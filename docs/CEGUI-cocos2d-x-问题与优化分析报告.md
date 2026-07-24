# CEGUI-0.7.1 与 cocos2d-x-2.2.6 问题与优化分析报告

> **版本**：2.1.3
> **审核日期**：2026-07-23
> **审核对象**：`dependencies/cegui/CEGUI` 运行时、`cocos2d-x-2.2.6` Win32/Android 主线，以及 FireClient/Nuclear 的实际调用链
> **文档性质**：源码驱动的全链路复核。原报告中的 `tools/CEGUI-0.7.1` 仅作为历史并存快照，不作为运行时证据源。

## 1. 审核结论

本次审核将原报告的 22 个问题小节逐条回到工程实物、项目文件和调用链验证；原报告优化汇总中的 P1-P14 只是建议编号，不等于问题数量。结论分为“已确认”“条件成立”“待验证/优化项”“推翻或降级”四类。修复实施前确认的 P0/P1 根因如下：

1. **P0：异步资源线程退出顺序**。`System::destroy()` 先析构 `System`，再调用 `CEGUIResLoadThread::Destroy()`；而 `System` 析构会清理 Imageset、纹理和渲染器依赖。只要工作线程尚未 join，就存在回调访问已析构对象的窗口。
2. **P1：CEGUI 与 Nuclear 的混合渲染状态契约不完整**。`GameUIManager` 在 CEGUI 绘制中间多次 `endRendering()`/`beginRendering()`，Renderer 仅保存单槽 scissor 快照，并且 `endRendering()` 强制设置 blend，未覆盖调用前的完整 GL/Cocos 状态。
3. **P1：`updataFromMemory()` 的像素格式与缓冲区实现存在真实内存错误**。PF_RGB 使用 3 字节步长，却无条件写入第 4 个字节；不支持格式时步长为 0；空纹理分支把输入当作 alpha 平面，却按调用方格式上传。
4. **P1：纹理失效后的批次引用与地址复用风险**。`GeometryBuffer::draw()` 调用 `ReleaseTexture()` 后，批次仍保留旧指针；`isTextureValid()` 仅按地址查找，地址复用时可能出现 ABA 误判。
5. **P1：GL 状态恢复覆盖面不足**。当前代码保存了 projection/modelview 栈和 scissor，但没有形成 GLES2 可用的完整显式快照；viewport、active texture、纹理参数、vertex attrib、depth/stencil/cull 以及 Cocos 状态缓存均未形成一致契约。
6. **P1：异步任务取消和失败闭环缺失**。文件/解析任务持有 renderer、texture 原始指针；`destroyTexture()` 只移除 renderer 容器记录，未从任务队列取消对应任务。文件读取、解析或 GPU 初始化失败时，也存在 task、loading 标记和空纹理未闭环的问题。

本轮已按 A/B 阶段实施 P0/P1 修复：`System::destroy()` 先停止并 join 资源线程；TaskManager 增加队列锁、取消、失败回调、运行任务所有权和析构清理；文件/解析任务使用独立引用计数的加载数据；纹理增加失败、销毁挂起和延迟释放状态；GeometryBuffer 在失效纹理前摘除引用；Renderer 与 `GameUIManager` 使用可嵌套的显式 GL/Cocos 状态快照。针对 `23_4_39_29.dmp` 新增修复：FreeType 空白字形产生的零面积 `copyRect` 在已有纹理上直接作为无操作处理，同时继续拒绝反向、负坐标、越界和非整数矩形。CEGUI、engine、FireClient、MT3 已按 `v120|Win32` 完成 Release 全链重建，运行时文件已同步到 `client/resource/bin/Release`；因此本版把代码、产物、依赖审计和运行时取证分开记录。

### 1.1 最新 Dump 根因闭环（2026-07-23）

运行目录中的 `client/resource/bin/Release/23_4_39_29.dmp`（148,390,203 bytes，12:41:52）与同一会话的 `CEGUI_history.log` 对齐，首个错误为：

```text
CEGUI::RendererException in CEGUICocos2DTexture.cpp(428)
Cocos2DTexture::updateFromMemory failed: invalid source rectangle.
```

调用链为 `FreeTypeFont::rasteriseHZ()` -> `copyRect` -> `Cocos2DTexture::updataFromMemory()`。FreeType 对空格、空白字形以及宽度或高度为 0 的 glyph 保留 advance，但会生成零面积矩形；旧校验把 `right == left` 或 `bottom == top` 与反向矩形一起判为错误，主线程上传字体图集时抛出异常并进入崩溃流程。

修复位于 [CEGUICocos2DTexture.cpp](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DTexture.cpp)：保留整数尺寸、负坐标、反向矩形、缓冲区边界和目标纹理边界校验；对已有纹理的零面积更新直接返回；新纹理仍走完整 coverage page 上传。修复后清理日志并完成构建，`CEGUI_ct.log` 当前为空，运行目录未出现同类新错误。

### 1.2 Debug 启动阻塞闭环（2026-07-23）

Debug 全链构建首次完成后，`client/resource/bin/Debug/MT3.exe` 弹出“损坏的映像”，退出码为 `0xC000012F`。二进制取证显示 Debug 目录的 `fmodex.dll` 为 619,244 bytes，文件头为 `78 01 ...`，属于压缩数据而非 PE；`dumpbin /headers` 返回无效格式。根因是 runtime-sync 对 FMOD 候选只做存在性判断，将 `client/resource/res1/Update/bin/release/fmodex.dll` 的压缩内容复制到了 Debug 运行目录。

已在 [Build-MT3-v120.ps1](../client/Build-MT3-v120.ps1) 增加 `Test-ValidWin32PeFile`：校验 `MZ`、PE 签名和 x86 machine `0x014C`，`fmodex.dll` 候选不通过时跳过并继续寻找有效候选；Debug 候选链增加已验证的 `client/resource/bin/Release/fmodex.dll` 回退。修复后 Debug 目录 FMOD 为有效 1,266,688-byte x86 PE，SHA256 `E86B1D932038AD26EDE26A43EF2B3AF1E5D5C6BD9ECE0161CDE0D5FB82C686DC`，不再复制压缩资源包内容。

回归时重新将 619,244-byte 压缩内容放回 Debug 目录，并通过 `-FmodDll` 显式指定该坏候选。canonical Debug 增量构建输出 `runtime-sync ignored invalid Win32 PE candidate`，随后自动复制有效候选；恢复后的 `fmodex.dll` 文件头为 `4D 5A 90 00`。再次启动 `MT3.exe` 15 秒后进程仍为 `Responding=True`，项目日志已生成且无新 Dump，证明同步链能够从坏映像状态自动恢复。

### 1.3 Android MuMu 闪退闭环（2026-07-23）

MuMu `emulator-5556`（Android 12、PD2364/V2364A）旧 Debug 包的首个崩溃为 `SIGSEGV`，调用链落在 `Json_dispose()` -> `UpdateJson::onGetUpdateJson()` -> `UpdateManagerEx::StepLoadVersion()`。根因是 `Json_new()` 使用 `malloc(sizeof(Json))`，导致 `next`、`child` 和字符串指针携带未初始化垃圾值；更新响应释放时形成递归野指针链。修复为 `calloc(1, sizeof(Json))` 后重新构建并安装 `client/android/LocojoyProject/bin/mt3-debug.apk`。

当前 Debug APK 为 1,845,012,181 bytes，SHA256 `D1173477D43391EA7B22E1DB0F74B57FB53D816DAD363B046D3E398F20CEF919`，仅含 `arm64-v8a`。MuMu 连续 90 秒采样及 3 轮独立冷启动（PID `4790`、`4985`、`5178`）均保持进程存活，crash buffer 为 0，未出现新的 `Json_dispose`、`SIGSEGV`、`SIGABRT`；日志中的 `libhp12_x86_64.so` 是模拟器 ARM64 转译层加载提示，不是 MT3 崩溃根因。

### 1.4 iOS 脚本解析与静态工程门禁（2026-07-23）

`tools/scripts/Build-iOS-MT3.ps1` 原文件为 UTF-8 无 BOM。Windows PowerShell 5.1 按系统代码页解析中文注释后，将第 210 行的注释与 `switch` 合并，因而在第 211/214/224 行报告 `Unexpected token '{'`。脚本已恢复 UTF-8 BOM；同时移除自定义 `-Verbose` 参数与公共参数冲突，增加 `-StaticGateOnly`，并让 `-WhatIf` 在 Xcode 检查前生成计划。

静态门禁已嵌入该脚本，检查 FireClient、engine、CEGUI 三个 `project.pbxproj` 的目标、宏、子工程关系、入口文件、iOS Cocos 旧树和预编译库，并拒绝未经专项迁移的 `cocos2d-x-2.2.6` 漂移。当前门禁结果为 **29/36 PASS，7 FAIL**：缺失项均来自 `cocos2d-2.0-rc2-x-2.0.1` 的 iOS Cocos 工程、Lua/Spine 头文件及 FMOD/curl/LuaJIT 归档。2026-07-22 的仓库清理提交删除了该目录下 900 个已跟踪构建产物（约 411.67 MiB），但其父版本同样不含门禁所需的 iOS 源码和 Xcode 工程，不能通过回退该提交恢复可构建依赖；需要补齐 2.2.6 的 iOS 支持或恢复 2.0 旧树中被删除的 iOS 专属产物（三个 pbxproj 已引用 `cocos2d-x-2.2.6`，非 2.0 旧树）。Windows 本机无 `xcodebuild`，因此本轮不宣称 iOS 编译通过。

原报告中“CCTexture2D 双重所有权必然悬空”“`new`/`delete` 失败路径构成泄漏”“`CheckLoadingTexture` 锁外修改”“`destroySystem` 资源提供者删除顺序错误”“相同 RenderEffect 指针必然 UAF”“D3D 设备丢失测试适用”等结论，均未获得当前工程证据，已在第 5 节明确降级或推翻。

## 2. 证据范围与实际依赖树

### 2.1 运行时源码树

- CEGUI 运行时代码：`dependencies/cegui/CEGUI/**`。
- CEGUI Cocos2D 后端：`dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/` 及对应 `include/RendererModules/Cocos2D/`。
- 历史工具/并存快照：`tools/CEGUI-0.7.1/**`。它与运行时树的 `CEGUICocos2DRenderer.cpp`、`CEGUICocos2DTexture.cpp` 已存在差异，工具快照行号不适用于运行时裁决。
- Cocos2d-x 主线：Win32 canonical 与 Android free 工程使用 `cocos2d-x-2.2.6`；iOS 三个 Xcode 工程已引用 `cocos2d-x-2.2.6`；历史 `cocos2d-2.0-rc2-x-2.0.1/` 在当前工作树中不存在，但原 2.0 旧树中的部分 iOS 专属产物（Lua/Spine 头文件、FMOD/curl/LuaJIT 归档）仍缺失，静态门禁会阻断交给 macOS/Xcode 的构建；本报告不将 Win32/Android 结论外推到 iOS。

### 2.2 工程配置事实

- Win32 CEGUI 工程为 `dependencies/cegui/project/win32/cegui.win32.vcxproj`，仅有 `Debug|Win32` 和 `Release|Win32`，两者均定义 `CEGUI_STATIC`、`PUBLISHED_VERSION`。原报告引用的 `Debug_Static`、`ReleaseWithSymbols` 来自 `tools/CEGUI-0.7.1/projects/premake/**`，不是当前主线。
- Win32 FireClient/MT3 项目均包含 `../../dependencies/cegui/CEGUI/include`，并定义 `CEGUI_STATIC;PUBLISHED_VERSION`；Cocos 头文件与库路径指向 `cocos2d-x-2.2.6`。
- Android CEGUI 各模块的 `Android.mk` 同样显式定义 `-DPUBLISHED_VERSION` 和 `-DCEGUI_STATIC`。
- `cocos2d-x-2.2.6/cocos2dx/platform/third_party/win32/OGLES` 在当前工作树存在；“包含路径失效”的原结论不成立。

### 2.3 全链路调用图

```text
GameApplication::OnRenderUI
  -> ResetRenderTextures
  -> GameUImanager::Draw
  -> CEGUI::System::renderGUI
       -> Renderer::beginRendering
       -> RenderingRoot / GeometryBuffer::draw
       -> Renderer::endRendering
  -> GameUIManager::RenderWindowSprite / RenderUIEffect / DrawSysMsgEffect
       -> Nuclear::GetEngine()->DrawEffect
       -> Renderer::beginRendering / endRendering 再次切换
```

纹理资源链为：

```text
Imageset::createTexture
  -> Cocos2DRenderer::createTexture(filename, group, priority, synload)
  -> CLoadFileTask / CParseImageTask
  -> OnImageParsed -> m_mapLoadedTexture
  -> CheckLoadingTexture（渲染侧上传）
  -> GeometryBuffer 批次引用 Cocos2DTexture*
  -> ImagesetManager::UpdateTextureState / OnFrameEnd
  -> destroyTexture / 自动释放
```

## 3. 原报告逐项裁决矩阵

| 原编号 | 原报告结论                       | 当前裁决                                                                                                                                                    | 级别     | 关键证据                                                                                                                                                                                                                                                                             |
| --- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.1 | 矩阵栈竞争                       | **条件成立**：push/pop 本身成对；异常或调用不配对时仍缺少守卫。`RenderTarget::activate()` 还会改 viewport/projection。                                                               | P2     | [CEGUICocos2DRenderer.cpp:677](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L677)、[CEGUICocos2DRenderTarget.cpp:44](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderTarget.cpp#L44)                                |
| 1.2 | Scissor 竞争                  | **已确认**：Renderer 只有单槽快照；嵌套 `end/begin` 会覆盖进入 CEGUI 前的快照。GameUIManager 在原状态已启用时也可能恢复错误 box。                                                              | P1     | [CEGUICocos2DRenderer.cpp:692](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L692)、[GameUIManager.cpp:1012](../client/FireClient/Application/Manager/GameUIManager.cpp#L1012)                                                                 |
| 1.3 | Shader 推栈嵌套                 | **降级**：正常 ETC 路径 push/pop 成对，当前代码未见 early return；保留 Debug 深度断言建议。                                                                                       | P2     | [Cocos2DGeometryBuffer.cpp:196](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DGeometryBuffer.cpp#L196)                                                                                                                                                     |
| 1.4 | 单帧多次 begin/end              | **已确认**：是混合渲染状态风险的直接触发条件；异常恢复尚无 scope 守卫。                                                                                                               | P1     | [GameUIManager.cpp:1012](../client/FireClient/Application/Manager/GameUIManager.cpp#L1012)、[GameUIManager.cpp:1126](../client/FireClient/Application/Manager/GameUIManager.cpp#L1126)、[GameUIManager.cpp:1905](../client/FireClient/Application/Manager/GameUIManager.cpp#L1905) |
| 2.1 | CCTexture2D 双重所有权           | **推翻原定性**：CEGUI `retain()` 会使 retainCount 大于 1，`CCTextureCache::removeUnusedTextures()` 只清理 retainCount 为 1 的对象；现有证据支持该引用计数契约。                          | P3     | [CEGUICocos2DTexture.cpp:536](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DTexture.cpp#L536)、[CCTextureCache.cpp:633](../cocos2d-x-2.2.6/cocos2dx/textures/CCTextureCache.cpp#L633)                                                                       |
| 2.2 | `new` 无 `delete` 配对         | **推翻原定性**：`CCObject::release()` 最终也是 `delete this`；失败路径直接 `delete`，成功路径由 CEGUI 对象析构 `release()`。真正风险是失败处理与异步任务并发，不是该段本身的泄漏。                             | P3     | [CEGUICocos2DTexture.cpp:196](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DTexture.cpp#L196)、[CCObject.cpp:79](../cocos2d-x-2.2.6/cocos2dx/cocoa/CCObject.cpp#L79)                                                                                        |
| 2.3 | GL 纹理失效释放不完整                | **已确认**：`ReleaseTexture()` 删除 renderer 所有权，但 GeometryBuffer 批次仍保留指针；地址复用后 `isTextureValid()` 可能误判。                                                      | P1     | [Cocos2DGeometryBuffer.cpp:193](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DGeometryBuffer.cpp#L193)、[CEGUICocos2DRenderer.cpp:948](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L948)                               |
| 3.1 | 加载完成操作无锁                    | **部分推翻、仍有并发缺口**：`m_mapLoadedTexture` 查找、上传、删除均在 `m_mutexLoadedTextures` 锁内；但同一锁没有覆盖 `d_loadingTextures`、`d_textures` 的全部访问，销毁路径仍可竞争。                    | P1     | [CEGUICocos2DRenderer.cpp:237](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L237)、[CEGUICocos2DRenderer.cpp:575](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L575)                                      |
| 3.2 | `OnFrameEnd` 锁外销毁竞争         | **条件成立**：当前实现锁内摘除、锁外 `destroyTexture()`；若渲染线程/任务线程与 `OnFrameEnd` 非同一线程，确有迭代器和回调风险。现有调用链尚不足以断言必然跨线程。                                                     | P1     | [CEGUICocos2DRenderer.cpp:301](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L301)                                                                                                                                                            |
| 3.3 | 非发布版异步上传缺失                  | **条件成立**：`CheckLoadingTexture()` 的上传受 `PUBLISHED_VERSION && !FORCEGUIEDITOR` 控制；主线 Win32/Android/iOS 工程均定义 `PUBLISHED_VERSION`，工具/编辑器配置仍可能得到“标记完成但未上传”。 | P2     | [CEGUICocos2DRenderer.cpp:247](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L247)、[cegui.win32.vcxproj:68](../dependencies/cegui/project/win32/cegui.win32.vcxproj#L68)                                                                      |
| 4.1 | 预处理器不一致                     | **推翻对主线的结论**：主线 CEGUI 仅 Debug/Release 且均有 `PUBLISHED_VERSION`；原矩阵描述的是工具快照。仍应在 CI 中锁定宏矩阵。                                                                | P3     | [cegui.win32.vcxproj:68](../dependencies/cegui/project/win32/cegui.win32.vcxproj#L68)                                                                                                                                                                                            |
| 4.2 | 过时 OGLES 路径                 | **推翻**：`OGLES` 目录存在，且 Win32 canonical 项目实际引用 `cocos2d-x-2.2.6`。                                                                                         | P3     | [mt3.win32.vcxproj:71](../client/MT3Win32App/mt3.win32.vcxproj#L71)                                                                                                                                                                                                              |
| 4.3 | ReleaseWithSymbols 链接不全     | **不适用于主线**：主线 CEGUI 工程没有该配置；工具工程是否可构建应单列为历史工具治理。                                                                                                        | P3     | [cegui.win32.vcxproj:4](../dependencies/cegui/project/win32/cegui.win32.vcxproj#L4)                                                                                                                                                                                              |
| 5.1 | GeometryBuffer 缺 System 检查  | **降级为生命周期契约项**：正常渲染在 System 存活期内调用；真正需要修复的是 shutdown 顺序和调用方不应在 System 销毁后绘制。                                                                            | P2     | [Cocos2DGeometryBuffer.cpp:86](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DGeometryBuffer.cpp#L86)、[CEGUISystem.cpp:483](../dependencies/cegui/CEGUI/src/CEGUISystem.cpp#L483)                                                                           |
| 5.2 | Size 构造未实现                  | **已确认但调用面有限**：构造函数仅 assert，Release 下仍生成空纹理对象；Renderer API 与 Lua 绑定公开，应删除接口或实现。                                                                          | P2     | [CEGUICocos2DTexture.cpp:57](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DTexture.cpp#L57)、[CEGUICocos2DRenderer.cpp:561](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L561)                                          |
| 5.3 | `updataFromMemory` 断言不足     | **升级为已确认内存错误**：见第 4.3 节，优先级由低改为 P1。                                                                                                                     | P1     | [CEGUICocos2DTexture.cpp:371](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DTexture.cpp#L371)                                                                                                                                                              |
| 5.4 | `destroySystem` provider 顺序 | **推翻原定性**：`System::~System()` 会按自身所有权清理 provider；外部 provider 的删除发生在 System 析构之后符合当前所有权设计。真正顺序问题是资源线程停止太晚。                                               | P1（改判） | [CEGUISystem.cpp:417](../dependencies/cegui/CEGUI/src/CEGUISystem.cpp#L417)、[CEGUICocos2DRenderer.cpp:395](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L395)                                                                                |
| 6.1 | 特效与 CEGUI GL 状态冲突           | **与 1.2/1.4 合并确认**：`glPushAttrib/glPopAttrib` 不适用于 GLES2；应做显式快照并同步 Cocos 状态缓存。                                                                          | P1     | [GameUIManager.cpp:1021](../client/FireClient/Application/Manager/GameUIManager.cpp#L1021)、[CEGUICocos2DRenderer.cpp:719](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L719)                                                                 |
| 6.2 | RenderEffect 相同指针 UAF       | **推翻**：代码先判断 `d_effect != effect`，相同指针时不会 delete。实际问题是裸拥有指针缺少所有权注释和复制/替换契约。                                                                             | P3     | [Cocos2DGeometryBuffer.cpp:382](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DGeometryBuffer.cpp#L382)                                                                                                                                                     |
| 7.1 | 压缩纹理格式差异                    | **条件成立**：枚举映射覆盖 PVR/ATC/DXT3/DXT5/ETC，但设备支持和资源头合法性没有统一日志与回退矩阵；加载失败可表现为空白。                                                                               | P2     | [CEGUICocos2DTexture.cpp:205](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DTexture.cpp#L205)                                                                                                                                                              |
| 7.2 | WP8 旋转                      | **历史平台项**：代码仍存在，但 WP8 不属于当前 Win32/Android 交付主线；保留兼容分支，不纳入主线优先级。                                                                                         | P3     | [CEGUICocos2DRenderTarget.cpp:52](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderTarget.cpp#L52)                                                                                                                                                      |
| 7.3 | 非发布版资源路径                    | **条件成立**：`../../res`/`../../res1` 依赖进程工作目录；资源源实际位于 `client/resource/res`，开发启动布局变化时会失败。                                                                  | P2     | [GameUIManager.cpp:1756](../client/FireClient/Application/Manager/GameUIManager.cpp#L1756)                                                                                                                                                                                       |

## 4. 已确认问题详证与实施状态

### 4.1 P0：异步资源线程必须先停止再销毁 System

`CEGUISystem` 构造时启动 `CEGUIResLoadThread`，线程通过 `CCEGUITaskManager` 运行文件读取和解析任务。当前 `System::destroy()` 的顺序是：

```cpp
delete System::getSingletonPtr();
CEGUIResLoadThread::Destroy();
```

而 `System::~System()` 在删除线程前已经清理 ImageCodec、XML、窗口、ImagesetManager 及资源 provider。工作线程在 `Destroy()` 获得执行前，仍可能完成 `CParseImageTask::Run()` 并回调 `Cocos2DRenderer::OnImageParsed()`。这不是“provider 删除太早”，而是线程拥有的回调目标与 CEGUI 对象销毁顺序倒置。

**修复契约**：在 `System::destroy()` 开始处调用停止并 join；停止后清空或取消待处理 task，保证 `OnFileLoaded`、`OnImageParsed` 不再触达 renderer/system；再析构 System、Imageset、Renderer 和 provider。`CEGUIResLoadThread::Destroy()` 当前使用 `StopRunning()`、fire semaphore、`Join()`，可作为统一入口，但需要把它移动到 System 析构之前并验证重复创建/销毁。

修复前重复初始化还存在独立问题：`CEGUIResLoadThread::~CEGUIResLoadThread()` 删除 `g_LoadResSem` 引用所指对象，但 `pSem`/`g_LoadResSem` 是静态初始化且没有重建逻辑。下一次 `System` 创建新线程时会继续使用已释放的 semaphore。生命周期修复必须同时让 semaphore 成为线程对象成员，或提供明确的进程级单例存续周期。

**当前实施状态**：`System::destroy()` 已先调用 `CEGUIResLoadThread::Destroy()`，由其执行 `StopRunning()`、唤醒、`Join()`、删除线程并清空单例，再析构 `System`。semaphore 已成为 `CEGUIResLoadThread` 对象成员，TaskManager 在线程退出时销毁并清理待执行队列。CEGUI Release 重建通过；连续两次 create/destroy 与退出压力仍需运行时验证。

### 4.2 P1：CEGUI/Nuclear 混合渲染的嵌套状态覆盖

`System::renderGUI()` 自身执行一对 `beginRendering()`/`endRendering()`。在其绘制过程中，GeometryBuffer 绑定的 RenderEffect 会回调 `GameUIManager::RenderWindowSprite()`、`RenderUIEffect()` 等逻辑；修复前 `DrawSysMsgEffect()` 也主动结束 CEGUI 状态、绘制 Nuclear 特效、再开始 CEGUI，Renderer 的状态结构只有一份 `d_stateManager.d_ScissorEnabled` 与 `d_ScissorBox`：

```cpp
d_stateManager.d_ScissorEnabled = glIsEnabled(GL_SCISSOR_TEST);
glGetIntegerv(GL_SCISSOR_BOX, d_stateManager.d_ScissorBox);
// ...
if (!d_stateManager.d_ScissorEnabled)
    glDisable(GL_SCISSOR_TEST);
glScissor(d_stateManager.d_ScissorBox);
```

第一次 `begin` 保存的状态会被第二次 `begin` 覆盖。若特效前 scissor 已启用且 box 为 A，特效结束后第二次 `begin` 保存的是 B，最终 `end` 恢复 B 而不是 A。GameUIManager 自己的 `scissorEnable` 分支也只在进入特效前后局部恢复，不足以替代 Renderer 的嵌套栈。

**修复契约**：

- 让 `beginRendering`/`endRendering` 只在完整帧边界调用；特效绘制改为显式 `ScopedExternalPass`，由同一个状态快照对象保存和恢复。
- 若必须支持嵌套，使用深度栈而非单槽 scissor；每层保存 enable、box、blend、active texture、program、vertex attrib、纹理参数和 Cocos `ccGLStateCache` 相关缓存。
- GLES2 不支持桌面 OpenGL 的 `glPushAttrib/glPopAttrib`，原报告建议不适用于 Android。

**当前实施状态**：Renderer 已使用 `d_stateStack`、`d_externalStateStack` 和 external-pass depth 管理嵌套快照；`GameUIManager` 已用 `ScopedExternalRenderPass` 包裹三个 Nuclear 外部绘制入口，scope 析构时恢复状态。`System::renderGUI()` 异常路径也会配对调用 `endRendering()`。CEGUI 与 engine Release 重建通过；特效交替绘制和裁剪嵌套仍需客户端运行时验证。

### 4.3 P1：`updataFromMemory` 的三个独立错误

修复前代码行为：

1. `iStride` 只对 `PF_RGBA`/`PF_RGB` 赋值；其它格式保持 0，随后 `for (col += iStride)` 可能死循环，并且分配 0 字节缓冲区。
2. 循环无论输入格式都写 `dstPos[col + 3]`。PF_RGB 的每像素只有 3 字节，最后一次写入越过每行或整个分配边界。
3. `d_texture == NULL` 时分配 RGBA 缓冲，把输入按 alpha 平面读取，却继续用调用者传入的 `pixel_format` 调用 `loadFromMemory`；PF_RGB 或压缩格式的语义不成立。

该接口的当前调用语义是 FreeType/业务字体生成的单字节 coverage 平面，缓冲区大小为 `width * height`；`PF_RGB`/`PF_RGBA` 表示转换后的目标纹理格式，并不表示传入的是普通三通道或四通道源图像。字体上传主要走 `PF_RGBA`，`SpaceManager::CreateImage` 也按 alpha 选择 `PF_RGBA`/`PF_RGB`。

**修复契约**：先验证 `buffer`、整数尺寸、rect 边界、溢出和目标格式；PF_RGBA 将每个 coverage 值转换为白色 RGB 与 coverage alpha，PF_RGB 将 coverage 扩展为三通道灰度；其它格式直接抛出明确异常。空纹理分支使用转换后的完整目标缓冲，已有纹理分支仅上传目标 rect，并在结束后恢复 GL active texture、binding 和 unpack alignment。

**当前实施状态**：上述校验、转换、上传和 GL 状态恢复已实现，PF_RGB 路径不再写第 4 字节，未知格式不再以 0 步长进入循环；零面积字形回归已由 Dump 复现模式覆盖并通过静态调用链闭环。CEGUI Release 重建通过；PF_RGB/PF_RGBA 的独立运行时 harness、越界 rect 和空纹理专项仍需在可启动桌面会话中完成。

### 4.4 P1：失效纹理的悬挂批次与 ABA

`Cocos2DGeometryBuffer::draw()` 在 `glIsTexture(texId)==GL_FALSE` 时调用 `pRender->ReleaseTexture(pTex)` 并继续遍历批次。`ReleaseTexture()` 从 `d_RenderTextures` 删除并调用 `destroyTexture()`；GeometryBuffer 的 `d_batches` 仍然保存 `Cocos2DTexture*`。下一帧可能再次访问已删除对象。当前 `isTextureValid()` 只是 `std::find(d_textures, pointer)`，若 allocator 将同一地址分配给新纹理，会把旧批次误认为新对象。

**修复契约**：失效时先把批次标记为无效并从 GeometryBuffer 的批次或纹理引用中摘除，再由 renderer 延迟销毁；用 generation/token 或稳定句柄替代裸地址有效性判断；纹理重新加载必须创建新批次或显式刷新引用。

**当前实施状态**：Renderer 销毁纹理前会通知全部 GeometryBuffer 执行 `releaseTexture()`，批次引用被清空；运行任务尚持有纹理时进入 `d_pendingDestroyTextures`，任务结束后再释放。GeometryBuffer 跳过无效批次时同步推进顶点偏移，避免后续批次读取错位。当前补丁以“先摘除引用 + 延迟释放”关闭已知悬挂窗口，稳定句柄/generation 仍作为后续结构优化项。

### 4.5 P1：显式 GL/Cocos 状态快照

`beginRendering()` 会修改 texture filter/wrap、blend、scissor、shader、vertex attrib；`endRendering()` 只恢复矩阵栈和 scissor，并强制 `GL_SRC_ALPHA/GL_ONE_MINUS_SRC_ALPHA`。`Cocos2DRenderTarget::activate()` 还会设置 viewport 和 projection。状态契约至少缺少：viewport、active texture、texture bindings/parameters、program、vertex attrib enable/pointer、depth/stencil/cull、color mask、blend enable/function，以及 Cocos 状态缓存的同步。

**修复契约**：建立 GLES2 兼容的 `Cocos2DRenderStateSnapshot`，在唯一入口保存、在 scope 结束恢复；恢复后同步 `ccGLStateCache`，避免“GL 实际状态”和 Cocos 缓存分裂。

**当前实施状态**：`captureRenderState()`/`restoreRenderState()` 已覆盖 scissor、viewport、blend、depth、stencil、cull、color mask、program、active texture、前两个纹理单元、unpack alignment、VBO/EBO 和三个标准 vertex attrib；恢复时通过 Cocos GL 包装同步主要缓存，并显式关闭快照中原本关闭的 attrib。CEGUI 与 engine Release 重建通过；多窗口、ETC shader 和 Android GLES2 实机状态一致性仍待运行时验证。

### 4.6 P1：异步任务持有悬挂 renderer/texture 指针

`CLoadFileTask` 和 `CParseImageTask` 都直接保存 `Cocos2DRenderer*`、`Cocos2DTexture*`。`destroyTexture()` 会从 `m_mapLoadingTexture`、`d_loadingTextures`、`d_textures` 移除并删除纹理，却没有从 `CCEGUITaskManager` 的 file/parse/cache 队列取消对应任务。已排队任务随后仍可执行 `OnFileLoaded(this)` 或 `OnImageParsed(this)`，把已释放的纹理地址重新放入后续任务或 `m_mapLoadedTexture`；renderer 析构后继续执行时，renderer 指针也会悬挂。

`CCEGUITaskManager::destroy()` 只是删除 manager；类没有析构函数清理 `m_vCacheTasks`、`m_mapFileTasks`、`m_vParseTasks`、`m_vFontTasks` 中的 `ITask*`。因此 shutdown 即使先 join，也需要显式取消和释放所有未执行任务。

**修复契约**：task 使用稳定的取消 token 和纹理 generation，不以裸指针代表存活性；`destroyTexture` 先标记取消，再由队列安全摘除；worker 回调前校验 renderer epoch、texture generation 和 shutdown 状态；TaskManager 析构逐队列释放任务并核对所有权唯一性。

**当前实施状态**：TaskManager 的 file/parse/font/cache 队列及运行任务均由同一队列锁保护，支持按 renderer/texture owner 取消与查询；工作任务回调前检查取消状态，纹理销毁设置 `m_bDestroyPending` 并等待运行任务退出。文件任务与解析任务共享独立引用计数的 `CTextureLoadData`，TaskManager 析构清理全部未执行任务。当前实现已关闭已知裸指针销毁窗口，renderer epoch/纹理 generation 作为后续强化项保留。

### 4.7 P1：加载失败会泄漏任务、卡住 loading 或解引用空纹理

失败链存在三种结果：

1. `CLoadFileTask::Run()` 遇到空文件直接 return，任务没有后续 owner，`m_mapLoadingTexture` 和 `m_bIsLoading` 保持原状。
2. `CParseImageTask::Run()` 遇到 codec 失败直接 return，parse task 及其持有的 file task没有进入 `m_mapLoadedTexture`，同样缺少清理入口。
3. `CheckLoadingTexture()` 调用 `loadFromBuffer()` 后，无论 `CCTexture2D::initWith*` 是否成功都会把 `m_bIsLoading` 设为 false。初始化失败会令 `d_texture == NULL`；下一帧 `Cocos2DGeometryBuffer::draw()` 调用 `getTextureName()` 时直接解引用空指针。同步创建路径也会在 codec 返回空结果后把空纹理放入 `d_textures`。

**修复契约**：统一 task 状态机为 queued/running/parsed/uploaded/failed/cancelled；每个终态都必须清理 map、queue、task 和 loading 标记；`loadFromBuffer` 返回明确成功值；GeometryBuffer 在读取 GL name 前检查纹理对象内部有效性，并用可诊断的占位纹理或跳过批次处理失败状态。

**当前实施状态**：文件读取、codec 解析和 GPU 初始化失败均进入失败回调；完成项记录 `bLoadSucceeded`，主线程上传后统一清理 task、map、loading 标记并设置 `m_bLoadFailed`。GeometryBuffer 在取 texture name 前检查对象与内部纹理有效性，失败批次直接跳过。OnFileLoaded、OnImageParsed、OnImageLoadFailed 还增加了取消/销毁挂起检查，覆盖 file→parse 入队交错。CEGUI Release 重建通过；失败注入与占位纹理策略仍需运行时验证。

## 5. 其它问题与优化项

### 5.1 P2：Size 构造函数和公开 API

`Cocos2DRenderer::createTexture(const Size&)` 是公共虚函数并被 Lua 绑定导出，但 `Cocos2DTexture(const Size&)` 只有 assert。建议二选一：实现 `CCTexture2D::initWithData` 的空白 RGBA 纹理并校验尺寸，或删除/禁用该后端 API，避免 Release 生成空对象。

### 5.2 P2：压缩纹理格式矩阵

`loadFromBuffer`/`loadFromMemory` 映射 PVR2/PVR4、ATC、DXT3/DXT5、ETC。资源格式应按 Win32、Android ABI/GPU、iOS 物理 Cocos 树分别维护；加载失败记录文件名、格式、宽高、资源组和设备能力，并定义 RGBA8888 回退。“枚举存在”只证明代码分支存在，不代表设备具备对应能力。

### 5.3 P2：非发布版资源目录

`GameUIManager.cpp` 在非 `PUBLISHED_VERSION` 下以 `CFileUtil::GetRootDir() + "../../res/"` 或 `../../res1/` 配置资源组；当前业务源目录是 `client/resource/res`，staging 目录由打包链生成。建议由启动配置传入资源根，或在开发启动器中固定工作目录并在启动时打印最终解析路径。

### 5.4 P2：OnFrameEnd 与销毁线程归属

`OnFrameEnd()` 在锁内从 `m_mapLoadedTexture` 摘除任务，锁外调用 `destroyTexture()`。这在所有渲染操作均运行于同一线程时可工作，但线程归属未在接口中表达。建议将 GPU 对象销毁排入渲染线程延迟队列，后台线程只做文件读取和解析；所有 `d_textures`、`d_loadingTextures`、`d_RenderTextures` 访问统一由渲染线程或同一把生命周期锁保护。

### 5.5 P3：纹理所有权和错误路径

`Cocos2DTexture::setCocos2DTexture()` 的 `retain/release` 与 cocos2d 引用计数能够保护 `CCTextureCache` 中对象，不建议为了“统一缓存”强行改造。应补充所有权注释和失败路径检查：

- `loadFromBuffer()`/`loadFromMemory()` 先释放旧纹理，再 `new CCTexture2D`；初始化失败后直接 `delete`。
- `createTexture(CCTexture2D*)` 的修复前实现曾把基类 `CCTexture2D*` 强转成 `Cocos2DTexture*` 读取 `m_bIsLoadFromFile`，这是未定义行为；当前构造函数直接将 `m_bIsLoadFromFile` 初始化为 `false`，不再读取错误动态类型的派生成员。
- 成功创建后应检查每个 `initWith*` 返回值，而不是只在 `loadFromBuffer()` 的一条路径检查。

### 5.6 P3：RenderEffect 所有权契约

`setRenderEffect` 在 `d_effect != effect` 时删除旧对象，因此“传入同一指针立即 UAF”的原推导不成立。但该 API 使用裸 owning pointer，调用方必须明确移交所有权；建议改名或注释为 `setOwnedRenderEffect`，或采用 clone/智能指针语义（受 C++03 工具链约束可使用项目已有封装）。

## 6. 分阶段修复路线

| 阶段 | 工作项 | 影响范围 | 当前状态 | 验证门槛 |
|---|---|---|---|---|
| A：先止血 | 线程停止顺序和 semaphore 生命周期；task 取消/失败闭环；`updataFromMemory` 格式/边界修复；失效批次摘除；删除错误派生类强转 | `dependencies/cegui/CEGUI` Cocos2D 后端、CEGUIBase | **代码完成；CEGUI Release PASS** | Win32 Debug/Release UI 回归；异步加载失败与退出压力；CEGUI 二次初始化；PF_RGB/PF_RGBA 回归 |
| B：状态治理 | GLES2 显式状态快照；`ScopedExternalRenderPass` 收敛 GameUIManager 外部绘制；补 viewport、blend、shader、纹理和 Cocos cache 恢复 | CEGUI Cocos2D renderer、FireClient GameUIManager、engine 下游 | **代码完成；CEGUI/engine Release PASS** | UI 与 Nuclear 特效交替绘制；裁剪 box 嵌套；多窗口/RenderEffect 顺序 |
| Win32 链路 | 按 `CEGUI -> engine -> FireClient -> MT3` 重建 Debug/Release 产物并记录首错 | CEGUI、engine、FireClient、MT3 | **Debug/Release 全链 PASS；Debug FMOD 运行时同步已修复** | 运行目录冷启动、压力、二次初始化、PF_RGB/PF_RGBA、特效交替绘制 |
| C：资源矩阵 | 压缩格式能力探测、日志和 RGBA 回退；开发资源根配置化 | CEGUI ImageCodec、资源启动配置、打包 staging | 本轮未进入 | Win32、Android free、iOS 各自资源格式矩阵；缺失/损坏纹理可诊断 |
| D：工具治理 | 单独审计 `tools/CEGUI-0.7.1` 的 Debug_Static/ReleaseWithSymbols 配置，不把其结论混入运行时报告 | `tools/CEGUI-0.7.1/**` | 本轮未进入 | 工具工程按自身配置独立构建；与运行时差异有清单 |

### ABI 与重编边界

若修改 CEGUI 公共头、Renderer/Texture 类成员或虚函数，按 `CEGUI -> engine -> FireClient -> MT3` 全链重建；Cocos 公共接口或对象布局变化还需先重编 `cocos2d-x-2.2.6`。Android 按 free canonical 入口执行 NDK/Ant 门禁；iOS 必须在 macOS/Xcode 上按旧 Cocos 树单独复验。

## 7. 分平台验证矩阵

| 平台              | 当前物理依赖                                                    | 必测项                                                            | 入口/备注                                                                                       |
| --------------- | --------------------------------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Win32 canonical | `cocos2d-x-2.2.6` + `dependencies/cegui/project/win32`    | Debug/Release；异步加载；特效交替；scissor/viewport；PF_RGB/PF_RGBA；纹理缓存清理 | `tools/scripts/Build-MT3-Exe-Canonical.ps1`；项目宏均含 `PUBLISHED_VERSION`                       |
| Android free    | `cocos2d-x-2.2.6`，NDK r16b/clang，`android-21`，`arm64-v8a` | GLES2 状态恢复；ETC/ATC 能力；后台解析与渲染线程边界；退出 join                      | `tools/scripts/Build-Android-Locojoy-WithGate.ps1`；同时检查 `engine/Android.mk` 旧 libSpine 导入门禁 |
| iOS             | 工程已引用 `cocos2d-x-2.2.6`，但原 2.0 旧树的部分 iOS 专属产物仍缺失 | 先补齐 2.2.6 iOS 支持或恢复缺失产物；再复验共用 CEGUI 逻辑和 iOS Cocos 实现 | `tools/scripts/Build-iOS-MT3.ps1 -StaticGateOnly`；门禁通过后再交给 macOS/Xcode                  |
| WP8/历史工具        | 非当前交付主线                                                   | 仅在维护该工程时验证旋转和工具配置                                              | 不纳入本次主线优先级                                                                                  |

## 8. 测试与观测建议

### 8.1 回归场景

1. 启动 UI 异步加载，连续切换 Scheme/Imageset，随后执行 CEGUI shutdown；验证后台任务已 join 且无回调落到已析构对象。
2. 在 file task、parse task、GPU upload 三个阶段分别注入失败，同时销毁 Imageset/Texture；验证任务进入 failed/cancelled 终态、容器清空且无悬挂回调。
3. 连续执行两次 CEGUI create/destroy；验证线程、TaskManager 和 semaphore 均完成重新初始化。
4. CEGUI 绘制中交替插入 `RenderWindowSprite`、`RenderUIEffect`、`DrawSysMsgEffect`；保存并比较进入 CEGUI 前后的 scissor、blend、viewport、program 和 active texture。
5. 构造 PF_RGB 3 字节、PF_RGBA 4 字节、空纹理、越界 Rect、压缩格式输入；用 ASan 或调试堆检查越界、死循环和空纹理。
6. 人为令 `glIsTexture` 失败，验证批次摘除、纹理延迟销毁和重新加载后不会命中新对象地址。
7. Win32 `CCTextureCache::removeUnusedTextures()` 前后检查 CEGUI 纹理仍可绘制，验证 retainCount 契约而不是修改缓存所有权。

### 8.2 静态与运行时检查

- 对 `createTexture(CCTexture2D*)` 做 RTTI/调用面审计，禁止基类指针读取 CEGUI 派生字段。
- 在 Debug 中记录 renderer 状态栈深度、纹理 generation、异步 task 数量和销毁线程 ID。
- 对 `d_textures`、`d_loadingTextures`、`m_mapLoadedTexture` 建立线程归属断言。
- Android 侧使用 GLES 调试层或 `glGetError` 抽样；OpenGL 状态恢复不使用桌面 `glPushAttrib/glPopAttrib`。

## 9. 关键源码索引

| 文件                                                                                                                       | 证据范围                                   |
| ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------- |
| [CEGUICocos2DRenderer.cpp](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp)             | 异步纹理队列、销毁、状态 begin/end、有效性判断           |
| [CEGUICocos2DTexture.cpp](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DTexture.cpp)               | Cocos 纹理所有权、格式映射、内存上传                  |
| [CEGUICocos2DGeometryBuffer.cpp](../dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/CEGUICocos2DGeometryBuffer.cpp) | scissor、失效纹理批次、ETC shader、RenderEffect |
| [CEGUISystem.cpp](../dependencies/cegui/CEGUI/src/CEGUISystem.cpp)                                                       | renderGUI 生命周期、System 析构与线程销毁顺序        |
| [CEGUIResLoadThread.cpp](../dependencies/cegui/CEGUI/src/CEGUIResLoadThread.cpp)                                         | StopRunning/fire/Join 退出协议             |
| [CEGUILoadingTaskManager.cpp](../dependencies/cegui/CEGUI/src/CEGUILoadingTaskManager.cpp)                               | file/parse/font/cache 队列、任务所有权和退出清理    |
| [GameUIManager.cpp](../client/FireClient/Application/Manager/GameUIManager.cpp)                                          | CEGUI/Nuclear 交错绘制、特效 scissor、资源根      |
| [SpaceManager.cpp](../client/FireClient/Application/Manager/SpaceManager.cpp)                                            | PF_RGB/PF_RGBA 内存纹理调用面                 |
| [cegui.win32.vcxproj](../dependencies/cegui/project/win32/cegui.win32.vcxproj)                                           | Win32 当前配置与宏矩阵                         |
| [mt3.win32.vcxproj](../client/MT3Win32App/mt3.win32.vcxproj)                                                             | Win32 canonical Cocos/CEGUI include 与宏 |
| [CCTextureCache.cpp](../cocos2d-x-2.2.6/cocos2dx/textures/CCTextureCache.cpp)                                            | removeUnusedTextures retainCount 证据    |

## 10. 审核边界与未覆盖项

- 本轮已修改运行时 CEGUI Cocos2D renderer，并已落库的 P0/P1 修复同时覆盖 CEGUIBase、engine 下游和 FireClient 的调用契约；第 6 节状态列区分“代码完成”和“最终产物/运行时验证完成”。
- Win32 Release 实际取证（VS2013/v120、Windows SDK 8.1）：
  - **CEGUI：PASS**。`dependencies/cegui/project/win32/Release.win32/cegui.lib`，2026-07-23 12:58:42，107,917,256 bytes，SHA256 `D74BF127AC5EC2435265B4782E40AB1213412485429DBF63CE20AE7299561B8D`。
  - **engine：PASS**。`engine/Release.win32/engine.lib`，2026-07-23 12:59:14，70,302,660 bytes，SHA256 `BE18C371E053DEE1471028E8EDFC29779F9C6BCE2A0FF4D5D772A1EF8622727A`。
  - **FireClient：PASS**。`client/MT3Win32App/Release.win32/FireClient.lib`，2026-07-23 13:03:00，110,960,300 bytes，SHA256 `ADE95A3052C91F90002F76CC435AA09602087937C87E68C7797991B708A4EE87`。
  - **MT3：PASS**。`client/resource/bin/Release/MT3.exe`，2026-07-23 13:04:38，9,980,416 bytes，SHA256 `CEF1B7AADD387D8B9962B65A4BD8D130177DC7A5FAD37A2B050B5E15E4104328`。
  - **运行目录依赖审计：PASS**。`build_logs/runtime-audit-release-after-dump-fix.json`：`DriftCount=0`、`MissingDepCount=0`、`MissingDepHighCount=0`、`RuntimeImportHighCount=0`；12 个 High 仅来自 `client/resource/tools` 的编辑器 DLL 家族一致性检查，不属于 MT3 游戏运行目录。
  - **Dump 回归取证**。分析时已从旧 `CEGUI_history.log` 取证 12:41:51 的 `invalid source rectangle`；回归前清理旧日志和旧 Dump，修复后的 `CEGUI_ct.log` 保持 0 bytes，未出现同类新错误。
  - **Win32 冷启动观察：PASS（基础稳定性）**。13:13:09 从 `client/resource/bin/Release` 启动 `MT3.exe`，进程保持 `Responding=True`；13:15:11 至 13:16:01 每 10 秒采样 6 次，进程未退出，工作集约 233.7-235.2 MB，线程数 16-19；期间未生成新 `.dmp`，`CEGUI_ct.log` 保持 0 bytes。
- Win32 Debug 实际取证（VS2013/v120、Windows SDK 8.1）：
  - **CEGUI：PASS**。`dependencies/cegui/project/win32/Debug.win32/cegui_d.lib`，129,335,368 bytes，SHA256 `4CC3F9FB74834205693B67112C6FA8B0D950C829B6E9207A45AD476205DBCB9D`。
  - **engine：PASS**。`engine/Debug.win32/engine.lib`，102,710,754 bytes，SHA256 `A90F06C39F147C54EEF5A8DC715D3E8473EB037BFC87F43757BD5A800E98632E`。
  - **FireClient：PASS**。`client/MT3Win32App/Debug.win32/FireClient.lib`，156,658,156 bytes，SHA256 `2A773268F73BCAFD107253156FCF3958ED7399ABC0F966E929A5F9B8DDDE9B8C`。
  - **MT3：PASS**。`client/resource/bin/Debug/MT3.exe`，24,136,704 bytes，SHA256 `E0CD76D5FD7EEFB33AB7A6DBC3AEFB4B70215DEDF41027A39B92F7518080D512`；与 `client/MT3Win32App/Debug.win32/MT3.exe` 哈希一致。
  - **Debug 运行目录依赖审计：PASS**。`build_logs/runtime-audit-debug-after-fmod-fix.json`：`DriftCount=0`、`MissingDepCount=0`、`MissingDepHighCount=0`、`RuntimeImportHighCount=0`；12 个 High 仍仅来自编辑器 DLL 家族检查。
  - **Debug 冷启动：PASS**。修复 FMOD 后从 `client/resource/bin/Debug` 启动，连续 6 次、每 5 秒采样均为 `Responding=True`；已生成 `CEGUI_ct.log`（0 bytes）、`mt3_ct.log`、`startup_bootstrap.log`，进入登录 UI、Lua 初始化和 CEGUI/Nuclear 渲染循环，未生成新 `.dmp`，未出现 `0xC000012F` 或 `RendererException`。
  - **坏映像回归：PASS**。显式注入压缩 `fmodex.dll` 后，runtime-sync 跳过无效 PE、恢复有效 x86 FMOD，Debug 再次冷启动通过。
- Android：JDK 8 gate、arm64 migration gate、NDK r16 native build、Ant Debug package、APK structure/ABI、LJFM 资源路径、Audio JNI bridge、启动黑屏防护和 zipalign 均 PASS。MuMu 旧包的 `Json_dispose` 闪退已由 `Json_new()` 零初始化修复；90 秒采样和 3 轮冷启动均无新增 native crash。
- iOS 脚本解析：Windows PowerShell 5.1 parser 已 PASS；`Build-iOS-MT3.ps1` 保持 UTF-8 BOM，`switch` 目标分支不再因 CP936 错读而报语法错误。
- iOS 静态门禁：工程结构、目标、宏和引用关系 29/36 PASS；7 个失败均为原 `cocos2d-2.0-rc2-x-2.0.1` 旧树中、2.2.6 iOS 支持尚未补齐的工程/头文件/归档（三个 pbxproj 已引用 `cocos2d-x-2.2.6`）。该阻塞解决前不进入 macOS/Xcode 构建。本机无 `xcodebuild`，未执行 iOS 编译、签名或设备运行验证。
- 本轮尚未取得交互式长时间异步加载/退出压力、CEGUI 二次初始化、PF_RGB/PF_RGBA 独立 harness、特效交替绘制和嵌套裁剪的专门进程内证据。
- 未将 `tools/CEGUI-0.7.1`、WP8 历史工程或 iOS 旧 Cocos 树的独立问题冒充 Win32/Android 主线缺陷；后续治理应另建工具或平台专项报告并保留各自证据树。

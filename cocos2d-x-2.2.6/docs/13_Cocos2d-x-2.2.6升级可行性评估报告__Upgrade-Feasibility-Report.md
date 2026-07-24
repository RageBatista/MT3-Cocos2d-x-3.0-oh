# Cocos2d-x 2.2.6 升级可行性评估报告

> 评估日期: 2026-04-30  
> 评估范围: 将 MT3 当前 `cocos2d-2.0-rc2-x-2.0.1` 基础层升级到官方 `cocos2d-x-2.2.6`  
> 评估角色: Cocos 技术负责人 / 项目总负责人  
> 结论等级: 有条件可行, 高风险, 需要独立立项和分阶段影子迁移  

## 1. 结论摘要

本次升级技术上可行, 但不适合以“直接覆盖旧引擎目录”的方式进入主线。MT3 当前 Cocos2d-x 2.0.1 并非纯官方版本, 已承载渲染、资源、平台生命周期、手势事件、纹理恢复、音频和 Lua 绑定等多处项目定制。官方 2.2.6 虽然仍属于 2.x API 体系, `CC*` 命名和引用计数模型整体延续, 但 MT3 依赖的若干定制 API 在官方 2.2.6 中不存在或行为不同。

建议采用“并行引擎目录 + 兼容层移植 + 分平台门禁 + 可一键回滚”的方案。若目标只是修复当前 2.0.1 的少数崩溃或内存问题, 优先继续在 2.0.1 定向补丁, 不建议立即升级。若目标是建立更接近 2.x 后期版本的长期基线, 支持 iOS 64-bit、Android FPS 控制和 Lollipop 音频修复, 则建议独立立项, 预计 8-12 周完成可投产灰度版本, 前提是投入引擎、渲染、平台、构建和 QA 资源。

## 2. 证据基线

| 项目 | 当前证据 |
| --- | --- |
| 当前 MT3 引擎版本 | `cocos2d-2.0-rc2-x-2.0.1/cocos2dx/cocos2d.cpp` 返回 `cocos2d-2.0-rc2-x-2.0.1`; `COCOS2D_VERSION` 为 `0x00020000` |
| 官方 2.0.1 tag | `bf92165f2060afc184de2ac8651ea438a04eb030` |
| 官方 2.2.6 tag | `1fc007df0ed6f01ef458083504260d0752d19049`; `cocos2dVersion()` 返回 `cocos2d-x 2.2.6`; `COCOS2D_VERSION` 为 `0x00020206` |
| 当前直接 Cocos API 影响面 | `engine`、`client`、`tools/CEGUI-0.7.1`、当前 Cocos 目录中检索 `CCDirector/CCEGLView/CCTextureCache/CCFileUtils/CCNotificationCenter/CCTouchDispatcher/CCRenderTexture/ccGL` 命中 329 个文件 |
| 渲染链锚点 | `probe-render-stack.ps1` 通过, CEGUI Cocos2DRenderer、PFSResourceProvider、GameUIManager、Nuclear renderer 均存在 |
| 平台交接锚点 | `probe-platform-handoff.ps1` 通过, Win32、Android、iOS 壳层仍按预期交给共享 C++ 主链 |
| 当前工具链硬约束 | Windows: `VS2013/v120 + Windows SDK 8.1`; Android: `NDK r10e + Ant + JDK 1.7/1.8 + Python 2.7`; 禁止主线直接改用 Gradle、NDK r11+ 或 v140+ |

## 3. 升级收益

1. iOS 64-bit 支持增强  
   官方 2.2.6 CHANGELOG 明确包含 iOS 64-bit support, 对未来 iOS 设备和工具链兼容有正向价值。但 MT3 自身 C++、ObjC++、第三方 SDK、Lua/tolua 和指针整型转换也必须独立验证, 不能因为 Cocos 支持 64-bit 就视为客户端整体支持。

2. Android 运行稳定性收益  
   2.2.6 包含 Android FPS 控制算法优化和 SimpleAudioEngine 在 Lollipop 上的崩溃修复。对 Android 帧调度、后台恢复和音频播放有潜在收益, 但 MT3 当前 Java/JNI 生命周期是定制版, 需要合并而不是替换官方模板。

3. 渲染和资源模块的历史修复  
   2.2.x 系列包含 `CCClippingNode`、`CCLabelTTF`、`CCTextureAtlas`、`CCConfiguration`、`AssetsManager`、ETC1 等修复或扩展。对部分渲染异常、内存热点和资源下载能力有参考价值。

4. 维护资料相对充足  
   2.2.6 是 2.x 后期版本, 历史社区资料比 MT3 当前 rc2 定制分支更容易检索。但 2.x 已是遗留版本, 不能期待官方继续安全维护。

## 4. API 兼容性评估

### 4.1 兼容性总体判断

2.2.6 仍保留 Cocos2d-x 2.x 的主要对象模型: `CCObject` 引用计数、`autorelease`、`CCNode/CCScene/CCLayer`、`CCDirector`、`CCTextureCache`、`CCRenderTexture`、动作系统和大部分 `CC*` API。因此普通游戏层代码迁移难度低于升级到 3.x 或 4.x。

MT3 的主要风险不在官方 2.x API 基本面, 而在当前 2.0.1 目录内的项目级定制补丁。这些补丁已经被上层业务、CEGUI 渲染器、Nuclear 渲染器和平台壳层依赖, 官方 2.2.6 不提供同等接口。

### 4.2 必须移植的 MT3 定制 API

| 风险点 | 当前 MT3 使用 | 官方 2.2.6 状态 | 影响 |
| --- | --- | --- | --- |
| `CCDirector::pauseRender/resumeRender` | Win32 WebBrowser、视频和后台切换控制渲染暂停 | 官方 2.2.6 未提供同名接口 | 不移植会导致编译失败或窗口/视频叠加时渲染状态异常 |
| `CCDirector::SetBackgroundMode/SetSwapBuffer` | `GameApplication`、`GameUIManager` 和平台后台流程依赖 | 官方 2.2.6 未提供同名接口 | 后台恢复、Android swap buffer 和 Win32 嵌入控件存在崩溃/黑屏风险 |
| `CCEGLViewProtocol` 手势扩展 | `handleLongPress/handleClick/handleDoubleClick/handleSlide/handleDrag` 贯穿 iOS、触摸派发和 EngineLayer | 官方 2.2.6 未提供同名扩展 | 输入链断裂, 长按/双击/滑动/拖拽行为失效 |
| Android `CCEGLView::swapBuffersForAndroid()` | 当前 `CCDirector` 绘制流程调用 | 官方 2.2.6 未提供同名接口 | Android 帧提交和后台恢复行为不一致 |
| `CCTextureCache::reloadAllTextures(CCFileProvidor*)` | `GameApplication.cpp` 通过 `CTextureFileReloader` 从项目资源体系重载纹理 | 官方 2.2.6 只有无参 `reloadAllTextures()` | Android GL context 丢失后无法从 PFS/自定义资源源恢复纹理 |
| `CCTexture2D::getAlphaName()` | Nuclear/CEGUI 绑定 ETC alpha 分离纹理 | 官方 2.2.6 未提供同名接口 | ETC alpha、UI 透明纹理和特效渲染错误 |
| 自定义 shader key | `kCCShader_PositionTextureColorGray/Etc/HSV` 被 Nuclear/CEGUI 使用 | 官方 shader 集不完全一致 | 灰度、HSV、ETC 双纹理渲染路径失效 |
| `CCNotificationCenter` 双位置 | 当前同时存在 `extensions` 和 `support` 相关实现 | 2.2.6 主要走 `support` | 头路径漂移或重复符号风险 |

### 4.3 API 迁移建议

必须先建立 `MT3CocosCompat` 兼容层, 再接入 2.2.6。兼容层职责包括:

- 在 2.2.6 上恢复 MT3 依赖的 `CCDirector` 后台/暂停/swap buffer 行为。
- 保留 `CCEGLViewProtocol` 到 `CCTouchDispatcher`、`EngineLayer` 的手势扩展通道。
- 在 `CCTextureCache` 和 `VolatileTexture` 恢复带 provider 的纹理重载入口, 支持 PFS 和自定义资源源。
- 保留 `CCTexture2D` 的 alpha 分离纹理句柄语义, 并明确生命周期释放规则。
- 注册 MT3 自定义 shader key, 包含 gray、ETC、HSV 等项目 shader。
- 统一 `CCNotificationCenter` include 路径, 避免同名实现重复编译。

兼容层完成前, 不应启动大规模上层业务适配, 否则会出现“编译错误由上层补丁掩盖底层契约缺失”的风险。

## 5. 核心模块重构影响

### 5.1 渲染模块

MT3 的真实渲染链为 Cocos2d-x -> Nuclear -> CEGUI/FireClient UI。当前 Nuclear 和 CEGUI 并非只使用 Cocos 高层 Sprite API, 而是直接调用 `ccGLBindTexture2D`、`ccGLEnableVertexAttribs`、`CCShaderCache`、`CCRenderTexture`、`CCTexture2D` 纹理句柄和 orientation matrix。

主要风险:

- GL state 保存/恢复边界变化会影响 CEGUI 与 Nuclear 绘制顺序。
- `CCRenderTexture` 初始化、清理和 viewport 行为变化会影响 UI texture target、截图、特效离屏渲染。
- `CCTextureAtlas` 热点优化可能改变批量绘制时机, 需要验证 DrawCall、批次拆分和纹理绑定次数。
- 2.2.6 的 shader cache 初始化不包含 MT3 的 gray/HSV/ETC 扩展, 必须移植。
- orientation matrix 和多分辨率适配差异可能导致 Win32/iOS/Android UI 坐标偏移。

结论: 渲染模块是 P0 风险。升级第一阶段只以“能启动并绘制空场景”为成功不充分, 必须覆盖登录首屏、CEGUI 窗口、角色模型、粒子、灰度、ETC alpha、RT UI、地图滚动和多分辨率。

### 5.2 内存管理模块

2.2.6 仍使用 `CCObject` 引用计数和 autorelease pool, 源码模型与 2.0.1 相近。风险集中在以下位置:

- `VolatileTexture` 重载流程变化导致纹理对象持有的数据源不足。
- `CCTextureCache`、`CCSpriteFrameCache`、`CCAnimationCache` purge 时机变化影响跨场景资源释放。
- Win32 不允许跨 CRT 边界分配/释放内存。2.2.6 及其第三方库必须全部用 v120 主线工具链重建, 禁止混用官方预编译库。
- CEGUI `Cocos2DTexture` 持有 `CCTexture2D*` 的释放语义必须复查, 防止二次释放或悬空引用。
- Android GL context 丢失后, 若 provider 式 reload 未恢复, 会出现纹理黑块、崩溃或内存上涨。

结论: 内存管理模型可迁移, 但必须以资源生命周期和纹理恢复为核心验收项, 不能只依赖编译通过。

### 5.3 动画系统

Cocos2d-x 动作系统在 2.x 内部整体兼容, `CCAction`、`CCActionInterval`、`CCAnimation`、`CCAnimate` 等迁移风险中等。MT3 更高风险在 Nuclear 自有动画、Spine、特效和 CEGUI 动画路径:

- 2.2.x 引入或强化 CocoStudio/Armature, 但 MT3 不应直接改用 CocoStudio 运行时替换现有 Nuclear 动画链。
- `extensions/libSpine` 版本和 include 路径需与当前动画资源格式匹配, 不允许盲目升级 runtime。
- Cocos schedule/update 优先级或 action manager 行为差异可能影响粒子和特效播放时序。

结论: Cocos 动作 API 风险中等, 项目动画系统和 Spine 资源兼容风险高于 Cocos 动作系统本身。

## 6. 第三方库与编译环境适配

### 6.1 Windows

当前 MT3 Win32 主线固定 `VS2013/v120 + Windows SDK 8.1`, 构建顺序包含 `libcocos2d`、`libCocosDenshion`、`engine`、`FireClient`、`MT3`。2.2.6 Win32 工程包含 v120/v120_xp 相关配置, 但官方示例工程、WinRT/WP8 工程和 PCH 设置不能直接作为 MT3 主线规则。

适配要求:

- 创建 MT3 专用 2.2.6 Win32 工程配置, 固定 `PlatformToolset=v120`。
- 全量重建 `libcocos2d.lib`、`libCocosDenshion.lib`、`engine.lib`、`FireClient.lib` 和 `MT3.exe`。
- 禁止混用 2.0.1 与 2.2.6 的 `.obj/.lib`。
- 复核 PCH、编码 BOM、第三方 include/lib 路径和 FMOD/OpenAL/MCI 音频实现。

### 6.2 Android

当前 MT3 Android 主线固定 `NDK r10e + Ant + JDK 1.7/1.8 + Python 2.7`, `client/android/LocojoyProject/jni/Android.mk` 明确 `import-add-path` 到当前 `cocos2d-2.0-rc2-x-2.0.1`, `client/FireClient/Android.mk` 直接编译当前 Cocos 目录下的 `extensions/network`、`lua/lua`、`lua/tolua`、`lua/cocos2dx_support` 和 `extensions/libSpine`。

2.2.6 官方源码的 Lua 目录组织转为 `scripting/lua/...`, 不再与 MT3 当前 `lua/...` 路径完全一致。这是 Android 构建的 P0 风险。

适配要求:

- 不切 Gradle, 不切 NDK r11+, 保持 Ant 主线。
- 新增 2.2.6 并行 `import-add-path`, 不覆盖旧目录。
- 重写 `Android.mk` 的 Cocos、Lua、tolua、Spine、extensions 路径映射。
- 合并 2.2.6 Android FPS/Lifecycle 修复到 MT3 定制 `Cocos2dxActivity/Cocos2dxRenderer/JNI` 链路。
- 验证免费服、点卡服、64 位工程和渠道工程的 `libgame.so`、APK 结构、安装和登录链路。

### 6.3 iOS

2.2.6 的 iOS 64-bit 支持是主要收益, 但 MT3 iOS 层有 `FireClientAppDelegate.mm`、`FireClientViewController.mm`、`GameSdk.mm`、WebView、SDK 登录回调和定制手势桥接。

适配要求:

- 先完成 armv7/arm64 双架构编译矩阵。
- 逐项审查 pointer-to-int、long/int、size_t、Objective-C++ block 和 C++ ABI。
- 合并或重建 `EAGLView` 手势扩展, 保持 MT3 输入语义。
- 验证后台进入/恢复、WebView 显示关闭、SDK 登录回调、音频恢复和纹理恢复。

## 7. 项目现有代码与资源改造工作量

| 改造域 | 估算工作量 | 风险等级 | 说明 |
| --- | --- | --- | --- |
| Cocos 2.2.6 并行导入与工程裁剪 | 5-8 人日 | P1 | 需要保留旧目录, 新建 MT3 专用工程/Android.mk 配置 |
| MT3 Cocos 兼容层 | 12-18 人日 | P0 | 移植自定义 API、shader、纹理恢复、手势、后台模式 |
| Nuclear 渲染适配 | 10-15 人日 | P0 | 直接依赖 GL state、shader、纹理句柄和 render texture |
| CEGUI Cocos2DRenderer 适配 | 8-12 人日 | P0 | UI 纹理、异步加载、PFSResourceProvider、RT target、裁剪 |
| Android JNI/Java/Ant 适配 | 8-12 人日 | P0 | 工程路径、生命周期、FPS、音频和渠道差异 |
| iOS 64-bit 与 ObjC++ 适配 | 8-15 人日 | P1 | 依赖第三方 SDK 和 64-bit clean 程度 |
| Win32 v120 构建链适配 | 5-8 人日 | P1 | v120、PCH、编码、第三方库、FMOD |
| Lua/tolua/脚本绑定 | 6-10 人日 | P1 | 路径迁移和生成物边界, 需避免长期手改生成代码 |
| 资源与热更新/PFS 回归 | 8-12 人日 | P0 | 纹理重载、路径解析、writable path、资源包一致性 |
| QA 回归与性能基准 | 15-25 人日 | P0 | 三端启动、登录、入世界、战斗、UI、音频、后台 |

总体估算: 若 3-5 名熟悉引擎、平台和项目资源链的工程师并行推进, 首个可灰度版本约 8-12 周。若只投入单人或缺少 Android/iOS 真机回归, 周期不可控。

## 8. 性能与多平台稳定性对比

### 8.1 性能预期

潜在提升:

- Android FPS 控制算法优化可能降低空转和帧抖动。
- `CCTextureAtlas::updateQuad()` 热点优化可能降低部分批量渲染 CPU 成本。
- 纹理、Label、ClippingNode 等历史修复可能减少局部崩溃和渲染异常。

潜在回退:

- CEGUI 与 Nuclear 的 GL state 若适配不完整, 会导致 shader 切换增加、DrawCall 增多或批次被打断。
- 新旧 texture cache 和 volatile texture 语义不一致可能增加纹理重载耗时和内存峰值。
- Android Java FPS 修复若和 MT3 自定义 render loop 冲突, 可能出现掉帧、黑屏或后台恢复失败。

性能结论: 升级不应被视为必然提速。必须建立同机型、同资源、同场景基准, 至少覆盖 FPS、帧耗时 P95、DrawCall、纹理内存、加载耗时、后台恢复耗时和崩溃率。

### 8.2 稳定性预期

| 平台 | 预期收益 | 主要风险 | 验收重点 |
| --- | --- | --- | --- |
| Win32 | 可吸收部分 Texture/Label/Atlas 修复 | v120 ABI、PCH、FMOD、GL/窗口叠加 | 启动、登录、地图、WebBrowser、视频、音频、资源释放 |
| Android | FPS/Lollipop 音频收益明显 | JNI/Java 生命周期、Ant/NDK 路径、GL context 恢复 | APK 构建、安装、登录 3 次、后台恢复、旋转/锁屏、纹理重载 |
| iOS | 64-bit 支持是主要价值 | ObjC++ 64-bit、EAGLView 手势、SDK/WebView | armv7/arm64、后台恢复、登录回调、WebView、音频和纹理 |

## 9. 社区支持与长期维护成本

2.2.6 是 Cocos2d-x 2.x 的后期版本, 历史资料多, 对 2.0.1 来说更接近稳定维护线。但从 2026 年视角看, 2.x 本身已经是遗留技术栈:

- 官方活跃维护和安全修复有限。
- 旧 Android Ant、NDK r10e、JDK 1.7/1.8 与现代 SDK 生态逐步脱节。
- iOS 现代工具链、隐私权限、64-bit、SDK 签名和第三方 SDK 兼容仍需项目自担。
- 若未来目标是长期技术现代化, 2.2.6 只能作为阶段性稳定基线, 不应被包装成最终现代化方案。

维护结论: 从 2.0.1 升至 2.2.6 有历史债务收敛价值, 但不会消除旧工具链维护成本。项目应保留“后续评估 3.x/4.x 或自研渲染抽象”的长期议题。

## 10. 风险优先级排序

| 优先级 | 风险 | 触发条件 | 处置策略 |
| --- | --- | --- | --- |
| P0 | MT3 定制 Cocos API 丢失 | 直接替换官方 2.2.6 | 先建兼容层, 编译门禁前移 |
| P0 | 渲染链 GL/shader/texture 语义不兼容 | CEGUI/Nuclear 接入新 Cocos | 建立专项渲染基准和像素级回归 |
| P0 | Android 生命周期和纹理恢复失败 | 后台/锁屏/GL context lost | 移植 provider reload 和 MT3 render loop |
| P0 | Lua/tolua 目录和生成链漂移 | Android.mk 指向旧 `lua/...` | 回源生成入口, 重写路径, 禁止长期手改生成物 |
| P0 | 资源/PFS/writable path 行为差异 | 热更资源、压缩纹理、异步加载 | 建立资源加载全链路门禁 |
| P1 | Win32 ABI 混编 | 新旧 `.lib/.obj` 混用 | 强制整链 Rebuild, 产物独立命名 |
| P1 | iOS 64-bit 不完整 | Cocos 支持但项目/SDK 不支持 | 单独做 64-bit clean 审计 |
| P1 | 音频实现差异 | CocosDenshion/FMOD/OpenAL 路径变化 | 保持当前音频后端或逐项替换验证 |
| P1 | 第三方库版本漂移 | curl/libwebsockets/Spine/lua/freetype 等变化 | 锁定版本, 优先移植补丁而不是全量换库 |
| P2 | 社区资料时效性 | 2.x 遗留资料过期 | 文档内标注来源和工程实测结论 |

## 11. 分阶段迁移建议

### Phase 0: 基线冻结与差异盘点

时间: 3-5 人日  
负责人: 项目负责人 + 引擎负责人 + 构建负责人  
目标:

- 打 tag 固化当前 2.0.1 可构建基线和三端产物。
- 归档 Win32、Android、iOS 当前启动、登录、入世界、后台恢复、音频、资源加载和性能基准。
- 生成 MT3 当前 Cocos 定制补丁清单, 区分官方差异、项目补丁和历史产物。
- 明确“不覆盖旧引擎目录、不混用二进制”的硬门禁。

验收:

- Win32 `Build-MT3-Exe-Canonical.ps1` 可复现。
- Android Locojoy APK 可复现。
- 渲染栈和平台交接探针通过。
- 有完整回滚 tag 和产物归档。

### Phase 1: 2.2.6 并行引入与最小构建

时间: 5-8 人日  
负责人: 构建负责人 + 引擎负责人  
目标:

- 新增并行目录, 例如 `cocos2d-x-2.2.6-mt3`, 不覆盖 `cocos2d-2.0-rc2-x-2.0.1`。
- 建立 Win32 v120、Android r10e/Ant 的最小 Cocos 构建。
- 初步裁剪官方示例、WinRT/WP8 等非主线工程, 避免误纳入 MT3 主线。

验收:

- 2.2.6 `libcocos2d` 和 `libCocosDenshion` 可在 MT3 工具链下构建。
- 旧 2.0.1 主线仍可构建。
- 构建配置能显式选择旧引擎或新引擎。

### Phase 2: MT3 兼容层移植

时间: 12-18 人日  
负责人: 引擎负责人  
目标:

- 移植 `CCDirector` 后台/暂停/swap buffer 扩展。
- 移植 `CCEGLViewProtocol` 和触摸/手势扩展。
- 移植 `CCTextureCache(CCFileProvidor*)` 和 `CCTexture2D::getAlphaName()`。
- 移植 MT3 shader key 和 shader 初始化。
- 统一 `CCNotificationCenter` 路径。

验收:

- 上层核心工程不因上述接口缺失而编译失败。
- 兼容层单独有接口清单和回归样例。
- Android GL context 恢复至少能恢复 PFS/自定义资源纹理。

### Phase 3: 渲染链适配

时间: 10-20 人日  
负责人: 渲染负责人 + UI 负责人  
目标:

- 适配 Nuclear `nucocos2d_render.cpp` 对 shader、纹理句柄、RT、GL state 的使用。
- 适配 CEGUI Cocos2DRenderer、TextureTarget、GeometryBuffer、PFSResourceProvider。
- 验证 ETC alpha、灰度、HSV、粒子、特效、UI 裁剪、多分辨率和 RT 窗口。

验收:

- 登录首屏和主界面 UI 无黑块、错位、丢 alpha。
- 常用地图、角色、粒子、战斗特效渲染正常。
- DrawCall、纹理内存、帧耗时不劣化超过基线阈值。

### Phase 4: 平台适配

时间: 10-15 人日  
负责人: Android/iOS/Win32 平台负责人  
目标:

- Android 合并 2.2.6 FPS 和音频修复, 但保留 MT3 定制 Activity/JNI/渠道流程。
- iOS 完成 64-bit clean 审计和 EAGLView 手势桥接。
- Win32 完成 v120、PCH、FMOD、窗口叠加和 WebBrowser/Video 验证。

验收:

- Android APK 结构门禁通过, 真机安装成功。
- Android 登录首屏显示正常, 点击进入游戏连续 3 次无闪退。
- iOS armv7/arm64 构建通过, 后台恢复和 SDK/WebView 正常。
- Win32 Debug/Release 至少一轮完整构建和烟测通过。

### Phase 5: 资源、Lua 与业务回归

时间: 10-15 人日  
负责人: 资源负责人 + Lua/业务负责人 + QA  
目标:

- 适配 Lua/tolua 路径和生成链。
- 验证 PFS、热更新、资源包、图片/字体/音频加载。
- 回归登录、入世界、战斗、背包、商城、聊天、任务、UI 弹窗和脚本事件。

验收:

- 资源缺失率为 0。
- Lua 绑定无新增崩溃和关键错误日志。
- 核心玩法 smoke 用例通过。

### Phase 6: 灰度与投产决策

时间: 2-4 周灰度  
负责人: 项目负责人 + QA + 运维/发布负责人  
目标:

- 小流量灰度新引擎包。
- 监控崩溃率、卡顿、加载失败、后台恢复失败、资源异常和设备分布。
- 根据指标决定扩大灰度、继续修复或回滚。

验收:

- 崩溃率不高于旧基线。
- P95 帧耗时和加载耗时不劣化超过约定阈值。
- 无 P0/P1 未关闭问题。

## 12. 回滚预案

1. 目录级回滚  
   保留 `cocos2d-2.0-rc2-x-2.0.1` 完整可构建目录。2.2.6 使用并行目录, 不覆盖旧目录。

2. 构建配置回滚  
   Win32 include/lib、Android `import-add-path`、iOS 工程引用通过显式变量或分支配置切换。任何阶段发现 P0 问题, 直接切回旧引擎配置。

3. 产物级回滚  
   新旧引擎产物独立命名和归档, 禁止混用 `.obj/.lib/.so`。发布系统保留旧 APK/IPA/Win32 包和资源版本。

4. 分支级回滚  
   升级在独立分支推进。主线只接受已通过阶段门禁的兼容层或低风险补丁, 不接受半成品引擎替换。

5. 触发回滚条件  
   出现以下任一情况立即停止扩大灰度并回滚:
   - 启动、登录、入世界任一 P0 路径崩溃。
   - Android 后台恢复黑屏、纹理大面积丢失或 `SIGSEGV` 增多。
   - iOS 64-bit 真机启动或 SDK 登录不可用。
   - Win32 WebBrowser/视频/窗口切换导致稳定崩溃。
   - 资源热更新、PFS 读取或 Lua 绑定出现批量失败。
   - 崩溃率、卡顿率或加载失败率超过旧基线阈值。

## 13. 最终建议

综合收益、风险和 MT3 当前技术栈约束, 本项目不建议在当前主线直接把 `cocos2d-2.0-rc2-x-2.0.1` 替换为官方 `cocos2d-x-2.2.6`。建议批准“2.2.6 影子迁移专项”, 目标不是简单升级版本号, 而是建立一个带 MT3 兼容层的 2.2.6 项目分支。

若业务版本周期紧张, 当前最优策略是继续对 2.0.1 做精准补丁, 将 2.2.6 的 Android FPS、Lollipop 音频、TextureAtlas 和 iOS 64-bit 相关修复作为可摘取补丁逐项评估。若项目准备投入跨平台技术债治理, 则按本报告 Phase 0-6 执行, 每阶段验收通过后再进入下一阶段。

项目总负责人的批准条件:

- 有独立分支、独立产物和明确回滚开关。
- 有引擎、渲染、Android、iOS、Win32、资源和 QA 责任人。
- 先完成兼容层和渲染链门禁, 再扩大业务回归。
- 不允许新旧 Cocos 二进制混编。
- 不允许用“能编译”替代“能稳定启动、渲染、登录、入世界和后台恢复”。

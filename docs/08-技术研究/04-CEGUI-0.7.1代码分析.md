# CEGUI 0.7.1 代码分析

> **对象**：`dependencies/cegui/` 的客户端当前定制源码。
> **辅助对照**：`tools/CEGUI-0.7.1/` 可用于工具/源码研究，但客户端主线引用仍以 `dependencies/cegui/` 为准。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 顶层结构

| 路径 | 作用 |
| --- | --- |
| `CEGUI/include/` | 核心 API、renderer/image codec/XML/Lua 模块头文件。 |
| `CEGUI/src/` | 核心实现、Falagard、renderer、codec、XML、Lua 和 BinLayout。 |
| `CEGUIResLoadThread.*` / `CEGUILoadingTaskManager.*` | MT3 异步资源工作线程、任务分类、队列和限流缓存。 |
| `CEGUIBase/` | 平台工程的核心编译分组。 |
| `CEGUICocos2DRender/` | Cocos2D renderer 编译分组。 |
| `CEGUIFalagardWRBase/` | Falagard WindowRendererSet 编译分组。 |
| `CEGUILuaScriptModule/` | Lua 脚本模块编译分组。 |
| `CEGUIImageCodec/` / `CEGUIXmlParser/` | 图像和 XML 解析分组。 |
| `project/` / `Android.mk` / `CEGUI.xcodeproj` | Win32、Android、iOS 构建入口。 |

## 2. 核心调用链

```text
GameUIManager
  -> Cocos2DRenderer::bootstrapSystem
  -> CEGUI::System::create
  -> resource groups / SchemeManager
  -> WindowManager::createWindow / loadWindowLayout
  -> Window + Falagard WindowRenderer
  -> Cocos2DGeometryBuffer
  -> Cocos2d-x 2.2.6 render path
```

## 3. Window 与资源

- `Scheme` 加载图像集、字体、LookNFeel 和 FalagardMapping。
- `WindowFactoryManager` 管理具体 Window 工厂和 Falagard 映射。
- `WindowManager::loadWindowLayout()` 支持 name prefix、resource group、property callback 和子布局。
- `Window` 保存几何、属性、事件、子树和 WindowRenderer。
- `Imageset` / `Font` 是画质、显存和前后台恢复的主要资源对象。

### 3.1 Imageset 异步排队

`Imageset_xmlHandler` 创建带文件名的 `Imageset` 时不立即创建纹理。首次进入 [`Imageset::draw()`](../../dependencies/cegui/CEGUI/src/CEGUIImageset.cpp) 后，当前 Cocos2D renderer 分支调用 `createTexture(filename, resourceGroup, dest_rect.d_left, d_SynLoadTexture)`：

1. 相同文件已在 `m_mapLoadingTexture` 时复用正在加载的纹理。
2. 新文件创建 `CLoadFileTask`，把 `dest_rect.d_left` 写入任务浮点优先级并排入 `CCEGUITaskManager`。
3. 文件任务由 `ResourceProvider` 读取原始数据，完成后再排入 `CParseImageTask`。
4. 解析任务调用 `ImageCodec`，随后 `OnImageParsed()` 把结果交给 renderer 的已解析队列。
5. `Cocos2DGeometryBuffer` 发现纹理仍在加载时调用 `CheckLoadingTexture()`，在渲染路径完成纹理数据落地并清除 loading 状态。

## 4. Cocos2D Renderer

`RendererModules/Cocos2D/` 包含：

- `CEGUICocos2DRenderer`：创建、销毁、渲染调度和纹理管理入口。
- `CEGUICocos2DGeometryBuffer`：顶点、纹理、裁剪与 blend 状态的提交单元。
- `CEGUICocos2DTexture`：CEGUI Texture 与 Cocos2d-x 纹理资源的桥接。
- `RenderTarget` / `TextureTarget` / `ViewportTarget`：目标、视口和离屏资源。

## 5. MT3 扩展

| 扩展 | 代码证据 | 影响 |
| --- | --- | --- |
| 运行时 adapter | `CEGUIAdapter.h`、`CEGUISystem.h` | 逻辑尺寸、视口与输入映射。 |
| 二进制布局 | `src/BinLayout/v1/` | Layout 生成、加载和属性序列化的兼容性。 |
| 异步资源调度 | `CEGUIResLoadThread.*`、`CEGUILoadingTaskManager.*`、Cocos2D renderer 任务类 | 文件/解析/字形分阶段处理、限流缓存、优先级与线程生命周期。 |
| 纹理恢复 | `CEGUIImageset.cpp`、`CEGUIImagesetManager.cpp` | Android/iOS 前后台或 GL 恢复。 |
| 异步字形标记 | `CEGUIFont.h` 等 | 字形处理和缓存生命周期。 |
| 业务 Window/Falagard 属性 | WindowRendererSets/Falagard 与 `GameUIManager` 回调 | 提示、链接、文本、物品等 MT3 UI 行为。 |

## 6. 每帧收束与退出

[`GameApplication.cpp`](../../client/FireClient/Application/Framework/GameApplication.cpp) 在每帧 UI 绘制末尾调用 `ImagesetManager::UpdateTextureState()`。该方法的固定顺序是：

1. `CCEGUITaskManager::Update()`：把因全局线程唤醒计数受限而暂存的任务转入正式队列。
2. 遍历全部 Imageset 执行 `UpdateTextureState()`：跟踪未渲染帧数并按阈值释放纹理。
3. renderer `OnFrameEnd()`：处理异步结果重绘、超时任务/纹理回收和字形加载状态。

平台纹理恢复路径调用 `CleanUPTextureState()`，清理未使用纹理、重置 renderer 纹理集合并再次执行 `OnFrameEnd()`。

退出时，`System` 构造函数启动 `CEGUIResLoadThread`；静态 `System::destroy()` 先删除 `System`，再调用 `CEGUIResLoadThread::Destroy()`，后者执行 `StopRunning()`、唤醒信号量、`Join()` 并删除线程。工作线程检测停止后销毁 `CCEGUITaskManager`。这套先后关系和剩余任务处置必须在迁移或重构时单独验证。

## 7. 风险边界

- 更换官方 CEGUI 库会同时影响自定义 API、renderer、BinLayout、Falagard、Lua 绑定和三端构建。
- CEGUI 0.7.9 迁移必须覆盖 `CEGUIResLoadThread`、`CCEGUITaskManager`、Imageset 懒加载、文件/解析分阶段、render 线程纹理落地、每帧 pump 和退出时任务所有权；只替换头文件/库会丢失这条链。
- 修改 `Window`、`System`、renderer 公共头文件时需评估 CEGUI -> engine -> FireClient -> 三端壳层重编。
- BinLayout 变更需要 XML/BIN 往返、历史样本和客户端加载回归。

## 8. 阅读顺序

1. `CEGUIVersion.h`、`CEGUISystem.*`、`CEGUIWindowManager.*`。
2. `CEGUIScheme*`、`CEGUIWindowFactoryManager*`、Falagard 实现。
3. `CEGUIResLoadThread.*`、`CEGUILoadingTaskManager.*`。
4. `RendererModules/Cocos2D/`。
5. `CEGUIImageset*`、`CEGUIFont*`、resource provider。
6. `BinLayout/v1/`、LuaScriptModule 和 MT3 业务扩展。
7. `GameUIManager.cpp` 与 `GameApplication.cpp` 中的客户端集成和每帧收束。

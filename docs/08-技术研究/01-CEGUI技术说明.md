# CEGUI 技术说明

> **当前实现（Win32）**：`tools/CEGUI-0.7.9-r5/` 中的 CEGUI 0.7.9-r5 Cocos2D Renderer。
> **兼容实现（Android/iOS）**：`dependencies/cegui/` 中的 MT3 定制 CEGUI 0.7.1。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 版本与角色

Win32 版本由 [`tools/CEGUI-0.7.9-r5/cegui/include/CEGUIVersion.h`](../../tools/CEGUI-0.7.9-r5/cegui/include/CEGUIVersion.h) 定义为 `0.7.9`，通过 Cocos2D Renderer 与 `cocos2d-x-3.0-oh`/Nuclear 结合；Android/iOS 仍读取 `dependencies/cegui/` 的 0.7.1 兼容实现。

| 目录 | 角色 |
| --- | --- |
| `dependencies/cegui/` | 客户端当前 CEGUI 源码、头文件、平台工程和产物输入。 |
| `tools/CEGUI-0.7.1/` | 0.7.1 配套源码/工具研究副本。 |
| `tools/CEGUI-0.7.1-bulid/` | 历史预构建库/DLL 和产物对照资产。 |
| `tools/CEGUI-0.7.9-r5/` | 0.7.9 文档、库、DLL、对象和工程研究样本；未进入客户端主线。 |

## 2. 核心组件

| 组件 | 当前实现位置 | 职责 |
| --- | --- | --- |
| `System` | `CEGUISystem.*` | CEGUI 核心对象、输入注入、渲染与 GUISheet。 |
| `WindowManager` | `CEGUIWindowManager.*` | Window 创建/销毁、Layout 加载和子布局。 |
| `SchemeManager` / `WidgetLookManager` | `CEGUIScheme*`、LookNFeel/Falagard 实现 | 窗口类型、外观和 renderer 映射。 |
| `ImagesetManager` / `FontManager` | `CEGUIImageset*`、`CEGUIFont*` | 图像集、纹理状态和字形。 |
| `CEGUIResLoadThread` | `CEGUIResLoadThread.*` | 常驻资源工作线程，等待信号量并执行异步文件、解析和字形任务。 |
| `CCEGUITaskManager` | `CEGUILoadingTaskManager.*` | 管理文件、图像解析、字形和限流缓存队列；类名不是 `CEGUILoadingTaskManager`。 |
| `Cocos2DRenderer` | `RendererModules/Cocos2D/` | 将 CEGUI GeometryBuffer/纹理/视口接入 Cocos2d-x 2.2.6。 |
| `LuaScriptModule` | `ScriptingModules/LuaScriptModule/` | Lua 事件和 Window API 绑定。 |
| `BinLayout` | `CEGUI/src/BinLayout/v1/` | MT3 定制的二进制布局序列化/加载。 |
| `IAdapter` | `CEGUIAdapter.h` | 与 `ResolutionAdapter` 交换逻辑尺寸和显示参数。 |

## 3. 资源链

```text
Scheme
  -> FalagardMapping
  -> LookNFeel / WidgetLook
  -> Imageset / Font
  -> Layout
  -> Lua/C++ Window path
  -> Event handler
```

当前客户端资源真源位于 `client/resource/res/ui/` 和 `client/resource/res/script/`。Android `assets/res/**` 是打包生成物，不作为业务修改入口。

## 4. MT3 定制点

当前源码可验证的定制包括：

- Cocos2D Renderer 和 Cocos2D ImageCodec。
- `CEGUI::IAdapter` 与运行时分辨率适配。
- `BinLayout/v1` 二进制布局支持。
- `CEGUIResLoadThread` + `CCEGUITaskManager` 异步资源任务链。
- Imageset 纹理状态更新/清理，用于平台恢复。
- Font 异步字形处理字段与相关逻辑。
- Window、Falagard renderer 和业务提示/链接的项目扩展。

这些定制使“直接替换为官方 0.7.9 库”不具备等价性。

## 5. 运行时初始化

[`GameUIManager.cpp`](../../client/FireClient/Application/Manager/GameUIManager.cpp) 的关键步骤：

1. `Cocos2DRenderer::bootstrapSystem()` 创建 renderer。
2. 根据打包形态选择 `PFSResourceProvider` 或 `DefaultResourceProvider`。
3. 创建 `LuaScriptModule`。
4. `CEGUI::System::create()` 建立系统和日志。
5. 设置 `ResolutionAdapter`、资源组、Scheme、默认字体/光标/提示和业务回调。
6. 创建 `root_wnd` 并设置为 GUISheet。

## 6. 异步资源加载与帧末收束

当前异步链不是官方 0.7.1 默认能力的简单调用，而是 MT3 定制的一组线程、队列、Imageset 懒加载和 renderer 收束逻辑：

```text
CEGUI::System 构造
  -> CEGUIResLoadThread::GetPtr()->Start()

Imageset XML 创建对象（只保存文件名，纹理为空）
  -> 首次 draw() 调用 Cocos2DRenderer::createTexture()
  -> QueueTask(CLoadFileTask, priority = dest_rect.left)
  -> 工作线程读取原始文件
  -> OnFileLoaded() 再排入 CParseImageTask
  -> 工作线程经 ImageCodec 解析
  -> OnImageParsed() 放入 renderer 已解析队列
  -> GeometryBuffer 渲染时 CheckLoadingTexture() 完成纹理落地

GameApplication 每帧 UI 绘制后
  -> ImagesetManager::UpdateTextureState()
  -> CCEGUITaskManager::Update() 释放限流缓存任务
  -> 各 Imageset 更新未使用纹理状态
  -> Renderer::OnFrameEnd() 失效窗口、回收超时任务/纹理并收束字形加载状态
```

源码锚点：

- [`CEGUISystem.cpp`](../../dependencies/cegui/CEGUI/src/CEGUISystem.cpp)：`System` 构造时启动线程；`System::destroy()` 删除系统后调用线程 `Destroy()`。
- [`CEGUIResLoadThread.cpp`](../../dependencies/cegui/CEGUI/src/CEGUIResLoadThread.cpp)：信号量等待、工作线程取任务，以及 `StopRunning -> fire -> Join -> delete` 销毁流程。
- [`CEGUILoadingTaskManager.cpp`](../../dependencies/cegui/CEGUI/src/CEGUILoadingTaskManager.cpp)：文件优先级队列、解析/字形队列、限流缓存和 `Update()`。
- [`CEGUIImagesetManager.cpp`](../../dependencies/cegui/CEGUI/src/CEGUIImagesetManager.cpp)：每帧先刷新缓存任务，再更新 Imageset，最后调用 renderer `OnFrameEnd()`。

`QueueTask()` 在全局线程唤醒计数超过阈值时先放入 `m_vCacheTasks`；每帧 `Update()` 在计数恢复后再转入正式队列。工作线程取任务时优先处理字形，其次解析，最后处理 `m_mapFileTasks` 中浮点优先级最小的一组文件任务。

### 6.1 CEGUI 0.7.9 迁移约束

评估 0.7.9 时必须把上述链作为迁移清单，而不是只比较公开 API：

1. 明确保留或重做资源线程的启动、停止、唤醒、Join 和未完成任务所有权。
2. 保留文件读取 -> 图像解析 -> render 线程纹理落地的阶段边界，避免在工作线程直接操作渲染资源。
3. 保留 Imageset 首次绘制排队、同文件去重、优先级、限流缓存和字形任务语义。
4. 提供等价的每帧 pump 与 `OnFrameEnd()` 收束点，覆盖重绘、超时回收、字体加载状态和纹理自动释放。
5. 单独审计当前“先删除 `System`、再停止并 Join 资源线程”的销毁顺序；新实现必须证明退出时不会让残留任务访问已销毁的 CEGUI singleton。

缺少任一项都不能将官方 0.7.9 二进制视为当前定制 0.7.1 的等价替换。

## 7. 文档导航

- 画质和性能：[02-CEGUI画质与性能优化](02-CEGUI画质与性能优化.md)
- 0.7.1 源码：[04-CEGUI-0.7.1代码分析](04-CEGUI-0.7.1代码分析.md)
- 0.7.9 研究：[05-CEGUI-0.7.9可行性研究](05-CEGUI-0.7.9可行性研究.md)
- 渲染集成：[06-CEGUI与Cocos2d-x集成](06-CEGUI与Cocos2d-x集成.md)
- 资源集成：[07-CEGUI集成指南](07-CEGUI集成指南.md)
- 目录/产物关系：[08-CEGUI架构关系](08-CEGUI架构关系.md)

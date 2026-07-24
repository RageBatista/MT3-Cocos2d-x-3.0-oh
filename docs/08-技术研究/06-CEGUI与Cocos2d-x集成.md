# CEGUI 与 Cocos2d-x 集成

> **当前组合**：MT3 定制 CEGUI 0.7.1 + Cocos2d-x 2.2.6 + Nuclear + FireClient。
> **事实源**：`dependencies/cegui/CEGUI/src/RendererModules/Cocos2D/`、`GameUIManager.cpp`、`ResolutionAdapter.cpp`。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 分层边界

```text
平台壳层
  -> Cocos2d-x 2.2.6 (GL、纹理、输入、平台)
  -> Nuclear (场景、精灵、动画、特效)
  -> CEGUI 0.7.1 Cocos2DRenderer (UI 几何与纹理桥接)
  -> FireClient GameUIManager / Lua Dialog
```

CEGUI 不直接管理平台窗口；`Cocos2DRenderer` 将 CEGUI 的 renderer 接口映射到当前 Cocos2d-x 图形资源和 GL 状态。

## 2. 初始化

[`GameUIManager.cpp`](../../client/FireClient/Application/Manager/GameUIManager.cpp) 当前执行：

1. `CEGUI::Cocos2DRenderer::bootstrapSystem()`。
2. 创建 PFS 或默认 resource provider。
3. 创建 `CEGUI::LuaScriptModule`。
4. `CEGUI::System::create()`。
5. `System::SetAdapter(&g_adapter)` 并通知逻辑显示尺寸。
6. 设置 imagesets/fonts/schemes/looknfeel/layouts/scripts/animations 资源组。
7. 加载 `taharezlook.scheme`、默认光标、字体和 MT3 业务回调。
8. 创建 `root_wnd` 并 `setGUISheet()`。

## 3. 渲染链

```text
CEGUI Window/Falagard
  -> cache/render geometry
  -> Cocos2DGeometryBuffer
  -> Cocos2DTexture / RenderTarget / ViewportTarget
  -> Cocos2d-x 2.2.6 GL state and texture resources
```

修改 renderer 时必须保持：

- CEGUI 提交顺序、裁剪、blend 与纹理绑定语义。
- UI 渲染前后 Cocos2d-x/Nuclear GL 状态不被污染。
- `ResolutionAdapter` 的 logic/display 尺寸与输入映射一致。
- 纹理生命周期和 GL 上下文重建后可恢复。

## 4. 输入链

```text
平台鼠标/触摸/键盘
  -> Cocos2d-x / 平台壳坐标
  -> ResolutionAdapter display rectangle / safe inset
  -> CEGUI::System injectMouse* / injectChar / injectKey*
  -> Window target / subscribed event
  -> FireClient / Lua handler
```

显示正常但点击偏移时，先对照显示与输入是否共用同一 viewport profile，再检查 layout 坐标。

## 5. 资源链

CEGUI 资源从 resource provider 加载，并按 `Scheme -> FalagardMapping -> LookNFeel -> Imageset/Font -> Layout` 注册。PFS 包内路径和 Win32 松散资源路径都必须保持同一逻辑资源名。

## 6. 前后台与销毁

- Android/iOS 恢复 GL 后，重载 Cocos2d-x 资源并更新 CEGUI Imageset 纹理状态。
- CEGUI 销毁时先清理 Window/Dialog，再销毁 `System`、LuaScriptModule、renderer 和 resource provider。
- 重建时避免旧 Window 指针、Lua 引用和事件订阅留存。

## 7. 验证

1. 冷启动无 CEGUI 资源首错。
2. 鼠标/触摸/文本输入在多种视口比例下命中正确。
3. 切场景、切账号、大型面板、战斗 UI 和提示层顺序正确。
4. Android/iOS 前后台后无黑图、白图、字体缺失或事件重复。
5. 性能对比同时记录 CPU、draw call、纹理切换和内存。

## 8. 相关文档

- [CEGUI 集成指南](07-CEGUI集成指南.md)
- [CEGUI 架构关系](08-CEGUI架构关系.md)
- [跨平台 UI 交互](../02-技术架构/专题/05-跨平台UI交互.md)

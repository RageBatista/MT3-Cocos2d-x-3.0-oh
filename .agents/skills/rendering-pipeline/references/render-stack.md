# 渲染栈参考

## 主渲染链

当前仓库的共享渲染链可按职责理解为：

1. 平台层提供窗口、输入和设备上下文
2. Cocos2d-x 提供基础渲染、纹理与平台适配
3. Nuclear 提供场景、精灵、动画、特效等中间层能力
4. FireClient 在 `Application/GameUI` 等目录承接业务 UI 与表现逻辑

## CEGUI 关键锚点

- `tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp`
- `tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp`
- `docs/08-技术研究/07-CEGUI集成指南.md`

重点事实：

- 使用自定义 `Cocos2DRenderer`
- 布局与资源读取依赖二进制布局序列化和资源提供器
- UI 贴图与部分资源链路可能经由异步纹理加载

## 常见子域

- UI 布局和窗口生命周期
- 输入到控件事件分发
- 场景对象、精灵、动作、特效表现
- 资源提供器、贴图加载、PFS 路径
- 批量渲染、裁剪和顺序问题

## 边界

- 若资源本身找不到、版本包不一致或 PFS 挂载异常，先联动 `resource-packaging-pipeline`
- 若问题还停在 Android/iOS 输入桥接、平台视图或 WebView 遮挡，联动 `platform-bridge`
- 若问题属于共享业务流程未触发 UI 状态切换，联动 `application-core-flow`

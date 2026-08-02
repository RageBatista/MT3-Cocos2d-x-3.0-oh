# Android 与 Windows 客户端 UI 显示分析

> **当前基线**：Windows 为 Cocos2d-x 3.0-oh + Nuclear + CEGUI 0.7.9-r5 + FireClient/Lua；Android 仍为 Cocos2d-x 2.2.6 + CEGUI 0.7.1 兼容链。
> **事实源**：`ResolutionAdapter`、`RuntimeViewportCalculator`、Win32/Android 平台壳和 `GameUIManager`。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 共享与差异

| 维度 | Android | Windows |
| --- | --- | --- |
| 平台容器 | Activity/GLSurfaceView/Renderer + JNI | Win32 窗口 + CCEGLView |
| 物理尺寸来源 | Java/GL 创建的 viewport | Win32 frame size，失败时回退 GL viewport |
| UI 目标基线 | 1080x720 | 默认 1280x720，可由 `frameResolutionSize.txt` 覆盖 |
| UI 缩放上限 | 2.0 | 1.3 |
| 输入 | 触摸/软键盘/平台控件 | 鼠标/键盘/窗口消息 |
| 前后台 | GL 资源恢复和纹理重载是关键路径 | 窗口活动、尺寸变化和 DPI 是关键路径 |
| 共享 UI | CEGUI 0.7.1 + `GameUIManager` + Lua Layout/Dialog | 同一套共享实现 |

## 2. 视口模型

`ResolutionAdapter` 读取物理视口，使用 `RuntimeViewportCalculator` 计算：

- scene logic size
- UI logic size
- display rectangle
- safe inset
- UI scale

CEGUI 和 Nuclear 从同一 adapter 获取参数，因此显示与输入映射必须使用同一 profile。

## 3. Android 关键点

1. `nativeInit(w, h)` 设置 CCEGLView frame size，首次启动调用 `gRunGameApplication()`。
2. 当前 scene/UI 基线都为 1080x720，这是源码常量，不是从截图反推。
3. 前台恢复可重载默认 shader 与纹理，需同时验证 CEGUI Imageset 状态。
4. 导航栏、刘海、圆角和软键盘需通过 safe inset/平台容器处理，不用全量布局硬编码补偿。

## 4. Windows 关键点

1. Win32 当前优先读取 CCEGLView frame size，不只依赖 OpenGL viewport。
2. `frameResolutionSize.txt` 可分别覆盖 render、UI 和 scene render 目标尺寸，排障时需确认工作目录与文件内容。
3. Win32 可导出 `MT3.runtime-profile.json` 用于编辑器 WYSIWYG 对照。
4. DPI 感知、窗口缩放与 OS 虚拟化必须分开取证。

## 5. 常见问题定位

| 现象 | 证据 |
| --- | --- |
| 面板比例不一致 | screen/target/logic/display/uiScale 和真实 layout 数值。 |
| 控件点击偏移 | 输入坐标是否使用同一 display rectangle/safe inset。 |
| Android 恢复后白图/黑图 | GL context、shader、Cocos2DTexture 和 Imageset 更新日志。 |
| Windows 高 DPI 模糊 | OS DPI 缩放、frame size、render target、UI logic size 和资源密度。 |
| 文字模糊 | Font 字形、字号、UI 缩放和像素对齐。 |

## 6. 验证

- Android：至少覆盖主流长宽比、前后台、软键盘、切场景和纹理重载。
- Windows：覆盖窗口尺寸、全屏/窗口、DPI 缩放、`frameResolutionSize.txt` 有无两种状态。
- 两端都保存 runtime profile、截图、UI 日志和输入命中记录。

## 7. 相关文档

- [Android 客户端 UI 显示比例](../02-技术架构/专题/06-Android客户端UI显示比例.md)
- [跨平台 UI 交互](../02-技术架构/专题/05-跨平台UI交互.md)
- [客户端界面清晰度与高分屏适配](11-客户端界面清晰度与高分屏适配.md)

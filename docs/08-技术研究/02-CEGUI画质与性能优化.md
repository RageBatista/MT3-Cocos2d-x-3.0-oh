# CEGUI 画质与性能优化

> **对象**：当前 MT3 定制 CEGUI 0.7.1 + Cocos2d-x 2.2.6 Renderer。
> **边界**：本页区分已实现机制、可配置调整和需要代码实验的研究方案。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 先分层定位

| 现象 | 首查层 |
| --- | --- |
| 文字模糊/错位 | Font 字形、逻辑尺寸、缩放和像素对齐。 |
| 图标/边框模糊 | Imageset 原图密度、采样方式、九宫格和缩放比。 |
| 控件不显示 | Scheme -> LookNFeel -> Imageset/Font -> Layout 资源链，不先归因为画质。 |
| 帧率降低 | Window 数、GeometryBuffer、纹理切换、裁剪、Lua 每帧逻辑。 |
| 前后台恢复后黑块 | Imageset/Cocos2DTexture 的纹理状态更新与清理。 |

## 2. 已实现机制

- `Cocos2DRenderer` / `Cocos2DGeometryBuffer` 接管 CEGUI 几何提交。
- `ResolutionAdapter` 为 CEGUI 提供逻辑尺寸，Android 当前基线 1080x720，`maxUiScale=2.0`。
- `Imageset::UpdateTextureState()` / `cleanUpTextureState()` 与 Manager 级聚合函数处理纹理恢复。
- CEGUI Window/Falagard 使用缓存的 geometry 和属性驱动渲染。
- CEGUI 日志在 `GameUIManager` 初始化时配置，可用于找资源和 Window 首个 blocker。

## 3. 低风险优化

1. 先减少无效 Window 更新、重复订阅和每帧 Lua 全树扫描。
2. 关闭不可见容器的动画/计时器，而不只是将 alpha 设为 0。
3. 合并频繁变动的文本/进度刷新，使用脏标记。
4. 减少同一面板内不必要的 Imageset/纹理切换。
5. 保持小图标和 1px 线条在整像素边界，避免纯布局引入的半像素模糊。

## 4. 字体与高分屏

- 将“字体原图模糊”、“二次缩放”、“字号不合理”和“边缘颜色/背景混合”分开取证。
- 同一字体资产在不同 `uiScale` 下的清晰度需用截图和 glyph cache 指标对照。
- 字体资源方案、DPI 感知和倍率资源属于研究路线，未经三端实验不写成现行能力。

## 5. 需要实验的中高风险方案

| 方案 | 风险 | 必要证据 |
| --- | --- | --- |
| 改变纹理采样/过滤 | 图标和文字可变模糊，场景/UI 策略可互相污染 | 分层截图、GPU 状态和帧时。 |
| 深度合并 GeometryBuffer | 裁剪、层级、blend 或纹理不同时不可合并 | draw/texture/scissor 序列和像素对比。 |
| 改写 glyph cache | 异步、内存、字符集和前后台恢复风险 | 字符覆盖、显存/内存、重建和缺字回归。 |
| 更换 CEGUI 版本 | MT3 定制 API、BinLayout、renderer 和 Lua 绑定不兼容 | 定制补丁清单、编译、资源和三端回归。 |

## 6. 度量方法

| 维度 | 建议指标 |
| --- | --- |
| CPU | UI update 耗时、Lua 回调次数、Window 更新数。 |
| GPU | UI draw call、纹理切换、scissor 切换、overdraw。 |
| 内存 | Imageset 纹理、glyph cache、窗口数、前后台前后差值。 |
| 画质 | 1:1 截图、高对比边缘、小字、斜线、缩放和动画帧。 |
| 稳定性 | 切场景、切账号、前后台、重载纹理、销毁重建。 |

## 7. 相关文档

- [Android 与 Windows 客户端 UI 显示分析](03-Android与Windows客户端UI显示分析.md)
- [客户端界面清晰度与高分屏适配](11-客户端界面清晰度与高分屏适配.md)
- [Android 客户端 UI 显示比例](../02-技术架构/专题/06-Android客户端UI显示比例.md)

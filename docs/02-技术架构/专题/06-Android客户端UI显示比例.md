# Android 客户端 UI 显示比例

> **定位**：区分当前 `ResolutionAdapter` 实现与截图比例/布局建议。
> **当前事实**：Android 场景与 UI 目标基线为 1080x720，`c_max_ui_scale=2.00f`。
> **实现路径**：`client/FireClient/Application/Framework/ResolutionAdapter.cpp` 与 `common/platform/RuntimeViewportCalculator.h`。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../../07-参考文档/02-文档索引.md)

## 1. 当前源码事实

[`ResolutionAdapter.cpp`](../../../client/FireClient/Application/Framework/ResolutionAdapter.cpp) 当前定义（以下为 Android 分支的等效汇总，非逐字源码：源码中 `c_max_ui_scale` 位于 `#if defined(ANDROID)/#else` 块，四个尺寸常量位于 `#ifdef WIN32/#elif defined(ANDROID)/...` 块，见 ResolutionAdapter.cpp:25-53）：

```cpp
// Android 分支等效值
static const float c_max_ui_scale = 2.00f;   // 非 Android 分支为 1.30f
static const int c_render_width = 1080;
static const int c_render_height = 720;
static const int c_ui_width = 1080;
static const int c_ui_height = 720;
```

同一实现中：

- 物理屏幕宽高来自 OpenGL viewport。
- `ComputeRuntimeViewportProfile()` 计算 UI 逻辑尺寸、显示区域和 `uiScale`。
- `ComputeRuntimeLogicSize()` 计算场景/渲染逻辑尺寸。
- `ResolutionAdapter` 同时实现 `CEGUI::IAdapter` 和 `Nuclear::iadapter`，是 UI 与场景共享视口参数的关键桥接。

## 2. 坐标与尺寸模型

| 尺寸 | 含义 |
| --- | --- |
| `screenWidth/screenHeight` | GL viewport 报告的物理视口。 |
| `targetWidth/targetHeight` | Android 当前使用的 1080x720 目标基线。 |
| `logicWidth/logicHeight` | 经长宽比和缩放计算后交给 UI/场景的逻辑尺寸。 |
| `displayX/Y/W/H` | 逻辑内容在物理视口中的显示区域。 |
| `safeInset` | 安全区域留白，需与输入映射使用同一份 profile。 |
| `uiScale` | UI 缩放值，Android 上限当前为 2.0。 |

## 3. 计算主链

```text
Android GLSurfaceView 物理尺寸
  -> nativeInit(w, h)
  -> CCEGLView::setFrameSize(w, h)
  -> ResolutionAdapter::init()
  -> glGetIntegerv(GL_VIEWPORT)
  -> ComputeRuntimeViewportProfile(1080, 720, maxUiScale=2.0)
  -> CEGUI / Nuclear adapter getters
  -> Layout + Lua 使用 GUISheet 逻辑尺寸
```

Android JNI 入口可见 [`client/android/common/jni/main.cpp`](../../../client/android/common/jni/main.cpp)。

## 4. 截图比例的证据边界

人物属性、背包、排行榜等截图可用于提取宏观外框、留白和层级比例，但属于研究/验收参考，不能反向宣称为当前运行时算法。

截图测量使用以下口径：

1. 记录原始截图像素宽高、导航栏/刘海/安全区域。
2. 只将外框宽高、边距和主次区域转换为百分比。
3. 内部按钮和文本仍以真实 `.layout`、Imageset 和 Font 为准。
4. 不将单一设备的 dp/density 推算写成全局常量。

## 5. 布局建议（研究）

- 优先使用 CEGUI 相对尺寸表达外框与安全区域。
- 固定像素只用于边框、图标和已有美术资产的必要尺寸。
- 新增屏幕比例适配时，先在 `RuntimeViewportCalculator` 与 `ResolutionAdapter` 形成统一 profile，再调整个别布局。
- 不通过全量修改 Lua 坐标或批量改 `.layout` 弥补输入/视口计算错误。

## 6. 验证矩阵

| 维度 | 至少覆盖 |
| --- | --- |
| 屏幕比例 | 16:9、16:10、18:9、19.5:9、4:3 或当前设备群的代表值。 |
| 方向 | 横屏首启、前后台恢复、GL 上下文重建。 |
| 显示 | 主界面、大型面板、弹窗、提示、战斗 UI、聊天/输入。 |
| 输入 | 中心、四角、安全区边缘和滚动/拖拽的触摸命中。 |
| 日志 | 记录 screen/target/logic/display/safeInset/uiScale，不仅记录最终窗口宽高。 |

## 7. 相关研究

- [Android 与 Windows 客户端 UI 显示分析](../../08-技术研究/03-Android与Windows客户端UI显示分析.md)
- [客户端界面清晰度与高分屏适配](../../08-技术研究/11-客户端界面清晰度与高分屏适配.md)
- [CEGUI 画质与性能优化](../../08-技术研究/02-CEGUI画质与性能优化.md)

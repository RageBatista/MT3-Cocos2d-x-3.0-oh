# CEImagesetEditor 技术手册

> **对象**：`tools/CEImagesetEditor-0.7.1/`。
> **职责**：本页说明功能、架构、数据和使用；构建命令只见 [CEImagesetEditor 编译构建](../06-工具链/07-CEImagesetEditor编译构建.md)。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 功能边界

CEImagesetEditor 用于维护 CEGUI `.imageset` 与原始图片之间的 region 关系，当前源码可见：

- 新建/打开/保存 Imageset 文档。
- region 添加、删除、改名、移动和缩放。
- 批量改名、批量生成和 region 导出。
- 基于 alpha/连通域的自动 region 检测。
- 资源组、原始分辨率和 AutoScaled 属性编辑。
- 撤销/重做、缩放/平移、设置持久化。
- LookNFeel 浏览器与相关资源检视。

## 2. 架构

```text
CEImagesetEditor (wxApp)
  -> EditorFrame / EditorView
  -> EditorDocument / EditorDocManager
  -> EditorGLCanvas
       -> InputRouter
       -> InteractionController
       -> ViewportController
       -> RenderScheduler
  -> EditorCommand / EditorCommandHistory
  -> AutoRegionDetector / AsyncTextureLoader / ExportService
  -> Dialog* tools
```

| 模块 | 职责 |
| --- | --- |
| `EditorDocument` | Imageset 名、图片文件、region、native resolution、auto scaled 和 dirty 状态。 |
| `EditorDocManager` | 多文档/文件生命周期和打开保存协调。 |
| `EditorGLCanvas` 及拆分 controller | 渲染、输入路由、缩放/平移和 region 交互。 |
| `EditorCommandHistory` | 命令执行、撤销和重做。 |
| `AutoRegionDetector` | alpha 提取、二值化、形态学、连通域、包围盒、合并、过滤和命名。 |
| `AsyncTextureLoader` | 工作线程、任务取消和完成事件。 |

## 3. Imageset 数据

工具最终维护的核心信息：

| 字段 | 含义 |
| --- | --- |
| Imageset name | CEGUI 资源名，Scheme/LookNFeel/Layout 引用它。 |
| Imagefile | 原始纹理路径。 |
| NativeHorzRes / NativeVertRes | 原始设计分辨率。 |
| AutoScaled | CEGUI 自动缩放标记。 |
| Image region | name + x/y/width/height，可另含项目定制属性。 |

修改 region 名会影响 LookNFeel、Layout、Lua/C++ 字符串引用，必须全仓检索。

## 4. 常见操作

### 打开与对齐

1. 打开 `.imageset`，确认 Imagefile 可解析。
2. 在 1:1 视图检查 region 边界，再使用缩放/适应窗口辅助观察。
3. 修改 region 后保存，检查 XML 差异只包含预期变更。

### 自动检测

1. 根据图片透明边缘设置阈值、最小区域、合并距离和形态学参数。
2. 预览包围盒，人工排除阴影、粒子和边缘噪声。
3. 应用后使用命名规则与批量改名工具收敛资源名。

### 导出

导出 region 图像时保留输出目录、透明通道、命名冲突和失败记录；导出图不自动替代 Imageset 真源。

## 5. 验证

1. 工具内往返：打开 -> 修改 -> 保存 -> 重新打开。
2. XML 校验：Imageset 名、Imagefile、分辨率、AutoScaled 和 region 尺寸。
3. 引用校验：Scheme/LookNFeel/Layout/Lua/C++ 中的资源名。
4. 客户端冷启动：图片正常、无 XML/region 首错、无紫块/空白。
5. Android/iOS 前后台后纹理恢复正常。

## 6. 变更边界

- 不将工具自包含 CEGUI 库替换客户端 `dependencies/cegui/`。
- 不修改 Android `assets/res/**` 生成物；先修改 `client/resource/res/**` 并重打包。
- 不将自动检测结果无审核批量写入生产 Imageset。

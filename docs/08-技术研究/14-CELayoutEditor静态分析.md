# CELayoutEditor 静态分析

> **分析对象**：`tools/CELayoutEditor/`（旧文档中的 `\tools/CELayoutEditor` 路径笔误已修正）。
> **工作树边界**：当前可直接读取的代码主要是 `inc/EditorExtensionManager.h`、`EditorExtensionCommandRouter.h`、`FileSearchUtils.h`；其余主要为产物、资源、脚本与阶段性文档。
> **当前 CEGUI 基线**：Win32 游戏客户端为 CEGUI 0.7.9-r5；CELayoutEditor 等旧工具仍按其自带/共享的 0.7.1 兼容 ABI 维护。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 实物盘点

| 路径 | 当前角色 |
| --- | --- |
| `bin/` | 运行时产物/依赖。 |
| `datafiles/` | 工具数据与字体资源。 |
| `docs/` | 资源生命周期、构建审计、崩溃复盘、WYSIWYG 方案和风险清单。 |
| `inc/` | 当前保留的扩展管理/路由与文件搜索头文件。 |
| `scripts/` | WYSIWYG 运行时预览和稳定性测试脚本。 |
| `vc++12/` | Debug/Release 中间/产物与历史 VS 状态文件；当前没有可直接核对的完整 `.vcxproj`/source 集。 |

因此，旧深度报告中的完整类、函数、行号和调用链应视为当时的静态研究，不能全部声称已被当前工作树重新验证。

## 2. 可验证的扩展边界

### `EditorExtensionManager`

头文件表明工具有扩展注册与生命周期管理边界。维护重点：

- 扩展加载/卸载顺序。
- 重复注册和悬空引用。
- 文档/视图销毁时扩展资源清理。

### `EditorExtensionCommandRouter`

用于将编辑命令路由到扩展处理。维护重点：

- command ID 冲突。
- 命令可用/禁用状态。
- 路由失败后的回退和日志。

### `FileSearchUtils`

用于布局和资源文件搜索。维护重点：

- 搜索根、相对路径、大小写和重名文件的决策。
- Win32 路径与 CEGUI resource group 路径的转换。
- 文件存在不等于对应 Scheme/LookNFeel/Imageset 已注册。

## 3. 资源加载模型

CELayoutEditor 需要重建客户端 CEGUI 资源环境：

```text
resource roots
  -> Scheme
  -> LookNFeel / FalagardMapping
  -> Imageset / Font
  -> Layout
  -> preview Window tree
```

工具启动/打开 Layout 崩溃时，先读 [CELayoutEditor 文档索引](../../tools/CELayoutEditor/docs/INDEX.md) 中的相关分析。

## 4. WYSIWYG 运行时预览

Win32 客户端可输出 `MT3.runtime-profile.json`，CELayoutEditor 存在 WYSIWYG 预览脚本/文档。比对时需统一：

- physical/frame size
- target/render/UI logic size
- display rectangle
- safe inset
- uiScale

预览与客户端不一致时，先比较 profile，再调整 layout。

## 5. 验证入口

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\CELayoutEditor\scripts\Test-WysiwygRuntimePreview.ps1
powershell -ExecutionPolicy Bypass -File .\tools\CELayoutEditor\scripts\Test-CELayoutEditor-Stability.ps1
```

执行前先阅读脚本参数和预期输入，并确认当前工具产物与资源根。

## 6. 当前结论

- CELayoutEditor 存在可运行产物、资源、扩展头文件和较完整的阶段性文档。
- 当前工作树不支持对旧报告所有源码行号重做全量静态验证。
- 维护时以现存头文件、脚本、当前日志和实际产物行为为准。

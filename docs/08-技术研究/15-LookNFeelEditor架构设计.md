# LookNFeelEditor 架构设计

> **项目**：`tools/LnFEditor/`。
> **当前状态**：Electron/React/TypeScript 实现已入库，Phase 1 具备代码、测试和构建资产；本文的 Phase 2-4 仍是规划。
> **目标资源**：MT3 CEGUI 0.7.1 `.looknfeel` / `.imageset` / `.scheme`。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 实现概览

`package.json` 当前声明：

- Electron 33 + electron-vite 2
- React 19 + TypeScript 5.7
- Zustand + Immer
- fast-xml-parser
- Sharp
- Vitest
- Windows x64 NSIS/portable 打包

仓库已包含 `src/`、`dist/`、`release/`、`resources/`、`node_modules/`、测试和项目文档，因此 LnFEditor 不是纯概念设计。

## 2. 架构

```text
Electron main process
  -> parser / resource loading / serialization / file system
  -> IPC + contextBridge
  -> React renderer
       -> Zustand editor store
       -> navigator / layer tree / property / preview panels
       -> Canvas 2D renderer and interaction
  -> shared models / Dim evaluator / constants
```

| 路径 | 职责 |
| --- | --- |
| `src/main/services/` | LookNFeel/Scheme/Imageset 解析、索引、资源加载和回写。 |
| `src/preload/` | contextBridge 和 IPC 安全边界。 |
| `src/renderer/` | React UI、Canvas、面板、状态和交互。 |
| `src/shared/model/` | WidgetLook、ImagerySection、StateImagery、Dim AST 和编辑状态类型。 |
| `src/shared/services/dim-evaluator.ts` | Dim 表达式求值。 |

## 3. 数据流

```text
open file/directory
  -> build index / parse selected WidgetLook
  -> load Scheme and Imageset resources
  -> Zustand editor state
  -> layer tree + property panel + Canvas preview
  -> edit history
  -> serialize and save
  -> diff + client-side CEGUI validation
```

工具只编辑 XML 资源，不修改 CEGUI 运行时。

## 4. Phase 1（已有实现）

当前可从代码和测试直接确认的基础包括：

- LookNFeel 解析/索引和基础序列化。
- Scheme/Imageset 资源加载边界。
- 共享 Dim evaluator。
- React 编辑器状态、层级树构建和基础 Canvas/面板。
- parser、Dim evaluator、editor store、layer-tree-builder 测试。
- Electron 构建与 Windows 打包配置。

`dist/`/`release/` 产物的存在只是阶段性产物证据；发布前仍需使用当前源码重新执行验证。

## 5. Phase 2-4（规划）

### Phase 2：编辑完整性

- 扩展 WidgetLook/ImagerySection/StateImagery/ChildWidget 的完整可视编辑。
- 完善 Dim AST 编辑、校验、拖拽与属性联动。
- 完善撤销/重做和 dirty/save 生命周期。

### Phase 3：格式保真与验证

- 保留注释、顺序、缩进、属性表达和未识别节点。
- 建立 parse -> serialize -> parse 语义往返。
- 与 CEGUI 0.7.1 真实资源加载做集成验证。

### Phase 4：生产化

- 大文件性能、崩溃恢复、自动保存和差异预览。
- 资源跨引用检查：Scheme -> LookNFeel -> Imageset/Image/Font。
- 打包签名、更新、错误上报和团队发布门禁。

## 6. 格式安全

- 保存前必须显示差异，不默认整文件格式化。
- 未识别的 CEGUI/MT3 扩展节点不静默丢弃。
- 文件编码、BOM 和换行符保持原样，或在用户明确选择后转换。
- 不在渲染进程直接暴露任意文件系统访问，所有 I/O 通过 preload/IPC 边界。

## 7. 验证入口

```powershell
Set-Location E:\MT3\tools\LnFEditor
npm run typecheck
npm run lint
npm test
npm run build
```

打包验证使用 `npm run package:dir` 或当前发布流程，并在一份可回滚 LookNFeel 副本上执行往返与客户端加载。

## 8. 内置文档

- [项目架构概览](../../tools/LnFEditor/docs/01-项目架构概览.md)
- [目录结构与文件职责](../../tools/LnFEditor/docs/02-目录结构与文件职责.md)
- [核心数据流](../../tools/LnFEditor/docs/03-核心数据流.md)
- [构建与打包流程](../../tools/LnFEditor/docs/06-构建与打包流程.md)
- [测试覆盖策略](../../tools/LnFEditor/docs/07-测试覆盖策略.md)

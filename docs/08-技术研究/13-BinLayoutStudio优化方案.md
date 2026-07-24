# BinLayoutStudio 优化方案

> **对象**：`dependencies/BinLayoutConvert/BinLayoutStudio/`。
> **构建入口**：[BinLayoutStudio v120 构建](../06-工具链/04-BinLayoutStudio-v120构建.md)。本页不维护第二套构建命令。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 工具定位

BinLayoutStudio 用于检视和转换 MT3 CEGUI XML/BIN Layout。当前源码包含：

| 模块 | 职责 |
| --- | --- |
| `BinLayoutStudioBinCodec.*` | BIN/XML 读取、节点/属性解码和双向转换。 |
| `BinLayoutStudioXmlWriter.*` | 将中间节点树序列化为 Layout XML。 |
| `BinLayoutStudioBatchConvert.*` | 批量预览、输入/输出规则和转换调度。 |
| `BinLayoutStudioMain.cpp` | Win32 界面和单文件/命令行入口。 |
| `BinLayoutStudioWxMain.cpp` | wxWidgets 界面、属性查看、批量页和拖放。 |

## 2. 已存在的能力

- 自动识别 BIN/XML Layout。
- BIN -> XML、XML -> BIN 转换。
- 展示节点树、属性和处理日志。
- 从已打开的中间树另存 XML/BIN。
- 批量源目录、输出目录、递归、覆盖、命名和模式选项。
- 错误返回与日志。

## 3. 核心不变量

1. BIN 魔数、版本、节点类型和属性 ID/类型解码必须与 `dependencies/cegui/CEGUI/src/BinLayout/v1/` 一致。
2. 未知属性不可静默写成错误类型。
3. XML -> BIN -> XML 的语义需等价，不要求字节级完全相同。
4. 批量转换不覆盖源文件，除非调用方显式选择且已保留回滚。
5. 部分失败需形成清晰汇总，不使用“整批成功”覆盖单文件失败。

## 4. 优化路线

### Phase A：已有能力收敛

- 将单文件和批量转换共用的 codec/error 语义统一。
- 对输入识别、输出命名、覆盖和部分失败建立回归样本。

### Phase B：批量可用性

- 预览必须显示输入、预期输出、操作类型、冲突和跳过原因。
- 增加取消、进度、失败导出和可重试清单。
- 避免 UI 线程执行大量 I/O/转换。

### Phase C：可验证性

- 实现 XML -> BIN -> XML 语义比较器。
- 输出转换 manifest：工具版本、输入哈希、输出哈希、模式、警告和错误。
- 使用历史 Layout 语料库做持续回归。

### Phase D：可维护性

- 将格式解码、XML writer、批量调度与 UI 进一步隔离。
- 将 property ID/type 表的版本与 CEGUI BinLayout 真源联动校验。

## 5. 验证

| 场景 | 预期 |
| --- | --- |
| 单个 XML -> BIN | 客户端可加载，Window/属性/子布局语义正确。 |
| 单个 BIN -> XML | XML 可解析，节点和属性完整。 |
| 往返 | XML -> BIN -> XML 语义比较通过。 |
| 批量 | 成功/失败/跳过/冲突数与文件清单一致。 |
| 异常输入 | 截断 BIN、未知版本、非法 XML、无权限输出时明确失败。 |

## 6. 回滚

- 转换前保留源文件和 manifest。
- 产物先输出到独立目录，验收后才回流资源真源。
- 修改 BinLayout 格式时保留旧工具和客户端可读样本。

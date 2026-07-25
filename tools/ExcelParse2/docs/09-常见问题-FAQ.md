# 09-常见问题-FAQ

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术委员会
> **目标**: 收集和解答 ExcelParse2 的常见问题

---

## 目录

- [1. 安装和配置问题](#1-安装和配置问题)
- [2. 数据加载问题](#2-数据加载问题)
- [3. 数据生成问题](#3-数据生成问题)
- [4. 代码生成问题](#4-代码生成问题)
- [5. 性能问题](#5-性能问题)
- [6. 错误排查问题](#6-错误排查问题)
- [7. 参考资料](#7-参考资料)

---

## 1. 安装和配置问题

### 1.1 如何安装 ExcelParse2？

**问题描述**: 如何安装 ExcelParse2？

**原因分析**: ExcelParse2 是一个独立的可执行程序，不需要安装。

**解决方案**:
1. 下载 ExcelParse2 可执行文件（ExcelParse2.exe）
2. 将可执行文件和依赖库放在同一目录下
3. 直接运行 ExcelParse2.exe

**依赖库**:
- NPOI.dll
- NPOI.OOXML.dll
- NPOI.OpenXml4Net.dll
- NPOI.OpenXmlFormats.dll
- ICSharpCode.SharpZipLib.dll
- Ionic.Zip.dll

---

### 1.2 如何配置 ExcelParse2？

**问题描述**: 如何配置 ExcelParse2 的路径和选项？

**原因分析**: ExcelParse2 需要配置源数据路径和目标路径才能正常工作。

**解决方案**:
1. 运行 ExcelParse2.exe
2. 在主界面中配置以下路径：
   - 源数据路径（Excel/CSV/TXT 文件）
   - Bean 定义路径（XML 文件）
   - 目标客户端 Bin 路径
   - 目标客户端 Xml 路径
   - 目标服务器 Xml 路径
   - 目标服务器 Java 路径
   - 目标客户端 C++ 路径
   - 目标客户端 Lua 路径
   - 目标客户端 PKG 路径
3. 点击"保存配置"按钮保存配置
4. 配置将保存在 ExcelParseOption2.ini 文件中

**参考文档**: [04-配置指南-Configuration-Guide.md](04-配置指南-Configuration-Guide.md)

---

### 1.3 配置文件在哪里？

**问题描述**: ExcelParse2 的配置文件在哪里？

**原因分析**: 配置文件默认保存在可执行文件所在目录。

**解决方案**:
- 配置文件名: ExcelParseOption2.ini
- 位置: 与 ExcelParse2.exe 相同的目录

**配置文件示例**:
```ini
[Path]
SrcDataXlsPath=E:/MT3/gbeans
SrcDataCsvPath=
SrcDataTxtPath=
SrcDataDefXmlPath=E:/MT3/gbeans
DstClientBinDataPath=E:/MT3/client/resource/bin
DstClientXmlDataPath=E:/MT3/client/resource/xml
DstServerXmlDataPath=E:/MT3/server/data/xml
DstServerJavaPath=E:/MT3/server/src
DstClientCppPath=E:/MT3/client/FireClient
DstClientLuaPath=E:/MT3/client/resource/script
DstClientPkgPath=E:/MT3/client/tolua++-pkgs

[Option]
AutoMake=false
ExportSingleTable=false
```

---

### 1.4 如何重置配置？

**问题描述**: 如何重置 ExcelParse2 的配置？

**原因分析**: 配置文件损坏或需要恢复默认配置。

**解决方案**:
1. 关闭 ExcelParse2
2. 删除 ExcelParseOption2.ini 文件
3. 重新运行 ExcelParse2
4. 重新配置路径和选项

---

### 1.5 如何升级 ExcelParse2？

**问题描述**: 如何升级 ExcelParse2 到新版本？

**原因分析**: 需要升级到新版本以获得新功能和修复。

**解决方案**:
1. 备份当前的配置文件（ExcelParseOption2.ini）
2. 备份当前的缓存文件（OneKeyMakeCache.xml）
3. 下载新版本的 ExcelParse2.exe
4. 替换旧版本的 ExcelParse2.exe
5. 恢复配置文件和缓存文件
6. 运行新版本的 ExcelParse2

---

## 2. 数据加载问题

### 2.1 加载 Excel 文件失败

**问题描述**: 加载 Excel 文件时提示"加载失败"。

**原因分析**:
1. Excel 文件格式不正确
2. Excel 文件被其他程序占用
3. Excel 文件路径不正确
4. Excel 文件损坏

**解决方案**:
1. 检查 Excel 文件格式是否为 .xls 或 .xlsx
2. 关闭其他可能占用 Excel 文件的程序
3. 检查 Excel 文件路径是否正确
4. 尝试用 Excel 打开文件，确认文件是否损坏
5. 如果文件损坏，尝试恢复或重新创建

**参考代码**: [`DataManager.cs:LoadXls()`](../DataManager.cs:1)

---

### 2.2 加载 CSV 文件失败

**问题描述**: 加载 CSV 文件时提示"加载失败"。

**原因分析**:
1. CSV 文件格式不正确
2. CSV 文件编码不正确
3. CSV 文件路径不正确
4. CSV 文件损坏

**解决方案**:
1. 检查 CSV 文件格式是否正确（逗号分隔）
2. 检查 CSV 文件编码是否为 UTF-8
3. 检查 CSV 文件路径是否正确
4. 尝试用文本编辑器打开文件，确认文件是否损坏
5. 如果文件损坏，尝试恢复或重新创建

**参考代码**: [`DataManager.cs:LoadCsv()`](../DataManager.cs:1)

---

### 2.3 加载 TXT 文件失败

**问题描述**: 加载 TXT 文件时提示"加载失败"。

**原因分析**:
1. TXT 文件格式不正确
2. TXT 文件编码不正确
3. TXT 文件路径不正确
4. TXT 文件损坏

**解决方案**:
1. 检查 TXT 文件格式是否正确（Tab 分隔）
2. 检查 TXT 文件编码是否为 UTF-8
3. 检查 TXT 文件路径是否正确
4. 尝试用文本编辑器打开文件，确认文件是否损坏
5. 如果文件损坏，尝试恢复或重新创建

**参考代码**: [`DataManager.cs:LoadTxt()`](../DataManager.cs:1)

---

### 2.4 加载 Bean 定义失败

**问题描述**: 加载 Bean 定义文件时提示"加载失败"。

**原因分析**:
1. Bean 定义文件格式不正确
2. Bean 定义文件编码不正确
3. Bean 定义文件路径不正确
4. Bean 定义文件损坏
5. Bean 定义文件中有语法错误

**解决方案**:
1. 检查 Bean 定义文件格式是否为 XML
2. 检查 Bean 定义文件编码是否为 UTF-8
3. 检查 Bean 定义文件路径是否正确
4. 尝试用文本编辑器打开文件，确认文件是否损坏
5. 检查 Bean 定义文件中的 XML 语法是否正确
6. 参考 [06-Bean定义指南-Bean-Definition-Guide.md](06-Bean定义指南-Bean-Definition-Guide.md) 检查 Bean 定义格式

**参考代码**: [`DefineManager.cs:LoadBeanDef()`](../DefineManager.cs:1)

---

### 2.5 数据验证失败

**问题描述**: 加载数据时提示"数据验证失败"。

**原因分析**:
1. 数据类型不符合定义
2. 数据格式不正确
3. 数据超出范围
4. ID 冲突
5. 必填项为空

**解决方案**:
1. 检查数据类型是否符合 Bean 定义
2. 检查数据格式是否正确
3. 检查数据是否在定义的范围内
4. 检查是否有重复的 ID
5. 检查必填项是否为空
6. 查看日志输出，了解具体的验证错误

**参考代码**: [`DataManager.cs:ValidateData()`](../DataManager.cs:1)

---

## 3. 数据生成问题

### 3.1 生成 Bin 文件失败

**问题描述**: 生成 Bin 文件时提示"生成失败"。

**原因分析**:
1. 目标路径不存在
2. 目标路径没有写权限
3. 磁盘空间不足
4. 数据格式不正确

**解决方案**:
1. 检查目标路径是否存在
2. 检查目标路径是否有写权限
3. 检查磁盘空间是否充足
4. 检查数据格式是否正确
5. 查看日志输出，了解具体的错误信息

**参考文档**: [08-二进制格式规范-Binary-Format-Specification.md](08-二进制格式规范-Binary-Format-Specification.md)

---

### 3.2 生成 Xml 文件失败

**问题描述**: 生成 Xml 文件时提示"生成失败"。

**原因分析**:
1. 目标路径不存在
2. 目标路径没有写权限
3. 磁盘空间不足
4. 数据格式不正确
5. XML 格式不正确

**解决方案**:
1. 检查目标路径是否存在
2. 检查目标路径是否有写权限
3. 检查磁盘空间是否充足
4. 检查数据格式是否正确
5. 检查生成的 XML 格式是否正确
6. 查看日志输出，了解具体的错误信息

---

### 3.3 生成 Java 代码失败

**问题描述**: 生成 Java 代码时提示"生成失败"。

**原因分析**:
1. 目标路径不存在
2. 目标路径没有写权限
3. 磁盘空间不足
4. Bean 定义不正确
5. 代码生成模板错误

**解决方案**:
1. 检查目标路径是否存在
2. 检查目标路径是否有写权限
3. 检查磁盘空间是否充足
4. 检查 Bean 定义是否正确
5. 检查代码生成模板是否正确
6. 查看日志输出，了解具体的错误信息

**参考文档**: [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md)

---

### 3.4 生成 C++ 代码失败

**问题描述**: 生成 C++ 代码时提示"生成失败"。

**原因分析**:
1. 目标路径不存在
2. 目标路径没有写权限
3. 磁盘空间不足
4. Bean 定义不正确
5. 代码生成模板错误

**解决方案**:
1. 检查目标路径是否存在
2. 检查目标路径是否有写权限
3. 检查磁盘空间是否充足
4. 检查 Bean 定义是否正确
5. 检查代码生成模板是否正确
6. 查看日志输出，了解具体的错误信息

**参考文档**: [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md)

---

### 3.5 生成 Lua 代码失败

**问题描述**: 生成 Lua 代码时提示"生成失败"。

**原因分析**:
1. 目标路径不存在
2. 目标路径没有写权限
3. 磁盘空间不足
4. Bean 定义不正确
5. 代码生成模板错误

**解决方案**:
1. 检查目标路径是否存在
2. 检查目标路径是否有写权限
3. 检查磁盘空间是否充足
4. 检查 Bean 定义是否正确
5. 检查代码生成模板是否正确
6. 查看日志输出，了解具体的错误信息

**参考文档**: [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md)

---

## 4. 代码生成问题

### 4.1 生成的 Java 代码无法编译

**问题描述**: 生成的 Java 代码无法编译。

**原因分析**:
1. Bean 定义不正确
2. 数据类型不支持
3. 代码生成模板错误
4. Java 语法错误

**解决方案**:
1. 检查 Bean 定义是否正确
2. 检查数据类型是否支持
3. 检查代码生成模板是否正确
4. 检查生成的 Java 代码语法是否正确
5. 查看编译错误信息，定位具体问题

**参考文档**: [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md)

---

### 4.2 生成的 C++ 代码无法编译

**问题描述**: 生成的 C++ 代码无法编译。

**原因分析**:
1. Bean 定义不正确
2. 数据类型不支持
3. 代码生成模板错误
4. C++ 语法错误

**解决方案**:
1. 检查 Bean 定义是否正确
2. 检查数据类型是否支持
3. 检查代码生成模板是否正确
4. 检查生成的 C++ 代码语法是否正确
5. 查看编译错误信息，定位具体问题

**参考文档**: [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md)

---

### 4.3 生成的 Lua 代码无法运行

**问题描述**: 生成的 Lua 代码无法运行。

**原因分析**:
1. Bean 定义不正确
2. 数据类型不支持
3. 代码生成模板错误
4. Lua 语法错误

**解决方案**:
1. 检查 Bean 定义是否正确
2. 检查数据类型是否支持
3. 检查代码生成模板是否正确
4. 检查生成的 Lua 代码语法是否正确
5. 查看运行错误信息，定位具体问题

**参考文档**: [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md)

---

### 4.4 生成的 PKG 文件无法使用

**问题描述**: 生成的 PKG 文件无法使用。

**原因分析**:
1. Bean 定义不正确
2. 数据类型不支持
3. 代码生成模板错误
4. PKG 语法错误

**解决方案**:
1. 检查 Bean 定义是否正确
2. 检查数据类型是否支持
3. 检查代码生成模板是否正确
4. 检查生成的 PKG 文件语法是否正确
5. 查看 tolua++ 错误信息，定位具体问题

**参考文档**: [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md)

---

### 4.5 代码生成速度慢

**问题描述**: 代码生成速度很慢。

**原因分析**:
1. 数据量过大
2. 没有启用缓存
3. 磁盘 I/O 性能差
4. 系统资源不足

**解决方案**:
1. 启用增量生成（缓存机制）
2. 检查磁盘 I/O 性能
3. 关闭其他占用系统资源的程序
4. 升级硬件配置
5. 分批生成代码

**参考文档**: [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) - 性能考虑

---

## 5. 性能问题

### 5.1 文件加载速度慢

**问题描述**: 加载 Excel/CSV/TXT 文件速度很慢。

**原因分析**:
1. 文件过大
2. 磁盘 I/O 性能差
3. 没有启用缓存
4. 系统资源不足

**解决方案**:
1. 启用缓存机制
2. 检查磁盘 I/O 性能
3. 关闭其他占用系统资源的程序
4. 升级硬件配置
5. 分批加载文件

**参考文档**: [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) - 性能考虑

---

### 5.2 生成速度慢

**问题描述**: 生成数据或代码速度很慢。

**原因分析**:
1. 数据量过大
2. 没有启用增量生成
3. 磁盘 I/O 性能差
4. 系统资源不足

**解决方案**:
1. 启用增量生成（缓存机制）
2. 检查磁盘 I/O 性能
3. 关闭其他占用系统资源的程序
4. 升级硬件配置
5. 分批生成数据

**参考文档**: [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) - 性能考虑

---

### 5.3 内存占用高

**问题描述**: ExcelParse2 运行时内存占用很高。

**原因分析**:
1. 数据量过大
2. 没有启用缓存
3. 内存泄漏
4. 系统资源不足

**解决方案**:
1. 启用缓存机制
2. 分批处理数据
3. 关闭其他占用系统资源的程序
4. 升级硬件配置
5. 检查是否有内存泄漏

**参考文档**: [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) - 性能考虑

---

## 6. 错误排查问题

### 6.1 如何查看错误日志？

**问题描述**: 如何查看 ExcelParse2 的错误日志？

**原因分析**: 需要查看详细的错误信息来定位问题。

**解决方案**:
1. 在 ExcelParse2 主界面中查看日志输出窗口
2. 查看生成报告（OneKeyMakeReport）
3. 查看 onekeymake.log 文件（如果启用了自动生成）

**日志位置**:
- 界面日志: 主界面下方的日志输出窗口
- 生成报告: OneKeyMakeReport.xml
- 自动生成日志: onekeymake.log

---

### 6.2 如何调试数据加载问题？

**问题描述**: 如何调试数据加载问题？

**原因分析**: 需要定位数据加载失败的具体原因。

**解决方案**:
1. 查看日志输出窗口，了解具体的错误信息
2. 检查数据文件格式是否正确
3. 检查数据文件编码是否正确
4. 检查数据文件路径是否正确
5. 使用断点调试，逐步跟踪数据加载流程
6. 检查 Bean 定义是否正确

**参考代码**: [`DataManager.cs`](../DataManager.cs:1)

---

### 6.3 如何调试数据生成问题？

**问题描述**: 如何调试数据生成问题？

**原因分析**: 需要定位数据生成失败的具体原因。

**解决方案**:
1. 查看日志输出窗口，了解具体的错误信息
2. 检查目标路径是否存在
3. 检查目标路径是否有写权限
4. 检查数据格式是否正确
5. 使用断点调试，逐步跟踪数据生成流程
6. 检查生成的文件是否正确

**参考代码**: [`MainWindow.xaml.cs`](../MainWindow.xaml.cs:1)

---

### 6.4 如何调试代码生成问题？

**问题描述**: 如何调试代码生成问题？

**原因分析**: 需要定位代码生成失败的具体原因。

**解决方案**:
1. 查看日志输出窗口，了解具体的错误信息
2. 检查 Bean 定义是否正确
3. 检查数据类型是否支持
4. 检查代码生成模板是否正确
5. 使用断点调试，逐步跟踪代码生成流程
6. 检查生成的代码是否正确

**参考代码**: [`ServerBeanNode.cs`](../ServerBeanNode.cs:1)

---

### 6.5 如何报告 Bug？

**问题描述**: 如何向开发团队报告 Bug？

**原因分析**: 需要提供详细的 Bug 信息以便开发团队定位和修复问题。

**解决方案**:
1. 记录 Bug 的详细描述
2. 记录重现 Bug 的步骤
3. 记录错误日志和堆栈信息
4. 记录系统环境信息（操作系统、.NET Framework 版本等）
5. 提供相关的数据文件和配置文件
6. 联系技术支持团队

**Bug 报告模板**:
```markdown
## Bug 描述
[简要描述 Bug 的问题]

## 重现步骤
1. [步骤 1]
2. [步骤 2]
3. [步骤 3]

## 期望结果
[描述期望的结果]

## 实际结果
[描述实际的结果]

## 错误日志
[粘贴错误日志]

## 系统环境
- 操作系统: [Windows 10/11]
- .NET Framework 版本: [4.5]
- ExcelParse2 版本: [1.0.0]

## 附件
[提供相关的数据文件和配置文件]
```

---

## 7. 参考资料

### 7.1 相关文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 项目概述 | [01-项目概述-Project-Overview.md](01-项目概述-Project-Overview.md) | 项目概述 |
| 架构设计 | [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) | 架构设计 |
| 快速开始 | [03-快速开始-Quick-Start.md](03-快速开始-Quick-Start.md) | 快速入门指南 |
| 配置指南 | [04-配置指南-Configuration-Guide.md](04-配置指南-Configuration-Guide.md) | 配置文件说明 |
| 数据格式规范 | [05-数据格式规范-Data-Format-Specification.md](05-数据格式规范-Data-Format-Specification.md) | 数据格式说明 |
| Bean 定义指南 | [06-Bean定义指南-Bean-Definition-Guide.md](06-Bean定义指南-Bean-Definition-Guide.md) | Bean 定义说明 |
| 代码生成指南 | [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md) | 代码生成说明 |
| 二进制格式规范 | [08-二进制格式规范-Binary-Format-Specification.md](08-二进制格式规范-Binary-Format-Specification.md) | 二进制格式说明 |
| 故障排查指南 | [10-故障排查指南-Troubleshooting-Guide.md](10-故障排查指南-Troubleshooting-Guide.md) | 故障排查指南 |

### 7.2 核心代码文件

| 文件 | 行数 | 说明 |
|------|------|------|
| MainWindow.xaml.cs | 2721 | 主窗口逻辑 |
| DataManager.cs | 577 | 数据管理器 |
| DefineManager.cs | 315 | Bean 定义管理器 |
| ServerBeanNode.cs | 358 | 服务器 Bean 节点 |

### 7.3 外部资源

- [NPOI 官方文档](https://github.com/tonyqus/npoi)
- [SharpZipLib 官方文档](https://github.com/icsharpcode/SharpZipLib)
- [.NET Framework 文档](https://docs.microsoft.com/dotnet/framework/)

---

**维护者**: 技术委员会
**下次审查**: 2026-05-20
**许可证**: 内部使用

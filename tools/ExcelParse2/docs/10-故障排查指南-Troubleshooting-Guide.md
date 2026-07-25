# 10-故障排查指南-Troubleshooting-Guide

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术委员会
> **目标**: 提供详细的故障排查指南，帮助用户快速定位和解决问题

---

## 目录

- [1. 错误日志分析](#1-错误日志分析)
- [2. 常见错误及解决方案](#2-常见错误及解决方案)
- [3. 调试技巧](#3-调试技巧)
- [4. 性能问题排查](#4-性能问题排查)
- [5. 联系支持](#5-联系支持)
- [6. 参考资料](#6-参考资料)

---

## 1. 错误日志分析

### 1.1 日志位置

ExcelParse2 提供多种日志输出方式：

| 日志类型 | 位置 | 说明 |
|---------|------|------|
| **界面日志** | 主界面下方的日志输出窗口 | 实时显示操作日志 |
| **生成报告** | OneKeyMakeReport.xml | 详细的生成报告 |
| **自动生成日志** | onekeymake.log | 自动生成的日志文件 |

### 1.2 日志格式

#### 界面日志格式

```
[时间] [级别] [模块] 消息内容
```

**示例**:
```
[2026-02-20 14:30:15] [INFO] [DataManager] 加载 Excel 文件: item.xml
[2026-02-20 14:30:16] [ERROR] [DataManager] 加载 Excel 文件失败: 文件不存在
```

#### 生成报告格式

```xml
<?xml version="1.0" encoding="utf-8"?>
<Report>
  <StartTime>2026-02-20 14:30:00</StartTime>
  <EndTime>2026-02-20 14:31:00</EndTime>
  <TotalFiles>10</TotalFiles>
  <SuccessFiles>8</SuccessFiles>
  <FailedFiles>2</FailedFiles>
  <Errors>
    <Error>
      <File>item.xml</File>
      <Message>加载 Excel 文件失败: 文件不存在</Message>
    </Error>
  </Errors>
</Report>
```

### 1.3 常见错误级别

| 级别 | 说明 | 处理建议 |
|------|------|---------|
| INFO | 信息日志 | 正常操作信息，无需处理 |
| WARNING | 警告日志 | 潜在问题，建议检查 |
| ERROR | 错误日志 | 操作失败，需要处理 |
| FATAL | 致命错误 | 严重错误，需要立即处理 |

---

## 2. 常见错误及解决方案

### 2.1 加载 Excel 失败

**错误信息**:
```
[ERROR] [DataManager] 加载 Excel 文件失败: 文件不存在
```

**原因分析**:
1. Excel 文件路径不正确
2. Excel 文件不存在
3. Excel 文件被其他程序占用
4. Excel 文件格式不正确
5. Excel 文件损坏

**解决方案**:
1. 检查 Excel 文件路径是否正确
2. 确认 Excel 文件是否存在
3. 关闭其他可能占用 Excel 文件的程序
4. 检查 Excel 文件格式是否为 .xls 或 .xlsx
5. 尝试用 Excel 打开文件，确认文件是否损坏
6. 如果文件损坏，尝试恢复或重新创建

**参考代码**: [`DataManager.cs:LoadXls()`](../DataManager.cs:1)

---

### 2.2 加载 CSV/TXT 失败

**错误信息**:
```
[ERROR] [DataManager] 加载 CSV 文件失败: 文件编码不正确
```

**原因分析**:
1. CSV/TXT 文件编码不正确
2. CSV/TXT 文件格式不正确
3. CSV/TXT 文件路径不正确
4. CSV/TXT 文件损坏

**解决方案**:
1. 检查 CSV/TXT 文件编码是否为 UTF-8
2. 检查 CSV 文件格式是否为逗号分隔
3. 检查 TXT 文件格式是否为 Tab 分隔
4. 检查 CSV/TXT 文件路径是否正确
5. 尝试用文本编辑器打开文件，确认文件是否损坏
6. 如果文件损坏，尝试恢复或重新创建

**参考代码**: [`DataManager.cs:LoadCsv()`](../DataManager.cs:1), [`DataManager.cs:LoadTxt()`](../DataManager.cs:1)

---

### 2.3 加载 Bean 定义失败

**错误信息**:
```
[ERROR] [DefineManager] 加载 Bean 定义失败: XML 解析错误
```

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

### 2.4 生成 Bin 文件失败

**错误信息**:
```
[ERROR] [MainWindow] 生成 Bin 文件失败: 目标路径不存在
```

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

### 2.5 生成 Xml 文件失败

**错误信息**:
```
[ERROR] [MainWindow] 生成 Xml 文件失败: XML 格式不正确
```

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

### 2.6 生成 Java 代码失败

**错误信息**:
```
[ERROR] [MainWindow] 生成 Java 代码失败: Bean 定义不正确
```

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

### 2.7 生成 C++ 代码失败

**错误信息**:
```
[ERROR] [MainWindow] 生成 C++ 代码失败: Bean 定义不正确
```

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

### 2.8 生成 Lua 代码失败

**错误信息**:
```
[ERROR] [MainWindow] 生成 Lua 代码失败: Bean 定义不正确
```

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

### 2.9 ID 冲突错误

**错误信息**:
```
[ERROR] [DataManager] ID 冲突: item.xml 中 ID 100 重复
```

**原因分析**:
1. 同一个文件中有重复的 ID
2. 不同文件中有重复的 ID
3. ID 列定义不正确

**解决方案**:
1. 检查同一个文件中是否有重复的 ID
2. 检查不同文件中是否有重复的 ID
3. 检查 ID 列定义是否正确
4. 修改重复的 ID
5. 查看日志输出，了解具体的冲突信息

**参考代码**: [`DataManager.cs:mIdIndex`](../DataManager.cs:21)

---

### 2.10 数据类型转换错误

**错误信息**:
```
[ERROR] [DataManager] 数据类型转换错误: 无法将字符串 "abc" 转换为 int
```

**原因分析**:
1. 数据类型不符合定义
2. 数据格式不正确
3. 数据超出范围

**解决方案**:
1. 检查数据类型是否符合 Bean 定义
2. 检查数据格式是否正确
3. 检查数据是否在定义的范围内
4. 修改数据使其符合定义
5. 查看日志输出，了解具体的转换错误

**参考代码**: [`DataManager.cs:ValidateData()`](../DataManager.cs:1)

---

## 3. 调试技巧

### 3.1 断点设置

**Visual Studio 调试**:

1. 打开 ExcelParse2 项目（ExcelParse2.sln）
2. 在需要调试的代码行设置断点（F9）
3. 按 F5 开始调试
4. 程序运行到断点时自动暂停
5. 使用调试工具查看变量值、调用堆栈等

**推荐断点位置**:
- [`MainWindow.xaml.cs:LoadDataDef()`](../MainWindow.xaml.cs:1) - 加载 Bean 定义
- [`MainWindow.xaml.cs:LoadAllData()`](../MainWindow.xaml.cs:1) - 加载所有数据
- [`MainWindow.xaml.cs:MakeClientData()`](../MainWindow.xaml.cs:1) - 生成客户端数据
- [`MainWindow.xaml.cs:MakeServerData()`](../MainWindow.xaml.cs:1) - 生成服务器数据
- [`MainWindow.xaml.cs:MakeClientCode()`](../MainWindow.xaml.cs:1) - 生成客户端代码

### 3.2 日志输出

**添加自定义日志**:

```csharp
// 信息日志
MainWindow.Info("这是一条信息日志");

// 警告日志
MainWindow.Warning("这是一条警告日志");

// 错误日志
MainWindow.Error("这是一条错误日志");
```

**查看日志**:
- 界面日志: 主界面下方的日志输出窗口
- 生成报告: OneKeyMakeReport.xml
- 自动生成日志: onekeymake.log

### 3.3 单步调试

**单步调试步骤**:

1. 在需要调试的代码行设置断点
2. 按 F5 开始调试
3. 程序运行到断点时自动暂停
4. 使用以下命令进行单步调试：
   - F10 - 单步跳过（不进入函数）
   - F11 - 单步进入（进入函数）
   - Shift+F11 - 单步跳出（跳出当前函数）
5. 使用调试工具查看变量值、调用堆栈等

**调试工具**:
- **局部变量** - 查看当前函数的局部变量
- **监视** - 添加自定义监视表达式
- **调用堆栈** - 查看函数调用链
- **即时窗口** - 执行表达式并查看结果

---

## 4. 性能问题排查

### 4.1 文件加载慢

**症状**: 加载 Excel/CSV/TXT 文件速度很慢

**排查步骤**:
1. 检查文件大小是否过大
2. 检查磁盘 I/O 性能
3. 检查是否启用了缓存
4. 检查系统资源占用情况

**解决方案**:
1. 启用缓存机制
2. 检查磁盘 I/O 性能
3. 关闭其他占用系统资源的程序
4. 升级硬件配置
5. 分批加载文件

**参考文档**: [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) - 性能考虑

### 4.2 生成慢

**症状**: 生成数据或代码速度很慢

**排查步骤**:
1. 检查数据量是否过大
2. 检查是否启用了增量生成
3. 检查磁盘 I/O 性能
4. 检查系统资源占用情况

**解决方案**:
1. 启用增量生成（缓存机制）
2. 检查磁盘 I/O 性能
3. 关闭其他占用系统资源的程序
4. 升级硬件配置
5. 分批生成数据

**参考文档**: [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) - 性能考虑

### 4.3 内存占用高

**症状**: ExcelParse2 运行时内存占用很高

**排查步骤**:
1. 检查数据量是否过大
2. 检查是否启用了缓存
3. 检查是否有内存泄漏
4. 检查系统资源占用情况

**解决方案**:
1. 启用缓存机制
2. 分批处理数据
3. 关闭其他占用系统资源的程序
4. 升级硬件配置
5. 检查是否有内存泄漏

**参考文档**: [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) - 性能考虑

---

## 5. 联系支持

### 5.1 问题报告模板

如果以上方法无法解决问题，请联系技术支持团队。请提供以下信息：

```markdown
## 问题描述
[简要描述问题]

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
- CPU: [Intel Core i7-9700K]
- 内存: [16GB]
- 磁盘: [SSD 500GB]

## 附件
[提供相关的数据文件、配置文件、日志文件等]
```

### 5.2 联系方式

- **技术支持邮箱**: support@example.com
- **技术支持电话**: +86-123-4567-8900
- **技术支持论坛**: https://forum.example.com
- **技术支持工单**: https://support.example.com/tickets

### 5.3 响应时间

| 问题级别 | 响应时间 | 解决时间 |
|---------|---------|---------|
| P0 - 致命错误 | 2 小时 | 24 小时 |
| P1 - 严重错误 | 4 小时 | 48 小时 |
| P2 - 一般错误 | 8 小时 | 72 小时 |
| P3 - 轻微问题 | 24 小时 | 1 周 |

---

## 6. 参考资料

### 6.1 相关文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 文档索引 | [00-文档索引-Documentation-Index.md](00-文档索引-Documentation-Index.md) | 完整文档索引 |
| 项目概述 | [01-项目概述-Project-Overview.md](01-项目概述-Project-Overview.md) | 项目概述 |
| 架构设计 | [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) | 架构设计 |
| 快速开始 | [03-快速开始-Quick-Start.md](03-快速开始-Quick-Start.md) | 快速入门指南 |
| 配置指南 | [04-配置指南-Configuration-Guide.md](04-配置指南-Configuration-Guide.md) | 配置文件说明 |
| 数据格式规范 | [05-数据格式规范-Data-Format-Specification.md](05-数据格式规范-Data-Format-Specification.md) | 数据格式说明 |
| Bean 定义指南 | [06-Bean定义指南-Bean-Definition-Guide.md](06-Bean定义指南-Bean-Definition-Guide.md) | Bean 定义说明 |
| 代码生成指南 | [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md) | 代码生成说明 |
| 二进制格式规范 | [08-二进制格式规范-Binary-Format-Specification.md](08-二进制格式规范-Binary-Format-Specification.md) | 二进制格式说明 |
| 常见问题 | [09-常见问题-FAQ.md](09-常见问题-FAQ.md) | 常见问题解答 |

### 6.2 核心代码文件

| 文件 | 行数 | 说明 |
|------|------|------|
| MainWindow.xaml.cs | 2721 | 主窗口逻辑 |
| DataManager.cs | 577 | 数据管理器 |
| DefineManager.cs | 315 | Bean 定义管理器 |
| ServerBeanNode.cs | 358 | 服务器 Bean 节点 |
| OneKeyMakeCache.cs | - | 缓存管理 |
| OneKeyMakeReport.cs | - | 报告管理 |
| SafeFileWrite.cs | - | 安全文件写入 |

### 6.3 外部资源

- [NPOI 官方文档](https://github.com/tonyqus/npoi)
- [SharpZipLib 官方文档](https://github.com/icsharpcode/SharpZipLib)
- [.NET Framework 文档](https://docs.microsoft.com/dotnet/framework/)
- [Visual Studio 调试指南](https://docs.microsoft.com/en-us/visualstudio/debugger/)

---

**维护者**: 技术委员会
**下次审查**: 2026-05-20
**许可证**: 内部使用

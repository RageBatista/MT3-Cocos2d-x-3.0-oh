# 01-项目概述-Project-Overview

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术委员会
> **目标**: 介绍 ExcelParse2 项目的背景、历史、技术栈和核心功能

---

## 目录

- [1. 项目简介](#1-项目简介)
- [2. 项目历史](#2-项目历史)
- [3. 技术栈](#3-技术栈)
- [4. 核心功能](#4-核心功能)
- [5. 项目结构](#5-项目结构)
- [6. 架构设计](#6-架构设计)
- [7. 数据流图](#7-数据流图)
- [8. 关键特性](#8-关键特性)
- [9. 参考资料](#9-参考资料)

---

## 1. 项目简介

### 1.1 什么是 ExcelParse2

ExcelParse2 是一个基于 .NET Framework 4.5 的 WPF 桌面应用程序，用于将 Excel/CSV/TXT 格式的游戏配置数据转换为多种目标格式：

- **二进制文件** (`.bin`) - 客户端高性能数据加载
- **XML 文件** (`.xml`) - 服务器端数据配置
- **Java 代码** (`.java`) - 服务器端数据访问类
- **C++ 代码** (`.cpp/.h`) - 客户端数据访问类
- **Lua 代码** (`.lua`) - 客户端脚本数据访问
- **PKG 文件** (`.pkg`) - tolua++ 绑定定义

### 1.2 为什么需要 ExcelParse2

在游戏开发过程中，策划通常使用 Excel 编辑配置数据（如物品表、技能表、任务表等）。这些数据需要转换为游戏引擎和服务器可以使用的格式。ExcelParse2 解决了以下问题：

1. **数据格式转换** - 将 Excel 转换为多种目标格式
2. **代码自动生成** - 自动生成数据访问代码，减少手动编码工作
3. **数据验证** - 在转换过程中验证数据完整性和正确性
4. **增量生成** - 只重新生成修改过的数据，提高效率
5. **批量处理** - 支持批量处理多个 Excel 文件
6. **跨平台支持** - 支持客户端（C++/Lua）和服务器（Java）的数据生成

### 1.3 应用场景

- **游戏配置管理** - 管理游戏中的各种配置数据
- **数据版本控制** - 将 Excel 数据纳入版本控制系统
- **自动化构建** - 集成到自动化构建流程中
- **多平台数据生成** - 为不同平台生成不同格式的数据

---

## 2. 项目历史

### 2.1 ExcelParse 的局限性

ExcelParse 是 ExcelParse2 的前身，存在以下问题：

1. **性能问题** - 处理大量数据时性能较差
2. **功能限制** - 不支持增量生成
3. **代码质量** - 代码结构混乱，难以维护
4. **扩展性差** - 难以添加新的数据类型和代码生成模板

### 2.2 ExcelParse2 的改进

ExcelParse2 在 ExcelParse 的基础上进行了全面重构：

| 特性 | ExcelParse | ExcelParse2 |
|------|-----------|-------------|
| 性能 | 较慢 | 显著提升 |
| 增量生成 | 不支持 | 支持 |
| 缓存机制 | 无 | 有 |
| 数据验证 | 基础 | 完善 |
| 代码质量 | 较差 | 良好 |
| 扩展性 | 差 | 良好 |
| 错误处理 | 基础 | 完善 |
| 日志记录 | 简单 | 详细 |

### 2.3 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| 1.0.0 | 2026-02-20 | 初始版本，完整功能实现 |

---

## 3. 技术栈

### 3.1 开发框架

| 技术 | 版本 | 用途 |
|------|------|------|
| .NET Framework | 4.5 | 运行时框架 |
| WPF | 4.5 | 用户界面框架 |
| C# | 5.0 | 编程语言 |

### 3.2 核心依赖库

| 库 | 版本 | 用途 |
|------|------|------|
| NPOI.dll | - | Excel 文件读写（.xls/.xlsx） |
| NPOI.OOXML.dll | - | OOXML 格式支持 |
| NPOI.OpenXml4Net.dll | - | OpenXml 支持 |
| NPOI.OpenXmlFormats.dll | - | OpenXml 格式处理 |
| ICSharpCode.SharpZipLib.dll | - | ZIP 解压缩 |
| Ionic.Zip.dll | - | ZIP 文件处理 |

### 3.3 依赖库说明

#### NPOI 库

NPOI 是一个开源的 .NET 库，用于读写 Microsoft Office 格式文件：

- **NPOI.dll** - 核心库，提供 Excel 文件读写功能
- **NPOI.OOXML.dll** - 支持 Office Open XML 格式（.xlsx）
- **NPOI.OpenXml4Net.dll** - OpenXml 打包支持
- **NPOI.OpenXmlFormats.dll** - OpenXml 格式定义

#### SharpZipLib 库

ICSharpCode.SharpZipLib 是一个开源的 .NET ZIP 压缩库：

- 用于解压缩 .xlsx 文件（.xlsx 本质上是 ZIP 文件）
- 提供高效的压缩和解压缩功能

---

## 4. 核心功能

### 4.1 数据加载

ExcelParse2 支持从多种数据源加载数据：

| 数据源 | 格式 | 说明 |
|--------|------|------|
| Excel 文件 | .xls, .xlsx | Microsoft Excel 格式 |
| CSV 文件 | .csv | 逗号分隔值文件 |
| TXT 文件 | .txt | 文本文件（Tab 分隔） |
| Bean 定义 | .xml | XML 格式的 Bean 定义文件 |

**核心代码**：[`DataManager.cs`](../DataManager.cs:1) (577行)

### 4.2 数据生成

ExcelParse2 可以生成多种格式的数据：

| 目标格式 | 文件扩展名 | 用途 |
|---------|-----------|------|
| 二进制文件 | .bin | 客户端高性能数据加载 |
| XML 文件 | .xml | 服务器端数据配置 |
| Java 代码 | .java | 服务器端数据访问类 |
| C++ 代码 | .cpp, .h | 客户端数据访问类 |
| Lua 代码 | .lua | 客户端脚本数据访问 |
| PKG 文件 | .pkg | tolua++ 绑定定义 |

**核心代码**：[`MainWindow.xaml.cs`](../MainWindow.xaml.cs:1) (2721行)

### 4.3 代码生成

ExcelParse2 可以自动生成数据访问代码：

- **Java 代码** - 生成 xbean 数据访问类
- **C++ 代码** - 生成 C++ 数据结构和访问函数
- **Lua 代码** - 生成 Lua 数据访问模块
- **PKG 文件** - 生成 tolua++ 绑定定义

**核心代码**：[`ServerBeanNode.cs`](../ServerBeanNode.cs:1) (358行)

### 4.4 数据验证

ExcelParse2 在数据加载和生成过程中进行多种验证：

- **数据类型验证** - 验证数据是否符合定义的类型
- **ID 冲突检测** - 检测数据 ID 是否重复
- **范围验证** - 验证数值是否在指定范围内
- **必填项验证** - 验证必填项是否为空
- **格式验证** - 验证数据格式是否正确

**核心代码**：[`DefineManager.cs`](../DefineManager.cs:1) (315行)

---

## 5. 项目结构

### 5.1 目录结构

```
tools/ExcelParse2/
├── App.xaml                    # WPF 应用程序入口
├── App.xaml.cs                 # 应用程序代码
├── MainWindow.xaml             # 主窗口 UI 定义
├── MainWindow.xaml.cs          # 主窗口逻辑 (2721行)
├── DataManager.cs              # 数据管理器 (577行)
├── DefineManager.cs            # Bean 定义管理器 (315行)
├── ServerBeanData.cs           # 服务器 Bean 数据
├── ServerBeanNode.cs           # 服务器 Bean 节点 (358行)
├── OneKeyMakeCache.cs          # 缓存管理
├── OneKeyMakeReport.cs         # 报告管理
├── SafeFileWrite.cs            # 安全文件写入
├── SelectXlsDlg.xaml           # Excel 文件选择对话框
├── SelectXlsDlg.xaml.cs        # 对话框逻辑
├── ExcelParse2.csproj          # 项目文件
├── ExcelParse2.sln             # 解决方案文件
├── ExcelParseOption2.ini       # 配置文件
├── README.md                   # 项目说明
├── lib/                        # 依赖库目录
│   ├── NPOI.dll
│   ├── NPOI.OOXML.dll
│   ├── NPOI.OpenXml4Net.dll
│   ├── NPOI.OpenXmlFormats.dll
│   ├── ICSharpCode.SharpZipLib.dll
│   └── Ionic.Zip.dll
├── utils/                      # 工具类目录
│   ├── ToolsFile.cs            # 文件工具
│   ├── ToolsFileStr.cs         # 文件字符串工具
│   ├── ToolsIni.cs             # INI 配置工具
│   └── ToolsStr.cs             # 字符串工具
├── Properties/                  # 项目属性
│   ├── AssemblyInfo.cs
│   ├── Resources.Designer.cs
│   ├── Resources.resx
│   ├── Settings.Designer.cs
│   └── Settings.settings
└── docs/                       # 文档目录
    ├── 00-文档索引-Documentation-Index.md
    ├── 01-项目概述-Project-Overview.md
    ├── 02-架构设计-Architecture-Design.md
    ├── 03-快速开始-Quick-Start.md
    ├── 04-配置指南-Configuration-Guide.md
    ├── 05-数据格式规范-Data-Format-Specification.md
    ├── 06-Bean定义指南-Bean-Definition-Guide.md
    ├── 07-代码生成指南-Code-Generation-Guide.md
    ├── 08-二进制格式规范-Binary-Format-Specification.md
    ├── 09-常见问题-FAQ.md
    └── 10-故障排查指南-Troubleshooting-Guide.md
```

### 5.2 核心类

| 类名 | 文件 | 行数 | 功能描述 |
|------|------|------|---------|
| MainWindow | MainWindow.xaml.cs | 2721 | 主窗口，负责 UI 交互和数据生成流程控制 |
| DataManager | DataManager.cs | 577 | 数据管理器，负责 Excel/CSV/TXT 数据加载和验证 |
| DefineManager | DefineManager.cs | 315 | Bean 定义管理器，负责加载和管理 Bean 定义 |
| ServerBeanData | ServerBeanData.cs | - | 服务器 Bean 数据，负责存储服务器端数据 |
| ServerBeanNode | ServerBeanNode.cs | 358 | 服务器 Bean 节点，负责构建 Bean 数据树 |
| OneKeyMakeCache | OneKeyMakeCache.cs | - | 缓存管理，负责增量生成的缓存机制 |
| OneKeyMakeReport | OneKeyMakeReport.cs | - | 报告管理，负责生成数据生成报告 |
| SafeFileWrite | SafeFileWrite.cs | - | 安全文件写入，负责原子性文件写入 |

### 5.3 依赖库

| 库名 | 文件 | 功能描述 |
|------|------|---------|
| NPOI | lib/NPOI.dll | Excel 文件读写核心库 |
| NPOI.OOXML | lib/NPOI.OOXML.dll | OOXML 格式支持 |
| NPOI.OpenXml4Net | lib/NPOI.OpenXml4Net.dll | OpenXml 打包支持 |
| NPOI.OpenXmlFormats | lib/NPOI.OpenXmlFormats.dll | OpenXml 格式定义 |
| SharpZipLib | lib/ICSharpCode.SharpZipLib.dll | ZIP 解压缩 |
| Ionic.Zip | lib/Ionic.Zip.dll | ZIP 文件处理 |

---

## 6. 架构设计

### 6.1 三层架构

ExcelParse2 采用经典的三层架构设计：

```
┌─────────────────────────────────────────┐
│  Layer 3: UI 层 (Presentation Layer)    │
│  - MainWindow.xaml                      │
│  - SelectXlsDlg.xaml                    │
│  - 用户交互                             │
│  - 进度显示                             │
│  - 日志输出                             │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  Layer 2: 业务逻辑层 (Business Layer)   │
│  - DataManager                          │
│  - DefineManager                        │
│  - ServerBeanData                       │
│  - ServerBeanNode                       │
│  - 数据加载                             │
│  - 数据验证                             │
│  - 数据生成                             │
│  - 代码生成                             │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  Layer 1: 数据层 (Data Layer)           │
│  - Excel 文件 (.xls/.xlsx)              │
│  - CSV/TXT 文件                         │
│  - Bean 定义 (.xml)                     │
│  - 二进制文件 (.bin)                    │
│  - XML 文件 (.xml)                      │
│  - 代码文件 (.java/.cpp/.lua)           │
│  - 配置文件 (.ini)                      │
└─────────────────────────────────────────┘
```

### 6.2 各层职责

#### UI 层 (Layer 3)

- **MainWindow** - 主窗口，提供用户界面
- **SelectXlsDlg** - Excel 文件选择对话框
- 负责用户交互、进度显示、日志输出

#### 业务逻辑层 (Layer 2)

- **DataManager** - 数据管理器，负责数据加载和验证
- **DefineManager** - Bean 定义管理器，负责 Bean 定义管理
- **ServerBeanData** - 服务器 Bean 数据，负责数据存储
- **ServerBeanNode** - 服务器 Bean 节点，负责数据树构建
- 负责数据加载、验证、生成和代码生成

#### 数据层 (Layer 1)

- Excel/CSV/TXT 文件 - 数据源
- Bean 定义文件 - 数据结构定义
- 二进制/XML/代码文件 - 输出文件
- 配置文件 - 应用配置

---

## 7. 数据流图

### 7.1 完整数据流

```
┌──────────────┐
│ Excel 文件   │
│ (.xls/.xlsx) │
└──────┬───────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌──────────────┐  ┌──────────────┐
│ CSV/TXT 文件 │  │ Bean 定义    │
└──────┬───────┘  │ (.xml)       │
       │          └──────┬───────┘
       │                 │
       │                 ▼
       │          ┌──────────────┐
       │          │ DefineManager│
       │          └──────┬───────┘
       │                 │
       └────────┬────────┘
                │
                ▼
         ┌──────────────┐
         │ DataManager  │
         └──────┬───────┘
                │
                ▼
         ┌──────────────┐
         │ 数据验证     │
         └──────┬───────┘
                │
       ┌────────┴────────┐
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ 客户端数据   │  │ 服务器数据   │
│ 生成流程     │  │ 生成流程     │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ .bin 文件    │  │ .xml 文件    │
│ .cpp/.h 文件 │  │ .java 文件   │
│ .lua 文件    │  │              │
│ .pkg 文件    │  │              │
└──────────────┘  └──────────────┘
```

### 7.2 数据加载流程

```
1. 用户选择 Excel 文件
   ↓
2. DataManager 加载 Excel 文件
   ↓
3. 解析 Excel 数据到 XlsData 对象
   ↓
4. 创建标题索引 (mTitleIndex)
   ↓
5. 创建 ID 索引 (mIdIndex)
   ↓
6. 验证数据类型和格式
   ↓
7. 返回加载结果
```

### 7.3 数据生成流程

```
1. 用户配置生成选项
   ↓
2. DataManager 生成数据
   ↓
3. 根据数据类型生成不同格式
   ├─ 二进制文件 (.bin)
   ├─ XML 文件 (.xml)
   ├─ Java 代码 (.java)
   ├─ C++ 代码 (.cpp/.h)
   ├─ Lua 代码 (.lua)
   └─ PKG 文件 (.pkg)
   ↓
4. 使用 SafeFileWrite 安全写入文件
   ↓
5. 更新缓存 (OneKeyMakeCache)
   ↓
6. 生成报告 (OneKeyMakeReport)
   ↓
7. 返回生成结果
```

---

## 8. 关键特性

### 8.1 增量生成

ExcelParse2 支持增量生成，只重新生成修改过的数据：

- **缓存机制** - 使用 [`OneKeyMakeCache.cs`](../OneKeyMakeCache.cs:1) 管理缓存
- **文件哈希** - 通过文件哈希判断文件是否修改
- **时间戳** - 通过时间戳判断文件是否修改
- **性能提升** - 显著提高大规模数据生成的性能

**核心代码**：[`OneKeyMakeCache.cs`](../OneKeyMakeCache.cs:1)

### 8.2 缓存机制

ExcelParse2 使用缓存机制提高性能：

- **数据缓存** - 缓存加载的 Excel 数据
- **定义缓存** - 缓存 Bean 定义
- **生成缓存** - 缓存生成的文件
- **缓存失效** - 支持手动清除缓存

**核心代码**：[`OneKeyMakeCache.cs`](../OneKeyMakeCache.cs:1)

### 8.3 数据验证

ExcelParse2 提供完善的数据验证机制：

- **类型验证** - 验证数据类型是否符合定义
- **范围验证** - 验证数值是否在指定范围内
- **必填验证** - 验证必填项是否为空
- **格式验证** - 验证数据格式是否正确
- **ID 冲突检测** - 检测数据 ID 是否重复

**核心代码**：[`DataManager.cs`](../DataManager.cs:1)

### 8.4 错误处理

ExcelParse2 提供完善的错误处理机制：

- **错误日志** - 记录详细的错误信息
- **错误提示** - 在 UI 中显示错误信息
- **错误恢复** - 支持从错误中恢复
- **错误报告** - 生成详细的错误报告

**核心代码**：[`MainWindow.xaml.cs`](../MainWindow.xaml.cs:1)

### 8.5 批量处理

ExcelParse2 支持批量处理多个文件：

- **批量加载** - 一次加载多个 Excel 文件
- **批量生成** - 一次生成多个文件
- **进度显示** - 显示批量处理进度
- **错误汇总** - 汇总批量处理错误

**核心代码**：[`MainWindow.xaml.cs`](../MainWindow.xaml.cs:1)

### 8.6 安全写入

ExcelParse2 使用安全文件写入机制：

- **原子写入** - 确保文件写入的原子性
- **临时文件** - 使用临时文件避免数据损坏
- **文件锁** - 使用文件锁避免并发冲突
- **回滚机制** - 支持写入失败回滚

**核心代码**：[`SafeFileWrite.cs`](../SafeFileWrite.cs:1)

---

## 9. 参考资料

### 9.1 相关文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 文档索引 | [00-文档索引-Documentation-Index.md](00-文档索引-Documentation-Index.md) | 完整文档索引 |
| 快速开始 | [03-快速开始-Quick-Start.md](03-快速开始-Quick-Start.md) | 快速入门指南 |
| 配置指南 | [04-配置指南-Configuration-Guide.md](04-配置指南-Configuration-Guide.md) | 配置文件说明 |
| 数据格式规范 | [05-数据格式规范-Data-Format-Specification.md](05-数据格式规范-Data-Format-Specification.md) | 数据格式说明 |
| Bean 定义指南 | [06-Bean定义指南-Bean-Definition-Guide.md](06-Bean定义指南-Bean-Definition-Guide.md) | Bean 定义说明 |
| 代码生成指南 | [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md) | 代码生成说明 |
| 二进制格式规范 | [08-二进制格式规范-Binary-Format-Specification.md](08-二进制格式规范-Binary-Format-Specification.md) | 二进制格式说明 |
| 架构设计 | [02-架构设计-Architecture-Design.md](02-架构设计-Architecture-Design.md) | 架构设计说明 |
| 常见问题 | [09-常见问题-FAQ.md](09-常见问题-FAQ.md) | 常见问题解答 |
| 故障排查指南 | [10-故障排查指南-Troubleshooting-Guide.md](10-故障排查指南-Troubleshooting-Guide.md) | 故障排查指南 |

### 9.2 核心代码文件

| 文件 | 行数 | 说明 |
|------|------|------|
| MainWindow.xaml.cs | 2721 | 主窗口逻辑 |
| DataManager.cs | 577 | 数据管理器 |
| DefineManager.cs | 315 | Bean 定义管理器 |
| ServerBeanNode.cs | 358 | 服务器 Bean 节点 |

### 9.3 外部资源

- [NPOI 官方文档](https://github.com/tonyqus/npoi)
- [SharpZipLib 官方文档](https://github.com/icsharpcode/SharpZipLib)
- [.NET Framework 文档](https://docs.microsoft.com/dotnet/framework/)

---

**维护者**: 技术委员会
**下次审查**: 2026-05-20
**许可证**: 内部使用

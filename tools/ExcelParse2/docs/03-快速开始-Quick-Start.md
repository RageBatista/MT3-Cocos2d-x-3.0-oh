# ExcelParse2 快速开始

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术委员会

---

## 目录

- [1. 环境要求](#1-环境要求)
- [2. 安装步骤](#2-安装步骤)
- [3. 首次配置](#3-首次配置)
- [4. 基本使用流程](#4-基本使用流程)
- [5. 示例演示](#5-示例演示)
- [6. 常见问题快速解答](#6-常见问题快速解答)
- [7. 下一步](#7-下一步)

---

## 1. 环境要求

### 1.1 硬件要求

```yaml
最低配置：
  - CPU: Intel Core i3 或同等处理器
  - 内存: 2GB RAM
  - 硬盘: 500MB 可用空间

推荐配置：
  - CPU: Intel Core i5 或更高
  - 内存: 4GB RAM 或更多
  - 硬盘: 1GB 可用空间或更多
```

### 1.2 软件要求

```yaml
操作系统：
  - Windows 7 或更高版本
  - Windows Server 2008 R2 或更高版本

开发环境：
  - Visual Studio 2013 (必需)
  - .NET Framework 4.5 (必需)
  - Windows SDK 8.1 (可选)

运行时依赖：
  - .NET Framework 4.5 或更高版本
  - Windows Presentation Foundation (WPF)
```

### 1.3 验证环境

#### 验证 Visual Studio 2013

打开命令提示符，执行以下命令：

```cmd
cmd /c "call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86 && cl"
```

如果显示 Microsoft (R) C/C++ 编译器版本信息，说明 Visual Studio 2013 已正确安装。

#### 验证 .NET Framework 4.5

打开命令提示符，执行以下命令：

```cmd
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release
```

如果返回值大于或等于 378389，说明 .NET Framework 4.5 或更高版本已安装。

---

## 2. 安装步骤

### 2.1 获取源代码

从版本控制系统获取 ExcelParse2 源代码：

```bash
# 克隆仓库（示例）
git clone <repository-url> MT3
cd MT3/tools/ExcelParse2
```

### 2.2 编译项目

#### 方法一：使用 Visual Studio 2013

1. 双击打开 [`ExcelParse2.sln`](../ExcelParse2.sln)
2. 选择 **生成** → **生成解决方案** (或按 `Ctrl+Shift+B`)
3. 等待编译完成

#### 方法二：使用 MSBuild 命令行

打开命令提示符，执行以下命令：

```cmd
cd tools/ExcelParse2
cmd /c "call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86 && msbuild ExcelParse2.sln /t:Rebuild /p:Configuration=Release /p:Platform=AnyCPU /m /nologo"
```

### 2.3 验证编译结果

编译成功后，在以下目录生成可执行文件：

```
tools/ExcelParse2/bin/Release/ExcelParse2.exe
```

---

## 3. 首次配置

### 3.1 配置文件说明

ExcelParse2 使用 [`ExcelParseOption2.ini`](../ExcelParseOption2.ini) 作为配置文件，该文件必须位于程序运行目录。

### 3.2 创建配置文件

首次运行时，程序会自动创建默认配置文件。您也可以手动创建配置文件。

#### 配置文件示例

```ini
[SrcDataXlsPath]
Path=..\..\..\gbeans\xls

[SrcDataCsvPath]
Path=..\..\..\gbeans\csv

[SrcDataTxtPath]
Path=..\..\..\gbeans\txt

[SrcDataDefXmlPath]
Path=..\..\..\gbeans\def

[DstClientBinDataPath]
Path=..\..\..\client\resource\bin

[DstClientXmlDataPath]
Path=..\..\..\client\resource\xml

[DstServerXmlDataPath]
Path=..\..\..\server\server\data\xml

[DstServerXmlDataPath]
ManualConfig=false

[DstClientCppPath]
Path=..\..\..\client\FireClient\src

[DstClientLuaPath]
Path=..\..\..\client\resource\lua

[DstClientPkgPath]
Path=..\..\..\client\tolua++-pkgs

[DstServerJavaPath]
Path=..\..\..\server\server\src

[Hostroy]
Record=

[Config]
AutoMake=false
CoderUse=false
SelectFileType=0
SelectSortType=0
```

### 3.3 配置项说明

#### 源数据路径配置

| 配置项 | 说明 | 示例 |
|--------|------|------|
| `SrcDataXlsPath` | Excel 源文件路径 | `..\..\..\gbeans\xls` |
| `SrcDataCsvPath` | CSV 源文件路径 | `..\..\..\gbeans\csv` |
| `SrcDataTxtPath` | TXT 源文件路径 | `..\..\..\gbeans\txt` |
| `SrcDataDefXmlPath` | Bean 定义 XML 路径 | `..\..\..\gbeans\def` |

#### 目标数据路径配置

| 配置项 | 说明 | 示例 |
|--------|------|------|
| `DstClientBinDataPath` | 客户端二进制数据路径 | `..\..\..\client\resource\bin` |
| `DstClientXmlDataPath` | 客户端 XML 数据路径 | `..\..\..\client\resource\xml` |
| `DstServerXmlDataPath` | 服务器 XML 数据路径 | `..\..\..\server\server\data\xml` |
| `DstClientCppPath` | 客户端 C++ 代码路径 | `..\..\..\client\FireClient\src` |
| `DstClientLuaPath` | 客户端 Lua 代码路径 | `..\..\..\client\resource\lua` |
| `DstClientPkgPath` | 客户端 PKG 文件路径 | `..\..\..\client\tolua++-pkgs` |
| `DstServerJavaPath` | 服务器 Java 代码路径 | `..\..\..\server\server\src` |

#### 其他配置项

| 配置项 | 说明 | 可选值 |
|--------|------|--------|
| `AutoMake` | 是否自动生成 | `true`/`false` |
| `CoderUse` | CoderUse 模式 | `true`/`false` |
| `SelectFileType` | 选择文件类型 | `0`=Excel, `1`=CSV, `2`=TXT |
| `SelectSortType` | 排序类型 | `0`=默认 |

### 3.4 路径解析规则

配置文件中的路径支持相对路径，使用 `..\\` 前缀表示上级目录。

#### 相对路径示例

```ini
# 相对于程序运行目录
Path=..\..\..\gbeans\xls

# 绝对路径
Path=D:\MT3\gbeans\xls

# 当前目录
Path=.\data
```

#### 路径解析逻辑

程序使用以下逻辑解析路径：

```csharp
// 伪代码
string GetAbsDataPath(string relativePath)
{
    if (relativePath.StartsWith("..\\"))
    {
        // 相对路径：基于程序运行目录
        return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, relativePath);
    }
    else if (Path.IsPathRooted(relativePath))
    {
        // 绝对路径
        return relativePath;
    }
    else
    {
        // 相对路径：基于程序运行目录
        return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, relativePath);
    }
}
```

### 3.5 CoderUse 模式说明

CoderUse 模式用于程序化使用 ExcelParse2，无需人工干预。

#### 启用 CoderUse 模式

在配置文件中设置：

```ini
[Config]
CoderUse=true
AutoMake=true
```

#### CoderUse 模式行为

- 启动程序后自动执行一键生成
- 生成完成后自动关闭程序
- 生成日志保存到 `onekeymake.log`
- 错误日志保存到 `error.log`

---

## 4. 基本使用流程

### 4.1 启动程序

双击运行 [`ExcelParse2.exe`](../bin/Release/ExcelParse2.exe)，程序主窗口将显示。

### 4.2 选择文件类型

在主窗口中选择源数据文件类型：

- **Excel**: 选择 `.xlsx` 或 `.xlsm` 文件
- **CSV**: 选择 `.csv` 文件
- **TXT**: 选择 `.txt` 文件（CSV 格式）

### 4.3 加载定义

点击 **加载定义** 按钮，加载 Bean 定义文件：

```csharp
// 加载定义流程
LoadDataDef()
  ↓
读取 mSrcDataDefXmlPath 目录下的所有 XML 文件
  ↓
解析 XML 文件，生成 BeanDef 对象
  ↓
显示加载结果
```

### 4.4 加载数据

有两种加载数据的方式：

#### 方式一：加载所有数据

点击 **加载所有数据** 按钮，加载所有 Bean 数据：

```csharp
// 加载所有数据流程
LoadAllData()
  ↓
遍历所有 BeanDef
  ↓
根据 BeanDef.from 加载对应的数据文件
  ↓
解析数据文件，生成 XlsData 对象
  ↓
显示加载结果
```

#### 方式二：仅加载配置数据

点击 **仅加载配置数据** 按钮，仅加载历史 Bean 数据：

```csharp
// 仅加载配置数据流程
LoadConfigData()
  ↓
读取 mHostroyBeans 配置
  ↓
遍历历史 Bean 列表
  ↓
加载对应的 Bean 数据
  ↓
显示加载结果
```

### 4.5 生成数据

#### 生成客户端数据

点击 **生成客户端数据** 按钮，生成客户端数据：

```csharp
// 生成客户端数据流程
MakeClientData(makeBin, makeXml, makeCpp, makeLua)
  ↓
遍历所有 BeanDef
  ↓
生成二进制数据 (makeBin=true)
  ↓
生成 XML 数据 (makeXml=true)
  ↓
生成 C++ 代码 (makeCpp=true)
  ↓
生成 Lua 代码 (makeLua=true)
  ↓
显示生成结果
```

#### 生成服务器数据

点击 **生成服务器数据** 按钮，生成服务器数据：

```csharp
// 生成服务器数据流程
MakeServerData(makeXml, makeJava)
  ↓
遍历所有 BeanDef
  ↓
生成 XML 数据 (makeXml=true)
  ↓
生成 Java 代码 (makeJava=true)
  ↓
显示生成结果
```

#### 一键生成

点击 **一键生成** 按钮，自动执行所有步骤：

```csharp
// 一键生成流程
AutoMake()
  ↓
LoadDataDef()        // 加载定义
  ↓
LoadAllData()        // 加载所有数据
  ↓
MakeClientData()     // 生成客户端数据
  ↓
MakeServerData()     // 生成服务器数据
  ↓
MakeClientCode()     // 生成客户端代码
  ↓
生成日志文件
```

### 4.6 查看日志

生成完成后，程序会在输出窗口显示日志信息。同时，日志会保存到以下文件：

- `onekeymake.log`: 完整日志
- `error.log`: 错误日志（仅在生成失败时生成）

---

## 5. 示例演示

### 5.1 示例 1：一键生成所有数据

**场景**: 策划更新了 Excel 配置文件，需要生成客户端和服务器数据。

**步骤**:

1. 启动 ExcelParse2
2. 点击 **一键生成** 按钮
3. 等待生成完成
4. 查看 `onekeymake.log` 确认生成结果

**预期输出**:

```
[INFO] 成功加载服务器Bean 100个,客户端Bean 80个.
[INFO] 成功加载数据文件 50个.
[INFO] 成功生成客户端二进制数据 50个.
[INFO] 成功生成客户端XML数据 50个.
[INFO] 成功生成服务器XML数据 50个.
[INFO] 成功生成客户端C++代码 80个.
[INFO] 成功生成客户端Lua代码 80个.
[INFO] 一键数据和代码生成成功！
```

### 5.2 示例 2：单表导出

**场景**: 仅需要更新某个特定 Bean 的数据。

**步骤**:

1. 启动 ExcelParse2
2. 点击 **加载定义** 按钮
3. 在历史 Bean 列表中选择要导出的 Bean
4. 点击 **仅加载配置数据** 按钮
5. 点击 **生成客户端数据** 按钮
6. 点击 **生成服务器数据** 按钮

**预期输出**:

```
[INFO] 成功加载服务器Bean 100个,客户端Bean 80个.
[INFO] 成功加载数据文件 1个.
[INFO] 成功生成客户端二进制数据 1个.
[INFO] 成功生成客户端XML数据 1个.
[INFO] 成功生成服务器XML数据 1个.
```

### 5.3 示例 3：使用 CoderUse 模式

**场景**: 在构建脚本中自动调用 ExcelParse2。

**步骤**:

1. 在配置文件中启用 CoderUse 模式：

```ini
[Config]
CoderUse=true
AutoMake=true
```

2. 在构建脚本中调用 ExcelParse2：

```batch
@echo off
cd tools\ExcelParse2\bin\Release
ExcelParse2.exe
```

3. 查看 `onekeymake.log` 确认生成结果

**预期行为**:

- 程序启动后自动执行一键生成
- 生成完成后自动关闭程序
- 无需人工干预

---

## 6. 常见问题快速解答

### Q1: 程序启动失败，提示找不到 .NET Framework 4.5

**原因**: 系统未安装 .NET Framework 4.5 或更高版本。

**解决方案**:

1. 下载并安装 .NET Framework 4.5：
   - Windows 7/8: https://www.microsoft.com/download/details.aspx?id=42642
   - Windows 8.1/10: 已内置，无需安装

2. 重新启动程序

### Q2: 加载定义失败，提示找不到 XML 文件

**原因**: `SrcDataDefXmlPath` 配置错误或路径不存在。

**解决方案**:

1. 检查配置文件中的 `SrcDataDefXmlPath` 是否正确
2. 确认路径是否存在
3. 确认路径下是否有 XML 文件

### Q3: 加载数据失败，提示找不到 Excel 文件

**原因**: `SrcDataXlsPath` 配置错误或路径不存在。

**解决方案**:

1. 检查配置文件中的 `SrcDataXlsPath` 是否正确
2. 确认路径是否存在
3. 确认路径下是否有 Excel 文件

### Q4: 生成数据失败，提示目标路径不存在

**原因**: 目标路径配置错误或路径不存在。

**解决方案**:

1. 检查配置文件中的目标路径是否正确
2. 手动创建目标路径
3. 确认是否有写入权限

### Q5: 生成 Lua 代码失败，提示编码错误

**原因**: Lua 代码必须使用 ASCII 编码，但数据中包含非 ASCII 字符。

**解决方案**:

1. 检查数据中是否包含非 ASCII 字符
2. 将非 ASCII 字符转换为 ASCII 字符或移除
3. 重新生成

### Q6: CSV 文件读取失败，提示编码错误

**原因**: CSV 文件必须使用 GB2312 编码。

**解决方案**:

1. 使用文本编辑器打开 CSV 文件
2. 将文件编码转换为 GB2312
3. 保存文件
4. 重新加载

### Q7: 如何查看详细错误信息？

**解决方案**:

1. 查看程序输出窗口的错误信息
2. 查看 `error.log` 文件（如果存在）
3. 查看 `onekeymake.log` 文件

### Q8: 如何批量更新所有配置？

**解决方案**:

使用 CoderUse 模式：

1. 在配置文件中启用 CoderUse 模式：

```ini
[Config]
CoderUse=true
AutoMake=true
```

2. 运行 ExcelParse2.exe
3. 程序会自动执行一键生成并关闭

---

## 7. 下一步

恭喜您完成了 ExcelParse2 的快速入门！接下来，您可以：

1. **深入学习配置**: 阅读 [04-配置指南-Configuration-Guide.md](04-配置指南-Configuration-Guide.md)
2. **了解数据格式**: 阅读 [06-数据格式规范-Data-Format-Specification.md](06-数据格式规范-Data-Format-Specification.md)
3. **学习 Bean 定义**: 阅读 [07-Bean定义指南-Bean-Definition-Guide.md](07-Bean定义指南-Bean-Definition-Guide.md)
4. **查看完整用户指南**: 阅读 [05-用户指南-User-Guide.md](05-用户指南-User-Guide.md)

---

## 附录

### A. 相关文档

- [00-文档索引-Documentation-Index.md](00-文档索引-Documentation-Index.md) - 文档导航索引
- [04-配置指南-Configuration-Guide.md](04-配置指南-Configuration-Guide.md) - 配置指南
- [10-故障排查指南-Troubleshooting-Guide.md](10-故障排查指南-Troubleshooting-Guide.md) - 故障排查指南

### B. 核心代码文件

- [`MainWindow.xaml.cs`](../MainWindow.xaml.cs) - 主窗口逻辑 (2721行)
- [`DataManager.cs`](../DataManager.cs) - 数据管理器 (577行)
- [`DefineManager.cs`](../DefineManager.cs) - Bean 定义管理器 (315行)

### C. 配置文件

- [`ExcelParseOption2.ini`](../ExcelParseOption2.ini) - 主配置文件

---

**维护者**: 技术委员会
**下次审查**: 2026-03-20
**许可证**: 内部使用

# ExcelParse2 配置指南

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术委员会

---

## 目录

- [1. 配置文件概述](#1-配置文件概述)
- [2. 源数据路径配置](#2-源数据路径配置)
- [3. 目标数据路径配置](#3-目标数据路径配置)
- [4. 其他配置项](#4-其他配置项)
- [5. 相对路径解析规则](#5-相对路径解析规则)
- [6. CoderUse 模式](#6-coderuse-模式)
- [7. 配置示例](#7-配置示例)
- [8. 最佳实践](#8-最佳实践)
- [9. 常见问题](#9-常见问题)

---

## 1. 配置文件概述

### 1.1 配置文件位置

ExcelParse2 使用 [`ExcelParseOption2.ini`](../ExcelParseOption2.ini) 作为配置文件，该文件必须位于程序运行目录。

```
tools/ExcelParse2/bin/Release/ExcelParseOption2.ini
```

### 1.2 配置文件格式

配置文件使用 INI 格式，由多个节（Section）和键值对（Key=Value）组成。

```ini
[SectionName]
KeyName=Value
```

### 1.3 配置文件加载

程序启动时，通过以下代码加载配置文件：

```csharp
// MainWindow.xaml.cs:61
public static ToolsIni mOptionIni = new ToolsIni("ExcelParseOption2.ini");
```

配置文件读取逻辑在 [`GetConfigPath()`](../MainWindow.xaml.cs:151) 方法中：

```csharp
// MainWindow.xaml.cs:151-181
private void GetConfigPath()
{
    mSrcDataXlsPath = mOptionIni.FindAndAddApp("SrcDataXlsPath", "Path").FindAndAddItem("Path").GetValue();
    mSrcDataCsvPath = mOptionIni.FindAndAddApp("SrcDataCsvPath", "Path").FindAndAddItem("Path").GetValue();
    mSrcDataTxtPath = mOptionIni.FindAndAddApp("SrcDataTxtPath", "Path").FindAndAddItem("Path").GetValue();
    mSrcDataDefXmlPath = mOptionIni.FindAndAddApp("SrcDataDefXmlPath", "Path").FindAndAddItem("Path").GetValue();
    mDstClientBinDataPath = mOptionIni.FindAndAddApp("DstClientBinDataPath", "Path").FindAndAddItem("Path").GetValue();
    mDstClientXmlDataPath = mOptionIni.FindAndAddApp("DstClientXmlDataPath", "Path").FindAndAddItem("Path").GetValue();
    mDstServerXmlDataPath = mOptionIni.FindAndAddApp("DstServerXmlDataPath", "Path").FindAndAddItem("Path").GetValue();
    if (mOptionIni.FindAndAddApp("DstServerXmlDataPath", "ManualConfig").FindAndAddItem("ManualConfig").GetValue() == "true")
        mManualConfig = true;
    mDstClientCppPath = mOptionIni.FindAndAddApp("DstClientCppPath", "Path").FindAndAddItem("Path").GetValue();
    mDstClientLuaPath = mOptionIni.FindAndAddApp("DstClientLuaPath", "Path").FindAndAddItem("Path").GetValue();
    mDstClientPkgPath = mOptionIni.FindAndAddApp("DstClientPkgPath", "Path").FindAndAddItem("Path").GetValue();
    mDstServerJavaPath = mOptionIni.FindAndAddApp("DstServerJavaPath", "Path").FindAndAddItem("Path").GetValue();
    mHostroyBeans = mOptionIni.FindAndAddApp("Hostroy", "Record").FindAndAddItem("Record").GetValue();
    mAutoMake = mOptionIni.FindAndAddApp("Config", "AutoMake").FindAndAddItem("AutoMake").GetValue();
    string programUse = mOptionIni.FindAndAddApp("Config", "CoderUse").FindAndAddItem("CoderUse").GetValue();
    string SelectFileType = mOptionIni.FindAndAddApp("Config", "SelectFileType").FindAndAddItem("SelectFileType").GetValue();
    string SelectSortType = mOptionIni.FindAndAddApp("Config", "SelectSortType").FindAndAddItem("SelectSortType").GetValue();
    mSortListIndex = int.Parse(SelectSortType);
    if(programUse=="true")
    {
        setProgramUse();
        m_btn11.IsChecked = true;
    }
    else
    {
        m_btn11.IsChecked = false;
    }
}
```

---

## 2. 源数据路径配置

### 2.1 Excel 源路径

**配置节**: `[SrcDataXlsPath]`

**配置项**: `Path`

**说明**: Excel 源文件路径，支持 `.xlsx` 和 `.xlsm` 格式。

**示例**:

```ini
[SrcDataXlsPath]
Path=..\..\..\gbeans\xls
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:32
public static string mSrcDataXlsPath = "";
```

### 2.2 CSV 源路径

**配置节**: `[SrcDataCsvPath]`

**配置项**: `Path`

**说明**: CSV 源文件路径，文件必须使用 GB2312 编码。

**示例**:

```ini
[SrcDataCsvPath]
Path=..\..\..\gbeans\csv
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:33
public static string mSrcDataCsvPath = "";
```

### 2.3 TXT 源路径

**配置节**: `[SrcDataTxtPath]`

**配置项**: `Path`

**说明**: TXT 源文件路径，文件必须使用 CSV 格式和 GB2312 编码。

**示例**:

```ini
[SrcDataTxtPath]
Path=..\..\..\gbeans\txt
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:34
public static string mSrcDataTxtPath = "";
```

### 2.4 Bean 定义 XML 路径

**配置节**: `[SrcDataDefXmlPath]`

**配置项**: `Path`

**说明**: Bean 定义 XML 文件路径，包含所有 Bean 的定义信息。

**示例**:

```ini
[SrcDataDefXmlPath]
Path=..\..\..\gbeans\def
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:35
public static string mSrcDataDefXmlPath = "";
```

**加载逻辑**:

```csharp
// MainWindow.xaml.cs:183-195
private bool LoadDataDef()
{
    mDefineMgr.Clear();
    List<string> files = MainWindow.GetFiles(mSrcDataDefXmlPath, "*.xml");
    for(int i = 0; i < files.Count; i++)
    {
        if(!mDefineMgr.loadDefFromFile(files[i]))
        {
            return false;
        }
    }
    return true;
}
```

---

## 3. 目标数据路径配置

### 3.1 客户端二进制数据路径

**配置节**: `[DstClientBinDataPath]`

**配置项**: `Path`

**说明**: 客户端二进制数据输出路径。

**示例**:

```ini
[DstClientBinDataPath]
Path=..\..\..\client\resource\bin
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:36
public static string mDstClientBinDataPath = "";
```

### 3.2 客户端 XML 数据路径

**配置节**: `[DstClientXmlDataPath]`

**配置项**: `Path`

**说明**: 客户端 XML 数据输出路径。

**示例**:

```ini
[DstClientXmlDataPath]
Path=..\..\..\client\resource\xml
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:37
public static string mDstClientXmlDataPath = "";
```

### 3.3 服务器 XML 数据路径

**配置节**: `[DstServerXmlDataPath]`

**配置项**: `Path`

**说明**: 服务器 XML 数据输出路径。

**示例**:

```ini
[DstServerXmlDataPath]
Path=..\..\..\server\server\data\xml
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:39
public static string mDstServerXmlDataPath = "";
```

### 3.4 服务器手动配置

**配置节**: `[DstServerXmlDataPath]`

**配置项**: `ManualConfig`

**说明**: 是否使用手动配置模式。

**可选值**: `true`/`false`

**示例**:

```ini
[DstServerXmlDataPath]
Path=..\..\..\server\server\data\xml
ManualConfig=false
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:160-161
if (mOptionIni.FindAndAddApp("DstServerXmlDataPath", "ManualConfig").FindAndAddItem("ManualConfig").GetValue() == "true")
    mManualConfig = true;
```

### 3.5 客户端 C++ 代码路径

**配置节**: `[DstClientCppPath]`

**配置项**: `Path`

**说明**: 客户端 C++ 代码输出路径。

**示例**:

```ini
[DstClientCppPath]
Path=..\..\..\client\FireClient\src
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:41
public static string mDstClientCppPath = "";
```

### 3.6 客户端 Lua 代码路径

**配置节**: `[DstClientLuaPath]`

**配置项**: `Path`

**说明**: 客户端 Lua 代码输出路径。

**示例**:

```ini
[DstClientLuaPath]
Path=..\..\..\client\resource\lua
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:42
public static string mDstClientLuaPath = "";
```

### 3.7 客户端 PKG 文件路径

**配置节**: `[DstClientPkgPath]`

**配置项**: `Path`

**说明**: 客户端 PKG 文件输出路径。

**示例**:

```ini
[DstClientPkgPath]
Path=..\..\..\client\tolua++-pkgs
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:43
public static string mDstClientPkgPath = "";
```

### 3.8 服务器 Java 代码路径

**配置节**: `[DstServerJavaPath]`

**配置项**: `Path`

**说明**: 服务器 Java 代码输出路径。

**示例**:

```ini
[DstServerJavaPath]
Path=..\..\..\server\server\src
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:40
public static string mDstServerJavaPath = "";
```

---

## 4. 其他配置项

### 4.1 历史 Bean 记录

**配置节**: `[Hostroy]`

**配置项**: `Record`

**说明**: 历史 Bean 记录，用于单表导出模式。多个 Bean 名称使用逗号分隔。

**示例**:

```ini
[Hostroy]
Record=ItemBean,MonsterBean,NPCBean
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:44
public static string mHostroyBeans = "";
```

**使用逻辑**:

```csharp
// MainWindow.xaml.cs:217-229
List<string> beanList = MainWindow.stovs(MainWindow.mHostroyBeans, ',');
for (int i = 0; i < beanList.Count; i++)
{
    string beanName = beanList[i];
    BeanDef beanDef;
    if(mDefineMgr.GetBeanFromBeanName(out beanDef, beanName))
    {
        List<string> listDataFiles = stovs(beanDef.from, ',');
        for(int j = 0; j < listDataFiles.Count; j++)
        {
            string xlsFileName = listDataFiles[j];
            string xlsFilePathName = strAbsDataPath + "\\" + xlsFileName;
            string strxlsFilePath = ConverPath(xlsFilePathName);
            // 加载数据文件
        }
    }
}
```

### 4.2 自动生成

**配置节**: `[Config]`

**配置项**: `AutoMake`

**说明**: 是否启用自动生成模式。

**可选值**: `true`/`false`

**示例**:

```ini
[Config]
AutoMake=false
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:45
public static string mAutoMake = "false";
```

### 4.3 CoderUse 模式

**配置节**: `[Config]`

**配置项**: `CoderUse`

**说明**: 是否启用 CoderUse 模式（程序化使用）。

**可选值**: `true`/`false`

**示例**:

```ini
[Config]
CoderUse=false
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:168-180
string programUse = mOptionIni.FindAndAddApp("Config", "CoderUse").FindAndAddItem("CoderUse").GetValue();
if(programUse=="true")
{
    setProgramUse();
    m_btn11.IsChecked = true;
}
else
{
    m_btn11.IsChecked = false;
}
```

### 4.4 文件类型选择

**配置节**: `[Config]`

**配置项**: `SelectFileType`

**说明**: 选择源数据文件类型。

**可选值**:
- `0`: Excel (.xlsx, .xlsm)
- `1`: CSV
- `2`: TXT

**示例**:

```ini
[Config]
SelectFileType=0
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:169
string SelectFileType = mOptionIni.FindAndAddApp("Config", "SelectFileType").FindAndAddItem("SelectFileType").GetValue();
```

**使用逻辑**:

```csharp
// MainWindow.xaml.cs:230-247
if (mSelectFileType == 0)
{
    if (ToolsFile.FileExists(strxlsFilePath + ".xlsx"))
    {
        if (!mDataMgr.loadXlsFile(strxlsFilePath + ".xlsx"))
        {
            return false;
        }
    }
    else
    {
        if (!mDataMgr.loadXlsFile(strxlsFilePath + ".xlsm"))
        {
            return false;
        }
    }
}
else if (mSelectFileType == 1)
{
    // CSV 文件
}
else if (mSelectFileType == 2)
{
    // TXT 文件
}
```

### 4.5 排序类型选择

**配置节**: `[Config]`

**配置项**: `SelectSortType`

**说明**: 选择排序类型。

**可选值**: 整数（0-9）

**示例**:

```ini
[Config]
SelectSortType=0
```

**代码引用**:

```csharp
// MainWindow.xaml.cs:50,170-171
public static int mSortListIndex = 0;
string SelectSortType = mOptionIni.FindAndAddApp("Config", "SelectSortType").FindAndAddItem("SelectSortType").GetValue();
mSortListIndex = int.Parse(SelectSortType);
```

---

## 5. 相对路径解析规则

### 5.1 路径格式

配置文件中的路径支持以下格式：

```yaml
相对路径：
  - ..\\ 表示上级目录
  - .\\ 表示当前目录
  - 直接路径名表示相对于程序运行目录

绝对路径：
  - 完整的文件系统路径
  - Windows: D:\\MT3\\gbeans\\xls
  - UNC: \\\\server\\share\\path
```

### 5.2 路径解析示例

#### 示例 1：相对路径

```ini
[SrcDataXlsPath]
Path=..\..\..\gbeans\xls
```

**解析结果**:

```
程序运行目录: D:\MT3\tools\ExcelParse2\bin\Release
解析后路径: D:\MT3\gbeans\xls
```

#### 示例 2：当前目录

```ini
[SrcDataXlsPath]
Path=.\data
```

**解析结果**:

```
程序运行目录: D:\MT3\tools\ExcelParse2\bin\Release
解析后路径: D:\MT3\tools\ExcelParse2\bin\Release\data
```

#### 示例 3：绝对路径

```ini
[SrcDataXlsPath]
Path=D:\MT3\gbeans\xls
```

**解析结果**:

```
程序运行目录: D:\MT3\tools\ExcelParse2\bin\Release
解析后路径: D:\MT3\gbeans\xls
```

### 5.3 路径解析逻辑

程序使用以下逻辑解析路径：

```csharp
// 伪代码
string GetAbsDataPath(string relativePath)
{
    // 获取程序运行目录
    string baseDir = AppDomain.CurrentDomain.BaseDirectory;
    
    // 检查是否是绝对路径
    if (Path.IsPathRooted(relativePath))
    {
        return relativePath;
    }
    
    // 处理相对路径
    string fullPath = Path.Combine(baseDir, relativePath);
    
    // 规范化路径
    fullPath = Path.GetFullPath(fullPath);
    
    return fullPath;
}
```

### 5.4 路径验证

程序在加载配置后会验证路径是否存在：

```csharp
// 伪代码
bool ValidatePath(string path)
{
    // 检查路径是否存在
    if (!Directory.Exists(path))
    {
        MainWindow.Error("路径不存在: " + path);
        return false;
    }
    
    // 检查是否有读取权限
    try
    {
        Directory.GetFiles(path);
        return true;
    }
    catch (UnauthorizedAccessException)
    {
        MainWindow.Error("无权限访问路径: " + path);
        return false;
    }
}
```

---

## 6. CoderUse 模式

### 6.1 模式概述

CoderUse 模式用于程序化使用 ExcelParse2，无需人工干预。适用于构建脚本、CI/CD 流程等场景。

### 6.2 启用 CoderUse 模式

在配置文件中设置：

```ini
[Config]
CoderUse=true
AutoMake=true
```

### 6.3 CoderUse 模式行为

启用 CoderUse 模式后，程序会执行以下操作：

1. 启动程序
2. 自动执行一键生成
3. 生成完成后自动关闭程序
4. 生成日志保存到 `onekeymake.log`
5. 错误日志保存到 `error.log`（仅在生成失败时生成）

### 6.4 一键生成流程

```csharp
// MainWindow.xaml.cs:72-134
private void AutoMake()
{
    mMakeError = false;
    mExportSingleTable = false;
    
    // 1. 加载定义
    if (LoadDataDef()
        // 2. 加载所有数据
        && LoadAllData()
        // 3. 生成客户端数据
        && MakeClientData(true, true, true, true)
        // 4. 生成服务器数据
        && MakeServerData(true, true)
        // 5. 生成客户端代码
        && MakeClientCode()
        )
    {
        Info("一键数据和代码生成成功！");
    }

    // 6. 生成日志文件
    try
    {
        File.Delete("onekeymake.log");
        FileStream fs = File.Open("onekeymake.log", FileMode.CreateNew, FileAccess.Write);
        if (fs != null)
        {
            StreamWriter sw = new StreamWriter(fs, Encoding.UTF8);
            sw.AutoFlush = true;
            if (sw != null)
            {
                for (int i = 0; i < getInstance().mOutputText.Items.Count; ++i)
                {
                    sw.Write(getInstance().mOutputText.Items[i]);
                    sw.Write("\n");
                }
                sw.Close();
            }
            fs.Close();
        }
    }
    catch (System.Exception e2)
    {
        Error("创建文件 onekeymake.log 时失败！异常信息=" + e2.Message);
    }
    
    // 7. 生成错误日志
    try
    {
        if (mMakeError)
        {
            FileStream fs = File.Open("error.log", FileMode.CreateNew);
            if (fs != null)
            {
                StreamWriter sw = new StreamWriter(fs, Encoding.ASCII);
                sw.AutoFlush = true;
                if (sw != null)
                {
                    sw.Write("hello world!");
                }
                sw.Close();
            }
            fs.Close();
        }
    }
    catch (System.Exception)
    {
    }
}
```

### 6.5 使用示例

#### 构建脚本示例

```batch
@echo off
REM 进入 ExcelParse2 目录
cd tools\ExcelParse2\bin\Release

REM 运行 ExcelParse2（CoderUse 模式）
ExcelParse2.exe

REM 检查错误日志
if exist error.log (
    echo 生成失败！
    type error.log
    exit /b 1
) else (
    echo 生成成功！
    exit /b 0
)
```

#### PowerShell 脚本示例

```powershell
# 进入 ExcelParse2 目录
cd tools\ExcelParse2\bin\Release

# 运行 ExcelParse2（CoderUse 模式）
Start-Process -FilePath "ExcelParse2.exe" -Wait

# 检查错误日志
if (Test-Path "error.log") {
    Write-Host "生成失败！" -ForegroundColor Red
    Get-Content "error.log"
    exit 1
} else {
    Write-Host "生成成功！" -ForegroundColor Green
    exit 0
}
```

---

## 7. 配置示例

### 7.1 完整配置示例

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
Record=ItemBean,MonsterBean,NPCBean

[Config]
AutoMake=false
CoderUse=false
SelectFileType=0
SelectSortType=0
```

### 7.2 最小配置示例

```ini
[SrcDataXlsPath]
Path=..\..\..\gbeans\xls

[SrcDataDefXmlPath]
Path=..\..\..\gbeans\def

[DstClientBinDataPath]
Path=..\..\..\client\resource\bin

[DstServerXmlDataPath]
Path=..\..\..\server\server\data\xml

[Config]
AutoMake=false
CoderUse=false
SelectFileType=0
SelectSortType=0
```

### 7.3 CoderUse 模式配置示例

```ini
[SrcDataXlsPath]
Path=..\..\..\gbeans\xls

[SrcDataDefXmlPath]
Path=..\..\..\gbeans\def

[DstClientBinDataPath]
Path=..\..\..\client\resource\bin

[DstServerXmlDataPath]
Path=..\..\..\server\server\data\xml

[Config]
AutoMake=true
CoderUse=true
SelectFileType=0
SelectSortType=0
```

---

## 8. 最佳实践

### 8.1 路径配置最佳实践

#### 使用相对路径

```ini
# 推荐：使用相对路径
[SrcDataXlsPath]
Path=..\..\..\gbeans\xls

# 不推荐：使用绝对路径
[SrcDataXlsPath]
Path=D:\MT3\gbeans\xls
```

**原因**: 相对路径更灵活，便于项目迁移和团队协作。

#### 路径分隔符

```ini
# 推荐：使用双反斜杠
Path=..\..\..\gbeans\xls

# 不推荐：使用单反斜杠
Path=..\..\..\gbeans\xls
```

**原因**: INI 文件中，单反斜杠可能被误认为转义字符。

### 8.2 配置文件管理最佳实践

#### 版本控制

将配置文件纳入版本控制：

```git
# .gitignore
# 不要忽略配置文件
# ExcelParseOption2.ini

# 可以忽略日志文件
onekeymake.log
error.log
```

#### 团队协作

为不同环境创建不同的配置文件：

```
tools/ExcelParse2/
├── ExcelParseOption2.ini          # 默认配置
├── ExcelParseOption2.dev.ini      # 开发环境配置
├── ExcelParseOption2.test.ini     # 测试环境配置
└── ExcelParseOption2.prod.ini     # 生产环境配置
```

使用时复制对应的配置文件：

```batch
REM 使用开发环境配置
copy ExcelParseOption2.dev.ini ExcelParseOption2.ini
ExcelParse2.exe
```

### 8.3 CoderUse 模式最佳实践

#### CI/CD 集成

在 CI/CD 流程中使用 CoderUse 模式：

```yaml
# .gitlab-ci.yml
stages:
  - build
  - generate

generate_data:
  stage: generate
  script:
    - cd tools/ExcelParse2/bin/Release
    - copy ExcelParseOption2.prod.ini ExcelParseOption2.ini
    - ExcelParse2.exe
    - if exist error.log exit /b 1
  artifacts:
    paths:
      - client/resource/bin/
      - server/server/data/xml/
    expire_in: 1 week
```

#### 错误处理

在构建脚本中添加错误处理：

```batch
@echo off
cd tools\ExcelParse2\bin\Release
copy ExcelParseOption2.prod.ini ExcelParseOption2.ini
ExcelParse2.exe

if %ERRORLEVEL% NEQ 0 (
    echo ExcelParse2 执行失败！
    exit /b 1
)

if exist error.log (
    echo 数据生成失败！
    type error.log
    exit /b 1
)

echo 数据生成成功！
exit /b 0
```

---

## 9. 常见问题

### Q1: 配置文件修改后不生效？

**原因**: 程序可能缓存了配置文件。

**解决方案**:

1. 重启程序
2. 确认配置文件路径正确
3. 检查配置文件格式是否正确

### Q2: 相对路径解析错误？

**原因**: 路径分隔符使用错误或路径格式不正确。

**解决方案**:

1. 使用双反斜杠 `..\\` 而不是单反斜杠 `..\`
2. 确认路径相对于程序运行目录
3. 使用绝对路径进行测试

### Q3: CoderUse 模式不自动关闭？

**原因**: 可能是 `AutoMake` 未设置为 `true`。

**解决方案**:

```ini
[Config]
CoderUse=true
AutoMake=true  # 必须设置为 true
```

### Q4: 如何调试配置文件？

**解决方案**:

1. 查看程序输出窗口的错误信息
2. 查看 `onekeymake.log` 文件
3. 使用绝对路径进行测试

### Q5: 配置文件中的特殊字符如何处理？

**解决方案**:

- 路径中的空格：不需要特殊处理
- 路径中的特殊字符：使用引号包裹

```ini
# 路径中包含空格
[SrcDataXlsPath]
Path=..\..\..\gbeans\my data\xls

# 路径中包含特殊字符（如果需要）
[SrcDataXlsPath]
Path="..\..\..\gbeans\my-data\xls"
```

---

## 附录

### A. 相关文档

- [00-文档索引-Documentation-Index.md](00-文档索引-Documentation-Index.md) - 文档导航索引
- [03-快速开始-Quick-Start.md](03-快速开始-Quick-Start.md) - 快速开始指南
- [10-故障排查指南-Troubleshooting-Guide.md](10-故障排查指南-Troubleshooting-Guide.md) - 故障排查指南

### B. 配置文件模板

#### 模板 1：开发环境

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

#### 模板 2：生产环境

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
AutoMake=true
CoderUse=true
SelectFileType=0
SelectSortType=0
```

### C. 核心代码文件

- [`MainWindow.xaml.cs`](../MainWindow.xaml.cs) - 主窗口逻辑 (2721行)
- [`DataManager.cs`](../DataManager.cs) - 数据管理器 (577行)
- [`DefineManager.cs`](../DefineManager.cs) - Bean 定义管理器 (315行)

### D. 配置文件

- [`ExcelParseOption2.ini`](../ExcelParseOption2.ini) - 主配置文件

---

**维护者**: 技术委员会
**下次审查**: 2026-03-20
**许可证**: 内部使用

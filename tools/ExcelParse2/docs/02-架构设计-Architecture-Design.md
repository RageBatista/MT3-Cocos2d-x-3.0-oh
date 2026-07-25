# 02-架构设计-Architecture-Design

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术委员会
> **目标**: 详细介绍 ExcelParse2 项目的架构设计

---

## 目录

- [1. 整体架构](#1-整体架构)
- [2. 模块依赖关系](#2-模块依赖关系)
- [3. 类图](#3-类图)
- [4. 数据流图](#4-数据流图)
- [5. 关键设计模式](#5-关键设计模式)
- [6. 性能考虑](#6-性能考虑)
- [7. 线程安全](#7-线程安全)
- [8. 扩展点](#8-扩展点)
- [9. 参考资料](#9-参考资料)

---

## 1. 整体架构

### 1.1 三层架构

ExcelParse2 采用经典的三层架构设计：

```
┌─────────────────────────────────────────────────────────┐
│  Layer 3: UI 层 (Presentation Layer)                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │  MainWindow.xaml (UI 定义)                       │  │
│  │  MainWindow.xaml.cs (UI 逻辑, 2721行)            │  │
│  │  SelectXlsDlg.xaml (对话框 UI)                   │  │
│  │  SelectXlsDlg.xaml.cs (对话框逻辑)               │  │
│  │                                                  │  │
│  │  职责:                                           │  │
│  │  - 提供用户界面                                  │  │
│  │  - 处理用户交互                                  │  │
│  │  - 显示进度信息                                  │  │
│  │  - 输出日志信息                                  │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│  Layer 2: 业务逻辑层 (Business Layer)                   │
│  ┌──────────────────────────────────────────────────┐  │
│  │  DataManager.cs (数据管理器, 577行)             │  │
│  │  DefineManager.cs (Bean 定义管理器, 315行)      │  │
│  │  ServerBeanData.cs (服务器 Bean 数据)           │  │
│  │  ServerBeanNode.cs (服务器 Bean 节点, 358行)    │  │
│  │  OneKeyMakeCache.cs (缓存管理)                   │  │
│  │  OneKeyMakeReport.cs (报告管理)                  │  │
│  │  SafeFileWrite.cs (安全文件写入)                 │  │
│  │                                                  │  │
│  │  职责:                                           │  │
│  │  - 加载 Excel/CSV/TXT 数据                       │  │
│  │  - 加载 Bean 定义                                │  │
│  │  - 验证数据完整性                                │  │
│  │  - 生成二进制/XML 数据                           │  │
│  │  - 生成 Java/C++/Lua 代码                        │  │
│  │  - 管理缓存和报告                                │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│  Layer 1: 数据层 (Data Layer)                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  输入数据:                                       │  │
│  │  - Excel 文件 (.xls/.xlsx)                       │  │
│  │  - CSV 文件 (.csv)                               │  │
│  │  - TXT 文件 (.txt)                               │  │
│  │  - Bean 定义文件 (.xml)                          │  │
│  │  - 配置文件 (.ini)                               │  │
│  │                                                  │  │
│  │  输出数据:                                       │  │
│  │  - 二进制文件 (.bin)                             │  │
│  │  - XML 文件 (.xml)                               │  │
│  │  - Java 代码 (.java)                             │  │
│  │  - C++ 代码 (.cpp/.h)                            │  │
│  │  - Lua 代码 (.lua)                               │  │
│  │  - PKG 文件 (.pkg)                               │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 1.2 架构优势

| 优势 | 说明 |
|------|------|
| **分层清晰** | UI、业务逻辑、数据分离，职责明确 |
| **易于维护** | 每层独立修改，不影响其他层 |
| **易于测试** | 业务逻辑层可独立测试 |
| **易于扩展** - 可添加新的数据格式和代码生成模板 |
| **代码复用** | 业务逻辑层可被多个 UI 复用 |

---

## 2. 模块依赖关系

### 2.1 模块依赖图

```
┌─────────────────────────────────────────────────────────┐
│                    MainWindow                           │
│                  (UI 交互层)                             │
└────────┬────────────────────────────────────────────┬──┘
         │                                            │
         ├──────────────┬──────────────┬──────────────┤
         │              │              │              │
         ▼              ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ DataManager  │ │DefineManager │ │OneKeyMakeCache│ │OneKeyMakeReport│
│              │ │              │ │              │ │              │
│ 数据加载     │ │ Bean 定义    │ │ 缓存管理     │ │ 报告管理     │
│ 数据验证     │ │ 定义管理     │ │ 增量生成     │ │ 日志记录     │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │                │
       │                │                │                │
       └────────────────┼────────────────┘                │
                        │                                 │
                        ▼                                 │
               ┌──────────────┐                          │
               │ServerBeanData │                          │
               │              │                          │
               │ 服务器数据   │                          │
               └──────┬───────┘                          │
                      │                                 │
                      ▼                                 │
               ┌──────────────┐                          │
               │ServerBeanNode │                          │
               │              │                          │
               │ Bean 数据树  │                          │
               └──────────────┘                          │
                                                         │
┌─────────────────────────────────────────────────────────┤
│                    SafeFileWrite                        │
│                  (安全文件写入)                          │
└─────────────────────────────────────────────────────────┘
```

### 2.2 模块说明

#### MainWindow (主窗口)

**文件**: [`MainWindow.xaml.cs`](../MainWindow.xaml.cs:1) (2721行)

**职责**:
- 提供用户界面
- 处理用户交互
- 协调各个模块
- 显示进度和日志

**关键方法**:
- `LoadDataDef()` - 加载 Bean 定义
- `LoadAllData()` - 加载所有数据
- `MakeClientData()` - 生成客户端数据
- `MakeServerData()` - 生成服务器数据
- `MakeClientCode()` - 生成客户端代码

#### DataManager (数据管理器)

**文件**: [`DataManager.cs`](../DataManager.cs:1) (577行)

**职责**:
- 加载 Excel/CSV/TXT 数据
- 验证数据完整性
- 管理数据索引

**关键类**:
- `XlsData` - Excel 数据封装

**关键方法**:
- `LoadXls()` - 加载 Excel 文件
- `LoadCsv()` - 加载 CSV 文件
- `LoadTxt()` - 加载 TXT 文件
- `ValidateData()` - 验证数据

#### DefineManager (Bean 定义管理器)

**文件**: [`DefineManager.cs`](../DefineManager.cs:1) (315行)

**职责**:
- 加载 Bean 定义
- 管理 Bean 定义
- 提供 Bean 定义查询

**关键类**:
- `BeanDef` - Bean 定义
- `BeanCol` - 列定义
- `BeanSubCol` - 子列定义

**关键方法**:
- `LoadBeanDef()` - 加载 Bean 定义
- `GetBeanDef()` - 获取 Bean 定义
- `GetColCheckNumber()` - 获取列版本号

#### ServerBeanData (服务器 Bean 数据)

**文件**: [`ServerBeanData.cs`](../ServerBeanData.cs:1)

**职责**:
- 存储服务器端数据
- 提供数据访问接口

#### ServerBeanNode (服务器 Bean 节点)

**文件**: [`ServerBeanNode.cs`](../ServerBeanNode.cs:1) (358行)

**职责**:
- 构建 Bean 数据树
- 支持 Bean 继承
- 支持数组类型

**关键枚举**:
- `SBNStyle` - 节点类型 (Error, BaseAttrib, BeanAttrib, BaseArray, BeanArray)

**关键方法**:
- `SetupDef()` - 设置节点定义
- `GetBeanDef()` - 获取 Bean 定义

#### OneKeyMakeCache (缓存管理)

**文件**: [`OneKeyMakeCache.cs`](../OneKeyMakeCache.cs:1)

**职责**:
- 管理生成缓存
- 支持增量生成
- 提高生成性能

#### OneKeyMakeReport (报告管理)

**文件**: [`OneKeyMakeReport.cs`](../OneKeyMakeReport.cs:1)

**职责**:
- 生成生成报告
- 记录生成日志
- 统计生成结果

#### SafeFileWrite (安全文件写入)

**文件**: [`SafeFileWrite.cs`](../SafeFileWrite.cs:1)

**职责**:
- 原子性文件写入
- 避免数据损坏
- 支持回滚

---

## 3. 类图

### 3.1 核心类关系图

```
┌─────────────────────────────────────────────────────────┐
│                     MainWindow                          │
│  - mDefineMgr: DefineManager                            │
│  - mDataMgr: DataManager                                │
│  - mOptionIni: ToolsIni                                 │
│  + LoadDataDef(): bool                                   │
│  + LoadAllData(): bool                                   │
│  + MakeClientData(): bool                                │
│  + MakeServerData(): bool                                │
│  + MakeClientCode(): bool                                │
└────────┬────────────────────────────────────────────────┘
         │
         ├─────────────────┬─────────────────┐
         │                 │                 │
         ▼                 ▼                 ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ DefineManager   │ │ DataManager     │ │ OneKeyMakeCache │
│  - mBeanDefs:   │ │  - mXlsDataList:│ │  - mCache:      │
│    Dictionary   │ │    List<XlsData>│ │    Dictionary   │
│  + LoadBeanDef():│ │  + LoadXls():    │ │  + LoadCache(): │
│    bool         │ │    bool         │ │    bool         │
│  + GetBeanDef(): │ │  + LoadCsv():    │ │  + SaveCache(): │
│    bool         │ │    bool         │ │    bool         │
└────────┬────────┘ └────────┬────────┘ └─────────────────┘
         │                  │
         │                  │
         ▼                  ▼
┌─────────────────┐ ┌─────────────────┐
│ BeanDef         │ │ XlsData         │
│  - name: string │ │  - mData:       │
│  - from: string │ │    List<string> │
│  - cols: List<  │ │  - mTitleIndex: │
│    BeanCol>     │ │    Dictionary  │
│  + GetCol():    │ │  - mIdIndex:    │
│    bool         │ │    Dictionary  │
│  + GetIdColIndex│ │  + GetXlsData():│
│    (): bool     │ │    bool         │
└────────┬────────┘ └─────────────────┘
         │
         │
         ▼
┌─────────────────┐
│ BeanCol         │
│  - name: string │
│  - type: string │
│  - fromCol:     │
│    string       │
│  - subCols:     │
│    List<        │
│    BeanSubCol>  │
└─────────────────┘

┌─────────────────┐
│ ServerBeanNode  │
│  - mParentNode: │
│    ServerBeanNode│
│  - mStyle:      │
│    SBNStyle     │
│  - mType: string│
│  - mName: string│
│  - mNodes: List<│
│    ServerBeanNode>│
│  + SetupDef():  │
│    bool         │
│  + GetBeanDef():│
│    bool         │
└─────────────────┘
```

### 3.2 类详细说明

#### MainWindow 类

```csharp
public partial class MainWindow : Window
{
    // 路径配置
    public static string mSrcDataXlsPath = "";
    public static string mSrcDataCsvPath = "";
    public static string mSrcDataTxtPath = "";
    public static string mSrcDataDefXmlPath = "";
    public static string mDstClientBinDataPath = "";
    public static string mDstClientXmlDataPath = "";
    public static string mDstServerXmlDataPath = "";
    public static string mDstServerJavaPath = "";
    public static string mDstClientCppPath = "";
    public static string mDstClientLuaPath = "";
    public static string mDstClientPkgPath = "";

    // 数据管理
    public static DefineManager mDefineMgr = new DefineManager();
    public static DataManager mDataMgr = new DataManager();

    // 配置文件
    public static ToolsIni mOptionIni = new ToolsIni("ExcelParseOption2.ini");

    // 实例
    public static MainWindow mInstance = null;

    // 文件版本号
    public static ushort mBinFileVersion = 101;
}
```

#### DataManager 类

```csharp
public class XlsData
{
    public List<string> mData = new List<string>();
    public int rowCount;
    public int colCount;
    public Dictionary<string, int> mTitleIndex = new Dictionary<string, int>();
    public Dictionary<string, string> mTitleCommit = new Dictionary<string, string>();
    public Dictionary<int, int> mIdIndex = new Dictionary<int, int>();
    public string mFileName;

    public bool GetXlsData(out string value, string title, int id, bool outputError = true);
    public bool makeTitleIndexs();
    public bool makeTitleIndexsCsv();
}
```

#### DefineManager 类

```csharp
public class BeanDef
{
    public string name;
    public string from;
    public string genXml;
    public bool makeLua;
    public string baseClass;
    public string priority;
    public string spaceName;
    public List<BeanCol> cols;

    public bool GetCol(out BeanCol beanCol, string colName);
    public bool GetIdColIndex(out string idTitleName);
    public uint GetColCheckNumber();
    public bool isHaveNameValue();
}

public class BeanCol
{
    public string name;
    public string fromCol;
    public string type;
    public string value;
    public string minLimit;
    public string maxLimit;
    public List<BeanSubCol> subCols;
    public string data;
}
```

#### ServerBeanNode 类

```csharp
class ServerBeanNode
{
    public enum SBNStyle
    {
        Error,
        BaseAttrib,
        BeanAttrib,
        BaseArray,
        BeanArray,
    };

    public ServerBeanNode mParentNode;
    public ServerBeanNode mBaseClassNode;
    public List<ServerBeanNode> mNodes = new List<ServerBeanNode>();

    private SBNStyle mStyle = SBNStyle.Error;
    private string mType = "";
    private string mName = "";
    private string mValue = "";
    private string mXlsTitle = "";
    private BeanDef mBeanDef;

    public bool SetupDef(string name, string type, string value, string fromCol);
    public bool GetBeanDef(out BeanDef beanDef);
}
```

---

## 4. 数据流图

### 4.1 数据加载流程

```
用户操作
   │
   ▼
┌──────────────────┐
│ MainWindow       │
│ - LoadDataDef()  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ DefineManager    │
│ - LoadBeanDef()  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 读取 Bean 定义  │
│ (.xml 文件)     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 解析 XML        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 创建 BeanDef     │
│ 对象列表         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ MainWindow       │
│ - LoadAllData()  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ DataManager      │
│ - LoadXls()      │
│ - LoadCsv()      │
│ - LoadTxt()      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 读取数据文件     │
│ (.xls/.csv/.txt) │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 解析数据         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 创建 XlsData     │
│ 对象列表         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 创建标题索引     │
│ (mTitleIndex)    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 创建 ID 索引     │
│ (mIdIndex)       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 验证数据         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 返回加载结果     │
└──────────────────┘
```

### 4.2 数据生成流程

```
用户操作
   │
   ▼
┌──────────────────┐
│ MainWindow       │
│ - MakeClientData()│
│ - MakeServerData()│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ DataManager      │
│ - 生成数据       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 遍历 XlsData     │
│ 对象列表         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 根据数据类型     │
│ 生成不同格式     │
└────────┬─────────┘
         │
    ┌────┴────┬────────┬────────┬────────┐
    │         │        │        │        │
    ▼         ▼        ▼        ▼        ▼
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
│ .bin │ │ .xml │ │ .java│ │ .cpp │ │ .lua │
└──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘
   │        │        │        │        │
   └────────┴────────┴────────┴────────┘
            │
            ▼
┌──────────────────┐
│ SafeFileWrite    │
│ - 安全写入       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ OneKeyMakeCache  │
│ - 更新缓存       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ OneKeyMakeReport │
│ - 生成报告       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 返回生成结果     │
└──────────────────┘
```

### 4.3 代码生成流程

```
用户操作
   │
   ▼
┌──────────────────┐
│ MainWindow       │
│ - MakeClientCode()│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ DataManager      │
│ - 生成代码       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 遍历 BeanDef     │
│ 对象列表         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 创建             │
│ ServerBeanNode   │
│ 数据树           │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 根据代码类型     │
│ 生成不同代码     │
└────────┬─────────┘
         │
    ┌────┴────┬────────┬────────┐
    │         │        │        │
    ▼         ▼        ▼        ▼
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
│ .java│ │ .cpp │ │ .h   │ │ .lua │
└──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘
   │        │        │        │
   └────────┴────────┴────────┘
            │
            ▼
┌──────────────────┐
│ SafeFileWrite    │
│ - 安全写入       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ OneKeyMakeCache  │
│ - 更新缓存       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ OneKeyMakeReport │
│ - 生成报告       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 返回生成结果     │
└──────────────────┘
```

---

## 5. 关键设计模式

### 5.1 单例模式

**应用场景**: [`MainWindow`](../MainWindow.xaml.cs:64)

```csharp
public static MainWindow mInstance = null;

public static MainWindow getInstance()
{
    return mInstance;
}
```

**说明**: MainWindow 使用单例模式，确保整个应用程序只有一个主窗口实例。

### 5.2 工厂模式

**应用场景**: [`ServerBeanNode`](../ServerBeanNode.cs:57)

```csharp
public bool SetupDef(string name, string type, string value, string fromCol)
{
    mStyle = SBNStyle.Error;
    mType = type;
    mName = name;
    mValue = value;
    mXlsTitle = fromCol;

    if (MainWindow.IsBaseType(type))
    {
        mStyle = SBNStyle.BaseAttrib;
    }
    else if (MainWindow.IsBeanType(type))
    {
        mStyle = SBNStyle.BeanAttrib;
        // ...
    }
    else if (MainWindow.IsArrayType(type))
    {
        // ...
    }

    return true;
}
```

**说明**: ServerBeanNode 使用工厂模式，根据类型创建不同类型的节点。

### 5.3 模板方法模式

**应用场景**: [`DataManager`](../DataManager.cs:1)

```csharp
public bool LoadXls(string fileName)
{
    // 1. 打开文件
    // 2. 读取数据
    // 3. 创建索引
    // 4. 验证数据
    // 5. 返回结果
}

public bool LoadCsv(string fileName)
{
    // 1. 打开文件
    // 2. 读取数据
    // 3. 创建索引
    // 4. 验证数据
    // 5. 返回结果
}
```

**说明**: DataManager 使用模板方法模式，不同数据源的加载遵循相同的流程。

### 5.4 策略模式

**应用场景**: [`MainWindow`](../MainWindow.xaml.cs:1)

```csharp
public bool MakeClientData(bool makeBin, bool makeXml, bool makeCpp, bool makeLua)
{
    // 根据参数选择不同的生成策略
    if (makeBin)
    {
        // 生成 .bin 文件
    }
    if (makeXml)
    {
        // 生成 .xml 文件
    }
    if (makeCpp)
    {
        // 生成 .cpp/.h 文件
    }
    if (makeLua)
    {
        // 生成 .lua 文件
    }
}
```

**说明**: MainWindow 使用策略模式，根据用户选择的选项执行不同的生成策略。

---

## 6. 性能考虑

### 6.1 增量生成

**实现**: [`OneKeyMakeCache`](../OneKeyMakeCache.cs:1)

**原理**:
- 记录每个文件的哈希值和时间戳
- 只重新生成修改过的文件
- 显著提高大规模数据生成的性能

**优势**:
- 减少不必要的文件生成
- 提高生成速度
- 降低系统资源占用

### 6.2 缓存机制

**实现**: [`OneKeyMakeCache`](../OneKeyMakeCache.cs:1)

**缓存类型**:
- **数据缓存** - 缓存加载的 Excel 数据
- **定义缓存** - 缓存 Bean 定义
- **生成缓存** - 缓存生成的文件

**优势**:
- 避免重复加载和生成
- 提高响应速度
- 降低内存占用

### 6.3 批量处理

**实现**: [`MainWindow`](../MainWindow.xaml.cs:1)

**原理**:
- 一次加载多个文件
- 一次生成多个文件
- 减少文件 I/O 次数

**优势**:
- 提高处理效率
- 减少系统调用
- 优化资源使用

### 6.4 索引优化

**实现**: [`XlsData`](../DataManager.cs:14)

**索引类型**:
- **标题索引** (mTitleIndex) - 快速查找列
- **ID 索引** (mIdIndex) - 快速查找行

**优势**:
- 快速数据访问
- 减少遍历次数
- 提高查询性能

---

## 7. 线程安全

### 7.1 UI 线程更新

**实现**: [`MainWindow`](../MainWindow.xaml.cs:1)

```csharp
// 使用 Dispatcher 更新 UI
Dispatcher.Invoke(new Action(() =>
{
    // 更新 UI
    mOutputText.Items.Add(message);
    mProgressBar.Value = progress;
}));
```

**说明**: 所有 UI 更新必须在 UI 线程上执行，使用 Dispatcher 确保线程安全。

### 7.2 文件写入

**实现**: [`SafeFileWrite`](../SafeFileWrite.cs:1)

**原理**:
- 使用临时文件
- 原子性写入
- 避免并发冲突

**说明**: 确保文件写入的原子性和一致性。

---

## 8. 扩展点

### 8.1 添加新数据类型

**步骤**:
1. 在 [`DefineManager`](../DefineManager.cs:1) 中添加新数据类型定义
2. 在 [`DataManager`](../DataManager.cs:1) 中添加数据验证逻辑
3. 在 [`ServerBeanNode`](../ServerBeanNode.cs:1) 中添加节点类型

**示例**:
```csharp
// 添加新的数据类型
public enum DataType
{
    bool,
    int,
    long,
    double,
    string,
    // 新增类型
    vector2,
    vector3,
}
```

### 8.2 添加新代码生成模板

**步骤**:
1. 在 [`MainWindow`](../MainWindow.xaml.cs:1) 中添加新的代码生成方法
2. 在 [`ServerBeanNode`](../ServerBeanNode.cs:1) 中添加代码生成逻辑
3. 在 UI 中添加新的生成选项

**示例**:
```csharp
// 添加新的代码生成方法
public bool MakePythonCode()
{
    // 生成 Python 代码
    // ...
    return true;
}
```

### 8.3 添加新数据源

**步骤**:
1. 在 [`DataManager`](../DataManager.cs:1) 中添加新的加载方法
2. 在 [`XlsData`](../DataManager.cs:14) 中添加数据解析逻辑
3. 在 UI 中添加新的数据源选项

**示例**:
```csharp
// 添加新的数据源加载方法
public bool LoadJson(string fileName)
{
    // 加载 JSON 文件
    // ...
    return true;
}
```

---

## 9. 参考资料

### 9.1 相关文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 项目概述 | [01-项目概述-Project-Overview.md](01-项目概述-Project-Overview.md) | 项目概述 |
| 快速开始 | [03-快速开始-Quick-Start.md](03-快速开始-Quick-Start.md) | 快速入门指南 |
| 配置指南 | [04-配置指南-Configuration-Guide.md](04-配置指南-Configuration-Guide.md) | 配置文件说明 |
| 数据格式规范 | [05-数据格式规范-Data-Format-Specification.md](05-数据格式规范-Data-Format-Specification.md) | 数据格式说明 |
| Bean 定义指南 | [06-Bean定义指南-Bean-Definition-Guide.md](06-Bean定义指南-Bean-Definition-Guide.md) | Bean 定义说明 |
| 代码生成指南 | [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md) | 代码生成说明 |
| 二进制格式规范 | [08-二进制格式规范-Binary-Format-Specification.md](08-二进制格式规范-Binary-Format-Specification.md) | 二进制格式说明 |

### 9.2 核心代码文件

| 文件 | 行数 | 说明 |
|------|------|------|
| MainWindow.xaml.cs | 2721 | 主窗口逻辑 |
| DataManager.cs | 577 | 数据管理器 |
| DefineManager.cs | 315 | Bean 定义管理器 |
| ServerBeanNode.cs | 358 | 服务器 Bean 节点 |

### 9.3 设计模式参考

- [设计模式：可复用面向对象软件的基础](https://en.wikipedia.org/wiki/Design_Patterns)
- [C# 设计模式](https://docs.microsoft.com/en-us/dotnet/standard/design-patterns/)

---

**维护者**: 技术委员会
**下次审查**: 2026-05-20
**许可证**: 内部使用

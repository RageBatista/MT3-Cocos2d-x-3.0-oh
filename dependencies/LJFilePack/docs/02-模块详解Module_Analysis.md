# 02-模块详解 Module Analysis

> **版本**: 1.0.0  
> **创建日期**: 2026-01-13  
> **作者**: 系统架构师  
> **项目**: LJFilePack (LJ文件打包工具)

---

## 1. 模块概述

### 1.1 模块分类

LJFilePack 项目包含以下核心模块：

| 模块类别 | 模块名称 | 功能描述 |
|----------|----------|----------|
| **主程序模块** | LJFP_Main | 主程序入口，命令行参数解析 |
| **配置管理模块** | LJFP_Option | XML配置文件加载与解析 |
| **版本管理模块** | LJFP_Version | 版本号管理与转换 |
| **文件扫描模块** | LJFP_Find | 文件递归扫描与过滤 |
| **文件打包模块** | LJFP_Pack | 文件压缩、加密、打包 |
| **文件信息模块** | LJFP_FileInfo | 文件元数据管理 |
| **文件列表模块** | LJFP_FileList | 文件列表管理 |
| **ZIP封装模块** | LJFP_ZipFile | ZIP文件操作 |
| **XML处理模块** | LJFP_XML | XML文件读写 |
| **节点结构模块** | LJFP_Node | 节点数据结构 |
| **加密模块** | LJFP_SMS4 | SMS4国密加密算法 |
| **压缩模块** | LJFP_MiniZ | MiniZ压缩库（zlib兼容） |
| **校验模块** | LJFP_CRC32 | CRC32校验算法 |
| **字符串工具模块** | LJFP_StringUtil | 字符串转换工具 |
| **文件操作模块** | LJFP_FileUtil | 文件操作工具 |

### 1.2 模块依赖关系

```
┌─────────────────────────────────────────────────────────────────┐
│                        LJFP_Main                             │
│         └──────────┬──────────────┘
│                           │
├───────────────────────────┼───────────────────────────────────┤
│                           │
│  ┌────────────────────────┼────────────────────────────────┐   │
│  ▼                        ▼                                ▼   │
│ ┌─────────┐        ┌─────────┐        ┌─────────┐          │
│ │LJFP_Find│        │LJFP_Pack│        │LJFP_Ver │          │
│ └────┬────┘        └────┬────┘        └────┬────┘          │
│      │                  │                  │                │
│      ▼                  ▼                  ▼                │
│ ┌─────────────────────────────────────────┐                │
│ │         LJFP_Option                    │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │          LJFP_XML                      │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │         LJFP_Node                      │                │
│ └─────────────────────────────────────────┘                │
│                                                           │
│ ┌─────────────────────────────────────────┐                │
│ │       LJFP_FileList                   │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │       LJFP_PackInfo                   │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │      LJFP_FileInfo                    │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │       LJFP_ZipFile                   │                │
│ └───────┬───────────────┬─────────────┘                │
│         │               │                               │
│         ▼               ▼                               │
│ ┌───────────────┐ ┌───────────────┐                     │
│ │  LJFP_SMS4    │ │  LJFP_MiniZ   │                     │
│ └───────────────┘ └───────────────┘                     │
│                                                           │
│ ┌─────────────────────────────────────────┐                │
│ │      LJFP_CRC32                      │                │
│ └─────────────────────────────────────────┘                │
│                                                           │
│ ┌─────────────────────────────────────────┐                │
│ │    LJFP_StringUtil                   │                │
│ └─────────────────────────────────────────┘                │
│                                                           │
│ ┌─────────────────────────────────────────┐                │
│ │     LJFP_FileUtil                    │                │
│ └─────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 核心模块详解

### 2.1 LJFP_Main 模块

#### 2.1.1 模块概述

**文件**: [`LJFP_Main.h`](../LJFP_Main.h)

**功能描述**:
- 主程序入口
- 命令行参数解析
- 初始化配置
- 调用文件扫描和打包流程

#### 2.1.2 核心功能

| 功能 | 描述 |
|------|------|
| 命令行参数解析 | 解析 version、update、channel、extend、io、filter、pack、compress、code 等参数 |
| 配置初始化 | 加载并初始化配置文件 |
| 文件扫描 | 调用 LJFP_Find 扫描文件 |
| 文件打包 | 调用 LJFP_Pack 打包文件 |
| 版本管理 | 调用 LJFP_Version 管理版本信息 |

#### 2.1.3 主要接口

```cpp
// 命令行参数解析
int ParseCommandLine(int argc, char* argv[]);

// 主程序入口
int main(int argc, char* argv[]);
```

#### 2.1.4 使用示例

```bash
# 指定版本索引、更新索引、渠道索引
LJFilePack.exe version:0 update:1 channel:0

# 指定扩展索引、IO索引、过滤索引
LJFilePack.exe extend:0 io:0 filter:0

# 指定打包索引、压缩索引、加密索引
LJFilePack.exe pack:0 compress:0 code:0

# 禁用暂停提示
LJFilePack.exe nopause
```

---

### 2.2 LJFP_Option 模块

#### 2.2.1 模块概述

**文件**: [`LJFP_Option.h`](../LJFP_Option.h)

**功能描述**:
- XML配置文件加载与解析
- 配置项管理
- 配置文件保存

#### 2.2.2 核心功能

| 功能 | 描述 |
|------|------|
| 配置加载 | 从 XML 文件加载配置 |
| 配置保存 | 保存配置到 XML 文件 |
| 版本初始化 | 初始化版本信息 |
| 更新初始化 | 初始化更新信息 |
| 渠道初始化 | 初始化渠道信息 |
| 扩展初始化 | 初始化扩展信息 |
| 过滤规则查询 | 查询目录和文件过滤规则 |
| 打包规则查询 | 查询文件打包规则 |
| 压缩规则查询 | 查询文件压缩规则 |
| 加密规则查询 | 查询文件加密规则 |

#### 2.2.3 主要接口

```cpp
// 创建默认配置
static LJFP_Node* MakeDefaultOption();

// 加载配置文件
static int LoadOption(std::wstring strFileName);

// 保存配置文件
static int SaveOption(std::wstring strFileName);

// 初始化版本信息
static int InitVersion(LJFP_Node* FN, unsigned int uiIndex);

// 初始化更新信息
static int InitUpdate(LJFP_Node* FN, unsigned int uiIndex);

// 初始化渠道信息
static int InitChannel(LJFP_Node* FN, unsigned int uiIndex);

// 初始化扩展信息
static int InitExtend(LJFP_Node* FN, unsigned int uiIndex);

// 检查是否过滤目录
static bool IsFilterDir(std::wstring strDirName);

// 检查是否过滤文件
static bool IsFilterFile(std::wstring strFileName);

// 检查是否打包文件
static bool IsPackFile(std::wstring strFileName);

// 检查是否压缩文件
static bool IsCompressFile(std::wstring strFileName);

// 检查是否加密文件
static bool IsCodeFile(std::wstring strFileName);

// 获取查找路径
static std::wstring GetFindPath();

// 获取输出路径
static std::wstring GetOutputPath();

// 获取输出类型
static unsigned int GetOutputType();

// 获取最大包大小
static unsigned int GetPackMaxSize();
```

#### 2.2.4 配置文件结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Option>
  <Version>
    <VersionIndex>0</VersionIndex>
    <VersionCaption>1.0.0</VersionCaption>
    <VersionBase>0</VersionBase>
    <VersionMinimum>0</VersionMinimum>
    <VersionDonotCheck>false</VersionDonotCheck>
    <Channel>0</Channel>
    <ChannelCaption>Default</ChannelCaption>
    <AppURL>http://www.example.com</AppURL>
  </Version>
  <Update>
    <UpdateIndex>0</UpdateIndex>
    <UpdateCaption>Update</UpdateCaption>
  </Update>
  <Channel>
    <ChannelIndex>0</ChannelIndex>
    <ChannelCaption>Default</ChannelCaption>
  </Channel>
  <Extend>
    <ExtendIndex>0</ExtendIndex>
    <ExtendCaption>Default</ExtendCaption>
  </Extend>
  <IO>
    <IOIndex>0</IOIndex>
    <IOCaption>Default</IOCaption>
  </IO>
  <Filter>
    <FilterIndex>0</FilterIndex>
    <FilterCaption>Default</FilterCaption>
    <FilterDir>
      <DirName>.svn</DirName>
      <DirName>.git</DirName>
    </FilterDir>
    <FilterFile>
      <FileName>*.tmp</FileName>
      <FileName>*.log</FileName>
    </FilterFile>
  </Filter>
  <Pack>
    <PackIndex>0</PackIndex>
    <PackCaption>Default</PackCaption>
    <PackMaxSize>52428800</PackMaxSize>
    <PackFile>
      <FileName>*.pak</FileName>
      <FileName>*.zip</FileName>
    </PackFile>
  </Pack>
  <Compress>
    <CompressIndex>0</CompressIndex>
    <CompressCaption>Default</CompressCaption>
    <CompressFile>
      <FileName>*.txt</FileName>
      <FileName>*.xml</FileName>
    </CompressFile>
  </Compress>
  <Code>
    <CodeIndex>0</CodeIndex>
    <CodeCaption>Default</CodeCaption>
    <CodeFile>
      <FileName>*.lua</FileName>
      <FileName>*.script</FileName>
    </CodeFile>
  </Code>
</Option>
```

---

### 2.3 LJFP_Version 模块

#### 2.3.1 模块概述

**文件**: [`LJFP_Version.h`](../LJFP_Version.h)

**功能描述**:
- 版本号管理与转换
- 版本号格式：255.4095.4095
- 版本号与数字双向转换

#### 2.3.2 核心功能

| 功能 | 描述 |
|------|------|
| 版本号转数字 | 将版本号字符串转换为数字 |
| 数字转版本号 | 将数字转换为版本号字符串 |
| 获取版本号 | 获取当前版本号 |
| 设置版本号 | 设置版本号 |
| 设置渠道ID | 设置渠道ID |
| 设置渠道名称 | 设置渠道名称 |
| 设置应用URL | 设置应用URL |
| 设置URL信息数组 | 设置URL信息数组 |
| 设置扩展映射 | 设置扩展映射 |
| 查找扩展值 | 查找扩展值 |
| 克隆扩展映射 | 克隆扩展映射 |
| 从XML加载版本信息 | 从XML文件加载版本信息 |
| 保存版本信息到XML | 保存版本信息到XML文件 |

#### 2.3.3 主要接口

```cpp
// 版本号转数字
static unsigned int VersionCaption2Version(std::wstring strVersionCaption);

// 数字转版本号
static std::wstring Version2VersionCaption(unsigned int uiVersion);

// 获取版本号
unsigned int GetVersion();

// 获取基础版本号
unsigned int GetVersionBase();

// 获取最小版本号
unsigned int GetVersionMinimum();

// 设置版本号
void SetVersionCaption(std::wstring strVersionCaption);

// 设置基础版本号
void SetVersionCaptionBase(std::wstring strVersionCaptionBase);

// 设置最小版本号
void SetVersionCaptionMinimum(std::wstring strVersionCaptionMinimum);

// 设置不检查版本号
void SetVersionDonotCheck(bool bVersionDonotCheck);

// 设置渠道ID
void SetChannel(unsigned int uiChannel);

// 设置渠道名称
void SetChannelCaption(std::wstring strChannelCaption);

// 设置应用URL
void SetAppURL(std::wstring strAppURL);

// 设置URL信息数组
void SetURLInfoArr(std::vector<std::wstring> URLInfoArr);

// 设置扩展映射
void SetExtendMap(std::map<std::wstring, std::wstring> ExtendMap);

// 获取扩展数量
unsigned int GetExtendCount();

// 查找扩展值
std::wstring FindExtendValue(std::wstring strExtendKey);

// 克隆扩展映射
std::map<std::wstring, std::wstring>* CloneExtendMap();

// 从XML加载版本信息
int LoadFromXMLFile(std::wstring strFileName);

// 保存版本信息到XML
int SaveToXMLFile(std::wstring strFileName);
```

#### 2.3.4 版本号格式

版本号格式：`255.4095.4095`

| 字段 | 位数 | 范围 | 说明 |
|------|------|------|------|
| 主版本 | 8位 | 0-255 | 主版本号 |
| 次版本 | 12位 | 0-4095 | 次版本号 |
| 修订号 | 12位 | 0-4095 | 修订号 |

**示例**:
- `1.0.0` → 数字：`65536`
- `255.4095.4095` → 数字：`4294967295`

---

### 2.4 LJFP_Find 模块

#### 2.4.1 模块概述

**文件**: [`LJFP_Find.h`](../LJFP_Find.h)

**功能描述**:
- 文件递归扫描
- 文件过滤
- 目录过滤

#### 2.4.2 核心功能

| 功能 | 描述 |
|------|------|
| 递归查找文件 | 递归查找指定目录下的所有文件 |
| 处理目录发现事件 | 处理目录发现事件 |
| 处理文件发现事件 | 处理文件发现事件 |
| 处理文件数据事件 | 处理文件数据事件 |

#### 2.4.3 主要接口

```cpp
// 处理目录发现事件
void OnFindDir(std::wstring strRootPathName, std::wstring strParentPathName, std::wstring strDirName);

// 处理文件发现事件
void OnFindFile(std::wstring strRootPathName, std::wstring strParentPathName, std::wstring strFileName);

// 处理文件数据事件
void OnFindData(std::wstring strRootPathName, std::wstring strParentPathName, WIN32_FIND_DATAW& FindData);

// 递归查找文件
int FindFiles(std::wstring strRootPathName, std::wstring strParentPathName, std::wstring strPathName);
```

#### 2.4.4 使用示例

```cpp
LJFP_Find find;
find.m_FindFunc = FindOneFile;

// 开始扫描
find.FindFiles(L"Root/", L"", L"");
```

---

### 2.5 LJFP_Pack 模块

#### 2.5.1 模块概述

**文件**: [`LJFP_Pack.h`](../LJFP_Pack.h)

**功能描述**:
- 文件压缩
- 文件加密
- 文件打包

#### 2.5.2 核心功能

| 功能 | 描述 |
|------|------|
| 加载文件数据 | 加载文件数据到内存 |
| 压缩数据 | 压缩文件数据 |
| 加密数据 | 加密文件数据 |
| 保存数据 | 保存数据到文件 |
| 释放数据 | 释放数据内存 |
| 清空数据 | 清空所有数据 |

#### 2.5.3 主要接口

```cpp
// 加载文件数据
int LoadData();

// 压缩数据
int CompressData(bool bCompress);

// 加密数据
int CodeData(bool bCode);

// 保存数据到文件
int SaveData(std::wstring strRootPathName);

// 释放数据内存
int ReleaseData();

// 清空数据
int Clear();
```

#### 2.5.4 数据状态

| 状态 | 说明 |
|------|------|
| m_Data | 当前数据指针（原始/压缩后/加密后） |
| m_DataOriginal | 原始数据指针 |
| m_DataCompress | 压缩后数据指针 |
| m_DataCode | 加密后数据指针 |

---

### 2.6 LJFP_FileInfo 模块

#### 2.6.1 模块概述

**文件**: [`LJFP_FileInfo.h`](../LJFP_FileInfo.h)

**功能描述**:
- 文件元数据管理
- 文件信息存储
- 文件信息序列化

#### 2.6.2 核心功能

| 功能 | 描述 |
|------|------|
| 克隆文件信息 | 克隆文件信息对象 |
| 获取完整文件路径 | 获取完整文件路径 |
| 从流加载文件信息 | 从流加载文件信息 |
| 从文件加载文件信息 | 从文件加载文件信息 |
| 保存到流 | 保存到流 |
| 保存到文件 | 保存到文件 |

#### 2.6.3 主要接口

```cpp
// 克隆文件信息对象
LJFP_FileInfo* Clone();

// 获取完整文件路径
std::wstring GetFullPathFileName();

// 从流加载文件信息
int LoadFromStream(std::ifstream& FS);

// 从文件加载文件信息
int LoadFromFile(std::wstring strFileName);

// 保存到流
int SaveToStream(std::ofstream& FS);

// 保存到文件
int SaveToFile(std::wstring strFileName);
```

#### 2.6.4 成员变量

| 变量 | 类型 | 说明 |
|------|------|------|
| m_FileArea | unsigned int | 文件区域（0=散文件，>0=打包文件） |
| m_PackIndex | unsigned int | 包索引 |
| m_Pos | unsigned int | 文件位置 |
| m_Size | unsigned int | 文件大小 |
| m_CRC32 | unsigned int | CRC32校验值 |
| m_CompressType | unsigned int | 压缩类型（0=不压缩） |
| m_CodeType | unsigned int | 加密类型（0=不加密） |
| m_SizeOriginal | unsigned int | 原始大小 |
| m_CRC32Original | unsigned int | 原始CRC32 |
| m_RootPathName | std::wstring | 根路径名 |
| m_PathFileName | std::wstring | 文件路径名 |
| m_PackFileName | std::wstring | 包文件名 |
| m_PathFileNameCRC32 | unsigned int | 路径名CRC32 |
| m_IsUse | unsigned int | 是否使用标记 |

---

### 2.7 LJFP_FileList 模块

#### 2.7.1 模块概述

**文件**: [`LJFP_FileList.h`](../LJFP_FileList.h)

**功能描述**:
- 文件列表管理
- 文件路径映射
- 文件导出

#### 2.7.2 核心功能

| 功能 | 描述 |
|------|------|
| 设置最大包大小 | 设置最大包大小 |
| 添加文件到列表 | 添加文件到列表 |
| 创建目录结构 | 创建目录结构 |
| 导出文件列表 | 执行导出操作 |

#### 2.7.3 主要接口

```cpp
// 设置最大包大小
void SetPackMaxSize(unsigned int PackMaxSize);

// 添加文件到列表
int AddFile(std::wstring strRootPathName, std::wstring strParentPathName, std::wstring strFileName, unsigned int Pack, unsigned int CompressType, unsigned int CodeType);

// 创建目录结构
int MakeDir(std::wstring ExportRootPathName, bool bPack, std::map<std::wstring, char>& PathMap);

// 执行导出操作
int ExportRes(std::wstring ExportRootPathName, bool bPack, bool bCompress, bool bCode);
```

#### 2.7.4 成员变量

| 变量 | 类型 | 说明 |
|------|------|------|
| m_PathMapAll | std::map<std::wstring, char> | 所有文件路径映射 |
| m_PathMapPack | std::map<std::wstring, char> | 打包文件路径映射 |
| m_PackMaxSize | unsigned int | 最大包大小 |
| m_FilePack | LJFP_Pack* | 文件包对象 |
| m_FilePackNo | LJFP_Pack* | 不打包文件对象 |
| m_FilePackAll | LJFP_Pack* | 所有文件包对象 |

---

### 2.8 LJFP_ZipFile 模块

#### 2.8.1 模块概述

**文件**: [`LJFP_ZipFile.h`](../LJFP_ZipFile.h)

**功能描述**:
- ZIP文件操作
- 压缩和解压缩
- 加密和解密

#### 2.8.2 核心功能

| 功能 | 描述 |
|------|------|
| 压缩流 | 压缩流操作 |
| 解压缩流 | 解压缩流操作 |
| 压缩文件 | 压缩文件操作 |
| 解压缩文件 | 解压缩文件操作 |

#### 2.8.3 主要接口

```cpp
// 压缩流操作
int ZipStream(std::ifstream& FSSrc, std::ofstream& FSDst);

// 解压缩流操作
int UnZipStream(std::ifstream& FSSrc, std::ofstream& FSDst, unsigned int& SizeDst, unsigned int& CRC32Dst);

// 压缩文件操作
int ZipFile(std::wstring Src, std::wstring Dst);

// 解压缩文件操作
int UnZipFile(std::wstring Src, std::wstring Dst);
```

#### 2.8.4 成员变量

| 变量 | 类型 | 说明 |
|------|------|------|
| m_uiKey | unsigned int | 密钥标识 |
| m_CRC32Func | CRC32_Func | CRC32函数指针 |
| m_ZipFunc | Zip_Func | 压缩函数指针 |
| m_UnZipFunc | UnZip_Func | 解压缩函数指针 |
| m_SMS4Func | SMS4_Func | 加密函数指针 |
| m_DeSMS4Func | DeSMS4_Func | 解密函数指针 |
| m_strPassword | std::string | 密码 |

---

### 2.9 LJFP_XML 模块

#### 2.9.1 模块概述

**文件**: [`LJFP_XML.h`](../LJFP_XML.h)

**功能描述**:
- XML文件读写
- 节点树操作
- XML序列化

#### 2.9.2 核心功能

| 功能 | 描述 |
|------|------|
| 从XML文件加载节点 | 从XML文件加载节点 |
| 保存到XML文件 | 保存到XML文件 |
| 从XML节点加载 | 从XML节点加载 |
| 保存到XML节点 | 保存到XML节点 |

#### 2.9.3 主要接口

```cpp
// 从XML文件加载节点
static int LoadFromXMLFile(std::wstring strFileName, LJFP_NodeEx*& pNode);

// 保存到XML文件
static int SaveToXMLFile(std::wstring strFileName, LJFP_NodeEx* pNode);

// 从XML节点加载
static int LoadFromXMLNode(LJXML::LJXML_Node<LJXML::Char>* pXMLNode, LJFP_NodeEx* pParentNode, LJFP_NodeEx*& pNode);

// 保存到XML节点
static int SaveToXMLNode(LJFP_NodeEx* pNode, LJXML::LJXML_Node<LJXML::Char>* pXMLNodeParent);
```

---

### 2.10 LJFP_Node 模块

#### 2.10.1 模块概述

**文件**: [`LJFP_Node.h`](../LJFP_Node.h)

**功能描述**:
- 节点数据结构
- 节点属性管理
- 节点子节点管理
- 节点序列化

#### 2.10.2 核心功能

| 功能 | 描述 |
|------|------|
| 获取属性数量 | 获取属性数量 |
| 添加属性 | 添加属性 |
| 查找属性 | 查找属性 |
| 获取属性值 | 获取属性值 |
| 获取指定索引的属性 | 获取指定索引的属性 |
| 添加子节点 | 添加子节点 |
| 查找子节点 | 查找子节点 |
| 获取指定索引的子节点 | 获取指定索引的子节点 |
| 获取子节点数量 | 获取子节点数量 |
| 构建属性列表 | 构建属性列表 |
| 清空属性列表 | 清空属性列表 |
| 从流加载节点 | 从流加载节点 |
| 从文件加载节点 | 从文件加载节点 |
| 保存到流 | 保存到流 |
| 保存到文件 | 保存到文件 |

#### 2.10.3 主要接口

```cpp
// 获取属性数量
unsigned int GetAttrCount();

// 添加属性
LJFP_Attr* AddAttr(std::wstring Key, std::wstring Value);

// 查找属性
LJFP_Attr* FindAttr(std::wstring Key);

// 获取属性值
std::wstring FindAttrValue(std::wstring Key);

// 获取指定索引的属性
LJFP_Attr* GetAttr(unsigned int uiIndex);

// 添加子节点
virtual LJFP_Node* AddNode(std::wstring Name, std::wstring Text);

// 查找子节点
LJFP_Node* FindNode(std::wstring Name);

// 获取指定索引的子节点
LJFP_Node* GetNode(unsigned int uiIndex);

// 获取子节点数量
unsigned int GetNodeCount();

// 构建属性列表
int BuildAttrList();

// 清空属性列表
int ClearAttrList();

// 从流加载节点
static int LoadFromStream(std::ifstream& FS, LJFP_Node* pParentNode, LJFP_Node*& pNode);

// 从文件加载节点
static int LoadFromFile(std::wstring strFileName, LJFP_Node*& pNode);

// 保存到流
static int SaveToStream(std::ofstream& FS, LJFP_Node* pNode);

// 保存到文件
static int SaveToFile(std::wstring strFileName, LJFP_Node* pNode);
```

#### 2.10.4 成员变量

| 变量 | 类型 | 说明 |
|------|------|------|
| m_Name | std::wstring | 节点名称 |
| m_Text | std::wstring | 节点文本 |
| m_AttrMap | std::map<std::wstring, LJFP_Attr*> | 属性映射 |
| m_NodeMap | std::map<std::wstring, LJFP_Node*> | 子节点映射 |
| m_AttrList | WStrList | 属性列表 |

---

### 2.11 LJFP_SMS4 模块

#### 2.11.1 模块概述

**文件**: [`LJFP_SMS4.h`](../LJFP_SMS4.h)

**功能描述**:
- SMS4国密算法实现
- 数据加密
- 数据解密

#### 2.11.2 核心功能

| 功能 | 描述 |
|------|------|
| 密钥扩展 | 密钥扩展（32轮） |
| 加密 | 加密数据 |
| 解密 | 解密数据 |

#### 2.11.3 主要接口

```cpp
// 密钥扩展
void KeyExpansion();

// 第1轮密钥生成
unsigned int T1(unsigned int dwA, unsigned int dwB, unsigned int dwC, unsigned int dwD);

// 第2轮密钥生成
unsigned int T2(unsigned int dwA, unsigned int dwB, unsigned int dwC, unsigned int dwD);

// 加密函数
void Cipher(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize);

// 解密函数
void InvCipher(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize);
```

#### 2.11.4 成员变量

| 变量 | 类型 | 说明 |
|------|------|------|
| m_Key | unsigned int[4] | 密钥 |
| m_RK | unsigned int[32] | 轮密钥 |

---

### 2.12 LJFP_MiniZ 模块

#### 2.12.1 模块概述

**文件**: [`LJFP_MiniZ.h`](../LJFP_MiniZ.h)

**功能描述**:
- MiniZ压缩库（zlib兼容）
- 数据压缩
- 数据解压缩

#### 2.12.2 核心功能

| 功能 | 描述 |
|------|------|
| 压缩数据 | 压缩数据 |
| 解压缩数据 | 解压缩数据 |
| CRC32计算 | 计算CRC32 |
| 初始化压缩流 | 初始化压缩流 |
| 初始化解压缩流 | 初始化解压缩流 |

#### 2.12.3 主要接口

```cpp
// 压缩函数
int mz_compress(unsigned char *pDest, mz_ulong *pDest_len, 
              const unsigned char *pSource, mz_ulong source_len);

// 更高级别压缩
int mz_compress2(unsigned char *pDest, mz_ulong *pDest_len, 
                const unsigned char *pSource, mz_ulong source_len, int level);

// 解压缩函数
int mz_uncompress(unsigned char *pDest, mz_ulong *pDest_len, 
                const unsigned char *pSource, mz_ulong source_len);

// CRC32计算函数
mz_ulong mz_crc32(mz_ulong crc, const unsigned char *ptr, size_t buf_len);

// 初始化压缩流
int mz_deflateInit(mz_stream *stream, int level);

// 初始化解压缩流
int mz_inflateInit(mz_stream *stream);
```

---

### 2.13 LJFP_CRC32 模块

#### 2.13.1 模块概述

**文件**: [`LJFP_CRC32.h`](../LJFP_CRC32.h)

**功能描述**:
- CRC32校验算法
- CRC32计算

#### 2.13.2 核心功能

| 功能 | 描述 |
|------|------|
| CRC32计算 | 计算CRC32 |

#### 2.13.3 主要接口

```cpp
// CRC32计算函数
unsigned int crc32_nn(unsigned int crc, const unsigned char* ptr, size_t buf_len);
```

#### 2.13.4 查表

| 变量 | 类型 | 说明 |
|------|------|------|
| crc32_tab | unsigned int[256] | 256项标准CRC32表 |

---

### 2.14 LJFP_StringUtil 模块

#### 2.14.1 模块概述

**文件**: [`LJFP_StringUtil.h`](../LJFP_StringUtil.h)

**功能描述**:
- 字符串转换
- 字符串分割
- 大小写转换

#### 2.14.2 核心功能

| 功能 | 描述 |
|------|------|
| 宽字符转窄字符 | 宽字符转窄字符 |
| 窄字符转宽字符 | 窄字符转宽字符 |
| 字符串分割 | 字符串分割 |
| 大小写转换 | 大小写转换 |

#### 2.14.3 主要接口

```cpp
// 宽字符转窄字符
template<typename T>
std::string WStrToNum(const std::wstring& InSrc);

// 窄字符转宽字符
std::wstring S2WS(const std::string& S);

// 字符串分割
std::size_t SplitStrW(const std::wstring& SourceStr, const std::wstring& DelimitStr, 
                     std::vector<std::wstring>& ResultStr);

// 大小写转换
std::wstring ToLowerW(const std::wstring& str);
std::wstring ToUpperW(const std::wstring& str);
```

---

### 2.15 LJFP_FileUtil 模块

#### 2.15.1 模块概述

**文件**: [`LJFP_FileUtil.h`](../LJFP_FileUtil.h)

**功能描述**:
- 文件操作
- 目录操作
- 路径处理

#### 2.15.2 核心功能

| 功能 | 描述 |
|------|------|
| 创建目录 | 创建目录 |
| 检查文件是否存在 | 检查文件是否存在 |
| 获取文件大小 | 获取文件大小 |
| 复制文件 | 复制文件 |
| 删除文件 | 删除文件 |
| 路径处理 | 路径处理 |

#### 2.15.3 主要接口

```cpp
// 创建目录
bool CreateDir(const std::wstring& strDir);

// 检查文件是否存在
bool FileExists(const std::wstring& strFile);

// 获取文件大小
unsigned int GetFileSize(const std::wstring& strFile);

// 复制文件
bool CopyFile(const std::wstring& strSrc, const std::wstring& strDst);

// 删除文件
bool DeleteFile(const std::wstring& strFile);

// 路径处理
std::wstring GetPathName(const std::wstring& strPath);
std::wstring GetFileName(const std::wstring& strPath);
std::wstring GetFileExt(const std::wstring& strPath);
```

---

## 3. 模块间交互

### 3.1 主程序流程

```
┌─────────────────────────────────────────────────────────────────┐
│                        LJFP_Main                             │
│         └──────────┬──────────────┘
│                           │
│  ┌────────────────────────┼────────────────────────────────┐   │
│  ▼                        ▼                                ▼   │
│ ┌─────────┐        ┌─────────┐        ┌─────────┐          │
│ │解析命令行│        │加载配置  │        │初始化版本│          │
│ └────┬────┘        └────┬────┘        └────┬────┘          │
│      │                  │                  │                │
│      ▼                  ▼                  ▼                │
│ ┌─────────────────────────────────────────┐                │
│ │         扫描文件                       │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │         打包文件                       │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │         生成索引                       │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │         生成版本                       │                │
│ └─────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 文件打包流程

```
┌─────────────────────────────────────────────────────────────────┐
│                        LJFP_FileList                        │
│         └──────────┬──────────────┘
│                           │
│  ┌────────────────────────┼────────────────────────────────┐   │
│  ▼                        ▼                                ▼   │
│ ┌─────────┐        ┌─────────┐        ┌─────────┐          │
│ │添加文件  │        │分类文件  │        │处理文件  │          │
│ └────┬────┘        └────┬────┘        └────┬────┘          │
│      │                  │                  │                │
│      ▼                  ▼                  ▼                │
│ ┌─────────────────────────────────────────┐                │
│ │         加载数据                       │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │         压缩数据                       │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │         加密数据                       │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │         保存数据                       │                │
│ └───────────────┬───────────────────────┘                │
│                 │                                        │
│                 ▼                                        │
│ ┌─────────────────────────────────────────┐                │
│ │         释放数据                       │                │
│ └─────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. 附录

### 4.1 术语表

| 术语 | 说明 |
|------|------|
| ljfp | LJ文件打包格式 |
| ljpi | 文件索引文件格式 |
| ljzip | 加密索引文件格式 |
| ljvi | 版本信息文件格式 |
| xml | XML配置文件格式 |
| crc32 | 循环冗余校验算法 |
| sms4 | SMS4国密算法 |
| miniz | zlib兼容压缩库 |
| node | 节点数据结构 |

### 4.2 命令行参数

| 参数 | 说明 |
|------|------|
| version:0 | 指定版本索引 |
| update:1 | 指定更新索引 |
| channel:0 | 指定渠道索引 |
| extend:0 | 指定扩展索引 |
| io:0 | 指定IO索引 |
| filter:0 | 指定过滤索引 |
| pack:0 | 指定打包索引 |
| compress:0 | 指定压缩索引 |
| code:0 | 指定加密索引 |
| nopause | 禁用暂停提示 |

### 4.3 文件扩展名

| 扩展名 | 说明 |
|--------|------|
| .ljfp | 打包文件格式 |
| .ljpi | 文件索引格式 |
| .ljzip | 加密索引文件格式 |
| .ljvi | 版本信息文件格式 |
| .xml | XML配置文件格式 |
| .ljnd | 节点文件格式 |
| .exe | 可执行文件 |

---

**文档版本**: 1.0.0  
**最后更新**: 2026-01-13

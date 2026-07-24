# 05-API参考手册 API Reference Manual

> **版本**: 1.0.0  
> **创建日期**: 2026-01-13  
> **作者**: 系统架构师  
> **项目**: LJFilePack (LJ文件打包工具)

---

## 1. API索引

### 1.1 核心模块API

| 模块 | 文件 | API类别 | 说明 |
|------|------|------|------|
| 版本管理 | [`LJFP_Version.h`](../LJFP_Version.h) | 版本号转换与格式管理 | 版本号与格式双向转换 |
| 配置管理 | [`LJFP_Option.h`](../LJFP_Option.h) | XML配置文件加载与解析 | 初始化默认配置、加载/保存配置文件 |
| 文件打包 | [`LJFP_Pack.h`](../LJFP_Pack.h) | 文件压缩、加密、打包 | 文件数据加载、压缩、加密、保存 |
| 文件信息 | [`LJFP_FileInfo.h`](../LJFP_FileInfo.h) | 文件元数据管理 | 文件信息存储、序列化、路径计算 |
| 包信息 | [`LJFP_PackInfo.h`](../LJFP_Pack.h) | 包索引管理 | 文件列表管理、包统计信息、CRC32冲突检测 |
| 文件列表 | [`LJFP_FileList.h`](../LJFP_FileList.h) | 文件列表管理 | 整个打包流程管理、路径映射 |
| XML节点 | [`LJFP_Node.h`](../LJFP_Node.h) | 节点数据结构 | 节点属性、子节点管理、序列化 |
| XML扩展 | [`LJFP_XML.h`](../LJFP_XML.h) | XML文件读写 | XML文件加载、保存、节点树操作 |
| 文件查找 | [`LJFP_Find.h`](../LJFP_Find.h) | 文件扫描 | 递归扫描、过滤规则应用 |
| ZIP封装 | [`LJFP_ZipFile.h`](../LJFP_ZipFile.h) | ZIP文件操作 | 压缩、解压、加密 |
| 加密 | [`LJFP_SMS4.h`](../LJFP_SMS4.h) | SMS4加密 | SMS4国密算法实现 |
| 压缩 | [`LJFP_MiniZ.h`](../LJFP_MiniZ.h) | MiniZ压缩 | zlib兼容压缩库 |
| CRC32 | [`LJFP_CRC32.h`](../LJFP_CRC32.h) | CRC32校验 | CRC32校验算法 |

### 1.2 工具类API

| 工具类 | 文件 | 主要API |
|------|------|------|
| StringUtil | [`LJFP_StringUtil.h`](../LJFP_StringUtil.h) | 字符串转换 | 宽窄字符互转、分割、大小写转换 |
| FileUtil | [`LJFP_FileUtil.h`](../LJFP_FileUtil.h) | 文件操作 | 目录创建、文件存在检查、路径处理、文件复制 |

---

## 2. 核心类API参考

### 2.1 LJFP_Node 类

**文件**: [`LJFP_Node.h`](../LJFP_Node.h)

**类声明**:
```cpp
class LJFP_Node
{
public:
    std::wstring m_Name;
    std::wstring m_Text;
    std::map<std::wstring, LJFP_Attr*> m_AttrMap;
    std::map<std::wstring, LJFP_Node*> m_NodeMap;
    WStrList m_AttrList;
    
    LJFP_Node(std::wstring Name, std::wstring Text = L"");
    virtual ~LJFP_Node();
    
    unsigned int GetAttrCount();
    LJFP_Attr* AddAttr(std::wstring Key, std::wstring Value);
    LJFP_Attr* FindAttr(std::wstring Key);
    std::wstring FindAttrValue(std::wstring Key);
    LJFP_Attr* FindAndAddAttr(std::wstring Key, std::wstring Value);
    LJFP_Attr* GetAttr(unsigned int uiIndex);
    
    virtual LJFP_Node* AddNode(std::wstring Name, std::wstring Text);
    virtual void AddNode(LJFP_Node* pNode);
    LJFP_Node* FindNode(std::wstring Name);
    LJFP_Node* FindAndAddNode(std::wstring Name, std::wstring Text = L"");
    LJFP_Node* GetNode(unsigned int uiIndex);
    unsigned int GetNodeCount();
    
    int BuildAttrList();
    int ClearAttrList();
    
    static int LoadFromStream(std::ifstream& FS, LJFP_Node* pParentNode, LJFP_Node*& pNode);
    static int LoadFromFile(std::wstring strFileName, LJFP_Node*& pNode);
    static int SaveToStream(std::ofstream& FS, LJFP_Node* pNode);
    static int SaveToFile(std::wstring strFileName, LJFP_Node* pNode);
};
```

**主要方法**:
- `GetAttrCount()` - 获取属性数量
- `AddAttr()` - 添加属性
- `FindAttr()` - 查找属性
- `FindAttrValue()` - 获取属性值
- `GetAttr()` - 获取指定索引的属性
- `AddNode()` - 添加子节点
- `FindNode()` - 查找子节点
- `GetNode()` - 获取指定索引的子节点
- `GetNodeCount()` - 获取子节点数量
- `BuildAttrList()` - 构建属性列表
- `ClearAttrList()` - 清空属性列表
- `LoadFromStream()` - 从流加载节点
- `LoadFromFile()` - 从文件加载节点
- `SaveToStream()` - 保存到流
- `SaveToFile()` - 保存到文件

---

### 2.2 LJFP_NodeEx 类

**文件**: [`LJFP_XML.h`](../LJFP_XML.h)

**类声明**:
```cpp
class LJFP_NodeEx : public LJFP_Node
{
public:
    LJFP_NodeEx(std::wstring Name, std::wstring Text = L"")
        : LJFP_Node(Name, Text)
    {
        
    virtual ~LJFP_NodeEx();
    
    virtual LJFP_NodeEx* AddNode(std::wstring Name, std::wstring Text);
    virtual void AddNode(LJFP_Node* pNode);
    virtual LJFP_NodeEx* FindNode(std::wstring Name);
    virtual LJFP_NodeEx* FindAndAddNode(std::wstring Name, std::wstring Text = L"");
    
    static int LoadFromXMLNode(LJXML::LJXML_Node<LJXML::Char>* pXMLNode, LJFP_NodeEx* pParentNode, LJFP_NodeEx*& pNode);
    static int LoadFromXMLFile(std::wstring strFileName, LJFP_NodeEx*& pNode);
    static int SaveToXMLNode(LJFP_NodeEx* pNode, LJXML::LJXML_Node<LJXML::Char>* pXMLNodeParent);
    static int SaveToXMLFile(std::wstring strFileName, LJFP_NodeEx* pNode);
};
```

**新增功能**:
- `LoadFromXMLFile()` - 从XML文件加载节点
- `SaveToXMLFile()` - 保存到XML文件
- `LoadFromXMLNode()` - 从XML节点加载

---

### 2.3 LJFP_FileInfo 类

**文件**: [`LJFP_FileInfo.h`](../LJFP_FileInfo.h)

**类声明**:
```cpp
class LJFP_FileInfo
{
public:
    unsigned int m_FileArea;
    
    unsigned int m_PackIndex;
    unsigned int m_Pos;
    unsigned int m_Size;
    unsigned int m_CRC32;
    
    unsigned int m_CompressType;
    unsigned int m_CodeType;
    
    unsigned int m_SizeOriginal;
    unsigned int m_CRC32Original;
    
    std::wstring m_RootPathName;
    std::wstring m_PathFileName;
    std::wstring m_PackFileName;
    
    unsigned int m_PathFileNameCRC32;
    
    unsigned int m_IsUse;
    
    LJFP_FileInfo();
    LJFP_FileInfo* Clone();
    
    std::wstring GetFullPathFileName();
    
    int LoadFromStream(std::ifstream& FS);
    int LoadFromFile(std::wstring strFileName);
    int SaveToStream(std::ofstream& FS);
    int SaveToFile(std::wstring strFileName);
};
```

**主要方法**:
- `Clone()` - 克隆文件信息对象
- `GetFullPathFileName()` - 获取完整文件路径
- `LoadFromStream()` - 从流加载文件信息
- `LoadFromFile()` - 从文件加载文件信息
- `SaveToStream()` - 保存到流
- `SaveToFile()` - 保存到文件

**成员变量**:
- `m_FileArea` - 文件区域（0=散文件，>0=打包文件）
- `m_PackIndex` - 包索引
- `m_Pos` - 文件位置
- `m_Size` - 文件大小
- `m_CRC32` - CRC32校验值
- `m_CompressType` - 压缩类型（0=不压缩）
- `m_CodeType` - 加密类型（0=不加密）
- `m_SizeOriginal` - 原始大小
- `m_CRC32Original` - 原始CRC32
- `m_RootPathName` - 根路径名
- `m_PathFileName` - 文件路径名
- `m_PackFileName` - 包文件名
- `m_PathFileNameCRC32` - 路径名CRC32
- `m_IsUse` - 是否使用标记

---

### 2.4 LJFP_File 类

**文件**: [`LJFP_Pack.h`](../LJFP_Pack.h)

**类声明**:
```cpp
class LJFP_File
{
public:
    unsigned int m_Pack;
    unsigned int m_Pos;
    
    unsigned int m_Size;
    unsigned int m_CRC32;
    
    unsigned char* m_Data;
    
    unsigned int m_CompressType;
    unsigned int m_CodeType;
    
    unsigned int m_SizeOriginal;
    unsigned int m_CRC32Original;
    
    unsigned char* m_DataOriginal;
    unsigned char* m_DataCompress;
    unsigned char* m_DataCode;
    
    std::wstring m_RootPathName;
    std::wstring m_PathName;
    std::wstring m_Name;
    
    unsigned int m_PathFileNameCRC32;
    
    LJFP_File();
    ~LJFP_File();
    
    int LoadData();
    int CompressData(bool bCompress);
    int CodeData(bool bCode);
    int SaveData(std::wstring strRootPathName);
    int ReleaseData();
    int Clear();
};
```

**主要方法**:
- `LoadData()` - 加载文件数据
- `CompressData()` - 压缩数据
- `CodeData()` - 加密数据
- `SaveData()` - 保存数据到文件
- `ReleaseData()` - 释放数据内存
- `Clear()` - 清空数据

**数据状态**:
- `m_Data` - 当前数据指针（原始/压缩后/加密后）
- `m_DataOriginal` - 原始数据指针
- `m_DataCompress` - 压缩后数据指针
- `m_DataCode` - 加密后数据指针

---

### 2.5 LJFP_PackInfo 类

**文件**: [`LJFP_Pack.h`](../LJFP_Pack.h)

**类声明**:
```cpp
class LJFP_PackInfo
{
public:
    LJFP_FileInfoMap m_FileInfoMap;
    LJFP_FileInfoArr m_FileInfoArr;
    LJFP_PackInfoOneMap m_PackInfoOneMap;
    
    CRC32_Func m_CRC32Func;
    
    LJFP_PackInfo();
    ~LJFP_PackInfo();
    
    unsigned int GetPackCount();
    unsigned int GetFileCount();
    
    int SetFileArea(unsigned int FileArea);
    int SetRootPathName(std::wstring RootPathName);
    int MakePackFileName();
    int Clear();
    
    int AddFileInfo(LJFP_FileInfo* pFileInfo);
    LJFP_FileInfo* GetFileInfo(unsigned int uiIndex);
    LJFP_FileInfo* GetFileInfo(std::wstring wstrPathFileName);
    LJFP_FileInfo* FindFileInfo(unsigned int uiCRC32);
    int LoadFromStream(std::ifstream& FS);
    int LoadFromFile(std::wstring strFileName);
    int SaveToStream(std::ofstream& FS);
    int LoadFromNode(LJFP_Node* FN);
    int SaveToNode(LJFP_Node*& FN);
};
```

**主要方法**:
- `GetPackCount()` - 获取包数量
- `GetFileCount()` - 获取文件总数
- `SetFileArea()` - 设置文件区域
- `AddFileInfo()` - 添加文件信息
- `GetFileInfo()` - 按索引获取文件信息
- `GetFileInfo()` - 按路径名获取文件信息
- `FindFileInfo()` - 按CRC32查找文件信息
- `LoadFromStream()` - 从流加载包信息
- `LoadFromFile()` - 从文件加载包信息
- `LoadFromNode()` - 从节点树加载包信息
- `SaveToStream()` - 保存到流
- `SaveToNode()` - 保存到节点树
- `Clear()` - 清空包信息

**成员变量**:
- `m_FileInfoMap` - 文件信息映射（键=CRC32）
- `m_FileInfoArr` - 文件信息数组
- `m_PackInfoOneMap` - 包统计信息（键=包索引）

---

### 2.6 LJFP_FileList 类

**文件**: [`LJFP_Pack.h`](../LJFP_Pack.h)

**类声明**:
```cpp
class LJFP_FileList
{
public:
    std::map<std::wstring, char> m_PathMapAll;
    std::map<std::wstring, char> m_PathMapPack;
    
    unsigned int m_PackMaxSize;
    
    LJFP_Pack* m_FilePack;
    LJFP_Pack* m_FilePackNo;
    LJFP_Pack* m_FilePackAll;
    
    LJFP_FileList();
    ~LJFP_FileList();
    
    void SetPackMaxSize(unsigned int PackMaxSize);
    int AddFile(std::wstring strRootPathName, std::wstring strParentPathName, std::wstring strFileName, unsigned int Pack, unsigned int CompressType, unsigned int CodeType);
    int MakeDir(std::wstring ExportRootPathName, bool bPack, std::map<std::wstring, char>& PathMap);
    int ExportRes(std::wstring ExportRootPathName, bool bPack, bool bCompress, bool bCode);
};
```

**主要方法**:
- `SetPackMaxSize()` - 设置最大包大小
- `AddFile()` - 添加文件到列表
- `MakeDir()` - 创建目录结构
- `ExportRes()` - 执行导出操作

---

### 2.7 LJFP_Find 类

**文件**: [`LJFP_Find.h`](../LJFP_Find.h)

**类声明**:
```cpp
class LJFP_Find
{
public:
    Find_Func m_FindFunc;
    
    LJFP_Find();
    ~LJFP_Find();
    
    void OnFindDir(std::wstring strRootPathName, std::wstring strParentPathName, std::wstring strDirName);
    void OnFindFile(std::wstring strRootPathName, std::wstring strParentPathName, std::wstring strFileName);
    void OnFindData(std::wstring strRootPathName, std::wstring strParentPathName, WIN32_FIND_DATAW& FindData);
    int FindFiles(std::wstring strRootPathName, std::wstring strParentPathName, std::wstring strPathName);
};
```

**主要方法**:
- `OnFindDir()` - 处理目录发现事件
- `OnFindFile()` - 处理文件发现事件
- `OnFindData()` - 处理文件数据事件
- `FindFiles()` - 递归查找文件

---

### 2.8 LJFP_Option 类

**文件**: [`LJFP_Option.h`](../LJFP_Option.h)

**主要静态方法**:
- `MakeDefaultOption()` - 创建默认配置节点树
- `LoadOption()` - 加载配置文件
- `InitVersion()` - 初始化版本信息
- `InitUpdate()` - 初始化更新信息
- `InitChannel()` - 初始化渠道信息
- `InitExtend()` - 初始化扩展信息
- `IsFilterDir()` - 检查是否过滤目录
- `IsFilterFile()` - 检查是否过滤文件
- `IsPackFile()` - 检查是否打包文件
- `IsCompressFile()` - 检查是否压缩文件
- `IsCodeFile()` - 检查是否加密文件
- `GetFindPath()` - 获取查找路径
- `GetOutputPath()` - 获取输出路径
- `GetOutputType()` - 获取输出类型
- `GetPackMaxSize()` - 获取最大包大小

---

### 2.9 LJFP_Version 类

**文件**: [`LJFP_Version.h`](../LJFP_Version.h)

**主要方法**:
- `VersionCaption2Version()` - 版本号转数字
- `Version2VersionCaption()` - 数字转版本号
- `GetVersion()` - 获取版本号
- `GetVersionBase()` - 获取基础版本号
- `GetVersionMinimum()` - 获取最小版本号
- `SetVersionCaption()` - 设置版本号
- `SetVersionCaptionBase()` - 设置基础版本号
- `SetVersionCaptionMinimum()` - 设置最小版本号
- `SetVersionDonotCheck()` - 设置不检查版本号
- `SetChannel()` - 设置渠道ID
- `SetChannelCaption()` - 设置渠道名称
- `SetAppURL()` - 设置应用URL
- `SetURLInfoArr()` - 设置URL信息数组
- `SetExtendMap()` - 设置扩展映射
- `GetExtendCount()` - 获取扩展数量
- `FindExtendValue()` - 查找扩展值
- `CloneExtendMap()` - 克隆扩展映射
- `LoadFromXMLFile()` - 从XML加载版本信息
- `SaveToXMLFile()` - 保存到XML文件

---

### 2.10 LJFP_ZipFile 类

**文件**: [`LJFP_ZipFile.h`](../LJFP_ZipFile.h)

**类声明**:
```cpp
class LJFP_ZipFile
{
public:
    unsigned int m_uiKey;
    CRC32_Func m_CRC32Func;
    Zip_Func m_ZipFunc;
    UnZip_Func m_UnZipFunc;
    SMS4_Func m_SMS4Func;
    DeSMS4_Func m_DeSMS4Func;
    std::string m_strPassword;
    
    LJFP_ZipFile(unsigned int uiKey, CRC32_Func CRC32Func, Zip_Func ZipFunc, UnZip_Func UnZipFunc, SMS4_Func SMS4Func, DeSMS4_Func DeSMS4Func, std::string strPassword);
    
    ~LJFP_ZipFile();
    
    int ZipStream(std::ifstream& FSSrc, std::ofstream& FSDst);
    int UnZipStream(std::ifstream& FSSrc, std::ofstream& FSDst, unsigned int& SizeDst, unsigned int& CRC32Dst);
    int ZipFile(std::wstring Src, std::wstring Dst);
    int UnZipFile(std::wstring Src, std::wstring Dst);
};
```

**主要方法**:
- `ZipStream()` - 压缩流操作
- `UnZipStream()` - 解压缩流操作
- `ZipFile()` - 压缩文件操作
- `UnZipFile()` - 解压缩文件操作

---

### 2.11 SMS4 类

**文件**: [`LJFP_SMS4.h`](../LJFP_SMS4.h)

**类声明**:
```cpp
class SMS4
{
public:
    unsigned int m_Key[4];
    unsigned int m_RK[32];
    
    SMS4(unsigned char* Mkey);
    ~SMS4();
    
    void KeyExpansion();
    unsigned int T1(unsigned int dwA, unsigned int dwB, unsigned int dwC, unsigned int dwD);
    unsigned int T2(unsigned int dwA, unsigned int dwB, unsigned int dwC, unsigned int dwD);
    void Cipher(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize);
    void InvCipher(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize);
};
```

**主要方法**:
- `KeyExpansion()` - 密钥扩展（32轮）
- `T1()` - 第1轮密钥生成
- `T2()` - 第2轮密钥生成
- `Cipher()` - 加密函数
- `InvCipher()` - 解密函数

---

### 2.12 MiniZ 类

**文件**: [`LJFP_MiniZ.h`](../LJFP_MiniZ.h)

**主要函数**:
- `mz_compress()` - 压缩函数
- `mz_compress2()` - 更高级别压缩
- `mz_uncompress()` - 解压缩函数
- `mz_deflateInit()` - 初始化压缩流
- `mz_inflateInit()` - 初始化解压缩流
- `mz_crc32()` - CRC32计算函数

---

### 2.13 CRC32 类

**文件**: [`LJFP_CRC32.h`](../LJFP_CRC32.h)

**主要函数**:
- `crc32_nn()` - CRC32计算函数
- 查表：`crc32_tab[]` - 256项标准CRC32表

---

## 3. 函数指针类型定义

### 3.1 类型定义

**文件**: [`LJFP_Var.h`](../LJFP_Var.h)

```cpp
typedef unsigned int(*CRC32_Func)(unsigned int crc, const unsigned char* ptr, size_t buf_len);
typedef int(*Zip_Func)(unsigned char *pDest, unsigned int *pDest_len, const unsigned char *pSource, unsigned int source_len, int level);
typedef int(*UnZip_Func)(unsigned char *pDest, unsigned int *pDest_len, const unsigned char *pSource, unsigned int source_len);
typedef void(*SMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword);
typedef void(*DeSMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize);
```

---

## 4. 使用示例

### 4.1 版本号转换

```cpp
// 版本号转数字
unsigned int uiVersion = LJFP_Version::VersionCaption2Version(L"1.0.1");
std::wstring wsVersion = LJFP_Version::Version2VersionCaption(uiVersion);

// 数字转版本号
unsigned int uiVersionBack = LJFP_Version::Version2VersionCaption(wsVersion);
```

### 4.2 配置文件操作

```cpp
// 加载配置文件
LJFP_Option::LoadOption(L"Option.xml");

// 保存配置文件
LJFP_Option::SaveOption(L"Option.xml");
```

### 4.3 文件扫描

```cpp
// 设置查找路径
LJFP_Find find;
find.m_FindFunc = FindOneFile;

// 开始扫描
find.FindFiles(L"Root/", L"", L"");
```

### 4.4 文件打包

```cpp
// 初始化文件列表
LJFP_FileList fileList;
fileList.SetPackMaxSize(52428800);

// 添加文件
fileList.AddFile(L"Root/", L"", L"", 0, 0, 0);

// 导出文件列表
fileList.ExportRes(L"IOS_Pack/", true, false, false);
```

---

## 5. 错误处理

### 5.1 返回值约定

| 返回值 | 含义 | 处理方式 |
|------|------|------|
| 0 | 成功 | 操作成功完成 |
| -1 | 配置文件不存在 | 创建默认配置并继续 |
| -2 | 配置文件解析失败 | 使用默认配置并继续 |
| -99 | 未知错误 | 记录错误并退出 |
| -1 | 文件读取失败 | 跳过该文件 |
| -2 | 文件写入失败 | 检查磁盘空间 |
| -3 | 内存不足 | 减少文件大小或关闭其他程序 |
| -4 | CRC32冲突 | 检测并报告重复文件 |

### 5.2 日志输出

**日志级别**:
- `0` - 绿色（正常信息）
- `1` - 黄色（警告信息）
- `2` - 橙色（错误信息）
- `3` - 红色（严重错误）
- `4` - 紫色（致命错误）
- `5` - 品色（调试信息）
- `6` - 亮白色（成功信息）
- `7` - 亮黄色（警告信息）
- `8` - 亮绿色（提示信息）
- `9` - 亮红色（严重信息）
- `A` - 亮青色（严重错误）
- `B` - 亮品红色（致命错误）
- `C` - 亮洋红（致命错误）
- `D` - 亮白色（成功）
- `E` - 亮洋红（致命错误）
- `F` - 亮白色（成功信息）

**日志内容**:
- 打包进度：文件总数/当前包索引/当前文件
- 错误信息：文件路径/错误类型/错误描述
- 成功信息：操作完成/文件数

---

## 6. 性能优化建议

### 6.1 文件查找优化

- **使用CRC32哈希映射**：将文件路径转换为CRC32作为键，实现O(1)查找
- **批量处理**：减少单次IO操作
- **预分配**：提前分配足够大的缓冲区

### 6.2 内存管理

- **及时释放**：使用RAII模式，确保资源正确释放
- **避免泄漏**：检查所有 `new` 操作都有对应的 `delete`
- **智能指针**：使用智能指针管理对象生命周期

### 6.3 分包策略

- **合理分包**：根据文件大小和类型合理分包
- **避免碎片化**：小文件尽量不单独分包
- **平衡压缩**：根据文件类型选择是否压缩

### 6.4 安全考虑

- **密钥管理**：通过配置文件管理，不应硬编码
- **文件验证**：使用CRC32确保文件完整性
- **加密强度**：使用SMS4国密算法提供足够安全性

---

## 7. 扩展指南

### 7.1 添加新压缩算法

```cpp
// 定义新的压缩函数指针
Zip_Func newZipFunc = mz_compress2;
UnZip_Func newUnZipFunc = mz_uncompress;

// 在 LJFP_ZipFile构造函数中使用新的函数指针
LJFP_ZipFile zf(9999, crc32, newZipFunc, newUnZipFunc, SMS4Ex, DeSMS4Ex, "locojoy123456789");
```

### 7.2 添加新加密算法

```cpp
// 定义新的加密函数指针
SMS4_Func newSMS4Func = SMS4Ex;
DeSMS4_Func newDeSMS4Func = DeSMS4Ex;

// 在 LJFP_ZipFile构造函数中使用新的函数指针
LJFP_ZipFile zf(9999, crc32, newZipFunc, newUnZipFunc, newSMS4Func, newDeSMS4Func, "locojoy123456789");
```

### 7.3 添加新文件格式

```cpp
// 定义新的文件格式处理函数
```

---

## 8. 编译与构建

### 8.1 项目配置

**Visual Studio 2013 (v120)**

**项目文件**:
- [`LJFilePack.sln`](../LJFilePack.sln)
- [`LJFilePack.vcxproj`](../LJFilePack.vcxproj)
- [`LJFilePack.vcxproj.filters`](../LJFilePack.vcxproj.filters)

**配置要求**:
- **字符集**: Unicode
- **运行时库**: MSVCRT (v120)
- **平台工具集**: Windows SDK

### 8.2 编译命令

```bash
# 清理并重新生成
msbuild LJFilePack.sln /t:Rebuild /p:Configuration=Release /p:Platform=Win32

# 单独编译项目
msbuild LJFilePack.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32
```

### 8.3 输出产物

- **可执行文件**: `LJFilePack.exe`
- **输出目录**: 根据配置的OutputPath设置
- **默认位置**: 项目根目录

---

## 9. 附录

### 9.1 文件格式规范

### 9.1 配置文件格式 (Option.xml)

详见第3.2节的XML配置结构。

### 9.2 打包文件格式 (.ljfp)

二进制格式，包含：
- 文件列表
- 文件元数据（位置、大小、CRC32、压缩类型、加密类型）
- 包统计信息

### 9.3 索引文件格式 (.ljpi)

二进制格式，包含：
- 文件索引（按CRC32快速查找）
- 文件详细信息
- 包统计信息

### 9.4 加密索引文件格式 (.ljzip)

ZIP格式，包含：
- 加密的.ljpi文件
- 密钥标识头（4字节）
- 压缩后大小（4字节）
- 原始大小（4字节）
- CRC32（4字节）

---

## 10. 变更日志

### 10.1 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0.0 | 2026-01-13 | 初始版本，完成基础架构文档 |

---

**文档版本**: 1.0.0  
**最后更新**: 2026-01-13

# 03-类继承结构 Class Inheritance

> **版本**: 1.0.0  
> **创建日期**: 2026-01-13  
> **作者**: 系统架构师  
> **项目**: LJFilePack (LJ文件打包工具)

---

## 1. 类继承关系总览

```
                    ┌─────────────────────────────────┐
                    │      LJFP_NodeEx           │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_Node              │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_NodeEx            │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_FileInfo          │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_File              │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_FileInfo          │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_PackInfo         │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_File              │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_Pack             │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_Pack             │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_FileList           │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_File              │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_Find              │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_ZipFile           │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_Option            │
                    └──────────┬──────────────┘
                           │
                    ┌─────────────────────────────────┐
                    │      LJFP_Version           │
                    └──────────┬──────────────┘
```

---

## 2. 核心类继承层次

### 2.1 基础节点类 (LJFP_Node)

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

**职责**:
- 提供通用的树形数据结构
- 管理节点属性和子节点
- 支持二进制序列化和反序列化
- 提供XML文件读写基础

**设计特点**:
- 使用 `std::map` 存储属性和子节点，支持快速查找
- 使用 `WStrList` 维护属性列表顺序
- 虚析构函数确保资源正确释放

**关键方法**:
- `AddNode()` / `AddAttr()` - 添加节点/属性
- `FindNode()` / `FindAttr()` - 查找节点/属性
- `LoadFromStream()` / `LoadFromFile()` - 从流/文件加载
- `SaveToStream()` / `SaveToFile()` - 保存到流/文件

---

### 2.2 扩展节点类 (LJFP_NodeEx)

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
    LJFP_NodeEx* FindNode(std::wstring Name);
    LJFP_NodeEx* FindAndAddNode(std::wstring Name, std::wstring Text = L"");
    
    static int LoadFromXMLNode(LJXML::LJXML_Node<LJXML::Char>* pXMLNode, LJFP_NodeEx* pParentNode, LJFP_NodeEx*& pNode);
    static int LoadFromXMLFile(std::wstring strFileName, LJFP_NodeEx*& pNode);
    static int SaveToXMLNode(LJFP_NodeEx* pNode, LJXML::LJXML_Node<LJXML::Char>* pXMLNodeParent);
    static int SaveToXMLFile(std::wstring strFileName, LJFP_NodeEx* pNode);
};
```

**职责**:
- 扩展基础节点类，添加XML支持
- 继承自 [`LJFP_Node`](../LJFP_Node.h)
- 支持从XML文件加载配置
- 支持保存到XML文件

**新增功能**:
- `LoadFromXMLFile()` - 从XML文件加载节点树
- `SaveToXMLFile()` - 保存节点树到XML文件
- `LoadFromXMLNode()` - 从XML节点加载
- `SaveToXMLNode()` - 保存到XML节点

**设计特点**:
- 重写 `AddNode()` 方法返回 `LJFP_NodeEx*` 类型
- 重写 `FindNode()` 方法返回 `LJFP_NodeEx*` 类型
- 支持XML与二进制格式的双向转换

---

### 2.3 文件信息类 (LJFP_FileInfo)

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

**职责**:
- 存储单个文件的元数据信息
- 支持文件路径计算
- 支持二进制序列化/反序列化
- 支持克隆操作

**成员变量**:
- `m_FileArea` - 文件区域标识（0=散文件，>0=打包文件）
- `m_PackIndex` - 包索引（0=散文件包，>=1=打包文件）
- `m_Pos` - 文件在包中的偏移位置
- `m_Size` - 文件大小（压缩/加密后）
- `m_CRC32` - 文件CRC32校验值
- `m_CompressType` - 压缩类型（0=不压缩，>0=压缩）
- `m_CodeType` - 加密类型（0=不加密，>0=加密）
- `m_SizeOriginal` - 原始文件大小
- `m_CRC32Original` - 原始文件CRC32
- `m_PathFileName` - 文件路径名
- `m_PackFileName` - 包文件名
- `m_PathFileNameCRC32` - 路径名CRC32
- `m_IsUse` - 运行时标记

**关键方法**:
- `Clone()` - 创建文件信息副本
- `GetFullPathFileName()` - 获取完整文件路径
- `LoadFromStream()` / `SaveToStream()` - 流序列化
- `LoadFromFile()` / `SaveToFile()` - 文件序列化

---

### 2.4 包信息类 (LJFP_PackInfo)

**文件**: [`LJFP_FileInfo.h`](../LJFP_FileInfo.h)

**类声明**:
```cpp
class LJFP_PackInfo
{
public:
    LJFP_FileInfoMap m_FileInfoMap;
    LJFP_FileInfoArr m_FileInfoArr;
    LJFP_PackInfoOneMap m_PackInfoOne;
    
    CRC32_Func m_CRC32Func;
    
    LJFP_PackInfo();
    ~LJPFP_PackInfo();
    
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
    int SaveToFile(std::wstring strFileName);
    int LoadFromNode(LJFP_Node* FN);
    int SaveToNode(LJFP_Node*& FN);
};
```

**职责**:
- 管理文件包的索引信息
- 维护文件信息映射（按CRC32快速查找）
- 维护文件信息数组
- 维护各包统计信息
- 支持从节点树加载/保存

**成员变量**:
- `m_FileInfoMap` - 文件信息映射（键=CRC32，值=文件信息指针）
- `m_FileInfoArr` - 文件信息数组
- `m_PackInfoOne` - 各包统计信息（键=包索引，值=统计信息）

**关键方法**:
- `AddFileInfo()` - 添加文件信息到映射和数组
- `GetFileInfo()` - 按索引获取文件信息
- `GetFileInfo()` - 按路径名CRC32获取文件信息
- `FindFileInfo()` - 按CRC32查找文件信息
- `LoadFromNode()` - 从节点树加载包信息
- `SaveToNode()` - 保存到节点树

---

### 2.5 文件类 (LJFP_File)

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
    
    unsigned int m_SizeCompress;
    unsigned int m_CRC32Compress;
    unsigned char* m_DataCompress;
    
    unsigned int m_SizeCode;
    unsigned int m_CRC32Code;
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

**职责**:
- 管理单个文件的完整生命周期
- 执行文件加载、压缩、加密、保存操作
- 管理内存分配和释放

**数据状态管理**:
- `m_Data` - 当前数据指针（指向原始/压缩后/加密后数据）
- `m_DataOriginal` - 原始数据指针
- `m_DataCompress` - 压缩后数据指针
- `m_DataCode` - 加密后数据指针

**关键方法**:
- `LoadData()` - 从文件加载数据
- `CompressData()` - 执行压缩
- `CodeData()` - 执行加密
- `SaveData()` - 保存数据到文件
- `ReleaseData()` - 释放数据内存
- `Clear()` - 清空所有数据

---

### 2.6 文件包类 (LJFP_Pack)

**文件**: [`LJFP_Pack.h`](../LJFP_Pack.h)

**类声明**:
```cpp
class LJFP_Pack
{
public:
    unsigned int m_PackMaxSize;
    std::vector<LJFP_File*> m_FileArr;
    std::map<unsigned int, std::vector<LJFP_File*>> m_FileMap;
    std::map<unsigned int, std::vector<LJFP_File*>> m_SameFileMap;
    
    LJFP_Pack();
    ~LJFP_Pack();
    
    int AddFile(LJFP_File* pFile);
    unsigned int GetFileCount();
    int Clear();
    int CheckSameCRC32();
    int ExportFileInfo(unsigned int PackIndex, std::wstring ExportRootPathName, LJFP_Node* pParentNode, bool bPack, bool bCompress, bool bCode);
    int ExportFileInfoOne(LJFP_Node* pPackNode, LJFP_File* pFile, bool bPack, unsigned int uiIndex);
};
```

**职责**:
- 管理文件包中的文件列表
- 检测并报告重复文件（CRC32冲突）
- 导出文件信息和索引
- 支持分包（按最大包大小限制）

**成员变量**:
- `m_PackMaxSize` - 最大包大小限制
- `m_FileArr` - 文件数组
- `m_FileMap` - 文件映射（按索引）
- `m_SameFileMap` - 重复文件映射

**关键方法**:
- `AddFile()` - 添加文件到列表和映射
- `CheckSameCRC32()` - 检查CRC32重复
- `ExportFileInfo()` - 导出文件信息到节点树
- `ExportFileInfoOne()` - 导出单个文件信息

---

### 2.7 文件列表类 (LJFP_FileList)

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

**职责**:
- 管理整个打包流程
- 维护三个文件包（散文件包、打包文件包、全部文件包）
- 管理路径映射
- 执行导出操作

**成员变量**:
- `m_PathMapAll` - 所有文件路径映射
- `m_PathMapPack` - 打包文件路径映射
- `m_FilePack` - 打包文件（需要打包的文件）
- `m_FilePackNo` - 散文件（不打包）
- `m_FilePackAll` - 全部文件（包括散文件和打包文件）

**关键方法**:
- `SetPackMaxSize()` - 设置最大包大小
- `AddFile()` - 添加文件到对应包
- `MakeDir()` - 创建目录结构
- `ExportRes()` - 执行导出操作

---

### 2.8 文件查找类 (LJFP_Find)

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

**职责**:
- 递归扫描指定目录
- 应用过滤规则
- 调用回调函数处理找到的文件和目录

**核心成员**:
- `m_FindFunc` - 文件发现回调函数指针

**关键方法**:
- `OnFindDir()` - 处理目录发现
- `OnFindFile()` - 处理文件发现
- `OnFindData()` - 处理文件数据
- `FindFiles()` - 递归查找文件

---

### 2.9 配置管理类 (LJFP_Option)

**文件**: [`LJFP_Option.h`](../LJFP_Option.h)

**类声明**:
```cpp
class LJFP_Option
{
public:
    static int MakeDefaultOption(LJFP_NodeEx*& pNode);
    static int CheckOption(LJFP_NodeEx* pNode);
    static int SaveOption(std::wstring strFileName, LJFP_NodeEx* pNode);
    static int LoadOption(std::wstring strFileName, LJFP_NodeEx*& pNode);
    static int LoadOption(std::wstring strFileName);
    
    static int InitOptionOne(std::wstring Node1Name, std::wstring Node2Name, std::wstring Node3Name, std::map<std::wstring, std::wstring>& AttrMap);
    static int InitVersion(std::wstring OptionIndexVersion);
    static int InitUpdate(std::wstring OptionIndexUpdate);
    static int InitChannel(std::wstring OptionIndexChannel);
    static int InitExtend(std::wstring OptionIndexExtend);
    
    static int IsFilterDir(std::wstring strParentPathName, std::wstring strDirName);
    static int IsFilterFile(std::wstring strParentPathName, std::wstring strFileName);
    static int IsPackFile(std::wstring strParentPathName, std::wstring strFileName);
    static int IsCompressFile(std::wstring strParentPathName, std::wstring strFileName);
    static int IsCodeFile(std::wstring strParentPathName, std::wstring strFileName);
    
    static std::wstring GetFindPath(std::wstring OptionIndexIO);
    static std::wstring GetOutputPath(std::wstring OptionIndexIO);
    static bool GetOutputType(std::wstring OptionIndexIO);
    static unsigned int GetPackMaxSize(std::wstring OptionIndexPack);
    
    static int ReleaseOption();
};
```

**职责**:
- 管理配置文件加载和保存
- 初始化默认配置
- 解析版本、更新、渠道、扩展信息
- 提供过滤规则查询接口

**核心静态方法**:
- `MakeDefaultOption()` - 创建默认配置节点树
- `LoadOption()` - 加载配置文件
- `InitVersion()` - 初始化版本信息
- `InitUpdate()` - 初始化更新信息
- `InitChannel()` - 初始化渠道信息
- `InitExtend()` - 初始化扩展信息
- `IsFilterDir()` / `IsFilterFile()` - 过滤检查
- `IsPackFile()` / `IsCompressFile()` / `IsCodeFile()` - 打包规则检查

---

### 2.10 版本管理类 (LJFP_Version)

**文件**: [`LJFP_Version.h`](../LJFP_Version.h)

**类声明**:
```cpp
class LJFP_Version
{
public:
    unsigned int m_uiVersion;
    unsigned int m_uiVersionBase;
    unsigned int m_uiVersionMinimum;
    std::wstring m_VersionCaption;
    std::wstring m_VersionCaptionBase;
    std::wstring m_VersionCaptionMinimum;
    unsigned int m_VersionDonotCheck;
    unsigned int m_uiChannel;
    std::wstring m_ChannelCaption;
    
    std::wstring m_AppURL;
    
    URLInfoArr m_URLInfoArr;
    std::vector<std::wstring> m_URLArr;
    std::vector<std::wstring> m_SystemArr;
    std::vector<std::wstring> m_NetworkArr;
    
    std::map<std::wstring, std::wstring> m_ExtendMap;
    
    LJFP_Version();
    
    static unsigned int VersionCaption2Version(std::wstring VersionCaption);
    static std::wstring Version2VersionCaption(unsigned int Version, int ResultType);
    
    unsigned int GetVersion();
    unsigned int GetVersionBase();
    unsigned int GetVersionMinimum();
    void SetVersionCaption(std::wstring VersionCaption);
    std::wstring GetVersionCaption();
    void SetVersionCaptionBase(std::wstring VersionCaptionBase);
    std::wstring GetVersionCaptionBase();
    void SetVersionCaptionMinimum(std::wstring VersionCaptionMinimum);
    void SetVersionDonotCheck(unsigned int VersionDonotCheck);
    unsigned int GetVersionDonotCheck();
    void SetChannel(unsigned int uiChannel);
    unsigned int GetChannel();
    void SetChannelCaption(std::wstring ChannelCaption);
    std::wstring GetChannelCaption();
    void SetAppURL(std::wstring AppURL);
    void SetURLInfoArr(URLInfoArr UIArr);
    URLInfoArr GetURLInfoArr();
    std::vector<std::wstring> GetURLInfoArr(std::wstring strInfoType);
    void SetExtendMap(std::map<std::wstring, std::wstring> Extend);
    std::map<std::wstring, std::wstring> GetExtendMap();
    unsigned int GetExtendCount();
    std::wstring FindExtendValue(std::wstring wsKey);
    bool GetExtendKeyAndValue(unsigned int uiIndex, std::wstring& wsKey, std::wstring& wsValue);
    void CloneExtendMap(std::map<std::wstring, std::wstring>& ExtendMap);
    
    int LoadFromXMLFile(std::wstring strFileName);
    int SaveToXMLFile(std::wstring strFileName);
    int LoadFromFile(std::wstring strFileName);
    int LoadFromFileEx(std::wstring strFileName, int FileType);
    int SaveToFileEx(std::wstring strFileName, int FileType);
};
```

**职责**:
- 管理版本信息
- 版本号与版本号的双向转换
- 管理更新URL、渠道、扩展信息
- 支持XML和二进制格式的配置文件读写

**版本号格式**:
- 格式：`255.4095.4095`
- 主版本号：8位（0-255）
- 次版本号：12位（0-4095）
- 修订号：12位（0-4095）

**核心方法**:
- `VersionCaption2Version()` - 版本号转数字
- `Version2VersionCaption()` - 数字转版本号
- `LoadFromXMLFile()` / `SaveToXMLFile()` - XML配置读写
- `LoadFromFile()` / `SaveToFile()` - 二进制配置读写

---

### 2.11 ZIP文件封装类 (LJFP_ZipFile)

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
    int UnZipFile(std::wstring Src, std::wstring Dst, unsigned int& SizeDst, unsigned int& CRC32Dst);
};
```

**职责**:
- 封装压缩和加密后的数据为ZIP格式
- 支持自定义密钥
- 生成文件头（密钥标识、压缩后大小、原始大小、CRC32）

**文件头格式**:
```
[密钥标识: 4字节]
[压缩后大小: 4字节]
[原始大小: 4字节]
[CRC32: 4字节]
[数据: ...]
```

---

## 3. 工具类继承关系

### 3.1 字符串工具类

| 类 | 继承关系 | 说明 |
|------|----------|------|
| StringUtil | 无 | 独立工具类，提供字符转换功能 |
| LJFP_StringUtil | 继承StringUtil | 包装StringUtil，提供统一接口 |

### 3.2 文件操作类

| 类 | 继承关系 | 说明 |
|------|----------|------|
| FileUtil | 无 | 独立工具类，提供文件操作功能 |

### 3.3 加密相关类

| 类 | 继承关系 | 说明 |
|------|----------|------|
| SMS4 | 无 | 独立类，实现SMS4加密算法 |
| LJFP_SMS4 | 无 | 独立函数，提供加密/解密接口 |

### 3.4 压缩相关类

| 类 | 继承关系 | 说明 |
|------|----------|------|
| MiniZ | 无 | 内置压缩库（zlib兼容） |
| LJFP_MiniZ | 无 | 包装MiniZ，提供统一接口 |

### 3.5 XML相关类

| 类 | 继承关系 | 说明 |
|------|----------|------|
| LJXML | 无 | 外部XML解析库 |
| LJFP_XML | 无 | 包装LJXML，提供XML节点操作 |

---

## 4. 设计模式与最佳实践

### 4.1 RAII模式

所有类都遵循RAII（Resource Acquisition Is Initialization）模式：
- 构造函数负责初始化所有成员变量
- 析构函数负责释放所有资源
- 确保无资源泄漏

### 4.2 单一职责原则

每个类都有明确的单一职责：
- [`LJFP_Node`] - 节点数据结构管理
- [`LJFP_FileInfo`] - 文件元数据管理
- [`LJFP_PackInfo`] - 包信息管理
- [`LJFP_File`] - 文件数据管理
- [`LJPFP_Find`] - 文件查找
- [`LJFP_Option`] - 配置管理
- [`LJFP_Version`] - 版本管理

### 4.3 依赖注入

通过函数指针实现依赖注入：
- `CRC32_Func` - CRC32函数指针
- `Zip_Func` / `UnZip_Func` - 压缩函数指针
- `SMS4_Func` / `DeSMS4_Func` - 加密函数指针

### 4.4 内存管理

- 使用 `new`/`delete`管理动态内存
- 使用智能指针管理对象生命周期
- 避免内存泄漏和野指针

---

## 5. 扩展点与维护建议

### 5.1 性能优化

- 使用CRC32映射加速文件查找
- 使用分包避免单个文件过大
- 批量操作减少IO次数

### 5.2 安全增强

- 支持SMS4加密保护资源
- 使用CRC32确保文件完整性
- 密钥通过配置文件管理

### 5.3 可维护性

- 模块化设计便于扩展
- 清晰的类继承层次
- 统一的错误处理机制

---

**文档版本**: 1.0.0  
**最后更新**: 2026-01-13

# LJFilePack 架构设计文档

> **文档类型**: 架构设计
> **项目**: LJFilePack (Locojoy File Packager)
> **版本**: 1.0
> **更新日期**: 2025-01-03

---

## 1. 系统概述

### 1.1 设计目标

LJFilePack 的设计目标是提供一个**高效、安全、可配置**的游戏资源打包解决方案：

1. **高效性**: 快速扫描、压缩、加密大量资源文件
2. **安全性**: 使用国密 SM4 算法保护资源不被篡改
3. **可配置性**: 通过 XML 配置灵活控制打包策略
4. **可扩展性**: 支持增量更新和版本管理

### 1.2 系统边界

```
┌─────────────────────────────────────────────────────────────┐
│                        LJFilePack                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  资源扫描    │  │  资源打包    │  │  版本管理    │         │
│  │             │  │             │  │             │         │
│  │  • 递归查找  │  │  • 文件压缩  │  │  • 版本控制  │         │
│  │  • 过滤规则  │  │  • SMS4加密  │  │  • 增量更新  │         │
│  │  • CRC32校验 │  │  • 索引生成  │  │  • 格式转换  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  输入: 资源目录  │    │  输出: .ljfp  │    │  配置: XML   │
│  • 文件       │    │  • .ljpi     │    │  • 版本规则   │
│  • 目录       │    │  • .ljzip    │    │  • 过滤规则   │
└─────────────┘    └─────────────┘    └─────────────┘
```

---

## 2. 模块架构

### 2.1 核心模块层次

```
┌─────────────────────────────────────────────────────────────┐
│                        应用层 (Application)                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  LJFP_Main.h - 命令行入口、参数解析、工作流编排        │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       业务逻辑层 (Business)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ LJFP_Option  │  │ LJFP_Pack    │  │ LJFP_Version │      │
│  │ 配置管理      │  │ 打包核心      │  │ 版本管理      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ LJFP_Find    │  │ LJFP_FileInfo│  │ LJFP_ZipFile │      │
│  │ 文件扫描      │  │ 文件信息      │  │ 压缩加密      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       数据访问层 (Data)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ LJFP_FileUtil│  │ LJFP_XML     │  │ LJFP_Node    │      │
│  │ 文件操作      │  │ XML解析      │  │ 节点结构      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       基础设施层 (Infrastructure)              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ LJFP_MiniZ   │  │ LJFP_SMS4    │  │ LJFP_CRC32   │      │
│  │ 压缩算法      │  │ 加密算法      │  │ 校验算法      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ LJFP_StringUtil│ platform/utils/                       │
│  │ 字符串工具     │ StringUtil.cpp                          │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       系统层 (System)                         │
│  • Windows API (shlwapi, file I/O)                           │
│  • STL (vector, map, string, fstream)                        │
│  • C Runtime Library                                         │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 模块职责矩阵

| 模块 | 输入 | 输出 | 职责 |
|------|------|------|------|
| LJFP_Main | 命令行参数 | 执行状态 | 程序入口、流程控制 |
| LJFP_Option | XML配置 | 配置数据 | 配置解析与管理 |
| LJFP_Find | 目录路径 | 文件列表 | 递归文件扫描 |
| LJFP_Pack | 文件列表 | 资源包 | 打包逻辑实现 |
| LJFP_FileInfo | 文件元数据 | 序列化数据 | 文件信息管理 |
| LJFP_ZipFile | 文件流 | 压缩加密流 | 压缩加密处理 |
| LJFP_Version | 版本配置 | 版本信息 | 版本管理 |
| LJFP_FileUtil | 文件路径 | 操作结果 | 文件系统操作 |
| LJFP_XML | XML文本 | 节点树 | XML解析与生成 |
| LJFP_MiniZ | 数据流 | 压缩流 | 压缩算法 |
| LJFP_SMS4 | 数据流 | 加密流 | 加密算法 |
| LJFP_CRC32 | 数据 | 校验码 | 数据校验 |

---

## 3. 数据结构设计

### 3.1 核心数据结构

#### 3.1.1 LJFP_FileInfo - 文件信息结构

```cpp
struct LJFP_FileInfo {
    // 存储位置信息
    unsigned int m_FileArea;          // 文件区域 (0=包内, 1=散文件)
    unsigned int m_PackIndex;         // 包索引 (0=散文件, 1+=包号)
    unsigned int m_Pos;               // 包内位置 (字节偏移)

    // 当前数据信息
    unsigned int m_Size;              // 当前大小
    unsigned int m_CRC32;             // 当前CRC32
    unsigned int m_CompressType;      // 压缩类型 (0=未压缩)
    unsigned int m_CodeType;          // 加密类型 (0=未加密)

    // 原始数据信息
    unsigned int m_SizeOriginal;      // 原始大小
    unsigned int m_CRC32Original;     // 原始CRC32

    // 路径信息
    std::wstring m_RootPathName;      // 根路径
    std::wstring m_PathFileName;      // 相对路径
    std::wstring m_PackFileName;      // 包文件名
    unsigned int m_PathFileNameCRC32; // 路径CRC32(哈希)

    unsigned int m_IsUse;             // 运行时标记
};
```

**内存布局**: 48字节 (32位系统) / 64字节 (64位系统)

#### 3.1.2 LJFP_PackInfo - 包信息结构

```cpp
class LJFP_PackInfo {
    LJFP_FileInfoMap m_FileInfoMap;   // 哈希索引: CRC32 -> FileInfo*
    LJFP_FileInfoArr m_FileInfoArr;   // 顺序数组
    LJFP_PackInfoOneMap m_PackInfoOne; // 包统计

    // 快速查找接口
    LJFP_FileInfo* GetFileInfo(std::wstring path);
    LJFP_FileInfo* FindFileInfo(unsigned int crc32);
};
```

**查找复杂度**:
- CRC32索引: O(1)
- 顺序遍历: O(n)

#### 3.1.3 LJFP_Version - 版本信息结构

```cpp
class LJFP_Version {
    unsigned int m_uiVersion;         // 当前版本号 (编码)
    unsigned int m_uiVersionBase;     // 基准版本号
    unsigned int m_uiVersionMinimum;  // 最低兼容版本
    unsigned int m_VersionDonotCheck; // 跳过版本检查标志

    unsigned int m_uiChannel;         // 渠道号
    std::wstring m_ChannelCaption;    // 渠道名称
    std::wstring m_AppURL;            // 应用商店URL

    URLInfoArr m_URLInfoArr;          // 更新服务器列表
    std::map<std::wstring, std::wstring> m_ExtendMap; // 扩展信息
};
```

### 3.2 文件格式设计

#### 3.2.1 .ljfp 格式 (打包文件)

```
+──────────────────────────────────────────────────────────────+
│                        LJFP Pack File                        │
+──────────────────────────────────────────────────────────────+
│  File 1 Data                                                 │
│  • Size: N bytes                                             │
│  • Contains: Compressed/Encrypted file data                  │
+──────────────────────────────────────────────────────────────+
│  File 2 Data                                                 │
│  • Size: M bytes                                             │
│  • Contains: Compressed/Encrypted file data                  │
+──────────────────────────────────────────────────────────────+
│  ...                                                         │
+──────────────────────────────────────────────────────────────+
│  File K Data                                                 │
│  • Size: L bytes                                             │
+──────────────────────────────────────────────────────────────+

注意: 文件数据是顺序追加，没有文件头
```

#### 3.2.2 .ljpi 格式 (包信息文件)

```
+──────────────────────────────────────────────────────────────+
│                       LJPI Header                             │
+──────────────────────────────────────────────────────────────+
│  FileCount (uint32)                                          │
│  • Total number of file entries                              │
+──────────────────────────────────────────────────────────────+
│  File Entry 1                                                │
│  ├─ PackIndex (uint32)                                       │
│  ├─ Position (uint32)     [if PackIndex > 0]                 │
│  ├─ Size (uint32)                                            │
│  ├─ CRC32 (uint32)                                           │
│  ├─ CompressType (uint32)                                    │
│  ├─ CodeType (uint32)                                        │
│  ├─ SizeOriginal (uint32)  [if CompressType>0 || CodeType>0] │
│  ├─ CRC32Original (uint32) [if CompressType>0 || CodeType>0] │
│  └─ PathFileNameCRC32 (uint32)                              │
+──────────────────────────────────────────────────────────────+
│  File Entry 2                                                │
│  ...                                                         │
+──────────────────────────────────────────────────────────────+
│  File Entry N                                                │
+──────────────────────────────────────────────────────────────+
```

#### 3.2.3 .ljzip 格式 (加密包信息)

```
+──────────────────────────────────────────────────────────────+
│                      LJZIP File Format                        │
+──────────────────────────────────────────────────────────────+
│  MagicKey (uint32) = 9999                                    │
+──────────────────────────────────────────────────────────────+
│  EncryptedSize (uint32)                                      │
│  • Size of the encrypted data block                          │
+──────────────────────────────────────────────────────────────+
│  EncryptedData (byte array)                                  │
│  • SMS4 encrypted .ljpi file content                         │
+──────────────────────────────────────────────────────────────+
│  CompressedSize (uint32)                                     │
│  • Size before encryption                                    │
+──────────────────────────────────────────────────────────────+
│  OriginalSize (uint32)                                       │
│  • Size before compression                                   │
+──────────────────────────────────────────────────────────────+
│  OriginalCRC32 (uint32)                                      │
│  • CRC32 of original data                                    │
+──────────────────────────────────────────────────────────────+
```

---

## 4. 工作流设计

### 4.1 标准打包流程

```
┌─────────────────────────────────────────────────────────────┐
│                     标准打包工作流                            │
└─────────────────────────────────────────────────────────────┘

     用户命令
        │
        ▼
 ┌────────────┐
 │  参数解析    │ Parse command line arguments
 └────────────┘
        │
        ▼
 ┌────────────┐
 │  加载配置    │ Load LJFilePackOption.xml
 └────────────┘
        │
        ▼
 ┌────────────┐
 │  初始化选项  │ Init version/update/channel/etc.
 └────────────┘
        │
        ▼
 ┌────────────┐
 │  扫描文件    │ Recursively scan source directory
 └────────────┘
        │
        ▼
 ┌────────────┐
 │  过滤文件    │ Apply filter rules
 └────────────┘
        │
        ▼
 ┌────────────┐
 │  分类文件    │ Separate packed/unpacked files
 └────────────┘
        │
        ├─────────────────────────────────────┐
        ▼                                     ▼
 ┌────────────┐                       ┌────────────┐
 │  散文件处理   │                       │  打包文件处理  │
 │  • 不打包     │                       │  • 打包压缩    │
 │  • 单独存储   │                       │  • 分包存储    │
 └────────────┘                       └────────────┘
        │                                     │
        └─────────────────────────────────────┘
                      │
                      ▼
             ┌────────────┐
             │  生成索引    │ Generate .ljpi file
             └────────────┘
                      │
                      ▼
             ┌────────────┐
             │  加密压缩    │ Compress & Encrypt to .ljzip
             └────────────┘
                      │
                      ▼
             ┌────────────┐
             │  生成版本    │ Generate ver.ljvi file
             └────────────┘
                      │
                      ▼
                   完成
```

### 4.2 增量更新流程

```
┌─────────────────────────────────────────────────────────────┐
│                    增量更新工作流                             │
└─────────────────────────────────────────────────────────────┘

    Base版本           New版本
     fl.ljpi            fl.ljpi
         │                  │
         └────────┬─────────┘
                  ▼
         ┌──────────────┐
         │  加载两个版本   │ Load both pack info
         └──────────────┘
                  │
                  ▼
         ┌──────────────┐
         │  逐文件对比    │ Compare by CRC32
         └──────────────┘
                  │
      ┌───────────┼───────────┐
      ▼           ▼           ▼
 ┌────────┐  ┌────────┐  ┌────────┐
 │ 新增文件 │  │ 修改文件 │  │ 删除文件 │
 │  Add   │  │  Mod   │  │  Del   │
 └────────┘  └────────┘  └────────┘
      │           │           │
      └───────────┼───────────┘
                  ▼
         ┌──────────────┐
         │  复制到目标目录 │ Copy to output directory
         └──────────────┘
                  │
                  ▼
         ┌──────────────┐
         │  复制版本文件   │ Copy ver.ljvi and fl.ljzip
         └──────────────┘
                  │
                  ▼
               完成增量包
```

### 4.3 文件处理流程

```
┌─────────────────────────────────────────────────────────────┐
│                    单文件处理流程                             │
└─────────────────────────────────────────────────────────────┐
│                                                              │
│  原始文件                                                    │
│    └─ 大小: SizeO, CRC32: CRC32O                            │
│         │                                                     │
│         ▼                                                     │
│  ┌─────────────┐                                             │
│  │   读取数据   │ Load into memory                           │
│  └─────────────┘                                             │
│         │                                                     │
│         ▼                                                     │
│  ┌─────────────┐     IsCompressFile()                        │
│  │   压缩判断   │ ──────────────────┐                        │
│  └─────────────┘                   │                        │
│         │                          │                        │
│    Yes │                          │ No                     │
│         ▼                          ▼                        │
│  ┌─────────────┐            ┌─────────────┐                 │
│  │   执行压缩   │            │   跳过压缩   │                 │
│  │ mz_compress2│            │   Size = SizeO                 │
│  └─────────────┘            └─────────────┘                 │
│         │                          │                        │
│         └──────────┬───────────────┘                        │
│                    ▼                                         │
│         ┌─────────────┐     IsCodeFile()                     │
│         │   加密判断   │ ──────────────────┐                  │
│         └─────────────┘                   │                  │
│                    │                      │                  │
│               Yes │                      │ No               │
│                    ▼                      ▼                  │
│         ┌─────────────┐            ┌─────────────┐           │
│         │   执行加密   │            │   跳过加密   │           │
│         │   SMS4Ex    │            │                             │
│         └─────────────┘            └─────────────┘           │
│                    │                      │                  │
│                    └──────────┬───────────┘                  │
│                               ▼                              │
│                    ┌─────────────┐                            │
│                    │   保存数据   │ Write to output           │
│                    └─────────────┘                            │
│                               │                              │
│                               ▼                              │
│                         输出文件                             │
│                    └─ 大小: Size, CRC32: CRC                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. 接口设计

### 5.1 命令行接口

```bash
LJFilePack.exe [OPTIONS] [COMMANDS]

OPTIONS:
  version:N       使用第N个版本配置
  update:N        使用第N个更新配置
  channel:N       使用第N个渠道配置
  extend:N        使用第N个扩展配置
  io:N            使用第N个IO配置
  filter:N        使用第N个过滤配置
  pack:N          使用第N个打包配置
  compress:N      使用第N个压缩配置
  code:N          使用第N个加密配置
  nopause         不显示等待提示

COMMANDS:
  getversionnum       版本号转数字工具
  getversioncaption   数字转版本号工具
  verljvi2xml:file    版本文件转XML
  verxml2ljvi:file    XML转版本文件
  ljpi2xml:file       包信息转XML
  ljzip2xml:file      加密包信息转XML
  decode:file         解密文件
  unzip:file          解压文件
  decodeunzip:file    解密并解压
  unpack:file         解包文件
  makeupdatepack:base|new|result
                      生成增量更新包
  makeupdatepackall:configfile
                      批量生成增量包
  ?                   显示帮助
```

### 5.2 配置接口

#### 5.2.1 配置文件结构

```xml
<Root>
    <Version Count="N">
        <N Description="描述">
            <VersionInfo
                VersionCaption="版本号"
                VersionCaptionBase="基准版本"
                VersionCaptionMinimum="最低版本"
                VersionDonotCheck="跳过检查"/>
        </N>
    </Version>
    <Update Count="N">
        <N Description="描述">
            <URLInfo
                AppURL="应用商店URL"
                Count="M">
                <M URL="下载URL" System="ios/android" Network="lan/wan"/>
            </URLInfo>
        </N>
    </Update>
    <Channel Count="N">
        <N Description="描述">
            <ChannelInfo
                Channel="渠道号"
                ChannelCaption="渠道名称"/>
        </N>
    </Channel>
    <Extend Count="N">
        <N Description="描述">
            <ExtendInfo
                Key1="Value1"
                Key2="Value2"/>
        </N>
    </Extend>
    <IO Count="N">
        <N Description="描述"
           FindPath="源目录"
           OutputPath="输出目录"
           OutputType="Pack/File"/>
    </IO>
    <Filter Count="N">
        <N Description="描述">
            <FilterDirName Count="M">...</FilterDirName>
            <FilterDirNameFull Count="M">...</FilterDirNameFull>
            <FilterFileName Count="M">...</FilterFileName>
            <FilterFileNameFull Count="M">...</FilterFileNameFull>
            <FilterFileType Count="M">...</FilterFileType>
        </N>
    </Filter>
    <Pack Count="N">
        <N Description="描述" MaxSize="最大字节数">
            <UnPackFileName Count="M">...</UnPackFileName>
            <UnPackFileNameFull Count="M">...</UnPackFileNameFull>
            <UnPackFileType Count="M">...</UnPackFileType>
        </N>
    </Pack>
    <Compress Count="N">
        <N Description="描述">
            <UnCompressFileName Count="M">...</UnCompressFileName>
            <UnCompressFileNameFull Count="M">...</UnCompressFileNameFull>
            <UnCompressFileType Count="M">...</UnCompressFileType>
        </N>
    </Compress>
    <Code Count="N">
        <N Description="描述">
            <UnCodeFileName Count="M">...</UnCodeFileName>
            <UnCodeFileNameFull Count="M">...</UnCodeFileNameFull>
            <UnCodeFileType Count="M">...</UnCodeFileType>
        </N>
    </Code>
</Root>
```

### 5.3 内部接口

#### 5.3.1 文件处理接口

```cpp
// 文件处理回调
typedef void(*Pack_Func)(
    std::wstring strRootPathName,
    std::wstring strParentPathName,
    std::wstring strFileName,
    unsigned int FileIndex,
    unsigned int FileCount,
    unsigned int PackIndex
);

// 日志回调
typedef void(*Log_Func)(
    std::wstring strText,
    unsigned int uiColor
);

// 文件查找回调
typedef void(*Find_File_Func)(
    std::wstring strRootPathName,
    std::wstring strParentPathName,
    std::wstring strFileName
);
```

#### 5.3.2 算法接口

```cpp
// CRC32 校验函数
typedef unsigned int(*CRC32_Func)(
    unsigned int crc,
    const unsigned char* ptr,
    size_t buf_len
);

// 压缩函数
typedef int(*Zip_Func)(
    unsigned char *pDest,
    unsigned int *pDest_len,
    const unsigned char *pSource,
    unsigned int source_len,
    int level
);

// 解压函数
typedef int(*UnZip_Func)(
    unsigned char *pDest,
    unsigned int *pDest_len,
    const unsigned char *pSource,
    unsigned int source_len
);

// SMS4 加密函数
typedef void(*SMS4_Func)(
    unsigned char* inBuff,
    unsigned char* ouBuff,
    unsigned int uiSize,
    std::string strPassword
);

// SMS4 解密函数
typedef void(*DeSMS4_Func)(
    unsigned char* inBuff,
    unsigned char* ouBuff,
    unsigned int uiSize,
    std::string strPassword
);
```

---

## 6. 并发与性能

### 6.1 性能特征

| 操作 | 复杂度 | 说明 |
|------|--------|------|
| 文件扫描 | O(n) | n = 文件数量 |
| CRC32计算 | O(m) | m = 文件大小 |
| 压缩 | O(m) | 取决于压缩级别 |
| 加密 | O(m) | SM4 分组处理 |
| 文件查找 | O(1) | 哈希索引 |

### 6.2 性能优化点

1. **分包处理**: 单包大小限制为 50MB，避免单个文件过大
2. **选择性压缩**: 对已压缩格式（ogg/mp3/mp4）跳过压缩
3. **哈希索引**: 使用 CRC32 作为文件索引，快速查找
4. **内存管理**: 及时释放处理完的文件数据

### 6.3 性能瓶颈

1. **单线程处理**: 大文件处理时无进度反馈
2. **串行压缩**: 多个文件无法并行压缩
3. **磁盘I/O**: 大量小文件时I/O成为瓶颈

---

## 7. 安全设计

### 7.1 安全机制

| 机制 | 用途 | 强度 |
|------|------|------|
| SMS4加密 | 资料保护 | 中等 |
| CRC32校验 | 完整性验证 | 弱 |
| 版本控制 | 防止降级攻击 | 中等 |

### 7.2 安全风险

1. **密钥硬编码**: 加密密钥直接写在代码中
2. **无混淆**: 资源文件名使用明文
3. **弱校验**: CRC32 容易碰撞
4. **无签名**: 文件包无数字签名

### 7.3 安全建议

```cpp
// 建议 1: 使用配置文件存储密钥
std::string GetEncryptionKey() {
    // 从安全配置或环境变量读取
    return LoadKeyFromSecureStore();
}

// 建议 2: 实现文件名混淆
unsigned int ObfuscateFileName(const std::wstring& filename) {
    return crc32(0, (unsigned char*)filename.c_str(),
                 filename.size() * sizeof(wchar_t));
}

// 建议 3: 添加数字签名
bool VerifySignature(const std::wstring& packageFile,
                     const std::wstring& signatureFile);
```

---

## 8. 扩展设计

### 8.1 扩展点

1. **压缩算法**: 通过 Zip_Func/UnZip_Func 接口扩展
2. **加密算法**: 通过 SMS4_Func/DeSMS4_Func 接口扩展
3. **校验算法**: 通过 CRC32_Func 接口扩展
4. **配置格式**: XML 可扩展到 JSON/YAML

### 8.2 扩展示例

```cpp
// 示例: 使用 LZMA 压缩替代 MiniZ
extern "C" int lzma_compress(...);
extern "C" int lzma_decompress(...);

// 注入自定义压缩实现
LJFP_ZipFile zipper(
    9999,
    crc32,
    lzma_compress,  // 替换 mz_compress2
    lzma_decompress,// 替换 mz_uncompress
    SMS4Ex,
    DeSMS4Ex,
    "locojoy123456789"
);
```

---

**文档版本**: 1.0
**作者**: Claude AI Assistant
**更新日期**: 2025-01-03

# LJFilePack 解密技术方案

> **版本**: 1.0.0  
> **创建日期**: 2026-01-13  
> **文档类型**: 技术方案

---

## 目录

- [1. 执行摘要](#1-执行摘要)
- [2. 文件格式规范](#2-文件格式规范)
- [3. 核心算法分析](#3-核心算法分析)
- [4. 解密流程详解](#4-解密流程详解)
- [5. 数据结构定义](#5-数据结构定义)
- [6. 一键解密工具可行性评估](#6-一键解密工具可行性评估)
- [7. 实现方案](#7-实现方案)
- [8. 安全性分析](#8-安全性分析)
- [9. 附录](#9-附录)

---

## 1. 执行摘要

### 1.1 项目概述

LJFilePack 是梦幻西游 MG 版本游戏的文件打包工具，用于将游戏资源文件打包、压缩、加密，生成 `.ljfp`（打包文件）、`.ljpi`（索引文件）和 `.ljzip`（加密索引文件）格式的资源包。

### 1.2 核心技术栈

| 技术组件 | 实现方式 | 说明 |
|-----------|----------|------|
| **压缩算法** | MiniZ (deflate) | zlib 兼容的压缩库 |
| **加密算法** | SMS4 | 中国国密标准分组密码 |
| **校验算法** | CRC32 | 循环冗余校验 |
| **密码** | 硬编码 | "locojoy123456789" |

### 1.3 解密可行性结论

**结论：完全可行**

基于对源代码的深度分析，LJFilePack 使用的所有算法（MiniZ、SMS4、CRC32）均为公开标准算法，且密码已硬编码在源代码中。因此，构建一键解密工具在技术上完全可行。

---

## 2. 文件格式规范

### 2.1 文件类型

| 扩展名 | 类型 | 说明 |
|---------|------|------|
| `.ljfp` | 打包文件 | 二进制格式，包含压缩/加密后的文件数据 |
| `.ljpi` | 索引文件 | 二进制格式，包含文件索引和元数据 |
| `.ljzip` | 加密索引 | ZIP 格式，包含加密后的 `.ljpi` 文件 |

### 2.2 LJFP_ZipFile 格式（加密压缩文件）

```
┌─────────────────────────────────────────────────────────────────┐
│ LJFP_ZipFile Binary Format                              │
├─────────────────────────────────────────────────────────────────┤
│ Offset   | Size  | Field              │ Description    │
├──────────┼───────┼─────────────────────┼────────────────┤
│ 0x00     | 4      | Key                │ 魔术数 0x270F │
│ 0x04     | 4      | SizeSMS4           │ 加密后数据大小  │
│ 0x08     | N      | DataSMS4           │ SMS4加密数据    │
│ 0x08+N   | 4      | SizeZip            │ 压缩后数据大小  │
│ 0x0C+N   | 4      | SizeSrc            │ 原始数据大小    │
│ 0x10+N   | 4      | CRC32Src           │ 原始数据CRC32  │
└─────────────────────────────────────────────────────────────────┘
```

**字段说明**：
- `Key`: 固定值 `0x270F` (9999)，用于验证文件格式
- `SizeSMS4`: SMS4 加密后的数据字节数
- `DataSMS4`: 经过 SMS4 加密的数据
- `SizeZip`: MiniZ 压缩后的数据字节数
- `SizeSrc`: 原始未压缩数据的字节数
- `CRC32Src`: 原始未压缩数据的 CRC32 校验值

### 2.3 LJFP_FileInfo 结构（文件索引）

```
┌─────────────────────────────────────────────────────────────────┐
│ LJFP_FileInfo Binary Format                             │
├─────────────────────────────────────────────────────────────────┤
│ Offset   | Size  | Field              │ Description    │
├──────────┼───────┼─────────────────────┼────────────────┤
│ 0x00     | 4      | PackIndex          │ 包索引（0=散文件）│
│ 0x04     | 4      | Pos                │ 在包中的位置    │
│ 0x08     | 4      | Size               │ 当前数据大小      │
│ 0x0C     | 4      | CRC32              │ 当前数据CRC32    │
│ 0x10     | 4      | CompressType       │ 压缩类型（0=不压缩）│
│ 0x14     | 4      | CodeType           │ 加密类型（0=不加密）│
│ 0x18     | 4      | SizeOriginal       │ 原始文件大小      │
│ 0x1C     | 4      | CRC32Original       │ 原始文件CRC32    │
│ 0x20     | 4      | PathFileNameCRC32  │ 文件路径CRC32     │
└─────────────────────────────────────────────────────────────────┘
```

**字段说明**：
- `PackIndex`: 文件所属的包索引，0 表示散文件（不在包中）
- `Pos`: 文件在包中的偏移位置（仅 PackIndex > 0 时有效）
- `Size`: 当前处理后的数据大小（可能已压缩/加密）
- `CRC32`: 当前数据的 CRC32 校验值
- `CompressType`: 压缩类型标志
- `CodeType`: 加密类型标志
- `SizeOriginal`: 原始未处理文件大小（仅当 CompressType>0 或 CodeType>0 时存在）
- `CRC32Original`: 原始文件的 CRC32 校验值
- `PathFileNameCRC32`: 文件路径的 CRC32 哈希值

### 2.4 LJFP_PackInfo 结构（包信息）

```
┌─────────────────────────────────────────────────────────────────┐
│ LJFP_PackInfo Binary Format                              │
├─────────────────────────────────────────────────────────────────┤
│ Offset   | Size  | Field              │ Description    │
├──────────┼───────┼─────────────────────┼────────────────┤
│ 0x00     | 4      | FileCount          │ 文件总数        │
│ 0x04     | N      | FileInfoArray      │ 文件信息数组    │
└─────────────────────────────────────────────────────────────────┘
```

**FileInfoArray**: 由多个 `LJFP_FileInfo` 结构组成的数组

---

## 3. 核心算法分析

### 3.1 MiniZ 压缩算法

#### 3.1.1 算法概述

MiniZ 是一个轻量级的 zlib 兼容压缩库，实现了 deflate 压缩算法。

**关键特性**：
- 完全兼容 zlib API
- 支持 0-10 级压缩级别
- 支持原始 deflate 流和 zlib 流（带头部/校验）

#### 3.1.2 压缩函数

```cpp
// 函数签名
int mz_compress2(
    unsigned char *pDest,           // 输出缓冲区
    unsigned int *pDest_len,        // 输出缓冲区大小（输入/输出）
    const unsigned char *pSource,    // 输入数据
    unsigned int source_len,         // 输入数据大小
    int level                       // 压缩级别 (0-10)
);
```

**压缩级别**：
- `0`: 无压缩
- `1`: 最快速度
- `6`: 默认级别（速度/压缩比平衡）
- `9`: 最佳压缩
- `10`: 最高压缩（可能很慢）

#### 3.1.3 解压函数

```cpp
// 函数签名
int mz_uncompress(
    unsigned char *pDest,           // 输出缓冲区
    unsigned int *pDest_len,        // 输出缓冲区大小（输入/输出）
    const unsigned char *pSource,    // 输入数据
    unsigned int source_len          // 输入数据大小
);
```

**返回值**：
- `MZ_OK (0)`: 成功
- `MZ_STREAM_END (1)`: 流结束
- `MZ_DATA_ERROR (-3)`: 数据错误
- `MZ_MEM_ERROR (-4)`: 内存错误
- `MZ_BUF_ERROR (-5)`: 缓冲区错误

### 3.2 SMS4 加密算法

#### 3.2.1 算法概述

SMS4 是中国国家商用密码标准（GM/T 0002-2012）中定义的分组密码算法。

**关键特性**：
- 分组长度：128 位（16 字节）
- 密钥长度：128 位（16 字节）
- 轮数：32 轮
- S 盒：256 字节查找表

#### 3.2.2 密码

```cpp
// 硬编码密码
std::string strPassword = "locojoy123456789";
```

**注意**：密码在源代码中硬编码，这是安全漏洞。

#### 3.2.3 加密流程

```
┌─────────────────────────────────────────────────────────┐
│ SMS4 Encryption Process                               │
├─────────────────────────────────────────────────────────┤
│ 1. 密钥扩展（Key Expansion）                    │
│    - 输入：16 字节密钥                            │
│    - 输出：32 个轮密钥（RK[0]~RK[31]）        │
│                                                  │
│ 2. 分组加密（Block Cipher）                        │
│    - 输入：16 字节明文                          │
│    - 输出：16 字节密文                          │
│    - 处理：32 轮非线性变换                     │
└─────────────────────────────────────────────────────────┘
```

**加密函数签名**：
```cpp
void SMS4Ex(
    unsigned char* inBuff,      // 输入数据
    unsigned char* ouBuff,      // 输出数据
    unsigned int uiSize,         // 数据大小
    std::string strPassword     // 密码
);
```

**处理规则**：
- 数据按 16 字节分组处理
- 最后不足 16 字节的部分不加密，直接复制
- 最大加密 1024 字节（超过部分不加密）

#### 3.2.4 解密流程

```
┌─────────────────────────────────────────────────────────┐
│ SMS4 Decryption Process                               │
├─────────────────────────────────────────────────────────┤
│ 1. 密钥扩展（Key Expansion）                    │
│    - 与加密相同的密钥扩展过程                    │
│                                                  │
│ 2. 分组解密（Block Inverse Cipher）               │
│    - 输入：16 字节密文                          │
│    - 输出：16 字节明文                          │
│    - 处理：32 轮逆变换（轮序相反）           │
└─────────────────────────────────────────────────────────┘
```

**解密函数签名**：
```cpp
void DeSMS4Ex(
    unsigned char* inBuff,      // 输入数据
    unsigned char* ouBuff,      // 输出数据
    unsigned int uiSize,         // 数据大小
    std::string strPassword     // 密码
);
```

**解密关键点**：
- 使用与加密相同的密码
- 轮密钥顺序相反（使用 RK[31]~RK[0]）
- 其他变换与加密相同

#### 3.2.5 S 盒（Sbox）

SMS4 使用 256 字节的 S 盒进行非线性替换：

```cpp
static unsigned char Sbox1[256] = {
    0xd6,0x90,0xe9,0xfe,0xcc,0xe1,0x3d,0xb7,0x16,0xb6,0x14,0xc2,0x28,0xfb,0x2c,0x05,
    // ... 共 256 字节
};
```

### 3.3 CRC32 校验算法

#### 3.3.1 算法概述

CRC32 是一种循环冗余校验算法，用于检测数据传输或存储中的错误。

**关键特性**：
- 多项式：0x04C11DB7
- 初始值：0xFFFFFFFF
- 最终异或：0xFFFFFFFF

#### 3.3.2 CRC32 函数

```cpp
// 函数签名
uint32_t crc32_nn(
    uint32_t crc,              // 初始 CRC 值（通常为 0）
    const void *buf,            // 数据缓冲区
    size_t size                 // 数据大小
);
```

**查找表**：
```cpp
static uint32_t crc32_tab[] = {
    0x00000000, 0x77073096, 0xee0e612c, 0x990951ba,
    // ... 共 256 项
};
```

**计算过程**：
1. 初始化：`crc = crc ^ 0xFFFFFFFF`
2. 对每个字节：
   - `crc = crc32_tab[(crc ^ byte) & 0xFF] ^ (crc >> 8)`
3. 最终：`return crc ^ 0xFFFFFFFF`

---

## 4. 解密流程详解

### 4.1 完整解密流程图

```
┌─────────────────────────────────────────────────────────────────┐
│ LJFilePack 完整解密流程                                │
├─────────────────────────────────────────────────────────────────┤
│                                                          │
│  输入: .ljzip 文件                                      │
│      ↓                                                  │
│  ┌──────────────────────────────────────┐                 │
│  │ 1. 解压 ZIP 文件                │                 │
│  │    - 使用 MiniZ 解压 .ljzip               │                 │
│  │    - 获取 .ljpi 文件内容                 │                 │
│  └──────────────────────────────────────┘                 │
│      ↓                                                  │
│  输出: .ljpi 文件（二进制索引数据）                     │
│      ↓                                                  │
│  ┌──────────────────────────────────────┐                 │
│  │ 2. 解析 .ljpi 文件               │                 │
│  │    - 读取 FileCount (4 字节)               │                 │
│  │    - 读取 FileInfoArray (N 个 FileInfo)     │                 │
│  └──────────────────────────────────────┘                 │
│      ↓                                                  │
│  输出: LJFP_FileInfo 数组                               │
│      ↓                                                  │
│  ┌──────────────────────────────────────┐                 │
│  │ 3. 遍历每个文件                    │                 │
│  │    对每个 FileInfo:                                  │                 │
│  │      ↓                                              │                 │
│  │  ┌────────────────────────────────┐                │                 │
│  │  │ 4. 读取 .ljfp 包文件     │                │                 │
│  │  │    - 定位到 Pos 偏移       │                │                 │
│  │  │    - 读取 Size 字节数据     │                │                 │
│  │  └────────────────────────────────┘                │                 │
│  │      ↓                                          │                 │
│  │  ┌────────────────────────────────┐                │                 │
│  │  │ 5. 解密数据               │                │                 │
│  │  │    if (CodeType > 0):                      │                │                 │
│  │  │      DeSMS4Ex(Data, DecryptedData, Size,  │                │                 │
│  │  │                  "locojoy123456789")         │                │                 │
│  │  └────────────────────────────────┘                │                 │
│  │      ↓                                          │                 │
│  │  ┌────────────────────────────────┐                │                 │
│  │  │ 6. 解压数据               │                │                 │
│  │  │    if (CompressType > 0):                  │                │                 │
│  │  │      mz_uncompress(UncompressedData,            │                │                 │
│  │  │                   &UncompressedSize,            │                │                 │
│  │  │                   DecryptedData,               │                │                 │
│  │  │                   DecryptedSize)              │                │                 │
│  │  └────────────────────────────────┘                │                 │
│  │      ↓                                          │                 │
│  │  ┌────────────────────────────────┐                │                 │
│  │  │ 7. CRC32 校验             │                │                 │
│  │  │    if (CRC32Original > 0):                │                 │                 │
│  │  │      computed = crc32_nn(0,                 │                │                 │
│  │  │                      UncompressedData,           │                │                 │
│  │  │                      UncompressedSize)           │                │                 │
│  │  │      if (computed != CRC32Original):          │                │                 │
│  │  │        错误：CRC32 校验失败                │                 │
│  │  └────────────────────────────────┘                │                 │
│  │      ↓                                          │                 │
│  │  ┌────────────────────────────────┐                │                 │
│  │  │ 8. 写入原始文件          │                │                 │
│  │  │    - 使用 PathFileNameCRC32 查找文件名    │                │                 │
│  │  │    - 写入 UncompressedData 到文件          │                │                 │
│  │  └────────────────────────────────┘                │                 │
│  └──────────────────────────────────────┘                 │
│      ↓                                                  │
│  输出: 原始资源文件                                      │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 解密步骤详解

#### 步骤 1：解压 ZIP 文件

```cpp
// 使用 MiniZ 解压 .ljzip 文件
mz_zip_archive zip_archive;
mz_zip_reader_init_file(&zip_archive, "index.ljzip", 0);

// 读取加密的 .ljpi 文件
size_t ljpi_size;
void* ljpi_data = mz_zip_reader_extract_to_heap(
    &zip_archive, 
    "fl.ljpi", 
    &ljpi_size, 
    0
);

mz_zip_reader_end(&zip_archive);
```

#### 步骤 2：解析 .ljpi 文件

```cpp
// 读取文件数量
unsigned int file_count;
memcpy(&file_count, ljpi_data, 4);

// 分配 FileInfo 数组
std::vector<LJFP_FileInfo*> file_infos;
for (unsigned int i = 0; i < file_count; i++) {
    LJFP_FileInfo* info = new LJFP_FileInfo();
    info->LoadFromStream(stream);
    file_infos.push_back(info);
}
```

#### 步骤 3：读取 .ljfp 包文件

```cpp
// 对每个文件
for (auto* info : file_infos) {
    if (info->m_PackIndex > 0) {
        // 打开对应的 .ljfp 包文件
        std::wstring pack_file = L"pack_" + 
            std::to_wstring(info->m_PackIndex) + L".ljfp";
        std::ifstream pack_stream(ws2s(pack_file), 
                               std::ios_base::binary);
        
        // 定位到文件位置
        pack_stream.seekg(info->m_Pos, std::ios_base::beg);
        
        // 读取数据
        unsigned char* data = new unsigned char[info->m_Size];
        pack_stream.read((char*)data, info->m_Size);
    }
}
```

#### 步骤 4：解密数据

```cpp
// 如果文件已加密
if (info->m_CodeType > 0) {
    unsigned char* decrypted = new unsigned char[info->m_Size];
    
    // SMS4 解密
    DeSMS4Ex(
        data,              // 加密数据
        decrypted,          // 解密后数据
        info->m_Size,      // 数据大小
        "locojoy123456789"  // 密码
    );
    
    // 更新数据指针
    delete[] data;
    data = decrypted;
}
```

#### 步骤 5：解压数据

```cpp
// 如果文件已压缩
if (info->m_CompressType > 0) {
    // 计算解压后大小
    unsigned int uncompressed_size = info->m_SizeOriginal;
    unsigned char* uncompressed = new unsigned char[uncompressed_size];
    
    // MiniZ 解压
    int result = mz_uncompress(
        uncompressed,                // 输出缓冲区
        &uncompressed_size,          // 缓冲区大小（输入/输出）
        data,                       // 压缩数据
        info->m_Size               // 压缩数据大小
    );
    
    if (result != MZ_OK) {
        // 处理解压错误
        delete[] data;
        delete[] uncompressed;
        continue;
    }
    
    // 更新数据指针
    delete[] data;
    data = uncompressed;
    info->m_Size = uncompressed_size;
}
```

#### 步骤 6：CRC32 校验

```cpp
// 如果有原始 CRC32
if (info->m_CRC32Original > 0) {
    // 计算解压后数据的 CRC32
    unsigned int computed_crc = crc32_nn(
        0,                      // 初始值
        data,                    // 数据
        info->m_SizeOriginal      // 数据大小
    );
    
    // 验证 CRC32
    if (computed_crc != info->m_CRC32Original) {
        // CRC32 校验失败
        wprintf(L"CRC32 校验失败: %s\n", 
                 info->m_PathFileName.c_str());
        delete[] data;
        continue;
    }
}
```

#### 步骤 7：写入原始文件

```cpp
// 构建输出文件路径
std::wstring output_path = L"output/" + info->m_PathFileName;

// 写入文件
std::ofstream out_stream(ws2s(output_path), std::ios_base::binary);
out_stream.write((char*)data, info->m_SizeOriginal);
out_stream.close();

// 释放内存
delete[] data;
```

---

## 5. 数据结构定义

### 5.1 LJFP_ZipFile 结构

```cpp
class LJFP_ZipFile {
public:
    unsigned int m_uiKey;              // 魔术数 0x270F
    CRC32_Func m_CRC32Func;          // CRC32 函数指针
    Zip_Func m_ZipFunc;              // 压缩函数指针
    UnZip_Func m_UnZipFunc;          // 解压函数指针
    SMS4_Func m_SMS4Func;            // 加密函数指针
    DeSMS4_Func m_DeSMS4Func;        // 解密函数指针
    std::string m_strPassword;         // 密码

    // 压缩流
    int ZipStream(std::ifstream& FSSrc, std::ofstream& FSDst);
    
    // 压缩文件
    int ZipFile(std::wstring Src, std::wstring Dst);
    
    // 解压流
    int UnZipStream(std::ifstream& FSSrc, std::ofstream& FSDst, 
                   unsigned int& SizeDst, unsigned int& CRC32Dst);
    
    // 解压文件
    int UnZipFile(std::wstring Src, std::wstring Dst);
};
```

### 5.2 LJFP_FileInfo 结构

```cpp
class LJFP_FileInfo {
public:
    // 文件位置信息
    unsigned int m_FileArea;           // 文件区域
    unsigned int m_PackIndex;          // 包索引（0=散文件）
    unsigned int m_Pos;                // 在包中的位置
    
    // 当前数据信息
    unsigned int m_Size;               // 当前数据大小
    unsigned int m_CRC32;              // 当前数据 CRC32
    unsigned int m_CompressType;       // 压缩类型（0=不压缩）
    unsigned int m_CodeType;           // 加密类型（0=不加密）
    
    // 原始文件信息
    unsigned int m_SizeOriginal;       // 原始文件大小
    unsigned int m_CRC32Original;       // 原始文件 CRC32
    
    // 文件路径信息
    std::wstring m_RootPathName;      // 根路径
    std::wstring m_PathFileName;        // 路径文件名
    std::wstring m_PackFileName;       // 包文件名
    unsigned int m_PathFileNameCRC32;  // 路径文件名 CRC32
    unsigned int m_IsUse;             // 运行时使用标志
    
    // 方法
    int LoadFromStream(std::ifstream& FS);
    int LoadFromFile(std::wstring strFileName);
    int SaveToStream(std::ofstream& FS);
    int SaveToFile(std::wstring strFileName);
    LJFP_FileInfo* Clone();
    std::wstring GetFullPathFileName();
};
```

### 5.3 LJFP_PackInfo 结构

```cpp
class LJFP_PackInfo {
public:
    LJFP_FileInfoMap m_FileInfoMap;      // 文件信息映射（CRC32 -> FileInfo）
    LJFP_FileInfoArr m_FileInfoArr;      // 文件信息数组
    LJFP_PackInfoOneMap m_PackInfoOne;  // 包信息映射（PackIndex -> PackInfoOne）
    CRC32_Func m_CRC32Func;             // CRC32 函数指针
    
    // 方法
    int SetFileArea(unsigned int FileArea);
    int SetRootPathName(std::wstring RootPathName);
    int MakePackFileName();
    int Clear();
    unsigned int GetPackCount();
    unsigned int GetFileCount();
    int AddFileInfo(LJFP_FileInfo* pFileInfo);
    LJFP_FileInfo* GetFileInfo(unsigned int uiIndex);
    LJFP_FileInfo* GetFileInfo(std::wstring wstrPathFileName);
    LJFP_FileInfo* FindFileInfo(unsigned int uiCRC32);
    int LoadFromStream(std::ifstream& FS);
    int LoadFromFile(std::wstring strFileName);
    int SaveToStream(std::ofstream& FS);
    int SaveToFile(std::wstring strFileName);
    int LoadFromNode(LJFP_Node* FN);
    unsigned int GetFileIndexInPack(unsigned int uiFileIndex, 
                                   unsigned int uiPackIndex);
    int SaveToNode(LJFP_Node*& FN);
};
```

---

## 6. 一键解密工具可行性评估

### 6.1 技术可行性

| 评估项 | 结果 | 说明 |
|---------|------|------|
| **算法公开性** | ✅ 完全可行 | MiniZ、SMS4、CRC32 均为公开标准算法 |
| **密码获取** | ✅ 完全可行 | 密码硬编码在源代码中 |
| **文件格式** | ✅ 完全可行 | 文件格式已完全逆向 |
| **依赖库** | ✅ 完全可行 | MiniZ 为单头文件库，无外部依赖 |
| **实现复杂度** | ✅ 中等 | 需要实现 ZIP 解压、SMS4 解密、MiniZ 解压 |

**结论**：技术上完全可行，无任何阻碍因素。

### 6.2 实现难度评估

| 模块 | 难度 | 工作量 | 说明 |
|------|--------|---------|------|
| ZIP 解压 | ⭐ 低 | 2-4 小时 | MiniZ 已提供完整 API |
| SMS4 解密 | ⭐⭐ 中 | 4-8 小时 | 需要实现密钥扩展和分组解密 |
| MiniZ 解压 | ⭐ 低 | 1-2 小时 | 直接调用 mz_uncompress |
| 文件格式解析 | ⭐ 低 | 2-3 小时 | 二进制格式简单 |
| CRC32 校验 | ⭐ 低 | 1 小时 | 直接调用 crc32_nn |
| 错误处理 | ⭐⭐ 中 | 2-3 小时 | 需要处理各种错误情况 |
| **总计** | ⭐⭐ 中 | **12-21 小时** | 约 1.5-3 个工作日 |

### 6.3 风险评估

| 风险类型 | 风险等级 | 缓解措施 |
|-----------|-----------|-----------|
| **密码变更** | 低 | 当前密码硬编码，若变更需重新分析 |
| **文件格式变更** | 低 | 当前格式已稳定，若变更需重新逆向 |
| **性能问题** | 低 | 大文件解密可能较慢，可优化 |
| **内存占用** | 中 | 大文件需要较多内存，可使用流式处理 |
| **兼容性问题** | 低 | 算法为标准实现，兼容性良好 |

### 6.4 性能预估

| 操作类型 | 预估性能 | 说明 |
|---------|-----------|------|
| **ZIP 解压** | 50-100 MB/s | 取决于磁盘 I/O |
| **SMS4 解密** | 200-500 MB/s | 纯内存操作，速度快 |
| **MiniZ 解压** | 20-50 MB/s | 取决于压缩比 |
| **CRC32 校验** | 500-1000 MB/s | 使用查找表，速度快 |
| **整体解密** | 10-30 MB/s | 综合所有操作 |

---

## 7. 实现方案

### 7.1 工具架构设计

```
┌─────────────────────────────────────────────────────────────────┐
│ LJFilePack 解密工具架构                                │
├─────────────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────┐             │
│  │ 命令行接口 (CLI)                    │             │
│  │  - 解析命令行参数                          │             │
│  │  - 显示进度信息                              │             │
│  │  - 错误处理                                  │             │
│  └────────────────────────────────────────────┘             │
│      ↓                                                  │
│  ┌────────────────────────────────────────────┐             │
│  │ 文件解析模块 (File Parser)              │             │
│  │  - 解析 .ljzip 文件                        │             │
│  │  - 解析 .ljpi 文件                         │             │
│  │  - 解析 .ljfp 文件                         │             │
│  └────────────────────────────────────────────┘             │
│      ↓                                                  │
│  ┌────────────────────────────────────────────┐             │
│  │ 解密模块 (Decryption)                    │             │
│  │  - SMS4 解密                                  │             │
│  │  - MiniZ 解压                                 │             │
│  │  - CRC32 校验                                 │             │
│  └────────────────────────────────────────────┘             │
│      ↓                                                  │
│  ┌────────────────────────────────────────────┐             │
│  │ 文件输出模块 (File Output)                │             │
│  │  - 写入原始文件                              │             │
│  │  - 保持目录结构                              │             │
│  │  - 文件名映射                                │             │
│  └────────────────────────────────────────────┘             │
│                                                          │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 核心类设计

#### LJFPDecryptor 类

```cpp
class LJFPDecryptor {
public:
    // 构造函数
    LJFPDecryptor(const std::wstring& password = L"locojoy123456789");
    
    // 析构函数
    ~LJFPDecryptor();
    
    // 解密单个文件
    int DecryptFile(const std::wstring& ljzip_path,
                  const std::wstring& output_dir);
    
    // 批量解密
    int DecryptBatch(const std::vector<std::wstring>& ljzip_files,
                     const std::wstring& output_dir);
    
    // 设置进度回调
    void SetProgressCallback(ProgressCallback callback);
    
private:
    std::wstring m_password;
    ProgressCallback m_progress_callback;
    
    // 内部方法
    int ExtractZipFile(const std::wstring& zip_path);
    int ParseLJPIFile(const std::vector<unsigned char>& data);
    int DecryptLJFPFile(const LJFP_FileInfo& info,
                        const std::wstring& pack_path,
                        const std::wstring& output_path);
    int SMS4Decrypt(const unsigned char* input,
                   unsigned char* output,
                   unsigned int size);
    int MiniZDecompress(const unsigned char* input,
                       unsigned char* output,
                       unsigned int input_size,
                       unsigned int& output_size);
    unsigned int CRC32Compute(const unsigned char* data,
                           unsigned int size);
};

// 进度回调函数类型
typedef void (*ProgressCallback)(
    const std::wstring& current_file,
    unsigned int current_index,
    unsigned int total_files,
    unsigned int progress_percent
);
```

### 7.3 实现步骤

#### 阶段 1：项目初始化（1 小时）

```bash
# 创建项目目录
mkdir ljfp_decryptor
cd ljfp_decryptor

# 创建源文件目录
mkdir src
mkdir include
mkdir lib

# 初始化 CMake 项目
# 或使用 VS2013 项目文件
```

#### 阶段 2：集成 MiniZ（1 小时）

```cpp
// 将 LJFP_MiniZ.h 复制到项目中
// 配置为单头文件库
#define MINIZ_HEADER_FILE_ONLY
#include "miniz.h"
```

#### 阶段 3：实现 SMS4 解密（4-6 小时）

```cpp
// SMS4 解密实现
class SMS4Decryptor {
private:
    unsigned int m_rk[32];  // 轮密钥
    
public:
    SMS4Decryptor(const std::string& password);
    
    void DecryptBlock(unsigned char* input, 
                  unsigned char* output);
    
private:
    void KeyExpansion(const unsigned char* key);
    unsigned int T1(unsigned int dwA);
    unsigned int T2(unsigned int dwA);
};
```

#### 阶段 4：实现文件解析（2-3 小时）

```cpp
// LJFP 文件解析器
class LJFPFileParser {
public:
    static LJFP_FileInfo* ParseFileInfo(
        const unsigned char* data,
        unsigned int offset);
    
    static LJFP_PackInfo* ParsePackInfo(
        const unsigned char* data);
};
```

#### 阶段 5：实现主解密流程（3-4 小时）

```cpp
// 主解密流程
int LJFPDecryptor::DecryptFile(
    const std::wstring& ljzip_path,
    const std::wstring& output_dir) {
    
    // 1. 解压 ZIP 文件
    std::vector<unsigned char> ljpi_data;
    int result = ExtractZipFile(ljzip_path, ljpi_data);
    if (result != 0) return result;
    
    // 2. 解析 .ljpi 文件
    std::vector<LJFP_FileInfo*> file_infos;
    result = ParseLJPIFile(ljpi_data, file_infos);
    if (result != 0) return result;
    
    // 3. 解密每个文件
    for (size_t i = 0; i < file_infos.size(); i++) {
        if (m_progress_callback) {
            m_progress_callback(
                file_infos[i]->m_PathFileName,
                i + 1,
                file_infos.size(),
                (i + 1) * 100 / file_infos.size()
            );
        }
        
        result = DecryptLJFPFile(*file_infos[i], output_dir);
        if (result != 0) {
            // 继续处理其他文件
            continue;
        }
    }
    
    return 0;
}
```

#### 阶段 6：测试与优化（2-3 小时）

```bash
# 编译项目
cmake -B build -S . -G "Visual Studio 12 2013"
cmake --build build --config Release

# 测试解密工具
.\Release\ljfp_decryptor.exe test.ljzip output\

# 性能分析
# 使用性能分析工具优化关键路径
```

### 7.4 命令行接口设计

```bash
# 基本用法
ljfp_decryptor.exe <input.ljzip> [output_dir]

# 示例
ljfp_decryptor.exe game_resources.ljzip .\extracted

# 高级选项
ljfp_decryptor.exe <input.ljzip> [output_dir] [options]

选项:
  -p, --password <pwd>    指定解密密码（默认: locojoy123456789）
  -v, --verbose            显示详细输出
  -q, --quiet              静默模式
  -f, --force              强制覆盖已存在文件
  --no-crc32              跳过 CRC32 校验
  --no-decompress          跳过解压（仅解密）
  --no-decrypt            跳过解密（仅解压）
  -h, --help               显示帮助信息
```

### 7.5 错误处理策略

```cpp
// 错误代码定义
enum LJFPError {
    LJFP_OK = 0,
    LJFP_ERR_FILE_NOT_FOUND = -1,
    LJFP_ERR_INVALID_FORMAT = -2,
    LJFP_ERR_DECRYPT_FAILED = -3,
    LJFP_ERR_DECOMPRESS_FAILED = -4,
    LJFP_ERR_CRC32_MISMATCH = -5,
    LJFP_ERR_OUT_OF_MEMORY = -6,
    LJFP_ERR_INVALID_PASSWORD = -7,
    LJFP_ERR_IO_ERROR = -8
};

// 错误消息映射
const wchar_t* GetErrorMessage(LJFPError error) {
    switch (error) {
        case LJFP_OK: return L"操作成功";
        case LJFP_ERR_FILE_NOT_FOUND: return L"文件未找到";
        case LJFP_ERR_INVALID_FORMAT: return L"无效的文件格式";
        case LJFP_ERR_DECRYPT_FAILED: return L"解密失败";
        case LJFP_ERR_DECOMPRESS_FAILED: return L"解压失败";
        case LJFP_ERR_CRC32_MISMATCH: return L"CRC32 校验失败";
        case LJFP_ERR_OUT_OF_MEMORY: return L"内存不足";
        case LJFP_ERR_INVALID_PASSWORD: return L"无效的密码";
        case LJFP_ERR_IO_ERROR: return L"IO 错误";
        default: return L"未知错误";
    }
}
```

---

## 8. 安全性分析

### 8.1 当前安全漏洞

| 漏洞类型 | 严重程度 | 说明 |
|-----------|-----------|------|
| **硬编码密码** | 🔴 高 | 密码 "locojoy123456789" 硬编码在源代码中 |
| **无密钥派生** | 🟡 中 | 直接使用密码字符串，未使用密钥派生函数 |
| **无完整性保护** | 🟡 中 | 仅使用 CRC32 校验，可被篡改 |
| **无防篡改机制** | 🟡 中 | 缺少数字签名或 HMAC |

### 8.2 安全建议

| 建议 | 优先级 | 实现难度 |
|------|--------|-----------|
| **使用密钥派生** | 高 | 低 |
| **添加数字签名** | 高 | 中 |
| **使用更强的加密算法** | 中 | 高 |
| **实现密钥轮换** | 高 | 低 |
| **添加完整性保护** | 中 | 低 |

---

## 9. 附录

### 9.1 术语表

| 术语 | 英文 | 说明 |
|------|------|------|
| 分组密码 | Block Cipher | 将明文分成固定长度的分组进行加密的算法 |
| 轮密钥 | Round Key | 每一轮加密使用的子密钥 |
| S 盒 | S-Box | 用于非线性替换的查找表 |
| 密钥扩展 | Key Expansion | 从主密钥生成轮密钥的过程 |
| 循环冗余校验 | CRC | 用于检测数据传输错误的校验算法 |
| 压缩级别 | Compression Level | 控制压缩速度与压缩比的参数 |

### 9.2 参考资料

| 资源 | 链接 |
|------|------|
| MiniZ 官方仓库 | https://github.com/richgel999/miniz |
| SMS4 国密标准 | GM/T 0002-2012 |
| zlib 规范 | RFC 1950, RFC 1951 |
| CRC32 算法 | https://create.stephan-brumme.de/Fehler/Crc32.htm |

### 9.3 代码示例

#### 示例 1：SMS4 密钥扩展

```cpp
void SMS4Decryptor::KeyExpansion(const unsigned char* key) {
    unsigned int K[4];
    
    // 将 16 字节密钥转换为 4 个 32 位整数
    for (int i = 0; i < 4; i++) {
        K[i] = key[i * 4 + 0] << 24 | 
                key[i * 4 + 1] << 16 | 
                key[i * 4 + 2] << 8 | 
                key[i * 4 + 3];
    }
    
    // FK 参数
    static const unsigned int FK[4] = {
        0xA3B1BAC6, 0x56AA3350, 
        0x677D9197, 0xB27022DC
    };
    
    // CK 参数
    static const unsigned int CK[32] = {
        0x00070e15, 0x1c232a31, 0x383f464d, 0x545b6269,
        0x70777e85, 0x8c939aa1, 0xa8afb6bd, 0xc4cbd2d9,
        0xe0e7eef5, 0xfc030a11, 0x181f262d, 0x343b4249,
        0x50575e65, 0x6c737a81, 0x888f969d, 0xa4abb2b9,
        0xc0c7ced5, 0xdce3eaf1, 0xf8ff060d, 0x141b2229,
        0x30373e45, 0x4c535a61, 0x686f767d, 0x848b9299,
        0xa0a7aeb5, 0xbcc3cad1, 0xd8dfe6ed, 0xf4fb0209,
        0x10171e25, 0x2c333a41, 0x484f565d, 0x646b7279,
        0x848b9299, 0xa0a7aeb5, 0xbcc3cad1, 0xd8dfe6ed,
        0xf4fb0209, 0x10171e25, 0x2c333a41, 0x484f565d
    };
    
    // 生成 32 个轮密钥
    for (int i = 0; i < 4; i++) {
        K[i] ^= FK[i];
    }
    
    for (int i = 0; i < 32; i++) {
        K[i % 4] ^= T2(K[(i + 1) % 4] ^ 
                        K[(i + 2) % 4] ^ 
                        K[(i + 3) % 4] ^ 
                        CK[i]);
        m_rk[i] = K[i % 4];
    }
}
```

#### 示例 2：SMS4 分组解密

```cpp
void SMS4Decryptor::DecryptBlock(unsigned char* input, 
                               unsigned char* output) {
    unsigned int X[4];
    
    // 将输入转换为 4 个 32 位整数
    for (int i = 0; i < 4; i++) {
        X[i] = input[i * 4 + 0] << 24 | 
               input[i * 4 + 1] << 16 | 
               input[i * 4 + 2] << 8 | 
               input[i * 4 + 3];
    }
    
    // 32 轮解密（轮序相反）
    for (int i = 0; i < 32; i++) {
        X[i % 4] ^= T1(X[(i + 1) % 4] ^ 
                       X[(i + 2) % 4] ^ 
                       X[(i + 3) % 4] ^ 
                       m_rk[31 - i]);  // 注意：使用逆序轮密钥
    }
    
    // 输出反转
    for (int i = 0; i < 4; i++) {
        output[i * 4 + 0] = (X[3 - i] >> 24) & 0xFF;
        output[i * 4 + 1] = (X[3 - i] >> 16) & 0xFF;
        output[i * 4 + 2] = (X[3 - i] >> 8) & 0xFF;
        output[i * 4 + 3] = X[3 - i] & 0xFF;
    }
}
```

#### 示例 3：完整解密流程

```cpp
int DecryptLJFPFile(const LJFP_FileInfo& info,
                  const std::wstring& pack_path,
                  const std::wstring& output_path) {
    
    // 1. 读取加密数据
    std::ifstream pack_stream(ws2s(pack_path), std::ios_base::binary);
    pack_stream.seekg(info->m_Pos, std::ios_base::beg);
    
    unsigned char* encrypted_data = new unsigned char[info->m_Size];
    pack_stream.read((char*)encrypted_data, info->m_Size);
    pack_stream.close();
    
    unsigned char* current_data = encrypted_data;
    unsigned int current_size = info->m_Size;
    
    // 2. SMS4 解密
    if (info->m_CodeType > 0) {
        unsigned char* decrypted_data = new unsigned char[current_size];
        SMS4Decryptor sms4("locojoy123456789");
        
        for (unsigned int i = 0; i < current_size; i += 16) {
            unsigned int block_size = min(16, current_size - i);
            sms4.DecryptBlock(current_data + i, decrypted_data + i);
            if (block_size < 16) {
                // 最后不足 16 字节直接复制
                memcpy(decrypted_data + i + 16 - block_size,
                       current_data + i + 16 - block_size,
                       block_size);
            }
        }
        
        delete[] current_data;
        current_data = decrypted_data;
    }
    
    // 3. MiniZ 解压
    if (info->m_CompressType > 0) {
        unsigned int uncompressed_size = info->m_SizeOriginal;
        unsigned char* uncompressed_data = new unsigned char[uncompressed_size];
        
        int result = mz_uncompress(
            uncompressed_data,
            &uncompressed_size,
            current_data,
            current_size
        );
        
        if (result != MZ_OK) {
            delete[] current_data;
            delete[] uncompressed_data;
            return LJFP_ERR_DECOMPRESS_FAILED;
        }
        
        delete[] current_data;
        current_data = uncompressed_data;
        current_size = uncompressed_size;
    }
    
    // 4. CRC32 校验
    if (info->m_CRC32Original > 0) {
        unsigned int computed_crc = crc32_nn(
            0, current_data, info->m_SizeOriginal);
        
        if (computed_crc != info->m_CRC32Original) {
            delete[] current_data;
            return LJFP_ERR_CRC32_MISMATCH;
        }
    }
    
    // 5. 写入输出文件
    std::wstring full_output_path = output_path + L"\\" + 
                                  info->m_PathFileName;
    std::ofstream out_stream(ws2s(full_output_path), 
                            std::ios_base::binary);
    out_stream.write((char*)current_data, info->m_SizeOriginal);
    out_stream.close();
    
    // 6. 释放内存
    delete[] current_data;
    
    return LJFP_OK;
}
```

### 9.4 性能优化建议

| 优化项 | 方法 | 预期提升 |
|---------|------|-----------|
| **内存池** | 预分配内存块，减少频繁分配 | 20-30% |
| **多线程解密** | 并行处理多个文件 | 2-4x（多核） |
| **批量 I/O** | 使用缓冲区批量读写 | 10-20% |
| **SIMD 优化** | 使用 SSE/AVX 指令加速 | 2-3x |
| **缓存优化** | 优化数据访问模式 | 10-15% |

---

**文档版本**: 1.0.0  
**最后更新**: 2026-01-13  
**维护者**: 技术委员会

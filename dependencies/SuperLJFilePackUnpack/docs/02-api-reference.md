# SuperLJFilePackUnpack API 接口参考

> 本文档基于源代码实际实现编写，确保与代码逻辑 100% 精准同步。
> 生成日期：2026-04-26

---

## 目录

- [1. Unpacker 核心类 API](#1-unpacker-核心类-api)
- [2. 数据结构参考](#2-数据结构参考)
- [3. LibsWrapper 函数 API](#3-libswrapper-函数-api)
- [4. FileTypeDetector API](#4-filetypedetector-api)
- [5. AndroidBinaryKey API](#5-androidbinarykey-api)
- [6. UnpackIndexIO 内部 API](#6-unpackindexio-内部-api)
- [7. UnpackSourceIO 内部 API](#7-unpacksourceio-内部-api)
- [8. 错误码参考](#8-错误码参考)

---

## 1. Unpacker 核心类 API

### 1.1 构造与析构

#### `Unpacker::Unpacker`

```cpp
Unpacker(
    CRC32_Func crc32Func,
    Zip_Func zipFunc,
    UnZip_Func unzipFunc,
    SMS4_Func sms4Func,
    DeSMS4_Func desms4Func);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `crc32Func` | `CRC32_Func` | 不得为 nullptr | CRC32 计算函数指针 |
| `zipFunc` | `Zip_Func` | 不得为 nullptr | zlib 压缩函数指针 |
| `unzipFunc` | `UnZip_Func` | 不得为 nullptr | zlib 解压函数指针 |
| `sms4Func` | `SMS4_Func` | 不得为 nullptr | SMS4 加密函数指针 |
| `desms4Func` | `DeSMS4_Func` | 不得为 nullptr | SMS4 解密函数指针 |

**源文件**: `include/SLJFP_Unpack.h`, 行 570-576
**源文件**: `src/SLJFP_Unpack.cpp`, 行 2096-2111

**异常处理**: 构造函数不执行参数空指针校验，调用方需确保传入有效函数指针。

#### `Unpacker::~Unpacker`

```cpp
~Unpacker();
```

**行为**: 调用 `Clear()` 释放所有内部资源。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2113-2116

---

### 1.2 索引加载

#### `Unpacker::LoadIndex`

```cpp
int LoadIndex(const std::string& indexPath);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `indexPath` | `const std::string&` | 不得为空；文件必须存在 | 索引文件路径 (.ljpi 或 .ljzip) |

**返回值**:

| 返回值 | 含义 |
|--------|------|
| `LJFP_SUCCESS` | 加载成功 |
| `LJFP_ERROR_INDEX_NOT_FOUND` | 索引文件不存在 |
| `LJFP_ERROR_INDEX_INVALID_FORMAT` | 索引格式无效 |
| `LJFP_ERROR_INDEX_CORRUPTED` | 索引数据损坏 |
| `LJFP_ERROR_INDEX_DECOMPRESS_FAILED` | .ljzip 索引解压失败 |
| `LJFP_ERROR_CRC32_MISMATCH` | .ljzip 索引 CRC32 校验失败 |

**行为**:
1. 检查文件是否存在
2. 根据扩展名判断类型：`.ljzip` → `LoadLjzipIndex()`，其他 → `LoadLjpiIndex()`
3. 解析索引数据填充 `m_fileList`
4. 设置 `m_inputDir` 为索引文件所在目录
5. 更新路径映射命中率统计

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2118-2135

---

### 1.3 路径映射

#### `Unpacker::LoadPathMapping`

```cpp
int LoadPathMapping(const std::string& mapPath);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `mapPath` | `const std::string&` | 不得为空；文件必须存在 | 映射表文件路径 |

**返回值**:

| 返回值 | 含义 |
|--------|------|
| `LJFP_SUCCESS` | 加载成功 |
| `LJFP_ERROR_FILE_NOT_FOUND` | 文件不存在 |
| `LJFP_ERROR_INVALID_INDEX` | 无有效映射条目 |

**行为**:
1. 检测文件格式：`.ljpm` 扩展名或魔数 `0x4D504A4C`("LJPM") → 二进制格式，否则文本格式
2. 文本格式支持：`CRC32|路径` 或 `0xCRC32<TAB>路径`，支持十进制和十六进制 CRC32
3. 对每条路径执行 `NormalizeOutputRelativePath()` 规范化
4. 记录审计信息到 `m_pathMappingAudit`
5. 更新命中率统计

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2890-2980

#### `Unpacker::LoadPathMappingBinary`

```cpp
int LoadPathMappingBinary(const std::string& ljpmPath);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `ljpmPath` | `const std::string&` | 不得为空；文件必须存在 | 二进制映射文件路径 |

**返回值**: 同 `LoadPathMapping`

**二进制格式**:
```
[4B] 魔数 = 0x4D504A4C ("LJPM")
[4B] 版本 = 1
[4B] 条目数量
[循环 N 次]
  [4B] CRC32
  [2B] 路径长度
  [NB] 路径字符串 (UTF-8)
```

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2982-3060

---

### 1.4 解包操作

#### `Unpacker::UnpackAll`

```cpp
int UnpackAll(const std::string& inputDir, const std::string& outputDir, const UnpackOptions& options);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `inputDir` | `const std::string&` | 不得为空 | 输入目录 |
| `outputDir` | `const std::string&` | 不得为空 | 输出目录 |
| `options` | `const UnpackOptions&` | — | 解包选项配置 |

**返回值**:

| 返回值 | 含义 |
|--------|------|
| `LJFP_SUCCESS` | 全部成功 |
| `LJFP_ERROR_PARTIAL_FAILURE` | 部分文件失败 |
| 其他错误码 | 后处理或清单写入失败 |

**执行流程**:
1. `ConfigureSession()` — 设置运行时配置
2. `CreateDirectoryRecursive()` — 创建输出目录
3. 根据 `threadCount` 选择单线程或多线程解包
4. `PostProcessRestoredOutputs()` — 后处理路径恢复（如果启用）
5. `ValidateRestoreOutcome()` — 校验恢复结果
6. `WriteOutputPathManifest()` — 写出路径清单（如果启用）

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2127-2175

#### `Unpacker::UnpackSelected`

```cpp
int UnpackSelected(const std::vector<size_t>& fileIndices,
                   const std::string& inputDir,
                   const std::string& outputDir,
                   const UnpackOptions& options);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `fileIndices` | `const std::vector<size_t>&` | 不得为空；索引须在有效范围内 | 要解包的文件索引集合 |
| `inputDir` | `const std::string&` | 不得为空 | 输入目录 |
| `outputDir` | `const std::string&` | 不得为空 | 输出目录 |
| `options` | `const UnpackOptions&` | — | 解包选项配置 |

**返回值**: 同 `UnpackAll`

**行为**: 去重并验证索引后，按单线程或多线程模式解包指定文件。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2177-2230

#### `Unpacker::UnpackSingle`

```cpp
int UnpackSingle(size_t index, const std::string& outputPath = "");
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `index` | `size_t` | 必须 < `m_fileList.size()` | 文件索引 |
| `outputPath` | `const std::string&` | 空=使用默认路径 | 自定义输出路径 |

**返回值**:

| 返回值 | 含义 |
|--------|------|
| `LJFP_SUCCESS` | 成功 |
| `LJFP_ERROR_INVALID_INDEX` | 索引越界 |
| `LJFP_ERROR_FILE_NOT_FOUND` | 输入目录未配置 |
| `LJFP_ERROR_FILE_CREATE_FAILED` | 输出目录未配置 |

**前置条件**: `m_inputDir` 和 `m_outputDir` 必须已配置（通过 `ConfigureSession` 或 `UnpackAll`）。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2570-2598

---

### 1.5 运行控制

#### `Unpacker::Stop`

```cpp
void Stop();
```

**行为**: 设置 `m_shouldStop = true`，唤醒暂停等待。协作式取消，不会立即终止线程。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2600-2604

#### `Unpacker::Pause`

```cpp
void Pause();
```

**行为**: 设置 `m_shouldPause = true`，工作线程在 `WaitIfPaused()` 中轮询检测。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2606-2609

#### `Unpacker::Resume`

```cpp
void Resume();
```

**行为**: 设置 `m_shouldPause = false`，唤醒暂停等待。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2611-2614

#### `Unpacker::Clear`

```cpp
void Clear();
```

**行为**: 清空所有内部状态（文件列表、路径映射、统计信息、审计记录）。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 2624-2650

---

### 1.6 查询接口

#### `Unpacker::GetFilePath`

```cpp
std::string GetFilePath(size_t index) const;
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `index` | `size_t` | 必须 < `m_fileList.size()` | 文件索引 |

**返回值**: 优先返回路径映射表中的路径，否则返回 CRC32 数字字符串。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 3140-3152

#### `Unpacker::FindFileByCRC32`

```cpp
int FindFileByCRC32(uint32_t pathCRC32) const;
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `pathCRC32` | `uint32_t` | — | 路径文件名 CRC32 |

**返回值**: 文件索引（找到）或 -1（未找到）。线性搜索，O(n) 复杂度。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 3130-3138

#### `Unpacker::GetPathMappingHitRate`

```cpp
bool GetPathMappingHitRate(uint32_t& hitCount, uint32_t& totalCount, uint32_t& rateBasis) const;
```

| 输出参数 | 类型 | 说明 |
|----------|------|------|
| `hitCount` | `uint32_t&` | 命中映射的文件数 |
| `totalCount` | `uint32_t&` | 总文件数 |
| `rateBasis` | `uint32_t&` | 百分比×100（两位小数精度） |

**返回值**: `true` 如果统计有效（已加载映射且有文件）。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 3220-3235

#### `Unpacker::ReadDecodedFileSample`

```cpp
int ReadDecodedFileSample(size_t index, size_t maxBytes,
                          std::vector<unsigned char>& outData,
                          std::string* outLogicalPath = NULL);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `index` | `size_t` | 必须 < `m_fileList.size()` | 文件索引 |
| `maxBytes` | `size_t` | 0=返回完整内容 | 最大返回字节数 |
| `outData` | `std::vector<unsigned char>&` | — | 输出数据 |
| `outLogicalPath` | `std::string*` | 可为 nullptr | 可选输出逻辑路径 |

**返回值**: `LJFP_SUCCESS` 或读取/解密错误码。

**源文件**: `src/SLJFP_Unpack.cpp`, 行 3154-3198

---

## 2. 数据结构参考

### 2.1 FileInfo

```cpp
struct FileInfo {
    unsigned int m_PackIndex;         // 包索引 (0=散文件, >0=包内文件)
    unsigned int m_Pos;               // 包内位置偏移
    unsigned int m_Size;              // 当前大小 (加密/压缩后)
    unsigned int m_CRC32;             // 当前 CRC32
    unsigned int m_CompressType;      // 压缩类型 (0=未压缩)
    unsigned int m_CodeType;          // 加密类型 (0=未加密)
    unsigned int m_SizeOriginal;      // 原始大小
    unsigned int m_CRC32Original;     // 原始 CRC32
    unsigned int m_PathFileNameCRC32; // 路径文件名 CRC32
};
```

**源文件**: `include/SLJFP_Unpack.h`, 行 100-120

### 2.2 UnpackOptions

```cpp
struct UnpackOptions {
    bool verifyCRC32;                          // 默认: true
    bool overwriteExisting;                    // 默认: false
    bool createDirectories;                    // 默认: true
    int threadCount;                           // 默认: 1
    std::string decryptKey;                    // 默认: ""
    bool useStreamMode;                        // 默认: false
    uint32_t streamChunkSize;                  // 默认: 4*1024*1024 (4MB)
    bool detectFileType;                       // 默认: true
    bool preferPathMapping;                    // 默认: true
    bool organizeByType;                       // 默认: true
    bool forceCrcOutputFirst;                  // 默认: false
    bool restorePathStructureAfterUnpack;      // 默认: false
    bool strictRestoreValidation;              // 默认: false
    bool relocateRootNumericResiduals;         // 默认: false
    bool writeReviewAliases;                   // 默认: false
    bool writePathManifest;                    // 默认: true
    DecryptMode decryptMode;                   // 默认: DecryptMode::Auto
};
```

**源文件**: `include/SLJFP_Unpack.h`, 行 228-267

### 2.3 DecryptProbeRecord

```cpp
struct DecryptProbeRecord {
    std::string candidateId;         // 候选标识
    DecryptMode mode;                // 解密模式
    bool applyDecrypt;               // 是否执行了解密
    bool useFullWindow;              // 是否全文件解密
    bool needDecompress;             // 是否需要解压
    int errorCode;                   // 候选阶段错误码
    int unzipResult;                 // zlib 返回值
    bool crcChecked;                 // 是否做了 CRC 校验
    bool crcMatched;                 // CRC 是否匹配
    bool selected;                   // 是否被选中
    uint32_t inputSize;              // 输入大小
    uint32_t transformedSize;        // 解密后大小
    uint32_t outputSize;             // 产出大小
    uint32_t expectedCRC32;          // 预期 CRC32
    uint32_t actualCRC32;            // 实际 CRC32
    std::string inputSignature;      // 输入特征摘要
    std::string transformedSignature;// 中间数据特征摘要
    std::string outputSignature;     // 产出特征摘要
    std::string inputPrefixHex;      // 输入前缀 hex
    std::string transformedPrefixHex;// 中间数据前缀 hex
    std::string outputPrefixHex;     // 产出前缀 hex
};
```

**源文件**: `include/SLJFP_Unpack.h`, 行 48-96

### 2.4 DecryptMode

```cpp
enum class DecryptMode {
    Auto = 0,               // 自动模式
    LJFilePackSMS4 = 1,     // 原始 LJFilePack SMS4
    ApkClientObf = 2        // APK 客户端混淆变体
};
```

**源文件**: `include/SLJFP_Unpack.h`, 行 40-44

---

## 3. LibsWrapper 函数 API

### 3.1 SLJFP_DeSMS4BlocksLegacy

```cpp
void SLJFP_DeSMS4BlocksLegacy(
    unsigned char* inBuff,
    unsigned char* ouBuff,
    unsigned int uiSize,
    const std::string& strPassword);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `inBuff` | `unsigned char*` | 不得为 nullptr | 输入加密数据 |
| `ouBuff` | `unsigned char*` | 不得为 nullptr | 输出解密数据 |
| `uiSize` | `unsigned int` | 必须为 16 的倍数 | 数据大小（字节） |
| `strPassword` | `const std::string&` | 不得为空 | 解密密钥 |

**行为**: 使用原始 LJFilePack SMS4 算法解密数据块。每 16 字节为一个 SMS4 分组。

**源文件**: `src/SLJFP_LibsWrapper.cpp`

### 3.2 SLJFP_DeSMS4BlocksClientObf

```cpp
void SLJFP_DeSMS4BlocksClientObf(
    unsigned char* inBuff,
    unsigned char* ouBuff,
    unsigned int uiSize,
    const std::string& strPassword);
```

**行为**: 使用 APK 客户端混淆变体 SMS4 算法解密数据块。

**源文件**: `src/SLJFP_LibsWrapper.cpp`

### 3.3 SLJFP_DeSMS4BlocksClientKeyed

```cpp
void SLJFP_DeSMS4BlocksClientKeyed(
    unsigned char* inBuff,
    unsigned char* ouBuff,
    unsigned int uiSize,
    const std::string& strPassword);
```

**行为**: 使用从 APK 客户端提取的密钥进行 SMS4 解密。

**源文件**: `src/SLJFP_LibsWrapper.cpp`

---

## 4. FileTypeDetector API

### 4.1 DetectExtension

```cpp
static std::string DetectExtension(const unsigned char* data, uint32_t size);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `data` | `const unsigned char*` | 可为 nullptr | 文件数据 |
| `size` | `uint32_t` | — | 数据大小 |

**返回值**: 检测到的文件扩展名（如 `.png`、`.xml`），空字符串表示未知类型。

**检测策略**: 基于 Magic Number 签名匹配，支持 PNG、JPEG、GIF、BMP、TIFF、WebP、DDS、TGA、OGG、MP3、WAV、FLAC、ZIP、XML (UTF-8/UTF-16)、JSON、Lua 字节码、TrueType/OpenType 字体等格式。

**源文件**: `src/SLJFP_FileTypeDetector.cpp`

---

## 5. AndroidBinaryKey API

### 5.1 ExtractKeyFromApk

```cpp
static std::string ExtractKeyFromApk(const std::string& apkPath);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `apkPath` | `const std::string&` | 文件必须存在 | APK 文件路径 |

**返回值**: 提取到的解密密钥，空字符串表示提取失败。

**行为**: 从 APK 的 `lib/armeabi-v7a/libgame.so` 中提取 SMS4 解密密钥。

**源文件**: `src/SLJFP_AndroidBinaryKey.cpp`

---

## 6. UnpackIndexIO 内部 API

> 以下 API 位于 `SLJFP::detail` 命名空间，仅供 `Unpacker` 内部调用。

### 6.1 ParseLjpiBuffer

```cpp
int ParseLjpiBuffer(const unsigned char* data, uint32_t size, IndexLoadResult& outResult);
```

| 参数 | 类型 | 校验规则 | 说明 |
|------|------|----------|------|
| `data` | `const unsigned char*` | 不得为 nullptr | 索引数据 |
| `size` | `uint32_t` | 必须 >= 4 | 数据大小 |
| `outResult` | `IndexLoadResult&` | — | 输出解析结果 |

**返回值**: `LJFP_SUCCESS` 或 `LJFP_ERROR_INDEX_INVALID_FORMAT` / `LJFP_ERROR_INDEX_CORRUPTED`

**.ljpi 二进制格式**:
```
[4B] fileCount: uint32_t
[循环 fileCount 次]
  [4B] m_PackIndex: uint32_t
  (如果 m_PackIndex > 0) [4B] m_Pos: uint32_t
  [4B] m_Size: uint32_t
  [4B] m_CRC32: uint32_t
  [4B] m_CompressType: uint32_t
  [4B] m_CodeType: uint32_t
  (如果 m_CompressType > 0 或 m_CodeType > 0)
    [4B] m_SizeOriginal: uint32_t
    [4B] m_CRC32Original: uint32_t
  [4B] m_PathFileNameCRC32: uint32_t
```

**源文件**: `src/SLJFP_UnpackIndexIO.cpp`, 行 16-55

### 6.2 LoadLjzipIndexData

```cpp
int LoadLjzipIndexData(const std::string& ljzipPath,
                       const IndexLoadDependencies& deps,
                       IndexLoadResult& outResult);
```

**.ljzip 二进制格式**:
```
[4B] magicKey: uint32_t (= 9999)
[4B] encryptedSize: uint32_t
[encryptedSize B] 加密的索引数据
[4B] compressedSize: uint32_t
[4B] originalSize: uint32_t
[4B] originalCRC32: uint32_t
```

**处理流程**: 读取→SMS4 解密→zlib 解压→CRC32 校验→ParseLjpiBuffer

**源文件**: `src/SLJFP_UnpackIndexIO.cpp`, 行 76-170

---

## 7. UnpackSourceIO 内部 API

### 7.1 BuildSourceFilePath

```cpp
std::string BuildSourceFilePath(const std::string& inputDir, const FileInfo& fileInfo);
```

**行为**:
- `m_PackIndex == 0` → `{inputDir}/{m_PathFileNameCRC32}` (散文件)
- `m_PackIndex > 0` → `{inputDir}/{m_PackIndex}.ljfp` (包文件)

**源文件**: `src/SLJFP_UnpackSourceIO.cpp`, 行 14-21

### 7.2 OpenSourceFileStream

```cpp
int OpenSourceFileStream(const std::string& inputDir,
                         const FileInfo& fileInfo,
                         std::ifstream& stream,
                         std::string& sourcePath);
```

**返回值**: `LJFP_SUCCESS` 或 `LJFP_ERROR_FILE_NOT_FOUND` / `LJFP_ERROR_PACK_NOT_FOUND` / `LJFP_ERROR_FILE_READ_FAILED`

**行为**: 打开源文件流，如果是包内文件则 seek 到 `m_Pos` 偏移。

**源文件**: `src/SLJFP_UnpackSourceIO.cpp`, 行 23-42

### 7.3 ReadSourceFileData

```cpp
int ReadSourceFileData(const std::string& inputDir,
                       const FileInfo& fileInfo,
                       std::vector<unsigned char>& outputData);
```

**返回值**: `LJFP_SUCCESS` 或读取错误码

**行为**: 读取文件全部数据到 `outputData`。散文件读取完整文件大小，包内文件读取 `m_Size` 字节。

**源文件**: `src/SLJFP_UnpackSourceIO.cpp`, 行 44-89

---

## 8. 错误码参考

| 错误码 | 值 | 含义 |
|--------|-----|------|
| `LJFP_SUCCESS` | 0 | 成功 |
| `LJFP_ERROR_FILE_OPEN_FAILED` | — | 文件打开失败 |
| `LJFP_ERROR_FILE_READ_FAILED` | — | 文件读取失败 |
| `LJFP_ERROR_FILE_WRITE_FAILED` | — | 文件写入失败 |
| `LJFP_ERROR_FILE_CREATE_FAILED` | — | 文件创建失败 |
| `LJFP_ERROR_FILE_NOT_FOUND` | — | 文件未找到 |
| `LJFP_ERROR_PACK_NOT_FOUND` | — | 包文件未找到 |
| `LJFP_ERROR_INDEX_NOT_FOUND` | — | 索引文件未找到 |
| `LJFP_ERROR_INDEX_INVALID_FORMAT` | — | 索引格式无效 |
| `LJFP_ERROR_INDEX_CORRUPTED` | — | 索引数据损坏 |
| `LJFP_ERROR_INDEX_DECOMPRESS_FAILED` | — | 索引解压失败 |
| `LJFP_ERROR_DECRYPT_FAILED` | — | 解密失败 |
| `LJFP_ERROR_DECOMPRESS_FAILED` | — | 解压失败 |
| `LJFP_ERROR_DECOMPRESS_TOO_LARGE` | — | 解压后数据超过 100MB 限制 |
| `LJFP_ERROR_CRC32_MISMATCH` | — | CRC32 校验不匹配 |
| `LJFP_ERROR_INVALID_INDEX` | — | 无效索引 |
| `LJFP_ERROR_USER_CANCELLED` | — | 用户取消 |
| `LJFP_ERROR_PARTIAL_FAILURE` | — | 部分文件失败 |

**源文件**: `include/SLJFP_ErrorCodes.h`

---

## 文档与代码映射关系

| 文档章节 | 对应源文件 |
|----------|-----------|
| 1.1 构造与析构 | `include/SLJFP_Unpack.h` 行 570-576; `src/SLJFP_Unpack.cpp` 行 2096-2116 |
| 1.2 索引加载 | `src/SLJFP_Unpack.cpp` 行 2118-2135; `src/SLJFP_UnpackIndexIO.cpp` |
| 1.3 路径映射 | `src/SLJFP_Unpack.cpp` 行 2890-3060 |
| 1.4 解包操作 | `src/SLJFP_Unpack.cpp` 行 2127-2598 |
| 1.5 运行控制 | `src/SLJFP_Unpack.cpp` 行 2600-2650 |
| 2.1 FileInfo | `include/SLJFP_Unpack.h` 行 100-120 |
| 2.2 UnpackOptions | `include/SLJFP_Unpack.h` 行 228-267 |
| 6.1 ParseLjpiBuffer | `src/SLJFP_UnpackIndexIO.cpp` 行 16-55 |
| 6.2 LoadLjzipIndexData | `src/SLJFP_UnpackIndexIO.cpp` 行 76-170 |
| 7.1-7.3 SourceIO | `src/SLJFP_UnpackSourceIO.cpp` |
| 8. 错误码 | `include/SLJFP_ErrorCodes.h` |

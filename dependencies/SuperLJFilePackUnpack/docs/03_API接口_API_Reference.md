# 03 API 接口参考

> 基准日期: 2026-04-21
> 事实源: `include/*.h`

## 1. 常量与基础类型

```cpp
const unsigned int LJZIP_MAGIC_KEY = 9999;
const char* const DEFAULT_DECRYPT_KEY = "locojoy123456789";
const unsigned int MAX_DECOMPRESS_SIZE = 100 * 1024 * 1024;
```

底层依赖函数类型：

```cpp
typedef unsigned int(*CRC32_Func)(unsigned int crc, const unsigned char* ptr, unsigned int buf_len);
typedef unsigned int(*Zip_Func)(unsigned char *pDest, unsigned int *pDest_len, const unsigned char *pSource, unsigned int source_len, int level);
typedef unsigned int(*UnZip_Func)(unsigned char *pDest, unsigned int *pDest_len, const unsigned char *pSource, unsigned int source_len);
typedef void(*SMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword);
typedef void(*DeSMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword);
```

项目自带实现位于 `SLJFP_LibsWrapper.*`：

- `SLJFP_crc32`
- `SLJFP_mz_compress2`
- `SLJFP_mz_uncompress`
- `SLJFP_SMS4Ex`
- `SLJFP_DeSMS4Ex`

## 2. `DecryptMode`

```cpp
enum class DecryptMode {
    Auto = 0,
    LJFilePackSMS4 = 1,
    ApkClientObf = 2
};
```

语义：

- `Auto`
  - 扩展候选链路并保存探针记录
- `LJFilePackSMS4`
  - 只尝试原始 LJFilePack SMS4 链路
- `ApkClientObf`
  - 只尝试 APK 客户端混淆变体

## 3. 关键数据结构

### 3.1 `FileInfo`

```cpp
struct FileInfo {
    unsigned int m_PackIndex;
    unsigned int m_Pos;
    unsigned int m_Size;
    unsigned int m_CRC32;
    unsigned int m_CompressType;
    unsigned int m_CodeType;
    unsigned int m_SizeOriginal;
    unsigned int m_CRC32Original;
    unsigned int m_PathFileNameCRC32;
};
```

### 3.2 `DecryptProbeRecord`

用于记录某一次候选链路的探针结果，包括：

- 候选 ID
- 模式
- 是否解密 / 是否全窗口
- unzip 状态
- 是否做 CRC 检查
- 是否被选中
- 输入/中间/输出签名摘要

### 3.3 `DecryptFailureDiagnostic`

用于记录首个失败样本，包括：

- `fileIndex`
- `failureCode`
- `FileInfo`
- 候选探针列表

### 3.4 `FailedFileRecord`

最近一次解包失败文件清单，包含：

- 文件索引
- 路径 CRC32
- 包索引
- 错误码
- 当前是否命中映射

### 3.5 `OutputPathManifestRecord`

输出路径 sidecar 记录，包含：

- 路径来源
- 原始映射路径
- 规范化路径
- 实际写盘路径
- 最终路径
- 是否冲突消解
- 是否被 review 归档

## 4. `UnpackOptions`

```cpp
struct UnpackOptions {
    bool verifyCRC32;
    bool overwriteExisting;
    bool createDirectories;
    int threadCount;
    std::string decryptKey;
    bool useStreamMode;
    uint32_t streamChunkSize;
    bool detectFileType;
    bool preferPathMapping;
    bool organizeByType;
    bool forceCrcOutputFirst;
    bool restorePathStructureAfterUnpack;
    bool strictRestoreValidation;
    bool relocateRootNumericResiduals;
    bool writeReviewAliases;
    bool writePathManifest;
    DecryptMode decryptMode;
};
```

默认值要点：

- `verifyCRC32 = true`
- `overwriteExisting = false`
- `createDirectories = true`
- `threadCount = 1`
- `useStreamMode = false`
- `streamChunkSize = 4MB`
- `detectFileType = true`
- `preferPathMapping = true`
- `organizeByType = true`
- `forceCrcOutputFirst = false`
- `restorePathStructureAfterUnpack = false`
- `strictRestoreValidation = false`
- `relocateRootNumericResiduals = false`
- `writeReviewAliases = false`
- `writePathManifest = true`
- `decryptMode = Auto`

## 5. `SLJFP::Unpacker`

### 5.1 构造

```cpp
Unpacker(
    CRC32_Func crc32Func,
    Zip_Func zipFunc,
    UnZip_Func unzipFunc,
    SMS4_Func sms4Func,
    DeSMS4_Func desms4Func
);
```

### 5.2 主流程接口

```cpp
int LoadIndex(const std::string& indexPath);
int UnpackAll(const std::string& inputDir, const std::string& outputDir, const UnpackOptions& options);
int UnpackSelected(const std::vector<size_t>& fileIndices,
                   const std::string& inputDir,
                   const std::string& outputDir,
                   const UnpackOptions& options);
void ConfigureSession(const std::string& inputDir,
                      const std::string& outputDir,
                      const UnpackOptions& options);
int UnpackSingle(size_t index, const std::string& outputPath = "");
```

### 5.3 控制接口

```cpp
void Stop();
void Pause();
void Resume();
void SetPaused(bool paused);
void Clear();
void SetProgressCallback(ProgressCallback callback);
```

### 5.4 映射与查询接口

```cpp
int LoadPathMapping(const std::string& mapPath);
int LoadPathMappingBinary(const std::string& ljpmPath);
size_t GetPathMappingCount() const;
bool GetPathMappingHitRate(uint32_t& hitCount, uint32_t& totalCount, uint32_t& rateBasis) const;
std::vector<uint32_t> GetPathMappingMissingSamples() const;
bool HasPathMappingForFile(size_t index) const;
int FindFileByCRC32(uint32_t pathCRC32) const;
std::string GetFilePath(size_t index) const;
```

### 5.5 失败与审计接口

```cpp
const std::map<int, uint32_t>& GetLastErrorCodeCounts() const;
int GetFirstErrorCode() const;
uint32_t GetFirstErrorFileIndex() const;
std::vector<DecryptProbeRecord> GetLastDecryptProbeRecords() const;
bool GetFirstFailedDecryptDiagnostic(DecryptFailureDiagnostic& outDiagnostic) const;
std::vector<FailedFileRecord> GetLastFailedFiles() const;
std::vector<OutputPathManifestRecord> GetLastOutputPathManifestRecords() const;
```

### 5.6 数据样本接口

```cpp
int ReadDecodedFileSample(size_t index,
                          size_t maxBytes,
                          std::vector<unsigned char>& outData,
                          std::string* outLogicalPath = NULL);
```

用途：

- 映射分析
- 失败定位
- GUI 预览辅助

## 6. `SLJFP::PathMappingGenerator`

### 6.1 关键枚举与结构

```cpp
enum class PathHashMode {
    NormalizedPath = 0,
    LjFilePackLegacyAcpExact = 1
};
```

```cpp
struct ScanOptions {
    bool recursiveScan;
    bool sljfpScanIncludeHiddenFlag;
    bool lowercasePaths;
    bool normalizeSlashes;
    std::string sljfpScanPathPrefixValue;
    PathHashMode pathHashMode;
};
```

### 6.2 主接口

```cpp
void SetCRC32Function(CRC32_PathFunc func);
uint32_t ScanDirectory(const std::string& rootDir, const ScanOptions& options = ScanOptions());
uint32_t AddPath(const std::string& relativePath, uint64_t fileSize = 0);
uint32_t AddPathWithCRC(const std::string& relativePath, uint32_t crc32, uint64_t fileSize = 0);
uint32_t LoadPathList(const std::string& pathListFile);
int SaveMapping(const std::string& outputPath, bool useHex = false);
int SaveMappingBinary(const std::string& outputPath);
void Clear();
```

### 6.3 静态辅助

```cpp
static std::string CanonicalizeStoragePath(const std::string& relativePath);
static bool IsLowConfidenceCrcRepositoryPath(const std::string& relativePath);
```

## 7. `SLJFP::FileTypeDetector`

当前是纯静态工具类，主要接口：

```cpp
static std::string DetectExtension(const uint8_t* data, size_t size);
static std::string DetectMimeType(const uint8_t* data, size_t size);
static std::string DetectDescription(const uint8_t* data, size_t size);
static bool IsTextFile(const std::string& extension);
static size_t GetSupportedTypeCount();
static std::string GetSupportedExtensions();
```

## 8. `SLJFP::AndroidBinaryKey`

```cpp
bool TryExtractAndroidLibgameDecryptKey(const std::string& libgamePath,
                                        std::string& outKey,
                                        std::string* outMessage = NULL);

bool TryResolveAndroidLibgameDecryptKey(const std::string& resourcePathOrDir,
                                        const std::string& explicitLibgamePathOrDir,
                                        AndroidBinaryKeyProbeResult& outResult);
```

## 9. GUI 工作流辅助接口

当前 GUI 还额外依赖以下公开头文件：

- `SLJFP_WorkflowPresenter.h`
- `SLJFP_WorkflowReviewController.h`
- `SLJFP_WorkflowReviewExportService.h`
- `gui/SLJFP_WorkflowSession.h`

它们不承担解包底层功能，但决定：

- 结果审阅列表怎么分组
- 过滤/定位逻辑怎么工作
- 失败项如何导出

## 10. 当前接口设计边界

需要特别注意的现状：

- GUI 没有暴露全部 `UnpackOptions`
- `BUILD_CLI` 不是当前 CLI 入口
- 路径映射生成现在统一走 API、GUI 和 `ljfp-unpack --scan`

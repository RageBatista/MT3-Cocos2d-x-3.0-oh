#ifndef SLJFP_UNPACK_H
#define SLJFP_UNPACK_H

/**
 * @file SLJFP_Unpack.h
 * @brief SuperLJFilePackUnpack 核心解包类
 * @version 1.0
 * @date 2025-01-03
 *
 * 基于 LJFilePack 逆向功能实施方案文档第7章设计
 * 实现完整的资源包逆向解包功能
 */

#include <string>
#include <vector>
#include <functional>
#include <cstdint>
#include <map>
#include <set>
#include <atomic>
#include <mutex>

// 前向声明依赖库函数类型
typedef unsigned int(*CRC32_Func)(unsigned int crc, const unsigned char* ptr, unsigned int buf_len);
typedef unsigned int(*Zip_Func)(unsigned char *pDest, unsigned int *pDest_len, const unsigned char *pSource, unsigned int source_len, int level);
typedef unsigned int(*UnZip_Func)(unsigned char *pDest, unsigned int *pDest_len, const unsigned char *pSource, unsigned int source_len);
typedef void(*SMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword);
typedef void(*DeSMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword);

namespace SLJFP {

// 常量定义
const unsigned int LJZIP_MAGIC_KEY = 9999;           ///< .ljzip 文件魔数
const char* const DEFAULT_DECRYPT_KEY = "locojoy123456789";  ///< 默认解密密钥
const unsigned int MAX_DECOMPRESS_SIZE = 100 * 1024 * 1024;  ///< 最大解压大小 (100MB)

/**
 * @brief 解密模式
 */
enum class DecryptMode {
    Auto = 0,               ///< 自动模式，按实现可支持的候选链路尝试
    LJFilePackSMS4 = 1,     ///< 原始 LJFilePack SMS4
    ApkClientObf = 2        ///< APK 客户端混淆变体
};

/**
 * @brief 单个解密候选的探针记录
 */
struct DecryptProbeRecord {
    std::string candidateId;         ///< 候选标识（如 legacy-window1024 / passthrough）
    DecryptMode mode;                ///< 候选所属解密模式
    bool applyDecrypt;               ///< 是否实际执行了解密
    bool useFullWindow;              ///< 是否对全文件解密窗口做探测
    bool needDecompress;             ///< 后续是否尝试了解压
    int errorCode;                   ///< 候选阶段错误码（LJFP_SUCCESS 表示候选本身可产出结果）
    int unzipResult;                 ///< zlib 返回值（未解压时为 0）
    bool crcChecked;                 ///< 是否做了 CRC 对照
    bool crcMatched;                 ///< CRC 是否命中预期
    bool selected;                   ///< 是否被当前策略选中
    uint32_t inputSize;              ///< 原始输入大小
    uint32_t transformedSize;        ///< 解密后的中间数据大小
    uint32_t outputSize;             ///< 最终产出大小（解压后或直通）
    uint32_t expectedCRC32;          ///< 预期原始 CRC32
    uint32_t actualCRC32;            ///< 实际产出 CRC32
    std::string inputSignature;      ///< 原始输入特征摘要
    std::string transformedSignature;///< 中间数据特征摘要
    std::string outputSignature;     ///< 最终产出特征摘要
    std::string inputPrefixHex;      ///< 原始输入前缀 hex
    std::string transformedPrefixHex;///< 中间数据前缀 hex
    std::string outputPrefixHex;     ///< 最终产出前缀 hex

    DecryptProbeRecord()
        : mode(DecryptMode::Auto)
        , applyDecrypt(false)
        , useFullWindow(false)
        , needDecompress(false)
        , errorCode(0)
        , unzipResult(0)
        , crcChecked(false)
        , crcMatched(false)
        , selected(false)
        , inputSize(0)
        , transformedSize(0)
        , outputSize(0)
        , expectedCRC32(0)
        , actualCRC32(0) {}
};

/**
 * @brief 文件信息结构
 */
struct FileInfo {
    unsigned int m_PackIndex;        ///< 包索引 (0=散文件, >0=包内文件)
    unsigned int m_Pos;              ///< 包内位置偏移

    unsigned int m_Size;             ///< 当前大小 (加密/压缩后)
    unsigned int m_CRC32;            ///< 当前 CRC32
    unsigned int m_CompressType;     ///< 压缩类型 (0=未压缩)
    unsigned int m_CodeType;         ///< 加密类型 (0=未加密)

    unsigned int m_SizeOriginal;     ///< 原始大小
    unsigned int m_CRC32Original;    ///< 原始 CRC32

    unsigned int m_PathFileNameCRC32;///< 路径文件名 CRC32

    FileInfo() : m_PackIndex(0), m_Pos(0),
                 m_Size(0), m_CRC32(0), m_CompressType(0), m_CodeType(0),
                 m_SizeOriginal(0), m_CRC32Original(0), m_PathFileNameCRC32(0) {}
};

/**
 * @brief 首个失败样本的解密诊断记录
 */
struct DecryptFailureDiagnostic {
    bool valid;                        ///< 是否有效
    uint32_t fileIndex;                ///< 失败文件索引
    uint32_t inputSize;                ///< 原始读取到的输入大小
    int failureCode;                   ///< 最终失败错误码
    FileInfo fileInfo;                 ///< 对应文件索引元信息
    std::vector<DecryptProbeRecord> candidates; ///< 该文件经历的候选探针

    DecryptFailureDiagnostic()
        : valid(false)
        , fileIndex(0)
        , inputSize(0)
        , failureCode(0) {}
};

/**
 * @brief 最近一次解包失败文件记录
 */
struct FailedFileRecord {
    uint32_t fileIndex;                 ///< 文件索引
    uint32_t pathCRC32;                 ///< 路径 CRC32
    uint32_t packIndex;                 ///< 包索引
    int errorCode;                      ///< 错误码
    bool mappingHit;                    ///< 当前是否命中路径映射

    FailedFileRecord()
        : fileIndex(0)
        , pathCRC32(0)
        , packIndex(0)
        , errorCode(0)
        , mappingHit(false) {}
};

/**
 * @brief 路径清单记录（供结果审阅页使用）
 */
struct OutputPathManifestRecord {
    uint32_t pathCRC32;                 ///< 路径 CRC32
    std::string sourceKind;             ///< 路径来源
    std::string rawMappingPath;         ///< 原始映射路径
    std::string normalizedRelativePath; ///< 规范化后的相对路径
    std::string writtenRelativePath;    ///< 实际写盘路径
    std::string finalRelativePath;      ///< 后处理后的最终路径
    std::string actualRelativePath;     ///< 当前物理文件的实际相对路径
    std::string physicalPathStatus;     ///< 物理文件状态（manifest_path / review_unresolved_relocated / missing_physical 等）
    std::string detectedExtension;      ///< 按内容检测出的扩展名
    bool mappingSanitized;              ///< 是否做过路径清洗
    bool conflictResolved;              ///< 是否做过冲突消解
    bool existingTargetPreserved;       ///< 是否保留了既有目标
    bool postProcessMoved;              ///< 是否被后处理迁移
    bool reviewBucketed;                ///< 是否被归档到 review/unresolved
    bool physicalExists;                ///< 物理文件当前是否存在
    bool extensionConsistent;           ///< 文件扩展名是否与内容检测一致
    uint64_t physicalSize;              ///< 物理文件大小

    OutputPathManifestRecord()
        : pathCRC32(0)
        , mappingSanitized(false)
        , conflictResolved(false)
        , existingTargetPreserved(false)
        , postProcessMoved(false)
        , reviewBucketed(false)
        , physicalExists(false)
        , extensionConsistent(true)
        , physicalSize(0) {}
};

/**
 * @brief 解包选项配置
 */
struct UnpackOptions {
    bool verifyCRC32;                ///< 是否验证 CRC32
    bool overwriteExisting;          ///< 是否覆盖已存在文件
    bool createDirectories;          ///< 是否创建目录结构
    int threadCount;                 ///< 线程数 (0或1=单线程, >1=多线程)
    std::string decryptKey;          ///< 自定义解密密钥 (空字符串=使用默认密钥)
    bool useStreamMode;              ///< 是否使用流式解包 (大文件优化)
    uint32_t streamChunkSize;        ///< 流式解包块大小 (字节, 默认 4MB)
    bool detectFileType;             ///< 是否自动检测文件类型并添加扩展名
    bool preferPathMapping;          ///< 优先使用路径映射表 (如果已加载)
    bool organizeByType;             ///< 是否按文件类型分类存放到子目录
    bool forceCrcOutputFirst;        ///< 是否先按 CRC32 落地，再做后续路径恢复
    bool restorePathStructureAfterUnpack; ///< 解包完成后是否尝试恢复路径结构
    bool strictRestoreValidation;    ///< 严格校验路径恢复结果（要求映射全覆盖且无根目录数字残留）
    bool relocateRootNumericResiduals; ///< 是否将仍未恢复的根目录数字文件归档到 review/unresolved
    bool writeReviewAliases;         ///< 是否写出人工核对用别名副本
    bool writePathManifest;          ///< 是否写出路径恢复 sidecar 清单
    DecryptMode decryptMode;         ///< 解密模式

    UnpackOptions()
        : verifyCRC32(true)
        , overwriteExisting(false)
        , createDirectories(true)
        , threadCount(1)
        , decryptKey("")
        , useStreamMode(false)
        , streamChunkSize(4 * 1024 * 1024)
        , detectFileType(true)
        , preferPathMapping(true)
        , organizeByType(true)
        , forceCrcOutputFirst(false)
        , restorePathStructureAfterUnpack(false)
        , strictRestoreValidation(false)
        , relocateRootNumericResiduals(false)
        , writeReviewAliases(false)
        , writePathManifest(true)
        , decryptMode(DecryptMode::Auto) {}
};

/**
 * @brief 进度回调函数类型
 * @param progress 进度 (0.0-1.0)
 * @param current 当前文件索引
 * @param total 总文件数
 */
typedef std::function<void(float progress, uint32_t current, uint32_t total)> ProgressCallback;

/**
 * @brief 核心解包类
 */
class Unpacker {
private:
    struct PathMappingAuditInfo {
        std::string rawPath;
        std::string normalizedPath;
        bool sanitized;

        PathMappingAuditInfo()
            : sanitized(false) {}
    };

    struct OutputPathAuditRecord {
        uint32_t pathCRC32;
        std::string sourceKind;
        std::string rawMappingPath;
        std::string normalizedRelativePath;
        std::string writtenRelativePath;
        std::string finalRelativePath;
        std::string actualRelativePath;
        std::string physicalPathStatus;
        std::string contentAliasRelativePath;
        std::string detectedExtension;
        bool mappingSanitized;
        bool conflictResolved;
        bool existingTargetPreserved;
        bool postProcessMoved;
        bool reviewBucketed;
        bool contentAliasAmbiguous;
        bool physicalExists;
        bool extensionConsistent;
        uint64_t physicalSize;

        OutputPathAuditRecord()
            : pathCRC32(0)
            , mappingSanitized(false)
            , conflictResolved(false)
            , existingTargetPreserved(false)
            , postProcessMoved(false)
            , reviewBucketed(false)
            , contentAliasAmbiguous(false)
            , physicalExists(false)
            , extensionConsistent(true)
            , physicalSize(0) {}
    };

    // 函数指针
    CRC32_Func m_crc32Func;
    Zip_Func m_zipFunc;
    UnZip_Func m_unzipFunc;
    SMS4_Func m_sms4Func;
    DeSMS4_Func m_desms4Func;

    // 文件列表
    std::vector<FileInfo> m_fileList;

    // 统计信息
    uint32_t m_totalFiles;
    uint32_t m_processedFiles;
    uint32_t m_failedFiles;
    uint64_t m_totalBytes;
    uint64_t m_processedBytes;

    // 运行时状态
    std::atomic<bool> m_isRunning;
    std::atomic<bool> m_shouldStop;
    std::atomic<bool> m_shouldPause;

    // 运行时配置
    std::string m_inputDir;
    std::string m_outputDir;
    UnpackOptions m_options;

    // 回调
    ProgressCallback m_progressCallback;

    // 路径映射命中率缓存
    bool m_pathMappingStatsValid;
    uint32_t m_pathMappingHitCount;
    uint32_t m_pathMappingMissCount;
    uint32_t m_pathMappingRateBasis;
    std::vector<uint32_t> m_pathMappingMissingSamples;

    // 流式解包统计
    std::atomic<uint32_t> m_streamConsidered;
    std::atomic<uint32_t> m_streamUsed;
    std::atomic<uint32_t> m_streamFallback;
    std::atomic<uint32_t> m_streamSkipCompressed;
    std::atomic<uint32_t> m_streamSkipEncryptedUnaligned;

    // 最近一次解包错误统计
    std::map<int, uint32_t> m_lastErrorCodeCounts;
    int m_firstErrorCode;
    uint32_t m_firstErrorFileIndex;
    mutable std::mutex m_failedFilesMutex;
    std::vector<FailedFileRecord> m_lastFailedFiles;

    // 最近一次候选探针与首个失败样本诊断
    mutable std::mutex m_decryptProbeMutex;
    std::vector<DecryptProbeRecord> m_lastDecryptProbeRecords;
    DecryptFailureDiagnostic m_firstFailedDecryptDiagnostic;

    // 输出路径预留表（避免并行解包时写到同一路径）
    mutable std::mutex m_outputPathMutex;
    std::map<std::string, uint32_t> m_reservedOutputPaths;
    std::map<uint32_t, PathMappingAuditInfo> m_pathMappingAudit;
    std::map<uint32_t, OutputPathAuditRecord> m_outputPathAuditRecords;

    void ResetPathMappingStats();
    void UpdatePathMappingStats();
    void ResetStreamStats();
    void ReportStreamStats(const std::wstring& context) const;
    void ResetOutputPathAudit();

public:
    /**
     * @brief 构造函数 - 注入依赖库函数
     * @param crc32Func CRC32 计算函数
     * @param zipFunc 压缩函数
     * @param unzipFunc 解压函数
     * @param sms4Func SMS4 加密函数
     * @param desms4Func SMS4 解密函数
     */
    Unpacker(
        CRC32_Func crc32Func,
        Zip_Func zipFunc,
        UnZip_Func unzipFunc,
        SMS4_Func sms4Func,
        DeSMS4_Func desms4Func);

    /**
     * @brief 析构函数
     */
    ~Unpacker();

    /**
     * @brief 加载索引文件
     * @param indexPath 索引文件路径 (.ljpi 或 .ljzip)
     * @return 错误码 (LJFP_SUCCESS=成功)
     */
    int LoadIndex(const std::string& indexPath);

    /**
     * @brief 解包所有文件
     * @param inputDir 输入目录 (包含 .ljfp 文件和散文件)
     * @param outputDir 输出目录
     * @param options 解包选项
     * @return 错误码 (LJFP_SUCCESS=成功)
     */
    int UnpackAll(const std::string& inputDir, const std::string& outputDir, const UnpackOptions& options);

    /**
     * @brief 仅解包指定文件集合
     * @param fileIndices 要处理的文件索引集合
     * @param inputDir 输入目录
     * @param outputDir 输出目录
     * @param options 解包选项
     * @return 错误码 (LJFP_SUCCESS=成功)
     */
    int UnpackSelected(const std::vector<size_t>& fileIndices,
                       const std::string& inputDir,
                       const std::string& outputDir,
                       const UnpackOptions& options);

    /**
     * @brief 配置当前解包会话上下文
     * @param inputDir 输入目录（空字符串=保持当前值）
     * @param outputDir 输出目录（空字符串=保持当前值）
     * @param options 解包选项
     */
    void ConfigureSession(const std::string& inputDir,
                          const std::string& outputDir,
                          const UnpackOptions& options);

    /**
     * @brief 解包单个文件
     * @param index 文件索引
     * @param outputPath 输出路径 (空字符串=使用默认路径)
     * @return 错误码 (LJFP_SUCCESS=成功)
     */
    int UnpackSingle(size_t index, const std::string& outputPath = "");

    /**
     * @brief 停止解包
     */
    void Stop();

    /**
     * @brief 暂停解包（协作式）
     */
    void Pause();

    /**
     * @brief 恢复解包
     */
    void Resume();

    /**
     * @brief 设置暂停状态
     */
    void SetPaused(bool paused);

    /**
     * @brief 清空文件列表
     */
    void Clear();

    /**
     * @brief 设置进度回调
     * @param callback 回调函数
     */
    void SetProgressCallback(ProgressCallback callback) {
        m_progressCallback = callback;
    }

    /**
     * @brief 获取总文件数
     */
    uint32_t GetTotalFiles() const { return m_totalFiles; }

    /**
     * @brief 获取已处理文件数
     */
    uint32_t GetProcessedFiles() const { return m_processedFiles; }

    /**
     * @brief 获取失败文件数
     */
    uint32_t GetFailedFiles() const { return m_failedFiles; }

    /**
     * @brief 获取总字节数
     */
    uint64_t GetTotalBytes() const { return m_totalBytes; }

    /**
     * @brief 获取已处理字节数
     */
    uint64_t GetProcessedBytes() const { return m_processedBytes; }

    /**
     * @brief 获取最近一次解包的错误码分布
     */
    const std::map<int, uint32_t>& GetLastErrorCodeCounts() const { return m_lastErrorCodeCounts; }

    /**
     * @brief 获取最近一次解包的首个错误码 (0 表示无错误)
     */
    int GetFirstErrorCode() const { return m_firstErrorCode; }

    /**
     * @brief 获取最近一次解包的首个错误文件索引
     */
    uint32_t GetFirstErrorFileIndex() const { return m_firstErrorFileIndex; }

    /**
     * @brief 获取最近一次文件解密/解压候选探针记录
     */
    std::vector<DecryptProbeRecord> GetLastDecryptProbeRecords() const;

    /**
     * @brief 获取最近一次解包中首个失败样本的候选探针记录
     * @param outDiagnostic 输出诊断结构
     * @return 是否存在可用诊断
     */
    bool GetFirstFailedDecryptDiagnostic(DecryptFailureDiagnostic& outDiagnostic) const;

    /**
     * @brief 获取最近一次解包的失败文件清单
     */
    std::vector<FailedFileRecord> GetLastFailedFiles() const;

    /**
     * @brief 获取最近一次路径清单审阅记录
     */
    std::vector<OutputPathManifestRecord> GetLastOutputPathManifestRecords() const;

    /**
     * @brief 检查是否正在运行
     */
    bool IsRunning() const { return m_isRunning.load(); }

    /**
     * @brief 检查是否处于暂停状态
     */
    bool IsPaused() const { return m_shouldPause.load(); }

    /**
     * @brief 加载路径映射表 (用于恢复原始文件名)
     * @param mapPath 映射表文件路径 (支持文本格式和二进制格式 .ljpm)
     * @return 错误码 (LJFP_SUCCESS=成功)
     */
    int LoadPathMapping(const std::string& mapPath);

    /**
     * @brief 加载二进制格式路径映射表 (.ljpm)
     * @param ljpmPath 二进制映射文件路径
     * @return 错误码 (LJFP_SUCCESS=成功)
     */
    int LoadPathMappingBinary(const std::string& ljpmPath);

    /**
     * @brief 获取已加载的路径映射数量
     * @return 映射条目数量
     */
    size_t GetPathMappingCount() const { return m_pathMapping.size(); }

    /**
     * @brief 获取路径映射命中率统计
     * @param hitCount 命中数量
     * @param totalCount 总文件数
     * @param rateBasis 百分比*100 (两位小数)
     * @return 是否可用（已加载映射且有文件）
     */
    bool GetPathMappingHitRate(uint32_t& hitCount, uint32_t& totalCount, uint32_t& rateBasis) const;

    /**
     * @brief 获取路径映射未命中的 CRC32 样本
     * @return 未命中样本列表
     */
    std::vector<uint32_t> GetPathMappingMissingSamples() const;
    const std::map<uint32_t, std::string>& GetPathMappingTable() const { return m_pathMapping; }

    /**
     * @brief 检查指定文件是否命中路径映射
     * @param index 文件索引
     * @return true 如果存在映射路径
     */
    bool HasPathMappingForFile(size_t index) const;

    /**
     * @brief 设置解密密钥
     * @param key 解密密钥
     */
    void SetDecryptKey(const std::string& key) { m_customDecryptKey = key; }

    /**
     * @brief 获取当前解密密钥
     * @return 当前解密密钥
     */
    std::string GetDecryptKey() const;

    /**
     * @brief 获取文件信息列表 (只读)
     * @return 文件信息列表
     */
    const std::vector<FileInfo>& GetFileList() const { return m_fileList; }

    /**
     * @brief 根据 CRC32 查找文件
     * @param pathCRC32 路径文件名 CRC32
     * @return 文件索引 (找不到返回 -1)
     */
    int FindFileByCRC32(uint32_t pathCRC32) const;

    /**
     * @brief 获取文件原始路径 (如果路径映射表已加载)
     * @param index 文件索引
     * @return 原始路径 (没有映射则返回 CRC32 字符串)
     */
    std::string GetFilePath(size_t index) const;

    /**
     * @brief 读取并解密/解压单个文件的内容样本，供映射分析或诊断使用
     * @param index 文件索引
     * @param maxBytes 最大返回字节数（0=返回完整内容）
     * @param outData 输出数据
     * @param outLogicalPath 可选输出逻辑路径
     * @return 错误码 (LJFP_SUCCESS=成功)
     */
    int ReadDecodedFileSample(size_t index,
                              size_t maxBytes,
                              std::vector<unsigned char>& outData,
                              std::string* outLogicalPath = NULL);

private:
    // 路径映射表 (CRC32 -> 原始路径)
    std::map<uint32_t, std::string> m_pathMapping;

    // 自定义解密密钥
    std::string m_customDecryptKey;

private:
    // =========================================================================
    // Index management submodule
    // =========================================================================

    /**
     * @brief 加载 .ljpi 索引文件
     * @param ljpiPath .ljpi 文件路径
     * @return 错误码
     */
    int LoadLjpiIndex(const std::string& ljpiPath);

    /**
     * @brief 加载 .ljzip 加密索引文件
     * @param ljzipPath .ljzip 文件路径
     * @return 错误码
     */
    int LoadLjzipIndex(const std::string& ljzipPath);

    // =========================================================================
    // Decrypt processing submodule
    // =========================================================================

    void BuildDecryptModeCandidates(std::vector<DecryptMode>& outModes) const;
    void DecryptBufferForMode(const unsigned char* inputData,
                              unsigned char* outputData,
                              uint32_t dataSize,
                              DecryptMode mode,
                              uint32_t fileOffset = 0,
                              uint32_t decryptWindowBytes = 1024u,
                              const std::string& candidateId = std::string()) const;
    void ResetDecryptProbeDiagnostics();
    void SetLastDecryptProbeRecords(const std::vector<DecryptProbeRecord>& records);
    void CaptureFirstFailedDecryptDiagnostic(uint32_t fileIndex,
                                            const FileInfo& fileInfo,
                                            uint32_t inputSize,
                                            int failureCode,
                                            const std::vector<DecryptProbeRecord>& probeRecords);

    /**
     * @brief 解析 .ljpi 格式数据
     * @param data 数据指针
     * @param size 数据大小
     * @return 错误码
     */
    int ParseLjpiData(const unsigned char* data, uint32_t size);

    // =========================================================================
    // Execution core
    // =========================================================================

    /**
     * @brief 单线程顺序解包
     * @return 错误码
     */
    int UnpackAllSequential();
    int UnpackSelectedSequential(const std::vector<size_t>& fileIndices);

    /**
     * @brief 多线程并行解包
     * @param threadCount 线程数
     * @return 错误码
     */
    int UnpackAllParallel(int threadCount);

    /**
     * @brief 多线程并行解包 (优化版 - 任务预排序+分片)
     * @param threadCount 线程数
     * @return 错误码
     */
    int UnpackAllParallelOptimized(int threadCount);
    int UnpackSelectedParallelOptimized(const std::vector<size_t>& fileIndices, int threadCount);

    /**
     * @brief 预创建所有输出目录
     * @param sortedIndices 排序后的文件索引 (可选，用于确定路径)
     */
    void PreCreateDirectories(const std::vector<size_t>* sortedIndices = nullptr);

    /**
     * @brief 解包单个文件 (内部实现)
     * @param fileInfo 文件信息
     * @param index 文件索引
     * @param customOutputPath 自定义输出路径 (空字符串=使用默认路径)
     * @return 错误码
     */
    int UnpackSingleFile(FileInfo& fileInfo, size_t index, const std::string& customOutputPath = "");
    bool UnpackSingleFileStream(FileInfo& fileInfo, size_t index, const std::string& customOutputPath, int& outError);
    bool UnpackSingleFileStreamCompressed(FileInfo& fileInfo, size_t index, const std::string& customOutputPath, int& outError);

    /**
     * @brief 读取文件数据
     * @param fileInfo 文件信息
     * @param outputData 输出数据指针
     * @param outputSize 输出数据大小
     * @return 错误码
     */
    int ReadFileData(const FileInfo& fileInfo, std::vector<unsigned char>& outputData);

    /**
     * @brief 解密解压处理
     * @param inputData 输入数据
     * @param inputSize 输入大小
     * @param outputData 输出数据
     * @param needDecrypt 是否需要解密
     * @param needDecompress 是否需要解压
     * @param originalSize 原始大小 (用于估算缓冲区)
     * @return 错误码
     */
    int DecryptAndDecompress(
        const unsigned char* inputData, uint32_t inputSize,
        std::vector<unsigned char>& outputData,
        bool needDecrypt, bool needDecompress, uint32_t originalSize,
        uint32_t expectedCRC32 = 0,
        std::vector<DecryptProbeRecord>* probeRecords = nullptr);

    /**
     * @brief 为写盘阶段解析最终输出路径（含冲突消解）
     * @param fileInfo 文件信息
     * @param requestedOutputPath 请求路径（空字符串=自动构建）
     * @param fileData 文件数据（用于自动扩展名检测，可为 nullptr）
     * @param dataSize 文件数据大小
     * @param resolvedOutputPath 解析后的输出路径
     * @return 错误码
     */
    int ResolveOutputPathForWrite(const FileInfo& fileInfo,
                                  const std::string& requestedOutputPath,
                                  const unsigned char* fileData,
                                  uint32_t dataSize,
                                  std::string& resolvedOutputPath);

    // =========================================================================
    // Path restoration submodule
    // =========================================================================

    /**
     * @brief 为冲突文件生成稳定的回退路径
     * @param outputPath 原始目标路径
     * @param pathFileNameCRC32 文件路径 CRC32
     * @param conflictIndex 冲突序号（从 1 开始）
     * @return 冲突回退路径
     */
    std::string BuildConflictOutputPath(const std::string& outputPath,
                                        uint32_t pathFileNameCRC32,
                                        uint32_t conflictIndex) const;

    /**
     * @brief 解包完成后的路径恢复与重复清理
     * @return 错误码
     */
    int PostProcessRestoredOutputs();

    /**
     * @brief 写出路径清单
     */
    void RefreshOutputPathAuditFinalPaths();
    int WriteOutputPathManifest();

    /**
     * @brief 构建输出路径
     * @param fileInfo 文件信息
     * @param fileData 文件数据 (用于类型检测, 可为 nullptr)
     * @param dataSize 文件数据大小
     * @return 输出文件路径
     */
    std::string BuildOutputPath(const FileInfo& fileInfo, const unsigned char* fileData = nullptr, uint32_t dataSize = 0);
    bool WaitIfPaused();

    /**
     * @brief 获取目录路径
     * @param filePath 文件路径
     * @return 目录路径
     */
    std::string GetDirectoryPath(const std::string& filePath);

    /**
     * @brief 创建目录 (递归)
     * @param dirPath 目录路径
     */
    void CreateDirectoryRecursive(const std::string& dirPath);

    /**
     * @brief 统计路径映射命中率
     * @param context 日志上下文
     */
    void ReportPathMappingHitRate(const std::wstring& context);

    /**
     * @brief 严格校验路径恢复结果
     */
    int ValidateRestoreOutcome();

    /**
     * @brief Review output submodule
     */
    void ResetRunDiagnostics();
    void RecordFailedFile(size_t index, const FileInfo& fileInfo, int errorCode);
};

} // namespace SLJFP

#endif // SLJFP_UNPACK_H

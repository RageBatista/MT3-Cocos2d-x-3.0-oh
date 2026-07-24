/**
 * @file SLJFP_PathMappingGenerator.h
 * @brief 路径映射生成器 - 扫描资源目录生成 CRC32 → 原始路径 映射表
 * @author SuperLJFilePackUnpack Project
 * @date 2026-01-04
 * @version 1.0
 *
 * 本模块用于从已知的资源目录（如客户端 res/ 文件夹）扫描文件，
 * 计算每个相对路径的 CRC32 值，生成映射文件供 Unpacker 使用。
 *
 * 工作流程:
 *   1. 扫描指定目录，收集所有文件的相对路径
 *   2. 使用与 LJFilePack 相同的 CRC32 算法计算路径哈希
 *   3. 输出映射文件 (文本格式: "CRC32|原始路径")
 *
 * 使用示例:
 * @code
 * SLJFP::PathMappingGenerator generator;
 * generator.SetCRC32Function(myCRC32Func);  // 注入 CRC32 函数
 * generator.ScanDirectory("E:/MT3/client/resource/res");
 * generator.SaveMapping("path_mapping.txt");
 * @endcode
 */

#pragma once
#ifndef SLJFP_PATH_MAPPING_GENERATOR_H
#define SLJFP_PATH_MAPPING_GENERATOR_H

#include <cstdint>
#include <string>
#include <vector>
#include <map>
#include <functional>

#ifdef includeHidden
#undef includeHidden
#endif
#ifdef pathPrefix
#undef pathPrefix
#endif
#ifdef sljfpIncludeHidden
#undef sljfpIncludeHidden
#endif
#ifdef sljfpPathPrefix
#undef sljfpPathPrefix
#endif
#ifdef sljfpScanIncludeHiddenFlag
#undef sljfpScanIncludeHiddenFlag
#endif
#ifdef sljfpScanPathPrefixValue
#undef sljfpScanPathPrefixValue
#endif
#ifdef includeHiddenFiles
#undef includeHiddenFiles
#endif
#ifdef pathPrefixStr
#undef pathPrefixStr
#endif

namespace SLJFP {

/**
 * @brief CRC32 计算函数类型
 *
 * 签名与 LJFP_CRC32.h 中的 LJFP_CRC32 兼容
 * @param crc 初始 CRC 值 (通常为 0)
 * @param data 数据指针
 * @param len 数据长度
 * @return CRC32 值
 */
typedef uint32_t (*CRC32_PathFunc)(uint32_t crc, const void* data, size_t len);

/**
 * @class PathMappingGenerator
 * @brief 路径映射生成器类
 *
 * 扫描资源目录，生成 CRC32 到原始路径的映射表。
 */
class PathMappingGenerator {
public:
    /**
     * @brief 路径 CRC 输入模式
     */
    enum class PathHashMode {
        NormalizedPath = 0,          ///< 使用规范化后的存储路径参与 CRC
        LjFilePackLegacyAcpExact = 1 ///< 兼容 LJFilePack：保留大小写，仅规范化斜杠并按 ACP 字节做 CRC
    };

    /**
     * @brief 路径条目结构
     */
    struct PathEntry {
        std::string relativePath;   ///< 相对路径 (使用 / 分隔符)
        uint32_t crc32;             ///< 路径的 CRC32 值
        uint64_t fileSize;          ///< 文件大小 (字节)

        PathEntry() : crc32(0), fileSize(0) {}
        PathEntry(const std::string& path, uint32_t crc, uint64_t size)
            : relativePath(path), crc32(crc), fileSize(size) {}
    };

    /**
     * @brief 扫描选项
     */
    struct ScanOptions {
        bool recursiveScan;         ///< 是否递归扫描子目录
        bool sljfpScanIncludeHiddenFlag;    ///< 是否包含隐藏文件
        bool lowercasePaths;        ///< 是否将路径转为小写 (用于大小写不敏感匹配)
        bool normalizeSlashes;      ///< 是否将反斜杠转为正斜杠
        std::string sljfpScanPathPrefixValue;  ///< 可选的路径前缀 (添加到相对路径前)
        PathHashMode pathHashMode;  ///< 路径 CRC 输入模式

        ScanOptions()
            : recursiveScan(true)
            , sljfpScanIncludeHiddenFlag(false)
            , lowercasePaths(true)
            , normalizeSlashes(true)
            , sljfpScanPathPrefixValue("")
            , pathHashMode(PathHashMode::NormalizedPath) {}
    };

    /**
     * @brief 扫描统计信息
     */
    struct ScanStats {
        uint32_t totalFiles;        ///< 扫描的文件总数
        uint32_t totalDirs;         ///< 扫描的目录总数
        uint64_t totalBytes;        ///< 总文件大小 (字节)
        uint32_t collisions;        ///< CRC32 碰撞数量
        double scanTimeMs;          ///< 扫描耗时 (毫秒)

        ScanStats()
            : totalFiles(0), totalDirs(0), totalBytes(0)
            , collisions(0), scanTimeMs(0.0) {}

        void reset() {
            totalFiles = 0;
            totalDirs = 0;
            totalBytes = 0;
            collisions = 0;
            scanTimeMs = 0.0;
        }
    };

    /**
     * @brief 进度回调函数类型
     * @param current 当前处理的文件数
     * @param total 总文件数
     * @param currentPath 当前处理的路径
     */
    typedef std::function<void(uint32_t current, uint32_t total, const std::string& currentPath)> ProgressCallback;

public:
    /**
     * @brief 构造函数
     */
    PathMappingGenerator();

    /**
     * @brief 析构函数
     */
    ~PathMappingGenerator();

    /**
     * @brief 设置 CRC32 计算函数
     * @param func CRC32 函数指针
     *
     * @note 必须在扫描前设置，否则使用内置默认实现
     */
    void SetCRC32Function(CRC32_PathFunc func);

    /**
     * @brief 扫描目录，收集文件路径并计算 CRC32
     * @param rootDir 根目录路径
     * @param options 扫描选项
     * @return 扫描到的文件数量
     */
    uint32_t ScanDirectory(const std::string& rootDir, const ScanOptions& options = ScanOptions());

    /**
     * @brief 添加单个路径条目
     * @param relativePath 相对路径
     * @param fileSize 文件大小 (可选)
     * @return 计算得到的 CRC32 值
     *
     * @note 用于手动添加路径，无需实际文件存在
     */
    uint32_t AddPath(const std::string& relativePath, uint64_t fileSize = 0);

    /**
     * @brief 添加一个带权威 CRC 的路径条目
     * @param relativePath 相对路径
     * @param crc32 外部已确认的 CRC32
     * @param fileSize 文件大小 (可选)
     * @return 保留后的 CRC32 值
     *
     * @note 用于合并外部映射种子时保留原始 CRC，避免重新计算后发生漂移
     */
    uint32_t AddPathWithCRC(const std::string& relativePath, uint32_t crc32, uint64_t fileSize = 0);

    /**
     * @brief 规范化映射存储路径
     * @param relativePath 原始相对路径
     * @return 统一为小写、正斜杠并剥离已知资源根前缀后的路径
     */
    static std::string CanonicalizeStoragePath(const std::string& relativePath);

    /**
     * @brief 判断 CRC 仓模式下的低置信路径
     * @param relativePath 原始相对路径
     * @return true 表示该路径更可能是污染候选，不应写入最终映射
     */
    static bool IsLowConfidenceCrcRepositoryPath(const std::string& relativePath);

    /**
     * @brief 从已有的路径列表文件加载
     * @param pathListFile 路径列表文件 (每行一个路径)
     * @return 加载的路径数量
     */
    uint32_t LoadPathList(const std::string& pathListFile);

    /**
     * @brief 保存映射表到文件 (文本格式)
     * @param outputPath 输出文件路径
     * @param useHex 是否使用十六进制格式 (默认十进制)
     * @return 成功返回 0，失败返回错误码
     *
     * 输出格式 (每行一条):
     *   十进制: "CRC32|相对路径"
     *   十六进制: "0xCRC32\t相对路径"
     */
    int SaveMapping(const std::string& outputPath, bool useHex = false);

    /**
     * @brief 保存映射表到文件 (二进制格式)
     * @param outputPath 输出文件路径
     * @return 成功返回 0，失败返回错误码
     *
     * 二进制格式:
     *   - 4 字节: 魔数 "LJPM" (0x4D504A4C)
     *   - 4 字节: 版本号 (1)
     *   - 4 字节: 条目数量
     *   - 每条记录:
     *     - 4 字节: CRC32
     *     - 2 字节: 路径长度
     *     - N 字节: 路径字符串 (UTF-8, 无终止符)
     */
    int SaveMappingBinary(const std::string& outputPath);

    /**
     * @brief 清空所有已扫描的数据
     */
    void Clear();

    /**
     * @brief 设置进度回调
     * @param callback 回调函数
     */
    void SetProgressCallback(ProgressCallback callback);

    // ========== Getter 方法 ==========

    /**
     * @brief 获取所有路径条目
     * @return 路径条目列表
     */
    const std::vector<PathEntry>& GetEntries() const { return m_entries; }

    /**
     * @brief 获取 CRC32 → 路径 映射表
     * @return 映射表
     */
    const std::map<uint32_t, std::string>& GetMapping() const { return m_mapping; }

    /**
     * @brief 获取扫描统计信息
     * @return 统计信息
     */
    const ScanStats& GetStats() const { return m_stats; }

    /**
     * @brief 根据 CRC32 查找路径
     * @param crc32 CRC32 值
     * @return 找到的路径，未找到返回空字符串
     */
    std::string FindPath(uint32_t crc32) const;

    /**
     * @brief 检查是否存在 CRC32 碰撞
     * @return 碰撞的 CRC32 值列表
     */
    std::vector<uint32_t> GetCollisions() const;

private:
    /**
     * @brief 递归扫描目录
     */
    void ScanDirectoryRecursive(const std::string& currentDir, const std::string& rootDir,
                                 const ScanOptions& options);

    /**
     * @brief 规范化路径
     */
    std::string NormalizePath(const std::string& path, const ScanOptions& options);

    /**
     * @brief 内置 CRC32 实现 (如果未注入外部函数)
     */
    static uint32_t DefaultCRC32(uint32_t crc, const void* data, size_t len);

    /**
     * @brief 计算路径的 CRC32
     */
    uint32_t CalculatePathCRC32(const std::string& path);

    /**
     * @brief 构建用于序列化的去重条目列表
     */
    std::vector<PathEntry> BuildSerializableEntries() const;

private:
    CRC32_PathFunc m_crc32Func;                     ///< CRC32 函数指针
    std::vector<PathEntry> m_entries;               ///< 路径条目列表
    std::map<uint32_t, std::string> m_mapping;      ///< CRC32 → 路径 映射
    std::map<uint32_t, std::vector<std::string>> m_collisionMap;  ///< 碰撞检测映射
    ScanStats m_stats;                              ///< 扫描统计
    ProgressCallback m_progressCallback;            ///< 进度回调

    static const uint32_t BINARY_MAGIC = 0x4D504A4C;  ///< "LJPM" 魔数
    static const uint32_t BINARY_VERSION = 1;          ///< 二进制格式版本
};

} // namespace SLJFP

#endif // SLJFP_PATH_MAPPING_GENERATOR_H

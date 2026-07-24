/**
 * @file SLJFP_PathMappingGenerator.cpp
 * @brief 路径映射生成器实现
 * @version 1.0
 * @date 2026-01-04
 */

#include "../include/SLJFP_PathMappingGenerator.h"
#include "../include/SLJFP_ErrorCodes.h"

#include <fstream>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <chrono>
#include <cctype>
#include <cstdio>
#include <cwctype>
#include <functional>

#ifdef _WIN32
#include <windows.h>
#include <io.h>
#include <direct.h>
#else
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

namespace SLJFP {

namespace {

std::string NormalizeStorageLikePath(const std::string& rawPath) {
    std::string normalized;
    normalized.reserve(rawPath.size());

    for (size_t i = 0; i < rawPath.size(); ++i) {
        char c = rawPath[i];
        if (c == '\\') {
            c = '/';
        }
        normalized.push_back(static_cast<char>(std::tolower(static_cast<unsigned char>(c))));
    }

    while (!normalized.empty() &&
           (normalized[0] == '/' || normalized[0] == '\\')) {
        normalized.erase(normalized.begin());
    }

    std::string compact;
    compact.reserve(normalized.size());
    bool lastSlash = false;
    for (size_t i = 0; i < normalized.size(); ++i) {
        const char c = normalized[i];
        if (c == '/') {
            if (!lastSlash) {
                compact.push_back(c);
            }
            lastSlash = true;
        } else {
            compact.push_back(c);
            lastSlash = false;
        }
    }

    while (!compact.empty() && compact.back() == '/') {
        compact.pop_back();
    }
    return compact;
}

std::string GetFileExtensionLowerForStorage(const std::string& rawPath) {
    const std::string normalized = NormalizeStorageLikePath(rawPath);
    const size_t slash = normalized.find_last_of('/');
    const size_t dot = normalized.find_last_of('.');
    if (dot == std::string::npos) {
        return std::string();
    }
    if (slash != std::string::npos && dot < slash) {
        return std::string();
    }
    return normalized.substr(dot);
}

std::string GetDirectoryPartForStorage(const std::string& rawPath) {
    const std::string normalized = NormalizeStorageLikePath(rawPath);
    const size_t slash = normalized.find_last_of('/');
    if (slash == std::string::npos) {
        return std::string();
    }
    return normalized.substr(0, slash);
}

std::string GetLeafNameForStorage(const std::string& rawPath) {
    const std::string normalized = NormalizeStorageLikePath(rawPath);
    const size_t slash = normalized.find_last_of('/');
    if (slash == std::string::npos) {
        return normalized;
    }
    return normalized.substr(slash + 1);
}

bool IsDigitsOnlyStringForStorage(const std::string& value) {
    if (value.empty()) {
        return false;
    }
    for (size_t i = 0; i < value.size(); ++i) {
        if (!std::isdigit(static_cast<unsigned char>(value[i]))) {
            return false;
        }
    }
    return true;
}

bool IsNumericRootLikePathForStorage(const std::string& rawPath) {
    std::string normalized = NormalizeStorageLikePath(rawPath);
    if (normalized.empty()) {
        return false;
    }
    if (normalized.find('/') != std::string::npos) {
        return false;
    }

    size_t dot = normalized.find('.');
    std::string stem = normalized;
    if (dot != std::string::npos) {
        std::string ext = normalized.substr(dot + 1);
        if (ext.empty()) {
            return false;
        }
        for (size_t i = 0; i < ext.size(); ++i) {
            const unsigned char c = static_cast<unsigned char>(ext[i]);
            if (!(std::isalnum(c) || c == '_')) {
                return false;
            }
        }
        stem = normalized.substr(0, dot);
    }
    return IsDigitsOnlyStringForStorage(stem);
}

bool ContainsPathSegmentForStorage(const std::string& rawPath, const std::string& segment) {
    if (segment.empty()) {
        return false;
    }

    const std::string path = NormalizeStorageLikePath(rawPath);
    if (path.empty()) {
        return false;
    }

    if (path == segment) {
        return true;
    }
    if (path.size() > segment.size() &&
        path.compare(0, segment.size(), segment) == 0 &&
        path[segment.size()] == '/') {
        return true;
    }

    const std::string needle = "/" + segment + "/";
    if (path.find(needle) != std::string::npos) {
        return true;
    }
    const std::string tail = "/" + segment;
    if (path.size() > tail.size() &&
        path.compare(path.size() - tail.size(), tail.size(), tail) == 0) {
        return true;
    }
    return false;
}

std::string StripKnownResourcePrefixesForStorage(const std::string& rawPath) {
    std::string normalized = NormalizeStorageLikePath(rawPath);
    static const char* const kPrefixes[] = {
        "client/resource/res/",
        "resource/res/",
        "assets/res/",
        "res/",
        "assets/",
        "resource/",
        "client/resource/"
    };
    for (size_t i = 0; i < sizeof(kPrefixes) / sizeof(kPrefixes[0]); ++i) {
        const std::string prefix = kPrefixes[i];
        if (normalized.size() > prefix.size() &&
            normalized.compare(0, prefix.size(), prefix) == 0) {
            return normalized.substr(prefix.size());
        }
    }
    return normalized;
}

bool IsKnownResourceExtensionForStorage(const std::string& extension) {
    static const char* const kKnownExtensions[] = {
        ".lua", ".xml", ".json", ".bin", ".ani", ".atlas",
        ".png", ".dds", ".tga", ".jpg", ".jpeg", ".webp",
        ".layout", ".imageset", ".font", ".txt", ".cfg", ".ini",
        ".eff", ".inf", ".set", ".dat", ".plist", ".csv",
        ".ogg", ".wav", ".mp3", ".act", ".lmx", ".mrmp", ".rmp"
    };
    for (size_t i = 0; i < sizeof(kKnownExtensions) / sizeof(kKnownExtensions[0]); ++i) {
        if (extension == kKnownExtensions[i]) {
            return true;
        }
    }
    return false;
}

std::string BuildTempOutputPath(const std::string& outputPath) {
    return outputPath + ".tmp";
}

bool ReplaceOutputFile(const std::string& tempPath, const std::string& outputPath) {
#ifdef _WIN32
    if (MoveFileExA(tempPath.c_str(),
                    outputPath.c_str(),
                    MOVEFILE_REPLACE_EXISTING | MOVEFILE_COPY_ALLOWED | MOVEFILE_WRITE_THROUGH)) {
        return true;
    }
    DeleteFileA(tempPath.c_str());
    return false;
#else
    std::remove(outputPath.c_str());
    if (std::rename(tempPath.c_str(), outputPath.c_str()) == 0) {
        return true;
    }
    std::remove(tempPath.c_str());
    return false;
#endif
}

} // namespace

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

// ============================================================================
// Windows: encoding/path helpers for LJFilePack compatibility
// ============================================================================
#ifdef _WIN32
static std::wstring AcpToWide(const std::string& s) {
    if (s.empty()) {
        return L"";
    }
    int len = MultiByteToWideChar(CP_ACP, 0, s.data(), (int)s.size(), nullptr, 0);
    if (len <= 0) {
        return L"";
    }
    std::wstring out(len, L'\0');
    MultiByteToWideChar(CP_ACP, 0, s.data(), (int)s.size(), &out[0], len);
    return out;
}

static std::string WideToAcp(const std::wstring& s) {
    if (s.empty()) {
        return "";
    }
    int len = WideCharToMultiByte(CP_ACP, 0, s.data(), (int)s.size(), nullptr, 0, nullptr, nullptr);
    if (len <= 0) {
        return "";
    }
    std::string out(len, '\0');
    WideCharToMultiByte(CP_ACP, 0, s.data(), (int)s.size(), &out[0], len, nullptr, nullptr);
    return out;
}

static std::wstring NormalizePathW(const std::wstring& path, const PathMappingGenerator::ScanOptions& options) {
    std::wstring result = path;

    if (options.normalizeSlashes) {
        for (size_t i = 0; i < result.size(); i++) {
            if (result[i] == L'\\') {
                result[i] = L'/';
            }
        }
    }

    if (options.lowercasePaths) {
        for (size_t i = 0; i < result.size(); i++) {
            result[i] = static_cast<wchar_t>(towlower(result[i]));
        }
    }

    if (!options.sljfpScanPathPrefixValue.empty()) {
        std::wstring prefix = AcpToWide(options.sljfpScanPathPrefixValue);
        if (!prefix.empty() && prefix.back() != L'/' && prefix.back() != L'\\') {
            prefix += L"/";
        }
        result = prefix + result;
    }

    return result;
}

#endif

static PathMappingGenerator::ScanOptions BuildHashScanOptions(
    const PathMappingGenerator::ScanOptions& options) {
    PathMappingGenerator::ScanOptions hashOptions = options;
    if (hashOptions.pathHashMode ==
        PathMappingGenerator::PathHashMode::LjFilePackLegacyAcpExact) {
        hashOptions.lowercasePaths = false;
    }
    return hashOptions;
}

// ============================================================================
// 内置 CRC32 实现 (与 LJFilePack 兼容)
// ============================================================================

static const uint32_t s_crc32Table[256] = {
    0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3,
    0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91,
    0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
    0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5,
    0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B,
    0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
    0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F,
    0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D,
    0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
    0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01,
    0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457,
    0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
    0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB,
    0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9,
    0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
    0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD,
    0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683,
    0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
    0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7,
    0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5,
    0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
    0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79,
    0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F,
    0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
    0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713,
    0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21,
    0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
    0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45,
    0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB,
    0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
    0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF,
    0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D
};

uint32_t PathMappingGenerator::DefaultCRC32(uint32_t crc, const void* data, size_t len) {
    const uint8_t* buf = static_cast<const uint8_t*>(data);
    crc = crc ^ 0xFFFFFFFF;
    for (size_t i = 0; i < len; i++) {
        crc = s_crc32Table[(crc ^ buf[i]) & 0xFF] ^ (crc >> 8);
    }
    return crc ^ 0xFFFFFFFF;
}

// ============================================================================
// 构造与析构
// ============================================================================

PathMappingGenerator::PathMappingGenerator()
    : m_crc32Func(nullptr)
    , m_progressCallback(nullptr)
{
}

PathMappingGenerator::~PathMappingGenerator() {
    Clear();
}

void PathMappingGenerator::SetCRC32Function(CRC32_PathFunc func) {
    m_crc32Func = func;
}

void PathMappingGenerator::SetProgressCallback(ProgressCallback callback) {
    m_progressCallback = callback;
}

std::string PathMappingGenerator::CanonicalizeStoragePath(const std::string& relativePath) {
    const std::string normalized = NormalizeStorageLikePath(relativePath);
    if (normalized.empty()) {
        return normalized;
    }

    const std::string stripped = StripKnownResourcePrefixesForStorage(normalized);
    if (!stripped.empty()) {
        return stripped;
    }
    return normalized;
}

bool PathMappingGenerator::IsLowConfidenceCrcRepositoryPath(const std::string& relativePath) {
    const std::string normalized = CanonicalizeStoragePath(relativePath);
    if (normalized.empty()) {
        return true;
    }

    const bool hasDirectory = normalized.find('/') != std::string::npos;
    const std::string leaf = GetLeafNameForStorage(normalized);
    const std::string ext = GetFileExtensionLowerForStorage(leaf);
    std::string stem = leaf;
    if (!ext.empty() && leaf.size() >= ext.size()) {
        stem = leaf.substr(0, leaf.size() - ext.size());
    }

    if (!hasDirectory &&
        normalized.find('.') == std::string::npos &&
        normalized.size() <= 4) {
        return true;
    }

    if (IsNumericRootLikePathForStorage(normalized)) {
        return true;
    }
    if (normalized == ".uedd") {
        return true;
    }
    if (normalized.find(".conflict.") != std::string::npos) {
        return true;
    }
    if (ContainsPathSegmentForStorage(normalized, "unpacked")) {
        return true;
    }

    if (ext == ".") {
        return true;
    }
    if (ext.empty() && leaf.size() <= 1) {
        return true;
    }
    if (!hasDirectory &&
        stem.size() <= 3 &&
        (ext.empty() || ext.size() <= 2) &&
        !IsKnownResourceExtensionForStorage(ext)) {
        return true;
    }
    if (!hasDirectory &&
        !ext.empty() &&
        stem.size() <= 4 &&
        ext.size() <= 4 &&
        !IsKnownResourceExtensionForStorage(ext)) {
        return true;
    }

    const std::string parentLeaf = GetLeafNameForStorage(GetDirectoryPartForStorage(normalized));
    if (hasDirectory &&
        ext.empty() &&
        leaf.size() <= 1 &&
        parentLeaf.size() <= 3) {
        return true;
    }

    const std::string stripped = StripKnownResourcePrefixesForStorage(normalized);
    if (IsNumericRootLikePathForStorage(stripped)) {
        return true;
    }

    return false;
}

void PathMappingGenerator::Clear() {
    m_entries.clear();
    m_mapping.clear();
    m_collisionMap.clear();
    m_stats.reset();
}

// ============================================================================
// 路径处理
// ============================================================================

std::string PathMappingGenerator::NormalizePath(const std::string& path, const ScanOptions& options) {
    std::string result = path;

    // 规范化斜杠
    if (options.normalizeSlashes) {
        for (size_t i = 0; i < result.size(); i++) {
            if (result[i] == '\\') {
                result[i] = '/';
            }
        }
    }

    // 转为小写
    if (options.lowercasePaths) {
        for (size_t i = 0; i < result.size(); i++) {
            result[i] = static_cast<char>(std::tolower(static_cast<unsigned char>(result[i])));
        }
    }

    // 添加路径前缀
    if (!options.sljfpScanPathPrefixValue.empty()) {
        std::string prefix = options.sljfpScanPathPrefixValue;
        // 确保前缀末尾有分隔符
        if (!prefix.empty() && prefix.back() != '/' && prefix.back() != '\\') {
            prefix += '/';
        }
        result = prefix + result;
    }

    return result;
}

uint32_t PathMappingGenerator::CalculatePathCRC32(const std::string& path) {
    if (m_crc32Func) {
        return m_crc32Func(0, path.c_str(), path.size());
    }
    return DefaultCRC32(0, path.c_str(), path.size());
}

// ============================================================================
// 目录扫描
// ============================================================================

#ifdef _WIN32

uint32_t PathMappingGenerator::ScanDirectory(const std::string& rootDir, const ScanOptions& options) {
    auto startTime = std::chrono::high_resolution_clock::now();

    m_stats.reset();
    // 不清除已有数据，允许增量扫描
    // Clear();

    ScanDirectoryRecursive(rootDir, rootDir, options);

    auto endTime = std::chrono::high_resolution_clock::now();
    m_stats.scanTimeMs = std::chrono::duration<double, std::milli>(endTime - startTime).count();

    return m_stats.totalFiles;
}

void PathMappingGenerator::ScanDirectoryRecursive(const std::string& currentDir,
                                                   const std::string& rootDir,
                                                   const ScanOptions& options) {
    std::wstring rootDirW = AcpToWide(rootDir);
    std::wstring currentDirW = AcpToWide(currentDir);
    if (rootDirW.empty() || currentDirW.empty()) {
        return;
    }

    std::function<void(const std::wstring&)> scanW = [&](const std::wstring& dirW) {
        std::wstring searchPath = dirW + L"\\*";
        WIN32_FIND_DATAW findData;
        HANDLE hFind = FindFirstFileW(searchPath.c_str(), &findData);
        if (hFind == INVALID_HANDLE_VALUE) {
            return;
        }

        do {
            std::wstring fileName = findData.cFileName;

            if (fileName == L"." || fileName == L"..") {
                continue;
            }

        if (!options.sljfpScanIncludeHiddenFlag && (findData.dwFileAttributes & FILE_ATTRIBUTE_HIDDEN)) {
                continue;
            }

            std::wstring fullPath = dirW + L"\\" + fileName;

            if (findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                m_stats.totalDirs++;
                if (options.recursiveScan) {
                    scanW(fullPath);
                }
            } else {
                std::wstring relativePathW;
                if (fullPath.size() > rootDirW.size()) {
                    relativePathW = fullPath.substr(rootDirW.size());
                    while (!relativePathW.empty() && (relativePathW[0] == L'\\' || relativePathW[0] == L'/')) {
                        relativePathW = relativePathW.substr(1);
                    }
                }

                if (relativePathW.empty()) {
                    continue;
                }

                const ScanOptions hashOptions = BuildHashScanOptions(options);
                const std::wstring storagePathW = NormalizePathW(relativePathW, options);
                const std::wstring hashPathW = NormalizePathW(relativePathW, hashOptions);

                std::string relativePath = WideToAcp(storagePathW);
                if (relativePath.empty()) {
                    continue;
                }
                std::string crcInputPath = WideToAcp(hashPathW);
                if (crcInputPath.empty()) {
                    crcInputPath = relativePath;
                }

                LARGE_INTEGER fileSize;
                fileSize.LowPart = findData.nFileSizeLow;
                fileSize.HighPart = findData.nFileSizeHigh;
                uint64_t size = static_cast<uint64_t>(fileSize.QuadPart);

                uint32_t crc32 = CalculatePathCRC32(crcInputPath);

                PathEntry entry(relativePath, crc32, size);
                m_entries.push_back(entry);

                auto it = m_mapping.find(crc32);
                if (it != m_mapping.end()) {
                    m_stats.collisions++;
                    m_collisionMap[crc32].push_back(relativePath);
                    if (m_collisionMap[crc32].size() == 1) {
                        m_collisionMap[crc32].insert(m_collisionMap[crc32].begin(), it->second);
                    }
                } else {
                    m_mapping[crc32] = relativePath;
                }

                m_stats.totalFiles++;
                m_stats.totalBytes += size;

                if (m_progressCallback) {
                    m_progressCallback(m_stats.totalFiles, 0, relativePath);
                }
            }
        } while (FindNextFileW(hFind, &findData) != 0);

        FindClose(hFind);
    };

    scanW(currentDirW);
}

#else  // POSIX

uint32_t PathMappingGenerator::ScanDirectory(const std::string& rootDir, const ScanOptions& options) {
    auto startTime = std::chrono::high_resolution_clock::now();

    m_stats.reset();

    ScanDirectoryRecursive(rootDir, rootDir, options);

    auto endTime = std::chrono::high_resolution_clock::now();
    m_stats.scanTimeMs = std::chrono::duration<double, std::milli>(endTime - startTime).count();

    return m_stats.totalFiles;
}

void PathMappingGenerator::ScanDirectoryRecursive(const std::string& currentDir,
                                                   const std::string& rootDir,
                                                   const ScanOptions& options) {
    DIR* dir = opendir(currentDir.c_str());
    if (!dir) {
        return;
    }

    struct dirent* entry;
    while ((entry = readdir(dir)) != nullptr) {
        std::string fileName = entry->d_name;

        // 跳过 . 和 ..
        if (fileName == "." || fileName == "..") {
            continue;
        }

        // 跳过隐藏文件
        if (!options.sljfpScanIncludeHiddenFlag && fileName[0] == '.') {
            continue;
        }

        std::string fullPath = currentDir + "/" + fileName;

        struct stat statBuf;
        if (stat(fullPath.c_str(), &statBuf) != 0) {
            continue;
        }

        if (S_ISDIR(statBuf.st_mode)) {
            m_stats.totalDirs++;
            if (options.recursiveScan) {
                ScanDirectoryRecursive(fullPath, rootDir, options);
            }
        } else if (S_ISREG(statBuf.st_mode)) {
            // 计算相对路径
            std::string relativePath;
            if (fullPath.size() > rootDir.size()) {
                relativePath = fullPath.substr(rootDir.size());
                while (!relativePath.empty() && relativePath[0] == '/') {
                    relativePath = relativePath.substr(1);
                }
            }

            if (relativePath.empty()) {
                continue;
            }

            const ScanOptions hashOptions = BuildHashScanOptions(options);
            const std::string storagePath = NormalizePath(relativePath, options);
            const std::string hashPath = NormalizePath(relativePath, hashOptions);
            relativePath = storagePath;
            uint64_t size = static_cast<uint64_t>(statBuf.st_size);
            const std::string& crcInputPath = hashPath.empty() ? relativePath : hashPath;
            uint32_t crc32 = CalculatePathCRC32(crcInputPath);

            PathEntry pathEntry(relativePath, crc32, size);
            m_entries.push_back(pathEntry);

            auto it = m_mapping.find(crc32);
            if (it != m_mapping.end()) {
                m_stats.collisions++;
                m_collisionMap[crc32].push_back(relativePath);
                if (m_collisionMap[crc32].size() == 1) {
                    m_collisionMap[crc32].insert(m_collisionMap[crc32].begin(), it->second);
                }
            } else {
                m_mapping[crc32] = relativePath;
            }

            m_stats.totalFiles++;
            m_stats.totalBytes += size;

            if (m_progressCallback) {
                m_progressCallback(m_stats.totalFiles, 0, relativePath);
            }
        }
    }

    closedir(dir);
}

#endif

// ============================================================================
// 手动添加路径
// ============================================================================

uint32_t PathMappingGenerator::AddPath(const std::string& relativePath, uint64_t fileSize) {
    ScanOptions defaultOptions;
    std::string normalizedPath = NormalizePath(relativePath, defaultOptions);

    uint32_t crc32 = CalculatePathCRC32(normalizedPath);

    PathEntry entry(normalizedPath, crc32, fileSize);
    m_entries.push_back(entry);

    auto it = m_mapping.find(crc32);
    if (it != m_mapping.end()) {
        m_stats.collisions++;
        m_collisionMap[crc32].push_back(normalizedPath);
        if (m_collisionMap[crc32].size() == 1) {
            m_collisionMap[crc32].insert(m_collisionMap[crc32].begin(), it->second);
        }
    } else {
        m_mapping[crc32] = normalizedPath;
    }

    m_stats.totalFiles++;
    m_stats.totalBytes += fileSize;

    return crc32;
}

uint32_t PathMappingGenerator::AddPathWithCRC(const std::string& relativePath,
                                              uint32_t crc32,
                                              uint64_t fileSize) {
    ScanOptions defaultOptions;
    std::string normalizedPath = NormalizePath(relativePath, defaultOptions);
    if (normalizedPath.empty()) {
        return crc32;
    }

    auto it = m_mapping.find(crc32);
    if (it != m_mapping.end() && it->second == normalizedPath) {
        return crc32;
    }

    PathEntry entry(normalizedPath, crc32, fileSize);
    m_entries.push_back(entry);

    if (it != m_mapping.end()) {
        m_stats.collisions++;
        std::vector<std::string>& collisionPaths = m_collisionMap[crc32];
        if (collisionPaths.empty()) {
            collisionPaths.push_back(it->second);
        }
        if (std::find(collisionPaths.begin(), collisionPaths.end(), normalizedPath) ==
            collisionPaths.end()) {
            collisionPaths.push_back(normalizedPath);
        }
    } else {
        m_mapping[crc32] = normalizedPath;
    }

    m_stats.totalFiles++;
    m_stats.totalBytes += fileSize;
    return crc32;
}

uint32_t PathMappingGenerator::LoadPathList(const std::string& pathListFile) {
    std::ifstream fs(pathListFile);
    if (!fs.is_open()) {
        return 0;
    }

    uint32_t count = 0;
    std::string line;

    while (std::getline(fs, line)) {
        // 去除首尾空白
        size_t start = line.find_first_not_of(" \t\r\n");
        if (start == std::string::npos) {
            continue;
        }
        size_t end = line.find_last_not_of(" \t\r\n");
        line = line.substr(start, end - start + 1);

        // 跳过空行和注释
        if (line.empty() || line[0] == '#' || (line.size() >= 2 && line[0] == '/' && line[1] == '/')) {
            continue;
        }

        AddPath(line);
        count++;
    }

    fs.close();
    return count;
}

// ============================================================================
// 保存映射
// ============================================================================

int PathMappingGenerator::SaveMapping(const std::string& outputPath, bool useHex) {
    const std::string tempPath = BuildTempOutputPath(outputPath);
    std::ofstream fs(tempPath.c_str(), std::ios::out | std::ios::trunc);
    if (!fs.is_open()) {
        return LJFP_ERROR_FILE_CREATE_FAILED;
    }

    const std::vector<PathEntry> serializableEntries = BuildSerializableEntries();

    size_t collisionGroups = m_collisionMap.size();
    size_t collisionEntries = 0;
    size_t maxCollisionGroup = 0;
    for (auto it = m_collisionMap.begin(); it != m_collisionMap.end(); ++it) {
        size_t count = it->second.size();
        collisionEntries += count;
        if (count > maxCollisionGroup) {
            maxCollisionGroup = count;
        }
    }

    // 写入头部注释
    fs << "# Path Mapping File\n";
    fs << "# Generated by SuperLJFilePackUnpack PathMappingGenerator\n";
    fs << "# Total entries: " << serializableEntries.size() << "\n";
    fs << "# Unique CRC32: " << m_mapping.size() << "\n";
    fs << "# Collisions: " << m_stats.collisions << "\n";
    fs << "# Collision groups: " << collisionGroups << "\n";
    fs << "# Collision entries: " << collisionEntries << "\n";
    fs << "# Max collision group size: " << maxCollisionGroup << "\n";
    fs << "#\n";

    if (useHex) {
        fs << "# Format: 0xCRC32<TAB>RelativePath\n";
    } else {
        fs << "# Format: CRC32|RelativePath\n";
    }
    fs << "#\n";

    // 按 CRC32 排序输出（便于二分查找）
    std::vector<PathEntry> sortedEntries = serializableEntries;
    std::sort(sortedEntries.begin(), sortedEntries.end(),
              [](const PathEntry& a, const PathEntry& b) {
                  return a.crc32 < b.crc32;
              });

    for (size_t i = 0; i < sortedEntries.size(); i++) {
        const PathEntry& entry = sortedEntries[i];
        if (useHex) {
            fs << "0x" << std::hex << std::setfill('0') << std::setw(8)
               << entry.crc32 << std::dec << "\t" << entry.relativePath << "\n";
        } else {
            fs << entry.crc32 << "|" << entry.relativePath << "\n";
        }
    }

    if (!fs.good()) {
        fs.close();
        std::remove(tempPath.c_str());
        return LJFP_ERROR_FILE_WRITE_FAILED;
    }
    fs.close();
    if (!ReplaceOutputFile(tempPath, outputPath)) {
        return LJFP_ERROR_FILE_WRITE_FAILED;
    }

    if (m_stats.collisions > 0 && !m_collisionMap.empty()) {
        std::string collisionFile = outputPath + ".collisions.txt";
        std::ofstream cfs(collisionFile);
        if (cfs.is_open()) {
            cfs << "# CRC32 collision report\n";
            cfs << "# Total entries: " << serializableEntries.size() << "\n";
            cfs << "# Unique CRC32: " << m_mapping.size() << "\n";
            cfs << "# Collision groups: " << collisionGroups << "\n";
            cfs << "# Collision entries: " << collisionEntries << "\n";
            cfs << "# Max collision group size: " << maxCollisionGroup << "\n";
            cfs << "#\n";

            std::vector<std::pair<uint32_t, std::vector<std::string>>> groups;
            groups.reserve(m_collisionMap.size());
            for (auto it = m_collisionMap.begin(); it != m_collisionMap.end(); ++it) {
                groups.push_back(*it);
            }
            std::sort(groups.begin(), groups.end(),
                      [](const std::pair<uint32_t, std::vector<std::string>>& a,
                         const std::pair<uint32_t, std::vector<std::string>>& b) {
                          if (a.second.size() != b.second.size()) {
                              return a.second.size() > b.second.size();
                          }
                          return a.first < b.first;
                      });

            for (size_t idx = 0; idx < groups.size(); idx++) {
                uint32_t crc = groups[idx].first;
                const std::vector<std::string>& paths = groups[idx].second;
                cfs << "CRC32=0x" << std::hex << std::setfill('0') << std::setw(8)
                    << crc << std::dec << " (" << paths.size() << " paths)\n";
                for (size_t i = 0; i < paths.size(); i++) {
                    cfs << "  " << paths[i] << "\n";
                }
                cfs << "\n";
            }
            cfs.close();
        }
    }

    return LJFP_SUCCESS;
}

int PathMappingGenerator::SaveMappingBinary(const std::string& outputPath) {
    const std::string tempPath = BuildTempOutputPath(outputPath);
    std::ofstream fs(tempPath.c_str(), std::ios::binary | std::ios::out | std::ios::trunc);
    if (!fs.is_open()) {
        return LJFP_ERROR_FILE_CREATE_FAILED;
    }

    const std::vector<PathEntry> serializableEntries = BuildSerializableEntries();

    // 写入魔数
    fs.write(reinterpret_cast<const char*>(&BINARY_MAGIC), 4);

    // 写入版本
    fs.write(reinterpret_cast<const char*>(&BINARY_VERSION), 4);

    // 写入条目数量
    uint32_t count = static_cast<uint32_t>(serializableEntries.size());
    fs.write(reinterpret_cast<const char*>(&count), 4);

    // 写入每条记录
    for (size_t i = 0; i < serializableEntries.size(); i++) {
        const PathEntry& entry = serializableEntries[i];
        // CRC32
        fs.write(reinterpret_cast<const char*>(&entry.crc32), 4);

        // 路径长度
        uint16_t pathLen = static_cast<uint16_t>(entry.relativePath.size());
        fs.write(reinterpret_cast<const char*>(&pathLen), 2);

        // 路径字符串
        fs.write(entry.relativePath.c_str(), pathLen);
    }

    if (!fs.good()) {
        fs.close();
        std::remove(tempPath.c_str());
        return LJFP_ERROR_FILE_WRITE_FAILED;
    }
    fs.close();
    if (!ReplaceOutputFile(tempPath, outputPath)) {
        return LJFP_ERROR_FILE_WRITE_FAILED;
    }
    return LJFP_SUCCESS;
}

std::vector<PathMappingGenerator::PathEntry> PathMappingGenerator::BuildSerializableEntries() const {
    std::vector<PathEntry> serializableEntries;
    serializableEntries.reserve(m_mapping.size());

    for (std::map<uint32_t, std::string>::const_iterator it = m_mapping.begin();
         it != m_mapping.end();
         ++it) {
        serializableEntries.push_back(PathEntry(it->second, it->first, 0));
    }

    return serializableEntries;
}

// ============================================================================
// 查询方法
// ============================================================================

std::string PathMappingGenerator::FindPath(uint32_t crc32) const {
    auto it = m_mapping.find(crc32);
    if (it != m_mapping.end()) {
        return it->second;
    }
    return "";
}

std::vector<uint32_t> PathMappingGenerator::GetCollisions() const {
    std::vector<uint32_t> result;
    for (auto it = m_collisionMap.begin(); it != m_collisionMap.end(); ++it) {
        result.push_back(it->first);
    }
    return result;
}

} // namespace SLJFP

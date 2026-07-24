/**
 * @file SLJFP_Unpack.cpp
 * @brief SuperLJFilePackUnpack 核心解包类实现
 * @version 1.0
 * @date 2025-01-03
 *
 * 基于 LJFilePack 逆向功能实施方案文档第7章设计实现
 * 实现完整的资源包逆向解包功能
 */

#include "../include/SLJFP_Unpack.h"
#include "../include/SLJFP_FileTypeDetector.h"
#include "../include/SLJFP_LibsWrapper.h"
#include "SLJFP_UnpackIndexIO.h"
#include "SLJFP_UnpackSourceIO.h"

#include "../include/SLJFP_Logger.h"

#include "../include/SLJFP_ErrorCodes.h"
// Library functions are accessed via injected function pointers
// #include "../libs/ljfp/LJFP_MiniZ.h"
// #include "../libs/ljfp/LJFP_SMS4.h"
// #include "../libs/ljfp/LJFP_CRC32.h"
// #include "../libs/ljfp/LJFP_FileUtil.h"  // Not used

#include <fstream>
#include <sstream>
#include <iomanip>
#include <chrono>
#include <thread>
#include <mutex>
#include <queue>
#include <atomic>
#include <condition_variable>
#include <cctype>
#include <algorithm>  // for std::max, std::sort
#include <numeric>    // for std::iota
#include <set>
#include <cstring>
#include <cstdio>
#include <cstdlib>
#include <cerrno>
#include <climits>
#ifndef _WIN32
#include <sys/stat.h>
#include <sys/types.h>
#endif

#define MINIZ_HEADER_FILE_ONLY
#include "../libs/ljfp/LJFP_MiniZ.h"
#undef MINIZ_HEADER_FILE_ONLY

#ifdef _WIN32
#define NOMINMAX  // 防止 windows.h 的 min/max 宏与 std::min/max 冲突
#include <windows.h>  // for CreateDirectoryA
#endif

namespace SLJFP {

#ifdef _WIN32
namespace {

std::wstring MultiByteToWideBestEffort(const std::string& value) {
    if (value.empty()) {
        return std::wstring();
    }

    UINT codePage = CP_UTF8;
    DWORD flags = MB_ERR_INVALID_CHARS;
    int required = MultiByteToWideChar(codePage, flags, value.c_str(), -1, NULL, 0);

    if (required <= 0) {
        codePage = CP_ACP;
        flags = 0;
        required = MultiByteToWideChar(codePage, flags, value.c_str(), -1, NULL, 0);
        if (required <= 0) {
            return std::wstring();
        }
    }

    std::wstring wide(required, L'\0');
    if (MultiByteToWideChar(codePage, flags, value.c_str(), -1, &wide[0], required) <= 0) {
        return std::wstring();
    }

    if (!wide.empty() && wide.back() == L'\0') {
        wide.pop_back();
    }
    return wide;
}

std::string WideToMultiByteBestEffort(const std::wstring& value) {
    if (value.empty()) {
        return std::string();
    }

    UINT codePage = CP_UTF8;
    int required = WideCharToMultiByte(codePage, 0, value.c_str(), -1, NULL, 0, NULL, NULL);
    if (required <= 0) {
        codePage = CP_ACP;
        required = WideCharToMultiByte(codePage, 0, value.c_str(), -1, NULL, 0, NULL, NULL);
        if (required <= 0) {
            return std::string();
        }
    }

    std::string text(required, '\0');
    if (WideCharToMultiByte(codePage, 0, value.c_str(), -1, &text[0], required, NULL, NULL) <= 0) {
        return std::string();
    }

    if (!text.empty() && text.back() == '\0') {
        text.pop_back();
    }
    return text;
}

bool OpenBinaryOutputFile(std::ofstream& stream, const std::string& path) {
    std::wstring widePath = MultiByteToWideBestEffort(path);
    if (!widePath.empty()) {
        stream.open(widePath.c_str(), std::ios::binary | std::ios::out | std::ios::trunc);
        if (stream.is_open()) {
            return true;
        }
    }

    stream.open(path.c_str(), std::ios::binary | std::ios::out | std::ios::trunc);
    return stream.is_open();
}

#ifndef _WIN32
bool CreatePosixDirectoryIfMissing(const std::string& path) {
    if (path.empty()) {
        return true;
    }

    if (::mkdir(path.c_str(), 0777) == 0) {
        return true;
    }

    if (errno == EEXIST) {
        struct stat st;
        return ::stat(path.c_str(), &st) == 0 && S_ISDIR(st.st_mode);
    }

    return false;
}
#endif

std::string NormalizeSlashesCopy(const std::string& path) {
    std::string text = path;
    for (size_t i = 0; i < text.size(); ++i) {
        if (text[i] == '\\') {
            text[i] = '/';
        }
    }
    return text;
}

std::string ToLowerCopy(const std::string& value) {
    std::string text = value;
    for (size_t i = 0; i < text.size(); ++i) {
        text[i] = static_cast<char>(std::tolower(static_cast<unsigned char>(text[i])));
    }
    return text;
}

bool StartsWith(const std::string& text, const std::string& prefix) {
    return text.size() >= prefix.size() &&
           std::equal(prefix.begin(), prefix.end(), text.begin());
}

bool EndsWith(const std::string& text, const std::string& suffix) {
    return text.size() >= suffix.size() &&
           std::equal(suffix.rbegin(), suffix.rend(), text.rbegin());
}

std::string GetDirectoryName(const std::string& path) {
    size_t pos = path.find_last_of("/\\");
    if (pos == std::string::npos) {
        return std::string();
    }
    return path.substr(0, pos);
}

std::string GetFileName(const std::string& path) {
    size_t pos = path.find_last_of("/\\");
    if (pos == std::string::npos) {
        return path;
    }
    return path.substr(pos + 1);
}

std::string GetExtensionLower(const std::string& path) {
    size_t pos = path.find_last_of('.');
    if (pos == std::string::npos) {
        return std::string();
    }
    return ToLowerCopy(path.substr(pos));
}

std::string RemoveExtension(const std::string& path) {
    size_t slash = path.find_last_of("/\\");
    size_t dot = path.find_last_of('.');
    if (dot == std::string::npos || (slash != std::string::npos && dot < slash)) {
        return path;
    }
    return path.substr(0, dot);
}

std::string JoinPath(const std::string& left, const std::string& right) {
    if (left.empty()) {
        return NormalizeSlashesCopy(right);
    }
    if (right.empty()) {
        return NormalizeSlashesCopy(left);
    }

    std::string result = NormalizeSlashesCopy(left);
    if (!result.empty() && result.back() != '/') {
        result += '/';
    }
    result += NormalizeSlashesCopy(right);
    return result;
}

bool IsAbsoluteLikePath(const std::string& path) {
    const std::string normalized = NormalizeSlashesCopy(path);
    return (!normalized.empty() && normalized[0] == '/') ||
           StartsWith(normalized, "//") ||
           (normalized.size() >= 2 &&
            std::isalpha(static_cast<unsigned char>(normalized[0])) &&
            normalized[1] == ':');
}

bool IsWindowsReservedBaseName(const std::string& segment) {
    if (segment.empty()) {
        return false;
    }

    std::string base = ToLowerCopy(segment);
    const size_t dotPos = base.find('.');
    if (dotPos != std::string::npos) {
        base = base.substr(0, dotPos);
    }

    static const char* kReservedNames[] = {
        "con", "prn", "aux", "nul",
        "com1", "com2", "com3", "com4", "com5", "com6", "com7", "com8", "com9",
        "lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9"
    };

    for (size_t i = 0; i < sizeof(kReservedNames) / sizeof(kReservedNames[0]); ++i) {
        if (base == kReservedNames[i]) {
            return true;
        }
    }
    return false;
}

std::string SanitizeWindowsPathSegment(const std::string& segment, bool& changed) {
    std::string sanitized;
    sanitized.reserve(segment.size());

    for (size_t i = 0; i < segment.size(); ++i) {
        const unsigned char c = static_cast<unsigned char>(segment[i]);
        if (c < 32 || c == '<' || c == '>' || c == ':' || c == '"' ||
            c == '|' || c == '?' || c == '*' || c == '/' || c == '\\') {
            sanitized.push_back('_');
            changed = true;
        } else {
            sanitized.push_back(static_cast<char>(c));
        }
    }

    while (!sanitized.empty() && (sanitized.back() == ' ' || sanitized.back() == '.')) {
        sanitized.pop_back();
        changed = true;
    }

    if (sanitized.empty()) {
        sanitized = "_";
        changed = true;
    }

    if (IsWindowsReservedBaseName(sanitized)) {
        sanitized += "_";
        changed = true;
    }

    return sanitized;
}

bool StripKnownResourceRootPrefixes(std::string& normalizedPath) {
    static const char* const kPrefixes[] = {
        "client/resource/res/",
        "resource/res/",
        "assets/res/",
        "res/",
        "assets/",
        "resource/",
        "client/resource/"
    };

    const std::string lowerPath = ToLowerCopy(normalizedPath);
    for (size_t i = 0; i < sizeof(kPrefixes) / sizeof(kPrefixes[0]); ++i) {
        const std::string prefix = kPrefixes[i];
        if (lowerPath.size() > prefix.size() &&
            lowerPath.compare(0, prefix.size(), prefix) == 0) {
            normalizedPath = normalizedPath.substr(prefix.size());
            return true;
        }
    }
    return false;
}

std::string NormalizeOutputRelativePath(const std::string& rawPath, bool* changedOut = NULL) {
    bool changed = false;
    std::string normalized = NormalizeSlashesCopy(rawPath);

    if (normalized.size() >= 2 &&
        std::isalpha(static_cast<unsigned char>(normalized[0])) &&
        normalized[1] == ':') {
        normalized = normalized.substr(2);
        changed = true;
    }

    while (!normalized.empty() && normalized[0] == '/') {
        normalized.erase(normalized.begin());
        changed = true;
    }

    std::vector<std::string> segments;
    size_t begin = 0;
    while (begin <= normalized.size()) {
        const size_t slashPos = normalized.find('/', begin);
        const std::string token = (slashPos == std::string::npos)
            ? normalized.substr(begin)
            : normalized.substr(begin, slashPos - begin);

        if (token.empty() || token == ".") {
            if (!token.empty()) {
                changed = true;
            }
        } else if (token == "..") {
            changed = true;
            if (!segments.empty()) {
                segments.pop_back();
            }
        } else {
            segments.push_back(SanitizeWindowsPathSegment(token, changed));
        }

        if (slashPos == std::string::npos) {
            break;
        }
        begin = slashPos + 1;
    }

    std::ostringstream oss;
    for (size_t i = 0; i < segments.size(); ++i) {
        if (i > 0) {
            oss << '/';
        }
        oss << segments[i];
    }

    normalized = oss.str();
    if (StripKnownResourceRootPrefixes(normalized)) {
        changed = true;
    }

    if (changedOut != NULL) {
        *changedOut = changed || IsAbsoluteLikePath(rawPath);
    }
    return normalized;
}

std::string BuildOutputReservationKey(const std::string& path) {
    return ToLowerCopy(NormalizeSlashesCopy(path));
}

std::string MakeRelativeToRoot(const std::string& rootPath, const std::string& fullPath) {
    std::string normalizedRoot = NormalizeSlashesCopy(rootPath);
    std::string normalizedFull = NormalizeSlashesCopy(fullPath);

    while (!normalizedRoot.empty() && normalizedRoot.back() == '/') {
        normalizedRoot.pop_back();
    }

    const std::string lowerRoot = ToLowerCopy(normalizedRoot);
    const std::string lowerFull = ToLowerCopy(normalizedFull);
    if (!lowerRoot.empty() &&
        StartsWith(lowerFull, lowerRoot) &&
        (lowerFull.size() == lowerRoot.size() || lowerFull[lowerRoot.size()] == '/')) {
        std::string relative = normalizedFull.substr(normalizedRoot.size());
        while (!relative.empty() && relative[0] == '/') {
            relative.erase(relative.begin());
        }
        return relative;
    }
    return normalizedFull;
}

std::string EscapeTsvField(const std::string& value) {
    std::string escaped;
    escaped.reserve(value.size());
    for (size_t i = 0; i < value.size(); ++i) {
        const char c = value[i];
        switch (c) {
            case '\t':
                escaped += "\\t";
                break;
            case '\r':
                escaped += "\\r";
                break;
            case '\n':
                escaped += "\\n";
                break;
            default:
                escaped.push_back(c);
                break;
        }
    }
    return escaped;
}

std::string EscapeJsonString(const std::string& value) {
    std::ostringstream oss;
    for (size_t i = 0; i < value.size(); ++i) {
        const unsigned char c = static_cast<unsigned char>(value[i]);
        switch (c) {
            case '\"':
                oss << "\\\"";
                break;
            case '\\':
                oss << "\\\\";
                break;
            case '\b':
                oss << "\\b";
                break;
            case '\f':
                oss << "\\f";
                break;
            case '\n':
                oss << "\\n";
                break;
            case '\r':
                oss << "\\r";
                break;
            case '\t':
                oss << "\\t";
                break;
            default:
                if (c < 0x20) {
                    oss << "\\u00"
                        << std::uppercase << std::hex << std::setw(2) << std::setfill('0')
                        << static_cast<unsigned int>(c)
                        << std::nouppercase << std::dec;
                } else {
                    oss << static_cast<char>(c);
                }
                break;
        }
    }
    return oss.str();
}

std::string FormatHexCrc32(uint32_t value) {
    std::ostringstream oss;
    oss << "0x" << std::uppercase << std::hex << std::setw(8)
        << std::setfill('0') << value;
    return oss.str();
}

std::string JoinFlagsCsv(const std::vector<std::string>& flags) {
    std::string text;
    for (size_t i = 0; i < flags.size(); ++i) {
        if (!text.empty()) {
            text += ",";
        }
        text += flags[i];
    }
    return text;
}

std::string FormatHexPrefix(const unsigned char* data, size_t size, size_t maxBytes) {
    if (data == NULL || size == 0 || maxBytes == 0) {
        return std::string();
    }

    const size_t count = std::min(size, maxBytes);
    std::ostringstream oss;
    for (size_t i = 0; i < count; ++i) {
        if (i > 0) {
            oss << ' ';
        }
        oss << std::uppercase << std::hex << std::setw(2) << std::setfill('0')
            << static_cast<unsigned int>(data[i]);
    }
    if (count < size) {
        oss << " ...";
    }
    return oss.str();
}

const wchar_t* DecryptModeToWideText(DecryptMode mode) {
    switch (mode) {
        case DecryptMode::LJFilePackSMS4:
            return L"LJFilePackSMS4";
        case DecryptMode::ApkClientObf:
            return L"ApkClientObf";
        case DecryptMode::Auto:
        default:
            return L"Auto";
    }
}

const wchar_t* ZlibResultToWideText(int result) {
    switch (result) {
        case 0:
            return L"Z_OK";
        case -1:
            return L"Z_ERRNO";
        case -2:
            return L"Z_STREAM_ERROR";
        case -3:
            return L"Z_DATA_ERROR";
        case -4:
            return L"Z_MEM_ERROR";
        case -5:
            return L"Z_BUF_ERROR";
        case -6:
            return L"Z_VERSION_ERROR";
        default:
            return L"Z_UNKNOWN";
    }
}

const uint32_t kDefaultDecryptWindowBytes = 1024u;
const uint32_t kFullDecryptWindowBytes = 0xFFFFFFFFu;

struct DecryptCandidateSpec {
    std::string candidateId;
    DecryptMode mode;
    bool applyDecrypt;
    bool useFullWindow;

    DecryptCandidateSpec()
        : mode(DecryptMode::Auto)
        , applyDecrypt(false)
        , useFullWindow(false) {}
};

void PushUniqueDecryptCandidate(std::vector<DecryptCandidateSpec>& specs,
                                const std::string& candidateId,
                                DecryptMode mode,
                                bool applyDecrypt,
                                bool useFullWindow) {
    for (size_t i = 0; i < specs.size(); ++i) {
        if (specs[i].candidateId == candidateId) {
            return;
        }
    }

    DecryptCandidateSpec spec;
    spec.candidateId = candidateId;
    spec.mode = mode;
    spec.applyDecrypt = applyDecrypt;
    spec.useFullWindow = useFullWindow;
    specs.push_back(spec);
}

bool LooksLikeZlibHeader(const unsigned char* data, size_t size) {
    if (data == NULL || size < 2) {
        return false;
    }

    const unsigned int cmf = data[0];
    const unsigned int flg = data[1];
    if ((cmf & 0x0Fu) != 8u) {
        return false;
    }
    if (((cmf << 8) + flg) % 31u != 0u) {
        return false;
    }
    return true;
}

bool LooksLikePngSignature(const unsigned char* data, size_t size) {
    if (data == NULL || size < 8) {
        return false;
    }

    static const unsigned char kPngMagic[8] = {
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
    };
    return std::memcmp(data, kPngMagic, sizeof(kPngMagic)) == 0;
}

bool LooksLikeUtf8Xml(const unsigned char* data, size_t size) {
    if (data == NULL || size == 0) {
        return false;
    }

    size_t pos = 0;
    if (size >= 3 && data[0] == 0xEF && data[1] == 0xBB && data[2] == 0xBF) {
        pos = 3;
    }
    while (pos < size && std::isspace(static_cast<unsigned char>(data[pos])) != 0) {
        ++pos;
    }
    return pos < size && data[pos] == '<';
}

bool LooksLikeUtf16LeXml(const unsigned char* data, size_t size) {
    if (data == NULL || size < 4) {
        return false;
    }

    size_t pos = 0;
    if (size >= 2 && data[0] == 0xFF && data[1] == 0xFE) {
        pos = 2;
    }
    while (pos + 1 < size &&
           (data[pos] == ' ' || data[pos] == '\t' || data[pos] == '\r' || data[pos] == '\n') &&
           data[pos + 1] == 0x00) {
        pos += 2;
    }
    return pos + 1 < size && data[pos] == '<' && data[pos + 1] == 0x00;
}

bool LooksLikeUtf8Json(const unsigned char* data, size_t size) {
    if (data == NULL || size == 0) {
        return false;
    }
    size_t pos = 0;
    if (size >= 3 && data[0] == 0xEF && data[1] == 0xBB && data[2] == 0xBF) {
        pos = 3;
    }
    while (pos < size && std::isspace(static_cast<unsigned char>(data[pos])) != 0) {
        ++pos;
    }
    return pos < size && (data[pos] == '{' || data[pos] == '[');
}

bool LooksMostlyPrintableAscii(const unsigned char* data, size_t size) {
    if (data == NULL || size == 0) {
        return false;
    }

    const size_t limit = std::min<size_t>(size, 128u);
    size_t printableCount = 0;
    for (size_t i = 0; i < limit; ++i) {
        const unsigned char c = data[i];
        if (c == '\r' || c == '\n' || c == '\t' || (c >= 32 && c <= 126)) {
            ++printableCount;
        }
    }

    return printableCount * 100u >= limit * 85u;
}

std::string JoinTags(const std::vector<std::string>& tags) {
    if (tags.empty()) {
        return std::string("binary");
    }

    std::ostringstream oss;
    for (size_t i = 0; i < tags.size(); ++i) {
        if (i > 0) {
            oss << '+';
        }
        oss << tags[i];
    }
    return oss.str();
}

std::string DescribeBufferSignature(const unsigned char* data, size_t size) {
    if (data == NULL || size == 0) {
        return std::string("empty");
    }

    std::vector<std::string> tags;
    if (LooksLikeZlibHeader(data, size)) {
        tags.push_back("zlib");
    }
    if (LooksLikePngSignature(data, size)) {
        tags.push_back("png");
    }
    if (LooksLikeUtf16LeXml(data, size)) {
        tags.push_back("utf16le-xml");
    } else if (LooksLikeUtf8Xml(data, size)) {
        tags.push_back("xml");
    } else if (LooksLikeUtf8Json(data, size)) {
        tags.push_back("json");
    }
    if (LooksMostlyPrintableAscii(data, size)) {
        tags.push_back("text");
    }
    return JoinTags(tags);
}

std::wstring ProbeRecordToWideSummary(const DecryptProbeRecord& record) {
    std::wostringstream oss;
    oss << L"id=" << MultiByteToWideBestEffort(record.candidateId)
        << L", mode=" << DecryptModeToWideText(record.mode)
        << L", decrypt=" << (record.applyDecrypt ? 1 : 0)
        << L", window=" << (record.useFullWindow ? L"all" : L"1024")
        << L", error=" << record.errorCode
        << L", unzip=" << record.unzipResult
        << L", crcChecked=" << (record.crcChecked ? 1 : 0)
        << L", crcMatched=" << (record.crcMatched ? 1 : 0)
        << L", selected=" << (record.selected ? 1 : 0)
        << L", transformed=" << MultiByteToWideBestEffort(record.transformedSignature)
        << L", output=" << MultiByteToWideBestEffort(record.outputSignature);
    return oss.str();
}

void BuildDecryptProbeCandidates(const unsigned char* inputData,
                                 uint32_t inputSize,
                                 bool needDecrypt,
                                 bool needDecompress,
                                 const UnpackOptions& options,
                                 std::vector<DecryptCandidateSpec>& outSpecs) {
    outSpecs.clear();

    if (!needDecrypt) {
        PushUniqueDecryptCandidate(outSpecs, "passthrough", DecryptMode::Auto, false, false);
        return;
    }

    const bool inputLooksZlib = needDecompress && LooksLikeZlibHeader(inputData, inputSize);
    const bool tryFullWindow = inputSize > kDefaultDecryptWindowBytes;

    switch (options.decryptMode) {
        case DecryptMode::LJFilePackSMS4:
            PushUniqueDecryptCandidate(outSpecs, "legacy-window1024", DecryptMode::LJFilePackSMS4, true, false);
            break;
        case DecryptMode::ApkClientObf:
            PushUniqueDecryptCandidate(outSpecs, "clientobf-window1024", DecryptMode::ApkClientObf, true, false);
            break;
        case DecryptMode::Auto:
        default:
            if (inputLooksZlib) {
                PushUniqueDecryptCandidate(outSpecs, "passthrough", DecryptMode::Auto, false, false);
            }

            PushUniqueDecryptCandidate(outSpecs, "legacy-window1024", DecryptMode::LJFilePackSMS4, true, false);
            PushUniqueDecryptCandidate(outSpecs, "clientobf-window1024", DecryptMode::ApkClientObf, true, false);
            PushUniqueDecryptCandidate(outSpecs, "clientkeyed-window1024", DecryptMode::ApkClientObf, true, false);

            if (tryFullWindow) {
                PushUniqueDecryptCandidate(outSpecs, "legacy-full", DecryptMode::LJFilePackSMS4, true, true);
                PushUniqueDecryptCandidate(outSpecs, "clientobf-full", DecryptMode::ApkClientObf, true, true);
                PushUniqueDecryptCandidate(outSpecs, "clientkeyed-full", DecryptMode::ApkClientObf, true, true);
            }

            PushUniqueDecryptCandidate(outSpecs, "passthrough", DecryptMode::Auto, false, false);
            break;
    }
}

bool IsDigitsOnly(const std::string& value) {
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

bool ReadFileBytes(const std::string& path, std::vector<unsigned char>& data) {
    std::ifstream file(path.c_str(), std::ios::binary | std::ios::ate);
    if (!file.is_open()) {
        return false;
    }

    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);
    if (size < 0) {
        return false;
    }

    data.resize(static_cast<size_t>(size));
    if (size == 0) {
        return true;
    }
    return file.read(reinterpret_cast<char*>(&data[0]), size).good();
}

bool ReadFilePrefixBytes(const std::string& path, size_t maxBytes, std::vector<unsigned char>& data) {
    data.clear();

    std::ifstream file(path.c_str(), std::ios::binary);
    if (!file.is_open()) {
        return false;
    }

    if (maxBytes == 0) {
        return true;
    }

    data.resize(maxBytes);
    file.read(reinterpret_cast<char*>(&data[0]), static_cast<std::streamsize>(maxBytes));
    const std::streamsize readSize = file.gcount();
    if (readSize < 0) {
        data.clear();
        return false;
    }

    data.resize(static_cast<size_t>(readSize));
    return !data.empty() || file.good() || file.eof();
}

uint64_t GetFileSizePath(const std::string& path) {
    std::ifstream file(path.c_str(), std::ios::binary | std::ios::ate);
    if (!file.is_open()) {
        return 0;
    }

    const std::streamoff size = file.tellg();
    return (size < 0) ? 0 : static_cast<uint64_t>(size);
}

std::string DetectPhysicalFileExtension(const std::string& path) {
    std::vector<unsigned char> prefixBytes;
    if (!ReadFilePrefixBytes(path, 4096, prefixBytes) || prefixBytes.empty()) {
        return std::string();
    }

    return FileTypeDetector::DetectExtension(prefixBytes.data(), prefixBytes.size());
}

bool WriteFileBytes(const std::string& path, const std::vector<unsigned char>& data) {
    std::ofstream file(path.c_str(), std::ios::binary | std::ios::trunc);
    if (!file.is_open()) {
        return false;
    }
    if (!data.empty()) {
        file.write(reinterpret_cast<const char*>(&data[0]), static_cast<std::streamsize>(data.size()));
    }
    return file.good();
}

bool FileExistsPath(const std::string& path) {
    std::wstring wide = MultiByteToWideBestEffort(path);
    if (wide.empty()) {
        return false;
    }
    DWORD attrs = GetFileAttributesW(wide.c_str());
    return attrs != INVALID_FILE_ATTRIBUTES && !(attrs & FILE_ATTRIBUTE_DIRECTORY);
}

bool DeleteFilePath(const std::string& path) {
    std::wstring wide = MultiByteToWideBestEffort(path);
    if (wide.empty()) {
        return false;
    }
    return DeleteFileW(wide.c_str()) != 0;
}

bool MoveFileReplacePath(const std::string& src, const std::string& dst) {
    std::wstring wideSrc = MultiByteToWideBestEffort(src);
    std::wstring wideDst = MultiByteToWideBestEffort(dst);
    if (wideSrc.empty() || wideDst.empty()) {
        return false;
    }
    return MoveFileExW(wideSrc.c_str(), wideDst.c_str(),
                       MOVEFILE_COPY_ALLOWED | MOVEFILE_REPLACE_EXISTING) != 0;
}

bool CopyFileReplacePath(const std::string& src, const std::string& dst) {
    std::wstring wideSrc = MultiByteToWideBestEffort(src);
    std::wstring wideDst = MultiByteToWideBestEffort(dst);
    if (wideSrc.empty() || wideDst.empty()) {
        return false;
    }
    return CopyFileW(wideSrc.c_str(), wideDst.c_str(), FALSE) != 0;
}

void CollectFilesRecursiveImpl(const std::wstring& root,
                               const std::wstring& current,
                               std::vector<std::string>& outFiles) {
    std::wstring searchPath = current;
    if (!searchPath.empty() && searchPath.back() != L'\\' && searchPath.back() != L'/') {
        searchPath += L'\\';
    }
    searchPath += L"*";

    WIN32_FIND_DATAW findData;
    HANDLE handle = FindFirstFileW(searchPath.c_str(), &findData);
    if (handle == INVALID_HANDLE_VALUE) {
        return;
    }

    do {
        std::wstring name = findData.cFileName;
        if (name == L"." || name == L"..") {
            continue;
        }

        std::wstring fullPath = current;
        if (!fullPath.empty() && fullPath.back() != L'\\' && fullPath.back() != L'/') {
            fullPath += L'\\';
        }
        fullPath += name;

        if ((findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0) {
            CollectFilesRecursiveImpl(root, fullPath, outFiles);
            continue;
        }

        std::wstring relative = fullPath.substr(root.size());
        while (!relative.empty() && (relative[0] == L'\\' || relative[0] == L'/')) {
            relative.erase(relative.begin());
        }
        std::string rel = NormalizeSlashesCopy(WideToMultiByteBestEffort(relative));
        if (!rel.empty()) {
            outFiles.push_back(rel);
        }
    } while (FindNextFileW(handle, &findData) != 0);

    FindClose(handle);
}

void CollectFilesRecursive(const std::string& rootDir, std::vector<std::string>& outFiles) {
    outFiles.clear();
    std::wstring root = MultiByteToWideBestEffort(rootDir);
    if (root.empty()) {
        return;
    }
    for (size_t i = 0; i < root.size(); ++i) {
        if (root[i] == L'/') {
            root[i] = L'\\';
        }
    }
    CollectFilesRecursiveImpl(root, root, outFiles);
}

void PushUnique(std::vector<std::string>& values, const std::string& value) {
    if (value.empty()) {
        return;
    }
    if (std::find(values.begin(), values.end(), value) == values.end()) {
        values.push_back(value);
    }
}

void PushUniqueSet(std::set<std::string>& values, const std::string& value) {
    if (!value.empty()) {
        values.insert(value);
    }
}

std::string TrimPunctuation(const std::string& token) {
    if (token.empty()) {
        return token;
    }

    size_t begin = 0;
    size_t end = token.size();
    while (begin < end) {
        unsigned char c = static_cast<unsigned char>(token[begin]);
        if (std::isalnum(c) || c == '_' || c == '-' || c == '+' || c == '"' ||
            c == '/' || c == '\\' || c == '.') {
            break;
        }
        ++begin;
    }
    while (end > begin) {
        unsigned char c = static_cast<unsigned char>(token[end - 1]);
        if (std::isalnum(c) || c == '_' || c == '-' || c == '+' || c == '"' ||
            c == '/' || c == '\\' || c == '.') {
            break;
        }
        --end;
    }
    return token.substr(begin, end - begin);
}

void ExtractPrintableAsciiTokens(const std::vector<unsigned char>& data,
                                 std::vector<std::string>& outTokens) {
    std::string current;
    for (size_t i = 0; i < data.size(); ++i) {
        unsigned char c = data[i];
        if (c >= 32 && c <= 126) {
            current.push_back(static_cast<char>(c));
            continue;
        }
        if (current.size() >= 3) {
            PushUnique(outTokens, TrimPunctuation(current));
        }
        current.clear();
    }
    if (current.size() >= 3) {
        PushUnique(outTokens, TrimPunctuation(current));
    }
}

void ExtractPrintableUtf16Tokens(const std::vector<unsigned char>& data,
                                 std::vector<std::string>& outTokens) {
    std::string current;
    for (size_t i = 0; i + 1 < data.size(); i += 2) {
        unsigned short wc = static_cast<unsigned short>(data[i] | (data[i + 1] << 8));
        if (wc >= 32 && wc <= 126) {
            current.push_back(static_cast<char>(wc));
            continue;
        }
        if (current.size() >= 3) {
            PushUnique(outTokens, TrimPunctuation(current));
        }
        current.clear();
    }
    if (current.size() >= 3) {
        PushUnique(outTokens, TrimPunctuation(current));
    }
}

std::vector<std::string> ExtractContentTokens(const std::vector<unsigned char>& data) {
    std::vector<std::string> tokens;
    ExtractPrintableAsciiTokens(data, tokens);
    ExtractPrintableUtf16Tokens(data, tokens);

    std::vector<std::string> filtered;
    for (size_t i = 0; i < tokens.size(); ++i) {
        std::string token = NormalizeSlashesCopy(tokens[i]);
        if (token.empty()) {
            continue;
        }
        PushUnique(filtered, token);
    }
    return filtered;
}

std::string ExtractQuotedValue(const std::string& text, size_t startPos) {
    if (startPos >= text.size()) {
        return std::string();
    }
    size_t begin = text.find('"', startPos);
    if (begin == std::string::npos) {
        return std::string();
    }
    size_t end = text.find('"', begin + 1);
    if (end == std::string::npos || end <= begin + 1) {
        return std::string();
    }
    return text.substr(begin + 1, end - begin - 1);
}

void ExtractAttrValues(const std::string& text,
                       const std::string& marker,
                       std::vector<std::string>& outValues) {
    size_t pos = 0;
    for (;;) {
        pos = text.find(marker, pos);
        if (pos == std::string::npos) {
            break;
        }
        std::string value = ExtractQuotedValue(text, pos + marker.size() - 1);
        if (!value.empty()) {
            PushUnique(outValues, value);
        }
        pos += marker.size();
    }
}

void ExtractQuotedStrings(const std::string& text,
                          std::vector<std::string>& outValues) {
    size_t pos = 0;
    while (pos < text.size()) {
        size_t begin = text.find('"', pos);
        if (begin == std::string::npos) {
            break;
        }
        size_t end = text.find('"', begin + 1);
        if (end == std::string::npos) {
            break;
        }
        if (end > begin + 1) {
            PushUnique(outValues, text.substr(begin + 1, end - begin - 1));
        }
        pos = end + 1;
    }
}

void ExtractQuotedCallArgs(const std::string& text,
                           const std::string& marker,
                           std::vector<std::string>& outValues) {
    size_t pos = 0;
    for (;;) {
        pos = text.find(marker, pos);
        if (pos == std::string::npos) {
            break;
        }
        std::string value = ExtractQuotedValue(text, pos + marker.size() - 1);
        if (!value.empty()) {
            PushUnique(outValues, value);
        }
        pos += marker.size();
    }
}

void ExtractLuaModuleRefs(const std::string& text,
                          std::vector<std::string>& outValues) {
    const char* kMarkers[] = {
        "require",
        "debugrequire",
        "module"
    };

    for (size_t markerIndex = 0;
         markerIndex < sizeof(kMarkers) / sizeof(kMarkers[0]);
         ++markerIndex) {
        const std::string marker = kMarkers[markerIndex];
        size_t pos = 0;
        for (;;) {
            pos = text.find(marker, pos);
            if (pos == std::string::npos) {
                break;
            }

            if (pos > 0) {
                const unsigned char prev =
                    static_cast<unsigned char>(text[pos - 1]);
                if (std::isalnum(prev) || prev == '_') {
                    pos += marker.size();
                    continue;
                }
            }

            size_t cursor = pos + marker.size();
            while (cursor < text.size() &&
                   std::isspace(static_cast<unsigned char>(text[cursor]))) {
                ++cursor;
            }
            if (cursor < text.size() && text[cursor] == '(') {
                ++cursor;
                while (cursor < text.size() &&
                       std::isspace(static_cast<unsigned char>(text[cursor]))) {
                    ++cursor;
                }
            }
            if (cursor >= text.size()) {
                break;
            }

            const char quote = text[cursor];
            if (quote != '"' && quote != '\'') {
                pos += marker.size();
                continue;
            }

            const size_t end = text.find(quote, cursor + 1);
            if (end == std::string::npos || end <= cursor + 1) {
                pos = cursor + 1;
                continue;
            }

            PushUnique(outValues, text.substr(cursor + 1, end - cursor - 1));
            pos = end + 1;
        }
    }
}

std::string LuaModuleRefToScriptPath(const std::string& moduleRef) {
    if (moduleRef.empty()) {
        return std::string();
    }

    std::string normalized = NormalizeSlashesCopy(moduleRef);
    if (EndsWith(ToLowerCopy(normalized), ".lua")) {
        normalized = RemoveExtension(normalized);
    }

    const std::string lower = ToLowerCopy(normalized);
    if (StartsWith(lower, "script/")) {
        normalized = normalized.substr(std::string("script/").size());
    } else if (StartsWith(lower, "script.")) {
        normalized = normalized.substr(std::string("script.").size());
    }

    for (size_t i = 0; i < normalized.size(); ++i) {
        char& c = normalized[i];
        if (c == '.' || c == '\\') {
            c = '/';
            continue;
        }
        const unsigned char uc = static_cast<unsigned char>(c);
        if (!(std::isalnum(uc) || c == '_' || c == '-' || c == '/')) {
            return std::string();
        }
    }

    if (normalized.empty() ||
        normalized[0] == '/' ||
        normalized.find("//") != std::string::npos) {
        return std::string();
    }
    return NormalizeOutputRelativePath("script/" + normalized + ".lua");
}

void ExtractUiLayoutNameHints(const std::vector<std::string>& tokens,
                              std::vector<std::string>& outValues) {
    bool hasLayoutTag = false;
    for (size_t i = 0; i < tokens.size(); ++i) {
        const std::string tokenLower = ToLowerCopy(tokens[i]);
        if (tokenLower.find("guilayout") != std::string::npos) {
            hasLayoutTag = true;
        }

        std::vector<std::string> attrValues;
        ExtractAttrValues(tokens[i], "Name=\"", attrValues);
        ExtractAttrValues(tokens[i], "name=\"", attrValues);
        for (size_t valueIndex = 0; valueIndex < attrValues.size(); ++valueIndex) {
            const std::string normalized = NormalizeSlashesCopy(attrValues[valueIndex]);
            if (normalized.empty()) {
                continue;
            }

            const size_t slashPos = normalized.find('/');
            if (slashPos == std::string::npos) {
                PushUnique(outValues, normalized);
                continue;
            }

            const std::string first = normalized.substr(0, slashPos);
            const std::string last = GetFileName(normalized);
            if (!first.empty()) {
                PushUnique(outValues, first);
            }
            if (!last.empty()) {
                PushUnique(outValues, last);
            }
            if (!first.empty() && !last.empty()) {
                PushUnique(outValues, first + last);
                PushUnique(outValues, first + "_" + last);
            }
        }
    }

    if (!hasLayoutTag) {
        outValues.clear();
    }
}

std::string ExtractXmlTagAttributeValueNoCase(const std::string& text,
                                              const std::string& tagName,
                                              const std::string& attrName) {
    if (text.empty() || tagName.empty() || attrName.empty()) {
        return std::string();
    }

    const std::string lowerText = ToLowerCopy(text);
    const std::string tagMarker = "<" + ToLowerCopy(tagName);
    const std::string attrMarker = ToLowerCopy(attrName);
    size_t tagPos = lowerText.find(tagMarker);
    while (tagPos != std::string::npos) {
        const size_t tagEnd = lowerText.find('>', tagPos + tagMarker.size());
        if (tagEnd == std::string::npos) {
            break;
        }

        size_t attrPos = lowerText.find(attrMarker, tagPos + tagMarker.size());
        while (attrPos != std::string::npos && attrPos < tagEnd) {
            size_t cursor = attrPos + attrMarker.size();
            while (cursor < text.size() &&
                   std::isspace(static_cast<unsigned char>(text[cursor]))) {
                ++cursor;
            }
            if (cursor >= text.size() || text[cursor] != '=') {
                attrPos = lowerText.find(attrMarker, attrPos + attrMarker.size());
                continue;
            }

            ++cursor;
            while (cursor < text.size() &&
                   std::isspace(static_cast<unsigned char>(text[cursor]))) {
                ++cursor;
            }
            if (cursor >= text.size()) {
                break;
            }

            const char quote = text[cursor];
            if (quote != '"' && quote != '\'') {
                attrPos = lowerText.find(attrMarker, attrPos + attrMarker.size());
                continue;
            }

            const size_t valueEnd = text.find(quote, cursor + 1);
            if (valueEnd == std::string::npos || valueEnd <= cursor + 1) {
                break;
            }
            return text.substr(cursor + 1, valueEnd - cursor - 1);
        }

        tagPos = lowerText.find(tagMarker, tagEnd + 1);
    }

    return std::string();
}

std::string ExtractResourceStemCandidate(const std::string& value) {
    if (value.empty()) {
        return std::string();
    }

    std::string normalized = NormalizeSlashesCopy(value);
    normalized = GetFileName(normalized);
    normalized = RemoveExtension(normalized);
    return normalized;
}

void ExtractUiLayoutPrimaryNameHintsFromText(const std::string& text,
                                             std::vector<std::string>& outValues) {
    if (text.empty() || ToLowerCopy(text).find("<guilayout") == std::string::npos) {
        return;
    }

    std::string windowName =
        NormalizeSlashesCopy(ExtractXmlTagAttributeValueNoCase(text, "Window", "Name"));
    if (windowName.empty()) {
        return;
    }

    const size_t slashPos = windowName.find('/');
    if (slashPos != std::string::npos) {
        windowName = windowName.substr(0, slashPos);
    }
    if (windowName.empty()) {
        return;
    }

    PushUnique(outValues, windowName);
    PushUnique(outValues, ToLowerCopy(windowName));
}

void ExtractUiImagesetNameHintsFromText(const std::string& text,
                                        std::vector<std::string>& outValues) {
    if (text.empty() || ToLowerCopy(text).find("<imageset") == std::string::npos) {
        return;
    }

    std::string imagesetName =
        ExtractResourceStemCandidate(ExtractXmlTagAttributeValueNoCase(text, "Imageset", "Name"));
    std::string imageFileName =
        ExtractResourceStemCandidate(ExtractXmlTagAttributeValueNoCase(text, "Imageset", "Imagefile"));

    if (!imagesetName.empty()) {
        PushUnique(outValues, imagesetName);
        PushUnique(outValues, ToLowerCopy(imagesetName));
    }
    if (!imageFileName.empty()) {
        PushUnique(outValues, imageFileName);
        PushUnique(outValues, ToLowerCopy(imageFileName));
    }
}

void ExtractUiImagesetImagePathHintsFromText(const std::string& text,
                                             std::vector<std::string>& outValues) {
    if (text.empty() || ToLowerCopy(text).find("<imageset") == std::string::npos) {
        return;
    }

    const std::string imageFile =
        NormalizeSlashesCopy(ExtractXmlTagAttributeValueNoCase(text, "Imageset", "Imagefile"));
    if (imageFile.empty()) {
        return;
    }

    PushUnique(outValues, imageFile);
    const std::string lowerImageFile = ToLowerCopy(imageFile);
    if (!lowerImageFile.empty() && lowerImageFile != imageFile) {
        PushUnique(outValues, lowerImageFile);
    }
}

void ExtractUiFontNameHintsFromText(const std::string& text,
                                    std::vector<std::string>& outValues) {
    if (text.empty() || ToLowerCopy(text).find("<font") == std::string::npos) {
        return;
    }

    const std::string fontName =
        ExtractResourceStemCandidate(ExtractXmlTagAttributeValueNoCase(text, "Font", "Name"));
    if (fontName.empty()) {
        return;
    }

    PushUnique(outValues, fontName);
    PushUnique(outValues, ToLowerCopy(fontName));
}

void BuildAtlasPagePathHints(const std::string& dirPath,
                             const std::string& pageName,
                             std::vector<std::string>& outValues) {
    const std::string normalizedPage = NormalizeSlashesCopy(pageName);
    if (normalizedPage.empty()) {
        return;
    }

    PushUnique(outValues, normalizedPage);
    const std::string lowerPage = ToLowerCopy(normalizedPage);
    if (!lowerPage.empty() && lowerPage != normalizedPage) {
        PushUnique(outValues, lowerPage);
    }

    if (!dirPath.empty()) {
        PushUnique(outValues, JoinPath(dirPath, normalizedPage));
        if (!lowerPage.empty() && lowerPage != normalizedPage) {
            PushUnique(outValues, JoinPath(dirPath, lowerPage));
        }
    }
}

void ExtractLuaTopLevelTableSymbols(const std::string& text,
                                    std::vector<std::string>& outValues) {
    size_t pos = 0;
    while (pos < text.size()) {
        pos = text.find('=', pos);
        if (pos == std::string::npos) {
            break;
        }

        size_t valuePos = pos + 1;
        while (valuePos < text.size() &&
               std::isspace(static_cast<unsigned char>(text[valuePos]))) {
            ++valuePos;
        }
        if (valuePos >= text.size() || text[valuePos] != '{') {
            ++pos;
            continue;
        }

        size_t end = pos;
        while (end > 0 && std::isspace(static_cast<unsigned char>(text[end - 1]))) {
            --end;
        }
        if (end == 0) {
            ++pos;
            continue;
        }

        size_t begin = end;
        while (begin > 0) {
            const unsigned char ch = static_cast<unsigned char>(text[begin - 1]);
            if (std::isalnum(ch) || ch == '_' || ch == '.') {
                --begin;
                continue;
            }
            break;
        }
        if (begin == end) {
            ++pos;
            continue;
        }

        std::string name = text.substr(begin, end - begin);
        const size_t dotPos = name.find_last_of('.');
        if (dotPos != std::string::npos && dotPos + 1 < name.size()) {
            name = name.substr(dotPos + 1);
        }
        if (!name.empty()) {
            PushUnique(outValues, name);
        }
        ++pos;
    }
}

std::string FindUniqueSpineStem(const std::vector<std::string>& tokens) {
    std::set<std::string> stems;
    for (size_t i = 0; i < tokens.size(); ++i) {
        const std::string& token = tokens[i];
        size_t pos = token.find("spine_");
        while (pos != std::string::npos) {
            size_t end = pos;
            while (end < token.size()) {
                char c = token[end];
                if (!(std::isalnum(static_cast<unsigned char>(c)) || c == '_' || c == '-')) {
                    break;
                }
                ++end;
            }
            std::string stem = token.substr(pos, end - pos);
            if (!stem.empty()) {
                stems.insert(stem);
            }
            pos = token.find("spine_", end);
        }
    }
    if (stems.size() == 1) {
        return *stems.begin();
    }
    return std::string();
}

std::string ParseFirstNonEmptyLine(const std::vector<unsigned char>& data) {
    std::string text(data.begin(), data.end());
    std::istringstream iss(text);
    std::string line;
    while (std::getline(iss, line)) {
        while (!line.empty() && (line.back() == '\r' || line.back() == '\n')) {
            line.pop_back();
        }
        if (!line.empty()) {
            return line;
        }
    }
    return std::string();
}

std::string TrimAsciiWhitespace(const std::string& value) {
    size_t begin = 0;
    while (begin < value.size() &&
           std::isspace(static_cast<unsigned char>(value[begin]))) {
        ++begin;
    }

    size_t end = value.size();
    while (end > begin &&
           std::isspace(static_cast<unsigned char>(value[end - 1]))) {
        --end;
    }

    return value.substr(begin, end - begin);
}

struct AtlasPrimaryPageInfo {
    std::string pageName;
    uint32_t width;
    uint32_t height;
    bool hasSize;

    AtlasPrimaryPageInfo()
        : width(0)
        , height(0)
        , hasSize(false) {}
};

bool TryParseAtlasSizePair(const std::string& text, uint32_t* width, uint32_t* height) {
    if (width == NULL || height == NULL) {
        return false;
    }

    const size_t comma = text.find(',');
    if (comma == std::string::npos) {
        return false;
    }

    const std::string widthText = TrimAsciiWhitespace(text.substr(0, comma));
    const std::string heightText = TrimAsciiWhitespace(text.substr(comma + 1));
    if (widthText.empty() || heightText.empty()) {
        return false;
    }

    char* widthEnd = NULL;
    char* heightEnd = NULL;
    errno = 0;
    const unsigned long parsedWidth = std::strtoul(widthText.c_str(), &widthEnd, 10);
    const int widthErrno = errno;
    errno = 0;
    const unsigned long parsedHeight = std::strtoul(heightText.c_str(), &heightEnd, 10);
    const int heightErrno = errno;
    if (widthEnd == NULL || heightEnd == NULL ||
        *widthEnd != '\0' || *heightEnd != '\0') {
        return false;
    }
    if (widthErrno == ERANGE || heightErrno == ERANGE ||
        parsedWidth > 0xFFFFFFFFul || parsedHeight > 0xFFFFFFFFul) {
        return false;
    }

    *width = static_cast<uint32_t>(parsedWidth);
    *height = static_cast<uint32_t>(parsedHeight);
    return true;
}

bool ParseAtlasPrimaryPageInfo(const std::vector<unsigned char>& data,
                               AtlasPrimaryPageInfo* outInfo) {
    if (outInfo == NULL) {
        return false;
    }

    *outInfo = AtlasPrimaryPageInfo();

    std::string text(data.begin(), data.end());
    std::istringstream iss(text);
    std::string line;
    while (std::getline(iss, line)) {
        while (!line.empty() && (line.back() == '\r' || line.back() == '\n')) {
            line.pop_back();
        }

        line = TrimAsciiWhitespace(line);
        if (line.empty()) {
            continue;
        }

        if (outInfo->pageName.empty()) {
            outInfo->pageName = line;
            continue;
        }

        if (StartsWith(ToLowerCopy(line), "size:")) {
            const std::string sizeText = TrimAsciiWhitespace(line.substr(5));
            outInfo->hasSize = TryParseAtlasSizePair(sizeText,
                                                     &outInfo->width,
                                                     &outInfo->height);
            return true;
        }
    }

    return !outInfo->pageName.empty();
}

bool TryReadPngDimensions(const std::vector<unsigned char>& data,
                          uint32_t* width,
                          uint32_t* height) {
    if (width == NULL || height == NULL ||
        data.size() < 24 || !LooksLikePngSignature(data.data(), data.size())) {
        return false;
    }

    *width = (static_cast<uint32_t>(data[16]) << 24) |
             (static_cast<uint32_t>(data[17]) << 16) |
             (static_cast<uint32_t>(data[18]) << 8) |
             static_cast<uint32_t>(data[19]);
    *height = (static_cast<uint32_t>(data[20]) << 24) |
              (static_cast<uint32_t>(data[21]) << 16) |
              (static_cast<uint32_t>(data[22]) << 8) |
              static_cast<uint32_t>(data[23]);
    return true;
}

bool TryReadDdsDimensions(const std::vector<unsigned char>& data,
                          uint32_t* width,
                          uint32_t* height) {
    if (width == NULL || height == NULL || data.size() < 20) {
        return false;
    }

    if (data[0] != 'D' || data[1] != 'D' || data[2] != 'S' || data[3] != ' ') {
        return false;
    }

    *height = static_cast<uint32_t>(data[12]) |
              (static_cast<uint32_t>(data[13]) << 8) |
              (static_cast<uint32_t>(data[14]) << 16) |
              (static_cast<uint32_t>(data[15]) << 24);
    *width = static_cast<uint32_t>(data[16]) |
             (static_cast<uint32_t>(data[17]) << 8) |
             (static_cast<uint32_t>(data[18]) << 16) |
             (static_cast<uint32_t>(data[19]) << 24);
    return true;
}

bool TryReadImageDimensions(const std::vector<unsigned char>& data,
                            const std::string& extension,
                            uint32_t* width,
                            uint32_t* height) {
    const std::string lowerExtension = ToLowerCopy(extension);
    if (lowerExtension == ".png") {
        return TryReadPngDimensions(data, width, height);
    }
    if (lowerExtension == ".dds") {
        return TryReadDdsDimensions(data, width, height);
    }
    return false;
}

std::string FormatResVariant(int index) {
    std::ostringstream oss;
    oss << "_res" << std::setw(3) << std::setfill('0') << index;
    return oss.str();
}

bool SplitModelAniPath(const std::string& relPath,
                       std::string& modelName,
                       std::string& groupName,
                       std::string& subgroupName,
                       std::string& actionName,
                       std::string& tail) {
    const std::string normalized = NormalizeSlashesCopy(relPath);
    if (!StartsWith(ToLowerCopy(normalized), "model/") ||
        !EndsWith(ToLowerCopy(normalized), ".ani")) {
        return false;
    }

    const std::string rest = normalized.substr(std::string("model/").size());
    const size_t firstSlash = rest.find('/');
    if (firstSlash == std::string::npos || firstSlash + 1 >= rest.size()) {
        return false;
    }

    modelName = rest.substr(0, firstSlash);
    tail = rest.substr(firstSlash + 1);

    const size_t secondSlash = tail.find('/');
    if (secondSlash == std::string::npos || secondSlash + 1 >= tail.size()) {
        return false;
    }

    groupName = tail.substr(0, secondSlash);
    const std::string leafRest = tail.substr(secondSlash + 1);
    const size_t thirdSlash = leafRest.find('/');
    if (thirdSlash == std::string::npos || thirdSlash + 1 >= leafRest.size()) {
        return false;
    }

    subgroupName = leafRest.substr(0, thirdSlash);
    actionName = RemoveExtension(GetFileName(leafRest));
    return !modelName.empty() && !groupName.empty() &&
           !subgroupName.empty() && !actionName.empty();
}

bool SplitModelActionPath(const std::string& relPath,
                          std::string& modelName,
                          std::string& actionName) {
    const std::string normalized = NormalizeSlashesCopy(relPath);
    const std::string lower = ToLowerCopy(normalized);
    if (!StartsWith(lower, "model/") || !EndsWith(lower, ".act")) {
        return false;
    }

    const std::string rest = normalized.substr(std::string("model/").size());
    const size_t firstSlash = rest.find('/');
    if (firstSlash == std::string::npos || firstSlash + 1 >= rest.size()) {
        return false;
    }

    modelName = rest.substr(0, firstSlash);
    const std::string tail = rest.substr(firstSlash + 1);
    if (!StartsWith(ToLowerCopy(tail), "action/")) {
        return false;
    }

    actionName = RemoveExtension(GetFileName(tail));
    return !modelName.empty() && !actionName.empty();
}

bool SplitModelDyePath(const std::string& relPath, std::string& modelName) {
    const std::string normalized = NormalizeSlashesCopy(relPath);
    const std::string lower = ToLowerCopy(normalized);
    if (!StartsWith(lower, "model/") || !EndsWith(lower, "/dyeinfo.dye")) {
        return false;
    }

    const std::string rest = normalized.substr(std::string("model/").size());
    const size_t firstSlash = rest.find('/');
    if (firstSlash == std::string::npos || firstSlash + 1 >= rest.size()) {
        return false;
    }

    modelName = rest.substr(0, firstSlash);
    return !modelName.empty() &&
           ToLowerCopy(rest.substr(firstSlash + 1)) == "dyeinfo.dye";
}

bool SplitEffectAnimationPath(const std::string& relPath, std::string& animationRef) {
    const std::string normalized = NormalizeSlashesCopy(relPath);
    const std::string lower = ToLowerCopy(normalized);
    if (!StartsWith(lower, "effect/animation/") || !EndsWith(lower, ".ani")) {
        return false;
    }

    animationRef = RemoveExtension(normalized.substr(std::string("effect/").size()));
    return !animationRef.empty();
}

struct TableBufferReader {
    const std::vector<unsigned char>& data;
    size_t pos;

    explicit TableBufferReader(const std::vector<unsigned char>& src)
        : data(src), pos(0) {}

private:
    TableBufferReader(const TableBufferReader&);
    TableBufferReader& operator=(const TableBufferReader&);

public:

    bool ReadUInt8(uint8_t& value) {
        if (pos + 1 > data.size()) {
            return false;
        }
        value = data[pos];
        ++pos;
        return true;
    }

    bool ReadUInt16(uint16_t& value) {
        if (pos + 2 > data.size()) {
            return false;
        }
        value = static_cast<uint16_t>(data[pos] | (data[pos + 1] << 8));
        pos += 2;
        return true;
    }

    bool ReadUInt32(uint32_t& value) {
        if (pos + 4 > data.size()) {
            return false;
        }
        value =
            static_cast<uint32_t>(data[pos]) |
            (static_cast<uint32_t>(data[pos + 1]) << 8) |
            (static_cast<uint32_t>(data[pos + 2]) << 16) |
            (static_cast<uint32_t>(data[pos + 3]) << 24);
        pos += 4;
        return true;
    }

    bool ReadInt32(int32_t& value) {
        uint32_t raw = 0;
        if (!ReadUInt32(raw)) {
            return false;
        }
        value = static_cast<int32_t>(raw);
        return true;
    }

    bool ReadUtf8String(std::string& value) {
        uint32_t length = 0;
        if (!ReadUInt32(length) || pos + length > data.size()) {
            return false;
        }
        value.assign(reinterpret_cast<const char*>(&data[pos]), length);
        pos += length;
        return true;
    }
};

bool ReadTableHeader(TableBufferReader& reader, uint16_t& rowCount, uint32_t& checkNumber) {
    uint32_t magic = 0;
    uint32_t totalSize = 0;
    uint16_t version = 0;
    if (!reader.ReadUInt32(magic) ||
        !reader.ReadUInt32(totalSize) ||
        !reader.ReadUInt16(version) ||
        !reader.ReadUInt16(rowCount) ||
        !reader.ReadUInt32(checkNumber)) {
        return false;
    }
    return magic == 1499087948u;  // 'LDZY'
}

bool SkipIntVector(TableBufferReader& reader) {
    uint32_t count = 0;
    if (!reader.ReadUInt32(count)) {
        return false;
    }
    for (uint32_t i = 0; i < count; ++i) {
        int32_t value = 0;
        if (!reader.ReadInt32(value)) {
            return false;
        }
    }
    return true;
}

bool ParseMapConfigResDirsFromBinary(const std::vector<unsigned char>& data,
                                    std::set<std::string>& outResDirs) {
    TableBufferReader reader(data);
    uint16_t rowCount = 0;
    uint32_t checkNumber = 0;
    if (!ReadTableHeader(reader, rowCount, checkNumber)) {
        return false;
    }

    if (rowCount == 0 || rowCount > 4096) {
        return false;
    }

    for (uint16_t row = 0; row < rowCount; ++row) {
        int32_t intValue = 0;
        uint8_t boolValue = 0;
        std::string textValue;
        std::string resdir;

        if (!reader.ReadInt32(intValue) ||          // id
            !reader.ReadUtf8String(textValue) ||    // mapName
            !reader.ReadUtf8String(textValue) ||    // mapIcon
            !reader.ReadUtf8String(textValue) ||    // desc
            !reader.ReadUtf8String(resdir)) {       // resdir
            return false;
        }

        for (int i = 0; i < 7; ++i) {               // battleground..qinggong
            if (!reader.ReadInt32(intValue)) {
                return false;
            }
        }
        if (!reader.ReadUInt8(boolValue)) {         // bShowInWorld
            return false;
        }
        for (int i = 0; i < 7; ++i) {               // LevelLimitMin..fubenType
            if (!reader.ReadInt32(intValue)) {
                return false;
            }
        }
        if (!reader.ReadUtf8String(textValue) ||    // music
            !reader.ReadInt32(intValue) ||          // flyPosX
            !reader.ReadInt32(intValue) ||          // flyPosY
            !reader.ReadUtf8String(textValue) ||    // sceneColor
            !reader.ReadInt32(intValue) ||          // jumpmappoint
            !reader.ReadInt32(intValue)) {          // isMemVisible
            return false;
        }

        resdir = NormalizeSlashesCopy(resdir);
        if (resdir.empty() ||
            resdir.find('/') != std::string::npos ||
            resdir.find('\\') != std::string::npos ||
            resdir.find('.') != std::string::npos) {
            continue;
        }
        outResDirs.insert(resdir);
    }

    return !outResDirs.empty();
}

bool ParseNpcShapeTableData(const std::vector<unsigned char>& data,
                            std::set<std::string>& outModels,
                            std::set<std::string>& outActions) {
    TableBufferReader reader(data);
    uint16_t rowCount = 0;
    uint32_t checkNumber = 0;
    if (!ReadTableHeader(reader, rowCount, checkNumber)) {
        return false;
    }

    for (uint16_t row = 0; row < rowCount; ++row) {
        int32_t intValue = 0;
        std::string shape;
        std::string roleimage;
        std::string chatimageleft;
        std::string chatimageright;
        std::string name;
        std::string attack;
        std::string magic;
        std::string behit;
        std::string death;

        if (!reader.ReadInt32(intValue) ||
            !reader.ReadUtf8String(shape) ||
            !reader.ReadUtf8String(roleimage) ||
            !reader.ReadUtf8String(chatimageleft) ||
            !reader.ReadUtf8String(chatimageright)) {
            return false;
        }

        for (int i = 0; i < 3; ++i) {
            if (!reader.ReadInt32(intValue)) {
                return false;
            }
        }

        if (!reader.ReadUtf8String(name)) {
            return false;
        }

        for (int i = 0; i < 3; ++i) {
            if (!reader.ReadInt32(intValue)) {
                return false;
            }
        }

        if (!reader.ReadUtf8String(attack) ||
            !reader.ReadUtf8String(magic) ||
            !reader.ReadUtf8String(behit) ||
            !reader.ReadUtf8String(death)) {
            return false;
        }

        for (int i = 0; i < 2; ++i) {
            if (!reader.ReadInt32(intValue)) {
                return false;
            }
        }

        if (!SkipIntVector(reader) ||
            !SkipIntVector(reader) ||
            !SkipIntVector(reader)) {
            return false;
        }

        for (int i = 0; i < 3; ++i) {
            if (!reader.ReadInt32(intValue)) {
                return false;
            }
        }

        PushUniqueSet(outModels, shape);
        PushUniqueSet(outActions, attack);
        PushUniqueSet(outActions, magic);
        PushUniqueSet(outActions, behit);
        PushUniqueSet(outActions, death);
    }

    return true;
}

bool ParseNpcActionInfoTableData(const std::vector<unsigned char>& data,
                                 std::set<std::string>& outModels,
                                 std::set<std::string>& outActions,
                                 std::set<std::string>& outRidingActions) {
    TableBufferReader reader(data);
    uint16_t rowCount = 0;
    uint32_t checkNumber = 0;
    if (!ReadTableHeader(reader, rowCount, checkNumber)) {
        return false;
    }

    for (uint16_t row = 0; row < rowCount; ++row) {
        int32_t intValue = 0;
        std::string model;
        std::string actionNames[11];

        if (!reader.ReadInt32(intValue) ||
            !reader.ReadUtf8String(model) ||
            !reader.ReadInt32(intValue)) {
            return false;
        }

        for (size_t i = 0; i < sizeof(actionNames) / sizeof(actionNames[0]); ++i) {
            if (!reader.ReadUtf8String(actionNames[i])) {
                return false;
            }
        }

        PushUniqueSet(outModels, model);
        for (size_t i = 0; i < sizeof(actionNames) / sizeof(actionNames[0]); ++i) {
            PushUniqueSet(outActions, actionNames[i]);
            if (StartsWith(ToLowerCopy(actionNames[i]), "riding_")) {
                PushUniqueSet(outRidingActions, actionNames[i]);
            }
        }
    }

    return true;
}

bool ParseNpcRideTableData(const std::vector<unsigned char>& data,
                           std::set<std::string>& outRideModelIds) {
    TableBufferReader reader(data);
    uint16_t rowCount = 0;
    uint32_t checkNumber = 0;
    if (!ReadTableHeader(reader, rowCount, checkNumber)) {
        return false;
    }

    for (uint16_t row = 0; row < rowCount; ++row) {
        int32_t id = 0;
        int32_t rideModel = 0;
        int32_t intValue = 0;
        std::string desc;

        if (!reader.ReadInt32(id) ||
            !reader.ReadInt32(rideModel)) {
            return false;
        }

        for (int i = 0; i < 5; ++i) {
            if (!reader.ReadInt32(intValue)) {
                return false;
            }
        }

        if (checkNumber == 524335u && !reader.ReadUtf8String(desc)) {
            return false;
        }

        std::ostringstream oss;
        oss << rideModel;
        PushUniqueSet(outRideModelIds, oss.str());
    }

    return true;
}

void ExtractAtlasRegionNames(const std::vector<unsigned char>& data,
                             std::set<std::string>& outRegions) {
    std::string text(data.begin(), data.end());
    std::istringstream iss(text);
    std::string line;
    bool firstLineSkipped = false;
    while (std::getline(iss, line)) {
        while (!line.empty() && (line.back() == '\r' || line.back() == '\n')) {
            line.pop_back();
        }
        if (!firstLineSkipped) {
            if (!line.empty()) {
                firstLineSkipped = true;
            }
            continue;
        }
        if (line.empty()) {
            continue;
        }
        if (!line.empty() && std::isspace(static_cast<unsigned char>(line[0]))) {
            continue;
        }
        if (line.find(':') != std::string::npos) {
            continue;
        }
        PushUniqueSet(outRegions, line);
    }
}

void ExtractSpineJsonAttachments(const std::vector<unsigned char>& data,
                                 std::set<std::string>& outAttachments) {
    std::string text(data.begin(), data.end());
    size_t pos = 0;
    for (;;) {
        pos = text.find("\"attachment\"", pos);
        if (pos == std::string::npos) {
            break;
        }
        size_t colon = text.find(':', pos + 12);
        if (colon == std::string::npos) {
            break;
        }
        size_t valuePos = colon + 1;
        while (valuePos < text.size() &&
               std::isspace(static_cast<unsigned char>(text[valuePos]))) {
            ++valuePos;
        }
        if (valuePos >= text.size() || text[valuePos] != '"') {
            pos = colon + 1;
            continue;
        }
        size_t valueEnd = text.find('"', valuePos + 1);
        if (valueEnd == std::string::npos || valueEnd <= valuePos + 1) {
            pos = valuePos + 1;
            continue;
        }
        std::string value = text.substr(valuePos + 1, valueEnd - valuePos - 1);
        if (!value.empty() && value.find('/') == std::string::npos) {
            PushUniqueSet(outAttachments, value);
        }
        pos = valueEnd + 1;
    }
}

bool ParseNumericBaseName(const std::string& relPath, uint32_t& outCrc, std::string& outExt) {
    std::string fileName = GetFileName(relPath);
    std::string stem = RemoveExtension(fileName);
    if (!IsDigitsOnly(stem)) {
        return false;
    }
    outCrc = static_cast<uint32_t>(std::strtoul(stem.c_str(), NULL, 10));
    outExt = GetExtensionLower(fileName);
    return true;
}

} // namespace
#endif

// ============================================================================
// Unpacker 类实现
// ============================================================================

Unpacker::Unpacker(
    CRC32_Func crc32Func,
    Zip_Func zipFunc,
    UnZip_Func unzipFunc,
    SMS4_Func sms4Func,
    DeSMS4_Func desms4Func)
    : m_crc32Func(crc32Func)
    , m_zipFunc(zipFunc)
    , m_unzipFunc(unzipFunc)
    , m_sms4Func(sms4Func)
    , m_desms4Func(desms4Func)
    , m_totalFiles(0)
    , m_processedFiles(0)
    , m_failedFiles(0)
    , m_totalBytes(0)
    , m_processedBytes(0)
    , m_isRunning(false)
    , m_shouldStop(false)
    , m_shouldPause(false)
    , m_pathMappingStatsValid(false)
    , m_pathMappingHitCount(0)
    , m_pathMappingMissCount(0)
    , m_pathMappingRateBasis(0)
    , m_streamConsidered(0)
    , m_streamUsed(0)
    , m_streamFallback(0)
    , m_streamSkipCompressed(0)
    , m_streamSkipEncryptedUnaligned(0)
    , m_firstErrorCode(0)
    , m_firstErrorFileIndex(0)
{
    LJFP_LOG_INFO(L"Unpacker initialized");
}

Unpacker::~Unpacker() {
    Clear();
    LJFP_LOG_INFO(L"Unpacker destroyed");
}

int Unpacker::LoadIndex(const std::string& indexPath) {
    LJFP_LOG_INFO(L"Loading index file: " + MultiByteToWideBestEffort(indexPath));

    // 检查文件是否存在
    std::ifstream testFile(indexPath, std::ios::binary);
    if (!testFile.is_open()) {
        LJFP_LOG_ERROR(L"Index file not found: " + MultiByteToWideBestEffort(indexPath));
        return LJFP_ERROR_INDEX_NOT_FOUND;
    }
    testFile.close();

    // 判断文件类型
    bool isLjzip = (indexPath.find(".ljzip") != std::string::npos);

    if (isLjzip) {
        // 处理加密索引文件
        return LoadLjzipIndex(indexPath);
    } else {
        // 直接加载 .ljpi 文件
        return LoadLjpiIndex(indexPath);
    }
}

void Unpacker::ConfigureSession(const std::string& inputDir,
                                const std::string& outputDir,
                                const UnpackOptions& options) {
    if (!inputDir.empty()) {
        m_inputDir = NormalizeSlashesCopy(inputDir);
    }
    if (!outputDir.empty()) {
        m_outputDir = NormalizeSlashesCopy(outputDir);
    }
    m_options = options;
}

int Unpacker::UnpackAll(const std::string& inputDir, const std::string& outputDir, const UnpackOptions& options) {
    LJFP_LOG_INFO(L"Starting unpacking...");
    LJFP_LOG_INFO(L"Input directory: " + MultiByteToWideBestEffort(inputDir));
    LJFP_LOG_INFO(L"Output directory: " + MultiByteToWideBestEffort(outputDir));

    m_isRunning.store(true);
    m_shouldStop.store(false);
    m_shouldPause.store(false);
    ConfigureSession(inputDir, outputDir, options);
    ResetStreamStats();
    ResetOutputPathAudit();

    // 确保输出目录存在
    CreateDirectoryRecursive(outputDir);

    // 重置统计信息
    m_processedFiles = 0;
    m_failedFiles = 0;
    m_processedBytes = 0;
    ResetRunDiagnostics();

    // 检查是否启用并行处理
    int threadCount = (options.threadCount > 0) ? options.threadCount : 1;

    int result = LJFP_SUCCESS;
    if (threadCount == 1) {
        // 单线程顺序处理
        result = UnpackAllSequential();
    } else {
        // 多线程并行处理 (使用优化版本)
        LJFP_LOG_INFO(L"Using optimized parallel processing with " + std::to_wstring(threadCount) + L" threads");
        result = UnpackAllParallelOptimized(threadCount);
    }

    if (m_options.restorePathStructureAfterUnpack) {
        int postResult = PostProcessRestoredOutputs();
        if (result == LJFP_SUCCESS && postResult != LJFP_SUCCESS) {
            result = postResult;
        }
    }

    int validateResult = ValidateRestoreOutcome();
    if (result == LJFP_SUCCESS && validateResult != LJFP_SUCCESS) {
        result = validateResult;
    }

    if (m_options.writePathManifest) {
        RefreshOutputPathAuditFinalPaths();
        int manifestResult = WriteOutputPathManifest();
        if (result == LJFP_SUCCESS && manifestResult != LJFP_SUCCESS) {
            result = manifestResult;
        }
    }

    return result;
}

int Unpacker::UnpackSelected(const std::vector<size_t>& fileIndices,
                             const std::string& inputDir,
                             const std::string& outputDir,
                             const UnpackOptions& options) {
    std::set<size_t> uniqueIndices;
    std::vector<size_t> validIndices;
    validIndices.reserve(fileIndices.size());
    for (size_t i = 0; i < fileIndices.size(); ++i) {
        const size_t index = fileIndices[i];
        if (index >= m_fileList.size()) {
            continue;
        }
        if (uniqueIndices.insert(index).second) {
            validIndices.push_back(index);
        }
    }

    if (validIndices.empty()) {
        LJFP_LOG_ERROR(L"UnpackSelected called with no valid file indices");
        return LJFP_ERROR_INVALID_INDEX;
    }

    LJFP_LOG_INFO(L"Starting selected-file unpacking...");
    LJFP_LOG_INFO(L"Selected file count: " + std::to_wstring(validIndices.size()));
    LJFP_LOG_INFO(L"Input directory: " + MultiByteToWideBestEffort(inputDir));
    LJFP_LOG_INFO(L"Output directory: " + MultiByteToWideBestEffort(outputDir));

    m_isRunning.store(true);
    m_shouldStop.store(false);
    m_shouldPause.store(false);
    ConfigureSession(inputDir, outputDir, options);
    ResetStreamStats();
    ResetOutputPathAudit();
    ResetRunDiagnostics();

    CreateDirectoryRecursive(outputDir);

    m_processedFiles = 0;
    m_failedFiles = 0;
    m_processedBytes = 0;

    const int threadCount = (options.threadCount > 0) ? options.threadCount : 1;
    int result = LJFP_SUCCESS;
    if (threadCount == 1) {
        result = UnpackSelectedSequential(validIndices);
    } else {
        LJFP_LOG_INFO(L"Using optimized parallel processing for selected files with " +
                      std::to_wstring(threadCount) + L" threads");
        result = UnpackSelectedParallelOptimized(validIndices, threadCount);
    }

    if (m_options.writePathManifest) {
        RefreshOutputPathAuditFinalPaths();
        int manifestResult = WriteOutputPathManifest();
        if (result == LJFP_SUCCESS && manifestResult != LJFP_SUCCESS) {
            result = manifestResult;
        }
    }

    return result;
}

int Unpacker::UnpackAllSequential() {
    // 报告初始进度 (0%)
    if (m_progressCallback) {
        m_progressCallback(0.0f, 0, m_totalFiles);
    }

    // 节流变量：每 0.5% 或至少每 10 个文件报告一次
    const size_t minReportDelta = std::max(1u, std::min(10u, m_totalFiles / 200));
    size_t lastReportedIndex = 0;

    // 遍历所有文件进行解包
    for (size_t i = 0; i < m_fileList.size(); i++) {
        if (!WaitIfPaused()) {
            LJFP_LOG_WARNING(L"Unpacking stopped while paused");
            break;
        }
        if (m_shouldStop.load()) {
            LJFP_LOG_WARNING(L"Unpacking stopped by user");
            break;
        }

        FileInfo& fileInfo = m_fileList[i];
        int result = UnpackSingleFile(fileInfo, i);

        if (result == LJFP_SUCCESS) {
            m_processedFiles++;
            m_processedBytes += fileInfo.m_SizeOriginal;
        } else if (result == LJFP_ERROR_USER_CANCELLED && m_shouldStop.load()) {
            LJFP_LOG_WARNING(L"Sequential unpack interrupted by stop request");
            break;
        } else {
            m_failedFiles++;
            m_lastErrorCodeCounts[result]++;
            if (m_firstErrorCode == 0) {
                m_firstErrorCode = result;
                m_firstErrorFileIndex = static_cast<uint32_t>(i);
            }
            RecordFailedFile(i, fileInfo, result);
            LJFP_LOG_ERROR(L"Failed to unpack file #" + std::to_wstring(i) +
                           L", CRC32=" + std::to_wstring(fileInfo.m_PathFileNameCRC32));
        }

        // 更新进度回调（带节流）
        if (m_progressCallback && (i + 1 - lastReportedIndex >= minReportDelta || i + 1 == m_totalFiles)) {
            float progress = (float)(i + 1) / m_totalFiles;
            m_progressCallback(progress, i + 1, m_totalFiles);
            lastReportedIndex = i + 1;
        }
    }

    m_isRunning.store(false);

    // 输出统计信息
    LJFP_LOG_INFO(L"======================================");
    LJFP_LOG_INFO(L"Unpacking completed!");
    LJFP_LOG_INFO(L"Total files: " + std::to_wstring(m_totalFiles));
    LJFP_LOG_INFO(L"Processed: " + std::to_wstring(m_processedFiles));
    LJFP_LOG_INFO(L"Failed: " + std::to_wstring(m_failedFiles));
    LJFP_LOG_INFO(L"Total bytes: " + std::to_wstring(m_processedBytes / 1024 / 1024) + L" MB");
    LJFP_LOG_INFO(L"======================================");
    ReportStreamStats(L"sequential");

    return (m_failedFiles == 0) ? LJFP_SUCCESS : LJFP_ERROR_PARTIAL_FAILURE;
}

int Unpacker::UnpackSelectedSequential(const std::vector<size_t>& fileIndices) {
    const uint32_t selectedTotal = static_cast<uint32_t>(fileIndices.size());
    if (m_progressCallback) {
        m_progressCallback(0.0f, 0, selectedTotal);
    }

    const size_t minReportDelta = std::max<size_t>(1u, std::min<size_t>(10u, selectedTotal / 200));
    size_t lastReportedIndex = 0;

    for (size_t i = 0; i < fileIndices.size(); ++i) {
        if (!WaitIfPaused()) {
            LJFP_LOG_WARNING(L"Selected unpack stopped while paused");
            break;
        }
        if (m_shouldStop.load()) {
            LJFP_LOG_WARNING(L"Selected unpack stopped by user");
            break;
        }

        const size_t fileIndex = fileIndices[i];
        if (fileIndex >= m_fileList.size()) {
            continue;
        }

        FileInfo& fileInfo = m_fileList[fileIndex];
        const int result = UnpackSingleFile(fileInfo, fileIndex);

        if (result == LJFP_SUCCESS) {
            m_processedFiles++;
            m_processedBytes += fileInfo.m_SizeOriginal;
        } else if (result == LJFP_ERROR_USER_CANCELLED && m_shouldStop.load()) {
            LJFP_LOG_WARNING(L"Selected sequential unpack interrupted by stop request");
            break;
        } else {
            m_failedFiles++;
            m_lastErrorCodeCounts[result]++;
            if (m_firstErrorCode == 0) {
                m_firstErrorCode = result;
                m_firstErrorFileIndex = static_cast<uint32_t>(fileIndex);
            }
            RecordFailedFile(fileIndex, fileInfo, result);
            LJFP_LOG_ERROR(L"Failed to unpack selected file #" + std::to_wstring(fileIndex) +
                           L", CRC32=" + std::to_wstring(fileInfo.m_PathFileNameCRC32));
        }

        if (m_progressCallback &&
            (i + 1 - lastReportedIndex >= minReportDelta || i + 1 == fileIndices.size())) {
            const float progress = selectedTotal > 0
                ? static_cast<float>(i + 1) / static_cast<float>(selectedTotal)
                : 1.0f;
            m_progressCallback(progress,
                               static_cast<uint32_t>(i + 1),
                               selectedTotal);
            lastReportedIndex = i + 1;
        }
    }

    m_isRunning.store(false);
    ReportStreamStats(L"selected-sequential");
    return (m_failedFiles == 0) ? LJFP_SUCCESS : LJFP_ERROR_PARTIAL_FAILURE;
}

int Unpacker::UnpackAllParallel(int threadCount) {
    // 线程同步变量
    std::mutex queueMutex;
    std::mutex statsMutex;
    std::condition_variable cv;
    std::queue<size_t> taskQueue;
    std::atomic<bool> stopFlag(false);
    std::atomic<uint32_t> completedCount(0);

    // 填充任务队列
    for (size_t i = 0; i < m_fileList.size(); i++) {
        taskQueue.push(i);
    }

    // Worker 线程函数
    // 注意：不在工作线程中调用进度回调，而是在主等待循环中定期报告
    auto workerThread = [&]() {
        for (;;) {
            size_t fileIndex;

            // 从队列中获取任务
            {
                std::unique_lock<std::mutex> lock(queueMutex);
                cv.wait(lock, [&]() { return stopFlag.load() || !taskQueue.empty(); });

                if (stopFlag.load() && taskQueue.empty()) {
                    break;
                }

                if (taskQueue.empty()) {
                    continue;
                }

                fileIndex = taskQueue.front();
                taskQueue.pop();
            }

            if (!WaitIfPaused()) {
                stopFlag.store(true);
                break;
            }
            if (stopFlag.load() || m_shouldStop.load()) {
                stopFlag.store(true);
                break;
            }

            // 处理文件
            if (fileIndex < m_fileList.size()) {
                FileInfo& fileInfo = m_fileList[fileIndex];
                int result = UnpackSingleFile(fileInfo, fileIndex);

                // 更新统计信息（线程安全）
                {
                    std::lock_guard<std::mutex> lock(statsMutex);
                    if (result == LJFP_SUCCESS) {
                        m_processedFiles++;
                        m_processedBytes += fileInfo.m_SizeOriginal;
                    } else if (result == LJFP_ERROR_USER_CANCELLED && m_shouldStop.load()) {
                        stopFlag.store(true);
                    } else {
                        m_failedFiles++;
                        m_lastErrorCodeCounts[result]++;
                        if (m_firstErrorCode == 0) {
                            m_firstErrorCode = result;
                            m_firstErrorFileIndex = static_cast<uint32_t>(fileIndex);
                        }
                        RecordFailedFile(fileIndex, fileInfo, result);
                        LJFP_LOG_ERROR(L"Failed to unpack file #" + std::to_wstring(fileIndex) +
                                       L", CRC32=" + std::to_wstring(fileInfo.m_PathFileNameCRC32));
                    }
                }

                // 只更新计数器，不调用回调（避免多线程竞争）
                ++completedCount;
            }
        }
    };

    // 创建线程池
    std::vector<std::thread> workers;
    for (int i = 0; i < threadCount; i++) {
        workers.emplace_back(workerThread);
    }

    // 通知所有线程开始工作
    cv.notify_all();

    // 进度报告节流变量（单线程安全）
    uint32_t lastReportedCount = 0;
    // 降低节流阈值：每 0.5% 或至少每 10 个文件报告一次
    const uint32_t minReportDelta = std::max(1u, std::min(10u, m_totalFiles / 200));
    auto lastReportTime = std::chrono::steady_clock::now();
    const auto minReportInterval = std::chrono::milliseconds(200);  // 至少每 200ms 报告一次

    // 报告初始进度 (0%)
    if (m_progressCallback) {
        m_progressCallback(0.0f, 0, m_totalFiles);
    }

    // 等待所有任务完成或停止信号
    for (;;) {
        if (m_shouldStop.load()) {
            stopFlag.store(true);
            cv.notify_all();
            break;
        }

        // 定期报告进度（在主等待循环中，单线程安全）
        uint32_t currentCount = completedCount.load();
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - lastReportTime);

        // 满足以下任一条件则报告进度：
        // 1. 完成文件数增量达到阈值
        // 2. 距上次报告超过 200ms 且有进度变化
        // 3. 当前是最后一批文件
        bool shouldReport = (currentCount - lastReportedCount >= minReportDelta) ||
                           (elapsed >= minReportInterval && currentCount > lastReportedCount) ||
                           (currentCount == m_totalFiles && lastReportedCount < m_totalFiles);

        if (m_progressCallback && shouldReport) {
            float progress = (float)currentCount / m_totalFiles;
            m_progressCallback(progress, currentCount, m_totalFiles);
            lastReportedCount = currentCount;
            lastReportTime = now;
        }

        {
            std::lock_guard<std::mutex> lock(queueMutex);
            if (taskQueue.empty() && completedCount.load() == m_totalFiles) {
                stopFlag.store(true);
                cv.notify_all();
                break;
            }
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    // 报告最终进度 (100%)
    if (m_progressCallback) {
        m_progressCallback(1.0f, m_totalFiles, m_totalFiles);
    }

    // 等待所有线程结束
    for (auto& worker : workers) {
        if (worker.joinable()) {
            worker.join();
        }
    }

    m_isRunning.store(false);

    // 输出统计信息
    LJFP_LOG_INFO(L"======================================");
    LJFP_LOG_INFO(L"Parallel unpacking completed!");
    LJFP_LOG_INFO(L"Thread count: " + std::to_wstring(threadCount));
    LJFP_LOG_INFO(L"Total files: " + std::to_wstring(m_totalFiles));
    LJFP_LOG_INFO(L"Processed: " + std::to_wstring(m_processedFiles));
    LJFP_LOG_INFO(L"Failed: " + std::to_wstring(m_failedFiles));
    LJFP_LOG_INFO(L"Total bytes: " + std::to_wstring(m_processedBytes / 1024 / 1024) + L" MB");
    LJFP_LOG_INFO(L"======================================");
    ReportStreamStats(L"parallel");

    return (m_failedFiles == 0) ? LJFP_SUCCESS : LJFP_ERROR_PARTIAL_FAILURE;
}

int Unpacker::UnpackSingle(size_t index, const std::string& outputPath) {
    if (index >= m_fileList.size()) {
        LJFP_LOG_ERROR(L"File index out of range: " + std::to_wstring(index));
        return LJFP_ERROR_INVALID_INDEX;
    }
    if (m_inputDir.empty()) {
        LJFP_LOG_ERROR(L"UnpackSingle requires a configured input directory");
        return LJFP_ERROR_FILE_NOT_FOUND;
    }
    if (outputPath.empty() && m_outputDir.empty()) {
        LJFP_LOG_ERROR(L"UnpackSingle requires a configured output directory or explicit output path");
        return LJFP_ERROR_FILE_CREATE_FAILED;
    }

    FileInfo& fileInfo = m_fileList[index];
    m_processedFiles = 0;
    m_failedFiles = 0;
    m_processedBytes = 0;
    ResetOutputPathAudit();
    ResetRunDiagnostics();
    int result = UnpackSingleFile(fileInfo, index, outputPath);
    if (result == LJFP_SUCCESS) {
        m_processedFiles = 1;
        m_processedBytes = fileInfo.m_SizeOriginal;
    } else {
        m_failedFiles = 1;
        m_lastErrorCodeCounts[result]++;
        m_firstErrorCode = result;
        m_firstErrorFileIndex = static_cast<uint32_t>(index);
        RecordFailedFile(index, fileInfo, result);
    }
    return result;
}

void Unpacker::Stop() {
    m_shouldStop.store(true);
    m_shouldPause.store(false);
    LJFP_LOG_INFO(L"Stop signal sent");
}

void Unpacker::Pause() {
    m_shouldPause.store(true);
    LJFP_LOG_INFO(L"Pause signal sent");
}

void Unpacker::Resume() {
    m_shouldPause.store(false);
    LJFP_LOG_INFO(L"Resume signal sent");
}

void Unpacker::SetPaused(bool paused) {
    if (paused) {
        Pause();
    } else {
        Resume();
    }
}

bool Unpacker::WaitIfPaused() {
    while (m_shouldPause.load()) {
        if (m_shouldStop.load()) {
            return false;
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(30));
    }
    return !m_shouldStop.load();
}

void Unpacker::Clear() {
    m_fileList.clear();
    m_pathMapping.clear();
    ResetPathMappingStats();
    m_customDecryptKey.clear();
    m_totalFiles = 0;
    m_processedFiles = 0;
    m_failedFiles = 0;
    m_totalBytes = 0;
    m_processedBytes = 0;
    m_isRunning.store(false);
    m_shouldStop.store(false);
    m_shouldPause.store(false);
    ResetRunDiagnostics();
    ResetOutputPathAudit();
    {
        std::lock_guard<std::mutex> lock(m_outputPathMutex);
        m_pathMappingAudit.clear();
    }
    ResetPathMappingStats();
    ResetStreamStats();
}

void Unpacker::ResetPathMappingStats() {
    m_pathMappingStatsValid = false;
    m_pathMappingHitCount = 0;
    m_pathMappingMissCount = 0;
    m_pathMappingRateBasis = 0;
    m_pathMappingMissingSamples.clear();
}

std::vector<DecryptProbeRecord> Unpacker::GetLastDecryptProbeRecords() const {
    std::lock_guard<std::mutex> lock(m_decryptProbeMutex);
    return m_lastDecryptProbeRecords;
}

bool Unpacker::GetFirstFailedDecryptDiagnostic(DecryptFailureDiagnostic& outDiagnostic) const {
    std::lock_guard<std::mutex> lock(m_decryptProbeMutex);
    if (!m_firstFailedDecryptDiagnostic.valid) {
        return false;
    }
    outDiagnostic = m_firstFailedDecryptDiagnostic;
    return true;
}

std::vector<FailedFileRecord> Unpacker::GetLastFailedFiles() const {
    std::lock_guard<std::mutex> lock(m_failedFilesMutex);
    return m_lastFailedFiles;
}

std::vector<OutputPathManifestRecord> Unpacker::GetLastOutputPathManifestRecords() const {
    std::vector<OutputPathManifestRecord> records;
    std::lock_guard<std::mutex> lock(m_outputPathMutex);
    records.reserve(m_outputPathAuditRecords.size());
    for (std::map<uint32_t, OutputPathAuditRecord>::const_iterator it = m_outputPathAuditRecords.begin();
         it != m_outputPathAuditRecords.end();
         ++it) {
        const OutputPathAuditRecord& audit = it->second;
        OutputPathManifestRecord record;
        record.pathCRC32 = audit.pathCRC32;
        record.sourceKind = audit.sourceKind;
        record.rawMappingPath = audit.rawMappingPath;
        record.normalizedRelativePath = audit.normalizedRelativePath;
        record.writtenRelativePath = audit.writtenRelativePath;
        record.finalRelativePath = audit.finalRelativePath;
        record.actualRelativePath = audit.actualRelativePath;
        record.physicalPathStatus = audit.physicalPathStatus;
        record.detectedExtension = audit.detectedExtension;
        record.mappingSanitized = audit.mappingSanitized;
        record.conflictResolved = audit.conflictResolved;
        record.existingTargetPreserved = audit.existingTargetPreserved;
        record.postProcessMoved = audit.postProcessMoved;
        record.reviewBucketed = audit.reviewBucketed;
        record.physicalExists = audit.physicalExists;
        record.extensionConsistent = audit.extensionConsistent;
        record.physicalSize = audit.physicalSize;
        records.push_back(record);
    }
    return records;
}

void Unpacker::ResetDecryptProbeDiagnostics() {
    std::lock_guard<std::mutex> lock(m_decryptProbeMutex);
    m_lastDecryptProbeRecords.clear();
    m_firstFailedDecryptDiagnostic = DecryptFailureDiagnostic();
}

void Unpacker::ResetRunDiagnostics() {
    m_lastErrorCodeCounts.clear();
    m_firstErrorCode = 0;
    m_firstErrorFileIndex = 0;
    {
        std::lock_guard<std::mutex> lock(m_failedFilesMutex);
        m_lastFailedFiles.clear();
    }
    ResetDecryptProbeDiagnostics();
}

void Unpacker::SetLastDecryptProbeRecords(const std::vector<DecryptProbeRecord>& records) {
    std::lock_guard<std::mutex> lock(m_decryptProbeMutex);
    m_lastDecryptProbeRecords = records;
}

void Unpacker::CaptureFirstFailedDecryptDiagnostic(uint32_t fileIndex,
                                                   const FileInfo& fileInfo,
                                                   uint32_t inputSize,
                                                   int failureCode,
                                                   const std::vector<DecryptProbeRecord>& probeRecords) {
    std::lock_guard<std::mutex> lock(m_decryptProbeMutex);
    if (m_firstFailedDecryptDiagnostic.valid || probeRecords.empty()) {
        return;
    }

    m_firstFailedDecryptDiagnostic.valid = true;
    m_firstFailedDecryptDiagnostic.fileIndex = fileIndex;
    m_firstFailedDecryptDiagnostic.inputSize = inputSize;
    m_firstFailedDecryptDiagnostic.failureCode = failureCode;
    m_firstFailedDecryptDiagnostic.fileInfo = fileInfo;
    m_firstFailedDecryptDiagnostic.candidates = probeRecords;
}

void Unpacker::RecordFailedFile(size_t index, const FileInfo& fileInfo, int errorCode) {
    FailedFileRecord record;
    record.fileIndex = static_cast<uint32_t>(index);
    record.pathCRC32 = fileInfo.m_PathFileNameCRC32;
    record.packIndex = fileInfo.m_PackIndex;
    record.errorCode = errorCode;
    record.mappingHit = (m_pathMapping.find(fileInfo.m_PathFileNameCRC32) != m_pathMapping.end());

    std::lock_guard<std::mutex> lock(m_failedFilesMutex);
    m_lastFailedFiles.push_back(record);
}

void Unpacker::UpdatePathMappingStats() {
    ResetPathMappingStats();
    if (m_fileList.empty() || m_pathMapping.empty()) {
        return;
    }

    size_t total = m_fileList.size();
    size_t hit = 0;
    m_pathMappingMissingSamples.reserve(5);

    for (size_t i = 0; i < total; i++) {
        uint32_t crc32 = m_fileList[i].m_PathFileNameCRC32;
        if (m_pathMapping.find(crc32) != m_pathMapping.end()) {
            hit++;
        } else if (m_pathMappingMissingSamples.size() < 5) {
            m_pathMappingMissingSamples.push_back(crc32);
        }
    }

    m_pathMappingHitCount = static_cast<uint32_t>(hit);
    m_pathMappingMissCount = static_cast<uint32_t>(total - hit);
    m_pathMappingRateBasis = (total == 0) ? 0 : static_cast<uint32_t>(hit * 10000 / total);
    m_pathMappingStatsValid = true;
}

void Unpacker::ResetStreamStats() {
    m_streamConsidered.store(0);
    m_streamUsed.store(0);
    m_streamFallback.store(0);
    m_streamSkipCompressed.store(0);
    m_streamSkipEncryptedUnaligned.store(0);
}

void Unpacker::ResetOutputPathAudit() {
    std::lock_guard<std::mutex> lock(m_outputPathMutex);
    m_reservedOutputPaths.clear();
    m_outputPathAuditRecords.clear();
}

void Unpacker::ReportStreamStats(const std::wstring& context) const {
    if (!m_options.useStreamMode) {
        return;
    }

    uint32_t considered = m_streamConsidered.load();
    uint32_t used = m_streamUsed.load();
    uint32_t fallback = m_streamFallback.load();
    uint32_t skipCompressed = m_streamSkipCompressed.load();
    uint32_t skipEncryptedUnaligned = m_streamSkipEncryptedUnaligned.load();

    std::wostringstream oss;
    oss << L"Stream mode stats (" << context << L"): "
        << L"considered=" << considered
        << L", used=" << used
        << L", fallback=" << fallback
        << L", skip(compressed)=" << skipCompressed
        << L", skip(unaligned)=" << skipEncryptedUnaligned;
    LJFP_LOG_INFO(oss.str());
}

// ============================================================================
// 路径恢复功能
// ============================================================================

static std::string TrimString(const std::string& s) {
    size_t start = s.find_first_not_of(" \t\r\n");
    if (start == std::string::npos) {
        return "";
    }
    size_t end = s.find_last_not_of(" \t\r\n");
    std::string trimmed = s.substr(start, end - start + 1);
    if (trimmed.size() >= 3 &&
        static_cast<unsigned char>(trimmed[0]) == 0xEF &&
        static_cast<unsigned char>(trimmed[1]) == 0xBB &&
        static_cast<unsigned char>(trimmed[2]) == 0xBF) {
        trimmed.erase(0, 3);
    }
    return trimmed;
}

static bool ParseCrc32Token(const std::string& token, uint32_t& outCrc) {
    std::string t = TrimString(token);
    if (t.empty()) {
        return false;
    }

    int base = 10;
    if (t.size() > 2 && t[0] == '0' && (t[1] == 'x' || t[1] == 'X')) {
        base = 16;
    } else {
        for (char c : t) {
            if (std::isxdigit(static_cast<unsigned char>(c)) && !std::isdigit(static_cast<unsigned char>(c))) {
                base = 16;
                break;
            }
        }
    }

    try {
        size_t idx = 0;
        unsigned long value = std::stoul(t, &idx, base);
        if (idx != t.size()) {
            return false;
        }
        outCrc = static_cast<uint32_t>(value);
        return true;
    } catch (...) {
        return false;
    }
}

int Unpacker::LoadPathMapping(const std::string& mapPath) {
    LJFP_LOG_INFO(L"Loading path mapping file: " + MultiByteToWideBestEffort(mapPath));

    // 检查是否为二进制格式 (.ljpm)
    if (mapPath.size() >= 5 && mapPath.substr(mapPath.size() - 5) == ".ljpm") {
        return LoadPathMappingBinary(mapPath);
    }

    // 尝试检测文件头是否为二进制格式
    std::ifstream testFs(mapPath, std::ios::binary);
    if (testFs.is_open()) {
        uint32_t magic = 0;
        testFs.read(reinterpret_cast<char*>(&magic), 4);
        testFs.close();
        if (magic == 0x4D504A4C) {  // "LJPM"
            return LoadPathMappingBinary(mapPath);
        }
    }

    std::ifstream fs(mapPath.c_str(), std::ios::binary);
    if (!fs.is_open()) {
        LJFP_LOG_WARNING(L"Path mapping file not found, will use CRC32 as filename");
        return LJFP_ERROR_FILE_NOT_FOUND;
    }

    m_pathMapping.clear();
    {
        std::lock_guard<std::mutex> lock(m_outputPathMutex);
        m_pathMappingAudit.clear();
    }
    ResetPathMappingStats();
    std::string line;
    int count = 0;
    int invalidLines = 0;
    int sanitizedLines = 0;

    while (std::getline(fs, line)) {
        line = TrimString(line);
        // 跳过空行和注释
        if (line.empty() || line[0] == '#' || (line.size() >= 2 && line[0] == '/' && line[1] == '/')) {
            continue;
        }

        // 支持格式:
        // 1) CRC32|原始路径 (十进制)
        // 2) 0xCRC32<TAB>原始路径 (十六进制)
        size_t delimPos = line.find('|');
        if (delimPos == std::string::npos) {
            delimPos = line.find_first_of(" \t");
        }
        if (delimPos == std::string::npos) {
            invalidLines++;
            continue;
        }

        try {
            std::string crcToken = TrimString(line.substr(0, delimPos));
            std::string path = TrimString(line.substr(delimPos + 1));
            if (crcToken.empty() || path.empty()) {
                invalidLines++;
                continue;
            }

            uint32_t crc32 = 0;
            if (!ParseCrc32Token(crcToken, crc32)) {
                invalidLines++;
                continue;
            }

            bool pathChanged = false;
            std::string safePath = NormalizeOutputRelativePath(path, &pathChanged);
            if (safePath.empty()) {
                invalidLines++;
                continue;
            }

            if (pathChanged) {
                sanitizedLines++;
            }

            m_pathMapping[crc32] = safePath;
            {
                std::lock_guard<std::mutex> lock(m_outputPathMutex);
                PathMappingAuditInfo& audit = m_pathMappingAudit[crc32];
                audit.rawPath = path;
                audit.normalizedPath = safePath;
                audit.sanitized = pathChanged;
            }
            count++;
        } catch (...) {
            invalidLines++;
            LJFP_LOG_WARNING(L"Invalid line in path mapping file");
        }
    }

    fs.close();
    LJFP_LOG_INFO(L"Loaded " + std::to_wstring(count) + L" path mappings");
    if (invalidLines > 0) {
        LJFP_LOG_WARNING(L"Ignored invalid mapping lines: " + std::to_wstring(invalidLines));
    }
    if (sanitizedLines > 0) {
        LJFP_LOG_WARNING(L"Sanitized mapping paths: " + std::to_wstring(sanitizedLines));
    }

    if (count == 0) {
        LJFP_LOG_WARNING(L"No valid path mappings parsed");
        return LJFP_ERROR_INVALID_INDEX;
    }

    UpdatePathMappingStats();
    if (m_pathMappingStatsValid) {
        ReportPathMappingHitRate(L"after LoadPathMapping");
    }

    return LJFP_SUCCESS;
}

int Unpacker::LoadPathMappingBinary(const std::string& ljpmPath) {
    LJFP_LOG_INFO(L"Loading binary path mapping file: " + MultiByteToWideBestEffort(ljpmPath));

    std::ifstream fs(ljpmPath, std::ios::binary);
    if (!fs.is_open()) {
        LJFP_LOG_ERROR(L"Binary mapping file not found");
        return LJFP_ERROR_FILE_NOT_FOUND;
    }

    // 读取魔数
    uint32_t magic = 0;
    if (!fs.read(reinterpret_cast<char*>(&magic), 4)) {
        LJFP_LOG_ERROR(L"Failed to read binary mapping magic number");
        fs.close();
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }
    if (magic != 0x4D504A4C) {  // "LJPM"
        LJFP_LOG_ERROR(L"Invalid binary mapping file magic number");
        fs.close();
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    // 读取版本
    uint32_t version = 0;
    if (!fs.read(reinterpret_cast<char*>(&version), 4)) {
        LJFP_LOG_ERROR(L"Failed to read binary mapping version");
        fs.close();
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }
    if (version != 1) {
        LJFP_LOG_WARNING(L"Unsupported binary mapping version: " + std::to_wstring(version));
        // 继续尝试解析
    }

    // 读取条目数量
    uint32_t count = 0;
    if (!fs.read(reinterpret_cast<char*>(&count), 4)) {
        LJFP_LOG_ERROR(L"Failed to read binary mapping entry count");
        fs.close();
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    LJFP_LOG_INFO(L"Binary mapping entries: " + std::to_wstring(count));

    m_pathMapping.clear();
    {
        std::lock_guard<std::mutex> lock(m_outputPathMutex);
        m_pathMappingAudit.clear();
    }
    int loadedCount = 0;
    int sanitizedCount = 0;

    // 读取每条记录
    for (uint32_t i = 0; i < count; i++) {
        // CRC32
        uint32_t crc32 = 0;
        if (!fs.read(reinterpret_cast<char*>(&crc32), 4)) {
            LJFP_LOG_WARNING(L"Failed to read CRC32 at entry " + std::to_wstring(i));
            break;
        }

        // 路径长度
        uint16_t pathLen = 0;
        if (!fs.read(reinterpret_cast<char*>(&pathLen), 2)) {
            LJFP_LOG_WARNING(L"Failed to read path length at entry " + std::to_wstring(i));
            break;
        }

        if (pathLen == 0) {
            LJFP_LOG_WARNING(L"Empty path at binary mapping entry " + std::to_wstring(i));
            continue;
        }
        if (pathLen >= 4096) {
            LJFP_LOG_ERROR(L"Binary mapping path length too large at entry " + std::to_wstring(i) +
                           L": " + std::to_wstring(pathLen));
            fs.close();
            return LJFP_ERROR_INDEX_INVALID_FORMAT;
        }

        // 路径字符串
        std::vector<char> pathBuffer(pathLen + 1, '\0');
        if (!fs.read(pathBuffer.data(), pathLen)) {
            LJFP_LOG_WARNING(L"Failed to read path at entry " + std::to_wstring(i));
            fs.close();
            return LJFP_ERROR_INDEX_INVALID_FORMAT;
        }
        std::string path(pathBuffer.data(), pathLen);
        bool pathChanged = false;
        std::string safePath = NormalizeOutputRelativePath(path, &pathChanged);
        if (safePath.empty()) {
            continue;
        }
        if (pathChanged) {
            sanitizedCount++;
        }
        m_pathMapping[crc32] = safePath;
        {
            std::lock_guard<std::mutex> lock(m_outputPathMutex);
            PathMappingAuditInfo& audit = m_pathMappingAudit[crc32];
            audit.rawPath = path;
            audit.normalizedPath = safePath;
            audit.sanitized = pathChanged;
        }
        loadedCount++;
    }

    fs.close();
    LJFP_LOG_INFO(L"Loaded " + std::to_wstring(loadedCount) + L" path mappings from binary file");
    if (sanitizedCount > 0) {
        LJFP_LOG_WARNING(L"Sanitized binary mapping paths: " + std::to_wstring(sanitizedCount));
    }

    if (loadedCount == 0) {
        LJFP_LOG_WARNING(L"No valid path mappings in binary file");
        return LJFP_ERROR_INVALID_INDEX;
    }

    UpdatePathMappingStats();
    if (m_pathMappingStatsValid) {
        ReportPathMappingHitRate(L"after LoadPathMapping");
    }

    return LJFP_SUCCESS;
}

std::string Unpacker::GetDecryptKey() const {
    if (!m_customDecryptKey.empty()) {
        return m_customDecryptKey;
    }
    if (!m_options.decryptKey.empty()) {
        return m_options.decryptKey;
    }
    return std::string(DEFAULT_DECRYPT_KEY);
}

void Unpacker::BuildDecryptModeCandidates(std::vector<DecryptMode>& outModes) const {
    outModes.clear();
    switch (m_options.decryptMode) {
        case DecryptMode::LJFilePackSMS4:
            outModes.push_back(DecryptMode::LJFilePackSMS4);
            break;
        case DecryptMode::ApkClientObf:
            outModes.push_back(DecryptMode::ApkClientObf);
            break;
        case DecryptMode::Auto:
        default:
            outModes.push_back(DecryptMode::LJFilePackSMS4);
            outModes.push_back(DecryptMode::ApkClientObf);
            break;
    }
}

void Unpacker::DecryptBufferForMode(const unsigned char* inputData,
                                    unsigned char* outputData,
                                    uint32_t dataSize,
                                    DecryptMode mode,
                                    uint32_t fileOffset,
                                    uint32_t decryptWindowBytes,
                                    const std::string& candidateId) const {
    if (dataSize == 0 || inputData == nullptr || outputData == nullptr) {
        return;
    }

    std::memcpy(outputData, inputData, dataSize);

    const uint32_t decryptWindow =
        (decryptWindowBytes == 0u) ? kDefaultDecryptWindowBytes : decryptWindowBytes;

    if (decryptWindow != kFullDecryptWindowBytes && fileOffset >= decryptWindow) {
        return;
    }

    const uint32_t bytesInsideWindow =
        (decryptWindow == kFullDecryptWindowBytes)
        ? dataSize
        : std::min(dataSize, decryptWindow - fileOffset);
    const uint32_t decryptBytes = (bytesInsideWindow / 16u) * 16u;
    if (decryptBytes == 0) {
        return;
    }

    unsigned char* outSpan = outputData;
    unsigned char* inSpan = outputData;
    const std::string key = GetDecryptKey();

    if (candidateId.find("clientkeyed") == 0) {
        SLJFP_DeSMS4BlocksClientKeyed(inSpan, outSpan, decryptBytes, key);
        return;
    }

    switch (mode) {
    case DecryptMode::ApkClientObf:
        SLJFP_DeSMS4BlocksClientObf(inSpan, outSpan, decryptBytes, key);
        break;
    case DecryptMode::LJFilePackSMS4:
    case DecryptMode::Auto:
    default:
        SLJFP_DeSMS4BlocksLegacy(inSpan, outSpan, decryptBytes, key);
        break;
    }
}

int Unpacker::FindFileByCRC32(uint32_t pathCRC32) const {
    for (size_t i = 0; i < m_fileList.size(); i++) {
        if (m_fileList[i].m_PathFileNameCRC32 == pathCRC32) {
            return static_cast<int>(i);
        }
    }
    return -1;
}

std::string Unpacker::GetFilePath(size_t index) const {
    if (index >= m_fileList.size()) {
        return "";
    }

    uint32_t crc32 = m_fileList[index].m_PathFileNameCRC32;

    // 先查找路径映射表
    auto it = m_pathMapping.find(crc32);
    if (it != m_pathMapping.end()) {
        return it->second;
    }

    // 没有映射，返回 CRC32 字符串
    return std::to_string(crc32);
}

int Unpacker::ReadDecodedFileSample(size_t index,
                                    size_t maxBytes,
                                    std::vector<unsigned char>& outData,
                                    std::string* outLogicalPath) {
    outData.clear();
    if (outLogicalPath != NULL) {
        outLogicalPath->clear();
    }

    if (index >= m_fileList.size()) {
        return LJFP_ERROR_INVALID_INDEX;
    }

    if (outLogicalPath != NULL) {
        *outLogicalPath = GetFilePath(index);
    }

    const FileInfo& fileInfo = m_fileList[index];
    std::vector<unsigned char> packedData;
    int result = ReadFileData(fileInfo, packedData);
    if (result != LJFP_SUCCESS) {
        return result;
    }

    result = DecryptAndDecompress(
        packedData.empty() ? NULL : &packedData[0],
        static_cast<uint32_t>(packedData.size()),
        outData,
        fileInfo.m_CodeType > 0,
        fileInfo.m_CompressType > 0,
        fileInfo.m_SizeOriginal,
        fileInfo.m_CRC32Original,
        NULL);
    if (result != LJFP_SUCCESS) {
        outData.clear();
        return result;
    }

    if (maxBytes > 0 && outData.size() > maxBytes) {
        outData.resize(maxBytes);
    }

    return LJFP_SUCCESS;
}

bool Unpacker::GetPathMappingHitRate(uint32_t& hitCount, uint32_t& totalCount, uint32_t& rateBasis) const {
    if (!m_pathMappingStatsValid) {
        const_cast<Unpacker*>(this)->UpdatePathMappingStats();
    }

    totalCount = static_cast<uint32_t>(m_fileList.size());
    if (!m_pathMappingStatsValid || totalCount == 0 || m_pathMapping.empty()) {
        hitCount = 0;
        rateBasis = 0;
        return false;
    }

    hitCount = m_pathMappingHitCount;
    rateBasis = m_pathMappingRateBasis;
    return true;
}

std::vector<uint32_t> Unpacker::GetPathMappingMissingSamples() const {
    if (!m_pathMappingStatsValid) {
        const_cast<Unpacker*>(this)->UpdatePathMappingStats();
    }
    return m_pathMappingMissingSamples;
}

bool Unpacker::HasPathMappingForFile(size_t index) const {
    if (index >= m_fileList.size()) {
        return false;
    }

    return m_pathMapping.find(m_fileList[index].m_PathFileNameCRC32) != m_pathMapping.end();
}

// ============================================================================
// 私有方法实现
// ============================================================================

int Unpacker::LoadLjpiIndex(const std::string& ljpiPath) {
    LJFP_LOG_INFO(L"Loading .ljpi index file...");

    detail::IndexLoadResult indexResult;
    int result = detail::LoadLjpiIndexData(ljpiPath, indexResult);
    if (result != LJFP_SUCCESS) {
        return result;
    }

    m_fileList.swap(indexResult.fileList);
    m_totalFiles = static_cast<uint32_t>(m_fileList.size());
    m_totalBytes = indexResult.totalBytes;
    m_processedFiles = 0;
    m_failedFiles = 0;
    m_processedBytes = 0;
    ResetRunDiagnostics();
    ResetOutputPathAudit();
    ResetPathMappingStats();
    m_inputDir = NormalizeSlashesCopy(detail::GetParentDirectory(ljpiPath));

    LJFP_LOG_INFO(L"Successfully loaded " + std::to_wstring(m_totalFiles) + L" file entries");

    UpdatePathMappingStats();
    if (m_pathMappingStatsValid) {
        ReportPathMappingHitRate(L"after LoadIndex");
    }

    return LJFP_SUCCESS;
}

int Unpacker::LoadLjzipIndex(const std::string& ljzipPath) {
    LJFP_LOG_INFO(L"Loading .ljzip encrypted index file...");

    detail::IndexLoadDependencies deps;
    deps.crc32Func = m_crc32Func;
    deps.unzipFunc = m_unzipFunc;
    deps.desms4Func = m_desms4Func;
    deps.decryptKey = GetDecryptKey();
    deps.verifyCRC32 = m_options.verifyCRC32;

    detail::IndexLoadResult indexResult;
    int result = detail::LoadLjzipIndexData(ljzipPath, deps, indexResult);
    if (result != LJFP_SUCCESS) {
        return result;
    }

    m_fileList.swap(indexResult.fileList);
    m_totalFiles = static_cast<uint32_t>(m_fileList.size());
    m_totalBytes = indexResult.totalBytes;
    m_processedFiles = 0;
    m_failedFiles = 0;
    m_processedBytes = 0;
    ResetRunDiagnostics();
    ResetOutputPathAudit();
    ResetPathMappingStats();
    m_inputDir = NormalizeSlashesCopy(detail::GetParentDirectory(ljzipPath));

    LJFP_LOG_INFO(L"Successfully parsed " + std::to_wstring(m_totalFiles) + L" file entries");

    UpdatePathMappingStats();
    if (m_pathMappingStatsValid) {
        ReportPathMappingHitRate(L"after LoadIndex");
    }

    return LJFP_SUCCESS;
}

int Unpacker::ParseLjpiData(const unsigned char* data, uint32_t size) {
    detail::IndexLoadResult indexResult;
    int result = detail::ParseLjpiBuffer(data, size, indexResult);
    if (result != LJFP_SUCCESS) {
        return result;
    }

    m_fileList.swap(indexResult.fileList);
    m_totalFiles = static_cast<uint32_t>(m_fileList.size());
    m_totalBytes = indexResult.totalBytes;
    m_processedFiles = 0;
    m_failedFiles = 0;
    m_processedBytes = 0;
    ResetRunDiagnostics();
    ResetOutputPathAudit();
    ResetPathMappingStats();

    LJFP_LOG_INFO(L"Successfully parsed " + std::to_wstring(m_totalFiles) + L" file entries");

    UpdatePathMappingStats();
    if (m_pathMappingStatsValid) {
        ReportPathMappingHitRate(L"after LoadIndex");
    }

    return LJFP_SUCCESS;
}

int Unpacker::UnpackSingleFile(FileInfo& fileInfo, size_t index, const std::string& customOutputPath) {
    if (m_options.useStreamMode) {
        m_streamConsidered.fetch_add(1);
        if (fileInfo.m_CodeType > 0 && (fileInfo.m_Size % 16 != 0)) {
            m_streamSkipEncryptedUnaligned.fetch_add(1);
        } else {
            int streamError = LJFP_SUCCESS;
            bool streamHandled = false;
            if (fileInfo.m_CompressType > 0) {
                streamHandled = UnpackSingleFileStreamCompressed(fileInfo, index, customOutputPath, streamError);
            } else {
                streamHandled = UnpackSingleFileStream(fileInfo, index, customOutputPath, streamError);
            }
            if (streamHandled) {
                m_streamUsed.fetch_add(1);
                return streamError;
            }
            m_streamFallback.fetch_add(1);
        }
    }

    // 读取文件数据
    std::vector<unsigned char> encryptedData;
    int readResult = ReadFileData(fileInfo, encryptedData);
    if (readResult != LJFP_SUCCESS) {
        LJFP_LOG_ERROR(L"Failed to read file data for file #" + std::to_wstring(index));
        return readResult;
    }
    const uint32_t encryptedSize = static_cast<uint32_t>(encryptedData.size());

    // 解密解压
    std::vector<unsigned char> decryptedData;
    std::vector<DecryptProbeRecord> probeRecords;

    int decryptResult = DecryptAndDecompress(
        encryptedData.data(), encryptedSize,
        decryptedData,
        fileInfo.m_CodeType > 0,
        fileInfo.m_CompressType > 0,
        fileInfo.m_SizeOriginal,
        fileInfo.m_CRC32Original,
        &probeRecords
    );

    if (decryptResult != LJFP_SUCCESS) {
        LJFP_LOG_ERROR(L"Failed to decrypt/decompress file #" + std::to_wstring(index));
        CaptureFirstFailedDecryptDiagnostic(static_cast<uint32_t>(index),
                                           fileInfo,
                                           encryptedSize,
                                           decryptResult,
                                           probeRecords);
        return decryptResult;
    }

    // CRC32 校验
    if (m_options.verifyCRC32) {
        uint32_t expectedCRC32 = fileInfo.m_CRC32Original;
        const unsigned char* decryptedBytes =
            decryptedData.empty() ? nullptr : &decryptedData[0];
        uint32_t actualCRC32 = m_crc32Func(0,
                                           decryptedBytes,
                                           static_cast<uint32_t>(decryptedData.size()));

        if (actualCRC32 != expectedCRC32) {
            LJFP_LOG_ERROR(L"CRC32 mismatch for file #" + std::to_wstring(index) +
                           L", expected=" + std::to_wstring(expectedCRC32) +
                           L", actual=" + std::to_wstring(actualCRC32));
            CaptureFirstFailedDecryptDiagnostic(static_cast<uint32_t>(index),
                                               fileInfo,
                                               encryptedSize,
                                               LJFP_ERROR_CRC32_MISMATCH,
                                               probeRecords);
            return LJFP_ERROR_CRC32_MISMATCH;
        }
    }

    // 构建输出路径 (使用解密后的数据进行文件类型检测)
    std::string outputPath;
    const unsigned char* decryptedBytes =
        decryptedData.empty() ? nullptr : &decryptedData[0];
    int resolvePathResult = ResolveOutputPathForWrite(fileInfo,
                                                      customOutputPath,
                                                      decryptedBytes,
                                                      static_cast<uint32_t>(decryptedData.size()),
                                                      outputPath);
    if (resolvePathResult != LJFP_SUCCESS) {
        return resolvePathResult;
    }

    // 创建目录
    std::string dirPath = GetDirectoryPath(outputPath);
    if (!dirPath.empty()) {
        CreateDirectoryRecursive(dirPath);
    }

    // 写入文件
    std::ofstream outFile;
    if (!OpenBinaryOutputFile(outFile, outputPath)) {
        LJFP_LOG_ERROR(L"Failed to create output file: " + MultiByteToWideBestEffort(outputPath));
        return LJFP_ERROR_FILE_CREATE_FAILED;
    }

    if (!decryptedData.empty()) {
        outFile.write(reinterpret_cast<const char*>(&decryptedData[0]),
                      static_cast<std::streamsize>(decryptedData.size()));
    }
    outFile.close();

    LJFP_LOG_DEBUG(L"Successfully unpacked file #" + std::to_wstring(index) +
                   L" to " + MultiByteToWideBestEffort(outputPath));

    return LJFP_SUCCESS;
}

bool Unpacker::UnpackSingleFileStream(FileInfo& fileInfo, size_t index, const std::string& customOutputPath, int& outError) {
    outError = LJFP_SUCCESS;

    // 流式解包只支持未压缩数据
    if (fileInfo.m_CompressType > 0) {
        return false;
    }

    const bool needDecrypt = (fileInfo.m_CodeType > 0);
    const uint32_t totalSize = fileInfo.m_Size;

    uint32_t chunkSize = m_options.streamChunkSize;
    if (chunkSize == 0) {
        chunkSize = 4 * 1024 * 1024;
    }

    if (needDecrypt) {
        if (m_options.decryptMode == DecryptMode::Auto) {
            LJFP_LOG_INFO(L"Stream mode fallback: auto decrypt candidate selection requires non-stream path");
            return false;
        }
        if (totalSize % 16 != 0) {
            // 加密块大小不对齐，回退到非流式处理
            return false;
        }
        if (chunkSize < 16) {
            chunkSize = 16;
        }
        chunkSize = (chunkSize / 16) * 16;
        if (chunkSize == 0) {
            chunkSize = 16;
        }
    }

    // 打开源文件
    std::ifstream fs;
    std::string srcFile;
    outError = detail::OpenSourceFileStream(m_inputDir, fileInfo, fs, srcFile);
    if (outError != LJFP_SUCCESS) {
        LJFP_LOG_ERROR(L"Failed to open source file for streaming: " +
                       MultiByteToWideBestEffort(srcFile));
        return true;
    }

    std::vector<unsigned char> inBuf;
    std::vector<unsigned char> outBuf;
    inBuf.resize(chunkSize);
    if (needDecrypt) {
        outBuf.resize(chunkSize);
    }

    std::string outputPath = customOutputPath;
    bool outputReady = false;
    std::ofstream outFile;
    std::string decryptKey;
    if (needDecrypt) {
        decryptKey = GetDecryptKey();
    }

    auto cleanupPartialOutput = [&]() {
        if (outFile.is_open()) {
            outFile.close();
        }
        if (outputReady && !outputPath.empty()) {
            DeleteFilePath(outputPath);
        }
    };

    if (!outputPath.empty()) {
        std::string resolvedPath;
        if (ResolveOutputPathForWrite(fileInfo, outputPath, nullptr, 0, resolvedPath) != LJFP_SUCCESS) {
            fs.close();
            outError = LJFP_ERROR_FILE_CREATE_FAILED;
            return true;
        }
        outputPath = resolvedPath;
    }

    if (outputPath.empty()) {
        bool canPrecomputePath = false;
        if (m_options.preferPathMapping) {
            if (m_pathMapping.find(fileInfo.m_PathFileNameCRC32) != m_pathMapping.end()) {
                canPrecomputePath = true;
            }
        }
        if (!m_options.detectFileType) {
            canPrecomputePath = true;
        }

        if (canPrecomputePath) {
            if (ResolveOutputPathForWrite(fileInfo, "", nullptr, 0, outputPath) != LJFP_SUCCESS) {
                fs.close();
                outError = LJFP_ERROR_FILE_CREATE_FAILED;
                return true;
            }
        }
    }

    if (!outputPath.empty()) {
        std::string dirPath = GetDirectoryPath(outputPath);
        if (!dirPath.empty()) {
            CreateDirectoryRecursive(dirPath);
        }

        if (!OpenBinaryOutputFile(outFile, outputPath)) {
            fs.close();
            LJFP_LOG_ERROR(L"Failed to create output file (stream mode): " +
                           MultiByteToWideBestEffort(outputPath));
            outError = LJFP_ERROR_FILE_CREATE_FAILED;
            return true;
        }
        outputReady = true;
    }

    uint32_t remaining = totalSize;
    uint32_t crc32 = 0;
    uint32_t fileOffset = 0;

    while (remaining > 0) {
        if (!WaitIfPaused()) {
            fs.close();
            cleanupPartialOutput();
            outError = LJFP_ERROR_USER_CANCELLED;
            return true;
        }

        uint32_t readSize = (remaining > chunkSize) ? chunkSize : remaining;
        if (readSize == 0) {
            break;
        }

        fs.read((char*)inBuf.data(), readSize);
        if (fs.fail()) {
            fs.close();
            cleanupPartialOutput();
            LJFP_LOG_ERROR(L"Failed to read stream data for file #" + std::to_wstring(index));
            outError = LJFP_ERROR_FILE_READ_FAILED;
            return true;
        }

        unsigned char* dataPtr = inBuf.data();
        uint32_t dataSize = readSize;

        if (needDecrypt) {
            if (readSize % 16 != 0) {
                fs.close();
                cleanupPartialOutput();
                LJFP_LOG_WARNING(L"Stream decrypt block not aligned, fallback required");
                return false;
            }
            DecryptBufferForMode(dataPtr, outBuf.data(), readSize, m_options.decryptMode, fileOffset);
            dataPtr = outBuf.data();
        }

        if (!outputReady) {
            if (outputPath.empty()) {
                if (ResolveOutputPathForWrite(fileInfo, "", dataPtr, dataSize, outputPath) != LJFP_SUCCESS) {
                    fs.close();
                    LJFP_LOG_ERROR(L"Failed to resolve output file path (stream mode)");
                    outError = LJFP_ERROR_FILE_CREATE_FAILED;
                    return true;
                }
            }

            std::string dirPath = GetDirectoryPath(outputPath);
            if (!dirPath.empty()) {
                CreateDirectoryRecursive(dirPath);
            }

            if (!OpenBinaryOutputFile(outFile, outputPath)) {
                fs.close();
                LJFP_LOG_ERROR(L"Failed to create output file (stream mode): " +
                               MultiByteToWideBestEffort(outputPath));
                outError = LJFP_ERROR_FILE_CREATE_FAILED;
                return true;
            }
            outputReady = true;
        }

        outFile.write((char*)dataPtr, dataSize);
        if (outFile.fail()) {
            fs.close();
            cleanupPartialOutput();
            LJFP_LOG_ERROR(L"Failed to write output file (stream mode): " +
                           MultiByteToWideBestEffort(outputPath));
            outError = LJFP_ERROR_FILE_WRITE_FAILED;
            return true;
        }

        if (m_options.verifyCRC32) {
            crc32 = m_crc32Func(crc32, dataPtr, dataSize);
        }

        remaining -= readSize;
        fileOffset += readSize;
    }

    fs.close();
    if (outFile.is_open()) {
        outFile.close();
    }

    if (m_options.verifyCRC32) {
        uint32_t expectedCRC32 = fileInfo.m_CRC32Original;
        if (crc32 != expectedCRC32) {
            LJFP_LOG_ERROR(L"CRC32 mismatch (stream mode) for file #" + std::to_wstring(index) +
                           L", expected=" + std::to_wstring(expectedCRC32) +
                           L", actual=" + std::to_wstring(crc32));
            outError = LJFP_ERROR_CRC32_MISMATCH;
            cleanupPartialOutput();
            return true;
        }
    }

    return true;
}

bool Unpacker::UnpackSingleFileStreamCompressed(FileInfo& fileInfo, size_t index, const std::string& customOutputPath, int& outError) {
    outError = LJFP_SUCCESS;

    if (fileInfo.m_CompressType == 0) {
        return false;
    }

    const bool needDecrypt = (fileInfo.m_CodeType > 0);
    const uint32_t totalSize = fileInfo.m_Size;

    uint32_t chunkSize = m_options.streamChunkSize;
    if (chunkSize == 0) {
        chunkSize = 4 * 1024 * 1024;
    }

    if (needDecrypt) {
        if (m_options.decryptMode == DecryptMode::Auto) {
            LJFP_LOG_INFO(L"Stream compressed fallback: auto decrypt candidate selection requires non-stream path");
            return false;
        }
        if (totalSize % 16 != 0) {
            // 加密块大小不对齐，回退到非流式处理
            return false;
        }
        if (chunkSize < 16) {
            chunkSize = 16;
        }
        chunkSize = (chunkSize / 16) * 16;
        if (chunkSize == 0) {
            chunkSize = 16;
        }
    }

    uint32_t outChunkSize = chunkSize;
    const uint32_t minOutChunk = 64 * 1024;
    const uint32_t maxOutChunk = 8 * 1024 * 1024;
    if (outChunkSize < minOutChunk) {
        outChunkSize = minOutChunk;
    } else if (outChunkSize > maxOutChunk) {
        outChunkSize = maxOutChunk;
    }

    // 打开源文件
    std::ifstream fs;
    std::string srcFile;
    outError = detail::OpenSourceFileStream(m_inputDir, fileInfo, fs, srcFile);
    if (outError != LJFP_SUCCESS) {
        LJFP_LOG_ERROR(L"Failed to open source file for streaming (compressed): " +
                       MultiByteToWideBestEffort(srcFile));
        return true;
    }

    std::vector<unsigned char> inBuf;
    std::vector<unsigned char> decryptBuf;
    std::vector<unsigned char> outBuf;
    inBuf.resize(chunkSize);
    if (needDecrypt) {
        decryptBuf.resize(chunkSize);
    }
    outBuf.resize(outChunkSize);

    std::string outputPath = customOutputPath;
    bool outputReady = false;
    std::ofstream outFile;

    std::string decryptKey;
    if (needDecrypt) {
        decryptKey = GetDecryptKey();
    }

    auto cleanupPartialOutput = [&]() {
        if (outFile.is_open()) {
            outFile.close();
        }
        if (outputReady && !outputPath.empty()) {
            DeleteFilePath(outputPath);
        }
    };

    if (!outputPath.empty()) {
        std::string resolvedPath;
        if (ResolveOutputPathForWrite(fileInfo, outputPath, nullptr, 0, resolvedPath) != LJFP_SUCCESS) {
            fs.close();
            outError = LJFP_ERROR_FILE_CREATE_FAILED;
            return true;
        }
        outputPath = resolvedPath;
    }

    if (outputPath.empty()) {
        bool canPrecomputePath = false;
        if (m_options.preferPathMapping) {
            if (m_pathMapping.find(fileInfo.m_PathFileNameCRC32) != m_pathMapping.end()) {
                canPrecomputePath = true;
            }
        }
        if (!m_options.detectFileType) {
            canPrecomputePath = true;
        }

        if (canPrecomputePath) {
            if (ResolveOutputPathForWrite(fileInfo, "", nullptr, 0, outputPath) != LJFP_SUCCESS) {
                fs.close();
                outError = LJFP_ERROR_FILE_CREATE_FAILED;
                return true;
            }
        }
    }

    if (!outputPath.empty()) {
        std::string dirPath = GetDirectoryPath(outputPath);
        if (!dirPath.empty()) {
            CreateDirectoryRecursive(dirPath);
        }

        if (!OpenBinaryOutputFile(outFile, outputPath)) {
            fs.close();
            LJFP_LOG_ERROR(L"Failed to create output file (stream compressed): " +
                           MultiByteToWideBestEffort(outputPath));
            outError = LJFP_ERROR_FILE_CREATE_FAILED;
            return true;
        }
        outputReady = true;
    }

    mz_stream stream;
    std::memset(&stream, 0, sizeof(stream));
    int initStatus = mz_inflateInit(&stream);
    if (initStatus != MZ_OK) {
        fs.close();
        cleanupPartialOutput();
        LJFP_LOG_WARNING(L"Stream compressed fallback: inflate init failed");
        return false;
    }

    uint32_t remaining = totalSize;
    uint64_t totalOut = 0;
    uint32_t crc32 = 0;
    bool streamDone = false;
    uint32_t fileOffset = 0;

    while (remaining > 0 && !streamDone) {
        if (!WaitIfPaused()) {
            fs.close();
            cleanupPartialOutput();
            mz_inflateEnd(&stream);
            outError = LJFP_ERROR_USER_CANCELLED;
            return true;
        }

        uint32_t readSize = (remaining > chunkSize) ? chunkSize : remaining;
        fs.read((char*)inBuf.data(), readSize);
        if (fs.fail()) {
            fs.close();
            cleanupPartialOutput();
            mz_inflateEnd(&stream);
            LJFP_LOG_ERROR(L"Failed to read stream data (compressed) for file #" + std::to_wstring(index));
            outError = LJFP_ERROR_FILE_READ_FAILED;
            return true;
        }

        unsigned char* dataPtr = inBuf.data();
        uint32_t dataSize = readSize;

        if (needDecrypt) {
            if (readSize % 16 != 0) {
                fs.close();
                mz_inflateEnd(&stream);
                cleanupPartialOutput();
                LJFP_LOG_WARNING(L"Stream compressed fallback: decrypt block not aligned");
                return false;
            }
            DecryptBufferForMode(dataPtr, decryptBuf.data(), readSize, m_options.decryptMode, fileOffset);
            dataPtr = decryptBuf.data();
        }

        stream.next_in = dataPtr;
        stream.avail_in = dataSize;

        while (stream.avail_in > 0) {
            if (!WaitIfPaused()) {
                fs.close();
                cleanupPartialOutput();
                mz_inflateEnd(&stream);
                outError = LJFP_ERROR_USER_CANCELLED;
                return true;
            }

            stream.next_out = outBuf.data();
            stream.avail_out = static_cast<mz_uint32>(outBuf.size());

            int status = mz_inflate(&stream, MZ_NO_FLUSH);
            size_t produced = outBuf.size() - stream.avail_out;

            if (produced > 0) {
                if (!outputReady) {
                    if (ResolveOutputPathForWrite(fileInfo,
                                                  "",
                                                  outBuf.data(),
                                                  static_cast<uint32_t>(produced),
                                                  outputPath) != LJFP_SUCCESS) {
                        fs.close();
                        mz_inflateEnd(&stream);
                        cleanupPartialOutput();
                        LJFP_LOG_ERROR(L"Failed to resolve output file path (stream compressed)");
                        outError = LJFP_ERROR_FILE_CREATE_FAILED;
                        return true;
                    }
                    std::string dirPath = GetDirectoryPath(outputPath);
                    if (!dirPath.empty()) {
                        CreateDirectoryRecursive(dirPath);
                    }
                    if (!OpenBinaryOutputFile(outFile, outputPath)) {
                        fs.close();
                        mz_inflateEnd(&stream);
                        cleanupPartialOutput();
                        LJFP_LOG_ERROR(L"Failed to create output file (stream compressed): " +
                                       MultiByteToWideBestEffort(outputPath));
                        outError = LJFP_ERROR_FILE_CREATE_FAILED;
                        return true;
                    }
                    outputReady = true;
                }

                outFile.write((char*)outBuf.data(), produced);
                if (outFile.fail()) {
                    fs.close();
                    cleanupPartialOutput();
                    mz_inflateEnd(&stream);
                    LJFP_LOG_ERROR(L"Failed to write output file (stream compressed): " +
                                   MultiByteToWideBestEffort(outputPath));
                    outError = LJFP_ERROR_FILE_WRITE_FAILED;
                    return true;
                }

                if (m_options.verifyCRC32) {
                    crc32 = m_crc32Func(crc32, outBuf.data(), static_cast<uint32_t>(produced));
                }

                totalOut += produced;
                if (fileInfo.m_SizeOriginal > 0 && totalOut > fileInfo.m_SizeOriginal) {
                    fs.close();
                    mz_inflateEnd(&stream);
                    cleanupPartialOutput();
                    LJFP_LOG_WARNING(L"Stream compressed fallback: output exceeds original size");
                    return false;
                }
            }

            if (status == MZ_STREAM_END) {
                streamDone = true;
                break;
            }
            if (status != MZ_OK && status != MZ_BUF_ERROR) {
                fs.close();
                mz_inflateEnd(&stream);
                cleanupPartialOutput();
                LJFP_LOG_WARNING(L"Stream compressed fallback: inflate error status=" +
                                 std::to_wstring(status));
                return false;
            }
            if (status == MZ_BUF_ERROR && produced == 0 && stream.avail_in > 0) {
                fs.close();
                mz_inflateEnd(&stream);
                cleanupPartialOutput();
                LJFP_LOG_WARNING(L"Stream compressed fallback: inflate stalled");
                return false;
            }
        }

        remaining -= readSize;
        fileOffset += readSize;
    }

    if (!streamDone) {
        for (;;) {
            if (!WaitIfPaused()) {
                cleanupPartialOutput();
                mz_inflateEnd(&stream);
                outError = LJFP_ERROR_USER_CANCELLED;
                return true;
            }

            stream.next_out = outBuf.data();
            stream.avail_out = static_cast<mz_uint32>(outBuf.size());

            int status = mz_inflate(&stream, MZ_FINISH);
            size_t produced = outBuf.size() - stream.avail_out;

            if (produced > 0) {
                if (!outputReady) {
                    if (ResolveOutputPathForWrite(fileInfo,
                                                  "",
                                                  outBuf.data(),
                                                  static_cast<uint32_t>(produced),
                                                  outputPath) != LJFP_SUCCESS) {
                        mz_inflateEnd(&stream);
                        cleanupPartialOutput();
                        LJFP_LOG_ERROR(L"Failed to resolve output file path (stream compressed)");
                        outError = LJFP_ERROR_FILE_CREATE_FAILED;
                        return true;
                    }
                    std::string dirPath = GetDirectoryPath(outputPath);
                    if (!dirPath.empty()) {
                        CreateDirectoryRecursive(dirPath);
                    }
                    if (!OpenBinaryOutputFile(outFile, outputPath)) {
                        mz_inflateEnd(&stream);
                        cleanupPartialOutput();
                        LJFP_LOG_ERROR(L"Failed to create output file (stream compressed): " +
                                       MultiByteToWideBestEffort(outputPath));
                        outError = LJFP_ERROR_FILE_CREATE_FAILED;
                        return true;
                    }
                    outputReady = true;
                }

                outFile.write((char*)outBuf.data(), produced);
                if (outFile.fail()) {
                    cleanupPartialOutput();
                    mz_inflateEnd(&stream);
                    LJFP_LOG_ERROR(L"Failed to write output file (stream compressed): " +
                                   MultiByteToWideBestEffort(outputPath));
                    outError = LJFP_ERROR_FILE_WRITE_FAILED;
                    return true;
                }

                if (m_options.verifyCRC32) {
                    crc32 = m_crc32Func(crc32, outBuf.data(), static_cast<uint32_t>(produced));
                }

                totalOut += produced;
            }

            if (status == MZ_STREAM_END) {
                streamDone = true;
                break;
            }
            if (status != MZ_OK && status != MZ_BUF_ERROR) {
                mz_inflateEnd(&stream);
                cleanupPartialOutput();
                LJFP_LOG_WARNING(L"Stream compressed fallback: inflate finish error status=" +
                                 std::to_wstring(status));
                return false;
            }
            if (status == MZ_BUF_ERROR && produced == 0) {
                break;
            }
        }
    }

    fs.close();
    if (outFile.is_open()) {
        outFile.close();
    }

    mz_inflateEnd(&stream);

    if (!streamDone) {
        cleanupPartialOutput();
        LJFP_LOG_WARNING(L"Stream compressed fallback: stream not completed");
        return false;
    }

    if (!outputReady) {
        if (fileInfo.m_SizeOriginal == 0) {
            if (outputPath.empty()) {
                if (ResolveOutputPathForWrite(fileInfo, "", nullptr, 0, outputPath) != LJFP_SUCCESS) {
                    LJFP_LOG_ERROR(L"Failed to resolve output file path (stream compressed empty file)");
                    outError = LJFP_ERROR_FILE_CREATE_FAILED;
                    return true;
                }
            }
            if (!outputPath.empty()) {
                std::string dirPath = GetDirectoryPath(outputPath);
                if (!dirPath.empty()) {
                    CreateDirectoryRecursive(dirPath);
                }
                std::ofstream emptyFile;
                if (!OpenBinaryOutputFile(emptyFile, outputPath)) {
                    LJFP_LOG_ERROR(L"Failed to create empty output file (stream compressed): " +
                                   MultiByteToWideBestEffort(outputPath));
                    outError = LJFP_ERROR_FILE_CREATE_FAILED;
                    return true;
                }
                emptyFile.close();
            }
        } else {
            cleanupPartialOutput();
            LJFP_LOG_WARNING(L"Stream compressed fallback: no output produced");
            return false;
        }
    }

    if (fileInfo.m_SizeOriginal > 0 && totalOut != fileInfo.m_SizeOriginal) {
        cleanupPartialOutput();
        LJFP_LOG_WARNING(L"Stream compressed fallback: output size mismatch");
        return false;
    }

    if (m_options.verifyCRC32) {
        uint32_t expectedCRC32 = fileInfo.m_CRC32Original;
        if (crc32 != expectedCRC32) {
            LJFP_LOG_ERROR(L"CRC32 mismatch (stream compressed) for file #" + std::to_wstring(index) +
                           L", expected=" + std::to_wstring(expectedCRC32) +
                           L", actual=" + std::to_wstring(crc32));
            outError = LJFP_ERROR_CRC32_MISMATCH;
            cleanupPartialOutput();
            return true;
        }
    }

    return true;
}

int Unpacker::ReadFileData(const FileInfo& fileInfo, std::vector<unsigned char>& outputData) {
    int readResult = detail::ReadSourceFileData(m_inputDir, fileInfo, outputData);
    if (readResult != LJFP_SUCCESS) {
        const std::string sourcePath = detail::BuildSourceFilePath(m_inputDir, fileInfo);
        if (fileInfo.m_PackIndex == 0) {
            LJFP_LOG_ERROR(L"Failed to open loose file: " + MultiByteToWideBestEffort(sourcePath));
        } else {
            LJFP_LOG_ERROR(L"Failed to read pack file: " + MultiByteToWideBestEffort(sourcePath) +
                           L" (PackIndex=" + std::to_wstring(fileInfo.m_PackIndex) + L")");
        }
    }
    return readResult;
}

int Unpacker::DecryptAndDecompress(
    const unsigned char* inputData, uint32_t inputSize,
    std::vector<unsigned char>& outputData,
    bool needDecrypt, bool needDecompress, uint32_t originalSize, uint32_t expectedCRC32,
    std::vector<DecryptProbeRecord>* probeRecordsOut)
{
    outputData.clear();

    std::vector<DecryptCandidateSpec> candidateSpecs;
    BuildDecryptProbeCandidates(inputData,
                                inputSize,
                                needDecrypt,
                                needDecompress,
                                m_options,
                                candidateSpecs);

    std::vector<DecryptProbeRecord> probeRecords;
    probeRecords.reserve(candidateSpecs.size());

    const bool shouldCheckCandidateCrc =
        m_options.verifyCRC32 && expectedCRC32 != 0;
    const bool autoSelectingCandidate =
        needDecrypt &&
        m_options.decryptMode == DecryptMode::Auto &&
        candidateSpecs.size() > 1 &&
        shouldCheckCandidateCrc;
    int lastError = LJFP_SUCCESS;

    for (size_t modeIndex = 0; modeIndex < candidateSpecs.size(); ++modeIndex) {
        const DecryptCandidateSpec& spec = candidateSpecs[modeIndex];
        const unsigned char* tempData = inputData;
        uint32_t tempSize = inputSize;
        std::vector<unsigned char> transformedBuffer;

        DecryptProbeRecord record;
        record.candidateId = spec.candidateId;
        record.mode = spec.mode;
        record.applyDecrypt = spec.applyDecrypt;
        record.useFullWindow = spec.useFullWindow;
        record.needDecompress = needDecompress;
        record.inputSize = inputSize;
        record.expectedCRC32 = expectedCRC32;
        record.inputSignature = DescribeBufferSignature(inputData, inputSize);
        record.inputPrefixHex = FormatHexPrefix(inputData, inputSize, 32);

        if (spec.applyDecrypt) {
            transformedBuffer.resize(tempSize);
            if (!transformedBuffer.empty()) {
                DecryptBufferForMode(inputData,
                                     &transformedBuffer[0],
                                     tempSize,
                                     spec.mode,
                                     0,
                                     spec.useFullWindow ? kFullDecryptWindowBytes : kDefaultDecryptWindowBytes,
                                     spec.candidateId);
            }
            tempData = transformedBuffer.empty() ? nullptr : &transformedBuffer[0];
        }

        record.transformedSize = tempSize;
        record.transformedSignature = DescribeBufferSignature(tempData, tempSize);
        record.transformedPrefixHex = FormatHexPrefix(tempData, tempSize, 32);

        std::vector<unsigned char> candidateOutput;
        uint32_t candidateOutputSize = 0;
        int candidateError = LJFP_SUCCESS;
        int unzipResult = 0;

        if (needDecompress) {
            uint64_t initialOutputSize =
                (originalSize > 0)
                ? static_cast<uint64_t>(originalSize)
                : (tempSize > 0 ? static_cast<uint64_t>(tempSize) * 4u : 1u);
            if (initialOutputSize == 0) {
                initialOutputSize = 1;
            }
            if (initialOutputSize > MAX_DECOMPRESS_SIZE) {
                candidateError = LJFP_ERROR_DECOMPRESS_TOO_LARGE;
            } else {
                candidateOutputSize = static_cast<uint32_t>(initialOutputSize);
            }

            if (candidateError == LJFP_SUCCESS) {
                candidateOutput.resize(candidateOutputSize);

                unzipResult = m_unzipFunc(candidateOutput.empty() ? nullptr : &candidateOutput[0],
                                          &candidateOutputSize,
                                          tempData,
                                          tempSize);
            }
            int retryCount = 0;
            const int MAX_RETRIES = 10;

            while (unzipResult == -5 && retryCount < MAX_RETRIES) {
                if (candidateOutputSize == 0 ||
                    candidateOutputSize > MAX_DECOMPRESS_SIZE / 2u) {
                    candidateError = LJFP_ERROR_DECOMPRESS_TOO_LARGE;
                    break;
                }
                candidateOutputSize *= 2;

                if (candidateOutputSize > MAX_DECOMPRESS_SIZE) {
                    candidateError = LJFP_ERROR_DECOMPRESS_TOO_LARGE;
                    break;
                }

                candidateOutput.resize(candidateOutputSize);
                unzipResult = m_unzipFunc(candidateOutput.empty() ? nullptr : &candidateOutput[0],
                                          &candidateOutputSize,
                                          tempData,
                                          tempSize);
                retryCount++;
            }

            if (candidateError == LJFP_SUCCESS && unzipResult != 0) {
                candidateError = LJFP_ERROR_DECOMPRESS_FAILED;
            } else if (candidateError == LJFP_SUCCESS) {
                candidateOutput.resize(candidateOutputSize);
            }
        } else {
            candidateOutputSize = tempSize;
            candidateOutput.resize(candidateOutputSize);
            if (candidateOutputSize > 0) {
                std::memcpy(&candidateOutput[0], tempData, tempSize);
            }
        }

        record.unzipResult = unzipResult;

        if (candidateError != LJFP_SUCCESS) {
            record.errorCode = candidateError;
            probeRecords.push_back(record);
            LJFP_LOG_WARNING(
                L"Decrypt probe failed: " + ProbeRecordToWideSummary(probeRecords.back()) +
                L", originalSize=" + std::to_wstring(originalSize) +
                L", expectedCRC32=" +
                MultiByteToWideBestEffort(FormatHexCrc32(expectedCRC32)) +
                L", transformedPrefix=" +
                MultiByteToWideBestEffort(probeRecords.back().transformedPrefixHex) +
                L", zlibStatus=" + std::wstring(ZlibResultToWideText(unzipResult)));
            lastError = candidateError;
            continue;
        }

        record.outputSize = candidateOutputSize;
        record.outputSignature = DescribeBufferSignature(candidateOutput.empty() ? nullptr : &candidateOutput[0],
                                                        candidateOutputSize);
        record.outputPrefixHex = FormatHexPrefix(candidateOutput.empty() ? nullptr : &candidateOutput[0],
                                                candidateOutputSize,
                                                32);
        record.errorCode = LJFP_SUCCESS;

        if (shouldCheckCandidateCrc) {
            record.crcChecked = true;
            record.actualCRC32 = m_crc32Func(0,
                                             candidateOutput.empty() ? nullptr : &candidateOutput[0],
                                             candidateOutputSize);
            record.crcMatched = (record.actualCRC32 == expectedCRC32);
        }

        if (autoSelectingCandidate && record.crcChecked && !record.crcMatched) {
            record.errorCode = LJFP_ERROR_CRC32_MISMATCH;
            probeRecords.push_back(record);
            const DecryptProbeRecord& failedRecord = probeRecords.back();
            LJFP_LOG_WARNING(
                L"Decrypt probe CRC mismatch: " + ProbeRecordToWideSummary(failedRecord) +
                L", expected=" +
                MultiByteToWideBestEffort(FormatHexCrc32(failedRecord.expectedCRC32)) +
                L", actual=" +
                MultiByteToWideBestEffort(FormatHexCrc32(failedRecord.actualCRC32)) +
                L", outputPrefix=" +
                MultiByteToWideBestEffort(failedRecord.outputPrefixHex));
            lastError = LJFP_ERROR_CRC32_MISMATCH;
            continue;
        }

        record.selected = true;
        probeRecords.push_back(record);
        SetLastDecryptProbeRecords(probeRecords);

        if (record.crcChecked && !record.crcMatched && !autoSelectingCandidate) {
            LJFP_LOG_WARNING(
                L"Decrypt probe selected candidate has CRC drift: " +
                ProbeRecordToWideSummary(probeRecords.back()) +
                L", expected=" +
                MultiByteToWideBestEffort(FormatHexCrc32(probeRecords.back().expectedCRC32)) +
                L", actual=" +
                MultiByteToWideBestEffort(FormatHexCrc32(probeRecords.back().actualCRC32)));
        }

        if (probeRecordsOut != nullptr) {
            *probeRecordsOut = probeRecords;
        }
        outputData.swap(candidateOutput);
        return LJFP_SUCCESS;
    }

    SetLastDecryptProbeRecords(probeRecords);
    if (probeRecordsOut != nullptr) {
        *probeRecordsOut = probeRecords;
    }

    if (lastError == LJFP_SUCCESS) {
        lastError = needDecompress ? LJFP_ERROR_DECOMPRESS_FAILED : LJFP_ERROR_DECRYPT_FAILED;
    }
    return lastError;
}

int Unpacker::ResolveOutputPathForWrite(const FileInfo& fileInfo,
                                        const std::string& requestedOutputPath,
                                        const unsigned char* fileData,
                                        uint32_t dataSize,
                                        std::string& resolvedOutputPath) {
    std::string desiredOutputPath = requestedOutputPath;
    if (desiredOutputPath.empty()) {
        desiredOutputPath = BuildOutputPath(fileInfo, fileData, dataSize);
    } else {
        desiredOutputPath = NormalizeSlashesCopy(desiredOutputPath);
    }

    if (desiredOutputPath.empty()) {
        return LJFP_ERROR_FILE_CREATE_FAILED;
    }

    std::lock_guard<std::mutex> lock(m_outputPathMutex);

    const bool hasCustomOutputPath = !requestedOutputPath.empty();
    const bool allowPathMappingForWrite =
        m_options.preferPathMapping && !m_options.forceCrcOutputFirst;
    bool usedPathMapping = false;
    PathMappingAuditInfo mappingAudit;
    if (!hasCustomOutputPath && allowPathMappingForWrite) {
        std::map<uint32_t, PathMappingAuditInfo>::const_iterator mappingAuditIt =
            m_pathMappingAudit.find(fileInfo.m_PathFileNameCRC32);
        if (mappingAuditIt != m_pathMappingAudit.end()) {
            usedPathMapping = true;
            mappingAudit = mappingAuditIt->second;
        } else {
            std::map<uint32_t, std::string>::const_iterator mappingIt =
                m_pathMapping.find(fileInfo.m_PathFileNameCRC32);
            if (mappingIt != m_pathMapping.end()) {
                usedPathMapping = true;
                mappingAudit.normalizedPath = NormalizeSlashesCopy(mappingIt->second);
            }
        }
    }

    std::string desiredRelativePath = NormalizeSlashesCopy(MakeRelativeToRoot(m_outputDir, desiredOutputPath));
    if (usedPathMapping && !mappingAudit.normalizedPath.empty()) {
        desiredRelativePath = NormalizeSlashesCopy(mappingAudit.normalizedPath);
    }

    std::string candidate = desiredOutputPath;
    uint32_t conflictIndex = 0;
    bool conflictResolved = false;
    bool existingTargetPreserved = false;
    for (;;) {
        const std::string reservationKey = BuildOutputReservationKey(candidate);
        std::map<std::string, uint32_t>::const_iterator reservedIt =
            m_reservedOutputPaths.find(reservationKey);

        if (reservedIt != m_reservedOutputPaths.end() &&
            reservedIt->second != fileInfo.m_PathFileNameCRC32) {
            conflictResolved = true;
            ++conflictIndex;
            candidate = BuildConflictOutputPath(desiredOutputPath,
                                                fileInfo.m_PathFileNameCRC32,
                                                conflictIndex);
            continue;
        }

        if (FileExistsPath(candidate) && !m_options.overwriteExisting) {
            conflictResolved = true;
            existingTargetPreserved = true;
            ++conflictIndex;
            candidate = BuildConflictOutputPath(desiredOutputPath,
                                                fileInfo.m_PathFileNameCRC32,
                                                conflictIndex);
            continue;
        }

        m_reservedOutputPaths[reservationKey] = fileInfo.m_PathFileNameCRC32;
        if (conflictIndex > 0) {
            LJFP_LOG_WARNING(L"Resolved output path conflict for CRC32=" +
                             std::to_wstring(fileInfo.m_PathFileNameCRC32) +
                             L" -> " + MultiByteToWideBestEffort(candidate));
        }

        OutputPathAuditRecord& auditRecord = m_outputPathAuditRecords[fileInfo.m_PathFileNameCRC32];
        auditRecord.pathCRC32 = fileInfo.m_PathFileNameCRC32;
        auditRecord.sourceKind = hasCustomOutputPath ? "custom" : (usedPathMapping ? "mapping" : "generated");
        auditRecord.rawMappingPath = mappingAudit.rawPath;
        auditRecord.normalizedRelativePath = desiredRelativePath;
        auditRecord.writtenRelativePath = NormalizeSlashesCopy(MakeRelativeToRoot(m_outputDir, candidate));
        auditRecord.finalRelativePath = auditRecord.writtenRelativePath;
        auditRecord.mappingSanitized = usedPathMapping && mappingAudit.sanitized;
        auditRecord.conflictResolved = conflictResolved;
        auditRecord.existingTargetPreserved = existingTargetPreserved;
        auditRecord.postProcessMoved = false;

        resolvedOutputPath = candidate;
        return LJFP_SUCCESS;
    }
}

std::string Unpacker::BuildConflictOutputPath(const std::string& outputPath,
                                              uint32_t pathFileNameCRC32,
                                              uint32_t conflictIndex) const {
    const std::string normalized = NormalizeSlashesCopy(outputPath);
    const std::string dirPath = GetDirectoryName(normalized);
    const std::string fileName = GetFileName(normalized);
    const std::string stem = RemoveExtension(fileName);
    const std::string ext = fileName.substr(stem.size());

    std::ostringstream oss;
    oss << (stem.empty() ? "file" : stem)
        << ".conflict."
        << std::uppercase << std::hex << std::setw(8) << std::setfill('0')
        << pathFileNameCRC32
        << std::dec;
    if (conflictIndex > 1) {
        oss << "." << conflictIndex;
    }
    oss << ext;

    if (dirPath.empty()) {
        return oss.str();
    }
    return JoinPath(dirPath, oss.str());
}

void Unpacker::RefreshOutputPathAuditFinalPaths() {
    struct PhysicalOutputInfo {
        std::string relativePath;
        uint64_t size;
        std::string detectedExtension;

        PhysicalOutputInfo()
            : size(0) {}
    };

    std::vector<std::string> relPaths;
    CollectFilesRecursive(m_outputDir, relPaths);

    std::map<uint32_t, std::string> resolvedPathsByCrc;
    std::map<std::string, PhysicalOutputInfo> physicalByRelativePath;
    std::map<std::string, PhysicalOutputInfo> physicalByRelativePathLower;
    std::map<std::string, std::vector<PhysicalOutputInfo> > physicalByFileName;
    std::map<uint32_t, std::vector<PhysicalOutputInfo> > physicalByNumericStem;
    for (size_t i = 0; i < relPaths.size(); ++i) {
        std::string normalizedRelPath = NormalizeOutputRelativePath(relPaths[i]);
        if (normalizedRelPath.empty()) {
            continue;
        }

        PhysicalOutputInfo info;
        info.relativePath = normalizedRelPath;
        info.size = GetFileSizePath(JoinPath(m_outputDir, normalizedRelPath));
        info.detectedExtension = DetectPhysicalFileExtension(JoinPath(m_outputDir, normalizedRelPath));
        physicalByRelativePath[normalizedRelPath] = info;
        physicalByRelativePathLower[ToLowerCopy(normalizedRelPath)] = info;
        physicalByFileName[ToLowerCopy(GetFileName(normalizedRelPath))].push_back(info);

        const std::string fileName = GetFileName(normalizedRelPath);
        const std::string numericStem = RemoveExtension(fileName);
        uint32_t stemCrc32 = 0;
        if (!numericStem.empty() && ParseCrc32Token(numericStem, stemCrc32)) {
            physicalByNumericStem[stemCrc32].push_back(info);
        }

        uint32_t pathCrc32 = m_crc32Func(
            0,
            reinterpret_cast<const unsigned char*>(normalizedRelPath.data()),
            static_cast<unsigned int>(normalizedRelPath.size()));
        resolvedPathsByCrc[pathCrc32] = normalizedRelPath;
    }

    std::lock_guard<std::mutex> lock(m_outputPathMutex);
    for (std::map<uint32_t, OutputPathAuditRecord>::iterator it = m_outputPathAuditRecords.begin();
         it != m_outputPathAuditRecords.end(); ++it) {
        OutputPathAuditRecord& record = it->second;
        auto samePhysicalPath = [](const std::string& left, const std::string& right) -> bool {
            return ToLowerCopy(left) == ToLowerCopy(right);
        };
        const std::string normalizedFinalCandidate = NormalizeOutputRelativePath(record.finalRelativePath);
        const std::string normalizedWrittenCandidate = NormalizeOutputRelativePath(record.writtenRelativePath);
        const std::string normalizedContentAliasCandidate =
            NormalizeOutputRelativePath(record.contentAliasRelativePath);
        record.actualRelativePath.clear();
        record.physicalPathStatus = "missing_physical";
        record.detectedExtension.clear();
        record.physicalExists = false;
        record.extensionConsistent = true;
        record.physicalSize = 0;

        std::vector<std::string> candidates;
        if (!record.finalRelativePath.empty()) {
            candidates.push_back(NormalizeOutputRelativePath(record.finalRelativePath));
        }
        if (!record.writtenRelativePath.empty()) {
            const std::string writtenCandidate = NormalizeOutputRelativePath(record.writtenRelativePath);
            if (std::find(candidates.begin(), candidates.end(), writtenCandidate) == candidates.end()) {
                candidates.push_back(writtenCandidate);
            }
        }
        if (!normalizedContentAliasCandidate.empty() &&
            std::find(candidates.begin(), candidates.end(), normalizedContentAliasCandidate) == candidates.end()) {
            candidates.push_back(normalizedContentAliasCandidate);
        }

        std::map<uint32_t, std::string>::const_iterator resolvedIt = resolvedPathsByCrc.find(record.pathCRC32);
        if (resolvedIt != resolvedPathsByCrc.end() &&
            std::find(candidates.begin(), candidates.end(), resolvedIt->second) == candidates.end()) {
            candidates.push_back(resolvedIt->second);
        }

        PhysicalOutputInfo foundInfo;
        bool found = false;
        for (size_t candidateIndex = 0; candidateIndex < candidates.size(); ++candidateIndex) {
            std::map<std::string, PhysicalOutputInfo>::const_iterator directIt =
                physicalByRelativePath.find(candidates[candidateIndex]);
            if (directIt != physicalByRelativePath.end()) {
                foundInfo = directIt->second;
                found = true;
                break;
            }

            std::map<std::string, PhysicalOutputInfo>::const_iterator lowerIt =
                physicalByRelativePathLower.find(ToLowerCopy(candidates[candidateIndex]));
            if (lowerIt != physicalByRelativePathLower.end()) {
                foundInfo = lowerIt->second;
                found = true;
                break;
            }
        }

        if (!found) {
            std::map<uint32_t, std::vector<PhysicalOutputInfo> >::const_iterator numericStemIt =
                physicalByNumericStem.find(record.pathCRC32);
            if (numericStemIt != physicalByNumericStem.end() && numericStemIt->second.size() == 1) {
                foundInfo = numericStemIt->second[0];
                found = true;
            }
        }

        if (!found) {
            std::string leafName = GetFileName(record.writtenRelativePath);
            if (leafName.empty()) {
                leafName = GetFileName(record.finalRelativePath);
            }
            if (leafName.empty()) {
                leafName = GetFileName(record.normalizedRelativePath);
            }

            const std::string lowerLeaf = ToLowerCopy(leafName);
            std::map<std::string, std::vector<PhysicalOutputInfo> >::const_iterator leafIt =
                physicalByFileName.find(lowerLeaf);
            if (leafIt != physicalByFileName.end() && leafIt->second.size() == 1) {
                foundInfo = leafIt->second[0];
                found = true;
            }
        }

        if (found) {
            record.actualRelativePath = foundInfo.relativePath;
            record.finalRelativePath = foundInfo.relativePath;
            record.physicalExists = true;
            record.physicalSize = foundInfo.size;
            record.detectedExtension = foundInfo.detectedExtension;

            if (!normalizedContentAliasCandidate.empty() &&
                samePhysicalPath(record.actualRelativePath, normalizedContentAliasCandidate)) {
                record.physicalPathStatus = "content_deduped_alias";
            } else if (!normalizedFinalCandidate.empty() &&
                samePhysicalPath(record.actualRelativePath, normalizedFinalCandidate)) {
                record.physicalPathStatus = "manifest_path";
            } else if (samePhysicalPath(record.actualRelativePath, normalizedWrittenCandidate)) {
                record.physicalPathStatus = "written_path";
            } else if (StartsWith(ToLowerCopy(record.actualRelativePath), "review/unresolved/")) {
                record.physicalPathStatus = "review_unresolved_relocated";
                record.reviewBucketed = true;
            } else if (resolvedIt != resolvedPathsByCrc.end() &&
                       samePhysicalPath(record.actualRelativePath, resolvedIt->second)) {
                record.physicalPathStatus = "crc_relocated";
            } else {
                record.physicalPathStatus = "basename_relocated";
            }
        } else if (record.finalRelativePath.empty()) {
            record.finalRelativePath = record.writtenRelativePath;
        }

        record.postProcessMoved =
            ToLowerCopy(record.finalRelativePath) != ToLowerCopy(record.writtenRelativePath);

        const std::string physicalExtension = GetExtensionLower(record.actualRelativePath);
        if (record.physicalExists && !record.detectedExtension.empty()) {
            record.extensionConsistent = (physicalExtension == record.detectedExtension);
        } else if (record.physicalExists && !physicalExtension.empty()) {
            record.extensionConsistent = false;
        }
    }
}

int Unpacker::WriteOutputPathManifest() {
    const std::string manifestPath = JoinPath(m_outputDir, "unpack_path_manifest.tsv");
    const std::string manifestJsonPath = JoinPath(m_outputDir, "unpack_path_manifest.json");

    std::ostringstream tsv;
    std::ostringstream json;
    tsv << "path_crc32\tsource_kind\traw_mapping_path\tnormalized_relative_path\twritten_relative_path\tfinal_relative_path\tactual_relative_path\tphysical_path_status\tphysical_exists\tphysical_size\tdetected_extension\textension_consistent\tflags\n";
    json << "{\n";
    json << "  \"version\": 1,\n";
    json << "  \"generated_by\": \"SuperLJFilePackUnpack\",\n";
    json << "  \"files\": [\n";

    bool firstRecord = true;
    {
        std::lock_guard<std::mutex> lock(m_outputPathMutex);
        for (std::map<uint32_t, OutputPathAuditRecord>::const_iterator it = m_outputPathAuditRecords.begin();
             it != m_outputPathAuditRecords.end(); ++it) {
            const OutputPathAuditRecord& record = it->second;
            std::vector<std::string> flags;
            if (record.mappingSanitized) {
                flags.push_back("mapping_sanitized");
            }
            if (record.conflictResolved) {
                flags.push_back("conflict_suffix");
            }
            if (record.existingTargetPreserved) {
                flags.push_back("existing_target_preserved");
            }
            if (record.postProcessMoved) {
                flags.push_back("postprocess_relocated");
            }
            if (record.physicalPathStatus == "content_deduped_alias") {
                flags.push_back("content_deduped_alias");
            }
            if (record.contentAliasAmbiguous) {
                flags.push_back("content_alias_ambiguous");
            }
            if (record.reviewBucketed) {
                flags.push_back("review_bucketed");
            }
            if (!record.physicalExists) {
                flags.push_back("physical_missing");
            }
            if (record.physicalExists && !record.extensionConsistent) {
                flags.push_back("extension_mismatch");
            }

            const std::string flagText = JoinFlagsCsv(flags);

            tsv << EscapeTsvField(FormatHexCrc32(record.pathCRC32)) << "\t"
                << EscapeTsvField(record.sourceKind) << "\t"
                << EscapeTsvField(record.rawMappingPath) << "\t"
                << EscapeTsvField(record.normalizedRelativePath) << "\t"
                << EscapeTsvField(record.writtenRelativePath) << "\t"
                << EscapeTsvField(record.finalRelativePath) << "\t"
                << EscapeTsvField(record.actualRelativePath) << "\t"
                << EscapeTsvField(record.physicalPathStatus) << "\t"
                << (record.physicalExists ? "True" : "False") << "\t"
                << record.physicalSize << "\t"
                << EscapeTsvField(record.detectedExtension) << "\t"
                << (record.extensionConsistent ? "true" : "false") << "\t"
                << EscapeTsvField(flagText) << "\n";

            if (!firstRecord) {
                json << ",\n";
            }
            firstRecord = false;
            json << "    {\n";
            json << "      \"path_crc32\": \"" << EscapeJsonString(FormatHexCrc32(record.pathCRC32)) << "\",\n";
            json << "      \"source_kind\": \"" << EscapeJsonString(record.sourceKind) << "\",\n";
            json << "      \"raw_mapping_path\": \"" << EscapeJsonString(record.rawMappingPath) << "\",\n";
            json << "      \"normalized_relative_path\": \"" << EscapeJsonString(record.normalizedRelativePath) << "\",\n";
            json << "      \"written_relative_path\": \"" << EscapeJsonString(record.writtenRelativePath) << "\",\n";
            json << "      \"final_relative_path\": \"" << EscapeJsonString(record.finalRelativePath) << "\",\n";
            json << "      \"actual_relative_path\": \"" << EscapeJsonString(record.actualRelativePath) << "\",\n";
            json << "      \"physical_path_status\": \"" << EscapeJsonString(record.physicalPathStatus) << "\",\n";
            json << "      \"physical_exists\": " << (record.physicalExists ? "true" : "false") << ",\n";
            json << "      \"physical_size\": " << record.physicalSize << ",\n";
            json << "      \"detected_extension\": \"" << EscapeJsonString(record.detectedExtension) << "\",\n";
            json << "      \"extension_consistent\": " << (record.extensionConsistent ? "true" : "false") << ",\n";
            json << "      \"flags\": [";
            for (size_t i = 0; i < flags.size(); ++i) {
                if (i > 0) {
                    json << ", ";
                }
                json << "\"" << EscapeJsonString(flags[i]) << "\"";
            }
            json << "]\n";
            json << "    }";
        }
    }
    json << "\n";
    json << "  ]\n";
    json << "}\n";

    const std::string manifestText = tsv.str();
    const std::string manifestJsonText = json.str();
    std::vector<unsigned char> manifestBytes(manifestText.begin(), manifestText.end());
    std::vector<unsigned char> manifestJsonBytes(manifestJsonText.begin(), manifestJsonText.end());

    const std::string manifestDir = GetDirectoryName(manifestPath);
    if (!manifestDir.empty()) {
        CreateDirectoryRecursive(manifestDir);
    }

    if (!WriteFileBytes(manifestPath, manifestBytes)) {
        LJFP_LOG_ERROR(L"Failed to write output path manifest: " +
                       MultiByteToWideBestEffort(manifestPath));
        return LJFP_ERROR_FILE_CREATE_FAILED;
    }
    if (!WriteFileBytes(manifestJsonPath, manifestJsonBytes)) {
        LJFP_LOG_ERROR(L"Failed to write output path manifest JSON: " +
                       MultiByteToWideBestEffort(manifestJsonPath));
        return LJFP_ERROR_FILE_CREATE_FAILED;
    }

    LJFP_LOG_INFO(L"Wrote output path manifest: " +
                  MultiByteToWideBestEffort(manifestPath));
    LJFP_LOG_INFO(L"Wrote output path manifest JSON: " +
                  MultiByteToWideBestEffort(manifestJsonPath));
    return LJFP_SUCCESS;
}

std::string Unpacker::BuildOutputPath(const FileInfo& fileInfo, const unsigned char* fileData, uint32_t dataSize) {
    // 默认使用 CRC32 作为文件名
    std::string fileName = std::to_string(fileInfo.m_PathFileNameCRC32);
    std::string extension;

    // 若有文件数据且启用识别，则先补后缀，便于后续阶段处理
    if (m_options.detectFileType && fileData != nullptr && dataSize > 0) {
        extension = FileTypeDetector::DetectExtension(fileData, dataSize);
        if (!extension.empty()) {
            fileName += extension;
        }
    }

    // 强制两阶段模式：首阶段只按 CRC32（可带识别后缀）落地到输出根目录
    if (m_options.forceCrcOutputFirst) {
        return JoinPath(m_outputDir, fileName);
    }

    // 非强制两阶段时，若命中映射则直接写入映射路径
    if (m_options.preferPathMapping) {
        auto it = m_pathMapping.find(fileInfo.m_PathFileNameCRC32);
        if (it != m_pathMapping.end()) {
            bool pathChanged = false;
            std::string originalPath = NormalizeOutputRelativePath(it->second, &pathChanged);
            if (!originalPath.empty()) {
                return JoinPath(m_outputDir, originalPath);
            }
        }
    }

    std::string typeDir;
    if (!extension.empty()) {
        // 按类型分类到子目录
        if (m_options.organizeByType) {
            // 图片类型
            if (extension == ".png" || extension == ".jpg" || extension == ".jpeg" ||
                extension == ".gif" || extension == ".bmp" || extension == ".tga" ||
                extension == ".webp" || extension == ".ico" || extension == ".dds") {
                typeDir = "images";
            }
            // 音频类型
            else if (extension == ".mp3" || extension == ".ogg" || extension == ".wav" ||
                        extension == ".flac" || extension == ".aac" || extension == ".wma") {
                typeDir = "audio";
            }
            // 脚本类型
            else if (extension == ".lua" || extension == ".luac" || extension == ".js" ||
                        extension == ".py" || extension == ".sh" || extension == ".bat") {
                typeDir = "scripts";
            }
            // 配置文件类型
            else if (extension == ".xml" || extension == ".json" || extension == ".ini" ||
                        extension == ".cfg" || extension == ".conf" || extension == ".yaml") {
                typeDir = "config";
            }
            // 模型/动画类型 (游戏特定格式)
            else if (extension == ".ani" || extension == ".act" || extension == ".lmx" ||
                        extension == ".set" || extension == ".dye" || extension == ".mdl" ||
                        extension == ".mesh" || extension == ".skeleton") {
                typeDir = "models";
            }
            // 字体类型
            else if (extension == ".ttf" || extension == ".otf" || extension == ".fnt" ||
                        extension == ".font") {
                typeDir = "fonts";
            }
            // 着色器类型
            else if (extension == ".glsl" || extension == ".hlsl" || extension == ".shader" ||
                        extension == ".vert" || extension == ".frag") {
                typeDir = "shaders";
            }
            // 数据表类型
            else if (extension == ".bin" || extension == ".dat" || extension == ".db") {
                typeDir = "data";
            }
            // 文本类型
            else if (extension == ".txt" || extension == ".log" || extension == ".md") {
                typeDir = "text";
            }
            // 其他已知类型
            else {
                typeDir = "misc";
            }
        }
    }

    // 未检测到类型的文件放入 unknown 目录
    if (m_options.organizeByType && typeDir.empty()) {
        typeDir = "unknown";
    }

    // 构建最终路径
    if (!typeDir.empty()) {
        return JoinPath(JoinPath(m_outputDir, typeDir), fileName);
    }
    return JoinPath(m_outputDir, fileName);
}

std::string Unpacker::GetDirectoryPath(const std::string& filePath) {
    size_t lastSlash = filePath.find_last_of("/\\");
    if (lastSlash != std::string::npos) {
        return filePath.substr(0, lastSlash);
    }
    return "";
}

void Unpacker::CreateDirectoryRecursive(const std::string& dirPath) {
    if (dirPath.empty() || !m_options.createDirectories) return;

#ifdef _WIN32
    // 使用宽字符 API，兼容包含中文路径的目录创建
    std::wstring path = MultiByteToWideBestEffort(dirPath);
    if (path.empty()) {
        return;
    }

    for (wchar_t& c : path) {
        if (c == L'/') {
            c = L'\\';
        }
    }

    size_t pos = 0;
    if (path.size() >= 2 && path[0] == L'\\' && path[1] == L'\\') {
        const size_t serverPos = path.find(L'\\', 2);
        if (serverPos == std::wstring::npos) {
            return;
        }
        pos = path.find(L'\\', serverPos + 1);
        if (pos == std::wstring::npos) {
            return;
        }
    } else if (path.size() >= 2 && path[1] == L':') {
        pos = 2;
    }

    while ((pos = path.find(L'\\', pos + 1)) != std::wstring::npos) {
        std::wstring subPath = path.substr(0, pos);
        if (!subPath.empty() && subPath.back() != L':') {
            CreateDirectoryW(subPath.c_str(), NULL);
        }
    }

    CreateDirectoryW(path.c_str(), NULL);
#else
    std::string path = dirPath;
    for (size_t i = 0; i < path.size(); ++i) {
        if (path[i] == '\\') {
            path[i] = '/';
        }
    }

    while (path.size() > 1 && path[path.size() - 1] == '/') {
        path.erase(path.size() - 1);
    }

    std::string current;
    size_t pos = 0;
    if (!path.empty() && path[0] == '/') {
        current = "/";
        pos = 1;
    }

    while (pos <= path.size()) {
        const size_t nextSlash = path.find('/', pos);
        const std::string segment =
            path.substr(pos, nextSlash == std::string::npos ? std::string::npos : nextSlash - pos);

        if (!segment.empty() && segment != ".") {
            if (!current.empty() && current[current.size() - 1] != '/') {
                current += "/";
            }
            current += segment;

            if (!CreatePosixDirectoryIfMissing(current)) {
                LJFP_LOG_WARNING(L"Failed to create directory: " +
                                 MultiByteToWideBestEffort(current));
                return;
            }
        }

        if (nextSlash == std::string::npos) {
            break;
        }
        pos = nextSlash + 1;
    }
#endif
}

int Unpacker::PostProcessRestoredOutputs() {
    struct OutputFile {
        std::string relPath;
        std::string absPath;
        std::string ext;
        bool isRootNumeric;
        uint32_t rootCRC;
    };
    const char* kImageExts[] = { ".png", ".dds", ".tga", ".jpg", ".jpeg", ".webp" };
    const char* kSkipContentScanExts[] = {
        ".png", ".dds", ".tga", ".jpg", ".jpeg", ".webp",
        ".ttf", ".ptc", ".rmp", ".mrmp", ".zip", ".cfb", ".dmp", ".img"
    };
    const char* kKnownPaths[] = {
        "table/bintable/battle.cbattleaiconfig.bin",
        "table/bintable/map.cmapconfig.bin",
        "table/bintable/effectpath.ceffectpath.bin",
        "table/bintable/effectpath.ceffectpathnonedrama.bin",
        "table/bintable/EffectPath.ceffectpathnonedrama.bin",
        "table/bintable/battle.cstageinfo.bin",
        "table/bintable/role.createroleconfig.bin",
        "table/bintable/npc.cnpcshape.bin",
        "table/bintable/npc.cactioninfo.bin",
        "table/bintable/npc.cride.bin",
        "model/sprites.set",
        "model/actiontype.set"
    };

    auto calcCRC = [&](const std::string& relPath) -> uint32_t {
        std::string normalized = NormalizeSlashesCopy(relPath);
        return m_crc32Func(0,
                           reinterpret_cast<const unsigned char*>(normalized.data()),
                           static_cast<unsigned int>(normalized.size()));
    };

    auto scanOutputs = [&](std::vector<OutputFile>& files,
                           std::map<uint32_t, OutputFile>& unresolved) {
        files.clear();
        unresolved.clear();
        std::vector<std::string> rels;
        CollectFilesRecursive(m_outputDir, rels);
        for (size_t i = 0; i < rels.size(); ++i) {
            OutputFile file;
            file.relPath = NormalizeSlashesCopy(rels[i]);
            file.absPath = JoinPath(m_outputDir, file.relPath);
            file.ext = GetExtensionLower(file.relPath);
            file.isRootNumeric = false;
            file.rootCRC = 0;

            if (file.relPath.find('/') == std::string::npos) {
                std::string parsedExt;
                uint32_t parsedCRC = 0;
                if (ParseNumericBaseName(file.relPath, parsedCRC, parsedExt)) {
                    file.isRootNumeric = true;
                    file.rootCRC = parsedCRC;
                    file.ext = parsedExt;
                    unresolved[parsedCRC] = file;
                }
            }
            files.push_back(file);
        }
    };

    auto addCandidate = [&](std::map<uint32_t, std::set<std::string> >& candidates,
                            const std::map<uint32_t, OutputFile>& unresolved,
                            const std::string& relPath) {
        std::string normalized = NormalizeOutputRelativePath(relPath);
        if (normalized.empty()) {
            return;
        }
        uint32_t crc = calcCRC(normalized);
        if (unresolved.find(crc) == unresolved.end()) {
            return;
        }
        candidates[crc].insert(normalized);
    };

    auto addDirectCandidate = [&](std::map<uint32_t, std::set<std::string> >& candidates,
                                  const std::map<uint32_t, OutputFile>& unresolved,
                                  uint32_t rootCRC,
                                  const std::string& relPath) {
        std::string normalized = NormalizeOutputRelativePath(relPath);
        if (normalized.empty()) {
            return;
        }
        if (unresolved.find(rootCRC) == unresolved.end()) {
            return;
        }
        candidates[rootCRC].insert(normalized);
    };

    auto detectCustomExtension = [&](const std::vector<unsigned char>& data) -> std::string {
        std::string ext = FileTypeDetector::DetectExtension(data.empty() ? NULL : &data[0],
                                                            static_cast<uint32_t>(data.size()));
        if (!ext.empty()) {
            return ToLowerCopy(ext);
        }

        std::vector<std::string> tokens = ExtractContentTokens(data);
        std::string firstLine = ToLowerCopy(ParseFirstNonEmptyLine(data));
        for (size_t i = 0; i < tokens.size(); ++i) {
            const std::string tokenLower = ToLowerCopy(tokens[i]);
            if (tokenLower.find("_res") != std::string::npos &&
                (EndsWith(tokenLower, ".png") || EndsWith(tokenLower, ".dds") ||
                 EndsWith(tokenLower, ".tga") || EndsWith(tokenLower, ".jpg") ||
                 EndsWith(tokenLower, ".jpeg") || EndsWith(tokenLower, ".webp"))) {
                return ".ani";
            }
            if (tokenLower.find("<guilayout") != std::string::npos) {
                return ".layout";
            }
            if (tokenLower.find("<data") != std::string::npos &&
                (tokenLower.find("<action") != std::string::npos ||
                 tokenLower.find("<layer") != std::string::npos ||
                 tokenLower.find("<weapon") != std::string::npos ||
                 tokenLower.find("<body") != std::string::npos)) {
                return ".xml";
            }
            if (tokenLower.find("\"skeleton\"") != std::string::npos &&
                tokenLower.find("\"skins\"") != std::string::npos) {
                return ".json";
            }
        }

        if (EndsWith(firstLine, ".png") || EndsWith(firstLine, ".jpg") ||
            EndsWith(firstLine, ".jpeg") || EndsWith(firstLine, ".dds")) {
            return ".atlas";
        }
        if (data.size() >= 4 && data[0] == 'L' && data[1] == 'D' && data[2] == 'Z' && data[3] == 'Y') {
            return ".bin";
        }
        return std::string();
    };

    auto shouldReadForContentHeuristics = [&](const OutputFile& file) -> bool {
        for (size_t i = 0; i < sizeof(kSkipContentScanExts) / sizeof(kSkipContentScanExts[0]); ++i) {
            if (file.ext == kSkipContentScanExts[i]) {
                return false;
            }
        }
        return true;
    };

    auto registerRecoveredExactPathMapping = [&](uint32_t rootCRC, const std::string& relPath) {
        std::string normalized = NormalizeOutputRelativePath(relPath);
        if (normalized.empty()) {
            return;
        }

        if (m_pathMapping.find(rootCRC) != m_pathMapping.end()) {
            return;
        }

        m_pathMapping[rootCRC] = normalized;
        {
            std::lock_guard<std::mutex> lock(m_outputPathMutex);
            PathMappingAuditInfo& audit = m_pathMappingAudit[rootCRC];
            if (audit.rawPath.empty()) {
                audit.rawPath = normalized;
            }
            audit.normalizedPath = normalized;
            audit.sanitized = false;
        }
        m_pathMappingStatsValid = false;
    };

    auto updateOutputAuditForResolvedPath = [&](uint32_t rootCRC,
                                                const std::string& relPath,
                                                bool resolvedFromPathMapping) {
        const std::string normalized = NormalizeOutputRelativePath(relPath);
        if (normalized.empty()) {
            return;
        }

        std::lock_guard<std::mutex> lock(m_outputPathMutex);
        std::map<uint32_t, OutputPathAuditRecord>::iterator auditIt =
            m_outputPathAuditRecords.find(rootCRC);
        if (auditIt == m_outputPathAuditRecords.end()) {
            return;
        }

        OutputPathAuditRecord& auditRecord = auditIt->second;
        auditRecord.finalRelativePath = normalized;
        auditRecord.postProcessMoved =
            ToLowerCopy(auditRecord.writtenRelativePath) != ToLowerCopy(normalized);

        if (!resolvedFromPathMapping || auditRecord.sourceKind == "custom") {
            return;
        }

        auditRecord.sourceKind = "mapping";
        auditRecord.normalizedRelativePath = normalized;

        std::map<uint32_t, PathMappingAuditInfo>::const_iterator mappingAuditIt =
            m_pathMappingAudit.find(rootCRC);
        if (mappingAuditIt != m_pathMappingAudit.end()) {
            if (!mappingAuditIt->second.rawPath.empty()) {
                auditRecord.rawMappingPath = mappingAuditIt->second.rawPath;
            } else if (auditRecord.rawMappingPath.empty()) {
                auditRecord.rawMappingPath = normalized;
            }
            auditRecord.mappingSanitized = mappingAuditIt->second.sanitized;
        } else if (auditRecord.rawMappingPath.empty()) {
            auditRecord.rawMappingPath = normalized;
        }
    };

    auto updateOutputAuditForContentAlias = [&](uint32_t rootCRC,
                                                const std::string& relPath,
                                                bool aliasAmbiguous) {
        const std::string normalized = NormalizeOutputRelativePath(relPath);
        if (normalized.empty()) {
            return;
        }

        std::lock_guard<std::mutex> lock(m_outputPathMutex);
        std::map<uint32_t, OutputPathAuditRecord>::iterator auditIt =
            m_outputPathAuditRecords.find(rootCRC);
        if (auditIt == m_outputPathAuditRecords.end()) {
            return;
        }

        OutputPathAuditRecord& auditRecord = auditIt->second;
        auditRecord.contentAliasRelativePath = normalized;
        auditRecord.contentAliasAmbiguous = aliasAmbiguous;
        auditRecord.finalRelativePath = normalized;
        auditRecord.postProcessMoved =
            ToLowerCopy(auditRecord.writtenRelativePath) != ToLowerCopy(normalized);
    };

    auto applyCandidates = [&](const std::map<uint32_t, std::set<std::string> >& candidates,
                               const std::map<uint32_t, OutputFile>& unresolved,
                               bool resolvedFromPathMapping) -> bool {
        bool changed = false;
        for (std::map<uint32_t, std::set<std::string> >::const_iterator it = candidates.begin();
             it != candidates.end(); ++it) {
            if (it->second.size() != 1) {
                continue;
            }
            std::map<uint32_t, OutputFile>::const_iterator unresolvedIt = unresolved.find(it->first);
            if (unresolvedIt == unresolved.end()) {
                continue;
            }
            const std::string targetRel = *it->second.begin();
            const std::string targetAbs = JoinPath(m_outputDir, targetRel);
            if (targetAbs == unresolvedIt->second.absPath) {
                continue;
            }

            std::string targetDir = GetDirectoryName(targetAbs);
            if (!targetDir.empty()) {
                CreateDirectoryRecursive(targetDir);
            }

            if (FileExistsPath(targetAbs)) {
                std::vector<unsigned char> srcData;
                std::vector<unsigned char> dstData;
                if (ReadFileBytes(unresolvedIt->second.absPath, srcData) &&
                    ReadFileBytes(targetAbs, dstData) &&
                    srcData == dstData) {
                    DeleteFilePath(unresolvedIt->second.absPath);
                    registerRecoveredExactPathMapping(it->first, targetRel);
                    updateOutputAuditForResolvedPath(it->first,
                                                     targetRel,
                                                     resolvedFromPathMapping);
                    changed = true;
                }
                continue;
            }

            if (MoveFileReplacePath(unresolvedIt->second.absPath, targetAbs)) {
                registerRecoveredExactPathMapping(it->first, targetRel);
                updateOutputAuditForResolvedPath(it->first,
                                                 targetRel,
                                                 resolvedFromPathMapping);
                changed = true;
            }
        }
        return changed;
    };

    LJFP_LOG_INFO(L"Starting post-process restore stage...");

    bool changed = false;
    for (int pass = 0; pass < 3; ++pass) {
        std::vector<OutputFile> files;
        std::map<uint32_t, OutputFile> unresolved;
        scanOutputs(files, unresolved);
        if (unresolved.empty()) {
            break;
        }

        if (!m_pathMapping.empty()) {
            std::map<uint32_t, std::set<std::string> > mappingCandidates;
            for (std::map<uint32_t, std::string>::const_iterator it = m_pathMapping.begin();
                 it != m_pathMapping.end(); ++it) {
                addCandidate(mappingCandidates, unresolved, it->second);
            }
            if (!mappingCandidates.empty() &&
                applyCandidates(mappingCandidates, unresolved, true)) {
                changed = true;
                scanOutputs(files, unresolved);
                if (unresolved.empty()) {
                    break;
                }
            }
        }

        bool renamedRootExtension = false;
        for (size_t i = 0; i < files.size(); ++i) {
            if (!files[i].isRootNumeric || !files[i].ext.empty()) {
                continue;
            }

            std::vector<unsigned char> data;
            if (!ReadFileBytes(files[i].absPath, data)) {
                continue;
            }

            std::string detectedExt = detectCustomExtension(data);
            if (detectedExt.empty()) {
                continue;
            }

            std::string targetRel = std::to_string(files[i].rootCRC) + detectedExt;
            std::string targetAbs = JoinPath(m_outputDir, targetRel);
            if (MoveFileReplacePath(files[i].absPath, targetAbs)) {
                renamedRootExtension = true;
                changed = true;
            }
        }
        if (renamedRootExtension) {
            continue;
        }

        std::map<uint32_t, std::set<std::string> > candidates;
        std::map<uint32_t, std::set<std::string> > directCandidates;
        std::set<std::string> modelNames;
        std::set<std::string> geffectRefs;
        std::set<std::string> actions;
        std::set<std::string> ridingActions;
        std::set<std::string> bodyNames;
        std::set<std::string> weaponNames;
        std::set<std::string> rideModelIds;
        std::set<std::string> animationRefs;
        std::map<std::string, std::set<std::string> > atlasRegionsByDir;
        std::vector< std::pair<std::string, std::vector<std::string> > > namedAniTextures;
        std::vector< std::pair<uint32_t, std::vector<std::string> > > rootAniTokens;
        const int kEffectImageVariantMax = 27;
        auto addModelActionImageCandidates =
            [&](const std::string& basePrefix, const std::string& actionName) {
                for (size_t e = 0; e < sizeof(kImageExts) / sizeof(kImageExts[0]); ++e) {
                    for (int variantIndex = 0; variantIndex <= 9; ++variantIndex) {
                        addCandidate(candidates, unresolved,
                                     basePrefix + actionName +
                                     FormatResVariant(variantIndex) + kImageExts[e]);
                    }
                }
            };
        auto addEffectAnimationImageCandidates = [&](const std::string& animRef) {
            const std::string animDir = GetDirectoryName(animRef);
            const std::string animStem = GetFileName(animRef);
            if (animStem.empty()) {
                return;
            }
            for (size_t e = 0; e < sizeof(kImageExts) / sizeof(kImageExts[0]); ++e) {
                for (int variantIndex = 0; variantIndex <= kEffectImageVariantMax; ++variantIndex) {
                    addCandidate(candidates, unresolved,
                                 "effect/" + JoinPath(animDir,
                                                      animStem + FormatResVariant(variantIndex) +
                                                      kImageExts[e]));
                }
            }
        };

        for (std::map<uint32_t, std::string>::const_iterator it = m_pathMapping.begin();
             it != m_pathMapping.end(); ++it) {
            addCandidate(candidates, unresolved, it->second);
        }
        for (size_t i = 0; i < sizeof(kKnownPaths) / sizeof(kKnownPaths[0]); ++i) {
            addCandidate(candidates, unresolved, kKnownPaths[i]);
        }

        for (size_t i = 0; i < files.size(); ++i) {
            std::vector<unsigned char> data;
            std::vector<std::string> tokens;
            std::string lowerRel = ToLowerCopy(files[i].relPath);
            std::string dirPath = GetDirectoryName(files[i].relPath);
            std::vector<std::string> texTokens;
            std::vector<std::string> localClipRefs;

            if (shouldReadForContentHeuristics(files[i])) {
                if (!ReadFileBytes(files[i].absPath, data)) {
                    continue;
                }
                tokens = ExtractContentTokens(data);
            }

            std::string modelNameFromPath;
            std::string aniGroupName;
            std::string aniSubgroupName;
            std::string aniActionName;
            std::string aniTail;
            if (!files[i].isRootNumeric &&
                SplitModelAniPath(files[i].relPath,
                                  modelNameFromPath,
                                  aniGroupName,
                                  aniSubgroupName,
                                  aniActionName,
                                  aniTail)) {
                PushUniqueSet(modelNames, modelNameFromPath);
                PushUniqueSet(actions, aniActionName);
                if (StartsWith(ToLowerCopy(aniActionName), "riding_")) {
                    PushUniqueSet(ridingActions, aniActionName);
                }
                if (ToLowerCopy(aniGroupName) == "body") {
                    PushUniqueSet(bodyNames, aniSubgroupName);
                } else if (ToLowerCopy(aniGroupName) == "weapon") {
                    PushUniqueSet(weaponNames, aniSubgroupName);
                }
            }

            std::string modelActionNameFromPath;
            std::string modelActionFromPath;
            if (!files[i].isRootNumeric &&
                SplitModelActionPath(files[i].relPath,
                                     modelActionNameFromPath,
                                     modelActionFromPath)) {
                PushUniqueSet(modelNames, modelActionNameFromPath);
                PushUniqueSet(actions, modelActionFromPath);
                if (StartsWith(ToLowerCopy(modelActionFromPath), "riding_")) {
                    PushUniqueSet(ridingActions, modelActionFromPath);
                }
            }

            std::string modelDyeNameFromPath;
            if (!files[i].isRootNumeric &&
                SplitModelDyePath(files[i].relPath, modelDyeNameFromPath)) {
                PushUniqueSet(modelNames, modelDyeNameFromPath);
            }

            std::string effectAnimationRefFromPath;
            if (!files[i].isRootNumeric &&
                SplitEffectAnimationPath(files[i].relPath, effectAnimationRefFromPath)) {
                animationRefs.insert(effectAnimationRefFromPath);
            }

            if (lowerRel == "table/bintable/npc.cnpcshape.bin") {
                ParseNpcShapeTableData(data, modelNames, actions);
            } else if (lowerRel == "table/bintable/npc.cactioninfo.bin") {
                ParseNpcActionInfoTableData(data, modelNames, actions, ridingActions);
            } else if (lowerRel == "table/bintable/npc.cride.bin") {
                ParseNpcRideTableData(data, rideModelIds);
            }

            for (size_t t = 0; t < tokens.size(); ++t) {
                const std::string token = NormalizeSlashesCopy(tokens[t]);
                const std::string tokenLower = ToLowerCopy(token);
                std::vector<std::string> quotedValues;
                std::vector<std::string> luaModuleRefs;
                ExtractQuotedStrings(token, quotedValues);
                ExtractLuaModuleRefs(token, luaModuleRefs);

                for (size_t moduleIndex = 0; moduleIndex < luaModuleRefs.size(); ++moduleIndex) {
                    const std::string scriptPath = LuaModuleRefToScriptPath(luaModuleRefs[moduleIndex]);
                    if (scriptPath.empty()) {
                        continue;
                    }
                    addCandidate(candidates, unresolved, scriptPath);
                    addCandidate(candidates, unresolved, ToLowerCopy(scriptPath));
                }

                for (size_t q = 0; q < quotedValues.size(); ++q) {
                    const std::string quoted = NormalizeSlashesCopy(quotedValues[q]);
                    const std::string quotedLower = ToLowerCopy(quoted);

                    if (quoted.find('/') != std::string::npos) {
                        if (StartsWith(quotedLower, "effect/") || StartsWith(quotedLower, "model/") ||
                            StartsWith(quotedLower, "table/") || StartsWith(quotedLower, "script/") ||
                            StartsWith(quotedLower, "ui/") || StartsWith(quotedLower, "map/")) {
                            addCandidate(candidates, unresolved, quoted);
                        }
                        if (StartsWith(quotedLower, "animation/")) {
                            animationRefs.insert(quoted);
                            addCandidate(candidates, unresolved, "effect/" + quoted + ".ani");
                        }
                        if (StartsWith(quotedLower, "geffect/")) {
                            geffectRefs.insert(quoted);
                            addCandidate(candidates, unresolved, "effect/" + quoted + ".eff.inf");
                        }
                        if (StartsWith(quotedLower, "spine/") && quoted.find('.') == std::string::npos) {
                            addCandidate(candidates, unresolved, "effect/" + quoted + ".atlas");
                            addCandidate(candidates, unresolved, "effect/" + quoted + ".json");
                        }
                    }

                    if (EndsWith(quotedLower, ".layout") && quoted.find('/') == std::string::npos) {
                        addCandidate(candidates, unresolved,
                                     "ui/layouts/" + ToLowerCopy(quoted));
                    }
                }

                if (token.find('/') != std::string::npos) {
                    if (StartsWith(tokenLower, "effect/") || StartsWith(tokenLower, "model/") ||
                        StartsWith(tokenLower, "table/") || StartsWith(tokenLower, "script/") ||
                        StartsWith(tokenLower, "ui/") || StartsWith(tokenLower, "map/")) {
                        addCandidate(candidates, unresolved, token);
                    }
                    if (StartsWith(tokenLower, "animation/")) {
                        if (EndsWith(tokenLower, ".png") || EndsWith(tokenLower, ".dds") ||
                            EndsWith(tokenLower, ".tga") || EndsWith(tokenLower, ".jpg") ||
                            EndsWith(tokenLower, ".jpeg") || EndsWith(tokenLower, ".webp")) {
                            addCandidate(candidates, unresolved,
                                         "effect/particle/texture/" + token);
                        } else {
                            addCandidate(candidates, unresolved, "effect/" + token + ".ani");
                            animationRefs.insert(token);
                        }
                    }
                    if (StartsWith(tokenLower, "geffect/")) {
                        geffectRefs.insert(token);
                        addCandidate(candidates, unresolved, "effect/" + token + ".eff.inf");
                    }
                    if (StartsWith(tokenLower, "spine/") && token.find('.') == std::string::npos) {
                        addCandidate(candidates, unresolved, "effect/" + token + ".atlas");
                        addCandidate(candidates, unresolved, "effect/" + token + ".json");
                    }
                }

                if (EndsWith(tokenLower, ".layout") && token.find('/') == std::string::npos) {
                    addCandidate(candidates, unresolved, "ui/layouts/" + token);
                }
                if (EndsWith(tokenLower, ".path") && token.find('/') == std::string::npos) {
                    addCandidate(candidates, unresolved, "effect/particle/path/" + token);
                }

                if (token.find("BeanConfigManager.getInstance():GetTableByName(") != std::string::npos ||
                    token.find("GetTableByName(") != std::string::npos) {
                    std::vector<std::string> tableNames;
                    ExtractQuotedCallArgs(token, "GetTableByName(", tableNames);
                    for (size_t j = 0; j < tableNames.size(); ++j) {
                        const std::string& tableName = tableNames[j];
                        addCandidate(candidates, unresolved, "table/bintable/" + tableName + ".bin");
                        size_t dot = tableName.find('.');
                        if (dot != std::string::npos && dot + 1 < tableName.size()) {
                            addCandidate(candidates, unresolved,
                                         "script/tabledef/" + tableName.substr(0, dot) + "/" +
                                         tableName.substr(dot + 1) + ".lua");
                        }
                    }
                }

                std::vector<std::string> literalModelNames;
                ExtractQuotedCallArgs(token, "UISpineSprite:new(", literalModelNames);
                ExtractQuotedCallArgs(token, "SetSpineModel(", literalModelNames);
                for (size_t j = 0; j < literalModelNames.size(); ++j) {
                    const std::string& modelName = literalModelNames[j];
                    if (modelName.find('/') == std::string::npos &&
                        modelName.find('.') == std::string::npos) {
                        addCandidate(candidates, unresolved,
                                     "model/" + modelName + "/" + modelName + ".atlas");
                        addCandidate(candidates, unresolved,
                                     "model/" + modelName + "/" + modelName + ".json");
                        addCandidate(candidates, unresolved,
                                     "model/" + modelName + "/" + modelName + ".png");
                    }
                }

                std::vector<std::string> attrValues;
                ExtractAttrValues(token, "model name=\"", attrValues);
                for (size_t j = 0; j < attrValues.size(); ++j) {
                    modelNames.insert(attrValues[j]);
                }
                attrValues.clear();
                ExtractAttrValues(token, "action name=\"", attrValues);
                for (size_t j = 0; j < attrValues.size(); ++j) {
                    actions.insert(attrValues[j]);
                    if (StartsWith(ToLowerCopy(attrValues[j]), "riding_")) {
                        ridingActions.insert(attrValues[j]);
                    }
                }
                attrValues.clear();
                ExtractAttrValues(token, "body name=\"", attrValues);
                for (size_t j = 0; j < attrValues.size(); ++j) {
                    bodyNames.insert(attrValues[j]);
                }
                attrValues.clear();
                ExtractAttrValues(token, "weapon name=\"", attrValues);
                for (size_t j = 0; j < attrValues.size(); ++j) {
                    weaponNames.insert(attrValues[j]);
                }
                attrValues.clear();
                ExtractAttrValues(token, "r_f=\"", attrValues);
                for (size_t j = 0; j < attrValues.size(); ++j) {
                    animationRefs.insert(attrValues[j]);
                    PushUnique(localClipRefs, attrValues[j]);
                    addCandidate(candidates, unresolved, "effect/" + attrValues[j] + ".ani");
                }

                if (token.find("_res") != std::string::npos &&
                    (EndsWith(tokenLower, ".png") || EndsWith(tokenLower, ".dds") ||
                     EndsWith(tokenLower, ".tga") || EndsWith(tokenLower, ".jpg") ||
                     EndsWith(tokenLower, ".jpeg") || EndsWith(tokenLower, ".webp"))) {
                    PushUnique(texTokens, token);
                }
            }

            if (files[i].isRootNumeric && files[i].ext == ".xml") {
                const std::string text(data.begin(), data.end());
                std::vector<std::string> layoutNameHints;
                ExtractUiLayoutNameHints(tokens, layoutNameHints);
                ExtractUiLayoutPrimaryNameHintsFromText(text, layoutNameHints);
                for (size_t hintIndex = 0; hintIndex < layoutNameHints.size(); ++hintIndex) {
                    const std::string layoutPath =
                        NormalizeOutputRelativePath("ui/layouts/" + layoutNameHints[hintIndex] +
                                                    ".layout");
                    if (!layoutPath.empty() && calcCRC(layoutPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, layoutPath);
                    } else {
                        addCandidate(candidates, unresolved, layoutPath);
                    }

                    const std::string lowerLayoutPath =
                        NormalizeOutputRelativePath("ui/layouts/" +
                                                    ToLowerCopy(layoutNameHints[hintIndex]) +
                                                    ".layout");
                    if (!lowerLayoutPath.empty() &&
                        calcCRC(lowerLayoutPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, lowerLayoutPath);
                    } else {
                        addCandidate(candidates, unresolved, lowerLayoutPath);
                    }
                }

                std::vector<std::string> imagesetNameHints;
                ExtractUiImagesetNameHintsFromText(text, imagesetNameHints);
                for (size_t hintIndex = 0; hintIndex < imagesetNameHints.size(); ++hintIndex) {
                    const std::string imagesetPath =
                        NormalizeOutputRelativePath("ui/imagesets/" +
                                                    imagesetNameHints[hintIndex] + ".imageset");
                    if (!imagesetPath.empty() && calcCRC(imagesetPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, imagesetPath);
                    } else {
                        addCandidate(candidates, unresolved, imagesetPath);
                    }

                    const std::string lowerImagesetPath =
                        NormalizeOutputRelativePath("ui/imagesets/" +
                                                    ToLowerCopy(imagesetNameHints[hintIndex]) +
                                                    ".imageset");
                    if (!lowerImagesetPath.empty() &&
                        calcCRC(lowerImagesetPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, lowerImagesetPath);
                    } else {
                        addCandidate(candidates, unresolved, lowerImagesetPath);
                    }
                }

                std::vector<std::string> fontNameHints;
                ExtractUiFontNameHintsFromText(text, fontNameHints);
                for (size_t hintIndex = 0; hintIndex < fontNameHints.size(); ++hintIndex) {
                    const std::string fontPath =
                        NormalizeOutputRelativePath("ui/fonts/" +
                                                    fontNameHints[hintIndex] + ".font");
                    if (!fontPath.empty() && calcCRC(fontPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, fontPath);
                    } else {
                        addCandidate(candidates, unresolved, fontPath);
                    }

                    const std::string lowerFontPath =
                        NormalizeOutputRelativePath("ui/fonts/" +
                                                    ToLowerCopy(fontNameHints[hintIndex]) +
                                                    ".font");
                    if (!lowerFontPath.empty() &&
                        calcCRC(lowerFontPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, lowerFontPath);
                    } else {
                        addCandidate(candidates, unresolved, lowerFontPath);
                    }
                }
            }

            if (files[i].isRootNumeric && files[i].ext == ".lua") {
                const std::string text(data.begin(), data.end());
                std::vector<std::string> luaModuleRefsFromText;
                std::vector<std::string> luaTopLevelSymbols;
                ExtractLuaModuleRefs(text, luaModuleRefsFromText);
                ExtractLuaTopLevelTableSymbols(text, luaTopLevelSymbols);

                std::set<std::string> luaModuleDirs;
                for (size_t moduleIndex = 0; moduleIndex < luaModuleRefsFromText.size(); ++moduleIndex) {
                    std::string modulePath = luaModuleRefsFromText[moduleIndex];
                    for (size_t ch = 0; ch < modulePath.size(); ++ch) {
                        if (modulePath[ch] == '.') {
                            modulePath[ch] = '/';
                        }
                    }
                    modulePath = NormalizeSlashesCopy(modulePath);
                    std::string moduleDir = GetDirectoryName(modulePath);
                    if (!moduleDir.empty()) {
                        luaModuleDirs.insert(moduleDir);
                    }
                }

                for (std::set<std::string>::const_iterator dirIt = luaModuleDirs.begin();
                     dirIt != luaModuleDirs.end(); ++dirIt) {
                    for (size_t symbolIndex = 0; symbolIndex < luaTopLevelSymbols.size();
                         ++symbolIndex) {
                        const std::string symbolStem = ToLowerCopy(luaTopLevelSymbols[symbolIndex]);
                        if (symbolStem.empty()) {
                            continue;
                        }
                        const std::string scriptPath =
                            NormalizeOutputRelativePath(
                                JoinPath("script", JoinPath(*dirIt, symbolStem + ".lua")));
                        if (!scriptPath.empty() && calcCRC(scriptPath) == files[i].rootCRC) {
                            addDirectCandidate(directCandidates, unresolved,
                                               files[i].rootCRC, scriptPath);
                        } else {
                            addCandidate(candidates, unresolved, scriptPath);
                        }
                    }
                }
            }

            if (!files[i].isRootNumeric && files[i].ext == ".imageset") {
                const std::string text(data.begin(), data.end());
                std::vector<std::string> imagePathHints;
                ExtractUiImagesetImagePathHintsFromText(text, imagePathHints);
                for (size_t hintIndex = 0; hintIndex < imagePathHints.size(); ++hintIndex) {
                    const std::string normalizedHint =
                        NormalizeSlashesCopy(imagePathHints[hintIndex]);
                    if (normalizedHint.empty()) {
                        continue;
                    }

                    std::vector<std::string> imageCandidates;
                    if (normalizedHint.find('/') != std::string::npos) {
                        PushUnique(imageCandidates, normalizedHint);
                    }
                    if (!dirPath.empty()) {
                        PushUnique(imageCandidates, JoinPath(dirPath, normalizedHint));
                    } else {
                        PushUnique(imageCandidates, normalizedHint);
                    }

                    for (size_t candidateIndex = 0;
                         candidateIndex < imageCandidates.size();
                         ++candidateIndex) {
                        const std::string normalizedImagePath =
                            NormalizeOutputRelativePath(imageCandidates[candidateIndex]);
                        if (normalizedImagePath.empty()) {
                            continue;
                        }

                        const uint32_t imageCrc = calcCRC(normalizedImagePath);
                        if (unresolved.find(imageCrc) != unresolved.end()) {
                            addDirectCandidate(directCandidates, unresolved,
                                               imageCrc, normalizedImagePath);
                        }

                        const std::string lowerImagePath = ToLowerCopy(normalizedImagePath);
                        if (lowerImagePath != normalizedImagePath) {
                            const uint32_t lowerImageCrc = calcCRC(lowerImagePath);
                            if (unresolved.find(lowerImageCrc) != unresolved.end()) {
                                addDirectCandidate(directCandidates, unresolved,
                                                   lowerImageCrc, lowerImagePath);
                            }
                        }
                    }
                }
            }

            if (StartsWith(lowerRel, "script/tabledef/") && EndsWith(lowerRel, ".lua")) {
                std::string sub = files[i].relPath.substr(std::string("script/tabledef/").size());
                sub = RemoveExtension(sub);
                for (size_t j = 0; j < sub.size(); ++j) {
                    if (sub[j] == '/') {
                        sub[j] = '.';
                    }
                }
                addCandidate(candidates, unresolved, "table/bintable/" + sub + ".bin");
            }

            if (lowerRel == "table/bintable/map.cmapconfig.bin") {
                std::set<std::string> mapResDirs;
                if (!ParseMapConfigResDirsFromBinary(data, mapResDirs)) {
                    for (size_t t = 0; t < tokens.size(); ++t) {
                        const std::string token = tokens[t];
                        if (token.empty() || token.find('/') != std::string::npos ||
                            token.find('.') != std::string::npos || token.find('_') == std::string::npos ||
                            !std::isdigit(static_cast<unsigned char>(token[0]))) {
                            continue;
                        }
                        mapResDirs.insert(token);
                    }
                }
                const char* kMapLeafNames[] = {
                    "maze.dat",
                    "monster.dat",
                    "goto.dat",
                    "regiontypeinfo.dat",
                    "npc.dat",
                    "jumpblock.dat",
                    "island.dat",
                    "island2.dat"
                };
                for (std::set<std::string>::const_iterator resIt = mapResDirs.begin();
                     resIt != mapResDirs.end(); ++resIt) {
                    for (size_t leafIndex = 0;
                         leafIndex < sizeof(kMapLeafNames) / sizeof(kMapLeafNames[0]);
                         ++leafIndex) {
                        addCandidate(candidates, unresolved,
                                     "map/" + *resIt + "/" + kMapLeafNames[leafIndex]);
                    }
                }
            }

            if (StartsWith(lowerRel, "effect/animation/skill/") && !files[i].isRootNumeric) {
                std::string skillRest =
                    files[i].relPath.substr(std::string("effect/animation/skill/").size());
                size_t slash = skillRest.find('/');
                if (slash != std::string::npos) {
                    const std::string family = skillRest.substr(0, slash);
                    const std::string leaf = skillRest.substr(slash + 1);
                    if (!StartsWith(ToLowerCopy(family), "acc")) {
                        for (int aliasIndex = 1; aliasIndex <= 9; ++aliasIndex) {
                            std::ostringstream aliasDir;
                            aliasDir << "effect/animation/skill/acc" << aliasIndex << "-" << family;
                            addCandidate(candidates, unresolved,
                                         JoinPath(aliasDir.str(), leaf));
                        }
                    }
                }
            }

            if (files[i].ext == ".ani" && !files[i].isRootNumeric && !texTokens.empty()) {
                namedAniTextures.push_back(std::make_pair(files[i].relPath, texTokens));
            } else if (files[i].ext == ".ani" && files[i].isRootNumeric && !tokens.empty()) {
                rootAniTokens.push_back(std::make_pair(files[i].rootCRC, tokens));
            }

            if (files[i].ext == ".atlas") {
                std::string pageName = ParseFirstNonEmptyLine(data);
                std::string modelStem = RemoveExtension(GetFileName(pageName));
                if (files[i].isRootNumeric && !modelStem.empty()) {
                    const std::string exactAtlasPath =
                        "model/" + modelStem + "/" + modelStem + ".atlas";
                    if (calcCRC(exactAtlasPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, exactAtlasPath);
                    } else {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC,
                                           "model/" + modelStem + "/" +
                                           std::to_string(files[i].rootCRC) + ".atlas");
                    }
                }
                if (!pageName.empty() && !files[i].isRootNumeric) {
                    std::vector<std::string> atlasPagePathHints;
                    BuildAtlasPagePathHints(dirPath, pageName, atlasPagePathHints);
                    if (!modelStem.empty()) {
                        BuildAtlasPagePathHints("model/" + modelStem, pageName, atlasPagePathHints);
                    }
                    for (size_t hintIndex = 0;
                         hintIndex < atlasPagePathHints.size();
                         ++hintIndex) {
                        const std::string exactPagePath =
                            NormalizeOutputRelativePath(atlasPagePathHints[hintIndex]);
                        if (exactPagePath.empty()) {
                            continue;
                        }
                        const uint32_t exactPageCrc = calcCRC(exactPagePath);
                        if (unresolved.find(exactPageCrc) != unresolved.end()) {
                            addDirectCandidate(directCandidates, unresolved,
                                               exactPageCrc, exactPagePath);
                        }
                    }
                }
                if (!pageName.empty() && !dirPath.empty()) {
                    addCandidate(candidates, unresolved, JoinPath(dirPath, pageName));
                }
                if (!modelStem.empty() && !pageName.empty()) {
                    addCandidate(candidates, unresolved, "model/" + modelStem + "/" + pageName);
                }
                std::set<std::string> regions;
                ExtractAtlasRegionNames(data, regions);
                if (!regions.empty() && !dirPath.empty()) {
                    atlasRegionsByDir[dirPath] = regions;
                }
            }

            if (files[i].ext == ".json" && files[i].isRootNumeric) {
                std::string uniqueStem = FindUniqueSpineStem(tokens);
                std::string fallbackUniqueStem;
                if (!uniqueStem.empty()) {
                    const std::string exactJsonPath =
                        "model/" + uniqueStem + "/" + uniqueStem + ".json";
                    if (calcCRC(exactJsonPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, exactJsonPath);
                    } else {
                        if (uniqueStem.find('-') == std::string::npos) {
                            fallbackUniqueStem = uniqueStem;
                        }
                    }
                }

                std::set<std::string> attachments;
                std::set<std::string> exactJsonTargets;
                std::set<std::string> numericJsonTargets;
                ExtractSpineJsonAttachments(data, attachments);
                for (std::map<std::string, std::set<std::string> >::const_iterator atlasIt = atlasRegionsByDir.begin();
                     atlasIt != atlasRegionsByDir.end(); ++atlasIt) {
                    bool coversAll = !attachments.empty();
                    for (std::set<std::string>::const_iterator attIt = attachments.begin();
                         attIt != attachments.end(); ++attIt) {
                        if (atlasIt->second.find(*attIt) == atlasIt->second.end()) {
                            coversAll = false;
                            break;
                        }
                    }
                    if (coversAll) {
                        const std::string dirLeaf = GetFileName(atlasIt->first);
                        exactJsonTargets.insert(
                            JoinPath(atlasIt->first, dirLeaf + ".json"));
                        numericJsonTargets.insert(
                            JoinPath(atlasIt->first,
                                     std::to_string(files[i].rootCRC) + ".json"));
                    }
                }
                for (std::set<std::string>::const_iterator exactIt = exactJsonTargets.begin();
                     exactIt != exactJsonTargets.end(); ++exactIt) {
                    if (calcCRC(*exactIt) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, *exactIt);
                    }
                }
                if (directCandidates.find(files[i].rootCRC) == directCandidates.end()) {
                    if (numericJsonTargets.size() == 1) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC,
                                           *numericJsonTargets.begin());
                    } else if (!fallbackUniqueStem.empty()) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC,
                                           "model/" + fallbackUniqueStem + "/" +
                                           std::to_string(files[i].rootCRC) + ".json");
                    }
                }
            }

            if (files[i].isRootNumeric &&
                (files[i].ext == ".xml" || files[i].ext == ".eff.inf") &&
                !localClipRefs.empty()) {
                for (size_t j = 0; j < localClipRefs.size(); ++j) {
                    const std::string animRef = NormalizeSlashesCopy(localClipRefs[j]);
                    const std::string animLower = ToLowerCopy(animRef);
                    if (!StartsWith(animLower, "animation/")) {
                        continue;
                    }

                    const std::string animRest = animRef.substr(std::string("animation/").size());
                    bool resolvedByExact = false;
                    for (std::set<std::string>::const_iterator geIt = geffectRefs.begin();
                         geIt != geffectRefs.end(); ++geIt) {
                        const std::string geffectRef = NormalizeSlashesCopy(*geIt);
                        const std::string geffectLower = ToLowerCopy(geffectRef);
                        if (!StartsWith(geffectLower, "geffect/")) {
                            continue;
                        }
                        const std::string geffectRest =
                            geffectRef.substr(std::string("geffect/").size());
                        if (ToLowerCopy(geffectRest) != ToLowerCopy(animRest)) {
                            continue;
                        }

                        const std::string exactEffectPath =
                            "effect/" + geffectRef + ".eff.inf";
                        if (calcCRC(exactEffectPath) == files[i].rootCRC) {
                            addDirectCandidate(directCandidates, unresolved,
                                               files[i].rootCRC, exactEffectPath);
                            resolvedByExact = true;
                        } else {
                            addDirectCandidate(directCandidates, unresolved,
                                               files[i].rootCRC,
                                               "effect/geffect/" + GetDirectoryName(geffectRest) +
                                               "/" + std::to_string(files[i].rootCRC) + ".eff.inf");
                        }
                    }

                    if (resolvedByExact) {
                        continue;
                    }

                    std::string exactEffectPath;
                    std::string canonicalEffectPath;
                    if (StartsWith(animLower, "animation/sprite/npc/")) {
                        const std::string leaf = GetFileName(animRef);
                        exactEffectPath = "effect/geffect/sprite/npc/" + leaf + ".eff.inf";
                        canonicalEffectPath =
                            "effect/geffect/sprite/npc/" +
                            std::to_string(files[i].rootCRC) + ".eff.inf";
                    } else if (StartsWith(animLower, "animation/sprite/title/")) {
                        const std::string leaf = GetFileName(animRef);
                        exactEffectPath = "effect/geffect/sprite/title/" + leaf + ".eff.inf";
                        canonicalEffectPath =
                            "effect/geffect/sprite/title/" +
                            std::to_string(files[i].rootCRC) + ".eff.inf";
                    } else {
                        const std::string effectDir = GetDirectoryName(animRest);
                        if (!effectDir.empty()) {
                            canonicalEffectPath =
                                "effect/geffect/" + effectDir + "/" +
                                std::to_string(files[i].rootCRC) + ".eff.inf";
                        }
                        if (StartsWith(animLower, "animation/sprite/") &&
                            GetDirectoryName(animRest) == "sprite") {
                            canonicalEffectPath =
                                "effect/geffect/sprite/" +
                                std::to_string(files[i].rootCRC) + ".eff.inf";
                        }
                    }

                    if (!exactEffectPath.empty() &&
                        calcCRC(exactEffectPath) == files[i].rootCRC) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, exactEffectPath);
                    } else if (!canonicalEffectPath.empty()) {
                        addDirectCandidate(directCandidates, unresolved,
                                           files[i].rootCRC, canonicalEffectPath);
                    }
                }
            }
        }

        for (size_t i = 0; i < files.size(); ++i) {
            if (files[i].ext != ".json" || !files[i].isRootNumeric) {
                continue;
            }

            std::vector<unsigned char> data;
            if (!ReadFileBytes(files[i].absPath, data)) {
                continue;
            }

            std::vector<std::string> tokens = ExtractContentTokens(data);
            std::string uniqueStem = FindUniqueSpineStem(tokens);
            std::string fallbackUniqueStem;
            if (!uniqueStem.empty()) {
                const std::string exactJsonPath =
                    "model/" + uniqueStem + "/" + uniqueStem + ".json";
                if (calcCRC(exactJsonPath) == files[i].rootCRC) {
                    addDirectCandidate(directCandidates, unresolved,
                                       files[i].rootCRC, exactJsonPath);
                    continue;
                }
                if (uniqueStem.find('-') == std::string::npos) {
                    fallbackUniqueStem = uniqueStem;
                }
            }

            std::set<std::string> attachments;
            std::set<std::string> exactJsonTargets;
            std::set<std::string> numericJsonTargets;
            ExtractSpineJsonAttachments(data, attachments);
            for (std::map<std::string, std::set<std::string> >::const_iterator atlasIt = atlasRegionsByDir.begin();
                 atlasIt != atlasRegionsByDir.end(); ++atlasIt) {
                bool coversAll = !attachments.empty();
                for (std::set<std::string>::const_iterator attIt = attachments.begin();
                     attIt != attachments.end(); ++attIt) {
                    if (atlasIt->second.find(*attIt) == atlasIt->second.end()) {
                        coversAll = false;
                        break;
                    }
                }
                if (coversAll) {
                    const std::string dirLeaf = GetFileName(atlasIt->first);
                    exactJsonTargets.insert(JoinPath(atlasIt->first, dirLeaf + ".json"));
                    numericJsonTargets.insert(
                        JoinPath(atlasIt->first, std::to_string(files[i].rootCRC) + ".json"));
                }
            }

            for (std::set<std::string>::const_iterator exactIt = exactJsonTargets.begin();
                 exactIt != exactJsonTargets.end(); ++exactIt) {
                if (calcCRC(*exactIt) == files[i].rootCRC) {
                    addDirectCandidate(directCandidates, unresolved,
                                       files[i].rootCRC, *exactIt);
                }
            }
            if (directCandidates.find(files[i].rootCRC) == directCandidates.end()) {
                if (numericJsonTargets.size() == 1) {
                    addDirectCandidate(directCandidates, unresolved,
                                       files[i].rootCRC, *numericJsonTargets.begin());
                } else if (!fallbackUniqueStem.empty()) {
                    addDirectCandidate(directCandidates, unresolved,
                                       files[i].rootCRC,
                                       "model/" + fallbackUniqueStem + "/" +
                                       std::to_string(files[i].rootCRC) + ".json");
                }
            }
        }

        for (size_t i = 0; i < namedAniTextures.size(); ++i) {
            const std::string aniPath = namedAniTextures[i].first;
            const std::string dirPath = GetDirectoryName(aniPath);
            const std::string stem = GetFileName(RemoveExtension(aniPath));
            for (size_t t = 0; t < namedAniTextures[i].second.size(); ++t) {
                std::string token = GetFileName(namedAniTextures[i].second[t]);
                std::string tokenStem = RemoveExtension(token);
                std::string tokenExt = GetExtensionLower(token);
                if (!tokenStem.empty() && tokenStem[0] == '_') {
                    tokenStem = stem + tokenStem;
                }
                if (!tokenStem.empty() && !tokenExt.empty()) {
                    addCandidate(candidates, unresolved, JoinPath(dirPath, tokenStem + tokenExt));
                }
                for (size_t e = 0; e < sizeof(kImageExts) / sizeof(kImageExts[0]); ++e) {
                    addCandidate(candidates, unresolved, JoinPath(dirPath, tokenStem + kImageExts[e]));
                }
            }
        }

        for (size_t i = 0; i < rootAniTokens.size(); ++i) {
            std::set<std::string> dirHits;
            std::set<std::string> baseNames;
            const std::vector<std::string>& aniTokens = rootAniTokens[i].second;

            for (size_t t = 0; t < aniTokens.size(); ++t) {
                const std::string token = GetFileName(aniTokens[t]);
                const std::string tokenLower = ToLowerCopy(token);
                if (token.find("_res") == std::string::npos) {
                    continue;
                }

                std::string suffixBase = RemoveExtension(token);
                if (suffixBase.empty()) {
                    continue;
                }

                if (suffixBase[0] != '_') {
                    baseNames.insert(suffixBase);
                    continue;
                }

                for (size_t hintIndex = 0; hintIndex < aniTokens.size(); ++hintIndex) {
                    const std::string hint = aniTokens[hintIndex];
                    if (hint.find('/') != std::string::npos || hint.find('.') != std::string::npos) {
                        continue;
                    }
                    if (hint.find('<') != std::string::npos || hint.find('>') != std::string::npos) {
                        continue;
                    }
                    if (hint == "_res000" || hint == "_res001" || hint == "_res002") {
                        continue;
                    }
                    baseNames.insert(hint + suffixBase);
                }
            }

            for (size_t fileIndex = 0; fileIndex < files.size(); ++fileIndex) {
                if (files[fileIndex].isRootNumeric) {
                    continue;
                }
                const std::string ext = ToLowerCopy(files[fileIndex].ext);
                bool isImage = false;
                for (size_t e = 0; e < sizeof(kImageExts) / sizeof(kImageExts[0]); ++e) {
                    if (ext == kImageExts[e]) {
                        isImage = true;
                        break;
                    }
                }
                if (!isImage) {
                    continue;
                }

                std::string imageBase = GetFileName(RemoveExtension(files[fileIndex].relPath));
                if (baseNames.find(imageBase) != baseNames.end()) {
                    dirHits.insert(GetDirectoryName(files[fileIndex].relPath));
                }
            }

            if (dirHits.size() == 1) {
                addDirectCandidate(directCandidates, unresolved,
                                   rootAniTokens[i].first,
                                   JoinPath(*dirHits.begin(),
                                            std::to_string(rootAniTokens[i].first) + ".ani"));
            }
        }

        for (std::set<std::string>::const_iterator modelIt = modelNames.begin();
             modelIt != modelNames.end(); ++modelIt) {
            const std::string modelName = *modelIt;
            addCandidate(candidates, unresolved, "model/" + modelName + "/action/action.lmx");
            addCandidate(candidates, unresolved, "model/" + modelName + "/layerdef.lmx");
            addCandidate(candidates, unresolved, "model/" + modelName + "/body/body.lmx");
            addCandidate(candidates, unresolved, "model/" + modelName + "/weapon/weapon.lmx");
            addCandidate(candidates, unresolved, "model/" + modelName + "/dyeinfo.dye");
            addCandidate(candidates, unresolved, "model/" + modelName + "/" + modelName + ".atlas");
            addCandidate(candidates, unresolved, "model/" + modelName + "/" + modelName + ".json");
            addCandidate(candidates, unresolved, "model/" + modelName + "/" + modelName + ".png");

            for (std::set<std::string>::const_iterator actionIt = actions.begin();
                 actionIt != actions.end(); ++actionIt) {
                addCandidate(candidates, unresolved,
                             "model/" + modelName + "/action/" + *actionIt + ".act");
                for (std::set<std::string>::const_iterator bodyIt = bodyNames.begin();
                     bodyIt != bodyNames.end(); ++bodyIt) {
                    addCandidate(candidates, unresolved,
                                 "model/" + modelName + "/body/" + *bodyIt + "/" + *actionIt + ".ani");
                    addModelActionImageCandidates("model/" + modelName + "/body/" + *bodyIt + "/",
                                                  *actionIt);
                }
                for (std::set<std::string>::const_iterator weaponIt = weaponNames.begin();
                     weaponIt != weaponNames.end(); ++weaponIt) {
                    addCandidate(candidates, unresolved,
                                 "model/" + modelName + "/weapon/" + *weaponIt + "/" + *actionIt + ".ani");
                    addModelActionImageCandidates("model/" + modelName + "/weapon/" + *weaponIt + "/",
                                                  *actionIt);
                }
            }
            for (std::set<std::string>::const_iterator actionIt = ridingActions.begin();
                 actionIt != ridingActions.end(); ++actionIt) {
                for (std::set<std::string>::const_iterator bodyIt = bodyNames.begin();
                     bodyIt != bodyNames.end(); ++bodyIt) {
                    addCandidate(candidates, unresolved,
                                 "model/" + modelName + "/body/" + *bodyIt + "/" + *actionIt + ".ani");
                }
            }
        }

        for (std::set<std::string>::const_iterator rideIt = rideModelIds.begin();
             rideIt != rideModelIds.end(); ++rideIt) {
            for (std::set<std::string>::const_iterator actionIt = ridingActions.begin();
                 actionIt != ridingActions.end(); ++actionIt) {
                addCandidate(candidates, unresolved,
                             "model/mt_zuoqi/ride1/" + *rideIt + "/" + *actionIt + ".ani");
                addModelActionImageCandidates("model/mt_zuoqi/ride1/" + *rideIt + "/",
                                              *actionIt);
            }
        }

        for (std::set<std::string>::const_iterator animIt = animationRefs.begin();
             animIt != animationRefs.end(); ++animIt) {
            const std::string animRef = *animIt;
            addCandidate(candidates, unresolved, "effect/" + animRef + ".ani");
            addEffectAnimationImageCandidates(animRef);
            if (StartsWith(ToLowerCopy(animRef), "animation/skill/")) {
                std::string skillRest = animRef.substr(std::string("animation/skill/").size());
                size_t slash = skillRest.find('/');
                if (slash != std::string::npos) {
                    const std::string family = skillRest.substr(0, slash);
                    const std::string leaf = skillRest.substr(slash + 1);
                    for (int aliasIndex = 1; aliasIndex <= 9; ++aliasIndex) {
                        std::ostringstream aliasDir;
                        aliasDir << "animation/skill/acc" << aliasIndex << "-" << family;
                        addCandidate(candidates, unresolved,
                                     "effect/" + JoinPath(aliasDir.str(), leaf) + ".ani");
                        addEffectAnimationImageCandidates(JoinPath(aliasDir.str(), leaf));
                    }
                }
            }
        }

        bool passChanged = false;
        if (applyCandidates(candidates, unresolved, false)) {
            passChanged = true;
        }
        if (applyCandidates(directCandidates, unresolved, false)) {
            passChanged = true;
        }
        if (!passChanged) {
            break;
        }
        changed = true;
    }

    {
        std::vector<OutputFile> files;
        std::map<uint32_t, OutputFile> unresolved;
        scanOutputs(files, unresolved);
        std::map<std::string, std::set<std::string> > atlasRegionsByDir;
        for (size_t i = 0; i < files.size(); ++i) {
            if (files[i].isRootNumeric || files[i].ext != ".atlas") {
                continue;
            }
            std::vector<unsigned char> data;
            if (!ReadFileBytes(files[i].absPath, data)) {
                continue;
            }
            std::set<std::string> regions;
            ExtractAtlasRegionNames(data, regions);
            if (!regions.empty()) {
                atlasRegionsByDir[GetDirectoryName(files[i].relPath)] = regions;
            }
        }

        for (std::map<uint32_t, OutputFile>::const_iterator it = unresolved.begin();
             it != unresolved.end(); ++it) {
            if (it->second.ext != ".json") {
                continue;
            }

            std::vector<unsigned char> data;
            if (!ReadFileBytes(it->second.absPath, data)) {
                continue;
            }

            std::set<std::string> attachments;
            ExtractSpineJsonAttachments(data, attachments);
            if (attachments.empty()) {
                continue;
            }

            for (std::map<std::string, std::set<std::string> >::const_iterator atlasIt = atlasRegionsByDir.begin();
                 atlasIt != atlasRegionsByDir.end(); ++atlasIt) {
                bool coversAll = true;
                for (std::set<std::string>::const_iterator attIt = attachments.begin();
                     attIt != attachments.end(); ++attIt) {
                    if (atlasIt->second.find(*attIt) == atlasIt->second.end()) {
                        coversAll = false;
                        break;
                    }
                }
                if (!coversAll) {
                    continue;
                }

                const std::string dirLeaf = GetFileName(atlasIt->first);
                const std::string exactJsonPath =
                    JoinPath(atlasIt->first, dirLeaf + ".json");
                if (calcCRC(exactJsonPath) != it->first) {
                    continue;
                }
                const std::string targetAbs = JoinPath(m_outputDir, exactJsonPath);
                CreateDirectoryRecursive(GetDirectoryName(targetAbs));
                if (FileExistsPath(targetAbs)) {
                    std::vector<unsigned char> srcData;
                    std::vector<unsigned char> dstData;
                    if (ReadFileBytes(it->second.absPath, srcData) &&
                        ReadFileBytes(targetAbs, dstData) &&
                        srcData == dstData) {
                        DeleteFilePath(it->second.absPath);
                        changed = true;
                    }
                } else if (MoveFileReplacePath(it->second.absPath, targetAbs)) {
                    changed = true;
                }
                break;
            }
        }
    }

    if (m_options.writeReviewAliases) {
        auto reviewMakeSignature = [&](const std::string& ext, size_t size, uint32_t contentCRC) {
            std::ostringstream sig;
            sig << ToLowerCopy(ext) << "#" << size << "#" << contentCRC;
            return sig.str();
        };
        auto isImageExtension = [&](const std::string& ext) -> bool {
            for (size_t e = 0; e < sizeof(kImageExts) / sizeof(kImageExts[0]); ++e) {
                if (ToLowerCopy(ext) == kImageExts[e]) {
                    return true;
                }
            }
            return false;
        };
        auto moveOrDedup = [&](const std::string& srcAbs,
                               const std::string& targetRel) -> bool {
            const std::string safeTargetRel = NormalizeOutputRelativePath(targetRel);
            if (safeTargetRel.empty()) {
                return false;
            }
            const std::string targetAbs = JoinPath(m_outputDir, safeTargetRel);
            CreateDirectoryRecursive(GetDirectoryName(targetAbs));
            if (FileExistsPath(targetAbs)) {
                std::vector<unsigned char> srcData;
                std::vector<unsigned char> dstData;
                if (ReadFileBytes(srcAbs, srcData) &&
                    ReadFileBytes(targetAbs, dstData) &&
                    srcData == dstData) {
                    DeleteFilePath(srcAbs);
                    return true;
                }
                return false;
            }
            return MoveFileReplacePath(srcAbs, targetAbs);
        };
        auto copyIfMissing = [&](const std::string& srcAbs,
                                 const std::string& targetRel) -> bool {
            const std::string safeTargetRel = NormalizeOutputRelativePath(targetRel);
            if (safeTargetRel.empty()) {
                return false;
            }
            const std::string targetAbs = JoinPath(m_outputDir, safeTargetRel);
            CreateDirectoryRecursive(GetDirectoryName(targetAbs));
            if (FileExistsPath(targetAbs)) {
                return false;
            }
            return CopyFileReplacePath(srcAbs, targetAbs);
        };
        auto writeReport = [&](const std::string& relPath,
                               const std::string& header,
                               const std::vector<std::string>& lines) {
            std::ostringstream oss;
            oss << header << "\n";
            for (size_t i = 0; i < lines.size(); ++i) {
                oss << lines[i] << "\n";
            }
            const std::string text = oss.str();
            std::vector<unsigned char> bytes(text.begin(), text.end());
            const std::string safeRelPath = NormalizeOutputRelativePath(relPath);
            if (safeRelPath.empty()) {
                return;
            }
            const std::string targetAbs = JoinPath(m_outputDir, safeRelPath);
            CreateDirectoryRecursive(GetDirectoryName(targetAbs));
            WriteFileBytes(targetAbs, bytes);
        };

        std::vector<std::string> aniReportLines;
        std::vector<std::string> pageReportLines;

        std::vector<OutputFile> files;
        std::map<uint32_t, OutputFile> unresolved;
        scanOutputs(files, unresolved);
        for (size_t i = 0; i < files.size(); ++i) {
            if (files[i].relPath.find("model/") != 0) {
                continue;
            }
            const std::string dirPath = GetDirectoryName(files[i].relPath);
            const std::string dirLeaf = GetFileName(dirPath);
            const std::string fileStem = GetFileName(RemoveExtension(files[i].relPath));
            if (IsDigitsOnly(fileStem) && (files[i].ext == ".atlas" || files[i].ext == ".json")) {
                const std::string aliasRel = JoinPath(dirPath, dirLeaf + files[i].ext);
                if (copyIfMissing(files[i].absPath, aliasRel)) {
                    changed = true;
                }
            }
        }

        std::map<std::string, std::set<std::string> > modelAniTailsBySignature;
        std::vector<OutputFile> rootAniFiles;
        for (size_t i = 0; i < files.size(); ++i) {
            if (files[i].ext == ".ani" && files[i].isRootNumeric) {
                rootAniFiles.push_back(files[i]);
                continue;
            }
            if (files[i].ext != ".ani" ||
                files[i].isRootNumeric ||
                files[i].relPath.find("model/") != 0) {
                continue;
            }

            std::string modelName;
            std::string groupName;
            std::string subgroupName;
            std::string actionName;
            std::string tail;
            if (!SplitModelAniPath(files[i].relPath,
                                   modelName,
                                   groupName,
                                   subgroupName,
                                   actionName,
                                   tail)) {
                continue;
            }

            std::vector<unsigned char> data;
            if (!ReadFileBytes(files[i].absPath, data)) {
                continue;
            }
            const uint32_t contentCRC = m_crc32Func(0,
                data.empty() ? reinterpret_cast<const unsigned char*>("") : &data[0],
                static_cast<unsigned int>(data.size()));
            modelAniTailsBySignature[reviewMakeSignature(files[i].ext, data.size(), contentCRC)]
                .insert(tail);
        }

        for (size_t i = 0; i < rootAniFiles.size(); ++i) {
            std::vector<unsigned char> data;
            if (!ReadFileBytes(rootAniFiles[i].absPath, data)) {
                continue;
            }

            const uint32_t contentCRC = m_crc32Func(0,
                data.empty() ? reinterpret_cast<const unsigned char*>("") : &data[0],
                static_cast<unsigned int>(data.size()));
            const std::string sig =
                reviewMakeSignature(rootAniFiles[i].ext, data.size(), contentCRC);
            std::map<std::string, std::set<std::string> >::const_iterator sigIt =
                modelAniTailsBySignature.find(sig);
            if (sigIt == modelAniTailsBySignature.end() || sigIt->second.empty()) {
                continue;
            }

            std::string aliasRel;
            std::string reason;
            if (sigIt->second.size() == 1) {
                const std::string tail = *sigIt->second.begin();
                aliasRel =
                    "review/model_ani/" + RemoveExtension(tail) +
                    ".candidate." + std::to_string(rootAniFiles[i].rootCRC) + ".ani";
                reason = "tail_alias";
            } else {
                std::set<std::string> leafNames;
                for (std::set<std::string>::const_iterator tailIt = sigIt->second.begin();
                     tailIt != sigIt->second.end(); ++tailIt) {
                    leafNames.insert(GetFileName(RemoveExtension(*tailIt)));
                }
                std::string leafStem =
                    leafNames.size() == 1 ? *leafNames.begin()
                                          : std::to_string(rootAniFiles[i].rootCRC);
                aliasRel =
                    "review/model_ani_leaf/" + leafStem +
                    ".candidate." + std::to_string(rootAniFiles[i].rootCRC) + ".ani";
                reason = "ambiguous";
            }

            if (moveOrDedup(rootAniFiles[i].absPath, aliasRel)) {
                changed = true;
                aniReportLines.push_back(reason + "|" + rootAniFiles[i].relPath + "|" + aliasRel);
            }
        }

        scanOutputs(files, unresolved);
        std::vector<std::string> currentModelAniPaths;
        std::vector<OutputFile> rootImageFiles;
        std::map<std::string, AtlasPrimaryPageInfo> atlasPageNameByDir;
        for (size_t i = 0; i < files.size(); ++i) {
            if (!files[i].isRootNumeric &&
                files[i].ext == ".ani" &&
                files[i].relPath.find("model/") == 0) {
                currentModelAniPaths.push_back(files[i].relPath);
            }
            if (files[i].isRootNumeric && isImageExtension(files[i].ext)) {
                rootImageFiles.push_back(files[i]);
            }
            if (!files[i].isRootNumeric &&
                files[i].ext == ".atlas" &&
                files[i].relPath.find("model/") == 0) {
                std::vector<unsigned char> data;
                if (!ReadFileBytes(files[i].absPath, data)) {
                    continue;
                }
                AtlasPrimaryPageInfo pageInfo;
                if (ParseAtlasPrimaryPageInfo(data, &pageInfo) &&
                    !pageInfo.pageName.empty()) {
                    atlasPageNameByDir[GetDirectoryName(files[i].relPath)] = pageInfo;
                }
            }
        }

        for (size_t i = 0; i < rootImageFiles.size(); ++i) {
            std::set<std::string> matchedTargets;
            for (size_t aniIndex = 0; aniIndex < currentModelAniPaths.size(); ++aniIndex) {
                const std::string dirPath = GetDirectoryName(currentModelAniPaths[aniIndex]);
                const std::string stem =
                    GetFileName(RemoveExtension(currentModelAniPaths[aniIndex]));
                for (int variantIndex = 0; variantIndex <= 9; ++variantIndex) {
                    const std::string candidate =
                        JoinPath(dirPath,
                                 stem + FormatResVariant(variantIndex) + rootImageFiles[i].ext);
                    if (calcCRC(candidate) == rootImageFiles[i].rootCRC) {
                        matchedTargets.insert(candidate);
                    }
                }
            }

            if (matchedTargets.size() == 1 &&
                moveOrDedup(rootImageFiles[i].absPath, *matchedTargets.begin())) {
                changed = true;
            }
        }

        scanOutputs(files, unresolved);
        rootImageFiles.clear();
        atlasPageNameByDir.clear();
        for (size_t i = 0; i < files.size(); ++i) {
            if (files[i].isRootNumeric && isImageExtension(files[i].ext)) {
                rootImageFiles.push_back(files[i]);
            }
            if (!files[i].isRootNumeric &&
                files[i].ext == ".atlas" &&
                files[i].relPath.find("model/") == 0) {
                std::vector<unsigned char> data;
                if (!ReadFileBytes(files[i].absPath, data)) {
                    continue;
                }
                AtlasPrimaryPageInfo pageInfo;
                if (ParseAtlasPrimaryPageInfo(data, &pageInfo) &&
                    !pageInfo.pageName.empty()) {
                    atlasPageNameByDir[GetDirectoryName(files[i].relPath)] = pageInfo;
                }
            }
        }

        struct ImageDimensionInfo {
            bool attempted;
            bool valid;
            uint32_t width;
            uint32_t height;

            ImageDimensionInfo()
                : attempted(false)
                , valid(false)
                , width(0)
                , height(0) {}
        };
        std::map<std::string, ImageDimensionInfo> rootImageDimensionCache;

        for (std::map<std::string, AtlasPrimaryPageInfo>::const_iterator pageIt = atlasPageNameByDir.begin();
             pageIt != atlasPageNameByDir.end(); ++pageIt) {
            const AtlasPrimaryPageInfo& pageInfo = pageIt->second;
            const std::string& pageName = pageInfo.pageName;
            const std::string pageExt = GetExtensionLower(pageName);
            const std::string aliasRel = JoinPath(pageIt->first, pageName);
            const std::string safeAliasRel = NormalizeOutputRelativePath(aliasRel);
            if (safeAliasRel.empty()) {
                continue;
            }
            const std::string aliasAbs = JoinPath(m_outputDir, safeAliasRel);
            if (FileExistsPath(aliasAbs)) {
                continue;
            }

            std::vector<OutputFile> matchingRoots;
            for (size_t i = 0; i < rootImageFiles.size(); ++i) {
                if (rootImageFiles[i].ext != pageExt) {
                    continue;
                }

                if (pageInfo.hasSize) {
                    ImageDimensionInfo& dimensionInfo =
                        rootImageDimensionCache[rootImageFiles[i].absPath];
                    if (!dimensionInfo.attempted) {
                        dimensionInfo.attempted = true;
                        std::vector<unsigned char> rootData;
                        if (ReadFileBytes(rootImageFiles[i].absPath, rootData) &&
                            TryReadImageDimensions(rootData,
                                                   rootImageFiles[i].ext,
                                                   &dimensionInfo.width,
                                                   &dimensionInfo.height)) {
                            dimensionInfo.valid = true;
                        }
                    }

                    if (!dimensionInfo.valid ||
                        dimensionInfo.width != pageInfo.width ||
                        dimensionInfo.height != pageInfo.height) {
                        continue;
                    }
                }

                matchingRoots.push_back(rootImageFiles[i]);
            }

            if (matchingRoots.size() == 1) {
                if (copyIfMissing(matchingRoots[0].absPath, aliasRel)) {
                    changed = true;
                }
                pageReportLines.push_back(
                    "unique|" + matchingRoots[0].relPath + "|" + aliasRel);
            } else if (!matchingRoots.empty()) {
                const std::string pageStem = RemoveExtension(pageName);
                for (size_t i = 0; i < matchingRoots.size(); ++i) {
                    const std::string reviewRel =
                        JoinPath(pageIt->first,
                                 "_review/" + pageStem + ".candidate." +
                                 std::to_string(matchingRoots[i].rootCRC) +
                                 matchingRoots[i].ext);
                    if (copyIfMissing(matchingRoots[i].absPath, reviewRel)) {
                        changed = true;
                    }
                    pageReportLines.push_back(
                        "ambiguous|" + matchingRoots[i].relPath + "|" + reviewRel);
                }
            }
        }

        writeReport("review_alias_model_ani.txt",
                    "# review alias model ani",
                    aniReportLines);
        writeReport("review_alias_model_pages.txt",
                    "# review alias model pages",
                    pageReportLines);
    }

    std::vector<OutputFile> files;
    std::map<uint32_t, OutputFile> unresolved;
    scanOutputs(files, unresolved);
    std::map<std::string, std::vector<std::string> > namedBySignature;
    std::vector<OutputFile> rootFiles;
    auto makeSignature = [&](const std::string& ext, size_t size, uint32_t contentCRC) {
        std::ostringstream sig;
        sig << ToLowerCopy(ext) << "#" << size << "#" << contentCRC;
        return sig.str();
    };
    for (size_t i = 0; i < files.size(); ++i) {
        std::vector<unsigned char> data;
        if (!ReadFileBytes(files[i].absPath, data)) {
            continue;
        }
        const uint32_t contentCRC = m_crc32Func(0,
            data.empty() ? reinterpret_cast<const unsigned char*>("") : &data[0],
            static_cast<unsigned int>(data.size()));
        if (files[i].isRootNumeric) {
            rootFiles.push_back(files[i]);
        } else {
            namedBySignature[makeSignature(files[i].ext, data.size(), contentCRC)]
                .push_back(files[i].absPath);
            if (files[i].ext == ".lmx" || files[i].ext == ".eff.inf") {
                namedBySignature[makeSignature(".xml", data.size(), contentCRC)]
                    .push_back(files[i].absPath);
            }
        }
    }
    for (size_t i = 0; i < rootFiles.size(); ++i) {
        bool keepReviewImageRoot = false;
        if (m_options.writeReviewAliases) {
            for (size_t e = 0; e < sizeof(kImageExts) / sizeof(kImageExts[0]); ++e) {
                if (rootFiles[i].ext == kImageExts[e]) {
                    keepReviewImageRoot = true;
                    break;
                }
            }
        }
        if (keepReviewImageRoot) {
            continue;
        }

        std::vector<unsigned char> data;
        if (!ReadFileBytes(rootFiles[i].absPath, data)) {
            continue;
        }
        const uint32_t contentCRC = m_crc32Func(0,
            data.empty() ? reinterpret_cast<const unsigned char*>("") : &data[0],
            static_cast<unsigned int>(data.size()));
        const std::string sig = makeSignature(rootFiles[i].ext, data.size(), contentCRC);
        std::map<std::string, std::vector<std::string> >::const_iterator aliasIt =
            namedBySignature.find(sig);
        if (aliasIt != namedBySignature.end()) {
            std::vector<std::string> aliases = aliasIt->second;
            std::sort(aliases.begin(), aliases.end());
            std::string aliasRelPath;
            if (!aliases.empty()) {
                aliasRelPath = NormalizeOutputRelativePath(MakeRelativeToRoot(m_outputDir, aliases[0]));
            }
            DeleteFilePath(rootFiles[i].absPath);
            if (!aliasRelPath.empty()) {
                updateOutputAuditForContentAlias(rootFiles[i].rootCRC,
                                                 aliasRelPath,
                                                 aliases.size() > 1);
            }
            changed = true;
        }
    }

    if (m_options.relocateRootNumericResiduals) {
        scanOutputs(files, unresolved);
        size_t relocatedResidualCount = 0;
        std::map<std::string, size_t> relocatedBucketCounts;
        for (std::map<uint32_t, OutputFile>::const_iterator it = unresolved.begin();
             it != unresolved.end(); ++it) {
            const OutputFile& file = it->second;
            std::string bucket = file.ext.empty() ? "noext" : ToLowerCopy(file.ext);
            if (!bucket.empty() && bucket[0] == '.') {
                bucket = bucket.substr(1);
            }
            if (bucket.empty()) {
                bucket = "noext";
            }

            bool bucketChanged = false;
            bucket = SanitizeWindowsPathSegment(bucket, bucketChanged);
            (void)bucketChanged;
            const std::string targetRel =
                JoinPath("review/unresolved", JoinPath(bucket, GetFileName(file.relPath)));
            const std::string safeTargetRel = NormalizeOutputRelativePath(targetRel);
            if (safeTargetRel.empty()) {
                continue;
            }

            const std::string targetAbs = JoinPath(m_outputDir, safeTargetRel);
            CreateDirectoryRecursive(GetDirectoryName(targetAbs));

            bool moved = false;
            if (FileExistsPath(targetAbs)) {
                std::vector<unsigned char> srcData;
                std::vector<unsigned char> dstData;
                if (ReadFileBytes(file.absPath, srcData) &&
                    ReadFileBytes(targetAbs, dstData) &&
                    srcData == dstData) {
                    DeleteFilePath(file.absPath);
                    moved = true;
                }
            } else if (MoveFileReplacePath(file.absPath, targetAbs)) {
                moved = true;
            }

            if (moved) {
                changed = true;
                relocatedResidualCount++;
                relocatedBucketCounts[bucket]++;
            }
        }

        if (relocatedResidualCount > 0) {
            std::wostringstream oss;
            oss << L"Relocated unresolved root residual files to review bucket: "
                << relocatedResidualCount;
            LJFP_LOG_INFO(oss.str());
            for (std::map<std::string, size_t>::const_iterator bucketIt = relocatedBucketCounts.begin();
                 bucketIt != relocatedBucketCounts.end(); ++bucketIt) {
                std::wostringstream bucketOss;
                bucketOss << L"  bucket[" << MultiByteToWideBestEffort(bucketIt->first)
                          << L"] = " << bucketIt->second;
                LJFP_LOG_INFO(bucketOss.str());
            }
        }
    }

    LJFP_LOG_INFO(L"Post-process restore stage finished");
    return LJFP_SUCCESS;
}

int Unpacker::ValidateRestoreOutcome() {
    if (!m_options.strictRestoreValidation) {
        return LJFP_SUCCESS;
    }

    if (!m_options.restorePathStructureAfterUnpack) {
        LJFP_LOG_ERROR(L"Strict restore validation enabled, but restorePathStructureAfterUnpack=false");
        return LJFP_ERROR_PARTIAL_FAILURE;
    }

    if (m_pathMapping.empty()) {
        LJFP_LOG_ERROR(L"Strict restore validation failed: no path mapping loaded");
        return LJFP_ERROR_PARTIAL_FAILURE;
    }

    uint32_t missingMappingCount = 0;
    std::vector<uint32_t> missingMappingSamples;
    missingMappingSamples.reserve(8);
    for (size_t i = 0; i < m_fileList.size(); ++i) {
        const uint32_t pathCrc = m_fileList[i].m_PathFileNameCRC32;
        if (m_pathMapping.find(pathCrc) == m_pathMapping.end()) {
            ++missingMappingCount;
            if (missingMappingSamples.size() < 8) {
                missingMappingSamples.push_back(pathCrc);
            }
        }
    }

    uint32_t rootNumericResidualCount = 0;
    std::vector<std::string> rootNumericSamples;
    rootNumericSamples.reserve(8);
    std::vector<std::string> relPaths;
    CollectFilesRecursive(m_outputDir, relPaths);
    auto isMappedRootNumericPath = [&](const std::string& normalizedPath) -> bool {
        uint32_t parsedCrc = 0;
        std::string parsedExt;
        if (!ParseNumericBaseName(normalizedPath, parsedCrc, parsedExt)) {
            return false;
        }
        for (std::map<uint32_t, std::string>::const_iterator it = m_pathMapping.begin();
             it != m_pathMapping.end(); ++it) {
            const std::string mappedPath = NormalizeSlashesCopy(it->second);
            if (mappedPath == normalizedPath && mappedPath.find('/') == std::string::npos) {
                return true;
            }
        }
        return false;
    };
    for (size_t i = 0; i < relPaths.size(); ++i) {
        const std::string normalizedPath = NormalizeSlashesCopy(relPaths[i]);
        if (normalizedPath.find('/') != std::string::npos) {
            continue;
        }
        if (isMappedRootNumericPath(normalizedPath)) {
            continue;
        }
        uint32_t pathCrc = 0;
        std::string ext;
        if (ParseNumericBaseName(normalizedPath, pathCrc, ext)) {
            ++rootNumericResidualCount;
            if (rootNumericSamples.size() < 8) {
                rootNumericSamples.push_back(normalizedPath);
            }
        }
    }

    bool failed = false;
    if (missingMappingCount > 0) {
        failed = true;
        std::wostringstream oss;
        oss << L"Strict restore validation failed: mapping missing for "
            << missingMappingCount << L"/" << m_fileList.size() << L" files";
        LJFP_LOG_ERROR(oss.str());

        if (!missingMappingSamples.empty()) {
            std::wostringstream sample;
            sample << L"Missing mapping CRC32 samples: ";
            for (size_t i = 0; i < missingMappingSamples.size(); ++i) {
                if (i > 0) {
                    sample << L", ";
                }
                sample << L"0x" << std::uppercase << std::hex
                       << std::setw(8) << std::setfill(L'0') << missingMappingSamples[i]
                       << std::nouppercase << std::dec;
            }
            LJFP_LOG_ERROR(sample.str());
        }
    }

    if (rootNumericResidualCount > 0) {
        failed = true;
        std::wostringstream oss;
        oss << L"Strict restore validation failed: root numeric residual files="
            << rootNumericResidualCount;
        LJFP_LOG_ERROR(oss.str());

        if (!rootNumericSamples.empty()) {
            std::wostringstream sample;
            sample << L"Root numeric residual samples: ";
            for (size_t i = 0; i < rootNumericSamples.size(); ++i) {
                if (i > 0) {
                    sample << L", ";
                }
                sample << MultiByteToWideBestEffort(rootNumericSamples[i]);
            }
            LJFP_LOG_ERROR(sample.str());
        }
    }

    if (failed) {
        return LJFP_ERROR_PARTIAL_FAILURE;
    }

    LJFP_LOG_INFO(L"Strict restore validation passed");
    return LJFP_SUCCESS;
}

void Unpacker::ReportPathMappingHitRate(const std::wstring& context) {
    if (!m_pathMappingStatsValid) {
        UpdatePathMappingStats();
    }
    if (m_fileList.empty()) {
        LJFP_LOG_INFO(L"Path mapping hit rate (" + context + L"): no files loaded");
        return;
    }
    if (m_pathMapping.empty()) {
        LJFP_LOG_INFO(L"Path mapping hit rate (" + context + L"): mapping not loaded");
        return;
    }
    if (!m_pathMappingStatsValid) {
        LJFP_LOG_INFO(L"Path mapping hit rate (" + context + L"): stats unavailable");
        return;
    }

    uint32_t total = static_cast<uint32_t>(m_fileList.size());
    uint32_t hit = m_pathMappingHitCount;
    uint32_t miss = m_pathMappingMissCount;
    uint32_t rateBasis = m_pathMappingRateBasis; // 2 decimals
    uint32_t rateInt = rateBasis / 100;
    uint32_t rateFrac = rateBasis % 100;

    std::wostringstream oss;
    oss << L"Path mapping hit rate (" << context << L"): "
        << hit << L"/" << total << L", miss=" << miss << L" ("
        << rateInt << L"." << std::setw(2) << std::setfill(L'0') << rateFrac << L"%)";
    LJFP_LOG_INFO(oss.str());

    if (!m_pathMappingMissingSamples.empty()) {
        std::wostringstream miss;
        miss << L"Missing CRC32 samples: ";
        for (size_t i = 0; i < m_pathMappingMissingSamples.size(); i++) {
            if (i > 0) miss << L", ";
            miss << L"0x" << std::hex << std::setw(8) << std::setfill(L'0')
                 << m_pathMappingMissingSamples[i] << std::dec;
        }
        LJFP_LOG_INFO(miss.str());
    }
}

// ============================================================================
// 性能优化: 目录预创建
// ============================================================================
void Unpacker::PreCreateDirectories(const std::vector<size_t>* sortedIndices) {
    LJFP_LOG_INFO(L"Pre-creating output directories...");
    auto startTime = std::chrono::steady_clock::now();

    const bool forceCrcOutputFirst = m_options.forceCrcOutputFirst;
    const bool allowPathMapping = m_options.preferPathMapping && !forceCrcOutputFirst;

    std::set<std::string> dirsToCreate;

    // 收集所有需要创建的目录
    size_t fileCount = sortedIndices ? sortedIndices->size() : m_fileList.size();
    for (size_t i = 0; i < fileCount; i++) {
        size_t idx = sortedIndices ? (*sortedIndices)[i] : i;
        if (idx >= m_fileList.size()) continue;

        const FileInfo& fileInfo = m_fileList[idx];

        // 尝试获取输出路径（不需要实际文件数据，只需路径）
        std::string outputPath;

        // 如果有路径映射，使用映射路径
        if (allowPathMapping) {
            auto it = m_pathMapping.find(fileInfo.m_PathFileNameCRC32);
            if (it != m_pathMapping.end()) {
                std::string originalPath = it->second;
                for (char& c : originalPath) {
                    if (c == '\\') c = '/';
                }
                outputPath = m_outputDir + "/" + originalPath;
            }
        }

        // 没有映射，使用类型分类目录
        if (outputPath.empty() && m_options.organizeByType && !forceCrcOutputFirst) {
            // 简单估计目录（实际扩展名检测需要文件内容，这里只创建基础目录）
            outputPath = m_outputDir + "/unknown/" + std::to_string(fileInfo.m_PathFileNameCRC32);
        } else if (outputPath.empty()) {
            outputPath = m_outputDir + "/" + std::to_string(fileInfo.m_PathFileNameCRC32);
        }

        std::string dirPath = GetDirectoryPath(outputPath);
        if (!dirPath.empty()) {
            dirsToCreate.insert(dirPath);
        }
    }

    // 批量创建所有目录
    for (const auto& dir : dirsToCreate) {
        CreateDirectoryRecursive(dir);
    }

    auto endTime = std::chrono::steady_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(endTime - startTime);

    LJFP_LOG_INFO(L"Pre-created " + std::to_wstring(dirsToCreate.size()) +
                  L" directories in " + std::to_wstring(duration.count()) + L" ms");
}

// ============================================================================
// 性能优化: 并行解包优化版 (任务预排序 + 任务分片 + 目录预创建)
// ============================================================================
int Unpacker::UnpackAllParallelOptimized(int threadCount) {
    LJFP_LOG_INFO(L"Starting optimized parallel unpacking...");
    auto totalStartTime = std::chrono::steady_clock::now();

    // ========== 步骤1: 任务预排序 (按 PackIndex 和 Pos 排序，减少磁盘随机寻道) ==========
    LJFP_LOG_INFO(L"Sorting tasks by PackIndex and Pos...");
    auto sortStartTime = std::chrono::steady_clock::now();

    std::vector<size_t> sortedIndices(m_fileList.size());
    std::iota(sortedIndices.begin(), sortedIndices.end(), 0);

    std::sort(sortedIndices.begin(), sortedIndices.end(),
        [this](size_t a, size_t b) {
            // 首先按 PackIndex 排序 (同一个 .ljfp 文件的数据放在一起)
            if (m_fileList[a].m_PackIndex != m_fileList[b].m_PackIndex) {
                return m_fileList[a].m_PackIndex < m_fileList[b].m_PackIndex;
            }
            // 然后按 Pos 排序 (同一文件内按偏移量顺序读取)
            return m_fileList[a].m_Pos < m_fileList[b].m_Pos;
        });

    auto sortEndTime = std::chrono::steady_clock::now();
    auto sortDuration = std::chrono::duration_cast<std::chrono::milliseconds>(sortEndTime - sortStartTime);
    LJFP_LOG_INFO(L"Task sorting completed in " + std::to_wstring(sortDuration.count()) + L" ms");

    // ========== 步骤2: 目录预创建 ==========
    PreCreateDirectories(&sortedIndices);

    // ========== 步骤3: 任务分片 (每个线程分配固定范围，减少锁竞争) ==========
    std::mutex statsMutex;
    std::atomic<uint32_t> completedCount(0);
    std::atomic<bool> stopFlag(false);

    // 计算每个线程的任务范围
    size_t totalTasks = sortedIndices.size();
    size_t baseChunkSize = totalTasks / threadCount;
    size_t remainder = totalTasks % threadCount;

    // Worker 线程函数 (处理分配的任务范围)
    auto workerThread = [&](int threadId, size_t startIdx, size_t endIdx) {
        LJFP_LOG_INFO(L"Worker thread " + std::to_wstring(threadId) +
                      L" started, processing files " + std::to_wstring(startIdx) +
                      L" to " + std::to_wstring(endIdx - 1));

        for (size_t i = startIdx; i < endIdx; i++) {
            if (!WaitIfPaused()) {
                stopFlag.store(true);
                LJFP_LOG_WARNING(L"Worker thread " + std::to_wstring(threadId) + L" stopped while paused");
                break;
            }
            if (stopFlag.load() || m_shouldStop.load()) {
                LJFP_LOG_WARNING(L"Worker thread " + std::to_wstring(threadId) + L" stopped by user");
                break;
            }

            size_t fileIndex = sortedIndices[i];
            if (fileIndex >= m_fileList.size()) continue;

            FileInfo& fileInfo = m_fileList[fileIndex];
            int result = UnpackSingleFile(fileInfo, fileIndex);

            // 更新统计信息（线程安全）
            {
                std::lock_guard<std::mutex> lock(statsMutex);
                if (result == LJFP_SUCCESS) {
                    m_processedFiles++;
                    m_processedBytes += fileInfo.m_SizeOriginal;
                } else if (result == LJFP_ERROR_USER_CANCELLED && m_shouldStop.load()) {
                    stopFlag.store(true);
                } else {
                    m_failedFiles++;
                    m_lastErrorCodeCounts[result]++;
                    if (m_firstErrorCode == 0) {
                        m_firstErrorCode = result;
                        m_firstErrorFileIndex = static_cast<uint32_t>(fileIndex);
                    }
                    RecordFailedFile(fileIndex, fileInfo, result);
                    LJFP_LOG_ERROR(L"Failed to unpack file #" + std::to_wstring(fileIndex) +
                                   L", CRC32=" + std::to_wstring(fileInfo.m_PathFileNameCRC32) +
                                   L", error=" + std::to_wstring(result));
                }
            }

            ++completedCount;
        }

        LJFP_LOG_INFO(L"Worker thread " + std::to_wstring(threadId) + L" finished");
    };

    // 报告初始进度 (0%)
    if (m_progressCallback) {
        m_progressCallback(0.0f, 0, m_totalFiles);
    }

    // 创建线程池并分配任务范围
    std::vector<std::thread> workers;
    size_t currentIdx = 0;

    for (int i = 0; i < threadCount; i++) {
        size_t chunkSize = baseChunkSize + (i < (int)remainder ? 1 : 0);
        size_t startIdx = currentIdx;
        size_t endIdx = currentIdx + chunkSize;
        currentIdx = endIdx;

        workers.emplace_back(workerThread, i, startIdx, endIdx);
    }

    // 进度报告节流变量
    uint32_t lastReportedCount = 0;
    const uint32_t minReportDelta = std::max(1u, std::min(10u, m_totalFiles / 200));
    auto lastReportTime = std::chrono::steady_clock::now();
    const auto minReportInterval = std::chrono::milliseconds(200);

    // 监控进度直到完成
    for (;;) {
        if (m_shouldStop.load()) {
            stopFlag.store(true);
            break;
        }

        uint32_t currentCount = completedCount.load();
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - lastReportTime);

        bool shouldReport = (currentCount - lastReportedCount >= minReportDelta) ||
                           (elapsed >= minReportInterval && currentCount > lastReportedCount) ||
                           (currentCount == m_totalFiles && lastReportedCount < m_totalFiles);

        if (m_progressCallback && shouldReport) {
            float progress = (float)currentCount / m_totalFiles;
            m_progressCallback(progress, currentCount, m_totalFiles);
            lastReportedCount = currentCount;
            lastReportTime = now;
        }

        if (completedCount.load() >= m_totalFiles) {
            break;
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(50));  // 更频繁检查
    }

    // 等待所有线程结束
    for (auto& worker : workers) {
        if (worker.joinable()) {
            worker.join();
        }
    }

    // 报告最终进度 (100%)
    if (m_progressCallback) {
        m_progressCallback(1.0f, m_totalFiles, m_totalFiles);
    }

    m_isRunning.store(false);

    auto totalEndTime = std::chrono::steady_clock::now();
    auto totalDuration = std::chrono::duration_cast<std::chrono::milliseconds>(totalEndTime - totalStartTime);

    // 输出统计信息
    LJFP_LOG_INFO(L"======================================");
    LJFP_LOG_INFO(L"Optimized parallel unpacking completed!");
    LJFP_LOG_INFO(L"Thread count: " + std::to_wstring(threadCount));
    LJFP_LOG_INFO(L"Total files: " + std::to_wstring(m_totalFiles));
    LJFP_LOG_INFO(L"Processed: " + std::to_wstring(m_processedFiles));
    LJFP_LOG_INFO(L"Failed: " + std::to_wstring(m_failedFiles));
    LJFP_LOG_INFO(L"Total bytes: " + std::to_wstring(m_processedBytes / 1024 / 1024) + L" MB");
    LJFP_LOG_INFO(L"Total time: " + std::to_wstring(totalDuration.count()) + L" ms");
    LJFP_LOG_INFO(L"Speed: " + std::to_wstring(m_totalFiles * 1000 / (totalDuration.count() + 1)) + L" files/sec");
    LJFP_LOG_INFO(L"======================================");

    return (m_failedFiles == 0) ? LJFP_SUCCESS : LJFP_ERROR_PARTIAL_FAILURE;
}

int Unpacker::UnpackSelectedParallelOptimized(const std::vector<size_t>& fileIndices, int threadCount) {
    LJFP_LOG_INFO(L"Starting optimized selected-file unpacking...");
    auto totalStartTime = std::chrono::steady_clock::now();

    std::vector<size_t> sortedIndices = fileIndices;
    std::sort(sortedIndices.begin(), sortedIndices.end(),
        [this](size_t a, size_t b) {
            if (m_fileList[a].m_PackIndex != m_fileList[b].m_PackIndex) {
                return m_fileList[a].m_PackIndex < m_fileList[b].m_PackIndex;
            }
            return m_fileList[a].m_Pos < m_fileList[b].m_Pos;
        });

    PreCreateDirectories(&sortedIndices);

    std::mutex statsMutex;
    std::atomic<uint32_t> completedCount(0);
    std::atomic<bool> stopFlag(false);

    const uint32_t selectedTotal = static_cast<uint32_t>(sortedIndices.size());
    const size_t totalTasks = sortedIndices.size();
    const size_t baseChunkSize = totalTasks / threadCount;
    const size_t remainder = totalTasks % threadCount;

    auto workerThread = [&](int threadId, size_t startIdx, size_t endIdx) {
        LJFP_LOG_INFO(L"Selected worker thread " + std::to_wstring(threadId) +
                      L" started, processing files " + std::to_wstring(startIdx) +
                      L" to " + std::to_wstring(endIdx == 0 ? 0 : endIdx - 1));

        for (size_t i = startIdx; i < endIdx; ++i) {
            if (!WaitIfPaused()) {
                stopFlag.store(true);
                break;
            }
            if (stopFlag.load() || m_shouldStop.load()) {
                break;
            }

            const size_t fileIndex = sortedIndices[i];
            if (fileIndex >= m_fileList.size()) {
                ++completedCount;
                continue;
            }

            FileInfo& fileInfo = m_fileList[fileIndex];
            const int result = UnpackSingleFile(fileInfo, fileIndex);

            {
                std::lock_guard<std::mutex> lock(statsMutex);
                if (result == LJFP_SUCCESS) {
                    m_processedFiles++;
                    m_processedBytes += fileInfo.m_SizeOriginal;
                } else if (result == LJFP_ERROR_USER_CANCELLED && m_shouldStop.load()) {
                    stopFlag.store(true);
                } else {
                    m_failedFiles++;
                    m_lastErrorCodeCounts[result]++;
                    if (m_firstErrorCode == 0) {
                        m_firstErrorCode = result;
                        m_firstErrorFileIndex = static_cast<uint32_t>(fileIndex);
                    }
                    RecordFailedFile(fileIndex, fileInfo, result);
                    LJFP_LOG_ERROR(L"Failed to unpack selected file #" + std::to_wstring(fileIndex) +
                                   L", CRC32=" + std::to_wstring(fileInfo.m_PathFileNameCRC32) +
                                   L", error=" + std::to_wstring(result));
                }
            }

            ++completedCount;
        }

        LJFP_LOG_INFO(L"Selected worker thread " + std::to_wstring(threadId) + L" finished");
    };

    if (m_progressCallback) {
        m_progressCallback(0.0f, 0, selectedTotal);
    }

    std::vector<std::thread> workers;
    size_t currentIdx = 0;
    for (int i = 0; i < threadCount; ++i) {
        const size_t chunkSize = baseChunkSize + (i < static_cast<int>(remainder) ? 1 : 0);
        const size_t startIdx = currentIdx;
        const size_t endIdx = currentIdx + chunkSize;
        currentIdx = endIdx;
        workers.emplace_back(workerThread, i, startIdx, endIdx);
    }

    uint32_t lastReportedCount = 0;
    const uint32_t minReportDelta = std::max(1u, std::min(10u, selectedTotal / 200));
    auto lastReportTime = std::chrono::steady_clock::now();
    const auto minReportInterval = std::chrono::milliseconds(200);

    for (;;) {
        if (m_shouldStop.load()) {
            stopFlag.store(true);
            break;
        }

        const uint32_t currentCount = completedCount.load();
        const auto now = std::chrono::steady_clock::now();
        const auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - lastReportTime);
        const bool shouldReport = (currentCount - lastReportedCount >= minReportDelta) ||
            (elapsed >= minReportInterval && currentCount > lastReportedCount) ||
            (currentCount == selectedTotal && lastReportedCount < selectedTotal);

        if (m_progressCallback && shouldReport) {
            const float progress = selectedTotal > 0
                ? static_cast<float>(currentCount) / static_cast<float>(selectedTotal)
                : 1.0f;
            m_progressCallback(progress, currentCount, selectedTotal);
            lastReportedCount = currentCount;
            lastReportTime = now;
        }

        if (currentCount >= selectedTotal) {
            break;
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    for (size_t i = 0; i < workers.size(); ++i) {
        if (workers[i].joinable()) {
            workers[i].join();
        }
    }

    if (m_progressCallback) {
        m_progressCallback(1.0f, selectedTotal, selectedTotal);
    }

    m_isRunning.store(false);

    auto totalEndTime = std::chrono::steady_clock::now();
    auto totalDuration = std::chrono::duration_cast<std::chrono::milliseconds>(totalEndTime - totalStartTime);
    LJFP_LOG_INFO(L"Selected optimized parallel unpacking completed in " +
                  std::to_wstring(totalDuration.count()) + L" ms");
    ReportStreamStats(L"selected-parallel");

    return (m_failedFiles == 0) ? LJFP_SUCCESS : LJFP_ERROR_PARTIAL_FAILURE;
}

} // namespace SLJFP

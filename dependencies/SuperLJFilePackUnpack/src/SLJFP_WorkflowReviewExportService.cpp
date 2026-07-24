#include "../include/SLJFP_WorkflowReviewExportService.h"
#include "../include/SLJFP_ErrorCodes.h"

#include <algorithm>
#include <cerrno>
#include <fstream>
#include <iomanip>
#include <map>
#include <set>
#include <sstream>

#ifdef _WIN32
#define NOMINMAX
#include <direct.h>
#include <windows.h>
#else
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#endif

namespace SLJFP {

namespace {

std::wstring MultiByteToWideBestEffort(const std::string& value) {
#ifdef _WIN32
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
#else
    return std::wstring(value.begin(), value.end());
#endif
}

std::string WideToMultiByteBestEffort(const std::wstring& value) {
#ifdef _WIN32
    if (value.empty()) {
        return std::string();
    }

    UINT codePage = CP_ACP;
    int required = WideCharToMultiByte(codePage, 0, value.c_str(), -1, NULL, 0, NULL, NULL);
    if (required <= 0) {
        codePage = CP_UTF8;
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
#else
    return std::string(value.begin(), value.end());
#endif
}

std::string JoinPath(const std::string& base, const std::string& leaf) {
    if (base.empty()) {
        return leaf;
    }
    if (leaf.empty()) {
        return base;
    }

    const char last = base[base.size() - 1];
    if (last == '/' || last == '\\') {
        return base + leaf;
    }
    return base + "/" + leaf;
}

bool DirectoryExists(const std::string& path) {
    if (path.empty()) {
        return false;
    }

#ifdef _WIN32
    std::wstring widePath = MultiByteToWideBestEffort(path);
    if (widePath.empty()) {
        return false;
    }
    DWORD attrs = GetFileAttributesW(widePath.c_str());
    return attrs != INVALID_FILE_ATTRIBUTES &&
           (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0;
#else
    struct stat info;
    return stat(path.c_str(), &info) == 0 && S_ISDIR(info.st_mode);
#endif
}

bool CreateDirectorySingle(const std::string& path) {
    if (path.empty() || DirectoryExists(path)) {
        return true;
    }

#ifdef _WIN32
    std::wstring widePath = MultiByteToWideBestEffort(path);
    if (widePath.empty()) {
        return false;
    }
    if (CreateDirectoryW(widePath.c_str(), NULL) != 0) {
        return true;
    }
    return GetLastError() == ERROR_ALREADY_EXISTS && DirectoryExists(path);
#else
    return mkdir(path.c_str(), 0755) == 0 || errno == EEXIST;
#endif
}

bool EnsureDirectoryRecursive(const std::string& dirPath) {
    if (dirPath.empty()) {
        return false;
    }

    if (DirectoryExists(dirPath)) {
        return true;
    }

    std::string normalized = dirPath;
#ifdef _WIN32
    std::replace(normalized.begin(), normalized.end(), '/', '\\');
    while (normalized.size() > 3 &&
           !normalized.empty() &&
           (normalized[normalized.size() - 1] == '\\')) {
        normalized.erase(normalized.size() - 1);
    }

    size_t pos = 0;
    if (normalized.size() >= 2 && normalized[0] == '\\' && normalized[1] == '\\') {
        const size_t serverPos = normalized.find('\\', 2);
        if (serverPos == std::string::npos) {
            return false;
        }
        pos = normalized.find('\\', serverPos + 1);
        if (pos == std::string::npos) {
            return false;
        }
    } else if (normalized.size() >= 2 && normalized[1] == ':') {
        pos = 2;
    }

    while ((pos = normalized.find('\\', pos + 1)) != std::string::npos) {
        const std::string segment = normalized.substr(0, pos);
        if (!segment.empty() && segment[segment.size() - 1] != ':') {
            if (!CreateDirectorySingle(segment)) {
                return false;
            }
        }
    }
    return CreateDirectorySingle(normalized);
#else
    std::replace(normalized.begin(), normalized.end(), '\\', '/');
    while (normalized.size() > 1 &&
           !normalized.empty() &&
           normalized[normalized.size() - 1] == '/') {
        normalized.erase(normalized.size() - 1);
    }

    size_t pos = 0;
    if (!normalized.empty() && normalized[0] == '/') {
        pos = 0;
    }

    while ((pos = normalized.find('/', pos + 1)) != std::string::npos) {
        const std::string segment = normalized.substr(0, pos);
        if (!segment.empty() && !CreateDirectorySingle(segment)) {
            return false;
        }
    }
    return CreateDirectorySingle(normalized);
#endif
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

std::string EscapeTsvField(const std::string& value) {
    std::string escaped;
    escaped.reserve(value.size());
    for (size_t i = 0; i < value.size(); ++i) {
        switch (value[i]) {
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
                escaped.push_back(value[i]);
                break;
        }
    }
    return escaped;
}

std::wstring SanitizeExportLabel(const std::wstring& label) {
    std::wstring result = label;
    static const wchar_t* kInvalidChars = L"\\/:*?\"<>|";
    for (size_t i = 0; i < result.size(); ++i) {
        const wchar_t c = result[i];
        if (c < 32 || std::wcschr(kInvalidChars, c) != NULL) {
            result[i] = L'_';
        }
    }

    for (size_t i = 0; i < result.size(); ++i) {
        if (result[i] == L' ' || result[i] == L'\t') {
            result[i] = L'_';
        }
    }

    std::wstring compacted;
    compacted.reserve(result.size());
    bool lastUnderscore = false;
    for (size_t i = 0; i < result.size(); ++i) {
        const wchar_t c = result[i];
        if (c == L'_') {
            if (lastUnderscore) {
                continue;
            }
            lastUnderscore = true;
        } else {
            lastUnderscore = false;
        }
        compacted.push_back(c);
    }

    while (!compacted.empty() &&
           (compacted[0] == L'_' || compacted[0] == L' ')) {
        compacted.erase(compacted.begin());
    }
    while (!compacted.empty() &&
           (compacted[compacted.size() - 1] == L'_' || compacted[compacted.size() - 1] == L' ')) {
        compacted.erase(compacted.size() - 1);
    }

    return compacted.empty() ? std::wstring(L"all_failed") : compacted;
}

std::string FormatCRC32(uint32_t value) {
    std::ostringstream oss;
    oss << "0x" << std::uppercase << std::hex << std::setw(8) << std::setfill('0') << value;
    return oss.str();
}

std::string FormatErrorCode(int code) {
    if (code == 0) {
        return "0 (Operation successful)";
    }

    std::ostringstream oss;
    oss << code << " (" << WideToMultiByteBestEffort(GetErrorMessage(static_cast<ErrorCode>(code))) << ")";
    return oss.str();
}

std::vector<std::string> BuildManifestFlags(const OutputPathManifestRecord& record) {
    std::vector<std::string> flags;
    if (record.mappingSanitized) flags.push_back("mapping_sanitized");
    if (record.conflictResolved) flags.push_back("conflict_suffix");
    if (record.existingTargetPreserved) flags.push_back("existing_target_preserved");
    if (record.postProcessMoved) flags.push_back("postprocess_relocated");
    if (record.physicalPathStatus == "content_deduped_alias") flags.push_back("content_deduped_alias");
    if (record.reviewBucketed) flags.push_back("review_bucketed");
    if (!record.physicalExists) flags.push_back("physical_missing");
    if (record.physicalExists && !record.extensionConsistent) flags.push_back("extension_mismatch");
    return flags;
}

std::string JoinCsv(const std::vector<std::string>& values) {
    std::ostringstream oss;
    for (size_t i = 0; i < values.size(); ++i) {
        if (i > 0) {
            oss << ",";
        }
        oss << values[i];
    }
    return oss.str();
}

} // namespace

WorkflowReviewExportService::Scope::Scope() {
}

WorkflowReviewExportService::Result::Result()
    : error(Error::None)
    , exportedCount(0) {
}

WorkflowReviewExportService::Result WorkflowReviewExportService::ExportFailedItems(
    const Unpacker* unpacker,
    const std::string& outputDir,
    const Scope* scope) {
    Result result;

    if (unpacker == NULL) {
        result.error = Error::MissingUnpacker;
        return result;
    }
    if (outputDir.empty()) {
        result.error = Error::MissingOutputDir;
        return result;
    }
    if (!EnsureDirectoryRecursive(outputDir)) {
        result.error = Error::OutputDirCreateFailed;
        return result;
    }

    const std::vector<FailedFileRecord> failedFiles = unpacker->GetLastFailedFiles();
    if (failedFiles.empty()) {
        result.error = Error::NoFailedFiles;
        return result;
    }

    std::set<size_t> scopedIndices;
    if (scope != NULL && !scope->fileIndices.empty()) {
        scopedIndices.insert(scope->fileIndices.begin(), scope->fileIndices.end());
    }

    std::vector<FailedFileRecord> exportRecords;
    exportRecords.reserve(failedFiles.size());
    for (size_t i = 0; i < failedFiles.size(); ++i) {
        if (!scopedIndices.empty() &&
            scopedIndices.find(static_cast<size_t>(failedFiles[i].fileIndex)) == scopedIndices.end()) {
            continue;
        }
        exportRecords.push_back(failedFiles[i]);
    }

    if (exportRecords.empty()) {
        result.error = Error::NoMatchingFailedItems;
        return result;
    }

    std::map<size_t, OutputPathManifestRecord> manifestByFileIndex;
    const std::vector<OutputPathManifestRecord> manifestRecords = unpacker->GetLastOutputPathManifestRecords();
    for (size_t i = 0; i < manifestRecords.size(); ++i) {
        const int fileIndex = unpacker->FindFileByCRC32(manifestRecords[i].pathCRC32);
        if (fileIndex >= 0) {
            manifestByFileIndex[static_cast<size_t>(fileIndex)] = manifestRecords[i];
        }
    }

    const std::wstring requestedLabel = (scope != NULL) ? scope->label : std::wstring();
    const std::wstring suffix = SanitizeExportLabel(!requestedLabel.empty() ? requestedLabel : std::wstring(L"all_failed"));
    const std::string suffixText = WideToMultiByteBestEffort(suffix);

    result.basePath = JoinPath(outputDir, "review_failed_items_" + suffixText);
    result.tsvPath = result.basePath + ".tsv";
    result.jsonPath = result.basePath + ".json";

    std::ofstream tsvOut(result.tsvPath.c_str(), std::ios::binary);
    std::ofstream jsonOut(result.jsonPath.c_str(), std::ios::binary);
    if (!tsvOut.is_open() || !jsonOut.is_open()) {
        result.error = Error::OutputFileOpenFailed;
        return result;
    }

    tsvOut << "file_index\tpath_crc32\terror_code\terror_text\tpack_index\tmapping_hit\tdisplay_path\tfinal_relative_path\tflags\n";
    jsonOut << "{\n";
    jsonOut << "  \"version\": 1,\n";
    jsonOut << "  \"group\": \"" << EscapeJsonString(suffixText) << "\",\n";
    jsonOut << "  \"failed_items\": [\n";

    for (size_t i = 0; i < exportRecords.size(); ++i) {
        const FailedFileRecord& record = exportRecords[i];
        const size_t fileIndex = static_cast<size_t>(record.fileIndex);
        const std::string displayPath = unpacker->GetFilePath(fileIndex);
        std::string finalRelativePath;

        std::vector<std::string> flags;
        std::map<size_t, OutputPathManifestRecord>::const_iterator manifestIt = manifestByFileIndex.find(fileIndex);
        if (manifestIt != manifestByFileIndex.end()) {
            finalRelativePath = manifestIt->second.finalRelativePath;
            flags = BuildManifestFlags(manifestIt->second);
        }
        const std::string flagsText = JoinCsv(flags);
        const std::string errorText = FormatErrorCode(record.errorCode);

        tsvOut << record.fileIndex << "\t"
               << EscapeTsvField(FormatCRC32(record.pathCRC32)) << "\t"
               << record.errorCode << "\t"
               << EscapeTsvField(errorText) << "\t"
               << record.packIndex << "\t"
               << (record.mappingHit ? "true" : "false") << "\t"
               << EscapeTsvField(displayPath) << "\t"
               << EscapeTsvField(finalRelativePath) << "\t"
               << EscapeTsvField(flagsText) << "\n";

        if (i > 0) {
            jsonOut << ",\n";
        }
        jsonOut << "    {\n";
        jsonOut << "      \"file_index\": " << record.fileIndex << ",\n";
        jsonOut << "      \"path_crc32\": \"" << EscapeJsonString(FormatCRC32(record.pathCRC32)) << "\",\n";
        jsonOut << "      \"error_code\": " << record.errorCode << ",\n";
        jsonOut << "      \"error_text\": \"" << EscapeJsonString(errorText) << "\",\n";
        jsonOut << "      \"pack_index\": " << record.packIndex << ",\n";
        jsonOut << "      \"mapping_hit\": " << (record.mappingHit ? "true" : "false") << ",\n";
        jsonOut << "      \"display_path\": \"" << EscapeJsonString(displayPath) << "\",\n";
        jsonOut << "      \"final_relative_path\": \"" << EscapeJsonString(finalRelativePath) << "\",\n";
        jsonOut << "      \"flags\": [";
        for (size_t flagIndex = 0; flagIndex < flags.size(); ++flagIndex) {
            if (flagIndex > 0) {
                jsonOut << ", ";
            }
            jsonOut << "\"" << EscapeJsonString(flags[flagIndex]) << "\"";
        }
        jsonOut << "]\n";
        jsonOut << "    }";
    }

    jsonOut << "\n  ]\n";
    jsonOut << "}\n";

    result.exportedCount = exportRecords.size();
    return result;
}

} // namespace SLJFP

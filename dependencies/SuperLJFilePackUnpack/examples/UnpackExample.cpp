/**
 * @file UnpackExample.cpp
 * @brief SuperLJFilePackUnpack 命令行解包工具
 * @version 1.1
 * @date 2026-01-04
 *
 * 使用示例:
 *   ljfp-unpack <输入目录> [输出目录] [选项]
 *
 * 选项:
 *   --no-verify      跳过 CRC32 校验
 *   --overwrite      覆盖已存在文件
 *   --mapping=FILE   加载路径映射文件 (恢复原始文件名)
 *   --scan=DIR       扫描目录生成路径映射文件
 *   --strict-restore 启用严格还原校验（要求映射全覆盖且无数字残留）
 *   --no-detect      禁用文件类型检测
 *   --keep-root-residuals 保留根目录未恢复的数字文件（默认归档到 review/unresolved）
 *   --review-aliases 为高置信 model 数字 atlas/json 额外写出可读别名副本
 *   --help           显示帮助信息
 */

#include "SLJFP_Unpack.h"
#include "SLJFP_AndroidBinaryKey.h"
#include "SLJFP_Logger_Impl.h"
#include "SLJFP_ErrorCodes.h"
#include "SLJFP_LibsWrapper.h"
#include "SLJFP_PathMappingGenerator.h"
#include "SLJFP_FileTypeDetector.h"
#include "SLJFP_WorkflowReviewExportService.h"

#include <iostream>
#include <string>
#include <cstring>
#include <fstream>
#include <algorithm>
#include <cctype>
#include <cstdio>
#include <sstream>
#include <set>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#include <io.h>
#include <fcntl.h>
#else
#include <sys/stat.h>
#include <unistd.h>
#endif

namespace {

std::string BuildHelpTextUtf8();

struct SourceTemplateSeedEnrichmentResult {
    bool attempted;
    bool executed;
    bool promoted;
    bool failed;
    long exitCode;
    uint32_t directHits;
    uint32_t existingHits;
    uint32_t mergedHits;
    uint32_t hitGain;
    uint32_t newHits;
    uint32_t mappingConflicts;
    uint32_t seedConflicts;
    std::vector<std::string> scanRoots;
    std::vector<std::string> mapConfigInputs;
    std::string pythonLauncher;
    std::string scriptPath;
    std::string reportDir;
    std::string promoteDir;
    std::string summaryPath;
    std::string targetCrcFile;
    std::string message;

    SourceTemplateSeedEnrichmentResult()
        : attempted(false)
        , executed(false)
        , promoted(false)
        , failed(false)
        , exitCode(-1)
        , directHits(0)
        , existingHits(0)
        , mergedHits(0)
        , hitGain(0)
        , newHits(0)
        , mappingConflicts(0)
        , seedConflicts(0) {
    }
};

uint32_t PathMappingCRC32Adapter(uint32_t crc, const void* data, size_t len) {
    return SLJFP_crc32(crc,
                       reinterpret_cast<const unsigned char*>(data),
                       static_cast<unsigned int>(len));
}

bool EndsWithNoCase(const std::string& value, const std::string& suffix) {
    if (value.size() < suffix.size()) {
        return false;
    }

    size_t offset = value.size() - suffix.size();
    for (size_t i = 0; i < suffix.size(); ++i) {
        char a = static_cast<char>(std::tolower(static_cast<unsigned char>(value[offset + i])));
        char b = static_cast<char>(std::tolower(static_cast<unsigned char>(suffix[i])));
        if (a != b) {
            return false;
        }
    }
    return true;
}

bool IsIndexFilePath(const std::string& path) {
    return EndsWithNoCase(path, ".ljpi") || EndsWithNoCase(path, ".ljzip");
}

bool FileExists(const std::string& path) {
    std::ifstream fs(path.c_str(), std::ios::binary);
    return fs.good();
}

bool DirectoryExists(const std::string& path) {
    if (path.empty()) {
        return false;
    }
#ifdef _WIN32
    const DWORD attrs = GetFileAttributesA(path.c_str());
    return attrs != INVALID_FILE_ATTRIBUTES &&
           (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0;
#else
    struct stat st;
    return stat(path.c_str(), &st) == 0 && S_ISDIR(st.st_mode);
#endif
}

bool ShouldUseProgressOutput() {
#ifdef _WIN32
    HANDLE stdoutHandle = GetStdHandle(STD_OUTPUT_HANDLE);
    if (stdoutHandle == nullptr || stdoutHandle == INVALID_HANDLE_VALUE) {
        return false;
    }

    if (GetFileType(stdoutHandle) != FILE_TYPE_CHAR) {
        return false;
    }

    return _isatty(_fileno(stdout)) != 0;
#else
    return isatty(fileno(stdout)) != 0;
#endif
}

std::string JoinPath(const std::string& dir, const std::string& fileName) {
    if (dir.empty()) {
        return fileName;
    }
    char last = dir.back();
    if (last == '/' || last == '\\') {
        return dir + fileName;
    }
    return dir + "/" + fileName;
}

std::string GetParentDirectory(const std::string& path) {
    size_t pos = path.find_last_of("/\\");
    if (pos == std::string::npos) {
        return ".";
    }
    if (pos == 0) {
        return path.substr(0, 1);
    }
    return path.substr(0, pos);
}

void PushUniquePath(std::vector<std::string>& outPaths, const std::string& path) {
    if (path.empty()) {
        return;
    }
    if (std::find(outPaths.begin(), outPaths.end(), path) != outPaths.end()) {
        return;
    }
    outPaths.push_back(path);
}

std::string FindSourceTemplateSeedPipelineScript() {
    const std::string cwdCandidate =
        JoinPath(".", "dependencies/SuperLJFilePackUnpack/tools/source_template_seed_pipeline.py");
    if (FileExists(cwdCandidate)) {
        return cwdCandidate;
    }

    char exePathBuffer[MAX_PATH] = {0};
#ifdef _WIN32
    if (GetModuleFileNameA(NULL, exePathBuffer, MAX_PATH) > 0) {
        std::string currentDir = GetParentDirectory(exePathBuffer);
        for (int depth = 0; depth < 8 && !currentDir.empty(); ++depth) {
            const std::string candidate =
                JoinPath(currentDir, "tools/source_template_seed_pipeline.py");
            if (FileExists(candidate)) {
                return candidate;
            }
            const std::string parentDir = GetParentDirectory(currentDir);
            if (parentDir.empty() || parentDir == currentDir) {
                break;
            }
            currentDir = parentDir;
        }
    }
#endif
    return std::string();
}

std::string DetectPythonLauncherForCli() {
#ifdef _WIN32
    if (std::system("python --version >nul 2>&1") == 0) {
        return "python";
    }
    if (std::system("py -3 --version >nul 2>&1") == 0) {
        return "py -3";
    }
#else
    if (std::system("python --version >/dev/null 2>&1") == 0) {
        return "python";
    }
    if (std::system("python3 --version >/dev/null 2>&1") == 0) {
        return "python3";
    }
#endif
    return std::string();
}

void DetectSourceTemplateScanRoots(const std::vector<std::string>& explicitRoots,
                                   const std::string& inputDir,
                                   std::vector<std::string>& outRoots) {
    outRoots.clear();

    std::vector<std::string> seeds = explicitRoots;
    PushUniquePath(seeds, inputDir);
    PushUniquePath(seeds, ".");

    for (size_t i = 0; i < seeds.size(); ++i) {
        std::string current = seeds[i];
        for (int depth = 0; depth < 6 && !current.empty(); ++depth) {
            const std::string clientChild = JoinPath(current, "client");
            if (DirectoryExists(clientChild)) {
                PushUniquePath(outRoots, clientChild);
            }
            const std::string autoChild = JoinPath(current, "auto");
            if (DirectoryExists(autoChild)) {
                PushUniquePath(outRoots, autoChild);
            }
            if (DirectoryExists(current)) {
                const std::string leaf = current.substr(current.find_last_of("/\\") == std::string::npos
                    ? 0
                    : current.find_last_of("/\\") + 1);
                if (leaf == "client" || leaf == "auto") {
                    PushUniquePath(outRoots, current);
                }
            }
            const std::string parent = GetParentDirectory(current);
            if (parent.empty() || parent == current) {
                break;
            }
            current = parent;
        }
    }
}

void DetectSourceTemplateMapConfigInputs(const std::vector<std::string>& explicitBins,
                                         const std::vector<std::string>& scanRoots,
                                         std::vector<std::string>& outBins) {
    outBins.clear();
    for (size_t i = 0; i < explicitBins.size(); ++i) {
        if (FileExists(explicitBins[i])) {
            PushUniquePath(outBins, explicitBins[i]);
        }
    }

    for (size_t i = 0; i < scanRoots.size(); ++i) {
        const std::string& root = scanRoots[i];
        const std::string direct = JoinPath(root, "table/bintable/map.cmapconfig.bin");
        const std::string resDirect = JoinPath(root, "res/table/bintable/map.cmapconfig.bin");
        const std::string assetsDirect = JoinPath(root, "assets/res/table/bintable/map.cmapconfig.bin");
        if (FileExists(direct)) {
            PushUniquePath(outBins, direct);
        }
        if (FileExists(resDirect)) {
            PushUniquePath(outBins, resDirect);
        }
        if (FileExists(assetsDirect)) {
            PushUniquePath(outBins, assetsDirect);
        }
    }
}

bool WriteTargetCrcFile(const std::string& outputPath, const std::set<uint32_t>& targetCrcs) {
    if (outputPath.empty()) {
        return false;
    }

    const std::string parentDir = GetParentDirectory(outputPath);
    if (!parentDir.empty()) {
#ifdef _WIN32
        std::string mkdirCmd = "mkdir \"" + parentDir + "\" >nul 2>&1";
        std::system(mkdirCmd.c_str());
#else
        std::string mkdirCmd = "mkdir -p \"" + parentDir + "\"";
        std::system(mkdirCmd.c_str());
#endif
    }

    std::ofstream out(outputPath.c_str(), std::ios::out | std::ios::binary | std::ios::trunc);
    if (!out.is_open()) {
        return false;
    }
    out << "# target PathFileNameCRC32 list\n";
    for (std::set<uint32_t>::const_iterator it = targetCrcs.begin();
         it != targetCrcs.end();
         ++it) {
        out << *it << "\n";
    }
    return out.good();
}

bool IsDigitsOnlyString(const std::string& value) {
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

void CollectNumericRootCrcsFromScanEntries(const std::vector<SLJFP::PathMappingGenerator::PathEntry>& entries,
                                           std::set<uint32_t>& outTargetCrcs) {
    outTargetCrcs.clear();
    for (size_t i = 0; i < entries.size(); ++i) {
        const std::string& relPath = entries[i].relativePath;
        if (relPath.empty()) {
            continue;
        }
        if (relPath.find('/') != std::string::npos || relPath.find('\\') != std::string::npos) {
            continue;
        }

        size_t dot = relPath.find('.');
        std::string stem = (dot == std::string::npos) ? relPath : relPath.substr(0, dot);
        if (!IsDigitsOnlyString(stem)) {
            continue;
        }

        const uint32_t crc32 = static_cast<uint32_t>(std::strtoul(stem.c_str(), NULL, 10));
        outTargetCrcs.insert(crc32);
    }
}

bool CopyFileWithOverwrite(const std::string& sourcePath, const std::string& targetPath) {
    if (sourcePath.empty() || targetPath.empty()) {
        return false;
    }
    if (sourcePath == targetPath) {
        return true;
    }

    std::ifstream in(sourcePath.c_str(), std::ios::in | std::ios::binary);
    if (!in.is_open()) {
        return false;
    }
    std::ofstream out(targetPath.c_str(), std::ios::out | std::ios::binary | std::ios::trunc);
    if (!out.is_open()) {
        return false;
    }
    out << in.rdbuf();
    return out.good();
}

bool TryExtractJsonUnsignedField(const std::string& jsonText,
                                 const std::string& key,
                                 uint32_t* outValue) {
    if (outValue == nullptr) {
        return false;
    }
    const std::string token = "\"" + key + "\"";
    size_t pos = jsonText.find(token);
    if (pos == std::string::npos) {
        return false;
    }
    pos = jsonText.find(':', pos + token.size());
    if (pos == std::string::npos) {
        return false;
    }
    ++pos;
    while (pos < jsonText.size() && std::isspace(static_cast<unsigned char>(jsonText[pos]))) {
        ++pos;
    }
    size_t end = pos;
    while (end < jsonText.size() && std::isdigit(static_cast<unsigned char>(jsonText[end]))) {
        ++end;
    }
    if (end == pos) {
        return false;
    }
    *outValue = static_cast<uint32_t>(std::strtoul(jsonText.substr(pos, end - pos).c_str(), NULL, 10));
    return true;
}

bool ReadFileAsString(const std::string& path, std::string* outText) {
    if (outText == nullptr) {
        return false;
    }
    outText->clear();
    std::ifstream in(path.c_str(), std::ios::in | std::ios::binary);
    if (!in.is_open()) {
        return false;
    }
    std::ostringstream buffer;
    buffer << in.rdbuf();
    *outText = buffer.str();
    return true;
}

SourceTemplateSeedEnrichmentResult RunSourceTemplateSeedEnrichmentForCli(
    const std::string& inputDir,
    const std::string& outputDir,
    const std::string& existingMappingPath,
    const std::set<uint32_t>& targetCrcSet,
    const std::vector<std::string>& explicitScanRoots,
    const std::vector<std::string>& explicitMapConfigBins) {
    SourceTemplateSeedEnrichmentResult result;
    result.attempted = true;

    if (targetCrcSet.empty()) {
        result.message = "No target PathFileNameCRC32 values available; skipping source-template seeding.";
        return result;
    }

    result.scriptPath = FindSourceTemplateSeedPipelineScript();
    if (result.scriptPath.empty()) {
        result.message = "source_template_seed_pipeline.py not found; skipping source-template seeding.";
        return result;
    }

    result.pythonLauncher = DetectPythonLauncherForCli();
    if (result.pythonLauncher.empty()) {
        result.message = "Python launcher not found; skipping source-template seeding.";
        return result;
    }

    DetectSourceTemplateScanRoots(explicitScanRoots, inputDir, result.scanRoots);
    if (result.scanRoots.empty()) {
        result.message = "No usable source/config roots detected; skipping source-template seeding.";
        return result;
    }
    DetectSourceTemplateMapConfigInputs(explicitMapConfigBins, result.scanRoots, result.mapConfigInputs);

    result.reportDir = JoinPath(outputDir, "source_template_reports_cli");
    result.promoteDir = JoinPath(outputDir, "source_template_promoted_cli");
    result.summaryPath = JoinPath(result.reportDir, "source_template_summary.json");
    result.targetCrcFile = JoinPath(result.reportDir, "target_crc32.txt");

#ifdef _WIN32
    std::system(std::string("mkdir \"" + result.reportDir + "\" >nul 2>&1").c_str());
    std::system(std::string("mkdir \"" + result.promoteDir + "\" >nul 2>&1").c_str());
#else
    std::system(std::string("mkdir -p \"" + result.reportDir + "\"").c_str());
    std::system(std::string("mkdir -p \"" + result.promoteDir + "\"").c_str());
#endif

    if (!WriteTargetCrcFile(result.targetCrcFile, targetCrcSet)) {
        result.failed = true;
        result.message = "Failed to write target_crc32.txt; skipping source-template seeding.";
        return result;
    }

    std::ostringstream cmd;
    cmd << result.pythonLauncher
        << " \"" << result.scriptPath << "\""
        << " --target-crc-file \"" << result.targetCrcFile << "\""
        << " --output-dir \"" << result.reportDir << "\""
        << " --promote-dir \"" << result.promoteDir << "\"";
    if (!existingMappingPath.empty()) {
        cmd << " --mapping \"" << existingMappingPath << "\"";
    }
    for (size_t i = 0; i < result.scanRoots.size(); ++i) {
        cmd << " --scan-root \"" << result.scanRoots[i] << "\"";
    }
    for (size_t i = 0; i < result.mapConfigInputs.size(); ++i) {
        cmd << " --map-config-bin \"" << result.mapConfigInputs[i] << "\"";
    }

    result.exitCode = std::system(cmd.str().c_str());
    result.executed = true;
    if (result.exitCode != 0) {
        result.failed = true;
        result.message = "source-template seeding script failed.";
        return result;
    }

    std::string summaryJson;
    if (!ReadFileAsString(result.summaryPath, &summaryJson)) {
        result.failed = true;
        result.message = "source-template seeding executed, but summary json was not found.";
        return result;
    }

    if (!TryExtractJsonUnsignedField(summaryJson, "direct_hits", &result.directHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "existing_hits", &result.existingHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "merged_hits", &result.mergedHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "hit_gain", &result.hitGain) ||
        !TryExtractJsonUnsignedField(summaryJson, "new_hits", &result.newHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "mapping_conflicts", &result.mappingConflicts) ||
        !TryExtractJsonUnsignedField(summaryJson, "seed_conflicts", &result.seedConflicts)) {
        result.failed = true;
        result.message = "source-template summary fields are incomplete.";
        return result;
    }

    const std::string promotedBinaryPath = JoinPath(result.promoteDir, "path_mapping.ljpm");
    const std::string promotedTextPath = JoinPath(result.promoteDir, "path_mapping.txt");
    if (!FileExists(promotedBinaryPath) || !FileExists(promotedTextPath)) {
        result.failed = true;
        result.message = "source-template seeding did not produce promoted path_mapping outputs.";
        return result;
    }

    if (result.hitGain == 0 || result.mergedHits <= result.existingHits) {
        result.message = "source-template seeding executed, but produced no coverage gain.";
        return result;
    }

    result.promoted = true;
    result.message = "source-template seeding promoted a merged mapping.";
    return result;
}

bool ResolveInputAndIndexPath(
    const std::string& inputArg,
    const std::string& indexArg,
    std::string* resolvedInputDir,
    std::string* resolvedIndexPath,
    std::string* errorMessage) {
    if (resolvedInputDir == nullptr || resolvedIndexPath == nullptr || errorMessage == nullptr) {
        return false;
    }

    resolvedInputDir->clear();
    resolvedIndexPath->clear();
    errorMessage->clear();

    if (!indexArg.empty()) {
        if (!FileExists(indexArg)) {
            *errorMessage = "指定的索引文件不存在: " + indexArg;
            return false;
        }
        *resolvedIndexPath = indexArg;
        *resolvedInputDir = inputArg.empty() ? GetParentDirectory(indexArg) : inputArg;
        return true;
    }

    if (inputArg.empty()) {
        *errorMessage = "未指定输入目录或索引文件";
        return false;
    }

    if (IsIndexFilePath(inputArg)) {
        if (!FileExists(inputArg)) {
            *errorMessage = "索引文件不存在: " + inputArg;
            return false;
        }
        *resolvedIndexPath = inputArg;
        *resolvedInputDir = GetParentDirectory(inputArg);
        return true;
    }

    *resolvedInputDir = inputArg;

    std::string ljpiPath = JoinPath(inputArg, "fl.ljpi");
    std::string ljzipPath = JoinPath(inputArg, "fl.ljzip");

    if (FileExists(ljpiPath)) {
        *resolvedIndexPath = ljpiPath;
        return true;
    }
    if (FileExists(ljzipPath)) {
        *resolvedIndexPath = ljzipPath;
        return true;
    }

    *errorMessage = "输入目录中未找到 fl.ljpi 或 fl.ljzip: " + inputArg;
    return false;
}

bool ParseDecryptMode(const std::string& rawMode, SLJFP::DecryptMode* modeOut) {
    if (modeOut == nullptr) {
        return false;
    }

    std::string mode = rawMode;
    std::transform(mode.begin(), mode.end(), mode.begin(), [](unsigned char c) {
        return static_cast<char>(std::tolower(c));
    });

    if (mode == "auto") {
        *modeOut = SLJFP::DecryptMode::Auto;
        return true;
    }
    if (mode == "lj" || mode == "ljfilepack" || mode == "ljfilepacksms4" || mode == "sms4") {
        *modeOut = SLJFP::DecryptMode::LJFilePackSMS4;
        return true;
    }
    if (mode == "apk" || mode == "apkclientobf" || mode == "clientobf") {
        *modeOut = SLJFP::DecryptMode::ApkClientObf;
        return true;
    }
    return false;
}

bool ParsePathHashMode(const std::string& rawMode,
                       SLJFP::PathMappingGenerator::PathHashMode* modeOut) {
    if (modeOut == nullptr) {
        return false;
    }

    std::string mode = rawMode;
    std::transform(mode.begin(), mode.end(), mode.begin(), [](unsigned char c) {
        return static_cast<char>(std::tolower(c));
    });

    typedef SLJFP::PathMappingGenerator::PathHashMode PathHashMode;
    if (mode == "normalized" || mode == "default") {
        *modeOut = PathHashMode::NormalizedPath;
        return true;
    }
    if (mode == "legacy" || mode == "legacy-acp" ||
        mode == "ljfilepack" || mode == "ljfilepack-legacy") {
        *modeOut = PathHashMode::LjFilePackLegacyAcpExact;
        return true;
    }
    return false;
}

const char* DecryptModeToText(SLJFP::DecryptMode mode) {
    switch (mode) {
        case SLJFP::DecryptMode::LJFilePackSMS4:
            return "LJFilePack-SMS4";
        case SLJFP::DecryptMode::ApkClientObf:
            return "APK-ClientObf";
        case SLJFP::DecryptMode::Auto:
        default:
            return "Auto";
    }
}

std::string NarrowAsciiBestEffort(const std::wstring& text) {
    std::string out;
    out.reserve(text.size());
    for (size_t i = 0; i < text.size(); ++i) {
        const wchar_t ch = text[i];
        out.push_back((ch >= 0 && ch <= 0x7F) ? static_cast<char>(ch) : '?');
    }
    return out;
}

std::string EscapeJsonString(const std::string& value) {
    std::ostringstream oss;
    for (size_t i = 0; i < value.size(); ++i) {
        const unsigned char ch = static_cast<unsigned char>(value[i]);
        switch (ch) {
            case '\"': oss << "\\\""; break;
            case '\\': oss << "\\\\"; break;
            case '\b': oss << "\\b"; break;
            case '\f': oss << "\\f"; break;
            case '\n': oss << "\\n"; break;
            case '\r': oss << "\\r"; break;
            case '\t': oss << "\\t"; break;
            default:
                if (ch < 0x20) {
                    char buffer[7];
                    std::sprintf(buffer, "\\u%04x", ch);
                    oss << buffer;
                } else {
                    oss << static_cast<char>(ch);
                }
                break;
        }
    }
    return oss.str();
}

std::string FormatCRC32Hex(uint32_t value) {
    char buffer[11];
    std::sprintf(buffer, "0x%08X", value);
    return std::string(buffer);
}

std::string FormatErrorCodeTextNarrow(int code) {
    if (code == 0) {
        return "0 (Operation successful)";
    }

    std::ostringstream oss;
    oss << code << " (" << NarrowAsciiBestEffort(
        GetErrorMessage(static_cast<SLJFP::ErrorCode>(code))) << ")";
    return oss.str();
}

bool ExportFirstFailedDecryptDiagnosticJson(const SLJFP::Unpacker& unpacker,
                                           const std::string& outputDir,
                                           std::string* outPath) {
    if (outPath != nullptr) {
        outPath->clear();
    }

    SLJFP::DecryptFailureDiagnostic diagnostic;
    if (!unpacker.GetFirstFailedDecryptDiagnostic(diagnostic)) {
        return false;
    }

    const std::string path = JoinPath(outputDir, "review_failed_first_decrypt_all_failed.json");
    std::ofstream jsonOut(path.c_str(), std::ios::binary | std::ios::trunc);
    if (!jsonOut.is_open()) {
        return false;
    }

    jsonOut << "{\n";
    jsonOut << "  \"version\": 1,\n";
    jsonOut << "  \"file_index\": " << diagnostic.fileIndex << ",\n";
    jsonOut << "  \"input_size\": " << diagnostic.inputSize << ",\n";
    jsonOut << "  \"failure_code\": " << diagnostic.failureCode << ",\n";
    jsonOut << "  \"failure_text\": \"" << EscapeJsonString(FormatErrorCodeTextNarrow(diagnostic.failureCode)) << "\",\n";
    jsonOut << "  \"file_info\": {\n";
    jsonOut << "    \"path_crc32\": \"" << EscapeJsonString(FormatCRC32Hex(diagnostic.fileInfo.m_PathFileNameCRC32)) << "\",\n";
    jsonOut << "    \"pack_index\": " << diagnostic.fileInfo.m_PackIndex << ",\n";
    jsonOut << "    \"size\": " << diagnostic.fileInfo.m_Size << ",\n";
    jsonOut << "    \"size_original\": " << diagnostic.fileInfo.m_SizeOriginal << ",\n";
    jsonOut << "    \"crc32\": \"" << EscapeJsonString(FormatCRC32Hex(diagnostic.fileInfo.m_CRC32)) << "\",\n";
    jsonOut << "    \"crc32_original\": \"" << EscapeJsonString(FormatCRC32Hex(diagnostic.fileInfo.m_CRC32Original)) << "\",\n";
    jsonOut << "    \"compress_type\": " << diagnostic.fileInfo.m_CompressType << ",\n";
    jsonOut << "    \"code_type\": " << diagnostic.fileInfo.m_CodeType << "\n";
    jsonOut << "  },\n";
    jsonOut << "  \"display_path\": \"" << EscapeJsonString(unpacker.GetFilePath(static_cast<size_t>(diagnostic.fileIndex))) << "\",\n";
    jsonOut << "  \"candidates\": [\n";

    for (size_t i = 0; i < diagnostic.candidates.size(); ++i) {
        const SLJFP::DecryptProbeRecord& record = diagnostic.candidates[i];
        if (i > 0) {
            jsonOut << ",\n";
        }

        jsonOut << "    {\n";
        jsonOut << "      \"candidate_id\": \"" << EscapeJsonString(record.candidateId) << "\",\n";
        jsonOut << "      \"mode\": \"" << EscapeJsonString(DecryptModeToText(record.mode)) << "\",\n";
        jsonOut << "      \"apply_decrypt\": " << (record.applyDecrypt ? "true" : "false") << ",\n";
        jsonOut << "      \"use_full_window\": " << (record.useFullWindow ? "true" : "false") << ",\n";
        jsonOut << "      \"need_decompress\": " << (record.needDecompress ? "true" : "false") << ",\n";
        jsonOut << "      \"error_code\": " << record.errorCode << ",\n";
        jsonOut << "      \"error_text\": \"" << EscapeJsonString(FormatErrorCodeTextNarrow(record.errorCode)) << "\",\n";
        jsonOut << "      \"unzip_result\": " << record.unzipResult << ",\n";
        jsonOut << "      \"selected\": " << (record.selected ? "true" : "false") << ",\n";
        jsonOut << "      \"crc_checked\": " << (record.crcChecked ? "true" : "false") << ",\n";
        jsonOut << "      \"crc_matched\": " << (record.crcMatched ? "true" : "false") << ",\n";
        jsonOut << "      \"expected_crc32\": \"" << EscapeJsonString(FormatCRC32Hex(record.expectedCRC32)) << "\",\n";
        jsonOut << "      \"actual_crc32\": \"" << EscapeJsonString(FormatCRC32Hex(record.actualCRC32)) << "\",\n";
        jsonOut << "      \"input_size\": " << record.inputSize << ",\n";
        jsonOut << "      \"transformed_size\": " << record.transformedSize << ",\n";
        jsonOut << "      \"output_size\": " << record.outputSize << ",\n";
        jsonOut << "      \"input_signature\": \"" << EscapeJsonString(record.inputSignature) << "\",\n";
        jsonOut << "      \"transformed_signature\": \"" << EscapeJsonString(record.transformedSignature) << "\",\n";
        jsonOut << "      \"output_signature\": \"" << EscapeJsonString(record.outputSignature) << "\",\n";
        jsonOut << "      \"input_prefix_hex\": \"" << EscapeJsonString(record.inputPrefixHex) << "\",\n";
        jsonOut << "      \"transformed_prefix_hex\": \"" << EscapeJsonString(record.transformedPrefixHex) << "\",\n";
        jsonOut << "      \"output_prefix_hex\": \"" << EscapeJsonString(record.outputPrefixHex) << "\"\n";
        jsonOut << "    }";
    }

    jsonOut << "\n  ]\n";
    jsonOut << "}\n";
    jsonOut.close();

    if (outPath != nullptr) {
        *outPath = path;
    }
    return true;
}

const char* PathHashModeToText(SLJFP::PathMappingGenerator::PathHashMode mode) {
    switch (mode) {
        case SLJFP::PathMappingGenerator::PathHashMode::LjFilePackLegacyAcpExact:
            return "LJFilePack-Legacy-ACP";
        case SLJFP::PathMappingGenerator::PathHashMode::NormalizedPath:
        default:
            return "NormalizedPath";
    }
}

std::string ResolveDecryptKeyForCli(const std::string& inputDir,
                                    const std::string& explicitLibgamePath,
                                    const std::string& userKey,
                                    std::string* keyMessage) {
    if (keyMessage != nullptr) {
        keyMessage->clear();
    }

    if (!userKey.empty()) {
        if (keyMessage != nullptr) {
            *keyMessage = "使用显式传入的 --decrypt-key。";
        }
        return userKey;
    }

    SLJFP::AndroidBinaryKeyProbeResult probeResult;
    if (SLJFP::TryResolveAndroidLibgameDecryptKey(inputDir, explicitLibgamePath, probeResult)) {
        if (keyMessage != nullptr) {
            *keyMessage = "已从 Android libgame.so 自动提取解密 key: " +
                probeResult.libgamePath;
        }
        return probeResult.decryptKey;
    }

    if (keyMessage != nullptr) {
        if (!probeResult.message.empty()) {
            *keyMessage = "未能自动提取 Android key，继续使用默认 key。原因: " +
                probeResult.message;
        } else {
            *keyMessage = "未提供 --decrypt-key，且未发现可提取 key 的 Android libgame.so，继续使用默认 key。";
        }
    }
    return std::string();
}

#ifdef _WIN32
std::wstring Utf8ToWide(const std::string& text) {
    if (text.empty()) {
        return std::wstring();
    }

    const int length = MultiByteToWideChar(
        CP_UTF8, 0, text.c_str(), static_cast<int>(text.size()), NULL, 0);
    if (length <= 0) {
        return std::wstring();
    }

    std::wstring wide(static_cast<size_t>(length), L'\0');
    MultiByteToWideChar(
        CP_UTF8, 0, text.c_str(), static_cast<int>(text.size()), &wide[0], length);
    return wide;
}

std::wstring BuildHelpTextWide() {
    return Utf8ToWide(BuildHelpTextUtf8());
}

bool WriteWideTextToConsole(const std::wstring& text) {
    const HANDLE stdoutHandle = GetStdHandle(STD_OUTPUT_HANDLE);
    if (stdoutHandle == NULL || stdoutHandle == INVALID_HANDLE_VALUE) {
        return false;
    }

    DWORD consoleMode = 0;
    if (!GetConsoleMode(stdoutHandle, &consoleMode)) {
        return false;
    }

    const DWORD textLength = static_cast<DWORD>(text.size());
    DWORD written = 0;
    return WriteConsoleW(stdoutHandle,
                         text.c_str(),
                         textLength,
                         &written,
                         NULL) != 0 &&
           written == textLength;
}

void WriteUtf8TextToStdout(const std::string& text) {
    if (!text.empty()) {
        std::fwrite(text.data(), 1, text.size(), stdout);
    }
    std::fflush(stdout);
}

void WriteHelpTextWindows() {
    const std::wstring wideText = BuildHelpTextWide();
    if (WriteWideTextToConsole(wideText)) {
        return;
    }

    const std::string helpText = BuildHelpTextUtf8();
    WriteUtf8TextToStdout(helpText);
}
#endif

std::string BuildHelpTextUtf8() {
    std::ostringstream oss;
    oss << "SuperLJFilePackUnpack - LJFilePack "
        << "\xE8\xB5\x84\xE6\xBA\x90\xE5\x8C\x85\xE8\xA7\xA3\xE5\x8C\x85\xE5\xB7\xA5\xE5\x85\xB7"
        << " v1.1\n\n";
    oss << "\xE7\x94\xA8\xE6\xB3\x95:\n";
    oss << "  ljfp-unpack <"
        << "\xE8\xBE\x93\xE5\x85\xA5\xE7\x9B\xAE\xE5\xBD\x95|\xE7\xB4\xA2\xE5\xBC\x95\xE6\x96\x87\xE4\xBB\xB6"
        << "> ["
        << "\xE8\xBE\x93\xE5\x87\xBA\xE7\x9B\xAE\xE5\xBD\x95"
        << "] ["
        << "\xE9\x80\x89\xE9\xA1\xB9"
        << "]\n\n";
    oss << "\xE5\x8F\x82\xE6\x95\xB0:\n";
    oss << "  "
        << "\xE8\xBE\x93\xE5\x85\xA5\xE7\x9B\xAE\xE5\xBD\x95"
        << "    "
        << "\xE5\x8C\x85\xE5\x90\xAB .ljpi/.ljzip \xE7\xB4\xA2\xE5\xBC\x95\xE6\x96\x87\xE4\xBB\xB6\xE5\x92\x8C .ljfp \xE5\x8C\x85\xE6\x96\x87\xE4\xBB\xB6\xE7\x9A\x84\xE7\x9B\xAE\xE5\xBD\x95"
        << "\n";
    oss << "  "
        << "\xE7\xB4\xA2\xE5\xBC\x95\xE6\x96\x87\xE4\xBB\xB6"
        << "    "
        << "\xE7\x9B\xB4\xE6\x8E\xA5\xE4\xBC\xA0\xE5\x85\xA5 .ljpi \xE6\x88\x96 .ljzip \xE6\x96\x87\xE4\xBB\xB6\xE8\xB7\xAF\xE5\xBE\x84"
        << "\n";
    oss << "  "
        << "\xE8\xBE\x93\xE5\x87\xBA\xE7\x9B\xAE\xE5\xBD\x95"
        << "    "
        << "\xE8\xA7\xA3\xE5\x8C\x85\xE5\x90\x8E\xE6\x96\x87\xE4\xBB\xB6\xE7\x9A\x84\xE8\xBE\x93\xE5\x87\xBA\xE7\x9B\xAE\xE5\xBD\x95"
        << " (\xE9\xBB\x98\xE8\xAE\xA4: ./unpacked/)\n\n";
    oss << "\xE9\x80\x89\xE9\xA1\xB9:\n";
    oss << "  --index=FILE      "
        << "\xE6\x98\xBE\xE5\xBC\x8F\xE6\x8C\x87\xE5\xAE\x9A\xE7\xB4\xA2\xE5\xBC\x95\xE6\x96\x87\xE4\xBB\xB6\xE8\xB7\xAF\xE5\xBE\x84 (\xE5\x8F\xAF\xE4\xB8\x8E\xE8\xBE\x93\xE5\x85\xA5\xE7\x9B\xAE\xE5\xBD\x95\xE9\x85\x8D\xE5\x90\x88)"
        << "\n";
    oss << "  --no-verify       "
        << "\xE8\xB7\xB3\xE8\xBF\x87 CRC32 \xE6\xA0\xA1\xE9\xAA\x8C"
        << "\n";
    oss << "  --overwrite       "
        << "\xE8\xA6\x86\xE7\x9B\x96\xE5\xB7\xB2\xE5\xAD\x98\xE5\x9C\xA8\xE6\x96\x87\xE4\xBB\xB6"
        << "\n";
    oss << "  --mapping=FILE    "
        << "\xE5\x8A\xA0\xE8\xBD\xBD\xE5\xA4\x96\xE9\x83\xA8\xE8\xB7\xAF\xE5\xBE\x84\xE6\x98\xA0\xE5\xB0\x84\xE6\x96\x87\xE4\xBB\xB6 (\xE4\xB8\xA4\xE9\x98\xB6\xE6\xAE\xB5\xE6\x81\xA2\xE5\xA4\x8D\xE4\xBC\x9A\xE4\xBC\x98\xE5\x85\x88\xE4\xBD\xBF\xE7\x94\xA8)"
        << "\n";
    oss << "  --scan=DIR        "
        << "\xE6\x89\xAB\xE6\x8F\x8F\xE7\x9B\xAE\xE5\xBD\x95\xE7\x94\x9F\xE6\x88\x90\xE8\xB7\xAF\xE5\xBE\x84\xE6\x98\xA0\xE5\xB0\x84\xE6\x96\x87\xE4\xBB\xB6\xE5\x88\xB0 path_mapping.ljpm"
        << "\n";
    oss << "  --scan-hash-mode=MODE  "
        << "\xE6\x89\xAB\xE6\x8F\x8F CRC \xE8\xBE\x93\xE5\x85\xA5\xE6\xA8\xA1\xE5\xBC\x8F: normalized | legacy-acp"
        << "\n";
    oss << "  --no-source-template-seed  "
        << "disable source-template seed enrichment (best-effort by default)"
        << "\n";
    oss << "  --source-scan-root=DIR  "
        << "add source/config scan root for source-template seeding (repeatable)"
        << "\n";
    oss << "  --source-map-config-bin=FILE  "
        << "add explicit map.cmapconfig.bin for source-template seeding (repeatable)"
        << "\n";
    oss << "  --strict-restore  "
        << "\xE4\xB8\xA5\xE6\xA0\xBC\xE6\xA0\xA1\xE9\xAA\x8C\xE8\xBF\x98\xE5\x8E\x9F\xE7\xBB\x93\xE6\x9E\x9C\xEF\xBC\x88\xE8\xA6\x81\xE6\xB1\x82\xE6\x98\xA0\xE5\xB0\x84\xE5\x85\xA8\xE8\xA6\x86\xE7\x9B\x96\xE4\xB8\x94\xE6\x97\xA0\xE6\x95\xB0\xE5\xAD\x97\xE6\xAE\x8B\xE7\x95\x99\xEF\xBC\x89"
        << "\n";
    oss << "  --no-detect       "
        << "\xE7\xA6\x81\xE7\x94\xA8\xE6\x96\x87\xE4\xBB\xB6\xE7\xB1\xBB\xE5\x9E\x8B\xE8\x87\xAA\xE5\x8A\xA8\xE6\xA3\x80\xE6\xB5\x8B"
        << "\n";
    oss << "  --keep-root-residuals  "
        << "\xE4\xBF\x9D\xE7\x95\x99\xE6\xA0\xB9\xE7\x9B\xAE\xE5\xBD\x95\xE6\x9C\xAA\xE6\x81\xA2\xE5\xA4\x8D\xE7\x9A\x84\xE6\x95\xB0\xE5\xAD\x97\xE6\x96\x87\xE4\xBB\xB6\xEF\xBC\x88\xE9\xBB\x98\xE8\xAE\xA4\xE5\xBD\x92\xE6\xA1\xA3\xE5\x88\xB0 review/unresolved\xEF\xBC\x89"
        << "\n";
    oss << "  --review-aliases  "
        << "\xE4\xB8\xBA model/<dir>/CRC.atlas|json \xE9\xA2\x9D\xE5\xA4\x96\xE5\x86\x99\xE5\x87\xBA <dir>.atlas|json \xE5\x89\xAF\xE6\x9C\xAC"
        << "\n";
    oss << "  --decrypt-mode=M  "
        << "\xE8\xA7\xA3\xE5\xAF\x86\xE6\xA8\xA1\xE5\xBC\x8F: auto | lj | apk\n";
    oss << "  --decrypt-key=K   "
        << "\xE8\x87\xAA\xE5\xAE\x9A\xE4\xB9\x89\xE8\xA7\xA3\xE5\xAF\x86\xE5\xAF\x86\xE9\x92\xA5 (\xE4\xBB\x85 LJFilePack-SMS4 \xE7\x94\x9F\xE6\x95\x88)"
        << "\n";
    oss << "  --android-libgame=PATH  "
        << "\xE6\x8C\x87\xE5\xAE\x9A Android libgame.so \xE6\x88\x96 APK \xE8\xA7\xA3\xE5\x8C\x85\xE6\xA0\xB9\xE7\x9B\xAE\xE5\xBD\x95\xEF\xBC\x8C\xE7\x94\xA8\xE4\xBA\x8E\xE8\x87\xAA\xE5\x8A\xA8\xE6\x8F\x90\xE5\x8F\x96\xE8\xA7\xA3\xE5\xAF\x86 key"
        << "\n";
    oss << "  --help            "
        << "\xE6\x98\xBE\xE7\xA4\xBA\xE6\xAD\xA4\xE5\xB8\xAE\xE5\x8A\xA9\xE4\xBF\xA1\xE6\x81\xAF"
        << "\n\n";
    oss << "\xE7\xA4\xBA\xE4\xBE\x8B:\n";
    oss << "  ljfp-unpack ./resources_packed/\n";
    oss << "  ljfp-unpack ./resources_packed/ ./output/ --mapping=path_mapping.ljpm\n";
    oss << "  ljfp-unpack --scan=./client/resource/res/\n\n";
    oss << "\xE6\x94\xAF\xE6\x8C\x81\xE7\x9A\x84\xE6\x96\x87\xE4\xBB\xB6\xE7\xB1\xBB\xE5\x9E\x8B\xE6\xA3\x80\xE6\xB5\x8B:\n";
    oss << "  " << SLJFP::FileTypeDetector::GetSupportedExtensions() << "\n\n";
    return oss.str();
}

} // namespace

// 显示帮助信息
void ShowHelp() {
#ifdef _WIN32
    WriteHelpTextWindows();
#else
    std::cout << BuildHelpTextUtf8();
    std::cout.flush();
#endif
}

// 进度回调函数
void ProgressCallback(float progress, uint32_t current, uint32_t total) {
    const int barWidth = 50;
    int pos = static_cast<int>(barWidth * progress);

    std::cout << "\r[";
    for (int i = 0; i < barWidth; ++i) {
        if (i < pos) std::cout << "=";
        else if (i == pos) std::cout << ">";
        else std::cout << " ";
    }
    std::cout << "] " << static_cast<int>(progress * 100) << "% "
              << "(" << current << "/" << total << ")";
    std::cout.flush();
}

#ifndef SLJFP_UNPACKEXAMPLE_UNIT_TEST
int main(int argc, char* argv[]) {
    // 检查参数
    if (argc < 2) {
        ShowHelp();
        return 1;
    }

    // 解析命令行参数
    std::string inputArg;
    std::string outputDir = "./unpacked/";
    std::string indexFileArg;
    std::string mappingFile;
    std::string scanDir;
    std::vector<std::string> sourceScanRoots;
    std::vector<std::string> sourceMapConfigBins;
    bool verifyCRC32 = true;
    bool overwrite = false;
    bool detectFileType = true;
    bool relocateRootResiduals = true;
    bool writeReviewAliases = false;
    bool strictRestore = false;
    bool enableSourceTemplateSeed = true;
    std::string decryptModeArg = "auto";
    std::string scanHashModeArg = "normalized";
    std::string decryptKeyArg;
    std::string androidLibgameArg;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];

        if (arg == "--help" || arg == "-h") {
            ShowHelp();
            return 0;
        } else if (arg == "--no-verify") {
            verifyCRC32 = false;
        } else if (arg == "--overwrite") {
            overwrite = true;
        } else if (arg == "--no-detect") {
            detectFileType = false;
        } else if (arg == "--keep-root-residuals") {
            relocateRootResiduals = false;
        } else if (arg == "--review-aliases") {
            writeReviewAliases = true;
        } else if (arg == "--no-source-template-seed") {
            enableSourceTemplateSeed = false;
        } else if (arg == "--strict-restore") {
            strictRestore = true;
        } else if (arg.substr(0, 8) == "--index=") {
            indexFileArg = arg.substr(8);
        } else if (arg.substr(0, 10) == "--mapping=") {
            mappingFile = arg.substr(10);
        } else if (arg.substr(0, 7) == "--scan=") {
            scanDir = arg.substr(7);
        } else if (arg.substr(0, 19) == "--source-scan-root=") {
            sourceScanRoots.push_back(arg.substr(19));
        } else if (arg.substr(0, 24) == "--source-map-config-bin=") {
            sourceMapConfigBins.push_back(arg.substr(24));
        } else if (arg.substr(0, 17) == "--scan-hash-mode=") {
            scanHashModeArg = arg.substr(17);
        } else if (arg.substr(0, 15) == "--decrypt-mode=") {
            decryptModeArg = arg.substr(15);
        } else if (arg.substr(0, 14) == "--decrypt-key=") {
            decryptKeyArg = arg.substr(14);
        } else if (arg.substr(0, 18) == "--android-libgame=") {
            androidLibgameArg = arg.substr(18);
        } else if (inputArg.empty()) {
            inputArg = arg;
        } else if (outputDir == "./unpacked/") {
            outputDir = arg;
        }
    }

    SLJFP::DecryptMode decryptMode = SLJFP::DecryptMode::Auto;
    if (!ParseDecryptMode(decryptModeArg, &decryptMode)) {
        std::cerr << "Error: 无效的 --decrypt-mode 值: " << decryptModeArg << "\n";
        std::cerr << "可用值: auto | lj | apk\n\n";
        ShowHelp();
        return 1;
    }

    SLJFP::PathMappingGenerator::PathHashMode scanHashMode =
        SLJFP::PathMappingGenerator::PathHashMode::NormalizedPath;
    if (!ParsePathHashMode(scanHashModeArg, &scanHashMode)) {
        std::cerr << "Error: 无效的 --scan-hash-mode 值: " << scanHashModeArg << "\n";
        std::cerr << "可用值: normalized | legacy-acp\n\n";
        ShowHelp();
        return 1;
    }

    // 如果是扫描模式，执行扫描并退出
    if (!scanDir.empty()) {
        std::cout << "========================================\n";
        std::cout << "  Path Mapping Generator\n";
        std::cout << "========================================\n";
        std::cout << "Scanning directory: " << scanDir << "\n\n";
        std::cout << "Path hash mode: " << PathHashModeToText(scanHashMode) << "\n\n";

        SLJFP::PathMappingGenerator generator;
        generator.SetCRC32Function(PathMappingCRC32Adapter);
        SLJFP::PathMappingGenerator::ScanOptions scanOptions;
        scanOptions.recursiveScan = true;
        scanOptions.lowercasePaths = true;
        scanOptions.normalizeSlashes = true;
        scanOptions.pathHashMode = scanHashMode;

        uint32_t count = generator.ScanDirectory(scanDir, scanOptions);
        const SLJFP::PathMappingGenerator::ScanStats& stats = generator.GetStats();

        std::cout << "Scan completed!\n";
        std::cout << "  Files: " << stats.totalFiles << "\n";
        std::cout << "  Directories: " << stats.totalDirs << "\n";
        std::cout << "  Total size: " << (stats.totalBytes / 1024 / 1024) << " MB\n";
        std::cout << "  Collisions: " << stats.collisions << "\n";
        std::cout << "  Time: " << stats.scanTimeMs << " ms\n\n";

        // 保存映射文件
        std::string outputMapping = "path_mapping.ljpm";
        int result = generator.SaveMappingBinary(outputMapping);
        if (result == SLJFP::LJFP_SUCCESS) {
            std::cout << "Mapping saved to: " << outputMapping << "\n";
            std::cout << "Entries: " << count << "\n";

            // 同时保存文本格式用于调试
            generator.SaveMapping("path_mapping.txt", true);
            std::cout << "Text format saved to: path_mapping.txt\n";

            if (enableSourceTemplateSeed) {
                std::set<uint32_t> targetCrcSet;
                CollectNumericRootCrcsFromScanEntries(generator.GetEntries(), targetCrcSet);
                std::cout << "Numeric CRC targets detected for source-template seeding: "
                          << targetCrcSet.size() << "\n";
                if (!targetCrcSet.empty()) {
                    std::cout << "\nRunning source-template seed enrichment after scan...\n";
                    const SourceTemplateSeedEnrichmentResult sourceTemplateResult =
                        RunSourceTemplateSeedEnrichmentForCli(scanDir,
                                                             ".",
                                                             outputMapping,
                                                             targetCrcSet,
                                                             sourceScanRoots,
                                                             sourceMapConfigBins);
                    if (sourceTemplateResult.promoted) {
                        const std::string promotedBinaryPath =
                            JoinPath(sourceTemplateResult.promoteDir, "path_mapping.ljpm");
                        const std::string promotedTextPath =
                            JoinPath(sourceTemplateResult.promoteDir, "path_mapping.txt");
                        bool copiedBinary = CopyFileWithOverwrite(promotedBinaryPath, outputMapping);
                        bool copiedText = CopyFileWithOverwrite(promotedTextPath, "path_mapping.txt");
                        if (copiedBinary && copiedText) {
                            std::cout << "Source-template merged mapping saved to: " << outputMapping << "\n";
                            std::cout << "  Direct hits: " << sourceTemplateResult.directHits
                                      << ", new hits: " << sourceTemplateResult.newHits
                                      << ", coverage: " << sourceTemplateResult.existingHits
                                      << " -> " << sourceTemplateResult.mergedHits << "\n";
                            std::cout << "  Report dir: " << sourceTemplateResult.reportDir << "\n";
                        } else {
                            std::cout << "  Warning: source-template promoted mapping was produced but could not overwrite path_mapping outputs\n";
                        }
                    } else if (!sourceTemplateResult.message.empty()) {
                        std::cout << "  Source-template seed result: " << sourceTemplateResult.message << "\n";
                    }
                } else {
                    std::cout << "\nSource-template seed enrichment skipped: scan directory does not expose numeric target CRC files.\n";
                }
            }
        } else {
            std::cerr << "Failed to save mapping file (error: " << result << ")\n";
            return 1;
        }

        return 0;
    }

    std::string inputDir;
    std::string indexPath;
    std::string resolveError;
    if (!ResolveInputAndIndexPath(inputArg, indexFileArg, &inputDir, &indexPath, &resolveError)) {
        std::cerr << "Error: " << resolveError << "\n\n";
        ShowHelp();
        return 1;
    }

    // 确保路径以 / 结尾
    if (inputDir.back() != '/' && inputDir.back() != '\\') {
        inputDir += "/";
    }
    if (outputDir.back() != '/' && outputDir.back() != '\\') {
        outputDir += "/";
    }

    std::string decryptKeyMessage;
    const std::string resolvedDecryptKey =
        ResolveDecryptKeyForCli(inputDir, androidLibgameArg, decryptKeyArg, &decryptKeyMessage);

    // 初始化日志系统
    InitLogger(L"ljfp-unpack.log", SLJFP::LOG_INFO);
    SLJFP::Logger::Instance().Initialize(L"ljfp-unpack.log", SLJFP::LOG_INFO);

    std::cout << "========================================\n";
    std::cout << "  SuperLJFilePackUnpack v1.1\n";
    std::cout << "========================================\n";
    std::cout << "Input directory: " << inputDir << "\n";
    std::cout << "Index file: " << indexPath << "\n";
    std::cout << "Output directory: " << outputDir << "\n";
    std::cout << "CRC32 verification: " << (verifyCRC32 ? "Enabled" : "Disabled") << "\n";
    std::cout << "Overwrite files: " << (overwrite ? "Yes" : "No") << "\n";
    if (detectFileType) {
        std::cout << "File type detection: Enabled (phase-3 suffix restore for unresolved CRC files)\n";
    } else {
        std::cout << "File type detection: Disabled (--no-detect)\n";
    }
    std::cout << "Decrypt mode: " << DecryptModeToText(decryptMode) << "\n";
    std::cout << "Decrypt key: " << (resolvedDecryptKey.empty() ? "(default)" : resolvedDecryptKey) << "\n";
    if (!androidLibgameArg.empty()) {
        std::cout << "Android libgame hint: " << androidLibgameArg << "\n";
    }
    if (!decryptKeyMessage.empty()) {
        std::cout << "Decrypt key source: " << decryptKeyMessage << "\n";
    }
    std::cout << "Review aliases: "
              << (writeReviewAliases ? "Enabled (--review-aliases)" : "Disabled") << "\n";
    std::cout << "Root residual bucket: "
              << (relocateRootResiduals ? "Enabled (review/unresolved)" :
                  "Disabled (--keep-root-residuals)") << "\n";
    std::cout << "Strict restore validation: "
              << (strictRestore ? "Enabled (--strict-restore)" : "Disabled") << "\n";
    std::cout << "Source-template seeding: "
              << (enableSourceTemplateSeed ? "Enabled (best-effort)" : "Disabled (--no-source-template-seed)") << "\n";
    if (!mappingFile.empty()) {
        std::cout << "Path mapping: " << mappingFile << "\n";
    }
    std::cout << "Output strategy: Phase-1 CRC output + Phase-2 path restore "
              << "+ Phase-3 suffix restore for unresolved CRC files";
    if (relocateRootResiduals) {
        std::cout << " + Phase-4 review bucket for unresolved root residuals";
    }
    std::cout << "\n";
    std::cout << "========================================\n\n";

    // 创建解包器
    SLJFP::Unpacker unpacker(
        SLJFP_crc32,           // CRC32 函数 (wrapper)
        SLJFP_mz_compress2,    // 压缩函数 (wrapper)
        SLJFP_mz_uncompress,   // 解压函数 (wrapper)
        SLJFP_SMS4Ex,          // 加密函数 (wrapper)
        SLJFP_DeSMS4Ex         // 解密函数 (wrapper)
    );

    if (!resolvedDecryptKey.empty()) {
        unpacker.SetDecryptKey(resolvedDecryptKey);
    }

    // 仅在交互式终端启用进度条，避免重定向/管道场景被频繁刷新阻塞
    if (ShouldUseProgressOutput()) {
        unpacker.SetProgressCallback(ProgressCallback);
    } else {
        std::cout << "Progress display: Disabled (stdout redirected)\n";
    }

    // 加载索引文件
    std::cout << "Loading index file...\n";
    int result = unpacker.LoadIndex(indexPath);

    if (result != SLJFP::LJFP_SUCCESS) {
        std::cerr << "\nError: Cannot load index file (error code: " << result << ")\n";
        std::cerr << "Please ensure the input directory contains fl.ljpi or fl.ljzip file\n";
        SLJFP::Logger::Instance().Shutdown();
        CloseLogger();
        return 1;
    }

    uint32_t totalFiles = unpacker.GetTotalFiles();
    uint64_t totalBytes = unpacker.GetTotalBytes();

    std::cout << "Index loaded successfully!\n";
    std::cout << "  Total files: " << totalFiles << "\n";
    std::cout << "  Total size: " << (totalBytes / 1024 / 1024) << " MB\n\n";

    // 加载路径映射文件 (如果指定)
    bool mappingLoaded = false;
    if (!mappingFile.empty()) {
        std::cout << "Loading path mapping file...\n";
        int mapResult = unpacker.LoadPathMapping(mappingFile);
        if (mapResult == SLJFP::LJFP_SUCCESS) {
            mappingLoaded = true;
            std::cout << "  Loaded " << unpacker.GetPathMappingCount() << " path mappings\n\n";
        } else {
            std::cout << "  Warning: Failed to load mapping file (error: " << mapResult << ")\n";
            std::cout << "  Will fallback to header-based inference after phase-1 unpack\n\n";
        }
    }

    if (enableSourceTemplateSeed) {
        std::set<uint32_t> targetCrcSet;
        const std::vector<SLJFP::FileInfo>& files = unpacker.GetFileList();
        for (size_t i = 0; i < files.size(); ++i) {
            targetCrcSet.insert(files[i].m_PathFileNameCRC32);
        }

        std::cout << "Running source-template seed enrichment...\n";
        const SourceTemplateSeedEnrichmentResult sourceTemplateResult =
            RunSourceTemplateSeedEnrichmentForCli(inputDir,
                                                 outputDir,
                                                 mappingFile,
                                                 targetCrcSet,
                                                 sourceScanRoots,
                                                 sourceMapConfigBins);
        if (sourceTemplateResult.promoted) {
            const std::string promotedMappingPath =
                JoinPath(sourceTemplateResult.promoteDir, "path_mapping.ljpm");
            int promotedLoadResult = unpacker.LoadPathMapping(promotedMappingPath);
            if (promotedLoadResult == SLJFP::LJFP_SUCCESS) {
                mappingLoaded = true;
                mappingFile = promotedMappingPath;
                std::cout << "  Source-template mapping promoted: " << promotedMappingPath << "\n";
                std::cout << "  Direct hits: " << sourceTemplateResult.directHits
                          << ", new hits: " << sourceTemplateResult.newHits
                          << ", coverage: " << sourceTemplateResult.existingHits
                          << " -> " << sourceTemplateResult.mergedHits << "\n\n";
            } else {
                std::cout << "  Warning: promoted source-template mapping load failed (error: "
                          << promotedLoadResult << ")\n\n";
            }
        } else if (!sourceTemplateResult.message.empty()) {
            std::cout << "  Source-template seed result: " << sourceTemplateResult.message << "\n\n";
        }
    }

    // 配置解包选项
    const bool enableTwoPhaseRestore = true;
    SLJFP::UnpackOptions options;
    options.verifyCRC32 = verifyCRC32;
    options.overwriteExisting = overwrite;
    options.createDirectories = true;
    options.detectFileType = detectFileType;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = enableTwoPhaseRestore;
    options.restorePathStructureAfterUnpack = enableTwoPhaseRestore;
    options.strictRestoreValidation = strictRestore;
    options.relocateRootNumericResiduals = relocateRootResiduals;
    options.writeReviewAliases = writeReviewAliases;
    options.decryptMode = decryptMode;
    options.decryptKey = resolvedDecryptKey;

    // 执行解包
    std::cout << "Starting unpacking...\n";
    result = unpacker.UnpackAll(inputDir, outputDir, options);

    std::cout << "\n\n";

    // 显示结果
    if (result == SLJFP::LJFP_SUCCESS || result == SLJFP::LJFP_ERROR_PARTIAL_FAILURE) {
        const uint32_t processed = unpacker.GetProcessedFiles();
        const uint32_t failed = unpacker.GetFailedFiles();
        const uint64_t processedBytes = unpacker.GetProcessedBytes();

        std::cout << "========================================\n";
        if (result == SLJFP::LJFP_SUCCESS) {
            std::cout << "  Unpacking completed!\n";
        } else {
            std::cout << "  Unpacking partially completed!\n";
        }
        std::cout << "========================================\n";
        std::cout << "Success: " << processed << " files\n";
        std::cout << "Failed: " << failed << " files\n";
        std::cout << "Processed data: " << (processedBytes / 1024 / 1024) << " MB\n";
        std::cout << "========================================\n";

        if (failed > 0) {
            std::cout << "\nWarning: " << failed << " files failed to unpack\n";
            std::cout << "Please check log file ljfp-unpack.log for details\n";

            SLJFP::WorkflowReviewExportService::Scope exportScope;
            exportScope.label = L"all_failed";
            const SLJFP::WorkflowReviewExportService::Result exportResult =
                SLJFP::WorkflowReviewExportService::ExportFailedItems(&unpacker, outputDir, &exportScope);
            if (exportResult.ok()) {
                std::cout << "Failed item TSV: " << exportResult.tsvPath << "\n";
                std::cout << "Failed item JSON: " << exportResult.jsonPath << "\n";
            }

            std::string firstFailedDecryptPath;
            if (ExportFirstFailedDecryptDiagnosticJson(unpacker, outputDir, &firstFailedDecryptPath)) {
                std::cout << "First failed decrypt JSON: " << firstFailedDecryptPath << "\n";
            }
        }
    } else {
        std::cerr << "========================================\n";
        std::cerr << "  Unpacking failed!\n";
        std::cerr << "========================================\n";
        std::cerr << "Error code: " << result << "\n";
        std::cerr << "Please check log file ljfp-unpack.log for details\n";
        std::cerr << "========================================\n";
    }

    // 关闭日志
    SLJFP::Logger::Instance().Shutdown();
    CloseLogger();

    return (result == SLJFP::LJFP_SUCCESS && unpacker.GetFailedFiles() == 0) ? 0 : 1;
}
#endif

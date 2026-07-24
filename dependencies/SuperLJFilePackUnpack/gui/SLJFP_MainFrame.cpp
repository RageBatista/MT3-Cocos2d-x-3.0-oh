/**
 * @file SLJFP_MainFrame.cpp
 * @brief SuperLJFilePackUnpack GUI 主窗口实现
 * @version 1.0
 * @date 2025-01-03
 */

#include "SLJFP_MainFrame.h"
#include "SLJFP_ProgressDialog.h"
#include "../include/SLJFP_AndroidBinaryKey.h"
#include "../include/SLJFP_FileTypeDetector.h"
#include "../include/SLJFP_LibsWrapper.h"
#include "../include/SLJFP_ErrorCodes.h"
#include "../include/SLJFP_Logger.h"
#include "../include/SLJFP_WorkflowReviewExportService.h"

#include <wx/artprov.h>
#include <wx/filename.h>
#include <wx/image.h>
#include <wx/mstream.h>
#include <wx/stdpaths.h>
#include <wx/tokenzr.h>
#include <wx/utils.h>
#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdlib>
#include <fstream>
#include <map>
#include <set>
#include <sstream>
#include <vector>

namespace SLJFP {

namespace {

class ResourceTreeFilterData : public wxTreeItemData {
public:
    ResourceTreeFilterData(WorkflowSessionController::TreeFilterMode filterMode,
                           uint32_t filterPackIndex = 0)
        : mode(filterMode)
        , packIndex(filterPackIndex) {
    }

    WorkflowSessionController::TreeFilterMode mode;
    uint32_t packIndex;
};

uint32_t PathMappingCRC32Adapter(uint32_t crc, const void* data, size_t len) {
    return SLJFP_crc32(crc,
                       reinterpret_cast<const unsigned char*>(data),
                       static_cast<unsigned int>(len));
}

std::string WxToNativePath(const wxString& value) {
#ifdef _WIN32
    wxScopedCharBuffer local = value.mb_str(wxConvLocal);
    if (local.data() != nullptr) {
        return std::string(local.data());
    }
#endif
    wxScopedCharBuffer utf8 = value.utf8_str();
    if (utf8.data() != nullptr) {
        return std::string(utf8.data());
    }
    return std::string();
}

wxString NativePathToWx(const std::string& value) {
#ifdef _WIN32
    return wxString(value.c_str(), wxConvLocal);
#else
    return wxString::FromUTF8(value.c_str());
#endif
}

wxString NormalizePathForCompare(const wxString& rawPath) {
    if (rawPath.IsEmpty()) {
        return rawPath;
    }
    wxFileName fileName(rawPath);
    fileName.Normalize(wxPATH_NORM_DOTS | wxPATH_NORM_ABSOLUTE);
    return fileName.GetFullPath();
}

wxString NormalizeDirectoryPath(const wxString& rawPath) {
    if (rawPath.IsEmpty()) {
        return wxEmptyString;
    }

    wxFileName dirName = wxFileName::DirName(rawPath);
    dirName.Normalize(wxPATH_NORM_DOTS | wxPATH_NORM_ABSOLUTE);
    return dirName.GetFullPath();
}

wxString GetParentDirectoryPath(const wxString& rawDir) {
    const wxString normalizedDir = NormalizeDirectoryPath(rawDir);
    if (normalizedDir.IsEmpty()) {
        return wxEmptyString;
    }

    wxFileName dirName = wxFileName::DirName(normalizedDir);
    if (dirName.GetDirCount() == 0) {
        return wxEmptyString;
    }

    dirName.RemoveLastDir();
    return dirName.GetFullPath();
}

bool SamePathIgnoreCase(const wxString& left, const wxString& right) {
    return NormalizePathForCompare(left).CmpNoCase(NormalizePathForCompare(right)) == 0;
}

void BuildStandardMappingArtifactPaths(const wxString& seedPath,
                                       wxString& outTextPath,
                                       wxString& outBinaryPath) {
    wxFileName seed(seedPath);
    wxString outputDir = seed.GetPath();
    if (outputDir.IsEmpty()) {
        outputDir = wxFileName::GetCwd();
    }
    outTextPath = wxFileName(outputDir, wxT("path_mapping.txt")).GetFullPath();
    outBinaryPath = wxFileName(outputDir, wxT("path_mapping.ljpm")).GetFullPath();
}

void AppendRuntimeTrace(const std::string& message) {
    wxString exePath = wxStandardPaths::Get().GetExecutablePath();
    wxFileName exeFile(exePath);
    wxString tracePath = exeFile.GetPathWithSep() + wxT("runtime_trace.log");

    std::ofstream out(std::string(tracePath.mb_str(wxConvLocal)).c_str(), std::ios::app);
    if (!out.is_open()) {
        return;
    }

    auto now = std::chrono::system_clock::now();
    std::time_t timeValue = std::chrono::system_clock::to_time_t(now);
    std::tm localTm;
#ifdef _WIN32
    localtime_s(&localTm, &timeValue);
#else
    localtime_r(&timeValue, &localTm);
#endif
    char ts[32] = {0};
    std::strftime(ts, sizeof(ts), "%Y-%m-%d %H:%M:%S", &localTm);
    out << "[" << ts << "] " << message << std::endl;
}

void WaitAndDeleteThread(UnpackThread*& thread) {
    if (thread == nullptr) {
        return;
    }
    thread->Wait();
    delete thread;
    thread = nullptr;
}

wxString FormatBytesForUi(uint64_t bytes) {
    const double kb = static_cast<double>(bytes) / 1024.0;
    const double mb = kb / 1024.0;
    const double gb = mb / 1024.0;

    if (gb >= 1.0) {
        return wxString::Format(wxT("%.2f GB"), gb);
    }
    if (mb >= 1.0) {
        return wxString::Format(wxT("%.2f MB"), mb);
    }
    if (kb >= 1.0) {
        return wxString::Format(wxT("%.2f KB"), kb);
    }
    return wxString::Format(wxT("%llu B"), bytes);
}

wxString FormatRateForUi(uint32_t rateBasis) {
    return wxString::Format(wxT("%u.%02u%%"), rateBasis / 100, rateBasis % 100);
}

wxString FormatCRC32ForUi(uint32_t value) {
    return wxString::Format(wxT("0x%08X"), value);
}

wxString DescribeCompressType(uint32_t compressType) {
    return (compressType > 0) ? wxT("已压缩") : wxT("原始");
}

wxString DescribeEncryptType(uint32_t codeType) {
    return (codeType > 0) ? wxT("已加密") : wxT("未加密");
}

wxString DescribeDecryptModeForUi(DecryptMode mode) {
    switch (mode) {
        case DecryptMode::LJFilePackSMS4:
            return wxT("LJFilePack-SMS4");
        case DecryptMode::ApkClientObf:
            return wxT("APK-ClientObf");
        case DecryptMode::Auto:
        default:
            return wxT("Auto");
    }
}

wxString FormatErrorCodeForUi(int code) {
    if (code == 0) {
        return wxT("无错误");
    }
    return wxString::Format(wxT("%d (%ls)"),
                            code,
                            GetErrorMessage(static_cast<ErrorCode>(code)));
}

wxString BuildDecryptDiagnosticSummary(const DecryptFailureDiagnostic& diagnostic) {
    wxString summary = wxString::Format(wxT("文件 #%u，输入 %s，最终错误 %s"),
                                        diagnostic.fileIndex,
                                        FormatBytesForUi(diagnostic.inputSize).c_str(),
                                        FormatErrorCodeForUi(diagnostic.failureCode).c_str());
    if (!diagnostic.candidates.empty()) {
        const DecryptProbeRecord& candidate = diagnostic.candidates.back();
        summary += wxString::Format(wxT("；最近候选 %s / %s / CRC %s"),
                                    wxString::FromUTF8(candidate.candidateId.c_str()).c_str(),
                                    DescribeDecryptModeForUi(candidate.mode).c_str(),
                                    candidate.crcChecked
                                        ? (candidate.crcMatched ? wxT("命中") : wxT("失配"))
                                        : wxT("未校验"));
    }
    return summary;
}

std::string NormalizeMappingCandidatePath(const std::string& rawPath) {
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

struct NearbyMappingSeedCandidate {
    wxString filePath;
    uint32_t hitCount;
    uint32_t mappingCount;
    uint32_t lowConfidenceCount;
    uint32_t cleanEntryCount;
    uint32_t semanticEntryCount;
    uint32_t hitRateBasis;
    uint32_t cleanRateBasis;
    uint32_t semanticRateBasis;
    uint32_t avgPathQualityBasis;
    uint32_t qualityScoreBasis;
    bool binaryFormat;
    bool isolated;
    std::string isolationReason;
    std::map<uint32_t, std::string> normalizedMappings;
};

struct MappingSeedQualityMetrics {
    uint32_t hitCount;
    uint32_t lowConfidenceCount;
    uint32_t cleanEntryCount;
    uint32_t semanticEntryCount;
    uint32_t hitRateBasis;
    uint32_t cleanRateBasis;
    uint32_t semanticRateBasis;
    uint32_t avgPathQualityBasis;
    uint32_t qualityScoreBasis;

    MappingSeedQualityMetrics()
        : hitCount(0)
        , lowConfidenceCount(0)
        , cleanEntryCount(0)
        , semanticEntryCount(0)
        , hitRateBasis(0)
        , cleanRateBasis(0)
        , semanticRateBasis(0)
        , avgPathQualityBasis(0)
        , qualityScoreBasis(0) {
    }
};

std::string CanonicalizeMappingStoragePath(const std::string& rawPath);
bool IsLowConfidenceMappingPathInCrcRepoMode(const std::string& rawPath);
std::string GetFileExtensionLower(const std::string& path);
bool ShouldAnalyzeFileContentForMapping(const std::string& relativePath, uint64_t fileSize);

std::string GetTopLevelPathSegment(const std::string& rawPath) {
    const std::string normalized = NormalizeMappingCandidatePath(rawPath);
    if (normalized.empty()) {
        return std::string();
    }
    const size_t slash = normalized.find('/');
    if (slash == std::string::npos) {
        return normalized;
    }
    return normalized.substr(0, slash);
}

bool IsKnownSemanticTopLevelSegment(const std::string& segment) {
    static const char* const kKnownSegments[] = {
        "cfg", "config", "data", "effect", "font", "image",
        "layout", "map", "model", "music", "script", "sound",
        "spine", "table", "texture", "ui"
    };
    for (size_t i = 0; i < sizeof(kKnownSegments) / sizeof(kKnownSegments[0]); ++i) {
        if (segment == kKnownSegments[i]) {
            return true;
        }
    }
    return false;
}

bool IsKnownResourceExtension(const std::string& extension) {
    static const char* const kKnownExtensions[] = {
        ".lua", ".xml", ".json", ".cfg", ".ini", ".txt",
        ".layout", ".imageset", ".font", ".scheme", ".looknfeel",
        ".atlas", ".ani", ".png", ".dds", ".tga", ".jpg", ".jpeg",
        ".webp", ".bmp", ".gif", ".ico", ".ogg", ".wav", ".mp3",
        ".bin", ".dat", ".csv", ".plist", ".act", ".lmx", ".mrmp", ".rmp"
    };
    for (size_t i = 0; i < sizeof(kKnownExtensions) / sizeof(kKnownExtensions[0]); ++i) {
        if (extension == kKnownExtensions[i]) {
            return true;
        }
    }
    return false;
}

uint32_t EstimateMappingPathQualityBasis(const std::string& rawPath) {
    const std::string normalized = CanonicalizeMappingStoragePath(rawPath);
    if (normalized.empty()) {
        return 0;
    }
    if (IsLowConfidenceMappingPathInCrcRepoMode(normalized)) {
        return 0;
    }

    uint32_t score = 3500;
    const bool hasDirectory = (normalized.find('/') != std::string::npos);
    if (hasDirectory) {
        score += 2000;
    }

    const std::string topLevel = GetTopLevelPathSegment(normalized);
    if (IsKnownSemanticTopLevelSegment(topLevel)) {
        score += 2000;
    }

    const std::string ext = GetFileExtensionLower(normalized);
    if (IsKnownResourceExtension(ext)) {
        score += 1500;
    }

    const size_t slash = normalized.find_last_of('/');
    const std::string leaf = (slash == std::string::npos)
        ? normalized
        : normalized.substr(slash + 1);
    if (leaf.size() >= 4) {
        score += 500;
    }
    if (normalized.find('/', slash == std::string::npos ? 0 : slash + 1) != std::string::npos) {
        score += 500;
    }

    return std::min<uint32_t>(10000u, score);
}

MappingSeedQualityMetrics EvaluateMappingSeedQuality(
    const std::map<uint32_t, std::string>& normalizedMappings,
    const std::set<uint32_t>& targetCrcSet) {
    MappingSeedQualityMetrics metrics;
    uint64_t qualityScoreSum = 0;

    for (std::map<uint32_t, std::string>::const_iterator it = normalizedMappings.begin();
         it != normalizedMappings.end();
         ++it) {
        const std::string& path = it->second;
        if (!targetCrcSet.empty() && targetCrcSet.find(it->first) != targetCrcSet.end()) {
            ++metrics.hitCount;
        }

        const bool lowConfidence = IsLowConfidenceMappingPathInCrcRepoMode(path);
        if (lowConfidence) {
            ++metrics.lowConfidenceCount;
            continue;
        }

        ++metrics.cleanEntryCount;
        const std::string topLevel = GetTopLevelPathSegment(path);
        if (IsKnownSemanticTopLevelSegment(topLevel)) {
            ++metrics.semanticEntryCount;
        }
        qualityScoreSum += EstimateMappingPathQualityBasis(path);
    }

    const uint32_t mappingCount = static_cast<uint32_t>(normalizedMappings.size());
    const uint32_t targetCount = static_cast<uint32_t>(targetCrcSet.size());
    if (mappingCount > 0) {
        metrics.cleanRateBasis =
            static_cast<uint32_t>((static_cast<uint64_t>(metrics.cleanEntryCount) * 10000ULL) / mappingCount);
        metrics.avgPathQualityBasis =
            static_cast<uint32_t>(qualityScoreSum / std::max<uint32_t>(metrics.cleanEntryCount, 1u));
    }
    if (metrics.cleanEntryCount > 0) {
        metrics.semanticRateBasis =
            static_cast<uint32_t>((static_cast<uint64_t>(metrics.semanticEntryCount) * 10000ULL) /
                                  metrics.cleanEntryCount);
    }
    if (targetCount > 0) {
        metrics.hitRateBasis =
            static_cast<uint32_t>((static_cast<uint64_t>(metrics.hitCount) * 10000ULL) / targetCount);
    }

    metrics.qualityScoreBasis =
        static_cast<uint32_t>((static_cast<uint64_t>(metrics.hitRateBasis) * 55ULL +
                               static_cast<uint64_t>(metrics.cleanRateBasis) * 20ULL +
                               static_cast<uint64_t>(metrics.semanticRateBasis) * 10ULL +
                               static_cast<uint64_t>(metrics.avgPathQualityBasis) * 15ULL) / 100ULL);
    return metrics;
}

bool ShouldIsolateMappingSeed(const MappingSeedQualityMetrics& metrics,
                              uint32_t mappingCount,
                              uint32_t bestHitRateBasis,
                              uint32_t bestQualityScoreBasis,
                              std::string& outReason) {
    std::vector<std::string> reasons;
    if (mappingCount == 0 || metrics.hitCount == 0) {
        reasons.push_back("no_overlap");
    }
    if (mappingCount > 0 && metrics.lowConfidenceCount * 100u >= mappingCount * 15u) {
        reasons.push_back("low_confidence_ratio");
    }
    if (metrics.cleanEntryCount == 0) {
        reasons.push_back("no_clean_entries");
    }
    if (bestHitRateBasis >= 500 && metrics.hitRateBasis < 100) {
        reasons.push_back("weak_hit_rate");
    }
    if (bestQualityScoreBasis >= 600 &&
        static_cast<uint64_t>(metrics.qualityScoreBasis) * 100ULL <
            static_cast<uint64_t>(bestQualityScoreBasis) * 35ULL) {
        reasons.push_back("score_far_below_best");
    }

    if (reasons.empty()) {
        outReason.clear();
        return false;
    }

    std::ostringstream oss;
    for (size_t i = 0; i < reasons.size(); ++i) {
        if (i > 0) {
            oss << ',';
        }
        oss << reasons[i];
    }
    outReason = oss.str();
    return true;
}

bool LooksMostlyPrintableTextPayload(const unsigned char* data, size_t size) {
    if (data == NULL || size == 0) {
        return false;
    }

    const size_t limit = std::min<size_t>(size, 256u);
    size_t printableCount = 0;
    for (size_t i = 0; i < limit; ++i) {
        const unsigned char c = data[i];
        if (c == '\r' || c == '\n' || c == '\t' || (c >= 32 && c <= 126)) {
            ++printableCount;
        }
    }
    return printableCount * 100u >= limit * 80u;
}

bool ShouldAnalyzeDecodedContentForMapping(const std::string& logicalPath,
                                           const std::vector<unsigned char>& decodedBytes) {
    if (decodedBytes.empty()) {
        return false;
    }
    if (ShouldAnalyzeFileContentForMapping(logicalPath, decodedBytes.size())) {
        return true;
    }

    const unsigned char* data = decodedBytes.empty() ? NULL : &decodedBytes[0];
    const std::string detectedExt = FileTypeDetector::DetectExtension(data, decodedBytes.size());
    if (FileTypeDetector::IsTextFile(detectedExt)) {
        return true;
    }
    if (detectedExt == ".atlas" || detectedExt == ".xml" || detectedExt == ".json" ||
        detectedExt == ".lua" || detectedExt == ".txt") {
        return true;
    }

    return LooksMostlyPrintableTextPayload(data, decodedBytes.size());
}

bool LoadNormalizedMappingSeed(const wxString& mappingPath,
                              std::map<uint32_t, std::string>& outMappings) {
    outMappings.clear();

    Unpacker seedUnpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    if (seedUnpacker.LoadPathMapping(WxToNativePath(mappingPath)) != LJFP_SUCCESS) {
        return false;
    }

    const std::map<uint32_t, std::string>& mappingTable = seedUnpacker.GetPathMappingTable();
    for (std::map<uint32_t, std::string>::const_iterator it = mappingTable.begin();
         it != mappingTable.end();
         ++it) {
        const std::string normalizedPath = CanonicalizeMappingStoragePath(it->second);
        if (normalizedPath.empty()) {
            continue;
        }
        outMappings[it->first] = normalizedPath;
    }

    return !outMappings.empty();
}

struct ManifestSeedEnrichmentResult {
    bool attempted;
    bool executed;
    bool promoted;
    bool failed;
    long exitCode;
    uint32_t existingHits;
    uint32_t mergedHits;
    uint32_t hitGain;
    uint32_t newHits;
    uint32_t mappingConflicts;
    uint32_t filteredEntries;
    uint32_t mergedEntries;
    wxString manifestRoot;
    wxString pythonLauncher;
    wxString scriptPath;
    wxString reportDir;
    wxString promoteDir;
    wxString summaryPath;
    wxString message;

    ManifestSeedEnrichmentResult()
        : attempted(false)
        , executed(false)
        , promoted(false)
        , failed(false)
        , exitCode(-1)
        , existingHits(0)
        , mergedHits(0)
        , hitGain(0)
        , newHits(0)
        , mappingConflicts(0)
        , filteredEntries(0)
        , mergedEntries(0) {
    }
};

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
    wxArrayString scanRoots;
    wxArrayString mapConfigInputs;
    wxString pythonLauncher;
    wxString scriptPath;
    wxString reportDir;
    wxString promoteDir;
    wxString summaryPath;
    wxString targetCrcFile;
    wxString message;

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

void PushUniqueDirectoryCandidate(wxArrayString& outCandidates, const wxString& rawPath) {
    const wxString normalized = NormalizeDirectoryPath(rawPath);
    if (normalized.IsEmpty()) {
        return;
    }
    if (outCandidates.Index(normalized) == wxNOT_FOUND) {
        outCandidates.Add(normalized);
    }
}

wxString BuildDriveSiblingDirectory(const wxString& rawPath, const wxString& childName) {
    const wxString normalized = NormalizeDirectoryPath(rawPath);
    if (normalized.Length() >= 2 && normalized[1] == wxT(':')) {
        return normalized.Mid(0, 2) + wxFILE_SEP_PATH + childName;
    }
    return wxEmptyString;
}

bool HasDefaultManifestSeedFiles(const wxString& rootDir) {
    if (rootDir.IsEmpty()) {
        return false;
    }

    static const wxChar* const kRequiredFiles[] = {
        wxT("main.txt"),
        wxT("imagesets.txt"),
        wxT("lua-layout.txt"),
        wxT("文件解密.txt"),
        wxT("model.txt")
    };

    for (size_t i = 0; i < sizeof(kRequiredFiles) / sizeof(kRequiredFiles[0]); ++i) {
        const wxString filePath = wxFileName(rootDir, kRequiredFiles[i]).GetFullPath();
        if (!wxFileExists(filePath)) {
            return false;
        }
    }

    return true;
}

wxString DetectManifestSeedRoot(const wxArrayString& referenceDirs) {
    wxArrayString candidates;
    for (size_t i = 0; i < referenceDirs.GetCount(); ++i) {
        const wxString normalized = NormalizeDirectoryPath(referenceDirs[i]);
        if (normalized.IsEmpty()) {
            continue;
        }

        PushUniqueDirectoryCandidate(candidates, normalized);

        const wxString parentDir = GetParentDirectoryPath(normalized);
        if (!parentDir.IsEmpty()) {
            PushUniqueDirectoryCandidate(candidates, parentDir);

            const wxString grandParent = GetParentDirectoryPath(parentDir);
            if (!grandParent.IsEmpty()) {
                PushUniqueDirectoryCandidate(candidates, grandParent);
            }
        }

        const wxString driveSibling = BuildDriveSiblingDirectory(normalized, wxT("jiebao"));
        if (!driveSibling.IsEmpty()) {
            PushUniqueDirectoryCandidate(candidates, driveSibling);
        }
    }

    PushUniqueDirectoryCandidate(candidates, wxFileName::GetCwd());
    const wxString cwdSibling = BuildDriveSiblingDirectory(wxFileName::GetCwd(), wxT("jiebao"));
    if (!cwdSibling.IsEmpty()) {
        PushUniqueDirectoryCandidate(candidates, cwdSibling);
    }
    PushUniqueDirectoryCandidate(candidates, wxT("E:\\jiebao"));

    for (size_t i = 0; i < candidates.GetCount(); ++i) {
        if (HasDefaultManifestSeedFiles(candidates[i])) {
            return candidates[i];
        }
    }

    return wxEmptyString;
}

wxString FindManifestSeedPipelineScript() {
    wxArrayString candidates;

    PushUniqueDirectoryCandidate(candidates, wxFileName::GetCwd());

    const wxString cwdScript =
        wxFileName(wxFileName::GetCwd(),
                   wxT("dependencies\\SuperLJFilePackUnpack\\tools\\manifest_seed_pipeline.py"))
            .GetFullPath();
    if (wxFileExists(cwdScript)) {
        return cwdScript;
    }

    wxFileName exeFile(wxStandardPaths::Get().GetExecutablePath());
    wxString currentDir = exeFile.GetPath();
    for (int depth = 0; depth < 8 && !currentDir.IsEmpty(); ++depth) {
        const wxString candidate =
            wxFileName(currentDir, wxT("tools\\manifest_seed_pipeline.py")).GetFullPath();
        if (wxFileExists(candidate)) {
            return candidate;
        }

        const wxString parentDir = GetParentDirectoryPath(currentDir);
        if (parentDir.IsEmpty() || SamePathIgnoreCase(parentDir, currentDir)) {
            break;
        }
        currentDir = parentDir;
    }

    return wxEmptyString;
}

wxString FindSourceTemplateSeedPipelineScript() {
    wxArrayString candidates;

    PushUniqueDirectoryCandidate(candidates, wxFileName::GetCwd());

    const wxString cwdScript =
        wxFileName(wxFileName::GetCwd(),
                   wxT("dependencies\\SuperLJFilePackUnpack\\tools\\source_template_seed_pipeline.py"))
            .GetFullPath();
    if (wxFileExists(cwdScript)) {
        return cwdScript;
    }

    wxFileName exeFile(wxStandardPaths::Get().GetExecutablePath());
    wxString currentDir = exeFile.GetPath();
    for (int depth = 0; depth < 8 && !currentDir.IsEmpty(); ++depth) {
        const wxString candidate =
            wxFileName(currentDir, wxT("tools\\source_template_seed_pipeline.py")).GetFullPath();
        if (wxFileExists(candidate)) {
            return candidate;
        }

        const wxString parentDir = GetParentDirectoryPath(currentDir);
        if (parentDir.IsEmpty() || SamePathIgnoreCase(parentDir, currentDir)) {
            break;
        }
        currentDir = parentDir;
    }

    return wxEmptyString;
}

bool CanExecuteHiddenSync(const wxString& command) {
    wxArrayString output;
    wxArrayString errors;
    return wxExecute(command, output, errors, wxEXEC_SYNC | wxEXEC_HIDE_CONSOLE) == 0;
}

wxString DetectPythonLauncher() {
    if (CanExecuteHiddenSync(wxT("python --version"))) {
        return wxT("python");
    }
    if (CanExecuteHiddenSync(wxT("py -3 --version"))) {
        return wxT("py -3");
    }
    return wxEmptyString;
}

bool TryExtractJsonUnsignedField(const std::string& jsonText,
                                 const std::string& key,
                                 uint32_t& outValue) {
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
    outValue = static_cast<uint32_t>(std::strtoul(jsonText.substr(pos, end - pos).c_str(), NULL, 10));
    return true;
}

bool TryExtractJsonStringField(const std::string& jsonText,
                               const std::string& key,
                               wxString& outValue) {
    const std::string token = "\"" + key + "\"";
    size_t pos = jsonText.find(token);
    if (pos == std::string::npos) {
        return false;
    }
    pos = jsonText.find(':', pos + token.size());
    if (pos == std::string::npos) {
        return false;
    }
    pos = jsonText.find('"', pos);
    if (pos == std::string::npos) {
        return false;
    }
    ++pos;

    std::string unescaped;
    bool escaping = false;
    for (; pos < jsonText.size(); ++pos) {
        const char ch = jsonText[pos];
        if (escaping) {
            switch (ch) {
                case '\\':
                case '"':
                case '/':
                    unescaped.push_back(ch);
                    break;
                case 'n':
                    unescaped.push_back('\n');
                    break;
                case 'r':
                    unescaped.push_back('\r');
                    break;
                case 't':
                    unescaped.push_back('\t');
                    break;
                default:
                    unescaped.push_back(ch);
                    break;
            }
            escaping = false;
            continue;
        }

        if (ch == '\\') {
            escaping = true;
            continue;
        }

        if (ch == '"') {
            outValue = wxString::FromUTF8(unescaped.c_str());
            return true;
        }

        unescaped.push_back(ch);
    }

    return false;
}

bool ReadFileAsUtf8String(const wxString& path, std::string& outText) {
    outText.clear();

    std::ifstream in(WxToNativePath(path).c_str(), std::ios::in | std::ios::binary);
    if (!in.is_open()) {
        return false;
    }

    std::ostringstream buffer;
    buffer << in.rdbuf();
    outText = buffer.str();
    return !outText.empty();
}

bool CopyFileWithOverwrite(const wxString& sourcePath, const wxString& targetPath) {
    if (sourcePath.IsEmpty() || targetPath.IsEmpty()) {
        return false;
    }
    if (SamePathIgnoreCase(sourcePath, targetPath)) {
        return true;
    }

    wxFileName targetFile(targetPath);
    if (!targetFile.DirExists()) {
        targetFile.Mkdir(wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL);
    }

    return wxCopyFile(sourcePath, targetPath, true);
}

void DetectSourceTemplateScanRoots(const wxArrayString& referenceDirs,
                                   const wxString& inputDir,
                                   wxArrayString& outRoots) {
    outRoots.Clear();

    auto addRoot = [&outRoots](const wxString& rawDir) {
        const wxString normalized = NormalizeDirectoryPath(rawDir);
        if (normalized.IsEmpty() || !wxDirExists(normalized)) {
            return;
        }
        if (outRoots.Index(normalized) == wxNOT_FOUND) {
            outRoots.Add(normalized);
        }
    };

    auto addChildIfExists = [&addRoot](const wxString& baseDir, const wxString& childName) {
        const wxString normalizedBase = NormalizeDirectoryPath(baseDir);
        if (normalizedBase.IsEmpty()) {
            return;
        }
        wxFileName child(normalizedBase, wxEmptyString);
        child.AppendDir(childName);
        addRoot(child.GetFullPath());
    };

    wxArrayString seeds;
    for (size_t i = 0; i < referenceDirs.GetCount(); ++i) {
        PushUniqueDirectoryCandidate(seeds, referenceDirs[i]);
    }
    if (!inputDir.IsEmpty()) {
        PushUniqueDirectoryCandidate(seeds, inputDir);
    }
    PushUniqueDirectoryCandidate(seeds, wxFileName::GetCwd());

    for (size_t i = 0; i < seeds.GetCount(); ++i) {
        wxString current = seeds[i];
        for (int depth = 0; depth < 6 && !current.IsEmpty(); ++depth) {
            addChildIfExists(current, wxT("client"));
            addChildIfExists(current, wxT("auto"));

            wxFileName currentDir(current, wxEmptyString);
            const wxString leaf = currentDir.GetDirs().IsEmpty()
                ? currentDir.GetName()
                : currentDir.GetDirs().Last();
            if (leaf.CmpNoCase(wxT("client")) == 0 || leaf.CmpNoCase(wxT("auto")) == 0) {
                addRoot(current);
            }

            const wxString parent = GetParentDirectoryPath(current);
            if (parent.IsEmpty() || SamePathIgnoreCase(parent, current)) {
                break;
            }
            current = parent;
        }
    }
}

void DetectSourceTemplateMapConfigInputs(const wxArrayString& referenceDirs,
                                         wxArrayString& outPaths) {
    outPaths.Clear();

    auto addConfigIfExists = [&outPaths](const wxString& rawPath) {
        if (rawPath.IsEmpty()) {
            return;
        }
        wxFileName fileName(rawPath);
        fileName.Normalize(wxPATH_NORM_DOTS | wxPATH_NORM_ABSOLUTE);
        const wxString normalized = fileName.GetFullPath();
        if (!wxFileExists(normalized)) {
            return;
        }
        if (outPaths.Index(normalized) == wxNOT_FOUND) {
            outPaths.Add(normalized);
        }
    };

    for (size_t i = 0; i < referenceDirs.GetCount(); ++i) {
        const wxString normalizedDir = NormalizeDirectoryPath(referenceDirs[i]);
        if (normalizedDir.IsEmpty()) {
            continue;
        }
        addConfigIfExists(wxFileName(normalizedDir, wxT("table\\bintable\\map.cmapconfig.bin")).GetFullPath());
        addConfigIfExists(wxFileName(normalizedDir, wxT("res\\table\\bintable\\map.cmapconfig.bin")).GetFullPath());
        addConfigIfExists(wxFileName(normalizedDir, wxT("assets\\res\\table\\bintable\\map.cmapconfig.bin")).GetFullPath());
    }
}

bool WriteTargetCrcSeedFile(const wxString& outputPath, const std::set<uint32_t>& targetCrcSet) {
    if (outputPath.IsEmpty()) {
        return false;
    }

    wxFileName outputFile(outputPath);
    if (!outputFile.DirExists()) {
        outputFile.Mkdir(wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL);
    }

    std::ofstream out(WxToNativePath(outputPath).c_str(), std::ios::out | std::ios::binary | std::ios::trunc);
    if (!out.is_open()) {
        return false;
    }

    out << "# target PathFileNameCRC32 list\n";
    for (std::set<uint32_t>::const_iterator it = targetCrcSet.begin();
         it != targetCrcSet.end();
         ++it) {
        out << *it << "\n";
    }
    return out.good();
}

ManifestSeedEnrichmentResult RunManifestSeedEnrichment(const wxArrayString& referenceDirs,
                                                       const wxString& standardTextPath,
                                                       const wxString& standardBinaryPath,
                                                       const wxString& customOutputPath,
                                                       bool customOutputIsBinary) {
    ManifestSeedEnrichmentResult result;
    result.attempted = true;

    result.manifestRoot = DetectManifestSeedRoot(referenceDirs);
    if (result.manifestRoot.IsEmpty()) {
        result.message = wxT("未检测到可用的 txt manifest 根目录，跳过补种。");
        return result;
    }

    result.scriptPath = FindManifestSeedPipelineScript();
    if (result.scriptPath.IsEmpty()) {
        result.message = wxT("未找到 manifest_seed_pipeline.py，跳过补种。");
        return result;
    }

    result.pythonLauncher = DetectPythonLauncher();
    if (result.pythonLauncher.IsEmpty()) {
        result.message = wxT("未检测到可用的 Python 运行时，跳过补种。");
        return result;
    }

    wxFileName standardBinaryFile(standardBinaryPath);
    const wxString standardDir = standardBinaryFile.GetPath();
    result.reportDir = wxFileName(standardDir, wxT("manifest_seed_reports_gui")).GetFullPath();
    result.promoteDir = wxFileName(standardDir, wxT("manifest_seed_promoted_gui")).GetFullPath();
    result.summaryPath = wxFileName(result.reportDir, wxT("manifest_summary.json")).GetFullPath();

    wxFileName::Mkdir(result.reportDir, wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL);
    wxFileName::Mkdir(result.promoteDir, wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL);

    const wxString command = wxString::Format(
        wxT("%s \"%s\" --res-dir \"%s\" --mapping \"%s\" --output-dir \"%s\" ")
        wxT("--jiebao-root \"%s\" --promote-dir \"%s\""),
        result.pythonLauncher.c_str(),
        result.scriptPath.c_str(),
        NormalizeDirectoryPath(referenceDirs.IsEmpty() ? wxEmptyString : referenceDirs[0]).c_str(),
        standardBinaryPath.c_str(),
        result.reportDir.c_str(),
        result.manifestRoot.c_str(),
        result.promoteDir.c_str());

    wxArrayString output;
    wxArrayString errors;
    result.exitCode = wxExecute(command, output, errors, wxEXEC_SYNC | wxEXEC_HIDE_CONSOLE);
    result.executed = true;
    if (result.exitCode != 0) {
        result.failed = true;
        result.message = wxString::Format(wxT("txt manifest 补种执行失败（退出码 %ld）"), result.exitCode);
        return result;
    }

    std::string summaryJson;
    if (!ReadFileAsUtf8String(result.summaryPath, summaryJson)) {
        result.failed = true;
        result.message = wxT("txt manifest 补种已执行，但未找到 summary.json。");
        return result;
    }

    if (!TryExtractJsonUnsignedField(summaryJson, "existing_hits", result.existingHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "merged_hits", result.mergedHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "hit_gain", result.hitGain) ||
        !TryExtractJsonUnsignedField(summaryJson, "new_hits", result.newHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "mapping_conflicts", result.mappingConflicts) ||
        !TryExtractJsonUnsignedField(summaryJson, "filtered_entries", result.filteredEntries) ||
        !TryExtractJsonUnsignedField(summaryJson, "merged_entries", result.mergedEntries)) {
        result.failed = true;
        result.message = wxT("txt manifest 补种 summary.json 字段不完整。");
        return result;
    }

    wxString promoteDirFromSummary;
    if (TryExtractJsonStringField(summaryJson, "promote_dir", promoteDirFromSummary) &&
        !promoteDirFromSummary.IsEmpty()) {
        result.promoteDir = promoteDirFromSummary;
    }

    const wxString promotedTextPath = wxFileName(result.promoteDir, wxT("path_mapping.txt")).GetFullPath();
    const wxString promotedBinaryPath = wxFileName(result.promoteDir, wxT("path_mapping.ljpm")).GetFullPath();
    if (!wxFileExists(promotedTextPath) || !wxFileExists(promotedBinaryPath)) {
        result.failed = true;
        result.message = wxT("txt manifest 补种未产出标准 path_mapping.txt/.ljpm。");
        return result;
    }

    if (result.hitGain == 0 || result.mergedHits <= result.existingHits) {
        result.message = wxString::Format(wxT("txt manifest 补种已执行，但没有覆盖率增益（%u -> %u）。"),
                                          result.existingHits,
                                          result.mergedHits);
        return result;
    }

    if (!CopyFileWithOverwrite(promotedTextPath, standardTextPath) ||
        !CopyFileWithOverwrite(promotedBinaryPath, standardBinaryPath)) {
        result.failed = true;
        result.message = wxT("txt manifest 补种已执行，但提升后的标准映射替换失败。");
        return result;
    }

    if (!customOutputPath.IsEmpty() &&
        !SamePathIgnoreCase(customOutputPath, standardTextPath) &&
        !SamePathIgnoreCase(customOutputPath, standardBinaryPath)) {
        const wxString promotedCustomPath = customOutputIsBinary ? promotedBinaryPath : promotedTextPath;
        if (!CopyFileWithOverwrite(promotedCustomPath, customOutputPath)) {
            result.failed = true;
            result.message = wxT("txt manifest 补种已执行，但自定义导出副本更新失败。");
            return result;
        }
    }

    result.promoted = true;
    result.message = wxString::Format(
        wxT("已合并 txt manifest 补种：新增 %u 条，高置信命中 %u -> %u。"),
        result.newHits,
        result.existingHits,
        result.mergedHits);
    return result;
}

SourceTemplateSeedEnrichmentResult RunSourceTemplateSeedEnrichment(const wxArrayString& referenceDirs,
                                                                   const wxString& inputDir,
                                                                   const std::set<uint32_t>& targetCrcSet,
                                                                   const wxString& standardTextPath,
                                                                   const wxString& standardBinaryPath,
                                                                   const wxString& customOutputPath,
                                                                   bool customOutputIsBinary) {
    SourceTemplateSeedEnrichmentResult result;
    result.attempted = true;

    if (targetCrcSet.empty()) {
        result.message = wxT("当前索引未提供可用的 PathFileNameCRC32，跳过源码模板补种。");
        return result;
    }

    result.scriptPath = FindSourceTemplateSeedPipelineScript();
    if (result.scriptPath.IsEmpty()) {
        result.message = wxT("未找到 source_template_seed_pipeline.py，跳过源码模板补种。");
        return result;
    }

    result.pythonLauncher = DetectPythonLauncher();
    if (result.pythonLauncher.IsEmpty()) {
        result.message = wxT("未检测到可用的 Python 运行时，跳过源码模板补种。");
        return result;
    }

    DetectSourceTemplateScanRoots(referenceDirs, inputDir, result.scanRoots);
    if (result.scanRoots.IsEmpty()) {
        result.message = wxT("未检测到可用的客户端源码/配置语料根目录，跳过源码模板补种。");
        return result;
    }
    DetectSourceTemplateMapConfigInputs(referenceDirs, result.mapConfigInputs);

    wxFileName standardBinaryFile(standardBinaryPath);
    const wxString standardDir = standardBinaryFile.GetPath();
    result.reportDir = wxFileName(standardDir, wxT("source_template_reports_gui")).GetFullPath();
    result.promoteDir = wxFileName(standardDir, wxT("source_template_promoted_gui")).GetFullPath();
    result.summaryPath = wxFileName(result.reportDir, wxT("source_template_summary.json")).GetFullPath();
    result.targetCrcFile = wxFileName(result.reportDir, wxT("target_crc32.txt")).GetFullPath();

    wxFileName::Mkdir(result.reportDir, wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL);
    wxFileName::Mkdir(result.promoteDir, wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL);

    if (!WriteTargetCrcSeedFile(result.targetCrcFile, targetCrcSet)) {
        result.failed = true;
        result.message = wxT("未能写出 target_crc32.txt，跳过源码模板补种。");
        return result;
    }

    wxString command = wxString::Format(
        wxT("%s \"%s\" --target-crc-file \"%s\" --mapping \"%s\" --output-dir \"%s\" --promote-dir \"%s\""),
        result.pythonLauncher.c_str(),
        result.scriptPath.c_str(),
        result.targetCrcFile.c_str(),
        standardBinaryPath.c_str(),
        result.reportDir.c_str(),
        result.promoteDir.c_str());

    for (size_t i = 0; i < result.scanRoots.GetCount(); ++i) {
        command += wxString::Format(wxT(" --scan-root \"%s\""), result.scanRoots[i].c_str());
    }
    for (size_t i = 0; i < result.mapConfigInputs.GetCount(); ++i) {
        command += wxString::Format(wxT(" --map-config-bin \"%s\""), result.mapConfigInputs[i].c_str());
    }

    wxArrayString output;
    wxArrayString errors;
    result.exitCode = wxExecute(command, output, errors, wxEXEC_SYNC | wxEXEC_HIDE_CONSOLE);
    result.executed = true;
    if (result.exitCode != 0) {
        result.failed = true;
        result.message = wxString::Format(wxT("源码模板补种执行失败（退出码 %ld）"), result.exitCode);
        return result;
    }

    std::string summaryJson;
    if (!ReadFileAsUtf8String(result.summaryPath, summaryJson)) {
        result.failed = true;
        result.message = wxT("源码模板补种已执行，但未找到 source_template_summary.json。");
        return result;
    }

    if (!TryExtractJsonUnsignedField(summaryJson, "direct_hits", result.directHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "existing_hits", result.existingHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "merged_hits", result.mergedHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "hit_gain", result.hitGain) ||
        !TryExtractJsonUnsignedField(summaryJson, "new_hits", result.newHits) ||
        !TryExtractJsonUnsignedField(summaryJson, "mapping_conflicts", result.mappingConflicts) ||
        !TryExtractJsonUnsignedField(summaryJson, "seed_conflicts", result.seedConflicts)) {
        result.failed = true;
        result.message = wxT("源码模板补种 summary.json 字段不完整。");
        return result;
    }

    const wxString promotedTextPath = wxFileName(result.promoteDir, wxT("path_mapping.txt")).GetFullPath();
    const wxString promotedBinaryPath = wxFileName(result.promoteDir, wxT("path_mapping.ljpm")).GetFullPath();
    if (!wxFileExists(promotedTextPath) || !wxFileExists(promotedBinaryPath)) {
        result.failed = true;
        result.message = wxT("源码模板补种未产出标准 path_mapping.txt/.ljpm。");
        return result;
    }

    if (result.hitGain == 0 || result.mergedHits <= result.existingHits) {
        result.message = wxString::Format(wxT("源码模板补种已执行，但没有覆盖率增益（%u -> %u）。"),
                                          result.existingHits,
                                          result.mergedHits);
        return result;
    }

    if (!CopyFileWithOverwrite(promotedTextPath, standardTextPath) ||
        !CopyFileWithOverwrite(promotedBinaryPath, standardBinaryPath)) {
        result.failed = true;
        result.message = wxT("源码模板补种已执行，但提升后的标准映射替换失败。");
        return result;
    }

    if (!customOutputPath.IsEmpty() &&
        !SamePathIgnoreCase(customOutputPath, standardTextPath) &&
        !SamePathIgnoreCase(customOutputPath, standardBinaryPath)) {
        const wxString promotedCustomPath = customOutputIsBinary ? promotedBinaryPath : promotedTextPath;
        if (!CopyFileWithOverwrite(promotedCustomPath, customOutputPath)) {
            result.failed = true;
            result.message = wxT("源码模板补种已执行，但自定义导出副本更新失败。");
            return result;
        }
    }

    result.promoted = true;
    result.message = wxString::Format(
        wxT("已合并源码模板补种：直接命中 %u 条，新增 %u 条，高置信命中 %u -> %u。"),
        result.directHits,
        result.newHits,
        result.existingHits,
        result.mergedHits);
    return result;
}

void PushUniqueCandidatePath(std::vector<std::string>& outCandidates,
                             const std::string& rawPath) {
    const std::string normalized = NormalizeMappingCandidatePath(rawPath);
    if (normalized.empty()) {
        return;
    }
    if (std::find(outCandidates.begin(), outCandidates.end(), normalized) != outCandidates.end()) {
        return;
    }
    outCandidates.push_back(normalized);
}

void AppendPathVariantWithPrefix(std::vector<std::string>& outCandidates,
                                 const std::string& basePath,
                                 const std::string& prefix) {
    if (prefix.empty()) {
        PushUniqueCandidatePath(outCandidates, basePath);
        return;
    }

    const std::string normalizedPrefix = NormalizeMappingCandidatePath(prefix);
    if (normalizedPrefix.empty()) {
        PushUniqueCandidatePath(outCandidates, basePath);
        return;
    }

    const std::string normalizedBase = NormalizeMappingCandidatePath(basePath);
    if (normalizedBase.empty()) {
        return;
    }

    if (normalizedBase == normalizedPrefix ||
        (normalizedBase.size() > normalizedPrefix.size() &&
         normalizedBase.compare(0, normalizedPrefix.size(), normalizedPrefix) == 0 &&
         normalizedBase[normalizedPrefix.size()] == '/')) {
        PushUniqueCandidatePath(outCandidates, normalizedBase);
        return;
    }

    PushUniqueCandidatePath(outCandidates, normalizedPrefix + "/" + normalizedBase);
}

void BuildMappingPathVariants(const std::string& relativePath,
                              std::vector<std::string>& outVariants) {
    outVariants.clear();

    const std::string normalized = NormalizeMappingCandidatePath(relativePath);
    if (normalized.empty()) {
        return;
    }

    static const char* const kPrefixCandidates[] = {
        "",
        "res",
        "resource/res",
        "assets",
        "assets/res",
        "client/resource/res"
    };

    PushUniqueCandidatePath(outVariants, normalized);
    for (size_t i = 0; i < sizeof(kPrefixCandidates) / sizeof(kPrefixCandidates[0]); ++i) {
        AppendPathVariantWithPrefix(outVariants, normalized, kPrefixCandidates[i]);
    }

    static const char* const kStripPrefixes[] = {
        "client/resource/res/",
        "resource/res/",
        "assets/res/",
        "assets/",
        "res/"
    };

    for (size_t i = 0; i < sizeof(kStripPrefixes) / sizeof(kStripPrefixes[0]); ++i) {
        const std::string stripPrefix = kStripPrefixes[i];
        if (normalized.size() > stripPrefix.size() &&
            normalized.compare(0, stripPrefix.size(), stripPrefix) == 0) {
            PushUniqueCandidatePath(outVariants, normalized.substr(stripPrefix.size()));
        }
    }
}

std::string GetFileExtensionLower(const std::string& path) {
    const std::string normalized = NormalizeMappingCandidatePath(path);
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

std::string GetDirectoryPart(const std::string& path) {
    const std::string normalized = NormalizeMappingCandidatePath(path);
    const size_t slash = normalized.find_last_of('/');
    if (slash == std::string::npos) {
        return std::string();
    }
    return normalized.substr(0, slash);
}

std::string JoinNormalizedPath(const std::string& left, const std::string& right) {
    const std::string normalizedLeft = NormalizeMappingCandidatePath(left);
    const std::string normalizedRight = NormalizeMappingCandidatePath(right);
    if (normalizedLeft.empty()) {
        return normalizedRight;
    }
    if (normalizedRight.empty()) {
        return normalizedLeft;
    }
    return normalizedLeft + "/" + normalizedRight;
}

std::string JoinNativePath(const std::string& left, const std::string& right) {
    if (left.empty()) {
        return right;
    }
    if (right.empty()) {
        return left;
    }

    std::string result = left;
    const char last = result[result.size() - 1];
    if (last != '/' && last != '\\') {
        result.push_back('/');
    }
    result += right;
    return result;
}

bool IsLikelyPathTokenChar(unsigned char ch) {
    if (std::isalnum(ch)) {
        return true;
    }
    switch (ch) {
        case '/':
        case '\\':
        case '_':
        case '-':
        case '.':
        case ':':
        case '$':
        case '@':
        case '+':
            return true;
        default:
            return false;
    }
}

void PushPathTokenCandidate(std::vector<std::string>& outTokens,
                            const std::string& rawToken) {
    if (rawToken.empty()) {
        return;
    }

    size_t begin = 0;
    size_t end = rawToken.size();
    while (begin < end &&
           (rawToken[begin] == '"' || rawToken[begin] == '\'' ||
            rawToken[begin] == '`' || rawToken[begin] == '(' ||
            rawToken[begin] == '[' || rawToken[begin] == '{' ||
            rawToken[begin] == '<')) {
        ++begin;
    }
    while (end > begin &&
           (rawToken[end - 1] == '"' || rawToken[end - 1] == '\'' ||
            rawToken[end - 1] == '`' || rawToken[end - 1] == ')' ||
            rawToken[end - 1] == ']' || rawToken[end - 1] == '}' ||
            rawToken[end - 1] == '>' || rawToken[end - 1] == ',' ||
            rawToken[end - 1] == ';')) {
        --end;
    }
    if (end <= begin) {
        return;
    }

    std::string token = rawToken.substr(begin, end - begin);
    if (token.size() < 4 || token.size() > 320) {
        return;
    }

    const std::string lower = NormalizeMappingCandidatePath(token);
    if (lower.empty()) {
        return;
    }

    if (lower.find("://") != std::string::npos) {
        return;
    }

    bool containsPathHint = (lower.find('/') != std::string::npos) ||
                            (lower.find('\\') != std::string::npos);
    const std::string ext = GetFileExtensionLower(lower);
    static const char* const kSupportedExts[] = {
        ".lua", ".xml", ".json", ".bin", ".ani", ".atlas",
        ".png", ".dds", ".tga", ".jpg", ".jpeg", ".webp",
        ".layout", ".imageset", ".font", ".txt", ".cfg", ".ini",
        ".eff", ".inf", ".set", ".dat", ".plist", ".csv"
    };
    bool extMatched = false;
    for (size_t i = 0; i < sizeof(kSupportedExts) / sizeof(kSupportedExts[0]); ++i) {
        if (ext == kSupportedExts[i]) {
            extMatched = true;
            break;
        }
    }

    if (!containsPathHint && !extMatched) {
        if (token.find('.') == std::string::npos) {
            return;
        }

        bool moduleLike = true;
        for (size_t i = 0; i < token.size(); ++i) {
            const unsigned char c = static_cast<unsigned char>(token[i]);
            if (!(std::isalnum(c) || c == '_' || c == '.')) {
                moduleLike = false;
                break;
            }
        }
        if (!moduleLike) {
            return;
        }
    }

    if (std::find(outTokens.begin(), outTokens.end(), lower) == outTokens.end()) {
        outTokens.push_back(lower);
    }
}

void ExtractPathLikeTokensFromBytes(const std::vector<unsigned char>& data,
                                    std::vector<std::string>& outTokens,
                                    size_t maxTokens = 800) {
    outTokens.clear();
    if (data.empty() || maxTokens == 0) {
        return;
    }

    std::string current;
    current.reserve(128);
    for (size_t i = 0; i < data.size(); ++i) {
        const unsigned char ch = data[i];
        if (IsLikelyPathTokenChar(ch)) {
            if (current.size() < 512) {
                current.push_back(static_cast<char>(ch));
            }
            continue;
        }

        if (!current.empty()) {
            PushPathTokenCandidate(outTokens, current);
            current.clear();
            if (outTokens.size() >= maxTokens) {
                return;
            }
        }
    }

    if (!current.empty() && outTokens.size() < maxTokens) {
        PushPathTokenCandidate(outTokens, current);
    }
}

bool ReadFileSampleBytes(const std::string& absolutePath,
                         size_t maxBytes,
                         std::vector<unsigned char>& outBytes,
                         uint64_t& outFileSize,
                         size_t& outReadBytes) {
    outBytes.clear();
    outFileSize = 0;
    outReadBytes = 0;
    if (absolutePath.empty() || maxBytes == 0) {
        return false;
    }

    std::ifstream in(absolutePath.c_str(), std::ios::binary);
    if (!in.is_open()) {
        return false;
    }

    in.seekg(0, std::ios::end);
    const std::streamoff end = in.tellg();
    if (end <= 0) {
        return false;
    }

    outFileSize = static_cast<uint64_t>(end);
    const size_t readBytes = static_cast<size_t>(
        std::min<uint64_t>(outFileSize, static_cast<uint64_t>(maxBytes)));
    if (readBytes == 0) {
        return false;
    }

    outBytes.resize(readBytes);
    in.seekg(0, std::ios::beg);
    in.read(reinterpret_cast<char*>(&outBytes[0]), static_cast<std::streamsize>(readBytes));
    const std::streamsize got = in.gcount();
    if (got <= 0) {
        outBytes.clear();
        return false;
    }

    outReadBytes = static_cast<size_t>(got);
    if (outReadBytes < outBytes.size()) {
        outBytes.resize(outReadBytes);
    }
    return !outBytes.empty();
}

bool ShouldAnalyzeFileContentForMapping(const std::string& relativePath, uint64_t fileSize) {
    if (fileSize == 0) {
        return false;
    }

    const std::string ext = GetFileExtensionLower(relativePath);
    static const char* const kAlwaysAnalyzeExts[] = {
        ".lua", ".xml", ".json", ".cfg", ".ini", ".txt", ".layout",
        ".imageset", ".font", ".scheme", ".looknfeel", ".atlas", ".ani"
    };
    for (size_t i = 0; i < sizeof(kAlwaysAnalyzeExts) / sizeof(kAlwaysAnalyzeExts[0]); ++i) {
        if (ext == kAlwaysAnalyzeExts[i]) {
            return true;
        }
    }

    if (ext == ".bin" || ext == ".dat") {
        return fileSize <= (2ULL * 1024ULL * 1024ULL);
    }

    if (ext.empty()) {
        return fileSize <= (768ULL * 1024ULL);
    }

    return false;
}

void ExpandExtractedTokenToCandidates(const std::string& token,
                                      const std::string& entryDirectory,
                                      std::vector<std::string>& outCandidates) {
    outCandidates.clear();
    if (token.empty()) {
        return;
    }

    std::string normalized = NormalizeMappingCandidatePath(token);
    while (normalized.size() > 2 &&
           normalized[0] == '.' &&
           normalized[1] == '/') {
        normalized = normalized.substr(2);
    }

    if (normalized.empty()) {
        return;
    }

    if (normalized.size() > 2 &&
        std::isalpha(static_cast<unsigned char>(normalized[0])) &&
        normalized[1] == ':') {
        const size_t resPos = normalized.find("res/");
        if (resPos != std::string::npos) {
            normalized = normalized.substr(resPos);
        }
    }

    PushUniqueCandidatePath(outCandidates, normalized);

    if (normalized.compare(0, 4, "res/") == 0) {
        PushUniqueCandidatePath(outCandidates, normalized.substr(4));
    } else if (normalized.compare(0, 11, "assets/res/") == 0) {
        PushUniqueCandidatePath(outCandidates, normalized.substr(11));
    } else if (normalized.compare(0, 13, "resource/res/") == 0) {
        PushUniqueCandidatePath(outCandidates, normalized.substr(13));
    } else if (normalized.compare(0, 20, "client/resource/res/") == 0) {
        PushUniqueCandidatePath(outCandidates, normalized.substr(20));
    }

    const bool hasSlash = (normalized.find('/') != std::string::npos);
    const std::string ext = GetFileExtensionLower(normalized);
    if (!hasSlash && !ext.empty() && !entryDirectory.empty()) {
        PushUniqueCandidatePath(outCandidates, JoinNormalizedPath(entryDirectory, normalized));
    }

    if (!hasSlash && ext.empty() && normalized.find('.') != std::string::npos) {
        bool moduleLike = true;
        for (size_t i = 0; i < normalized.size(); ++i) {
            const unsigned char c = static_cast<unsigned char>(normalized[i]);
            if (!(std::isalnum(c) || c == '_' || c == '.')) {
                moduleLike = false;
                break;
            }
        }
        if (moduleLike) {
            std::string modulePath = normalized;
            for (size_t i = 0; i < modulePath.size(); ++i) {
                if (modulePath[i] == '.') {
                    modulePath[i] = '/';
                }
            }
            PushUniqueCandidatePath(outCandidates, "script/" + modulePath + ".lua");
            PushUniqueCandidatePath(outCandidates, modulePath + ".lua");
        }
    }
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

bool IsNumericRootLikePath(const std::string& rawPath) {
    std::string normalized = NormalizeMappingCandidatePath(rawPath);
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
    return IsDigitsOnlyString(stem);
}

bool ContainsPathSegment(const std::string& rawPath, const std::string& segment) {
    if (segment.empty()) {
        return false;
    }

    const std::string path = NormalizeMappingCandidatePath(rawPath);
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

std::string CanonicalizeMappingStoragePath(const std::string& rawPath) {
    return PathMappingGenerator::CanonicalizeStoragePath(rawPath);
}

bool IsLowConfidenceMappingPathInCrcRepoMode(const std::string& rawPath) {
    return PathMappingGenerator::IsLowConfidenceCrcRepositoryPath(rawPath);
}

bool IsPreviewableImageOutputPath(const std::string& rawPath) {
    const std::string ext = GetFileExtensionLower(rawPath);
    static const char* const kPreviewImageExts[] = {
        ".png", ".dds", ".tga", ".jpg", ".jpeg", ".webp",
        ".bmp", ".gif", ".ico"
    };
    for (size_t i = 0; i < sizeof(kPreviewImageExts) / sizeof(kPreviewImageExts[0]); ++i) {
        if (ext == kPreviewImageExts[i]) {
            return true;
        }
    }
    return false;
}

void ApplyStepPresentation(wxStaticText* label,
                           const wxString& title,
                           const wxString& summary,
                           const WorkflowSessionController::StepStatus& status) {
    if (label == nullptr) {
        return;
    }

    wxString text = title;
    if (!summary.IsEmpty()) {
        text += wxT("\n") + summary;
    }
    label->SetLabel(text);

    wxFont font = label->GetFont();
    font.SetWeight(status.active || status.complete ? wxFONTWEIGHT_BOLD : wxFONTWEIGHT_NORMAL);
    label->SetFont(font);

    if (status.active) {
        label->SetForegroundColour(wxColour(18, 92, 165));
    } else if (status.complete) {
        label->SetForegroundColour(wxColour(30, 110, 55));
    } else {
        label->SetForegroundColour(wxColour(110, 110, 110));
    }
}

} // namespace

// ============================================================================
// 自定义事件定义
// ============================================================================
wxDEFINE_EVENT(wxEVT_UNPACK_PROGRESS, wxThreadEvent);
wxDEFINE_EVENT(wxEVT_UNPACK_COMPLETE, wxThreadEvent);

// ============================================================================
// 事件表
// ============================================================================
wxBEGIN_EVENT_TABLE(MainFrame, wxFrame)
    // 菜单事件
    EVT_MENU(ID_OPEN_INDEX, MainFrame::OnOpenIndex)
    EVT_MENU(ID_OPEN_DIR, MainFrame::OnOpenDir)
    EVT_MENU(ID_UNPACK_ALL, MainFrame::OnUnpackAll)
    EVT_MENU(ID_UNPACK_SELECTED, MainFrame::OnUnpackSelected)
    EVT_MENU(ID_STOP_UNPACK, MainFrame::OnStopUnpack)
    EVT_MENU(ID_SET_OUTPUT_DIR, MainFrame::OnSetOutputDir)
    EVT_MENU(ID_LOAD_MAPPING, MainFrame::OnLoadMapping)
    EVT_MENU(ID_GENERATE_MAPPING, MainFrame::OnGenerateMapping)
    EVT_MENU(ID_LOAD_MAPPING_HISTORY, MainFrame::OnLoadMappingHistory)
    EVT_MENU(ID_OPTIONS, MainFrame::OnOptions)
    EVT_MENU(ID_ABOUT, MainFrame::OnAbout)
    EVT_MENU(wxID_EXIT, MainFrame::OnExit)
    EVT_CHOICE(ID_PRESET_CHANGED, MainFrame::OnPresetChanged)

    // 列表事件
    EVT_LIST_ITEM_SELECTED(ID_FILE_LIST, MainFrame::OnFileListSelected)
    EVT_LIST_ITEM_ACTIVATED(ID_FILE_LIST, MainFrame::OnFileListActivated)
    EVT_LIST_ITEM_SELECTED(ID_RESULT_ISSUE_LIST, MainFrame::OnResultIssueSelected)
    EVT_LIST_ITEM_ACTIVATED(ID_RESULT_ISSUE_LIST, MainFrame::OnResultIssueActivated)

    // 树事件
    EVT_TREE_SEL_CHANGED(ID_RESOURCE_TREE, MainFrame::OnTreeSelChanged)

    // 控件事件
    EVT_BUTTON(ID_LOAD_MAPPING_HISTORY, MainFrame::OnLoadMappingHistory)
    EVT_BUTTON(ID_QUICK_OPEN_DIR, MainFrame::OnQuickOpenDir)
    EVT_BUTTON(ID_QUICK_OPEN_INDEX, MainFrame::OnQuickOpenIndex)
    EVT_BUTTON(ID_QUICK_SET_OUTPUT, MainFrame::OnQuickSetOutput)
    EVT_BUTTON(ID_QUICK_LOAD_MAPPING, MainFrame::OnQuickLoadMapping)
    EVT_BUTTON(ID_QUICK_GENERATE_MAPPING, MainFrame::OnQuickGenerateMapping)
    EVT_BUTTON(ID_QUICK_UNPACK, MainFrame::OnQuickUnpack)
    EVT_BUTTON(ID_QUICK_TOGGLE_PAUSE, MainFrame::OnQuickTogglePause)
    EVT_BUTTON(ID_QUICK_STOP, MainFrame::OnQuickStop)
    EVT_BUTTON(ID_REVIEW_OPEN_OUTPUT, MainFrame::OnReviewOpenOutput)
    EVT_BUTTON(ID_REVIEW_LOCATE_ISSUE, MainFrame::OnReviewLocateIssue)
    EVT_BUTTON(ID_REVIEW_GENERATE_MAPPING, MainFrame::OnReviewGenerateMapping)
    EVT_BUTTON(ID_REVIEW_EXPORT_FAILURES, MainFrame::OnReviewExportFailures)
    EVT_BUTTON(ID_REVIEW_RERUN_ISSUE, MainFrame::OnReviewRerunIssue)
    EVT_BUTTON(ID_REVIEW_CLEAR_FILTER, MainFrame::OnReviewClearFilter)

    // 线程事件改为在构造函数中 Bind（自定义事件类型不应使用 EVT_THREAD 宏）
wxEND_EVENT_TABLE()

// ============================================================================
// 构造函数和析构函数
// ============================================================================
MainFrame::MainFrame(const wxString& title)
    : wxFrame(nullptr, wxID_ANY, title, wxDefaultPosition, wxSize(1200, 800))
    , m_unpackThread(nullptr)
    , m_progressDialog(nullptr)
    , m_isUnpacking(false)
    , m_hasLoadedIndex(false)
{
    AppendRuntimeTrace("MainFrame ctor entered");

    // 初始化图像处理器
    wxInitAllImageHandlers();

    // 初始化日志输出（默认写到程序目录）
    wxString exePath = wxStandardPaths::Get().GetExecutablePath();
    wxFileName exeFile(exePath);
    wxString logPath = exeFile.GetPathWithSep() + wxT("sljfp-gui.log");
    SLJFP::Logger::Instance().Initialize(std::wstring(logPath.wc_str()), SLJFP::LOG_INFO);
    SLJFP::Logger::Instance().SetConsoleOutput(false);
    SLJFP_LOG_INFO(L"GUI build marker: v1.0.1");
    SLJFP_LOG_INFO(L"Executable path: " + std::wstring(exePath.wc_str()));
    AppendRuntimeTrace("Logger initialized");

    // 绑定自定义线程事件（EVT_THREAD 只匹配 wxEVT_THREAD + 事件ID）
    Bind(wxEVT_UNPACK_PROGRESS, &MainFrame::OnUnpackProgress, this);
    Bind(wxEVT_UNPACK_COMPLETE, &MainFrame::OnUnpackComplete, this);

    // 创建解包器
    m_unpacker.reset(new Unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    ));

    // 创建界面
    CreateMenuBar();
    CreateToolBar();
    CreateStatusBar();
    CreateMainUI();

    // 加载配置
    LoadConfig();

    // 居中显示
    Centre();

    // 更新状态栏
    UpdateStatusBar();
    UpdateWorkflowStatus();
    AppendSessionLog(wxT("会话已初始化，等待加载源数据。"));
}

MainFrame::~MainFrame() {
    // 停止解包线程
    if (m_unpackThread) {
        if (m_unpackThread->IsRunning()) {
            m_unpacker->Stop();
        }
        WaitAndDeleteThread(m_unpackThread);
    }

    // 保存配置
    SaveConfig();

}

// ============================================================================
// 界面创建
// ============================================================================
void MainFrame::CreateMenuBar() {
    m_menuBar = new wxMenuBar();

    // 文件菜单
    wxMenu* fileMenu = new wxMenu();
    fileMenu->Append(ID_OPEN_INDEX, wxT("打开索引文件(&O)...\tCtrl+O"), wxT("打开 .ljpi 或 .ljzip 索引文件"));
    fileMenu->Append(ID_OPEN_DIR, wxT("打开目录(&D)...\tCtrl+D"), wxT("打开包含资源包的目录"));
    fileMenu->AppendSeparator();
    fileMenu->Append(ID_SET_OUTPUT_DIR, wxT("设置输出目录(&S)..."), wxT("设置解包文件的输出目录"));
    fileMenu->Append(ID_LOAD_MAPPING, wxT("加载路径映射(&M)..."), wxT("加载路径映射表以恢复原始文件名"));
    fileMenu->Append(ID_GENERATE_MAPPING, wxT("生成路径映射(&G)..."), wxT("从资源目录生成路径映射表"));
    fileMenu->Append(ID_LOAD_MAPPING_HISTORY, wxT("加载历史映射(&R)..."), wxT("从历史记录中快速加载映射"));
    fileMenu->AppendSeparator();
    fileMenu->Append(wxID_EXIT, wxT("退出(&X)\tAlt+F4"), wxT("退出程序"));
    m_menuBar->Append(fileMenu, wxT("文件(&F)"));

    // 操作菜单
    wxMenu* actionMenu = new wxMenu();
    actionMenu->Append(ID_UNPACK_ALL, wxT("解包全部(&A)\tCtrl+U"), wxT("解包所有文件"));
    actionMenu->Append(ID_UNPACK_SELECTED, wxT("解包选中(&E)\tCtrl+E"), wxT("解包选中的文件"));
    actionMenu->AppendSeparator();
    actionMenu->Append(ID_STOP_UNPACK, wxT("停止(&S)\tEsc"), wxT("停止当前解包操作"));
    m_menuBar->Append(actionMenu, wxT("操作(&A)"));

    // 设置菜单
    wxMenu* settingsMenu = new wxMenu();
    settingsMenu->Append(ID_OPTIONS, wxT("选项(&O)..."), wxT("程序设置"));
    m_menuBar->Append(settingsMenu, wxT("设置(&S)"));

    // 帮助菜单
    wxMenu* helpMenu = new wxMenu();
    helpMenu->Append(ID_ABOUT, wxT("关于(&A)..."), wxT("关于本程序"));
    m_menuBar->Append(helpMenu, wxT("帮助(&H)"));

    SetMenuBar(m_menuBar);
}

void MainFrame::CreateToolBar() {
    m_toolBar = wxFrame::CreateToolBar(wxTB_HORIZONTAL | wxTB_TEXT | wxTB_FLAT);
    m_toolBar->SetToolBitmapSize(wxSize(16, 16));

    // 源数据入口
    m_toolBar->AddTool(ID_OPEN_DIR, wxT("资源目录"),
                       wxArtProvider::GetBitmap(wxART_FOLDER_OPEN, wxART_TOOLBAR),
                       wxT("打开资源目录"));
    m_toolBar->AddTool(ID_OPEN_INDEX, wxT("索引"),
                       wxArtProvider::GetBitmap(wxART_NORMAL_FILE, wxART_TOOLBAR),
                       wxT("打开索引文件"));
    m_toolBar->AddSeparator();

    // 映射与输出入口
    m_toolBar->AddTool(ID_SET_OUTPUT_DIR, wxT("输出目录"),
                       wxArtProvider::GetBitmap(wxART_FOLDER, wxART_TOOLBAR),
                       wxT("设置输出目录"));
    m_toolBar->AddTool(ID_LOAD_MAPPING, wxT("加载映射"),
                       wxArtProvider::GetBitmap(wxART_LIST_VIEW, wxART_TOOLBAR),
                       wxT("加载路径映射"));
    m_toolBar->AddTool(ID_GENERATE_MAPPING, wxT("生成映射"),
                       wxArtProvider::GetBitmap(wxART_NEW_DIR, wxART_TOOLBAR),
                       wxT("生成路径映射"));
    m_toolBar->AddSeparator();

    // 执行入口
    m_toolBar->AddTool(ID_UNPACK_ALL, wxT("解包全部"),
                       wxArtProvider::GetBitmap(wxART_EXECUTABLE_FILE, wxART_TOOLBAR),
                       wxT("解包所有文件"));
    m_toolBar->AddTool(ID_UNPACK_SELECTED, wxT("解包选中"),
                       wxArtProvider::GetBitmap(wxART_TICK_MARK, wxART_TOOLBAR),
                       wxT("仅解包当前选中文件"));
    m_toolBar->AddTool(ID_STOP_UNPACK, wxT("停止"),
                       wxArtProvider::GetBitmap(wxART_CROSS_MARK, wxART_TOOLBAR),
                       wxT("停止当前解包"));

    m_toolBar->EnableTool(ID_UNPACK_SELECTED, false);
    m_toolBar->EnableTool(ID_STOP_UNPACK, false);
    m_toolBar->Realize();
}

void MainFrame::CreateStatusBar() {
    m_statusBar = wxFrame::CreateStatusBar(3);
    int widths[] = { -2, -1, 150 };
    m_statusBar->SetStatusWidths(3, widths);

    m_statusBar->SetStatusText(wxT("就绪"), 0);
    m_statusBar->SetStatusText(wxT(""), 1);
    m_statusBar->SetStatusText(wxT("文件: 0"), 2);
}

void MainFrame::CreateMainUI() {
    wxPanel* mainPanel = new wxPanel(this);
    wxBoxSizer* mainSizer = new wxBoxSizer(wxVERTICAL);

    CreateWorkflowPanel(mainPanel, mainSizer);

    // 创建分割窗口
    m_splitter = new wxSplitterWindow(mainPanel, wxID_ANY,
                                       wxDefaultPosition, wxDefaultSize,
                                       wxSP_3D | wxSP_LIVE_UPDATE);

    // 左侧面板: 资源树
    wxPanel* leftPanel = new wxPanel(m_splitter);
    wxBoxSizer* leftSizer = new wxBoxSizer(wxVERTICAL);
    wxStaticBoxSizer* filterBox = new wxStaticBoxSizer(wxVERTICAL, leftPanel, wxT("资源筛选"));
    wxStaticText* treeHint = new wxStaticText(leftPanel, wxID_ANY,
                                              wxT("按资源源头、包索引或映射健康筛选右侧文件列表"));
    treeHint->SetForegroundColour(wxColour(96, 96, 96));
    filterBox->Add(treeHint, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 6);

    m_resourceTree = new wxTreeCtrl(leftPanel, ID_RESOURCE_TREE,
                                    wxDefaultPosition, wxDefaultSize,
                                    wxTR_DEFAULT_STYLE | wxTR_HIDE_ROOT);
    m_rootItem = m_resourceTree->AddRoot(wxT("资源"));
    filterBox->Add(m_resourceTree, 1, wxEXPAND | wxALL, 6);
    leftSizer->Add(filterBox, 1, wxEXPAND | wxALL, 5);
    leftPanel->SetSizer(leftSizer);

    // 右侧面板: 标签页 (文件列表 + 预览)
    wxPanel* rightPanel = new wxPanel(m_splitter);
    wxBoxSizer* rightSizer = new wxBoxSizer(wxVERTICAL);

    m_notebook = new wxNotebook(rightPanel, wxID_ANY);

    // 文件列表页
    wxPanel* listPage = new wxPanel(m_notebook);
    wxBoxSizer* listSizer = new wxBoxSizer(wxVERTICAL);

    m_fileList = new wxListCtrl(listPage, ID_FILE_LIST,
                                wxDefaultPosition, wxDefaultSize,
                                wxLC_REPORT | wxLC_SINGLE_SEL | wxLC_HRULES | wxLC_VRULES);

    // 添加列
    m_fileList->InsertColumn(0, wxT("文件名/CRC32"), wxLIST_FORMAT_LEFT, 200);
    m_fileList->InsertColumn(1, wxT("原始大小"), wxLIST_FORMAT_RIGHT, 100);
    m_fileList->InsertColumn(2, wxT("压缩大小"), wxLIST_FORMAT_RIGHT, 100);
    m_fileList->InsertColumn(3, wxT("压缩类型"), wxLIST_FORMAT_CENTER, 80);
    m_fileList->InsertColumn(4, wxT("加密类型"), wxLIST_FORMAT_CENTER, 80);
    m_fileList->InsertColumn(5, wxT("包索引"), wxLIST_FORMAT_CENTER, 80);

    listSizer->Add(m_fileList, 1, wxEXPAND | wxALL, 5);
    listPage->SetSizer(listSizer);
    m_notebook->AddPage(listPage, wxT("文件列表"));

    // 预览页
    m_previewPanel = new wxPanel(m_notebook);
    wxBoxSizer* previewSizer = new wxBoxSizer(wxVERTICAL);

    m_previewImage = new wxStaticBitmap(m_previewPanel, wxID_ANY, wxNullBitmap);
    m_previewImage->Hide();
    m_previewText = new wxTextCtrl(m_previewPanel, wxID_ANY, wxEmptyString,
                                   wxDefaultPosition, wxDefaultSize,
                                   wxTE_MULTILINE | wxTE_READONLY | wxHSCROLL);
    m_previewText->SetFont(wxFont(10, wxFONTFAMILY_TELETYPE, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL));

    previewSizer->Add(m_previewImage, 0, wxALIGN_CENTER_HORIZONTAL | wxALL, 5);
    previewSizer->Add(m_previewText, 1, wxEXPAND | wxALL, 5);
    m_previewPanel->SetSizer(previewSizer);
    m_notebook->AddPage(m_previewPanel, wxT("预览"));

    // 结果审阅页
    m_resultPanel = new wxPanel(m_notebook);
    wxBoxSizer* resultSizer = new wxBoxSizer(wxVERTICAL);
    wxBoxSizer* resultActionSizer = new wxBoxSizer(wxHORIZONTAL);

    m_resultOpenOutputButton = new wxButton(m_resultPanel, ID_REVIEW_OPEN_OUTPUT, wxT("打开输出目录"));
    m_resultLocateIssueButton = new wxButton(m_resultPanel, ID_REVIEW_LOCATE_ISSUE, wxT("定位问题文件"));
    m_resultGenerateMappingButton = new wxButton(m_resultPanel, ID_REVIEW_GENERATE_MAPPING, wxT("补全映射"));
    m_resultExportFailuresButton = new wxButton(m_resultPanel, ID_REVIEW_EXPORT_FAILURES, wxT("导出失败项"));
    m_resultRerunIssueButton = new wxButton(m_resultPanel, ID_REVIEW_RERUN_ISSUE, wxT("复跑问题组"));
    m_resultClearFilterButton = new wxButton(m_resultPanel, ID_REVIEW_CLEAR_FILTER, wxT("清除筛选"));

    resultActionSizer->Add(m_resultOpenOutputButton, 0, wxRIGHT, 6);
    resultActionSizer->Add(m_resultLocateIssueButton, 0, wxRIGHT, 6);
    resultActionSizer->Add(m_resultGenerateMappingButton, 0, wxRIGHT, 6);
    resultActionSizer->Add(m_resultExportFailuresButton, 0, wxRIGHT, 6);
    resultActionSizer->Add(m_resultRerunIssueButton, 0, wxRIGHT, 6);
    resultActionSizer->Add(m_resultClearFilterButton, 0);
    resultSizer->Add(resultActionSizer, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 5);

    m_resultSummaryText = new wxTextCtrl(m_resultPanel, wxID_ANY, wxEmptyString,
                                         wxDefaultPosition, wxSize(-1, 150),
                                         wxTE_MULTILINE | wxTE_READONLY | wxTE_RICH2);
    resultSizer->Add(m_resultSummaryText, 0, wxEXPAND | wxALL, 5);

    m_resultIssueList = new wxListCtrl(m_resultPanel, ID_RESULT_ISSUE_LIST,
                                       wxDefaultPosition, wxDefaultSize,
                                       wxLC_REPORT | wxLC_SINGLE_SEL | wxLC_HRULES | wxLC_VRULES);
    m_resultIssueList->InsertColumn(0, wxT("类别"), wxLIST_FORMAT_LEFT, 110);
    m_resultIssueList->InsertColumn(1, wxT("对象"), wxLIST_FORMAT_LEFT, 260);
    m_resultIssueList->InsertColumn(2, wxT("说明"), wxLIST_FORMAT_LEFT, 520);
    resultSizer->Add(m_resultIssueList, 1, wxEXPAND | wxALL, 5);

    m_resultPanel->SetSizer(resultSizer);
    m_notebook->AddPage(m_resultPanel, wxT("结果审阅"));

    // 配置页
    wxPanel* configPage = new wxPanel(m_notebook);
    CreateConfigPanel(configPage);
    m_notebook->AddPage(configPage, wxT("配置"));

    rightSizer->Add(m_notebook, 1, wxEXPAND);
    rightPanel->SetSizer(rightSizer);

    // 设置分割
    m_splitter->SplitVertically(leftPanel, rightPanel, 300);
    m_splitter->SetMinimumPaneSize(240);
    m_splitter->SetSashGravity(0.24);

    mainSizer->Add(m_splitter, 1, wxEXPAND);
    mainPanel->SetSizer(mainSizer);
    ClearPreviewPanel();
    RefreshResultReviewPanel();
}

void MainFrame::CreateWorkflowPanel(wxPanel* parent, wxSizer* parentSizer) {
    wxStaticBoxSizer* workflowBox = new wxStaticBoxSizer(wxVERTICAL, parent, wxT("工作流闭环"));

    wxFlexGridSizer* stepSizer = new wxFlexGridSizer(1, 4, 8, 8);
    stepSizer->AddGrowableCol(0, 1);
    stepSizer->AddGrowableCol(1, 1);
    stepSizer->AddGrowableCol(2, 1);
    stepSizer->AddGrowableCol(3, 1);
    auto addStepCard = [parent, stepSizer](wxStaticText*& outLabel,
                                           const wxString& title,
                                           const wxString& summary) {
        wxPanel* cardPanel = new wxPanel(parent, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxBORDER_SIMPLE);
        cardPanel->SetBackgroundColour(wxColour(252, 252, 252));

        wxBoxSizer* cardSizer = new wxBoxSizer(wxVERTICAL);
        outLabel = new wxStaticText(cardPanel, wxID_ANY, title + wxT("\n") + summary);
        outLabel->Wrap(280);
        cardSizer->Add(outLabel, 1, wxEXPAND | wxALL, 8);
        cardPanel->SetSizer(cardSizer);
        stepSizer->Add(cardPanel, 1, wxEXPAND);
    };

    addStepCard(m_stepIndexLabel, wxT("1. 源数据"), wxT("等待打开索引"));
    addStepCard(m_stepMappingLabel, wxT("2. 映射健康"), wxT("等待评估"));
    addStepCard(m_stepOutputLabel, wxT("3. 执行计划"), wxT("等待设置输出"));
    addStepCard(m_stepRunLabel, wxT("4. 结果审阅"), wxT("等待执行"));
    workflowBox->Add(stepSizer, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 8);

    wxStaticBoxSizer* sessionBox = new wxStaticBoxSizer(wxVERTICAL, parent, wxT("会话控制层"));
    wxFlexGridSizer* pathGrid = new wxFlexGridSizer(3, 3, 8, 8);
    pathGrid->AddGrowableCol(1, 1);

    m_quickOpenDirButton = new wxButton(parent, ID_QUICK_OPEN_DIR, wxT("打开资源目录"));
    m_quickOpenIndexButton = new wxButton(parent, ID_QUICK_OPEN_INDEX, wxT("打开索引"));
    m_quickLoadMappingButton = new wxButton(parent, ID_QUICK_LOAD_MAPPING, wxT("加载映射"));
    m_quickGenerateMappingButton = new wxButton(parent, ID_QUICK_GENERATE_MAPPING, wxT("生成映射"));
    m_quickOutputButton = new wxButton(parent, ID_QUICK_SET_OUTPUT, wxT("设置输出目录"));
    m_quickUnpackButton = new wxButton(parent, ID_QUICK_UNPACK, wxT("开始解包"));
    m_quickPauseButton = new wxButton(parent, ID_QUICK_TOGGLE_PAUSE, wxT("暂停"));
    m_quickStopButton = new wxButton(parent, ID_QUICK_STOP, wxT("停止"));

    auto addPathRow = [parent, pathGrid](const wxString& label,
                                         wxTextCtrl*& ctrl,
                                         wxSizer* actionSizer) {
        pathGrid->Add(new wxStaticText(parent, wxID_ANY, label), 0, wxALIGN_CENTER_VERTICAL | wxLEFT, 2);
        ctrl = new wxTextCtrl(parent, wxID_ANY, wxEmptyString,
                              wxDefaultPosition, wxDefaultSize,
                              wxTE_READONLY);
        ctrl->SetBackgroundColour(wxColour(248, 248, 248));
        pathGrid->Add(ctrl, 1, wxEXPAND);
        pathGrid->Add(actionSizer, 0, wxALIGN_CENTER_VERTICAL);
    };

    wxBoxSizer* sourceActionSizer = new wxBoxSizer(wxHORIZONTAL);
    sourceActionSizer->Add(m_quickOpenDirButton, 0, wxRIGHT, 6);
    sourceActionSizer->Add(m_quickOpenIndexButton, 0);

    wxBoxSizer* mappingActionSizer = new wxBoxSizer(wxHORIZONTAL);
    mappingActionSizer->Add(m_quickLoadMappingButton, 0, wxRIGHT, 6);
    mappingActionSizer->Add(m_quickGenerateMappingButton, 0);

    wxBoxSizer* outputActionSizer = new wxBoxSizer(wxHORIZONTAL);
    outputActionSizer->Add(m_quickOutputButton, 0, wxRIGHT, 6);
    outputActionSizer->Add(m_quickUnpackButton, 0, wxRIGHT, 6);
    outputActionSizer->Add(m_quickPauseButton, 0, wxRIGHT, 6);
    outputActionSizer->Add(m_quickStopButton, 0);

    addPathRow(wxT("源数据"), m_sessionSourcePathCtrl, sourceActionSizer);
    addPathRow(wxT("映射健康"), m_sessionMappingPathCtrl, mappingActionSizer);
    addPathRow(wxT("执行计划"), m_sessionOutputPathCtrl, outputActionSizer);
    sessionBox->Add(pathGrid, 0, wxEXPAND | wxALL, 6);

    wxBoxSizer* progressSizer = new wxBoxSizer(wxHORIZONTAL);
    m_sessionProgressGauge = new wxGauge(parent, wxID_ANY, 100,
                                         wxDefaultPosition, wxSize(-1, 22),
                                         wxGA_HORIZONTAL | wxGA_SMOOTH);
    m_sessionProgressLabel = new wxStaticText(parent, wxID_ANY, wxT("未开始"));
    progressSizer->Add(m_sessionProgressGauge, 1, wxALIGN_CENTER_VERTICAL | wxRIGHT, 10);
    progressSizer->Add(m_sessionProgressLabel, 0, wxALIGN_CENTER_VERTICAL);
    sessionBox->Add(progressSizer, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 6);

    wxBoxSizer* presetSizer = new wxBoxSizer(wxHORIZONTAL);
    presetSizer->Add(new wxStaticText(parent, wxID_ANY, wxT("工作流预设")), 0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 8);
    wxArrayString presetChoices;
    presetChoices.Add(wxT("标准闭环"));
    presetChoices.Add(wxT("快速审阅"));
    presetChoices.Add(wxT("长任务/大文件"));
    m_presetChoice = new wxChoice(parent, ID_PRESET_CHANGED, wxDefaultPosition, wxDefaultSize, presetChoices);
    m_presetChoice->SetSelection(0);
    presetSizer->Add(m_presetChoice, 0, wxRIGHT, 8);
    presetSizer->AddStretchSpacer();
    sessionBox->Add(presetSizer, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 6);
    workflowBox->Add(sessionBox, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 8);

    wxStaticBoxSizer* overviewBox = new wxStaticBoxSizer(wxVERTICAL, parent, wxT("状态概览"));
    m_overviewText = new wxTextCtrl(parent, wxID_ANY, wxEmptyString,
                                    wxDefaultPosition, wxSize(-1, 120),
                                    wxTE_MULTILINE | wxTE_READONLY | wxTE_RICH2);
    m_overviewText->SetFont(wxFont(9, wxFONTFAMILY_TELETYPE, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL));
    overviewBox->Add(m_overviewText, 1, wxEXPAND | wxALL, 6);
    workflowBox->Add(overviewBox, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 8);

    wxStaticBoxSizer* sessionLogBox = new wxStaticBoxSizer(wxVERTICAL, parent, wxT("会话日志"));
    m_sessionLogText = new wxTextCtrl(parent, wxID_ANY, wxEmptyString,
                                      wxDefaultPosition, wxSize(-1, 90),
                                      wxTE_MULTILINE | wxTE_READONLY | wxTE_RICH2);
    m_sessionLogText->SetFont(wxFont(9, wxFONTFAMILY_TELETYPE, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL));
    sessionLogBox->Add(m_sessionLogText, 1, wxEXPAND | wxALL, 6);
    workflowBox->Add(sessionLogBox, 0, wxEXPAND | wxALL, 8);

    parentSizer->Add(workflowBox, 0, wxEXPAND | wxALL, 8);
}

void MainFrame::CreateConfigPanel(wxPanel* parent) {
    wxBoxSizer* rootSizer = new wxBoxSizer(wxVERTICAL);

    wxStaticBoxSizer* pathBox = new wxStaticBoxSizer(wxVERTICAL, parent, wxT("路径与映射入口"));
    wxFlexGridSizer* pathGrid = new wxFlexGridSizer(4, 3, 8, 8);
    pathGrid->AddGrowableCol(1, 1);

    pathGrid->Add(new wxStaticText(parent, wxID_ANY, wxT("输入目录")), 0, wxALIGN_CENTER_VERTICAL);
    m_inputDirCtrl = new wxTextCtrl(parent, wxID_ANY, wxEmptyString,
                                    wxDefaultPosition, wxDefaultSize, wxTE_READONLY);
    m_inputDirCtrl->SetBackgroundColour(wxColour(248, 248, 248));
    pathGrid->Add(m_inputDirCtrl, 1, wxEXPAND);
    wxBoxSizer* inputActionSizer = new wxBoxSizer(wxHORIZONTAL);
    inputActionSizer->Add(new wxButton(parent, ID_QUICK_OPEN_DIR, wxT("打开资源目录")), 0, wxRIGHT, 6);
    inputActionSizer->Add(new wxButton(parent, ID_QUICK_OPEN_INDEX, wxT("打开索引")), 0);
    pathGrid->Add(inputActionSizer, 0, wxALIGN_CENTER_VERTICAL);

    pathGrid->Add(new wxStaticText(parent, wxID_ANY, wxT("输出目录")), 0, wxALIGN_CENTER_VERTICAL);
    m_outputDirCtrl = new wxTextCtrl(parent, wxID_ANY, wxT("./unpacked/"));
    pathGrid->Add(m_outputDirCtrl, 1, wxEXPAND);
    wxBoxSizer* outputActionSizer = new wxBoxSizer(wxHORIZONTAL);
    outputActionSizer->Add(new wxButton(parent, ID_QUICK_SET_OUTPUT, wxT("设置输出目录")), 0);
    pathGrid->Add(outputActionSizer, 0, wxALIGN_CENTER_VERTICAL);

    pathGrid->Add(new wxStaticText(parent, wxID_ANY, wxT("映射前缀")), 0, wxALIGN_CENTER_VERTICAL);
    m_mappingPrefixCtrl = new wxTextCtrl(parent, wxID_ANY, wxT("path_mapping,mapping"));
    m_mappingPrefixCtrl->SetHint(wxT("支持逗号/分号分隔，例如: path_mapping,mapping"));
    pathGrid->Add(m_mappingPrefixCtrl, 1, wxEXPAND);
    wxBoxSizer* mappingActionSizer = new wxBoxSizer(wxHORIZONTAL);
    mappingActionSizer->Add(new wxButton(parent, ID_QUICK_LOAD_MAPPING, wxT("加载映射")), 0, wxRIGHT, 6);
    mappingActionSizer->Add(new wxButton(parent, ID_QUICK_GENERATE_MAPPING, wxT("生成映射")), 0);
    pathGrid->Add(mappingActionSizer, 0, wxALIGN_CENTER_VERTICAL);

    pathGrid->Add(new wxStaticText(parent, wxID_ANY, wxT("映射历史")), 0, wxALIGN_CENTER_VERTICAL);
    m_mappingHistoryCombo = new wxComboBox(parent, wxID_ANY, wxEmptyString,
                                           wxDefaultPosition, wxDefaultSize,
                                           0, nullptr, wxCB_READONLY);
    pathGrid->Add(m_mappingHistoryCombo, 1, wxEXPAND);
    m_loadHistoryButton = new wxButton(parent, ID_LOAD_MAPPING_HISTORY, wxT("加载历史"));
    pathGrid->Add(m_loadHistoryButton, 0, wxALIGN_CENTER_VERTICAL);

    pathBox->Add(pathGrid, 0, wxEXPAND | wxALL, 8);
    rootSizer->Add(pathBox, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 10);

    wxStaticBoxSizer* optionsBox = new wxStaticBoxSizer(wxVERTICAL, parent, wxT("解包选项"));
    wxFlexGridSizer* optionsGrid = new wxFlexGridSizer(2, 2, 8, 12);
    optionsGrid->AddGrowableCol(0, 1);
    optionsGrid->AddGrowableCol(1, 1);

    wxBoxSizer* leftOptions = new wxBoxSizer(wxVERTICAL);
    m_verifyCRCCheck = new wxCheckBox(parent, wxID_ANY, wxT("验证 CRC32 校验"));
    m_verifyCRCCheck->SetValue(true);
    leftOptions->Add(m_verifyCRCCheck, 0, wxBOTTOM, 6);

    m_overwriteCheck = new wxCheckBox(parent, wxID_ANY, wxT("覆盖已存在文件"));
    m_overwriteCheck->SetValue(false);
    leftOptions->Add(m_overwriteCheck, 0, wxBOTTOM, 6);

    m_organizeByTypeCheck = new wxCheckBox(parent, wxID_ANY, wxT("按文件类型分类存放"));
    m_organizeByTypeCheck->SetValue(true);
    leftOptions->Add(m_organizeByTypeCheck, 0, wxBOTTOM, 6);

    m_autoLoadMappingCheck = new wxCheckBox(parent, wxID_ANY, wxT("打开索引后自动加载同目录映射"));
    m_autoLoadMappingCheck->SetValue(true);
    leftOptions->Add(m_autoLoadMappingCheck, 0);
    optionsGrid->Add(leftOptions, 1, wxEXPAND);

    wxBoxSizer* rightOptions = new wxBoxSizer(wxVERTICAL);
    m_streamModeCheck = new wxCheckBox(parent, wxID_ANY, wxT("启用流式解包（大文件优化）"));
    m_streamModeCheck->SetValue(false);
    rightOptions->Add(m_streamModeCheck, 0, wxBOTTOM, 6);

    wxBoxSizer* streamSizer = new wxBoxSizer(wxHORIZONTAL);
    streamSizer->Add(new wxStaticText(parent, wxID_ANY, wxT("流式块大小(MB)")), 0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 6);
    m_streamChunkCtrl = new wxSpinCtrl(parent, wxID_ANY, wxT("4"), wxDefaultPosition, wxSize(70, -1));
    m_streamChunkCtrl->SetRange(1, 256);
    m_streamChunkCtrl->Enable(m_streamModeCheck->GetValue());
    streamSizer->Add(m_streamChunkCtrl, 0, wxRIGHT, 10);
    streamSizer->Add(new wxStaticText(parent, wxID_ANY, wxT("线程数")), 0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 6);
    m_threadCountCtrl = new wxSpinCtrl(parent, wxID_ANY, wxT("4"), wxDefaultPosition, wxSize(70, -1));
    m_threadCountCtrl->SetRange(1, 16);
    streamSizer->Add(m_threadCountCtrl, 0);
    rightOptions->Add(streamSizer, 0, wxBOTTOM, 6);

    wxBoxSizer* decryptModeSizer = new wxBoxSizer(wxHORIZONTAL);
    decryptModeSizer->Add(new wxStaticText(parent, wxID_ANY, wxT("解密模式")), 0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 6);
    wxArrayString decryptModeChoices;
    decryptModeChoices.Add(wxT("自动 (依次尝试 LJ / APK)"));
    decryptModeChoices.Add(wxT("LJFilePack-SMS4"));
    decryptModeChoices.Add(wxT("APK-ClientObf"));
    m_decryptModeChoice = new wxChoice(parent, wxID_ANY, wxDefaultPosition, wxDefaultSize, decryptModeChoices);
    m_decryptModeChoice->SetSelection(0);
    decryptModeSizer->Add(m_decryptModeChoice, 1);
    rightOptions->Add(decryptModeSizer, 0, wxEXPAND);
    optionsGrid->Add(rightOptions, 1, wxEXPAND);

    optionsBox->Add(optionsGrid, 1, wxEXPAND | wxALL, 8);
    rootSizer->Add(optionsBox, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 10);

    wxStaticBoxSizer* keyBox = new wxStaticBoxSizer(wxVERTICAL, parent, wxT("Android 密钥与手动覆盖"));
    wxFlexGridSizer* keyGrid = new wxFlexGridSizer(2, 3, 8, 8);
    keyGrid->AddGrowableCol(1, 1);

    keyGrid->Add(new wxStaticText(parent, wxID_ANY, wxT("Android libgame.so")), 0, wxALIGN_CENTER_VERTICAL);
    m_androidLibgameCtrl = new wxTextCtrl(parent, wxID_ANY, wxEmptyString);
    m_androidLibgameCtrl->SetHint(wxT("选择 libgame.so；留空时按输入目录附近自动探测"));
    keyGrid->Add(m_androidLibgameCtrl, 1, wxEXPAND);
    wxButton* browseAndroidLibgameButton = new wxButton(parent, wxID_ANY, wxT("导入 libgame.so"));
    keyGrid->Add(browseAndroidLibgameButton, 0, wxALIGN_CENTER_VERTICAL);

    keyGrid->Add(new wxStaticText(parent, wxID_ANY, wxT("解密密钥")), 0, wxALIGN_CENTER_VERTICAL);
    m_decryptKeyCtrl = new wxTextCtrl(parent, wxID_ANY, wxEmptyString);
    m_decryptKeyCtrl->SetHint(wxT("可手动输入；选择 libgame.so 后会自动回填"));
    keyGrid->Add(m_decryptKeyCtrl, 1, wxEXPAND);
    keyGrid->Add(new wxStaticText(parent, wxID_ANY, wxT(""), wxDefaultPosition, wxSize(1, 1)), 0);

    keyBox->Add(keyGrid, 0, wxEXPAND | wxALL, 8);
    keyBox->Add(new wxStaticText(parent, wxID_ANY,
                                 wxT("支持直接选择 libgame.so，也支持手动粘贴 APK 解包根目录。")),
                0, wxLEFT | wxRIGHT | wxBOTTOM, 8);
    rootSizer->Add(keyBox, 0, wxEXPAND | wxALL, 10);

    parent->SetSizer(rootSizer);

    m_streamModeCheck->Bind(wxEVT_CHECKBOX, [this](wxCommandEvent& evt) {
        if (m_streamChunkCtrl) {
            m_streamChunkCtrl->Enable(evt.IsChecked());
        }
    });

    browseAndroidLibgameButton->Bind(wxEVT_BUTTON, [this](wxCommandEvent&) {
        wxString initialPath;
        if (m_androidLibgameCtrl) {
            initialPath = m_androidLibgameCtrl->GetValue();
        }

        wxFileName initialFile(initialPath);
        wxString defaultDir = initialFile.GetPath();
        wxString defaultName = initialFile.GetFullName();
        wxFileDialog dialog(this,
                            wxT("选择 Android libgame.so"),
                            defaultDir,
                            defaultName,
                            wxT("Android 共享库 (libgame.so)|libgame.so|共享库文件 (*.so)|*.so|所有文件 (*.*)|*.*"),
                            wxFD_OPEN | wxFD_FILE_MUST_EXIST);
        if (dialog.ShowModal() != wxID_OK) {
            return;
        }

        if (m_androidLibgameCtrl) {
            m_androidLibgameCtrl->SetValue(dialog.GetPath());
        }
        TryApplyAndroidLibgameKey(true, true);
    });

    if (m_outputDirCtrl) {
        m_outputDirCtrl->Bind(wxEVT_TEXT, [this](wxCommandEvent&) {
            UpdateWorkflowStatus();
        });
    }
    if (m_verifyCRCCheck) {
        m_verifyCRCCheck->Bind(wxEVT_CHECKBOX, [this](wxCommandEvent&) {
            UpdateWorkflowStatus();
        });
    }
    if (m_overwriteCheck) {
        m_overwriteCheck->Bind(wxEVT_CHECKBOX, [this](wxCommandEvent&) {
            UpdateWorkflowStatus();
        });
    }
    if (m_organizeByTypeCheck) {
        m_organizeByTypeCheck->Bind(wxEVT_CHECKBOX, [this](wxCommandEvent&) {
            UpdateWorkflowStatus();
        });
    }
    if (m_streamModeCheck) {
        m_streamModeCheck->Bind(wxEVT_CHECKBOX, [this](wxCommandEvent&) {
            UpdateWorkflowStatus();
        });
    }
    if (m_streamChunkCtrl) {
        m_streamChunkCtrl->Bind(wxEVT_SPINCTRL, [this](wxSpinEvent&) {
            UpdateWorkflowStatus();
        });
    }
    if (m_threadCountCtrl) {
        m_threadCountCtrl->Bind(wxEVT_SPINCTRL, [this](wxSpinEvent&) {
            UpdateWorkflowStatus();
        });
    }
    if (m_decryptModeChoice) {
        m_decryptModeChoice->Bind(wxEVT_CHOICE, [this](wxCommandEvent&) {
            UpdateWorkflowStatus();
        });
    }
    if (m_decryptKeyCtrl) {
        m_decryptKeyCtrl->Bind(wxEVT_TEXT, [this](wxCommandEvent&) {
            SyncDecryptKeyFromUi();
            UpdateWorkflowStatus();
        });
    }
}

// ============================================================================
// 事件处理
// ============================================================================
void MainFrame::OnOpenIndex(wxCommandEvent& event) {
    wxUnusedVar(event);
    wxFileDialog dialog(this, wxT("选择索引文件"),
                        wxEmptyString, wxEmptyString,
                        wxT("LJFilePack 索引文件 (*.ljpi;*.ljzip)|*.ljpi;*.ljzip|所有文件 (*.*)|*.*"),
                        wxFD_OPEN | wxFD_FILE_MUST_EXIST);

    if (dialog.ShowModal() == wxID_OK) {
        LoadIndex(dialog.GetPath());
    }
}

void MainFrame::OnOpenDir(wxCommandEvent& event) {
    wxUnusedVar(event);
    wxDirDialog dialog(this, wxT("选择资源目录"),
                       wxEmptyString, wxDD_DEFAULT_STYLE | wxDD_DIR_MUST_EXIST);

    if (dialog.ShowModal() == wxID_OK) {
        wxString dir = dialog.GetPath();
        AppendSessionLog(wxString::Format(wxT("已选择资源目录：%s"), dir.c_str()));

        // 尝试查找索引文件
        wxString ljpiPath = dir + wxT("/fl.ljpi");
        wxString ljzipPath = dir + wxT("/fl.ljzip");

        if (wxFileExists(ljpiPath)) {
            AppendSessionLog(wxT("检测到 fl.ljpi，开始加载索引。"));
            LoadIndex(ljpiPath);
        } else if (wxFileExists(ljzipPath)) {
            AppendSessionLog(wxT("检测到 fl.ljzip，开始加载索引。"));
            LoadIndex(ljzipPath);
        } else {
            AppendSessionLog(wxT("目录中未找到 fl.ljpi/fl.ljzip。"));
            wxMessageBox(wxT("目录中未找到索引文件 (fl.ljpi 或 fl.ljzip)"),
                         wxT("错误"), wxOK | wxICON_ERROR, this);
        }
    }
}

void MainFrame::ApplyPresetBySelection(int selection) {
    if (!m_verifyCRCCheck || !m_overwriteCheck || !m_organizeByTypeCheck ||
        !m_streamModeCheck || !m_streamChunkCtrl || !m_threadCountCtrl) {
        return;
    }

    switch (selection) {
        case 1: // 快速审阅
            m_verifyCRCCheck->SetValue(false);
            m_overwriteCheck->SetValue(false);
            m_organizeByTypeCheck->SetValue(false);
            m_streamModeCheck->SetValue(false);
            m_streamChunkCtrl->Enable(false);
            m_threadCountCtrl->SetValue(2);
            break;
        case 2: // 长任务/大文件
            m_verifyCRCCheck->SetValue(true);
            m_overwriteCheck->SetValue(false);
            m_organizeByTypeCheck->SetValue(true);
            m_streamModeCheck->SetValue(true);
            m_streamChunkCtrl->Enable(true);
            m_streamChunkCtrl->SetValue(8);
            m_threadCountCtrl->SetValue(6);
            break;
        case 0:
        default: // 标准闭环
            m_verifyCRCCheck->SetValue(true);
            m_overwriteCheck->SetValue(false);
            m_organizeByTypeCheck->SetValue(true);
            m_streamModeCheck->SetValue(false);
            m_streamChunkCtrl->Enable(false);
            m_streamChunkCtrl->SetValue(4);
            m_threadCountCtrl->SetValue(4);
            break;
    }

    UpdateWorkflowStatus();
}

bool MainFrame::BuildUnpackOptions(UnpackOptions& options, bool showError) {
    wxUnusedVar(showError);

    options.verifyCRC32 = (m_verifyCRCCheck && m_verifyCRCCheck->GetValue());
    options.overwriteExisting = (m_overwriteCheck && m_overwriteCheck->GetValue());
    options.organizeByType = (m_organizeByTypeCheck && m_organizeByTypeCheck->GetValue());
    options.threadCount = (m_threadCountCtrl ? m_threadCountCtrl->GetValue() : 1);
    options.decryptKey = (m_decryptKeyCtrl ? std::string(m_decryptKeyCtrl->GetValue().mb_str()) : std::string());
    options.useStreamMode = (m_streamModeCheck && m_streamModeCheck->GetValue());

    if (m_streamChunkCtrl) {
        int chunkMB = m_streamChunkCtrl->GetValue();
        if (chunkMB <= 0) {
            chunkMB = 4;
        }
        options.streamChunkSize = static_cast<uint32_t>(chunkMB) * 1024 * 1024;
    }

    if (m_decryptModeChoice) {
        switch (m_decryptModeChoice->GetSelection()) {
            case 1:
                options.decryptMode = DecryptMode::LJFilePackSMS4;
                break;
            case 2:
                options.decryptMode = DecryptMode::ApkClientObf;
                break;
            case 0:
            default:
                options.decryptMode = DecryptMode::Auto;
                break;
        }
    }

    return true;
}

bool MainFrame::ValidateReadyForUnpack(bool showError) const {
    if (!m_unpacker || m_unpacker->GetTotalFiles() == 0 || !m_hasLoadedIndex) {
        if (showError) {
            wxMessageBox(wxT("请先打开索引文件"),
                         wxT("提示"), wxOK | wxICON_INFORMATION, const_cast<MainFrame*>(this));
        }
        return false;
    }

    wxString outputDir = m_outputDirCtrl ? m_outputDirCtrl->GetValue() : wxEmptyString;
    outputDir.Trim(true).Trim(false);
    if (!m_outputDirCtrl || outputDir.IsEmpty()) {
        if (showError) {
            wxMessageBox(wxT("请先设置输出目录"),
                         wxT("提示"), wxOK | wxICON_INFORMATION, const_cast<MainFrame*>(this));
        }
        return false;
    }

    return true;
}

bool MainFrame::StartUnpackWorkflow(const UnpackOptions& options,
                                    const std::vector<size_t>* selectedIndices,
                                    const wxString& workflowLabel) {
    if (m_isUnpacking) {
        wxMessageBox(wxT("正在解包中，请等待完成或点击停止"),
                     wxT("提示"), wxOK | wxICON_INFORMATION, this);
        return false;
    }

    if (!ValidateReadyForUnpack(true)) {
        return false;
    }

    EnsureUsablePathMapping(true);
    UpdateWorkflowStatus();

    TryApplyAndroidLibgameKey(false, false);
    SyncDecryptKeyFromUi();

    m_currentOutputDir = WxToNativePath(m_outputDirCtrl->GetValue());
    const bool useSelection = (selectedIndices != nullptr && !selectedIndices->empty());
    const int workflowTotal = useSelection
        ? static_cast<int>(selectedIndices->size())
        : static_cast<int>(m_unpacker->GetTotalFiles());
    m_currentRunLabel = workflowLabel.IsEmpty()
        ? (useSelection ? wxT("问题组复跑") : wxT("解包进度"))
        : workflowLabel;

    if (m_progressDialog) {
        m_progressDialog->Destroy();
        m_progressDialog = nullptr;
    }

    m_progressDialog = new ProgressDialog(this, m_currentRunLabel, workflowTotal);
    m_progressDialog->Bind(wxEVT_DESTROY, &MainFrame::OnProgressDialogDestroy, this);
    m_progressDialog->SetPauseHandler([this](bool paused) {
        if (!m_unpacker) {
            return;
        }
        m_unpacker->SetPaused(paused);
        m_workflowSession.SetPaused(paused);
        AppendSessionLog(paused ? wxT("进度窗口请求：任务已暂停。")
                                : wxT("进度窗口请求：任务继续执行。"));
        UpdateWorkflowStatus();
    });
    m_progressDialog->SetStopHandler([this]() {
        if (!m_unpacker) {
            return;
        }
        m_unpacker->Stop();
        m_workflowSession.RequestStop();
        AppendSessionLog(wxT("进度窗口请求：正在停止任务。"));
        UpdateWorkflowStatus();
        if (m_statusBar) {
            m_statusBar->SetStatusText(wxT("正在停止..."), 0);
        }
    });
    m_progressDialog->Show();

    m_unpackThread = new UnpackThread(this, m_unpacker.get(),
                                      m_currentInputDir, m_currentOutputDir, options,
                                      selectedIndices);
    SLJFP_LOG_INFO(L"Preparing unpack thread...");
    AppendRuntimeTrace("OnUnpackAll: thread object created");

    if (m_unpackThread->Create() != wxTHREAD_NO_ERROR) {
        SLJFP_LOG_ERROR(L"Failed to create unpack thread");
        AppendRuntimeTrace("OnUnpackAll: thread create failed");
        wxMessageBox(wxT("无法创建解包线程"),
                     wxT("错误"), wxOK | wxICON_ERROR, this);
        delete m_unpackThread;
        m_unpackThread = nullptr;
        m_progressDialog->Destroy();
        m_progressDialog = nullptr;
        return false;
    }

    if (m_unpackThread->Run() != wxTHREAD_NO_ERROR) {
        SLJFP_LOG_ERROR(L"Failed to run unpack thread");
        AppendRuntimeTrace("OnUnpackAll: thread run failed");
        wxMessageBox(wxT("无法启动解包线程"),
                     wxT("错误"), wxOK | wxICON_ERROR, this);
        delete m_unpackThread;
        m_unpackThread = nullptr;
        m_progressDialog->Destroy();
        m_progressDialog = nullptr;
        return false;
    }

    SLJFP_LOG_INFO(L"Unpack thread started");
    AppendRuntimeTrace("OnUnpackAll: thread run ok");

    m_isUnpacking = true;
    m_toolBar->EnableTool(ID_STOP_UNPACK, true);
    m_toolBar->EnableTool(ID_UNPACK_ALL, false);
    m_workflowSession.SetExecutionPlan(m_currentOutputDir, options);
    m_workflowSession.BeginRun(static_cast<uint32_t>(workflowTotal));
    AppendSessionLog(wxString::Format(wxT("开始执行：%s（目标 %d 文件）"),
                                      m_currentRunLabel.c_str(),
                                      workflowTotal));
    UpdateWorkflowStatus();
    return true;
}

void MainFrame::OnUnpackAll(wxCommandEvent& event) {
    wxUnusedVar(event);
    UnpackOptions options;
    if (!BuildUnpackOptions(options, true)) {
        return;
    }
    StartUnpackWorkflow(options);
}

void MainFrame::OnUnpackSelected(wxCommandEvent& event) {
    wxUnusedVar(event);
    if (m_isUnpacking) {
        wxMessageBox(wxT("正在解包中，请等待完成或点击停止"),
                     wxT("提示"), wxOK | wxICON_INFORMATION, this);
        return;
    }

    size_t selected = GetSelectedFileIndex();
    if (selected == static_cast<size_t>(-1)) {
        wxMessageBox(wxT("请先选择要解包的文件"),
                     wxT("提示"), wxOK | wxICON_INFORMATION, this);
        return;
    }

    TryApplyAndroidLibgameKey(false, false);
    SyncDecryptKeyFromUi();

    UnpackOptions options;
    if (!BuildUnpackOptions(options, true)) {
        return;
    }
    options.threadCount = 1;

    m_currentOutputDir = WxToNativePath(m_outputDirCtrl->GetValue());
    if (m_currentOutputDir.empty()) {
        wxMessageBox(wxT("请先设置输出目录"),
                     wxT("提示"), wxOK | wxICON_INFORMATION, this);
        return;
    }

    m_unpacker->ConfigureSession(m_currentInputDir, m_currentOutputDir, options);

    // 解包单个文件
    int result = m_unpacker->UnpackSingle(selected);

    if (result == LJFP_SUCCESS) {
        UpdatePreview(selected);
        wxMessageBox(wxT("文件解包成功"),
                     wxT("成功"), wxOK | wxICON_INFORMATION, this);
    } else {
        wxMessageBox(wxString::Format(wxT("解包失败，错误码: %d"), result),
                     wxT("错误"), wxOK | wxICON_ERROR, this);
        if (m_notebook) {
            m_notebook->SetSelection(2);
        }
    }
    UpdateWorkflowStatus();
}

void MainFrame::OnStopUnpack(wxCommandEvent& event) {
    wxUnusedVar(event);
    if (m_unpacker && m_isUnpacking) {
        m_unpacker->Stop();
        m_workflowSession.RequestStop();
        AppendSessionLog(wxT("主界面请求：正在停止任务。"));
        if (m_progressDialog) {
            m_progressDialog->RequestStop();
        }
        m_statusBar->SetStatusText(wxT("正在停止..."), 0);
        UpdateWorkflowStatus();
    }
}

void MainFrame::OnSetOutputDir(wxCommandEvent& event) {
    wxUnusedVar(event);
    wxDirDialog dialog(this, wxT("选择输出目录"),
                       m_outputDirCtrl->GetValue(),
                       wxDD_DEFAULT_STYLE);

    if (dialog.ShowModal() == wxID_OK) {
        m_outputDirCtrl->SetValue(dialog.GetPath());
        AppendSessionLog(wxString::Format(wxT("输出目录更新为：%s"), dialog.GetPath().c_str()));
        UpdateWorkflowStatus();
    }
}

void MainFrame::OnLoadMapping(wxCommandEvent& event) {
    wxUnusedVar(event);
    wxFileDialog dialog(this, wxT("选择路径映射文件"),
                        wxEmptyString, wxEmptyString,
                        wxT("映射文件 (*.map;*.txt)|*.map;*.txt|所有文件 (*.*)|*.*"),
                        wxFD_OPEN | wxFD_FILE_MUST_EXIST);

    if (dialog.ShowModal() == wxID_OK) {
        m_lastMappingFile = dialog.GetPath();
        std::string mapPath = WxToNativePath(m_lastMappingFile);
        int result = m_unpacker->LoadPathMapping(mapPath);

        if (result == LJFP_SUCCESS) {
            AppendSessionLog(wxString::Format(wxT("映射加载成功：%s"), m_lastMappingFile.c_str()));
            wxMessageBox(wxT("路径映射表加载成功"),
                         wxT("成功"), wxOK | wxICON_INFORMATION, this);
            AddMappingHistory(m_lastMappingFile);
            UpdateWorkflowStatus();
            RefreshResourceTree();
            RefreshFileList();
            UpdateStatusBar();
        } else {
            AppendSessionLog(wxString::Format(wxT("映射加载失败：%s（错误码 %d）"),
                                              m_lastMappingFile.c_str(),
                                              result));
            wxMessageBox(wxT("路径映射表加载失败"),
                         wxT("错误"), wxOK | wxICON_ERROR, this);
        }
    }
}

void MainFrame::OnGenerateMapping(wxCommandEvent& event) {
    wxUnusedVar(event);
    // 选择资源目录
    wxDirDialog dirDialog(this, wxT("选择资源目录（如 client/resource/res）"),
                          wxEmptyString, wxDD_DEFAULT_STYLE | wxDD_DIR_MUST_EXIST);

    if (dirDialog.ShowModal() != wxID_OK) {
        return;
    }

    wxString resourceDir = dirDialog.GetPath();

    // 选择输出映射文件
    wxFileDialog saveDialog(this, wxT("保存路径映射表"),
                            wxEmptyString, wxT("path_mapping.ljpm"),
                            wxT("二进制映射 (*.ljpm)|*.ljpm|映射文件 (*.txt)|*.txt|所有文件 (*.*)|*.*"),
                            wxFD_SAVE | wxFD_OVERWRITE_PROMPT);

    if (saveDialog.ShowModal() != wxID_OK) {
        return;
    }

    wxString outputPath = saveDialog.GetPath();
    bool isBinary = outputPath.EndsWith(wxT(".ljpm"));
    wxArrayString referenceDirs;
    referenceDirs.Add(resourceDir);

    wxArrayString autoExpanded;
    CollectReferenceResourceDirs(resourceDir, autoExpanded);
    for (size_t i = 0; i < autoExpanded.GetCount(); ++i) {
        if (referenceDirs.Index(autoExpanded[i]) == wxNOT_FOUND) {
            referenceDirs.Add(autoExpanded[i]);
        }
    }
    if (!m_currentInputDir.empty()) {
        wxArrayString indexExpanded;
        CollectReferenceResourceDirs(NativePathToWx(m_currentInputDir), indexExpanded);
        for (size_t i = 0; i < indexExpanded.GetCount(); ++i) {
            if (referenceDirs.Index(indexExpanded[i]) == wxNOT_FOUND) {
                referenceDirs.Add(indexExpanded[i]);
            }
        }
    }

    PathMappingGenerator::ScanStats stats;
    uint32_t uniqueMappings = 0;
    wxArrayString usedDirs;

    m_statusBar->SetStatusText(wxT("正在生成并补全映射..."), 0);
    wxBusyCursor wait;
    const bool generated = GeneratePathMappingFromReferenceDirs(referenceDirs,
                                                                outputPath,
                                                                isBinary,
                                                                stats,
                                                                uniqueMappings,
                                                                &usedDirs,
                                                                true);
    if (!generated) {
        const wxString coveragePath = outputPath + wxT(".coverage.txt");
        wxMessageBox(wxString::Format(
                         wxT("未能生成可用映射。\n\n")
                         wxT("已写出覆盖诊断：\n%s\n\n")
                         wxT("请优先检查：\n")
                         wxT("1. 是否存在可复用的标准映射种子（含 assets\\\\mapping 子目录）\n")
                         wxT("2. 参考目录是否包含可分析的原始命名资源或可解密文本资源"),
                         coveragePath.c_str()),
                     wxT("提示"), wxOK | wxICON_WARNING, this);
        return;
    }

    wxString standardTextPath;
    wxString standardBinaryPath;
    BuildStandardMappingArtifactPaths(outputPath, standardTextPath, standardBinaryPath);
    m_lastGeneratedMappingFile = standardBinaryPath;

    wxString message = wxString::Format(
        wxT("路径映射表生成成功！\n\n")
        wxT("扫描文件: %u\n")
        wxT("扫描目录: %u\n")
        wxT("总大小: %.2f MB\n")
        wxT("候选冲突: %u\n")
        wxT("最终映射: %u\n")
        wxT("耗时: %.1f ms\n\n")
        wxT("映射表:\n%s\n")
        wxT("覆盖率诊断:\n%s.coverage.txt"),
        stats.totalFiles,
        stats.totalDirs,
        (double)stats.totalBytes / (1024 * 1024),
        stats.collisions,
        uniqueMappings,
        stats.scanTimeMs,
        outputPath.c_str(),
        outputPath.c_str());
    message += wxString::Format(wxT("\n\n标准文本映射:\n%s"), standardTextPath.c_str());
    message += wxString::Format(wxT("\n标准二进制映射:\n%s"), standardBinaryPath.c_str());
    if (!SamePathIgnoreCase(outputPath, standardTextPath) &&
        !SamePathIgnoreCase(outputPath, standardBinaryPath)) {
        message += wxString::Format(wxT("\n自定义导出副本:\n%s"), outputPath.c_str());
    }
    if (!usedDirs.IsEmpty()) {
        message += wxT("\n\n已使用参考目录:");
        for (size_t i = 0; i < usedDirs.GetCount(); ++i) {
            message += wxT("\n• ") + usedDirs[i];
        }
    }

    wxMessageBox(message, wxT("成功"), wxOK | wxICON_INFORMATION, this);

    const int loadResult = wxMessageBox(wxT("是否立即加载此路径映射表？"),
                                        wxT("加载映射表"),
                                        wxYES_NO | wxICON_QUESTION, this);

    if (loadResult == wxYES) {
        const wxString mappingToLoad = wxFileExists(standardBinaryPath) ? standardBinaryPath : outputPath;
        const int loadStatus = m_unpacker->LoadPathMapping(WxToNativePath(mappingToLoad));
        if (loadStatus == LJFP_SUCCESS) {
            wxMessageBox(wxT("路径映射表加载成功"),
                         wxT("成功"), wxOK | wxICON_INFORMATION, this);
            AddMappingHistory(mappingToLoad);
            UpdateWorkflowStatus();
            RefreshResourceTree();
            RefreshFileList();
            UpdateStatusBar();
        } else {
            wxMessageBox(wxString::Format(wxT("路径映射表加载失败，错误码: %d"), loadStatus),
                         wxT("错误"), wxOK | wxICON_ERROR, this);
        }
    }

    m_statusBar->SetStatusText(wxString::Format(wxT("已生成映射: %u 条"), uniqueMappings), 0);
}

void MainFrame::OnLoadMappingHistory(wxCommandEvent& event) {
    wxUnusedVar(event);
    if (!m_mappingHistoryCombo) {
        return;
    }
    wxString selected = m_mappingHistoryCombo->GetValue();
    if (selected.IsEmpty()) {
        wxMessageBox(wxT("请选择历史映射文件"), wxT("提示"),
                     wxOK | wxICON_INFORMATION, this);
        return;
    }

    wxFileName mappingFile(selected);
    if (!mappingFile.FileExists()) {
        wxMessageBox(wxT("文件不存在，请重新选择"), wxT("错误"),
                     wxOK | wxICON_ERROR, this);
        return;
    }

    int result = m_unpacker->LoadPathMapping(WxToNativePath(mappingFile.GetFullPath()));
    if (result == LJFP_SUCCESS) {
        AppendSessionLog(wxString::Format(wxT("历史映射加载成功：%s"), mappingFile.GetFullPath().c_str()));
        AddMappingHistory(mappingFile.GetFullPath());
        UpdateWorkflowStatus();
        RefreshResourceTree();
        RefreshFileList();
        UpdateStatusBar();
        wxMessageBox(wxT("路径映射表加载成功"),
                     wxT("成功"), wxOK | wxICON_INFORMATION, this);
    } else {
        AppendSessionLog(wxString::Format(wxT("历史映射加载失败：%s（错误码 %d）"),
                                          mappingFile.GetFullPath().c_str(),
                                          result));
        wxMessageBox(wxString::Format(wxT("路径映射表加载失败，错误码: %d"), result),
                     wxT("错误"), wxOK | wxICON_ERROR, this);
    }
}

void MainFrame::OnPresetChanged(wxCommandEvent& event) {
    ApplyPresetBySelection(event.GetSelection());
}

void MainFrame::OnQuickOpenDir(wxCommandEvent& event) {
    OnOpenDir(event);
}

void MainFrame::OnQuickOpenIndex(wxCommandEvent& event) {
    OnOpenIndex(event);
}

void MainFrame::OnQuickSetOutput(wxCommandEvent& event) {
    OnSetOutputDir(event);
}

void MainFrame::OnQuickLoadMapping(wxCommandEvent& event) {
    OnLoadMapping(event);
}

void MainFrame::OnQuickGenerateMapping(wxCommandEvent& event) {
    OnGenerateMapping(event);
}

void MainFrame::OnQuickUnpack(wxCommandEvent& event) {
    OnUnpackAll(event);
}

void MainFrame::OnQuickTogglePause(wxCommandEvent& event) {
    wxUnusedVar(event);
    if (!m_unpacker || !m_isUnpacking) {
        return;
    }

    const bool currentlyPaused = m_workflowSession.GetRunState().paused;
    const bool nextPaused = !currentlyPaused;
    m_unpacker->SetPaused(nextPaused);
    m_workflowSession.SetPaused(nextPaused);

    if (m_progressDialog) {
        m_progressDialog->AddLog(LogEntryType::Info,
                                 nextPaused ? wxT("主界面请求：已暂停") : wxT("主界面请求：继续执行"));
    }
    AppendSessionLog(nextPaused ? wxT("主界面请求：任务已暂停。")
                                : wxT("主界面请求：任务继续执行。"));
    UpdateWorkflowStatus();
}

void MainFrame::OnQuickStop(wxCommandEvent& event) {
    OnStopUnpack(event);
}

void MainFrame::OnReviewOpenOutput(wxCommandEvent& event) {
    wxUnusedVar(event);
    const WorkflowSessionController::ExecutionState& execution = m_workflowSession.GetExecutionState();
    if (!execution.outputReady) {
        wxMessageBox(wxT("请先设置输出目录"),
                     wxT("提示"), wxOK | wxICON_INFORMATION, this);
        return;
    }

    const wxString outputDir = NativePathToWx(execution.outputDir);
    if (!wxDirExists(outputDir)) {
        wxMessageBox(wxT("输出目录尚未生成，请先执行解包"),
                     wxT("提示"), wxOK | wxICON_INFORMATION, this);
        return;
    }

    if (!wxLaunchDefaultApplication(outputDir)) {
        wxMessageBox(wxT("无法打开输出目录"),
                     wxT("错误"), wxOK | wxICON_ERROR, this);
    }
}

void MainFrame::OnReviewLocateIssue(wxCommandEvent& event) {
    wxUnusedVar(event);
    const ReviewIssueGroup* group = GetSelectedReviewIssueGroup();
    size_t fileIndex = static_cast<size_t>(-1);
    if (WorkflowReviewController::TryResolveLocateFileIndex(group,
                                                            m_workflowSession,
                                                            m_unpacker.get(),
                                                            fileIndex) &&
        m_unpacker != nullptr &&
        fileIndex < m_unpacker->GetFileList().size()) {
        SelectAndRevealFile(fileIndex);
        return;
    }

    wxMessageBox(wxT("当前没有可定位的问题文件"),
                 wxT("提示"), wxOK | wxICON_INFORMATION, this);
}

void MainFrame::OnReviewGenerateMapping(wxCommandEvent& event) {
    wxUnusedVar(event);
    if (!EnsureUsablePathMapping(true)) {
        UpdateWorkflowStatus();
    }
}

void MainFrame::OnReviewExportFailures(wxCommandEvent& event) {
    wxUnusedVar(event);
    WorkflowReviewExportService::Scope scope;
    const WorkflowReviewExportService::Scope* scopePtr = nullptr;
    const ReviewIssueGroup* selectedGroup = GetSelectedReviewIssueGroup();
    if (selectedGroup != nullptr) {
        scope.label = !selectedGroup->filterLabel.empty()
            ? selectedGroup->filterLabel
            : selectedGroup->subject;
        scope.fileIndices = selectedGroup->fileIndices;
        scopePtr = &scope;
    }

    const WorkflowReviewExportService::Result exportResult =
        WorkflowReviewExportService::ExportFailedItems(
            m_unpacker.get(),
            m_outputDirCtrl ? WxToNativePath(m_outputDirCtrl->GetValue()) : std::string(),
            scopePtr);

    if (exportResult.ok()) {
        const wxString exportBasePath = NativePathToWx(exportResult.basePath);
        wxMessageBox(wxString::Format(wxT("失败项已导出:\n%s.tsv\n%s.json"),
                                      exportBasePath.c_str(),
                                      exportBasePath.c_str()),
                     wxT("导出完成"),
                     wxOK | wxICON_INFORMATION,
                     this);
        return;
    }

    switch (exportResult.error) {
        case WorkflowReviewExportService::Error::MissingOutputDir:
            wxMessageBox(wxT("请先设置输出目录，再导出失败项"),
                         wxT("提示"),
                         wxOK | wxICON_INFORMATION,
                         this);
            break;
        case WorkflowReviewExportService::Error::NoFailedFiles:
            wxMessageBox(wxT("最近一次运行没有失败文件可导出"),
                         wxT("提示"),
                         wxOK | wxICON_INFORMATION,
                         this);
            break;
        case WorkflowReviewExportService::Error::NoMatchingFailedItems:
            wxMessageBox(wxT("当前问题组没有失败文件可导出"),
                         wxT("提示"),
                         wxOK | wxICON_INFORMATION,
                         this);
            break;
        case WorkflowReviewExportService::Error::OutputDirCreateFailed:
            wxMessageBox(wxT("导出失败项时无法创建输出目录"),
                         wxT("错误"),
                         wxOK | wxICON_ERROR,
                         this);
            break;
        case WorkflowReviewExportService::Error::OutputFileOpenFailed:
            wxMessageBox(wxT("导出失败项时无法创建输出文件"),
                         wxT("错误"),
                         wxOK | wxICON_ERROR,
                         this);
            break;
        case WorkflowReviewExportService::Error::MissingUnpacker:
        case WorkflowReviewExportService::Error::None:
        default:
            wxMessageBox(wxT("导出失败项时发生未知错误"),
                         wxT("错误"),
                         wxOK | wxICON_ERROR,
                         this);
            break;
    }
}

void MainFrame::OnReviewRerunIssue(wxCommandEvent& event) {
    wxUnusedVar(event);
    const ReviewIssueGroup* group = GetSelectedReviewIssueGroup();
    std::vector<size_t> rerunIndices;
    std::wstring rerunSubject;
    if (!WorkflowReviewController::BuildRerunRequest(group, rerunIndices, rerunSubject)) {
        wxMessageBox(wxT("当前问题项没有可复跑的文件集合"),
                     wxT("提示"), wxOK | wxICON_INFORMATION, this);
        return;
    }

    UnpackOptions options;
    if (!BuildUnpackOptions(options, true)) {
        return;
    }

    const wxString label = wxString::Format(wxT("问题组复跑 - %s"), wxString(rerunSubject.c_str()).c_str());
    StartUnpackWorkflow(options, &rerunIndices, label);
}

void MainFrame::OnReviewClearFilter(wxCommandEvent& event) {
    wxUnusedVar(event);
    ClearReviewFilter();
}

void MainFrame::OnOptions(wxCommandEvent& event) {
    wxUnusedVar(event);
    // 切换到配置标签页
    m_notebook->SetSelection(3);
}

void MainFrame::OnAbout(wxCommandEvent& event) {
    wxUnusedVar(event);
    wxMessageBox(
        wxT("Super LJFilePackUnpack v1.0\n\n")
        wxT("资源包解包工具\n\n")
        wxT("功能:\n")
        wxT("- 支持 .ljpi/.ljzip 索引文件\n")
        wxT("- 支持 SMS4 加密解密\n")
        wxT("- 支持 MiniZ 压缩解压\n")
        wxT("- 多线程并行解包\n")
        wxT("- 路径恢复支持\n\n")
        wxT("作者: Super 威少\n")
        wxT("QQ: 1583812938\n")
        wxT("日期: 2025-01-03"),
        wxT("关于"), wxOK | wxICON_INFORMATION, this);
}

void MainFrame::OnExit(wxCommandEvent& event) {
    wxUnusedVar(event);
    Close(true);
}

void MainFrame::OnFileListSelected(wxListEvent& event) {
    long item = event.GetIndex();
    long fileIndex = m_fileList->GetItemData(item);
    if (fileIndex >= 0) {
        UpdatePreview(static_cast<size_t>(fileIndex));
    } else {
        ClearPreviewPanel();
    }
}

void MainFrame::OnFileListActivated(wxListEvent& event) {
    wxUnusedVar(event);
    // 双击解包选中文件
    wxCommandEvent dummy;
    OnUnpackSelected(dummy);
}

void MainFrame::OnResultIssueSelected(wxListEvent& event) {
    ApplyReviewFilter(GetReviewIssueGroupByRow(event.GetIndex()));
}

void MainFrame::OnResultIssueActivated(wxListEvent& event) {
    const ReviewIssueGroup* group = GetReviewIssueGroupByRow(event.GetIndex());
    if (group == nullptr) {
        return;
    }

    if (group->primaryFileIndex >= 0) {
        SelectAndRevealFile(static_cast<size_t>(group->primaryFileIndex));
        return;
    }

    if (!group->fileIndices.empty()) {
        SelectAndRevealFile(group->fileIndices.front());
    }
}

void MainFrame::OnTreeSelChanged(wxTreeEvent& event) {
    const wxTreeItemId item = event.GetItem();
    ResourceTreeFilterData* data = item.IsOk()
        ? dynamic_cast<ResourceTreeFilterData*>(m_resourceTree->GetItemData(item))
        : nullptr;

    if (data) {
        m_workflowSession.SetFilter(data->mode, data->packIndex);
    } else {
        m_workflowSession.SetFilter(WorkflowSessionController::TreeFilterMode::AllFiles);
    }

    RefreshFileList();
    UpdateWorkflowStatus();
}

void MainFrame::OnUnpackProgress(wxThreadEvent& event) {
    float progress = event.GetPayload<float>();
    int currentCount = event.GetInt();  // 使用事件中传递的实际完成数
    long totalCount = event.GetExtraLong();  // 使用事件中传递的总数

    // 如果没有传递有效值，则从 unpacker 获取
    if (totalCount <= 0) {
        totalCount = static_cast<long>(m_unpacker->GetTotalFiles());
    }
    if (currentCount < 0) {
        currentCount = static_cast<int>(progress * totalCount);
    }

    m_workflowSession.UpdateRunProgress(static_cast<uint32_t>(std::max(currentCount, 0)),
                                        static_cast<uint32_t>(std::max<long>(totalCount, 0)));

    m_statusBar->SetStatusText(wxString::Format(wxT("进度: %.1f%% (%d/%ld)"),
                                                 progress * 100, currentCount, totalCount), 1);

    // 更新进度对话框
    if (m_progressDialog) {
        wxString currentFile = wxString::Format(wxT("文件 %d/%ld"), currentCount, totalCount);
        int currentIndex = (currentCount > 0) ? (currentCount - 1) : -1;
        m_progressDialog->UpdateProgress(currentIndex, currentFile, 0);

        static bool s_firstProgressEventLogged = false;
        if (!s_firstProgressEventLogged) {
            AppendRuntimeTrace("OnUnpackProgress: first progress event received");
            s_firstProgressEventLogged = true;
        }

    }

    UpdateWorkflowStatus();
}

void MainFrame::OnUnpackComplete(wxThreadEvent& event) {
    m_isUnpacking = false;
    WaitAndDeleteThread(m_unpackThread);

    m_toolBar->EnableTool(ID_STOP_UNPACK, false);
    m_toolBar->EnableTool(ID_UNPACK_ALL, true);

    int result = event.GetPayload<int>();
    AppendRuntimeTrace(
        std::string("OnUnpackComplete: result=") + std::to_string(result) +
        ", success=" + std::to_string(m_unpacker->GetProcessedFiles()) +
        ", failed=" + std::to_string(m_unpacker->GetFailedFiles()));

    wxString summary;
    if (result == LJFP_SUCCESS) {
        summary = wxString::Format(
            wxT("解包完成! 成功: %u, 失败: %u\n")
            wxT("路径清单: unpack_path_manifest.tsv / unpack_path_manifest.json"),
            m_unpacker->GetProcessedFiles(),
            m_unpacker->GetFailedFiles());
    } else if (result == LJFP_ERROR_PARTIAL_FAILURE) {
        summary = wxString::Format(
            wxT("解包完成（部分失败）: 成功: %u, 失败: %u\n")
            wxT("已写出可用的路径清单: unpack_path_manifest.tsv / unpack_path_manifest.json"),
            m_unpacker->GetProcessedFiles(),
            m_unpacker->GetFailedFiles());
    } else {
        wxString errText(GetErrorMessage(static_cast<ErrorCode>(result)));
        summary = wxString::Format(wxT("解包失败，错误码: %d (%s)"), result, errText);
    }

    m_workflowSession.FinishRun(result,
                                m_unpacker->GetProcessedFiles(),
                                m_unpacker->GetFailedFiles(),
                                0,
                                0,
                                WxToNativePath(summary));

    // 更新进度对话框
    if (m_progressDialog) {
        m_progressDialog->SetResultCounts(
            static_cast<int>(m_unpacker->GetProcessedFiles()),
            static_cast<int>(m_unpacker->GetFailedFiles()));
        m_progressDialog->SetFinished(summary);
    }

    if (result == LJFP_SUCCESS) {
        m_statusBar->SetStatusText(wxT("解包完成"), 0);
    } else if (result == LJFP_ERROR_PARTIAL_FAILURE) {
        m_statusBar->SetStatusText(wxT("解包完成（部分失败）"), 0);
    } else {
        m_statusBar->SetStatusText(wxT("解包失败"), 0);
    }

    UpdateStatusBar();
    UpdateWorkflowStatus();
    RefreshFileList();
    AppendSessionLog(summary);
    if (m_notebook) {
        m_notebook->SetSelection(2);
    }
}

void MainFrame::OnProgressDialogDestroy(wxWindowDestroyEvent& event) {
    // 对话框被销毁时清理指针，防止悬空指针
    if (event.GetWindow() == m_progressDialog) {
        m_progressDialog = nullptr;
    }
    event.Skip();  // 继续处理事件
}

// ============================================================================
// 辅助方法
// ============================================================================
void MainFrame::LoadIndex(const wxString& path) {
    wxFileName fn(path);
    m_currentInputDir = WxToNativePath(fn.GetPath());
    m_currentIndexPath = path;
    TryApplyAndroidLibgameKey(false, false);
    SyncDecryptKeyFromUi();

    m_statusBar->SetStatusText(wxT("正在加载索引..."), 0);

    int result = m_unpacker->LoadIndex(WxToNativePath(path));

    if (result == LJFP_SUCCESS) {
        m_hasLoadedIndex = true;
        m_inputDirCtrl->SetValue(fn.GetPath());
        bool mappingLoaded = TryAutoLoadMapping(fn.GetPath(), fn.GetFullName());
        UpdateWorkflowStatus();
        RefreshResourceTree();
        RefreshFileList();
        UpdateStatusBar();
        if (mappingLoaded) {
            m_statusBar->SetStatusText(wxT("索引加载成功（已自动加载映射）"), 0);
            AppendSessionLog(wxString::Format(wxT("索引加载成功：%s（自动加载映射）"), path.c_str()));
        } else {
            m_statusBar->SetStatusText(wxT("索引加载成功"), 0);
            AppendSessionLog(wxString::Format(wxT("索引加载成功：%s"), path.c_str()));
        }
    } else {
        m_hasLoadedIndex = false;
        AppendSessionLog(wxString::Format(wxT("索引加载失败：%s（错误码 %d）"),
                                          path.c_str(),
                                          result));
        wxMessageBox(wxString::Format(wxT("加载索引失败，错误码: %d"), result),
                     wxT("错误"), wxOK | wxICON_ERROR, this);
        m_statusBar->SetStatusText(wxT("加载失败"), 0);
        UpdateWorkflowStatus();
    }
}

bool MainFrame::TryApplyAndroidLibgameKey(bool forceRefresh, bool showFeedback) {
    if (!m_unpacker || !m_decryptKeyCtrl) {
        return false;
    }

    wxString existingKey = m_decryptKeyCtrl->GetValue();
    if (!forceRefresh && !existingKey.IsEmpty()) {
        m_unpacker->SetDecryptKey(WxToNativePath(existingKey));
        return true;
    }

    wxString explicitLibgamePath;
    if (m_androidLibgameCtrl) {
        explicitLibgamePath = m_androidLibgameCtrl->GetValue();
    }

    AndroidBinaryKeyProbeResult probeResult;
    if (TryResolveAndroidLibgameDecryptKey(m_currentInputDir,
                                           WxToNativePath(explicitLibgamePath),
                                           probeResult)) {
        wxString resolvedKey = wxString::FromUTF8(probeResult.decryptKey.c_str());
        wxString resolvedPath = NativePathToWx(probeResult.libgamePath);
        wxString statusMessage;

        m_decryptKeyCtrl->SetValue(resolvedKey);
        m_unpacker->SetDecryptKey(probeResult.decryptKey);

        if (resolvedPath.IsEmpty()) {
            statusMessage = wxT("已从 Android libgame.so 自动提取解密密钥");
        } else {
            statusMessage = wxString::Format(wxT("已自动提取解密密钥: %s"), resolvedPath);
        }

        m_statusBar->SetStatusText(statusMessage, 0);
        SLJFP_LOG_INFO(std::wstring(statusMessage.wc_str()));

        if (showFeedback) {
            wxNotificationMessage notify(wxT("Android 解密密钥已应用"), statusMessage, this);
            notify.Show();
        }
        return true;
    }

    if (!existingKey.IsEmpty()) {
        m_unpacker->SetDecryptKey(WxToNativePath(existingKey));
    } else {
        m_unpacker->SetDecryptKey(std::string());
    }

    if (showFeedback || !explicitLibgamePath.IsEmpty()) {
        wxString reason = NativePathToWx(probeResult.message);
        wxString statusMessage = wxT("未能从 Android libgame.so 自动提取解密密钥");
        if (!reason.IsEmpty()) {
            statusMessage += wxT("：") + reason;
        }

        m_statusBar->SetStatusText(statusMessage, 0);
        SLJFP_LOG_WARNING(std::wstring(statusMessage.wc_str()));

        if (showFeedback) {
            wxMessageBox(statusMessage, wxT("提取失败"), wxOK | wxICON_WARNING, this);
        }
    }

    return false;
}

void MainFrame::SyncDecryptKeyFromUi() {
    if (!m_unpacker || !m_decryptKeyCtrl) {
        return;
    }
    m_unpacker->SetDecryptKey(WxToNativePath(m_decryptKeyCtrl->GetValue()));
}

bool MainFrame::PromptForReferenceDirs(wxArrayString& outDirs) const {
    outDirs.Clear();

    wxArrayString suggested;
    CollectReferenceResourceDirs(NativePathToWx(m_currentInputDir), suggested);

    if (!suggested.IsEmpty()) {
        wxString message = wxT("检测到索引附近可能可用的参考资源目录，是否直接用于补全路径映射？\n\n");
        const size_t maxPreview = std::min<size_t>(static_cast<size_t>(suggested.GetCount()), 5u);
        for (size_t i = 0; i < maxPreview; ++i) {
            message += wxString::Format(wxT("• %s\n"), suggested[i].c_str());
        }
        if (suggested.GetCount() > static_cast<unsigned int>(maxPreview)) {
            message += wxString::Format(wxT("…以及另外 %u 个目录\n"),
                                        static_cast<unsigned int>(suggested.GetCount() - maxPreview));
        }

        const int choice = wxMessageBox(message,
                                        wxT("补全路径映射"),
                                        wxYES_NO | wxCANCEL | wxICON_QUESTION,
                                        const_cast<MainFrame*>(this));
        if (choice == wxYES) {
            outDirs = suggested;
            return true;
        }
        if (choice == wxCANCEL) {
            return false;
        }
    }

    const wxString defaultDir = !suggested.IsEmpty()
        ? suggested[0]
        : (m_inputDirCtrl ? m_inputDirCtrl->GetValue() : wxEmptyString);

    while (true) {
        wxDirDialog dialog(const_cast<MainFrame*>(this),
                           wxT("选择参考资源目录"),
                           defaultDir,
                           wxDD_DEFAULT_STYLE | wxDD_DIR_MUST_EXIST);
        if (dialog.ShowModal() != wxID_OK) {
            return !outDirs.IsEmpty();
        }

        if (outDirs.Index(dialog.GetPath()) == wxNOT_FOUND) {
            outDirs.Add(dialog.GetPath());
        }

        const int nextChoice = wxMessageBox(wxT("是否继续添加参考资源目录？"),
                                            wxT("补全路径映射"),
                                            wxYES_NO | wxCANCEL | wxICON_QUESTION,
                                            const_cast<MainFrame*>(this));
        if (nextChoice == wxNO) {
            break;
        }
        if (nextChoice == wxCANCEL) {
            return !outDirs.IsEmpty();
        }
    }

    return !outDirs.IsEmpty();
}

void MainFrame::CollectReferenceResourceDirs(const wxString& indexDir, wxArrayString& outDirs) const {
    auto addDirectory = [&outDirs](const wxString& rawPath) {
        const wxString normalized = NormalizeDirectoryPath(rawPath);
        if (normalized.IsEmpty()) {
            return;
        }
        if (!wxDirExists(normalized)) {
            return;
        }

        for (size_t i = 0; i < outDirs.GetCount(); ++i) {
            if (outDirs[i].CmpNoCase(normalized) == 0) {
                return;
            }
        }
        outDirs.Add(normalized);
    };

    auto appendRelative = [&addDirectory](const wxString& baseDir, const wxString& relativePath) {
        if (baseDir.IsEmpty()) {
            return;
        }

        wxFileName dirName = wxFileName::DirName(baseDir);
        wxStringTokenizer tokenizer(relativePath, wxT("/\\"));
        while (tokenizer.HasMoreTokens()) {
            dirName.AppendDir(tokenizer.GetNextToken());
        }
        addDirectory(dirName.GetFullPath());
    };

    const wxString normalizedIndexDir = NormalizeDirectoryPath(indexDir);
    wxFileName indexDirName = wxFileName::DirName(normalizedIndexDir);

    wxString leafName;
    const wxArrayString dirs = indexDirName.GetDirs();
    if (!dirs.IsEmpty()) {
        leafName = dirs[dirs.GetCount() - 1];
    }

    if (leafName.CmpNoCase(wxT("res")) == 0) {
        addDirectory(normalizedIndexDir);
    }

    appendRelative(normalizedIndexDir, wxT("res"));
    appendRelative(normalizedIndexDir, wxT("resource/res"));

    const wxString parentDir = GetParentDirectoryPath(normalizedIndexDir);
    appendRelative(parentDir, wxT("res"));
    appendRelative(parentDir, wxT("resource/res"));
    appendRelative(parentDir, wxT("client/resource/res"));

    const wxString grandParentDir = GetParentDirectoryPath(parentDir);
    appendRelative(grandParentDir, wxT("resource/res"));
    appendRelative(grandParentDir, wxT("client/resource/res"));
}

bool MainFrame::GeneratePathMappingFromReferenceDirs(const wxArrayString& referenceDirs,
                                                     const wxString& outputPath,
                                                     bool isBinary,
                                                     PathMappingGenerator::ScanStats& outStats,
                                                     uint32_t& outUniqueMappings,
                                                     wxArrayString* outUsedDirs,
                                                     bool showProgress) {
    outStats.reset();
    outUniqueMappings = 0;
    if (outUsedDirs) {
        outUsedDirs->Clear();
    }

    if (referenceDirs.IsEmpty() || outputPath.IsEmpty()) {
        return false;
    }

    wxArrayString expandedDirs;
    auto addExpandedDir = [&expandedDirs](const wxString& rawDir) {
        const wxString normalized = NormalizeDirectoryPath(rawDir);
        if (normalized.IsEmpty()) {
            return;
        }
        if (!wxDirExists(normalized)) {
            return;
        }
        for (size_t i = 0; i < expandedDirs.GetCount(); ++i) {
            if (expandedDirs[i].CmpNoCase(normalized) == 0) {
                return;
            }
        }
        expandedDirs.Add(normalized);
    };

    for (size_t i = 0; i < referenceDirs.GetCount(); ++i) {
        addExpandedDir(referenceDirs[i]);
    }
    for (size_t i = 0; i < referenceDirs.GetCount(); ++i) {
        wxArrayString suggested;
        CollectReferenceResourceDirs(referenceDirs[i], suggested);
        for (size_t j = 0; j < suggested.GetCount(); ++j) {
            addExpandedDir(suggested[j]);
        }
    }
    if (!m_currentInputDir.empty()) {
        wxArrayString indexRelated;
        CollectReferenceResourceDirs(NativePathToWx(m_currentInputDir), indexRelated);
        for (size_t i = 0; i < indexRelated.GetCount(); ++i) {
            addExpandedDir(indexRelated[i]);
        }
    }

    if (expandedDirs.IsEmpty()) {
        return false;
    }

    std::set<uint32_t> targetCrcSet;
    uint32_t totalFileCount = 0;
    uint32_t existingCoveredCount = 0;
    std::map<uint32_t, std::string> mergedMapping;
    std::map<uint32_t, std::string> existingMappingNormalized;
    uint32_t existingMappingRawCount = 0;
    uint32_t existingMappingKeptCount = 0;
    uint32_t existingMappingDroppedLowConfidenceCount = 0;
    uint32_t nearbySeedFileCount = 0;
    uint32_t nearbySeedMergedFileCount = 0;
    uint32_t nearbySeedIsolatedFileCount = 0;
    uint32_t nearbySeedRawEntryCount = 0;
    uint32_t nearbySeedMergedEntryCount = 0;
    std::vector<NearbyMappingSeedCandidate> nearbySeedCandidates;
    if (m_unpacker) {
        const std::vector<FileInfo>& files = m_unpacker->GetFileList();
        totalFileCount = static_cast<uint32_t>(files.size());
        for (size_t i = 0; i < files.size(); ++i) {
            targetCrcSet.insert(files[i].m_PathFileNameCRC32);
            if (m_unpacker->HasPathMappingForFile(i)) {
                ++existingCoveredCount;
            }
        }

        const std::map<uint32_t, std::string>& existingMap = m_unpacker->GetPathMappingTable();
        existingMappingRawCount = static_cast<uint32_t>(existingMap.size());
        for (std::map<uint32_t, std::string>::const_iterator it = existingMap.begin();
             it != existingMap.end();
             ++it) {
            const std::string normalizedPath = CanonicalizeMappingStoragePath(it->second);
            if (normalizedPath.empty()) {
                continue;
            }
            existingMappingNormalized[it->first] = normalizedPath;
        }
    }

    wxArrayString nearbyMappingCandidatePaths;
    wxArrayString nearbySeedSearchDirs;
    auto addNearbyMappingCandidatePath = [&nearbyMappingCandidatePaths](const wxString& rawPath) {
        if (rawPath.IsEmpty()) {
            return;
        }
        wxFileName fileName(rawPath);
        fileName.Normalize(wxPATH_NORM_DOTS | wxPATH_NORM_ABSOLUTE);
        const wxString normalized = fileName.GetFullPath();
        if (!fileName.FileExists()) {
            return;
        }
        for (size_t i = 0; i < nearbyMappingCandidatePaths.GetCount(); ++i) {
            if (SamePathIgnoreCase(nearbyMappingCandidatePaths[i], normalized)) {
                return;
            }
        }
        nearbyMappingCandidatePaths.Add(normalized);
    };

    auto addNearbySeedSearchDir = [&nearbySeedSearchDirs](const wxString& rawDir) {
        const wxString normalized = NormalizeDirectoryPath(rawDir);
        if (normalized.IsEmpty()) {
            return;
        }
        if (!wxDirExists(normalized)) {
            return;
        }
        for (size_t i = 0; i < nearbySeedSearchDirs.GetCount(); ++i) {
            if (SamePathIgnoreCase(nearbySeedSearchDirs[i], normalized)) {
                return;
            }
        }
        nearbySeedSearchDirs.Add(normalized);
    };

    auto addNearbyMappingFilesForDir = [&](const wxString& rawDir) {
        const wxString normalizedDir = NormalizeDirectoryPath(rawDir);
        if (normalizedDir.IsEmpty()) {
            return;
        }
        if (!wxDirExists(normalizedDir)) {
            return;
        }
        addNearbySeedSearchDir(normalizedDir);

        addNearbyMappingCandidatePath(wxFileName(normalizedDir, wxT("path_mapping.ljpm")).GetFullPath());
        addNearbyMappingCandidatePath(wxFileName(normalizedDir, wxT("path_mapping.txt")).GetFullPath());

        if (!m_currentIndexPath.IsEmpty()) {
            wxFileName indexFile(m_currentIndexPath);
            const wxString baseName = indexFile.GetName();
            if (!baseName.IsEmpty()) {
                addNearbyMappingCandidatePath(wxFileName(normalizedDir, baseName + wxT(".ljpm")).GetFullPath());
                addNearbyMappingCandidatePath(wxFileName(normalizedDir, baseName + wxT(".txt")).GetFullPath());
                addNearbyMappingCandidatePath(wxFileName(normalizedDir, baseName + wxT(".map")).GetFullPath());
            }
        }
    };

    auto addNearbyMappingChildDirs = [&](const wxString& rawDir) {
        const wxString normalizedDir = NormalizeDirectoryPath(rawDir);
        if (normalizedDir.IsEmpty() || !wxDirExists(normalizedDir)) {
            return;
        }

        const wxString childNames[] = {
            wxT("mapping"),
            wxT("mappings")
        };
        for (size_t i = 0; i < sizeof(childNames) / sizeof(childNames[0]); ++i) {
            wxFileName childDir(normalizedDir, wxEmptyString);
            childDir.AppendDir(childNames[i]);
            addNearbyMappingFilesForDir(childDir.GetFullPath());
        }
    };

    for (size_t i = 0; i < expandedDirs.GetCount(); ++i) {
        wxString searchDir = expandedDirs[i];
        for (int depth = 0; depth < 3 && !searchDir.IsEmpty(); ++depth) {
            addNearbyMappingFilesForDir(searchDir);
            addNearbyMappingChildDirs(searchDir);
            searchDir = GetParentDirectoryPath(searchDir);
        }
    }

    wxFileName outputFile(outputPath);
    addNearbyMappingFilesForDir(outputFile.GetPath());
    addNearbyMappingChildDirs(outputFile.GetPath());
    if (!m_lastMappingFile.IsEmpty()) {
        addNearbyMappingCandidatePath(m_lastMappingFile);
        wxFileName lastMappingFile(m_lastMappingFile);
        addNearbyMappingFilesForDir(lastMappingFile.GetPath());
        addNearbyMappingChildDirs(lastMappingFile.GetPath());
    }

    for (size_t i = 0; i < nearbyMappingCandidatePaths.GetCount(); ++i) {
        NearbyMappingSeedCandidate candidate;
        candidate.filePath = nearbyMappingCandidatePaths[i];
        candidate.hitCount = 0;
        candidate.mappingCount = 0;
        candidate.lowConfidenceCount = 0;
        candidate.cleanEntryCount = 0;
        candidate.semanticEntryCount = 0;
        candidate.hitRateBasis = 0;
        candidate.cleanRateBasis = 0;
        candidate.semanticRateBasis = 0;
        candidate.avgPathQualityBasis = 0;
        candidate.qualityScoreBasis = 0;
        candidate.binaryFormat = nearbyMappingCandidatePaths[i].Lower().EndsWith(wxT(".ljpm"));
        candidate.isolated = false;
        if (!LoadNormalizedMappingSeed(candidate.filePath, candidate.normalizedMappings)) {
            continue;
        }

        candidate.mappingCount = static_cast<uint32_t>(candidate.normalizedMappings.size());
        nearbySeedRawEntryCount += candidate.mappingCount;
        const MappingSeedQualityMetrics metrics =
            EvaluateMappingSeedQuality(candidate.normalizedMappings, targetCrcSet);
        candidate.hitCount = metrics.hitCount;
        candidate.lowConfidenceCount = metrics.lowConfidenceCount;
        candidate.cleanEntryCount = metrics.cleanEntryCount;
        candidate.semanticEntryCount = metrics.semanticEntryCount;
        candidate.hitRateBasis = metrics.hitRateBasis;
        candidate.cleanRateBasis = metrics.cleanRateBasis;
        candidate.semanticRateBasis = metrics.semanticRateBasis;
        candidate.avgPathQualityBasis = metrics.avgPathQualityBasis;
        candidate.qualityScoreBasis = metrics.qualityScoreBasis;
        nearbySeedCandidates.push_back(candidate);
    }

    std::sort(nearbySeedCandidates.begin(),
              nearbySeedCandidates.end(),
              [](const NearbyMappingSeedCandidate& left, const NearbyMappingSeedCandidate& right) {
                  if (left.qualityScoreBasis != right.qualityScoreBasis) {
                      return left.qualityScoreBasis > right.qualityScoreBasis;
                  }
                  if (left.hitRateBasis != right.hitRateBasis) {
                      return left.hitRateBasis > right.hitRateBasis;
                  }
                  if (left.mappingCount != right.mappingCount) {
                      return left.mappingCount > right.mappingCount;
                  }
                  if (left.binaryFormat != right.binaryFormat) {
                      return left.binaryFormat && !right.binaryFormat;
                  }
                  return left.filePath.CmpNoCase(right.filePath) < 0;
              });

    const uint32_t bestSeedHitRateBasis =
        nearbySeedCandidates.empty() ? 0u : nearbySeedCandidates.front().hitRateBasis;
    const uint32_t bestSeedQualityScoreBasis =
        nearbySeedCandidates.empty() ? 0u : nearbySeedCandidates.front().qualityScoreBasis;

    for (size_t i = 0; i < nearbySeedCandidates.size(); ++i) {
        NearbyMappingSeedCandidate& candidate = nearbySeedCandidates[i];
        ++nearbySeedFileCount;
        candidate.isolated = ShouldIsolateMappingSeed(
            EvaluateMappingSeedQuality(candidate.normalizedMappings, targetCrcSet),
            candidate.mappingCount,
            bestSeedHitRateBasis,
            bestSeedQualityScoreBasis,
            candidate.isolationReason);
        if (candidate.isolated) {
            ++nearbySeedIsolatedFileCount;
            continue;
        }

        ++nearbySeedMergedFileCount;
        for (std::map<uint32_t, std::string>::const_iterator it = candidate.normalizedMappings.begin();
             it != candidate.normalizedMappings.end();
             ++it) {
            if (existingMappingNormalized.find(it->first) != existingMappingNormalized.end()) {
                continue;
            }
            existingMappingNormalized[it->first] = it->second;
            ++nearbySeedMergedEntryCount;
        }
    }

    PathMappingGenerator::ScanOptions options;
    options.recursiveScan = true;
    options.sljfpScanIncludeHiddenFlag = false;
    options.lowercasePaths = true;
    options.normalizeSlashes = true;

    wxProgressDialog* progressDlg = nullptr;
    if (showProgress) {
        progressDlg = new wxProgressDialog(wxT("补全路径映射"),
                                           wxT("正在准备扫描参考目录..."),
                                           100,
                                           this,
                                           wxPD_APP_MODAL | wxPD_AUTO_HIDE);
    }

    const std::chrono::high_resolution_clock::time_point startTime =
        std::chrono::high_resolution_clock::now();

    uint32_t scannedFilesTotal = 0;
    uint64_t scannedBytesTotal = 0;
    uint32_t variantTried = 0;
    uint32_t variantMatchedTarget = 0;
    uint32_t candidateConflictCount = 0;
    uint32_t mergedAddedCount = 0;
    uint32_t generatedPathAddedCount = 0;
    uint32_t skippedNumericPathCandidateFiles = 0;
    uint32_t skippedLowConfidenceContentCandidates = 0;

    uint32_t scanEntryTotal = 0;
    uint32_t scanRootEntryTotal = 0;
    uint32_t scanRootNumericTotal = 0;

    uint32_t contentScanFiles = 0;
    uint64_t contentScanBytes = 0;
    uint32_t contentTokenCount = 0;
    uint32_t contentVariantTried = 0;
    uint32_t contentVariantMatchedTarget = 0;
    uint32_t contentAmbiguousCount = 0;
    uint32_t contentAddedCount = 0;
    uint32_t decryptedContentScanFiles = 0;
    uint64_t decryptedContentScanBytes = 0;
    uint32_t decryptedContentTokenCount = 0;
    uint32_t decryptedContentVariantTried = 0;
    uint32_t decryptedContentVariantMatchedTarget = 0;
    uint32_t decryptedContentDecodeFailures = 0;

    const uint64_t kContentScanBudgetBytes = 512ULL * 1024ULL * 1024ULL;
    const size_t kContentScanPerFileLimit = 2ULL * 1024ULL * 1024ULL;
    uint64_t contentScanBudgetRemain = kContentScanBudgetBytes;
    const uint64_t kDecryptedContentScanBudgetBytes = 256ULL * 1024ULL * 1024ULL;
    const size_t kDecryptedContentPerFileLimit = 2ULL * 1024ULL * 1024ULL;
    uint64_t decryptedContentScanBudgetRemain = kDecryptedContentScanBudgetBytes;
    bool crcRepositoryDetected = false;

    std::map<uint32_t, std::string> generatedCandidates;
    std::map<uint32_t, size_t> generatedVariantRank;
    std::map<uint32_t, std::map<std::string, uint32_t> > contentCandidateVotes;
    std::vector<std::string> variants;
    std::vector<std::string> tokenVariants;
    std::vector<std::string> extractedTokens;
    std::vector<std::string> tokenCandidates;
    std::vector<unsigned char> fileSampleBytes;
    std::vector<unsigned char> decodedBytes;

    auto collectTokenVotesFromBytes =
        [&](const std::vector<unsigned char>& sourceBytes,
            const std::string& entryDir,
            uint32_t& tokenCountAccumulator,
            uint32_t& variantTriedAccumulator,
            uint32_t& variantMatchedAccumulator) {
            ExtractPathLikeTokensFromBytes(sourceBytes, extractedTokens, 640);
            if (extractedTokens.empty()) {
                return;
            }

            tokenCountAccumulator += static_cast<uint32_t>(extractedTokens.size());
            for (size_t tokenIndex = 0; tokenIndex < extractedTokens.size(); ++tokenIndex) {
                ExpandExtractedTokenToCandidates(extractedTokens[tokenIndex], entryDir, tokenCandidates);
                for (size_t candidateIndex = 0; candidateIndex < tokenCandidates.size(); ++candidateIndex) {
                    const std::string& tokenCandidate = tokenCandidates[candidateIndex];
                    if (crcRepositoryDetected &&
                        IsLowConfidenceMappingPathInCrcRepoMode(tokenCandidate)) {
                        ++skippedLowConfidenceContentCandidates;
                        continue;
                    }

                    BuildMappingPathVariants(tokenCandidate, tokenVariants);
                    for (size_t variantIndex = 0; variantIndex < tokenVariants.size(); ++variantIndex) {
                        const std::string& variantPath = tokenVariants[variantIndex];
                        const std::string canonicalVariantPath =
                            CanonicalizeMappingStoragePath(variantPath);
                        if (canonicalVariantPath.empty()) {
                            continue;
                        }

                        if (crcRepositoryDetected &&
                            IsLowConfidenceMappingPathInCrcRepoMode(canonicalVariantPath)) {
                            ++skippedLowConfidenceContentCandidates;
                            continue;
                        }

                        ++variantTriedAccumulator;
                        const uint32_t crc32 = PathMappingCRC32Adapter(0,
                                                                       variantPath.c_str(),
                                                                       variantPath.size());
                        if (!targetCrcSet.empty() &&
                            targetCrcSet.find(crc32) == targetCrcSet.end()) {
                            continue;
                        }
                        ++variantMatchedAccumulator;

                        if (mergedMapping.find(crc32) != mergedMapping.end()) {
                            continue;
                        }

                        const uint32_t voteWeight =
                            static_cast<uint32_t>((variantIndex < 8) ? (8 - variantIndex) : 1);
                        contentCandidateVotes[crc32][canonicalVariantPath] += voteWeight;
                    }
                }
            }
        };

    for (size_t dirIndex = 0; dirIndex < expandedDirs.GetCount(); ++dirIndex) {
        const wxString& referenceDir = expandedDirs[dirIndex];
        if (!wxDirExists(referenceDir)) {
            continue;
        }

        if (progressDlg) {
            const int progressValue = std::min<int>(92, static_cast<int>((dirIndex * 100) / expandedDirs.GetCount()));
            progressDlg->Update(progressValue,
                                wxString::Format(wxT("扫描参考目录 (%u/%u)\n%s"),
                                                 static_cast<unsigned int>(dirIndex + 1),
                                                 static_cast<unsigned int>(expandedDirs.GetCount()),
                                                 referenceDir.c_str()));
        }

        PathMappingGenerator scanGenerator;
        scanGenerator.SetCRC32Function(PathMappingCRC32Adapter);
        if (progressDlg) {
            scanGenerator.SetProgressCallback([progressDlg, referenceDir](uint32_t current,
                                                                          uint32_t total,
                                                                          const std::string& currentPath) {
                wxUnusedVar(total);
                if (current == 1 || current % 300 == 0) {
                    progressDlg->Pulse(wxString::Format(wxT("扫描中: %s\n%s"),
                                                        referenceDir.c_str(),
                                                        NativePathToWx(currentPath).c_str()));
                }
            });
        }

        const uint32_t scannedFiles = scanGenerator.ScanDirectory(WxToNativePath(referenceDir), options);
        if (scannedFiles == 0) {
            continue;
        }

        const std::string referenceDirNative = WxToNativePath(referenceDir);

        const PathMappingGenerator::ScanStats& scanStats = scanGenerator.GetStats();
        scannedFilesTotal += scanStats.totalFiles;
        scannedBytesTotal += scanStats.totalBytes;
        outStats.totalDirs += scanStats.totalDirs;
        if (outUsedDirs && outUsedDirs->Index(referenceDir) == wxNOT_FOUND) {
            outUsedDirs->Add(referenceDir);
        }

        const std::vector<PathMappingGenerator::PathEntry>& entries = scanGenerator.GetEntries();
        for (size_t entryIndex = 0; entryIndex < entries.size(); ++entryIndex) {
            const PathMappingGenerator::PathEntry& entry = entries[entryIndex];
            ++scanEntryTotal;
            const bool rootEntry = (entry.relativePath.find('/') == std::string::npos &&
                                    entry.relativePath.find('\\') == std::string::npos);
            if (rootEntry) {
                ++scanRootEntryTotal;
                if (IsNumericRootLikePath(entry.relativePath)) {
                    ++scanRootNumericTotal;
                }
            }

            if (!crcRepositoryDetected &&
                scanRootEntryTotal >= 2000 &&
                scanRootNumericTotal * 100 >= scanRootEntryTotal * 98 &&
                scanRootEntryTotal * 100 >= scanEntryTotal * 95) {
                crcRepositoryDetected = true;
            }

            const bool skipPathCandidatesFromEntry =
                crcRepositoryDetected && IsNumericRootLikePath(entry.relativePath);

            if (skipPathCandidatesFromEntry) {
                ++skippedNumericPathCandidateFiles;
            } else {
                BuildMappingPathVariants(entry.relativePath, variants);
                for (size_t variantIndex = 0; variantIndex < variants.size(); ++variantIndex) {
                    const std::string& variantPath = variants[variantIndex];
                    const std::string canonicalVariantPath =
                        CanonicalizeMappingStoragePath(variantPath);
                    if (canonicalVariantPath.empty()) {
                        continue;
                    }

                    if (crcRepositoryDetected &&
                        IsLowConfidenceMappingPathInCrcRepoMode(canonicalVariantPath)) {
                        ++skippedLowConfidenceContentCandidates;
                        continue;
                    }

                    ++variantTried;
                    const uint32_t crc32 = PathMappingCRC32Adapter(0,
                                                                   variantPath.c_str(),
                                                                   variantPath.size());
                    if (!targetCrcSet.empty() &&
                        targetCrcSet.find(crc32) == targetCrcSet.end()) {
                        continue;
                    }
                    ++variantMatchedTarget;

                    if (mergedMapping.find(crc32) != mergedMapping.end()) {
                        continue;
                    }

                    std::map<uint32_t, std::string>::iterator existingCandidate =
                        generatedCandidates.find(crc32);
                    if (existingCandidate == generatedCandidates.end()) {
                        generatedCandidates[crc32] = canonicalVariantPath;
                        generatedVariantRank[crc32] = variantIndex;
                        continue;
                    }

                    const size_t oldRank = generatedVariantRank[crc32];
                    const bool preferNew = (variantIndex < oldRank) ||
                                           (variantIndex == oldRank &&
                                            canonicalVariantPath.size() < existingCandidate->second.size());
                    if (preferNew) {
                        existingCandidate->second = canonicalVariantPath;
                        generatedVariantRank[crc32] = variantIndex;
                    } else {
                        ++candidateConflictCount;
                    }
                }
            }

            if (contentScanBudgetRemain == 0 ||
                !ShouldAnalyzeFileContentForMapping(entry.relativePath, entry.fileSize)) {
                continue;
            }

            const size_t readLimit = static_cast<size_t>(std::min<uint64_t>(
                static_cast<uint64_t>(kContentScanPerFileLimit), contentScanBudgetRemain));
            uint64_t fileSize = 0;
            size_t readBytes = 0;
            if (!ReadFileSampleBytes(JoinNativePath(referenceDirNative, entry.relativePath),
                                     readLimit,
                                     fileSampleBytes,
                                     fileSize,
                                     readBytes)) {
                continue;
            }
            if (readBytes == 0) {
                continue;
            }

            contentScanBudgetRemain -= static_cast<uint64_t>(readBytes);
            contentScanBytes += static_cast<uint64_t>(readBytes);
            ++contentScanFiles;

            if (progressDlg && (contentScanFiles == 1 || contentScanFiles % 120 == 0)) {
                progressDlg->Pulse(wxString::Format(
                    wxT("内容分析中: %s\n已分析文件 %u，已读 %.2f MB"),
                    referenceDir.c_str(),
                    contentScanFiles,
                    static_cast<double>(contentScanBytes) / (1024.0 * 1024.0)));
            }

            const std::string entryDir = GetDirectoryPart(entry.relativePath);
            collectTokenVotesFromBytes(fileSampleBytes,
                                       entryDir,
                                       contentTokenCount,
                                       contentVariantTried,
                                       contentVariantMatchedTarget);
        }
    }

    if (m_unpacker &&
        totalFileCount > 0 &&
        !m_currentInputDir.empty() &&
        decryptedContentScanBudgetRemain > 0) {
        UnpackOptions probeOptions;
        BuildUnpackOptions(probeOptions, false);
        probeOptions.threadCount = 1;
        probeOptions.useStreamMode = false;
        m_unpacker->ConfigureSession(m_currentInputDir, m_currentOutputDir, probeOptions);

        const std::vector<FileInfo>& files = m_unpacker->GetFileList();
        for (size_t fileIndex = 0; fileIndex < files.size(); ++fileIndex) {
            if (decryptedContentScanBudgetRemain == 0) {
                break;
            }

            const FileInfo& fileInfo = files[fileIndex];
            const bool hasMappedPath = m_unpacker->HasPathMappingForFile(fileIndex);
            const std::string logicalPath = m_unpacker->GetFilePath(fileIndex);
            const uint64_t originalSize = (fileInfo.m_SizeOriginal > 0)
                ? static_cast<uint64_t>(fileInfo.m_SizeOriginal)
                : static_cast<uint64_t>(fileInfo.m_Size);

            bool shouldProbeFile = false;
            if (hasMappedPath) {
                shouldProbeFile = ShouldAnalyzeFileContentForMapping(logicalPath, originalSize);
            } else if (originalSize > 0 && originalSize <= 256ULL * 1024ULL) {
                shouldProbeFile = (fileInfo.m_CodeType > 0 || fileInfo.m_CompressType > 0);
            }

            if (!shouldProbeFile) {
                continue;
            }

            decodedBytes.clear();
            std::string decodedLogicalPath;
            const int decodeResult = m_unpacker->ReadDecodedFileSample(
                fileIndex,
                kDecryptedContentPerFileLimit,
                decodedBytes,
                &decodedLogicalPath);
            if (decodeResult != LJFP_SUCCESS || decodedBytes.empty()) {
                ++decryptedContentDecodeFailures;
                continue;
            }

            const size_t sampleBytes = static_cast<size_t>(std::min<uint64_t>(
                static_cast<uint64_t>(decodedBytes.size()),
                std::min<uint64_t>(static_cast<uint64_t>(kDecryptedContentPerFileLimit),
                                   decryptedContentScanBudgetRemain)));
            if (sampleBytes == 0) {
                break;
            }

            if (decodedBytes.size() > sampleBytes) {
                decodedBytes.resize(sampleBytes);
            }

            const std::string analysisPath = decodedLogicalPath.empty() ? logicalPath : decodedLogicalPath;
            if (!ShouldAnalyzeDecodedContentForMapping(analysisPath, decodedBytes)) {
                continue;
            }

            decryptedContentScanBudgetRemain -= static_cast<uint64_t>(decodedBytes.size());
            decryptedContentScanBytes += static_cast<uint64_t>(decodedBytes.size());
            ++decryptedContentScanFiles;

            if (progressDlg &&
                (decryptedContentScanFiles == 1 || decryptedContentScanFiles % 80 == 0)) {
                progressDlg->Pulse(wxString::Format(
                    wxT("解密后语义分析中\n已分析文件 %u，已读 %.2f MB"),
                    decryptedContentScanFiles,
                    static_cast<double>(decryptedContentScanBytes) / (1024.0 * 1024.0)));
            }

            collectTokenVotesFromBytes(decodedBytes,
                                       hasMappedPath ? GetDirectoryPart(analysisPath) : std::string(),
                                       decryptedContentTokenCount,
                                       decryptedContentVariantTried,
                                       decryptedContentVariantMatchedTarget);
        }
    }

    if (!crcRepositoryDetected &&
        scanRootEntryTotal > 0 &&
        scanRootNumericTotal * 100 >= scanRootEntryTotal * 98 &&
        scanRootEntryTotal * 100 >= std::max<uint32_t>(scanEntryTotal, 1u) * 95) {
        crcRepositoryDetected = true;
    }

    for (std::map<uint32_t, std::string>::const_iterator it = existingMappingNormalized.begin();
         it != existingMappingNormalized.end();
         ++it) {
        if (crcRepositoryDetected &&
            IsLowConfidenceMappingPathInCrcRepoMode(it->second)) {
            ++existingMappingDroppedLowConfidenceCount;
            continue;
        }
        mergedMapping[it->first] = it->second;
        ++existingMappingKeptCount;
    }

    for (std::map<uint32_t, std::string>::const_iterator it = generatedCandidates.begin();
         it != generatedCandidates.end();
         ++it) {
        if (mergedMapping.insert(*it).second) {
            ++generatedPathAddedCount;
            ++mergedAddedCount;
        }
    }

    for (std::map<uint32_t, std::map<std::string, uint32_t> >::const_iterator it = contentCandidateVotes.begin();
         it != contentCandidateVotes.end();
         ++it) {
        const uint32_t crc32 = it->first;
        if (mergedMapping.find(crc32) != mergedMapping.end()) {
            continue;
        }

        const std::map<std::string, uint32_t>& votes = it->second;
        if (votes.empty()) {
            continue;
        }

        std::string bestPath;
        uint32_t bestScore = 0;
        uint32_t bestCount = 0;
        for (std::map<std::string, uint32_t>::const_iterator voteIt = votes.begin();
             voteIt != votes.end();
             ++voteIt) {
            if (voteIt->second > bestScore) {
                bestPath = voteIt->first;
                bestScore = voteIt->second;
                bestCount = 1;
            } else if (voteIt->second == bestScore) {
                ++bestCount;
                if (bestPath.empty() || voteIt->first.size() < bestPath.size()) {
                    bestPath = voteIt->first;
                }
            }
        }

        if (bestPath.empty()) {
            continue;
        }

        // 保守策略：并列第一时视为歧义，不自动写入，避免污染映射。
        if (bestCount > 1) {
            ++contentAmbiguousCount;
            continue;
        }

        if (mergedMapping.insert(std::make_pair(crc32, bestPath)).second) {
            ++contentAddedCount;
            ++mergedAddedCount;
        }
    }

    uint32_t rootNumericRatioBasis = 0;
    if (scanRootEntryTotal > 0) {
        rootNumericRatioBasis = static_cast<uint32_t>(
            (static_cast<uint64_t>(scanRootNumericTotal) * 10000ULL) / scanRootEntryTotal);
    }

    const std::chrono::high_resolution_clock::time_point endTime =
        std::chrono::high_resolution_clock::now();
    outStats.scanTimeMs = std::chrono::duration<double, std::milli>(endTime - startTime).count();
    outStats.totalFiles = scannedFilesTotal;
    outStats.totalBytes = scannedBytesTotal;
    outStats.collisions = candidateConflictCount + contentAmbiguousCount;
    outUniqueMappings = static_cast<uint32_t>(mergedMapping.size());

    const std::string outputNativePath = WxToNativePath(outputPath);
    uint32_t coveredAfter = 0;
    uint32_t coveredAfterSaved = 0;
    uint32_t savedMappingLoadedCount = 0;
    int savedMappingReloadResult = LJFP_SUCCESS;
    int saveResult = LJFP_SUCCESS;
    uint32_t finalUniqueMappingCount = static_cast<uint32_t>(mergedMapping.size());
    std::vector<uint32_t> missingSamplesAfter;
    ManifestSeedEnrichmentResult manifestSeedResult;
    SourceTemplateSeedEnrichmentResult sourceTemplateSeedResult;
    auto writeCoverageReport = [&]() {
        std::ofstream coverageOut((outputNativePath + ".coverage.txt").c_str(), std::ios::out);
        if (!coverageOut.is_open()) {
            return;
        }

        coverageOut << "# Auto mapping coverage report\n";
        coverageOut << "expanded_reference_dirs=" << expandedDirs.GetCount() << "\n";
        coverageOut << "scanned_files=" << scannedFilesTotal << "\n";
        coverageOut << "scanned_bytes=" << scannedBytesTotal << "\n";
        coverageOut << "scan_entries_total=" << scanEntryTotal << "\n";
        coverageOut << "scan_root_entries=" << scanRootEntryTotal << "\n";
        coverageOut << "scan_root_numeric_entries=" << scanRootNumericTotal << "\n";
        coverageOut << "scan_root_numeric_ratio_basis=" << rootNumericRatioBasis << "\n";
        coverageOut << "crc_repository_detected=" << (crcRepositoryDetected ? 1 : 0) << "\n";
        coverageOut << "variants_tried=" << variantTried << "\n";
        coverageOut << "variants_matched_target=" << variantMatchedTarget << "\n";
        coverageOut << "candidate_conflicts=" << candidateConflictCount << "\n";
        coverageOut << "skipped_numeric_path_candidate_files=" << skippedNumericPathCandidateFiles << "\n";
        coverageOut << "skipped_low_confidence_candidates=" << skippedLowConfidenceContentCandidates << "\n";
        coverageOut << "content_scan_budget_bytes=" << kContentScanBudgetBytes << "\n";
        coverageOut << "content_scan_budget_used=" << contentScanBytes << "\n";
        coverageOut << "content_scan_files=" << contentScanFiles << "\n";
        coverageOut << "content_tokens=" << contentTokenCount << "\n";
        coverageOut << "content_variants_tried=" << contentVariantTried << "\n";
        coverageOut << "content_variants_matched_target=" << contentVariantMatchedTarget << "\n";
        coverageOut << "content_ambiguous_crc=" << contentAmbiguousCount << "\n";
        coverageOut << "existing_mapping_entries_raw=" << existingMappingRawCount << "\n";
        coverageOut << "existing_mapping_entries_kept=" << existingMappingKeptCount << "\n";
        coverageOut << "existing_mapping_entries_dropped_low_confidence="
                    << existingMappingDroppedLowConfidenceCount << "\n";
        coverageOut << "nearby_seed_mapping_files=" << nearbySeedFileCount << "\n";
        coverageOut << "nearby_seed_mapping_files_merged=" << nearbySeedMergedFileCount << "\n";
        coverageOut << "nearby_seed_mapping_files_isolated=" << nearbySeedIsolatedFileCount << "\n";
        coverageOut << "nearby_seed_mapping_entries_raw=" << nearbySeedRawEntryCount << "\n";
        coverageOut << "nearby_seed_mapping_entries_merged=" << nearbySeedMergedEntryCount << "\n";
        coverageOut << "generated_path_entries=" << generatedPathAddedCount << "\n";
        coverageOut << "generated_content_entries=" << contentAddedCount << "\n";
        coverageOut << "generated_new_entries=" << mergedAddedCount << "\n";
        coverageOut << "decrypted_content_scan_budget_bytes=" << kDecryptedContentScanBudgetBytes << "\n";
        coverageOut << "decrypted_content_scan_budget_used=" << decryptedContentScanBytes << "\n";
        coverageOut << "decrypted_content_scan_files=" << decryptedContentScanFiles << "\n";
        coverageOut << "decrypted_content_tokens=" << decryptedContentTokenCount << "\n";
        coverageOut << "decrypted_content_variants_tried=" << decryptedContentVariantTried << "\n";
        coverageOut << "decrypted_content_variants_matched_target=" << decryptedContentVariantMatchedTarget << "\n";
        coverageOut << "decrypted_content_decode_failures=" << decryptedContentDecodeFailures << "\n";
        coverageOut << "final_unique_entries=" << finalUniqueMappingCount << "\n";
        coverageOut << "target_file_count=" << totalFileCount << "\n";
        coverageOut << "covered_before=" << existingCoveredCount << "\n";
        coverageOut << "covered_after=" << coveredAfter << "\n";
        coverageOut << "saved_mapping_reload_result=" << savedMappingReloadResult << "\n";
        coverageOut << "saved_mapping_entries_loaded=" << savedMappingLoadedCount << "\n";
        coverageOut << "saved_mapping_covered_after=" << coveredAfterSaved << "\n";
        coverageOut << "saved_mapping_drift=" << (coveredAfter >= coveredAfterSaved
            ? (coveredAfter - coveredAfterSaved)
            : (coveredAfterSaved - coveredAfter)) << "\n";
        coverageOut << "missing_after=" << (totalFileCount > coveredAfter ? (totalFileCount - coveredAfter) : 0) << "\n";
        coverageOut << "manifest_seed_attempted=" << (manifestSeedResult.attempted ? 1 : 0) << "\n";
        coverageOut << "manifest_seed_executed=" << (manifestSeedResult.executed ? 1 : 0) << "\n";
        coverageOut << "manifest_seed_promoted=" << (manifestSeedResult.promoted ? 1 : 0) << "\n";
        coverageOut << "manifest_seed_failed=" << (manifestSeedResult.failed ? 1 : 0) << "\n";
        coverageOut << "manifest_seed_exit_code=" << manifestSeedResult.exitCode << "\n";
        coverageOut << "manifest_seed_existing_hits=" << manifestSeedResult.existingHits << "\n";
        coverageOut << "manifest_seed_merged_hits=" << manifestSeedResult.mergedHits << "\n";
        coverageOut << "manifest_seed_hit_gain=" << manifestSeedResult.hitGain << "\n";
        coverageOut << "manifest_seed_new_hits=" << manifestSeedResult.newHits << "\n";
        coverageOut << "manifest_seed_conflicts=" << manifestSeedResult.mappingConflicts << "\n";
        coverageOut << "manifest_seed_filtered=" << manifestSeedResult.filteredEntries << "\n";
        coverageOut << "manifest_seed_merged_entries=" << manifestSeedResult.mergedEntries << "\n";
        coverageOut << "source_template_attempted=" << (sourceTemplateSeedResult.attempted ? 1 : 0) << "\n";
        coverageOut << "source_template_executed=" << (sourceTemplateSeedResult.executed ? 1 : 0) << "\n";
        coverageOut << "source_template_promoted=" << (sourceTemplateSeedResult.promoted ? 1 : 0) << "\n";
        coverageOut << "source_template_failed=" << (sourceTemplateSeedResult.failed ? 1 : 0) << "\n";
        coverageOut << "source_template_exit_code=" << sourceTemplateSeedResult.exitCode << "\n";
        coverageOut << "source_template_direct_hits=" << sourceTemplateSeedResult.directHits << "\n";
        coverageOut << "source_template_existing_hits=" << sourceTemplateSeedResult.existingHits << "\n";
        coverageOut << "source_template_merged_hits=" << sourceTemplateSeedResult.mergedHits << "\n";
        coverageOut << "source_template_hit_gain=" << sourceTemplateSeedResult.hitGain << "\n";
        coverageOut << "source_template_new_hits=" << sourceTemplateSeedResult.newHits << "\n";
        coverageOut << "source_template_mapping_conflicts=" << sourceTemplateSeedResult.mappingConflicts << "\n";
        coverageOut << "source_template_seed_conflicts=" << sourceTemplateSeedResult.seedConflicts << "\n";
        coverageOut << "\n";
        coverageOut << "[reference_dirs]\n";
        for (size_t i = 0; i < expandedDirs.GetCount(); ++i) {
            coverageOut << "- " << WxToNativePath(expandedDirs[i]) << "\n";
        }
        if (!nearbySeedSearchDirs.IsEmpty()) {
            coverageOut << "\n[nearby_seed_search_dirs]\n";
            for (size_t i = 0; i < nearbySeedSearchDirs.GetCount(); ++i) {
                coverageOut << "- " << WxToNativePath(nearbySeedSearchDirs[i]) << "\n";
            }
        }
        if (!nearbySeedCandidates.empty()) {
            coverageOut << "\n[nearby_seed_mapping_files]\n";
            for (size_t i = 0; i < nearbySeedCandidates.size(); ++i) {
                coverageOut << "- " << WxToNativePath(nearbySeedCandidates[i].filePath)
                            << " | hits=" << nearbySeedCandidates[i].hitCount
                            << " | entries=" << nearbySeedCandidates[i].mappingCount
                            << " | score=" << nearbySeedCandidates[i].qualityScoreBasis
                            << " | hit_rate_basis=" << nearbySeedCandidates[i].hitRateBasis
                            << " | clean_rate_basis=" << nearbySeedCandidates[i].cleanRateBasis
                            << " | avg_path_quality_basis=" << nearbySeedCandidates[i].avgPathQualityBasis
                            << " | isolated=" << (nearbySeedCandidates[i].isolated ? 1 : 0);
                if (nearbySeedCandidates[i].isolated &&
                    !nearbySeedCandidates[i].isolationReason.empty()) {
                    coverageOut << " | reason=" << nearbySeedCandidates[i].isolationReason;
                }
                coverageOut << "\n";
            }
        }
        if (!nearbySeedCandidates.empty()) {
            coverageOut << "\n[isolated_seed_mapping_files]\n";
            for (size_t i = 0; i < nearbySeedCandidates.size(); ++i) {
                if (!nearbySeedCandidates[i].isolated) {
                    continue;
                }
                coverageOut << "- " << WxToNativePath(nearbySeedCandidates[i].filePath)
                            << " | reason=" << nearbySeedCandidates[i].isolationReason << "\n";
            }
        }
        if (!missingSamplesAfter.empty()) {
            coverageOut << "\n[missing_crc32_samples]\n";
            for (size_t i = 0; i < missingSamplesAfter.size(); ++i) {
                coverageOut << "0x" << std::hex << std::uppercase << missingSamplesAfter[i]
                            << std::nouppercase << std::dec << "\n";
            }
        }
        if (manifestSeedResult.attempted) {
            coverageOut << "\n[manifest_seed_enrichment]\n";
            if (!manifestSeedResult.manifestRoot.IsEmpty()) {
                coverageOut << "manifest_root=" << WxToNativePath(manifestSeedResult.manifestRoot) << "\n";
            }
            if (!manifestSeedResult.scriptPath.IsEmpty()) {
                coverageOut << "script_path=" << WxToNativePath(manifestSeedResult.scriptPath) << "\n";
            }
            if (!manifestSeedResult.pythonLauncher.IsEmpty()) {
                coverageOut << "python_launcher=" << WxToNativePath(manifestSeedResult.pythonLauncher) << "\n";
            }
            if (!manifestSeedResult.reportDir.IsEmpty()) {
                coverageOut << "report_dir=" << WxToNativePath(manifestSeedResult.reportDir) << "\n";
            }
            if (!manifestSeedResult.promoteDir.IsEmpty()) {
                coverageOut << "promote_dir=" << WxToNativePath(manifestSeedResult.promoteDir) << "\n";
            }
            if (!manifestSeedResult.summaryPath.IsEmpty()) {
                coverageOut << "summary_path=" << WxToNativePath(manifestSeedResult.summaryPath) << "\n";
            }
            if (!manifestSeedResult.message.IsEmpty()) {
                coverageOut << "message=" << WxToNativePath(manifestSeedResult.message) << "\n";
            }
        }
        if (sourceTemplateSeedResult.attempted) {
            coverageOut << "\n[source_template_seed_enrichment]\n";
            if (!sourceTemplateSeedResult.scriptPath.IsEmpty()) {
                coverageOut << "script_path=" << WxToNativePath(sourceTemplateSeedResult.scriptPath) << "\n";
            }
            if (!sourceTemplateSeedResult.pythonLauncher.IsEmpty()) {
                coverageOut << "python_launcher=" << WxToNativePath(sourceTemplateSeedResult.pythonLauncher) << "\n";
            }
            if (!sourceTemplateSeedResult.reportDir.IsEmpty()) {
                coverageOut << "report_dir=" << WxToNativePath(sourceTemplateSeedResult.reportDir) << "\n";
            }
            if (!sourceTemplateSeedResult.promoteDir.IsEmpty()) {
                coverageOut << "promote_dir=" << WxToNativePath(sourceTemplateSeedResult.promoteDir) << "\n";
            }
            if (!sourceTemplateSeedResult.summaryPath.IsEmpty()) {
                coverageOut << "summary_path=" << WxToNativePath(sourceTemplateSeedResult.summaryPath) << "\n";
            }
            if (!sourceTemplateSeedResult.targetCrcFile.IsEmpty()) {
                coverageOut << "target_crc_file=" << WxToNativePath(sourceTemplateSeedResult.targetCrcFile) << "\n";
            }
            if (!sourceTemplateSeedResult.scanRoots.IsEmpty()) {
                coverageOut << "scan_roots=" << sourceTemplateSeedResult.scanRoots.GetCount() << "\n";
                for (size_t i = 0; i < sourceTemplateSeedResult.scanRoots.GetCount(); ++i) {
                    coverageOut << "-scan_root=" << WxToNativePath(sourceTemplateSeedResult.scanRoots[i]) << "\n";
                }
            }
            if (!sourceTemplateSeedResult.mapConfigInputs.IsEmpty()) {
                coverageOut << "map_config_inputs=" << sourceTemplateSeedResult.mapConfigInputs.GetCount() << "\n";
                for (size_t i = 0; i < sourceTemplateSeedResult.mapConfigInputs.GetCount(); ++i) {
                    coverageOut << "-map_config_bin=" << WxToNativePath(sourceTemplateSeedResult.mapConfigInputs[i]) << "\n";
                }
            }
            if (!sourceTemplateSeedResult.message.IsEmpty()) {
                coverageOut << "message=" << WxToNativePath(sourceTemplateSeedResult.message) << "\n";
            }
        }
        coverageOut.close();
    };

    if (outUniqueMappings == 0) {
        saveResult = LJFP_ERROR_INVALID_INDEX;
        writeCoverageReport();
        if (progressDlg) {
            delete progressDlg;
        }
        return false;
    }

    PathMappingGenerator mergedGenerator;
    mergedGenerator.SetCRC32Function(PathMappingCRC32Adapter);
    for (std::map<uint32_t, std::string>::const_iterator it = mergedMapping.begin();
         it != mergedMapping.end();
         ++it) {
        mergedGenerator.AddPathWithCRC(it->second, it->first);
    }

    if (progressDlg) {
        progressDlg->Update(96, wxT("正在保存路径映射..."));
    }

    wxString standardTextPath;
    wxString standardBinaryPath;
    BuildStandardMappingArtifactPaths(outputPath, standardTextPath, standardBinaryPath);

    saveResult = mergedGenerator.SaveMapping(WxToNativePath(standardTextPath), true);
    if (saveResult == LJFP_SUCCESS) {
        saveResult = mergedGenerator.SaveMappingBinary(WxToNativePath(standardBinaryPath));
    }
    if (saveResult == LJFP_SUCCESS &&
        !SamePathIgnoreCase(outputPath, standardTextPath) &&
        !SamePathIgnoreCase(outputPath, standardBinaryPath)) {
        saveResult = isBinary
            ? mergedGenerator.SaveMappingBinary(outputNativePath)
            : mergedGenerator.SaveMapping(outputNativePath, true);
    }

    if (m_unpacker && totalFileCount > 0) {
        const std::vector<FileInfo>& files = m_unpacker->GetFileList();
        missingSamplesAfter.reserve(16);
        for (size_t i = 0; i < files.size(); ++i) {
            const uint32_t crc32 = files[i].m_PathFileNameCRC32;
            if (mergedMapping.find(crc32) != mergedMapping.end()) {
                ++coveredAfter;
            } else if (missingSamplesAfter.size() < 16) {
                missingSamplesAfter.push_back(crc32);
            }
        }
    }

    if (saveResult == LJFP_SUCCESS && m_unpacker && totalFileCount > 0) {
        std::map<uint32_t, std::string> verifyMappingTable;
        if (LoadNormalizedMappingSeed(standardBinaryPath, verifyMappingTable)) {
            savedMappingReloadResult = LJFP_SUCCESS;
            savedMappingLoadedCount = static_cast<uint32_t>(verifyMappingTable.size());
            finalUniqueMappingCount = savedMappingLoadedCount;
            const std::vector<FileInfo>& files = m_unpacker->GetFileList();
            for (size_t i = 0; i < files.size(); ++i) {
                if (verifyMappingTable.find(files[i].m_PathFileNameCRC32) !=
                    verifyMappingTable.end()) {
                    ++coveredAfterSaved;
                }
            }
            if (coveredAfterSaved < coveredAfter) {
                saveResult = LJFP_ERROR_INVALID_INDEX;
            }
        } else {
            savedMappingReloadResult = LJFP_ERROR_INVALID_INDEX;
            saveResult = savedMappingReloadResult;
        }
    }

    if (saveResult == LJFP_SUCCESS) {
        manifestSeedResult = RunManifestSeedEnrichment(referenceDirs,
                                                       standardTextPath,
                                                       standardBinaryPath,
                                                       outputPath,
                                                       isBinary);
        if (manifestSeedResult.promoted) {
            coveredAfter = 0;
            coveredAfterSaved = 0;
            savedMappingLoadedCount = 0;
            missingSamplesAfter.clear();

            std::map<uint32_t, std::string> promotedMappingTable;
            if (LoadNormalizedMappingSeed(standardBinaryPath, promotedMappingTable)) {
                savedMappingReloadResult = LJFP_SUCCESS;
                savedMappingLoadedCount = static_cast<uint32_t>(promotedMappingTable.size());
                finalUniqueMappingCount = savedMappingLoadedCount;
                const std::vector<FileInfo>& files = m_unpacker->GetFileList();
                for (size_t i = 0; i < files.size(); ++i) {
                    const uint32_t crc32 = files[i].m_PathFileNameCRC32;
                    if (promotedMappingTable.find(crc32) != promotedMappingTable.end()) {
                        ++coveredAfter;
                        ++coveredAfterSaved;
                    } else if (missingSamplesAfter.size() < 16) {
                        missingSamplesAfter.push_back(crc32);
                    }
                }
                outUniqueMappings = savedMappingLoadedCount;
            } else {
                savedMappingReloadResult = LJFP_ERROR_INVALID_INDEX;
                saveResult = savedMappingReloadResult;
                manifestSeedResult.failed = true;
                manifestSeedResult.promoted = false;
                manifestSeedResult.message += wxT(" 但回读提升后的标准映射失败。");
            }
        }

        if (manifestSeedResult.promoted) {
            AppendSessionLog(wxString::Format(
                wxT("txt manifest 补种已接入：根目录 %s，新增 %u 条，命中 %u -> %u"),
                manifestSeedResult.manifestRoot.c_str(),
                manifestSeedResult.newHits,
                manifestSeedResult.existingHits,
                manifestSeedResult.mergedHits));
        } else if (!manifestSeedResult.message.IsEmpty()) {
            AppendSessionLog(wxT("txt manifest 补种结果：") + manifestSeedResult.message);
        }

        sourceTemplateSeedResult = RunSourceTemplateSeedEnrichment(referenceDirs,
                                                                   NativePathToWx(m_currentInputDir),
                                                                   targetCrcSet,
                                                                   standardTextPath,
                                                                   standardBinaryPath,
                                                                   outputPath,
                                                                   isBinary);
        if (sourceTemplateSeedResult.promoted) {
            coveredAfter = 0;
            coveredAfterSaved = 0;
            savedMappingLoadedCount = 0;
            missingSamplesAfter.clear();

            std::map<uint32_t, std::string> promotedMappingTable;
            if (LoadNormalizedMappingSeed(standardBinaryPath, promotedMappingTable)) {
                savedMappingReloadResult = LJFP_SUCCESS;
                savedMappingLoadedCount = static_cast<uint32_t>(promotedMappingTable.size());
                finalUniqueMappingCount = savedMappingLoadedCount;
                const std::vector<FileInfo>& files = m_unpacker->GetFileList();
                for (size_t i = 0; i < files.size(); ++i) {
                    const uint32_t crc32 = files[i].m_PathFileNameCRC32;
                    if (promotedMappingTable.find(crc32) != promotedMappingTable.end()) {
                        ++coveredAfter;
                        ++coveredAfterSaved;
                    } else if (missingSamplesAfter.size() < 16) {
                        missingSamplesAfter.push_back(crc32);
                    }
                }
                outUniqueMappings = savedMappingLoadedCount;
            } else {
                savedMappingReloadResult = LJFP_ERROR_INVALID_INDEX;
                saveResult = savedMappingReloadResult;
                sourceTemplateSeedResult.failed = true;
                sourceTemplateSeedResult.promoted = false;
                sourceTemplateSeedResult.message += wxT(" 但回读提升后的标准映射失败。");
            }
        }

        if (sourceTemplateSeedResult.promoted) {
            AppendSessionLog(wxString::Format(
                wxT("源码模板补种已接入：直接命中 %u 条，新增 %u 条，命中 %u -> %u"),
                sourceTemplateSeedResult.directHits,
                sourceTemplateSeedResult.newHits,
                sourceTemplateSeedResult.existingHits,
                sourceTemplateSeedResult.mergedHits));
        } else if (!sourceTemplateSeedResult.message.IsEmpty()) {
            AppendSessionLog(wxT("源码模板补种结果：") + sourceTemplateSeedResult.message);
        }
    }

    writeCoverageReport();

    if (progressDlg) {
        wxString doneMessage = (saveResult == LJFP_SUCCESS)
            ? wxString::Format(wxT("路径映射已生成（新增 %u 条：路径 %u / 内容推断 %u）"),
                               mergedAddedCount,
                               generatedPathAddedCount,
                               contentAddedCount)
            : wxString::Format(wxT("保存失败，错误码: %d"), saveResult);
        if (saveResult == LJFP_SUCCESS && coveredAfterSaved > 0) {
            doneMessage += wxString::Format(wxT("，落盘复检命中 %u/%u"),
                                            coveredAfterSaved,
                                            totalFileCount);
        }
        if (saveResult == LJFP_SUCCESS && crcRepositoryDetected) {
            doneMessage += wxT("，已启用 CRC 仓保守策略");
        }
        if (saveResult == LJFP_SUCCESS && nearbySeedFileCount > 0) {
            doneMessage += wxString::Format(wxT("，已合并 %u 份附近映射种子"), nearbySeedFileCount);
        }
        if (saveResult == LJFP_SUCCESS && manifestSeedResult.promoted) {
            doneMessage += wxString::Format(wxT("，txt manifest 补种 +%u（命中 %u/%u）"),
                                            manifestSeedResult.hitGain,
                                            coveredAfterSaved,
                                            totalFileCount);
        }
        if (saveResult == LJFP_SUCCESS && sourceTemplateSeedResult.promoted) {
            doneMessage += wxString::Format(wxT("，源码模板补种 +%u（命中 %u/%u）"),
                                            sourceTemplateSeedResult.hitGain,
                                            coveredAfterSaved,
                                            totalFileCount);
        }
        progressDlg->Update(100, doneMessage);
        delete progressDlg;
    }

    return saveResult == LJFP_SUCCESS;
}

bool MainFrame::TryGenerateMergedMappingFromReferenceDirs(const wxArrayString& referenceDirs,
                                                          wxString& outMappingPath,
                                                          wxArrayString* outUsedDirs) {
    outMappingPath.clear();

    wxString outputDir = NativePathToWx(m_currentInputDir);
    if (outputDir.IsEmpty()) {
        wxFileName indexFile(m_currentIndexPath);
        outputDir = indexFile.GetPath();
    }
    if (outputDir.IsEmpty()) {
        outputDir = wxFileName::GetCwd();
    }

    wxFileName outputFile(outputDir, wxT("path_mapping.ljpm"));
    outMappingPath = outputFile.GetFullPath();

    PathMappingGenerator::ScanStats stats;
    uint32_t uniqueMappings = 0;
    if (!GeneratePathMappingFromReferenceDirs(referenceDirs,
                                              outMappingPath,
                                              true,
                                              stats,
                                              uniqueMappings,
                                              outUsedDirs,
                                              true)) {
        outMappingPath.clear();
        return false;
    }

    m_lastGeneratedMappingFile = outMappingPath;
    return true;
}

bool MainFrame::EnsureUsablePathMapping(bool showHint) {
    if (!m_unpacker || !m_hasLoadedIndex) {
        if (showHint) {
            wxMessageBox(wxT("请先加载索引文件，再补全路径映射"),
                         wxT("提示"), wxOK | wxICON_INFORMATION, this);
        }
        return false;
    }

    uint32_t hit = 0;
    uint32_t total = 0;
    uint32_t rateBasis = 0;
    const bool mappingLoaded = (m_unpacker->GetPathMappingCount() > 0);
    const bool hasHitRate = mappingLoaded && m_unpacker->GetPathMappingHitRate(hit, total, rateBasis);
    const uint32_t beforeHit = hit;
    const uint32_t beforeTotal = total;
    const bool mappingHealthy = mappingLoaded && (!hasHitRate || total == 0 || hit == total || rateBasis >= 9500);

    if (mappingHealthy) {
        return true;
    }

    if (!showHint) {
        return false;
    }

    wxString prompt;
    if (!mappingLoaded) {
        prompt = wxT("当前尚未加载路径映射。\n是否尝试从索引附近的参考资源目录自动生成并立即加载标准 `path_mapping.ljpm`，同时同步导出 `path_mapping.txt`？");
    } else {
        prompt = wxString::Format(
            wxT("当前路径映射命中率为 %s (%u/%u)。\n仍有部分资源会回落到 CRC / 推断路径。\n是否尝试补全映射并同步导出标准 `path_mapping.txt/.ljpm`？"),
            FormatRateForUi(rateBasis).c_str(),
            hit,
            total);
    }

    const int choice = wxMessageBox(prompt,
                                    wxT("补全路径映射"),
                                    wxYES_NO | wxICON_QUESTION,
                                    this);
    if (choice != wxYES) {
        return false;
    }

    wxArrayString referenceDirs;
    if (!PromptForReferenceDirs(referenceDirs)) {
        return false;
    }

    wxString mappingPath;
    wxArrayString usedDirs;
    if (!TryGenerateMergedMappingFromReferenceDirs(referenceDirs, mappingPath, &usedDirs)) {
        wxMessageBox(wxT("未能从参考目录生成映射，请改用手动生成流程"),
                     wxT("提示"), wxOK | wxICON_WARNING, this);
        return false;
    }

    const int loadResult = m_unpacker->LoadPathMapping(WxToNativePath(mappingPath));
    if (loadResult != LJFP_SUCCESS) {
        wxMessageBox(wxString::Format(wxT("自动生成的映射加载失败，错误码: %d"), loadResult),
                     wxT("错误"), wxOK | wxICON_ERROR, this);
        return false;
    }

    AddMappingHistory(mappingPath);
    UpdateWorkflowStatus();
    RefreshResourceTree();
    RefreshFileList();
    UpdateStatusBar();

    uint32_t afterHit = 0;
    uint32_t afterTotal = 0;
    uint32_t afterRateBasis = 0;
    const bool hasAfterRate = m_unpacker->GetPathMappingHitRate(afterHit, afterTotal, afterRateBasis);

    wxString message = wxString::Format(wxT("已生成并加载路径映射：\n%s"), mappingPath.c_str());
    if (!usedDirs.IsEmpty()) {
        message += wxT("\n\n参考目录:\n");
        for (size_t i = 0; i < usedDirs.GetCount(); ++i) {
            message += wxT("• ") + usedDirs[i] + wxT("\n");
        }
    }
    if (hasAfterRate && afterTotal > 0) {
        message += wxString::Format(wxT("\n命中率: %s (%u/%u)"),
                                    FormatRateForUi(afterRateBasis).c_str(),
                                    afterHit,
                                    afterTotal);
        if (beforeTotal > 0) {
            const int32_t delta = static_cast<int32_t>(afterHit) - static_cast<int32_t>(beforeHit);
            message += wxString::Format(wxT("，较补全前提升 %+d"), delta);
        }
    }
    message += wxString::Format(wxT("\n\n覆盖率诊断: %s.coverage.txt"), mappingPath.c_str());

    wxMessageBox(message,
                 wxT("映射已就绪"),
                 wxOK | wxICON_INFORMATION,
                 this);
    return true;
}

bool MainFrame::TryAutoLoadMapping(const wxString& directoryPath, const wxString& indexFileName) {
    if (!m_autoLoadMappingCheck || !m_autoLoadMappingCheck->GetValue()) {
        SLJFP_LOG_INFO(L"Auto-load mapping disabled in settings");
        return false;
    }
    if (m_unpacker->GetPathMappingCount() > 0) {
        SLJFP_LOG_INFO(L"Auto-load mapping skipped: mapping already loaded");
        return true;
    }

    if (directoryPath.IsEmpty()) {
        SLJFP_LOG_WARNING(L"Auto-load mapping skipped: empty directory path");
        return false;
    }

    wxArrayString candidateDirs;
    auto addCandidateDir = [&candidateDirs](const wxString& rawDir) {
        const wxString normalizedDir = NormalizeDirectoryPath(rawDir);
        if (normalizedDir.IsEmpty() || !wxDirExists(normalizedDir)) {
            return;
        }

        for (size_t i = 0; i < candidateDirs.GetCount(); ++i) {
            if (SamePathIgnoreCase(candidateDirs[i], normalizedDir)) {
                return;
            }
        }
        candidateDirs.Add(normalizedDir);
    };

    wxString searchDir = NormalizeDirectoryPath(directoryPath);
    for (int depth = 0; depth < 3 && !searchDir.IsEmpty(); ++depth) {
        addCandidateDir(searchDir);

        const wxString childNames[] = {
            wxT("mapping"),
            wxT("mappings")
        };
        for (size_t i = 0; i < sizeof(childNames) / sizeof(childNames[0]); ++i) {
            wxFileName childDir(searchDir, wxEmptyString);
            childDir.AppendDir(childNames[i]);
            addCandidateDir(childDir.GetFullPath());
        }

        searchDir = GetParentDirectoryPath(searchDir);
    }
    if (candidateDirs.IsEmpty()) {
        SLJFP_LOG_WARNING(L"Auto-load mapping skipped: no candidate directories");
        return false;
    }

    wxArrayString prefixes;
    if (m_mappingPrefixCtrl) {
        wxString raw = m_mappingPrefixCtrl->GetValue();
        wxStringTokenizer tokenizer(raw, wxT(",;| "));
        while (tokenizer.HasMoreTokens()) {
            wxString token = tokenizer.GetNextToken();
            token.Trim(true).Trim(false);
            if (!token.IsEmpty()) {
                prefixes.Add(token);
            }
        }
    }
    if (prefixes.IsEmpty()) {
        prefixes.Add(wxT("path_mapping"));
        prefixes.Add(wxT("mapping"));
    }

    wxArrayString candidatePaths;
    auto addCandidatePath = [&candidatePaths](const wxString& fullPath) {
        if (fullPath.IsEmpty()) {
            return;
        }
        wxFileName candidateFile(fullPath);
        candidateFile.Normalize(wxPATH_NORM_DOTS | wxPATH_NORM_ABSOLUTE);
        if (!candidateFile.FileExists()) {
            return;
        }
        const wxString normalized = candidateFile.GetFullPath();
        for (size_t i = 0; i < candidatePaths.GetCount(); ++i) {
            if (SamePathIgnoreCase(candidatePaths[i], normalized)) {
                return;
            }
        }
        candidatePaths.Add(normalized);
    };

    // 优先尝试最近记录
    if (!m_lastGeneratedMappingFile.IsEmpty()) {
        wxFileName lastGenerated(m_lastGeneratedMappingFile);
        if (lastGenerated.FileExists()) {
            addCandidatePath(lastGenerated.GetFullPath());
            addCandidateDir(lastGenerated.GetPath());
        }
    }
    if (!m_lastMappingFile.IsEmpty()) {
        wxFileName lastLoaded(m_lastMappingFile);
        if (lastLoaded.FileExists()) {
            addCandidatePath(lastLoaded.GetFullPath());
            addCandidateDir(lastLoaded.GetPath());
        }
    }

    wxArrayString candidateNames;
    auto addCandidateName = [&candidateNames](const wxString& name) {
        if (name.IsEmpty()) {
            return;
        }
        if (candidateNames.Index(name) == wxNOT_FOUND) {
            candidateNames.Add(name);
        }
    };

    const wxString extensions[] = { wxT(".ljpm"), wxT(".txt"), wxT(".map") };

    if (!indexFileName.IsEmpty()) {
        wxFileName indexFile(indexFileName);
        wxString baseName = indexFile.GetName();
        if (!baseName.IsEmpty()) {
            for (const auto& ext : extensions) {
                addCandidateName(baseName + ext);
            }
        }
    }
    for (const auto& prefix : prefixes) {
        bool hasExt = prefix.Lower().EndsWith(wxT(".ljpm")) ||
                      prefix.Lower().EndsWith(wxT(".txt")) ||
                      prefix.Lower().EndsWith(wxT(".map"));
        if (hasExt) {
            addCandidateName(prefix);
        } else {
            for (const auto& ext : extensions) {
                addCandidateName(prefix + ext);
            }
        }
    }

    if (candidateNames.IsEmpty()) {
        SLJFP_LOG_WARNING(L"Auto-load mapping skipped: no candidate names generated");
        return false;
    }

    for (size_t dirIndex = 0; dirIndex < candidateDirs.GetCount(); ++dirIndex) {
        for (size_t nameIndex = 0; nameIndex < candidateNames.GetCount(); ++nameIndex) {
            wxFileName mappingFile(candidateDirs[dirIndex], candidateNames[nameIndex]);
            addCandidatePath(mappingFile.GetFullPath());
        }
    }

    if (candidatePaths.IsEmpty()) {
        SLJFP_LOG_INFO(L"Auto-load mapping: no candidate files exist in directory");
        return false;
    }

    std::set<uint32_t> targetCrcSet;
    const std::vector<FileInfo>& files = m_unpacker->GetFileList();
    for (size_t i = 0; i < files.size(); ++i) {
        targetCrcSet.insert(files[i].m_PathFileNameCRC32);
    }

    struct AutoLoadMappingCandidate {
        wxString filePath;
        uint32_t hitCount;
        uint32_t mappingCount;
        uint32_t lowConfidenceCount;
        uint32_t cleanEntryCount;
        uint32_t hitRateBasis;
        uint32_t cleanRateBasis;
        uint32_t avgPathQualityBasis;
        uint32_t qualityScoreBasis;
        bool binaryFormat;
        size_t searchDepth;
        bool isolated;
    };

    std::vector<AutoLoadMappingCandidate> rankedCandidates;
    for (size_t i = 0; i < candidatePaths.GetCount(); ++i) {
        std::map<uint32_t, std::string> normalizedMappings;
        if (!LoadNormalizedMappingSeed(candidatePaths[i], normalizedMappings)) {
            continue;
        }

        AutoLoadMappingCandidate candidate;
        candidate.filePath = candidatePaths[i];
        candidate.mappingCount = static_cast<uint32_t>(normalizedMappings.size());
        candidate.hitCount = 0;
        candidate.lowConfidenceCount = 0;
        candidate.cleanEntryCount = 0;
        candidate.hitRateBasis = 0;
        candidate.cleanRateBasis = 0;
        candidate.avgPathQualityBasis = 0;
        candidate.qualityScoreBasis = 0;
        candidate.binaryFormat = candidatePaths[i].Lower().EndsWith(wxT(".ljpm"));
        candidate.searchDepth = candidateDirs.GetCount();
        candidate.isolated = false;

        wxFileName candidateFile(candidate.filePath);
        const wxString candidateDir = candidateFile.GetPath();
        for (size_t dirIndex = 0; dirIndex < candidateDirs.GetCount(); ++dirIndex) {
            if (SamePathIgnoreCase(candidateDir, candidateDirs[dirIndex])) {
                candidate.searchDepth = dirIndex;
                break;
            }
        }

        const MappingSeedQualityMetrics metrics =
            EvaluateMappingSeedQuality(normalizedMappings, targetCrcSet);
        candidate.hitCount = metrics.hitCount;
        candidate.lowConfidenceCount = metrics.lowConfidenceCount;
        candidate.cleanEntryCount = metrics.cleanEntryCount;
        candidate.hitRateBasis = metrics.hitRateBasis;
        candidate.cleanRateBasis = metrics.cleanRateBasis;
        candidate.avgPathQualityBasis = metrics.avgPathQualityBasis;
        candidate.qualityScoreBasis = metrics.qualityScoreBasis;
        rankedCandidates.push_back(candidate);
    }

    if (rankedCandidates.empty()) {
        SLJFP_LOG_INFO(L"Auto-load mapping: no valid mapping file loaded");
        return false;
    }

    std::sort(rankedCandidates.begin(),
              rankedCandidates.end(),
              [](const AutoLoadMappingCandidate& left, const AutoLoadMappingCandidate& right) {
                  if (left.qualityScoreBasis != right.qualityScoreBasis) {
                      return left.qualityScoreBasis > right.qualityScoreBasis;
                  }
                  if (left.hitRateBasis != right.hitRateBasis) {
                      return left.hitRateBasis > right.hitRateBasis;
                  }
                  if (left.mappingCount != right.mappingCount) {
                      return left.mappingCount > right.mappingCount;
                  }
                  if (left.binaryFormat != right.binaryFormat) {
                      return left.binaryFormat && !right.binaryFormat;
                  }
                  return left.searchDepth < right.searchDepth;
              });

    const uint32_t bestAutoLoadHitRateBasis =
        rankedCandidates.empty() ? 0u : rankedCandidates.front().hitRateBasis;
    const uint32_t bestAutoLoadQualityBasis =
        rankedCandidates.empty() ? 0u : rankedCandidates.front().qualityScoreBasis;
    for (size_t i = 0; i < rankedCandidates.size(); ++i) {
        std::string isolationReason;
        MappingSeedQualityMetrics metrics;
        metrics.hitCount = rankedCandidates[i].hitCount;
        metrics.lowConfidenceCount = rankedCandidates[i].lowConfidenceCount;
        metrics.cleanEntryCount = rankedCandidates[i].cleanEntryCount;
        metrics.hitRateBasis = rankedCandidates[i].hitRateBasis;
        metrics.cleanRateBasis = rankedCandidates[i].cleanRateBasis;
        metrics.avgPathQualityBasis = rankedCandidates[i].avgPathQualityBasis;
        metrics.qualityScoreBasis = rankedCandidates[i].qualityScoreBasis;
        rankedCandidates[i].isolated = ShouldIsolateMappingSeed(metrics,
                                                                rankedCandidates[i].mappingCount,
                                                                bestAutoLoadHitRateBasis,
                                                                bestAutoLoadQualityBasis,
                                                                isolationReason);
    }

    for (size_t i = 0; i < rankedCandidates.size(); ++i) {
        const AutoLoadMappingCandidate& candidate = rankedCandidates[i];
        if (candidate.isolated) {
            continue;
        }
        std::string mapPath = WxToNativePath(candidate.filePath);
        int result = m_unpacker->LoadPathMapping(mapPath);
        if (result == LJFP_SUCCESS) {
            m_lastMappingFile = candidate.filePath;
            AddMappingHistory(m_lastMappingFile);
            wxString msg = wxString::Format(wxT("已自动加载映射: %s"), candidate.filePath.c_str());
            m_statusBar->SetStatusText(msg, 1);
            SLJFP_LOG_INFO(std::wstring(msg.wc_str()));
            wxNotificationMessage notify(wxT("路径映射已自动加载"), candidate.filePath, this);
            notify.Show();
            return true;
        }

        wxString msg = wxString::Format(wxT("自动加载映射失败: %s (错误码: %d)"),
                                        candidate.filePath.c_str(),
                                        result);
        SLJFP_LOG_WARNING(std::wstring(msg.wc_str()));
    }

    SLJFP_LOG_INFO(L"Auto-load mapping: no valid mapping file loaded");
    return false;
}

void MainFrame::AddMappingHistory(const wxString& path) {
    if (path.IsEmpty()) {
        return;
    }

    for (size_t i = 0; i < m_mappingHistory.size(); i++) {
        if (m_mappingHistory[i].CmpNoCase(path) == 0) {
            m_mappingHistory.erase(m_mappingHistory.begin() + i);
            break;
        }
    }

    m_mappingHistory.Insert(path, 0);
    const size_t kMaxHistory = 10;
    while (m_mappingHistory.size() > kMaxHistory) {
        m_mappingHistory.RemoveAt(m_mappingHistory.size() - 1);
    }

    m_lastMappingFile = path;
    RefreshMappingHistoryUI();
}

void MainFrame::RefreshMappingHistoryUI() {
    if (!m_mappingHistoryCombo) {
        return;
    }

    m_mappingHistoryCombo->Freeze();
    m_mappingHistoryCombo->Clear();
    for (size_t i = 0; i < m_mappingHistory.size(); i++) {
        m_mappingHistoryCombo->Append(m_mappingHistory[i]);
    }
    if (!m_mappingHistory.IsEmpty()) {
        m_mappingHistoryCombo->SetSelection(0);
    }
    m_mappingHistoryCombo->Thaw();
}

void MainFrame::RefreshFileList() {
    long previousSelected = -1;
    long selectedRow = m_fileList->GetNextItem(-1, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED);
    if (selectedRow != -1) {
        previousSelected = m_fileList->GetItemData(selectedRow);
    }

    m_fileList->Freeze();
    m_fileList->DeleteAllItems();

    const std::vector<FileInfo>& files = m_unpacker->GetFileList();
    long selectedVisibleRow = -1;
    long row = 0;

    for (size_t i = 0; i < files.size(); i++) {
        const FileInfo& info = files[i];
        const bool mappingHit = m_unpacker->HasPathMappingForFile(i);
        if (!m_workflowSession.MatchesFilter(info, mappingHit)) {
            continue;
        }
        if (!HasActiveReviewFilter(i)) {
            continue;
        }

        std::string path = m_unpacker->GetFilePath(i);
        wxString displayName = NativePathToWx(path);

        long item = m_fileList->InsertItem(row, displayName);
        m_fileList->SetItem(item, 1, FormatBytesForUi(info.m_SizeOriginal));
        m_fileList->SetItem(item, 2, FormatBytesForUi(info.m_Size));
        m_fileList->SetItem(item, 3, DescribeCompressType(info.m_CompressType));
        m_fileList->SetItem(item, 4, DescribeEncryptType(info.m_CodeType));
        m_fileList->SetItem(item, 5, wxString::Format(wxT("%u"), info.m_PackIndex));
        m_fileList->SetItemData(item, static_cast<long>(i));

        if (static_cast<long>(i) == previousSelected) {
            selectedVisibleRow = item;
        }
        ++row;
    }

    if (selectedVisibleRow >= 0) {
        m_fileList->SetItemState(selectedVisibleRow,
                                 wxLIST_STATE_SELECTED | wxLIST_STATE_FOCUSED,
                                 wxLIST_STATE_SELECTED | wxLIST_STATE_FOCUSED);
        m_fileList->EnsureVisible(selectedVisibleRow);
    } else if (m_fileList->GetItemCount() > 0) {
        m_fileList->SetItemState(0,
                                 wxLIST_STATE_SELECTED | wxLIST_STATE_FOCUSED,
                                 wxLIST_STATE_SELECTED | wxLIST_STATE_FOCUSED);
        m_fileList->EnsureVisible(0);
        UpdatePreview(static_cast<size_t>(m_fileList->GetItemData(0)));
    } else {
        ClearPreviewPanel();
    }

    m_fileList->Thaw();
}

void MainFrame::RefreshResourceTree() {
    m_resourceTree->Freeze();
    m_resourceTree->DeleteChildren(m_rootItem);

    const WorkflowSessionController::TreeFilter currentFilter = m_workflowSession.GetFilter();
    wxTreeItemId selectedItem;

    const uint32_t totalFiles = m_unpacker->GetTotalFiles();
    wxTreeItemId allItem = m_resourceTree->AppendItem(
        m_rootItem,
        wxString::Format(wxT("全部资源 (%u)"), totalFiles),
        -1, -1,
        new ResourceTreeFilterData(WorkflowSessionController::TreeFilterMode::AllFiles));
    if (currentFilter.mode == WorkflowSessionController::TreeFilterMode::AllFiles) {
        selectedItem = allItem;
    }

    wxTreeItemId sourceItem = m_resourceTree->AppendItem(m_rootItem, wxT("源数据"));
    std::map<uint32_t, int> packCounts;
    int looseCount = 0;
    int mappedCount = 0;
    const std::vector<FileInfo>& files = m_unpacker->GetFileList();

    for (const FileInfo& info : files) {
        if (info.m_PackIndex == 0) {
            ++looseCount;
        } else {
            packCounts[info.m_PackIndex]++;
        }
    }
    for (size_t i = 0; i < files.size(); ++i) {
        if (m_unpacker->HasPathMappingForFile(i)) {
            ++mappedCount;
        }
    }

    wxTreeItemId looseItem = m_resourceTree->AppendItem(
        sourceItem,
        wxString::Format(wxT("散文件 (%d)"), looseCount),
        -1, -1,
        new ResourceTreeFilterData(WorkflowSessionController::TreeFilterMode::LooseFiles));
    if (currentFilter.mode == WorkflowSessionController::TreeFilterMode::LooseFiles) {
        selectedItem = looseItem;
    }

    wxTreeItemId packsItem = m_resourceTree->AppendItem(sourceItem, wxT("资源包"));
    for (const auto& pair : packCounts) {
        wxTreeItemId packItem = m_resourceTree->AppendItem(
            packsItem,
            wxString::Format(wxT("包 %u (%d 文件)"), pair.first, pair.second),
            -1, -1,
            new ResourceTreeFilterData(WorkflowSessionController::TreeFilterMode::PackFiles, pair.first));
        if (currentFilter.mode == WorkflowSessionController::TreeFilterMode::PackFiles &&
            currentFilter.packIndex == pair.first) {
            selectedItem = packItem;
        }
    }

    const int unmappedCount = static_cast<int>(files.size()) - mappedCount;
    wxTreeItemId mappingItem = m_resourceTree->AppendItem(m_rootItem, wxT("映射健康"));
    wxTreeItemId mappedItem = m_resourceTree->AppendItem(
        mappingItem,
        wxString::Format(wxT("已命中 (%d)"), mappedCount),
        -1, -1,
        new ResourceTreeFilterData(WorkflowSessionController::TreeFilterMode::MappedFiles));
    wxTreeItemId unmappedItem = m_resourceTree->AppendItem(
        mappingItem,
        wxString::Format(wxT("待补全 (%d)"), unmappedCount),
        -1, -1,
        new ResourceTreeFilterData(WorkflowSessionController::TreeFilterMode::UnmappedFiles));
    if (currentFilter.mode == WorkflowSessionController::TreeFilterMode::MappedFiles) {
        selectedItem = mappedItem;
    } else if (currentFilter.mode == WorkflowSessionController::TreeFilterMode::UnmappedFiles) {
        selectedItem = unmappedItem;
    }

    m_resourceTree->Expand(allItem);
    m_resourceTree->Expand(sourceItem);
    m_resourceTree->Expand(packsItem);
    m_resourceTree->Expand(mappingItem);
    if (selectedItem.IsOk()) {
        m_resourceTree->SelectItem(selectedItem);
    }
    m_resourceTree->Thaw();
}

void MainFrame::UpdatePreview(size_t fileIndex) {
    if (fileIndex >= m_unpacker->GetFileList().size()) {
        ClearPreviewPanel();
        return;
    }

    const FileInfo& info = m_unpacker->GetFileList()[fileIndex];
    const std::string displayPath = m_unpacker->GetFilePath(fileIndex);
    const bool mappingHit = m_unpacker->HasPathMappingForFile(fileIndex);
    const std::string previewOutputPath =
        WorkflowPresenter::BuildPreviewOutputPath(m_workflowSession, m_unpacker.get(), fileIndex);
    const bool outputExists = !previewOutputPath.empty() && wxFileExists(NativePathToWx(previewOutputPath));

    m_workflowSession.SetPreviewSelection(fileIndex,
                                          info,
                                          displayPath,
                                          mappingHit,
                                          previewOutputPath,
                                          outputExists);

    wxString previewText;
    previewText += wxT("=== 源数据 ===\n");
    previewText += wxString::Format(wxT("文件路径/CRC32: %s\n"), NativePathToWx(displayPath).c_str());
    previewText += wxString::Format(wxT("来源包: %u (%s)\n"),
                                    info.m_PackIndex,
                                    info.m_PackIndex == 0 ? wxT("散文件") : wxT("资源包"));
    previewText += wxString::Format(wxT("原始大小: %s\n"), FormatBytesForUi(info.m_SizeOriginal).c_str());
    previewText += wxString::Format(wxT("当前大小: %s\n"), FormatBytesForUi(info.m_Size).c_str());
    previewText += wxString::Format(wxT("压缩状态: %s\n"), DescribeCompressType(info.m_CompressType).c_str());
    previewText += wxString::Format(wxT("加密状态: %s\n"), DescribeEncryptType(info.m_CodeType).c_str());
    previewText += wxString::Format(wxT("包内位置: %u\n"), info.m_Pos);

    previewText += wxT("\n=== 映射健康 ===\n");
    previewText += wxString::Format(wxT("路径映射: %s\n"), mappingHit ? wxT("已命中") : wxT("未命中，当前会落到 CRC/推断路径"));
    previewText += wxString::Format(wxT("路径 CRC32: 0x%08X\n"), info.m_PathFileNameCRC32);

    previewText += wxT("\n=== 执行计划 ===\n");
    if (!previewOutputPath.empty()) {
        previewText += wxString::Format(wxT("预估输出: %s\n"), NativePathToWx(previewOutputPath).c_str());
    } else {
        previewText += wxT("预估输出: 尚未设置输出目录\n");
    }
    previewText += wxString::Format(wxT("CRC 校验: %s\n"),
                                    (m_verifyCRCCheck && m_verifyCRCCheck->GetValue()) ? wxT("开启") : wxT("关闭"));
    previewText += wxString::Format(wxT("线程数: %d\n"),
                                    m_threadCountCtrl ? m_threadCountCtrl->GetValue() : 1);
    previewText += wxString::Format(wxT("流式模式: %s\n"),
                                    (m_streamModeCheck && m_streamModeCheck->GetValue()) ? wxT("开启") : wxT("关闭"));

    previewText += wxT("\n=== 结果审阅 ===\n");
    if (outputExists) {
        previewText += wxT("结果文件: 已生成，可在预览图/右侧信息中继续审阅\n");
    } else {
        previewText += wxT("结果文件: 尚未生成，执行解包后可回到这里审阅\n");
    }
    previewText += wxString::Format(wxT("CRC32 (原始): 0x%08X\n"), info.m_CRC32Original);
    previewText += wxString::Format(wxT("CRC32 (当前): 0x%08X\n"), info.m_CRC32);

    m_previewText->SetValue(previewText);

    bool imageLoaded = false;
    if (outputExists && IsPreviewableImageOutputPath(previewOutputPath)) {
        wxImage image;
        if (image.LoadFile(NativePathToWx(previewOutputPath)) && image.IsOk()) {
            wxSize panelSize = m_previewPanel->GetClientSize();
            int maxWidth = std::max(240, panelSize.GetWidth() - 40);
            int maxHeight = 280;
            int width = image.GetWidth();
            int height = image.GetHeight();
            if (width > 0 && height > 0) {
                double scale = std::min(static_cast<double>(maxWidth) / width,
                                        static_cast<double>(maxHeight) / height);
                if (scale < 1.0) {
                    width = static_cast<int>(width * scale);
                    height = static_cast<int>(height * scale);
                    image.Rescale(width, height, wxIMAGE_QUALITY_HIGH);
                }
                m_previewImage->SetBitmap(wxBitmap(image));
                m_previewImage->Show();
                imageLoaded = true;
            }
        }
    }

    if (!imageLoaded) {
        m_previewImage->SetBitmap(wxNullBitmap);
        m_previewImage->Hide();
    }

    m_previewPanel->Layout();
    m_notebook->SetSelection(1);
    UpdateWorkflowStatus();
}

void MainFrame::UpdateStatusBar() {
    if (!m_statusBar) {
        return;
    }

    const WorkflowPresenter::StatusBarModel model = WorkflowPresenter::BuildStatusBarModel(
        m_workflowSession,
        m_unpacker.get(),
        m_hasLoadedIndex,
        m_isUnpacking,
        m_fileList ? m_fileList->GetItemCount() : 0,
        m_reviewController.GetActiveFilterLabel());

    m_statusBar->SetStatusText(wxString(model.primaryText.c_str()), 0);
    m_statusBar->SetStatusText(wxString(model.secondaryText.c_str()), 1);
    m_statusBar->SetStatusText(wxString(model.fileCountText.c_str()), 2);
}

void MainFrame::RefreshOverviewPanel() {
    if (!m_overviewText) {
        return;
    }

    const WorkflowPresenter::OverviewPanelModel model =
        WorkflowPresenter::BuildOverviewPanelModel(
            m_workflowSession,
            m_reviewController.GetActiveFilterLabel());
    m_overviewText->ChangeValue(wxString(model.text.c_str()));
}

void MainFrame::RefreshSessionControlPanel() {
    const WorkflowSessionController::SourceState& source = m_workflowSession.GetSourceState();
    const WorkflowSessionController::MappingState& mapping = m_workflowSession.GetMappingState();
    const WorkflowSessionController::ExecutionState& execution = m_workflowSession.GetExecutionState();
    const WorkflowSessionController::RunState& run = m_workflowSession.GetRunState();

    if (m_sessionSourcePathCtrl) {
        wxString sourceText;
        if (!source.indexPath.empty()) {
            sourceText = NativePathToWx(source.indexPath);
            if (!source.inputDir.empty()) {
                sourceText += wxT("  |  ") + NativePathToWx(source.inputDir);
            }
        } else if (!source.inputDir.empty()) {
            sourceText = NativePathToWx(source.inputDir);
        } else {
            sourceText = wxT("未加载索引");
        }
        m_sessionSourcePathCtrl->ChangeValue(sourceText);
    }

    if (m_sessionMappingPathCtrl) {
        wxString mappingText = wxT("未加载映射");
        if (!mapping.mappingPath.empty()) {
            mappingText = NativePathToWx(mapping.mappingPath);
        } else if (!mapping.generatedPath.empty()) {
            mappingText = NativePathToWx(mapping.generatedPath);
        }
        m_sessionMappingPathCtrl->ChangeValue(mappingText);
    }

    if (m_sessionOutputPathCtrl) {
        m_sessionOutputPathCtrl->ChangeValue(execution.outputReady
            ? NativePathToWx(execution.outputDir)
            : wxT("尚未设置输出目录"));
    }

    if (m_sessionProgressGauge && m_sessionProgressLabel) {
        int gaugeRange = 100;
        int gaugeValue = 0;
        if (run.totalCount > 0) {
            gaugeRange = static_cast<int>(run.totalCount);
            gaugeValue = static_cast<int>(std::min(run.currentCount, run.totalCount));
        } else if (run.finished) {
            gaugeValue = 100;
        }

        m_sessionProgressGauge->SetRange(std::max(gaugeRange, 1));
        m_sessionProgressGauge->SetValue(std::min(gaugeValue, std::max(gaugeRange, 1)));

        wxString progressLabel;
        if (run.running) {
            if (run.paused) {
                progressLabel = wxString::Format(wxT("已暂停 %u/%u"), run.currentCount, run.totalCount);
            } else if (run.stopping) {
                progressLabel = wxString::Format(wxT("正在停止 %u/%u"), run.currentCount, run.totalCount);
            } else {
                progressLabel = wxString::Format(wxT("执行中 %u/%u"), run.currentCount, run.totalCount);
            }
        } else if (run.finished) {
            progressLabel = wxString::Format(wxT("完成：成功 %u / 失败 %u"),
                                             run.successCount,
                                             run.failedCount);
        } else {
            progressLabel = wxT("未开始");
        }
        m_sessionProgressLabel->SetLabel(progressLabel);
    }
}

void MainFrame::AppendSessionLog(const wxString& message) {
    if (!m_sessionLogText || message.IsEmpty()) {
        return;
    }

    const wxString line = wxString::Format(wxT("[%s] %s\n"),
                                           wxDateTime::Now().Format(wxT("%H:%M:%S")).c_str(),
                                           message.c_str());
    m_sessionLogText->AppendText(line);

    const long maxChars = 28000;
    if (m_sessionLogText->GetLastPosition() > maxChars) {
        wxString content = m_sessionLogText->GetValue();
        content = content.Right(maxChars / 2);
        const int firstNewline = content.Find('\n');
        if (firstNewline != wxNOT_FOUND) {
            content = content.Mid(firstNewline + 1);
        }
        m_sessionLogText->ChangeValue(content);
        m_sessionLogText->SetInsertionPointEnd();
    }
    m_sessionLogText->ShowPosition(m_sessionLogText->GetLastPosition());
}

void MainFrame::RefreshResultReviewPanel() {
    if (!m_resultSummaryText || !m_resultIssueList) {
        return;
    }

    const WorkflowSessionController::SourceState& source = m_workflowSession.GetSourceState();
    const WorkflowSessionController::ExecutionState& execution = m_workflowSession.GetExecutionState();
    const std::vector<FailedFileRecord> failedFiles = m_unpacker
        ? m_unpacker->GetLastFailedFiles()
        : std::vector<FailedFileRecord>();

    const long selectedRow = m_resultIssueList->GetNextItem(-1, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED);
    m_reviewController.RememberSelectionByRow(selectedRow);

    const WorkflowPresenter::ReviewPanelModel model =
        WorkflowPresenter::BuildReviewPanelModel(
            m_workflowSession,
            m_unpacker.get(),
            m_reviewController.GetActiveFilterLabel());

    m_resultSummaryText->ChangeValue(wxString(model.summary.c_str()));

    m_resultIssueList->Freeze();
    m_resultIssueList->DeleteAllItems();
    m_reviewController.SetIssueGroups(model.groups);
    const std::vector<ReviewIssueGroup>& reviewIssueGroups = m_reviewController.GetIssueGroups();
    for (size_t i = 0; i < reviewIssueGroups.size(); ++i) {
        const ReviewIssueGroup& group = reviewIssueGroups[i];
        const long row = m_resultIssueList->InsertItem(m_resultIssueList->GetItemCount(),
                                                       wxString(group.category.c_str()));
        m_resultIssueList->SetItem(row, 1, wxString(group.subject.c_str()));
        m_resultIssueList->SetItem(row, 2, wxString(group.detail.c_str()));
        m_resultIssueList->SetItemData(row, group.primaryFileIndex);
    }

    const long selectedRowToRestore = m_reviewController.ResolveSelectedRow();
    if (selectedRowToRestore >= 0) {
        m_resultIssueList->SetItemState(selectedRowToRestore,
                                        wxLIST_STATE_SELECTED | wxLIST_STATE_FOCUSED,
                                        wxLIST_STATE_SELECTED | wxLIST_STATE_FOCUSED);
        m_resultIssueList->EnsureVisible(selectedRowToRestore);
    }

    m_resultIssueList->Thaw();

    if (m_resultOpenOutputButton) {
        m_resultOpenOutputButton->Enable(execution.outputReady && wxDirExists(NativePathToWx(execution.outputDir)));
    }
    if (m_resultLocateIssueButton) {
        m_resultLocateIssueButton->Enable(model.canLocate);
    }
    if (m_resultGenerateMappingButton) {
        m_resultGenerateMappingButton->Enable(source.loaded && !m_isUnpacking);
    }
    if (m_resultExportFailuresButton) {
        m_resultExportFailuresButton->Enable(!failedFiles.empty() && execution.outputReady);
    }
    if (m_resultRerunIssueButton) {
        m_resultRerunIssueButton->Enable(
            WorkflowReviewController::CanRerunGroup(GetSelectedReviewIssueGroup(), m_isUnpacking));
    }
    if (m_resultClearFilterButton) {
        m_resultClearFilterButton->Enable(m_reviewController.HasActiveFilter());
    }
}

void MainFrame::UpdateQuickActionAvailability() {
    const bool hasSource = m_hasLoadedIndex && m_unpacker && m_unpacker->GetTotalFiles() > 0;
    const bool canStart = !m_isUnpacking && ValidateReadyForUnpack(false);
    const bool hasSelectedFile = (GetSelectedFileIndex() != static_cast<size_t>(-1));
    const WorkflowSessionController::RunState& runState = m_workflowSession.GetRunState();

    if (m_quickOpenDirButton) m_quickOpenDirButton->Enable(!m_isUnpacking);
    if (m_quickOpenIndexButton) m_quickOpenIndexButton->Enable(!m_isUnpacking);
    if (m_quickOutputButton) m_quickOutputButton->Enable(!m_isUnpacking);
    if (m_quickLoadMappingButton) m_quickLoadMappingButton->Enable(hasSource && !m_isUnpacking);
    if (m_quickGenerateMappingButton) m_quickGenerateMappingButton->Enable(hasSource && !m_isUnpacking);
    if (m_quickUnpackButton) m_quickUnpackButton->Enable(canStart);
    if (m_quickPauseButton) {
        m_quickPauseButton->Enable(m_isUnpacking);
        m_quickPauseButton->SetLabel(runState.paused ? wxT("继续") : wxT("暂停"));
    }
    if (m_quickStopButton) {
        m_quickStopButton->Enable(m_isUnpacking);
    }

    if (m_toolBar != nullptr) {
        auto enableTool = [this](int toolId, bool enabled) {
            if (m_toolBar->FindById(toolId) != nullptr) {
                m_toolBar->EnableTool(toolId, enabled);
            }
        };
        enableTool(ID_OPEN_DIR, !m_isUnpacking);
        enableTool(ID_OPEN_INDEX, !m_isUnpacking);
        enableTool(ID_SET_OUTPUT_DIR, !m_isUnpacking);
        enableTool(ID_LOAD_MAPPING, hasSource && !m_isUnpacking);
        enableTool(ID_GENERATE_MAPPING, hasSource && !m_isUnpacking);
        enableTool(ID_UNPACK_ALL, canStart);
        enableTool(ID_UNPACK_SELECTED, hasSource && hasSelectedFile && !m_isUnpacking);
        enableTool(ID_STOP_UNPACK, m_isUnpacking);
    }
}

void MainFrame::UpdateWorkflowStatus() {
    UnpackOptions options;
    BuildUnpackOptions(options, false);

    m_workflowSession.SetSourceData(WxToNativePath(m_currentIndexPath),
                                    m_currentInputDir,
                                    m_unpacker ? m_unpacker->GetTotalFiles() : 0,
                                    m_unpacker ? m_unpacker->GetTotalBytes() : 0,
                                    m_hasLoadedIndex);

    uint32_t hit = 0;
    uint32_t total = 0;
    uint32_t rateBasis = 0;
    const bool hasHitRate = m_unpacker && m_unpacker->GetPathMappingHitRate(hit, total, rateBasis);
    m_workflowSession.SetMappingData(m_unpacker ? m_unpacker->GetPathMappingCount() : 0,
                                     hasHitRate,
                                     hit,
                                     total,
                                     rateBasis,
                                     WxToNativePath(m_lastMappingFile),
                                     WxToNativePath(m_lastGeneratedMappingFile));
    m_workflowSession.SetExecutionPlan(m_outputDirCtrl ? WxToNativePath(m_outputDirCtrl->GetValue()) : std::string(),
                                       options);

    std::vector<uint32_t> missingSamples;
    bool mappingNeedsAttention = false;
    std::string mappingGuidance;
    if (!m_hasLoadedIndex) {
        mappingGuidance = WxToNativePath(wxT("等待加载索引后评估映射健康"));
    } else if (!m_unpacker || m_unpacker->GetPathMappingCount() == 0) {
        mappingNeedsAttention = true;
        mappingGuidance = WxToNativePath(wxT("尚未加载映射，可从索引附近参考目录自动生成"));
    } else if (hasHitRate && hit < total) {
        mappingNeedsAttention = true;
        missingSamples = m_unpacker->GetPathMappingMissingSamples();
        mappingGuidance = WxToNativePath(wxString::Format(wxT("仍有 %u 个文件缺少映射，建议补全后再执行"), total - hit));
    } else if (hasHitRate) {
        mappingGuidance = WxToNativePath(wxT("映射健康良好，可优先恢复原始路径"));
    } else {
        mappingGuidance = WxToNativePath(wxT("映射已加载，等待源数据统计"));
    }
    m_workflowSession.SetMappingGuidance(mappingNeedsAttention, missingSamples, mappingGuidance);

    if (m_unpacker) {
        std::vector<std::pair<int, uint32_t> > errorBreakdown;
        const std::map<int, uint32_t>& errorCounts = m_unpacker->GetLastErrorCodeCounts();
        for (std::map<int, uint32_t>::const_iterator it = errorCounts.begin();
             it != errorCounts.end();
             ++it) {
            errorBreakdown.push_back(std::make_pair(it->first, it->second));
        }
        std::sort(errorBreakdown.begin(),
                  errorBreakdown.end(),
                  [](const std::pair<int, uint32_t>& left, const std::pair<int, uint32_t>& right) {
                      if (left.second != right.second) {
                          return left.second > right.second;
                      }
                      return left.first < right.first;
                  });

        const int firstErrorCode = m_unpacker->GetFirstErrorCode();
        uint32_t firstErrorFileIndex = static_cast<uint32_t>(-1);
        std::string firstErrorPath;
        if (firstErrorCode != 0) {
            firstErrorFileIndex = m_unpacker->GetFirstErrorFileIndex();
            if (firstErrorFileIndex < m_unpacker->GetFileList().size()) {
                firstErrorPath = m_unpacker->GetFilePath(firstErrorFileIndex);
            }
        }

        DecryptFailureDiagnostic diagnostic;
        DecryptFailureDiagnostic* diagnosticPtr = nullptr;
        if (m_unpacker->GetFirstFailedDecryptDiagnostic(diagnostic)) {
            diagnosticPtr = &diagnostic;
        }

        m_workflowSession.SetReviewData(firstErrorCode,
                                        firstErrorFileIndex,
                                        firstErrorPath,
                                        errorBreakdown,
                                        diagnosticPtr);
    } else {
        m_workflowSession.ClearReviewData();
    }

    const WorkflowSessionController::SourceState& source = m_workflowSession.GetSourceState();
    const WorkflowSessionController::MappingState& mapping = m_workflowSession.GetMappingState();
    const WorkflowSessionController::ExecutionState& execution = m_workflowSession.GetExecutionState();
    const WorkflowSessionController::RunState& run = m_workflowSession.GetRunState();
    const WorkflowSessionController::ReviewState& review = m_workflowSession.GetReviewState();

    ApplyStepPresentation(m_stepIndexLabel,
                          wxT("1. 源数据"),
                          source.loaded ? wxString::Format(wxT("%u 个文件 / %s"),
                                                           source.totalFiles,
                                                           FormatBytesForUi(source.totalBytes).c_str())
                                        : wxT("等待打开索引"),
                          m_workflowSession.GetStepStatus(WorkflowSessionController::Stage::SourceData));
    ApplyStepPresentation(m_stepMappingLabel,
                          wxT("2. 映射健康"),
                          !mapping.loaded
                              ? wxT("未加载映射")
                              : (mapping.hasHitRate
                                     ? (mapping.needsAttention
                                            ? wxString::Format(wxT("命中率 %s，缺口 %u"),
                                                               FormatRateForUi(mapping.rateBasis).c_str(),
                                                               mapping.totalCount - mapping.hitCount)
                                            : wxString::Format(wxT("命中率 %s"),
                                                               FormatRateForUi(mapping.rateBasis).c_str()))
                                     : wxString::Format(wxT("已加载 %llu 条"),
                                                        static_cast<unsigned long long>(mapping.mappingCount))),
                          m_workflowSession.GetStepStatus(WorkflowSessionController::Stage::MappingHealth));
    ApplyStepPresentation(m_stepOutputLabel,
                          wxT("3. 执行计划"),
                          execution.outputReady ? wxString::Format(wxT("输出到 %s"),
                                                                   NativePathToWx(execution.outputDir).c_str())
                                                : wxT("等待设置输出"),
                          m_workflowSession.GetStepStatus(WorkflowSessionController::Stage::ExecutionPlan));
    ApplyStepPresentation(m_stepRunLabel,
                          wxT("4. 结果审阅"),
                          run.running ? (run.paused ? wxT("已暂停") : (run.stopping ? wxT("正在停止") : wxT("进行中")))
                                      : (run.finished ? (review.available && review.firstErrorCode != 0
                                                             ? wxString::Format(wxT("成功 %u / 失败 %u"),
                                                                                run.successCount,
                                                                                run.failedCount)
                                                             : wxString::Format(wxT("成功 %u / 失败 %u"),
                                                                                run.successCount,
                                                                                run.failedCount))
                                                      : wxT("等待执行")),
                          m_workflowSession.GetStepStatus(WorkflowSessionController::Stage::ResultReview));

    RefreshOverviewPanel();
    RefreshSessionControlPanel();
    RefreshResultReviewPanel();
    UpdateQuickActionAvailability();
    UpdateStatusBar();
}

const MainFrame::ReviewIssueGroup* MainFrame::GetReviewIssueGroupByRow(long row) const {
    return m_reviewController.GetIssueGroupByRow(row);
}

const MainFrame::ReviewIssueGroup* MainFrame::GetSelectedReviewIssueGroup() const {
    if (!m_resultIssueList) {
        return nullptr;
    }
    const long row = m_resultIssueList->GetNextItem(-1, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED);
    return GetReviewIssueGroupByRow(row);
}

void MainFrame::ApplyReviewFilter(const ReviewIssueGroup* group) {
    if (!m_reviewController.ApplyFilterForGroup(group)) {
        return;
    }

    RefreshResultReviewPanel();
    RefreshFileList();
    UpdateStatusBar();
}

void MainFrame::ClearReviewFilter() {
    if (!m_reviewController.ClearFilter()) {
        return;
    }

    RefreshResultReviewPanel();
    RefreshFileList();
    UpdateStatusBar();
}

bool MainFrame::HasActiveReviewFilter(size_t fileIndex) const {
    return m_reviewController.MatchesActiveFilter(fileIndex);
}

size_t MainFrame::GetSelectedFileIndex() const {
    if (!m_fileList) {
        return static_cast<size_t>(-1);
    }

    long selected = m_fileList->GetNextItem(-1, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED);
    if (selected == -1) {
        return static_cast<size_t>(-1);
    }

    const long itemData = m_fileList->GetItemData(selected);
    if (itemData < 0) {
        return static_cast<size_t>(-1);
    }
    return static_cast<size_t>(itemData);
}

void MainFrame::SelectAndRevealFile(size_t fileIndex) {
    if (!m_unpacker || fileIndex >= m_unpacker->GetFileList().size() || !m_fileList) {
        return;
    }

    m_workflowSession.SetFilter(WorkflowSessionController::TreeFilterMode::AllFiles);
    RefreshResourceTree();
    RefreshFileList();

    const long targetFileIndex = static_cast<long>(fileIndex);
    for (long row = 0; row < m_fileList->GetItemCount(); ++row) {
        const long currentItemData = static_cast<long>(m_fileList->GetItemData(row));
        if (currentItemData != targetFileIndex) {
            continue;
        }

        m_fileList->SetItemState(row,
                                 wxLIST_STATE_SELECTED | wxLIST_STATE_FOCUSED,
                                 wxLIST_STATE_SELECTED | wxLIST_STATE_FOCUSED);
        m_fileList->EnsureVisible(row);
        UpdatePreview(fileIndex);
        return;
    }

    UpdatePreview(fileIndex);
}

void MainFrame::ClearPreviewPanel() {
    if (m_previewText) {
        m_previewText->SetValue(wxT("在左侧资源树或文件列表中选择一个条目，这里会展示源数据、映射健康、执行计划和结果审阅信息。"));
    }
    if (m_previewImage) {
        m_previewImage->SetBitmap(wxNullBitmap);
        m_previewImage->Hide();
    }
    if (m_previewPanel) {
        m_previewPanel->Layout();
    }
    m_workflowSession.ClearPreviewSelection();
}

void MainFrame::SaveConfig() {
    wxConfig config(wxT("SuperLJFilePackUnpack"));

    config.Write(wxT("/General/OutputDir"), m_outputDirCtrl->GetValue());
    config.Write(wxT("/General/VerifyCRC"), m_verifyCRCCheck->GetValue());
    config.Write(wxT("/General/Overwrite"), m_overwriteCheck->GetValue());
    config.Write(wxT("/General/OrganizeByType"), m_organizeByTypeCheck->GetValue());
    config.Write(wxT("/General/ThreadCount"), m_threadCountCtrl->GetValue());
    if (m_decryptModeChoice) {
        config.Write(wxT("/General/DecryptMode"), m_decryptModeChoice->GetSelection());
    }
    if (m_streamModeCheck) {
        config.Write(wxT("/General/StreamMode"), m_streamModeCheck->GetValue());
    }
    if (m_streamChunkCtrl) {
        config.Write(wxT("/General/StreamChunkMB"), m_streamChunkCtrl->GetValue());
    }
    if (m_androidLibgameCtrl) {
        config.Write(wxT("/General/AndroidLibgamePath"), m_androidLibgameCtrl->GetValue());
    }
    if (m_autoLoadMappingCheck) {
        config.Write(wxT("/Mapping/AutoLoadEnabled"), m_autoLoadMappingCheck->GetValue());
    }
    if (m_mappingPrefixCtrl) {
        config.Write(wxT("/Mapping/AutoLoadPrefixes"), m_mappingPrefixCtrl->GetValue());
    }
    if (!m_lastMappingFile.IsEmpty()) {
        config.Write(wxT("/Mapping/LastLoaded"), m_lastMappingFile);
    }
    if (!m_lastGeneratedMappingFile.IsEmpty()) {
        config.Write(wxT("/Mapping/LastGenerated"), m_lastGeneratedMappingFile);
    }
    if (!m_mappingHistory.IsEmpty()) {
        wxString joined = wxJoin(m_mappingHistory, '|');
        config.Write(wxT("/Mapping/History"), joined);
    }
}

void MainFrame::LoadConfig() {
    wxConfig config(wxT("SuperLJFilePackUnpack"));

    wxString outputDir;
    if (config.Read(wxT("/General/OutputDir"), &outputDir)) {
        m_outputDirCtrl->SetValue(outputDir);
    }

    bool verifyCRC = true;
    if (config.Read(wxT("/General/VerifyCRC"), &verifyCRC)) {
        m_verifyCRCCheck->SetValue(verifyCRC);
    }

    bool overwrite = false;
    if (config.Read(wxT("/General/Overwrite"), &overwrite)) {
        m_overwriteCheck->SetValue(overwrite);
    }

    bool organizeByType = true;
    if (config.Read(wxT("/General/OrganizeByType"), &organizeByType)) {
        m_organizeByTypeCheck->SetValue(organizeByType);
    }

    bool streamMode = false;
    config.Read(wxT("/General/StreamMode"), &streamMode, false);
    if (m_streamModeCheck) {
        m_streamModeCheck->SetValue(streamMode);
    }
    long streamChunkMB = 4;
    config.Read(wxT("/General/StreamChunkMB"), &streamChunkMB, 4L);
    if (m_streamChunkCtrl) {
        m_streamChunkCtrl->SetValue(static_cast<int>(streamChunkMB));
        m_streamChunkCtrl->Enable(streamMode);
    }

    wxString androidLibgamePath;
    config.Read(wxT("/General/AndroidLibgamePath"), &androidLibgamePath, wxEmptyString);
    if (m_androidLibgameCtrl) {
        m_androidLibgameCtrl->SetValue(androidLibgamePath);
    }

    int threadCount = 4;
    if (config.Read(wxT("/General/ThreadCount"), &threadCount)) {
        m_threadCountCtrl->SetValue(threadCount);
    }

    int decryptModeSelection = 0;
    config.Read(wxT("/General/DecryptMode"), &decryptModeSelection, 0);
    if (m_decryptModeChoice) {
        if (decryptModeSelection < 0 || decryptModeSelection >= static_cast<int>(m_decryptModeChoice->GetCount())) {
            decryptModeSelection = 0;
        }
        m_decryptModeChoice->SetSelection(decryptModeSelection);
    }

    bool autoLoadMapping = true;
    config.Read(wxT("/Mapping/AutoLoadEnabled"), &autoLoadMapping, true);
    if (m_autoLoadMappingCheck) {
        m_autoLoadMappingCheck->SetValue(autoLoadMapping);
    }

    wxString prefixes;
    config.Read(wxT("/Mapping/AutoLoadPrefixes"), &prefixes, wxT("path_mapping,mapping"));
    if (m_mappingPrefixCtrl) {
        m_mappingPrefixCtrl->SetValue(prefixes);
    }

    config.Read(wxT("/Mapping/LastLoaded"), &m_lastMappingFile);
    config.Read(wxT("/Mapping/LastGenerated"), &m_lastGeneratedMappingFile);

    wxString historyStr;
    if (config.Read(wxT("/Mapping/History"), &historyStr) && !historyStr.IsEmpty()) {
        wxStringTokenizer tokenizer(historyStr, wxT("|"));
        while (tokenizer.HasMoreTokens()) {
            wxString token = tokenizer.GetNextToken();
            token.Trim(true).Trim(false);
            if (!token.IsEmpty()) {
                m_mappingHistory.Add(token);
            }
        }
    }
    RefreshMappingHistoryUI();
}

// ============================================================================
// 解包线程实现
// ============================================================================
UnpackThread::UnpackThread(MainFrame* frame, Unpacker* unpacker,
                           const std::string& inputDir, const std::string& outputDir,
                           const UnpackOptions& options,
                           const std::vector<size_t>* selectedIndices)
    : wxThread(wxTHREAD_JOINABLE)
    , m_frame(frame)
    , m_unpacker(unpacker)
    , m_inputDir(inputDir)
    , m_outputDir(outputDir)
    , m_options(options)
{
    if (selectedIndices != nullptr) {
        m_selectedIndices = *selectedIndices;
    }
}

wxThread::ExitCode UnpackThread::Entry() {
    SLJFP_LOG_INFO(L"Unpack thread entered");
    AppendRuntimeTrace("UnpackThread::Entry entered");
    // 进度回调节流变量
    float lastReportedProgress = -1.0f;  // 初始化为 -1 确保第一次一定报告
    auto lastReportTime = std::chrono::steady_clock::now();
    const auto minReportInterval = std::chrono::milliseconds(100);  // 最小报告间隔 100ms
    const float minProgressDelta = 0.005f;  // 最小进度增量 0.5%
    bool firstReport = true;  // 首次报告标志

    // 设置进度回调（带节流）
    m_unpacker->SetProgressCallback([this, &lastReportedProgress, &lastReportTime,
                                      minReportInterval, minProgressDelta, &firstReport]
                                     (float progress, uint32_t current, uint32_t total) {
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - lastReportTime);

        // 节流条件：首次报告、时间间隔足够、进度增量足够大、或者是最后一个文件
        bool shouldReport = firstReport ||
                            (elapsed >= minReportInterval) ||
                            (progress - lastReportedProgress >= minProgressDelta) ||
                            (current == total);

        if (shouldReport) {
            wxThreadEvent* event = new wxThreadEvent(wxEVT_UNPACK_PROGRESS);
            // 使用自定义结构传递更多信息
            event->SetPayload(progress);
            event->SetInt(static_cast<int>(current));  // 当前已完成数
            event->SetExtraLong(static_cast<long>(total));  // 总数
            wxQueueEvent(m_frame, event);

            lastReportedProgress = progress;
            lastReportTime = now;
            firstReport = false;
        }
    });

    // 执行解包
    int result = m_selectedIndices.empty()
        ? m_unpacker->UnpackAll(m_inputDir, m_outputDir, m_options)
        : m_unpacker->UnpackSelected(m_selectedIndices, m_inputDir, m_outputDir, m_options);
    SLJFP_LOG_INFO(L"Unpack thread finished with result=" + std::to_wstring(result));
    AppendRuntimeTrace(std::string("UnpackThread::Entry finished result=") + std::to_string(result));

    // 发送完成事件
    wxThreadEvent* event = new wxThreadEvent(wxEVT_UNPACK_COMPLETE);
    event->SetPayload(result);
    wxQueueEvent(m_frame, event);

    return (wxThread::ExitCode)0;
}

} // namespace SLJFP

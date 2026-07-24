/**
 * @file UnpackDiag.cpp
 * @brief Minimal CLI diagnostics for current Unpacker interface.
 */

#include "../include/SLJFP_Unpack.h"
#include "../include/SLJFP_AndroidBinaryKey.h"
#include "../include/SLJFP_ErrorCodes.h"
#include "../include/SLJFP_LibsWrapper.h"

#include <cstdint>
#include <fstream>
#include <iostream>
#include <map>
#include <string>
#include <vector>

namespace {

std::string JoinPath(const std::string& base, const std::string& child) {
    if (base.empty()) {
        return child;
    }
    const char last = base.back();
    if (last == '/' || last == '\\') {
        return base + child;
    }
    return base + "/" + child;
}

bool FileExists(const std::string& path) {
    std::ifstream fs(path.c_str(), std::ios::binary);
    return fs.good();
}

std::string ResolveDecryptKeyForDiag(const std::string& inputDir,
                                     const std::string& explicitLibgamePath,
                                     const std::string& userKey,
                                     std::string* keyMessage) {
    if (keyMessage != NULL) {
        keyMessage->clear();
    }

    if (!userKey.empty()) {
        if (keyMessage != NULL) {
            *keyMessage = "Using explicit decrypt key";
        }
        return userKey;
    }

    SLJFP::AndroidBinaryKeyProbeResult probeResult;
    if (SLJFP::TryResolveAndroidLibgameDecryptKey(inputDir, explicitLibgamePath, probeResult)) {
        if (keyMessage != NULL) {
            *keyMessage = "Auto-extracted decrypt key from Android libgame.so: " + probeResult.libgamePath;
        }
        return probeResult.decryptKey;
    }

    if (keyMessage != NULL) {
        if (!probeResult.message.empty()) {
            *keyMessage = "Automatic Android key extraction failed, fallback to default key. Reason: " + probeResult.message;
        } else {
            *keyMessage = "No Android libgame.so with extractable key found, fallback to default key.";
        }
    }
    return std::string();
}

void PrintTypeStats(const std::vector<SLJFP::FileInfo>& files) {
    std::map<unsigned int, uint32_t> codeTypeCounts;
    std::map<unsigned int, uint32_t> compressTypeCounts;
    std::map<unsigned int, uint32_t> packIndexCounts;
    std::map<std::pair<unsigned int, unsigned int>, uint32_t> comboCounts;

    for (size_t i = 0; i < files.size(); ++i) {
        const SLJFP::FileInfo& info = files[i];
        codeTypeCounts[info.m_CodeType]++;
        compressTypeCounts[info.m_CompressType]++;
        packIndexCounts[info.m_PackIndex]++;
        comboCounts[std::make_pair(info.m_CompressType, info.m_CodeType)]++;
    }

    std::cout << "Index stats:\n";
    std::cout << "  packIndex=0: " << packIndexCounts[0] << "\n";
    std::cout << "  packIndex>0: " << (files.size() - packIndexCounts[0]) << "\n";

    std::cout << "  CodeType:";
    for (std::map<unsigned int, uint32_t>::const_iterator it = codeTypeCounts.begin();
         it != codeTypeCounts.end(); ++it) {
        std::cout << " [" << it->first << "=" << it->second << "]";
    }
    std::cout << "\n";

    std::cout << "  CompressType:";
    for (std::map<unsigned int, uint32_t>::const_iterator it = compressTypeCounts.begin();
         it != compressTypeCounts.end(); ++it) {
        std::cout << " [" << it->first << "=" << it->second << "]";
    }
    std::cout << "\n";

    std::cout << "  (compress,code):";
    for (std::map<std::pair<unsigned int, unsigned int>, uint32_t>::const_iterator it = comboCounts.begin();
         it != comboCounts.end(); ++it) {
        std::cout << " [(" << it->first.first << "," << it->first.second << ")=" << it->second << "]";
    }
    std::cout << "\n";
}

const char* DecryptModeToText(SLJFP::DecryptMode mode) {
    switch (mode) {
        case SLJFP::DecryptMode::LJFilePackSMS4:
            return "LJFilePackSMS4";
        case SLJFP::DecryptMode::ApkClientObf:
            return "ApkClientObf";
        case SLJFP::DecryptMode::Auto:
        default:
            return "Auto";
    }
}

void PrintFirstFailedDecryptDiagnostic(const SLJFP::DecryptFailureDiagnostic& diagnostic) {
    std::cout << "  firstFailedDecrypt:\n";
    std::cout << "    fileIndex=" << diagnostic.fileIndex
              << " pathCRC32=" << diagnostic.fileInfo.m_PathFileNameCRC32
              << " packIndex=" << diagnostic.fileInfo.m_PackIndex
              << " size=" << diagnostic.fileInfo.m_Size
              << " originalSize=" << diagnostic.fileInfo.m_SizeOriginal
              << " compressType=" << diagnostic.fileInfo.m_CompressType
              << " codeType=" << diagnostic.fileInfo.m_CodeType
              << " inputSize=" << diagnostic.inputSize
              << " failureCode=" << diagnostic.failureCode << "\n";

    for (size_t i = 0; i < diagnostic.candidates.size(); ++i) {
        const SLJFP::DecryptProbeRecord& record = diagnostic.candidates[i];
        std::cout << "    candidate[" << i << "]"
                  << " id=" << record.candidateId
                  << " mode=" << DecryptModeToText(record.mode)
                  << " decrypt=" << (record.applyDecrypt ? 1 : 0)
                  << " window=" << (record.useFullWindow ? "all" : "1024")
                  << " error=" << record.errorCode
                  << " unzip=" << record.unzipResult
                  << " crcChecked=" << (record.crcChecked ? 1 : 0)
                  << " crcMatched=" << (record.crcMatched ? 1 : 0)
                  << " selected=" << (record.selected ? 1 : 0)
                  << " transformedSize=" << record.transformedSize
                  << " outputSize=" << record.outputSize
                  << "\n";
        std::cout << "      input=" << record.inputSignature
                  << " prefix=" << record.inputPrefixHex << "\n";
        std::cout << "      transformed=" << record.transformedSignature
                  << " prefix=" << record.transformedPrefixHex << "\n";
        if (!record.outputSignature.empty() || !record.outputPrefixHex.empty()) {
            std::cout << "      output=" << record.outputSignature
                      << " prefix=" << record.outputPrefixHex;
            if (record.crcChecked) {
                std::cout << " crcExpected=" << record.expectedCRC32
                          << " crcActual=" << record.actualCRC32;
            }
            std::cout << "\n";
        }
    }
}

void PrintUsage() {
    std::cout << "Usage:\n";
    std::cout << "  ljfp-unpack-diag <input_dir> <output_dir> [mapping_file] [decrypt_key] [thread_count] [stream_mode]\n";
    std::cout << "  Optional named args after positional slots: --android-libgame=<file|dir>\n";
    std::cout << "  - thread_count: 1..N (default 1, for deterministic first-error)\n";
    std::cout << "  - stream_mode: 0/1 (default 0)\n";
}

} // namespace

int main(int argc, char* argv[]) {
    if (argc < 3) {
        PrintUsage();
        return 1;
    }

    const std::string inputDir = argv[1];
    const std::string outputDir = argv[2];
    std::vector<std::string> positionalArgs;
    std::string mappingFile;
    std::string decryptKey;
    std::string androidLibgamePath;
    for (int i = 3; i < argc; ++i) {
        const std::string arg = argv[i];
        if (arg.size() >= 18 && arg.substr(0, 18) == "--android-libgame=") {
            androidLibgamePath = arg.substr(18);
            continue;
        }
        positionalArgs.push_back(arg);
    }

    if (positionalArgs.size() >= 1) {
        mappingFile = positionalArgs[0];
    }
    if (positionalArgs.size() >= 2) {
        decryptKey = positionalArgs[1];
    }
    int threadCount = 1;
    if (positionalArgs.size() >= 3) {
        const int parsed = std::atoi(positionalArgs[2].c_str());
        if (parsed > 0) {
            threadCount = parsed;
        }
    }
    bool streamMode = false;
    if (positionalArgs.size() >= 4) {
        streamMode = (std::atoi(positionalArgs[3].c_str()) != 0);
    }

    std::string indexPath = JoinPath(inputDir, "fl.ljpi");
    if (!FileExists(indexPath)) {
        const std::string ljzipPath = JoinPath(inputDir, "fl.ljzip");
        if (FileExists(ljzipPath)) {
            indexPath = ljzipPath;
        } else {
            std::cerr << "Index file not found: fl.ljpi / fl.ljzip\n";
            return 2;
        }
    }

    std::string decryptKeyMessage;
    const std::string resolvedDecryptKey =
        ResolveDecryptKeyForDiag(inputDir, androidLibgamePath, decryptKey, &decryptKeyMessage);

    std::cout << "InputDir: " << inputDir << "\n";
    std::cout << "OutputDir: " << outputDir << "\n";
    std::cout << "IndexPath: " << indexPath << "\n";
    if (!mappingFile.empty()) {
        std::cout << "MappingFile: " << mappingFile << "\n";
    }
    if (!androidLibgamePath.empty()) {
        std::cout << "AndroidLibgame: " << androidLibgamePath << "\n";
    }
    std::cout << "DecryptKey: " << (resolvedDecryptKey.empty() ? "(default)" : resolvedDecryptKey) << "\n";
    if (!decryptKeyMessage.empty()) {
        std::cout << "DecryptKeySource: " << decryptKeyMessage << "\n";
    }
    std::cout << "\n";
    std::cout << "ThreadCount: " << threadCount << "\n";
    std::cout << "StreamMode: " << (streamMode ? 1 : 0) << "\n\n";

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    if (!resolvedDecryptKey.empty()) {
        unpacker.SetDecryptKey(resolvedDecryptKey);
    }

    int result = unpacker.LoadIndex(indexPath);
    if (result != SLJFP::LJFP_SUCCESS) {
        std::cerr << "LoadIndex failed: " << result << "\n";
        std::wcout << L"ErrorMessage: " << SLJFP::GetErrorMessage(static_cast<SLJFP::ErrorCode>(result)) << L"\n";
        return 3;
    }

    const std::vector<SLJFP::FileInfo>& files = unpacker.GetFileList();
    std::cout << "TotalFiles: " << files.size() << "\n";
    PrintTypeStats(files);

    if (!mappingFile.empty()) {
        int mapResult = unpacker.LoadPathMapping(mappingFile);
        std::cout << "LoadPathMapping: " << mapResult
                  << " count=" << unpacker.GetPathMappingCount() << "\n";
    }

    SLJFP::UnpackOptions options;
    options.verifyCRC32 = true;
    options.overwriteExisting = false;
    options.createDirectories = true;
    options.threadCount = threadCount;
    options.useStreamMode = streamMode;
    options.streamChunkSize = 4 * 1024 * 1024;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.decryptKey = resolvedDecryptKey;

    unpacker.SetProgressCallback([](float progress, uint32_t current, uint32_t total) {
        if (total == 0) {
            return;
        }
        if (current == 0 || current == total || (current % 5000 == 0)) {
            std::cout << "progress=" << (progress * 100.0f)
                      << "% (" << current << "/" << total << ")\n";
        }
    });

    result = unpacker.UnpackAll(inputDir, outputDir, options);

    std::cout << "\nResult:\n";
    std::cout << "  result=" << result << "\n";
    std::cout << "  total=" << unpacker.GetTotalFiles() << "\n";
    std::cout << "  success=" << unpacker.GetProcessedFiles() << "\n";
    std::cout << "  failed=" << unpacker.GetFailedFiles() << "\n";
    std::cout << "  processedBytes=" << unpacker.GetProcessedBytes() << "\n";

    const std::map<int, uint32_t>& errCounts = unpacker.GetLastErrorCodeCounts();
    if (!errCounts.empty()) {
        std::cout << "  errorCodeBreakdown:";
        for (std::map<int, uint32_t>::const_iterator it = errCounts.begin(); it != errCounts.end(); ++it) {
            std::cout << " [" << it->first << "=" << it->second << "]";
        }
        std::cout << "\n";
        std::cout << "  firstErrorCode=" << unpacker.GetFirstErrorCode()
                  << " firstErrorFileIndex=" << unpacker.GetFirstErrorFileIndex() << "\n";

        SLJFP::DecryptFailureDiagnostic diagnostic;
        if (unpacker.GetFirstFailedDecryptDiagnostic(diagnostic)) {
            PrintFirstFailedDecryptDiagnostic(diagnostic);
        }
    }

    if (result != SLJFP::LJFP_SUCCESS) {
        std::wcout << L"  message=" << SLJFP::GetErrorMessage(static_cast<SLJFP::ErrorCode>(result)) << L"\n";
    }

    return (result == SLJFP::LJFP_SUCCESS) ? 0 : 4;
}

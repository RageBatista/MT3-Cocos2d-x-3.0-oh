#include "SLJFP_UnpackSourceIO.h"

#include "../include/SLJFP_ErrorCodes.h"

namespace SLJFP {
namespace detail {

namespace {

std::string JoinPathSegments(const std::string& root, const std::string& leaf) {
    if (root.empty()) {
        return leaf;
    }
    if (root[root.size() - 1] == '/' || root[root.size() - 1] == '\\') {
        return root + leaf;
    }
    return root + "/" + leaf;
}

} // namespace

std::string BuildSourceFilePath(const std::string& inputDir, const FileInfo& fileInfo) {
    if (fileInfo.m_PackIndex == 0) {
        return JoinPathSegments(inputDir, std::to_string(fileInfo.m_PathFileNameCRC32));
    }
    return JoinPathSegments(inputDir, std::to_string(fileInfo.m_PackIndex) + ".ljfp");
}

int OpenSourceFileStream(const std::string& inputDir,
                         const FileInfo& fileInfo,
                         std::ifstream& stream,
                         std::string& sourcePath) {
    sourcePath = BuildSourceFilePath(inputDir, fileInfo);
    stream.open(sourcePath.c_str(), std::ios::binary);
    if (!stream.is_open()) {
        return (fileInfo.m_PackIndex == 0) ? LJFP_ERROR_FILE_NOT_FOUND : LJFP_ERROR_PACK_NOT_FOUND;
    }

    if (fileInfo.m_PackIndex > 0) {
        stream.seekg(fileInfo.m_Pos, std::ios::beg);
        if (stream.fail()) {
            stream.close();
            return LJFP_ERROR_FILE_READ_FAILED;
        }
    }

    return LJFP_SUCCESS;
}

int ReadSourceFileData(const std::string& inputDir,
                       const FileInfo& fileInfo,
                       std::vector<unsigned char>& outputData) {
    outputData.clear();

    std::ifstream stream;
    std::string sourcePath;
    const int openResult = OpenSourceFileStream(inputDir, fileInfo, stream, sourcePath);
    if (openResult != LJFP_SUCCESS) {
        return openResult;
    }

    uint32_t outputSize = fileInfo.m_Size;
    if (fileInfo.m_PackIndex == 0) {
        stream.seekg(0, std::ios::end);
        const std::streamoff fileSize = stream.tellg();
        if (fileSize < 0) {
            stream.close();
            return LJFP_ERROR_FILE_READ_FAILED;
        }
        if (fileSize > static_cast<std::streamoff>(MAX_DECOMPRESS_SIZE)) {
            stream.close();
            return LJFP_ERROR_DECOMPRESS_TOO_LARGE;
        }
        outputSize = static_cast<uint32_t>(fileSize);
        stream.seekg(0, std::ios::beg);
    }

    outputData.resize(outputSize);
    if (outputSize > 0) {
        stream.read(reinterpret_cast<char*>(outputData.data()), outputSize);
        if (stream.fail()) {
            outputData.clear();
            stream.close();
            return LJFP_ERROR_FILE_READ_FAILED;
        }
    }

    stream.close();
    return LJFP_SUCCESS;
}

} // namespace detail
} // namespace SLJFP

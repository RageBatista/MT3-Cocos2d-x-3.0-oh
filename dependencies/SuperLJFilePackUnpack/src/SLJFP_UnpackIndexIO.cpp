#include "SLJFP_UnpackIndexIO.h"

#include "../include/SLJFP_ErrorCodes.h"

#include <cstring>
#include <fstream>

namespace SLJFP {
namespace detail {

namespace {

const uint32_t kMinLjpiEntrySize = 24u;
const uint32_t kMaxLjpiEntryCount = 1000000u;

bool ReadUInt32Le(const unsigned char*& ptr,
                  const unsigned char* end,
                  uint32_t& outValue) {
    if (ptr == nullptr || end == nullptr || ptr > end || static_cast<size_t>(end - ptr) < 4u) {
        return false;
    }

    outValue = static_cast<uint32_t>(ptr[0]) |
               (static_cast<uint32_t>(ptr[1]) << 8) |
               (static_cast<uint32_t>(ptr[2]) << 16) |
               (static_cast<uint32_t>(ptr[3]) << 24);
    ptr += 4;
    return true;
}

bool ParseEntry(const unsigned char*& ptr,
                const unsigned char* end,
                FileInfo& outFileInfo) {
    uint32_t value = 0;
    if (!ReadUInt32Le(ptr, end, value)) {
        return false;
    }
    outFileInfo.m_PackIndex = value;

    if (outFileInfo.m_PackIndex > 0) {
        if (!ReadUInt32Le(ptr, end, value)) {
            return false;
        }
        outFileInfo.m_Pos = value;
    }

    if (!ReadUInt32Le(ptr, end, value)) {
        return false;
    }
    outFileInfo.m_Size = value;
    if (!ReadUInt32Le(ptr, end, value)) {
        return false;
    }
    outFileInfo.m_CRC32 = value;
    if (!ReadUInt32Le(ptr, end, value)) {
        return false;
    }
    outFileInfo.m_CompressType = value;
    if (!ReadUInt32Le(ptr, end, value)) {
        return false;
    }
    outFileInfo.m_CodeType = value;

    if (outFileInfo.m_CompressType > 0 || outFileInfo.m_CodeType > 0) {
        if (!ReadUInt32Le(ptr, end, value)) {
            return false;
        }
        outFileInfo.m_SizeOriginal = value;
        if (!ReadUInt32Le(ptr, end, value)) {
            return false;
        }
        outFileInfo.m_CRC32Original = value;
    } else {
        outFileInfo.m_SizeOriginal = outFileInfo.m_Size;
        outFileInfo.m_CRC32Original = outFileInfo.m_CRC32;
    }

    if (!ReadUInt32Le(ptr, end, value)) {
        return false;
    }
    outFileInfo.m_PathFileNameCRC32 = value;
    return true;
}

} // namespace

int ParseLjpiBuffer(const unsigned char* data, uint32_t size, IndexLoadResult& outResult) {
    if (data == nullptr || size < 4) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    const unsigned char* ptr = data;
    const unsigned char* end = data + size;
    uint32_t fileCount = 0;
    if (!ReadUInt32Le(ptr, end, fileCount)) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    outResult.fileList.clear();
    outResult.totalBytes = 0;

    const uint32_t payloadSize = size - 4u;
    if (fileCount > kMaxLjpiEntryCount ||
        (fileCount > 0 && fileCount > payloadSize / kMinLjpiEntrySize)) {
        return LJFP_ERROR_INDEX_CORRUPTED;
    }

    outResult.fileList.reserve(fileCount);

    for (uint32_t i = 0; i < fileCount; ++i) {
        FileInfo fileInfo;
        if (!ParseEntry(ptr, end, fileInfo)) {
            outResult.fileList.clear();
            outResult.totalBytes = 0;
            return LJFP_ERROR_INDEX_CORRUPTED;
        }
        outResult.totalBytes += fileInfo.m_SizeOriginal;
        outResult.fileList.push_back(fileInfo);
    }

    return LJFP_SUCCESS;
}

int LoadLjpiIndexData(const std::string& ljpiPath, IndexLoadResult& outResult) {
    std::ifstream fs(ljpiPath.c_str(), std::ios::binary);
    if (!fs.is_open()) {
        return LJFP_ERROR_FILE_OPEN_FAILED;
    }

    fs.seekg(0, std::ios::end);
    const std::streamoff size = fs.tellg();
    fs.seekg(0, std::ios::beg);
    if (size < 4) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    std::vector<unsigned char> data(static_cast<size_t>(size));
    fs.read(reinterpret_cast<char*>(data.data()), size);
    if (fs.fail()) {
        return LJFP_ERROR_FILE_READ_FAILED;
    }

    return ParseLjpiBuffer(data.data(), static_cast<uint32_t>(data.size()), outResult);
}

int LoadLjzipIndexData(const std::string& ljzipPath,
                       const IndexLoadDependencies& deps,
                       IndexLoadResult& outResult) {
    std::ifstream fs(ljzipPath.c_str(), std::ios::binary);
    if (!fs.is_open()) {
        return LJFP_ERROR_FILE_OPEN_FAILED;
    }

    fs.seekg(0, std::ios::end);
    const std::streamoff totalSize = fs.tellg();
    fs.seekg(0, std::ios::beg);
    if (totalSize < static_cast<std::streamoff>(sizeof(uint32_t) * 5)) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    uint32_t magicKey = 0;
    uint32_t encryptedSize = 0;
    uint32_t compressedSize = 0;
    uint32_t originalSize = 0;
    uint32_t originalCRC32 = 0;

    if (!fs.read(reinterpret_cast<char*>(&magicKey), sizeof(magicKey)) ||
        !fs.read(reinterpret_cast<char*>(&encryptedSize), sizeof(encryptedSize))) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    if (magicKey != LJZIP_MAGIC_KEY) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    const uint64_t minimumTailSize = sizeof(uint32_t) * 3;
    const uint64_t payloadCapacity = static_cast<uint64_t>(totalSize) - sizeof(uint32_t) * 2;
    if (payloadCapacity < minimumTailSize ||
        encryptedSize > payloadCapacity - minimumTailSize) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    std::vector<unsigned char> encryptedData(encryptedSize, 0);
    if (encryptedSize > 0 &&
        !fs.read(reinterpret_cast<char*>(encryptedData.data()), encryptedSize)) {
        return LJFP_ERROR_FILE_READ_FAILED;
    }

    if (!fs.read(reinterpret_cast<char*>(&compressedSize), sizeof(compressedSize)) ||
        !fs.read(reinterpret_cast<char*>(&originalSize), sizeof(originalSize)) ||
        !fs.read(reinterpret_cast<char*>(&originalCRC32), sizeof(originalCRC32))) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    if (compressedSize == 0 || compressedSize > encryptedSize) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }
    if (originalSize > MAX_DECOMPRESS_SIZE) {
        return LJFP_ERROR_DECOMPRESS_TOO_LARGE;
    }
    if (deps.verifyCRC32 && deps.crc32Func == nullptr) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }
    if ((compressedSize > 0 && deps.unzipFunc == nullptr) ||
        deps.desms4Func == nullptr) {
        return LJFP_ERROR_INDEX_INVALID_FORMAT;
    }

    std::vector<unsigned char> decryptedData(encryptedSize, 0);
    if (encryptedSize > 0) {
        deps.desms4Func(encryptedData.data(),
                        decryptedData.data(),
                        encryptedSize,
                        deps.decryptKey);
    }

    unsigned int decompressedSize = originalSize;
    std::vector<unsigned char> decompressedData(decompressedSize, 0);
    const int unzipResult = deps.unzipFunc(
        decompressedData.data(),
        &decompressedSize,
        decryptedData.data(),
        compressedSize);
    if (unzipResult != 0) {
        return LJFP_ERROR_INDEX_DECOMPRESS_FAILED;
    }
    if (decompressedSize != originalSize) {
        return LJFP_ERROR_INDEX_CORRUPTED;
    }

    decompressedData.resize(decompressedSize);

    if (deps.verifyCRC32 && deps.crc32Func != nullptr) {
        const uint32_t actualCRC32 = deps.crc32Func(
            0,
            decompressedData.data(),
            static_cast<unsigned int>(decompressedData.size()));
        if (actualCRC32 != originalCRC32) {
            return LJFP_ERROR_CRC32_MISMATCH;
        }
    }

    return ParseLjpiBuffer(decompressedData.data(),
                           static_cast<uint32_t>(decompressedData.size()),
                           outResult);
}

std::string GetParentDirectory(const std::string& filePath) {
    const std::string::size_type pos = filePath.find_last_of("/\\");
    if (pos == std::string::npos) {
        return ".";
    }
    return filePath.substr(0, pos);
}

} // namespace detail
} // namespace SLJFP

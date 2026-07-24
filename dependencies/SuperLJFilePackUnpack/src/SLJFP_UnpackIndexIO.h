#ifndef SLJFP_UNPACKINDEXIO_H
#define SLJFP_UNPACKINDEXIO_H

#include "../include/SLJFP_Unpack.h"

#include <cstdint>
#include <string>
#include <vector>

namespace SLJFP {
namespace detail {

struct IndexLoadDependencies {
    CRC32_Func crc32Func;
    UnZip_Func unzipFunc;
    DeSMS4_Func desms4Func;
    std::string decryptKey;
    bool verifyCRC32;

    IndexLoadDependencies()
        : crc32Func(nullptr)
        , unzipFunc(nullptr)
        , desms4Func(nullptr)
        , verifyCRC32(false) {}
};

struct IndexLoadResult {
    std::vector<FileInfo> fileList;
    uint64_t totalBytes;

    IndexLoadResult()
        : totalBytes(0) {}
};

int LoadLjpiIndexData(const std::string& ljpiPath, IndexLoadResult& outResult);
int LoadLjzipIndexData(const std::string& ljzipPath,
                       const IndexLoadDependencies& deps,
                       IndexLoadResult& outResult);
int ParseLjpiBuffer(const unsigned char* data, uint32_t size, IndexLoadResult& outResult);
std::string GetParentDirectory(const std::string& filePath);

} // namespace detail
} // namespace SLJFP

#endif // SLJFP_UNPACKINDEXIO_H

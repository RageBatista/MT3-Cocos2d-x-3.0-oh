#ifndef SLJFP_UNPACKSOURCEIO_H
#define SLJFP_UNPACKSOURCEIO_H

#include "../include/SLJFP_Unpack.h"

#include <fstream>
#include <string>
#include <vector>

namespace SLJFP {
namespace detail {

std::string BuildSourceFilePath(const std::string& inputDir, const FileInfo& fileInfo);
int OpenSourceFileStream(const std::string& inputDir,
                         const FileInfo& fileInfo,
                         std::ifstream& stream,
                         std::string& sourcePath);
int ReadSourceFileData(const std::string& inputDir,
                       const FileInfo& fileInfo,
                       std::vector<unsigned char>& outputData);

} // namespace detail
} // namespace SLJFP

#endif // SLJFP_UNPACKSOURCEIO_H

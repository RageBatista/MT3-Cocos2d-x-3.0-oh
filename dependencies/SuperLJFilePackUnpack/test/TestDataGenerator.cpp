/**
 * @file TestDataGenerator.cpp
 * @brief 测试数据生成器 - 创建用于测试的 .ljpi 和 .ljfp 文件
 * @version 1.0
 * @date 2025-01-03
 *
 * 用法:
 *   ljfp-testgen <输出目录> [选项]
 *
 * 选项:
 *   --files <N>        生成 N 个文件 (默认: 10)
 *   --size <KB>        每个文件的平均大小 (默认: 64KB)
 *   --compress         启用压缩
 *   --encrypt          启用加密
 */

#include "../include/SLJFP_LibsWrapper.h"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstring>
#include <cstdlib>
#include <ctime>

// MiniZ 返回值
#define MZ_OK 0

// 默认密钥
const std::string DEFAULT_KEY = "locojoy123456789";

// 文件信息结构 (与 FileInfo 对应)
struct TestFileInfo {
    unsigned int packIndex;
    unsigned int pos;
    unsigned int size;
    unsigned int crc32;
    unsigned int compressType;
    unsigned int codeType;
    unsigned int sizeOriginal;
    unsigned int crc32Original;
    unsigned int pathFileNameCRC32;
};

// 写入 4 字节无符号整数 (小端)
void WriteUInt32(std::ofstream& file, unsigned int value) {
    unsigned char bytes[4];
    bytes[0] = (unsigned char)(value & 0xFF);
    bytes[1] = (unsigned char)((value >> 8) & 0xFF);
    bytes[2] = (unsigned char)((value >> 16) & 0xFF);
    bytes[3] = (unsigned char)((value >> 24) & 0xFF);
    file.write((char*)bytes, 4);
}

// 生成随机数据
void GenerateRandomData(unsigned char* data, size_t size, bool compressible) {
    if (compressible) {
        // 生成可压缩数据 (重复模式)
        for (size_t i = 0; i < size; ++i) {
            data[i] = (unsigned char)((i % 64) + ((i / 1024) % 32));
        }
    } else {
        // 生成伪随机数据
        unsigned int seed = (unsigned int)time(nullptr) + (unsigned int)size;
        for (size_t i = 0; i < size; ++i) {
            seed = seed * 1103515245 + 12345;
            data[i] = (unsigned char)(seed >> 16);
        }
    }
}

// 创建目录
bool CreateDirectory(const std::string& path) {
#ifdef _WIN32
    std::string cmd = "if not exist \"" + path + "\" mkdir \"" + path + "\"";
#else
    std::string cmd = "mkdir -p \"" + path + "\"";
#endif
    return system(cmd.c_str()) == 0;
}

// 显示帮助
void ShowHelp() {
    std::cout << "SuperLJFilePackUnpack Test Data Generator v1.0\n\n";
    std::cout << "Usage:\n";
    std::cout << "  ljfp-testgen <output_dir> [options]\n\n";
    std::cout << "Options:\n";
    std::cout << "  --files <N>      Generate N files (default: 10)\n";
    std::cout << "  --size <KB>      Average file size in KB (default: 64)\n";
    std::cout << "  --compress       Enable compression\n";
    std::cout << "  --encrypt        Enable encryption\n";
    std::cout << "  --help           Show this help\n\n";
    std::cout << "Example:\n";
    std::cout << "  ljfp-testgen ./testdata --files 20 --compress --encrypt\n\n";
}

int main(int argc, char* argv[]) {
    // 默认参数
    std::string outputDir = "./testdata/";
    int numFiles = 10;
    int avgSizeKB = 64;
    bool enableCompress = false;
    bool enableEncrypt = false;

    // 解析命令行
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];

        if (arg == "--help" || arg == "-h") {
            ShowHelp();
            return 0;
        } else if (arg == "--files" && i + 1 < argc) {
            numFiles = atoi(argv[++i]);
        } else if (arg == "--size" && i + 1 < argc) {
            avgSizeKB = atoi(argv[++i]);
        } else if (arg == "--compress") {
            enableCompress = true;
        } else if (arg == "--encrypt") {
            enableEncrypt = true;
        } else if (arg[0] != '-') {
            outputDir = arg;
        }
    }

    // 确保目录以分隔符结尾
    if (outputDir.back() != '/' && outputDir.back() != '\\') {
        outputDir += "/";
    }

    std::cout << "========================================\n";
    std::cout << "  Test Data Generator\n";
    std::cout << "========================================\n";
    std::cout << "Output directory: " << outputDir << "\n";
    std::cout << "Number of files:  " << numFiles << "\n";
    std::cout << "Average size:     " << avgSizeKB << " KB\n";
    std::cout << "Compression:      " << (enableCompress ? "Yes" : "No") << "\n";
    std::cout << "Encryption:       " << (enableEncrypt ? "Yes" : "No") << "\n";
    std::cout << "========================================\n\n";

    // 创建输出目录
    if (!CreateDirectory(outputDir)) {
        std::cerr << "Error: Cannot create output directory\n";
        return 1;
    }

    // 初始化随机种子
    srand((unsigned int)time(nullptr));

    // 存储所有文件信息
    std::vector<TestFileInfo> fileInfos;

    // 创建 .ljfp 包文件
    std::string packPath = outputDir + "1.ljfp";
    std::ofstream packFile(packPath, std::ios::binary);
    if (!packFile) {
        std::cerr << "Error: Cannot create pack file\n";
        return 1;
    }

    unsigned int currentPos = 0;

    std::cout << "Generating files...\n";

    for (int i = 0; i < numFiles; ++i) {
        // 随机文件大小 (50% - 150% 的平均大小)
        size_t fileSize = (size_t)(avgSizeKB * 1024 * (0.5 + (rand() % 100) / 100.0));

        // 生成原始数据
        unsigned char* originalData = new unsigned char[fileSize];
        GenerateRandomData(originalData, fileSize, enableCompress);

        // 计算原始 CRC32
        unsigned int originalCRC = SLJFP_crc32(0, originalData, (unsigned int)fileSize);

        // 处理后的数据
        unsigned char* processedData = originalData;
        size_t processedSize = fileSize;
        bool needFreeProcessed = false;

        // 压缩
        if (enableCompress) {
            unsigned char* compressedData = new unsigned char[fileSize + 65536];
            unsigned int compressedSize = (unsigned int)(fileSize + 65536);

            unsigned int result = SLJFP_mz_compress2(compressedData, &compressedSize,
                                                      originalData, (unsigned int)fileSize, 6);
            if (result == MZ_OK && compressedSize < fileSize) {
                processedData = compressedData;
                processedSize = compressedSize;
                needFreeProcessed = true;
            } else {
                delete[] compressedData;
            }
        }

        // 加密 (需要 16 字节对齐)
        if (enableEncrypt) {
            unsigned int paddedSize = ((unsigned int)processedSize + 15) / 16 * 16;
            unsigned char* encryptedData = new unsigned char[paddedSize];
            memset(encryptedData, 0, paddedSize);
            memcpy(encryptedData, processedData, processedSize);

            unsigned char* tempData = new unsigned char[paddedSize];
            SLJFP_SMS4Ex(encryptedData, tempData, paddedSize, DEFAULT_KEY);

            if (needFreeProcessed && processedData != originalData) {
                delete[] processedData;
            }

            delete[] encryptedData;
            processedData = tempData;
            processedSize = paddedSize;
            needFreeProcessed = true;
        }

        // 计算处理后的 CRC32
        unsigned int processedCRC = SLJFP_crc32(0, processedData, (unsigned int)processedSize);

        // 写入包文件
        packFile.write((char*)processedData, processedSize);

        // 生成路径文件名 CRC32 (模拟)
        std::string fakePath = "file_" + std::to_string(i) + ".dat";
        unsigned int pathCRC = SLJFP_crc32(0, (unsigned char*)fakePath.c_str(),
                                            (unsigned int)fakePath.length());

        // 记录文件信息
        TestFileInfo info;
        info.packIndex = 1;  // 包索引
        info.pos = currentPos;
        info.size = (unsigned int)processedSize;
        info.crc32 = processedCRC;
        info.compressType = (needFreeProcessed && enableCompress) ? 1 : 0;
        info.codeType = enableEncrypt ? 1 : 0;
        info.sizeOriginal = (unsigned int)fileSize;
        info.crc32Original = originalCRC;
        info.pathFileNameCRC32 = pathCRC;
        fileInfos.push_back(info);

        currentPos += (unsigned int)processedSize;

        // 清理
        delete[] originalData;
        if (needFreeProcessed && processedData != originalData) {
            delete[] processedData;
        }

        // 进度
        std::cout << "  [" << (i + 1) << "/" << numFiles << "] "
                  << "Size: " << (fileSize / 1024) << "KB -> " << (processedSize / 1024) << "KB\n";
    }

    packFile.close();

    // 创建 .ljpi 索引文件
    std::string indexPath = outputDir + "fl.ljpi";
    std::ofstream indexFile(indexPath, std::ios::binary);
    if (!indexFile) {
        std::cerr << "Error: Cannot create index file\n";
        return 1;
    }

    std::cout << "\nWriting index file...\n";

    // 写入文件数量
    WriteUInt32(indexFile, (unsigned int)fileInfos.size());

    // 写入每个文件的信息
    for (size_t i = 0; i < fileInfos.size(); ++i) {
        const TestFileInfo& info = fileInfos[i];

        // PackIndex (>0 表示打包文件)
        WriteUInt32(indexFile, info.packIndex);
        WriteUInt32(indexFile, info.pos);

        // Size, CRC32, CompressType, CodeType
        WriteUInt32(indexFile, info.size);
        WriteUInt32(indexFile, info.crc32);
        WriteUInt32(indexFile, info.compressType);
        WriteUInt32(indexFile, info.codeType);

        // 如果有压缩或加密，写入原始信息
        if (info.compressType > 0 || info.codeType > 0) {
            WriteUInt32(indexFile, info.sizeOriginal);
            WriteUInt32(indexFile, info.crc32Original);
        }

        // PathFileNameCRC32
        WriteUInt32(indexFile, info.pathFileNameCRC32);
    }

    indexFile.close();

    // 创建映射文件 (用于验证)
    std::string mapPath = outputDir + "filemap.txt";
    std::ofstream mapFile(mapPath);
    if (mapFile) {
        mapFile << "# Test Data File Map\n";
        mapFile << "# Format: Index, PathCRC32, OriginalSize, OriginalCRC32\n\n";
        for (size_t i = 0; i < fileInfos.size(); ++i) {
            const TestFileInfo& info = fileInfos[i];
            mapFile << i << ", "
                    << std::hex << info.pathFileNameCRC32 << std::dec << ", "
                    << info.sizeOriginal << ", "
                    << std::hex << info.crc32Original << std::dec << "\n";
        }
        mapFile.close();
    }

    std::cout << "\n========================================\n";
    std::cout << "  Generation Complete!\n";
    std::cout << "========================================\n";
    std::cout << "Generated files:\n";
    std::cout << "  " << packPath << " (" << (currentPos / 1024) << " KB)\n";
    std::cout << "  " << indexPath << "\n";
    std::cout << "  " << mapPath << "\n";
    std::cout << "========================================\n\n";

    return 0;
}

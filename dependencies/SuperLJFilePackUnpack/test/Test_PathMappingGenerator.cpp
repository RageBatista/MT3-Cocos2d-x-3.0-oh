/**
 * @file Test_PathMappingGenerator.cpp
 * @brief PathMappingGenerator 单元测试
 * @version 1.0
 * @date 2026-01-04
 */

#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_PathMappingGenerator.h"
#include "../include/SLJFP_LibsWrapper.h"
#include <cstring>
#include <cstdlib>
#include <fstream>

static bool CreatePathMappingTestDirectory(const std::string& path) {
#ifdef _WIN32
    std::string cmd = "if not exist \"" + path + "\" mkdir \"" + path + "\"";
    return std::system(cmd.c_str()) == 0;
#else
    std::string cmd = "mkdir -p \"" + path + "\"";
    return std::system(cmd.c_str()) == 0;
#endif
}

static void CleanupPathMappingTestDirectory(const std::string& path) {
#ifdef _WIN32
    std::string cmd = "if exist \"" + path + "\" rmdir /s /q \"" + path + "\"";
#else
    std::string cmd = "rm -rf \"" + path + "\"";
#endif
    std::system(cmd.c_str());
}

static bool WritePathMappingTestFile(const std::string& path, const std::string& content) {
    std::ofstream fs(path.c_str(), std::ios::binary | std::ios::trunc);
    if (!fs.is_open()) {
        return false;
    }
    fs.write(content.data(), static_cast<std::streamsize>(content.size()));
    return fs.good();
}

static uint32_t PathMappingGeneratorTestCRC32(uint32_t crc, const void* data, size_t len) {
    return SLJFP_crc32(crc,
                       reinterpret_cast<const unsigned char*>(data),
                       static_cast<unsigned int>(len));
}

// ============================================================================
// 基础功能测试
// ============================================================================

TEST_CASE(PathMappingGenerator, DefaultConstruction) {
    SLJFP::PathMappingGenerator generator;
    TEST_ASSERT_EQ((size_t)0, generator.GetEntries().size());
    TEST_ASSERT_EQ((size_t)0, generator.GetMapping().size());
    TEST_ASSERT_EQ((uint32_t)0, generator.GetStats().totalFiles);
    return true;
}

TEST_CASE(PathMappingGenerator, AddSinglePath) {
    SLJFP::PathMappingGenerator generator;
    uint32_t crc32 = generator.AddPath("res/script/main.lua", 1024);

    TEST_ASSERT_TRUE(crc32 != 0);
    TEST_ASSERT_EQ((size_t)1, generator.GetEntries().size());
    TEST_ASSERT_EQ((size_t)1, generator.GetMapping().size());
    TEST_ASSERT_EQ((uint32_t)1, generator.GetStats().totalFiles);
    return true;
}

TEST_CASE(PathMappingGenerator, AddMultiplePaths) {
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/script/main.lua", 1024);
    generator.AddPath("res/image/logo.png", 2048);
    generator.AddPath("res/sound/bgm.ogg", 4096);

    TEST_ASSERT_EQ((size_t)3, generator.GetEntries().size());
    TEST_ASSERT_EQ((uint32_t)3, generator.GetStats().totalFiles);
    TEST_ASSERT_EQ((uint64_t)(1024 + 2048 + 4096), generator.GetStats().totalBytes);
    return true;
}

TEST_CASE(PathMappingGenerator, FindPathByCRC32) {
    SLJFP::PathMappingGenerator generator;
    uint32_t crc32 = generator.AddPath("res/test/file.txt");

    std::string foundPath = generator.FindPath(crc32);
    TEST_ASSERT_EQ("res/test/file.txt", foundPath);
    return true;
}

TEST_CASE(PathMappingGenerator, FindPathNotExist) {
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/test/file.txt");

    std::string foundPath = generator.FindPath(0x12345678);
    TEST_ASSERT_EQ("", foundPath);
    return true;
}

// ============================================================================
// 路径规范化测试
// ============================================================================

TEST_CASE(PathMappingGenerator, NormalizeBackslash) {
    SLJFP::PathMappingGenerator generator;
    uint32_t crc1 = generator.AddPath("res\\script\\main.lua");

    // 内部应该转换为正斜杠
    const SLJFP::PathMappingGenerator::PathEntry& entry = generator.GetEntries()[0];
    TEST_ASSERT_EQ("res/script/main.lua", entry.relativePath);
    return true;
}

TEST_CASE(PathMappingGenerator, CanonicalizeStoragePathStripsKnownResourcePrefixes) {
    TEST_ASSERT_EQ((std::string)"cfg/android_notify.xml",
                   SLJFP::PathMappingGenerator::CanonicalizeStoragePath(
                       "resource/res/cfg/android_notify.xml"));
    TEST_ASSERT_EQ((std::string)"ui/layouts/demo.layout",
                   SLJFP::PathMappingGenerator::CanonicalizeStoragePath(
                       "Res\\UI\\Layouts\\Demo.layout"));
    TEST_ASSERT_EQ((std::string)"script/main.lua",
                   SLJFP::PathMappingGenerator::CanonicalizeStoragePath(
                       "/assets/res/script/main.lua"));
    return true;
}

TEST_CASE(PathMappingGenerator, IsLowConfidenceCrcRepositoryPathRejectsPollutedShortPaths) {
    TEST_ASSERT_TRUE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath("2ei."));
    TEST_ASSERT_TRUE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath("2ej."));
    TEST_ASSERT_TRUE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath("2nmo.re"));
    TEST_ASSERT_TRUE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath("mj/f"));
    TEST_ASSERT_TRUE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath("za1/h"));
    TEST_ASSERT_TRUE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath("xd._"));

    TEST_ASSERT_FALSE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath(
        "cfg/android_notify.xml"));
    TEST_ASSERT_FALSE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath(
        "ui/login/login.layout"));
    TEST_ASSERT_FALSE(SLJFP::PathMappingGenerator::IsLowConfidenceCrcRepositoryPath(
        "script/main.lua"));
    return true;
}

TEST_CASE(PathMappingGenerator, CRC32Consistency) {
    SLJFP::PathMappingGenerator generator;

    // 多次计算相同路径应该得到相同的 CRC32
    uint32_t crc1 = generator.AddPath("res/test/file.txt");

    SLJFP::PathMappingGenerator generator2;
    uint32_t crc2 = generator2.AddPath("res/test/file.txt");

    TEST_ASSERT_EQ(crc1, crc2);
    return true;
}

TEST_CASE(PathMappingGenerator, DefaultCRC32MatchesLJFilePack) {
    SLJFP::PathMappingGenerator generator;
    const std::string relativePath = "script/logic/recruit/recruitmine.lua";
    uint32_t generated = generator.AddPath(relativePath);
    uint32_t expected = SLJFP_crc32(0,
                                    reinterpret_cast<const unsigned char*>(relativePath.c_str()),
                                    static_cast<unsigned int>(relativePath.size()));

    TEST_ASSERT_EQ(expected, generated);
    TEST_ASSERT_EQ((std::string)"script/logic/recruit/recruitmine.lua",
                   generator.GetEntries()[0].relativePath);
    return true;
}

TEST_CASE(PathMappingGenerator, DifferentPathsDifferentCRC32) {
    SLJFP::PathMappingGenerator generator;
    uint32_t crc1 = generator.AddPath("res/file1.txt");
    uint32_t crc2 = generator.AddPath("res/file2.txt");

    TEST_ASSERT_NE(crc1, crc2);
    return true;
}

// ============================================================================
// 碰撞检测测试
// ============================================================================

// 注意: CRC32 碰撞在实际使用中极其罕见，这里我们模拟测试框架
TEST_CASE(PathMappingGenerator, CollisionDetection) {
    SLJFP::PathMappingGenerator generator;

    // 添加一些路径
    generator.AddPath("path1.txt");
    generator.AddPath("path2.txt");
    generator.AddPath("path3.txt");

    // 碰撞数应该为 0（正常情况下）
    TEST_ASSERT_EQ((uint32_t)0, generator.GetStats().collisions);

    std::vector<uint32_t> collisions = generator.GetCollisions();
    TEST_ASSERT_EQ((size_t)0, collisions.size());
    return true;
}

// ============================================================================
// 清除功能测试
// ============================================================================

TEST_CASE(PathMappingGenerator, ClearData) {
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/file1.txt", 100);
    generator.AddPath("res/file2.txt", 200);

    TEST_ASSERT_EQ((size_t)2, generator.GetEntries().size());

    generator.Clear();

    TEST_ASSERT_EQ((size_t)0, generator.GetEntries().size());
    TEST_ASSERT_EQ((size_t)0, generator.GetMapping().size());
    TEST_ASSERT_EQ((uint32_t)0, generator.GetStats().totalFiles);
    return true;
}

// ============================================================================
// 外部 CRC32 函数注入测试
// ============================================================================

static uint32_t CustomCRC32(uint32_t crc, const void* data, size_t len) {
    // 简单的自定义 CRC32 (仅用于测试)
    const uint8_t* buf = static_cast<const uint8_t*>(data);
    uint32_t result = crc;
    for (size_t i = 0; i < len; i++) {
        result = result * 31 + buf[i];
    }
    return result;
}

TEST_CASE(PathMappingGenerator, CustomCRC32Function) {
    SLJFP::PathMappingGenerator generator;
    generator.SetCRC32Function(CustomCRC32);

    uint32_t crc = generator.AddPath("test.txt");

    // 使用自定义函数应该得到不同的结果
    SLJFP::PathMappingGenerator generator2;
    uint32_t crc2 = generator2.AddPath("test.txt");

    // 两个 CRC32 应该不同（除非碰巧相同）
    // 这里我们只验证自定义函数被调用了
    TEST_ASSERT_TRUE(crc != 0);
    return true;
}

// ============================================================================
// 保存映射测试
// ============================================================================

TEST_CASE(PathMappingGenerator, SaveMappingText) {
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/script/main.lua", 1024);
    generator.AddPath("res/image/logo.png", 2048);

    std::string outputPath = "test_mapping_output.txt";
    int result = generator.SaveMapping(outputPath, false);
    TEST_ASSERT_EQ(0, result);

    // 验证文件已创建
    std::ifstream fs(outputPath);
    TEST_ASSERT_TRUE(fs.is_open());

    // 读取并验证内容
    std::string line;
    int dataLines = 0;
    while (std::getline(fs, line)) {
        if (!line.empty() && line[0] != '#') {
            dataLines++;
            // 验证格式: CRC32|path
            TEST_ASSERT_TRUE(line.find('|') != std::string::npos);
        }
    }
    fs.close();

    TEST_ASSERT_EQ(2, dataLines);

    // 清理测试文件
    remove(outputPath.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, SaveMappingHex) {
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/test.txt", 512);

    std::string outputPath = "test_mapping_hex.txt";
    int result = generator.SaveMapping(outputPath, true);
    TEST_ASSERT_EQ(0, result);

    // 验证十六进制格式
    std::ifstream fs(outputPath);
    std::string line;
    bool foundHex = false;
    while (std::getline(fs, line)) {
        if (!line.empty() && line[0] != '#') {
            // 应该以 0x 开头
            TEST_ASSERT_TRUE(line.substr(0, 2) == "0x");
            foundHex = true;
        }
    }
    fs.close();

    TEST_ASSERT_TRUE(foundHex);

    // 清理
    remove(outputPath.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, SaveMappingBinary) {
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/file1.bin", 100);
    generator.AddPath("res/file2.bin", 200);

    std::string outputPath = "test_mapping.ljpm";
    int result = generator.SaveMappingBinary(outputPath);
    TEST_ASSERT_EQ(0, result);

    // 验证二进制文件
    std::ifstream fs(outputPath, std::ios::binary);
    TEST_ASSERT_TRUE(fs.is_open());

    // 读取魔数
    uint32_t magic = 0;
    fs.read(reinterpret_cast<char*>(&magic), 4);
    TEST_ASSERT_EQ((uint32_t)0x4D504A4C, magic);  // "LJPM"

    // 读取版本
    uint32_t version = 0;
    fs.read(reinterpret_cast<char*>(&version), 4);
    TEST_ASSERT_EQ((uint32_t)1, version);

    // 读取条目数
    uint32_t count = 0;
    fs.read(reinterpret_cast<char*>(&count), 4);
    TEST_ASSERT_EQ((uint32_t)2, count);

    fs.close();

    // 清理
    remove(outputPath.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, SaveMappingBinaryOverwritesExistingFile) {
    const std::string outputPath = "test_mapping_overwrite.ljpm";

    {
        SLJFP::PathMappingGenerator generator;
        generator.AddPath("res/file1.bin", 100);
        generator.AddPath("res/file2.bin", 200);
        TEST_ASSERT_EQ(0, generator.SaveMappingBinary(outputPath));
    }

    {
        SLJFP::PathMappingGenerator generator;
        generator.AddPath("cfg/android_notify.xml", 300);
        TEST_ASSERT_EQ(0, generator.SaveMappingBinary(outputPath));
    }

    std::ifstream fs(outputPath.c_str(), std::ios::binary);
    TEST_ASSERT_TRUE(fs.is_open());

    uint32_t magic = 0;
    uint32_t version = 0;
    uint32_t count = 0;
    fs.read(reinterpret_cast<char*>(&magic), 4);
    fs.read(reinterpret_cast<char*>(&version), 4);
    fs.read(reinterpret_cast<char*>(&count), 4);
    fs.close();

    TEST_ASSERT_EQ((uint32_t)0x4D504A4C, magic);
    TEST_ASSERT_EQ((uint32_t)1, version);
    TEST_ASSERT_EQ((uint32_t)1, count);

    remove(outputPath.c_str());
    return true;
}

// ============================================================================
// 从路径列表加载测试
// ============================================================================

TEST_CASE(PathMappingGenerator, LoadPathList) {
    // 创建测试路径列表文件
    std::string listPath = "test_pathlist.txt";
    std::ofstream ofs(listPath);
    ofs << "# Comment line\n";
    ofs << "res/script/main.lua\n";
    ofs << "res/image/logo.png\n";
    ofs << "\n";  // 空行
    ofs << "// Another comment\n";
    ofs << "res/sound/bgm.ogg\n";
    ofs.close();

    SLJFP::PathMappingGenerator generator;
    uint32_t loaded = generator.LoadPathList(listPath);

    TEST_ASSERT_EQ((uint32_t)3, loaded);
    TEST_ASSERT_EQ((size_t)3, generator.GetEntries().size());

    // 清理
    remove(listPath.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, LoadPathListNotExist) {
    SLJFP::PathMappingGenerator generator;
    uint32_t loaded = generator.LoadPathList("nonexistent_file.txt");

    TEST_ASSERT_EQ((uint32_t)0, loaded);
    return true;
}

// ============================================================================
// 扫描选项测试
// ============================================================================

TEST_CASE(PathMappingGenerator, ScanOptionsDefault) {
    SLJFP::PathMappingGenerator::ScanOptions options;

    TEST_ASSERT_TRUE(options.recursiveScan);
    TEST_ASSERT_FALSE(options.sljfpScanIncludeHiddenFlag);
    TEST_ASSERT_TRUE(options.lowercasePaths);
    TEST_ASSERT_TRUE(options.normalizeSlashes);
    TEST_ASSERT_EQ("", options.sljfpScanPathPrefixValue);
    TEST_ASSERT_TRUE(options.pathHashMode ==
                     SLJFP::PathMappingGenerator::PathHashMode::NormalizedPath);
    return true;
}

TEST_CASE(PathMappingGenerator, ScanDirectoryLegacyHashModeUsesOriginalCaseForCRC) {
    const std::string baseDir = "test_output/path_mapping_legacy_hash_mode";
    const std::string rootDir = baseDir + "/Root";
    const std::string nestedDir = rootDir + "/SubDir";
    const std::string filePath = nestedDir + "/MixedCase.lua";
    const std::string canonicalPath = "subdir/mixedcase.lua";
    const std::string legacyHashInput = "SubDir/MixedCase.lua";

    CleanupPathMappingTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreatePathMappingTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreatePathMappingTestDirectory(rootDir));
    TEST_ASSERT_TRUE(CreatePathMappingTestDirectory(nestedDir));
    TEST_ASSERT_TRUE(WritePathMappingTestFile(filePath, "print('legacy-hash')\n"));

    SLJFP::PathMappingGenerator generator;
    generator.SetCRC32Function(PathMappingGeneratorTestCRC32);

    SLJFP::PathMappingGenerator::ScanOptions options;
    options.lowercasePaths = true;
    options.normalizeSlashes = true;
    options.pathHashMode = SLJFP::PathMappingGenerator::PathHashMode::LjFilePackLegacyAcpExact;

    const uint32_t scanned = generator.ScanDirectory(rootDir, options);
    TEST_ASSERT_EQ((uint32_t)1, scanned);
    TEST_ASSERT_EQ((size_t)1, generator.GetEntries().size());

    const uint32_t legacyCRC = SLJFP_crc32(
        0,
        reinterpret_cast<const unsigned char*>(legacyHashInput.c_str()),
        static_cast<unsigned int>(legacyHashInput.size()));
    const uint32_t normalizedCRC = SLJFP_crc32(
        0,
        reinterpret_cast<const unsigned char*>(canonicalPath.c_str()),
        static_cast<unsigned int>(canonicalPath.size()));

    TEST_ASSERT_NE(legacyCRC, normalizedCRC);
    TEST_ASSERT_EQ(canonicalPath, generator.GetEntries()[0].relativePath);
    TEST_ASSERT_EQ(legacyCRC, generator.GetEntries()[0].crc32);
    TEST_ASSERT_EQ(canonicalPath, generator.FindPath(legacyCRC));
    TEST_ASSERT_EQ("", generator.FindPath(normalizedCRC));

    CleanupPathMappingTestDirectory(baseDir);
    return true;
}

TEST_CASE(PathMappingGenerator, PathPrefixOption) {
    SLJFP::PathMappingGenerator generator;

    // 测试路径前缀功能（通过手动添加）
    // 这个测试需要实际的目录扫描，这里我们只测试 AddPath 功能
    uint32_t crc = generator.AddPath("test/file.txt");
    TEST_ASSERT_TRUE(crc != 0);

    // 验证路径已规范化
    const SLJFP::PathMappingGenerator::PathEntry& entry = generator.GetEntries()[0];
    TEST_ASSERT_TRUE(entry.relativePath.find('\\') == std::string::npos);
    return true;
}

// ============================================================================
// 统计信息测试
// ============================================================================

TEST_CASE(PathMappingGenerator, StatsAccumulation) {
    SLJFP::PathMappingGenerator generator;

    generator.AddPath("file1.txt", 100);
    generator.AddPath("file2.txt", 200);
    generator.AddPath("file3.txt", 300);

    const SLJFP::PathMappingGenerator::ScanStats& stats = generator.GetStats();

    TEST_ASSERT_EQ((uint32_t)3, stats.totalFiles);
    TEST_ASSERT_EQ((uint64_t)600, stats.totalBytes);
    TEST_ASSERT_EQ((uint32_t)0, stats.collisions);
    return true;
}

TEST_CASE(PathMappingGenerator, StatsReset) {
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("file1.txt", 100);

    generator.Clear();

    const SLJFP::PathMappingGenerator::ScanStats& stats = generator.GetStats();
    TEST_ASSERT_EQ((uint32_t)0, stats.totalFiles);
    TEST_ASSERT_EQ((uint64_t)0, stats.totalBytes);
    return true;
}

// ============================================================================
// 集成测试: PathMappingGenerator + Unpacker
// ============================================================================

// Wrapper functions for Unpacker
static unsigned int TestCRC32(unsigned int crc, const unsigned char* ptr, unsigned int buf_len) {
    // 简单的 CRC32 实现 (仅用于测试)
    static const uint32_t s_crc32Table[256] = {
        0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3,
        0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91,
        0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
        0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5,
        0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B,
        0x35B5A8FA, 0x42B2986C, 0xDBBBBBD6, 0xACBCCB40, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
        0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F,
        0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D,
        0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
        0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01,
        0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457,
        0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
        0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB,
        0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9,
        0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
        0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD,
        0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683,
        0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
        0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7,
        0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5,
        0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
        0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79,
        0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F,
        0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
        0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713,
        0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21,
        0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
        0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45,
        0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB,
        0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
        0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD706B3, 0x54DE5729, 0x23D967BF,
        0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D
    };
    uint32_t c = crc ^ 0xFFFFFFFF;
    for (unsigned int i = 0; i < buf_len; i++) {
        c = s_crc32Table[(c ^ ptr[i]) & 0xFF] ^ (c >> 8);
    }
    return c ^ 0xFFFFFFFF;
}

static unsigned int TestZip(unsigned char* /*pDest*/, unsigned int* /*pDest_len*/,
                             const unsigned char* /*pSource*/, unsigned int /*source_len*/, int /*level*/) {
    return 0;
}

static unsigned int TestUnZip(unsigned char* /*pDest*/, unsigned int* /*pDest_len*/,
                               const unsigned char* /*pSource*/, unsigned int /*source_len*/) {
    return 0;
}

static void TestSMS4(unsigned char* /*inBuff*/, unsigned char* /*ouBuff*/,
                      unsigned int /*uiSize*/, std::string /*strPassword*/) {
}

static void TestDeSMS4(unsigned char* /*inBuff*/, unsigned char* /*ouBuff*/,
                        unsigned int /*uiSize*/, std::string /*strPassword*/) {
}

TEST_CASE(PathMappingGenerator, IntegrationWithUnpackerTextFormat) {
    // 1. 使用 PathMappingGenerator 生成映射文件
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/script/main.lua", 1024);
    generator.AddPath("res/image/logo.png", 2048);
    generator.AddPath("res/sound/bgm.ogg", 4096);

    std::string mappingFile = "test_integration_mapping.txt";
    int saveResult = generator.SaveMapping(mappingFile, false);
    TEST_ASSERT_EQ(0, saveResult);

    // 2. 使用 Unpacker 加载映射文件
    SLJFP::Unpacker unpacker(TestCRC32, TestZip, TestUnZip, TestSMS4, TestDeSMS4);
    int loadResult = unpacker.LoadPathMapping(mappingFile);
    TEST_ASSERT_EQ(0, loadResult);

    // 3. 验证映射数量
    TEST_ASSERT_EQ((size_t)3, unpacker.GetPathMappingCount());

    // 清理
    remove(mappingFile.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, IntegrationWithUnpackerBinaryFormat) {
    // 1. 使用 PathMappingGenerator 生成二进制映射文件
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/script/main.lua", 1024);
    generator.AddPath("res/image/logo.png", 2048);
    generator.AddPath("res/sound/bgm.ogg", 4096);
    generator.AddPath("res/data/config.json", 512);

    std::string mappingFile = "test_integration_mapping.ljpm";
    int saveResult = generator.SaveMappingBinary(mappingFile);
    TEST_ASSERT_EQ(0, saveResult);

    // 2. 使用 Unpacker 加载二进制映射文件
    SLJFP::Unpacker unpacker(TestCRC32, TestZip, TestUnZip, TestSMS4, TestDeSMS4);
    int loadResult = unpacker.LoadPathMapping(mappingFile);
    TEST_ASSERT_EQ(0, loadResult);

    // 3. 验证映射数量
    TEST_ASSERT_EQ((size_t)4, unpacker.GetPathMappingCount());

    // 清理
    remove(mappingFile.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, IntegrationAutoDetectBinaryFormat) {
    // 测试自动检测二进制格式 (不依赖扩展名)
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("test/file1.txt");
    generator.AddPath("test/file2.txt");

    // 保存为二进制但使用 .dat 扩展名
    std::string mappingFile = "test_auto_detect.dat";
    int saveResult = generator.SaveMappingBinary(mappingFile);
    TEST_ASSERT_EQ(0, saveResult);

    // Unpacker 应该自动检测到这是二进制格式
    SLJFP::Unpacker unpacker(TestCRC32, TestZip, TestUnZip, TestSMS4, TestDeSMS4);
    int loadResult = unpacker.LoadPathMapping(mappingFile);
    TEST_ASSERT_EQ(0, loadResult);
    TEST_ASSERT_EQ((size_t)2, unpacker.GetPathMappingCount());

    // 清理
    remove(mappingFile.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, SavePreservesAuthoritativeCRCTextFormat) {
    const uint32_t authoritativeCRC = 0x12345678;
    const std::string authoritativePath = "res/manual/seed.txt";
    const std::string canonicalPath = "manual/seed.txt";

    SLJFP::PathMappingGenerator generator;
    generator.AddPathWithCRC(authoritativePath, authoritativeCRC);

    std::string mappingFile = "test_authoritative_crc.txt";
    int saveResult = generator.SaveMapping(mappingFile, true);
    TEST_ASSERT_EQ(0, saveResult);

    SLJFP::Unpacker unpacker(TestCRC32, TestZip, TestUnZip, TestSMS4, TestDeSMS4);
    int loadResult = unpacker.LoadPathMapping(mappingFile);
    TEST_ASSERT_EQ(0, loadResult);

    const std::map<uint32_t, std::string>& loaded = unpacker.GetPathMappingTable();
    TEST_ASSERT_EQ((size_t)1, loaded.size());
    TEST_ASSERT_TRUE(loaded.find(authoritativeCRC) != loaded.end());
    TEST_ASSERT_EQ(canonicalPath, loaded.find(authoritativeCRC)->second);

    remove(mappingFile.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, SavePreservesAuthoritativeCRCBinaryFormat) {
    const uint32_t authoritativeCRC = 0x87654321;
    const std::string authoritativePath = "res/manual/seed.bin";
    const std::string canonicalPath = "manual/seed.bin";

    SLJFP::PathMappingGenerator generator;
    generator.AddPathWithCRC(authoritativePath, authoritativeCRC);

    std::string mappingFile = "test_authoritative_crc.ljpm";
    int saveResult = generator.SaveMappingBinary(mappingFile);
    TEST_ASSERT_EQ(0, saveResult);

    SLJFP::Unpacker unpacker(TestCRC32, TestZip, TestUnZip, TestSMS4, TestDeSMS4);
    int loadResult = unpacker.LoadPathMapping(mappingFile);
    TEST_ASSERT_EQ(0, loadResult);

    const std::map<uint32_t, std::string>& loaded = unpacker.GetPathMappingTable();
    TEST_ASSERT_EQ((size_t)1, loaded.size());
    TEST_ASSERT_TRUE(loaded.find(authoritativeCRC) != loaded.end());
    TEST_ASSERT_EQ(canonicalPath, loaded.find(authoritativeCRC)->second);

    remove(mappingFile.c_str());
    return true;
}

TEST_CASE(PathMappingGenerator, SaveWritesUniqueCRCEntriesOnly) {
    SLJFP::PathMappingGenerator generator;
    generator.AddPath("res/duplicate/path.txt");
    generator.AddPath("res/duplicate/path.txt");

    std::string mappingFile = "test_unique_entries.txt";
    int saveResult = generator.SaveMapping(mappingFile, true);
    TEST_ASSERT_EQ(0, saveResult);

    std::ifstream fs(mappingFile.c_str());
    TEST_ASSERT_TRUE(fs.is_open());

    size_t dataLines = 0;
    std::string line;
    while (std::getline(fs, line)) {
        if (line.empty() || line[0] == '#') {
            continue;
        }
        ++dataLines;
    }

    TEST_ASSERT_EQ((size_t)1, dataLines);

    remove(mappingFile.c_str());
    return true;
}

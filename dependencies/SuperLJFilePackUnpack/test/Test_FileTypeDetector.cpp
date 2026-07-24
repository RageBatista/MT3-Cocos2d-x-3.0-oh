/**
 * @file Test_FileTypeDetector.cpp
 * @brief FileTypeDetector 单元测试
 * @version 1.0
 * @date 2025-01-04
 */

#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_FileTypeDetector.h"
#include <cstring>
#include <vector>

// ============================================================================
// 图像格式测试
// ============================================================================

TEST_CASE(FileTypeDetector, DetectPNG) {
    uint8_t pngData[] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(pngData, sizeof(pngData));
    TEST_ASSERT_EQ(".png", ext);

    std::string desc = SLJFP::FileTypeDetector::DetectDescription(pngData, sizeof(pngData));
    TEST_ASSERT_EQ("PNG Image", desc);
    return true;
}

TEST_CASE(FileTypeDetector, DetectJPEG) {
    uint8_t jpgData[] = {0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(jpgData, sizeof(jpgData));
    TEST_ASSERT_EQ(".jpg", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectGIF87a) {
    uint8_t gifData[] = {0x47, 0x49, 0x46, 0x38, 0x37, 0x61, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(gifData, sizeof(gifData));
    TEST_ASSERT_EQ(".gif", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectGIF89a) {
    uint8_t gifData[] = {0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(gifData, sizeof(gifData));
    TEST_ASSERT_EQ(".gif", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectBMP) {
    uint8_t bmpData[] = {0x42, 0x4D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(bmpData, sizeof(bmpData));
    TEST_ASSERT_EQ(".bmp", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectICO) {
    uint8_t icoData[] = {0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x10, 0x10};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(icoData, sizeof(icoData));
    TEST_ASSERT_EQ(".ico", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectDDS) {
    uint8_t ddsData[] = {0x44, 0x44, 0x53, 0x20, 0x7C, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(ddsData, sizeof(ddsData));
    TEST_ASSERT_EQ(".dds", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectTTF) {
    uint8_t ttfData[] = {
        0x00, 0x01, 0x00, 0x00,
        0x00, 0x0E, 0x00, 0x30,
        0x63, 0x6D, 0x61, 0x70
    };
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(ttfData, sizeof(ttfData));
    TEST_ASSERT_EQ(".ttf", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectOTF) {
    uint8_t otfData[] = {
        0x4F, 0x54, 0x54, 0x4F,
        0x00, 0x09, 0x00, 0x80,
        0x43, 0x46, 0x46, 0x20
    };
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(otfData, sizeof(otfData));
    TEST_ASSERT_EQ(".otf", ext);
    return true;
}

// ============================================================================
// 音频格式测试
// ============================================================================

TEST_CASE(FileTypeDetector, DetectOGG) {
    uint8_t oggData[] = {0x4F, 0x67, 0x67, 0x53, 0x00, 0x02, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(oggData, sizeof(oggData));
    TEST_ASSERT_EQ(".ogg", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMP3_ID3) {
    uint8_t mp3Data[] = {0x49, 0x44, 0x33, 0x04, 0x00, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(mp3Data, sizeof(mp3Data));
    TEST_ASSERT_EQ(".mp3", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMP3_FrameSync) {
    uint8_t mp3Data[] = {0xFF, 0xFB, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(mp3Data, sizeof(mp3Data));
    TEST_ASSERT_EQ(".mp3", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectWAV) {
    uint8_t wavData[] = {0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00,
                         0x57, 0x41, 0x56, 0x45, 0x66, 0x6D, 0x74, 0x20};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(wavData, sizeof(wavData));
    TEST_ASSERT_EQ(".wav", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectWebP) {
    uint8_t webpData[] = {0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00,
                          0x57, 0x45, 0x42, 0x50, 0x56, 0x50, 0x38, 0x4C};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(webpData, sizeof(webpData));
    TEST_ASSERT_EQ(".webp", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectFLAC) {
    uint8_t flacData[] = {0x66, 0x4C, 0x61, 0x43, 0x00, 0x00, 0x00, 0x22};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(flacData, sizeof(flacData));
    TEST_ASSERT_EQ(".flac", ext);
    return true;
}

// ============================================================================
// 脚本格式测试 (MT3 核心)
// ============================================================================

TEST_CASE(FileTypeDetector, DetectLua51Bytecode) {
    uint8_t luaData[] = {0x1B, 0x4C, 0x75, 0x61, 0x51, 0x00, 0x01, 0x04};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(luaData, sizeof(luaData));
    TEST_ASSERT_EQ(".luac", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLua52Bytecode) {
    uint8_t luaData[] = {0x1B, 0x4C, 0x75, 0x61, 0x52, 0x00, 0x01, 0x04};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(luaData, sizeof(luaData));
    TEST_ASSERT_EQ(".luac", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLuaJITBytecode) {
    uint8_t luaData[] = {0x1B, 0x4C, 0x4A, 0x01, 0x00, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(luaData, sizeof(luaData));
    TEST_ASSERT_EQ(".luajit", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLuaSourceComment) {
    const char* luaSrc = "-- This is a Lua script\nlocal x = 1";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)luaSrc, strlen(luaSrc));
    TEST_ASSERT_EQ(".lua", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLuaSourceLocal) {
    const char* luaSrc = "local function hello()\n    print('Hello')\nend";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)luaSrc, strlen(luaSrc));
    TEST_ASSERT_EQ(".lua", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLuaSourceRequire) {
    const char* luaSrc = "\n\nrequire \"utils.binutil\"\n\nCJingMaiZhanShiTable = {}\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)luaSrc, strlen(luaSrc));
    TEST_ASSERT_EQ(".lua", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectSpineAtlas) {
    const char* atlasData =
        "\nspine_createrole_nvde.png\n"
        "size: 1024,512\n"
        "format: RGBA8888\n"
        "filter: Linear,Linear\n"
        "repeat: none\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)atlasData, strlen(atlasData));
    TEST_ASSERT_EQ(".atlas", ext);
    return true;
}

// ============================================================================
// 压缩格式测试
// ============================================================================

TEST_CASE(FileTypeDetector, DetectZIP) {
    uint8_t zipData[] = {0x50, 0x4B, 0x03, 0x04, 0x14, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(zipData, sizeof(zipData));
    TEST_ASSERT_EQ(".zip", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectGZIP) {
    uint8_t gzData[] = {0x1F, 0x8B, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(gzData, sizeof(gzData));
    TEST_ASSERT_EQ(".gz", ext);
    return true;
}

TEST_CASE(FileTypeDetector, Detect7Z) {
    uint8_t sz7Data[] = {0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(sz7Data, sizeof(sz7Data));
    TEST_ASSERT_EQ(".7z", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectRAR) {
    uint8_t rarData[] = {0x52, 0x61, 0x72, 0x21, 0x1A, 0x07, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(rarData, sizeof(rarData));
    TEST_ASSERT_EQ(".rar", ext);
    return true;
}

// ============================================================================
// 文档格式测试
// ============================================================================

TEST_CASE(FileTypeDetector, DetectPDF) {
    const char* pdfData = "%PDF-1.4\n%\xE2\xE3\xCF\xD3";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)pdfData, strlen(pdfData));
    TEST_ASSERT_EQ(".pdf", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectCompoundFileBinary) {
    uint8_t cfbData[] = {
        0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1,
        0x00, 0x00, 0x00, 0x00
    };
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(cfbData, sizeof(cfbData));
    TEST_ASSERT_EQ(".cfb", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMiniDump) {
    uint8_t mdmpData[] = {
        0x4D, 0x44, 0x4D, 0x50,
        0x93, 0xA7, 0x00, 0x00,
        0x04, 0x00, 0x00, 0x00
    };
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(mdmpData, sizeof(mdmpData));
    TEST_ASSERT_EQ(".dmp", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectNuclearImg) {
    uint8_t imgData[] = {
        0x06, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x40, 0x00, 0x00, 0x00,
        0x40, 0x00, 0x00, 0x00,
        0x00, 0x10, 0x00, 0x00,
        0x40, 0x00, 0x00, 0x00,
        0x40, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x04, 0x00, 0x00, 0x00,
        0x44, 0x58, 0x54, 0x35
    };
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(imgData, sizeof(imgData));
    TEST_ASSERT_EQ(".img", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectTGA) {
    std::vector<uint8_t> tgaData(44, 0);
    tgaData[2] = 0x0A;   // RLE true-color
    tgaData[12] = 0x04;  // width = 4
    tgaData[14] = 0x03;  // height = 3
    tgaData[16] = 0x20;  // 32 bpp

    const char* footer = "TRUEVISION-XFILE.";
    std::memcpy(&tgaData[tgaData.size() - 18], footer, 17);
    tgaData[tgaData.size() - 1] = 0x00;

    std::string ext = SLJFP::FileTypeDetector::DetectExtension(&tgaData[0], tgaData.size());
    TEST_ASSERT_EQ(".tga", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMazeDat) {
    std::vector<uint8_t> mazeData(12 + 6, 0);
    mazeData[0] = 0x0C;
    mazeData[4] = 0x02;
    mazeData[8] = 0x03;
    mazeData[12] = 0x00;
    mazeData[13] = 0x03;
    mazeData[14] = 0x08;
    mazeData[15] = 0x0B;
    mazeData[16] = 0x03;
    mazeData[17] = 0x00;

    std::string ext = SLJFP::FileTypeDetector::DetectExtension(&mazeData[0], mazeData.size());
    TEST_ASSERT_EQ(".dat", ext);

    std::string mime = SLJFP::FileTypeDetector::DetectMimeType(&mazeData[0], mazeData.size());
    TEST_ASSERT_EQ("application/x-mt3-maze-data", mime);

    std::string desc = SLJFP::FileTypeDetector::DetectDescription(&mazeData[0], mazeData.size());
    TEST_ASSERT_EQ("MT3 Maze Data", desc);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMonsterDat) {
    std::vector<uint8_t> monsterData(16 + 2 * 8, 0);
    monsterData[0] = 0x10;
    monsterData[4] = 0x02;
    monsterData[8] = 0x03;
    monsterData[12] = 0x02;

    // key = (0 << 16) | 1, val = 1001
    monsterData[16] = 0x01;
    monsterData[20] = 0xE9;
    monsterData[21] = 0x03;

    // key = (1 << 16) | 2, val = 1002
    monsterData[24] = 0x02;
    monsterData[26] = 0x01;
    monsterData[27] = 0x00;
    monsterData[28] = 0xEA;
    monsterData[29] = 0x03;

    std::string ext = SLJFP::FileTypeDetector::DetectExtension(&monsterData[0], monsterData.size());
    TEST_ASSERT_EQ(".dat", ext);

    std::string mime = SLJFP::FileTypeDetector::DetectMimeType(&monsterData[0], monsterData.size());
    TEST_ASSERT_EQ("application/x-mt3-monster-data", mime);

    std::string desc = SLJFP::FileTypeDetector::DetectDescription(&monsterData[0], monsterData.size());
    TEST_ASSERT_EQ("MT3 Monster Data", desc);
    return true;
}

TEST_CASE(FileTypeDetector, DetectXMLDeclaration) {
    const char* xmlData = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root></root>";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)xmlData, strlen(xmlData));
    TEST_ASSERT_EQ(".xml", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectXMLTag) {
    const char* xmlData = "<configuration>\n  <setting name=\"test\"/>\n</configuration>";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)xmlData, strlen(xmlData));
    TEST_ASSERT_EQ(".xml", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectJSONObject) {
    const char* jsonData = "{\"name\": \"test\", \"value\": 123}";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)jsonData, strlen(jsonData));
    TEST_ASSERT_EQ(".json", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectJSONArray) {
    const char* jsonData = "[1, 2, 3, \"test\"]";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)jsonData, strlen(jsonData));
    TEST_ASSERT_EQ(".json", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectIniClientSetting) {
    const char* iniData =
        "[ClientSetting]\n"
        "bLoadFromPak=1\n"
        "bLuaPrint=0\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)iniData, strlen(iniData));
    TEST_ASSERT_EQ(".ini", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectIniLocalizedFileNames) {
    const char* iniData =
        "[LocalizedFileNames]\n"
        "fenxiang.imageset=@fenxiang.imageset,0\n"
        "fenxiang.png=@fenxiang.png,0\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)iniData, strlen(iniData));
    TEST_ASSERT_EQ(".ini", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectHTML) {
    const char* htmlData = "<html>\n<head><title>Test</title></head>\n<body></body>\n</html>";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)htmlData, strlen(htmlData));
    TEST_ASSERT_EQ(".html", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLuaTopLevelAssignment) {
    const char* luaData = "Openui = { }\nOpenui.eUIId =\n{\n    shanghui_01 = 1,\n}\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)luaData, strlen(luaData));
    TEST_ASSERT_EQ(".lua", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectPatchText) {
    const char* patchData =
        "Index: zhandouanniu.lua\r\n"
        "===================================================================\r\n"
        "--- zhandouanniu.lua\t(revision 50091)\r\n"
        "+++ zhandouanniu.lua\t(working copy)\r\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)patchData, strlen(patchData));
    TEST_ASSERT_EQ(".patch", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLuaProjectSolution) {
    const char* luaprojData =
        "Microsoft Visual Studio Solution File, Format Version 12.00\r\n"
        "# Visual Studio 2013\r\n"
        "Project(\"{5697748A-77EF-44CA-8824-4F5637E5945B}\") = "
        "\"logic\", \"logic.luaproj\", \"{E439935D-B2A2-46AE-856D-2AA408428F33}\"\r\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)luaprojData, strlen(luaprojData));
    TEST_ASSERT_EQ(".luaproj", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectPythonScript) {
    const char* pyData =
        "import os\r\n"
        "rootdir = os.getcwd()\r\n"
        "projpath = os.path.join(rootdir, 'mt3.luaproj')\r\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)pyData, strlen(pyData));
    TEST_ASSERT_EQ(".py", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMovieScriptText) {
    const char* movieData =
        "Setmap id=1662 pos=26,66\r\n"
        "MoveCam pos=26,66\r\n"
        "CreateNpc id=2 varname=XXJ pos=25,60 model=1020122\r\n"
        "Wait time=500\r\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)movieData, strlen(movieData));
    TEST_ASSERT_EQ(".txt", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectPlainTextMultiline) {
    const char* textData =
        "emulator:\r\n"
        "hlteuc\r\n"
        "android_x86\r\n"
        "GT-P5210\r\n";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)textData, strlen(textData));
    TEST_ASSERT_EQ(".txt", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectPlainTextWindowsPath) {
    const char* pathData = "E:\\mt3\\client\\resource\\res\\script";
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(
        (const uint8_t*)pathData, strlen(pathData));
    TEST_ASSERT_EQ(".txt", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMt3ParticlePtc) {
    const unsigned char ptcData[] = {
        0x04, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x44, 0x33, 0x44, 0x54, 0x4F, 0x50, 0x5F, 0x41,
        0x44, 0x44, 0x53, 0x49, 0x47, 0x4E, 0x45, 0x44,
        0x00, 0x00, 0x00, 0x00,
        0x63, 0x63, 0x5F, 0x6C, 0x69, 0x7A, 0x69, 0x74,
        0x78, 0x32, 0x2E, 0x70, 0x6E, 0x67, 0x00, 0x00,
        0x6C, 0x69, 0x6E, 0x65, 0x30, 0x34, 0x2E, 0x70,
        0x61, 0x74, 0x68, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x80, 0x3E,
        0x66, 0x66, 0xE6, 0x3E,
        0xCD, 0xCC, 0xCC, 0x3D,
        0xCD, 0xCC, 0xCC, 0x3D,
        0x00, 0x00, 0x40, 0x3F,
        0x00, 0x00, 0x85, 0x42,
        0x00, 0x00, 0x85, 0x42,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x02, 0x00, 0x00, 0x00,
        0x03, 0x00, 0x00, 0x00,
        0x04, 0x00, 0x00, 0x00,
        0x05, 0x00, 0x00, 0x00,
        0x06, 0x00, 0x00, 0x00,
        0x07, 0x00, 0x00, 0x00,
        0x08, 0x00, 0x00, 0x00
    };
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(ptcData, sizeof(ptcData));
    TEST_ASSERT_EQ(".ptc", ext);
    return true;
}

// ============================================================================
// MT3 自定义格式测试
// ============================================================================

TEST_CASE(FileTypeDetector, DetectACT) {
    uint8_t actData[] = {0x41, 0x43, 0x54, 0x00, 0x01, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(actData, sizeof(actData));
    TEST_ASSERT_EQ(".act", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectANI) {
    uint8_t aniData[] = {0x41, 0x4E, 0x49, 0x00, 0x01, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(aniData, sizeof(aniData));
    TEST_ASSERT_EQ(".ani", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLMX) {
    uint8_t lmxData[] = {0x4C, 0x4D, 0x58, 0x00, 0x01, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(lmxData, sizeof(lmxData));
    TEST_ASSERT_EQ(".lmx", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectSPR) {
    uint8_t sprData[] = {0x53, 0x50, 0x52, 0x00, 0x01, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(sprData, sizeof(sprData));
    TEST_ASSERT_EQ(".spr", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMRMP) {
    uint8_t mrmpData[] = {
        0x4D, 0x52, 0x4D, 0x50, 0x01, 0x00, 0x00, 0x00,
        0x52, 0x4D, 0x41, 0x50, 0x2D, 0x00, 0x00, 0x00
    };
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(mrmpData, sizeof(mrmpData));
    TEST_ASSERT_EQ(".mrmp", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectRMAP) {
    uint8_t rmapData[] = {0x52, 0x4D, 0x41, 0x50, 0x2D, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(rmapData, sizeof(rmapData));
    TEST_ASSERT_EQ(".rmp", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectQUYU) {
    uint8_t quyuData[] = {0x51, 0x55, 0x59, 0x55, 0x56, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(quyuData, sizeof(quyuData));
    TEST_ASSERT_EQ(".dat", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectLDZY) {
    uint8_t ldzyData[] = {0x4C, 0x44, 0x5A, 0x59, 0x2A, 0x01, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(ldzyData, sizeof(ldzyData));
    TEST_ASSERT_EQ(".bin", ext);
    return true;
}

// ============================================================================
// 边界条件测试
// ============================================================================

TEST_CASE(FileTypeDetector, DetectEmpty) {
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(nullptr, 0);
    TEST_ASSERT_EQ("", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectTooShort) {
    uint8_t shortData[] = {0x89};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(shortData, 1);
    TEST_ASSERT_EQ("", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectUnknown) {
    uint8_t unknownData[] = {0xDE, 0xAD, 0xBE, 0xEF, 0x00, 0x00, 0x00, 0x00};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(unknownData, sizeof(unknownData));
    TEST_ASSERT_EQ("", ext);
    return true;
}

TEST_CASE(FileTypeDetector, DetectBOMJSON) {
    uint8_t bomJson[] = {0xEF, 0xBB, 0xBF, '{', '"', 'a', '"', ':', '1', '}'};
    std::string ext = SLJFP::FileTypeDetector::DetectExtension(bomJson, sizeof(bomJson));
    TEST_ASSERT_EQ(".json", ext);
    return true;
}

// ============================================================================
// 辅助方法测试
// ============================================================================

TEST_CASE(FileTypeDetector, IsTextFileLua) {
    TEST_ASSERT_TRUE(SLJFP::FileTypeDetector::IsTextFile(".lua"));
    return true;
}

TEST_CASE(FileTypeDetector, IsTextFileXML) {
    TEST_ASSERT_TRUE(SLJFP::FileTypeDetector::IsTextFile(".xml"));
    return true;
}

TEST_CASE(FileTypeDetector, IsTextFileJSON) {
    TEST_ASSERT_TRUE(SLJFP::FileTypeDetector::IsTextFile(".json"));
    return true;
}

TEST_CASE(FileTypeDetector, IsTextFileAtlas) {
    TEST_ASSERT_TRUE(SLJFP::FileTypeDetector::IsTextFile(".atlas"));
    return true;
}

TEST_CASE(FileTypeDetector, IsTextFilePatch) {
    TEST_ASSERT_TRUE(SLJFP::FileTypeDetector::IsTextFile(".patch"));
    return true;
}

TEST_CASE(FileTypeDetector, IsTextFileLuaProject) {
    TEST_ASSERT_TRUE(SLJFP::FileTypeDetector::IsTextFile(".luaproj"));
    return true;
}

TEST_CASE(FileTypeDetector, IsNotTextFilePNG) {
    TEST_ASSERT_FALSE(SLJFP::FileTypeDetector::IsTextFile(".png"));
    return true;
}

TEST_CASE(FileTypeDetector, IsNotTextFileBin) {
    TEST_ASSERT_FALSE(SLJFP::FileTypeDetector::IsTextFile(".bin"));
    return true;
}

TEST_CASE(FileTypeDetector, GetSupportedTypeCount) {
    size_t count = SLJFP::FileTypeDetector::GetSupportedTypeCount();
    TEST_ASSERT_TRUE(count > 20);  // 应该支持至少 20 种格式
    return true;
}

TEST_CASE(FileTypeDetector, DetectMimeTypePNG) {
    uint8_t pngData[] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
    std::string mime = SLJFP::FileTypeDetector::DetectMimeType(pngData, sizeof(pngData));
    TEST_ASSERT_EQ("image/png", mime);
    return true;
}

TEST_CASE(FileTypeDetector, DetectMimeTypeUnknown) {
    uint8_t unknownData[] = {0xDE, 0xAD, 0xBE, 0xEF};
    std::string mime = SLJFP::FileTypeDetector::DetectMimeType(unknownData, sizeof(unknownData));
    TEST_ASSERT_EQ("application/octet-stream", mime);
    return true;
}

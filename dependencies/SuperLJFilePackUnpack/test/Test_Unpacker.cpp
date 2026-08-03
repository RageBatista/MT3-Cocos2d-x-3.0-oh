/**
 * @file Test_Unpacker.cpp
 * @brief Unpacker core logic unit tests
 * @version 1.0
 * @date 2025-01-03
 */

#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_Unpack.h"
#include "../include/SLJFP_PathMappingGenerator.h"
#include "../include/SLJFP_LibsWrapper.h"
#include "../include/SLJFP_ErrorCodes.h"
#include "../src/SLJFP_UnpackIndexIO.h"
#include "../src/SLJFP_UnpackSourceIO.h"
#include "../libs/ljfp/LJFP_SMS4.h"
#include <fstream>
#include <cstring>
#include <sstream>
#include <iomanip>
#include <vector>
#include <cstdio>

// ============================================================================
// Helper Functions
// ============================================================================

// Create test directory
static bool CreateTestDirectory(const std::string& path) {
#ifdef _WIN32
    std::string cmd = "if not exist \"" + path + "\" mkdir \"" + path + "\"";
    return system(cmd.c_str()) == 0;
#else
    std::string cmd = "mkdir -p \"" + path + "\"";
    return system(cmd.c_str()) == 0;
#endif
}

// Create test file
static bool CreateTestFile(const std::string& path, const unsigned char* data, size_t size) {
    std::ofstream file(path, std::ios::binary);
    if (!file) return false;
    file.write((const char*)data, size);
    return file.good();
}

// Read test file
static bool ReadTestFile(const std::string& path, std::vector<unsigned char>& data) {
    std::ifstream file(path, std::ios::binary | std::ios::ate);
    if (!file) return false;

    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);

    data.resize((size_t)size);
    return file.read((char*)data.data(), size).good();
}

// Cleanup test file
static void CleanupTestFile(const std::string& path) {
#ifdef _WIN32
    std::string cmd = "if exist \"" + path + "\" del /q \"" + path + "\"";
#else
    std::string cmd = "rm -f \"" + path + "\"";
#endif
    system(cmd.c_str());
}

static void CleanupTestDirectory(const std::string& path) {
#ifdef _WIN32
    std::string cmd = "if exist \"" + path + "\" rmdir /s /q \"" + path + "\"";
#else
    std::string cmd = "rm -rf \"" + path + "\"";
#endif
    system(cmd.c_str());
}

static void AppendUInt32Le(std::vector<unsigned char>& data, unsigned int value) {
    data.push_back((unsigned char)(value & 0xFF));
    data.push_back((unsigned char)((value >> 8) & 0xFF));
    data.push_back((unsigned char)((value >> 16) & 0xFF));
    data.push_back((unsigned char)((value >> 24) & 0xFF));
}

static void PatchUInt32Le(std::vector<unsigned char>& data, size_t offset, unsigned int value) {
    if (offset + 4 > data.size()) {
        return;
    }
    data[offset + 0] = (unsigned char)(value & 0xFF);
    data[offset + 1] = (unsigned char)((value >> 8) & 0xFF);
    data[offset + 2] = (unsigned char)((value >> 16) & 0xFF);
    data[offset + 3] = (unsigned char)((value >> 24) & 0xFF);
}

static void AppendUInt16Le(std::vector<unsigned char>& data, unsigned short value) {
    data.push_back((unsigned char)(value & 0xFF));
    data.push_back((unsigned char)((value >> 8) & 0xFF));
}

static void AppendInt32Le(std::vector<unsigned char>& data, int value) {
    AppendUInt32Le(data, (unsigned int)value);
}

static void AppendFloatLe(std::vector<unsigned char>& data, float value) {
    unsigned int raw = 0;
    std::memcpy(&raw, &value, sizeof(raw));
    AppendUInt32Le(data, raw);
}

static void AppendPointLe(std::vector<unsigned char>& data, int x, int y) {
    AppendInt32Le(data, x);
    AppendInt32Le(data, y);
}

static void AppendRectLe(std::vector<unsigned char>& data, int left, int top, int right, int bottom) {
    AppendInt32Le(data, left);
    AppendInt32Le(data, top);
    AppendInt32Le(data, right);
    AppendInt32Le(data, bottom);
}

static void AppendWideStringLe(std::vector<unsigned char>& data, const std::wstring& value) {
    AppendUInt32Le(data, (unsigned int)value.size());
    for (size_t i = 0; i < value.size(); ++i) {
        unsigned short ch = (unsigned short)value[i];
        data.push_back((unsigned char)(ch & 0xFF));
        data.push_back((unsigned char)((ch >> 8) & 0xFF));
    }
}

static std::vector<unsigned char> BuildMinimalModelAni(const std::wstring& relativeTextureName,
                                                       const std::wstring& prefix = L"") {
    std::vector<unsigned char> data;
    data.reserve(256);

    AppendInt32Le(data, 15);   // version
    AppendInt32Le(data, 3);    // file format
    AppendInt32Le(data, 21);   // texture format
    AppendInt32Le(data, 0);    // blend mode
    AppendInt32Le(data, 1000); // play time
    AppendInt32Le(data, 1);    // region count
    AppendInt32Le(data, 1);    // frame count
    AppendInt32Le(data, 1);    // dir mode (8USE1)
    AppendInt32Le(data, -1);   // color
    AppendInt32Le(data, 0);    // system level
    AppendInt32Le(data, 0);    // bind type

    AppendPointLe(data, 0, 0);   // base.left
    AppendPointLe(data, 10, 10); // base.right
    AppendPointLe(data, 0, 0);   // center
    AppendRectLe(data, 0, 0, 10, 10); // border

    AppendRectLe(data, 0, 0, 10, 10); // file offset rect
    AppendWideStringLe(data, relativeTextureName);
    AppendFloatLe(data, 0.0f);
    AppendFloatLe(data, 0.0f);
    AppendFloatLe(data, 1.0f);
    AppendFloatLe(data, 1.0f);
    AppendInt32Le(data, 0); // outline point count
    AppendWideStringLe(data, prefix); // prefix

    return data;
}

static std::vector<unsigned char> BuildTinyPng() {
    static const unsigned char kTinyPng[] = {
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
        0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
        0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99,
        0x3D, 0x1D, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
        0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    };
    return std::vector<unsigned char>(kTinyPng, kTinyPng + sizeof(kTinyPng));
}

static std::vector<unsigned char> BuildPngWithSize(uint32_t width, uint32_t height) {
    std::vector<unsigned char> data = BuildTinyPng();
    if (data.size() >= 24) {
        data[16] = (unsigned char)((width >> 24) & 0xFF);
        data[17] = (unsigned char)((width >> 16) & 0xFF);
        data[18] = (unsigned char)((width >> 8) & 0xFF);
        data[19] = (unsigned char)(width & 0xFF);
        data[20] = (unsigned char)((height >> 24) & 0xFF);
        data[21] = (unsigned char)((height >> 16) & 0xFF);
        data[22] = (unsigned char)((height >> 8) & 0xFF);
        data[23] = (unsigned char)(height & 0xFF);
    }
    return data;
}

static std::vector<unsigned char> BuildTinyDds() {
    std::vector<unsigned char> data(128, 0);
    data[0] = 'D';
    data[1] = 'D';
    data[2] = 'S';
    data[3] = ' ';
    data[4] = 124;  // DDSURFACEDESC2 size
    data[8] = 0x07; // minimal flags
    data[12] = 0x01; // height = 1
    data[16] = 0x01; // width = 1
    data[76] = 32;   // pixel format size
    data[80] = 0x04; // fourCC flag
    data[84] = 'D';
    data[85] = 'X';
    data[86] = 'T';
    data[87] = '5';
    data[108] = 0x08; // texture caps
    return data;
}

static std::vector<unsigned char> BuildUtf8Text(const std::string& text) {
    return std::vector<unsigned char>(text.begin(), text.end());
}

static std::vector<unsigned char> BuildPatternBlob(size_t size) {
    std::vector<unsigned char> data(size);
    uint32_t state = 0x13572468u;
    for (size_t i = 0; i < size; ++i) {
        state = state * 1664525u + 1013904223u;
        data[i] = static_cast<unsigned char>(((state >> 24) ^ (state >> 15) ^ i) & 0xFFu);
    }
    return data;
}

static std::vector<unsigned char> CompressBuffer(const std::vector<unsigned char>& input) {
    std::vector<unsigned char> compressed(input.size() * 2 + 64, 0);
    unsigned int compressedSize = static_cast<unsigned int>(compressed.size());
    if (input.empty()) {
        compressed.resize(0);
        return compressed;
    }

    const unsigned int result = SLJFP_mz_compress2(compressed.data(),
                                                   &compressedSize,
                                                   input.data(),
                                                   static_cast<unsigned int>(input.size()),
                                                   9);
    if (result != 0) {
        compressed.resize(0);
        return compressed;
    }

    compressed.resize(compressedSize);
    return compressed;
}

static std::vector<unsigned char> EncryptAllBlocksLegacy(const std::vector<unsigned char>& input,
                                                         const std::string& key) {
    std::vector<unsigned char> encrypted(input);
    const unsigned int alignedSize =
        static_cast<unsigned int>((input.size() / 16u) * 16u);
    if (alignedSize > 0) {
        SMS4Byte16Arr(const_cast<unsigned char*>(input.data()),
                      encrypted.data(),
                      static_cast<int>(alignedSize / 16u),
                      key);
    }
    return encrypted;
}

static std::vector<unsigned char> BuildBinaryAsciiTokenBlob(
    const std::vector<std::string>& tokens) {
    std::vector<unsigned char> data;
    for (size_t i = 0; i < tokens.size(); ++i) {
        data.insert(data.end(), tokens[i].begin(), tokens[i].end());
        data.push_back(0x00);
    }
    return data;
}

static std::vector<unsigned char> BuildUtf16LeText(const std::string& text) {
    std::vector<unsigned char> data;
    data.reserve(2 + text.size() * 2);
    data.push_back(0xFF);
    data.push_back(0xFE);
    for (size_t i = 0; i < text.size(); ++i) {
        data.push_back((unsigned char)text[i]);
        data.push_back(0x00);
    }
    return data;
}

static std::string BuildExpectedConflictPath(const std::string& logicalPath,
                                             unsigned int pathCrc32,
                                             unsigned int conflictIndex = 1) {
    const size_t slashPos = logicalPath.find_last_of("/\\");
    const std::string dirPath = (slashPos == std::string::npos)
        ? std::string()
        : logicalPath.substr(0, slashPos);
    const std::string fileName = (slashPos == std::string::npos)
        ? logicalPath
        : logicalPath.substr(slashPos + 1);
    const size_t dotPos = fileName.find_last_of('.');
    const std::string stem = (dotPos == std::string::npos)
        ? fileName
        : fileName.substr(0, dotPos);
    const std::string ext = (dotPos == std::string::npos)
        ? std::string()
        : fileName.substr(dotPos);

    std::ostringstream oss;
    oss << (stem.empty() ? "file" : stem)
        << ".conflict."
        << std::uppercase << std::hex << std::setw(8) << std::setfill('0')
        << pathCrc32
        << std::dec;
    if (conflictIndex > 1) {
        oss << "." << conflictIndex;
    }
    oss << ext;

    if (dirPath.empty()) {
        return oss.str();
    }
    return dirPath + "/" + oss.str();
}

static std::string ReadTestTextFileOrEmpty(const std::string& path) {
    std::vector<unsigned char> data;
    if (!ReadTestFile(path, data)) {
        return std::string();
    }
    return std::string(data.begin(), data.end());
}

static void AppendUtf8String(std::vector<unsigned char>& data, const std::string& value) {
    AppendUInt32Le(data, (unsigned int)value.size());
    data.insert(data.end(), value.begin(), value.end());
}

static std::vector<unsigned char> BuildEffectPathNoneDramaTableBinary(
    const std::vector<std::string>& paths) {
    std::vector<unsigned char> data;
    AppendUInt32Le(data, 1499087948u);  // 'LDZY'
    AppendUInt32Le(data, 0);            // patched later
    AppendUInt16Le(data, 101u);
    AppendUInt16Le(data, (unsigned short)paths.size());
    AppendUInt32Le(data, 131080u);

    for (size_t i = 0; i < paths.size(); ++i) {
        AppendUInt32Le(data, (unsigned int)(i + 1));
        AppendUtf8String(data, paths[i]);
    }

    PatchUInt32Le(data, 4, (unsigned int)data.size());
    return data;
}

static std::vector<unsigned char> BuildBattleStageInfoTableBinary(
    const std::vector<std::string>& effectNames) {
    std::vector<unsigned char> data;
    AppendUInt32Le(data, 1499087948u);  // 'LDZY'
    AppendUInt32Le(data, 0);            // patched later
    AppendUInt16Le(data, 101u);
    AppendUInt16Le(data, (unsigned short)effectNames.size());
    AppendUInt32Le(data, 1835448u);

    for (size_t i = 0; i < effectNames.size(); ++i) {
        for (int j = 0; j < 18; ++j) {
            AppendInt32Le(data, (j == 0) ? (int)(i + 1) : 0);
        }
        AppendUtf8String(data, effectNames[i]);
        AppendInt32Le(data, 0);
        AppendUtf8String(data, "");
        for (int j = 0; j < 7; ++j) {
            AppendInt32Le(data, 0);
        }
    }

    PatchUInt32Le(data, 4, (unsigned int)data.size());
    return data;
}

static void AppendIntVector(std::vector<unsigned char>& data, const std::vector<int>& values) {
    AppendUInt32Le(data, (unsigned int)values.size());
    for (size_t i = 0; i < values.size(); ++i) {
        AppendInt32Le(data, values[i]);
    }
}

struct TestNpcShapeRow {
    int id;
    std::string shape;
    std::string roleimage;
    std::string chatimageleft;
    std::string chatimageright;
    int headID;
    int littleheadID;
    int mapheadID;
    std::string name;
    int dir;
    int hitmove;
    int shadow;
    std::string attack;
    std::string magic;
    std::string behit;
    std::string death;
    int nearorfar;
    int shadertype;
    std::vector<int> part0;
    std::vector<int> part1;
    std::vector<int> part2;
    int showWeaponId;
    int showHorseShape;
    int mapheadcID;
};

static TestNpcShapeRow MakeTestNpcShapeRow(const std::string& shape,
                                           const std::string& attack,
                                           const std::string& magic,
                                           const std::string& behit,
                                           const std::string& death) {
    TestNpcShapeRow row;
    row.id = 1;
    row.shape = shape;
    row.roleimage = "";
    row.chatimageleft = "";
    row.chatimageright = "";
    row.headID = 0;
    row.littleheadID = 0;
    row.mapheadID = 0;
    row.name = "demo";
    row.dir = 4;
    row.hitmove = 1;
    row.shadow = 2;
    row.attack = attack;
    row.magic = magic;
    row.behit = behit;
    row.death = death;
    row.nearorfar = 0;
    row.shadertype = 0;
    row.showWeaponId = 0;
    row.showHorseShape = 0;
    row.mapheadcID = 0;
    return row;
}

static std::vector<unsigned char> BuildNpcShapeTableBinary(
    const std::vector<TestNpcShapeRow>& rows) {
    std::vector<unsigned char> data;
    AppendUInt32Le(data, 1499087948u);  // 'LDZY'
    AppendUInt32Le(data, 0);            // patched later
    AppendUInt16Le(data, 101u);
    AppendUInt16Le(data, (unsigned short)rows.size());
    AppendUInt32Le(data, 1573215u);

    for (size_t i = 0; i < rows.size(); ++i) {
        const TestNpcShapeRow& row = rows[i];
        AppendInt32Le(data, row.id);
        AppendUtf8String(data, row.shape);
        AppendUtf8String(data, row.roleimage);
        AppendUtf8String(data, row.chatimageleft);
        AppendUtf8String(data, row.chatimageright);
        AppendInt32Le(data, row.headID);
        AppendInt32Le(data, row.littleheadID);
        AppendInt32Le(data, row.mapheadID);
        AppendUtf8String(data, row.name);
        AppendInt32Le(data, row.dir);
        AppendInt32Le(data, row.hitmove);
        AppendInt32Le(data, row.shadow);
        AppendUtf8String(data, row.attack);
        AppendUtf8String(data, row.magic);
        AppendUtf8String(data, row.behit);
        AppendUtf8String(data, row.death);
        AppendInt32Le(data, row.nearorfar);
        AppendInt32Le(data, row.shadertype);
        AppendIntVector(data, row.part0);
        AppendIntVector(data, row.part1);
        AppendIntVector(data, row.part2);
        AppendInt32Le(data, row.showWeaponId);
        AppendInt32Le(data, row.showHorseShape);
        AppendInt32Le(data, row.mapheadcID);
    }

    PatchUInt32Le(data, 4, (unsigned int)data.size());
    return data;
}

struct TestNpcActionInfoRow {
    int id;
    std::string model;
    int weapon;
    std::string attack;
    std::string magic;
    std::string attacked;
    std::string dying;
    std::string death;
    std::string defence;
    std::string run;
    std::string battlestand;
    std::string stand;
    std::string ridrun;
    std::string ridstand;
};

static TestNpcActionInfoRow MakeTestNpcActionInfoRow(const std::string& model,
                                                     const std::string& attack) {
    TestNpcActionInfoRow row;
    row.id = 1;
    row.model = model;
    row.weapon = 0;
    row.attack = attack;
    row.magic = "magic1";
    row.attacked = "attacked";
    row.dying = "death2";
    row.death = "death";
    row.defence = "defend";
    row.run = "run";
    row.battlestand = "stand3";
    row.stand = "stand1";
    row.ridrun = "riding_run";
    row.ridstand = "riding_stand1";
    return row;
}

static std::vector<unsigned char> BuildNpcActionInfoTableBinary(
    const std::vector<TestNpcActionInfoRow>& rows) {
    std::vector<unsigned char> data;
    AppendUInt32Le(data, 1499087948u);  // 'LDZY'
    AppendUInt32Le(data, 0);            // patched later
    AppendUInt16Le(data, 101u);
    AppendUInt16Le(data, (unsigned short)rows.size());
    AppendUInt32Le(data, 917659u);

    for (size_t i = 0; i < rows.size(); ++i) {
        const TestNpcActionInfoRow& row = rows[i];
        AppendInt32Le(data, row.id);
        AppendUtf8String(data, row.model);
        AppendInt32Le(data, row.weapon);
        AppendUtf8String(data, row.attack);
        AppendUtf8String(data, row.magic);
        AppendUtf8String(data, row.attacked);
        AppendUtf8String(data, row.dying);
        AppendUtf8String(data, row.death);
        AppendUtf8String(data, row.defence);
        AppendUtf8String(data, row.run);
        AppendUtf8String(data, row.battlestand);
        AppendUtf8String(data, row.stand);
        AppendUtf8String(data, row.ridrun);
        AppendUtf8String(data, row.ridstand);
    }

    PatchUInt32Le(data, 4, (unsigned int)data.size());
    return data;
}

struct TestNpcRideRow {
    int id;
    int ridemodel;
    int speed;
    int isstand;
    int effectId;
    int effectPosX;
    int effectPosY;
    std::string desc;
};

static TestNpcRideRow MakeTestNpcRideRow(int ridemodel) {
    TestNpcRideRow row;
    row.id = 1;
    row.ridemodel = ridemodel;
    row.speed = 1200;
    row.isstand = 0;
    row.effectId = 0;
    row.effectPosX = 0;
    row.effectPosY = 0;
    row.desc = "";
    return row;
}

static std::vector<unsigned char> BuildNpcRideTableBinary(
    const std::vector<TestNpcRideRow>& rows,
    unsigned int checkNumber = 458787u) {
    std::vector<unsigned char> data;
    AppendUInt32Le(data, 1499087948u);  // 'LDZY'
    AppendUInt32Le(data, 0);            // patched later
    AppendUInt16Le(data, 101u);
    AppendUInt16Le(data, (unsigned short)rows.size());
    AppendUInt32Le(data, checkNumber);

    for (size_t i = 0; i < rows.size(); ++i) {
        const TestNpcRideRow& row = rows[i];
        AppendInt32Le(data, row.id);
        AppendInt32Le(data, row.ridemodel);
        if (checkNumber == 524335u) {
            AppendInt32Le(data, row.isstand);
            AppendInt32Le(data, row.speed);
        } else {
            AppendInt32Le(data, row.speed);
            AppendInt32Le(data, row.isstand);
        }
        AppendInt32Le(data, row.effectId);
        AppendInt32Le(data, row.effectPosX);
        AppendInt32Le(data, row.effectPosY);
        if (checkNumber == 524335u) {
            AppendUtf8String(data, row.desc);
        }
    }

    PatchUInt32Le(data, 4, (unsigned int)data.size());
    return data;
}

static std::vector<unsigned char> BuildSpineEffectRegistryXml(const std::string& effectName) {
    const std::string xml =
        "<data>\n"
        "    <effect name=\"" + effectName + "\" des=\"demo\"/>\n"
        "</data>\n";
    return BuildUtf8Text(xml);
}

static std::vector<unsigned char> BuildMinimalSpineAtlas(const std::string& imageName) {
    const std::string atlas =
        imageName + "\n"
        "size: 1,1\n"
        "format: RGBA8888\n"
        "filter: Linear,Linear\n"
        "repeat: none\n"
        "\n"
        "root\n"
        "  rotate: false\n"
        "  xy: 0, 0\n"
        "  size: 1, 1\n"
        "  orig: 1, 1\n"
        "  offset: 0, 0\n"
        "  index: -1\n";
    return BuildUtf8Text(atlas);
}

static std::vector<unsigned char> BuildMinimalSpineJson() {
    const std::string json =
        "{\n"
        "\"skeleton\": { \"hash\": \"demo\", \"spine\": \"3.0.08\", \"images\": \"./images/\" },\n"
        "\"bones\": [ { \"name\": \"root\" } ],\n"
        "\"slots\": [],\n"
        "\"skins\": { \"default\": {} },\n"
        "\"animations\": { \"play\": {} }\n"
        "}\n";
    return BuildUtf8Text(json);
}

static std::vector<unsigned char> BuildSpineAtlasWithRegions(
    const std::string& imageName,
    const std::vector<std::string>& regionNames) {
    std::string atlas =
        imageName + "\n"
        "size: 1,1\n"
        "format: RGBA8888\n"
        "filter: Linear,Linear\n"
        "repeat: none\n";

    for (size_t i = 0; i < regionNames.size(); ++i) {
        atlas += "\n";
        atlas += regionNames[i];
        atlas += "\n"
                 "  rotate: false\n"
                 "  xy: 0, 0\n"
                 "  size: 1, 1\n"
                 "  orig: 1, 1\n"
                 "  offset: 0, 0\n"
                 "  index: -1\n";
    }

    return BuildUtf8Text(atlas);
}

static std::vector<unsigned char> BuildSpineJsonWithAttachments(
    const std::vector<std::string>& attachmentNames) {
    std::ostringstream json;
    json << "{\n";
    json << "\"skeleton\": { \"hash\": \"demo\", \"spine\": \"3.0.08\", \"images\": \"./images/\" },\n";
    json << "\"bones\": [ { \"name\": \"root\" } ],\n";
    json << "\"slots\": [\n";
    for (size_t i = 0; i < attachmentNames.size(); ++i) {
        json << "  { \"name\": \"slot" << i
             << "\", \"bone\": \"root\", \"attachment\": \"" << attachmentNames[i] << "\" }";
        if (i + 1u < attachmentNames.size()) {
            json << ",";
        }
        json << "\n";
    }
    json << "],\n";
    json << "\"skins\": { \"default\": {\n";
    for (size_t i = 0; i < attachmentNames.size(); ++i) {
        json << "  \"slot" << i << "\": {\n";
        json << "    \"" << attachmentNames[i] << "\": { \"width\": 1, \"height\": 1 }\n";
        json << "  }";
        if (i + 1u < attachmentNames.size()) {
            json << ",";
        }
        json << "\n";
    }
    json << "} },\n";
    json << "\"animations\": { \"play\": {} }\n";
    json << "}\n";
    return BuildUtf8Text(json.str());
}

static std::vector<unsigned char> BuildSpineJsonWithAttachmentsAndLooseStemToken(
    const std::vector<std::string>& attachmentNames,
    const std::string& looseStemToken) {
    std::ostringstream json;
    json << "{\n";
    json << "\"skeleton\": { \"hash\": \"demo\", \"spine\": \"3.0.08\", \"images\": \"./images/\" },\n";
    json << "\"bones\": [ { \"name\": \"root\" } ],\n";
    json << "\"slots\": [\n";
    for (size_t i = 0; i < attachmentNames.size(); ++i) {
        json << "  { \"name\": \"slot" << i
             << "\", \"bone\": \"root\", \"attachment\": \"" << attachmentNames[i] << "\" }";
        if (i + 1u < attachmentNames.size()) {
            json << ",";
        }
        json << "\n";
    }
    json << "],\n";
    json << "\"skins\": { \"default\": {\n";
    for (size_t i = 0; i < attachmentNames.size(); ++i) {
        json << "  \"slot" << i << "\": {\n";
        json << "    \"" << attachmentNames[i] << "\": { \"width\": 1, \"height\": 1 }\n";
        json << "  }";
        if (i + 1u < attachmentNames.size()) {
            json << ",";
        }
        json << "\n";
    }
    json << "} },\n";
    json << "\"animations\": {\n";
    json << "  \"play\": {\n";
    json << "    \"slots\": {\n";
    json << "      \"fx\": {\n";
    json << "        \"attachment\": [ { \"time\": 0, \"name\": \"" << looseStemToken << "\" } ]\n";
    json << "      }\n";
    json << "    }\n";
    json << "  }\n";
    json << "}\n";
    json << "}\n";
    return BuildUtf8Text(json.str());
}

static std::vector<unsigned char> BuildCreateRoleConfigBin(const std::string& spineName,
                                                           const std::string& liziName,
                                                           const std::string& bgName) {
    std::vector<unsigned char> data;
    data.reserve(512);

    AppendUInt32Le(data, 1499087948u);
    AppendUInt32Le(data, 0);
    AppendUInt16Le(data, 101u);
    AppendUInt16Le(data, 1u);
    AppendUInt32Le(data, 2163342u);

    AppendInt32Le(data, 1);
    AppendInt32Le(data, 1);
    AppendUtf8String(data, "测试角色");
    AppendUtf8String(data, "test_role");
    AppendUtf8String(data, "demo");
    AppendIntVector(data, std::vector<int>());
    AppendIntVector(data, std::vector<int>());
    AppendInt32Le(data, 1);

    for (int i = 0; i < 5; ++i) {
        AppendUtf8String(data, "");
    }
    for (int i = 0; i < 5; ++i) {
        AppendUtf8String(data, "");
    }

    AppendUtf8String(data, spineName);
    AppendUtf8String(data, liziName);
    AppendUtf8String(data, bgName);
    AppendUtf8String(data, "");
    AppendUtf8String(data, "set:left image:1");
    AppendUtf8String(data, "set:right image:1");
    AppendUtf8String(data, "set:desc image:1");

    const unsigned int fileLength = (unsigned int)data.size();
    data[4] = (unsigned char)(fileLength & 0xFF);
    data[5] = (unsigned char)((fileLength >> 8) & 0xFF);
    data[6] = (unsigned char)((fileLength >> 16) & 0xFF);
    data[7] = (unsigned char)((fileLength >> 24) & 0xFF);
    return data;
}

static void AppendTableBinString(std::vector<unsigned char>& data, const std::string& value) {
    AppendInt32Le(data, (int)value.size());
    data.insert(data.end(), value.begin(), value.end());
}

static std::vector<unsigned char> BuildMapConfigBinRows(const std::vector<std::string>& resdirs) {
    std::vector<unsigned char> data;
    data.reserve(256 * (resdirs.empty() ? 1 : resdirs.size()));

    AppendInt32Le(data, 1499087948);
    AppendInt32Le(data, 0);
    AppendUInt16Le(data, 101u);
    AppendUInt16Le(data, (unsigned short)resdirs.size());
    AppendInt32Le(data, 1704330);

    for (size_t index = 0; index < resdirs.size(); ++index) {
        AppendInt32Le(data, 5001 + (int)index);
        AppendTableBinString(data, "demo_map_" + std::to_string(index + 1));
        AppendTableBinString(data, "demo_icon");
        AppendTableBinString(data, "demo_desc");
        AppendTableBinString(data, resdirs[index]);
        AppendInt32Le(data, 0);
        AppendInt32Le(data, 0);
        AppendInt32Le(data, 0);
        AppendInt32Le(data, 0);
        AppendInt32Le(data, 0);
        AppendInt32Le(data, 0);
        AppendInt32Le(data, 0);
        data.push_back(0);
        for (int i = 0; i < 7; ++i) {
            AppendInt32Le(data, 0);
        }
        AppendTableBinString(data, "scene.mp3");
        AppendInt32Le(data, 0);
        AppendInt32Le(data, 0);
        AppendTableBinString(data, "255,255,255");
        AppendInt32Le(data, 0);
        AppendInt32Le(data, 0);
    }

    const unsigned int fileLength = (unsigned int)data.size();
    data[4] = (unsigned char)(fileLength & 0xFF);
    data[5] = (unsigned char)((fileLength >> 8) & 0xFF);
    data[6] = (unsigned char)((fileLength >> 16) & 0xFF);
    data[7] = (unsigned char)((fileLength >> 24) & 0xFF);
    return data;
}

static std::vector<unsigned char> BuildMapConfigBin(const std::string& resdir) {
    std::vector<std::string> resdirs;
    resdirs.push_back(resdir);
    return BuildMapConfigBinRows(resdirs);
}

static std::vector<unsigned char> BuildQuyuData() {
    std::vector<unsigned char> data;
    data.push_back('Q');
    data.push_back('U');
    data.push_back('Y');
    data.push_back('U');
    data.push_back(0x01);
    data.push_back(0x00);
    data.push_back(0x00);
    data.push_back(0x00);
    return data;
}

static bool WriteBinaryVector(const std::string& path, const std::vector<unsigned char>& data) {
    return CreateTestFile(path, data.data(), data.size());
}

static int g_IndexIoUnzipCallCount = 0;
static unsigned int g_IndexIoForcedDecompressedSize = 0;

static unsigned int CountingUnexpectedUnzip(unsigned char* /*pDest*/,
                                            unsigned int* /*pDest_len*/,
                                            const unsigned char* /*pSource*/,
                                            unsigned int /*source_len*/) {
    ++g_IndexIoUnzipCallCount;
    return 0;
}

static unsigned int ReportingSizedUnzip(unsigned char* pDest,
                                        unsigned int* pDest_len,
                                        const unsigned char* /*pSource*/,
                                        unsigned int /*source_len*/) {
    ++g_IndexIoUnzipCallCount;
    if (pDest_len != nullptr) {
        *pDest_len = g_IndexIoForcedDecompressedSize;
    }
    if (pDest != nullptr && g_IndexIoForcedDecompressedSize > 0) {
        std::memset(pDest, 0x5A, g_IndexIoForcedDecompressedSize);
    }
    return 0;
}

static void PassthroughDecrypt(unsigned char* inBuff,
                               unsigned char* ouBuff,
                               unsigned int uiSize,
                               std::string /*strPassword*/) {
    if (uiSize == 0 || inBuff == nullptr || ouBuff == nullptr || inBuff == ouBuff) {
        return;
    }
    std::memcpy(ouBuff, inBuff, uiSize);
}

static unsigned int AlwaysFailUnzip(unsigned char* /*pDest*/,
                                    unsigned int* /*pDest_len*/,
                                    const unsigned char* /*pSource*/,
                                    unsigned int /*source_len*/) {
    ++g_IndexIoUnzipCallCount;
    return 1234;
}

static unsigned int HugeBufErrorUnzip(unsigned char* /*pDest*/,
                                      unsigned int* pDest_len,
                                      const unsigned char* /*pSource*/,
                                      unsigned int /*source_len*/) {
    ++g_IndexIoUnzipCallCount;
    if (pDest_len != nullptr) {
        *pDest_len = 0x80000000u;
    }
    return (unsigned int)-5;
}

static std::vector<unsigned char> BuildMinimalLjpiIndexPayload(uint32_t fileCount = 0) {
    std::vector<unsigned char> payload;
    AppendUInt32Le(payload, fileCount);
    return payload;
}

static std::vector<unsigned char> BuildLjzipFixtureFromPayload(
    const std::vector<unsigned char>& payload,
    uint32_t originalCRC32) {
    const std::vector<unsigned char> compressed = CompressBuffer(payload);
    const std::vector<unsigned char> encrypted =
        EncryptAllBlocksLegacy(compressed, SLJFP::DEFAULT_DECRYPT_KEY);

    std::vector<unsigned char> ljzipData;
    AppendUInt32Le(ljzipData, SLJFP::LJZIP_MAGIC_KEY);
    AppendUInt32Le(ljzipData, static_cast<unsigned int>(encrypted.size()));
    ljzipData.insert(ljzipData.end(), encrypted.begin(), encrypted.end());
    AppendUInt32Le(ljzipData, static_cast<unsigned int>(compressed.size()));
    AppendUInt32Le(ljzipData, static_cast<unsigned int>(payload.size()));
    AppendUInt32Le(ljzipData, originalCRC32);
    return ljzipData;
}

// ============================================================================
// Index IO Boundary Tests
// ============================================================================

TEST_CASE(Unpacker, LjpiIndexRejectsImpossibleFileCountWithoutAllocating) {
    std::vector<unsigned char> ljpiData;
    AppendUInt32Le(ljpiData, 0xFFFFFFFFu);

    SLJFP::detail::IndexLoadResult result;
    const int parseResult = SLJFP::detail::ParseLjpiBuffer(ljpiData.data(),
                                                           (uint32_t)ljpiData.size(),
                                                           result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_CORRUPTED, parseResult);
    TEST_ASSERT_TRUE(result.fileList.empty());
    TEST_ASSERT_EQ((uint64_t)0, result.totalBytes);
    return true;
}

TEST_CASE(Unpacker, LjpiIndexParsesFromUnalignedBuffer) {
    std::vector<unsigned char> ljpiData;
    ljpiData.push_back(0xCC);
    AppendUInt32Le(ljpiData, 1);
    AppendUInt32Le(ljpiData, 0);
    AppendUInt32Le(ljpiData, 3);
    AppendUInt32Le(ljpiData, 0x11223344u);
    AppendUInt32Le(ljpiData, 0);
    AppendUInt32Le(ljpiData, 0);
    AppendUInt32Le(ljpiData, 0x55667788u);

    SLJFP::detail::IndexLoadResult result;
    const int parseResult = SLJFP::detail::ParseLjpiBuffer(ljpiData.data() + 1,
                                                           (uint32_t)(ljpiData.size() - 1),
                                                           result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, parseResult);
    TEST_ASSERT_EQ((size_t)1, result.fileList.size());
    TEST_ASSERT_EQ(3u, result.fileList[0].m_Size);
    TEST_ASSERT_EQ(0x11223344u, result.fileList[0].m_CRC32);
    TEST_ASSERT_EQ(0x55667788u, result.fileList[0].m_PathFileNameCRC32);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsFilesShorterThanMinimumStructure) {
    const std::string baseDir = "test_output/unpacker_ljzip_truncated_minimum";
    const std::string indexPath = baseDir + "/truncated_minimum.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::vector<unsigned char> ljzipData;
    AppendUInt32Le(ljzipData, SLJFP::LJZIP_MAGIC_KEY);
    AppendUInt32Le(ljzipData, 0);
    AppendUInt32Le(ljzipData, 0);
    AppendUInt32Le(ljzipData, 0);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.unzipFunc = CountingUnexpectedUnzip;
    deps.desms4Func = SLJFP_DeSMS4Ex;

    SLJFP::detail::IndexLoadResult result;
    g_IndexIoUnzipCallCount = 0;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_INVALID_FORMAT, loadResult);
    TEST_ASSERT_EQ(0, g_IndexIoUnzipCallCount);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsPayloadThatLeavesNoRoomForTail) {
    const std::string baseDir = "test_output/unpacker_ljzip_truncated_tail";
    const std::string indexPath = baseDir + "/truncated_tail.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::vector<unsigned char> ljzipData;
    AppendUInt32Le(ljzipData, SLJFP::LJZIP_MAGIC_KEY);
    AppendUInt32Le(ljzipData, 4);    // encryptedSize
    ljzipData.resize(ljzipData.size() + 4, 0xAB);
    AppendUInt32Le(ljzipData, 4);    // compressedSize
    AppendUInt32Le(ljzipData, 4);    // originalSize
    // Deliberately omit originalCRC32 so the payload leaves no room for a full tail.
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.unzipFunc = CountingUnexpectedUnzip;
    deps.desms4Func = SLJFP_DeSMS4Ex;

    SLJFP::detail::IndexLoadResult result;
    g_IndexIoUnzipCallCount = 0;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_INVALID_FORMAT, loadResult);
    TEST_ASSERT_EQ(0, g_IndexIoUnzipCallCount);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsCompressedSizeBeyondEncryptedPayload) {
    const std::string baseDir = "test_output/unpacker_ljzip_invalid_compressed_size";
    const std::string indexPath = baseDir + "/invalid.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::vector<unsigned char> ljzipData;
    AppendUInt32Le(ljzipData, SLJFP::LJZIP_MAGIC_KEY);
    AppendUInt32Le(ljzipData, 16);   // encryptedSize
    ljzipData.resize(ljzipData.size() + 16, 0xAB);
    AppendUInt32Le(ljzipData, 32);   // compressedSize, intentionally larger than encryptedSize
    AppendUInt32Le(ljzipData, 12);   // originalSize
    AppendUInt32Le(ljzipData, 0);    // originalCRC32
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.crc32Func = SLJFP_crc32;
    deps.unzipFunc = CountingUnexpectedUnzip;
    deps.desms4Func = SLJFP_DeSMS4Ex;
    deps.decryptKey = SLJFP::DEFAULT_DECRYPT_KEY;
    deps.verifyCRC32 = true;

    SLJFP::detail::IndexLoadResult result;
    g_IndexIoUnzipCallCount = 0;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_INVALID_FORMAT, loadResult);
    TEST_ASSERT_EQ(0, g_IndexIoUnzipCallCount);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsZeroCompressedPayloadWithoutInvokingInflater) {
    const std::string baseDir = "test_output/unpacker_ljzip_zero_compressed";
    const std::string indexPath = baseDir + "/zero_compressed.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::vector<unsigned char> ljzipData;
    AppendUInt32Le(ljzipData, SLJFP::LJZIP_MAGIC_KEY);
    AppendUInt32Le(ljzipData, 16);   // encryptedSize
    ljzipData.resize(ljzipData.size() + 16, 0x5A);
    AppendUInt32Le(ljzipData, 0);    // compressedSize, malformed
    AppendUInt32Le(ljzipData, 4);    // originalSize
    AppendUInt32Le(ljzipData, 0);    // originalCRC32
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.crc32Func = SLJFP_crc32;
    deps.unzipFunc = CountingUnexpectedUnzip;
    deps.desms4Func = SLJFP_DeSMS4Ex;
    deps.decryptKey = SLJFP::DEFAULT_DECRYPT_KEY;
    deps.verifyCRC32 = false;

    SLJFP::detail::IndexLoadResult result;
    g_IndexIoUnzipCallCount = 0;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_INVALID_FORMAT, loadResult);
    TEST_ASSERT_EQ(0, g_IndexIoUnzipCallCount);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsMissingInflaterForCompressedPayload) {
    const std::string baseDir = "test_output/unpacker_ljzip_missing_inflater";
    const std::string indexPath = baseDir + "/missing_inflater.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::vector<unsigned char> ljzipData;
    AppendUInt32Le(ljzipData, SLJFP::LJZIP_MAGIC_KEY);
    AppendUInt32Le(ljzipData, 16);   // encryptedSize
    ljzipData.resize(ljzipData.size() + 16, 0x44);
    AppendUInt32Le(ljzipData, 16);   // compressedSize
    AppendUInt32Le(ljzipData, 12);   // originalSize
    AppendUInt32Le(ljzipData, 0);    // originalCRC32
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.desms4Func = SLJFP_DeSMS4Ex;
    deps.decryptKey = SLJFP::DEFAULT_DECRYPT_KEY;

    SLJFP::detail::IndexLoadResult result;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_INVALID_FORMAT, loadResult);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsOriginalSizeOverConfiguredLimit) {
    const std::string baseDir = "test_output/unpacker_ljzip_oversize_original";
    const std::string indexPath = baseDir + "/oversize.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::vector<unsigned char> ljzipData;
    AppendUInt32Le(ljzipData, SLJFP::LJZIP_MAGIC_KEY);
    AppendUInt32Le(ljzipData, 16);   // encryptedSize
    ljzipData.resize(ljzipData.size() + 16, 0x11);
    AppendUInt32Le(ljzipData, 16);   // compressedSize
    AppendUInt32Le(ljzipData, SLJFP::MAX_DECOMPRESS_SIZE + 1u);
    AppendUInt32Le(ljzipData, 0);    // originalCRC32
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.crc32Func = SLJFP_crc32;
    deps.unzipFunc = CountingUnexpectedUnzip;
    deps.desms4Func = SLJFP_DeSMS4Ex;
    deps.decryptKey = SLJFP::DEFAULT_DECRYPT_KEY;
    deps.verifyCRC32 = false;

    SLJFP::detail::IndexLoadResult result;
    g_IndexIoUnzipCallCount = 0;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_DECOMPRESS_TOO_LARGE, loadResult);
    TEST_ASSERT_EQ(0, g_IndexIoUnzipCallCount);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsDecompressedSizeDrift) {
    const std::string baseDir = "test_output/unpacker_ljzip_size_drift";
    const std::string indexPath = baseDir + "/size_drift.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::vector<unsigned char> ljzipData;
    AppendUInt32Le(ljzipData, SLJFP::LJZIP_MAGIC_KEY);
    AppendUInt32Le(ljzipData, 16);   // encryptedSize
    ljzipData.resize(ljzipData.size() + 16, 0x33);
    AppendUInt32Le(ljzipData, 16);   // compressedSize
    AppendUInt32Le(ljzipData, 12);   // originalSize
    AppendUInt32Le(ljzipData, 0);    // originalCRC32
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.unzipFunc = ReportingSizedUnzip;
    deps.desms4Func = PassthroughDecrypt;
    deps.decryptKey = SLJFP::DEFAULT_DECRYPT_KEY;
    deps.verifyCRC32 = false;

    SLJFP::detail::IndexLoadResult result;
    g_IndexIoUnzipCallCount = 0;
    g_IndexIoForcedDecompressedSize = 11;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_CORRUPTED, loadResult);
    TEST_ASSERT_EQ(1, g_IndexIoUnzipCallCount);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexReturnsDecompressFailedWhenInflaterReportsError) {
    const std::string baseDir = "test_output/unpacker_ljzip_inflater_failure";
    const std::string indexPath = baseDir + "/inflater_failure.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    const std::vector<unsigned char> payload = BuildMinimalLjpiIndexPayload();
    const uint32_t payloadCRC32 = SLJFP_crc32(
        0, payload.data(), static_cast<unsigned int>(payload.size()));
    const std::vector<unsigned char> ljzipData =
        BuildLjzipFixtureFromPayload(payload, payloadCRC32);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.crc32Func = SLJFP_crc32;
    deps.unzipFunc = AlwaysFailUnzip;
    deps.desms4Func = SLJFP_DeSMS4Ex;
    deps.decryptKey = SLJFP::DEFAULT_DECRYPT_KEY;
    deps.verifyCRC32 = true;

    SLJFP::detail::IndexLoadResult result;
    g_IndexIoUnzipCallCount = 0;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_DECOMPRESS_FAILED, loadResult);
    TEST_ASSERT_EQ(1, g_IndexIoUnzipCallCount);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsCRC32MismatchAfterSuccessfulDecode) {
    const std::string baseDir = "test_output/unpacker_ljzip_crc_mismatch";
    const std::string indexPath = baseDir + "/crc_mismatch.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    const std::vector<unsigned char> payload = BuildMinimalLjpiIndexPayload();
    const std::vector<unsigned char> ljzipData =
        BuildLjzipFixtureFromPayload(payload, 0xA5A5A5A5u);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.crc32Func = SLJFP_crc32;
    deps.unzipFunc = SLJFP_mz_uncompress;
    deps.desms4Func = SLJFP_DeSMS4Ex;
    deps.decryptKey = SLJFP::DEFAULT_DECRYPT_KEY;
    deps.verifyCRC32 = true;

    SLJFP::detail::IndexLoadResult result;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_CRC32_MISMATCH, loadResult);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LjzipIndexRejectsMissingCRC32FunctionWhenVerificationEnabled) {
    const std::string baseDir = "test_output/unpacker_ljzip_missing_crc32_func";
    const std::string indexPath = baseDir + "/missing_crc32_func.ljzip";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    const std::vector<unsigned char> payload = BuildMinimalLjpiIndexPayload();
    const uint32_t payloadCRC32 = SLJFP_crc32(
        0, payload.data(), static_cast<unsigned int>(payload.size()));
    const std::vector<unsigned char> ljzipData =
        BuildLjzipFixtureFromPayload(payload, payloadCRC32);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, ljzipData));

    SLJFP::detail::IndexLoadDependencies deps;
    deps.unzipFunc = SLJFP_mz_uncompress;
    deps.desms4Func = SLJFP_DeSMS4Ex;
    deps.decryptKey = SLJFP::DEFAULT_DECRYPT_KEY;
    deps.verifyCRC32 = true;

    SLJFP::detail::IndexLoadResult result;
    const int loadResult = SLJFP::detail::LoadLjzipIndexData(indexPath, deps, result);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_INVALID_FORMAT, loadResult);

    CleanupTestDirectory(baseDir);
    return true;
}

// ============================================================================
// Unpacker Constructor Tests
// ============================================================================

TEST_CASE(Unpacker, Constructor) {
    // Test constructor works normally
    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    // Initial state check
    TEST_ASSERT_EQ((uint32_t)0, unpacker.GetTotalFiles());
    TEST_ASSERT_EQ((uint32_t)0, unpacker.GetProcessedFiles());
    TEST_ASSERT_EQ((uint32_t)0, unpacker.GetFailedFiles());
    TEST_ASSERT_FALSE(unpacker.IsRunning());

    return true;
}

TEST_CASE(Unpacker, DefaultOptions) {
    // Test default options
    SLJFP::UnpackOptions options;

    TEST_ASSERT_TRUE(options.verifyCRC32);
    TEST_ASSERT_FALSE(options.overwriteExisting);
    TEST_ASSERT_TRUE(options.createDirectories);
    TEST_ASSERT_EQ(1, options.threadCount);
    TEST_ASSERT_FALSE(options.relocateRootNumericResiduals);
    TEST_ASSERT_TRUE(options.writePathManifest);

    return true;
}

// ============================================================================
// Index File Loading Tests
// ============================================================================

TEST_CASE(Unpacker, LoadIndex_NotFound) {
    // Test loading non-existent index file
    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    int result = unpacker.LoadIndex("nonexistent_directory/");
    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_NOT_FOUND, result);

    return true;
}

TEST_CASE(Unpacker, LoadIndex_EmptyPath) {
    // Test empty path
    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    int result = unpacker.LoadIndex("");
    TEST_ASSERT_NE((int)SLJFP::LJFP_SUCCESS, result);

    return true;
}

TEST_CASE(Unpacker, UnpackSingle_UsesIndexDirectoryAfterLoadIndex) {
    const std::string baseDir = "test_output/unpacker_single_uses_index_dir";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string explicitOutputPath = outputDir + "/single.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::string logicalPath = "single/path";
    const std::vector<unsigned char> fileData = BuildUtf8Text("single-file-from-index-dir");
    const unsigned int pathCrc =
        SLJFP_crc32(0, reinterpret_cast<const unsigned char*>(logicalPath.data()),
                    (unsigned int)logicalPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackSingle(0, explicitOutputPath));

    std::vector<unsigned char> restoredData;
    TEST_ASSERT_TRUE(ReadTestFile(explicitOutputPath, restoredData));
    TEST_ASSERT_EQ(fileData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredData.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, UnpackSingleAcceptsStaleCompressionFlagOnlyOnSizeAndCrcMatch) {
    const std::string baseDir = "test_output/unpacker_stale_compression_flag";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string outputPath = outputDir + "/restored.png";
    const std::string logicalPath = "image/stale-compression.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildTinyPng();
    const unsigned int pathCrc =
        SLJFP_crc32(0, reinterpret_cast<const unsigned char*>(logicalPath.data()),
                    (unsigned int)logicalPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 1); // stale compression flag
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackSingle(0, outputPath));

    std::vector<unsigned char> restoredData;
    TEST_ASSERT_TRUE(ReadTestFile(outputPath, restoredData));
    TEST_ASSERT_EQ(fileData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredData.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, ConfigureSession_AllowsSingleFileOutputRoot) {
    const std::string baseDir = "test_output/unpacker_single_configure_session";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::string logicalPath = "table/config/demo.bin";
    const std::vector<unsigned char> fileData = BuildUtf8Text("single-file-session-output");
    const unsigned int pathCrc =
        SLJFP_crc32(0, reinterpret_cast<const unsigned char*>(logicalPath.data()),
                    (unsigned int)logicalPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.detectFileType = false;
    options.organizeByType = false;

    unpacker.ConfigureSession("", outputDir, options);
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackSingle(0));

    std::vector<unsigned char> restoredData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + std::to_string(pathCrc), restoredData));
    TEST_ASSERT_EQ(fileData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredData.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, GetPathMappingMissingSamples_ReturnsUnmappedPathCrcs) {
    const std::string baseDir = "test_output/unpacker_missing_mapping_samples";
    const std::string inputDir = baseDir + "/input";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = baseDir + "/mapping.txt";
    const std::string logicalPath = "map/need_repair.bin";
    const std::vector<unsigned char> fileData = BuildUtf8Text("mapping-gap");

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));

    const unsigned int pathCrc =
        SLJFP_crc32(0, reinterpret_cast<const unsigned char*>(logicalPath.data()),
                    (unsigned int)logicalPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary);
    TEST_ASSERT_TRUE(mappingFile.is_open());
    mappingFile << "0x11111111\tplaceholder/path.bin\n";
    mappingFile.close();

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    uint32_t hit = 0;
    uint32_t total = 0;
    uint32_t rateBasis = 0;
    TEST_ASSERT_TRUE(unpacker.GetPathMappingHitRate(hit, total, rateBasis));
    TEST_ASSERT_EQ(0u, hit);
    TEST_ASSERT_EQ(1u, total);
    TEST_ASSERT_EQ(0u, rateBasis);

    const std::vector<uint32_t> missingSamples = unpacker.GetPathMappingMissingSamples();
    TEST_ASSERT_EQ((size_t)1, missingSamples.size());
    TEST_ASSERT_EQ(pathCrc, missingSamples[0]);
    TEST_ASSERT_EQ(0, unpacker.FindFileByCRC32(pathCrc));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LoadPathMapping_StripsResourceRootPrefixes) {
    const std::string baseDir = "test_output/unpacker_strip_mapping_prefixes";
    const std::string mappingPath = baseDir + "/mapping.txt";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
    TEST_ASSERT_TRUE(mappingFile.is_open());
    mappingFile << "0x12345678\tresource/res/cfg/android_notify.xml\n";
    mappingFile << "0x23456789\tres/ui/layouts/demo.layout\n";
    mappingFile.close();

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    const std::map<uint32_t, std::string>& mappingTable = unpacker.GetPathMappingTable();
    TEST_ASSERT_EQ((std::string)"cfg/android_notify.xml", mappingTable.find(0x12345678)->second);
    TEST_ASSERT_EQ((std::string)"ui/layouts/demo.layout", mappingTable.find(0x23456789)->second);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LoadPathMappingBinary_StripsResourceRootPrefixes) {
    const std::string baseDir = "test_output/unpacker_strip_mapping_prefixes_binary";
    const std::string mappingPath = baseDir + "/mapping.ljpm";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    SLJFP::PathMappingGenerator generator;
    generator.AddPathWithCRC("resource/res/cfg/android_notify.xml", 0x12345678);
    generator.AddPathWithCRC("res/ui/layouts/demo.layout", 0x23456789);
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, generator.SaveMappingBinary(mappingPath));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    const std::map<uint32_t, std::string>& mappingTable = unpacker.GetPathMappingTable();
    TEST_ASSERT_EQ((std::string)"cfg/android_notify.xml", mappingTable.find(0x12345678)->second);
    TEST_ASSERT_EQ((std::string)"ui/layouts/demo.layout", mappingTable.find(0x23456789)->second);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, LoadPathMappingBinaryRejectsOversizedPathLength) {
    const std::string baseDir = "test_output/unpacker_binary_mapping_oversized_pathlen";
    const std::string mappingPath = baseDir + "/mapping.ljpm";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));

    std::vector<unsigned char> data;
    AppendUInt32Le(data, 0x4D504A4Cu); // "LJPM"
    AppendUInt32Le(data, 1);
    AppendUInt32Le(data, 1);
    AppendUInt32Le(data, 0x12345678u);
    AppendUInt16Le(data, 4096u);
    TEST_ASSERT_TRUE(WriteBinaryVector(mappingPath, data));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_INDEX_INVALID_FORMAT,
                   unpacker.LoadPathMapping(mappingPath));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, ReadSourceFileDataRejectsLooseFileLargerThanLimit) {
    const std::string baseDir = "test_output/unpacker_loose_file_too_large";
    const std::string inputDir = baseDir + "/input";
    const uint32_t pathCrc = 0xAABBCCDDu;
    const std::string sourcePath = inputDir + "/" + std::to_string(pathCrc);

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));

    std::ofstream file(sourcePath.c_str(), std::ios::binary | std::ios::trunc);
    TEST_ASSERT_TRUE(file.is_open());
    file.seekp((std::streamoff)SLJFP::MAX_DECOMPRESS_SIZE, std::ios::beg);
    const char marker = 0;
    file.write(&marker, 1);
    file.close();

    SLJFP::FileInfo fileInfo;
    fileInfo.m_PackIndex = 0;
    fileInfo.m_PathFileNameCRC32 = pathCrc;

    std::vector<unsigned char> data;
    const int readResult = SLJFP::detail::ReadSourceFileData(inputDir, fileInfo, data);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_DECOMPRESS_TOO_LARGE, readResult);
    TEST_ASSERT_TRUE(data.empty());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, UnpackAll_UsesCanonicalMappedPath) {
    const std::string baseDir = "test_output/unpacker_build_output_path_canonical";
    const std::string inputDir = baseDir + "/input";
    const std::string mappingPath = baseDir + "/mapping.txt";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string outputDir = baseDir + "/output";
    const std::string logicalPath = "cfg/android_notify.xml";
    const uint32_t pathCrc =
        SLJFP_crc32(0, reinterpret_cast<const unsigned char*>(logicalPath.data()),
                    (unsigned int)logicalPath.size());
    const std::vector<unsigned char> fileData = BuildUtf8Text("canonical-output-path");
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
    TEST_ASSERT_TRUE(mappingFile.is_open());
    mappingFile << "0x" << std::hex << pathCrc << "\tresource/res/cfg/android_notify.xml\n";
    mappingFile.close();

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.preferPathMapping = true;
    options.forceCrcOutputFirst = false;
    options.overwriteExisting = true;
    options.threadCount = 1;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredData;
    std::vector<unsigned char> unexpectedResourceData;
    std::vector<unsigned char> unexpectedResData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/cfg/android_notify.xml", restoredData));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/resource/res/cfg/android_notify.xml",
                                   unexpectedResourceData));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/res/cfg/android_notify.xml",
                                   unexpectedResData));
    TEST_ASSERT_EQ(fileData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredData.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, ReadDecodedFileSample_ReturnsMappedLogicalPathAndTrimmedBytes) {
    const std::string baseDir = "test_output/unpacker_read_decoded_sample";
    const std::string inputDir = baseDir + "/input";
    const std::string mappingPath = baseDir + "/mapping.txt";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string logicalPath = "cfg/android_notify.xml";
    const std::vector<unsigned char> fileData = BuildUtf8Text("decoded-sample-bytes");
    const uint32_t pathCrc =
        SLJFP_crc32(0,
                    reinterpret_cast<const unsigned char*>(logicalPath.data()),
                    (unsigned int)logicalPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
    TEST_ASSERT_TRUE(mappingFile.is_open());
    mappingFile << "0x" << std::hex << pathCrc << "\tresource/res/cfg/android_notify.xml\n";
    mappingFile.close();

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    std::vector<unsigned char> sampleBytes;
    std::string resolvedPath;
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS,
                   unpacker.ReadDecodedFileSample(0, 7, sampleBytes, &resolvedPath));
    TEST_ASSERT_EQ((std::string)"cfg/android_notify.xml", resolvedPath);
    TEST_ASSERT_EQ((size_t)7, sampleBytes.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), sampleBytes.data(), sampleBytes.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, UnpackSelected_ProcessesOnlyRequestedIndices) {
    const std::string baseDir = "test_output/unpacker_selected_subset";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::string logicalPaths[3] = {
        "selected/a.bin",
        "selected/b.bin",
        "selected/c.bin"
    };
    const std::vector<unsigned char> payloads[3] = {
        BuildUtf8Text("alpha"),
        BuildUtf8Text("beta"),
        BuildUtf8Text("gamma")
    };

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);
    unsigned int pathCrcs[3] = { 0, 0, 0 };
    for (int i = 0; i < 3; ++i) {
        pathCrcs[i] = SLJFP_crc32(0,
            reinterpret_cast<const unsigned char*>(logicalPaths[i].data()),
            static_cast<unsigned int>(logicalPaths[i].size()));
        const unsigned int dataCrc = SLJFP_crc32(0,
            payloads[i].data(),
            static_cast<unsigned int>(payloads[i].size()));

        TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrcs[i]), payloads[i]));
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, static_cast<unsigned int>(payloads[i].size()));
        AppendUInt32Le(indexData, dataCrc);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.detectFileType = false;
    options.organizeByType = false;
    options.threadCount = 2;

    std::vector<size_t> selectedIndices;
    selectedIndices.push_back(0);
    selectedIndices.push_back(2);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS,
                   unpacker.UnpackSelected(selectedIndices, inputDir, outputDir, options));
    TEST_ASSERT_EQ(2u, unpacker.GetProcessedFiles());
    TEST_ASSERT_EQ(0u, unpacker.GetFailedFiles());

    std::vector<unsigned char> restoredData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + std::to_string(pathCrcs[0]), restoredData));
    TEST_ASSERT_EQ(payloads[0].size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(payloads[0].data(), restoredData.data(), payloads[0].size());

    restoredData.clear();
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + std::to_string(pathCrcs[2]), restoredData));
    TEST_ASSERT_EQ(payloads[2].size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(payloads[2].data(), restoredData.data(), payloads[2].size());

    std::vector<unsigned char> absentData;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(pathCrcs[1]), absentData));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, GetLastFailedFiles_RecordsBatchFailures) {
    const std::string baseDir = "test_output/unpacker_failed_file_records";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::string okPath = "failed/ok.bin";
    const std::string missingPath = "failed/missing.bin";
    const std::vector<unsigned char> okPayload = BuildUtf8Text("ok-data");
    const unsigned int okPathCrc = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(okPath.data()),
        static_cast<unsigned int>(okPath.size()));
    const unsigned int missingPathCrc = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(missingPath.data()),
        static_cast<unsigned int>(missingPath.size()));
    const unsigned int okDataCrc = SLJFP_crc32(0,
        okPayload.data(),
        static_cast<unsigned int>(okPayload.size()));

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(okPathCrc), okPayload));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, static_cast<unsigned int>(okPayload.size()));
    AppendUInt32Le(indexData, okDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, okPathCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 16);
    AppendUInt32Le(indexData, 0x12345678u);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, missingPathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.detectFileType = false;
    options.organizeByType = false;
    options.threadCount = 1;

    std::vector<size_t> selectedIndices;
    selectedIndices.push_back(0);
    selectedIndices.push_back(1);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE,
                   unpacker.UnpackSelected(selectedIndices, inputDir, outputDir, options));
    TEST_ASSERT_EQ(1u, unpacker.GetProcessedFiles());
    TEST_ASSERT_EQ(1u, unpacker.GetFailedFiles());

    const std::vector<SLJFP::FailedFileRecord> failedRecords = unpacker.GetLastFailedFiles();
    TEST_ASSERT_EQ((size_t)1, failedRecords.size());
    TEST_ASSERT_EQ(1u, failedRecords[0].fileIndex);
    TEST_ASSERT_EQ(missingPathCrc, failedRecords[0].pathCRC32);
    TEST_ASSERT_EQ(0u, failedRecords[0].packIndex);
    TEST_ASSERT_FALSE(failedRecords[0].mappingHit);
    TEST_ASSERT_EQ(unpacker.GetFirstErrorCode(), failedRecords[0].errorCode);
    TEST_ASSERT_EQ(1u, unpacker.GetFirstErrorFileIndex());

    const std::map<int, uint32_t>& errorCounts = unpacker.GetLastErrorCodeCounts();
    std::map<int, uint32_t>::const_iterator countIt = errorCounts.find(failedRecords[0].errorCode);
    TEST_ASSERT_TRUE(countIt != errorCounts.end());
    TEST_ASSERT_EQ(1u, countIt->second);

    CleanupTestDirectory(baseDir);
    return true;
}

// ============================================================================
// .ljpi Index Parsing Tests
// ============================================================================

TEST_CASE(Unpacker, ParseLjpiData_Empty) {
    // Test empty data parsing
    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    // Create a minimal .ljpi file (only file count field)
    unsigned char data[4] = { 0x00, 0x00, 0x00, 0x00 };  // 0 files

    // Need to test through public interface, skip internal function test for now
    // This mainly verifies parser does not crash

    return true;
}

// ============================================================================
// Unpack Options Tests
// ============================================================================

TEST_CASE(Unpacker, UnpackOptions_VerifyCRC32) {
    // Test CRC32 verification option
    SLJFP::UnpackOptions options;

    options.verifyCRC32 = true;
    TEST_ASSERT_TRUE(options.verifyCRC32);

    options.verifyCRC32 = false;
    TEST_ASSERT_FALSE(options.verifyCRC32);

    return true;
}

TEST_CASE(Unpacker, UnpackOptions_Overwrite) {
    // Test overwrite option
    SLJFP::UnpackOptions options;

    options.overwriteExisting = true;
    TEST_ASSERT_TRUE(options.overwriteExisting);

    options.overwriteExisting = false;
    TEST_ASSERT_FALSE(options.overwriteExisting);

    return true;
}

TEST_CASE(Unpacker, UnpackOptions_ThreadCount) {
    // Test thread count option
    SLJFP::UnpackOptions options;

    options.threadCount = 1;
    TEST_ASSERT_EQ(1, options.threadCount);

    options.threadCount = 4;
    TEST_ASSERT_EQ(4, options.threadCount);

    return true;
}

// ============================================================================
// Progress Callback Tests
// ============================================================================

TEST_CASE(Unpacker, ProgressCallback) {
    // Test progress callback setting
    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    bool callbackCalled = false;
    float lastProgress = 0.0f;
    uint32_t lastCurrent = 0;
    uint32_t lastTotal = 0;

    unpacker.SetProgressCallback([&](float progress, uint32_t current, uint32_t total) {
        callbackCalled = true;
        lastProgress = progress;
        lastCurrent = current;
        lastTotal = total;
    });

    // Callback is only called during actual unpacking, just verify setting doesn't crash
    TEST_ASSERT_FALSE(callbackCalled);  // Not called yet

    return true;
}

// ============================================================================
// FileInfo Structure Tests
// ============================================================================

TEST_CASE(FileInfo, DefaultValues) {
    // Test FileInfo default values
    SLJFP::FileInfo info;

    TEST_ASSERT_EQ((unsigned int)0, info.m_PackIndex);
    TEST_ASSERT_EQ((unsigned int)0, info.m_Pos);
    TEST_ASSERT_EQ((unsigned int)0, info.m_Size);
    TEST_ASSERT_EQ((unsigned int)0, info.m_CRC32);
    TEST_ASSERT_EQ((unsigned int)0, info.m_CompressType);
    TEST_ASSERT_EQ((unsigned int)0, info.m_CodeType);
    TEST_ASSERT_EQ((unsigned int)0, info.m_SizeOriginal);
    TEST_ASSERT_EQ((unsigned int)0, info.m_CRC32Original);
    TEST_ASSERT_EQ((unsigned int)0, info.m_PathFileNameCRC32);

    return true;
}

// ============================================================================
// Constants Definition Tests
// ============================================================================

TEST_CASE(Constants, MagicKey) {
    // Test magic key constant
    TEST_ASSERT_EQ((unsigned int)9999, SLJFP::LJZIP_MAGIC_KEY);

    return true;
}

TEST_CASE(Constants, DefaultKey) {
    // Test default key
    std::string key = SLJFP::DEFAULT_DECRYPT_KEY;
    TEST_ASSERT_EQ((size_t)16, key.length());
    TEST_ASSERT_EQ(std::string("locojoy123456789"), key);

    return true;
}

TEST_CASE(Constants, MaxDecompressSize) {
    // Test max decompress size
    TEST_ASSERT_EQ((unsigned int)(100 * 1024 * 1024), SLJFP::MAX_DECOMPRESS_SIZE);

    return true;
}

// ============================================================================
// Stop and Clear Tests
// ============================================================================

TEST_CASE(Unpacker, Stop) {
    // Test stop function
    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    // Calling Stop when not running should not crash
    unpacker.Stop();
    TEST_ASSERT_FALSE(unpacker.IsRunning());

    return true;
}

TEST_CASE(Unpacker, Clear) {
    // Test clear function
    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    unpacker.Clear();
    TEST_ASSERT_EQ((uint32_t)0, unpacker.GetTotalFiles());
    TEST_ASSERT_EQ((uint32_t)0, unpacker.GetProcessedFiles());
    TEST_ASSERT_EQ((uint32_t)0, unpacker.GetFailedFiles());

    return true;
}

TEST_CASE(Unpacker, RestoreModelAniReferencedTexturePath) {
    const std::string baseDir = "test_output/unpacker_model_ani_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string aniPath = "model/test-model/body/bodyonly/stand1.ani";
    const std::string imagePath = "model/test-model/body/bodyonly/stand1_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int aniPathCrc = SLJFP_crc32(0, (const unsigned char*)aniPath.data(), (unsigned int)aniPath.size());
    const unsigned int imagePathCrc = SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());
    const unsigned int aniDataCrc = SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc = SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, aniPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData.size());
    AppendUInt32Le(indexData, pngDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagePathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << aniPathCrc << "|" << aniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> restoredPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aniPath, restoredAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredPng));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredPng.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredPng.data(), pngData.size());

    std::vector<unsigned char> leftoverPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png", leftoverPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreCanonicalModelAniDirectoryFromUniqueTextureBase) {
    const std::string baseDir = "test_output/unpacker_canonical_model_ani_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedAniPath = "model/demo/body/bodyonly/stand1.ani";
    const std::string namedPngPath = "model/demo/body/bodyonly/stand1_res000.png";
    const std::string unresolvedAniPath = "orphan/demo_stand1.ani";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> namedAniData = BuildMinimalModelAni(L"_res000.png", L"stand1");
    const std::vector<unsigned char> unresolvedAniData = BuildMinimalModelAni(L"_res000.png", L"stand1");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int namedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath.data(), (unsigned int)namedAniPath.size());
    const unsigned int namedPngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedPngPath.data(), (unsigned int)namedPngPath.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)unresolvedAniPath.data(), (unsigned int)unresolvedAniPath.size());
    const unsigned int namedAniDataCrc =
        SLJFP_crc32(0, namedAniData.data(), (unsigned int)namedAniData.size());
    const unsigned int unresolvedAniDataCrc =
        SLJFP_crc32(0, unresolvedAniData.data(), (unsigned int)unresolvedAniData.size());
    const unsigned int pngDataCrc = SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc), namedAniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedPngPathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), unresolvedAniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)namedAniData.size());
    AppendUInt32Le(indexData, namedAniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedAniPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData.size());
    AppendUInt32Le(indexData, pngDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedPngPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)unresolvedAniData.size());
    AppendUInt32Le(indexData, unresolvedAniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAniPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedAniPathCrc << "|" << namedAniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string canonicalAniPath =
        outputDir + "/model/demo/body/bodyonly/" + std::to_string(unresolvedAniPathCrc) + ".ani";
    std::vector<unsigned char> restoredCanonicalAni;
    std::vector<unsigned char> restoredNamedAni;
    TEST_ASSERT_TRUE(ReadTestFile(canonicalAniPath, restoredCanonicalAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedAniPath, restoredNamedAni));
    TEST_ASSERT_EQ(unresolvedAniData.size(), restoredCanonicalAni.size());
    TEST_ASSERT_EQ(namedAniData.size(), restoredNamedAni.size());
    TEST_ASSERT_MEM_EQ(unresolvedAniData.data(), restoredCanonicalAni.data(), unresolvedAniData.size());
    TEST_ASSERT_MEM_EQ(namedAniData.data(), restoredNamedAni.data(), namedAniData.size());

    std::vector<unsigned char> leftoverRootAni;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(unresolvedAniPathCrc) + ".ani",
                                   leftoverRootAni));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, SkipCanonicalModelAniDirectoryRestoreWhenAmbiguous) {
    const std::string baseDir = "test_output/unpacker_canonical_model_ani_ambiguous";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedAniPath1 = "model/demo1/body/bodyonly/stand1.ani";
    const std::string namedPngPath1 = "model/demo1/body/bodyonly/stand1_res000.png";
    const std::string namedAniPath2 = "model/demo2/body/bodyonly/stand1.ani";
    const std::string namedPngPath2 = "model/demo2/body/bodyonly/stand1_res000.png";
    const std::string unresolvedAniPath = "orphan/demo_stand1.ani";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png", L"stand1");
    std::vector<unsigned char> unresolvedAniData = BuildMinimalModelAni(L"_res000.png", L"stand1");
    PatchUInt32Le(unresolvedAniData, 16, 900u);
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int namedAniPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath1.data(), (unsigned int)namedAniPath1.size());
    const unsigned int namedPngPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)namedPngPath1.data(), (unsigned int)namedPngPath1.size());
    const unsigned int namedAniPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath2.data(), (unsigned int)namedAniPath2.size());
    const unsigned int namedPngPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)namedPngPath2.data(), (unsigned int)namedPngPath2.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)unresolvedAniPath.data(), (unsigned int)unresolvedAniPath.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int unresolvedAniDataCrc =
        SLJFP_crc32(0, unresolvedAniData.data(), (unsigned int)unresolvedAniData.size());
    const unsigned int pngDataCrc = SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc1), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedPngPathCrc1), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc2), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedPngPathCrc2), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), unresolvedAniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 5);

    const unsigned int pathCrcs[] = {
        namedAniPathCrc1, namedPngPathCrc1,
        namedAniPathCrc2, namedPngPathCrc2,
        unresolvedAniPathCrc
    };
    const unsigned int dataSizes[] = {
        (unsigned int)aniData.size(), (unsigned int)pngData.size(),
        (unsigned int)aniData.size(), (unsigned int)pngData.size(),
        (unsigned int)unresolvedAniData.size()
    };
    const unsigned int dataCrcs[] = {
        aniDataCrc, pngDataCrc,
        aniDataCrc, pngDataCrc,
        unresolvedAniDataCrc
    };

    for (int i = 0; i < 5; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, dataSizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedAniPathCrc1 << "|" << namedAniPath1 << "\n";
        mappingFile << namedAniPathCrc2 << "|" << namedAniPath2 << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> unresolvedRootAni;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + std::to_string(unresolvedAniPathCrc) + ".ani",
                                  unresolvedRootAni));
    TEST_ASSERT_EQ(unresolvedAniData.size(), unresolvedRootAni.size());
    TEST_ASSERT_MEM_EQ(unresolvedAniData.data(), unresolvedRootAni.data(), unresolvedAniData.size());

    std::vector<unsigned char> canonicalAni1;
    std::vector<unsigned char> canonicalAni2;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/model/demo1/body/bodyonly/" +
                                   std::to_string(unresolvedAniPathCrc) + ".ani",
                                   canonicalAni1));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/model/demo2/body/bodyonly/" +
                                   std::to_string(unresolvedAniPathCrc) + ".ani",
                                   canonicalAni2));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreAniReferencedTextureExtensionFallbackPath) {
    const std::string baseDir = "test_output/unpacker_ani_texture_extension_fallback";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string aniPath = "effect/animation/ui/dianji/putong/nor.ani";
    const std::string imagePath = "effect/animation/ui/dianji/putong/nor_res001.dds";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res001.png");
    const std::vector<unsigned char> ddsData = BuildTinyDds();

    const unsigned int aniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)aniPath.data(), (unsigned int)aniPath.size());
    const unsigned int imagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int ddsDataCrc =
        SLJFP_crc32(0, ddsData.data(), (unsigned int)ddsData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), ddsData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, aniPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)ddsData.size());
    AppendUInt32Le(indexData, ddsDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagePathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << aniPathCrc << "|" << aniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> restoredDds;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aniPath, restoredAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredDds));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_EQ(ddsData.size(), restoredDds.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(ddsData.data(), restoredDds.data(), ddsData.size());

    std::vector<unsigned char> leftoverDds;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".dds",
                                   leftoverDds));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreFashionWeaponAliasModelResources) {
    const std::string baseDir = "test_output/unpacker_fashion_weapon_alias_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string registryPath = "model/sprites.set";
    const std::string modelName = "fashion-hutouguai1";
    const std::string actionPath = "model/" + modelName + "/action/action.lmx";
    const std::string layerDefPath = "model/" + modelName + "/layerdef.lmx";
    const std::string weaponPath = "model/" + modelName + "/weapon/weapon.lmx";
    const std::string aniPath = "model/" + modelName + "/weapon/207/attack1.ani";
    const std::string imagePath = "model/" + modelName + "/weapon/207/attack1_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> registryData =
        BuildUtf16LeText("<data><model name=\"fashion-hutouguai1\" des=\"demo_fashion_role\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" scale=\"1.000000\"/></data>");
    const std::vector<unsigned char> actionData =
        BuildUtf16LeText("<data><action name=\"attack1\"/></data>");
    const std::vector<unsigned char> layerDefData =
        BuildUtf16LeText("<data><layer id=\"1\" name=\"weapon\" des=\"weapon\" type=\"0\"/></data>");
    const std::vector<unsigned char> weaponData =
        BuildUtf16LeText("<data><weapon name=\"207\"/></data>");
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int registryPathCrc =
        SLJFP_crc32(0, (const unsigned char*)registryPath.data(), (unsigned int)registryPath.size());
    const unsigned int actionPathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionPath.data(), (unsigned int)actionPath.size());
    const unsigned int layerDefPathCrc =
        SLJFP_crc32(0, (const unsigned char*)layerDefPath.data(), (unsigned int)layerDefPath.size());
    const unsigned int weaponPathCrc =
        SLJFP_crc32(0, (const unsigned char*)weaponPath.data(), (unsigned int)weaponPath.size());
    const unsigned int aniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)aniPath.data(), (unsigned int)aniPath.size());
    const unsigned int imagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());

    const unsigned int registryDataCrc =
        SLJFP_crc32(0, registryData.data(), (unsigned int)registryData.size());
    const unsigned int actionDataCrc =
        SLJFP_crc32(0, actionData.data(), (unsigned int)actionData.size());
    const unsigned int layerDefDataCrc =
        SLJFP_crc32(0, layerDefData.data(), (unsigned int)layerDefData.size());
    const unsigned int weaponDataCrc =
        SLJFP_crc32(0, weaponData.data(), (unsigned int)weaponData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(registryPathCrc), registryData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionPathCrc), actionData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(layerDefPathCrc), layerDefData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(weaponPathCrc), weaponData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 6);

    const unsigned int sizes[] = {
        (unsigned int)registryData.size(),
        (unsigned int)actionData.size(),
        (unsigned int)layerDefData.size(),
        (unsigned int)weaponData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        registryDataCrc,
        actionDataCrc,
        layerDefDataCrc,
        weaponDataCrc,
        aniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        registryPathCrc,
        actionPathCrc,
        layerDefPathCrc,
        weaponPathCrc,
        aniPathCrc,
        imagePathCrc
    };

    for (int i = 0; i < 6; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << registryPathCrc << "|" << registryPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> restoredPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aniPath, restoredAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredPng));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredPng.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredPng.data(), pngData.size());

    std::vector<unsigned char> leftoverAni;
    std::vector<unsigned char> leftoverPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aniPathCrc) + ".ani", leftoverAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png", leftoverPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreModelTextureVariantsFromMappedWeaponAniBases) {
    const std::string baseDir = "test_output/unpacker_model_weapon_texture_variants";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string registryPath = "model/sprites.set";
    const std::string modelName = "fashion-jianxiake1";
    const std::string actionPath = "model/" + modelName + "/action/action.lmx";
    const std::string layerDefPath = "model/" + modelName + "/layerdef.lmx";
    const std::string weaponPath = "model/" + modelName + "/weapon/weapon.lmx";
    const std::string aniPath = "model/" + modelName + "/weapon/207/run.ani";
    const std::string imagePath = "model/" + modelName + "/weapon/207/run_res000.png";
    const std::string extraImagePath = "model/" + modelName + "/weapon/207/run_res002.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> registryData =
        BuildUtf16LeText("<data><model name=\"fashion-jianxiake1\" des=\"demo_fashion_role\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" scale=\"1.000000\"/></data>");
    const std::vector<unsigned char> actionData =
        BuildUtf16LeText("<data><action name=\"run\"/></data>");
    const std::vector<unsigned char> layerDefData =
        BuildUtf16LeText("<data><layer id=\"1\" name=\"weapon\" des=\"weapon\" type=\"0\"/></data>");
    const std::vector<unsigned char> weaponData =
        BuildUtf16LeText("<data><weapon name=\"207\"/></data>");
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int registryPathCrc =
        SLJFP_crc32(0, (const unsigned char*)registryPath.data(), (unsigned int)registryPath.size());
    const unsigned int actionPathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionPath.data(), (unsigned int)actionPath.size());
    const unsigned int layerDefPathCrc =
        SLJFP_crc32(0, (const unsigned char*)layerDefPath.data(), (unsigned int)layerDefPath.size());
    const unsigned int weaponPathCrc =
        SLJFP_crc32(0, (const unsigned char*)weaponPath.data(), (unsigned int)weaponPath.size());
    const unsigned int aniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)aniPath.data(), (unsigned int)aniPath.size());
    const unsigned int imagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());
    const unsigned int extraImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)extraImagePath.data(), (unsigned int)extraImagePath.size());

    const unsigned int registryDataCrc =
        SLJFP_crc32(0, registryData.data(), (unsigned int)registryData.size());
    const unsigned int actionDataCrc =
        SLJFP_crc32(0, actionData.data(), (unsigned int)actionData.size());
    const unsigned int layerDefDataCrc =
        SLJFP_crc32(0, layerDefData.data(), (unsigned int)layerDefData.size());
    const unsigned int weaponDataCrc =
        SLJFP_crc32(0, weaponData.data(), (unsigned int)weaponData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(registryPathCrc), registryData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionPathCrc), actionData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(layerDefPathCrc), layerDefData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(weaponPathCrc), weaponData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(extraImagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 7);

    const unsigned int sizes[] = {
        (unsigned int)registryData.size(),
        (unsigned int)actionData.size(),
        (unsigned int)layerDefData.size(),
        (unsigned int)weaponData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        registryDataCrc,
        actionDataCrc,
        layerDefDataCrc,
        weaponDataCrc,
        aniDataCrc,
        pngDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        registryPathCrc,
        actionPathCrc,
        layerDefPathCrc,
        weaponPathCrc,
        aniPathCrc,
        imagePathCrc,
        extraImagePathCrc
    };

    for (int i = 0; i < 7; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << registryPathCrc << "|" << registryPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> restoredPng;
    std::vector<unsigned char> restoredExtraPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aniPath, restoredAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredPng));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + extraImagePath, restoredExtraPng));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredPng.size());
    TEST_ASSERT_EQ(pngData.size(), restoredExtraPng.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredPng.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredExtraPng.data(), pngData.size());

    std::vector<unsigned char> leftoverAni;
    std::vector<unsigned char> leftoverPng;
    std::vector<unsigned char> leftoverExtraPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aniPathCrc) + ".ani", leftoverAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png", leftoverPng));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(extraImagePathCrc) + ".png",
                                   leftoverExtraPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreModelBodyFallbackActionResources) {
    const std::string baseDir = "test_output/unpacker_model_body_fallback_actions";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string registryPath = "model/sprites.set";
    const std::string actionTypePath = "model/actiontype.set";
    const std::string rideSeedModelName = "fashion-feiyannv1";
    const std::string actionTypeModelName = "ts1-yingji";
    const std::string ridingModelName = "zz09-jiulingyuansheng";
    const std::string rideSeedActionPath = "model/" + rideSeedModelName + "/action/action.lmx";
    const std::string actionTypeModelActionPath =
        "model/" + actionTypeModelName + "/action/action.lmx";
    const std::string actionTypeModelLayerPath =
        "model/" + actionTypeModelName + "/layerdef.lmx";
    const std::string actionTypeModelBodyPath =
        "model/" + actionTypeModelName + "/body/body.lmx";
    const std::string actionTypeAniPath =
        "model/" + actionTypeModelName + "/body/bodyonly/attack1.ani";
    const std::string actionTypeImagePath =
        "model/" + actionTypeModelName + "/body/bodyonly/attack1_res000.png";
    const std::string ridingModelActionPath =
        "model/" + ridingModelName + "/action/action.lmx";
    const std::string ridingModelLayerPath =
        "model/" + ridingModelName + "/layerdef.lmx";
    const std::string ridingModelBodyPath =
        "model/" + ridingModelName + "/body/body.lmx";
    const std::string ridingAniPath =
        "model/" + ridingModelName + "/body/bodyonly/riding_run.ani";
    const std::string ridingImagePath =
        "model/" + ridingModelName + "/body/bodyonly/riding_run_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> registryData = BuildUtf16LeText(
        "<data>"
        "<model name=\"fashion-feiyannv1\" des=\"seed_role\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" scale=\"1.000000\"/>"
        "<model name=\"ts1-yingji\" des=\"demo_model_a\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" scale=\"1.000000\"/>"
        "<model name=\"zz09-jiulingyuansheng\" des=\"demo_model_b\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" scale=\"1.000000\"/>"
        "</data>");
    const std::vector<unsigned char> actionTypeData = BuildUtf16LeText(
        "<data><type id=\"4\" des=\"attack\"><action name=\"attack1\"/></type></data>");
    const std::vector<unsigned char> rideSeedActionData = BuildUtf16LeText(
        "<data><action name=\"riding_run\"/><action name=\"riding_stand1\"/></data>");
    const std::vector<unsigned char> actionTypeModelActionData = BuildUtf16LeText(
        "<data><action name=\"magic1\"/><action name=\"stand1\"/></data>");
    const std::vector<unsigned char> ridingModelActionData = BuildUtf16LeText(
        "<data><action name=\"run\"/><action name=\"stand1\"/></data>");
    const std::vector<unsigned char> layerDefData = BuildUtf16LeText(
        "<data><layer id=\"1\" name=\"body\" des=\"body\" type=\"0\"/></data>");
    const std::vector<unsigned char> bodyData = BuildUtf16LeText(
        "<data><body name=\"bodyonly\"/></data>");
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int registryPathCrc =
        SLJFP_crc32(0, (const unsigned char*)registryPath.data(), (unsigned int)registryPath.size());
    const unsigned int actionTypePathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionTypePath.data(), (unsigned int)actionTypePath.size());
    const unsigned int rideSeedActionPathCrc =
        SLJFP_crc32(0, (const unsigned char*)rideSeedActionPath.data(), (unsigned int)rideSeedActionPath.size());
    const unsigned int actionTypeModelActionPathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionTypeModelActionPath.data(), (unsigned int)actionTypeModelActionPath.size());
    const unsigned int actionTypeModelLayerPathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionTypeModelLayerPath.data(), (unsigned int)actionTypeModelLayerPath.size());
    const unsigned int actionTypeModelBodyPathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionTypeModelBodyPath.data(), (unsigned int)actionTypeModelBodyPath.size());
    const unsigned int actionTypeAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionTypeAniPath.data(), (unsigned int)actionTypeAniPath.size());
    const unsigned int actionTypeImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionTypeImagePath.data(), (unsigned int)actionTypeImagePath.size());
    const unsigned int ridingModelActionPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingModelActionPath.data(), (unsigned int)ridingModelActionPath.size());
    const unsigned int ridingModelLayerPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingModelLayerPath.data(), (unsigned int)ridingModelLayerPath.size());
    const unsigned int ridingModelBodyPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingModelBodyPath.data(), (unsigned int)ridingModelBodyPath.size());
    const unsigned int ridingAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingAniPath.data(), (unsigned int)ridingAniPath.size());
    const unsigned int ridingImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingImagePath.data(), (unsigned int)ridingImagePath.size());

    const unsigned int registryDataCrc =
        SLJFP_crc32(0, registryData.data(), (unsigned int)registryData.size());
    const unsigned int actionTypeDataCrc =
        SLJFP_crc32(0, actionTypeData.data(), (unsigned int)actionTypeData.size());
    const unsigned int rideSeedActionDataCrc =
        SLJFP_crc32(0, rideSeedActionData.data(), (unsigned int)rideSeedActionData.size());
    const unsigned int actionTypeModelActionDataCrc =
        SLJFP_crc32(0, actionTypeModelActionData.data(), (unsigned int)actionTypeModelActionData.size());
    const unsigned int actionTypeModelLayerDataCrc =
        SLJFP_crc32(0, layerDefData.data(), (unsigned int)layerDefData.size());
    const unsigned int actionTypeModelBodyDataCrc =
        SLJFP_crc32(0, bodyData.data(), (unsigned int)bodyData.size());
    const unsigned int ridingModelActionDataCrc =
        SLJFP_crc32(0, ridingModelActionData.data(), (unsigned int)ridingModelActionData.size());
    const unsigned int ridingModelLayerDataCrc =
        SLJFP_crc32(0, layerDefData.data(), (unsigned int)layerDefData.size());
    const unsigned int ridingModelBodyDataCrc =
        SLJFP_crc32(0, bodyData.data(), (unsigned int)bodyData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(registryPathCrc), registryData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionTypePathCrc), actionTypeData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(rideSeedActionPathCrc), rideSeedActionData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionTypeModelActionPathCrc), actionTypeModelActionData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionTypeModelLayerPathCrc), layerDefData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionTypeModelBodyPathCrc), bodyData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionTypeAniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionTypeImagePathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingModelActionPathCrc), ridingModelActionData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingModelLayerPathCrc), layerDefData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingModelBodyPathCrc), bodyData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingAniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingImagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 13);

    const unsigned int sizes[] = {
        (unsigned int)registryData.size(),
        (unsigned int)actionTypeData.size(),
        (unsigned int)rideSeedActionData.size(),
        (unsigned int)actionTypeModelActionData.size(),
        (unsigned int)layerDefData.size(),
        (unsigned int)bodyData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)ridingModelActionData.size(),
        (unsigned int)layerDefData.size(),
        (unsigned int)bodyData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        registryDataCrc,
        actionTypeDataCrc,
        rideSeedActionDataCrc,
        actionTypeModelActionDataCrc,
        actionTypeModelLayerDataCrc,
        actionTypeModelBodyDataCrc,
        aniDataCrc,
        pngDataCrc,
        ridingModelActionDataCrc,
        ridingModelLayerDataCrc,
        ridingModelBodyDataCrc,
        aniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        registryPathCrc,
        actionTypePathCrc,
        rideSeedActionPathCrc,
        actionTypeModelActionPathCrc,
        actionTypeModelLayerPathCrc,
        actionTypeModelBodyPathCrc,
        actionTypeAniPathCrc,
        actionTypeImagePathCrc,
        ridingModelActionPathCrc,
        ridingModelLayerPathCrc,
        ridingModelBodyPathCrc,
        ridingAniPathCrc,
        ridingImagePathCrc
    };

    for (int i = 0; i < 13; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << registryPathCrc << "|" << registryPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredActionTypeAni;
    std::vector<unsigned char> restoredActionTypePng;
    std::vector<unsigned char> restoredRidingAni;
    std::vector<unsigned char> restoredRidingPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + actionTypeAniPath, restoredActionTypeAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + actionTypeImagePath, restoredActionTypePng));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + ridingAniPath, restoredRidingAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + ridingImagePath, restoredRidingPng));
    TEST_ASSERT_EQ(aniData.size(), restoredActionTypeAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredActionTypePng.size());
    TEST_ASSERT_EQ(aniData.size(), restoredRidingAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredRidingPng.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredActionTypeAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredActionTypePng.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredRidingAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredRidingPng.data(), pngData.size());

    std::vector<unsigned char> leftoverActionTypeAni;
    std::vector<unsigned char> leftoverActionTypePng;
    std::vector<unsigned char> leftoverRidingAni;
    std::vector<unsigned char> leftoverRidingPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(actionTypeAniPathCrc) + ".ani",
                                   leftoverActionTypeAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(actionTypeImagePathCrc) + ".png",
                                   leftoverActionTypePng));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(ridingAniPathCrc) + ".ani",
                                   leftoverRidingAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(ridingImagePathCrc) + ".png",
                                   leftoverRidingPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreModelBodyTextureVariantsFromMappedAniBases) {
    const std::string baseDir = "test_output/unpacker_model_body_texture_variants";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string registryPath = "model/sprites.set";
    const std::string modelName = "fashion-jumowang1";
    const std::string actionPath = "model/" + modelName + "/action/action.lmx";
    const std::string layerPath = "model/" + modelName + "/layerdef.lmx";
    const std::string bodyPath = "model/" + modelName + "/body/body.lmx";
    const std::string ridingRun2AniPath =
        "model/" + modelName + "/body/bodyonly/riding_run2.ani";
    const std::string ridingRun2PngPath =
        "model/" + modelName + "/body/bodyonly/riding_run2_res000.png";
    const std::string ridingRun2ExtraPngPath =
        "model/" + modelName + "/body/bodyonly/riding_run2_res002.png";
    const std::string ridingStand2AniPath =
        "model/" + modelName + "/body/bodyonly/riding_stand2.ani";
    const std::string ridingStand2PngPath =
        "model/" + modelName + "/body/bodyonly/riding_stand2_res001.png";
    const std::string ridingStand2ExtraPngPath =
        "model/" + modelName + "/body/bodyonly/riding_stand2_res002.png";
    const std::string stand1AniPath =
        "model/" + modelName + "/body/bodyonly/stand1.ani";
    const std::string stand1PngPath =
        "model/" + modelName + "/body/bodyonly/stand1_res005.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> registryData = BuildUtf16LeText(
        "<data><model name=\"fashion-jumowang1\" des=\"demo_model\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" scale=\"1.000000\"/></data>");
    const std::vector<unsigned char> actionData = BuildUtf16LeText(
        "<data><action name=\"riding_run2\"/><action name=\"riding_stand2\"/><action name=\"stand1\"/></data>");
    const std::vector<unsigned char> layerData = BuildUtf16LeText(
        "<data><layer id=\"1\" name=\"body\" des=\"body\" type=\"0\"/></data>");
    const std::vector<unsigned char> bodyData = BuildUtf16LeText(
        "<data><body name=\"bodyonly\"/></data>");
    const std::vector<unsigned char> ridingRun2AniData =
        BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> ridingStand2AniData =
        BuildMinimalModelAni(L"_res001.png");
    const std::vector<unsigned char> stand1AniData =
        BuildMinimalModelAni(L"_res005.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int registryPathCrc =
        SLJFP_crc32(0, (const unsigned char*)registryPath.data(), (unsigned int)registryPath.size());
    const unsigned int actionPathCrc =
        SLJFP_crc32(0, (const unsigned char*)actionPath.data(), (unsigned int)actionPath.size());
    const unsigned int layerPathCrc =
        SLJFP_crc32(0, (const unsigned char*)layerPath.data(), (unsigned int)layerPath.size());
    const unsigned int bodyPathCrc =
        SLJFP_crc32(0, (const unsigned char*)bodyPath.data(), (unsigned int)bodyPath.size());
    const unsigned int ridingRun2AniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingRun2AniPath.data(), (unsigned int)ridingRun2AniPath.size());
    const unsigned int ridingRun2PngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingRun2PngPath.data(), (unsigned int)ridingRun2PngPath.size());
    const unsigned int ridingRun2ExtraPngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingRun2ExtraPngPath.data(), (unsigned int)ridingRun2ExtraPngPath.size());
    const unsigned int ridingStand2AniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingStand2AniPath.data(), (unsigned int)ridingStand2AniPath.size());
    const unsigned int ridingStand2PngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingStand2PngPath.data(), (unsigned int)ridingStand2PngPath.size());
    const unsigned int ridingStand2ExtraPngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)ridingStand2ExtraPngPath.data(), (unsigned int)ridingStand2ExtraPngPath.size());
    const unsigned int stand1AniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)stand1AniPath.data(), (unsigned int)stand1AniPath.size());
    const unsigned int stand1PngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)stand1PngPath.data(), (unsigned int)stand1PngPath.size());

    const unsigned int registryDataCrc =
        SLJFP_crc32(0, registryData.data(), (unsigned int)registryData.size());
    const unsigned int actionDataCrc =
        SLJFP_crc32(0, actionData.data(), (unsigned int)actionData.size());
    const unsigned int layerDataCrc =
        SLJFP_crc32(0, layerData.data(), (unsigned int)layerData.size());
    const unsigned int bodyDataCrc =
        SLJFP_crc32(0, bodyData.data(), (unsigned int)bodyData.size());
    const unsigned int ridingRun2AniDataCrc =
        SLJFP_crc32(0, ridingRun2AniData.data(), (unsigned int)ridingRun2AniData.size());
    const unsigned int ridingStand2AniDataCrc =
        SLJFP_crc32(0, ridingStand2AniData.data(), (unsigned int)ridingStand2AniData.size());
    const unsigned int stand1AniDataCrc =
        SLJFP_crc32(0, stand1AniData.data(), (unsigned int)stand1AniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(registryPathCrc), registryData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actionPathCrc), actionData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(layerPathCrc), layerData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(bodyPathCrc), bodyData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingRun2AniPathCrc), ridingRun2AniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingRun2PngPathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingRun2ExtraPngPathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingStand2AniPathCrc), ridingStand2AniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingStand2PngPathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(ridingStand2ExtraPngPathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(stand1AniPathCrc), stand1AniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(stand1PngPathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 12);

    const unsigned int sizes[] = {
        (unsigned int)registryData.size(),
        (unsigned int)actionData.size(),
        (unsigned int)layerData.size(),
        (unsigned int)bodyData.size(),
        (unsigned int)ridingRun2AniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)ridingStand2AniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)stand1AniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        registryDataCrc,
        actionDataCrc,
        layerDataCrc,
        bodyDataCrc,
        ridingRun2AniDataCrc,
        pngDataCrc,
        pngDataCrc,
        ridingStand2AniDataCrc,
        pngDataCrc,
        pngDataCrc,
        stand1AniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        registryPathCrc,
        actionPathCrc,
        layerPathCrc,
        bodyPathCrc,
        ridingRun2AniPathCrc,
        ridingRun2PngPathCrc,
        ridingRun2ExtraPngPathCrc,
        ridingStand2AniPathCrc,
        ridingStand2PngPathCrc,
        ridingStand2ExtraPngPathCrc,
        stand1AniPathCrc,
        stand1PngPathCrc
    };

    for (int i = 0; i < 12; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << registryPathCrc << "|" << registryPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredRun2ExtraPng;
    std::vector<unsigned char> restoredStand2ExtraPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + ridingRun2ExtraPngPath, restoredRun2ExtraPng));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + ridingStand2ExtraPngPath, restoredStand2ExtraPng));
    TEST_ASSERT_EQ(pngData.size(), restoredRun2ExtraPng.size());
    TEST_ASSERT_EQ(pngData.size(), restoredStand2ExtraPng.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredRun2ExtraPng.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredStand2ExtraPng.data(), pngData.size());

    std::vector<unsigned char> leftoverRun2ExtraPng;
    std::vector<unsigned char> leftoverStand2ExtraPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(ridingRun2ExtraPngPathCrc) + ".png",
                                   leftoverRun2ExtraPng));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(ridingStand2ExtraPngPathCrc) + ".png",
                                   leftoverStand2ExtraPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreEffectSkillAliasDirectoryResources) {
    const std::string baseDir = "test_output/unpacker_effect_skill_alias_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedAniPath = "effect/animation/skill/lg/3011.ani";
    const std::string mappedPng0Path = "effect/animation/skill/lg/3011_res000.png";
    const std::string mappedPng1Path = "effect/animation/skill/lg/3011_res001.png";
    const std::string mappedTextureOnlyPath = "effect/animation/skill/st/6006_res003.png";
    const std::string aliasAniPath = "effect/animation/skill/acc5-lg/3011.ani";
    const std::string aliasPng0Path = "effect/animation/skill/acc5-lg/3011_res000.png";
    const std::string aliasPng1Path = "effect/animation/skill/acc5-lg/3011_res001.png";
    const std::string aliasTextureOnlyPath = "effect/animation/skill/acc3-st/6006_res003.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int mappedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedAniPath.data(), (unsigned int)mappedAniPath.size());
    const unsigned int mappedPng0PathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPng0Path.data(), (unsigned int)mappedPng0Path.size());
    const unsigned int mappedPng1PathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPng1Path.data(), (unsigned int)mappedPng1Path.size());
    const unsigned int mappedTextureOnlyPathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedTextureOnlyPath.data(), (unsigned int)mappedTextureOnlyPath.size());
    const unsigned int aliasAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)aliasAniPath.data(), (unsigned int)aliasAniPath.size());
    const unsigned int aliasPng0PathCrc =
        SLJFP_crc32(0, (const unsigned char*)aliasPng0Path.data(), (unsigned int)aliasPng0Path.size());
    const unsigned int aliasPng1PathCrc =
        SLJFP_crc32(0, (const unsigned char*)aliasPng1Path.data(), (unsigned int)aliasPng1Path.size());
    const unsigned int aliasTextureOnlyPathCrc =
        SLJFP_crc32(0, (const unsigned char*)aliasTextureOnlyPath.data(), (unsigned int)aliasTextureOnlyPath.size());

    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mappedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mappedPng0PathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mappedPng1PathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mappedTextureOnlyPathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aliasAniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aliasPng0PathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aliasPng1PathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aliasTextureOnlyPathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 8);

    const unsigned int sizes[] = {
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        aniDataCrc,
        pngDataCrc,
        pngDataCrc,
        pngDataCrc,
        aniDataCrc,
        pngDataCrc,
        pngDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        mappedAniPathCrc,
        mappedPng0PathCrc,
        mappedPng1PathCrc,
        mappedTextureOnlyPathCrc,
        aliasAniPathCrc,
        aliasPng0PathCrc,
        aliasPng1PathCrc,
        aliasTextureOnlyPathCrc
    };

    for (int i = 0; i < 8; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << mappedAniPathCrc << "|" << mappedAniPath << "\n";
        mappingFile << mappedPng0PathCrc << "|" << mappedPng0Path << "\n";
        mappingFile << mappedPng1PathCrc << "|" << mappedPng1Path << "\n";
        mappingFile << mappedTextureOnlyPathCrc << "|" << mappedTextureOnlyPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAliasAni;
    std::vector<unsigned char> restoredAliasPng0;
    std::vector<unsigned char> restoredAliasPng1;
    std::vector<unsigned char> restoredAliasTextureOnly;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasAniPath, restoredAliasAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasPng0Path, restoredAliasPng0));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasPng1Path, restoredAliasPng1));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasTextureOnlyPath, restoredAliasTextureOnly));
    TEST_ASSERT_EQ(aniData.size(), restoredAliasAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredAliasPng0.size());
    TEST_ASSERT_EQ(pngData.size(), restoredAliasPng1.size());
    TEST_ASSERT_EQ(pngData.size(), restoredAliasTextureOnly.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAliasAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredAliasPng0.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredAliasPng1.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredAliasTextureOnly.data(), pngData.size());

    std::vector<unsigned char> leftoverAliasAni;
    std::vector<unsigned char> leftoverAliasPng0;
    std::vector<unsigned char> leftoverAliasPng1;
    std::vector<unsigned char> leftoverAliasTextureOnly;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aliasAniPathCrc) + ".ani",
                                   leftoverAliasAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aliasPng0PathCrc) + ".png",
                                   leftoverAliasPng0));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aliasPng1PathCrc) + ".png",
                                   leftoverAliasPng1));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aliasTextureOnlyPathCrc) + ".png",
                                   leftoverAliasTextureOnly));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreEffectSkillAliasAfterSemanticAnimationInference) {
    const std::string baseDir = "test_output/unpacker_effect_skill_alias_after_semantic_inference";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string effectXmlPath = "effect/geffect/skill/lg/molangtaotian.eff.inf";
    const std::string mappedAniPath = "effect/animation/skill/lg/3011.ani";
    const std::string mappedPng0Path = "effect/animation/skill/lg/3011_res000.png";
    const std::string mappedPng1Path = "effect/animation/skill/lg/3011_res001.png";
    const std::string aliasAniPath = "effect/animation/skill/acc5-lg/3011.ani";
    const std::string aliasPng0Path = "effect/animation/skill/acc5-lg/3011_res000.png";
    const std::string aliasPng1Path = "effect/animation/skill/acc5-lg/3011_res001.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> effectXmlData = BuildUtf8Text(
        "<data><clip s_f=\"0\" e_f=\"-1\" layer=\"0\" r_f=\"animation/skill/lg/3011\" "
        "fps=\"10.000000\" rel_x=\"0\" rel_y=\"0\" v_c=\"4294967295\" p_m=\"1\" l_n=\"1\">"
        "<TOOLS_DATA><pos_keys/><scale_keys/><rotation_keys/><alpha_keys/><color_keys/><divide_keys/>"
        "</TOOLS_DATA></clip></data>");
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int effectXmlPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectXmlPath.data(), (unsigned int)effectXmlPath.size());
    const unsigned int mappedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedAniPath.data(), (unsigned int)mappedAniPath.size());
    const unsigned int mappedPng0PathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPng0Path.data(), (unsigned int)mappedPng0Path.size());
    const unsigned int mappedPng1PathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPng1Path.data(), (unsigned int)mappedPng1Path.size());
    const unsigned int aliasAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)aliasAniPath.data(), (unsigned int)aliasAniPath.size());
    const unsigned int aliasPng0PathCrc =
        SLJFP_crc32(0, (const unsigned char*)aliasPng0Path.data(), (unsigned int)aliasPng0Path.size());
    const unsigned int aliasPng1PathCrc =
        SLJFP_crc32(0, (const unsigned char*)aliasPng1Path.data(), (unsigned int)aliasPng1Path.size());

    const unsigned int effectXmlDataCrc =
        SLJFP_crc32(0, effectXmlData.data(), (unsigned int)effectXmlData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectXmlPathCrc), effectXmlData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mappedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mappedPng0PathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mappedPng1PathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aliasAniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aliasPng0PathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aliasPng1PathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 7);

    const unsigned int sizes[] = {
        (unsigned int)effectXmlData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        effectXmlDataCrc,
        aniDataCrc,
        pngDataCrc,
        pngDataCrc,
        aniDataCrc,
        pngDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        effectXmlPathCrc,
        mappedAniPathCrc,
        mappedPng0PathCrc,
        mappedPng1PathCrc,
        aliasAniPathCrc,
        aliasPng0PathCrc,
        aliasPng1PathCrc
    };

    for (int i = 0; i < 7; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << effectXmlPathCrc << "|" << effectXmlPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredMappedAni;
    std::vector<unsigned char> restoredAliasAni;
    std::vector<unsigned char> restoredAliasPng0;
    std::vector<unsigned char> restoredAliasPng1;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + mappedAniPath, restoredMappedAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasAniPath, restoredAliasAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasPng0Path, restoredAliasPng0));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasPng1Path, restoredAliasPng1));
    TEST_ASSERT_EQ(aniData.size(), restoredMappedAni.size());
    TEST_ASSERT_EQ(aniData.size(), restoredAliasAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredAliasPng0.size());
    TEST_ASSERT_EQ(pngData.size(), restoredAliasPng1.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredMappedAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAliasAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredAliasPng0.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredAliasPng1.data(), pngData.size());

    std::vector<unsigned char> leftoverAliasAni;
    std::vector<unsigned char> leftoverAliasPng0;
    std::vector<unsigned char> leftoverAliasPng1;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aliasAniPathCrc) + ".ani",
                                   leftoverAliasAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aliasPng0PathCrc) + ".png",
                                   leftoverAliasPng0));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(aliasPng1PathCrc) + ".png",
                                   leftoverAliasPng1));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreEffectXmlAniAndTextureFromRegistryTokens) {
    const std::string baseDir = "test_output/unpacker_effect_animation_chain_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string registryPath = "table/bintable/EffectPath.ceffectpathnonedrama.bin";
    const std::string effectName = "geffect/demo/testeffect";
    const std::string effectXmlPath = "effect/" + effectName + ".eff.inf";
    const std::string effectAniStem = "animation/demo/test_anim";
    const std::string effectAniPath = "effect/" + effectAniStem + ".ani";
    const std::string effectImagePath = "effect/animation/demo/test_anim_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> registryData =
        BuildUtf8Text("10069\t" + effectName + "\n");
    const std::vector<unsigned char> effectXmlData = BuildUtf8Text(
        "<data t_f=\"10\" d_l=\"0\" b_l=\"0\" b_t=\"0\" b_r=\"0\" b_b=\"0\" fps=\"8.000000\" bT=\"0\" hasA=\"0\">"
        "<clip s_f=\"0\" e_f=\"-1\" layer=\"0\" r_f=\"" + effectAniStem + "\" fps=\"10.000000\" rel_x=\"0\" rel_y=\"0\" v_c=\"4294967295\" p_m=\"1\" l_n=\"1\">"
        "<TOOLS_DATA><pos_keys/><scale_keys/><rotation_keys/><alpha_keys/><color_keys/><divide_keys/></TOOLS_DATA>"
        "</clip></data>");
    const std::vector<unsigned char> effectAniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int registryPathCrc =
        SLJFP_crc32(0, (const unsigned char*)registryPath.data(), (unsigned int)registryPath.size());
    const unsigned int effectXmlPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectXmlPath.data(), (unsigned int)effectXmlPath.size());
    const unsigned int effectAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectAniPath.data(), (unsigned int)effectAniPath.size());
    const unsigned int effectImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectImagePath.data(), (unsigned int)effectImagePath.size());

    const unsigned int registryDataCrc =
        SLJFP_crc32(0, registryData.data(), (unsigned int)registryData.size());
    const unsigned int effectXmlDataCrc =
        SLJFP_crc32(0, effectXmlData.data(), (unsigned int)effectXmlData.size());
    const unsigned int effectAniDataCrc =
        SLJFP_crc32(0, effectAniData.data(), (unsigned int)effectAniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(registryPathCrc), registryData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectXmlPathCrc), effectXmlData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectAniPathCrc), effectAniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectImagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)registryData.size(),
        (unsigned int)effectXmlData.size(),
        (unsigned int)effectAniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        registryDataCrc,
        effectXmlDataCrc,
        effectAniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        registryPathCrc,
        effectXmlPathCrc,
        effectAniPathCrc,
        effectImagePathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << registryPathCrc << "|" << registryPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredRegistry;
    std::vector<unsigned char> restoredEffectXml;
    std::vector<unsigned char> restoredEffectAni;
    std::vector<unsigned char> restoredEffectPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + registryPath, restoredRegistry));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectXmlPath, restoredEffectXml));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectAniPath, restoredEffectAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectImagePath, restoredEffectPng));
    TEST_ASSERT_EQ(registryData.size(), restoredRegistry.size());
    TEST_ASSERT_EQ(effectXmlData.size(), restoredEffectXml.size());
    TEST_ASSERT_EQ(effectAniData.size(), restoredEffectAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredEffectPng.size());
    TEST_ASSERT_MEM_EQ(registryData.data(), restoredRegistry.data(), registryData.size());
    TEST_ASSERT_MEM_EQ(effectXmlData.data(), restoredEffectXml.data(), effectXmlData.size());
    TEST_ASSERT_MEM_EQ(effectAniData.data(), restoredEffectAni.data(), effectAniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredEffectPng.data(), pngData.size());

    std::vector<unsigned char> leftoverXml;
    std::vector<unsigned char> leftoverAni;
    std::vector<unsigned char> leftoverPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectXmlPathCrc) + ".xml", leftoverXml));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectAniPathCrc) + ".ani", leftoverAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectImagePathCrc) + ".png", leftoverPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreSemanticEffectXmlAniAndTextureFromRegistryTokens) {
    const std::string baseDir = "test_output/unpacker_effect_animation_semantic_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string scriptPath = "script/logic/demo/effectdemo.lua";
    const std::string effectName = "geffect/ui/youjian";
    const std::string effectXmlSemanticPath = "effect/" + effectName + ".eff.inf";
    const std::string fakeEffectXmlPath = "mystery/effect_youjian_cfg";
    const std::string effectAniStem = "animation/ui/youjian";
    const std::string effectAniPath = "effect/" + effectAniStem + ".ani";
    const std::string effectImagePath = "effect/animation/ui/youjian_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> scriptData = BuildUtf8Text(
        "return gGetGameUIManager():AddUIEffect(nil, \"geffect/ui/youjian\", true)\n");
    const std::vector<unsigned char> effectXmlData = BuildUtf8Text(
        "<data t_f=\"10\" d_l=\"0\" b_l=\"0\" b_t=\"0\" b_r=\"0\" b_b=\"0\" fps=\"8.000000\" bT=\"0\" hasA=\"0\">"
        "<clip s_f=\"0\" e_f=\"-1\" layer=\"0\" r_f=\"" + effectAniStem + "\" fps=\"1.000000\" rel_x=\"0\" rel_y=\"0\" v_c=\"4294967295\" p_m=\"0\">"
        "<TOOLS_DATA><pos_keys/><scale_keys/><rotation_keys/><alpha_keys/><color_keys/><divide_keys/></TOOLS_DATA>"
        "</clip></data>");
    const std::vector<unsigned char> effectAniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int scriptPathCrc =
        SLJFP_crc32(0, (const unsigned char*)scriptPath.data(), (unsigned int)scriptPath.size());
    const unsigned int fakeEffectXmlPathCrc =
        SLJFP_crc32(0, (const unsigned char*)fakeEffectXmlPath.data(), (unsigned int)fakeEffectXmlPath.size());
    const unsigned int effectAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectAniPath.data(), (unsigned int)effectAniPath.size());
    const unsigned int effectImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectImagePath.data(), (unsigned int)effectImagePath.size());

    const unsigned int scriptDataCrc =
        SLJFP_crc32(0, scriptData.data(), (unsigned int)scriptData.size());
    const unsigned int effectXmlDataCrc =
        SLJFP_crc32(0, effectXmlData.data(), (unsigned int)effectXmlData.size());
    const unsigned int effectAniDataCrc =
        SLJFP_crc32(0, effectAniData.data(), (unsigned int)effectAniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(scriptPathCrc), scriptData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(fakeEffectXmlPathCrc), effectXmlData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectAniPathCrc), effectAniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectImagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)scriptData.size(),
        (unsigned int)effectXmlData.size(),
        (unsigned int)effectAniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        scriptDataCrc,
        effectXmlDataCrc,
        effectAniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        scriptPathCrc,
        fakeEffectXmlPathCrc,
        effectAniPathCrc,
        effectImagePathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << scriptPathCrc << "|" << scriptPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredScript;
    std::vector<unsigned char> restoredEffectAni;
    std::vector<unsigned char> restoredEffectPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + scriptPath, restoredScript));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectAniPath, restoredEffectAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectImagePath, restoredEffectPng));
    TEST_ASSERT_EQ(scriptData.size(), restoredScript.size());
    TEST_ASSERT_EQ(effectAniData.size(), restoredEffectAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredEffectPng.size());
    TEST_ASSERT_MEM_EQ(scriptData.data(), restoredScript.data(), scriptData.size());
    TEST_ASSERT_MEM_EQ(effectAniData.data(), restoredEffectAni.data(), effectAniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredEffectPng.data(), pngData.size());

    const std::string canonicalEffectXmlPath =
        "effect/geffect/ui/" + std::to_string(fakeEffectXmlPathCrc) + ".eff.inf";
    std::vector<unsigned char> unresolvedEffectXml;
    std::vector<unsigned char> leftoverAni;
    std::vector<unsigned char> leftoverPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + effectXmlSemanticPath, unresolvedEffectXml));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + canonicalEffectXmlPath,
                                  unresolvedEffectXml));
    TEST_ASSERT_EQ(effectXmlData.size(), unresolvedEffectXml.size());
    TEST_ASSERT_MEM_EQ(effectXmlData.data(), unresolvedEffectXml.data(), effectXmlData.size());
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(fakeEffectXmlPathCrc) + ".xml",
                                   unresolvedEffectXml));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectAniPathCrc) + ".ani", leftoverAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectImagePathCrc) + ".png", leftoverPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreSemanticEffectXmlWhenTargetPathCrcExists) {
    const std::string baseDir = "test_output/unpacker_effect_animation_semantic_direct_crc_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string scriptPath = "script/logic/demo/effectdemo_redplus.lua";
    const std::string effectName = "geffect/ui/red+";
    const std::string effectXmlSemanticPath = "effect/" + effectName + ".eff.inf";
    const std::string effectAniStem = "animation/ui/red+";
    const std::string effectAniPath = "effect/" + effectAniStem + ".ani";
    const std::string effectImagePath = "effect/animation/ui/red+_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> scriptData = BuildUtf8Text(
        "return gGetGameUIManager():AddUIEffect(nil, \"geffect/ui/red+\", true)\n");
    const std::vector<unsigned char> effectXmlData = BuildUtf8Text(
        "<data t_f=\"10\" d_l=\"0\" b_l=\"0\" b_t=\"0\" b_r=\"0\" b_b=\"0\" fps=\"8.000000\" bT=\"0\" hasA=\"0\">"
        "<clip s_f=\"0\" e_f=\"-1\" layer=\"0\" r_f=\"" + effectAniStem + "\" fps=\"1.000000\" rel_x=\"0\" rel_y=\"0\" v_c=\"4294967295\" p_m=\"0\">"
        "<TOOLS_DATA><pos_keys/><scale_keys/><rotation_keys/><alpha_keys/><color_keys/><divide_keys/></TOOLS_DATA>"
        "</clip></data>");
    const std::vector<unsigned char> effectAniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int scriptPathCrc =
        SLJFP_crc32(0, (const unsigned char*)scriptPath.data(), (unsigned int)scriptPath.size());
    const unsigned int effectXmlSemanticPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectXmlSemanticPath.data(), (unsigned int)effectXmlSemanticPath.size());
    const unsigned int effectAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectAniPath.data(), (unsigned int)effectAniPath.size());
    const unsigned int effectImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectImagePath.data(), (unsigned int)effectImagePath.size());

    const unsigned int scriptDataCrc =
        SLJFP_crc32(0, scriptData.data(), (unsigned int)scriptData.size());
    const unsigned int effectXmlDataCrc =
        SLJFP_crc32(0, effectXmlData.data(), (unsigned int)effectXmlData.size());
    const unsigned int effectAniDataCrc =
        SLJFP_crc32(0, effectAniData.data(), (unsigned int)effectAniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(scriptPathCrc), scriptData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectXmlSemanticPathCrc), effectXmlData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectAniPathCrc), effectAniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectImagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)scriptData.size(),
        (unsigned int)effectXmlData.size(),
        (unsigned int)effectAniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        scriptDataCrc,
        effectXmlDataCrc,
        effectAniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        scriptPathCrc,
        effectXmlSemanticPathCrc,
        effectAniPathCrc,
        effectImagePathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << scriptPathCrc << "|" << scriptPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredScript;
    std::vector<unsigned char> restoredEffectXml;
    std::vector<unsigned char> restoredEffectAni;
    std::vector<unsigned char> restoredEffectPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + scriptPath, restoredScript));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectXmlSemanticPath, restoredEffectXml));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectAniPath, restoredEffectAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectImagePath, restoredEffectPng));
    TEST_ASSERT_EQ(scriptData.size(), restoredScript.size());
    TEST_ASSERT_EQ(effectXmlData.size(), restoredEffectXml.size());
    TEST_ASSERT_EQ(effectAniData.size(), restoredEffectAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredEffectPng.size());
    TEST_ASSERT_MEM_EQ(scriptData.data(), restoredScript.data(), scriptData.size());
    TEST_ASSERT_MEM_EQ(effectXmlData.data(), restoredEffectXml.data(), effectXmlData.size());
    TEST_ASSERT_MEM_EQ(effectAniData.data(), restoredEffectAni.data(), effectAniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredEffectPng.data(), pngData.size());

    std::vector<unsigned char> leftoverSemanticXml;
    std::vector<unsigned char> leftoverAni;
    std::vector<unsigned char> leftoverPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectXmlSemanticPathCrc) + ".xml",
                                   leftoverSemanticXml));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectAniPathCrc) + ".ani", leftoverAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectImagePathCrc) + ".png", leftoverPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreSpriteNpcEffectByClipLeafName) {
    const std::string baseDir = "test_output/unpacker_sprite_npc_effect_leaf_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string effectXmlPath = "effect/geffect/sprite/npc/fengcidianshan.eff.inf";
    const std::string effectAniStem = "animation/sprite/npc/chenghaosanyue/fengcidianshan";
    const std::string effectAniPath = "effect/" + effectAniStem + ".ani";
    const std::string effectImagePath =
        "effect/animation/sprite/npc/chenghaosanyue/fengcidianshan_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> effectXmlData = BuildUtf16LeText(
        "<data t_f=\"100\" d_l=\"0\" b_l=\"0\" b_t=\"0\" b_r=\"0\" b_b=\"0\" fps=\"8.000000\" bT=\"0\" hasA=\"0\">"
        "<clip s_f=\"0\" e_f=\"-1\" layer=\"0\" r_f=\"" + effectAniStem + "\" fps=\"6.024096\" rel_x=\"155\" rel_y=\"147\" v_c=\"4294967295\" p_m=\"0\">"
        "<TOOLS_DATA><pos_keys/><scale_keys/><rotation_keys/><alpha_keys/><color_keys/><divide_keys/></TOOLS_DATA>"
        "</clip></data>");
    const std::vector<unsigned char> effectAniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int effectXmlPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectXmlPath.data(), (unsigned int)effectXmlPath.size());
    const unsigned int effectAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectAniPath.data(), (unsigned int)effectAniPath.size());
    const unsigned int effectImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectImagePath.data(), (unsigned int)effectImagePath.size());

    const unsigned int effectXmlDataCrc =
        SLJFP_crc32(0, effectXmlData.data(), (unsigned int)effectXmlData.size());
    const unsigned int effectAniDataCrc =
        SLJFP_crc32(0, effectAniData.data(), (unsigned int)effectAniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectXmlPathCrc), effectXmlData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectAniPathCrc), effectAniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectImagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    const unsigned int sizes[] = {
        (unsigned int)effectXmlData.size(),
        (unsigned int)effectAniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        effectXmlDataCrc,
        effectAniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        effectXmlPathCrc,
        effectAniPathCrc,
        effectImagePathCrc
    };

    for (int i = 0; i < 3; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        const std::string dummyPath = "script/logic/demo/dummy.lua";
        const unsigned int dummyPathCrc =
            SLJFP_crc32(0, (const unsigned char*)dummyPath.data(), (unsigned int)dummyPath.size());
        mappingFile << dummyPathCrc << "|" << dummyPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredEffectXml;
    std::vector<unsigned char> restoredEffectAni;
    std::vector<unsigned char> restoredEffectPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectXmlPath, restoredEffectXml));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectAniPath, restoredEffectAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectImagePath, restoredEffectPng));
    TEST_ASSERT_EQ(effectXmlData.size(), restoredEffectXml.size());
    TEST_ASSERT_EQ(effectAniData.size(), restoredEffectAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredEffectPng.size());
    TEST_ASSERT_MEM_EQ(effectXmlData.data(), restoredEffectXml.data(), effectXmlData.size());
    TEST_ASSERT_MEM_EQ(effectAniData.data(), restoredEffectAni.data(), effectAniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredEffectPng.data(), pngData.size());

    std::vector<unsigned char> leftoverEffectXml;
    std::vector<unsigned char> leftoverEffectAni;
    std::vector<unsigned char> leftoverEffectPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectXmlPathCrc) + ".xml",
                                   leftoverEffectXml));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectAniPathCrc) + ".ani",
                                   leftoverEffectAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectImagePathCrc) + ".png",
                                   leftoverEffectPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreCanonicalEffectXmlDirectoryFromClipRef) {
    const std::string baseDir = "test_output/unpacker_canonical_effect_xml_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string unresolvedOriginalPath = "misc/effects/teamleader_variant";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> effectXmlData = BuildUtf16LeText(
        "<data t_f=\"5\" d_l=\"0\" b_l=\"0\" b_t=\"0\" b_r=\"0\" b_b=\"0\" fps=\"8.000000\" bT=\"0\" hasA=\"0\">"
        "<clip s_f=\"0\" e_f=\"-1\" layer=\"0\" r_f=\"animation/sprite/teamleader\" fps=\"12.048193\" rel_x=\"41\" rel_y=\"9\" v_c=\"4294967295\" p_m=\"0\">"
        "<TOOLS_DATA><pos_keys/><scale_keys/><rotation_keys/><alpha_keys/><color_keys/><divide_keys/></TOOLS_DATA>"
        "</clip></data>");

    const unsigned int unresolvedPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedOriginalPath.data(),
                    (unsigned int)unresolvedOriginalPath.size());
    const unsigned int effectXmlDataCrc =
        SLJFP_crc32(0, effectXmlData.data(), (unsigned int)effectXmlData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedPathCrc),
                                       effectXmlData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)effectXmlData.size());
    AppendUInt32Le(indexData, effectXmlDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string canonicalPath =
        "effect/geffect/sprite/" + std::to_string(unresolvedPathCrc) + ".eff.inf";
    std::vector<unsigned char> restoredEffectXml;
    std::vector<unsigned char> leftoverRootXml;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + canonicalPath, restoredEffectXml));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(unresolvedPathCrc) + ".xml",
                                   leftoverRootXml));
    TEST_ASSERT_EQ(effectXmlData.size(), restoredEffectXml.size());
    TEST_ASSERT_MEM_EQ(effectXmlData.data(), restoredEffectXml.data(), effectXmlData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreCanonicalModelSpineAtlasDirectoryAndPageImage) {
    const std::string baseDir = "test_output/unpacker_canonical_model_spine_atlas_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string unresolvedAtlasOriginalPath = "misc/spine/leftover_createrole_atlas";
    const std::string modelStem = "spine_createrole_nvde";
    const std::string pageFileName = modelStem + ".png";
    const std::string exactImagePath = "model/" + modelStem + "/" + pageFileName;

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> atlasData = BuildMinimalSpineAtlas(pageFileName);
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int unresolvedAtlasPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAtlasOriginalPath.data(),
                    (unsigned int)unresolvedAtlasOriginalPath.size());
    const unsigned int exactImagePathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)exactImagePath.data(),
                    (unsigned int)exactImagePath.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAtlasPathCrc),
                                       atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(exactImagePathCrc),
                                       pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAtlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData.size());
    AppendUInt32Le(indexData, pngDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, exactImagePathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string canonicalAtlasPath =
        "model/" + modelStem + "/" + std::to_string(unresolvedAtlasPathCrc) + ".atlas";
    std::vector<unsigned char> restoredAtlas;
    std::vector<unsigned char> restoredPng;
    std::vector<unsigned char> leftoverRootAtlas;
    std::vector<unsigned char> leftoverRootPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + canonicalAtlasPath, restoredAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + exactImagePath, restoredPng));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(unresolvedAtlasPathCrc) + ".atlas",
                                   leftoverRootAtlas));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(exactImagePathCrc) + ".png",
                                   leftoverRootPng));
    TEST_ASSERT_EQ(atlasData.size(), restoredAtlas.size());
    TEST_ASSERT_EQ(pngData.size(), restoredPng.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredPng.data(), pngData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreCanonicalModelSpineJsonDirectoryFromEmbeddedStem) {
    const std::string baseDir = "test_output/unpacker_canonical_model_spine_json_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string unresolvedJsonOriginalPath = "misc/spine/leftover_createrole_json";
    const std::string modelStem = "spine_createrole_shengqishi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> jsonData = BuildUtf8Text(
        "{\n"
        "\"skeleton\": { \"hash\": \"demo\", \"spine\": \"3.0.08\" },\n"
        "\"atlas_path\": \"model/spine_createrole_shengqishi/spine_createrole_shengqishi.json\",\n"
        "\"resource\": \"spine/spine_createrole_shengqishi.atlas\"\n"
        "}\n");

    const unsigned int unresolvedJsonPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedJsonOriginalPath.data(),
                    (unsigned int)unresolvedJsonOriginalPath.size());
    const unsigned int jsonDataCrc =
        SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedJsonPathCrc),
                                       jsonData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)jsonData.size());
    AppendUInt32Le(indexData, jsonDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedJsonPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string canonicalJsonPath =
        "model/" + modelStem + "/" + std::to_string(unresolvedJsonPathCrc) + ".json";
    std::vector<unsigned char> restoredJson;
    std::vector<unsigned char> leftoverRootJson;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + canonicalJsonPath, restoredJson));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(unresolvedJsonPathCrc) + ".json",
                                   leftoverRootJson));
    TEST_ASSERT_EQ(jsonData.size(), restoredJson.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredJson.data(), jsonData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreCanonicalModelSpineJsonDirectoryFromAtlasSignature) {
    const std::string baseDir =
        "test_output/unpacker_canonical_model_spine_json_atlas_signature_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string atlasPath = "model/spine_createrole_lieren/257373299.atlas";
    const std::string jsonPath =
        "model/spine_createrole_lieren/spine_createrole_lieren.json";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    std::vector<std::string> regionNames;
    regionNames.push_back("guihuo2/kuluhuo_00001");
    regionNames.push_back("guihuo2/kuluhuo_00002");
    regionNames.push_back("guihuo2/kuluhuo_00003");
    regionNames.push_back("piaodai_l2");

    const std::vector<unsigned char> atlasData =
        BuildSpineAtlasWithRegions("spine_createrole_lieren.png", regionNames);
    const std::vector<unsigned char> jsonData =
        BuildSpineJsonWithAttachments(regionNames);

    const unsigned int atlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)atlasPath.data(), (unsigned int)atlasPath.size());
    const unsigned int jsonPathCrc =
        SLJFP_crc32(0, (const unsigned char*)jsonPath.data(), (unsigned int)jsonPath.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int jsonDataCrc =
        SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc), atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(jsonPathCrc), jsonData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, atlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)jsonData.size());
    AppendUInt32Le(indexData, jsonDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, jsonPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << atlasPathCrc << "|" << atlasPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAtlas;
    std::vector<unsigned char> restoredJson;
    std::vector<unsigned char> leftoverRootJson;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + atlasPath, restoredAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + jsonPath, restoredJson));
    TEST_ASSERT_EQ(atlasData.size(), restoredAtlas.size());
    TEST_ASSERT_EQ(jsonData.size(), restoredJson.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredJson.data(), jsonData.size());
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(jsonPathCrc) + ".json",
                                   leftoverRootJson));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, PreferAtlasSignatureDirectoryWhenSpineJsonStemTokenIsDecorated) {
    const std::string baseDir =
        "test_output/unpacker_canonical_model_spine_json_decorated_stem_prefer_atlas";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string atlasPath =
        "model/spine_createrole_shengqishi/4243822742.atlas";
    const std::string jsonPath =
        "model/spine_createrole_shengqishi/spine_createrole_shengqishi.json";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    std::vector<std::string> regionNames;
    regionNames.push_back("fuwenquan/comp 1_00000");
    regionNames.push_back("bianzi1");
    regionNames.push_back("dipan");
    regionNames.push_back("erhuan1");

    const std::vector<unsigned char> atlasData =
        BuildSpineAtlasWithRegions("spine_createrole_shengqishi.png", regionNames);
    const std::vector<unsigned char> jsonData =
        BuildSpineJsonWithAttachmentsAndLooseStemToken(
            regionNames,
            "liuguang/spine_createrole_shengqishi-stand1_00000");

    const unsigned int atlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)atlasPath.data(), (unsigned int)atlasPath.size());
    const unsigned int jsonPathCrc =
        SLJFP_crc32(0, (const unsigned char*)jsonPath.data(), (unsigned int)jsonPath.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int jsonDataCrc =
        SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc), atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(jsonPathCrc), jsonData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, atlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)jsonData.size());
    AppendUInt32Le(indexData, jsonDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, jsonPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << atlasPathCrc << "|" << atlasPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredJson;
    std::vector<unsigned char> leftoverRootJson;
    std::vector<unsigned char> wrongStemJson;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + jsonPath, restoredJson));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(jsonPathCrc) + ".json",
                                   leftoverRootJson));
    TEST_ASSERT_FALSE(
        ReadTestFile(outputDir + "/model/spine_createrole_shengqishi-stand1_00000/" +
                         std::to_string(jsonPathCrc) + ".json",
                     wrongStemJson));
    TEST_ASSERT_EQ(jsonData.size(), restoredJson.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredJson.data(), jsonData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RetryCanonicalModelSpineJsonDirectoryAfterAtlasMovedLater) {
    const std::string baseDir =
        "test_output/unpacker_canonical_model_spine_json_retry_after_late_atlas";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string atlasPath =
        "model/spine_createrole_nvde/3691300004.atlas";
    const std::string jsonPath =
        "model/spine_createrole_nvde/spine_createrole_nvde.json";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    std::vector<std::string> regionNames;
    regionNames.push_back("bianzi");
    regionNames.push_back("cao1");
    regionNames.push_back("dizuo");
    regionNames.push_back("nvde_mozhang_1");
    regionNames.push_back("nvde_guang_1");

    const std::vector<unsigned char> atlasData =
        BuildSpineAtlasWithRegions("spine_createrole_nvde.png", regionNames);
    const std::vector<unsigned char> jsonData =
        BuildSpineJsonWithAttachments(regionNames);

    const unsigned int atlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)atlasPath.data(), (unsigned int)atlasPath.size());
    const unsigned int jsonPathCrc =
        SLJFP_crc32(0, (const unsigned char*)jsonPath.data(), (unsigned int)jsonPath.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int jsonDataCrc =
        SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc), atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(jsonPathCrc), jsonData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    // 故意让 JSON 排在 atlas 前面，验证 atlas 落位后会进行二次重试
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)jsonData.size());
    AppendUInt32Le(indexData, jsonDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, jsonPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, atlasPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << atlasPathCrc << "|" << atlasPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAtlas;
    std::vector<unsigned char> restoredJson;
    std::vector<unsigned char> leftoverRootJson;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + atlasPath, restoredAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + jsonPath, restoredJson));
    TEST_ASSERT_EQ(atlasData.size(), restoredAtlas.size());
    TEST_ASSERT_EQ(jsonData.size(), restoredJson.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredJson.data(), jsonData.size());
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(jsonPathCrc) + ".json",
                                   leftoverRootJson));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, WriteReviewAliasesForCanonicalModelNumericLeaves) {
    const std::string baseDir =
        "test_output/unpacker_canonical_model_review_aliases";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string unresolvedAtlasOriginalPath = "misc/spine/review_alias_atlas";
    const std::string unresolvedJsonOriginalPath = "misc/spine/review_alias_json";
    const std::string modelStem = "spine_createrole_mushi";
    const std::string pageFileName = modelStem + ".png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> atlasData =
        BuildMinimalSpineAtlas(pageFileName);
    const std::vector<unsigned char> jsonData = BuildUtf8Text(
        "{\n"
        "\"skeleton\": { \"hash\": \"demo\", \"spine\": \"3.0.08\" },\n"
        "\"atlas_path\": \"model/spine_createrole_mushi/spine_createrole_mushi.json\",\n"
        "\"resource\": \"spine/spine_createrole_mushi.atlas\"\n"
        "}\n");

    const unsigned int unresolvedAtlasPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAtlasOriginalPath.data(),
                    (unsigned int)unresolvedAtlasOriginalPath.size());
    const unsigned int unresolvedJsonPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedJsonOriginalPath.data(),
                    (unsigned int)unresolvedJsonOriginalPath.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int jsonDataCrc =
        SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAtlasPathCrc),
                                       atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedJsonPathCrc),
                                       jsonData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAtlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)jsonData.size());
    AppendUInt32Le(indexData, jsonDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedJsonPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string numericAtlasPath =
        "model/" + modelStem + "/" + std::to_string(unresolvedAtlasPathCrc) + ".atlas";
    const std::string numericJsonPath =
        "model/" + modelStem + "/" + std::to_string(unresolvedJsonPathCrc) + ".json";
    const std::string aliasAtlasPath =
        "model/" + modelStem + "/" + modelStem + ".atlas";
    const std::string aliasJsonPath =
        "model/" + modelStem + "/" + modelStem + ".json";

    std::vector<unsigned char> restoredNumericAtlas;
    std::vector<unsigned char> restoredNumericJson;
    std::vector<unsigned char> restoredAliasAtlas;
    std::vector<unsigned char> restoredAliasJson;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + numericAtlasPath, restoredNumericAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + numericJsonPath, restoredNumericJson));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasAtlasPath, restoredAliasAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasJsonPath, restoredAliasJson));
    TEST_ASSERT_EQ(atlasData.size(), restoredNumericAtlas.size());
    TEST_ASSERT_EQ(jsonData.size(), restoredNumericJson.size());
    TEST_ASSERT_EQ(atlasData.size(), restoredAliasAtlas.size());
    TEST_ASSERT_EQ(jsonData.size(), restoredAliasJson.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredNumericAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredNumericJson.data(), jsonData.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAliasAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredAliasJson.data(), jsonData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, WriteReviewAliasModelPageForUniqueRootPngCandidate) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_page";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string unresolvedAtlasOriginalPath = "misc/spine/review_alias_page_atlas";
    const std::string unresolvedPngOriginalPath = "misc/spine/review_alias_page_png";
    const std::string modelStem = "spine_createrole_demo";
    const std::string pageFileName = modelStem + ".png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> atlasData = BuildUtf8Text(
        "\n"
        "spine_createrole_demo.png\n"
        "size: 1,1\n"
        "format: RGBA8888\n"
        "filter: Linear,Linear\n"
        "repeat: none\n"
        "demo_region\n"
        "  rotate: false\n"
        "  xy: 0, 0\n"
        "  size: 1, 1\n"
        "  orig: 1, 1\n"
        "  offset: 0, 0\n"
        "  index: -1\n");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int unresolvedAtlasPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAtlasOriginalPath.data(),
                    (unsigned int)unresolvedAtlasOriginalPath.size());
    const unsigned int unresolvedPngPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedPngOriginalPath.data(),
                    (unsigned int)unresolvedPngOriginalPath.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAtlasPathCrc),
                                       atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedPngPathCrc),
                                       pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAtlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData.size());
    AppendUInt32Le(indexData, pngDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedPngPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string numericAtlasPath =
        "model/" + modelStem + "/" + std::to_string(unresolvedAtlasPathCrc) + ".atlas";
    const std::string aliasAtlasPath =
        "model/" + modelStem + "/" + modelStem + ".atlas";
    const std::string aliasPagePath =
        "model/" + modelStem + "/" + pageFileName;
    const std::string rootNumericPngPath =
        std::to_string(unresolvedPngPathCrc) + ".png";
    const std::string reviewReportPath = "review_alias_model_pages.txt";

    std::vector<unsigned char> restoredAliasPage;
    std::vector<unsigned char> restoredRootNumericPng;
    std::vector<unsigned char> restoredAliasAtlas;
    std::vector<unsigned char> restoredNumericAtlas;
    std::vector<unsigned char> reportData;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + numericAtlasPath, restoredNumericAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasAtlasPath, restoredAliasAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasPagePath, restoredAliasPage));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + rootNumericPngPath, restoredRootNumericPng));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewReportPath, reportData));
    TEST_ASSERT_EQ(atlasData.size(), restoredNumericAtlas.size());
    TEST_ASSERT_EQ(atlasData.size(), restoredAliasAtlas.size());
    TEST_ASSERT_EQ(pngData.size(), restoredAliasPage.size());
    TEST_ASSERT_EQ(pngData.size(), restoredRootNumericPng.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredNumericAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAliasAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredAliasPage.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredRootNumericPng.data(), pngData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, WriteReviewAliasModelPageCandidatesForAmbiguousRootPngs) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_page_ambiguous";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string unresolvedAtlasOriginalPath = "misc/spine/review_alias_page_atlas_ambiguous";
    const std::string unresolvedPngOriginalPath1 = "misc/spine/review_alias_page_png_1";
    const std::string unresolvedPngOriginalPath2 = "misc/spine/review_alias_page_png_2";
    const std::string modelStem = "spine_createrole_demo2";
    const std::string pageFileName = modelStem + ".png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> atlasData = BuildUtf8Text(
        "\n"
        "spine_createrole_demo2.png\n"
        "size: 1,1\n"
        "format: RGBA8888\n"
        "filter: Linear,Linear\n"
        "repeat: none\n"
        "demo_region\n"
        "  rotate: false\n"
        "  xy: 0, 0\n"
        "  size: 1, 1\n"
        "  orig: 1, 1\n"
        "  offset: 0, 0\n"
        "  index: -1\n");
    const std::vector<unsigned char> pngData1 = BuildTinyPng();
    const std::vector<unsigned char> pngData2 = BuildTinyPng();

    const unsigned int unresolvedAtlasPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAtlasOriginalPath.data(),
                    (unsigned int)unresolvedAtlasOriginalPath.size());
    const unsigned int unresolvedPngPathCrc1 =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedPngOriginalPath1.data(),
                    (unsigned int)unresolvedPngOriginalPath1.size());
    const unsigned int unresolvedPngPathCrc2 =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedPngOriginalPath2.data(),
                    (unsigned int)unresolvedPngOriginalPath2.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int pngDataCrc1 =
        SLJFP_crc32(0, pngData1.data(), (unsigned int)pngData1.size());
    const unsigned int pngDataCrc2 =
        SLJFP_crc32(0, pngData2.data(), (unsigned int)pngData2.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAtlasPathCrc),
                                       atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedPngPathCrc1),
                                       pngData1));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedPngPathCrc2),
                                       pngData2));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAtlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData1.size());
    AppendUInt32Le(indexData, pngDataCrc1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedPngPathCrc1);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData2.size());
    AppendUInt32Le(indexData, pngDataCrc2);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedPngPathCrc2);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string numericAtlasPath =
        "model/" + modelStem + "/" + std::to_string(unresolvedAtlasPathCrc) + ".atlas";
    const std::string aliasAtlasPath =
        "model/" + modelStem + "/" + modelStem + ".atlas";
    const std::string aliasPagePath =
        "model/" + modelStem + "/" + pageFileName;
    const std::string rootNumericPngPath1 =
        std::to_string(unresolvedPngPathCrc1) + ".png";
    const std::string rootNumericPngPath2 =
        std::to_string(unresolvedPngPathCrc2) + ".png";
    const std::string reviewCandidatePath1 =
        "model/" + modelStem + "/_review/" + modelStem + ".candidate." +
        std::to_string(unresolvedPngPathCrc1) + ".png";
    const std::string reviewCandidatePath2 =
        "model/" + modelStem + "/_review/" + modelStem + ".candidate." +
        std::to_string(unresolvedPngPathCrc2) + ".png";
    const std::string reviewReportPath = "review_alias_model_pages.txt";

    std::vector<unsigned char> restoredRootNumericPng1;
    std::vector<unsigned char> restoredRootNumericPng2;
    std::vector<unsigned char> restoredReviewCandidate1;
    std::vector<unsigned char> restoredReviewCandidate2;
    std::vector<unsigned char> restoredAliasAtlas;
    std::vector<unsigned char> restoredNumericAtlas;
    std::vector<unsigned char> reportData;
    std::vector<unsigned char> unexpectedAliasPage;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + numericAtlasPath, restoredNumericAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasAtlasPath, restoredAliasAtlas));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + aliasPagePath, unexpectedAliasPage));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + rootNumericPngPath1, restoredRootNumericPng1));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + rootNumericPngPath2, restoredRootNumericPng2));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewCandidatePath1, restoredReviewCandidate1));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewCandidatePath2, restoredReviewCandidate2));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewReportPath, reportData));
    TEST_ASSERT_EQ(atlasData.size(), restoredNumericAtlas.size());
    TEST_ASSERT_EQ(atlasData.size(), restoredAliasAtlas.size());
    TEST_ASSERT_EQ(pngData1.size(), restoredRootNumericPng1.size());
    TEST_ASSERT_EQ(pngData2.size(), restoredRootNumericPng2.size());
    TEST_ASSERT_EQ(pngData1.size(), restoredReviewCandidate1.size());
    TEST_ASSERT_EQ(pngData2.size(), restoredReviewCandidate2.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredNumericAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAliasAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(pngData1.data(), restoredRootNumericPng1.data(), pngData1.size());
    TEST_ASSERT_MEM_EQ(pngData2.data(), restoredRootNumericPng2.data(), pngData2.size());
    TEST_ASSERT_MEM_EQ(pngData1.data(), restoredReviewCandidate1.data(), pngData1.size());
    TEST_ASSERT_MEM_EQ(pngData2.data(), restoredReviewCandidate2.data(), pngData2.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, SkipReviewAliasModelPageCandidatesWhenAliasPageAlreadyExists) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_page_existing_target";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string unresolvedAtlasOriginalPath = "misc/spine/review_alias_page_existing_atlas";
    const std::string unresolvedPngOriginalPath1 = "misc/spine/review_alias_page_existing_png_1";
    const std::string unresolvedPngOriginalPath2 = "misc/spine/review_alias_page_existing_png_2";
    const std::string modelStem = "spine_createrole_existing";
    const std::string pageFileName = modelStem + ".png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir + "/model"));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir + "/model/" + modelStem));

    const std::vector<unsigned char> atlasData = BuildUtf8Text(
        "\n"
        "spine_createrole_existing.png\n"
        "size: 1,1\n"
        "format: RGBA8888\n"
        "filter: Linear,Linear\n"
        "repeat: none\n"
        "demo_region\n"
        "  rotate: false\n"
        "  xy: 0, 0\n"
        "  size: 1, 1\n"
        "  orig: 1, 1\n"
        "  offset: 0, 0\n"
        "  index: -1\n");
    const std::vector<unsigned char> pngData1 = BuildTinyPng();
    const std::vector<unsigned char> pngData2 = BuildTinyPng();
    const std::vector<unsigned char> existingAliasPageData = BuildTinyPng();

    const unsigned int unresolvedAtlasPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAtlasOriginalPath.data(),
                    (unsigned int)unresolvedAtlasOriginalPath.size());
    const unsigned int unresolvedPngPathCrc1 =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedPngOriginalPath1.data(),
                    (unsigned int)unresolvedPngOriginalPath1.size());
    const unsigned int unresolvedPngPathCrc2 =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedPngOriginalPath2.data(),
                    (unsigned int)unresolvedPngOriginalPath2.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int pngDataCrc1 =
        SLJFP_crc32(0, pngData1.data(), (unsigned int)pngData1.size());
    const unsigned int pngDataCrc2 =
        SLJFP_crc32(0, pngData2.data(), (unsigned int)pngData2.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAtlasPathCrc),
                                       atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedPngPathCrc1),
                                       pngData1));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedPngPathCrc2),
                                       pngData2));
    TEST_ASSERT_TRUE(WriteBinaryVector(outputDir + "/model/" + modelStem + "/" + pageFileName,
                                       existingAliasPageData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAtlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData1.size());
    AppendUInt32Le(indexData, pngDataCrc1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedPngPathCrc1);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData2.size());
    AppendUInt32Le(indexData, pngDataCrc2);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedPngPathCrc2);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string reviewCandidatePath1 =
        "model/" + modelStem + "/_review/" + modelStem + ".candidate." +
        std::to_string(unresolvedPngPathCrc1) + ".png";
    const std::string reviewCandidatePath2 =
        "model/" + modelStem + "/_review/" + modelStem + ".candidate." +
        std::to_string(unresolvedPngPathCrc2) + ".png";
    std::vector<unsigned char> aliasPageData;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/model/" + modelStem + "/" + pageFileName,
                                  aliasPageData));
    TEST_ASSERT_EQ(existingAliasPageData.size(), aliasPageData.size());
    TEST_ASSERT_MEM_EQ(existingAliasPageData.data(),
                       aliasPageData.data(),
                       existingAliasPageData.size());
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + reviewCandidatePath1, aliasPageData));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + reviewCandidatePath2, aliasPageData));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, ReviewAliasModelPageAmbiguousCandidatesFilterByAtlasPageDimensions) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_page_dimension_filter";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string unresolvedAtlasOriginalPath = "misc/spine/review_alias_page_dimension_atlas";
    const std::string unresolvedPngOriginalPath1 = "misc/spine/review_alias_page_dimension_png_1";
    const std::string unresolvedPngOriginalPath2 = "misc/spine/review_alias_page_dimension_png_2";
    const std::string modelStem = "spine_createrole_dimension";
    const std::string pageFileName = modelStem + ".png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> atlasData = BuildUtf8Text(
        "\n"
        "spine_createrole_dimension.png\n"
        "size: 2,1\n"
        "format: RGBA8888\n"
        "filter: Linear,Linear\n"
        "repeat: none\n"
        "demo_region\n"
        "  rotate: false\n"
        "  xy: 0, 0\n"
        "  size: 2, 1\n"
        "  orig: 2, 1\n"
        "  offset: 0, 0\n"
        "  index: -1\n");
    const std::vector<unsigned char> pngDataMatching = BuildPngWithSize(2, 1);
    const std::vector<unsigned char> pngDataMismatched = BuildTinyPng();

    const unsigned int unresolvedAtlasPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAtlasOriginalPath.data(),
                    (unsigned int)unresolvedAtlasOriginalPath.size());
    const unsigned int unresolvedPngPathCrc1 =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedPngOriginalPath1.data(),
                    (unsigned int)unresolvedPngOriginalPath1.size());
    const unsigned int unresolvedPngPathCrc2 =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedPngOriginalPath2.data(),
                    (unsigned int)unresolvedPngOriginalPath2.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int pngDataCrc1 =
        SLJFP_crc32(0, pngDataMatching.data(), (unsigned int)pngDataMatching.size());
    const unsigned int pngDataCrc2 =
        SLJFP_crc32(0, pngDataMismatched.data(), (unsigned int)pngDataMismatched.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAtlasPathCrc),
                                       atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedPngPathCrc1),
                                       pngDataMatching));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedPngPathCrc2),
                                       pngDataMismatched));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAtlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngDataMatching.size());
    AppendUInt32Le(indexData, pngDataCrc1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedPngPathCrc1);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngDataMismatched.size());
    AppendUInt32Le(indexData, pngDataCrc2);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedPngPathCrc2);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string aliasPagePath =
        "model/" + modelStem + "/" + pageFileName;
    const std::string reviewCandidatePath1 =
        "model/" + modelStem + "/_review/" + modelStem + ".candidate." +
        std::to_string(unresolvedPngPathCrc1) + ".png";
    const std::string reviewCandidatePath2 =
        "model/" + modelStem + "/_review/" + modelStem + ".candidate." +
        std::to_string(unresolvedPngPathCrc2) + ".png";
    const std::string rootNumericPngPath1 =
        std::to_string(unresolvedPngPathCrc1) + ".png";
    const std::string rootNumericPngPath2 =
        std::to_string(unresolvedPngPathCrc2) + ".png";

    std::vector<unsigned char> restoredAliasPage;
    std::vector<unsigned char> restoredRootNumericPng1;
    std::vector<unsigned char> restoredRootNumericPng2;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aliasPagePath, restoredAliasPage));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + rootNumericPngPath1, restoredRootNumericPng1));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + rootNumericPngPath2, restoredRootNumericPng2));
    TEST_ASSERT_EQ(pngDataMatching.size(), restoredAliasPage.size());
    TEST_ASSERT_MEM_EQ(pngDataMatching.data(), restoredAliasPage.data(), pngDataMatching.size());
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + reviewCandidatePath1, restoredAliasPage));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + reviewCandidatePath2, restoredAliasPage));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, WriteReviewAliasModelAniForUniqueTailSignature) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_unique_tail";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedAniPath = "model/demo/body/bodyonly/attack1.ani";
    const std::string unresolvedAniOriginalPath = "misc/review_alias_body_attack1";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res003.png");
    const unsigned int namedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath.data(), (unsigned int)namedAniPath.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedAniPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAniPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedAniPathCrc << "|" << namedAniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string reviewAliasPath =
        "review/model_ani/body/bodyonly/attack1.candidate." +
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string reviewReportPath = "review_alias_model_ani.txt";

    std::vector<unsigned char> restoredNamedAni;
    std::vector<unsigned char> restoredReviewAlias;
    std::vector<unsigned char> reportData;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedAniPath, restoredNamedAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewAliasPath, restoredReviewAlias));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewReportPath, reportData));
    TEST_ASSERT_EQ(aniData.size(), restoredNamedAni.size());
    TEST_ASSERT_EQ(aniData.size(), restoredReviewAlias.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredNamedAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredReviewAlias.data(), aniData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, WriteReviewAliasModelAniLeafWhenTailIsAmbiguous) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_leaf";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedAniPath1 = "model/demo1/body/bodyonly/attack1.ani";
    const std::string namedAniPath2 = "model/demo2/weapon/207/attack1.ani";
    const std::string unresolvedAniOriginalPath = "misc/review_alias_leaf_attack1";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res003.png");
    const unsigned int namedAniPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath1.data(), (unsigned int)namedAniPath1.size());
    const unsigned int namedAniPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath2.data(), (unsigned int)namedAniPath2.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc1), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc2), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedAniPathCrc1);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedAniPathCrc2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAniPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedAniPathCrc1 << "|" << namedAniPath1 << "\n";
        mappingFile << namedAniPathCrc2 << "|" << namedAniPath2 << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string reviewLeafAliasPath =
        "review/model_ani_leaf/attack1.candidate." +
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string reviewTailAliasPath =
        "review/model_ani/body/bodyonly/attack1.candidate." +
        std::to_string(unresolvedAniPathCrc) + ".ani";
    std::vector<unsigned char> restoredLeafAlias;
    std::vector<unsigned char> unexpectedTailAlias;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewLeafAliasPath, restoredLeafAlias));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + reviewTailAliasPath, unexpectedTailAlias));
    TEST_ASSERT_EQ(aniData.size(), restoredLeafAlias.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredLeafAlias.data(), aniData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreExactModelAniPathFromSpritesRegistryBeforeReviewAlias) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_exact_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string registryPath = "model/sprites.set";
    const std::string namedAniPath1 = "model/demo1/body/bodyonly/attack1.ani";
    const std::string namedAniPath2 = "model/demo2/body/bodyonly/attack1.ani";
    const std::string unresolvedAniOriginalPath = "model/demo3/body/bodyonly/attack1.ani";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> registryData =
        BuildUtf16LeText(
            "<data>"
            "<model name=\"demo1\" des=\"demo1\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" "
            "efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" "
            "scale=\"1.000000\"/>"
            "<model name=\"demo2\" des=\"demo2\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" "
            "efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" "
            "scale=\"1.000000\"/>"
            "<model name=\"demo3\" des=\"demo3\" type=\"0\" titlepos=\"0\" efctPosX=\"0\" "
            "efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" "
            "scale=\"1.000000\"/>"
            "</data>");
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res003.png");

    const unsigned int registryPathCrc =
        SLJFP_crc32(0, (const unsigned char*)registryPath.data(), (unsigned int)registryPath.size());
    const unsigned int namedAniPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath1.data(), (unsigned int)namedAniPath1.size());
    const unsigned int namedAniPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath2.data(), (unsigned int)namedAniPath2.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int registryDataCrc =
        SLJFP_crc32(0, registryData.data(), (unsigned int)registryData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());

    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(registryPathCrc), registryData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc1), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc2), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)registryData.size());
    AppendUInt32Le(indexData, registryDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, registryPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedAniPathCrc1);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedAniPathCrc2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAniPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << registryPathCrc << "|" << registryPath << "\n";
        mappingFile << namedAniPathCrc1 << "|" << namedAniPath1 << "\n";
        mappingFile << namedAniPathCrc2 << "|" << namedAniPath2 << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string restoredAniPath = unresolvedAniOriginalPath;
    const std::string unresolvedRootAniPath =
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string unexpectedReviewAliasPath =
        "review/model_ani/body/bodyonly/attack1.candidate." +
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string reviewReportPath = "review_alias_model_ani.txt";

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> unexpectedRootAni;
    std::vector<unsigned char> unexpectedReviewAlias;
    std::vector<unsigned char> reportData;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + restoredAniPath, restoredAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + unresolvedRootAniPath, unexpectedRootAni));
    TEST_ASSERT_FALSE(
        ReadTestFile(outputDir + "/" + unexpectedReviewAliasPath, unexpectedReviewAlias));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewReportPath, reportData));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    {
        const std::string reportText(reinterpret_cast<const char*>(reportData.data()),
                                     reportData.size());
        const bool hasExactRestore = reportText.find("exact_restore") != std::string::npos;
        const bool hasSourceEntry =
            reportText.find(std::to_string(unresolvedAniPathCrc) + ".ani") != std::string::npos;
        // 允许两种正确路径：
        // 1) 在 review-alias 阶段命中 exact_restore；
        // 2) 在前置映射阶段已恢复，因此 report 中不再出现该 root CRC 源。
        TEST_ASSERT_TRUE(hasExactRestore || !hasSourceEntry);
    }

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreExactModelAniPathFromNpcShapeTableBeforeReviewAlias) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_exact_restore_npcshape";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string tablePath = "table/bintable/npc.cnpcshape.bin";
    const std::string namedAniPath = "model/demo1/body/bodyonly/attack1.ani";
    const std::string unresolvedAniOriginalPath = "model/mushi/body/bodyonly/attack1.ani";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> tableData = BuildNpcShapeTableBinary(
        std::vector<TestNpcShapeRow>(1,
                                     MakeTestNpcShapeRow("mushi",
                                                         "attack1",
                                                         "magic1",
                                                         "attacked",
                                                         "death")));
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res003.png");

    const unsigned int tablePathCrc =
        SLJFP_crc32(0, (const unsigned char*)tablePath.data(), (unsigned int)tablePath.size());
    const unsigned int namedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath.data(), (unsigned int)namedAniPath.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int tableDataCrc =
        SLJFP_crc32(0, tableData.data(), (unsigned int)tableData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());

    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(tablePathCrc), tableData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)tableData.size());
    AppendUInt32Le(indexData, tableDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, tablePathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedAniPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAniPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << tablePathCrc << "|" << tablePath << "\n";
        mappingFile << namedAniPathCrc << "|" << namedAniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string unresolvedRootAniPath =
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string unexpectedReviewAliasPath =
        "review/model_ani/body/bodyonly/attack1.candidate." +
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string reviewReportPath = "review_alias_model_ani.txt";

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> unexpectedRootAni;
    std::vector<unsigned char> unexpectedReviewAlias;
    std::vector<unsigned char> reportData;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + unresolvedAniOriginalPath, restoredAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + unresolvedRootAniPath, unexpectedRootAni));
    TEST_ASSERT_FALSE(
        ReadTestFile(outputDir + "/" + unexpectedReviewAliasPath, unexpectedReviewAlias));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewReportPath, reportData));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    const std::string reportText1(reinterpret_cast<const char*>(reportData.data()),
                                  reportData.size());
    const bool hasExactRestore1 =
        reportText1.find("exact_restore") != std::string::npos;
    const bool hasSourceEntry1 =
        reportText1.find(unresolvedRootAniPath + "|") != std::string::npos;
    TEST_ASSERT_TRUE(hasExactRestore1 || !hasSourceEntry1);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreExactModelAniPathFromNpcActionInfoTableBeforeReviewAlias) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_exact_restore_cactioninfo";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string tablePath = "table/bintable/npc.cactioninfo.bin";
    const std::string namedAniPath = "model/demo1/body/bodyonly/attack1.ani";
    const std::string unresolvedAniOriginalPath = "model/mushi/body/bodyonly/attack1.ani";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> tableData = BuildNpcActionInfoTableBinary(
        std::vector<TestNpcActionInfoRow>(1, MakeTestNpcActionInfoRow("mushi", "attack1")));
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res003.png");

    const unsigned int tablePathCrc =
        SLJFP_crc32(0, (const unsigned char*)tablePath.data(), (unsigned int)tablePath.size());
    const unsigned int namedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath.data(), (unsigned int)namedAniPath.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int tableDataCrc =
        SLJFP_crc32(0, tableData.data(), (unsigned int)tableData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());

    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(tablePathCrc), tableData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)tableData.size());
    AppendUInt32Le(indexData, tableDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, tablePathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, namedAniPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedAniPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << tablePathCrc << "|" << tablePath << "\n";
        mappingFile << namedAniPathCrc << "|" << namedAniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string unresolvedRootAniPath =
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string unexpectedReviewAliasPath =
        "review/model_ani/body/bodyonly/attack1.candidate." +
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string reviewReportPath = "review_alias_model_ani.txt";

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> unexpectedRootAni;
    std::vector<unsigned char> unexpectedReviewAlias;
    std::vector<unsigned char> reportData;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + unresolvedAniOriginalPath, restoredAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + unresolvedRootAniPath, unexpectedRootAni));
    TEST_ASSERT_FALSE(
        ReadTestFile(outputDir + "/" + unexpectedReviewAliasPath, unexpectedReviewAlias));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewReportPath, reportData));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    const std::string reportText2(reinterpret_cast<const char*>(reportData.data()),
                                  reportData.size());
    const bool hasExactRestore2 =
        reportText2.find("exact_restore") != std::string::npos;
    const bool hasSourceEntry2 =
        reportText2.find(unresolvedRootAniPath + "|") != std::string::npos;
    TEST_ASSERT_TRUE(hasExactRestore2 || !hasSourceEntry2);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreExactModelAniPathFromNpcRideTableWithoutNamedSignatureTail) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_exact_restore_cride";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string actionInfoTablePath = "table/bintable/npc.cactioninfo.bin";
    const std::string rideTablePath = "table/bintable/npc.cride.bin";
    const std::string unresolvedAniOriginalPath = "model/mt_zuoqi/ride1/501/riding_run.ani";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> actionInfoTableData = BuildNpcActionInfoTableBinary(
        std::vector<TestNpcActionInfoRow>(1, MakeTestNpcActionInfoRow("mushi", "attack1")));
    const std::vector<unsigned char> rideTableData = BuildNpcRideTableBinary(
        std::vector<TestNpcRideRow>(1, MakeTestNpcRideRow(501)),
        524335u);
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res003.png");

    const unsigned int actionInfoTablePathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)actionInfoTablePath.data(),
                    (unsigned int)actionInfoTablePath.size());
    const unsigned int rideTablePathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)rideTablePath.data(),
                    (unsigned int)rideTablePath.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int actionInfoTableDataCrc =
        SLJFP_crc32(0, actionInfoTableData.data(), (unsigned int)actionInfoTableData.size());
    const unsigned int rideTableDataCrc =
        SLJFP_crc32(0, rideTableData.data(), (unsigned int)rideTableData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());

    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(actionInfoTablePathCrc),
                          actionInfoTableData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(rideTablePathCrc), rideTableData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    const unsigned int sizes[] = {
        (unsigned int)actionInfoTableData.size(),
        (unsigned int)rideTableData.size(),
        (unsigned int)aniData.size()
    };
    const unsigned int dataCrcs[] = {
        actionInfoTableDataCrc,
        rideTableDataCrc,
        aniDataCrc
    };
    const unsigned int pathCrcs[] = {
        actionInfoTablePathCrc,
        rideTablePathCrc,
        unresolvedAniPathCrc
    };

    for (int i = 0; i < 3; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << actionInfoTablePathCrc << "|" << actionInfoTablePath << "\n";
        mappingFile << rideTablePathCrc << "|" << rideTablePath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string unresolvedRootAniPath =
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string reviewReportPath = "review_alias_model_ani.txt";

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> unexpectedRootAni;
    std::vector<unsigned char> reportData;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + unresolvedAniOriginalPath, restoredAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + unresolvedRootAniPath, unexpectedRootAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewReportPath, reportData));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    const std::string reportText3(reinterpret_cast<const char*>(reportData.data()),
                                  reportData.size());
    const bool hasExactStructuredRestore =
        reportText3.find("exact_restore_structured") != std::string::npos;
    const bool hasSourceEntry3 =
        reportText3.find(unresolvedRootAniPath + "|") != std::string::npos;
    TEST_ASSERT_TRUE(hasExactStructuredRestore || !hasSourceEntry3);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreModelTextureAfterNpcShapeExactAniRestore) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_texture_after_exact_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string tablePath = "table/bintable/npc.cnpcshape.bin";
    const std::string namedAniPath = "model/demo1/body/bodyonly/attack1.ani";
    const std::string unresolvedAniOriginalPath = "model/mushi/body/bodyonly/attack1.ani";
    const std::string unresolvedTexturePath =
        "model/mushi/body/bodyonly/attack1_res005.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> tableData = BuildNpcShapeTableBinary(
        std::vector<TestNpcShapeRow>(1,
                                     MakeTestNpcShapeRow("mushi",
                                                         "attack1",
                                                         "magic1",
                                                         "attacked",
                                                         "death")));
    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int tablePathCrc =
        SLJFP_crc32(0, (const unsigned char*)tablePath.data(), (unsigned int)tablePath.size());
    const unsigned int namedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath.data(), (unsigned int)namedAniPath.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int unresolvedTexturePathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedTexturePath.data(),
                    (unsigned int)unresolvedTexturePath.size());
    const unsigned int tableDataCrc =
        SLJFP_crc32(0, tableData.data(), (unsigned int)tableData.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(tablePathCrc), tableData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedTexturePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)tableData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        tableDataCrc,
        aniDataCrc,
        aniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        tablePathCrc,
        namedAniPathCrc,
        unresolvedAniPathCrc,
        unresolvedTexturePathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << tablePathCrc << "|" << tablePath << "\n";
        mappingFile << namedAniPathCrc << "|" << namedAniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string unresolvedRootAniPath =
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string unresolvedRootTexturePath =
        std::to_string(unresolvedTexturePathCrc) + ".png";

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> restoredTexture;
    std::vector<unsigned char> unexpectedRootAni;
    std::vector<unsigned char> unexpectedRootTexture;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + unresolvedAniOriginalPath, restoredAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + unresolvedTexturePath, restoredTexture));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + unresolvedRootAniPath, unexpectedRootAni));
    TEST_ASSERT_FALSE(
        ReadTestFile(outputDir + "/" + unresolvedRootTexturePath, unexpectedRootTexture));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    TEST_ASSERT_EQ(pngData.size(), restoredTexture.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredTexture.data(), pngData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreModelTextureAfterReviewAliasTailCandidate) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_texture_from_tail_alias";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedAniPath = "model/demo1/body/bodyonly/attack1.ani";
    const std::string unresolvedAniOriginalPath = "misc/review/attack1_alias.ani";
    const std::string unresolvedTexturePath =
        "model/demo1/body/bodyonly/attack1_res005.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int namedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath.data(), (unsigned int)namedAniPath.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int unresolvedTexturePathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedTexturePath.data(),
                    (unsigned int)unresolvedTexturePath.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedTexturePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    const unsigned int sizes[] = {
        (unsigned int)aniData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        aniDataCrc,
        aniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        namedAniPathCrc,
        unresolvedAniPathCrc,
        unresolvedTexturePathCrc
    };

    for (int i = 0; i < 3; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedAniPathCrc << "|" << namedAniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string unresolvedRootAniPath =
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string reviewAliasPath =
        "review/model_ani/body/bodyonly/attack1.candidate." +
        std::to_string(unresolvedAniPathCrc) + ".ani";
    const std::string unresolvedRootTexturePath =
        std::to_string(unresolvedTexturePathCrc) + ".png";
    const std::string reviewReportPath = "review_alias_model_ani.txt";

    std::vector<unsigned char> unexpectedRootAni;
    std::vector<unsigned char> reviewAliasAni;
    std::vector<unsigned char> restoredTexture;
    std::vector<unsigned char> unexpectedRootTexture;
    std::vector<unsigned char> reportData;

    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + unresolvedRootAniPath, unexpectedRootAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewAliasPath, reviewAliasAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + unresolvedTexturePath, restoredTexture));
    TEST_ASSERT_FALSE(
        ReadTestFile(outputDir + "/" + unresolvedRootTexturePath, unexpectedRootTexture));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + reviewReportPath, reportData));
    TEST_ASSERT_EQ(aniData.size(), reviewAliasAni.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), reviewAliasAni.data(), aniData.size());
    TEST_ASSERT_EQ(pngData.size(), restoredTexture.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredTexture.data(), pngData.size());
    TEST_ASSERT_NE(std::string::npos,
                   std::string(reinterpret_cast<const char*>(reportData.data()),
                               reportData.size()).find("tail_alias"));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreModelTextureFromAmbiguousReviewAliasNamedAniCandidates) {
    const std::string baseDir =
        "test_output/unpacker_review_alias_model_ani_texture_from_ambiguous_named_candidates";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedAniPath1 = "model/demo1/body/bodyonly/attack1.ani";
    const std::string namedAniPath2 = "model/demo2/body/bodyonly/defend.ani";
    const std::string unresolvedAniOriginalPath = "misc/review/ambiguous_alias.ani";
    const std::string unresolvedTexturePath =
        "model/demo2/body/bodyonly/defend_res005.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int namedAniPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath1.data(), (unsigned int)namedAniPath1.size());
    const unsigned int namedAniPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath2.data(), (unsigned int)namedAniPath2.size());
    const unsigned int unresolvedAniPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedAniOriginalPath.data(),
                    (unsigned int)unresolvedAniOriginalPath.size());
    const unsigned int unresolvedTexturePathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedTexturePath.data(),
                    (unsigned int)unresolvedTexturePath.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc1), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc2), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(
        WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedTexturePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)aniData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        aniDataCrc,
        aniDataCrc,
        aniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        namedAniPathCrc1,
        namedAniPathCrc2,
        unresolvedAniPathCrc,
        unresolvedTexturePathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedAniPathCrc1 << "|" << namedAniPath1 << "\n";
        mappingFile << namedAniPathCrc2 << "|" << namedAniPath2 << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writeReviewAliases = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string unresolvedRootTexturePath =
        std::to_string(unresolvedTexturePathCrc) + ".png";
    std::vector<unsigned char> restoredTexture;
    std::vector<unsigned char> unexpectedRootTexture;
    std::vector<unsigned char> reportData;

    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + unresolvedTexturePath, restoredTexture));
    TEST_ASSERT_FALSE(
        ReadTestFile(outputDir + "/" + unresolvedRootTexturePath, unexpectedRootTexture));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/review_alias_model_ani.txt", reportData));
    TEST_ASSERT_EQ(pngData.size(), restoredTexture.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredTexture.data(), pngData.size());
    TEST_ASSERT_NE(std::string::npos,
                   std::string(reinterpret_cast<const char*>(reportData.data()),
                               reportData.size()).find("ambiguous"));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, DoNotRestoreCanonicalModelSpineJsonDirectoryFromAmbiguousAtlasSignature) {
    const std::string baseDir =
        "test_output/unpacker_canonical_model_spine_json_atlas_signature_ambiguous";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string atlasPath1 = "model/spine_createrole_xuejingling/atlas1.atlas";
    const std::string atlasPath2 = "model/mtjumowang/atlas2.atlas";
    const std::string unresolvedJsonOriginalPath = "misc/spine/ambiguous_createrole_json";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    std::vector<std::string> regionNames;
    regionNames.push_back("xuejingling_nv_1a");
    regionNames.push_back("zuoyi1");
    regionNames.push_back("toufahou");
    regionNames.push_back("shenti");

    const std::vector<unsigned char> atlasData1 =
        BuildSpineAtlasWithRegions("spine_createrole_xuejingling.png", regionNames);
    const std::vector<unsigned char> atlasData2 =
        BuildSpineAtlasWithRegions("mtjumowang.png", regionNames);
    const std::vector<unsigned char> jsonData =
        BuildSpineJsonWithAttachments(regionNames);

    const unsigned int atlasPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)atlasPath1.data(), (unsigned int)atlasPath1.size());
    const unsigned int atlasPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)atlasPath2.data(), (unsigned int)atlasPath2.size());
    const unsigned int unresolvedJsonPathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)unresolvedJsonOriginalPath.data(),
                    (unsigned int)unresolvedJsonOriginalPath.size());
    const unsigned int atlasDataCrc1 =
        SLJFP_crc32(0, atlasData1.data(), (unsigned int)atlasData1.size());
    const unsigned int atlasDataCrc2 =
        SLJFP_crc32(0, atlasData2.data(), (unsigned int)atlasData2.size());
    const unsigned int jsonDataCrc =
        SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc1), atlasData1));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc2), atlasData2));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unresolvedJsonPathCrc), jsonData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData1.size());
    AppendUInt32Le(indexData, atlasDataCrc1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, atlasPathCrc1);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData2.size());
    AppendUInt32Le(indexData, atlasDataCrc2);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, atlasPathCrc2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)jsonData.size());
    AppendUInt32Le(indexData, jsonDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unresolvedJsonPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << atlasPathCrc1 << "|" << atlasPath1 << "\n";
        mappingFile << atlasPathCrc2 << "|" << atlasPath2 << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> unresolvedRootJson;
    std::vector<unsigned char> movedJson;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + std::to_string(unresolvedJsonPathCrc) + ".json",
                                  unresolvedRootJson));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/model/spine_createrole_xuejingling/" +
                                   std::to_string(unresolvedJsonPathCrc) + ".json",
                                   movedJson));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/model/mtjumowang/" +
                                   std::to_string(unresolvedJsonPathCrc) + ".json",
                                   movedJson));
    TEST_ASSERT_EQ(jsonData.size(), unresolvedRootJson.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), unresolvedRootJson.data(), jsonData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreEffectPathTableReferencedResources) {
    const std::string baseDir = "test_output/unpacker_effectpath_table_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string effectPathTablePath =
        "table/bintable/effectpath.ceffectpathnonedrama.bin";
    const std::string effectToken = "geffect/ui/demo/demo";
    const std::string effectXmlPath = "effect/" + effectToken + ".eff.inf";
    const std::string effectAniStem = "animation/ui/demo/demo";
    const std::string effectAniPath = "effect/" + effectAniStem + ".ani";
    const std::string effectImagePath = "effect/animation/ui/demo/demo_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> effectPathTableData =
        BuildEffectPathNoneDramaTableBinary(std::vector<std::string>(1, effectToken));
    const std::vector<unsigned char> effectXmlData = BuildUtf16LeText(
        "<data t_f=\"100\" d_l=\"0\" b_l=\"0\" b_t=\"0\" b_r=\"0\" b_b=\"0\" fps=\"8.000000\" bT=\"0\" hasA=\"0\">"
        "<clip s_f=\"0\" e_f=\"-1\" layer=\"0\" r_f=\"" + effectAniStem + "\" fps=\"1.000000\" rel_x=\"0\" rel_y=\"0\" v_c=\"4294967295\" p_m=\"0\">"
        "<TOOLS_DATA><pos_keys/><scale_keys/><rotation_keys/><alpha_keys/><color_keys/><divide_keys/></TOOLS_DATA>"
        "</clip></data>");
    const std::vector<unsigned char> effectAniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int effectPathTablePathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectPathTablePath.data(), (unsigned int)effectPathTablePath.size());
    const unsigned int effectXmlPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectXmlPath.data(), (unsigned int)effectXmlPath.size());
    const unsigned int effectAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectAniPath.data(), (unsigned int)effectAniPath.size());
    const unsigned int effectImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectImagePath.data(), (unsigned int)effectImagePath.size());

    const unsigned int effectPathTableDataCrc =
        SLJFP_crc32(0, effectPathTableData.data(), (unsigned int)effectPathTableData.size());
    const unsigned int effectXmlDataCrc =
        SLJFP_crc32(0, effectXmlData.data(), (unsigned int)effectXmlData.size());
    const unsigned int effectAniDataCrc =
        SLJFP_crc32(0, effectAniData.data(), (unsigned int)effectAniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectPathTablePathCrc),
                                       effectPathTableData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectXmlPathCrc),
                                       effectXmlData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectAniPathCrc),
                                       effectAniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectImagePathCrc),
                                       pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)effectPathTableData.size(),
        (unsigned int)effectXmlData.size(),
        (unsigned int)effectAniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        effectPathTableDataCrc,
        effectXmlDataCrc,
        effectAniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        effectPathTablePathCrc,
        effectXmlPathCrc,
        effectAniPathCrc,
        effectImagePathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        const std::string dummyPath = "script/logic/demo/dummy.lua";
        const unsigned int dummyPathCrc =
            SLJFP_crc32(0, (const unsigned char*)dummyPath.data(), (unsigned int)dummyPath.size());
        mappingFile << dummyPathCrc << "|" << dummyPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredEffectPathTable;
    std::vector<unsigned char> restoredEffectXml;
    std::vector<unsigned char> restoredEffectAni;
    std::vector<unsigned char> restoredEffectPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectPathTablePath, restoredEffectPathTable));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectXmlPath, restoredEffectXml));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectAniPath, restoredEffectAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectImagePath, restoredEffectPng));
    TEST_ASSERT_EQ(effectPathTableData.size(), restoredEffectPathTable.size());
    TEST_ASSERT_EQ(effectXmlData.size(), restoredEffectXml.size());
    TEST_ASSERT_EQ(effectAniData.size(), restoredEffectAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredEffectPng.size());
    TEST_ASSERT_MEM_EQ(effectPathTableData.data(), restoredEffectPathTable.data(), effectPathTableData.size());
    TEST_ASSERT_MEM_EQ(effectXmlData.data(), restoredEffectXml.data(), effectXmlData.size());
    TEST_ASSERT_MEM_EQ(effectAniData.data(), restoredEffectAni.data(), effectAniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredEffectPng.data(), pngData.size());

    std::vector<unsigned char> leftoverEffectXml;
    std::vector<unsigned char> leftoverEffectAni;
    std::vector<unsigned char> leftoverEffectPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectXmlPathCrc) + ".xml",
                                   leftoverEffectXml));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectAniPathCrc) + ".ani",
                                   leftoverEffectAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectImagePathCrc) + ".png",
                                   leftoverEffectPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreBattleStageTableReferencedResources) {
    const std::string baseDir = "test_output/unpacker_battle_stage_table_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string stageTablePath = "table/bintable/battle.cstageinfo.bin";
    const std::string effectToken = "geffect/skill/acc-teji/cc.demo";
    const std::string effectXmlPath = "effect/" + effectToken + ".eff.inf";
    const std::string effectAniStem = "animation/skill/acc-teji/cc.demo";
    const std::string effectAniPath = "effect/" + effectAniStem + ".ani";
    const std::string effectImagePath = "effect/animation/skill/acc-teji/cc.demo_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> stageTableData =
        BuildBattleStageInfoTableBinary(std::vector<std::string>(1, effectToken));
    const std::vector<unsigned char> effectXmlData = BuildUtf16LeText(
        "<data t_f=\"100\" d_l=\"0\" b_l=\"0\" b_t=\"0\" b_r=\"0\" b_b=\"0\" fps=\"8.000000\" bT=\"0\" hasA=\"0\">"
        "<clip s_f=\"0\" e_f=\"-1\" layer=\"0\" r_f=\"" + effectAniStem + "\" fps=\"1.000000\" rel_x=\"0\" rel_y=\"0\" v_c=\"4294967295\" p_m=\"0\">"
        "<TOOLS_DATA><pos_keys/><scale_keys/><rotation_keys/><alpha_keys/><color_keys/><divide_keys/></TOOLS_DATA>"
        "</clip></data>");
    const std::vector<unsigned char> effectAniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int stageTablePathCrc =
        SLJFP_crc32(0, (const unsigned char*)stageTablePath.data(), (unsigned int)stageTablePath.size());
    const unsigned int effectXmlPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectXmlPath.data(), (unsigned int)effectXmlPath.size());
    const unsigned int effectAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectAniPath.data(), (unsigned int)effectAniPath.size());
    const unsigned int effectImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)effectImagePath.data(), (unsigned int)effectImagePath.size());

    const unsigned int stageTableDataCrc =
        SLJFP_crc32(0, stageTableData.data(), (unsigned int)stageTableData.size());
    const unsigned int effectXmlDataCrc =
        SLJFP_crc32(0, effectXmlData.data(), (unsigned int)effectXmlData.size());
    const unsigned int effectAniDataCrc =
        SLJFP_crc32(0, effectAniData.data(), (unsigned int)effectAniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(stageTablePathCrc),
                                       stageTableData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectXmlPathCrc),
                                       effectXmlData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectAniPathCrc),
                                       effectAniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectImagePathCrc),
                                       pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)stageTableData.size(),
        (unsigned int)effectXmlData.size(),
        (unsigned int)effectAniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        stageTableDataCrc,
        effectXmlDataCrc,
        effectAniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        stageTablePathCrc,
        effectXmlPathCrc,
        effectAniPathCrc,
        effectImagePathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        const std::string dummyPath = "script/logic/demo/dummy.lua";
        const unsigned int dummyPathCrc =
            SLJFP_crc32(0, (const unsigned char*)dummyPath.data(), (unsigned int)dummyPath.size());
        mappingFile << dummyPathCrc << "|" << dummyPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredStageTable;
    std::vector<unsigned char> restoredEffectXml;
    std::vector<unsigned char> restoredEffectAni;
    std::vector<unsigned char> restoredEffectPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + stageTablePath, restoredStageTable));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectXmlPath, restoredEffectXml));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectAniPath, restoredEffectAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectImagePath, restoredEffectPng));
    TEST_ASSERT_EQ(stageTableData.size(), restoredStageTable.size());
    TEST_ASSERT_EQ(effectXmlData.size(), restoredEffectXml.size());
    TEST_ASSERT_EQ(effectAniData.size(), restoredEffectAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredEffectPng.size());
    TEST_ASSERT_MEM_EQ(stageTableData.data(), restoredStageTable.data(), stageTableData.size());
    TEST_ASSERT_MEM_EQ(effectXmlData.data(), restoredEffectXml.data(), effectXmlData.size());
    TEST_ASSERT_MEM_EQ(effectAniData.data(), restoredEffectAni.data(), effectAniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredEffectPng.data(), pngData.size());

    std::vector<unsigned char> leftoverEffectXml;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectXmlPathCrc) + ".xml",
                                   leftoverEffectXml));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreSpineEffectReferencedResources) {
    const std::string baseDir = "test_output/unpacker_spine_effect_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string setPath = "effect/spine/spine_effect.set";
    const std::string effectBasePath = "effect/spine/demo/demo";
    const std::string atlasPath = effectBasePath + ".atlas";
    const std::string jsonPath = effectBasePath + ".json";
    const std::string imagePath = "effect/spine/demo/demo.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> setData = BuildSpineEffectRegistryXml("spine/demo/demo");
    const std::vector<unsigned char> atlasData = BuildMinimalSpineAtlas("demo.png");
    const std::vector<unsigned char> jsonData = BuildMinimalSpineJson();
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int setPathCrc = SLJFP_crc32(0, (const unsigned char*)setPath.data(), (unsigned int)setPath.size());
    const unsigned int atlasPathCrc = SLJFP_crc32(0, (const unsigned char*)atlasPath.data(), (unsigned int)atlasPath.size());
    const unsigned int jsonPathCrc = SLJFP_crc32(0, (const unsigned char*)jsonPath.data(), (unsigned int)jsonPath.size());
    const unsigned int imagePathCrc = SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());
    const unsigned int setDataCrc = SLJFP_crc32(0, setData.data(), (unsigned int)setData.size());
    const unsigned int atlasDataCrc = SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int jsonDataCrc = SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());
    const unsigned int pngDataCrc = SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(setPathCrc), setData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc), atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(jsonPathCrc), jsonData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)setData.size());
    AppendUInt32Le(indexData, setDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, setPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, atlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)jsonData.size());
    AppendUInt32Le(indexData, jsonDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, jsonPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData.size());
    AppendUInt32Le(indexData, pngDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagePathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << setPathCrc << "|" << setPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredSet;
    std::vector<unsigned char> restoredAtlas;
    std::vector<unsigned char> restoredJson;
    std::vector<unsigned char> restoredPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + setPath, restoredSet));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + atlasPath, restoredAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + jsonPath, restoredJson));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredPng));
    TEST_ASSERT_EQ(setData.size(), restoredSet.size());
    TEST_ASSERT_EQ(atlasData.size(), restoredAtlas.size());
    TEST_ASSERT_EQ(jsonData.size(), restoredJson.size());
    TEST_ASSERT_EQ(pngData.size(), restoredPng.size());
    TEST_ASSERT_MEM_EQ(setData.data(), restoredSet.data(), setData.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredJson.data(), jsonData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredPng.data(), pngData.size());

    std::vector<unsigned char> leftoverAtlas;
    std::vector<unsigned char> leftoverJson;
    std::vector<unsigned char> leftoverPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(atlasPathCrc) + ".atlas", leftoverAtlas));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(jsonPathCrc) + ".json", leftoverJson));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png", leftoverPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreModelSpineReferencedResourcesFromLuaLiteral) {
    const std::string baseDir = "test_output/unpacker_model_spine_from_lua";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string scriptPath = "script/logic/demo.lua";
    const std::string modelName = "demo_model";
    const std::string atlasPath = "model/" + modelName + "/" + modelName + ".atlas";
    const std::string jsonPath = "model/" + modelName + "/" + modelName + ".json";
    const std::string imagePath = "model/" + modelName + "/" + modelName + ".png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> scriptData = BuildUtf8Text(
        "local spine = UISpineSprite:new('demo_model')\n"
        "spine:SetSpineModel(\"demo_model\", false)\n");
    const std::vector<unsigned char> atlasData = BuildMinimalSpineAtlas("demo_model.png");
    const std::vector<unsigned char> jsonData = BuildMinimalSpineJson();
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int scriptPathCrc =
        SLJFP_crc32(0, (const unsigned char*)scriptPath.data(), (unsigned int)scriptPath.size());
    const unsigned int atlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)atlasPath.data(), (unsigned int)atlasPath.size());
    const unsigned int jsonPathCrc =
        SLJFP_crc32(0, (const unsigned char*)jsonPath.data(), (unsigned int)jsonPath.size());
    const unsigned int imagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());
    const unsigned int scriptDataCrc =
        SLJFP_crc32(0, scriptData.data(), (unsigned int)scriptData.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int jsonDataCrc =
        SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(scriptPathCrc), scriptData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc), atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(jsonPathCrc), jsonData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)scriptData.size());
    AppendUInt32Le(indexData, scriptDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, scriptPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, atlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)jsonData.size());
    AppendUInt32Le(indexData, jsonDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, jsonPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData.size());
    AppendUInt32Le(indexData, pngDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagePathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << scriptPathCrc << "|" << scriptPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredScript;
    std::vector<unsigned char> restoredAtlas;
    std::vector<unsigned char> restoredJson;
    std::vector<unsigned char> restoredPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + scriptPath, restoredScript));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + atlasPath, restoredAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + jsonPath, restoredJson));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredPng));
    TEST_ASSERT_EQ(scriptData.size(), restoredScript.size());
    TEST_ASSERT_EQ(atlasData.size(), restoredAtlas.size());
    TEST_ASSERT_EQ(jsonData.size(), restoredJson.size());
    TEST_ASSERT_EQ(pngData.size(), restoredPng.size());
    TEST_ASSERT_MEM_EQ(scriptData.data(), restoredScript.data(), scriptData.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredJson.data(), jsonData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredPng.data(), pngData.size());

    std::vector<unsigned char> leftoverAtlas;
    std::vector<unsigned char> leftoverPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(atlasPathCrc) + ".atlas", leftoverAtlas));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png", leftoverPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreSpineModelResourcesFromSpritesSetType1) {
    const std::string baseDir = "test_output/unpacker_spine_from_sprites_set";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string registryPath = "model/sprites.set";
    const std::string modelName = "paopao";
    const std::string atlasPath = "model/" + modelName + "/" + modelName + ".atlas";
    const std::string jsonPath = "model/" + modelName + "/" + modelName + ".json";
    const std::string imagePath = "model/" + modelName + "/" + modelName + ".png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> registryData =
        BuildUtf16LeText("<data><model name=\"paopao\" des=\"泡泡\" type=\"1\" titlepos=\"0\" efctPosX=\"0\" efctPosY=\"0\" surfacetype=\"1\" blx=\"-10\" bly=\"0\" brx=\"10\" bry=\"0\" scale=\"1.000000\"/></data>");
    const std::vector<unsigned char> atlasData = BuildMinimalSpineAtlas("paopao.png");
    const std::vector<unsigned char> jsonData = BuildMinimalSpineJson();
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int registryPathCrc =
        SLJFP_crc32(0, (const unsigned char*)registryPath.data(), (unsigned int)registryPath.size());
    const unsigned int atlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)atlasPath.data(), (unsigned int)atlasPath.size());
    const unsigned int jsonPathCrc =
        SLJFP_crc32(0, (const unsigned char*)jsonPath.data(), (unsigned int)jsonPath.size());
    const unsigned int imagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());

    const unsigned int registryDataCrc =
        SLJFP_crc32(0, registryData.data(), (unsigned int)registryData.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int jsonDataCrc =
        SLJFP_crc32(0, jsonData.data(), (unsigned int)jsonData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(registryPathCrc), registryData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc), atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(jsonPathCrc), jsonData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)registryData.size(),
        (unsigned int)atlasData.size(),
        (unsigned int)jsonData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        registryDataCrc,
        atlasDataCrc,
        jsonDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        registryPathCrc,
        atlasPathCrc,
        jsonPathCrc,
        imagePathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << registryPathCrc << "|" << registryPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredRegistry;
    std::vector<unsigned char> restoredAtlas;
    std::vector<unsigned char> restoredJson;
    std::vector<unsigned char> restoredPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + registryPath, restoredRegistry));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + atlasPath, restoredAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + jsonPath, restoredJson));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredPng));
    TEST_ASSERT_EQ(registryData.size(), restoredRegistry.size());
    TEST_ASSERT_EQ(atlasData.size(), restoredAtlas.size());
    TEST_ASSERT_EQ(jsonData.size(), restoredJson.size());
    TEST_ASSERT_EQ(pngData.size(), restoredPng.size());
    TEST_ASSERT_MEM_EQ(registryData.data(), restoredRegistry.data(), registryData.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(jsonData.data(), restoredJson.data(), jsonData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredPng.data(), pngData.size());

    std::vector<unsigned char> leftoverAtlas;
    std::vector<unsigned char> leftoverJson;
    std::vector<unsigned char> leftoverPng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(atlasPathCrc) + ".atlas", leftoverAtlas));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(jsonPathCrc) + ".json", leftoverJson));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png", leftoverPng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreTableDefBinaryAndCreateRoleSpineResources) {
    const std::string baseDir = "test_output/unpacker_tabledef_create_role_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string scriptPath = "script/tabledef/role/createroleconfig.lua";
    const std::string binPath = "table/bintable/role.createroleconfig.bin";
    const std::string spineName = "hero_spine";
    const std::string bgName = "hero_bg";
    const std::string liziName = "hero_lizi";

    const std::string spineAtlasPath = "model/" + spineName + "/" + spineName + ".atlas";
    const std::string spineJsonPath = "model/" + spineName + "/" + spineName + ".json";
    const std::string spineImagePath = "model/" + spineName + "/" + spineName + ".png";
    const std::string bgAtlasPath = "model/" + bgName + "/" + bgName + ".atlas";
    const std::string bgJsonPath = "model/" + bgName + "/" + bgName + ".json";
    const std::string bgImagePath = "model/" + bgName + "/" + bgName + ".png";
    const std::string liziAtlasPath = "model/" + liziName + "/" + liziName + ".atlas";
    const std::string liziJsonPath = "model/" + liziName + "/" + liziName + ".json";
    const std::string liziImagePath = "model/" + liziName + "/" + liziName + ".png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> scriptData =
        BuildUtf8Text("return require \"script.tabledef.role.createroleconfig\"\n");
    const std::vector<unsigned char> binData =
        BuildCreateRoleConfigBin(spineName, liziName, bgName);
    const std::vector<unsigned char> spineAtlasData = BuildMinimalSpineAtlas(spineName + ".png");
    const std::vector<unsigned char> spineJsonData = BuildMinimalSpineJson();
    const std::vector<unsigned char> spinePngData = BuildTinyPng();
    const std::vector<unsigned char> bgAtlasData = BuildMinimalSpineAtlas(bgName + ".png");
    const std::vector<unsigned char> bgJsonData = BuildMinimalSpineJson();
    const std::vector<unsigned char> bgPngData = BuildTinyPng();
    const std::vector<unsigned char> liziAtlasData = BuildMinimalSpineAtlas(liziName + ".png");
    const std::vector<unsigned char> liziJsonData = BuildMinimalSpineJson();
    const std::vector<unsigned char> liziPngData = BuildTinyPng();

    const unsigned int scriptPathCrc =
        SLJFP_crc32(0, (const unsigned char*)scriptPath.data(), (unsigned int)scriptPath.size());
    const unsigned int binPathCrc =
        SLJFP_crc32(0, (const unsigned char*)binPath.data(), (unsigned int)binPath.size());
    const unsigned int spineAtlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)spineAtlasPath.data(), (unsigned int)spineAtlasPath.size());
    const unsigned int spineJsonPathCrc =
        SLJFP_crc32(0, (const unsigned char*)spineJsonPath.data(), (unsigned int)spineJsonPath.size());
    const unsigned int spineImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)spineImagePath.data(), (unsigned int)spineImagePath.size());
    const unsigned int bgAtlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)bgAtlasPath.data(), (unsigned int)bgAtlasPath.size());
    const unsigned int bgJsonPathCrc =
        SLJFP_crc32(0, (const unsigned char*)bgJsonPath.data(), (unsigned int)bgJsonPath.size());
    const unsigned int bgImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)bgImagePath.data(), (unsigned int)bgImagePath.size());
    const unsigned int liziAtlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)liziAtlasPath.data(), (unsigned int)liziAtlasPath.size());
    const unsigned int liziJsonPathCrc =
        SLJFP_crc32(0, (const unsigned char*)liziJsonPath.data(), (unsigned int)liziJsonPath.size());
    const unsigned int liziImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)liziImagePath.data(), (unsigned int)liziImagePath.size());

    const unsigned int scriptDataCrc =
        SLJFP_crc32(0, scriptData.data(), (unsigned int)scriptData.size());
    const unsigned int binDataCrc =
        SLJFP_crc32(0, binData.data(), (unsigned int)binData.size());
    const unsigned int spineAtlasDataCrc =
        SLJFP_crc32(0, spineAtlasData.data(), (unsigned int)spineAtlasData.size());
    const unsigned int spineJsonDataCrc =
        SLJFP_crc32(0, spineJsonData.data(), (unsigned int)spineJsonData.size());
    const unsigned int spinePngDataCrc =
        SLJFP_crc32(0, spinePngData.data(), (unsigned int)spinePngData.size());
    const unsigned int bgAtlasDataCrc =
        SLJFP_crc32(0, bgAtlasData.data(), (unsigned int)bgAtlasData.size());
    const unsigned int bgJsonDataCrc =
        SLJFP_crc32(0, bgJsonData.data(), (unsigned int)bgJsonData.size());
    const unsigned int bgPngDataCrc =
        SLJFP_crc32(0, bgPngData.data(), (unsigned int)bgPngData.size());
    const unsigned int liziAtlasDataCrc =
        SLJFP_crc32(0, liziAtlasData.data(), (unsigned int)liziAtlasData.size());
    const unsigned int liziJsonDataCrc =
        SLJFP_crc32(0, liziJsonData.data(), (unsigned int)liziJsonData.size());
    const unsigned int liziPngDataCrc =
        SLJFP_crc32(0, liziPngData.data(), (unsigned int)liziPngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(scriptPathCrc), scriptData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(binPathCrc), binData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(spineAtlasPathCrc), spineAtlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(spineJsonPathCrc), spineJsonData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(spineImagePathCrc), spinePngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(bgAtlasPathCrc), bgAtlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(bgJsonPathCrc), bgJsonData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(bgImagePathCrc), bgPngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(liziAtlasPathCrc), liziAtlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(liziJsonPathCrc), liziJsonData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(liziImagePathCrc), liziPngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 11);

    const unsigned int sizes[] = {
        (unsigned int)scriptData.size(), (unsigned int)binData.size(),
        (unsigned int)spineAtlasData.size(), (unsigned int)spineJsonData.size(), (unsigned int)spinePngData.size(),
        (unsigned int)bgAtlasData.size(), (unsigned int)bgJsonData.size(), (unsigned int)bgPngData.size(),
        (unsigned int)liziAtlasData.size(), (unsigned int)liziJsonData.size(), (unsigned int)liziPngData.size()
    };
    const unsigned int dataCrcs[] = {
        scriptDataCrc, binDataCrc,
        spineAtlasDataCrc, spineJsonDataCrc, spinePngDataCrc,
        bgAtlasDataCrc, bgJsonDataCrc, bgPngDataCrc,
        liziAtlasDataCrc, liziJsonDataCrc, liziPngDataCrc
    };
    const unsigned int pathCrcs[] = {
        scriptPathCrc, binPathCrc,
        spineAtlasPathCrc, spineJsonPathCrc, spineImagePathCrc,
        bgAtlasPathCrc, bgJsonPathCrc, bgImagePathCrc,
        liziAtlasPathCrc, liziJsonPathCrc, liziImagePathCrc
    };

    for (int i = 0; i < 11; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << scriptPathCrc << "|" << scriptPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredBin;
    std::vector<unsigned char> restoredSpineAtlas;
    std::vector<unsigned char> restoredSpinePng;
    std::vector<unsigned char> restoredBgAtlas;
    std::vector<unsigned char> restoredLiziAtlas;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + binPath, restoredBin));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + spineAtlasPath, restoredSpineAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + spineImagePath, restoredSpinePng));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + bgAtlasPath, restoredBgAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + liziAtlasPath, restoredLiziAtlas));
    TEST_ASSERT_EQ(binData.size(), restoredBin.size());
    TEST_ASSERT_EQ(spineAtlasData.size(), restoredSpineAtlas.size());
    TEST_ASSERT_EQ(spinePngData.size(), restoredSpinePng.size());
    TEST_ASSERT_MEM_EQ(binData.data(), restoredBin.data(), binData.size());
    TEST_ASSERT_MEM_EQ(spineAtlasData.data(), restoredSpineAtlas.data(), spineAtlasData.size());
    TEST_ASSERT_MEM_EQ(spinePngData.data(), restoredSpinePng.data(), spinePngData.size());

    std::vector<unsigned char> leftoverBin;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(binPathCrc) + ".bin", leftoverBin));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreTableDefResourcesFromBeanConfigReferences) {
    const std::string baseDir = "test_output/unpacker_tabledef_from_beanconfig_refs";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string refScriptPath = "script/logic/demo/beanconfig_ref.lua";
    const std::string tableLuaPath1 = "script/tabledef/skill/cjingmaizhanshi.lua";
    const std::string tableBinPath1 = "table/bintable/skill.cjingmaizhanshi.bin";
    const std::string tableLuaPath2 = "script/tabledef/shop/cnpcsale.lua";
    const std::string tableBinPath2 = "table/bintable/shop.cnpcsale.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> refScriptData = BuildUtf8Text(
        "local a = BeanConfigManager.getInstance():GetTableByName(\"skill.cjingmaizhanshi\")\n"
        "local b = BeanConfigManager.getInstance():GetTableByName(CheckTableName(\"shop.cnpcsale\"))\n"
        "return a ~= nil and b ~= nil\n");
    const std::vector<unsigned char> tableLuaData1 = BuildUtf8Text(
        "require \"utils.binutil\"\n"
        "CJingMaiZhanShiTable = {}\n"
        "return CJingMaiZhanShiTable\n");
    const std::vector<unsigned char> tableLuaData2 = BuildUtf8Text(
        "require \"utils.binutil\"\n"
        "CNpcSaleTable = {}\n"
        "return CNpcSaleTable\n");
    const std::vector<unsigned char> tableBinData1 = BuildUtf8Text("BIN_SKILL_JINGMAI");
    const std::vector<unsigned char> tableBinData2 = BuildUtf8Text("BIN_SHOP_NPCSALE");

    const unsigned int refScriptPathCrc =
        SLJFP_crc32(0, (const unsigned char*)refScriptPath.data(), (unsigned int)refScriptPath.size());
    const unsigned int tableLuaPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)tableLuaPath1.data(), (unsigned int)tableLuaPath1.size());
    const unsigned int tableBinPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)tableBinPath1.data(), (unsigned int)tableBinPath1.size());
    const unsigned int tableLuaPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)tableLuaPath2.data(), (unsigned int)tableLuaPath2.size());
    const unsigned int tableBinPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)tableBinPath2.data(), (unsigned int)tableBinPath2.size());

    const unsigned int refScriptDataCrc =
        SLJFP_crc32(0, refScriptData.data(), (unsigned int)refScriptData.size());
    const unsigned int tableLuaDataCrc1 =
        SLJFP_crc32(0, tableLuaData1.data(), (unsigned int)tableLuaData1.size());
    const unsigned int tableBinDataCrc1 =
        SLJFP_crc32(0, tableBinData1.data(), (unsigned int)tableBinData1.size());
    const unsigned int tableLuaDataCrc2 =
        SLJFP_crc32(0, tableLuaData2.data(), (unsigned int)tableLuaData2.size());
    const unsigned int tableBinDataCrc2 =
        SLJFP_crc32(0, tableBinData2.data(), (unsigned int)tableBinData2.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(refScriptPathCrc), refScriptData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(tableLuaPathCrc1), tableLuaData1));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(tableBinPathCrc1), tableBinData1));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(tableLuaPathCrc2), tableLuaData2));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(tableBinPathCrc2), tableBinData2));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 5);

    const unsigned int sizes[] = {
        (unsigned int)refScriptData.size(),
        (unsigned int)tableLuaData1.size(),
        (unsigned int)tableBinData1.size(),
        (unsigned int)tableLuaData2.size(),
        (unsigned int)tableBinData2.size()
    };
    const unsigned int dataCrcs[] = {
        refScriptDataCrc,
        tableLuaDataCrc1,
        tableBinDataCrc1,
        tableLuaDataCrc2,
        tableBinDataCrc2
    };
    const unsigned int pathCrcs[] = {
        refScriptPathCrc,
        tableLuaPathCrc1,
        tableBinPathCrc1,
        tableLuaPathCrc2,
        tableBinPathCrc2
    };

    for (int i = 0; i < 5; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << refScriptPathCrc << "|" << refScriptPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredRefScript;
    std::vector<unsigned char> restoredTableLua1;
    std::vector<unsigned char> restoredTableBin1;
    std::vector<unsigned char> restoredTableLua2;
    std::vector<unsigned char> restoredTableBin2;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + refScriptPath, restoredRefScript));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + tableLuaPath1, restoredTableLua1));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + tableBinPath1, restoredTableBin1));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + tableLuaPath2, restoredTableLua2));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + tableBinPath2, restoredTableBin2));
    TEST_ASSERT_EQ(refScriptData.size(), restoredRefScript.size());
    TEST_ASSERT_EQ(tableLuaData1.size(), restoredTableLua1.size());
    TEST_ASSERT_EQ(tableBinData1.size(), restoredTableBin1.size());
    TEST_ASSERT_EQ(tableLuaData2.size(), restoredTableLua2.size());
    TEST_ASSERT_EQ(tableBinData2.size(), restoredTableBin2.size());
    TEST_ASSERT_MEM_EQ(refScriptData.data(), restoredRefScript.data(), refScriptData.size());
    TEST_ASSERT_MEM_EQ(tableLuaData1.data(), restoredTableLua1.data(), tableLuaData1.size());
    TEST_ASSERT_MEM_EQ(tableBinData1.data(), restoredTableBin1.data(), tableBinData1.size());
    TEST_ASSERT_MEM_EQ(tableLuaData2.data(), restoredTableLua2.data(), tableLuaData2.size());
    TEST_ASSERT_MEM_EQ(tableBinData2.data(), restoredTableBin2.data(), tableBinData2.size());

    std::vector<unsigned char> leftoverTableLua1;
    std::vector<unsigned char> leftoverTableBin1;
    std::vector<unsigned char> leftoverTableLua2;
    std::vector<unsigned char> leftoverTableBin2;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(tableLuaPathCrc1) + ".lua", leftoverTableLua1));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(tableBinPathCrc1) + ".bin", leftoverTableBin1));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(tableLuaPathCrc2) + ".lua", leftoverTableLua2));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(tableBinPathCrc2) + ".bin", leftoverTableBin2));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreEffectPathRegistryBinsFromKnownTablePaths) {
    const std::string baseDir = "test_output/unpacker_effectpath_registry_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string effectPathBin = "table/bintable/effectpath.ceffectpath.bin";
    const std::string effectPathNoneDramaBin =
        "table/bintable/effectpath.ceffectpathnonedrama.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> effectPathData = BuildUtf8Text("geffect/ui/red+\n");
    const std::vector<unsigned char> effectPathNoneDramaData =
        BuildUtf8Text("geffect/ui/ccziti1/lv-10\n");

    const unsigned int effectPathBinCrc =
        SLJFP_crc32(0, (const unsigned char*)effectPathBin.data(), (unsigned int)effectPathBin.size());
    const unsigned int effectPathNoneDramaBinCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)effectPathNoneDramaBin.data(),
                    (unsigned int)effectPathNoneDramaBin.size());
    const unsigned int effectPathDataCrc =
        SLJFP_crc32(0, effectPathData.data(), (unsigned int)effectPathData.size());
    const unsigned int effectPathNoneDramaDataCrc =
        SLJFP_crc32(0,
                    effectPathNoneDramaData.data(),
                    (unsigned int)effectPathNoneDramaData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectPathBinCrc),
                                       effectPathData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(effectPathNoneDramaBinCrc),
                                       effectPathNoneDramaData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)effectPathData.size());
    AppendUInt32Le(indexData, effectPathDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, effectPathBinCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)effectPathNoneDramaData.size());
    AppendUInt32Le(indexData, effectPathNoneDramaDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, effectPathNoneDramaBinCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredEffectPathData;
    std::vector<unsigned char> restoredEffectPathNoneDramaData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectPathBin, restoredEffectPathData));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + effectPathNoneDramaBin,
                                  restoredEffectPathNoneDramaData));
    TEST_ASSERT_EQ(effectPathData.size(), restoredEffectPathData.size());
    TEST_ASSERT_EQ(effectPathNoneDramaData.size(), restoredEffectPathNoneDramaData.size());
    TEST_ASSERT_MEM_EQ(effectPathData.data(),
                       restoredEffectPathData.data(),
                       effectPathData.size());
    TEST_ASSERT_MEM_EQ(effectPathNoneDramaData.data(),
                       restoredEffectPathNoneDramaData.data(),
                       effectPathNoneDramaData.size());

    std::vector<unsigned char> leftoverEffectPath;
    std::vector<unsigned char> leftoverEffectPathNoneDrama;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectPathBinCrc) + ".txt",
                                   leftoverEffectPath));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectPathNoneDramaBinCrc) + ".txt",
                                   leftoverEffectPathNoneDrama));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectPathBinCrc),
                                   leftoverEffectPath));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(effectPathNoneDramaBinCrc),
                                   leftoverEffectPathNoneDrama));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreParticleTextureReferencesFromEmbeddedTokens) {
    const std::string baseDir = "test_output/unpacker_particle_texture_tokens";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string tokenSourcePath = "misc/particle_refs.bin";
    const std::string particleImagePath = "effect/particle/texture/animation/a00012_3x3.png";
    const std::string particlePathPath = "effect/particle/path/line04.path";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> tokenSourceData =
        BuildUtf16LeText("animation\\a00012_3x3.png\nline04.path\n");
    const std::vector<unsigned char> pngData = BuildTinyPng();
    const std::vector<unsigned char> pathData = BuildUtf8Text("particle-path");

    const unsigned int tokenSourcePathCrc =
        SLJFP_crc32(0, (const unsigned char*)tokenSourcePath.data(), (unsigned int)tokenSourcePath.size());
    const unsigned int particleImagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)particleImagePath.data(), (unsigned int)particleImagePath.size());
    const unsigned int particlePathPathCrc =
        SLJFP_crc32(0, (const unsigned char*)particlePathPath.data(), (unsigned int)particlePathPath.size());

    const unsigned int tokenSourceDataCrc =
        SLJFP_crc32(0, tokenSourceData.data(), (unsigned int)tokenSourceData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());
    const unsigned int pathDataCrc =
        SLJFP_crc32(0, pathData.data(), (unsigned int)pathData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(tokenSourcePathCrc), tokenSourceData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(particleImagePathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(particlePathPathCrc), pathData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    const unsigned int sizes[] = {
        (unsigned int)tokenSourceData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)pathData.size()
    };
    const unsigned int dataCrcs[] = {
        tokenSourceDataCrc,
        pngDataCrc,
        pathDataCrc
    };
    const unsigned int pathCrcs[] = {
        tokenSourcePathCrc,
        particleImagePathCrc,
        particlePathPathCrc
    };

    for (int i = 0; i < 3; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredPng;
    std::vector<unsigned char> restoredPath;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + particleImagePath, restoredPng));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + particlePathPath, restoredPath));
    TEST_ASSERT_EQ(pngData.size(), restoredPng.size());
    TEST_ASSERT_EQ(pathData.size(), restoredPath.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredPng.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(pathData.data(), restoredPath.data(), pathData.size());

    std::vector<unsigned char> leftoverPng;
    std::vector<unsigned char> leftoverPath;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(particleImagePathCrc) + ".png", leftoverPng));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(particlePathPathCrc), leftoverPath));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreMapResourcesWhenConfigAlreadyMapped) {
    const std::string baseDir = "test_output/unpacker_map_restore_from_mapped_config";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string configPath = "table/bintable/map.cmapconfig.bin";
    const std::string mazePath = "map/5001_dayanta1/maze.dat";
    const std::string monsterPath = "map/5001_dayanta1/monster.dat";
    const std::string gotoPath = "map/5001_dayanta1/goto.dat";
    const std::string regionTypePath = "map/5001_dayanta1/regiontypeinfo.dat";
    const std::string npcPath = "map/5001_dayanta1/npc.dat";
    const std::string jumpBlockPath = "map/5001_dayanta1/jumpblock.dat";
    const std::string islandPath = "map/5001_dayanta1/island.dat";
    const std::string island2Path = "map/5001_dayanta1/island2.dat";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> configData = BuildMapConfigBin("5001_dayanta1");
    const std::vector<unsigned char> mazeData = BuildQuyuData();
    const std::vector<unsigned char> monsterData = BuildQuyuData();
    const std::vector<unsigned char> gotoData = BuildUtf16LeText(
        "<data><item posx=\"5\" posy=\"55\" destmap=\"5002\" destx=\"57\" desty=\"60\"/></data>");
    const std::vector<unsigned char> regionTypeData = BuildQuyuData();
    const std::vector<unsigned char> npcData = BuildUtf16LeText(
        "<data><npc id=\"1\" name=\"demo\" posx=\"10\" posy=\"20\"/></data>");
    const std::vector<unsigned char> jumpBlockData = BuildQuyuData();
    const std::vector<unsigned char> islandData = BuildQuyuData();
    const std::vector<unsigned char> island2Data = BuildQuyuData();

    const unsigned int configPathCrc =
        SLJFP_crc32(0, (const unsigned char*)configPath.data(), (unsigned int)configPath.size());
    const unsigned int mazePathCrc =
        SLJFP_crc32(0, (const unsigned char*)mazePath.data(), (unsigned int)mazePath.size());
    const unsigned int monsterPathCrc =
        SLJFP_crc32(0, (const unsigned char*)monsterPath.data(), (unsigned int)monsterPath.size());
    const unsigned int gotoPathCrc =
        SLJFP_crc32(0, (const unsigned char*)gotoPath.data(), (unsigned int)gotoPath.size());
    const unsigned int regionTypePathCrc =
        SLJFP_crc32(0, (const unsigned char*)regionTypePath.data(), (unsigned int)regionTypePath.size());
    const unsigned int npcPathCrc =
        SLJFP_crc32(0, (const unsigned char*)npcPath.data(), (unsigned int)npcPath.size());
    const unsigned int jumpBlockPathCrc =
        SLJFP_crc32(0, (const unsigned char*)jumpBlockPath.data(), (unsigned int)jumpBlockPath.size());
    const unsigned int islandPathCrc =
        SLJFP_crc32(0, (const unsigned char*)islandPath.data(), (unsigned int)islandPath.size());
    const unsigned int island2PathCrc =
        SLJFP_crc32(0, (const unsigned char*)island2Path.data(), (unsigned int)island2Path.size());

    const unsigned int configDataCrc =
        SLJFP_crc32(0, configData.data(), (unsigned int)configData.size());
    const unsigned int mazeDataCrc =
        SLJFP_crc32(0, mazeData.data(), (unsigned int)mazeData.size());
    const unsigned int monsterDataCrc =
        SLJFP_crc32(0, monsterData.data(), (unsigned int)monsterData.size());
    const unsigned int gotoDataCrc =
        SLJFP_crc32(0, gotoData.data(), (unsigned int)gotoData.size());
    const unsigned int regionTypeDataCrc =
        SLJFP_crc32(0, regionTypeData.data(), (unsigned int)regionTypeData.size());
    const unsigned int npcDataCrc =
        SLJFP_crc32(0, npcData.data(), (unsigned int)npcData.size());
    const unsigned int jumpBlockDataCrc =
        SLJFP_crc32(0, jumpBlockData.data(), (unsigned int)jumpBlockData.size());
    const unsigned int islandDataCrc =
        SLJFP_crc32(0, islandData.data(), (unsigned int)islandData.size());
    const unsigned int island2DataCrc =
        SLJFP_crc32(0, island2Data.data(), (unsigned int)island2Data.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(configPathCrc), configData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mazePathCrc), mazeData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(monsterPathCrc), monsterData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(gotoPathCrc), gotoData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(regionTypePathCrc), regionTypeData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(npcPathCrc), npcData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(jumpBlockPathCrc), jumpBlockData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(islandPathCrc), islandData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(island2PathCrc), island2Data));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 9);

    const unsigned int sizes[] = {
        (unsigned int)configData.size(),
        (unsigned int)mazeData.size(),
        (unsigned int)monsterData.size(),
        (unsigned int)gotoData.size(),
        (unsigned int)regionTypeData.size(),
        (unsigned int)npcData.size(),
        (unsigned int)jumpBlockData.size(),
        (unsigned int)islandData.size(),
        (unsigned int)island2Data.size()
    };
    const unsigned int dataCrcs[] = {
        configDataCrc,
        mazeDataCrc,
        monsterDataCrc,
        gotoDataCrc,
        regionTypeDataCrc,
        npcDataCrc,
        jumpBlockDataCrc,
        islandDataCrc,
        island2DataCrc
    };
    const unsigned int pathCrcs[] = {
        configPathCrc,
        mazePathCrc,
        monsterPathCrc,
        gotoPathCrc,
        regionTypePathCrc,
        npcPathCrc,
        jumpBlockPathCrc,
        islandPathCrc,
        island2PathCrc
    };

    for (int i = 0; i < 9; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << configPathCrc << "|" << configPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredConfig;
    std::vector<unsigned char> restoredMaze;
    std::vector<unsigned char> restoredMonster;
    std::vector<unsigned char> restoredGoto;
    std::vector<unsigned char> restoredRegionType;
    std::vector<unsigned char> restoredNpc;
    std::vector<unsigned char> restoredJumpBlock;
    std::vector<unsigned char> restoredIsland;
    std::vector<unsigned char> restoredIsland2;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + configPath, restoredConfig));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + mazePath, restoredMaze));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + monsterPath, restoredMonster));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + gotoPath, restoredGoto));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + regionTypePath, restoredRegionType));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + npcPath, restoredNpc));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + jumpBlockPath, restoredJumpBlock));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + islandPath, restoredIsland));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + island2Path, restoredIsland2));
    TEST_ASSERT_EQ(configData.size(), restoredConfig.size());
    TEST_ASSERT_EQ(mazeData.size(), restoredMaze.size());
    TEST_ASSERT_EQ(monsterData.size(), restoredMonster.size());
    TEST_ASSERT_EQ(gotoData.size(), restoredGoto.size());
    TEST_ASSERT_EQ(regionTypeData.size(), restoredRegionType.size());
    TEST_ASSERT_EQ(npcData.size(), restoredNpc.size());
    TEST_ASSERT_EQ(jumpBlockData.size(), restoredJumpBlock.size());
    TEST_ASSERT_EQ(islandData.size(), restoredIsland.size());
    TEST_ASSERT_EQ(island2Data.size(), restoredIsland2.size());
    TEST_ASSERT_MEM_EQ(configData.data(), restoredConfig.data(), configData.size());
    TEST_ASSERT_MEM_EQ(mazeData.data(), restoredMaze.data(), mazeData.size());
    TEST_ASSERT_MEM_EQ(monsterData.data(), restoredMonster.data(), monsterData.size());
    TEST_ASSERT_MEM_EQ(gotoData.data(), restoredGoto.data(), gotoData.size());
    TEST_ASSERT_MEM_EQ(regionTypeData.data(),
                       restoredRegionType.data(),
                       regionTypeData.size());
    TEST_ASSERT_MEM_EQ(npcData.data(), restoredNpc.data(), npcData.size());
    TEST_ASSERT_MEM_EQ(jumpBlockData.data(), restoredJumpBlock.data(), jumpBlockData.size());
    TEST_ASSERT_MEM_EQ(islandData.data(), restoredIsland.data(), islandData.size());
    TEST_ASSERT_MEM_EQ(island2Data.data(), restoredIsland2.data(), island2Data.size());

    std::vector<unsigned char> leftoverMaze;
    std::vector<unsigned char> leftoverMonster;
    std::vector<unsigned char> leftoverGoto;
    std::vector<unsigned char> leftoverRegionType;
    std::vector<unsigned char> leftoverNpc;
    std::vector<unsigned char> leftoverJumpBlock;
    std::vector<unsigned char> leftoverIsland;
    std::vector<unsigned char> leftoverIsland2;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(mazePathCrc) + ".dat", leftoverMaze));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(monsterPathCrc) + ".dat", leftoverMonster));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(gotoPathCrc) + ".xml", leftoverGoto));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(regionTypePathCrc) + ".dat",
                                   leftoverRegionType));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(npcPathCrc) + ".xml", leftoverNpc));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(jumpBlockPathCrc) + ".dat",
                                   leftoverJumpBlock));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(islandPathCrc) + ".dat",
                                   leftoverIsland));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(island2PathCrc) + ".dat",
                                   leftoverIsland2));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreKnownGameTableBinaryWithoutExternalMapping) {
    const std::string baseDir = "test_output/unpacker_known_gametable_bin_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string knownBinPath = "table/bintable/battle.cbattleaiconfig.bin";
    const std::string unknownBinPath = "table/bintable/demo.notregistered.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> knownBinData =
        BuildUtf8Text("LDZYKNOWN_BATTLE_AI_CONFIG");
    const std::vector<unsigned char> unknownBinData =
        BuildUtf8Text("LDZYUNREGISTERED_TABLE_DATA");

    const unsigned int knownBinPathCrc =
        SLJFP_crc32(0, (const unsigned char*)knownBinPath.data(), (unsigned int)knownBinPath.size());
    const unsigned int unknownBinPathCrc =
        SLJFP_crc32(0, (const unsigned char*)unknownBinPath.data(), (unsigned int)unknownBinPath.size());
    const unsigned int knownBinDataCrc =
        SLJFP_crc32(0, knownBinData.data(), (unsigned int)knownBinData.size());
    const unsigned int unknownBinDataCrc =
        SLJFP_crc32(0, unknownBinData.data(), (unsigned int)unknownBinData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(knownBinPathCrc), knownBinData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(unknownBinPathCrc), unknownBinData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)knownBinData.size());
    AppendUInt32Le(indexData, knownBinDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, knownBinPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)unknownBinData.size());
    AppendUInt32Le(indexData, unknownBinDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, unknownBinPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredKnownBin;
    std::vector<unsigned char> stillNumericUnknownBin;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + knownBinPath, restoredKnownBin));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + std::to_string(unknownBinPathCrc) + ".bin",
                                  stillNumericUnknownBin));
    TEST_ASSERT_EQ(knownBinData.size(), restoredKnownBin.size());
    TEST_ASSERT_EQ(unknownBinData.size(), stillNumericUnknownBin.size());
    TEST_ASSERT_MEM_EQ(knownBinData.data(), restoredKnownBin.data(), knownBinData.size());
    TEST_ASSERT_MEM_EQ(unknownBinData.data(), stillNumericUnknownBin.data(), unknownBinData.size());

    std::vector<unsigned char> leftoverKnownBin;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(knownBinPathCrc) + ".bin",
                                   leftoverKnownBin));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreMapResourcesWhenConfigUsesStructuredNonNumericResdirNames) {
    const std::string baseDir = "test_output/unpacker_map_restore_from_structured_non_numeric_resdir";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string configPath = "table/bintable/map.cmapconfig.bin";
    const std::string yunmengRegionPath = "map/map_1601_yunmengze/regiontypeinfo.dat";
    const std::string yunmengIslandPath = "map/map_1601_yunmengze/island.dat";
    const std::string zichenIslandPath = "map/zichen1/island.dat";
    const std::string zichenJumpBlockPath = "map/zichen1/jumpblock.dat";
    const std::string zichenIsland2Path = "map/zichen1/island2.dat";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    std::vector<std::string> resdirs;
    resdirs.push_back("map_1601_yunmengze");
    resdirs.push_back("zichen1");
    const std::vector<unsigned char> configData = BuildMapConfigBinRows(resdirs);
    const std::vector<unsigned char> yunmengRegionData = BuildQuyuData();
    const std::vector<unsigned char> yunmengIslandData = BuildUtf8Text("YUNMENGZE_ISLAND_PAYLOAD");
    const std::vector<unsigned char> zichenIslandData = BuildUtf8Text("ZICHEN_ISLAND_PAYLOAD");
    const std::vector<unsigned char> zichenJumpBlockData = BuildQuyuData();
    const std::vector<unsigned char> zichenIsland2Data = BuildQuyuData();

    const unsigned int configPathCrc =
        SLJFP_crc32(0, (const unsigned char*)configPath.data(), (unsigned int)configPath.size());
    const unsigned int yunmengRegionPathCrc =
        SLJFP_crc32(0, (const unsigned char*)yunmengRegionPath.data(), (unsigned int)yunmengRegionPath.size());
    const unsigned int yunmengIslandPathCrc =
        SLJFP_crc32(0, (const unsigned char*)yunmengIslandPath.data(), (unsigned int)yunmengIslandPath.size());
    const unsigned int zichenIslandPathCrc =
        SLJFP_crc32(0, (const unsigned char*)zichenIslandPath.data(), (unsigned int)zichenIslandPath.size());
    const unsigned int zichenJumpBlockPathCrc =
        SLJFP_crc32(0, (const unsigned char*)zichenJumpBlockPath.data(), (unsigned int)zichenJumpBlockPath.size());
    const unsigned int zichenIsland2PathCrc =
        SLJFP_crc32(0, (const unsigned char*)zichenIsland2Path.data(), (unsigned int)zichenIsland2Path.size());

    const unsigned int configDataCrc =
        SLJFP_crc32(0, configData.data(), (unsigned int)configData.size());
    const unsigned int yunmengRegionDataCrc =
        SLJFP_crc32(0, yunmengRegionData.data(), (unsigned int)yunmengRegionData.size());
    const unsigned int yunmengIslandDataCrc =
        SLJFP_crc32(0, yunmengIslandData.data(), (unsigned int)yunmengIslandData.size());
    const unsigned int zichenIslandDataCrc =
        SLJFP_crc32(0, zichenIslandData.data(), (unsigned int)zichenIslandData.size());
    const unsigned int zichenJumpBlockDataCrc =
        SLJFP_crc32(0, zichenJumpBlockData.data(), (unsigned int)zichenJumpBlockData.size());
    const unsigned int zichenIsland2DataCrc =
        SLJFP_crc32(0, zichenIsland2Data.data(), (unsigned int)zichenIsland2Data.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(configPathCrc), configData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(yunmengRegionPathCrc), yunmengRegionData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(yunmengIslandPathCrc), yunmengIslandData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(zichenIslandPathCrc), zichenIslandData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(zichenJumpBlockPathCrc), zichenJumpBlockData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(zichenIsland2PathCrc), zichenIsland2Data));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 6);

    const unsigned int sizes[] = {
        (unsigned int)configData.size(),
        (unsigned int)yunmengRegionData.size(),
        (unsigned int)yunmengIslandData.size(),
        (unsigned int)zichenIslandData.size(),
        (unsigned int)zichenJumpBlockData.size(),
        (unsigned int)zichenIsland2Data.size()
    };
    const unsigned int dataCrcs[] = {
        configDataCrc,
        yunmengRegionDataCrc,
        yunmengIslandDataCrc,
        zichenIslandDataCrc,
        zichenJumpBlockDataCrc,
        zichenIsland2DataCrc
    };
    const unsigned int pathCrcs[] = {
        configPathCrc,
        yunmengRegionPathCrc,
        yunmengIslandPathCrc,
        zichenIslandPathCrc,
        zichenJumpBlockPathCrc,
        zichenIsland2PathCrc
    };

    for (int i = 0; i < 6; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << configPathCrc << "|" << configPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredConfig;
    std::vector<unsigned char> restoredYunmengRegion;
    std::vector<unsigned char> restoredYunmengIsland;
    std::vector<unsigned char> restoredZichenIsland;
    std::vector<unsigned char> restoredZichenJump;
    std::vector<unsigned char> restoredZichenIsland2;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + configPath, restoredConfig));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + yunmengRegionPath, restoredYunmengRegion));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + yunmengIslandPath, restoredYunmengIsland));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + zichenIslandPath, restoredZichenIsland));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + zichenJumpBlockPath, restoredZichenJump));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + zichenIsland2Path, restoredZichenIsland2));
    TEST_ASSERT_MEM_EQ(configData.data(), restoredConfig.data(), configData.size());
    TEST_ASSERT_MEM_EQ(yunmengRegionData.data(), restoredYunmengRegion.data(), yunmengRegionData.size());
    TEST_ASSERT_MEM_EQ(yunmengIslandData.data(), restoredYunmengIsland.data(), yunmengIslandData.size());
    TEST_ASSERT_MEM_EQ(zichenIslandData.data(), restoredZichenIsland.data(), zichenIslandData.size());
    TEST_ASSERT_MEM_EQ(zichenJumpBlockData.data(), restoredZichenJump.data(), zichenJumpBlockData.size());
    TEST_ASSERT_MEM_EQ(zichenIsland2Data.data(), restoredZichenIsland2.data(), zichenIsland2Data.size());

    std::vector<unsigned char> leftoverYunmengRegion;
    std::vector<unsigned char> leftoverYunmengIsland;
    std::vector<unsigned char> leftoverZichenIsland;
    std::vector<unsigned char> leftoverZichenJump;
    std::vector<unsigned char> leftoverZichenIsland2;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(yunmengRegionPathCrc) + ".dat", leftoverYunmengRegion));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(yunmengIslandPathCrc), leftoverYunmengIsland));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(zichenIslandPathCrc), leftoverZichenIsland));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(zichenJumpBlockPathCrc) + ".dat", leftoverZichenJump));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(zichenIsland2PathCrc) + ".dat", leftoverZichenIsland2));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreTableBinaryFromTextualBeanConfigReference) {
    const std::string baseDir = "test_output/unpacker_textual_beanconfig_bin_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string referencePath = "notes/beanconfig_reference.txt";
    const std::string targetBinPath = "table/bintable/item.cguaguale.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> referenceData =
        BuildUtf8Text("<root>BeanConfigManager.getInstance():GetTableByName(\"item.cguaguale\")</root>");
    const std::vector<unsigned char> targetBinData =
        BuildUtf8Text("LDZY_CGUAGUALE_TABLE");

    const unsigned int referencePathCrc =
        SLJFP_crc32(0, (const unsigned char*)referencePath.data(), (unsigned int)referencePath.size());
    const unsigned int targetBinPathCrc =
        SLJFP_crc32(0, (const unsigned char*)targetBinPath.data(), (unsigned int)targetBinPath.size());
    const unsigned int referenceDataCrc =
        SLJFP_crc32(0, referenceData.data(), (unsigned int)referenceData.size());
    const unsigned int targetBinDataCrc =
        SLJFP_crc32(0, targetBinData.data(), (unsigned int)targetBinData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(referencePathCrc), referenceData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(targetBinPathCrc), targetBinData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)referenceData.size());
    AppendUInt32Le(indexData, referenceDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, referencePathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)targetBinData.size());
    AppendUInt32Le(indexData, targetBinDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, targetBinPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredTargetBin;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + targetBinPath, restoredTargetBin));
    TEST_ASSERT_EQ(targetBinData.size(), restoredTargetBin.size());
    TEST_ASSERT_MEM_EQ(targetBinData.data(), restoredTargetBin.data(), targetBinData.size());

    std::vector<unsigned char> leftoverTargetBin;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(targetBinPathCrc) + ".bin",
                                   leftoverTargetBin));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreUiLayoutFromLuaLiteralReference) {
    const std::string baseDir = "test_output/unpacker_ui_layout_literal_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string scriptPath = "script/logic/demo.lua";
    const std::string layoutPath = "ui/layouts/addcashdlg.layout";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> scriptData = BuildUtf8Text(
        "local layoutName = \"addcashdlg.layout\"\n"
        "return layoutName\n");
    const std::vector<unsigned char> layoutData = BuildUtf8Text(
        "<GUILayout>\n"
        "  <Window Type=\"TaharezLook/Button\" Name=\"some_other_root\"/>\n"
        "</GUILayout>\n");

    const unsigned int scriptPathCrc =
        SLJFP_crc32(0, (const unsigned char*)scriptPath.data(), (unsigned int)scriptPath.size());
    const unsigned int layoutPathCrc =
        SLJFP_crc32(0, (const unsigned char*)layoutPath.data(), (unsigned int)layoutPath.size());
    const unsigned int scriptDataCrc =
        SLJFP_crc32(0, scriptData.data(), (unsigned int)scriptData.size());
    const unsigned int layoutDataCrc =
        SLJFP_crc32(0, layoutData.data(), (unsigned int)layoutData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(scriptPathCrc), scriptData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(layoutPathCrc), layoutData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)scriptData.size());
    AppendUInt32Le(indexData, scriptDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, scriptPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)layoutData.size());
    AppendUInt32Le(indexData, layoutDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, layoutPathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << scriptPathCrc << "|" << scriptPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredScript;
    std::vector<unsigned char> restoredLayout;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + scriptPath, restoredScript));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + layoutPath, restoredLayout));
    TEST_ASSERT_EQ(scriptData.size(), restoredScript.size());
    TEST_ASSERT_EQ(layoutData.size(), restoredLayout.size());
    TEST_ASSERT_MEM_EQ(scriptData.data(), restoredScript.data(), scriptData.size());
    TEST_ASSERT_MEM_EQ(layoutData.data(), restoredLayout.data(), layoutData.size());

    std::vector<unsigned char> leftoverLayout;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(layoutPathCrc) + ".layout",
                                   leftoverLayout));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, ReconcileUniqueExactDuplicateRootOutputs) {
    const std::string baseDir = "test_output/unpacker_unique_duplicate_reconcile";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedAniPath = "model/demo/body/bodyonly/stand1.ani";
    const std::string namedPngPath = "model/demo/body/bodyonly/stand1_res000.png";
    const std::string duplicateAniPath = "model/demo_alias/body/bodyonly/stand1.ani";
    const std::string duplicatePngPath = "model/demo_alias/body/bodyonly/stand1_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"stand1_res000.png");
    const std::vector<unsigned char> pngData = BuildTinyPng();

    const unsigned int namedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath.data(), (unsigned int)namedAniPath.size());
    const unsigned int namedPngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedPngPath.data(), (unsigned int)namedPngPath.size());
    const unsigned int duplicateAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)duplicateAniPath.data(), (unsigned int)duplicateAniPath.size());
    const unsigned int duplicatePngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)duplicatePngPath.data(), (unsigned int)duplicatePngPath.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedPngPathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(duplicateAniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(duplicatePngPathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 4);

    const unsigned int sizes[] = {
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size(),
        (unsigned int)aniData.size(),
        (unsigned int)pngData.size()
    };
    const unsigned int dataCrcs[] = {
        aniDataCrc,
        pngDataCrc,
        aniDataCrc,
        pngDataCrc
    };
    const unsigned int pathCrcs[] = {
        namedAniPathCrc,
        namedPngPathCrc,
        duplicateAniPathCrc,
        duplicatePngPathCrc
    };

    for (int i = 0; i < 4; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedAniPathCrc << "|" << namedAniPath << "\n";
        mappingFile << namedPngPathCrc << "|" << namedPngPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredNamedAni;
    std::vector<unsigned char> restoredNamedPng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedAniPath, restoredNamedAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedPngPath, restoredNamedPng));
    TEST_ASSERT_EQ(aniData.size(), restoredNamedAni.size());
    TEST_ASSERT_EQ(pngData.size(), restoredNamedPng.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredNamedAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredNamedPng.data(), pngData.size());

    std::vector<unsigned char> leftoverDuplicateAni;
    std::vector<unsigned char> leftoverDuplicatePng;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(duplicateAniPathCrc) + ".ani",
                                   leftoverDuplicateAni));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(duplicatePngPathCrc) + ".png",
                                   leftoverDuplicatePng));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, PruneAmbiguousExactDuplicateRootOutputs) {
    const std::string baseDir = "test_output/unpacker_ambiguous_duplicate_reconcile";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedPngPath1 = "model/demo/body/bodyonly/stand1_res000.png";
    const std::string namedPngPath2 = "model/demo_variant/body/bodyonly/stand1_res000.png";
    const std::string duplicatePngPath = "model/demo_alias/body/bodyonly/stand1_res000.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> pngData = BuildTinyPng();
    const unsigned int namedPngPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)namedPngPath1.data(), (unsigned int)namedPngPath1.size());
    const unsigned int namedPngPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)namedPngPath2.data(), (unsigned int)namedPngPath2.size());
    const unsigned int duplicatePngPathCrc =
        SLJFP_crc32(0, (const unsigned char*)duplicatePngPath.data(), (unsigned int)duplicatePngPath.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedPngPathCrc1), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedPngPathCrc2), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(duplicatePngPathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    const unsigned int pathCrcs[] = {
        namedPngPathCrc1,
        namedPngPathCrc2,
        duplicatePngPathCrc
    };

    for (int i = 0; i < 3; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, (unsigned int)pngData.size());
        AppendUInt32Le(indexData, pngDataCrc);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedPngPathCrc1 << "|" << namedPngPath1 << "\n";
        mappingFile << namedPngPathCrc2 << "|" << namedPngPath2 << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredNamedPng1;
    std::vector<unsigned char> restoredNamedPng2;
    std::vector<unsigned char> leftoverDuplicatePng;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedPngPath1, restoredNamedPng1));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedPngPath2, restoredNamedPng2));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(duplicatePngPathCrc) + ".png",
                                   leftoverDuplicatePng));
    TEST_ASSERT_EQ(pngData.size(), restoredNamedPng1.size());
    TEST_ASSERT_EQ(pngData.size(), restoredNamedPng2.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredNamedPng1.data(), pngData.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredNamedPng2.data(), pngData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, PruneNonAniPngExactDuplicateRootOutputs) {
    const std::string baseDir = "test_output/unpacker_generic_duplicate_prune";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedActPath = "model/demo/action/stand1.act";
    const std::string duplicateActPath = "model/demo_alias/action/stand1.act";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    std::vector<unsigned char> actData;
    actData.push_back(0x41);
    actData.push_back(0x43);
    actData.push_back(0x54);
    actData.push_back(0x00);
    actData.push_back(0x01);
    actData.push_back(0x02);
    actData.push_back(0x03);
    actData.push_back(0x04);

    const unsigned int namedActPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedActPath.data(), (unsigned int)namedActPath.size());
    const unsigned int duplicateActPathCrc =
        SLJFP_crc32(0, (const unsigned char*)duplicateActPath.data(), (unsigned int)duplicateActPath.size());
    const unsigned int actDataCrc =
        SLJFP_crc32(0, actData.data(), (unsigned int)actData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedActPathCrc), actData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(duplicateActPathCrc), actData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);
    const unsigned int pathCrcs[] = {
        namedActPathCrc,
        duplicateActPathCrc
    };
    for (int i = 0; i < 2; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, (unsigned int)actData.size());
        AppendUInt32Le(indexData, actDataCrc);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedActPathCrc << "|" << namedActPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredNamedAct;
    std::vector<unsigned char> leftoverDuplicateAct;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedActPath, restoredNamedAct));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(duplicateActPathCrc) + ".act",
                                   leftoverDuplicateAct));
    TEST_ASSERT_EQ(actData.size(), restoredNamedAct.size());
    TEST_ASSERT_MEM_EQ(actData.data(), restoredNamedAct.data(), actData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreScriptPathsFromLuaRequireModuleReferences) {
    const std::string baseDir = "test_output/unpacker_script_module_require_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string refScriptPath = "script/logic/demo/loader.lua";
    const std::string targetScriptPath1 = "script/logic/waiguan/peticoncell.lua";
    const std::string targetScriptPath2 = "script/tabledef/role/createroleconfig.lua";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> refScriptData = BuildUtf8Text(
        "local PetIconCell = require \"logic.waiguan.peticoncell\"\n"
        "local cfg = require \"script.tabledef.role.createroleconfig\"\n"
        "return PetIconCell, cfg\n");
    const std::vector<unsigned char> targetScriptData1 = BuildUtf8Text(
        "require \"logic.dialog\"\n"
        "PetIconCell = {}\n"
        "return PetIconCell\n");
    const std::vector<unsigned char> targetScriptData2 = BuildUtf8Text(
        "CreateRoleConfig = {}\n"
        "return CreateRoleConfig\n");

    const unsigned int refScriptPathCrc =
        SLJFP_crc32(0, (const unsigned char*)refScriptPath.data(), (unsigned int)refScriptPath.size());
    const unsigned int targetScriptPathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)targetScriptPath1.data(), (unsigned int)targetScriptPath1.size());
    const unsigned int targetScriptPathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)targetScriptPath2.data(), (unsigned int)targetScriptPath2.size());
    const unsigned int refScriptDataCrc =
        SLJFP_crc32(0, refScriptData.data(), (unsigned int)refScriptData.size());
    const unsigned int targetScriptDataCrc1 =
        SLJFP_crc32(0, targetScriptData1.data(), (unsigned int)targetScriptData1.size());
    const unsigned int targetScriptDataCrc2 =
        SLJFP_crc32(0, targetScriptData2.data(), (unsigned int)targetScriptData2.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(refScriptPathCrc), refScriptData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(targetScriptPathCrc1), targetScriptData1));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(targetScriptPathCrc2), targetScriptData2));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);
    const unsigned int sizes[] = {
        (unsigned int)refScriptData.size(),
        (unsigned int)targetScriptData1.size(),
        (unsigned int)targetScriptData2.size()
    };
    const unsigned int dataCrcs[] = {
        refScriptDataCrc,
        targetScriptDataCrc1,
        targetScriptDataCrc2
    };
    const unsigned int pathCrcs[] = {
        refScriptPathCrc,
        targetScriptPathCrc1,
        targetScriptPathCrc2
    };
    for (int i = 0; i < 3; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << refScriptPathCrc << "|" << refScriptPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredRefScript;
    std::vector<unsigned char> restoredTargetScript1;
    std::vector<unsigned char> restoredTargetScript2;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + refScriptPath, restoredRefScript));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + targetScriptPath1, restoredTargetScript1));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + targetScriptPath2, restoredTargetScript2));
    TEST_ASSERT_EQ(targetScriptData1.size(), restoredTargetScript1.size());
    TEST_ASSERT_EQ(targetScriptData2.size(), restoredTargetScript2.size());
    TEST_ASSERT_MEM_EQ(targetScriptData1.data(), restoredTargetScript1.data(), targetScriptData1.size());
    TEST_ASSERT_MEM_EQ(targetScriptData2.data(), restoredTargetScript2.data(), targetScriptData2.size());

    std::vector<unsigned char> leftoverTargetScript1;
    std::vector<unsigned char> leftoverTargetScript2;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(targetScriptPathCrc1) + ".lua",
                                   leftoverTargetScript1));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(targetScriptPathCrc2) + ".lua",
                                   leftoverTargetScript2));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreUiLayoutFromRootWindowNameHeuristic) {
    const std::string baseDir = "test_output/unpacker_ui_layout_root_name_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string layoutPath = "ui/layouts/jingmai232.layout";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> layoutData = BuildUtf8Text(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "<GUILayout>\n"
        "    <Window Type=\"TaharezLook/StaticImage\" Name=\"jingmai232/diban\">\n"
        "        <Property Name=\"LuaForDialog\" Value=\"True\" />\n"
        "    </Window>\n"
        "</GUILayout>\n");
    const unsigned int layoutPathCrc =
        SLJFP_crc32(0, (const unsigned char*)layoutPath.data(), (unsigned int)layoutPath.size());
    const unsigned int layoutDataCrc =
        SLJFP_crc32(0, layoutData.data(), (unsigned int)layoutData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(layoutPathCrc), layoutData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)layoutData.size());
    AppendUInt32Le(indexData, layoutDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, layoutPathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredLayout;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + layoutPath, restoredLayout));
    TEST_ASSERT_EQ(layoutData.size(), restoredLayout.size());
    TEST_ASSERT_MEM_EQ(layoutData.data(), restoredLayout.data(), layoutData.size());

    std::vector<unsigned char> leftoverLayout;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(layoutPathCrc) + ".xml",
                                   leftoverLayout));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, PruneXmlDuplicateAgainstNamedLmxOutputs) {
    const std::string baseDir = "test_output/unpacker_xml_lmx_duplicate_prune";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedLmxPath = "model/demo/action/action.lmx";
    const std::string duplicateLmxPath = "model/demo_alias/action/action.lmx";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> lmxData = BuildUtf8Text(
        "<data>\n"
        "    <action name=\"attack1\"/>\n"
        "    <action name=\"stand1\"/>\n"
        "</data>\n");

    const unsigned int namedLmxPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedLmxPath.data(), (unsigned int)namedLmxPath.size());
    const unsigned int duplicateLmxPathCrc =
        SLJFP_crc32(0, (const unsigned char*)duplicateLmxPath.data(), (unsigned int)duplicateLmxPath.size());
    const unsigned int lmxDataCrc =
        SLJFP_crc32(0, lmxData.data(), (unsigned int)lmxData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedLmxPathCrc), lmxData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(duplicateLmxPathCrc), lmxData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);
    const unsigned int pathCrcs[] = {
        namedLmxPathCrc,
        duplicateLmxPathCrc
    };
    for (int i = 0; i < 2; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, (unsigned int)lmxData.size());
        AppendUInt32Le(indexData, lmxDataCrc);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedLmxPathCrc << "|" << namedLmxPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredNamedLmx;
    std::vector<unsigned char> leftoverDuplicateXml;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedLmxPath, restoredNamedLmx));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(duplicateLmxPathCrc) + ".xml",
                                   leftoverDuplicateXml));
    TEST_ASSERT_EQ(lmxData.size(), restoredNamedLmx.size());
    TEST_ASSERT_MEM_EQ(lmxData.data(), restoredNamedLmx.data(), lmxData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, SanitizeBomMappingPathAndKeepOutputUnderRoot) {
    const std::string baseDir = "test_output/unpacker_mapping_path_sanitize";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string rawMappedPath = "../assets\\bad?.txt";
    const std::string safeMappedPath = "bad_.txt";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("sanitized-path");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)rawMappedPath.data(), (unsigned int)rawMappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        const unsigned char bom[] = { 0xEF, 0xBB, 0xBF };
        mappingFile.write((const char*)bom, sizeof(bom));
        mappingFile << pathCrc << "|" << rawMappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredData;
    std::vector<unsigned char> escapedData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + safeMappedPath, restoredData));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/assets/bad_.txt", escapedData));
    TEST_ASSERT_FALSE(ReadTestFile(baseDir + "/assets/bad_.txt", escapedData));
    TEST_ASSERT_EQ(fileData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredData.data(), fileData.size());

    const std::string manifestText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.tsv");
    const std::string manifestJsonText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.json");
    TEST_ASSERT_FALSE(manifestText.empty());
    TEST_ASSERT_FALSE(manifestJsonText.empty());
    TEST_ASSERT_NE(std::string::npos, manifestText.find("raw_mapping_path"));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(rawMappedPath));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(safeMappedPath));
    TEST_ASSERT_NE(std::string::npos, manifestText.find("mapping_sanitized"));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("\"files\""));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find(safeMappedPath));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("mapping_sanitized"));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, WriteConflictSuffixWhenMappingsSanitizeToSamePath) {
    const std::string baseDir = "test_output/unpacker_mapping_conflict_suffix";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string rawPath1 = "ui/dup?.txt";
    const std::string rawPath2 = "ui/dup*.txt";
    const std::string safePath = "ui/dup_.txt";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData1 = BuildUtf8Text("first-version");
    const std::vector<unsigned char> fileData2 = BuildUtf8Text("second-version");
    const unsigned int pathCrc1 =
        SLJFP_crc32(0, (const unsigned char*)rawPath1.data(), (unsigned int)rawPath1.size());
    const unsigned int pathCrc2 =
        SLJFP_crc32(0, (const unsigned char*)rawPath2.data(), (unsigned int)rawPath2.size());
    const unsigned int dataCrc1 =
        SLJFP_crc32(0, fileData1.data(), (unsigned int)fileData1.size());
    const unsigned int dataCrc2 =
        SLJFP_crc32(0, fileData2.data(), (unsigned int)fileData2.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc1), fileData1));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc2), fileData2));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData1.size());
    AppendUInt32Le(indexData, dataCrc1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData2.size());
    AppendUInt32Le(indexData, dataCrc2);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc2);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc1 << "|" << rawPath1 << "\n";
        mappingFile << pathCrc2 << "|" << rawPath2 << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string conflictPath = BuildExpectedConflictPath(safePath, pathCrc2);
    std::vector<unsigned char> restoredPrimary;
    std::vector<unsigned char> restoredConflict;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + safePath, restoredPrimary));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + conflictPath, restoredConflict));
    TEST_ASSERT_EQ(fileData1.size(), restoredPrimary.size());
    TEST_ASSERT_EQ(fileData2.size(), restoredConflict.size());
    TEST_ASSERT_MEM_EQ(fileData1.data(), restoredPrimary.data(), fileData1.size());
    TEST_ASSERT_MEM_EQ(fileData2.data(), restoredConflict.data(), fileData2.size());

    const std::string manifestText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.tsv");
    const std::string manifestJsonText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.json");
    TEST_ASSERT_FALSE(manifestText.empty());
    TEST_ASSERT_FALSE(manifestJsonText.empty());
    TEST_ASSERT_NE(std::string::npos, manifestText.find(rawPath1));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(rawPath2));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(safePath));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(conflictPath));
    TEST_ASSERT_NE(std::string::npos, manifestText.find("conflict_suffix"));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("\"files\""));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find(safePath));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find(conflictPath));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("conflict_suffix"));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, KeepExistingFileWhenOverwriteDisabledAndWriteConflictCopy) {
    const std::string baseDir = "test_output/unpacker_existing_file_conflict";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string rawPath = "ui/preserve.txt";
    const std::string safePath = "ui/preserve.txt";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir + "/ui"));

    const std::vector<unsigned char> existingData = BuildUtf8Text("already-there");
    const std::vector<unsigned char> unpackedData = BuildUtf8Text("newly-unpacked");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)rawPath.data(), (unsigned int)rawPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, unpackedData.data(), (unsigned int)unpackedData.size());

    TEST_ASSERT_TRUE(CreateTestFile(outputDir + "/" + safePath,
                                    existingData.data(),
                                    existingData.size()));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), unpackedData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)unpackedData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << rawPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = false;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string conflictPath = BuildExpectedConflictPath(safePath, pathCrc);
    std::vector<unsigned char> restoredExisting;
    std::vector<unsigned char> restoredConflict;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + safePath, restoredExisting));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + conflictPath, restoredConflict));
    TEST_ASSERT_EQ(existingData.size(), restoredExisting.size());
    TEST_ASSERT_EQ(unpackedData.size(), restoredConflict.size());
    TEST_ASSERT_MEM_EQ(existingData.data(), restoredExisting.data(), existingData.size());
    TEST_ASSERT_MEM_EQ(unpackedData.data(), restoredConflict.data(), unpackedData.size());

    const std::string manifestText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.tsv");
    const std::string manifestJsonText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.json");
    TEST_ASSERT_FALSE(manifestText.empty());
    TEST_ASSERT_FALSE(manifestJsonText.empty());
    TEST_ASSERT_NE(std::string::npos, manifestText.find(rawPath));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(safePath));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(conflictPath));
    TEST_ASSERT_NE(std::string::npos, manifestText.find("existing_target_preserved"));
    TEST_ASSERT_NE(std::string::npos, manifestText.find("conflict_suffix"));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("\"files\""));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find(safePath));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find(conflictPath));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("existing_target_preserved"));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("conflict_suffix"));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, ForceCrcOutputFirst_WritesRootNumericBeforeRestore) {
    const std::string baseDir = "test_output/unpacker_force_crc_output_first";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "ui/layouts/demo.layout";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("<GUILayout />");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = false;
    options.strictRestoreValidation = false;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredRoot;
    std::vector<unsigned char> restoredMapped;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + std::to_string(pathCrc), restoredRoot));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + mappedPath, restoredMapped));
    TEST_ASSERT_EQ(fileData.size(), restoredRoot.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredRoot.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreUiImagesetFromRootTagHeuristic) {
    const std::string baseDir = "test_output/unpacker_ui_imageset_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string imagesetPath = "ui/imagesets/fenxiang.imageset";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> imagesetData = BuildUtf8Text(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "<Imageset Name=\"fenxiang\" Imagefile=\"fenxiang.png\">\n"
        "    <Image Name=\"fenxiang_button\" XPos=\"0\" YPos=\"0\" Width=\"64\" Height=\"64\" />\n"
        "</Imageset>\n");
    const unsigned int imagesetPathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagesetPath.data(), (unsigned int)imagesetPath.size());
    const unsigned int imagesetDataCrc =
        SLJFP_crc32(0, imagesetData.data(), (unsigned int)imagesetData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagesetPathCrc), imagesetData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)imagesetData.size());
    AppendUInt32Le(indexData, imagesetDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagesetPathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredImageset;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagesetPath, restoredImageset));
    TEST_ASSERT_EQ(imagesetData.size(), restoredImageset.size());
    TEST_ASSERT_MEM_EQ(imagesetData.data(), restoredImageset.data(), imagesetData.size());

    std::vector<unsigned char> leftoverRootFile;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagesetPathCrc) + ".xml",
                                   leftoverRootFile));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, RestoreLuaPathFromRequireDirectoryAndSymbolName) {
    const std::string baseDir = "test_output/unpacker_lua_require_dir_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string scriptPath = "script/logic/ranse/zujiyichudlg.lua";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> scriptData = BuildUtf8Text(
        "require \"logic.dialog\"\n"
        "require \"logic.ranse.skinattrtipdlg\"\n"
        "require \"logic.ranse.waiguanattrDlg\"\n"
        "ZuJiYiChuDlg = {}\n"
        "ZuJiYiChuDlg.__index = ZuJiYiChuDlg\n");
    const unsigned int scriptPathCrc =
        SLJFP_crc32(0, (const unsigned char*)scriptPath.data(), (unsigned int)scriptPath.size());
    const unsigned int scriptDataCrc =
        SLJFP_crc32(0, scriptData.data(), (unsigned int)scriptData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(scriptPathCrc), scriptData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)scriptData.size());
    AppendUInt32Le(indexData, scriptDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, scriptPathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredScript;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + scriptPath, restoredScript));
    TEST_ASSERT_EQ(scriptData.size(), restoredScript.size());
    TEST_ASSERT_MEM_EQ(scriptData.data(), restoredScript.data(), scriptData.size());

    std::vector<unsigned char> leftoverRootFile;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(scriptPathCrc) + ".lua",
                                   leftoverRootFile));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, OutputPathManifestMarksTwoPhasePathMappingRestoreAsMapping) {
    const std::string baseDir = "test_output/unpacker_manifest_two_phase_mapping_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "cfg/android_notify.xml";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData =
        BuildUtf8Text("<notify platform=\"android\" />\n");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writePathManifest = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + mappedPath, restoredData));
    TEST_ASSERT_EQ(fileData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredData.data(), fileData.size());

    const std::vector<SLJFP::OutputPathManifestRecord> records =
        unpacker.GetLastOutputPathManifestRecords();
    TEST_ASSERT_EQ((size_t)1, records.size());
    TEST_ASSERT_EQ(pathCrc, records[0].pathCRC32);
    TEST_ASSERT_EQ((std::string)"mapping", records[0].sourceKind);
    TEST_ASSERT_EQ(mappedPath, records[0].rawMappingPath);
    TEST_ASSERT_EQ(mappedPath, records[0].normalizedRelativePath);
    TEST_ASSERT_EQ(std::to_string(pathCrc), records[0].writtenRelativePath);
    TEST_ASSERT_EQ(mappedPath, records[0].finalRelativePath);
    TEST_ASSERT_FALSE(records[0].mappingSanitized);
    TEST_ASSERT_FALSE(records[0].conflictResolved);
    TEST_ASSERT_FALSE(records[0].existingTargetPreserved);
    TEST_ASSERT_TRUE(records[0].postProcessMoved);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, OutputPathManifestJsonPreservesUtf8Paths) {
    const std::string baseDir = "test_output/unpacker_manifest_utf8_paths";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "cfg/中文/贴图.txt";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("utf8-json-manifest");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.writePathManifest = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> jsonBytes;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/unpack_path_manifest.json", jsonBytes));
    const std::string jsonText(jsonBytes.begin(), jsonBytes.end());
    TEST_ASSERT_TRUE(jsonText.find(mappedPath) != std::string::npos);
    TEST_ASSERT_TRUE(jsonText.find("\\u00E4") == std::string::npos);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, OutputPathManifestConvertsAcpMappingPathsToUtf8) {
    const std::string baseDir = "test_output/unpacker_manifest_acp_paths";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string acpPath = "ui/layouts/" + std::string("\xD0\xC2\xB5\xD8\xCD\xBC", 6) + ".layout";
    const std::string utf8Path = "ui/layouts/" + std::string("\xE6\x96\xB0\xE5\x9C\xB0\xE5\x9B\xBE", 9) + ".layout";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("acp-to-utf8-manifest");
    const unsigned int pathCrc =
        SLJFP_crc32(0, reinterpret_cast<const unsigned char*>(acpPath.data()),
                    (unsigned int)acpPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << acpPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.writePathManifest = true;
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::string manifestText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.tsv");
    const std::string manifestJsonText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.json");
    TEST_ASSERT_NE(std::string::npos, manifestText.find(utf8Path));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find(utf8Path));
    TEST_ASSERT_EQ(std::string::npos, manifestText.find(acpPath));
    TEST_ASSERT_EQ(std::string::npos, manifestJsonText.find(acpPath));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, OutputPathManifestTracksReviewBucketPhysicalPath) {
    const std::string baseDir = "test_output/unpacker_manifest_review_bucket_path";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("review-bucket-text");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)"script/unknown_asset.txt", 24);
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());
    const std::string inputNumericName = std::to_string(pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + inputNumericName, fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.relocateRootNumericResiduals = true;
    options.writePathManifest = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::vector<SLJFP::OutputPathManifestRecord> records =
        unpacker.GetLastOutputPathManifestRecords();
    TEST_ASSERT_EQ((size_t)1, records.size());
    TEST_ASSERT_TRUE(!records[0].writtenRelativePath.empty());
    TEST_ASSERT_TRUE(records[0].finalRelativePath.find("review/unresolved/") == 0);
    TEST_ASSERT_EQ(records[0].finalRelativePath, records[0].actualRelativePath);
    TEST_ASSERT_EQ((std::string)"review_unresolved_relocated", records[0].physicalPathStatus);
    TEST_ASSERT_TRUE(records[0].physicalExists);
    TEST_ASSERT_EQ(fileData.size(), (size_t)records[0].physicalSize);
    TEST_ASSERT_TRUE(records[0].extensionConsistent);
    TEST_ASSERT_TRUE(records[0].reviewBucketed);

    std::vector<unsigned char> reviewBytes;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + records[0].actualRelativePath, reviewBytes));
    TEST_ASSERT_EQ(fileData.size(), reviewBytes.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), reviewBytes.data(), fileData.size());

    const std::string manifestText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.tsv");
    TEST_ASSERT_NE(std::string::npos, manifestText.find("actual_relative_path"));
    TEST_ASSERT_NE(std::string::npos, manifestText.find("physical_path_status"));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(records[0].actualRelativePath));
    TEST_ASSERT_NE(std::string::npos, manifestText.find("review_unresolved_relocated"));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, OutputPathManifestTracksReviewBucketSuffixRestoredPath) {
    const std::string baseDir = "test_output/unpacker_manifest_review_bucket_suffix_restore";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string originalPath = "orphan/review_suffix_restore";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png", L"stand1");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)originalPath.data(), (unsigned int)originalPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), aniData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.relocateRootNumericResiduals = true;
    options.writePathManifest = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::vector<SLJFP::OutputPathManifestRecord> records =
        unpacker.GetLastOutputPathManifestRecords();
    TEST_ASSERT_EQ((size_t)1, records.size());
    TEST_ASSERT_EQ((std::string)"review_unresolved_relocated", records[0].physicalPathStatus);
    TEST_ASSERT_TRUE(records[0].physicalExists);
    TEST_ASSERT_TRUE(records[0].actualRelativePath.find("review/unresolved/ani/") == 0);
    TEST_ASSERT_TRUE(records[0].actualRelativePath.find(std::to_string(pathCrc) + ".ani") != std::string::npos);

    std::vector<unsigned char> reviewBytes;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + records[0].actualRelativePath, reviewBytes));
    TEST_ASSERT_EQ(aniData.size(), reviewBytes.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), reviewBytes.data(), aniData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, OutputPathManifestTracksContentDedupAlias) {
    const std::string baseDir = "test_output/unpacker_manifest_content_dedup_alias";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "model/demo/body/bodyonly/stand1_res000.png";
    const std::string duplicateOriginalPath = "misc/duplicate_same_png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> pngData = BuildTinyPng();
    const unsigned int mappedPathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int duplicatePathCrc =
        SLJFP_crc32(0,
                    (const unsigned char*)duplicateOriginalPath.data(),
                    (unsigned int)duplicateOriginalPath.size());
    const unsigned int pngDataCrc =
        SLJFP_crc32(0, pngData.data(), (unsigned int)pngData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(mappedPathCrc), pngData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(duplicatePathCrc), pngData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData.size());
    AppendUInt32Le(indexData, pngDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, mappedPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)pngData.size());
    AppendUInt32Le(indexData, pngDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, duplicatePathCrc);

    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << mappedPathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.relocateRootNumericResiduals = true;
    options.writePathManifest = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredMapped;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + mappedPath, restoredMapped));
    TEST_ASSERT_EQ(pngData.size(), restoredMapped.size());
    TEST_ASSERT_MEM_EQ(pngData.data(), restoredMapped.data(), pngData.size());

    std::vector<unsigned char> duplicateRoot;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(duplicatePathCrc) + ".png",
                                   duplicateRoot));

    const std::vector<SLJFP::OutputPathManifestRecord> records =
        unpacker.GetLastOutputPathManifestRecords();
    TEST_ASSERT_EQ((size_t)2, records.size());

    const SLJFP::OutputPathManifestRecord* duplicateRecord = nullptr;
    for (size_t i = 0; i < records.size(); ++i) {
        if (records[i].pathCRC32 == duplicatePathCrc) {
            duplicateRecord = &records[i];
            break;
        }
    }
    TEST_ASSERT_TRUE(duplicateRecord != nullptr);
    TEST_ASSERT_EQ(mappedPath, duplicateRecord->finalRelativePath);
    TEST_ASSERT_EQ(mappedPath, duplicateRecord->actualRelativePath);
    TEST_ASSERT_EQ((std::string)"content_deduped_alias", duplicateRecord->physicalPathStatus);
    TEST_ASSERT_TRUE(duplicateRecord->physicalExists);
    TEST_ASSERT_FALSE(duplicateRecord->reviewBucketed);

    const std::string manifestText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.tsv");
    TEST_ASSERT_NE(std::string::npos, manifestText.find("content_deduped_alias"));
    TEST_ASSERT_EQ(std::string::npos, manifestText.find("physical_missing"));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, OutputPathManifestDetectsMappedExtensionMismatch) {
    const std::string baseDir = "test_output/unpacker_manifest_extension_mismatch";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "image/demo.jpg";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildTinyPng();
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.writePathManifest = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    const std::vector<SLJFP::OutputPathManifestRecord> records =
        unpacker.GetLastOutputPathManifestRecords();
    TEST_ASSERT_EQ((size_t)1, records.size());
    TEST_ASSERT_EQ(mappedPath, records[0].finalRelativePath);
    TEST_ASSERT_EQ(mappedPath, records[0].actualRelativePath);
    TEST_ASSERT_EQ((std::string)"manifest_path", records[0].physicalPathStatus);
    TEST_ASSERT_TRUE(records[0].physicalExists);
    TEST_ASSERT_EQ((std::string)".png", records[0].detectedExtension);
    TEST_ASSERT_FALSE(records[0].extensionConsistent);

    const std::string manifestText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.tsv");
    const std::string manifestJsonText = ReadTestTextFileOrEmpty(outputDir + "/unpack_path_manifest.json");
    TEST_ASSERT_NE(std::string::npos, manifestText.find("detected_extension"));
    TEST_ASSERT_NE(std::string::npos, manifestText.find("extension_consistent"));
    TEST_ASSERT_NE(std::string::npos, manifestText.find(".png"));
    TEST_ASSERT_NE(std::string::npos, manifestText.find("extension_mismatch"));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("\"detected_extension\": \".png\""));
    TEST_ASSERT_NE(std::string::npos, manifestJsonText.find("\"extension_consistent\": false"));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidationAllowsMappedRootNumericFile) {
    const std::string baseDir = "test_output/unpacker_strict_restore_root_numeric_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "12345.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildTinyPng();
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + mappedPath, restoredData));
    TEST_ASSERT_EQ(fileData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredData.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_FailsWhenMappingMissing) {
    const std::string baseDir = "test_output/unpacker_strict_restore_missing_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappedPath = "table/config/demo.cfg";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("strict-restore-check");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredRoot;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + std::to_string(pathCrc), restoredRoot));
    TEST_ASSERT_EQ(fileData.size(), restoredRoot.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredRoot.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_FailsAfterRelocatingRootResidualsWhenMappingMissing) {
    const std::string baseDir =
        "test_output/unpacker_strict_restore_missing_mapping_review_bucket";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappedPath = "table/config/demo.cfg";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("strict-restore-review-bucket");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;
    options.relocateRootNumericResiduals = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE,
                   unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> leftoverRoot;
    std::vector<unsigned char> relocatedFile;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(pathCrc), leftoverRoot));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(pathCrc) + ".txt",
                                   leftoverRoot));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/review/unresolved/noext/" +
                                      std::to_string(pathCrc),
                                  relocatedFile));
    TEST_ASSERT_EQ(fileData.size(), relocatedFile.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), relocatedFile.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_PassWithGeneratedImagesetMapping) {
    const std::string baseDir = "test_output/unpacker_strict_generated_imageset_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string imagesetPath = "ui/imagesets/fenxiang.imageset";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> imagesetData = BuildUtf8Text(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "<Imageset Name=\"fenxiang\" Imagefile=\"fenxiang.png\">\n"
        "    <Image Name=\"fenxiang_button\" XPos=\"0\" YPos=\"0\" Width=\"64\" Height=\"64\" />\n"
        "</Imageset>\n");
    const unsigned int imagesetPathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagesetPath.data(), (unsigned int)imagesetPath.size());
    const unsigned int imagesetDataCrc =
        SLJFP_crc32(0, imagesetData.data(), (unsigned int)imagesetData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagesetPathCrc), imagesetData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)imagesetData.size());
    AppendUInt32Le(indexData, imagesetDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagesetPathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredImageset;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagesetPath, restoredImageset));
    TEST_ASSERT_EQ(imagesetData.size(), restoredImageset.size());
    TEST_ASSERT_MEM_EQ(imagesetData.data(), restoredImageset.data(), imagesetData.size());

    std::vector<unsigned char> leftoverRootFile;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagesetPathCrc) + ".xml",
                                   leftoverRootFile));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_PassWithGeneratedImagesetTextureMapping) {
    const std::string baseDir = "test_output/unpacker_strict_generated_imageset_texture_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string imagesetPath = "ui/imagesets/fenxiang.imageset";
    const std::string imagePath = "ui/imagesets/fenxiang.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> imagesetData = BuildUtf8Text(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "<Imageset Name=\"fenxiang\" Imagefile=\"fenxiang.png\">\n"
        "    <Image Name=\"fenxiang_button\" XPos=\"0\" YPos=\"0\" Width=\"64\" Height=\"64\" />\n"
        "</Imageset>\n");
    const std::vector<unsigned char> imageData = BuildTinyPng();
    const unsigned int imagesetPathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagesetPath.data(), (unsigned int)imagesetPath.size());
    const unsigned int imagesetDataCrc =
        SLJFP_crc32(0, imagesetData.data(), (unsigned int)imagesetData.size());
    const unsigned int imagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());
    const unsigned int imageDataCrc =
        SLJFP_crc32(0, imageData.data(), (unsigned int)imageData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagesetPathCrc), imagesetData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), imageData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)imagesetData.size());
    AppendUInt32Le(indexData, imagesetDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagesetPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)imageData.size());
    AppendUInt32Le(indexData, imageDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagePathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredImageset;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagesetPath, restoredImageset));
    TEST_ASSERT_EQ(imagesetData.size(), restoredImageset.size());
    TEST_ASSERT_MEM_EQ(imagesetData.data(), restoredImageset.data(), imagesetData.size());

    std::vector<unsigned char> restoredImage;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredImage));
    TEST_ASSERT_EQ(imageData.size(), restoredImage.size());
    TEST_ASSERT_MEM_EQ(imageData.data(), restoredImage.data(), imageData.size());

    std::vector<unsigned char> leftoverRootFile;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagesetPathCrc) + ".xml",
                                   leftoverRootFile));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png",
                                   leftoverRootFile));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_PassWithGeneratedFontMapping) {
    const std::string baseDir = "test_output/unpacker_strict_generated_font_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string fontPath = "ui/fonts/num-count4.font";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fontData = BuildUtf8Text(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "<Font Name=\"num-count4\" Filename=\"num-count4.ttf\" Type=\"FreeType\">\n"
        "    <Mapping Code=\"48\" Image=\"0\" XAdvance=\"16\" />\n"
        "</Font>\n");
    const unsigned int fontPathCrc =
        SLJFP_crc32(0, (const unsigned char*)fontPath.data(), (unsigned int)fontPath.size());
    const unsigned int fontDataCrc =
        SLJFP_crc32(0, fontData.data(), (unsigned int)fontData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(fontPathCrc), fontData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fontData.size());
    AppendUInt32Le(indexData, fontDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, fontPathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredFont;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + fontPath, restoredFont));
    TEST_ASSERT_EQ(fontData.size(), restoredFont.size());
    TEST_ASSERT_MEM_EQ(fontData.data(), restoredFont.data(), fontData.size());

    std::vector<unsigned char> leftoverRootFile;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(fontPathCrc) + ".xml",
                                   leftoverRootFile));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_PassWithGeneratedModelActionAndDyeMapping) {
    const std::string baseDir = "test_output/unpacker_strict_generated_model_action_dye_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string namedAniPath = "model/demo/body/bodyonly/attack3.ani";
    const std::string actPath = "model/demo/action/attack3.act";
    const std::string dyePath = "model/demo/dyeinfo.dye";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> namedAniData = BuildMinimalModelAni(L"_res000.png");
    std::vector<unsigned char> actData;
    actData.push_back(0x09);
    actData.push_back(0x00);
    actData.push_back(0x00);
    actData.push_back(0x00);
    actData.push_back(0xE8);
    actData.push_back(0x03);
    actData.push_back(0x00);
    actData.push_back(0x00);
    actData.push_back(0xFF);
    actData.push_back(0xFF);
    actData.push_back(0xFF);
    actData.push_back(0xFF);
    std::vector<unsigned char> dyeData;
    dyeData.push_back('D');
    dyeData.push_back('Y');
    dyeData.push_back('E');
    dyeData.push_back('P');
    dyeData.push_back(0x01);
    dyeData.push_back(0x02);
    dyeData.push_back(0x03);
    dyeData.push_back(0x04);

    const unsigned int namedAniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)namedAniPath.data(), (unsigned int)namedAniPath.size());
    const unsigned int namedAniDataCrc =
        SLJFP_crc32(0, namedAniData.data(), (unsigned int)namedAniData.size());
    const unsigned int actPathCrc =
        SLJFP_crc32(0, (const unsigned char*)actPath.data(), (unsigned int)actPath.size());
    const unsigned int actDataCrc =
        SLJFP_crc32(0, actData.data(), (unsigned int)actData.size());
    const unsigned int dyePathCrc =
        SLJFP_crc32(0, (const unsigned char*)dyePath.data(), (unsigned int)dyePath.size());
    const unsigned int dyeDataCrc =
        SLJFP_crc32(0, dyeData.data(), (unsigned int)dyeData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(namedAniPathCrc), namedAniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(actPathCrc), actData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(dyePathCrc), dyeData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);

    const unsigned int sizes[] = {
        (unsigned int)namedAniData.size(),
        (unsigned int)actData.size(),
        (unsigned int)dyeData.size()
    };
    const unsigned int dataCrcs[] = {
        namedAniDataCrc,
        actDataCrc,
        dyeDataCrc
    };
    const unsigned int pathCrcs[] = {
        namedAniPathCrc,
        actPathCrc,
        dyePathCrc
    };

    for (int i = 0; i < 3; ++i) {
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, sizes[i]);
        AppendUInt32Le(indexData, dataCrcs[i]);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, 0);
        AppendUInt32Le(indexData, pathCrcs[i]);
    }
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << namedAniPathCrc << "|" << namedAniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> restoredAct;
    std::vector<unsigned char> restoredDye;
    std::vector<unsigned char> leftoverRootFile;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + namedAniPath, restoredAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + actPath, restoredAct));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + dyePath, restoredDye));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(actPathCrc), leftoverRootFile));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(dyePathCrc), leftoverRootFile));
    TEST_ASSERT_EQ(namedAniData.size(), restoredAni.size());
    TEST_ASSERT_EQ(actData.size(), restoredAct.size());
    TEST_ASSERT_EQ(dyeData.size(), restoredDye.size());
    TEST_ASSERT_MEM_EQ(namedAniData.data(), restoredAni.data(), namedAniData.size());
    TEST_ASSERT_MEM_EQ(actData.data(), restoredAct.data(), actData.size());
    TEST_ASSERT_MEM_EQ(dyeData.data(), restoredDye.data(), dyeData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_PassWithGeneratedAtlasPageTextureMapping) {
    const std::string baseDir = "test_output/unpacker_strict_generated_atlas_texture_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string atlasPath = "model/demo_model/demo_model.atlas";
    const std::string imagePath = "model/demo_model/demo_model.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> atlasData = BuildMinimalSpineAtlas("DEMO_MODEL.PNG");
    const std::vector<unsigned char> imageData = BuildTinyPng();
    const unsigned int atlasPathCrc =
        SLJFP_crc32(0, (const unsigned char*)atlasPath.data(), (unsigned int)atlasPath.size());
    const unsigned int atlasDataCrc =
        SLJFP_crc32(0, atlasData.data(), (unsigned int)atlasData.size());
    const unsigned int imagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());
    const unsigned int imageDataCrc =
        SLJFP_crc32(0, imageData.data(), (unsigned int)imageData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(atlasPathCrc), atlasData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), imageData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)atlasData.size());
    AppendUInt32Le(indexData, atlasDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, atlasPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)imageData.size());
    AppendUInt32Le(indexData, imageDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagePathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << atlasPathCrc << "|" << atlasPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAtlas;
    std::vector<unsigned char> restoredImage;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + atlasPath, restoredAtlas));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredImage));
    TEST_ASSERT_EQ(atlasData.size(), restoredAtlas.size());
    TEST_ASSERT_EQ(imageData.size(), restoredImage.size());
    TEST_ASSERT_MEM_EQ(atlasData.data(), restoredAtlas.data(), atlasData.size());
    TEST_ASSERT_MEM_EQ(imageData.data(), restoredImage.data(), imageData.size());

    std::vector<unsigned char> leftoverRootFile;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(atlasPathCrc) + ".atlas",
                                   leftoverRootFile));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png",
                                   leftoverRootFile));

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_PassWithGeneratedEffectVariantTextureMapping) {
    const std::string baseDir = "test_output/unpacker_strict_generated_effect_variant_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string aniPath = "effect/animation/ui/demo/demo.ani";
    const std::string imagePath = "effect/animation/ui/demo/demo_res004.png";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> aniData = BuildMinimalModelAni(L"_res000.png");
    const std::vector<unsigned char> imageData = BuildTinyPng();
    const unsigned int aniPathCrc =
        SLJFP_crc32(0, (const unsigned char*)aniPath.data(), (unsigned int)aniPath.size());
    const unsigned int aniDataCrc =
        SLJFP_crc32(0, aniData.data(), (unsigned int)aniData.size());
    const unsigned int imagePathCrc =
        SLJFP_crc32(0, (const unsigned char*)imagePath.data(), (unsigned int)imagePath.size());
    const unsigned int imageDataCrc =
        SLJFP_crc32(0, imageData.data(), (unsigned int)imageData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(aniPathCrc), aniData));
    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(imagePathCrc), imageData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 2);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)aniData.size());
    AppendUInt32Le(indexData, aniDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, aniPathCrc);

    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)imageData.size());
    AppendUInt32Le(indexData, imageDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, imagePathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << aniPathCrc << "|" << aniPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredAni;
    std::vector<unsigned char> restoredImage;
    std::vector<unsigned char> leftoverRootFile;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + aniPath, restoredAni));
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + imagePath, restoredImage));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(imagePathCrc) + ".png",
                                   leftoverRootFile));
    TEST_ASSERT_EQ(aniData.size(), restoredAni.size());
    TEST_ASSERT_EQ(imageData.size(), restoredImage.size());
    TEST_ASSERT_MEM_EQ(aniData.data(), restoredAni.data(), aniData.size());
    TEST_ASSERT_MEM_EQ(imageData.data(), restoredImage.data(), imageData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StrictRestoreValidation_PassWithFullMapping) {
    const std::string baseDir = "test_output/unpacker_strict_restore_full_mapping";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "table/config/demo.cfg";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("strict-restore-full-mapping");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int dataCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.strictRestoreValidation = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredMapped;
    std::vector<unsigned char> restoredRoot;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + mappedPath, restoredMapped));
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + std::to_string(pathCrc), restoredRoot));
    TEST_ASSERT_EQ(fileData.size(), restoredMapped.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredMapped.data(), fileData.size());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, AutoDecryptProbeFallsBackToPassthroughForMislabeledCodeType) {
    const std::string baseDir = "test_output/unpacker_auto_decrypt_probe_passthrough";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "misc/passthrough_probe.txt";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("probe-passthrough-auto");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int currentCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, currentCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, currentCrc);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writePathManifest = false;
    options.decryptMode = SLJFP::DecryptMode::Auto;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + mappedPath, restoredData));
    TEST_ASSERT_EQ(fileData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(fileData.data(), restoredData.data(), fileData.size());

    std::vector<SLJFP::DecryptProbeRecord> probes = unpacker.GetLastDecryptProbeRecords();
    TEST_ASSERT_TRUE(!probes.empty());

    bool foundSelectedPassthrough = false;
    for (size_t i = 0; i < probes.size(); ++i) {
        if (probes[i].selected && probes[i].candidateId == "passthrough") {
            foundSelectedPassthrough = true;
            TEST_ASSERT_TRUE(probes[i].crcChecked);
            TEST_ASSERT_TRUE(probes[i].crcMatched);
            break;
        }
    }
    TEST_ASSERT_TRUE(foundSelectedPassthrough);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StreamModeDeletesPartialOutputOnCrcMismatch) {
    const std::string baseDir = "test_output/unpacker_stream_crc_cleanup";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "misc/stream_crc_cleanup.txt";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("stream-mode-partial-output");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int wrongDataCrc = 0x01020304u;

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, wrongDataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.useStreamMode = true;
    options.verifyCRC32 = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE,
                   unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> partialOutput;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + mappedPath, partialOutput));

    const std::vector<SLJFP::FailedFileRecord> failedRecords = unpacker.GetLastFailedFiles();
    TEST_ASSERT_EQ((size_t)1, failedRecords.size());
    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_CRC32_MISMATCH, failedRecords[0].errorCode);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, StreamCompressedDeletesPartialOutputOnCrcMismatch) {
    const std::string baseDir = "test_output/unpacker_stream_compressed_crc_cleanup";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "misc/stream_compressed_crc_cleanup.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> originalData = BuildPatternBlob(8192);
    const std::vector<unsigned char> compressedData = CompressBuffer(originalData);
    TEST_ASSERT_TRUE(!compressedData.empty());

    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int compressedCrc =
        SLJFP_crc32(0, compressedData.data(), (unsigned int)compressedData.size());
    const unsigned int originalCrc =
        SLJFP_crc32(0, originalData.data(), (unsigned int)originalData.size());
    const unsigned int wrongOriginalCrc = originalCrc ^ 0xFFFFFFFFu;

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), compressedData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)compressedData.size());
    AppendUInt32Le(indexData, compressedCrc);
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)originalData.size());
    AppendUInt32Le(indexData, wrongOriginalCrc);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.useStreamMode = true;
    options.verifyCRC32 = true;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE,
                   unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> partialOutput;
    TEST_ASSERT_FALSE(ReadTestFile(outputDir + "/" + mappedPath, partialOutput));

    const std::vector<SLJFP::FailedFileRecord> failedRecords = unpacker.GetLastFailedFiles();
    TEST_ASSERT_EQ((size_t)1, failedRecords.size());
    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_CRC32_MISMATCH, failedRecords[0].errorCode);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, DecompressRetryRejectsHugeReportedBufferBeforeOverflow) {
    const std::string baseDir = "test_output/unpacker_decompress_huge_buf_error";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string logicalPath = "misc/huge_buf_error.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> sourceData = BuildUtf8Text("x");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)logicalPath.data(), (unsigned int)logicalPath.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), sourceData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)sourceData.size());
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        HugeBufErrorUnzip,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.verifyCRC32 = false;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE,
                   unpacker.UnpackAll(inputDir, outputDir, options));

    const std::vector<SLJFP::FailedFileRecord> failedRecords = unpacker.GetLastFailedFiles();
    TEST_ASSERT_EQ((size_t)1, failedRecords.size());
    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_DECOMPRESS_TOO_LARGE, failedRecords[0].errorCode);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, AutoDecryptProbeFallsBackToLegacyFullWindowForCompressedPayload) {
    const std::string baseDir = "test_output/unpacker_auto_decrypt_probe_legacy_full";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "misc/legacy_full_probe.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> originalData = BuildPatternBlob(4096);
    const std::vector<unsigned char> compressedData = CompressBuffer(originalData);
    TEST_ASSERT_TRUE(compressedData.size() > 1024);

    const std::vector<unsigned char> encryptedData =
        EncryptAllBlocksLegacy(compressedData, SLJFP::DEFAULT_DECRYPT_KEY);

    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int encryptedCrc =
        SLJFP_crc32(0, encryptedData.data(), (unsigned int)encryptedData.size());
    const unsigned int originalCrc =
        SLJFP_crc32(0, originalData.data(), (unsigned int)originalData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), encryptedData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)encryptedData.size());
    AppendUInt32Le(indexData, encryptedCrc);
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, (unsigned int)originalData.size());
    AppendUInt32Le(indexData, originalCrc);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writePathManifest = false;
    options.decryptMode = SLJFP::DecryptMode::Auto;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.UnpackAll(inputDir, outputDir, options));

    std::vector<unsigned char> restoredData;
    TEST_ASSERT_TRUE(ReadTestFile(outputDir + "/" + mappedPath, restoredData));
    TEST_ASSERT_EQ(originalData.size(), restoredData.size());
    TEST_ASSERT_MEM_EQ(originalData.data(), restoredData.data(), originalData.size());

    std::vector<SLJFP::DecryptProbeRecord> probes = unpacker.GetLastDecryptProbeRecords();
    TEST_ASSERT_TRUE(!probes.empty());

    bool foundSelectedLegacyFull = false;
    for (size_t i = 0; i < probes.size(); ++i) {
        if (probes[i].selected && probes[i].candidateId == "legacy-full") {
            foundSelectedLegacyFull = true;
            TEST_ASSERT_TRUE(probes[i].crcChecked);
            TEST_ASSERT_TRUE(probes[i].crcMatched);
            break;
        }
    }
    TEST_ASSERT_TRUE(foundSelectedLegacyFull);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, CapturesFirstFailedDecryptDiagnosticOnCrcMismatch) {
    const std::string baseDir = "test_output/unpacker_first_failed_decrypt_diagnostic";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "misc/force_crc_mismatch.txt";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::vector<unsigned char> fileData = BuildUtf8Text("force-crc-mismatch");
    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int currentCrc =
        SLJFP_crc32(0, fileData.data(), (unsigned int)fileData.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, currentCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, (unsigned int)fileData.size());
    AppendUInt32Le(indexData, currentCrc);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writePathManifest = false;
    options.decryptMode = SLJFP::DecryptMode::LJFilePackSMS4;

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE, unpacker.UnpackAll(inputDir, outputDir, options));

    SLJFP::DecryptFailureDiagnostic diagnostic;
    TEST_ASSERT_TRUE(unpacker.GetFirstFailedDecryptDiagnostic(diagnostic));
    TEST_ASSERT_TRUE(diagnostic.valid);
    TEST_ASSERT_EQ((uint32_t)0, diagnostic.fileIndex);
    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_CRC32_MISMATCH, diagnostic.failureCode);
    TEST_ASSERT_EQ((unsigned int)pathCrc, diagnostic.fileInfo.m_PathFileNameCRC32);
    TEST_ASSERT_TRUE(!diagnostic.candidates.empty());
    TEST_ASSERT_EQ(std::string("legacy-window1024"), diagnostic.candidates[0].candidateId);
    TEST_ASSERT_TRUE(diagnostic.candidates[0].selected);
    TEST_ASSERT_TRUE(diagnostic.candidates[0].crcChecked);
    TEST_ASSERT_FALSE(diagnostic.candidates[0].crcMatched);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(Unpacker, AutoDecryptProbeIncludesClientKeyedCandidatesOnFailure) {
    const std::string baseDir = "test_output/unpacker_auto_decrypt_probe_client_keyed";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string mappedPath = "misc/client_keyed_probe.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    std::vector<unsigned char> bogusEncrypted(1408);
    for (size_t i = 0; i < bogusEncrypted.size(); ++i) {
        bogusEncrypted[i] = static_cast<unsigned char>((i * 37u + 11u) & 0xFFu);
    }
    bogusEncrypted[0] = 0x07;
    bogusEncrypted[1] = 0x7D;

    const unsigned int pathCrc =
        SLJFP_crc32(0, (const unsigned char*)mappedPath.data(), (unsigned int)mappedPath.size());
    const unsigned int encryptedCrc =
        SLJFP_crc32(0, bogusEncrypted.data(), (unsigned int)bogusEncrypted.size());

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), bogusEncrypted));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, (unsigned int)bogusEncrypted.size());
    AppendUInt32Le(indexData, encryptedCrc);
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 4096);
    AppendUInt32Le(indexData, 0x12345678);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << mappedPath << "\n";
        TEST_ASSERT_TRUE(mappingFile.good());
    }

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadPathMapping(mappingPath));

    SLJFP::UnpackOptions options;
    options.overwriteExisting = true;
    options.threadCount = 1;
    options.detectFileType = false;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.writePathManifest = false;
    options.decryptMode = SLJFP::DecryptMode::Auto;
    options.decryptKey = "runtime-key-1234";

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE, unpacker.UnpackAll(inputDir, outputDir, options));

    SLJFP::DecryptFailureDiagnostic diagnostic;
    TEST_ASSERT_TRUE(unpacker.GetFirstFailedDecryptDiagnostic(diagnostic));
    TEST_ASSERT_TRUE(diagnostic.valid);
    TEST_ASSERT_EQ((uint32_t)0, diagnostic.fileIndex);
    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_DECOMPRESS_FAILED, diagnostic.failureCode);

    bool foundClientKeyedWindow = false;
    bool foundClientKeyedFull = false;
    for (size_t i = 0; i < diagnostic.candidates.size(); ++i) {
        if (diagnostic.candidates[i].candidateId == "clientkeyed-window1024") {
            foundClientKeyedWindow = true;
        }
        if (diagnostic.candidates[i].candidateId == "clientkeyed-full") {
            foundClientKeyedFull = true;
        }
    }

    TEST_ASSERT_TRUE(foundClientKeyedWindow);
    TEST_ASSERT_TRUE(foundClientKeyedFull);

    CleanupTestDirectory(baseDir);
    return true;
}

// ============================================================================
// Error Code Tests
// ============================================================================

TEST_CASE(ErrorCodes, Ranges) {
    // Test error code ranges
    TEST_ASSERT_EQ(0, SLJFP::LJFP_SUCCESS);

    // File operation errors: 100-199
    TEST_ASSERT_TRUE(SLJFP::LJFP_ERROR_FILE_NOT_FOUND >= 100);
    TEST_ASSERT_TRUE(SLJFP::LJFP_ERROR_FILE_NOT_FOUND < 200);

    // Index errors: 200-299
    TEST_ASSERT_TRUE(SLJFP::LJFP_ERROR_INDEX_NOT_FOUND >= 200);
    TEST_ASSERT_TRUE(SLJFP::LJFP_ERROR_INDEX_NOT_FOUND < 300);

    return true;
}

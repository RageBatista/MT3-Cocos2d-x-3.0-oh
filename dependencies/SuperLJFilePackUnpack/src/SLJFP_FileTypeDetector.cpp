/**
 * @file SLJFP_FileTypeDetector.cpp
 * @brief 文件类型检测器实现
 * @author SuperLJFilePackUnpack Project
 * @date 2026-01-04
 * @version 1.0
 */

#include "SLJFP_FileTypeDetector.h"
#include <cstring>
#include <algorithm>
#include <cctype>

namespace SLJFP {

namespace {

bool EndsWithNoCase(const std::string& value, const char* suffix) {
    if (suffix == nullptr) {
        return false;
    }

    const size_t suffixLen = std::strlen(suffix);
    if (value.size() < suffixLen) {
        return false;
    }

    const size_t offset = value.size() - suffixLen;
    for (size_t i = 0; i < suffixLen; ++i) {
        const unsigned char a = static_cast<unsigned char>(value[offset + i]);
        const unsigned char b = static_cast<unsigned char>(suffix[i]);
        if (std::tolower(a) != std::tolower(b)) {
            return false;
        }
    }
    return true;
}

bool ContainsAsciiLiteral(const uint8_t* data, size_t size, const char* literal) {
    if (data == nullptr || literal == nullptr) {
        return false;
    }

    const size_t literalLen = std::strlen(literal);
    if (literalLen == 0 || size < literalLen) {
        return false;
    }

    for (size_t i = 0; i + literalLen <= size; ++i) {
        if (std::memcmp(data + i, literal, literalLen) == 0) {
            return true;
        }
    }

    return false;
}

bool MatchesAsciiLiteralNoCaseAt(const uint8_t* data,
                                 size_t size,
                                 size_t offset,
                                 const char* literal) {
    if (data == nullptr || literal == nullptr) {
        return false;
    }

    const size_t literalLen = std::strlen(literal);
    if (literalLen == 0 || offset + literalLen > size) {
        return false;
    }

    for (size_t i = 0; i < literalLen; ++i) {
        const unsigned char a = static_cast<unsigned char>(data[offset + i]);
        const unsigned char b = static_cast<unsigned char>(literal[i]);
        if (std::tolower(a) != std::tolower(b)) {
            return false;
        }
    }
    return true;
}

bool StartsWithAsciiLiteralNoCase(const uint8_t* data, size_t size, const char* literal) {
    return MatchesAsciiLiteralNoCaseAt(data, size, 0, literal);
}

bool ContainsAsciiLiteralNoCase(const uint8_t* data, size_t size, const char* literal) {
    if (data == nullptr || literal == nullptr) {
        return false;
    }

    const size_t literalLen = std::strlen(literal);
    if (literalLen == 0 || size < literalLen) {
        return false;
    }

    for (size_t i = 0; i + literalLen <= size; ++i) {
        if (MatchesAsciiLiteralNoCaseAt(data, size, i, literal)) {
            return true;
        }
    }

    return false;
}

bool ContainsUtf16LeAsciiLiteralNoCase(const uint8_t* data, size_t size, const char* literal) {
    if (data == nullptr || literal == nullptr) {
        return false;
    }

    const size_t literalLen = std::strlen(literal);
    if (literalLen == 0 || size < literalLen * 2) {
        return false;
    }

    for (size_t i = 0; i + literalLen * 2 <= size; ++i) {
        bool matched = true;
        for (size_t j = 0; j < literalLen; ++j) {
            const unsigned char ch = static_cast<unsigned char>(data[i + j * 2]);
            const unsigned char zero = static_cast<unsigned char>(data[i + j * 2 + 1]);
            const unsigned char literalCh = static_cast<unsigned char>(literal[j]);
            if (zero != 0 || std::tolower(ch) != std::tolower(literalCh)) {
                matched = false;
                break;
            }
        }
        if (matched) {
            return true;
        }
    }

    return false;
}

bool ContainsAsciiLiteralEitherEncodingNoCase(const uint8_t* data,
                                              size_t size,
                                              const char* literal) {
    return ContainsAsciiLiteralNoCase(data, size, literal) ||
           ContainsUtf16LeAsciiLiteralNoCase(data, size, literal);
}

uint32_t ReadUInt32LE(const uint8_t* data) {
    return static_cast<uint32_t>(data[0]) |
           (static_cast<uint32_t>(data[1]) << 8) |
           (static_cast<uint32_t>(data[2]) << 16) |
           (static_cast<uint32_t>(data[3]) << 24);
}

uint32_t MakeFourCC(char ch0, char ch1, char ch2, char ch3) {
    return static_cast<uint32_t>(static_cast<unsigned char>(ch0)) |
           (static_cast<uint32_t>(static_cast<unsigned char>(ch1)) << 8) |
           (static_cast<uint32_t>(static_cast<unsigned char>(ch2)) << 16) |
           (static_cast<uint32_t>(static_cast<unsigned char>(ch3)) << 24);
}

bool IsKnownNuclearImageFileFormat(uint32_t fileFormat) {
    return fileFormat <= 12;
}

bool IsKnownNuclearTextureFormat(uint32_t textureFormat) {
    return textureFormat == 21 ||  // XPTEXFMT_A8R8G8B8
           textureFormat == 26 ||  // XPTEXFMT_A4R4G4B4
           textureFormat == 23 ||  // XPTEXFMT_R5G6B5
           textureFormat == MakeFourCC('D', 'X', 'T', '1') ||
           textureFormat == MakeFourCC('D', 'X', 'T', '2') ||
           textureFormat == MakeFourCC('D', 'X', 'T', '3') ||
           textureFormat == MakeFourCC('D', 'X', 'T', '4') ||
           textureFormat == MakeFourCC('D', 'X', 'T', '5');
}

inline bool IsAsciiIdentifierStart(unsigned char ch) {
    return (std::isalpha(ch) != 0) || ch == '_';
}

inline bool IsAsciiIdentifierPart(unsigned char ch) {
    return (std::isalnum(ch) != 0) || ch == '_';
}

bool LooksLikeLuaTopLevelAssignment(const uint8_t* data, size_t size) {
    if (data == nullptr || size == 0) {
        return false;
    }

    size_t i = 0;
    if (!IsAsciiIdentifierStart(static_cast<unsigned char>(data[i]))) {
        return false;
    }

    ++i;
    while (i < size) {
        const unsigned char ch = static_cast<unsigned char>(data[i]);
        if (IsAsciiIdentifierPart(ch)) {
            ++i;
            continue;
        }
        if (ch == '.') {
            if (i + 1 >= size ||
                !IsAsciiIdentifierStart(static_cast<unsigned char>(data[i + 1]))) {
                return false;
            }
            ++i;
            continue;
        }
        break;
    }

    while (i < size && (data[i] == ' ' || data[i] == '\t')) {
        ++i;
    }

    return i < size && data[i] == '=';
}

bool LooksLikeMt3ParticlePtc(const uint8_t* data, size_t size) {
    if (data == nullptr || size < 96) {
        return false;
    }

    const uint32_t version = ReadUInt32LE(data);
    if (version > 16) {
        return false;
    }

    const bool hasBlendToken =
        ContainsAsciiLiteral(data, size, "D3DTOP_") ||
        ContainsAsciiLiteral(data, size, "D3DBLEND_") ||
        ContainsAsciiLiteral(data, size, "D3DTADDRESS_");
    if (!hasBlendToken) {
        return false;
    }

    const char* particleRefs[] = {
        ".dds",
        ".png",
        ".jpg",
        ".tga",
        ".path"
    };

    for (size_t i = 0; i < sizeof(particleRefs) / sizeof(particleRefs[0]); ++i) {
        if (ContainsAsciiLiteralEitherEncodingNoCase(data, size, particleRefs[i])) {
            return true;
        }
    }

    return false;
}

bool LooksLikeNuclearImg(const uint8_t* data, size_t size) {
    if (data == nullptr || size < 96) {
        return false;
    }

    const uint32_t version = ReadUInt32LE(data);
    if (version != 6) {
        return false;
    }

    const uint32_t row = ReadUInt32LE(data + 44);
    const uint32_t col = ReadUInt32LE(data + 48);
    const uint32_t rectCount = ReadUInt32LE(data + 52);
    if (row == 0 || col == 0 || row > 4096 || col > 4096) {
        return false;
    }

    size_t offset = 56;
    if (rectCount > (size - offset) / 16) {
        return false;
    }
    offset += static_cast<size_t>(rectCount) * 16;

    if (offset + 16 > size) {
        return false;
    }

    const uint32_t fileSize = ReadUInt32LE(data + offset);
    const uint32_t width = ReadUInt32LE(data + offset + 4);
    const uint32_t height = ReadUInt32LE(data + offset + 8);
    if (fileSize == 0 || width == 0 || height == 0 || width > 8192 || height > 8192) {
        return false;
    }
    offset += 12;

    const uint32_t maskCount = ReadUInt32LE(data + offset);
    offset += 4;
    if (maskCount > (size - offset) / 8) {
        return false;
    }
    offset += static_cast<size_t>(maskCount) * 8;

    if (offset + 8 != size) {
        return false;
    }

    const uint32_t fileFormat = ReadUInt32LE(data + offset);
    const uint32_t textureFormat = ReadUInt32LE(data + offset + 4);
    return IsKnownNuclearImageFileFormat(fileFormat) &&
           IsKnownNuclearTextureFormat(textureFormat);
}

bool HasTgaFooterSignature(const uint8_t* data, size_t size) {
    static const char kTgaFooter[] = "TRUEVISION-XFILE.";
    return data != nullptr &&
           size >= 26 &&
           std::memcmp(data + size - 18, kTgaFooter, 17) == 0 &&
           data[size - 1] == 0;
}

bool LooksLikeTga(const uint8_t* data, size_t size) {
    if (data == nullptr || size < 26) {
        return false;
    }

    if (!HasTgaFooterSignature(data, size)) {
        return false;
    }

    const uint8_t colorMapType = data[1];
    const uint8_t imageType = data[2];
    if (colorMapType > 1) {
        return false;
    }

    switch (imageType) {
    case 1:
    case 2:
    case 3:
    case 9:
    case 10:
    case 11:
        break;
    default:
        return false;
    }

    const uint16_t width = static_cast<uint16_t>(data[12]) |
                           (static_cast<uint16_t>(data[13]) << 8);
    const uint16_t height = static_cast<uint16_t>(data[14]) |
                            (static_cast<uint16_t>(data[15]) << 8);
    if (width == 0 || height == 0 || width > 8192 || height > 8192) {
        return false;
    }

    const uint8_t pixelDepth = data[16];
    return pixelDepth == 8 || pixelDepth == 15 || pixelDepth == 16 ||
           pixelDepth == 24 || pixelDepth == 32;
}

bool LooksLikeMazeDat(const uint8_t* data, size_t size) {
    if (data == nullptr || size < 12) {
        return false;
    }

    const uint32_t headerSize = ReadUInt32LE(data);
    if (headerSize != 12) {
        return false;
    }

    const uint32_t width = ReadUInt32LE(data + 4);
    const uint32_t height = ReadUInt32LE(data + 8);
    if (width == 0 || height == 0 || width > 4096 || height > 4096) {
        return false;
    }

    const uint64_t expectedSize = 12ull + static_cast<uint64_t>(width) * height;
    return expectedSize == size;
}

bool LooksLikeMonsterDat(const uint8_t* data, size_t size) {
    if (data == nullptr || size < 16) {
        return false;
    }

    const uint32_t headerSize = ReadUInt32LE(data);
    if (headerSize != 16) {
        return false;
    }

    const uint32_t width = ReadUInt32LE(data + 4);
    const uint32_t height = ReadUInt32LE(data + 8);
    const uint32_t entryCount = ReadUInt32LE(data + 12);
    if (width == 0 || height == 0 || width > 4096 || height > 4096) {
        return false;
    }

    if (entryCount > static_cast<uint64_t>(width) * height) {
        return false;
    }

    const uint64_t expectedSize = 16ull + static_cast<uint64_t>(entryCount) * 8ull;
    return expectedSize == size;
}

bool StartsWithWindowsDrivePath(const uint8_t* data, size_t size) {
    return data != nullptr &&
           size >= 3 &&
           std::isalpha(static_cast<unsigned char>(data[0])) != 0 &&
           data[1] == ':' &&
           (data[2] == '\\' || data[2] == '/');
}

bool LooksLikeIniSectionedText(const uint8_t* data, size_t size) {
    if (data == nullptr || size < 5) {
        return false;
    }

    if (data[0] != '[') {
        return false;
    }

    size_t lineEnd = 0;
    while (lineEnd < size && data[lineEnd] != '\n' && data[lineEnd] != '\r') {
        ++lineEnd;
    }

    if (lineEnd < 3 || lineEnd > 128 || data[lineEnd - 1] != ']') {
        return false;
    }

    bool sawAlpha = false;
    for (size_t i = 1; i + 1 < lineEnd; ++i) {
        const unsigned char ch = static_cast<unsigned char>(data[i]);
        if (std::isalpha(ch) != 0) {
            sawAlpha = true;
        }

        if ((std::isalnum(ch) == 0) &&
            ch != '_' &&
            ch != '-' &&
            ch != '.' &&
            ch != ' ') {
            return false;
        }
    }

    if (!sawAlpha) {
        return false;
    }

    const size_t scanSize = std::min<size_t>(size, 512u);
    return ContainsAsciiLiteral(data, scanSize, "=");
}

bool LooksLikePlainText(const uint8_t* data, size_t size) {
    if (data == nullptr || size == 0) {
        return false;
    }

    size_t textishCount = 0;
    size_t controlCount = 0;
    bool hasLineBreak = false;

    for (size_t i = 0; i < size; ++i) {
        const uint8_t ch = data[i];
        if (ch == 0) {
            return false;
        }

        if (ch == '\r' || ch == '\n') {
            hasLineBreak = true;
            ++textishCount;
            continue;
        }

        if (ch == '\t' || ch >= 0x20 || ch >= 0x80) {
            ++textishCount;
            continue;
        }

        ++controlCount;
    }

    const size_t maxControlCount = std::max<size_t>(2, size / 64);
    if (controlCount > maxControlCount) {
        return false;
    }

    const double textishRatio = static_cast<double>(textishCount) /
                                static_cast<double>(size);
    if (textishRatio < 0.95) {
        return false;
    }

    return hasLineBreak ||
           StartsWithWindowsDrivePath(data, size) ||
           ContainsAsciiLiteral(data, size, ":\\");
}

}  // namespace

// ============================================================================
// Magic Number 定义
// ============================================================================

// 图像格式
static const uint8_t MAGIC_PNG[] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
static const uint8_t MAGIC_JPG[] = {0xFF, 0xD8, 0xFF};
static const uint8_t MAGIC_GIF87[] = {0x47, 0x49, 0x46, 0x38, 0x37, 0x61};  // GIF87a
static const uint8_t MAGIC_GIF89[] = {0x47, 0x49, 0x46, 0x38, 0x39, 0x61};  // GIF89a
static const uint8_t MAGIC_BMP[] = {0x42, 0x4D};
static const uint8_t MAGIC_ICO[] = {0x00, 0x00, 0x01, 0x00};
static const uint8_t MAGIC_CUR[] = {0x00, 0x00, 0x02, 0x00};
static const uint8_t MAGIC_PSD[] = {0x38, 0x42, 0x50, 0x53};                 // 8BPS
static const uint8_t MAGIC_TGA_FOOTER[] = {'T', 'R', 'U', 'E', 'V', 'I', 'S', 'I', 'O', 'N', '-', 'X', 'F', 'I', 'L', 'E'};
static const uint8_t MAGIC_DDS[] = {0x44, 0x44, 0x53, 0x20};                 // DDS (DirectDraw Surface)
static const uint8_t MAGIC_PVR[] = {0x50, 0x56, 0x52, 0x03};                 // PVR v3
static const uint8_t MAGIC_TTF[] = {0x00, 0x01, 0x00, 0x00};                 // TrueType/OpenType sfnt
static const uint8_t MAGIC_OTTO[] = {0x4F, 0x54, 0x54, 0x4F};                // OpenType CFF (OTTO)

// 音频格式
static const uint8_t MAGIC_RIFF[] = {0x52, 0x49, 0x46, 0x46};                // RIFF (WAV/WEBP container)
static const uint8_t MAGIC_OGG[] = {0x4F, 0x67, 0x67, 0x53};                 // OggS
static const uint8_t MAGIC_MP3_ID3[] = {0x49, 0x44, 0x33};                   // ID3
static const uint8_t MAGIC_MP3_SYNC1[] = {0xFF, 0xFB};                       // Frame sync (Layer 3)
static const uint8_t MAGIC_MP3_SYNC2[] = {0xFF, 0xFA};                       // Frame sync (Layer 3)
static const uint8_t MAGIC_MP3_SYNC3[] = {0xFF, 0xF3};                       // Frame sync (Layer 3)
static const uint8_t MAGIC_FLAC[] = {0x66, 0x4C, 0x61, 0x43};                // fLaC
static const uint8_t MAGIC_MIDI[] = {0x4D, 0x54, 0x68, 0x64};                // MThd

// Lua 脚本格式
static const uint8_t MAGIC_LUA51_BC[] = {0x1B, 0x4C, 0x75, 0x61, 0x51};      // Lua 5.1 bytecode
static const uint8_t MAGIC_LUA52_BC[] = {0x1B, 0x4C, 0x75, 0x61, 0x52};      // Lua 5.2 bytecode
static const uint8_t MAGIC_LUA53_BC[] = {0x1B, 0x4C, 0x75, 0x61, 0x53};      // Lua 5.3 bytecode
static const uint8_t MAGIC_LUAJIT_BC[] = {0x1B, 0x4C, 0x4A};                 // LuaJIT bytecode

// 压缩/归档格式
static const uint8_t MAGIC_ZIP[] = {0x50, 0x4B, 0x03, 0x04};
static const uint8_t MAGIC_ZIP_EMPTY[] = {0x50, 0x4B, 0x05, 0x06};           // Empty archive
static const uint8_t MAGIC_ZIP_SPANNED[] = {0x50, 0x4B, 0x07, 0x08};         // Spanned archive
static const uint8_t MAGIC_GZIP[] = {0x1F, 0x8B};
static const uint8_t MAGIC_BZIP2[] = {0x42, 0x5A, 0x68};                     // BZh
static const uint8_t MAGIC_7Z[] = {0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C};
static const uint8_t MAGIC_RAR[] = {0x52, 0x61, 0x72, 0x21, 0x1A, 0x07};
static const uint8_t MAGIC_TAR_USTAR[] = {'u', 's', 't', 'a', 'r'};          // offset 257

// 文档格式
static const uint8_t MAGIC_PDF[] = {0x25, 0x50, 0x44, 0x46};                 // %PDF
static const uint8_t MAGIC_XML_DECL[] = {0x3C, 0x3F, 0x78, 0x6D, 0x6C};      // <?xml
static const uint8_t MAGIC_CFB[] = {0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1};  // Compound File Binary
static const uint8_t MAGIC_MDMP[] = {0x4D, 0x44, 0x4D, 0x50};                // Windows Minidump

// 可执行/二进制格式
static const uint8_t MAGIC_EXE_MZ[] = {0x4D, 0x5A};                          // MZ (DOS/PE)
static const uint8_t MAGIC_ELF[] = {0x7F, 0x45, 0x4C, 0x46};                 // ELF

// MT3 自定义格式 (基于项目分析)
static const uint8_t MAGIC_ACT[] = {0x41, 0x43, 0x54, 0x00};                 // ACT\0 (动作文件)
static const uint8_t MAGIC_ANI[] = {0x41, 0x4E, 0x49, 0x00};                 // ANI\0 (动画文件)
static const uint8_t MAGIC_LMX[] = {0x4C, 0x4D, 0x58, 0x00};                 // LMX\0 (模型文件)
static const uint8_t MAGIC_SPR[] = {0x53, 0x50, 0x52, 0x00};                 // SPR\0 (精灵文件)
static const uint8_t MAGIC_FNT[] = {0x46, 0x4E, 0x54, 0x00};                 // FNT\0 (字体文件)
static const uint8_t MAGIC_MRMP[] = {0x4D, 0x52, 0x4D, 0x50};                // MRMP (地图编辑数据)
static const uint8_t MAGIC_RMAP[] = {0x52, 0x4D, 0x41, 0x50, 0x2D};          // RMAP- (地图块数据)
static const uint8_t MAGIC_QUYU[] = {0x51, 0x55, 0x59, 0x55};                // QUYU (区域/寻路数据)
static const uint8_t MAGIC_LDZY[] = {0x4C, 0x44, 0x5A, 0x59};                // LDZY (表格数据)

// ============================================================================
// 文件类型信息表
// ============================================================================

static const FileTypeDetector::FileTypeInfo FILE_TYPES[] = {
    // 图像格式 (最常见，放在前面)
    {MAGIC_PNG, 8, 0, ".png", "image/png", "PNG Image"},
    {MAGIC_JPG, 3, 0, ".jpg", "image/jpeg", "JPEG Image"},
    {MAGIC_GIF87, 6, 0, ".gif", "image/gif", "GIF Image (87a)"},
    {MAGIC_GIF89, 6, 0, ".gif", "image/gif", "GIF Image (89a)"},
    {MAGIC_BMP, 2, 0, ".bmp", "image/bmp", "BMP Image"},
    {MAGIC_ICO, 4, 0, ".ico", "image/x-icon", "ICO Icon"},
    {MAGIC_CUR, 4, 0, ".cur", "image/x-icon", "CUR Cursor"},
    {MAGIC_PSD, 4, 0, ".psd", "image/vnd.adobe.photoshop", "Photoshop Document"},
    {MAGIC_DDS, 4, 0, ".dds", "image/vnd-ms.dds", "DirectDraw Surface"},
    {MAGIC_PVR, 4, 0, ".pvr", "image/x-pvr", "PowerVR Texture"},
    {MAGIC_TTF, 4, 0, ".ttf", "font/ttf", "TrueType Font"},
    {MAGIC_OTTO, 4, 0, ".otf", "font/otf", "OpenType Font"},

    // 音频格式
    {MAGIC_OGG, 4, 0, ".ogg", "audio/ogg", "OGG Audio"},
    {MAGIC_MP3_ID3, 3, 0, ".mp3", "audio/mpeg", "MP3 Audio (ID3)"},
    {MAGIC_MP3_SYNC1, 2, 0, ".mp3", "audio/mpeg", "MP3 Audio"},
    {MAGIC_MP3_SYNC2, 2, 0, ".mp3", "audio/mpeg", "MP3 Audio"},
    {MAGIC_MP3_SYNC3, 2, 0, ".mp3", "audio/mpeg", "MP3 Audio"},
    {MAGIC_FLAC, 4, 0, ".flac", "audio/flac", "FLAC Audio"},
    {MAGIC_MIDI, 4, 0, ".mid", "audio/midi", "MIDI Audio"},
    {MAGIC_RIFF, 4, 0, ".riff", "application/octet-stream", "RIFF Container"},  // 特殊处理

    // Lua 脚本格式 (MT3 大量使用)
    {MAGIC_LUA51_BC, 5, 0, ".luac", "application/x-lua-bytecode", "Lua 5.1 Bytecode"},
    {MAGIC_LUA52_BC, 5, 0, ".luac", "application/x-lua-bytecode", "Lua 5.2 Bytecode"},
    {MAGIC_LUA53_BC, 5, 0, ".luac", "application/x-lua-bytecode", "Lua 5.3 Bytecode"},
    {MAGIC_LUAJIT_BC, 3, 0, ".luajit", "application/x-luajit-bytecode", "LuaJIT Bytecode"},

    // 压缩格式
    {MAGIC_ZIP, 4, 0, ".zip", "application/zip", "ZIP Archive"},
    {MAGIC_ZIP_EMPTY, 4, 0, ".zip", "application/zip", "ZIP Archive (Empty)"},
    {MAGIC_ZIP_SPANNED, 4, 0, ".zip", "application/zip", "ZIP Archive (Spanned)"},
    {MAGIC_GZIP, 2, 0, ".gz", "application/gzip", "GZIP Archive"},
    {MAGIC_BZIP2, 3, 0, ".bz2", "application/x-bzip2", "BZIP2 Archive"},
    {MAGIC_7Z, 6, 0, ".7z", "application/x-7z-compressed", "7-Zip Archive"},
    {MAGIC_RAR, 6, 0, ".rar", "application/vnd.rar", "RAR Archive"},

    // 文档格式
    {MAGIC_PDF, 4, 0, ".pdf", "application/pdf", "PDF Document"},
    {MAGIC_XML_DECL, 5, 0, ".xml", "application/xml", "XML Document"},
    {MAGIC_CFB, 8, 0, ".cfb", "application/x-cfb", "Compound File Binary"},
    {MAGIC_MDMP, 4, 0, ".dmp", "application/x-minidump", "Windows Minidump"},

    // 可执行格式
    {MAGIC_EXE_MZ, 2, 0, ".exe", "application/x-msdownload", "Windows Executable"},
    {MAGIC_ELF, 4, 0, ".elf", "application/x-executable", "ELF Executable"},

    // MT3 自定义格式
    {MAGIC_ACT, 4, 0, ".act", "application/x-mt3-action", "MT3 Action File"},
    {MAGIC_ANI, 4, 0, ".ani", "application/x-mt3-animation", "MT3 Animation File"},
    {MAGIC_LMX, 4, 0, ".lmx", "application/x-mt3-model", "MT3 Model File"},
    {MAGIC_SPR, 4, 0, ".spr", "application/x-mt3-sprite", "MT3 Sprite File"},
    {MAGIC_FNT, 4, 0, ".fnt", "application/x-mt3-font", "MT3 Font File"},
    {MAGIC_MRMP, 4, 0, ".mrmp", "application/x-mt3-map-editor", "MT3 Map Editor File"},
    {MAGIC_RMAP, 5, 0, ".rmp", "application/x-mt3-map-block", "MT3 Map Block File"},
    {MAGIC_QUYU, 4, 0, ".dat", "application/x-mt3-region-data", "MT3 Region Data"},
    {MAGIC_LDZY, 4, 0, ".bin", "application/x-mt3-table-data", "MT3 Table Data"},
};

static const size_t FILE_TYPE_COUNT = sizeof(FILE_TYPES) / sizeof(FILE_TYPES[0]);

// 文本文件扩展名列表
static const char* TEXT_EXTENSIONS[] = {
    ".lua", ".xml", ".json", ".txt", ".cfg", ".ini", ".atlas",
    ".csv", ".html", ".htm", ".css", ".js", ".md",
    ".yaml", ".yml", ".toml", ".sh", ".bat", ".py",
    ".patch", ".luaproj",
    ".c", ".cpp", ".h", ".hpp", ".java", ".cs",
    ".log", ".conf", ".properties", ".plist"
};

static const size_t TEXT_EXTENSION_COUNT = sizeof(TEXT_EXTENSIONS) / sizeof(TEXT_EXTENSIONS[0]);

// ============================================================================
// 公共方法实现
// ============================================================================

const FileTypeDetector::FileTypeInfo* FileTypeDetector::GetFileTypes() {
    return FILE_TYPES;
}

size_t FileTypeDetector::GetFileTypeCount() {
    return FILE_TYPE_COUNT;
}

size_t FileTypeDetector::GetSupportedTypeCount() {
    return FILE_TYPE_COUNT;
}

std::string FileTypeDetector::GetSupportedExtensions() {
    std::string result;
    for (size_t i = 0; i < FILE_TYPE_COUNT; ++i) {
        if (i > 0) result += ", ";
        result += FILE_TYPES[i].extension;
    }
    result += ", .ptc, .img, .tga";
    return result;
}

std::string FileTypeDetector::DetectRIFFSubtype(const uint8_t* data, size_t size) {
    // RIFF 格式: RIFF + 4字节大小 + 4字节类型 (WAVE/WEBP/AVI/...)
    if (size < 12) {
        return "";
    }

    // 检查 RIFF 头
    if (memcmp(data, MAGIC_RIFF, 4) != 0) {
        return "";
    }

    // 检查子类型 (offset 8)
    if (memcmp(data + 8, "WAVE", 4) == 0) {
        return ".wav";
    } else if (memcmp(data + 8, "WEBP", 4) == 0) {
        return ".webp";
    } else if (memcmp(data + 8, "AVI ", 4) == 0) {
        return ".avi";
    }

    return "";  // 未知 RIFF 子类型
}

std::string FileTypeDetector::DetectTextType(const uint8_t* data, size_t size) {
    if (data == nullptr || size == 0) {
        return "";
    }

    // 跳过 BOM (Byte Order Mark)
    size_t offset = 0;
    if (size >= 3 && data[0] == 0xEF && data[1] == 0xBB && data[2] == 0xBF) {
        offset = 3;  // UTF-8 BOM
    } else if (size >= 2 && ((data[0] == 0xFE && data[1] == 0xFF) ||
                             (data[0] == 0xFF && data[1] == 0xFE))) {
        offset = 2;  // UTF-16 BOM
    }

    if (offset >= size) {
        return "";
    }

    const uint8_t* start = data + offset;
    size_t remaining = size - offset;

    // 跳过空白字符
    while (remaining > 0 && (*start == ' ' || *start == '\t' || *start == '\n' || *start == '\r')) {
        ++start;
        --remaining;
    }

    if (remaining == 0) {
        return "";
    }

    // SVN/Git 补丁文本
    if (StartsWithAsciiLiteralNoCase(start, remaining, "Index: ") &&
        ContainsAsciiLiteral(start, remaining, "--- ") &&
        ContainsAsciiLiteral(start, remaining, "+++ ")) {
        return ".patch";
    }

    // Lua 工程文件（内容是 VS solution，但磁盘扩展名实际为 .luaproj）
    if (ContainsAsciiLiteral(start, remaining, "Microsoft Visual Studio Solution File") &&
        ContainsAsciiLiteralNoCase(start, remaining, ".luaproj")) {
        return ".luaproj";
    }

    // Python 脚本
    if ((StartsWithAsciiLiteralNoCase(start, remaining, "import ") ||
         StartsWithAsciiLiteralNoCase(start, remaining, "from ")) &&
        (ContainsAsciiLiteral(start, remaining, "os.path") ||
         ContainsAsciiLiteral(start, remaining, "def ") ||
         ContainsAsciiLiteral(start, remaining, "__name__"))) {
        return ".py";
    }

    // MT3 剧情脚本文本，真实资源树下通常位于 cfg/movie/*.txt
    if ((StartsWithAsciiLiteralNoCase(start, remaining, "Setmap id=") ||
         StartsWithAsciiLiteralNoCase(start, remaining, "MoveCam pos=")) &&
        (ContainsAsciiLiteralNoCase(start, remaining, "CreateNpc id=") ||
         ContainsAsciiLiteralNoCase(start, remaining, "PlaySound id=") ||
         ContainsAsciiLiteralNoCase(start, remaining, "Wait time="))) {
        return ".txt";
    }

    if (LooksLikeIniSectionedText(start, remaining)) {
        return ".ini";
    }

    // JSON 检测
    if (*start == '{') {
        // 验证 JSON 对象：查找 "
        for (size_t i = 1; i < std::min(remaining, (size_t)50); ++i) {
            if (start[i] == '"') {
                return ".json";
            }
        }
    } else if (*start == '[') {
        // JSON 数组
        return ".json";
    }

    // XML 检测 (不带 <?xml 声明的)
    if (*start == '<') {
        // 检查是否是 HTML
        if (remaining >= 6) {
            // <!DOCTYPE html
            if (start[1] == '!' && remaining >= 15) {
                char doctype[10];
                for (int i = 0; i < 9 && i + 2 < (int)remaining; ++i) {
                    doctype[i] = (char)std::tolower(start[i + 2]);
                }
                doctype[9] = '\0';
                if (strncmp(doctype, "doctype h", 9) == 0) {
                    return ".html";
                }
            }
            // <html
            char tag[5];
            for (int i = 0; i < 4 && i + 1 < (int)remaining; ++i) {
                tag[i] = (char)std::tolower(start[i + 1]);
            }
            tag[4] = '\0';
            if (strncmp(tag, "html", 4) == 0) {
                return ".html";
            }
        }
        return ".xml";
    }

    // Lua 源码检测 (以 -- 注释开头)
    if (remaining >= 2 && start[0] == '-' && start[1] == '-') {
        return ".lua";
    }

    // 检测 "local " 或 "function " (Lua 常见开头)
    if (remaining >= 6) {
        if (memcmp(start, "local ", 6) == 0 || memcmp(start, "functi", 6) == 0) {
            return ".lua";
        }
    }

    // 很多表定义文件以 require "utils.binutil" 开头
    if (remaining >= 8 && std::memcmp(start, "require ", 8) == 0) {
        return ".lua";
    }

    // Lua 配置表常见形式: Foo.Bar = { ... }
    if (LooksLikeLuaTopLevelAssignment(start, remaining)) {
        return ".lua";
    }

    // Spine Atlas: 首行通常是贴图文件名，后续带 size/format/filter/repeat 元信息
    size_t lineEnd = 0;
    while (lineEnd < remaining && start[lineEnd] != '\n' && start[lineEnd] != '\r') {
        ++lineEnd;
    }
    if (lineEnd >= 5 && lineEnd <= 256) {
        std::string firstLine(reinterpret_cast<const char*>(start), lineEnd);
        if (EndsWithNoCase(firstLine, ".png") ||
            EndsWithNoCase(firstLine, ".jpg") ||
            EndsWithNoCase(firstLine, ".jpeg") ||
            EndsWithNoCase(firstLine, ".webp")) {
            const uint8_t* tail = start + lineEnd;
            const size_t tailSize = remaining - lineEnd;
            if (ContainsAsciiLiteral(tail, tailSize, "size:") &&
                ContainsAsciiLiteral(tail, tailSize, "format:") &&
                ContainsAsciiLiteral(tail, tailSize, "filter:")) {
                return ".atlas";
            }
        }
    }

    if (LooksLikePlainText(start, remaining)) {
        return ".txt";
    }

    return "";  // 未知文本类型
}

std::string FileTypeDetector::DetectExtension(const uint8_t* data, size_t size) {
    if (data == nullptr || size == 0) {
        return "";
    }

    // 优先检查 RIFF 子类型 (WAV/WEBP/AVI)
    std::string riffExt = DetectRIFFSubtype(data, size);
    if (!riffExt.empty()) {
        return riffExt;
    }

    if (LooksLikeTga(data, size)) {
        return ".tga";
    }

    // 遍历 Magic Number 表
    const FileTypeInfo* types = GetFileTypes();
    size_t count = GetFileTypeCount();

    for (size_t i = 0; i < count; ++i) {
        const FileTypeInfo& type = types[i];

        // 跳过 RIFF (已单独处理)
        if (type.magic == MAGIC_RIFF) {
            continue;
        }

        // 检查数据大小是否足够
        if (size < type.offset + type.magicLen) {
            continue;
        }

        // 比较 Magic Number
        if (memcmp(data + type.offset, type.magic, type.magicLen) == 0) {
            return type.extension;
        }
    }

    if (LooksLikeMt3ParticlePtc(data, size)) {
        return ".ptc";
    }

    if (LooksLikeNuclearImg(data, size)) {
        return ".img";
    }

    if (LooksLikeMazeDat(data, size) || LooksLikeMonsterDat(data, size)) {
        return ".dat";
    }

    // 尝试检测文本类型
    std::string textExt = DetectTextType(data, size);
    if (!textExt.empty()) {
        return textExt;
    }

    return "";  // 未知类型
}

std::string FileTypeDetector::DetectMimeType(const uint8_t* data, size_t size) {
    if (data == nullptr || size == 0) {
        return "application/octet-stream";
    }

    // 检查 RIFF 子类型
    if (size >= 12 && memcmp(data, MAGIC_RIFF, 4) == 0) {
        if (memcmp(data + 8, "WAVE", 4) == 0) {
            return "audio/wav";
        } else if (memcmp(data + 8, "WEBP", 4) == 0) {
            return "image/webp";
        } else if (memcmp(data + 8, "AVI ", 4) == 0) {
            return "video/x-msvideo";
        }
    }

    if (LooksLikeTga(data, size)) {
        return "image/x-tga";
    }

    // 遍历类型表
    const FileTypeInfo* types = GetFileTypes();
    size_t count = GetFileTypeCount();

    for (size_t i = 0; i < count; ++i) {
        const FileTypeInfo& type = types[i];

        if (type.magic == MAGIC_RIFF) {
            continue;
        }

        if (size < type.offset + type.magicLen) {
            continue;
        }

        if (memcmp(data + type.offset, type.magic, type.magicLen) == 0) {
            return type.mimeType;
        }
    }

    if (LooksLikeMt3ParticlePtc(data, size)) {
        return "application/x-mt3-particle-psl";
    }

    if (LooksLikeNuclearImg(data, size)) {
        return "application/x-nuclear-img";
    }

    if (LooksLikeMazeDat(data, size)) {
        return "application/x-mt3-maze-data";
    }

    if (LooksLikeMonsterDat(data, size)) {
        return "application/x-mt3-monster-data";
    }

    // 尝试文本类型
    std::string ext = DetectTextType(data, size);
    if (ext == ".json") return "application/json";
    if (ext == ".xml") return "application/xml";
    if (ext == ".html") return "text/html";
    if (ext == ".lua") return "text/x-lua";
    if (ext == ".py") return "text/x-python";
    if (ext == ".patch") return "text/x-diff";
    if (ext == ".luaproj" || ext == ".txt" || ext == ".atlas") return "text/plain";

    return "application/octet-stream";
}

std::string FileTypeDetector::DetectDescription(const uint8_t* data, size_t size) {
    if (data == nullptr || size == 0) {
        return "Unknown Binary";
    }

    // 检查 RIFF 子类型
    if (size >= 12 && memcmp(data, MAGIC_RIFF, 4) == 0) {
        if (memcmp(data + 8, "WAVE", 4) == 0) {
            return "WAV Audio";
        } else if (memcmp(data + 8, "WEBP", 4) == 0) {
            return "WebP Image";
        } else if (memcmp(data + 8, "AVI ", 4) == 0) {
            return "AVI Video";
        }
    }

    if (LooksLikeTga(data, size)) {
        return "TGA Image";
    }

    // 遍历类型表
    const FileTypeInfo* types = GetFileTypes();
    size_t count = GetFileTypeCount();

    for (size_t i = 0; i < count; ++i) {
        const FileTypeInfo& type = types[i];

        if (type.magic == MAGIC_RIFF) {
            continue;
        }

        if (size < type.offset + type.magicLen) {
            continue;
        }

        if (memcmp(data + type.offset, type.magic, type.magicLen) == 0) {
            return type.description;
        }
    }

    if (LooksLikeMt3ParticlePtc(data, size)) {
        return "MT3 Particle PSL";
    }

    if (LooksLikeNuclearImg(data, size)) {
        return "Nuclear IMG";
    }

    if (LooksLikeMazeDat(data, size)) {
        return "MT3 Maze Data";
    }

    if (LooksLikeMonsterDat(data, size)) {
        return "MT3 Monster Data";
    }

    // 尝试文本类型
    std::string ext = DetectTextType(data, size);
    if (ext == ".json") return "JSON Document";
    if (ext == ".xml") return "XML Document";
    if (ext == ".html") return "HTML Document";
    if (ext == ".lua") return "Lua Source Code";
    if (ext == ".py") return "Python Source Code";
    if (ext == ".patch") return "Patch File";
    if (ext == ".luaproj") return "Lua Project File";
    if (ext == ".txt") return "Text Document";
    if (ext == ".atlas") return "Spine Atlas";

    return "Unknown Binary";
}

bool FileTypeDetector::IsTextFile(const std::string& extension) {
    if (extension.empty()) {
        return false;
    }

    // 转换为小写进行比较
    std::string lowerExt = extension;
    std::transform(lowerExt.begin(), lowerExt.end(), lowerExt.begin(),
                   [](unsigned char c) { return std::tolower(c); });

    for (size_t i = 0; i < TEXT_EXTENSION_COUNT; ++i) {
        if (lowerExt == TEXT_EXTENSIONS[i]) {
            return true;
        }
    }
    return false;
}

} // namespace SLJFP

#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_AndroidBinaryKey.h"

#include <cstdint>
#include <cstring>
#include <fstream>
#include <vector>

namespace {

#pragma pack(push, 1)
struct TestElf32Header {
    unsigned char e_ident[16];
    uint16_t e_type;
    uint16_t e_machine;
    uint32_t e_version;
    uint32_t e_entry;
    uint32_t e_phoff;
    uint32_t e_shoff;
    uint32_t e_flags;
    uint16_t e_ehsize;
    uint16_t e_phentsize;
    uint16_t e_phnum;
    uint16_t e_shentsize;
    uint16_t e_shnum;
    uint16_t e_shstrndx;
};

struct TestElf32ProgramHeader {
    uint32_t p_type;
    uint32_t p_offset;
    uint32_t p_vaddr;
    uint32_t p_paddr;
    uint32_t p_filesz;
    uint32_t p_memsz;
    uint32_t p_flags;
    uint32_t p_align;
};

struct TestElf32SectionHeader {
    uint32_t sh_name;
    uint32_t sh_type;
    uint32_t sh_flags;
    uint32_t sh_addr;
    uint32_t sh_offset;
    uint32_t sh_size;
    uint32_t sh_link;
    uint32_t sh_info;
    uint32_t sh_addralign;
    uint32_t sh_entsize;
};

struct TestElf32Symbol {
    uint32_t st_name;
    uint32_t st_value;
    uint32_t st_size;
    unsigned char st_info;
    unsigned char st_other;
    uint16_t st_shndx;
};
#pragma pack(pop)

void WriteUInt16Le(std::vector<unsigned char>& data, size_t offset, uint16_t value) {
    data[offset] = static_cast<unsigned char>(value & 0xFFu);
    data[offset + 1] = static_cast<unsigned char>((value >> 8) & 0xFFu);
}

void WriteUInt32Le(std::vector<unsigned char>& data, size_t offset, uint32_t value) {
    data[offset] = static_cast<unsigned char>(value & 0xFFu);
    data[offset + 1] = static_cast<unsigned char>((value >> 8) & 0xFFu);
    data[offset + 2] = static_cast<unsigned char>((value >> 16) & 0xFFu);
    data[offset + 3] = static_cast<unsigned char>((value >> 24) & 0xFFu);
}

void WriteBytes(std::vector<unsigned char>& data, size_t offset, const void* bytes, size_t size) {
    std::memcpy(&data[offset], bytes, size);
}

void WriteCString(std::vector<unsigned char>& data, size_t offset, const std::string& text) {
    std::memcpy(&data[offset], text.c_str(), text.size());
    data[offset + text.size()] = 0;
}

bool WriteSyntheticLibgame(const std::string& path, const std::string& key) {
    const size_t kFileSize = 0x4000;
    const size_t kProgramHeaderOffset = 0x34;
    const size_t kTextOffset = 0x2000;
    const uint32_t kTextAddress = 0x2000;
    const uint32_t kLjDeCodeAddress = 0x2001;
    const uint32_t kStepLoadPackInfoAddress = 0x2101;
    const uint32_t kKeyAddress = 0x3000;
    const size_t kKeyOffset = 0x3000;
    const size_t kShStrOffset = 0x3400;
    const size_t kDynStrOffset = 0x3500;
    const size_t kDynSymOffset = 0x3600;
    const size_t kSectionHeaderOffset = 0x3800;

    std::vector<unsigned char> data(kFileSize, 0);

    TestElf32Header header;
    std::memset(&header, 0, sizeof(header));
    header.e_ident[0] = 0x7F;
    header.e_ident[1] = 'E';
    header.e_ident[2] = 'L';
    header.e_ident[3] = 'F';
    header.e_ident[4] = 1;
    header.e_ident[5] = 1;
    header.e_ident[6] = 1;
    header.e_type = 3;
    header.e_machine = 40;
    header.e_version = 1;
    header.e_phoff = static_cast<uint32_t>(kProgramHeaderOffset);
    header.e_shoff = static_cast<uint32_t>(kSectionHeaderOffset);
    header.e_ehsize = sizeof(header);
    header.e_phentsize = sizeof(TestElf32ProgramHeader);
    header.e_phnum = 1;
    header.e_shentsize = sizeof(TestElf32SectionHeader);
    header.e_shnum = 5;
    header.e_shstrndx = 4;
    WriteBytes(data, 0, &header, sizeof(header));

    TestElf32ProgramHeader ph;
    std::memset(&ph, 0, sizeof(ph));
    ph.p_type = 1;
    ph.p_offset = 0;
    ph.p_vaddr = 0;
    ph.p_paddr = 0;
    ph.p_filesz = static_cast<uint32_t>(kFileSize);
    ph.p_memsz = static_cast<uint32_t>(kFileSize);
    ph.p_flags = 5;
    ph.p_align = 0x1000;
    WriteBytes(data, kProgramHeaderOffset, &ph, sizeof(ph));

    const uint32_t ljDeCodeLiteral = kKeyAddress - (0x2002u + 4u);
    WriteUInt16Le(data, kTextOffset + 0x00, 0x4901);
    WriteUInt16Le(data, kTextOffset + 0x02, 0x4479);
    WriteUInt16Le(data, kTextOffset + 0x04, 0x4770);
    WriteUInt16Le(data, kTextOffset + 0x06, 0x46C0);
    WriteUInt32Le(data, kTextOffset + 0x08, ljDeCodeLiteral);

    const uint32_t stepLiteral = kKeyAddress - (0x2102u + 4u);
    WriteUInt16Le(data, kTextOffset + 0x100, 0x4901);
    WriteUInt16Le(data, kTextOffset + 0x102, 0x4479);
    WriteUInt16Le(data, kTextOffset + 0x104, 0x4770);
    WriteUInt16Le(data, kTextOffset + 0x106, 0x46C0);
    WriteUInt32Le(data, kTextOffset + 0x108, stepLiteral);

    WriteCString(data, kKeyOffset, key);

    const std::string shstr = std::string("\0.text\0.dynsym\0.dynstr\0.shstrtab\0", 35);
    WriteBytes(data, kShStrOffset, shstr.data(), shstr.size());

    const std::string dynstr =
        std::string("\0_Z8LJDeCodeP13LJFP_FileInfoPhRS1_\0_ZN15UpdateManagerEx16StepLoadPackInfoEv\0", 80);
    WriteBytes(data, kDynStrOffset, dynstr.data(), dynstr.size());

    TestElf32Symbol symbols[3];
    std::memset(symbols, 0, sizeof(symbols));
    symbols[1].st_name = 1;
    symbols[1].st_value = kLjDeCodeAddress;
    symbols[1].st_size = 12;
    symbols[1].st_info = 0x12;
    symbols[1].st_shndx = 1;
    symbols[2].st_name = 37;
    symbols[2].st_value = kStepLoadPackInfoAddress;
    symbols[2].st_size = 12;
    symbols[2].st_info = 0x12;
    symbols[2].st_shndx = 1;
    WriteBytes(data, kDynSymOffset, symbols, sizeof(symbols));

    TestElf32SectionHeader sections[5];
    std::memset(sections, 0, sizeof(sections));
    sections[1].sh_name = 1;
    sections[1].sh_type = 1;
    sections[1].sh_flags = 6;
    sections[1].sh_addr = kTextAddress;
    sections[1].sh_offset = static_cast<uint32_t>(kTextOffset);
    sections[1].sh_size = 0x200;
    sections[1].sh_addralign = 4;

    sections[2].sh_name = 7;
    sections[2].sh_type = 11;
    sections[2].sh_offset = static_cast<uint32_t>(kDynSymOffset);
    sections[2].sh_size = sizeof(symbols);
    sections[2].sh_link = 3;
    sections[2].sh_entsize = sizeof(TestElf32Symbol);
    sections[2].sh_addralign = 4;

    sections[3].sh_name = 15;
    sections[3].sh_type = 3;
    sections[3].sh_offset = static_cast<uint32_t>(kDynStrOffset);
    sections[3].sh_size = static_cast<uint32_t>(dynstr.size());
    sections[3].sh_addralign = 1;

    sections[4].sh_name = 23;
    sections[4].sh_type = 3;
    sections[4].sh_offset = static_cast<uint32_t>(kShStrOffset);
    sections[4].sh_size = static_cast<uint32_t>(shstr.size());
    sections[4].sh_addralign = 1;

    WriteBytes(data, kSectionHeaderOffset, sections, sizeof(sections));

    std::ofstream fs(path.c_str(), std::ios::binary | std::ios::trunc);
    if (!fs.is_open()) {
        return false;
    }
    fs.write(reinterpret_cast<const char*>(&data[0]), static_cast<std::streamsize>(data.size()));
    return fs.good();
}

} // namespace

TEST_CASE(AndroidBinaryKey, ExtractFromExplicitLibgamePath) {
    const std::string baseDir = "test_output/android_binary_key_extract";
    const std::string libDir = baseDir + "/lib/armeabi-v7a";
    const std::string libgamePath = libDir + "/libgame.so";
    const std::string expectedKey = "fweqzfw533621d4e7084231";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir + "/lib"));
    TEST_ASSERT_TRUE(CreateTestDirectory(libDir));
    TEST_ASSERT_TRUE(WriteSyntheticLibgame(libgamePath, expectedKey));

    std::string extractedKey;
    std::string message;
    TEST_ASSERT_TRUE(SLJFP::TryExtractAndroidLibgameDecryptKey(libgamePath, extractedKey, &message));
    TEST_ASSERT_EQ(expectedKey, extractedKey);
    TEST_ASSERT_FALSE(message.empty());

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(AndroidBinaryKey, ResolveFromNearbyAndroidRoot) {
    const std::string baseDir = "test_output/android_binary_key_resolve";
    const std::string inputDir = baseDir + "/assets/res";
    const std::string libDir = baseDir + "/lib/armeabi-v7a";
    const std::string libgamePath = libDir + "/libgame.so";
    const std::string expectedKey = "fweqzfw533621d4e7084231";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir + "/assets"));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir + "/lib"));
    TEST_ASSERT_TRUE(CreateTestDirectory(libDir));
    TEST_ASSERT_TRUE(WriteSyntheticLibgame(libgamePath, expectedKey));

    SLJFP::AndroidBinaryKeyProbeResult result;
    TEST_ASSERT_TRUE(SLJFP::TryResolveAndroidLibgameDecryptKey(inputDir, "", result));
    TEST_ASSERT_TRUE(result.found);
    TEST_ASSERT_EQ(expectedKey, result.decryptKey);
    TEST_ASSERT_EQ(libgamePath, result.libgamePath);

    CleanupTestDirectory(baseDir);
    return true;
}

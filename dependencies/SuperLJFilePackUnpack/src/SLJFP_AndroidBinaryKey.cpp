#include "../include/SLJFP_AndroidBinaryKey.h"

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <map>
#include <set>
#include <sstream>
#include <vector>

#ifdef _WIN32
#define NOMINMAX
#include <windows.h>
#else
#include <sys/stat.h>
#endif

namespace SLJFP {
namespace {

const unsigned char kElfMagic[4] = { 0x7F, 'E', 'L', 'F' };
const size_t kElfIdentSize = 16;
const uint16_t kElfTypeLoad = 1;
const uint32_t kSectionTypeDynSym = 11;
const uint16_t kThumbAddR1Pc = 0x4479;

const char* const kLjDeCodeSymbol = "_Z8LJDeCodeP13LJFP_FileInfoPhRS1_";
const char* const kStepLoadPackInfoSymbol = "_ZN15UpdateManagerEx16StepLoadPackInfoEv";

const char* const kLibgameRelativeCandidates[] = {
    "lib/armeabi-v7a/libgame.so",
    "lib/armeabi/libgame.so",
    "lib/arm64-v8a/libgame.so",
    "lib/x86/libgame.so",
    "lib/x86_64/libgame.so",
    "libgame.so"
};

#pragma pack(push, 1)
struct Elf32Header {
    unsigned char e_ident[kElfIdentSize];
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

struct Elf32ProgramHeader {
    uint32_t p_type;
    uint32_t p_offset;
    uint32_t p_vaddr;
    uint32_t p_paddr;
    uint32_t p_filesz;
    uint32_t p_memsz;
    uint32_t p_flags;
    uint32_t p_align;
};

struct Elf32SectionHeader {
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

struct Elf32Symbol {
    uint32_t st_name;
    uint32_t st_value;
    uint32_t st_size;
    unsigned char st_info;
    unsigned char st_other;
    uint16_t st_shndx;
};
#pragma pack(pop)

struct SymbolInfo {
    uint32_t value;
    uint32_t size;

    SymbolInfo()
        : value(0)
        , size(0) {}
};

struct Elf32Image {
    Elf32Header header;
    std::vector<Elf32ProgramHeader> programHeaders;
    std::map<std::string, SymbolInfo> dynSymbols;
};

std::string NormalizeSlashes(const std::string& path) {
    std::string normalized = path;
    for (size_t i = 0; i < normalized.size(); ++i) {
        if (normalized[i] == '\\') {
            normalized[i] = '/';
        }
    }
    return normalized;
}

std::string ToLowerAscii(const std::string& value) {
    std::string lowered = value;
    for (size_t i = 0; i < lowered.size(); ++i) {
        lowered[i] = static_cast<char>(std::tolower(static_cast<unsigned char>(lowered[i])));
    }
    return lowered;
}

bool EndsWithNoCase(const std::string& text, const std::string& suffix) {
    if (text.size() < suffix.size()) {
        return false;
    }

    const size_t offset = text.size() - suffix.size();
    for (size_t i = 0; i < suffix.size(); ++i) {
        const char a = static_cast<char>(std::tolower(static_cast<unsigned char>(text[offset + i])));
        const char b = static_cast<char>(std::tolower(static_cast<unsigned char>(suffix[i])));
        if (a != b) {
            return false;
        }
    }
    return true;
}

std::string JoinPath(const std::string& left, const std::string& right) {
    if (left.empty()) {
        return NormalizeSlashes(right);
    }
    if (right.empty()) {
        return NormalizeSlashes(left);
    }

    std::string result = NormalizeSlashes(left);
    if (!result.empty() && result.back() != '/') {
        result += '/';
    }
    result += NormalizeSlashes(right);
    return result;
}

std::string GetParentDirectory(const std::string& path) {
    const std::string normalized = NormalizeSlashes(path);
    const size_t pos = normalized.find_last_of('/');
    if (pos == std::string::npos) {
        return std::string();
    }
    if (pos == 0) {
        return normalized.substr(0, 1);
    }
    if (pos == 2 && normalized.size() >= 3 && normalized[1] == ':') {
        return normalized.substr(0, 3);
    }
    return normalized.substr(0, pos);
}

bool FileExists(const std::string& path) {
    std::ifstream fs(path.c_str(), std::ios::binary);
    return fs.good();
}

bool DirectoryExists(const std::string& path) {
#ifdef _WIN32
    const DWORD attrs = GetFileAttributesA(path.c_str());
    return attrs != INVALID_FILE_ATTRIBUTES && (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0;
#else
    struct stat st;
    if (stat(path.c_str(), &st) != 0) {
        return false;
    }
    return S_ISDIR(st.st_mode);
#endif
}

bool ReadFileBytes(const std::string& path, std::vector<unsigned char>& outBytes) {
    std::ifstream fs(path.c_str(), std::ios::binary);
    if (!fs.is_open()) {
        return false;
    }

    fs.seekg(0, std::ios::end);
    const std::streamoff size = fs.tellg();
    if (size <= 0) {
        return false;
    }
    fs.seekg(0, std::ios::beg);

    outBytes.resize(static_cast<size_t>(size));
    fs.read(reinterpret_cast<char*>(&outBytes[0]), size);
    return fs.good();
}

bool IsLikelyDecryptKey(const std::string& value) {
    if (value.size() < 16 || value.size() > 64) {
        return false;
    }

    bool hasAlpha = false;
    bool hasDigit = false;
    size_t alnumCount = 0;

    for (size_t i = 0; i < value.size(); ++i) {
        const unsigned char ch = static_cast<unsigned char>(value[i]);
        if (ch < 33 || ch > 126 || ch == '/' || ch == '\\' || ch == '"' || ch == 0x27) {
            return false;
        }
        if (std::isalnum(ch)) {
            ++alnumCount;
        }
        if (std::isalpha(ch)) {
            hasAlpha = true;
        } else if (std::isdigit(ch)) {
            hasDigit = true;
        }
    }

    return hasAlpha && hasDigit && alnumCount >= 16;
}

bool ReadStructAt(const std::vector<unsigned char>& data,
                  size_t offset,
                  void* outStruct,
                  size_t structSize) {
    if (offset > data.size() || structSize > data.size() - offset || outStruct == NULL) {
        return false;
    }

    std::memcpy(outStruct, &data[offset], structSize);
    return true;
}

bool ReadWordAt(const std::vector<unsigned char>& data, size_t offset, uint32_t* outValue) {
    if (outValue == NULL || offset > data.size() || 4 > data.size() - offset) {
        return false;
    }

    *outValue =
        static_cast<uint32_t>(data[offset]) |
        (static_cast<uint32_t>(data[offset + 1]) << 8) |
        (static_cast<uint32_t>(data[offset + 2]) << 16) |
        (static_cast<uint32_t>(data[offset + 3]) << 24);
    return true;
}

bool ReadHalfwordAt(const std::vector<unsigned char>& data, size_t offset, uint16_t* outValue) {
    if (outValue == NULL || offset > data.size() || 2 > data.size() - offset) {
        return false;
    }

    *outValue =
        static_cast<uint16_t>(data[offset]) |
        (static_cast<uint16_t>(data[offset + 1]) << 8);
    return true;
}

bool ParseElf32Image(const std::vector<unsigned char>& data, Elf32Image& outImage, std::string* outMessage) {
    if (data.size() < sizeof(Elf32Header)) {
        if (outMessage != NULL) {
            *outMessage = "ELF header too small";
        }
        return false;
    }

    if (!ReadStructAt(data, 0, &outImage.header, sizeof(Elf32Header))) {
        if (outMessage != NULL) {
            *outMessage = "Failed to read ELF header";
        }
        return false;
    }

    if (std::memcmp(outImage.header.e_ident, kElfMagic, sizeof(kElfMagic)) != 0) {
        if (outMessage != NULL) {
            *outMessage = "Not an ELF file";
        }
        return false;
    }

    if (outImage.header.e_ident[4] != 1 || outImage.header.e_ident[5] != 1) {
        if (outMessage != NULL) {
            *outMessage = "Only ELF32 little-endian Android so is supported";
        }
        return false;
    }

    if (outImage.header.e_phentsize != sizeof(Elf32ProgramHeader)) {
        if (outMessage != NULL) {
            *outMessage = "Unexpected ELF program header size";
        }
        return false;
    }

    if (outImage.header.e_shentsize != sizeof(Elf32SectionHeader)) {
        if (outMessage != NULL) {
            *outMessage = "Unexpected ELF section header size";
        }
        return false;
    }

    outImage.programHeaders.clear();
    outImage.dynSymbols.clear();

    const size_t phEnd = static_cast<size_t>(outImage.header.e_phoff) +
                         static_cast<size_t>(outImage.header.e_phnum) * sizeof(Elf32ProgramHeader);
    if (phEnd > data.size()) {
        if (outMessage != NULL) {
            *outMessage = "ELF program header out of range";
        }
        return false;
    }

    for (uint16_t i = 0; i < outImage.header.e_phnum; ++i) {
        Elf32ProgramHeader ph;
        const size_t offset = static_cast<size_t>(outImage.header.e_phoff) + i * sizeof(Elf32ProgramHeader);
        if (!ReadStructAt(data, offset, &ph, sizeof(Elf32ProgramHeader))) {
            if (outMessage != NULL) {
                *outMessage = "Failed to read ELF program header";
            }
            return false;
        }
        outImage.programHeaders.push_back(ph);
    }

    const size_t shEnd = static_cast<size_t>(outImage.header.e_shoff) +
                         static_cast<size_t>(outImage.header.e_shnum) * sizeof(Elf32SectionHeader);
    if (shEnd > data.size() || outImage.header.e_shstrndx >= outImage.header.e_shnum) {
        if (outMessage != NULL) {
            *outMessage = "ELF section header out of range";
        }
        return false;
    }

    std::vector<Elf32SectionHeader> sections;
    sections.reserve(outImage.header.e_shnum);
    for (uint16_t i = 0; i < outImage.header.e_shnum; ++i) {
        Elf32SectionHeader sh;
        const size_t offset = static_cast<size_t>(outImage.header.e_shoff) + i * sizeof(Elf32SectionHeader);
        if (!ReadStructAt(data, offset, &sh, sizeof(Elf32SectionHeader))) {
            if (outMessage != NULL) {
                *outMessage = "Failed to read ELF section header";
            }
            return false;
        }
        sections.push_back(sh);
    }

    const Elf32SectionHeader& shstr = sections[outImage.header.e_shstrndx];
    if (shstr.sh_offset > data.size() || shstr.sh_size > data.size() - shstr.sh_offset) {
        if (outMessage != NULL) {
            *outMessage = "ELF section name table out of range";
        }
        return false;
    }
    const char* shstrBase = reinterpret_cast<const char*>(&data[shstr.sh_offset]);

    const Elf32SectionHeader* dynsymSection = NULL;
    const Elf32SectionHeader* dynstrSection = NULL;

    for (size_t i = 0; i < sections.size(); ++i) {
        const Elf32SectionHeader& sh = sections[i];
        if (sh.sh_name >= shstr.sh_size) {
            continue;
        }
        const char* name = shstrBase + sh.sh_name;
        if (std::strcmp(name, ".dynsym") == 0 && sh.sh_type == kSectionTypeDynSym) {
            dynsymSection = &sections[i];
        } else if (std::strcmp(name, ".dynstr") == 0) {
            dynstrSection = &sections[i];
        }
    }

    if (dynsymSection == NULL || dynstrSection == NULL) {
        if (outMessage != NULL) {
            *outMessage = "Missing .dynsym / .dynstr";
        }
        return false;
    }

    if (dynsymSection->sh_offset > data.size() ||
        dynsymSection->sh_size > data.size() - dynsymSection->sh_offset ||
        dynsymSection->sh_entsize != sizeof(Elf32Symbol) ||
        dynstrSection->sh_offset > data.size() ||
        dynstrSection->sh_size > data.size() - dynstrSection->sh_offset) {
        if (outMessage != NULL) {
            *outMessage = ".dynsym / .dynstr out of range";
        }
        return false;
    }

    const char* dynstrBase = reinterpret_cast<const char*>(&data[dynstrSection->sh_offset]);
    const size_t symbolCount = dynsymSection->sh_size / sizeof(Elf32Symbol);
    for (size_t i = 0; i < symbolCount; ++i) {
        Elf32Symbol sym;
        const size_t offset = dynsymSection->sh_offset + i * sizeof(Elf32Symbol);
        if (!ReadStructAt(data, offset, &sym, sizeof(Elf32Symbol))) {
            if (outMessage != NULL) {
                *outMessage = "Failed to read ELF symbol";
            }
            return false;
        }

        if (sym.st_name >= dynstrSection->sh_size) {
            continue;
        }

        const char* name = dynstrBase + sym.st_name;
        if (name[0] == '\0' || sym.st_value == 0) {
            continue;
        }

        SymbolInfo symbolInfo;
        symbolInfo.value = sym.st_value;
        symbolInfo.size = sym.st_size;
        outImage.dynSymbols[name] = symbolInfo;
    }

    return true;
}

bool VirtualAddressToFileOffset(const Elf32Image& image,
                                uint32_t virtualAddress,
                                size_t* outOffset) {
    if (outOffset == NULL) {
        return false;
    }

    for (size_t i = 0; i < image.programHeaders.size(); ++i) {
        const Elf32ProgramHeader& ph = image.programHeaders[i];
        if (ph.p_type != kElfTypeLoad) {
            continue;
        }
        if (virtualAddress < ph.p_vaddr || virtualAddress >= ph.p_vaddr + ph.p_filesz) {
            continue;
        }
        *outOffset = static_cast<size_t>(ph.p_offset) + (virtualAddress - ph.p_vaddr);
        return true;
    }

    return false;
}

bool ReadCStringAtAddress(const std::vector<unsigned char>& data,
                          const Elf32Image& image,
                          uint32_t address,
                          size_t maxLength,
                          std::string& outText) {
    outText.clear();

    size_t offset = 0;
    if (!VirtualAddressToFileOffset(image, address, &offset) || offset >= data.size()) {
        return false;
    }

    for (size_t i = offset; i < data.size() && outText.size() < maxLength; ++i) {
        const unsigned char ch = data[i];
        if (ch == '\0') {
            return !outText.empty();
        }
        if (ch < 32 || ch > 126) {
            return false;
        }
        outText.push_back(static_cast<char>(ch));
    }

    return false;
}

bool TryExtractKeyFromFunctionLiteral(const std::vector<unsigned char>& data,
                                      const Elf32Image& image,
                                      const char* symbolName,
                                      std::string& outKey,
                                      std::string* outMessage) {
    std::map<std::string, SymbolInfo>::const_iterator it = image.dynSymbols.find(symbolName);
    if (it == image.dynSymbols.end()) {
        if (outMessage != NULL) {
            *outMessage = std::string("Missing symbol: ") + symbolName;
        }
        return false;
    }

    const uint32_t symbolValue = it->second.value;
    const uint32_t functionAddress = symbolValue & ~1u;
    uint32_t functionSize = it->second.size;
    if (functionSize == 0 || functionSize > 256u) {
        functionSize = 128u;
    }

    size_t functionOffset = 0;
    if (!VirtualAddressToFileOffset(image, functionAddress, &functionOffset) ||
        functionOffset >= data.size()) {
        if (outMessage != NULL) {
            *outMessage = std::string("Cannot map function body: ") + symbolName;
        }
        return false;
    }

    const size_t available = data.size() - functionOffset;
    const size_t scanSize = std::min(static_cast<size_t>(functionSize), available);
    if (scanSize < 6) {
        if (outMessage != NULL) {
            *outMessage = std::string("Function body too small: ") + symbolName;
        }
        return false;
    }

    for (size_t byteOffset = 0; byteOffset + 2 <= scanSize; byteOffset += 2) {
        uint16_t ldrHalfword = 0;
        if (!ReadHalfwordAt(data, functionOffset + byteOffset, &ldrHalfword)) {
            break;
        }

        if ((ldrHalfword & 0xF800u) != 0x4800u) {
            continue;
        }
        if (((ldrHalfword >> 8) & 0x7u) != 1u) {
            continue;
        }

        const uint32_t ldrAddress = functionAddress + static_cast<uint32_t>(byteOffset);
        const uint32_t literalAddress =
            ((ldrAddress + 4u) & ~3u) + static_cast<uint32_t>(ldrHalfword & 0x00FFu) * 4u;

        size_t literalOffset = 0;
        uint32_t literalWord = 0;
        if (!VirtualAddressToFileOffset(image, literalAddress, &literalOffset) ||
            !ReadWordAt(data, literalOffset, &literalWord)) {
            continue;
        }

        for (size_t lookAhead = byteOffset + 2; lookAhead + 2 <= scanSize && lookAhead <= byteOffset + 16; lookAhead += 2) {
            uint16_t addHalfword = 0;
            if (!ReadHalfwordAt(data, functionOffset + lookAhead, &addHalfword)) {
                break;
            }
            if (addHalfword != kThumbAddR1Pc) {
                continue;
            }

            const uint32_t addAddress = functionAddress + static_cast<uint32_t>(lookAhead);
            const uint32_t candidateAddress = addAddress + 4u + literalWord;
            std::string candidate;
            if (!ReadCStringAtAddress(data, image, candidateAddress, 96, candidate)) {
                continue;
            }
            if (!IsLikelyDecryptKey(candidate)) {
                continue;
            }

            outKey = candidate;
            if (outMessage != NULL) {
                *outMessage = std::string("Extracted decrypt key from symbol: ") + symbolName;
            }
            return true;
        }
    }

    if (outMessage != NULL) {
        *outMessage = std::string("No Thumb PC-relative key reference in symbol: ") + symbolName;
    }
    return false;
}

void AppendUniqueCandidate(std::vector<std::string>& candidates, const std::string& path) {
    if (path.empty()) {
        return;
    }
    if (std::find(candidates.begin(), candidates.end(), path) == candidates.end()) {
        candidates.push_back(path);
    }
}

void BuildLibgameCandidatesFromBase(const std::string& basePath, std::vector<std::string>& candidates) {
    if (basePath.empty()) {
        return;
    }

    if (EndsWithNoCase(basePath, ".so")) {
        AppendUniqueCandidate(candidates, NormalizeSlashes(basePath));
        return;
    }

    const std::string normalizedBase = NormalizeSlashes(basePath);
    for (size_t i = 0; i < sizeof(kLibgameRelativeCandidates) / sizeof(kLibgameRelativeCandidates[0]); ++i) {
        AppendUniqueCandidate(candidates, JoinPath(normalizedBase, kLibgameRelativeCandidates[i]));
    }
}

void BuildNearbyLibgameCandidates(const std::string& resourcePathOrDir, std::vector<std::string>& candidates) {
    std::string current = NormalizeSlashes(resourcePathOrDir);
    if (current.empty()) {
        return;
    }

    if (EndsWithNoCase(current, ".ljpi") || EndsWithNoCase(current, ".ljzip") || EndsWithNoCase(current, ".so")) {
        current = GetParentDirectory(current);
    }

    std::set<std::string> visited;
    while (!current.empty()) {
        const std::string key = ToLowerAscii(current);
        if (visited.find(key) != visited.end()) {
            break;
        }
        visited.insert(key);

        BuildLibgameCandidatesFromBase(current, candidates);

        const std::string parent = GetParentDirectory(current);
        if (parent.empty() || parent == current) {
            break;
        }
        current = parent;
    }
}

} // namespace

bool TryExtractAndroidLibgameDecryptKey(const std::string& libgamePath,
                                        std::string& outKey,
                                        std::string* outMessage) {
    outKey.clear();

    std::vector<unsigned char> data;
    if (!ReadFileBytes(libgamePath, data)) {
        if (outMessage != NULL) {
            *outMessage = "Failed to read libgame.so: " + libgamePath;
        }
        return false;
    }

    Elf32Image image;
    std::string parseMessage;
    if (!ParseElf32Image(data, image, &parseMessage)) {
        if (outMessage != NULL) {
            *outMessage = parseMessage;
        }
        return false;
    }

    std::string deCodeKey;
    std::string deCodeMessage;
    const bool foundDeCode =
        TryExtractKeyFromFunctionLiteral(data, image, kLjDeCodeSymbol, deCodeKey, &deCodeMessage);

    std::string packInfoKey;
    std::string packInfoMessage;
    const bool foundPackInfo =
        TryExtractKeyFromFunctionLiteral(data, image, kStepLoadPackInfoSymbol, packInfoKey, &packInfoMessage);

    if (foundDeCode && foundPackInfo && deCodeKey != packInfoKey) {
        if (outMessage != NULL) {
            *outMessage = "LJDeCode and StepLoadPackInfo resolved different keys";
        }
        return false;
    }

    if (foundDeCode) {
        outKey = deCodeKey;
        if (outMessage != NULL) {
            *outMessage = deCodeMessage;
        }
        return true;
    }

    if (foundPackInfo) {
        outKey = packInfoKey;
        if (outMessage != NULL) {
            *outMessage = packInfoMessage;
        }
        return true;
    }

    if (outMessage != NULL) {
        if (!deCodeMessage.empty()) {
            *outMessage = deCodeMessage;
        } else if (!packInfoMessage.empty()) {
            *outMessage = packInfoMessage;
        } else {
            *outMessage = "Failed to extract decrypt key from libgame.so";
        }
    }
    return false;
}

bool TryResolveAndroidLibgameDecryptKey(const std::string& resourcePathOrDir,
                                        const std::string& explicitLibgamePathOrDir,
                                        AndroidBinaryKeyProbeResult& outResult) {
    outResult = AndroidBinaryKeyProbeResult();

    std::vector<std::string> candidates;
    if (!explicitLibgamePathOrDir.empty()) {
        BuildLibgameCandidatesFromBase(explicitLibgamePathOrDir, candidates);
    }
    BuildNearbyLibgameCandidates(resourcePathOrDir, candidates);

    std::string firstFailure;
    for (size_t i = 0; i < candidates.size(); ++i) {
        const std::string candidate = candidates[i];
        if (!FileExists(candidate)) {
            continue;
        }

        std::string key;
        std::string message;
        if (TryExtractAndroidLibgameDecryptKey(candidate, key, &message)) {
            outResult.found = true;
            outResult.libgamePath = candidate;
            outResult.decryptKey = key;
            outResult.message = message;
            return true;
        }

        if (firstFailure.empty()) {
            firstFailure = candidate + ": " + message;
        }
    }

    if (!firstFailure.empty()) {
        outResult.message = firstFailure;
    } else if (!explicitLibgamePathOrDir.empty()) {
        outResult.message = "No libgame.so found near: " + explicitLibgamePathOrDir;
    } else {
        outResult.message = "No Android libgame.so with extractable key found near input";
    }
    return false;
}

} // namespace SLJFP

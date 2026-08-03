/**
 * @file Test_RegressionFixtures.cpp
 * @brief Repository-backed regression fixtures for real unpack samples.
 */

#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

namespace {

struct OrangeSubsetSnapshot {
    std::string relativePath;
    size_t size;
    uint32_t contentCRC32;

    OrangeSubsetSnapshot()
        : size(0)
        , contentCRC32(0) {
    }
};

bool FileExistsForRegression(const std::string& path) {
    std::ifstream fs(path.c_str(), std::ios::binary);
    return fs.good();
}

std::string JoinRegressionPath(const std::string& base, const std::string& child) {
    if (base.empty()) {
        return child;
    }
    const char last = base[base.size() - 1];
    if (last == '/' || last == '\\') {
        return base + child;
    }
    return base + "/" + child;
}

std::vector<std::string> SplitTabFields(const std::string& line) {
    std::vector<std::string> fields;
    std::string field;
    std::istringstream iss(line);
    while (std::getline(iss, field, '\t')) {
        fields.push_back(field);
    }
    return fields;
}

std::string GetFileNameForRegression(const std::string& path) {
    const std::string::size_type pos = path.find_last_of("/\\");
    if (pos == std::string::npos) {
        return path;
    }
    return path.substr(pos + 1);
}

std::string GetExtensionForRegression(const std::string& path) {
    const std::string fileName = GetFileNameForRegression(path);
    const std::string::size_type pos = fileName.find_last_of('.');
    if (pos == std::string::npos) {
        return std::string();
    }
    return fileName.substr(pos);
}

bool ParseUnsignedCrc32(const std::string& text, uint32_t* outValue) {
    if (outValue == NULL || text.empty()) {
        return false;
    }

    char* endPtr = NULL;
    unsigned long parsed = 0;
    if (text.size() > 2 && text[0] == '0' && (text[1] == 'x' || text[1] == 'X')) {
        parsed = std::strtoul(text.c_str() + 2, &endPtr, 16);
    } else {
        parsed = std::strtoul(text.c_str(), &endPtr, 10);
    }

    if (endPtr == NULL || *endPtr != '\0') {
        return false;
    }

    *outValue = static_cast<uint32_t>(parsed);
    return true;
}

bool ResolveOrangeSubsetRepoPrefix(std::string* outPrefix) {
    if (outPrefix == NULL) {
        return false;
    }
    outPrefix->clear();

    std::string probe = ".";
    for (int depth = 0; depth < 12; ++depth) {
        const std::string fixtureIndex = JoinRegressionPath(
            probe, "tools/LJFilePackUnpacker/work/orange_subset/input/fl.ljpi");
        const std::string baselineManifest = JoinRegressionPath(
            probe, "tools/LJFilePackUnpacker/work/orange_subset/output_auto_diag/unpack_path_manifest.tsv");
        if (FileExistsForRegression(fixtureIndex) && FileExistsForRegression(baselineManifest)) {
            *outPrefix = probe;
            return true;
        }
        probe = JoinRegressionPath(probe, "..");
    }

    return false;
}

bool LoadOrangeSubsetSnapshots(const std::string& rootDir,
                               const std::string& manifestPath,
                               std::map<uint32_t, OrangeSubsetSnapshot>& outSnapshots) {
    outSnapshots.clear();

    std::ifstream manifest(manifestPath.c_str(), std::ios::binary);
    if (!manifest.is_open()) {
        return false;
    }

    std::string line;
    if (!std::getline(manifest, line)) {
        return false;
    }

    while (std::getline(manifest, line)) {
        if (line.empty()) {
            continue;
        }

        const std::vector<std::string> fields = SplitTabFields(line);
        if (fields.size() < 6) {
            continue;
        }

        uint32_t pathCRC32 = 0;
        if (!ParseUnsignedCrc32(fields[0], &pathCRC32)) {
            continue;
        }

        const std::string relativePath = fields[5];
        std::vector<unsigned char> bytes;
        if (!ReadTestFile(JoinRegressionPath(rootDir, relativePath), bytes)) {
            return false;
        }

        OrangeSubsetSnapshot snapshot;
        snapshot.relativePath = relativePath;
        snapshot.size = bytes.size();
        snapshot.contentCRC32 = SLJFP_crc32(
            0,
            bytes.empty() ? reinterpret_cast<const unsigned char*>("") : &bytes[0],
            static_cast<unsigned int>(bytes.size()));
        outSnapshots[pathCRC32] = snapshot;
    }

    return !outSnapshots.empty();
}

bool LoadCurrentOrangeSubsetSnapshot(const std::string& outputRoot,
                                     const OrangeSubsetSnapshot& baselineSnapshot,
                                     OrangeSubsetSnapshot* outSnapshot) {
    if (outSnapshot == NULL) {
        return false;
    }

    std::vector<std::string> candidates;
    candidates.push_back(baselineSnapshot.relativePath);

    std::string bucket = GetExtensionForRegression(baselineSnapshot.relativePath);
    if (!bucket.empty() && bucket[0] == '.') {
        bucket = bucket.substr(1);
    }
    if (bucket.empty()) {
        bucket = "noext";
    }
    candidates.push_back("review/unresolved/" + bucket + "/" +
                         GetFileNameForRegression(baselineSnapshot.relativePath));

    for (size_t i = 0; i < candidates.size(); ++i) {
        std::vector<unsigned char> bytes;
        if (!ReadTestFile(JoinRegressionPath(outputRoot, candidates[i]), bytes)) {
            continue;
        }

        outSnapshot->relativePath = candidates[i];
        outSnapshot->size = bytes.size();
        outSnapshot->contentCRC32 = SLJFP_crc32(
            0,
            bytes.empty() ? reinterpret_cast<const unsigned char*>("") : &bytes[0],
            static_cast<unsigned int>(bytes.size()));
        return true;
    }

    return false;
}

} // namespace

TEST_CASE(RegressionFixtures, OrangeSubsetMatchesHistoricalDecodedBaseline) {
    std::string repoPrefix;
    TEST_ASSERT_TRUE(ResolveOrangeSubsetRepoPrefix(&repoPrefix));

    const std::string fixtureInputDir = JoinRegressionPath(
        repoPrefix, "tools/LJFilePackUnpacker/work/orange_subset/input");
    const std::string baselineOutputDir = JoinRegressionPath(
        repoPrefix, "tools/LJFilePackUnpacker/work/orange_subset/output_auto_diag");
    const std::string baselineManifestPath = JoinRegressionPath(
        baselineOutputDir, "unpack_path_manifest.tsv");

    std::map<uint32_t, OrangeSubsetSnapshot> baselineSnapshots;
    TEST_ASSERT_TRUE(LoadOrangeSubsetSnapshots(
        baselineOutputDir, baselineManifestPath, baselineSnapshots));
    TEST_ASSERT_EQ(static_cast<size_t>(10), baselineSnapshots.size());
    TEST_ASSERT_TRUE(baselineSnapshots.find(0xF848F16Bu) != baselineSnapshots.end());
    TEST_ASSERT_TRUE(baselineSnapshots.find(0x0214152Bu) != baselineSnapshots.end());
    TEST_ASSERT_TRUE(baselineSnapshots.find(0x1E35552Fu) != baselineSnapshots.end());
    TEST_ASSERT_TRUE(baselineSnapshots.find(0x16D8382Du) != baselineSnapshots.end());
    std::map<uint32_t, OrangeSubsetSnapshot> stableBaselineSnapshots = baselineSnapshots;
    stableBaselineSnapshots.erase(0xF848F16Bu);
    stableBaselineSnapshots.erase(0x0214152Bu);
    stableBaselineSnapshots.erase(0x1E35552Fu);
    stableBaselineSnapshots.erase(0x16D8382Du);
    TEST_ASSERT_EQ(static_cast<size_t>(6), stableBaselineSnapshots.size());

    const std::string tempRoot = "test_output/orange_subset_regression_fixture";
    const std::string unpackOutputDir = tempRoot + "/output";
    CleanupTestDirectory(tempRoot);
    TEST_ASSERT_TRUE(CreateTestDirectory(tempRoot));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS,
                   unpacker.LoadIndex(JoinRegressionPath(fixtureInputDir, "fl.ljpi")));

    SLJFP::UnpackOptions options;
    options.verifyCRC32 = true;
    options.overwriteExisting = true;
    options.createDirectories = true;
    options.threadCount = 1;
    options.detectFileType = true;
    options.preferPathMapping = true;
    options.organizeByType = false;
    options.forceCrcOutputFirst = true;
    options.restorePathStructureAfterUnpack = true;
    options.relocateRootNumericResiduals = true;
    options.writePathManifest = true;
    options.decryptMode = SLJFP::DecryptMode::Auto;

    const int unpackResult = unpacker.UnpackAll(fixtureInputDir, unpackOutputDir, options);
    TEST_ASSERT_TRUE(unpackResult == (int)SLJFP::LJFP_SUCCESS ||
                     unpackResult == (int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE);

    std::vector<SLJFP::FailedFileRecord> failedFiles = unpacker.GetLastFailedFiles();
    std::map<uint32_t, bool> knownGapSet;
    knownGapSet[0xF848F16Bu] = true;
    knownGapSet[0x0214152Bu] = true;
    knownGapSet[0x1E35552Fu] = true;
    knownGapSet[0x16D8382Du] = true;
    for (size_t i = 0; i < failedFiles.size(); ++i) {
        TEST_ASSERT_TRUE(knownGapSet.find(failedFiles[i].pathCRC32) != knownGapSet.end());
    }

    TEST_ASSERT_TRUE(unpacker.GetProcessedFiles() >= stableBaselineSnapshots.size());

    for (std::map<uint32_t, OrangeSubsetSnapshot>::const_iterator it = stableBaselineSnapshots.begin();
         it != stableBaselineSnapshots.end();
         ++it) {
        OrangeSubsetSnapshot currentSnapshot;
        TEST_ASSERT_TRUE(LoadCurrentOrangeSubsetSnapshot(
            unpackOutputDir, it->second, &currentSnapshot));
        TEST_ASSERT_EQ(it->second.size, currentSnapshot.size);
        TEST_ASSERT_EQ(it->second.contentCRC32, currentSnapshot.contentCRC32);
    }

    CleanupTestDirectory(tempRoot);
    return true;
}

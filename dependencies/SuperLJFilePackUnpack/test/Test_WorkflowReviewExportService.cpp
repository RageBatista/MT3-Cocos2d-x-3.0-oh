#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_WorkflowReviewExportService.h"
#include "../include/SLJFP_LibsWrapper.h"

namespace SLJFP {
namespace Test {

namespace {

std::string ReadTestText(const std::string& path) {
    std::vector<unsigned char> data;
    if (!ReadTestFile(path, data)) {
        return std::string();
    }
    return std::string(reinterpret_cast<const char*>(data.data()), data.size());
}

} // namespace

TEST_CASE(WorkflowReviewExportService, ExportsFailedItemsForAllAndSubsetScopes) {
    const std::string baseDir = "test_output/workflow_review_export";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string reportDir = baseDir + "/artifacts/review";
    const std::string indexPath = inputDir + "/sample.ljpi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::string okPath = "review/ok.bin";
    const std::string missingPathA = "review/missing_a.bin";
    const std::string missingPathB = "review/missing_b.bin";
    const std::vector<unsigned char> okPayload = BuildUtf8Text("ok-data");

    const unsigned int okPathCrc = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(okPath.data()),
        static_cast<unsigned int>(okPath.size()));
    const unsigned int missingPathCrcA = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(missingPathA.data()),
        static_cast<unsigned int>(missingPathA.size()));
    const unsigned int missingPathCrcB = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(missingPathB.data()),
        static_cast<unsigned int>(missingPathB.size()));
    const unsigned int okDataCrc = SLJFP_crc32(0,
        okPayload.data(),
        static_cast<unsigned int>(okPayload.size()));

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(okPathCrc), okPayload));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 3);
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
    AppendUInt32Le(indexData, missingPathCrcA);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 32);
    AppendUInt32Le(indexData, 0x87654321u);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, missingPathCrcB);
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
    selectedIndices.push_back(2);

    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE,
                   unpacker.UnpackSelected(selectedIndices, inputDir, outputDir, options));
    TEST_ASSERT_EQ(2u, unpacker.GetFailedFiles());

    WorkflowReviewExportService::Result allResult =
        WorkflowReviewExportService::ExportFailedItems(&unpacker, reportDir, NULL);
    TEST_ASSERT_TRUE(allResult.ok());
    TEST_ASSERT_EQ((size_t)2, allResult.exportedCount);

    const std::string allTsv = ReadTestText(allResult.tsvPath);
    const std::string allJson = ReadTestText(allResult.jsonPath);
    TEST_ASSERT_FALSE(allTsv.empty());
    TEST_ASSERT_FALSE(allJson.empty());
    TEST_ASSERT_TRUE(allTsv.find("file_index\tpath_crc32") != std::string::npos);
    TEST_ASSERT_TRUE(allTsv.find("\n1\t") != std::string::npos);
    TEST_ASSERT_TRUE(allTsv.find("\n2\t") != std::string::npos);
    TEST_ASSERT_TRUE(allJson.find("\"group\": \"all_failed\"") != std::string::npos);

    WorkflowReviewExportService::Scope scope;
    scope.label = L"crc errors";
    scope.fileIndices.push_back(2);

    WorkflowReviewExportService::Result scopedResult =
        WorkflowReviewExportService::ExportFailedItems(&unpacker, reportDir, &scope);
    TEST_ASSERT_TRUE(scopedResult.ok());
    TEST_ASSERT_EQ((size_t)1, scopedResult.exportedCount);
    TEST_ASSERT_TRUE(scopedResult.basePath.find("review_failed_items_crc_errors") != std::string::npos);

    const std::string scopedTsv = ReadTestText(scopedResult.tsvPath);
    TEST_ASSERT_TRUE(scopedTsv.find("\n2\t") != std::string::npos);
    TEST_ASSERT_TRUE(scopedTsv.find("\n1\t") == std::string::npos);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(WorkflowReviewExportService, JsonPreservesUtf8FailedItemPaths) {
    const std::string baseDir = "test_output/workflow_review_export_utf8_json";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string reportDir = baseDir + "/reports";
    const std::string indexPath = inputDir + "/sample.ljpi";
    const std::string mappingPath = inputDir + "/sample.map";
    const std::string missingPath = "review/中文/缺失.bin";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const unsigned int pathCrc = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(missingPath.data()),
        static_cast<unsigned int>(missingPath.size()));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 16);
    AppendUInt32Le(indexData, 0x12345678u);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(WriteBinaryVector(indexPath, indexData));

    {
        std::ofstream mappingFile(mappingPath.c_str(), std::ios::binary | std::ios::trunc);
        TEST_ASSERT_TRUE(mappingFile.is_open());
        mappingFile << pathCrc << "|" << missingPath << "\n";
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
    options.detectFileType = false;
    options.organizeByType = false;
    options.threadCount = 1;

    std::vector<size_t> selectedIndices;
    selectedIndices.push_back(0);
    TEST_ASSERT_EQ((int)SLJFP::LJFP_ERROR_PARTIAL_FAILURE,
                   unpacker.UnpackSelected(selectedIndices, inputDir, outputDir, options));

    WorkflowReviewExportService::Result result =
        WorkflowReviewExportService::ExportFailedItems(&unpacker, reportDir, NULL);
    TEST_ASSERT_TRUE(result.ok());
    TEST_ASSERT_EQ((size_t)1, result.exportedCount);

    const std::string json = ReadTestText(result.jsonPath);
    TEST_ASSERT_TRUE(json.find(missingPath) != std::string::npos);
    TEST_ASSERT_TRUE(json.find("\\u00E4") == std::string::npos);

    CleanupTestDirectory(baseDir);
    return true;
}

TEST_CASE(WorkflowReviewExportService, ReturnsErrorWhenNoFailuresExist) {
    const std::string baseDir = "test_output/workflow_review_export_empty";
    const std::string inputDir = baseDir + "/input";
    const std::string outputDir = baseDir + "/output";
    const std::string reportDir = baseDir + "/reports";
    const std::string indexPath = inputDir + "/sample.ljpi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(outputDir));

    const std::string logicalPath = "review/ok.bin";
    const std::vector<unsigned char> payload = BuildUtf8Text("ok-data");
    const unsigned int pathCrc = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(logicalPath.data()),
        static_cast<unsigned int>(logicalPath.size()));
    const unsigned int dataCrc = SLJFP_crc32(0,
        payload.data(),
        static_cast<unsigned int>(payload.size()));

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), payload));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, static_cast<unsigned int>(payload.size()));
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

    std::vector<size_t> selectedIndices;
    selectedIndices.push_back(0);
    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS,
                   unpacker.UnpackSelected(selectedIndices, inputDir, outputDir, options));

    const WorkflowReviewExportService::Result exportResult =
        WorkflowReviewExportService::ExportFailedItems(&unpacker, reportDir, NULL);
    TEST_ASSERT_FALSE(exportResult.ok());
    TEST_ASSERT(exportResult.error == WorkflowReviewExportService::Error::NoFailedFiles);

    CleanupTestDirectory(baseDir);
    return true;
}

} // namespace Test
} // namespace SLJFP

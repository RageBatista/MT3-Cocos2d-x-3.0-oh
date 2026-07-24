#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_WorkflowPresenter.h"
#include "../include/SLJFP_LibsWrapper.h"

namespace SLJFP {
namespace Test {

namespace {

bool ContainsText(const std::wstring& text, const wchar_t* needle) {
    return text.find(needle) != std::wstring::npos;
}

bool ContainsText(const std::string& text, const char* needle) {
    return text.find(needle) != std::string::npos;
}

const WorkflowPresenter::ReviewIssueGroup* FindGroup(
    const WorkflowPresenter::ReviewPanelModel& model,
    const wchar_t* key) {
    for (size_t i = 0; i < model.groups.size(); ++i) {
        if (model.groups[i].key == key) {
            return &model.groups[i];
        }
    }
    return NULL;
}

} // namespace

TEST_CASE(WorkflowPresenter, BuildsNoSourceReviewModel) {
    WorkflowSessionController session;

    const WorkflowPresenter::ReviewPanelModel model =
        WorkflowPresenter::BuildReviewPanelModel(session, NULL, L"");

    TEST_ASSERT_EQ((size_t)1, model.groups.size());
    TEST_ASSERT_NOT_NULL(FindGroup(model, L"prepare:no_source"));
    TEST_ASSERT_FALSE(model.canLocate);

    return true;
}

TEST_CASE(WorkflowPresenter, BuildsReviewModelFromSessionState) {
    WorkflowSessionController session;
    session.SetSourceData("sample.ljpi", "input", 12, 2048, true);
    session.SetMappingData(4, true, 9, 12, 7500, "mapping.txt", "");

    std::vector<uint32_t> missingSamples;
    missingSamples.push_back(0x12345678u);
    session.SetMappingGuidance(true, missingSamples, "needs mapping repair");

    UnpackOptions options;
    options.threadCount = 4;
    options.verifyCRC32 = true;
    options.useStreamMode = true;
    options.overwriteExisting = true;
    options.organizeByType = true;
    session.SetExecutionPlan("output", options);

    session.BeginRun(12);
    session.FinishRun(LJFP_ERROR_PARTIAL_FAILURE, 10, 2, 0, 0, "done");

    std::vector<std::pair<int, uint32_t> > errorBreakdown;
    errorBreakdown.push_back(std::make_pair(500, 2u));

    DecryptFailureDiagnostic diagnostic;
    diagnostic.valid = true;
    diagnostic.fileIndex = 3;
    diagnostic.inputSize = 64;
    diagnostic.failureCode = 304;

    DecryptProbeRecord candidate;
    candidate.candidateId = "runtime-key";
    candidate.mode = DecryptMode::ApkClientObf;
    candidate.crcChecked = true;
    candidate.crcMatched = false;
    diagnostic.candidates.push_back(candidate);

    session.SetReviewData(500, 3u, "broken/file.bin", errorBreakdown, &diagnostic);

    const WorkflowPresenter::ReviewPanelModel model =
        WorkflowPresenter::BuildReviewPanelModel(session, NULL, L"error-500");

    const WorkflowPresenter::ReviewIssueGroup* mappingGroup =
        FindGroup(model, L"mapping:needs_attention");
    TEST_ASSERT_NOT_NULL(mappingGroup);
    TEST_ASSERT_TRUE(mappingGroup->rerunnable);

    const WorkflowPresenter::ReviewIssueGroup* runSummaryGroup =
        FindGroup(model, L"run:summary");
    TEST_ASSERT_NOT_NULL(runSummaryGroup);

    const WorkflowPresenter::ReviewIssueGroup* firstFailureGroup =
        FindGroup(model, L"failure:first");
    TEST_ASSERT_NOT_NULL(firstFailureGroup);
    TEST_ASSERT_EQ(3L, firstFailureGroup->primaryFileIndex);
    TEST_ASSERT_TRUE(firstFailureGroup->rerunnable);

    const WorkflowPresenter::ReviewIssueGroup* decryptGroup =
        FindGroup(model, L"failure:decrypt_diagnostic");
    TEST_ASSERT_NOT_NULL(decryptGroup);
    TEST_ASSERT_EQ(3L, decryptGroup->primaryFileIndex);

    TEST_ASSERT_TRUE(ContainsText(model.summary, L"broken/file.bin"));
    TEST_ASSERT_TRUE(ContainsText(model.summary, L"error-500"));
    TEST_ASSERT_TRUE(model.canLocate);

    return true;
}

TEST_CASE(WorkflowPresenter, BuildsOverviewAndStatusModels) {
    WorkflowSessionController session;
    session.SetSourceData("sample.ljpi", "input", 12, 4096, true);
    session.SetMappingData(4, true, 9, 12, 7500, "mapping.txt", "generated.ljpm");

    std::vector<uint32_t> missingSamples;
    missingSamples.push_back(0x11111111u);
    session.SetMappingGuidance(true, missingSamples, "needs mapping repair");

    UnpackOptions options;
    options.threadCount = 2;
    options.verifyCRC32 = true;
    options.organizeByType = true;
    session.SetExecutionPlan("output", options);

    FileInfo fileInfo;
    fileInfo.m_PackIndex = 3;
    fileInfo.m_PathFileNameCRC32 = 0x22222222u;
    session.SetPreviewSelection(5, fileInfo, "preview/item.bin", true, "output/preview/item.bin", false);
    session.SetFilter(WorkflowSessionController::TreeFilterMode::PackFiles, 3);

    const WorkflowPresenter::OverviewPanelModel overview =
        WorkflowPresenter::BuildOverviewPanelModel(session, L"error-500");
    TEST_ASSERT_TRUE(ContainsText(overview.text, L"sample.ljpi"));
    TEST_ASSERT_TRUE(ContainsText(overview.text, L"mapping.txt"));
    TEST_ASSERT_TRUE(ContainsText(overview.text, L"output"));
    TEST_ASSERT_TRUE(ContainsText(overview.text, L"preview/item.bin"));
    TEST_ASSERT_TRUE(ContainsText(overview.text, L"error-500"));

    const WorkflowPresenter::StatusBarModel status =
        WorkflowPresenter::BuildStatusBarModel(session, NULL, true, false, 5, L"error-500");
    TEST_ASSERT_FALSE(status.primaryText.empty());
    TEST_ASSERT_TRUE(ContainsText(status.secondaryText, L"error-500"));
    TEST_ASSERT_TRUE(ContainsText(status.fileCountText, L"5"));
    TEST_ASSERT_TRUE(ContainsText(status.fileCountText, L"12"));

    return true;
}

TEST_CASE(WorkflowPresenter, BuildsPreviewOutputPathFromExecutionPlan) {
    const std::string baseDir = "test_output/workflow_presenter_preview";
    const std::string inputDir = baseDir + "/input";
    const std::string indexPath = inputDir + "/sample.ljpi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));

    const std::string logicalPath = "preview/item.bin";
    const std::vector<unsigned char> fileData = BuildUtf8Text("preview-data");
    const unsigned int pathCrc = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(logicalPath.data()),
        static_cast<unsigned int>(logicalPath.size()));
    const unsigned int dataCrc = SLJFP_crc32(0,
        fileData.data(),
        static_cast<unsigned int>(fileData.size()));

    TEST_ASSERT_TRUE(WriteBinaryVector(inputDir + "/" + std::to_string(pathCrc), fileData));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, static_cast<unsigned int>(fileData.size()));
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

    WorkflowSessionController session;
    session.SetSourceData(indexPath, inputDir, 1, fileData.size(), true);

    UnpackOptions options;
    options.organizeByType = true;
    options.preferPathMapping = true;
    session.SetExecutionPlan("preview-output", options);

    const std::string displayPath = unpacker.GetFilePath(0);
    const std::string previewPath =
        WorkflowPresenter::BuildPreviewOutputPath(session, &unpacker, 0);
    TEST_ASSERT_TRUE(ContainsText(previewPath, "preview-output/unknown/"));
    TEST_ASSERT_TRUE(ContainsText(previewPath, displayPath.c_str()));

    options.organizeByType = false;
    options.preferPathMapping = false;
    session.SetExecutionPlan("preview-output", options);
    const std::string plainPreviewPath =
        WorkflowPresenter::BuildPreviewOutputPath(session, &unpacker, 0);
    TEST_ASSERT_TRUE(ContainsText(plainPreviewPath, "preview-output/"));
    TEST_ASSERT_TRUE(ContainsText(plainPreviewPath, displayPath.c_str()));

    WorkflowSessionController emptySession;
    TEST_ASSERT_TRUE(WorkflowPresenter::BuildPreviewOutputPath(emptySession, &unpacker, 0).empty());

    CleanupTestDirectory(baseDir);
    return true;
}

} // namespace Test
} // namespace SLJFP

#include "SLJFP_TestFramework.h"
#include "../gui/SLJFP_WorkflowSession.h"

namespace SLJFP {
namespace Test {

TEST_CASE(WorkflowSession, TracksStageFlow) {
    WorkflowSessionController session;

    TEST_ASSERT_TRUE(session.GetActiveStage() == WorkflowSessionController::Stage::SourceData);
    TEST_ASSERT_FALSE(session.GetStepStatus(WorkflowSessionController::Stage::SourceData).complete);

    session.SetSourceData("fl.ljpi", "input", 12, 1024, true);
    TEST_ASSERT_TRUE(session.GetActiveStage() == WorkflowSessionController::Stage::MappingHealth);
    TEST_ASSERT_TRUE(session.GetStepStatus(WorkflowSessionController::Stage::SourceData).complete);

    session.SetMappingData(16, true, 9, 12, 7500, "mapping.txt", "");
    TEST_ASSERT_TRUE(session.GetActiveStage() == WorkflowSessionController::Stage::ExecutionPlan);
    TEST_ASSERT_TRUE(session.GetStepStatus(WorkflowSessionController::Stage::MappingHealth).complete);

    UnpackOptions options;
    options.threadCount = 4;
    session.SetExecutionPlan("output", options);
    TEST_ASSERT_TRUE(session.GetStepStatus(WorkflowSessionController::Stage::ExecutionPlan).complete);

    session.BeginRun(12);
    session.UpdateRunProgress(5, 12);
    TEST_ASSERT_TRUE(session.GetActiveStage() == WorkflowSessionController::Stage::ResultReview);
    TEST_ASSERT_TRUE(session.GetRunState().running);
    TEST_ASSERT_EQ(5u, session.GetRunState().currentCount);

    session.SetPaused(true);
    TEST_ASSERT_TRUE(session.GetRunState().paused);

    session.FinishRun(LJFP_SUCCESS, 12, 0, 0, 0, "done");
    TEST_ASSERT_TRUE(session.GetStepStatus(WorkflowSessionController::Stage::ResultReview).complete);
    TEST_ASSERT_FALSE(session.GetRunState().running);
    TEST_ASSERT_EQ(12u, session.GetRunState().successCount);

    return true;
}

TEST_CASE(WorkflowSession, MatchesTreeFilters) {
    WorkflowSessionController session;
    FileInfo loose;
    loose.m_PackIndex = 0;
    FileInfo packed;
    packed.m_PackIndex = 3;

    session.SetFilter(WorkflowSessionController::TreeFilterMode::AllFiles);
    TEST_ASSERT_TRUE(session.MatchesFilter(loose, false));
    TEST_ASSERT_TRUE(session.MatchesFilter(packed, true));

    session.SetFilter(WorkflowSessionController::TreeFilterMode::LooseFiles);
    TEST_ASSERT_TRUE(session.MatchesFilter(loose, false));
    TEST_ASSERT_FALSE(session.MatchesFilter(packed, false));

    session.SetFilter(WorkflowSessionController::TreeFilterMode::PackFiles, 3);
    TEST_ASSERT_TRUE(session.MatchesFilter(packed, false));
    TEST_ASSERT_FALSE(session.MatchesFilter(loose, false));

    session.SetFilter(WorkflowSessionController::TreeFilterMode::MappedFiles);
    TEST_ASSERT_TRUE(session.MatchesFilter(packed, true));
    TEST_ASSERT_FALSE(session.MatchesFilter(loose, false));

    session.SetFilter(WorkflowSessionController::TreeFilterMode::UnmappedFiles);
    TEST_ASSERT_TRUE(session.MatchesFilter(loose, false));
    TEST_ASSERT_FALSE(session.MatchesFilter(packed, true));

    return true;
}

TEST_CASE(WorkflowSession, StoresMappingGuidanceAndReviewData) {
    WorkflowSessionController session;
    std::vector<uint32_t> missingSamples;
    missingSamples.push_back(0x12345678u);
    missingSamples.push_back(0x9ABCDEF0u);

    session.SetSourceData("sample.ljpi", "input", 8, 4096, true);
    session.SetMappingData(4, true, 6, 8, 7500, "mapping.txt", "generated.ljpm");
    session.SetMappingGuidance(true, missingSamples, "needs mapping repair");

    TEST_ASSERT_TRUE(session.GetMappingState().needsAttention);
    TEST_ASSERT_EQ((size_t)2, session.GetMappingState().missingSamples.size());
    TEST_ASSERT_EQ(std::string("needs mapping repair"), session.GetMappingState().guidance);

    std::vector<std::pair<int, uint32_t> > errors;
    errors.push_back(std::make_pair(500, 2u));
    errors.push_back(std::make_pair(304, 1u));

    DecryptFailureDiagnostic diagnostic;
    diagnostic.valid = true;
    diagnostic.fileIndex = 3;
    diagnostic.failureCode = 304;

    session.SetReviewData(500, 3u, "broken/file.bin", errors, &diagnostic);

    TEST_ASSERT_TRUE(session.GetReviewState().available);
    TEST_ASSERT_EQ(500, session.GetReviewState().firstErrorCode);
    TEST_ASSERT_EQ(3u, session.GetReviewState().firstErrorFileIndex);
    TEST_ASSERT_EQ(std::string("broken/file.bin"), session.GetReviewState().firstErrorPath);
    TEST_ASSERT_EQ((size_t)2, session.GetReviewState().errorBreakdown.size());
    TEST_ASSERT_TRUE(session.GetReviewState().hasDecryptDiagnostic);
    TEST_ASSERT_EQ(3u, session.GetReviewState().decryptDiagnostic.fileIndex);

    session.ClearReviewData();
    TEST_ASSERT_FALSE(session.GetReviewState().available);

    return true;
}

} // namespace Test
} // namespace SLJFP

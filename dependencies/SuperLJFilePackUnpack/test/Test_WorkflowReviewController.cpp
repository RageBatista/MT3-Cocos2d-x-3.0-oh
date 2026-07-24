#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_WorkflowReviewController.h"
#include "../include/SLJFP_LibsWrapper.h"

#include <cstring>

namespace SLJFP {
namespace Test {

namespace {

WorkflowReviewController::ReviewIssueGroup MakeReviewGroup(const wchar_t* key,
                                                          const wchar_t* subject,
                                                          const wchar_t* filterLabel,
                                                          bool filterable,
                                                          bool rerunnable,
                                                          long primaryFileIndex,
                                                          const std::vector<size_t>& fileIndices) {
    WorkflowReviewController::ReviewIssueGroup group;
    group.key = key;
    group.category = L"category";
    group.subject = subject;
    group.detail = L"detail";
    group.filterLabel = filterLabel;
    group.filterable = filterable;
    group.rerunnable = rerunnable;
    group.primaryFileIndex = primaryFileIndex;
    group.fileIndices = fileIndices;
    return group;
}

} // namespace

TEST_CASE(WorkflowReviewController, TracksSelectionAndFilterAcrossRefresh) {
    WorkflowReviewController controller;

    std::vector<size_t> issueAIndices;
    issueAIndices.push_back(1);
    issueAIndices.push_back(3);

    std::vector<WorkflowReviewController::ReviewIssueGroup> groups;
    groups.push_back(MakeReviewGroup(L"issue:a", L"issue-a", L"filter-a", true, true, 1, issueAIndices));
    groups.push_back(MakeReviewGroup(L"issue:b", L"issue-b", L"", false, false, -1, std::vector<size_t>()));

    controller.SetIssueGroups(groups);
    controller.RememberSelectionByRow(0);

    TEST_ASSERT_EQ(0L, controller.ResolveSelectedRow());
    TEST_ASSERT_TRUE(controller.ApplyFilterForGroup(controller.GetIssueGroupByRow(0)));
    TEST_ASSERT_TRUE(controller.HasActiveFilter());
    TEST_ASSERT_TRUE(controller.MatchesActiveFilter(1));
    TEST_ASSERT_TRUE(controller.MatchesActiveFilter(3));
    TEST_ASSERT_FALSE(controller.MatchesActiveFilter(2));
    TEST_ASSERT(controller.GetActiveFilterLabel() == L"filter-a");

    std::vector<size_t> refreshedIndices;
    refreshedIndices.push_back(3);
    std::vector<WorkflowReviewController::ReviewIssueGroup> refreshedGroups;
    refreshedGroups.push_back(MakeReviewGroup(L"issue:a", L"issue-a", L"filter-a", true, true, 3, refreshedIndices));
    refreshedGroups.push_back(MakeReviewGroup(L"issue:c", L"issue-c", L"", false, false, -1, std::vector<size_t>()));

    controller.SetIssueGroups(refreshedGroups);

    TEST_ASSERT_EQ(0L, controller.ResolveSelectedRow());
    TEST_ASSERT_FALSE(controller.MatchesActiveFilter(1));
    TEST_ASSERT_TRUE(controller.MatchesActiveFilter(3));
    TEST_ASSERT_TRUE(controller.ClearFilter());
    TEST_ASSERT_FALSE(controller.HasActiveFilter());

    return true;
}

TEST_CASE(WorkflowReviewController, BuildsLocateAndRerunRequests) {
    WorkflowReviewController controller;

    std::vector<size_t> rerunIndices;
    rerunIndices.push_back(5);
    rerunIndices.push_back(7);
    const WorkflowReviewController::ReviewIssueGroup group =
        MakeReviewGroup(L"issue:rerun", L"issue-rerun", L"filter-rerun", true, true, 5, rerunIndices);

    TEST_ASSERT_TRUE(WorkflowReviewController::CanRerunGroup(&group, false));
    TEST_ASSERT_FALSE(WorkflowReviewController::CanRerunGroup(&group, true));

    std::vector<size_t> builtIndices;
    std::wstring builtSubject;
    TEST_ASSERT_TRUE(WorkflowReviewController::BuildRerunRequest(&group, builtIndices, builtSubject));
    TEST_ASSERT_EQ((size_t)2, builtIndices.size());
    TEST_ASSERT_EQ((size_t)5, builtIndices[0]);
    TEST_ASSERT_EQ((size_t)7, builtIndices[1]);
    TEST_ASSERT(builtSubject == L"issue-rerun");

    WorkflowSessionController session;
    size_t locatedFileIndex = static_cast<size_t>(-1);
    TEST_ASSERT_TRUE(WorkflowReviewController::TryResolveLocateFileIndex(&group, session, NULL, locatedFileIndex));
    TEST_ASSERT_EQ((size_t)5, locatedFileIndex);

    std::vector<std::pair<int, uint32_t> > errors;
    errors.push_back(std::make_pair(500, 1u));
    session.SetReviewData(500, 9u, "broken.bin", errors, NULL);

    locatedFileIndex = static_cast<size_t>(-1);
    TEST_ASSERT_TRUE(WorkflowReviewController::TryResolveLocateFileIndex(NULL, session, NULL, locatedFileIndex));
    TEST_ASSERT_EQ((size_t)9, locatedFileIndex);

    return true;
}

TEST_CASE(WorkflowReviewController, FallsBackToMappingSamplesForLocate) {
    const std::string baseDir = "test_output/workflow_review_controller_locate";
    const std::string inputDir = baseDir + "/input";
    const std::string indexPath = inputDir + "/sample.ljpi";

    CleanupTestDirectory(baseDir);
    TEST_ASSERT_TRUE(CreateTestDirectory(baseDir));
    TEST_ASSERT_TRUE(CreateTestDirectory(inputDir));

    const std::string logicalPath = "locate/missing.bin";
    const char* payloadText = "demo-data";
    const unsigned int payloadSize = static_cast<unsigned int>(std::strlen(payloadText));
    const unsigned int pathCrc = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(logicalPath.data()),
        static_cast<unsigned int>(logicalPath.size()));
    const unsigned int dataCrc = SLJFP_crc32(0,
        reinterpret_cast<const unsigned char*>(payloadText),
        payloadSize);

    TEST_ASSERT_TRUE(CreateTestFile(inputDir + "/" + std::to_string(pathCrc),
                                    reinterpret_cast<const unsigned char*>(payloadText),
                                    payloadSize));

    std::vector<unsigned char> indexData;
    AppendUInt32Le(indexData, 1);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, payloadSize);
    AppendUInt32Le(indexData, dataCrc);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, 0);
    AppendUInt32Le(indexData, pathCrc);
    TEST_ASSERT_TRUE(CreateTestFile(indexPath, indexData.data(), indexData.size()));

    SLJFP::Unpacker unpacker(
        SLJFP_crc32,
        SLJFP_mz_compress2,
        SLJFP_mz_uncompress,
        SLJFP_SMS4Ex,
        SLJFP_DeSMS4Ex
    );

    TEST_ASSERT_EQ((int)SLJFP::LJFP_SUCCESS, unpacker.LoadIndex(indexPath));

    WorkflowSessionController session;
    std::vector<uint32_t> missingSamples;
    missingSamples.push_back(pathCrc);
    session.SetSourceData(indexPath, inputDir, 1, payloadSize, true);
    session.SetMappingData(0, false, 0, 0, 0, "", "");
    session.SetMappingGuidance(true, missingSamples, "needs mapping");

    size_t locatedFileIndex = static_cast<size_t>(-1);
    TEST_ASSERT_TRUE(WorkflowReviewController::TryResolveLocateFileIndex(NULL, session, &unpacker, locatedFileIndex));
    TEST_ASSERT_EQ((size_t)0, locatedFileIndex);

    CleanupTestDirectory(baseDir);
    return true;
}

} // namespace Test
} // namespace SLJFP

#ifndef SLJFP_WORKFLOW_REVIEW_CONTROLLER_H
#define SLJFP_WORKFLOW_REVIEW_CONTROLLER_H

#include "SLJFP_WorkflowPresenter.h"
#include "../gui/SLJFP_WorkflowSession.h"

#include <set>
#include <string>
#include <vector>

namespace SLJFP {

class WorkflowReviewController {
public:
    typedef WorkflowPresenter::ReviewIssueGroup ReviewIssueGroup;

    WorkflowReviewController();

    void Reset();
    void SetIssueGroups(const std::vector<ReviewIssueGroup>& groups);

    const std::vector<ReviewIssueGroup>& GetIssueGroups() const;
    const ReviewIssueGroup* GetIssueGroupByRow(long row) const;

    void RememberSelectionByRow(long row);
    long ResolveSelectedRow() const;

    bool ApplyFilterForGroup(const ReviewIssueGroup* group);
    bool ClearFilter();
    bool HasActiveFilter() const;
    bool MatchesActiveFilter(size_t fileIndex) const;
    const std::wstring& GetActiveFilterLabel() const;

    static bool CanRerunGroup(const ReviewIssueGroup* group, bool isUnpacking);
    static bool BuildRerunRequest(const ReviewIssueGroup* group,
                                 std::vector<size_t>& outFileIndices,
                                 std::wstring& outSubject);
    static bool TryResolveLocateFileIndex(const ReviewIssueGroup* group,
                                          const WorkflowSessionController& session,
                                          const Unpacker* unpacker,
                                          size_t& outFileIndex);

private:
    const ReviewIssueGroup* FindGroupByKey(const std::wstring& key) const;
    void RefreshActiveFilterFromKey();

    std::vector<ReviewIssueGroup> m_groups;
    std::wstring m_selectedGroupKey;
    std::wstring m_activeFilterKey;
    std::wstring m_activeFilterLabel;
    std::set<size_t> m_activeFilterIndices;
};

} // namespace SLJFP

#endif // SLJFP_WORKFLOW_REVIEW_CONTROLLER_H

#include "../include/SLJFP_WorkflowReviewController.h"

namespace SLJFP {

WorkflowReviewController::WorkflowReviewController() {
    Reset();
}

void WorkflowReviewController::Reset() {
    m_groups.clear();
    m_selectedGroupKey.clear();
    m_activeFilterKey.clear();
    m_activeFilterLabel.clear();
    m_activeFilterIndices.clear();
}

void WorkflowReviewController::SetIssueGroups(const std::vector<ReviewIssueGroup>& groups) {
    m_groups = groups;
    if (!m_selectedGroupKey.empty() && FindGroupByKey(m_selectedGroupKey) == NULL) {
        m_selectedGroupKey.clear();
    }
    RefreshActiveFilterFromKey();
}

const std::vector<WorkflowReviewController::ReviewIssueGroup>&
WorkflowReviewController::GetIssueGroups() const {
    return m_groups;
}

const WorkflowReviewController::ReviewIssueGroup*
WorkflowReviewController::GetIssueGroupByRow(long row) const {
    if (row < 0 || static_cast<size_t>(row) >= m_groups.size()) {
        return NULL;
    }
    return &m_groups[static_cast<size_t>(row)];
}

void WorkflowReviewController::RememberSelectionByRow(long row) {
    const ReviewIssueGroup* group = GetIssueGroupByRow(row);
    m_selectedGroupKey = (group != NULL) ? group->key : std::wstring();
}

long WorkflowReviewController::ResolveSelectedRow() const {
    if (m_selectedGroupKey.empty()) {
        return -1;
    }

    for (size_t i = 0; i < m_groups.size(); ++i) {
        if (m_groups[i].key == m_selectedGroupKey) {
            return static_cast<long>(i);
        }
    }
    return -1;
}

bool WorkflowReviewController::ApplyFilterForGroup(const ReviewIssueGroup* group) {
    std::wstring nextFilterKey;
    std::wstring nextFilterLabel;
    std::set<size_t> nextFilterIndices;

    if (group != NULL && group->filterable) {
        nextFilterKey = group->key;
        nextFilterLabel = group->filterLabel;
        nextFilterIndices.insert(group->fileIndices.begin(), group->fileIndices.end());
    }

    if (nextFilterKey == m_activeFilterKey &&
        nextFilterLabel == m_activeFilterLabel &&
        nextFilterIndices == m_activeFilterIndices) {
        return false;
    }

    m_activeFilterKey.swap(nextFilterKey);
    m_activeFilterLabel.swap(nextFilterLabel);
    m_activeFilterIndices.swap(nextFilterIndices);
    return true;
}

bool WorkflowReviewController::ClearFilter() {
    if (!HasActiveFilter()) {
        return false;
    }

    m_activeFilterKey.clear();
    m_activeFilterLabel.clear();
    m_activeFilterIndices.clear();
    return true;
}

bool WorkflowReviewController::HasActiveFilter() const {
    return !m_activeFilterIndices.empty() || !m_activeFilterLabel.empty();
}

bool WorkflowReviewController::MatchesActiveFilter(size_t fileIndex) const {
    return m_activeFilterIndices.empty() ||
           m_activeFilterIndices.find(fileIndex) != m_activeFilterIndices.end();
}

const std::wstring& WorkflowReviewController::GetActiveFilterLabel() const {
    return m_activeFilterLabel;
}

bool WorkflowReviewController::CanRerunGroup(const ReviewIssueGroup* group, bool isUnpacking) {
    return !isUnpacking &&
           group != NULL &&
           group->rerunnable &&
           !group->fileIndices.empty();
}

bool WorkflowReviewController::BuildRerunRequest(const ReviewIssueGroup* group,
                                                 std::vector<size_t>& outFileIndices,
                                                 std::wstring& outSubject) {
    outFileIndices.clear();
    outSubject.clear();

    if (group == NULL || !group->rerunnable || group->fileIndices.empty()) {
        return false;
    }

    outFileIndices = group->fileIndices;
    outSubject = group->subject;
    return true;
}

bool WorkflowReviewController::TryResolveLocateFileIndex(const ReviewIssueGroup* group,
                                                         const WorkflowSessionController& session,
                                                         const Unpacker* unpacker,
                                                         size_t& outFileIndex) {
    if (group != NULL) {
        if (group->primaryFileIndex >= 0) {
            outFileIndex = static_cast<size_t>(group->primaryFileIndex);
            return true;
        }
        if (!group->fileIndices.empty()) {
            outFileIndex = group->fileIndices.front();
            return true;
        }
    }

    const WorkflowSessionController::ReviewState& review = session.GetReviewState();
    if (review.available &&
        review.firstErrorFileIndex != static_cast<uint32_t>(-1)) {
        outFileIndex = static_cast<size_t>(review.firstErrorFileIndex);
        return true;
    }

    if (unpacker != NULL) {
        const WorkflowSessionController::MappingState& mapping = session.GetMappingState();
        if (!mapping.missingSamples.empty()) {
            const int fileIndex = unpacker->FindFileByCRC32(mapping.missingSamples[0]);
            if (fileIndex >= 0) {
                outFileIndex = static_cast<size_t>(fileIndex);
                return true;
            }
        }
    }

    return false;
}

const WorkflowReviewController::ReviewIssueGroup*
WorkflowReviewController::FindGroupByKey(const std::wstring& key) const {
    if (key.empty()) {
        return NULL;
    }

    for (size_t i = 0; i < m_groups.size(); ++i) {
        if (m_groups[i].key == key) {
            return &m_groups[i];
        }
    }
    return NULL;
}

void WorkflowReviewController::RefreshActiveFilterFromKey() {
    if (m_activeFilterKey.empty()) {
        m_activeFilterLabel.clear();
        m_activeFilterIndices.clear();
        return;
    }

    const ReviewIssueGroup* group = FindGroupByKey(m_activeFilterKey);
    if (group == NULL || !group->filterable) {
        m_activeFilterKey.clear();
        m_activeFilterLabel.clear();
        m_activeFilterIndices.clear();
        return;
    }

    m_activeFilterLabel = group->filterLabel;
    m_activeFilterIndices.clear();
    m_activeFilterIndices.insert(group->fileIndices.begin(), group->fileIndices.end());
}

} // namespace SLJFP

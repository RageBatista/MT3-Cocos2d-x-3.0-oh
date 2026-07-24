#ifndef SLJFP_WORKFLOW_PRESENTER_H
#define SLJFP_WORKFLOW_PRESENTER_H

#include "SLJFP_Unpack.h"
#include "../gui/SLJFP_WorkflowSession.h"

#include <string>
#include <vector>

namespace SLJFP {

class WorkflowPresenter {
public:
    struct ReviewIssueGroup {
        std::wstring key;
        std::wstring category;
        std::wstring subject;
        std::wstring detail;
        std::wstring filterLabel;
        std::vector<size_t> fileIndices;
        long primaryFileIndex;
        bool rerunnable;
        bool filterable;

        ReviewIssueGroup();
    };

    struct ReviewPanelModel {
        std::wstring summary;
        std::vector<ReviewIssueGroup> groups;
        bool canLocate;

        ReviewPanelModel();
    };

    struct OverviewPanelModel {
        std::wstring text;
    };

    struct StatusBarModel {
        std::wstring primaryText;
        std::wstring secondaryText;
        std::wstring fileCountText;
    };

    static ReviewPanelModel BuildReviewPanelModel(
        const WorkflowSessionController& session,
        const Unpacker* unpacker,
        const std::wstring& activeReviewFilterLabel);

    static OverviewPanelModel BuildOverviewPanelModel(
        const WorkflowSessionController& session,
        const std::wstring& activeReviewFilterLabel);

    static StatusBarModel BuildStatusBarModel(
        const WorkflowSessionController& session,
        const Unpacker* unpacker,
        bool hasLoadedIndex,
        bool isUnpacking,
        long visibleFiles,
        const std::wstring& activeReviewFilterLabel);

    static std::string BuildPreviewOutputPath(
        const WorkflowSessionController& session,
        const Unpacker* unpacker,
        size_t fileIndex);
};

} // namespace SLJFP

#endif // SLJFP_WORKFLOW_PRESENTER_H

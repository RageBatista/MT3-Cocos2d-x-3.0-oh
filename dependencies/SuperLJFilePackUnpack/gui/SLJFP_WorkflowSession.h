#ifndef SLJFP_WORKFLOW_SESSION_H
#define SLJFP_WORKFLOW_SESSION_H

#include "../include/SLJFP_Unpack.h"

#include <cstddef>
#include <cstdint>
#include <string>
#include <utility>
#include <vector>

namespace SLJFP {

class WorkflowSessionController {
public:
    enum class Stage {
        SourceData = 0,
        MappingHealth,
        ExecutionPlan,
        ResultReview
    };

    enum class TreeFilterMode {
        AllFiles = 0,
        LooseFiles,
        PackFiles,
        MappedFiles,
        UnmappedFiles
    };

    struct StepStatus {
        bool complete;
        bool active;

        StepStatus()
            : complete(false)
            , active(false) {
        }
    };

    struct SourceState {
        bool loaded;
        std::string indexPath;
        std::string inputDir;
        uint32_t totalFiles;
        uint64_t totalBytes;

        SourceState()
            : loaded(false)
            , totalFiles(0)
            , totalBytes(0) {
        }
    };

    struct MappingState {
        bool loaded;
        bool hasHitRate;
        bool needsAttention;
        size_t mappingCount;
        uint32_t hitCount;
        uint32_t totalCount;
        uint32_t rateBasis;
        std::string mappingPath;
        std::string generatedPath;
        std::vector<uint32_t> missingSamples;
        std::string guidance;

        MappingState()
            : loaded(false)
            , hasHitRate(false)
            , needsAttention(false)
            , mappingCount(0)
            , hitCount(0)
            , totalCount(0)
            , rateBasis(0) {
        }
    };

    struct ExecutionState {
        bool configured;
        bool outputReady;
        std::string outputDir;
        UnpackOptions options;

        ExecutionState()
            : configured(false)
            , outputReady(false) {
        }
    };

    struct RunState {
        bool running;
        bool paused;
        bool stopping;
        bool finished;
        int result;
        uint32_t currentCount;
        uint32_t totalCount;
        uint32_t successCount;
        uint32_t failedCount;
        uint32_t skippedCount;
        uint32_t emptyCount;
        std::string summary;

        RunState()
            : running(false)
            , paused(false)
            , stopping(false)
            , finished(false)
            , result(0)
            , currentCount(0)
            , totalCount(0)
            , successCount(0)
            , failedCount(0)
            , skippedCount(0)
            , emptyCount(0) {
        }
    };

    struct ReviewState {
        bool available;
        int firstErrorCode;
        uint32_t firstErrorFileIndex;
        std::string firstErrorPath;
        std::vector<std::pair<int, uint32_t> > errorBreakdown;
        bool hasDecryptDiagnostic;
        DecryptFailureDiagnostic decryptDiagnostic;

        ReviewState()
            : available(false)
            , firstErrorCode(0)
            , firstErrorFileIndex(static_cast<uint32_t>(-1))
            , hasDecryptDiagnostic(false) {
        }
    };

    struct PreviewState {
        bool selected;
        size_t fileIndex;
        FileInfo fileInfo;
        std::string displayPath;
        bool mappingHit;
        std::string outputPath;
        bool outputExists;

        PreviewState()
            : selected(false)
            , fileIndex(0)
            , mappingHit(false)
            , outputExists(false) {
        }
    };

    struct TreeFilter {
        TreeFilterMode mode;
        uint32_t packIndex;

        TreeFilter()
            : mode(TreeFilterMode::AllFiles)
            , packIndex(0) {
        }
    };

    WorkflowSessionController() {
        Reset();
    }

    void Reset() {
        m_source = SourceState();
        m_mapping = MappingState();
        m_execution = ExecutionState();
        m_run = RunState();
        m_review = ReviewState();
        m_preview = PreviewState();
        m_filter = TreeFilter();
    }

    void SetSourceData(const std::string& indexPath,
                       const std::string& inputDir,
                       uint32_t totalFiles,
                       uint64_t totalBytes,
                       bool loaded) {
        m_source.indexPath = indexPath;
        m_source.inputDir = inputDir;
        m_source.totalFiles = totalFiles;
        m_source.totalBytes = totalBytes;
        m_source.loaded = loaded;
    }

    void SetMappingData(size_t mappingCount,
                        bool hasHitRate,
                        uint32_t hitCount,
                        uint32_t totalCount,
                        uint32_t rateBasis,
                        const std::string& mappingPath,
                        const std::string& generatedPath) {
        m_mapping.mappingCount = mappingCount;
        m_mapping.loaded = (mappingCount > 0);
        m_mapping.hasHitRate = hasHitRate;
        m_mapping.hitCount = hitCount;
        m_mapping.totalCount = totalCount;
        m_mapping.rateBasis = rateBasis;
        m_mapping.mappingPath = mappingPath;
        m_mapping.generatedPath = generatedPath;
    }

    void SetMappingGuidance(bool needsAttention,
                            const std::vector<uint32_t>& missingSamples,
                            const std::string& guidance) {
        m_mapping.needsAttention = needsAttention;
        m_mapping.missingSamples = missingSamples;
        m_mapping.guidance = guidance;
    }

    void SetExecutionPlan(const std::string& outputDir,
                          const UnpackOptions& options) {
        m_execution.configured = true;
        m_execution.outputDir = outputDir;
        m_execution.outputReady = !outputDir.empty();
        m_execution.options = options;
    }

    void BeginRun(uint32_t totalCount) {
        m_run.running = true;
        m_run.paused = false;
        m_run.stopping = false;
        m_run.finished = false;
        m_run.result = 0;
        m_run.currentCount = 0;
        m_run.totalCount = totalCount;
        m_run.successCount = 0;
        m_run.failedCount = 0;
        m_run.skippedCount = 0;
        m_run.emptyCount = 0;
        m_run.summary.clear();
        m_review = ReviewState();
    }

    void UpdateRunProgress(uint32_t currentCount, uint32_t totalCount) {
        m_run.currentCount = currentCount;
        if (totalCount > 0) {
            m_run.totalCount = totalCount;
        }
    }

    void SetPaused(bool paused) {
        m_run.paused = paused;
        if (paused) {
            m_run.running = true;
        }
    }

    void RequestStop() {
        m_run.stopping = true;
        m_run.running = true;
    }

    void FinishRun(int result,
                   uint32_t successCount,
                   uint32_t failedCount,
                   uint32_t skippedCount,
                   uint32_t emptyCount,
                   const std::string& summary) {
        m_run.running = false;
        m_run.paused = false;
        m_run.stopping = false;
        m_run.finished = true;
        m_run.result = result;
        m_run.successCount = successCount;
        m_run.failedCount = failedCount;
        m_run.skippedCount = skippedCount;
        m_run.emptyCount = emptyCount;
        m_run.currentCount = successCount + failedCount + skippedCount + emptyCount;
        if (m_run.totalCount < m_run.currentCount) {
            m_run.totalCount = m_run.currentCount;
        }
        m_run.summary = summary;
    }

    void SetReviewData(int firstErrorCode,
                       uint32_t firstErrorFileIndex,
                       const std::string& firstErrorPath,
                       const std::vector<std::pair<int, uint32_t> >& errorBreakdown,
                       const DecryptFailureDiagnostic* decryptDiagnostic = nullptr) {
        m_review.available = (firstErrorCode != 0) ||
                             !errorBreakdown.empty() ||
                             (decryptDiagnostic != nullptr && decryptDiagnostic->valid);
        m_review.firstErrorCode = firstErrorCode;
        m_review.firstErrorFileIndex = firstErrorFileIndex;
        m_review.firstErrorPath = firstErrorPath;
        m_review.errorBreakdown = errorBreakdown;
        m_review.hasDecryptDiagnostic = (decryptDiagnostic != nullptr && decryptDiagnostic->valid);
        if (m_review.hasDecryptDiagnostic) {
            m_review.decryptDiagnostic = *decryptDiagnostic;
        } else {
            m_review.decryptDiagnostic = DecryptFailureDiagnostic();
        }
    }

    void ClearReviewData() {
        m_review = ReviewState();
    }

    void SetPreviewSelection(size_t fileIndex,
                             const FileInfo& fileInfo,
                             const std::string& displayPath,
                             bool mappingHit,
                             const std::string& outputPath,
                             bool outputExists) {
        m_preview.selected = true;
        m_preview.fileIndex = fileIndex;
        m_preview.fileInfo = fileInfo;
        m_preview.displayPath = displayPath;
        m_preview.mappingHit = mappingHit;
        m_preview.outputPath = outputPath;
        m_preview.outputExists = outputExists;
    }

    void ClearPreviewSelection() {
        m_preview = PreviewState();
    }

    void SetFilter(TreeFilterMode mode, uint32_t packIndex = 0) {
        m_filter.mode = mode;
        m_filter.packIndex = packIndex;
    }

    bool MatchesFilter(const FileInfo& fileInfo, bool mappingHit) const {
        switch (m_filter.mode) {
            case TreeFilterMode::LooseFiles:
                return fileInfo.m_PackIndex == 0;
            case TreeFilterMode::PackFiles:
                return fileInfo.m_PackIndex == m_filter.packIndex;
            case TreeFilterMode::MappedFiles:
                return mappingHit;
            case TreeFilterMode::UnmappedFiles:
                return !mappingHit;
            case TreeFilterMode::AllFiles:
            default:
                return true;
        }
    }

    Stage GetActiveStage() const {
        if (m_run.running || m_run.finished || m_run.stopping) {
            return Stage::ResultReview;
        }
        if (!m_source.loaded) {
            return Stage::SourceData;
        }
        if (!m_mapping.loaded) {
            return Stage::MappingHealth;
        }
        return Stage::ExecutionPlan;
    }

    StepStatus GetStepStatus(Stage stage) const {
        StepStatus status;
        status.active = (GetActiveStage() == stage);

        switch (stage) {
            case Stage::SourceData:
                status.complete = m_source.loaded;
                break;
            case Stage::MappingHealth:
                status.complete = m_mapping.loaded;
                break;
            case Stage::ExecutionPlan:
                status.complete = m_execution.outputReady;
                break;
            case Stage::ResultReview:
                status.complete = m_run.finished;
                break;
            default:
                status.complete = false;
                break;
        }

        return status;
    }

    const SourceState& GetSourceState() const { return m_source; }
    const MappingState& GetMappingState() const { return m_mapping; }
    const ExecutionState& GetExecutionState() const { return m_execution; }
    const RunState& GetRunState() const { return m_run; }
    const ReviewState& GetReviewState() const { return m_review; }
    const PreviewState& GetPreviewState() const { return m_preview; }
    const TreeFilter& GetFilter() const { return m_filter; }

private:
    SourceState m_source;
    MappingState m_mapping;
    ExecutionState m_execution;
    RunState m_run;
    ReviewState m_review;
    PreviewState m_preview;
    TreeFilter m_filter;
};

} // namespace SLJFP

#endif // SLJFP_WORKFLOW_SESSION_H

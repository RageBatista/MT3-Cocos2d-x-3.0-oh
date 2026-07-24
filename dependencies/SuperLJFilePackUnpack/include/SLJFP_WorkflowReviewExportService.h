#ifndef SLJFP_WORKFLOW_REVIEW_EXPORT_SERVICE_H
#define SLJFP_WORKFLOW_REVIEW_EXPORT_SERVICE_H

#include "SLJFP_Unpack.h"

#include <string>
#include <vector>

namespace SLJFP {

class WorkflowReviewExportService {
public:
    struct Scope {
        std::wstring label;
        std::vector<size_t> fileIndices;

        Scope();
    };

    enum class Error {
        None = 0,
        MissingUnpacker,
        MissingOutputDir,
        OutputDirCreateFailed,
        NoFailedFiles,
        NoMatchingFailedItems,
        OutputFileOpenFailed
    };

    struct Result {
        Error error;
        std::string basePath;
        std::string tsvPath;
        std::string jsonPath;
        size_t exportedCount;

        Result();

        bool ok() const {
            return error == Error::None;
        }
    };

    static Result ExportFailedItems(const Unpacker* unpacker,
                                    const std::string& outputDir,
                                    const Scope* scope);
};

} // namespace SLJFP

#endif // SLJFP_WORKFLOW_REVIEW_EXPORT_SERVICE_H

#pragma once

#include <string>
#include <vector>

struct OperationResult
{
    bool success;
    bool cancelled;
    std::wstring title;
    std::wstring summary;
    std::wstring outputPath;
    int successCount;
    int failCount;
    int skippedCount;
    std::vector<std::wstring> errors;

    OperationResult()
        : success(false)
        , cancelled(false)
        , successCount(0)
        , failCount(0)
        , skippedCount(0)
    {
    }
};

namespace SpriteEditorOperationUi
{
    struct OperationResultView
    {
        std::wstring title;
        std::wstring summary;
        std::wstring outputPath;
        std::vector<std::wstring> errors;
    };

    OperationResultView ToResultView(const OperationResult& result);
    std::wstring BuildOperationErrorBlock(const std::vector<std::wstring>& errors);
    std::wstring BuildOperationMessage(const OperationResultView& result);
    void ShowOperationMessage(const OperationResultView& result);
    void ShowOperationResult(const OperationResult& result);
}

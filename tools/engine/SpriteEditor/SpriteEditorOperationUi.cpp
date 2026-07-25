#include "stdafx.h"
#include "SpriteEditorOperationUi.h"
#include <afxwin.h>

namespace SpriteEditorOperationUi
{
    OperationResultView ToResultView(const OperationResult& result)
    {
        OperationResultView view;
        view.title = result.title;
        view.summary = result.summary;
        view.outputPath = result.outputPath;
        view.errors = result.errors;
        return view;
    }

    std::wstring BuildOperationErrorBlock(const std::vector<std::wstring>& errors)
    {
        if (errors.empty())
            return std::wstring();

        std::wstring block = L"\n\n错误详情：";
        const size_t maxCount = 8;
        for (size_t i = 0; i < errors.size() && i < maxCount; ++i)
        {
            block += L"\n- ";
            block += errors[i];
        }
        if (errors.size() > maxCount)
            block += L"\n- ...";
        return block;
    }

    std::wstring BuildOperationMessage(const OperationResultView& result)
    {
        std::wstring message;
        if (!result.title.empty())
            message += result.title + L"\n\n";
        if (!result.summary.empty())
            message += result.summary;
        if (!result.outputPath.empty())
            message += L"\n输出目录：" + result.outputPath;
        message += BuildOperationErrorBlock(result.errors);
        return message;
    }

    void ShowOperationMessage(const OperationResultView& result)
    {
        AfxMessageBox(BuildOperationMessage(result).c_str());
    }

    void ShowOperationResult(const OperationResult& result)
    {
        ShowOperationMessage(ToResultView(result));
    }
}

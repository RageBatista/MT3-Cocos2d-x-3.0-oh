/**
 * @file SLJFP_App.cpp
 * @brief SuperLJFilePackUnpack GUI 应用程序入口
 * @version 1.0
 * @date 2025-01-03
 */

#include <wx/wx.h>
#include "SLJFP_MainFrame.h"

namespace SLJFP {

/**
 * @brief 应用程序类
 */
class App : public wxApp {
public:
    virtual bool OnInit() override {
        // 设置语言环境 (支持中文)
        static wxLocale locale(wxLANGUAGE_CHINESE_SIMPLIFIED);
        wxUnusedVar(locale);

        // 创建主窗口
        MainFrame* frame = new MainFrame(wxT("SuperLJFilePackUnpack - LJFilePack 资源包解包工具 v1.0.1"));
        frame->Show(true);

        return true;
    }
};

} // namespace SLJFP

// 声明应用程序入口点
wxIMPLEMENT_APP(SLJFP::App);

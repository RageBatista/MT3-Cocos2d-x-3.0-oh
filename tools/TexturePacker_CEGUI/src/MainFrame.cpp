#include "MainFrame.h"

#include "BuildTypes.h"
#include "PreviewCanvas.h"
#include "TexturePackerInvoker.h"

#include <wx/button.h>
#include <wx/datetime.h>
#include <wx/dirdlg.h>
#include <wx/filedlg.h>
#include <wx/filename.h>
#include <wx/msgdlg.h>
#include <wx/panel.h>
#include <wx/sizer.h>
#include <wx/stattext.h>
#include <wx/textctrl.h>

namespace {

enum {
  ID_BROWSE_SOURCE = wxID_HIGHEST + 100,
  ID_BROWSE_OUTPUT,
  ID_BUILD,
  ID_RELOAD_PREVIEW
};

} // namespace

wxBEGIN_EVENT_TABLE(MainFrame, wxFrame)
EVT_BUTTON(ID_BROWSE_SOURCE, MainFrame::OnBrowseSourceDir)
EVT_BUTTON(ID_BROWSE_OUTPUT, MainFrame::OnBrowseOutputDir)
EVT_BUTTON(ID_BUILD, MainFrame::OnBuild)
EVT_BUTTON(ID_RELOAD_PREVIEW, MainFrame::OnReloadPreview)
wxEND_EVENT_TABLE()

MainFrame::MainFrame()
    : wxFrame(NULL, wxID_ANY, wxT("TexturePacker_CEGUI"),
              wxDefaultPosition, wxSize(1400, 900)),
      m_previewCanvas(NULL), m_sourceDirCtrl(NULL),
      m_outputDirCtrl(NULL), m_atlasNameCtrl(NULL), m_logCtrl(NULL),
      m_buildButton(NULL), m_reloadPreviewButton(NULL) {
  wxPanel *panel = new wxPanel(this, wxID_ANY);

  wxBoxSizer *rootSizer = new wxBoxSizer(wxVERTICAL);

  wxFlexGridSizer *configGrid = new wxFlexGridSizer(3, 3, 8, 8);
  configGrid->AddGrowableCol(1, 1);
  m_sourceDirCtrl = new wxTextCtrl(
      panel, wxID_ANY,
      wxGetCwd() +
          wxT("\\tools\\free-tex-packer\\src\\client\\resources\\static\\images\\browser"));
  m_outputDirCtrl =
      new wxTextCtrl(panel, wxID_ANY,
                     wxGetCwd() + wxT("\\tools\\TexturePacker_CEGUI\\workspace\\smoke-out"));
  m_atlasNameCtrl = new wxTextCtrl(panel, wxID_ANY, wxT("tp_cegui_smoke"));

  configGrid->Add(new wxStaticText(panel, wxID_ANY, wxT("源目录")), 0,
                  wxALIGN_CENTER_VERTICAL);
  configGrid->Add(m_sourceDirCtrl, 1, wxEXPAND);
  configGrid->Add(new wxButton(panel, ID_BROWSE_SOURCE, wxT("浏览")), 0,
                  wxALIGN_CENTER_VERTICAL);

  configGrid->Add(new wxStaticText(panel, wxID_ANY, wxT("输出目录")), 0,
                  wxALIGN_CENTER_VERTICAL);
  configGrid->Add(m_outputDirCtrl, 1, wxEXPAND);
  configGrid->Add(new wxButton(panel, ID_BROWSE_OUTPUT, wxT("浏览")), 0,
                  wxALIGN_CENTER_VERTICAL);

  configGrid->Add(new wxStaticText(panel, wxID_ANY, wxT("图集名")), 0,
                  wxALIGN_CENTER_VERTICAL);
  configGrid->Add(m_atlasNameCtrl, 1, wxEXPAND);
  configGrid->AddSpacer(1);

  rootSizer->Add(configGrid, 0, wxEXPAND | wxALL, 10);

  wxBoxSizer *btnSizer = new wxBoxSizer(wxHORIZONTAL);
  m_buildButton = new wxButton(panel, ID_BUILD, wxT("构建图集"));
  m_reloadPreviewButton = new wxButton(panel, ID_RELOAD_PREVIEW, wxT("重载预览"));

  btnSizer->Add(m_buildButton, 0, wxRIGHT, 8);
  btnSizer->Add(m_reloadPreviewButton, 0, wxRIGHT, 8);
  rootSizer->Add(btnSizer, 0, wxLEFT | wxRIGHT | wxBOTTOM, 10);

  m_previewCanvas = new PreviewCanvas(panel);
  rootSizer->Add(m_previewCanvas, 1, wxEXPAND | wxLEFT | wxRIGHT, 10);

  rootSizer->Add(new wxStaticText(panel, wxID_ANY, wxT("构建日志")), 0,
                 wxLEFT | wxRIGHT | wxTOP, 10);
  m_logCtrl = new wxTextCtrl(panel, wxID_ANY, wxEmptyString,
                             wxDefaultPosition, wxSize(-1, 180),
                             wxTE_MULTILINE | wxTE_READONLY);
  rootSizer->Add(m_logCtrl, 0, wxEXPAND | wxALL, 10);

  panel->SetSizer(rootSizer);

  CreateStatusBar(2);
  SetStatusText(wxT("就绪"));

  AppendLog(wxT("TexturePacker_CEGUI 已启动。"));
  Centre(wxBOTH);
}

bool MainFrame::InitializePreview(wxString &errorMessage) {
  if (!m_previewCanvas->InitialiseCEGUI(errorMessage)) {
    AppendLog(wxT("CEGUI 初始化失败: ") + errorMessage);
    return false;
  }

  AppendLog(wxT("CEGUI 真实渲染预览初始化完成。"));
  return true;
}

void MainFrame::AppendLog(const wxString &message) {
  if (!m_logCtrl) {
    return;
  }

  const wxString timestamp = wxDateTime::Now().FormatISOTime();
  m_logCtrl->AppendText(wxT("[") + timestamp + wxT("] ") + message +
                        wxT("\n"));
}

void MainFrame::OnBrowseSourceDir(wxCommandEvent &WXUNUSED(event)) {
  wxDirDialog dlg(this, wxT("选择源目录"), m_sourceDirCtrl->GetValue(),
                  wxDD_DEFAULT_STYLE | wxDD_DIR_MUST_EXIST);
  if (dlg.ShowModal() == wxID_OK) {
    m_sourceDirCtrl->SetValue(dlg.GetPath());
  }
}

void MainFrame::OnBrowseOutputDir(wxCommandEvent &WXUNUSED(event)) {
  wxDirDialog dlg(this, wxT("选择输出目录"), m_outputDirCtrl->GetValue(),
                  wxDD_DEFAULT_STYLE);
  if (dlg.ShowModal() == wxID_OK) {
    m_outputDirCtrl->SetValue(dlg.GetPath());
  }
}

void MainFrame::OnBuild(wxCommandEvent &WXUNUSED(event)) {
  BuildRequest req;
  req.sourceDir = m_sourceDirCtrl->GetValue();
  req.outputDir = m_outputDirCtrl->GetValue();
  req.atlasName = m_atlasNameCtrl->GetValue();

  if (req.atlasName.IsEmpty()) {
    wxMessageBox(wxT("图集名称不能为空。"), wxT("参数错误"),
                 wxOK | wxICON_WARNING, this);
    return;
  }

  AppendLog(wxT("开始构建图集: ") + req.atlasName);

  const BuildResult result = TexturePackerInvoker::Run(req);

  AppendLog(wxT("命令行: ") + result.commandLine);

  if (!result.stdOut.IsEmpty()) {
    AppendLog(wxT("[stdout]\n") + result.stdOut);
  }
  if (!result.stdErr.IsEmpty()) {
    AppendLog(wxT("[stderr]\n") + result.stdErr);
  }

  if (!result.success) {
    AppendLog(wxT("构建失败: ") + result.errorMessage);
    wxMessageBox(wxT("构建失败：\n") + result.errorMessage, wxT("错误"),
                 wxOK | wxICON_ERROR, this);
    SetStatusText(wxT("构建失败"));
    return;
  }

  AppendLog(wxString::Format(wxT("构建成功。精灵数: %d，图集页数: %d"),
                             result.spriteCount, result.atlasCount));
  for (size_t i = 0; i < result.outputImagePaths.Count(); ++i) {
    AppendLog(wxString::Format(wxT("构建成功。png[%d]: %s"), static_cast<int>(i),
                               result.outputImagePaths[i].c_str()));
  }
  for (size_t i = 0; i < result.outputImagesetPaths.Count(); ++i) {
    AppendLog(wxString::Format(wxT("构建成功。imageset[%d]: %s"),
                               static_cast<int>(i),
                               result.outputImagesetPaths[i].c_str()));
  }

  wxString previewError;
  if (!m_previewCanvas->LoadAtlasImage(result.outputImagePath, previewError)) {
    AppendLog(wxT("预览加载失败: ") + previewError);
  } else {
    AppendLog(wxT("预览加载成功。"));
  }

  SetStatusText(wxT("构建成功"));
}

void MainFrame::OnReloadPreview(wxCommandEvent &WXUNUSED(event)) {
  wxFileName imageFile(m_outputDirCtrl->GetValue(),
                       m_atlasNameCtrl->GetValue() + wxT(".png"));

  wxString previewError;
  if (!m_previewCanvas->LoadAtlasImage(imageFile.GetFullPath(), previewError)) {
    AppendLog(wxT("重载预览失败: ") + previewError);
    wxMessageBox(wxT("重载预览失败：\n") + previewError, wxT("提示"),
                 wxOK | wxICON_INFORMATION, this);
    return;
  }

  AppendLog(wxT("预览已重载: ") + imageFile.GetFullPath());
}

#pragma once

#include <wx/frame.h>
#include <wx/string.h>

class PreviewCanvas;
class wxButton;
class wxTextCtrl;

class MainFrame : public wxFrame {
public:
  MainFrame();
  bool InitializePreview(wxString &errorMessage);

private:
  PreviewCanvas *m_previewCanvas;

  wxTextCtrl *m_sourceDirCtrl;
  wxTextCtrl *m_outputDirCtrl;
  wxTextCtrl *m_atlasNameCtrl;

  wxTextCtrl *m_logCtrl;

  wxButton *m_buildButton;
  wxButton *m_reloadPreviewButton;

  void AppendLog(const wxString &message);

  void OnBrowseSourceDir(wxCommandEvent &event);
  void OnBrowseOutputDir(wxCommandEvent &event);
  void OnBuild(wxCommandEvent &event);
  void OnReloadPreview(wxCommandEvent &event);

  wxDECLARE_EVENT_TABLE();
};

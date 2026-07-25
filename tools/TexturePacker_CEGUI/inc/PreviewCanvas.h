#pragma once

#include <wx/glcanvas.h>
#include <wx/string.h>

#include <CEGUISystem.h>
#include <RendererModules/OpenGL/CEGUIOpenGLRenderer.h>

class PreviewCanvas : public wxGLCanvas {
public:
  PreviewCanvas(wxWindow *parent, wxWindowID id = wxID_ANY);
  ~PreviewCanvas();

  bool InitialiseCEGUI(wxString &errorMessage);
  bool LoadAtlasImage(const wxString &imagePath, wxString &errorMessage);
  void ClearPreview();

private:
  wxGLContext *m_context;

  CEGUI::System *m_guiSystem;
  CEGUI::OpenGLRenderer *m_renderer;
  CEGUI::Window *m_rootWindow;
  CEGUI::Window *m_staticImageWindow;

  float m_zoomFactor;
  float m_imageWidth;
  float m_imageHeight;

  bool m_isReady;

  void DestroyCEGUI();
  void UpdateImagePlacement();
  void RenderNow();

  void OnPaint(wxPaintEvent &event);
  void OnSize(wxSizeEvent &event);
  void OnEraseBackground(wxEraseEvent &event);
  void OnMouseMove(wxMouseEvent &event);
  void OnMouseDown(wxMouseEvent &event);
  void OnMouseUp(wxMouseEvent &event);
  void OnMouseWheel(wxMouseEvent &event);

  wxDECLARE_EVENT_TABLE();
};
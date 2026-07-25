#include "PreviewCanvas.h"

#include <wx/dcclient.h>
#include <wx/filename.h>
#include <wx/stdpaths.h>

#include <CEGUIDefaultResourceProvider.h>
#include <CEGUIExceptions.h>
#include <CEGUIImage.h>
#include <CEGUIImageset.h>
#include <CEGUIImagesetManager.h>
#include <CEGUILogger.h>
#include <CEGUISchemeManager.h>
#include <CEGUIWindow.h>
#include <CEGUIWindowManager.h>

namespace {

CEGUI::String ToCEGUIString(const wxString &text) {
  wxCharBuffer utf8 = text.utf8_str();
  const char *data = utf8.data();
  if (!data) {
    data = "";
  }
  return CEGUI::String(reinterpret_cast<const CEGUI::utf8 *>(data));
}

} // namespace

wxBEGIN_EVENT_TABLE(PreviewCanvas, wxGLCanvas)
EVT_PAINT(PreviewCanvas::OnPaint)
EVT_SIZE(PreviewCanvas::OnSize)
EVT_ERASE_BACKGROUND(PreviewCanvas::OnEraseBackground)
EVT_MOTION(PreviewCanvas::OnMouseMove)
EVT_LEFT_DOWN(PreviewCanvas::OnMouseDown)
EVT_RIGHT_DOWN(PreviewCanvas::OnMouseDown)
EVT_MIDDLE_DOWN(PreviewCanvas::OnMouseDown)
EVT_LEFT_UP(PreviewCanvas::OnMouseUp)
EVT_RIGHT_UP(PreviewCanvas::OnMouseUp)
EVT_MIDDLE_UP(PreviewCanvas::OnMouseUp)
EVT_MOUSEWHEEL(PreviewCanvas::OnMouseWheel)
wxEND_EVENT_TABLE()

PreviewCanvas::PreviewCanvas(wxWindow *parent, wxWindowID id)
    : wxGLCanvas(parent, id, NULL, wxDefaultPosition, wxDefaultSize,
                 wxFULL_REPAINT_ON_RESIZE | wxSUNKEN_BORDER),
      m_context(NULL), m_guiSystem(NULL), m_renderer(NULL), m_rootWindow(NULL),
      m_staticImageWindow(NULL), m_zoomFactor(1.0f), m_imageWidth(0.0f),
      m_imageHeight(0.0f), m_isReady(false) {
  m_context = new wxGLContext(this);
}

PreviewCanvas::~PreviewCanvas() {
  DestroyCEGUI();
  delete m_context;
  m_context = NULL;
}

bool PreviewCanvas::InitialiseCEGUI(wxString &errorMessage) {
  if (m_isReady) {
    return true;
  }

  if (!m_context || !SetCurrent(*m_context)) {
    errorMessage = wxT("无法创建或激活 OpenGL 上下文。");
    return false;
  }

  try {
    m_renderer = &CEGUI::OpenGLRenderer::create();
    m_guiSystem = &CEGUI::System::create(*m_renderer);

    CEGUI::Logger::getSingleton().setLoggingLevel(CEGUI::Informative);

    CEGUI::DefaultResourceProvider *resourceProvider =
        static_cast<CEGUI::DefaultResourceProvider *>(
            m_guiSystem->getResourceProvider());

    wxFileName exePath(wxStandardPaths::Get().GetExecutablePath());
    wxString dataDir = exePath.GetPathWithSep() + wxT("data\\");

    resourceProvider->setResourceGroupDirectory("editor_data",
                                                ToCEGUIString(dataDir));
    resourceProvider->setDefaultResourceGroup("editor_data");

    if (!CEGUI::SchemeManager::getSingleton().isDefined("CEImagesetEditor")) {
      CEGUI::SchemeManager::getSingleton().create("CEImagesetEditor.scheme");
    }

    resourceProvider->setDefaultResourceGroup("");

    CEGUI::WindowManager &wm = CEGUI::WindowManager::getSingleton();
    m_rootWindow = wm.createWindow("DefaultWindow", "TP.Root");
    m_staticImageWindow =
        wm.createWindow("CEImagesetEditor/StaticImage", "TP.PreviewImage");

    m_staticImageWindow->setProperty("FrameEnabled", "False");
    m_staticImageWindow->setProperty("BackgroundEnabled", "False");

    m_rootWindow->addChildWindow(m_staticImageWindow);
    m_guiSystem->setGUISheet(m_rootWindow);

    m_isReady = true;
    UpdateImagePlacement();
    RenderNow();
    return true;
  } catch (const CEGUI::Exception &e) {
    errorMessage = wxString::FromUTF8(
        reinterpret_cast<const char *>(e.getMessage().c_str()));
    DestroyCEGUI();
    return false;
  } catch (...) {
    errorMessage = wxT("初始化 CEGUI 时发生未知异常。");
    DestroyCEGUI();
    return false;
  }
}

bool PreviewCanvas::LoadAtlasImage(const wxString &imagePath,
                                   wxString &errorMessage) {
  if (!m_isReady) {
    errorMessage = wxT("CEGUI 尚未初始化。");
    return false;
  }

  if (!wxFileName::FileExists(imagePath)) {
    errorMessage = wxT("预览图像不存在: ") + imagePath;
    return false;
  }

  try {
    CEGUI::ImagesetManager &imagesetMgr = CEGUI::ImagesetManager::getSingleton();
    if (imagesetMgr.isDefined("__tp_preview__")) {
      imagesetMgr.destroy("__tp_preview__");
    }

    CEGUI::Imageset &imageset = imagesetMgr.createFromImageFile(
        "__tp_preview__", ToCEGUIString(imagePath));
    imageset.setAutoScalingEnabled(false);

    m_staticImageWindow->setProperty("Image",
                                     "set:__tp_preview__ image:full_image");

    const CEGUI::Image &image = imageset.getImage("full_image");
    const CEGUI::Size size = image.getSize();
    m_imageWidth = size.d_width;
    m_imageHeight = size.d_height;

    m_zoomFactor = 1.0f;
    UpdateImagePlacement();
    RenderNow();

    return true;
  } catch (const CEGUI::Exception &e) {
    errorMessage = wxString::FromUTF8(
        reinterpret_cast<const char *>(e.getMessage().c_str()));
    return false;
  }
}

void PreviewCanvas::ClearPreview() {
  if (!m_isReady) {
    return;
  }

  try {
    CEGUI::ImagesetManager &imagesetMgr = CEGUI::ImagesetManager::getSingleton();
    if (imagesetMgr.isDefined("__tp_preview__")) {
      imagesetMgr.destroy("__tp_preview__");
    }

    m_staticImageWindow->setProperty("Image", "");
  } catch (...) {
  }

  m_imageWidth = 0.0f;
  m_imageHeight = 0.0f;
  m_zoomFactor = 1.0f;

  UpdateImagePlacement();
  RenderNow();
}

void PreviewCanvas::DestroyCEGUI() {
  if (!m_isReady) {
    return;
  }

  try {
    if (m_context) {
      SetCurrent(*m_context);
    }

    CEGUI::ImagesetManager *imagesetMgr = NULL;
    try {
      imagesetMgr = &CEGUI::ImagesetManager::getSingleton();
    } catch (...) {
      imagesetMgr = NULL;
    }

    if (imagesetMgr && imagesetMgr->isDefined("__tp_preview__")) {
      imagesetMgr->destroy("__tp_preview__");
    }

    CEGUI::WindowManager *wm = NULL;
    try {
      wm = &CEGUI::WindowManager::getSingleton();
    } catch (...) {
      wm = NULL;
    }

    if (wm && m_staticImageWindow) {
      wm->destroyWindow(m_staticImageWindow);
      m_staticImageWindow = NULL;
    }

    if (wm && m_rootWindow) {
      wm->destroyWindow(m_rootWindow);
      m_rootWindow = NULL;
    }

    if (m_guiSystem) {
      CEGUI::System::destroy();
      m_guiSystem = NULL;
    }

    if (m_renderer) {
      CEGUI::OpenGLRenderer::destroy(*m_renderer);
      m_renderer = NULL;
    }
  } catch (...) {
  }

  m_isReady = false;
}

void PreviewCanvas::UpdateImagePlacement() {
  if (!m_isReady || !m_rootWindow || !m_staticImageWindow) {
    return;
  }

  int clientWidth = 0;
  int clientHeight = 0;
  GetClientSize(&clientWidth, &clientHeight);

  if (clientWidth <= 0 || clientHeight <= 0) {
    return;
  }

  m_rootWindow->setPosition(CEGUI::UVector2(CEGUI::UDim(0, 0),
                                             CEGUI::UDim(0, 0)));
  m_rootWindow->setSize(
      CEGUI::UVector2(CEGUI::UDim(0, clientWidth), CEGUI::UDim(0, clientHeight)));

  if (m_imageWidth <= 0.0f || m_imageHeight <= 0.0f) {
    m_staticImageWindow->setSize(
        CEGUI::UVector2(CEGUI::UDim(0, 1), CEGUI::UDim(0, 1)));
    return;
  }

  float drawWidth = m_imageWidth * m_zoomFactor;
  float drawHeight = m_imageHeight * m_zoomFactor;

  if (drawWidth < 1.0f)
    drawWidth = 1.0f;
  if (drawHeight < 1.0f)
    drawHeight = 1.0f;

  float offsetX = (static_cast<float>(clientWidth) - drawWidth) * 0.5f;
  float offsetY = (static_cast<float>(clientHeight) - drawHeight) * 0.5f;

  if (offsetX < 0.0f)
    offsetX = 0.0f;
  if (offsetY < 0.0f)
    offsetY = 0.0f;

  m_staticImageWindow->setPosition(
      CEGUI::UVector2(CEGUI::UDim(0, offsetX), CEGUI::UDim(0, offsetY)));
  m_staticImageWindow->setSize(
      CEGUI::UVector2(CEGUI::UDim(0, drawWidth), CEGUI::UDim(0, drawHeight)));

  m_staticImageWindow->setProperty("HorzFormatting", "Stretched");
  m_staticImageWindow->setProperty("VertFormatting", "Stretched");
}

void PreviewCanvas::RenderNow() {
  if (!m_isReady || !m_context || !m_guiSystem) {
    return;
  }

  if (!SetCurrent(*m_context)) {
    return;
  }

  int width = 0;
  int height = 0;
  GetClientSize(&width, &height);

  if (width <= 0 || height <= 0) {
    return;
  }

  glViewport(0, 0, width, height);
  glClearColor(0.12f, 0.12f, 0.12f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  m_guiSystem->renderGUI();

  glFlush();
  SwapBuffers();
}

void PreviewCanvas::OnPaint(wxPaintEvent &WXUNUSED(event)) {
  wxPaintDC dc(this);
  RenderNow();
}

void PreviewCanvas::OnSize(wxSizeEvent &event) {
  if (m_isReady && m_context && m_guiSystem && SetCurrent(*m_context)) {
    const wxSize size = event.GetSize();
    m_guiSystem->notifyDisplaySizeChanged(
        CEGUI::Size(static_cast<float>(size.x), static_cast<float>(size.y)));
    UpdateImagePlacement();
  }

  Refresh(false);
  event.Skip();
}

void PreviewCanvas::OnEraseBackground(wxEraseEvent &WXUNUSED(event)) {
  // 使用 OpenGL 渲染，显式忽略背景擦除事件。
}

void PreviewCanvas::OnMouseMove(wxMouseEvent &event) {
  if (m_isReady && m_guiSystem) {
    m_guiSystem->injectMousePosition(static_cast<float>(event.GetX()),
                                     static_cast<float>(event.GetY()));
    RenderNow();
  }

  event.Skip();
}

void PreviewCanvas::OnMouseDown(wxMouseEvent &event) {
  if (!m_isReady || !m_guiSystem) {
    event.Skip();
    return;
  }

  if (event.LeftDown()) {
    m_guiSystem->injectMouseButtonDown(CEGUI::LeftButton);
  } else if (event.RightDown()) {
    m_guiSystem->injectMouseButtonDown(CEGUI::RightButton);
  } else if (event.MiddleDown()) {
    m_guiSystem->injectMouseButtonDown(CEGUI::MiddleButton);
  }

  RenderNow();
  event.Skip();
}

void PreviewCanvas::OnMouseUp(wxMouseEvent &event) {
  if (!m_isReady || !m_guiSystem) {
    event.Skip();
    return;
  }

  if (event.LeftUp()) {
    m_guiSystem->injectMouseButtonUp(CEGUI::LeftButton);
  } else if (event.RightUp()) {
    m_guiSystem->injectMouseButtonUp(CEGUI::RightButton);
  } else if (event.MiddleUp()) {
    m_guiSystem->injectMouseButtonUp(CEGUI::MiddleButton);
  }

  RenderNow();
  event.Skip();
}

void PreviewCanvas::OnMouseWheel(wxMouseEvent &event) {
  if (!m_isReady || !m_guiSystem) {
    event.Skip();
    return;
  }

  if (event.ControlDown()) {
    const int rotation = event.GetWheelRotation();
    if (rotation > 0) {
      m_zoomFactor *= 1.1f;
    } else {
      m_zoomFactor /= 1.1f;
    }

    if (m_zoomFactor < 0.1f)
      m_zoomFactor = 0.1f;
    if (m_zoomFactor > 8.0f)
      m_zoomFactor = 8.0f;

    UpdateImagePlacement();
  } else {
    const float delta = event.GetWheelRotation() > 0 ? 1.0f : -1.0f;
    m_guiSystem->injectMouseWheelChange(delta);
  }

  RenderNow();
  event.Skip();
}
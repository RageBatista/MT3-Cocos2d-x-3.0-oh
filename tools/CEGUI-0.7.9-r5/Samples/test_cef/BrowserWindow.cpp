#include "BrowserWindow.h"
#include "include/cef_app.h"
#include "include/cef_browser.h"
#include "include/cef_command_line.h"
#include "include/cef_frame.h"
#include "include/cef_runnable.h"
#include "cefclient/client_handler.h"
#include "cefclient/string_util.h"
#include "cefclient/util.h"
#include "CEGUISystem.h"
#include "CEGUI.h"
#include "CEGuiD3D9BaseApplication.h"
using namespace CEGUI;

BrowserWindow::BrowserWindow(CEGuiD3D9BaseApplication* pApp)
	: m_pSampleApp( pApp )
{
	SchemeManager::getSingleton().create("TaharezLook.scheme");
	System::getSingleton().setDefaultMouseCursor("TaharezLook", "MouseArrow");
    CEGUI::WindowManager& winMgr = CEGUI::WindowManager::getSingleton();

    //CEGUI::Window* pWindow = winMgr.createWindow("TaharezLook/FrameWindow", "fw_browser");
	Window* pWindow = winMgr.createWindow("DefaultWindow", "Root");
	System::getSingleton().setGUISheet(pWindow);

    pWindow->setPosition(CEGUI::UVector2(cegui_reldim(0), cegui_reldim( 0)));
    pWindow->setSize(CEGUI::UVector2(cegui_absdim(650), cegui_absdim(550)));

    CEGUI::Size browerSize(600, 480);
    CEGUI::Texture& texture  = CEGUI::System::getSingleton().getRenderer()->createTexture(browerSize);
    CEGUI::Imageset& imageSet = CEGUI::ImagesetManager::getSingleton().create("is_browser", texture);
    imageSet.defineImage("content", CEGUI::Rect(CEGUI::Point(0, 0), browerSize), CEGUI::Point(0, 0));

    m_pTexture = &texture;

    CEGUI::Window* pImage = winMgr.createWindow("TaharezLook/StaticImage", "si_browser");
    pImage->setPosition(CEGUI::UVector2(cegui_absdim(10), cegui_absdim(10)));
    pImage->setSize(CEGUI::UVector2(cegui_absdim(600), cegui_absdim(480)));
    // disable frame and standard background
    pImage->setProperty("FrameEnabled", "false");
    pImage->setProperty("BackgroundEnabled", "false");
    // set the background image
    pImage->setProperty("Image", "set:is_browser image:content");

    pImage->subscribeEvent(CEGUI::Window::EventWindowUpdated, CEGUI::Event::Subscriber(&BrowserWindow::Update, this));
    pImage->subscribeEvent(CEGUI::Window::EventMouseMove, CEGUI::Event::Subscriber(&BrowserWindow::OnMouseMove, this));
    pImage->subscribeEvent(CEGUI::Window::EventMouseClick, CEGUI::Event::Subscriber(&BrowserWindow::OnMouseClick, this));
    pImage->subscribeEvent(CEGUI::Window::EventMouseButtonDown, CEGUI::Event::Subscriber(&BrowserWindow::OnMouseButtonDown, this));
    pImage->subscribeEvent(CEGUI::Window::EventMouseButtonUp, CEGUI::Event::Subscriber(&BrowserWindow::OnMouseButtonUp, this));

    pWindow->addChildWindow(pImage);

	FrameWindow* wnd = (FrameWindow*)winMgr.createWindow("TaharezLook/FrameWindow", "Demo Window");
	pWindow->addChildWindow(wnd);
	wnd->setPosition(UVector2(cegui_reldim(0.25f), cegui_reldim( 0.25f)));
    wnd->setSize(UVector2(cegui_reldim(0.5f), cegui_reldim( 0.5f)));
	wnd->setMaxSize(UVector2(cegui_reldim(1.0f), cegui_reldim( 1.0f)));
	wnd->setMinSize(UVector2(cegui_reldim(0.1f), cegui_reldim( 0.1f)));
	wnd->setText("Hello World!");

    CefWindowInfo info;
    CefBrowserSettings settings;

	if( m_pSampleApp )
	{
		HWND wWin = m_pSampleApp->GetWin();
		RECT rect;
		/*rect.left = 0;
		rect.top = 0;
		rect.right = 600;
		rect.bottom = 800;*/
		GetClientRect(wWin, &rect);
		info.SetAsChild(wWin,rect);
	}
	

	//info.SetAsChild(pWindow,browerSize);
    //info.SetAsOffScreen(NULL);
    //info.SetTransparentPainting(false);

    m_pHandler = new ClientBrowserHandler(*this);
	//m_pHandler->SetMainHwnd(pWindow);
    if(!CefBrowser::CreateBrowser(info, m_pHandler.get(),
        "http://www.google.com/", settings) )
    {
        printf("CreateBrowser Fail");
    }

    printf("CreateBrowser Succeed");

	CefRunMessageLoop();
	CefShutdown();
}

BrowserWindow::~BrowserWindow()
{
    CEGUI::ImagesetManager::getSingleton().destroy("si_browser");
}

void BrowserWindow::OnPaint()
{
    m_bDirty = true;
}

bool BrowserWindow::Update(const CEGUI::EventArgs& e)
{
    if(m_bDirty)
    {
        CEGUI::WindowManager& winMgr = CEGUI::WindowManager::getSingleton();
        winMgr.getWindow("si_browser")->invalidate(true);
    }

    m_bDirty = false;

    return true;
}

bool BrowserWindow::OnMouseMove(const CEGUI::EventArgs& e)
{
    if(!m_pBrowser)
    {
        return true;
    }

    //CefRefPtr<CefBrowserHost> browserHost = m_pBrowser->GetHost();

    //const CEGUI::MouseEventArgs& me = static_cast<const CEGUI::MouseEventArgs&>(e);

    //CefMouseEvent mouse_event;
    //mouse_event.x = CEGUI::CoordConverter::screenToWindowX(*me.window, me.position.d_x);
    //mouse_event.y = CEGUI::CoordConverter::screenToWindowY(*me.window, me.position.d_y);
    ////window->ApplyPopupOffset(mouse_event.x, mouse_event.y);
    ////mouse_event.modifiers = GetCefMouseModifiers(wParam);
    //browserHost->SendMouseMoveEvent(mouse_event, false);

    //BIN3D_DBUG("%d %d", mouse_event.x, mouse_event.y);
    
    return true;
}

bool BrowserWindow::OnMouseClick(const CEGUI::EventArgs& e)
{
    if(!m_pBrowser)
    {
        return true;
    }

    //CefRefPtr<CefBrowserHost> browserHost = m_pBrowser->GetHost();

    //const CEGUI::MouseEventArgs& me = static_cast<const CEGUI::MouseEventArgs&>(e);

    //CefMouseEvent mouse_event;
    //mouse_event.x = CEGUI::CoordConverter::screenToWindowX(*me.window, me.position.d_x);
    //mouse_event.y = CEGUI::CoordConverter::screenToWindowY(*me.window, me.position.d_y);
    ////window->ApplyPopupOffset(mouse_event.x, mouse_event.y);
    ////mouse_event.modifiers = GetCefMouseModifiers(wParam);

    //CefBrowserHost::MouseButtonType btnType = MBT_LEFT;
    //mouse_event.modifiers = EVENTFLAG_LEFT_MOUSE_BUTTON;
    //if(me.button ==  CEGUI::RightButton)
    //{
    //    btnType = MBT_RIGHT;

    //    mouse_event.modifiers = EVENTFLAG_RIGHT_MOUSE_BUTTON;
    //}
    //else if(me.button ==  CEGUI::MiddleButton)
    //{
    //    btnType = MBT_MIDDLE;
    //    mouse_event.modifiers = EVENTFLAG_MIDDLE_MOUSE_BUTTON;
    //}

    //browserHost->SendMouseClickEvent(mouse_event, btnType, true, me.clickCount);

   // BIN3D_DBUG("OnMouseClick %d %d", mouse_event.x, mouse_event.y);

    return true;
}

bool BrowserWindow::OnMouseButtonDown(const CEGUI::EventArgs& e)
{
    if(!m_pBrowser)
    {
        return true;
    }

    //CefRefPtr<CefBrowserHost> browserHost = m_pBrowser->GetHost();

    //const CEGUI::MouseEventArgs& me = static_cast<const CEGUI::MouseEventArgs&>(e);

    //CefMouseEvent mouse_event;
    //mouse_event.x = CEGUI::CoordConverter::screenToWindowX(*me.window, me.position.d_x);
    //mouse_event.y = CEGUI::CoordConverter::screenToWindowY(*me.window, me.position.d_y);
    ////window->ApplyPopupOffset(mouse_event.x, mouse_event.y);
    ////mouse_event.modifiers = GetCefMouseModifiers(wParam);

    //CefBrowserHost::MouseButtonType btnType = MBT_LEFT;
    //mouse_event.modifiers = EVENTFLAG_LEFT_MOUSE_BUTTON;
    //if(me.button ==  CEGUI::RightButton)
    //{
    //    btnType = MBT_RIGHT;

    //    mouse_event.modifiers = EVENTFLAG_RIGHT_MOUSE_BUTTON;
    //}
    //else if(me.button ==  CEGUI::MiddleButton)
    //{
    //    btnType = MBT_MIDDLE;
    //    mouse_event.modifiers = EVENTFLAG_MIDDLE_MOUSE_BUTTON;
    //}

    //browserHost->SendMouseClickEvent(mouse_event, btnType, false, me.clickCount);

    //BIN3D_DBUG("OnMouseButtonDown %d %d", mouse_event.x, mouse_event.y);

    return true;
}

bool BrowserWindow::OnMouseButtonUp(const CEGUI::EventArgs& e)
{
    if(!m_pBrowser)
    {
        return true;
    }

    //CefRefPtr<CefBrowserHost> browserHost = m_pBrowser->GetHost();

    //const CEGUI::MouseEventArgs& me = static_cast<const CEGUI::MouseEventArgs&>(e);

    //CefMouseEvent mouse_event;
    //mouse_event.x = CEGUI::CoordConverter::screenToWindowX(*me.window, me.position.d_x);
    //mouse_event.y = CEGUI::CoordConverter::screenToWindowY(*me.window, me.position.d_y);
    ////window->ApplyPopupOffset(mouse_event.x, mouse_event.y);
    ////mouse_event.modifiers = GetCefMouseModifiers(wParam);

    //CefBrowserHost::MouseButtonType btnType = MBT_LEFT;
    //mouse_event.modifiers = EVENTFLAG_LEFT_MOUSE_BUTTON;
    //if(me.button ==  CEGUI::RightButton)
    //{
    //    btnType = MBT_RIGHT;

    //    mouse_event.modifiers = EVENTFLAG_RIGHT_MOUSE_BUTTON;
    //}
    //else if(me.button ==  CEGUI::MiddleButton)
    //{
    //    btnType = MBT_MIDDLE;
    //    mouse_event.modifiers = EVENTFLAG_MIDDLE_MOUSE_BUTTON;
    //}

    //browserHost->SendMouseClickEvent(mouse_event, btnType, true, me.clickCount);

    //BIN3D_DBUG("OnMouseButtonUp %d %d", mouse_event.x, mouse_event.y);

    return true;
}


//if (window && window->browser_provider_->GetBrowser().get())
//browser = window->browser_provider_->GetBrowser()->GetHost();
//
//LONG currentTime = 0;
//bool cancelPreviousClick = false;
//
//if (message == WM_LBUTTONDOWN || message == WM_RBUTTONDOWN ||
//    message == WM_MBUTTONDOWN || message == WM_MOUSEMOVE ||
//    message == WM_MOUSELEAVE) {
//        currentTime = GetMessageTime();
//        int x = GET_X_LPARAM(lParam);
//        int y = GET_Y_LPARAM(lParam);
//        cancelPreviousClick =
//            (abs(lastClickX - x) > (GetSystemMetrics(SM_CXDOUBLECLK) / 2))
//            || (abs(lastClickY - y) > (GetSystemMetrics(SM_CYDOUBLECLK) / 2))
//            || ((currentTime - gLastClickTime) > GetDoubleClickTime());
//        if (cancelPreviousClick &&
//            (message == WM_MOUSEMOVE || message == WM_MOUSELEAVE)) {
//                gLastClickCount = 0;
//                lastClickX = 0;
//                lastClickY = 0;
//                gLastClickTime = 0;
//        }
//}
//
//switch (message) {
//  case WM_DESTROY:
//      if (window)
//          window->OnDestroyed();
//      return 0;
//
//  case WM_LBUTTONDOWN:
//  case WM_RBUTTONDOWN:
//  case WM_MBUTTONDOWN: {
//      SetCapture(hWnd);
//      SetFocus(hWnd);
//      int x = GET_X_LPARAM(lParam);
//      int y = GET_Y_LPARAM(lParam);
//      if (wParam & MK_SHIFT) {
//          // Start rotation effect.
//          lastMousePos.x = curMousePos.x = x;
//          lastMousePos.y = curMousePos.y = y;
//          mouseRotation = true;
//      } else {
//          CefBrowserHost::MouseButtonType btnType =
//              (message == WM_LBUTTONDOWN ? MBT_LEFT : (
//              message == WM_RBUTTONDOWN ? MBT_RIGHT : MBT_MIDDLE));
//          if (!cancelPreviousClick && (btnType == lastClickButton)) {
//              ++gLastClickCount;
//          } else {
//              gLastClickCount = 1;
//              lastClickX = x;
//              lastClickY = y;
//          }
//          gLastClickTime = currentTime;
//          lastClickButton = btnType;
//
//          if (browser.get()) {
//              CefMouseEvent mouse_event;
//              mouse_event.x = x;
//              mouse_event.y = y;
//              gLastMouseDownOnView = !window->IsOverPopupWidget(x, y);
//              window->ApplyPopupOffset(mouse_event.x, mouse_event.y);
//              mouse_event.modifiers = GetCefMouseModifiers(wParam);
//              browser->SendMouseClickEvent(mouse_event, btnType, false,
//                  gLastClickCount);
//          }
//      }
//      break;
//                       }
//
//  case WM_LBUTTONUP:
//  case WM_RBUTTONUP:
//  case WM_MBUTTONUP:
//      if (GetCapture() == hWnd)
//          ReleaseCapture();
//      if (mouseRotation) {
//          // End rotation effect.
//          mouseRotation = false;
//          window->renderer_.SetSpin(0, 0);
//          window->Invalidate();
//      } else {
//          int x = GET_X_LPARAM(lParam);
//          int y = GET_Y_LPARAM(lParam);
//          CefBrowserHost::MouseButtonType btnType =
//              (message == WM_LBUTTONUP ? MBT_LEFT : (
//              message == WM_RBUTTONUP ? MBT_RIGHT : MBT_MIDDLE));
//          if (browser.get()) {
//              CefMouseEvent mouse_event;
//              mouse_event.x = x;
//              mouse_event.y = y;
//              if (gLastMouseDownOnView &&
//                  window->IsOverPopupWidget(x, y) &&
//                  (window->GetPopupXOffset() || window->GetPopupYOffset())) {
//                      break;
//              }
//              window->ApplyPopupOffset(mouse_event.x, mouse_event.y);
//              mouse_event.modifiers = GetCefMouseModifiers(wParam);
//              browser->SendMouseClickEvent(mouse_event, btnType, true,
//                  gLastClickCount);
//          }
//      }
//      break;
//
//  case WM_MOUSEMOVE: {
//      int x = GET_X_LPARAM(lParam);
//      int y = GET_Y_LPARAM(lParam);
//      if (mouseRotation) {
//          // Apply rotation effect.
//          curMousePos.x = x;
//          curMousePos.y = y;
//          window->renderer_.IncrementSpin((curMousePos.x - lastMousePos.x),
//              (curMousePos.y - lastMousePos.y));
//          lastMousePos.x = curMousePos.x;
//          lastMousePos.y = curMousePos.y;
//          window->Invalidate();
//      } else {
//          if (!mouseTracking) {
//              // Start tracking mouse leave. Required for the WM_MOUSELEAVE event to
//              // be generated.
//              TRACKMOUSEEVENT tme;
//              tme.cbSize = sizeof(TRACKMOUSEEVENT);
//              tme.dwFlags = TME_LEAVE;
//              tme.hwndTrack = hWnd;
//              TrackMouseEvent(&tme);
//              mouseTracking = true;
//          }
//          if (browser.get()) {
//              CefMouseEvent mouse_event;
//              mouse_event.x = x;
//              mouse_event.y = y;
//              window->ApplyPopupOffset(mouse_event.x, mouse_event.y);
//              mouse_event.modifiers = GetCefMouseModifiers(wParam);
//              browser->SendMouseMoveEvent(mouse_event, false);
//          }
//      }
//      break;
//                     }
//
//  case WM_MOUSELEAVE:
//      if (mouseTracking) {
//          // Stop tracking mouse leave.
//          TRACKMOUSEEVENT tme;
//          tme.cbSize = sizeof(TRACKMOUSEEVENT);
//          tme.dwFlags = TME_LEAVE & TME_CANCEL;
//          tme.hwndTrack = hWnd;
//          TrackMouseEvent(&tme);
//          mouseTracking = false;
//      }
//      if (browser.get()) {
//          CefMouseEvent mouse_event;
//          mouse_event.x = 0;
//          mouse_event.y = 0;
//          mouse_event.modifiers = GetCefMouseModifiers(wParam);
//          browser->SendMouseMoveEvent(mouse_event, true);
//      }
//      break;
//
//  case WM_MOUSEWHEEL:
//      if (browser.get()) {
//          POINT screen_point = {GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam)};
//          HWND scrolled_wnd = ::WindowFromPoint(screen_point);
//          if (scrolled_wnd != hWnd) {
//              break;
//          }
//          ScreenToClient(hWnd, &screen_point);
//          int delta = GET_WHEEL_DELTA_WPARAM(wParam);
//
//          CefMouseEvent mouse_event;
//          mouse_event.x = screen_point.x;
//          mouse_event.y = screen_point.y;
//          window->ApplyPopupOffset(mouse_event.x, mouse_event.y);
//          mouse_event.modifiers = GetCefMouseModifiers(wParam);
//
//          browser->SendMouseWheelEvent(mouse_event,
//              isKeyDown(VK_SHIFT) ? delta : 0,
//              !isKeyDown(VK_SHIFT) ? delta : 0);
//      }
//      break;
//
//  case WM_SIZE:
//      if (browser.get())
//          browser->WasResized();
//      break;
//
//  case WM_SETFOCUS:
//  case WM_KILLFOCUS:
//      if (browser.get())
//          browser->SendFocusEvent(message == WM_SETFOCUS);
//      break;
//
//  case WM_CAPTURECHANGED:
//  case WM_CANCELMODE:
//      if (!mouseRotation) {
//          if (browser.get())
//              browser->SendCaptureLostEvent();
//      }
//      break;
//  case WM_SYSCHAR:
//  case WM_SYSKEYDOWN:
//  case WM_SYSKEYUP:
//  case WM_KEYDOWN:
//  case WM_KEYUP:
//  case WM_CHAR: {
//      CefKeyEvent event;
//      event.windows_key_code = wParam;
//      event.native_key_code = lParam;
//      event.is_system_key = message == WM_SYSCHAR ||
//          message == WM_SYSKEYDOWN ||
//          message == WM_SYSKEYUP;
//
//      if (message == WM_KEYDOWN || message == WM_SYSKEYDOWN)
//          event.type = KEYEVENT_RAWKEYDOWN;
//      else if (message == WM_KEYUP || message == WM_SYSKEYUP)
//          event.type = KEYEVENT_KEYUP;
//      else
//          event.type = KEYEVENT_CHAR;
//      event.modifiers = GetCefKeyboardModifiers(wParam, lParam);
//      if (browser.get())
//          browser->SendKeyEvent(event);
//      break;
//                }
//
//  case WM_PAINT: {
//      PAINTSTRUCT ps;
//      RECT rc;
//      BeginPaint(hWnd, &ps);
//      rc = ps.rcPaint;
//      EndPaint(hWnd, &ps);
//      if (browser.get()) {
//          browser->Invalidate(CefRect(rc.left,
//              rc.top,
//              rc.right - rc.left,
//              rc.bottom - rc.top), PET_VIEW);
//      }
//      return 0;
//                 }
//
//  case WM_ERASEBKGND:
//      return 0;
//}

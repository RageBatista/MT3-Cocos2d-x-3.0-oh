#include "CEGUI.h"

#include "include/cef_app.h"
#include "CEGUI.h"
//class ClientHandler;
class ClientBrowserHandler;
class CefBrowser;
class CEGuiD3D9BaseApplication;

class BrowserWindow 
{
public:
    BrowserWindow( CEGuiD3D9BaseApplication* pApp);
    ~BrowserWindow();
    CEGUI::Texture*          m_pTexture;
    CefRefPtr<CefBrowser>    m_pBrowser;

    void OnPaint();
    bool Update(const CEGUI::EventArgs& e);
    bool OnMouseMove(const CEGUI::EventArgs& e);
    bool OnMouseClick(const CEGUI::EventArgs& e);
    bool OnMouseButtonDown(const CEGUI::EventArgs& e);
    bool OnMouseButtonUp(const CEGUI::EventArgs& e);
protected:
	CEGuiD3D9BaseApplication* m_pSampleApp;
private:
    //CefRefPtr<ClientHandler> m_pHandler;
	CefRefPtr<ClientBrowserHandler> m_pHandler;
    bool                     m_bDirty;
};
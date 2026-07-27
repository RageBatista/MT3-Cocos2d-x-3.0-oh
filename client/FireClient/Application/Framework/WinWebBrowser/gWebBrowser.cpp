#include "gWebBrowser.h"
#include "MyWebBrowser.h"
#include "GameApplication.h"
#define GLFW_EXPOSE_NATIVE_WIN32
#define GLFW_EXPOSE_NATIVE_WGL
#include "glfw3native.h"
#include "CCDirector.h"

gWebBrowser* gWebBrowser::m_Inst = NULL;

gWebBrowser::gWebBrowser()
{
	m_listen = false;
}

gWebBrowser::~gWebBrowser()
{
}

gWebBrowser* gWebBrowser::getInstance()
{
	if (!m_Inst) {
		m_Inst = new gWebBrowser();
		m_Inst->init();
	}
	return m_Inst;
}

void gWebBrowser::destroyInstance()
{
	if (m_Inst) {
		m_Inst->destroy();
		delete m_Inst;
		m_Inst = NULL;
	}
}

void gWebBrowser::init()
{
	GLFWwindow* glfwWindow = cocos2d::Director::getInstance()->getOpenGLView()->getWindow();
	HWND m_main_hwnd = glfwGetWin32Window(glfwWindow);
	m_pBrowser = new CMyWebBrowser();
	m_pBrowser->initWindow( m_main_hwnd );
}

void gWebBrowser::destroy()
{
	if( m_pBrowser )
	{
		setVisible(false);
		m_pBrowser->CloseHostWindow();
		delete m_pBrowser;
		m_pBrowser = NULL;
	}
}

void gWebBrowser::setUrl(const char* _url, float sw, float sh)
{
	size_t nLen = strlen(_url)+ 1;
	wchar_t* pwszBuffer = new wchar_t[nLen];
	memset(pwszBuffer, 0, sizeof(wchar_t)*nLen);
	MultiByteToWideChar(CP_ACP, 0, _url, nLen, pwszBuffer, nLen);
	VARIANT var;
	VariantInit(&var);
	var.vt= VT_BSTR;
	var.bstrVal= SysAllocString(pwszBuffer);

	GLFWwindow* glfwWindow = cocos2d::Director::getInstance()->getOpenGLView()->getWindow();
	HWND m_main_hwnd = glfwGetWin32Window(glfwWindow);
	RECT rc;
	GetClientRect(m_main_hwnd, &rc);
	float x = (rc.left + rc.right)*0.5f - sw*0.5f;
	float y = (rc.top + rc.bottom)*0.5f - sh*0.5f;
	m_pBrowser->showWebBrowser(&var, cocos2d::Rect(x, y, sw, sh));

	cocos2d::Director::getInstance()->pause();

	delete[] pwszBuffer;
}

void gWebBrowser::setVisible(bool _show)
{
	if(!m_pBrowser)
		return;

	if (_show)
	{
		cocos2d::Director::getInstance()->pause();
		m_pBrowser->showWebBrowser();
	}
	else
	{
		cocos2d::Director::getInstance()->resume();
		m_pBrowser->hideWebBrowser();
	}
}

void gWebBrowser::update()
{
	if(m_pBrowser) {
		m_pBrowser->updateUrl();
	}
}

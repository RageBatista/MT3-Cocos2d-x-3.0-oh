/** gaoyong change for pcmt
�����ʹ��
*/
#include "MyWebBrowser.h"
#include "WinSDK.h"
#include <iostream>
#include <windows.h>
#include <shellapi.h>

namespace
{
	template <typename T>
	void SafeComRelease(T*& ptr)
	{
		if (ptr)
		{
			ptr->Release();
			ptr = NULL;
		}
	}
}


//�ָ��ַ���
int split_string(const std::string &inputstr, std::string& delimiters, std::vector<std::string> &substrs)
{
	if (inputstr.empty() || delimiters.empty()) {
		return 0;
	}

	size_t find_pos = 0; //the finding position   
	while (true) {
		size_t split_pos = std::string::npos; // ����ķָ���λ��    
		size_t delimiter_size = 0; // ���õ��ķָ�������   

		size_t tpos = inputstr.find(delimiters, find_pos);
		if (tpos != std::string::npos) {
			split_pos = tpos;
			delimiter_size = delimiters.size();
		}

		if (split_pos != std::string::npos) {
			substrs.push_back(inputstr.substr(find_pos, split_pos - find_pos));
			find_pos = split_pos + delimiter_size;
		}
		else {
			substrs.push_back(inputstr.substr(find_pos)); // all the remainder is pushed back   
			break;
		}

	};
	return static_cast<int>(substrs.size());
}

LRESULT CALLBACK WndProcChildren(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_DESTROY:
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
		break;
	}

	return 0;
}

LRESULT CALLBACK WndProcChildren2(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_DESTROY:
		{


			/** gaoyong change for 360pcmt
			*/


			CMyWebBrowserEX** ppWeb= CMyWebBrowserEX::getWebviewInstanceEX();
			if ((*ppWeb)->getNeedClose())
			{
				PostQuitMessage(0);
			}
			else
			{
				// �ص��ر��¼�
				if ((*ppWeb)->m_onClose)
				{
					(*ppWeb)->m_onClose();
					(*ppWeb)->m_onClose= NULL;
				}
			}
			// ����� Win8 �¹رշ������ں󣬿ͻ��˱�������
			if (*ppWeb)
			{
				delete (*ppWeb);
				(*ppWeb) = NULL;
			}
			/* end */
		}
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
		break;
	}

	return 0;
}

CMyWebBrowser::CMyWebBrowser(void)
	: _realurl(NULL), 
	m_hWnd(NULL), 
	_pWB2(NULL), 
	_pHtmlDoc2(NULL), 
	_pHtmlDoc3(NULL), 
	_pHtmlWnd2(NULL), 
	_pHtmlEvent(NULL)
{
}

CMyWebBrowser::~CMyWebBrowser(void)
{
	ReleaseBrowserInterfaces();
	if (_realurl)
	{
		if (*_realurl)
		{
			SysFreeString(*_realurl);
			*_realurl = NULL;
		}
		delete[] _realurl;
		_realurl = NULL;
	}
	m_hWnd = NULL;
}


void CMyWebBrowser::ReleaseBrowserInterfaces()
{
	SafeComRelease(_pHtmlEvent);
	SafeComRelease(_pHtmlWnd2);
	SafeComRelease(_pHtmlDoc3);
	SafeComRelease(_pHtmlDoc2);
	if (_pWB2)
	{
		_pWB2->Stop();
		_pWB2->Quit();
		SafeComRelease(_pWB2);
	}
}

bool CMyWebBrowser::initWindow(HWND hParent)
{
	if (!m_hWnd)
	{
		HINSTANCE hInstance= GetModuleHandle( NULL );
		WNDCLASSEX wc	= {sizeof(WNDCLASSEX)};
		wc.style		= CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
		wc.lpfnWndProc	= WndProcChildren;
		wc.cbClsExtra	= 0;
		wc.cbWndExtra	= 0;
		wc.hInstance	= hInstance;
		wc.hCursor		= LoadCursor(nullptr, IDC_ARROW);
		wc.hbrBackground= (HBRUSH)(COLOR_WINDOW+ 1);
		wc.lpszClassName= L"Web";

		RegisterClassEx(&wc);

		m_hWnd= CreateWindowEx(
			0,
			L"Web",
			L"",
			WS_CHILDWINDOW,
			CW_USEDEFAULT,
			0,
			CW_USEDEFAULT,
			0,
			hParent,
			nullptr,
			hInstance,
			nullptr);

		if (!m_hWnd)
		{
			return false;
		}
	}

	OpenWebBrowser();
	return true;
}

/*
===============
|Other Methods|
===============
*/
IWebBrowser2* 
CMyWebBrowser::GetWebBrowser2()
{
	if (!_realurl)
	{
		_realurl = new BSTR[1];
		*_realurl = NULL;
	}

	USE_DO;
	if( _pWB2 != NULL )
		return _pWB2;
	NULLTEST_SE( _pOleObj,L"Ole����Ϊ��");
	HRTEST_SE( _pOleObj->QueryInterface(IID_IWebBrowser2,(void**)&_pWB2),L"QueryInterface IID_ICOleContainer2 ʧ��");
	return _pWB2;
	USE_WIHLE;
	return NULL;
}

IHTMLDocument2*    
CMyWebBrowser::GetHTMLDocument2()
{
	IWebBrowser2* pWB2 = NULL;
	USE_DO;
	if( _pHtmlDoc2 != NULL )
		return _pHtmlDoc2;
	NULLTEST(pWB2 = GetWebBrowser2());//GetCOleContainer2�Ѿ�������ԭ�򽻸�LastError.
	if(!pWB2)
		return NULL;
	IDispatch* pDp =  NULL;
	HRTEST_SE(pWB2->get_Document(&pDp),L"DCOleContainer2::get_Document ����");
	if(!pDp)
		return NULL;
	HRTEST_SE(pDp->QueryInterface(IID_IHTMLDocument2,(void**)&_pHtmlDoc2),L"QueryInterface IID_IHTMLDocument2 ʧ��");
	pDp->Release();
	return _pHtmlDoc2;
	USE_WIHLE;
	return NULL;
}

IHTMLDocument3*    
CMyWebBrowser::GetHTMLDocument3()
{
    if( _pHtmlDoc3 != NULL )
        return _pHtmlDoc3;

	IWebBrowser2* pWB2 = NULL;
	USE_DO;
	NULLTEST(pWB2 = GetWebBrowser2());//GetCOleContainer2�Ѿ�������ԭ�򽻸�LastError.
	if(!pWB2)
		return NULL;
	IDispatch* pDp =  NULL;
	HRTEST_SE(pWB2->get_Document(&pDp),L"DCOleContainer2::get_Document ����");
	if(!pDp)
		return NULL;
	HRTEST_SE(pDp->QueryInterface(IID_IHTMLDocument3,(void**)&_pHtmlDoc3),L"QueryInterface IID_IHTMLDocument3 ʧ��");
	pDp->Release();
	return _pHtmlDoc3;
	USE_WIHLE;
	return NULL;
}

IHTMLWindow2*
CMyWebBrowser::GetHTMLWindow2()
{
    if( _pHtmlWnd2 != NULL)
        return _pHtmlWnd2;
    IHTMLDocument2*  pHD2 = GetHTMLDocument2();
	USE_DO;
	NULLTEST( pHD2 );
    HRTEST_SE( pHD2->get_parentWindow(&_pHtmlWnd2),L"IHTMLWindow2::get_parentWindow ����" );
    return _pHtmlWnd2;
	USE_WIHLE;
    return NULL;
}

IHTMLEventObj*   
CMyWebBrowser::GetHTMLEventObject()
{
    if( _pHtmlEvent != NULL )
        return _pHtmlEvent;
    IHTMLWindow2* pHW2;
	USE_DO;
	NULLTEST( pHW2 = GetHTMLWindow2() );
    HRTEST_SE( pHW2->get_event(&_pHtmlEvent),L"IHTMLWindow2::get_event ����");
    return _pHtmlEvent;
	USE_WIHLE;
    return NULL;
}

BOOL       
CMyWebBrowser::SetWebRect(LPRECT lprc)
{
    BOOL bRet = FALSE;
	USE_DO;
	if( false == _bInPlaced )//��δOpenCOleContainer����,ֱ��д��_rcWebWnd
    {
       _rcWebWnd = *lprc;
    }
    else//�Ѿ���COleContainer,ͨ�� IOleInPlaceObject::SetObjectRects ������С
    {
        SIZEL size;
        size.cx = lprc->right- lprc->left;
        size.cy = lprc->bottom- lprc->top;

        IOleObject* pOleObj;
        NULLTEST( pOleObj= _GetOleObject());
        HRTEST_SE( pOleObj->SetExtent(  1,&size ),L"SetExtent ����");

        IOleInPlaceObject* pInPlace;
        NULLTEST( pInPlace = _GetInPlaceObject());
        HRTEST_SE( pInPlace->SetObjectRects(lprc,lprc),L"SetObjectRects ����");
        _rcWebWnd = *lprc;
    }
    bRet = TRUE;
	USE_WIHLE;
    return bRet;
}

BOOL    
CMyWebBrowser::OpenWebBrowser()
{
    BOOL bRet = FALSE;
	USE_DO;
	NULLTEST_SE( _GetOleObject(),L"ActiveX����Ϊ��" );//���ڱ�����ʵ�ֺ���,�������е�����¼�빤��
    
    if ( _rcWebWnd.right- _rcWebWnd.left && _rcWebWnd.bottom- _rcWebWnd.top == 0 )
        ::GetClientRect( GetHWND() ,&_rcWebWnd);//����COleContainer�Ĵ�СΪ���ڵĿͻ�����С.
    
    if( _bInPlaced == false )// Activate In Place
    {
        _bInPlaced = true;//_bInPlaced must be set as true, before INPLACEACTIVATE, otherwise, once DoVerb, it would return error;
        _bExternalPlace = 0;//lParam;
    
        HRTEST_SE( _GetOleObject()->DoVerb(OLEIVERB_INPLACEACTIVATE,0,this,0, GetHWND()  ,&_rcWebWnd),L"����INPLACE��DoVerb����");
        _bInPlaced = true;
        
        //* �ҽ�DWebBrwoser2Event
        IConnectionPointContainer* pCPC = NULL;
        IConnectionPoint*          pCP  = NULL;
        HRTEST_SE( GetWebBrowser2()->QueryInterface(IID_IConnectionPointContainer,(void**)&pCPC),L"ö��IConnectionPointContainer�ӿ�ʧ��");
        HRTEST_SE( pCPC->FindConnectionPoint( DIID_DWebBrowserEvents2,&pCP),L"FindConnectionPointʧ��");
        DWORD dwCookie = 0;
        HRTEST_SE( pCP->Advise( (IUnknown*)(void*)this,&dwCookie),L"IConnectionPoint::Adviseʧ��");
		TrackBrowserEventConnection(pCP, dwCookie);
		SafeComRelease(pCPC);
    }

	if (GetWebBrowser2())
	{//�رնԻ�����Ϊ����ʾ������Ϣ���Ƿ��и����ã�δ֪��
		GetWebBrowser2()->put_Silent(VARIANT_TRUE);
	}
    bRet = TRUE;
	USE_WIHLE;
    return bRet;
}

BOOL    
CMyWebBrowser::showWebBrowser(VARIANT* pVarUrl,cocos2d::CCRect rc)
{
	RECT rc1;
	GetClientRect(m_hWnd,&rc1);
	rc1.right = rc1.left+ rc.size.width;
	rc1.bottom= rc1.top+ rc.size.height;
	DWORD dwStyle= GetWindowLong(m_hWnd,GWL_STYLE);
	DWORD dwWXStyle= GetWindowLong(m_hWnd,GWL_EXSTYLE);
	AdjustWindowRectEx(&rc1,dwStyle,false,dwWXStyle);
	SetWindowPos(m_hWnd,0,rc.origin.x,rc.origin.y,rc.size.width,rc.size.height,0 );

	ShowWindow(m_hWnd, SW_SHOW);
	UpdateWindow(m_hWnd);
	GetClientRect(m_hWnd,&rc1);
	SetWebRect(&rc1);

    BOOL bRet = FALSE;
	USE_DO;
	HRTEST_SE( GetWebBrowser2()->Navigate2( pVarUrl,0,0,0,0),L"GetWebBrowser2 ʧ��");
    bRet = TRUE;
	USE_WIHLE;
    return bRet;
}

void CMyWebBrowser::showWebBrowser()
{
	ShowWindow(m_hWnd, SW_SHOW);
}

void CMyWebBrowser::hideWebBrowser()
{
	ShowWindow(m_hWnd, SW_HIDE);
}


void CMyWebBrowser::CloseHostWindow()
{
	ReleaseBrowserInterfaces();
	if (m_hWnd && IsWindow(m_hWnd))
	{
		DestroyWindow(m_hWnd);
	}
	m_hWnd = NULL;
}

IDispatch * CMyWebBrowser::GetJScript()
{
	IHTMLDocument2* doc;  
	doc = GetHTMLDocument2();
	if(!doc)
		return NULL;
	IDispatch * dsScript = NULL;
	HRESULT hr = doc->get_Script(&dsScript);
	if(SUCCEEDED(hr) && dsScript)
		return dsScript;
	else
		return NULL;
}

BOOL CMyWebBrowser::CallJScript(wchar_t * func, VARIANT * vtParams, int cNumberOfParam, VARIANT * vtResult)
{
	if(!func || !func[0])
		return FALSE;
	IDispatch* spScript;
	spScript = GetJScript();
	if(!spScript)
		return FALSE;
	DISPID dispID = NULL;
	// 	CComBSTR bstrFunc(func);
	HRESULT hr = spScript->GetIDsOfNames(IID_NULL,&func, 1, LOCALE_SYSTEM_DEFAULT, &dispID);
	if(FAILED(hr))
		return FALSE;
	DISPPARAMS dispParams = {0};
	dispParams.cArgs = cNumberOfParam;
	//dispParams.rgvarg = CC_NEW VARIANT[cNumberOfParam];
	dispParams.rgvarg = new VARIANT[cNumberOfParam];
	for(int i = 0; i < cNumberOfParam; ++i)
	{
		VariantInit(&dispParams.rgvarg[i]);
		VariantCopy(&dispParams.rgvarg[i], &vtParams[cNumberOfParam - 1 - i]);
	}
	hr = spScript->Invoke(dispID, IID_NULL, 0, DISPATCH_METHOD, &dispParams, vtResult, NULL, NULL);
	//CC_DELETE [] dispParams.rgvarg;
	delete[] dispParams.rgvarg;
	if(FAILED(hr))
		return FALSE;
	return TRUE;
}

bool CMyWebBrowser::updateUrl()
{
	IWebBrowser2* t_browser = GetWebBrowser2();
	if( t_browser )
	{
		if (_realurl && *_realurl)
		{
			SysFreeString(*_realurl);
			*_realurl = NULL;
		}
		t_browser->get_LocationURL(_realurl);
	}
	
	BSTR bstrRealUrl = *_realurl;
	size_t st= wcslen(bstrRealUrl);
	if( st == 0)
	{
		return false;
	}
	char* szPath = new char[st+ 1];//CC_NEW char[st+ 1];
	memset(szPath, 0, st+ 1);
	WideCharToMultiByte(CP_ACP, 0, bstrRealUrl, st, szPath , 1024, NULL, NULL);
	szPath[st]= 0;
	std::string strintRealUrl(szPath);
	std::string t_platform_str;
	std::string t_session_str;

	// yeqing
	std::string strSpli("?");
	size_t pos = strintRealUrl.find_first_of(strSpli);
	if (pos == std::string::npos) {
		delete[] szPath;
		return false;
	}
	strintRealUrl = strintRealUrl.substr(pos + 1);

	strSpli = "&";
	std::vector<std::string> vecStrSplit;
	split_string(strintRealUrl, strSpli, vecStrSplit);

	strSpli = "=";
	for(size_t i = 0; i < vecStrSplit.size(); i++)
	{
		pos = vecStrSplit[i].find_first_of(strSpli);
		if (pos != std::string::npos)
		{
			std::string key = vecStrSplit[i].substr(0, pos);
			std::string value = vecStrSplit[i].substr(pos + strSpli.size());
			if (strcmp(key.c_str(), "PlatformId") == 0)
			{
				t_platform_str = value;
			}
			if (strcmp(key.c_str(), "Session") == 0)
			{
				t_session_str = value;
			}
		}
	}
	if( t_platform_str.size() > 0 && t_session_str.size() > 0 )
	{
		WinSDK::getInstance()->onLoginSuccess(t_platform_str, t_session_str);
		delete[] szPath;
		return true;
	}
	delete[] szPath;
	return false;
}

CMyWebBrowserEX::CMyWebBrowserEX()
	: m_hWnd(NULL), 
	_pWB2(NULL), 
	_pHtmlDoc2(NULL), 
	_pHtmlDoc3(NULL), 
	_pHtmlWnd2(NULL), 
	_pHtmlEvent(NULL)
	,m_onClose(NULL)
{
}

CMyWebBrowserEX::~CMyWebBrowserEX()
{
	ReleaseBrowserInterfaces();
	m_hWnd = NULL;
}

void CMyWebBrowserEX::ReleaseBrowserInterfaces()
{
	SafeComRelease(_pHtmlEvent);
	SafeComRelease(_pHtmlWnd2);
	SafeComRelease(_pHtmlDoc3);
	SafeComRelease(_pHtmlDoc2);
	if (_pWB2)
	{
		_pWB2->Stop();
		_pWB2->Quit();
		SafeComRelease(_pWB2);
	}
}

void CMyWebBrowserEX::CloseHostWindow()
{
	ReleaseBrowserInterfaces();
	if (m_hWnd && IsWindow(m_hWnd))
	{
		DestroyWindow(m_hWnd);
	}
	m_hWnd = NULL;
}


CMyWebBrowserEX**
CMyWebBrowserEX::getWebviewInstanceEX()
{
	static CMyWebBrowserEX* s_pWebviewEX= NULL;
	if (!s_pWebviewEX)
	{
		s_pWebviewEX= new CMyWebBrowserEX();
		s_pWebviewEX->initWindow();
	}
	return &s_pWebviewEX;
}

//����Ϸ�����޹ص�webview����ֵʹ��
bool
CMyWebBrowserEX::initWindow()
{
	if (!m_hWnd)
	{
		HINSTANCE hInstance= GetModuleHandle( NULL );
		WNDCLASSEX wc	= {sizeof(WNDCLASSEX)};
		wc.style		= CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
		wc.lpfnWndProc	= WndProcChildren2;
		wc.cbClsExtra	= 0;
		wc.cbWndExtra	= 0;
		wc.hInstance	= hInstance;
		wc.hCursor		= LoadCursor(nullptr, IDC_ARROW);
		wc.hbrBackground= (HBRUSH)(COLOR_WINDOW+ 1);
		wc.lpszClassName= L"�ҽ�MT3";

		RegisterClassEx(&wc);

		m_hWnd = CreateWindowEx(
			0,
			L"�ҽ�MT3",
			L"�ҽ�MT3",
			WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX,
			CW_USEDEFAULT,
			0,
			CW_USEDEFAULT,
			0,
			NULL,
			nullptr,
			hInstance,
			nullptr);

		if (!m_hWnd)
		{
			return false;
		}
	}

	OpenWebBrowser();
	return true;
}

BOOL       
CMyWebBrowserEX::SetWebRect(LPRECT lprc)
{
	BOOL bRet = FALSE;
	USE_DO;
	if( false == _bInPlaced )//��δOpenCOleContainer����,ֱ��д��_rcWebWnd
	{
		_rcWebWnd = *lprc;
	}
	else//�Ѿ���COleContainer,ͨ�� IOleInPlaceObject::SetObjectRects ������С
	{
		SIZEL size;
		size.cx = lprc->right- lprc->left;
		size.cy = lprc->bottom- lprc->top;

		IOleObject* pOleObj;
		NULLTEST( pOleObj= _GetOleObject());
		HRTEST_SE( pOleObj->SetExtent(  1,&size ),L"SetExtent ����");

		IOleInPlaceObject* pInPlace;
		NULLTEST( pInPlace = _GetInPlaceObject());
		HRTEST_SE( pInPlace->SetObjectRects(lprc,lprc),L"SetObjectRects ����");
		_rcWebWnd = *lprc;
	}
	bRet = TRUE;
	USE_WIHLE;
	return bRet;
}

BOOL    
CMyWebBrowserEX::OpenWebBrowser()
{
    BOOL bRet = FALSE;
	USE_DO;
	NULLTEST_SE( _GetOleObject(),L"ActiveX����Ϊ��" );//���ڱ�����ʵ�ֺ���,�������е�����¼�빤��
    
    if ( _rcWebWnd.right- _rcWebWnd.left && _rcWebWnd.bottom- _rcWebWnd.top == 0 )
        ::GetClientRect( GetHWND() ,&_rcWebWnd);//����COleContainer�Ĵ�СΪ���ڵĿͻ�����С.
    
    if( _bInPlaced == false )// Activate In Place
    {
        _bInPlaced = true;//_bInPlaced must be set as true, before INPLACEACTIVATE, otherwise, once DoVerb, it would return error;
        _bExternalPlace = 0;//lParam;
    
        HRTEST_SE( _GetOleObject()->DoVerb(OLEIVERB_INPLACEACTIVATE,0,this,0, GetHWND()  ,&_rcWebWnd),L"����INPLACE��DoVerb����");
        _bInPlaced = true;
        
        //* �ҽ�DWebBrwoser2Event
        IConnectionPointContainer* pCPC = NULL;
        IConnectionPoint*          pCP  = NULL;
        HRTEST_SE( GetWebBrowser2()->QueryInterface(IID_IConnectionPointContainer,(void**)&pCPC),L"ö��IConnectionPointContainer�ӿ�ʧ��");
        HRTEST_SE( pCPC->FindConnectionPoint( DIID_DWebBrowserEvents2,&pCP),L"FindConnectionPointʧ��");
        DWORD dwCookie = 0;
        HRTEST_SE( pCP->Advise( (IUnknown*)(void*)this,&dwCookie),L"IConnectionPoint::Adviseʧ��");
		TrackBrowserEventConnection(pCP, dwCookie);
		SafeComRelease(pCPC);
    }

	if (GetWebBrowser2())
	{//�رնԻ�����Ϊ����ʾ������Ϣ���Ƿ��и����ã�δ֪��
		GetWebBrowser2()->put_Silent(VARIANT_TRUE);
	}
    bRet = TRUE;
	USE_WIHLE;
    return bRet;
}

//ȫ����ʾ��webvew��������ʾ��ֵ
BOOL    
CMyWebBrowserEX::showWebBrowser(VARIANT* pVarUrl,cocos2d::CCRect rc)
{
	RECT rc1;
	GetClientRect(m_hWnd, &rc1);
	RECT rc2;
	GetWindowRect(m_hWnd, &rc2);

	int width= (rc2.right- rc2.left) - (rc1.right - rc1.left);
	int height= (rc2.bottom- rc2.top) - (rc1.bottom- rc1.top);
	rc1.right = rc1.left+ rc.size.width+ width;
	rc1.bottom= rc1.top+ rc.size.height+ height;
	DWORD dwStyle= GetWindowLong(m_hWnd,GWL_STYLE);
	DWORD dwWXStyle= GetWindowLong(m_hWnd,GWL_EXSTYLE);
	AdjustWindowRectEx(&rc1,dwStyle,false,dwWXStyle);

	//�������ü�
	RECT rcDesktop, rcWindow;
	GetWindowRect(GetDesktopWindow(), &rcDesktop);
	// substract the task bar
	HWND hTaskBar = FindWindow(TEXT("Shell_TrayWnd"), NULL);
	if (hTaskBar != NULL)
	{
		APPBARDATA abd;

		abd.cbSize = sizeof(APPBARDATA);
		abd.hWnd = hTaskBar;

		SHAppBarMessage(ABM_GETTASKBARPOS, &abd);
		SubtractRect(&rcDesktop, &rcDesktop, &abd.rc);
	}
	//GetWindowRect(m_hWnd, &rcWindow);
	rcWindow.left= rc.origin.x;
	rcWindow.right= rc.origin.x+ rc.size.width;
	rcWindow.top= rc.origin.y;
	rcWindow.bottom= rc.origin.y+ rc.size.height;

	int offsetX = (rcDesktop.right - rcDesktop.left - (rcWindow.right - rcWindow.left)) / 2;
	offsetX = (offsetX > 0) ? offsetX : rcDesktop.left;
	int offsetY = (rcDesktop.bottom - rcDesktop.top - (rcWindow.bottom - rcWindow.top)) / 2;
	offsetY = (offsetY > 0) ? offsetY : rcDesktop.top;
	//SetWindowPos(m_hWnd, 0, offsetX, offsetY, 0, 0, SWP_NOCOPYBITS | SWP_NOSIZE | SWP_NOOWNERZORDER | SWP_NOZORDER);
	//end

	//����λ��
	SetWindowPos(m_hWnd,0,offsetX,offsetY,rc.size.width+ width,rc.size.height+ height,0 );

	ShowWindow(m_hWnd, SW_SHOW);
	UpdateWindow(m_hWnd);
	GetClientRect(m_hWnd,&rc1);
	SetWebRect(&rc1);

	BOOL bRet = FALSE;
	USE_DO;
	HRTEST_SE( GetWebBrowser2()->Navigate2( pVarUrl,0,0,0,0),L"GetWebBrowser2 ʧ��");
	bRet = TRUE;
	USE_WIHLE;
	return bRet;
}

void CMyWebBrowserEX::hideWebBrowser()
{
	ShowWindow(m_hWnd, SW_HIDE);
}
/*
===============
|Other Methods|
===============
*/
IWebBrowser2* 
CMyWebBrowserEX::GetWebBrowser2()
{
	USE_DO;
	if( _pWB2 != NULL )
		return _pWB2;
	NULLTEST_SE( _pOleObj,L"Ole����Ϊ��");
	HRTEST_SE( _pOleObj->QueryInterface(IID_IWebBrowser2,(void**)&_pWB2),L"QueryInterface IID_ICOleContainer2 ʧ��");
	return _pWB2;
	USE_WIHLE;
	return NULL;
}

IHTMLDocument2*    
CMyWebBrowserEX::GetHTMLDocument2()
{
	IWebBrowser2* pWB2 = NULL;
	USE_DO;
	if( _pHtmlDoc2 != NULL )
		return _pHtmlDoc2;
	NULLTEST(pWB2 = GetWebBrowser2());//GetCOleContainer2�Ѿ�������ԭ�򽻸�LastError.
	IDispatch* pDp =  NULL;
	HRTEST_SE(pWB2->get_Document(&pDp),L"DCOleContainer2::get_Document ����");
	HRTEST_SE(pDp->QueryInterface(IID_IHTMLDocument2,(void**)&_pHtmlDoc2),L"QueryInterface IID_IHTMLDocument2 ʧ��");
	pDp->Release();
	return _pHtmlDoc2;
	USE_WIHLE;
	return NULL;
}

IHTMLDocument3*    
CMyWebBrowserEX::GetHTMLDocument3()
{
	if( _pHtmlDoc3 != NULL )
		return _pHtmlDoc3;

	IWebBrowser2* pWB2 = NULL;
	USE_DO;
	NULLTEST(pWB2 = GetWebBrowser2());//GetCOleContainer2�Ѿ�������ԭ�򽻸�LastError.
	IDispatch* pDp =  NULL;
	HRTEST_SE(pWB2->get_Document(&pDp),L"DCOleContainer2::get_Document ����");
	HRTEST_SE(pDp->QueryInterface(IID_IHTMLDocument3,(void**)&_pHtmlDoc3),L"QueryInterface IID_IHTMLDocument3 ʧ��");
	pDp->Release();
	return _pHtmlDoc3;
	USE_WIHLE;
	return NULL;
}

IHTMLWindow2*
CMyWebBrowserEX::GetHTMLWindow2()
{
	if( _pHtmlWnd2 != NULL)
		return _pHtmlWnd2;
	IHTMLDocument2*  pHD2 = GetHTMLDocument2();
	USE_DO;
	NULLTEST( pHD2 );
	HRTEST_SE( pHD2->get_parentWindow(&_pHtmlWnd2),L"IHTMLWindow2::get_parentWindow ����" );
	return _pHtmlWnd2;
	USE_WIHLE;
	return NULL;
}

IHTMLEventObj*   
CMyWebBrowserEX::GetHTMLEventObject()
{
	if( _pHtmlEvent != NULL )
		return _pHtmlEvent;
	IHTMLWindow2* pHW2;
	USE_DO;
	NULLTEST( pHW2 = GetHTMLWindow2() );
	HRTEST_SE( pHW2->get_event(&_pHtmlEvent),L"IHTMLWindow2::get_event ����");
	return _pHtmlEvent;
	USE_WIHLE;
	return NULL;
}

void CMyWebBrowserEX::setTranslateAccelerator(UINT message, WPARAM wParam, LPARAM lParam)
{
	if (IsWindowVisible(m_hWnd))
	{
		IWebBrowser2* iBrowser;
		IOleInPlaceActiveObject* pIOIPAO;
		HRESULT hr= GetWebBrowser2()->QueryInterface(IID_IWebBrowser2, (void**)&iBrowser);
		if (SUCCEEDED(hr))
		{
			iBrowser->QueryInterface(IID_IOleInPlaceActiveObject, (void**)&pIOIPAO);
			MSG msg;
			msg.message= message;
			msg.wParam= wParam;
			msg.lParam= lParam;

			pIOIPAO->TranslateAccelerator(&msg);
			pIOIPAO->Release();
		}
		iBrowser->Release();
	}
}

/*	��ҳ��ݼ�����
*/
void CMyWebBrowserEX::setTranslateAccelerator(MSG& msg)
{
	if (IsWindowVisible(m_hWnd))
	{
		IWebBrowser2* iBrowser;
		IOleInPlaceActiveObject* pIOIPAO;
		HRESULT hr= GetWebBrowser2()->QueryInterface(IID_IWebBrowser2, (void**)&iBrowser);
		if (SUCCEEDED(hr))
		{
			hr= iBrowser->QueryInterface(IID_IOleInPlaceActiveObject, (void**)&pIOIPAO);
			if (SUCCEEDED(hr))
			{
				// �˴���һ���жϣ������Ӣ��״̬�µ������ȥ�����ж�
				DWORD wParam = msg.wParam;
				DWORD lParam = msg.lParam;
				if (msg.message == WM_CHAR || msg.message == WM_KEYDOWN || msg.message == WM_KEYUP)
				{
					if (wParam < 0x20)
					{
						if (VK_BACK != wParam)
						{
							pIOIPAO->TranslateAccelerator(&msg);
						}
					}
				}
				pIOIPAO->Release();
			}
		}
		iBrowser->Release();
	}
}

IDispatch * CMyWebBrowserEX::GetJScript()
{
	IHTMLDocument2* doc;  
	doc = GetHTMLDocument2();
	if(!doc)
		return NULL;
	IDispatch * dsScript = NULL;
	HRESULT hr = doc->get_Script(&dsScript);
	if(SUCCEEDED(hr) && dsScript)
		return dsScript;
	else
		return NULL;
}
BOOL CMyWebBrowserEX::CallJScript(wchar_t * func, VARIANT * vtParams, int cNumberOfParam, VARIANT * vtResult)
{
	if(!func || !func[0])
		return FALSE;
	IDispatch* spScript;
	spScript = GetJScript();
	if(!spScript)
		return FALSE;
	DISPID dispID = NULL;
	// 	CComBSTR bstrFunc(func);
	HRESULT hr = spScript->GetIDsOfNames(IID_NULL,&func, 1, LOCALE_SYSTEM_DEFAULT, &dispID);
	if(FAILED(hr))
		return FALSE;
	DISPPARAMS dispParams = {0};
	dispParams.cArgs = cNumberOfParam;
	dispParams.rgvarg = new VARIANT[cNumberOfParam];//CC_NEW VARIANT[cNumberOfParam];
	for(int i = 0; i < cNumberOfParam; ++i)
	{
		VariantInit(&dispParams.rgvarg[i]);
		VariantCopy(&dispParams.rgvarg[i], &vtParams[cNumberOfParam - 1 - i]);
	}
	hr = spScript->Invoke(dispID, IID_NULL, 0, DISPATCH_METHOD, &dispParams, vtResult, NULL, NULL);
	delete[] dispParams.rgvarg;
	//CC_DELETE [] dispParams.rgvarg;
	if(FAILED(hr))
		return FALSE;
	return TRUE;
}
/* end */

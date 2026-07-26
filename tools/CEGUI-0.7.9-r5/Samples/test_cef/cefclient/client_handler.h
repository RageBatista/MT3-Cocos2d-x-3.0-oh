// Copyright (c) 2011 The Chromium Embedded Framework Authors. All rights
// reserved. Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

#ifndef CEF_TESTS_CEFCLIENT_CLIENT_HANDLER_H_
#define CEF_TESTS_CEFCLIENT_CLIENT_HANDLER_H_
#pragma once

#include <map>
#include <string>
#include "include/cef_client.h"
#include "cefclient/util.h"

class BrowserWindow;
// Define this value to redirect all popup URLs to the main application browser
// window.
// #define TEST_REDIRECT_POPUP_URLS


// ClientBrowserHandler implementation
class ClientBrowserHandler :    public CefClient,
								public CefLifeSpanHandler,
								public CefLoadHandler,
								public CefRequestHandler,
								public CefDisplayHandler,
								public CefRenderHandler {
public:
	ClientBrowserHandler(BrowserWindow& window);
	~ClientBrowserHandler();
	// CefClient methods
	virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE {
		return this;
	}
	virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE {
		return this;
	}
	virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE {
		return this;
	}
	virtual CefRefPtr<CefDisplayHandler> GetDisplayHandler() OVERRIDE {
		return this;
	}
	virtual CefRefPtr<CefRenderHandler> GetRenderHandler() OVERRIDE {
		return this;
	}

	// CefLifeSpanHandler methods

	virtual bool OnBeforePopup(CefRefPtr<CefBrowser> parentBrowser,
		const CefPopupFeatures& popupFeatures,
		CefWindowInfo& windowInfo,
		const CefString& url,
		CefRefPtr<CefClient>& client,
		CefBrowserSettings& settings) OVERRIDE;

	virtual void OnAfterCreated(CefRefPtr<CefBrowser> browser) OVERRIDE;
	virtual void OnBeforeClose(CefRefPtr<CefBrowser> browser) OVERRIDE;

	virtual void OnPaint(CefRefPtr<CefBrowser> browser,
		PaintElementType type,
		const RectList& dirtyRects,
		const void* buffer) OVERRIDE;

protected:
	BrowserWindow&              m_window;
	// Include the default reference counting implementation.
	IMPLEMENT_REFCOUNTING(ClientBrowserHandler);
	// Include the default locking implementation.
	IMPLEMENT_LOCKING(ClientBrowserHandler);
};

// ClientHandler implementation.
//class ClientHandler : public CefClient,
//                      public CefLifeSpanHandler,
//                      public CefLoadHandler,
//                      public CefRequestHandler,
//                      public CefDisplayHandler,
//                      public CefFocusHandler,
//                      public CefKeyboardHandler,
//                      public CefPrintHandler,
//                      public CefV8ContextHandler,
//                      public CefDragHandler,
//                      public CefPermissionHandler,
//                      public CefGeolocationHandler,
//					  public CefRenderHandler
//                      //public DownloadListener 
//{
// public:
//  ClientHandler(BrowserWindow& window);
//  virtual ~ClientHandler();
//
//  // CefClient methods
//  virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefDisplayHandler> GetDisplayHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefFocusHandler> GetFocusHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefPrintHandler> GetPrintHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefV8ContextHandler> GetV8ContextHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefDragHandler> GetDragHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefPermissionHandler> GetPermissionHandler() OVERRIDE {
//    return this;
//  }
//  virtual CefRefPtr<CefGeolocationHandler> GetGeolocationHandler() OVERRIDE {
//    return this;
//  }
//
//  virtual void OnAfterCreated(CefRefPtr<CefBrowser> browser) OVERRIDE;
//  virtual bool DoClose(CefRefPtr<CefBrowser> browser) OVERRIDE;
//  virtual void OnBeforeClose(CefRefPtr<CefBrowser> browser) OVERRIDE;
//
//  virtual void OnPaint(CefRefPtr<CefBrowser> browser,
//	  PaintElementType type,
//	  const RectList& dirtyRects,
//	  const void* buffer) OVERRIDE;
//
// protected:
//  BrowserWindow&               m_window;  
//  // Include the default reference counting implementation.
//  IMPLEMENT_REFCOUNTING(ClientHandler);
//  // Include the default locking implementation.
//  IMPLEMENT_LOCKING(ClientHandler);
//};

#endif  // CEF_TESTS_CEFCLIENT_CLIENT_HANDLER_H_

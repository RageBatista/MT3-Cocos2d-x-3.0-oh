// Copyright (c) 2011 The Chromium Embedded Framework Authors. All rights
// reserved. Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

#include "cefclient/client_handler.h"
#include <stdio.h>
#include <sstream>
#include <string>
#include "include/cef_browser.h"
#include "include/cef_command_line.h"
#include "include/cef_frame.h"
#include "cefclient/string_util.h"
#include "include/cef_render_handler.h"
#include "BrowserWindow.h"

ClientBrowserHandler::ClientBrowserHandler(BrowserWindow& window)
	: m_window(window)
{
}

ClientBrowserHandler::~ClientBrowserHandler() {
}

bool ClientBrowserHandler::OnBeforePopup(CefRefPtr<CefBrowser> parentBrowser,
	const CefPopupFeatures& popupFeatures,
	CefWindowInfo& windowInfo,
	const CefString& url,
	CefRefPtr<CefClient>& client,
	CefBrowserSettings& settings){
		REQUIRE_UI_THREAD();

		windowInfo.m_bWindowRenderingDisabled = TRUE;
		//client = new ClientPopupHandler(g_offscreenBrowser);
		return false;
}

void ClientBrowserHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser) {
	REQUIRE_UI_THREAD();
	m_window.m_pBrowser = browser;
}

void ClientBrowserHandler::OnBeforeClose(CefRefPtr<CefBrowser> browser) {
	REQUIRE_UI_THREAD();
	m_window.m_pBrowser = NULL;
}

void ClientBrowserHandler::OnPaint(CefRefPtr<CefBrowser> browser,
	PaintElementType type,
	const RectList& dirtyRects,
	const void* buffer)
{
	if ( !m_window.m_pTexture )
	{
		return;
	}

	m_window.m_pTexture->loadFromMemory(buffer, CEGUI::Size(800, 600), CEGUI::Texture::PF_RGBA);

	m_window.OnPaint();	
}
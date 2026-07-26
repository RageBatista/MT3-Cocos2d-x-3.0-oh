/***********************************************************************
    filename:   Sample_FirstWindow.cpp
    created:    10/3/2005
    author:     Paul D Turner
*************************************************************************/
/***************************************************************************
 *   Copyright (C) 2004 - 2006 Paul D Turner & The CEGUI Development Team
 *
 *   Permission is hereby granted, free of charge, to any person obtaining
 *   a copy of this software and associated documentation files (the
 *   "Software"), to deal in the Software without restriction, including
 *   without limitation the rights to use, copy, modify, merge, publish,
 *   distribute, sublicense, and/or sell copies of the Software, and to
 *   permit persons to whom the Software is furnished to do so, subject to
 *   the following conditions:
 *
 *   The above copyright notice and this permission notice shall be
 *   included in all copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *   IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 *   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 *   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *   OTHER DEALINGS IN THE SOFTWARE.
 ***************************************************************************/
#include "Sample_FirstWindow.h"
#include "BrowserWindow.h"
#include "cef_app.h"
#include "CEGuiD3D9BaseApplication.h"

//#pragma comment(lib, "libcef.lib")
//#pragma comment(lib, "libcef_dll_wrapper.lib")

int main(int /*argc*/, char* /*argv*/[])
{
	CefSettings settings;
	CefRefPtr<CefApp> app1;

	if( !CefInitialize(settings, app1) )
	{
		printf("Init Error!");
	}

    FirstWindowSample app;
	return app.run();
}

FirstWindowSample::FirstWindowSample() : m_pBrowerWin(NULL)
{
}

FirstWindowSample::~FirstWindowSample()
{
	if(m_pBrowerWin)
	{
		delete m_pBrowerWin;
		m_pBrowerWin = NULL;
	}
}

/*************************************************************************
    Sample specific initialisation goes here.
*************************************************************************/
bool FirstWindowSample::initialiseSample()
{
	//add brower win
	if( !m_pBrowerWin )
		m_pBrowerWin = new BrowserWindow( (CEGuiD3D9BaseApplication*)d_sampleApp );
    return true;
}


/*************************************************************************
    Cleans up resources allocated in the initialiseSample call.
*************************************************************************/
void FirstWindowSample::cleanupSample()
{
    // nothing to do here!
}

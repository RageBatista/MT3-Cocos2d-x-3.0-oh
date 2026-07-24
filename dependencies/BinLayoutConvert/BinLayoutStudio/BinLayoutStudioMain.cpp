#include <Windows.h>
#include <CommCtrl.h>
#include <CommDlg.h>

#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <string>

#include "BinLayoutStudioBinCodec.h"
#include "BinLayoutStudioXmlWriter.h"

#include "CEGUIDefaultLogger.h"

namespace
{
	static HINSTANCE g_hInstance = NULL;
	static HWND g_hwndMain = NULL;
	static HWND g_hwndTree = NULL;
	static HWND g_hwndList = NULL;
	static HWND g_hwndLog = NULL;
	static HWND g_hwndPath = NULL;
	static HWND g_btnOpen = NULL;
	static HWND g_btnSaveXml = NULL;
	static HWND g_btnSaveBin = NULL;
	static HMENU g_hMenuBar = NULL;
	static HACCEL g_hAccel = NULL;

	static CEGUI::BinLayout::XMLFileData::NodeData* g_root = NULL;
	static std::string g_openPath;
	static bool g_openIsBin = false;

	// Layout tuning (splitter-based).
	static int g_treeWidth = -1;  // <=0 means auto
	static int g_logHeight = 160;
	static bool g_showLog = true;
	static bool g_dragVSplit = false;
	static bool g_dragHSplit = false;
	static RECT g_vSplitRect = { 0 };
	static RECT g_hSplitRect = { 0 };

	enum
	{
		ID_BTN_OPEN = 1001,
		ID_BTN_SAVEXML = 1002,
		ID_BTN_SAVEBIN = 1003,

		ID_FILE_RELOAD = 1101,
		ID_FILE_EXIT = 1102,

		ID_VIEW_TOGGLE_LOG = 1201,
		ID_VIEW_CLEAR_LOG = 1202,
		ID_VIEW_RESET_LAYOUT = 1203,

		ID_HELP_ABOUT = 1301,
	};

	static void appendLogLine(const std::string& text)
	{
		if (!g_hwndLog)
		{
			return;
		}

		std::string line = text;
		line += "\r\n";

		SendMessageA(g_hwndLog, EM_SETSEL, (WPARAM)-1, (LPARAM)-1);
		SendMessageA(g_hwndLog, EM_REPLACESEL, 0, (LPARAM)line.c_str());
	}

	static void logf(const char* fmt, ...)
	{
		char buf[2048];
		va_list ap;
		va_start(ap, fmt);
		vsnprintf_s(buf, sizeof(buf), _TRUNCATE, fmt, ap);
		va_end(ap);

		appendLogLine(buf);
	}

	static void clearLog()
	{
		if (g_hwndLog)
		{
			SetWindowTextA(g_hwndLog, "");
		}
	}

	static void clearTree()
	{
		if (g_hwndTree)
		{
			TreeView_DeleteAllItems(g_hwndTree);
		}
	}

	static void clearList()
	{
		if (g_hwndList)
		{
			ListView_DeleteAllItems(g_hwndList);
		}
	}

	static bool isBinaryLayoutFile(const char* path)
	{
		FILE* fp = fopen(path, "rb");
		if (!fp)
		{
			return false;
		}

		char magic[4] = { 0 };
		const size_t n = fread(magic, 1, 4, fp);
		fclose(fp);

		return n == 4 && 0 == memcmp(magic, "LBFM", 4);
	}

	static std::string getBaseNameNoExt(const std::string& path)
	{
		size_t slash = path.find_last_of("\\/");
		const size_t start = (slash == std::string::npos) ? 0 : (slash + 1);
		std::string file = path.substr(start);

		size_t dot = file.find_last_of('.');
		if (dot != std::string::npos)
		{
			file = file.substr(0, dot);
		}

		return file;
	}

	static bool pickOpenFile(std::string& outPath)
	{
		char fileBuf[MAX_PATH] = { 0 };

		OPENFILENAMEA ofn = { 0 };
		ofn.lStructSize = sizeof(ofn);
		ofn.hwndOwner = g_hwndMain;
		ofn.lpstrFilter = "CEGUI Layout (*.layout)\0*.layout\0All Files (*.*)\0*.*\0\0";
		ofn.lpstrFile = fileBuf;
		ofn.nMaxFile = sizeof(fileBuf);
		ofn.Flags = OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_EXPLORER;

		if (!GetOpenFileNameA(&ofn))
		{
			return false;
		}

		outPath = fileBuf;
		return true;
	}

	static bool pickSaveFile(const std::string& suggestedFileName, std::string& outPath)
	{
		char fileBuf[MAX_PATH] = { 0 };
		strncpy(fileBuf, suggestedFileName.c_str(), sizeof(fileBuf) - 1);

		OPENFILENAMEA ofn = { 0 };
		ofn.lStructSize = sizeof(ofn);
		ofn.hwndOwner = g_hwndMain;
		ofn.lpstrFilter = "CEGUI Layout (*.layout)\0*.layout\0All Files (*.*)\0*.*\0\0";
		ofn.lpstrFile = fileBuf;
		ofn.nMaxFile = sizeof(fileBuf);
		ofn.Flags = OFN_OVERWRITEPROMPT | OFN_PATHMUSTEXIST | OFN_EXPLORER;
		ofn.lpstrDefExt = "layout";

		if (!GetSaveFileNameA(&ofn))
		{
			return false;
		}

		outPath = fileBuf;
		return true;
	}

	static void ensureListColumns()
	{
		if (!g_hwndList)
		{
			return;
		}

		if (ListView_GetColumnWidth(g_hwndList, 0) != 0)
		{
			return;
		}

		LVCOLUMNA col = { 0 };
		col.mask = LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM;

		col.pszText = const_cast<char*>("Name");
		col.cx = 220;
		col.iSubItem = 0;
		ListView_InsertColumn(g_hwndList, 0, &col);

		col.pszText = const_cast<char*>("Value");
		col.cx = 700;
		col.iSubItem = 1;
		ListView_InsertColumn(g_hwndList, 1, &col);
	}

	static void resizeListColumns(int listWidth)
	{
		if (!g_hwndList)
		{
			return;
		}

		ensureListColumns();

		const int col0 = 220;
		const int col1 = (listWidth > col0 + 40) ? (listWidth - col0 - 6) : 200;
		ListView_SetColumnWidth(g_hwndList, 0, col0);
		ListView_SetColumnWidth(g_hwndList, 1, col1);
	}

	static void listAddRow(int row, const char* name, const char* value)
	{
		LVITEMA item = { 0 };
		item.mask = LVIF_TEXT;
		item.iItem = row;
		item.iSubItem = 0;
		item.pszText = const_cast<char*>(name);
		ListView_InsertItem(g_hwndList, &item);
		ListView_SetItemText(g_hwndList, row, 1, const_cast<char*>(value));
	}

	static void showNodeDetails(const CEGUI::BinLayout::XMLFileData::NodeData* node)
	{
		using namespace CEGUI::BinLayout;

		clearList();
		ensureListColumns();

		if (!node)
		{
			return;
		}

		int row = 0;
		const NodeType t = node->getType();
		if (t == NT_Window)
		{
			const XMLFileData::WindowData* w = static_cast<const XMLFileData::WindowData*>(node);
			listAddRow(row++, "Type", w->mType.c_str());
			listAddRow(row++, "Name", w->mName.c_str());

			for (int i = 0; i < node->getChildCount(); ++i)
			{
				const XMLFileData::NodeData* child = node->getChild(i);
				if (child && child->getType() == NT_Property)
				{
					const XMLFileData::PropertyData* p = static_cast<const XMLFileData::PropertyData*>(child);
					listAddRow(row++, p->mName.c_str(), p->mValue.c_str());
				}
			}
		}
		else if (t == NT_AutoWindow)
		{
			const XMLFileData::AutoWindowData* w = static_cast<const XMLFileData::AutoWindowData*>(node);
			listAddRow(row++, "AutoWindow NameSuffix", w->mNameSuffix.c_str());

			for (int i = 0; i < node->getChildCount(); ++i)
			{
				const XMLFileData::NodeData* child = node->getChild(i);
				if (child && child->getType() == NT_Property)
				{
					const XMLFileData::PropertyData* p = static_cast<const XMLFileData::PropertyData*>(child);
					listAddRow(row++, p->mName.c_str(), p->mValue.c_str());
				}
			}
		}
		else if (t == NT_LayoutImport)
		{
			const XMLFileData::LayoutImportData* li = static_cast<const XMLFileData::LayoutImportData*>(node);
			listAddRow(row++, "Prefix", li->mPrefix.c_str());
			listAddRow(row++, "Filename", li->mFilename.c_str());
			listAddRow(row++, "ResourceGroup", li->mResourceGroup.c_str());
		}
		else if (t == NT_Event)
		{
			const XMLFileData::EventData* e = static_cast<const XMLFileData::EventData*>(node);
			listAddRow(row++, "Name", e->mName.c_str());
			listAddRow(row++, "Function", e->mFunction.c_str());
		}
	}

	static HTREEITEM addTreeItem(HTREEITEM parent, const char* text, const CEGUI::BinLayout::XMLFileData::NodeData* node)
	{
		TVINSERTSTRUCTA ti = { 0 };
		ti.hParent = parent;
		ti.hInsertAfter = TVI_LAST;
		ti.item.mask = TVIF_TEXT | TVIF_PARAM;
		ti.item.pszText = const_cast<char*>(text);
		ti.item.lParam = reinterpret_cast<LPARAM>(node);

		return TreeView_InsertItem(g_hwndTree, &ti);
	}

	static void populateTreeRecursive(const CEGUI::BinLayout::XMLFileData::NodeData* node, HTREEITEM parent)
	{
		using namespace CEGUI::BinLayout;

		if (!node)
		{
			return;
		}

		char buf[1024] = { 0 };
		HTREEITEM self = NULL;

		switch (node->getType())
		{
		case NT_Window:
		{
			const XMLFileData::WindowData* w = static_cast<const XMLFileData::WindowData*>(node);
			sprintf_s(buf, sizeof(buf), "%s [%s]", w->mName.c_str(), w->mType.c_str());
			self = addTreeItem(parent, buf, node);
			break;
		}
		case NT_AutoWindow:
		{
			const XMLFileData::AutoWindowData* w = static_cast<const XMLFileData::AutoWindowData*>(node);
			sprintf_s(buf, sizeof(buf), "AutoWindow %s", w->mNameSuffix.c_str());
			self = addTreeItem(parent, buf, node);
			break;
		}
		case NT_LayoutImport:
		{
			const XMLFileData::LayoutImportData* li = static_cast<const XMLFileData::LayoutImportData*>(node);
			sprintf_s(buf, sizeof(buf), "LayoutImport %s", li->mFilename.c_str());
			self = addTreeItem(parent, buf, node);
			break;
		}
		case NT_Event:
		{
			const XMLFileData::EventData* e = static_cast<const XMLFileData::EventData*>(node);
			sprintf_s(buf, sizeof(buf), "Event %s", e->mName.c_str());
			self = addTreeItem(parent, buf, node);
			break;
		}
		default:
			return;
		}

		if (!self)
		{
			return;
		}

		for (int i = 0; i < node->getChildCount(); ++i)
		{
			const XMLFileData::NodeData* child = node->getChild(i);
			if (!child || child->getType() == NT_Property)
			{
				continue;
			}

			populateTreeRecursive(child, self);
		}
	}

	static void refreshUiEnabled()
	{
		const BOOL hasOpen = !g_openPath.empty();
		const BOOL hasTree = (g_root != NULL);

		EnableWindow(g_btnSaveXml, hasTree);
		EnableWindow(g_btnSaveBin, hasOpen);

		if (g_hMenuBar)
		{
			EnableMenuItem(g_hMenuBar, ID_BTN_SAVEXML, MF_BYCOMMAND | (hasTree ? MF_ENABLED : MF_GRAYED));
			EnableMenuItem(g_hMenuBar, ID_BTN_SAVEBIN, MF_BYCOMMAND | (hasOpen ? MF_ENABLED : MF_GRAYED));
			DrawMenuBar(g_hwndMain);
		}
	}

	static void freeCurrentDoc()
	{
		if (g_root)
		{
			BinLayoutStudio::Core::FreeXmlData(g_root);
			g_root = NULL;
		}
	}

	static void updatePathBar()
	{
		if (!g_hwndPath)
		{
			return;
		}

		if (g_openPath.empty())
		{
			SetWindowTextW(g_hwndPath, L"\u672A\u6253\u5F00\u6587\u4EF6");
			return;
		}

		// Note: internal path is ANSI (CEGUI XMLToBin uses fopen). For UI display, best-effort convert from ACP.
		wchar_t wbuf[2048] = { 0 };
		MultiByteToWideChar(CP_ACP, 0, g_openPath.c_str(), -1, wbuf, (int)(sizeof(wbuf) / sizeof(wbuf[0])));

		std::wstring text = g_openIsBin ? L"BIN: " : L"XML: ";
		text += wbuf;
		SetWindowTextW(g_hwndPath, text.c_str());
	}

	static void loadFile(const std::string& path)
	{
		freeCurrentDoc();
		clearTree();
		clearList();

		g_openPath = path;
		g_openIsBin = isBinaryLayoutFile(path.c_str());

		logf("Open: %s", path.c_str());
		logf("Detected: %s", g_openIsBin ? "BIN (LBFM)" : "XML (non-LBFM)");

		if (g_openIsBin)
		{
			std::string err;
			if (!BinLayoutStudio::Core::LoadBinLayoutToXmlData(path.c_str(), &g_root, err))
			{
				logf("Parse BIN failed: %s", err.c_str());
				g_root = NULL;
			}
			else
			{
				populateTreeRecursive(g_root, TVI_ROOT);
				TreeView_Expand(g_hwndTree, TreeView_GetRoot(g_hwndTree), TVE_EXPAND);
				logf("Parse BIN ok");
			}
		}
		else
		{
			logf("XML file detected. Use 'Export BIN' to generate binary layout.");
		}

		updatePathBar();
		refreshUiEnabled();
	}

	static void saveXmlAs()
	{
		if (!g_root)
		{
			MessageBoxW(g_hwndMain, L"\u5F53\u524D\u672A\u52A0\u8F7D BIN \u5E03\u5C40, \u65E0\u6CD5\u5BFC\u51FA XML.", L"BinLayoutStudio", MB_ICONWARNING);
			return;
		}

		const std::string base = getBaseNameNoExt(g_openPath);
		std::string savePath;
		if (!pickSaveFile(base + "_xml.layout", savePath))
		{
			return;
		}

		std::string xml;
		std::string err;
		if (!BinLayoutStudio::Core::BuildLayoutXml(g_root, xml, err))
		{
			logf("Build XML failed: %s", err.c_str());
			return;
		}

		FILE* fp = fopen(savePath.c_str(), "wb");
		if (!fp)
		{
			logf("Write failed: %s", savePath.c_str());
			return;
		}
		fwrite(xml.data(), 1, xml.size(), fp);
		fclose(fp);

		logf("Exported XML: %s", savePath.c_str());
	}

	static void saveBinAs()
	{
		if (g_openPath.empty())
		{
			MessageBoxW(g_hwndMain, L"\u8BF7\u5148\u6253\u5F00\u4E00\u4E2A .layout \u6587\u4EF6.", L"BinLayoutStudio", MB_ICONWARNING);
			return;
		}

		const std::string base = getBaseNameNoExt(g_openPath);
		std::string savePath;
		if (!pickSaveFile(base + "_bin.layout", savePath))
		{
			return;
		}

		std::string err;
		if (g_openIsBin)
		{
			if (!g_root)
			{
				MessageBoxW(g_hwndMain, L"BIN \u89E3\u6790\u5931\u8D25\u6216\u5C1A\u672A\u52A0\u8F7D, \u65E0\u6CD5\u5BFC\u51FA BIN.", L"BinLayoutStudio", MB_ICONWARNING);
				return;
			}

			if (!BinLayoutStudio::Core::WriteXmlDataToBinFile(savePath.c_str(), g_root, err))
			{
				logf("Export BIN failed: %s", err.c_str());
				return;
			}
		}
		else
		{
			if (!BinLayoutStudio::Core::ConvertXmlToBinFile(g_openPath.c_str(), savePath.c_str(), err))
			{
				logf("XML->BIN failed: %s", err.c_str());
				return;
			}
		}

		logf("Exported BIN: %s", savePath.c_str());
	}

	static void resetLayoutDefaults()
	{
		g_treeWidth = -1;
		g_logHeight = 160;
		g_showLog = true;
		g_dragVSplit = false;
		g_dragHSplit = false;
	}

	static void doLayout(int clientW, int clientH)
	{
		const int padding = 8;
		const int gap = 6;       // splitter thickness
		const int topBarH = 38;
		const int btnH = 26;
		const int btnW = 92;
		const int btnGap = 6;

		const int minTreeW = 220;
		const int minListW = 320;
		const int minLogH = 80;
		const int minContentH = 160;

		const int contentTop = topBarH + padding;
		const int bottom = clientH - padding;

		int logH = 0;
		if (g_showLog)
		{
			const int maxLogH = (bottom - contentTop) - minContentH - gap;
			if (g_logHeight < minLogH)
			{
				g_logHeight = minLogH;
			}
			if (g_logHeight > maxLogH)
			{
				g_logHeight = maxLogH;
			}
			logH = g_logHeight;
		}

		const int contentBottom = g_showLog ? (bottom - logH - gap) : bottom;
		const int contentH = contentBottom - contentTop;

		const int availW = clientW - padding * 2;
		const int maxTreeW = availW - minListW - gap;
		if (g_treeWidth <= 0)
		{
			g_treeWidth = availW / 3;
		}
		if (g_treeWidth < minTreeW)
		{
			g_treeWidth = minTreeW;
		}
		if (g_treeWidth > maxTreeW)
		{
			g_treeWidth = maxTreeW;
		}

		const int treeW = g_treeWidth;
		const int listW = availW - treeW - gap;

		MoveWindow(g_btnOpen, padding, 6, btnW, btnH, TRUE);
		MoveWindow(g_btnSaveXml, padding + (btnW + btnGap) * 1, 6, btnW, btnH, TRUE);
		MoveWindow(g_btnSaveBin, padding + (btnW + btnGap) * 2, 6, btnW, btnH, TRUE);

		const int pathX = padding + (btnW + btnGap) * 3 + btnGap;
		const int pathW = (clientW > pathX + padding) ? (clientW - pathX - padding) : 10;
		MoveWindow(g_hwndPath, pathX, 6, pathW, btnH, TRUE);

		MoveWindow(g_hwndTree, padding, contentTop, treeW, contentH, TRUE);
		MoveWindow(g_hwndList, padding + treeW + gap, contentTop, listW, contentH, TRUE);

		if (g_showLog)
		{
			ShowWindow(g_hwndLog, SW_SHOW);
			MoveWindow(g_hwndLog, padding, contentBottom + gap, availW, logH, TRUE);
		}
		else
		{
			ShowWindow(g_hwndLog, SW_HIDE);
		}

		resizeListColumns(listW);

		// Splitter rects (parent client coordinates).
		g_vSplitRect.left = padding + treeW;
		g_vSplitRect.right = g_vSplitRect.left + gap;
		g_vSplitRect.top = contentTop;
		g_vSplitRect.bottom = contentBottom;

		if (g_showLog)
		{
			g_hSplitRect.left = padding;
			g_hSplitRect.right = padding + availW;
			g_hSplitRect.top = contentBottom;
			g_hSplitRect.bottom = g_hSplitRect.top + gap;
		}
		else
		{
			SetRectEmpty(&g_hSplitRect);
		}

		if (g_hwndMain)
		{
			InvalidateRect(g_hwndMain, NULL, FALSE);
		}
	}

	static bool isInRect(const RECT& rc, int x, int y)
	{
		return (x >= rc.left && x < rc.right && y >= rc.top && y < rc.bottom);
	}

	static void toggleLogVisibility()
	{
		g_showLog = !g_showLog;
		if (g_hMenuBar)
		{
			CheckMenuItem(g_hMenuBar, ID_VIEW_TOGGLE_LOG, MF_BYCOMMAND | (g_showLog ? MF_CHECKED : MF_UNCHECKED));
		}

		RECT rc;
		GetClientRect(g_hwndMain, &rc);
		doLayout(rc.right - rc.left, rc.bottom - rc.top);
	}

	static void showAbout()
	{
		MessageBoxW(g_hwndMain,
			L"BinLayoutStudio\n"
			L"\n"
			L"\u4F5C\u8005:\n"
			L"  Super\u68A6\u5E7B\u4E92\u5A31Team-<super9118@gmail.com>\n"
			L"  \u7EF4\u62A4/\u5236\u4F5C\uFF1Asuper \u5A01\u5C11QQ:1583812938\n"
			L"\n"
			L"\u529F\u80FD:\n"
			L"  - BIN(LBFM) <-> XML \u53CC\u5411\u8F6C\u6362\n"
			L"  - \u7ED3\u6784\u6811 / \u5C5E\u6027\u67E5\u770B\n"
			L"\n"
			L"\u5FEB\u6377\u952E:\n"
			L"  Ctrl+O \u6253\u5F00\n"
			L"  Ctrl+E \u5BFC\u51FA XML\n"
			L"  Ctrl+B \u5BFC\u51FA BIN\n"
			L"  F5     \u91CD\u65B0\u52A0\u8F7D\n"
			L"  Ctrl+L \u6E05\u7A7A\u65E5\u5FD7\n"
			L"\n"
			L"\u63D0\u793A:\n"
			L"  - \u62D6\u62FD\u5206\u9694\u7EBF\u8C03\u6574\u5E03\u5C40\n",
			L"\u5173\u4E8E BinLayoutStudio",
			MB_OK | MB_ICONINFORMATION);
	}

	static void initMenuAndAccel(HWND hwnd)
	{
		// Menu
		HMENU fileMenu = CreatePopupMenu();
		AppendMenuW(fileMenu, MF_STRING, ID_BTN_OPEN, L"\u6253\u5F00(&O)...\tCtrl+O");
		AppendMenuW(fileMenu, MF_STRING, ID_FILE_RELOAD, L"\u91CD\u65B0\u52A0\u8F7D(&R)\tF5");
		AppendMenuW(fileMenu, MF_SEPARATOR, 0, NULL);
		AppendMenuW(fileMenu, MF_STRING, ID_FILE_EXIT, L"\u9000\u51FA(&X)");

		HMENU convertMenu = CreatePopupMenu();
		AppendMenuW(convertMenu, MF_STRING, ID_BTN_SAVEXML, L"\u5BFC\u51FA\u4E3A XML(&X)...\tCtrl+E");
		AppendMenuW(convertMenu, MF_STRING, ID_BTN_SAVEBIN, L"\u5BFC\u51FA\u4E3A BIN(&B)...\tCtrl+B");

		HMENU viewMenu = CreatePopupMenu();
		AppendMenuW(viewMenu, MF_STRING, ID_VIEW_TOGGLE_LOG, L"\u663E\u793A\u65E5\u5FD7(&L)");
		AppendMenuW(viewMenu, MF_STRING, ID_VIEW_CLEAR_LOG, L"\u6E05\u7A7A\u65E5\u5FD7\tCtrl+L");
		AppendMenuW(viewMenu, MF_SEPARATOR, 0, NULL);
		AppendMenuW(viewMenu, MF_STRING, ID_VIEW_RESET_LAYOUT, L"\u91CD\u7F6E\u5E03\u5C40");

		HMENU helpMenu = CreatePopupMenu();
		AppendMenuW(helpMenu, MF_STRING, ID_HELP_ABOUT, L"\u5173\u4E8E(&A)...");

		g_hMenuBar = CreateMenu();
		AppendMenuW(g_hMenuBar, MF_POPUP, (UINT_PTR)fileMenu, L"\u6587\u4EF6(&F)");
		AppendMenuW(g_hMenuBar, MF_POPUP, (UINT_PTR)convertMenu, L"\u8F6C\u6362(&C)");
		AppendMenuW(g_hMenuBar, MF_POPUP, (UINT_PTR)viewMenu, L"\u89C6\u56FE(&V)");
		AppendMenuW(g_hMenuBar, MF_POPUP, (UINT_PTR)helpMenu, L"\u5E2E\u52A9(&H)");

		SetMenu(hwnd, g_hMenuBar);
		CheckMenuItem(g_hMenuBar, ID_VIEW_TOGGLE_LOG, MF_BYCOMMAND | (g_showLog ? MF_CHECKED : MF_UNCHECKED));

		// Accelerators
		ACCEL accels[] = {
			{ FVIRTKEY | FCONTROL, 'O', ID_BTN_OPEN },
			{ FVIRTKEY | FCONTROL, 'E', ID_BTN_SAVEXML },
			{ FVIRTKEY | FCONTROL, 'B', ID_BTN_SAVEBIN },
			{ FVIRTKEY, VK_F5, ID_FILE_RELOAD },
			{ FVIRTKEY | FCONTROL, 'L', ID_VIEW_CLEAR_LOG },
		};
		g_hAccel = CreateAcceleratorTable(accels, sizeof(accels) / sizeof(accels[0]));
	}

	static LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
	{
		switch (msg)
		{
		case WM_CREATE:
		{
			g_hwndMain = hwnd;

			g_btnOpen = CreateWindowW(L"BUTTON", L"\u6253\u5F00", WS_CHILD | WS_VISIBLE | WS_TABSTOP, 8, 6, 92, 26, hwnd, (HMENU)ID_BTN_OPEN, g_hInstance, NULL);
			g_btnSaveXml = CreateWindowW(L"BUTTON", L"\u5BFC\u51FAXML", WS_CHILD | WS_VISIBLE | WS_TABSTOP, 106, 6, 92, 26, hwnd, (HMENU)ID_BTN_SAVEXML, g_hInstance, NULL);
			g_btnSaveBin = CreateWindowW(L"BUTTON", L"\u5BFC\u51FABIN", WS_CHILD | WS_VISIBLE | WS_TABSTOP, 204, 6, 92, 26, hwnd, (HMENU)ID_BTN_SAVEBIN, g_hInstance, NULL);
			g_hwndPath = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", L"\u672A\u6253\u5F00\u6587\u4EF6",
				WS_CHILD | WS_VISIBLE | WS_TABSTOP | ES_READONLY | ES_AUTOHSCROLL,
				304, 6, 680, 26, hwnd, NULL, g_hInstance, NULL);

			g_hwndTree = CreateWindowExA(WS_EX_CLIENTEDGE, WC_TREEVIEWA, "",
				WS_CHILD | WS_VISIBLE | WS_TABSTOP | TVS_HASLINES | TVS_LINESATROOT | TVS_HASBUTTONS,
				8, 40, 350, 500, hwnd, NULL, g_hInstance, NULL);

			g_hwndList = CreateWindowExA(WS_EX_CLIENTEDGE, WC_LISTVIEWA, "",
				WS_CHILD | WS_VISIBLE | WS_TABSTOP | LVS_REPORT | LVS_SINGLESEL | LVS_SHOWSELALWAYS,
				366, 40, 650, 500, hwnd, NULL, g_hInstance, NULL);

			g_hwndLog = CreateWindowExA(WS_EX_CLIENTEDGE, "EDIT", "",
				WS_CHILD | WS_VISIBLE | WS_VSCROLL | ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_READONLY,
				8, 550, 1008, 160, hwnd, NULL, g_hInstance, NULL);

			ListView_SetExtendedListViewStyle(g_hwndList, LVS_EX_FULLROWSELECT | LVS_EX_GRIDLINES);

			initMenuAndAccel(hwnd);
			resetLayoutDefaults();
			updatePathBar();
			refreshUiEnabled();
			return 0;
		}
		case WM_SIZE:
		{
			const int w = LOWORD(lParam);
			const int h = HIWORD(lParam);

			doLayout(w, h);

			return 0;
		}
		case WM_PAINT:
		{
			PAINTSTRUCT ps;
			HDC hdc = BeginPaint(hwnd, &ps);
			FillRect(hdc, &ps.rcPaint, (HBRUSH)(COLOR_WINDOW + 1));

			if (!IsRectEmpty(&g_vSplitRect))
			{
				DrawEdge(hdc, &g_vSplitRect, EDGE_ETCHED, BF_RECT);
			}
			if (!IsRectEmpty(&g_hSplitRect))
			{
				DrawEdge(hdc, &g_hSplitRect, EDGE_ETCHED, BF_RECT);
			}

			EndPaint(hwnd, &ps);
			return 0;
		}
		case WM_SETCURSOR:
		{
			if (LOWORD(lParam) == HTCLIENT)
			{
				POINT pt;
				GetCursorPos(&pt);
				ScreenToClient(hwnd, &pt);

				if (isInRect(g_vSplitRect, pt.x, pt.y))
				{
					SetCursor(LoadCursor(NULL, IDC_SIZEWE));
					return TRUE;
				}
				if (g_showLog && isInRect(g_hSplitRect, pt.x, pt.y))
				{
					SetCursor(LoadCursor(NULL, IDC_SIZENS));
					return TRUE;
				}
			}
			break;
		}
		case WM_LBUTTONDOWN:
		{
			const int x = (short)LOWORD(lParam);
			const int y = (short)HIWORD(lParam);

			if (isInRect(g_vSplitRect, x, y))
			{
				g_dragVSplit = true;
				SetCapture(hwnd);
				return 0;
			}
			if (g_showLog && isInRect(g_hSplitRect, x, y))
			{
				g_dragHSplit = true;
				SetCapture(hwnd);
				return 0;
			}
			break;
		}
		case WM_MOUSEMOVE:
		{
			if (g_dragVSplit || g_dragHSplit)
			{
				const int x = (short)LOWORD(lParam);
				const int y = (short)HIWORD(lParam);

				RECT rc;
				GetClientRect(hwnd, &rc);
				const int w = rc.right - rc.left;
				const int h = rc.bottom - rc.top;

				const int padding = 8;
				const int gap = 6;
				const int topBarH = 38;
				const int minTreeW = 220;
				const int minListW = 320;
				const int minLogH = 80;
				const int minContentH = 160;

				if (g_dragVSplit)
				{
					const int availW = w - padding * 2;
					const int maxTreeW = availW - minListW - gap;
					int newTreeW = x - padding;
					if (newTreeW < minTreeW) newTreeW = minTreeW;
					if (newTreeW > maxTreeW) newTreeW = maxTreeW;
					g_treeWidth = newTreeW;
				}
				if (g_dragHSplit && g_showLog)
				{
					// log height = bottom - (splitTop + gap)
					const int contentTop = topBarH + padding;
					const int bottom = h - padding;
					const int maxLogH = (bottom - contentTop) - minContentH - gap;
					int newLogH = (bottom - (y + gap));
					if (newLogH < minLogH) newLogH = minLogH;
					if (newLogH > maxLogH) newLogH = maxLogH;
					g_logHeight = newLogH;
				}

				doLayout(w, h);
				return 0;
			}
			break;
		}
		case WM_LBUTTONUP:
		{
			if (g_dragVSplit || g_dragHSplit)
			{
				g_dragVSplit = false;
				g_dragHSplit = false;
				ReleaseCapture();
				return 0;
			}
			break;
		}
		case WM_CAPTURECHANGED:
		{
			g_dragVSplit = false;
			g_dragHSplit = false;
			break;
		}
		case WM_COMMAND:
		{
			switch (LOWORD(wParam))
			{
			case ID_BTN_OPEN:
			{
				std::string path;
				if (pickOpenFile(path))
				{
					loadFile(path);
				}
				return 0;
			}
			case ID_BTN_SAVEXML:
				saveXmlAs();
				return 0;
			case ID_BTN_SAVEBIN:
				saveBinAs();
				return 0;
			case ID_FILE_RELOAD:
				if (!g_openPath.empty())
				{
					loadFile(g_openPath);
				}
				return 0;
			case ID_FILE_EXIT:
				DestroyWindow(hwnd);
				return 0;
			case ID_VIEW_TOGGLE_LOG:
				toggleLogVisibility();
				return 0;
			case ID_VIEW_CLEAR_LOG:
				clearLog();
				return 0;
			case ID_VIEW_RESET_LAYOUT:
			{
				resetLayoutDefaults();
				if (g_hMenuBar)
				{
					CheckMenuItem(g_hMenuBar, ID_VIEW_TOGGLE_LOG, MF_BYCOMMAND | (g_showLog ? MF_CHECKED : MF_UNCHECKED));
				}
				RECT rc;
				GetClientRect(g_hwndMain, &rc);
				doLayout(rc.right - rc.left, rc.bottom - rc.top);
				return 0;
			}
			case ID_HELP_ABOUT:
				showAbout();
				return 0;
			default:
				break;
			}
			break;
		}
		case WM_NOTIFY:
		{
			NMHDR* hdr = reinterpret_cast<NMHDR*>(lParam);
			if (hdr && hdr->hwndFrom == g_hwndTree && hdr->code == TVN_SELCHANGEDA)
			{
				NMTREEVIEWA* tv = reinterpret_cast<NMTREEVIEWA*>(lParam);
				const CEGUI::BinLayout::XMLFileData::NodeData* node =
					reinterpret_cast<const CEGUI::BinLayout::XMLFileData::NodeData*>(tv->itemNew.lParam);
				showNodeDetails(node);
				return 0;
			}
			break;
		}
		case WM_DESTROY:
			freeCurrentDoc();
			if (g_hAccel)
			{
				DestroyAcceleratorTable(g_hAccel);
				g_hAccel = NULL;
			}
			PostQuitMessage(0);
			return 0;
		default:
			break;
		}

		return DefWindowProc(hwnd, msg, wParam, lParam);
	}
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nCmdShow)
{
	g_hInstance = hInstance;

	// CLI mode (optional): enables quick batch conversion without GUI.
	// Usage:
	//   BinLayoutStudio.exe --bin2xml <in.layout> <out.layout>
	//   BinLayoutStudio.exe --xml2bin <in.layout> <out.layout>
	if (__argc >= 2)
	{
		const char* cmd = __argv[1];
		if (0 == strcmp(cmd, "--help") || 0 == strcmp(cmd, "-h") || 0 == strcmp(cmd, "/?"))
		{
			AllocConsole();
			freopen("CONOUT$", "w", stdout);
			fprintf(stdout,
				"BinLayoutStudio\n"
				"  --bin2xml <in.layout> <out.layout>\n"
				"  --xml2bin <in.layout> <out.layout>\n");
			return 0;
		}
		if ((0 == strcmp(cmd, "--bin2xml") || 0 == strcmp(cmd, "--xml2bin")) && __argc >= 4)
		{
			AllocConsole();
			freopen("CONOUT$", "w", stdout);

			const char* inPath = __argv[2];
			const char* outPath = __argv[3];
			std::string err;

			bool ok = false;
			if (0 == strcmp(cmd, "--bin2xml"))
			{
				ok = BinLayoutStudio::Core::ConvertBinToXmlFile(inPath, outPath, err);
			}
			else
			{
				ok = BinLayoutStudio::Core::ConvertXmlToBinFile(inPath, outPath, err);
			}

			if (!ok)
			{
				fprintf(stdout, "FAILED: %s\n", err.c_str());
				return 1;
			}

			fprintf(stdout, "OK\n");
			return 0;
		}
	}

	INITCOMMONCONTROLSEX icc = { 0 };
	icc.dwSize = sizeof(icc);
	icc.dwICC = ICC_TREEVIEW_CLASSES | ICC_LISTVIEW_CLASSES;
	InitCommonControlsEx(&icc);

	CEGUI::DefaultLogger logger;

	WNDCLASSA wc = { 0 };
	wc.lpfnWndProc = WndProc;
	wc.hInstance = hInstance;
	wc.lpszClassName = "BinLayoutStudioWnd";
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);

	if (!RegisterClassA(&wc))
	{
		MessageBoxA(NULL, "RegisterClass failed.", "BinLayoutStudio", MB_ICONERROR);
		return 1;
	}

	g_hwndMain = CreateWindowA(
		wc.lpszClassName,
		"BinLayoutStudio (Bin <-> XML)",
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, CW_USEDEFAULT, 1100, 800,
		NULL, NULL, hInstance, NULL);

	if (!g_hwndMain)
	{
		MessageBoxA(NULL, "CreateWindow failed.", "BinLayoutStudio", MB_ICONERROR);
		return 1;
	}

	ShowWindow(g_hwndMain, nCmdShow);
	UpdateWindow(g_hwndMain);

	MSG msg;
	while (GetMessage(&msg, NULL, 0, 0))
	{
		if (g_hAccel && TranslateAccelerator(g_hwndMain, g_hAccel, &msg))
		{
			continue;
		}

		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	return static_cast<int>(msg.wParam);
}

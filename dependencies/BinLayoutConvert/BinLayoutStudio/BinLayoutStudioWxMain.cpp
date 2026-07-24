#include <wx/wx.h>
#include <wx/button.h>
#include <wx/checkbox.h>
#include <wx/choice.h>
#include <wx/cmdline.h>
#include <wx/datetime.h>
#include <wx/dnd.h>
#include <wx/ffile.h>
#include <wx/fileconf.h>
#include <wx/filedlg.h>
#include <wx/filehistory.h>
#include <wx/filepicker.h>
#include <wx/filename.h>
#include <wx/gauge.h>
#include <wx/listctrl.h>
#include <wx/msw/init.h>
#include <wx/notebook.h>
#include <wx/sizer.h>
#include <wx/splitter.h>
#include <wx/srchctrl.h>
#include <wx/stdpaths.h>
#include <wx/stattext.h>
#include <wx/textctrl.h>
#include <wx/treectrl.h>

#include <cstdio>
#include <cstdarg>
#include <cstring>
#include <vector>
#include <utility>
#include <memory>
#include <string>

#include "BinLayoutStudioBatchConvert.h"
#include "BinLayoutStudioBinCodec.h"
#include "BinLayoutStudioXmlWriter.h"

#include "CEGUIDefaultLogger.h"

class BinLayoutStudioFrame;

namespace
{
	enum
	{
		ID_FILE_RELOAD = wxID_HIGHEST + 1,
		ID_CONVERT_EXPORT_XML,
		ID_CONVERT_EXPORT_BIN,
		ID_VIEW_TOGGLE_LOG,
		ID_VIEW_CLEAR_LOG,
		ID_VIEW_SAVE_LOG,
		ID_VIEW_RESET_LAYOUT,
		ID_TREE_EXPAND_ALL,
		ID_TREE_COLLAPSE_ALL,
		ID_BATCH_SWITCH_PAGE,
		ID_BATCH_REFRESH_PREVIEW,
		ID_BATCH_RUN,
	};

	class NodeItemData : public wxTreeItemData
	{
	public:
		explicit NodeItemData(const CEGUI::BinLayout::XMLFileData::NodeData* node) : m_node(node) {}

		const CEGUI::BinLayout::XMLFileData::NodeData* getNode() const { return m_node; }

	private:
		const CEGUI::BinLayout::XMLFileData::NodeData* m_node;
	};

	static void ensureConsole()
	{
		static bool s_hasConsole = false;
		if (s_hasConsole)
		{
			return;
		}

		if (AllocConsole())
		{
			freopen("CONOUT$", "w", stdout);
			freopen("CONOUT$", "w", stderr);
			s_hasConsole = true;
		}
	}

	static std::string toLocalPathAcp(const wxString& path)
	{
		const wxCharBuffer buf = path.mb_str(wxConvLocal);
		if (!buf.data())
		{
			return std::string();
		}
		return std::string(buf.data());
	}

	static wxString fromLocalPathAcp(const std::string& path)
	{
		return wxString(path.c_str(), wxConvLocal);
	}

	static wxString fromUtf8Text(const std::string& text)
	{
		return wxString(text.c_str(), wxConvUTF8);
	}

	static wxString displayPath(const std::string& path)
	{
		return path.empty() || path == "-" ? wxString(L"-") : fromLocalPathAcp(path);
	}

	static wxString shortenText(const wxString& text, size_t maxChars)
	{
		if (text.length() <= maxChars || maxChars < 8)
		{
			return text;
		}

		const size_t head = maxChars / 2 - 2;
		const size_t tail = maxChars - head - 3;
		return text.Left(head) + wxString(L"...") + text.Right(tail);
	}

	static wxFont makeBoldFont(const wxWindow* window, int delta)
	{
		wxFont font = window->GetFont();
		font.SetWeight(wxFONTWEIGHT_BOLD);
		font.SetPointSize(wxMax(8, font.GetPointSize() + delta));
		return font;
	}

	static void showAbout(wxWindow* parent)
	{
		const wxString msg =
			wxString(L"BinLayoutStudio (Bin <-> XML)\n\n")
			+ wxString(L"\u73B0\u4EE3\u5316\u5E03\u5C40\u5206\u6790\u4E0E\u76EE\u5F55\u6279\u91CF\u8F6C\u6362\u5DE5\u4F5C\u53F0\n")
			+ wxString(L"\u7EF4\u62A4\uFF1AMT3 \u5DE5\u5177\u94FE\u6539\u9020\n");

		wxMessageBox(msg, wxString(L"\u5173\u4E8E BinLayoutStudio"), wxOK | wxICON_INFORMATION, parent);
	}

	class LayoutFileDropTarget : public wxFileDropTarget
	{
	public:
		explicit LayoutFileDropTarget(BinLayoutStudioFrame* frame) : m_frame(frame) {}
		virtual bool OnDropFiles(wxCoord, wxCoord, const wxArrayString& filenames);

	private:
		BinLayoutStudioFrame* m_frame;
	};
}

class BinLayoutStudioFrame : public wxFrame
{
public:
	BinLayoutStudioFrame()
		: wxFrame(NULL, wxID_ANY, wxString(L"BinLayoutStudio (Bin <-> XML)"), wxDefaultPosition, wxSize(1420, 940))
		, m_rootSplitter(NULL)
		, m_mainNotebook(NULL)
		, m_contentSplitter(NULL)
		, m_pathBar(NULL)
		, m_tree(NULL)
		, m_rightPanel(NULL)
		, m_propSearch(NULL)
		, m_list(NULL)
		, m_log(NULL)
		, m_openBtn(NULL)
		, m_reloadBtn(NULL)
		, m_exportXmlBtn(NULL)
		, m_exportBinBtn(NULL)
		, m_batchPageBtn(NULL)
		, m_treeExpandBtn(NULL)
		, m_treeCollapseBtn(NULL)
		, m_batchSourcePicker(NULL)
		, m_batchOutputPicker(NULL)
		, m_batchModeChoice(NULL)
		, m_batchLayoutChoice(NULL)
		, m_batchNamingChoice(NULL)
		, m_batchPatternText(NULL)
		, m_batchRecursiveCheck(NULL)
		, m_batchOverwriteCheck(NULL)
		, m_batchAutoPreviewCheck(NULL)
		, m_batchRefreshBtn(NULL)
		, m_batchRunBtn(NULL)
		, m_batchList(NULL)
		, m_batchGauge(NULL)
		, m_batchProgressText(NULL)
		, m_fileCardValue(NULL)
		, m_formatCardValue(NULL)
		, m_statsCardValue(NULL)
		, m_hintCardValue(NULL)
		, m_batchFilesCardValue(NULL)
		, m_batchTasksCardValue(NULL)
		, m_batchFormatsCardValue(NULL)
		, m_batchWarningsCardValue(NULL)
		, m_recentMenu(NULL)
		, m_root(NULL)
		, m_openIsBin(false)
		, m_showLog(true)
		, m_lastRootSash(700)
		, m_lastContentSash(420)
		, m_batchPreviewRefreshPending(false)
		, m_batchRunning(false)
	{
		SetBackgroundColour(wxColour(242, 245, 250));
		createMenu();
		createUi();
		CreateStatusBar(3);
		{
			int widths[3] = { 260, 220, -1 };
			GetStatusBar()->SetStatusWidths(3, widths);
		}
		SetDropTarget(new LayoutFileDropTarget(this));
		updateInspectorCards();
		updateBatchSummaryCards();
		updateUiEnabled();
		updatePathBar();
		updateStatusBar();
	}

	bool openLayoutFromUiPath(const wxString& uiPath)
	{
		if (uiPath.empty())
		{
			return false;
		}

		if (!wxFileExists(uiPath))
		{
			wxMessageBox(wxString(L"\u6587\u4EF6\u4E0D\u5B58\u5728\u6216\u5DF2\u88AB\u79FB\u52A8\uFF1A\n") + uiPath, wxString(L"BinLayoutStudio"), wxOK | wxICON_WARNING, this);
			return false;
		}

		const std::string path = toLocalPathAcp(uiPath);
		if (path.empty())
		{
			wxMessageBox(
				wxString(L"\u8DEF\u5F84\u5305\u542B\u5F53\u524D\u7CFB\u7EDF\u4EE3\u7801\u9875\u65E0\u6CD5\u8868\u793A\u7684\u5B57\u7B26\u3002\n")
				+ wxString(L"\u8BF7\u5C06\u6587\u4EF6\u653E\u5230\u7EAF\u82F1\u6587\u8DEF\u5F84\u4E0B\u518D\u6253\u5F00\uFF08\u4F8B\u5982 e:\\\\MT3\\\\docs\\\\research\\\\ \uFF09\u3002"),
				wxString(L"BinLayoutStudio"),
				wxOK | wxICON_WARNING,
				this);
			return false;
		}

		loadFile(path);
		if (m_mainNotebook)
		{
			m_mainNotebook->SetSelection(0);
		}
		if (m_fileHistory)
		{
			m_fileHistory->AddFileToHistory(uiPath);
			saveRecentFiles();
		}
		return true;
	}

	~BinLayoutStudioFrame()
	{
		saveRecentFiles();
		freeCurrentDoc();
	}

private:
	wxSplitterWindow* m_rootSplitter;
	wxNotebook* m_mainNotebook;
	wxSplitterWindow* m_contentSplitter;
	wxStaticText* m_pathBar;
	wxTreeCtrl* m_tree;
	wxPanel* m_rightPanel;
	wxSearchCtrl* m_propSearch;
	wxListCtrl* m_list;
	wxTextCtrl* m_log;
	wxButton* m_openBtn;
	wxButton* m_reloadBtn;
	wxButton* m_exportXmlBtn;
	wxButton* m_exportBinBtn;
	wxButton* m_batchPageBtn;
	wxButton* m_treeExpandBtn;
	wxButton* m_treeCollapseBtn;
	wxDirPickerCtrl* m_batchSourcePicker;
	wxDirPickerCtrl* m_batchOutputPicker;
	wxChoice* m_batchModeChoice;
	wxChoice* m_batchLayoutChoice;
	wxChoice* m_batchNamingChoice;
	wxTextCtrl* m_batchPatternText;
	wxCheckBox* m_batchRecursiveCheck;
	wxCheckBox* m_batchOverwriteCheck;
	wxCheckBox* m_batchAutoPreviewCheck;
	wxButton* m_batchRefreshBtn;
	wxButton* m_batchRunBtn;
	wxListCtrl* m_batchList;
	wxGauge* m_batchGauge;
	wxStaticText* m_batchProgressText;
	wxStaticText* m_fileCardValue;
	wxStaticText* m_formatCardValue;
	wxStaticText* m_statsCardValue;
	wxStaticText* m_hintCardValue;
	wxStaticText* m_batchFilesCardValue;
	wxStaticText* m_batchTasksCardValue;
	wxStaticText* m_batchFormatsCardValue;
	wxStaticText* m_batchWarningsCardValue;
	wxMenu* m_recentMenu;

	std::unique_ptr<wxFileConfig> m_config;
	std::unique_ptr<wxFileHistory> m_fileHistory;

	std::vector<std::pair<wxString, wxString>> m_currentProps;

	CEGUI::BinLayout::XMLFileData::NodeData* m_root;
	std::string m_openPath;
	bool m_openIsBin;
	wxString m_lastFileHint;

	bool m_showLog;
	int m_lastRootSash;     // height of top pane
	int m_lastContentSash;  // width of left pane
	bool m_batchPreviewRefreshPending;
	bool m_batchRunning;
	BinLayoutStudio::Batch::PreviewSummary m_batchPreviewSummary;
	std::vector<BinLayoutStudio::Batch::PreviewItem> m_batchPreviewItems;

	wxPanel* createInfoCard(
		wxWindow* parent,
		const wxString& title,
		const wxColour& background,
		wxStaticText** outValue,
		const wxColour& valueColour)
	{
		wxPanel* card = new wxPanel(parent, wxID_ANY);
		card->SetBackgroundColour(background);
		card->SetMinSize(wxSize(0, 82));

		wxBoxSizer* sizer = new wxBoxSizer(wxVERTICAL);
		wxStaticText* titleText = new wxStaticText(card, wxID_ANY, title);
		titleText->SetForegroundColour(wxColour(92, 102, 120));
		sizer->Add(titleText, 0, wxLEFT | wxRIGHT | wxTOP, 12);

		*outValue = new wxStaticText(card, wxID_ANY, wxString(L"-"));
		(*outValue)->SetFont(makeBoldFont(card, 2));
		(*outValue)->SetForegroundColour(valueColour);
		sizer->Add(*outValue, 0, wxLEFT | wxRIGHT | wxTOP, 12);

		card->SetSizer(sizer);
		return card;
	}

	void styleActionButton(wxButton* button, bool primary)
	{
		if (!button)
		{
			return;
		}

		button->SetMinSize(wxSize(primary ? 110 : 102, 32));
		button->SetFont(makeBoldFont(button, 0));
		if (primary)
		{
			button->SetBackgroundColour(wxColour(50, 110, 245));
			button->SetForegroundColour(*wxWHITE);
		}
		else
		{
			button->SetBackgroundColour(wxColour(249, 250, 252));
			button->SetForegroundColour(wxColour(43, 54, 70));
		}
	}

	void resizePropertyColumns()
	{
		if (!m_list)
		{
			return;
		}

		const int width = m_list->GetClientSize().GetWidth();
		const int col0 = 220;
		const int col1 = width > col0 + 40 ? width - col0 - 10 : 200;
		m_list->SetColumnWidth(0, col0);
		m_list->SetColumnWidth(1, col1);
	}

	void resizeBatchColumns()
	{
		if (!m_batchList)
		{
			return;
		}

		const int width = m_batchList->GetClientSize().GetWidth();
		const int fixed = 88 + 64 + 110 + 300;
		const int remain = width - fixed - 40;
		const int outWidth = remain > 540 ? remain / 2 + 90 : 380;
		const int noteWidth = remain > 540 ? remain / 2 - 80 : 220;

		m_batchList->SetColumnWidth(0, 88);
		m_batchList->SetColumnWidth(1, 64);
		m_batchList->SetColumnWidth(2, 110);
		m_batchList->SetColumnWidth(3, 300);
		m_batchList->SetColumnWidth(4, wxMax(260, outWidth));
		m_batchList->SetColumnWidth(5, wxMax(220, noteWidth));
	}

	void createMenu()
	{
		wxMenu* fileMenu = new wxMenu();
		fileMenu->Append(wxID_OPEN, wxString(L"\u6253\u5F00(&O)\tCtrl+O"));
		fileMenu->Append(ID_FILE_RELOAD, wxString(L"\u91CD\u65B0\u52A0\u8F7D(&R)\tF5"));
		fileMenu->AppendSeparator();
		m_recentMenu = new wxMenu();
		fileMenu->AppendSubMenu(m_recentMenu, wxString(L"\u6700\u8FD1\u6253\u5F00(&N)"));
		fileMenu->AppendSeparator();
		fileMenu->Append(wxID_EXIT, wxString(L"\u9000\u51FA(&X)\tAlt+F4"));

		wxMenu* convertMenu = new wxMenu();
		convertMenu->Append(ID_CONVERT_EXPORT_XML, wxString(L"\u5BFC\u51FA XML\tCtrl+E"));
		convertMenu->Append(ID_CONVERT_EXPORT_BIN, wxString(L"\u5BFC\u51FA BIN\tCtrl+B"));
		convertMenu->AppendSeparator();
		convertMenu->Append(ID_BATCH_SWITCH_PAGE, wxString(L"\u6253\u5F00\u76EE\u5F55\u8F6C\u6362\u5DE5\u4F5C\u533A\tF7"));
		convertMenu->Append(ID_BATCH_REFRESH_PREVIEW, wxString(L"\u5237\u65B0\u76EE\u5F55\u9884\u89C8\tCtrl+Shift+P"));
		convertMenu->Append(ID_BATCH_RUN, wxString(L"\u5F00\u59CB\u76EE\u5F55\u8F6C\u6362\tCtrl+Shift+B"));

		wxMenu* viewMenu = new wxMenu();
		viewMenu->AppendCheckItem(ID_VIEW_TOGGLE_LOG, wxString(L"\u663E\u793A\u65E5\u5FD7(&L)\tCtrl+L"));
		viewMenu->Check(ID_VIEW_TOGGLE_LOG, true);
		viewMenu->Append(ID_VIEW_CLEAR_LOG, wxString(L"\u6E05\u7A7A\u65E5\u5FD7"));
		viewMenu->Append(ID_VIEW_SAVE_LOG, wxString(L"\u5BFC\u51FA\u65E5\u5FD7...\tCtrl+Shift+S"));
		viewMenu->AppendSeparator();
		viewMenu->Append(ID_TREE_EXPAND_ALL, wxString(L"\u5C55\u5F00\u6240\u6709\u8282\u70B9"));
		viewMenu->Append(ID_TREE_COLLAPSE_ALL, wxString(L"\u6298\u53E0\u6240\u6709\u8282\u70B9"));
		viewMenu->Append(ID_VIEW_RESET_LAYOUT, wxString(L"\u91CD\u7F6E\u5E03\u5C40"));

		wxMenu* helpMenu = new wxMenu();
		helpMenu->Append(wxID_ABOUT, wxString(L"\u5173\u4E8E(&A)"));

		wxMenuBar* bar = new wxMenuBar();
		bar->Append(fileMenu, wxString(L"\u6587\u4EF6(&F)"));
		bar->Append(convertMenu, wxString(L"\u8F6C\u6362(&C)"));
		bar->Append(viewMenu, wxString(L"\u89C6\u56FE(&V)"));
		bar->Append(helpMenu, wxString(L"\u5E2E\u52A9(&H)"));

		SetMenuBar(bar);

		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onOpen, this, wxID_OPEN);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onReload, this, ID_FILE_RELOAD);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onExit, this, wxID_EXIT);

		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onExportXml, this, ID_CONVERT_EXPORT_XML);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onExportBin, this, ID_CONVERT_EXPORT_BIN);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onGoBatchPage, this, ID_BATCH_SWITCH_PAGE);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onBatchRefresh, this, ID_BATCH_REFRESH_PREVIEW);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onBatchRun, this, ID_BATCH_RUN);

		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onToggleLog, this, ID_VIEW_TOGGLE_LOG);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onClearLog, this, ID_VIEW_CLEAR_LOG);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onSaveLog, this, ID_VIEW_SAVE_LOG);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onExpandAllNodes, this, ID_TREE_EXPAND_ALL);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onCollapseAllNodes, this, ID_TREE_COLLAPSE_ALL);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onResetLayout, this, ID_VIEW_RESET_LAYOUT);

		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onAbout, this, wxID_ABOUT);
		Bind(wxEVT_MENU, &BinLayoutStudioFrame::onOpenRecent, this, wxID_FILE1, wxID_FILE9);

		initRecentFiles();
	}

	void createUi()
	{
		wxPanel* panel = new wxPanel(this, wxID_ANY);
		wxBoxSizer* rootSizer = new wxBoxSizer(wxVERTICAL);

		wxPanel* heroPanel = new wxPanel(panel, wxID_ANY);
		heroPanel->SetBackgroundColour(wxColour(21, 46, 96));
		wxBoxSizer* heroSizer = new wxBoxSizer(wxHORIZONTAL);

		wxBoxSizer* heroTextSizer = new wxBoxSizer(wxVERTICAL);
		wxStaticText* title = new wxStaticText(heroPanel, wxID_ANY, wxString(L"BinLayoutStudio"));
		title->SetFont(makeBoldFont(heroPanel, 6));
		title->SetForegroundColour(*wxWHITE);
		heroTextSizer->Add(title, 0, wxBOTTOM, 4);

		wxStaticText* subtitle = new wxStaticText(
			heroPanel,
			wxID_ANY,
			wxString(L"\u5355\u6587\u4EF6\u68C0\u89C6 + \u76EE\u5F55\u6279\u91CF\u8F6C\u6362\u5DE5\u4F5C\u53F0\uff0c\u9762\u5411 .layout XML/BIN \u53CC\u5411\u5206\u6790\u4E0E\u6279\u91CF\u5904\u7406"));
		subtitle->SetForegroundColour(wxColour(206, 220, 245));
		heroTextSizer->Add(subtitle, 0);

		heroSizer->Add(heroTextSizer, 1, wxEXPAND | wxALL, 18);

		wxBoxSizer* heroButtonSizer = new wxBoxSizer(wxHORIZONTAL);
		m_openBtn = new wxButton(heroPanel, wxID_ANY, wxString(L"\u6253\u5F00\u6587\u4EF6"));
		m_reloadBtn = new wxButton(heroPanel, wxID_ANY, wxString(L"\u91CD\u65B0\u52A0\u8F7D"));
		m_exportXmlBtn = new wxButton(heroPanel, wxID_ANY, wxString(L"\u5BFC\u51FA XML"));
		m_exportBinBtn = new wxButton(heroPanel, wxID_ANY, wxString(L"\u5BFC\u51FA BIN"));
		m_batchPageBtn = new wxButton(heroPanel, wxID_ANY, wxString(L"\u76EE\u5F55\u5DE5\u4F5C\u53F0"));

		styleActionButton(m_openBtn, true);
		styleActionButton(m_reloadBtn, false);
		styleActionButton(m_exportXmlBtn, false);
		styleActionButton(m_exportBinBtn, false);
		styleActionButton(m_batchPageBtn, false);

		heroButtonSizer->Add(m_openBtn, 0, wxRIGHT, 8);
		heroButtonSizer->Add(m_reloadBtn, 0, wxRIGHT, 8);
		heroButtonSizer->Add(m_exportXmlBtn, 0, wxRIGHT, 8);
		heroButtonSizer->Add(m_exportBinBtn, 0, wxRIGHT, 8);
		heroButtonSizer->Add(m_batchPageBtn, 0);
		heroSizer->Add(heroButtonSizer, 0, wxALIGN_CENTER_VERTICAL | wxALL, 18);

		heroPanel->SetSizer(heroSizer);
		rootSizer->Add(heroPanel, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 10);

		m_rootSplitter = new wxSplitterWindow(panel, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxSP_LIVE_UPDATE);
		m_rootSplitter->SetSashGravity(1.0);
		m_rootSplitter->SetMinimumPaneSize(120);

		m_mainNotebook = new wxNotebook(m_rootSplitter, wxID_ANY);

		wxPanel* inspectorPage = new wxPanel(m_mainNotebook, wxID_ANY);
		inspectorPage->SetBackgroundColour(wxColour(242, 245, 250));
		wxBoxSizer* inspectorSizer = new wxBoxSizer(wxVERTICAL);

		wxBoxSizer* inspectorCards = new wxBoxSizer(wxHORIZONTAL);
		inspectorCards->Add(createInfoCard(inspectorPage, wxString(L"\u5F53\u524D\u6587\u4EF6"), wxColour(255, 255, 255), &m_fileCardValue, wxColour(31, 51, 84)), 1, wxRIGHT, 10);
		inspectorCards->Add(createInfoCard(inspectorPage, wxString(L"\u8F93\u5165\u683C\u5F0F"), wxColour(255, 255, 255), &m_formatCardValue, wxColour(29, 113, 184)), 1, wxRIGHT, 10);
		inspectorCards->Add(createInfoCard(inspectorPage, wxString(L"\u8282\u70B9\u6982\u89C8"), wxColour(255, 255, 255), &m_statsCardValue, wxColour(14, 128, 85)), 1, wxRIGHT, 10);
		inspectorCards->Add(createInfoCard(inspectorPage, wxString(L"\u64CD\u4F5C\u63D0\u793A"), wxColour(255, 255, 255), &m_hintCardValue, wxColour(183, 103, 15)), 1);
		inspectorSizer->Add(inspectorCards, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 12);

		wxPanel* filePanel = new wxPanel(inspectorPage, wxID_ANY);
		filePanel->SetBackgroundColour(wxColour(255, 255, 255));
		wxBoxSizer* fileSizer = new wxBoxSizer(wxVERTICAL);
		wxStaticText* fileTitle = new wxStaticText(filePanel, wxID_ANY, wxString(L"\u5F53\u524D\u5E03\u5C40"));
		fileTitle->SetFont(makeBoldFont(filePanel, 0));
		fileSizer->Add(fileTitle, 0, wxLEFT | wxRIGHT | wxTOP, 12);
		m_pathBar = new wxStaticText(filePanel, wxID_ANY, wxString(L"\u672A\u6253\u5F00\u6587\u4EF6"));
		m_pathBar->SetForegroundColour(wxColour(73, 84, 102));
		fileSizer->Add(m_pathBar, 0, wxEXPAND | wxALL, 12);
		filePanel->SetSizer(fileSizer);
		inspectorSizer->Add(filePanel, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 12);

		m_contentSplitter = new wxSplitterWindow(inspectorPage, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxSP_LIVE_UPDATE);
		m_contentSplitter->SetSashGravity(0.0);
		m_contentSplitter->SetMinimumPaneSize(220);

		wxPanel* treePanel = new wxPanel(m_contentSplitter, wxID_ANY);
		treePanel->SetBackgroundColour(wxColour(255, 255, 255));
		wxBoxSizer* treeSizer = new wxBoxSizer(wxVERTICAL);
		wxBoxSizer* treeHeader = new wxBoxSizer(wxHORIZONTAL);
		wxStaticText* treeTitle = new wxStaticText(treePanel, wxID_ANY, wxString(L"\u7ED3\u6784\u6811"));
		treeTitle->SetFont(makeBoldFont(treePanel, 1));
		treeHeader->Add(treeTitle, 1, wxALIGN_CENTER_VERTICAL);
		m_treeExpandBtn = new wxButton(treePanel, wxID_ANY, wxString(L"\u5C55\u5F00"));
		m_treeCollapseBtn = new wxButton(treePanel, wxID_ANY, wxString(L"\u6298\u53E0"));
		styleActionButton(m_treeExpandBtn, false);
		styleActionButton(m_treeCollapseBtn, false);
		treeHeader->Add(m_treeExpandBtn, 0, wxLEFT, 8);
		treeHeader->Add(m_treeCollapseBtn, 0, wxLEFT, 8);
		treeSizer->Add(treeHeader, 0, wxEXPAND | wxALL, 12);

		m_tree = new wxTreeCtrl(
			treePanel,
			wxID_ANY,
			wxDefaultPosition,
			wxDefaultSize,
			wxTR_HAS_BUTTONS | wxTR_LINES_AT_ROOT | wxTR_SINGLE | wxTR_HIDE_ROOT);
		treeSizer->Add(m_tree, 1, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 12);
		treePanel->SetSizer(treeSizer);

		m_rightPanel = new wxPanel(m_contentSplitter, wxID_ANY);
		m_rightPanel->SetBackgroundColour(wxColour(255, 255, 255));
		{
			wxBoxSizer* rightSizer = new wxBoxSizer(wxVERTICAL);
			wxStaticText* propsTitle = new wxStaticText(m_rightPanel, wxID_ANY, wxString(L"\u5C5E\u6027\u4E0E\u8282\u70B9\u7EC6\u8282"));
			propsTitle->SetFont(makeBoldFont(m_rightPanel, 1));
			rightSizer->Add(propsTitle, 0, wxLEFT | wxRIGHT | wxTOP, 12);

			wxStaticText* propsDesc = new wxStaticText(m_rightPanel, wxID_ANY, wxString(L"\u652F\u6301\u5BF9 XML \u4E0E BIN \u5E03\u5C40\u6811\u8FDB\u884C\u67E5\u770B\u3001\u7B5B\u9009\u548C\u5BFC\u51FA\u3002"));
			propsDesc->SetForegroundColour(wxColour(100, 111, 129));
			rightSizer->Add(propsDesc, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 6);

			wxBoxSizer* searchSizer = new wxBoxSizer(wxHORIZONTAL);
			searchSizer->Add(new wxStaticText(m_rightPanel, wxID_ANY, wxString(L"\u5C5E\u6027\u7B5B\u9009")), 0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 8);

			m_propSearch = new wxSearchCtrl(m_rightPanel, wxID_ANY, wxEmptyString);
			m_propSearch->ShowSearchButton(true);
			m_propSearch->ShowCancelButton(true);
			searchSizer->Add(m_propSearch, 1, wxEXPAND);
			rightSizer->Add(searchSizer, 0, wxEXPAND | wxALL, 12);

			m_list = new wxListCtrl(m_rightPanel, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_SINGLE_SEL | wxLC_HRULES | wxLC_VRULES);
			m_list->InsertColumn(0, wxString(L"\u5C5E\u6027"), wxLIST_FORMAT_LEFT, 220);
			m_list->InsertColumn(1, wxString(L"\u503C"), wxLIST_FORMAT_LEFT, 900);
			rightSizer->Add(m_list, 1, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 12);

			m_rightPanel->SetSizer(rightSizer);
		}

		m_contentSplitter->SplitVertically(treePanel, m_rightPanel, m_lastContentSash);
		inspectorSizer->Add(m_contentSplitter, 1, wxEXPAND | wxALL, 12);
		inspectorPage->SetSizer(inspectorSizer);
		m_mainNotebook->AddPage(inspectorPage, wxString(L"\u5355\u6587\u4EF6\u5DE5\u4F5C\u53F0"), true);

		wxPanel* batchPage = new wxPanel(m_mainNotebook, wxID_ANY);
		batchPage->SetBackgroundColour(wxColour(242, 245, 250));
		wxBoxSizer* batchSizer = new wxBoxSizer(wxVERTICAL);

		wxBoxSizer* batchCards = new wxBoxSizer(wxHORIZONTAL);
		batchCards->Add(createInfoCard(batchPage, wxString(L"\u626B\u63CF\u6587\u4EF6"), wxColour(255, 255, 255), &m_batchFilesCardValue, wxColour(31, 51, 84)), 1, wxRIGHT, 10);
		batchCards->Add(createInfoCard(batchPage, wxString(L"\u5F85\u6267\u884C\u4EFB\u52A1"), wxColour(255, 255, 255), &m_batchTasksCardValue, wxColour(29, 113, 184)), 1, wxRIGHT, 10);
		batchCards->Add(createInfoCard(batchPage, wxString(L"\u683C\u5F0F\u5206\u5E03"), wxColour(255, 255, 255), &m_batchFormatsCardValue, wxColour(14, 128, 85)), 1, wxRIGHT, 10);
		batchCards->Add(createInfoCard(batchPage, wxString(L"\u51B2\u7A81/\u63D0\u793A"), wxColour(255, 255, 255), &m_batchWarningsCardValue, wxColour(183, 103, 15)), 1);
		batchSizer->Add(batchCards, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 12);

		wxPanel* configPanel = new wxPanel(batchPage, wxID_ANY);
		configPanel->SetBackgroundColour(wxColour(255, 255, 255));
		wxBoxSizer* configSizer = new wxBoxSizer(wxVERTICAL);
		wxStaticText* configTitle = new wxStaticText(configPanel, wxID_ANY, wxString(L"\u76EE\u5F55\u8F6C\u6362\u89C4\u5219"));
		configTitle->SetFont(makeBoldFont(configPanel, 1));
		configSizer->Add(configTitle, 0, wxLEFT | wxRIGHT | wxTOP, 12);

		wxStaticText* configDesc = new wxStaticText(
			configPanel,
			wxID_ANY,
			wxString(L"\u652F\u6301\u591A\u5C42\u7EA7\u76EE\u5F55\u626B\u63CF\u3001\u683C\u5F0F\u81EA\u52A8\u8BC6\u522B\u3001\u51B2\u7A81\u63D0\u793A\u3001\u955C\u50CF/\u6253\u5E73\u8F93\u51FA\u4E0E\u5458\u5DE5\u65E5\u5FD7\u56DE\u6EAF\u3002"));
		configDesc->SetForegroundColour(wxColour(100, 111, 129));
		configSizer->Add(configDesc, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 6);

		wxFlexGridSizer* grid = new wxFlexGridSizer(0, 4, 10, 12);
		grid->AddGrowableCol(1, 1);
		grid->AddGrowableCol(3, 1);

		grid->Add(new wxStaticText(configPanel, wxID_ANY, wxString(L"\u6E90\u76EE\u5F55")), 0, wxALIGN_CENTER_VERTICAL);
		m_batchSourcePicker = new wxDirPickerCtrl(configPanel, wxID_ANY, wxEmptyString, wxString(L"\u9009\u62E9\u6E90\u76EE\u5F55"));
		grid->Add(m_batchSourcePicker, 1, wxEXPAND);

		grid->Add(new wxStaticText(configPanel, wxID_ANY, wxString(L"\u8F93\u51FA\u76EE\u5F55")), 0, wxALIGN_CENTER_VERTICAL);
		m_batchOutputPicker = new wxDirPickerCtrl(configPanel, wxID_ANY, wxEmptyString, wxString(L"\u9009\u62E9\u8F93\u51FA\u76EE\u5F55"));
		grid->Add(m_batchOutputPicker, 1, wxEXPAND);

		grid->Add(new wxStaticText(configPanel, wxID_ANY, wxString(L"\u8F6C\u6362\u6A21\u5F0F")), 0, wxALIGN_CENTER_VERTICAL);
		m_batchModeChoice = new wxChoice(configPanel, wxID_ANY);
		m_batchModeChoice->Append(wxString(L"\u81EA\u52A8\u8BC6\u522B(XML->BIN / BIN->XML)"));
		m_batchModeChoice->Append(wxString(L"\u53EA\u505A XML -> BIN"));
		m_batchModeChoice->Append(wxString(L"\u53EA\u505A BIN -> XML"));
		m_batchModeChoice->SetSelection(0);
		grid->Add(m_batchModeChoice, 1, wxEXPAND);

		grid->Add(new wxStaticText(configPanel, wxID_ANY, wxString(L"\u8F93\u51FA\u7ED3\u6784")), 0, wxALIGN_CENTER_VERTICAL);
		m_batchLayoutChoice = new wxChoice(configPanel, wxID_ANY);
		m_batchLayoutChoice->Append(wxString(L"\u955C\u50CF\u4FDD\u6301\u539F\u76EE\u5F55\u5C42\u7EA7"));
		m_batchLayoutChoice->Append(wxString(L"\u6253\u5E73\u8F93\u51FA\u5230\u5355\u76EE\u5F55"));
		m_batchLayoutChoice->SetSelection(0);
		grid->Add(m_batchLayoutChoice, 1, wxEXPAND);

		grid->Add(new wxStaticText(configPanel, wxID_ANY, wxString(L"\u547D\u540D\u89C4\u5219")), 0, wxALIGN_CENTER_VERTICAL);
		m_batchNamingChoice = new wxChoice(configPanel, wxID_ANY);
		m_batchNamingChoice->Append(wxString(L"\u4FDD\u6301\u539F\u6587\u4EF6\u540D"));
		m_batchNamingChoice->Append(wxString(L"\u8FFD\u52A0\u76EE\u6807\u540E\u7F00(_bin/_xml)"));
		m_batchNamingChoice->SetSelection(0);
		grid->Add(m_batchNamingChoice, 1, wxEXPAND);

		grid->Add(new wxStaticText(configPanel, wxID_ANY, wxString(L"\u5305\u542B\u89C4\u5219")), 0, wxALIGN_CENTER_VERTICAL);
		m_batchPatternText = new wxTextCtrl(configPanel, wxID_ANY, wxString(L"*.layout"));
		grid->Add(m_batchPatternText, 1, wxEXPAND);

		configSizer->Add(grid, 0, wxEXPAND | wxALL, 12);

		wxBoxSizer* batchOptionSizer = new wxBoxSizer(wxHORIZONTAL);
		m_batchRecursiveCheck = new wxCheckBox(configPanel, wxID_ANY, wxString(L"\u9012\u5F52\u626B\u63CF\u5B50\u76EE\u5F55"));
		m_batchRecursiveCheck->SetValue(true);
		m_batchOverwriteCheck = new wxCheckBox(configPanel, wxID_ANY, wxString(L"\u5141\u8BB8\u8986\u76D6\u5DF2\u6709\u8F93\u51FA"));
		m_batchOverwriteCheck->SetValue(false);
		m_batchAutoPreviewCheck = new wxCheckBox(configPanel, wxID_ANY, wxString(L"\u89C4\u5219\u6539\u53D8\u65F6\u81EA\u52A8\u5237\u65B0\u9884\u89C8"));
		m_batchAutoPreviewCheck->SetValue(true);
		batchOptionSizer->Add(m_batchRecursiveCheck, 0, wxRIGHT | wxBOTTOM, 12);
		batchOptionSizer->Add(m_batchOverwriteCheck, 0, wxRIGHT | wxBOTTOM, 12);
		batchOptionSizer->Add(m_batchAutoPreviewCheck, 0, wxRIGHT | wxBOTTOM, 12);
		batchOptionSizer->AddStretchSpacer(1);
		m_batchRefreshBtn = new wxButton(configPanel, wxID_ANY, wxString(L"\u5237\u65B0\u9884\u89C8"));
		m_batchRunBtn = new wxButton(configPanel, wxID_ANY, wxString(L"\u5F00\u59CB\u8F6C\u6362"));
		styleActionButton(m_batchRefreshBtn, false);
		styleActionButton(m_batchRunBtn, true);
		batchOptionSizer->Add(m_batchRefreshBtn, 0, wxRIGHT, 8);
		batchOptionSizer->Add(m_batchRunBtn, 0);
		configSizer->Add(batchOptionSizer, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 12);
		configPanel->SetSizer(configSizer);
		batchSizer->Add(configPanel, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 12);

		wxPanel* previewPanel = new wxPanel(batchPage, wxID_ANY);
		previewPanel->SetBackgroundColour(wxColour(255, 255, 255));
		wxBoxSizer* previewSizer = new wxBoxSizer(wxVERTICAL);
		wxStaticText* previewTitle = new wxStaticText(previewPanel, wxID_ANY, wxString(L"\u8F6C\u6362\u9884\u89C8"));
		previewTitle->SetFont(makeBoldFont(previewPanel, 1));
		previewSizer->Add(previewTitle, 0, wxLEFT | wxRIGHT | wxTOP, 12);

		m_batchList = new wxListCtrl(previewPanel, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_HRULES | wxLC_VRULES);
		m_batchList->InsertColumn(0, wxString(L"\u52A8\u4F5C"));
		m_batchList->InsertColumn(1, wxString(L"\u683C\u5F0F"));
		m_batchList->InsertColumn(2, wxString(L"\u6267\u884C"));
		m_batchList->InsertColumn(3, wxString(L"\u76F8\u5BF9\u8DEF\u5F84"));
		m_batchList->InsertColumn(4, wxString(L"\u8F93\u51FA\u8DEF\u5F84"));
		m_batchList->InsertColumn(5, wxString(L"\u5907\u6CE8"));
		previewSizer->Add(m_batchList, 1, wxEXPAND | wxALL, 12);

		wxBoxSizer* progressSizer = new wxBoxSizer(wxHORIZONTAL);
		m_batchGauge = new wxGauge(previewPanel, wxID_ANY, 100);
		progressSizer->Add(m_batchGauge, 1, wxALIGN_CENTER_VERTICAL | wxRIGHT, 12);
		m_batchProgressText = new wxStaticText(previewPanel, wxID_ANY, wxString(L"\u914D\u7F6E\u89C4\u5219\u540E\u53EF\u5B9E\u65F6\u751F\u6210\u9884\u89C8"));
		m_batchProgressText->SetForegroundColour(wxColour(95, 107, 125));
		progressSizer->Add(m_batchProgressText, 0, wxALIGN_CENTER_VERTICAL);
		previewSizer->Add(progressSizer, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 12);
		previewPanel->SetSizer(previewSizer);
		batchSizer->Add(previewPanel, 1, wxEXPAND | wxALL, 12);

		batchPage->SetSizer(batchSizer);
		m_mainNotebook->AddPage(batchPage, wxString(L"\u76EE\u5F55\u8F6C\u6362\u5DE5\u4F5C\u533A"), false);

		m_log = new wxTextCtrl(m_rootSplitter, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxTE_MULTILINE | wxTE_READONLY);
		m_log->SetBackgroundColour(wxColour(18, 22, 30));
		m_log->SetForegroundColour(wxColour(224, 229, 238));
		m_rootSplitter->SplitHorizontally(m_mainNotebook, m_log, m_lastRootSash);
		rootSizer->Add(m_rootSplitter, 1, wxEXPAND | wxALL, 10);
		panel->SetSizer(rootSizer);

		m_tree->Bind(wxEVT_TREE_SEL_CHANGED, &BinLayoutStudioFrame::onTreeSelChanged, this);
		m_rootSplitter->Bind(wxEVT_SPLITTER_SASH_POS_CHANGED, &BinLayoutStudioFrame::onRootSashChanged, this);
		m_contentSplitter->Bind(wxEVT_SPLITTER_SASH_POS_CHANGED, &BinLayoutStudioFrame::onContentSashChanged, this);
		m_openBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onOpen, this);
		m_reloadBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onReload, this);
		m_exportXmlBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onExportXml, this);
		m_exportBinBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onExportBin, this);
		m_batchPageBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onGoBatchPage, this);
		m_treeExpandBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onExpandAllNodes, this);
		m_treeCollapseBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onCollapseAllNodes, this);
		m_batchRefreshBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onBatchRefresh, this);
		m_batchRunBtn->Bind(wxEVT_BUTTON, &BinLayoutStudioFrame::onBatchRun, this);

		if (m_propSearch)
		{
			m_propSearch->Bind(wxEVT_TEXT, &BinLayoutStudioFrame::onPropSearchChanged, this);
			m_propSearch->Bind(wxEVT_SEARCHCTRL_CANCEL_BTN, &BinLayoutStudioFrame::onPropSearchCancel, this);
		}
		if (m_list)
		{
			m_list->Bind(wxEVT_SIZE, &BinLayoutStudioFrame::onListSize, this);
		}
		if (m_batchList)
		{
			m_batchList->Bind(wxEVT_SIZE, &BinLayoutStudioFrame::onBatchListSize, this);
		}
		if (m_mainNotebook)
		{
			m_mainNotebook->Bind(wxEVT_NOTEBOOK_PAGE_CHANGED, &BinLayoutStudioFrame::onNotebookChanged, this);
		}
		if (m_batchSourcePicker)
		{
			m_batchSourcePicker->Bind(wxEVT_DIRPICKER_CHANGED, &BinLayoutStudioFrame::onBatchDirChanged, this);
		}
		if (m_batchOutputPicker)
		{
			m_batchOutputPicker->Bind(wxEVT_DIRPICKER_CHANGED, &BinLayoutStudioFrame::onBatchDirChanged, this);
		}
		if (m_batchModeChoice)
		{
			m_batchModeChoice->Bind(wxEVT_CHOICE, &BinLayoutStudioFrame::onBatchOptionsChanged, this);
		}
		if (m_batchLayoutChoice)
		{
			m_batchLayoutChoice->Bind(wxEVT_CHOICE, &BinLayoutStudioFrame::onBatchOptionsChanged, this);
		}
		if (m_batchNamingChoice)
		{
			m_batchNamingChoice->Bind(wxEVT_CHOICE, &BinLayoutStudioFrame::onBatchOptionsChanged, this);
		}
		if (m_batchPatternText)
		{
			m_batchPatternText->Bind(wxEVT_TEXT, &BinLayoutStudioFrame::onBatchOptionsChanged, this);
		}
		if (m_batchRecursiveCheck)
		{
			m_batchRecursiveCheck->Bind(wxEVT_CHECKBOX, &BinLayoutStudioFrame::onBatchOptionsChanged, this);
		}
		if (m_batchOverwriteCheck)
		{
			m_batchOverwriteCheck->Bind(wxEVT_CHECKBOX, &BinLayoutStudioFrame::onBatchOptionsChanged, this);
		}
		if (m_batchAutoPreviewCheck)
		{
			m_batchAutoPreviewCheck->Bind(wxEVT_CHECKBOX, &BinLayoutStudioFrame::onBatchOptionsChanged, this);
		}

		resizePropertyColumns();
		resizeBatchColumns();
	}

	void expandTreeRecursive(const wxTreeItemId& item, int depth)
	{
		if (!m_tree || !item.IsOk())
		{
			return;
		}

		m_tree->Expand(item);
		if (depth == 0)
		{
			return;
		}

		wxTreeItemIdValue cookie;
		wxTreeItemId child = m_tree->GetFirstChild(item, cookie);
		while (child.IsOk())
		{
			expandTreeRecursive(child, depth < 0 ? -1 : depth - 1);
			child = m_tree->GetNextChild(item, cookie);
		}
	}

	void collapseTreeRecursive(const wxTreeItemId& item)
	{
		if (!m_tree || !item.IsOk())
		{
			return;
		}

		wxTreeItemIdValue cookie;
		wxTreeItemId child = m_tree->GetFirstChild(item, cookie);
		while (child.IsOk())
		{
			collapseTreeRecursive(child);
			child = m_tree->GetNextChild(item, cookie);
		}
		m_tree->Collapse(item);
	}

	void updateInspectorCards()
	{
		if (!m_fileCardValue || !m_formatCardValue || !m_statsCardValue || !m_hintCardValue)
		{
			return;
		}

		if (m_openPath.empty())
		{
			m_fileCardValue->SetLabel(wxString(L"\u672A\u8F7D\u5165"));
			m_formatCardValue->SetLabel(wxString(L"-"));
			m_statsCardValue->SetLabel(wxString(L"0 \u8282\u70B9 / 0 \u5C5E\u6027"));
			m_hintCardValue->SetLabel(wxString(L"\u62D6\u62FD\u6216\u6253\u5F00 .layout \u5F00\u59CB"));
			return;
		}

		const wxFileName fileName(fromLocalPathAcp(m_openPath));
		m_fileCardValue->SetLabel(shortenText(fileName.GetFullName(), 26));

		if (m_openIsBin)
		{
			int version = 0;
			m_formatCardValue->SetLabel(
				tryReadLbfmVersion(m_openPath.c_str(), version)
				? wxString::Format(wxString(L"BIN v%d"), version)
				: wxString(L"BIN"));
		}
		else
		{
			m_formatCardValue->SetLabel(wxString(L"XML"));
		}

		int nodes = 0;
		int props = 0;
		if (m_root)
		{
			collectStats(m_root, nodes, props);
		}
		m_statsCardValue->SetLabel(wxString::Format(wxString(L"%d \u8282\u70B9 / %d \u5C5E\u6027"), nodes, props));

		const wxString hint = m_lastFileHint.empty()
			? wxString(L"\u53EF\u7EE7\u7EED\u5BFC\u51FA XML/BIN \u6216\u8FDB\u5165\u76EE\u5F55\u6279\u91CF\u5DE5\u4F5C\u533A")
			: m_lastFileHint;
		m_hintCardValue->SetLabel(shortenText(hint, 30));
	}

	void updateBatchSummaryCards()
	{
		if (!m_batchFilesCardValue || !m_batchTasksCardValue || !m_batchFormatsCardValue || !m_batchWarningsCardValue)
		{
			return;
		}

		m_batchFilesCardValue->SetLabel(wxString::Format(wxString(L"%d \u4E2A"), m_batchPreviewSummary.totalFiles));
		m_batchTasksCardValue->SetLabel(wxString::Format(wxString(L"%d \u4E2A"), m_batchPreviewSummary.actionableFiles));
		m_batchFormatsCardValue->SetLabel(
			wxString::Format(
				wxString(L"XML %d / BIN %d / ? %d"),
				m_batchPreviewSummary.xmlFiles,
				m_batchPreviewSummary.binFiles,
				m_batchPreviewSummary.unknownFiles));
		m_batchWarningsCardValue->SetLabel(
			wxString::Format(
				wxString(L"%d \u63D0\u793A / %d \u8DF3\u8FC7"),
				m_batchPreviewSummary.warningFiles,
				m_batchPreviewSummary.skippedFiles));
	}

	void setBatchProgress(int value, int range, const wxString& text)
	{
		if (m_batchGauge)
		{
			m_batchGauge->SetRange(wxMax(1, range));
			m_batchGauge->SetValue(wxMin(wxMax(0, value), wxMax(1, range)));
		}
		if (m_batchProgressText)
		{
			m_batchProgressText->SetLabel(text);
		}
	}

	void fillBatchPreviewList()
	{
		if (!m_batchList)
		{
			return;
		}

		m_batchList->Freeze();
		m_batchList->DeleteAllItems();

		for (size_t i = 0; i < m_batchPreviewItems.size(); ++i)
		{
			const BinLayoutStudio::Batch::PreviewItem& item = m_batchPreviewItems[i];
			const long row = m_batchList->InsertItem(
				static_cast<long>(i),
				wxString(BinLayoutStudio::Batch::PlannedActionToString(item.action), wxConvUTF8));

			m_batchList->SetItem(row, 1, wxString(BinLayoutStudio::Batch::SourceFormatToString(item.sourceFormat), wxConvUTF8));
			m_batchList->SetItem(row, 2, item.actionable ? wxString(L"\u5F85\u6267\u884C") : wxString(L"\u8DF3\u8FC7"));
			m_batchList->SetItem(row, 3, displayPath(item.relativePath.empty() ? item.sourcePath : item.relativePath));
			m_batchList->SetItem(row, 4, displayPath(item.outputPath));
			m_batchList->SetItem(row, 5, item.note.empty() ? wxString(L"-") : fromUtf8Text(item.note));
		}

		m_batchList->Thaw();
		resizeBatchColumns();
	}

	void markBatchPreviewDirty(const wxString& hint)
	{
		m_batchPreviewRefreshPending = true;
		if (!hint.empty())
		{
			setBatchProgress(0, 1, hint);
			updateStatusBar(hint);
		}
	}

	bool collectBatchRules(BinLayoutStudio::Batch::RuleConfig& rules, wxString& outError) const
	{
		outError.clear();

		const wxString sourceUi = m_batchSourcePicker ? m_batchSourcePicker->GetPath() : wxEmptyString;
		const wxString outputUi = m_batchOutputPicker ? m_batchOutputPicker->GetPath() : wxEmptyString;

		if (sourceUi.empty())
		{
			outError = wxString(L"\u8BF7\u5148\u9009\u62E9\u6E90\u76EE\u5F55\u3002");
			return false;
		}
		if (outputUi.empty())
		{
			outError = wxString(L"\u8BF7\u5148\u9009\u62E9\u8F93\u51FA\u76EE\u5F55\u3002");
			return false;
		}

		rules.sourceRoot = toLocalPathAcp(sourceUi);
		rules.outputRoot = toLocalPathAcp(outputUi);
		if (rules.sourceRoot.empty() || rules.outputRoot.empty())
		{
			outError = wxString(L"\u76EE\u5F55\u8DEF\u5F84\u5305\u542B\u5F53\u524D\u7CFB\u7EDF\u4EE3\u7801\u9875\u65E0\u6CD5\u8868\u793A\u7684\u5B57\u7B26\u3002");
			return false;
		}

		rules.includePattern = toLocalPathAcp(m_batchPatternText ? m_batchPatternText->GetValue() : wxString(L"*.layout"));
		if (rules.includePattern.empty())
		{
			rules.includePattern = "*.layout";
		}

		const int modeSel = m_batchModeChoice ? m_batchModeChoice->GetSelection() : 0;
		const int layoutSel = m_batchLayoutChoice ? m_batchLayoutChoice->GetSelection() : 0;
		const int namingSel = m_batchNamingChoice ? m_batchNamingChoice->GetSelection() : 0;

		rules.mode = modeSel == 1
			? BinLayoutStudio::Batch::ConvertMode_XmlToBin
			: (modeSel == 2 ? BinLayoutStudio::Batch::ConvertMode_BinToXml : BinLayoutStudio::Batch::ConvertMode_Auto);
		rules.outputLayout = layoutSel == 1
			? BinLayoutStudio::Batch::OutputLayout_Flat
			: BinLayoutStudio::Batch::OutputLayout_Mirror;
		rules.namingRule = namingSel == 1
			? BinLayoutStudio::Batch::NamingRule_AppendTargetSuffix
			: BinLayoutStudio::Batch::NamingRule_KeepName;
		rules.recursive = m_batchRecursiveCheck ? m_batchRecursiveCheck->GetValue() : true;
		rules.overwriteExisting = m_batchOverwriteCheck ? m_batchOverwriteCheck->GetValue() : false;
		return true;
	}

	bool refreshBatchPreview(bool interactive)
	{
		BinLayoutStudio::Batch::RuleConfig rules;
		wxString uiError;
		if (!collectBatchRules(rules, uiError))
		{
			m_batchPreviewItems.clear();
			m_batchPreviewSummary = BinLayoutStudio::Batch::PreviewSummary();
			fillBatchPreviewList();
			updateBatchSummaryCards();
			m_batchPreviewRefreshPending = true;
			setBatchProgress(0, 1, uiError.empty() ? wxString(L"\u7B49\u5F85\u914D\u7F6E\u6E90/\u8F93\u51FA\u76EE\u5F55") : uiError);
			updateStatusBar(uiError.empty() ? wxString(L"\u7B49\u5F85\u914D\u7F6E\u76EE\u5F55\u89C4\u5219") : uiError);
			if (interactive && !uiError.empty())
			{
				wxMessageBox(uiError, wxString(L"BinLayoutStudio"), wxOK | wxICON_WARNING, this);
			}
			return false;
		}

		std::string err;
		if (!BinLayoutStudio::Batch::BuildPreview(rules, m_batchPreviewItems, m_batchPreviewSummary, err))
		{
			const wxString errorText = fromUtf8Text(err);
			m_batchPreviewItems.clear();
			m_batchPreviewSummary = BinLayoutStudio::Batch::PreviewSummary();
			fillBatchPreviewList();
			updateBatchSummaryCards();
			m_batchPreviewRefreshPending = true;
			setBatchProgress(0, 1, errorText.empty() ? wxString(L"\u76EE\u5F55\u9884\u89C8\u751F\u6210\u5931\u8D25") : errorText);
			logLine(wxString(L"Batch preview failed: ") + (errorText.empty() ? wxString(L"unknown error") : errorText));
			updateStatusBar(errorText.empty() ? wxString(L"\u76EE\u5F55\u9884\u89C8\u5931\u8D25") : errorText);
			if (interactive)
			{
				wxMessageBox(
					errorText.empty() ? wxString(L"\u76EE\u5F55\u9884\u89C8\u751F\u6210\u5931\u8D25\u3002") : errorText,
					wxString(L"BinLayoutStudio"),
					wxOK | wxICON_ERROR,
					this);
			}
			return false;
		}

		m_batchPreviewRefreshPending = false;
		fillBatchPreviewList();
		updateBatchSummaryCards();

		const wxString summary = wxString::Format(
			wxString(L"\u9884\u89C8\u5C31\u7EEA\uff1A%d \u4E2A\u6587\u4EF6\uff0C%d \u4E2A\u53EF\u6267\u884C\uff0C%d \u4E2A\u9700\u5173\u6CE8"),
			m_batchPreviewSummary.totalFiles,
			m_batchPreviewSummary.actionableFiles,
			m_batchPreviewSummary.warningFiles);
		setBatchProgress(0, wxMax(1, m_batchPreviewSummary.actionableFiles), summary);
		logLine(summary);
		updateStatusBar(summary);
		return true;
	}

	bool ensureDirectoryForFile(const std::string& filePath, std::string& outError)
	{
		outError.clear();
		const wxString fileUi = fromLocalPathAcp(filePath);
		if (fileUi.empty() && !filePath.empty())
		{
			outError = "Output path contains characters that cannot be represented by the current code page.";
			return false;
		}

		wxFileName fn(fileUi);
		const wxString dir = fn.GetPath();
		if (dir.empty() || wxFileName::DirExists(dir))
		{
			return true;
		}

		if (!wxFileName::Mkdir(dir, wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL) && !wxFileName::DirExists(dir))
		{
			outError = "Cannot create output directory.";
			return false;
		}
		return true;
	}

	void saveBatchSessionLog(const std::string& outputRoot)
	{
		if (!m_log || outputRoot.empty())
		{
			return;
		}

		const wxString outputDir = fromLocalPathAcp(outputRoot);
		if (outputDir.empty())
		{
			return;
		}

		wxFileName::Mkdir(outputDir, wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL);
		const wxString filename = wxString(L"BinLayoutStudio_batch_") + wxDateTime::Now().Format(wxString(L"%Y%m%d_%H%M%S")) + wxString(L".log.txt");
		const wxString path = wxFileName(outputDir, filename).GetFullPath();
		const wxCharBuffer utf8 = m_log->GetValue().ToUTF8();
		if (!utf8.data())
		{
			return;
		}

		wxFFile file(path, wxString(L"wb"));
		if (!file.IsOpened())
		{
			return;
		}

		file.Write(utf8.data(), strlen(utf8.data()));
		file.Close();
		logLine(wxString(L"Batch log saved: ") + path);
	}

	void initRecentFiles()
	{
		if (m_fileHistory || !m_recentMenu)
		{
			return;
		}

		const wxString dataDir = wxStandardPaths::Get().GetUserLocalDataDir();
		wxFileName::Mkdir(dataDir, wxS_DIR_DEFAULT, wxPATH_MKDIR_FULL);

		const wxString cfgPath = wxFileName(dataDir, wxString(L"BinLayoutStudio.ini")).GetFullPath();
		m_config.reset(new wxFileConfig(wxString(L"BinLayoutStudio"), wxString(L"MT3"), cfgPath, wxEmptyString, wxCONFIG_USE_LOCAL_FILE));

		m_fileHistory.reset(new wxFileHistory(9));
		m_fileHistory->UseMenu(m_recentMenu);
		m_fileHistory->Load(*m_config);
		m_fileHistory->AddFilesToMenu(m_recentMenu);
	}

	void saveRecentFiles()
	{
		if (!m_fileHistory || !m_config)
		{
			return;
		}

		m_fileHistory->Save(*m_config);
		m_config->Flush();
	}

	void logLine(const wxString& line)
	{
		if (!m_log)
		{
			return;
		}

		const wxString timestamp = wxDateTime::Now().FormatISOTime();
		m_log->AppendText(wxString(L"[") + timestamp + wxString(L"] ") + line + wxString(L"\n"));
		m_log->ShowPosition(m_log->GetLastPosition());
	}

	void logf(const char* fmt, ...)
	{
		char buf[2048];
		va_list ap;
		va_start(ap, fmt);
		vsnprintf_s(buf, sizeof(buf), _TRUNCATE, fmt, ap);
		va_end(ap);
		logLine(wxString(buf, wxConvLocal));
	}

	void clearLog()
	{
		if (m_log)
		{
			m_log->Clear();
		}
	}

	void clearTree()
	{
		if (m_tree)
		{
			m_tree->DeleteAllItems();
		}
	}

	void clearList()
	{
		if (m_list)
		{
			m_list->DeleteAllItems();
		}
	}

	void applyPropFilter()
	{
		if (!m_list)
		{
			return;
		}

		m_list->Freeze();
		clearList();

		wxString filter;
		if (m_propSearch)
		{
			filter = m_propSearch->GetValue();
		}

		wxString filterLower = filter;
		filterLower.MakeLower();

		long row = 0;
		const long total = (long)m_currentProps.size();
		for (size_t i = 0; i < m_currentProps.size(); ++i)
		{
			const wxString& name = m_currentProps[i].first;
			const wxString& value = m_currentProps[i].second;

			bool match = filterLower.empty();
			if (!match)
			{
				wxString n = name;
				wxString v = value;
				n.MakeLower();
				v.MakeLower();
				match = (n.Find(filterLower) != wxNOT_FOUND) || (v.Find(filterLower) != wxNOT_FOUND);
			}

			if (!match)
			{
				continue;
			}

			m_list->InsertItem(row, name);
			m_list->SetItem(row, 1, value);
			++row;
		}

		resizePropertyColumns();

		m_list->Thaw();

		if (total > 0)
		{
			wxString msg;
			if (filterLower.empty())
			{
				msg = wxString::Format(wxString(L"\u5C5E\u6027: %ld"), total);
			}
			else
			{
				msg = wxString::Format(wxString(L"\u7B5B\u9009: %s  %ld/%ld"), filter, row, total);
			}
			updateStatusBar(msg);
		}
	}

	void freeCurrentDoc()
	{
		if (m_root)
		{
			BinLayoutStudio::Core::FreeXmlData(m_root);
			m_root = NULL;
		}
	}

	void updatePathBar()
	{
		if (!m_pathBar)
		{
			return;
		}

		if (m_openPath.empty())
		{
			m_pathBar->SetLabel(wxString(L"\u672A\u6253\u5F00\u6587\u4EF6"));
			return;
		}

		wxString label = m_openIsBin ? wxString(L"BIN: ") : wxString(L"XML: ");
		label += fromLocalPathAcp(m_openPath);
		m_pathBar->SetLabel(label);
	}

	static bool tryReadLbfmVersion(const char* path, int& outVersion)
	{
		FILE* fp = fopen(path, "rb");
		if (!fp)
		{
			return false;
		}

		char magic[4] = { 0 };
		if (4 != fread(magic, 1, 4, fp) || 0 != memcmp(magic, "LBFM", 4))
		{
			fclose(fp);
			return false;
		}

		int version = 0;
		if (4 != fread(&version, 1, 4, fp))
		{
			fclose(fp);
			return false;
		}

		fclose(fp);
		outVersion = version;
		return true;
	}

	static void collectStats(const CEGUI::BinLayout::XMLFileData::NodeData* node, int& inoutNodes, int& inoutProps)
	{
		using namespace CEGUI::BinLayout;
		if (!node)
		{
			return;
		}

		const NodeType t = node->getType();
		if (t == NT_Property)
		{
			++inoutProps;
			return;
		}

		++inoutNodes;
		for (int i = 0; i < node->getChildCount(); ++i)
		{
			collectStats(node->getChild(i), inoutNodes, inoutProps);
		}
	}

	void updateStatusBar(const wxString& message = wxEmptyString)
	{
		wxStatusBar* sb = GetStatusBar();
		if (!sb)
		{
			return;
		}

		const bool batchPageActive = m_mainNotebook && m_mainNotebook->GetSelection() == 1;

		wxString f0 = batchPageActive ? wxString(L"Batch Workspace") : wxString(L"Ready");
		if (!batchPageActive && !m_openPath.empty())
		{
			if (m_openIsBin)
			{
				int v = 0;
				if (tryReadLbfmVersion(m_openPath.c_str(), v))
				{
					f0 = wxString::Format(wxString(L"BIN (LBFM v%d)"), v);
				}
				else
				{
					f0 = wxString(L"BIN (LBFM)");
				}
			}
			else
			{
				f0 = wxString(L"XML");
			}
		}

		wxString f1;
		if (batchPageActive)
		{
			f1 = wxString::Format(
				wxString(L"\u9884\u89C8 %d / \u53EF\u6267\u884C %d / \u63D0\u793A %d"),
				m_batchPreviewSummary.totalFiles,
				m_batchPreviewSummary.actionableFiles,
				m_batchPreviewSummary.warningFiles);
		}
		else
		{
			int nodes = 0;
			int props = 0;
			if (m_root)
			{
				collectStats(m_root, nodes, props);
			}
			f1 = wxString::Format(wxString(L"Nodes: %d  Props: %d"), nodes, props);
		}

		wxString f2 = message;
		if (f2.empty())
		{
			if (batchPageActive)
			{
				f2 = m_batchPreviewRefreshPending
					? wxString(L"\u89C4\u5219\u5DF2\u66F4\u65B0\uff0c\u7B49\u5F85\u5237\u65B0\u9884\u89C8")
					: wxString(L"\u8BBE\u5B9A\u6E90/\u8F93\u51FA\u76EE\u5F55\u540E\u5373\u53EF\u6267\u884C\u76EE\u5F55\u8F6C\u6362");
			}
			else
			{
				f2 = m_openPath.empty() ? wxString(L"\u62D6\u62FD .layout \u5230\u7A97\u53E3\u6253\u5F00") : wxString(L"\u5C31\u7EEA");
			}
		}

		sb->SetStatusText(f0, 0);
		sb->SetStatusText(f1, 1);
		sb->SetStatusText(f2, 2);
	}

	void updateUiEnabled()
	{
		const bool hasOpen = !m_openPath.empty();
		const bool hasTree = (m_root != NULL);
		const bool hasBatchWork = !m_batchPreviewItems.empty();
		const bool hasBatchAction = m_batchPreviewSummary.actionableFiles > 0 && !m_batchRunning;

		wxMenuBar* bar = GetMenuBar();
		if (bar)
		{
			bar->Enable(ID_CONVERT_EXPORT_XML, hasTree);
			bar->Enable(ID_CONVERT_EXPORT_BIN, hasTree || hasOpen);
			bar->Enable(ID_TREE_EXPAND_ALL, hasTree);
			bar->Enable(ID_TREE_COLLAPSE_ALL, hasTree);
			bar->Enable(ID_BATCH_REFRESH_PREVIEW, !m_batchRunning);
			bar->Enable(ID_BATCH_RUN, hasBatchAction);
		}

		if (m_reloadBtn)
		{
			m_reloadBtn->Enable(hasOpen && !m_batchRunning);
		}
		if (m_exportXmlBtn)
		{
			m_exportXmlBtn->Enable(hasTree && !m_batchRunning);
		}
		if (m_exportBinBtn)
		{
			m_exportBinBtn->Enable((hasTree || hasOpen) && !m_batchRunning);
		}
		if (m_treeExpandBtn)
		{
			m_treeExpandBtn->Enable(hasTree);
		}
		if (m_treeCollapseBtn)
		{
			m_treeCollapseBtn->Enable(hasTree);
		}
		if (m_batchRefreshBtn)
		{
			m_batchRefreshBtn->Enable(!m_batchRunning);
		}
		if (m_batchRunBtn)
		{
			m_batchRunBtn->Enable(hasBatchAction);
		}
		if (m_batchList)
		{
			m_batchList->Enable(!m_batchRunning && hasBatchWork);
		}
	}

	void populateTreeRecursive(const CEGUI::BinLayout::XMLFileData::NodeData* node, const wxTreeItemId& parent)
	{
		using namespace CEGUI::BinLayout;
		if (!node)
		{
			return;
		}

		wxString text;
		switch (node->getType())
		{
		case NT_Window:
		{
			const XMLFileData::WindowData* w = static_cast<const XMLFileData::WindowData*>(node);
			text = wxString::Format(wxString(L"%s [%s]"), wxString(w->mName.c_str(), wxConvLocal), wxString(w->mType.c_str(), wxConvLocal));
			break;
		}
		case NT_AutoWindow:
		{
			const XMLFileData::AutoWindowData* w = static_cast<const XMLFileData::AutoWindowData*>(node);
			text = wxString::Format(wxString(L"AutoWindow %s"), wxString(w->mNameSuffix.c_str(), wxConvLocal));
			break;
		}
		case NT_LayoutImport:
		{
			const XMLFileData::LayoutImportData* li = static_cast<const XMLFileData::LayoutImportData*>(node);
			text = wxString::Format(wxString(L"LayoutImport %s"), wxString(li->mFilename.c_str(), wxConvLocal));
			break;
		}
		case NT_Event:
		{
			const XMLFileData::EventData* e = static_cast<const XMLFileData::EventData*>(node);
			text = wxString::Format(wxString(L"Event %s"), wxString(e->mName.c_str(), wxConvLocal));
			break;
		}
		default:
			return;
		}

		wxTreeItemId self = m_tree->AppendItem(parent, text, -1, -1, new NodeItemData(node));

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

	void showNodeDetails(const CEGUI::BinLayout::XMLFileData::NodeData* node)
	{
		using namespace CEGUI::BinLayout;

		m_currentProps.clear();
		clearList();
		if (!node)
		{
			updateStatusBar();
			return;
		}

		const NodeType t = node->getType();
		if (t == NT_Window)
		{
			const XMLFileData::WindowData* w = static_cast<const XMLFileData::WindowData*>(node);
			m_currentProps.push_back(std::make_pair(wxString(L"NodeKind"), wxString(L"Window")));
			m_currentProps.push_back(std::make_pair(wxString(L"Type"), wxString(w->mType.c_str(), wxConvLocal)));
			m_currentProps.push_back(std::make_pair(wxString(L"Name"), wxString(w->mName.c_str(), wxConvLocal)));
			m_currentProps.push_back(std::make_pair(wxString(L"ChildCount"), wxString::Format(wxString(L"%d"), node->getChildCount())));

			for (int i = 0; i < node->getChildCount(); ++i)
			{
				const XMLFileData::NodeData* child = node->getChild(i);
				if (child && child->getType() == NT_Property)
				{
					const XMLFileData::PropertyData* p = static_cast<const XMLFileData::PropertyData*>(child);
					m_currentProps.push_back(std::make_pair(wxString(p->mName.c_str(), wxConvLocal), wxString(p->mValue.c_str(), wxConvLocal)));
				}
			}
		}
		else if (t == NT_AutoWindow)
		{
			const XMLFileData::AutoWindowData* w = static_cast<const XMLFileData::AutoWindowData*>(node);
			m_currentProps.push_back(std::make_pair(wxString(L"NodeKind"), wxString(L"AutoWindow")));
			m_currentProps.push_back(std::make_pair(wxString(L"AutoWindow NameSuffix"), wxString(w->mNameSuffix.c_str(), wxConvLocal)));
			m_currentProps.push_back(std::make_pair(wxString(L"ChildCount"), wxString::Format(wxString(L"%d"), node->getChildCount())));

			for (int i = 0; i < node->getChildCount(); ++i)
			{
				const XMLFileData::NodeData* child = node->getChild(i);
				if (child && child->getType() == NT_Property)
				{
					const XMLFileData::PropertyData* p = static_cast<const XMLFileData::PropertyData*>(child);
					m_currentProps.push_back(std::make_pair(wxString(p->mName.c_str(), wxConvLocal), wxString(p->mValue.c_str(), wxConvLocal)));
				}
			}
		}
		else if (t == NT_LayoutImport)
		{
			const XMLFileData::LayoutImportData* li = static_cast<const XMLFileData::LayoutImportData*>(node);
			m_currentProps.push_back(std::make_pair(wxString(L"NodeKind"), wxString(L"LayoutImport")));
			m_currentProps.push_back(std::make_pair(wxString(L"Prefix"), wxString(li->mPrefix.c_str(), wxConvLocal)));
			m_currentProps.push_back(std::make_pair(wxString(L"Filename"), wxString(li->mFilename.c_str(), wxConvLocal)));
			m_currentProps.push_back(std::make_pair(wxString(L"ResourceGroup"), wxString(li->mResourceGroup.c_str(), wxConvLocal)));
		}
		else if (t == NT_Event)
		{
			const XMLFileData::EventData* e = static_cast<const XMLFileData::EventData*>(node);
			m_currentProps.push_back(std::make_pair(wxString(L"NodeKind"), wxString(L"Event")));
			m_currentProps.push_back(std::make_pair(wxString(L"Name"), wxString(e->mName.c_str(), wxConvLocal)));
			m_currentProps.push_back(std::make_pair(wxString(L"Function"), wxString(e->mFunction.c_str(), wxConvLocal)));
		}

		applyPropFilter();
	}

	void loadFile(const std::string& path)
	{
		freeCurrentDoc();
		clearTree();
		clearList();
		m_currentProps.clear();
		if (m_propSearch)
		{
			m_propSearch->SetValue(wxEmptyString);
		}

		m_openPath = path;
		const BinLayoutStudio::Core::LayoutInputFormat format = BinLayoutStudio::Core::DetectLayoutInputFormat(path.c_str());
		m_openIsBin = format == BinLayoutStudio::Core::LayoutInputFormat_Bin;

		logf("Open: %s", path.c_str());
		switch (format)
		{
		case BinLayoutStudio::Core::LayoutInputFormat_Bin:
			logLine(wxString(L"Detected: BIN (LBFM)"));
			break;
		case BinLayoutStudio::Core::LayoutInputFormat_Xml:
			logLine(wxString(L"Detected: XML layout"));
			break;
		default:
			logLine(wxString(L"Detected: Unknown / unreadable layout payload"));
			break;
		}

		std::string err;
		if (!BinLayoutStudio::Core::LoadLayoutToXmlData(path.c_str(), &m_root, err))
		{
			m_root = NULL;
			m_lastFileHint = wxString(L"\u89E3\u6790\u5931\u8D25\uff0c\u8BF7\u68C0\u67E5\u683C\u5F0F\u548C\u65E5\u5FD7");
			const wxString errText = fromUtf8Text(err);
			logLine(wxString(L"Parse failed: ") + (errText.empty() ? wxString(err.c_str(), wxConvLocal) : errText));
		}
		else
		{
			const wxFileName fileName(fromLocalPathAcp(path));
			const wxString rootLabel = fileName.GetFullName().empty() ? wxString(L"Layout") : fileName.GetFullName();

			m_tree->Freeze();
			wxTreeItemId rootItem = m_tree->AddRoot(rootLabel, -1, -1, new NodeItemData(m_root));
			populateTreeRecursive(m_root, rootItem);
			expandTreeRecursive(rootItem, 1);

			wxTreeItemIdValue cookie;
			wxTreeItemId firstVisible = m_tree->GetFirstChild(rootItem, cookie);
			if (firstVisible.IsOk())
			{
				m_tree->SelectItem(firstVisible);
			}
			else
			{
				m_tree->SelectItem(rootItem);
			}
			m_tree->Thaw();

			m_lastFileHint = m_openIsBin
				? wxString(L"\u5DF2\u52A0\u8F7D BIN \u5E03\u5C40\uff0c\u53EF\u68C0\u89C6\u6811\u7ED3\u6784\u5E76\u5BFC\u51FA XML/BIN")
				: wxString(L"\u5DF2\u52A0\u8F7D XML \u5E03\u5C40\uff0c\u53EF\u76F4\u63A5\u9884\u89C8\u7ED3\u6784\u5E76\u5BFC\u51FA BIN");
			logLine(m_openIsBin ? wxString(L"Parse BIN ok") : wxString(L"Parse XML ok"));
		}

		updatePathBar();
		updateInspectorCards();
		updateUiEnabled();
		updateStatusBar();
	}

	bool pickOpenFile(wxString& outPath)
	{
		wxFileDialog dlg(
			this,
			wxString(L"\u9009\u62E9\u5E03\u5C40\u6587\u4EF6"),
			wxEmptyString,
			wxEmptyString,
			wxString(L"CEGUI Layout (*.layout)|*.layout|All Files (*.*)|*.*"),
			wxFD_OPEN | wxFD_FILE_MUST_EXIST);

		if (dlg.ShowModal() != wxID_OK)
		{
			return false;
		}

		outPath = dlg.GetPath();
		return !outPath.empty();
	}

	bool pickSaveFile(std::string& outPath)
	{
		wxString defaultDir;
		wxString defaultName;
		if (!m_openPath.empty())
		{
			wxFileName fn(fromLocalPathAcp(m_openPath));
			defaultDir = fn.GetPath();
			defaultName = fn.GetFullName();
		}

		wxFileDialog dlg(
			this,
			wxString(L"\u9009\u62E9\u8F93\u51FA\u6587\u4EF6\uFF08\u4E0D\u4F1A\u81EA\u52A8\u6539\u540D\u6216\u6DFB\u52A0\u540E\u7F00\uFF09"),
			defaultDir,
			defaultName,
			wxString(L"All Files (*.*)|*.*"),
			wxFD_SAVE | wxFD_OVERWRITE_PROMPT);

		if (dlg.ShowModal() != wxID_OK)
		{
			return false;
		}

		outPath = toLocalPathAcp(dlg.GetPath());
		return !outPath.empty();
	}

	void saveXmlAs()
	{
		if (!m_root)
		{
			wxMessageBox(wxString(L"\u5F53\u524D\u672A\u52A0\u8F7D\u5E03\u5C40\u7ED3\u6784\uff0c\u65E0\u6CD5\u5BFC\u51FA XML\u3002"), wxString(L"BinLayoutStudio"), wxOK | wxICON_WARNING, this);
			return;
		}

		std::string savePath;
		if (!pickSaveFile(savePath))
		{
			return;
		}

		std::string xml;
		std::string err;
		if (!BinLayoutStudio::Core::BuildLayoutXml(m_root, xml, err))
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
		m_lastFileHint = wxString(L"\u5DF2\u5BFC\u51FA XML\uff0c\u53EF\u7EE7\u7EED\u5207\u6362\u5230\u76EE\u5F55\u5DE5\u4F5C\u53F0\u6267\u884C\u6279\u5904\u7406");
		updateInspectorCards();
		updateStatusBar(wxString(L"XML \u5BFC\u51FA\u6210\u529F"));
	}

	void saveBinAs()
	{
		if (!m_root)
		{
			wxMessageBox(wxString(L"\u8BF7\u5148\u6253\u5F00\u5E76\u89E3\u6790\u4E00\u4E2A .layout \u6587\u4EF6\u3002"), wxString(L"BinLayoutStudio"), wxOK | wxICON_WARNING, this);
			return;
		}

		std::string savePath;
		if (!pickSaveFile(savePath))
		{
			return;
		}

		std::string err;
		if (!BinLayoutStudio::Core::WriteXmlDataToBinFile(savePath.c_str(), m_root, err))
		{
			logf("Export BIN failed: %s", err.c_str());
			return;
		}

		logf("Exported BIN: %s", savePath.c_str());
		m_lastFileHint = wxString(L"\u5DF2\u5BFC\u51FA BIN\uff0c\u53EF\u7EE7\u7EED\u8FDB\u884C\u6279\u91CF\u8F6C\u6362\u6216\u6253\u5305\u9A8C\u8BC1");
		updateInspectorCards();
		updateStatusBar(wxString(L"BIN \u5BFC\u51FA\u6210\u529F"));
	}

	void toggleLogVisibility()
	{
		wxMenuBar* bar = GetMenuBar();
		if (!bar)
		{
			return;
		}

		m_showLog = !m_showLog;
		bar->Check(ID_VIEW_TOGGLE_LOG, m_showLog);

		if (m_showLog)
		{
			if (!m_rootSplitter->IsSplit())
			{
				m_log->Show(true);
				m_rootSplitter->SplitHorizontally(m_mainNotebook, m_log, m_lastRootSash);
			}
		}
		else
		{
			if (m_rootSplitter->IsSplit())
			{
				m_lastRootSash = m_rootSplitter->GetSashPosition();
				m_rootSplitter->Unsplit(m_log);
				m_log->Show(false);
			}
		}
	}

	void resetLayoutDefaults()
	{
		m_lastContentSash = 420;
		m_lastRootSash = 700;

		if (m_contentSplitter && m_contentSplitter->IsSplit())
		{
			m_contentSplitter->SetSashPosition(m_lastContentSash);
		}

		if (m_showLog)
		{
			if (m_rootSplitter && m_rootSplitter->IsSplit())
			{
				m_rootSplitter->SetSashPosition(m_lastRootSash);
			}
			else if (m_rootSplitter)
			{
				m_log->Show(true);
				m_rootSplitter->SplitHorizontally(m_mainNotebook, m_log, m_lastRootSash);
			}
		}
	}

	void onRootSashChanged(wxSplitterEvent& e)
	{
		if (m_rootSplitter && m_rootSplitter->IsSplit())
		{
			m_lastRootSash = m_rootSplitter->GetSashPosition();
		}
		e.Skip();
	}

	void onContentSashChanged(wxSplitterEvent& e)
	{
		if (m_contentSplitter && m_contentSplitter->IsSplit())
		{
			m_lastContentSash = m_contentSplitter->GetSashPosition();
		}
		e.Skip();
	}

	void onPropSearchChanged(wxCommandEvent&)
	{
		applyPropFilter();
	}

	void onPropSearchCancel(wxCommandEvent&)
	{
		if (m_propSearch)
		{
			m_propSearch->SetValue(wxEmptyString);
		}
		applyPropFilter();
	}

	void onListSize(wxSizeEvent& e)
	{
		resizePropertyColumns();
		e.Skip();
	}

	void onBatchListSize(wxSizeEvent& e)
	{
		resizeBatchColumns();
		e.Skip();
	}

	void onNotebookChanged(wxBookCtrlEvent& e)
	{
		updateStatusBar();
		e.Skip();
	}

	void onTreeSelChanged(wxTreeEvent& e)
	{
		wxTreeItemId id = e.GetItem();
		NodeItemData* data = id.IsOk() ? dynamic_cast<NodeItemData*>(m_tree->GetItemData(id)) : NULL;
		showNodeDetails(data ? data->getNode() : NULL);
		e.Skip();
	}

	void onOpenRecent(wxCommandEvent& e)
	{
		if (!m_fileHistory)
		{
			return;
		}

		const int idx = (int)(e.GetId() - wxID_FILE1);
		const int count = (int)m_fileHistory->GetCount();
		if (idx < 0 || idx >= count)
		{
			return;
		}

		const wxString path = m_fileHistory->GetHistoryFile(idx);
		if (path.empty())
		{
			return;
		}

		if (!openLayoutFromUiPath(path))
		{
			m_fileHistory->RemoveFileFromHistory(idx);
			saveRecentFiles();
		}
	}

	void onOpen(wxCommandEvent&)
	{
		wxString path;
		if (!pickOpenFile(path))
		{
			return;
		}
		openLayoutFromUiPath(path);
	}

	void onReload(wxCommandEvent&)
	{
		if (!m_openPath.empty())
		{
			loadFile(m_openPath);
		}
	}

	void onExportXml(wxCommandEvent&)
	{
		saveXmlAs();
	}

	void onExportBin(wxCommandEvent&)
	{
		saveBinAs();
	}

	void onGoBatchPage(wxCommandEvent&)
	{
		if (!m_mainNotebook)
		{
			return;
		}

		if (!m_openPath.empty() && m_batchSourcePicker && m_batchSourcePicker->GetPath().empty())
		{
			const wxFileName fn(fromLocalPathAcp(m_openPath));
			m_batchSourcePicker->SetPath(fn.GetPath());
		}

		if (m_batchSourcePicker && m_batchOutputPicker && m_batchOutputPicker->GetPath().empty())
		{
			wxString sourceDir = m_batchSourcePicker->GetPath();
			if (!sourceDir.empty())
			{
				if (!sourceDir.EndsWith(wxString(L"\\")) && !sourceDir.EndsWith(wxString(L"/")))
				{
					sourceDir += wxString(L"\\");
				}
				m_batchOutputPicker->SetPath(sourceDir + wxString(L"converted"));
			}
		}

		m_mainNotebook->SetSelection(1);
		updateStatusBar(wxString(L"\u5DF2\u5207\u6362\u5230\u76EE\u5F55\u8F6C\u6362\u5DE5\u4F5C\u533A"));
		if (m_batchAutoPreviewCheck && m_batchAutoPreviewCheck->GetValue())
		{
			refreshBatchPreview(false);
			updateUiEnabled();
		}
	}

	void onToggleLog(wxCommandEvent&)
	{
		toggleLogVisibility();
	}

	void onClearLog(wxCommandEvent&)
	{
		clearLog();
	}

	void onSaveLog(wxCommandEvent&)
	{
		wxString defaultDir;
		wxString defaultName = wxString(L"BinLayoutStudio.log.txt");
		if (!m_openPath.empty())
		{
			wxFileName fn(fromLocalPathAcp(m_openPath));
			defaultDir = fn.GetPath();
			defaultName = fn.GetName() + wxString(L"_BinLayoutStudio.log.txt");
		}

		wxFileDialog dlg(
			this,
			wxString(L"\u5BFC\u51FA\u65E5\u5FD7"),
			defaultDir,
			defaultName,
			wxString(L"Text Files (*.txt)|*.txt|All Files (*.*)|*.*"),
			wxFD_SAVE | wxFD_OVERWRITE_PROMPT);

		if (dlg.ShowModal() != wxID_OK)
		{
			return;
		}

		const wxString outPath = dlg.GetPath();
		const wxString content = m_log ? m_log->GetValue() : wxEmptyString;
		const wxCharBuffer utf8 = content.ToUTF8();
		if (!utf8.data())
		{
			wxMessageBox(wxString(L"\u65E5\u5FD7\u7F16\u7801\u5931\u8D25\uFF0C\u65E0\u6CD5\u4FDD\u5B58\u3002"), wxString(L"BinLayoutStudio"), wxOK | wxICON_ERROR, this);
			return;
		}

		wxFFile fp(outPath, wxString(L"wb"));
		if (!fp.IsOpened())
		{
			wxMessageBox(wxString(L"\u65E0\u6CD5\u5199\u5165\u6587\u4EF6\uFF1A\n") + outPath, wxString(L"BinLayoutStudio"), wxOK | wxICON_ERROR, this);
			return;
		}

		fp.Write(utf8.data(), strlen(utf8.data()));
		fp.Close();

		logLine(wxString(L"Saved log: ") + outPath);
		updateStatusBar(wxString(L"\u65E5\u5FD7\u5DF2\u4FDD\u5B58"));
	}

	void onResetLayout(wxCommandEvent&)
	{
		resetLayoutDefaults();
	}

	void onExpandAllNodes(wxCommandEvent&)
	{
		if (!m_tree || !m_tree->GetRootItem().IsOk())
		{
			return;
		}

		m_tree->Freeze();
		expandTreeRecursive(m_tree->GetRootItem(), -1);
		m_tree->Thaw();
		updateStatusBar(wxString(L"\u5DF2\u5C55\u5F00\u5168\u90E8\u6811\u8282\u70B9"));
	}

	void onCollapseAllNodes(wxCommandEvent&)
	{
		if (!m_tree || !m_tree->GetRootItem().IsOk())
		{
			return;
		}

		m_tree->Freeze();
		collapseTreeRecursive(m_tree->GetRootItem());
		expandTreeRecursive(m_tree->GetRootItem(), 0);
		m_tree->Thaw();
		updateStatusBar(wxString(L"\u5DF2\u6298\u53E0\u6811\u7ED3\u6784"));
	}

	void onBatchOptionsChanged(wxCommandEvent&)
	{
		markBatchPreviewDirty(wxString(L"\u89C4\u5219\u5DF2\u66F4\u65B0\uff0c\u6B63\u5728\u7B49\u5F85\u9884\u89C8\u5237\u65B0"));
		if (m_batchAutoPreviewCheck && m_batchAutoPreviewCheck->GetValue())
		{
			refreshBatchPreview(false);
		}
		updateUiEnabled();
	}

	void onBatchDirChanged(wxFileDirPickerEvent&)
	{
		markBatchPreviewDirty(wxString(L"\u76EE\u5F55\u8DEF\u5F84\u5DF2\u66F4\u65B0\uff0c\u8BF7\u786E\u8BA4\u9884\u89C8\u7ED3\u679C"));
		if (m_batchAutoPreviewCheck && m_batchAutoPreviewCheck->GetValue())
		{
			refreshBatchPreview(false);
		}
		updateUiEnabled();
	}

	void onBatchRefresh(wxCommandEvent&)
	{
		refreshBatchPreview(true);
		updateUiEnabled();
	}

	void onBatchRun(wxCommandEvent&)
	{
		if (m_batchRunning)
		{
			return;
		}

		if (m_batchPreviewRefreshPending || m_batchPreviewItems.empty())
		{
			if (!refreshBatchPreview(true))
			{
				updateUiEnabled();
				return;
			}
		}

		BinLayoutStudio::Batch::RuleConfig rules;
		wxString uiError;
		if (!collectBatchRules(rules, uiError))
		{
			wxMessageBox(uiError, wxString(L"BinLayoutStudio"), wxOK | wxICON_WARNING, this);
			return;
		}

		if (m_batchPreviewSummary.actionableFiles <= 0)
		{
			wxMessageBox(
				wxString(L"\u5F53\u524D\u89C4\u5219\u4E0B\u6CA1\u6709\u53EF\u6267\u884C\u7684\u8F6C\u6362\u4EFB\u52A1\u3002\n\u8BF7\u68C0\u67E5\u8F93\u51FA\u76EE\u5F55\u3001\u547D\u540D\u89C4\u5219\u6216\u662F\u5426\u9700\u8981\u5F00\u542F\u547D\u540D\u540E\u7F00\u3002"),
				wxString(L"BinLayoutStudio"),
				wxOK | wxICON_INFORMATION,
				this);
			return;
		}

		m_batchRunning = true;
		m_mainNotebook->SetSelection(1);
		updateUiEnabled();

		const int total = m_batchPreviewSummary.actionableFiles;
		int processed = 0;
		int success = 0;
		int failed = 0;

		logLine(wxString(L"Batch convert started."));
		setBatchProgress(0, total, wxString::Format(wxString(L"\u5F00\u59CB\u6279\u91CF\u8F6C\u6362\uff1A%d \u4E2A\u4EFB\u52A1"), total));

		for (size_t i = 0; i < m_batchPreviewItems.size(); ++i)
		{
			const BinLayoutStudio::Batch::PreviewItem& item = m_batchPreviewItems[i];
			if (!item.actionable)
			{
				continue;
			}

			++processed;
			const wxString relativePath = displayPath(item.relativePath.empty() ? item.sourcePath : item.relativePath);
			const wxString startText = wxString::Format(
				wxString(L"[%d/%d] %s -> %s"),
				processed,
				total,
				relativePath,
				displayPath(item.outputPath));
			logLine(startText);

			std::string dirError;
			if (!ensureDirectoryForFile(item.outputPath, dirError))
			{
				++failed;
				logLine(wxString(L"  failed: ") + fromUtf8Text(dirError));
				setBatchProgress(processed, total, wxString::Format(wxString(L"\u76EE\u5F55\u521B\u5EFA\u5931\u8D25\uff1A%d/%d"), processed, total));
				wxYieldIfNeeded();
				continue;
			}

			std::string convertError;
			bool ok = false;
			if (item.action == BinLayoutStudio::Batch::PlannedAction_XmlToBin)
			{
				ok = BinLayoutStudio::Core::ConvertXmlToBinFile(item.sourcePath.c_str(), item.outputPath.c_str(), convertError);
			}
			else if (item.action == BinLayoutStudio::Batch::PlannedAction_BinToXml)
			{
				ok = BinLayoutStudio::Core::ConvertBinToXmlFile(item.sourcePath.c_str(), item.outputPath.c_str(), convertError);
			}

			if (ok)
			{
				++success;
				logLine(wxString(L"  ok"));
			}
			else
			{
				++failed;
				const wxString errText = fromUtf8Text(convertError);
				logLine(wxString(L"  failed: ") + (errText.empty() ? wxString(convertError.c_str(), wxConvLocal) : errText));
			}

			setBatchProgress(
				processed,
				total,
				wxString::Format(
					wxString(L"\u8FDB\u5EA6 %d/%d\uff0C\u6210\u529F %d\uff0C\u5931\u8D25 %d"),
					processed,
					total,
					success,
					failed));
			updateStatusBar(wxString::Format(wxString(L"\u6279\u91CF\u8F6C\u6362\u8FDB\u5EA6 %d/%d"), processed, total));
			wxYieldIfNeeded();
		}

		m_batchRunning = false;

		const wxString summary = wxString::Format(
			wxString(L"\u6279\u91CF\u8F6C\u6362\u5B8C\u6210\uff1A\u6210\u529F %d\uff0C\u5931\u8D25 %d\uff0C\u8DF3\u8FC7 %d"),
			success,
			failed,
			m_batchPreviewSummary.skippedFiles);
		logLine(summary);
		setBatchProgress(total, total, summary);
		saveBatchSessionLog(rules.outputRoot);

		refreshBatchPreview(false);
		updateUiEnabled();
		updateStatusBar(summary);

		wxMessageBox(
			summary,
			wxString(L"BinLayoutStudio"),
			(failed > 0 ? wxICON_WARNING : wxICON_INFORMATION) | wxOK,
			this);
	}

	void onAbout(wxCommandEvent&)
	{
		showAbout(this);
	}

	void onExit(wxCommandEvent&)
	{
		Close(true);
	}
};

bool LayoutFileDropTarget::OnDropFiles(wxCoord, wxCoord, const wxArrayString& filenames)
{
	if (!m_frame)
	{
		return false;
	}

	if (filenames.IsEmpty())
	{
		return false;
	}

	const wxString first = filenames[0];
	const bool ok = m_frame->openLayoutFromUiPath(first);
	if (!ok)
	{
		return false;
	}

	if (filenames.GetCount() > 1)
	{
		wxMessageBox(
			wxString(L"\u5DF2\u6253\u5F00\u7B2C\u4E00\u4E2A\u6587\u4EF6\uFF0C\u5176\u4F59\u6587\u4EF6\u5DF2\u5FFD\u7565\u3002"),
			wxString(L"BinLayoutStudio"),
			wxOK | wxICON_INFORMATION,
			m_frame);
	}

	return true;
}

class BinLayoutStudioApp : public wxApp
{
public:
	BinLayoutStudioApp() {}

	virtual bool OnInit()
	{
		// Ensure CEGUI has a default logger while the app is alive.
		m_logger.reset(new CEGUI::DefaultLogger());

		BinLayoutStudioFrame* frame = new BinLayoutStudioFrame();
		frame->Show(true);
		SetTopWindow(frame);
		return true;
	}

	virtual int OnExit()
	{
		m_logger.reset();
		return wxApp::OnExit();
	}

private:
	std::unique_ptr<CEGUI::DefaultLogger> m_logger;
};

wxIMPLEMENT_APP_NO_MAIN(BinLayoutStudioApp);

// Keep explicit WinMain to preserve CLI mode exit codes (0/1) for scripting.
// Usage:
//   BinLayoutStudio.exe --bin2xml <in.layout> <out.layout>
//   BinLayoutStudio.exe --xml2bin <in.layout> <out.layout>
extern "C" int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, wxCmdLineArgType, int nCmdShow)
{
	wxDISABLE_DEBUG_SUPPORT();

	if (__argc >= 2)
	{
		const char* cmd = __argv[1];
		if (0 == strcmp(cmd, "--help") || 0 == strcmp(cmd, "-h") || 0 == strcmp(cmd, "/?"))
		{
			ensureConsole();
			fprintf(stdout,
				"BinLayoutStudio\n"
				"  --bin2xml <in.layout> <out.layout>\n"
				"  --xml2bin <in.layout> <out.layout>\n");
			return 0;
		}

		if ((0 == strcmp(cmd, "--bin2xml") || 0 == strcmp(cmd, "--xml2bin")) && __argc >= 4)
		{
			ensureConsole();
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

	return wxEntry(hInstance, hPrevInstance, NULL, nCmdShow);
}

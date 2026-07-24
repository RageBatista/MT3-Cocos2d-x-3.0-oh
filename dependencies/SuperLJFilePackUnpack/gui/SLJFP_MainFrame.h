/**
 * @file SLJFP_MainFrame.h
 * @brief SuperLJFilePackUnpack GUI 主窗口
 * @version 1.0
 * @date 2025-01-03
 */

#ifndef SLJFP_MAINFRAME_H
#define SLJFP_MAINFRAME_H

#include <wx/wx.h>
#include <wx/listctrl.h>
#include <wx/treectrl.h>
#include <wx/splitter.h>
#include <wx/notebook.h>
#include <wx/statusbr.h>
#include <wx/progdlg.h>
#include <wx/filedlg.h>
#include <wx/dirdlg.h>
#include <wx/config.h>
#include <wx/thread.h>
#include <wx/spinctrl.h>
#include <wx/notifmsg.h>
#include <wx/combobox.h>
#include <wx/button.h>
#include <wx/choice.h>
#include <wx/arrstr.h>
#include <memory>

#include "../include/SLJFP_Unpack.h"
#include "../include/SLJFP_PathMappingGenerator.h"
#include "../include/SLJFP_WorkflowPresenter.h"
#include "../include/SLJFP_WorkflowReviewController.h"
#include "SLJFP_WorkflowSession.h"

namespace SLJFP {

// 前向声明
class UnpackThread;
class ProgressDialog;

/**
 * @brief 主窗口类
 */
class MainFrame : public wxFrame {
public:
    MainFrame(const wxString& title);
    virtual ~MainFrame();

private:
    // ============ 界面元素 ============
    wxMenuBar*      m_menuBar;
    wxToolBar*      m_toolBar;
    wxStatusBar*    m_statusBar;
    wxSplitterWindow* m_splitter;

    // 左侧: 资源树
    wxTreeCtrl*     m_resourceTree;
    wxTreeItemId    m_rootItem;

    // 右侧: 文件列表和预览
    wxNotebook*     m_notebook;
    wxListCtrl*     m_fileList;
    wxPanel*        m_previewPanel;
    wxStaticBitmap* m_previewImage;
    wxTextCtrl*     m_previewText;
    wxPanel*        m_resultPanel;
    wxTextCtrl*     m_resultSummaryText;
    wxListCtrl*     m_resultIssueList;
    wxButton*       m_resultOpenOutputButton;
    wxButton*       m_resultLocateIssueButton;
    wxButton*       m_resultGenerateMappingButton;
    wxButton*       m_resultExportFailuresButton;
    wxButton*       m_resultRerunIssueButton;
    wxButton*       m_resultClearFilterButton;
    wxTextCtrl*     m_overviewText;
    wxTextCtrl*     m_sessionSourcePathCtrl;
    wxTextCtrl*     m_sessionMappingPathCtrl;
    wxTextCtrl*     m_sessionOutputPathCtrl;
    wxGauge*        m_sessionProgressGauge;
    wxStaticText*   m_sessionProgressLabel;
    wxTextCtrl*     m_sessionLogText;
    wxChoice*       m_presetChoice;
    wxStaticText*   m_stepIndexLabel;
    wxStaticText*   m_stepMappingLabel;
    wxStaticText*   m_stepOutputLabel;
    wxStaticText*   m_stepRunLabel;
    wxButton*       m_quickOpenDirButton;
    wxButton*       m_quickOpenIndexButton;
    wxButton*       m_quickOutputButton;
    wxButton*       m_quickLoadMappingButton;
    wxButton*       m_quickGenerateMappingButton;
    wxButton*       m_quickUnpackButton;
    wxButton*       m_quickPauseButton;
    wxButton*       m_quickStopButton;

    // 配置面板
    wxTextCtrl*     m_inputDirCtrl;
    wxTextCtrl*     m_outputDirCtrl;
    wxCheckBox*     m_verifyCRCCheck;
    wxCheckBox*     m_overwriteCheck;
    wxCheckBox*     m_organizeByTypeCheck;
    wxCheckBox*     m_streamModeCheck;
    wxSpinCtrl*     m_streamChunkCtrl;
    wxCheckBox*     m_autoLoadMappingCheck;
    wxSpinCtrl*     m_threadCountCtrl;
    wxChoice*       m_decryptModeChoice;
    wxTextCtrl*     m_androidLibgameCtrl;
    wxTextCtrl*     m_decryptKeyCtrl;
    wxTextCtrl*     m_mappingPrefixCtrl;
    wxComboBox*     m_mappingHistoryCombo;
    wxButton*       m_loadHistoryButton;

    // ============ 数据成员 ============
    std::unique_ptr<Unpacker> m_unpacker;
    std::string     m_currentInputDir;
    std::string     m_currentOutputDir;
    UnpackThread*   m_unpackThread;
    ProgressDialog* m_progressDialog;
    bool            m_isUnpacking;
    wxString        m_lastMappingFile;
    wxString        m_lastGeneratedMappingFile;
    wxString        m_currentIndexPath;
    bool            m_hasLoadedIndex;
    wxArrayString   m_mappingHistory;
    WorkflowSessionController m_workflowSession;
    WorkflowReviewController  m_reviewController;
    wxString        m_currentRunLabel;
    typedef WorkflowReviewController::ReviewIssueGroup ReviewIssueGroup;

    // ============ 菜单项 ID ============
    enum {
        ID_OPEN_INDEX = wxID_HIGHEST + 1,
        ID_OPEN_DIR,
        ID_UNPACK_ALL,
        ID_UNPACK_SELECTED,
        ID_STOP_UNPACK,
        ID_SET_OUTPUT_DIR,
        ID_LOAD_MAPPING,
        ID_GENERATE_MAPPING,
        ID_LOAD_MAPPING_HISTORY,
        ID_PRESET_CHANGED,
        ID_QUICK_OPEN_DIR,
        ID_QUICK_OPEN_INDEX,
        ID_QUICK_SET_OUTPUT,
        ID_QUICK_LOAD_MAPPING,
        ID_QUICK_GENERATE_MAPPING,
        ID_QUICK_UNPACK,
        ID_QUICK_TOGGLE_PAUSE,
        ID_QUICK_STOP,
        ID_REVIEW_OPEN_OUTPUT,
        ID_REVIEW_LOCATE_ISSUE,
        ID_REVIEW_GENERATE_MAPPING,
        ID_REVIEW_EXPORT_FAILURES,
        ID_REVIEW_RERUN_ISSUE,
        ID_REVIEW_CLEAR_FILTER,
        ID_OPTIONS,
        ID_ABOUT,

        // 工具栏
        ID_TB_OPEN,
        ID_TB_UNPACK,
        ID_TB_STOP,

        // 列表
        ID_FILE_LIST,
        ID_RESULT_ISSUE_LIST,
        ID_RESOURCE_TREE
    };

    // ============ 事件处理 ============
    void OnOpenIndex(wxCommandEvent& event);
    void OnOpenDir(wxCommandEvent& event);
    void OnUnpackAll(wxCommandEvent& event);
    void OnUnpackSelected(wxCommandEvent& event);
    void OnStopUnpack(wxCommandEvent& event);
    void OnSetOutputDir(wxCommandEvent& event);
    void OnLoadMapping(wxCommandEvent& event);
    void OnGenerateMapping(wxCommandEvent& event);
    void OnLoadMappingHistory(wxCommandEvent& event);
    void OnPresetChanged(wxCommandEvent& event);
    void OnQuickOpenDir(wxCommandEvent& event);
    void OnQuickOpenIndex(wxCommandEvent& event);
    void OnQuickSetOutput(wxCommandEvent& event);
    void OnQuickLoadMapping(wxCommandEvent& event);
    void OnQuickGenerateMapping(wxCommandEvent& event);
    void OnQuickUnpack(wxCommandEvent& event);
    void OnQuickTogglePause(wxCommandEvent& event);
    void OnQuickStop(wxCommandEvent& event);
    void OnReviewOpenOutput(wxCommandEvent& event);
    void OnReviewLocateIssue(wxCommandEvent& event);
    void OnReviewGenerateMapping(wxCommandEvent& event);
    void OnReviewExportFailures(wxCommandEvent& event);
    void OnReviewRerunIssue(wxCommandEvent& event);
    void OnReviewClearFilter(wxCommandEvent& event);
    void OnOptions(wxCommandEvent& event);
    void OnAbout(wxCommandEvent& event);
    void OnExit(wxCommandEvent& event);

    void OnFileListSelected(wxListEvent& event);
    void OnFileListActivated(wxListEvent& event);
    void OnResultIssueSelected(wxListEvent& event);
    void OnResultIssueActivated(wxListEvent& event);
    void OnTreeSelChanged(wxTreeEvent& event);

    void OnUnpackProgress(wxThreadEvent& event);
    void OnUnpackComplete(wxThreadEvent& event);
    void OnProgressDialogDestroy(wxWindowDestroyEvent& event);

    // ============ 辅助方法 ============
    void CreateMenuBar();
    void CreateToolBar();
    void CreateStatusBar();
    void CreateMainUI();
    void CreateWorkflowPanel(wxPanel* parent, wxSizer* parentSizer);
    void CreateConfigPanel(wxPanel* parent);
    void ApplyPresetBySelection(int selection);
    bool BuildUnpackOptions(UnpackOptions& options, bool showError);
    bool ValidateReadyForUnpack(bool showError) const;
    bool StartUnpackWorkflow(const UnpackOptions& options,
                             const std::vector<size_t>* selectedIndices = nullptr,
                             const wxString& workflowLabel = wxEmptyString);
    bool PromptForReferenceDirs(wxArrayString& outDirs) const;
    void CollectReferenceResourceDirs(const wxString& indexDir, wxArrayString& outDirs) const;
    bool GeneratePathMappingFromReferenceDirs(const wxArrayString& referenceDirs,
                                              const wxString& outputPath,
                                              bool isBinary,
                                              PathMappingGenerator::ScanStats& outStats,
                                              uint32_t& outUniqueMappings,
                                              wxArrayString* outUsedDirs = nullptr,
                                              bool showProgress = true);
    bool TryGenerateMergedMappingFromReferenceDirs(const wxArrayString& referenceDirs,
                                                   wxString& outMappingPath,
                                                   wxArrayString* outUsedDirs = nullptr);
    bool EnsureUsablePathMapping(bool showHint);
    void UpdateWorkflowStatus();
    void RefreshOverviewPanel();
    void RefreshSessionControlPanel();
    void AppendSessionLog(const wxString& message);
    void RefreshResultReviewPanel();
    void UpdateQuickActionAvailability();
    bool TryApplyAndroidLibgameKey(bool forceRefresh, bool showFeedback);
    void SyncDecryptKeyFromUi();

    void LoadIndex(const wxString& path);
    bool TryAutoLoadMapping(const wxString& directoryPath, const wxString& indexFileName = wxEmptyString);
    void AddMappingHistory(const wxString& path);
    void RefreshMappingHistoryUI();
    void RefreshFileList();
    void RefreshResourceTree();
    void UpdatePreview(size_t fileIndex);
    void UpdateStatusBar();
    size_t GetSelectedFileIndex() const;
    void SelectAndRevealFile(size_t fileIndex);
    const ReviewIssueGroup* GetReviewIssueGroupByRow(long row) const;
    const ReviewIssueGroup* GetSelectedReviewIssueGroup() const;
    void ApplyReviewFilter(const ReviewIssueGroup* group);
    void ClearReviewFilter();
    bool HasActiveReviewFilter(size_t fileIndex) const;
    void ClearPreviewPanel();

    void SaveConfig();
    void LoadConfig();

    wxDECLARE_EVENT_TABLE();
};

/**
 * @brief 解包线程
 */
class UnpackThread : public wxThread {
public:
    UnpackThread(MainFrame* frame, Unpacker* unpacker,
                 const std::string& inputDir, const std::string& outputDir,
                 const UnpackOptions& options,
                 const std::vector<size_t>* selectedIndices = nullptr);

    virtual ExitCode Entry() override;

private:
    MainFrame*      m_frame;
    Unpacker*       m_unpacker;
    std::string     m_inputDir;
    std::string     m_outputDir;
    UnpackOptions   m_options;
    std::vector<size_t> m_selectedIndices;
};

// 自定义事件类型
wxDECLARE_EVENT(wxEVT_UNPACK_PROGRESS, wxThreadEvent);
wxDECLARE_EVENT(wxEVT_UNPACK_COMPLETE, wxThreadEvent);

} // namespace SLJFP

#endif // SLJFP_MAINFRAME_H

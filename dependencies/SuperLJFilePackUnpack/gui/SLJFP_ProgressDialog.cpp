/**
 * @file SLJFP_ProgressDialog.cpp
 * @brief 统一操作进度对话框实现
 * @version 1.0
 * @date 2026-01-04
 */

#include "SLJFP_ProgressDialog.h"
#include <wx/sizer.h>
#include <iomanip>
#include <sstream>

namespace SLJFP {

wxBEGIN_EVENT_TABLE(ProgressDialog, wxDialog)
    EVT_BUTTON(ID_PAUSE_BTN, ProgressDialog::OnPause)
    EVT_BUTTON(ID_STOP_BTN, ProgressDialog::OnStop)
    EVT_BUTTON(ID_CLOSE_BTN, ProgressDialog::OnClose)
    EVT_CLOSE(ProgressDialog::OnCloseWindow)
    EVT_TIMER(ID_UPDATE_TIMER, ProgressDialog::OnTimer)
wxEND_EVENT_TABLE()

ProgressDialog::ProgressDialog(wxWindow* parent,
                               const wxString& title,
                               int totalFiles)
    : wxDialog(parent, wxID_ANY, title,
               wxDefaultPosition, wxSize(600, 450),
               wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER)
    , m_statusLabel(nullptr)
    , m_fileLabel(nullptr)
    , m_progressBar(nullptr)
    , m_percentLabel(nullptr)
    , m_statsLabel(nullptr)
    , m_logList(nullptr)
    , m_pauseBtn(nullptr)
    , m_stopBtn(nullptr)
    , m_closeBtn(nullptr)
    , m_updateTimer(this, ID_UPDATE_TIMER)
    , m_cancelled(false)
    , m_paused(false)
    , m_finished(false)
    , m_pendingProgress(0)
{
    CreateControls();
    LayoutControls();

    if (totalFiles > 0) {
        Initialize(totalFiles, 0);
    }

    // 启动 UI 更新定时器 (100ms 间隔)
    m_updateTimer.Start(100);

    Centre();
}

ProgressDialog::~ProgressDialog() {
    m_updateTimer.Stop();
}

void ProgressDialog::CreateControls() {
    // 状态标签
    m_statusLabel = new wxStaticText(this, wxID_ANY, wxT("准备中..."));
    m_statusLabel->SetFont(m_statusLabel->GetFont().Bold());

    // 当前文件标签
    m_fileLabel = new wxStaticText(this, wxID_ANY, wxEmptyString);
    m_fileLabel->SetForegroundColour(wxColour(64, 64, 64));

    // 进度条
    m_progressBar = new wxGauge(this, wxID_ANY, 100,
                                 wxDefaultPosition, wxSize(-1, 25),
                                 wxGA_HORIZONTAL | wxGA_SMOOTH);

    // 百分比标签
    m_percentLabel = new wxStaticText(this, wxID_ANY, wxT("0%"));
    m_percentLabel->SetFont(m_percentLabel->GetFont().Larger().Bold());

    // 统计信息标签
    m_statsLabel = new wxStaticText(this, wxID_ANY, wxEmptyString);
    m_statsLabel->SetForegroundColour(wxColour(96, 96, 96));

    // 日志列表
    m_logList = new wxListBox(this, wxID_ANY,
                               wxDefaultPosition, wxSize(-1, 200),
                               0, nullptr,
                               wxLB_HSCROLL | wxLB_NEEDED_SB);
    m_logList->SetFont(wxFont(9, wxFONTFAMILY_TELETYPE, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL));

    // 按钮
    m_pauseBtn = new wxButton(this, ID_PAUSE_BTN, wxT("暂停"));
    m_stopBtn = new wxButton(this, ID_STOP_BTN, wxT("停止"));
    m_closeBtn = new wxButton(this, ID_CLOSE_BTN, wxT("关闭"));
    m_closeBtn->Enable(false);  // 初始禁用，完成后启用
}

void ProgressDialog::LayoutControls() {
    wxBoxSizer* mainSizer = new wxBoxSizer(wxVERTICAL);

    // 顶部状态区域
    wxStaticBoxSizer* statusBox = new wxStaticBoxSizer(wxVERTICAL, this, wxT("状态"));
    statusBox->Add(m_statusLabel, 0, wxEXPAND | wxALL, 5);
    statusBox->Add(m_fileLabel, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 5);

    // 进度区域
    wxBoxSizer* progressSizer = new wxBoxSizer(wxHORIZONTAL);
    progressSizer->Add(m_progressBar, 1, wxALIGN_CENTER_VERTICAL | wxRIGHT, 10);
    progressSizer->Add(m_percentLabel, 0, wxALIGN_CENTER_VERTICAL);
    statusBox->Add(progressSizer, 0, wxEXPAND | wxALL, 5);

    // 统计信息
    statusBox->Add(m_statsLabel, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 5);

    mainSizer->Add(statusBox, 0, wxEXPAND | wxALL, 10);

    // 日志区域
    wxStaticBoxSizer* logBox = new wxStaticBoxSizer(wxVERTICAL, this, wxT("日志"));
    logBox->Add(m_logList, 1, wxEXPAND | wxALL, 5);
    mainSizer->Add(logBox, 1, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 10);

    // 按钮区域
    wxBoxSizer* buttonSizer = new wxBoxSizer(wxHORIZONTAL);
    buttonSizer->AddStretchSpacer();
    buttonSizer->Add(m_pauseBtn, 0, wxRIGHT, 5);
    buttonSizer->Add(m_stopBtn, 0, wxRIGHT, 5);
    buttonSizer->Add(m_closeBtn, 0);
    mainSizer->Add(buttonSizer, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 10);

    SetSizer(mainSizer);
    Layout();
}

void ProgressDialog::Initialize(int totalFiles, int64_t totalBytes) {
    m_stats.Reset();
    m_stats.totalFiles = totalFiles;
    m_stats.totalBytes = totalBytes;

    m_cancelled.store(false);
    m_paused.store(false);
    m_finished.store(false);

    m_progressBar->SetRange(totalFiles > 0 ? totalFiles : 100);
    m_progressBar->SetValue(0);

    m_statusLabel->SetLabel(wxT("正在处理..."));
    m_fileLabel->SetLabel(wxEmptyString);
    m_percentLabel->SetLabel(wxT("0%"));

    m_pauseBtn->Enable(true);
    m_stopBtn->Enable(true);
    m_closeBtn->Enable(false);

    // 清空日志
    m_logList->Clear();

    LogInfo(wxString::Format(wxT("开始处理，共 %d 个文件"), totalFiles));
}

void ProgressDialog::UpdateProgress(int currentIndex,
                                     const wxString& currentFile,
                                     int64_t bytesProcessed) {
    std::lock_guard<std::mutex> lock(m_updateMutex);

    m_stats.processedFiles = currentIndex + 1;
    m_stats.processedBytes = bytesProcessed;
    m_pendingProgress = currentIndex + 1;
    m_pendingFile = currentFile;

    // 状态文本将在定时器中更新
}

void ProgressDialog::AddLog(LogEntryType type, const wxString& message) {
    std::lock_guard<std::mutex> lock(m_logMutex);
    m_logQueue.push(LogEntry(type, message));

    // 更新统计
    switch (type) {
        case LogEntryType::Success:
            m_stats.successFiles++;
            break;
        case LogEntryType::Error:
            m_stats.failedFiles++;
            break;
        default:
            break;
    }
}

void ProgressDialog::SetFinished(const wxString& summary) {
    m_stats.endTime = std::chrono::steady_clock::now();
    m_finished.store(true);

    // 添加完成日志
    if (!summary.empty()) {
        AddLog(LogEntryType::Info, summary);
    }

    // 添加统计摘要
    wxString statsMsg = wxString::Format(
        wxT("处理完成: 总计 %d 个文件, 成功 %d, 失败 %d, 跳过 %d, 空文件 %d"),
        m_stats.totalFiles, m_stats.successFiles, m_stats.failedFiles,
        m_stats.skippedFiles, m_stats.emptyFiles);
    AddLog(LogEntryType::Info, statsMsg);

    double elapsed = m_stats.GetElapsedSeconds();
    wxString timeMsg = wxString::Format(wxT("耗时: %s, 速度: %.1f 文件/秒"),
                                         FormatTime(elapsed), m_stats.GetFilesPerSecond());
    AddLog(LogEntryType::Info, timeMsg);
}

void ProgressDialog::SetResultCounts(int successFiles,
                                     int failedFiles,
                                     int skippedFiles,
                                     int emptyFiles) {
    std::lock_guard<std::mutex> lock(m_updateMutex);
    m_stats.successFiles = successFiles;
    m_stats.failedFiles = failedFiles;
    m_stats.skippedFiles = skippedFiles;
    m_stats.emptyFiles = emptyFiles;

    const int finalProcessed = successFiles + failedFiles + skippedFiles + emptyFiles;
    if (finalProcessed > 0) {
        m_stats.processedFiles = finalProcessed;
        m_pendingProgress = std::min(finalProcessed, m_stats.totalFiles);
    }
}

void ProgressDialog::RequestStop() {
    const bool wasCancelled = m_cancelled.exchange(true);
    if (!wasCancelled) {
        m_stopBtn->Enable(false);
        m_pauseBtn->Enable(false);
        LogWarning(wxT("正在停止... (完成当前安全点后退出)"));
        if (m_stopHandler) {
            m_stopHandler();
        }
    }
}

void ProgressDialog::OnTimer(wxTimerEvent& event) {
    wxUnusedVar(event);
    UpdateUI();
}

void ProgressDialog::UpdateUI() {
    // 更新进度条和状态
    {
        std::lock_guard<std::mutex> lock(m_updateMutex);

        if (m_pendingProgress > 0) {
            m_progressBar->SetValue(m_pendingProgress);

            double percent = m_stats.GetProgress();
            m_percentLabel->SetLabel(wxString::Format(wxT("%.1f%%"), percent));

            if (!m_pendingFile.empty()) {
                // 截断过长的路径
                wxString displayFile = m_pendingFile;
                if (displayFile.length() > 60) {
                    displayFile = wxT("...") + displayFile.Right(57);
                }
                m_fileLabel->SetLabel(wxString::Format(wxT("当前: %s"), displayFile));
            }
        }
    }

    // 更新统计显示
    UpdateStatsDisplay();

    // 处理日志队列
    {
        std::lock_guard<std::mutex> lock(m_logMutex);
        while (!m_logQueue.empty()) {
            const LogEntry& entry = m_logQueue.front();
            wxString prefix = GetLogPrefix(entry.type);
            wxString line = prefix + entry.message;

            int idx = m_logList->Append(line);
            if (idx >= 0) {
                m_logList->SetSelection(idx);
                m_logList->EnsureVisible(idx);
            }

            // 限制日志条数
            if (m_logList->GetCount() > 1000) {
                m_logList->Delete(0);
            }

            m_logQueue.pop();
        }
    }

    // 更新完成状态
    if (m_finished.load()) {
        m_statusLabel->SetLabel(wxT("处理完成"));
        m_pauseBtn->Enable(false);
        m_stopBtn->Enable(false);
        m_closeBtn->Enable(true);
        m_updateTimer.Stop();
    } else if (m_cancelled.load()) {
        m_statusLabel->SetLabel(wxT("已取消"));
        m_pauseBtn->Enable(false);
        m_stopBtn->Enable(false);
        m_closeBtn->Enable(true);
    } else if (m_paused.load()) {
        m_statusLabel->SetLabel(wxT("已暂停"));
    } else {
        m_statusLabel->SetLabel(wxString::Format(wxT("正在处理 (%d/%d)..."),
                                                  m_stats.processedFiles, m_stats.totalFiles));
    }
}

void ProgressDialog::UpdateStatsDisplay() {
    double elapsed = m_stats.GetElapsedSeconds();
    double speed = m_stats.GetFilesPerSecond();

    // 估算剩余时间
    int remaining = m_stats.totalFiles - m_stats.processedFiles;
    double eta = (speed > 0) ? (remaining / speed) : 0;

    wxString statsText = wxString::Format(
        wxT("成功: %d | 失败: %d | 速度: %.1f 文件/秒 | 已用: %s | 剩余: %s"),
        m_stats.successFiles, m_stats.failedFiles, speed,
        FormatTime(elapsed), FormatTime(eta));

    m_statsLabel->SetLabel(statsText);
}

wxString ProgressDialog::FormatTime(double seconds) const {
    if (seconds < 0) seconds = 0;

    int hours = static_cast<int>(seconds / 3600);
    int minutes = static_cast<int>((seconds - hours * 3600) / 60);
    int secs = static_cast<int>(seconds) % 60;

    if (hours > 0) {
        return wxString::Format(wxT("%02d:%02d:%02d"), hours, minutes, secs);
    } else {
        return wxString::Format(wxT("%02d:%02d"), minutes, secs);
    }
}

wxString ProgressDialog::GetLogPrefix(LogEntryType type) const {
    switch (type) {
        case LogEntryType::Success: return wxT("[OK] ");
        case LogEntryType::Error:   return wxT("[FAIL] ");
        case LogEntryType::Warning: return wxT("[WARN] ");
        case LogEntryType::Info:
        default:                    return wxT("[INFO] ");
    }
}

wxColour ProgressDialog::GetLogColor(LogEntryType type) const {
    switch (type) {
        case LogEntryType::Success: return wxColour(0, 128, 0);    // 绿色
        case LogEntryType::Error:   return wxColour(192, 0, 0);    // 红色
        case LogEntryType::Warning: return wxColour(192, 128, 0);  // 橙色
        case LogEntryType::Info:
        default:                    return wxColour(0, 0, 0);      // 黑色
    }
}

void ProgressDialog::OnPause(wxCommandEvent& event) {
    wxUnusedVar(event);
    if (m_paused.load()) {
        m_paused.store(false);
        m_pauseBtn->SetLabel(wxT("暂停"));
        LogInfo(wxT("继续处理..."));
        if (m_pauseHandler) {
            m_pauseHandler(false);
        }
    } else {
        m_paused.store(true);
        m_pauseBtn->SetLabel(wxT("继续"));
        LogInfo(wxT("已暂停"));
        if (m_pauseHandler) {
            m_pauseHandler(true);
        }
    }
}

void ProgressDialog::OnStop(wxCommandEvent& event) {
    wxUnusedVar(event);
    RequestStop();
}

void ProgressDialog::OnClose(wxCommandEvent& event) {
    wxUnusedVar(event);
    if (m_finished.load() || m_cancelled.load()) {
        // 非模态对话框使用 Destroy() 而不是 EndModal()
        // 因为 MainFrame::OnUnpackAll 使用 Show() 而不是 ShowModal()
        Destroy();
    }
}

void ProgressDialog::OnCloseWindow(wxCloseEvent& event) {
    if (m_finished.load() || m_cancelled.load()) {
        // 非模态对话框在完成或取消后可以关闭
        // 使用 Destroy() 确保正确清理
        Destroy();
    } else {
        // 正在处理时，点击关闭相当于取消
        RequestStop();
        event.Veto();  // 暂时阻止关闭
    }
}

} // namespace SLJFP

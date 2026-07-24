/**
 * @file SLJFP_ProgressDialog.h
 * @brief 统一操作进度对话框
 * @version 1.0
 * @date 2026-01-04
 *
 * 参考 SpriteEditor 的 ModelReverseProgressDlg 设计
 * 提供单一进度窗口，避免多窗口闪退问题
 */

#ifndef SLJFP_PROGRESS_DIALOG_H
#define SLJFP_PROGRESS_DIALOG_H

#include <wx/wx.h>
#include <wx/progdlg.h>
#include <wx/listbox.h>
#include <wx/gauge.h>
#include <wx/stattext.h>
#include <wx/timer.h>
#include <wx/thread.h>

#include <string>
#include <vector>
#include <queue>
#include <mutex>
#include <atomic>
#include <chrono>
#include <functional>

namespace SLJFP {

/**
 * @brief 日志条目类型
 */
enum class LogEntryType {
    Info,       // 普通信息
    Success,    // 成功
    Warning,    // 警告
    Error       // 错误
};

/**
 * @brief 日志条目
 */
struct LogEntry {
    LogEntryType type;
    wxString message;
    std::chrono::steady_clock::time_point timestamp;

    LogEntry(LogEntryType t = LogEntryType::Info, const wxString& msg = "")
        : type(t), message(msg), timestamp(std::chrono::steady_clock::now()) {}
};

/**
 * @brief 操作统计信息
 */
struct OperationStats {
    int totalFiles = 0;
    int processedFiles = 0;
    int successFiles = 0;
    int failedFiles = 0;
    int skippedFiles = 0;
    int emptyFiles = 0;
    int64_t totalBytes = 0;
    int64_t processedBytes = 0;
    std::chrono::steady_clock::time_point startTime;
    std::chrono::steady_clock::time_point endTime;

    void Reset() {
        totalFiles = processedFiles = successFiles = 0;
        failedFiles = skippedFiles = emptyFiles = 0;
        totalBytes = processedBytes = 0;
        startTime = std::chrono::steady_clock::now();
    }

    double GetElapsedSeconds() const {
        auto end = (processedFiles >= totalFiles) ? endTime : std::chrono::steady_clock::now();
        return std::chrono::duration<double>(end - startTime).count();
    }

    double GetProgress() const {
        return (totalFiles > 0) ? (100.0 * processedFiles / totalFiles) : 0.0;
    }

    double GetFilesPerSecond() const {
        double elapsed = GetElapsedSeconds();
        return (elapsed > 0) ? (processedFiles / elapsed) : 0.0;
    }
};

/**
 * @brief 统一操作进度对话框
 *
 * 设计特点:
 * 1. 单一模态对话框，显示所有操作进度
 * 2. 进度条 + 当前文件状态 + 滚动日志
 * 3. 支持暂停/停止/继续
 * 4. 完成后显示统计摘要
 * 5. 线程安全的日志更新
 */
class ProgressDialog : public wxDialog {
public:
    /**
     * @brief 构造函数
     * @param parent 父窗口
     * @param title 对话框标题
     * @param totalFiles 总文件数
     */
    ProgressDialog(wxWindow* parent,
                   const wxString& title = wxT("操作进度"),
                   int totalFiles = 0);

    virtual ~ProgressDialog();

    // ============ 公共接口 (线程安全) ============

    /**
     * @brief 初始化进度
     * @param totalFiles 总文件数
     * @param totalBytes 总字节数 (可选)
     */
    void Initialize(int totalFiles, int64_t totalBytes = 0);

    /**
     * @brief 更新当前进度
     * @param currentIndex 当前索引 (0-based)
     * @param currentFile 当前文件路径
     * @param bytesProcessed 已处理字节数
     */
    void UpdateProgress(int currentIndex,
                        const wxString& currentFile,
                        int64_t bytesProcessed = 0);

    /**
     * @brief 添加日志
     * @param type 日志类型
     * @param message 日志消息
     */
    void AddLog(LogEntryType type, const wxString& message);

    /**
     * @brief 便捷方法：添加成功日志
     */
    void LogSuccess(const wxString& message) { AddLog(LogEntryType::Success, message); }

    /**
     * @brief 便捷方法：添加错误日志
     */
    void LogError(const wxString& message) { AddLog(LogEntryType::Error, message); }

    /**
     * @brief 便捷方法：添加警告日志
     */
    void LogWarning(const wxString& message) { AddLog(LogEntryType::Warning, message); }

    /**
     * @brief 便捷方法：添加信息日志
     */
    void LogInfo(const wxString& message) { AddLog(LogEntryType::Info, message); }

    /**
     * @brief 标记操作完成
     * @param summary 摘要信息 (可选)
     */
    void SetFinished(const wxString& summary = wxEmptyString);
    void SetResultCounts(int successFiles,
                         int failedFiles,
                         int skippedFiles = 0,
                         int emptyFiles = 0);
    void SetPauseHandler(const std::function<void(bool)>& handler) { m_pauseHandler = handler; }
    void SetStopHandler(const std::function<void()>& handler) { m_stopHandler = handler; }
    void RequestStop();

    /**
     * @brief 增加成功计数
     */
    void IncrementSuccess() { m_stats.successFiles++; }

    /**
     * @brief 增加失败计数
     */
    void IncrementFailed() { m_stats.failedFiles++; }

    /**
     * @brief 增加跳过计数
     */
    void IncrementSkipped() { m_stats.skippedFiles++; }

    /**
     * @brief 增加空文件计数
     */
    void IncrementEmpty() { m_stats.emptyFiles++; }

    // ============ 状态查询 (线程安全) ============

    /**
     * @brief 检查是否已取消
     */
    bool IsCancelled() const { return m_cancelled.load(); }

    /**
     * @brief 检查是否已暂停
     */
    bool IsPaused() const { return m_paused.load(); }

    /**
     * @brief 检查是否已完成
     */
    bool IsFinished() const { return m_finished.load(); }

    /**
     * @brief 获取统计信息
     */
    const OperationStats& GetStats() const { return m_stats; }

private:
    // ============ UI 组件 ============
    wxStaticText*   m_statusLabel;      // 当前状态
    wxStaticText*   m_fileLabel;        // 当前文件
    wxGauge*        m_progressBar;      // 进度条
    wxStaticText*   m_percentLabel;     // 百分比
    wxStaticText*   m_statsLabel;       // 统计信息
    wxListBox*      m_logList;          // 日志列表
    wxButton*       m_pauseBtn;         // 暂停按钮
    wxButton*       m_stopBtn;          // 停止按钮
    wxButton*       m_closeBtn;         // 关闭按钮
    wxTimer         m_updateTimer;      // UI 更新定时器

    // ============ 状态 ============
    std::atomic<bool> m_cancelled;
    std::atomic<bool> m_paused;
    std::atomic<bool> m_finished;
    OperationStats m_stats;

    // ============ 线程安全日志队列 ============
    std::queue<LogEntry> m_logQueue;
    std::mutex m_logMutex;

    // ============ UI 更新缓存 ============
    wxString m_pendingStatus;
    wxString m_pendingFile;
    int m_pendingProgress;
    std::mutex m_updateMutex;
    std::function<void(bool)> m_pauseHandler;
    std::function<void()> m_stopHandler;

    // ============ 私有方法 ============
    void CreateControls();
    void LayoutControls();
    void UpdateUI();
    void UpdateStatsDisplay();
    wxString FormatTime(double seconds) const;
    wxString GetLogPrefix(LogEntryType type) const;
    wxColour GetLogColor(LogEntryType type) const;

    // ============ 事件处理 ============
    void OnPause(wxCommandEvent& event);
    void OnStop(wxCommandEvent& event);
    void OnClose(wxCommandEvent& event);
    void OnCloseWindow(wxCloseEvent& event);
    void OnTimer(wxTimerEvent& event);

    wxDECLARE_EVENT_TABLE();

    enum {
        ID_PAUSE_BTN = wxID_HIGHEST + 100,
        ID_STOP_BTN,
        ID_CLOSE_BTN,
        ID_UPDATE_TIMER
    };
};

} // namespace SLJFP

#endif // SLJFP_PROGRESS_DIALOG_H

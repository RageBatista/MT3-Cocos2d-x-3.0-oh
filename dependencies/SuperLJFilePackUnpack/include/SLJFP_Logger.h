#ifndef SLJFP_LOGGER_H
#define SLJFP_LOGGER_H

/**
 * @file SLJFP_Logger.h
 * @brief SuperLJFilePackUnpack 日志系统
 * @version 1.0
 * @date 2025-01-03
 *
 * 基于 LJFilePack 逆向功能实施方案文档第12章设计
 */

#include <string>
#include <fstream>
#include <vector>
#include <functional>
#include <mutex>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>
#include <iostream>

namespace SLJFP {

/**
 * @brief 日志级别
 */
enum LogLevel {
    LOG_DEBUG = 0,      ///< 调试信息
    LOG_INFO = 1,       ///< 一般信息
    LOG_WARNING = 2,    ///< 警告
    LOG_ERROR = 3,      ///< 错误
    LOG_FATAL = 4       ///< 致命错误
};

/**
 * @brief 获取日志级别字符串
 */
inline const wchar_t* GetLogLevelString(LogLevel level) {
    switch (level) {
        case LOG_DEBUG:   return L"DEBUG";
        case LOG_INFO:    return L"INFO ";
        case LOG_WARNING: return L"WARN ";
        case LOG_ERROR:   return L"ERROR";
        case LOG_FATAL:   return L"FATAL";
        default:          return L"?????";
    }
}

/**
 * @brief 日志回调函数类型
 */
typedef std::function<void(LogLevel, const std::wstring&)> LogCallback;

/**
 * @brief 日志管理器 (单例模式)
 */
class Logger {
private:
    std::wofstream m_fileStream;
    LogLevel m_minLevel;
    std::mutex m_mutex;
    std::vector<LogCallback> m_callbacks;
    bool m_consoleOutput;

    Logger() : m_minLevel(LOG_INFO), m_consoleOutput(true) {}

public:
    /**
     * @brief 获取单例实例
     */
    static Logger& Instance() {
        static Logger instance;
        return instance;
    }

    /**
     * @brief 销毁单例
     */
    static void Destroy() {
        Instance().Shutdown();
    }

    /**
     * @brief 初始化日志系统
     * @param logFile 日志文件路径
     * @param minLevel 最小日志级别
     */
    void Initialize(const std::wstring& logFile, LogLevel minLevel = LOG_INFO) {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_minLevel = minLevel;

        if (!logFile.empty()) {
            m_fileStream.open(logFile, std::ios::app);
        }
    }

    /**
     * @brief 关闭日志系统
     */
    void Shutdown() {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (m_fileStream.is_open()) {
            m_fileStream.close();
        }
        m_callbacks.clear();
    }

    /**
     * @brief 设置最小日志级别
     */
    void SetMinLevel(LogLevel level) {
        m_minLevel = level;
    }

    /**
     * @brief 设置是否输出到控制台
     */
    void SetConsoleOutput(bool enable) {
        m_consoleOutput = enable;
    }

    /**
     * @brief 添加日志回调
     */
    void AddCallback(LogCallback callback) {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_callbacks.push_back(callback);
    }

    /**
     * @brief 记录日志
     * @param level 日志级别
     * @param message 日志消息
     */
    void Log(LogLevel level, const std::wstring& message) {
        if (level < m_minLevel) return;

        std::lock_guard<std::mutex> lock(m_mutex);

        // 生成时间戳
        std::wstring timestamp = GetTimestamp();
        std::wstring levelStr = GetLogLevelString(level);
        std::wstring fullMessage = L"[" + timestamp + L"] [" + levelStr + L"] " + message;

        // 写入文件
        if (m_fileStream.is_open()) {
            m_fileStream << fullMessage << std::endl;
            m_fileStream.flush();
        }

        // 输出到控制台
        if (m_consoleOutput) {
            std::wcout << fullMessage << std::endl;
        }

        // 回调通知
        for (const auto& callback : m_callbacks) {
            callback(level, fullMessage);
        }
    }

    /**
     * @brief 便捷方法 - DEBUG
     */
    void Debug(const std::wstring& msg) { Log(LOG_DEBUG, msg); }

    /**
     * @brief 便捷方法 - INFO
     */
    void Info(const std::wstring& msg) { Log(LOG_INFO, msg); }

    /**
     * @brief 便捷方法 - WARNING
     */
    void Warning(const std::wstring& msg) { Log(LOG_WARNING, msg); }

    /**
     * @brief 便捷方法 - ERROR
     */
    void Error(const std::wstring& msg) { Log(LOG_ERROR, msg); }

    /**
     * @brief 便捷方法 - FATAL
     */
    void Fatal(const std::wstring& msg) { Log(LOG_FATAL, msg); }

private:
    /**
     * @brief 获取当前时间戳字符串
     */
    std::wstring GetTimestamp() {
        auto now = std::chrono::system_clock::now();
        auto time = std::chrono::system_clock::to_time_t(now);

        std::tm tm;
#ifdef _WIN32
        localtime_s(&tm, &time);
#else
        localtime_r(&time, &tm);
#endif

        wchar_t buffer[32];
        wcsftime(buffer, 32, L"%Y-%m-%d %H:%M:%S", &tm);
        return buffer;
    }
};

// 便捷宏定义
#define SLJFP_LOG_DEBUG(msg)   SLJFP::Logger::Instance().Debug(msg)
#define SLJFP_LOG_INFO(msg)    SLJFP::Logger::Instance().Info(msg)
#define SLJFP_LOG_WARNING(msg) SLJFP::Logger::Instance().Warning(msg)
#define SLJFP_LOG_ERROR(msg)   SLJFP::Logger::Instance().Error(msg)
#define SLJFP_LOG_FATAL(msg)   SLJFP::Logger::Instance().Fatal(msg)

// Legacy aliases for backward compatibility
#define LJFP_LOG_DEBUG(msg)   SLJFP_LOG_DEBUG(msg)
#define LJFP_LOG_INFO(msg)    SLJFP_LOG_INFO(msg)
#define LJFP_LOG_WARNING(msg) SLJFP_LOG_WARNING(msg)
#define LJFP_LOG_ERROR(msg)   SLJFP_LOG_ERROR(msg)
#define LJFP_LOG_FATAL(msg)   SLJFP_LOG_FATAL(msg)

} // namespace SLJFP

#endif // SLJFP_LOGGER_H

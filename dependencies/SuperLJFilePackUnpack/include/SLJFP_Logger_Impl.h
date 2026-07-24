/**
 * @file SLJFP_Logger_Impl.h
 * @brief SuperLJFilePackUnpack 日志系统简化实现
 * @version 1.0
 * @date 2025-01-03
 */

#ifndef SLJFP_LOGGER_IMPL_H
#define SLJFP_LOGGER_IMPL_H

#include "SLJFP_Logger.h"
#include <iostream>
#include <fstream>
#include <ctime>

// 日志级别字符串
static const wchar_t* LOG_LEVEL_STRINGS[] = {
    L"DEBUG",
    L"INFO",
    L"WARNING",
    L"ERROR",
    L"FATAL"
};

// 全局日志输出流
static std::wofstream g_logFile;
static int g_minLogLevel = SLJFP::LOG_INFO;

// 初始化日志系统
inline void InitLogger(const std::wstring& logFilePath, int minLevel = SLJFP::LOG_INFO) {
    g_logFile.open(logFilePath, std::ios::app);
    g_minLogLevel = minLevel;
}

// 关闭日志系统
inline void CloseLogger() {
    if (g_logFile.is_open()) {
        g_logFile.close();
    }
}

// 记录日志
inline void LogMessage(int level, const std::wstring& message) {
    if (level < g_minLogLevel) return;

    // 获取时间戳
    time_t now = time(nullptr);
    struct tm timeinfo;
    wchar_t timestamp[64];

#ifdef _WIN32
    localtime_s(&timeinfo, &now);
#else
    localtime_r(&now, &timeinfo);
#endif

    wcsftime(timestamp, sizeof(timestamp)/sizeof(wchar_t), L"%Y-%m-%d %H:%M:%S", &timeinfo);

    // 构建日志消息
    std::wstring levelStr = LOG_LEVEL_STRINGS[level];
    std::wstring fullMessage = L"[" + std::wstring(timestamp) + L"] [" + levelStr + L"] " + message;

    // 输出到控制台
    std::wcout << fullMessage << std::endl;

    // 输出到文件
    if (g_logFile.is_open()) {
        g_logFile << fullMessage << std::endl;
        g_logFile.flush();
    }
}

#endif // SLJFP_LOGGER_IMPL_H

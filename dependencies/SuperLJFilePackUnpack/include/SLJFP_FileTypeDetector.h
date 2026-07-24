/**
 * @file SLJFP_FileTypeDetector.h
 * @brief 文件类型检测器 - 基于 Magic Number (文件头特征字节) 识别文件类型
 * @author SuperLJFilePackUnpack Project
 * @date 2026-01-04
 * @version 1.0
 *
 * 本模块用于解包时自动识别文件类型并添加正确的文件扩展名。
 * 由于 .ljpi 索引文件只保存 CRC32 而非原始路径，解包后的文件名默认为 CRC32 数字。
 * 通过 Magic Number 检测，可以自动为文件添加正确的扩展名。
 */

#pragma once
#ifndef SLJFP_FILE_TYPE_DETECTOR_H
#define SLJFP_FILE_TYPE_DETECTOR_H

#include <cstdint>
#include <cstddef>
#include <string>

namespace SLJFP {

/**
 * @class FileTypeDetector
 * @brief 文件类型检测器类
 *
 * 提供静态方法检测文件类型，无需实例化。
 *
 * 使用示例:
 * @code
 * std::vector<uint8_t> data = ReadFileData();
 * std::string ext = FileTypeDetector::DetectExtension(data.data(), data.size());
 * if (!ext.empty()) {
 *     filename += ext;  // 添加扩展名
 * }
 * @endcode
 */
class FileTypeDetector {
public:
    /**
     * @brief 文件类型信息结构
     */
    struct FileTypeInfo {
        const uint8_t* magic;      ///< Magic Number 字节序列
        size_t magicLen;           ///< Magic Number 长度
        size_t offset;             ///< 起始偏移 (通常为0)
        const char* extension;     ///< 文件扩展名 (包含点号)
        const char* mimeType;      ///< MIME 类型
        const char* description;   ///< 类型描述
    };

    /**
     * @brief 检测文件类型并返回对应扩展名
     * @param data 文件数据缓冲区
     * @param size 数据大小
     * @return 文件扩展名 (如 ".png", ".lua")，未知类型返回空字符串
     *
     * @note 扩展名包含点号前缀，可直接拼接到文件名后
     */
    static std::string DetectExtension(const uint8_t* data, size_t size);

    /**
     * @brief 检测文件类型并返回 MIME 类型
     * @param data 文件数据缓冲区
     * @param size 数据大小
     * @return MIME 类型 (如 "image/png")，未知类型返回 "application/octet-stream"
     */
    static std::string DetectMimeType(const uint8_t* data, size_t size);

    /**
     * @brief 检测文件类型并返回类型描述
     * @param data 文件数据缓冲区
     * @param size 数据大小
     * @return 类型描述 (如 "PNG Image")，未知类型返回 "Unknown Binary"
     */
    static std::string DetectDescription(const uint8_t* data, size_t size);

    /**
     * @brief 根据扩展名判断是否为文本文件
     * @param extension 文件扩展名 (包含点号)
     * @return true 如果是文本文件
     */
    static bool IsTextFile(const std::string& extension);

    /**
     * @brief 获取支持的文件类型数量
     * @return 支持的文件类型总数
     */
    static size_t GetSupportedTypeCount();

    /**
     * @brief 获取支持的所有扩展名列表 (用于调试/显示)
     * @return 逗号分隔的扩展名字符串
     */
    static std::string GetSupportedExtensions();

private:
    /**
     * @brief 获取文件类型信息表
     * @return 文件类型信息数组指针
     */
    static const FileTypeInfo* GetFileTypes();

    /**
     * @brief 获取文件类型信息表大小
     * @return 文件类型数量
     */
    static size_t GetFileTypeCount();

    /**
     * @brief 特殊处理 RIFF 格式 (区分 WAV 和 WEBP)
     * @param data 文件数据
     * @param size 数据大小
     * @return 扩展名，非 RIFF 格式返回空字符串
     */
    static std::string DetectRIFFSubtype(const uint8_t* data, size_t size);

    /**
     * @brief 检测文本类型文件 (JSON, XML without header, Lua source)
     * @param data 文件数据
     * @param size 数据大小
     * @return 扩展名，非文本格式返回空字符串
     */
    static std::string DetectTextType(const uint8_t* data, size_t size);
};

} // namespace SLJFP

#endif // SLJFP_FILE_TYPE_DETECTOR_H

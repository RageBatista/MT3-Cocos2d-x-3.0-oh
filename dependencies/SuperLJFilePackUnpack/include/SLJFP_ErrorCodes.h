/**
 * @file SLJFP_ErrorCodes.h
 * @brief SuperLJFilePackUnpack Error Code Definitions
 * @version 1.1
 * @date 2025-01-03
 *
 * Based on LJFilePack Reverse Engineering Implementation Plan Chapter 12
 *
 * Note: Error codes use LJFP_ERR_ prefix to avoid conflicts with Windows macros
 */

#ifndef SLJFP_ERRORCODES_H
#define SLJFP_ERRORCODES_H

namespace SLJFP {

/**
 * @brief Error code enumeration
 *
 * Error code ranges:
 * - 0: Success
 * - 1xx: File operation errors
 * - 2xx: Index errors
 * - 3xx: Decryption errors
 * - 4xx: Decompression errors
 * - 5xx: CRC32 errors
 * - 6xx: Pack file errors
 * - 7xx: Memory errors
 * - 8xx: User operations
 * - 9xx: Unknown errors
 */
enum ErrorCode {
    // Success
    LJFP_SUCCESS = 0,

    // File operation errors (1xx)
    LJFP_ERR_FILE_NOT_FOUND = 100,
    LJFP_ERR_FILE_OPEN_FAILED = 101,
    LJFP_ERR_FILE_READ_FAILED = 102,
    LJFP_ERR_FILE_WRITE_FAILED = 103,
    LJFP_ERR_FILE_SEEK_FAILED = 104,
    LJFP_ERR_FILE_CREATE_FAILED = 105,
    LJFP_ERR_DIRECTORY_CREATE_FAILED = 106,
    LJFP_ERR_PERMISSION_DENIED = 107,
    LJFP_ERR_DISK_FULL = 108,
    LJFP_ERR_INVALID_INDEX = 109,
    LJFP_ERR_PARTIAL_FAILURE = 110,

    // Index errors (2xx)
    LJFP_ERR_INDEX_NOT_FOUND = 200,
    LJFP_ERR_INDEX_INVALID_FORMAT = 201,
    LJFP_ERR_INDEX_VERSION_MISMATCH = 202,
    LJFP_ERR_INDEX_CORRUPTED = 203,
    LJFP_ERR_INDEX_DECRYPT_FAILED = 204,
    LJFP_ERR_INDEX_DECOMPRESS_FAILED = 205,

    // Decryption errors (3xx)
    LJFP_ERR_DECRYPT_INVALID_KEY = 300,
    LJFP_ERR_DECRYPT_INVALID_DATA = 301,
    LJFP_ERR_DECRYPT_BLOCK_SIZE = 302,
    LJFP_ERR_DECRYPT_MEMORY = 303,
    LJFP_ERR_DECRYPT_FAILED = 304,

    // Decompression errors (4xx)
    LJFP_ERR_DECOMPRESS_DATA_CORRUPT = 400,
    LJFP_ERR_DECOMPRESS_BUFFER_OVERFLOW = 401,
    LJFP_ERR_DECOMPRESS_MEMORY = 402,
    LJFP_ERR_DECOMPRESS_TOO_LARGE = 403,
    LJFP_ERR_DECOMPRESS_UNKNOWN = 404,
    LJFP_ERR_DECOMPRESS_FAILED = 405,

    // CRC32 errors (5xx)
    LJFP_ERR_CRC32_MISMATCH = 500,
    LJFP_ERR_CRC32_ORIGINAL_MISMATCH = 501,

    // Pack file errors (6xx)
    LJFP_ERR_PACK_NOT_FOUND = 600,
    LJFP_ERR_PACK_INVALID_FORMAT = 601,
    LJFP_ERR_PACK_SEEK_OUT_OF_RANGE = 602,
    LJFP_ERR_PACK_SIZE_MISMATCH = 603,

    // Memory errors (7xx)
    LJFP_ERR_MEMORY_ALLOCATION = 700,
    LJFP_ERR_MEMORY_OVERFLOW = 701,

    // User operations (8xx)
    LJFP_ERR_USER_CANCELLED = 800,

    // Unknown errors (9xx)
    LJFP_ERR_UNKNOWN = 999
};

/**
 * @brief Get error message for error code
 * @param code Error code
 * @return Error message string
 */
inline const wchar_t* GetErrorMessage(ErrorCode code) {
    switch (code) {
        // Success
        case LJFP_SUCCESS: return L"Operation successful";

        // File operation errors
        case LJFP_ERR_FILE_NOT_FOUND: return L"File not found";
        case LJFP_ERR_FILE_OPEN_FAILED: return L"Failed to open file";
        case LJFP_ERR_FILE_READ_FAILED: return L"File read failed";
        case LJFP_ERR_FILE_WRITE_FAILED: return L"File write failed";
        case LJFP_ERR_FILE_SEEK_FAILED: return L"File seek failed";
        case LJFP_ERR_FILE_CREATE_FAILED: return L"Failed to create file";
        case LJFP_ERR_DIRECTORY_CREATE_FAILED: return L"Failed to create directory";
        case LJFP_ERR_PERMISSION_DENIED: return L"Permission denied";
        case LJFP_ERR_DISK_FULL: return L"Disk full";
        case LJFP_ERR_INVALID_INDEX: return L"Invalid index";
        case LJFP_ERR_PARTIAL_FAILURE: return L"Some files failed to unpack";

        // Index errors
        case LJFP_ERR_INDEX_NOT_FOUND: return L"Index file not found (.ljpi or .ljzip)";
        case LJFP_ERR_INDEX_INVALID_FORMAT: return L"Invalid index file format";
        case LJFP_ERR_INDEX_VERSION_MISMATCH: return L"Index file version mismatch";
        case LJFP_ERR_INDEX_CORRUPTED: return L"Index file corrupted";
        case LJFP_ERR_INDEX_DECRYPT_FAILED: return L"Failed to decrypt index file";
        case LJFP_ERR_INDEX_DECOMPRESS_FAILED: return L"Failed to decompress index file";

        // Decryption errors
        case LJFP_ERR_DECRYPT_INVALID_KEY: return L"Invalid decryption key";
        case LJFP_ERR_DECRYPT_INVALID_DATA: return L"Invalid encrypted data";
        case LJFP_ERR_DECRYPT_BLOCK_SIZE: return L"Encryption block size error";
        case LJFP_ERR_DECRYPT_MEMORY: return L"Memory allocation failed during decryption";
        case LJFP_ERR_DECRYPT_FAILED: return L"Decryption failed";

        // Decompression errors
        case LJFP_ERR_DECOMPRESS_DATA_CORRUPT: return L"Compressed data corrupted";
        case LJFP_ERR_DECOMPRESS_BUFFER_OVERFLOW: return L"Decompression buffer overflow";
        case LJFP_ERR_DECOMPRESS_MEMORY: return L"Memory allocation failed during decompression";
        case LJFP_ERR_DECOMPRESS_TOO_LARGE: return L"Decompressed data too large";
        case LJFP_ERR_DECOMPRESS_UNKNOWN: return L"Unknown decompression error";
        case LJFP_ERR_DECOMPRESS_FAILED: return L"Decompression failed";

        // CRC32 errors
        case LJFP_ERR_CRC32_MISMATCH: return L"CRC32 checksum mismatch";
        case LJFP_ERR_CRC32_ORIGINAL_MISMATCH: return L"Original data CRC32 checksum mismatch";

        // Pack file errors
        case LJFP_ERR_PACK_NOT_FOUND: return L"Pack file not found";
        case LJFP_ERR_PACK_INVALID_FORMAT: return L"Invalid pack file format";
        case LJFP_ERR_PACK_SEEK_OUT_OF_RANGE: return L"Pack file seek out of range";
        case LJFP_ERR_PACK_SIZE_MISMATCH: return L"Pack file size mismatch";

        // Memory errors
        case LJFP_ERR_MEMORY_ALLOCATION: return L"Memory allocation failed";
        case LJFP_ERR_MEMORY_OVERFLOW: return L"Memory overflow";

        // User operations
        case LJFP_ERR_USER_CANCELLED: return L"Operation cancelled by user";

        // Unknown errors
        default: return L"Unknown error";
    }
}

// Legacy error code aliases for backward compatibility
// These use the new LJFP_ERR_ prefix internally
const int LJFP_ERROR_FILE_NOT_FOUND = LJFP_ERR_FILE_NOT_FOUND;
const int LJFP_ERROR_FILE_OPEN_FAILED = LJFP_ERR_FILE_OPEN_FAILED;
const int LJFP_ERROR_FILE_READ_FAILED = LJFP_ERR_FILE_READ_FAILED;
const int LJFP_ERROR_FILE_CREATE_FAILED = LJFP_ERR_FILE_CREATE_FAILED;
const int LJFP_ERROR_FILE_WRITE_FAILED = LJFP_ERR_FILE_WRITE_FAILED;
const int LJFP_ERROR_INVALID_INDEX = LJFP_ERR_INVALID_INDEX;
const int LJFP_ERROR_PARTIAL_FAILURE = LJFP_ERR_PARTIAL_FAILURE;
const int LJFP_ERROR_INDEX_NOT_FOUND = LJFP_ERR_INDEX_NOT_FOUND;
const int LJFP_ERROR_INDEX_INVALID_FORMAT = LJFP_ERR_INDEX_INVALID_FORMAT;
const int LJFP_ERROR_INDEX_CORRUPTED = LJFP_ERR_INDEX_CORRUPTED;
const int LJFP_ERROR_INDEX_DECOMPRESS_FAILED = LJFP_ERR_INDEX_DECOMPRESS_FAILED;
const int LJFP_ERROR_DECRYPT_FAILED = LJFP_ERR_DECRYPT_FAILED;
const int LJFP_ERROR_DECOMPRESS_FAILED = LJFP_ERR_DECOMPRESS_FAILED;
const int LJFP_ERROR_DECOMPRESS_TOO_LARGE = LJFP_ERR_DECOMPRESS_TOO_LARGE;
const int LJFP_ERROR_CRC32_MISMATCH = LJFP_ERR_CRC32_MISMATCH;
const int LJFP_ERROR_PACK_NOT_FOUND = LJFP_ERR_PACK_NOT_FOUND;
const int LJFP_ERROR_USER_CANCELLED = LJFP_ERR_USER_CANCELLED;

} // namespace SLJFP

#endif // SLJFP_ERRORCODES_H

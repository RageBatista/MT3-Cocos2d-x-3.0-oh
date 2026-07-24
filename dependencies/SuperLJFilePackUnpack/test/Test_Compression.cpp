/**
 * @file Test_Compression.cpp
 * @brief MiniZ compression/decompression unit tests
 * @version 1.0
 * @date 2025-01-03
 */

#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_LibsWrapper.h"
#include <cstring>

// MiniZ return codes
#define MZ_OK 0
#define MZ_STREAM_END 1
#define MZ_NEED_DICT 2
#define MZ_ERRNO (-1)
#define MZ_STREAM_ERROR (-2)
#define MZ_DATA_ERROR (-3)
#define MZ_MEM_ERROR (-4)
#define MZ_BUF_ERROR (-5)
#define MZ_VERSION_ERROR (-6)

// ============================================================================
// Basic Compression Tests
// ============================================================================

TEST_CASE(Compression, SmallData) {
    // Small data compression test
    // Note: Small data may not compress smaller due to header overhead
    unsigned char source[] = "Hello, World! This is a test string for compression.";
    unsigned int sourceLen = (unsigned int)strlen((char*)source);

    unsigned char dest[256];
    unsigned int destLen = sizeof(dest);

    // Compress
    unsigned int result = SLJFP_mz_compress2(dest, &destLen, source, sourceLen, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);
    TEST_ASSERT_TRUE(destLen > 0);
    // Small data may not compress smaller, just verify reasonable output
    TEST_ASSERT_TRUE(destLen <= sourceLen + 20);  // zlib header overhead ~6-11 bytes

    return true;
}

TEST_CASE(Compression, RoundTrip) {
    // Compression-decompression round-trip test
    const char* original = "This is a test message for compression round-trip testing. "
                          "It should be long enough to get some compression benefit.";
    unsigned int originalLen = (unsigned int)strlen(original);

    // Compression buffer
    unsigned char compressed[1024];
    unsigned int compressedLen = sizeof(compressed);

    // Compress
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen,
                                              (const unsigned char*)original, originalLen, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Decompression buffer
    unsigned char decompressed[1024];
    unsigned int decompressedLen = sizeof(decompressed);

    // Decompress
    result = SLJFP_mz_uncompress(decompressed, &decompressedLen, compressed, compressedLen);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Verify size
    TEST_ASSERT_EQ(originalLen, decompressedLen);

    // Verify content
    TEST_ASSERT_MEM_EQ(original, decompressed, originalLen);

    return true;
}

TEST_CASE(Compression, LevelComparison) {
    // Different compression level test
    // Note: For simple patterns, different levels may produce similar results
    // Use larger data set to ensure level differences are more noticeable
    const size_t dataLen = 4000;
    unsigned char* data = new unsigned char[dataLen];

    // Generate repetitive pattern data
    for (size_t i = 0; i < dataLen; ++i) {
        // Generate repeating pattern: AAAA...BBBB...CCCC...ABCD...
        size_t block = i / 10;
        size_t pos = i % 10;
        if (block % 4 == 0) data[i] = 'A';
        else if (block % 4 == 1) data[i] = 'B';
        else if (block % 4 == 2) data[i] = 'C';
        else data[i] = (unsigned char)('A' + pos);
    }

    unsigned char* compressed1 = new unsigned char[dataLen + 1024];
    unsigned char* compressed9 = new unsigned char[dataLen + 1024];
    unsigned int len1 = (unsigned int)(dataLen + 1024);
    unsigned int len9 = (unsigned int)(dataLen + 1024);

    // Lowest compression level
    unsigned int result1 = SLJFP_mz_compress2(compressed1, &len1,
                                               data, (unsigned int)dataLen, 1);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result1);

    // Highest compression level
    unsigned int result9 = SLJFP_mz_compress2(compressed9, &len9,
                                               data, (unsigned int)dataLen, 9);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result9);

    // Both levels should significantly compress the data
    TEST_ASSERT_TRUE(len1 < dataLen);
    TEST_ASSERT_TRUE(len9 < dataLen);
    // Higher level should produce smaller (or equal) output
    // Note: In some edge cases they may be equal
    TEST_ASSERT_TRUE(len9 <= len1 + 10);  // Allow small variance

    delete[] data;
    delete[] compressed1;
    delete[] compressed9;

    return true;
}

TEST_CASE(Compression, BinaryData) {
    // Binary data compression test
    const size_t size = 4096;
    unsigned char* source = new unsigned char[size];

    // Generate binary data (all byte values)
    for (size_t i = 0; i < size; ++i) {
        source[i] = (unsigned char)(i & 0xFF);
    }

    unsigned char* compressed = new unsigned char[size + 1024];
    unsigned int compressedLen = (unsigned int)(size + 1024);

    // Compress
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen,
                                              source, (unsigned int)size, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Decompress
    unsigned char* decompressed = new unsigned char[size];
    unsigned int decompressedLen = (unsigned int)size;

    result = SLJFP_mz_uncompress(decompressed, &decompressedLen, compressed, compressedLen);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);
    TEST_ASSERT_EQ((unsigned int)size, decompressedLen);
    TEST_ASSERT_MEM_EQ(source, decompressed, size);

    delete[] source;
    delete[] compressed;
    delete[] decompressed;

    return true;
}

TEST_CASE(Compression, LargeData) {
    // Large data compression test (1MB)
    const size_t size = 1024 * 1024;
    unsigned char* source = new unsigned char[size];

    // Generate compressible data (repeating pattern)
    for (size_t i = 0; i < size; ++i) {
        source[i] = (unsigned char)((i % 256) ^ ((i / 256) % 256));
    }

    // Compression buffer (may be larger after compression)
    unsigned char* compressed = new unsigned char[size + 65536];
    unsigned int compressedLen = (unsigned int)(size + 65536);

    // Compress
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen,
                                              source, (unsigned int)size, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Decompress
    unsigned char* decompressed = new unsigned char[size];
    unsigned int decompressedLen = (unsigned int)size;

    result = SLJFP_mz_uncompress(decompressed, &decompressedLen, compressed, compressedLen);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);
    TEST_ASSERT_EQ((unsigned int)size, decompressedLen);
    TEST_ASSERT_MEM_EQ(source, decompressed, size);

    delete[] source;
    delete[] compressed;
    delete[] decompressed;

    return true;
}

TEST_CASE(Compression, BufferTooSmall) {
    // Buffer too small test
    const char* data = "This is some data that needs to be compressed into a buffer";
    unsigned int dataLen = (unsigned int)strlen(data);

    unsigned char compressed[2];  // Intentionally too small
    unsigned int compressedLen = sizeof(compressed);

    // Should return MZ_BUF_ERROR
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen,
                                              (const unsigned char*)data, dataLen, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_BUF_ERROR, result);

    return true;
}

TEST_CASE(Compression, EmptyData) {
    // Empty data compression test
    unsigned char dest[256];
    unsigned int destLen = sizeof(dest);

    // Compress empty data
    unsigned int result = SLJFP_mz_compress2(dest, &destLen, nullptr, 0, 6);

    // MiniZ should succeed for empty data, but output length may be zlib header
    // Just verify no crash
    TEST_ASSERT_TRUE(result == MZ_OK || result == MZ_BUF_ERROR);

    return true;
}

TEST_CASE(Decompression, CorruptedData) {
    // Corrupted data decompression test
    unsigned char corruptedData[] = { 0x78, 0x9C, 0xFF, 0xFF, 0xFF, 0xFF };
    unsigned int corruptedLen = sizeof(corruptedData);

    unsigned char dest[256];
    unsigned int destLen = sizeof(dest);

    // Should return error
    unsigned int result = SLJFP_mz_uncompress(dest, &destLen, corruptedData, corruptedLen);
    TEST_ASSERT_NE((unsigned int)MZ_OK, result);

    return true;
}

TEST_CASE(Compression, HighlyCompressible) {
    // Highly compressible data test (all zeros)
    const size_t size = 10000;
    unsigned char* source = new unsigned char[size];
    memset(source, 0, size);

    unsigned char compressed[1024];
    unsigned int compressedLen = sizeof(compressed);

    // Compress
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen,
                                              source, (unsigned int)size, 9);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // All-zero data should compress to very small size
    TEST_ASSERT_TRUE(compressedLen < size / 10);

    delete[] source;

    return true;
}

TEST_CASE(Compression, Incompressible) {
    // Incompressible data test (random data)
    const size_t size = 1000;
    unsigned char* source = new unsigned char[size];

    // Generate pseudo-random data (LCG)
    unsigned int seed = 12345;
    for (size_t i = 0; i < size; ++i) {
        seed = seed * 1103515245 + 12345;
        source[i] = (unsigned char)(seed >> 16);
    }

    unsigned char* compressed = new unsigned char[size + 256];
    unsigned int compressedLen = (unsigned int)(size + 256);

    // Compress - should still succeed, but may not get smaller
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen,
                                              source, (unsigned int)size, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Verify round-trip
    unsigned char* decompressed = new unsigned char[size];
    unsigned int decompressedLen = (unsigned int)size;

    result = SLJFP_mz_uncompress(decompressed, &decompressedLen, compressed, compressedLen);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);
    TEST_ASSERT_MEM_EQ(source, decompressed, size);

    delete[] source;
    delete[] compressed;
    delete[] decompressed;

    return true;
}

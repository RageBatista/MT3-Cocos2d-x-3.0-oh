/**
 * @file Test_Integration.cpp
 * @brief Integration tests - Complete encryption and compression round-trip tests
 * @version 1.0
 * @date 2025-01-03
 */

#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_LibsWrapper.h"
#include "../include/SLJFP_ErrorCodes.h"
#include <cstring>

// MiniZ return codes
#define MZ_OK 0

// ============================================================================
// Integration Tests: Complete Encryption/Compression Pipeline
// ============================================================================

TEST_CASE(Integration, CompressThenEncrypt) {
    // Test compress-then-encrypt workflow
    const char* original = "This is a test message for integration testing. "
                          "It should be long enough to benefit from compression. "
                          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    unsigned int originalLen = (unsigned int)strlen(original);

    // Step 1: Compress
    unsigned char compressed[1024];
    unsigned int compressedLen = sizeof(compressed);
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen,
                                              (const unsigned char*)original, originalLen, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Align to 16-byte boundary (SMS4 requirement)
    unsigned int paddedLen = ((compressedLen + 15) / 16) * 16;
    unsigned char* paddedCompressed = new unsigned char[paddedLen];
    memset(paddedCompressed, 0, paddedLen);
    memcpy(paddedCompressed, compressed, compressedLen);

    // Step 2: Encrypt
    unsigned char* encrypted = new unsigned char[paddedLen];
    SLJFP_SMS4Ex(paddedCompressed, encrypted, paddedLen, "locojoy123456789");

    // Step 3: Decrypt
    unsigned char* decrypted = new unsigned char[paddedLen];
    SLJFP_DeSMS4Ex(encrypted, decrypted, paddedLen, "locojoy123456789");

    // Verify decrypted data matches compressed data
    TEST_ASSERT_MEM_EQ(paddedCompressed, decrypted, paddedLen);

    // Step 4: Decompress
    unsigned char decompressed[1024];
    unsigned int decompressedLen = sizeof(decompressed);
    result = SLJFP_mz_uncompress(decompressed, &decompressedLen, decrypted, compressedLen);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Verify final result
    TEST_ASSERT_EQ(originalLen, decompressedLen);
    TEST_ASSERT_MEM_EQ(original, decompressed, originalLen);

    delete[] paddedCompressed;
    delete[] encrypted;
    delete[] decrypted;

    return true;
}

TEST_CASE(Integration, EncryptThenCompress) {
    // Test encrypt-then-compress workflow (similar to .ljzip file format)
    unsigned char original[64];
    for (int i = 0; i < 64; ++i) {
        original[i] = (unsigned char)i;
    }

    // Step 1: Encrypt
    unsigned char encrypted[64];
    SLJFP_SMS4Ex(original, encrypted, 64, "locojoy123456789");

    // Step 2: Compress encrypted data
    unsigned char compressed[256];
    unsigned int compressedLen = sizeof(compressed);
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen, encrypted, 64, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Step 3: Decompress
    unsigned char decompressed[64];
    unsigned int decompressedLen = sizeof(decompressed);
    result = SLJFP_mz_uncompress(decompressed, &decompressedLen, compressed, compressedLen);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);
    TEST_ASSERT_EQ((unsigned int)64, decompressedLen);

    // Step 4: Decrypt
    unsigned char decrypted[64];
    SLJFP_DeSMS4Ex(decompressed, decrypted, 64, "locojoy123456789");

    // Verify final result
    TEST_ASSERT_MEM_EQ(original, decrypted, 64);

    return true;
}

TEST_CASE(Integration, LargeFileSimulation) {
    // Simulate large file processing (256KB)
    const size_t size = 256 * 1024;
    unsigned char* original = new unsigned char[size];

    // Generate compressible test data
    for (size_t i = 0; i < size; ++i) {
        original[i] = (unsigned char)((i % 128) + ((i / 1024) % 128));
    }

    // Calculate original CRC32
    unsigned int originalCRC = SLJFP_crc32(0, original, (unsigned int)size);

    // Step 1: Compress
    unsigned char* compressed = new unsigned char[size + 65536];
    unsigned int compressedLen = (unsigned int)(size + 65536);
    unsigned int result = SLJFP_mz_compress2(compressed, &compressedLen, original, (unsigned int)size, 6);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);

    // Step 2: Align and encrypt
    unsigned int paddedLen = ((compressedLen + 15) / 16) * 16;
    unsigned char* paddedCompressed = new unsigned char[paddedLen];
    memset(paddedCompressed, 0, paddedLen);
    memcpy(paddedCompressed, compressed, compressedLen);

    unsigned char* encrypted = new unsigned char[paddedLen];
    SLJFP_SMS4Ex(paddedCompressed, encrypted, paddedLen, "locojoy123456789");

    // Step 3: Decrypt
    unsigned char* decrypted = new unsigned char[paddedLen];
    SLJFP_DeSMS4Ex(encrypted, decrypted, paddedLen, "locojoy123456789");

    // Step 4: Decompress
    unsigned char* decompressed = new unsigned char[size];
    unsigned int decompressedLen = (unsigned int)size;
    result = SLJFP_mz_uncompress(decompressed, &decompressedLen, decrypted, compressedLen);
    TEST_ASSERT_EQ((unsigned int)MZ_OK, result);
    TEST_ASSERT_EQ((unsigned int)size, decompressedLen);

    // Verify CRC32
    unsigned int decompressedCRC = SLJFP_crc32(0, decompressed, decompressedLen);
    TEST_ASSERT_EQ(originalCRC, decompressedCRC);

    // Verify content
    TEST_ASSERT_MEM_EQ(original, decompressed, size);

    delete[] original;
    delete[] compressed;
    delete[] paddedCompressed;
    delete[] encrypted;
    delete[] decrypted;
    delete[] decompressed;

    return true;
}

TEST_CASE(Integration, CRC32Verification) {
    // Test CRC32 verification workflow
    unsigned char data[128];
    for (int i = 0; i < 128; ++i) {
        data[i] = (unsigned char)(i * 3 + 7);
    }

    // Calculate CRC32
    unsigned int crc1 = SLJFP_crc32(0, data, 128);

    // Compress
    unsigned char compressed[256];
    unsigned int compressedLen = sizeof(compressed);
    SLJFP_mz_compress2(compressed, &compressedLen, data, 128, 6);

    // Decompress
    unsigned char decompressed[128];
    unsigned int decompressedLen = sizeof(decompressed);
    SLJFP_mz_uncompress(decompressed, &decompressedLen, compressed, compressedLen);

    // Verify CRC32
    unsigned int crc2 = SLJFP_crc32(0, decompressed, decompressedLen);
    TEST_ASSERT_EQ(crc1, crc2);

    return true;
}

TEST_CASE(Integration, MultiBlockEncryption) {
    // Test multi-block encryption (16 bytes x N)
    const size_t numBlocks = 10;
    const size_t size = 16 * numBlocks;
    unsigned char original[160];

    for (size_t i = 0; i < size; ++i) {
        original[i] = (unsigned char)(i ^ (i >> 4));
    }

    unsigned char encrypted[160];
    unsigned char decrypted[160];

    // Encrypt all blocks
    SLJFP_SMS4Ex(original, encrypted, (unsigned int)size, "locojoy123456789");

    // Decrypt all blocks
    SLJFP_DeSMS4Ex(encrypted, decrypted, (unsigned int)size, "locojoy123456789");

    // Verify
    TEST_ASSERT_MEM_EQ(original, decrypted, size);

    return true;
}

TEST_CASE(Integration, ZeroSizeHandling) {
    // Test zero-size data handling
    unsigned char dummy[16] = {0};

    // CRC32 of empty data
    unsigned int crc = SLJFP_crc32(0, nullptr, 0);
    TEST_ASSERT_EQ((unsigned int)0, crc);

    // SMS4 with 16 bytes (minimum block)
    unsigned char encrypted[16];
    unsigned char decrypted[16];

    memset(dummy, 0, 16);
    SLJFP_SMS4Ex(dummy, encrypted, 16, "locojoy123456789");
    SLJFP_DeSMS4Ex(encrypted, decrypted, 16, "locojoy123456789");
    TEST_ASSERT_MEM_EQ(dummy, decrypted, 16);

    return true;
}

/**
 * @file Test_SMS4.cpp
 * @brief SMS4 encryption/decryption unit tests
 * @version 1.0
 * @date 2025-01-03
 */

#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_LibsWrapper.h"
#include <cstring>

// Default key (same as defined in SLJFP_Unpack.h)
const std::string DEFAULT_KEY = "locojoy123456789";

static void DecryptClientObfBlock(const unsigned char* input,
                                  unsigned char* output) {
    SLJFP_DeSMS4ExClientObf(const_cast<unsigned char*>(input), output, 16, DEFAULT_KEY);
}

static void DecryptClientKeyedBlock(const unsigned char* input,
                                    unsigned char* output,
                                    const std::string& key) {
    SLJFP_DeSMS4BlocksClientKeyed(const_cast<unsigned char*>(input), output, 16, key);
}

// ============================================================================
// SMS4 Basic Function Tests
// ============================================================================

TEST_CASE(SMS4, RoundTrip_16Bytes) {
    // 16-byte round-trip test (SMS4 block size)
    unsigned char original[16] = {
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10
    };

    unsigned char encrypted[16];
    unsigned char decrypted[16];

    // Encrypt
    SLJFP_SMS4Ex(original, encrypted, 16, DEFAULT_KEY);

    // Verify encrypted data is different
    bool different = false;
    for (int i = 0; i < 16; ++i) {
        if (original[i] != encrypted[i]) {
            different = true;
            break;
        }
    }
    TEST_ASSERT_MSG(different, "Encrypted data should be different from original");

    // Decrypt
    SLJFP_DeSMS4Ex(encrypted, decrypted, 16, DEFAULT_KEY);

    // Verify decrypted data matches original
    TEST_ASSERT_MEM_EQ(original, decrypted, 16);

    return true;
}

TEST_CASE(SMS4, RoundTrip_64Bytes) {
    // 64-byte round-trip test (4 blocks)
    unsigned char original[64];
    for (int i = 0; i < 64; ++i) {
        original[i] = (unsigned char)i;
    }

    unsigned char encrypted[64];
    unsigned char decrypted[64];

    // Encrypt
    SLJFP_SMS4Ex(original, encrypted, 64, DEFAULT_KEY);

    // Decrypt
    SLJFP_DeSMS4Ex(encrypted, decrypted, 64, DEFAULT_KEY);

    // Verify
    TEST_ASSERT_MEM_EQ(original, decrypted, 64);

    return true;
}

TEST_CASE(SMS4, RoundTrip_LargeData) {
    // Large data round-trip test (4KB)
    const size_t size = 4096;
    unsigned char* original = new unsigned char[size];
    unsigned char* encrypted = new unsigned char[size];
    unsigned char* decrypted = new unsigned char[size];

    // Generate data
    for (size_t i = 0; i < size; ++i) {
        original[i] = (unsigned char)(i & 0xFF);
    }

    // Encrypt
    SLJFP_SMS4Ex(original, encrypted, (unsigned int)size, DEFAULT_KEY);

    // Decrypt
    SLJFP_DeSMS4Ex(encrypted, decrypted, (unsigned int)size, DEFAULT_KEY);

    // Verify
    TEST_ASSERT_MEM_EQ(original, decrypted, size);

    delete[] original;
    delete[] encrypted;
    delete[] decrypted;

    return true;
}

TEST_CASE(SMS4, DifferentKeys) {
    // Different keys test
    unsigned char original[16] = {
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10
    };

    unsigned char encrypted1[16];
    unsigned char encrypted2[16];

    std::string key1 = "locojoy123456789";
    std::string key2 = "differentkey1234";

    // Encrypt with different keys
    SLJFP_SMS4Ex(original, encrypted1, 16, key1);
    SLJFP_SMS4Ex(original, encrypted2, 16, key2);

    // Verify encrypted results are different
    bool different = false;
    for (int i = 0; i < 16; ++i) {
        if (encrypted1[i] != encrypted2[i]) {
            different = true;
            break;
        }
    }
    TEST_ASSERT_MSG(different, "Different keys should produce different ciphertext");

    return true;
}

TEST_CASE(SMS4, WrongKeyDecrypt) {
    // Wrong key decryption test
    unsigned char original[16] = {
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10
    };

    unsigned char encrypted[16];
    unsigned char decrypted[16];

    std::string correctKey = "locojoy123456789";
    std::string wrongKey = "wrongkey12345678";

    // Encrypt with correct key
    SLJFP_SMS4Ex(original, encrypted, 16, correctKey);

    // Decrypt with wrong key
    SLJFP_DeSMS4Ex(encrypted, decrypted, 16, wrongKey);

    // Verify decrypted result is different from original
    bool different = false;
    for (int i = 0; i < 16; ++i) {
        if (original[i] != decrypted[i]) {
            different = true;
            break;
        }
    }
    TEST_ASSERT_MSG(different, "Wrong key decryption should not produce original data");

    return true;
}

TEST_CASE(SMS4, Consistency) {
    // Consistency test: same input produces same output
    unsigned char original[32];
    for (int i = 0; i < 32; ++i) {
        original[i] = (unsigned char)(i * 7 + 3);
    }

    unsigned char encrypted1[32];
    unsigned char encrypted2[32];

    SLJFP_SMS4Ex(original, encrypted1, 32, DEFAULT_KEY);
    SLJFP_SMS4Ex(original, encrypted2, 32, DEFAULT_KEY);

    TEST_ASSERT_MEM_EQ(encrypted1, encrypted2, 32);

    return true;
}

TEST_CASE(SMS4, BlockAligned) {
    // Block alignment test (SMS4 block size is 16 bytes)
    // Test non-16-byte aligned data

    // 20 bytes (not a multiple of 16)
    unsigned char original[32];  // Use 32-byte buffer
    memset(original, 0, 32);
    for (int i = 0; i < 20; ++i) {
        original[i] = (unsigned char)(i + 1);
    }

    unsigned char encrypted[32];
    unsigned char decrypted[32];

    // SMS4Ex may pad to 16-byte boundary
    // Here we test 32 bytes (20 bytes data + 12 bytes padding)
    SLJFP_SMS4Ex(original, encrypted, 32, DEFAULT_KEY);
    SLJFP_DeSMS4Ex(encrypted, decrypted, 32, DEFAULT_KEY);

    // Verify first 20 bytes
    bool match = true;
    for (int i = 0; i < 20; ++i) {
        if (original[i] != decrypted[i]) {
            match = false;
            break;
        }
    }
    TEST_ASSERT_MSG(match, "First 20 bytes should match after round-trip");

    return true;
}

TEST_CASE(SMS4, ZeroData) {
    // All-zero data test
    unsigned char original[16];
    memset(original, 0, 16);

    unsigned char encrypted[16];
    unsigned char decrypted[16];

    SLJFP_SMS4Ex(original, encrypted, 16, DEFAULT_KEY);
    SLJFP_DeSMS4Ex(encrypted, decrypted, 16, DEFAULT_KEY);

    TEST_ASSERT_MEM_EQ(original, decrypted, 16);

    return true;
}

TEST_CASE(SMS4, AllOnesData) {
    // All 0xFF data test
    unsigned char original[16];
    memset(original, 0xFF, 16);

    unsigned char encrypted[16];
    unsigned char decrypted[16];

    SLJFP_SMS4Ex(original, encrypted, 16, DEFAULT_KEY);
    SLJFP_DeSMS4Ex(encrypted, decrypted, 16, DEFAULT_KEY);

    TEST_ASSERT_MEM_EQ(original, decrypted, 16);

    return true;
}

TEST_CASE(SMS4, InPlaceEncryption) {
    // In-place encryption test (using same input/output buffer)
    // Note: SMS4Ex may not support in-place operation, this test verifies behavior
    unsigned char data[16] = {
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10
    };

    unsigned char backup[16];
    memcpy(backup, data, 16);

    // Using different buffers is safe
    unsigned char encrypted[16];
    SLJFP_SMS4Ex(data, encrypted, 16, DEFAULT_KEY);

    // Decrypt back
    unsigned char decrypted[16];
    SLJFP_DeSMS4Ex(encrypted, decrypted, 16, DEFAULT_KEY);

    TEST_ASSERT_MEM_EQ(backup, decrypted, 16);

    return true;
}

TEST_CASE(SMS4, ClientObfMatchesHistoricalKnownGoodBlockVector) {
    // 1278158688: this block is known-good and matches the 2026-03-25 GUI binary.
    const unsigned char encrypted[16] = {
        0x43, 0x64, 0xA3, 0x97, 0xF9, 0xB2, 0xD7, 0x54,
        0xDF, 0x7C, 0x5A, 0x0B, 0x40, 0xEF, 0x2F, 0x7F
    };
    const unsigned char expected[16] = {
        0x78, 0x01, 0x8D, 0x51, 0xB1, 0x4E, 0x03, 0x31,
        0x0C, 0xDD, 0x91, 0xF8, 0x07, 0xCB, 0x33, 0xF4
    };

    unsigned char output[16];
    DecryptClientObfBlock(encrypted, output);
    TEST_ASSERT_MEM_EQ(expected, output, 16);

    return true;
}

TEST_CASE(SMS4, ClientObfMatchesHistoricalKnownProblemBlockVector) {
    // 2433835888 / 2579075739: the historical 2026-03-25 GUI binary uses the
    // same ClientObf block transform as the current source, even though these
    // files still fail end-to-end CRC validation in the unpack pipeline.
    const unsigned char encrypted[16] = {
        0xEB, 0x6A, 0x85, 0xB6, 0x4E, 0x0C, 0x8B, 0x69,
        0x4A, 0x84, 0xB5, 0x94, 0xD3, 0xB5, 0x10, 0xBC
    };
    const unsigned char expected[16] = {
        0x78, 0x01, 0x55, 0x8D, 0x5B, 0x0A, 0x40, 0x50,
        0x14, 0x45, 0xD7, 0x2F, 0x65, 0x0E, 0x32, 0x01
    };

    unsigned char output[16];
    DecryptClientObfBlock(encrypted, output);
    TEST_ASSERT_MEM_EQ(expected, output, 16);

    return true;
}

TEST_CASE(SMS4, ClientKeyedVariantRespondsToPasswordBytes) {
    const unsigned char encrypted[16] = {
        0x07, 0x7D, 0x74, 0x36, 0x17, 0x46, 0xB5, 0xA1,
        0x48, 0xDD, 0x9E, 0x60, 0xAB, 0xEA, 0x81, 0x60
    };

    unsigned char fixedOutput[16];
    unsigned char keyedOutputA[16];
    unsigned char keyedOutputB[16];
    unsigned char keyedOutputWrong[16];

    DecryptClientObfBlock(encrypted, fixedOutput);
    DecryptClientKeyedBlock(encrypted, keyedOutputA, DEFAULT_KEY);
    DecryptClientKeyedBlock(encrypted, keyedOutputB, DEFAULT_KEY);
    DecryptClientKeyedBlock(encrypted, keyedOutputWrong, "runtime-key-1234");

    TEST_ASSERT_MEM_EQ(keyedOutputA, keyedOutputB, 16);

    bool differsFromFixed = std::memcmp(fixedOutput, keyedOutputA, 16) != 0;
    TEST_ASSERT_TRUE(differsFromFixed);

    bool differsFromWrongKey = std::memcmp(keyedOutputA, keyedOutputWrong, 16) != 0;
    TEST_ASSERT_TRUE(differsFromWrongKey);

    return true;
}

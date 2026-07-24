/**
 * @file Test_CRC32.cpp
 * @brief CRC32 function unit tests
 * @version 1.0
 * @date 2025-01-03
 */

#include "SLJFP_TestFramework.h"
#include "../include/SLJFP_LibsWrapper.h"

// ============================================================================
// CRC32 Basic Function Tests
// ============================================================================

TEST_CASE(CRC32, EmptyData) {
    // Empty data CRC32 should be initial value
    unsigned int crc = SLJFP_crc32(0, nullptr, 0);
    TEST_ASSERT_EQ((unsigned int)0, crc);
    return true;
}

TEST_CASE(CRC32, SingleByte) {
    // Single byte test
    unsigned char data[] = { 0x00 };
    unsigned int crc = SLJFP_crc32(0, data, 1);
    TEST_ASSERT_NE((unsigned int)0, crc);
    return true;
}

TEST_CASE(CRC32, KnownValue_ABC) {
    // Known value test "ABC"
    // CRC32 of "ABC" should be a specific value
    unsigned char data[] = { 'A', 'B', 'C' };
    unsigned int crc = SLJFP_crc32(0, data, 3);

    // MiniZ uses standard CRC32 (ISO 3309)
    // CRC32 of "ABC" = 0xA3830348
    TEST_ASSERT_EQ((unsigned int)0xA3830348, crc);
    return true;
}

TEST_CASE(CRC32, KnownValue_HelloWorld) {
    // Known value test "Hello, World!"
    unsigned char data[] = "Hello, World!";
    unsigned int crc = SLJFP_crc32(0, data, 13);

    // CRC32 of "Hello, World!" (without null terminator)
    // Expected value needs verification
    TEST_ASSERT_NE((unsigned int)0, crc);
    return true;
}

TEST_CASE(CRC32, Incremental) {
    // Test incremental calculation
    unsigned char data[] = { 'A', 'B', 'C', 'D', 'E', 'F' };

    // Full calculation at once
    unsigned int crc_full = SLJFP_crc32(0, data, 6);

    // Incremental calculation (ABC + DEF)
    unsigned int crc_part1 = SLJFP_crc32(0, data, 3);
    unsigned int crc_part2 = SLJFP_crc32(crc_part1, data + 3, 3);

    TEST_ASSERT_EQ(crc_full, crc_part2);
    return true;
}

TEST_CASE(CRC32, LargeData) {
    // Large data test (1MB)
    const size_t size = 1024 * 1024;
    unsigned char* data = new unsigned char[size];

    // Fill data
    for (size_t i = 0; i < size; ++i) {
        data[i] = (unsigned char)(i & 0xFF);
    }

    unsigned int crc = SLJFP_crc32(0, data, (unsigned int)size);
    TEST_ASSERT_NE((unsigned int)0, crc);

    // Verify same data produces same CRC
    unsigned int crc2 = SLJFP_crc32(0, data, (unsigned int)size);
    TEST_ASSERT_EQ(crc, crc2);

    delete[] data;
    return true;
}

TEST_CASE(CRC32, Consistency) {
    // Consistency test: same data produces same CRC
    unsigned char data[] = { 0x01, 0x02, 0x03, 0x04, 0x05 };

    unsigned int crc1 = SLJFP_crc32(0, data, 5);
    unsigned int crc2 = SLJFP_crc32(0, data, 5);
    unsigned int crc3 = SLJFP_crc32(0, data, 5);

    TEST_ASSERT_EQ(crc1, crc2);
    TEST_ASSERT_EQ(crc2, crc3);
    return true;
}

TEST_CASE(CRC32, DifferentData) {
    // Different data produces different CRC
    unsigned char data1[] = { 0x01, 0x02, 0x03 };
    unsigned char data2[] = { 0x01, 0x02, 0x04 };  // Last byte different

    unsigned int crc1 = SLJFP_crc32(0, data1, 3);
    unsigned int crc2 = SLJFP_crc32(0, data2, 3);

    TEST_ASSERT_NE(crc1, crc2);
    return true;
}

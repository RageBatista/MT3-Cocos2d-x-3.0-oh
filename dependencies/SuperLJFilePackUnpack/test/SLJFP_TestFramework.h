/**
 * @file SLJFP_TestFramework.h
 * @brief Lightweight unit test framework (no external dependencies)
 * @version 1.0
 * @date 2025-01-03
 *
 * Features:
 *   - No Google Test or other external dependencies required
 *   - Compatible with Visual Studio 2013 (v120)
 *   - Provides basic assertions and test organization
 */

#ifndef SLJFP_TESTFRAMEWORK_H
#define SLJFP_TESTFRAMEWORK_H

#include <iostream>
#include <string>
#include <vector>
#include <functional>
#include <cstdint>
#include <cstring>
#include <sstream>
#include <iomanip>

namespace SLJFP {
namespace Test {

// ============================================================================
// Test Result Statistics
// ============================================================================

struct TestStats {
    int total;
    int passed;
    int failed;
    int skipped;

    TestStats() : total(0), passed(0), failed(0), skipped(0) {}

    void reset() {
        total = 0;
        passed = 0;
        failed = 0;
        skipped = 0;
    }

    void print() const {
        std::cout << "\n";
        std::cout << "========================================\n";
        std::cout << "  Test Results Summary\n";
        std::cout << "========================================\n";
        std::cout << "  Total:   " << total << "\n";
        std::cout << "  Passed:  " << passed << " (" << (total > 0 ? (passed * 100 / total) : 0) << "%)\n";
        std::cout << "  Failed:  " << failed << "\n";
        std::cout << "  Skipped: " << skipped << "\n";
        std::cout << "========================================\n";

        if (failed == 0) {
            std::cout << "  [PASS] All tests passed!\n";
        } else {
            std::cout << "  [FAIL] " << failed << " test(s) failed!\n";
        }
        std::cout << "========================================\n";
    }
};

// Global test statistics
static TestStats g_stats;

// ============================================================================
// Test Case Structure
// ============================================================================

struct TestCase {
    std::string name;
    std::string suite;
    std::function<bool()> func;
    bool enabled;

    TestCase(const std::string& n, const std::string& s, std::function<bool()> f, bool e = true)
        : name(n), suite(s), func(f), enabled(e) {}
};

// Test case registry
static std::vector<TestCase> g_tests;

// ============================================================================
// Test Registration Macros
// ============================================================================

#define TEST_CASE(suite, name) \
    bool Test_##suite##_##name(); \
    static struct TestRegistrar_##suite##_##name { \
        TestRegistrar_##suite##_##name() { \
            SLJFP::Test::g_tests.push_back( \
                SLJFP::Test::TestCase(#name, #suite, Test_##suite##_##name)); \
        } \
    } g_registrar_##suite##_##name; \
    bool Test_##suite##_##name()

#define SKIP_TEST(suite, name) \
    bool Test_##suite##_##name(); \
    static struct TestRegistrar_##suite##_##name { \
        TestRegistrar_##suite##_##name() { \
            SLJFP::Test::g_tests.push_back( \
                SLJFP::Test::TestCase(#name, #suite, Test_##suite##_##name, false)); \
        } \
    } g_registrar_##suite##_##name; \
    bool Test_##suite##_##name()

// ============================================================================
// Assertion Macros
// ============================================================================

#define TEST_ASSERT(condition) \
    do { \
        if (!(condition)) { \
            std::cerr << "  [ASSERT FAILED] " << #condition << "\n"; \
            std::cerr << "    at " << __FILE__ << ":" << __LINE__ << "\n"; \
            return false; \
        } \
    } while(0)

#define TEST_ASSERT_MSG(condition, msg) \
    do { \
        if (!(condition)) { \
            std::cerr << "  [ASSERT FAILED] " << #condition << "\n"; \
            std::cerr << "    Message: " << msg << "\n"; \
            std::cerr << "    at " << __FILE__ << ":" << __LINE__ << "\n"; \
            return false; \
        } \
    } while(0)

#define TEST_ASSERT_EQ(expected, actual) \
    do { \
        if (!((expected) == (actual))) { \
            std::cerr << "  [ASSERT FAILED] " << #expected << " == " << #actual << "\n"; \
            std::cerr << "    Expected: " << (expected) << "\n"; \
            std::cerr << "    Actual:   " << (actual) << "\n"; \
            std::cerr << "    at " << __FILE__ << ":" << __LINE__ << "\n"; \
            return false; \
        } \
    } while(0)

#define TEST_ASSERT_NE(val1, val2) \
    do { \
        if ((val1) == (val2)) { \
            std::cerr << "  [ASSERT FAILED] " << #val1 << " != " << #val2 << "\n"; \
            std::cerr << "    Both are: " << (val1) << "\n"; \
            std::cerr << "    at " << __FILE__ << ":" << __LINE__ << "\n"; \
            return false; \
        } \
    } while(0)

#define TEST_ASSERT_TRUE(condition) TEST_ASSERT(condition)
#define TEST_ASSERT_FALSE(condition) TEST_ASSERT(!(condition))

#define TEST_ASSERT_NULL(ptr) \
    do { \
        if ((ptr) != nullptr) { \
            std::cerr << "  [ASSERT FAILED] " << #ptr << " is not NULL\n"; \
            std::cerr << "    at " << __FILE__ << ":" << __LINE__ << "\n"; \
            return false; \
        } \
    } while(0)

#define TEST_ASSERT_NOT_NULL(ptr) \
    do { \
        if ((ptr) == nullptr) { \
            std::cerr << "  [ASSERT FAILED] " << #ptr << " is NULL\n"; \
            std::cerr << "    at " << __FILE__ << ":" << __LINE__ << "\n"; \
            return false; \
        } \
    } while(0)

#define TEST_ASSERT_MEM_EQ(expected, actual, size) \
    do { \
        if (std::memcmp((expected), (actual), (size)) != 0) { \
            std::cerr << "  [ASSERT FAILED] Memory compare failed\n"; \
            std::cerr << "    Size: " << (size) << " bytes\n"; \
            std::cerr << "    at " << __FILE__ << ":" << __LINE__ << "\n"; \
            return false; \
        } \
    } while(0)

// ============================================================================
// Test Runner
// ============================================================================

inline int RunAllTests(const std::string& filter = "") {
    g_stats.reset();

    std::cout << "\n";
    std::cout << "========================================\n";
    std::cout << "  SuperLJFilePackUnpack Unit Tests\n";
    std::cout << "========================================\n";

    std::string currentSuite;

    for (size_t i = 0; i < g_tests.size(); ++i) {
        const TestCase& test = g_tests[i];

        // Apply filter
        if (!filter.empty()) {
            std::string fullName = test.suite + "." + test.name;
            if (fullName.find(filter) == std::string::npos) {
                continue;
            }
        }

        // Print test suite header
        if (test.suite != currentSuite) {
            currentSuite = test.suite;
            std::cout << "\n[Suite: " << currentSuite << "]\n";
        }

        g_stats.total++;

        // Skip disabled tests
        if (!test.enabled) {
            std::cout << "  [ SKIP ] " << test.name << "\n";
            g_stats.skipped++;
            continue;
        }

        std::cout << "  [ RUN  ] " << test.name << "... ";
        std::cout.flush();

        try {
            bool result = test.func();
            if (result) {
                std::cout << "[PASS]\n";
                g_stats.passed++;
            } else {
                std::cout << "[FAIL]\n";
                g_stats.failed++;
            }
        } catch (const std::exception& e) {
            std::cout << "[EXCEPTION]\n";
            std::cerr << "    Exception: " << e.what() << "\n";
            g_stats.failed++;
        } catch (...) {
            std::cout << "[EXCEPTION]\n";
            std::cerr << "    Unknown exception\n";
            g_stats.failed++;
        }
    }

    g_stats.print();

    return g_stats.failed == 0 ? 0 : 1;
}

// ============================================================================
// Helper Utility Functions
// ============================================================================

// Convert byte array to hex string
inline std::string BytesToHex(const unsigned char* data, size_t size, size_t maxBytes = 32) {
    std::ostringstream oss;
    size_t displaySize = (size < maxBytes) ? size : maxBytes;
    for (size_t i = 0; i < displaySize; ++i) {
        oss << std::hex << std::setw(2) << std::setfill('0') << (int)data[i];
        if (i < displaySize - 1) oss << " ";
    }
    if (size > maxBytes) {
        oss << " ... (" << (size - maxBytes) << " more bytes)";
    }
    return oss.str();
}

// Compare two byte arrays and print differences
inline bool CompareBytes(const unsigned char* expected, const unsigned char* actual,
                         size_t size, const char* name = "Data") {
    bool match = true;
    for (size_t i = 0; i < size; ++i) {
        if (expected[i] != actual[i]) {
            if (match) {
                std::cerr << "  [" << name << " MISMATCH]\n";
                match = false;
            }
            std::cerr << "    Byte " << i << ": expected 0x"
                      << std::hex << std::setw(2) << std::setfill('0') << (int)expected[i]
                      << ", got 0x"
                      << std::hex << std::setw(2) << std::setfill('0') << (int)actual[i]
                      << std::dec << "\n";
            if (i > 10) {
                std::cerr << "    ... (more differences)\n";
                break;
            }
        }
    }
    return match;
}

} // namespace Test
} // namespace SLJFP

#endif // SLJFP_TESTFRAMEWORK_H

/**
 * @file Test_Main.cpp
 * @brief Unit test main program
 * @version 1.0
 * @date 2025-01-03
 *
 * Usage:
 *   ljfp-test              Run all tests
 *   ljfp-test CRC32        Run only CRC32 test suite
 *   ljfp-test SMS4.Round   Run tests containing "SMS4.Round"
 */

#include "SLJFP_TestFramework.h"
#include <string>
#include <iostream>

// Include all test files directly to avoid linker optimization issues
// This ensures static initializers are properly executed
#include "Test_CRC32.cpp"
#include "Test_Compression.cpp"
#include "Test_SMS4.cpp"
#include "Test_Unpacker.cpp"
#include "Test_AndroidBinaryKey.cpp"
#include "Test_Integration.cpp"
#include "Test_FileTypeDetector.cpp"
#include "Test_PathMappingGenerator.cpp"
#include "Test_WorkflowSession.cpp"
#include "Test_WorkflowPresenter.cpp"
#include "Test_WorkflowReviewController.cpp"
#include "Test_WorkflowReviewExportService.cpp"
#include "Test_UnpackExampleHelp.cpp"
#include "Test_RegressionFixtures.cpp"

int main(int argc, char* argv[]) {
    std::cout << "\n";
    std::cout << "=========================================================\n";
    std::cout << "  SuperLJFilePackUnpack Unit Test Suite\n";
    std::cout << "  Version: 1.0\n";
    std::cout << "  Date: 2025-01-03\n";
    std::cout << "=========================================================\n";

    // Parse command line arguments
    std::string filter;

    if (argc > 1) {
        std::string arg = argv[1];
        if (arg == "--help" || arg == "-h") {
            std::cout << "\n";
            std::cout << "Usage:\n";
            std::cout << "  ljfp-test              Run all tests\n";
            std::cout << "  ljfp-test <filter>     Run tests matching filter\n";
            std::cout << "  ljfp-test --help       Show this help\n";
            std::cout << "\n";
            std::cout << "Filter examples:\n";
            std::cout << "  ljfp-test CRC32        Run CRC32 suite\n";
            std::cout << "  ljfp-test SMS4         Run SMS4 suite\n";
            std::cout << "  ljfp-test Compression  Run Compression suite\n";
            std::cout << "  ljfp-test Integration  Run Integration suite\n";
            std::cout << "  ljfp-test Unpacker     Run Unpacker suite\n";
            std::cout << "  ljfp-test FileType     Run FileTypeDetector suite\n";
            std::cout << "  ljfp-test PathMapping  Run PathMappingGenerator suite\n";
            std::cout << "\n";
            return 0;
        }
        filter = arg;
    }

    if (!filter.empty()) {
        std::cout << "Filter: " << filter << "\n";
    }

    // Run tests
    int result = SLJFP::Test::RunAllTests(filter);

    // Return result
    if (result == 0) {
        std::cout << "\n[SUCCESS] All tests passed!\n\n";
    } else {
        std::cout << "\n[FAILURE] Some tests failed!\n\n";
    }

    return result;
}

/**
 * @file Test_UnpackExampleHelp.cpp
 * @brief ljfp-unpack help text regression tests
 */

#define SLJFP_UNPACKEXAMPLE_UNIT_TEST 1
#include "../examples/UnpackExample.cpp"

TEST_CASE(CliHelp, WindowsWideHelpTextContainsChineseUsageAndOptions) {
#ifdef _WIN32
    const std::wstring helpText = BuildHelpTextWide();
    TEST_ASSERT_TRUE(helpText.find(L"\u7528\u6CD5") != std::wstring::npos);
    TEST_ASSERT_TRUE(helpText.find(L"\u53C2\u6570") != std::wstring::npos);
    TEST_ASSERT_TRUE(helpText.find(L"--index=FILE") != std::wstring::npos);
    TEST_ASSERT_TRUE(helpText.find(L"--android-libgame=PATH") != std::wstring::npos);
#endif
    return true;
}

#ifdef _WIN32
static std::string WideToUtf8ForHelpTest(const std::wstring& value) {
    if (value.empty()) {
        return std::string();
    }

    const int length = WideCharToMultiByte(
        CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()), NULL, 0, NULL, NULL);
    if (length <= 0) {
        return std::string();
    }

    std::string utf8(static_cast<size_t>(length), '\0');
    WideCharToMultiByte(
        CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()), &utf8[0], length, NULL, NULL);
    return utf8;
}
#endif

TEST_CASE(CliHelp, WindowsWideHelpTextRoundTripsToUtf8) {
#ifdef _WIN32
    const std::string roundTripUtf8 = WideToUtf8ForHelpTest(BuildHelpTextWide());
    TEST_ASSERT_TRUE(roundTripUtf8.find("--decrypt-mode=M") != std::string::npos);
    TEST_ASSERT_TRUE(roundTripUtf8.find("auto | lj | apk") != std::string::npos);
    TEST_ASSERT_TRUE(roundTripUtf8.find("--android-libgame=PATH") != std::string::npos);
#endif
    return true;
}

TEST_CASE(CliHelp, HelpTextDocumentsScanHashModeOption) {
    const std::string helpText = BuildHelpTextUtf8();
    TEST_ASSERT_TRUE(helpText.find("--scan-hash-mode=MODE") != std::string::npos);
    TEST_ASSERT_TRUE(helpText.find("legacy-acp") != std::string::npos);
    return true;
}

TEST_CASE(CliHelp, HelpTextDocumentsSourceTemplateSeedOptions) {
    const std::string helpText = BuildHelpTextUtf8();
    TEST_ASSERT_TRUE(helpText.find("--no-source-template-seed") != std::string::npos);
    TEST_ASSERT_TRUE(helpText.find("--source-scan-root=DIR") != std::string::npos);
    TEST_ASSERT_TRUE(helpText.find("--source-map-config-bin=FILE") != std::string::npos);
    return true;
}

TEST_CASE(CliHelp, ParsePathHashModeAcceptsSupportedAliases) {
    typedef SLJFP::PathMappingGenerator::PathHashMode PathHashMode;

    PathHashMode mode = PathHashMode::NormalizedPath;
    TEST_ASSERT_TRUE(ParsePathHashMode("normalized", &mode));
    TEST_ASSERT_TRUE(mode == PathHashMode::NormalizedPath);

    TEST_ASSERT_TRUE(ParsePathHashMode("legacy", &mode));
    TEST_ASSERT_TRUE(mode == PathHashMode::LjFilePackLegacyAcpExact);

    TEST_ASSERT_TRUE(ParsePathHashMode("legacy-acp", &mode));
    TEST_ASSERT_TRUE(mode == PathHashMode::LjFilePackLegacyAcpExact);

    TEST_ASSERT_TRUE(ParsePathHashMode("ljfilepack", &mode));
    TEST_ASSERT_TRUE(mode == PathHashMode::LjFilePackLegacyAcpExact);

    TEST_ASSERT_FALSE(ParsePathHashMode("unknown-mode", &mode));
    TEST_ASSERT_FALSE(ParsePathHashMode("normalized", nullptr));
    return true;
}

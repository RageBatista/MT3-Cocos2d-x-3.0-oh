cmake_minimum_required(VERSION 3.6)

project(SuperLJFilePackUnpack VERSION 1.0 LANGUAGES CXX)

# VS 工程开启自动再生成时，会在本机旧版 CMake 环境下触发
# `cmake --check-stamp-list` 兼容性问题，直接阻塞目标编译。
if(CMAKE_GENERATOR MATCHES "Visual Studio")
    set(CMAKE_SUPPRESS_REGENERATION ON)
endif()

# ==============================================================================
# 项目配置
# ==============================================================================

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# ==============================================================================
# 编译选项
# ==============================================================================

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)

    # Visual Studio 编译选项
    add_compile_options(
        /W4                 # 警告级别 4
        /WX-                # 警告不视为错误
    )

    # Modern MSVC flags (VS2017+)
    if(NOT MSVC_VERSION LESS 1910)
        add_compile_options(
            /utf-8              # UTF-8 编码
            /permissive-        # 标准一致性
            /Zc:__cplusplus     # 正确的 __cplusplus 宏
        )
    endif()

    # Release 优化
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        add_compile_options(/O2 /Ob2 /Oi /Ot)
    endif()

    # Debug 选项
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(/Od /Zi)
    endif()
else()
    # GCC/Clang 编译选项
    add_compile_options(
        -Wall               # 所有警告
        -Wextra             # 额外警告
        -Wpedantic          # 严格警告
        -Wno-unused-parameter
    )

    # Release 优化
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        add_compile_options(-O3)
    endif()

    # Debug 选项
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(-O0 -g)
    endif()
endif()

# ==============================================================================
# 头文件路径
# ==============================================================================

include_directories(
    ${PROJECT_SOURCE_DIR}/include
    ${PROJECT_SOURCE_DIR}/libs
    ${PROJECT_SOURCE_DIR}/libs/ljfp
)

# ==============================================================================
# 源文件
# ==============================================================================

set(LJFP_SOURCES
    src/SLJFP_Unpack.cpp
    src/SLJFP_WorkflowPresenter.cpp
    src/SLJFP_WorkflowReviewController.cpp
    src/SLJFP_WorkflowReviewExportService.cpp
    src/SLJFP_UnpackIndexIO.cpp
    src/SLJFP_UnpackSourceIO.cpp
    src/SLJFP_LibsWrapper.cpp
    src/SLJFP_AndroidBinaryKey.cpp
    src/SLJFP_FileTypeDetector.cpp
    src/SLJFP_PathMappingGenerator.cpp
)

set(LJFP_HEADERS
    include/SLJFP_Unpack.h
    include/SLJFP_WorkflowPresenter.h
    include/SLJFP_WorkflowReviewController.h
    include/SLJFP_WorkflowReviewExportService.h
    include/SLJFP_AndroidBinaryKey.h
    include/SLJFP_Logger.h
    include/SLJFP_Logger_Impl.h
    include/SLJFP_ErrorCodes.h
    include/SLJFP_LibsWrapper.h
    include/SLJFP_FileTypeDetector.h
    include/SLJFP_PathMappingGenerator.h
)

set(LJFP_LIB_HEADERS
    libs/ljfp/LJFP_SMS4.h
    libs/ljfp/LJFP_CRC32.h
    libs/ljfp/LJFP_MiniZ.h
    libs/ljfp/LJFP_Compress.h
    libs/ljfp/LJFP_FileUtil.h
    libs/ljfp/LJFP_StringUtil.h
    libs/ljfp/LJFP_Var.h
)

# ==============================================================================
# 构建目标
# ==============================================================================

# 静态库
add_library(SuperLJFilePackUnpack STATIC
    ${LJFP_SOURCES}
    ${LJFP_HEADERS}
    ${LJFP_LIB_HEADERS}
)

add_library(SuperLJFilePackUnpack::SuperLJFilePackUnpack ALIAS SuperLJFilePackUnpack)

if(MSVC)
    # vendor 头文件中的未使用静态函数在 /W4 下会触发 C4505
    target_compile_options(SuperLJFilePackUnpack PRIVATE /wd4505)
endif()

target_include_directories(SuperLJFilePackUnpack PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/libs>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/libs/ljfp>
    $<INSTALL_INTERFACE:include>
)

# 设置目标属性
set_target_properties(SuperLJFilePackUnpack PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "${LJFP_HEADERS}"
)

# ==============================================================================
# CLI 程序（已弃用）
# ==============================================================================

option(BUILD_CLI "Build deprecated CLI application" OFF)
if(BUILD_CLI)
    message(WARNING "CLI target has been removed. Use GUI target: ljfp-gui")
endif()

# ==============================================================================
# 命令行示例工具（用于批处理与诊断）
# ==============================================================================

option(BUILD_EXAMPLES "Build command-line examples" ON)
if(BUILD_EXAMPLES)
    add_executable(ljfp-unpack examples/UnpackExample.cpp)
    target_link_libraries(ljfp-unpack SuperLJFilePackUnpack)
    target_include_directories(ljfp-unpack PRIVATE
        ${PROJECT_SOURCE_DIR}/include
        ${PROJECT_SOURCE_DIR}/libs
        ${PROJECT_SOURCE_DIR}/libs/ljfp
    )

    add_executable(ljfp-unpack-diag tools/UnpackDiag.cpp)
    target_link_libraries(ljfp-unpack-diag SuperLJFilePackUnpack)
    target_include_directories(ljfp-unpack-diag PRIVATE
        ${PROJECT_SOURCE_DIR}/include
        ${PROJECT_SOURCE_DIR}/libs
        ${PROJECT_SOURCE_DIR}/libs/ljfp
    )
endif()

# ==============================================================================
# 测试（可选）
# ==============================================================================

option(BUILD_TESTS "Build unit tests" ON)

if(BUILD_TESTS)
    enable_testing()

    # 测试源文件 (使用自带的轻量级测试框架，无需 Google Test)
    # 注意: Test_Main.cpp 通过 #include 指令包含其他测试文件
    # 这样做是为了避免 MSVC 链接器优化掉静态初始化器
    set(TEST_SOURCES
        test/Test_Main.cpp
    )

    set(TEST_HEADERS
        test/SLJFP_TestFramework.h
    )

    # 创建测试可执行文件
    add_executable(ljfp-test
        ${TEST_SOURCES}
        ${TEST_HEADERS}
    )

    target_link_libraries(ljfp-test SuperLJFilePackUnpack)

    target_include_directories(ljfp-test PRIVATE
        ${PROJECT_SOURCE_DIR}/test
        ${PROJECT_SOURCE_DIR}/include
        ${PROJECT_SOURCE_DIR}/libs
        ${PROJECT_SOURCE_DIR}/libs/ljfp
    )

    # 添加 CTest 测试
    add_test(NAME UnitTests COMMAND ljfp-test)

    add_test(
        NAME PackageInstallConsumer
        COMMAND "${CMAKE_COMMAND}"
            "-DSLJFP_VERIFY_CMAKE_COMMAND=${CMAKE_COMMAND}"
            "-DSLJFP_VERIFY_BUILD_DIR=${CMAKE_BINARY_DIR}"
            "-DSLJFP_VERIFY_SOURCE_DIR=${PROJECT_SOURCE_DIR}"
            "-DSLJFP_VERIFY_GENERATOR=${CMAKE_GENERATOR}"
            "-DSLJFP_VERIFY_CONFIG=Release"
            -P "${PROJECT_SOURCE_DIR}/cmake/VerifyPackageInstall.cmake"
    )

    # 测试数据生成器
    if(EXISTS ${PROJECT_SOURCE_DIR}/test/TestDataGenerator.cpp)
        add_executable(ljfp-testgen test/TestDataGenerator.cpp)
        target_link_libraries(ljfp-testgen SuperLJFilePackUnpack)

        target_include_directories(ljfp-testgen PRIVATE
            ${PROJECT_SOURCE_DIR}/include
            ${PROJECT_SOURCE_DIR}/libs
            ${PROJECT_SOURCE_DIR}/libs/ljfp
        )
    endif()

    message(STATUS "Unit tests enabled (using built-in test framework)")
endif()

# ==============================================================================
# GUI 程序（可选，需要 wxWidgets）
# ==============================================================================

option(BUILD_GUI "Build GUI application (requires wxWidgets)" ON)

# wxWidgets 本地路径配置 (MT3 项目)
# 优先使用已包含预编译库的路径
set(_WXWIDGETS_CANDIDATE_1 "${PROJECT_SOURCE_DIR}/../../tools/CEImagesetEditor-0.7.1/dependencies/wxWidgets-3.0.5")
set(_WXWIDGETS_CANDIDATE_2 "${PROJECT_SOURCE_DIR}/../wxWidgets-3.0.5")
if(NOT DEFINED WXWIDGETS_ROOT_DIR)
    if(EXISTS "${_WXWIDGETS_CANDIDATE_1}/include/wx/wx.h" AND EXISTS "${_WXWIDGETS_CANDIDATE_1}/lib/vc_lib/wxmsw30u_core.lib")
        set(_WXWIDGETS_DEFAULT_ROOT "${_WXWIDGETS_CANDIDATE_1}")
    else()
        set(_WXWIDGETS_DEFAULT_ROOT "${_WXWIDGETS_CANDIDATE_2}")
    endif()
endif()
set(WXWIDGETS_ROOT_DIR "${_WXWIDGETS_DEFAULT_ROOT}" CACHE PATH "wxWidgets installation root")

if(BUILD_GUI)
    # 检查本地 wxWidgets
    if(EXISTS "${WXWIDGETS_ROOT_DIR}/include/wx/wx.h" AND EXISTS "${WXWIDGETS_ROOT_DIR}/lib/vc_lib/wxmsw30u_core.lib")
        message(STATUS "Found local wxWidgets at: ${WXWIDGETS_ROOT_DIR}")

        # 设置 wxWidgets 变量 (不使用 find_package，直接配置)
        set(wxWidgets_FOUND TRUE)
        set(wxWidgets_INCLUDE_DIRS
            "${WXWIDGETS_ROOT_DIR}/include"
            "${WXWIDGETS_ROOT_DIR}/lib/vc_lib/mswu"
        )
        set(wxWidgets_LIB_DIR "${WXWIDGETS_ROOT_DIR}/lib/vc_lib")

        # 根据构建类型选择库
        if(CMAKE_BUILD_TYPE STREQUAL "Debug")
            set(wxWidgets_LIBRARIES
                "${wxWidgets_LIB_DIR}/wxmsw30ud_core.lib"
                "${wxWidgets_LIB_DIR}/wxmsw30ud_adv.lib"
                "${wxWidgets_LIB_DIR}/wxbase30ud.lib"
                "${wxWidgets_LIB_DIR}/wxpngd.lib"
                "${wxWidgets_LIB_DIR}/wxzlibd.lib"
                "${wxWidgets_LIB_DIR}/wxjpegd.lib"
                "${wxWidgets_LIB_DIR}/wxtiffd.lib"
                "${wxWidgets_LIB_DIR}/wxexpatd.lib"
                "${wxWidgets_LIB_DIR}/wxregexud.lib"
            )
            set(wxWidgets_SETUP_DIR "${WXWIDGETS_ROOT_DIR}/lib/vc_lib/mswud")
        else()
            set(wxWidgets_LIBRARIES
                "${wxWidgets_LIB_DIR}/wxmsw30u_core.lib"
                "${wxWidgets_LIB_DIR}/wxmsw30u_adv.lib"
                "${wxWidgets_LIB_DIR}/wxbase30u.lib"
                "${wxWidgets_LIB_DIR}/wxpng.lib"
                "${wxWidgets_LIB_DIR}/wxzlib.lib"
                "${wxWidgets_LIB_DIR}/wxjpeg.lib"
                "${wxWidgets_LIB_DIR}/wxtiff.lib"
                "${wxWidgets_LIB_DIR}/wxexpat.lib"
                "${wxWidgets_LIB_DIR}/wxregexu.lib"
            )
            set(wxWidgets_SETUP_DIR "${WXWIDGETS_ROOT_DIR}/lib/vc_lib/mswu")
        endif()

        # Windows 系统库
        set(wxWidgets_SYSTEM_LIBS
            comctl32 rpcrt4 winmm advapi32 wsock32 oleacc uxtheme version
        )
    else()
        # 回退到 CMake 自动查找
        find_package(wxWidgets COMPONENTS core base adv)
    endif()

    if(wxWidgets_FOUND)
        set(GUI_SOURCES
            gui/SLJFP_App.cpp
            gui/SLJFP_MainFrame.cpp
            gui/SLJFP_ProgressDialog.cpp
        )

        set(GUI_HEADERS
            gui/SLJFP_MainFrame.h
            gui/SLJFP_ProgressDialog.h
            gui/SLJFP_WorkflowSession.h
        )

        add_executable(ljfp-gui WIN32
            ${GUI_SOURCES}
            ${GUI_HEADERS}
        )

        # 添加预处理器定义 (静态库: 不定义 WXUSINGDLL)
        target_compile_definitions(ljfp-gui PRIVATE
            UNICODE
            _UNICODE
            __WXMSW__
            wxUSE_GUI=1
            _CRT_SECURE_NO_WARNINGS
        )

        target_include_directories(ljfp-gui PRIVATE
            ${PROJECT_SOURCE_DIR}/gui
            ${PROJECT_SOURCE_DIR}/include
            ${PROJECT_SOURCE_DIR}/libs
            ${PROJECT_SOURCE_DIR}/libs/ljfp
            ${wxWidgets_INCLUDE_DIRS}
            ${wxWidgets_SETUP_DIR}
        )

        target_link_libraries(ljfp-gui
            SuperLJFilePackUnpack
            ${wxWidgets_LIBRARIES}
            ${wxWidgets_SYSTEM_LIBS}
        )

        set_target_properties(ljfp-gui PROPERTIES
            OUTPUT_NAME "LJFilePackUnpacker"
        )

        message(STATUS "GUI application enabled (wxWidgets found)")
        message(STATUS "  Include dirs: ${wxWidgets_INCLUDE_DIRS}")
        message(STATUS "  Setup dir: ${wxWidgets_SETUP_DIR}")
    else()
        message(WARNING "wxWidgets not found, GUI application will not be built")
        message(WARNING "  Set WXWIDGETS_ROOT_DIR to wxWidgets installation path")
    endif()
endif()

# ==============================================================================
# 安装配置
# ==============================================================================

# 安装库文件
install(TARGETS SuperLJFilePackUnpack
    EXPORT SuperLJFilePackUnpackTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/SuperLJFilePackUnpack
    INCLUDES DESTINATION include
)

# 安装依赖库头文件
install(FILES ${LJFP_LIB_HEADERS}
    DESTINATION include/SuperLJFilePackUnpack/ljfp
)

# 安装文档
install(FILES
    ${PROJECT_SOURCE_DIR}/README.md
    DESTINATION share/doc/SuperLJFilePackUnpack
)

install(FILES
    ${PROJECT_SOURCE_DIR}/docs/README.md
    DESTINATION share/doc/SuperLJFilePackUnpack
    RENAME DOCS_INDEX.md
)

install(FILES
    ${PROJECT_SOURCE_DIR}/docs/11_发布验收_Release_Checklist.md
    DESTINATION share/doc/SuperLJFilePackUnpack
    RENAME RELEASE_CHECKLIST.md
)

install(FILES
    ${PROJECT_SOURCE_DIR}/docs/12_现状审计与目录清理报告_Current_State_Audit.md
    DESTINATION share/doc/SuperLJFilePackUnpack
    RENAME CURRENT_STATE_AUDIT.md
)

# ==============================================================================
# 包配置（用于 find_package）
# ==============================================================================

include(CMakePackageConfigHelpers)

export(
    EXPORT SuperLJFilePackUnpackTargets
    FILE "${CMAKE_CURRENT_BINARY_DIR}/SuperLJFilePackUnpackTargets.cmake"
    NAMESPACE SuperLJFilePackUnpack::
)

# 生成版本文件
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/SuperLJFilePackUnpackConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

# 生成配置文件
configure_package_config_file(
    "${PROJECT_SOURCE_DIR}/cmake/SuperLJFilePackUnpackConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/SuperLJFilePackUnpackConfig.cmake"
    INSTALL_DESTINATION lib/cmake/SuperLJFilePackUnpack
)

# 安装配置文件
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/SuperLJFilePackUnpackConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/SuperLJFilePackUnpackConfigVersion.cmake"
    DESTINATION lib/cmake/SuperLJFilePackUnpack
)

install(
    EXPORT SuperLJFilePackUnpackTargets
    FILE SuperLJFilePackUnpackTargets.cmake
    NAMESPACE SuperLJFilePackUnpack::
    DESTINATION lib/cmake/SuperLJFilePackUnpack
)

# ==============================================================================
# 打包配置
# ==============================================================================

set(CPACK_PACKAGE_NAME "SuperLJFilePackUnpack")
set(CPACK_PACKAGE_VENDOR "MT3 Project")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "LJFilePack Resource Unpacker")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "SuperLJFilePackUnpack")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/README.md")

if(WIN32)
    find_program(SLJFP_MAKENSIS_EXECUTABLE makensis)
    if(SLJFP_MAKENSIS_EXECUTABLE)
        set(CPACK_GENERATOR "NSIS;ZIP")
        set(CPACK_NSIS_EXECUTABLE "${SLJFP_MAKENSIS_EXECUTABLE}")
    else()
        set(CPACK_GENERATOR "ZIP")
        message(STATUS "NSIS not found; falling back to ZIP package generation")
    endif()
else()
    set(CPACK_GENERATOR "TGZ")
endif()

include(CPack)

# ==============================================================================
# 显示配置信息
# ==============================================================================

message(STATUS "")
message(STATUS "==========================================")
message(STATUS "  SuperLJFilePackUnpack ${PROJECT_VERSION}")
message(STATUS "==========================================")
message(STATUS "Build Type:       ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Compiler:     ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "C++ Standard:     ${CMAKE_CXX_STANDARD}")
message(STATUS "Install Prefix:   ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Build CLI:        ${BUILD_CLI}")
message(STATUS "Build Tests:      ${BUILD_TESTS}")
message(STATUS "Build GUI:        ${BUILD_GUI}")
message(STATUS "==========================================")
message(STATUS "")

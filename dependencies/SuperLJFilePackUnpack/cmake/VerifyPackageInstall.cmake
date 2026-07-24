if(NOT DEFINED SLJFP_VERIFY_CMAKE_COMMAND)
    message(FATAL_ERROR "SLJFP_VERIFY_CMAKE_COMMAND is required")
endif()

if(NOT DEFINED SLJFP_VERIFY_BUILD_DIR)
    message(FATAL_ERROR "SLJFP_VERIFY_BUILD_DIR is required")
endif()

if(NOT DEFINED SLJFP_VERIFY_SOURCE_DIR)
    message(FATAL_ERROR "SLJFP_VERIFY_SOURCE_DIR is required")
endif()

if(NOT DEFINED SLJFP_VERIFY_GENERATOR)
    message(FATAL_ERROR "SLJFP_VERIFY_GENERATOR is required")
endif()

if(NOT DEFINED SLJFP_VERIFY_CONFIG OR SLJFP_VERIFY_CONFIG STREQUAL "")
    set(SLJFP_VERIFY_CONFIG Release)
endif()

set(_install_script "${SLJFP_VERIFY_BUILD_DIR}/cmake_install.cmake")
if(NOT EXISTS "${_install_script}")
    message(FATAL_ERROR "Install script not found: ${_install_script}")
endif()

set(_install_prefix "${SLJFP_VERIFY_BUILD_DIR}/package_verify/install")
set(_consumer_source "${SLJFP_VERIFY_SOURCE_DIR}/test/package_consumer")
set(_consumer_build "${SLJFP_VERIFY_BUILD_DIR}/package_verify/consumer-build")
set(_config_dir "${_install_prefix}/lib/cmake/SuperLJFilePackUnpack")
set(_targets_file "${_config_dir}/SuperLJFilePackUnpackTargets.cmake")

file(REMOVE_RECURSE "${SLJFP_VERIFY_BUILD_DIR}/package_verify")
file(MAKE_DIRECTORY "${_install_prefix}")
file(MAKE_DIRECTORY "${_consumer_build}")

execute_process(
    COMMAND "${SLJFP_VERIFY_CMAKE_COMMAND}"
        "-DCMAKE_INSTALL_PREFIX=${_install_prefix}"
        "-DCMAKE_INSTALL_CONFIG_NAME=${SLJFP_VERIFY_CONFIG}"
        -P "${_install_script}"
    RESULT_VARIABLE _install_result
)
if(NOT _install_result EQUAL 0)
    message(FATAL_ERROR "Install step failed with exit code ${_install_result}")
endif()

if(NOT EXISTS "${_targets_file}")
    message(FATAL_ERROR "Installed export target file is missing: ${_targets_file}")
endif()

execute_process(
    COMMAND "${SLJFP_VERIFY_CMAKE_COMMAND}"
        "-G${SLJFP_VERIFY_GENERATOR}"
        "-DSuperLJFilePackUnpack_DIR=${_config_dir}"
        "${_consumer_source}"
    WORKING_DIRECTORY "${_consumer_build}"
    RESULT_VARIABLE _configure_result
)
if(NOT _configure_result EQUAL 0)
    message(FATAL_ERROR "Consumer configure failed with exit code ${_configure_result}")
endif()

execute_process(
    COMMAND "${SLJFP_VERIFY_CMAKE_COMMAND}"
        --build "${_consumer_build}"
        --config "${SLJFP_VERIFY_CONFIG}"
    RESULT_VARIABLE _build_result
)
if(NOT _build_result EQUAL 0)
    message(FATAL_ERROR "Consumer build failed with exit code ${_build_result}")
endif()

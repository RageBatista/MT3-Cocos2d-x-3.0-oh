# Install script for directory: E:/MT3/cocos2d-x-3.0-oh

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files (x86)/Cocos2dx")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("E:/MT3/build/cocos/math/kazmath/cmake_install.cmake")
  include("E:/MT3/build/external/chipmunk/src/cmake_install.cmake")
  include("E:/MT3/build/external/Box2D/cmake_install.cmake")
  include("E:/MT3/build/external/unzip/cmake_install.cmake")
  include("E:/MT3/build/external/tinyxml2/cmake_install.cmake")
  include("E:/MT3/build/external/xxhash/cmake_install.cmake")
  include("E:/MT3/build/external/sqlite3/cmake_install.cmake")
  include("E:/MT3/build/cocos/audio/cmake_install.cmake")
  include("E:/MT3/build/cocos/base/cmake_install.cmake")
  include("E:/MT3/build/cocos/2d/cmake_install.cmake")
  include("E:/MT3/build/cocos/storage/cmake_install.cmake")
  include("E:/MT3/build/cocos/ui/cmake_install.cmake")
  include("E:/MT3/build/cocos/network/cmake_install.cmake")
  include("E:/MT3/build/extensions/cmake_install.cmake")
  include("E:/MT3/build/cocos/editor-support/spine/cmake_install.cmake")
  include("E:/MT3/build/cocos/editor-support/cocosbuilder/cmake_install.cmake")
  include("E:/MT3/build/cocos/editor-support/cocostudio/cmake_install.cmake")
  include("E:/MT3/build/tests/cpp-tests/cmake_install.cmake")

endif()


# 03-环境配置文档 Environment Configuration Document

## 文档信息

| 项目 | 内容 |
|-----|------|
| **文档名称** | MT3 Common 公共库环境配置文档 |
| **文档版本** | v1.0 |
| **创建日期** | 2026-01-27 |
| **最后更新** | 2026-01-27 |
| **适用项目** | MT3 Common 公共库模块 |

---

## 目录

- [1. 概述](#1-概述)
- [2. Windows 平台配置](#2-windows-平台配置)
- [3. iOS 平台配置](#3-ios-平台配置)
- [4. Android 平台配置](#4-android-平台配置)
- [5. Windows Phone 8 平台配置](#5-windows-phone-8-平台配置)
- [6. 环境变量配置](#6-环境变量配置)
- [7. 编译选项配置](#7-编译选项配置)
- [8. 依赖库配置](#8-依赖库配置)
- [9. 常见问题与解决方案](#9-常见问题与解决方案)

---

## 1. 概述

### 1.1 支持的平台

MT3 Common 公共库支持以下平台：

| 平台 | 架构 | 编译器 | 状态 |
|-----|-------|-------|------|
| **Windows** | Win32, x64 | Visual Studio 2013 | ✅ 完全支持 |
| **iOS** | armv7, arm64 | Xcode 7.0+ | ✅ 完全支持 |
| **Android** | armeabi-v7a, arm64-v8a | NDK r8+ | ✅ 完全支持 |
| **Windows Phone 8** | ARM, Win32 | Visual Studio 2012 | ⚠️ 历史支持 |

### 1.2 系统要求

#### Windows 平台

| 组件 | 要求 |
|-----|------|
| **操作系统** | Windows 7 或更高版本 |
| **开发工具** | Visual Studio 2013 |
| **平台工具集** | v120 |
| **Windows SDK** | Windows SDK 8.1 |
| **运行时** | Visual C++ Redistributable for Visual Studio 2013 (x86) |

#### iOS 平台

| 组件 | 要求 |
|-----|------|
| **操作系统** | macOS 10.12 或更高版本 |
| **开发工具** | Xcode 7.0 或更高版本 |
| **iOS SDK** | iOS SDK 7.0 或更高版本 |
| **部署目标** | iOS 7.0 或更高版本 |

#### Android 平台

| 组件 | 要求 |
|-----|------|
| **操作系统** | Windows, macOS, Linux |
| **开发工具** | Android NDK r8 或更高版本 |
| **Android SDK** | API Level 14 (Android 4.0) 或更高版本 |
| **构建工具** | make, ndk-build |

#### Windows Phone 8 平台

| 组件 | 要求 |
|-----|------|
| **操作系统** | Windows 8 或更高版本 |
| **开发工具** | Visual Studio 2012 |
| **平台工具集** | v110_wp80 |
| **Windows Phone SDK** | Windows Phone 8 SDK |

---

## 2. Windows 平台配置

### 2.1 开发环境配置

#### 2.1.1 安装 Visual Studio 2013

1. 下载 Visual Studio 2013 安装包
2. 运行安装程序
3. 选择 "Visual C++" 组件
4. 确保安装 Windows SDK 8.1

#### 2.1.2 配置环境变量

**必需的环境变量**:

| 变量名 | 值 | 说明 |
|-------|------|------|
| `VS120COMNTOOLS` | `D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\` | VS2013 工具目录 |

**PATH 环境变量**:

需要将以下路径添加到系统 PATH 环境变量：

```
C:\Program Files (x86)\MSBuild\12.0\Bin\
D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\
C:\Program Files (x86)\Windows Kits\8.1\bin\x86\
```

#### 2.1.3 验证配置

打开命令提示符，执行以下命令验证配置：

```cmd
# 验证 MSBuild
msbuild /version

# 验证 cl 编译器
cl

# 验证环境变量
echo %VS120COMNTOOLS%
```

### 2.2 项目配置

#### 2.2.1 cauthc 项目配置

**项目文件**: [cauthc/projects/windows/cauthc.win32.vcxproj](file:///e:/MT3/common/cauthc/projects/windows/cauthc.win32.vcxproj)

**关键配置项**:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>true</UseDebugLibraries>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>false</UseDebugLibraries>
  <WholeProgramOptimization>true</WholeProgramOptimization>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
</PropertyGroup>
```

**预处理器定义**:

```xml
<ClCompile>
  <PreprocessorDefinitions>WIN32;WIN7_32;_DEBUG;_WINDOWS;_LIB;%(PreprocessorDefinitions)</PreprocessorDefinitions>
  <AdditionalIncludeDirectories>$(ProjectDir)\..\..\authc\os\windows;$(ProjectDir)\..\..\authc\share;$(ProjectDir)\..\..\authc</AdditionalIncludeDirectories>
</ClCompile>
```

**输出目录**:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <OutDir>$(SolutionDir)$(Configuration).win32\</OutDir>
  <IntDir>$(Configuration).win32\</IntDir>
</PropertyGroup>
```

#### 2.2.2 platform 项目配置

**项目文件**: [platform/platform.win32.vcxproj](file:///e:/MT3/common/platform/platform.win32.vcxproj)

**关键配置项**:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>true</UseDebugLibraries>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
</PropertyGroup>
```

**预处理器定义**:

```xml
<ClCompile>
  <PreprocessorDefinitions>_LIB;_CRT_SECURE_NO_WARNINGS;%(PreprocessorDefinitions)</PreprocessorDefinitions>
</ClCompile>
```

#### 2.2.3 lua 项目配置

**项目文件**: [lua/lua.win32.vcxproj](file:///e:/MT3/common/lua/lua.win32.vcxproj)

**关键配置项**:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>true</UseDebugLibraries>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
</PropertyGroup>
```

#### 2.2.4 ljfm 项目配置

**项目文件**: [ljfm/ljfm.win32.vcxproj](file:///e:/MT3/common/ljfm/ljfm.win32.vcxproj)

**关键配置项**:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>true</UseDebugLibraries>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
</PropertyGroup>
```

#### 2.2.5 updateengine 项目配置

**项目文件**: [updateengine/updateengine.win32.vcxproj](file:///e:/MT3/common/updateengine/updateengine.win32.vcxproj)

**关键配置项**:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>true</UseDebugLibraries>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
</PropertyGroup>
```

### 2.3 构建配置

#### 2.3.1 使用 Visual Studio 构建

1. 打开解决方案文件 `.sln`
2. 选择配置：Debug 或 Release
3. 选择平台：Win32 或 x64
4. 菜单：生成 → 生成解决方案

#### 2.3.2 使用 MSBuild 命令行构建

```cmd
# 构建 Debug 版本
msbuild cauthc.win32.vcxproj /p:Configuration=Debug /p:Platform=Win32

# 构建 Release 版本
msbuild cauthc.win32.vcxproj /p:Configuration=Release /p:Platform=Win32

# 清理构建
msbuild cauthc.win32.vcxproj /t:Clean /p:Configuration=Release /p:Platform=Win32
```

### 2.4 输出目录

**Windows 平台输出目录结构**:

```
common/
├── cauthc/projects/windows/
│   ├── Debug.win32/
│   │   └── cauthc.lib
│   └── Release.win32/
│       └── cauthc.lib
├── lua/
│   ├── Debug.win32/
│   │   └── lua.lib
│   └── Release.win32/
│       └── lua.lib
├── ljfm/
│   ├── Debug.win32/
│   │   └── ljfm.lib
│   └── Release.win32/
│       └── ljfm.lib
├── platform/
│   ├── Debug.win32/
│   │   └── platform.lib
│   └── Release.win32/
│       └── platform.lib
└── updateengine/
    ├── Debug.win32/
    │   └── updateengine.lib
    └── Release.win32/
        └── updateengine.lib
```

---

## 3. iOS 平台配置

### 3.1 开发环境配置

#### 3.1.1 安装 Xcode

1. 从 Mac App Store 下载 Xcode
2. 安装 Xcode 7.0 或更高版本
3. 安装 Command Line Tools

#### 3.1.2 配置开发者账号

1. 打开 Xcode
2. 进入 Xcode → Preferences → Accounts
3. 添加 Apple Developer 账号
4. 配置签名证书和 Provisioning Profile

### 3.2 项目配置

#### 3.2.1 platform 项目配置

**项目文件**: [platform/share.xcodeproj](file:///e:/MT3/common/platform/share.xcodeproj)

**关键配置项**:

```xml
<key>CFBundleDevelopmentRegion</key>
<string>en</string>
<key>CFBundleExecutable</key>
<string>$(EXECUTABLE_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>CFBundleInfoDictionaryVersion</key>
<string>6.0</string>
<key>CFBundleName</key>
<string>$(PRODUCT_NAME)</string>
<key>CFBundlePackageType</key>
<string>FMWK</string>
<key>CFBundleShortVersionString</key>
<string>1.0</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>MinimumOSVersion</key>
<string>7.0</string>
```

**构建设置**:

- **Scheme**: platform
- **Destination**: Generic iOS Device 或 iOS Simulator
- **Configuration**: Debug 或 Release

#### 3.2.2 ljfm 项目配置

**项目文件**: [ljfm/ljfm.xcodeproj](file:///e:/MT3/common/ljfm/ljfm.xcodeproj)

**关键配置项**:

```xml
<key>CFBundleDevelopmentRegion</key>
<string>en</string>
<key>CFBundleExecutable</key>
<string>$(EXECUTABLE_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>CFBundleInfoDictionaryVersion</key>
<string>6.0</string>
<key>CFBundleName</key>
<string>$(PRODUCT_NAME)</string>
<key>CFBundlePackageType</key>
<string>FMWK</string>
<key>CFBundleShortVersionString</key>
<string>1.0</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>MinimumOSVersion</key>
<string>7.0</string>
```

### 3.3 构建配置

#### 3.3.1 使用 Xcode 构建

```bash
# 1. 打开 Xcode 项目
cd common/platform
open share.xcodeproj

# 2. 选择配置
# - Scheme: platform
# - Destination: Generic iOS Device

# 3. 构建
# 菜单: Product → Build

# 4. 构建产物
# DerivedData/.../Build/Products/Release-iphoneos/libplatform.a
```

#### 3.3.2 使用 xcodebuild 命令行构建

```bash
# 构建 Debug 版本
xcodebuild -project share.xcodeproj \
          -scheme platform \
          -configuration Debug \
          -sdk iphoneos

# 构建 Release 版本
xcodebuild -project share.xcodeproj \
          -scheme platform \
          -configuration Release \
          -sdk iphoneos

# 清理构建
xcodebuild -project share.xcodeproj \
          -scheme platform \
          -configuration Release \
          -sdk iphoneos \
          clean
```

### 3.4 输出目录

**iOS 平台输出目录结构**:

```
DerivedData/
└── <ProjectName>-<Hash>/
    └── Build/
        └── Products/
            ├── Debug-iphoneos/
            │   ├── libplatform.a
            │   ├── libljfm.a
            │   └── ...
            └── Release-iphoneos/
                ├── libplatform.a
                ├── libljfm.a
                └── ...
```

---

## 4. Android 平台配置

### 4.1 开发环境配置

#### 4.1.1 安装 Android NDK

1. 下载 Android NDK r8 或更高版本
2. 解压到指定目录，例如：`C:\android-ndk`
3. 设置环境变量

#### 4.1.2 配置环境变量

**必需的环境变量**:

| 变量名 | 值 | 说明 |
|-------|------|------|
| `ANDROID_NDK` | `C:\android-ndk` | NDK 安装目录 |
| `ANDROID_NDK_ROOT` | `C:\android-ndk` | NDK 根目录（可选） |

**PATH 环境变量**:

需要将以下路径添加到系统 PATH 环境变量：

```
C:\android-ndk
```

#### 4.1.3 验证配置

打开命令提示符，执行以下命令验证配置：

```cmd
# 验证 NDK
echo %ANDROID_NDK%

# 验证 ndk-build
ndk-build --version
```

### 4.2 项目配置

#### 4.2.1 Android.mk 配置文件

**cauthc 模块 Android.mk**:

**文件位置**: [cauthc/projects/android/Android.mk](file:///e:/MT3/common/cauthc/projects/android/Android.mk)

```makefile
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cauthc_static
LOCAL_MODULE_FILENAME := libcauthc

LOCAL_SRC_FILES := \
    ../authc/authc.cpp \
    ../authc/ioengine.cpp \
    ../authc/netsession.cpp \
    ../authc/pollio.cpp \
    ../authc/protocol.cpp \
    ../authc/rpcgen.cpp \
    ../authc/share/marshal.cpp \
    ../authc/share/octets.cpp \
    ../authc/share/security.cpp \
    ../authc/share/streamcompress.cpp \
    ../authc/timer.cpp \
    ../net/FNet.cpp

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/../authc/os/android \
    $(LOCAL_PATH)/../authc/share \
    $(LOCAL_PATH)/../authc

LOCAL_LDLIBS := \
    -llog

LOCAL_CFLAGS := \
    -DANDROID \
    -D_OS_ANDROID

LOCAL_CPPFLAGS := -fexceptions -fpermissive

include $(BUILD_STATIC_LIBRARY)
```

**platform 模块 Android.mk**:

**文件位置**: [platform/Android.mk](file:///e:/MT3/common/platform/Android.mk)

```makefile
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := platform_static
LOCAL_MODULE_FILENAME := libplatform

LOCAL_SRC_FILES := \
    ini/IniFile.cpp \
    log/CoreLog.cpp \
    platform/ksemaphore.cpp \
    platform/usememory.cpp \
    platform/platform_types.cpp \
    platform/thread.cpp \
    utils/Encoder.cpp \
    utils/stringbuilder.cpp \
    utils/StringCover.cpp \
    utils/StringUtil.cpp \
    utils/Utils.cpp \
    android/FileUtil.cpp \
    android/SDJniHelper.cpp

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/ini \
    $(LOCAL_PATH)/log \
    $(LOCAL_PATH)/platform \
    $(LOCAL_PATH)/utils \
    $(LOCAL_PATH)/android \
    $(LOCAL_PATH)/../cauthc/include

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static

LOCAL_LDLIBS := \
    -llog

LOCAL_CFLAGS := \
    -DUSE_FILE32API \
    -DANDROID \
    -D_OS_IOS

LOCAL_CPPFLAGS := -fexceptions -fpermissive

include $(BUILD_STATIC_LIBRARY)

$(call import-module,cauthc/projects/android)
$(call import-module,cocos2dx)
```

**ljfm 模块 Android.mk**:

**文件位置**: [ljfm/Android.mk](file:///e:/MT3/common/ljfm/Android.mk)

```makefile
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := ljfm_static
LOCAL_MODULE_FILENAME := libljfm

LOCAL_SRC_FILES := \
    code/source/common.cpp \
    code/source/ljfileinfo.cpp \
    code/source/ljfm.cpp \
    code/source/ljfmbase.cpp \
    code/source/ljfmfex.cpp \
    code/source/ljfmasync.cpp \
    code/source/ljfsfile.cpp \
    code/source/ljfszipfile.cpp \
    code/source/ljfmimage.cpp \
    code/source/ljfmfsmanager.cpp \
    code/source/ljfmpq.cpp \
    code/source/timelog.cpp \
    code/source/util_android.cpp

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/code/include

LOCAL_LDLIBS := \
    -llog

LOCAL_CFLAGS := \
    -DANDROID

LOCAL_CPPFLAGS := -fexceptions -fpermissive

include $(BUILD_STATIC_LIBRARY)
```

**updateengine 模块 Android.mk**:

**文件位置**: [updateengine/Android.mk](file:///e:/MT3/common/updateengine/Android.mk)

```makefile
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := updateengine_static
LOCAL_MODULE_FILENAME := libupdateengine

LOCAL_SRC_FILES := \
    UpdateEngine.cpp \
    UpdateManagerEx.cpp \
    GlobalFunction_Common.cpp \
    android/UpdateEngineJni.cpp \
    android/GlobalFunction.cpp \
    android/GlobalNotification.cpp \
    android/FileDownloader.cpp \
    android/AsyncFileDownloader.cpp

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/android \
    $(LOCAL_PATH)/../platform/log \
    $(LOCAL_PATH)/../platform/utils \
    $(LOCAL_PATH)/../ljfm/code/include

LOCAL_LDLIBS := \
    -llog

LOCAL_CFLAGS := \
    -DANDROID

LOCAL_CPPFLAGS := -fexceptions -fpermissive

include $(BUILD_STATIC_LIBRARY)
```

### 4.3 Application.mk 配置

**Application.mk 示例**:

```makefile
APP_PLATFORM := android-14
APP_STL := gnustl_static
APP_CPPFLAGS := -fexceptions -frtti
APP_ABI := armeabi-v7a arm64-v8a
```

**配置项说明**:

| 配置项 | 值 | 说明 |
|-------|------|------|
| `APP_PLATFORM` | `android-14` | 最低 Android API 级别 |
| `APP_STL` | `gnustl_static` | 使用 GNU STL 静态库 |
| `APP_CPPFLAGS` | `-fexceptions -frtti` | 启用异常和 RTTI |
| `APP_ABI` | `armeabi-v7a arm64-v8a` | 支持的架构 |

### 4.4 构建配置

#### 4.4.1 使用 ndk-build 构建

```bash
# 设置环境变量
export ANDROID_NDK=/path/to/android-ndk
export PATH=$ANDROID_NDK:$PATH

# 进入模块目录
cd common/cauthc

# 使用 ndk-build 构建
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk

# 清理构建
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk clean
```

#### 4.4.2 构建多个架构

```bash
# 构建 armeabi-v7a
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk APP_ABI=armeabi-v7a

# 构建 arm64-v8a
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk APP_ABI=arm64-v8a

# 构建所有架构
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk APP_ABI=all
```

### 4.5 输出目录

**Android 平台输出目录结构**:

```
common/
├── cauthc/projects/android/
│   ├── obj/
│   │   ├── local/
│   │   │   ├── armeabi-v7a/
│   │   │   │   └── libcauthc.a
│   │   │   └── arm64-v8a/
│   │   │       └── libcauthc.a
│   └── libs/
│       ├── armeabi-v7a/
│       │   └── libcauthc.so
│       └── arm64-v8a/
│           └── libcauthc.so
├── platform/
│   ├── obj/
│   │   └── local/
│   │       ├── armeabi-v7a/
│   │       │   └── libplatform.a
│   │       └── arm64-v8a/
│   │           └── libplatform.a
│   └── libs/
│       ├── armeabi-v7a/
│       │   └── libplatform.so
│       └── arm64-v8a/
│           └── libplatform.so
├── ljfm/
│   ├── obj/
│   │   └── local/
│   │       ├── armeabi-v7a/
│   │       │   └── libljfm.a
│   │       └── arm64-v8a/
│   │           └── libljfm.a
│   └── libs/
│       ├── armeabi-v7a/
│       │   └── libljfm.so
│       └── arm64-v8a/
│           └── libljfm.so
└── updateengine/
    ├── obj/
    │   └── local/
    │       ├── armeabi-v7a/
    │       │   └── libupdateengine.a
    │       └── arm64-v8a/
    │           └── libupdateengine.a
    └── libs/
        ├── armeabi-v7a/
        │   └── libupdateengine.so
        └── arm64-v8a/
            └── libupdateengine.so
```

---

## 5. Windows Phone 8 平台配置

### 5.1 开发环境配置

#### 5.1.1 安装 Visual Studio 2012

1. 下载 Visual Studio 2012 Express for Windows Phone
2. 运行安装程序
3. 选择 Windows Phone SDK 组件

#### 5.1.2 配置环境变量

**必需的环境变量**:

| 变量名 | 值 | 说明 |
|-------|------|------|
| `VS110COMNTOOLS` | `D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\` | VS2012 工具目录 |

### 5.2 项目配置

#### 5.2.1 platform 项目配置

**项目文件**: [platform/platform.vcxproj](file:///e:/MT3/common/platform/platform.vcxproj)

**关键配置项**:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>true</UseDebugLibraries>
  <PlatformToolset>v110_wp80</PlatformToolset>
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>false</UseDebugLibraries>
  <WholeProgramOptimization>true</WholeProgramOptimization>
  <PlatformToolset>v110_wp80</PlatformToolset>
</PropertyGroup>
```

#### 5.2.2 cauthc 项目配置

**项目文件**: [cauthc/projects/wp8/wp8.vcxproj](file:///e:/MT3/common/cauthc/projects/wp8/wp8.vcxproj)

**关键配置项**:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <UseDebugLibraries>true</UseDebugLibraries>
  <PlatformToolset>v110_wp80</PlatformToolset>
</PropertyGroup>
```

### 5.3 构建配置

#### 5.3.1 使用 Visual Studio 构建

1. 打开解决方案文件 `.sln`
2. 选择配置：Debug 或 Release
3. 选择平台：Win32 或 ARM
4. 菜单：生成 → 生成解决方案

#### 5.3.2 使用 MSBuild 命令行构建

```cmd
# 构建 Debug 版本
msbuild wp8.vcxproj /p:Configuration=Debug /p:Platform=Win32

# 构建 Release 版本
msbuild wp8.vcxproj /p:Configuration=Release /p:Platform=Win32
```

### 5.4 输出目录

**Windows Phone 8 平台输出目录结构**:

```
common/
├── platform/
│   ├── lib/
│   │   ├── Debug/
│   │   │   ├── Win32/
│   │   │   │   └── platform.lib
│   │   │   └── ARM/
│   │   │       └── platform.lib
│   │   └── Release/
│   │       ├── Win32/
│   │       │   └── platform.lib
│   │       └── ARM/
│   │           └── platform.lib
└── cauthc/projects/wp8/
    ├── lib/
    │   ├── Debug/
    │   │   ├── Win32/
    │   │   │   └── cauthc.lib
    │   │   └── ARM/
    │   │       └── cauthc.lib
    │   └── Release/
    │       ├── Win32/
    │       │   └── cauthc.lib
    │       └── ARM/
    │           └── cauthc.lib
```

---

## 6. 环境变量配置

### 6.1 Windows 平台环境变量

#### 6.1.1 Visual Studio 环境变量

| 变量名 | 值 | 说明 |
|-------|------|------|
| `VS120COMNTOOLS` | `D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\` | VS2013 工具目录 |
| `VS110COMNTOOLS` | `D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\` | VS2012 工具目录 |

#### 6.1.2 PATH 环境变量

**Windows 平台 PATH**:

```
C:\Program Files (x86)\MSBuild\12.0\Bin\
D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\
C:\Program Files (x86)\Windows Kits\8.1\bin\x86\
```

### 6.2 Android 平台环境变量

#### 6.2.1 NDK 环境变量

| 变量名 | 值 | 说明 |
|-------|------|------|
| `ANDROID_NDK` | `C:\android-ndk` | NDK 安装目录 |
| `ANDROID_NDK_ROOT` | `C:\android-ndk` | NDK 根目录（可选） |
| `ANDROID_SDK` | `C:\android-sdk` | SDK 安装目录（可选） |

#### 6.2.2 PATH 环境变量

**Android 平台 PATH**:

```
C:\android-ndk
```

### 6.3 设置环境变量的方法

#### 6.3.1 Windows 临时设置

```cmd
# 命令提示符临时设置
set VS120COMNTOOLS=D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\

# PowerShell 临时设置
$env:VS120COMNTOOLS = "D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\"
```

#### 6.3.2 Windows 永久设置

1. 右键点击"此电脑" → 属性
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"系统变量"或"用户变量"中添加或编辑变量
5. 点击"确定"保存

#### 6.3.3 Linux/macOS 临时设置

```bash
# Bash 临时设置
export ANDROID_NDK=/path/to/android-ndk
export PATH=$ANDROID_NDK:$PATH

# Zsh 临时设置
export ANDROID_NDK=/path/to/android-ndk
export PATH=$ANDROID_NDK:$PATH
```

#### 6.3.4 Linux/macOS 永久设置

```bash
# 编辑 ~/.bashrc 或 ~/.zshrc
echo 'export ANDROID_NDK=/path/to/android-ndk' >> ~/.bashrc
echo 'export PATH=$ANDROID_NDK:$PATH' >> ~/.bashrc

# 重新加载配置
source ~/.bashrc
```

---

## 7. 编译选项配置

### 7.1 Windows 平台编译选项

#### 7.1.1 预处理器定义

| 定义 | 平台 | 说明 |
|-----|------|------|
| `WIN32` | Windows | 32位 Windows 平台 |
| `WIN7_32` | Windows | Windows 7 32位平台 |
| `_DEBUG` | Windows | Debug 配置 |
| `_WINDOWS` | Windows | Windows 平台 |
| `_LIB` | Windows | 静态库 |
| `_CRT_SECURE_NO_WARNINGS` | Windows | 禁用 CRT 安全警告 |

#### 7.1.2 编译器选项

| 选项 | 说明 |
|-----|------|
| `/Zi` | 生成调试信息 |
| `/Od` | 禁用优化（Debug） |
| `/O2` | 最大优化（Release） |
| `/MD` | 多线程 DLL 运行时 |
| `/MT` | 多线程静态运行时 |
| `/EHsc` | 异常处理 |
| `/W3` | 警告级别 3 |
| `/WX` | 将警告视为错误 |

#### 7.1.3 链接器选项

| 选项 | 说明 |
|-----|------|
| `/LIBPATH` | 库搜索路径 |
| `/NODEFAULTLIB` | 忽略默认库 |
| `/INCREMENTAL` | 增量链接 |

### 7.2 iOS 平台编译选项

#### 7.2.1 预处理器定义

| 定义 | 平台 | 说明 |
|-----|------|------|
| `OS_IOS` | iOS | iOS 平台 |
| `_OS_IOS` | iOS | iOS 平台（替代） |
| `DEBUG` | iOS | Debug 配置 |

#### 7.2.2 编译器选项

| 选项 | 说明 |
|-----|------|
| `-O0` | 无优化（Debug） |
| `-O2` | 优化（Release） |
| `-g` | 生成调试信息 |
| `-fexceptions` | 启用异常 |
| `-frtti` | 启用 RTTI |

### 7.3 Android 平台编译选项

#### 7.3.1 预处理器定义

| 定义 | 平台 | 说明 |
|-----|------|------|
| `ANDROID` | Android | Android 平台 |
| `_OS_ANDROID` | Android | Android 平台（替代） |
| `USE_FILE32API` | Android | 使用 32位文件 API |

#### 7.3.2 编译器选项

| 选项 | 说明 |
|-----|------|
| `-fexceptions` | 启用异常 |
| `-fpermissive` | 宽松的标准符合性 |
| `-frtti` | 启用 RTTI |

---

## 8. 依赖库配置

### 8.1 Windows 平台依赖库

#### 8.1.1 系统库

| 库名 | 说明 |
|-----|------|
| `ws2_32.lib` | Windows Sockets 2 |
| `winmm.lib` | Windows 多媒体 |
| `kernel32.lib` | Windows 内核 |
| `user32.lib` | Windows 用户界面 |
| `gdi32.lib` | Windows GDI |

#### 8.1.2 运行时库

| 配置 | 库 |
|-----|------|
| `/MD` | `msvcr120.dll` |
| `/MDd` | `msvcr120d.dll` |
| `/MT` | 静态链接运行时 |
| `/MTd` | 静态链接运行时（Debug） |

### 8.2 iOS 平台依赖库

| 框架 | 说明 |
|-----|------|
| `Foundation.framework` | 基础框架 |
| `CoreFoundation.framework` | 核心基础框架 |
| `UIKit.framework` | 用户界面框架 |
| `CFNetwork.framework` | 网络框架 |

### 8.3 Android 平台依赖库

| 库 | 说明 |
|-----|------|
| `log` | Android 日志库 |
| `z` | 压缩库 |
| `dl` | 动态链接库 |

---

## 9. 常见问题与解决方案

### 9.1 Windows 平台问题

#### 问题 1: 找不到 Visual Studio 工具

**症状**:
```
'msbuild' 不是内部或外部命令
```

**解决方案**:
1. 检查 `VS120COMNTOOLS` 环境变量是否设置
2. 将 MSBuild 路径添加到 PATH
3. 使用 Visual Studio 开发者命令提示符

#### 问题 2: 链接错误 LNK2019

**症状**:
```
error LNK2019: 无法解析的外部符号
```

**解决方案**:
1. 检查库依赖是否正确
2. 确认库文件路径是否正确
3. 检查函数声明和定义是否一致

#### 问题 3: 运行时库缺失

**症状**:
```
无法启动此程序，因为计算机中丢失 MSVCR120.dll
```

**解决方案**:
1. 安装 Visual C++ Redistributable for Visual Studio 2013
2. 或使用 `/MT` 静态链接运行时

### 9.2 iOS 平台问题

#### 问题 1: 代码签名失败

**症状**:
```
Code signing is required for product type 'Application' in SDK 'iOS'
```

**解决方案**:
1. 配置开发者账号
2. 设置正确的签名证书
3. 配置 Provisioning Profile

#### 问题 2: 架构不匹配

**症状**:
```
undefined symbols for architecture arm64
```

**解决方案**:
1. 检查目标架构设置
2. 确认库文件架构匹配
3. 重新编译依赖库

### 9.3 Android 平台问题

#### 问题 1: NDK 路径未找到

**症状**:
```
Android NDK: Could not find application project directory
```

**解决方案**:
1. 检查 `ANDROID_NDK` 环境变量
2. 确认 NDK 路径正确
3. 使用绝对路径

#### 问题 2: STL 相关错误

**症状**:
```
error: 'std::string' has not been declared
```

**解决方案**:
1. 检查 `APP_STL` 设置
2. 使用 `gnustl_static` 或 `c++_static`
3. 包含正确的头文件

---

## 10. 配置文件示例

### 10.1 Windows 批处理脚本

**build_all.bat**:

```batch
@echo off
setlocal

set VS120COMNTOOLS=D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\

echo Building platform...
cd platform
msbuild platform.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
cd ..

echo Building lua...
cd lua
msbuild lua.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
cd ..

echo Building cauthc...
cd cauthc\projects\windows
msbuild cauthc.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
cd ..\..

echo Building ljfm...
cd ljfm
msbuild ljfm.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
cd ..

echo Building updateengine...
cd updateengine
msbuild updateengine.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
cd ..

echo Build complete!
endlocal
```

### 10.2 Android 构建脚本

**build_all.sh**:

```bash
#!/bin/bash

export ANDROID_NDK=/path/to/android-ndk
export PATH=$ANDROID_NDK:$PATH

echo "Building platform..."
cd platform
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
cd ..

echo "Building lua..."
cd lua
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
cd ..

echo "Building cauthc..."
cd cauthc/projects/android
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
cd ../..

echo "Building ljfm..."
cd ljfm
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
cd ..

echo "Building updateengine..."
cd updateengine
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
cd ..

echo "Build complete!"
```

### 10.3 iOS 构建脚本

**build_all.sh**:

```bash
#!/bin/bash

echo "Building platform..."
cd platform
xcodebuild -project share.xcodeproj \
          -scheme platform \
          -configuration Release \
          -sdk iphoneos
cd ..

echo "Building ljfm..."
cd ljfm
xcodebuild -project ljfm.xcodeproj \
          -scheme ljfm \
          -configuration Release \
          -sdk iphoneos
cd ..

echo "Build complete!"
```

---

**文档结束**

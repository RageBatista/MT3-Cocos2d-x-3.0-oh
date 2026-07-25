# MT3 游戏客户端环境搭建指南

> **版本**: v1.0
>
> **最后更新**: 2026-01-27
>
> 本文档详细说明 MT3 客户端开发环境的搭建步骤和配置方法

---

## 📋 文档目录

- [1. Windows 平台环境搭建](#1-windows-平台环境搭建)
- [2. macOS 平台环境搭建](#2-macos-平台环境搭建)
- [3. Android 平台环境搭建](#3-android-平台环境搭建)
- [4. 通用工具配置](#4-通用工具配置)
- [5. 项目配置](#5-项目配置)
- [6. 常见问题](#6-常见问题)

---

## 1. Windows 平台环境搭建

### 1.1 系统要求

```yaml
操作系统:
  - Windows 7 SP1 或更高版本
  - Windows 8/8.1
  - Windows 10/11

硬件要求:
  - CPU: Intel Core i5 或更高
  - 内存: 8GB RAM（推荐 16GB）
  - 硬盘: 50GB 可用空间
  - 显卡: 支持 DirectX 11
```

### 1.2 安装 Visual Studio

#### 1.2.1 下载 Visual Studio 2013

```bash
# 下载地址
https://visualstudio.microsoft.com/vs/older-downloads/

# 选择版本
Visual Studio 2013 Update 5
```

#### 1.2.2 安装组件

安装时选择以下组件：

```yaml
必需组件:
  - Visual C++ 2013
  - Windows SDK 8.1
  - .NET Framework 4.5.1

可选组件:
  - Git for Windows
  - Python Tools for Visual Studio
```

#### 1.2.3 配置环境变量

```powershell
# VS2013 工具集
setx VS120COMNTOOLS "D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\"

# 将以下路径加入 PATH（建议系统级）
setx PATH "%PATH%;C:\Program Files (x86)\MSBuild\12.0\Bin\"
setx PATH "%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\"
setx PATH "%PATH%;C:\Program Files (x86)\Windows Kits\8.1\bin\x86\"

# 验证安装
msbuild -version
where msbuild
```

### 1.3 安装 DirectX SDK

```bash
# 下载 DirectX SDK (June 2010)
https://www.microsoft.com/en-us/download/details.aspx?id=6812

# 安装步骤
1. 下载 DXSDK_Jun10.exe
2. 运行安装程序
3. 按照提示完成安装
```

### 1.4 安装 Python

```bash
# 下载 Python 2.7.18
https://www.python.org/downloads/release/python-2718/

# 安装步骤
1. 下载 python-2.7.18.amd64.msi
2. 运行安装程序
3. 勾选 "Add python.exe to Path"
4. 完成安装

# 验证安装
python --version
```

### 1.5 安装 Git

```bash
# 下载 Git for Windows
https://git-scm.com/download/win

# 安装步骤
1. 下载 Git-2.x.x.x-64-bit.exe
2. 运行安装程序
3. 选择默认配置
4. 完成安装

# 验证安装
git --version
```

### 1.6 克隆项目

```bash
# 克隆项目仓库
git clone <repository_url> client
cd client

# 检查分支
git branch -a
```

### 1.7 编译项目

```bash
# 1. 打开项目
cd FireClient
start FireClient.sln

# 2. 在 Visual Studio 中选择配置
# - 配置管理器 → Release | Win32

# 3. 生成解决方案
# 菜单: 生成 → 生成解决方案
# 或按快捷键: Ctrl+Shift+B

# 4. 检查构建产物
ls Release.win32/
# 输出: MT3.exe, *.dll

# 5. 运行游戏
Release.win32/MT3.exe
```

---

## 2. macOS 平台环境搭建

### 2.1 系统要求

```yaml
操作系统:
  - macOS 10.10 Yosemite 或更高版本
  - macOS 10.11 El Capitan
  - macOS 10.12 Sierra
  - macOS 10.13 High Sierra
  - macOS 10.14 Mojave
  - macOS 10.15 Catalina
  - macOS 11 Big Sur
  - macOS 12 Monterey

硬件要求:
  - CPU: Intel Core i5 或更高
  - 内存: 8GB RAM（推荐 16GB）
  - 硬盘: 50GB 可用空间
```

### 2.2 安装 Xcode

#### 2.2.1 从 App Store 安装

```bash
# 打开 App Store
# 搜索 "Xcode"
# 点击 "获取" 或 "安装"
```

#### 2.2.2 安装 Command Line Tools

```bash
# 安装 Command Line Tools
xcode-select --install

# 验证安装
xcode-select -p
# 输出: /Applications/Xcode.app/Contents/Developer
```

#### 2.2.3 配置 Xcode

```bash
# 打开 Xcode
open /Applications/Xcode.app

# 同意许可协议
sudo xcodebuild -license

# 验证安装
xcodebuild -version
```

### 2.3 安装 Homebrew

```bash
# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 验证安装
brew --version
```

### 2.4 安装 Python

```bash
# 使用 Homebrew 安装 Python 2.7
brew install python@2.7

# 验证安装
python2 --version
```

### 2.5 安装 Git

```bash
# 使用 Homebrew 安装 Git
brew install git

# 配置 Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 验证安装
git --version
```

### 2.6 克隆项目

```bash
# 克隆项目仓库
git clone <repository_url> client
cd client

# 检查分支
git branch -a
```

### 2.7 编译项目

```bash
# 1. 打开项目
cd FireClient
open FireClient.xcodeproj

# 2. 配置签名
# Xcode → Project Settings → Signing & Capabilities
# - Team: 选择开发团队
# - Provisioning Profile: 自动 / 手动选择

# 3. 选择目标设备
# Xcode 工具栏 → Generic iOS Device

# 4. 构建项目
# Product → Build (Cmd+B)
# 或 Product → Archive (Cmd+Shift+B)

# 5. 运行项目
# Product → Run (Cmd+R)
```

---

## 3. Android 平台环境搭建

### 3.1 系统要求

```yaml
操作系统:
  - Windows 7 或更高版本
  - macOS 10.10 或更高版本
  - Linux (Ubuntu 16.04 或更高版本)

硬件要求:
  - CPU: Intel Core i5 或更高
  - 内存: 8GB RAM（推荐 16GB）
  - 硬盘: 50GB 可用空间
```

### 3.2 安装 JDK

```bash
# 下载 JDK 8
https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html

# 安装步骤
1. 下载 jdk-8uXXX-windows-x64.exe
2. 运行安装程序
3. 按照提示完成安装

# 配置环境变量
setx JAVA_HOME "C:\Program Files\Java\jdk1.8.0_144"
setx PATH "%PATH%;%JAVA_HOME%\bin"

# 验证安装
java -version
javac -version
```

### 3.3 安装 Android Studio

#### 3.3.1 下载 Android Studio

```bash
# 下载地址
https://developer.android.com/studio

# 选择版本
Windows (64-bit) 或 macOS
```

#### 3.3.2 安装 Android Studio

```bash
# Windows
1. 下载 android-studio-ide-XXX-windows.zip
2. 解压到指定目录
3. 运行 studio64.exe

# macOS
1. 下载 android-studio-ide-XXX-mac.dmg
2. 挂载 DMG 文件
3. 拖拽 Android Studio 到 Applications 文件夹
```

#### 3.3.3 配置 Android SDK

```bash
# 打开 Android Studio
# Tools → SDK Manager

# 安装以下 SDK 包:
SDK Platforms:
  - Android 5.0 (Lollipop) - API Level 21
  - Android 6.0 (Marshmallow) - API Level 23
  - Android 7.0 (Nougat) - API Level 24
  - Android 8.0 (Oreo) - API Level 26
  - Android 9.0 (Pie) - API Level 28

SDK Tools:
  - Android SDK Build-Tools 28.0.3
  - Android SDK Platform-Tools
  - Android SDK Tools
  - NDK (Side by side) - r10e
```

#### 3.3.4 配置环境变量

```powershell
# Android SDK
setx ANDROID_HOME "C:\Users\YourName\AppData\Local\Android\Sdk"
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools"
setx PATH "%PATH%;%ANDROID_HOME%\tools"
setx PATH "%PATH%;%ANDROID_HOME%\tools\bin"

# Android NDK
setx NDK_HOME "C:\Users\YourName\AppData\Local\Android\Sdk\ndk\10e"
setx PATH "%PATH%;%NDK_HOME%"

# 验证安装
adb version
ndk-build --version
```

### 3.4 安装 Apache Ant

```bash
# 下载 Apache Ant
https://ant.apache.org/bindownload.cgi

# 安装步骤
1. 下载 apache-ant-1.9.15-bin.zip
2. 解压到 C:\apache-ant-1.9.15
3. 配置环境变量

# 配置环境变量
setx ANT_HOME "C:\apache-ant-1.9.15"
setx PATH "%PATH%;%ANT_HOME%\bin"

# 验证安装
ant -version
```

### 3.5 克隆项目

```bash
# 克隆项目仓库
git clone <repository_url> client
cd client

# 检查分支
git branch -a
```

### 3.6 编译项目

#### 3.6.1 使用 Android Studio

```bash
# 1. 导入项目
# File → Open → 选择 android/LocojoyProject

# 2. 配置 Gradle（如果需要）
# 查看 build.gradle

# 3. 构建 APK
# Build → Build APK(s)
# 或 Build → Generate Signed APK（发布版本）

# 4. 安装到设备
# Run → Run 'app' (Shift+F10)
```

#### 3.6.2 使用命令行

```bash
# 1. 配置 SDK/NDK 路径
cd android/LocojoyProject
cat > local.properties <<EOF
sdk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\Sdk
ndk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\Sdk\\ndk\\10e
EOF

# 2. 构建 JNI 本地代码
cd jni
ndk-build clean
ndk-build -j4
# 输出: libs/armeabi-v7a/libcocos2dcpp.so

# 3. 拷贝游戏资源到 assets
cd ..
mkdir -p assets
cp -r ../../resource/res assets/

# 4. 构建 APK
ant clean
ant debug
# 输出: bin/mt3-debug.apk

# 或构建 Release APK（需要签名）
ant release
jarsigner -verbose -keystore my-release-key.keystore \
          bin/mt3-release-unsigned.apk alias_name
zipalign -v 4 bin/mt3-release-unsigned.apk bin/mt3-release.apk
```

---

## 4. 通用工具配置

### 4.1 配置 Git

```bash
# 配置用户信息
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 配置换行符
git config --global core.autocrlf true

# 配置编辑器
git config --global core.editor "notepad"

# 配置默认分支名
git config --global init.defaultBranch main
```

### 4.2 配置 Lua 环境

```bash
# 下载 LuaJIT
http://luajit.org/download.html

# 编译 LuaJIT（Windows）
# 使用预编译版本或自行编译

# 配置环境变量
setx LUA_PATH "C:\LuaJIT\?.lua;C:\LuaJIT\?\init.lua"
setx LUA_CPATH "C:\LuaJIT\?.dll"

# 验证安装
luajit -v
```

### 4.3 配置 tolua++

```bash
# tolua++ 已包含在项目中
# 位置: tolua++-pkgs/

# 编译 tolua++（如需要）
cd tolua++-pkgs
# 使用项目提供的 tolua++.exe
```

---

## 5. 项目配置

### 5.1 Visual Studio 项目配置

#### 5.1.1 通用设置

```yaml
配置:
  - PlatformToolset: v120 (VS2013)
  - WindowsTargetPlatformVersion: 8.1
  - CharacterSet: Unicode

Release:
  - RuntimeLibrary: MultiThreadedDLL (/MD)
  - AdditionalDependencies: legacy_stdio_definitions.lib
  - IgnoreSpecificDefaultLibraries: libcmt.lib; libcmtd.lib; msvcrt.lib; msvcrtd.lib
  - AdditionalOptions: /DYNAMICBASE:NO /GS-

Debug:
  - RuntimeLibrary: MultiThreadedDebugDLL (/MDd)
  - AdditionalDependencies: legacy_stdio_definitions.lib
  - IgnoreSpecificDefaultLibraries: libcmt.lib; libcmtd.lib; msvcrt.lib; msvcrtd.lib
  - AdditionalOptions: /DYNAMICBASE:NO /GS-
```

#### 5.1.2 包含目录

```yaml
包含目录:
  - $(ProjectDir)
  - $(ProjectDir)Application
  - $(ProjectDir)Application/Framework
  - $(ProjectDir)Application/Common
  - $(ProjectDir)Application/Utils
  - $(ProjectDir)../resource/cocos2dx
  - $(ProjectDir)../resource/cocos2dx/cocos2dx
  - $(ProjectDir)../resource/cocos2dx/cocos2dx/platform
  - $(ProjectDir)../resource/cocos2dx/cocos2dx/include
  - $(ProjectDir)../dependencies/cegui/CEGUI/include
```

#### 5.1.3 库目录

```yaml
库目录:
  - $(ProjectDir)../dependencies/cegui/CEGUI/lib
  - $(ProjectDir)../resource/cocos2dx/proj.win32/Debug.win32
  - $(ProjectDir)../resource/cocos2dx/proj.win32/Release.win32
```

### 5.2 Xcode 项目配置

#### 5.2.1 Build Settings

```yaml
Architectures:
  - $(ARCHS_STANDARD)
  - armv7
  - arm64

Base SDK:
  - Latest iOS (iphoneos)

Deployment Target:
  - iOS 7.0

Valid Architectures:
  - armv7
  - arm64

C++ Language Dialect:
  - C++11

C++ Standard Library:
  - libc++
```

#### 5.2.2 Signing

```yaml
Code Signing Entitlements:
  - $(PROJECT_DIR)/entitlements.plist

Provisioning Profile:
  - Automatic / 手动选择

Team:
  - 选择开发团队
```

### 5.3 Android 项目配置

#### 5.3.1 AndroidManifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.locojoy.mt3"
    android:versionCode="1"
    android:versionName="1.0">

    <uses-sdk
        android:minSdkVersion="19"
        android:targetSdkVersion="28" />

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

    <application
        android:label="@string/app_name"
        android:icon="@drawable/icon"
        android:theme="@android:style/Theme.NoTitleBar.Fullscreen">
        
        <activity
            android:name=".MT3Activity"
            android:label="@string/app_name"
            android:screenOrientation="landscape"
            android:configChanges="orientation">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

#### 5.3.2 build.gradle

```gradle
android {
    compileSdkVersion 28
    buildToolsVersion "28.0.3"

    defaultConfig {
        applicationId "com.locojoy.mt3"
        minSdkVersion 19
        targetSdkVersion 28
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }

    sourceSets {
        main {
            jniLibs.srcDirs = ['libs']
            assets.srcDirs = ['assets']
        }
    }
}
```

---

## 6. 常见问题

### 6.1 Windows 平台问题

#### 问题 1: DirectX SDK 安装失败

**现象**: 安装 DirectX SDK 时提示错误

**解决方案**:
```bash
# 1. 卸载 Visual C++ 2010 Redistributable
# 控制面板 → 程序和功能

# 2. 重新安装 DirectX SDK

# 3. 安装完成后重新安装 Visual C++ 2010 Redistributable
```

#### 问题 2: 找不到 d3dx9.h

**现象**: 编译时提示找不到 d3dx9.h

**解决方案**:
```bash
# 1. 确认已安装 DirectX SDK (June 2010)

# 2. 检查包含目录配置
# 项目属性 → C/C++ → 常规 → 附加包含目录
# 添加: C:\Program Files (x86)\Microsoft DirectX SDK (June 2010)\Include
```

#### 问题 3: 链接错误 LNK2005

**现象**: 链接时提示符号多重定义

**解决方案**:
```yaml
# 1. 统一运行时库为 /MD 或 /MDd

# 2. 在链接器 AdditionalDependencies 中加入 legacy_stdio_definitions.lib

# 3. 在链接器 AdditionalOptions 中添加 /DYNAMICBASE:NO /GS-
```

#### 问题 4: 运行时缺少 DLL

**现象**: 运行时提示缺少 MSVCP120.dll 或 MSVCR120.dll

**解决方案**:
```bash
# 安装 Visual C++ Redistributable for VS2013 (x86)
# 下载地址: https://www.microsoft.com/en-us/download/details.aspx?id=40784
```

### 6.2 macOS 平台问题

#### 问题 1: 签名错误

**现象**: 真机调试时提示签名错误

**解决方案**:
```bash
# 1. 登录 Apple Developer 账号

# 2. 创建开发证书（Development Certificate）

# 3. 创建 App ID（Bundle Identifier）

# 4. 创建 Provisioning Profile（Development）

# 5. 下载并安装证书和 Profile

# 6. Xcode 项目配置
# Signing & Capabilities → Team: 选择团队
# Automatically manage signing: 勾选
```

#### 问题 2: 找不到库

**现象**: 编译时提示找不到库文件

**解决方案**:
```bash
# 1. 检查 Framework Search Paths
# 项目设置 → Build Settings → Framework Search Paths

# 2. 添加正确的框架路径
$(PROJECT_DIR)/../dependencies/cegui/CEGUI/lib
```

### 6.3 Android 平台问题

#### 问题 1: NDK 版本不匹配

**现象**: 编译时提示 NDK 版本不匹配

**解决方案**:
```bash
# 使用 NDK r10e
# 下载地址: https://developer.android.com/ndk/downloads/older_releases

# 配置 local.properties
ndk.dir=/path/to/android-ndk-r10e
```

#### 问题 2: 构建失败

**现象**: ant 构建时失败

**解决方案**:
```bash
# 1. 检查 local.properties 配置
sdk.dir=/path/to/android-sdk
ndk.dir=/path/to/android-ndk

# 2. 清理项目
ant clean

# 3. 重新构建
ant debug
```

#### 问题 3: 无法安装到设备

**现象**: adb install 失败

**解决方案**:
```bash
# 1. 检查设备连接
adb devices

# 2. 检查设备权限
# 确保设备已开启 USB 调试

# 3. 卸载旧版本（如需要）
adb uninstall com.locojoy.mt3

# 4. 重新安装
adb install bin/mt3-debug.apk
```

---

## 附录

### A. 环境变量汇总

#### Windows

```powershell
# Visual Studio 2013
setx VS120COMNTOOLS "D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\"

# MSBuild
setx PATH "%PATH%;C:\Program Files (x86)\MSBuild\12.0\Bin\"

# Java
setx JAVA_HOME "C:\Program Files\Java\jdk1.8.0_144"
setx PATH "%PATH%;%JAVA_HOME%\bin"

# Android SDK
setx ANDROID_HOME "C:\Users\YourName\AppData\Local\Android\Sdk"
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools"
setx PATH "%PATH%;%ANDROID_HOME%\tools"

# Android NDK
setx NDK_HOME "C:\Users\YourName\AppData\Local\Android\Sdk\ndk\10e"
setx PATH "%PATH%;%NDK_HOME%"

# Apache Ant
setx ANT_HOME "C:\apache-ant-1.9.15"
setx PATH "%PATH%;%ANT_HOME%\bin"
```

#### macOS/Linux

```bash
# 添加到 ~/.bash_profile 或 ~/.zshrc

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_XXX.jdk/Contents/Home
export PATH=$PATH:$JAVA_HOME/bin

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools

# Android NDK
export NDK_HOME=$ANDROID_HOME/ndk/10e
export PATH=$PATH:$NDK_HOME

# Apache Ant
export ANT_HOME=/usr/local/ant
export PATH=$PATH:$ANT_HOME/bin
```

### B. 推荐开发工具

| 工具 | 用途 | 下载地址 |
|-----|------|---------|
| **Visual Studio Code** | 代码编辑器 | https://code.visualstudio.com/ |
| **SourceTree** | Git 图形界面 | https://www.sourcetreeapp.com/ |
| **Beyond Compare** | 文件对比 | https://www.scootersoftware.com/ |
| **Lua Studio** | Lua 调试 | http://luaforwindows.com/ |
| **Android Device Monitor** | Android 调试 | 内置于 Android SDK |
| **Xcode Instruments** | 性能分析 | 内置于 Xcode |

---

**文档结束** | **Document End**

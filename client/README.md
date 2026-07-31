# MT3 游戏客户端工程总览

> **梦幻西游 MG 版本** - 客户端工程完整文档
>
> 本文档提供客户端工程的完整架构说明、项目结构、构建指南和开发规范

---

## 📋 目录

- [1. 项目概述](#1-项目概述)
- [2. 目录结构说明](#2-目录结构说明)
- [3. 核心项目详解](#3-核心项目详解)
- [4. 多平台支持](#4-多平台支持)
- [5. 资源管理](#5-资源管理)
- [6. 构建与部署](#6-构建与部署)
- [7. 开发指南](#7-开发指南)
- [8. 常见问题 FAQ](#8-常见问题-faq)
- [9. 文档维护信息](#9-文档维护信息)
- [10. 快速链接](#10-快速链接)
- [11. 贡献与反馈](#11-贡献与反馈)
- [12. API 接口与示例](#12-api-接口与示例)
- [13. 已知问题与注意事项](#13-已知问题与注意事项)
- [附录 A](#附录-a-技术版本详细信息)
- [15. 环境变量与路径设置](#15-环境变量与路径设置)

---

## 1. 项目概述

### 1.1 客户端架构

MT3 客户端按平台使用不同的 Cocos2d-x 兼容链；Windows canonical 主线基于 **Cocos2d-x 3.0-oh + CEGUI 0.7.9-r5**，其他平台保留各自已验证的 2.2.6 兼容链。

**技术栈**:
- **游戏引擎**: Windows canonical 使用 Cocos2d-x 3.0-oh；Android/iOS 兼容链使用 Cocos2d-x 2.2.6
- **脚本语言**: Lua 5.1 (LuaJIT 2.0.3)
- **C++绑定**: tolua++ 1.0.93
- **编程语言**: C++ (引擎层), Lua (逻辑层)
- **UI 框架**: Windows canonical 使用 CEGUI 0.7.9-r5；旧 0.7.1 仅保留在 Legacy226 链路
- **网络协议**: TCP + protobuf 二进制协议
- **资源格式**: PNG, JPG, PVR, MP3, OGG

**支持平台**:
- ✅ Windows (Win32)
- ✅ Android (ARM, ARM64)
- ✅ iOS (iPhone, iPad)
- ⚠️ Windows Phone 8 (历史版本支持)

### 1.2 项目特点

| 特性 | 说明 |
|-----|------|
| 🎮 **多平台** | 一套代码，多平台发布（Windows/Android/iOS） |
| 📱 **跨渠道** | 支持多渠道 SDK 集成（Locojoy、易接、百度等） |
| 🔧 **热更新** | Lua 脚本热更新，无需重新发布 |
| 🎨 **UI 分离** | CEGUI XML 布局，美术资源与代码解耦 |
| 🛡️ **反外挂** | 内置防护机制，代码混淆、加密 |
| 📊 **日志收集** | 崩溃日志自动上报与分析 |

### 1.3 项目规模

```
代码行数统计 (估算):
  C++ 引擎代码: ~150,000 行
  Lua 脚本代码: ~300,000 行
  配置 XML: ~50,000 行

资源规模:
  纹理图片: ~10,000+ 张
  音效音乐: ~500+ 个
  地图数据: ~200+ 张
  APK 大小: ~396 MB (mt3_locojoy.apk 实际大小)
  iOS IPA: ~500 MB (未压缩)

目录空间占用 (实际):
  android/         4.8 GB  (包含多渠道项目和构建产物)
  FireClient/      1.7 GB  (iOS/Win32 主项目)
  resource/        1.2 GB  (Lua 脚本和游戏资源)
  MT3Win32App/     1.1 GB  (旧版 Win32 项目)
  res_ios/         768 MB  (iOS 平台资源)
  res_android/     665 MB  (Android 平台资源)
  res_win/         394 MB  (Windows 平台资源)
  Launcher/        83 MB   (启动器)
```

---

## 2. 目录结构说明

### 2.1 顶层目录结构

```
client/                              # 客户端根目录
├── 3rdplatform/                     # 第三方 SDK 集成
│   ├── BaiduLBS_AndroidSDK_Lib/     # 百度地图 SDK
│   ├── duClient_SDK_Lib/            # 度客 SDK
│   ├── MeiqiaSdk/                   # 美洽客服 SDK
│   ├── ShareSDK/                    # 分享 SDK (微信/QQ/微博)
│   └── YijieSDK/                    # 易接渠道 SDK
│
├── android/                         # Android 平台项目
│   ├── common/                      # 公共代码和资源
│   ├── JoysdkProject/               # Joysdk 渠道项目
│   ├── LocojoyProject/              # Locojoy 渠道项目（主渠道）
│   ├── YijieProject/                # 易接渠道项目
│   ├── ApkIDE_.apk                  # 构建产物 (1.3GB)
│   └── mt3_locojoy.apk              # Locojoy 渠道 APK (415MB)
│
├── doc/                             # 文档与工具
│   ├── carsh统计工具/               # 崩溃日志统计工具
│   ├── 崩溃日志批量解析说明/        # 日志解析文档
│   └── 反外挂说明和程序/            # 反外挂机制说明
│
├── FireClient/                      # iOS/Win32 主项目（新版）
│   ├── Application/                 # 应用程序入口（iOS/Android/Win32）
│   ├── FireClient/                  # 引擎核心代码
│   ├── FireClient.sln               # Visual Studio 解决方案
│   ├── FireClient.xcodeproj/        # Xcode 项目
│   ├── Debug.win32/                 # Windows Debug 构建目录
│   └── Release.win32/               # Windows Release 构建目录
│
├── Launcher/                        # Windows 启动器（更新器）
│   ├── Code/                        # 启动器源代码
│   ├── Release/                     # 启动器构建产物
│   ├── Launcher.sln                 # Visual Studio 解决方案
│   └── Launcher.vcxproj             # Visual Studio 项目文件
│
├── MT3Win32App/                     # Windows 主程序项目（旧版）
│   ├── FireClient.win32.vcxproj     # 新版项目文件
│   ├── mt3.win32.vcxproj            # 旧版项目文件
│   ├── main.cpp                     # 程序入口
│   ├── Debug.win32/                 # Debug 构建目录
│   └── Release.win32/               # Release 构建目录
│
├── res_android/                     # Android 平台资源
│   └── res/                         # 资源文件（图标、启动图）
│
├── res_ios/                         # iOS 平台资源
│   └── res/                         # 资源文件（图标、启动图）
│
├── res_win/                         # Windows 平台资源
│   └── res/                         # 资源文件（图标、ICO）
│
├── resource/                        # 游戏核心资源（所有平台共享）
│   ├── bin/                         # 二进制工具（资源打包器）
│   ├── cocos2dx/                    # Cocos2d-x 引擎源码
│   ├── res/                         # 游戏资源（纹理、音效、脚本）
│   ├── res1/                        # 额外资源（备用）
│   └── tools/                       # 资源处理工具
│
├── tolua++-pkgs/                    # Lua 绑定包定义
│   └── FireClient/                  # FireClient 的 tolua++ 绑定
│
├── build.xml                        # Ant 构建脚本（Lua 绑定生成）
├── cc.sh                            # Cocos 命令行工具脚本
├── gen_cygwin.sh                    # Cygwin 环境生成脚本
├── gen4d.sh                         # 4D 工具生成脚本
├── genluaonly.sh                    # 仅生成 Lua 绑定脚本
├── genWp8Release.bat                # Windows Phone 8 发布脚本
└── luajit.py                        # LuaJIT 编译脚本
```

### 2.2 关键目录说明

| 目录 | 用途 | 重要性 |
|-----|------|--------|
| `FireClient/` | iOS/Win32 主项目，包含引擎和游戏逻辑 | ⭐⭐⭐⭐⭐ |
| `resource/res/script/` | Lua 脚本源码（游戏核心逻辑） | ⭐⭐⭐⭐⭐ |
| `android/LocojoyProject/` | Android 主渠道项目 | ⭐⭐⭐⭐⭐ |
| `Launcher/` | Windows 启动器（热更新支持） | ⭐⭐⭐⭐ |
| `resource/cocos2dx/` | Cocos2d-x 引擎源码 | ⭐⭐⭐⭐ |
| `3rdplatform/` | 第三方 SDK 集成 | ⭐⭐⭐ |
| `doc/` | 开发文档和工具 | ⭐⭐⭐ |

---

## 3. 核心项目详解

### 3.1 FireClient - iOS/Win32 主项目 ⭐⭐⭐⭐⭐

**项目位置**: `FireClient/`

**用途**: iOS 和 Windows 平台的主项目，包含 Cocos2d-x 引擎集成和游戏逻辑。

**项目结构**:
```
FireClient/
├── Application/                     # 应用程序入口
│   ├── AppDelegate.cpp              # 应用程序委托（启动入口）
│   ├── AppDelegate.h
│   ├── main.m                       # iOS 入口（Objective-C）
│   ├── main.cpp                     # Win32 入口（C++）
│   └── Prefix.pch                   # 预编译头文件
│
├── FireClient/                      # 引擎核心代码
│   ├── Classes/                     # C++ 业务类
│   │   ├── NetworkManager.cpp       # 网络管理
│   │   ├── SceneManager.cpp         # 场景管理
│   │   ├── ResourceManager.cpp      # 资源管理
│   │   └── ...                      # 其他业务类
│   ├── Lua/                         # Lua 绑定代码
│   │   ├── LuaEngine.cpp            # Lua 引擎封装
│   │   ├── LuaBridge.cpp            # C++ ↔ Lua 桥接
│   │   └── ...
│   ├── Network/                     # 网络通信模块
│   │   ├── SocketClient.cpp         # TCP Socket 封装
│   │   ├── ProtocolHandler.cpp      # 协议处理
│   │   └── ...
│   ├── UI/                          # UI 组件（CEGUI 集成）
│   │   ├── CEGUIManager.cpp         # CEGUI 管理器
│   │   ├── WindowManager.cpp        # 窗口管理
│   │   └── ...
│   └── Utils/                       # 工具类
│       ├── FileUtils.cpp            # 文件操作
│       ├── Crypto.cpp               # 加密解密
│       └── ...
│
├── FireClient.sln                   # 历史 Legacy226 解决方案（非 Upgrade30 主线）
├── FireClient.xcodeproj/            # Xcode 项目（iOS）
├── Debug.win32/                     # Win32 Debug 构建输出
└── Release.win32/                   # Win32 Release 构建输出
```

**关键特性**:
- Windows canonical 集成 Cocos2d-x 3.0-oh
- Windows canonical 集成 CEGUI 0.7.9-r5，Legacy226 保留 CEGUI 0.7.1
- Lua 5.1 脚本引擎（LuaJIT 2.0.3）
- tolua++ 1.0.93 C++ ↔ Lua 绑定
- TCP 网络通信模块
- 资源加密与解密
- 崩溃日志收集

**构建步骤（Windows canonical）**:
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 `
  -Configuration Release -Platform Win32 -EngineProfile Upgrade30 `
  -BuildMode SafeChain -StrictRuntimeAudit
# 构建产物: client/resource/bin/Release/MT3.exe
```

**构建步骤（iOS）**:
```bash
# 1. 打开项目
cd FireClient
open FireClient.xcodeproj

# 2. 在 Xcode 中选择配置
# - Scheme: FireClient
# - Device: Generic iOS Device

# 3. 构建项目
# 菜单: Product → Archive

# 4. 导出 IPA
# Organizer → Distribute App → Ad Hoc / App Store
```

---

### 3.2 MT3Win32App - Windows 主程序项目（旧版） ⭐⭐⭐

**项目位置**: `MT3Win32App/`

**用途**: Windows 平台的旧版主程序项目（向后兼容）。

**项目结构**:
```
MT3Win32App/
├── main.cpp                         # 程序入口
├── main.h
├── mt3.cpp                          # 主程序逻辑
├── mt3.h
├── mt3.ico                          # 程序图标
├── mt3.rc                           # 资源文件
├── CrashDump.cpp                    # 崩溃转储
├── CrashDump.h
├── FireClient.win32.vcxproj         # 新版项目文件
├── mt3.win32.vcxproj                # 旧版项目文件
├── Debug.win32/                     # Debug 构建输出
└── Release.win32/                   # Release 构建输出
```

**注意**:
- 该项目已被 FireClient 取代
- 仅用于维护旧版本兼容性
- 新开发建议使用 FireClient 项目

---

### 3.3 Launcher - Windows 启动器 ⭐⭐⭐⭐

**项目位置**: `Launcher/`

**用途**: Windows 平台的游戏启动器，负责热更新、版本检查、启动游戏。

**项目结构**:
```
Launcher/
├── Code/                            # 启动器源代码
│   ├── LauncherDlg.cpp              # 主对话框（UI）
│   ├── UpdateManager.cpp            # 更新管理器
│   ├── VersionCheck.cpp             # 版本检查
│   ├── Downloader.cpp               # 文件下载器
│   └── ...
├── Release/                         # 构建产物
│   └── Launcher.exe                 # 启动器程序
├── Launcher.sln                     # Visual Studio 解决方案
└── Launcher.vcxproj                 # Visual Studio 项目文件
```

**关键特性**:
- HTTP 文件下载（支持断点续传）
- 版本校验（MD5/SHA1）
- 进度显示与取消
- 启动游戏主程序
- 错误处理与日志记录

**工作流程**:
```
1. 用户启动 Launcher.exe
   ↓
2. 连接更新服务器，检查版本
   ↓
3. 对比本地文件与服务器文件列表
   ↓
4. 下载需要更新的文件（差异更新）
   ↓
5. 验证文件完整性（MD5 校验）
   ↓
6. 启动 MT3.exe（游戏主程序）
   ↓
7. 退出 Launcher
```

**构建步骤**:
```bash
# 1. 打开项目
cd Launcher
start Launcher.sln

# 2. 构建项目（Release 配置）
# 菜单: 生成 → 生成解决方案

# 3. 测试
Release/Launcher.exe
```

---

### 3.4 Android 项目 ⭐⭐⭐⭐⭐

**项目位置**: `android/`

**用途**: Android 平台的多渠道项目。

**项目结构**:
```
android/
├── common/                          # 公共代码（所有渠道共享）
│   ├── jni/                         # JNI 本地代码（C++）
│   ├── libs/                        # 第三方库（.so 文件）
│   └── src/                         # Java 公共代码
│
├── LocojoyProject/                  # Locojoy 主渠道项目
│   ├── src/                         # Java 源码
│   │   └── com/locojoy/mt3/         # 包名
│   ├── res/                         # 资源文件
│   ├── jni/                         # JNI 本地代码
│   ├── libs/                        # 库文件
│   ├── assets/                      # 游戏资源（打包到 APK）
│   ├── AndroidManifest.xml          # 应用清单
│   ├── project.properties           # 项目配置
│   └── bin/                         # 构建输出
│       ├── mt3-debug.apk            # Debug APK
│       └── mt3-release.apk          # Release APK
│
├── JoysdkProject/                   # Joysdk 渠道项目
│   └── ...                          # 结构类似 LocojoyProject
│
├── YijieProject/                    # 易接渠道项目
│   └── ...                          # 结构类似 LocojoyProject
│
├── ApkIDE_.apk                      # 大包 APK (1.3GB，含所有资源和调试信息)
└── mt3_locojoy.apk                  # Locojoy 渠道 APK (396MB，实际发布包)
```

**关键特性**:
- NDK 本地代码（C++ 引擎）
- JNI 桥接（Java ↔ C++）
- 多渠道 SDK 集成（支付、分享、登录）
- 资源热更新支持
- 崩溃日志上报

**构建步骤**:
```bash
# 方法 1: 使用 Android Studio
cd android/LocojoyProject
# 用 Android Studio 打开项目
# 菜单: Build → Build APK(s)

# 方法 2: 使用命令行（需要 Android SDK）
cd android/LocojoyProject
ant clean
ant debug              # 构建 Debug APK
# 或
ant release            # 构建 Release APK（需要签名）

# 方法 3: 使用 Gradle（如果已配置）
./gradlew assembleDebug
./gradlew assembleRelease
```

---

## 4. 多平台支持

### 4.1 支持的平台

| 平台 | 状态 | 项目位置 | 构建工具 |
|-----|------|---------|---------|
| **Windows (Win32)** | ✅ 主要平台 | `FireClient/` | Visual Studio 2012+ |
| **Android** | ✅ 主要平台 | `android/LocojoyProject/` | Android Studio / Ant |
| **iOS** | ✅ 主要平台 | `FireClient/` | Xcode 7+ |
| **Windows Phone 8** | ⚠️ 历史支持 | `FireClient/` | Visual Studio 2012 |

### 4.2 平台差异说明

#### Windows 平台
```yaml
特点:
  - 开发和测试最便捷
  - 支持完整的调试工具
  - 资源不加密（方便调试）

适用场景:
  - 日常开发和调试
  - 内部测试版本
  - GM 工具版本

构建产物:
  - MT3.exe (主程序)
  - Launcher.exe (启动器)
  - DLL 依赖库
```

#### Android 平台
```yaml
特点:
  - 多渠道 SDK 集成
  - APK 大小优化（分包、压缩）
  - ARM/ARM64 多架构支持

适用场景:
  - 正式发布版本
  - 渠道分发
  - 玩家使用

构建产物:
  - mt3-release.apk (签名后的发布包)
  - mt3-debug.apk (调试包)
```

#### iOS 平台
```yaml
特点:
  - App Store 审核要求严格
  - 需要苹果开发者账号
  - 必须使用 Xcode 构建

适用场景:
  - App Store 发布
  - TestFlight 内测
  - 企业签名分发

构建产物:
  - MT3.ipa (安装包)
  - MT3.app (应用程序包)
```

### 4.3 多平台资源管理

```
resource/res/               # 所有平台共享的游戏资源
├── script/                 # Lua 脚本（跨平台）
├── ui/                     # UI 布局（CEGUI XML，跨平台）
├── texture/                # 纹理图片（跨平台）
└── sound/                  # 音效音乐（跨平台）

res_win/res/                # Windows 专用资源
├── icon.ico                # 程序图标
└── splash.png              # 启动画面

res_android/res/            # Android 专用资源
├── drawable-hdpi/          # 高分辨率图标
├── drawable-xhdpi/         # 超高分辨率图标
└── mipmap-xxhdpi/          # 启动图标

res_ios/res/                # iOS 专用资源
├── Icon-60@2x.png          # 应用图标（iPhone）
├── Icon-76@2x.png          # 应用图标（iPad）
└── Default-568h@2x.png     # 启动画面
```

**Android 资源生成红线**：`android/LocojoyProject/assets/res/**` 是由 `resource/tools/LJFilePack_打包安卓.bat` 资源打包链生成并供 APK 使用的产物，严禁手工修改。业务资源只允许修改 `resource/res/**`，修改后重新执行打包脚本并通过构建/同步链刷新 `assets/res`。

---

## 5. 资源管理

### 5.1 资源目录结构

```
resource/
├── bin/                             # 资源打包工具
│   ├── packer.exe                   # 资源打包器
│   ├── encryptor.exe                # 资源加密器
│   └── compressor.exe               # 资源压缩器
│
├── cocos2dx/                        # Cocos2d-x 引擎源码
│   ├── cocos/                       # 引擎核心
│   ├── extensions/                  # 引擎扩展
│   ├── external/                    # 第三方库
│   └── platform/                    # 平台适配层
│
├── res/                             # 游戏资源（主目录）
│   ├── script/                      # Lua 脚本
│   │   ├── main.lua                 # 脚本入口
│   │   ├── config.lua               # 配置文件
│   │   ├── logic/                   # 游戏逻辑
│   │   │   ├── login/               # 登录模块
│   │   │   ├── map/                 # 地图模块
│   │   │   ├── battle/              # 战斗模块
│   │   │   ├── shop/                # 商城模块
│   │   │   └── ...
│   │   ├── manager/                 # 管理器
│   │   │   ├── SceneManager.lua     # 场景管理
│   │   │   ├── NetworkManager.lua   # 网络管理
│   │   │   └── ...
│   │   ├── utils/                   # 工具类
│   │   │   ├── StringUtil.lua       # 字符串工具
│   │   │   ├── MathUtil.lua         # 数学工具
│   │   │   └── ...
│   │   └── protodef/                # 协议定义
│   │
│   ├── ui/                          # UI 资源
│   │   ├── layouts/                 # CEGUI XML 布局
│   │   ├── schemes/                 # CEGUI 方案
│   │   ├── imagesets/               # 图片集定义
│   │   └── fonts/                   # 字体文件
│   │
│   ├── texture/                     # 纹理图片
│   │   ├── character/               # 角色纹理
│   │   ├── scene/                   # 场景纹理
│   │   ├── ui/                      # UI 纹理
│   │   └── effect/                  # 特效纹理
│   │
│   ├── sound/                       # 音效音乐
│   │   ├── music/                   # 背景音乐（MP3/OGG）
│   │   └── effect/                  # 音效（WAV）
│   │
│   ├── map/                         # 地图数据
│   │   ├── city/                    # 城镇地图
│   │   ├── dungeon/                 # 副本地图
│   │   └── world/                   # 世界地图
│   │
│   └── config/                      # 配置表
│       ├── monster.xml              # 怪物配置
│       ├── item.xml                 # 道具配置
│       ├── skill.xml                # 技能配置
│       └── ...
│
├── res1/                            # 额外资源（备用）
└── tools/                           # 资源处理工具
    ├── texture_packer/              # 纹理打包工具
    ├── sprite_editor/               # 精灵编辑器
    └── map_editor/                  # 地图编辑器
```

### 5.2 Lua 脚本结构

**脚本位置**: `resource/res/script/`

**核心脚本**:

| 脚本 | 用途 |
|-----|------|
| `main.lua` | Lua 脚本入口，初始化 Lua 环境 |
| `config.lua` | 全局配置（服务器地址、版本号等） |
| `dofile_main.lua` | 脚本加载器，管理模块依赖 |
| `mainticker.lua` | 主循环 Ticker，驱动游戏逻辑 |
| `globalfunctionsforcpp.lua` | C++ 调用 Lua 的全局函数 |

**脚本模块**:

```
logic/                               # 游戏逻辑模块
├── login/                           # 登录模块
│   ├── LoginScene.lua               # 登录场景
│   ├── LoginProtocol.lua            # 登录协议
│   └── LoginManager.lua             # 登录管理器
│
├── map/                             # 地图模块
│   ├── MapScene.lua                 # 地图场景
│   ├── MapData.lua                  # 地图数据
│   └── MapManager.lua               # 地图管理器
│
├── battle/                          # 战斗模块
│   ├── BattleScene.lua              # 战斗场景
│   ├── BattleLogic.lua              # 战斗逻辑
│   └── BattleSkill.lua              # 技能系统
│
├── shop/                            # 商城模块
│   ├── ShopWindow.lua               # 商城窗口
│   ├── ShopData.lua                 # 商品数据
│   └── ShopManager.lua              # 商城管理器
│
└── ...                              # 其他模块

manager/                             # 管理器（全局单例）
├── SceneManager.lua                 # 场景管理
├── NetworkManager.lua               # 网络管理
├── ResourceManager.lua              # 资源管理
├── SoundManager.lua                 # 音效管理
└── ...

utils/                               # 工具类
├── StringUtil.lua                   # 字符串工具
├── MathUtil.lua                     # 数学工具
├── TableUtil.lua                    # 表工具
└── ...

protodef/                            # 协议定义（自动生成）
├── login_pb.lua                     # 登录协议
├── map_pb.lua                       # 地图协议
├── battle_pb.lua                    # 战斗协议
└── ...
```

### 5.3 资源热更新机制

**更新流程**:
```
1. 客户端启动 Launcher.exe (Windows) / 检查更新 (Android/iOS)
   ↓
2. 连接资源服务器，获取资源列表（版本号 + MD5）
   ↓
3. 对比本地资源与服务器资源
   ↓
4. 下载需要更新的资源文件（差异更新）
   ↓
5. 解压资源到本地目录
   ↓
6. 重新启动游戏，加载新资源
```

**支持的热更新内容**:
- ✅ Lua 脚本（无需重新发布）
- ✅ UI 布局（CEGUI XML）
- ✅ 配置表（XML）
- ✅ 纹理图片（PNG/JPG）
- ✅ 音效音乐（MP3/OGG）
- ⚠️ 地图数据（部分支持）
- ❌ C++ 引擎代码（需要重新发布）

---

## 6. 构建与部署

### 6.1 Windows 平台构建

#### 6.1.1 环境准备

```yaml
必需工具:
  - Visual Studio 2013 (PlatformToolset v120)
  - MSBuild 12.0
  - Windows SDK 8.1
  - Visual C++ Redistributable for Visual Studio 2013 (x86)

可选工具:
  - CMake 2.8+
  - Python 2.7
  - LuaJIT 2.0
```

#### 6.1.2 构建步骤

```powershell
# 步骤 1: 从仓库根目录调用 canonical wrapper
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 `
  -Configuration Release -Platform Win32 -EngineProfile Upgrade30 `
  -BuildMode SafeChain -StrictRuntimeAudit

# 步骤 2: 检查构建产物
Get-Item .\client\resource\bin\Release\MT3.exe

# 步骤 3: 运行游戏
Start-Process .\client\resource\bin\Release\MT3.exe
```

#### 6.1.3 编译/链接一致性设置（Windows）

```yaml
通用:
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

#### 6.1.4 打包发布

```bash
# 1. 准备发布目录
mkdir publish_win32
cd publish_win32

# 2. 拷贝构建产物
cp ../FireClient/Release.win32/MT3.exe .
cp ../FireClient/Release.win32/*.dll .

# 3. 拷贝资源
cp -r ../resource/res .

# 4. 拷贝启动器
cp ../Launcher/Release/Launcher.exe .

# 5. 创建压缩包
7z a MT3_Win32_v1.0.zip *
```

---

### 6.2 Android 平台构建

#### 6.2.1 环境准备

```yaml
必需工具:
  - Android SDK (API Level 19+)
  - Android NDK r10e
  - Apache Ant 1.9+ 或 Android Studio

可选工具:
  - Gradle 2.14+
  - Python 2.7
```

#### 6.2.2 构建步骤（Ant）

```bash
# 步骤 1: 配置 SDK/NDK 路径
cd client/android/LocojoyProject
cat > local.properties <<EOF
sdk.dir=/path/to/android-sdk
ndk.dir=/path/to/android-ndk
EOF

# 步骤 2: 构建 JNI 本地代码
cd jni
ndk-build clean
ndk-build -j4
# 输出: libs/armeabi-v7a/libcocos2dcpp.so

# 步骤 3: 生成 Android 打包资源（禁止手拷/手改 assets/res）
cmd /c "cd /d E:\MT3\client\resource\tools && LJFilePack_打包安卓.bat"
# 如需同步到 LocojoyProject/assets/res，使用项目构建脚本的 -SyncRes，
# 不要手动修改 client/android/LocojoyProject/assets/res 下任何文件。

# 步骤 4: 构建 APK
ant clean
ant debug
# 输出: bin/mt3-debug.apk

# 或构建 Release APK（需要签名）
ant release
jarsigner -verbose -keystore my-release-key.keystore \
          bin/mt3-release-unsigned.apk alias_name
zipalign -v 4 bin/mt3-release-unsigned.apk bin/mt3-release.apk
```

#### 6.2.3 构建步骤（Android Studio）

```bash
# 步骤 1: 导入项目
# 打开 Android Studio
# File → Open → 选择 android/LocojoyProject

# 步骤 2: 配置 Gradle（如果需要）
# 查看 build.gradle

# 步骤 3: 构建 APK
# Build → Build APK(s)
# 或 Build → Generate Signed APK（发布版本）

# 步骤 4: 安装到设备
# Run → Run 'app' (Shift+F10)
```

---

### 6.3 iOS 平台构建

#### 6.3.1 环境准备

```yaml
必需工具:
  - macOS 10.10+
  - Xcode 7.0+
  - iOS SDK 8.0+
  - Apple Developer Account

可选工具:
  - CocoaPods (如果使用第三方库)
  - Fastlane (自动化构建)
```

#### 6.3.2 构建步骤

```bash
# 步骤 1: 打开项目
cd client/FireClient
open FireClient.xcodeproj

# 步骤 2: 配置签名
# Xcode → Project Settings → Signing & Capabilities
# - Team: 选择开发团队
# - Provisioning Profile: 自动 / 手动选择

# 步骤 3: 选择目标设备
# Xcode 工具栏 → Generic iOS Device

# 步骤 4: 归档（Archive）
# Product → Archive
# 等待构建完成（5-10 分钟）

# 步骤 5: 导出 IPA
# Organizer → Archives → Distribute App
# 选择发布方式:
#   - Ad Hoc (内测)
#   - App Store (正式发布)
#   - Enterprise (企业签名)

# 步骤 6: 上传到 TestFlight / App Store
# Xcode → Window → Organizer → Upload
```

---

## 7. 开发指南

### 7.1 开发环境搭建

#### Windows 开发环境

```yaml
步骤:
  1. 安装 Visual Studio 2012/2013/2015
  2. 安装 DirectX SDK (June 2010)
  3. 克隆项目代码: git clone <repo_url>
  4. 使用 tools/scripts/Build-MT3-Exe-Canonical.ps1 构建 Windows Upgrade30 主线
  5. 仅在维护 Legacy226 时打开 FireClient/FireClient.sln

常见问题:
  - DirectX SDK 安装失败: 卸载 VC++ 2010 Redistributable
  - 找不到 d3dx9.h: 安装 DirectX SDK
  - 链接错误: 检查库路径配置
```

#### macOS 开发环境

```yaml
步骤:
  1. 安装 Xcode (App Store)
  2. 安装 Command Line Tools: xcode-select --install
  3. 克隆项目代码: git clone <repo_url>
  4. 打开 FireClient/FireClient.xcodeproj
  5. 构建并运行（Cmd+R）

常见问题:
  - 签名错误: 配置开发团队
  - 找不到库: 检查 Framework Search Paths
  - 真机调试: 设备需要加入开发者账号
```

#### Android 开发环境

```yaml
步骤:
  1. 安装 Android Studio
  2. 配置 Android SDK (API Level 19+)
  3. 配置 Android NDK (r10e)
  4. 导入项目: android/LocojoyProject
  5. 构建并运行（Shift+F10）

常见问题:
  - NDK 版本不匹配: 使用 r10e
  - 构建失败: 检查 local.properties
  - 无法安装: 检查设备权限
```

### 7.2 Lua 脚本开发规范

#### 代码风格

```lua
-- 1. 命名规范
local ClassName = {}              -- 类名: 大驼峰
local functionName = function()   -- 函数名: 小驼峰
local local_variable = 10         -- 局部变量: 下划线分隔
GLOBAL_CONSTANT = 100             -- 全局常量: 全大写

-- 2. 注释规范
-- 单行注释使用 --

--[[
多行注释使用 --[[ ... ]]
用于函数说明、模块说明
]]

--- 函数说明（LuaDoc 风格）
-- @param player_id 玩家 ID
-- @param item_id 道具 ID
-- @return 是否成功
local function useItem(player_id, item_id)
    -- ...
end

-- 3. 模块定义
local ModuleName = {}

function ModuleName:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function ModuleName:method()
    -- ...
end

return ModuleName

-- 4. 错误处理
local success, result = pcall(function()
    -- 可能抛出异常的代码
end)
if not success then
    print("错误: " .. tostring(result))
end
```

#### 性能优化

```lua
-- 1. 局部化全局变量
local math_floor = math.floor
local table_insert = table.insert

-- 2. 避免频繁创建表
local reusable_table = {}
function process()
    table.clear(reusable_table)  -- 清空复用
    -- ...
end

-- 3. 使用局部函数
local function helper()
    -- ...
end

-- 4. 缓存计算结果
local cached_result = nil
function expensive_calculation()
    if cached_result then
        return cached_result
    end
    -- 复杂计算
    cached_result = result
    return cached_result
end
```

### 7.3 C++ 引擎开发规范

#### 代码风格

```cpp
// 1. 命名规范
class ClassName {};               // 类名: 大驼峰
void functionName() {}            // 函数名: 小驼峰
int m_memberVariable;             // 成员变量: m_ 前缀
int g_globalVariable;             // 全局变量: g_ 前缀

// 2. 注释规范
/// @brief 函数简要说明
/// @param playerId 玩家 ID
/// @return 是否成功
bool useItem(int playerId, int itemId);

// 3. 内存管理
// 使用智能指针
std::shared_ptr<Player> player = std::make_shared<Player>();

// 手动管理内存时注意释放
Player* player = new Player();
// ...
delete player;
player = nullptr;

// 4. 错误处理
try {
    // 可能抛出异常的代码
} catch (const std::exception& e) {
    CCLOG("错误: %s", e.what());
}
```

---

## 8. 常见问题 FAQ

### Q1: 如何构建 Windows 版本？

**A**: Windows 主线使用 canonical wrapper 生成 Upgrade30；FireClient.sln 仅用于 Legacy226 历史链路。

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 `
  -Configuration Release -Platform Win32 -EngineProfile Upgrade30 `
  -BuildMode SafeChain -StrictRuntimeAudit
```

**详细步骤**: 参见 [6.1 Windows 平台构建](#61-windows-平台构建)

---

### Q2: Android APK 太大如何优化？

**A**: 使用以下方法优化 APK 大小：

```yaml
优化方法:
  1. 资源压缩:
     - 纹理使用 ETC1/ETC2 格式
     - 音频使用 OGG 格式（压缩率高）

  2. 代码混淆:
     - 启用 ProGuard (build.gradle)
     - 混淆 Java 代码

  3. 移除未使用资源:
     - 使用 shrinkResources true
     - 删除无用的图片和音频

  4. 分包策略:
     - 使用 APK 分包（armeabi-v7a / arm64-v8a）
     - 动态下载资源包

  5. 资源热更新:
     - 基础包只包含启动资源
     - 其他资源首次运行时下载
```

---

### Q3: Lua 脚本如何调试？

**A**: 有多种 Lua 调试方法：

```yaml
方法 1: 使用 print 调试
  - 在 Lua 脚本中添加 print() 语句
  - 查看控制台输出

方法 2: 使用 Cocos Studio Lua Debugger
  - 安装 Cocos Studio
  - 连接到运行中的游戏进程
  - 设置断点、查看变量

方法 3: 使用 ZeroBrane Studio
  - 下载 ZeroBrane Studio
  - 配置远程调试
  - 连接到游戏进程

方法 4: 使用 MobDebug
  - 在 Lua 脚本中集成 mobdebug.lua
  - 启动调试服务器
  - 远程连接调试
```

---

### Q4: iOS 真机调试提示签名错误？

**A**: 配置开发证书和 Provisioning Profile：

```yaml
步骤:
  1. 登录 Apple Developer 账号
  2. 创建开发证书（Development Certificate）
  3. 创建 App ID（Bundle Identifier）
  4. 创建 Provisioning Profile（Development）
  5. 下载并安装证书和 Profile
  6. Xcode 项目配置:
     - Signing & Capabilities → Team: 选择团队
     - Automatically manage signing: 勾选
  7. 连接设备，Build & Run
```

---

### Q5: 如何添加新的 Lua 模块？

**A**: 按照以下步骤添加：

```bash
# 1. 在 resource/res/script/logic/ 下创建新模块目录
mkdir resource/res/script/logic/newmodule

# 2. 创建模块文件
cat > resource/res/script/logic/newmodule/NewModule.lua <<EOF
local NewModule = {}

function NewModule:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function NewModule:init()
    print("NewModule initialized")
end

return NewModule
EOF

# 3. 在 dofile_main.lua 中添加引用
# require "logic/newmodule/NewModule"

# 4. 重新启动游戏测试
```

---

### Q6: 游戏崩溃如何排查？

**A**: 使用崩溃日志分析：

```yaml
Windows 平台:
  1. 崩溃时生成 .dmp 文件
  2. 使用 Visual Studio 打开 .dmp
  3. 查看调用堆栈
  4. 定位崩溃代码

Android 平台:
  1. 查看 logcat 日志: adb logcat
  2. 查看 tombstone 文件: /data/tombstones/
  3. 使用 ndk-stack 解析堆栈:
     adb logcat | ndk-stack -sym obj/local/armeabi-v7a

iOS 平台:
  1. 连接设备到 Xcode
  2. Window → Devices and Simulators
  3. 查看 Crash Logs
  4. 使用 symbolicatecrash 符号化
```

---

### Q7: 如何集成新的第三方 SDK？

**A**: 按照平台分别集成：

```yaml
Android 集成:
  1. 将 SDK 的 .jar 文件拷贝到 libs/
  2. 将 SDK 的 .so 文件拷贝到 jni/libs/
  3. 在 AndroidManifest.xml 中添加权限和组件
  4. 在 Java 代码中调用 SDK API
  5. 测试功能

iOS 集成:
  1. 将 SDK 的 .framework 拷贝到项目
  2. Xcode: Build Phases → Link Binary With Libraries
  3. 在 Objective-C/C++ 代码中调用 SDK API
  4. 测试功能

Windows 集成:
  1. 将 SDK 的 .lib 文件拷贝到项目
  2. Visual Studio: 配置包含目录和库目录
  3. 在 C++ 代码中调用 SDK API
  4. 测试功能
```

---

### Q8: 如何实现热更新？

**A**: 热更新流程：

```yaml
服务器端:
  1. 部署资源服务器（HTTP/CDN）
  2. 准备资源包:
     - 版本号: version.txt
     - 文件列表: filelist.txt (文件名 + MD5)
     - 资源文件: *.zip (差异包)

客户端:
  1. 启动时检查版本
  2. 对比本地文件列表与服务器文件列表
  3. 下载需要更新的文件
  4. 解压到本地资源目录
  5. 重启游戏

支持热更新的内容:
  ✅ Lua 脚本
  ✅ UI 布局 (CEGUI XML)
  ✅ 配置表 (XML)
  ✅ 纹理图片
  ✅ 音效音乐
  ❌ C++ 引擎代码（需要重新发布）
```

---

## 9. 文档维护信息

| 项目 | 信息 |
|-----|------|
| **项目名称** | MT3 梦幻西游 MG 版本客户端 |
| **引擎版本** | Cocos2d-x 2.x |
| **脚本语言** | Lua 5.1 (LuaJIT) |
| **支持平台** | Windows, Android, iOS |
| **文档版本** | v1.0 |
| **最后更新** | 2025-11-27 |
| **维护者** | MT3 客户端开发团队 |

---

## 10. 快速链接

### 10.1 核心项目

- [FireClient - iOS/Win32 主项目](FireClient/)
- [MT3Win32App - Windows 主程序](MT3Win32App/)
- [Launcher - Windows 启动器](Launcher/)
- [Android - Android 多渠道项目](android/)

### 10.2 资源与工具

- [游戏资源目录](resource/res/)
- [Lua 脚本](resource/res/script/)
- [第三方 SDK](3rdplatform/)
- [开发文档](doc/)

### 10.3 构建工具

- [Cocos2d-x 引擎源码](resource/cocos2dx/)
- [tolua++ Lua 绑定](tolua++-pkgs/)
- [资源打包工具](resource/bin/)

---

## 11. 贡献与反馈

如有问题、建议或发现文档错误，请通过以下方式联系：

- **提交 Issue**: 到项目 Git 仓库提交问题
- **技术讨论**: 联系 MT3 客户端开发团队
- **文档更新**: 提交 Pull Request 或联系文档维护者

---

## 12. API 接口与示例

### 12.1 协议注册

```lua
-- 在 protodef/protocols.lua 中集中注册
-- 将消息 ID 与消息构造函数绑定
-- 参考：resource/res/script/protodef/protocols.lua
function RegisterLuaProtocols()
  local m
  m = require("protodef.fire.pb.creqroleinfo")
  LuaProtocolManager.getInstance():RegisterLuaProtocolCreator(786508, m.Create)
  -- ... 其他协议注册
end
```

### 12.2 请求发送示例

```lua
local m = require("protodef.fire.pb.creqroleinfo")
local req = m.Create()
-- 按需设置字段
-- req.xxx = value
gGetNetConnection():send(req)
```

### 12.3 响应处理

- 协议响应由已注册的协议与处理器驱动，处理逻辑位于 `resource/res/script/handler/` 目录。
- 服务器列表与端点由 `GetServerInfo()` 动态获取并通过 `gGetLoginManager()` 保存与读取（见 `logic/selectserverentry.lua` 与 `logic/selectserversdialog.lua`）。

### 12.4 服务器列表与端点选择流程

```lua
-- 拉取服务器列表（本地为空时从登录服获取）
local servers = GetServerInfo():getAllServers()
if servers:size() == 0 then
  GetServerInfo():setConnectFromLogin(true)
  GetServerInfo():connetGetServerlist()
end

-- 选择默认区服并设置端点
gGetLoginManager():SetSelectServerInfo(areaName, serverName, ip, tostring(port), 0)
```

说明:
- 服务器列表加载与默认服选择见 `logic/selectserverentry.lua` 的 `connetGetServerInfo/TryGetFastLoginServer`。
- 具体区服数据映射见 `logic/selectserversdialog.lua:OnInit`（将 `area/server/ip/port/type` 归入 `m_AreaServersMap`）。

### 12.5 登录与进入世界流程

```lua
-- 连接参数来自 LoginManager 当前选择
local host = gGetLoginManager():GetHost()
local port = gGetLoginManager():GetPort()

-- 建立连接（ARCFOUR 加密），并进入等待界面
gGetLoginManager():ClearConnections()
gGetGameApplication():CreateConnection(account, key, host, port, true, servername, area, serverKey, channelId)
gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
```

说明:
- 进入世界的关键响应通常为 `senterworld`，登录回退为 `sreturnlogin`；两者的注册在 `protodef/protocols.lua` 中。

### 12.6 角色信息获取流程

```lua
-- 请求角色信息
local m_creqroleinfo = require("protodef.fire.pb.creqroleinfo")
local req = m_creqroleinfo.Create()
gGetNetConnection():send(req)

-- 典型响应
-- sretroleprop / srefreshuserexp / srefreshhp 等数据增量
```

说明:
- `creqroleinfo` 与 `sretroleprop/srefreshuserexp/srefreshhp` 的注册在 `protodef/protocols.lua`。
- 具体 UI/数据刷新位于 `resource/res/script/handler/` 目录中的相应处理器。

### 12.7 负载检查与心跳

```lua
-- 负载检测，进入前确定可用性
gGetLoginManager():CheckLoad(ip, port, key)

-- 服务器时间/状态通知
-- 例如：sgametime / snotifydeviceinfo 等
```

说明:
- 负载检测调用与结果处理见 `logic/selectserverentry.lua` 的 `checkLoad/SetServerLoad/setServerStatus`。

### 12.8 错误与踢出

- 错误提示：`serror`（注册见 `protodef/protocols.lua`）。
- 踢出通知：`ckick/sgacdkickoutmsg` 等（注册见 `protodef/protocols.lua`）。

### 12.9 处理器目录与约定

- 响应处理器位于 `resource/res/script/handler/`，以 `fire_pb_*.lua` 命名分类（如 `fire_pb_battle.lua`、`fire_pb_item.lua`）。
- 发送约定：所有请求由 `pb` 模块 `Create()` 构造，通过 `gGetNetConnection():send(msg)` 发送。

### 12.10 API 分类与典型消息映射

登录与世界进入:
- `senterworld` 进入世界，初始化主角、背包、称号、配置等（`resource/res/script/handler/fire_pb.lua:610-686`）
- `ssendqueueinfo/ssendslowqueueinfo` 排队提示（`resource/res/script/handler/fire_pb.lua:10-35`）
- `snotifydeviceinfo` 设置登录 IP（`resource/res/script/handler/fire_pb.lua:604-607`）
- `sgametime` 同步服务器时间（`resource/res/script/handler/fire_pb.lua:258-274`）
- `serror` 错误提示（`resource/res/script/handler/fire_pb.lua:227-249`）
- `sgacdkickoutmsg/sgacdkickoutmsg1` 踢出通知（`resource/res/script/handler/fire_pb.lua:50-88`）

角色与属性:
- `sretroleprop` 返回角色属性（`resource/res/script/handler/fire_pb_discards.lua:126-129`）
- `srefreshhp` 刷新角色生命（`resource/res/script/handler/fire_pb.lua:373-382`）
- `srefreshuserexp` 刷新角色经验（`resource/res/script/handler/fire_pb.lua:385-391`）
- `sserverlevel` 服务器等级信息（`resource/res/script/handler/fire_pb.lua:392-403`）

命名与改名:
- `sgivename` 服务器分配推荐名（`resource/res/script/handler/fire_pb.lua:99-105`）
- `smodifyrolename` 改名结果（注册见 `resource/res/script/protodef/protocols.lua:163-164`）

队伍与社交:
- `sanswerroleteamstate` 队伍状态刷新（`resource/res/script/handler/fire_pb.lua:3-9`）
- `steamvote/cteamvoteagree` 队伍投票（`resource/res/script/handler/fire_pb.lua:107-132`）

背包与物品:
- 进入世界后通过 `RoleItemManager` 刷新背包（`resource/res/script/handler/fire_pb.lua:650-658`）
- 装备效果检查（`resource/res/script/handler/fire_pb.lua:660-664`）

平台信息:
- `sserveridresponse` 向各渠道上报服务器信息（`resource/res/script/handler/fire_pb.lua:134-175`）

### 12.11 示例：登录流程调用闭环

```lua
-- 1) 选择区服并设置端点
gGetLoginManager():SetSelectServerInfo(area, servername, ip, tostring(port), 0)

-- 2) 负载检查（可选）
gGetLoginManager():CheckLoad(ip, port, key)

-- 3) 建立连接并进入登录等待
gGetLoginManager():ClearConnections()
gGetGameApplication():CreateConnection(account, key, host, port, true, servername, area, serverKey, channelId)
gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)

-- 4) 服务器返回进入世界
-- senterworld: 初始化主角、背包、称号、配置、进入场景
-- 参考: resource/res/script/handler/fire_pb.lua:610-686

-- 5) 后续增量刷新
-- sretroleprop/srefreshuserexp/srefreshhp 等，驱动 UI 与数据层更新
```

说明:
- 登录成功后的进入世界及数据初始化详见 `senterworld` 处理器。
- 具体 UI 刷新与数据更新分布在 `handler`、`logic` 模块内。

### 12.12 常用消息 ID 索引

```text
786438  senterworld         进入世界
786439  sgametime           服务器时间同步
786451  serror              错误提示
786501  sgacdkickoutmsg     踢出通知
786519  sgacdkickoutmsg1    踢出通知（变体）
786475  sgivename           推荐角色名
786446  srefreshhp          刷新角色生命
786445  srefreshuserexp     刷新角色经验
786454  sretroleprop        返回角色属性
786392  sserverlevel        服务器等级（编号以实际注册为准，参考协议文件）
786515  snotifydeviceinfo   登录设备信息（含 IP）
```

来源:
- 参考 `resource/res/script/protodef/protocols.lua:135-200` 的注册条目。

### 12.13 服务器列表数据结构

来源: `logic/selectserversdialog.lua:265-340` 将 `GetServerInfo()` 提供的数据组织为 `m_AreaServersMap`

字段说明:
- `areaID` (`I`): 大区编号
- `serverid` (`D`): 服务器唯一 ID
- `serverArea` (`A`): 大区名称
- `serverName` (`N`): 服务器显示名（可能包含排序号）
- `serverIp` (`P`): 服务器 IP
- `serverPort` (`T`): 端口（低位）
- `serverState` (`S`): 状态（如维护/爆满）
- `serverStandby` (`B`): 备用端口数量（用于随机选取端口）
- `serverType` (`C`): 服务器类型（如点卡服）
- `serverOpenTime` (`KS`): 开服时间
- `serverFlag` (`NS`): 推荐/新服标志（`0` 推荐，`1` 新服）

客户端映射:
- `servername`、`ip`、`port`、`status`、`standby`、`type`、`opentime`、`flag`、`sort` 等，以区服名为键组织在 `m_AreaServersMap[area].servers`

### 12.14 进入世界数据载荷（示例）

来源: `resource/res/script/handler/fire_pb.lua:610-686`

关键字段:
- `mydata.rolecreatetime`: 角色创建时间
- `mydata.factionvalue`: 帮贡/派系值
- `mydata.lineconfigmap`: 分线配置
- `mydata.components`: 角色外观组件（用于 `UpdateSpriteComponent`）
- `mydata.learnedformsmap`: 已学习阵法
- `mydata.baginfo`: 背包信息（进入后清空并批量加入）
- `mydata.depotnameinfo`: 仓库命名信息
- `mydata.pets`: 宠物列表
- `mydata.petmaxnum`: 宠物上限
- `mydata.sysconfigmap`: 客户端系统配置
- `mydata.titles`: 称号列表

增量刷新:
- 生命: `srefreshhp.hp` → `gGetDataManager():RefreshRoleHp`
- 经验: `srefreshuserexp.curexp` → `gGetDataManager():RefreshCurExp`
- 服务器等级: `sserverlevel.slevel/newleveldays` → `gGetDataManager()` 与 UI 刷新

### 12.15 错误码与错误处理

来源: `resource/res/script/handler/fire_pb.lua:227-249`

- 错误码表: `protodef.rpcgen.fire.pb.errorcodes`
- 常见映射:
  - `AddItemToBagException` → `100001`
  - `NotEnoughMoney` → `100003`
  - `EquipPosNotSuit` → `100068`
  - `EquipLevelNotSuit` → `100065`
  - `EquipSexNotSuit` → `100066`
- 提示接口: `GetCTipsManager():AddMessageTip(str)` 或 `gGetMessageManager():AddConfirmBox(...)`

### 12.16 请求构造与发送约定

### 12.17 字段表：角色改名（CModifyRoleName / SModifyRoleName）

请求：`CModifyRoleName`（`resource/res/script/protodef/fire/pb/cmodifyrolename.lua:7-19, 30-39`）
- `PROTOCOL_TYPE`: `786506`
- `newname` `wstring` 示例：`"新名字"`
- `itemkey` `int32` 示例：`12345`

响应：`SModifyRoleName`（`resource/res/script/protodef/fire/pb/smodifyrolename.lua:7-19, 30-39`）
- `PROTOCOL_TYPE`: `786507`
- `roleid` `int64` 示例：`10000001`
- `newname` `wstring` 示例：`"新名字"`

处理器：`fire_pb_attr.lua:71-113`
- 自己角色更新：`GetMainCharacterData().strName = newname`（`fire_pb_attr.lua:79-81`）
- 他人角色更新：`character:SetName(newname)`（`fire_pb_attr.lua:83-85`）
- 队伍成员名更新：`GetTeamManager():UpdateMemberName(roleId,name)`（`fire_pb_attr.lua:103-107`）

示例（闭环）：
```lua
local req = require("protodef.fire.pb.cmodifyrolename").Create()
req.newname = "新名字"
req.itemkey = 12345
LuaProtocolManager.getInstance():send(req)
-- 等待 SModifyRoleName 响应，处理器更新 UI 与数据
```

### 12.18 字段表：队伍投票（STeamVote / CTeamVoteAgree）

服务器推送：`STeamVote`（`resource/res/script/protodef/fire/pb/steamvote.lua:7-19, 30-50`）
- `PROTOCOL_TYPE`: `786524`
- `flag` `int32` 示例：`1`
- `parms` `list<wstring>` 示例：`{"邀请人","被操作对象"}`

客户端响应：`CTeamVoteAgree`（`resource/res/script/protodef/fire/pb/cteamvoteagree.lua:7-18, 29-36`）
- `PROTOCOL_TYPE`: `786525`
- `result` `char` 示例：`0`（同意），`1`（拒绝）

处理器：`fire_pb.lua:107-132`
- 构建提示消息与两按钮，点击后发送 `CTeamVoteAgree`（`fire_pb.lua:115-129`）

示例（闭环）：
```lua
-- 收到 STeamVote 后 UI 弹出并发送结果
local req = require("protodef.fire.pb.cteamvoteagree").Create()
req.result = 0 -- 1 为拒绝
LuaProtocolManager.getInstance():send(req)
```

### 12.19 字段表：队列提示（SSendQueueInfo / SSendSlowQueueInfo）

`SSendQueueInfo`（`resource/res/script/protodef/fire/pb/ssendqueueinfo.lua:7-20, 31-42`）
- `PROTOCOL_TYPE`: `786480`
- `order` `int32` 当前排位
- `queuelength` `int32` 队列长度
- `minutes` `int32` 预计等待分钟

`SSendSlowQueueInfo`（`resource/res/script/protodef/fire/pb/ssendslowqueueinfo.lua:7-20, 31-42`）
- `PROTOCOL_TYPE`: `786484`
- `order` `int32`
- `queuelength` `int32`
- `second` `int32` 预计等待秒数

处理器：`fire_pb.lua:10-21, 24-35`
- 退出到登录并展示排队界面，刷新信息（`LoginWaitingDialog.DestroyDialog()` / `loginqueuedialog:RefreshInfo*`）

### 12.20 字段表：时间 / 设备 / 错误

`SGameTime`（`resource/res/script/protodef/fire/pb/sgametime.lua:7-18, 29-37`）
- `PROTOCOL_TYPE`: `786439`
- `servertime` `int64` 服务器时间戳（毫秒）

`SNotifyDeviceInfo`（`resource/res/script/protodef/fire/pb/snotifydeviceinfo.lua:7-18, 29-36`）
- `PROTOCOL_TYPE`: `786515`
- `ip` `wstring` 登录 IP

`SError`（`resource/res/script/protodef/fire/pb/serror.lua:7-18, 29-36`）
- `PROTOCOL_TYPE`: `786451`
- `error` `int32` 错误码（映射见 `protodef.rpcgen.fire.pb.errorcodes`）

处理器：`fire_pb.lua:227-274, 604-607`
- 时间同步与设备信息更新；错误提示通过 `GetCTipsManager()/MessageManager` 展示

### 12.21 字段表：角色属性返回（SRetRoleProp）

`SRetRoleProp`（`resource/res/script/protodef/fire/pb/sretroleprop.lua:7-19, 30-55`）
- `PROTOCOL_TYPE`: `786454`
- `roleid` `int64`
- `datas` `map<int32,float>` 属性键值对（如伤害、速度等）

处理器：参考 `handler` 模块按属性类型更新数据层与 UI

### 12.22 战斗协议字段与闭环

观看战斗开始：`SSendWatchBattleStart`（`resource/res/script/protodef/fire/pb/battle/ssendwatchbattlestart.lua:7-27, 39-52`）
- `PROTOCOL_TYPE`: `793444`
- 字段：`enemyside:int32`、`leftcount:int32`、`battletype:int32`、`roundnum:int32`、`friendsformation:int32`、`enemyformation:int32`、`friendsformationlevel:int32`、`enemyformationlevel:int32`、`background:char`、`backmusic:char`、`battlekey:int64`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:243-265`

回合演示结束：`SSendRoundPlayEnd`（`resource/res/script/protodef/fire/pb/battle/ssendroundplayend.lua:7-18, 29-36`）
- `PROTOCOL_TYPE`: `793462`
- 字段：`fighterid:int32`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:221-240`

操作状态：`SSendBattlerOperateState`（`resource/res/script/protodef/fire/pb/battle/ssendbattleroperatestate.lua:7-19, 30-39`）
- `PROTOCOL_TYPE`: `793450`
- 字段：`battleid:int32`、`state:int32`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:271-290`

已用物品列表：`SSendAlreadyUseItem`（`resource/res/script/protodef/fire/pb/battle/ssendalreadyuseitem.lua:7-18, 29-52`）
- `PROTOCOL_TYPE`: `793458`
- 字段：`itemlist:map<int,int>`（物品ID→次数）
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:292-303`

Boss 血量同步：`SSynchroBossHp`（`resource/res/script/protodef/fire/pb/battle/ssynchrobosshp.lua:7-23, 34-51`）
- `PROTOCOL_TYPE`: `793459`
- 字段：`bossmonsterid:int32`、`flag:char`、`maxhp:int64`、`hp:int64`、`rolename:wstring`、`changehp:int64`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:305-315`

角色初始属性：`SSendRoleInitAttrs`（`resource/res/script/protodef/fire/pb/battle/ssendroleinitattrs.lua:7-18, 29-51`）
- `PROTOCOL_TYPE`: `793455`
- 字段：`roleinitattrs:map<int,float>`（不含 `EXP/LEVEL/NEXP`）
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:317-330`

战斗标记/指挥：
- `SSetCommander`（`resource/res/script/protodef/fire/pb/battle/battleflag/ssetcommander.lua:7-18, 29-36`）→ 设置队伍指挥
- `SSetBattleFlag`（`resource/res/script/protodef/fire/pb/battle/battleflag/ssetbattleflag.lua:7-20, 31-41`）→ 设置/清除战斗标记
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:332-349`

闭环示例：观看战斗
```lua
-- 服务器推送 SSendWatchBattleStart
-- 客户端设置阵法/等级与背景后调用 BeginWatchScene
-- 回合演示结束由 SSendRoundPlayEnd 通知，驱动刷新与延迟演示
```

### 12.23 道具协议字段与闭环

强化道具使用提示：`SUseEnhancementItem`（`resource/res/script/protodef/fire/pb/item/suseenhancementitem.lua:7-17, 29-36`）
- `PROTOCOL_TYPE`: `786446`（同名编号；具体以文件为准）
- 字段：`equippos:int32`（目标装备位）
- 处理器：`resource/res/script/logic/item/mainpackhelper.lua:140-178`（播放效果→请求 `CGetItemTips`）

获取物品 Tips：`CGetItemTips/SGetItemTips`（`resource/res/script/protodef/fire/pb/item/cgetitemtips.lua` / `sgetitemtips.lua:307-341`）
- 客户端请求字段：`packid:int32`、`keyinpack:int32`
- 服务器返回：`tips:OctetsStream`（物品详细属性）
- 处理器：`resource/res/script/handler/fire_pb_item.lua:307-341`

闭环示例：强化道具
```lua
-- 收到 SUseEnhancementItem 后，播放装备槽效果
local p = require("protodef.fire.pb.item.cgetitemtips").Create()
p.packid = fire.pb.item.BagTypes.EQUIP
p.keyinpack = equipItemKey
LuaProtocolManager.getInstance():send(p)
-- SGetItemTips 返回后更新 Tips 与 UI
```

### 12.24 道具增删与位置变更字段表

新增道具：`SItemAdded`（`resource/res/script/protodef/fire/pb/item/sitemadded.lua`）
- 字段：`items:vector<{itemid,itemnum}>`（处理器播放新增特效：`resource/res/script/handler/fire_pb_item.lua:216-227`）

删除道具：`SDelItem`（`resource/res/script/protodef/fire/pb/item/sdelitem.lua`）
- 字段：`packid:int32`、`itemkey:int32`
- 处理器：`resource/res/script/handler/fire_pb_item.lua:276-305`（移除、刷新、更新摊位/修理提示）

位置变更：`SItemPosChange`（`resource/res/script/protodef/fire/pb/item/sitemposchange.lua`）
- 字段：`packid:int32`、`keyinpack:int32`、`pos:int32`
- 处理器：`resource/res/script/handler/fire_pb_item.lua:257-273`

### 12.25 战斗结算与 PVP 匹配字段表

1v1 匹配结果：`SPvP1MatchResult`（`resource/res/script/protodef/fire/pb/battle/pvp1/spvp1matchresult.lua:8-19, 30-41`）
- `PROTOCOL_TYPE`: `793542`
- 字段：`target: PvP1RoleSingleMatch`（`rpcgen/fire/pb/battle/pvp1/pvp1rolesinglematch.lua:9-13, 16-23`）
  - `roleid:int64`、`level:short`、`shape:int32`、`school:int32`
- 处理器桥接：`resource/res/script/handler/fire_pb_battle.lua:35-39`

3v3 匹配结果：`SPvP3MatchResult`（`resource/res/script/protodef/fire/pb/battle/pvp3/spvp3matchresult.lua:8-19, 30-55`）
- `PROTOCOL_TYPE`: `793645`
- 字段：`targets:list<PvP3RoleSingleMatch>`（`rpcgen/fire/pb/battle/pvp3/pvp3rolesinglematch.lua:9-13, 16-23`）
  - `roleid:int64`、`level:short`、`shape:int32`、`school:int32`
- 处理器桥接：`resource/res/script/handler/fire_pb_battle.lua:59-63`

5v5 匹配结果：`SPvP5MatchResult`（`resource/res/script/protodef/fire/pb/battle/pvp5/spvp5matchresult.lua:7-17, 27-34`）
- `PROTOCOL_TYPE`: `793669`
- 处理器桥接：`resource/res/script/handler/fire_pb_battle.lua:95-99`

说明：具体结算 UI 与数据更新在 `logic/jingji/jingjiprotocol.lua` 中实现，通过处理器桥接。

### 12.26 地图场景切换与分线

进入场景：`SRoleEnterScene`（`resource/res/script/protodef/fire/pb/move/sroleenterscene.lua:27-44, 55-79`）
- `PROTOCOL_TYPE`: `790441`
- 字段：
  - `ownername:wstring`（场景所属者）
  - `destpos:Pos`（目标坐标；`rpcgen/fire/pb/move/pos.lua`）
  - `destz:char`（层级，高层/低层）
  - `changetype:int32`（切换类型，见枚举：`ENTER_LINE_SCENCE/ENTER_COMMON_SCENCE` 等）
  - `sceneid:int64`（场景 ID）
  - `weatherid:char`（天气）
  - `tipsparm:wstring`（提示参数）
- 处理器：`resource/res/script/handler/fire_pb_move.lua:262-345`，核心调用 `gGetScene():ChangeMap(sceneid, pos, ownername, changetype, destz == 1)`。

相关移动/状态：
- 角色移动：`SRoleMove` → `resource/res/script/handler/fire_pb_move.lua:47-66`（绘制回退、继续移动或 NPC 移动）
- 角色定点定位：`SSetRoleLocation` → `resource/res/script/handler/fire_pb_move.lua:13-36`
- 场景状态：`SUpdateRoleSceneState` / `SUpdateNpcSceneState` → `resource/res/script/handler/fire_pb_move.lua:85-107`
- 角色进入/离开屏幕：`SAddUserScreen` / `SRemoveUserScreen` → `resource/res/script/handler/fire_pb_move.lua:364-399, 174-190`

闭环示例：切换至目标场景
```lua
-- 服务器推送 SRoleEnterScene
-- 客户端执行 ChangeMap，并根据 changetype/destz 处理分线与层级
-- 如在重连且处于战斗中，先 EndBattleScene 再切换（fire_pb_move.lua:290-298）
```

### 12.27 战斗操作状态（SSendBattlerOperateState）

操作阶段状态更新：`SSendBattlerOperateState`（`resource/res/script/protodef/fire/pb/battle/ssendbattleroperatestate.lua:7, 17-19, 30-41`）
- `PROTOCOL_TYPE`: `793450`
- 字段：`battleid:int32`、`state:int32`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:270-290`

闭环示例：单位操作状态变更
```lua
-- 服务器推送 SSendBattlerOperateState
-- 客户端：根据 battleid 找到战斗单位并更新状态
-- 若 state==2 且主角/宠物处于操作阶段，结束本回合操作（fire_pb_battle.lua:270-290）
```

### 12.28 生死战点赞与视频观看

点赞请求：`CLiveDieBattleGiveRose`（`resource/res/script/protodef/fire/pb/battle/livedie/clivediebattlegiverose.lua:7, 13-19, 29-37`）
- `PROTOCOL_TYPE`: `793844`
- 字段：`vedioid:wstring`

点赞回执：`SLiveDieBattleGiveRose`（`resource/res/script/protodef/fire/pb/battle/livedie/slivediebattlegiverose.lua:7, 13-21, 31-44`）
- `PROTOCOL_TYPE`: `793845`
- 字段：`vedioid:wstring`、`rosenum:int32`、`roseflag:int32`

观看请求：`CLiveDieBattleWatchVideo`（`resource/res/script/protodef/fire/pb/battle/livedie/clivediebattlewatchvideo.lua:7, 13-19, 29-37`）
- `PROTOCOL_TYPE`: `793846`
- 字段：`vedioid:wstring`

协议注册：`resource/res/script/protodef/protocols.lua:331-332, 349-350`
- `793844 → CLiveDieBattleGiveRose`、`793845 → SLiveDieBattleGiveRose`

闭环示例：点赞与观看
```lua
-- 点击“赞”发送 CLiveDieBattleGiveRose（logic/shengsizhan/shengsibangdlg.lua:361-374）
-- 服务器推送 SLiveDieBattleGiveRose，客户端更新 UI（logic/shengsizhan/shengsibangdlg.lua:452-458）
-- 点击“录像”发送 CLiveDieBattleWatchVideo（logic/shengsizhan/shengsibangdlg.lua:351-359）
```

### 12.29 回合演示结束（SSendRoundPlayEnd）

回合演示结束：`SSendRoundPlayEnd`（`resource/res/script/protodef/fire/pb/battle/ssendroundplayend.lua:7, 13-19, 29-38`）
- `PROTOCOL_TYPE`: `793462`
- 字段：`fighterid:int32`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:221-240`

闭环示例：结束单位演示并刷新
```lua
-- 服务器推送 SSendRoundPlayEnd
-- 客户端：将 fighterid 转换为战斗侧 ID，设置演示结束并刷新（fire_pb_battle.lua:221-240）
```

### 12.30 观看战斗开始（SSendWatchBattleStart）

观看战斗开始：`SSendWatchBattleStart`（`resource/res/script/protodef/fire/pb/battle/ssendwatchbattlestart.lua:7, 13-28, 39-68`）
- `PROTOCOL_TYPE`: `793444`
- 字段：
  - `enemyside:int32`、`leftcount:int32`、`battletype:int32`、`roundnum:int32`
  - `friendsformation:int32`、`enemyformation:int32`
  - `friendsformationlevel:int32`、`enemyformationlevel:int32`
  - `background:char`、`backmusic:char`、`battlekey:int64`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:242-266`

闭环示例：进入观看场景
```lua
-- 服务器推送 SSendWatchBattleStart
-- 客户端：设置双方阵法/等级与战斗键，进入观看场景（fire_pb_battle.lua:242-266）
```

### 12.31 已使用道具列表（SSendAlreadyUseItem）

道具使用同步：`SSendAlreadyUseItem`（`resource/res/script/protodef/fire/pb/battle/ssendalreadyuseitem.lua:7, 13-19, 29-40, 42-53`）
- `PROTOCOL_TYPE`: `793458`
- 字段：`itemlist:map<int32,int32>`（道具ID → 使用次数或状态）
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:292-303`

闭环示例：刷新二次使用道具
```lua
-- 服务器推送 SSendAlreadyUseItem
-- 客户端：清空并重建使用列表，刷新双栏道具（fire_pb_battle.lua:292-303）
```

### 12.32 Boss 血量同步（SSynchroBossHp）

Boss 血量同步：`SSynchroBossHp`（`resource/res/script/protodef/fire/pb/battle/ssynchrobosshp.lua:7, 13-23, 34-43, 45-53`）
- `PROTOCOL_TYPE`: `793459`
- 字段：`bossmonsterid:int32`、`flag:char`、`maxhp:int64`、`hp:int64`、`rolename:wstring`、`changehp:int64`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:305-315`

闭环示例：更新血条 UI
```lua
-- 服务器推送 SSynchroBossHp
-- 客户端：打开血条界面并初始化信息（fire_pb_battle.lua:305-315）
```

### 12.33 队伍指挥与战旗（SSetCommander/SSetBattleFlag）

设置指挥：`SSetCommander`（`resource/res/script/protodef/fire/pb/battle/battleflag/ssetcommander.lua:7, 13-19, 29-37`）
- `PROTOCOL_TYPE`: `793888`
- 字段：`roleid:int64`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:331-338`

设置战旗：`SSetBattleFlag`（`resource/res/script/protodef/fire/pb/battle/battleflag/ssetbattleflag.lua:7, 13-21, 31-37, 39-44`）
- `PROTOCOL_TYPE`: `793890`
- 字段：`opttype:char`、`index:char`、`flag:wstring`
- 处理器：`resource/res/script/handler/fire_pb_battle.lua:339-349`

闭环示例：清空或设置单位战旗
```lua
-- 服务器推送 SSetBattleFlag
-- 客户端：当 opttype==3 清空所有战旗，否则设置指定单位的战旗（fire_pb_battle.lua:339-349）
```

- 构造方式:
  - `local m = require("protodef.fire.pb.xxx") ; local req = m.Create()`
  - 或 `local req = require("protodef.fire.pb.xxx"):new()`（少量模块）
- 发送接口:
  - `gGetNetConnection():send(req)`（底层连接）
  - 或 `LuaProtocolManager.getInstance():send(req)`（协议管理器封装）
- 会话与安全:
  - 连接后使用 `ARCFOUR` 加密：`gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)`
- 建议:
  - 请求前确保 `host/port` 来自当前选择区服（`gGetLoginManager():GetHost()/GetPort()`）
  - 进入世界后以增量刷新消息驱动 UI 与数据层更新

---

## 13. 已知问题与注意事项

- 链接冲突（LNK2005/LNK1169）
  - 现象：`__crt_debugger_hook` 多重定义
  - 处理：统一运行时库为 `/MD` 或 `/MDd`，并忽略旧版默认库；在 `AdditionalDependencies` 中加入 `legacy_stdio_definitions.lib`。
- 无法解析的外部符号（LNK2001）
  - 现象：`@__security_check_cookie@4` 缺失
  - 处理：在链接器 `AdditionalOptions` 中添加 `/DYNAMICBASE:NO /GS-`。
- 运行时缺少 DLL
  - 现象：缺少 `MSVCP120.dll` 或 `MSVCR120.dll`
  - 处理：安装 Visual C++ Redistributable for VS2013（x86）。
- 构建工具未找到（MSBuild）
  - 验证 `MSBuild 12.0` 路径是否在 `PATH` 中，并配置 `VS120COMNTOOLS` 指向 VS2013 `Common7\Tools`。

---

## 14. 版本更新记录与变更说明

```text
2025-11-27  v1.0
- 对齐 Windows 构建环境（VS2013 v120 / Windows SDK 8.1 / MSBuild 12.0）
- 修正网络协议为 TCP + protobuf 二进制协议
- 新增“API 接口与示例”章节
- 新增“已知问题与注意事项”与“版本更新记录与变更说明”章节
```

---

## 15. 环境变量与路径设置

### 15.1 Windows 构建环境变量

```powershell
# VS2013 工具集
setx VS120COMNTOOLS "D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\"

# 将以下路径加入 PATH（建议系统级）：
# - MSBuild 12.0
setx PATH "%PATH%;C:\Program Files (x86)\MSBuild\12.0\Bin\"
# - VS2013 IDE
setx PATH "%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\"
# - Windows Kits 8.1（x86）
setx PATH "%PATH%;C:\Program Files (x86)\Windows Kits\8.1\bin\x86\"

# 验证
msbuild -version
where msbuild
```

注意:
- 统一使用 `PlatformToolset v120` 与 `Windows SDK 8.1`，以避免 CRT/链接冲突。
- 运行时缺少 `MSVCP120.dll/MSVCR120.dll` 时安装 VC++ 2013 x86 运行库。

### 15.2 Android 构建环境变量/配置

```powershell
# 常用环境变量（如使用命令行/Gradle 构建）
setx JAVA_HOME "C:\Program Files\Java\jdk1.8.0_202"
setx ANDROID_HOME "C:\Android\Sdk"
setx NDK_HOME "C:\Android\android-ndk-r10e"
setx PATH "%PATH%;%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools;%NDK_HOME%"

# 项目级配置（推荐）: client/android/LocojoyProject/local.properties
sdk.dir=C:\Android\Sdk
ndk.dir=C:\Android\android-ndk-r10e

# 验证
adb version
ndk-build --version
```

### 15.3 Ant/Gradle/其他工具

```powershell
# Ant（如使用 Ant 构建）
setx ANT_HOME "C:\apache-ant-1.9.9"
setx PATH "%PATH%;%ANT_HOME%\bin"
ant -version

# Gradle（如使用独立 Gradle）
gradle -v
```

## 附录 A: 技术版本详细信息

### 核心技术栈版本

| 技术组件 | 版本 | 位置 | 说明 |
|---------|------|------|------|
| **Cocos2d-x** | 3.0-oh (Win32 canonical) / 2.2.6 (Android/iOS) | `/cocos2d-x-3.0-oh/`、`/cocos2d-x-2.2.6/` | 按平台分层的引擎核心 |
| **Lua 5.1 / LuaJIT 兼容链** | 5.1 / 2.0.3 | `/cocos2d-x-3.0-oh/external/lua/`、`/cocos2d-x-2.2.6/scripting/lua/` | Win32 canonical 使用 `lua.lib`；其他平台沿用 2.2.6 兼容链 |
| **tolua++** | 1.0.93 | `/common/tolua++-1.0.93/` | C++ ↔ Lua 绑定工具 |
| **CEGUI** | 0.7.9-r5 (Win32 canonical) / 0.7.1 (Legacy226) | `/tools/CEGUI-0.7.9-r5/`、`/dependencies/cegui/` | UI 框架 |

### 依赖库版本

| 依赖库 | 版本 | 位置 | 用途 |
|-------|------|------|------|
| **Box2D** | 2.3.x | `/cocos2d-x-2.2.6/external/Box2D/` | 物理引擎 |
| **Chipmunk** | 6.x | `/cocos2d-x-2.2.6/external/chipmunk/` | 2D 物理引擎 |
| **luasocket** | 2.0.2 | `/dependencies/luasocket-2.0.2/` | Lua 网络库 |
| **CocosDenshion** | 2.2.6 | `/cocos2d-x-2.2.6/CocosDenshion/` | 音频引擎 |

### 开发工具版本要求

| 平台 | 工具 | 最低版本 | 推荐版本 |
|-----|------|---------|---------|
| **Windows** | Visual Studio | 2013 | VS2013 + v120 + Windows SDK 8.1 |
| **Android** | NDK | r8 | r10e |
| **Android** | SDK | API 14 (Android 4.0) | API 23 (Android 6.0) |
| **iOS** | Xcode | 7.0 | 9.0 |
| **iOS** | iOS SDK | 7.0 | 10.0 |

### 第三方 SDK 集成

| SDK 名称 | 版本 | 用途 | 平台 |
|---------|------|------|------|
| **百度地图 SDK** | - | 地理位置服务 | Android |
| **度客 SDK** | - | 渠道 SDK | Android |
| **美洽客服 SDK** | - | 客服系统 | Android/iOS |
| **ShareSDK** | - | 社交分享 (微信/QQ/微博) | Android/iOS |
| **易接 SDK** | - | 渠道 SDK | Android |

### 构建产物规格

| 产物 | 平台 | 大小 | 说明 |
|-----|------|------|------|
| **mt3_locojoy.apk** | Android | 396 MB | Locojoy 渠道发布包 |
| **ApkIDE_.apk** | Android | 1.3 GB | 开发调试大包 (含所有资源) |
| **MT3.exe** | Windows | ~50 MB | Windows 主程序 |
| **Launcher.exe** | Windows | ~5 MB | Windows 启动器 |
| **MT3.ipa** | iOS | ~500 MB | iOS 发布包 (估算) |

### 目录空间占用

根据实际测量 (2025-11-27):

```
android/         4.8 GB   (多渠道项目 + 构建产物)
FireClient/      1.7 GB   (iOS/Win32 主项目)
resource/        1.2 GB   (Lua 脚本 + 游戏资源)
MT3Win32App/     1.1 GB   (旧版 Win32 项目)
res_ios/         768 MB   (iOS 平台资源)
res_android/     665 MB   (Android 平台资源)
res_win/         394 MB   (Windows 平台资源)
Launcher/        83 MB    (启动器项目)
doc/             5.4 MB   (开发文档)
3rdplatform/     6.6 MB   (第三方 SDK)
tolua++-pkgs/    1.3 MB   (tolua++ 绑定配置)
```

### 技术栈说明

**Cocos2d-x 3.0-oh（Windows canonical）**:
- 基于 cocos2d-iphone 移植的 C++ 跨平台游戏引擎
- 支持 iOS, Android, Windows, Linux 等多平台
- 使用 OpenGL ES 2.0 进行渲染
- 内置场景管理、动画系统、粒子系统
- Windows 主线目录为 `cocos2d-x-3.0-oh/`；Android/iOS 仍使用 `cocos2d-x-2.2.6/`

**LuaJIT 2.0.3**:
- Mike Pall 开发的高性能 Lua JIT 编译器
- 兼容 Lua 5.1 语法
- 比标准 Lua 5.1 解释器快 10-100 倍
- 支持 FFI (Foreign Function Interface)

**tolua++ 1.0.93**:
- C/C++ 到 Lua 的绑定生成器
- 基于 tolua 5.x 改进
- 支持 C++ 类、继承、重载
- 通过 .pkg 文件定义绑定接口

**CEGUI 0.7.9-r5（Windows canonical）**:
- Crazy Eddie's GUI System
- 跨平台 GUI 库
- 支持 XML 布局定义
- 高度可定制的皮肤系统
- 与 Cocos2d-x 集成需要自定义渲染器

---

**文档结束** | **Document End** | **最后更新**: 2025-11-27 (技术版本信息已验证)

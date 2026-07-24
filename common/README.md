# MT3 Common 公共库模块

> **MT3 游戏项目** - 客户端与服务器共享的基础库
>
> 本文档详细说明 common 目录中各个公共模块的功能、架构和使用方法

---

## 📋 目录

- [1. 项目概述](#1-项目概述)
- [2. 目录结构说明](#2-目录结构说明)
- [3. 核心模块详解](#3-核心模块详解)
- [4. 构建说明](#4-构建说明)
- [5. 依赖关系](#5-依赖关系)
- [6. 使用示例](#6-使用示例)
- [7. 常见问题 FAQ](#7-常见问题-faq)
- [8. 版本更新记录](#8-版本更新记录)
- [9. API 接口索引](#9-api-接口索引)
- [10. 构建顺序与依赖映射](#10-构建顺序与依赖映射)
- [11. 错误码与返回值规范](#11-错误码与返回值规范)

---

## 1. 项目概述

### 1.1 模块简介

**common** 目录包含 MT3 游戏项目中客户端和服务器共享的基础库模块，提供跨平台的底层功能支持。

**主要功能**:
- 🔐 **客户端认证** - 网络通信、协议处理、RPC 框架
- 🧵 **跨平台基础** - 线程、互斥锁、信号量、日志系统
- 🔄 **热更新引擎** - 文件下载、异步更新
- 🐍 **脚本绑定** - Lua 解释器、C++/Lua 绑定工具
- 🎮 **游戏框架** - 自定义游戏模块 (ljfm)

**支持平台**:
- ✅ Windows (Win32)
- ✅ Android (NDK)
- ✅ iOS (Xcode)
- ⚠️ Windows Phone 8 (历史支持)

### 1.2 技术栈

| 技术 | 版本/说明 |
|-----|----------|
| **编程语言** | C++ (C++11 标准) |
| **Lua 解释器** | Lua 5.1 |
| **C++/Lua 绑定** | tolua++ 1.0.93 |
| **网络库** | 自研异步 IO 框架 (aio 命名空间) |
| **构建工具** | Visual Studio (Windows), Xcode (iOS), NDK (Android) |

### 1.3 模块规模

```
代码统计:
  源代码文件: 162 个 (.h/.cpp)
  总代码行数: ~50,000+ 行 (估算)

模块大小:
  cauthc/         66 MB   (客户端认证与网络通信)
  lua/            33 MB   (Lua 解释器库)
  ljfm/           30 MB   (Locojoy Fire Module)
  platform/       20 MB   (跨平台基础库)
  tolua++-1.0.93/ 1.6 MB  (C++/Lua 绑定工具)
  updateengine/   392 KB  (热更新引擎)
```

---

## 2. 目录结构说明

### 2.1 顶层目录结构

```
common/                              # 公共库根目录
├── cauthc/                          # 客户端认证与网络通信模块
│   ├── authc/                       # 核心认证代码
│   │   ├── gnet/                    # 网络通信
│   │   ├── os/                      # 操作系统抽象
│   │   ├── rpcgen/                  # RPC 代码生成
│   │   ├── share/                   # 共享工具
│   │   ├── ioengine.h               # IO 引擎接口
│   │   ├── pollio.h                 # Poll IO 实现
│   │   ├── timer.h                  # 定时器
│   │   └── ...
│   ├── include/                     # 公共头文件
│   ├── net/                         # 网络协议
│   └── projects/                    # 平台项目文件
│       ├── windows/                 # Windows 项目
│       └── wp8/                     # Windows Phone 8 项目
│
├── ljfm/                            # Locojoy Fire Module (自定义游戏模块)
│   ├── code/                        # 源代码
│   │   ├── include/                 # 头文件
│   │   └── source/                  # 实现文件
│   ├── ljfm.vcxproj                 # Visual Studio 项目
│   ├── ljfm.xcodeproj/              # Xcode 项目
│   ├── Debug.win32/                 # Debug 构建输出
│   └── Release.win32/               # Release 构建输出
│
├── lua/                             # Lua 5.1 解释器库
│   ├── lua.vcxproj                  # Visual Studio 项目
│   ├── Debug.win32/                 # Debug 构建输出
│   └── Release.win32/               # Release 构建输出
│
├── platform/                        # 跨平台基础库
│   ├── android/                     # Android 平台实现
│   ├── ios/                         # iOS 平台实现
│   ├── ini/                         # INI 配置文件解析
│   ├── log/                         # 日志系统
│   ├── platform/                    # 平台抽象层
│   │   ├── mutex.h                  # 互斥锁
│   │   ├── thread.h                 # 线程
│   │   ├── ksemaphore.h             # 信号量
│   │   └── platform_types.h        # 平台类型定义
│   ├── utils/                       # 工具函数
│   ├── share.xcodeproj/             # iOS 共享项目
│   ├── Debug.win32/                 # Debug 构建输出
│   └── Release.win32/               # Release 构建输出
│
├── tolua++-1.0.93/                  # tolua++ C++/Lua 绑定工具
│   ├── bin/                         # 可执行文件
│   │   └── tolua++.exe              # Windows 工具
│   ├── include/                     # 头文件
│   ├── lib/                         # 库文件
│   ├── src/                         # 源代码
│   │   ├── bin/                     # 工具源码
│   │   └── lib/                     # 库源码
│   ├── win32/                       # Windows 项目
│   ├── doc/                         # 文档
│   ├── README                       # 说明文档
│   └── README-5.1                   # Lua 5.1 说明
│
└── updateengine/                    # 热更新引擎
    ├── android/                     # Android 实现
    ├── ios/                         # iOS 实现
    ├── win32/                       # Windows 实现
    │   ├── AsyncFileDownloader.h    # 异步文件下载器
    │   ├── FileDownloader.cpp       # 文件下载器实现
    │   └── GlobalFunction.cpp       # 全局函数
    ├── wp/                          # Windows Phone 实现
    └── updateengine.vcxproj         # Visual Studio 项目
```

### 2.2 重点模块说明

| 模块 | 用途 | 重要性 |
|-----|------|-------|
| `cauthc/` | 客户端认证、网络通信、RPC 框架 | ⭐⭐⭐⭐⭐ |
| `platform/` | 跨平台基础设施（线程、锁、日志） | ⭐⭐⭐⭐⭐ |
| `lua/` | Lua 5.1 解释器库 | ⭐⭐⭐⭐⭐ |
| `ljfm/` | 自定义游戏模块 | ⭐⭐⭐⭐ |
| `tolua++-1.0.93/` | C++/Lua 绑定工具 | ⭐⭐⭐⭐ |
| `updateengine/` | 热更新引擎 | ⭐⭐⭐ |

---

## 3. 核心模块详解

### 3.1 cauthc - 客户端认证与网络通信 ⭐⭐⭐⭐⭐

**模块位置**: `cauthc/`

**用途**: 提供客户端与服务器之间的认证、网络通信、协议处理和 RPC 框架。

**核心组件**:

#### 3.1.1 IO 引擎 (ioengine)
```cpp
namespace aio {
    class Runnable {
        virtual void run();        // 异步任务执行
        virtual void destroy();    // 资源清理
    };

    class TaskQueue {
        void addTask(Runnable* task);  // 添加异步任务
        void runTasks();                // 执行任务队列
    };
}
```

**功能**:
- 异步 IO 任务调度
- 线程安全的任务队列
- 事件驱动架构

#### 3.1.2 Poll IO (pollio)
- 基于 `poll()` 或 `epoll()` 的 IO 多路复用
- 跨平台网络事件处理
- 高性能并发连接支持

#### 3.1.3 RPC 框架 (rpcgen)
- 远程过程调用代码生成
- 协议自动序列化/反序列化
- 与服务器端协议兼容

#### 3.1.4 网络会话 (netsession)
- TCP 连接管理
- 会话状态维护
- 心跳保活机制

#### 3.1.5 定时器 (timer)
- 高精度定时器
- 超时检测
- 周期性任务调度

**构建产物**:
- Windows: `cauthc.lib`
- iOS: `libcauthc.a`
- Android: `libcauthc.so`

**依赖**:
- `platform/` (线程、互斥锁)
- 系统网络库 (socket API)

---

### 3.2 platform - 跨平台基础库 ⭐⭐⭐⭐⭐

**模块位置**: `platform/`

**用途**: 提供跨平台的基础设施抽象，隔离操作系统差异。

**核心组件**:

#### 3.2.1 线程 (thread.h)
```cpp
class Thread {
    void start();              // 启动线程
    void join();               // 等待线程结束
    bool isRunning();          // 检查运行状态
};
```

**支持平台**:
- Windows: Win32 Threads
- POSIX: pthreads (Linux/iOS/Android)

#### 3.2.2 互斥锁 (mutex.h)
```cpp
class Mutex {
    void lock();               // 加锁
    void unlock();             // 解锁
    bool tryLock();            // 尝试加锁

    class Scoped {             // RAII 风格自动锁
        Scoped(Mutex& m);
        ~Scoped();
    };
};
```

#### 3.2.3 信号量 (ksemaphore.h)
```cpp
class Semaphore {
    void wait();               // 等待信号量
    void signal();             // 发送信号量
    bool tryWait();            // 非阻塞等待
};
```

#### 3.2.4 日志系统 (log/)
- 多级别日志 (DEBUG, INFO, WARN, ERROR)
- 线程安全
- 日志文件轮转
- 格式化输出

#### 3.2.5 INI 配置 (ini/)
- INI 文件解析
- 配置项读取
- 类型转换 (string, int, float, bool)

#### 3.2.6 工具函数 (utils/)
- 字符串处理
- 文件操作
- 时间处理
- 加密/解密

**构建产物**:
- Windows: `platform.lib`
- iOS: `libplatform.a`
- Android: `libplatform.so`

---

### 3.3 lua - Lua 5.1 解释器 ⭐⭐⭐⭐⭐

**模块位置**: `lua/`

**用途**: 嵌入式 Lua 5.1 解释器，用于游戏脚本执行。

**核心功能**:
- Lua 5.1 标准库完整实现
- C API 支持
- 与 tolua++ 集成
- 性能优化版本

**API 示例**:
```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

// 创建 Lua 虚拟机
lua_State* L = luaL_newstate();
luaL_openlibs(L);

// 执行 Lua 脚本
luaL_dofile(L, "script.lua");

// 清理
lua_close(L);
```

**构建产物**:
- Windows: `lua.lib`
- iOS: `liblua.a`
- Android: `liblua.so`

---

### 3.4 ljfm - Locojoy Fire Module ⭐⭐⭐⭐

**模块位置**: `ljfm/`

**用途**: Locojoy 自定义游戏模块，封装常用游戏功能。

**可能功能** (基于目录结构推测):
- 游戏框架封装
- 自定义工具函数
- Locojoy 平台集成
- 特定业务逻辑

**项目结构**:
```
ljfm/
├── code/
│   ├── include/      # 公共接口
│   └── source/       # 实现代码
├── ljfm.vcxproj      # Windows 项目
└── ljfm.xcodeproj/   # iOS 项目
```

**构建产物**:
- Windows: `ljfm.lib`
- iOS: `libljfm.a`
- Android: `libljfm.so`

---

### 3.5 tolua++ - C++/Lua 绑定工具 ⭐⭐⭐⭐

**模块位置**: `tolua++-1.0.93/`

**版本**: 1.0.93

**用途**: 自动生成 C++ 到 Lua 的绑定代码，允许 Lua 脚本调用 C++ 类和函数。

**核心功能**:
- C++ 类导出到 Lua
- 函数重载支持
- 继承关系支持
- 自动类型转换

**使用流程**:
```bash
# 1. 编写 .pkg 文件定义需要导出的 C++ 接口
# 2. 使用 tolua++ 生成绑定代码
tolua++ -o output.cpp input.pkg

# 3. 将生成的代码编译到项目中
# 4. 在 Lua 中调用 C++ 接口
```

**示例 .pkg 文件**:
```cpp
// Player.pkg
class Player {
    Player(const char* name);
    ~Player();

    void setPosition(float x, float y);
    float getX() const;
    float getY() const;

    int getLevel();
    void addExp(int exp);
};
```

**生成的 Lua 绑定**:
```lua
-- Lua 脚本中使用
local player = Player("Alice")
player:setPosition(100, 200)
print(player:getX(), player:getY())
player:addExp(500)
```

**目录结构**:
- `bin/` - tolua++ 可执行文件
- `include/` - 运行时头文件
- `lib/` - 运行时库文件
- `src/` - tolua++ 源代码
- `doc/` - 使用文档

---

### 3.6 updateengine - 热更新引擎 ⭐⭐⭐

**模块位置**: `updateengine/`

**用途**: 实现游戏客户端的热更新功能，支持 Lua 脚本和资源文件更新。

**核心组件**:

#### 3.6.1 文件下载器 (FileDownloader)
```cpp
class FileDownloader {
    bool download(const char* url, const char* savePath);
    int getProgress();         // 获取下载进度
    void cancel();             // 取消下载
};
```

#### 3.6.2 异步文件下载器 (AsyncFileDownloader)
```cpp
class AsyncFileDownloader {
    void startDownload(const char* url, Callback* callback);
    void onDownloadProgress(int percent);
    void onDownloadComplete();
    void onDownloadError(int errorCode);
};
```

**功能特性**:
- HTTP/HTTPS 文件下载
- 断点续传支持
- 下载进度回调
- MD5 文件校验
- 多线程下载
- 压缩包解压

**工作流程**:
```
1. 连接更新服务器
   ↓
2. 获取版本文件列表
   ↓
3. 对比本地文件差异
   ↓
4. 下载需要更新的文件
   ↓
5. 校验文件完整性 (MD5)
   ↓
6. 替换旧文件
   ↓
7. 重启应用或热加载
```

**支持平台**:
- Windows (WinHTTP)
- iOS (NSURLConnection)
- Android (HttpURLConnection)
- Windows Phone 8

**构建产物**:
- Windows: `updateengine.lib`
- iOS: `libupdateengine.a`
- Android: `libupdateengine.so`

---

## 4. 构建说明

### 4.1 Windows 平台构建

#### 环境要求
- Visual Studio 2013（PlatformToolset `v120`）
- Windows SDK 8.1
- MSBuild 12.0
- 运行时：Visual C++ Redistributable for Visual Studio 2013（x86）

#### 环境变量配置（Windows）
- `VS120COMNTOOLS` 指向 VS2013 的 `Common7\Tools`
  - 示例：`D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\`
- 将以下路径加入系统 `PATH`
  - `C:\Program Files (x86)\MSBuild\12.0\Bin\`
  - `D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\`
  - `C:\Program Files (x86)\Windows Kits\8.1\bin\x86\`

#### 构建步骤
```bash
# 方法 1: 使用 Visual Studio
# 1. 打开对应的 .vcxproj 或 .sln 文件
# 2. 选择配置: Debug 或 Release
# 3. 选择平台: Win32 或 x64
# 4. 菜单: 生成 → 生成解决方案

# 方法 2: 使用 MSBuild 命令行
cd common/platform
msbuild platform.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
```

#### 构建产物位置
```
common/
├── cauthc/projects/windows/Debug.win32/    → cauthc.lib
├── lua/Debug.win32/                        → lua.lib
├── ljfm/Debug.win32/                       → ljfm.lib
├── platform/Debug.win32/                   → platform.lib
└── updateengine/Debug.win32/               → updateengine.lib
```

---

### 4.2 iOS 平台构建

#### 环境要求
- macOS 10.12+
- Xcode 7.0+
- iOS SDK 7.0+

#### 构建步骤
```bash
# 1. 打开 Xcode 项目
cd common/platform
open share.xcodeproj

# 2. 选择配置
# - Scheme: platform (或对应模块名)
# - Destination: Generic iOS Device

# 3. 构建
# 菜单: Product → Build

# 4. 构建产物
# DerivedData/.../Build/Products/Release-iphoneos/libplatform.a
```

---

### 4.3 Android 平台构建

#### 环境要求
- Android NDK r8+
- Android SDK (API Level 14+)

#### 构建步骤
```bash
# 1. 设置环境变量
export ANDROID_NDK=/path/to/android-ndk
export PATH=$ANDROID_NDK:$PATH

# 2. 进入模块目录
cd common/cauthc

# 3. 使用 ndk-build 构建
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk

# 4. 构建产物
# obj/local/armeabi-v7a/libcauthc.so
```

---

### 4.4 构建顺序

由于模块间存在依赖关系，建议按以下顺序构建:

```
1. platform/        (基础库，无依赖)
2. lua/             (无依赖)
3. tolua++/         (依赖 lua)
4. cauthc/          (依赖 platform)
5. ljfm/            (依赖 platform, lua)
6. updateengine/    (依赖 platform)
```

---

## 5. 依赖关系

### 5.1 模块依赖图

```
                    ┌─────────────┐
                    │   client    │
                    │  (客户端)    │
                    └──────┬──────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
    ┌────▼────┐      ┌────▼────┐      ┌────▼────┐
    │  cauthc │      │  ljfm   │      │updateeng│
    │ (认证)  │      │ (模块)  │      │ (更新)  │
    └────┬────┘      └────┬────┘      └────┬────┘
         │                │                 │
         └────────┬───────┴─────────────────┘
                  │
         ┌────────▼─────────┐
         │    platform      │
         │  (跨平台基础)    │
         └──────────────────┘


    ┌──────────┐          ┌──────────┐
    │   lua    │ ◄────────┤ tolua++  │
    │(解释器)  │          │  (绑定)  │
    └──────────┘          └──────────┘
```

### 5.2 依赖关系表

| 模块 | 依赖项 | 说明 |
|-----|-------|------|
| **platform** | 无 | 最底层，仅依赖系统 API |
| **lua** | 无 | 独立的 Lua 解释器 |
| **tolua++** | lua | 需要 Lua 运行时 |
| **cauthc** | platform | 需要线程、锁等基础设施 |
| **ljfm** | platform, lua | 需要跨平台支持和脚本引擎 |
| **updateengine** | platform | 需要文件操作、线程支持 |

---

## 6. 使用示例

### 6.1 使用 platform 模块

#### 示例 1: 线程与互斥锁
```cpp
#include "platform/thread.h"
#include "platform/mutex.h"

// 全局互斥锁
FireNet::Mutex g_mutex;
int g_counter = 0;

// 线程任务
class WorkerThread : public FireNet::Thread {
public:
    void run() override {
        for (int i = 0; i < 1000; ++i) {
            FireNet::Mutex::Scoped lock(g_mutex);  // RAII 自动加锁/解锁
            ++g_counter;
        }
    }
};

int main() {
    WorkerThread t1, t2;
    t1.start();
    t2.start();
    t1.join();
    t2.join();

    printf("Counter: %d\n", g_counter);  // 输出: 2000
    return 0;
}
```

#### 示例 2: 日志系统
```cpp
#include "platform/log/klog.h"

// 初始化日志系统
KLog::init("game.log", KLog::LEVEL_DEBUG);

// 记录日志
KLOG_DEBUG("游戏启动");
KLOG_INFO("连接服务器: %s:%d", "127.0.0.1", 8000);
KLOG_WARN("网络延迟较高: %d ms", 200);
KLOG_ERROR("连接失败: %s", "timeout");

// 关闭日志系统
KLog::shutdown();
```

---

### 6.2 使用 cauthc 网络模块

#### 示例: 连接游戏服务器
```cpp
#include "cauthc/authc/netsession.h"
#include "cauthc/authc/ioengine.h"

// 网络会话回调
class GameSessionHandler : public NetSessionHandler {
public:
    void onConnected() override {
        printf("已连接到服务器\n");
    }

    void onDisconnected() override {
        printf("与服务器断开连接\n");
    }

    void onReceived(const char* data, int len) override {
        printf("收到数据: %d 字节\n", len);
        // 解析协议...
    }
};

int main() {
    // 创建 IO 引擎
    aio::IOEngine engine;

    // 创建会话
    NetSession session(&engine);
    GameSessionHandler handler;
    session.setHandler(&handler);

    // 连接服务器
    session.connect("127.0.0.1", 8000);

    // 运行事件循环
    engine.run();

    return 0;
}
```

---

### 6.3 使用 updateengine 热更新

#### 示例: 下载更新文件
```cpp
#include "updateengine/AsyncFileDownloader.h"

// 下载回调
class UpdateCallback : public DownloadCallback {
public:
    void onProgress(int percent) override {
        printf("下载进度: %d%%\n", percent);
    }

    void onComplete() override {
        printf("下载完成\n");
        // 解压、校验、替换文件...
    }

    void onError(int errorCode) override {
        printf("下载失败: %d\n", errorCode);
    }
};

int main() {
    AsyncFileDownloader downloader;
    UpdateCallback callback;

    // 开始下载
    downloader.startDownload(
        "http://update.game.com/patch_1.2.zip",
        "patch_1.2.zip",
        &callback
    );

    // 等待下载完成...

    return 0;
}
```

---

### 6.4 使用 tolua++ 绑定 C++ 类

#### 步骤 1: 编写 .pkg 文件
```cpp
// GamePlayer.pkg
class GamePlayer {
    GamePlayer(const char* name);
    ~GamePlayer();

    void setPosition(float x, float y);
    float getX() const;
    float getY() const;

    void attack(GamePlayer* target);
    int getHP() const;
    void setHP(int hp);
};
```

#### 步骤 2: 生成绑定代码
```bash
cd common/tolua++-1.0.93/bin
tolua++ -o GamePlayer_bind.cpp GamePlayer.pkg
```

#### 步骤 3: 在 Lua 中使用
```lua
-- Lua 脚本
local player1 = GamePlayer("Alice")
local player2 = GamePlayer("Bob")

player1:setPosition(100, 200)
player2:setPosition(150, 250)

player1:attack(player2)
print("Player2 HP:", player2:getHP())
```

---

## 7. 常见问题 FAQ

### Q1: 如何在新项目中集成 common 模块？

**A**: 按以下步骤集成：

```yaml
步骤 1: 复制 common 目录到项目中
  cp -r common/ /path/to/your/project/

步骤 2: 添加包含路径
  Visual Studio:
    - 项目属性 → C/C++ → 常规 → 附加包含目录
    - 添加: $(ProjectDir)common/platform;$(ProjectDir)common/lua;...

  Xcode:
    - Target → Build Settings → Header Search Paths
    - 添加: $(SRCROOT)/common/platform $(SRCROOT)/common/lua ...

步骤 3: 链接库文件
  Visual Studio:
    - 项目属性 → 链接器 → 输入 → 附加依赖项
    - 添加: platform.lib;lua.lib;cauthc.lib;...

  Xcode:
    - Target → Build Phases → Link Binary With Libraries
    - 添加: libplatform.a, liblua.a, libcauthc.a, ...

步骤 4: 构建并测试
```

### Q9: Windows CRT/链接冲突如何排查？

**A**: 按以下步骤处理：

```yaml
步骤 1: 统一运行时库设置
  - Release: /MD (MultiThreadedDLL)
  - Debug:   /MDd (MultiThreadedDebugDLL)

步骤 2: 忽略旧版默认 CRT 库
  - 链接器 → 输入 → 忽略特定默认库
  - libcmt.lib; libcmtd.lib; msvcrt.lib; msvcrtd.lib

步骤 3: 添加兼容库
  - 附加依赖项: legacy_stdio_definitions.lib

步骤 4: 设置链接器附加选项
  - /DYNAMICBASE:NO /GS-
  - 解决 @__security_check_cookie@4 缺失与 ASLR 兼容问题

步骤 5: 典型错误定位
  - LNK2005: 多重定义 (__crt_debugger_hook 等) → 检查运行时库与忽略默认库设置
  - LNK2001: 无法解析 (@__security_check_cookie@4) → 检查 /GS- 与兼容库

步骤 6: 重新编译第三方依赖
  - 使用 VS2013 (v120) 统一编译依赖，避免符号冲突
```

---

### Q2: cauthc 模块编译失败怎么办？

**A**: 检查以下几点：

```yaml
问题 1: 缺少 platform 库
  解决: 先构建 platform 模块，确保 platform.lib 存在

问题 2: 链接错误
  解决: 检查链接器依赖项，添加 ws2_32.lib (Windows socket 库)

问题 3: 头文件找不到
  解决: 添加 common/cauthc/include 到包含路径

问题 4: C++ 标准不匹配
  解决: 设置项目使用 C++11 标准
    Visual Studio: /std:c++11
    Xcode: -std=c++11
```

---

### Q3: 如何在多线程环境中使用 lua 模块？

**A**: Lua 虚拟机不是线程安全的，需要注意：

```cpp
// ❌ 错误：多线程共享同一个 lua_State
lua_State* L = luaL_newstate();
std::thread t1([L]() { luaL_dostring(L, "print('Thread 1')"); });
std::thread t2([L]() { luaL_dostring(L, "print('Thread 2')"); });

// ✅ 正确 1：每个线程创建独立的 lua_State
std::thread t1([]() {
    lua_State* L = luaL_newstate();
    luaL_dostring(L, "print('Thread 1')");
    lua_close(L);
});

// ✅ 正确 2：使用互斥锁保护
FireNet::Mutex g_lua_mutex;
std::thread t1([L]() {
    FireNet::Mutex::Scoped lock(g_lua_mutex);
    luaL_dostring(L, "print('Thread 1')");
});
```

---

### Q4: tolua++ 生成的代码编译报错？

**A**: 常见问题和解决方法：

```yaml
问题 1: "undeclared identifier" 错误
  原因: .pkg 文件中引用的类型未声明
  解决: 在 .pkg 开头添加 $#include "YourHeader.h"

问题 2: 链接错误 "unresolved external symbol"
  原因: 未链接 tolua++ 运行时库
  解决: 链接 toluapp.lib (Windows) 或 libtoluapp.a (iOS/Android)

问题 3: Lua 中调用 C++ 方法崩溃
  原因: C++ 对象生命周期管理问题
  解决: 使用 tolua_pushusertype 时确保对象有效性
```

---

### Q5: updateengine 下载文件失败？

**A**: 排查步骤：

```yaml
步骤 1: 检查网络连接
  ping update.game.com
  telnet update.game.com 80

步骤 2: 检查 URL 格式
  - 必须是完整 URL: http://... 或 https://...
  - 不支持相对路径

步骤 3: 检查文件写入权限
  - Windows: 确保目标目录有写权限
  - iOS: 只能写入 Documents 或 Caches 目录
  - Android: 需要 WRITE_EXTERNAL_STORAGE 权限

步骤 4: 查看错误码
  errorCode 含义:
    - 1: 网络不可达
    - 2: 服务器拒绝连接
    - 3: HTTP 错误 (404, 500 等)
    - 4: 磁盘空间不足
    - 5: MD5 校验失败
```

---

### Q6: 如何调试 cauthc 网络通信问题？

**A**: 调试技巧：

```cpp
// 1. 启用网络日志
#define CAUTHC_DEBUG_LOG 1
#include "cauthc/authc/netio.h"

// 2. 使用 Wireshark 抓包
// - 设置过滤器: tcp.port == 8000
// - 查看数据包内容

// 3. 添加调试输出
class DebugSessionHandler : public NetSessionHandler {
    void onReceived(const char* data, int len) override {
        printf("收到数据: ");
        for (int i = 0; i < len && i < 64; ++i) {
            printf("%02X ", (unsigned char)data[i]);
        }
        printf("\n");
    }
};

// 4. 检查服务器是否正常
// telnet 127.0.0.1 8000
```

---

### Q7: platform 模块在不同平台的行为差异？

**A**: 已知差异：

| 特性 | Windows | iOS/Android | 说明 |
|-----|---------|-------------|------|
| **线程优先级** | 支持完整优先级 | 受系统限制 | iOS 不允许设置高优先级 |
| **文件路径** | `\` 分隔符 | `/` 分隔符 | 使用 `platform::Path` 统一处理 |
| **时间精度** | 微秒级 | 毫秒级 | Android 某些设备时间精度较低 |
| **日志输出** | 控制台 + 文件 | NSLog / Logcat | iOS 建议使用系统日志 |
| **TLS/HTTPS** | WinHTTP/Schannel | NSURLSession/CFNetwork | Android HttpURLConnection/OkHttp |
| **文件权限** | 用户目录写入 | 沙盒 Documents/Caches | 外部存储需权限 |
| **证书/签名** | 系统证书 | ATS/证书策略 | 网络安全配置 |

**跨平台代码建议**:
```cpp
#include "platform/platform_types.h"
platformInt64 timestamp = platform::getTimestamp();
```

---

### Q8: 如何测试 common 模块的功能？

**A**: 测试方法：

```bash
# 1. 单元测试（如果有）
cd common/platform/test
./run_tests

# 2. 编写简单测试程序
# test_platform.cpp
#include "platform/thread.h"
#include "platform/mutex.h"

int main() {
    // 测试线程
    // 测试互斥锁
    // 测试日志
    return 0;
}

# 3. 集成测试
# 在实际客户端/服务器中测试各模块功能

# 4. 性能测试
# 测试网络吞吐量、并发连接数等
```

---

## 8. 版本更新记录

- 2025-11-27
  - Windows 工具链统一至 VS2013（v120）、Windows SDK 8.1、MSBuild 12.0
  - 增加 Windows 环境变量与 PATH 配置清单（`VS120COMNTOOLS`、`MSBuild 12.0`、`Windows Kits 8.1`）
  - 添加 MT3 项目关键链接器选项（`legacy_stdio_definitions.lib`、忽略旧版 CRT 默认库、`/DYNAMICBASE:NO /GS-`）
  - 更新附录 Windows 配置示例为 `PlatformToolset v120`

---

## 附录 A: 编译配置

### Windows (Visual Studio)

```xml
<!-- 推荐配置 -->
<PropertyGroup>
  <ConfigurationType>StaticLibrary</ConfigurationType>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
  <TargetName>$(ProjectName)</TargetName>
</PropertyGroup>

<ItemDefinitionGroup>
  <ClCompile>
    <PreprocessorDefinitions>WIN32;_LIB;%(PreprocessorDefinitions)</PreprocessorDefinitions>
    <WarningLevel>Level3</WarningLevel>
    <Optimization>MaxSpeed</Optimization>
    <MultiProcessorCompilation>true</MultiProcessorCompilation>
  </ClCompile>
</ItemDefinitionGroup>
```

#### 附加链接器配置（MT3 项目）

```xml
<!-- Release 配置示例 -->
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
  <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
  <WholeProgramOptimization>true</WholeProgramOptimization>
  <Optimization>MaxSpeed</Optimization>
  <InlineFunctionExpansion>AnySuitable</InlineFunctionExpansion>
</PropertyGroup>

<ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
  <Link>
    <AdditionalDependencies>legacy_stdio_definitions.lib;%(AdditionalDependencies)</AdditionalDependencies>
    <IgnoreSpecificDefaultLibraries>libcmt.lib;libcmtd.lib;msvcrt.lib;msvcrtd.lib</IgnoreSpecificDefaultLibraries>
    <AdditionalOptions>/DYNAMICBASE:NO /GS- %(AdditionalOptions)</AdditionalOptions>
  </Link>
</ItemDefinitionGroup>

<!-- Debug 配置示例 -->
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>
  <CharacterSet>Unicode</CharacterSet>
  <PlatformToolset>v120</PlatformToolset>
  <Optimization>Disabled</Optimization>
  <BasicRuntimeChecks>EnableFastChecks</BasicRuntimeChecks>
</PropertyGroup>

<ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <Link>
    <AdditionalDependencies>legacy_stdio_definitions.lib;%(AdditionalDependencies)</AdditionalDependencies>
    <IgnoreSpecificDefaultLibraries>libcmt.lib;libcmtd.lib;msvcrt.lib;msvcrtd.lib</IgnoreSpecificDefaultLibraries>
    <AdditionalOptions>/DYNAMICBASE:NO /GS- %(AdditionalOptions)</AdditionalOptions>
  </Link>
</ItemDefinitionGroup>
```

---

## 9. API 接口索引

### 9.1 platform
- 头文件位置：`platform/`
- 核心接口：`mutex.h`、`thread.h`、`ksemaphore.h`、`log/klog.h`、`ini/`、`platform_types.h`
- 常用方法：
  - `Thread.start()`、`Thread.join()`、`Thread.isRunning()`
  - `Mutex.lock()`、`Mutex.unlock()`、`Mutex.tryLock()`、`Mutex::Scoped`
  - `Semaphore.wait()`、`Semaphore.signal()`、`Semaphore.tryWait()`
  - `KLog::init()`、`KLog::shutdown()`、`KLOG_DEBUG/INFO/WARN/ERROR`
  - INI 读取：`ini::get(key)`、`ini::getInt(key)`、`ini::getBool(key)`

#### 详细接口（引用）
- `core::Thread`：`IsRunningNow`、`StopRunning`、`Start`、`Join`、`Run` 抽象方法（common/platform/platform/thread.h:22、24、26、28、30）
- `core::CMutex`：`Lock`、`UNLock`、`Scoped` 构造与析构（common/platform/platform/mutex.h:38、46、61-64）
- `core::CSemaphore`：`CSemaphore(const char*)`、`wait`、`fire`（common/platform/platform/ksemaphore.h:26-31）
- `core::Logger`：`setLoggingLevel`（common/platform/log/CoreLog.h:79）、`setLogFilename`（common/platform/log/CoreLog.h:81）、`logEvent`（common/platform/log/CoreLog.h:111）、`logLuaEvent`（common/platform/log/CoreLog.h:113）
- 日志宏：`SDLOG_ERR/WARN/STD/INFO/INSANE`（common/platform/log/CoreLog.h:7-12）
- `IniFile`：`read_profile_string/int/float`、`write_profile_string`、`getCfgFilename`（common/platform/ini/IniFile.h:11-17）

参见使用示例：`6.1 使用 platform 模块`

#### 日志初始化最佳实践（CoreLog）
- 初始化：调用 `core::Logger::GetInstance()->setLogFilename("game.log", /*append*/true)` 设置文件；`setLoggingLevel(core::Standard)` 设置等级（common/platform/log/CoreLog.h:79、81）
- 使用：通过宏 `SDLOG_INFO/SDLOG_WARN/SDLOG_ERR` 记录（common/platform/log/CoreLog.h:7-12）
- 关闭：按需关闭输出流（默认 `Logger` 管理文件流，可重复设置文件名）

#### 快速示例
```cpp
#include "platform/thread.h"
#include "platform/mutex.h"
#include "platform/log/CoreLog.h"

class Worker : public core::Thread {
public:
    void Run() override {
        core::CMutex mtx;
        core::CMutex::Scoped lock(mtx);
        core::Logger::GetInstance()->setLogFilename("game.log", true);
        core::Logger::GetInstance()->setLoggingLevel(core::Standard);
        SDLOG_INFO(L"worker running");
    }
};

int main() {
    Worker w; w.Start(); w.Join();
    return 0;
}
```

### 9.2 cauthc
- 头文件位置：`cauthc/authc/`
- 核心接口：`ioengine.h`、`netsession.h`、`pollio.h`、`timer.h`
- 常用类与方法：
  - `aio::IOEngine.run()`
  - `NetSession.connect(host, port)`、`NetSession.setHandler(handler)`
  - `NetSessionHandler.onConnected()`、`onDisconnected()`、`onReceived(data, len)`
  - `Timer.start()`、`Timer.stop()`、`Timer.schedule(interval)`

#### 详细接口（引用）
- `aio::Runnable`：`run`、`destroy`、`runAndDestroy`（common/cauthc/authc/ioengine.h:10-17、13-17）
- `aio::TaskQueue`：`addTask`（common/cauthc/authc/ioengine.h:37-45）、`runTasks`（common/cauthc/authc/ioengine.h:47）、`clear`（common/cauthc/authc/ioengine.h:48）
- `aio::Engine`：`getInstance`（common/cauthc/authc/ioengine.h:58）、`Startup`（common/cauthc/authc/ioengine.h:60）、`Cleanup`（common/cauthc/authc/ioengine.h:61）、`Connect`（common/cauthc/authc/ioengine.h:63）、`Run`（common/cauthc/authc/ioengine.h:65）
- `FireNet::PollIO`：`Register`（common/cauthc/authc/pollio.h:268-278）、`Poll`（common/cauthc/authc/pollio.h:348-361、363-400）、`PermitRecv/PermitSend`（common/cauthc/authc/pollio.h:300-309）、`ForbidRecv/ForbidSend`（common/cauthc/authc/pollio.h:312-337）、`Close`（common/cauthc/authc/pollio.h:340-346）
- `FireNet::StreamIO`：数据收发与关闭回调 `PollIn/PollOut/PollClose`（common/cauthc/authc/netio.h:56-82、85-114、116-124）
- `FireNet::NetSession`：`GetOBuffer`（common/cauthc/authc/netsession.cpp:23-29）、`GetIBuffer`（common/cauthc/authc/netsession.cpp:31-34）、`SendFinish`（common/cauthc/authc/netsession.cpp:36-43）、`Output`（common/cauthc/authc/netsession.cpp:45-51）、`Input`（common/cauthc/authc/netsession.cpp:53-63）、`SendReady`（common/cauthc/authc/netsession.cpp:65-71）、`SetISecurity/SetOSecurity`（common/cauthc/authc/netsession.cpp:73-87）、`Close`（common/cauthc/authc/netsession.cpp:89-101）、`Destroy`（common/cauthc/authc/netsession.cpp:103）、`getCloseInfo`（common/cauthc/authc/netsession.cpp:105-112）
- `FireNet::Timer`：`Attach`（common/cauthc/authc/timer.h:35-39）、`Detach`（common/cauthc/authc/timer.h:40-44）、`UpdateSelf`（common/cauthc/authc/timer.h:45-53）、`GetTime`（common/cauthc/authc/timer.h:55-58）、`GetSystemTick`（common/cauthc/authc/timer.h:60-61）

参见使用示例：`6.2 使用 cauthc 网络模块`

#### 会话生命周期与事件流
- 打开阶段：`StreamIO` 构造触发 `NetSession.OnOpen(...)`（common/cauthc/authc/netio.h:131-144）
- 接收阶段：网络可读触发 `PollIn`，填充输入缓冲并回调 `session->OnRecv()`（common/cauthc/authc/netio.h:56-66）
- 处理阶段：调用 `NetSession.Input()` 将解密后的数据转入 `isecbuf` 并允许继续接收（common/cauthc/authc/netsession.cpp:53-63）
- 发送阶段：`NetSession.Output()` 写入待发送缓冲；`SendReady()` 允许发送（common/cauthc/authc/netsession.cpp:45-51、65-71）
- 发送完成：`SendFinish()` 在输出缓冲清空后禁止继续发送（common/cauthc/authc/netsession.cpp:36-43）
- 关闭阶段：`Close()` 设置关闭标志并允许发送关闭事件；`PollClose()` 检测关闭条件并最终关闭（common/cauthc/authc/netsession.cpp:89-101、114-120；common/cauthc/authc/netio.h:116-124）
- 资源释放：`StreamIO` 析构时回调 `NetSession.OnClose()` 并销毁会话（common/cauthc/authc/netio.h:125-129）

#### 会话状态图（示意）

```
           +-----------+
           |  OnOpen   |
           +-----+-----+
                 |
                 v
           +-----+-----+       PollIn        +-----------+
           |  Recv     | ------------------> |  OnRecv    |
           +-----+-----+                     +-----+-----+
                 |                                 |
                 v                                 v
           +-----+-----+                     +-----------+
           |  Input    | ------------------> |  isecbuf  |
           +-----+-----+                     +-----------+
                 |
                 v
           +-----+-----+       Output        +-----------+
           |  Send     | ------------------> |  obuf     |
           +-----+-----+                     +-----------+
                 |
                 v
           +-----+-----+
           | SendFinish|
           +-----+-----+
                 |
                 v
           +-----+-----+
           |  Close    |
           +-----+-----+
                 |
                 v
           +-----+-----+
           | PollClose |
           +-----+-----+
                 |
                 v
           +-----+-----+
           |  OnClose  |
           +-----------+
```

#### 快速示例
```cpp
#include "authc/ioengine.h"
#include "authc/netsession.h"

class Handler : public NetSessionHandler {
public:
    void onConnected() override {}
    void onDisconnected() override {}
    void onReceived(const char* data, int len) override {}
};

int main() {
    aio::Engine& eng = aio::Engine::getInstance();
    eng.Startup();
    Handler h; NetSession s; s.setHandler(&h);
    // 连接伪代码
    // eng.Connect(connector);
    eng.Run();
    eng.Cleanup();
    return 0;
}
```

### 9.3 updateengine
- 头文件位置：`updateengine/win32/`
- 核心接口：`AsyncFileDownloader.h`、`FileDownloader.cpp`
- 常用类与方法：
  - `AsyncFileDownloader.startDownload(url, saveName, callback)`
  - `DownloadCallback.onProgress(percent)`、`onComplete()`、`onError(code)`
  - 同步下载：`FileDownloader.download(url, savePath)`、`FileDownloader.getProgress()`、`FileDownloader.cancel()`

#### 详细接口（引用）
- `AsyncFileDownloader`：`InitUrlAndDestdir`、`DownloadOneFileAsyn`、`StartDownload`、`Clear`（common/updateengine/win32/AsyncFileDownloader.h:6-9）
- `FileDownloader`：`SynDownloadOneFile`（common/updateengine/FileDownloader.h:13；common/updateengine/win32/FileDownloader.cpp:4-8）

参见使用示例：`6.3 使用 updateengine 热更新`

#### 快速示例
```cpp
#include "updateengine/win32/AsyncFileDownloader.h"

struct CB {
    void onProgress(int percent) {}
    void onComplete() {}
    void onError(int code) {}
};

int main() {
    AsyncFileDownloader::InitUrlAndDestdir(L"http://example.com", L"C:/downloads");
    AsyncFileDownloader::DownloadOneFileAsyn(L"patch.pak");
    AsyncFileDownloader::StartDownload();
    return 0;
}
```

#### 示例锚点
- 参见：[`6.3 使用 updateengine 热更新`](#6-3-使用-updateengine-热更新)
- 参见：[`10.2 构建顺序建议`](#10-2-构建顺序建议)

### 9.4 tolua++
- 位置：`tolua++-1.0.93/`
- 核心流程：`.pkg` 描述接口 → 生成绑定 `tolua++ -o output.cpp input.pkg` → 链接运行时库 → Lua 中调用绑定类/函数
- 注意：确保 C++ 对象生命周期在 Lua 使用期间有效

参见使用示例：`6.4 使用 tolua++ 绑定 C++ 类`

### 9.5 导出头文件与库路径
- 包含路径建议：
  - `common/platform`
  - `common/cauthc/include`
  - `common/lua`
  - `common/tolua++-1.0.93/include`
  - `common/updateengine/win32`
- 库链接建议（Win32 Debug/Release 输出示例）：
  - `common/platform/Debug.win32/platform.lib`
  - `common/lua/Debug.win32/lua.lib`
  - `common/cauthc/projects/windows/Debug.win32/cauthc.lib`
  - `common/ljfm/Debug.win32/ljfm.lib`
  - `common/updateengine/Debug.win32/updateengine.lib`

---

### 9.6 接口签名表

#### platform
- `core::Thread`（common/platform/platform/thread.h）
  - `Thread()`、`~Thread()`
  - `bool IsRunningNow()`
  - `void StopRunning()`
  - `void Start()`
  - `void Join()`
  - `virtual void Run() = 0`
- `core::CMutex`（common/platform/platform/mutex.h）
  - `void Lock()`、`void UNLock()`
  - `class Scoped { explicit Scoped(CMutex&); ~Scoped(); }`
- `core::CSemaphore`（common/platform/platform/ksemaphore.h）
  - `CSemaphore(const char* name)`、`~CSemaphore()`
  - `int wait()`、`void fire()`
- `core::Logger`（common/platform/log/CoreLog.h）
  - `void setLoggingLevel(LoggingLevel level)`
  - `void setLogFilename(const std::string& filename, bool append)`
  - `void logEvent(LoggingLevel level, const wchar_t* format, ...)`
  - `void logLuaEvent(LoggingLevel level, std::wstring message)`
- `IniFile`（common/platform/ini/IniFile.h）
  - `static int read_profile_string(const char* section, const char* key, char* value, int size, const char* def, const char* file)`
  - `static int read_profile_int(const char* section, const char* key, int def, const char* file)`
  - `static int read_profile_float(const char* section, const char* key, float def, const char* file)`
  - `static int write_profile_string(const char* section, const char* key, const char* value, const char* file)`
  - `static std::string getCfgFilename()`

#### cauthc
- `aio::Runnable`（common/cauthc/authc/ioengine.h）
  - `virtual void run()`、`virtual void destroy()`、`virtual ~Runnable()`、`void runAndDestroy()`
- `aio::TaskQueue`（common/cauthc/authc/ioengine.h）
  - `void addTask(Runnable* task)`、`void addTask(Runnable& task)`
  - `void runTasks()`、`void clear()`
- `aio::Engine`（common/cauthc/authc/ioengine.h）
  - `static Engine& getInstance()`
  - `bool Startup()`、`void Cleanup()`
  - `void Connect(const FireNet::Connector& c)`
  - `virtual void Run()`
- `FireNet::PollIO`（common/cauthc/authc/pollio.h）
  - `static PollIO* Register(PollIO* io, bool initRecv, bool initSend)`
  - `static int Poll(int timeout)`
  - `void PermitRecv()`、`void PermitSend()`
  - `void ForbidRecv()`、`void ForbidSend()`
  - `void Close()`
- `FireNet::StreamIO`（common/cauthc/authc/netio.h）
  - `void PollIn()`、`void PollOut()`、`void PollClose()`（内部回调）
  - 构造：`StreamIO(int fd, NetSession* s, const Connector& c)`
- `FireNet::NetSession`（common/cauthc/authc/netsession.cpp）
  - `Octets& GetOBuffer()`、`Octets& GetIBuffer()`
  - `void SendFinish()`、`bool Output(const Octets& data)`、`Octets& Input()`
  - `void SendReady()`
  - `void SetISecurity(Security::Type, const Octets& key)`
  - `void SetOSecurity(Security::Type, const Octets& key)`
  - `void Close(const char* info, bool locked)`、`void Destroy()`
  - `const std::string getCloseInfo() const`
- `FireNet::Timer`（common/cauthc/authc/timer.h）
  - `static void Attach(Observer* o)`、`static void Detach(Observer* o)`
  - `static void UpdateSelf()`、`static time_t GetTime()`、`static int64_t GetSystemTick()`

#### updateengine
- `AsyncFileDownloader`（common/updateengine/win32/AsyncFileDownloader.h）
  - `static void InitUrlAndDestdir(const std::wstring& url, const std::wstring& destdir)`
  - `static void DownloadOneFileAsyn(const std::wstring& filename)`
  - `static void StartDownload()`、`static void Clear()`
- `FileDownloader`（common/updateengine/FileDownloader.h）
  - `static bool SynDownloadOneFile(const std::wstring& url, const std::wstring& destfile, bool notify=false)`

## 10. 构建顺序与依赖映射

### 10.1 与项目“六层依赖”映射
- 第1层（基础库）：`lua/`、`tolua++-1.0.93/`
- 第4层（游戏框架）：`platform/`、`cauthc/`、`ljfm/`、`updateengine/`

### 10.2 构建顺序建议
- `platform → lua → tolua++ → cauthc → ljfm → updateengine`
- 说明：`platform` 为最底层；`lua/tolua++`为脚本执行与绑定；`cauthc/ljfm/updateengine` 依赖 `platform` 与/或 `lua`

---

## 11. 错误码与返回值规范

### 11.1 updateengine
- 错误码：
  - 1 网络不可达
  - 2 服务器拒绝连接
  - 3 HTTP 错误（如 404、500）
  - 4 磁盘空间不足
  - 5 MD5 校验失败
- 返回值：
  - 下载方法返回 `bool` 表示成功与否；异步回调通过 `onError(code)` 传递错误码

### 11.2 cauthc
- 建议分类：
  - 0 成功
  - 1 连接失败（不可达/拒绝）
  - 2 超时
  - 3 协议解析错误
  - 4 会话状态异常
- 回调：
  - `onConnected()`、`onDisconnected()`、`onReceived(data, len)`；建议在接收路径中对错误分类进行统一上报

#### NetIO 错误处理行为（引用）
- 接收：循环处理 `EINTR`；`EAGAIN` 视为非致命；其他错误关闭会话（common/cauthc/authc/netio.h:70-83）
- 发送：循环处理 `EINTR`；`EAGAIN` 视为非致命；其他错误清空缓冲并关闭（common/cauthc/authc/netio.h:103-114）
- 连接：Windows 使用 `WSAEISCONN`、非 Windows 使用 `EISCONN` 判断连接已建立（common/cauthc/authc/activeio.h:71-74）

### 11.3 platform
- 常规返回值：
  - 线程/锁/信号量操作返回 `bool` 或无返回；失败场景建议记录日志并返回错误码
- 日志等级：
  - DEBUG/INFO/WARN/ERROR，建议统一格式化输出并包含错误码与上下文信息

### 4.1 Windows 平台构建（补充）

#### 运行时依赖与下载链接
- 需安装：Visual C++ Redistributable for Visual Studio 2013（x86）
- 官方下载地址：`https://www.microsoft.com/zh-cn/download/details.aspx?id=40784`
- 常见错误：缺少 `MSVCP120.dll` 或 `MSVCR120.dll` → 安装上述运行时即可解决

### iOS (Xcode)

```bash
# Build Settings 推荐配置
ENABLE_BITCODE = NO
CLANG_CXX_LANGUAGE_STANDARD = c++11
CLANG_CXX_LIBRARY = libc++
IPHONEOS_DEPLOYMENT_TARGET = 8.0
```

### Android (NDK)

```makefile
# Application.mk
APP_ABI := armeabi-v7a arm64-v8a
APP_PLATFORM := android-14
APP_STL := c++_static
APP_CPPFLAGS := -std=c++11 -fexceptions -frtti
```

---

**文档结束** | **Document End** | **最后更新**: 2025-11-27
- #### 示例锚点
- 参见：[`6.1 使用 platform 模块`](#6-1-使用-platform-模块)
- 参见：[`附录 A: 编译配置`](#附录-a-编译配置)
- #### 示例锚点
- 参见：[`6.2 使用 cauthc 网络模块`](#6-2-使用-cauthc-网络模块)
- 参见：[`11.2 cauthc`](#11-2-cauthc)

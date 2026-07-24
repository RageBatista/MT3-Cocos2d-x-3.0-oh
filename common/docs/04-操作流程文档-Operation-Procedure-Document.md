# 04-操作流程文档 Operation Procedure Document

## 文档信息

| 项目 | 内容 |
|-----|------|
| **文档名称** | MT3 Common 公共库操作流程文档 |
| **文档版本** | v1.0 |
| **创建日期** | 2026-01-27 |
| **最后更新** | 2026-01-27 |
| **适用项目** | MT3 Common 公共库模块 |

---

## 目录

- [1. 概述](#1-概述)
- [2. 构建流程](#2-构建流程)
- [3. 网络通信流程](#3-网络通信流程)
- [4. 认证流程](#4-认证流程)
- [5. 热更新流程](#5-热更新流程)
- [6. 文件操作流程](#6-文件操作流程)
- [7. 日志记录流程](#7-日志记录流程)
- [8. Lua 脚本执行流程](#8-lua-脚本执行流程)
- [9. 错误处理流程](#9-错误处理流程)
- [10. 常见操作场景](#10-常见操作场景)

---

## 1. 概述

### 1.1 文档目的

本文档详细说明 MT3 Common 公共库的各个核心操作流程，包括构建、网络通信、认证、热更新、文件操作等关键流程。

### 1.2 适用人群

- 开发人员
- 测试人员
- 运维人员
- 技术支持人员

### 1.3 流程分类

| 流程类别 | 说明 |
|---------|------|
| **构建流程** | 编译和链接各个模块 |
| **网络通信流程** | 客户端与服务器通信 |
| **认证流程** | 用户身份验证 |
| **热更新流程** | 游戏客户端更新 |
| **文件操作流程** | 文件读写管理 |
| **日志记录流程** | 日志输出和管理 |
| **脚本执行流程** | Lua 脚本运行 |
| **错误处理流程** | 异常捕获和处理 |

---

## 2. 构建流程

### 2.1 Windows 平台构建流程

#### 2.1.1 完整构建流程图

```
开始
  │
  ▼
检查开发环境
  │
  ├─ Visual Studio 2013 已安装？ ──否─► 安装 VS2013
  │                           │
  │                           ▼
  │                        检查 Windows SDK
  │                           │
  │                           ▼
  │                        配置环境变量
  │                           │
  ▼
打开解决方案文件
  │
  ▼
选择构建配置（Debug/Release）
  │
  ▼
选择目标平台（Win32/x64）
  │
  ▼
执行构建
  │
  ├─ 构建成功？ ──否─► 检查错误并修复
  │  │                    │
  │  │                    ▼
  │  │                 重新构建
  │  │                    │
  │  ▼                   ▼
  │  生成库文件
  │  │
  ▼  │
结束  ◄──────────────────┘
```

#### 2.1.2 详细步骤

**步骤 1: 检查开发环境**

```cmd
# 检查 Visual Studio 2013
dir "D:\Program Files (x86)\Microsoft Visual Studio 12.0"

# 检查 Windows SDK 8.1
dir "C:\Program Files (x86)\Windows Kits\8.1"

# 检查环境变量
echo %VS120COMNTOOLS%
```

**步骤 2: 打开解决方案**

1. 导航到项目根目录：`e:\MT3\common`
2. 打开解决方案文件（如果有）
3. 或打开单个项目文件 `.vcxproj`

**步骤 3: 选择构建配置**

- **Debug**: 调试版本，包含调试信息
- **Release**: 发布版本，经过优化

**步骤 4: 选择目标平台**

- **Win32**: 32位 Windows
- **x64**: 64位 Windows

**步骤 5: 执行构建**

- 菜单：生成 → 生成解决方案
- 或按 `Ctrl+Shift+B`

**步骤 6: 验证构建结果**

```cmd
# 检查输出目录
dir common\cauthc\projects\windows\Release.win32\
dir common\platform\Release.win32\
dir common\lua\Release.win32\
dir common\ljfm\Release.win32\
dir common\updateengine\Release.win32\
```

#### 2.1.3 命令行构建流程

```cmd
@echo off
setlocal

# 设置环境变量
set VS120COMNTOOLS=D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\

# 按顺序构建各模块
echo Building platform...
cd platform
msbuild platform.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
if %errorlevel% neq 0 goto error
cd ..

echo Building lua...
cd lua
msbuild lua.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
if %errorlevel% neq 0 goto error
cd ..

echo Building cauthc...
cd cauthc\projects\windows
msbuild cauthc.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
if %errorlevel% neq 0 goto error
cd ..\..

echo Building ljfm...
cd ljfm
msbuild ljfm.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
if %errorlevel% neq 0 goto error
cd ..

echo Building updateengine...
cd updateengine
msbuild updateengine.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
if %errorlevel% neq 0 goto error
cd ..

echo Build successful!
goto end

:error
echo Build failed!
exit /b 1

:end
endlocal
```

### 2.2 iOS 平台构建流程

#### 2.2.1 完整构建流程图

```
开始
  │
  ▼
检查开发环境
  │
  ├─ Xcode 已安装？ ──否─► 安装 Xcode
  │  │                 │
  │  │                 ▼
  │  │              配置开发者账号
  │  │                 │
  ▼  │
打开 Xcode 项目
  │
  ▼
选择 Scheme
  │
  ▼
选择 Destination
  │
  ├─ Device？ ──是─► 选择真机
  │  │            │
  │  │            ▼
  │  │         配置签名证书
  │  │            │
  │  ▼            │
  │  Simulator ◄──┘
  │
  ▼
选择构建配置（Debug/Release）
  │
  ▼
执行构建
  │
  ├─ 构建成功？ ──否─► 检查错误并修复
  │  │                    │
  │  │                    ▼
  │  │                 重新构建
  │  │                    │
  │  ▼                   ▼
  │  生成库文件
  │  │
  ▼  │
结束  ◄──────────────────┘
```

#### 2.2.2 详细步骤

**步骤 1: 检查开发环境**

```bash
# 检查 Xcode 版本
xcodebuild -version

# 检查 iOS SDK
xcodebuild -showsdks
```

**步骤 2: 打开 Xcode 项目**

```bash
cd common/platform
open share.xcodeproj
```

**步骤 3: 选择 Scheme**

- **platform**: platform 模块
- **ljfm**: ljfm 模块

**步骤 4: 选择 Destination**

- **Generic iOS Device**: 真机
- **iOS Simulator**: 模拟器

**步骤 5: 选择构建配置**

- **Debug**: 调试版本
- **Release**: 发布版本

**步骤 6: 执行构建**

- 菜单：Product → Build
- 或按 `Cmd+B`

**步骤 7: 验证构建结果**

```bash
# 检查输出目录
ls -la ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Release-iphoneos/
```

#### 2.2.3 命令行构建流程

```bash
#!/bin/bash

echo "Building platform..."
cd platform
xcodebuild -project share.xcodeproj \
          -scheme platform \
          -configuration Release \
          -sdk iphoneos \
          clean build
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
cd ..

echo "Building ljfm..."
cd ljfm
xcodebuild -project ljfm.xcodeproj \
          -scheme ljfm \
          -configuration Release \
          -sdk iphoneos \
          clean build
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
cd ..

echo "Build successful!"
```

### 2.3 Android 平台构建流程

#### 2.3.1 完整构建流程图

```
开始
  │
  ▼
检查开发环境
  │
  ├─ NDK 已安装？ ──否─► 安装 Android NDK
  │  │               │
  │  │               ▼
  │  │            配置环境变量
  │  │               │
  ▼  │
进入模块目录
  │
  ▼
检查 Android.mk
  │
  ▼
执行 ndk-build
  │
  ├─ 构建成功？ ──否─► 检查错误并修复
  │  │                    │
  │  │                    ▼
  │  │                 重新构建
  │  │                    │
  │  ▼                   ▼
  │  生成库文件
  │  │
  ▼  │
结束  ◄──────────────────┘
```

#### 2.3.2 详细步骤

**步骤 1: 检查开发环境**

```bash
# 检查 NDK 版本
echo $ANDROID_NDK

# 检查 ndk-build
which ndk-build
```

**步骤 2: 进入模块目录**

```bash
cd common/platform
```

**步骤 3: 执行构建**

```bash
# 构建 Debug 版本
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk

# 构建 Release 版本
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk NDK_DEBUG=0

# 清理构建
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk clean
```

**步骤 4: 验证构建结果**

```bash
# 检查输出目录
ls -la common/platform/libs/armeabi-v7a/
ls -la common/platform/libs/arm64-v8a/
```

#### 2.3.3 完整构建脚本

```bash
#!/bin/bash

export ANDROID_NDK=/path/to/android-ndk
export PATH=$ANDROID_NDK:$PATH

echo "Building platform..."
cd platform
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
cd ..

echo "Building lua..."
cd lua
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
cd ..

echo "Building cauthc..."
cd cauthc/projects/android
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
cd ../..

echo "Building ljfm..."
cd ljfm
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
cd ..

echo "Building updateengine..."
cd updateengine
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
cd ..

echo "Build successful!"
```

---

## 3. 网络通信流程

### 3.1 客户端连接服务器流程

#### 3.1.1 连接流程图

```
开始
  │
  ▼
创建 IO 引擎实例
  │
  ▼
启动 IO 引擎
  │
  ▼
创建连接器对象
  │
  ▼
设置服务器地址和端口
  │
  ▼
发起连接请求
  │
  ├─ 连接成功？ ──否─► 连接失败处理
  │  │               │
  │  │               ▼
  │  │           记录错误日志
  │  │               │
  │  ▼               │
  │  创建网络会话    │
  │  │               │
  ▼  │               │
注册会话回调    │
  │               │
  │               │
  ▼               │
进入事件循环    │
  │               │
  │               │
  ▼               │
等待网络事件    │
  │               │
  │               │
  ▼               │
处理网络事件    │
  │               │
  │               │
  └───────────────┘
  │
  ▼
结束
```

#### 3.1.2 代码示例

```cpp
#include "cauthc/authc/ioengine.h"
#include "cauthc/include/protocol.h"

class MyManager : public aio::Manager {
protected:
    virtual void OnAddSession(Session::ID sid, const FireNet::Connector& conn, 
                             const std::string& info) override {
        SDLOG_INFO(L"Session added: %d", sid);
    }
    
    virtual void OnDelSession(Session* session) override {
        SDLOG_INFO(L"Session deleted: %d", session->getSID());
    }
    
    virtual void AbortSession(const FireNet::SockAddr& addr, Session* session, 
                            const FireNet::Connector& conn) override {
        SDLOG_INFO(L"Session aborted");
    }
};

int main() {
    // 获取 IO 引擎实例
    aio::Engine& engine = aio::Engine::getInstance();
    
    // 启动引擎
    if (!engine.Startup()) {
        SDLOG_ERR(L"Failed to start engine");
        return -1;
    }
    
    // 创建连接器
    FireNet::Connector conn;
    conn.host = "127.0.0.1";
    conn.port = "8000";
    
    // 连接服务器
    engine.Connect(conn);
    
    // 运行事件循环
    engine.Run();
    
    return 0;
}
```

### 3.2 发送协议流程

#### 3.2.1 发送流程图

```
开始
  │
  ▼
创建协议对象
  │
  ▼
设置协议参数
  │
  ▼
序列化协议
  │
  ▼
获取会话 ID
  │
  ▼
发送协议到服务器
  │
  ├─ 发送成功？ ──否─► 发送失败处理
  │  │               │
  │  │               ▼
  │  │           记录错误日志
  │  │               │
  │  ▼               │
  │  加入发送队列    │
  │  │               │
  ▼  │               │
等待发送完成    │
  │               │
  │               │
  ▼               │
发送完成回调    │
  │               │
  │               │
  └───────────────┘
  │
  ▼
结束
```

#### 3.2.2 代码示例

```cpp
// 创建协议对象
gnet::KeepAlive keepAlive;

// 设置协议参数（如果有）
// keepAlive.timestamp = ...;

// 发送协议
manager.Send(sessionId, keepAlive);

// 或者发送原始字节流
FireNet::Octets data;
// ... 填充数据 ...
manager.Send(sessionId, data);
```

### 3.3 接收协议流程

#### 3.3.1 接收流程图

```
开始
  │
  ▼
接收网络数据
  │
  ▼
解析协议头
  │
  ├─ 解析成功？ ──否─► 协议错误处理
  │  │               │
  │  │               ▼
  │  │           记录错误日志
  │  │               │
  │  ▼               │
  │  关闭连接        │
  │  │               │
  ▼  │               │
获取协议类型    │
  │               │
  │               │
  ▼               │
创建协议对象    │
  │               │
  │               │
  ▼               │
反序列化数据    │
  │               │
  ├─ 反序列化成功？ ──否─► 数据错误处理
  │  │               │
  │  │               ▼
  │  │           记录错误日志
  │  │               │
  │  ▼               │
  │  丢弃协议        │
  │  │               │
  ▼  │               │
分发协议        │
  │               │
  │               │
  ▼               │
执行协议处理    │
  │               │
  │               │
  ▼               │
处理完成        │
  │               │
  │               │
  └───────────────┘
  │
  ▼
结束
```

#### 3.3.2 代码示例

```cpp
class MyProtocol : public aio::Protocol {
public:
    static const ProtocolType PROTOCOL_TYPE = 0x100;
    
    MyProtocol() : Protocol(PROTOCOL_TYPE) {}
    
    virtual void Process(Manager* mgr, Manager::Session::ID sid) override {
        SDLOG_INFO(L"Processing protocol: %d", sid);
        
        // 处理协议逻辑
        // ...
    }
    
    virtual Protocol* Clone() const override {
        return new MyProtocol(*this);
    }
};

// 注册协议
static aio::Protocol::TStub<MyProtocol> stub;
```

---

## 4. 认证流程

### 4.1 客户端认证流程

#### 4.1.1 认证流程图

```
开始
  │
  ▼
连接到认证服务器
  │
  ▼
发送认证请求
  │
  ├─ 发送成功？ ──否─► 连接失败处理
  │  │               │
  │  ▼               │
  │  等待服务器响应  │
  │  │               │
  │  ▼               │
  │  接收响应        │
  │  │               │
  │  ├─ 响应成功？ ──否─► 认证失败处理
  │  │  │               │
  │  │  │               ▼
  │  │  │           记录错误日志
  │  │  │               │
  │  │  │               ▼
  │  │  │           提示用户重新登录
  │  │  │               │
  │  ▼  │               │
  │  解析认证结果    │
  │  │               │
  │  ▼               │
  │  保存会话信息    │
  │  │               │
  │  ▼               │
  │  认证成功        │
  │  │               │
  │  ▼               │
  │  进入游戏主界面  │
  │  │               │
  └───────────────────┘
  │
  ▼
结束
```

#### 4.1.2 代码示例

```cpp
// 发送认证请求
gnet::KeyExchange keyExchange;
// 设置认证参数
// keyExchange.username = "player";
// keyExchange.password = "password";
manager.Send(sessionId, keyExchange);

// 处理认证响应
class KeyExchangeHandler : public aio::Protocol {
public:
    virtual void Process(Manager* mgr, Manager::Session::ID sid) override {
        if (success) {
            SDLOG_INFO(L"Authentication successful");
            // 保存会话信息
            // 进入游戏主界面
        } else {
            SDLOG_ERR(L"Authentication failed");
            // 提示用户重新登录
        }
    }
};
```

---

## 5. 热更新流程

### 5.1 完整热更新流程

#### 5.1.1 热更新流程图

```
开始
  │
  ▼
初始化更新引擎
  │
  ▼
加载本地版本信息
  │
  ▼
连接到更新服务器
  │
  ├─ 连接成功？ ──否─► 连接失败处理
  │  │               │
  │  ▼               │
  │  获取服务器版本  │
  │  │               │
  │  ▼               │
  │  比较版本号    │
  │  │               │
  │  ├─ 需要更新？ ──否─► 无需更新
  │  │  │               │
  │  │  │               ▼
  │  │  │           进入游戏
  │  │  │               │
  │  ▼  │               │
  │  下载版本文件  │
  │  │               │
  │  ├─ 下载成功？ ──否─► 下载失败处理
  │  │  │               │
  │  │  │               ▼
  │  │  │           记录错误日志
  │  │  │               │
  │  │  │               ▼
  │  │  │           提示用户重试
  │  │  │               │
  │  ▼  │               │
  │  解析更新包列表  │
  │  │               │
  │  ▼  │               │
  │  下载更新包    │
  │  │               │
  │  ├─ 下载成功？ ──否─► 下载失败处理
  │  │  │               │
  │  │  │               ▼
  │  │  │           记录错误日志
  │  │  │               │
  │  │  │               ▼
  │  │  │           提示用户重试
  │  │  │               │
  │  ▼  │               │
  │  校验文件完整性  │
  │  │               │
  │  ├─ 校验成功？ ──否─► 校验失败处理
  │  │  │               │
  │  │  │               ▼
  │  │  │           记录错误日志
  │  │  │               │
  │  │  │               ▼
  │  │  │           重新下载
  │  │  │               │
  │  ▼  │               │
  │  备份旧文件    │
  │  │               │
  │  ▼  │               │
  │  替换新文件    │
  │  │               │
  │  ▼  │               │
  │  更新版本信息    │
  │  │               │
  │  ▼  │               │
  │  清理临时文件    │
  │  │               │
  │  ▼  │               │
  │  重启应用      │
  │  │               │
  └───────────────────┘
  │
  ▼
结束
```

#### 5.1.2 代码示例

```cpp
#include "updateengine/UpdateEngine.h"

int main() {
    // 初始化更新引擎
    UpdateEngine::Initialize();
    
    // 运行更新流程
    UpdateEngine::Run();
    
    return 0;
}

// 更新结束回调
void OnUpdateEnd(bool bRet, bool isFirstDownload) {
    if (bRet) {
        SDLOG_INFO(L"Update successful");
        // 重启应用
    } else {
        SDLOG_ERR(L"Update failed");
        // 提示用户
    }
}
```

### 5.2 更新步骤详解

#### 5.2.1 StepInit - 初始化

```cpp
int UpdateManagerEx::StepInit() {
    // 设置下载站点
    SetDownloadSite(L"http://update.example.com", 
                  L"http://app.example.com", 
                  L"http://wg.example.com");
    
    // 初始化路径
    m_RootPath = L"C:\\GameData";
    m_RootResPath = m_RootPath + L"\\res";
    m_CacheResPath = m_RootPath + L"\\cache";
    m_CacheUpdatePath = m_RootPath + L"\\update";
    
    return 0;
}
```

#### 5.2.2 StepLoadVersion - 加载版本

```cpp
int UpdateManagerEx::StepLoadVersion() {
    // 读取本地版本文件
    std::wstring versionFile = m_RootPath + L"\\version.txt";
    
    // 解析版本号
    // m_Version = ...;
    // m_VersionCaption = ...;
    
    return 0;
}
```

#### 5.2.3 StepCheckVersion - 检查版本

```cpp
int UpdateManagerEx::StepCheckVersion() {
    // 连接到更新服务器
    // 获取服务器版本
    
    // 比较版本号
    if (serverVersion > localVersion) {
        // 需要更新
        return 1;
    } else {
        // 无需更新
        return 0;
    }
}
```

#### 5.2.4 StepDownloadPackInfo - 下载包信息

```cpp
int UpdateManagerEx::StepDownloadPackInfo() {
    // 下载版本文件列表
    std::wstring url = m_DownloadSite + L"/version.xml";
    std::wstring dest = m_CacheUpdatePath + L"\\version.xml";
    
    bool success = FileDownloader::SynDownloadOneFile(url, dest, true);
    
    if (!success) {
        SDLOG_ERR(L"Failed to download version file");
        return -1;
    }
    
    return 0;
}
```

#### 5.2.5 StepUpdatePackInfo - 更新包信息

```cpp
int UpdateManagerEx::StepUpdatePackInfo() {
    // 遍历更新包列表
    for (auto& pack : updatePacks) {
        // 下载包文件
        std::wstring url = m_DownloadSite + L"/" + pack.filename;
        std::wstring dest = m_CacheUpdatePath + L"\\" + pack.filename;
        
        bool success = FileDownloader::SynDownloadOneFile(url, dest, true);
        
        if (!success) {
            SDLOG_ERR(L"Failed to download pack: %s", pack.filename.c_str());
            continue;
        }
        
        // 校验文件完整性
        if (!VerifyFile(dest, pack.md5)) {
            SDLOG_ERR(L"File verification failed: %s", pack.filename.c_str());
            continue;
        }
        
        // 备份旧文件
        BackupOldFile(pack.path);
        
        // 替换新文件
        ReplaceFile(dest, pack.path);
    }
    
    return 0;
}
```

---

## 6. 文件操作流程

### 6.1 使用 LJFM 文件系统

#### 6.1.1 文件操作流程图

```
开始
  │
  ▼
创建文件系统实例
  │
  ▼
初始化文件系统
  │
  ├─ 初始化成功？ ──否─► 初始化失败处理
  │  │               │
  │  │               ▼
  │  │           记录错误日志
  │  │               │
  │  ▼               │
  │  退出            │
  │  │               │
  ▼  │               │
打开文件        │
  │               │
  ├─ 打开成功？ ──否─► 打开失败处理
  │  │               │
  │  │               ▼
  │  │           记录错误日志
  │  │               │
  │  ▼               │
  │  退出            │
  │  │               │
  ▼  │               │
读取/写入数据   │
  │               │
  │               │
  ▼  │               │
关闭文件        │
  │               │
  │               │
  ▼  │               │
文件关闭回调    │
  │               │
  │               │
  ▼  │               │
结束            │
  │               │
  └───────────────┘
  │
  ▼
结束
```

#### 6.1.2 代码示例

```cpp
#include "ljfm/code/include/ljfm.h"

int main() {
    // 创建文件系统实例
    LJFM::LJFMBase* fs = LJFM::LJFMBase::Create(LJFM::FS_TYPE_STANDARD);
    
    // 初始化文件系统
    if (fs->Initialize(L"C:\\GameData") != 0) {
        SDLOG_ERR(L"Failed to initialize file system");
        return -1;
    }
    
    // 打开文件
    LJFM::LJFMBF* file;
    if (fs->OpenFile(L"data.txt", FILE_MODE_READ, FILE_ACCESS_READ, file) != 0) {
        SDLOG_ERR(L"Failed to open file");
        fs->Destroy();
        return -1;
    }
    
    // 读取数据
    char buffer[1024];
    size_t bytesRead = file->Read(buffer, sizeof(buffer));
    
    // 关闭文件
    file->Close();
    
    // 销毁文件系统
    fs->Destroy();
    
    return 0;
}
```

---

## 7. 日志记录流程

### 7.1 日志记录流程

#### 7.1.1 日志流程图

```
开始
  │
  ▼
初始化日志系统
  │
  ▼
设置日志级别
  │
  ▼
设置日志文件
  │
  ▼
记录日志
  │
  ▼
检查日志级别
  │
  ├─ 级别匹配？ ──否─► 丢弃日志
  │  │               │
  │  ▼               │
  │  格式化日志    │
  │  │               │
  │  ▼               │
  │  写入日志文件  │
  │  │               │
  │  ▼               │
  │  刷新缓冲区    │
  │  │               │
  │  ▼               │
  │  发送到 Flurry│
  │  │               │
  └───────────────┘
  │
  ▼
结束
```

#### 7.1.2 代码示例

```cpp
#include "platform/log/CoreLog.h"

int main() {
    // 初始化日志系统
    core::Logger::GetInstance()->setLoggingLevel(core::Informative);
    core::Logger::GetInstance()->setLogFilename("game.log", false);
    
    // 记录日志
    SDLOG_ERR(L"Error occurred: %s", L"timeout");
    SDLOG_WARN(L"Warning: %d", 42);
    SDLOG_STD(L"Standard message");
    SDLOG_INFO(L"Info: %s", L"connected");
    SDLOG_INSANE(L"Debug: x=%d, y=%d", 100, 200);
    
    // Flurry 统计
    core::Logger::flurryEvent(L"level_up");
    core::Logger::flurryEvent(L"purchase", L"item", L"sword");
    core::Logger::flurryError(L"network_error", L"code", L"404");
    
    return 0;
}
```

---

## 8. Lua 脚本执行流程

### 8.1 Lua 脚本执行流程

#### 8.1.1 执行流程图

```
开始
  │
  ▼
创建 Lua 状态
  │
  ▼
打开标准库
  │
  ▼
加载 tolua++ 绑定
  │
  ▼
加载 Lua 脚本
  │
  ├─ 加载成功？ ──否─► 加载失败处理
  │  │               │
  │  │               ▼
  │  │           记录错误日志
  │  │               │
  │  ▼               │
  │  退出            │
  │  │               │
  ▼  │               │
执行 Lua 函数  │
  │               │
  │               │
  ▼  │               │
获取返回值      │
  │               │
  │               │
  ▼  │               │
处理返回值      │
  │               │
  │               │
  ▼  │               │
关闭 Lua 状态  │
  │               │
  │               │
  ▼  │               │
结束            │
  │               │
  └───────────────┘
  │
  ▼
结束
```

#### 8.1.2 代码示例

```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main() {
    // 创建 Lua 状态
    lua_State* L = luaL_newstate();
    
    // 打开标准库
    luaL_openlibs(L);
    
    // 加载 tolua++ 绑定
    // tolua_open(L);
    
    // 加载 Lua 脚本
    if (luaL_dofile(L, "script.lua") != 0) {
        SDLOG_ERR(L"Lua error: %s", lua_tostring(L, -1));
        lua_close(L);
        return -1;
    }
    
    // 调用 Lua 函数
    lua_getglobal(L, "main");
    if (lua_pcall(L, 0, 1, 0) != 0) {
        SDLOG_ERR(L"Lua error: %s", lua_tostring(L, -1));
    } else {
        // 获取返回值
        int result = lua_tonumber(L, -1);
        SDLOG_INFO(L"Lua function returned: %d", result);
        lua_pop(L, 1);
    }
    
    // 关闭 Lua 状态
    lua_close(L);
    
    return 0;
}
```

---

## 9. 错误处理流程

### 9.1 错误处理流程

#### 9.1.1 错误处理流程图

```
开始
  │
  ▼
执行操作
  │
  ▼
检查错误
  │
  ├─ 有错误？ ──否─► 操作成功
  │  │           │
  │  │           ▼
  │  │       继续执行
  │  │           │
  │  ▼           │
  获取错误信息  │
  │           │
  │  ▼           │
  记录错误日志  │
  │           │
  │  ▼           │
  判断错误类型  │
  │           │
  │  ▼           │
  ├─ 网络错误？ ──是─► 网络错误处理
  │  │               │
  │  │               ▼
  │  │           重试连接
  │  │               │
  │  ▼           │
  ├─ 文件错误？ ──是─► 文件错误处理
  │  │               │
  │  │               ▼
  │  │           检查文件权限
  │  │               │
  │  ▼           │
  ├─ 内存错误？ ──是─► 内存错误处理
  │  │               │
  │  │               ▼
  │  │           释放资源
  │  │               │
  │  ▼           │
  ├─ 协议错误？ ──是─► 协议错误处理
  │  │               │
  │  │               ▼
  │  │           关闭连接
  │  │               │
  │  ▼           │
  其他错误处理    │
  │           │
  │  ▼           │
  提示用户      │
  │           │
  │  ▼           │
  清理资源      │
  │           │
  │  ▼           │
  返回错误码    │
  │           │
  └───────────┘
  │
  ▼
结束
```

#### 9.1.2 代码示例

```cpp
try {
    // 执行操作
    int result = SomeOperation();
    
    if (result != 0) {
        throw std::runtime_error("Operation failed");
    }
    
} catch (const std::exception& e) {
    // 记录错误
    SDLOG_ERR(L"Exception: %s", e.what());
    
    // 清理资源
    Cleanup();
    
    // 返回错误码
    return -1;
}
```

---

## 10. 常见操作场景

### 10.1 场景 1: 首次运行

#### 10.1.1 操作流程

```
开始
  │
  ▼
检查配置文件
  │
  ├─ 配置文件存在？ ──否─► 创建默认配置
  │  │               │
  │  │               ▼
  │  │           写入默认值
  │  │               │
  │  ▼               │
  │  读取配置      │
  │  │               │
  │  ▼               │
  │  初始化模块    │
  │  │               │
  │  ▼               │
  │  显示欢迎界面  │
  │  │               │
  └───────────────┘
  │
  ▼
结束
```

### 10.2 场景 2: 网络断线重连

#### 10.2.1 操作流程

```
开始
  │
  ▼
检测网络断线
  │
  ▼
记录断线日志
  │
  ▼
启动重连定时器
  │
  ▼
等待重连间隔
  │
  ▼
尝试重新连接
  │
  ├─ 连接成功？ ──是─► 连接成功处理
  │  │               │
  │  │               ▼
  │  │           取消重连定时器
  │  │               │
  │  │               ▼
  │  │           恢复正常操作
  │  │               │
  │  ▼               │
  │  结束        │
  │  │               │
  │  ▼               │
  ├─ 重试次数 < 最大值？ ──否─► 重连失败处理
  │  │               │
  │  │               ▼
  │  │           提示用户
  │  │               │
  │  │               ▼
  │  │           结束
  │  │               │
  │  ▼               │
  增加重试计数  │
  │               │
  │  ▼               │
  继续等待      │
  │               │
  └───────────────┘
  │
  ▼
结束
```

### 10.3 场景 3: 更新失败回滚

#### 10.3.1 操作流程

```
开始
  │
  ▼
检测更新失败
  │
  ▼
记录失败日志
  │
  ▼
检查备份文件
  │
  ├─ 备份存在？ ──是─► 恢复备份
  │  │               │
  │  │               ▼
  │  │           删除损坏文件
  │  │               │
  │  │           ▼
  │  │           恢复备份文件
  │  │               │
  │  │           ▼
  │  │           恢复版本信息
  │  │               │
  │  ▼               │
  │  结束        │
  │  │               │
  │  ▼               │
  提示用户      │
  │               │
  │  ▼               │
  清理临时文件  │
  │               │
  │  ▼               │
  结束        │
  │               │
  └───────────────┘
  │
  ▼
结束
```

---

**文档结束**

# 01-架构设计文档 Architecture Design Document

## 文档信息

| 项目 | 内容 |
|-----|------|
| **文档名称** | MT3 Common 公共库架构设计文档 |
| **文档版本** | v1.0 |
| **创建日期** | 2026-01-27 |
| **最后更新** | 2026-01-27 |
| **适用项目** | MT3 Common 公共库模块 |

---

## 1. 概述

### 1.1 项目简介

MT3 Common 是 MT3 游戏项目的客户端与服务器共享的基础库模块，提供跨平台的底层功能支持。该公共库采用模块化设计，各模块职责清晰，通过统一的接口规范进行交互。

### 1.2 设计目标

- **跨平台兼容性**: 支持 Windows、Android、iOS、Windows Phone 8 等多个平台
- **模块化架构**: 各模块独立编译，降低耦合度
- **高性能**: 采用异步 IO、多线程等技术提升性能
- **可扩展性**: 提供灵活的接口设计，便于功能扩展
- **易用性**: 封装复杂底层操作，提供简洁的 API

### 1.3 技术栈

| 技术类别 | 技术选型 | 版本 |
|---------|---------|------|
| **编程语言** | C++ | C++11 标准 |
| **Lua 解释器** | Lua | 5.1 |
| **C++/Lua 绑定** | tolua++ | 1.0.93 |
| **网络框架** | 自研异步 IO 框架 | aio 命名空间 |
| **构建工具** | Visual Studio / Xcode / NDK | VS2013 / Xcode7+ / NDK r8+ |
| **平台工具集** | Platform Toolset | v120 (Windows) |

---

## 2. 系统架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        MT3 Common 公共库                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   cauthc     │  │    ljfm      │  │updateengine  │        │
│  │  (认证网络)  │  │  (游戏模块)  │  │  (热更新)    │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                 │                 │                   │
│         └─────────────────┼─────────────────┘                   │
│                           │                                     │
│  ┌────────────────────────▼──────────────────────────┐          │
│  │                   platform                      │          │
│  │              (跨平台基础库)                      │          │
│  │  - 线程  - 互斥锁  - 信号量  - 日志  - 工具    │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │     lua      │  │   tolua++    │                         │
│  │  (脚本引擎)  │  │  (绑定工具)   │                         │
│  └──────────────┘  └──────────────┘                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 模块分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    应用层 (Application Layer)               │
│  游戏客户端 / 游戏服务器                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    业务层 (Business Layer)                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│  │  cauthc  │  │   ljfm   │  │  update  │               │
│  │  认证模块  │  │ 游戏模块  │  │ 更新模块  │               │
│  └──────────┘  └──────────┘  └──────────┘               │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   平台层 (Platform Layer)                  │
│  ┌──────────────────────────────────────────────────┐    │
│  │                  platform                        │    │
│  │  - 线程管理  - 互斥锁  - 信号量  - 日志系统    │    │
│  │  - INI配置  - 文件操作  - 字符串处理          │    │
│  └──────────────────────────────────────────────────┘    │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   脚本层 (Script Layer)                   │
│  ┌──────────┐  ┌──────────┐                            │
│  │   lua    │  │ tolua++  │                            │
│  │  解释器   │  │  绑定工具  │                            │
│  └──────────┘  └──────────┘                            │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  系统层 (System Layer)                    │
│  Windows API / POSIX API / Android NDK / iOS SDK          │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 核心模块设计

### 3.1 cauthc - 客户端认证与网络通信模块

#### 3.1.1 模块职责

- 提供客户端与服务器之间的网络通信能力
- 实现认证协议和安全通信
- 提供 RPC 框架支持远程过程调用
- 管理网络会话和连接状态

#### 3.1.2 架构设计

```
cauthc 模块架构
│
├── aio (异步 IO 命名空间)
│   ├── Engine           # IO 引擎，管理事件循环
│   ├── TaskQueue        # 任务队列，异步任务调度
│   ├── Runnable         # 可运行任务接口
│   └── PollIO          # IO 多路复用基类
│
├── FireNet (网络通信命名空间)
│   ├── NetSession       # 网络会话管理
│   ├── NetIO            # 网络 IO 基类
│   ├── StreamIO         # 流式 IO 实现
│   ├── Connector        # 连接器
│   ├── SockAddr         # Socket 地址封装
│   ├── Mutex            # 互斥锁
│   └── AtomicLong       # 原子长整型
│
├── Protocol (协议处理)
│   ├── Manager          # 协议管理器
│   ├── Protocol         # 协议基类
│   ├── LuaProtocol      # Lua 协议
│   └── ProtocolException # 协议异常
│
├── RPC 框架
│   ├── rpcgen          # RPC 代码生成器
│   ├── gnet            # 游戏网络协议定义
│   └── Marshal         # 序列化/反序列化
│
├── 数据结构
│   ├── Octets          # 字节流容器
│   ├── OctetsStream    # 字节流操作
│   └── Security        # 安全加密
│
└── 平台适配
    ├── os/windows      # Windows 平台实现
    ├── os/ios          # iOS 平台实现
    ├── os/android      # Android 平台实现
    └── os/linux        # Linux 平台实现
```

#### 3.1.3 核心类设计

##### Engine (IO 引擎)

```cpp
namespace aio {
    class Engine : public Thread {
    private:
        TaskQueue taskqueue;
        bool exit;
        
    public:
        static Engine& getInstance();
        bool Startup();
        void Cleanup();
        void Connect(const FireNet::Connector& c);
        virtual void Run();
    };
}
```

**职责**:
- 单例模式管理 IO 引擎实例
- 运行事件循环处理网络事件
- 管理任务队列调度异步任务
- 处理连接请求

##### NetSession (网络会话)

```cpp
namespace FireNet {
    class NetSession {
    protected:
        Octets ibuffer;          // 输入缓冲区
        Octets obuffer;          // 输出缓冲区
        NetIO* assoc_io;         // 关联的 IO 对象
        Mutex locker;            // 会话锁
        
    public:
        virtual void OnOpen(const SockAddr& local, const SockAddr& peer);
        virtual void OnClose();
        virtual void OnRecv();
        virtual void OnSend();
        virtual void Close(const char* info, bool discard);
        
        Octets& GetIBuffer();
        Octets& GetOBuffer();
    };
}
```

**职责**:
- 管理网络连接的生命周期
- 处理数据收发
- 维护会话状态
- 提供缓冲区管理

##### Protocol (协议基类)

```cpp
namespace aio {
    class Protocol : public FireNet::Marshal {
    protected:
        ProtocolType type;
        
    public:
        virtual ~Protocol();
        FireNet::Octets encode() const;
        ProtocolType getType() const;
        
        virtual void Process(Manager*, Manager::Session::ID) = 0;
        virtual Protocol* Clone() const = 0;
        
        static Protocol* Create(ProtocolType type);
        static void AddStub(Stub* stub);
        static void DelStub(ProtocolType type);
    };
}
```

**职责**:
- 定义协议接口规范
- 实现协议序列化/反序列化
- 提供协议工厂模式
- 支持协议注册和分发

#### 3.1.4 网络协议定义

cauthc 模块定义了以下核心网络协议：

| 协议名称 | 协议类型 | 功能描述 |
|---------|---------|---------|
| **KeyExchange** | 密钥交换 | 客户端与服务器之间的密钥协商 |
| **Challenge** | 挑战应答 | 认证过程中的挑战-应答机制 |
| **KeepAlive** | 心跳保活 | 维持连接活跃状态 |
| **Response** | 响应消息 | 通用响应协议 |
| **SSOGetTicketReq** | SSO 请求 | 单点登录票据请求 |
| **SSOGetTicketRep** | SSO 响应 | 单点登录票据响应 |
| **OnlineAnnounce** | 在线公告 | 服务器在线公告推送 |
| **AnnounceForbidInfo** | 禁令公告 | 禁令信息公告 |
| **GetUserCouponReq** | 优惠券请求 | 获取用户优惠券 |
| **GetUserCouponRep** | 优惠券响应 | 优惠券信息返回 |
| **CouponExchangeReq** | 优惠券兑换 | 优惠券兑换请求 |
| **CouponExchangeRep** | 兑换响应 | 优惠券兑换结果 |
| **InstantAddCashReq** | 充值请求 | 即时充值请求 |
| **InstantAddCashRep** | 充值响应 | 充值结果返回 |
| **PortForward** | 端口转发 | 端口转发配置 |

#### 3.1.5 数据序列化

**Marshal (序列化基类)**

```cpp
namespace FireNet {
    class Marshal {
    public:
        class OctetsStream {
        private:
            Octets data;
            mutable uint32_t pos;
            mutable uint32_t tranpos;
            
        public:
            OctetsStream& operator<<(char x);
            OctetsStream& operator<<(int32_t x);
            OctetsStream& operator<<(uint32_t x);
            OctetsStream& operator<<(float x);
            OctetsStream& operator<<(const std::string& x);
            OctetsStream& operator<<(const Octets& x);
            
            const OctetsStream& operator>>(char& x) const;
            const OctetsStream& operator>>(int32_t& x) const;
            const OctetsStream& operator>>(uint32_t& x) const;
            const OctetsStream& operator>>(float& x) const;
            const OctetsStream& operator>>(std::string& x) const;
            const OctetsStream& operator>>(Octets& x) const;
            
            OctetsStream& compact_uint32(size_t x);
            const OctetsStream& uncompact_uint32(uint32_t& x) const;
        };
        
        virtual OctetsStream& marshal(OctetsStream&) const = 0;
        virtual const OctetsStream& unmarshal(const OctetsStream&) = 0;
    };
}
```

**特性**:
- 支持基本数据类型序列化
- 支持容器类型 (vector, list, map, deque)
- 支持紧凑整数编码 (节省带宽)
- 支持事务处理 (Begin/Commit/Rollback)

---

### 3.2 platform - 跨平台基础库

#### 3.2.1 模块职责

- 提供跨平台的线程管理
- 提供同步原语 (互斥锁、信号量)
- 提供日志系统
- 提供配置文件解析
- 提供工具函数库

#### 3.2.2 架构设计

```
platform 模块架构
│
├── core (核心命名空间)
│   ├── Thread           # 线程抽象
│   ├── CMutex          # 互斥锁
│   └── Logger          # 日志系统
│
├── 平台适配
│   ├── platform/
│   │   ├── thread.h/cpp      # 线程实现
│   │   ├── mutex.h/cpp       # 互斥锁实现
│   │   ├── ksemaphore.h/cpp  # 信号量实现
│   │   ├── usememory.h/cpp   # 内存管理
│   │   └── platform_types.h  # 平台类型定义
│   ├── android/         # Android 平台实现
│   ├── ios/            # iOS 平台实现
│   └── ini/            # INI 配置文件解析
│
├── log (日志系统)
│   └── CoreLog.h/cpp   # 核心日志实现
│
├── utils (工具函数)
│   ├── FileUtil.h/cpp       # 文件操作
│   ├── StringUtil.h/cpp     # 字符串处理
│   ├── Encoder.h/cpp        # 编码工具
│   ├── JsonUtil.h/cpp       # JSON 处理
│   ├── FTPManagerUTF8.h/cpp # FTP 管理
│   └── IOS_Utils.h/mm      # iOS 工具
│
└── Singleton.hpp    # 单例模板
```

#### 3.2.3 核心类设计

##### Thread (线程)

**platform/thread.h (core 命名空间)**

```cpp
namespace core {
    class Thread {
    public:
        Thread();
        virtual ~Thread();
        
        virtual bool IsRunningNow();
        virtual void StopRunning();
        virtual void Start();
        virtual void Join();
        virtual void Run() = 0;
        
        static unsigned int m_iFireCounter;
        static unsigned int m_iLimitFires;
        
    private:
        static void* thread_start(void* arg);
        
#if (defined WIN7_32) || (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
        std::thread* thread;
#else
        pthread_t thread;
#endif
        volatile bool running;
    };
}
```

**aio 命名空间 (cauthc/authc/os/windows/thread.hpp)**

```cpp
namespace aio {
#if (defined WIN7_32) || (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
    class Thread {
    private:
        std::thread* m_pThread;
        volatile bool running;
        
    public:
        Thread();
        virtual ~Thread();
        virtual bool IsRunningNow();
        virtual void StopRunning();
        virtual void Start();
        virtual void Join();
        virtual void Run() = 0;
    };
#else
    class Thread {
    private:
        HANDLE thread;
        volatile bool running;
        
    public:
        Thread();
        virtual ~Thread();
        virtual bool IsRunningNow();
        virtual void StopRunning();
        virtual void Start();
        virtual void Join();
        virtual void Run() = 0;
    };
#endif
}
```

**职责**:
- 提供跨平台线程抽象
- 支持线程启动、停止、等待
- 支持线程运行状态查询

##### CMutex (互斥锁)

```cpp
namespace core {
    class CMutex {
#if (defined WIN7_32) || (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
        std::mutex mutex;
#else
        pthread_mutex_t mutex;
#endif
        
    public:
        CMutex();
        ~CMutex();
        
        void Lock();
        void UNLock();
        
        class Scoped {
            CMutex& mm;
        public:
            explicit Scoped(CMutex& m);
            explicit Scoped(CMutex* m);
            ~Scoped();
        };
    };
}
```

**职责**:
- 提供互斥锁保护共享资源
- 支持 RAII 风格的自动加锁/解锁
- 跨平台实现 (std::mutex / pthread_mutex_t)

##### Logger (日志系统)

```cpp
namespace core {
    enum LoggingLevel {
        Errors,         // 错误级别
        Warnings,       // 警告级别
        Standard,       // 标准级别
        Informative,    // 信息级别
        Insane          // 调试级别
    };
    
    class Logger : public CSingleton<Logger> {
    private:
        std::ofstream d_ostream;
        std::ostringstream d_workstream;
        LoggingLevel d_level;
        bool d_write2file;
        std::map<int, std::wstring> m_PassLevel;
        
    public:
        Logger();
        virtual ~Logger();
        
        void setLoggingLevel(LoggingLevel level);
        void setLogFilename(const std::string& filename, bool append);
        
        virtual void logEvent(LoggingLevel level, const wchar_t* format, ...);
        virtual void logLuaEvent(LoggingLevel level, std::wstring message);
        
        int AddPassLevel(int PassLevel, std::wstring PassLevelCaption);
        std::wstring FindPassLevel(int PassLevel);
        
        static void flurryEvent(std::wstring s, bool remarkFirst = false);
        static void flurryEvent(std::wstring s, std::wstring key, std::wstring value, bool remarkFirst = false);
        static void flurryError(std::wstring s, std::wstring key, std::wstring value, bool notRepeatSameError = true);
    };
}

// 日志宏定义
#define SDLOG_ERR(__FORMAT__, ...) core::Logger::GetInstance()->logEvent(core::Errors, __FORMAT__, ##__VA_ARGS__)
#define SDLOG_WARN(__FORMAT__, ...) core::Logger::GetInstance()->logEvent(core::Warnings, __FORMAT__, ##__VA_ARGS__)
#define SDLOG_STD(__FORMAT__, ...) core::Logger::GetInstance()->logEvent(core::Standard, __FORMAT__, ##__VA_ARGS__)
#define SDLOG_INFO(__FORMAT__, ...) core::Logger::GetInstance()->logEvent(core::Informative, __FORMAT__, ##__VA_ARGS__)
#define SDLOG_INSANE(__FORMAT__, ...) core::Logger::GetInstance()->logEvent(core::Insane, __FORMAT__, ##__VA_ARGS__)
```

**职责**:
- 提供多级别日志记录
- 支持日志文件输出
- 支持自定义日志级别过滤
- 支持宽字符日志
- 集成 Flurry 统计

##### IniFile (INI 配置文件)

```cpp
class IniFile {
public:
    static int read_profile_string(const char* section, const char* key, 
                                  char* value, int size, 
                                  const char* default_value, const char* file);
    static int read_profile_int(const char* section, const char* key, 
                               int default_value, const char* file);
    static int read_profile_float(const char* section, const char* key, 
                                 float default_value, const char* file);
    static int write_profile_string(const char* section, const char* key, 
                                   const char* value, const char* file);
    
    static std::string getCfgFilename();
};
```

**职责**:
- 解析 INI 格式配置文件
- 支持读取字符串、整数、浮点数
- 支持写入配置项

---

### 3.3 ljfm - Locojoy Fire Module

#### 3.3.1 模块职责

- 提供文件系统抽象
- 支持多种文件系统类型
- 提供文件操作接口
- 支持异步文件操作

#### 3.3.2 架构设计

```
ljfm 模块架构
│
├── 核心接口
│   ├── ljfm.h              # 主头文件
│   ├── ljfmbase.h/cpp      # 文件系统基类
│   ├── ljfmfs.h/cpp        # 文件系统实现
│   ├── ljfmfsmanager.h/cpp # 文件系统管理器
│   └── ljfileinfo.h/cpp    # 文件信息
│
├── 文件操作
│   ├── ljfmopen.h/cpp      # 文件打开
│   ├── ljfmbf.h           # 文件缓冲区
│   ├── ljfsfile.h/cpp      # 标准文件
│   └── ljfszipfile.h/cpp  # ZIP 文件
│
├── 扩展功能
│   ├── ljfmext.h/cpp      # 扩展功能
│   ├── ljfmasync.h/cpp     # 异步操作
│   ├── ljfmfex.h/cpp      # 文件扩展
│   └── ljfmimage.h/cpp    # 图像处理
│
├── 特殊格式
│   ├── ljfmpq.h/cpp       # PQ 格式
│   └── ljfmtableloader.h/cpp # 表格加载器
│
└── 工具
    ├── common.h/cpp        # 通用定义
    ├── timelog.h/cpp       # 时间日志
    └── util_android.h/cpp # Android 工具
```

#### 3.3.3 核心类设计

##### LJFMBase (文件系统基类)

```cpp
namespace LJFM {
    enum FS_TYPE {
        FS_TYPE_UNKNOWN,
        FS_TYPE_STANDARD,
        FS_TYPE_ZIP,
        FS_TYPE_PQ,
        // ...
    };
    
    class LJFMBase {
    private:
        typedef std::set<std::wstring> CRefMountFSSet;
        CRefMountFSSet m_rmfs;
        bool m_bMetaChanged;
        
    protected:
        std::wstring m_deviceName;
        LJFMBase* m_BaseLJFM;
        unsigned short m_usFilesMetaVersion;
        
    public:
        LJFMBase();
        LJFMBase(FS_TYPE type);
        virtual ~LJFMBase();
        
        virtual LJFMBase* Clone() const = 0;
        virtual void Delete();
        virtual int Initialize(const std::wstring& device) = 0;
        virtual FS_TYPE GetFSType() const = 0;
        virtual int OpenFile(const std::wstring& filename, FILE_MODE fm, 
                           FILE_ACCESS fa, LJFMBF*& file) = 0;
        virtual int RemoveFile(const std::wstring& filename) = 0;
        virtual int CreateDirectory(const std::wstring& path, 
                                  bool bFailIfExisting = false) = 0;
        virtual int RemoveDirectory(const std::wstring& path, 
                                  bool bFailIfNotEmpty = false) = 0;
        virtual bool IsDirectoryExisting(const std::wstring& path) = 0;
        virtual bool IsFSBusy() const = 0;
        virtual bool IsFileExisting(const std::wstring& filename) = 0;
        virtual void OnFileClose(LJFMBF* pFile);
        virtual void CheckMetaInfo() = 0;
        virtual bool Destroy();
        
        static LJFMBase* Create(FS_TYPE type);
    };
}
```

**职责**:
- 定义文件系统抽象接口
- 支持多种文件系统类型
- 提供文件和目录操作
- 支持元数据管理

---

### 3.4 updateengine - 热更新引擎

#### 3.4.1 模块职责

- 实现游戏客户端热更新功能
- 支持文件下载和校验
- 支持版本管理和差异更新
- 支持进度通知和错误处理

#### 3.4.2 架构设计

```
updateengine 模块架构
│
├── 核心引擎
│   ├── UpdateEngine.h/cpp           # 更新引擎主类
│   ├── UpdateManagerEx.h/cpp        # 更新管理器
│   ├── UpdateManagerEx_Win.h/cpp    # Windows 实现
│   ├── UpdateManagerEx_Helper.h     # 辅助类
│   └── UpdateCommon.h              # 公共定义
│
├── 文件下载
│   ├── FileDownloader.h             # 文件下载器接口
│   ├── AsyncFileDownloader.h        # 异步下载器
│   └── GlobalFunction.h            # 全局函数
│
├── 平台实现
│   ├── win32/                      # Windows 实现
│   │   ├── FileDownloader.cpp
│   │   ├── AsyncFileDownloader.h/cpp
│   │   └── GlobalFunction.cpp
│   ├── ios/                        # iOS 实现
│   │   ├── FileDownloader.mm
│   │   ├── GlobalFunction.mm
│   │   ├── GlobalNotification.h
│   │   ├── ProgressIndicator.h/mm
│   │   ├── ProgressNotify.h
│   │   └── ZipArchive/             # ZIP 解压
│   ├── android/                    # Android 实现
│   │   ├── FileDownloader.cpp
│   │   ├── AsyncFileDownloader.h/cpp
│   │   ├── GlobalFunction.cpp
│   │   ├── GlobalNotification.h/cpp
│   │   └── UpdateEngineJni.cpp
│   └── wp/                        # Windows Phone 实现
│       ├── FileDownloader.cpp
│       ├── AsyncFileDownloader.h/cpp
│       └── GlobalFunction.cpp
│
└── 通用实现
    └── GlobalFunction_Common.cpp    # 通用全局函数
```

#### 3.4.3 核心类设计

##### UpdateEngine (更新引擎)

```cpp
class UpdateEngine {
public:
    static void Initialize();
    static void Run();
    static void Continue();
    static void ContinueEx(int iResult);
    static void OnUpdateEnd(bool bRet, bool isFirstDownload = false);
    static void OnUpdateEnd2(bool bRet, bool isFirstDownload = false);
    static std::wstring GetWGAdress();
    
    // 版本信息
    static unsigned int g_uiVersionOld;
    static std::wstring g_wsVersionOldCaption;
    static unsigned int g_uiVersion;
    static std::wstring g_wsVersionCaption;
    static unsigned int g_uiVersionBase;
    static std::wstring g_wsVersionBaseCaption;
    static unsigned int g_uiChannel;
    static std::wstring g_wsChannelCaption;
    static std::map<std::wstring, std::wstring> g_ExtendMap;
    
    static unsigned int g_uiNoPack;
    static unsigned int g_uiVersionDonotCheck;
    static std::wstring g_WGAdressStr;
};
```

**职责**:
- 管理更新流程
- 维护版本信息
- 提供更新接口

##### UpdateManagerEx (更新管理器)

```cpp
class UpdateManagerEx : public CSingleton<UpdateManagerEx> {
public:
    std::wstring m_DownloadSite;
    std::wstring m_AppSite;
    int m_DownloadSiteIsBack;
    
    static void SetDownloadSite(std::wstring DownloadSite, std::wstring AppSite, 
                               std::wstring WGSite);
    std::wstring GetDownloadSite();
    
    std::wstring m_RootPath;
    std::wstring m_RootResPath;
    std::wstring m_CacheResPath;
    std::wstring m_CacheUpdatePath;
    
    std::wstring m_SystemType;
    std::wstring m_NetworkType;
    
    int m_FormResult;
    
    void* m_pVerRoot;
    void* m_pVerCache;
    void* m_pVerUpdate;
    
    void* m_pPIRoot;
    void* m_pPICache;
    void* m_pPIUpdate;
    
    void* m_pPIAdd;
    void* m_pPIMod;
    void* m_pPIDel;
    
    unsigned int m_VersionOld;
    std::wstring m_VersionOldCaption;
    unsigned int m_Version;
    std::wstring m_VersionCaption;
    unsigned int m_VersionBase;
    std::wstring m_VersionBaseCaption;
    unsigned int m_Channel;
    std::wstring m_ChannelCaption;
    
    std::map<std::wstring, std::wstring> m_ExtendMap;
    
    UpdateManagerEx();
    ~UpdateManagerEx();
    
    int DelOldResFile();
    
    int StepInit();
    int StepInitPath();
    int StepLoadVersion();
    int StepCheckVersion();
    int StepLoadPackInfo();
    int StepCheckPackInfo();
    int StepDownloadPackInfo();
    int StepUpdatePackInfo();
    int StepClearPackInfo();
    
    virtual bool Run();
    int StepLoadVersionNoPack();
    virtual bool RunNoPack();
    virtual void Continue(int iResult);
    
    void CloneExtendMap(std::map<std::wstring, std::wstring>& ExtendMap);
};
```

**职责**:
- 管理更新步骤
- 处理版本检查
- 管理文件下载
- 处理更新进度

##### FileDownloader (文件下载器)

```cpp
class FileDownloader {
public:
    static bool SynDownloadOneFile(const std::wstring& url, 
                                  const std::wstring& destfile, 
                                  bool notify = false);
};
```

**职责**:
- 提供同步文件下载接口
- 支持进度通知

##### AsyncFileDownloader (异步文件下载器)

```cpp
class AsyncFileDownloader {
public:
    void startDownload(const char* url, Callback* callback);
    void onDownloadProgress(int percent);
    void onDownloadComplete();
    void onDownloadError(int errorCode);
};
```

**职责**:
- 提供异步文件下载
- 支持进度回调
- 支持错误处理

#### 3.4.4 更新流程

```
更新流程
│
├── StepInit()              # 初始化
│   └── 设置下载站点、路径等
│
├── StepInitPath()          # 初始化路径
│   └── 创建必要的目录结构
│
├── StepLoadVersion()       # 加载版本信息
│   └── 读取本地版本文件
│
├── StepCheckVersion()      # 检查版本
│   └── 对比本地和服务器版本
│
├── StepLoadPackInfo()      # 加载包信息
│   └── 读取更新包列表
│
├── StepCheckPackInfo()     # 检查包信息
│   └── 验证包完整性
│
├── StepDownloadPackInfo()  # 下载包信息
│   └── 下载需要更新的文件
│
├── StepUpdatePackInfo()    # 更新包信息
│   └── 替换旧文件
│
└── StepClearPackInfo()     # 清理包信息
    └── 删除临时文件
```

---

### 3.5 lua - Lua 5.1 解释器

#### 3.5.1 模块职责

- 提供 Lua 5.1 解释器
- 提供 Lua C API
- 支持与 tolua++ 集成

#### 3.5.2 架构设计

```
lua 模块架构
│
├── Lua 核心
│   ├── lua.h              # Lua 核心接口
│   ├── lualib.h           # Lua 标准库
│   ├── lauxlib.h          # Lua 辅助库
│   └── luaconf.h          # Lua 配置
│
└── 平台适配
    ├── dllmain.cpp        # Windows DLL 入口
    └── pch.h             # 预编译头
```

#### 3.5.3 使用方式

```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

// 创建 Lua 虚拟机
lua_State* L = luaL_newstate();
luaL_openlibs(L);

// 执行 Lua 脚本
luaL_dofile(L, "script.lua");

// 调用 Lua 函数
lua_getglobal(L, "functionName");
lua_pushnumber(L, 42);
lua_pcall(L, 1, 1, 0);
int result = lua_tonumber(L, -1);
lua_pop(L, 1);

// 清理
lua_close(L);
```

---

### 3.6 tolua++ - C++/Lua 绑定工具

#### 3.6.1 模块职责

- 自动生成 C++ 到 Lua 的绑定代码
- 支持 C++ 类、函数、枚举导出
- 支持继承关系
- 支持类型转换

#### 3.6.2 架构设计

```
tolua++ 模块架构
│
├── 工具
│   ├── bin/
│   │   └── tolua++.exe    # Windows 可执行文件
│   └── src/bin/           # 工具源码
│
├── 运行时库
│   ├── include/
│   │   └── tolua++.h      # 运行时头文件
│   └── src/lib/           # 运行时库源码
│       ├── tolua_event.c/h
│       ├── tolua_is.c
│       ├── tolua_map.c
│       └── tolua_push.c
│
├── 测试
│   └── src/tests/         # 测试用例
│
└── 文档
    └── doc/               # 使用文档
```

#### 3.6.3 使用流程

```bash
# 1. 编写 .pkg 文件定义需要导出的 C++ 接口
# 2. 使用 tolua++ 生成绑定代码
tolua++ -o output.cpp input.pkg

# 3. 将生成的代码编译到项目中
# 4. 在 Lua 中调用 C++ 接口
```

#### 3.6.4 .pkg 文件示例

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

---

## 4. 模块依赖关系

### 4.1 依赖关系图

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

### 4.2 依赖关系表

| 模块 | 依赖项 | 说明 |
|-----|-------|------|
| **platform** | 无 | 最底层，仅依赖系统 API |
| **lua** | 无 | 独立的 Lua 解释器 |
| **tolua++** | lua | 需要 Lua 运行时 |
| **cauthc** | platform | 需要线程、锁等基础设施 |
| **ljfm** | platform, lua | 需要跨平台支持和脚本引擎 |
| **updateengine** | platform | 需要文件操作、线程支持 |

### 4.3 构建顺序

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

## 5. 数据流设计

### 5.1 网络通信数据流

```
客户端应用
    │
    │ 发送请求
    ▼
┌─────────────┐
│  Protocol   │  协议对象
└──────┬──────┘
       │ encode()
       ▼
┌─────────────┐
│  Octets    │  字节流
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ NetSession │  会话管理
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  StreamIO  │  流式 IO
└──────┬──────┘
       │ send()
       ▼
    网络
       │
       ▼
┌─────────────┐
│  StreamIO  │  流式 IO
└──────┬──────┘
       │ recv()
       ▼
┌─────────────┐
│ NetSession │  会话管理
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Octets    │  字节流
└──────┬──────┘
       │ decode()
       ▼
┌─────────────┐
│  Protocol   │  协议对象
└──────┬──────┘
       │ Process()
       ▼
    业务处理
```

### 5.2 热更新数据流

```
更新引擎启动
    │
    ▼
StepInit() - 初始化
    │
    ▼
StepLoadVersion() - 加载本地版本
    │
    ▼
StepCheckVersion() - 检查服务器版本
    │
    ├─ 版本相同 ────────► 结束
    │
    └─ 版本不同
         │
         ▼
    StepLoadPackInfo() - 加载包信息
         │
         ▼
    StepDownloadPackInfo() - 下载文件
         │
         ▼
    StepUpdatePackInfo() - 更新文件
         │
         ▼
    StepClearPackInfo() - 清理临时文件
         │
         ▼
      更新完成
```

---

## 6. 线程模型

### 6.1 cauthc 线程模型

```
主线程 (UI 线程)
    │
    │ 提交任务
    ▼
┌─────────────────┐
│   TaskQueue     │  任务队列
└────────┬────────┘
         │
         │ 调度任务
         ▼
┌─────────────────┐
│   IO Engine    │  IO 引擎线程
│   (Thread)     │
└────────┬────────┘
         │
         │ 处理网络事件
         ▼
┌─────────────────┐
│   PollIO       │  IO 多路复用
└────────┬────────┘
         │
         │ 回调
         ▼
┌─────────────────┐
│  NetSession    │  会话处理
└────────┬────────┘
         │
         │ 解析协议
         ▼
┌─────────────────┐
│   Protocol     │  协议处理
└────────┬────────┘
         │
         │ 回调到主线程
         ▼
    业务处理
```

### 6.2 platform 线程模型

```
主线程
    │
    │ 创建工作线程
    ▼
┌─────────────────┐
│    Thread      │  工作线程
└────────┬────────┘
         │
         │ 使用互斥锁保护共享资源
         ▼
┌─────────────────┐
│    CMutex      │  互斥锁
└─────────────────┘
```

---

## 7. 内存管理

### 7.1 Octets 内存管理

```cpp
class Octets_Rep {
    size_t mCap;           // 容量
    size_t mLen;           // 长度
    volatile size_t mRef;   // 引用计数
    
    void addref();         // 增加引用
    void release();        // 释放引用
    void* clone();         // 克隆数据
    void* unique();        // 确保唯一
    void* reserve(size_t); // 预留空间
};
```

**特性**:
- 引用计数管理
- 写时复制 (Copy-on-Write)
- 自动内存回收

### 7.2 内存分配策略

- **小对象**: 使用栈分配
- **大对象**: 使用堆分配
- **共享数据**: 使用引用计数
- **临时对象**: 使用对象池

---

## 8. 错误处理

### 8.1 异常层次

```
std::exception
    │
    ▼
FireNet::Marshal::Exception
    │
    ├─ 序列化/反序列化错误
    ├─ 数据格式错误
    └─ 协议解析错误
```

### 8.2 错误码定义

| 错误码 | 含义 |
|-------|------|
| **0** | 成功 |
| **-1** | 未知错误 |
| **-2** | 网络错误 |
| **-3** | 超时 |
| **-4** | 协议错误 |
| **-5** | 文件不存在 |
| **-6** | 权限不足 |
| **-7** | 内存不足 |

---

## 9. 性能优化

### 9.1 网络优化

- **异步 IO**: 避免阻塞主线程
- **连接池**: 复用连接减少开销
- **协议压缩**: 减少网络传输量
- **批量发送**: 合并多个小包

### 9.2 内存优化

- **引用计数**: 减少数据拷贝
- **对象池**: 减少内存分配
- **内存预分配**: 避免频繁分配
- **紧凑编码**: 节省存储空间

### 9.3 线程优化

- **线程池**: 复用线程资源
- **任务队列**: 平衡负载
- **锁粒度**: 减少锁竞争
- **无锁算法**: 提升并发性能

---

## 10. 安全设计

### 10.1 网络安全

- **加密传输**: 使用 Security 模块加密数据
- **密钥交换**: KeyExchange 协议协商密钥
- **挑战应答**: Challenge 协议验证身份
- **防重放**: 时间戳和随机数

### 10.2 数据安全

- **数据校验**: MD5 校验文件完整性
- **签名验证**: 验证更新包签名
- **权限控制**: 文件访问权限检查

---

## 11. 扩展性设计

### 11.1 协议扩展

```cpp
// 定义新协议
class NewProtocol : public aio::Protocol {
public:
    static const ProtocolType PROTOCOL_TYPE = 0x100;
    
    virtual void Process(Manager*, Manager::Session::ID);
    virtual Protocol* Clone() const;
    
    // 序列化/反序列化
    virtual OctetsStream& marshal(OctetsStream&) const;
    virtual const OctetsStream& unmarshal(const OctetsStream&);
};

// 注册协议
static aio::Protocol::TStub<NewProtocol> stub;
```

### 11.2 文件系统扩展

```cpp
// 实现新文件系统
class NewFileSystem : public LJFM::LJFMBase {
public:
    virtual LJFMBase* Clone() const;
    virtual int Initialize(const std::wstring& device);
    virtual FS_TYPE GetFSType() const;
    virtual int OpenFile(const std::wstring& filename, FILE_MODE fm, 
                       FILE_ACCESS fa, LJFMBF*& file);
    // ...
};
```

---

## 12. 平台适配

### 12.1 Windows 平台

- **编译器**: Visual Studio 2013
- **平台工具集**: v120
- **字符集**: Unicode
- **运行时**: Visual C++ Redistributable 2013

### 12.2 iOS 平台

- **编译器**: Clang (Xcode)
- **最低版本**: iOS 7.0
- **架构**: armv7, arm64
- **运行时**: Objective-C++

### 12.3 Android 平台

- **编译器**: NDK r8+
- **最低版本**: API Level 14 (Android 4.0)
- **架构**: armeabi-v7a, arm64-v8a
- **运行时**: JNI

### 12.4 Windows Phone 8 平台

- **编译器**: Visual Studio 2012
- **平台工具集**: v110_wp80
- **架构**: ARM, Win32
- **运行时**: WinRT

---

## 13. 构建系统

### 13.1 Windows 构建

**项目文件**: `.vcxproj`

**配置**:
- Debug/Release
- Win32/x64

**输出目录**:
```
$(SolutionDir)$(Configuration).win32\
```

### 13.2 iOS 构建

**项目文件**: `.xcodeproj`

**配置**:
- Debug/Release
- Device/Simulator

**输出目录**:
```
DerivedData/.../Build/Products/
```

### 13.3 Android 构建

**构建文件**: `Android.mk`

**配置**:
- APP_ABI: armeabi-v7a, arm64-v8a
- APP_PLATFORM: android-14

**输出目录**:
```
obj/local/$(APP_ABI)/
```

---

## 14. 测试策略

### 14.1 单元测试

- **测试框架**: 自定义测试框架
- **测试覆盖**: 核心模块
- **测试频率**: 每次构建

### 14.2 集成测试

- **测试场景**: 完整业务流程
- **测试环境**: 多平台
- **测试频率**: 每次发布

### 14.3 性能测试

- **测试工具**: 自定义性能测试
- **测试指标**: 吞吐量、延迟、内存
- **测试频率**: 每周

---

## 15. 版本管理

### 15.1 版本号规范

```
主版本号.次版本号.修订号.构建号
```

### 15.2 兼容性

- **向后兼容**: 保持 API 兼容
- **弃用策略**: 提前通知
- **迁移指南**: 提供文档

---

## 16. 文档规范

### 16.1 代码注释

- **文件头注释**: 说明文件用途
- **类注释**: 说明类职责
- **函数注释**: 说明函数功能、参数、返回值
- **复杂逻辑**: 添加详细注释

### 16.2 API 文档

- **接口说明**: 功能描述
- **参数说明**: 类型、含义、约束
- **返回值说明**: 类型、含义、错误码
- **使用示例**: 代码示例

---

## 17. 附录

### 17.1 术语表

| 术语 | 英文 | 说明 |
|-----|------|------|
| **RPC** | Remote Procedure Call | 远程过程调用 |
| **IO** | Input/Output | 输入输出 |
| **JNI** | Java Native Interface | Java 本地接口 |
| **NDK** | Native Development Kit | 原生开发工具包 |
| **SDK** | Software Development Kit | 软件开发工具包 |
| **API** | Application Programming Interface | 应用程序编程接口 |

### 17.2 参考资料

- [Lua 5.1 参考手册](https://www.lua.org/manual/5.1/)
- [tolua++ 文档](http://www.codenix.com/~tolua/)
- [C++11 标准](https://en.cppreference.com/w/cpp/11)
- [POSIX 线程编程](https://computing.llnl.gov/tutorials/pthreads/)

---

**文档结束**

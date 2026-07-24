# 02-API接口文档 API Reference Document

## 文档信息

| 项目 | 内容 |
|-----|------|
| **文档名称** | MT3 Common 公共库 API 接口文档 |
| **文档版本** | v1.0 |
| **创建日期** | 2026-01-27 |
| **最后更新** | 2026-01-27 |
| **适用项目** | MT3 Common 公共库模块 |

---

## 目录

- [1. cauthc 模块 API](#1-cauthc-模块-api)
  - [1.1 aio 命名空间](#11-aio-命名空间)
  - [1.2 FireNet 命名空间](#12-firenet-命名空间)
  - [1.3 网络协议 API](#13-网络协议-api)
- [2. platform 模块 API](#2-platform-模块-api)
  - [2.1 core 命名空间](#21-core-命名空间)
  - [2.2 日志系统 API](#22-日志系统-api)
  - [2.3 配置文件 API](#23-配置文件-api)
  - [2.4 工具函数 API](#24-工具函数-api)
- [3. ljfm 模块 API](#3-ljfm-模块-api)
- [4. updateengine 模块 API](#4-updateengine-模块-api)
- [5. lua 模块 API](#5-lua-模块-api)
- [6. tolua++ 模块 API](#6-tolua-模块-api)

---

## 1. cauthc 模块 API

### 1.1 aio 命名空间

#### 1.1.1 Runnable - 可运行任务接口

**文件位置**: [cauthc/authc/ioengine.h](file:///e:/MT3/common/cauthc/authc/ioengine.h)

**类定义**:
```cpp
namespace aio {
    class Runnable {
    public:
        virtual void run();
        virtual void destroy();
        
        inline void runAndDestroy() {
            run();
            destroy();
        }
        
    protected:
        virtual ~Runnable();
    };
}
```

**方法说明**:

| 方法 | 类型 | 说明 |
|-----|------|------|
| `run()` | virtual void | 执行任务，由子类实现 |
| `destroy()` | virtual void | 销毁任务对象，默认 delete this |
| `runAndDestroy()` | inline void | 执行任务后销毁对象 |

**使用示例**:
```cpp
class MyTask : public aio::Runnable {
public:
    virtual void run() override {
        SDLOG_INFO(L"Task running...");
    }
};

aio::TaskQueue& queue = aio::Engine::getInstance();
queue.addTask(new MyTask());
```

---

#### 1.1.2 TaskQueue - 任务队列

**文件位置**: [cauthc/authc/ioengine.h](file:///e:/MT3/common/cauthc/authc/ioengine.h)

**类定义**:
```cpp
namespace aio {
    class TaskQueue {
    public:
        TaskQueue();
        ~TaskQueue();
        
        inline void addTask(Runnable* task);
        inline void addTask(Runnable& task);
        
        void runTasks();
        void clear();
    };
}
```

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `addTask()` | `Runnable* task` | void | 添加任务到队列 |
| `addTask()` | `Runnable& task` | void | 添加任务到队列（引用） |
| `runTasks()` | 无 | void | 执行队列中的所有任务 |
| `clear()` | 无 | void | 清空任务队列 |

**使用示例**:
```cpp
aio::TaskQueue queue;

queue.addTask(new MyTask());
queue.addTask(*anotherTask);

queue.runTasks();

queue.clear();
```

---

#### 1.1.3 Engine - IO 引擎

**文件位置**: [cauthc/authc/ioengine.h](file:///e:/MT3/common/cauthc/authc/ioengine.h)

**类定义**:
```cpp
namespace aio {
    class Engine : public Thread {
    public:
        static Engine& getInstance();
        
        bool Startup();
        void Cleanup();
        void Connect(const FireNet::Connector& c);
        
        virtual void Run();
        
    private:
        Engine();
        ~Engine();
    };
}
```

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `getInstance()` | 无 | `Engine&` | 获取引擎单例 |
| `Startup()` | 无 | `bool` | 启动引擎 |
| `Cleanup()` | 无 | `void` | 清理引擎资源 |
| `Connect()` | `const Connector& c` | `void` | 连接到服务器 |
| `Run()` | 无 | `void` | 运行事件循环 |

**使用示例**:
```cpp
aio::Engine& engine = aio::Engine::getInstance();

if (engine.Startup()) {
    FireNet::Connector conn;
    conn.host = "127.0.0.1";
    conn.port = "8000";
    engine.Connect(conn);
}
```

---

#### 1.1.4 Protocol - 协议基类

**文件位置**: [cauthc/include/protocol.h](file:///e:/MT3/common/cauthc/include/protocol.h)

**类定义**:
```cpp
namespace aio {
    class Protocol : public FireNet::Marshal {
    public:
        typedef FireNet::ProtocolType Type;
        
    protected:
        Protocol();
        explicit Protocol(Type t);
        
    public:
        virtual ~Protocol();
        
        FireNet::Octets encode() const;
        Type getType() const;
        
        virtual int PriorPolicy() const;
        virtual int WaitingProtocol() const;
        virtual bool SizePolicy(size_t) const;
        
        virtual void Dispatch(Manager::Session::ID mSID, Manager * manager);
        virtual void Process(Manager*, Manager::Session::ID) = 0;
        virtual Protocol* Clone() const = 0;
        
        static Protocol* Create(Type type);
        static void AddStub(Stub * stub);
        static void DelStub(Type type);
        static void DelStub(Stub * stub);
        
        struct Stub {
            Type type;
            virtual Protocol* create() = 0;
        };
        
        template <typename T>
        struct TStub : public Stub {
            TStub();
            virtual Protocol* create();
        };
    };
}
```

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `encode()` | 无 | `Octets` | 编码协议为字节流 |
| `getType()` | 无 | `Type` | 获取协议类型 |
| `PriorPolicy()` | 无 | `int` | 优先级策略 |
| `WaitingProtocol()` | 无 | `int` | 等待的协议类型 |
| `SizePolicy()` | `size_t` | `bool` | 大小策略 |
| `Dispatch()` | `Session::ID, Manager*` | `void` | 分发协议 |
| `Process()` | `Manager*, Session::ID` | `void` | 处理协议（纯虚函数） |
| `Clone()` | 无 | `Protocol*` | 克隆协议（纯虚函数） |
| `Create()` | `Type type` | `Protocol*` | 创建协议实例 |
| `AddStub()` | `Stub* stub` | `void` | 注册协议存根 |
| `DelStub()` | `Type type` | `void` | 删除协议存根 |
| `DelStub()` | `Stub* stub` | `void` | 删除协议存根 |

**使用示例**:
```cpp
class MyProtocol : public aio::Protocol {
public:
    static const ProtocolType PROTOCOL_TYPE = 0x100;
    
    MyProtocol() : Protocol(PROTOCOL_TYPE) {}
    
    virtual void Process(Manager* mgr, Manager::Session::ID sid) override {
        SDLOG_INFO(L"Processing protocol...");
    }
    
    virtual Protocol* Clone() const override {
        return new MyProtocol(*this);
    }
};

static aio::Protocol::TStub<MyProtocol> stub;

aio::Protocol* proto = aio::Protocol::Create(MyProtocol::PROTOCOL_TYPE);
```

---

### 1.2 FireNet 命名空间

#### 1.2.1 Octets - 字节流容器

**文件位置**: [cauthc/include/octets.h](file:///e:/MT3/common/cauthc/include/octets.h)

**类定义**:
```cpp
namespace FireNet {
    class Octets {
    public:
        Octets& reserve(size_t size);
        Octets& replace(const void *data, size_t size);
        
        virtual ~Octets();
        
        Octets();
        Octets(size_t size);
        Octets(const void *x, size_t size);
        Octets(const void *x, const void *y);
        Octets(const Octets &x);
        
        Octets& operator = (const Octets&x);
        bool operator == (const Octets &x) const;
        bool operator != (const Octets &x) const;
        
        Octets& swap(Octets &x);
        
        void *begin();
        void *end();
        const void *begin() const;
        const void *end() const;
        
        size_t size() const;
        size_t capacity() const;
        Octets& clear();
        Octets& erase(size_t pos, size_t len);
        Octets& erase(void *x, void *y);
        
        Octets& insert(void *pos, const void *x, size_t len);
        Octets& insert(void *pos, const void *x, const void *y);
        Octets& resize(size_t size);
        
        void dump() const;
    };
}
```

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `reserve()` | `size_t size` | `Octets&` | 预留容量 |
| `replace()` | `const void*, size_t` | `Octets&` | 替换内容 |
| `Octets()` | 无 | - | 默认构造函数 |
| `Octets()` | `size_t size` | - | 指定大小构造 |
| `Octets()` | `const void*, size_t` | - | 从数据构造 |
| `Octets()` | `const void*, const void*` | - | 从范围构造 |
| `Octets()` | `const Octets&` | - | 拷贝构造函数 |
| `operator=` | `const Octets&` | `Octets&` | 赋值运算符 |
| `operator==` | `const Octets&` | `bool` | 相等比较 |
| `operator!=` | `const Octets&` | `bool` | 不等比较 |
| `swap()` | `Octets&` | `Octets&` | 交换内容 |
| `begin()` | 无 | `void*` | 获取起始指针 |
| `end()` | 无 | `void*` | 获取结束指针 |
| `begin()` | 无 | `const void*` | 获取起始指针（常量） |
| `end()` | 无 | `const void*` | 获取结束指针（常量） |
| `size()` | 无 | `size_t` | 获取大小 |
| `capacity()` | 无 | `size_t` | 获取容量 |
| `clear()` | 无 | `Octets&` | 清空内容 |
| `erase()` | `size_t, size_t` | `Octets&` | 删除指定位置 |
| `erase()` | `void*, void*` | `Octets&` | 删除指定范围 |
| `insert()` | `void*, const void*, size_t` | `Octets&` | 插入数据 |
| `insert()` | `void*, const void*, const void*` | `Octets&` | 插入范围 |
| `resize()` | `size_t` | `Octets&` | 调整大小 |
| `dump()` | 无 | `void` | 打印内容 |

**使用示例**:
```cpp
FireNet::Octets data1;
FireNet::Octets data2(100);

const char* str = "Hello";
FireNet::Octets data3(str, strlen(str));

data3.replace("World", 5);

size_t size = data3.size();
size_t cap = data3.capacity();

data3.clear();

data3.insert(data3.end(), "Test", 4);

data3.resize(200);

data3.dump();
```

---

#### 1.2.2 Mutex - 互斥锁

**文件位置**: [cauthc/authc/os/windows/mutex.hpp](file:///e:/MT3/common/cauthc/authc/os/windows/mutex.hpp)

**类定义**:
```cpp
namespace FireNet {
    class Mutex {
    public:
        Mutex();
        ~Mutex();
        
        bool CheckValid();
        void Lock();
        void UNLock();
        
        class Scoped {
        public:
            explicit Scoped(Mutex& mMember);
            explicit Scoped(Mutex* mMember);
            ~Scoped();
        };
    };
    
    class AtomicLong {
    public:
        AtomicLong(long x = 0);
        
        long get() const;
        long set(long x);
        
        long incrementAndGet();
        long decrementAndGet();
        long getAndAdd(long x);
        
        long exchange(long x);
        long exchangeIfEqual(long x, long comparand);
    };
}
```

**Mutex 方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `Mutex()` | 无 | - | 构造函数 |
| `~Mutex()` | 无 | - | 析构函数 |
| `CheckValid()` | 无 | `bool` | 检查互斥锁是否有效 |
| `Lock()` | 无 | `void` | 加锁 |
| `UNLock()` | 无 | `void` | 解锁 |

**AtomicLong 方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `AtomicLong()` | `long x` | - | 构造函数 |
| `get()` | 无 | `long` | 获取值 |
| `set()` | `long x` | `long` | 设置值 |
| `incrementAndGet()` | 无 | `long` | 原子递增并返回新值 |
| `decrementAndGet()` | 无 | `long` | 原子递减并返回新值 |
| `getAndAdd()` | `long x` | `long` | 原子加并返回旧值 |
| `exchange()` | `long x` | `long` | 原子交换 |
| `exchangeIfEqual()` | `long x, long comparand` | `long` | 条件原子交换 |

**使用示例**:
```cpp
FireNet::Mutex mutex;
int counter = 0;

mutex.Lock();
counter++;
mutex.UNLock();

{
    FireNet::Mutex::Scoped lock(mutex);
    counter++;
}

FireNet::AtomicLong atomicCounter(0);
long newValue = atomicCounter.incrementAndGet();
long oldValue = atomicCounter.getAndAdd(10);
```

---

### 1.3 网络协议 API

#### 1.3.1 KeyExchange - 密钥交换协议

**文件位置**: [cauthc/authc/gnet/KeyExchange.hpp](file:///e:/MT3/common/cauthc/authc/gnet/KeyExchange.hpp)

**命名空间**: `gnet`

**类定义**:
```cpp
namespace gnet {
    class KeyExchange : public aio::Protocol {
    public:
        #include "rpcgen/gnet/KeyExchange.inc"
        
        virtual void Process(Manager *, Manager::Session::ID);
    };
}
```

**功能**: 客户端与服务器之间的密钥协商

**使用示例**:
```cpp
gnet::KeyExchange keyExchange;
manager.Send(sid, keyExchange);
```

---

#### 1.3.2 Challenge - 挑战应答协议

**文件位置**: [cauthc/authc/gnet/Challenge.hpp](file:///e:/MT3/common/cauthc/authc/gnet/Challenge.hpp)

**命名空间**: `gnet`

**类定义**:
```cpp
namespace gnet {
    class Challenge : public aio::Protocol {
    public:
        #include "rpcgen/gnet/Challenge.inc"
        
        virtual void Process(Manager *, Manager::Session::ID);
    };
}
```

**功能**: 认证过程中的挑战-应答机制

**使用示例**:
```cpp
gnet::Challenge challenge;
manager.Send(sid, challenge);
```

---

#### 1.3.3 KeepAlive - 心跳保活协议

**文件位置**: [cauthc/authc/gnet/KeepAlive.hpp](file:///e:/MT3/common/cauthc/authc/gnet/KeepAlive.hpp)

**命名空间**: `gnet`

**类定义**:
```cpp
namespace gnet {
    class KeepAlive : public aio::Protocol {
    public:
        #include "rpcgen/gnet/KeepAlive.inc"
        
        virtual void Process(Manager *, Manager::Session::ID);
    };
}
```

**功能**: 维持连接活跃状态

**使用示例**:
```cpp
gnet::KeepAlive keepAlive;
manager.Send(sid, keepAlive);
```

---

#### 1.3.4 Response - 响应协议

**文件位置**: [cauthc/authc/gnet/Response.hpp](file:///e:/MT3/common/cauthc/authc/gnet/Response.hpp)

**命名空间**: `gnet`

**类定义**:
```cpp
namespace gnet {
    class Response : public aio::Protocol {
    public:
        #include "rpcgen/gnet/Response.inc"
        
        virtual void Process(Manager *, Manager::Session::ID);
    };
}
```

**功能**: 通用响应协议

**使用示例**:
```cpp
gnet::Response response;
manager.Send(sid, response);
```

---

#### 1.3.5 SSOGetTicketReq - SSO 请求协议

**文件位置**: [cauthc/authc/gnet/SSOGetTicketReq.hpp](file:///e:/MT3/common/cauthc/authc/gnet/SSOGetTicketReq.hpp)

**命名空间**: `gnet`

**类定义**:
```cpp
namespace gnet {
    class SSOGetTicketReq : public aio::Protocol {
    public:
        #include "rpcgen/gnet/SSOGetTicketReq.inc"
        
        virtual void Process(Manager *, Manager::Session::ID);
    };
}
```

**功能**: 单点登录票据请求

**使用示例**:
```cpp
gnet::SSOGetTicketReq req;
manager.Send(sid, req);
```

---

#### 1.3.6 SSOGetTicketRep - SSO 响应协议

**文件位置**: [cauthc/authc/gnet/SSOGetTicketRep.hpp](file:///e:/MT3/common/cauthc/authc/gnet/SSOGetTicketRep.hpp)

**命名空间**: `gnet`

**类定义**:
```cpp
namespace gnet {
    class SSOGetTicketRep : public aio::Protocol {
    public:
        #include "rpcgen/gnet/SSOGetTicketRep.inc"
        
        virtual void Process(Manager *, Manager::Session::ID);
    };
}
```

**功能**: 单点登录票据响应

**使用示例**:
```cpp
gnet::SSOGetTicketRep rep;
```

---

## 2. platform 模块 API

### 2.1 core 命名空间

#### 2.1.1 Thread - 线程

**文件位置**: [platform/platform/thread.h](file:///e:/MT3/common/platform/platform/thread.h)

**类定义**:
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
    };
}
```

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `Thread()` | 无 | - | 构造函数 |
| `~Thread()` | 无 | - | 析构函数 |
| `IsRunningNow()` | 无 | `bool` | 检查线程是否正在运行 |
| `StopRunning()` | 无 | `void` | 停止线程运行 |
| `Start()` | 无 | `void` | 启动线程 |
| `Join()` | 无 | `void` | 等待线程结束 |
| `Run()` | 无 | `void` | 线程执行函数（纯虚函数） |

**使用示例**:
```cpp
class WorkerThread : public core::Thread {
public:
    virtual void Run() override {
        while (IsRunningNow()) {
            SDLOG_INFO(L"Worker running...");
        }
    }
};

WorkerThread worker;
worker.Start();

worker.StopRunning();
worker.Join();
```

---

#### 2.1.2 CMutex - 互斥锁

**文件位置**: [platform/platform/mutex.h](file:///e:/MT3/common/platform/platform/mutex.h)

**类定义**:
```cpp
namespace core {
    class CMutex {
    public:
        CMutex();
        ~CMutex();
        
        void Lock();
        void UNLock();
        
        class Scoped {
        public:
            explicit Scoped(CMutex& m);
            explicit Scoped(CMutex* m);
            ~Scoped();
        };
    };
}
```

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `CMutex()` | 无 | - | 构造函数 |
| `~CMutex()` | 无 | - | 析构函数 |
| `Lock()` | 无 | `void` | 加锁 |
| `UNLock()` | 无 | `void` | 解锁 |

**CMutex::Scoped 方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `Scoped()` | `CMutex&` | - | 构造函数（引用） |
| `Scoped()` | `CMutex*` | - | 构造函数（指针） |
| `~Scoped()` | 无 | - | 析构函数（自动解锁） |

**使用示例**:
```cpp
core::CMutex mutex;
int counter = 0;

mutex.Lock();
counter++;
mutex.UNLock();

{
    core::CMutex::Scoped lock(mutex);
    counter++;
}
```

---

### 2.2 日志系统 API

#### 2.2.1 Logger - 日志记录器

**文件位置**: [platform/log/CoreLog.h](file:///e:/MT3/common/platform/log/CoreLog.h)

**类定义**:
```cpp
namespace core {
    enum LoggingLevel {
        Errors,         
        Warnings,       
        Standard,       
        Informative,    
        Insane          
    };
    
    class Logger : public CSingleton<Logger> {
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
        static void flurryEvent(std::wstring s, std::wstring key, 
                               std::wstring value, bool remarkFirst = false);
        static void flurryError(std::wstring s, std::wstring key, 
                               std::wstring value, bool notRepeatSameError = true);
    };
}
```

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `setLoggingLevel()` | `LoggingLevel level` | `void` | 设置日志级别 |
| `setLogFilename()` | `const string&, bool` | `void` | 设置日志文件名 |
| `logEvent()` | `LoggingLevel, const wchar_t*, ...` | `void` | 记录日志事件 |
| `logLuaEvent()` | `LoggingLevel, wstring` | `void` | 记录 Lua 日志事件 |
| `AddPassLevel()` | `int, wstring` | `int` | 添加通过级别 |
| `FindPassLevel()` | `int` | `wstring` | 查找通过级别 |
| `flurryEvent()` | `wstring, bool` | `void` | Flurry 事件统计 |
| `flurryEvent()` | `wstring, wstring, wstring, bool` | `void` | Flurry 事件统计（带参数） |
| `flurryError()` | `wstring, wstring, wstring, bool` | `void` | Flurry 错误统计 |

**日志宏定义**:

| 宏 | 说明 |
|-----|------|
| `SDLOG_ERR(__FORMAT__, ...)` | 记录错误级别日志 |
| `SDLOG_WARN(__FORMAT__, ...)` | 记录警告级别日志 |
| `SDLOG_STD(__FORMAT__, ...)` | 记录标准级别日志 |
| `SDLOG_INFO(__FORMAT__, ...)` | 记录信息级别日志 |
| `SDLOG_INSANE(__FORMAT__, ...)` | 记录调试级别日志 |

**使用示例**:
```cpp
core::Logger::GetInstance()->setLoggingLevel(core::Informative);
core::Logger::GetInstance()->setLogFilename("game.log", false);

SDLOG_ERR(L"Error occurred: %s", L"timeout");
SDLOG_WARN(L"Warning: %d", 42);
SDLOG_STD(L"Standard message");
SDLOG_INFO(L"Info: %s", L"connected");
SDLOG_INSANE(L"Debug: x=%d, y=%d", 100, 200);

core::Logger::GetInstance()->logEvent(core::Errors, L"Error: %s", L"critical");

core::Logger::flurryEvent(L"level_up");
core::Logger::flurryEvent(L"purchase", L"item", L"sword");
core::Logger::flurryError(L"network_error", L"code", L"404");
```

---

### 2.3 配置文件 API

#### 2.3.1 IniFile - INI 配置文件

**文件位置**: [platform/ini/IniFile.h](file:///e:/MT3/common/platform/ini/IniFile.h)

**类定义**:
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

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `read_profile_string()` | `section, key, value, size, default_value, file` | `int` | 读取字符串配置 |
| `read_profile_int()` | `section, key, default_value, file` | `int` | 读取整数配置 |
| `read_profile_float()` | `section, key, default_value, file` | `int` | 读取浮点数配置 |
| `write_profile_string()` | `section, key, value, file` | `int` | 写入字符串配置 |
| `getCfgFilename()` | 无 | `string` | 获取配置文件名 |

**使用示例**:
```cpp
char server[256];
IniFile::read_profile_string("Network", "Server", server, sizeof(server), 
                             "127.0.0.1", "config.ini");

int port = IniFile::read_profile_int("Network", "Port", 8000, "config.ini");

float version = IniFile::read_profile_float("App", "Version", 1.0f, "config.ini");

IniFile::write_profile_string("Network", "Server", "192.168.1.1", "config.ini");

std::string cfgFile = IniFile::getCfgFilename();
```

---

## 3. ljfm 模块 API

### 3.1 LJFMBase - 文件系统基类

**文件位置**: [ljfm/code/include/ljfmbase.h](file:///e:/MT3/common/ljfm/code/include/ljfmbase.h)

**命名空间**: `LJFM`

**类定义**:
```cpp
namespace LJFM {
    enum FS_TYPE {
        FS_TYPE_UNKNOWN,
        FS_TYPE_STANDARD,
        FS_TYPE_ZIP,
        FS_TYPE_PQ,
    };
    
    class LJFMBase {
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

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `LJFMBase()` | 无 | - | 默认构造函数 |
| `LJFMBase()` | `FS_TYPE type` | - | 指定类型构造函数 |
| `~LJFMBase()` | 无 | - | 析构函数 |
| `Clone()` | 无 | `LJFMBase*` | 克隆文件系统（纯虚函数） |
| `Delete()` | 无 | `void` | 删除文件系统 |
| `Initialize()` | `const wstring& device` | `int` | 初始化文件系统（纯虚函数） |
| `GetFSType()` | 无 | `FS_TYPE` | 获取文件系统类型（纯虚函数） |
| `OpenFile()` | `wstring, FILE_MODE, FILE_ACCESS, LJFMBF*&` | `int` | 打开文件（纯虚函数） |
| `RemoveFile()` | `const wstring& filename` | `int` | 删除文件（纯虚函数） |
| `CreateDirectory()` | `const wstring& path, bool` | `int` | 创建目录（纯虚函数） |
| `RemoveDirectory()` | `const wstring& path, bool` | `int` | 删除目录（纯虚函数） |
| `IsDirectoryExisting()` | `const wstring& path` | `bool` | 检查目录是否存在（纯虚函数） |
| `IsFSBusy()` | 无 | `bool` | 检查文件系统是否忙碌（纯虚函数） |
| `IsFileExisting()` | `const wstring& filename` | `bool` | 检查文件是否存在（纯虚函数） |
| `OnFileClose()` | `LJFMBF* pFile` | `void` | 文件关闭回调 |
| `CheckMetaInfo()` | 无 | `void` | 检查元数据（纯虚函数） |
| `Destroy()` | 无 | `bool` | 销毁文件系统 |
| `Create()` | `FS_TYPE type` | `LJFMBase*` | 创建文件系统实例 |

**使用示例**:
```cpp
LJFM::LJFMBase* fs = LJFM::LJFMBase::Create(LJFM::FS_TYPE_STANDARD);

fs->Initialize(L"C:\\GameData");

LJFM::LJFMBF* file;
int ret = fs->OpenFile(L"data.txt", FILE_MODE_READ, FILE_ACCESS_READ, file);

bool exists = fs->IsFileExisting(L"data.txt");

fs->CreateDirectory(L"backup", false);

fs->RemoveFile(L"old_data.txt");

fs->Destroy();
```

---

## 4. updateengine 模块 API

### 4.1 UpdateEngine - 更新引擎

**文件位置**: [updateengine/UpdateEngine.h](file:///e:/MT3/common/updateengine/UpdateEngine.h)

**类定义**:
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

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `Initialize()` | 无 | `void` | 初始化更新引擎 |
| `Run()` | 无 | `void` | 运行更新流程 |
| `Continue()` | 无 | `void` | 继续更新 |
| `ContinueEx()` | `int iResult` | `void` | 继续更新（带结果） |
| `OnUpdateEnd()` | `bool, bool` | `void` | 更新结束回调 |
| `OnUpdateEnd2()` | `bool, bool` | `void` | 更新结束回调2 |
| `GetWGAdress()` | 无 | `wstring` | 获取 WG 地址 |

**静态成员说明**:

| 成员 | 类型 | 说明 |
|-----|------|------|
| `g_uiVersionOld` | `unsigned int` | 旧版本号 |
| `g_wsVersionOldCaption` | `wstring` | 旧版本标题 |
| `g_uiVersion` | `unsigned int` | 当前版本号 |
| `g_wsVersionCaption` | `wstring` | 当前版本标题 |
| `g_uiVersionBase` | `unsigned int` | 基础版本号 |
| `g_wsVersionBaseCaption` | `wstring` | 基础版本标题 |
| `g_uiChannel` | `unsigned int` | 渠道号 |
| `g_wsChannelCaption` | `wstring` | 渠道标题 |
| `g_ExtendMap` | `map<wstring, wstring>` | 扩展信息映射 |
| `g_uiNoPack` | `unsigned int` | 无包标志 |
| `g_uiVersionDonotCheck` | `unsigned int` | 不检查版本标志 |
| `g_WGAdressStr` | `wstring` | WG 地址字符串 |

**使用示例**:
```cpp
UpdateEngine::Initialize();

UpdateEngine::Run();

unsigned int version = UpdateEngine::g_uiVersion;
std::wstring caption = UpdateEngine::g_wsVersionCaption;

std::wstring wgAddr = UpdateEngine::GetWGAdress();
```

---

### 4.2 UpdateManagerEx - 更新管理器

**文件位置**: [updateengine/UpdateManagerEx.h](file:///e:/MT3/common/updateengine/UpdateManagerEx.h)

**类定义**:
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

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `SetDownloadSite()` | `wstring, wstring, wstring` | `void` | 设置下载站点 |
| `GetDownloadSite()` | 无 | `wstring` | 获取下载站点 |
| `DelOldResFile()` | 无 | `int` | 删除旧资源文件 |
| `StepInit()` | 无 | `int` | 初始化步骤 |
| `StepInitPath()` | 无 | `int` | 初始化路径步骤 |
| `StepLoadVersion()` | 无 | `int` | 加载版本步骤 |
| `StepCheckVersion()` | 无 | `int` | 检查版本步骤 |
| `StepLoadPackInfo()` | 无 | `int` | 加载包信息步骤 |
| `StepCheckPackInfo()` | 无 | `int` | 检查包信息步骤 |
| `StepDownloadPackInfo()` | 无 | `int` | 下载包信息步骤 |
| `StepUpdatePackInfo()` | 无 | `int` | 更新包信息步骤 |
| `StepClearPackInfo()` | 无 | `int` | 清理包信息步骤 |
| `Run()` | 无 | `bool` | 运行更新流程 |
| `StepLoadVersionNoPack()` | 无 | `int` | 加载版本步骤（无包） |
| `RunNoPack()` | 无 | `bool` | 运行更新流程（无包） |
| `Continue()` | `int iResult` | `void` | 继续更新 |
| `CloneExtendMap()` | `map<wstring, wstring>&` | `void` | 克隆扩展映射 |

**使用示例**:
```cpp
UpdateManagerEx::NewInstance();
UpdateManagerEx* mgr = UpdateManagerEx::GetInstance();

UpdateManagerEx::SetDownloadSite(L"http://update.example.com", 
                                  L"http://app.example.com", 
                                  L"http://wg.example.com");

std::wstring site = mgr->GetDownloadSite();

mgr->Run();
```

---

### 4.3 FileDownloader - 文件下载器

**文件位置**: [updateengine/FileDownloader.h](file:///e:/MT3/common/updateengine/FileDownloader.h)

**类定义**:
```cpp
class FileDownloader {
public:
    static bool SynDownloadOneFile(const std::wstring& url, 
                                  const std::wstring& destfile, 
                                  bool notify = false);
};
```

**方法说明**:

| 方法 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `SynDownloadOneFile()` | `url, destfile, notify` | `bool` | 同步下载单个文件 |

**使用示例**:
```cpp
bool success = FileDownloader::SynDownloadOneFile(
    L"http://example.com/file.zip",
    L"C:\\Downloads\\file.zip",
    true
);
```

---

## 5. lua 模块 API

### 5.1 Lua C API

**文件位置**: [lua/](file:///e:/MT3/common/lua/)

**核心头文件**:
- `lua.h` - Lua 核心接口
- `lualib.h` - Lua 标准库
- `lauxlib.h` - Lua 辅助库

**常用 API**:

| 函数 | 参数 | 返回值 | 说明 |
|-----|------|-------|------|
| `lua_newstate()` | `alloc, ud` | `lua_State*` | 创建 Lua 状态 |
| `lua_close()` | `lua_State*` | `void` | 关闭 Lua 状态 |
| `luaL_openlibs()` | `lua_State*` | `void` | 打开标准库 |
| `luaL_dofile()` | `lua_State*, filename` | `int` | 执行 Lua 文件 |
| `lua_dostring()` | `lua_State*, str` | `int` | 执行 Lua 字符串 |
| `lua_getglobal()` | `lua_State*, name` | `void` | 获取全局变量 |
| `lua_setglobal()` | `lua_State*, name` | `void` | 设置全局变量 |
| `lua_pushnumber()` | `lua_State*, n` | `void` | 压入数字 |
| `lua_pushstring()` | `lua_State*, s` | `void` | 压入字符串 |
| `lua_pushnil()` | `lua_State*` | `void` | 压入 nil |
| `lua_pushboolean()` | `lua_State*, b` | `void` | 压入布尔值 |
| `lua_tonumber()` | `lua_State*, index` | `lua_Number` | 获取数字 |
| `lua_tostring()` | `lua_State*, index` | `const char*` | 获取字符串 |
| `lua_toboolean()` | `lua_State*, index` | `int` | 获取布尔值 |
| `lua_isnumber()` | `lua_State*, index` | `int` | 检查是否为数字 |
| `lua_isstring()` | `lua_State*, index` | `int` | 检查是否为字符串 |
| `lua_pcall()` | `lua_State*, nargs, nresults, errfunc` | `int` | 调用 Lua 函数 |
| `lua_pop()` | `lua_State*, n` | `void` | 弹出栈元素 |
| `lua_gettop()` | `lua_State*` | `int` | 获取栈顶索引 |
| `lua_settop()` | `lua_State*, index` | `void` | 设置栈顶索引 |

**使用示例**:
```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

lua_State* L = luaL_newstate();
luaL_openlibs(L);

if (luaL_dofile(L, "script.lua") != 0) {
    printf("Error: %s\n", lua_tostring(L, -1));
}

lua_getglobal(L, "add");
lua_pushnumber(L, 10);
lua_pushnumber(L, 20);
if (lua_pcall(L, 2, 1, 0) != 0) {
    printf("Error: %s\n", lua_tostring(L, -1));
} else {
    double result = lua_tonumber(L, -1);
    printf("Result: %f\n", result);
    lua_pop(L, 1);
}

lua_close(L);
```

---

## 6. tolua++ 模块 API

### 6.1 tolua++ 工具

**文件位置**: [tolua++-1.0.93/](file:///e:/MT3/common/tolua++-1.0.93/)

**功能**: C++ 到 Lua 的绑定工具

**使用流程**:

```bash
# 1. 编写 .pkg 文件定义需要导出的 C++ 接口
# 2. 使用 tolua++ 生成绑定代码
tolua++ -o output.cpp input.pkg

# 3. 将生成的代码编译到项目中
# 4. 在 Lua 中调用 C++ 接口
```

**.pkg 文件示例**:

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
local player = Player("Alice")
player:setPosition(100, 200)
print(player:getX(), player:getY())
player:addExp(500)
```

---

**文档结束**

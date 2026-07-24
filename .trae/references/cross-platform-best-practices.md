# 跨平台最佳实践文档

> MT3 项目跨平台最佳实践文档

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、平台差异

### 1.1 渲染 API 差异

| 平台 | 渲染 API | 库文件 |
|------|-----------|--------|
| Win32 | OpenGL 2.0 | opengl32.lib, glew32.lib |
| Android | OpenGL ES 2.0 | libEGL.lib, libGLESv2.lib |
| iOS | OpenGL ES 2.0 | OpenGLES.framework, QuartzCore.framework |
| WinRT/WP8 | OpenGL ES 2.0 + ANGLE | libEGL.lib, libGLESv2.lib |

### 1.2 文件路径差异

| 平台 | 路径分隔符 | 资源路径 |
|------|-------------|----------|
| Win32 | `\` 或 `/` | `C:\Users\Username\Documents\MT3\resource\` |
| Android | `/` | `/sdcard/MT3/resource/` |
| iOS | `/` | `/var/mobile/Applications/.../Documents/` |

### 1.3 输入处理差异

| 平台 | 输入方式 | API |
|------|-----------|-----|
| Win32 | 键盘 + 鼠标 | Windows 消息机制 |
| Android | 触摸 | Android 触摸事件 |
| iOS | 触摸 | iOS 触摸事件 |

### 1.4 线程 API 差异

| 平台 | 线程 API | 头文件 |
|------|-----------|--------|
| Win32 | Windows 线程 API | `<windows.h>` |
| Android | pthread | `<pthread.h>` |
| iOS | NSThread | `<Foundation/NSThread.h>` |

---

## 二、跨平台抽象

### 2.1 平台抽象层

```cpp
// 平台抽象接口
class Platform {
public:
    virtual std::string getDocumentsPath() = 0;
    virtual std::string getCachePath() = 0;
    virtual void showMessageBox(const std::string& title, const std::string& message) = 0;
    virtual void* createThread(ThreadFunction func, void* arg) = 0;
    virtual void sleep(int milliseconds) = 0;
};

// Win32 平台实现
class Win32Platform : public Platform {
public:
    std::string getDocumentsPath() override {
        char path[MAX_PATH];
        SHGetFolderPath(NULL, CSIDL_PERSONAL, NULL, 0, path);
        return std::string(path) + "\\MT3\\";
    }

    std::string getCachePath() override {
        char path[MAX_PATH];
        GetTempPath(MAX_PATH, path);
        return std::string(path) + "MT3\\";
    }

    void showMessageBox(const std::string& title, const std::string& message) override {
        MessageBoxA(NULL, message.c_str(), title.c_str(), MB_OK);
    }

    void* createThread(ThreadFunction func, void* arg) override {
        return (void*)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)func, arg, 0, NULL);
    }

    void sleep(int milliseconds) override {
        Sleep(milliseconds);
    }
};

// Android 平台实现
class AndroidPlatform : public Platform {
public:
    std::string getDocumentsPath() override {
        return "/sdcard/MT3/";
    }

    std::string getCachePath() override {
        return "/sdcard/Android/data/com.mt3.game/cache/";
    }

    void showMessageBox(const std::string& title, const std::string& message) override {
        // 使用 JNI 调用 Android API
    }

    void* createThread(ThreadFunction func, void* arg) override {
        pthread_t thread;
        pthread_create(&thread, NULL, func, arg);
        return (void*)thread;
    }

    void sleep(int milliseconds) override {
        usleep(milliseconds * 1000);
    }
};

// iOS 平台实现
class IOSPlatform : public Platform {
public:
    std::string getDocumentsPath() override {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths firstObject];
        return std::string([documentsDirectory UTF8String]) + "/MT3/";
    }

    std::string getCachePath() override {
        return getDocumentsPath() + "cache/";
    }

    void showMessageBox(const std::string& title, const std::string& message) override {
        UIAlertView* alert = [[UIAlertView alloc]
            initWithTitle:[NSString stringWithUTF8String:title.c_str()]
            message:[NSString stringWithUTF8String:message.c_str()]
            delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

    void* createThread(ThreadFunction func, void* arg) override {
        NSThread* thread = [[NSThread alloc] initWithTarget:[NSThread class] selector:@selector(detachedNewThreadWithBlock:) object:[^{
            func(arg);
        } copy]];
        [thread start];
        return (void*)thread;
    }

    void sleep(int milliseconds) override {
        [NSThread sleepForTimeInterval:milliseconds / 1000.0];
    }
};
```

### 2.2 平台检测

```cpp
// 平台枚举
enum class PlatformType {
    WIN32,
    ANDROID,
    IOS,
    UNKNOWN
};

// 平台检测函数
PlatformType GetPlatformType() {
#if defined(_WIN32)
    return PlatformType::WIN32;
#elif defined(ANDROID)
    return PlatformType::ANDROID;
#elif defined(IOS)
    return PlatformType::IOS;
#else
    return PlatformType::UNKNOWN;
#endif
}

// 创建平台实例
Platform* CreatePlatform() {
    PlatformType type = GetPlatformType();

    switch (type) {
        case PlatformType::WIN32:
            return new Win32Platform();
        case PlatformType::ANDROID:
            return new AndroidPlatform();
        case PlatformType::IOS:
            return new IOSPlatform();
        default:
            return nullptr;
    }
}
```

---

## 三、跨平台文件处理

### 3.1 文件路径处理

```cpp
// 跨平台路径处理
class PathUtils {
public:
    static std::string join(const std::string& path1, const std::string& path2) {
#if defined(_WIN32)
        return path1 + "\\" + path2;
#else
        return path1 + "/" + path2;
#endif
    }

    static std::string normalize(const std::string& path) {
        std::string normalized = path;
        std::replace(normalized.begin(), normalized.end(), '\\', '/');
        return normalized;
    }

    static std::string getExtension(const std::string& path) {
        size_t pos = path.find_last_of('.');
        if (pos != std::string::npos) {
            return path.substr(pos);
        }
        return "";
    }
};
```

### 3.2 文件读取

```cpp
// 跨平台文件读取
class FileUtils {
public:
    static std::string readFile(const std::string& filename) {
        std::string path = PathUtils::join(getDocumentsPath(), filename);

        FILE* file = fopen(path.c_str(), "rb");
        if (!file) {
            return "";
        }

        fseek(file, 0, SEEK_END);
        long size = ftell(file);
        fseek(file, 0, SEEK_SET);

        std::string content(size, '\0');
        fread(&content[0], 1, size, file);

        fclose(file);
        return content;
    }

    static bool writeFile(const std::string& filename, const std::string& content) {
        std::string path = PathUtils::join(getDocumentsPath(), filename);

        FILE* file = fopen(path.c_str(), "wb");
        if (!file) {
            return false;
        }

        fwrite(content.c_str(), 1, content.size(), file);
        fclose(file);
        return true;
    }
};
```

---

## 四、跨平台线程处理

### 4.1 线程抽象

```cpp
// 跨平台线程
class Thread {
public:
    Thread(ThreadFunction func, void* arg) {
        m_platform = CreatePlatform();
        m_thread = m_platform->createThread(func, arg);
    }

    ~Thread() {
        delete m_platform;
    }

    void join() {
#if defined(_WIN32)
        WaitForSingleObject((HANDLE)m_thread, INFINITE);
#elif defined(ANDROID)
        pthread_join((pthread_t)m_thread, NULL);
#elif defined(IOS)
        [(NSThread*)m_thread join];
#endif
    }

private:
    Platform* m_platform;
    void* m_thread;
};
```

### 4.2 互斥锁抽象

```cpp
// 跨平台互斥锁
class Mutex {
public:
    Mutex() {
#if defined(_WIN32)
        InitializeCriticalSection(&m_mutex);
#elif defined(ANDROID)
        pthread_mutex_init(&m_mutex, NULL);
#elif defined(IOS)
        m_mutex = [[NSLock alloc] init];
#endif
    }

    ~Mutex() {
#if defined(_WIN32)
        DeleteCriticalSection(&m_mutex);
#elif defined(ANDROID)
        pthread_mutex_destroy(&m_mutex);
#elif defined(IOS)
        [m_mutex release];
#endif
    }

    void lock() {
#if defined(_WIN32)
        EnterCriticalSection(&m_mutex);
#elif defined(ANDROID)
        pthread_mutex_lock(&m_mutex);
#elif defined(IOS)
        [m_mutex lock];
#endif
    }

    void unlock() {
#if defined(_WIN32)
        LeaveCriticalSection(&m_mutex);
#elif defined(ANDROID)
        pthread_mutex_unlock(&m_mutex);
#elif defined(IOS)
        [m_mutex unlock];
#endif
    }

private:
#if defined(_WIN32)
    CRITICAL_SECTION m_mutex;
#elif defined(ANDROID)
    pthread_mutex_t m_mutex;
#elif defined(IOS)
    NSLock* m_mutex;
#endif
};
```

---

## 五、跨平台网络处理

### 5.1 Socket 抽象

```cpp
// 跨平台 Socket
class Socket {
public:
    Socket() {
#if defined(_WIN32)
        WSADATA wsaData;
        WSAStartup(MAKEWORD(2, 2), &wsaData);
#endif

        m_socket = ::socket(AF_INET, SOCK_STREAM, 0);
    }

    ~Socket() {
        close();

#if defined(_WIN32)
        WSACleanup();
#endif
    }

    bool connect(const std::string& host, int port) {
        sockaddr_in serverAddr;
        serverAddr.sin_family = AF_INET;
        serverAddr.sin_port = htons(port);
        serverAddr.sin_addr.s_addr = inet_addr(host.c_str());

        return ::connect(m_socket, (sockaddr*)&serverAddr, sizeof(serverAddr)) == 0;
    }

    int send(const std::string& data) {
        return ::send(m_socket, data.c_str(), data.size(), 0);
    }

    int receive(char* buffer, int size) {
        return ::recv(m_socket, buffer, size, 0);
    }

    void close() {
#if defined(_WIN32)
        ::closesocket(m_socket);
#else
        ::close(m_socket);
#endif
    }

private:
    int m_socket;
};
```

---

## 六、最佳实践

### 6.1 平台抽象最佳实践

- 使用平台抽象层屏蔽平台差异
- 使用条件编译处理平台特定代码
- 使用平台检测选择平台实现
- 避免平台特定代码扩散

### 6.2 文件处理最佳实践

- 使用跨平台路径处理
- 使用相对路径而非绝对路径
- 使用平台抽象层处理文件操作
- 避免硬编码路径

### 6.3 线程处理最佳实践

- 使用跨平台线程抽象
- 使用跨平台互斥锁
- 避免平台特定线程 API
- 使用线程池复用线程

### 6.4 网络处理最佳实践

- 使用跨平台 Socket 抽象
- 使用跨平台网络 API
- 避免平台特定网络 API
- 使用数据压缩减少网络传输

---

## 七、常见问题

### 7.1 平台特定代码未生效

**原因**: 条件编译宏未正确定义

**解决方案**:
```cpp
// 检查平台宏
#if defined(_WIN32)
    // Win32 平台代码
#elif defined(ANDROID)
    // Android 平台代码
#elif defined(IOS)
    // iOS 平台代码
#endif
```

### 7.2 文件路径错误

**原因**: 路径分隔符不正确

**解决方案**:
```cpp
// 使用跨平台路径处理
std::string path = PathUtils::join(getDocumentsPath(), "texture.png");
```

### 7.3 线程同步问题

**原因**: 平台特定线程 API 不一致

**解决方案**:
```cpp
// 使用跨平台互斥锁
Mutex mutex;
mutex.lock();
// 临界区代码
mutex.unlock();
```

---

## 八、参考资料

- [公共约束](../references/common-constraints.md)
- [Win32 平台特定技能](../skills/platform-win32/SKILL.md)
- [Android 平台特定技能](../skills/platform-android/SKILL.md)
- [iOS 平台特定技能](../skills/platform-ios/SKILL.md)

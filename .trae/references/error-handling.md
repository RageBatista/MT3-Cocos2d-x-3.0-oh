# 错误处理策略

> 本文件定义了 MT3 项目中的错误处理策略和最佳实践。

## 目录

- [错误分类](#错误分类)
- [错误处理模式](#错误处理模式)
- [资源加载错误处理](#资源加载错误处理)
- [网络错误处理](#网络错误处理)
- [内存错误处理](#内存错误处理)
- [日志记录](#日志记录)
- [错误恢复策略](#错误恢复策略)
- [常见错误场景](#常见错误场景)
- [参考文档](#参考文档)

---

## 错误分类

### 致命错误

```yaml
定义：导致程序无法继续运行的错误
处理方式：记录日志，显示错误提示，安全退出
示例：
  - 引擎初始化失败
  - 关键资源加载失败
  - 内存不足
```

### 可恢复错误

```yaml
定义：可以通过重试或备用方案恢复的错误
处理方式：记录日志，尝试恢复，显示警告
示例：
  - 非关键资源加载失败
  - 网络连接超时
  - 文件写入失败
```

### 警告

```yaml
定义：不影响程序运行但需要注意的问题
处理方式：记录日志，显示提示
示例：
  - 性能下降
  - 资源加载较慢
  - 配置参数异常
```

## 错误处理模式

### C++ 错误处理

```cpp
// 1. 返回值检查
bool loadResource(const std::string& path) {
    if (path.empty()) {
        LOG_ERROR("Resource path is empty");
        return false;
    }

    FILE* fp = fopen(path.c_str(), "rb");
    if (!fp) {
        LOG_ERROR("Failed to open file: %s", path.c_str());
        return false;
    }

    // ... 处理文件

    fclose(fp);
    return true;
}

// 2. 异常处理
void processResource(const std::string& path) {
    try {
        // 可能抛出异常的代码
        loadAndProcess(path);
    } catch (const std::exception& e) {
        LOG_ERROR("Exception in processResource: %s", e.what());
        // 恢复或清理
    } catch (...) {
        LOG_ERROR("Unknown exception in processResource");
        // 恢复或清理
    }
}

// 3. 错误码
enum class ErrorCode {
    SUCCESS = 0,
    INVALID_PARAM = 1,
    RESOURCE_NOT_FOUND = 2,
    OUT_OF_MEMORY = 3,
    NETWORK_ERROR = 4
};

ErrorCode doSomething(int param) {
    if (param < 0) {
        return ErrorCode::INVALID_PARAM;
    }
    // ...
    return ErrorCode::SUCCESS;
}
```

### Lua 错误处理

```lua
-- 1. pcall 保护调用
local success, result = pcall(function()
    -- 可能出错的代码
    return doSomething()
end)

if not success then
    print("Error:", result)
    -- 处理错误
else
    -- 使用结果
    print("Result:", result)
end

-- 2. xpcall 带错误处理函数
local function errorHandler(err)
    print("Stack trace:", debug.traceback(err, 2))
    return err
end

local success, result = xpcall(function()
    return doSomething()
end, errorHandler)

-- 3. 断言
assert(condition, "Error message")

-- 4. 自定义错误处理
function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        print("Error in safeCall:", result)
        return nil
    end
    return result
end
```

## 资源加载错误处理

### CEGUI 资源加载

```cpp
// 安全加载布局文件
CEGUI::Window* safeLoadLayout(const std::string& layoutFile) {
    try {
        CEGUI::Window* window = CEGUI::WindowManager::getSingleton().loadWindowLayout(layoutFile);
        if (!window) {
            LOG_ERROR("Failed to load layout: %s (returned NULL)", layoutFile.c_str());
            return nullptr;
        }
        return window;
    } catch (const CEGUI::FileIOException& e) {
        LOG_ERROR("File not found: %s - %s", layoutFile.c_str(), e.what());
        return nullptr;
    } catch (const CEGUI::InvalidRequestException& e) {
        LOG_ERROR("Invalid request: %s - %s", layoutFile.c_str(), e.what());
        return nullptr;
    } catch (const CEGUI::Exception& e) {
        LOG_ERROR("CEGUI exception: %s - %s", layoutFile.c_str(), e.what());
        return nullptr;
    } catch (...) {
        LOG_ERROR("Unknown exception while loading layout: %s", layoutFile.c_str());
        return nullptr;
    }
}

// 安全加载图片集
bool safeLoadImageset(const std::string& imagesetFile) {
    try {
        CEGUI::ImagesetManager::getSingleton().create(imagesetFile);
        return true;
    } catch (const CEGUI::Exception& e) {
        LOG_ERROR("Failed to load imageset: %s - %s", imagesetFile.c_str(), e.what());
        // 尝试加载备用图片集
        return loadFallbackImageset(imagesetFile);
    }
}
```

### Cocos2d-x 资源加载

```cpp
// 安全加载纹理
CCTexture2D* safeLoadTexture(const std::string& textureFile) {
    CCTexture2D* texture = CCTextureCache::sharedTextureCache()->addImage(textureFile.c_str());
    if (!texture) {
        LOG_ERROR("Failed to load texture: %s", textureFile.c_str());
        // 尝试加载备用纹理
        return loadFallbackTexture(textureFile);
    }
    return texture;
}

// 安全加载精灵帧
CCSpriteFrame* safeLoadSpriteFrame(const std::string& frameName) {
    CCSpriteFrame* frame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName(frameName.c_str());
    if (!frame) {
        LOG_ERROR("Sprite frame not found: %s", frameName.c_str());
        // 尝试加载备用精灵帧
        return loadFallbackSpriteFrame(frameName);
    }
    return frame;
}

// 异步加载资源错误处理
void onTextureLoaded(CCTexture2D* texture) {
    if (!texture) {
        LOG_ERROR("Async texture load failed");
        // 显示错误提示
        showErrorDialog("Failed to load texture");
        // 尝试重新加载
        retryTextureLoad();
    } else {
        // 纹理加载成功
        LOG_INFO("Texture loaded successfully");
    }
}
```

### Nuclear 引擎错误处理

```cpp
// 安全获取引擎
Nuclear::Engine* safeGetEngine() {
    Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
    if (!engine) {
        LOG_ERROR("Nuclear engine not initialized");
        // 显示错误提示
        showErrorDialog("Engine initialization failed");
        return nullptr;
    }
    return engine;
}

// 安全创建特效
Nuclear::IEffect* safeCreateEffect(const std::string& effectName) {
    Nuclear::Engine* engine = safeGetEngine();
    if (!engine) {
        return nullptr;
    }

    Nuclear::EffectManager* effectMan = engine->GetEffectManager();
    if (!effectMan) {
        LOG_ERROR("Effect manager not available");
        return nullptr;
    }

    Nuclear::IEffect* effect = effectMan->CreateEffect(effectName.c_str());
    if (!effect) {
        LOG_ERROR("Failed to create effect: %s", effectName.c_str());
        return nullptr;
    }

    return effect;
}
```

## 网络错误处理

```cpp
// 网络请求错误处理
class NetworkRequest {
public:
    enum class Error {
        SUCCESS = 0,
        TIMEOUT = 1,
        CONNECTION_FAILED = 2,
        SERVER_ERROR = 3,
        INVALID_RESPONSE = 4
    };

    static Error sendRequest(const std::string& url, std::string& response) {
        CURL* curl = curl_easy_init();
        if (!curl) {
            LOG_ERROR("Failed to initialize curl");
            return Error::CONNECTION_FAILED;
        }

        // 设置超时
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30L);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10L);

        // 设置 URL
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());

        // 设置写入回调
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);

        // 执行请求
        CURLcode res = curl_easy_perform(curl);

        curl_easy_cleanup(curl);

        if (res != CURLE_OK) {
            LOG_ERROR("Curl error: %s", curl_easy_strerror(res));
            if (res == CURLE_OPERATION_TIMEDOUT) {
                return Error::TIMEOUT;
            }
            return Error::CONNECTION_FAILED;
        }

        return Error::SUCCESS;
    }

private:
    static size_t writeCallback(void* contents, size_t size, size_t nmemb, std::string* s) {
        s->append((char*)contents, size * nmemb);
        return size * nmemb;
    }
};
```

## 内存错误处理

```cpp
// 内存分配失败处理
template<typename T>
T* safeNew() {
    try {
        return new T();
    } catch (const std::bad_alloc& e) {
        LOG_ERROR("Memory allocation failed: %s", e.what());
        // 尝试释放缓存
        releaseCache();
        // 重试分配
        try {
            return new T();
        } catch (...) {
            LOG_ERROR("Memory allocation failed after cache release");
            // 显示内存不足提示
            showOutOfMemoryDialog();
            return nullptr;
        }
    }
}

// 检查内存使用
void checkMemoryUsage() {
    MEMORYSTATUSEX status;
    status.dwLength = sizeof(status);
    GlobalMemoryStatusEx(&status);

    if (status.dwMemoryLoad > 90) {
        LOG_WARNING("High memory usage: %d%%", status.dwMemoryLoad);
        // 释放缓存
        releaseCache();
    }
}
```

## 日志记录

### 日志级别

```cpp
enum class LogLevel {
    DEBUG = 0,
    INFO = 1,
    WARNING = 2,
    ERROR = 3,
    FATAL = 4
};

// 日志宏
#define LOG_DEBUG(fmt, ...)   logMessage(LogLevel::DEBUG, __FILE__, __LINE__, fmt, ##__VA_ARGS__)
#define LOG_INFO(fmt, ...)    logMessage(LogLevel::INFO, __FILE__, __LINE__, fmt, ##__VA_ARGS__)
#define LOG_WARNING(fmt, ...) logMessage(LogLevel::WARNING, __FILE__, __LINE__, fmt, ##__VA_ARGS__)
#define LOG_ERROR(fmt, ...)   logMessage(LogLevel::ERROR, __FILE__, __LINE__, fmt, ##__VA_ARGS__)
#define LOG_FATAL(fmt, ...)   logMessage(LogLevel::FATAL, __FILE__, __LINE__, fmt, ##__VA_ARGS__)

// 日志函数
void logMessage(LogLevel level, const char* file, int line, const char* fmt, ...) {
    // 格式化消息
    char buffer[1024];
    va_list args;
    va_start(args, fmt);
    vsnprintf(buffer, sizeof(buffer), fmt, args);
    va_end(args);

    // 输出到控制台
    printf("[%s] %s:%d - %s\n",
           levelToString(level), file, line, buffer);

    // 输出到文件
    logToFile(level, file, line, buffer);

    // 如果是致命错误，显示对话框
    if (level == LogLevel::FATAL) {
        showFatalErrorDialog(buffer);
    }
}
```

## 错误恢复策略

### 重试机制

```cpp
// 带重试的操作
template<typename Func>
bool retryOperation(Func operation, int maxRetries = 3, int delayMs = 1000) {
    for (int i = 0; i < maxRetries; ++i) {
        if (operation()) {
            return true;
        }
        LOG_WARNING("Operation failed, retry %d/%d", i + 1, maxRetries);
        if (i < maxRetries - 1) {
            Sleep(delayMs);
        }
    }
    LOG_ERROR("Operation failed after %d retries", maxRetries);
    return false;
}

// 使用示例
bool loadResourceWithRetry(const std::string& path) {
    return retryOperation([&]() {
        return loadResource(path);
    });
}
```

### 备用方案

```cpp
// 加载备用资源
CEGUI::Window* loadLayoutWithFallback(const std::string& layoutFile) {
    // 尝试加载主资源
    CEGUI::Window* window = safeLoadLayout(layoutFile);
    if (window) {
        return window;
    }

    // 加载备用资源
    std::string fallbackFile = getFallbackLayout(layoutFile);
    LOG_INFO("Loading fallback layout: %s", fallbackFile.c_str());
    window = safeLoadLayout(fallbackFile);
    if (window) {
        return window;
    }

    // 使用默认布局
    LOG_WARNING("Using default layout");
    return createDefaultLayout();
}
```

### 降级策略

```cpp
// 性能降级
void adjustPerformanceLevel() {
    float fps = getFPS();

    if (fps < 30) {
        // 低性能模式
        setPerformanceLevel(PerformanceLevel::LOW);
        disableEffects();
        reduceTextureQuality();
    } else if (fps < 50) {
        // 中等性能模式
        setPerformanceLevel(PerformanceLevel::MEDIUM);
        reduceParticleCount();
    } else {
        // 高性能模式
        setPerformanceLevel(PerformanceLevel::HIGH);
        enableAllEffects();
    }
}
```

## 常见错误场景

### 引擎初始化失败

```cpp
// 引擎初始化
bool initializeEngine() {
    // 初始化 Nuclear 引擎
    Nuclear::Engine* engine = Nuclear::GetEngine();
    if (!engine) {
        LOG_FATAL("Failed to initialize Nuclear engine");
        showFatalErrorDialog("Engine initialization failed");
        return false;
    }

    // 初始化 CEGUI
    try {
        CEGUI::System::getSingleton().initialise();
    } catch (const CEGUI::Exception& e) {
        LOG_FATAL("Failed to initialize CEGUI: %s", e.what());
        showFatalErrorDialog("UI initialization failed");
        return false;
    }

    // 初始化 Cocos2d-x
    if (!cocos2d::CCDirector::sharedDirector()->init()) {
        LOG_FATAL("Failed to initialize Cocos2d-x");
        showFatalErrorDialog("Scene initialization failed");
        return false;
    }

    return true;
}
```

### 文件操作错误

```cpp
// 安全文件写入
bool safeWriteFile(const std::string& path, const std::string& content) {
    // 创建备份
    std::string backupPath = path + ".bak";
    if (fileExists(path)) {
        if (!copyFile(path, backupPath)) {
            LOG_WARNING("Failed to create backup: %s", backupPath.c_str());
        }
    }

    // 写入文件
    FILE* fp = fopen(path.c_str(), "wb");
    if (!fp) {
        LOG_ERROR("Failed to open file for writing: %s", path.c_str());
        // 尝试恢复备份
        if (fileExists(backupPath)) {
            copyFile(backupPath, path);
        }
        return false;
    }

    size_t written = fwrite(content.c_str(), 1, content.size(), fp);
    fclose(fp);

    if (written != content.size()) {
        LOG_ERROR("Failed to write complete file: %s", path.c_str());
        // 恢复备份
        if (fileExists(backupPath)) {
            copyFile(backupPath, path);
        }
        return false;
    }

    // 删除备份
    if (fileExists(backupPath)) {
        remove(backupPath.c_str());
    }

    return true;
}
```

## 参考文档

- [公共约束](common-constraints.md)
- [资源管理](resource-management.md)
- [性能优化](performance-guide.md)

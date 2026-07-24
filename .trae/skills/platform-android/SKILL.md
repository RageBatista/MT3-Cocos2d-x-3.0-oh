---
name: platform-android
description: MT3 项目 Android 平台特定技能
---

# Android 平台特定技能

> MT3 项目 Android 平台特定技能

## 何时使用

在以下场景使用本技能：

- 需要在 Android 平台上开发时
- 需要使用 Android 平台特定 API 时
- 需要处理 Android 平台特定问题时
- 需要优化 Android 平台性能时

## 何时不使用

在以下场景不使用本技能：

- 需要在 Win32 平台上开发时 → 使用 [Win32 平台特定技能](../platform-win32/SKILL.md)
- 需要在 iOS 平台上开发时 → 使用 [iOS 平台特定技能](../platform-ios/SKILL.md)

## 输入要求

使用本技能前需要满足以下条件：

- 已阅读 [公共约束](../references/common-constraints.md)
- 已配置 Android NDK
- 已配置 Android SDK

## 关键约束

使用本技能时需要注意以下约束：

- **渲染 API**: 必须使用 OpenGL ES 2.0
- **库文件**: 必须链接 libEGL.lib 和 libGLESv2.lib
- **编码约束**: C++ 源码使用 UTF-8 with BOM 编码

## 平台特性

### 1. 渲染 API

Android 平台使用 OpenGL ES 2.0 API。

```cpp
// Android 平台使用 OpenGL ES 2.0
#include <GLES2/gl2.h>

// 使用 OpenGL ES 2.0 API
glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
```

### 2. 输入处理

Android 平台使用触摸事件处理输入。

```cpp
// 处理触摸事件
bool onTouchEvent(cocos2d::CCTouch* touch, cocos2d::CCEvent* event) {
    CCPoint location = touch->getLocation();

    // 处理触摸事件
    switch (touch->getID()) {
        case 0:
            // 单点触摸
            break;
        default:
            // 多点触摸
            break;
    }

    return true;
}

// 注册触摸事件
cocos2d::CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, 0, true);
```

### 3. 文件路径

Android 平台使用正斜杠作为路径分隔符。

```cpp
// Android 平台路径
std::string path = "/sdcard/MT3/resource/texture.png";

// 使用 Android 资源路径
std::string path = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename("texture.png");
```

### 4. 线程模型

Android 平台使用 pthread 线程 API。

```cpp
// 创建 pthread 线程
pthread_t thread;
pthread_create(&thread, NULL, ThreadFunction, NULL);

// 等待线程结束
pthread_join(thread, NULL);

// 销毁线程
pthread_detach(thread);
```

### 5. 文件系统

Android 平台使用 Android 文件 API。

```cpp
// 读取文件
std::string path = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename("filename.txt");
unsigned long size = 0;
unsigned char* data = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(path.c_str(), "rb", &size);

if (data) {
    // 处理文件数据
    delete[] data;
}
```

### 6. 网络通信

Android 平台使用 BSD Socket API。

```cpp
// 创建 socket
int socket = socket(AF_INET, SOCK_STREAM, 0);

// 连接服务器
sockaddr_in serverAddr;
serverAddr.sin_family = AF_INET;
serverAddr.sin_port = htons(8080);
serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");
connect(socket, (sockaddr*)&serverAddr, sizeof(serverAddr));

// 发送数据
send(socket, "Hello", 5, 0);

// 接收数据
char buffer[1024];
recv(socket, buffer, 1024, 0);

// 关闭 socket
close(socket);
```

### 7. JNI 调用

Android 平台使用 JNI 调用 Java 代码。

```cpp
// 调用 Java 方法
jclass clazz = env->FindClass("com/mt3/MainActivity");
jmethodID method = env->GetMethodID(clazz, "showToast", "(Ljava/lang/String;)V");
jstring message = env->NewStringUTF("Hello from C++");
env->CallVoidMethod(obj, method, message);
env->DeleteLocalRef(message);
env->DeleteLocalRef(clazz);
```

## 性能优化

### 1. 渲染优化

- 使用批处理减少 Draw Call
- 优化纹理格式
- 使用纹理图集
- 使用 VBO (Vertex Buffer Object)

### 2. 内存优化

- 使用对象池
- 及时释放资源
- 使用智能指针
- 优化内存分配

### 3. 线程优化

- 使用多线程并行处理
- 优化线程同步
- 使用线程池
- 避免线程竞争

## 调试技巧

### 1. 使用 Logcat

```cpp
// 输出调试信息
#include <android/log.h>

#define LOG_TAG "MT3"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

LOGI("Info message");
LOGE("Error message");
```

### 2. 使用 GDB

- 使用 GDB 调试器
- 设置断点
- 查看变量
- 单步执行

### 3. 使用日志系统

```cpp
// 使用日志系统
Logger::log(Logger::Level::INFO, "Info message");
Logger::log(Logger::Level::ERROR, "Error message");
```

## 常见问题

### 问题 1: OpenGL ES 初始化失败

**原因**: OpenGL ES 上下文创建失败

**解决方案**:
```cpp
// 检查 OpenGL ES 版本
const char* version = (const char*)glGetString(GL_VERSION);
LOGI("OpenGL ES Version: %s", version);

// 检查支持的扩展
const char* extensions = (const char*)glGetString(GL_EXTENSIONS);
LOGI("OpenGL ES Extensions: %s", extensions);
```

### 问题 2: 纹理加载失败

**原因**: 纹理路径错误

**解决方案**:
```cpp
// 检查纹理路径
std::string path = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename("texture.png");
if (path.empty()) {
    LOGE("Texture file not found");
    return false;
}
```

### 问题 3: 网络连接失败

**原因**: 网络权限未设置

**解决方案**:
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 参考资料

- [公共约束](../references/common-constraints.md)
- [性能优化指南](../references/performance-guide.md)
- [跨平台最佳实践](../references/cross-platform-best-practices.md)

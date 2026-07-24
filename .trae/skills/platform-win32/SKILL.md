---
name: platform-win32
description: MT3 项目 Win32 平台特定技能
---

# Win32 平台特定技能

> MT3 项目 Win32 平台特定技能

## 何时使用

在以下场景使用本技能：

- 需要在 Win32 平台上开发时
- 需要使用 Win32 平台特定 API 时
- 需要处理 Win32 平台特定问题时
- 需要优化 Win32 平台性能时

## 何时不使用

在以下场景不使用本技能：

- 需要在 Android 平台上开发时 → 使用 [Android 平台特定技能](../platform-android/SKILL.md)
- 需要在 iOS 平台上开发时 → 使用 [iOS 平台特定技能](../platform-ios/SKILL.md)

## 输入要求

使用本技能前需要满足以下条件：

- 已阅读 [公共约束](../references/common-constraints.md)
- 已配置 Visual Studio 2013 和 v120 工具集
- 已安装 Windows SDK 8.1

## 关键约束

使用本技能时需要注意以下约束：

- **工具集约束**: 必须使用 v120 (VS2013) 工具集
- **渲染 API**: 必须使用原生 OpenGL 2.0，禁止使用 OpenGL ES API
- **库文件**: 必须链接 opengl32.lib 和 glew32.lib，禁止链接 libEGL.lib 和 libGLESv2.lib
- **编码约束**: C++ 源码使用 UTF-8 with BOM 编码

## 平台特性

### 1. 渲染 API

Win32 平台使用原生 OpenGL 2.0 API，而非 OpenGL ES。

```cpp
// Win32 平台使用原生 OpenGL 2.0
#include <GL/glew.h>

// 初始化 GLEW
glewInit();

// 使用 OpenGL 2.0 API
glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
```

### 2. 输入处理

Win32 平台使用 Windows 消息机制处理输入。

```cpp
// 处理 Windows 消息
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
    switch (message) {
        case WM_KEYDOWN:
            // 处理键盘按下
            break;
        case WM_KEYUP:
            // 处理键盘释放
            break;
        case WM_LBUTTONDOWN:
            // 处理鼠标左键按下
            break;
        case WM_LBUTTONUP:
            // 处理鼠标左键释放
            break;
        case WM_MOUSEMOVE:
            // 处理鼠标移动
            break;
        default:
            return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}
```

### 3. 文件路径

Win32 平台使用反斜杠作为路径分隔符。

```cpp
// Win32 平台路径
std::string path = "C:\\Users\\Username\\Documents\\MT3\\resource\\texture.png";

// 使用跨平台路径分隔符
std::string path = "C:/Users/Username/Documents/MT3/resource/texture.png";
```

### 4. 线程模型

Win32 平台使用 Windows 线程 API。

```cpp
// 创建 Windows 线程
HANDLE hThread = CreateThread(
    NULL,
    0,
    ThreadFunction,
    NULL,
    0,
    NULL
);

// 等待线程结束
WaitForSingleObject(hThread, INFINITE);

// 关闭线程句柄
CloseHandle(hThread);
```

### 5. 文件系统

Win32 平台使用 Windows 文件 API。

```cpp
// 读取文件
HANDLE hFile = CreateFile(
    "filename.txt",
    GENERIC_READ,
    FILE_SHARE_READ,
    NULL,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    NULL
);

if (hFile != INVALID_HANDLE_VALUE) {
    DWORD fileSize = GetFileSize(hFile, NULL);
    char* buffer = new char[fileSize + 1];
    DWORD bytesRead;
    ReadFile(hFile, buffer, fileSize, &bytesRead, NULL);
    buffer[bytesRead] = '\0';
    CloseHandle(hFile);
}
```

### 6. 网络通信

Win32 平台使用 Winsock API。

```cpp
// 初始化 Winsock
WSADATA wsaData;
WSAStartup(MAKEWORD(2, 2), &wsaData);

// 创建 socket
SOCKET socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

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
closesocket(socket);
WSACleanup();
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

### 1. 使用 Visual Studio 调试器

- 设置断点
- 查看变量
- 单步执行
- 查看调用堆栈

### 2. 使用 OutputDebugString

```cpp
// 输出调试信息
OutputDebugString("Debug message\n");

// 输出格式化调试信息
char buffer[256];
sprintf_s(buffer, "Value: %d\n", value);
OutputDebugString(buffer);
```

### 3. 使用日志系统

```cpp
// 使用日志系统
Logger::log(Logger::Level::INFO, "Info message");
Logger::log(Logger::Level::ERROR, "Error message");
```

## 常见问题

### 问题 1: OpenGL 初始化失败

**原因**: GLEW 初始化失败

**解决方案**:
```cpp
// 检查 GLEW 初始化
GLenum err = glewInit();
if (err != GLEW_OK) {
    printf("GLEW Error: %s\n", glewGetErrorString(err));
    return false;
}
```

### 问题 2: 纹理加载失败

**原因**: 纹理路径错误

**解决方案**:
```cpp
// 检查纹理路径
std::string path = "resource/texture.png";
FILE* file = fopen(path.c_str(), "rb");
if (!file) {
    printf("Texture file not found: %s\n", path.c_str());
    return false;
}
fclose(file);
```

### 问题 3: 网络连接失败

**原因**: Winsock 未初始化

**解决方案**:
```cpp
// 初始化 Winsock
WSADATA wsaData;
int result = WSAStartup(MAKEWORD(2, 2), &wsaData);
if (result != 0) {
    printf("WSAStartup failed: %d\n", result);
    return false;
}
```

## 参考资料

- [公共约束](../references/common-constraints.md)
- [性能优化指南](../references/performance-guide.md)
- [跨平台最佳实践](../references/cross-platform-best-practices.md)

---
name: platform-ios
description: MT3 项目 iOS 平台特定技能
---

# iOS 平台特定技能

> MT3 项目 iOS 平台特定技能

## 何时使用

在以下场景使用本技能：

- 需要在 iOS 平台上开发时
- 需要使用 iOS 平台特定 API 时
- 需要处理 iOS 平台特定问题时
- 需要优化 iOS 平台性能时

## 何时不使用

在以下场景不使用本技能：

- 需要在 Win32 平台上开发时 → 使用 [Win32 平台特定技能](../platform-win32/SKILL.md)
- 需要在 Android 平台上开发时 → 使用 [Android 平台特定技能](../platform-android/SKILL.md)

## 输入要求

使用本技能前需要满足以下条件：

- 已阅读 [公共约束](../references/common-constraints.md)
- 已配置 Xcode
- 已配置 iOS SDK

## 关键约束

使用本技能时需要注意以下约束：

- **渲染 API**: 必须使用 OpenGL ES 2.0
- **库文件**: 必须链接 OpenGLES.framework 和 QuartzCore.framework
- **编码约束**: C++ 源码使用 UTF-8 with BOM 编码

## 平台特性

### 1. 渲染 API

iOS 平台使用 OpenGL ES 2.0 API。

```cpp
// iOS 平台使用 OpenGL ES 2.0
#include <OpenGLES/ES2/gl.h>

// 使用 OpenGL ES 2.0 API
glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
```

### 2. 输入处理

iOS 平台使用触摸事件处理输入。

```cpp
// 处理触摸事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        // 处理触摸事件
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        // 处理触摸移动
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        // 处理触摸结束
    }
}
```

### 3. 文件路径

iOS 平台使用正斜杠作为路径分隔符。

```cpp
// iOS 平台路径
std::string path = "/var/mobile/Applications/.../Documents/texture.png";

// 使用 iOS 资源路径
std::string path = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename("texture.png");
```

### 4. 线程模型

iOS 平台使用 NSThread 线程 API。

```cpp
// 创建 NSThread
NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadFunction:) object:nil];
[thread start];

// 等待线程结束
[thread join];

// 销毁线程
[thread release];
```

### 5. 文件系统

iOS 平台使用 iOS 文件 API。

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

iOS 平台使用 BSD Socket API。

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

### 7. Objective-C++ 混合编程

iOS 平台支持 Objective-C++ 混合编程。

```cpp
// Objective-C++ 代码
@interface MyObject : NSObject {
}

- (void)doSomething;

@end

@implementation MyObject

- (void)doSomething {
    NSLog(@"Do something");
}

@end

// C++ 代码
MyObject* obj = [[MyObject alloc] init];
[obj doSomething];
[obj release];
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
- 使用 GCD (Grand Central Dispatch)
- 避免线程竞争

## 调试技巧

### 1. 使用 NSLog

```cpp
// 输出调试信息
NSLog(@"Debug message");

// 输出格式化调试信息
NSLog(@"Value: %d", value);
```

### 2. 使用 Xcode 调试器

- 设置断点
- 查看变量
- 单步执行
- 查看调用堆栈

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
NSLog(@"OpenGL ES Version: %s", version);

// 检查支持的扩展
const char* extensions = (const char*)glGetString(GL_EXTENSIONS);
NSLog(@"OpenGL ES Extensions: %s", extensions);
```

### 问题 2: 纹理加载失败

**原因**: 纹理路径错误

**解决方案**:
```cpp
// 检查纹理路径
std::string path = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename("texture.png");
if (path.empty()) {
    NSLog(@"Texture file not found");
    return false;
}
```

### 问题 3: 网络连接失败

**原因**: 网络权限未设置

**解决方案**:
```xml
<!-- Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 参考资料

- [公共约束](../references/common-constraints.md)
- [性能优化指南](../references/performance-guide.md)
- [跨平台最佳实践](../references/cross-platform-best-practices.md)

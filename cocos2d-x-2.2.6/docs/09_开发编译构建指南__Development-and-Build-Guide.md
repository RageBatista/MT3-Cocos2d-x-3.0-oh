# 开发编译构建指南 (Development and Build Guide)

## 目录 (Table of Contents)

- [环境要求](#环境要求-environment-requirements)
- [Windows 平台配置](#windows-平台配置-windows-platform-configuration)
- [Linux 平台配置](#linux-平台配置-linux-platform-configuration)
- [Android 平台配置](#android-平台配置-android-platform-configuration)
- [iOS 平台配置](#ios-平台配置-ios-platform-configuration)
- [Emscripten 平台配置](#emscripten-平台配置-emscripten-platform-configuration)
- [项目结构](#项目结构-project-structure)
- [编译步骤](#编译步骤-build-steps)
- [常见编译问题](#常见编译问题-common-build-issues)
- [调试配置](#调试配置-debugging-configuration)
- [发布构建](#发布构建-release-build)

---

## 环境要求 (Environment Requirements)

### 硬件要求 (Hardware Requirements)

- **处理器**: Intel Core 2 Duo 或更高
- **内存**: 最低 2GB RAM，推荐 4GB 或更高
- **硬盘**: 至少 5GB 可用空间
- **显卡**: 支持 DirectX 9.0c 或更高

### 软件要求 (Software Requirements)

- **操作系统**: Windows 7 或更高版本
- **开发工具**: Visual Studio 2010 (推荐) 或 Visual Studio 2008
  - Visual Studio 2010 安装路径: `D:\Program Files (x86)\Microsoft Visual Studio 12.0.0`
  - Visual Studio 2008 安装路径: `D:\Program Files (x86)\Microsoft Visual Studio 9.0`
- **Windows SDK**: Windows 7.1 SDK 或更高
- **Python**: Python 2.7.x (用于构建脚本)

---

## Windows 平台配置 (Windows Platform Configuration)

### Visual Studio 2010 配置 (Visual Studio 2010 Configuration)

### 安装路径 (Installation Path)

确保 Visual Studio 2010 安装在以下路径：

```
D:\Program Files (x86)\Microsoft Visual Studio 12.0.0
```

### 环境变量配置 (Environment Variables)

配置以下环境变量：

```batch
set VS100COMNTOOLS=D:\Program Files (x86)\Microsoft Visual Studio 12.0.0\Common7\Tools\
set PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 12.0.0\VC\bin
set INCLUDE=%INCLUDE%;D:\Program Files (x86)\Microsoft Visual Studio 12.0.0\VC\include
set LIB=%LIB%;D:\Program Files (x86)\Microsoft Visual Studio 12.0.0\VC\lib
```

### Visual Studio 项目设置 (Visual Studio Project Settings)

#### 平台工具集 (Platform Toolset)

设置为 **Visual Studio 2010 (v100)**

#### 字符集 (Character Set)

设置为 **使用多字节字符集 (Use Multi-Byte Character Set)**

#### C++ 语言标准 (C++ Language Standard)

设置为 **C++11**

---

## Linux 平台配置 (Linux Platform Configuration)

### 软件要求 (Software Requirements)

- **操作系统**: Ubuntu 12.04 或更高版本
- **编译器**: GCC 4.6 或更高版本
- **构建工具**: CMake 2.8 或更高版本
- **依赖库**:
  - OpenGL
  - OpenGL ES
  - FreeType
  - libpng
  - libjpeg
  - libxml2
  - zlib
  - pthread

### 环境变量配置 (Environment Variables)

```bash
# 设置编译器路径
export CC=gcc
export CXX=g++

# 设置构建工具路径
export CMAKE=/usr/bin/cmake

# 设置库路径
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

### 编译步骤 (Build Steps)

```bash
# 1. 进入项目目录
cd cocos2d-x

# 2. 创建构建目录
mkdir build
cd build

# 3. 配置构建
cmake .. -DCMAKE_BUILD_TYPE=Debug

# 4. 编译
make -j4

# 5. 安装
sudo make install
```

---

## Android 平台配置 (Android Platform Configuration)

### 软件要求 (Software Requirements)

- **操作系统**: Windows、Linux 或 macOS
- **开发工具**: Android NDK r8 或更高版本
- **SDK**: Android SDK r20 或更高版本
- **JDK**: JDK 6 或更高版本
- **构建工具**: Apache Ant 1.8 或更高版本

### 环境变量配置 (Environment Variables)

```bash
# 设置 Android SDK 路径
export ANDROID_SDK=/path/to/android-sdk

# 设置 Android NDK 路径
export ANDROID_NDK=/path/to/android-ndk

# 设置 JDK 路径
export JAVA_HOME=/path/to/jdk

# 添加工具到 PATH
export PATH=$PATH:$ANDROID_SDK/tools:$ANDROID_SDK/platform-tools:$ANDROID_NDK:$JAVA_HOME/bin

# 设置目标平台
export ANDROID_TARGET=android-14

# 设置架构
export ANDROID_ABI=armeabi-v7a
```

### 编译步骤 (Build Steps)

```bash
# 1. 创建 Android 项目
./create-android-project.sh

# 2. 进入项目目录
cd proj.android

# 3. 编译
./build_native.sh

# 4. 生成 APK
ant debug
# 或
ant release
```

---

## iOS 平台配置 (iOS Platform Configuration)

### 软件要求 (Software Requirements)

- **操作系统**: macOS 10.7 或更高版本
- **开发工具**: Xcode 4.6 或更高版本
- **SDK**: iOS SDK 6.0 或更高版本
- **证书**: iOS 开发者证书

### Xcode 项目配置 (Xcode Project Configuration)

#### 项目设置 (Project Settings)

1. 打开 Xcode 项目文件
2. 选择项目 -> Build Settings
3. 配置以下设置：

**Base SDK**: 设置为 **Latest iOS (iOS 6.0)**

**Deployment Target**: 设置为 **iOS 5.0**

**Architecture**: 设置为 **armv7** 或 **armv7s**

**Valid Architectures**: 设置为 **armv7, armv7s**

**C++ Language Dialect**: 设置为 **C++11**

**C++ Standard Library**: 设置为 **libc++**

#### 代码签名 (Code Signing)

1. 选择项目 -> Build Settings
2. 找到 Code Signing 部分
3. 配置以下设置：

**Code Signing Identity**: 选择你的开发者证书

**Provisioning Profile**: 选择正确的配置文件

### 编译步骤 (Build Steps)

```bash
# 1. 打开 Xcode 项目
open cocos2d-ios.xcodeproj

# 2. 选择目标设备
# - iOS Simulator: 模拟器
# - iOS Device: 真机

# 3. 选择构建配置
# - Debug: 调试版本
# - Release: 发布版本

# 4. 编译
# Product -> Build
# 或按 Command + B

# 5. 运行
# Product -> Run
# 或按 Command + R
```

---

## Emscripten 平台配置 (Emscripten Platform Configuration)

### 软件要求 (Software Requirements)

- **操作系统**: Windows、Linux 或 macOS
- **编译器**: Emscripten 1.29.0 或更高版本
- **Python**: Python 2.7.x
- **Node.js**: Node.js 0.10 或更高版本（可选）

### 环境变量配置 (Environment Variables)

```bash
# 设置 Emscripten 路径
export EMSCRIPTEN=/path/to/emsdk

# 添加工具到 PATH
export PATH=$PATH:$EMSCRIPTEN

# 设置编译器
export CC=emcc
export CXX=em++

# 设置缓存目录
export EMCC_CACHE=/tmp/emscripten_cache
```

### 编译步骤 (Build Steps)

```bash
# 1. 进入项目目录
cd cocos2d-x

# 2. 配置 Emscripten
source /path/to/emsdk/emsdk_env.sh

# 3. 编译
emcc -s USE_SDL=2 -s USE_WEBGL=1 \
     -I./cocos2dx \
     -I./cocos2dx/include \
     -I./cocos2dx/platform \
     -I./external \
     -o output.html \
     main.cpp

# 4. 运行
# 在浏览器中打开 output.html
python -m SimpleHTTPServer 8000
# 然后访问 http://localhost:8000/output.html
```

---

## 项目结构 (Project Structure)

### 解决方案文件 (Solution Files)

```
cocos2d-win32.vc2010.sln    # 主解决方案文件 (推荐)
cocos2d-win32.vc2008.sln    # Visual Studio 2008 解决方案文件
```

### 主要项目 (Main Projects)

| 项目名称 | 描述 | 输出类型 |
|---------|------|---------|
| libcocos2d | Cocos2d-x 核心库 | 静态库 |
| libcocosdenshion | 音频引擎 | 静态库 |
| libBox2D | 物理引擎 | 静态库 |
| libCocosDenshion | 音频引擎封装 | 静态库 |
| libExtensions | 扩展库 | 静态库 |
| HelloCpp | 示例项目 | 可执行文件 |

### 源代码目录 (Source Code Directories)

```
cocos2dx/          # 核心引擎代码
  actions/         # 动作系统
  base_nodes/      # 基础节点
  sprite_nodes/    # 精灵节点
  label_nodes/     # 标签节点
  layer_nodes/     # 层节点
  scene_nodes/     # 场景节点
  misc_nodes/      # 其他节点
  platform/        # 平台相关代码
  support/         # 支持类
  shader/          # 着色器
  text_input_node/ # 文本输入
  touch_dispatcher/ # 触摸分发
  keypad_dispatcher/ # 键盘分发
  accelerometer/   # 加速度计
  script_support/  # 脚本支持
  cocos2d.h        # 主头文件

platform/          # 平台特定代码
  win32/           # Windows 平台
    CCApplication-win32.h
    CCGL-win32.h
    CCEGLView-win32.h

extensions/        # 扩展库
  CocosBuilder/
  GUI/
  network/
  physics_nodes/

external/          # 外部库
  Box2D/           # Box2D 物理引擎
  chipmunk/        # Chipmunk 物理引擎
  lua/             # Lua 脚本引擎
  scripting/       # 脚本支持
  zlib/            # 压缩库
```

---

## 编译步骤 (Build Steps)

### 步骤 1: 打开解决方案 (Step 1: Open Solution)

1. 启动 Visual Studio 2010
2. 打开文件: `cocos2d-win32.vc2010.sln`

### 步骤 2: 选择构建配置 (Step 2: Select Build Configuration)

选择以下配置之一：

- **Debug**: 调试版本，包含调试符号
- **Release**: 发布版本，优化性能

选择平台：

- **Win32**: 32位 Windows
- **x64**: 64位 Windows

### 步骤 3: 清理解决方案 (Step 3: Clean Solution)

```batch
# 在 Visual Studio 中
Build -> Clean Solution

# 或使用命令行
msbuild cocos2d-win32.vc2010.sln /t:Clean /p:Configuration=Debug /p:Platform=Win32
```

### 步骤 4: 构建解决方案 (Step 4: Build Solution)

```batch
# 在 Visual Studio 中
Build -> Build Solution

# 或使用命令行
msbuild cocos2d-win32.vc2010.sln /t:Build /p:Configuration=Debug /p:Platform=Win32
```

### 步骤 5: 验证构建 (Step 5: Verify Build)

检查以下内容：

1. 所有项目编译成功，无错误
2. 输出目录包含生成的库文件
3. 示例项目可以正常运行

---

## 常见编译问题 (Common Build Issues)

### 问题 1: 找不到头文件 (Issue 1: Cannot Find Header Files)

**症状**: 编译错误 "fatal error C1083: 无法打开包括文件"

**解决方案**:

```cpp
// 检查项目属性中的包含目录
// 项目 -> 属性 -> C/C++ -> 常规 -> 附加包含目录

// 确保包含以下路径:
$(ProjectDir);$(ProjectDir)..\..\cocos2dx;$(ProjectDir)..\..\cocos2dx\include;$(ProjectDir)..\..\cocos2dx\platform;$(ProjectDir)..\..\cocos2dx\platform\win32;$(ProjectDir)..\..\cocos2dx\kazmath\include;$(ProjectDir)..\..\external;$(ProjectDir)..\..\external\chipmunk\include\chipmunk;
```

### 问题 2: 链接错误 (Issue 2: Linker Errors)

**症状**: 链接错误 "unresolved external symbol"

**解决方案**:

```cpp
// 检查项目属性中的库目录
// 项目 -> 属性 -> 链接器 -> 常规 -> 附加库目录

// 确保包含以下路径:
$(OutDir);$(ProjectDir)..\..\external\lib\win32

// 检查附加依赖项
// 项目 -> 属性 -> 链接器 -> 输入 -> 附加依赖项

// 确保包含以下库:
libcocos2d.lib;libCocosDenshion.lib;glew32.lib;opengl32.lib;glu32.lib;winmm.lib;ws2_32.lib;iphlpapi.lib
```

### 问题 3: Visual Studio 版本不匹配 (Issue 3: Visual Studio Version Mismatch)

**症状**: 编译错误 "Platform Toolset not found"

**解决方案**:

```batch
# 确认 Visual Studio 2010 安装路径
D:\Program Files (x86)\Microsoft Visual Studio 12.0.0

# 设置平台工具集为 Visual Studio 2010 (v100)
# 项目 -> 属性 -> 配置属性 -> 常规 -> 平台工具集
# 选择: Visual Studio 2010 (v100)
```

### 问题 4: 字符集错误 (Issue 4: Character Set Errors)

**症状**: 编译错误 "cannot convert from 'const char *' to 'LPCWSTR'"

**解决方案**:

```cpp
// 项目 -> 属性 -> 配置属性 -> 项目默认值 -> 字符集
// 选择: 使用多字节字符集 (Use Multi-Byte Character Set)
```

---

## 调试配置 (Debugging Configuration)

### 调试符号 (Debug Symbols)

确保在 Debug 配置中生成调试符号：

```batch
# 项目 -> 属性 -> C/C++ -> 常规 -> 调试信息格式
# 选择: 程序数据库 (/Zi)

# 项目 -> 属性 -> 链接器 -> 调试 -> 生成调试信息
# 选择: 是 (/DEBUG)
```

### 断点设置 (Breakpoint Settings)

在 Visual Studio 中设置断点：

```cpp
// 在代码中设置断点
void HelloWorld::menuCloseCallback(CCObject* pSender)
{
    // 在此行设置断点
    CCDirector::sharedDirector()->end();
}
```

### 调试输出 (Debug Output)

使用 CCLog 输出调试信息：

```cpp
// 输出调试信息
CCLog("Debug message: %s", "Hello World");

// 输出变量值
int value = 42;
CCLog("Value: %d", value);

// 输出坐标信息
CCPoint pos = ccp(100, 200);
CCLog("Position: (%.2f, %.2f)", pos.x, pos.y);
```

---

## 发布构建 (Release Build)

### 优化设置 (Optimization Settings)

```cpp
// 项目 -> 属性 -> C/C++ -> 优化
// 选择: 最大化速度 (/O2)

// 项目 -> 属性 -> C/C++ -> 代码生成
// 运行时库: 多线程 DLL (/MD)
```

### 去除调试信息 (Remove Debug Information)

```cpp
// 项目 -> 属性 -> 链接器 -> 调试 -> 生成调试信息
// 选择: 否

// 项目 -> 属性 -> 链接器 -> 调试 -> 生成程序数据库文件
// 清空此字段
```

### 发布构建命令 (Release Build Command)

```batch
# 使用命令行构建 Release 版本
msbuild cocos2d-win32.vc2010.sln /t:Build /p:Configuration=Release /p:Platform=Win32 /m
```

---

## 快速参考 (Quick Reference)

### 常用编译命令 (Common Build Commands)

```batch
# 清理并构建 Debug 版本
msbuild cocos2d-win32.vc2010.sln /t:Clean,Build /p:Configuration=Debug /p:Platform=Win32

# 清理并构建 Release 版本
msbuild cocos2d-win32.vc2010.sln /t:Clean,Build /p:Configuration=Release /p:Platform=Win32

# 重新构建所有项目
msbuild cocos2d-win32.vc2010.sln /t:Rebuild /p:Configuration=Debug /p:Platform=Win32

# 并行构建 (使用多核)
msbuild cocos2d-win32.vc2010.sln /t:Build /p:Configuration=Debug /p:Platform=Win32 /m:4
```

### 项目属性检查清单 (Project Properties Checklist)

- [ ] 平台工具集: Visual Studio 2010 (v100)
- [ ] 字符集: 使用多字节字符集
- [ ] C++ 语言标准: C++11
- [ ] 包含目录: 正确配置
- [ ] 库目录: 正确配置
- [ ] 附加依赖项: 正确配置
- [ ] 运行时库: Debug (/MTd) 或 Release (/MD)

---

## 相关文档 (Related Documentation)

- [最佳实践指南](10_最佳实践指南__Best-Practices-Guide.md)
- [故障排除指南](11_故障排除指南__Troubleshooting-Guide.md)
- [核心类架构](02_核心类架构__Core-Classes-Architecture.md)
- [关键实现细节](04_关键实现细节与代码示例__Key-Implementation-Details.md)
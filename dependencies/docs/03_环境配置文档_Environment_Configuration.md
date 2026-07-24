# 03_环境配置文档_Environment_Configuration

> **项目名称**: MT3 Dependencies Environment Setup
> **文档版本**: 1.0
> **更新日期**: 2026-04-22
> **文档类型**: 环境配置文档

---

## 目录

1. [系统要求](#1-系统要求)
2. [开发环境配置](#2-开发环境配置)
3. [编译环境配置](#3-编译环境配置)
4. [运行环境配置](#4-运行环境配置)
5. [依赖库配置](#5-依赖库配置)
6. [环境变量配置](#6-环境变量配置)
7. [配置文件说明](#7-配置文件说明)
8. [故障排除](#8-故障排除)

---

## 1. 系统要求

### 1.1 硬件要求

| 组件 | 最低配置 | 推荐配置 |
|------|----------|----------|
| **CPU** | Intel Core i3 或同等 | Intel Core i5 或更高 |
| **内存** | 4GB | 8GB 或更多 |
| **硬盘** | 10GB 可用空间 | 20GB 或更多 |
| **网络** | 100Mbps | 1Gbps |

### 1.2 操作系统支持

| 平台 | 版本 | 支持状态 |
|------|------|----------|
| **Windows** | Windows 7 SP1+ | ✅ 完全支持 |
| **Windows** | Windows 10/11 | ✅ 完全支持 |
| **Windows** | Windows Server 2012+ | ✅ 完全支持 |
| **macOS** | 10.12+ | ✅ 部分支持 |
| **Linux** | Ubuntu 16.04+ | ⚠️ 实验性支持 |

### 1.3 软件依赖

| 软件 | 版本 | 用途 |
|------|------|------|
| **Visual Studio** | 2013 (v120) | Windows编译（必需） |
| **CMake** | 3.6+ | 跨平台构建（推荐） |
| **Git** | 2.0+ | 版本控制（推荐） |
| **Python** | 2.7 或 3.6+ | 脚本工具（可选） |

---

## 2. 开发环境配置

### 2.1 Windows开发环境

#### 2.1.1 安装Visual Studio 2013

**步骤**:
1. 下载 Visual Studio 2013 安装程序
2. 选择 "Visual C++" 工作负载
3. 安装 Windows SDK 8.1
4. 确保安装 "MSVC v120" 工具集

**验证安装**:
```cmd
# 打开 "Developer Command Prompt for VS2013"
cl
# 应显示编译器版本信息
```

#### 2.1.2 安装CMake

**步骤**:
1. 下载 CMake 安装程序: https://cmake.org/download/
2. 运行安装程序
3. 选择 "Add CMake to the system PATH"
4. 完成安装

**验证安装**:
```cmd
cmake --version
# 应显示 CMake 版本信息
```

#### 2.1.3 配置环境变量

**必需的环境变量**:
```cmd
# Visual Studio 2013（根据实际安装位置调整）
VS120COMNTOOLS=D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\

# CMake (如果未自动添加到PATH）
CMAKE_PATH=C:\Program Files\CMake\bin

# 项目根目录
MT3_ROOT=E:\MT3\dependencies
```

**设置方法**:
1. 右键 "计算机" → "属性"
2. 点击 "高级系统设置"
3. 点击 "环境变量"
4. 在 "系统变量" 中添加或编辑上述变量

**注意事项**:
- `VS120COMNTOOLS` 路径需要根据实际安装位置调整
- 如果 Visual Studio 安装在其他位置（如 `D:\Program Files (x86)\Microsoft Visual Studio 12.0`），需要相应修改路径
- 可以通过以下命令查找 Visual Studio 安装位置：
  ```cmd
  dir "C:\Program Files (x86)\Microsoft Visual Studio" /b
  dir "D:\Program Files (x86)\Microsoft Visual Studio" /b
  ```
- 如果使用其他版本的 Visual Studio，需要使用对应的环境变量：
  - Visual Studio 2010: `VS100COMNTOOLS`
  - Visual Studio 2012: `VS110COMNTOOLS`
  - Visual Studio 2013: `VS120COMNTOOLS`
  - Visual Studio 2015: `VS140COMNTOOLS`
  - Visual Studio 2017: `VS150COMNTOOLS`
  - Visual Studio 2019: `VS160COMNTOOLS`

### 2.2 macOS开发环境

#### 2.2.1 安装Xcode

**步骤**:
1. 从 App Store 安装 Xcode
2. 安装 Xcode Command Line Tools
```bash
xcode-select --install
```

#### 2.2.2 安装Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2.2.3 安装依赖

```bash
# 安装CMake
brew install cmake

# 安装其他工具
brew install git python3
```

### 2.3 Linux开发环境

#### 2.3.1 Ubuntu/Debian

```bash
# 更新包管理器
sudo apt-get update

# 安装编译工具
sudo apt-get install build-essential cmake git

# 安装依赖库
sudo apt-get install libpng-dev libfreetype6-dev libogg-dev libvorbis-dev
```

#### 2.3.2 CentOS/RHEL

```bash
# 安装编译工具
sudo yum groupinstall "Development Tools"
sudo yum install cmake git

# 安装依赖库
sudo yum install libpng-devel freetype-devel libogg-devel libvorbis-devel
```

---

## 3. 编译环境配置

### 3.1 LJFilePack编译配置

#### 3.1.1 使用Visual Studio

**步骤**:
1. 打开 `LJFilePack/LJFilePack.sln`
2. 选择配置 (Debug/Release)
3. 选择平台 (Win32/x64)
4. 点击 "生成" → "生成解决方案"

**输出目录**:
- Debug: `LJFilePack/Debug/`
- Release: `LJFilePack/Release/`

**输出文件**:
- `LJFilePack.exe` - 主程序
- `LJFilePack.pdb` - 调试符号（仅Debug）

#### 3.1.2 使用MSBuild命令行

```cmd
# 设置Visual Studio环境
call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86

# 编译Debug版本
msbuild LJFilePack.sln /p:Configuration=Debug /p:Platform=Win32 /m

# 编译Release版本
msbuild LJFilePack.sln /p:Configuration=Release /p:Platform=Win32 /m
```

### 3.2 SuperLJFilePackUnpack编译配置

#### 3.2.1 使用CMake

**步骤**:
1. 创建构建目录
```cmd
cd SuperLJFilePackUnpack
mkdir build
cd build
```

2. 生成项目文件
```cmd
# Visual Studio 2013
cmake .. -G "Visual Studio 12 2013"

# 也可使用更高版本 VS 生成器
cmake .. -G "Visual Studio 14 2015"
cmake .. -G "Visual Studio 16 2019" -A x64
```

3. 编译
```cmd
# Debug
cmake --build . --config Debug

# Release
cmake --build . --config Release

# 多线程编译
cmake --build . --config Release --parallel 4
```

**输出目录**:
- `build/bin/` - 可执行文件
- `build/lib/` - 库文件

#### 3.2.2 CMake配置选项

**常用选项**:
```cmd
# 启用GUI（需要wxWidgets）
cmake .. -DBUILD_GUI=ON

# 启用测试
cmake .. -DBUILD_TESTS=ON

# 启用示例
cmake .. -DBUILD_EXAMPLES=ON

# 设置C++标准
cmake .. -DCMAKE_CXX_STANDARD=11

# 设置安装前缀
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local

# 设置wxWidgets根目录（MT3项目本地配置）
cmake .. -DWXWIDGETS_ROOT_DIR="../wxWidgets-3.0.5"
```

**wxWidgets配置说明**:
- SuperLJFilePackUnpack 支持本地 wxWidgets 配置
- 默认路径: `../wxWidgets-3.0.5`
- 如果 wxWidgets 不在默认位置，需要设置 `WXWIDGETS_ROOT_DIR`
- 静态链接配置: 不定义 `WXUSINGDLL`
- Unicode 配置: 定义 `UNICODE` 和 `_UNICODE`

**完整示例**:
```cmd
# Windows + Visual Studio 2019 + wxWidgets
cmake .. ^
    -G "Visual Studio 16 2019" ^
    -A x64 ^
    -DBUILD_GUI=ON ^
    -DBUILD_TESTS=ON ^
    -DBUILD_EXAMPLES=ON ^
    -DWXWIDGETS_ROOT_DIR="../wxWidgets-3.0.5" ^
    -DCMAKE_CXX_STANDARD=11 ^
    -DCMAKE_BUILD_TYPE=Release

# Linux + GCC + wxWidgets
cmake .. ^
    -G "Unix Makefiles" ^
    -DBUILD_GUI=ON ^
    -DBUILD_TESTS=ON ^
    -DBUILD_EXAMPLES=ON ^
    -DCMAKE_CXX_STANDARD=11 ^
    -DCMAKE_BUILD_TYPE=Release
```

**构建输出**:
- `build/bin/` - 可执行文件
  - `ljfp-unpack.exe` - CLI解包工具
  - `ljfp-unpack-diag.exe` - 诊断CLI
  - `LJFilePackUnpacker.exe` - GUI解包工具（如果启用GUI）
  - `ljfp-test.exe` - 单元测试（如果启用测试）
- `build/lib/` - 库文件
  - `SuperLJFilePackUnpack.lib` - 静态库

说明：

- `build/` 是本地生成目录，不应作为仓库事实目录长期保留
- `BUILD_CLI` 是废弃兼容开关，不会生成旧主程序

### 3.3 BinLayoutConvert编译配置

#### 3.3.1 使用Visual Studio

**步骤**:
1. 打开 `BinLayoutConvert/BinLayoutConvert.sln`
2. 选择配置 (Debug/Release)
3. 选择平台 (Win32/x64)
4. 点击 "生成" → "生成解决方案"

**输出目录**:
- `BinLayoutConvert/Release/` - Release输出
- `BinLayoutConvert/Debug/` - Debug输出

**输出文件**:
- `BinLayoutConvert.exe` - CLI工具
- `BinLayoutStudio.exe` - GUI工具

#### 3.3.2 使用MSBuild命令行

```cmd
# 设置Visual Studio环境
call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86

# 编译整个解决方案
msbuild BinLayoutConvert.sln /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /m /nologo
```

### 3.4 wxWidgets编译配置

#### 3.4.1 使用Visual Studio

**步骤**:
1. 打开 `wxWidgets-3.0.5/build/msw/wx_vc12.sln`
2. 选择配置 (Debug/Release)
3. 选择平台 (Win32/x64)
4. 选择要编译的库（如 `wx_base`, `wx_core`, `wx_adv` 等）
5. 点击 "生成" → "生成解决方案"

**输出目录**:
- `wxWidgets-3.0.5/lib/vc_lib/` - 静态库
- `wxWidgets-3.0.5/lib/vc_dll/` - 动态库

**编译选项**:
- `wxUSE_UNICODE=1` - 启用Unicode
- `wxUSE_DEBUG_FLAG=1` - Debug模式
- `wxUSE_EXCEPTIONS=1` - 启用异常

---

## 4. 运行环境配置

### 4.1 Windows运行环境

#### 4.1.1 DLL依赖

**必需的DLL**:
- `msvcr120.dll` - Visual C++ Runtime
- `msvcp120.dll` - Visual C++ Standard Library
- 其他项目特定的DLL

**解决方案**:
1. 将DLL复制到可执行文件目录
2. 或安装 Visual C++ Redistributable
3. 或将DLL路径添加到PATH

#### 4.1.2 路径配置

**LJFilePack**:
- 配置文件: `LJFilePackOption.xml`
- 输入目录: `Root/`
- 输出目录: `IOS_Pack/`, `Android_Pack/`, `IOS_File/`, `Android_File/`

**SuperLJFilePackUnpack**:
- 输入目录: 包含 `.ljpi` 或 `.ljzip` 的目录
- 输出目录: 解包文件输出目录

**BinLayoutConvert**:
- 输入文件: `.layout` 文件（XML或BinLayout）
- 输出文件: 转换后的文件

### 4.2 macOS/Linux运行环境

#### 4.2.1 库路径

**设置DYLD_LIBRARY_PATH (macOS)**:
```bash
export DYLD_LIBRARY_PATH=/path/to/lib:$DYLD_LIBRARY_PATH
```

**设置LD_LIBRARY_PATH (Linux)**:
```bash
export LD_LIBRARY_PATH=/path/to/lib:$LD_LIBRARY_PATH
```

#### 4.2.2 权限配置

**可执行权限**:
```bash
chmod +x SuperLJFilePackUnpack
chmod +x BinLayoutConvert
```

---

## 5. 依赖库配置

### 5.1 LJFilePack依赖

**内部依赖**:
- `LJFP_SMS4.h` - SMS4加密算法
- `LJFP_MiniZ.h` - MiniZ压缩库
- `LJFP_CRC32.h` - CRC32校验算法
- `LJFP_XML.h` - XML解析
- `LJFP_FileUtil.h` - 文件工具
- `LJFP_StringUtil.h` - 字符串工具

**外部依赖**:
- 无（完全自包含）

### 5.2 SuperLJFilePackUnpack依赖

**内部依赖**:
- `libs/ljfp/` - LJFilePack依赖库
  - `LJFP_SMS4.h`
  - `LJFP_MiniZ.h`
  - `LJFP_CRC32.h`
  - `LJFP_FileUtil.h`
  - `LJFP_StringUtil.h`

**外部依赖**:
- C++11标准库
- CMake 3.6+

### 5.3 BinLayoutConvert依赖

**内部依赖**:
- `cegui/CEGUI/` - CEGUI框架
  - `BinLayout/` - 二进制布局模块
  - `src/` - CEGUI核心
  - `include/` - 头文件

**外部依赖**:
- `wxWidgets-3.0.5/` - wxWidgets GUI框架（可选，仅GUI工具需要）
- Windows SDK 8.1（Windows平台）

### 5.4 CEGUI依赖

**必需依赖**:
- `freetype-2.4.9/` - 字体渲染
- `libpng-1.4.5/` - PNG图像
- `SILLY-0.1.0/` - 图像加载

**可选依赖**:
- `wxWidgets-3.0.5/` - GUI后端
- `OpenGL` - 渲染后端
- `Direct3D` - 渲染后端（Windows）

### 5.5 音频库依赖

**libogg**:
- 无外部依赖

**libvorbis**:
- `libogg` - Ogg容器支持

### 5.6 调试工具依赖

**VLD** (Visual Leak Detector):
- Visual Studio 2013+
- Windows平台

**Breakpad**:
- 无特殊依赖
- 跨平台支持

---

## 6. 环境变量配置

### 6.1 必需环境变量

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `VS120COMNTOOLS` | Visual Studio 2013 Common Tools路径 | Windows编译必需 |
| `MT3_ROOT` | 项目根目录路径 | 可选，用于脚本 |

### 6.2 可选环境变量

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `PATH` | 包含可执行文件路径 | 运行时查找DLL |
| `LD_LIBRARY_PATH` | 库文件路径 | Linux运行时 |
| `DYLD_LIBRARY_PATH` | 库文件路径 | macOS运行时 |
| `CMAKE_PREFIX_PATH` | CMake查找路径 | CMake构建 |

### 6.3 配置示例

**Windows PowerShell**:
```powershell
# 设置项目根目录
$env:MT3_ROOT = "E:\MT3\dependencies"

# 添加到PATH
$env:PATH = "$env:MT3_ROOT\LJFilePack\Release;$env:PATH"
$env:PATH = "$env:MT3_ROOT\SuperLJFilePackUnpack\build\bin;$env:PATH"
$env:PATH = "$env:MT3_ROOT\BinLayoutConvert\Release;$env:PATH"
```

**Linux/macOS Bash**:
```bash
# 设置项目根目录
export MT3_ROOT=/path/to/dependencies

# 添加到PATH
export PATH=$MT3_ROOT/LJFilePack:$PATH
export PATH=$MT3_ROOT/SuperLJFilePackUnpack/build/bin:$PATH
export PATH=$MT3_ROOT/BinLayoutConvert:$PATH

# 设置库路径
export LD_LIBRARY_PATH=$MT3_ROOT/lib:$LD_LIBRARY_PATH
```

---

## 7. 配置文件说明

### 7.1 LJFilePack配置文件

**文件路径**: `LJFilePack/LJFilePackOption.xml`

**结构**:
```xml
<Root>
    <Channel Count="2">
        <!-- 渠道配置 -->
        <0 Description="IOS_Locojoy">
            <ChannelInfo Channel="0" ChannelCaption="IOS_Locojoy"/>
        </0>
        <1 Description="Android_Locojoy">
            <ChannelInfo Channel="0" ChannelCaption="Android_Locojoy"/>
        </1>
    </Channel>

    <Code Count="1">
        <!-- 加密配置 -->
        <0 Description="Some texts">
            <UnCodeFileName>0</UnCodeFileName>
            <UnCodeFileNameFull 0="cfg/mount_android.xml" 1="cfg/mount_ios.xml" 2="cfg/mount_win.xml">3</UnCodeFileNameFull>
            <UnCodeFileType 0="ogg" 1="mp3" 2="mp4" 3="ini">4</UnCodeFileType>
        </0>
    </Code>

    <Compress Count="1">
        <!-- 压缩配置 -->
        <0 Description="Some texts">
            <UnCompressFileName>0</UnCompressFileName>
            <UnCompressFileNameFull 0="cfg/mount_android.xml" 1="cfg/mount_ios.xml" 2="cfg/mount_win.xml">3</UnCompressFileNameFull>
            <UnCompressFileType 0="ogg" 1="mp3" 2="mp4" 3="ini" 4="png">5</UnCompressFileType>
        </0>
    </Compress>

    <Filter Count="1">
        <!-- 过滤配置 -->
        <0 Description="Some texts">
            <FilterDirName>0</FilterDirName>
            <FilterDirNameFull 0="config/autoconfig">1</FilterDirNameFull>
            <FilterFileName>0</FilterFileName>
            <FilterFileNameFull>0</FilterFileNameFull>
            <FilterFileType 0="db" 1="ilk" 2="pdb" 3="exe">4</FilterFileType>
        </0>
    </Filter>

    <IO Count="4">
        <!-- 输入输出配置 -->
        <0 Description="Some texts" FindPath="Root/" OutputPath="IOS_Pack/" OutputType="Pack"/>
        <1 Description="Some texts" FindPath="Root/" OutputPath="IOS_File/" OutputType="File"/>
        <2 Description="Some texts" FindPath="Root/" OutputPath="Android_Pack/" OutputType="Pack"/>
        <3 Description="Some texts" FindPath="Root/" OutputPath="Android_File/" OutputType="File"/>
    </IO>

    <Pack Count="1">
        <!-- 打包配置 -->
        <0 Description="Some texts" MaxSize="52428800">
            <UnPackFileName>0</UnPackFileName>
            <UnPackFileNameFull 0="cfg/mount_android.xml" 1="cfg/mount_ios.xml" 2="cfg/mount_win.xml">3</UnPackFileNameFull>
            <UnPackFileType 0="ogg" 1="mp3" 2="mp4" 3="ini">4</UnPackFileType>
        </0>
    </Pack>

    <Update Count="2">
        <!-- 更新配置 -->
        <0 Description="IOS">
            <URLInfo AppURL="http://store.apple.com/123/456/789/0" Count="1">
                <0 Network="lan" System="ios" URL="http://192.168.29.164:8090/ios/"/>
            </URLInfo>
        </0>
        <1 Description="Android">
            <URLInfo AppURL="http://store.google.com/123/456/789/0" Count="1">
                <0 Network="lan" System="android" URL="http://192.168.29.164:8090/android/"/>
            </URLInfo>
        </1>
    </Update>

    <Version Count="2">
        <!-- 版本配置 -->
        <0 Description="IOS">
            <VersionInfo VersionCaption="0.0.1" VersionCaptionBase="0.0.1" VersionCaptionMinimum="0.0.1" VersionDonotCheck="0"/>
        </0>
        <1 Description="Android">
            <VersionInfo VersionCaption="0.0.1" VersionCaptionBase="0.0.1" VersionCaptionMinimum="0.0.1" VersionDonotCheck="0"/>
        </1>
    </Version>
</Root>
```

**配置项说明**:

| 节点 | 说明 |
|------|------|
| `Channel` | 渠道配置（iOS/Android） |
| `Code` | 加密文件配置 |
| `Compress` | 压缩文件配置 |
| `Filter` | 过滤规则配置 |
| `IO` | 输入输出路径配置 |
| `Pack` | 打包配置 |
| `Update` | 更新服务器配置 |
| `Version` | 版本信息配置 |

### 7.2 VLD配置文件

**文件路径**: `vld/prebuilt/win32/vld.ini`

**常用配置**:
```ini
[General]
ReportTo=Debugger
ReportFile=vld_report.txt
MaxDataDump=256
MaxTraceFrames=32

[Options]
Enabled=true
ForceInclude=true
```

### 7.3 wxWidgets配置

**编译配置**:
- `setup.h` - 编译时配置
- `wx/msw/setup0.h` - Windows平台配置

**常用选项**:
```cpp
#define wxUSE_UNICODE 1
#define wxUSE_DEBUG_FLAG 1
#define wxUSE_EXCEPTIONS 1
#define wxUSE_THREADS 1
#define wxUSE_STL 1
```

---

## 8. 故障排除

### 8.1 编译问题

#### 问题1: 找不到Visual Studio

**症状**:
```
error MSB6003: The specified task executable "cl.exe" could not be run.
```

**解决方案**:
```cmd
# 设置Visual Studio环境
call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86
```

#### 问题2: CMake找不到编译器

**症状**:
```
CMake Error: CMake was unable to find a build program corresponding to "Visual Studio 12 2013"
```

**解决方案**:
```cmd
# 指定生成器
cmake .. -G "Visual Studio 12 2013"

# 或使用其他版本的Visual Studio
cmake .. -G "Visual Studio 16 2019"
```

#### 问题3: 链接错误

**症状**:
```
error LNK2019: unresolved external symbol
```

**解决方案**:
1. 检查库文件路径
2. 确保所有依赖库已编译
3. 检查库的架构（x86/x64）

### 8.2 运行时问题

#### 问题1: 缺少DLL

**症状**:
```
The program can't start because MSVCR120.dll is missing from your computer.
```

**解决方案**:
1. 安装 Visual C++ Redistributable
2. 或将DLL复制到可执行文件目录
3. 或将DLL路径添加到PATH

#### 问题2: 找不到配置文件

**症状**:
```
Error: Configuration file not found
```

**解决方案**:
1. 确认配置文件路径正确
2. 检查文件权限
3. 使用绝对路径

#### 问题3: 权限错误

**症状**:
```
Error: Permission denied
```

**解决方案**:
1. 以管理员身份运行
2. 检查文件/目录权限
3. 确保输出目录可写

### 8.3 性能问题

#### 问题1: 编译速度慢

**解决方案**:
```cmd
# 使用多线程编译
msbuild solution.sln /m /p:Configuration=Release

# 或使用CMake多线程
cmake --build . --config Release --parallel 4
```

#### 问题2: 运行时性能差

**解决方案**:
1. 使用Release版本
2. 启用编译器优化
3. 使用性能分析工具

---

## 9. 最佳实践

### 9.1 开发环境

1. **使用版本控制**: 使用Git管理代码
2. **定期备份**: 定期备份配置文件
3. **文档记录**: 记录环境配置变更
4. **自动化**: 使用脚本自动化配置过程

### 9.2 编译环境

1. **清理构建**: 定期清理构建目录
2. **增量编译**: 使用增量编译提高速度
3. **并行编译**: 使用多线程加速编译
4. **静态分析**: 启用静态代码分析

### 9.3 运行环境

1. **环境隔离**: 使用虚拟环境隔离依赖
2. **版本管理**: 管理依赖库版本
3. **监控日志**: 监控运行日志
4. **性能监控**: 监控系统资源使用

---

**文档版本**: 1.0
**最后更新**: 2026-01-27
**维护者**: MT3项目组

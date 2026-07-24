---
name: build-troubleshooting
version: 1.1.0
priority: high
category: common
description: |
  MT3编译故障排查技能。涵盖Windows客户端、Android客户端和服务器端编译问题诊断与解决。
  触发词: 编译, 构建, 链接, LNK, MSB, 错误, 依赖, 工具集, v120
allowed-tools:
  - Bash
  - Read
  - Edit
---

# MT3 编译故障排查技能 (Build Troubleshooting Skill)

**版本**: v1.1.0
**最后更新**: 2026-04-11

---

## 🎯 核心知识点

### 1. 强制性约束理解

```yaml
Windows 客户端:
  ❌ 致命错误: 使用 v140/v141/v142
  ✅ 唯一正解: Visual Studio 2013 (v120)

  错误表现:
    - LNK2001: 无法解析的外部符号
    - LNK2019: 无法解析的外部符号
    - 运行时崩溃 (Access Violation)

  根本原因:
    - FireClient.lib 为 v120 编译
    - C++ ABI 在不同编译器版本间不兼容
    - 标准库实现差异 (STL)

Android 客户端:
  ❌ 致命错误: 使用 r10e/GCC、NDK r21+ 或 Gradle
  ✅ 唯一正解: NDK r16 clang + Apache Ant + JDK8

  错误表现:
    - JNI 链接失败
    - 运行时 UnsatisfiedLinkError
    - 符号找不到错误

  根本原因:
    - NDK ABI 兼容性问题
    - Gradle 与 Ant 构建脚本不兼容
    - 历史包袱，迁移成本极高

服务器端:
  ❌ 致命错误: 使用 JDK 9+ / Maven / Gradle
  ✅ 唯一正解: JDK 1.7/1.8 + Apache Ant

  错误表现:
    - 类找不到 (ClassNotFoundException)
    - 方法签名不匹配
    - gnet 编译失败

  根本原因:
    - gnet 框架依赖 JDK 1.7/1.8 API
    - 模块化系统 (JDK 9+) 不兼容
    - Ant 构建脚本历史遗留
```

---

## 🔧 故障诊断流程

### 流程图

```
编译错误
    ↓
┌─────────────────────┐
│ 步骤1: 错误分类     │
└──────┬──────────────┘
       ├─→ 链接错误 (LNK*) → [工具集检查]
       ├─→ 编译错误 (C*) → [头文件检查]
       ├─→ 预编译头错误 (MSB*) → [PCH配置检查]
       └─→ 依赖错误 → [库文件检查]
              ↓
┌─────────────────────┐
│ 步骤2: 定位根因     │
└──────┬──────────────┘
       ├─→ 工具集版本
       ├─→ 依赖库路径
       ├─→ 头文件路径
       └─→ 编译选项
              ↓
┌─────────────────────┐
│ 步骤3: 应用修复     │
└──────┬──────────────┘
       ├─→ 修改项目配置
       ├─→ 重新编译依赖
       ├─→ 清理中间文件
       └─→ 验证修复结果
```

---

## 🧠 自动进化高价值规则（2026-03 回灌）

来源：`.claude/evolution/evolved/skills/backfill-proposals.md`（2026-03-05）。

### 规则 A：LNK 优先检查链（confidence=0.95）

1. 先确认 `PlatformToolset=v120`。
2. 再确认库链接顺序（核心预编译库 → 业务库 → 系统库）。
3. 最后确认预编译库 ABI 与 CRT 一致（避免 `v140+`、`/MD` 与 `/MT` 混用）。

### 规则 B：MSB 预检先行（confidence=0.81）

重新构建前必须先做工具链预检，任一失败先修环境再编译：

- Windows：`vcvarsall.bat`、`cl`、`MSBuild 12.0`
- Android：`java/javac (JDK8)`、`ndk-build (r16)`、`ant`
- Server：`java/javac`、`ant`

### 规则 C：首错优先（confidence=0.84）

- 只围绕第一条 `error` 排查。
- 先抓取“首错前后 30 行上下文”再判断根因，避免被连锁报错误导。

### 规则 D：Exception 观察态（confidence=0.84）

- 遇到 `Exception` 先记录到观测流，不立即升格为强制修复规则。
- 累积更多样本后再升级为通用处理策略。

---

## 🚨 常见错误模式与解决方案

### 错误模式 1: LNK2001/LNK2019 无法解析的外部符号

#### 症状

```
error LNK2001: 无法解析的外部符号 "public: __thiscall CCSprite::CCSprite(void)" (??0CCSprite@@QAE@XZ)
error LNK2019: 无法解析的外部符号 _lua_pushnumber
```

#### 诊断步骤

```yaml
步骤 1: 检查工具集版本
  位置: 项目属性 → 配置属性 → 常规 → 平台工具集
  期望: v120
  如果不是: 修改为 v120 → 重新编译

步骤 2: 检查依赖库是否存在
  命令: dir /s /b *.lib | findstr FireClient
  期望: 找到 FireClient.lib
  如果没有: 重新编译 FireClient 项目

步骤 3: 检查库路径配置
  位置: 项目属性 → 链接器 → 常规 → 附加库目录
  期望: 包含所有依赖库目录
  如果没有: 添加缺失的路径

步骤 4: 检查库文件时间戳
  命令: dir /T:W FireClient.lib
  期望: 时间戳为原始编译时间
  如果被修改: 恢复原始库文件或重新编译
```

#### 解决方案

```xml
<!-- 正确的项目配置 -->
<PropertyGroup>
  <PlatformToolset>v120</PlatformToolset>
</PropertyGroup>

<ItemDefinitionGroup>
  <Link>
    <AdditionalLibraryDirectories>
      $(SolutionDir)client\FireClient\$(Configuration).win32;
      $(SolutionDir)cocos2d-x-2.2.6\Debug.win32;
      $(SolutionDir)dependencies\cegui\lib;
      %(AdditionalLibraryDirectories)
    </AdditionalLibraryDirectories>
    <AdditionalDependencies>
      FireClient.lib;
      libcocos2d.lib;
      CEGUIBase.lib;
      %(AdditionalDependencies)
    </AdditionalDependencies>
  </Link>
</ItemDefinitionGroup>
```

---

### 错误模式 2: C2065 未声明的标识符

#### 症状

```
error C2065: 'CCPoint' : undeclared identifier
error C2039: 'string' : is not a member of 'std'
```

#### 诊断步骤

```yaml
步骤 1: 检查头文件包含
  - 是否 #include <cocos2d.h>
  - 是否 using namespace cocos2d;
  - 头文件顺序是否正确

步骤 2: 检查预编译头
  文件: nupch.h
  期望: 包含常用头文件
  如果没有: 添加到预编译头

步骤 3: 检查头文件路径配置
  位置: 项目属性 → C/C++ → 常规 → 附加包含目录
  期望: 包含 Cocos2d-x、CEGUI 等头文件目录
```

#### 解决方案

```cpp
// 正确的头文件包含顺序
#include "nupch.h"          // 1. 预编译头（必须第一个）
#include <cocos2d.h>        // 2. Cocos2d-x
#include <CEGUIBase.h>      // 3. CEGUI
#include "GameDefines.h"    // 4. 项目头文件

using namespace cocos2d;
```

---

### 错误模式 3: MSB3073 预编译头错误

#### 症状

```
error MSB3073: 命令"xxx"已退出，代码为 1
fatal error C1010: 在查找预编译头时遇到意外的文件结尾
```

#### 诊断步骤

```yaml
步骤 1: 检查预编译头配置
  位置: 项目属性 → C/C++ → 预编译头
  选项:
    - 预编译头: 使用 (/Yu)
    - 预编译头文件: nupch.h
    - 通过文件创建/使用预编译头: nupch.cpp

步骤 2: 检查 nupch.cpp 特殊配置
  文件: nupch.cpp
  配置: 创建 (/Yc)
  注意: 只有这一个文件应该是 /Yc

步骤 3: 清理中间文件
  操作: 生成 → 清理解决方案
  删除: Debug.win32/、Release.win32/ 目录
```

#### 解决方案

```xml
<!-- nupch.cpp 特殊配置 -->
<ClCompile Include="nupch.cpp">
  <PrecompiledHeader>Create</PrecompiledHeader>
</ClCompile>

<!-- 其他所有 .cpp 文件 -->
<ClCompile Include="*.cpp">
  <PrecompiledHeader>Use</PrecompiledHeader>
  <PrecompiledHeaderFile>nupch.h</PrecompiledHeaderFile>
</ClCompile>
```

---

### 错误模式 4: Android NDK 链接失败

#### 症状

```
undefined reference to `JNI_OnLoad'
error: cannot find -lcocos2d
UnsatisfiedLinkError: dlopen failed: cannot locate symbol
```

#### 诊断步骤

```yaml
步骤 1: 检查 NDK 版本
  命令: ndk-build --version
  期望: r16 (16.1.4479499)
  如果不是: 切换到 NDK r16 clang

步骤 2: 检查 Application.mk
  文件: jni/Application.mk
  内容:
    APP_ABI := arm64-v8a
    APP_PLATFORM := android-21
    APP_STL := c++_shared

步骤 3: 检查 Android.mk
  - LOCAL_C_INCLUDES 是否包含所有头文件路径
  - LOCAL_LDLIBS 是否包含必要的系统库
  - LOCAL_WHOLE_STATIC_LIBRARIES 是否正确

步骤 4: 清理并重新编译
  ndk-build clean
  ndk-build -B
```

#### 解决方案

```makefile
# Application.mk
APP_ABI := arm64-v8a
APP_PLATFORM := android-21
APP_STL := c++_shared
APP_CPPFLAGS := -frtti -fexceptions -std=c++11

# Android.mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := game
LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/../../cocos2d-x-2.2.6 \
    $(LOCAL_PATH)/../../cocos2d-x-2.2.6/cocos2dx/platform \
    $(LOCAL_PATH)/../FireClient

LOCAL_WHOLE_STATIC_LIBRARIES := \
    cocos2dx_static \
    cocosdenshion_static

LOCAL_LDLIBS := -llog -lGLESv2 -lz

include $(BUILD_SHARED_LIBRARY)

$(call import-module,cocos2dx)
$(call import-module,CocosDenshion/android)
```

---

### 错误模式 5: Java 服务器编译失败

#### 症状

```
[javac] error: package gnet.protocol does not exist
[xbean] Error: xbean.xml parse failed
ClassNotFoundException: com.game.logic.GameServer
```

#### 诊断步骤

```yaml
步骤 1: 检查 JDK 版本
  命令: java -version
  期望: 1.7 或 1.8
  如果不是: 安装正确版本的 JDK

步骤 2: 检查 Ant 版本
  命令: ant -version
  期望: 1.9+
  如果不是: 安装正确版本的 Ant

步骤 3: 检查代码生成
  - xbean 是否已生成: src/*/xbean/*.java
  - gnet 是否已生成: src/*/rpc/*.java
  如果没有: 运行 ant xbean 和 ant gnet

步骤 4: 检查 build.xml 配置
  - classpath 是否包含所有依赖 jar
  - srcdir 是否正确指向源码目录
```

#### 解决方案

```bash
# 完整的编译流程
cd server/tools/jgs

# 1. 清理
ant clean

# 2. 生成代码
ant xbean
ant gnet

# 3. 编译
ant compile

# 4. 打包
ant jar

# 5. 验证
java -jar jgs.jar -version
```

---

## 🛠️ 调试工具使用

### Visual Studio 调试器

```yaml
基础调试:
  F5: 启动调试
  F9: 设置/取消断点
  F10: 单步跳过 (Step Over)
  F11: 单步进入 (Step Into)
  Shift+F11: 单步跳出 (Step Out)

高级技巧:
  条件断点: 右键断点 → 条件 → "变量 == 值"
  数据断点: 调试 → 新建断点 → 数据断点
  跟踪点: 右键断点 → 操作 → 记录消息

查看变量:
  本地变量: 调试 → 窗口 → 局部变量
  监视: 调试 → 窗口 → 监视 → 添加表达式
  内存: 调试 → 窗口 → 内存 → 输入地址
```

### 编译日志分析

```bash
# Windows: 生成详细日志
msbuild mt3.win32.vcxproj /v:detailed > build.log 2>&1

# 查找错误
findstr /i "error" build.log
findstr /i "warning" build.log

# 查找特定库链接信息
findstr /i "FireClient.lib" build.log
```

### NDK 调试

```bash
# 启用 NDK 调试
ndk-build NDK_DEBUG=1

# 使用 ndk-stack 解析崩溃日志
adb logcat | ndk-stack -sym obj/local/arm64-v8a

# 使用 addr2line 解析地址
aarch64-linux-android-addr2line -C -f -e obj/local/arm64-v8a/libgame.so 0x00012345
```

---

## 📊 编译依赖关系图

### Windows 客户端依赖

```
MT3.exe
    ├─→ FireClient.lib (v120, 必需)
    ├─→ libcocos2d.lib (v120, Cocos2d-x)
    ├─→ CocosDenshion.lib (v120, 音频)
    ├─→ CEGUIBase.lib (v120, UI)
    ├─→ lua.lib (v120, Lua 解释器)
    ├─→ platform.lib (v120, 跨平台基础)
    └─→ 系统库
        ├─→ kernel32.lib
        ├─→ user32.lib
        ├─→ gdi32.lib
        ├─→ winsock2.lib
        └─→ ...
```

### Android 客户端依赖

```
libgame.so
    ├─→ libcocos2dx.a (NDK r16)
    ├─→ libCocosDenshion.a (NDK r16)
    ├─→ liblua.a (NDK r16)
    ├─→ libplatform.a (NDK r16)
    └─→ 系统库
        ├─→ liblog.so
        ├─→ libGLESv2.so
        ├─→ libz.so
        └─→ ...
```

### 服务器端依赖

```
jgs.jar
    ├─→ gnet.jar (自研 RPC 框架)
    ├─→ xdb.jar (文件数据库)
    ├─→ commons-*.jar (Apache Commons)
    └─→ log4j.jar (日志框架)
```

---

## 🎯 实战演练

### 演练 1: 修复 v140 工具集错误

**场景**: 不小心升级到 VS2015，编译报错 LNK2001

**步骤**:
```yaml
1. 识别问题:
   错误信息: LNK2001 无法解析 FireClient 中的符号
   判断: 工具集不匹配

2. 检查工具集:
   操作: 项目属性 → 常规 → 平台工具集
   发现: v140

3. 修正配置:
   修改: 平台工具集 → v120
   保存: Ctrl+S

4. 清理并重新编译:
   操作: 生成 → 清理解决方案
   操作: 生成 → 重新生成解决方案

5. 验证:
   检查: 0 个错误，0 个警告
   运行: F5 启动程序
```

### 演练 2: 修复 Android 链接失败

**场景**: NDK 编译通过，但运行时 UnsatisfiedLinkError

**步骤**:
```yaml
1. 检查 .so 文件:
   cd obj/local/arm64-v8a
   ls -lh libgame.so

2. 检查符号导出:
   aarch64-linux-android-nm -D libgame.so | grep JNI_OnLoad
   期望: 看到 JNI_OnLoad 符号

3. 如果没有符号:
   检查: jni/game.cpp 是否实现 JNI_OnLoad
   检查: Android.mk 是否正确链接

4. 重新编译:
   ndk-build clean
   ndk-build V=1  # 详细输出

5. 安装并测试:
   ant clean debug install
   adb logcat | grep game
```

### 演练 3: 修复 Java 代码生成问题

**场景**: 修改了 xbean.xml，但编译找不到新的 xbean 类

**步骤**:
```yaml
1. 确认 xbean.xml 修改:
   检查: src/xbean.xml 是否已保存

2. 清理旧代码:
   rm -rf src/*/xbean/*.java

3. 重新生成:
   ant xbean
   检查: src/*/xbean/*.java 是否生成

4. 编译:
   ant clean compile

5. 验证:
   查找: src/*/xbean/ 目录中的新类文件
```

---

## 📚 参考资料

### 权威文档

- [../RULES.md](../../RULES.md) - 强制性技术约束
- [Windows 完整构建指南](../../../docs/03-开发指南/02-Windows完整构建指南.md) - Windows 编译流程
- [Android 平台文档入口](../../../docs/05-平台专项/android/00-README.md) - Android 编译流程
- [.claude/BUILD_GUIDE.md](../../BUILD_GUIDE.md) - 构建优化指南

### 外部资源

- [MSDN: C/C++ 编译器错误](https://docs.microsoft.com/zh-cn/cpp/error-messages/)
- [NDK 文档](https://developer.android.com/ndk/guides)
- [Apache Ant 手册](https://ant.apache.org/manual/)

---

## ✅ 技能验证清单

完成以下任务，表明你已掌握本技能:

- [ ] 能够独立解决 LNK2001/LNK2019 错误
- [ ] 能够正确配置 Visual Studio v120 工具集
- [ ] 能够诊断并修复预编译头问题
- [ ] 能够处理 Android NDK 编译和链接错误
- [ ] 能够处理 Java 服务器编译和代码生成问题
- [ ] 能够使用调试器定位运行时问题
- [ ] 能够阅读和分析编译日志
- [ ] 能够理解并绘制项目依赖关系图
- [ ] 能够在 30 分钟内解决常见编译问题
- [ ] 能够向团队成员解释编译错误原因和解决方案

---

**技能文档版本**: 1.0
**最后更新**: 2025-11-27
**维护**: MT3 技术团队
**状态**: 🚀 生产就绪

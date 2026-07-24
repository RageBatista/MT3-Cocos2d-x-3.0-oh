# 工具链兼容性矩阵 (Toolchain Compatibility Matrix)

> **版本**: 1.0 | **更新**: 2026-01-07

---

## 📋 概述

本文档提供 MT3 项目各平台工具链的兼容性矩阵，用于:
- ✅ 环境配置验证
- ✅ 编译问题诊断
- ✅ 新环境搭建参考

---

## 🖥️ Windows 平台

### Visual Studio 工具集兼容性

| Visual Studio 版本 | PlatformToolset | MT3 兼容性 | FireClient.lib | 备注 |
|-------------------|----------------|-----------|---------------|------|
| VS2013 | v120 | ✅ **必须** | ✅ 兼容 | MT3 官方工具集 |
| VS2015 | v140 | ⚠️ 可用 (需安装v120) | ❌ ABI 不兼容 | 仅用于编辑,构建用v120 |
| VS2017 | v141 | ⚠️ 可用 (需安装v120) | ❌ ABI 不兼容 | 仅用于编辑,构建用v120 |
| VS2019 | v142 | ⚠️ 可用 (需安装v120) | ❌ ABI 不兼容 | 仅用于编辑,构建用v120 |
| VS2022 | v143 | ⚠️ 可用 (需安装v120) | ❌ ABI 不兼容 | 仅用于编辑,构建用v120 |

**关键结论**:
- ✅ **必须使用 v120 工具集编译**
- ⚠️ 可以使用新版 VS 打开项目,但需安装 v120 工具集
- ❌ 使用 v140+ 编译会导致与 FireClient.lib 链接失败

**v120 安装方法**:
```yaml
步骤:
  1. 打开 Visual Studio Installer
  2. 修改已安装的 VS 版本
  3. 单个组件 → 搜索 "v120"
  4. 勾选 "MSVC v120 - VS2013 C++ x64/x86 生成工具"
  5. 安装
```

---

### MSBuild 版本兼容性

| MSBuild 版本 | 路径 | v120 支持 | 推荐使用 |
|-------------|------|----------|----------|
| 12.0 (VS2013) | `C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe` | ✅ 原生支持 | ✅ **推荐** |
| 14.0 (VS2015) | `C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe` | ✅ 需安装v120 | ✅ 可用 |
| 15.0 (VS2017) | `C:\Program Files (x86)\Microsoft Visual Studio\2017\...\MSBuild.exe` | ✅ 需安装v120 | ✅ 可用 |
| 16.0 (VS2019) | `C:\Program Files (x86)\Microsoft Visual Studio\2019\...\MSBuild.exe` | ✅ 需安装v120 | ✅ 可用 |
| 17.0 (VS2022) | `C:\Program Files\Microsoft Visual Studio\2022\...\MSBuild.exe` | ✅ 需安装v120 | ✅ 可用 |

**命令行示例**:
```bash
# 使用 MSBuild 12.0 (推荐)
"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" mt3.win32.vcxproj /p:PlatformToolset=v120

# 使用 MSBuild 14.0+ (需安装v120)
"C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" mt3.win32.vcxproj /p:PlatformToolset=v120
```

---

### CRT 运行时库兼容性

| 配置 | 运行时库选项 | MT3 标准 | FireClient.lib | 备注 |
|-----|-------------|---------|---------------|------|
| Debug | `/MDd` (MultiThreadedDebugDLL) | ✅ **标准** | ✅ 兼容 | 动态链接 MSVCR120D.dll |
| Debug | `/MTd` (MultiThreadedDebug) | ❌ 禁止 | ❌ 不兼容 | 静态链接,ABI 不匹配 |
| Release | `/MD` (MultiThreadedDLL) | ✅ **标准** | ✅ 兼容 | 动态链接 MSVCR120.dll |
| Release | `/MT` (MultiThreaded) | ❌ 禁止 | ❌ 不兼容 | 静态链接,ABI 不匹配 |

**关键结论**:
- ✅ **必须使用 /MD (Release) 和 /MDd (Debug)**
- ❌ 禁止使用 /MT 或 /MTd
- ⚠️ 混用会导致 LNK4098 警告和运行时崩溃

---

## 📱 Android 平台

### NDK 版本兼容性

| NDK 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|---------|-----------|---------|------|
| r16 (16.1.4479499) | ✅ **必须** | ✅ **官方版本** | MT3 当前免费服双 ABI NDK 版本 |
| r10e | ❌ 历史链路 | ❌ 不推荐 | 已废弃，禁止作为当前免费服输出链路 |
| r11c | ⚠️ 未测试 | ❌ 不推荐 | 可能存在兼容性问题 |
| r12b | ⚠️ 未测试 | ❌ 不推荐 | 可能存在兼容性问题 |
| r21+ | ❌ 不兼容 | ❌ 禁止 | 架构变更,不兼容 |

**下载地址**:
- NDK r16: https://developer.android.com/ndk/downloads/older_releases

---

### Android SDK 版本兼容性

| 组件 | 版本 | MT3 兼容性 | 备注 |
|-----|------|-----------|------|
| SDK Platform | API 19 (Android 4.4) | ✅ 最低要求 | 目标 API |
| SDK Platform | API 21 (Android 5.0) | ✅ 推荐 | 推荐目标 |
| SDK Platform | API 28+ | ✅ 兼容 | 向后兼容 |
| Build Tools | 28.0.3 | ✅ 推荐 | 构建工具 |
| Build Tools | 30.0.0+ | ✅ 兼容 | 新版本兼容 |

---

### Ant 版本兼容性

| Ant 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|---------|-----------|---------|------|
| 1.9.x | ✅ **推荐** | ✅ 官方版本 | MT3 官方 Ant 版本 |
| 1.10.x | ✅ 兼容 | ✅ 可用 | 向后兼容 |
| Maven/Gradle | ❌ 不支持 | ❌ 禁止 | MT3 使用 Ant,不支持其他构建工具 |

---

### JDK 版本兼容性 (Android)

| JDK 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|---------|-----------|---------|------|
| JDK 1.7 | ✅ **推荐** | ✅ 官方版本 | MT3 官方 JDK 版本 |
| JDK 1.8 | ✅ 兼容 | ✅ 可用 | 向后兼容 |
| JDK 9+ | ❌ 不兼容 | ❌ 禁止 | 模块化系统不兼容 |

---

## ☕ 服务器平台

### JDK 版本兼容性

| JDK 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|---------|-----------|---------|------|
| JDK 1.7 | ✅ **推荐** | ✅ 官方版本 | MT3 官方 JDK 版本 |
| JDK 1.8 | ✅ 兼容 | ✅ 可用 | 推荐升级到 1.8 |
| JDK 9 | ❌ 不兼容 | ❌ 禁止 | 模块化系统与 gnet 不兼容 |
| JDK 10+ | ❌ 不兼容 | ❌ 禁止 | 模块化系统与 gnet 不兼容 |

**关键结论**:
- ✅ **推荐使用 JDK 1.8** (长期支持)
- ⚠️ JDK 1.7 仍可用,但已停止支持
- ❌ JDK 9+ 不兼容 gnet 框架

---

### Ant 版本兼容性

| Ant 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|---------|-----------|---------|------|
| 1.9.x | ✅ **推荐** | ✅ 官方版本 | MT3 官方 Ant 版本 |
| 1.10.x | ✅ 兼容 | ✅ 可用 | 向后兼容 |
| Maven | ❌ 不支持 | ❌ 禁止 | MT3 使用 Ant |
| Gradle | ❌ 不支持 | ❌ 禁止 | MT3 使用 Ant |

---

## 🌍 跨平台工具

### Git 版本兼容性

| Git 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|---------|-----------|---------|------|
| 2.20+ | ✅ **推荐** | ✅ 现代版本 | 推荐 2.30+ |
| 2.10-2.19 | ✅ 兼容 | ⚠️ 可用 | 建议升级 |
| 1.x | ⚠️ 老版本 | ❌ 不推荐 | 缺少现代功能 |

---

### Python 版本兼容性 (工具脚本)

| Python 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|------------|-----------|---------|------|
| Python 2.7 | ✅ 兼容 | ⚠️ 即将弃用 | 部分老脚本使用 |
| Python 3.6+ | ✅ **推荐** | ✅ 现代版本 | 推荐 3.8+ |

---

## 🛠️ 第三方库

### Cocos2d-x 版本兼容性

| Cocos2d-x 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|---------------|-----------|---------|------|
| 2.0.1 | ✅ **必须** | ✅ 官方版本 | MT3 官方 Cocos2d-x 版本 |
| 2.0.4 | ⚠️ 未测试 | ❌ 不推荐 | API 可能有变化 |
| 2.1.x | ❌ 不兼容 | ❌ 禁止 | API 不兼容 |
| 3.x | ❌ 不兼容 | ❌ 禁止 | 架构重大变更 |

---

### CEGUI 版本兼容性

| CEGUI 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|-----------|-----------|---------|------|
| 0.7.1 | ✅ 原版本 | ⚠️ 功能不足 | 缺少部分自定义组件 |
| 0.7.9-r5 | ✅ **推荐** | ✅ 增强版本 | MT3 定制版本,新增组件 |
| 0.8.x | ❌ 不兼容 | ❌ 禁止 | API 重大变更 |

**CEGUI 0.7.9-r5 特性**:
- ✅ 新增自定义组件 (Fal*.cpp)
- ✅ 支持 Cocos2d 渲染器
- ⚠️ 需要特殊构建流程 (见 [workflows/cegui-build-workflow.md](../workflows/cegui-build-workflow.md))

---

### Lua 版本兼容性

| Lua 版本 | MT3 兼容性 | 推荐使用 | 备注 |
|---------|-----------|---------|------|
| Lua 5.1 | ✅ **必须** | ✅ 官方版本 | MT3 官方 Lua 版本 |
| LuaJIT 2.0.3 | ✅ **推荐** | ✅ 性能优化 | 性能提升 50-100x |
| Lua 5.2+ | ❌ 不兼容 | ❌ 禁止 | API 不兼容 |

---

## 📊 推荐配置组合

### Windows 开发环境 (推荐)

```yaml
操作系统: Windows 10 (64-bit)
Visual Studio: 2019 Community + v120 工具集
MSBuild: 16.0 (VS2019 自带)
PlatformToolset: v120
CRT 运行时库: /MD (Release), /MDd (Debug)
Git: 2.30+
```

---

### Android 开发环境 (推荐)

```yaml
操作系统: Windows 10 / Ubuntu 20.04
NDK: r16 (16.1.4479499)
SDK Platform: API 21 (Android 5.0)
Build Tools: 28.0.3
Ant: 1.9.x
JDK: 1.8
```

---

### 服务器开发环境 (推荐)

```yaml
操作系统: Ubuntu 20.04 LTS
JDK: 1.8 (OpenJDK 或 Oracle JDK)
Ant: 1.10.x
Git: 2.30+
```

---

## 🔍 兼容性问题诊断

### 问题 1: LNK2001/LNK2019 错误

**可能原因**:
- ❌ 使用了错误的 PlatformToolset (v140+ 而非 v120)
- ❌ CRT 运行时库不匹配 (/MT vs /MD)
- ❌ 依赖库缺失或版本不匹配

**诊断流程**:
```yaml
1. 检查 PlatformToolset:
   - Read: project.vcxproj → 搜索 <PlatformToolset>
   - 验证: 必须是 v120

2. 检查 CRT 运行时库:
   - Read: project.vcxproj → 搜索 <RuntimeLibrary>
   - 验证: Debug=MultiThreadedDebugDLL, Release=MultiThreadedDLL

3. 检查依赖库:
   - Read: project.vcxproj → 搜索 <AdditionalDependencies>
   - 验证: 库文件是否存在,工具集是否匹配
```

---

### 问题 2: MSB8020 错误 (找不到 v120)

**可能原因**:
- ❌ 未安装 v120 工具集

**解决方案**:
```yaml
1. 打开 Visual Studio Installer
2. 修改已安装的 VS 版本
3. 单个组件 → 搜索 "v120"
4. 勾选 "MSVC v120 - VS2013 C++ x64/x86 生成工具"
5. 安装并重启 VS
```

---

### 问题 3: Android 编译失败

**可能原因**:
- ❌ NDK 版本不是 r16 (16.1.4479499)
- ❌ JDK 版本是 9+

**诊断流程**:
```bash
# 检查 NDK 版本
ndk-build -version  # 路径应指向 r16 (16.1.4479499)

# 检查 JDK 版本
java -version  # 应显示 1.7 或 1.8

# 检查 Ant 版本
ant -version  # 应显示 1.9.x 或 1.10.x
```

---

## 📚 参考文档

- [RULES.md#编译工具链](../RULES.md#编译工具链) - 工具链强制约束
- [workflows/windows-build-workflow.md](../workflows/windows-build-workflow.md) - Windows 构建流程
- [errors/msbuild-errors.md#MSB8020](../errors/msbuild-errors.md#msb8020-工具集不匹配) - MSB8020 错误详解
- [errors/linker-errors.md#LNK2019](../errors/linker-errors.md#lnk2019-无法解析的外部符号-函数) - LNK2019 错误详解

---

**文档版本**: 1.0
**最后更新**: 2026-01-07
**维护**: MT3 开发团队

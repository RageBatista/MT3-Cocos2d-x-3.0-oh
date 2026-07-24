---
name: windows-build
version: 1.5.0
priority: high
category: client
description: |
  MT3 Windows客户端编译技能。涵盖VS2013 v120工具集配置、MT3主程序与Launcher登录器的MSBuild流程、
  输出路径校验与常见构建偏差修复。
  触发词: Windows, 编译, v120, VS2013, MSBuild, Launcher, 登录器, 构建, 链接错误, FireClient.lib, vcxproj, msbuild, DYNAMICBASE, /GS-, LNK2001, LNK2019
dependencies:
  - cpp-development
  - build-troubleshooting
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 8000
---

# Windows 编译技能 (MT3 客户端)

**版本**: v1.5.0
**最后更新**: 2026-04-11

## 🛠️ 环境要求

### 必需软件

| 软件 | 版本要求 | 用途 | 下载地址 |
|------|---------|------|----------|
| **Visual Studio** | 2013 Update 5 | C++ 编译器 | [MSDN](https://visualstudio.microsoft.com/) |
| **Windows SDK** | 8.1 | Windows API | VS 安装时选择 |
| **DirectX SDK** | June 2010 | 图形渲染 | [Microsoft](https://www.microsoft.com/en-us/download/details.aspx?id=6812) |

### 为什么必须使用 VS 2013？

**原因**: FireClient.lib 是使用 v120 编译的预编译库

```
┌─────────────────────────────────────────────────────────┐
│  FireClient.lib (v120)                              │
│         ↓                                        │
│  MT3.exe 链接                                │
└─────────────────────────────────────────────────────────┘
```

**后果**（使用其他版本）:
- LNK2038: mismatch detected for '_MSC_VER'
- LNK2038: mismatch detected for 'RuntimeLibrary'
- 运行时崩溃

---

## 📥 安装步骤

### 1. 安装 Visual Studio 2013

#### 下载 VS 2013 Update 5
- 从 MSDN 档案或 Visual Studio 存档下载
- 选择包含 C++ 的版本

#### 选择安装组件
```
✅ Visual C++ (必需)
✅ Windows SDK 8.1 (必需)
✅ MFC/ATL (可选，但建议)
✅ .NET Framework (可选)
```

### 2. 验证安装

```bash
# 打开 VS 2013 开发者命令提示
cmd /c "call \"%VS120COMNTOOLS%..\\..\\VC\\vcvarsall.bat\" x86 && cl"
```

预期输出:
```
Microsoft (R) C/C++ Optimizing Compiler Version 18.00.40629 for x86
Copyright (C) Microsoft Corporation. All rights reserved.
```

---

## 📚 项目配置

### PlatformToolset 设置

**正确配置**:
```xml
<PlatformToolset>v120</PlatformToolset>
```

**如何验证**:
1. 打开项目文件 (`.vcxproj`)
2. 右键 → 属性 → 配置属性
3. 选择"配置属性" → "常规"
4. 查看"平台工具集"值

**预期值**: `v120`
```

### RuntimeLibrary 设置（按工程区分）

| 工程 | Release | Debug | 说明 |
|-------|---------|-------|------|
| **MT3Win32App** | `/MD` | `/MDd` | 主客户端，动态 CRT |
| **Launcher** | `/MT` | `/MTd` | 登录器，静态 CRT |

**如何配置**:
1. 右键项目 → 属性 → 配置属性
2. 选择"C/C++" → "代码生成"
3. 修改"运行库"为对应值

---

## 🧠 自动进化高价值规则（2026-03 回灌）

来源：`.claude/evolution/evolved/skills/backfill-proposals.md`（2026-03-05）。

### 规则 A：MSB 构建前预检（confidence=0.81）

每次 `msbuild` 前，先执行并确认以下命令成功：

```powershell
cmd /c "call \"%VS120COMNTOOLS%..\\..\\VC\\vcvarsall.bat\" x86 && cl >nul"
cmd /c "\"%ProgramFiles(x86)%\\MSBuild\\12.0\\Bin\\MSBuild.exe\" /version"
```

预检失败时禁止继续构建，先修复环境变量与工具链安装。

### 规则 B：LNK 三步排查（confidence=0.95）

出现 `LNK2001/LNK2019/LNK2038` 时按固定顺序定位：

1. `PlatformToolset` 是否为 `v120`。
2. `AdditionalLibraryDirectories` 与 `AdditionalDependencies` 是否完整且顺序正确。
3. 预编译库 ABI 与 CRT 是否一致（重点检查 `FireClient.lib` 与相关第三方库）。

---

## 🔧 常见编译错误

### LNK2038: mismatch detected

**原因**: RuntimeLibrary 配置不匹配

**解决方案**:
```xml
<!-- Release 配置 -->
<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>

<!-- Debug 配置 -->
<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>
```

### LNK2001 / LNK2019: 无法解析的外部符号

**常见原因**:
1. 工具集版本不匹配 (非 v120)
2. 缺少库文件
3. 库文件路径错误

**排查步骤**:
```bash
# 1. 检查工具集
findstr /i "PlatformToolset" "E:\MT3\client\MT3Win32App\*.vcxproj"
# 预期结果: v120
# 如果不是 v120，这是主要问题原因

# 2. 检查库文件
dir /s /b "E:\MT3\client\FireClient\*.lib"
dir /s /b "E:\MT3\cocos2d-2.0-rc2-x-2.0.1\*.lib"
```

---

## 🚀 编译命令

### 固定入口（唯一，推荐）

标准路径：`tools/scripts/Build-MT3-Exe-Canonical.ps1`

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release

# Debug
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug

# 严格 Runtime 审计模式
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -StrictRuntimeAudit
```

说明：
- 旧入口脚本仅作为内部链路使用，不再作为外部首选入口。

### 构建模式分层（效率与安全）

```powershell
# 1) 日常开发（推荐，最快）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -FastLocal -MaxParallelJobs 8

# 2) 日常 Release 快速验证（不做全量重建）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode Incremental -MaxParallelJobs 8

# 3) 发版前安全构建（全链路 SafeChain）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit

# 4) 里程碑全量验证（最慢）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both -MaxParallelJobs 8 -StrictRuntimeAudit
```

执行规则：
1. 日常迭代默认不加 `-Clean`，避免触发无必要全量重建。
2. 修改 ABI 敏感头文件、工具链漂移排查、发版前验收时，切回 `SafeChain` 或 `FullValidation`。
3. `-MaxParallelJobs` 按机器逻辑核调整（例如 `8/12/16`）。
4. 若 `Incremental` 被 ABI 防护拦截，按脚本提示切回 `SafeChain` 执行一次。

### 排障兜底（仅在 canonical 入口不可用时）

```bash
cmd /c "call \"%VS120COMNTOOLS%..\\..\\VC\\vcvarsall.bat\" x86 && msbuild E:\MT3\client\MT3Win32App\mt3.win32.vcxproj /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /v:minimal"
```

### Launcher 登录器编译（2026-03 实测）

> 关键结论：内部链路脚本不包含 Launcher 构建步骤，需单独编译。

```powershell
# Release
$cmd = 'call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86 && "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" client\Launcher\Launcher.sln /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /m /nologo'
cmd /c $cmd

# Debug
$cmd = 'call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86 && "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" client\Launcher\Launcher.sln /t:Rebuild /p:Configuration=Debug /p:Platform=Win32 /m /nologo'
cmd /c $cmd
```

### Launcher 产物路径（必须按工程真实配置校验）

```powershell
Get-Item client\Launcher\Debug\Launcher.exe
Get-Item client\resource\Launcher.exe
```

说明：
1. `Debug` 产物在 `client/Launcher/Debug/Launcher.exe`。  
2. `Release` 产物在 `client/resource/Launcher.exe`（`Launcher.vcxproj` 的 `<OutputFile>` 指定），不是 `client/Launcher/Release/Launcher.exe`。  
3. 若仅检查 `client/Launcher/Release` 会误判“Release 未生成”。

### PowerShell 调用注意（避免命令被误解析）

错误写法容易把 `x86` 当成 PowerShell 命令解析，导致：
- `The term 'x86' is not recognized...`

建议固定写法：
```powershell
$cmd = 'call "...vcvarsall.bat" x86 && "...MSBuild.exe" ...'
cmd /c $cmd
```

### 启动验证策略（避免误测）

1. 构建完成后仅做文件存在/时间戳校验。  
2. 启动与功能验证由人工手动执行，不做“短时自动启动探测”。  
3. 启动失败时优先回收 `dmp + mt3_ct.log + 构建日志` 再定位。

---

## 📖 参考文档

- [cpp-development](cpp-development.md) - C++ 开发基础
- [build-troubleshooting](../common/build-troubleshooting.md) - 构建问题排查
- [diagnose-build](../../commands/diagnose-build.md) - 编译错误诊断命令
- [windows-build-workflow](../../workflows/windows-build-workflow.md) - Windows 构建工作流
- [Windows 编译环境准备](../../../docs/03-开发指南/01-Windows编译环境准备.md) - 环境与退出问题沉淀
- [资源打包与热更新发布指南](../../../docs/03-开发指南/06-资源打包与热更新发布指南.md) - 发布前检查清单

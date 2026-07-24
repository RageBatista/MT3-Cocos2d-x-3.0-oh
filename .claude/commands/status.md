---
name: status
version: 1.1.0
description: 快速查看项目状态和关键入口
linked-skill: common/project-context
linked-agent: architecture-analyst
allowed-tools:
  - Bash
  - Read
---

# 项目状态查看命令

**关联技能**: [project-context](../skills/common/project-context.md)
**关联代理**: [architecture-analyst](../agents/architecture-analyst.md)

## 建议检查项

### 1. Git 状态

```powershell
git status --short
git branch --show-current
git log --oneline -5
```

### 2. 工具链状态

```powershell
# MSBuild 12.0
Test-Path "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe"

# JDK / Ant
java -version
ant -version

# NDK 环境变量
$env:ANDROID_NDK_HOME
```

### 3. 关键入口存在性

```powershell
Test-Path "tools/scripts/Build-MT3-Exe-Canonical.ps1"
Test-Path "tools/scripts/Build-Android-Locojoy-WithGate.ps1"
Test-Path "server/server/game_server/build.xml"
Test-Path ".claude/config/router.json"
```

### 4. 最近构建产物（按需）

```powershell
Get-ChildItem "client/MT3Win32App/Release.win32" -Filter *.exe -ErrorAction SilentlyContinue
Get-ChildItem "client/android/LocojoyProject/build/bin" -Filter *.apk -ErrorAction SilentlyContinue
Get-ChildItem "server/serverbin/gs" -Filter *.jar -ErrorAction SilentlyContinue
```

## 输出要求

- 分支与最近提交
- 工具链可用性
- 构建入口完整性
- 最近产物存在性

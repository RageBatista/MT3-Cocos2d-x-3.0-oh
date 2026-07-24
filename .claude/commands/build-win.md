---
name: build-win
version: 1.1.0
description: 编译 Windows 客户端（使用 MT3 一键脚本）
linked-skill: client/windows-build
linked-agent: build-expert
allowed-tools:
  - Bash
---

# Windows 客户端编译命令

**关联技能**: [windows-build](../skills/client/windows-build.md)
**关联代理**: [build-expert](../agents/build-expert.md)

优先使用仓库标准入口脚本，确保依赖同步和运行时校验一致。
标准路径：`tools/scripts/Build-MT3-Exe-Canonical.ps1`

## 推荐命令

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32
```

## 常用变体

```powershell
# Debug 构建
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32

# 发版前安全构建
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -StrictRuntimeAudit
```

说明：
- 旧入口脚本仅作为内部链路使用，不再作为外部首选入口。

## 产物检查

```powershell
$cfg = 'Release'
$stage = if ($cfg -eq 'Debug') { 'Debug.win32' } else { 'Release.win32' }

Get-Item ".\client\resource\bin\$cfg\MT3.exe" | Select-Object FullName, Length, LastWriteTime
Get-Item ".\client\MT3Win32App\$stage\MT3.exe" | Select-Object FullName, Length, LastWriteTime
Get-Item ".\client\MT3Win32App\$stage\FireClient.lib" | Select-Object FullName, Length, LastWriteTime
Get-Item ".\client\MT3Win32App\$stage\engine.lib" | Select-Object FullName, Length, LastWriteTime
```

根据用户意图选择 Debug/Release 并反馈构建结果与日志位置。

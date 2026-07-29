# MT3 Win32 壳层子树规则

> **定位**: `client/MT3Win32App/` 用于 Win32 启动层、壳层资源和最终 `MT3.exe` 链接；默认叠加根 `AGENTS.md`、`../AGENTS.md` 与 `../../.claude/BUILD_GUIDE.md`。

## 关注点

- 主要文件：`main.cpp`、`mt3.*`、`CrashDump.*`、`*.vcxproj`、`*.rc`、启动层资源。
- 典型任务：启动链排障、崩溃转储、链接产物核对、Win32 壳层资源调整。
- 构建判断：仅改壳层文件通常可直接重链 `MT3`；若触到 `FireClient` 公共头文件或共享 ABI，回退到上层规则。

## 本目录边界

- 壳层问题先核对崩溃栈、链接输出、资源实物和 `Release.win32` / 最终产物时间戳，再判断是入口、链接还是 ABI 问题；不要先做表面补丁。
- 该目录存在历史 `CP936/ANSI`、`UTF-8 no BOM` 和 `UTF-16` 文件；`.rc` 文件必须保持原编码。
- 不要把 Win32 壳层问题与 Android 渠道、Lua 业务逻辑、资源发布链问题混在一轮里处理。
- `Release.win32` 为 `FireClient.win32.vcxproj` 与 `mt3.win32.vcxproj` 的共享输出目录（各项目 `IntDir` 按项目名分离）；发现产物时间戳异常或 ABI 可疑时，优先走固定入口脚本，而不是只依赖局部增量构建。

## 首轮验证入口

```powershell
powershell -ExecutionPolicy Bypass -File ..\..\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -EngineProfile Upgrade30
Get-Item .\Release.win32\MT3.exe, ..\resource\bin\Release\MT3.exe | Select-Object FullName, Length, LastWriteTime
```

## 常用技能

- `windows-v120-build`
- `platform-bridge`

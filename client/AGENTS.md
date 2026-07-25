# MT3 客户端子树协作边界

> **定位**: `client/` 目录的就近规则；默认叠加根 `AGENTS.md`、`../.claude/RULES.md` 和 `../.claude/BUILD_GUIDE.md`。

## 首轮路由

- `FireClient/Application/**`：继续读 `FireClient/Application/AGENTS.md`；这里是客户端主业务、网络、Lua 桥接和 ProtoDef 边界。
- `MT3Win32App/**`：继续读 `MT3Win32App/AGENTS.md`；这里是 Win32 壳层、启动入口、资源脚本与混合编码目录。
- `android/**`：继续读 `android/AGENTS.md`；这里固定走 `NDK r16 clang + Ant + JDK8` 当前主线。
- `resource/**`、`Launcher/**`、平台资源目录：优先判定是资源发布链、启动器更新还是平台资源问题，必要时联动 `resource-packaging-pipeline`、`platform-bridge`。

## 本目录硬边界

- 客户端问题先取证再修改；证据优先来自日志、调用链、构建输出、资源实物与产物时间戳，不把“最小修改”当默认目标，先修真正根因。
- 修改 `client/FireClient/Application/**.h` 前，先按 ABI 敏感变更处理；至少满足 `Rebuild FireClient -> Build MT3`。
- `client/**/tolua++/*.cpp` 与 `client/FireClient/Application/ProtoDef/**` 默认视为生成物，修改应回到源定义。
- `client/android/LocojoyProject/assets/res/**` 是 `LJFilePack_打包安卓.bat` 资源打包链生成产物，严禁手动修改；业务资源只改 `client/resource/res/**` 后重打包。
- `client/MT3Win32App/**`、平台资源目录和历史工程可能存在 `CP936/ANSI`、`UTF-8 no BOM`、`UTF-16`；修改前先探测编码。
- Android 渠道、Win32 壳层、FireClient 业务层、资源打包层不要在同一轮任务里混改。

## 常用验证入口

```powershell
powershell -ExecutionPolicy Bypass -File ..\tools\scripts\Check-v120Toolset.ps1
powershell -ExecutionPolicy Bypass -File ..\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release
Get-Item .\resource\bin\Release\MT3.exe | Select-Object FullName, Length, LastWriteTime
```

## 常用技能

- `application-core-flow`
- `platform-bridge`
- `rendering-pipeline`
- `resource-packaging-pipeline`

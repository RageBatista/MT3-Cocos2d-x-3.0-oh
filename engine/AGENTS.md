# MT3 引擎子树规则

> **定位**: `engine/` 是第一方引擎源码区；这里的头文件改动默认按高风险处理，并叠加根 `AGENTS.md` 与 `../.claude/RULES.md`。

## 关注点

- 典型任务：场景、精灵、动画、特效、渲染路径、引擎容器与下游依赖排障。
- 任何影响类布局、虚表、模板实例、内联实现或公共宏分支的变更，都默认属于 ABI 敏感变更。
- 若问题其实落在 CEGUI 工具、资源提供器或平台输入桥接，联动 `rendering-pipeline` 或 `platform-bridge`，不要只盯 `engine/`。

## 本目录硬边界

- 引擎问题先看崩溃栈、渲染现象、调用链和下游受影响面，再定根因；如果根因在公共头文件或上游渲染入口，应直接修根因，不追求表面最小改动。
- 修改 `engine/**.h` 后，默认执行 `Rebuild engine -> Rebuild FireClient -> Build MT3`。
- 本目录以 `UTF-8 with BOM` 为主；修改既有文件时保持原 BOM 与换行。
- 不要把 `engine` 源码问题和 `dependencies/**`、vendor 目录批量治理混在一起处理。

## 首轮验证入口

```powershell
cmd /c 'call "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 && msbuild engine\engine.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo'
powershell -ExecutionPolicy Bypass -File ..\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release
```

## 常用技能

- `rendering-pipeline`
- `platform-bridge`

# MT3 FireClient Application 子树规则

> **定位**: `client/FireClient/Application/` 是客户端主业务源码区；这里的局部规则优先于上层 `client/AGENTS.md`，但仍受根 `AGENTS.md`、`../../../.claude/RULES.md` 和 `../../../.claude/BUILD_GUIDE.md` 约束。

## 关注点

- 主线职责：启动初始化、登录流程、入世界流程、Manager/Framework 协作、Lua/Proto 协议接入。
- 高风险点：公共头文件、跨模块内联实现、影响对象布局的类定义、共享枚举和宏分支。
- 常见协作任务：业务流程排障、协议接入、平台回调接管、UI 与数据层联动。

## 本目录边界

- 业务链问题先拿启动日志、调用链、协议流向和相关表/脚本实物，再判断根因；不要为了追求最小改动而绕过真正的源定义或公共入口。
- `ProtoDef/**` 默认视为生成物；协议修改应回到源定义和生成链，而不是直接手改产物。
- `.h` 改动若影响 ABI，至少执行 `Rebuild FireClient -> Build MT3`；若联动 `engine/**.h`，升级为整链重编。
- 本目录现状以 `UTF-8 with BOM` 为主；修改既有文件时保持原 BOM 与换行，不做顺手转码。
- 涉及 JNI、ObjC++、平台生命周期、SDK 登录桥接时，联动 `platform-bridge`；涉及渲染链或 CEGUI 时，联动 `rendering-pipeline`。

## 首轮验证入口

```powershell
powershell -ExecutionPolicy Bypass -File ..\..\..\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release
Get-Item ..\..\resource\bin\Release\MT3.exe | Select-Object FullName, Length, LastWriteTime
```

## 常用技能

- `application-core-flow`
- `platform-bridge`
- `rendering-pipeline`

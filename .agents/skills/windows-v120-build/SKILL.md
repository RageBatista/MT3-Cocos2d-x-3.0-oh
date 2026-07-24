---
name: windows-v120-build
description: "MT3 Windows 客户端构建与构建排障技能。处理 VS2013、v120、`msbuild`、`vcvarsall`、Win32 构建失败、链接错误或 `FireClient.lib` ABI 兼容问题时使用；不用于 Android/iOS 平台壳层或纯资源热更问题。"
---

Win32 主线固定为 `VS2013 + v120 + Windows SDK 8.1`。外部构建入口固定使用 canonical wrapper，不把内部脚本或新工具集当替代主线。

## 何时使用

- Win32 编译/链接失败、`PlatformToolset` 漂移、MSBuild/`vcvarsall` 不可见
- `FireClient.lib`、`engine.lib`、`libcocos2d` 或 `MT3.exe` 的 ABI/重编顺序风险
- 需要选择日常增量、SafeChain 或 Debug+Release 全量验证

## 不使用

- Android/iOS 构建或平台壳层问题，用 `android-r10e-build` 或 `platform-bridge`
- 纯资源热更、版本包或下载校验，用 `resource-packaging-pipeline`
- 已确认是共享业务、渲染或运行时资源根因时，切对应业务技能

## 输入校验

1. 先区分编译失败、链接失败、运行时 ABI 风险或入口误用。
2. 记录实际命令、配置、`PlatformToolset`、`vcvarsall` 与首个错误。
3. 信息不足时用 `../mt3-project-guidelines/references/high-frequency-fact-packs.md` 的 Windows 模板。
4. 先跑快速体检：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\windows-v120-build\scripts\verify-build-env.ps1 -Json
```

## 关键边界

- 构建 `MT3.exe` 并要求可靠退出码时，只用 `tools/scripts/Build-MT3-Exe-Canonical.ps1`。
- `client/Build-MT3-v120.ps1` 是 canonical wrapper 的内部链路，不是首选外部入口。
- 需要 Debug+Release 里程碑验证时，用 `tools/scripts/Build-MT3-FullValidation.ps1`。
- 主线出现非 `v120` 工具集立即判为漂移；禁止用 `/FORCE` 或新工具集二进制掩盖 ABI/链接问题。
- 修改 `engine/**.h` 等 ABI 敏感头时按 `engine -> FireClient -> MT3` 重编；修改 `client/FireClient/Application/**.h` 时按 `FireClient -> MT3` 重编。
- `FireClient.win32.vcxproj` 与 `mt3.win32.vcxproj` 共用中间目录；单项目增量成功不能证明 ABI 一致。
- VS2013 在中文字符串附近报 `C2001: 常量中有换行符` 时，先查 C/C++ 文件 UTF-8 BOM 是否丢失。

## 最短流程

1. 运行 `verify-build-env.ps1` 与 `tools/scripts/Check-v120Toolset.ps1`，锁定工具链或入口首错。
2. 根据改动面判断是否命中 ABI 敏感头；命中则禁用不安全增量。
3. 日常开发用 Debug FastLocal；普通 Release 用 Incremental；ABI/发版用 SafeChain。
4. 运行 canonical wrapper，核对退出码与 `MT3.exe/FireClient.lib/engine.lib` 时间戳。
5. 运行时失败再做依赖审计或实跑，不用“编译成功”替代运行时证据。

```powershell
# 日常 Debug
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -FastLocal -MaxParallelJobs 8

# 发版前 SafeChain
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit
```

完整模式命令、手动重编顺序与 C2001/BOM 处理见 `references/win32-v120-build-details.md`。

## 失败处理

- 体检为 `FAIL`：先修 v120、MSBuild 12.0、SDK 或入口漂移，不继续堆业务补丁。
- 链接错误先核对公共头、CRT、宏与产物工具集；怀疑混编时从受影响层开始整链 Rebuild。
- fresh process 初始化期崩在容器或成员偏移访问时，优先核对对象布局与产物时间戳。
- 根因落到 CEGUI/Nuclear/渲染、Launcher/PFS 或平台壳层时及时切技能。

## 输出与验证

- 输出：入口脚本、工具链状态、首个阻塞点、ABI 风险、构建命令、退出码与产物证据。
- 至少运行一次目标 canonical 命令；ABI 变更同时验证受影响库与 `MT3.exe` 的重编顺序。
- 机器可读体检优先用 `verify-build-env.ps1 -Json`。

## 资源与上下文预算

- 默认只读当前日志、canonical wrapper、受影响 `.vcxproj`、公共头与最近产物证据。
- 工具链路径、构建模式、BOM 修复和手动重编命令按需读 `references/win32-v120-build-details.md`。

## 需要时再读

- `references/win32-v120-build-details.md`
- `.claude/skills/client/windows-build.md`
- `.claude/BUILD_GUIDE.md`
- `docs/03-开发指南/02-Windows完整构建指南.md`
- `docs/03-开发指南/04-Windows构建命令速查.md`

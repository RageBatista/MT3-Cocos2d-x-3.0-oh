# Windows 平台构建标准工作流

> 适用: MT3.exe Win32 客户端、VS2013/MSBuild 12.0/v120 工具集
> 版本: 2.0.0 | 更新: 2026-07-03

## 核心原则

- 构建 `MT3.exe` 并需要可信退出码时，固定使用 `tools/scripts/Build-MT3-Exe-Canonical.ps1`。
- `client/Build-MT3-v120.ps1` 只作为 canonical 脚本的内部链路，不再作为外部首选入口。
- 直接调用 `msbuild` 只用于窄范围取证或单工程排障，不能替代 `MT3.exe` 交付构建。
- 不手工替换 `.lib/.dll/.exe`，ABI 问题回到源码和 v120 链路重编。

## Phase 0: 前置体检

先确认工作区配置和构建入口可读：

```powershell
git lfs checkout .claude/config .claude/hooks/hooks.json .claude/settings.json .claude/settings.local.json
powershell -ExecutionPolicy Bypass -File .\.agents\skills\windows-v120-build\scripts\verify-build-env.ps1
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1
```

若 `.claude/config/*.json` 仍是 Git LFS pointer，先恢复 LFS 实物；不要基于 pointer 内容做配置审计结论。

## Phase 1: 选择构建模式

| 场景 | 命令 |
| --- | --- |
| 日常 Debug 快速验证 | `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -FastLocal -MaxParallelJobs 8` |
| 日常 Release 增量验证 | `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode Incremental -MaxParallelJobs 8` |
| 发版前安全构建 | `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit` |
| Debug + Release 里程碑验证 | `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both -MaxParallelJobs 8 -StrictRuntimeAudit` |

使用规则：

1. 日常迭代默认不加 `-Clean`。
2. ABI 敏感头文件、工具链漂移排查或发版验收时，切到 `SafeChain` 或 `FullValidation`。
3. 若 `Incremental` 被 ABI 防护拦截，按脚本提示切回 `SafeChain`。
4. `-MaxParallelJobs` 按本机逻辑核数调整。

## Phase 2: 执行构建

Release 默认入口：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32
```

执行期间只启动一个主构建任务。不要并行启动多个 `msbuild`、不要提前删除输出目录、不要在构建未结束前读取半成品日志判断结果。

## Phase 3: 产物校验

构建成功后检查两个落点和核心 ABI 产物：

```powershell
$cfg = 'Release'
$stage = if ($cfg -eq 'Debug') { 'Debug.win32' } else { 'Release.win32' }

Get-Item ".\client\resource\bin\$cfg\MT3.exe" | Select-Object FullName, Length, LastWriteTime
Get-Item ".\client\MT3Win32App\$stage\MT3.exe" | Select-Object FullName, Length, LastWriteTime
Get-Item ".\client\MT3Win32App\$stage\FireClient.lib" | Select-Object FullName, Length, LastWriteTime
Get-Item ".\client\MT3Win32App\$stage\engine.lib" | Select-Object FullName, Length, LastWriteTime
```

判断要点：

- `client/resource/bin/<Configuration>/MT3.exe` 是运行目录产物。
- `client/MT3Win32App/<Configuration>.win32/MT3.exe` 是工程输出目录产物。
- `FireClient.lib`、`engine.lib`、`MT3.exe` 的时间戳应符合本次重编顺序。

## Phase 4: 失败处理

| 信号 | 优先处理 |
| --- | --- |
| Git LFS pointer 出现在运行时输入或 `.claude/config` | 运行 `git lfs checkout <path>`，必要时 `git lfs pull -I <path>` |
| `PlatformToolset` 非 `v120` | 先修项目文件或错误入口，再重跑 `Check-v120Toolset.ps1` |
| `LNK2001/LNK2019/LNK2038` | 检查 v120、库路径、ABI/CRT；需要时切回 `SafeChain` |
| 中文字符串附近 `C2001: 常量中有换行符` | 先检查 C/C++ 源文件 UTF-8 BOM 状态 |
| 构建成功但运行目录缺 `MT3.exe` | 先看 canonical 脚本输出和 runtime sync/audit 结果 |

## 禁止清单

- 不为 `MT3.exe` 交付构建临时生成 `build_logs\build_*.bat`。
- 不把 `client/Build-MT3-v120.ps1` 作为人工或 Agent 的外部首选入口。
- 不在未确认路径的情况下递归删除 `Debug.win32`、`Release.win32` 或运行目录。
- 不用 v140+ 工具集产物替换 v120 主线二进制。

## 交付说明模板

```markdown
## Windows 构建结果

- 入口: tools/scripts/Build-MT3-Exe-Canonical.ps1
- 配置: Release|Win32
- 模式: Incremental/SafeChain/FastLocal
- 结果: PASS/FAIL
- 首个阻塞点:
- 产物:
  - client/resource/bin/Release/MT3.exe
  - client/MT3Win32App/Release.win32/MT3.exe
  - client/MT3Win32App/Release.win32/FireClient.lib
  - client/MT3Win32App/Release.win32/engine.lib
- 验证命令:
- 剩余风险:
```

## 参考

- `.claude/RULES.md`
- `.claude/BUILD_GUIDE.md`
- `.agents/skills/windows-v120-build/SKILL.md`
- `tools/scripts/Build-MT3-Exe-Canonical.ps1`
- `tools/scripts/Build-MT3-FullValidation.ps1`

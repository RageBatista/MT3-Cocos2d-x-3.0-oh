# 服务端 Ant 构建兼容工作流

> 版本: 2.0.0
> 更新: 2026-07-12
> 状态: `manual`；需要 JDK 1.7/1.8 与 Ant
> 声明式目录: `.codex/workflows/workflow-engine.json` sidecar 中的 `server-ant-build`

## 1. 首步：Git LFS 与入口门禁

在读取 XML 或执行 Ant 前，必须先运行已跟踪的服务端检查器。它会检测 `build.xml`、`gnet.xml`、`protocol.main.xml`、`gs/build.xml` 是否仍是 LFS pointer，并给出精确恢复命令。

```powershell
$repoRoot = (Resolve-Path .).Path
$gateRelative = ".agents/skills/server-ant-build/scripts/verify-server-ant-chain.ps1"
$gate = Join-Path $repoRoot $gateRelative

& git ls-files --error-unmatch -- $gateRelative 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Server LFS gate is not tracked: $gateRelative" }
if (-not (Test-Path -LiteralPath $gate -PathType Leaf)) { throw "Server LFS gate is missing: $gate" }

& powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $gate -RepoRoot $repoRoot -Json
if ($LASTEXITCODE -ne 0) { throw "Server LFS/Ant preflight failed; follow its lfs_pull_command and lfs_checkout_command" }
```

禁止在 pointer 状态下解析 XML、运行生成器或把 pointer 文本改成占位 XML。

## 2. 工具链与目标选择

- `JAVA_HOME` 必须指向 JDK 1.7/1.8。
- 主入口固定为 `server/server/game_server/build.xml`。
- 只有协议、数据库或 bean 定义发生变化时，才按 `genrpc -> genxdb -> gengbeans` 生成；不要手改生成出的 `rpc/xbean` Java 文件。
- 纯构建且定义未变化时，直接执行目标模块或 `dist`，避免无意义再生成。

## 3. 人工执行

```powershell
$buildXml = Join-Path $repoRoot "server/server/game_server/build.xml"
$antCommand = Get-Command ant -ErrorAction Stop
$ant = [string]$antCommand.Source
if (-not (Test-Path -LiteralPath $buildXml -PathType Leaf)) { throw "Server build.xml is missing: $buildXml" }

# 仅在对应定义变化时执行以下三个目标。
& $ant -f $buildXml genrpc
if ($LASTEXITCODE -ne 0) { throw "genrpc failed" }
& $ant -f $buildXml genxdb
if ($LASTEXITCODE -ne 0) { throw "genxdb failed" }
& $ant -f $buildXml gengbeans
if ($LASTEXITCODE -ne 0) { throw "gengbeans failed" }

& $ant -f $buildXml dist
if ($LASTEXITCODE -ne 0) { throw "server dist failed" }
```

## 4. 验证与回滚

1. 记录 LFS gate JSON、JDK/Ant 版本、执行目标与首个失败任务。
2. 检查 `dist/` 或目标模块实际声明的产物，不编造固定 JAR 路径。
3. 生成前后审查 `git diff`；生成异常时回到 `protocol/gnet/xbean` 源定义，不在生成目录继续补丁。
4. 构建工具链失败留在本工作流；服务端运行时异常转运行时/协议排障，不归入 build failure。

## 关联入口

- [Ant 构建技能](../skills/server/ant-build.md)
- [Java 开发技能](../skills/server/java-development.md)
- [错误诊断兼容视图](error-diagnosis-workflow.md)

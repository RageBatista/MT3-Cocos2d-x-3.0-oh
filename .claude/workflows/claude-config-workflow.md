---
name: claude-config-workflow
version: 2.0.0
description: Codex 原生治理与 Claude 兼容桥接的人工审计工作流
---

# Codex / Claude 配置治理兼容工作流

> 状态: `manual`
> 声明式目录: `.codex/workflows/workflow-engine.json` 治理 sidecar 中的 `codex-governance`
> Claude-only 路由: `claude_config_governance`

## 权威边界

- `.codex/config.toml`、`.codex/rules/**`、`.codex/hooks.json` 与 `.codex/agents/*.toml` 是 Codex 项目原生运行入口。
- `.codex/requirements.toml`、`.codex/mcp/**`、`.codex/permissions/**`、`.codex/project-map.json` 和 workflow catalog 是治理、审计或导出 sidecar，除非官方运行时另有声明。
- `.codex/workflows/workflow-engine.json` 是机器可读声明式事实源，不是 Codex 原生运行时工作流引擎；`.claude/config/workflows.manifest.json` 和 `.claude/workflows/*.md` 只是兼容人工视图。
- `.agents/skills/**` 是 Codex 原生技能；`.claude/skills/**` 是 Claude 长文/兼容能力层。

## 1. 先分流治理域

1. 命中 `.codex/**`、`.agents/skills/**`、Codex MCP/rules/hooks/subagent/catalog：走 `codex_config_governance`，先校正原生层。
2. 命中 `.claude/config/**`、`.claude/hooks/**`、Claude manifest/router/proxy/command：走 `claude_config_governance`。
3. 同时跨两层：先完成 Codex 原生与 sidecar 校验，再同步 Claude bridge；兼容层不得覆盖原生事实。

## 2. 锁步修改

- 修改 Codex Agent：同步核对 `.codex/config.toml` 声明和对应 `.codex/agents/*.toml`。
- 修改 repo-local skill：同步 `SKILL.md`、`agents/openai.yaml`、必要脚本/引用与技能审计。
- 修改 guardrail：同步 `.codex/rules`、`.codex/hooks.json`、权限 sidecar 和规则矩阵。
- 修改 workflow catalog：先改 catalog/schema/project-map，再更新 Claude manifest、router、bridge 与人工文档。
- 只改 Claude 层时，不复制 Codex sandbox、MCP、Agent 或 approval 配置。

## 3. 审计链

在仓库根目录执行；任何一步失败都先修首个结构性错误，不删除检查或降低规则：

```powershell
$repoRoot = (Resolve-Path .).Path

& pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\validate_codex_sidecars.ps1 -ProjectRoot $repoRoot
if ($LASTEXITCODE -ne 0) { throw "Codex sidecar validation failed" }

& pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_guardrails.ps1 -ProjectRoot $repoRoot
if ($LASTEXITCODE -ne 0) { throw "Codex guardrail audit failed" }

& pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_skills.ps1 -ProjectRoot $repoRoot
if ($LASTEXITCODE -ne 0) { throw "Codex skill audit failed" }

& pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1 -ProjectRoot $repoRoot
if ($LASTEXITCODE -ne 0) { throw "Claude bridge audit failed" }

& pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\analyze_codex_skill_workflows.ps1 -ProjectRoot $repoRoot
if ($LASTEXITCODE -ne 0) { throw "Codex skill workflow analysis failed" }

& pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly -Strict
if ($LASTEXITCODE -ne 0) { throw "Configuration quality gate failed" }
```

治理主链固定使用 `pwsh.exe`；需要 Windows PowerShell 5.1 可移植性的 ASCII fixture 由对应双 Shell 矩阵单独验证。

## 4. 完成标准

- Codex sidecar、skills、guardrails 与 Claude bridge 审计均无结构错误。
- Router 中 Codex/Claude 治理域分离；runtime crash 不再落入 build failure。
- manifest 中 `declarative/compatibility/legacy/manual/external` 含义明确，不把治理 sidecar 或人工 Markdown 宣称为自动执行引擎。
- 所有 active/native 命令指向已跟踪且存在的脚本；外部工具或本地源码明确标记 `manual/external`。
- 输出包含修改文件、权威层级、验证结果、运行时缺口和回滚方式。

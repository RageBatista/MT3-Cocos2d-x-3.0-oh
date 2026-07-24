# Codex Runtime Governance Map

## 分类

| 路径 | 类型 | 运行时含义 |
| --- | --- | --- |
| `.codex/config.toml` | Codex 原生项目配置 | 受信项目中加载；定义 sandbox、approval、features、MCP 与 subagent 入口。 |
| `.codex/agents/*.toml` | Codex subagent 角色 | 由 `.codex/config.toml` 的 `[agents.<name>] config_file` 引用。 |
| `.codex/rules/*.rules` | Codex 项目规则 | 项目本地规则，受信项目中加载。 |
| `.codex/requirements.toml` | 治理 sidecar | 本仓库仅用于审计和策略导出，不等同官方项目 runtime requirements 层。 |
| `.codex/mcp/*.json` | 治理 sidecar | 记录默认/可选 MCP profile，不替代 `config.toml`。 |
| `.codex/permissions/*.json` | 治理 sidecar | 记录 guardrail 映射和审计状态。 |
| `.codex/project-map.json` | 治理 sidecar | 固化 MT3 架构、依赖、目录域和构建入口。 |
| `.codex/workflows/workflow-engine.json` | 治理 sidecar | 固化 Agent 工作流、技能路由和验证门禁。 |
| `.agents/skills/**` | repo-local skill | 可复用任务技能，必须包含 `SKILL.md`，建议包含 `agents/openai.yaml`。 |

## 最小验证链

1. `pwsh.exe -NoLogo -NoProfile -File ./.claude/scripts/validate_codex_sidecars.ps1`
2. `pwsh.exe -NoLogo -NoProfile -File ./.claude/scripts/audit_codex_guardrails.ps1`
3. `pwsh.exe -NoLogo -NoProfile -File ./.claude/scripts/audit_codex_skills.ps1`
4. `pwsh.exe -NoLogo -NoProfile -File ./.claude/scripts/audit_claude_config.ps1`
5. `pwsh.exe -NoLogo -NoProfile -File ./.claude/scripts/analyze_codex_skill_workflows.ps1`
6. `pwsh.exe -NoLogo -NoProfile -File ./.claude/scripts/quality_gate.ps1 -TargetPath .codex`

## 常见漂移

- 把 MT3 项目特例写进全局 `C:/Users/www/.codex/config.toml`。
- 在 `.codex/requirements.toml` 中扩大默认 MCP 集合。
- subagent 只写角色口号，没有工具链、生成代码、ABI、编码和验证边界。
- 新增 skill 后忘记 `agents/openai.yaml` 或 `policy.allow_implicit_invocation`。
- 修改 `.codex` 后未刷新 `.claude/reports/*` 审计报告。

# .claude/config 索引

> 版本: 2.3.0
> 更新: 2026-04-03
> 目标: 让 `.claude/config` 的入口契约、配置分层和审计关系可快速定位。

## 入口链

入口链以 [quality-gates.json](quality-gates.json) 的 `entry_contract` 为准，并由 [audit_claude_config.ps1](../scripts/audit_claude_config.ps1) 校验；`.codex` 与 `.agents` 的最小运行面则由同文件中的 `codex_runtime_contract` 补充约束。

固定顺序：

1. `AGENTS.md`
2. `.claude/RULES.md`
3. `.claude/BUILD_GUIDE.md`
4. `.claude/CODEX_BRIDGE.md`
5. `router.json`
6. `proxies.manifest.json`
7. `agents.manifest.json`
8. `skills.manifest.json`
9. `commands.manifest.json`
10. `workflows.manifest.json`
11. `hooks.manifest.json`
12. `mcp.manifest.json`
13. `quality-gates.json`
14. `evidence-contract.json`
15. `source-authority.json`
16. `evolution.config.json`
17. `.agents/skills/mt3-project-guidelines/SKILL.md`（Codex 原生技能分流）
18. `.claude/CLAUDE.md`

## 配置文件

- [router.json](router.json): 意图分类、资源模式、运行时装载顺序
- [agents.manifest.json](agents.manifest.json): Agent 角色与输出契约
- [skills.manifest.json](skills.manifest.json): Skill 定义、依赖与参数
- [proxies.manifest.json](proxies.manifest.json): 代理编排和回退链
- [commands.manifest.json](commands.manifest.json): 命令清单与绑定关系
- [workflows.manifest.json](workflows.manifest.json): 工作流与意图映射
- [hooks.manifest.json](hooks.manifest.json): Hook 生命周期与守卫脚本
- [mcp.manifest.json](mcp.manifest.json): MCP 治理清单、默认启用集、opt-in 建议与运行时核对入口
- [mcp-servers.sample.json](mcp-servers.sample.json): Claude 本地手工 MCP 示例模板（不代表 Codex 运行时）
- [quality-gates.json](quality-gates.json): 阈值、必需文件、入口契约、治理维度
- [evidence-contract.json](evidence-contract.json): 治理证据契约、状态口径与第一阶段 evidence completeness 基线要求
- [source-authority.json](source-authority.json): 主事实源/派生视图/bridge-sidecar/运行时真值校验点/报告产物分类，以及 route/manifest/skill canonical registry
- [gate-policy.json](gate-policy.json): Gate 决策策略，定义如何将证据状态转换为显式决策（allow/review-required/block），区分高风险缺证据与观察缺口
- [evolution.config.json](evolution.config.json): 自动进化与 backfill 配置

## 核心关系

- `router.json` 负责运行时决定“加载什么”
- `quality-gates.json` 负责定义“必须具备什么”
- `evidence-contract.json` 负责定义“什么算作治理证据、状态如何判定、哪些项当前仍属未证明”
- `source-authority.json` 负责定义“谁是主事实源、谁只是派生视图或 sidecar、route/manifest/skill 应该去哪里取真值”
- `audit_claude_config.ps1` 负责验证“当前配置是否满足上面两者”
- `validate_codex_sidecars.ps1` 负责验证 `.codex` sidecar 与 MCP 默认集是否仍符合官方/仓库口径
- `audit_codex_guardrails.ps1` 负责验证人类规则、原生 `.rules`、requirements sidecar 与 guardrails sidecar 是否仍对齐
- `audit_evidence_baseline.ps1` 负责输出当前治理 evidence gap baseline，并显式区分"静态一致性"与"运行证据完备性"，消费 gate-policy.json 输出显式决策结果
- `test_gate_decision.ps1` (测试用): Gate decision 逻辑验证脚本，用于测试 gate policy 评估机制

补充口径：`.codex/compat/claude-bridge.json` 是 compact bridge sidecar，不承担完整 `load_order` 真值；完整入口顺序以 `router.json + quality-gates.json + evidence-contract.json + source-authority.json` 为准。

## MCP 口径

- `mcp.manifest.json` 是 `.claude` 治理侧的 MCP 清单，不直接驱动 Codex 运行时。
- MT3 当前项目默认启用集为空；`openaiDeveloperDocs` 与其余 MCP 均通过 opt-in profile、命令行覆盖或更高层配置按需启用。
- `mcp-servers.sample.json` 只提供 Claude 本地手工示例，不应当被当作项目真实运行面。
- 需要核对当前 Codex 会话可见的 MCP 时，使用 `codex -C E:\MT3 mcp list`。

## 变更检查

修改以下内容后必须审计：

- 入口顺序
- manifest 文件名或路径
- 必需配置文件
- 工作流强制映射
- MCP 默认启用集合或运行时核对口径
- `.codex/requirements.toml`、`.codex/rules/*.rules` 或 `.codex/permissions/*.json`
- `evidence-contract.json` 或 evidence baseline 审计口径

审计命令：

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\validate_codex_sidecars.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_guardrails.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_evidence_baseline.ps1
codex -C E:\MT3 mcp list
```

## 关联文档

- [README.md](README.md): 目录职责与维护规则
- [../CODEX_BRIDGE.md](../CODEX_BRIDGE.md): Codex/GPT 进入 `.claude` 的桥接流程
- [../CLAUDE.md](../CLAUDE.md): `.claude` 子树职责说明

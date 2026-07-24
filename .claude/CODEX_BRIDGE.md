# MT3 Codex/Claude 配置桥接

> **版本**: 2.4.0
> **更新日期**: 2026-04-20
> **定位**: 本文件只定义 Codex/GPT 进入 `.claude` 配置体系时的治理侧桥接顺序、最小装载策略和回退规则；它不是 Codex 原生自动加载语义的替代品。

---

## 治理侧桥接顺序

1. 先读取根 `AGENTS.md`，获取仓库事实、高层边界和目录治理矩阵。
2. 再读取 `.claude/RULES.md`，锁定工具链、ABI、编码和生成代码硬约束。
3. 涉及构建、重编、发布、产物校验时，读取 `.claude/BUILD_GUIDE.md`。
4. 在治理侧参考 `.claude/config/router.json` 做意图分类，确定 `domain`、`default_proxy`、`primary_agent`、`skills`、`mode`、`workflow_id`。
5. 按治理侧路由结果按需读取以下配置：
   - `proxies.manifest.json`
   - `agents.manifest.json`
   - `skills.manifest.json`
   - `commands.manifest.json`（仅命中命令时）
   - `workflows.manifest.json`（仅路由声明 workflow 时）
   - `hooks.manifest.json`
   - `mcp.manifest.json`（治理/建议清单，不代替 Codex 运行时 MCP 来源）
   - `quality-gates.json`
   - `evidence-contract.json`（治理证据契约与状态口径；仅治理审计任务需要时读取）
   - `source-authority.json`（主事实源/派生视图/bridge-sidecar/运行时真值校验点/报告产物分类，以及 route/manifest/skill 的 canonical registry；仅治理审计任务需要时读取）
   - `evolution.config.json`（仅技能进化或 backfill 相关任务）
6. Codex/GPT 原生技能侧再读取 `.agents/skills/mt3-project-guidelines/SKILL.md`，仅按任务域继续装载命中的 `.agents` 技能。
   - 若用户提到历史 `.claude/skills/**` 技能名或旧文档路径，先参考 `.agents/skills/mt3-project-guidelines/references/legacy-skill-routing.md` 做别名映射，再决定当前 `.agents` 主技能。
7. 需要理解 `.claude` 子树分工时，再读取 `.claude/CLAUDE.md`；它不是事实、规则或命令的替代品。

## MCP 运行面说明

- `.claude/config/mcp.manifest.json` 只负责 `.claude` 治理层的 MCP 清单、意图绑定与建议启用集。
- MT3 当前治理默认集不启用项目 MCP；`openaiDeveloperDocs` 保留为按需能力，避免其初始化耗时超过 VS Code `thread/start` 的 30 秒窗口。
- Codex 实际 MCP 运行面以 `../.codex/config.toml`、已信任的更高层配置合并结果，以及运行中的 managed/system requirements 为准；项目层已显式将所有项目 MCP 设为 `enabled = false`。
- 需要核对当前会话真实可见的 MCP 时，使用 `codex -C E:\MT3 mcp list`，不要只看 `.claude` 下的 manifest 文本。

## 最小装载原则

- 只加载当前路由命中的 Agent、Skill、Workflow、MCP，不批量展开整个 `.claude/skills`。
- Codex 原生技能层只从 `.agents/skills/mt3-project-guidelines/SKILL.md` 再分流，不批量展开整个 `.agents/skills`。
- `mode=light` 时保持最小上下文；`mode=standard/deep` 由 `router.json` 与质量门禁共同约束。
- 构建类任务优先依赖 `.claude/BUILD_GUIDE.md` 的已验证命令，而不是桥接文档中的示例。
- 入口文档只负责导航，不复写 manifest 正文。

## 冲突处理

出现冲突时，按以下顺序裁决：

1. 工程实际文件与已验证脚本
2. `AGENTS.md`
3. `.claude/RULES.md`
4. `.claude/BUILD_GUIDE.md`
5. `../.codex/config.toml` 与 `../.codex/rules/*.rules`
6. `config/*.json` 与各类 manifest
7. `.claude/CODEX_BRIDGE.md`
8. `.claude/CLAUDE.md`

含义：桥接文件不能覆盖根事实，也不能覆盖硬约束和已验证命令。

## 回退策略

- `router.json` 可读但未命中意图：使用其 `fallback` 字段。当前仓库默认回退到 `architecture-proxy + architecture-analyst + project-context + light`。
- `router.json` 缺失或解析失败：先执行配置审计，再按最小安全路径处理任务，避免高风险自动编排。
- `manifest` 引用缺失：先修配置，再继续依赖该配置的高风险动作。

## 生效验证

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\validate_codex_sidecars.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_guardrails.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_evidence_baseline.ps1
codex -C E:\MT3 mcp list
```

通过标准：

- `Standard Layer` 为 `PASS`
- 报告文件存在：
  - `.claude/reports/claude-config-audit.json`
  - `.claude/reports/claude-config-audit.md`
- Sidecar/guardrail 报告存在：
  - `.claude/reports/codex-sidecars-validation.json`
  - `.claude/reports/codex-guardrails-audit.json`
- Evidence baseline 报告存在：
  - `.claude/reports/evidence-baseline-*.json`
  - `.claude/reports/evidence-baseline-*.md`
- `source-authority.json` 存在，且 Evidence baseline 已按其 canonical registry 校验 route / manifest / skill 引用
- Codex 桥接文件与 `.agents` 入口技能同时存在且无漂移警告
- `.claude/config/mcp.manifest.json` 的治理清单与 `codex -C E:\MT3 mcp list` 的运行时集合没有关键误导

## 边界

- 本文件不再维护技能触发清单、教程、学习路线。
- 路由关键词、Agent 参数、Skill 参数、Workflow 绑定以各自 manifest 为准。
- 若需要修改桥接流程，应同时检查 `router.json`、相关 manifest、`.codex/*` 与 `.agents/*` 是否仍一致。

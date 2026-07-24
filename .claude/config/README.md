# .claude/config 配置说明

> 版本: 2.2.0
> 更新: 2026-04-03
> 定位: 本目录只承载 `.claude` 的机器可读配置、入口契约和质量门禁；不重复仓库事实、硬约束和构建命令正文。

## 入口契约

`.claude` 配置链当前有两套契约，统一由 [quality-gates.json](quality-gates.json) 维护：

- `entry_contract`: `.claude` 入口顺序、根入口引用链、预期装载顺序。
- `codex_runtime_contract`: `.codex` 原生运行面、`.agents` 技能元数据，以及 sidecar 校验脚本的最小基线。
- `codex_runtime_contract` 现同时声明 Skills 审计脚本，用于把 Skill 触发边界、元数据与渐进披露要求纳入常规治理。

当前固定入口链：

1. `AGENTS.md`
2. `.claude/RULES.md`
3. `.claude/BUILD_GUIDE.md`
4. `.claude/CODEX_BRIDGE.md`
5. `.claude/config/router.json`
6. `.claude/config/*.manifest.json`
7. `.claude/config/quality-gates.json`
8. `.claude/config/evolution.config.json`
9. `.agents/skills/mt3-project-guidelines/SKILL.md`
10. `.claude/CLAUDE.md`

说明：

- 入口契约由 [quality-gates.json](quality-gates.json) 维护。
- 审计脚本 [audit_claude_config.ps1](../scripts/audit_claude_config.ps1) 直接读取这两套契约做校验。
- 入口链调整时，优先改 `quality-gates.json` 与 `router.json`，再更新入口文档。

## 文件分工

- `router.json`: 意图路由、资源模式、回退策略、运行时 `load_order`
- `agents.manifest.json`: Agent 清单、角色、输入输出契约
- `skills.manifest.json`: Skill 清单、依赖与参数模式
- `proxies.manifest.json`: 代理编排、主/备 Agent、能力包组合
- `commands.manifest.json`: 命令入口与 Agent/Skill 绑定
- `workflows.manifest.json`: 工作流定义与意图映射
- `hooks.manifest.json`: 运行时 Hook 与守卫规则
- `mcp.manifest.json`: MCP 治理清单、默认启用集、意图绑定与运行时核对入口
- `mcp-servers.sample.json`: Claude 本地手工 MCP 示例模板（不代表 Codex 运行时）
- `quality-gates.json`: 质量阈值、必需配置、入口契约、Codex 运行面契约
- `evolution.config.json`: 技能进化与 backfill 自动化配置
- `README.md` / `INDEX.md`: 本目录说明与索引

## MCP 运行时说明

- `.claude/config/mcp.manifest.json` 是 `.claude` 治理层的 MCP sidecar，用来表达默认治理集、opt-in 建议集和审计口径。
- MT3 当前治理默认集不启用项目 MCP；`openaiDeveloperDocs` 与其余服务器通过 `.codex/mcp/mcp-profiles.json` 的 opt-in profile、命令行覆盖或更高层配置按需启用。
- Codex 实际 MCP 运行面不直接由本文件驱动，而是以 `.codex/config.toml`、已信任的更高层配置合并结果以及运行中的 managed/system requirements 为准。
- 需要核对当前项目会话真实可见的 MCP 时，使用 `codex -C E:\MT3 mcp list`。

## 使用顺序

1. 根入口先落到 `AGENTS.md`、`.claude/RULES.md`、`.claude/BUILD_GUIDE.md`
2. 再由 `.claude/CODEX_BRIDGE.md` 进入 `router.json`
3. `router.json` 决定 `proxy / agent / skills / mode / workflow`
4. 按需读取各类 manifest、`quality-gates.json` 与 `evolution.config.json`
5. 涉及 MCP 时，把 `mcp.manifest.json` 当治理清单看待；实际运行时启用面仍需回看 `.codex/config.toml` 并执行 `codex -C E:\MT3 mcp list`
6. Codex/GPT 原生技能任务再从 `.agents/skills/mt3-project-guidelines/SKILL.md` 进入 `.agents` 技能层
7. 最后用 `.claude/CLAUDE.md` 解释 `.claude` 子树职责，而不是反向覆盖前述配置

## 维护规则

1. 新增配置键前，先判断是否属于 manifest、quality gate 或 workflow，而不是继续堆进入口文档。
2. 修改入口链时，至少同步这四处：
   - `quality-gates.json`
   - `router.json`
   - `../scripts/audit_claude_config.ps1`
   - 相关入口文档
3. 修改 `mcp.manifest.json` 时，同时确认它是否仍与 `.codex/config.toml`、`.codex/mcp/mcp-profiles.json` 和当前 `codex -C E:\MT3 mcp list` 的运行面保持一致。
4. 修改 `.codex/requirements.toml`、`.codex/rules/*.rules` 或 `.codex/permissions/*.json` 时，同时执行 sidecar 校验和 guardrail 对齐审计。
5. 修改 `.agents/skills/**` 的 `SKILL.md` 或 `agents/openai.yaml` 时，同时执行 Skills 审计，确认触发边界、默认提示词与验证闭环没有漂移。
6. `README.md` 只解释职责和顺序，不维护教程、案例和临时排障步骤。

## 审计命令

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\validate_codex_sidecars.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_guardrails.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_skills.ps1
codex -C E:\MT3 mcp list
```

通过标准：

- `Standard Layer: PASS`
- 无缺失入口文件与 Codex 运行面必需文件
- `.agents/skills/*/agents/openai.yaml` 元数据完整
- `router.json load_order` 与入口契约一致
- `codex-sidecars-validation.json`、`codex-guardrails-audit.json` 与 `codex-skills-audit.json` 为 `PASS`

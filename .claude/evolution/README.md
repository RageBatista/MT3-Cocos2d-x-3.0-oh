# AI 自动进化技能系统（MT3）

本目录实现 MT3 的“持续学习 + 技能演化”闭环，参考 `everything-claude-code` 的 continuous-learning-v2 机制并做项目化裁剪。

## 目录结构

```text
evolution/
├── README.md
├── projects/
│   └── mt3-default/
│       └── observations.jsonl
├── instincts/
│   └── mt3-instincts.json
├── reports/
│   └── evolution-latest.md
└── evolved/
    └── skills/
        └── continuous-learning-v2.suggestions.md
```

## 执行链路

1. 采集观测：`.\.claude\scripts\evolution_collect.ps1`
2. 演化归纳：`.\.claude\scripts\evolution_evolve.ps1`
3. 回灌提案：`.\.claude\scripts\evolution_backfill.ps1`
4. 一键管线：`.\.claude\scripts\evolution_run.ps1`

## 半自动回灌

默认只生成提案，不会改技能正文：

```powershell
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\evolution_backfill.ps1
```

显式应用已审核规则（需要 `-RuleIds` 或 `-Force`）：

```powershell
# 仅应用指定规则
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\evolution_backfill.ps1 -Apply -RuleIds instinct-log.pattern::LNK

# 应用全部提案（高风险，需人工确认后执行）
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\evolution_backfill.ps1 -Apply -Force
```

## 自动触发

### 本地 Git Hook（pre-push）

当推送包含 `AGENTS.md` 或 `.claude/` 变更时，自动执行：

1. `audit_claude_config.ps1 -LegacyStrict`
2. `evolution_run.ps1`

Hook 文件：`.githooks/pre-push`

### CI 定时任务

工作流：`.github/workflows/claude-evolution-nightly.yml`

- 每日定时执行（北京时间 02:30）
- 支持手动触发（`workflow_dispatch`）
- 推送 `.claude/**` 或 `AGENTS.md` 时也会触发
- 自动归档审计报告与演化产物

## 设计目标

- 自动提取 Git 变更热点、构建日志错误模式、配置审计结果。
- 输出“可复用 instinct 规则”，而不是一次性经验。
- 将演化结果写入建议文件，人工审核后再更新 skill/rule/workflow。

## 安全边界

- 仅在仓库本地读写 `.claude/evolution/*`，不修改业务代码。
- 不自动提交变更，不自动覆盖现有技能文档。
- 默认保留人工审核环节，避免错误策略扩散。

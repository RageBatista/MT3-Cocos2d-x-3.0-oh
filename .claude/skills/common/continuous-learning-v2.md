---
name: continuous-learning-v2
version: 1.1.0
priority: medium
category: common
description: |
  MT3 项目的 AI 自动进化技能系统。用于从 Git 历史、构建日志、配置审计中提炼高频问题与可复用策略，
  形成 instincts（项目直觉规则）并产出技能更新建议。
  触发词: 进化, 持续学习, 自动学习, instincts, skill evolution, 经验沉淀
allowed-tools:
  - Read
  - Bash
  - Write
---

# Continuous Learning v2（MT3 版）

## 目标

将“排障经验”转成“可复用规则”，而不是停留在单次会话记忆。

## 输入源

1. `git log`（近期变更主题、热点文件）
2. `build_logs/`、`tools/engine/build_logs/`（错误模式）
3. `.claude/reports/claude-config-audit.*`（配置质量信号）

## 输出物

- 观测流：`.claude/evolution/projects/mt3-default/observations.jsonl`
- instinct 规则：`.claude/evolution/instincts/mt3-instincts.json`
- 演化报告：`.claude/evolution/reports/evolution-latest.md`
- 技能建议：`.claude/evolution/evolved/skills/continuous-learning-v2.suggestions.md`
- 回灌提案（JSON）：`.claude/evolution/evolved/skills/backfill-proposals.json`
- 回灌提案（Markdown）：`.claude/evolution/evolved/skills/backfill-proposals.md`

## 标准执行流程

1. 采集观测

```powershell
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\evolution_collect.ps1
```

2. 归纳演化

```powershell
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\evolution_evolve.ps1
```

3. 一键运行

```powershell
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\evolution_run.ps1
```

4. 半自动回灌（默认提案模式）

```powershell
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\evolution_backfill.ps1
```

5. 显式应用已审核提案

```powershell
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\evolution_backfill.ps1 -Apply -RuleIds instinct-log.pattern::LNK
```

## 高价值规则应用策略（2026-03）

高价值判定（默认）：

- `confidence >= 0.80`
- 且 `recommended_action` 不是“Keep as observation ...”

本轮已应用到技能文档：

- `instinct-log.pattern::LNK`（0.95）
- `instinct-log.pattern::MSB`（0.81）
- `instinct-log.pattern::error-`（0.84）

本轮保持观察态：

- `instinct-log.pattern::Exception`（0.84）
- `instinct-log.pattern::-`（log.pattern::错误，0.81）

## 规则升级门槛

- `samples >= 3`
- `confidence >= 0.6`
- 每次最多升级 `20` 条规则（防止噪声扩散）

## 落地约束

- 自动演化结果只写建议文件，不直接覆盖 skill/rule/workflow 正文。
- 自动回灌默认只生成提案；写入技能文档必须显式 `-Apply`。
- 所有演化建议需要人工审核后再修改 `.claude/config/*.json` 与 `.claude/skills/*.md`。
- 涉及工具链、ABI、生成代码边界的规则必须与 `AGENTS.md` 和 `.claude/RULES.md` 一致。

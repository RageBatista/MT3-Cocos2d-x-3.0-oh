# 技能自动进化工作流（Skill Evolution Workflow）

> 版本: 1.0.0  
> 更新: 2026-03-05  
> 适用: `.claude` 配置优化、经验沉淀、技能体系持续演进

## 目标

将近期开发活动中的高频问题自动提炼为可复用规则，降低重复诊断成本。

## 标准流程

1. 观测采集：运行 `evolution_collect.ps1` 收集 Git 与日志信号。
2. 规则演化：运行 `evolution_evolve.ps1` 输出 instincts 与建议。
3. 人工评审：审核建议文件，筛选可落地项。
4. 配置更新：更新 skill/rule/workflow/manifest。
5. 稳定性复验：执行 `audit_claude_config.ps1` 确认兼容性。

## 验收标准

- 生成 `instincts` 文件且规则条数 > 0（若样本不足可为 0）。
- 生成演化报告与技能建议文件。
- 审计脚本 `Standard Layer` 通过。

## 关联文档

- [continuous-learning-v2 技能](../skills/common/continuous-learning-v2.md)
- [Claude 配置审计脚本](../scripts/audit_claude_config.ps1)
- [配置质量门禁](../config/quality-gates.json)

---
name: plan
version: 1.0.0
description: 先规划后实施，输出分阶段方案并等待确认
linked-skill: common/search-first
linked-agent: planner
allowed-tools:
  - Read
  - Grep
  - Glob
---

# 计划命令

在改代码前先给出可执行计划，并等待用户确认。

## 输出结构

1. 需求重述
2. 范围与假设
3. 风险分级（高/中/低）
4. 分阶段步骤（含文件范围）
5. 验证方案（命令 + 预期）
6. 回滚方案

## 约束

- 未获确认前，不执行代码修改。
- 计划必须引用 MT3 真实路径与构建入口。


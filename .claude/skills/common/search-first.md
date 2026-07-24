---
name: search-first
version: 1.1.0
priority: medium
category: common
description: |
  研究优先技能。编码前先检索仓库已有实现、现有脚本与可复用依赖，避免重复造轮子。
  触发词: 先调研, 先搜索, 方案对比, 可复用实现, research-first
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# Search First（MT3 版）

## 适用场景

- 新增功能前，怀疑仓库已有近似实现。
- 需要新增依赖或脚本时。
- 技术方案有多个可选路径，需要权衡成本与风险。

## 执行顺序

1. 仓库内检索（必须）
- 使用 `rg` 在 `client/`、`server/`、`tools/`、`.claude/` 中查找同类实现。
- 优先复用已有脚本与工作流。

2. 构建链路检索（必须）
- 核对现有构建脚本是否已覆盖需求（如 `client/Build-MT3-v120.ps1`、`tools/scripts/*.ps1`）。
- 避免新增与既有脚本重复的入口。

3. 外部资料检索（按需）
- 仅在仓库内无可行方案时，查询官方文档或稳定来源。

4. 决策输出
- 采用（Adopt）/ 扩展（Extend）/ 自建（Build）三选一，并说明理由。

## 输出模板

```markdown
## Search-First 决策
- 需求:
- 仓库候选:
- 外部候选:
- 结论: [Adopt/Extend/Build]
- 理由:
- 风险:
```


---
name: verification-loop
version: 1.2.0
priority: high
category: common
description: |
  统一验证闭环技能。把构建、质量检查、回归验证与结果报告串成固定门禁流程。
  触发词: verify, 验证闭环, 质量门禁, pre-pr, pre-commit
allowed-tools:
  - Read
  - Bash
  - Grep
  - Write
---

# Verification Loop（MT3 版）

## 目标

保证每次关键改动具备可验证性，输出统一 PASS/FAIL 结论。

## 核心流程

1. 工具链约束预检
- Windows: v120
- Android: NDK r16 clang + Ant + JDK8
- Server: JDK 1.7/1.8 + Ant

2. 构建验证
- 仅执行与改动范围相关的最小构建集。

3. 质量验证
- 语法/静态检查（若模块提供）。
- 敏感信息与生成代码边界检查。

4. 回归验证
- 关键路径验证（至少 1 条可复现步骤）。

5. 报告归档
- 输出结构化结论，记录残留风险与回滚建议。

## 输出模板

```markdown
VERIFICATION: [PASS/FAIL]
- Scope:
- Build:
- Quality:
- Regression:
- Risks:
- Rollback:
```

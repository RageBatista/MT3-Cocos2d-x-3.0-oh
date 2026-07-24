---
name: orchestrate
version: 1.0.0
description: 多代理编排执行复杂任务
linked-skill: common/verification-loop
linked-agent: workflow-orchestrator
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
---

# 编排命令

按固定代理链路组织复杂任务执行并输出交接记录。

## 默认链路

`planner -> build-error-resolver/build-expert -> code-reviewer -> test-engineer`

## 交接模板

```markdown
## HANDOFF: [from] -> [to]
- Context:
- Changes:
- Risks:
- Required Verification:
- Open Questions:
```

## 结果要求

- 汇总各阶段结论。
- 明确阻断项与解除条件。
- 给出最终 PASS/FAIL 建议。


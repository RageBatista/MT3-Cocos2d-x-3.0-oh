# 代理编排规则

> **优先级**: 🟡 重要  
> **适用范围**: 复杂任务、多阶段交付、跨模块改造

---

## 核心原则

1. 复杂任务先规划
- 涉及多模块或高风险改动时，先走 `planner`。

2. 阶段化交接
- 每阶段必须输出结构化 handoff，避免上下文丢失。

3. 先恢复可构建，再做优化
- 构建失败场景优先使用 `build-error-resolver` 或 `build-expert`。

4. 审查与验证不可省略
- 代码完成后必须经过 `code-reviewer` 与 `test-engineer` 的门禁验证。

---

## 推荐链路

`planner -> build-expert/build-error-resolver -> code-reviewer -> test-engineer`

---

## 交接模板（强烈建议）

```markdown
## HANDOFF: [from] -> [to]
- Context:
- Changes:
- Risks:
- Required Verification:
- Open Questions:
```


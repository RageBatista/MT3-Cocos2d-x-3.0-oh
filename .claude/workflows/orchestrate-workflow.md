# 多代理编排工作流（Orchestrate Workflow）

> 版本: 1.0.0  
> 更新: 2026-03-05  
> 适用: 复杂改造、跨模块联动、需要多视角评估的任务

## 目标

把规划、实现、审查、验证拆成可追踪的代理链路，降低遗漏和返工。

## 推荐链路

1. `planner`
- 重述需求、界定边界、识别风险、给出阶段计划。

2. `build-error-resolver` 或 `build-expert`（按任务类型）
- 执行最小可行改动，优先让构建链路恢复绿色。

3. `code-reviewer`
- 按严重级别输出问题，明确行为回归风险。

4. `test-engineer`
- 执行验证门禁，给出通过条件和残留风险。

## 交接协议（Handoff）

每个阶段结束后都输出以下结构：

```markdown
## HANDOFF: [from] -> [to]
- Context:
- Changes:
- Risks:
- Required Verification:
- Open Questions:
```

## 结束条件

- 所有阻断项关闭。
- 验证门禁状态为 PASS。
- 风险项有明确缓解或回滚方案。


# MT3 AI 代理索引

> **版本**: 1.1.0 | **更新**: 2026-03-05 | **代理数量**: 11

> Canonical Source: Agent 元数据（触发词、输入输出契约、技能绑定）以
> `.claude/config/agents.manifest.json` 为准。

---

## 代理列表

| 代理 | 职责 | 优先级 | 文件 |
|------|------|--------|------|
| build-expert | 构建诊断与修复 | 高 | [build-expert.md](build-expert.md) |
| build-error-resolver | 构建错误最小改动修复 | 高 | [build-error-resolver.md](build-error-resolver.md) |
| code-reviewer | 代码审查与质量门禁 | 高 | [code-reviewer.md](code-reviewer.md) |
| security-auditor | 安全审计与风险缓解 | 高 | [security-auditor.md](security-auditor.md) |
| planner | 任务规划与阶段拆解 | 高 | [planner.md](planner.md) |
| architecture-analyst | 架构分析与演进方案 | 中 | [architecture-analyst.md](architecture-analyst.md) |
| workflow-orchestrator | 多代理编排与交接 | 中 | [workflow-orchestrator.md](workflow-orchestrator.md) |
| test-engineer | 验证与回归设计 | 中 | [test-engineer.md](test-engineer.md) |
| deploy-specialist | 发布部署与回滚 | 中 | [deploy-specialist.md](deploy-specialist.md) |
| performance-analyst | 性能定位与优化 | 中 | [performance-analyst.md](performance-analyst.md) |
| doc-writer | 文档生产与维护 | 低 | [doc-writer.md](doc-writer.md) |

---

## 选择建议

- 复杂改造先用 `planner`。
- 构建失败优先 `build-error-resolver` / `build-expert`。
- 交付前至少经过 `code-reviewer` + `test-engineer`。
- 多阶段任务使用 `workflow-orchestrator` 串联。
# Agents 快速索引

> **版本**: 1.0.0 | **更新**: 2026-02-28 | **代理数量**: 8

---

## 📋 代理列表

### 高优先级代理 (3个)

| 代理 | 模型 | 触发条件 | 快速链接 |
|-----|------|---------|---------|
| **build-expert** | claude-3.5-sonnet | 编译错误、链接失败、工具集问题 | [→](../agents/build-expert.md) |
| **code-reviewer** | claude-3-haiku | 代码审查请求、提交前检查、PR 审查 | [→](../agents/code-reviewer.md) |
| **security-auditor** | claude-sonnet-4-5 | 安全审计需求、漏洞扫描、安全检查 | [→](../agents/security-auditor.md) |

### 中优先级代理 (4个)

| 代理 | 模型 | 触发条件 | 快速链接 |
|-----|------|---------|---------|
| **architecture-analyst** | claude-3.5-sonnet | 架构分析、依赖分析、重构规划 | [→](../agents/architecture-analyst.md) |
| **test-engineer** | claude-3.5-sonnet | 测试需求、测试用例编写、测试执行 | [→](../agents/test-engineer.md) |
| **deploy-specialist** | claude-3.5-sonnet | 部署需求、打包需求、版本发布 | [→](../agents/deploy-specialist.md) |
| **performance-analyst** | claude-sonnet-4-5 | 性能问题、性能优化、瓶颈分析 | [→](../agents/performance-analyst.md) |

### 低优先级代理 (1个)

| 代理 | 模型 | 触发条件 | 快速链接 |
|-----|------|---------|---------|
| **doc-writer** | claude-3-haiku | 文档需求、API文档生成、用户手册 | [→](../agents/doc-writer.md) |

---

## 🎯 按任务类型选择

| 任务类型 | 推荐代理 | 快速链接 |
|---------|---------|---------|
| **编译问题** | build-expert | [→](../agents/build-expert.md) |
| **代码审查** | code-reviewer | [→](../agents/code-reviewer.md) |
| **安全审计** | security-auditor | [→](../agents/security-auditor.md) |
| **架构分析** | architecture-analyst | [→](../agents/architecture-analyst.md) |
| **测试相关** | test-engineer | [→](../agents/test-engineer.md) |
| **部署发布** | deploy-specialist | [→](../agents/deploy-specialist.md) |
| **性能优化** | performance-analyst | [→](../agents/performance-analyst.md) |
| **文档编写** | doc-writer | [→](../agents/doc-writer.md) |

---

## 📊 代理统计

### 按模型分布
```
claude-3-haiku:       2  (25%)
claude-3.5-sonnet:    4  (50%)
claude-sonnet-4-5:    2  (25%)
```

### 按优先级分布
```
高优先级:   3  (37.5%)
中优先级:   4  (50%)
低优先级:   1  (12.5%)
```

---

## 🚀 快速触发示例

### 编译问题
```
"编译失败，LNK2019 错误" → build-expert
"链接错误，找不到符号" → build-expert
```

### 代码审查
```
"请审查这段代码" → code-reviewer
"代码质量检查" → code-reviewer
```

### 安全审计
```
"安全审计" → security-auditor
"漏洞扫描" → security-auditor
```

---

## 📝 版本历史

### 1.0.0 (2026-02-28)
- 初始化代理索引
- 添加快速查找功能
- 添加触发示例

---

**维护者**: MT3 技术团队
**更新周期**: 按需更新

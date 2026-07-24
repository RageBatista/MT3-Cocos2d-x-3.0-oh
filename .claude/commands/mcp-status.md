---
name: mcp-status
version: 1.1.0
description: 查看 MCP 治理清单、运行时实际启用面与漂移风险
linked-skill: common/project-context
linked-agent: doc-writer
allowed-tools:
  - Read
  - Bash
---

# MCP 状态命令

输出当前项目 MCP 治理清单、运行时实际启用面与风险提示。

## 检查项

1. 读取 `.claude/config/mcp.manifest.json`
2. 读取 `../.codex/config.toml`，确认项目级运行时入口
3. 执行 `codex -C E:\MT3 mcp list`，获取当前实际可见的 MCP 集合
4. 比较治理清单与运行时集合是否存在关键漂移
5. 校验必需环境变量声明

## 输出结构

```markdown
## MCP 状态
- Governance Core:
- Governance Optional:
- Runtime Enabled:
- Runtime Disabled:
- Drift:
- Env Requirements:
- Risks:
```

---
name: audit-config
version: 1.0.0
description: 审计 .claude 配置完整性、一致性与引用关系
linked-skill: common/claude-config-engineering
linked-agent: architecture-analyst
allowed-tools:
  - Bash
  - Read
  - Grep
---

# 配置审计命令

执行 `.claude` 机器可读配置审计，确认路由、manifest、工作流、Hook、MCP 与索引文档之间没有漂移。

## 标准命令

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
```

## 输出关注点

1. `Standard Layer` 是否为 `PASS`
2. 是否存在缺失文件、断链、孤儿技能、无工作流映射意图
3. 审计报告是否写入：
   - `.claude/reports/claude-config-audit.json`
   - `.claude/reports/claude-config-audit.md`

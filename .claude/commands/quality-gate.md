---
name: quality-gate
version: 1.0.0
description: 对已改动文件执行编码、生成代码边界与 .claude 审计新鲜度检查
linked-skill: common/verification-loop
linked-agent: test-engineer
allowed-tools:
  - Bash
  - Read
  - Grep
---

# 质量门禁命令

按 MT3 约束执行轻量质量门禁，优先检查当前改动集。

## 默认命令

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly
```

## 可选模式

```powershell
# 检查指定目录
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -TargetPath .\.claude

# 严格模式：告警也返回失败
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly -Strict
```

## 检查项

1. C++/资源文件 BOM 是否符合约束
2. Markdown/JSON/XML/Lua/Java/PowerShell 等文件是否误带 BOM
3. 是否触碰生成代码路径
4. `.claude` 改动后审计报告是否已刷新

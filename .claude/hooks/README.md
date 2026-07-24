# MT3 Hooks 配置说明

> 自动化钩子用于在关键动作前后执行守卫逻辑，降低误操作风险。

---

## 配置入口

1. 机器可读清单：`../config/hooks.manifest.json`
2. Claude Hook 配置样例：`hooks.json`
3. 执行脚本目录：当前目录

`hooks.json` 中的 PowerShell hook 统一由 PowerShell 7 (`pwsh.exe`) 执行，以稳定解析 UTF-8 no-BOM 脚本；需要 Windows PowerShell 5.1 覆盖的守卫由各自双 Shell fixture 单独验证。

---

## 主要守卫

| 守卫 | 触发时机 | 模式 | 脚本 |
|------|----------|------|------|
| 会话初始化概况 | SessionStart | Warn | `session-start-profile.ps1` |
| MSBuild 工具集守卫 | PreToolUse(Bash) | Block | `pre-msbuild-guard.ps1` |
| git commit 敏感信息守卫 | PreToolUse(Bash) | Block | `pre-git-commit-secret-guard.ps1` |
| 生成代码边界提醒 | PostToolUse(Edit/Write/MultiEdit) | Warn | `post-edit-generated-guard.ps1` |
| 编码规范校验 | PostToolUse(Edit/Write/MultiEdit) | Warn | `post-edit-encoding-reminder.ps1` |
| 配置审计提醒 | Stop | Warn | `stop-config-audit.ps1` |
| 改动集质量门禁 | Stop | Warn | `stop-quality-gate.ps1` |

---

## 兼容脚本（保留）

- `validate-toolset.bat`
- `check-secrets.bat`
- `check-generated-code.bat`

这些脚本可用于 Git Hook 或人工调用。

---

## 建议

- 修改 `.claude` 配置后执行：

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
```

- 检查当前改动集时执行：

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly
```

- 提交前执行：

```powershell
cmd /c .\.claude\hooks\check-secrets.bat
```

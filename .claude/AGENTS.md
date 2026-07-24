# MT3 代理配置治理子树规则

> **定位**: `.claude/` 是项目的长文规则源与兼容治理入口；这里默认叠加根 `AGENTS.md`，并与 `.codex/`、`.agents/` 保持联动。

## 首轮路由

- `RULES.md`：构建、ABI、编码、生成代码等硬约束。
- `BUILD_GUIDE.md`：当前已验证的构建与校验命令。
- `CODEX_BRIDGE.md`：Codex/Claude 桥接顺序与回退说明。
- `config/**`：路由、manifest、质量门禁。
- `scripts/**`：审计、质量门禁和辅助治理脚本。

## 本目录硬边界

- Codex 原生运行时配置以 `../.codex/config.toml` 与 `../.codex/agents/*.toml` 为准；`.claude` 负责桥接、路由、审计与长文知识源，不直接替代这些原生入口。
- 改 `.claude` 前先拿到证据，再定根因；证据优先来自当前 manifest、路由命中、审计输出、脚本行为与实际生效配置，不要只因表面症状就做最小补丁。
- 先判定改动属于“事实边界”“命令基线”“桥接/路由”“技能治理”哪一类，再动文件。
- `.claude` 是长文知识源；`AGENTS.md` 与 `.agents/skills/**` 负责渐进式披露，不要把全部长文再复制进技能正文。
- 改 `.claude` 时要同步关注 `.codex/compat`、`.codex/permissions` 和 `.agents/skills` 是否需要联动。
- `.md`、`.json`、`.ps1` 默认保持 `UTF-8 no BOM`；PowerShell 改动后优先跑对应审计脚本。

## 首轮验证入口

```powershell
pwsh.exe -NoLogo -NoProfile -File .\scripts\audit_claude_config.ps1
pwsh.exe -NoLogo -NoProfile -File .\scripts\validate_codex_sidecars.ps1
pwsh.exe -NoLogo -NoProfile -File .\scripts\audit_codex_guardrails.ps1
pwsh.exe -NoLogo -NoProfile -File .\scripts\audit_codex_skills.ps1
pwsh.exe -NoLogo -NoProfile -File .\scripts\analyze_codex_skill_workflows.ps1
pwsh.exe -NoLogo -NoProfile -File .\scripts\quality_gate.ps1 -TargetPath .
```

## 常用技能

- `claude-config-governance`
- `encoding-bom-guard`

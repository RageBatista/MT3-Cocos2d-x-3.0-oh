# MT3 治理脚本说明

> 版本: 2.3.0
> 最后更新: 2026-07-15
> 定位: 记录 `.claude/scripts` 中与配置治理直接相关的脚本职责、输出和推荐执行顺序。

## 推荐执行顺序

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\validate_codex_sidecars.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_guardrails.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_skills.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\analyze_codex_skill_workflows.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly -Strict
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\assert_codex_governance_reports.ps1
```

## 核心脚本

### audit_mt3_docs.ps1 / audit_mt3_docs.py

- 功能: 按 `.claude/config/docs-audit-policy.json` 盘点已跟踪的根 `README.md`、`docs/**/*.md` 与 `plans/**/*.md`，检查重复内容、Markdown 链接、源码行号链接、标题、围栏与根 `docs/` Markdown 编码。
- 当前根文档入口: `docs/01-快速入门` 至 `docs/10-管理文档`，以及 `docs/generated`、`docs/superpowers`。
- 源码行号链接: 支持 `file.cpp:123`、`file.h:40-42`；仅当去掉行号后的仓库内目标是真实文件时校验范围，目录或缺失目标仍作为断链，围栏代码中的示例链接不参与检查。
- 路径基准: PowerShell 包装器与 Python CLI 的相对 policy/output 路径统一基于 `ProjectRoot` 解析，显式绝对路径保持不变，因此可从仓库外工作目录调用。
- 输出: 默认写入由 tracked `.gitignore` 忽略的 `/.superpowers/audits/mt3-docs-audit.json`；也可用 `-OutputPath` 指向仓库外临时目录。报告路径字段使用可移植相对标识，不记录本机绝对路径。

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_mt3_docs.ps1 `
  -ProjectRoot . `
  -OutputPath (Join-Path $env:TEMP 'mt3-docs-audit.json')

pwsh.exe -NoLogo -NoProfile -File .\.claude\tests\test-mt3-docs-audit.ps1 -ProjectRoot .
```

### audit_claude_config.ps1

- 功能: 审计 `.claude/config` 入口契约、manifest 引用、路由完整性，以及 `.codex/.agents` 运行面最小基线。
- 输出:
  - `.claude/reports/claude-config-audit.json`
  - `.claude/reports/claude-config-audit.md`

### validate_codex_sidecars.ps1

- 功能: 校验 `.codex/requirements.toml`、`.codex/mcp/mcp-profiles.json` 与 `.claude/config/mcp.manifest.json` 的 sidecar 口径是否仍与官方/仓库约束一致。
- 重点:
  - `requirements.toml` 是否仍明确声明“sidecar 而非项目级官方运行时入口”
  - `allowed_approval_policies` 是否只使用当前支持值
  - MCP 默认启用集是否仍最小化
- 输出:
  - `.claude/reports/codex-sidecars-validation.json`
  - `.claude/reports/codex-sidecars-validation.md`

### audit_codex_guardrails.ps1

- 功能: 对齐 `.claude/RULES.md`、`.codex/rules/mt3-guardrails.rules`、`.codex/requirements.toml` 与 `.codex/permissions/guardrails.json` 的关键守卫规则。
- 当前审计家族:
  - Win32 官方外部构建入口
  - Android Gradle 禁止
  - 服务端 Maven/Gradle 禁止
  - 未显式声明编码的文本写入保护
- 输出:
  - `.claude/reports/codex-guardrails-audit.json`
  - `.claude/reports/codex-guardrails-audit.md`

### audit_codex_skills.ps1

- 功能: 审计 `.agents/skills/*` 的 `SKILL.md` 与 `agents/openai.yaml`，重点检查触发边界、输入校验、失败处理、输出验证、上下文预算与显式 `allow_implicit_invocation`。
- 重点:
  - `SKILL.md` front matter 是否完整且 `name` 与目录名一致
  - `default_prompt` 是否显式包含 `$skill-name`
  - 隐式触发 Skill 是否具备负向路由边界，避免误触发与上下文扩散
  - 是否通过 `references/` 或短正文实现渐进式披露
- 输出:
  - `.claude/reports/codex-skills-audit.json`
  - `.claude/reports/codex-skills-audit.md`

### analyze_codex_skill_workflows.ps1

- 功能: 依据 OpenAI 官方 Skills 规范，对 `.agents/skills/*` 做工作流健康分析，输出每个 skill 在输入校验、逻辑流程、错误处理、资源效率、触发准确性/运行依赖上的分项得分与建议。
- 重点:
  - 是否符合“单技能单职责、优先指令、显式输入输出、渐进式披露、显式调用策略”这些官方基线
  - 是否存在长正文、隐式触发边界偏弱、依赖声明与运行时快照脱节、旧 `.claude` 技能别名覆盖不足等问题
  - 是否已经把监控脚本接入质量门和 GitHub Actions
- 输出:
  - `.claude/reports/codex-skills-workflow-health.json`
  - `.claude/reports/codex-skills-workflow-health.md`
- 配套清单:
  - `.agents/skills/mt3-project-guidelines/references/skill-development-checklist.md`
  - 用于新增或重构 repo-local skill 前的逐项自检

### quality_gate.ps1

- 功能: 对改动文件执行编码/BOM 质量门禁，并提醒治理类改动是否已重新跑审计。
- 说明:
  - 对 `.codex`、`.claude`、`.agents` 的治理改动，会检查五份报告是否新鲜：
    - `claude-config-audit.json`
    - `codex-sidecars-validation.json`
    - `codex-guardrails-audit.json`
    - `codex-skills-audit.json`
    - `codex-skills-workflow-health.json`
  - C/C++ 文件不再对混合编码目录做一刀切 BOM 约束，而是遵循仓库目录矩阵。

### assert_codex_governance_reports.ps1

- 功能: 在所有审计与 strict quality gate 完成后，读取六份治理 JSON 的顶层状态。
- 语义: 只有六项全部为 `PASS` 才返回 0；`WARN`、`FAIL`、报告缺失、状态字段缺失或 JSON 无效均返回非 0。
- 接入: `codex-governance` catalog 的最终可执行节点与 GitHub Actions 都必须调用本脚本，禁止只凭前序脚本退出码宣称最终 PASS。

## 其他脚本

- `check_precompiled_header.ps1`: 预编译头检查与修复
- `verify_documentation_links.sh`: 文档链接校验
- `verify_documentation_links.bat`: Windows 批处理版链接校验，保留但不推荐

## 维护规则

1. 新增治理脚本时，优先写入 `.claude/reports/` 的机器可读报告，便于被 `quality_gate.ps1` 和其他脚本复用。
2. 修改脚本职责时，同步更新 `.claude/AGENTS.md`、`.claude/config/README.md` 和本文件。
3. 脚本输出默认保持 `UTF-8 no BOM`，避免污染编码审计。

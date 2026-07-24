# MT3 Repo-Local Skill 开发检查清单

本清单用于 MT3 仓库内新增或重构 `.agents/skills/*` 时做首轮自检。目标是把“分析报告里的规则”收敛成可执行门禁，减少后续反复补元数据、补边界、补脚本契约和补治理接线。

适用范围：

- 新增 repo-local skill
- 重构现有 `SKILL.md`
- 新增或重构 `agents/openai.yaml`
- 新增或重构 `scripts/*.ps1`
- 调整 `references/`、`assets/`、旧 `.claude` 技能别名映射或治理入口

## 1. 首轮判断

- [ ] 先确认这个能力是否真的应该做成独立 skill，而不是并入现有 skill
- [ ] 先确认 skill 是否只有一个主职责；若存在两个以上主职责，先拆 skill，再写正文
- [ ] 先确认是否需要脚本；若只是流程指引、边界判断或轻量检索，优先保留为纯指令型 skill
- [ ] 先确认是否需要 `references/` 或 `assets/`；不要把所有细节都塞进 `SKILL.md`

## 2. 目录结构

- [ ] skill 目录名使用小写加连字符
- [ ] 存在 `SKILL.md`
- [ ] 存在 `agents/openai.yaml`
- [ ] 只有在确实需要时才创建 `scripts/`、`references/`、`assets/`
- [ ] 不新增 README、CHANGELOG、INSTALLATION_GUIDE 这类对 agent 无帮助的辅助文档

## 3. Front Matter

- [ ] `SKILL.md` front matter 只包含 `name` 和 `description`
- [ ] `name` 与目录名完全一致
- [ ] `description` 同时说明“做什么”和“何时触发”
- [ ] `description` 对隐式 skill 明确写出负向边界，例如“`不用于` / `不负责`”
- [ ] `description` 不堆实现细节，只写触发语义和边界

## 4. openai.yaml

- [ ] `display_name` 面向人读，短而明确
- [ ] `short_description` 只描述触发场景与能力边界
- [ ] `default_prompt` 显式包含 `$skill-name`
- [ ] `allow_implicit_invocation` 显式配置，不留空
- [ ] 若声明 `dependencies.tools`，必须能解释为什么运行时真的需要这些依赖
- [ ] 若 skill 只该显式调用，不要误开 `allow_implicit_invocation: true`

## 5. SKILL.md 正文

- [ ] 正文保持短入口，不把长教程直接塞进来
- [ ] 正文有 `何时使用`
- [ ] 正文有 `不使用`
- [ ] 正文有 `输入校验`
- [ ] 正文有 `失败处理`
- [ ] 正文有 `输出与验证`
- [ ] 正文有 `资源与上下文预算`
- [ ] 若正文超过约 3500-4000 字符，优先考虑把边缘案例下沉到 `references/`
- [ ] 若 skill 支持多变体、多平台或多链路，正文只保留分流规则，细节移到 `references/`

## 6. 输入参数验证

- [ ] 正文明确写出“先确认什么”
- [ ] 正文明确写出首个阻塞证据应来自哪里
- [ ] 若有脚本，参数名与正文中的输入概念一致
- [ ] 若有路径类参数，脚本必须做路径存在性校验
- [ ] 若有仓库根参数，脚本必须统一走 `Resolve-RepoRootPath`
- [ ] 若参数可选，正文要说明默认行为

## 7. 逻辑处理流程

- [ ] 正文存在明确流程锚点，例如 `使用方式`、`执行顺序`、`标准流程`
- [ ] 流程是可执行步骤，不是泛泛描述
- [ ] 先取证、再定因、再改动的顺序清楚
- [ ] 若要继续读 `references/` 或 `.claude` 长文，正文明确写出“何时再读”
- [ ] 输出里能解释为什么当前应该加载这个 skill，而不是邻近 skill

## 8. 错误处理机制

- [ ] 正文说明常见失败点和处理方向
- [ ] 正文区分硬阻塞与可继续的 warning
- [ ] 若脚本存在，统一输出 `PASS | WARN | FAIL`
- [ ] 若脚本存在，统一通过 `Write-Result` 输出 `status/summary/next/details/data`
- [ ] 脚本在发现硬阻塞时应早失败，不继续给误导性建议
- [ ] 脚本输出至少包含“当前结论 + 下一步动作”

## 9. 资源占用与上下文效率

- [ ] 能用指令解决时，不额外造脚本
- [ ] 能把细节放 `references/` 时，不让 `SKILL.md` 变成长文百科
- [ ] 不重复复制共享 helper、共享 JSON 契约或历史大段说明
- [ ] 若 script 超过一个，确认它们确实承担不同职责，而不是人为拆碎
- [ ] 若 skill 是隐式触发，description 足够精确，不会和邻近 skill 抢同一类任务

## 10. PowerShell 脚本专项

- [ ] 脚本使用 `[CmdletBinding()]`
- [ ] 脚本使用 `Set-StrictMode -Version Latest`
- [ ] 脚本使用 `$ErrorActionPreference = "Stop"`
- [ ] 脚本点源 `scripts/skill-script-helpers.ps1`
- [ ] 脚本设置 `$script:SkillScriptName`
- [ ] 脚本支持 `-Json`
- [ ] 领域字段优先放进 `data`
- [ ] `.ps1` 内尽量保持 ASCII；若需要中文匹配词，优先使用运行期构造，避免 Windows PowerShell 编码误判

## 11. references / assets

- [ ] `references/` 只放需要按需加载的事实、规则、长说明
- [ ] `assets/` 只放输出时要用的模板或资源，不拿来堆文档
- [ ] `SKILL.md` 明确引用了需要时才读的 `references/` 或 `assets/`
- [ ] 同一事实不在 `SKILL.md` 和 `references/` 重复写两份

## 12. 触发准确性

- [ ] 隐式触发 skill 的 description 有专属锚点词
- [ ] 隐式触发 skill 的 description 有负向边界
- [ ] 与邻近 skill 比较后，不存在明显“谁都能命中”的模糊描述
- [ ] 若任务来自旧 `.claude/skills/**` 技能名，已补 `legacy-skill-routing.md`
- [ ] 若 skill 涉及 MCP/外部工具，依赖声明与运行时快照口径一致

## 13. 治理接线

- [ ] 新增或修改 skill 后，补跑 `audit_codex_skills.ps1`
- [ ] 在 workflow health 分析前运行 `audit_claude_config.ps1`，刷新未跟踪的 MCP runtime snapshot
- [ ] 新增或修改 skill 后，补跑 `analyze_codex_skill_workflows.ps1`
- [ ] 若改动涉及 `.claude` 治理入口，`audit_claude_config.ps1` 使用 `-LegacyStrict` 复核兼容层
- [ ] 若改动涉及 `.agents` 或 `.claude`，确认 `quality_gate.ps1` 可通过
- [ ] 若新增的是长期要维护的治理能力，确认是否需要接入 `.github/workflows/codex-skills-quality-gate.yml`

## 14. 推荐验证命令

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_skills.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\analyze_codex_skill_workflows.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -TargetPath .agents -Strict
```

若同时修改 `.claude`：

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1 -LegacyStrict
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -TargetPath .claude -Strict
```

## 15. 快速结论模板

在提交 skill 相关改动前，至少能回答下面 5 个问题：

1. 这个 skill 为什么必须独立存在？
2. 它和最邻近 skill 的边界差异是什么？
3. 它的输入、输出、失败收口是否明确？
4. 它是否把长说明和脚本数量控制在合理范围内？
5. 它的触发、审计、质量门和持续监控是否已经接好？

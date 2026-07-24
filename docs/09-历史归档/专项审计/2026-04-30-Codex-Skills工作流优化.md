# Codex Skills 工作流深度分析与优化方案

## 1. 背景与目标

本文面向 MT3 仓库当前用于 Codex/GPT 运行的 repo-local skills：

- 入口目录：`.agents/skills/*`
- 治理脚本：`.claude/scripts/audit_codex_skills.ps1`
- 运行桥接：`.claude/CODEX_BRIDGE.md`

目标不是只做一次“合规审计”，而是把 Skills 的结构质量、触发准确性、脚本前置校验、错误处理和资源效率，纳入持续、可量化、可回归的治理链，减少后续任务中反复补规则、反复改 skill 的返工。

## 2. 官方规范基线

本次分析严格对齐 OpenAI 官方 Codex Skills 文档：

- Agent Skills: `https://developers.openai.com/codex/skills`

本仓采用的核心基线来自官方文档中的以下原则：

1. Skill 使用渐进式披露，先看元数据，命中后才加载 `SKILL.md`。
2. Skill 的 `description` 决定隐式触发，因此必须有清晰作用域与边界。
3. 每个 Skill 保持单技能单职责。
4. 除非需要确定性行为或外部工具，否则优先使用指令而非脚本。
5. 步骤应写成祈使式，并给出显式输入与输出。
6. 要用真实 prompt 检验触发行为是否准确。
7. `agents/openai.yaml` 应显式声明调用策略和工具依赖。

这些原则直接转译为本仓评估维度：

- 输入参数验证
- 逻辑处理流程
- 错误处理机制
- 资源占用与上下文效率
- 触发准确性与运行依赖

## 3. 当前基线盘点

基于当前审计结果，MT3 仓库 Codex skills 运行面现状如下：

- repo-local skills：14 个
- 含脚本 skills：13 个
- 指令型 skill：1 个
- 共享 helper 入口脚本：1 个
- repo-local 业务脚本：12 个
- 所有脚本均已统一 `PASS/WARN/FAIL + JSON data` 输出契约
- 所有业务脚本均已接入共享 helper
- 所有 skills 已补齐 `allow_implicit_invocation`
- 所有 skills 已补齐输入校验、失败处理、输出验证、上下文预算章节

这说明仓库已经完成了“结构化合规治理”，但在运行效率和执行准确性层面，之前仍有 3 个明显缺口：

1. 现有审计偏静态结构，无法衡量每个 skill 的运行效率、正文体积、隐式触发风险和依赖可用性。
2. 缺少专门面向 Skills 工作流的持续监控入口，修改 `.agents` 后容易只跑结构审计，漏掉运行健康分析。
3. 缺少面向每个 skill 的分项打分和趋势视图，导致优化容易回到“出问题再补规则”的被动模式。

## 4. 问题诊断

### 4.1 输入参数验证

已有优势：

- 所有 skills 都有单独的“输入校验”章节。
- 绝大多数带脚本的 skills 都在脚本入口进行 `RepoRoot`、路径、文件存在性或工具链可见性检查。
- CEGUI/Lua/构建类脚本已具备 `Mandatory` 参数或显式路径解析逻辑。

此前问题：

- 缺少统一的“输入验证质量评分”，无法快速识别哪些 skill 只是“写了输入校验章节”，哪些已经真正做到脚本层前置防呆。
- 无法自动发现“正文有输入规则，但脚本校验深度不足”的弱点。

### 4.2 逻辑处理流程

已有优势：

- 所有 skills 基本都包含“何时使用 / 不使用 / 标准流程 / 输出与验证”。
- 共享 helper 与 JSON 契约已经把脚本输出流程标准化。

此前问题：

- 结构审计只能证明“有流程章节”，不能证明“流程是否够清晰、是否有显式步骤锚点、是否真正符合渐进式披露”。
- 大 skill 是否应继续下沉到 `references/`，此前没有量化信号。

### 4.3 错误处理机制

已有优势：

- 所有 repo-local 脚本都已统一 FAIL/WARN/PASS。
- 构建类、布局校验类、生成链校验类技能都已具备首个阻塞点输出。

此前问题：

- 过去只能验证脚本“契约存在”，不能验证 skill 正文和脚本是否同时具备足够清晰的失败升级路径。
- 没有把“声明依赖存在，但运行面不可见”视作准确性风险来持续跟踪。

### 4.4 资源占用情况

已有优势：

- 仓库已经从旧 `.claude/skills` 长文技能迁移到 `.agents/skills` 短入口模式。
- 已通过共享 helper、统一模板、fact packs、legacy routing 收敛重复上下文。

此前问题：

- 某些技能正文仍偏长，之前没有自动标出“高上下文成本” skill。
- 没有专门统计哪些 skill 会在命中后造成更大的上下文负担。

### 4.5 触发准确性

已有优势：

- 所有技能都显式声明了 `allow_implicit_invocation`。
- 绝大多数隐式 skill 的 description 已包含负向边界。

此前问题：

- 之前没有系统化分析“隐式描述是否过近、是否存在误触发风险”。
- `.claude` 历史技能与 `.agents` 当前主技能之间虽然已有映射，但缺少持续校验机制确保两边不再漂移。

## 5. 已实施优化

### 5.1 新增工作流健康分析脚本

新增：

- `.claude/scripts/analyze_codex_skill_workflows.ps1`

作用：

- 基于官方基线，对每个 skill 输出 5 个维度评分：
  - 输入参数验证
  - 逻辑处理流程
  - 错误处理机制
  - 资源占用与上下文效率
  - 触发准确性与运行依赖
- 输出每个 skill 的问题、建议、依赖状态和风险说明
- 生成：
  - `.claude/reports/codex-skills-workflow-health.json`
  - `.claude/reports/codex-skills-workflow-health.md`

### 5.2 把 Skills 健康分析接入质量门

更新：

- `.claude/scripts/quality_gate.ps1`

新增能力：

- 当 `.agents` 有改动时，除了检查 `codex-skills-audit.json` 是否新鲜，还会检查：
  - `codex-skills-workflow-health.json`
- 推荐命令中新增：
  - `analyze_codex_skill_workflows.ps1`

效果：

- 避免只改了 skills 却忘记重新做健康分析。

### 5.3 新增 GitHub Actions 持续监控

新增：

- `.github/workflows/codex-skills-quality-gate.yml`

作用：

- 在 `.agents/**` 或治理脚本变化时自动执行：
  - `audit_codex_skills.ps1`
  - `analyze_codex_skill_workflows.ps1`
- 自动上传结构审计和工作流健康分析报告

效果：

- 把“本地人工检查”升级为“PR/分支级持续监控”。

### 5.4 把新报告纳入治理资产

更新：

- `.claude/config/source-authority.json`
- `.claude/AGENTS.md`
- `.claude/scripts/README.md`

作用：

- 把新的 workflow health 报告正式纳入治理产物体系
- 把分析脚本加入推荐执行顺序和入口文档

### 5.5 把评分规则沉淀为开发检查清单

新增：

- `.agents/skills/mt3-project-guidelines/references/skill-development-checklist.md`

并同步接入：

- `.agents/skills/mt3-project-guidelines/SKILL.md`
- `.agents/skills/claude-config-governance/SKILL.md`

作用：

- 把“工作流健康分析里的评分维度”收敛成新增或重构 skill 时可直接执行的自检清单
- 让 skill 开发在进入审计脚本和 CI 之前，先完成一轮人工门禁

## 6. 每个 Skill 组件的评估方式

后续所有 skills 统一按下面的方法评估：

### 6.1 输入参数验证

- 是否有输入校验章节
- 正文是否明确“先确认什么”
- 脚本是否声明参数
- 脚本是否校验 `RepoRoot`、路径、文件存在性

### 6.2 逻辑处理流程

- 是否同时有“何时使用 / 不使用 / 流程 / 输出验证”
- 是否存在编号步骤或明确流程锚点
- 是否通过 `references/`、`assets/` 或脚本实现渐进式披露

### 6.3 错误处理机制

- 是否有失败处理章节
- 脚本是否统一 FAIL/WARN/PASS
- 是否能给出首个阻塞点
- 是否能在运行依赖缺失时给出明确告警

### 6.4 资源占用情况

- `SKILL.md` 正文长度
- 是否有必要继续下沉到 `references/`
- 脚本数量是否克制
- 隐式触发边界是否足够清晰，以减少误触发带来的上下文浪费

### 6.5 准确性与运行依赖

- `allow_implicit_invocation` 是否显式配置
- description 是否有负向边界
- 是否存在高相似度隐式描述
- `agents/openai.yaml` 声明的依赖是否能在运行时快照中确认

## 7. 预期改进效果

实施本轮优化后，预期收益如下：

1. 技能运行效率提升
   - 高上下文成本的 skills 会被持续标记，促使正文进一步收敛到短入口模式。
2. 技能执行准确性提升
   - 触发边界、依赖可用性、描述相似度不再只靠人工判断。
3. 返工率下降
   - `.agents` 有改动时，质量门会直接提示是否遗漏 workflow health 分析。
4. 治理链更可回归
   - 以后可以直接比较 `codex-skills-workflow-health.json` 的结果，看到哪些 skill 真正变好或变差。

## 8. 持续监控机制

### 8.1 本地执行顺序

```powershell
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\audit_codex_skills.ps1
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\analyze_codex_skill_workflows.ps1
powershell -ExecutionPolicy Bypass -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly -Strict
```

### 8.2 CI 执行入口

- `.github/workflows/codex-skills-quality-gate.yml`

### 8.3 监控重点指标

- 平均得分
- 低于 85 分的 skills
- 超过 4000 字符的 skills
- 隐式触发高相似度告警数
- 运行依赖缺失告警数
- 历史 `.claude` 技能别名映射缺口

## 9. 结论

MT3 当前的 Codex skills 已经具备较好的结构化基础，真正的下一阶段问题不再是“有没有规则”，而是“这些规则是否被持续量化、持续验证、持续监控”。本轮优化把技能治理从静态合规，提升到了动态健康分析和持续监控层面，后续可在不大幅增加维护成本的前提下，持续提升 skill 的运行效率与执行准确性。

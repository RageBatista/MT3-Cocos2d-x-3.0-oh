---
name: codex-runtime-governance
description: "Use when MT3 任务涉及 `.codex/**` 原生运行配置、MCP、rules、subagent、审计 sidecar，或 `.agents/skills/**` 的 Codex 原生元数据、触发边界与验证；不用于 `.claude` 桥接兼容层或业务代码修复。"
---

将 `.codex/config.toml` 视为 MT3 项目级 Codex 原生运行入口，将 `.codex/requirements.toml`、`.codex/mcp/`、`.codex/permissions/`、`.codex/project-map.json` 与 `.codex/workflows/workflow-engine.json` 视为审计和治理 sidecar。

## 何时使用

- 修改或审查 `.codex/config.toml`、`.codex/agents/*.toml`、`.codex/rules/*.rules`、`.codex/requirements.toml`、MCP 配置或 workflow sidecar 时。
- 新增、重构或审计 `.agents/skills/**`，并需要确认 `agents/openai.yaml`、触发边界、依赖和质量门禁时。
- 需要把 MT3 的目录架构、旧工具链、生成代码边界或验证入口同步到 Codex 运行面时。

## 不使用

- 不用于客户端业务、服务端业务、Lua UI、渲染、资源发布或构建问题本身；这些任务先走对应 MT3 专题技能。
- 不负责修改全局 `C:/Users/www/.codex`。项目特例只能落在 `E:/MT3/.codex`、`E:/MT3/.agents` 或就近 `AGENTS.md`。
- 不负责 `.claude/CODEX_BRIDGE.md`、`.claude/config/**`、hooks、proxy 或 workflow 的桥接兼容治理；原生层确认后再组合 `claude-config-governance`。
- 不把 `.codex/requirements.toml` 宣称为官方项目级 runtime requirements；本仓库仅把它作为 schema-compatible sidecar。

## 输入校验

1. 先确认目标文件属于原生运行入口、审计 sidecar、subagent 配置、repo-local skill 或规则文件；若目标是 `.claude` 桥接文档，转入 `claude-config-governance`。
2. 涉及 Codex、MCP、rules、skills 或 subagents 语义时，先用 Codex manual 或 `openaiDeveloperDocs` 核对官方运行面。
3. 修改中文 Markdown/TOML/JSON/YAML 前，确认 BOM 与换行；新建治理文件默认 UTF-8 no BOM + LF。
4. 若同步项目事实，先回到 `AGENTS.md`、就近 `AGENTS.md`、`.claude/RULES.md`、`.claude/BUILD_GUIDE.md` 与真实源码目录取证。

## 执行顺序

1. 先恢复或收敛 `.codex/config.toml`：只放项目级 runtime 默认值、默认 MCP、features 与 subagent 入口。
2. 再维护 `.codex/agents/*.toml`：角色必须有清晰职责、行为边界、工具链约束、只读/可写边界和验证职责。
3. 再同步 sidecar：`requirements.toml` 只描述可导出策略，`mcp-profiles.json` 和 `guardrails.json` 只做审计和映射，`project-map.json` 和 `workflow-engine.json` 固化项目事实与工作流。
4. 最后维护 `.agents/skills/**`：保持短入口，深度资料放 `references/`，`default_prompt` 必须包含 `$skill-name`。
5. 若任务跨到 `.claude`，先完成以上原生层校验，再组合 `claude-config-governance` 同步桥接层。

## 失败处理

- 若官方文档、项目文档和工程实物冲突，先记录冲突；Codex 运行面以官方文档为准，项目业务事实以工程实物和已验证命令为准。
- 若验证脚本失败，先修首个结构性错误；不要通过删除审计脚本或降低规则来绕过失败。
- 若运行时 MCP 快照与 sidecar 不一致，标记为 runtime drift，并要求重新执行 `codex -C E:/MT3 mcp list` 或等价快照命令。

## 输出与验证

- 输出至少包含：修改文件、运行面/sidecar 分类、官方规范依据、验证命令和结果、剩余风险。
- 修改 `.codex` 后运行：`validate_codex_sidecars.ps1`、`audit_codex_guardrails.ps1`、`quality_gate.ps1 -TargetPath .codex`。
- 修改 `.agents/skills` 后运行：`audit_codex_skills.ps1` 与 `analyze_codex_skill_workflows.ps1`。
- 同时修改 `.codex` 与 `.agents` 时，五条验证命令全部执行并记录结果。

## 资源与上下文预算

- 默认只读当前目标文件、`AGENTS.md`、`.claude/RULES.md`、`.claude/BUILD_GUIDE.md` 和官方 Codex 相关片段。
- 仅当需要字段速查、审计口径或 sidecar 分类时再读取 `references/codex-runtime-map.md`。
- 不批量展开全部 `.claude` 长文或所有技能正文；按任务域加载最小技能集合。

## 需要时再读

- `references/codex-runtime-map.md`
- `.codex/project-map.json`
- `.codex/workflows/workflow-engine.json`
- `.claude/CODEX_BRIDGE.md`

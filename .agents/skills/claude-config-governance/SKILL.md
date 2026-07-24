---
name: claude-config-governance
description: "Use when MT3 任务涉及 `.claude/CODEX_BRIDGE.md`、`.claude/config/**`、hook、proxy、workflow、manifest 或 Codex/Claude 桥接兼容层；不用于 `.codex` 原生配置、`.agents/skills` 技能治理或业务代码修复。"
---

把 `.claude` 视为 Claude 侧长文知识源与 Codex/Claude 桥接层。`.codex` 与 `.agents/skills` 的原生治理先进入 `codex-runtime-governance`；本技能只处理桥接映射、兼容路由和 Claude 侧审计。技能正文保持短入口，深度内容下沉到 `references/`。

## 何时使用

- 任务涉及 `.claude/CODEX_BRIDGE.md`、`.claude/config/**`、`.claude/hooks/**`、proxy、workflow、manifest 或 Codex/Claude 跨工具兼容层时，使用本技能
- 需要把已经在 Codex 原生层确认的治理改动同步到 Claude 桥接、审计或质量门禁时，使用本技能

## 执行顺序

1. 先确认事实来源：`AGENTS.md` -> `.claude/RULES.md` -> `.claude/BUILD_GUIDE.md` -> 已对齐 `docs/`
2. 若改动同时命中 `.codex/.agents`，先用 `codex-runtime-governance` 校正原生层，再确认 `.claude` 需要同步的桥接映射
3. 只同步当前桥接任务真正需要的事实，不复制整套文档
4. 技能优先采用渐进式披露：主技能短说明，深度资料放 `references/`

## 不使用

- 用户任务明确属于客户端业务、服务端业务、资源发布或渲染问题时，不把本技能当成主技能
- 只做单个业务文件修复而不涉及治理链、配置链或技能链时，不要引入本技能扩散上下文

## 输入校验

- 先确认目标确属 `.claude` 桥接、兼容路由或 Claude 侧审计；若根因在 `.codex/.agents` 原生层，先转入 `codex-runtime-governance`
- 先确认 `.claude/config/*.json`、`.claude/hooks/hooks.json`、`.claude/settings*.json` 是否为真实内容；若首行是 `version https://git-lfs.github.com/spec/v1`，先运行 `git lfs checkout .claude/config .claude/hooks/hooks.json .claude/settings.json .claude/settings.local.json`
- 先确认是否需要官方规范；涉及 Codex/Skills/MCP 时，优先对齐 `openaiDeveloperDocs`
- 先确认本次需要同步的事实源和验证脚本，避免只改文档不改入口
- 若任务从旧 `.claude/skills/**` 技能名发起，先读 `../mt3-project-guidelines/references/legacy-skill-routing.md`，明确当前 `.agents` 运行时主技能，再决定是否同步桥接层

## 治理要求

- 保留根 `AGENTS.md` 作为跨工具统一入口
- 涉及 OpenAI API、Codex、MCP、`AGENTS.md` 或技能规范时，优先使用 `openaiDeveloperDocs` MCP 校对官方原文
- `.codex/.agents` 的原生字段、技能元数据与触发边界由 `codex-runtime-governance` 校验；本技能只检查桥接 manifest、router 与审计映射是否一致
- 本技能正文只保留桥接决策、入口路径、边界和何时继续读 `references/`
- 桥接配置改动后必须做结构校验，并补跑 Claude 侧兼容审计
- `.claude/config` 被 Git LFS 管理时，不把 pointer 文件当成有效 JSON；恢复实物并通过 `ConvertFrom-Json` 后再运行治理审计

## 重点输出

- `.claude/CODEX_BRIDGE.md`
- `.claude/config/*`
- `.claude/hooks/*`
- `.claude/settings*.json`
- `.claude/scripts/*` 中的桥接审计入口

## 失败处理

- 若项目事实、桥接文档和官方规范冲突，先记录冲突点，再以工程入口和官方运行面定义为准
- 若治理改动同时影响 `.claude/.codex/.agents`，先完成 Codex 原生层校验，再同步 Claude 桥接层并补跑两侧审计，不做“桥接层先行”的倒序提交

## 输出与验证

- 输出至少包含：事实来源、受影响入口、同步文件、验证命令、剩余风险
- 修改桥接文档、manifest、router 或 hook 后，至少运行 `audit_claude_config.ps1` 与对应结构审计
- 若本轮同时命中 Codex 原生层，先保留 `codex-runtime-governance` 的验证结果，再执行 Claude 侧兼容审计

## 资源与上下文预算

- 默认先读最靠近任务的入口文件和 manifest，不批量展开所有 `.claude` 技能长文
- `references/skill-governance.md` 只在需要模板、规范或迁移口径时展开

## 需要时再读

- `references/skill-governance.md`
- `../mt3-project-guidelines/references/legacy-skill-routing.md`
- `../mt3-project-guidelines/references/skill-development-checklist.md`
- `.claude/CODEX_BRIDGE.md`
- `.claude/skills/common/claude-config-engineering.md`

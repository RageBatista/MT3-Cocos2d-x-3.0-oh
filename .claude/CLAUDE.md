# MT3 .claude 配置入口说明

> **版本**: 3.0.0
> **更新日期**: 2026-03-06
> **定位**: 本文件只说明 `.claude` 子树的入口职责、装载边界和维护规则；不重复仓库事实、硬约束和构建命令。

---

## 入口职责

| 入口 | 职责 | 不再承载 |
|------|------|------|
| `../AGENTS.md` | 仓库事实、高层边界、目录治理矩阵 | 教程、案例、构建细节 |
| `.claude/RULES.md` | 硬约束：工具链、ABI、编码、生成代码、目录例外 | 教程、学习路线、过时脚本 |
| `.claude/BUILD_GUIDE.md` | 已验证可执行命令 | 问题复盘、专题排障 |
| `.claude/CODEX_BRIDGE.md` | Codex/GPT 进入 `.claude` 配置体系的桥接流程 | 项目事实、规则正文、命令清单 |
| `.claude/CLAUDE.md` | `.claude` 子树职责说明与维护约定 | Agent/Skill 教程、技能速查、质量规范正文 |

## `.claude` 子树分工

| 文件 | 单一职责 |
|------|------|
| `config/router.json` | 意图路由、默认代理、资源模式、回退策略 |
| `config/proxies.manifest.json` | 代理层编排与主/备 Agent 绑定 |
| `config/agents.manifest.json` | Agent 清单、角色、输入输出契约 |
| `config/skills.manifest.json` | Skill 清单、依赖、参数模式 |
| `config/commands.manifest.json` | 命令入口与 Agent/Skill 绑定 |
| `config/workflows.manifest.json` | 工作流编排定义 |
| `config/hooks.manifest.json` | 运行时钩子与守卫规则 |
| `config/mcp.manifest.json` | MCP 服务器清单与启用策略 |
| `config/quality-gates.json` | 配置质量门禁阈值 |
| `config/evolution.config.json` | 技能进化与 backfill 自动化配置 |
| `scripts/audit_claude_config.ps1` | 对 `.claude` 配置做结构审计 |

## 装载与优先级

统一原则：文档负责解释，`config/*.json` 与工程文件负责落地。若二者冲突，以更接近执行面的对象为准。

优先级从高到低如下：

1. 工程实际文件与已验证脚本
2. `../AGENTS.md`
3. `.claude/RULES.md`
4. `.claude/BUILD_GUIDE.md`
5. `.claude/CODEX_BRIDGE.md`
6. `.claude/config/*.json` 与各类 manifest 的字段解释说明
7. `.claude/CLAUDE.md`

说明：

- `router.json` 可以定义运行时加载顺序，但不能推翻根事实、硬约束和已验证命令。
- `CLAUDE.md` 只解释 `.claude` 怎么组织，不再复写 Agent/Skill 教程内容。
- 需要具体能力时，应直接查看对应 manifest 或技能文件，而不是继续在入口文档堆说明。

## 维护约定

1. 新增入口文件前，先明确它是否真的承担独立职责；不能与 `AGENTS.md`、`RULES.md`、`BUILD_GUIDE.md`、`CODEX_BRIDGE.md` 重叠。
2. 调整 Agent、Skill、Command、Proxy、Workflow、Hook、MCP 时，优先修改对应 manifest，再补入口说明。
3. 入口文档不得再写教程、学习路线、专题排障、历史案例。
4. 桥接顺序、回退策略和质量门禁变化后，必须执行一次配置审计。

## 审计命令

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
```

审计目标：

- 入口文件存在且能被引用
- 路由、代理、Agent、Skill、Workflow、Hook、MCP 之间的引用闭合
- 必需配置文件齐全
- 质量门禁与技能进化配置可解析

## 边界提醒

- 若任务是仓库事实或目录治理问题，返回 `../AGENTS.md`。
- 若任务是工具链、ABI、编码、生成代码边界，返回 `.claude/RULES.md`。
- 若任务是构建、重编、产物校验命令，返回 `.claude/BUILD_GUIDE.md`。
- 若任务是 Codex/GPT 如何进入 `.claude` 体系，返回 `.claude/CODEX_BRIDGE.md`。

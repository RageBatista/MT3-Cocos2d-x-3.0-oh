---
name: claude-config-engineering
version: 1.3.0
priority: medium
category: common
description: |
  .claude 配置工程技能。用于新增或优化 MT3 项目的路由、代理、技能、命令、Hooks、Rules、MCP 与工作流配置时，确保配置与仓库真实代码入口、工具链约束和验证脚本保持一致。
  触发词: .claude, Claude 配置, manifest, hook, MCP, proxy, command, workflow, config governance
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
---

# Claude Config Engineering（MT3 版）

## 目标

让 `.claude + .codex + .agents` 共同成为仓库真实实现的镜像，而不是脱离代码的独立文档层。

## 必查源码锚点

- Windows 构建入口：`client/Build-MT3-v120.ps1`、`client/MT3Win32App/mt3.win32.vcxproj`、`client/FireClient/FireClient.sln`
- Android 构建入口：`client/android/LocojoyProject`、`client/android/JoysdkProject`、`client/android/YijieProject`；`client/android/LocojoyProject64` 已废弃，不再作为输出目录
- 服务端构建入口：`server/server/game_server/build.xml`
- 协议与数据定义：`server/server/game_server/protocol.main.xml`
- tolua++ 源定义：`client/tolua++-pkgs/**/*.pkg`
- 客户端协议生成产物：`client/FireClient/Application/ProtoDef/`
- 生成代码守卫：`server/**/xbean/*.java`、`server/**/rpc/*.java`
- 配置审计脚本：`.claude/scripts/audit_claude_config.ps1`
- Codex 原生技能入口：`.agents/skills/mt3-project-guidelines/SKILL.md`

## 锁步更新顺序

1. 先扫描源码与脚本入口，确认配置要服务的真实对象。
2. 再决定需要改哪一层：`router`、`proxy`、`skill`、`command`、`hook`、`workflow`、`mcp`。
3. 变更机器可读配置时，同步更新对应文档索引、`.codex` 桥接和 `.agents` 入口说明。
4. 新增命令或 Hook 时，必须绑定仓库内真实脚本或真实路径，禁止“只有说明，没有执行体”。
5. 修改完成后，至少执行：
   - `pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1`
   - `pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly`

## 设计约束

- 路由必须绑定真实意图，不要为了“看起来完整”创建无入口意图。
- Proxy 必须有清晰主 Agent、回退 Agent 和最小技能包。
- Skills 只沉淀 MT3 特有流程，不重复写通用常识。
- Hooks 默认非破坏；阻断型 Hook 只用于高风险操作。
- MCP 默认最小启用，只有在任务明显需要外部上下文时才加可选服务器。

## 高风险边界

- 不要把生成代码目录当作手工编辑目录。
- 不要新增和仓库现有脚本重复的命令入口。
- 不要在未更新 manifest 的情况下只改 Markdown 文档。
- 不要修改 `.claude` 后跳过审计与编码/BOM 校验。

## 输出模板

```markdown
## Claude Config 变更方案
- 目标:
- 代码锚点:
- 需要变更的配置层:
- 新增/修改文件:
- 审计命令:
- 风险与回滚:
```

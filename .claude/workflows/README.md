# `.claude/workflows` 兼容工作流视图

> 版本: 2.0.0
> 更新: 2026-07-12

## 权威关系

1. `.codex/workflows/workflow-engine.json`（`kind = workflow-catalog`）是机器可读治理 sidecar/声明式事实源，负责描述节点、成功/失败转移、证据、回滚和可用性；它不是 Codex 原生运行时工作流引擎。
2. `.claude/config/workflows.manifest.json` 维护 Claude 兼容 ID、catalog aliases 与 `declarative/compatibility/legacy/manual/external` 状态。
3. 本目录 Markdown 是兼容人工视图，不是自动执行引擎，也不得覆盖 catalog。

## 兼容视图索引

| Claude workflow ID | Catalog ID | 状态 | 人工文档 |
|---|---|---|---|
| `windows-build-workflow` | `win32-build` | compatibility/manual | [Windows 构建](windows-build-workflow.md) |
| `android-build-workflow` | `android-build` | compatibility/manual + external toolchain | [Android 构建](android-build-workflow.md) |
| `server-build-workflow` | `server-ant-build` | compatibility/manual | [服务端构建](server-build-workflow.md) |
| `cegui-build-workflow` | `cegui-layout-integration`、`cocos-cegui-shadow-migration` | compatibility/manual + external source | [CEGUI 0.7.1 / Cocos shadow](cegui-build-workflow.md) |
| `runtime-crash-workflow` | `runtime-crash` | compatibility/manual | [运行时崩溃诊断视图](error-diagnosis-workflow.md) |
| `codex-governance-workflow` | `codex-governance` | compatibility/manual | [Codex/Claude 配置治理](claude-config-workflow.md) |
| `claude-config-workflow` | 无精确 catalog 节点 | legacy/manual | [Claude 配置治理兼容视图](claude-config-workflow.md) |
| `error-diagnosis-workflow` | 无单一映射 | legacy/manual | [通用错误诊断](error-diagnosis-workflow.md) |
| `verification-workflow` | 无通用 catalog 对应 | legacy/manual | [验证门禁](verification-workflow.md) |
| `skill-evolution-workflow` | 无精确 catalog 节点 | legacy/manual | [技能进化](skill-evolution-workflow.md) |
| `orchestrate-workflow` | 无精确 catalog 节点 | legacy/manual | [多代理编排](orchestrate-workflow.md) |

以下 catalog 工作流当前没有单独 Claude Markdown，直接读取 catalog：`lua-ui-integration`、`resource-packaging`、`sprite-pack-algorithm`、`application-core-flow`、`resource-name-path-recovery`。`ios-platform` 需要 macOS/Xcode，状态为 `external-platform`。

## 选择建议

- 编译/链接/工具链错误：使用对应平台构建视图；不得把 `SIGSEGV`、Access Violation、`0xC0000005`、`FATAL EXCEPTION` 或闪退归入 build failure。
- 运行时崩溃：路由到 `runtime_crash` / `runtime-crash-workflow`，优先日志、堆栈、时间戳、二进制和复现证据。
- `.codex/**` 或 `.agents/skills/**`：路由到 `codex_config_governance`，先处理原生层。
- `.claude/**`：路由到 `claude_config_governance`；跨层时在 Codex 原生层校验后再同步 bridge。
- CEGUI：资源 XML/WidgetLook 使用 `cegui-layout-integration`；CEGUI 0.7.1 外部源码与 Cocos2d-x 2.2.6 shadow 构建使用 `cocos-cegui-shadow-migration` 的人工门禁。

## 维护约束

- 新增/重命名 workflow 时先改 Codex catalog，再同步 manifest、router、bridge 和本索引。
- catalog 中 `availability=tracked_required` 的 command 只能引用已跟踪且存在的仓库脚本；未跟踪源码、SDK、Xcode、证书等必须标记 `manual/external`。
- 所有路径先 `git ls-files` / `Test-Path`，再通过目标 shell 的合法调用语法执行；PowerShell 可执行路径或脚本使用 `&`。
- 更新后运行 `audit_claude_config.ps1`、Codex sidecar/skills/guardrails 审计与严格质量门禁。

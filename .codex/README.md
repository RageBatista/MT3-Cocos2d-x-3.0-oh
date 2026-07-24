# MT3 项目级 Codex 治理说明

> 更新：2026-07-16
> 定位：说明 `.codex/` 的原生运行面、治理 sidecar、工作流目录、继承边界与统一验证入口。

## 1. 权威边界

MT3 的配置按以下顺序裁决：

1. 工程实物、日志、调用链、构建输出和已验证脚本。
2. 根/就近 `AGENTS.md`、`.claude/RULES.md`、`.claude/BUILD_GUIDE.md`。
3. `.codex/config.toml`、`.codex/rules/*.rules`、`.codex/hooks.json`、`.codex/agents/*.toml`。
4. `.codex/project-map.json`、工作流目录和其他治理 sidecar。
5. `.claude` router/manifest/workflow 文档等兼容视图。

工程事实与配置冲突时先修配置；Claude 兼容层不能覆盖 Codex 原生配置或工作流事实目录。

## 2. 原生运行面与 sidecar

### 2.1 Codex 原生运行面

| 路径 | 作用 | 生效条件 |
| --- | --- | --- |
| `config.toml` | 项目审批、沙箱、搜索、Agent、MCP 入口 | 仓库被信任 |
| `rules/mt3-guardrails.rules` | `execpolicy` argv 前缀规则 | 项目规则被加载 |
| `hooks.json` | `PreToolUse` hook 声明 | 仓库被信任，且 hook 哈希已在 `/hooks` 审查 |
| `hooks/mt3-pretool-guard.ps1` | wrapper、编码、Git 和生成物补充守卫 | 由 `hooks.json` 调用 |
| `agents/*.toml` | 13 个 MT3 子代理角色 | `config.toml` 相对路径解析成功 |

项目 hook 是补充 guardrail，不是完整安全边界：它只能拦截当前 Codex 提供的对应 hook/tool 路径。真实约束仍由 rules、仓库指令、测试和审计共同闭环。

### 2.2 治理 / 审计 sidecar

| 路径 | 作用 | 是否直接改变项目运行时 |
| --- | --- | --- |
| `requirements.toml` | managed/system requirements 的审计与导出模板 | 否；必须由管理员部署到受支持层级 |
| `project-map.json` | 目录、修改策略、可用性、生成边界和构建入口事实索引 | 否 |
| `schemas/*.schema.json` | project map 与 workflow catalog 的 JSON Schema | 否 |
| `workflows/workflow-engine.json` | 声明式 `workflow-catalog` | 否；不是自动执行引擎 |
| `mcp/mcp-profiles.json` | advisory/managed-export MCP 集合 | 否；不会自动切换 MCP |
| `permissions/guardrails.json` | 原生规则、hook、权威来源和测试的交叉索引 | 否 |
| `compat/claude-bridge.json` | Codex 与 Claude Agent/skill/workflow 别名 | 否 |

sidecar 只能记录、校验和导出事实，不能被文档描述提升为 Codex 原生运行能力。

## 3. 当前项目默认值

```text
approval_policy = on-request
sandbox_mode    = workspace-write
web_search      = cached
personality     = pragmatic
multi_agent     = true
max_threads     = 4
max_depth       = 1
project MCP     = 23 个 disabled override（enabled=0）
```

- `features.multi_agent` 显式保留，因为项目声明了 13 个协作角色。
- `personality` 与 `shell_snapshot` 的稳定默认 feature 开关不再重复固定；只保留顶层 `personality = "pragmatic"` 作为项目沟通风格。
- Agent 不固定模型，默认继承当前会话模型；角色 TOML 只保留 `high` 或 `medium` reasoning effort 与角色边界。
- 只读 Agent 不承诺直接实施；写操作由实现/构建角色或主代理承担。
- `config.toml` 显式声明当前 23 个已知 MCP server，全部设为 `enabled = false`；需要某个 server 时必须通过当前会话或命令行显式覆盖。

## 4. MCP 项目声明与继承漂移

项目 `config.toml` 对当前已知集合声明 23 个 disabled override，用项目层同名配置收敛可信用户、系统、managed 和插件层的合并结果。该集合是当前运行面的显式关闭清单；上层新增未被项目列出的 server 时，仍需通过运行快照识别并同步清单。

禁用原因有可复现的版本证据：VS Code 扩展 `26.707.71524` 内置 Codex `0.144.2` 时，启用该 MCP 的 `mcp list --json` 耗时 `33319ms`，临时覆盖为禁用后耗时 `112ms`；VS Code 的 `thread/start` 固定在 `30000ms` 超时，因此默认启用会直接阻断新任务创建。客户端修复后可用以下覆盖重新评估：

```powershell
codex -C E:\MT3 -c 'mcp_servers.openaiDeveloperDocs.enabled=true' mcp list --json
```

运行面必须通过命令取证：

```powershell
codex -C E:\MT3 mcp list --json
codex -C E:\MT3 --strict-config doctor --json
```

2026-07-16 当前项目快照为 configured=23、enabled=0、project-default=0；`configured` 包含已配置但禁用的 server，因此不等于启用数。该数字描述当前项目关闭集与合并运行面，审计必须分别报告：

- 项目默认集合；
- 合并后 configured/enabled 集合；
- enabled 与项目默认的差集；
- enabled 与项目关闭清单的差集，作为新增继承项或配置漂移证据。

`mcp-profiles.json` 是 advisory/managed-export 目录，`runtime_effect = "none"`，不会自动启停服务器。需要切换时必须显式覆盖当前会话配置，或由管理员导出并部署到 managed/system requirements。

## 5. Agent 与技能路由

### 5.1 Agent

`config.toml` 通过相对 `.codex/` 的 `agents/*.toml` 声明 13 个角色：架构、构建、Codex 治理、文档研究、Lua UI、性能、计划、资源、审查、运行时、安全、服务端协议和测试。

校验重点：

- `config_file` 必须存在且使用相对路径；
- 不写死模型；
- 角色权限与提示词一致；
- 只读角色不含实施承诺；
- 构建/治理事实以项目脚本和当前文档为准。

### 5.2 技能

Repo-local skills 位于 `.agents/skills/`，入口是 `mt3-project-guidelines`。`SKILL.md` frontmatter 只使用 `name`、`description`；`agents/openai.yaml` 只使用官方 `interface`、`dependencies`、`policy` 顶层结构。

主要路由：

- Win32：`windows-v120-build`
- Android：`android-r10e-build`
- Server：`server-ant-build`
- Lua UI：`lua-dialog-integration`
- CEGUI XML 资源：`cegui-layout-integration`
- 运行时绘制：`rendering-pipeline`
- 平台生命周期/JNI 回调：`platform-bridge`
- Codex 治理：`codex-runtime-governance`
- Claude 兼容治理：显式加载 `claude-config-governance`

Android NDK/Ant/APK 构建不强制加载 `platform-bridge`，仅在生命周期、JNI 注册或平台回调问题出现时按需联动；CEGUI XML 资源闭环不强制加载 `rendering-pipeline`，仅在资源校验通过后仍有绘制异常时联动。

## 6. 声明式工作流目录

`workflows/workflow-engine.json` 为 `kind: workflow-catalog`，保留历史文件名仅为兼容。它不监听事件、不调度进程，也不自动执行节点。

目录包含 13 条工作流：

```text
win32-build
android-build
server-ant-build
lua-ui-integration
cegui-layout-integration
resource-packaging
sprite-pack-algorithm
codex-governance
cocos-cegui-shadow-migration
application-core-flow
runtime-crash
ios-platform
resource-name-path-recovery
```

每条图声明 `entry_node`、节点、成功/失败/跳过边、证据、回滚和 availability。动态 sidecar 校验器额外检查 Schema 无法表达的语义：

- workflow/node ID 唯一；
- 所有边目标存在；
- 从入口可达全部节点并能到达 terminal；
- input default 类型与条件输入存在；
- Agent/skill/workflow 跨文件引用存在；
- tracked-required 命令路径真实、已跟踪且不是 LFS pointer；
- runtime-local、generated、external 路径不会因 clean checkout 缺失而假 FAIL/PASS。

`.claude/workflows/*.md` 是人工兼容视图；别名、共享兼容视图与降级映射以 `compat/claude-bridge.json` 和 `.claude/config/workflows.manifest.json` 校验。

`codex-governance` 的 strict quality 节点不会直接进入 PASS；最终由 `assert_codex_governance_reports.ps1` 可执行校验六份治理报告的顶层状态。只有全部 PASS 才进入 PASS，任一 WARN、FAIL、报告缺失或 JSON 无效都 fail closed。

## 7. 构建与生成边界

- Win32 外部入口：`tools/scripts/Build-MT3-Exe-Canonical.ps1`。
- Android 主线：`tools/scripts/Build-Android-Locojoy-WithGate.ps1`，固定 NDK r16 clang + Ant + JDK8，禁止 Gradle。
- Server 主线：JDK 1.7/1.8 + Ant；`genrpc -> genxdb -> gengbeans -> dist` 前先跑 LFS/链路 gate。
- iOS 构建需要 macOS/Xcode；Windows 只做静态入口检查，不宣称完成构建。
- `server/**/xbean|rpc`、`client/**/tolua++`、`ProtoDef` 和 Android 生成资源必须回源定义/生成入口。
- `client/resource/res/ui`、`tools/CEGUI-0.7.1`、`tools/engine/SpriteEditor` 等 runtime-workspace-local 路径允许在 clean checkout 缺失；执行对应任务时必须用实物重新取证。

## 8. 命令守卫

`.rules` 负责可精确匹配的 argv 前缀；hook 负责 wrapper 和内容级补充检查。当前回归矩阵覆盖：

- legacy Win32 构建入口及其 PowerShell/cmd/绝对路径变体；
- Gradle/Maven wrapper 与 `cmd /c call`；
- 批量暂存、强制 `git clean`、sparse-checkout 修改；
- 不稳定 PowerShell/.NET/Python 文本写入；
- 常见生成物 patch、写入、删除和 `git restore`。

安全只读命令、canonical 构建和显式路径暂存必须保持可用，避免过拦。

## 9. 统一验证

在仓库根目录依次执行：

```powershell
# 原生配置
codex -C . --strict-config doctor --json
codex -C . mcp list --json

# 工作流、sidecar、技能、守卫
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\validate_codex_sidecars.ps1 -ProjectRoot .
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_skills.ps1 -ProjectRoot .
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_guardrails.ps1 -ProjectRoot .
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1 -ProjectRoot .
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\analyze_codex_skill_workflows.ps1 -ProjectRoot .

# 编码/结构质量门（回归前）
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -TargetPath .codex -Strict

# 回归矩阵
pwsh.exe -NoLogo -NoProfile -File .\.claude\tests\test-codex-skill-scripts.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\tests\test-codex-execpolicy.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\tests\test-codex-pretool-hook.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\tests\test-codex-governance-audits.ps1

# 最终报告状态
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\assert_codex_governance_reports.ps1 -ProjectRoot .
git diff --check
```

`doctor` 总状态可能受终端、更新或外部服务检查影响；原生配置验收至少要求 `config.load=ok`、`mcp.config=ok`。任何命令不可用或外部依赖缺失都必须显式记录，不得编造 PASS。

## 10. 常用内建入口

本目录不定义自定义斜杠命令。排查项目配置时优先使用：

| 命令 | 用途 |
| --- | --- |
| `/status` | 查看当前会话、模型、审批和沙箱 |
| `/debug-config` | 查看实际加载的配置层 |
| `/permissions` | 查看审批/权限状态 |
| `/mcp` | 查看合并后的 MCP 运行面 |
| `/agent` | 查看/选择 Agent |
| `/skills`、`$skill-name` | 查看或显式调用技能 |
| `/hooks` | 审查并信任项目 hook 哈希 |

不在仓库文档中硬编码特定模型版本的临时命令行为；以当前 Codex 内建帮助和官方文档为准。

## 11. 维护要求

1. 新增/修改 `.codex` 文件必须同步 Schema、sidecar validator、CI 和 README。
2. 新增工作流必须有真实入口、失败边、证据、回滚和 availability；缺失外部条件只能 BLOCKED/WARN，不能 PASS。
3. 新增 Agent/skill/workflow 别名必须在 catalog、manifest、bridge 三侧一致。
4. `.codex/**` 与 `.claude/config/**/*.json` 使用普通 Git 文本对象，避免关键治理配置继续依赖 LFS。
5. 治理文本使用 UTF-8 no BOM；`.codex/**`、Schema、JSON、Markdown 和新增测试使用 LF。
6. 不提交 token、密钥、密码、认证文件或用户级 Codex 状态。

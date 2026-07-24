---
name: mt3-project-guidelines
description: "MT3 仓库的总入口技能。处理本仓库内任意开发、审查、排障或配置治理任务时先使用本技能，用它先判断任务域，再加载最小技能集合；不负责承载全部专题细节。"
---

先把本技能当作 MT3 仓库的任务分流器。它只负责建立最小上下文，不负责承载整套架构细节；这里的“最小”只指上下文装载，不指修改幅度。

## 何时使用

- 刚进入 MT3 仓库任务，尚未完成代码域分流时，先使用本技能
- 任务跨越多个子树、多个工具链或多个项目技能时，先用本技能收敛主故障域和最小技能集合

## 使用方式

1. 先确认任务落在 `client/`、`server/`、`tools/`、`.claude/`、`.codex/` 还是 `.agents/skills/`。
2. 若命中代理配置治理、repo-local skill 治理或资源名称路径恢复，先按“专项前置分流”选择主技能。
3. 其余业务任务再按下面五个任务域选择最小技能集合。
4. 修复类任务先取证，再定根因，再决定修改范围；不要把“最小修改”当成默认目标。
5. 修复类任务先定性主故障域，禁止未定因前跨域混改。
6. 只有短技能不足时，才继续读取对应 `references/` 或 `.claude` 长文。

## 专项前置分流

在五域分流前先应用以下路径优先级：

- 命中 `.codex/**`：先进入 `codex-runtime-governance`，由其处理 Codex 原生运行配置与审计 sidecar
- 命中 `.agents/skills/**`：先进入 `codex-runtime-governance`，按 Codex 原生技能规范处理元数据、触发边界与验证
- 命中 `.claude/CODEX_BRIDGE.md`、`.claude/config/**`、`.claude/hooks/**`、`.claude/settings*.json` 等桥接或兼容层：进入 `claude-config-governance`
- 同时跨越 `.codex` / `.agents` 与 `.claude`：先校正 Codex 原生层，再同步 Claude 桥接层；桥接层不得覆盖原生入口
- 命中资源解包后的真实名称、目录路径、错误扩展名或 `review/unresolved` 收敛：单独进入 `resource-name-path-recovery`，不要并入 `resource-packaging-pipeline`

## 不使用

- 任务已经明确锁定到某个具体项目技能，且不存在跨域不确定性时，可直接进入该技能
- 任务不在 MT3 仓库内，或不需要项目级路由时，不必加载本技能

## 输入校验

- 先确认任务路径、主目标、首个阻塞证据和可能涉及的目录域
- 先确认是否已经命中代理配置治理、资源名称路径恢复、生成代码、编码风险、平台壳层、渲染链或资源发布链
- 先确认本轮是否需要一个技能还是多个技能组合
- 若用户提到历史 `.claude/skills/**` 技能名或旧文档路径，先读 `references/legacy-skill-routing.md` 做路由，不直接按文件名猜一一对应
- 若任务是高频构建或 UI 排障但证据很薄，优先复用 `references/high-frequency-fact-packs.md` 对应模板收敛最小事实包

## 五域分流

- 应用核心层：进入 `application-core-flow`
- 打包处理层：进入 `resource-packaging-pipeline`
- 打包算法层：进入 `sprite-pack-algorithm`
- 渲染处理层：进入 `rendering-pipeline`
- 平台抽象层：进入 `platform-bridge`

## 组合规则

- Windows 构建或 ABI 问题，加 `windows-v120-build`
- Android 构建、JNI 或渠道工程问题，加 `android-r10e-build`
- 服务端 Ant 或生成链路问题，加 `server-ant-build`
- 命中 `client/resource/res/ui/**/*.layout`、`scheme`、`imageset`、`looknfeel` 或字体资源时，加 `cegui-layout-integration`
- 命中 `client/resource/res/script/**` 的 UI dialog、`GetLayoutFileName()`、`LuaUIManager` 或布局事件绑定时，加 `lua-dialog-integration`
- 命中 `xbean`、`rpc`、`tolua++`、`ProtoDef` 等生成边界，加 `generated-code-guard`
- 修改中文文本、脚本、Markdown 或历史 C++ 文件前，加 `encoding-bom-guard`

## 基线事实

- 运行时代码架构仍以当前源码与文档为准：平台层 -> Cocos2d-x 层 -> Nuclear 层 -> FireClient 层
- 本技能里的“五层”是 Agent 执行任务的分域模型，不等同于客户端运行时分层
- 文档、技能与配置若冲突，以工程文件、构建入口和已核对文档为准

## 失败处理

- 若任务域仍不清晰，先停在取证和分域阶段，不要抢先展开多个长技能
- 若一个症状同时覆盖多域，先确定主故障域，再把次要域拆成后续验证项

## 输出与验证

- 输出至少包含：当前任务域、选择该技能集合的原因、下一步要读的最小文件集
- 若本技能完成分流后仍需继续工作，后续技能必须能解释“为什么现在加载它”
- 若本技能导致 `.agents/skills/**` 被修改，后续需补跑 `audit_codex_skills.ps1`
- 若本技能新增或重构 `scripts/*.ps1`，优先复用 `references/skill-script-output-contract.md` 与 `assets/skill-script-template.ps1.txt`
- 若本技能新增或重构 repo-local skill，先按 `references/skill-development-checklist.md` 做一次逐项自检，再进入审计和 CI
- 若本技能新增或重构 repo-local skill 脚本，优先点源 `scripts/skill-script-helpers.ps1`，不要继续复制 `Resolve-RepoRootPath`、`Read-TextFileSmart`、`Get-CommandSource`、`Get-ExistingPath`、`Write-Result`
- repo-local skill 脚本的 `-Json` 输出默认遵循 `references/skill-script-json-schema.md`，新增领域字段优先放进 `data`
- 若任务起点是旧 `.claude` 技能名，输出里要显式说明“旧技能 -> 当前 `.agents` 技能”的映射结果，避免后续轮次再重判一次

## 资源与上下文预算

- 默认只读当前任务直接相关的目录规则和一个最近邻技能
- 仅在短技能不足时才继续展开 `references/` 或 `.claude` 长文
- 只有在新增 repo-local 技能脚本时，才读取 `assets/` 模板与输出契约
- 历史技能名路由只在命中旧 `.claude/skills/**` 时读取 `references/legacy-skill-routing.md`
- 高频构建/UI 任务只在证据不足时读取 `references/high-frequency-fact-packs.md`，不要默认把所有模板都展开进上下文

## 需要时再读

- `references/task-architecture.md`
- `references/legacy-skill-routing.md`
- `references/high-frequency-fact-packs.md`
- `references/skill-development-checklist.md`
- `references/skill-script-json-schema.md`
- `.claude/RULES.md`
- `.claude/BUILD_GUIDE.md`

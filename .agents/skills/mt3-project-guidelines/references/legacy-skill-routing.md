# MT3 历史 `.claude/skills` 到当前 `.agents/skills` 路由映射

## 目的

本文件用于把历史 `.claude/skills/**` 长文技能名，映射到当前 Codex/GPT 运行面的 `.agents/skills/**`。

使用原则：

- `.claude/skills/**` 现在主要作为长文知识源和历史沉淀，不再作为 Codex repo-local 运行时主入口。
- `.agents/skills/**` 才是当前 Codex/GPT 在 MT3 仓库中的短入口、脚本入口和审计入口。
- 如果用户直接提到旧技能名、旧文档路径或旧术语，先用本表做路由，不要按文件名猜一一对应。

## 映射规则

### 客户端

| 历史 `.claude` 技能 | 当前主技能 | 常见辅助技能 | 说明 |
|---|---|---|---|
| `client/android-build.md` | `android-r10e-build` | `platform-bridge` `resource-packaging-pipeline` | 命中旧 Android 构建、NDK、Ant、渠道工程时优先走这里 |
| `client/android-p0-boot-log.md` | `android-r10e-build` | `platform-bridge` | 命中旧 Android 启动首屏、P0 日志、模拟器启动链或首个 logcat 阻塞点时，先走 Android 构建/启动链技能，不再保留孤立的旧日志技能入口 |
| `client/windows-build.md` | `windows-v120-build` | `rendering-pipeline` `resource-packaging-pipeline` | 命中 v120、VS2013、Launcher 构建或 Win32 构建漂移时优先走这里 |
| `client/cegui-usage.md` | `cegui-layout-integration` | `lua-dialog-integration` `rendering-pipeline` | 命中 `.layout/.scheme/.imageset/.font` 或窗口命名路径时优先走这里 |
| `client/cocos2dx-usage.md` | `rendering-pipeline` | `platform-bridge` `application-core-flow` | 命中节点、场景、渲染链、绘制顺序时优先走这里 |
| `client/cpp-development.md` | `application-core-flow` | `rendering-pipeline` `platform-bridge` `generated-code-guard` | 旧 C++ 泛化技能太宽，当前优先先定主故障域再选具体技能 |
| `client/fireclient-framework.md` | `application-core-flow` | `lua-dialog-integration` `generated-code-guard` | 命中 FireClient Manager/Framework/业务主链时优先走这里 |
| `client/lua-scripting.md` | `lua-dialog-integration` | `application-core-flow` `generated-code-guard` | 命中 UI dialog、Lua 事件绑定、窗口路径时优先走这里 |
| `client/nuclear-engine.md` | `rendering-pipeline` | `application-core-flow` | 命中引擎渲染、场景对象、批量绘制时优先走这里 |
| `client/tolua-binding.md` | `generated-code-guard` | `lua-dialog-integration` `application-core-flow` | 命中绑定生成物、pkg、Lua/C++ 桥接边界时优先走这里 |

### 服务端

| 历史 `.claude` 技能 | 当前主技能 | 常见辅助技能 | 说明 |
|---|---|---|---|
| `server/ant-build.md` | `server-ant-build` | `generated-code-guard` | 命中服务端构建、`genrpc/genxdb/gengbeans` 时直接走这里 |
| `server/java-development.md` | `server-ant-build` | `generated-code-guard` | 当前 `.agents` 没有单独的服务端 Java 业务技能；构建/生成先走这里，业务深度再回旧长文 |
| `server/gnet-framework.md` | `generated-code-guard` | `server-ant-build` | 命中 RPC/协议/生成边界先守生成链，不直接在旧长文里兜圈子 |
| `server/xbean-system.md` | `generated-code-guard` | `server-ant-build` | 命中 xbean/xdb 先判断是否为生成物，再决定是否回源定义 |
| `server/distributed-arch.md` | `mt3-project-guidelines` | 无固定辅助 | 当前没有一一对应的 repo-local 运行时技能，保留旧长文作为架构背景源 |

### 通用与治理

| 历史 `.claude` 技能 | 当前主技能 | 常见辅助技能 | 说明 |
|---|---|---|---|
| `common/build-troubleshooting.md` | `mt3-project-guidelines` | `windows-v120-build` `android-r10e-build` `server-ant-build` | 先分流到具体平台或构建链，不再留在泛化“构建排障” |
| `common/debugging.md` | `mt3-project-guidelines` | 按故障域补具体技能 | 旧文偏通用；当前优先先定主故障域 |
| `common/dependency-management.md` | `windows-v120-build` | `android-r10e-build` `server-ant-build` `generated-code-guard` | 命中 ABI/依赖/工具链版本漂移时先走具体构建链 |
| `common/engine-tools-build.md` | `sprite-pack-algorithm` | `resource-packaging-pipeline` `windows-v120-build` | 命中 SpriteEditor、工具工程或图集导出时优先细分到工具链技能 |
| `common/git-workflow.md` | `mt3-project-guidelines` | 无固定辅助 | 当前仓库把 Git/工作区协作守卫内化进总入口与根规则，不再单独保留 repo-local Git 技能 |
| `common/performance-optimization.md` | `mt3-project-guidelines` | `rendering-pipeline` `application-core-flow` | 旧性能技能范围过宽；当前先判瓶颈在渲染链、共享主链还是构建链，再补具体技能 |
| `common/project-context.md` | `mt3-project-guidelines` | 无固定辅助 | 当前仓库总入口已由 `mt3-project-guidelines` 承担 |
| `common/protocol-design.md` | `generated-code-guard` | `server-ant-build` | 协议/定义改动先守生成边界，再决定是否进入服务端链 |
| `common/claude-config-engineering.md` | `claude-config-governance` | `mt3-project-guidelines` | 命中 `.claude/.codex/.agents`、路由、manifest、bridge 时优先走这里 |
| `common/search-first.md` | `mt3-project-guidelines` | 无固定辅助 | 搜索优先已经内化到当前总入口技能和全局工作流，不再单独当运行时技能 |
| `common/verification-loop.md` | `mt3-project-guidelines` | 具体领域技能 + 对应审计脚本 | 当前以“技能脚本 + 审计脚本”组合代替单独 verification 技能 |
| `common/continuous-learning-v2.md` | 无 repo-local 对应 | 仅在用户显式要求时使用全局 continuous-learning 技能 | 不属于 MT3 当前 repo-local 原生技能集 |

## 快速决策法

1. 用户提到旧 `.claude/skills` 文档名时，先查本表，不直接按同名猜测。
2. 如果本表给出明确主技能，优先走 `.agents` 主技能，再按症状补辅助技能。
3. 如果本表写的是“无 repo-local 对应”，把旧 `.claude` 长文当背景知识源，不要误装成当前主入口。
4. 当旧长文和当前 `.agents` 技能口径冲突时，以根 `AGENTS.md`、`.claude/RULES.md`、`.claude/BUILD_GUIDE.md` 和 `.agents` 当前入口技能为准。

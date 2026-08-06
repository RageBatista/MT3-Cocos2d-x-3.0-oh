# MT3 仓库事实与协作边界（AGENTS）

> **版本**：4.2.0
>
> **更新日期**：2026-08-06
>
> **维护者**：技术委员会
>
> **定位**：本文件是 MT3 仓库级事实、任务分流和长期边界的主入口。目录专用规则由最近的 `AGENTS.md` 补充；硬约束和已验证命令分别下沉到 `.claude/RULES.md` 与 `.claude/BUILD_GUIDE.md`。

---

## 1. 默认协作方式

- 所有对话、计划、变更说明和提交说明默认使用中文；代码与注释延续所在模块的既有语言和风格。
- 本仓库是 Win32、Android、iOS、共享 C++、Lua、Java/Ant 服务端、资源生产链和多套历史工具共同存在的混合技术栈，先划分任务域，再加载对应规则和技能。
- 修复任务先取证、再定根因、再决定改动面。优先证据依次是工程文件、源码、构建脚本、日志、调用链、配置实物、构建输出、产物时间戳和 `git diff`。
- 不做无关重构、批量格式化、批量转码或隐式工具链升级；生成物、vendor、历史工程和第一方源码必须先分类再处理。
- 规则中的版本、路径和命令必须能在当前工作树或已验证外部环境中找到证据；历史估算、计划文档和治理 sidecar 只作辅助，不反向覆盖工程事实。

## 2. 权威入口与裁决顺序

| 入口 | 职责 | 使用时机 |
| --- | --- | --- |
| [AGENTS.md](AGENTS.md) | 仓库事实、总体架构、任务分流和根级边界 | 每次进入仓库 |
| 最近的 `AGENTS.md` / `AGENTS.override.md` | 当前目录专有边界和最短验证入口 | 进入具体子树后 |
| [.claude/RULES.md](.claude/RULES.md) | 工具链、ABI、编码、生成代码硬约束 | 任何可能影响构建正确性的任务 |
| [.claude/BUILD_GUIDE.md](.claude/BUILD_GUIDE.md) | 当前工作机已验证的构建和产物校验命令 | 构建、重编、打包、发布 |
| [.claude/CODEX_BRIDGE.md](.claude/CODEX_BRIDGE.md) | Codex 原生运行面到 Claude 兼容层的单向映射 | 同时变更 `.codex` 与 `.claude` 治理入口 |
| [.codex/config.toml](.codex/config.toml) | 项目级 Codex 原生运行配置和 Agent/MCP 接入 | Codex 运行时治理 |
| [.agents/skills/mt3-project-guidelines/SKILL.md](.agents/skills/mt3-project-guidelines/SKILL.md) | MT3 任务域分流和最小技能集合 | 选择处理流程 |
| [docs/02-技术架构/02-项目架构.md](docs/02-技术架构/02-项目架构.md) | 架构背景与调用链说明 | 需要展开架构上下文 |

事实冲突时按以下顺序裁决：

1. 当前工程实物、源码、项目文件、脚本、日志和可复现构建结果；
2. 根与最近目录的 `AGENTS.md`（局部规则可在本目录内细化，但不得弱化根级硬边界）；
3. `.claude/RULES.md` 与 `.claude/BUILD_GUIDE.md`；
4. `.codex/**`、`.agents/skills/**` 和 `.claude` 桥接配置；
5. 当前基线文档；
6. `.trae/references/**`、历史报告、计划、生成报告和其他辅助材料。

若文档或 sidecar 与项目文件不一致，先按工程实物工作，再同步修正文档；不得为了让旧文档“成立”而改坏当前构建链。

## 3. 当前实际架构

### 3.1 系统级模块

| 子系统 | 主要路径 | 当前职责 |
| --- | --- | --- |
| 平台壳层 | `client/MT3Win32App/`、`client/android/`、`client/FireClient/FireClient/` | 进程/应用入口、生命周期、窗口与输入、JNI/ObjC++、渠道 SDK、CrashDump |
| 共享客户端业务 | `client/FireClient/Application/`、`client/resource/res/script/`、`client/resource/res/ui/` | `gRunGameApplication()` 后的启动、登录、入世界、网络、UI、Lua、配置和业务逻辑 |
| Nuclear 引擎 | `engine/` | 场景、世界、精灵、地图、动画、特效、渲染组织和引擎接口 |
| Cocos 基础层 | Win32、Android、iOS canonical 均使用 `cocos2d-x-3.0-oh/ + tools/CEGUI-0.7.9-r5/`；`cocos2d-x-2.2.6/ + dependencies/cegui/` 仅保留给 `Legacy226` 回滚链 | 图形、音频、物理、Lua 基础、扩展和平台适配；实际依赖按平台区分，见 3.3 |
| 公共本地库 | `common/` | `platform`、`ljfm`、`cauthc`、Lua/tolua、更新等跨模块基础库 |
| 服务端与协议 | `server/`、`gbeans/` | Java/Ant 游戏服务、gnet/RPC、XDB/XBean、策划配置生成和运行分发 |
| 资源生产与发布 | `client/resource/res/`、`client/res_*`、`client/android/**/assets/res/`、`tools/` | 源资源、平台 staging、APK 资源同步、PFS/热更新、编辑器与离线工具 |
| 代理与文档治理 | `.codex/`、`.agents/`、`.claude/`、`.trae/`、`docs/` | Codex 原生配置、技能、兼容桥接、Trae 规则和项目文档 |
| 计划与辅助材料 | `plans/`、`scheme_doc/`、`build_logs/`、`lib/` | 规划/分析报告 sidecar、策划与测试文档、构建日志证据、VS2013 预编译库归置；均不作为规范入口 |

仓库中的行数、文件数和构建耗时会持续变化，不作为根级架构约束；需要统计时必须由当前工作树重新生成。

### 3.2 客户端逻辑分层

客户端共享运行时采用四层逻辑模型：

```text
FireClient 业务层
  C++ 业务 / Lua / CEGUI UI / 协议 / Manager / Battle / SceneObj
                         ↓
Nuclear 引擎层
  IEngine / IWorld / IEnv / IQuery / 场景 / 精灵 / 动画 / 特效
                         ↓
Cocos2d-x 基础层
  渲染 / 音频 / 物理 / Lua 基础 / extensions / 平台适配
                         ↓
平台层
  Win32 / Android / iOS 生命周期、系统能力和渠道桥接
```

- 平台壳层负责启动共享主链，不承载另一套独立业务核心。
- Win32 canonical 运行时使用 `tools/CEGUI-0.7.9-r5/` 的静态库与 Cocos2D renderer；`dependencies/cegui/` 的 0.7.1 树仅保留给尚未迁移的平台/历史链路，不得混入 Win32 `Upgrade30` 产物。
- `client/resource/res/script/` 与 `client/resource/res/ui/` 是 FireClient 业务/UI 的组成部分，不是可脱离 C++ 主链单独治理的普通静态资源。
- 跨层公共接口、对象布局、生命周期或资源所有权变更必须评估所有下游，不以“单个工程编译通过”作为完成标准。

### 3.3 Cocos2d-x 物理依赖现状

“逻辑架构使用 Cocos 基础层”不等于所有平台已经物理收敛到同一目录。当前工程实物为：

- **Win32 canonical 主线**：`client/MT3Win32App/*.win32.vcxproj`、`engine/engine.win32.vcxproj` 和 `client/Build-MT3-v120.ps1` 使用 `cocos2d-x-3.0-oh/ + CEGUI-0.7.9-r5`；canonical wrapper 默认并校验 `EngineProfile=Upgrade30`。
- **Android Locojoy free 主线**：`client/android/LocojoyProject/jni/Android.mk` 默认 `EngineProfile=Upgrade30`，导入 `cocos2d-x-3.0-oh/` 与 `client/android/native/cegui-r5/`；`Application.mk` 为 `arm64-v8a + android-21 + c++_shared + clang`。2026-08-06 已完成 NDK r16 clang + Ant + JDK8 Debug canonical 构建，并通过 APK 结构、ABI、LJFM、音频 JNI、启动保护与 zipalign 门禁。
- **iOS 工程**：canonical 为 `client/FireClient/FireClient-Upgrade30.xcodeproj`、`engine/engine-Upgrade30.xcodeproj`、`client/ios/CEGUI-0.7.9-r5.xcodeproj` 与 `cocos2d-x-3.0-oh/build/cocos2d_libs.xcodeproj`。Windows 静态门禁已 `64/64 PASS`，状态文件为 `client/ios/Upgrade30/READY_FOR_XCODE_BUILD.md`；最终编译、签名与设备验收仅在 macOS/Xcode 执行。
- `client/MT3Win32App/mt3.vcxproj`、部分 `.filters`、WinRT/WP8 工程和其他旧项目文件仍可能包含旧树路径；它们不属于 Win32 canonical 入口，也不得用来推翻 canonical 主线事实。

新增三端 canonical 依赖不得继续指向 Legacy226 树。处理旧树时必须先识别实际引用它的平台和工程，再决定修复、迁移或重编范围；禁止全目录批量替换路径。

### 3.4 服务端与代码生成

- 服务端主入口为 `server/server/game_server/build.xml`，当前核心目标包括 `genrpc`、`genxdb`、`gengbeans`、`genfiles` 和 `dist`。
- `gbeans/*.xml` 是 `gengbeans` 消费的源定义，不是生成后的 Java 文件。
- `server/**/xbean/*.java`、`server/**/rpc/*.java` 是生成结果；协议/XDB 变更必须回到 XML、XDB、RPC 定义和 Ant 生成入口。
- `serverbin/` 是运行分发产物，不作为长期手写源；服务端配置、生成结果和分发目录必须区分。
- 客户端 `ProtoDef`、Lua 协议脚本与服务端协议定义存在生成关系；协议调整必须同时核对客户端生成链和服务端生成链，避免单边更新。

### 3.5 资源生产链

```text
client/resource/res/**                         # 业务源资源（可修改）
  -> LJFilePackOption.xml / LJFilePack_打包*.bat
  -> client/res_android|res_ios|res_win/**     # 平台 staging（生成）
  -> Android -SyncRes
  -> client/android/LocojoyProject/assets/res/** # APK 工程生成输入
```

- `client/resource/res/**` 是资源业务源；Android 资源问题必须先回到这里定位。
- `client/resource/tools/**`、`client/res_android/**`、`client/res_ios/**`、`client/res_win/**` 和 `client/android/LocojoyProject/assets/res/**` 在当前仓库策略下可能被忽略且不随干净 checkout 提供；执行前必须检查工作区实物。
- `client/android/LocojoyProject/assets/res/**` 只允许由资源打包和构建同步链刷新，不接受手工补丁。
- 修改 layout/scheme/looknfeel/imageset/font 时同时核对 CEGUI 声明链、Lua/C++ 查找路径和资源打包输出，不得只验证单个 XML 能解析。

## 4. 主线工具链与构建入口

| 平台/子系统 | 当前基线 | canonical/源入口 | 关键边界 |
| --- | --- | --- | --- |
| Win32 客户端 | VS2013 `v120` + Windows SDK 8.1 + MSBuild 12.0 | `tools/scripts/Build-MT3-Exe-Canonical.ps1` | `client/Build-MT3-v120.ps1` 是内部依赖链；不以 CMake 或新 MSVC 替换 |
| Android free 渠道 | NDK r16b clang + Ant + JDK 8；旧脚本需要时使用 Python 2.7 | `tools/scripts/Build-Android-Locojoy-WithGate.ps1` | 当前验证对象是 `LocojoyProject` free；其他渠道/月卡配置需单独复验 |
| iOS | macOS + Xcode/xcodebuild；`arm64 + iOS 12.0` | `tools/scripts/Build-iOS-MT3.ps1` / `client/FireClient/FireClient-Upgrade30.xcodeproj` | Windows 只跑 `-StaticGateOnly`；编译、签名和设备验收在 macOS 执行 |
| 服务端 | JDK 1.7/1.8 + Ant | `server/server/game_server/build.xml` | 不以 Maven/Gradle 或 JDK 9+ 隐式替换 |

- WinRT/WP8、vendor 示例工程和历史项目不属于当前主线交付入口；其配置不得作为升级主线工具链的依据。
- 编译宏、字符集、警告、链接库和渲染后端以具体项目文件为准，不设虚构的全仓统一值。例如当前 `engine.win32.vcxproj` 的 `CharacterSet` 与 MT3/FireClient 工程不同；最终 Win32 工程同时保留 OpenGL 与 EGL/GLES 相关链接项，禁止按旧规则擅自删除。
- 构建命令和本机路径以 `.claude/BUILD_GUIDE.md` 与脚本参数为准；规则文件不复制易漂移的机器绝对路径。

## 5. 首轮任务分流

| 任务域 | 最近入口 | 首轮动作 |
| --- | --- | --- |
| FireClient 共享业务 | [client/FireClient/Application/AGENTS.md](client/FireClient/Application/AGENTS.md) | 先定位启动、登录、入世界、Manager、协议或 Lua/UI 主链 |
| Win32 壳层与构建 | [client/MT3Win32App/AGENTS.md](client/MT3Win32App/AGENTS.md) | 区分壳层、链接、运行目录和 ABI，再使用 canonical 脚本 |
| Android 平台 | [client/android/AGENTS.md](client/android/AGENTS.md) | 固定 free 主线与 JDK8/NDK r16 门禁，先区分 Java/JNI、native、渠道和资源同步 |
| iOS 平台 | [client/AGENTS.md](client/AGENTS.md) | 核对 Xcode 工程、ObjC++ 生命周期、旧 Cocos 物理依赖和共享 C++ 桥接 |
| Nuclear/渲染 | [engine/AGENTS.md](engine/AGENTS.md) | 区分引擎 ABI、运行时渲染、CEGUI 声明链与平台输入 |
| 服务端/协议/生成 | [server/AGENTS.md](server/AGENTS.md) | 区分源定义、生成代码、Ant 构建和运行分发 |
| 工具/资源/打包 | [tools/AGENTS.md](tools/AGENTS.md) | 区分构建脚本、PFS/热更新、Sprite 打包、CEGUI 工具和资源恢复 |
| 文档 | [docs/AGENTS.md](docs/AGENTS.md) | 先回工程事实，再更新当前基线；历史资料不覆盖现状 |
| Codex 原生治理 | `.codex/**`、`.agents/skills/**` | 使用 `codex-runtime-governance`，核对配置、sidecar、Agent 和技能审计 |
| Claude 兼容治理 | [.claude/AGENTS.md](.claude/AGENTS.md) | 区分硬约束、构建命令、桥接路由和审计脚本 |
| Trae 规则 | [.trae/rules/project_rules.md](.trae/rules/project_rules.md) | 以本文件和工程实物为主，Trae 文件只维护适配摘要 |

## 6. 源码、生成物、vendor 与产物边界

| 范围 | 分类 | 修改规则 |
| --- | --- | --- |
| `client/FireClient/Application/**` | 第一方共享业务源码 | 允许修改；公共头和生成文件例外按下文处理 |
| `client/MT3Win32App/**`、`client/android/**`、`client/FireClient/FireClient/**` | 第一方平台壳层 | 允许修改；保持平台工具链、生命周期和编码现状 |
| `engine/**` | 第一方 Nuclear 引擎 | 允许修改；公共头默认按 ABI 高风险处理 |
| `cocos2d-x-3.0-oh/**`、`tools/CEGUI-0.7.9-r5/**` | 当前 Win32/Android/iOS canonical 基础层/UI 运行时 | 允许有证据的补丁；按平台重编 `Cocos/CEGUI -> engine -> FireClient -> 最终壳层` |
| `cocos2d-x-2.2.6/**`、`dependencies/cegui/**` | `Legacy226` 回滚与历史兼容链 | 允许有证据的补丁；不得把其头文件或库混入 Upgrade30 产物 |
| `cocos2d-2.0-rc2-x-2.0.1/**` | 历史兼容树（已不存在于工作区） | 旧树目录已删除，仅作概念回滚基线保留 |
| `dependencies/**`、第三方快照 | vendor | 日常保持原状；专项补丁保留来源、影响和回滚，不做全仓风格治理 |
| `client/resource/res/**`、`gbeans/*.xml`、协议/XML/pkg 定义 | 源定义 | 从这里修改，再运行相应生成/打包链 |
| `.lib/.dll/.exe/.a/.so/.jar/.apk`、`serverbin/**` | 构建或分发产物 | 不手工编辑；回到源码和 canonical 构建入口 |

以下内容默认视为生成结果，不作为长期手写源：

- `server/**/xbean/*.java`、`server/**/rpc/*.java`；
- `client/FireClient/Application/ProtoDef/**`；
- `client/resource/res/script/protodef/**`；
- `client/FireClient/Application/Framework/LuaEngine.cpp`、`LuaFireClient.cpp`；
- 由 tolua++ 输出的其他绑定 `.cpp`；
- `client/res_android/**`、`client/res_ios/**`、`client/res_win/**`；
- `client/android/LocojoyProject/assets/res/**`。

对应源入口包括 `client/FireClient/Application/*.xml`、`genprotocol*.bat/.sh`、`client/tolua++-pkgs/**/*.pkg`、`engine/tolua++-pkgs/engine.pkg`、服务端协议/XDB XML、`gbeans/*.xml` 和资源源目录。修改生成结果前必须先找到真实生成入口。

## 7. ABI、链接与下游重建

- 类成员、继承关系、虚函数、模板实例、内联实现、公共宏分支、对象大小或成员偏移变化均属于 ABI 敏感变更。
- 修改 `engine/**.h` 的 ABI 后执行 `Rebuild engine -> Rebuild FireClient -> Build MT3`。
- 修改 `client/FireClient/Application/**.h` 的 ABI 后执行 `Rebuild FireClient -> Build MT3`；若同时影响 engine，从 engine 开始整链重建。
- 修改 Cocos 公共接口后，重编对应 Cocos 库并继续重编 `engine -> FireClient -> MT3`。
- `FireClient.win32.vcxproj` 与 `mt3.win32.vcxproj` 共享 `$(SolutionDir)$(Configuration).win32` **输出目录**，但其 `IntDir` 分别带项目名；不要再描述为“共用同一中间目录”。共享输出目录仍要求核对 `.lib/.exe` 时间戳和实际重编顺序。
- 不使用 `/FORCE`、跨工具集二进制或局部替换来掩盖符号、CRT、对象布局或链接问题；不跨 CRT 边界分配/释放内存。

## 8. 编码、风格与 Shell

- 修改前必须探测原始编码、BOM 和换行，修改后按原编码回读并做字节校验；不按扩展名对全仓一刀切转码。
- 交给 VS2013 `cl.exe` 的 UTF-8 C/C++ 文件只要含非 ASCII 字符就必须保留 UTF-8 BOM；历史 CP936/ANSI/UTF-16 文件仍按原编码写回。
- `.rc` 文件保持原编码，禁止把常见 UTF-16 LE/BOM 自动转换成 UTF-8。
- `.md/.json/.xml/.ps1/.lua/.java` 新文件默认 UTF-8 无 BOM；修改既有文件仍以保持原状和就近 `.gitattributes` 为先。本文件与 `.trae/rules/project_rules.md` 的当前基线为 UTF-8 无 BOM、LF。
- 代码命名、缩进、花括号、预编译头、宏和警告配置遵循最近模块现状；不存在可覆盖所有 C++、Lua、Java 和工具工程的单一格式模板。
- PowerShell 使用 `$env:NAME`，`cmd.exe`/`.bat` 才使用 `%NAME%`；跨 shell 必须显式写 `cmd /c`、`powershell -File` 或 `bash -lc`。

## 9. 验证与交付

- 业务逻辑改动必须增加测试，或提供能覆盖关键路径的回归步骤；Bug 修复至少保留一个复现与回归证据。
- 构建影响按最近 `AGENTS.md`、`.claude/BUILD_GUIDE.md` 和 canonical 脚本执行；没有在对应平台运行就明确记录“未执行”和阻塞条件。
- 仅修改规则/文档时至少执行：严格 UTF-8/BOM/换行检查、本地 Markdown 链接存在性检查、过时关键字检查和 `git diff --check`；文档改动本身不要求无关的全量客户端构建。
- 交付说明包含：目标与假设、工程证据、变更点、验证命令与结果、未覆盖项、风险与回滚方式。
- 不覆盖或回退用户已有改动；提交前先用 `git status --short` 和限定路径的 `git diff` 区分本次修改。

## 10. 维护原则

1. 根 `AGENTS.md` 只维护跨域长期事实、架构边界和导航；专题步骤下沉到最近目录规则或技能。
2. `.claude/RULES.md` 维护硬约束，`.claude/BUILD_GUIDE.md` 维护已验证命令，`.codex/**` 维护 Codex 原生运行配置；职责不互相复制。
3. `.trae/rules/project_rules.md` 必须引用本文件并保持事实摘要一致；`.trae/references/**` 中未逐篇复核的旧材料不得覆盖本文件。
4. 新增平台、迁移 Cocos 根、改变工具链、调整资源 staging 或生成链时，必须同步更新本文件、最近目录规则和对应构建文档。
5. 不在根规则中固化会快速失真的代码行数、耗时、机器绝对路径或单次故障 workaround。

## 11. 文档实时同步与智能体元数据治理

### 11.1 触发与同步范围

下列事实发生变化时，必须在同一任务内检查并更新受影响的文档；若核对后无需改文，交付记录中应说明已检查：

- 客户端、服务端、工具或资源链的代码修改导致功能、启动/构建入口、生成边界、资源声明或验证方式变化；
- 平台基线、工具链、架构分层、目录职责、ABI 重建顺序或发布流程变化；
- `.codex/**`、`.agents/**` 的项目级配置、角色定义、技能接口或治理 sidecar 变化；
- 已验证的日志、构建结果或运行回归改变了当前文档中的状态结论。

同步边界如下：

| 目标文档 | 必须保持的内容 |
| --- | --- |
| `README.md` | 项目概览、平台基线、环境要求、使用/构建入口、功能与 FAQ、文档导航 |
| 根 `AGENTS.md` | 仓库事实、任务分流、构建/生成/ABI 边界、智能体元数据治理规则 |
| `docs/README.md` 与 `docs/07-参考文档/02-文档索引.md` | 已落库的当前文档入口和索引 |
| 专题文档 | 与本次修改直接相关的实现、验证证据、已知边界和回滚说明 |

文档只记录源码、工程文件、构建脚本、配置、日志、构建产物或已复现运行结果已经证实的事实。不得把计划、静态审计推测或单次临时结果表述为已完成的端到端结论。用户要求输出完整文档时，必须从工作树读取当前 `README.md` 与 `AGENTS.md`，分别使用独立的 Markdown 代码块输出，不得以局部片段替代完整文件。

### 11.2 智能体元数据权威来源

| 信息 | 权威来源 | 使用边界 |
| --- | --- | --- |
| 角色 ID、描述、配置路径 | [.codex/config.toml](.codex/config.toml) | 项目级角色注册表 |
| 推理等级、沙箱模式、职责、读写边界与输出要求 | [.codex/agents/](.codex/agents/) 下对应 `.toml` | 单个角色的当前定义 |
| 技能显示名、默认提示、是否允许隐式调用和已声明依赖 | `.agents/skills/**/agents/openai.yaml` | 技能接口元数据；不与角色配置混淆 |
| 角色与技能的版本历史 | `git log -- .codex/config.toml .codex/agents .agents/skills` | 以 Git 提交记录为准 |
| 会话内临时子智能体、执行状态和消息 | 运行时会话 | 非仓库持久元数据，不写入本文件 |

当前 `.codex/agents/*.toml` 未定义统一的机器可解析 `input_schema` 或 `output_schema`。角色输入为父智能体传入的任务与其要求的仓库证据，输出为各自 `developer_instructions` 规定的自然语言分析、计划、审查或验证结果；不得臆造未在配置中存在的 JSON、CLI 或 API 输入输出格式。技能的“何时使用/不使用”等触发边界以对应 `SKILL.md` 为准，`openai.yaml` 只声明其是否允许隐式调用。

### 11.3 当前项目级角色目录

| ID | 描述与能力 | 推理/沙箱 | 任务输入 -> 预期输出 |
| --- | --- | --- | --- |
| [`mt3_architecture_analyst`](.codex/agents/mt3_architecture_analyst.toml) | 目录架构、依赖图、运行时分层和模块边界分析 | `high` / `read-only` | 架构或跨域问题与工程证据 -> 源目录、依赖边、生成边界、ABI/构建影响和最小验证门禁 |
| [`mt3_build_expert`](.codex/agents/mt3_build_expert.toml) | Win32 v120、Android r16/Ant、服务端 Ant 及 CEGUI/CRT/编码构建问题 | `high` / `workspace-write` | 构建故障与入口参数 -> 最小修复、明确验证命令和回滚友好改动 |
| [`mt3_codex_governor`](.codex/agents/mt3_codex_governor.toml) | `.codex`、`.agents`、MCP、规则和治理 sidecar 对齐 | `high` / `read-only` | 运行面或技能治理问题 -> 配置权威、精确改动建议、官方规范依据和剩余验证缺口 |
| [`mt3_docs_researcher`](.codex/agents/mt3_docs_researcher.toml) | Codex、MCP、`AGENTS.md` 和 OpenAI API 文档调研 | `medium` / `read-only` | 文档问题或官方资料缺口 -> 含官方引用的简明约束说明 |
| [`mt3_lua_ui_integrator`](.codex/agents/mt3_lua_ui_integrator.toml) | Lua Dialog 生命周期、CEGUI 绑定、事件、窗口路径和 Lua/C++ 桥接 | `medium` / `read-only` | UI 症状、Lua/资源路径与绑定证据 -> 归因、最小改动建议和打开/关闭/事件/刷新回归步骤 |
| [`mt3_performance_analyst`](.codex/agents/mt3_performance_analyst.toml) | FPS、内存、DrawCall、CPU/GPU 与 Lua 热点分析 | `medium` / `read-only` | 性能基线和优化目标 -> 含验证指标与回归风险的优化建议 |
| [`mt3_planner`](.codex/agents/mt3_planner.toml) | 跨子系统任务的范围、风险、回滚点与验证门禁规划 | `medium` / `read-only` | 多步骤或高风险任务 -> 根因导向的计划、回滚点和可执行验证门禁 |
| [`mt3_resource_pipeline_expert`](.codex/agents/mt3_resource_pipeline_expert.toml) | PFS、热更新、版本索引、补丁、LJFilePack、SpriteEditor 与资源恢复边界 | `medium` / `read-only` | 资源/发布问题与源目录 -> 源定义、影响根、预期产物形态和验证命令 |
| [`mt3_reviewer`](.codex/agents/mt3_reviewer.toml) | 正确性、ABI、生成物、编码、忽略规则、staging 和验证缺口审查 | `high` / `read-only` | 改动集与相关证据 -> 按严重度排序、含文件引用的审查发现 |
| [`mt3_runtime_troubleshooter`](.codex/agents/mt3_runtime_troubleshooter.toml) | 崩溃、启动、登录、场景、UI、渲染、CEGUI、资源和平台交接排障 | `high` / `read-only` | 当前日志、复现步骤、二进制路径和配置 -> 按证据排序的根因假设、影响、下一探针和最小验证命令 |
| [`mt3_security_auditor`](.codex/agents/mt3_security_auditor.toml) | 凭证、注入、提权、敏感数据暴露和合规审计 | `high` / `read-only` | 安全审计范围与改动证据 -> 高严重度优先的发现和兼容旧工具链的建议 |
| [`mt3_server_protocol_expert`](.codex/agents/mt3_server_protocol_expert.toml) | Ant、gnet、xbean、rpc、生成入口和客户端/服务端协议边界 | `high` / `read-only` | 服务端或协议问题与生成源 -> 源/生成证据、兼容性、同步影响和验证命令 |
| [`mt3_test_engineer`](.codex/agents/mt3_test_engineer.toml) | 单元、集成、跨平台回归、构建门禁和发布检查 | `medium` / `read-only` | 行为改动与风险范围 -> 必测/建议测试分层、回归用例和可执行命令 |

### 11.4 版本历史与维护检查

- 当前角色注册表和 13 份角色配置由提交 `136acd5bc`（`2026-07-25`，`batch1: root files + engine + cocos + server + small dirs`）引入；截至本次核对，`git log -- .codex/config.toml .codex/agents` 仅返回该记录。
- 技能目录的后续变更以 `git log -- .agents/skills` 为准；当前可追溯记录包括 `7ea59af3b`（`2026-07-30`）和 `dbe09dc2a`（`2026-08-03`），它们不替代角色注册表的当前定义。
- 新增、删除或修改角色时，必须在同一变更中同步 `.codex/config.toml`、对应 `.toml`、本节角色目录和版本历史说明；修改技能接口时同步检查其 `openai.yaml` 与技能审计结果。
- 只修改文档时，至少执行 UTF-8/BOM/换行检查、Markdown 链接存在性检查和限定路径的 `git diff --check`；改动 `.codex` 或 `.agents` 时，按第 5 节和 `codex-runtime-governance` 技能执行对应治理审计。

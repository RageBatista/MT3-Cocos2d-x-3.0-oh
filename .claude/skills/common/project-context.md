---
name: project-context
version: 1.3.1
priority: high
category: common
description: |
  MT3 项目事实与最小上下文技能。用于在分析、规划、文档、配置治理或跨模块排障前快速建立当前仓库事实、工具链边界和目录分流。
  触发词: 项目, 架构, 上下文, 约束, 目录, 工具链
allowed-tools:
  - Read
---

# MT3 项目上下文

## 目标

- 提供当前仓库的最小事实基线，避免历史 README、旧报告或过期记忆污染后续判断。
- 只回答“现在这个仓库是什么、边界在哪里、下一步该读什么”，不承载教程、学习路线或长篇案例。

## 事实优先级

1. `AGENTS.md`
2. `.claude/RULES.md`
3. `.claude/BUILD_GUIDE.md`
4. `.claude/CODEX_BRIDGE.md`
5. 已校准 `docs/`

若旧 README、历史报告或技能内容与以上入口冲突，以这条优先级为准。

## 当前仓库事实

```yaml
项目名称: MT3（梦幻西游 MG 版本）
项目类型: 2D MMORPG 商业游戏
主客户端: Win32 + Android + iOS
服务器: Java + Ant + gnet/xbean
主渲染链: Cocos2d-x 2.2.6 + Nuclear
代码规模: ~5,300,000+ 行
客户端运行时架构:
  1: 平台层（Win32 / Android / iOS）
  2: Cocos2d-x 2.2.6 层
  3: Nuclear 引擎层
  4: FireClient 业务层
```

说明：

- `FireClient.lib`、`engine.lib`、`libcocos2d.lib` 是构建产物，不是“源码不可修改”的含义。
- 对应第一方源码允许修改，但必须用正确工具链按依赖顺序重编。

## 工具链硬边界

```yaml
Windows:
  required: VS2013 + v120 + Windows SDK 8.1
  canonical_entry: tools/scripts/Build-MT3-Exe-Canonical.ps1

Android:
  required: NDK r16 clang + Ant + JDK8 + Python 2.7
  canonical_entry: tools/scripts/Build-Android-Locojoy-WithGate.ps1

Server:
  required: JDK 1.7/1.8 + Ant
  canonical_entry: server/server/game_server/build.xml
```

## 目录分流

| 范围 | 定位 | 典型下一步 |
|---|---|---|
| `client/FireClient/Application/**` | 第一方共享业务源码 | 读 FireClient 业务链、Manager/Framework/Scene/Battle |
| `client/MT3Win32App/**` | Win32 壳层/启动层 | 读 Win32 入口与最终链接链 |
| `client/android/**` | Android 多渠道壳层与 JNI | 读渠道工程、Application、JNI、打包脚本 |
| `client/FireClient/FireClient/**` | iOS 壳层与 ObjC++ 桥接 | 读 `main.m`、`AppDelegate`、`ViewController` |
| `engine/**` | 第一方引擎源码 | 读引擎能力、渲染/世界对象实现 |
| `common/**` | 公共库与热更新基础能力 | 读公共模块与 `updateengine` |
| `server/**` | Java 服务端 | 读 `build.xml`、协议、xbean/gnet |
| `tools/**` | 编辑器、PFS、精灵打包工具链 | 读 SpriteEditor、PFS、发布工具 |
| `dependencies/**` | 第三方/vendor | 默认不改，只做专项补丁 |

## 生成物与编码边界

- 生成代码默认不手改：
  - `server/**/xbean/*.java`
  - `server/**/rpc/*.java`
  - `client/**/tolua++/*.cpp`
  - `client/FireClient/Application/ProtoDef/**`
- 修改已有文本文件必须保持原编码、BOM 和换行。
- `dependencies/**` 与 vendor 目录不参与全仓统一风格或统一转码治理。

## Codex / Claude 工作流入口

1. 先读 `AGENTS.md`
2. 再读 `.claude/RULES.md`
3. 涉及构建、发布、重编时读 `.claude/BUILD_GUIDE.md`
4. 再按 `.claude/CODEX_BRIDGE.md` 进入 `.claude/config/router.json`
5. Codex 原生技能层继续从 `.agents/skills/mt3-project-guidelines/SKILL.md` 分流

## 何时继续读

- 构建或 ABI 问题：`.claude/BUILD_GUIDE.md`
- 配置治理：`.claude/skills/common/claude-config-engineering.md`
- 架构分析：`docs/02-技术架构/02-项目架构.md`
- Codex 原生技能分流：`.agents/skills/mt3-project-guidelines/SKILL.md`

## 不再在这里维护的内容

- 新人学习路径
- 过期 README 行数与历史统计
- 历史更新日志
- 与当前仓库事实冲突的技术版本快照

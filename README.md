# MT3（梦幻西游 MG 版本）

> **版本**: 1.0
> **更新**: 2026-07-28

MT3 是一个基于 Cocos2d-x 2.2.6 的 2D MMORPG 商业游戏，采用四层架构设计，代码规模约 530 万行，涵盖 C++、Lua、Java 和工具代码。

---

## 技术栈

| 层 | 技术 | 说明 |
|---|------|------|
| 游戏引擎 | Cocos2d-x 2.2.6 | Win32/Android/iOS 全平台主线 |
| 自研引擎 | Nuclear Engine | 场景/精灵/动画/特效/渲染 |
| UI 框架 | CEGUI 0.7.1 | runtime 位于 `dependencies/cegui/` |
| 脚本 | Lua 5.1 + tolua++ | 游戏逻辑主要用 Lua 实现 |
| 服务端 | Java + Ant + gnet/XBean | 位于 `server/server/game_server/` |
| 构建工具 | MSBuild 12.0 / NDK r16b / Ant | 详见工具链约束 |

---

## 四层架构

```
┌─────────────────────────────────────────┐
│  FireClient 业务层                       │
│  C++ 业务 / Lua / CEGUI UI / 协议 / Manager / Battle / SceneObj │
├─────────────────────────────────────────┤
│  Nuclear 引擎层                          │
│  IEngine / IWorld / IEnv / 场景 / 精灵 / 动画 / 特效          │
├─────────────────────────────────────────┤
│  Cocos2d-x 基础层                        │
│  渲染 / 音频 / 物理 / Lua 基础 / extensions / 平台适配         │
├─────────────────────────────────────────┤
│  平台层                                  │
│  Win32 / Android / iOS 生命周期、系统能力、渠道 SDK            │
└─────────────────────────────────────────┘
```

---

## 目录结构

```
MT3/
├── client/                      # 客户端
│   ├── FireClient/              # 共享业务层
│   │   └── Application/         # Framework, Manager, SceneObj, Battle, ProtoDef
│   ├── MT3Win32App/             # Win32 壳层 (.vcxproj)
│   ├── resource/                # 游戏资源 (res/, scripts/, audio/)
│   └── android/                 # Android 渠道项目 (LocojoyProject 等)
├── engine/                      # Nuclear 自研引擎
├── cocos2d-x-2.2.6/             # Cocos2d-x 2.2.6（当前全平台主线）
├── cocos2d-x-3.0-oh/            # Cocos2d-x 3.0 评估树（草案，非构建主线）
├── common/                      # 公共库 (platform, ljfm, cauthc, updateengine)
├── server/                      # 服务端 (Java/Ant + gnet/XBean)
│   └── server/game_server/      # 主入口
├── gbeans/                      # Server design-config 源 XML
├── dependencies/                # 第三方依赖 (CEGUI 0.7.1, freetype, SILLY, speex)
├── lib/                         # 预编译库 (vs2013/)
├── tools/
│   ├── scripts/                 # 构建与验证脚本
│   └── CEGUI-0.7.9-r5/          # CEGUI 源码（工具/评估）
└── docs/                        # 项目文档
```

---

## 快速构建

### Win32 客户端

```powershell
# 标准构建（推荐入口）
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release

# 快速本地调试构建
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -FastLocal -MaxParallelJobs 8

# 完整验证（Debug + Release + 运行时审计）
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both
```

### Android（Locojoy free 渠道）

```powershell
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-Android-Locojoy-WithGate.ps1 `
    -ProjectDir client\android\LocojoyProject `
    -BuildType Debug `
    -Channel free `
    -Jobs 4
```

### 服务端

```bash
cd server/server/game_server
ant init      # 首次：genfiles + mhsdcounter.jar
ant genfiles  # 重生成：genrpc + genxdb + gengbeans + jsconvert
ant dist      # 编译打包
```

---

## 工具链约束（强制性）

| 平台 | 工具链 | 禁止 |
|------|--------|------|
| Win32 | VS2013 v120 + Windows SDK 8.1 | v140/v141/v142/v143 |
| Android | NDK r16b (16.1.4479499) + Ant + JDK 8 | Gradle, JDK 9+ |
| Server | JDK 1.7/1.8 + Ant | JDK 9+, Maven, Gradle |

### ABI 安全规则

- `engine/**/*.h` 变更 → `Rebuild engine → Rebuild FireClient → Build MT3`
- `client/FireClient/Application/**/*.h` 变更 → `Rebuild FireClient → Build MT3`
- `FireClient.win32.vcxproj` 与 `mt3.win32.vcxproj` 共享输出目录

---

## 生成代码边界（禁止手动修改）

| 生成器 | 源定义 | 输出 |
|--------|--------|------|
| xbean | `server/**/gsx.mkdb.xml` | `server/**/xbean/*.java`, `xtable/*.java` |
| gnet | `server/server/game_server/protocol.main.xml` | `server/**/rpc/*.java` |
| tolua++ | `client/tolua++-pkgs/**/*.pkg` | `client/FireClient/Application/Framework/Lua*.cpp` |
| ProtoDef | `client/FireClient/Application/*.xml` | `ProtoDef/**`, `script/protodef/**` |

---

## 文档索引

| 分类 | 文档 | 说明 |
|------|------|------|
| 入门 | [docs/01-快速入门/01-Windows快速启动.md](docs/01-快速入门/01-Windows快速启动.md) | Windows 环境快速上手 |
| 架构 | [docs/02-技术架构/02-项目架构.md](docs/02-技术架构/02-项目架构.md) | 系统架构与调用链 |
| 开发 | [docs/03-开发指南/02-Windows完整构建指南.md](docs/03-开发指南/02-Windows完整构建指南.md) | 完整构建流程 |
| 平台 | [docs/05-平台专项/android/01-快速开始.md](docs/05-平台专项/android/01-快速开始.md) | Android 构建指南 |
| 工具链 | [docs/06-工具链/01-工具链总览.md](docs/06-工具链/01-工具链总览.md) | 依赖矩阵与配置 |
| 问题 | [docs/04-问题排查/01-编译问题排查.md](docs/04-问题排查/01-编译问题排查.md) | 常见问题与解决 |

完整文档列表见 [docs/](docs/)

---

## 相关入口

| 文件 | 职责 |
|------|------|
| [AGENTS.md](AGENTS.md) | 仓库事实、任务分流、根级边界 |
| [CLAUDE.md](CLAUDE.md) | Claude Code 工作指引 |
| [codex.md](codex.md) | 项目知识库 |
| [docs/INDEX.md](docs/INDEX.md) | 完整文档索引 |

---

## 许可证

内部项目，版权归原作者所有。

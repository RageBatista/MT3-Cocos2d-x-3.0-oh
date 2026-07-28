# MT3 — 梦幻西游 MG 版本

> **版本**：2.0.0  
> **更新日期**：2026-07-28  
> **仓库**：[supercegui-wan/MT3](https://github.com/supercegui-wan/MT3)（正式）｜ [RageBatista/MT3-Cocos2d-x-3.0-oh](https://github.com/RageBatista/MT3-Cocos2d-x-3.0-oh)（备用）  
> **技术栈**：C++ / Lua / Java / Cocos2d-x / CEGUI / Nuclear Engine

MT3 是一款基于 Cocos2d-x 的 2D MMORPG 商业游戏客户端，采用四层架构设计，涵盖 Win32、Android、iOS 三端，并包含完整的 Java 服务端与资源生产链。当前正在进行双引擎升级（Cocos2d-x 2.2.6 → 3.0-oh + CEGUI 0.7.1 → 0.7.9-r5）。

---

## 目录

- [项目概述](#项目概述)
- [功能特点](#功能特点)
- [四层架构](#四层架构)
- [目录结构](#目录结构)
- [环境要求](#环境要求)
- [安装与配置](#安装与配置)
- [构建指南](#构建指南)
- [API 接口文档](#api-接口文档)
- [常见问题 (FAQ)](#常见问题-faq)
- [贡献指南](#贡献指南)
- [文档索引](#文档索引)
- [许可证](#许可证)

---

## 项目概述

MT3 是一个大型商业 2D MMORPG 游戏项目，具备以下核心系统：

| 系统 | 说明 |
|------|------|
| 客户端业务层 | C++ 业务逻辑 + Lua 脚本 + CEGUI 界面，涵盖登录、战斗、场景、网络、Manager 框架 |
| 自研引擎 (Nuclear) | 场景管理、精灵系统、地图渲染、动画控制、粒子特效 |
| 服务端 | Java/Ant 构建，gnet 网络框架、XBean 数据持久化、RPC 通信 |
| 资源生产链 | PFS 热更新、Sprite 图集打包、LJFilePack 资源打包、三端同步 |
| 工具链 | CEImagesetEditor、CELayoutEditor、BinLayoutStudio、SpriteEditor 等离线工具 |

### 当前工程状态

| 维度 | 状态 |
|------|------|
| Cocos2d-x 主干 | 2.2.6（当前全平台主线） |
| 双引擎升级 | 3.0-oh + CEGUI 0.7.9-r5（进行中，约 45.7%） |
| Win32 构建 | Debug/Release 均通过，`MT3.exe` 可运行 |
| Android 构建 | LocojoyProject free 渠道，arm64-v8a |
| iOS 构建 | Xcode 工程已迁移至 2.2.6 |
| 服务端构建 | JDK 1.7/1.8 + Ant，通过 |

---

## 功能特点

### 客户端

- **跨平台支持**：Win32（VS2013）、Android（NDK r16b）、iOS（Xcode）
- **Lua 脚本驱动**：2500+ Lua 文件实现 UI 对话框、游戏逻辑、数据同步
- **CEGUI UI 框架**：基于 CEGUI 0.7.1 的 XML 布局系统，800+ layout 文件
- **自研 Nuclear 引擎**：场景/世界/精灵/地图/动画/特效一体化渲染
- **热更新系统**：PFS 资源包差异更新，支持三端资源同步
- **网络通信**：libcurl HTTP 客户端、gnet 游戏协议、RPC 远程调用
- **语音系统**：集成讯飞语音识别与合成、Speex/AMR 音频编解码
- **输入法支持**：Win32/Android/iOS 系统输入法桥接

### 服务端

- **Java 游戏服务**：基于 gnet 框架的高性能游戏服务器
- **XBean 数据层**：XML 驱动的数据持久化与缓存
- **RPC 通信**：自动生成客户端/服务端协议代码
- **策划配置**：gbeans XML 源定义，自动生成 Java 配置类

### 工具链

- **资源打包**：LJFilePack 资源打包与 PFS 热更新发布
- **UI 编辑器**：CELayoutEditor、CEImagesetEditor、BinLayoutStudio
- **精灵图集**：SpriteEditor 自动打包与 ANI/XAP 输出
- **构建审计**：PowerShell 脚本驱动的自动化构建验证

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

- **平台壳层**负责启动共享主链，不承载另一套独立业务核心
- **CEGUI 0.7.1** 运行时位于 `dependencies/cegui/`，通过 Cocos2D renderer 与 FireClient/Lua UI 协作
- **Lua 脚本**位于 `client/resource/res/script/`，是 FireClient 业务/UI 的组成部分

---

## 目录结构

```
MT3/
├── client/                          # 客户端
│   ├── FireClient/                  # 共享业务层
│   │   ├── Application/             # Framework, Manager, SceneObj, Battle, ProtoDef
│   │   └── FireClient/              # iOS 平台壳层
│   ├── MT3Win32App/                 # Win32 壳层 (.vcxproj)
│   ├── resource/                    # 游戏资源
│   │   ├── res/script/              # Lua 脚本 (2500+ 文件)
│   │   ├── res/ui/                  # CEGUI 布局 (800+ layout)
│   │   ├── res/audio/               # 音频资源
│   │   └── tools/                   # 资源打包工具
│   ├── android/                     # Android 渠道项目
│   │   └── LocojoyProject/          # free 渠道主线
│   └── Build-MT3-v120.ps1           # Win32 构建依赖链
├── engine/                          # Nuclear 自研引擎
├── cocos2d-x-2.2.6/                 # Cocos2d-x 2.2.6（当前全平台主线）
├── cocos2d-x-3.0-oh/                # Cocos2d-x 3.0-oh（双引擎升级目标）
├── common/                          # 公共库
│   └── platform/                    # 平台抽象、单例模式等
├── server/                          # 服务端
│   └── server/game_server/          # 主入口 (build.xml)
├── gbeans/                          # 策划配置源 XML
├── dependencies/                    # 第三方依赖
│   ├── cegui/                       # CEGUI 0.7.1 运行时
│   ├── freetype/                    # 字体渲染
│   └── speex/                       # 语音编解码
├── lib/                             # 预编译库 (vs2013/)
├── tools/
│   ├── scripts/                     # 构建与验证脚本
│   ├── CEGUI-0.7.9-r5/              # CEGUI 0.7.9-r5 源码（升级目标）
│   └── android_dump_analyze/        # Android 调试工具
├── docs/                            # 项目文档
├── .claude/                         # Claude 规则与构建指南
├── .codex/                          # Codex 运行时配置
├── .agents/                         # Agent 技能定义
└── .trae/                           # Trae IDE 规则适配
```

---

## 环境要求

### 必需工具链

| 组件 | 版本要求 | 用途 |
|------|---------|------|
| Visual Studio | 2013 (v120) | Win32 客户端编译 |
| Windows SDK | 8.1 | Win32 平台 SDK |
| MSBuild | 12.0 | 构建引擎 |
| Android NDK | r16b (16.1.4479499) | Android 原生编译 |
| Android SDK | API 22 + build-tools 22.0.1 | Android APK 打包 |
| Apache Ant | 1.9+ | Android 构建 |
| JDK | 1.8 | Android/服务端编译 |
| Python | 2.7 | 旧构建脚本 |
| CMake | 3.10 | Cocos2d-x 3.0-oh CMake 工程（仅升级分支） |
| PowerShell | 5.1+ | 构建脚本运行 |

### 禁止事项

| 范围 | 禁止 |
|------|------|
| Win32 | 禁止使用 v140/v141/v142/v143（VS2015+） |
| Android | 禁止使用 Gradle、JDK 9+、回退 NDK r10e/GCC |
| 服务端 | 禁止使用 JDK 9+、Maven/Gradle 替换 Ant |

### 操作系统

- **Windows**：Windows 10/11（主要开发环境）
- **macOS**：iOS 构建需要（仅 Xcode 工程）
- **Android**：Android 5.0+ (API 21+)

---

## 安装与配置

### 1. 克隆仓库

```bash
git clone https://github.com/supercegui-wan/MT3.git
cd MT3
```

### 2. Win32 开发环境配置

1. 安装 Visual Studio 2013（含 Windows SDK 8.1）
2. 验证工具链：

```powershell
# 检查 v120 工具链
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1

# 查看 MSBuild 版本
cmd /c '"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" /version'
```

### 3. Android 开发环境配置

1. 安装 JDK 8，设置 `JAVA_HOME`
2. 安装 Android NDK r16b，设置 `ANDROID_NDK_ROOT`
3. 安装 Android SDK（API 22），设置 `ANDROID_HOME`
4. 安装 Apache Ant，确保 `ant` 在 PATH 中

```powershell
# 验证 Android 环境
$env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_202"
$env:ANDROID_NDK_ROOT = "C:\android-ndk-r16b"
$env:ANDROID_HOME = "C:\android-sdk"
ant -version
```

### 4. 服务端环境配置

1. 安装 JDK 1.8，设置 `JAVA_HOME`
2. 安装 Apache Ant

```bash
cd server/server/game_server
ant -version
```

---

## 构建指南

### Win32 客户端

```powershell
# 标准 Release 构建（推荐入口）
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release

# 快速本地 Debug 构建
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -FastLocal -MaxParallelJobs 8

# 完整验证（Debug + Release + 运行时审计）
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both
```

### ABI 安全规则

头文件变更后必须按整链顺序重编，不可只做单项目增量构建：

| 变更范围 | 重编顺序 |
|---------|---------|
| `engine/**.h` | `Rebuild engine → Rebuild FireClient → Build MT3` |
| `client/FireClient/Application/**.h` | `Rebuild FireClient → Build MT3` |
| Cocos2d-x 公共接口 | `Rebuild Cocos → Rebuild engine → Rebuild FireClient → Build MT3` |

### Android（LocojoyProject free 渠道）

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

# 首次构建
ant init      # genfiles + mhsdcounter.jar

# 常规构建
ant genfiles  # 重生成：genrpc + genxdb + gengbeans + jsconvert
ant dist      # 编译打包
```

### 生成代码边界

以下为生成代码，**禁止手动修改**，应修改源定义后重新生成：

| 生成器 | 源定义 | 输出 |
|--------|--------|------|
| xbean | `server/**/gsx.mkdb.xml` | `server/**/xbean/*.java` |
| gnet | `server/server/game_server/protocol.main.xml` | `server/**/rpc/*.java` |
| tolua++ | `client/tolua++-pkgs/**/*.pkg` | `client/FireClient/Application/Framework/Lua*.cpp` |
| ProtoDef | `client/FireClient/Application/*.xml` | `ProtoDef/**`, `script/protodef/**` |
| gengbeans | `gbeans/*.xml` | `server/**/gbeans/*.java` |

### 资源生产链

```
client/resource/res/**                     # 业务源资源（可修改）
  → LJFilePackOption.xml / LJFilePack_打包*.bat
  → client/res_android|res_ios|res_win/**  # 平台 staging（生成）
  → Android -SyncRes
  → client/android/LocojoyProject/assets/res/** # APK 工程生成输入
```

---

## API 接口文档

### 客户端核心接口

#### Nuclear 引擎

| 接口 | 文件 | 说明 |
|------|------|------|
| `IEngine` | `engine/` | 引擎主接口，管理场景/世界/渲染 |
| `IWorld` | `engine/` | 世界管理，容器与实体 |
| `IEnv` | `engine/` | 环境配置，光照/天气 |
| `IQuery` | `engine/` | 场景查询，拾取/碰撞 |

#### FireClient 业务框架

| 接口 | 文件 | 说明 |
|------|------|------|
| `GameApplication` | `Application/GameApplication.h` | 应用主入口，管理生命周期 |
| `SpaceManager` | `Manager/SpaceManager.h` | 网络图片下载与缓存 |
| `VoiceManager` | `Manager/VoiceManager.h` | 语音录制/播放/识别 |
| `IconManager` | `Manager/IconManager.h` | UI 图标与 Imageset 管理 |
| `SceneMovieManager` | `Manager/SceneMovieManager.h` | 场景动画与剧情系统 |
| `DownloadManager` | `Manager/DownloadManager.h` | HTTP 文件下载管理 |

#### Cocos2d-x 基础层

| 模块 | 关键类 | 说明 |
|------|--------|------|
| 场景图 | `CCNode`, `CCScene`, `CCLayer` | 节点树与场景管理 |
| 动作系统 | `CCAction`, `CCMoveTo`, `CCSequence` | 动画与缓动 |
| 事件系统 | `CCEventDispatcher`, `CCEventListener` | 触摸/键盘/自定义事件 |
| UI 控件 | `CCTextFieldTTF`, `CCLabelTTF` | 文本输入与显示 |
| 纹理 | `CCTexture2D`, `CCTextureCache` | 纹理加载与缓存 |
| 音频 | `SimpleAudioEngine` | 背景音乐与音效 |

### Lua 脚本接口

Lua 脚本位于 `client/resource/res/script/`，采用全局注册 + Dialog/Manager 生命周期模式：

```lua
-- 全局函数注册示例
function MyDialog:onOpen()
    -- 窗口打开时的初始化逻辑
end

function MyDialog:onClose()
    -- 窗口关闭时的清理逻辑
end
```

### HTTP 网络 API

```cpp
// 使用 FireClient 的 DownloadManager 发起 HTTP 请求
#include "Manager/DownloadManager.h"

// SpaceManager 的 HTTP 请求
#include "Manager/SpaceManager.h"
gGetSpaceManager()->SendRequest("protocol_id", "https://api.example.com/data");
```

---

## 常见问题 (FAQ)

### 构建问题

**Q: 构建时提示 "error MSB8020: The build tools for v120 cannot be found"**

A: 需要安装 Visual Studio 2013。如果已安装 VS2015+，需要单独安装 VS2013 的 MSBuild 工具链。

**Q: 编译时出现大量 "deprecated" 警告**

A: Cocos2d-x 3.0-oh 中部分旧 API 已标记为废弃。这些警告不影响功能，但建议逐步迁移到新 API。详见 [API 对照表](docs/MT3-双引擎升级方案-cocos2d-x-3.0-oh-CEGUI-0.7.9-r5.md#附录-a快速参考--关键-api-对照表)。

**Q: Android 构建失败，提示 "Unsupported major.minor version 52.0"**

A: 需要 JDK 8。JDK 9+ 不支持旧版 Ant/dx 构建链。请设置 `JAVA_HOME` 指向 JDK 8。

**Q: 提示 `LINK : fatal error LNK1104: cannot open file 'xxx.lib'`**

A: 检查依赖库是否已编译。确保按 ABI 安全规则，从底层引擎开始逐层重编。

### 编码问题

**Q: 修改 C++ 文件后出现乱码**

A: MT3 项目中的 C++ 文件混合使用 UTF-8 BOM、CP936 (ANSI) 和 UTF-16 LE 编码。修改前请用编辑器的"另存为"确认原编码，修改后保持原编码不变。VS2013 编译的 UTF-8 文件必须保留 BOM。

**Q: clangd 报大量错误但 VS2013 构建通过**

A: clangd 可能无法正确解析 CEGUI 模板和 Cocos2d-x 宏。以 VS2013 MSBuild 构建结果为准。如遇误报，可在 `.clangd` 中添加文件级诊断抑制。

### 资源问题

**Q: 游戏运行时找不到 UI 布局或图片**

A: 检查 `client/resource/res/` 下的源资源是否存在，然后运行资源打包工具同步到平台 staging 目录。不要直接修改 `client/android/LocojoyProject/assets/res/` 下的文件。

**Q: 修改 layout 文件后未生效**

A: 确保重新运行了 LJFilePack 打包流程，并同步到目标平台的资源目录。

---

## 贡献指南

### 开发流程

1. **Fork 仓库**并创建功能分支
2. **阅读 AGENTS.md**：了解仓库事实、任务分流和根级边界
3. **遵循编码规范**：保持与所在模块一致的编码风格（缩进、命名、注释语言）
4. **提交前验证**：
   - 修改 C++ 代码后运行对应平台的构建
   - 修改头文件后按 ABI 安全规则进行整链重编
   - 使用 `git diff --check` 检查空白问题
5. **提交信息**：使用中文，格式为 `类型(范围): 简述`

### 提交类型

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `refactor` | 代码重构 |
| `docs` | 文档更新 |
| `build` | 构建系统变更 |
| `chore` | 杂项维护 |

### 编码约定

- **C++**：遵循所在模块既有风格，不批量格式化
- **Lua**：延续 `client/resource/res/script/` 的 Dialog/Manager 全局注册和生命周期惯例
- **Java**：服务端代码遵循 Java 编码规范
- **编码**：修改前探测原编码、BOM 和换行，修改后按原编码回读
- **ABI**：公共头文件变更需评估所有下游影响

### 文档规范

- 所有文档使用 Markdown 格式
- 技术文档放在 `docs/` 对应分类目录
- 新增文档需在 `docs/07-参考文档/02-文档索引.md` 中注册

### 提交前检查清单

- [ ] 代码已通过相应平台的构建
- [ ] 头文件变更已按 ABI 规则重编下游
- [ ] 无新增的 VS2013 编译错误
- [ ] 生成的代码未被手动修改
- [ ] 提交信息符合规范
- [ ] `git diff --check` 无空白问题

---

## 文档索引

| 分类 | 文档 | 说明 |
|------|------|------|
| 入门 | [docs/01-快速入门/01-Windows快速启动.md](docs/01-快速入门/01-Windows快速启动.md) | Windows 环境快速上手 |
| 入门 | [docs/01-快速入门/02-项目概述.md](docs/01-快速入门/02-项目概述.md) | 项目详细概述 |
| 架构 | [docs/02-技术架构/01-技术体系总览.md](docs/02-技术架构/01-技术体系总览.md) | 技术体系与组件关系 |
| 架构 | [docs/02-技术架构/02-项目架构.md](docs/02-技术架构/02-项目架构.md) | 系统架构与调用链 |
| 开发 | [docs/03-开发指南/02-Windows完整构建指南.md](docs/03-开发指南/02-Windows完整构建指南.md) | 完整构建流程 |
| 开发 | [docs/03-开发指南/06-资源打包与热更新发布指南.md](docs/03-开发指南/06-资源打包与热更新发布指南.md) | 资源打包与热更新 |
| 平台 | [docs/05-平台专项/android/01-快速开始.md](docs/05-平台专项/android/01-快速开始.md) | Android 构建指南 |
| 平台 | [docs/05-平台专项/ios/01-iOS发布前闸门清单.md](docs/05-平台专项/ios/01-iOS发布前闸门清单.md) | iOS 发布检查 |
| 工具链 | [docs/06-工具链/01-工具链总览.md](docs/06-工具链/01-工具链总览.md) | 依赖矩阵与配置 |
| 问题 | [docs/04-问题排查/01-编译问题排查.md](docs/04-问题排查/01-编译问题排查.md) | 常见编译问题与解决 |
| 升级 | [docs/MT3-双引擎升级方案-cocos2d-x-3.0-oh-CEGUI-0.7.9-r5.md](docs/MT3-双引擎升级方案-cocos2d-x-3.0-oh-CEGUI-0.7.9-r5.md) | 双引擎升级综合方案 |

### 权威入口

| 文件 | 职责 |
|------|------|
| [AGENTS.md](AGENTS.md) | 仓库事实、任务分流、根级边界 |
| [.claude/RULES.md](.claude/RULES.md) | 工具链、ABI、编码、生成代码硬约束 |
| [.claude/BUILD_GUIDE.md](.claude/BUILD_GUIDE.md) | 已验证构建命令与产物校验 |
| [.codex/config.toml](.codex/config.toml) | Codex 原生运行配置 |

---

## 许可证

© 内部项目。保留所有权利。

本仓库代码仅供授权人员使用，未经许可不得复制、分发或用于商业用途。
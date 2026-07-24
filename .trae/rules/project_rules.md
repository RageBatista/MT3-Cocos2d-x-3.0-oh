# MT3 Trae 项目规则

> **版本**：3.0.0
>
> **更新日期**：2026-07-18
>
> **定位**：本文件是 Trae 在 MT3 工作区中的兼容规则摘要，不建立第二套项目事实源。仓库事实以 [根 AGENTS.md](../../AGENTS.md) 和当前工程实物为准。

---

## 1. 规则来源与优先级

按以下顺序读取和裁决：

1. 当前源码、项目文件、构建脚本、配置、日志、构建输出和产物状态；
2. [根 AGENTS.md](../../AGENTS.md) 与目标目录最近的 `AGENTS.md`；
3. [.claude/RULES.md](../../.claude/RULES.md)；
4. [.claude/BUILD_GUIDE.md](../../.claude/BUILD_GUIDE.md)；
5. [.codex/config.toml](../../.codex/config.toml) 与 `.agents/skills/**`；
6. [当前项目架构](../../docs/02-技术架构/02-项目架构.md)；
7. `.trae/references/**`、`.trae/skills/**` 和历史报告。

此前规则引用的 `ai-shared-rules/` 目录在当前仓库中不存在，不再作为规则源。`.trae/references/common-constraints.md`、`.trae/references/project-rules.md` 等材料仍含旧 Cocos、旧编码和旧构建假设，只作背景材料；与本文件或根 `AGENTS.md` 冲突时以后两者为准。

## 2. 当前项目架构摘要

### 2.1 客户端四层逻辑架构

```text
FireClient 业务层
  client/FireClient/Application + client/resource/res/script + client/resource/res/ui
                         ↓
Nuclear 引擎层
  engine（场景、世界、精灵、地图、动画、特效、渲染组织）
                         ↓
Cocos2d-x 基础层
  图形、音频、物理、Lua 基础、extensions、平台适配
                         ↓
平台壳层
  client/MT3Win32App + client/android + client/FireClient/FireClient
```

- Win32、Android、iOS 壳层只负责入口、生命周期、系统能力和 SDK/JNI/ObjC++ 桥接，共享业务主链从 `gRunGameApplication()` 进入 FireClient。
- CEGUI UI、Lua 脚本和资源不是独立第五层：它们属于 FireClient 业务/UI，并通过 CEGUI Cocos2D renderer、Lua 绑定和 Nuclear 运行时协作。
- 服务端、资源生产链和工具链是并列子系统，不应被硬塞进客户端运行时层数。

### 2.2 其他子系统

| 子系统 | 路径 | 事实 |
| --- | --- | --- |
| 公共库 | `common/` | `platform`、`ljfm`、`cauthc`、Lua/tolua、更新等共享基础 |
| 服务端 | `server/` | Java + Ant + gnet/XBean；主入口 `server/server/game_server/build.xml` |
| 配置源 | `gbeans/*.xml` | `gengbeans` 的源定义，不是生成 Java |
| 资源源 | `client/resource/res/**` | Lua、UI、表、音频等业务资源源头 |
| 平台资源 staging | `client/res_android/**`、`client/res_ios/**`、`client/res_win/**` | LJFilePack 生成目录，可能被忽略且在干净 checkout 中缺席 |
| Android APK 资源 | `client/android/LocojoyProject/assets/res/**` | 构建同步生成输入，不手工修改 |
| 工具链 | `tools/`、`client/resource/tools/` | 构建审计、PFS/热更新、编辑器、图集和资源打包工具 |

## 3. 版本和平台基线

### 3.1 Cocos2d-x 不是全平台单一物理根

| 范围 | 当前工程事实 | 处理规则 |
| --- | --- | --- |
| Win32 canonical | `*.win32.vcxproj` 与 `client/Build-MT3-v120.ps1` 使用 `cocos2d-x-2.2.6/` | 新依赖只接当前树；修改公共接口后重编全部下游 |
| Android Locojoy free | `LocojoyProject/jni/Android.mk` 使用 `cocos2d-x-2.2.6/` | NDK r16 clang/arm64 门禁必须通过；不得回退 r10e/GCC |
| Android 遗留点 | `engine/Android.mk` 仍导入旧树 `libSpine` | `Assert-AndroidArm64Migration.ps1` 会报告该漂移；先修依赖再宣称闭环 |
| iOS | FireClient 与 engine 的 Xcode 工程仍引用 `cocos2d-2.0-rc2-x-2.0.1/` | 旧树目前仍是 iOS 现实兼容依赖；迁移必须在 macOS/Xcode 验证 |
| 旧 Win32/WinRT/WP8 工程 | 仍可能包含旧树路径 | 不属于 Win32 canonical 主线，不用其配置覆盖主线 |

因此：不得继续把 Cocos2d-x 2.0 写成 Win32/Android 当前主线，也不得把整个 2.0 树描述成全仓纯历史只读目录。

### 3.2 核心依赖事实

| 组件 | 当前事实 | 注意事项 |
| --- | --- | --- |
| Nuclear | `engine/` 第一方引擎 | 允许修改，公共头按 ABI 高风险处理 |
| CEGUI | 运行时 `dependencies/cegui/` 为 0.7.1 | `tools/CEGUI-0.7.1`、`0.7.9-r5` 等是工具/快照，不替换运行时 |
| Lua | 当前 2.2.6 主线头文件为 Lua 5.1.5 | iOS/历史树按其工程引用核对，不做全仓版本替换 |
| tolua++ | 当前主线包含 1.0.93；`common/tolua++-1.0.93` 的头仍声明 1.0.92 | 以实际生成器和头文件为准，禁止只按目录名批量“修版本” |
| FMOD、gnet、第三方库 | 仓库内遗留版本/二进制依赖 | 不手工编辑二进制，不用新版本直接覆盖旧 ABI |

## 4. 主线工具链与入口

| 范围 | 工具链 | 入口 |
| --- | --- | --- |
| Win32 | VS2013 `v120` + Windows SDK 8.1 + MSBuild 12.0 | `tools/scripts/Build-MT3-Exe-Canonical.ps1` |
| Android free | NDK r16b clang + Ant + JDK 8；旧脚本需要时 Python 2.7 | `tools/scripts/Build-Android-Locojoy-WithGate.ps1` |
| iOS | macOS + Xcode/xcodebuild | `client/FireClient/FireClient.xcodeproj` |
| 服务端 | JDK 1.7/1.8 + Ant | `server/server/game_server/build.xml` |

- `client/Build-MT3-v120.ps1` 是 Win32 canonical 脚本内部依赖链，不是另起一套外部入口。
- Android 当前验证对象是 `LocojoyProject` 的 free 渠道；Joysdk、Yijie、monthpayment 等目录存在不等于已通过同一轮验收。
- 不以 CMake/新 MSVC、Gradle、新 NDK、Maven/Gradle 或 JDK 9+ 隐式替换现有主线。
- iOS 构建结论只在 macOS/Xcode 执行器产生；Windows 上只做静态工程审查。

## 5. 编译配置不得全仓一刀切

原规则把以下内容写成全仓统一要求：Unicode 字符集、`/W3`、固定禁用警告、SDLCheck、`_CRT_SECURE_NO_WARNINGS`、`_SCL_SECURE_NO_WARNINGS`、固定链接器开关、原生 OpenGL-only。当前项目文件并不支持这些全局结论。

正确规则：

- `PlatformToolset=v120` 是 Win32 canonical 硬约束；字符集、宏、警告、SDLCheck、运行时库和链接器项以具体 `.vcxproj` 的目标配置为准。
- MT3/FireClient canonical 工程当前为 Unicode，`engine.win32.vcxproj` 的 `CharacterSet` 为 MultiByte 但部分配置又定义 `UNICODE`；不得批量统一。
- canonical Debug/Release 主链通常使用 `/MDd` 与 `/MD`，但修改前仍需核对受影响工程，不用规则文件覆盖 vendor/示例工程。
- `mt3.win32.vcxproj` 当前同时链接 `opengl32/glew32` 与 `libEGL/libGLESv2`；不得再写“Win32 绝对禁止 EGL/GLES”或据此删除现有链接项。渲染路径以 Cocos/Nuclear 实际代码和项目配置为准。
- 不统一注入 `/DYNAMICBASE:NO`、`/GS-` 或其他安全/链接开关；先验证当前配置、运行时兼容性和产物影响。
- 代码缩进、花括号、命名、预编译头和注释语言遵循最近模块既有风格，不用单一模板重排历史代码。

## 6. 源定义、生成代码和资源链

### 6.1 客户端协议与 tolua++

以下为生成结果：

- `client/FireClient/Application/ProtoDef/**`；
- `client/resource/res/script/protodef/**`；
- `client/FireClient/Application/Framework/LuaEngine.cpp`；
- `client/FireClient/Application/Framework/LuaFireClient.cpp`；
- 其他由 tolua++ 输出的绑定 `.cpp`。

源入口包括：

- `client/FireClient/Application/client.xml`、`modules.xml`、`pkg_client.xml`、`lua_client.xml`；
- `client/FireClient/Application/genprotocol*.bat/.sh`；
- `client/tolua++-pkgs/FireClient/FireClient.pkg`；
- `engine/tolua++-pkgs/engine.pkg`。

协议/绑定变更应修改源定义并运行对应生成链，不长期手工维护输出文件。

### 6.2 服务端生成链

- `server/server/game_server/build.xml` 的 `genrpc`、`genxdb`、`gengbeans`、`genfiles`、`dist` 是当前入口。
- `server/**/rpc/*.java` 与 `server/**/xbean/*.java` 是生成结果。
- `gbeans/*.xml`、协议 XML 和 XDB 定义是源；客户端与服务端协议需要成对更新和验证。

### 6.3 资源链

```text
client/resource/res/**
  -> client/resource/tools/LJFilePack_打包*.bat
  -> client/res_android|res_ios|res_win/**
  -> Android -SyncRes
  -> client/android/LocojoyProject/assets/res/**
```

- 业务资源只改 `client/resource/res/**`。
- `client/resource/tools/**` 和各 staging/`assets/res` 路径当前可能是 ignored/runtime-local；先 `Test-Path` 和 `git check-ignore`，不要假设干净 checkout 必然拥有工具或输出。
- `assets/res` 的任何差异必须可追溯到打包/同步链，禁止手工修补。

## 7. ABI 与二进制边界

- `.lib/.dll/.exe/.a/.so/.jar/.apk` 和 `serverbin/**` 是构建/分发产物，不手工编辑。
- 修改 `engine/**.h` 的 ABI：`Rebuild engine -> Rebuild FireClient -> Build MT3`。
- 修改 `client/FireClient/Application/**.h` 的 ABI：`Rebuild FireClient -> Build MT3`。
- 修改 Cocos 公共接口：从对应 Cocos 库开始，继续重编 `engine -> FireClient -> MT3`。
- `FireClient.win32.vcxproj` 与 `mt3.win32.vcxproj` 共享配置输出目录，但 `IntDir` 分别带项目名；正确表述是“共享 OutDir、独立 IntDir”。仍需核对 `FireClient.lib` 和 `MT3.exe` 的时间戳及实际重建顺序。
- 不用 `/FORCE`、跨工具集库或局部替换掩盖 CRT、符号和对象布局问题。

## 8. 编码、Lua 与内存约定

- 修改既有文件时保持原编码、BOM 和换行。VS2013 编译且包含非 ASCII 的 UTF-8 C/C++ 文件必须保留 BOM；历史 CP936/ANSI/UTF-16 文件按原编码写回。
- `.rc` 保持原编码；禁止一律转成 UTF-8。新建 Markdown/JSON/XML/PowerShell/Lua/Java 默认 UTF-8 无 BOM，本文件当前为 UTF-8 无 BOM、CRLF。
- Lua 代码延续 `client/resource/res/script/**` 的 Dialog/Manager/全局注册和生命周期惯例。现有框架需要的全局注册不得被机械改成局部 module；新增全局前先确认框架查找方式和卸载生命周期。
- Cocos/Nuclear/CEGUI 对象分别遵循各自所有权模型。`create()` 工厂通常已返回 autorelease 对象，不再机械追加一次 `autorelease()`；跨层保存对象时明确 retain/release、销毁回调和容器所有权。
- PowerShell 环境变量使用 `$env:NAME`；只有在 `cmd /c` 或 `.bat/.cmd` 中使用 `%NAME%`。

## 9. 任务路由

| 任务 | 就近规则/入口 |
| --- | --- |
| FireClient 启动、登录、业务、协议 | `client/FireClient/Application/AGENTS.md` |
| Win32 壳层、链接、构建 | `client/MT3Win32App/AGENTS.md` |
| Android Java/JNI、渠道、APK | `client/android/AGENTS.md` |
| iOS ObjC++、Xcode、SDK | `client/AGENTS.md` + 实际 Xcode 工程 |
| Nuclear、渲染、特效 | `engine/AGENTS.md` |
| Java/Ant、RPC、XBean | `server/AGENTS.md` |
| PFS、热更新、图集、CEGUI 工具 | `tools/AGENTS.md` |
| 文档 | `docs/AGENTS.md` |
| Codex/Claude 配置治理 | `.codex/**`、`.agents/skills/**`、`.claude/AGENTS.md` |

## 10. 最小验证

- 修改前：`git status --short`，确认用户已有改动；读取最近 `AGENTS.md`；检查目标编码/BOM/换行。
- 文档/规则修改后：严格 UTF-8 解码、BOM/换行回读、本地 Markdown 链接存在性、过时关键词扫描、`git diff --check`。
- C++/平台/服务端/资源改动：按 [BUILD_GUIDE](../../.claude/BUILD_GUIDE.md) 和最近目录规则执行最小相关构建或生成链。
- 未在对应执行器验证的内容明确记录为未执行，不把静态审查写成构建成功。

## 11. 本轮逐条核对结论

| 原描述 | 核对结果 | 当前规则 |
| --- | --- | --- |
| `ai-shared-rules/` 是单一事实源 | 路径不存在 | 根 `AGENTS.md` + 工程实物为事实源 |
| Cocos2d-x 2.0 是 Win32 当前版本 | 与 canonical 工程不符 | Win32/Android canonical 为 2.2.6；iOS 仍引用旧树 |
| Android NDK r10e/GCC | 已过时 | NDK r16b clang + Ant + JDK8，Locojoy free/arm64 主线 |
| 全仓 Unicode、固定警告/宏/SDL | 项目文件不统一 | 按具体工程和配置核对 |
| Win32 只允许原生 OpenGL，禁止 EGL/GLES | 与最终工程链接项冲突 | 不抽象删除现有后端依赖，以代码和项目文件为准 |
| 所有 C/C++/RC 都用 UTF-8 BOM | 与混合编码现状冲突 | 保持原编码；仅 VS2013 UTF-8 非 ASCII 源码强制 BOM |
| 统一 PascalCase/camelCase/行尾花括号 | 仓库多语言多历史风格不支持 | 遵循最近模块既有风格 |
| Lua 一律禁止全局 | 与现有 Dialog/Manager 注册机制冲突 | 区分框架注册全局与意外污染 |
| `create()` 后再次 `autorelease()` | 会导致所有权错误 | 遵循实际工厂语义，不重复 autorelease |
| Win32 工程共用同一中间目录 | 项目文件显示 IntDir 独立 | 共享 OutDir、独立 IntDir |
| 旧文档链接 `docs/19-*`、`docs/05-*`、`docs/06-*` | 路径不存在 | 使用当前 `docs/02-*`、`docs/03-*` 和 `.claude/BUILD_GUIDE.md` |

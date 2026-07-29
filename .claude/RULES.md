# MT3 硬约束（RULES）

**版本**: 5.5.0
**更新日期**: 2026-07-05
**定位**: 本文件只保留会直接影响构建正确性、ABI、编码安全和代码生成边界的硬约束。

---

## 1. 单一职责

- 仓库事实与高层边界以根 [AGENTS.md](../AGENTS.md) 为准。
- 已验证构建命令以 [BUILD_GUIDE.md](BUILD_GUIDE.md) 为准。
- 本文件不承载教程、学习路线、案例复盘、过时脚本或临时排障经验。

## 2. 工具链硬约束

| 平台 | 主线工具链 | 禁止事项 |
|------|------|------|
| Windows 桌面 | `v120 (VS2013)` + `Windows SDK 8.1` | 禁止主线使用 `v140/v141/v142/v143` |
| Android | `NDK r16b (16.1.4479499) clang + Ant + JDK 8 + Python 2.7` | 禁止主线使用 `JDK 9+`、不完整 Android SDK、Gradle 替换 Ant，禁止回退到 r10e/GCC |
| 服务器 | `JDK 1.7/1.8 + Ant` | 禁止主线使用 `JDK 9+` 或 Maven/Gradle 替换 Ant |

补充：

- Win32 主线只针对当前 Win32 客户端交付目标；WinRT/WP8/ANGLE 示例工程不纳入主线构建约束。
- 主线项目的 `PlatformToolset` 必须与其目标发布链一致，不能用 vendor 或示例工程的配置推翻主线约束。
- Android Ant/dx 构建必须使用 JDK8。JDK17 会使旧 Ant 工程默认的 `source/target 1.5` 直接失败，禁止作为 Android 构建入口 JDK。
- Android Ant 打包的 `ANDROID_HOME/ANDROID_SDK_ROOT` 必须指向完整旧 SDK，至少包含 `tools/ant/build.xml`、`platform-tools`、`build-tools/22.0.1`、`platforms/android-22`。
- Android release 签名密码禁止写入已跟踪的 `ant.properties`；必须通过本机环境变量、CI Secret 或忽略入库的本地生成文件注入。

## 2.1 故障修复与验证硬约束

- 修复前必须先定性故障域，至少区分为：`工具链/构建`、`运行时崩溃`、`UI比例/显示`、`网络配置`。
- 未定位根因前，禁止跨故障域同时改动（例如 UI 比例问题中同时改 C++ 初始化流程、登录网络地址、退出流程）。
- 一次修复只允许一个主故障域；若需跨域，必须拆分为可独立回滚的多次提交。
- Android 登录链路相关修复，必须同时通过以下最小门禁才可判定“已修复”：
  1. 登录首屏显示正常；
  2. 点击“进入游戏”连续 3 次稳定进入，无闪退；
  3. `adb logcat` 无新增 `FATAL EXCEPTION` / `SIGSEGV` / `UnsatisfiedLinkError`。
- 若任一门禁失败，必须先回到最后已知可用版本，再做二分定位；禁止继续叠加猜测式补丁。

## 3. ABI 与二进制约束

- `FireClient.lib`、`engine.lib`、`cocos2d.lib`、`cegui-0.7.9.lib` 等是构建产物，禁止手工编辑或跨工具集替换。
- 第一方源码允许修改，但必须使用主线工具链重编对应产物。
- 禁止把“二进制 ABI 不能乱动”误写成“对应源码不可修改”。
- 后续升级 `Cocos2d-x`、Lua 或 CEGUI 版本时，必须单独立项评估 ABI、API、资源与构建链影响；禁止用新二进制直接覆盖当前 `Upgrade30` 链路。
- 禁止使用 `/FORCE` 掩盖符号冲突、CRT 冲突或链接错误。
- 禁止跨 CRT 边界分配/释放内存。
- 禁止把不同对象布局、不同公共头文件版本、不同宏分支展开结果的 `.obj/.lib` 链接进同一份 Win32 交付产物。

### 3.1 ABI 混编防护

- 以下变更默认视为 ABI 敏感变更：类成员增删改、继承关系变化、虚函数表变化、`sizeof` 或成员偏移变化、模板实例变化、内联实现变化、影响布局的宏开关变化。
- 以下路径中的头文件变更默认按 ABI 敏感处理：`engine/**.h`、`client/FireClient/Application/**.h`，以及 renderer、engine、framework、公共基类相关头文件。
- 修改 `engine/**` 中 ABI 敏感头文件后，必须执行 `Rebuild engine -> Rebuild FireClient -> Build MT3`，禁止只对单项目做增量 `Build`。
- 修改 `client/FireClient/Application/**` 中 ABI 敏感头文件后，必须执行 `Rebuild FireClient -> Build MT3`，禁止跳过 `FireClient` 直接重链 `MT3`。
- 一旦怀疑已有 ABI 混编，必须停止继续增量补链，并从受影响项目开始按下游顺序 `Rebuild` 恢复一致产物。

### 3.2 混编判定信号

- dump、PDB 或调试信息里，同名类型同时出现两套 `sizeof`、成员偏移或布局记录。
- 调用方分配对象大小与被调方按成员偏移访问的布局不一致。
- fresh process 启动期在 `std::map`、`std::vector`、`this + offset` 一类容器或成员访问处崩溃，且调用链落在初始化阶段。

## 4. 主线 Win32 构建依赖顺序

Win32 canonical 默认使用 `EngineProfile=Upgrade30`，构建顺序固定如下：

1. `common/platform`
2. `common/ljfm`
3. `common/cauthc`
4. `cocos2d-x-3.0-oh` 的 v120 静态项目（基础依赖、core、audio、extensions、network、UI、Lua bindings）
5. `CEGUI-0.7.9-r5`
6. `engine`
7. `FireClient`
8. `MT3`

### 4.1 MT3.exe 固定入口脚本（唯一）

- 面向“执行编译构建 `MT3.exe` 并返回成功退出码”的场景，固定入口脚本为 `tools/scripts/Build-MT3-Exe-Canonical.ps1`。
- Agent、人工命令和 CI 手工触发均应优先调用该脚本，不再直接把 `client/Build-MT3-v120.ps1` 作为外部入口。
- canonical 默认 `EngineProfile=Upgrade30`，并在构建前拒绝 Cocos 2.2.6/3.0-oh 或 CEGUI 0.7.1/0.7.9-r5 的混合工程配置；验收命令仍应显式记录 `-EngineProfile Upgrade30`。
- 该脚本内部仍调用 `client/Build-MT3-v120.ps1` 的 ABI 安全链路，并默认启用 `-RuntimeAuditWarnOnly -AllowArchiveRuntimeFallback`，保证“编译成功即返回 `0`；编译失败返回非 `0`”。
- 如需把 runtime audit 的 High 问题升级为失败，显式传入 `-StrictRuntimeAudit`。

下游重编规则：

- 修改 `client/FireClient/Application/**` 后，至少重编 `FireClient`，再重链 `MT3`。
- 修改 `engine/**` 后，至少重编 `engine`，再重编 `FireClient` 或重链 `MT3`（视链接关系而定）。
- 修改 `cocos2d-x-3.0-oh/**` 或 `tools/CEGUI-0.7.9-r5/**` 后，必须重编对应库并继续重编 `engine -> FireClient -> MT3`。
- 若改动涉及第 3.1 节定义的 ABI 敏感头文件，以上“至少”一律提升为强制 `Rebuild`，不得以增量 `Build` 替代。

共享输出目录约束：

- `client/MT3Win32App/FireClient.win32.vcxproj` 与 `client/MT3Win32App/mt3.win32.vcxproj` 共享 `Release.win32` 输出目录（`IntDir` 按项目名分离）。
- 单项目增量 `Build/Rebuild` 可能出现“输出看似最新但未真正刷新”的情况。
- 涉及 `FireClient` 改动时，必须显式确认 `FireClient` 已重编，再重链 `MT3`；优先使用 [BUILD_GUIDE.md](BUILD_GUIDE.md) 中的顺序命令。

## 5. 生成代码/生成物约束

以下路径默认视为生成物，禁止直接手工维护为主流程：

- `server/**/xbean/*.java`
- `server/**/rpc/*.java`
- `client/**/tolua++/*.cpp`
- `client/FireClient/Application/ProtoDef/**`
- `client/android/LocojoyProject/assets/res/**`（Android Locojoy APK 资源生成产物）

正确流程：

1. 修改源定义文件（如 `*.xml`、`*.pkg`）。
2. 运行对应生成命令。
3. 验证生成结果进入构建链。

Android 资源产物补充硬约束：`client/android/LocojoyProject/assets/res/**` 只允许由 `client/resource/tools/LJFilePack_打包安卓.bat` 资源打包链和后续构建/同步流程刷新；业务资源源头固定为 `client/resource/res/**`，严禁直接手改 `assets/res`。

## 6. 编码与文件写回硬约束

总原则：修改已有文件时，必须保持原始编码、BOM、换行；禁止因"统一风格"进行批量转码。

### 6.0 VS2013/cl.exe 源码编码强制要求

VS2013 的 `cl.exe` 对含非 ASCII 字符（中文等）的 C/C++ 源文件有严格编码要求：

- **含非 ASCII 字符的 C/C++ 源文件必须保留 UTF-8 BOM（EF BB BF）**。
- `cl.exe` 在遇到无 BOM 的 UTF-8 文件时，会按系统默认编码（CP936/GBK）解析源码。
- 此时会将 UTF-8 多字节中文序列误解为 GBK 字节流，导致 **C2001 "常量中有换行符"** 等诡异的编译错误。
- 字节级检查（hex dump）可能显示字符串完全正常、无嵌入换行，但编译器看到的行与磁盘行不一致。
- **根因不是文件内容损坏，而是 BOM 丢失导致编译器选择了错误的解码器**。

此规则适用于所有通过 VS2013/v120 工具链编译的 C/C++ 源文件，包括但不限于 `tools/**` 下的工具工程。

修复方法：

```powershell
$enc = New-Object System.Text.UTF8Encoding($true)
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($path, $text, $enc)
```

### 6.1 第一方源码目标策略

| 范围 | 硬约束 |
|------|------|
| `client/FireClient/Application/**` | 以 `UTF-8 with BOM` 为主，但修改既有文件时必须保持原编码 |
| `engine/**` | 以 `UTF-8 with BOM` 为主，保持现有 BOM/换行 |
| `client/MT3Win32App/**` | 保持原编码优先；该目录存在历史 `CP936/ANSI`、`UTF-8 no BOM`、`UTF-16` 文件 |
| `cocos2d-x-3.0-oh/**`、`tools/CEGUI-0.7.9-r5/**` | 保持原编码；Win32 主线补丁必须重编全部受影响下游 |
| `cocos2d-x-2.2.6/**` | 保持原编码；允许补丁，但禁止顺手转码 |
| `cocos2d-2.0-rc2-x-2.0.1/**` | 历史回滚/差异基线（目录已不存在于工作区）；保持原编码；禁止顺手转码 |
| `dependencies/**` | 保持原编码；禁止做全仓统一编码改造 |
| `tools/**` (C/C++ 源码) | 以 `UTF-8 with BOM` 为主；含中文的源文件 **必须** 保留 BOM |

### 6.2 `.rc` 文件

- `.rc` 文件必须保持原编码。
- Win32 客户端/工具主线 `.rc` 优先接受 `UTF-16 LE with BOM`。
- 禁止把 `.rc` 一律改写成 `UTF-8 with BOM`。

### 6.3 文档与脚本

- `.md`、`.json`、`.xml`、`.ps1`、`.lua`、`.java` 默认使用 `UTF-8 无 BOM`。
- 新建文档按上述目标编码创建；修改已有文件时仍以“保持原编码”为先。

### 6.4 操作边界

- 禁止使用未显式指定编码的写入方式覆盖文本文件。
- 非 UTF-8 文件禁止直接套用 UTF-8 patch 流程。
- 在无法确认编码时，必须先探测，再按原编码写回。

## 7. 按目录例外矩阵

| 范围 | 是否允许修改 | 编码策略 | 最低重编要求 |
|------|------|------|------|
| `client/FireClient/Application/**` | 允许 | 保持原编码；新增/收敛优先 `UTF-8 BOM` | `FireClient` -> `MT3` |
| `client/MT3Win32App/**` | 允许 | 保持原编码优先 | `MT3` |
| `engine/**` | 允许 | 保持 `UTF-8 BOM` 现状 | `engine` -> 下游 |
| `cocos2d-x-3.0-oh/**`、`tools/CEGUI-0.7.9-r5/**` | 允许补丁，但高风险 | 保持原编码 | 对应库 -> `engine` -> `FireClient` -> `MT3` |
| `cocos2d-x-2.2.6/**` | 允许补丁，但高风险 | 保持原编码 | 对应库 -> 下游 |
| `cocos2d-2.0-rc2-x-2.0.1/**` | 目录已不存在于工作区 | 保持原编码 | 仅概念回滚/差异核对 |
| `dependencies/**` | 原则上不改 | 不套用全仓规则 | 仅专项任务 |
| `tools/**` | 允许 | 按各子工程现状 | 对应工具工程 |

## 8. 明确禁止事项

1. 禁止在 Windows 主线使用非 `v120` 工具集产出并替换主线二进制。
2. 禁止手工修改 `.lib`、`.dll`、`.exe` 等二进制产物。
3. 禁止直接修改生成代码作为长期维护方式。
4. 禁止手工修改 `client/android/LocojoyProject/assets/res/**`；必须回到 `client/resource/res/**` 修改并重跑 `client/resource/tools/LJFilePack_打包安卓.bat`。
5. 禁止对 `dependencies/**`、vendor 目录做批量格式化、批量转码或统一风格治理。
6. 禁止把示例工程、WinRT/WP8 工程、第三方工程的配置问题，误判为 Win32 主线规则冲突。
7. 禁止继续在规则文件中引用不存在的脚本、废弃命令或临时排障步骤。
8. 禁止把“只改 ABI 敏感头文件 + 局部 Build”当成可交付流程或可接受状态。
9. 禁止把“单一截图显示正常”当作“登录链路已修复”的交付依据。
10. 禁止在无日志证据情况下，把运行时闪退直接归因到 UI 缩放参数。

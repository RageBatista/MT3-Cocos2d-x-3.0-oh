# MT3 客户端代码审查与文档同步复核报告

> **复核日期**: 2026-04-26
>
> **复核范围**: `client/FireClient/Application/` 中原报告列出的安全修复点、`client/docs/` 文档同步点、`GameTable` 残留风险点、Debug 登录/注册配置链路、CEGUI 工具运行库漂移
>
> **复核方式**: 以当前工作区实际源码为准，使用 `rg`、`Format-Hex`、源码上下文抽样和文档检索交叉验证
>
> **重要说明**: 当前工作区存在大量未提交改动，本报告只复核与客户端审查报告直接相关的证据；未对全仓所有历史改动背书。

---

## 1. 执行摘要

| 类别 | 原报告结论 | 本次复核结论 | 处理状态 |
|------|------------|--------------|----------|
| `sprintf()` 风险 | 57 处已修复 | `client/FireClient/Application` 主业务范围未发现残留 `sprintf()` | 结论基本成立 |
| `strcpy()` 风险 | 7 处已修复 | 主业务范围未发现残留；但修复引入 6 个真实 NUL 字节 | 已修正 |
| `m_pNetConnection` 删除 | 无保护删除零残留 | 仍有 3 处直接 `delete`，但均在 `if (m_pNetConnection != NULL)` 分支内 | 原“零残留”表述需修正 |
| `delete this;` 模式 | 23 处不修复 | 源码确有大量效果回调自删除；属于架构风险记录项 | 保持记录 |
| 文档类名修正 | 已修复 | `GameUImanager` 类名正确，但部分文档把源码文件名也写成 `GameUImanager.*` | 已修正 |
| GameTable `malloc()` | 约 25 处风险 | 实测 25 个头文件存在 `malloc(stringLength+1)` 且未检查返回值 | 保持风险项 |
| `assert(0)` | 1 处风险 | `BattleManagerOperate.cpp:483` 仍存在 | 保持风险项 |
| Debug 登录/注册 | 无法完成登录/注册 | Debug 已确认读取 `client/resource/res/cfg/clientsetting_win.ini`；配置中的 SDK 登录/注册 HTTP 路由当前远端返回 404，且近期 HTTP 前置登录改动阻断了旧选服链路 | 已恢复 Win32 非 SDK 旧链路，并对 HTTP 404/405 增加兼容回退；服务端路由仍需部署 |
| 登录失败提示 | 弹窗提示内容乱码 | 本地 C++ 中文失败提示曾以窄字符串传入 Lua/CEGUI；已改为宽字符串经 `StringCover::to_string()` 输出 UTF-8 | 已修正并通过 Debug 构建 |
| CEGUI DLL drift | `CEGUIBase.dll` 多版本高风险漂移 | 现役 `client/resource/tools` 与 `tools/CELayoutEditor/bin/release` 已同步；跨工具家族版本差异改为受控漂移 | 高风险项已消除 |

---

## 2. 本次确认的问题与修复

### 2.1 修复后源码中存在真实 NUL 字节（HIGH → FIXED）

**证据**:

- `client/FireClient/Application/Manager/GameUIManager.cpp` 在剪贴板读取逻辑中出现 `url[length] = '0x00';` 的实际 NUL 字节。
- `client/FireClient/Application/Utils/Voice.cpp` 中 4 处 RIFF/WAVE/fmt/data 标签终止符也出现同类实际 NUL 字节。
- `client/FireClient/Application/Manager/SpaceManager.cpp` 中 1 处 `"WAVEfmt "` 标签终止符出现同类实际 NUL 字节。
- `rg` 对上述文件报告 `binary file matches` 或提前停止搜索，说明源码文本已被二进制字节污染。

**根因判断**:

原报告提到的 `strcpy` 修复方向正确，但写入 null 终止符时把源码文本 `'\0'` 写成了单个 `0x00` 字节。

**已修复**:

| 文件 | 修复数 | 修复内容 |
|------|--------|----------|
| `Manager/GameUIManager.cpp` | 1 | 实际 NUL 字节替换为源码文本 `'\0'` |
| `Utils/Voice.cpp` | 4 | 实际 NUL 字节替换为源码文本 `'\0'` |
| `Manager/SpaceManager.cpp` | 1 | 实际 NUL 字节替换为源码文本 `'\0'` |

### 2.2 文档中类名与文件名混淆（MEDIUM → FIXED）

**代码事实**:

- 源码文件名: `client/FireClient/Application/Manager/GameUIManager.cpp`
- 头文件名: `client/FireClient/Application/Manager/GameUIManager.h`
- C++ 类名: `GameUImanager`
- 全局访问函数: `gGetGameUIManager()`

**已修复文档**:

| 文档 | 修复内容 |
|------|----------|
| `01-README-项目概述.md` | 目录树从 `GameUImanager.*` 改为 `GameUIManager.*`，并注明类名为 `GameUImanager` |
| `02-ARCHITECTURE-架构设计.md` | UI 管理源码路径从 `GameUImanager.cpp` 改为 `GameUIManager.cpp` |

### 2.3 Debug 登录/注册失败链路复核（HIGH → CLIENT-SIDE VERIFIED）

**配置读取结论**:

- Debug 工作目录为 `client/resource/bin/Debug` 时，Win32 `NoPack` 分支会解析到 `../../res/cfg/clientsetting_win.ini`，即 `client/resource/res/cfg/clientsetting_win.ini`。
- `client/FireClient/Application/Framework/GameApplication.cpp` 中 `GetIniFileName()` 在 Win32 下使用 `cfg/clientsetting_win.ini`，`InitIni()` 随后读取 SDK 登录/注册地址。
- 最新启动日志显示 `loadFromPak=0` 且跳过 PAK 文件表初始化，符合 Debug 直接读取 `client/resource/res` 的运行方式。

**当前配置值**:

```ini
HttpServerListUrl=http://193.112.65.157:88/server/index.html
HttpSdkLoginUrl=http://193.112.65.157:88/api/sdk/user_login
HttpSdkRegisterUrl=http://193.112.65.157:88/api/sdk/user_register
```

**远端验证结果**:

- `GET http://193.112.65.157:88/server/index.html` 返回 `200`，服务器列表可达。
- `POST http://193.112.65.157:88/api/sdk/user_login` 返回 `404`。
- `POST http://193.112.65.157:88/api/sdk/user_register` 返回 `404`。
- 仓库内 `server/server/web_app/app/api/controller/Sdk.php` 确实定义了 `user_login()` 与 `user_register()`，且文档声明路径为 `/api/sdk/user_login`、`/api/sdk/user_register`；因此当前故障更像远端 `193.112.65.157:88` 未部署该 ThinkPHP API、Web 根目录未指向 web_app/public，或 rewrite/入口配置缺失。

**登录回归根因与本轮修复**:

- 近期新增的 `LoginManager::LoginAccount()` / `RegisterAccount()` 以及 tolua 导出，把 `switchaccountdialog.lua` 的登录/注册按钮接入 SDK HTTP 前置账号接口。
- 当前远端 `/api/sdk/user_login` 与 `/api/sdk/user_register` 返回 `404`，导致 Win32 非 SDK 登录被统一提示为“网络异常”；Android 同样无法进入旧的选服链路。
- `LoginManager` 已补回兼容路径：Win32 且 `bUseSDKInWindows=0` 时直接保存账号并进入选服；SDK HTTP 返回 `404/405` 时记录日志并回退到旧的本地账号选服流程；HTTP 返回 `200` 且 `code == 1` 的正常链路保持不变。

**客户端侧补充修复**:

`LoginManager::ShowLoginHttpMessage()` 通过点号调用 `CTipsManager.AddMessageTipByMsg`，而 Lua 侧原函数是冒号方法。现已在 `client/resource/res/script/logic/chat/tipsmanager.lua` 中兼容点号调用，避免登录/注册失败提示再次触发 `attempt to call method 'AddMessageTip' (a nil value)`。

**登录提示乱码修复**:

登录失败弹窗中文字乱码的首个根因不在字体和 Lua toast 控件，而在 C++ 本地失败提示的编码。`LoginManager.cpp` 中新增的 `"网络异常，请稍后重试"` 等中文窄字符串在 VS2013/v120 下无法保证以 Lua/CEGUI 期望的 UTF-8 进入脚本层。已在 `LoginManager.cpp` 中将本地中文提示改为 `L"..."` 宽字符串，并通过 `StringCover::to_string()` 转为 UTF-8 后再调用 `CTipsManager.AddMessageTipByMsg`。服务端 JSON 返回的 `msg` 保持原样透传，避免重复转码。

### 2.4 CEGUI 工具 DLL drift 高风险项复核（HIGH → CONTROLLED）

**原始风险**:

`CEGUIBase.dll` 曾在 runtime audit 中被标记为 High drift，原因是同名 DLL 同时出现在现役 CELayoutEditor、旧版 CELayoutEditor、CEImageset/TexturePacker 与 CEGUI-0.7.9-r5 等不同工具家族中，且 `client/resource/tools/CEGUIBase.dll` 与现役 `tools/CELayoutEditor/bin/release/CEGUIBase.dll` 不同源。

**根因判断**:

1. `Sync-CELayoutEditorRuntime.ps1` 对 `CEGUIBase.dll` 的候选优先级曾偏向旧 `tools/CEGUI-0.7.1/projects/premake/BaseSystem/Release.win32`，导致现役工具运行目录可能同步到错误 ABI 家族。
2. `Audit-RuntimeDependencies.ps1` 早先把现役 CELayoutEditor、旧版 CELayoutEditor、CEImageset/TexturePacker 与 CEGUI-0.7.9-r5 混在同一运行时家族中比较，误把“工具家族间预期差异”升级为 High。

**已处理**:

- `client/resource/tools/CEGUIBase.dll` 已与 `tools/CELayoutEditor/bin/release/CEGUIBase.dll` 对齐，二者大小均为 `3365888`，SHA256 前 12 位均为 `01CAF4B5B50B`。
- `Sync-CELayoutEditorRuntime.ps1` 已把现役 CELayoutEditor release 输出放到 `CEGUIBase.dll` 候选优先级首位。
- `Audit-RuntimeDependencies.ps1` 已按 `CELayoutEditor.Current`、`CELayoutEditor.Legacy`、`CEImageset`、`CEGUI-0.7.9-r5` 等家族区分漂移；同一现役运行时目录内仍强校验，不同工具家族间差异标记为 `Controlled`。

**当前审计结果**:

- `DriftHighCount=0`
- `MissingDepHighCount=0`
- `FamilyHighCount=0`
- `CEGUIBase.dll` 仍有多哈希记录，但严重级别为 `Controlled`，不再阻断客户端/工具运行库审计。

---

## 3. 原报告结论复核

### 3.1 缓冲区安全

**复核命令**:

```powershell
rg -n "\bsprintf\s*\(" client/FireClient/Application -g "*.cpp" -g "*.h" --glob "!oggenc/**" --glob "!Amr/**"
rg -n "\bstrcpy\s*\(" client/FireClient/Application -g "*.cpp" -g "*.h" --glob "!oggenc/**" --glob "!Amr/**"
```

**复核结果**:

- 主业务源码范围未发现残留 `sprintf()`。
- 主业务源码范围未发现残留 `strcpy()`。
- `client/FireClient/Application/oggenc/lyrics.cpp` 仍有 1 处 `strcpy(text, "")`，属于第三方/编码器目录，原报告已排除类似范围；不纳入本轮修复。

### 3.2 `m_pNetConnection` 删除逻辑

原报告称“delete m_pNetConnection 无保护零残留”，这个表述不准确。当前源码仍有 3 处直接 `delete m_pNetConnection`：

- `GameApplication.cpp:2898`
- `GameApplication.cpp:2930`
- `GameApplication.cpp:2955`

复核上下文显示三处均位于 `if (m_pNetConnection != NULL)` 分支内，行为上有保护；更准确的表述应为：

> 退出流程中的 2 处无保护删除已改为 `DestroyConnection()`；创建连接和销毁连接路径仍保留直接 `delete`，但有空指针判断。

### 3.3 `delete this;` 模式

源码中确实存在多处 `delete this;`，主要集中在 Nuclear `IEffectNotify`/效果结束回调对象中。该模式不是普通业务代码可复用范式，文档中保留“仅限引擎回调上下文”的风险说明是合理的。

### 3.4 静态变量线程安全

原报告列出的静态变量仍存在：

- `GameApplication.cpp`: `s_bIsOpenGLReady`、`s_bIsGameInBackground`
- `GameUIManager.cpp`: `hasPreloadLayout`
- `platform/win/WavRecorder.cpp`: `s_bRecording`

另有 `GameApplication.cpp` 中 `sbDoSDKOrShowQuickLoginAfterPlayingCG` 也属于静态状态变量。是否改为 `std::atomic<bool>` 需要结合 VS2013、Android NDK r10e 和调用线程事实验证，不能在文档中直接声明安全。

---

## 4. 残留风险清单

### 4.1 GameTable 生成头文件 `malloc()` 未检查返回值（MEDIUM）

`client/FireClient/Application/GameTable/**` 下 25 个头文件存在：

```cpp
char* buf=(char*)malloc(stringLength+1);
```

随后直接写入/读取 `buf`，在极端内存不足或异常表数据场景下会崩溃。由于这些文件属于表结构生成物，长期修复应优先回到生成模板或生成入口，避免逐个手工补丁。

### 4.2 `BattleManagerOperate.cpp` 使用 `assert(0)` 处理异常分支（LOW-MEDIUM）

`client/FireClient/Application/Battle/BattleManagerOperate.cpp:483` 仍有 `assert(0)`。Release 构建中断言可能被移除，建议后续改为日志 + 明确返回路径。

### 4.3 第三方/历史编码目录残留 C 字符串 API（LOW）

`oggenc/lyrics.cpp` 仍有 `strcpy(text, "")`。该目录更像第三方编码器源码，当前风险低；若后续做全客户端安全清理，应按 vendor/第三方策略单独评估，不建议混入 FireClient 主业务修复。

---

## 5. 文档同步结论

本次已确认并修正 `client/docs` 中最直接影响阅读准确性的两类问题：

1. `GameUImanager` 是类名，不是源码文件名。
2. `gGetGameUIManager()` 是实际全局访问函数，当前文档中未发现 `gGetUIManager()` 残留。

仍需注意：`client/docs` 目前是高层架构文档，并非逐函数 API 规格。若要求“100% 绝对对齐”到接口级别，应将 `LuaFireClientWin32.cpp`/`.pkg` 生成绑定、Manager 头文件和脚本调用点纳入自动抽取流程，否则人工文档会持续漂移。

---

## 6. 验证记录

| 检查项 | 结果 |
|--------|------|
| `GameUIManager.cpp` 嵌入 NUL 字节 | 已清除 |
| `Voice.cpp` 嵌入 NUL 字节 | 已清除 |
| `SpaceManager.cpp` 嵌入 NUL 字节 | 已清除 |
| 主业务范围 `sprintf()` 残留 | 未发现 |
| 主业务范围 `strcpy()` 残留 | 未发现 |
| `GameUImanager.cpp` 错误路径 | 已修正 |
| `gGetUIManager()` 文档残留 | 未发现 |
| Debug INI 解析路径 | 确认读取 `client/resource/res/cfg/clientsetting_win.ini` |
| SDK 登录/注册远端路由 | 当前 `user_login` / `user_register` 均返回 404；客户端已对 404/405 回退旧选服链路 |
| 登录失败提示乱码 | 本地中文提示改为宽字符串转 UTF-8 后传入 Lua |
| CEGUIBase 现役运行库一致性 | `client/resource/tools` 与 `tools/CELayoutEditor/bin/release` 哈希一致 |
| Runtime audit 高风险漂移 | `DriftHighCount=0`、`FamilyHighCount=0` |
| 源码 NUL 字节扫描 | `client/resource/res/script/logic/chat` 与 `tools/scripts` 范围通过 |
| Win32 编译验证 | `Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8` 通过，产物 `client/resource/bin/Debug/MT3.exe` |
| Android 编译验证 | `Build-Android-Locojoy-WithGate.ps1 -ProjectDir client/android/LocojoyProject -Channel free -Jobs 4 -CleanIntermediates` 通过，产物 `client/android/LocojoyProject/build/bin/mt3-release.apk` |
| Android APK 结构门禁 | `Assert-ApkInstallableStructure.ps1` 通过，EntryCount `63248`，ZIP64 `False` |
| Android 启动烟测 | `adb install -r` 成功；启动 `com.locojoy.mini.mt3.locojoy/com.locojoy.mini.mt3.GameApp` 后未发现 `FATAL EXCEPTION` / `SIGSEGV` / `UnsatisfiedLinkError` |

---

## 7. 建议后续动作

1. 对 `GameTable` 生成模板补充 `malloc` 失败处理，再重新生成相关头文件。
2. 将 `BattleManagerOperate.cpp:483` 的 `assert(0)` 改为可在 Release 生效的错误处理。
3. 用脚本从 `GameUIManager.h`、`ConfigManager.h` 和 tolua 绑定输出自动生成 API 摘要，减少 `client/docs/05-API-接口文档.md` 后续漂移。
4. 在构建前增加源码 NUL 字节扫描，避免 `'\0'` 再次被错误写成真实二进制字节。

---

**复核完成**: 2026-04-26 | **复核人**: Codex

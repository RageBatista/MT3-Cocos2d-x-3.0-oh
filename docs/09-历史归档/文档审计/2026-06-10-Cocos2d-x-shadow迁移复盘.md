# Cocos2d-x 2.2.6 shadow 迁移对话复盘与执行偏差分析

> 日期：2026-06-10
> 来源：围绕 `cocos2d-2.0-rc2-x-2.0.1` 升级评估、2.2.6 shadow 迁移、CEGUI 0.7.1 重建、CRT/编码治理、vendor 入库策略的一组任务对话。
> 定位：本文件合并保存 2026-06-10 升级前进度核实与 shadow 迁移复盘，不替代 `.claude/RULES.md`、`.claude/BUILD_GUIDE.md` 或最近目录 `AGENTS.md`。
> 时间边界：当日核实时主线仍为 2.0.1、2.2.6 接入进度为 0%；6 月 20 日正式迁移验收和 7 月 3 日依赖引用审计属于后续独立里程碑。

## 1. 复盘结论

本轮对话暴露的核心问题不是单点构建失败，而是**混合技术栈仓库在长链迁移中容易把工作树、工具链、vendor、索引、编码和文档口径混在一起**。后续必须把“工程证据优先”和“索引/编码门禁”前置到执行流程中。

关键结论：

1. `E:\MT3` 主线与 `E:\MT3-c226-shadow` shadow worktree 必须显式区分；任何迁移结论都要绑定具体 root、branch 和 status。
2. CEGUI 0.7.1 既是运行/渲染链依赖，又是工具目录下的 vendor 快照；不能用“`tools/` 默认忽略”或“全部放开”两种粗粒度策略处理。
3. `git check-ignore -v` 会打印否定规则命中，不能单独作为 ignored 判定；应以 `git ls-files --others --exclude-standard` 与 `git ls-files --others -i --exclude-standard` 闭环。
4. 非 cone sparse-checkout 会让磁盘存在的路径无法更新索引；`git add -n` 出现 outside sparse warning 时，根因在 sparse 定义而不是 `.gitignore`。
5. 在 `core.autocrlf=true` 的 Windows 环境，真实 `git add` 才会暴露 LF/CRLF 风险；vendor 快照和文档应先写 `.gitattributes` 再入索引。
6. 索引状态验证不能并行执行；`git add`、`git reset`、`git diff --cached` 必须顺序运行。
7. VS2013/v120、NDK r10e、Ant、生成代码边界、ABI 敏感头文件和历史编码都不是“旧项目噪声”，而是交付正确性的硬约束。

## 2. 对话中暴露的潜在陷阱

### 2.1 工作树身份陷阱

同一任务链中同时出现主仓库 `E:\MT3` 与 shadow worktree `E:\MT3-c226-shadow`。如果不先输出：

```powershell
git rev-parse --show-toplevel
git branch --show-current
git status --short --branch
```

就容易把 shadow 分支的 `.gitignore`、staged 文件、构建产物和主线文档状态混为一谈。

### 2.2 `tools/CEGUI-0.7.1` 语义陷阱

该目录同时包含：

- 可入库的 CEGUI 源码、工程文件、脚本和部分重建依赖；
- 应继续忽略的 `shadow-build/`；
- 历史构建输出 `lib/`；
- `obj/Debug/Release/PDB/IDB/ILK/TLOG` 等中间产物；
- macOS AppleDouble `._*` 元数据；
- `.dll/.lib/.exp/.exe` 等普通 Git blob 形式的预编译依赖。

因此它既不能继续被 `/tools/` 一刀切忽略，也不能直接 `git add tools/CEGUI-0.7.1` 后不审计。

### 2.3 ignore 判定陷阱

`git check-ignore -v` 对否定规则也会输出匹配行。正确判定方式是：

```powershell
git ls-files --others --exclude-standard -- tools/CEGUI-0.7.1
git ls-files --others -i --exclude-standard -- tools/CEGUI-0.7.1
```

再用样本路径确认 `CEGUI.h`、`.vcxproj`、`dependencies/lib/*.lib`、`shadow-build/*.dll`、`lib/*.lib`、`._*` 的版本管理状态。

### 2.4 sparse-checkout 陷阱

shadow worktree 使用非 cone sparse-checkout 时，路径在磁盘上存在并不代表能更新索引。`git add -n` 出现：

```text
outside of your sparse-checkout definition
```

时，应先审计：

```powershell
git sparse-checkout list
git config --get core.sparseCheckout
git config --get core.sparseCheckoutCone
```

再决定是否追加 `tools/CEGUI-0.7.1/**`。

### 2.5 行尾与属性陷阱

真实 `git add` 前需要先确认 `.gitattributes`。否则在 `core.autocrlf=true` 下，CEGUI 源码、`.codex` 和 `docs` 可能出现 Git 自动提示：

```text
LF will be replaced by CRLF the next time Git touches it
```

对 vendor snapshot，正确策略是保留原始字节；对 `.codex/**` 与 `docs/**/*.md`，当前项目策略是 UTF-8 no BOM + LF。

### 2.6 并行工具竞态陷阱

索引相关命令有共享状态：

- `git reset`
- `git add`
- `git diff --cached`
- `git status`

这些命令不能为了“快”而并行执行，否则可能读到重加索引之前的旧状态，造成误判。

### 2.7 PowerShell 语法陷阱

本轮出现过 PowerShell 解析失败：

- `foreach { ... } | Format-Table` 写法位置不当导致空管道元素；
- 多行字符串中反引号、中文和路径混排导致解析错误；
- Windows 环境变量语法若混用 `%VAR%` 与 PowerShell `$env:VAR`，容易创建错误路径或误执行。

治理原则：复杂文本写回用 `.NET WriteAllText` 或小段 Python/PowerShell 明确编码；索引/日志分析尽量用一次性命令，不为了单次分析创建脚本。

## 3. 认知盲区

| 盲区 | 表现 | 纠偏方式 |
| --- | --- | --- |
| 把“最小修改”误解为“只改一行 ignore” | 只改 `.gitignore` 不能解决 sparse、行尾、OS 元数据和 staging 边界 | 最小可交付应覆盖 ignore + attributes + dry-run + 文档 |
| 把 vendor 当普通源码 | 忽略二进制依赖大小、LFS 状态、行尾归一化 | 先定义 vendor snapshot 边界和恢复策略 |
| 把 sidecar 当运行面 | 误以为 `.codex/requirements.toml` 在项目中天然强制生效 | 官方运行入口以 `.codex/config.toml` 为准，sidecar 只做治理/导出 |
| 把构建成功当主工程可接入 | shadow gate 通过不代表 Release 或主工程接入安全 | 接入前仍需 CRT、编码、ABI、产物链门禁 |
| 把工具输出当结论 | `check-ignore -v`、旧日志、并行 diff 输出都可能误导 | 用交叉证据和顺序验证闭环 |

## 4. 执行偏差清单

1. 曾先查看了主仓库状态，再切到 shadow worktree，说明工作树身份需要被固定为强制首检。
2. 曾先 dry-run 成功但真实 `git add` 后才暴露 CRLF 警告，说明 `.gitattributes` 必须前置。
3. 曾把索引写入与验证并行执行，导致 `diff --cached --check` 一度读到旧 staged 文档。
4. 曾在 PowerShell 中出现多行字符串和管道解析错误，说明复杂写回应减少 shell 拼接。
5. CEGUI 快照最初包含 47 个 AppleDouble `._*` 候选，说明 vendor 快照必须有 OS 元数据扫描。

## 5. 已沉淀到配置的治理动作

本复盘已推动以下项目层治理：

- `.codex/config.toml`：注册 repo-local MT3 子代理，并明确项目默认 MCP 只启用 `openaiDeveloperDocs`。
- `.codex/requirements.toml`：增加 broad staging、CEGUI vendor、sparse-checkout、git clean 的 prompt 规则侧车。
- `.codex/rules/mt3-guardrails.rules`：同步项目级命令规则，提示高风险 git 操作。
- `.codex/project-map.json`：记录迁移复盘风险登记。
- `.codex/workflows/workflow-engine.json`：新增 `cocos-cegui-shadow-migration` 工作流。
- `.gitattributes`：补充 `.codex/**`、`docs/**/*.md` 与 `tools/CEGUI-0.7.1/**` 的行尾/二进制策略。

## 6. 后续要求

后续所有 Cocos/CEGUI shadow 迁移、主工程接入、vendor 入库任务，交付说明至少包含：

1. 当前 root / branch / status；
2. 任务域分类和命中的技能/规则；
3. `.gitignore`、`.gitattributes`、sparse-checkout 影响；
4. dry-run 结果与 bad path 筛查；
5. 编码/BOM/换行验证；
6. 构建或文档门禁结果；
7. 未处理风险和回滚方式。

---

## 附录 A：2026-06-10 升级前进度核实（合并原文）

> **原始路径**: `docs/00-文档审计/26-Cocos2d-x-2.2.6升级进度核实报告-2026-06-10.md`
> **原始 SHA256**: `0DE437FFEBA56FE94F7826C756C09F9B2B87D31C05D8B7598B684DB40D9F47AF`
> **日期边界**: 该快照明确记录“目标已确认、主线接入 0%”的 2026-06-10 当日事实，不能用后续完成状态反向覆盖。下文按原文完整并入，仅更新 2026-07-03 审计的归档路径、下调标题层级并清理行尾空格。

### Cocos2d-x v2.2.6 升级进度核实报告

> 核实日期：2026-06-10
> 目标版本：`Cocos2d-x v2.2.6`
> 2026-06-10 当日主线：`cocos2d-2.0-rc2-x-2.0.1`
> 2026-07-03 当前主线：`cocos2d-x-2.2.6`
> 报告定位：记录目标版本确认后的工程事实、主线接入进度和下一阶段门禁；本报告不表示升级已经落地。
> 时效说明：本文为升级前历史核实报告；当前事实以 `docs/09-历史归档/文档审计/2026-07-03-Cocos2d-x构建依赖审计.md`、源码目录和构建脚本为准。

#### 1. 结论

目标版本已经明确为 **Cocos2d-x v2.2.6**。

截至 2026-06-10 本次核实，当日 MT3 主线使用 `cocos2d-2.0-rc2-x-2.0.1`，未发现 `cocos2d-x-2.2.6` 或 `cocos2d-x-2.2.6-mt3` 的源码目录、构建入口、工程引用或可构建产物接入。

因此 2026-06-10 当日状态应表述为：

> **Cocos2d-x v2.2.6 升级仍处于目标确认、可行性评估与 shadow 迁移准备阶段；主线实现进度为 0%。**

#### 2. 本次核实范围

本次只核实 Cocos2d-x v2.2.6 升级目标与主线接入进度，不对 Android、Win32、iOS 全量构建执行重编，也不修改任何引擎源码。

核实范围覆盖：

- 根目录引擎源码目录。
- Win32 主构建脚本、解决方案和 `.vcxproj`。
- Android `Android.mk` 引用。
- `engine/`、`common/`、`tools/CEGUI-0.7.1*` 中的 Cocos 路径引用。
- 根规则、`.claude/RULES.md`、`docs/README.md` 和既有 2.2.6 评估文档。

#### 3. 工程证据

##### 3.1 引擎目录

2026-06-10 核实时仓库根目录存在：

```text
cocos2d-2.0-rc2-x-2.0.1/
```

2026-06-10 核实时仓库根目录不存在：

```text
cocos2d-x-2.2.6-mt3/
cocos2d-x-2.2.6/
```

##### 3.2 当前引擎版本源码证据

2026-06-10 当日 Cocos 目录仍返回 2.0 线版本：

| 文件 | 证据 |
| --- | --- |
| `cocos2d-2.0-rc2-x-2.0.1/cocos2dx/cocos2d.cpp:33` | `cocos2dVersion()` 返回 `cocos2d-2.0-rc2-x-2.0.1` |
| `cocos2d-2.0-rc2-x-2.0.1/cocos2dx/include/cocos2d.h:32` | `COCOS2D_VERSION` 为 `0x00020000` |

既有可行性评估文档记录官方 2.2.6 目标基线：

| 文件 | 证据 |
| --- | --- |
| `cocos2d-2.0-rc2-x-2.0.1/docs/13_Cocos2d-x-2.2.6升级可行性评估报告__Upgrade-Feasibility-Report.md:20` | 官方 2.2.6 tag 为 `1fc007df0ed6f01ef458083504260d0752d19049`，`COCOS2D_VERSION` 为 `0x00020206` |

##### 3.3 构建入口引用

本次检索到仍引用 `cocos2d-2.0-rc2-x-2.0.1` 的构建/工程文件共 54 个，覆盖主线关键入口。未检索到构建/工程文件引用 `cocos2d-x-2.2.6` 或 `cocos2d-x-2.2.6-mt3`。

关键旧路径引用包括：

| 范围 | 代表文件 | 当前状态 |
| --- | --- | --- |
| Win32 统一构建 | `client/Build-MT3-v120.ps1:342-345`、`:856-859` | 仍读取 2.0.1 下的 `libBox2D`、`liblua`、`libcocos2d`、`libCocosDenshion` 工程与产物 |
| Win32 解决方案 | `client/FireClient/FireClient.sln:8-14`、`:115` | 仍把 `liblua`、`libBox2D`、`libchipmunk`、`libcocos2d`、`libSpine` 指向 2.0.1 |
| FireClient Win32 工程 | `client/MT3Win32App/FireClient.win32.vcxproj:117-121`、`:258-261` | 仍直接编译/包含 2.0.1 `extensions/network` |
| Android 主业务库 | `client/FireClient/Android.mk:123-183`、`:293-308` | 仍直接编译/包含 2.0.1 `extensions/network`、`lua`、`tolua`、`cocos2dx_support`、`libSpine` |
| Android 渠道工程 | `client/android/*/jni/Android.mk` | `import-add-path` 仍指向 2.0.1 |
| 引擎和公共库 | `engine/engine.win32.vcxproj`、`common/platform/*.vcxproj`、`common/lua/*.vcxproj` | include、source、lib 路径仍是 2.0.1 |
| CEGUI/工具链 | `tools/CEGUI-0.7.1*/projects/**/*.vcxproj` | CEGUI 工程仍按 2.0.1 的 win32 pthread / Cocos 依赖配置 |

##### 3.4 规则约束

`.claude/RULES.md:44` 明确禁止主线直接升级 `Cocos2d-x` 大版本，要求单独立项评估 ABI、API、资源与构建链影响。

因此 v2.2.6 不能通过直接覆盖 `cocos2d-2.0-rc2-x-2.0.1/` 或替换预编译二进制的方式进入主线。

#### 4. 进度判定

| 工作项 | 判定 | 进度 |
| --- | --- | ---: |
| 目标版本确认 | 已确认目标为 `Cocos2d-x v2.2.6` | 100% |
| 可行性评估 | 已有评估报告，结论为“有条件可行、高风险、需独立立项和分阶段影子迁移” | 部分完成 |
| shadow 迁移经验沉淀 | 已有避坑指南和复盘材料，但不等于主线接入 | 部分完成 |
| 2.2.6 并行源码目录 | 未发现 `cocos2d-x-2.2.6-mt3/` 或 `cocos2d-x-2.2.6/` | 0% |
| Win32 v120 工程迁移 | 未发现 `.sln/.vcxproj` 切换到 2.2.6 | 0% |
| Android NDK r10e 工程迁移 | 未发现 `Android.mk` 切换到 2.2.6 | 0% |
| iOS 工程迁移 | 本次未发现主线已接入 2.2.6 的证据 | 0% |
| `engine/` 适配 | 未发现面向 2.2.6 的主线适配代码 | 0% |
| `FireClient/` 适配 | 未发现面向 2.2.6 的主线适配代码 | 0% |
| CEGUI Cocos2DRenderer 适配 | 未发现面向 2.2.6 的主线适配代码 | 0% |
| ABI/CRT 混编门禁 | 未建立 2.2.6 专项门禁 | 0% |
| 三端运行验证 | 未建立 2.2.6 专项验收矩阵 | 0% |

工程实现口径下的当前进度：

```text
主线升级实现进度：0%
准备/评估阶段：已启动，但尚未进入可交付实现阶段
```

#### 5. 不得误判为“已升级”的材料

以下材料只能作为评估、复盘或 shadow 迁移参考，不代表主线已经切换到 v2.2.6：

- `cocos2d-2.0-rc2-x-2.0.1/docs/13_Cocos2d-x-2.2.6升级可行性评估报告__Upgrade-Feasibility-Report.md`
- `docs/03-开发指南/Cocos2d-x-2.2.6-shadow迁移避坑指南-2026-06-10.md`
- `docs/00-文档审计/24-Cocos2d-x-2.2.6-shadow迁移对话复盘与执行偏差分析-2026-06-10.md`

是否完成主线升级，只能以以下证据共同成立为准：

1. 并行 2.2.6 源码目录存在，且不覆盖 2.0.1 目录。
2. Win32、Android、iOS 构建入口明确选择 2.2.6 或带可回滚开关的 2.2.6 变体。
3. 2.2.6 下 `libcocos2d`、`libCocosDenshion`、`engine`、`FireClient`、最终客户端产物均由主线工具链重建。
4. CEGUI、Nuclear、PFS、Lua/tolua、纹理恢复、音频、平台生命周期和输入链通过专项验收。
5. `.claude/RULES.md`、构建指南、docs 当前基线文档同步更新。

#### 6. 建议的正式实施阶段

##### Phase 0：立项与基线冻结

- 明确升级目标：`Cocos2d-x v2.2.6`。
- 冻结当前 2.0.1 可构建基线。
- 明确回滚策略：不得覆盖 `cocos2d-2.0-rc2-x-2.0.1/`。
- 建立专项分支或 worktree。

##### Phase 1：并行源码导入

- 新增 `cocos2d-x-2.2.6-mt3/`。
- 记录官方 tag、MT3 补丁清单、第三方库版本和许可来源。
- 禁止引入官方预编译库作为主线交付依赖。

##### Phase 2：Win32 v120 最小构建

- 固定 `VS2013/v120 + Windows SDK 8.1`。
- 先完成 2.2.6 `libcocos2d`、`libCocosDenshion` 构建。
- 建立与 2.0.1 并存的构建开关。
- 禁止混用 2.0.1 与 2.2.6 的 `.obj/.lib`。

##### Phase 3：Android NDK r10e 最小构建

- 保持 `NDK r10e + Ant + JDK 1.7/1.8`。
- 适配 2.2.6 的目录组织，尤其是 Lua、tolua、scripting 路径差异。
- 合并 Android FPS、生命周期、音频修复时保留 MT3 定制 JNI 和渠道流程。

##### Phase 4：MT3 兼容层

至少恢复或封装以下 MT3 依赖能力：

- `CCDirector` 后台、暂停、swap buffer 相关定制。
- `CCEGLViewProtocol` 长按、点击、双击、滑动、拖拽扩展。
- Android `swapBuffersForAndroid()` 等帧提交行为。
- `CCTextureCache::reloadAllTextures(CCFileProvidor*)` 一类资源恢复接口。
- `CCTexture2D::getAlphaName()` 相关 ETC alpha 分离纹理逻辑。
- shader、PFS、CEGUI Cocos2DRenderer、Nuclear 渲染扩展。

##### Phase 5：FireClient / engine / CEGUI 接入

- `engine` 先编译通过，再接 `FireClient`。
- CEGUI Cocos2DRenderer 必须覆盖登录首屏、普通窗口、RT UI、粒子、灰度、ETC alpha、地图滚动、多分辨率。
- Lua/tolua 与资源加载路径必须做回归验证。

##### Phase 6：三端门禁与灰度

- Win32：Debug / Release 构建与冷启动验证。
- Android：至少覆盖 armeabi-v7a、arm64-v8a 相关链路和渠道工程差异。
- iOS：重点验证 64-bit、ObjC++ 生命周期、SDK 回调和手势桥接。
- 建立性能和稳定性基准：FPS、P95 帧耗时、DrawCall、纹理内存、后台恢复、崩溃率。

#### 7. 当前下一步

建议下一步不要直接改主线构建文件，而是先完成以下最小闭环：

1. 创建独立分支或 worktree。
2. 引入 `cocos2d-x-2.2.6-mt3/` 并记录来源。
3. 仅构建 2.2.6 的 `libcocos2d` 与 `libCocosDenshion`，不接入 FireClient。
4. 产出 Win32 v120 最小构建日志。
5. 对比 2.0.1 与 2.2.6 对外头文件、库产物、CRT、导出符号和目录组织。
6. 通过后再进入 MT3 兼容层和上层工程接入。

在上述最小闭环完成前，任何“主线已升级到 Cocos2d-x v2.2.6”的表述都应视为不准确。

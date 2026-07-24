# client/resource/res CEGUI 与 Lua 技能集成分析

## 1. 目的与结论

本文只基于仓库现状取证，目标是回答三个问题：

1. `client/resource/res` 当前资源树如何组织。
2. CEGUI `.layout`、`scheme`、`looknfeel`、`imageset`、`font` 与 Lua 脚本如何串起来。
3. 新增项目级 CEGUI 技能与 Lua 技能时，应该教会 Codex 哪些真实约定，避免只学到表面文件名。

结论先行：

- `client/resource/res` 是典型的“资源树 + 约定驱动”系统，不存在单一注册表把 `.layout` 与 `.lua` 显式成对声明。
- CEGUI 资源链由 C++ 的 `GameUIManager` 初始化，主路径是 `scheme -> imageset/font/looknfeel -> layout`。
- Lua UI 主路径由 `Dialog` 基类和 `LuaUIManager` 驱动，核心约定是 `GetLayoutFileName() -> loadWindowLayout() -> getWindow() -> subscribeEvent()`。
- 857 个 `.layout` 里，只有一部分和 Lua 对话框形成直接 1:1 配对；其余大量布局是 cell、模板、嵌入式子布局、C++ 对话框或历史残留。
- 仓库中存在 `LuaEventOnClicked` 这类布局属性，但当前主链仍大量手工 `subscribeEvent`；新增技能不应把它当成主要绑定机制。
- 新技能如果只教“新建一个 `.layout` + 新建一个同名 `.lua`”会误导。真正需要的是“先判模式，再选链路”的技能。

## 2. 取证范围

本次只读审计的主要锚点如下：

- `client/resource/res/**`
- `client/FireClient/Application/Framework/GameApplication.cpp`
- `client/FireClient/Application/Manager/GameUIManager.cpp`
- `client/resource/res/script/dofile_main.lua`
- `client/resource/res/script/main.lua`
- `client/resource/res/script/logic/dialog.lua`
- `client/resource/res/script/logic/luauimanager.lua`
- `client/resource/res/script/logic/logo/logoinfodlg.lua`
- `client/resource/res/script/logic/shop/stalldlg.lua`
- `client/resource/res/ui/layouts/logoinfo.layout`
- `client/resource/res/ui/layouts/baitan.layout`
- `client/resource/res/ui/schemes/taharezlook.scheme`
- `client/resource/res/ui/schemes/taharezlook2.scheme`
- `client/resource/res/ui/looknfeel/TaharezLook.looknfeel`
- `tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp`
- `tools/CEGUI-0.7.1/cegui/src/CEGUIGUILayout_xmlHandler.cpp`
- `tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp`
- `tools/CEGUI-0.7.1/cegui/src/CEGUIWindowProperties.cpp`

取证方式只用了 `rg`、`Get-ChildItem`、`Get-Content`、PowerShell/Python 一次性统计脚本，没有创建临时仓库文件。

## 3. 资源目录结构

### 3.1 `res` 一级目录

`client/resource/res` 当前有 11 个一级目录：

- `cfg`
- `docs`
- `effect`
- `image`
- `map`
- `model`
- `replay`
- `script`
- `sound`
- `table`
- `ui`

全树统计：

- 文件 63,899 个
- 目录 3,602 个

按一级目录文件量看，主量级如下：

| 目录 | 文件数 |
| --- | ---: |
| `model` | 44,447 |
| `map` | 6,540 |
| `effect` | 6,190 |
| `script` | 2,556 |
| `ui` | 2,167 |

### 3.2 主要文件类型

高频扩展名统计如下：

| 扩展名 | 数量 |
| --- | ---: |
| `.png` | 32,726 |
| `.ani` | 8,169 |
| 无扩展名 | 5,167 |
| `.act` | 4,559 |
| `.lua` | 2,526 |
| `.pngpart` | 2,084 |
| `.lmx` | 1,771 |
| `.inf` | 1,327 |
| `.layout` | 857 |
| `.dat` | 816 |
| `.csv` | 696 |
| `.imageset` | 613 |
| `.ogg` | 608 |

这组数字说明：

- `res` 不是 UI 专用资源树，UI 只是其中一层。
- 想新增 UI 技能，不能只看 `ui/`；还必须知道 `script/` 的组织方式和 C++ 加载入口。

## 4. UI 子树事实

### 4.1 `ui` 目录组成

`client/resource/res/ui` 当前主要子目录如下：

| 子目录 | 文件数 |
| --- | ---: |
| `layouts` | 857 |
| `imagesets` | 1,223 |
| `fonts` | 93 |
| `schemes` | 2 |
| `looknfeel` | 2 |
| `animations` | 1 |
| `xml_schemas` | 6 |
| `zhandou` | 17 |

另有一个不在 `ui/layouts` 下的布局文件：

- `client/resource/res/ui/jingmaiui.layout`

### 4.2 `.layout` 命名特征

857 个 `.layout` 文件里：

> 注：下列分类数量基于较早一次 822 文件快照分析，仅作形态参考；如需精确分布应按当前 857 文件重新统计。

- `*cell` 相关命名很多，纯 `cell` 后缀 125 个，名字中包含 `cell` 的还有 80 个。
- `dialog` 后缀 38 个，`dlg` 后缀 25 个。
- 其余 532 个是业务名、分页名、专题名或历史兼容名。

这说明布局存在至少三种形态：

1. 独立对话框。
2. 可复用 cell / 条目模板。
3. 纯业务容器或嵌入式分页。

## 5. CEGUI 资源链

### 5.1 资源组初始化

`client/FireClient/Application/Manager/GameUIManager.cpp` 中，`initialiseDefaultResourceGroups()` 和 `initialiseResourceGroupDirectories()` 把 CEGUI 资源组固定到这些目录：

- `schemes -> ui/schemes`
- `imagesets -> ui/imagesets`
- `fonts -> ui/fonts`
- `layouts -> ui/layouts`
- `looknfeel -> ui/looknfeel`
- `animations -> ui/animations`

随后 `InitGameUI()` 会调用：

- `CEGUI::SchemeManager::getSingleton().create("taharezlook.scheme")`
- `CEGUI::SchemeManager::getSingleton().append("taharezlook2.scheme")`

这意味着运行时默认加载的不是单个 `.layout`，而是先装入一整套 scheme 资源定义。

### 5.2 `scheme -> looknfeel/imageset/font`

以 `taharezlook.scheme` 为例：

- 顶部连续加载大量 `.imageset`
- 中段加载大量 `.font`
- 随后加载 `TaharezLook.looknfeel`
- 再通过 `FalagardMapping` 把 `TaharezLook/*` 类型映射到渲染器和 looknfeel

`taharezlook2.scheme` 则继续追加专题图集和数字字体，如：

- `skillui.imageset`
- `teamui.imageset`
- `mainui2.imageset`
- `itemicon*.imageset`
- `num-count*.font`

所以新增布局时，优先动作应当是“确认现有 scheme 是否已提供所需 imageset/font/type”，而不是先新建 XML。

### 5.3 `looknfeel` 与 `imageset` 的职责

`client/resource/res/ui/looknfeel/TaharezLook.looknfeel` 负责定义窗口外观和状态图：

- `PropertyDefinition`
- `ImagerySection`
- `StateImagery`
- `ImageProperty`

`client/resource/res/ui/imagesets/*.imageset` 负责把大图切成命名 image，例如：

- `ccui1.imageset` 定义 `newxxz`、`newxxy`、`gj` 等 image 名

`client/resource/res/ui/fonts/*.font` 负责两类字体：

- FreeType 字体，如 `simhei-12.font -> DFYuanW7-GB2312.ttf`
- Pixmap 字体，如 `num-count.font -> allnumber.imageset`

### 5.4 `.layout` 如何引用资源

`.layout` 不直接写 `.png`、`.ttf` 或 `.imageset` 文件名，主写法是：

- `Property Name="Image" Value="set:xxx image:yyy"`
- `Property Name="Font" Value="simhei-12"`
- `Window Type="TaharezLook/StaticImage"` 之类的窗口类型

从布局统计结果看：

- 857 个布局引用了 179 个不同的 `imageset`
- 引用了 55 个不同字体名
- 19,305 个窗口节点里，18,586 个使用 `TaharezLook/*` 前缀，约占 96.28%

这说明新技能的核心不是“教会怎么写 XML 标签”，而是“教会如何落在现有 TaharezLook 体系里”。

## 6. Lua 加载与生命周期

### 6.1 启动入口

`client/FireClient/Application/Framework/GameApplication.cpp` 中，Lua 主链至少有两个关键脚本入口：

- `executeScriptFile(L"dofile_main.lua")`
- `executeScriptFile(L"main.lua")`

`client/resource/res/script/dofile_main.lua` 负责预加载：

- 协议定义
- manager
- 常用 UI 对话框
- `logic.luauimanager`
- `mainticker`
- `globalfunctionsforcpp`

`client/resource/res/script/main.lua` 则处理登录入口逻辑，例如：

- `logic.switchaccountdialog`
- `logic.selectserverentry`
- `config`

### 6.2 `Dialog` 基类

`client/resource/res/script/logic/dialog.lua` 是 Lua UI 的主基类，主链非常固定：

1. `GetLayoutFileName()` 返回布局文件名。
2. `Dialog.OnCreate()` 调用 `winMgr:loadWindowLayout(fileName, nameprefix)`。
3. 通过 `winMgr:getWindow("Root/Child/...")` 拿控件。
4. 通过 `subscribeEvent()` 手工绑定事件。
5. `OnClose()` 里 `RemoveAllScriptFunctors()`、`LuaUIManager:RemoveUIDialog()`、`destroyWindow()`。

这条链比任何文档命名约定都更接近真实标准。

### 6.3 `LuaUIManager`

`client/resource/res/script/logic/luauimanager.lua` 负责：

- 记录 `window -> dialog` 映射
- 在 `DestructStart` 时兜底清理
- `GUISheetChanged` 时处理 modal 恢复
- `Exit()` 时清理大量 Lua manager / dialog 状态

对应的 C++ 侧 `GameUIManager.cpp` 会在退出流程中执行：

- `executeGlobalFunction("LuaUIManager.Exit")`

因此 Lua 技能必须教会 Codex：

- 不只写 `OnCreate`
- 还要同步设计 `DestroyDialog`、事件解绑、数据清理和退出路径

## 7. `.layout` 与 `.lua` 的真实关联方式

### 7.1 直接 1:1 配对

通过扫描 `GetLayoutFileName()` 返回值：

- `ui/layouts` 下有 857 个布局
- Lua 中有 360 个布局名被 `GetLayoutFileName()` 显式返回
- 其中 347 个布局能和 Lua 类形成直接同名配对

代表例子：

- `logoinfo.layout <-> logic/logo/logoinfodlg.lua`
- `baitan.layout <-> logic/shop/stalldlg.lua`

这条链通常长这样：

1. Lua 类定义 `GetLayoutFileName()`
2. `Dialog.OnCreate()` 统一加载布局
3. Lua 根据固定窗口路径取控件
4. Lua 手工订阅事件

### 7.2 动态子布局 / cell 模式

另有至少 53 个布局名是被脚本直接 `loadWindowLayout("xxx.layout", prefix)` 动态加载的，常见于：

- `petcell1`
- `petskillbookcell_mtg`
- `baitancell1..4`
- `lifeskillcell`
- `tasktrackcell`

这类布局往往不是独立对话框，而是：

- cell
- 子页
- 预制模板
- 列表项

新增技能时，必须先判断任务属于“完整 dialog”还是“动态 cell/模板”。两者的命名和生命周期约束不同。

### 7.3 C++ 对话框模式

仓库里也有纯 C++ `Dialog` 路径，例如：

- `client/FireClient/Application/GameUI/Dialog.cpp`
- `client/FireClient/Application/androidcommon/AndroidLoginDialog.cpp`
- `client/FireClient/Application/Manager/MessageManager.cpp`

这说明不能把所有布局都默认归到 Lua。

### 7.4 `LuaEventOnClicked` 的事实地位

布局扫描结果：

- 84 个布局文件出现 `LuaEventOnClicked`
- 共计 258 个 `LuaEventOnClicked` 属性

例如：

- `baitan.layout`
- `baitan1.layout`

但全仓搜索 `LuaEventOnClicked` 的运行时消费点时，只找到：

- CEGUI `Window` 的属性定义、序列化和读写
- 没有找到清晰的业务层运行时使用点

同时 `logic/shop/stalldlg.lua` 仍显式执行：

- `self.searchBtn:subscribeEvent(...)`
- `self.buyBtn:subscribeEvent(...)`
- `self.tradeLog:subscribeEvent(...)`

因此当前更可靠的判断是：

- `LuaEventOnClicked` 至少不是现行主路径
- 新增技能应默认走显式 `subscribeEvent`
- 若后续要启用声明式绑定，需先单独做运行时链路核实

这不是主观偏好，而是代码搜索后的保守结论。

## 8. 典型样本

### 8.1 `LogoInfo`

`client/resource/res/script/logic/logo/logoinfodlg.lua` 展示了最典型的 Lua dialog 模式：

- 单例 `_instance`
- `GetLayoutFileName() -> "logoinfo.layout"`
- `OnCreate()` 里逐个 `getWindow()`
- 逐个 `subscribeEvent()`

`client/resource/res/ui/layouts/logoinfo.layout` 展示了最典型的布局事实：

- 根窗口 `LogoInfo`
- 大量绝对路径控件名，如 `LogoInfo/backImage/jiangLiBtn`
- 资源引用使用 `set:skillui image:tiaodi`、`set:diban image:wifi`
- 样式类型使用 `TaharezLook/ImageButton`、`TaharezLook/StaticImage`

### 8.2 `StallDlg`

`client/resource/res/script/logic/shop/stalldlg.lua` 很重要，因为它同时命中了两种模式：

- `GetLayoutFileName() -> "baitan.layout"`
- `baitan.layout` 中存在 `LuaEventOnClicked`
- 但脚本仍手工 `subscribeEvent`

它证明了：

- 布局声明式属性与脚本显式绑定可以同时存在
- 当前真实业务仍依赖显式绑定

## 9. 资源加载、缓存与释放

### 9.1 同步加载

常规 Lua dialog 主路径使用：

- `WindowManager::loadWindowLayout()`

`tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp` 里，这个函数会先把文件名转成小写再加载。这意味着：

- 布局文件名查找是大小写宽容的
- 但新文件仍应优先使用小写命名，避免历史兼容逻辑继续扩散

### 9.2 模板缓存与异步加载

`GameUIManager.cpp` 还提供：

- `asyncLoadWindowLayout()`
- `LayoutReadTask`
- `cloneWindowFromTemplate()`
- `addTemplateWindow()`

这说明引擎支持：

- 布局模板缓存
- 异步读布局
- 基于模板 clone

但当前 Lua dialog 主流仍是同步 `loadWindowLayout()`。新技能只有在命中大布局、模板或已有缓存链时，才应引导到这条路径。

### 9.3 释放路径

Lua 释放主链：

1. `Dialog.OnClose()`
2. `RemoveAllScriptFunctors()`
3. `LuaUIManager:RemoveUIDialog()`
4. `CEGUI.WindowManager:destroyWindow()`

C++ 侧还有：

- `cleanupAllEvent()`
- `OnUIDialogDestructionStarted`
- `UnInitGameUI()`

因此“新增 UI 技能”不只是会创建窗口，更要会收尾和退出。

## 10. 当前阻碍技能沉淀的根因

### 10.1 关联机制主要靠约定，不靠注册表

根因：

- `.layout` 与 `.lua` 的关联不是集中配置，而是散落在 `GetLayoutFileName()`、`loadWindowLayout()` 和窗口路径字符串里。

影响：

- 技能如果只按文件名猜配对，很容易漏掉 cell、模板、C++ 对话框和历史文件。

### 10.2 绑定模型混杂

根因：

- 仓库同时存在 `LuaEventOnClicked` 和显式 `subscribeEvent`。

证据：

- 84 个布局含 `LuaEventOnClicked`
- 但 `stalldlg.lua` 等主路径仍手工订阅事件
- 搜索未找到清晰的业务层消费 `GetLuaEventOnClicked()` 的逻辑

影响：

- 新技能若默认推广声明式绑定，风险很高。

### 10.3 资源组命名与主脚本目录不一致

根因：

- `GameUIManager` 里 `lua_scripts` 资源组指向 `scripts/` 或 `/lua_scripts/`
- 但 `res` 实际脚本主目录是 `script/`

影响：

- 这条资源组更像历史遗留或旁路，不应被当成 Lua 主逻辑目录的事实入口。

### 10.4 布局分层复杂

根因：

- 857 个布局里，直接 1:1 对话框只覆盖一部分；大量布局是 cell、模板、分页或嵌入组件。

影响：

- 新技能必须先做模式识别，再决定该新增 `.layout`、扩展已有 `.layout`，还是做动态 cell。

## 11. 新增 CEGUI 技能应固化的规则

建议技能名：`cegui-layout-integration`

技能应明确教会 Codex：

1. 先确认任务属于完整 dialog、cell/模板，还是样式资源改动。
2. 优先复用现有 `TaharezLook/*` 类型，不轻易新开 scheme。
3. 布局资源引用必须先确认 `scheme` 已加载对应 `imageset/font`。
4. 根窗口和子控件命名要为 Lua/C++ 的 `getWindow("path")` 服务。
5. 修改控件名后，必须全仓反查对应窗口路径字符串。
6. 默认采用显式 `subscribeEvent` 绑定，不把 `LuaEventOnClicked` 当成主路径。
7. 只有命中已有缓存/模板链时，才走异步布局或模板 clone。

## 12. 新增 Lua 技能应固化的规则

建议技能名：`lua-dialog-integration`

技能应明确教会 Codex：

1. 先判断是完整 dialog、列表 cell、manager 还是纯工具脚本。
2. 完整 dialog 默认遵循：
   - `require "logic.dialog"`
   - 单例 `_instance`
   - `GetLayoutFileName()`
   - `OnCreate()`
   - `DestroyDialog()`
   - `OnClose()`
3. 事件绑定默认使用显式 `subscribeEvent`。
4. 数据同步依赖 manager、事件 functor、协议回包或 C++ `executeString/executeGlobalFunction` 调用链。
5. 修改布局后必须同步检查：
   - `GetLayoutFileName()`
   - `winMgr:getWindow("...")`
   - `subscribeEvent(...)`
   - `DestroyDialog()` / 解绑逻辑
6. 若任务同时改 `.layout`，必须联动 `cegui-layout-integration`。

## 13. 新技能集成建议

### 13.1 技能边界

建议把两个新技能边界拆开：

- `cegui-layout-integration`
  - 聚焦 `client/resource/res/ui/**`
  - 负责资源链、布局结构、命名与样式
- `lua-dialog-integration`
  - 聚焦 `client/resource/res/script/**`
  - 负责 Dialog 生命周期、事件绑定、数据同步和 Lua/C++ 桥接

### 13.2 与现有技能的关系

- 与 `rendering-pipeline` 关系：
  - `rendering-pipeline` 负责更高层的渲染链
  - `cegui-layout-integration` 负责更窄的 CEGUI 布局事实和规则
- 与 `application-core-flow` 关系：
  - `application-core-flow` 负责共享主链
  - `lua-dialog-integration` 负责更窄的 Lua 对话框生命周期
- 与 `encoding-bom-guard` 关系：
  - 所有 `.lua/.md/.xml/.yaml` 编辑都应联动

### 13.3 最低验证动作

新增或修改 UI 相关实现后，至少应执行这些验证：

1. `rg -n "GetLayoutFileName|loadWindowLayout|getWindow\\(|subscribeEvent\\(" client/resource/res/script`
2. `rg -n "set:|Font|Window Type|LuaEventOnClicked" client/resource/res/ui/layouts -g "*.layout"`
3. 反查改动过的窗口路径、布局文件名和事件处理函数是否一致
4. 若新增资源，确认对应 `imageset/font/scheme` 已存在并可被主链加载

## 14. 后续建议

若后续继续治理这一块，优先级建议如下：

1. 先把新技能用于后续真实任务，验证触发描述是否足够准。
2. 再补一轮布局与脚本的“显式配对清单”，重点覆盖高频模块。
3. 若确认 `LuaEventOnClicked` 已废弃，再单独做一次清理或降级文档说明。
4. 若需要更强自动化，再考虑生成 “layout -> lua/cpp/动态引用” 关系表，而不是现在就引入固定脚本。

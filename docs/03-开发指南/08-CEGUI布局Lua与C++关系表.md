# client/resource/res layout 与 Lua/C++ 入口关系表

## 1. 目的

本文是 [07-CEGUI与Lua资源集成](07-CEGUI与Lua资源集成.md) 的补充，专门回答一个更具体的问题：

- 一个 `.layout` 现在是被哪个入口链路使用的。
- 该布局属于完整 dialog、动态 cell/子布局，还是 C++ 直连布局。
- 当新增或修改布局时，应该先反查哪一条调用链。

本文只基于当前仓库源码取证，不对“未找到显式入口”的布局直接下“废弃”结论。

## 2. 取证口径

本次关系分类只统计 4 类显式入口：

1. Lua `GetLayoutFileName()` 返回值。
2. Lua `loadWindowLayout("xxx.layout")` 动态加载。
3. C++ `loadWindowLayout("xxx.layout")` 字面量加载。
4. C++ 通用基类 `Dialog.cpp` 的 `loadWindowLayout(fileName, name_prefix)` 泛型入口。

统计范围：

- `client/resource/res/ui/layouts/**/*.layout`
- `client/resource/res/script/**/*.lua`
- `client/FireClient/Application/**/*.cpp`
- `client/FireClient/Application/**/*.h`

## 3. 总量结论

当前 `ui/layouts` 目录共有 857 个 `.layout`。

按显式入口分类后的结果如下：

| 分类 | 数量 | 说明 |
| --- | ---: | --- |
| Lua `GetLayoutFileName()` 唯一布局名 | 547 | 典型完整 dialog 或带单独类的 cell |
| Lua 动态 `loadWindowLayout()` 唯一布局名 | 80 | 典型 cell、模板、分页、预制子布局 |
| C++ 字面量 `loadWindowLayout()` 唯一布局名 | 3 | 目前主要是消息框和场景特效背景 |
| 至少出现在上述任一显式入口中的唯一布局名 | 629 | 当前能直接回溯到脚本或 C++ 调用点 |
| 当前未在上述显式入口中命中的布局名 | 193 | 这是第一轮“字面量入口”结果，不等同于真实未使用清单 |

进一步拆分：

| 子类 | 数量 |
| --- | ---: |
| 只在 `GetLayoutFileName()` 中出现 | 546 |
| 只在动态 `loadWindowLayout()` 中出现 | 79 |
| 同时被 `GetLayoutFileName()` 和动态加载命中 | 1 |
| 只在 C++ 字面量入口出现 | 3 |

唯一同时落在“直接入口 + 动态入口”的布局是：

- `zhuanzhibaoshicell.layout`

这类交叉布局修改时要同时检查“作为独立类使用”和“作为子布局复用”两条链。

## 4. 直接 dialog 入口链

### 4.1 事实

Lua 侧最稳定的入口链仍是：

1. `GetLayoutFileName()`
2. `Dialog.OnCreate()`
3. `loadWindowLayout()`
4. `getWindow("Root/Child/...")`
5. `subscribeEvent()`

本次共捕获 667 个 `GetLayoutFileName()` 返回点，对应 547 个唯一布局名。

### 4.2 代表样本

| Lua 文件 | 类/函数 | 布局 |
| --- | --- | --- |
| `logic/logo/logoinfodlg.lua` | `LogoInfoDialog.GetLayoutFileName` | `logoinfo.layout` |
| `logic/friend/frienddialog.lua` | `FriendDialog.GetLayoutFileName` | `frienddialog.layout` |
| `logic/maincontrol.lua` | `MainControl.GetLayoutFileName` | `maincontrol.layout` |
| `logic/battle/battleskillpanel.lua` | `BattleSkillPanel.GetLayoutFileName` | `skilllist.layout` |
| `logic/shop/treasurehousedlg.lua` | `TreasureHouseDlg.GetLayoutFileName` | 对应主页面布局 |
| `logic/systemsettingdlgnew.lua` | `SystemSettingNewDlg.GetLayoutFileName` | `systemsetting1.layout` |

### 4.3 判断规则

命中这一类时，优先把布局当作“完整 dialog”处理：

- 先查 `GetLayoutFileName()`
- 再查 `OnCreate()` 中的 `getWindow()` 路径
- 再查 `subscribeEvent()`、script functor、manager 解绑链

## 5. 动态子布局 / cell / 模板入口链

### 5.1 事实

Lua 中显式 `loadWindowLayout("xxx.layout")` 共命中 93 条引用，折算为 80 个唯一布局名。

这类布局通常不是完整 dialog，而是：

- 列表 cell
- 复合页局部模板
- 预制卡片
- 子分页
- 某个主窗口中的嵌入组件

### 5.2 高密度动态加载点

| Lua 文件 | 动态布局数量 | 代表布局 |
| --- | ---: | --- |
| `logic/jingling/jinglingdlg.lua` | 5 | `dashidati.layout`、`jinglinganswer.layout`、`jinglinguserask.layout` |
| `logic/shop/stalldlg.lua` | 4 | `baitancell1.layout` 到 `baitancell4.layout` |
| `logic/chat/insertdlg.lua` | 4 | `insetbaitancell.layout`、`insetcell.layout`、`insetchatcell.layout`、`insetpetcell.layout` |
| `logic/pet/petshizhuangdlg.lua` | 3 | `petcard.layout`、`petcardwon.layout`、`petcellsz.layout` |
| `logic/team/teamrollmelondialog.lua` | 2 | `teamrollcell.layout`、`teamrolldaojishi.layout` |
| `logic/task/renwulistdialog.lua` | 2 | `teamkuaijiecell.layout`、`teampipeicell.layout` |

### 5.3 判断规则

命中这一类时，不要直接套完整 dialog 模式：

- 先确认主窗口是谁。
- 再确认当前布局是否依赖 `nameprefix`。
- 再确认列表刷新、克隆、销毁由谁负责。

像 `baitancell*.layout`、`friendcell.layout`、`petskillbookcell_mtg.layout` 这类布局，通常更接近“复用模板”而不是“单独窗口”。

## 6. C++ 入口链

### 6.1 事实

当前在 `client/FireClient/Application` 下能直接命中的 C++ 字面量布局只有 3 个：

| C++ 文件 | 布局 |
| --- | --- |
| `Manager/MessageManager.cpp` | `MessageBox.layout` |
| `Manager/MessageManager.cpp` | `SpecialMessageBox.layout` |
| `Manager/SceneMovieManager.cpp` | `SceneAniBack.layout` |

另有两个必须注意的泛型入口：

- `GameUI/Dialog.cpp`：`loadWindowLayout(fileName, name_prefix)`，说明 C++ dialog 也可能复用 Lua 同类模式。
- `Manager/GameUIManager.cpp`：存在模板回收/清理路径，会 `loadWindowLayout(it->c_str())` 后销毁。

### 6.2 判断规则

如果改动命中消息框、场景动画背景或 C++ dialog：

- 先反查 `client/FireClient/Application`，不要只在 Lua 下找。
- 若布局是通过 `fileName` 变量传入，继续顺着类成员或构造参数上溯。

## 7. 当前未见显式入口的 193 个布局

### 7.1 这类布局不等于可删

当前未在上面三条“显式入口”命中的有 193 个布局。这里只能得出：

- 当前一次性扫描没有直接命中它们的 `GetLayoutFileName()`、Lua 字面量动态加载或 C++ 字面量加载。

不能直接得出：

- 这些布局一定未使用。
- 这些布局可以删除。

### 7.2 代表样本

这一类里比较典型的名字包括：

- `guidedlg.layout`、`guidedlg1.layout` 到 `guidedlg5.layout`
- `battleautodlg.layout`
- `banbengengxindialog.layout`
- `familytips.layout`
- `fengcefanli.layout`
- `jingmai111.layout` 到 `jingmai163.layout`
- `friendheimingdancell.layout`
- `itembuyback.layout`

### 7.3 更合理的解释

结合命名特征，这 193 个布局通常更可能属于以下几类：

1. 历史版本残留或专题阶段性布局。
2. 通过更隐蔽的字符串拼接、配置驱动或脚本执行入口加载。
3. 只在某些编辑器、活动服或特殊分支链路使用。
4. 只作为手工拖入、模板克隆或局部嵌套资源存在。

这也是为什么新增技能不能把“没有搜到 `GetLayoutFileName()`”直接等同于“可重命名/可删除”。

## 8. 第二轮隐式入口追链结论

第一轮的 193 个“未见显式入口”里，很多并不是没被使用，而是入口不是字面量写死的。

第二轮按“精确名称二次搜索 + 已证实的生成规则”补追后，结论如下：

| 口径 | 数量 | 说明 |
| --- | ---: | --- |
| 第一轮字面量未命中 | 193 | 只统计字面量 `return "x.layout"` 和 `loadWindowLayout("x.layout")` |
| 第二轮精确名称命中 | 29 | 典型是 `layoutName = "x.layout"` 后再中转调用 |
| 第二轮已证实生成族群 | 60 | 典型是 `guidedlg*.layout`、`jingmai###.layout`、`chatdiacell*.layout` 等 |
| 第二轮合计补回 | 89 | 说明第一轮漏掉了大量隐式入口 |
| 当前仍属硬未证实 | 104 | 到这一轮为止仍未拿到足够入口证据 |

这组数字说明：

- “193 个未命中”不能直接理解成“193 个废弃布局”。
- 第一轮分类器的主要盲点是变量中转和字符串拼接，不是资源树本身失真。

## 9. 已证实的隐式入口模式

### 9.1 变量中转

典型写法：

```lua
local layoutName = "familyduizhanzuduicell1.layout"
self.m_pMainFrame = winMgr:loadWindowLayout(layoutName, prefix)
```

已证实样本：

- `logic/family/familyduizhanzuduichildcell.lua -> familyduizhanzuduicell1.layout`
- `logic/family/familyduizhanzudui.lua -> familyduizhanzuduicell2.layout`
- `logic/qiandaosongli/qiandaosonglidlg_mtg.lua -> qiandaosonglimain.layout`
- `logic/qiandaosongli/mtg_firstchargedlg.lua -> shouchong.layout`
- `logic/qiandaosongli/leveluprewarddlg.lua -> shengjidalibao.layout`
- `logic/space/spacedetaildialog.lua -> kongjiandetail.layout`

结论：

- 只搜 `loadWindowLayout("...")` 会漏掉这一类。
- 第二轮必须补查 `layoutName`、`strLayoutName`、`layoutNamegetSize` 之类的中转变量。

### 9.2 字符串拼接族群

#### 新手引导浮层

`logic/guide/newroleguidemanager.lua` 中，布局名由下面的规则生成：

```lua
str = "guidedlg"
if record.uiposition ~= 0 then
    str = str .. tostring(record.uiposition)
end
str = str .. ".layout"
```

这条链能解释当前存在的：

- `guidedlg.layout`
- `guidedlg1.layout`
- `guidedlg2.layout`
- `guidedlg3.layout`
- `guidedlg4.layout`
- `guidedlg5.layout`

#### 经脉数字布局

`logic/workshop/jingmai/jingmaizhu.lua` 先组出：

```lua
local prefix = "jingmai" .. zhiye .. data.fangan
```

随后 `logic/workshop/jingmai/jingmais.lua` 再继续：

```lua
local layoutName = prefix .. ".layout"
self.m_pMainFrame = winMgr:loadWindowLayout(layoutName, prefix)
```

这条链能解释 `ui/layouts` 下 48 个数字布局，例如：

- `jingmai111.layout`
- `jingmai154.layout`
- `jingmai211.layout`
- `jingmai254.layout`

#### 聊天气泡 cell

`logic/chat/chatcommon.lua` 中：

```lua
local chatCellName = {"chatdiacell", "chatdiacell2", "chatdiacell3"}
self.window = winMgr:loadWindowLayout(chatCellName[style] .. ".layout", chatCellUniName[style])
```

这条链能解释：

- `chatdiacell.layout`
- `chatdiacell2.layout`
- `chatdiacell3.layout`

#### 生死战排行 cell

`logic/shengsizhan/shengsibangdlg.lua` 中：

```lua
local lyout = winMgr:loadWindowLayout(lyoutname .. ".layout", sID)
```

其中 `lyoutname` 会在运行时切换为：

- `shengsizhanbenripaihangcell_mtg`
- `shengsizhanbenripaihangcell2_mtg`
- `shengsizhanbenripaihangcell3_mtg`

结论：

- 对 `.layout` 的追链不能只看“完整文件名是否出现在源码里”。
- 还必须看基名数组、前缀拼接和枚举切换。

## 10. 配置表字段现状

`tabledef/mission/cuicongig.lua` 定义了 `layoutname` 字段：

```lua
status,bean.layoutname = util:Load_string()
```

同时 `logic/openui.lua` 确实会读取 `mission.cuicongig`：

- `uiCfg = BeanConfigManager.getInstance():GetTableByName("mission.cuicongig"):getRecorder(nUIId)`

但当前已证实的消费字段只有：

- `uiCfg.name`
- `uiCfg.ngongnengid`

到本轮追链为止，还没有找到 `uiCfg.layoutname` 的运行时消费点。

结论：

- 可以确认“配置表里存在 layoutname 字段”。
- 但不能把它写成“当前客户端的布局注册主链”。
- 新技能遇到这条线时，应把它当作待继续核实的旁证，而不是既定事实。

## 11. 当前更像历史残留或改名漂移的样本

下面这些布局，到本轮为止仍未拿到明确入口，而且名字和现行布局存在明显接近关系：

- `battleautodlg.layout`，而现行脚本 `battleautofightdlg.lua` 返回的是 `BattleAuto.layout`
- `fengcefanli.layout`，而现行脚本 `fengcefanhuandlg.lua` 使用的是 `fengcefanhuan.layout`

这类样本更接近“历史版本残留、重命名未清理或策划分支遗留”。

这里是推断，不是定论。若后续要清理，仍需要：

1. 补查运行时触发链。
2. 在真实客户端流程中验证。
3. 再决定是否删除或合并。

## 12. 新增或修改布局时的反查顺序

推荐固定按下面顺序取证：

1. 先查是否命中 `GetLayoutFileName()`：

```powershell
rg -n "GetLayoutFileName" client/resource/res/script -g "*.lua"
```

2. 再查是否被动态 `loadWindowLayout()` 引用：

```powershell
rg -n "loadWindowLayout\\(" client/resource/res/script -g "*.lua"
```

3. 再查 C++ 是否直接使用：

```powershell
rg -n "loadWindowLayout\\(" client/FireClient/Application -g "*.cpp" -g "*.h"
```

4. 改控件路径前，反查 `getWindow()` 和事件绑定：

```powershell
rg -n "getWindow\\(|subscribeEvent\\(" client/resource/res/script -g "*.lua"
rg -n "getWindow\\(|subscribeEvent\\(" client/FireClient/Application -g "*.cpp" -g "*.h"
```

如果前三步都没命中，还要继续补 2 轮：

5. 查变量中转：

```powershell
rg -n "layoutName|strLayoutName|layoutNamegetSize|lyoutname" client/resource/res/script -g "*.lua"
```

6. 查字符串拼接：

```powershell
rg -n "\\.\\.\\s*\"\\.layout\"" client/resource/res/script -g "*.lua"
```

## 13. 对技能设计的直接约束

对 `cegui-layout-integration`：

- 第一步必须先把目标布局归到“直接 dialog / 动态子布局 / C++ 入口 / 未见显式入口”四类之一。
- 只有落到“直接 dialog”时，才默认按完整窗口生命周期分析。
- 若前三类字面量入口都没命中，必须继续查变量中转和字符串拼接，不能立刻判“未使用”。

对 `lua-dialog-integration`：

- 不能假设每个布局都有 1:1 `GetLayoutFileName()`。
- 命中 `loadWindowLayout("xxx.layout")` 且无 `GetLayoutFileName()` 时，要优先按 cell/模板模式看待。
- 若存在 `prefix .. ".layout"`、`lyoutname .. ".layout"`、数组基名拼接等模式，必须把对应布局视为真实运行时入口候选。
- `mission.cuicongig.layoutname` 字段存在，但当前未见消费，不能把它当现成注册表。

## 14. 后续建议

如果后续继续治理这一块，建议优先做两件事：

1. 继续针对当前仍硬未证实的 104 个布局，补查 `executeString`、脚本拼接和运行时路径。
2. 对高频模块单独沉淀局部关系表，例如：
   - 摆摊链
   - 好友链
   - 精灵问答链
   - 宠物技能书链

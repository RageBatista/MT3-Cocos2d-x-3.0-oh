# Lua Dialog 事实速查

## 关键事实

- `GameApplication.cpp` 会执行 `dofile_main.lua` 和 `main.lua`；前者预加载 manager 和大量 UI 模块，后者进入登录主流程。
- `logic/dialog.lua` 是大多数 Lua dialog 的基类，主链是：
  1. `GetLayoutFileName()`
  2. `loadWindowLayout()`
  3. `getWindow()`
  4. `subscribeEvent()`
  5. `OnClose()` / `DestroyDialog()`
- `logic/luauimanager.lua` 负责 `window -> dialog` 映射、析构兜底和退出清理。
- 直接 1:1 布局配对只覆盖部分 dialog；还有大量 cell、模板和被动态加载的子布局。
- C++ 也会通过 `executeString()` 或 `executeGlobalFunction()` 触发 Lua UI 逻辑。

## Dialog 基类生命周期

### OnCreate 完整流程

1. **单例复用检查**：若 `m_pMainFrame` 存在且 `m_bCloseIsHide` 为 true，直接 `SetVisible(true)` 返回
2. **加载布局**：`winMgr:loadWindowLayout(fileName, nameprefix)`
3. **挂载到窗口树**：`root:addChildWindow(self.m_pMainFrame)`，支持场景电影模式特殊处理
4. **自动绑定关闭按钮**：若根窗口为 `FrameWindow`，自动订阅 `Clicked` 事件
5. **订阅生命周期事件**：`Shown`、`Hidden`、`DestructStart`
6. **模态处理**：若 `isModalAfterShow()` 为 true，设置模态状态
7. **注册到 LuaUIManager**：`LuaUIManager.getInstance():AddDialog(self.m_pMainFrame, self)`

### OnClose 完整流程

1. 若 `m_bCloseIsHide` 为 true，仅 `hide()` 窗口
2. 若为 false：
   - `RemoveAllScriptFunctors()` 清理所有 ScriptFunctor
   - `LuaUIManager.getInstance():RemoveUIDialog(self.m_pMainFrame)` 注销
   - `CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)` 销毁窗口
   - `self.m_pMainFrame = nil` 清空引用

### ScriptFunctor 机制

- `InsertScriptFunctor(eventGetter, func)` 注册回调，返回 handle 存入 `self.mScriptFunctors`
- `RemoveAllScriptFunctors()` 在 `OnClose()` 中自动调用，遍历并移除所有已注册的 functor
- 若子类覆盖 `OnClose()` 且未调用基类方法，ScriptFunctor 不会被清理，导致泄漏
- `subscribeEvent` 绑定的事件回调在窗口销毁时由 CEGUI 自动清理，不需要手动解绑

## 代表样本

- 标准单例 dialog：`client/resource/res/script/logic/logo/logoinfodlg.lua`
- 复杂页面 dialog：`client/resource/res/script/logic/shop/stalldlg.lua`
- 生命周期基类：`client/resource/res/script/logic/dialog.lua`
- UI 管理器：`client/resource/res/script/logic/luauimanager.lua`
- Cell 模式：`client/resource/res/script/logic/pet/petpropertydlgnew.lua`
- 动态布局名：`client/resource/res/script/logic/workshop/jingmai/jingmais.lua`

## 修改前最少检查

1. 当前脚本是完整 dialog、cell，还是 manager。
2. `GetLayoutFileName()` 是否存在，是否与布局文件一致。
3. `winMgr:getWindow("...")` 路径是否与布局树一致。
4. 是否注册了 script functor、协议回包、manager 监听，关闭时是否需要解绑。
5. 若使用了 `InsertScriptFunctor`，`OnClose()` 中是否调用了 `RemoveAllScriptFunctor()`。

## 事件绑定模式

### subscribeEvent 事件类型

| 事件类型 | 适用控件 | 典型用法 |
|---------|---------|---------|
| `Clicked` | PushButton | 按钮点击 |
| `MouseClick` | 任意窗口 | 鼠标点击 |
| `MouseButtonDown` | 任意窗口 | 鼠标按下 |
| `MouseButtonUp` | 任意窗口 | 鼠标释放 |
| `SelectStateChanged` | GroupButton, Checkbox, RadioButton | 选择状态变化 |
| `TextChanged` | Editbox | 文本变化 |
| `KeyboardTargetWndChanged` | Editbox | 键盘焦点变化 |
| `Shown` | 任意窗口 | 窗口显示 |
| `Hidden` | 任意窗口 | 窗口隐藏 |
| `DestructStart` | 任意窗口 | 窗口即将销毁 |

### subscribeEvent 回调模式

```lua
-- 模式一：类方法引用（最常见）
self.closeBtn:subscribeEvent("Clicked", CBGItemDlg.HandleCloseButtonClick, self)

-- 模式二：内联函数（用于组合操作）
self.freeBtn:subscribeEvent("Clicked", function()
    self:handleToggleView(false)
    PetPropertyDlgNew.handleFreeBtnOnClicked(self)
end, self)

-- 模式三：nil receiver（不绑定 self）
self:GetCloseBtn():subscribeEvent("Clicked", PetLabel.hide, nil)
```

### LuaEventOnClicked 双路径

- 约 84 个布局在 XML 中声明 `LuaEventOnClicked` 属性
- 集中在 `cbg*`、`lianyaoshengdian`、`switchaccountdialog` 等布局
- 回调函数名直接写在 `Value` 属性中，不需要 `ClassName.` 前缀
- 若同一控件同时有 `LuaEventOnClicked` 和 `subscribeEvent`，两者都会触发
- 新增界面优先使用 `subscribeEvent` 主路径

## CEGUI 控件类型转换

### 两种转换写法

```lua
-- 写法一（多数脚本使用）
self.btn = CEGUI.toPushButton(winMgr:getWindow("Root/btn"))

-- 写法二（switchaccountdialog 等使用）
self.btn = CEGUI.Window.toPushButton(winMgr:getWindow("Root/btn"))
```

### 类型转换函数与布局 Type 对应

| Lua 转换函数 | 布局 Type | 典型场景 |
|-------------|-----------|---------|
| `CEGUI.toPushButton` | `TaharezLook/PushButton` | 按钮 |
| `CEGUI.toEditbox` | `TaharezLook/Editbox` | 输入框 |
| `CEGUI.toProgressBar` | `TaharezLook/ProgressBar` | 进度条 |
| `CEGUI.toFrameWindow` | `TaharezLook/FrameWindow` | 框架窗口 |
| `CEGUI.toGroupButton` | `TaharezLook/GroupButton` | 分组按钮/选项卡/Cell |
| `CEGUI.toItemCell` | `TaharezLook/ItemCell` | 物品格子 |
| `CEGUI.toSkillBox` | `TaharezLook/SkillBox` | 技能框 |
| `CEGUI.toWindowEventArgs` | — | 事件参数转换 |

### 事件回调中提取窗口

```lua
local wnd = CEGUI.toWindowEventArgs(args).window
local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
local skillBox = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
```

## 动态布局名模式

| 模式 | 示例 | 出现位置 |
|------|------|----------|
| 局部变量赋值 | `local layoutName = "xinshouliwu.layout"` | mtg_onlinewelfaredlg.lua |
| 前缀拼接 | `local layoutName = prefix..".layout"` | jingmais.lua |
| 条件选择 | `lyoutname = cond and "cell_a" or "cell_b"` | shengsibangdlg.lua |
| 数组索引 | `chatCellName[style] .. ".layout"` | chatcommon.lua |
| 枚举映射 | `layoutName = "baitanshaixuan1"` / `"baitanshaixuan2"` | multimenuset.lua |

## Cell/子布局管理模式

### 典型 Cell 加载流程

```lua
-- 1. 加载 cell 布局（带 nameprefix 确保唯一）
local lyout = winMgr:loadWindowLayout("petcell1.layout", sID)

-- 2. 获取 cell 内控件（使用 prefix 拼接窗口路径）
lyout.addclick = CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"))

-- 3. 订阅 cell 内控件事件
lyout.addclick:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handlePetIconSelected, self)

-- 4. 存储数据引用
lyout.data = petData

-- 5. 挂载到列表容器
self.petlistWnd:addChildWindow(lyout)

-- 6. 移除 cell
self.petlistWnd:removeChildWindow(lyout)
```

### 高频 Cell 布局

| Cell 布局 | 使用者 | nameprefix |
|-----------|--------|------------|
| `petcell1.layout` | petpropertydlgnew, petlianyaodlg, petfeeddlg | `sID` |
| `cbgcell1.layout` / `cbgcell2.layout` | treasurehousedlg | `prefix` |
| `blackmarkettemcell.layout` | cbgitemdlg | `prefix` |
| `jueseshizhuangcell.layout` | charactershizhuangdlg | `sID` |
| `baitancell2.layout` / `baitancell4.layout` | stallupshelf / stalldlg | `prefix` |
| `friendcell.layout` | frienddialog | `namePrefix` |
| `guajicell.layout` | guaji | `sID` |
| `lifeskillcell.layout` | gonghuiskilldlg | `namePrefix` |

## 主界面入口接线闭环

给现有主界面补入口时，不要只改一个点击函数，至少检查：

1. `layout` 是否有对应按钮节点
2. `OnCreate()` 是否成功 `getWindow()` / `toPushButton()`
3. 是否完成 `subscribeEvent()`
4. 点击后是否打开正确 dialog
5. 运行时显隐函数是否会把新入口再次隐藏

### 推荐顺序

1. 先找当前主界面的现行 `layout + dialog`
2. 再对照 `unpacked` 的旧版入口实现
3. 优先复用遗留坑位或隐藏节点
4. 最后补显隐条件和刷新逻辑

## Lua 协议资源闭环

当 Lua dialog 依赖 `protodef` 协议时，检查三层：

1. `script/protodef/protocols.lua` 是否有 `RegisterLuaProtocolCreator`
2. 对应 `protodef/fire/pb/**.lua` 是否已在 `res`
3. 若协议文件内部继续 `require bean`，其依赖 bean 是否也在 `res`

### 典型模式

1. 炼妖盛典
   - 常见缺口：协议文件已在 `res`，但 `protocols.lua` 没注册
   - 关键协议：`creqlianyaoscore`、`sreqlianyaoscore`、`creqlianyaobuyitems`、`creqlianyaoaward`、`cbuylianyaoitem`
2. 藏宝阁
   - 常见缺口：只保留了短信校验码协议，黑市交易协议和 bean 没同步
   - 除 `c/sblackmarket*`、`cgoldorder*` 外，还要补 `blackmarketgoods.lua`、`goldorderinfo.lua`

## 布局属性操控 API

| API | 用途 | 示例 |
|-----|------|------|
| `setText(text)` | 设置文本 | `self.m_Account:setText(strLastAccount)` |
| `setTextMasked(bool)` | 密码遮罩 | `self.m_KeyEdit:setTextMasked(true)` |
| `setVisible(bool)` | 显隐控制 | `self.loginFy:setVisible(true)` |
| `setProperty(name, value)` | 通用属性设置 | `btn:setProperty("NormalImage", "set:xxx image:yyy")` |
| `setAlpha(value)` | 透明度 | `wnd:setAlpha(0.5)` |
| `activate()` | 激活窗口 | `self.m_pMainFrame:activate()` |
| `hide()` | 隐藏窗口 | `self.m_pMainFrame:hide()` |
| `setModalState(bool)` | 模态状态 | `wnd:setModalState(true)` |
| `addChildWindow(wnd)` | 挂载子窗口 | `self.petlistWnd:addChildWindow(lyout)` |
| `removeChildWindow(wnd)` | 移除子窗口 | `self.petlistWnd:removeChildWindow(lyout)` |

图片属性值格式：`"set:imageset名 image:图片项名"`，如 `"set:logindlginfo image:login1"`。

## 排查命令

```powershell
# 查找所有 GetLayoutFileName 定义
rg -n "GetLayoutFileName" client/resource/res/script

# 查找所有动态布局名变量
rg -n "layoutName\s*=|lyoutname" client/resource/res/script

# 查找所有 subscribeEvent 调用
rg -n "subscribeEvent" client/resource/res/script

# 查找所有 InsertScriptFunctor 调用
rg -n "InsertScriptFunctor" client/resource/res/script

# 查找特定 dialog 的 DestroyDialog 定义
rg -n "function.*DestroyDialog" client/resource/res/script/logic/pet/petpropertydlgnew.lua

# 验证 ScriptFunctor 清理
rg -n "RemoveAllScriptFunctors" client/resource/res/script/logic/dialog.lua
```

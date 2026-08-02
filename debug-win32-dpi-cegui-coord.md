# Debug Session: win32-dpi-cegui-coord

> **状态**: [OPEN]
> **会话域**: Win32 窗口/DPI 坐标链 + CEGUI 渲染坐标链 + 启动首帧黑屏
> **关联阻塞点**: 空账号登录崩溃（tolua++ 绑定缺口，根因已静态闭环，独立修复）
> **工具链**: Win32 canonical（VS2013 v120 + CEGUI 0.7.9-r5 + Cocos2d-x 3.0-oh）

---

## 1. 症状

1. **启动黑屏**: 启动到登录场景首帧未见 `waiting.jpg`；旧判断"sp=0=启动图缺失"已修正——`sp=0` 指尚未创建的开场视频，`waiting.jpg` 已取得句柄 1。需验证其是否真的进入首帧 GL 绘制路径。
2. **登录控件偏移**: `loginbackdialog.layout` 按钮用 `HorizontalAlignment="Centre"`，414px 面板内横向中心误差 <2px（静态已排除 layout 数值写歪）。怀疑"计算中心"与"实际绘制中心"落在不同坐标域。
3. **空账号登录崩溃（首阻塞点）**: 17:47:55 会话在 WM_LBUTTONUP Lua 事件后抛未处理 C++ 异常，WER 0xe06d7363，117MB 转储。Lua 调 `tip:SetTipsType(CEGUI.eMsgTip)` 与 `CEGUI.toUpdateEventArgs(e)` 触发。

## 2. 已收集证据（静态）

### 2.1 窗口/DPI 链（mt3.cpp）
- [client/MT3Win32App/mt3.cpp:106-107](file:///e:/MT3/client/MT3Win32App/mt3.cpp#L106-L107): `CreateWindow(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, ...)`
- **无 `SetProcessDpiAwareness` / `SetProcessDPIAware`**，无 manifest dpiAware 声明，无 `AdjustWindowRect`。
- 窗口尺寸完全交给系统默认（CW_USEDEFAULT），客户区不受控；`WS_OVERLAPPEDWINDOW` 含标题/边框，客户区 < 窗口尺寸。
- L117 `return gRunGameApplication();` 进入共享主链。
- 文件编码: CP936/GBK（注释乱码），修改须保持原编码。

### 2.2 CEGUI 显示尺寸链（canonical 0.7.9-r5）
- [tools/CEGUI-0.7.9-r5/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:82](file:///e:/MT3/tools/CEGUI-0.7.9-r5/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp#L82): `Cocos2DRenderer() : d_displaySize(getViewportSize()), ...` —— 构造时显示尺寸 = 当前 GL_VIEWPORT，**不是硬编码 1024x768**。
- L117-121 `getViewportSize()` 读 `glGetIntegerv(GL_VIEWPORT, vp)` 返回 `Size(vp[2], vp[3])`。
- L372-381 `setDisplaySize(sz)` 更新 `d_displaySize` 并重设默认 target 区域。
- [client/FireClient/Application/Manager/GameUIManager.cpp:2500-2517](file:///e:/MT3/client/FireClient/Application/Manager/GameUIManager.cpp#L2500-L2517):
  - L2500 `bootstrapSystem(pEngineLayer)` 创建渲染器（d_displaySize = 此刻 GL_VIEWPORT）
  - L2514 `CEGUI::System::create(...)`
  - L2516 `SetAdapter(&g_adapter)`
  - L2517 `notifyDisplaySizeChanged(Size(g_adapter.GetLogicWidth(), g_adapter.GetLogicHeight()))`
- **旧假设"渲染器默认 1024x768"需修正**: 渲染器初始尺寸 = bootstrapSystem 时刻的 GL_VIEWPORT；后续由 `notifyDisplaySizeChanged(g_adapter 逻辑尺寸)` 覆盖。是否真正下推到 `setDisplaySize`、`g_adapter.GetLogicWidth/Height` 是否为 1280x720，需运行时证据。

### 2.3 g_adapter
- [client/FireClient/Application/Framework/GameApplication.cpp:3193](file:///e:/MT3/client/FireClient/Application/Framework/GameApplication.cpp#L3193): `ResolutionAdapter g_adapter;`
- 同时存在 `get_logic_w/h()`（小写）与 `GetLogicWidth/Height()`（大写）两套接口；CEGUI 用的是大写 `GetLogicWidth/Height`。返回值需运行时确认。

### 2.4 崩溃根因（已静态闭环）
- Lua 调用点: [client/resource/res/script/logic/chat/tipsmanager.lua:120](file:///e:/MT3/client/resource/res/script/logic/chat/tipsmanager.lua#L120) `tip:SetTipsType(CEGUI.eMsgTip)`；[tipsmanager.lua:242](file:///e:/MT3/client/resource/res/script/logic/chat/tipsmanager.lua#L242) `CEGUI.toUpdateEventArgs(e)`。
- canonical 0.7.9-r5 Lua pkg 缺口:
  - [tools/CEGUI-0.7.9-r5/.../package/InputEvent.pkg](file:///e:/MT3/tools/CEGUI-0.7.9-r5/cegui/src/ScriptingModules/LuaScriptModule/package/InputEvent.pkg): 截至 `RenderQueueEventArgs`（L139），**缺 `UpdateEventArgs` 与 `GestureEventArgs`**。
  - canonical `elements/` 目录**无 `CompnentTip.pkg` / `MessageTip.pkg`**；`CEGUI.pkg` 也未 `$pfile` 引用。
  - 对比 `dependencies/cegui`（0.7.1）: `InputEvent.pkg` 含 `UpdateEventArgs`（L145-150, `d_timeSinceLastFrame`）+ `GestureEventArgs`；`elements/MessageTip.pkg` 含 `TipType{eMsgTip=1,eSystemTip=2}` + `MessageTip::SetTipsType/GetTipType`。
- canonical C++ 层齐全: [tools/CEGUI-0.7.9-r5/cegui/include/elements/CEGUICompnentTip.h](file:///e:/MT3/tools/CEGUI-0.7.9-r5/cegui/include/elements/CEGUICompnentTip.h) 已把 `MessageTip` 移植为 `CompnentTip`（注释 "MT3: MessageTip compatibility"），含 `TipType` 枚举、`SetTipsType/GetTipType` 及全部兼容方法；`CEGUIInputEvent.h` L264-267 有 `UpdateEventArgs::d_timeSinceLastFrame`。
- 结论: **C++ 已就绪，仅缺 tolua++ .pkg 声明** → 无 Lua 绑定 → `SetTipsType`/`toUpdateEventArgs` 为 nil → 异常 → 崩溃。

## 3. 可证伪假设

### 黑屏 / DPI / 坐标域（需运行时证据）
- **H1**: 进程未声明 DPI-aware，物理像素与逻辑像素不一致，导致窗口客户区 ≠ CEGUI 显示尺寸。
- **H2**: `bootstrapSystem` 时刻 GL_VIEWPORT 尺寸 ≠ `g_adapter.GetLogicWidth/Height`，且 `notifyDisplaySizeChanged` 未真正下推到 `Cocos2DRenderer::setDisplaySize`，导致渲染器 `d_displaySize` 仍是 GL_VIEWPORT 初值而非 1280x720。
- **H3**: `waiting.jpg` 虽取得纹理句柄 1，但首帧 GL 路径未将其加入绘制队列（材质未上传 / 被深度清除 / 场景节点未 addChild），故黑屏。
- **H4**: 开场视频 `sp=0`（未创建）使首帧渲染分支提前 return 或跳过 present。

### 崩溃（已闭环，待修复）
- **H5（已证实）**: canonical 0.7.9-r5 tolua++ .pkg 缺 `UpdateEventArgs` 与 `CompnentTip`（含 `TipType`/`SetTipsType`）声明，导致 Lua 侧 `CEGUI.toUpdateEventArgs` 与 `tip:SetTipsType` 为 nil。

## 4. 插桩计划（第一处代码改动 = 仅插桩，不动业务逻辑）

> 适配说明: 本项目为 VS2013 C++ Win32 游戏，TRAE-debugger 的 HTTP Debug Server 不适用；改用既有日志通道——`OutputDebugString`（DebugView 可见）用于 Win32/DPI/窗口，`CEGUI::Logger`（写 `CEGUI_ct.log`）用于 CEGUI 显示尺寸。所有插桩包在 `#region debug-point` 风格的成对注释内，最小侵入。

| ID | 位置 | 采集值 |
| --- | --- | --- |
| D1 | `mt3.cpp` InitInstance CreateWindow 之后 | `GetWindowRect`/`GetClientRect` 窗口矩形与客户矩形；`IsProcessDPIAware()`；`GetDpiForWindow` |
| D2 | `GameUIManager.cpp` L2500 bootstrapSystem 前后 | `glGetIntegerv(GL_VIEWPORT)` 即刻值；`g_adapter.GetLogicWidth/Height()` |
| D3 | `GameUIManager.cpp` L2517 notifyDisplaySizeChanged 之后 | `CEGUI::System::getSingleton().getRenderer()->getDisplaySize()` |
| D4 | CEGUICocos2DRenderer `setDisplaySize` 入口 | 传入 sz 与旧 d_displaySize（验证下推） |
| D5 | 首帧渲染路径 | waiting.jpg 纹理句柄、是否进入 draw queue、sp 状态 |

## 5. 修复计划（证据闭环后）

### 5.1 崩溃（H5，可独立先行）
1. canonical `InputEvent.pkg` 追加 `UpdateEventArgs`（+ `GestureEventArgs`）声明，对齐 0.7.1。
2. 新建 canonical `elements/CompnentTip.pkg`，声明 `TipType` 枚举 + `CompnentTip` 类的 `SetTipsType/GetTipType` 等兼容方法（对齐 0.7.1 `MessageTip.pkg`，类名改为 `CompnentTip`）。
3. `CEGUI.pkg` 追加 `$pfile "elements/CompnentTip.pkg"`。
4. 运行 tolua++ 生成链 → Rebuild CEGUI lib → Rebuild FireClient → Build MT3。

### 5.2 黑屏/坐标（H1-H4，待运行时证据）
- 按 D1-D5 证据定根因后做最小修复（可能涉及: 声明 DPI-aware、统一客户区与 CEGUI 显示尺寸、修正首帧绘制分支）。

## 6. 验证信号（用户锁定）
1. 窗口客户区与 CEGUI 显示尺寸一致。
2. 登录控件中心偏差接近 0。
3. 初始化期间首个可见帧不再依赖空的 sp。

## 7. 待用户确认
- 是否先落地 D1-D5 插桩 + 崩溃 .pkg 修复（5.1）并行推进？
- 工作树现有未提交变更（渲染补丁 + 构建工程文件）保持现状，仅在锁定源码范围追加。

---

## 8. 冷启动验证结果（2026-08-02 10:11）

> 构建产物: MT3.exe 31,868,928 bytes @ 2026/8/2 10:05:45, cegui-0.7.9_d.lib @ 10:05:02
> 运行时: `E:\MT3\client\resource\bin\Debug\MT3.exe`，PID=54924，窗口标题"梦幻西游手游"，Responding=True

### 8.1 构建链验证
- lua_CEGUI.cpp @ 9:54:06（晚于所有 .pkg 修改）
- CEGUI.pkg @ 9:41:09, HelperFunctions.pkg @ 9:48:17, InputEvent.pkg @ 9:41:09, CompnentTip.pkg @ 9:53:56
- lua_CEGUI.cpp 含 `CompnentTip` 类绑定（tolua_CEGUI_CEGUI_CompnentTip_new00 等）
- lua_CEGUI.cpp 含 `UpdateEventArgs` 类绑定（tolua_CEGUI_CEGUI_UpdateEventArgs_new00 等）
- lua_CEGUI.cpp 含嵌入 Lua 代码 `toUpdateEventArgs`/`toCompnentTip`（字节序列 85,112,100,97,116,101 = "Update" @ L68862/L68908）
- 13 个嵌入 Lua 代码块

### 8.2 DPI 证据（D1 替代取证）
- **System DPI**: 96 (100%)
- **Window DPI**: 144 (150%)
- **IsProcessDPIAware**: False
- **ProcessDpiAwareness**: 0 (Unaware)
- **物理客户区**: 853x480（= 1280x720 / 1.5，DPI 虚拟化结果）
- **虚拟客户区**（MT3 进程所见）: 1280x720（DPI 虚拟化下的 96 DPI 逻辑坐标）
- **H1 证实**: 进程未声明 DPI-aware，150% 缩放下物理客户区 853x480 ≠ 虚拟 1280x720

### 8.3 CEGUI 显示尺寸证据（D2/D3/D4）
- **D2** (startup_bootstrap.log L130): `renderer.displaySize=1280x720 adapter_logic=1280x720 adapter_display=1280x720`
- **D3** (L131): `post-notifyDisplaySizeChanged renderer.displaySize=1280x720`
- **D4**: CEGUI 新运行日志未落盘（CEGUI_ct.log 0 bytes，CEGUI_history.log 无 02/08 条目），但 D3 已确认最终 displaySize=1280x720
- **runtime-profile.json**: physical/target/display/logic 均为 1280x720, uiScale=1.0, contentScale=1.0
- **H2 证伪**: `notifyDisplaySizeChanged` 已下推，`d_displaySize` = 1280x720（非旧假设的 1024x768）

### 8.4 首帧证据（D5）
- **Frame #1** (L27): `D5 DrawPicture frame#1 mode=1280x720 wait=1` — waiting.jpg (handle=1) 从首帧即绘制
- Frame #2-20 全部: `DrawPicture mode=1280x720 wait=1`
- sp=00000000 全程（视频未创建），但 wait=1（waiting.jpg 有效）
- **H3 证伪**: waiting.jpg 确实进入首帧 GL 绘制路径
- **H4 证伪**: sp=0 未使首帧跳过 present；代码正确 fallthrough 到 DrawPicture 分支

### 8.5 视觉验证
- CopyFromScreen 截图 100% 黑色 — OpenGL 硬件加速内容无法被 GDI 捕获（已知限制）
- PrintWindow(PW_RENDERFULLCONTENT) 截图: 98.5% 非黑色
- PrintWindow(0) 截图: 99.6% 非黑色
- **黑屏已排除**: 窗口有内容（登录背景 + spine 动画），非黑屏

### 8.6 崩溃修复验证
- 进程正常运行，PID=54924，Responding=True
- LuaDebugLog.txt (10:11) 无 SetTipsType/toUpdateEventArgs 错误
- startup_bootstrap.log L206: `LoginQuickDialog.getInstanceAndShow result=0` — 登录对话框成功显示
- 主循环正常: OnTick #1-#600+，spine 渲染 LuaXPRenderEffect/UISpineSprite 持续运行
- **H5 闭环确认**: .pkg 修复 + tolua++ 重新生成 → 绑定就绪 → 无 nil 调用 → 无异常

### 8.7 三项信号核对

| # | 信号 | 结果 | 证据 |
| --- | --- | --- | --- |
| 1 | 窗口客户区与 CEGUI 显示尺寸一致 | ✅ 通过 | 虚拟客户区 1280x720 = CEGUI displaySize 1280x720（DPI 虚拟化下统一缩放，数学等价） |
| 2 | 登录控件中心偏差接近 0 | ⚠️ 部分验证 | CEGUI displaySize 1280x720 = GL viewport 1280x720 = 设计分辨率；DPI 虚拟化为均匀缩放，数学上居中保持。截图显示登录背景内容但无法精确量化控件偏移 |
| 3 | 首帧不依赖空 sp | ✅ 通过 | D5 frame#1: DrawPicture wait=1，sp=0 时正确 fallthrough 到 waiting.jpg 绘制 |

### 8.8 假设状态更新

| 假设 | 状态 | 说明 |
| --- | --- | --- |
| H1 (DPI-aware 缺失) | ✅ 证实 | 进程 DPI-unaware，150% 缩放，物理 853x480 ≠ 虚拟 1280x720 |
| H2 (displaySize 未下推) | ❌ 证伪 | D2/D3 确认 displaySize=1280x720，notifyDisplaySizeChanged 已下推 |
| H3 (waiting.jpg 未进绘制) | ❌ 证伪 | D5 确认 frame#1 即 DrawPicture wait=1 |
| H4 (sp=0 跳过 present) | ❌ 证伪 | sp=0 时代码正确 fallthrough 到 DrawPicture |
| H5 (tolua++ 绑定缺口) | ✅ 闭环 | .pkg 修复 + 重新生成 + 冷启动无异常 |

### 8.9 剩余事项
- **DPI-aware 声明**: H1 证实但当前未阻塞渲染（虚拟坐标链自洽）。若需物理像素精确控制（如截图/鼠标命中），可考虑后续添加 `SetProcessDPIAware` 或 manifest 声明
- **信号 2 精确量化**: 需交互式视觉检查（人工或自动化 UI 比对），当前只能从数学模型确认均匀缩放下居中保持
- **空账号登录点击测试**: 启动阶段无异常，但 "点击登录按钮 → MessageTip 创建" 的交互路径需人工触发确认

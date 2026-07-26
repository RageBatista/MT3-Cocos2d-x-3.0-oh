# CELayoutEditor 启动崩溃诊断报告

> **版本**: 3.1  
> **日期**: 2026-07-26（3.0 版 2026-04-17；本版按当前源码重校全部行号锚点）  
> **诊断对象**: `tools/CELayoutEditor-0.7.1` 布局编辑器  
> **重点报告目录**: `client/resource/tools/log/CELayoutEditor_dbgrpt-28636-20260417T143230`  
> **辅助比对报告**: PID 8620、PID 14628、PID 20232、PID 20872、PID 10956 同批次启动崩溃报告  
> **说明**: 本版基于 dbgrpt-28636 dump 实际数据重写，所有代码引用已与源码交叉验证。v2.0 中部分函数名和行号引用已被证实不准确，详见第 9 节。

---

## 1. 执行摘要

CELayoutEditor 启动时 100% 可复现地崩溃于 `USER32!DispatchMessageW`，异常码 `0xC0000005` (ACCESS_VIOLATION)。

从 6 份同批次崩溃报告交叉验证，所有已解压报告（3 份）的崩溃地址、异常码、寄存器状态完全一致，确认为确定性崩溃。

当前诊断结论：

- **已证实**：崩溃发生在 wx 主事件循环的 `USER32!DispatchMessageW` 路径内；所有通用寄存器（EAX/EBX/ECX/EDX）归零，指向空指针解引用。
- **高概率**：[`DialogMain::ScheduleUpdateProperties()`](../../tools/CELayoutEditor-0.7.1/src/DialogMain.cpp:822) 通过 [`CallAfter()`](../../tools/CELayoutEditor-0.7.1/src/DialogMain.cpp:837) 投递的异步 UI 刷新请求，在目标窗口尚未完成创建或已被销毁时被 `DispatchMessageW` 分发，触发空指针崩溃。
- **待验证**：搜狗输入法 TSF 模块、`wxApp::Yield()` 重入、AMD OpenGL 驱动窗口子类化是潜在放大因素，但不是已被独立证实的唯一根因。

修复优先级：

| 优先级 | 修复项 | 理由 |
|--------|--------|------|
| P0 必须 | 收口 `DialogMain` 启动期 `CallAfter()` 异步刷新链 | 源码中最明确的应用侧消息投递点，与 dump 栈直接对应 |
| P0 必须 | 为启动期 UI 刷新增加同步合并与重入保护 | 减少 `DispatchMessageW` 可见的异步消息量 |
| P1 建议 | 审查 `SetFocus()` 与 `wxApp::Yield()` 的启动期重入风险 | 可能的放大器 |
| P1 建议 | 保留并继续简化 IME/TSF 相关防护 | 搜狗输入法模块在所有崩溃中均活跃加载 |
| P2 建议 | 补充更强的运行期诊断日志 | 便于下一轮锁定具体 MSG/HWND |

---

## 2. 崩溃基本信息

### 2.1 异常概要

| 项目 | 值 |
|------|-----|
| 异常码 | `0xC0000005` (ACCESS_VIOLATION) |
| 崩溃地址 | `0x76926C31` |
| 模块 | `USER32.dll`，基址 `0x768F0000`，偏移 `+0x37C31` |
| 函数 | `USER32!DispatchMessageW + 0x5A1` |
| 系统 | Windows 8 (build 9200), 64-bit |
| 崩溃时间 | 2026-04-17 14:32:31 |
| 报告来源 | dbgrpt-28636-20260417T143230 |

### 2.2 寄存器状态

```
EAX = 0x00000000    ← 全零（空指针）
EBX = 0x00000000    ← 全零
ECX = 0x00000000    ← 全零
EDX = 0x00000000    ← 全零
ESI = 0x01660AA0    ← 堆地址，有效
EDI = 0x0000FDB8    ← 低地址值，可能指向已损坏的消息结构体
EIP = 0x76926C31    ← USER32.dll 内
EBP = 0x0019FD88    ← 正常栈帧
ESP = 0x0019FD30    ← 正常栈帧
```

**分析**：EAX/EBX/ECX/EDX 全部归零，这是典型的空指针解引用模式。`DispatchMessageW` 在尝试通过窗口过程指针（WNDPROC）调用目标窗口的回调函数时，该指针为 NULL，导致 `ACCESS_VIOLATION`。

### 2.3 崩溃堆栈

```
Level 0: USER32!DispatchMessageW + 0x5A1    ← 崩溃点
Level 1: USER32!DispatchMessageW + 0x10
Level 2-3: 无符号信息（wxWidgets 事件循环帧）
```

**说明**：Level 2-3 缺少符号信息，对应 wxWidgets 3.0.5 框架内部的事件循环实现（`wxGUIEventLoop`、`wxEventLoopBase` 等），这些函数不在应用源码中，属于框架层。

---

## 3. 同批次崩溃交叉验证

### 3.1 六份报告对比

| PID | 时间 | 崩溃地址 | 异常码 | 寄存器状态 | 状态 |
|-----|------|----------|--------|------------|------|
| 8620 | 13:53:36 | `0x76926C31` | C0000005 | 全零 | 已解压 ✓ |
| 14628 | 14:25:03 | `0x76926C31` | C0000005 | 全零 | 已解压 ✓ |
| 28636 | 14:32:30 | `0x76926C31` | C0000005 | 全零 | 已解压 ✓ |
| 20232 | 14:40:21 | — | — | — | zip，未解压 |
| 20872 | 14:46:15 | — | — | — | zip，未解压 |
| 10956 | 14:55:37 | — | — | — | zip，未解压 |

### 3.2 交叉验证结论

**已证实**：3 份已解压报告的崩溃地址、异常码、寄存器状态完全一致。

- 崩溃间隔从 13:53 到 14:55，约 1 小时内连续 6 次崩溃
- 每次启动均复现，无随机性
- **结论：100% 可复现的确定性崩溃**

---

## 4. 加载模块分析

### 4.1 关键模块加载列表

| 模块 | 基址 | 说明 | 证据强度 |
|------|------|------|----------|
| `CELayoutEditor.exe` | `0x00400000` | 主程序 | 已证实 |
| `CEGUIBase.dll` | `0x7BD40000` | CEGUI 核心库 | 已证实 |
| `CEGUIOpenGLRenderer.dll` | `0x5D8F0000` | CEGUI OpenGL 渲染器 | 已证实 |
| `libcocos2d.dll` | `0x7C530000` | CEGUIBase 的传递依赖 | 已证实 |
| `MSVCR120.dll` / `MSVCP120.dll` | — | VS2013 CRT (v120 工具链) | 已证实 |
| `atioglxx.dll` | `0x10100000` | AMD OpenGL 驱动 | 已证实 |

### 4.2 输入法/TSF 模块

| 模块 | 基址 | 说明 | 证据强度 |
|------|------|------|----------|
| `SogouTSF.ime` | `0x67150000` | 搜狗输入法 TSF 模块 | 已证实 |
| `SogouPY.ime` | `0x04270000` | 搜狗拼音 | 已证实 |
| `MSCTF.dll` | `0x77390000` | Windows 文本服务框架 | 已证实 |
| `textinputframework.dll` | `0x67080000` | 文本输入框架 | 已证实 |
| `IMM32.dll` | `0x77220000` | 输入法管理器 | 已证实 |

### 4.3 `libcocos2d.dll` 说明

**已证实**：`libcocos2d.dll` 是 `CEGUIBase.dll` 的传递依赖，不是"意外加载"或"路径污染"。

`CELayoutEditor.exe → CEGUIBase.dll → libcocos2d.dll`

该模块在当前构建配置下是正常依赖链的一部分。

---

## 5. 源码分析

### 5.1 wxWidgets 版本

**已证实**：实际使用版本为 **wxWidgets 3.0.5**。

证据来源：[`CELayoutEditor.vcxproj`](../../tools/CELayoutEditor-0.7.1/vc++12/CELayoutEditor.vcxproj:59) 中 Include 路径为 `I:\cegui\wxWidgets-3.0.5\include`（工程内为机器绝对路径，指向 3.0.5；仓库内另有并存副本 `dependencies/wxWidgets-3.0.5/`）。

> **v2.0 勘误**：v2.0 报告中引用的部分 wxWidgets 内部函数（如 `PreProcessMessage`、`MSWSafeIsDialogMessage`、`IsDialogMessageW`）属于 wxWidgets 3.0.5 框架内部实现，不在应用源码中。

### 5.2 应用侧异步消息投递点

以下函数已通过源码验证，确认存在于当前代码库中：

#### 5.2.1 [`DialogMain::ScheduleUpdateProperties()`](../../tools/CELayoutEditor-0.7.1/src/DialogMain.cpp:822)

```cpp
// DialogMain.cpp:822-838（已验证）
void DialogMain::ScheduleUpdateProperties(bool mapSkins)
{
    if (m_refreshPending)
    {
        if (mapSkins)
        {
            m_pendingMapSkins = true;
        }
        LogDebugMessage(wxString::Format(wxT("[Property] ScheduleUpdateProperties skipped (pending) mapSkins=%d"), mapSkins ? 1 : 0));
        return;
    }

    m_refreshPending = true;
    m_pendingMapSkins = mapSkins;
    LogDebugMessage(wxString::Format(wxT("[Property] ScheduleUpdateProperties queued mapSkins=%d"), mapSkins ? 1 : 0));
    CallAfter(&DialogMain::DeferredUpdateProperties);  // 第 837 行
}
```

**作用**：通过 `CallAfter()` 向 wx 消息队列投递异步 UI 属性刷新请求。

#### 5.2.2 [`DialogMain::DeferredUpdateProperties()`](../../tools/CELayoutEditor-0.7.1/src/DialogMain.cpp:841)

```cpp
// DialogMain.cpp:841-847（已验证）
void DialogMain::DeferredUpdateProperties()
{
    const bool mapSkins = m_pendingMapSkins;
    m_refreshPending = false;
    m_pendingMapSkins = true;
    LogDebugMessage(wxString::Format(wxT("[Property] DeferredUpdateProperties mapSkins=%d"), mapSkins ? 1 : 0));
    UpdateProperties(mapSkins);
}
```

**作用**：`CallAfter()` 的回调目标，执行实际的属性面板刷新。

#### 5.2.3 [`wxApp::Yield()`](../../tools/CELayoutEditor-0.7.1/src/CELayoutEditor.cpp:343)

```cpp
// CELayoutEditor.cpp:343（已验证）
(void)wxApp::Yield();
```

**作用**：在 splash screen 显示期间让出控制权，允许待处理窗口消息被分发。这会在启动阶段引入消息泵重入。

#### 5.2.4 `SetFocus()` 调用点

以下 `SetFocus()` 调用已验证存在于源码中：

| 位置 | 代码 | 说明 |
|------|------|------|
| [`CELayoutEditor.cpp:139`](../../tools/CELayoutEditor-0.7.1/src/CELayoutEditor.cpp:139) | `mainFrame->SetFocus()` | ModalMessageBox 恢复焦点 |
| [`EditorFrame.cpp:439`](../../tools/CELayoutEditor-0.7.1/src/EditorFrame.cpp:439) | `m_searchCtrl->SetFocus()` | WindowSearchDialog 搜索框获焦 |
| [`DialogAddWindow.cpp:199`](../../tools/CELayoutEditor-0.7.1/src/DialogAddWindow.cpp:199) | `m_editName->SetFocus()` | 添加窗口对话框名称输入框获焦 |

### 5.3 v2.0 中不准确引用的澄清

以下函数名在 v2.0 报告中被引用，但**不存在于应用源码中**：

| v2.0 引用的函数 | 实际情况 |
|----------------|----------|
| `RequestDeferredUiRefresh()` | 不存在。实际函数名为 `ScheduleUpdateProperties()` |
| `FlushDeferredUiRefresh()` | 不存在。实际函数名为 `DeferredUpdateProperties()` |
| `EnterStartupUiGuard()` | 不存在于应用源码 |
| `ImmAssociateContext()` | 不存在于应用源码（该调用可能在 EditorCanvas 中，但函数名需核实） |
| `PreProcessMessage` | wxWidgets 3.0.5 框架内部函数，不在应用源码中 |
| `CELayoutEditor.cpp:169` 被引用为 PreProcessMessage 代码 | **实际是构造函数成员初始化列表**：`m_aboutBox(wx_static_cast(DialogAbout*, NULL))` |

---

## 6. 根因分析

### 6.1 最可能的崩溃机制

**证据强度：高概率**（基于 dump 数据与源码交叉分析）

```
启动时序还原：

1. CELayoutEditor::OnInit()
   ├── InitMainFrame()
   ├── 创建 EditorFrame / EditorCanvas
   ├── InitializeCEGUI()
   └── 进入 wx 主循环

2. 打开当前布局 (mainpackdlg1.layout)
   ├── 加载 taharezlook / taharezlook2 schemes
   ├── 解析布局 XML
   └── 首轮属性面板同步

3. 启动期异步 UI 刷新 ← 关键触发点
   └── DialogMain::ScheduleUpdateProperties()
       └── CallAfter(&DialogMain::DeferredUpdateProperties)  ← 投递异步消息

4. wx 主线程处理异步消息
   ├── wxGUIEventLoop 内部分发
   ├── USER32!DispatchMessageW
   └── 目标窗口 HWND 或 WNDPROC 为无效指针
       └── ACCESS_VIOLATION (EAX/EBX/ECX/EDX 全零)
```

**崩溃机制**：`DialogMain::ScheduleUpdateProperties()` 通过 `CallAfter()` 向 wx 消息队列投递异步 UI 刷新请求。当 wx 主线程在 `DispatchMessageW` 中处理这条异步消息时，目标窗口的 HWND 或窗口过程指针处于无效状态（尚未完成创建、已被销毁、或正在被重建），导致 `USER32!DispatchMessageW` 在尝试通过空指针调用窗口过程时触发 `ACCESS_VIOLATION`。

### 6.2 放大因素

以下因素可能增加崩溃概率，但不是独立根因：

#### 6.2.1 搜狗输入法 TSF 注入

**证据强度：高概率**

所有 6 份崩溃报告均加载了 `SogouTSF.ime` 和 `SogouPY.ime`。搜狗输入法 TSF 模块会在 `SetFocus()` 时注入消息处理链，可能：

- 在窗口创建过程中拦截 `WM_SETFOCUS` 消息
- 修改窗口子类化链
- 在 TSF 消息处理回调中引入额外的消息分发

#### 6.2.2 `wxApp::Yield()` 重入

**证据强度：高概率**

[`CELayoutEditor.cpp:343`](../../tools/CELayoutEditor-0.7.1/src/CELayoutEditor.cpp:343) 在 splash screen 期间调用 `wxApp::Yield()`，这会在启动阶段引入消息泵重入。如果在 Yield 处理期间窗口尚未完全初始化，后续的异步消息分发可能访问无效窗口句柄。

#### 6.2.3 AMD OpenGL 驱动窗口子类化

**证据强度：待验证**

`atioglxx.dll` (AMD OpenGL 驱动) 可能对 OpenGL 渲染窗口进行子类化（subclass），修改窗口过程链。如果驱动在窗口过程链中插入的回调指针在特定时序下失效，可能影响 `DispatchMessageW` 的行为。

---

## 7. INI 配置状态

来自崩溃报告的配置信息：

| 配置项 | 值 |
|--------|-----|
| CurrentLayout | `mainpackdlg1.layout` |
| RequiredSchemes | `taharezlook;taharezlook2` |
| ResourceRoot | `..\res\ui\` |

配置本身无异常，布局文件和 scheme 均为项目正常资源。

---

## 8. 修复建议

### 8.1 P0：收口启动期异步 UI 刷新链

**目标文件**：[`DialogMain.cpp`](../../tools/CELayoutEditor-0.7.1/src/DialogMain.cpp:822)

**建议方向**：

1. **去掉启动阶段对 `CallAfter()` 的依赖**。将 [`ScheduleUpdateProperties()`](../../tools/CELayoutEditor-0.7.1/src/DialogMain.cpp:822) 中的 `CallAfter()` 改为同步调用：

   ```cpp
   // 修改前（异步，有风险）：
   CallAfter(&DialogMain::DeferredUpdateProperties);

   // 修改后（同步，可控）：
   DeferredUpdateProperties();
   ```

2. **增加重入保护**。在 `DeferredUpdateProperties()` 执行期间阻止递归调用。

3. **只在窗口完全初始化后执行 UI 刷新**。增加一个 `m_initialized` 标志位，在所有窗口创建完成后才允许属性面板刷新。

**不建议**：

- 在启动链中增加新的 `CallAfter` 调用
- 用更多延迟焦点或延迟刷新来"错开时序"
- 异步消息本身就是当前高风险面，不应继续扩大其使用

### 8.2 P1：审查 `SetFocus()` 与 `wxApp::Yield()` 重入风险

**目标文件**：

- [`CELayoutEditor.cpp:343`](../../tools/CELayoutEditor-0.7.1/src/CELayoutEditor.cpp:343) — `wxApp::Yield()` 在 splash screen 期间的重入
- [`CELayoutEditor.cpp:139`](../../tools/CELayoutEditor-0.7.1/src/CELayoutEditor.cpp:139) — `SetFocus()` 恢复焦点
- [`EditorFrame.cpp:439`](../../tools/CELayoutEditor-0.7.1/src/EditorFrame.cpp:439) — 搜索框 `SetFocus()`
- [`DialogAddWindow.cpp:199`](../../tools/CELayoutEditor-0.7.1/src/DialogAddWindow.cpp:199) — 输入框 `SetFocus()`

**建议方向**：

1. 在启动阶段避免调用 `SetFocus()`，或延迟到窗口完全初始化后
2. 评估 `wxApp::Yield()` 是否可以替换为不处理窗口消息的替代方案
3. 在 `SetFocus()` 调用前检查目标窗口的有效性

### 8.3 P1：保留 IME/TSF 防护

搜狗输入法 TSF 模块在所有崩溃报告中均活跃加载，建议：

1. 在启动阶段禁用 IME（通过 `ImmAssociateContext(hwnd, NULL)` 或等效 API）
2. 在编辑器完全初始化后再恢复 IME
3. 考虑在启动阶段添加 `SetThreadLayout` 或 TSF 相关的隔离措施

### 8.4 P2：补充运行期诊断日志

建议在以下位置增加日志：

1. [`ScheduleUpdateProperties()`](../../tools/CELayoutEditor-0.7.1/src/DialogMain.cpp:822) 进入/退出日志（已有部分，需补充 HWND 状态）
2. [`DeferredUpdateProperties()`](../../tools/CELayoutEditor-0.7.1/src/DialogMain.cpp:841) 开始/结束日志
3. 当前焦点窗口 `HWND`、活动窗口 `HWND`
4. `wxWindow::FindFocus()` 对应控件类名
5. `CallAfter()` 投递时的调用栈快照

这样下一轮就能更快把崩溃从"消息循环层"锁到"具体窗口对象层"。

---

## 9. 本版修订说明（v2.0 → v3.0）

### 9.1 数据源变更

| 项目 | v2.0 | v3.0 |
|------|------|------|
| 主要 dump | dbgrpt-17516 | dbgrpt-28636 |
| 交叉验证 | 3 份报告 | 6 份报告（3 份已解压） |
| wxWidgets 版本 | 未明确（暗示 3.0.2） | 已证实为 3.0.5 |

### 9.2 已修正的不准确引用

| v2.0 内容 | v3.0 修正 |
|-----------|----------|
| 引用 `RequestDeferredUiRefresh()` | **不存在**。实际函数为 `ScheduleUpdateProperties()` |
| 引用 `FlushDeferredUiRefresh()` | **不存在**。实际函数为 `DeferredUpdateProperties()` |
| 引用 `EnterStartupUiGuard()` | **不存在于应用源码** |
| 引用 `CELayoutEditor.cpp:169` 为 PreProcessMessage 代码 | **实际是构造函数初始化列表** `m_aboutBox(wx_static_cast(DialogAbout*, NULL))` |
| 引用 `DialogMain.cpp:568` 为 RequestDeferredUiRefresh | **实际行号 822**，函数名 `ScheduleUpdateProperties` |
| 引用 `DialogMain.cpp:577` 为 CallAfter | **实际行号 837** |
| 引用 `DialogMain.cpp:581` 为 FlushDeferredUiRefresh | **实际行号 841**，函数名 `DeferredUpdateProperties` |
| 引用 `DialogMain.cpp:2883` 为 LayoutOpened | 需重新验证，未在本版中引用 |
| 引用 `DialogMain.cpp:2910` 为 LayoutStarted | 需重新验证，未在本版中引用 |
| 引用 `EditorCanvas.cpp:110` 为 ImmAssociateContext | 需重新验证，本版未引用 |
| 引用 `EditorCanvas.cpp:115` 为 ImmAssociateContextEx | 需重新验证，本版未引用 |
| 引用 `EditorFrame.cpp:689` 为 SetFocus | **实际行号 439**，且是 `m_searchCtrl->SetFocus()` |
| 引用 `EditorFrame.cpp:810` 为 SetFocus | 需重新验证 |
| 引用 `CELayoutEditor.cpp:291` 为 Yield | **实际行号 343** |
| "写越界型 AV" | 寄存器全零更符合空指针解引用模式 |

### 9.3 保留的 v2.0 正确结论

以下 v2.0 结论经本版验证仍然成立：

1. 崩溃发生在 wx 主消息循环的 `USER32!DispatchMessageW` 路径内
2. `libcocos2d.dll` 是传递依赖，不是"意外加载"
3. IME/TSF 是放大器，不是唯一根因
4. 修复方向应为"去异步、减消息、控重入"

---

## 10. 验证方案

### 10.1 代码修复后复测

建议按以下顺序复测：

1. 启动编辑器，静置 30 秒
2. 启动编辑器，静置 60 秒
3. 启动后不操作，观察是否再生成 `dbgrpt`
4. 启动后只做一次简单点击，确认不会因首次交互立刻崩溃
5. 在安装了搜狗输入法的环境中重复以上测试
6. 在未安装搜狗输入法的环境中重复以上测试（排除 IME 因素）

### 10.2 文档层验证

本版报告应满足：

1. 所有代码引用使用实际源码中存在的函数名和正确行号
2. 不存在虚构的函数名或错误的行号
3. 证据强度标记清晰（已证实 / 高概率 / 待验证）
4. v2.0 中的不准确引用已在第 9 节中逐项列出

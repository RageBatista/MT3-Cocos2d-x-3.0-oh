# 01 — 架构设计（Architecture Design）

> **版本**: 1.0.0  
> **更新日期**: 2026-04-25  
> **源码路径**: `tools/engine/npceditor/`

---

## 1. 系统概述

NPC 编辑器（内部工程名称 **MazeAndNpcEditor**，代码中称为 **SoundEditor**）是 MT3 项目工具链中的地图迷宫与 NPC 编辑工具。其主要功能包括：

- 编辑地图迷宫阻挡（maze buffer）
- 放置和编辑 NPC 实例
- 管理地图跳转点（goto point）
- 设置区域类型（切磋/播撒/摆摊/刷怪等）
- 管理怪物分布数据
- 孤岛检测与信息保存
- 轻功飞跃阻挡编辑
- 环境音区域编辑
- 测试模式（角色行走测试）

---

## 2. 整体架构模式

### 2.1 MFC SDI Doc/View 架构

应用基于 **MFC SDI（单文档界面）Doc/View** 架构构建，同时嵌入 Nuclear 引擎进行地图渲染。

| 架构角色 | 类 | 定义位置 | 说明 |
|----------|-----|----------|------|
| 应用类 | [`CSoundEditorApp`](../SoundEditor.h:18) | `SoundEditor.h:18` | 继承 `CWinApp`，初始化 PFS 文件系统、路径映射 |
| 文档类 | [`CSoundEditorDoc`](../SoundEditorDoc.h:40) | `SoundEditorDoc.h:40` | 继承 `CDocument`，管理编辑状态、地图尺寸、XML 序列化 |
| 主框架 | [`CMainFrame`](../MainFrm.h:7) | `MainFrm.h:7` | 继承 `CFrameWnd`，使用 `CSplitterWnd` 分左右两栏 |
| 主视图 | [`CSoundEditorView`](../SoundEditorView.h:7) | `SoundEditorView.h:7` | 继承 `CView`，左栏视图，内嵌 `CMainDlg` |
| 属性视图 | [`CPropView`](../PropView.h:7) | `PropView.h:7` | 继承 `CView`，右栏视图，内嵌 `CTabPropPanel` |

### 2.2 引擎嵌入方式

[`CMainDlg`](../MainDlg.h:15)（定义在 `MainDlg.h:15`）作为 Nuclear 引擎的宿主对话框嵌入 MFC 视图体系中。其内部持有 [`SoundApp`](../SoundApp.h:75)（继承 `Nuclear::IApp`，定义在 `SoundApp.h:75`）实例，通过 `Nuclear::IApp` 回调接口驱动引擎渲染循环。

```
┌─────────────────────────────────────────────────────────────────┐
│                        CSoundEditorApp                          │
│                    (CWinApp, MFC 应用入口)                       │
│   InitInstance(): 初始化 PFS、路径映射、DocTemplate              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ 创建
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                          CMainFrame                             │
│              (CFrameWnd, SDI 主框架, MainFrm.h:7)               │
│                                                                 │
│  ┌─── CSplitterWnd ─────────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌──────────────────────┐  ┌───────────────────────────┐ │  │
│  │  │  CSoundEditorView    │  │     CPropView             │ │  │
│  │  │  (SoundEditorView:7) │  │     (PropView.h:7)        │ │  │
│  │  │                      │  │                           │ │  │
│  │  │  ┌────────────────┐  │  │  ┌─────────────────────┐  │ │  │
│  │  │  │   CMainDlg     │  │  │  │  CTabPropPanel      │  │ │  │
│  │  │  │  (MainDlg.h:15)│  │  │  │ (TabPropPanel.h:11) │  │ │  │
│  │  │  │                │  │  │  │                     │  │ │  │
│  │  │  │  ┌──────────┐  │  │  │  │ ├ CMiniMapPanel    │  │ │  │
│  │  │  │  │ SoundApp │  │  │  │  │ ├ CNpcPropertyDlg  │  │ │  │
│  │  │  │  │(SoundApp │  │  │  │  │ │   └ CAddNpcDlg   │  │ │  │
│  │  │  │  │  .h:75)  │  │  │  │  │ ├ CJumpPointInfDlg │  │ │  │
│  │  │  │  │    │     │  │  │  │  │ └ CMonsterPanel    │  │ │  │
│  │  │  │  │    ▼     │  │  │  │  │                     │  │ │  │
│  │  │  │  │Nuclear:: │  │  │  │  └─────────────────────┘  │ │  │
│  │  │  │  │ IEngine  │  │  │  │                           │ │  │
│  │  │  │  └──────────┘  │  │  └───────────────────────────┘ │  │
│  │  │  └────────────────┘  │                                  │  │
│  │  └──────────────────────┘  ┌───────────────────────────┐  │  │
│  │                            │     CPropView             │ │  │
│  └────────────────────────────┴───────────────────────────┘  │  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. 进程/线程模型

- **单进程单线程**（MFC 主线程）
- Nuclear 引擎通过定时器（**25ms 间隔**）在主线程中调用 `m_pEngine->OnIdle()` 驱动渲染循环
- 引擎初始化时使用 `Nuclear::EngineParameter::bAsyncRead = true` 启用异步文件读取（引擎内部线程）

### 3.1 渲染循环时序

```
MFC 主线程
  │
  ├─ OnTimer(1000) [25ms 周期]
  │    └─ Nuclear::IEngine::OnIdle()
  │         ├─ SoundApp::OnBeforeRender(now) → return true
  │         ├─ Nuclear 引擎内部渲染
  │         └─ SoundApp::OnRenderUI(now)
  │              ├─ 绘制网格线
  │              ├─ 绘制阻挡区域
  │              ├─ 绘制区域类型
  │              ├─ 绘制 NPC 选择框 + 名字
  │              └─ 绘制跳转点标志
  │
  ├─ MFC 消息处理 (鼠标/键盘/命令)
  │    └─ CMainDlg::WindowProc() → Nuclear::IEngine::OnWindowsMessage()
  │
  └─ MFC 空闲处理
```

---

## 4. 模块划分

### 4.1 模块总表

| 模块 | 文件 | 职责 |
|------|------|------|
| 应用入口 | [`SoundEditor.h`](../SoundEditor.h) / [`SoundEditor.cpp`](../SoundEditor.cpp) | `CSoundEditorApp` — MFC 应用类，初始化 PFS 文件系统、路径映射 |
| 文档 | [`SoundEditorDoc.h`](../SoundEditorDoc.h) / [`SoundEditorDoc.cpp`](../SoundEditorDoc.cpp) | `CSoundEditorDoc` — 管理编辑状态（迷宫/NPC/跳转点/测试）、地图尺寸、XML 序列化 |
| 主框架 | [`MainFrm.h`](../MainFrm.h) / [`MainFrm.cpp`](../MainFrm.cpp) | `CMainFrame` — SDI 框架，管理工具栏、状态栏、`CSplitterWnd` 分栏 |
| 主视图 | [`SoundEditorView.h`](../SoundEditorView.h) / [`SoundEditorView.cpp`](../SoundEditorView.cpp) | `CSoundEditorView` — 左栏视图，内嵌 `CMainDlg`，转发工具栏命令 |
| 属性视图 | [`PropView.h`](../PropView.h) / [`PropView.cpp`](../PropView.cpp) | `CPropView` — 右栏视图，内嵌 `CTabPropPanel` |
| 主对话框（引擎宿主） | [`MainDlg.h`](../MainDlg.h) / [`MainDlg.cpp`](../MainDlg.cpp) | `CMainDlg` — 嵌入 Nuclear 引擎，处理鼠标/键盘事件，驱动地图编辑操作 |
| 引擎应用层 | [`SoundApp.h`](../SoundApp.h) / [`SoundApp.cpp`](../SoundApp.cpp) | `SoundApp` — `Nuclear::IApp` 实现，管理精灵、NPC、迷宫缓冲、区域、跳转点、怪物等全部编辑数据 |
| 精灵包装 | [`Sprite.h`](../Sprite.h) / [`Sprite.cpp`](../Sprite.cpp) | `Sprite` — 对 `Nuclear::ISprite` 的包装，管理动作状态（站立/跑/骑马） |
| NPC 实体 | [`Npc.h`](../Npc.h) / [`Npc.cpp`](../Npc.cpp) | `CNpc` — 继承 `Sprite`，关联 `stNpcBaseData` 基础数据 |
| NPC 属性面板 | [`NpcPropertyDlg.h`](../NpcPropertyDlg.h) / [`NpcPropertyDlg.cpp`](../NpcPropertyDlg.cpp) | `CNpcPropertyDlg` — NPC 属性编辑对话框 |
| 添加 NPC 对话框 | [`AddNpcDlg.h`](../AddNpcDlg.h) / [`AddNpcDlg.cpp`](../AddNpcDlg.cpp) | `CAddNpcDlg` — 从基础 NPC 列表选择添加 |
| 跳转点面板 | [`JumpPointInfDlg.h`](../JumpPointInfDlg.h) / [`JumpPointInfDlg.cpp`](../JumpPointInfDlg.cpp) | `CJumpPointInfDlg` — 地图跳转点信息编辑 |
| 怪物面板 | [`CMonsterPanel.h`](../CMonsterPanel.h) / [`CMonsterPanel.cpp`](../CMonsterPanel.cpp) | `CMonsterPanel` — 怪物区域类型选择 |
| Tab 属性面板 | [`TabPropPanel.h`](../TabPropPanel.h) / [`TabPropPanel.cpp`](../TabPropPanel.cpp) | `CTabPropPanel` — 右栏 Tab 控件，管理环境音/NPC/跳转点/测试/怪物五个 Tab 页 |
| 小地图面板 | [`MiniMapPanel.h`](../MiniMapPanel.h) / [`MiniMapPanel.cpp`](../MiniMapPanel.cpp) | `CMiniMapPanel` — 缩略图面板（含缩放滑块） |
| 区域缓冲模板 | [`regionbuffer.h`](../regionbuffer.h) | `CRegionBuffer<T>` — 稀疏区域数据存储，支持序列化 |
| 数据结构 | [`Npc.h`](../Npc.h) `stNpcBaseData`、[`Monster.h`](../Monster.h) `stMonsterBaseData` | NPC/怪物基础数据结构 |

### 4.2 内部模块依赖关系图

```
CSoundEditorApp → CMainFrame → CSplitterWnd
                                  ├→ CSoundEditorView → CMainDlg → SoundApp → Nuclear::IEngine
                                  └→ CPropView → CTabPropPanel
                                                    ├→ CMiniMapPanel
                                                    ├→ CNpcPropertyDlg → CAddNpcDlg
                                                    ├→ CJumpPointInfDlg
                                                    └→ CMonsterPanel
```

**依赖说明：**

- `CSoundEditorApp` 创建 `CMainFrame`，通过 `CSingleDocTemplate` 关联 Document/View
- `CMainFrame` 使用 `CSplitterWnd`（[`m_VSplitterWindow`](../MainFrm.h:17)）分为左右两栏
- `CSoundEditorView` 内嵌 [`CMainDlg m_mainDlg`](../SoundEditorView.h:19)，后者持有 [`SoundApp m_soundApp`](../MainDlg.h:61)
- `CPropView` 内嵌 [`CTabPropPanel m_tabPropPanel`](../PropView.h:21)，后者管理所有属性面板
- `SoundApp` 持有 [`CSoundEditorDoc* m_pDoc`](../SoundApp.h:89) 反向引用文档类

---

## 5. 外部库依赖

### 5.1 外部库依赖表

| 库 | 用途 | 头文件引用 |
|----|------|-----------|
| MFC | GUI 框架 | `afxwin.h`, `afxext.h`, `afxcmn.h` |
| Nuclear 引擎 | 渲染、精灵、地图、特效 | `engine/iengine.h`, `engine/isprite.h`, `engine/ieffect.h`, `engine/renderer/ifontmanager.h` |
| XMLIO | XML 读写 | `xmlio/xmlio.h` |
| Nuclear 工具库 | 序列化、坐标转换、文件 I/O | `engine/common/util.h`, `engine/common/xmarshal.h`, `engine/common/pobject.h`, `engine/common/worldlogiccoord.h`, `engine/common/pfsutil.h` |
| Nuclear 路径地图 | PFS 路径映射 | `engine/map/ppathmap.h` |

### 5.2 资源文件依赖

| 资源文件 | 用途 |
|----------|------|
| [`SoundEditor.rc`](../SoundEditor.rc) | 对话框模板、工具栏、图标资源定义 |
| [`resource.h`](../resource.h) | 控件 ID 和命令 ID 定义 |
| `res/SoundEditor.ico` | 应用图标 |
| `res/Toolbar.bmp` | 主工具栏位图 |
| `res/toolbar1.bmp` | 编辑器工具栏位图 |
| `res/ls.png` | 区域渲染用的 PNG 资源（`IDR_PNG_AREA`） |

---

## 6. 视图布局

### 6.1 分栏结构

使用 [`CSplitterWnd`](../MainFrm.h:17) 将窗口分为左右两栏：

```
┌─────────────────────────────────────────────────────────────────┐
│  主工具栏 (m_wndToolBar)                                        │
│  编辑工具栏 (m_wndEditorToolBar)                                │
├────────────────────────────────┬────────────────────────────────┤
│                                │                                │
│     左栏（渲染区）              │     右栏（属性面板）            │
│                                │                                │
│  CSoundEditorView              │  CPropView                     │
│  └─ CMainDlg                   │  └─ CTabPropPanel              │
│     └─ Nuclear 引擎渲染区      │     ├─ Tab 0: 小地图           │
│                                │     ├─ Tab 1: 环境音           │
│                                │     ├─ Tab 2: NPC 属性         │
│                                │     ├─ Tab 3: 跳转点           │
│                                │     ├─ Tab 4: 测试             │
│                                │     └─ Tab 5: 怪物             │
│                                │                                │
├────────────────────────────────┴────────────────────────────────┤
│  状态栏 (m_wndStatusBar)                                        │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 分栏实现

- 垂直分割：[`m_VSplitterWindow`](../MainFrm.h:17) — 主分割窗口
- 水平分割：[`m_HSplitterWindow`](../MainFrm.h:25) — 辅助分割窗口
- 分割在 [`CMainFrame::OnCreateClient()`](../MainFrm.h:35) 中创建

---

## 7. 编辑状态枚举

### 7.1 EDIT_STATE

定义在 [`SoundEditorDoc.h:8`](../SoundEditorDoc.h:8)：

```cpp
enum EDIT_STATE 
{
    EDIT_STATE_MAZE = 0,    // 编辑阻挡点
    EDIT_STATE_NPC  = 1,    // 编辑 NPC
    EDIT_STATE_MapJump = 2, // 地图跳转点编辑
    EDIT_STATE_TESTING     // 测试模式
};
```

### 7.2 UPDATE_VIEW_SIGN

定义在 [`SoundEditorDoc.h:31`](../SoundEditorDoc.h:31)：

```cpp
enum UPDATE_VIEW_SIGN
{
    UVS_TAB                      = 1,
    UVS_VIEWPORT                 = 2,
    UVS_ENV_SOUND_AREA_SELECTED  = 4,
    UVS_ENV_SOUND_AREA_SHAPE     = 8,
    UVS_ALL                      = 0xFFFFFFFF,
};
```

### 7.3 SELECT_STATE

定义在 [`SoundEditorDoc.h:15`](../SoundEditorDoc.h:15)：

```cpp
enum SELECT_STATE
{
    SS_SELECTED          = 0,  // 已经被选中了的
    SS_SELECTED_AREA_POINT,    // 已经选中了的区域的一个点
    SS_NEWSELECTED,            // 选中了个新的
    SS_ENPTY,                  // 选了个空地方
};
```

### 7.4 POLYGON_MOUSE_STATE

定义在 [`SoundEditorDoc.h:23`](../SoundEditorDoc.h:23)：

```cpp
enum POLYGON_MOUSE_STATE
{
    PMS_NORMAL       = 0,
    PMS_DRAGGING,
    PMS_MOVING_POINT,
    PMS_CUTTING
};
```

---

## 8. 工具状态枚举（TOOLS_STATE）

定义在 [`MainDlg.h:27`](../MainDlg.h:27)，共 27 种工具状态：

```cpp
enum TOOLS_STATE
{
    TS_MOVE          = 0,   // 移动视图
    TS_SELECT,              // 选择
    TS_PUTNPC,              // 放置 NPC
    TS_SETBLOCK,            // 阻挡
    TS_QIEZUO,              // 切磋区域
    TS_BOSA,                // 播撒区域
    TS_BAITAN,              // 摆摊区域
    TS_DUST,                // 尘土区域
    TS_GRASS,               // 草地区域
    TS_WATER,               // 水域区域
    TS_KITE,                // 风筝区域
    TS_SHUAGUAI      = 11,  // 刷怪区域
    TS_MINGSHENG,           // 名胜区域
    TS_QINHGONG1,           // 轻功飞跃阻挡 1 阶
    TS_QINHGONG2,           // 轻功飞跃阻挡 2 阶
    TS_QINHGONG3,           // 轻功飞跃阻挡 3 阶
    TS_QINHGONG4,           // 轻功飞跃阻挡 4 阶
    TS_GUDAO,               // 孤岛检测（1 层）
    TS_AREA11,              // 区域 11
    TS_AREA12,              // 区域 12
    TS_AREA13,              // 区域 13
    TS_AREA14,              // 区域 14
    TS_AREA15,              // 区域 15
    TS_AREA16,              // 区域 16
    TS_SETBLOCK2,           // 2 层阻挡
    TS_GUDAO2,              // 孤岛检测（2 层）
    TS_GAOJISHUGUAI,        // 高级刷怪区域
};
```

---

## 9. 区域类型枚举（RegionType）

定义在 [`SoundApp.h:47`](../SoundApp.h:47)：

```cpp
enum RegionType {
    RY_QIEZUO       = 0x1,     // 切磋
    RY_BOSA         = 0x2,     // 播撒
    RY_BAITAN       = 0x4,     // 摆摊
    RY_KITE         = 0x8,     // 风筝
    RY_SHUAGUAI     = 0x10,    // 刷怪
    RY_MINGSHENG    = 0x20,    // 名胜区
    RY_GAOJISHUGUAI = 0x40,    // 高级刷怪区
    RY_AREA11       = 1 << 10, // 区域 11
    RY_AREA12       = 1 << 11, // 区域 12
    RY_AREA13       = 1 << 12, // 区域 13
    RY_AREA14       = 1 << 13, // 区域 14
    RY_AREA15       = 1 << 14, // 区域 15
    RY_AREA16       = 1 << 15, // 区域 16
};
```

---

## 10. 轻功阻挡类型枚举（QingGongBlockType）

定义在 [`SoundApp.h:64`](../SoundApp.h:64)：

```cpp
enum QingGongBlockType {
    QG_1 = 0x1,   // 飞跃阻挡 1 阶
    QG_2 = 0x2,   // 飞跃阻挡 2 阶
    QG_3 = 0x4,   // 飞跃阻挡 3 阶
    QG_4 = 0x8    // 飞跃阻挡 4 阶
};
```

---

## 11. NPC 类型枚举（enumNpcType）

定义在 [`Npc.h:5`](../Npc.h:5)：

```cpp
enum enumNpcType
{
    eNpcTypeNone       = 0,  // 无
    eNpcTypeImportant,       // 重要
    eNpcTypeTranslate,       // 传送
    eNpcTypeTrade,           // 商业
    eNpcTypeNormal,          // 普通
    eNpcTypeMax,
};
```

---

## 12. 关键常量

| 常量 | 值 | 定义位置 | 说明 |
|------|-----|----------|------|
| [`GRID_WIDTH`](../SoundApp.h:18) | `24` | `SoundApp.h:18` | 网格宽度（像素） |
| [`GRID_HEIGHT`](../SoundApp.h:19) | `16` | `SoundApp.h:19` | 网格高度（像素） |
| [`s_BlockLayer2Mask`](../SoundApp.h:72) | `0x08` | `SoundApp.h:72` | 二层阻挡掩码 |
| [`s_iJumPointGridNum`](../SoundApp.h:285) | `5` | `SoundApp.h:285` | 跳转点占的格子数 N×N |
| [`s_iJumpPointOffset_X`](../SoundApp.h:286) | `1` | `SoundApp.h:286` | 跳转区域中心 X 偏移 |
| [`s_iJumpPointOffset_Y`](../SoundApp.h:287) | `0` | `SoundApp.h:287` | 跳转区域中心 Y 偏移 |

---

## 13. 区域渲染颜色表

定义在 [`SoundApp.h:37`](../SoundApp.h:37)：

```cpp
const DWORD freeAreaColor[6] = {
    0x3FFF0000,   // 红色半透明
    0x3F00FF00,   // 绿色半透明
    0x3F0000FF,   // 蓝色半透明
    0x3FFF8F00,   // 橙色半透明
    0x3FFF8FFF,   // 粉色半透明
    0x3F8FFF8F,   // 浅绿半透明
};
```

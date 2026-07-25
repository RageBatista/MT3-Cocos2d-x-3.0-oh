# MapEditor 深度分析报告

> **历史边界（2026-07-23）**：本文保留 2026-04 阶段的分析和方案记录，不再作为当前实现基线。高清 Tile 旁路、`textureFilter`、Alpha Bleed、`/smoketest` 及部分构建结论未在当前源码中存在；最新源码链、优化内容和验证证据见 [MapEditor 当前实现与优化报告](MapEditor-当前实现与优化报告-20260723.md)。

> **版本**: 1.0.0 | **分析日期**: 2026-04-24 | **分析范围**: `tools/engine/MapEditor/`

---

## 目录

1. [代码结构与功能分析](#1-代码结构与功能分析)
2. [核心模块功能实现与关键入口](#2-核心模块功能实现与关键入口)
3. [主要数据结构与类层次](#3-主要数据结构与类层次)
4. [功能调用流程与业务逻辑](#4-功能调用流程与业务逻辑)
5. [当前代码状态裁决](#5-当前代码状态裁决)
6. [潜在 Bug 清单（初始审查）](#6-潜在-bug-清单初始审查)
7. [整体代码质量评估与优化方向（初始版本）](#7-整体代码质量评估与优化方向初始版本)
8. [资深测试与架构复核修订版](#8-资深测试与架构复核修订版)
9. [P0-P2 修复执行记录](#9-p0-p2-修复执行记录)
10. [地图清晰度优化执行记录](#10-地图清晰度优化执行记录)
11. [最新代码目录现状与静态审计结论](#11-最新代码目录现状与静态审计结论)

---

## 1. 代码结构与功能分析

### 1.1 目录组织结构

```
MapEditor/
├── MapEditor.vcxproj          # VS2013 项目文件
├── MapEditor.rc               # 资源定义
├── Resource.h                 # 资源 ID 宏
├── StdAfx.h / StdAfx.cpp      # 预编译头
├── MapEditor.h / .cpp         # 应用程序类 (CWinApp)
├── MainFrm.h / .cpp           # MDI 主框架 (CMDIFrameWnd)
├── ChildFrm.h / .cpp          # MDI 子框架 (CMDIChildWnd)
├── MapEditorDoc.h / .cpp      # 文档类 (CDocument)
├── MapEditorView.h / .cpp     # 视图类 (CScrollView + CDisplayMapBase)
├── ToolsMap.h / .cpp          # 地图工具类 (继承 Nuclear::PMap)
├── Action.h / .cpp            # 操作类型定义 (22 种 Action)
├── ActionList.h / .cpp        # 操作历史管理 (撤销/重做)
├── Operator.h                 # 旧版操作定义 (已废弃，与 Action.h 重复)
├── OperatorList.h             # 旧版操作列表 (已废弃，与 ActionList.h 重复)
├── DisplayMapBase.h / .cpp    # 渲染基类 (CLayerView + EngineBase)
├── EditorRender.h / .cpp      # DX9 渲染器 (继承 DX9Renderer)
├── ScreenElements.h / .cpp    # 屏幕元素拓扑排序
├── LayerView.h                # 图层编辑 ID 枚举与编码
├── MapEditorGroundCtrl.h/.cpp # 地面编辑控件
├── MapEditorObjsCtrl.h / .cpp # 对象编辑控件
├── MapClipboardContentMaker.h # 剪贴板内容
├── Sprite.h / .cpp            # 精灵行走模拟
├── ImgInfo.h                  # 图片信息结构
├── CrashDump.h / .cpp         # 崩溃转储
├── docs/                      # 文档目录
│   ├── MapEditor-技术文档.md
│   └── MapEditor-深度分析报告.md
├── README.md                  # 目录说明
└── [46 个对话框相关源码/头文件] # 各种编辑面板
```

### 1.2 模块依赖关系图

```
                    ┌──────────────┐
                    │ CMapEditorApp│
                    │  (CWinApp)   │
                    └──────┬───────┘
                           │ InitInstance()
                           ▼
              ┌────────────────────────┐
              │      CMainFrame        │
              │   (CMDIFrameWnd)       │
              │  ┌─CLayerEditBar       │
              │  └─CToolBar            │
              └──────────┬─────────────┘
                         │
              ┌──────────┴─────────────┐
              ▼                        ▼
    ┌──────────────────┐    ┌──────────────────┐
    │  CChildFrame     │    │  CMapEditorDoc   │
    │(CMDIChildWnd)    │    │  (CDocument)     │
    └────────┬─────────┘    │  ┌─CToolsMap     │
             │              │  │  (extends PMap)│
             │              └────────┬─────────┘
             │                       │
             ▼                       ▼
    ┌────────────────────────────────────────┐
    │         CMapEditorView                 │
    │  (CScrollView + CDisplayMapBase)       │
    │  ┌─CMapEditorGroundCtrl                │
    │  ├─CMapEditorObjsCtrl                  │
    │  ├─CActionList (m_pOperatorList)       │
    │  ├─20+ Dialog 成员                     │
    │  └─CScreenElements                     │
    └────────────┬───────────────────────────┘
                 │
       ┌─────────┼──────────┐
       ▼         ▼          ▼
  ┌─────────┐ ┌────────┐ ┌──────────────┐
  │CEditor  │ │CScreen │ │  Dialog面板   │
  │Render   │ │Elements│ │  (20+个)      │
  │(DX9)    │ │(拓扑)  │ └──────────────┘
  └─────────┘ └────────┘
```

### 1.3 核心文件统计

| 类别 | 文件数 | 代码行数(估) |
|------|--------|-------------|
| 核心框架 (App/Doc/View/Frame) | 10 | 7,762 |
| 地图工具 (ToolsMap) | 2 | 1,322 |
| 撤销/重做 (Action/ActionList) | 4 | 1,244 |
| 渲染 (DisplayMapBase/EditorRender/ScreenElements) | 6 | 2,811 |
| 编辑控件 (GroundCtrl/ObjsCtrl) | 4 | 798 |
| 对话框相关源码/头文件 | 46 | 8,951 |
| 辅助 (Sprite/ImgInfo/CrashDump/Clipboard) | 7 | 581 |
| **核心源码合计** | **79** | **23,469** |

### 1.4 源码锚点索引总表

> **维护规则**: 后续代码演进时，先更新本表中的“文件 / 关键函数 / 关键成员 / 当前状态裁决”，再更新第 2、4、5、11 节正文。这样位置描述可以维持机械同步。

| 模块 | 文件 | 关键函数 | 关键成员 | 当前状态裁决 |
|------|------|----------|----------|--------------|
| `CMapEditorApp` | `MapEditor.h/.cpp` | `InitInstance()`、`CheckTileType()`、`OnImport()`、`OnMergeImport()` | `m_TileTypeMap`、`m_pPathMap`、`m_pFileIOManager` | 应用入口与资源环境宿主 |
| `CMapEditorDoc` | `MapEditorDoc.h/.cpp` | `OnOpenDocument()`、`OnSaveDocument()`、`ExportToFile()`、`ModifyCanvas()` | `m_ToolsMap`、`m_DocSize`、`m_bInit`、`m_bPictureInit` | 文档主数据宿主；导出前预检已接入 |
| `CMapEditorView` | `MapEditorView.h/.cpp` | `OnDraw()`、`DoAction()`、`UnDo()`、`ReDo()`、`OnEditMapInfo()` | `m_pOperatorList`、`m_SelectedObjects`、`m_nEditMode` | 编辑调度中心；画布快照阈值确认已接入 |
| `CToolsMap` | `ToolsMap.h/.cpp` | `ImportFromFile()`、`ExportToFile()`、`ValidateExportResources()`、`CleanMap()`、`marshal()` / `unmarshal()` | `m_GroundLayerInfoArray`、`m_GroundLayersArray`、`m_mapNamesToObjMapKey`、`m_bIsExportImport` | 工具格式 / 运行时导出桥接层 |
| `CActionList` | `ActionList.h/.cpp` | `DoOneAction()`、`UndoOneAction()`、`RedoOneAction()`、`ToDoAction()` | `m_ActionList`、`m_Iter` | 撤销游标提交语义已修复 |
| `CDisplayMapBase` | `DisplayMapBase.h/.cpp` | `drawMap()`、`drawSmallTiles()`、`drawLayerTiles()`、`UpdateTriggers()` | `m_TileMap`、`m_MidTileMap`、`m_BigTileMap`、`m_ImgInfoMap` | 高清 tile 预览与 point/linear 采样已接入；默认 filter 状态仍需收敛 |
| `PPathMap` | `engine/map/ppathmap.h/.cpp` | `GetTileFileName()`、`GetHighDefinitionTileFileName()`、`Insert()`、`Save()` | `m_mapPaths`、`m_bChanged` | 普通 / 高清地砖路径映射层 |
| Alpha Bleed 脚本 | `tools/scripts/Build-MapTile-AlphaBleed.ps1` | `Get-TargetFiles`、`Invoke-AlphaBleed` | `InputPath`、`OutputPath`、`BleedPixels` | 离线 PNG 边缘外扩工具 |

---

## 2. 核心模块功能实现与关键入口

### 2.1 地图数据管理 (CToolsMap)

当前 `CToolsMap` 应按入口函数理解：

| 入口函数 | 位置 | 当前作用 | 直接调用方 |
|---|---|---|---|
| `ImportFromFile()` | `ToolsMap.cpp:1087` | 从工具格式 `.map` 导入；读完后恢复图层数组与名称映射 | `CMapEditorDoc::OnOpenDocument()` |
| `unmarshal()` | `ToolsMap.cpp:375` | 在工具模式下读取 `MRMP + TOOLS_VERSION + PMap + 图层扩展` | `Load()` / `ImportFromFile()` |
| `marshal()` | `ToolsMap.cpp:412` | 在工具模式下写 `MRMP + TOOLS_VERSION + PMap + 图层扩展` | `SaveToNativePath()` |
| `SaveTilesToGround()` | `ToolsMap.cpp` | 将编辑器图层数组写回 `PGround` | 导出前、资源预检前 |
| `SaveTilesFromGround()` | `ToolsMap.cpp` | 从 `PGround` 恢复编辑器图层数组 | 导入后 |
| `ValidateExportResources()` | `ToolsMap.cpp:455` | 在副本上执行 `SaveTilesToGround() + CleanMap()` | `CMapEditorDoc::ExportToFile()` |
| `ExportToFile()` | `ToolsMap.cpp:1101` | 导出运行时地图，只输出 `PMap` 数据 | `CMapEditorDoc::ExportToFile()` |
| `CleanMap()` | `ToolsMap.cpp:442` | 调度地表、元素、特效、联动对象、扭曲对象资源清洗 | 预检和导出 |

当前状态裁决：

- `CToolsMap` 是“编辑器图层视图”和“运行时地图底层数据”的桥接层，不是单纯的 `PMap` 包装。
- 小地表的编辑结果常驻在 `m_GroundLayerInfoArray + m_GroundLayersArray`，运行时导出前必须显式写回 `PGround`。
- 当前导出链路不会再直接清洗当前文档状态，而是总在副本上执行资源清洗。

### 2.2 撤销/重做系统 (CActionList)

当前撤销系统应按以下入口理解：

| 入口函数 | 位置 | 当前作用 |
|---|---|---|
| `DoOneAction()` | `ActionList.cpp:605` | 写入新操作；裁剪 redo 分支；处理背景 `pPics` 特殊释放 |
| `UndoOneAction()` | `ActionList.cpp:513` | 先计算临时迭代器，再执行 `BEFORE_OPERATOR`，成功后提交 |
| `RedoOneAction()` | `ActionList.cpp:497` | 执行当前 `m_Iter` 的 `AFTER_OPERATOR`，成功后前移迭代器 |
| `ToDoAction()` | `ActionList.cpp:531` | switch 分发到 `SetTile / SetObjects / SetChangeCanvas / ...` |

当前状态裁决：

- 撤销栈最大长度仍是 `50`。
- 新操作会清掉当前位置之后的 redo 分支，这是当前实现的固定行为。
- `UndoOneAction()` 失败后游标错位这一项已修复，当前失败路径会恢复 `m_Iter`。
- 背景操作仍是最特殊的一类 `Action`，`pPics` 所有权和释放逻辑依旧需要单独看待。

### 2.3 渲染管线 (CDisplayMapBase + CEditorRender)

当前渲染链的关键入口如下：

| 入口函数 | 位置 | 当前作用 |
|---|---|---|
| `CreateEditorRenderer()` | `EditorRender.cpp` | 创建 `CEditorRender`，底层走 `DX9Renderer::Create()` |
| `drawMap()` | `DisplayMapBase.cpp:1720` | MapEditor 预览主调度入口 |
| `drawSmallTiles()` | `DisplayMapBase.cpp:1247` | 绘制小地表，支持高清旁路与 point/linear 采样 |
| `drawLayerTiles()` | `DisplayMapBase.cpp:1390` | 绘制中/大地表，支持高清旁路与 point/linear 采样 |

当前调用链裁决：

1. `CMapEditorView::OnDraw()` 调用 `drawMap()`。
2. `drawMap()` 按背景 -> 地表 -> 水面 -> 对象 -> 编辑叠加层的顺序调度。
3. 地表绘制时先读 `MapEditorCfg.ini [QUALITY] UseHDTiles`，优先尝试 `/map/tiles_hd/`。
4. `m_fRatio == 1.0f` 时显式传 `FILTER_POINT`，否则传 `FILTER_LINEAR`。
5. 对象层排序依赖 `CScreenElements` 和 `RectTopologyList`。

当前状态裁决：

- `MapEditor` 预览层已经接入高清地砖旁路和采样策略，但客户端运行时地图尚未接入。
- `textureFilter` 默认路径仍可能继承上一批次 sampler state，这是当前渲染链仍未完全收敛的问题。
- `CEditorRender` 仍是 DX9 编辑器包装层，不承担材质节点或场景 RT 后处理职责。

### 2.4 触发器系统

当前触发器编辑链入口主要在：

| 入口函数 | 位置 | 当前作用 |
|---|---|---|
| `CTriggerListDlg::OnBnClickedButtonNewLayer()` | `TriggerListDlg.cpp:129` | 新增触发器信息集 |
| `CTriggerListDlg::OnBnClickedButton1()` | `TriggerListDlg.cpp:89` | 编辑触发器信息集 |
| `CTriggerListDlg::OnBnClickedButtonDeleteLayer()` | `TriggerListDlg.cpp:55` | 删除触发器信息集或具体区域 |
| `CTriggerListDlg::ReNewTree()` | `TriggerListDlg.cpp:182` | 用当前 `TriggerInfoMap` 重建树形视图 |

当前状态裁决：

- 触发器面板的写回仍通过 `AT_TRIGGER_OBJECT` 进入撤销链。
- 树控件同时表示“触发器信息集”和“具体区域”；删除时通过是否有父节点区分。
- 运行时触发更新仍属于引擎/渲染层，MapEditor 主要负责编辑、选择和可视化。

### 2.5 画布修改系统

当前画布修改链入口如下：

| 入口函数 | 位置 | 当前作用 |
|---|---|---|
| `CMapEditorView::OnEditMapInfo()` | `MapEditorView.cpp:3801` | 从 `CRegionMapInfoDlg` 收集新尺寸、对齐方式和水面效果名 |
| `EstimateCanvasUndoSnapshotBytes()` | `MapEditorView.cpp` | 估算双快照内存体积，超阈值时弹确认框 |
| `CMapEditorDoc::ModifyCanvas()` | `MapEditorDoc.cpp` | 调度地表、对象、背景、水区、触发器迁移 |

当前调用链裁决：

1. 用户在 `CRegionMapInfoDlg` 中提交新宽高、对齐模式和水面效果名。
2. `OnEditMapInfo()` 先判断撤销快照体积是否超过阈值。
3. 创建 `AT_CHANGE_CANVAS` 并记录 `BEFORE_OPERATOR`。
4. `ModifyCanvas()` 分发到 tile / object / background / water-area 的调整逻辑。
5. 成功后记录 `AFTER_OPERATOR` 并通过 `DoAction()` 写入历史栈。

当前状态裁决：

- 画布修改仍采用完整 `CToolsMap` 双快照，不是差异快照。
- 本轮仅加入大地图快照确认框，尚未改成更轻量的 undo 结构。
- 水面效果名变更仍绑定在画布修改入口内处理。

---

## 3. 主要数据结构与类层次

### 3.1 核心类继承关系

```
CWinApp
  └── CMapEditorApp

CMDIFrameWnd
  └── CMainFrame

CMDIChildWnd
  └── CChildFrame

CDocument
  └── CMapEditorDoc
        └── m_ToolsMap: CToolsMap

CScrollView
  └── CMapEditorView (多重继承)
        └── CDisplayMapBase
              ├── CLayerView (图层管理)
              └── Nuclear::EngineBase (引擎基础)

Nuclear::PMap
  └── CToolsMap

Nuclear::DX9Renderer
  └── CEditorRender

Nuclear::ComponentSprite
  └── Sprite

Nuclear::IApp
  └── CMapEditorApplicationDelegate
```

### 3.2 关键数据结构

| 结构 | 文件 | 用途 |
|------|------|------|
| `TileLayerInfo` | ToolsMap.h | 图层元信息（ID/可见性/名称） |
| `sModifyCanvasParam` | MapEditorDoc.h | 画布修改参数 |
| `sImgInfo` | ImgInfo.h | 图片资源描述 |
| `TILT_TYPE_ID` | Action.h | 地砖类型联合体（8位类型+24位地砖） |
| `MapClipboardCont` | MapClipboardContentMaker.h | 剪贴板对象内容 |
| `TileGranule` | Action.h | 小地砖操作原子数据 |
| `BiggerTileGranule` | Action.h | 中大地砖操作原子数据 |
| `SuperTileGranule` | Action.h | 超级地砖操作原子数据 |
| `FileStates` / `MapFileState` | ToolsMap.h | 资源文件状态 |

### 3.3 对象 ID 编码方案 (CLayerView)

对象 ID 使用 32 位编码：
```
Bit 31-24: 对象类型 (MAP_OBJ_TYPE)
Bit 23-16: 图层 ID
Bit 15-0:  对象索引
```

编码/解码函数：
- `GetObjectType(ObjectId)` → 提取类型
- `GetLayerId(ObjectId)` → 提取图层
- `GetObjectId(ObjectId)` → 提取索引
- `MakeObjectId(type, layer, id)` → 组合 ID

---

## 4. 功能调用流程与业务逻辑

### 4.1 地图编辑主流程

当前主流程应按“输入 -> 控制器 -> 文档 -> 历史栈”理解：

| 阶段 | 入口 | 结果 |
|---|---|---|
| 输入分发 | `CMapEditorView::OnLButtonDown / OnMouseMove / OnLButtonUp` | 根据 `EDIT_MODE_TYPE` 分发到地表、对象、水面、触发器、背景逻辑 |
| 地表编辑 | `CMapEditorGroundCtrl` | 构造 `AT_TILE / AT_BIGGER_TILE / AT_TILE_COLOR / AT_WATER / ...` |
| 对象编辑 | `CMapEditorObjsCtrl` | 构造 `AT_OBJECTS / AT_ELEMENT_BASE / AT_DYNAMIC_BASE / ...` |
| 特殊业务编辑 | 面板或 View 直接入口 | 触发器、水区、背景等通过对应 `CAction` 写回 |
| 历史写入 | `CMapEditorView::DoAction()` -> `CActionList::DoOneAction()` | 进入撤销栈 |

当前状态裁决：

- 主流程的协调者是 `CMapEditorView`，不是各对话框。
- 控制器不负责持久化，它们负责构造 `CAction` 并调用 `Doc / ToolsMap` 修改真实数据。
- 触发器、水区、背景等功能仍存在“面板直接写文档 + 构造 Action”的混合模式。

### 4.2 文件保存流程

当前保存与导出要分开看：

| 场景 | 入口函数 | 当前调用链 |
|---|---|---|
| 普通保存 | `CMapEditorDoc::OnSaveDocument()` | `m_ToolsMap.SaveToNativePath()` -> `CToolsMap::marshal()` |
| 工具格式导入 | `CMapEditorDoc::OnOpenDocument()` | `m_ToolsMap.ImportFromFile()` -> `CToolsMap::unmarshal()` |
| 运行时导出 | `CMapEditorDoc::ExportToFile()` | `ValidateExportResources()` -> `CToolsMap::ExportToFile()` |

当前状态裁决：

- 普通保存输出完整工具格式地图，会保留 `MRMP` 文件头和图层扩展数据。
- 运行时导出输出纯 `PMap` 数据，不包含工具扩展图层信息。
- `OnSaveDocument()` 除了写地图文件，还会同步保存被修改过的 `PImg` 和 `PLinkedObject` 资源侧数据。

### 4.3 渲染更新流程

当前渲染更新链如下：

| 阶段 | 入口 | 当前行为 |
|---|---|---|
| 视图重绘 | `CMapEditorView::OnDraw()` | 进入 `drawMap()` |
| 场景绘制 | `CDisplayMapBase::drawMap()` | 背景 -> 地表 -> 水面 -> 对象 -> 编辑叠加层 |
| 地表绘制 | `drawSmallTiles()` / `drawLayerTiles()` | 懒加载贴图并按配置决定普通/高清路径 |
| 对象排序 | `CScreenElements` | 视口裁剪 + 拓扑排序 |
| 运行时更新 | `UpdateEffects / UpdateLinkedObjs / UpdateDistortObjs / UpdateTriggers` | 更新可视效果与运行时对象 |
| 编辑辅助 | 选择框 / 鼠标对象 / 网格 | 编辑器叠加层 |

当前状态裁决：

- MapEditor 预览不是纯静态图像渲染，而是带有一部分运行时对象更新。
- 地表绘制路径中可能触发 `PPathMap` 回填与资源懒加载。
- 高清预览、point/linear 采样和触发器效果更新都属于当前渲染更新链的一部分。

---

## 5. 当前代码状态裁决

### 5.1 当前应该以哪些章节为准

| 章节 | 当前用途 |
|---|---|
| 第 2 节 | 看模块入口和当前实现职责 |
| 第 3 节 | 看类职责、关键成员、调用方 |
| 第 4 节 | 看主流程、保存链、渲染更新链 |
| 第 6 节 | 看文件格式、字段和导出规则 |
| 第 8-11 节 | 看当前状态、已修复项和静态风险 |

### 5.2 当前状态裁决

| 维度 | 当前裁决 |
|---|---|
| 文件格式 | 当前以二进制工具格式 `MRMP + TOOLS_VERSION + PMap + 图层扩展` 为准；运行时导出是纯 `PMap` |
| 渲染链 | 当前以 `CMapEditorView::OnDraw()` -> `CDisplayMapBase::drawMap()` -> 地表/对象/叠加层 调度为准 |
| 导出链 | 当前导出前一定先走 `ValidateExportResources()`，缺失资源时阻断导出 |
| 高清预览 | 当前只接入 MapEditor 预览链，不进入客户端运行时地图 |
| 工具链状态 | `MapEditor` 及已覆盖的 DirectX 工具工程，`MSB8012 / C4005` 噪音已治理 |
| 主线实现 | 当前应以 `Action.* / ActionList.*` 为主，`Operator.*` 视为历史兼容文件 |

### 5.3 当前仍需重点关注的问题

| 项目 | 当前状态 |
|---|---|
| `textureFilter` 默认路径 | 仍可能继承上一批次 sampler state |
| 高清开关读取位置 | 仍位于渲染热路径辅助函数中 |
| 导出性能 | 预检与正式导出重复清洗副本 |
| 资源缓存 | 仍未做容量治理 |
| 历史重复模块 | `Operator.*` 仍保留在代码树中 |

---

## 6. 潜在 Bug 清单（初始审查）

> **说明**: 本节记录首次深度扫描时的原始问题视图，其中部分问题已在后续代码中修复。判断“当前代码状态”时，应优先查看第 8、9、10、11 节。

### 6.1 内存管理问题

| # | 问题 | 位置 | 严重程度 | 说明 |
|---|------|------|---------|------|
| M-1 | **ModifyBackgroundInfo 内存泄漏** | [ToolsMap.cpp:112-121](file:///e:/MT3/tools/engine/MapEditor/ToolsMap.cpp#L112-L121) | 🔴 高 | 当 `oldBufferSize != newBufferSize` 时，分配了新的 `pPics` 缓冲区，但旧的 `pPics` 未释放。每次修改背景尺寸都会泄漏一块内存 |
| M-2 | **CToolsMap 赋值运算符浅拷贝风险** | [ActionList.cpp:SetChangeCanvas](file:///e:/MT3/tools/engine/MapEditor/ActionList.cpp) | 🟡 中 | `pmap = oper->oper[type]` 使用默认赋值运算符，CToolsMap 包含裸指针数组 `m_GroundLayersArray`，浅拷贝可能导致双重释放 |
| M-3 | **ActionList 清理时背景 pPics 泄漏** | [ActionList.cpp:DoOneAction](file:///e:/MT3/tools/engine/MapEditor/ActionList.cpp) | 🟡 中 | 清除历史时只检查 `AT_BACKGROUND_INFO` 类型的 `pPics`，其他可能持有 `pPics` 的 Action 类型未处理 |
| M-4 | **DistortMap 中的 DistortBase 泄漏** | [DisplayMapBase.cpp](file:///e:/MT3/tools/engine/MapEditor/DisplayMapBase.cpp) | 🟡 中 | `m_DistortMap` 中的 `DistortBase*` 在某些异常路径下可能未被正确删除 |
| M-5 | **EffectArray 中的 Effect 泄漏** | [DisplayMapBase.cpp](file:///e:/MT3/tools/engine/MapEditor/DisplayMapBase.cpp) | 🟡 中 | `m_EffectArray` 中的 `Effect*` 在图层切换或文档关闭时可能未被完全清理 |
| M-6 | **SetNewDeleteLayersInfo 中的裸指针 delete** | [ActionList.cpp:SetNewDeleteLayersInfo](file:///e:/MT3/tools/engine/MapEditor/ActionList.cpp) | 🟠 低 | 使用 `delete` 释放 `m_GroundLayersArray` 中的 `TileType*`，但数组中可能存在重复指针（浅拷贝导致） |

### 6.2 边界条件问题

| # | 问题 | 位置 | 严重程度 | 说明 |
|---|------|------|---------|------|
| B-1 | **GetSmallTileData 无边界检查** | [ToolsMap.h:GetSmallTileData](file:///e:/MT3/tools/engine/MapEditor/ToolsMap.h) | 🔴 高 | `m_GroundLayersArray.at(layer)` 会抛出 `std::out_of_range` 异常，但调用方未做异常处理；x/y 参数也无边界检查 |
| B-2 | **GetGroundLayerInfo 无边界检查** | [ToolsMap.h:GetGroundLayerInfo](file:///e:/MT3/tools/engine/MapEditor/ToolsMap.h) | 🟡 中 | 使用 `at()` 但调用方未捕获异常 |
| B-3 | **SetSingleGroundLayerInfo 无边界检查** | [ActionList.cpp:SetSingleGroundLayerInfo](file:///e:/MT3/tools/engine/MapEditor/ActionList.cpp) | 🟡 中 | 直接用 `oper->m_Layer` 索引数组，无范围验证 |
| B-4 | **SetObjects 中的 objID 断言** | [ActionList.cpp:SetObjects](file:///e:/MT3/tools/engine/MapEditor/ActionList.cpp) | 🟡 中 | `XPASSERT(objID == pmap.m_objs[objType].GetObjSize(layerID))` 在 Release 模式下被移除，可能导致越界访问 |
| B-5 | **画布修改后对象位置溢出** | [MapEditorDoc.cpp:ModifyCanvas](file:///e:/MT3/tools/engine/MapEditor/MapEditorDoc.cpp) | 🟠 低 | 画布缩小时，超出新边界的对象位置未做裁剪，可能导致负坐标或超大坐标 |
| B-6 | **ModifyMode 范围未验证** | [MapEditorDoc.h:sModifyCanvasParam](file:///e:/MT3/tools/engine/MapEditor/MapEditorDoc.h) | 🟠 低 | `m_ModifyMode` 应为 0-8，但无验证逻辑 |

### 6.3 错误处理问题

| # | 问题 | 位置 | 严重程度 | 说明 |
|---|------|------|---------|------|
| E-1 | **SetLinkedObjectBase 空指针返回** | [ActionList.cpp:SetLinkedObjectBase](file:///e:/MT3/tools/engine/MapEditor/ActionList.cpp) | 🟡 中 | `m_LinkedObjectMap[...]` 可能返回 nullptr，函数返回 false 但调用方未检查 |
| E-2 | **SetElementBase 空指针返回** | [ActionList.cpp:SetElementBase](file:///e:/MT3/tools/engine/MapEditor/ActionList.cpp) | 🟡 中 | 同上，`m_ImgInfoMap[...]` 可能返回 nullptr |
| E-3 | **UndoOneAction 失败后迭代器状态** | [ActionList.cpp:UndoOneAction](file:///e:/MT3/tools/engine/MapEditor/ActionList.cpp) | 🟡 中 | `m_Iter--` 在 `ToDoAction` 之前执行，如果 `ToDoAction` 返回 false，迭代器已经回退但操作未执行，导致状态不一致 |
| E-4 | **OnOpenDocument 异常安全** | [MapEditorDoc.cpp:OnOpenDocument](file:///e:/MT3/tools/engine/MapEditor/MapEditorDoc.cpp) | 🟠 低 | 文件加载失败时，部分初始化状态可能未清理 |
| E-5 | **CreateTriggerEffect 资源创建失败** | [DisplayMapBase.cpp:CreateTriggerEffect](file:///e:/MT3/tools/engine/MapEditor/DisplayMapBase.cpp) | 🟠 低 | `m_pEffectMgr->CreateEffect()` 可能返回 nullptr，后续 `AssureResource` 和 `Play` 会导致崩溃 |

### 6.4 性能问题

| # | 问题 | 位置 | 严重程度 | 说明 |
|---|------|------|---------|------|
| P-1 | **AT_CHANGE_CANVAS 完整地图拷贝** | [Action.h:CCanvasActionAtom](file:///e:/MT3/tools/engine/MapEditor/Action.h) | 🟡 中 | 画布修改时复制整个 CToolsMap（包含所有地砖数据），大地图可能占用数十 MB 内存 |
| P-2 | **rand() 非线程安全** | [DisplayMapBase.cpp:TryTrigger](file:///e:/MT3/tools/engine/MapEditor/DisplayMapBase.cpp) | 🟠 低 | 使用 `rand()` 进行随机触发判断，非线程安全（当前单线程使用，但未来扩展有风险） |
| P-3 | **资源缓存无 LRU 淘汰** | [DisplayMapBase.h](file:///e:/MT3/tools/engine/MapEditor/DisplayMapBase.h) | 🟠 低 | 8 个资源缓存映射只增不减，长时间编辑大地图可能导致内存持续增长 |
| P-4 | **CScreenElements 全量重排** | [ScreenElements.cpp](file:///e:/MT3/tools/engine/MapEditor/ScreenElements.cpp) | 🟠 低 | `SetMustRenew()` 触发全量拓扑排序，频繁调用时可能影响帧率 |

### 6.5 代码质量问题

| # | 问题 | 位置 | 严重程度 | 说明 |
|---|------|------|---------|------|
| Q-1 | **Operator.h / Action.h 重复定义** | [Operator.h](file:///e:/MT3/tools/engine/MapEditor/Operator.h), [Action.h](file:///e:/MT3/tools/engine/MapEditor/Action.h) | 🟡 中 | 两个文件定义了几乎相同的操作类型和结构，Operator.h 为旧版遗留代码 |
| Q-2 | **OperatorList.h / ActionList.h 重复** | [OperatorList.h](file:///e:/MT3/tools/engine/MapEditor/OperatorList.h), [ActionList.h](file:///e:/MT3/tools/engine/MapEditor/ActionList.h) | 🟡 中 | 同上，OperatorList 为旧版命名 |
| Q-3 | **CMapEditorView 成员过多** | [MapEditorView.h](file:///e:/MT3/tools/engine/MapEditor/MapEditorView.h) | 🟡 中 | View 类包含 20+ 对话框成员和大量状态变量，违反单一职责原则 |
| Q-4 | **CDisplayMapBase 职责过重** | [DisplayMapBase.h](file:///e:/MT3/tools/engine/MapEditor/DisplayMapBase.h) | 🟠 低 | 同时负责渲染、资源缓存、特效更新、触发器更新，应拆分 |
| Q-5 | **硬编码魔法数字** | 多处 | 🟠 低 | 如 `FIRST_ELEMENT_LAYER`、`TILES_SMALL_LAYER_COUNT` 等散布在代码中 |
| Q-6 | **CString 与 std::wstring 混用** | 多处 | 🟠 低 | MFC CString 与 STL wstring 之间频繁转换，增加复杂度 |

### 6.6 跨平台与兼容性问题

| # | 问题 | 位置 | 严重程度 | 说明 |
|---|------|------|---------|------|
| C-1 | **仅支持 Windows** | 全局 | 🔴 高 | MFC + DirectX 9 完全绑定 Windows 平台，无法移植 |
| C-2 | **VS2013 编译器限制** | 全局 | 🟡 中 | 不支持 C++11/14 特性（如 auto、range-for、智能指针），代码风格受限 |
| C-3 | **32 位地址空间限制** | 全局 | 🟡 中 | 大地图可能接近 2GB 进程地址空间限制 |
| C-4 | **Unicode 字符集依赖** | 全局 | 🟠 低 | 使用 `TCHAR` 和 `CString`，与 MBCS 编译不兼容 |

---

## 7. 整体代码质量评估与优化方向（初始版本）

### 7.1 代码质量评分

| 维度 | 评分 (1-10) | 说明 |
|------|------------|------|
| **功能完整性** | 8 | 地图编辑功能齐全，22 种操作类型覆盖全面 |
| **代码可读性** | 5 | 命名不一致、注释少、类职责过重 |
| **内存安全** | 4 | 多处裸指针、潜在泄漏、浅拷贝风险 |
| **错误处理** | 4 | 大量 XPASSERT 在 Release 下无效、空指针未检查 |
| **性能** | 6 | 基本满足需求，但画布修改和大地图有瓶颈 |
| **可维护性** | 4 | 重复代码、类职责不清、硬编码多 |
| **可测试性** | 2 | 无单元测试、紧耦合 MFC、难以隔离测试 |
| **文档质量** | 7 | 更新后文档与代码对齐，覆盖核心模块 |

**综合评分**: 5.0 / 10

### 7.2 优化方向建议

#### 高优先级（影响稳定性）

1. **修复 ModifyBackgroundInfo 内存泄漏** (M-1)
   - 在分配新 `pPics` 前，先释放旧的 `pPics`
   - 建议：`Nuclear::XFree(objinfo.pPics)` 在 `Nuclear::XAlloc` 之前

2. **修复 UndoOneAction 迭代器状态问题** (E-3)
   - 将 `m_Iter--` 移到 `ToDoAction` 成功之后
   - 或在 `ToDoAction` 失败时恢复迭代器

3. **添加边界检查** (B-1, B-4)
   - 在 `GetSmallTileData` 中添加 x/y 范围验证
   - 将 `XPASSERT` 替换为运行时检查 + 错误返回

4. **修复 CToolsMap 赋值运算符** (M-2)
   - 实现深拷贝赋值运算符，或使用 `std::vector<TileType>` 替代裸指针数组

#### 中优先级（影响可维护性）

5. **清理重复代码** (Q-1, Q-2)
   - 删除 `Operator.h` 和 `OperatorList.h`，统一使用 `Action.h` / `ActionList.h`
   - 确认无编译依赖后移除

6. **拆分 CMapEditorView** (Q-3)
   - 将对话框管理提取到独立的 `DialogManager` 类
   - 将编辑状态提取到 `EditContext` 类
   - View 类只负责视图渲染和事件分发

7. **优化 AT_CHANGE_CANVAS 内存占用** (P-1)
   - 只存储画布差异而非完整快照
   - 或使用增量式撤销/重做

8. **统一字符串类型** (Q-6)
   - 在业务逻辑层统一使用 `std::wstring`
   - 只在与 MFC 交互时转换为 `CString`

#### 低优先级（长期改进）

9. **资源缓存 LRU 淘汰** (P-3)
   - 为 8 个缓存映射添加最大容量限制
   - 实现基于访问时间的淘汰策略

10. **添加单元测试框架**
    - 将核心逻辑（CToolsMap、CActionList、CLayerView）与 MFC 解耦
    - 使用 Google Test 或 CppUnit 编写单元测试

11. **替换 rand() 为更安全的随机数生成器** (P-2)
    - 使用 `std::mt19937` 替代 `rand()`

12. **消除硬编码魔法数字** (Q-5)
    - 定义常量或枚举替代散布的数字

### 7.3 风险评估总结

| 风险等级 | 数量 | 关键风险 |
|---------|------|---------|
| 🔴 高 | 4 | 内存泄漏 (M-1)、边界检查缺失 (B-1)、平台锁定 (C-1)、赋值浅拷贝 (M-2) |
| 🟡 中 | 10 | 多处空指针风险、迭代器状态不一致、重复代码、类职责过重 |
| 🟠 低 | 8 | 性能瓶颈、硬编码、字符串混用、缓存无淘汰 |

**总体评估**: MapEditor 功能完整、业务逻辑正确，但存在若干内存安全和错误处理缺陷。建议优先修复高严重度问题（M-1 内存泄漏、B-1 边界检查、M-2 浅拷贝），再逐步改善代码结构和可维护性。文档已从 v2.5.0 更新至 v3.0.0，修正了文件格式、技术栈、接口定义等关键错误，新增了撤销/重做系统、渲染管线、数据结构参考等章节，确保与代码实现 100% 对齐。

---

**分析完成日期**: 2026-04-24  
**分析工具**: 人工代码审查 + 自动化检索  
**许可证**: 内部使用

---

## 8. 资深测试与架构复核修订版

> **复核日期**: 2026-04-24  
> **复核视角**: 软件测试风险建模 + 系统架构一致性审查  
> **复核方式**: 基于 `tools/engine/MapEditor/` 与 `tools/engine/engine/map/` 关键源码交叉验证  
> **结论摘要**: 原报告对 MapEditor 的主要方向判断基本成立，但部分问题定性需要修正；源码中还存在若干比原清单更直接的崩溃级风险，尤其是数组释放不匹配、撤销游标状态错乱、背景图缓冲区所有权不清晰和整图快照式撤销导致的内存峰值。

### 8.1 报告结论准确性复核

| 原结论 | 复核结果 | 证据位置 | 修订意见 |
|---|---|---|---|
| `ModifyBackgroundInfo` 存在内存泄漏 | ✅ 证实 | `ToolsMap.cpp:114` | 当背景尺寸变化时直接覆盖 `objinfo` 并重新 `XAlloc`，旧 `pPics` 未释放，应列为 P0 |
| `CToolsMap::operator=` 存在背景浅拷贝 | ⚠️ 需修正 | `ToolsMap.cpp:1139`、`pbackground.cpp:32` | `PMap::operator=` 会触发 `PBackGround::operator=` 深拷贝背景 `pPics`，该项不应作为独立高危浅拷贝结论 |
| `UndoOneAction` 迭代器失败状态不一致 | ✅ 证实 | `ActionList.cpp:514` | 先 `m_Iter--` 再执行动作，失败时未恢复游标，可能破坏撤销/重做边界 |
| `GetSmallTileData` 边界检查不足 | ✅ 部分证实 | `ToolsMap.h:160` | 坐标越界依赖 `GetSmlTilePos` 返回 `-1`，但图层索引、`m_GroundLayerInfoArray.at(layer).layerID` 与数组访问仍缺运行时保护 |
| `AT_CHANGE_CANVAS` 内存占用高 | ✅ 证实 | `Action.h:400` | 撤销数据保存两份完整 `CToolsMap`，大地图、多背景、多对象时内存峰值显著 |
| 资源缓存无淘汰 | ✅ 证实但需降级 | `DisplayMapBase.h:18`、`DisplayMapBase.cpp:1867` | 析构会释放主要资源，但编辑过程中长期打开大图或频繁切资源时仍可能膨胀，属于长期会话性能风险 |

### 8.2 新增高优先级风险清单

#### R-1 数组释放方式错误导致堆破坏（P0）

**现象**: 多处使用 `new[]` 分配数组，却用 `delete` 释放。该问题比普通内存泄漏更严重，可能破坏 CRT 堆元数据，引发随机崩溃、撤销操作异常、退出时崩溃或后续分配失败。

**源码证据**:

- `ToolsMap.cpp:1159` 使用 `new Nuclear::SubMap::TileType[count]`，但 `ToolsMap.cpp:1147` 使用 `delete (*iter)`。
- `Action.h:312` 的 `m_Data` 保存数组指针，`Action.h:314` 析构中使用 `delete (m_Data)`。
- `MapEditorGroundCtrl.cpp:227`、`MapEditorGroundCtrl.cpp:272` 分别使用 `new CAction::TileGranule[size]` 与 `new CAction::BiggerTileGranule[size]`，但 `MapEditorGroundCtrl.cpp:249`、`MapEditorGroundCtrl.cpp:293` 使用 `delete (ptrTileData)`。
- `ActionList.cpp:341` 使用 `new TileType[...]`，相关删除路径 `ActionList.cpp:337` 使用 `delete(...)`。

**触发场景**:

1. 新建/删除地表图层后撤销或重做。
2. 大面积刷地表、刷阻挡或刷中/大地块后结束当前操作。
3. 打开地图、修改画布或复制 `CToolsMap` 后销毁旧图层数组。
4. 长时间编辑后关闭工具或切换地图。

**修复建议**:

- 将所有数组释放点改为 `delete[]`，并建立 `new[]/delete[]` 专项审计。
- 优先把 `Nuclear::SubMap::PtrTileTypeList` 内部裸数组收敛为小型 RAII 包装，至少在 MapEditor 内部封装释放函数，例如 `ReleaseTileArray(TileType*& p)`。
- 在 Debug 构建下启用 CRT heap check，在撤销/重做、新建/删除图层、关闭文档路径后执行 `_CrtCheckMemory()`。

#### R-2 背景图 `pPics` 所有权转移不透明（P0）

**现象**: 背景图数组 `pPics` 同时被地图对象、撤销动作和背景编辑流程引用，靠手工判断 `oper[0].pPics != oper[1].pPics` 决定释放，所有权语义非常脆弱。一旦新增流程未遵守该隐式约定，容易出现泄漏、重复释放或悬空指针。

**源码证据**:

- `ToolsMap.cpp:127` 在背景尺寸变化时 `objinfo = info`，随后分配新 `pPics`，未释放旧 `objinfo.pPics`。
- `ActionList.cpp:40` 调用 `pmap.AddBackgroundInfo(oper->oper[type], oper->oper[type].pPics)`，撤销数据指针被转移到地图对象。
- `ActionList.cpp:609`、`ActionList.cpp:641` 根据动作执行状态手工释放 `BEFORE/AFTER` 中的 `pPics`。
- `pbackground.cpp:17` 中 `PBackGround::ClearAll()` 会释放 `m_backGroundInfos` 内每个 `pPics`。

**触发场景**:

1. 修改背景尺寸后连续撤销、重做、再新增背景。
2. 修改背景信息后执行新的编辑操作，导致 redo 分支被截断释放。
3. 背景图层删除后保存、关闭或重新打开地图。

**修复建议**:

- `ModifyBackgroundInfo` 在分配新缓冲区前必须释放旧 `pPics`，并将 `objinfo.pPics` 置空后再赋值。
- 为 `PBackGoundInfo` 引入显式复制/释放辅助函数：`CloneBackgroundInfo`、`ReleaseBackgroundPics`、`AssignBackgroundInfoPreservePics`。
- 撤销动作中不要直接共享地图对象持有的 `pPics` 指针；改为动作内部持有深拷贝，应用动作时由地图层统一接管或复制。
- 建立背景编辑回归用例：新增背景、修改尺寸、绘制背景格、撤销、重做、截断 redo、保存、关闭。

#### R-3 撤销/重做游标异常后不可恢复（P0/P1）

**现象**: `UndoOneAction()` 在动作执行前先移动 `m_Iter`，若 `ToDoAction(BEFORE_OPERATOR)` 返回 `false`，`m_Iter` 已经落到上一个动作位置，后续 `CanUndo()`、`CanRedo()` 与实际地图状态不再一致。

**源码证据**:

- `ActionList.cpp:514` 中 `m_Iter--` 发生在 `ToDoAction()` 前。
- `ActionList.cpp:528` 的 `ToDoAction()` 分发多个子操作，任何一个返回 `false` 都会让 `UndoOneAction()` 直接失败返回，但游标未恢复。

**触发场景**:

1. 撤销对象资源缺失、图层 ID 异常、背景 ID 越界或窗口状态无效的操作。
2. 在历史地图、损坏地图或半加载状态下执行撤销。
3. 某个 `Set*` 子操作未来新增校验并返回失败。

**修复建议**:

- 使用临时迭代器：`std::list<CAction*>::iterator prev = m_Iter; --prev;`，仅当动作成功后再 `m_Iter = prev`。
- `RedoOneAction()` 也应以同样模式提交游标，避免未来修改引入对称问题。
- `ToDoAction()` 失败时记录动作类型、图层 ID、目标状态、失败原因，便于测试复现。
- 对所有 `Set*` 函数补充失败前置校验，避免部分修改后返回失败造成半应用状态。

#### R-4 新建/删除地表图层恢复逻辑存在索引与释放风险（P0/P1）

**现象**: 图层数组以 `m_LayerID` 作为索引直接访问和删除，缺少边界保护；删除数组时也存在 `delete`/`new[]` 不匹配。

**源码证据**:

- `ActionList.cpp:337` 直接访问 `m_GroundLayersArray[oper->m_LayerID]` 并删除。
- `ActionList.cpp:338` 使用 `erase(remove(...))`，没有传入标准 erase-remove 的结束迭代器形式，语义可读性和兼容性较差。
- `ActionList.cpp:346` 通过反向迭代器移动元素，依赖 `m_LayerID` 合法且数组非空。

**触发场景**:

1. 删除非末尾地表图层后撤销/重做。
2. 图层数据异常或历史地图中的 `layerID` 与数组位置不一致。
3. 操作栈中保存的图层 ID 在其他操作后失效。

**修复建议**:

- 操作前校验 `oper->m_LayerID < m_GroundLayersArray.size()`。
- 删除数组使用 `delete[]`，且先保存指针再 `erase`，避免表达式中多次索引访问。
- 插入恢复时改用 `vector::insert(begin + m_LayerID, data)`，不要手工反向搬移。
- 图层 ID 与数组下标应在命名上区分：若 `layerID` 是稳定 ID，不应直接作为数组下标。

### 8.3 边界条件与异常路径测试矩阵

| 测试域 | 用例 | 预期风险 | 建议断言 |
|---|---|---|---|
| 背景编辑 | 修改背景宽高为更大、更小、0、极大值 | 泄漏、越界、分配失败 | 内存无增长泄漏；非法尺寸拒绝；保存后重载一致 |
| 背景撤销 | 新增背景 -> 改尺寸 -> 绘制格子 -> 撤销/重做 -> 新操作截断 redo | 双重释放、悬空指针 | 每一步 `pPics` 非空且内容一致；关闭文档不崩溃 |
| 地表图层 | 新建图层、删除首层/中间层/末层并撤销重做 | 堆破坏、层 ID 错乱 | 图层数量、顺序、内容哈希一致 |
| 大面积刷地表 | 使用超大笔刷跨越地图边缘 | 数组越界、错误写入 | 越界区域被裁剪；地图边界外不写入 |
| 画布修改 | 大地图扩大/缩小画布后连续撤销 | 内存峰值、响应卡顿 | 峰值内存受控；撤销后宽高与对象坐标一致 |
| 对象资源缺失 | 删除或替换对象贴图/特效文件后打开地图 | 空指针、异常路径失败 | 缺资源可降级显示并记录错误，不影响保存 |
| 长会话渲染 | 连续打开多张大地图、切换资源、缩放视图 | 缓存膨胀、句柄耗尽 | 资源缓存有上限；关闭文档后句柄释放 |
| 损坏地图 | 构造非法 layerID、背景 ID、负尺寸或超大尺寸 | 崩溃、越界访问 | 加载失败返回明确错误，不进入半初始化状态 |

### 8.4 性能瓶颈深度分析

#### P-1 整图快照式撤销导致内存峰值

`CCanvasActionAtom` 内含 `CToolsMap oper[2]`，意味着画布变化会深拷贝完整地图两份。由于 `PBackGround::operator=` 会深拷贝背景 `pPics`，该机制虽然避免了背景浅拷贝，但会显著放大内存占用。若地图包含大背景网格、多图层地表、多对象与水面数据，一次画布修改可能产生数十到数百 MB 的瞬时和常驻撤销内存。

**优化建议**:

- 近期：限制画布修改动作进入撤销栈的最大地图尺寸，超过阈值时提示用户并强制保存检查点。
- 中期：将 `AT_CHANGE_CANVAS` 改为差异模型，只记录旧矩形、新矩形、裁剪区域与新增区域默认值。
- 长期：引入命令式 undo/redo，每类数据结构提供 `ApplyResizeDelta()`，避免全量 `CToolsMap` 深拷贝。

#### P-2 渲染资源缓存缺少会话级上限

`CDisplayMapBase` 在析构中释放 `m_PictureResMap`、`m_ImgInfoMap`、`m_LinkedObjectMap`、`m_DistortMap`、`m_DistortObjectMap` 等缓存，但编辑过程中没有明确 LRU 或容量阈值。长时间编辑或频繁切换资源时，峰值仍可能持续增长。

**优化建议**:

- 给图片、对象、扭曲对象缓存增加最大条目数和最大估算字节数。
- 以“当前视口 + 最近使用 + 当前选中资源”为保留策略，其余资源延迟释放。
- 在性能面板中暴露缓存数量、纹理句柄数量、估算显存与系统内存。

#### P-3 拓扑排序与屏幕元素重建可能过于频繁

`CScreenElements` 会按视口重建屏幕元素并进行拓扑排序，若对象密集且滚动视图时频繁全量重建，会带来 CPU 峰值和内存分配压力。

**优化建议**:

- 将视口变化分为小滚动与大跳转，小滚动优先做增量进出屏更新。
- 对静态对象层建立空间索引，例如网格桶或四叉树，减少每帧扫描对象数量。
- 复用 `sObjInfo` 临时缓冲区，减少 `XAlloc/XFree` 高频调用。

### 8.5 架构优化路线

#### 第一阶段：稳定性止血

1. 修复所有 `new[]/delete` 不匹配点。
2. 修复 `ModifyBackgroundInfo` 旧 `pPics` 泄漏。
3. 修复撤销/重做游标提交时机。
4. 为地表图层 ID、背景 ID、tile 坐标和对象 key 增加运行时校验。
5. 增加 MapEditor 专项崩溃回归场景：背景尺寸、图层删除、画布修改、撤销截断 redo。

#### 第二阶段：所有权收敛

1. 建立背景 `pPics` 的统一复制、释放、接管接口。
2. 将地表层数组封装为具备析构语义的类型，避免裸 `TileType*` 在多个类中传递。
3. 让 `CAction` 的各类 ActionAtom 明确是否持有资源，禁止在 `CActionList` 外部手工推断释放对象。
4. 引入轻量级资源诊断日志：分配尺寸、释放路径、动作类型、地图文件名。

#### 第三阶段：性能与可测试性改造

1. 将画布撤销从全量快照改为差异快照。
2. 为资源缓存增加 LRU 和容量阈值。
3. 将 `CToolsMap` 的纯数据操作从 MFC 视图中剥离，形成可单测的 MapModel 层。
4. 构建最小回归测试工程，覆盖 `CToolsMap`、`CActionList`、图层数组、背景数据复制与释放。

### 8.6 修订后的风险排序

| 优先级 | 风险 | 影响 | 建议处理时机 |
|---|---|---|---|
| P0 | `new[]/delete` 不匹配 | 随机崩溃、堆破坏、退出崩溃 | 立即修复 |
| P0 | `ModifyBackgroundInfo` 泄漏旧 `pPics` | 长会话内存膨胀、保存/关闭路径风险 | 立即修复 |
| P0/P1 | 撤销失败后 `m_Iter` 错位 | 撤销/重做历史损坏、地图状态不一致 | 立即修复或随 P0 一并修复 |
| P1 | 背景 `pPics` 所有权不透明 | 重复释放、悬空指针、维护风险 | 第一轮修复后重构 |
| P1 | 地表图层 ID 与数组下标混用 | 越界、图层恢复错乱 | 第一轮修复后验证 |
| P2 | 整图快照撤销内存峰值 | 大地图卡顿、内存不足 | 稳定性修复后优化 |
| P2 | 渲染缓存无会话级上限 | 长时间编辑内存/显存上涨 | 性能专项处理 |
| P3 | View/DisplayMapBase 职责过重 | 可维护性差、测试困难 | 长期架构演进 |

### 8.7 最小验证建议

修复完成后，建议至少执行以下人工回归流程：

1. 打开一张包含背景、多个地表层、对象、特效、水面与触发器的地图。
2. 修改背景尺寸并填充背景格，连续撤销/重做 20 次。
3. 新建地表层、删除中间地表层，连续撤销/重做 20 次。
4. 扩大和缩小画布各 3 次，每次保存后重新打开确认尺寸、地表、对象、背景一致。
5. 使用超大笔刷在四个边界和四个角落刷地表、阻挡、水面。
6. 删除或临时重命名部分贴图/特效资源，验证地图仍可打开且错误可定位。
7. 连续打开/关闭多张大地图，观察进程内存、GDI/DirectX 资源句柄是否回落。

### 8.8 最终复核结论

MapEditor 的核心功能覆盖较完整，但当前风险并不只是“代码风格老旧”或“缺少现代封装”，而是存在可直接导致崩溃和数据状态错乱的底层资源管理缺陷。短期应以 P0 稳定性修复为主，避免先做大规模架构重构；中期再将背景、图层数组和撤销动作的所有权模型收敛；长期才适合拆分 `CMapEditorView`、`CDisplayMapBase` 并提升可测试性。原报告中的总体评分 5.0/10 基本合理，但若按崩溃风险权重重新评估，稳定性维度应从 4/10 下调到 3/10，待 P0 项修复后可恢复到 6/10 左右。

---

## 9. P0-P2 修复执行记录

> **执行日期**: 2026-04-24  
> **执行范围**: P0 崩溃级内存缺陷、P1 撤销一致性与边界保护、P2 大画布撤销内存保护  
> **修复原则**: 优先修直接崩溃根因，不做跨模块大重构；P2 先提供低侵入运行时保护，差异快照作为后续架构项保留。

### 9.1 已修复项

| 优先级 | 问题 | 修复位置 | 修复结果 |
|---|---|---|---|
| P0 | `ModifyBackgroundInfo` 修改背景尺寸时泄漏旧 `pPics` | `ToolsMap.cpp:114` | 尺寸变化前释放旧缓冲区；新尺寸为 0 时置空；分配失败返回 `false` |
| P0 | 地表层数组 `new[]/delete` 不匹配 | `ToolsMap.cpp:286`、`ToolsMap.cpp:1139` | 删除地表层与赋值清理路径改为 `delete[]` |
| P0 | 新建/删除图层撤销数据 `new[]/delete` 不匹配 | `Action.h:307` | `CNewDeleteGroundLayerActionAtom::m_Data` 析构改为 `delete[]` |
| P0 | 地表刷子临时数组 `new[]/delete` 不匹配 | `MapEditorGroundCtrl.cpp:219`、`MapEditorGroundCtrl.cpp:253` | `TileGranule` 与 `BiggerTileGranule` 临时数组改为 `delete[]` |
| P1 | 撤销失败导致 `m_Iter` 游标错位 | `ActionList.cpp:500`、`ActionList.cpp:514` | Undo 使用临时迭代器，动作成功后提交；失败时恢复旧游标；Redo 同步收敛提交语义 |
| P1 | 新建/删除图层撤销缺少 layerID 边界保护 | `ActionList.cpp:330` | 删除/插入前校验 `m_LayerID`，非法时返回失败并释放临时数据 |
| P1 | `CToolsMap::DeleteGroundLayer` 直接按 layerID 访问数组 | `ToolsMap.cpp:286` | 增加 layerID 范围校验，删除时使用保存的数组指针与 `vector::erase(begin + layerID)` |
| P2 | 画布变更保存双份完整 `CToolsMap` 快照，超大地图内存峰值高 | `MapEditorView.cpp:3786` | 增加撤销快照内存估算，超过 256MB 时弹窗确认，避免用户无感触发高内存操作 |

### 9.2 修复后的风险状态

| 风险 | 原状态 | 当前状态 | 后续建议 |
|---|---|---|---|
| 堆破坏风险 | 多处 `new[]/delete` 不匹配 | 已修复本轮确认的 MapEditor 关键路径 | 后续可全仓执行一次 `new[]/delete` 专项静态审计 |
| 背景 `pPics` 泄漏 | 修改尺寸必然泄漏旧缓冲区 | 已修复尺寸变化路径 | 所有权模型仍依赖手工规则，建议后续封装 `Clone/Release/Assign` 辅助函数 |
| 撤销栈状态错乱 | Undo 失败后游标不恢复 | 已修复 | 仍建议为每个 `Set*` 子动作补充更完整的失败日志 |
| 地表图层恢复越界 | layerID 可越界访问 | 已增加基础保护 | 需进一步区分稳定 layerID 与数组下标语义 |
| 画布快照内存峰值 | 无提示直接创建双快照 | 已增加阈值确认 | 根治方案仍是差异快照或命令式 resize undo |
| 渲染缓存长期增长 | 仅析构时集中释放 | 未在本轮改动 | 建议作为独立性能专项处理 LRU 与容量上限 |

### 9.3 建议验证清单

1. 构建 MapEditor 工程，确认 `MapEditorView.cpp` 新增估算函数涉及的 `CToolsMap` 接口可正常通过 VS2013 编译。
2. 新建地表层、删除首层/中间层/末层，分别执行撤销/重做 20 次，确认无崩溃且图层内容一致。
3. 使用小/中/大笔刷刷地表与大地块，覆盖地图边界，确认操作结束时无堆检查错误。
4. 修改背景宽高为更大、更小、0 或非法值，执行撤销/重做并关闭文档，确认 `pPics` 无泄漏或重复释放。
5. 对超大地图执行画布修改，确认超过阈值时出现内存风险确认框，取消时地图不变、继续时行为与历史一致。
6. 连续执行“画布修改 -> 撤销 -> 重做 -> 新操作截断 redo”，确认撤销历史游标与地图状态一致。

### 9.4 未纳入本轮的架构项

- `AT_CHANGE_CANVAS` 差异快照：本轮仅加阈值保护，未改撤销数据结构，避免影响保存/撤销语义。
- 渲染资源 LRU：涉及 `CDisplayMapBase` 资源生命周期和 DirectX 句柄释放策略，建议单独建性能专项。
- `PBackGoundInfo` 所有权重构：需要统一地图层、撤销层和背景编辑层的 `pPics` 持有规则，建议在 P0 回归稳定后实施。

---

## 10. 地图清晰度优化执行记录

> **执行日期**: 2026-04-24  
> **目标**: 在不修改 `TileType` 编码、不破坏旧 `RMAP/PMap` 格式的前提下，提升地图资源边缘质量、预览采样质量和导出可靠性。  
> **策略**: 优先做工具链与旁路配置；客户端场景 RT 后处理保留为下一阶段渲染专项，避免影响 UI 与现有渲染顺序。

### 10.1 已落地能力

| 优化项 | 落地位置 | 当前行为 | 后续扩展 |
|---|---|---|---|
| Alpha bleed 资源预处理 | `tools/scripts/Build-MapTile-AlphaBleed.ps1` | 支持对 PNG 透明边缘做颜色外扩，降低线性采样黑边/白边 | 接入 SpriteEditor 或资源 CI，增加质量报告 |
| 导出前资源阻断 | `MapEditorDoc.cpp:158`、`ToolsMap.h:23`、`ToolsMap.cpp:442` | 导出前用副本执行资源校验；存在缺失资源时阻止导出，避免地表/对象静默置空 | 增加质量面板与 error/warn 分级 |
| 分层采样策略入口 | `renderer.h:46`、`dx9renderer.cpp:1957`、`DisplayMapBase.cpp:1337` | Renderer 支持 `FILTER_POINT/FILTER_LINEAR`；MapEditor 地表 1:1 用 point，非 1:1 用 linear | 客户端 RegionMap 绘制接入同策略；增加 mipmap 策略 |
| 高清 tile 旁路映射 | `ppathmap.h:39`、`ppathmap.cpp:111`、`DisplayMapBase.cpp:24` | 不改 `TileType`；配置 `MapEditorCfg.ini [QUALITY] UseHDTiles=1` 时优先尝试 `/map/tiles_hd/`，失败回退普通资源 | 发布链增加高清资源组与设备分档选择 |
| 场景 RT 后处理边界 | 文档约束 | 本轮不直接改客户端 RT 链路；明确只应作用于场景层，UI 后绘制 | 下一阶段实现 FXAA/SMAA-lite 场景 pass |

### 10.2 Alpha bleed 使用方式

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MapTile-AlphaBleed.ps1 `
  -InputPath .\client\resource\res\map\tiles `
  -OutputPath .\client\resource\res\map\tiles_bleed `
  -Recurse `
  -BleedPixels 4 `
  -Overwrite
```

说明：

- 对象、地表、水面 PNG 都可作为输入，但建议先在小范围样本上验证。
- 默认只处理 alpha 为 0 的透明像素 RGB，不改变非透明像素 alpha。
- 如果需要原地覆盖，可不传 `-OutputPath`，但正式流程建议先输出到旁路目录做比对。

### 10.3 高清 tile 旁路规则

普通资源路径仍保持原规则：

- 小地表：`/map/tiles/smalltile/...`
- 中地表：`/map/tiles/midtile/...`
- 大地表：`/map/tiles/bigtile/...`

高清预览资源采用同构目录：

- 小地表：`/map/tiles_hd/smalltile/...`
- 中地表：`/map/tiles_hd/midtile/...`
- 大地表：`/map/tiles_hd/bigtile/...`

启用方式：

```ini
[QUALITY]
UseHDTiles=1
```

当前仅 MapEditor 预览优先尝试高清资源；找不到高清资源时自动回退普通资源，因此不影响旧地图和旧资源包。

### 10.4 采样策略说明

- 1:1 地表预览使用 point sampling，避免像素对齐时被线性采样糊化。
- 非 1:1 缩放使用 linear sampling，降低缩放锯齿和跳变。
- Renderer 默认保持旧行为；只有显式传入 `textureFilter` 的绘制调用才切换采样。
- 后续客户端接入时，建议按“地表、对象、特效、水体、UI”分层设置，禁止对 UI 统一套场景后处理。

### 10.5 后续渲染专项边界

场景 RT 后处理建议下一阶段单独实现：

1. 地图场景绘制到 offscreen render target。
2. 对场景 RT 执行 FXAA 或 SMAA-lite。
3. UI、文字、鼠标命中辅助线在后处理之后绘制。
4. 增加低端设备开关，避免 RT 内存和 fill-rate 压力。

该项涉及客户端主渲染顺序、UI 渲染接管和多平台后端一致性，本轮只完成接口边界和文档约束。

---

## 11. 最新代码目录现状与静态审计结论

> **复核日期**: 2026-04-24  
> **复核范围**: `tools/engine/MapEditor/**` 当前代码树与其直接依赖的 `renderer` / `ppathmap` 扩展  
> **裁决说明**: 若本节与前文第 1、6、7 节旧结论冲突，以本节为准。

### 11.1 当前目录现状

按 `rg --files tools/engine/MapEditor` 的当前口径统计：

| 项目 | 数值 |
|------|------|
| 跟踪文件总数 | 108 |
| `.cpp` 文件 | 46 |
| `.h` 文件 | 50 |
| 资源文件 (`.rc/.rc2`) | 2 |
| 对话框相关源码/头文件 | 46 |

当前与本轮代码状态强相关的新增事实：

- `MapEditor.rc` 中“窗口”菜单子项已本地化为中文。
- `MapEditorDoc::ExportToFile()` 已改为导出前副本预检，不再允许缺失资源时静默导出退化地图。
- `PPathMap` 已增加高清地砖旁路接口，MapEditor 预览可优先尝试 `/map/tiles_hd/`。
- `Renderer::DrawPictureParam` / `DrawBatchPictureParam` 已增加 `textureFilter`，MapEditor 地表预览已显式区分 point/linear。
- `tools/scripts/Build-MapTile-AlphaBleed.ps1` 已作为离线 PNG 边缘外扩脚本纳入工具链。

### 11.2 已修正的旧结论

下列结论在当前代码状态下已不再成立，不应继续作为“待修复问题”描述：

| 原结论 | 当前状态 | 说明 |
|---|---|---|
| `ModifyBackgroundInfo` 必然泄漏旧 `pPics` | 已修复 | 背景尺寸变化前会先处理旧缓冲区，再接管新缓冲区 |
| `UndoOneAction()` 失败后撤销游标错位 | 已修复 | 已改为临时迭代器提交语义 |
| 地表图层及临时数组存在 `new[]/delete` 不匹配 | 已修复 | 关键路径已统一为 `delete[]` |
| 导出时缺失资源会静默清空地表/对象并继续输出 | 已修复 | 现在会先生成 `experr.log` 并阻止导出 |
| 导出预检与正式导出重复执行 `CleanMap()` | 已修复 | 当前复用同一份清洗后的导出副本 |
| `textureFilter` 默认路径继承上一次采样状态 | 已修复 | 当前局部覆盖后恢复原 sampler |
| 高清地砖开关位于渲染热路径每次读盘 | 已修复 | 当前在 `CDisplayMapBase` 初始化时缓存 |
| `MSB8012` 与 `C4005` 是 MapEditor 主线的长期既有噪音 | 已修复 | 当前主线工具工程已完成对应构建治理 |

### 11.3 当前仍需关注的静态风险

| 级别 | 风险 | 位置 | 说明 |
|------|------|------|------|
| 低 | 高清预览配置在视图生命周期内缓存 | `DisplayMapBase.cpp:1964` | `UseHDTiles` 已改为初始化时读取，运行时手工修改 `MapEditorCfg.ini` 不会立即刷新到当前视图 |
| 低 | `Operator.*` 与 `Action.*` 重复实现仍保留 | `MapEditor` 根目录 | 虽然不再作为当前主线使用，但仍增加认知与维护成本 |

### 11.4 当前代码质量判断

如果仅按当前 `MapEditor` 代码状态重评：

- 稳定性：相比初始审查结论明显改善，尤其是内存释放、导出安全性和撤销状态一致性。
- 可维护性：仍受 `Operator.*` 历史重复、`View` / `DisplayMapBase` 职责偏重影响。
- 渲染质量能力：已具备 point/linear 采样切换、高清 tile 旁路和 alpha bleed 工具入口，但客户端运行时尚未完全接入。
- 工具链治理：MapEditor 及已覆盖的相关编辑器工程，`MSB8012` / `C4005` 这两类构建噪音已完成专项治理。

### 11.5 完修验收索引

当前与“是否接近完修”直接相关的验收视图：

- 技术文档第 12 节维护了完修验收清单与回归测试矩阵。
- 本报告第 11 节用于判断“当前仍活跃的静态风险”。
- 若技术文档第 12 节中的验收项与本节冲突，以本节静态风险裁决为准。

### 11.6 2026-04-25 修复复核结果

本轮针对“当前仍需关注的静态风险”执行后的复核结论如下：

| 项目 | 当前结果 | 证据锚点 |
|------|----------|----------|
| `textureFilter` 默认路径继承上一批次状态 | 已修复 | `dx9renderer.cpp:1978` 进入绘制前缓存旧 sampler，结束后恢复 |
| 高清地砖开关位于渲染热路径每次读盘 | 已修复 | `DisplayMapBase.cpp:1973` / `2000` 改为初始化时缓存 `m_bUseHDTiles` |
| 导出预检与正式导出重复清洗 | 已修复 | `ToolsMap.cpp:455`、`MapEditorDoc.cpp:161` 引入 `PrepareExportMap()` 与 `SaveRuntimeMapToFile()` |
| 主线构建有效性 | 已验证 | `MapEditor.exe` 重新构建成功，时间戳为 2026-04-25 01:03:52 |

### 11.7 2026-04-25 smoke 实操验收结果

本轮使用内建 smoke 模式执行了半自动验收：

- 输入样本：`client/resource/res/map/5001_dayanta1/MapEditor1.mrmp`
- 输出目录：`%TEMP%/MapEditorSmoke_20260425_022046/`

结果裁决：

| 验收项 | 结果 | 说明 |
|--------|------|------|
| 文档打开 | 通过 | `OpenDocumentFileDirect: PASS` |
| 工具格式保存 | 通过 | `smoke_saved.map` 已生成 |
| 保存后回读 | 通过 | `ReloadSavedMap: PASS` |
| 地表编辑 | 未通过 | 当前 smoke 样本未成功完成地表修改，需要继续补强样本选择或编辑策略 |
| 画布修改 | 通过 | `ModifyCanvas: PASS` |
| 运行时导出准备 | 通过 | `PrepareExport: PASS` |
| 运行时导出 | 未通过 | 当前样本存在缺失资源，导出阻断符合设计预期 |
| 预览渲染截图 | 通过 | 已输出多张 `preview_*.jpg` |

当前裁决：

- smoke 模式已经能真实覆盖“文件 I/O + 画布修改 + 预览截图”。
- “运行时导出失败”当前不是回归，而是样本存在缺失资源后被新导出预检正确阻断。
- “地表编辑失败”是当前半自动验收里仍需继续收敛的缺口，后续应优先改进 smoke 选样或地表编辑策略。

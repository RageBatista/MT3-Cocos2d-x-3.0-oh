# MapEditor 技术文档

> **历史边界（2026-07-23）**：本文主体是 2026-04 的设计与审查快照，其中关于高清 Tile 旁路、`UseHDTiles`、Renderer `textureFilter`、Alpha Bleed 脚本、`/smoketest` 和“构建零警告”的描述与当前源码不一致。当前实现、构建和实跑结论以 [MapEditor 当前实现与优化报告](MapEditor-当前实现与优化报告-20260723.md) 为准。

> **版本**: 3.0.0 | **更新日期**: 2026-04-24 | **工具集**: Visual Studio 2013 (v120)

---

## 目录

1. [概述](#1-概述)
2. [架构设计](#2-架构设计)
3. [核心类与接口](#3-核心类与接口)
4. [撤销/重做系统](#4-撤销重做系统)
5. [渲染管线](#5-渲染管线)
6. [文件格式规范](#6-文件格式规范)
7. [对话框与编辑面板](#7-对话框与编辑面板)
8. [数据结构参考](#8-数据结构参考)
9. [使用指南](#9-使用指南)
10. [技术边界与已知限制](#10-技术边界与已知限制)
11. [最新现状与静态审计](#11-最新现状与静态审计)

---

## 1. 概述

### 1.1 工具功能描述

MapEditor 是 MT3 项目的地图编辑器，基于 MFC MDI 架构构建，用于创建和编辑游戏场景地图。该工具支持多层地面编辑、场景对象放置、触发器配置、区域定义等功能，为游戏提供完整的场景编辑能力。

### 1.2 主要特性

| 特性 | 说明 |
|------|------|
| **多层地面系统** | 支持小/中/大三种尺寸的地砖层，可动态增删图层 |
| **场景对象管理** | 支持元素(ELEMENT)、特效(EFFECT)、联动对象(LINKEDOBJ)、扭曲对象(DISTORT) 四类对象 |
| **透明对象层** | 支持半透明对象（如树木、建筑）的编辑与排序 |
| **触发器系统** | 可视化触发器区域编辑，支持时间触发、精灵触发、随机触发等模式 |
| **水面区域** | 支持水面区域定义和水面特效配置 |
| **背景层** | 支持多层背景图像配置与视差滚动 |
| **遮罩编辑** | 支持行走遮罩和视野遮罩编辑 |
| **小地图生成** | 自动生成场景小地图 |
| **性能分析** | 内置场景性能分析工具 |
| **导入/合并** | 支持从外部数据源导入地图并合并到当前地图 |
| **撤销/重做** | 支持 22 种操作类型的完整撤销/重做 |
| **剪贴板** | 支持地图对象的复制/粘贴 |
| **导出前资源预检** | 导出前基于副本执行资源清洗与缺失校验，缺资源时阻止静默导出 |
| **高清地砖预览** | 支持通过 `MapEditorCfg.ini` 中的 `UseHDTiles=1` 优先预览 `/map/tiles_hd/` 资源 |
| **分层采样策略** | 地表 1:1 预览使用 point sampling，非 1:1 缩放使用 linear sampling |

### 1.3 技术栈

```yaml
语言: C++
框架: MFC (Microsoft Foundation Classes) - MDI 架构
工具集: Visual Studio 2013 (v120)
渲染: DirectX 9 (通过 CEditorRender / Nuclear::DX9Renderer)
依赖:
  - Nuclear引擎 (渲染、特效、精灵、动画管理)
  - PFS (文件系统与资源管理)
  - PPathMap (普通/高清地砖路径映射)
  - A* 寻路 (astar::PathFinder)
附加工具:
  - tools/scripts/Build-MapTile-AlphaBleed.ps1 (PNG 透明边缘颜色外扩)
```

---

## 2. 架构设计

### 2.1 核心类层次

```
┌─────────────────────────────────────────────────────────────────┐
│                      MapEditor 架构                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────┐    ┌───────────────────┐                │
│  │  CMapEditorApp    │    │   CMainFrame       │                │
│  │  (CWinApp)        │    │   (CMDIFrameWnd)   │                │
│  │  - FileIOManager  │    │   - ToolBar        │                │
│  │  - PPathMap       │    │   - LayerEditBar   │                │
│  │  - TileTypeMap    │    │   - StatusBar      │                │
│  └────────┬──────────┘    └────────┬──────────┘                │
│           │                        │                            │
│           ▼                        ▼                            │
│  ┌──────────────────────────────────────────────┐              │
│  │              CMapEditorDoc                    │              │
│  │              (CDocument)                      │              │
│  │  ├── CToolsMap m_ToolsMap (继承 Nuclear::PMap)│              │
│  │  ├── CSize m_DocSize                         │              │
│  │  └── bool m_bInit / m_bPictureInit           │              │
│  └──────────────────┬───────────────────────────┘              │
│                     │                                            │
│           ┌─────────┼─────────┐                                │
│           ▼         ▼         ▼                                │
│  ┌──────────────┐ ┌────────┐ ┌──────────────┐                 │
│  │CMapEditorView│ │各种Dlg │ │编辑控件       │                 │
│  │(CScrollView  │ │面板    │ │              │                 │
│  │+CDisplayMap  │ │        │ │GroundCtrl    │                 │
│  │ Base)        │ │        │ │ObjsCtrl      │                 │
│  └──────┬───────┘ └────────┘ └──────────────┘                 │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────────────────────────────┐              │
│  │           CDisplayMapBase                     │              │
│  │           (CLayerView + EngineBase)           │              │
│  │  ├── CEditorRender (DX9渲染器)               │              │
│  │  ├── CScreenElements (屏幕元素排序)           │              │
│  │  ├── EffectManager / AniManager               │              │
│  │  ├── 资源缓存 (图片/联动对象/扭曲对象)       │              │
│  │  └── 触发器更新 / 特效更新 / 精灵更新        │              │
│  └──────────────────────────────────────────────┘              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

| 模块 | 文件 | 职责 |
|------|------|------|
| **应用程序** | `MapEditor.cpp/h` | MFC 应用入口、PFS 初始化、地砖类型扫描、导入/合并导入 |
| **主框架** | `MainFrm.cpp/h`, `ChildFrm.cpp/h` | MDI 框架窗口、工具栏、状态栏 |
| **文档** | `MapEditorDoc.cpp/h` | 地图数据管理、文件 I/O、画布修改、对象管理 |
| **视图** | `MapEditorView.cpp/h` | 编辑模式切换、鼠标交互、渲染调度、选择管理 |
| **地图工具** | `ToolsMap.cpp/h` | 继承 Nuclear::PMap，扩展图层管理、序列化、资源清理、导入/导出 |
| **撤销/重做** | `ActionList.cpp/h`, `Action.cpp/h` | 22 种操作类型的撤销/重做，最大 50 步历史 |
| **渲染基类** | `DisplayMapBase.cpp/h` | 渲染管线、资源加载缓存、触发器/特效/联动对象更新 |
| **编辑器渲染** | `EditorRender.cpp/h` | 继承 DX9Renderer，支持图层块渲染模式 |
| **屏幕元素** | `ScreenElements.cpp/h` | 基于拓扑排序的可见元素管理 |
| **图层视图** | `LayerView.h` | 图层编辑 ID 枚举、对象 ID 编码/解码 |
| **地面编辑** | `MapEditorGroundCtrl.cpp/h` | 地砖类型/颜色/水面编辑操作 |
| **对象编辑** | `MapEditorObjsCtrl.cpp/h` | 对象添加/删除/移动操作 |
| **剪贴板** | `MapClipboardContentMaker.cpp/h` | 地图对象剪贴板格式支持 |
| **精灵** | `Sprite.cpp/h` | 编辑器内精灵（角色）行走模拟 |
| **崩溃转储** | `CrashDump.cpp/h` | 进程崩溃时生成 .dmp 文件 |
| **图片信息** | `ImgInfo.h` | 图片资源描述结构 (sImgInfo) |

### 2.3 数据流

以下按当前代码中的实际入口拆分，不再使用抽象流程图。

#### 2.3.1 打开地图

| 阶段 | 入口函数 | 直接调用 | 输入 | 输出 / 副作用 |
|------|----------|----------|------|---------------|
| 文档入口 | `CMapEditorDoc::OnOpenDocument()` | `m_ToolsMap.ImportFromFile()` | 目标 `.map` 文件路径 | 加载工具格式地图，恢复 `CToolsMap` 与文档尺寸 |
| 工具文件导入 | `CToolsMap::ImportFromFile()` | `Load()` -> `CToolsMap::unmarshal()` | `MRMP` 文件流 | 读入 `MRMP + TOOLS_VERSION + PMap + 图层扩展数据` |
| 引擎层反序列化 | `CToolsMap::unmarshal()` | `PMap::unmarshal()` | `XIStream` | 先恢复运行时 `PMap` 数据，再恢复编辑器图层信息 |
| 图层恢复 | `CToolsMap::unmarshal()` | `NewGroundLayer()` | `layerCount / isShow / tileData / nameData` | 逆序写入的小地表图层被重新插入到编辑器图层数组头部 |
| 后处理 | `CToolsMap::ImportFromFile()` | `SaveTilesFromGround()`、`ResetMapNamesToObjMapKeys()` | 已加载地图 | 建立 `m_GroundLayersArray` 与对象名称映射缓存 |

#### 2.3.2 保存与导出

| 场景 | 入口函数 | 关键调用链 | 结果 |
|------|----------|------------|------|
| 普通保存 | `CMapEditorDoc::OnSaveDocument()` | `m_ToolsMap.SaveToNativePath()` | 保存完整工具格式地图，保留图层扩展数据 |
| 导出运行时地图 | `CMapEditorView` 导出命令 -> `CMapEditorDoc::ExportToFile()` | `ValidateExportResources()` -> `CToolsMap::ExportToFile()` | 导出纯运行时 `PMap` 数据，不包含 `MRMP` 文件头和图层扩展 |
| 导出前校验 | `CMapEditorDoc::ExportToFile()` | `CToolsMap::ValidateExportResources()` -> 副本 `CleanMap()` | 缺失资源时写 `experr.log` 并阻止导出 |

#### 2.3.3 编辑与撤销

| 阶段 | 入口函数 | 参与对象 | 说明 |
|------|----------|----------|------|
| 用户输入 | `CMapEditorView` 鼠标 / 菜单消息 | `CMapEditorGroundCtrl`、`CMapEditorObjsCtrl` | 根据当前 `EDIT_MODE_TYPE` 分发到地表或对象控制器 |
| 记录操作前状态 | 控制器内部创建 `CAction` | `CAction` | 填充 `BEFORE_OPERATOR` |
| 执行修改 | `CMapEditorDoc` / `CToolsMap` 修改函数 | `m_ToolsMap` | 修改小/中/大地表、对象、水面、背景等 |
| 记录操作后状态 | 控制器或 View | `CAction` | 填充 `AFTER_OPERATOR` |
| 入栈 | `CActionList::DoOneAction()` | `m_ActionList` | 超过 50 步时淘汰最旧记录；新操作会裁剪 redo 分支 |

#### 2.3.4 预览渲染

| 阶段 | 入口函数 | 关键数据 | 说明 |
|------|----------|----------|------|
| 视图触发 | `CMapEditorView::OnDraw()` | 当前滚动位置、缩放比例 | 调用 `drawMap()` 进入渲染调度 |
| 主渲染入口 | `CDisplayMapBase::drawMap()` | `CToolsMap`、选择状态、显示开关 | 顺序绘制背景、地表、水面、对象、网格、选中态 |
| 小地表绘制 | `CDisplayMapBase::drawSmallTiles()` | `m_GroundLayersArray`、`m_TileMap` | 1:1 预览时使用 `FILTER_POINT`，缩放时使用 `FILTER_LINEAR` |
| 中/大地表绘制 | `CDisplayMapBase::drawLayerTiles()` | `PPathMap`、`m_MidTileMap`、`m_BigTileMap` | 可选优先解析 `/map/tiles_hd/`，失败回退普通路径 |
| 对象排序 | `CScreenElements` | `RectTopologyList` | 维护视口内对象拓扑顺序 |

#### 2.3.5 主要数据容器

| 容器 | 所属类 | 当前用途 |
|------|--------|----------|
| `m_GroundLayersArray` | `CToolsMap` | 编辑器小地表图层数组，元素类型为 `TileType*` |
| `m_GroundLayerInfoArray` | `CToolsMap` | 图层可见性、名称、逻辑层 ID |
| `m_Ground` | `PMap/PGround` | 运行时地表主数据：小/中/大地表、颜色层、水面 |
| `m_objs` | `PMap` | 4 类对象：`ELEMENT / EFFECT / LINKEDOBJ / DISTORT` |
| `m_Water` | `PMap` | 水面区域信息 |
| `m_backGround` | `PMap` | 背景层与 `pPics` 图片 key 网格 |
| `m_transObjs` | `PMap` | 透明对象集合 |
| `m_mask` / `m_timeEffect` / `m_triggerObjs` | `PMap` | 遮罩、时间特效、触发器 |

### 2.4 源码锚点索引总表

> **维护规则**: 当代码变更时，优先更新本表中的“文件 / 关键函数 / 关键成员 / 当前状态”，再回写各章节正文。若正文与本表冲突，以本表为准。

| 模块 | 文件 | 关键函数 | 关键成员 | 当前状态 |
|------|------|----------|----------|----------|
| `CMapEditorApp` | `MapEditor.h/.cpp` | `InitInstance()`、`CheckTileType()`、`OnImport()`、`OnMergeImport()` | `m_TileTypeMap`、`m_pPathMap`、`m_pFileIOManager`、`m_ResPath` | 应用入口与资源环境宿主 |
| `CMapEditorDoc` | `MapEditorDoc.h/.cpp` | `OnOpenDocument()`、`OnSaveDocument()`、`ExportToFile()`、`ModifyCanvas()` | `m_ToolsMap`、`m_DocSize`、`m_bInit`、`m_bPictureInit` | 文档主数据宿主；导出前预检已接入 |
| `CMapEditorView` | `MapEditorView.h/.cpp` | `OnDraw()`、`DoAction()`、`UnDo()`、`ReDo()`、`OnEditMapInfo()` | `m_pOperatorList`、`m_SelectedObjects`、`m_nEditMode` | 编辑调度中心；画布快照阈值确认已接入 |
| `CToolsMap` | `ToolsMap.h/.cpp` | `ImportFromFile()`、`ExportToFile()`、`ValidateExportResources()`、`CleanMap()`、`marshal()` / `unmarshal()` | `m_GroundLayerInfoArray`、`m_GroundLayersArray`、`m_mapNamesToObjMapKey`、`m_bIsExportImport` | 工具格式 / 运行时导出桥接层 |
| `CActionList` | `ActionList.h/.cpp` | `DoOneAction()`、`UndoOneAction()`、`RedoOneAction()`、`ToDoAction()` | `m_ActionList`、`m_Iter` | 撤销游标提交语义已修复 |
| `CDisplayMapBase` | `DisplayMapBase.h/.cpp` | `drawMap()`、`drawSmallTiles()`、`drawLayerTiles()`、`UpdateTriggers()` | `m_TileMap`、`m_MidTileMap`、`m_BigTileMap`、`m_ImgInfoMap` | 高清 tile 预览与 point/linear 采样已接入 |
| `PPathMap` | `engine/map/ppathmap.h/.cpp` | `GetTileFileName()`、`GetHighDefinitionTileFileName()`、`Insert()`、`Save()` | `m_mapPaths`、`m_bChanged` | 普通 / 高清地砖路径映射层 |
| Alpha Bleed 脚本 | `tools/scripts/Build-MapTile-AlphaBleed.ps1` | `Get-TargetFiles`、`Invoke-AlphaBleed` | `InputPath`、`OutputPath`、`BleedPixels` | 离线 PNG 边缘外扩工具 |

---

## 3. 核心类与接口

### 3.1 CMapEditorApp (应用程序类)

**类职责**

| 维度 | 当前职责 |
|------|----------|
| 应用生命周期 | 作为 MFC `CWinApp` 入口，负责 `InitInstance()` / `ExitInstance()` |
| 资源环境 | 初始化并持有 `CFileIOManager`、`PPathMap`、资源根路径 |
| 地砖类型索引 | 维护 `m_TileTypeMap`，供地表编辑和导出校验使用 |
| 导入模式控制 | 通过 `m_bIsImport` / `m_bIsMergeImport` 区分普通导入和合并导入 |
| 通用工具入口 | 提供导出目录选择、全对象资源窗口、批量替换联动对象等应用级命令 |

**入口函数**

| 函数 | 作用 | 主要调用方 |
|------|------|------------|
| `InitInstance()` | 创建主框架、初始化资源系统、注册文档模板 | MFC 启动流程 |
| `ExitInstance()` | 释放 `PPathMap`、文件系统和应用级资源 | MFC 退出流程 |
| `GetTileType()` | 延迟触发 `CheckTileType()`，返回可用地砖类型映射 | `CToolsMap::CleanGround()`、地表编辑逻辑 |
| `GetFileIOManager()` | 暴露 PFS 文件 I/O 管理器 | `CEditorRender`、渲染链、路径解析 |
| `GetPathMap()` | 暴露地砖路径映射表 | `DisplayMapBase`、`CToolsMap::CleanGround()` |
| `OnImport()` | 发起外部地图导入 | 菜单命令 |
| `OnMergeImport()` | 发起地图合并导入 | 菜单命令 |
| `SelectExportFolder()` | 统一目录选择对话框 | `CMapEditorView`、`CSmallMapDlg` |

**关键成员**

| 成员 | 类型 | 当前用途 |
|------|------|----------|
| `m_TileTypeMap` | `map<unsigned int, bool>` | 地砖类型 -> 是否可用 |
| `m_pLog` | `Nuclear::PFSLog` | PFS 初始化与运行日志 |
| `m_bIsInitTileType` | `bool` | 地砖类型表是否已初始化 |
| `m_bIsMergeImport` | `bool` | 当前是否为合并导入 |
| `m_bIsImport` | `bool` | 当前是否处于导入流程 |
| `m_pPathMap` | `PPathMap*` | `pro.dat` 路径映射与高清旁路入口 |
| `m_pFileIOManager` | `CFileIOManager*` | 资源读取入口 |
| `m_ResPath` | `CString` | 资源根目录 |

**调用方**

| 调用方 | 依赖点 |
|--------|--------|
| `CToolsMap` | `GetTileType()`、`GetPathMap()` |
| `CDisplayMapBase` | `GetFileIOManager()`、`GetPathMap()`、`GetResPath()` |
| `CMapEditorView` | `SelectExportFolder()`、导入/合并导入命令 |
| 各资源选择面板 | `GetResPath()`、`PFS` 环境 |

### 3.2 CMapEditorDoc (文档类)

**类职责**

| 维度 | 当前职责 |
|------|----------|
| 文档生命周期 | 新建、打开、保存、自动保存、运行时导出 |
| 数据宿主 | 独占持有 `CToolsMap`，统一对外暴露地图读写接口 |
| 编辑事务 | 为地表、对象、触发器、画布修改提供文档级入口 |
| 文件格式桥接 | 在工具格式 `.map` 与运行时导出格式之间切换 |
| 资源预检 | 导出前用副本执行 `ValidateExportResources()` |

**入口函数**

| 函数 | 作用 | 主要调用方 |
|------|------|------------|
| `OnNewDocument()` | 新建空白文档，初始化尺寸和默认状态 | MFC 文档模板 |
| `OnOpenDocument()` | 打开工具格式地图，恢复 `CToolsMap` | 文件菜单、导入流程 |
| `OnSaveDocument()` | 保存工具格式地图，并同步变更过的图片/联动对象资源 | 文件菜单、自动保存 |
| `ExportToFile()` | 运行时导出入口，先预检再正式导出 | `CMapEditorView` 导出菜单 |
| `ModifyCanvas()` | 统一处理画布大小变化及对象/水区/背景迁移 | `CMapEditorView::OnEditMapInfo()` |
| `SetType()` / `SetTile()` | 地表与大地表修改入口 | `CMapEditorGroundCtrl` |
| `AddObject()` / `AddTriggerArea()` | 对象与触发器文档级写入口 | `CMapEditorObjsCtrl`、触发器面板 |

**关键成员**

| 成员 | 类型 | 当前用途 |
|------|------|----------|
| `m_ToolsMap` | `CToolsMap` | 文档主数据 |
| `m_DocSize` | `CSize` | 当前文档像素尺寸 |
| `m_bInit` | `bool` | 文档是否完成初始化 |
| `m_bPictureInit` | `bool` | 地表图片是否已完成首次有效初始化 |

**关键辅助结构**

| 结构 | 字段 | 当前用途 |
|------|------|----------|
| `sModifyCanvasParam` | `m_NewWidth / m_NewHeight / m_ModifyMode / m_EffectName[3]` | 画布修改参数 |

**调用方**

| 调用方 | 依赖点 |
|--------|--------|
| `CMapEditorView` | 新建/保存/导出/画布修改 |
| `CMapEditorGroundCtrl` | 地表修改、图层增删 |
| `CMapEditorObjsCtrl` | 对象增删与对象 key 映射 |
| `CActionList` | 直接访问 `m_ToolsMap` 做撤销/重做应用 |
| 各面板 | 通过 `GetDocument()` 查询和修改数据 |

### 3.3 CMapEditorView (视图类)

**类职责**

| 维度 | 当前职责 |
|------|----------|
| 视图宿主 | 作为 `CScrollView` + `CDisplayMapBase` 组合体，承载编辑预览与滚动视图 |
| 编辑模式分发 | 用 `EDIT_MODE_TYPE` 管理地表、对象、触发器、水面、背景、游戏模式等交互状态 |
| 面板宿主 | 负责创建并持有图层、对象、背景、遮罩、时间特效、小地图等面板 |
| 交互协调 | 负责鼠标命中、框选、拖拽、吸附、选中集维护 |
| 撤销接入 | 通过 `m_pOperatorList` 将交互动作写入历史栈 |

**入口函数**

| 函数 | 作用 | 主要调用方 |
|------|------|------------|
| `Create()` / `OnCreate()` | 创建视图窗口并初始化编辑状态 | MFC 框架 |
| `OnDraw()` | 进入 `drawMap()` 渲染预览 | MFC 重绘流程 |
| `SetEditMode()` | 切换编辑模式 | 工具栏、菜单、面板命令 |
| `DoAction()` / `UnDo()` / `ReDo()` | 写入 / 撤销 / 重做操作 | 控制器与菜单命令 |
| `SetGroundLayerEdit()` / `SetSmallLayerEdit()` | 切换当前编辑图层 | 图层面板、地表工具 |
| `ClearAllSelection()` / `TrySelect*()` | 管理对象、水面、透明对象选择集 | 鼠标交互、各列表面板 |
| `OnEditMapInfo()` | 画布修改与水面效果名变更入口 | 菜单命令 |
| 导出菜单命令 | 组织导出目录后调用 `CMapEditorDoc::ExportToFile()` | 菜单命令 |

**关键成员**

| 成员 | 类型 | 当前用途 |
|------|------|----------|
| `m_GroundCtrl` | `CMapEditorGroundCtrl` | 地表编辑控制器 |
| `m_ObjectsCtrl` | `CMapEditorObjsCtrl` | 对象编辑控制器 |
| `m_pOperatorList` | `LPTRACTIONLIST` | 撤销 / 重做历史栈 |
| `m_SelectedObjects` | `SortBaseIDSet` | 当前选中的普通对象 |
| `m_HiddenTriggerArea` | `set<TriggerInfoID>` | 被隐藏的触发器区域 |
| `m_nEditMode` | `EDIT_MODE_TYPE` | 当前编辑模式 |
| `m_nBrushSize / m_nBrushType` | `int / unsigned int` | 当前画笔参数 |
| `m_nAttachColor` | `unsigned int` | 当前附加颜色 |
| `m_nMagnetRadius` | `int` | 吸附半径，来自 `MapEditorCfg.ini` |
| `m_ModelName / m_Components / m_RideName / 动作名` | `wstring` 系列 | 精灵预览配置 |
| `m_BackgroundListDlg ... m_SelectGroundDlg` | 多个对话框成员 | 各编辑面板宿主 |

**关联枚举与状态**

| 枚举 | 当前用途 |
|------|----------|
| `EDIT_MODE_TYPE` | 描述全部编辑模式，不在类内定义而是在头文件全局作用域定义 |
| `CLICK_STATE` | 命中测试结果 |
| `TRANSPARENT_OBJECT_SCAL_DIRECT` | 透明对象缩放方向 |

**调用方**

| 调用方 | 依赖点 |
|--------|--------|
| MFC 框架 | `Create()`、`OnCreate()`、`OnDraw()` |
| 各面板 (`*Dlg`) | 通过 View 宿主访问文档、选择状态和模式切换 |
| `CMapEditorGroundCtrl` / `CMapEditorObjsCtrl` | 共享当前模式、图层、颜色、撤销入口 |
| `CActionList` | 依赖 View 提供图层切换、列表刷新、选择清理等 UI 联动 |

### 3.4 CToolsMap (地图工具类)

**类职责**

| 维度 | 当前职责 |
|------|----------|
| `PMap` 扩展层 | 在 `Nuclear::PMap` 之上追加编辑器图层、名称映射和工具格式序列化 |
| 图层桥接 | 在小地表编辑层数组与 `PGround` 运行时地表之间双向同步 |
| 资源校验 | 提供 `CleanGround / CleanElement / CleanEffect / ...` 及导出前资源预检 |
| 导入导出 | 支持工具格式导入 (`MRMP`) 和运行时导出 |
| 画布关联数据修正 | 在画布修改时迁移水区、触发器、背景等坐标相关数据 |

**入口函数**

| 函数 | 作用 | 主要调用方 |
|------|------|------------|
| `marshal()` / `unmarshal()` | 工具格式读写，受 `m_bIsExportImport` 控制 | `ImportFromFile()`、`SaveToNativePath()` |
| `ImportFromFile()` | 工具格式导入入口 | `CMapEditorDoc::OnOpenDocument()` |
| `ExportToFile()` | 运行时导出入口 | `CMapEditorDoc::ExportToFile()` |
| `ValidateExportResources()` | 在副本上执行导出预检 | `CMapEditorDoc::ExportToFile()` |
| `SaveTilesToGround()` | 将编辑器小地表图层写回 `PGround` | 导出前、副本清洗前 |
| `SaveTilesFromGround()` | 从 `PGround` 恢复编辑器小地表图层 | 导入后 |
| `NewGroundLayer()` / `DeleteGroundLayer()` | 图层增删 | `CMapEditorDoc`、`CActionList` |
| `CleanMap()` | 清洗地表、对象、特效、联动对象、扭曲对象资源引用 | 预检与运行时导出 |

**关键成员**

| 成员 | 类型 | 当前用途 |
|------|------|----------|
| `m_bIsExportImport` | `bool` | 控制序列化走工具格式还是纯 `PMap` 导出格式 |
| `m_nMaxObjMapKey` | `ObjMapKey[MAP_OBJ_COUNT]` | 各对象类型的最大 key 种子 |
| `m_mapNamesToObjMapKey` | `map<wstring, ObjMapKey>[MAP_OBJ_COUNT]` | 名称 -> key 映射 |
| `m_GroundLayerInfoArray` | `TileLayerInfoList` | 编辑器图层属性 |
| `m_GroundLayersArray` | `PtrTileTypeList` | 编辑器小地表图层数据 |

**关键结构**

| 结构 | 字段 | 当前用途 |
|------|------|----------|
| `TileLayerInfo` | `layerID / isShow / name` | 编辑器图层元数据 |
| `FileStates` | `usedFiles / missFiles` | 单类资源清洗结果 |
| `MapFileState` | `groundFile / elementFile / effectFile / linkedObjectFile / disFile` | 导出预检与日志输出总结果 |

**调用方**

| 调用方 | 依赖点 |
|--------|--------|
| `CMapEditorDoc` | 主数据宿主、导入导出、地表与对象修改 |
| `CActionList` | 撤销 / 重做时直接操作图层、背景、对象相关数据 |
| `CDisplayMapBase` | 读取地表、背景、对象和图层可见性 |
| `CMapEditorApp` | 通过 `GetTileType()` / `GetPathMap()` 辅助资源清洗 |

---

## 4. 撤销/重做系统

### 4.1 架构概述

撤销系统的当前实现由三层组成：

| 层级 | 类型 | 作用 |
|------|------|------|
| 操作壳 | `CAction` | 持有操作类型、图层 ID、具体 `ActionAtom` 指针 |
| 操作数据 | `CAction::CActionAtom` 及其派生类 | 存放 `BEFORE_OPERATOR / AFTER_OPERATOR` 或特定粒度差异数据 |
| 历史栈 | `CActionList` | 管理 `std::list<CAction*>`、当前迭代器 `m_Iter`、redo 分支裁剪与特殊资源释放 |

当前状态机的关键事实：

- 最大历史长度固定为 `50`。
- 新操作写入时，如果 `m_Iter != end()`，会先删除当前位置之后的 redo 分支。
- 背景 `pPics` 的释放逻辑在 `DoOneAction()` 和析构中有专项处理，不与普通 `Action` 统一回收。
- `UndoOneAction()` / `RedoOneAction()` 已使用临时迭代器提交语义，失败时不会破坏 `m_Iter`。

### 4.2 操作类型

| 枚举值 | 数据粒度 | 典型载荷 |
|--------|----------|----------|
| `AT_CHANGE_CANVAS` | 全图快照 | `CCanvasActionAtom::oper[2]` 中两份 `CToolsMap` |
| `AT_TILE` | 小地表点集 | `CTileActionAtom::m_TileData` |
| `AT_TILE_COLOR` | 颜色点集 | `CTileColorActionAtom::m_TileColorData` |
| `AT_SUPER_TILE` | 多层同点位变更 | `CSuperTileActionAtom::m_TileData` |
| `AT_BIGGER_TILE` | 中/大地表点集 | `CBiggerTileActionAtom::m_TileData` |
| `AT_WATER` | 水面点集 | `CWaterActionAtom::m_WaterData` |
| `AT_OBJECTS` | 对象集合差异 | `CObjectsActionAtom::m_AtomObjInfo[2]` |
| `AT_SINGLE_GROUND_LAYER_INFO` | 单图层属性 | `CGroundLayerInfoActionAtom` |
| `AT_ALL_GROUND_LAYER_INFOS` | 全部图层属性 | `CGroundLayerInfosActionAtom` |
| `AT_NEW_DELETE_GROUND_LAYER` | 图层增删 + 全层数据 | `CNewDeleteGroundLayerActionAtom::m_Data` |
| `AT_OBJECT_NAMES` / `AT_SINGLE_OBJECT_NAMES` | 名称映射 | `ObjNameMap` / 单项名称 |
| `AT_ELEMENT_BASE` / `AT_DYNAMIC_BASE` | 锚点 | 四个控制点坐标 |
| `AT_TRANSPARENT_OBJECT` / `AT_TRIGGER_OBJECT` / `AT_WATER_AREA` | 业务对象表 | `TransObjInfoMap` / `TriggerInfoMap` / `WaterAreaInfoMap` |
| `AT_TIME_EFFECT` / `AT_MASK_PARAM` | 时间/遮罩参数 | 对应参数粒度结构 |
| `AT_BACKGROUND_INFO` / `AT_BACKGROUND_DATA` / `AT_BACKGROUND_ORDER` | 背景层 | 背景信息、单格 key、背景顺序 |

### 4.3 CActionList 接口

```cpp
class CActionList {
public:
    static int const MAX_LENGTH = 50;  // 最大历史步数

    void DoOneAction(CAction* oper);   // 写入新操作，必要时裁剪 redo 分支
    bool UndoOneAction();              // m_Iter 向前提交，执行 BEFORE_OPERATOR
    bool RedoOneAction();              // m_Iter 向后提交，执行 AFTER_OPERATOR
    bool CanUndo();                    // m_Iter != begin()
    bool CanRedo();                    // m_Iter != end()

private:
    bool ToDoAction(int type);         // 按枚举分发到 SetTile / SetObjects / SetChangeCanvas ...
};
```

当前关键入口对应关系：

| 函数 | 当前行为 |
|------|----------|
| `DoOneAction()` | 删除 redo 分支；对 `AT_BACKGROUND_INFO` 特殊释放 `pPics`；超长时淘汰最旧操作 |
| `UndoOneAction()` | 先计算临时 `actionIter`，成功后才提交；失败恢复旧 `m_Iter` |
| `RedoOneAction()` | 使用当前 `m_Iter` 的 `AFTER_OPERATOR` 执行，再前移迭代器 |
| `ToDoAction()` | 统一 switch 到 `SetChangeCanvas / SetTile / SetObjects / ...` |

### 4.4 Action 生命周期

严格按当前代码执行顺序：

1. 控制器或 View 创建 `CAction(type, layerID)`。
2. 填充 `BEFORE_OPERATOR` 或初始快照。
3. 调用 `CMapEditorDoc` / `CToolsMap` 修改真实数据。
4. 填充 `AFTER_OPERATOR` 或差异集。
5. `CActionList::DoOneAction()` 写入历史栈。
6. 如果用户在撤销后继续编辑，`DoOneAction()` 会删除当前位置之后的 redo 分支。
7. `UndoOneAction()` 执行 `BEFORE_OPERATOR`，`RedoOneAction()` 执行 `AFTER_OPERATOR`。
8. 析构或淘汰时，对背景操作的 `pPics` 走特殊释放逻辑，其余 `Action` 由 `CAction` 析构自身数据。

---

## 5. 渲染管线

### 5.1 渲染器

当前渲染相关入口如下：

| 入口 | 文件 | 作用 |
|------|------|------|
| `CreateEditorRenderer()` | `EditorRender.cpp` | 创建 `CEditorRender`，并调用 `DX9Renderer::Create()` |
| `CMapEditorView::OnDraw()` | `MapEditorView.cpp` | 视图重绘入口，内部调用 `drawMap()` |
| `CDisplayMapBase::drawMap()` | `DisplayMapBase.cpp` | 地图预览主渲染调度 |
| `CEditorRender` | `EditorRender.h/.cpp` | `DX9Renderer` 的编辑器包装，支持普通模式和图层块模式 |

当前 MapEditor 预览层面的新增渲染行为：

- 小/中/大地表预览统一走 `DrawPictureParam.textureFilter`。
- `m_fRatio == 1.0f` 时显式传 `FILTER_POINT`。
- 非 1:1 缩放时传 `FILTER_LINEAR`。
- 高清地砖旁路仅作用于 MapEditor 预览，不影响旧地图文件格式。

### 5.2 渲染流程

`drawMap()` 当前可拆成以下顺序：

| 顺序 | 函数 | 输入 | 输出 |
|------|------|------|------|
| 1 | `drawBackground()` | 背景静态资源 | 静态背景 |
| 2 | `drawMovingBackground()` | `m_backGround` / `pPics` | 视差背景 |
| 3 | `drawSmallTiles()` | `m_GroundLayersArray`、`m_TileMap` | 小地表 |
| 4 | `drawLayerTiles(GL_MID1/GL_MID2/GL_BIG)` | `PPathMap`、中/大地表缓存 | 中大地表 |
| 5 | `drawWater()` | `WaterTileType`、水特效 | 水面 |
| 6 | `drawElementLayers()` | `CScreenElements` 排序结果 | 元素、联动对象、扭曲对象、特效 |
| 7 | `drawTransparent()` | 透明对象表 | 透明对象 |
| 8 | `drawTriggerObjs()` / `drawWaterAreaObjs()` | 触发器/水区对象 | 特殊区域对象 |
| 9 | `drawSelectedRects()` / `DrawMouseObj()` | 选择与鼠标状态 | 编辑叠加层 |
| 10 | `drawGrids()` / `drawCityGrid()` | 视图配置 | 网格叠加层 |

当前地表资源解析顺序：

1. 读取 `MapEditorCfg.ini` 的 `[QUALITY] UseHDTiles`。
2. 若开启，则优先调用 `PPathMap::GetHighDefinitionTileFileName()`。
3. 若高清路径解析失败，则回退到 `PPathMap::GetTileFileName()`。
4. 若路径映射为空，则按目录模式扫描 `smalltile / midtile / bigtile`。
5. 扫描成功后会调用 `PPathMap::Insert()` 补种路径，并在必要时 `Save()`。

### 5.3 CScreenElements (屏幕元素管理)

`CScreenElements` 当前负责三件事：

| 功能 | 关键数据 | 说明 |
|------|----------|------|
| 视口裁剪 | `m_ElementLayerArray` | 仅保留当前视口内对象 |
| 拓扑排序 | `RectTopologyList` | 计算对象绘制顺序 |
| 增量重建 | `m_bMustRenew` | 仅在标记为脏时重建图层缓存 |

### 5.4 资源缓存

`CDisplayMapBase` 当前维护的缓存与运行时实例如下：

| 缓存 | 类型 | 说明 |
|------|------|------|
| `m_ImgInfoMap` | `map<wstring, LPImgInfo>` | 图片资源信息缓存 |
| `m_LinkedObjectMap` | `map<wstring, PLinkedObject*>` | 联动对象缓存 |
| `m_DistortObjectMap` | `map<wstring, PDistortionObject*>` | 扭曲对象缓存 |
| `m_PictureResMap` | `map<PictureHandle, PicResrc*>` | 图片渲染资源缓存 |
| `m_EffectInfoMap` | `map<wstring, sEffInfo>` | 特效边界信息缓存 |
| `m_TreeMap` | `map<pair<char,uint>, LkoTreeNodeList>` | 联动对象树节点缓存 |
| `m_DistortMap` | `map<pair<char,uint>, DistortBase*>` | 扭曲对象运行时实例 |
| `m_EffectArray` | `vector<EffectMap>` | 特效运行时实例（按图层） |

当前缓存生命周期特点：

- 大部分缓存只在 `CDisplayMapBase` 析构时统一释放。
- 地表贴图缓存（如 `m_TileMap`、`m_MidTileMap`、`m_BigTileMap`）以懒加载方式增长。
- 当前未实现 LRU / 容量阈值治理。

---

## 6. 文件格式规范

### 6.1 .map 文件格式

当前存在两种序列化模式，由 `m_bIsExportImport` 控制：

| 模式 | 入口 | 输出内容 |
|------|------|----------|
| 工具文件模式 | `m_bIsExportImport == false` | `MRMP + TOOLS_VERSION + PMap数据 + 图层扩展` |
| 运行时导出模式 | `m_bIsExportImport == true` | 仅 `PMap::marshal()` 输出的运行时地图数据 |

#### 文件头

```
偏移  长度  说明
0     4     文件魔数: 'M','R','M','P'
4     4     工具版本号 (TOOLS_VERSION = 1)
```

#### `PMap` 序列化字段顺序

`PMap::marshal()` 当前字段顺序是固定的：

1. 文件头 `RMAP`
2. `MAP_VERSION`
3. `width`
4. `height`
5. `sign`
6. `m_Ground`
7. `m_Water`
8. `m_objs[MAP_OBJ_COUNT]`
9. `m_transObjs`
10. `m_timeEffect`
11. `m_mask`
12. `m_triggerObjs`
13. `m_backGround`

#### 工具扩展图层字段

仅在工具文件模式下，`PMap` 之后追加以下字段：

```
字段              类型            说明
layerCount       int             编辑器小地表图层数
对于每个图层:
  isShow         unsigned char   图层可见性
  tileData       byte[TileSize]  对应 `TileType[]` 原始字节
  nameSize       unsigned int    图层名字节长度
  nameData       byte[nameSize]  UTF-16LE 图层名称
```

#### 图层读写规则

- 写入时按 `m_GroundLayerInfoArray.rbegin() -> rend()` 逆序写出。
- 读取时每读一层先 `NewGroundLayer()`，新图层总是插在头部。
- 因此“逆序写 + 头插读”共同保证编辑器中的最终图层顺序与保存前一致。

### 6.2 导出格式

当前导出流程分两段：

1. `CMapEditorDoc::ExportToFile()` 先调用 `ValidateExportResources()`，基于 `CToolsMap` 副本执行 `CleanMap()`。
2. 如果发现缺失或非法资源，则生成 `experr.log` 并直接阻止导出，避免旧逻辑把缺失地表或对象静默置空后继续写文件。
3. 只有预检通过后，才调用 `ExportToFile()` 进入 `PMap::marshal` 导出态（`m_bIsExportImport = true`），输出纯运行时地图数据，不包含 `MRMP` 文件头和工具扩展图层数据。

当前相关入口函数：

| 函数 | 当前作用 |
|------|----------|
| `CMapEditorView` 导出菜单命令 | 组织目标导出路径，目标文件名通常为 `map.rmp` |
| `CMapEditorDoc::ExportToFile()` | 执行预检、写日志、正式导出 |
| `CToolsMap::ValidateExportResources()` | 在副本上执行 `SaveTilesToGround()` + `CleanMap()` |
| `CToolsMap::ExportToFile()` | 在副本上清洗资源并写运行时地图 |

### 6.3 地砖类型文件结构

```
res/map/tiles/
├── smalltile/           # 小地砖 (128x64)
│   └── {type}-{name}/
│       └── {shape}-{index}.{TILE_TYPE}
├── midtile/             # 中地砖 (256x256)
│   └── {type}-{name}/
│       └── *.{TILE_TYPE}
└── bigtile/             # 大地砖 (512x512)
    └── {type}-{name}/
        └── *.{TILE_TYPE}

res/map/tiles_hd/        # 高清预览旁路目录，结构与上面保持同构
├── smalltile/
├── midtile/
└── bigtile/
```

`PPathMap` 当前的路径接口：

| 接口 | 用途 |
|------|------|
| `GetTileFileName(TileType)` | 普通小地表路径 |
| `GetTileFileName(TILE_SIZE_TYPE, BiggerTileType)` | 普通中/大地表路径 |
| `GetHighDefinitionTileFileName(...)` | 高清旁路路径，内部将 `/map/tiles/` 替换为 `/map/tiles_hd/` |
| `Insert()` | 扫描目录成功后回填 `pro.dat` 映射 |

---

## 7. 对话框与编辑面板

### 7.1 编辑面板一览

| 面板类 | 创建入口 | 主要刷新入口 | 主要写回路径 |
|--------|----------|--------------|--------------|
| `CLayerListDlg` | `Create(CMapEditorView*)` | `ReNewTree()` | `CMapEditorView::NewGroundLayer()` / `DeleteGroundLayer()` / 图层显示与命名同步 |
| `CObjectListDlg` | `Create(CMapEditorView*)` | 列表重建 | 通过 `CMapEditorView` 选择对象与调用 `DoAction()` |
| `CTransparentObjectListDlg` | `Create(CMapEditorView*)` | `ReNewTree()` | 透明对象增删改通过 `DoAction()` + `SetModifiedFlag()` |
| `CTriggerListDlg` | `Create(CMapEditorView*)` | `ReNewTree()` | 触发器增删改通过 `CAction(AT_TRIGGER_OBJECT)` 写回 |
| `CBackgroundListDlg` | `Create(CMapEditorView*)` | `RenewList()` | 背景增删改直接修改 `CToolsMap` 并标记文档已修改 |
| `CTimeEffectEditorDlg` | `Create(CMapEditorView*)` | `Reset()` | 时间特效关键帧变更通过 `DoAction()` 写回 |
| `CMaskEditorDlg` | `Create(CMapEditorView*)` | `Reset()` | 遮罩参数修改通过 `DoAction()` 写回 |
| `CSmallMapDlg` | `Create(CMapEditorView*)` | `TryInvalidate()` / `OnPaint()` | 小地图预览、打印屏导出，不直接改地图主数据 |
| `CSelectGroundDlg` | `Create(CMapEditorView*)` | 地砖列表刷新 | 返回当前地砖选择给 `CMapEditorView` / `CMapEditorGroundCtrl` |
| `CSelectObjectDlg` | `Create(CMapEditorView*)` | 资源列表刷新 | 返回当前对象资源选择给 `CMapEditorObjsCtrl` |
| `CSelectWaterDlg` | `Create(CMapEditorView*)` | `RenewList()` | 返回水面特效和水面 tile 选择 |
| `CViewPropDlg` | 模态对话框 | `OnPaint()` | `OnBnClickedSaveProp()` 写回 `MapEditorCfg.ini` |
| `CAllObjectResourceDlg` | 模态对话框 | `OnInitDialog()` / `OnPaint()` | 对资源引用做统计、清理和浏览，不直接写地图主文件 |
| `CTriggerEditorDlg` / `CBackgroundInfoDlg` / `CWaterAreaInfoDlg` | 模态对话框 | `OnInitDialog()` | 为列表面板提供单项属性编辑 |

### 7.2 面板与视图的交互

当前面板交互可以归纳成 4 条固定链路：

| 链路 | 触发源 | 中间层 | 最终写回 |
|------|--------|--------|----------|
| 图层链路 | `CLayerListDlg` 选择/勾选/增删 | `CMapEditorView` | `CMapEditorDoc` / `CToolsMap` |
| 对象链路 | `CObjectListDlg` / `CTransparentObjectListDlg` / `CTriggerListDlg` | `CMapEditorView` + `DoAction()` | `CActionList` 应用到 `CToolsMap` |
| 配置链路 | `CViewPropDlg` / `TimeEffectEditorDlg` / `MaskEditorDlg` | `CMapEditorView` | 文档数据或 `MapEditorCfg.ini` |
| 预览链路 | `CSmallMapDlg` / `PerformanceDlg` / `AllObjectResourceDlg` | `CDisplayMapBase` / 渲染缓存 | 只读或旁路分析，不直接改主地图 |

典型的消息到数据路径：

1. 面板通过 `Create(this)` 或模态 `DoModal()` 绑定 `CMapEditorView`。
2. 面板从 `GetDocument()`、`GetToolsMap()` 或 `CMapEditorView` 的访问器中读取当前状态。
3. 需要支持撤销的修改会先构造 `CAction`，再调用 `CMapEditorView::DoAction()`。
4. `DoAction()` 最终进入 `CActionList`，并由 `Set*` 系列函数作用到 `CToolsMap`。
5. 不走撤销链的修改通常直接调用 `SetModifiedFlag()`、`RenewList()`、`ReNewTree()`、`TryInvalidate()` 进行 UI 同步。

---

## 8. 数据结构参考

### 8.1 sImgInfo (图片信息)

定义位置：`ImgInfo.h`

| 字段 | 类型 | 当前含义 |
|------|------|----------|
| `m_nFileHeight` | `int` | 原始图片文件高度 |
| `m_nFileWidth` | `int` | 原始图片文件宽度 |
| `m_HandleArray` | `vector<PictureHandle>` | 已加载到渲染器的图片句柄数组 |
| `m_RectArray` | `vector<CRECT>` | 子图矩形列表 |
| `m_nCol` | `BYTE` | 图集列数 |
| `m_nRow` | `BYTE` | 图集行数 |
| `m_Positions[4]` | `POINT[4]` | 图片四个基准点 |
| `m_CenterPoint` | `POINT` | 图片中心点 |

当前赋值语义：

- `operator=(Nuclear::PImg&)` 会把 `PImg` 中的中心点、四角基点、行列数、子图矩形和文件尺寸拷入 `sImgInfo`。
- `m_HandleArray` 在赋值时只 `clear + reserve`，实际句柄由渲染加载阶段填充，而不是从 `PImg` 直接复制。

### 8.2 TILT_TYPE_ID (地砖类型联合体)

定义位置：`MapEditor.h`

| 字段 | 位宽 | 当前用途 |
|------|------|----------|
| `type` | 8 bit | 地砖尺寸类别，当前与 `TST_SMALL / TST_MIDDLE / TST_BIG` 对应 |
| `tileType` | 24 bit | 地砖资源类型编号 |
| `id` | 32 bit | 组合后的完整 key |

当前主要使用场景：

- `CMapEditorApp::CheckTileType()` 用它把“尺寸类别 + 地砖类型”压成一个 `unsigned int` key。
- `CToolsMap::CleanGround()` 用它查询 `theApp.GetTileType()`，判断某类地砖资源是否可用。

### 8.3 CLayerView 图层编辑 ID

定义位置：`LayerView.h`

#### `LAYER_EDIT_ID`

| 值 | 标识 | 当前用途 |
|----|------|----------|
| 0 | `LEI_GROUND` | 地表编辑层 |
| 1 | `LEI_WATER_1` | 水下 1 层 |
| 2 | `LEI_WATER_2` | 水下 2 层 |
| 3-8 | `LEI_LOW_1` ~ `LEI_LOW_6` | 低对象层 |
| 9 | `LEI_MID` | 对象中层 |
| 10-11 | `LEI_HIGH_1` / `LEI_HIGH_2` | 高对象层 |
| 12 | `LEI_TRANS` | 透明对象层 |
| 13 | `LEI_TRIGGER` | 触发器层 |
| 14 | `LEI_WATER` | 水面区域层 |
| 15 | `LEI_BACKGROUND` | 背景层 |
| 16 | `LEI_GAMING` | 游戏预览层 |

#### `LAYER_OBJ_TYPE`

| 标识 | 当前语义 |
|------|----------|
| `LOT_ELEMENT` | 普通元素对象 |
| `LOT_EFFECT` | 特效对象 |
| `LOT_LINKEDOBJECT` | 联动对象 |
| `LOT_DISTORT` | 扭曲对象 |
| `LOT_SPRITE` | 编辑器精灵预览对象 |
| `LOT_TRIGGER_EFFECT` | 触发器特效对象 |

#### 当前辅助函数

| 函数 | 作用 |
|------|------|
| `ConvertObjectType()` | `MAP_OBJ_TYPE` 与 `LAYER_OBJ_TYPE` 互转 |
| `GetSortBaseId()` | 把对象 ID 与对象类型编码成 `SortBaseId` |
| `GetObjectId()` | 从 `SortBaseId` 提取对象 ID |
| `GetObjectType()` | 从 `SortBaseId` 提取对象类型 |

### 8.4 sModifyCanvasParam (画布修改参数)

定义位置：`MapEditorDoc.h`

| 字段 | 类型 | 当前用途 |
|------|------|----------|
| `m_NewWidth` | `int` | 新地图宽度（像素） |
| `m_NewHeight` | `int` | 新地图高度（像素） |
| `m_ModifyMode` | `int` | 3x3 对齐矩阵索引，决定旧地图内容对齐方式 |
| `m_EffectName[WATER_EFFECT_COUNT]` | `wstring[3]` | 水面效果资源名 |

当前调用链：

- `CMapEditorView::OnEditMapInfo()` 读取 `CRegionMapInfoDlg` 的结果并填充该结构。
- `CMapEditorDoc::ModifyCanvas()` 读取该结构后，分发到 tile / object / background / water-area 的调整函数。

修改模式矩阵（水平 x 垂直）：

| 模式 | 水平对齐 | 垂直对齐 |
|------|---------|---------|
| 0 | 左对齐 | 顶部对齐 |
| 1 | 居中 | 顶部对齐 |
| 2 | 右对齐 | 顶部对齐 |
| 3 | 左对齐 | 居中 |
| 4 | 居中 | 居中 |
| 5 | 右对齐 | 居中 |
| 6 | 左对齐 | 底部对齐 |
| 7 | 居中 | 底部对齐 |
| 8 | 右对齐 | 底部对齐 |

### 8.5 MapClipboardCont (剪贴板内容)

定义位置：`MapClipboardContentMaker.h/.cpp`

#### 结构体字段

| 字段 | 类型 | 当前含义 |
|------|------|----------|
| `name` | `std::wstring` | 对象资源名 |
| `type` | `Nuclear::PMap::MAP_OBJ_TYPE` | 对象类型 |
| `rect` | `CRect` | 对象包围矩形 |
| `point` | `CPoint` | 对象放置点 |
| `attachColor` | `unsigned int` | 附加颜色 |

#### 当前封装类

| 类 / 成员 | 当前用途 |
|-----------|----------|
| `CMapClipboardContentMaker` | 地图对象剪贴板序列化与反序列化 |
| `m_Container` | `vector<MapClipboardCont>`，实际对象载荷 |
| `m_Type` | 当前仅定义了 `MCCT_OBJ` |
| `ms_ClipboardFormatID` | 注册到系统剪贴板的格式 ID |

#### 当前二进制格式

`MakeMapClipboardContent()` 当前写出的内存块格式：

1. `int size`
2. `char type`
3. `int count`
4. 对于每个对象：
   - `wstring name`
   - `char objType`
   - `CRect rect`
   - `CPoint point`
   - `unsigned int attachColor`

`GetDataFromMapClipboardContent()` 会按同一顺序反序列化，并在读取后释放 `GlobalAlloc` 得到的句柄。

---

## 9. 使用指南

### 9.1 构建与运行

当前已验证的最小构建事实：

| 项目 | 当前值 |
|------|--------|
| 工程文件 | `tools/engine/MapEditor/MapEditor.vcxproj` |
| 工具集 | `v120` |
| 字符集 | `Unicode` |
| Release 产物 | `client/resource/tools/MapEditor.exe` |

推荐命令：

```powershell
& 'C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe' `
  'tools/engine/MapEditor/MapEditor.vcxproj' `
  /t:Build `
  /p:Configuration=Release `
  /p:Platform=Win32 `
  /m `
  /v:minimal
```

### 9.2 基本操作流程

当前编辑主线入口：

| 步骤 | 入口 | 当前行为 |
|------|------|----------|
| 1 | `OnNewDocument()` / `OnOpenDocument()` | 创建或加载工具格式地图 |
| 2 | `SetEditMode()` | 切换地表 / 对象 / 触发器 / 水面 / 背景等模式 |
| 3 | `CMapEditorGroundCtrl` | 处理地表、水面 tile、颜色、超级删除等 |
| 4 | `CMapEditorObjsCtrl` | 处理对象添加、拖拽、删除、基点修改 |
| 5 | `DoAction()` / `UnDo()` / `ReDo()` | 写入或回放撤销链 |
| 6 | `OnSaveDocument()` | 保存工具格式地图并同步资源侧改动 |
| 7 | `ExportToFile()` | 导出运行时地图，附带资源预检 |

### 9.3 导入与合并

| 模式 | 入口 | 当前行为 |
|------|------|----------|
| 导入 | `CMapEditorApp::OnImport()` | 替换当前地图 |
| 合并导入 | `CMapEditorApp::OnMergeImport()` | 将外部地图合并进当前地图 |

当前导入流程补充事实：

- 两个入口都会先通过 `m_pDocManager->OnFileNew()` 创建文档。
- 后续在 `CMapEditorDoc::OnNewDocument()` 中读取 `theApp.IsImport()` / `theApp.IsMergeImport()` 决定走导入或合并导入路径。
- 合并导入的最终地图合并逻辑在 `CToolsMap::MargeMap()` 中完成。

### 9.4 快捷键

| 操作 | 快捷键 |
|------|--------|
| 撤销 | Ctrl+Z |
| 重做 | Ctrl+Y |
| 复制 | Ctrl+C |
| 粘贴 | Ctrl+V |
| 剪切 | Ctrl+X |
| 备用撤销 | Alt+Backspace |
| 备用复制 | Ctrl+Insert |
| 备用粘贴 | Shift+Insert |
| 备用剪切 | Shift+Delete |
| 缩放+ | 鼠标滚轮上 |
| 缩放- | 鼠标滚轮下 |
| 吸附 | Shift |

当前还定义了层切换快捷键：

| 操作 | 快捷键 |
|------|--------|
| 地表层 | F1 |
| 水下 1 层 | F2 |
| 水面特效层 | F3 |
| 低对象层 1-3 | F4 / F5 / F6 |
| 中对象层 | F7 |
| 高对象层 1-2 | F8 / F9 |
| 传送对象层 | F10 |
| 触发器层 | F11 |
| 游戏层 | F12 |
| 显示开关 | 对应 `Ctrl + F1..F11` |

### 9.5 `MapEditorCfg.ini` 当前生效键

| Section | Key | 默认值 | 当前用途 |
|---------|-----|--------|----------|
| `SAVE` | `AutoSave` | `0` | 自动保存间隔（分钟） |
| `VIEW` | `MagnetRadio` | `20` | 吸附半径 |
| `VIEW` | `BaseColor` | `FFFFFFFF` | 视图基础色 |
| `VIEW` | `GirdColor` | `FF000000` | 网格颜色 |
| `VIEW` | `BackGroundColor` | `FF00C090` | 背景色 |
| `QUALITY` | `UseHDTiles` | `0` | 是否优先预览 `/map/tiles_hd/` |
| `Sprite` | `Model` | `male` | 预览精灵模型名 |
| `Sprite` | `Component` | `body:...,head:...,weapon:...` | 预览精灵部件映射 |
| `Sprite` | `RideName` | 空 | 坐骑名 |
| `Sprite` | `RunLeft` | `runleft` | 左向移动动作 |
| `Sprite` | `RunRight` | `runright` | 右向移动动作 |
| `Sprite` | `Stand` | `stand1` | 站立动作 |

当前读写入口：

| 键组 | 读取位置 | 写入位置 |
|------|----------|----------|
| `SAVE.AutoSave` | `CMapEditorDoc::SetAutoSave()` | 无 UI 写回入口，需手工改配置 |
| `VIEW.MagnetRadio` | `CMapEditorView` 初始化 | `CViewPropDlg::OnBnClickedSaveProp()` |
| `VIEW.BaseColor / GirdColor / BackGroundColor` | `CDisplayMapBase` 初始化 | `CViewPropDlg::OnBnClickedSaveProp()` |
| `QUALITY.UseHDTiles` | `CDisplayMapBase::UseHighDefinitionTiles()` | 当前无 UI 写回入口，需手工改配置 |
| `Sprite.*` | `CMapEditorView` 初始化 | 当前无专门配置面板，主要用于启动时预览精灵 |

---

## 10. 技术边界与已知限制

### 10.1 平台限制

- 仅支持 Windows 平台（MFC + DirectX 9）
- 不支持跨平台编译

### 10.2 数据限制

- 撤销/重做最大 50 步
- 地砖尺寸固定为 128x64 / 256x256 / 512x512，水面格为 128x128
- 对象类型固定为 4 种（ELEMENT / EFFECT / LINKEDOBJ / DISTORT）
- 画布尺寸必须为 `TILE_WIDTH=128` 与 `TILE_HEIGHT=64` 的整数倍

### 10.3 当前未解决问题与保留项

| 类别 | 项目 | 当前状态 | 说明 |
|------|------|----------|------|
| 历史兼容 | `Operator.*` / `OperatorList.*` | 保留 | 仍存在于代码树中，但不应视为当前主线实现 |
| 缓存治理 | 渲染资源缓存 | 未实现 LRU | 长时间编辑大地图仍可能持续增长 |
| 功能边界 | 高清地砖 | 仅编辑器预览接入 | 尚未进入客户端运行时地图渲染链 |
| 配置刷新 | `UseHDTiles` 运行时切换 | 需重启视图/工具生效 | 当前在 `CDisplayMapBase` 初始化时读取并缓存 |
| 工具边界 | `Build-MapTile-AlphaBleed.ps1` | 可用但偏离线 | 适合批处理，不适合交互式大规模实时预处理 |

补充裁决（2026-04-25）：

- `textureFilter` 默认路径继承上一批次 sampler state：已修复，不再属于“当前未解决问题”。
- 高清地砖开关位于渲染热路径每次读盘：已修复，不再属于“当前未解决问题”。
- 导出预检与正式导出重复执行 `CleanMap()`：已修复，不再属于“当前未解决问题”。

## 11. 最新现状与静态审计

> **基线日期**: 2026-04-24  
> **适用范围**: `tools/engine/MapEditor/**` 当前代码树  
> **说明**: 第 10 节描述长期限制与保留边界；第 11 节描述当前代码状态。若两者冲突，以第 11 节为准。

### 11.1 代码目录最新现状

当前 `MapEditor` 代码树的源码口径统计如下：

| 类别 | 数量 / 行数 | 说明 |
|------|------------|------|
| 跟踪文件总数 | 108 | `rg --files tools/engine/MapEditor` 统计口径 |
| `.cpp` 文件 | 46 | 仅统计源码实现文件 |
| `.h` 文件 | 50 | 仅统计头文件 |
| 对话框相关源码/头文件 | 46 | 命名匹配 `*Dlg.*` / `*Dialog.*` |
| 核心框架代码 | 7,762 行 | `App/MainFrm/ChildFrm/Doc/View` |
| 地图工具代码 | 1,322 行 | `ToolsMap.*` |
| 操作与撤销系统 | 1,244 行 | `Action.*` + `ActionList.*` |
| 渲染与屏幕元素 | 2,811 行 | `DisplayMapBase.*` + `EditorRender.*` + `ScreenElements.*` |
| 编辑控件 | 798 行 | `MapEditorGroundCtrl.*` + `MapEditorObjsCtrl.*` |
| 辅助模块 | 581 行 | `Sprite`、`CrashDump`、`Clipboard`、`ImgInfo` |
| 对话框总行数 | 8,951 行 | 对话框类 `.cpp/.h` 汇总 |

当前与 2026-04-24 本轮代码状态直接相关的新增或已确认能力：

- 导出前资源预检：`CMapEditorDoc::ExportToFile()` 先调用 `ValidateExportResources()`，发现缺失资源时阻止静默导出。
- 高清地砖预览旁路：`PPathMap` 新增 `/map/tiles_hd/` 映射接口，MapEditor 通过 `MapEditorCfg.ini` 中 `[QUALITY] UseHDTiles=1` 控制预览。
- 分层采样策略：`Renderer::DrawPictureParam` / `DrawBatchPictureParam` 新增 `textureFilter`，MapEditor 地表 1:1 预览改为 point，缩放预览改为 linear。
- 资源预处理脚本：新增 `tools/scripts/Build-MapTile-AlphaBleed.ps1`，用于 PNG 透明边缘颜色外扩。
- 菜单本地化：窗口菜单子项资源字符串已改为中文。
- 相关 DirectX 工具工程已覆盖 `C4005` 兼容策略，`MapEditor / EffectEditor / SpriteEditor / ImageEditor / ParticleSystemEditor / DistortionEditor / LinkedObjectEditor / SoundEditor / picconverter / MazeAndNpcEditor / SpriteSoundEditor` 当前均已收口到工程级白名单。

### 11.2 当前静态审计结论

以下问题是基于当前代码状态的最新静态审计结论：

| 级别 | 问题 | 位置 | 说明 |
|------|------|------|------|
| 中 | `textureFilter` 默认路径可能继承上一次采样状态 | `engine/renderer/dx9renderer.cpp:1978` | 当前仅在 `FILTER_POINT/FILTER_LINEAR` 时显式设置 `MIN/MAGFILTER`；若后续绘制走 `FILTER_DEFAULT`，可能沿用上一批次采样状态 |
| 中 | 高清地砖开关读取位于渲染热路径辅助函数中 | `MapEditor/DisplayMapBase.cpp:24` | `UseHighDefinitionTiles()` 每次缓存缺失时都会读取 `MapEditorCfg.ini`，在大地图首次预览阶段会产生额外 I/O 与配置解析开销 |
| 低 | 导出预检与正式导出都会执行 `CleanMap()` | `MapEditorDoc.cpp:161`、`ToolsMap.cpp:1106` | 当前实现优先保证正确性与不污染当前地图状态，但会在大地图导出时重复遍历地表和对象资源 |
| 低 | `Operator.*` / `OperatorList.*` 仍保留旧版重复定义 | `MapEditor` 根目录 | 当前没有移除，文档和审计都应继续把它视为历史兼容文件而非主线实现 |

### 11.3 已修复并已体现在代码中的问题

以下问题已不应再作为当前代码状态中的“待修复风险”描述：

- `ModifyBackgroundInfo` 旧 `pPics` 泄漏：已修复。
- 地表相关 `new[] / delete` 不匹配：已修复。
- `UndoOneAction()` 失败后游标错位：已修复。
- 导出遇到缺失资源时静默置空并继续导出：已改为导出前阻断。
- 导出预检与正式导出重复执行 `CleanMap()`：已修复，当前复用同一份清洗后的导出副本。
- `textureFilter` 默认路径继承上一批次 sampler state：已修复，当前局部覆盖后恢复原 sampler。
- 高清地砖开关位于渲染热路径每次读盘：已修复，当前在 `CDisplayMapBase` 初始化时缓存。
- `MapEditor` 主工程及相关工具链的 `MSB8012` / `C4005` 既有构建噪音：本轮已在主线工具工程中清理。

### 11.4 当前判定优先级

阅读和维护当前 `MapEditor` 代码时，建议按以下优先级理解问题：

1. 第 11 节中的“当前静态审计结论”视为真正仍在生效的问题。
2. 第 10 节中的条目视为长期边界、功能范围或技术债背景。
3. 第 6、7 节若与第 11 节冲突，应视为历史扫描结果，不再直接代表当前代码状态。

## 12. 完修验收清单与回归测试矩阵

### 12.1 完修验收清单

| 类别 | 验收项 | 当前状态 | 验证方式 |
|------|--------|----------|----------|
| 构建 | `MapEditor.vcxproj` Release 构建成功 | 已完成 | `MSBuild /t:Build /p:Configuration=Release /p:Platform=Win32` |
| 构建 | 主线 DirectX 工具工程 `C4005` 收敛 | 已完成 | 工程级白名单 + 逐个构建 |
| 稳定性 | 背景 `pPics` 尺寸变更不泄漏旧缓冲区 | 已完成 | 代码审查 + 构建通过 |
| 稳定性 | 地表相关 `new[]/delete` 不匹配已清理 | 已完成 | 代码审查 + 构建通过 |
| 稳定性 | 撤销失败不破坏游标 | 已完成 | `UndoOneAction()` 当前提交语义 |
| 导出 | 缺失资源时阻断运行时导出 | 已完成 | `ExportToFile()` 预检链 |
| 导出 | 预检与正式导出不再重复清洗 | 已完成 | `PrepareExportMap()` + `SaveRuntimeMapToFile()` |
| 预览 | 地表 1:1 / 缩放采样显式区分 | 已完成 | `textureFilter` 接入与恢复 |
| 预览 | 高清 tile 旁路可用 | 已完成 | `PPathMap::GetHighDefinitionTileFileName()` + `UseHDTiles` |
| 文档 | 技术文档与深度报告已同步到当前代码状态 | 已完成 | 当前两份文档 |

### 12.2 回归测试矩阵

| 测试域 | 场景 | 目标 | 当前建议 |
|--------|------|------|----------|
| 文件 I/O | 新建 / 打开 / 保存 / 重新打开 | 工具格式读写一致 | 必测 |
| 运行时导出 | 资源完整 / 资源缺失 | 缺失资源阻断、正常资源可导出 | 必测 |
| 地表编辑 | 小 / 中 / 大地表绘制、颜色层、水面 tile | 数据正确、撤销正确 | 必测 |
| 图层管理 | 新建图层、删除图层、调整可见性与名称 | 图层数组与 UI 同步 | 必测 |
| 对象编辑 | 添加 / 移动 / 删除 / 复制粘贴对象 | 对象数据与选择集一致 | 必测 |
| 触发器 / 水区 / 背景 | 新增、编辑、删除、列表刷新 | 树/列表与底层数据一致 | 必测 |
| 画布修改 | 9 种对齐模式、大地图警告框 | 快照提示、数据迁移正确 | 必测 |
| 预览渲染 | 1:1、缩放、普通 tile、高清 tile | point/linear 行为正确、高清回退正确 | 必测 |
| 长时会话 | 连续编辑 + 滚屏 + 面板开关 + 多次保存 | 无异常增长或状态错乱 | 建议 |
| 资源工具链 | Alpha bleed 小样本批处理 | 输出 PNG 正常 | 已完成脚本小样本验证 |

### 12.3 2026-04-25 smoke 执行记录

本轮通过 `MapEditor.exe /smoketest <MapEditor*.mrmp> <临时输出目录>` 执行了一次半自动验收，样本为：

- 输入样本：`client/resource/res/map/5001_dayanta1/MapEditor1.mrmp`
- 输出目录：`%TEMP%/MapEditorSmoke_20260425_022046/`

示例命令：

```powershell
& 'E:\MT3\client\resource\tools\MapEditor.exe' `
  /smoketest `
  'E:\MT3\client\resource\res\map\5001_dayanta1\MapEditor1.mrmp' `
  "$env:TEMP\MapEditorSmoke_xxx"
```

结果如下：

| 项目 | 结果 | 说明 |
|------|------|------|
| 打开文档 | 通过 | `OpenDocumentFileDirect: PASS` |
| 保存工具地图 | 通过 | `smoke_saved.map` 已生成 |
| 保存后回读 | 通过 | `ReloadSavedMap: PASS` |
| 地表编辑 | 未通过 | `GroundEdit: FAIL`，仍需进一步确认样本地图的可编辑地表层状态 |
| 画布修改 | 通过 | `ModifyCanvas: PASS` |
| 保存画布修改结果 | 通过 | `smoke_canvas_edited.map` 已生成 |
| 运行时导出准备 | 通过 | `PrepareExport: PASS` |
| 运行时导出 | 未通过 | `ExportHasMissingFiles: PASS`、`ExportRuntimeMap: FAIL`，当前样本存在缺失资源阻断导出 |
| 预览渲染截图 | 通过 | 已生成多张 `preview_*.jpg` |
| 总体结果 | 未通过 | 该轮 smoke 暴露了“样本资源完整性”和“地表编辑样本适配性”两个剩余问题 |

**许可证**: 内部使用

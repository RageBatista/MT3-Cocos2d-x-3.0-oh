# 02 — 模块功能说明（Module Description）

> **版本**: 1.0.0  
> **更新日期**: 2026-04-25  
> **源码路径**: `tools/engine/npceditor/`

---

## 1. SoundApp 模块（引擎应用核心）

### 1.1 概述

[`SoundApp`](../SoundApp.h:75) 是 NPC 编辑器的核心引擎应用层，继承 `Nuclear::IApp`（定义在 `SoundApp.h:75`），负责管理所有编辑数据和引擎渲染回调。该模块是编辑器业务逻辑的主要承载者。

### 1.2 继承关系

```
Nuclear::IApp
    └── SoundApp (SoundApp.h:75)
```

### 1.3 自定义类型

| 类型名 | 定义 | 位置 | 说明 |
|--------|------|------|------|
| [`SpriteMap`](../SoundApp.h:79) | `std::map<Nuclear::ISprite*, Sprite*>` | `SoundApp.h:79` | 引擎精灵到包装精灵的映射 |
| [`NpcList`](../SoundApp.h:80) | `std::vector<CNpc*>` | `SoundApp.h:80` | NPC 实例列表 |
| [`NpcBaseList`](../SoundApp.h:81) | `std::vector<stNpcBaseData*>` | `SoundApp.h:81` | NPC 基础数据表 |
| [`MonsterBaseList`](../SoundApp.h:198) | `std::vector<stMonsterBaseData*>` | `SoundApp.h:198` | 怪物基础数据表 |

### 1.4 关键成员变量

#### 引擎与文档

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_pEngine`](../SoundApp.h:86) | `Nuclear::IEngine*` | `SoundApp.h:86` | Nuclear 引擎实例 |
| [`m_editState`](../SoundApp.h:87) | `EDIT_STATE` | `SoundApp.h:87` | 当前编辑状态 |
| [`m_pHero`](../SoundApp.h:88) | `Sprite*` | `SoundApp.h:88` | 测试模式主角精灵 |
| [`m_pDoc`](../SoundApp.h:89) | `CSoundEditorDoc*` | `SoundApp.h:89` | 关联文档 |
| [`m_pNpcDlg`](../SoundApp.h:90) | `CNpcPropertyDlg*` | `SoundApp.h:90` | NPC 属性对话框指针 |
| [`m_pJPInfDlg`](../SoundApp.h:91) | `CJumpPointInfDlg*` | `SoundApp.h:91` | 跳转点信息对话框指针 |
| [`m_bEngineInited`](../SoundApp.h:289) | `bool` | `SoundApp.h:289` | 引擎是否已初始化 |

#### 迷宫阻挡

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_MazeBuffer`](../SoundApp.h:100) | `unsigned char*` | `SoundApp.h:100` | 迷宫阻挡缓冲（每格一字节） |
| [`m_mapGridWidth`](../SoundApp.h:101) | `size_t` | `SoundApp.h:101` | 地图网格宽度 |
| [`m_mapGridHeight`](../SoundApp.h:102) | `size_t` | `SoundApp.h:102` | 地图网格高度 |
| [`m_BlockRectList`](../SoundApp.h:103) | `std::vector<Nuclear::FRECT>` | `SoundApp.h:103` | 阻挡矩形列表（绿色 0x1） |
| [`m_BlockRectList1`](../SoundApp.h:105) | `std::vector<Nuclear::FRECT>` | `SoundApp.h:105` | 阻挡矩形列表 1 |
| [`m_BlockRectList2`](../SoundApp.h:106) | `std::vector<Nuclear::FRECT>` | `SoundApp.h:106` | 阻挡矩形列表 2 |

#### NPC 数据

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_NpcList`](../SoundApp.h:107) | `NpcList` | `SoundApp.h:107` | 当前地图 NPC 实例列表 |
| [`m_NpcBaseList`](../SoundApp.h:108) | `NpcBaseList` | `SoundApp.h:108` | 全局 NPC 基础数据表 |
| [`m_strNpcXmlName`](../SoundApp.h:109) | `std::wstring` | `SoundApp.h:109` | NPC XML 文件名 |
| [`m_strGotoXmlName`](../SoundApp.h:110) | `std::wstring` | `SoundApp.h:110` | 跳转点 XML 文件名 |
| [`m_pCurSelNpc`](../SoundApp.h:112) | `CNpc*` | `SoundApp.h:112` | 当前选中的 NPC |
| [`m_pEditNpc`](../SoundApp.h:158) | `CNpc*` | `SoundApp.h:158` | 当前编辑中的 NPC |

#### NPC 资源映射

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_NpcShapeMap`](../SoundApp.h:114) | `std::map<int, std::wstring>` | `SoundApp.h:114` | NPC 造型映射 |
| [`m_NpcBodyNameMap`](../SoundApp.h:115) | `std::map<int, std::wstring>` | `SoundApp.h:115` | NPC 身体资源名映射 |
| [`m_NpcHeadNameMap`](../SoundApp.h:116) | `std::map<int, std::wstring>` | `SoundApp.h:116` | NPC 头部资源名映射 |
| [`m_NpcHairNameMap`](../SoundApp.h:117) | `std::map<int, std::wstring>` | `SoundApp.h:117` | NPC 头发资源名映射 |
| [`m_NpcDirMap`](../SoundApp.h:119) | `std::map<std::wstring, int>` | `SoundApp.h:119` | NPC 方向映射 |

#### 区域数据

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_RegionBuffer`](../SoundApp.h:293) | `CRegionBuffer<unsigned short>` | `SoundApp.h:293` | 区域类型稀疏缓冲 |
| [`m_regionType`](../SoundApp.h:99) | `int` | `SoundApp.h:99` | 当前区域类型 |
| [`m_AreaHandle`](../SoundApp.h:95) | `Nuclear::PictureHandle` | `SoundApp.h:95` | 区域渲染图片句柄 |

#### 跳跃阻挡与孤岛

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_JumpBlockBuffer`](../SoundApp.h:324) | `unsigned char*` | `SoundApp.h:324` | 跳跃阻挡缓冲 |
| [`m_IslandBuffer`](../SoundApp.h:325) | `char*` | `SoundApp.h:325` | 孤岛信息缓冲（1 层） |
| [`m_IsLandNumber`](../SoundApp.h:326) | `int` | `SoundApp.h:326` | 孤岛个数（1 层） |
| [`m_IslandBuffer2`](../SoundApp.h:328) | `char*` | `SoundApp.h:328` | 孤岛信息缓冲（2 层） |
| [`m_IsLandNumber2`](../SoundApp.h:329) | `int` | `SoundApp.h:329` | 孤岛个数（2 层） |

#### 跳转点

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_vecJumpVector`](../SoundApp.h:282) | `std::vector<stJumpPointInf>` | `SoundApp.h:282` | 跳转点列表 |
| [`m_selectJumpPointID`](../SoundApp.h:283) | `int` | `SoundApp.h:283` | 当前选中的跳转点 ID |
| [`m_EditJumpPointID`](../SoundApp.h:284) | `int` | `SoundApp.h:284` | 当前编辑中的跳转点 ID |

#### 怪物数据

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_Monbuffer`](../SoundApp.h:276) | `std::map<unsigned int, int>` | `SoundApp.h:276` | 怪物点缓冲 |
| [`m_monsterBaseList`](../SoundApp.h:199) | `MonsterBaseList` | `SoundApp.h:199` | 怪物基础数据列表 |
| [`m_MonBlockList`](../SoundApp.h:208) | `std::map<int, MonsterInfo>` | `SoundApp.h:208` | 怪物区域列表 |
| [`m_pMonPanel`](../SoundApp.h:194) | `CMonsterPanel*` | `SoundApp.h:194` | 怪物面板指针 |
| [`monKind`](../SoundApp.h:277) | `int` | `SoundApp.h:277` | 当前怪物种类 |
| [`monIndex`](../SoundApp.h:278) | `int` | `SoundApp.h:278` | 当前怪物索引 |

#### 渲染控制

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_bDrawGird`](../SoundApp.h:96) | `bool` | `SoundApp.h:96` | 是否绘制网格 |
| [`m_bDrawBlock`](../SoundApp.h:97) | `bool` | `SoundApp.h:97` | 是否绘制阻挡 |
| [`m_BlockColorList`](../SoundApp.h:279) | `std::vector<Nuclear::XPCOLOR>` | `SoundApp.h:279` | 阻挡颜色列表 |
| [`m_EdgeSize`](../SoundApp.h:121) | `int` | `SoundApp.h:121` | 笔刷边缘大小 |

### 1.5 关键成员函数

#### 引擎生命周期回调

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`bool OnInit(int step)`](../SoundApp.h:225) | `SoundApp.h:225` | 引擎初始化：设置环境参数、加载字体、加载 NPC/怪物基础表 |
| [`bool OnExit()`](../SoundApp.h:227) | `SoundApp.h:227` | 引擎退出清理 |
| [`void OnTick(int now, int delta)`](../SoundApp.h:229) | `SoundApp.h:229` | 主线程每帧调用，处理与渲染无关的日常工作 |
| [`bool OnBeforeRender(int now)`](../SoundApp.h:230) | `SoundApp.h:230` | 每帧渲染前调用，返回 false 则不渲染 |
| [`void OnRenderUI(int now)`](../SoundApp.h:231) | `SoundApp.h:231` | 每帧 UI 渲染：绘制网格、阻挡区域、NPC 名字、跳转点标志等 |
| [`void OnUpdateSpriteAction(ISprite*, XPUSA_TYPE)`](../SoundApp.h:233) | `SoundApp.h:233` | 精灵状态改变回调，更新动作 |

#### 迷宫阻挡操作

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`bool ReadMazeBuffer(CString)`](../SoundApp.h:135) | `SoundApp.h:135` | 从二进制文件读取迷宫阻挡数据 |
| [`bool WriteMazeBuffer(CString)`](../SoundApp.h:136) | `SoundApp.h:136` | 写入迷宫阻挡数据（含孤岛检查） |
| [`void NewMazeBuffer()`](../SoundApp.h:137) | `SoundApp.h:137` | 创建新的迷宫阻挡缓冲 |
| [`void SetBlockPoint(CPoint, bool, bool, bool, unsigned char)`](../SoundApp.h:134) | `SoundApp.h:134` | 设置阻挡点（支持全屏刷/笔刷/多层） |
| [`unsigned char GetMazeMask(CPoint pixel)`](../SoundApp.h:152) | `SoundApp.h:152` | 获取指定像素位置的阻挡掩码 |
| [`void SetMazeMask(unsigned int, CPoint, bool, bool)`](../SoundApp.h:153) | `SoundApp.h:153` | 设置指定位置的阻挡掩码 |
| [`void ClearMazeMask(unsigned int, CPoint, bool)`](../SoundApp.h:155) | `SoundApp.h:155` | 清除指定位置的阻挡掩码 |
| [`void CheckMazeLayer2IsNew()`](../SoundApp.h:151) | `SoundApp.h:151` | 检测 2 层阻挡是否为新的（未刷过则全刷上） |
| [`bool CheckLonelyIsland()`](../SoundApp.h:160) | `SoundApp.h:160` | 孤岛检测算法 |
| [`void JumpToIsland(int islandIdx)`](../SoundApp.h:161) | `SoundApp.h:161` | 跳到孤岛的第一个格子作为屏幕中心 |

#### NPC 操作

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void LoadAllBaseNpc()`](../SoundApp.h:163) | `SoundApp.h:163` | 加载全部基础 NPC 数据 |
| [`void LoadNpcShapeMap()`](../SoundApp.h:164) | `SoundApp.h:164` | 加载 NPC 造型映射 |
| [`void RemoveAllBaseNpc()`](../SoundApp.h:165) | `SoundApp.h:165` | 清除全部基础 NPC 数据 |
| [`const stNpcBaseData* GetNpcBaseById(int id)`](../SoundApp.h:166) | `SoundApp.h:166` | 根据 ID 获取 NPC 基础数据 |
| [`void ResetMapNpc(std::wstring)`](../SoundApp.h:167) | `SoundApp.h:167` | 从 XML 加载地图 NPC 实例 |
| [`void AddNpc(int, int, int, Location)`](../SoundApp.h:168) | `SoundApp.h:168` | 添加 NPC 到指定位置 |
| [`void RemoveNpc(CNpc*)`](../SoundApp.h:169) | `SoundApp.h:169` | 移除指定 NPC |
| [`bool SelectNpc(CPoint pt)`](../SoundApp.h:171) | `SoundApp.h:171` | 通过点击位置选择 NPC |
| [`void MoveSelectNpc(CPoint pt)`](../SoundApp.h:172) | `SoundApp.h:172` | 移动选中的 NPC |
| [`void PutNpc(CPoint pt)`](../SoundApp.h:173) | `SoundApp.h:173` | 放置 NPC |
| [`CNpc* AddNewNpc(int baseid)`](../SoundApp.h:174) | `SoundApp.h:174` | 添加新 NPC 到地图 |
| [`int GetNewNpcBaseID()`](../SoundApp.h:157) | `SoundApp.h:157` | 获取新的 NPC BaseID |
| [`bool OnSaveNpcInf()`](../SoundApp.h:189) | `SoundApp.h:189` | 保存地图 NPC 信息到 XML |
| [`bool OnSaveNpcBaseInf()`](../SoundApp.h:188) | `SoundApp.h:188` | 保存 NPC 基础数据 |
| [`void DelCurEditNpc()`](../SoundApp.h:190) | `SoundApp.h:190` | 删除当前编辑的 NPC |

#### 跳转点操作

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`int AddJumpPoint(int, int, int, int, int)`](../SoundApp.h:246) | `SoundApp.h:246` | 添加跳转点（含特效） |
| [`int SelectJumpPointByPoint(CPoint)`](../SoundApp.h:247) | `SoundApp.h:247` | 通过坐标选择跳转点 |
| [`void DelectJumpPoint(int id)`](../SoundApp.h:248) | `SoundApp.h:248` | 删除跳转点 |
| [`void LoadJumpPoint(const std::wstring&)`](../SoundApp.h:249) | `SoundApp.h:249` | 从 XML 加载跳转点 |
| [`bool SaveJumpPointInf()`](../SoundApp.h:250) | `SoundApp.h:250` | 保存跳转点到 XML |
| [`void DrawJumpPoint()`](../SoundApp.h:251) | `SoundApp.h:251` | 绘制跳转点标志 |
| [`void AddNewJumpPoint()`](../SoundApp.h:252) | `SoundApp.h:252` | 添加新跳转点 |
| [`int GenerateNewJumpPointID()`](../SoundApp.h:255) | `SoundApp.h:255` | 生成新的跳转点 ID |
| [`void MoveSelJumpPoint(CPoint pt)`](../SoundApp.h:258) | `SoundApp.h:258` | 移动选中的跳转点 |
| [`bool PointCanJump(CPoint pt)`](../SoundApp.h:262) | `SoundApp.h:262` | 检查点是否可跳转 |

#### 区域操作

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void SetRegion(const int&, const int&, RegionType)`](../SoundApp.h:266) | `SoundApp.h:266` | 设置区域类型（切磋/播撒/摆摊/刷怪等） |
| [`void SetRegionBig(const int&, const int&, RegionType)`](../SoundApp.h:267) | `SoundApp.h:267` | 大笔刷设置区域类型 |
| [`void DelRegion(const int&, const int&, RegionType)`](../SoundApp.h:268) | `SoundApp.h:268` | 删除区域类型 |
| [`void DelRegionBig(const int&, const int&, RegionType)`](../SoundApp.h:269) | `SoundApp.h:269` | 大笔刷删除区域类型 |
| [`void WriteRegionBufferToFile(std::wstring)`](../SoundApp.h:271) | `SoundApp.h:271` | 写入区域缓冲到文件 |
| [`void ReadRegionBufferFromFile(std::wstring)`](../SoundApp.h:272) | `SoundApp.h:272` | 从文件读取区域缓冲 |

#### 跳跃阻挡操作

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void NewJumpBlockBuffer()`](../SoundApp.h:298) | `SoundApp.h:298` | 创建新的跳跃阻挡缓冲 |
| [`bool LoadJumpBlockInf(std::wstring)`](../SoundApp.h:299) | `SoundApp.h:299` | 加载跳跃阻挡信息 |
| [`void SetJumpBlock(CPoint, bool, unsigned char)`](../SoundApp.h:301) | `SoundApp.h:301` | 设置跳跃阻挡 |
| [`void SaveJumpBlockInf(std::wstring)`](../SoundApp.h:305) | `SoundApp.h:305` | 保存跳跃阻挡信息 |
| [`void SaveIslandInf(std::wstring, int)`](../SoundApp.h:306) | `SoundApp.h:306` | 计算并保存孤岛信息 |
| [`int processBlockInfo(char*, int, int)`](../SoundApp.h:308) | `SoundApp.h:308` | BFS 孤岛检测核心算法 |
| [`void DrawJumpBlockRect()`](../SoundApp.h:303) | `SoundApp.h:303` | 绘制跳跃阻挡矩形 |
| [`void DrawGuDaoInf(int layer)`](../SoundApp.h:318) | `SoundApp.h:318` | 绘制孤岛信息 |

#### 怪物操作

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void LoadAllMonster()`](../SoundApp.h:196) | `SoundApp.h:196` | 加载全部怪物基础数据 |
| [`void CreateMonCombo(CComboBox*)`](../SoundApp.h:200) | `SoundApp.h:200` | 初始化怪物下拉列表 |
| [`void AddMonsterPoint(const int&, const int&)`](../SoundApp.h:215) | `SoundApp.h:215` | 添加怪物点 |
| [`void DelMonsterPoint(const int&, const int&)`](../SoundApp.h:216) | `SoundApp.h:216` | 删除怪物点 |
| [`bool SaveMonsterKind(std::wstring)`](../SoundApp.h:217) | `SoundApp.h:217` | 保存怪物分布数据 |
| [`bool ReadMonsterKind(std::wstring)`](../SoundApp.h:218) | `SoundApp.h:218` | 读取怪物分布数据 |

#### 精灵管理

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void RemoveAllSprite()`](../SoundApp.h:127) | `SoundApp.h:127` | 移除所有精灵 |
| [`void RemoveAllNpc()`](../SoundApp.h:128) | `SoundApp.h:128` | 移除所有 NPC |
| [`void Reset()`](../SoundApp.h:131) | `SoundApp.h:131` | 重置所有编辑数据 |
| [`void DrawSelectNpcBox()`](../SoundApp.h:181) | `SoundApp.h:181` | 绘制 NPC 选择框 |
| [`void DrawNpcName()`](../SoundApp.h:182) | `SoundApp.h:182` | 绘制 NPC 名字 |
| [`void DrawFreeArea(int regionType)`](../SoundApp.h:320) | `SoundApp.h:320` | 绘制自由区域 |

---

## 2. CMainDlg 模块（主编辑对话框）

### 2.1 概述

[`CMainDlg`](../MainDlg.h:15) 是 Nuclear 引擎的宿主对话框（定义在 `MainDlg.h:15`），继承 `CDialog`。它嵌入在 `CSoundEditorView` 中，负责处理用户输入（鼠标/键盘事件）并驱动地图编辑操作。

### 2.2 继承关系

```
CDialog
    └── CMainDlg (MainDlg.h:15)
```

### 2.3 关键枚举

#### MOUSESTATE（鼠标状态）

定义在 [`MainDlg.h:20`](../MainDlg.h:20)：

```cpp
enum MOUSESTATE
{
    NORMAL             = 0,
    LEFT_BUTTON_DOWN   = 1,
    RIGHT_BUTTON_DOWN  = 2,
};
```

#### TOOLS_STATE（工具状态）

定义在 [`MainDlg.h:27`](../MainDlg.h:27)，共 27 种工具状态（详见 [01-架构设计](01-架构设计__Architecture-Design.md#8-工具状态枚举tools_state)）。

### 2.4 关键成员变量

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_soundApp`](../MainDlg.h:61) | `SoundApp` | `MainDlg.h:61` | 引擎应用实例 |
| [`m_pDoc`](../MainDlg.h:65) | `CSoundEditorDoc*` | `MainDlg.h:65` | 关联文档 |
| [`m_pEngine`](../MainDlg.h:68) | `Nuclear::IEngine*` | `MainDlg.h:68` | 引擎实例 |
| [`m_pWorld`](../MainDlg.h:69) | `Nuclear::IWorld*` | `MainDlg.h:69` | 世界实例 |
| [`m_bIsLoadedMap`](../MainDlg.h:70) | `bool` | `MainDlg.h:70` | 是否已加载地图 |
| [`m_mouseState`](../MainDlg.h:72) | `int` | `MainDlg.h:72` | 当前鼠标状态 |
| [`m_toolState`](../MainDlg.h:73) | `TOOLS_STATE` | `MainDlg.h:73` | 当前工具状态 |
| [`m_oldMousePoint`](../MainDlg.h:74) | `CPoint` | `MainDlg.h:74` | 上次鼠标世界坐标 |
| [`m_oldViewportPos`](../MainDlg.h:75) | `CPoint` | `MainDlg.h:75` | 上次视口世界坐标 |
| [`m_bAllScreenBrush`](../MainDlg.h:87) | `bool` | `MainDlg.h:87` | 是否全屏笔刷 |
| [`m_EdgeSize`](../MainDlg.h:88) | `int` | `MainDlg.h:88` | 笔刷边缘大小 |

### 2.5 文件路径成员

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_mazefilename`](../MainDlg.h:77) | `CString` | `MainDlg.h:77` | 迷宫阻挡文件路径 |
| [`m_NpcXmlFileName`](../MainDlg.h:78) | `CString` | `MainDlg.h:78` | NPC XML 文件路径 |
| [`m_RegionTypeInfoFileName`](../MainDlg.h:79) | `std::wstring` | `MainDlg.h:79` | 区域类型信息文件路径 |
| [`m_JumpBlockFileName`](../MainDlg.h:80) | `std::wstring` | `MainDlg.h:80` | 跳跃阻挡文件路径 |
| [`m_IslandInfFileName`](../MainDlg.h:81) | `std::wstring` | `MainDlg.h:81` | 孤岛信息文件路径（1 层） |
| [`m_IslandInf2FileName`](../MainDlg.h:82) | `std::wstring` | `MainDlg.h:82` | 孤岛信息文件路径（2 层） |
| [`m_MonsterFileName`](../MainDlg.h:85) | `std::wstring` | `MainDlg.h:85` | 怪物数据文件路径 |

### 2.6 关键成员函数

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`BOOL OnInitDialog()`](../MainDlg.h:135) | `MainDlg.h:135` | 初始化对话框，设置定时器 |
| [`void OnTimer(UINT_PTR)`](../MainDlg.h:136) | `MainDlg.h:136` | 定时器回调，驱动引擎 OnIdle |
| [`LRESULT WindowProc(UINT, WPARAM, LPARAM)`](../MainDlg.h:138) | `MainDlg.h:138` | 消息处理，转发给引擎 |
| [`void OnLButtonDown(UINT, CPoint)`](../MainDlg.h:143) | `MainDlg.h:143` | 左键按下：根据编辑/工具状态分发操作 |
| [`void OnLButtonUp(UINT, CPoint)`](../MainDlg.h:146) | `MainDlg.h:146` | 左键释放 |
| [`void OnRButtonDown(UINT, CPoint)`](../MainDlg.h:140) | `MainDlg.h:140` | 右键按下 |
| [`void OnRButtonUp(UINT, CPoint)`](../MainDlg.h:141) | `MainDlg.h:141` | 右键释放 |
| [`void OnMouseMove(UINT, CPoint)`](../MainDlg.h:142) | `MainDlg.h:142` | 鼠标移动：拖拽编辑阻挡/区域/移动 NPC |
| [`void OnKeyUp(UINT, UINT, UINT)`](../MainDlg.h:147) | `MainDlg.h:147` | 键盘释放 |
| [`bool LoadMap(const CString&)`](../MainDlg.h:124) | `MainDlg.h:124` | 加载地图（含迷宫/NPC/跳转点/区域/怪物） |
| [`bool UnloadMap()`](../MainDlg.h:125) | `MainDlg.h:125` | 卸载地图 |
| [`void OnSavemaze()`](../MainDlg.h:152) | `MainDlg.h:152` | 保存全部地图数据 |
| [`void OnTool(UINT nID)`](../MainDlg.h:144) | `MainDlg.h:144` | 工具栏命令处理 |
| [`void OnDrawGird()`](../MainDlg.h:148) | `MainDlg.h:148` | 切换网格显示 |
| [`void OnDrawBlock()`](../MainDlg.h:150) | `MainDlg.h:150` | 切换阻挡显示 |
| [`void OnAllScreenBrush()`](../MainDlg.h:154) | `MainDlg.h:154` | 切换全屏笔刷模式 |

### 2.7 坐标转换工具函数

定义在 [`MainDlg.h:94`](../MainDlg.h:94)：

```cpp
// 客户端坐标 → 世界坐标
static void Client2World(const POINT &clientpt, const RECT& vp, POINT &worldpt)
{
    worldpt.x = clientpt.x + vp.left;
    worldpt.y = clientpt.y + vp.top;
}

// 世界坐标 → 客户端坐标
static void World2Client(const POINT &worldpt, const RECT& vp, POINT &clientpt)
{
    clientpt.x = worldpt.x - vp.left;
    clientpt.y = worldpt.y - vp.top;
}
```

以及全局内联函数（[`MainDlg.h:11`](../MainDlg.h:11)）：

```cpp
inline CPoint PixelPointToGridPoint(CPoint pt)
{
    return CPoint(pt.x / GRID_WIDTH, pt.y / GRID_HEIGHT);
}
```

---

## 3. CSoundEditorDoc 模块（文档类）

### 3.1 概述

[`CSoundEditorDoc`](../SoundEditorDoc.h:40) 继承 `CDocument`（定义在 `SoundEditorDoc.h:40`），负责管理编辑状态、地图尺寸和文档序列化。

### 3.2 继承关系

```
CDocument
    └── CSoundEditorDoc (SoundEditorDoc.h:40)
```

### 3.3 关键成员变量

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_editState`](../SoundEditorDoc.h:51) | `EDIT_STATE` | `SoundEditorDoc.h:51` | 当前编辑状态 |
| [`m_mapSize`](../SoundEditorDoc.h:52) | `Nuclear::CPOINT` | `SoundEditorDoc.h:52` | 地图尺寸 |
| [`m_pSelectedShape`](../SoundEditorDoc.h:54) | `Nuclear::XPIShape*` | `SoundEditorDoc.h:54` | 选中的环境音区域形状 |
| [`m_nSelectedPt`](../SoundEditorDoc.h:55) | `int` | `SoundEditorDoc.h:55` | 选中的多边形点索引 |
| [`m_PolygonMouseState`](../SoundEditorDoc.h:56) | `POLYGON_MOUSE_STATE` | `SoundEditorDoc.h:56` | 多边形鼠标状态 |
| [`m_CutingPolygonLine`](../SoundEditorDoc.h:57) | `RECT` | `SoundEditorDoc.h:57` | 裁剪多边形线 |
| [`m_bIsIngoreDragging`](../SoundEditorDoc.h:58) | `bool` | `SoundEditorDoc.h:58` | 是否忽略拖拽 |
| [`m_bTestingDrawBkgArea`](../SoundEditorDoc.h:59) | `BOOL` | `SoundEditorDoc.h:59` | 测试模式是否绘制背景区域 |
| [`m_nUpdateViewSign`](../SoundEditorDoc.h:60) | `int` | `SoundEditorDoc.h:60` | 更新视图信号 |

### 3.4 关键成员函数

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`const CPOINT GetMapSize()`](../SoundEditorDoc.h:68) | `SoundEditorDoc.h:68` | 获取地图尺寸 |
| [`void SetMapSize(const CPOINT&)`](../SoundEditorDoc.h:69) | `SoundEditorDoc.h:69` | 设置地图尺寸 |
| [`EDIT_STATE GetEditState()`](../SoundEditorDoc.h:70) | `SoundEditorDoc.h:70` | 获取当前编辑状态 |
| [`void SetEditState(EDIT_STATE)`](../SoundEditorDoc.h:71) | `SoundEditorDoc.h:71` | 设置编辑状态 |
| [`void SaveAsXML(CONode&)`](../SoundEditorDoc.h:72) | `SoundEditorDoc.h:72` | 保存为 XML |
| [`BOOL OnNewDocument()`](../SoundEditorDoc.h:78) | `SoundEditorDoc.h:78` | 新建文档 |
| [`BOOL OnOpenDocument(LPCTSTR)`](../SoundEditorDoc.h:95) | `SoundEditorDoc.h:95` | 打开文档 |
| [`BOOL OnSaveDocument(LPCTSTR)`](../SoundEditorDoc.h:96) | `SoundEditorDoc.h:96` | 保存文档 |

### 3.5 更新视图信号机制

`CSoundEditorDoc` 通过 [`m_nUpdateViewSign`](../SoundEditorDoc.h:60) 和 `UpdateAllViews()` 机制通知视图更新。信号类型定义在 [`UPDATE_VIEW_SIGN`](../SoundEditorDoc.h:31)：

| 信号 | 值 | 说明 |
|------|-----|------|
| `UVS_TAB` | 1 | 更新 Tab 面板 |
| `UVS_VIEWPORT` | 2 | 更新视口 |
| `UVS_ENV_SOUND_AREA_SELECTED` | 4 | 环境音区域选中 |
| `UVS_ENV_SOUND_AREA_SHAPE` | 8 | 环境音区域形状变化 |
| `UVS_ALL` | 0xFFFFFFFF | 全部更新 |

---

## 4. Sprite 模块（精灵包装）

### 4.1 概述

[`Sprite`](../Sprite.h:4) 是对 `Nuclear::ISprite` 的包装类（定义在 `Sprite.h:4`），管理精灵的动作状态并提供简化的接口。

### 4.2 关键成员变量

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_actState`](../Sprite.h:8) | `int` | `Sprite.h:8` | 动作状态：0=stand1, 1=runleft, 2=runright, 3=骑马 |
| [`m_isTel`](../Sprite.h:9) | `bool` | `Sprite.h:9` | 是否瞬移 |
| [`m_pSprite`](../Sprite.h:12) | `Nuclear::ISprite*` | `Sprite.h:12` | 被包装的引擎精灵实例 |

### 4.3 关键成员函数

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void UpdateAction(XPUSA_TYPE)`](../Sprite.h:16) | `Sprite.h:16` | 更新动作状态 |
| [`void GoToRun()`](../Sprite.h:17) | `Sprite.h:17` | 切换到跑步动作 |
| [`int GetState()`](../Sprite.h:18) | `Sprite.h:18` | 获取当前动作状态 |
| [`void SetLocation(const Location&)`](../Sprite.h:22) | `Sprite.h:22` | 设置位置（世界像素坐标） |
| [`Location GetLocation()`](../Sprite.h:24) | `Sprite.h:24` | 获取位置 |
| [`void SetDirection(XPDIRECTION)`](../Sprite.h:27) | `Sprite.h:27` | 设置方向 |
| [`void SetVisible(bool)`](../Sprite.h:31) | `Sprite.h:31` | 设置可见性 |
| [`void SetModel(const std::wstring&)`](../Sprite.h:39) | `Sprite.h:39` | 设置精灵模型 |
| [`void SetComponent(int, const std::wstring&, XPCOLOR)`](../Sprite.h:42) | `Sprite.h:42` | 设置装备组件 |
| [`void SetDefaultAction(const std::wstring&, bool, float)`](../Sprite.h:50) | `Sprite.h:50` | 设置默认动作 |
| [`void PlayAction(const std::wstring&, float)`](../Sprite.h:56) | `Sprite.h:56` | 播放临时动作 |
| [`void SetRideName(const std::wstring&)`](../Sprite.h:47) | `Sprite.h:47` | 设置坐骑名称 |
| [`bool SetBindFile(const std::wstring&)`](../Sprite.h:68) | `Sprite.h:68` | 设置绑定文件 |
| [`void SetMoveSpeed(float)`](../Sprite.h:99) | `Sprite.h:99` | 设置移动速度 |
| [`void EnableShadow(bool)`](../Sprite.h:92) | `Sprite.h:92` | 启用/禁用阴影 |

### 4.4 动作状态机

```
         ┌──────────────────────────────────────────┐
         │                                          │
    ┌────▼────┐    GoToRun()    ┌──────────┐        │
    │ stand1  │───────────────→│ runleft  │        │
    │ (0)     │                │ (1)      │        │
    └────┬────┘                └──────────┘        │
         │                          │               │
         │    GoToRun()             │ UpdateAction  │
         │                          │               │
         │                ┌──────────┐              │
         └───────────────→│ runright │              │
                          │ (2)      │              │
                          └──────────┘              │
                                                    │
         ┌──────────┐                               │
         │ 骑马     │←── SetRideName()              │
         │ (3)      │                               │
         └──────────┘                               │
```

---

## 5. CNpc 模块（NPC 实体）

### 5.1 概述

[`CNpc`](../Npc.h:80) 继承 [`Sprite`](../Sprite.h:4)（定义在 `Npc.h:80`），增加 NPC 特有的 ID、名称和基础数据关联。

### 5.2 继承关系

```
Sprite (Sprite.h:4)
    └── CNpc (Npc.h:80)
```

### 5.3 关键成员变量

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_nId`](../Npc.h:93) | `int` | `Npc.h:93` | NPC 实例 ID |
| [`m_strName`](../Npc.h:94) | `std::wstring` | `Npc.h:94` | NPC 名称 |
| [`m_pNpcBaseData`](../Npc.h:89) | `const stNpcBaseData*` | `Npc.h:89` | 关联的 NPC 基础数据 |

### 5.4 关键成员函数

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void SetId(int)`](../Npc.h:85) | `Npc.h:85` | 设置 NPC ID |
| [`int GetId()`](../Npc.h:86) | `Npc.h:86` | 获取 NPC ID |
| [`void SetName(const std::wstring&)`](../Npc.h:87) | `Npc.h:87` | 设置 NPC 名称 |
| [`std::wstring GetName()`](../Npc.h:88) | `Npc.h:88` | 获取 NPC 名称 |

---

## 6. CRegionBuffer 模板（区域缓冲）

### 6.1 概述

[`CRegionBuffer<T>`](../regionbuffer.h:8) 是稀疏区域数据存储模板（定义在 `regionbuffer.h:8`），继承 `Nuclear::PObject`，使用 `std::map` 存储非零区域数据。

### 6.2 继承关系

```
Nuclear::PObject
    └── CRegionBuffer<T> (regionbuffer.h:8)
```

### 6.3 存储结构

- 底层容器：[`std::map<unsigned int, T>`](../regionbuffer.h:146)
- Key 编码：高 16 位 = x 坐标，低 16 位 = y 坐标
  ```cpp
  unsigned int key = w << 16 | h;  // regionbuffer.h:34
  ```
- Value：区域类型位组合（`RegionType` 的位或运算结果）

### 6.4 关键成员函数

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void Init(const unsigned int&, const unsigned int&)`](../regionbuffer.h:18) | `regionbuffer.h:18` | 初始化宽高，清空缓冲 |
| [`void AddPoint(const unsigned int&, const unsigned int&, const T&)`](../regionbuffer.h:31) | `regionbuffer.h:31` | 添加区域点（位或运算） |
| [`void DelPoint(const unsigned int&, const unsigned int&, const T&)`](../regionbuffer.h:49) | `regionbuffer.h:49` | 删除区域点（位与取反运算） |
| [`bool CheckPointType(const unsigned int&, const unsigned int&, const T&)`](../regionbuffer.h:64) | `regionbuffer.h:64` | 检查指定位置的区域类型 |
| [`T GetPointValue(const unsigned int&, const unsigned int&)`](../regionbuffer.h:78) | `regionbuffer.h:78` | 获取指定位置的值 |
| [`XOStream& marshal(XOStream&)`](../regionbuffer.h:91) | `regionbuffer.h:91` | 序列化到输出流 |
| [`const XIStream& unmarshal(const XIStream&)`](../regionbuffer.h:111) | `regionbuffer.h:111` | 从输入流反序列化 |

### 6.5 序列化格式

```
文件头: 'Q' 'U' 'Y' 'U' (4 字节)
宽度:   unsigned int (4 字节)
高度:   unsigned int (4 字节)
条目数: int (4 字节)
数据:   [key: unsigned int, value: T] × 条目数
```

---

## 7. 数据结构

### 7.1 stNpcBaseData（NPC 基础数据）

定义在 [`Npc.h:16`](../Npc.h:16)：

| 字段 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`BaseID`](../Npc.h:18) | `int` | `Npc.h:18` | NPC 基础 ID |
| [`strNpcModel`](../Npc.h:19) | `std::wstring` | `Npc.h:19` | NPC 造型（如 "male"） |
| [`strBodyResName`](../Npc.h:20) | `std::wstring` | `Npc.h:20` | 身体资源名 |
| [`strHeadResName`](../Npc.h:21) | `std::wstring` | `Npc.h:21` | 头部资源名 |
| [`strHairResName`](../Npc.h:22) | `std::wstring` | `Npc.h:22` | 头发资源名 |
| [`eNpcType`](../Npc.h:23) | `int` | `Npc.h:23` | NPC 类型（`enumNpcType`） |
| [`strName`](../Npc.h:24) | `std::wstring` | `Npc.h:24` | NPC 名字 |
| [`strTitle`](../Npc.h:25) | `std::wstring` | `Npc.h:25` | NPC 称谓 |
| [`chat1`](../Npc.h:26) | `int` | `Npc.h:26` | NPC 闲话 1 |
| [`chat2`](../Npc.h:27) | `int` | `Npc.h:27` | NPC 闲话 2 |
| [`chat3`](../Npc.h:28) | `int` | `Npc.h:28` | NPC 闲话 3 |
| [`dirType`](../Npc.h:29) | `int` | `Npc.h:29` | 方向类型 |

### 7.2 stMonsterBaseData（怪物基础数据）

定义在 [`Monster.h:3`](../Monster.h:3)：

| 字段 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`BaseID`](../Monster.h:5) | `int` | `Monster.h:5` | 怪物基础 ID |
| [`strMonsterColor`](../Monster.h:6) | `std::wstring` | `Monster.h:6` | 怪物颜色 |
| [`strMonsterDescribe`](../Monster.h:7) | `std::wstring` | `Monster.h:7` | 怪物描述 |

### 7.3 stJumpPointInf（跳转点信息）

定义在 [`SoundApp.h:27`](../SoundApp.h:27)：

| 字段 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`id`](../SoundApp.h:29) | `int` | `SoundApp.h:29` | 跳转点编号 |
| [`effect`](../SoundApp.h:30) | `Nuclear::IEffect*` | `SoundApp.h:30` | 对应的特效 |
| [`dest_mapID`](../SoundApp.h:31) | `int` | `SoundApp.h:31` | 目标地图 ID |
| [`dest_X`](../SoundApp.h:32) | `int` | `SoundApp.h:32` | 目标点 X |
| [`dest_Y`](../SoundApp.h:33) | `int` | `SoundApp.h:33` | 目标点 Y |

### 7.4 SoundApp::MonsterInfo（怪物信息）

定义在 [`SoundApp.h:202`](../SoundApp.h:202)：

| 字段 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`ID`](../SoundApp.h:204) | `std::wstring` | `SoundApp.h:204` | 怪物 ID |
| [`Color`](../SoundApp.h:205) | `Nuclear::XPCOLOR` | `SoundApp.h:205` | 怪物颜色 |
| [`Area`](../SoundApp.h:206) | `Nuclear::FRECT` | `SoundApp.h:206` | 怪物区域 |

---

## 8. UI 面板模块

### 8.1 CTabPropPanel（Tab 属性面板）

[`CTabPropPanel`](../TabPropPanel.h:11) 继承 `CDialog`（定义在 `TabPropPanel.h:11`），是右栏的 Tab 控件宿主，管理五个 Tab 页。

**关键成员变量：**

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_Tab`](../TabPropPanel.h:25) | `CTabCtrl` | `TabPropPanel.h:25` | Tab 控件 |
| [`m_pView`](../TabPropPanel.h:26) | `CPropView*` | `TabPropPanel.h:26` | 关联视图 |
| [`m_miniMapPanel`](../TabPropPanel.h:27) | `CMiniMapPanel` | `TabPropPanel.h:27` | 小地图面板 |
| [`m_pdlgNpcPropertyDlg`](../TabPropPanel.h:18) | `CNpcPropertyDlg*` | `TabPropPanel.h:18` | NPC 属性面板 |
| [`m_pJPInfDlg`](../TabPropPanel.h:19) | `CJumpPointInfDlg*` | `TabPropPanel.h:19` | 跳转点信息面板 |
| [`m_pMonPanel`](../TabPropPanel.h:20) | `CMonsterPanel*` | `TabPropPanel.h:20` | 怪物面板 |

**Tab 页布局：**

| Tab 索引 | 面板 | 说明 |
|----------|------|------|
| 0 | `CMiniMapPanel` | 小地图缩略图 |
| 1 | 环境音面板 | 环境音区域编辑 |
| 2 | `CNpcPropertyDlg` | NPC 属性编辑 |
| 3 | `CJumpPointInfDlg` | 跳转点信息编辑 |
| 4 | 测试面板 | 测试模式控制 |
| 5 | `CMonsterPanel` | 怪物区域类型选择 |

### 8.2 CNpcPropertyDlg（NPC 属性面板）

[`CNpcPropertyDlg`](../NpcPropertyDlg.h:14) 继承 `CDialog`（定义在 `NpcPropertyDlg.h:14`），提供 NPC 属性编辑功能。

**关键成员变量：**

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_pMainDlg`](../NpcPropertyDlg.h:40) | `CMainDlg*` | `NpcPropertyDlg.h:40` | 主对话框引用 |
| [`m_AddNpcDlg`](../NpcPropertyDlg.h:41) | `CAddNpcDlg` | `NpcPropertyDlg.h:41` | 添加 NPC 子对话框 |

**关键成员函数：**

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void ChangeSelNpc(CNpc*)`](../NpcPropertyDlg.h:21) | `NpcPropertyDlg.h:21` | 切换选中的 NPC，更新控件显示 |
| [`void ChangeSelNpcPos(int, int)`](../NpcPropertyDlg.h:22) | `NpcPropertyDlg.h:22` | 更新 NPC 位置显示 |
| [`void Reset()`](../NpcPropertyDlg.h:23) | `NpcPropertyDlg.h:23` | 重置面板 |
| [`void OnBnClickedButtonAddnpc()`](../NpcPropertyDlg.h:45) | `NpcPropertyDlg.h:45` | "添加 NPC" 按钮点击 |
| [`void OnBnClickedButtonNewnpc()`](../NpcPropertyDlg.h:46) | `NpcPropertyDlg.h:46` | "新建 NPC" 按钮点击 |
| [`void OnBnClickedNpcOk()`](../NpcPropertyDlg.h:47) | `NpcPropertyDlg.h:47` | "确定" 按钮：应用 NPC 属性修改 |
| [`void OnBnClickedNpcSave()`](../NpcPropertyDlg.h:48) | `NpcPropertyDlg.h:48` | "保存" 按钮：保存 NPC 信息到 XML |
| [`void OnBnClickedNpcCancel()`](../NpcPropertyDlg.h:49) | `NpcPropertyDlg.h:49` | "取消" 按钮 |

**可编辑属性：** BaseID、Model、Name、Pos(X/Y)、Type、Title、Chat(1/2/3)、Dir

### 8.3 CAddNpcDlg（添加 NPC 对话框）

[`CAddNpcDlg`](../AddNpcDlg.h:10) 继承 `CDialog`（定义在 `AddNpcDlg.h:10`），从基础 NPC 列表中选择添加。

**关键成员变量：**

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_pCombox`](../AddNpcDlg.h:25) | `CComboBox*` | `AddNpcDlg.h:25` | NPC 选择下拉列表 |
| [`m_pSoundApp`](../AddNpcDlg.h:26) | `SoundApp*` | `AddNpcDlg.h:26` | 引擎应用引用 |

**关键成员函数：**

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`BOOL OnInitDialog()`](../AddNpcDlg.h:17) | `AddNpcDlg.h:17` | 初始化对话框，填充 NPC 列表 |
| [`void InitCombox()`](../AddNpcDlg.h:18) | `AddNpcDlg.h:18` | 初始化下拉列表 |
| [`void OnBnClickedAddnpc()`](../AddNpcDlg.h:31) | `AddNpcDlg.h:31` | 确认添加 NPC |
| [`void OnBnClickedCancelAddnpc()`](../AddNpcDlg.h:32) | `AddNpcDlg.h:32` | 取消添加 |

### 8.4 CJumpPointInfDlg（跳转点信息面板）

[`CJumpPointInfDlg`](../JumpPointInfDlg.h:10) 继承 `CDialog`（定义在 `JumpPointInfDlg.h:10`），提供跳转点信息编辑功能。

**关键成员变量：**

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_pMainDlg`](../JumpPointInfDlg.h:22) | `CMainDlg*` | `JumpPointInfDlg.h:22` | 主对话框引用 |

**关键成员函数：**

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void ChangeJPInf(int, int, int)`](../JumpPointInfDlg.h:18) | `JumpPointInfDlg.h:18` | 更新跳转点信息显示（目标地图/坐标） |
| [`void JumpIsland(int idx)`](../JumpPointInfDlg.h:20) | `JumpPointInfDlg.h:20` | 跳到指定孤岛 |
| [`void OnBnClickedJPInfOK()`](../JumpPointInfDlg.h:34) | `JumpPointInfDlg.h:34` | 确认修改跳转点信息 |
| [`void OnBnClickedDeljump()`](../JumpPointInfDlg.h:35) | `JumpPointInfDlg.h:35` | 删除跳转点 |
| [`void OnBnClickedAddjump()`](../JumpPointInfDlg.h:36) | `JumpPointInfDlg.h:36` | 添加跳转点 |
| [`void OnBnClickedSavejpinf()`](../JumpPointInfDlg.h:37) | `JumpPointInfDlg.h:37` | 保存跳转点信息 |

### 8.5 CMonsterPanel（怪物面板）

[`CMonsterPanel`](../CMonsterPanel.h:7) 继承 `CDialog`（定义在 `CMonsterPanel.h:7`），提供怪物区域类型选择功能。

**关键成员变量：**

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_pMainDlg`](../CMonsterPanel.h:16) | `CMainDlg*` | `CMonsterPanel.h:16` | 主对话框引用 |
| [`mMonsterKind`](../CMonsterPanel.h:18) | `int` | `CMonsterPanel.h:18` | 当前怪物种类 |
| [`mMonsterIndex`](../CMonsterPanel.h:19) | `int` | `CMonsterPanel.h:19` | 当前怪物索引 |

**关键成员函数：**

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void CreateMonCombo()`](../CMonsterPanel.h:15) | `CMonsterPanel.h:15` | 创建怪物下拉列表 |
| [`void GetMonsterKind(int&)`](../CMonsterPanel.h:21) | `CMonsterPanel.h:21` | 获取当前怪物种类 |
| [`void GetMonsterIndex(int&)`](../CMonsterPanel.h:22) | `CMonsterPanel.h:22` | 获取当前怪物索引 |
| [`int GetSelectMonster()`](../CMonsterPanel.h:24) | `CMonsterPanel.h:24` | 获取选中的怪物 |
| [`void SetMonsterKind(int)`](../CMonsterPanel.h:25) | `CMonsterPanel.h:25` | 设置怪物种类 |
| [`void OnBnClickedMonOk()`](../CMonsterPanel.h:34) | `CMonsterPanel.h:34` | 确认怪物设置 |

### 8.6 CMiniMapPanel（小地图面板）

[`CMiniMapPanel`](../MiniMapPanel.h:8) 继承 `CDialog`（定义在 `MiniMapPanel.h:8`），提供缩略图面板功能。

**关键成员变量：**

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_pView`](../MiniMapPanel.h:17) | `CPropView*` | `MiniMapPanel.h:17` | 关联视图 |
| [`m_sliderScale`](../MiniMapPanel.h:19) | `CSliderCtrl` | `MiniMapPanel.h:19` | 缩放滑块控件 |

**关键成员函数：**

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`void ResetCont()`](../MiniMapPanel.h:29) | `MiniMapPanel.h:29` | 重置内容 |
| [`void ResetSize()`](../MiniMapPanel.h:26) | `MiniMapPanel.h:26` | 重置大小 |
| [`BOOL OnInitDialog()`](../MiniMapPanel.h:39) | `MiniMapPanel.h:39` | 初始化对话框 |

---

## 9. CSoundEditorApp 模块（应用入口）

### 9.1 概述

[`CSoundEditorApp`](../SoundEditor.h:18) 继承 `CWinApp`（定义在 `SoundEditor.h:18`），是 MFC 应用入口类。

### 9.2 关键成员变量

| 变量 | 类型 | 位置 | 说明 |
|------|------|------|------|
| [`m_stringPath`](../SoundEditor.h:21) | `CString` | `SoundEditor.h:21` | 可执行文件路径 |
| [`m_pfsLog`](../SoundEditor.h:23) | `Nuclear::PFSLog` | `SoundEditor.h:23` | PFS 日志 |
| [`m_pFileIOMan`](../SoundEditor.h:24) | `Nuclear::CFileIOManager*` | `SoundEditor.h:24` | 文件 I/O 管理器 |
| [`m_pPathMap`](../SoundEditor.h:25) | `Nuclear::SubMap::PPathMap*` | `SoundEditor.h:25` | PFS 路径映射 |

### 9.3 关键成员函数

| 函数签名 | 位置 | 功能 |
|----------|------|------|
| [`BOOL InitInstance()`](../SoundEditor.h:34) | `SoundEditor.h:34` | 初始化应用实例：设置 PFS 路径、创建 DocTemplate |
| [`int ExitInstance()`](../SoundEditor.h:35) | `SoundEditor.h:35` | 退出清理 |
| [`void EnableSecToolBar(bool)`](../SoundEditor.h:29) | `SoundEditor.h:29` | 启用/禁用编辑器工具栏 |
| [`CString GetExePath()`](../SoundEditor.h:37) | `SoundEditor.h:37` | 获取可执行文件路径 |

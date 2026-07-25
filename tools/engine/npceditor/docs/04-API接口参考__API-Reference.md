# 04 - API 接口参考 (API Reference)

> NPC 编辑器（npceditor）完整公共接口参考文档。
> 所有接口签名与参数描述均基于源码静态分析，与实际代码保持一致。

---

## 目录

- [1. SoundApp 类](#1-soundapp-类)
- [2. CMainDlg 类](#2-cmaindlg-类)
- [3. CSoundEditorDoc 类](#3-csoundeditordoc-类)
- [4. Sprite 类](#4-sprite-类)
- [5. CNpc 类](#5-cnpc-类)
- [6. CRegionBuffer\<T\> 模板类](#6-cregionbuffert-模板类)
- [7. 数据结构定义](#7-数据结构定义)
- [8. UI 对话框类](#8-ui-对话框类)
- [9. 枚举与常量](#9-枚举与常量)

---

## 1. SoundApp 类

**定义**: [`SoundApp.h:75`](../SoundApp.h:75)  
**实现**: [`SoundApp.cpp`](../SoundApp.cpp)  
**基类**: `Nuclear::IApp`  
**职责**: 引擎应用层核心，管理地图阻挡数据、NPC 实例、跳转点、区域缓冲、怪物分布等全部编辑数据。

### 1.1 生命周期接口

#### `bool OnInit(int step)`

- **定义**: [`SoundApp.h:225`](../SoundApp.h:225) | **实现**: [`SoundApp.cpp:265`](../SoundApp.cpp:265)
- **功能**: 引擎初始化回调。设置环境参数、关闭调试信息显示、启用表面缓存、加载字体、加载区域图片资源、加载 NPC 基础表和怪物基础表。
- **参数**:
  - `step` — 初始化步骤编号（由引擎调用时传入）
- **返回值**: `true` 初始化成功
- **关键流程**:
  1. 获取 `Nuclear::IEngine` 实例
  2. 通过 `IEnv` 关闭所有调试信息（`SetConsoleInfo`、`SetFrameStateInfo`）
  3. 设置渲染参数（`SetSmoothMove(false)`、`SetRenderNightEffectByShader(false)`）
  4. 加载字体 `/ui/fonts/DFYuanW7-GB2312.ttf`，注册为字体类型 1
  5. 从资源加载 PNG 区域标记图片（`IDR_PNG_AREA`）
  6. 调用 `LoadNpcShapeMap()` 加载 NPC 造型映射
  7. 调用 `LoadAllBaseNpc()` 加载 NPC 基础数据表
  8. 调用 `LoadAllMonster()` 加载怪物基础数据表
  9. 设置 `m_bEngineInited = true`

#### `bool OnExit()`

- **定义**: [`SoundApp.h:227`](../SoundApp.h:227) | **实现**: [`SoundApp.cpp:254`](../SoundApp.cpp:254)
- **功能**: 引擎退出回调。释放所有 Sprite 映射中的对象。
- **返回值**: `true`

#### `void OnTick(int now, int delta)`

- **定义**: [`SoundApp.h:229`](../SoundApp.h:229) | **实现**: [`SoundApp.cpp:233`](../SoundApp.cpp:233)
- **功能**: 主线程主循环每帧调用，用于处理与渲染无关的日常工作。当前实现为空。

#### `bool OnBeforeRender(int now)`

- **定义**: [`SoundApp.h:230`](../SoundApp.h:230) | **实现**: [`SoundApp.cpp:239`](../SoundApp.cpp:239)
- **功能**: 引擎每帧渲染前调用，用于更新渲染相关数据。返回 `false` 可跳过渲染。
- **返回值**: 始终返回 `true`

#### `void OnRenderUI(int now)`

- **定义**: [`SoundApp.h:231`](../SoundApp.h:231) | **实现**: [`SoundApp.cpp:338`](../SoundApp.cpp:338)
- **功能**: 每帧 UI 渲染回调。根据当前编辑状态和工具状态绘制网格线、阻挡区域、区域类型标记、NPC 选择框、NPC 名字、跳转点标志等。
- **参数**: `now` — 当前时间戳（毫秒）
- **绘制顺序**:
  1. **网格线** — 绿色竖线 (`0x3F00FF00`)、蓝色横线 (`0x3F0000FF`)
  2. **阻挡区域** — 根据当前工具类型绘制对应颜色的半透明矩形
  3. **区域类型** — 切磋(红)、播撒(黄)、摆摊(紫)、刷怪(蓝)、名胜(红)、飞跃(多色)、孤岛(多色)、自由区域(6色) 等
  4. **NPC 选择框 + 名字** — 仅在 `EDIT_STATE_NPC` 状态下绘制
  5. **跳转点标志** — 仅在 `EDIT_STATE_MapJump` 状态下绘制

#### `void OnUpdateSpriteAction(Nuclear::ISprite* sprite, Nuclear::XPUSA_TYPE type)`

- **定义**: [`SoundApp.h:233`](../SoundApp.h:233) | **实现**: [`SoundApp.cpp:245`](../SoundApp.cpp:245)
- **功能**: 精灵状态变化回调。查找 `m_spriteMap` 中对应的 `Sprite` 对象并调用其 `UpdateAction()`。

### 1.2 迷宫阻挡接口

#### `bool ReadMazeBuffer(CString mazefilename)`

- **定义**: [`SoundApp.h:135`](../SoundApp.h:135) | **实现**: [`SoundApp.cpp:718`](../SoundApp.cpp:718)
- **功能**: 从二进制文件读取迷宫阻挡数据到 `m_MazeBuffer`。
- **参数**: `mazefilename` — 阻挡文件路径（如 `map/5002_dayanta2/maze.dat`）
- **返回值**: `true` 读取成功；`false` 文件打开失败、文件头校验失败或尺寸不匹配
- **文件格式**:
  ```
  [int: minsize] [size_t: map_width] [size_t: map_height] [unsigned char[]: data]
  ```
  - `minsize` = `sizeof(int) + sizeof(size_t) + sizeof(size_t)` = 头部大小
  - `data` 长度 = `map_width × map_height` 字节
- **关键流程**:
  1. 打开二进制文件，读取头部（minsize、width、height）
  2. 校验 `minsize` 是否等于期望头部大小
  3. 调用 `NewMazeBuffer()` 根据地图尺寸分配缓冲区
  4. 校验文件中的 width/height 是否与当前地图匹配
  5. 读取阻挡数据到 `m_MazeBuffer`
  6. 调用 `CheckMazeLayer2IsNew()` 检测并初始化二层阻挡

#### `bool WriteMazeBuffer(CString mazefilename)`

- **定义**: [`SoundApp.h:136`](../SoundApp.h:136) | **实现**: [`SoundApp.cpp:766`](../SoundApp.cpp:766)
- **功能**: 写入迷宫阻挡数据到二进制文件，含孤岛检查。
- **参数**: `mazefilename` — 输出文件路径
- **返回值**: `true` 写入成功；`false` 缓冲区无效、存在孤岛或写入失败
- **关键流程**:
  1. 检查 `m_MazeBuffer` 有效性
  2. 调用 `CheckLonelyIsland()` 执行孤岛检测
  3. 写入头部 + 阻挡数据
  4. 回读文件并调用 `SetMapMaze()` 更新引擎阻挡数据

#### `void SetBlockPoint(CPoint point, bool bAllScreen, bool tab, bool brush, unsigned char mask = 0x03)`

- **定义**: [`SoundApp.h:134`](../SoundApp.h:134) | **实现**: [`SoundApp.cpp:824`](../SoundApp.cpp:824)
- **功能**: 设置阻挡点。内部委托给 `SetMazeMask()`。
- **参数**:
  - `point` — 像素坐标
  - `bAllScreen` — 是否全屏刷
  - `tab` — （保留参数）
  - `brush` — 是否使用笔刷模式（按 `m_EdgeSize` 范围刷）
  - `mask` — 阻挡掩码，默认 `0x03`（1 层阻挡）

#### `void SetMazeMask(unsigned int mask, CPoint pixel, bool bAllScreen, bool brush = false)`

- **定义**: [`SoundApp.h:153`](../SoundApp.h:153) | **实现**: [`SoundApp.cpp:892`](../SoundApp.cpp:892)
- **功能**: 设置迷宫掩码。支持单格、笔刷范围和全屏三种模式。
- **参数**:
  - `mask` — 要设置的掩码值
  - `pixel` — 像素坐标
  - `bAllScreen` — 是否全屏设置
  - `brush` — 是否使用笔刷模式
- **位运算逻辑**:
  - 鼠标点击效果（`mask == 0x01<<6` 或 `0x02<<6` 或 `0x03<<6`）时，先清除高 2 位：`buffer[index] &= 0x3F`
  - 然后位或合并：`buffer[index] |= mask`

#### `unsigned char GetMazeMask(CPoint pixel)`

- **定义**: [`SoundApp.h:152`](../SoundApp.h:152) | **实现**: [`SoundApp.cpp:834`](../SoundApp.cpp:834)
- **功能**: 获取指定像素坐标处的迷宫掩码值。
- **返回值**: 掩码字节；缓冲区无效时返回 0

#### `void ClearMazeMask(unsigned int mask, CPoint pixel, bool bAllScreen)`

- **定义**: [`SoundApp.h:155`](../SoundApp.h:155) | **实现**: [`SoundApp.cpp:951`](../SoundApp.cpp:951)
- **功能**: 清除单格掩码。位与清除：`buffer[index] &= ~mask`。

#### `void ClearMazeMask(unsigned int mask, CPoint center, int edge, bool bAllScreen)`

- **定义**: [`SoundApp.h:156`](../SoundApp.h:156) | **实现**: [`SoundApp.cpp:969`](../SoundApp.cpp:969)
- **功能**: 清除笔刷范围内的掩码。以 `center` 为中心、`edge` 为边长的正方形区域内逐格清除。

#### `void NewMazeBuffer()`

- **定义**: [`SoundApp.h:137`](../SoundApp.h:137)
- **功能**: 根据地图尺寸分配新的迷宫阻挡缓冲区。计算 `m_mapGridWidth = (mapWidth + 23) / 24`，`m_mapGridHeight = mapHeight / 16`。

#### `void SetAllMask(unsigned int mask)`

- **实现**: [`SoundApp.cpp:3140`](../SoundApp.cpp:3140)
- **功能**: 对所有网格执行 `m_MazeBuffer[i] |= mask`。

#### `void ClearAllMask(unsigned int mask)`

- **实现**: [`SoundApp.cpp:3149`](../SoundApp.cpp:3149)
- **功能**: 对所有网格执行 `m_MazeBuffer[i] &= ~mask`。

#### `void CheckMazeLayer2IsNew()`

- **定义**: [`SoundApp.h:151`](../SoundApp.h:151) | **实现**: [`SoundApp.cpp:3107`](../SoundApp.cpp:3107)
- **功能**: 检测二层阻挡是否从未刷过。如果整个地图没有任何二层阻挡（`s_BlockLayer2Mask`），则将所有格子的二层阻挡全部刷上。

### 1.3 孤岛检测接口

#### `bool CheckLonelyIsland()`

- **定义**: [`SoundApp.h:160`](../SoundApp.h:160) | **实现**: [`SoundApp.cpp:845`](../SoundApp.cpp:845)
- **功能**: 简单孤岛检测。遍历所有网格，对非阻挡点检查周围 8 个方向是否全是阻挡点。如果是，则将该点标记为阻挡并返回 `false`。
- **返回值**: `true` 无孤岛；`false` 存在孤岛（已自动修复）

#### `int processBlockInfo(char* blockinfo, int x_grid_num, int y_grid_num)`

- **定义**: [`SoundApp.h:308`](../SoundApp.h:308) | **实现**: [`SoundApp.cpp:2872`](../SoundApp.cpp:2872)
- **功能**: BFS 孤岛检测核心算法。遍历所有网格，对非阻挡点启动 BFS 扩展连通区域，每个连通区域分配唯一编号。
- **返回值**: 孤岛总数（连通区域数 - 1，因为编号从 1 开始）

#### `void SaveIslandInf(std::wstring mazefilename, int layer)`

- **定义**: [`SoundApp.h:306`](../SoundApp.h:306) | **实现**: [`SoundApp.cpp:2779`](../SoundApp.cpp:2779)
- **功能**: 计算并保存孤岛信息。根据 `layer` 参数选择 1 层或 2 层阻挡数据进行孤岛检测，结果保存到文件。
- **参数**:
  - `mazefilename` — 输出文件路径
  - `layer` — 层号（1 或 2）

#### `void JumpToIsland(int islandIdx)`

- **定义**: [`SoundApp.h:161`](../SoundApp.h:161) | **实现**: [`SoundApp.cpp:3053`](../SoundApp.cpp:3053)
- **功能**: 跳转到指定孤岛的第一个格子坐标作为屏幕中心。

### 1.4 NPC 管理接口

#### `void ResetMapNpc(std::wstring NpcXmlfilename)`

- **定义**: [`SoundApp.h:167`](../SoundApp.h:167) | **实现**: [`SoundApp.cpp:1107`](../SoundApp.cpp:1107)
- **功能**: 从 XML 文件加载地图 NPC 实例。先清除所有现有 Sprite 和 NPC，再解析 XML 创建 NPC 精灵。
- **参数**: `NpcXmlfilename` — NPC 数据文件路径（XML 或 DAT 格式）
- **关键流程**:
  1. 调用 `RemoveAllSprite()` + `RemoveAllNpc()`
  2. 解析 XML 中每个 `<record>` 节点的 `id`、`posx`、`posy`、`dir`
  3. 通过 `GetNpcBaseById()` 查找基础数据
  4. 创建 `Nuclear::ISprite` 和 `CNpc` 实例
  5. 设置位置（`logic2world` 坐标转换）、方向、组件、名字
  6. 加入 `m_NpcList` 和 `m_spriteMap`

#### `CNpc* AddNewNpc(int baseid)`

- **定义**: [`SoundApp.h:174`](../SoundApp.h:174) | **实现**: [`SoundApp.cpp:1435`](../SoundApp.cpp:1435)
- **功能**: 添加新 NPC 到地图。在视口中心创建，自动设为当前选中 NPC。
- **参数**: `baseid` — NPC 基础 ID
- **返回值**: 新创建的 `CNpc*`；失败返回 `NULL`

#### `void RemoveAllNpc()`

- **定义**: [`SoundApp.h:128`](../SoundApp.h:128) | **实现**: [`SoundApp.cpp:331`](../SoundApp.cpp:331)
- **功能**: 清空 NPC 列表（`m_NpcList`），重置 `m_pCurSelNpc`。

#### `void RemoveAllSprite()`

- **定义**: [`SoundApp.h:127`](../SoundApp.h:127) | **实现**: [`SoundApp.cpp:315`](../SoundApp.cpp:315)
- **功能**: 删除所有精灵。调用 `IWorld::DeleteAllSprite()`，释放 `m_spriteMap` 中所有 `Sprite` 对象。

#### `void RemoveNpc(CNpc* pNpc)`

- **实现**: [`SoundApp.cpp:1784`](../SoundApp.cpp:1784)
- **功能**: 移除指定 NPC。从 `m_NpcList` 和 `m_spriteMap` 中删除，调用 `IWorld::DeleteSprite()`。

#### `bool OnSaveNpcInf()`

- **定义**: [`SoundApp.h:189`](../SoundApp.h:189) | **实现**: [`SoundApp.cpp:1714`](../SoundApp.cpp:1714)
- **功能**: 保存地图 NPC 信息到 XML 文件。遍历 `m_NpcList`，将每个 NPC 的 BaseID、逻辑坐标、方向写入 `<record>` 节点。
- **返回值**: `true` 保存成功

#### `bool OnSaveNpcBaseInf()`

- **定义**: [`SoundApp.h:188`](../SoundApp.h:188) | **实现**: [`SoundApp.cpp:1687`](../SoundApp.cpp:1687)
- **功能**: 保存 NPC 基础表到 `config/AutoConfig/fire.gsp.npc.CNPCConfig.xml`。

#### `bool SelectNpc(CPoint pt)`

- **定义**: [`SoundApp.h:171`](../SoundApp.h:171) | **实现**: [`SoundApp.cpp:1312`](../SoundApp.cpp:1312)
- **功能**: NPC 选择。两阶段选择算法：先精确选择，后矩形碰撞回退。
- **参数**: `pt` — 世界像素坐标
- **返回值**: `true` 选中了一个 NPC
- **选择流程**:
  1. 检查当前选中 NPC 位置是否有阻挡（有则拒绝选择）
  2. 调用 `IWorld::SelectObjs(loc, objs)` 精确选择
  3. 若精确选择命中，在 `m_NpcList` 中匹配 `m_pSprite`
  4. 若精确选择未命中，遍历 `m_NpcList`，对每个 NPC 构造 60×120 像素碰撞矩形进行点测试
  5. 选中后调用 `CNpcPropertyDlg::ChangeSelNpc()` 更新属性面板

#### `void MoveSelectNpc(CPoint pt)`

- **定义**: [`SoundApp.h:172`](../SoundApp.h:172) | **实现**: [`SoundApp.cpp:1411`](../SoundApp.cpp:1411)
- **功能**: 移动当前选中的 NPC 到指定世界坐标，同时更新属性面板中的逻辑坐标显示。

#### `void PutNpc(CPoint pt)`

- **实现**: [`SoundApp.cpp:1423`](../SoundApp.cpp:1423)
- **功能**: 放置当前选中的 NPC 到指定位置并取消选中。

#### `const stNpcBaseData* GetNpcBaseById(int id)`

- **定义**: [`SoundApp.h:166`](../SoundApp.h:166) | **实现**: [`SoundApp.cpp:1225`](../SoundApp.cpp:1225)
- **功能**: 在 `m_NpcBaseList` 中按 BaseID 查找 NPC 基础数据。
- **返回值**: 找到返回指针；未找到返回 `NULL`

#### `int GetNewNpcBaseID()`

- **定义**: [`SoundApp.h:157`](../SoundApp.h:157) | **实现**: [`SoundApp.cpp:1519`](../SoundApp.cpp:1519)
- **功能**: 获取当前最大 BaseID + 1 作为新 NPC 的 BaseID。

#### `bool AddNewNpcBase(int id, int type, std::wstring strName, std::wstring strModel = L"male", std::wstring strTitle = L"", int chat1 = 1, int chat2 = 1, int chat3 = 1)`

- **定义**: [`SoundApp.h:176`](../SoundApp.h:176) | **实现**: [`SoundApp.cpp:1534`](../SoundApp.cpp:1534)
- **功能**: 创建新的 NPC 基础数据并添加到列表。

#### `void LoadAllBaseNpc()`

- **定义**: [`SoundApp.h:163`](../SoundApp.h:163) | **实现**: [`SoundApp.cpp:1062`](../SoundApp.cpp:1062)
- **功能**: 从 `/table/xmltable/npc.CNPCConfig.xml` 加载所有 NPC 基础数据到 `m_NpcBaseList`。

#### `void LoadNpcShapeMap()`

- **定义**: [`SoundApp.h:164`](../SoundApp.h:164) | **实现**: [`SoundApp.cpp:1018`](../SoundApp.cpp:1018)
- **功能**: 从 `/table/xmltable/npc.cnpcshape.xml` 加载 NPC 造型映射（modelID → modelName/body/head/hair/dirType）。

### 1.5 跳转点接口

#### `int AddJumpPoint(int Logic_X, int Logic_Y, int destMapID, int Dest_X, int Dest_Y)`

- **定义**: [`SoundApp.h:246`](../SoundApp.h:246) | **实现**: [`SoundApp.cpp:1820`](../SoundApp.cpp:1820)
- **功能**: 添加跳转点。在指定逻辑坐标创建传送特效，生成唯一 ID。
- **参数**:
  - `Logic_X`, `Logic_Y` — 跳转点逻辑坐标（世界像素）
  - `destMapID` — 目标地图 ID
  - `Dest_X`, `Dest_Y` — 目标点坐标
- **返回值**: 新跳转点 ID；失败返回 -1
- **特效**: 使用 `animation/ui/mt_chuansong/chuansong` 动画

#### `void LoadJumpPoint(const std::wstring& strGotoXmlName)`

- **定义**: [`SoundApp.h:249`](../SoundApp.h:249) | **实现**: [`SoundApp.cpp:1880`](../SoundApp.cpp:1880)
- **功能**: 从 XML 文件加载跳转点。每个跳转点占 5×5 = 25 个 `<item>` 节点，取中心节点（第 12 个）的坐标和目标信息。
- **参数**: `strGotoXmlName` — 跳转点数据文件路径

#### `bool SaveJumpPointInf()`

- **定义**: [`SoundApp.h:250`](../SoundApp.h:250) | **实现**: [`SoundApp.cpp:1936`](../SoundApp.cpp:1936)
- **功能**: 保存跳转点信息到 XML。每个跳转点展开为 5×5 = 25 个 `<item>` 节点。
- **返回值**: `true` 保存成功

#### `int SelectJumpPointByPoint(CPoint pt)`

- **定义**: [`SoundApp.h:247`](../SoundApp.h:247) | **实现**: [`SoundApp.cpp:1843`](../SoundApp.cpp:1843)
- **功能**: 通过坐标选择跳转点。判断点击位置与跳转点特效位置的距离是否在 3 个网格范围内。
- **返回值**: 跳转点 ID；未命中返回 -1

#### `void DelectJumpPoint(int id)`

- **定义**: [`SoundApp.h:248`](../SoundApp.h:248) | **实现**: [`SoundApp.cpp:1862`](../SoundApp.cpp:1862)
- **功能**: 删除指定 ID 的跳转点，移除特效。

#### `void MoveSelJumpPoint(CPoint pt)`

- **定义**: [`SoundApp.h:258`](../SoundApp.h:258) | **实现**: [`SoundApp.cpp:2074`](../SoundApp.cpp:2074)
- **功能**: 移动当前选中的跳转点到新坐标。

#### `int GenerateNewJumpPointID()`

- **定义**: [`SoundApp.h:255`](../SoundApp.h:255) | **实现**: [`SoundApp.cpp:1983`](../SoundApp.cpp:1983)
- **功能**: 生成新的跳转点 ID（当前最大 ID + 1）。

#### `void AddNewJumpPoint()`

- **定义**: [`SoundApp.h:252`](../SoundApp.h:252) | **实现**: [`SoundApp.cpp:1974`](../SoundApp.cpp:1974)
- **功能**: 在视口中心创建新跳转点（目标为 0,0,0），自动选中并进入编辑状态。

#### `bool PointCanJump(CPoint pt)`

- **定义**: [`SoundApp.h:262`](../SoundApp.h:262) | **实现**: [`SoundApp.cpp:2406`](../SoundApp.cpp:2406)
- **功能**: 检查指定坐标周围 5×5 区域内是否有阻挡点。
- **返回值**: `true` 可以放置跳转点

#### `CPoint FixPoint(const CPoint& pt)`

- **定义**: [`SoundApp.h:263`](../SoundApp.h:263) | **实现**: [`SoundApp.cpp:2428`](../SoundApp.cpp:2428)
- **功能**: 将坐标对齐到网格。`newX = (pt.x / 24) * 24`，`newY = (pt.y / 16) * 16`。

### 1.6 区域管理接口

#### `void SetRegion(const int& x, const int& y, RegionType rt)`

- **定义**: [`SoundApp.h:266`](../SoundApp.h:266) | **实现**: [`SoundApp.cpp:2124`](../SoundApp.cpp:2124)
- **功能**: 设置单格区域类型。委托给 `m_RegionBuffer.AddPoint()`，同时调用 `AddMonsterPoint()`。

#### `void SetRegionBig(const int& x, const int& y, RegionType rt)`

- **定义**: [`SoundApp.h:267`](../SoundApp.h:267) | **实现**: [`SoundApp.cpp:2132`](../SoundApp.cpp:2132)
- **功能**: 笔刷范围设置区域类型。以 `(x, y)` 为中心、`m_EdgeSize` 为边长的正方形区域内逐格设置。

#### `void DelRegion(const int& x, const int& y, RegionType rt)`

- **定义**: [`SoundApp.h:268`](../SoundApp.h:268) | **实现**: [`SoundApp.cpp:2154`](../SoundApp.cpp:2154)
- **功能**: 删除单格区域类型。委托给 `m_RegionBuffer.DelPoint()`。

#### `void DelRegionBig(const int& x, const int& y, RegionType rt)`

- **定义**: [`SoundApp.h:269`](../SoundApp.h:269) | **实现**: [`SoundApp.cpp:2162`](../SoundApp.cpp:2162)
- **功能**: 笔刷范围删除区域类型。

#### `bool GetIsTypeOfRegion(const int& x, const int& y, RegionType rt)`

- **定义**: [`SoundApp.h:270`](../SoundApp.h:270) | **实现**: [`SoundApp.cpp:2184`](../SoundApp.cpp:2184)
- **功能**: 检查指定网格坐标是否属于指定区域类型。
- **返回值**: `true` 属于该区域类型

#### `void WriteRegionBufferToFile(std::wstring filename)`

- **定义**: [`SoundApp.h:271`](../SoundApp.h:271) | **实现**: [`SoundApp.cpp:2189`](../SoundApp.cpp:2189)
- **功能**: 将区域缓冲序列化到文件。仅当缓冲非空时写入。

#### `void ReadRegionBufferFromFile(std::wstring filename)`

- **定义**: [`SoundApp.h:272`](../SoundApp.h:272) | **实现**: [`SoundApp.cpp:2195`](../SoundApp.cpp:2195)
- **功能**: 从文件反序列化区域缓冲。加载失败时重新初始化空缓冲。

### 1.7 跳跃阻挡接口

#### `bool LoadJumpBlockInf(std::wstring jumpBlockFileName)`

- **定义**: [`SoundApp.h:299`](../SoundApp.h:299) | **实现**: [`SoundApp.cpp:2488`](../SoundApp.cpp:2488)
- **功能**: 从文件加载跳跃阻挡信息到 `m_JumpBlockBuffer`。
- **返回值**: `true` 加载成功

#### `bool SaveJumpBlockInf(std::wstring jumpBlockFileName)`

- **定义**: [`SoundApp.h:305`](../SoundApp.h:305) | **实现**: [`SoundApp.cpp:2723`](../SoundApp.cpp:2723)
- **功能**: 保存跳跃阻挡信息到文件。使用 `CRegionBuffer<unsigned char>` 序列化。
- **返回值**: `true` 保存成功

#### `void SetJumpBlock(CPoint pixel, bool brush, unsigned char type)`

- **定义**: [`SoundApp.h:301`](../SoundApp.h:301) | **实现**: [`SoundApp.cpp:2552`](../SoundApp.cpp:2552)
- **功能**: 设置跳跃阻挡点。支持单格和笔刷模式。

#### `unsigned char GetJumpBlock(CPoint pixel)`

- **定义**: [`SoundApp.h:300`](../SoundApp.h:300) | **实现**: [`SoundApp.cpp:2517`](../SoundApp.cpp:2517)
- **功能**: 获取指定像素坐标处的跳跃阻挡值。

#### `void ClearJumpBlock(CPoint center, int edge)`

- **定义**: [`SoundApp.h:302`](../SoundApp.h:302) | **实现**: [`SoundApp.cpp:2530`](../SoundApp.cpp:2530)
- **功能**: 清除指定范围内的跳跃阻挡。

### 1.8 怪物分布接口

#### `bool SaveMonsterKind(std::wstring filename)`

- **定义**: [`SoundApp.h:217`](../SoundApp.h:217) | **实现**: [`SoundApp.cpp:2233`](../SoundApp.cpp:2233)
- **功能**: 保存怪物分布数据到二进制文件。
- **文件格式**: `[int: 16] [size_t: width] [size_t: height] [int: count] [uint:key, int:val]...`

#### `bool ReadMonsterKind(std::wstring filename)`

- **定义**: [`SoundApp.h:218`](../SoundApp.h:218) | **实现**: [`SoundApp.cpp:2278`](../SoundApp.cpp:2278)
- **功能**: 从二进制文件读取怪物分布数据到 `m_Monbuffer`。

#### `void LoadAllMonster()`

- **定义**: [`SoundApp.h:196`](../SoundApp.h:196) | **实现**: [`SoundApp.cpp:2352`](../SoundApp.cpp:2352)
- **功能**: 从 `/table/xmltable/map.cmineareainfo.xml` 加载所有怪物基础数据到 `m_monsterBaseList`。

#### `int CheckMonsterPoint(const unsigned int& w, const unsigned int& h)`

- **定义**: [`SoundApp.h:210`](../SoundApp.h:210) | **实现**: [`SoundApp.cpp:2336`](../SoundApp.cpp:2336)
- **功能**: 检查指定网格坐标的怪物类型。
- **返回值**: 怪物类型 ID；无数据返回 -1

### 1.9 通用工具接口

#### `void Reset()`

- **定义**: [`SoundApp.h:131`](../SoundApp.h:131) | **实现**: [`SoundApp.cpp:159`](../SoundApp.cpp:159)
- **功能**: 重置所有编辑数据。状态回到 `EDIT_STATE_MAZE`，清除所有 Sprite 和 NPC，重置选中状态。

#### `bool GetXmlNodeList(std::wstring path, XMLIO::CFileReader& fr, XMLIO::CNodeList& typenl)`

- **定义**: [`SoundApp.h:170`](../SoundApp.h:170) | **实现**: [`SoundApp.cpp:1203`](../SoundApp.cpp:1203)
- **功能**: 打开 XML 文件并获取根节点的子节点列表。
- **返回值**: `true` 成功打开并获取节点

#### `EDIT_STATE GetEditState()` / `void SetEditState(EDIT_STATE)`

- 通过 `CSoundEditorDoc` 间接访问，见 [`SoundEditorDoc.h:70-71`](../SoundEditorDoc.h:71)。

#### `void SetDrawGrid(bool b)` / `void SetDrawBlock(bool b)` / `void SetRegionType(int t)`

- **定义**: [`SoundApp.h:239-241`](../SoundApp.h:239)
- **功能**: 设置绘制开关和当前区域类型。

---

## 2. CMainDlg 类

**定义**: [`MainDlg.h:15`](../MainDlg.h:15)  
**实现**: [`MainDlg.cpp`](../MainDlg.cpp)  
**基类**: `CDialog`  
**职责**: 主对话框窗口，管理引擎创建、地图加载、用户输入分发和保存操作。

### 2.1 生命周期接口

#### `BOOL OnInitDialog()`

- **实现**: [`MainDlg.cpp:57`](../MainDlg.cpp:57)
- **功能**: 对话框初始化。创建引擎实例、初始化 `SoundApp`、启动 25ms 定时器。
- **关键流程**:
  1. 获取 `CSoundEditorDoc` 文档对象
  2. 设置窗口大小为 1024×768
  3. 配置 `Nuclear::EngineParameter`（窗口句柄、异步读取、1024×768 分辨率）
  4. 调用 `Nuclear::GetEngine()->Run(ep)` 启动引擎
  5. 循环调用 `OnIdle()` 直到 `SoundApp` 初始化完成
  6. 设置 `m_soundApp.SetDoc(m_pDoc)`
  7. 启动定时器：`SetTimer(1000, 25, NULL)`

#### `void OnTimer(UINT_PTR nIDEvent)`

- **实现**: [`MainDlg.cpp:95`](../MainDlg.cpp:95)
- **功能**: 定时器回调（25ms 间隔）。调用 `m_pEngine->OnIdle()` 驱动引擎渲染循环。

### 2.2 地图管理接口

#### `bool LoadMap(const CString& name)`

- **定义**: [`MainDlg.h:124`](../MainDlg.h:124) | **实现**: [`MainDlg.cpp:123`](../MainDlg.cpp:123)
- **功能**: 加载地图。先卸载旧地图，再加载新地图及所有关联数据。
- **参数**: `name` — 地图目录名（如 `5002_dayanta2`）
- **返回值**: `true` 加载成功
- **关键流程**:
  1. 调用 `UnloadMap()` 卸载当前地图
  2. 构造文件路径：`/map/{name}/`、`maze.dat`、`npc.xml`（或 `npc.dat`）、`goto.dat`
  3. 调用 `IWorld::LoadMap()` 加载地图资源
  4. 设置视口左上角为 (0, 0)
  5. 获取地图尺寸并更新文档
  6. 依次调用：
     - `ReadMazeBuffer()` — 读取阻挡数据
     - `ResetMapNpc()` — 加载 NPC 实例
     - `LoadJumpPoint()` — 加载跳转点
     - `ReadRegionBufferFromFile()` — 读取区域缓冲
     - `LoadJumpBlockInf()` — 加载跳跃阻挡
     - `ReadMonsterKind()` — 读取怪物分布

#### `bool UnloadMap()`

- **定义**: [`MainDlg.h:125`](../MainDlg.h:125) | **实现**: [`MainDlg.cpp:114`](../MainDlg.cpp:114)
- **功能**: 卸载当前地图。调用 `SoundApp::Reset()` 和 `IWorld::UnloadMap()`。

### 2.3 鼠标事件接口

#### `void OnMouseMove(UINT nFlags, CPoint point)`

- **实现**: [`MainDlg.cpp:248`](../MainDlg.cpp:248)
- **功能**: 根据编辑状态和工具状态分发鼠标移动操作。支持视口拖拽、阻挡刷涂、区域设置等。

#### `void OnLButtonDown(UINT nFlags, CPoint point)`

- **实现**: 搜索 `ON_WM_LBUTTONDOWN` 消息映射
- **功能**: 左键按下处理。根据当前工具状态执行对应操作（设置阻挡、放置 NPC、选择 NPC 等）。

#### `void OnLButtonUp(UINT nFlags, CPoint point)`

- **实现**: 搜索 `ON_WM_LBUTTONUP` 消息映射
- **功能**: 左键释放处理。释放鼠标捕获。

#### `void OnRButtonDown(UINT nFlags, CPoint point)`

- **实现**: [`MainDlg.cpp:200`](../MainDlg.cpp:200)
- **功能**: 右键按下处理。在 `EDIT_STATE_MAZE`/`EDIT_STATE_NPC` 下记录视口起始位置用于拖拽；在 `EDIT_STATE_MapJump` 下显示跳转点信息。

### 2.4 工具与保存接口

#### `void OnTool(UINT nID)`

- **定义**: [`MainDlg.h:144`](../MainDlg.h:144)
- **功能**: 工具切换。根据菜单项 ID 设置 `m_toolState` 和 `m_regionType`。

#### `void OnSavemaze()`

- **定义**: [`MainDlg.h:152`](../MainDlg.h:152) | **实现**: [`MainDlg.cpp:1125`](../MainDlg.cpp:1125)
- **功能**: 保存全部数据。依次调用：
  1. `WriteMazeBuffer()` — 保存阻挡点
  2. `WriteRegionBufferToFile()` — 保存区域
  3. `SaveJumpBlockInf()` — 保存跳跃阻挡
  4. `SaveIslandInf(layer=1)` — 保存 1 层孤岛
  5. `SaveIslandInf(layer=2)` — 保存 2 层孤岛
  6. `SaveMonsterKind()` — 保存怪物分布

### 2.5 坐标转换接口

#### `static void Client2World(const POINT& clientpt, const RECT& vp, POINT& worldpt)`

- **定义**: [`MainDlg.h:94`](../MainDlg.h:94)
- **功能**: 屏幕坐标转世界坐标。`worldpt = clientpt + vp.left/top`。

#### `static void World2Client(const POINT& worldpt, const RECT& vp, POINT& clientpt)`

- **定义**: [`MainDlg.h:99`](../MainDlg.h:99)
- **功能**: 世界坐标转屏幕坐标。`clientpt = worldpt - vp.left/top`。

#### `inline CPoint PixelPointToGridPoint(CPoint pt)`

- **定义**: [`MainDlg.h:11`](../MainDlg.h:11)
- **功能**: 像素坐标转网格坐标。`gridX = pt.x / 24`，`gridY = pt.y / 16`。

---

## 3. CSoundEditorDoc 类

**定义**: [`SoundEditorDoc.h:40`](../SoundEditorDoc.h:40)  
**基类**: `CDocument`  
**职责**: MFC 文档类，管理编辑状态、地图尺寸和序列化。

### 公共接口

| 函数签名 | 功能 |
|----------|------|
| `const Nuclear::CPOINT GetMapSize()` | 获取地图尺寸 |
| `void SetMapSize(const Nuclear::CPOINT& size)` | 设置地图尺寸 |
| `EDIT_STATE GetEditState()` | 获取当前编辑状态 |
| `void SetEditState(EDIT_STATE state)` | 设置编辑状态 |
| `void SaveAsXML(XMLIO::CONode& root)` | 保存为 XML |
| `virtual BOOL OnNewDocument()` | MFC 新建文档 |
| `virtual BOOL OnOpenDocument(LPCTSTR lpszPathName)` | MFC 打开文档 |
| `virtual BOOL OnSaveDocument(LPCTSTR lpszPathName)` | MFC 保存文档 |

### 公共成员

| 成员 | 类型 | 功能 |
|------|------|------|
| `m_pSelectedShape` | `Nuclear::XPIShape*` | 当前选中的形状 |
| `m_nSelectedPt` | `int` | 选中的点索引 |
| `m_PolygonMouseState` | `POLYGON_MOUSE_STATE` | 多边形鼠标状态 |
| `m_bIsIngoreDragging` | `bool` | 是否忽略拖拽 |
| `m_bTestingDrawBkgArea` | `BOOL` | 测试绘制背景区域 |
| `m_nUpdateViewSign` | `int` | 视图更新标志（`UPDATE_VIEW_SIGN` 位掩码） |

---

## 4. Sprite 类

**定义**: [`Sprite.h:4`](../Sprite.h:4)  
**职责**: 包装 `Nuclear::ISprite` 接口，提供精灵位置、方向、可见性、模型、组件、动作、移动等操作。

### 4.1 构造/析构

| 函数签名 | 功能 |
|----------|------|
| `Sprite(Nuclear::ISprite* pSprite)` | 构造函数，接受引擎精灵指针 |
| `~Sprite(void)` | 析构函数 |

### 4.2 动作状态机

| 成员/函数 | 说明 |
|-----------|------|
| `m_actState` | 动作状态：0=stand1, 1=runleft, 2=runright, 3=骑马 |
| `void UpdateAction(Nuclear::XPUSA_TYPE type)` | 根据引擎状态类型更新动作 |
| `void GoToRun()` | 切换到跑步状态 |
| `int GetState() const` | 获取当前动作状态 |

### 4.3 位置与方向

| 函数签名 | 功能 |
|----------|------|
| `void SetLocation(const Nuclear::Location& location)` | 设置世界像素坐标位置 |
| `Nuclear::Location GetLocation() const` | 获取当前位置 |
| `void SetDirection(Nuclear::XPDIRECTION direction)` | 设置方向（枚举值） |
| `Nuclear::XPDIRECTION GetDirection() const` | 获取当前方向 |
| `void SetDirection(int targetx, int targety)` | 转向目标点 |
| `void SetDirection(const Nuclear::CPOINT& target)` | 转向目标点 |
| `void SetDirection(int dir)` | 按方向值设置 |

### 4.4 可见性与模型

| 函数签名 | 功能 |
|----------|------|
| `void SetVisible(bool v)` | 设置可见性 |
| `bool IsVisiable() const` | 获取可见性 |
| `void SetModel(const std::wstring& modelname)` | 设置精灵模型名称 |

### 4.5 组件

| 函数签名 | 功能 |
|----------|------|
| `void SetComponent(int scid, const std::wstring& resource, Nuclear::XPCOLOR color = 0xffffffff)` | 设置装备组件。`scid`: 0=body, 1=head/body, 2=head, 3=weapon/hair |
| `void SetRideName(const std::wstring& name)` | 设置坐骑名称 |

### 4.6 动作播放

| 函数签名 | 功能 |
|----------|------|
| `void SetDefaultAction(const std::wstring& action_name, bool fHoldLastFrame, float freq = 1.0f)` | 设置默认动作 |
| `std::wstring GetDefaultAction()` | 获取默认动作名 |
| `void PlayAction(const std::wstring& action_name, float freq = 1.0f)` | 播放临时动作 |
| `int GetCurrentFrame() const` | 获取当前帧号 |
| `int GetTotalFrame() const` | 获取总帧数 |

### 4.7 特效

| 函数签名 | 功能 |
|----------|------|
| `bool SetBindFile(const std::wstring& bindFile)` | 设置绑定文件 |
| `std::wstring GetBindFile()` | 获取绑定文件 |
| `Nuclear::IEffect* SetDurativeEffect(...)` | 设置持续效果（**当前已注释掉实现，返回未定义值**） |
| `Nuclear::IEffect* SetContinueEffect(...)` | 设置连续效果（**当前返回 NULL**） |
| `void RemoveDurativeEffect(Nuclear::IEffect* pEffect)` | 移除持续效果 |
| `void PlayEffect(...)` | 播放临时效果（**当前已注释掉实现**） |

### 4.8 移动

| 函数签名 | 功能 |
|----------|------|
| `void SetMoveSpeed(float speed)` | 设置移动速度（像素/毫秒），默认 0.160 |
| `float GetMoveSpeed() const` | 获取移动速度 |
| `void StopMove()` | 停止移动，清除路径 |
| `bool IsMoving() const` | 是否移动中 |
| `void SetMoveSuspended(bool moveSuspended)` | 设置/取消暂停状态 |
| `bool IsMoveSuspended() const` | 是否暂停 |
| `void MoveTo(int targetX, int targetY, int range, const Nuclear::CSIZE* size)` | 移动到目标点 |
| `void MoveTo(const Nuclear::Location& target, int range, const Nuclear::CSIZE* size)` | 移动到目标点 |
| `void EnableShadow(bool b)` | 启用/禁用阴影 |
| `bool IsEnableShadow()` | 是否启用阴影 |

### 4.9 公共成员

| 成员 | 类型 | 说明 |
|------|------|------|
| `m_pSprite` | `Nuclear::ISprite*` | 被包装的引擎精灵指针 |

---

## 5. CNpc 类

**定义**: [`Npc.h:80`](../Npc.h:80)  
**基类**: `Sprite`  
**职责**: 表示地图上的一个 NPC 实例，继承精灵功能并增加 ID、名称和基础数据关联。

### 公共接口

| 函数签名 | 功能 |
|----------|------|
| `CNpc(Nuclear::ISprite* piSprite)` | 构造函数 |
| `~CNpc()` | 析构函数 |
| `void SetId(int id)` | 设置实例 ID |
| `int GetId()` | 获取实例 ID |
| `void SetName(const std::wstring& name)` | 设置 NPC 名称 |
| `std::wstring GetName()` | 获取 NPC 名称 |

### 公共成员

| 成员 | 类型 | 说明 |
|------|------|------|
| `m_pNpcBaseData` | `const stNpcBaseData*` | 指向 NPC 基础数据的指针（非拥有） |

### 私有成员

| 成员 | 类型 | 说明 |
|------|------|------|
| `m_nId` | `int` | NPC 实例 ID |
| `m_strName` | `std::wstring` | NPC 名称 |

---

## 6. CRegionBuffer\<T\> 模板类

**定义**: [`regionbuffer.h:7`](../regionbuffer.h:7)  
**基类**: `Nuclear::PObject`  
**职责**: 稀疏网格区域缓冲，支持位运算合并/清除区域类型，支持序列化。

### 公共接口

#### `CRegionBuffer()`

- **定义**: [`regionbuffer.h:16`](../regionbuffer.h:16)
- **功能**: 默认构造。`m_Width = 0`，`m_Height = 0`。

#### `void Init(const unsigned int& w, const unsigned int& h)`

- **定义**: [`regionbuffer.h:18`](../regionbuffer.h:18)
- **功能**: 初始化缓冲区尺寸。断言 `w <= 65535 && h <= 65535`。
- **参数**: `w` — 网格宽度，`h` — 网格高度

#### `bool IsEmpty()`

- **定义**: [`regionbuffer.h:26`](../regionbuffer.h:26)
- **功能**: 检查缓冲区是否为空。
- **返回值**: `m_buffer.empty()`

#### `void AddPoint(const unsigned int& w, const unsigned int& h, const T& regiontype)`

- **定义**: [`regionbuffer.h:31`](../regionbuffer.h:31)
- **功能**: 添加区域点。使用位或合并：`buffer[key] |= regiontype`。
- **Key 编码**: `key = (w << 16) | h`

#### `void DelPoint(const unsigned int& w, const unsigned int& h, const T& regiontype)`

- **定义**: [`regionbuffer.h:49`](../regionbuffer.h:49)
- **功能**: 删除区域点。使用位与清除：`buffer[key] &= ~regiontype`。

#### `bool CheckPointType(const unsigned int& w, const unsigned int& h, const T& regiontype)`

- **定义**: [`regionbuffer.h:64`](../regionbuffer.h:64)
- **功能**: 检查指定坐标是否包含指定区域类型。
- **返回值**: `(buffer[key] & regiontype) > 0`

#### `T GetPointValue(const unsigned int& w, const unsigned int& h)`

- **定义**: [`regionbuffer.h:78`](../regionbuffer.h:78)
- **功能**: 获取指定坐标的完整区域值。
- **返回值**: 区域值；不存在返回 0

#### `virtual Nuclear::XOStream& marshal(Nuclear::XOStream& os) const`

- **定义**: [`regionbuffer.h:91`](../regionbuffer.h:91)
- **功能**: 序列化到输出流。
- **格式**: `'QUYU'` (4字节) + `m_Width` (uint) + `m_Height` (uint) + `count` (int) + `[key (uint), value (T)]...`

#### `virtual const Nuclear::XIStream& unmarshal(const Nuclear::XIStream& os)`

- **定义**: [`regionbuffer.h:111`](../regionbuffer.h:111)
- **功能**: 从输入流反序列化。校验 `'QUYU'` 文件头。

#### `bool SaveToNativePath(const wchar_t* path)` / `bool LoadFromNativePath(const wchar_t* path)`

- 继承自 `Nuclear::PObject`，内部调用 `marshal`/`unmarshal`。

### 私有成员

| 成员 | 类型 | 说明 |
|------|------|------|
| `m_Width` | `unsigned int` | 网格宽度 |
| `m_Height` | `unsigned int` | 网格高度 |
| `m_buffer` | `std::map<unsigned int, T>` | 稀疏缓冲区。Key = `(x << 16) | y`，Value = 区域类型位组合 |

---

## 7. 数据结构定义

### 7.1 stNpcBaseData

**定义**: [`Npc.h:16`](../Npc.h:16)

NPC 基础数据表记录。

| 字段 | 类型 | 说明 |
|------|------|------|
| `BaseID` | `int` | NPC 基础 ID（默认 -1） |
| `strNpcModel` | `std::wstring` | NPC 造型名称（如 `male`、`3ds_xxx`） |
| `strBodyResName` | `std::wstring` | 身体资源名称 |
| `strHeadResName` | `std::wstring` | 头部资源名称 |
| `strHairResName` | `std::wstring` | 头发资源名称 |
| `eNpcType` | `int` | NPC 类型（`enumNpcType` 枚举值） |
| `strName` | `std::wstring` | NPC 名称 |
| `strTitle` | `std::wstring` | NPC 称谓 |
| `chat1` | `int` | 闲话 ID 1（默认 0） |
| `chat2` | `int` | 闲话 ID 2（默认 0） |
| `chat3` | `int` | 闲话 ID 3（默认 0） |
| `dirType` | `int` | 方向类型（默认 4，即 8 方向） |

### 7.2 stMonsterBaseData

**定义**: [`Monster.h:3`](../Monster.h:3)

怪物基础数据记录。

| 字段 | 类型 | 说明 |
|------|------|------|
| `BaseID` | `int` | 怪物基础 ID（默认 -1） |
| `strMonsterColor` | `std::wstring` | 怪物颜色（8 位 ARGB 十六进制字符串） |
| `strMonsterDescribe` | `std::wstring` | 怪物描述 |

### 7.3 stJumpPointInf

**定义**: [`SoundApp.h:27`](../SoundApp.h:27)

跳转点信息结构。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `int` | 跳转点编号 |
| `effect` | `Nuclear::IEffect*` | 对应的传送特效实例 |
| `dest_mapID` | `int` | 目标地图 ID |
| `dest_X` | `int` | 目标点 X 坐标 |
| `dest_Y` | `int` | 目标点 Y 坐标 |

### 7.4 SoundApp::MonsterInfo

**定义**: [`SoundApp.h:202`](../SoundApp.h:202)

怪物渲染信息。

| 字段 | 类型 | 说明 |
|------|------|------|
| `ID` | `std::wstring` | 怪物 ID 字符串 |
| `Color` | `Nuclear::XPCOLOR` | 渲染颜色 |
| `Area` | `Nuclear::FRECT` | 渲染区域矩形 |

---

## 8. UI 对话框类

### 8.1 CNpcPropertyDlg

**定义**: [`NpcPropertyDlg.h:14`](../NpcPropertyDlg.h:14)  
**基类**: `CDialog`  
**对话框 ID**: `IDD_NPCPANEL`

| 函数签名 | 功能 |
|----------|------|
| `CNpcPropertyDlg(CWnd* pParent = NULL)` | 构造函数 |
| `void ChangeSelNpc(CNpc* pNpc)` | 切换选中 NPC，更新属性面板显示 |
| `void ChangeSelNpcPos(int x, int y)` | 更新 NPC 位置显示（逻辑坐标） |
| `void Reset()` | 重置面板状态 |
| `afx_msg void OnBnClickedButtonAddnpc()` | "添加 NPC"按钮点击 |
| `afx_msg void OnBnClickedButtonNewnpc()` | "新建 NPC 基础"按钮点击 |
| `afx_msg void OnBnClickedNpcOk()` | "确认修改"按钮点击 |
| `afx_msg void OnBnClickedNpcSave()` | "保存 NPC 信息"按钮点击 |
| `afx_msg void OnBnClickedNpcCancel()` | "取消"按钮点击 |

**成员**:

| 成员 | 类型 | 说明 |
|------|------|------|
| `m_pMainDlg` | `CMainDlg*` | 主对话框指针 |
| `m_AddNpcDlg` | `CAddNpcDlg` | 添加 NPC 子对话框 |

### 8.2 CAddNpcDlg

**定义**: [`AddNpcDlg.h:10`](../AddNpcDlg.h:10)  
**基类**: `CDialog`  
**对话框 ID**: `IDD_DIALOG_ADDNPC`

| 函数签名 | 功能 |
|----------|------|
| `BOOL OnInitDialog()` | 初始化对话框，调用 `InitCombox()` |
| `void InitCombox()` | 初始化 NPC 基础列表下拉框 |
| `afx_msg void OnBnClickedAddnpc()` | "添加"按钮点击 |
| `afx_msg void OnBnClickedCancelAddnpc()` | "取消"按钮点击 |

**成员**:

| 成员 | 类型 | 说明 |
|------|------|------|
| `m_pCombox` | `CComboBox*` | NPC 选择下拉框 |
| `m_pSoundApp` | `SoundApp*` | SoundApp 实例指针 |

### 8.3 CJumpPointInfDlg

**定义**: [`JumpPointInfDlg.h:10`](../JumpPointInfDlg.h:10)  
**基类**: `CDialog`  
**对话框 ID**: `IDD_DIALOG_JPINF`

| 函数签名 | 功能 |
|----------|------|
| `void ChangeJPInf(int mapID, int dest_X, int dest_Y)` | 更新跳转点目标信息显示 |
| `void JumpIsland(int idx)` | 跳转到指定孤岛 |
| `afx_msg void OnBnClickedJPInfOK()` | "确认"按钮点击 |
| `afx_msg void OnBnClickedDeljump()` | "删除跳转点"按钮点击 |
| `afx_msg void OnBnClickedAddjump()` | "添加跳转点"按钮点击 |
| `afx_msg void OnBnClickedSavejpinf()` | "保存跳转点"按钮点击 |

**成员**:

| 成员 | 类型 | 说明 |
|------|------|------|
| `m_pMainDlg` | `CMainDlg*` | 主对话框指针 |

### 8.4 CMonsterPanel

**定义**: [`CMonsterPanel.h:7`](../CMonsterPanel.h:7)  
**基类**: `CDialog`  
**对话框 ID**: `IDD_MONSTER_PANEL`

| 函数签名 | 功能 |
|----------|------|
| `void CreateMonCombo()` | 初始化怪物类型下拉框 |
| `void GetMonsterKind(int& MonKind)` | 获取当前选中的怪物类型 |
| `void GetMonsterIndex(int& MonIndex)` | 获取当前选中的怪物索引 |
| `int GetSelectMonster()` | 获取选中的怪物 ID |
| `void SetMonsterKind(int MonKind)` | 设置怪物类型 |
| `afx_msg void OnBnClickedMonOk()` | "确认"按钮点击 |

**成员**:

| 成员 | 类型 | 说明 |
|------|------|------|
| `m_pMainDlg` | `CMainDlg*` | 主对话框指针 |
| `mMonsterKind` | `int` | 当前怪物类型 |
| `mMonsterIndex` | `int` | 当前怪物索引 |

---

## 9. 枚举与常量

### 9.1 EDIT_STATE

**定义**: [`SoundEditorDoc.h:8`](../SoundEditorDoc.h:8)

| 值 | 名称 | 说明 |
|----|------|------|
| 0 | `EDIT_STATE_MAZE` | 编辑阻挡点 |
| 1 | `EDIT_STATE_NPC` | 编辑 NPC |
| 2 | `EDIT_STATE_MapJump` | 地图跳转点编辑 |
| 3 | `EDIT_STATE_TESTING` | 测试模式 |

### 9.2 RegionType

**定义**: [`SoundApp.h:47`](../SoundApp.h:47)

| 值 | 名称 | 说明 |
|----|------|------|
| `0x1` | `RY_QIEZUO` | 切磋区域 |
| `0x2` | `RY_BOSA` | 播撒区域 |
| `0x4` | `RY_BAITAN` | 摆摊区域 |
| `0x8` | `RY_KITE` | 风筝区域 |
| `0x10` | `RY_SHUAGUAI` | 刷怪区域 |
| `0x20` | `RY_MINGSHENG` | 名胜区域 |
| `0x40` | `RY_GAOJISHUGUAI` | 高级刷怪区域 |
| `1<<10` | `RY_AREA11` | 自由区域 11 |
| `1<<11` | `RY_AREA12` | 自由区域 12 |
| `1<<12` | `RY_AREA13` | 自由区域 13 |
| `1<<13` | `RY_AREA14` | 自由区域 14 |
| `1<<14` | `RY_AREA15` | 自由区域 15 |
| `1<<15` | `RY_AREA16` | 自由区域 16 |

### 9.3 QingGongBlockType

**定义**: [`SoundApp.h:64`](../SoundApp.h:64)

| 值 | 名称 | 说明 |
|----|------|------|
| `0x1` | `QG_1` | 飞跃阻挡 1 阶 |
| `0x2` | `QG_2` | 飞跃阻挡 2 阶 |
| `0x4` | `QG_3` | 飞跃阻挡 3 阶 |
| `0x8` | `QG_4` | 飞跃阻挡 4 阶 |

### 9.4 enumNpcType

**定义**: [`Npc.h:5`](../Npc.h:5)

| 值 | 名称 | 说明 |
|----|------|------|
| 0 | `eNpcTypeNone` | 无 |
| 1 | `eNpcTypeImportant` | 重要 NPC |
| 2 | `eNpcTypeTranslate` | 传送 NPC |
| 3 | `eNpcTypeTrade` | 商业 NPC |
| 4 | `eNpcTypeNormal` | 普通 NPC |

### 9.5 关键常量

| 常量 | 值 | 定义位置 | 说明 |
|------|-----|----------|------|
| `GRID_WIDTH` | `24` | [`SoundApp.h:18`](../SoundApp.h:18) | 网格宽度（像素） |
| `GRID_HEIGHT` | `16` | [`SoundApp.h:19`](../SoundApp.h:19) | 网格高度（像素） |
| `s_BlockLayer2Mask` | `0x08` | [`SoundApp.h:72`](../SoundApp.h:72) | 2 层阻挡掩码 |
| `s_iJumPointGridNum` | `5` | [`SoundApp.h:285`](../SoundApp.h:285) | 跳转点占的格子数 N×N |
| `s_iJumpPointOffset_X` | `1` | [`SoundApp.h:286`](../SoundApp.h:286) | 跳转区域中心 X 偏移 |
| `s_iJumpPointOffset_Y` | `0` | [`SoundApp.h:287`](../SoundApp.h:287) | 跳转区域中心 Y 偏移 |

### 9.6 渲染颜色常量

**区域渲染颜色**（定义于 [`SoundApp.h:37`](../SoundApp.h:37) 及 [`SoundApp.cpp`](../SoundApp.cpp) 渲染函数中）：

| 区域类型 | 颜色值 | 说明 |
|----------|--------|------|
| 1 层阻挡 | `0x3FFF8800` | 黄色半透明 |
| 2 层阻挡 | `0x3F88FF00` | 浅绿色半透明 |
| 切磋 | `0x3FFF0000` | 红色半透明 |
| 播撒 | `0x3FFFFF00` | 黄色半透明 |
| 摆摊 | `0x3FFF00FF` | 紫色半透明 |
| 风筝 | `0x3F00FFFF` | 青色半透明 |
| 刷怪 | `0x3FFF0000` | 红色半透明 |
| 名胜 | `0x3FFF0000` | 红色半透明 |
| 高级刷怪 | `0x3F00FF88` | 绿色半透明 |
| 土地 | `0x7FFF7FF3F` | 黄色 |
| 草地 | `0x7F3FFF3F` | 绿色 |
| 水 | `0x7F3F3FFF` | 蓝色 |
| 跳转点(普通) | `0xCCFFFF00` | 黄色 |
| 跳转点(编辑中) | `0xCC87CEEB` | 天蓝色 |

**自由区域颜色**（定义于 [`SoundApp.h:37`](../SoundApp.h:37)）：

```cpp
const DWORD freeAreaColor[6] = {
    0x3FFF0000,  // 区域11 - 红
    0x3F00FF00,  // 区域12 - 绿
    0x3F0000FF,  // 区域13 - 蓝
    0x3FFF8F00,  // 区域14 - 橙
    0x3FFF8FFF,  // 区域15 - 粉
    0x3F8FFF8F,  // 区域16 - 浅绿
};
```

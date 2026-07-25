# 03 — 数据流向（Data Flow）

> **版本**: 1.0.0  
> **更新日期**: 2026-04-25  
> **源码路径**: `tools/engine/npceditor/`

---

## 1. 地图数据加载到显示的完整流程

### 1.1 数据文件到内存

```
文件系统:
  map/<name>/maze.dat
    → SoundApp::ReadMazeBuffer() → m_MazeBuffer[]

  map/<name>/npc.xml
    → SoundApp::ResetMapNpc() → m_NpcList[] + Nuclear::ISprite 实例

  map/<name>/goto.dat
    → SoundApp::LoadJumpPoint() → m_vecJumpVector[] + Nuclear::IEffect 特效

  <path>/regiontypeinfo.dat
    → SoundApp::ReadRegionBufferFromFile() → m_RegionBuffer

  <path>/JumpBlock.dat
    → SoundApp::LoadJumpBlockInf() → m_JumpBlockBuffer[]

  <path>/monster.dat
    → SoundApp::ReadMonsterKind() → m_Monbuffer
```

### 1.2 内存到显示

每帧在 [`SoundApp::OnRenderUI()`](../SoundApp.h:231) 中遍历可视区域格子进行绘制：

```
OnRenderUI() 每帧遍历可视区域格子:
  → m_MazeBuffer[]       → DrawBox(绿色/黄色半透明)    // 阻挡区域
  → m_RegionBuffer       → DrawBox(各区域颜色)          // 区域类型
  → m_JumpBlockBuffer[]  → DrawBox(飞跃阻挡颜色)        // 跳跃阻挡
  → m_NpcList[]          → DrawSelectNpcBox() + DrawNpcName()  // NPC 选择框与名字
  → m_vecJumpVector[]    → DrawJumpPoint()              // 跳转点标志
```

### 1.3 数据文件格式汇总

| 数据类型 | 文件格式 | 读写方式 | 关键函数 |
|----------|----------|----------|----------|
| 迷宫阻挡 | 二进制（`.dat`） | `fstream` 直接读写 | [`ReadMazeBuffer()`](../SoundApp.h:135) / [`WriteMazeBuffer()`](../SoundApp.h:136) |
| NPC 实例 | XML（`.xml`） | `XMLIO::CFileReader` / `XMLIO::CFileWriter` | [`ResetMapNpc()`](../SoundApp.h:167) / [`OnSaveNpcInf()`](../SoundApp.h:189) |
| 跳转点 | XML（`.dat`） | `XMLIO::CFileReader` / `XMLIO::CFileWriter` | [`LoadJumpPoint()`](../SoundApp.h:249) / [`SaveJumpPointInf()`](../SoundApp.h:250) |
| 区域类型 | 二进制（`CRegionBuffer` 序列化） | `Nuclear::XOStream` / `Nuclear::XIStream` | [`ReadRegionBufferFromFile()`](../SoundApp.h:272) / [`WriteRegionBufferToFile()`](../SoundApp.h:271) |
| 跳跃阻挡 | 二进制（`CRegionBuffer` 序列化） | `Nuclear::XOStream` / `Nuclear::XIStream` | [`LoadJumpBlockInf()`](../SoundApp.h:299) / [`SaveJumpBlockInf()`](../SoundApp.h:305) |
| 孤岛信息 | 二进制（`CRegionBuffer` 序列化） | `Nuclear::XOStream` | [`SaveIslandInf()`](../SoundApp.h:306) |
| 怪物分布 | 二进制 | `Nuclear::XOStream` / `FWrite` | [`ReadMonsterKind()`](../SoundApp.h:218) / [`SaveMonsterKind()`](../SoundApp.h:217) |

---

## 2. 数据持久化流程

### 2.1 保存全部数据（OnSavemaze）

用户触发保存操作时，[`CMainDlg::OnSavemaze()`](../MainDlg.h:152) 按以下顺序保存所有数据：

```
CMainDlg::OnSavemaze()
  │
  ├─→ SoundApp::WriteMazeBuffer(mazefilename)
  │     ├─→ SoundApp::CheckLonelyIsland()     // 孤岛检测
  │     ├─→ fstream::write()                   // 写入 maze.dat
  │     └─→ Nuclear::IWorld::SetMapMaze()      // 同步到引擎
  │
  ├─→ SoundApp::WriteRegionBufferToFile(regiontypeinfo.dat)
  │     └─→ CRegionBuffer::SaveToNativePath()  // 区域类型
  │
  ├─→ SoundApp::SaveJumpBlockInf(JumpBlock.dat)
  │     └─→ CRegionBuffer::SaveToNativePath()  // 跳跃阻挡
  │
  ├─→ SoundApp::SaveIslandInf(Island.dat, 1)
  │     ├─→ SoundApp::processBlockInfo()       // BFS 孤岛检测
  │     └─→ CRegionBuffer::SaveToNativePath()  // 1 层孤岛
  │
  ├─→ SoundApp::SaveIslandInf(Island2.dat, 2)
  │     ├─→ SoundApp::processBlockInfo()       // BFS 孤岛检测
  │     └─→ CRegionBuffer::SaveToNativePath()  // 2 层孤岛
  │
  └─→ SoundApp::SaveMonsterKind(monster.dat)
        └─→ Nuclear::XOStream 序列化 → FWrite   // 怪物分布
```

### 2.2 NPC 数据保存

```
CNpcPropertyDlg::OnBnClickedNpcSave()
  └─→ SoundApp::OnSaveNpcInf()
        └─→ XMLIO::CFileWriter → npc.xml
```

### 2.3 跳转点数据保存

```
CJumpPointInfDlg::OnBnClickedSavejpinf()
  └─→ SoundApp::SaveJumpPointInf()
        └─→ XMLIO::CFileWriter → goto.dat
```

---

## 3. 用户交互数据流

### 3.1 鼠标事件处理总览

```
鼠标事件 → CMainDlg::WindowProc()
  ├─→ Nuclear::IEngine::OnWindowsMessage()     // 转发给引擎
  │
  └─→ MFC 消息分发:
       ├─→ CMainDlg::OnLButtonDown()
       ├─→ CMainDlg::OnMouseMove()
       ├─→ CMainDlg::OnLButtonUp()
       └─→ CMainDlg::OnRButtonDown()
            │
            ├─→ 坐标转换: Client2World()
            │     worldpt.x = clientpt.x + vp.left
            │     worldpt.y = clientpt.y + vp.top
            │
            ├─→ 状态分发: switch(GetEditState()) + switch(m_toolState)
            │
            ├─→ 数据修改:
            │     SoundApp::SetBlockPoint()      // 阻挡编辑
            │     SoundApp::SetRegion()           // 区域编辑
            │     SoundApp::SetJumpBlock()        // 跳跃阻挡编辑
            │     SoundApp::SelectNpc()           // NPC 选择
            │     SoundApp::MoveSelectNpc()       // NPC 移动
            │
            └─→ 视图更新: m_pDoc->UpdateAllViews()
```

### 3.2 编辑状态与工具状态分发矩阵

| 编辑状态 (`EDIT_STATE`) | 工具状态 (`TOOLS_STATE`) | 鼠标操作 | 数据修改函数 |
|--------------------------|--------------------------|----------|-------------|
| `EDIT_STATE_MAZE` | `TS_SETBLOCK` | 左键拖拽 | [`SoundApp::SetBlockPoint()`](../SoundApp.h:134) |
| `EDIT_STATE_MAZE` | `TS_SETBLOCK2` | 左键拖拽 | [`SoundApp::SetBlockPoint()`](../SoundApp.h:134)（mask=0x08） |
| `EDIT_STATE_MAZE` | `TS_QIEZUO` | 左键拖拽 | [`SoundApp::SetRegion(x, y, RY_QIEZUO)`](../SoundApp.h:266) |
| `EDIT_STATE_MAZE` | `TS_BOSA` | 左键拖拽 | [`SoundApp::SetRegion(x, y, RY_BOSA)`](../SoundApp.h:266) |
| `EDIT_STATE_MAZE` | `TS_BAITAN` | 左键拖拽 | [`SoundApp::SetRegion(x, y, RY_BAITAN)`](../SoundApp.h:266) |
| `EDIT_STATE_MAZE` | `TS_SHUAGUAI` | 左键拖拽 | [`SoundApp::SetRegion(x, y, RY_SHUAGUAI)`](../SoundApp.h:266) |
| `EDIT_STATE_MAZE` | `TS_GAOJISHUGUAI` | 左键拖拽 | [`SoundApp::SetRegion(x, y, RY_GAOJISHUGUAI)`](../SoundApp.h:266) |
| `EDIT_STATE_MAZE` | `TS_QINHGONG1~4` | 左键拖拽 | [`SoundApp::SetJumpBlock()`](../SoundApp.h:301) |
| `EDIT_STATE_MAZE` | `TS_GUDAO` | 点击 | [`SoundApp::JumpToIsland()`](../SoundApp.h:161) |
| `EDIT_STATE_NPC` | `TS_SELECT` | 左键点击 | [`SoundApp::SelectNpc()`](../SoundApp.h:171) |
| `EDIT_STATE_NPC` | `TS_SELECT` | 左键拖拽 | [`SoundApp::MoveSelectNpc()`](../SoundApp.h:172) |
| `EDIT_STATE_NPC` | `TS_PUTNPC` | 左键点击 | [`SoundApp::PutNpc()`](../SoundApp.h:173) |
| `EDIT_STATE_MapJump` | `TS_SELECT` | 左键点击 | [`SoundApp::SelectJumpPointByPoint()`](../SoundApp.h:247) |
| `EDIT_STATE_TESTING` | — | 方向键 | [`Sprite::GoToRun()`](../Sprite.h:17) |

---

## 4. 核心函数调用链

### 4.1 地图加载流程

```
CSoundEditorView::OnFileOpen()
  │
  └─→ CMainDlg::LoadMap(mapName)
        │
        ├─→ CMainDlg::UnloadMap()
        │     └─→ SoundApp::Reset()
        │           ├─→ RemoveAllSprite()
        │           └─→ RemoveAllNpc()
        │
        ├─→ Nuclear::IWorld::LoadMap(mapname, mazename, &param, false)
        │     // 引擎加载地图资源
        │
        ├─→ SoundApp::ReadMazeBuffer(m_mazefilename)
        │     // 从 maze.dat 读取迷宫阻挡数据到 m_MazeBuffer[]
        │
        ├─→ SoundApp::ResetMapNpc(NpcXmlName)
        │     ├─→ SoundApp::GetXmlNodeList(path, fr, typenl)
        │     │     // XMLIO 解析 NPC XML
        │     └─→ 遍历 XML 节点:
        │           ├─→ new CNpc(Nuclear::ISprite)  // 创建 NPC 实例
        │           ├─→ CNpc::SetLocation()          // 设置位置
        │           ├─→ CNpc::SetDirection()         // 设置方向
        │           └─→ m_NpcList.push_back(npc)     // 加入列表
        │
        ├─→ SoundApp::LoadJumpPoint(gotoXmlName)
        │     ├─→ XMLIO 解析跳转点 XML
        │     └─→ 遍历节点:
        │           ├─→ m_vecJumpVector.push_back(jp)
        │           └─→ Nuclear::IEffect 创建特效
        │
        ├─→ SoundApp::ReadRegionBufferFromFile(...)
        │     └─→ CRegionBuffer::unmarshal()  // 反序列化区域类型
        │
        ├─→ SoundApp::LoadJumpBlockInf(m_JumpBlockFileName)
        │     └─→ 读取跳跃阻挡数据
        │
        └─→ SoundApp::ReadMonsterKind(m_MonsterFileName)
              └─→ 读取怪物分布数据
```

### 4.2 迷宫阻挡编辑流程（左键拖拽）

```
CMainDlg::OnMouseMove(UINT nFlags, CPoint point)
  │
  ├─→ Client2World(point, viewport, absPt)
  │     // 客户端坐标 → 世界坐标
  │
  └─→ switch(GetEditState())
        └─→ case EDIT_STATE_MAZE:
              │
              └─→ switch(m_toolState)
                    │
                    ├─→ case TS_SETBLOCK:
                    │     └─→ SoundApp::SetBlockPoint(absPt, bAllScreen, false, false/true)
                    │           └─→ SoundApp::SetMazeMask(mask, pixel, bAllScreen, brush)
                    │                 └─→ m_MazeBuffer[...] |= mask
                    │                       // 直接修改迷宫缓冲
                    │
                    ├─→ case TS_QIEZUO:
                    │     └─→ SoundApp::SetRegion(tmpPt.x, tmpPt.y, RY_QIEZUO)
                    │           └─→ CRegionBuffer::AddPoint(x, y, rt)
                    │                 └─→ m_buffer[key] |= regiontype
                    │
                    ├─→ case TS_QINHGONG1:
                    │     └─→ SoundApp::SetJumpBlock(pixel, brush, type)
                    │           └─→ m_JumpBlockBuffer[...] = type
                    │
                    └─→ ... (其他工具状态)
```

### 4.3 保存流程

```
CMainDlg::OnSavemaze()
  │
  ├─→ [1] SoundApp::WriteMazeBuffer(mazefilename)
  │       ├─→ SoundApp::CheckLonelyIsland()
  │       │     └─→ BFS 遍历 m_MazeBuffer 检测不可达区域
  │       ├─→ fstream::write(m_MazeBuffer, size)
  │       │     // 二进制写入 maze.dat
  │       └─→ Nuclear::IWorld::SetMapMaze()
  │             // 同步迷宫数据到引擎
  │
  ├─→ [2] SoundApp::WriteRegionBufferToFile(regiontypeinfo.dat)
  │       └─→ CRegionBuffer<unsigned short>::marshal()
  │             // 序列化: 'QUYU' + width + height + size + [key,val]...
  │
  ├─→ [3] SoundApp::SaveJumpBlockInf(JumpBlock.dat)
  │       └─→ CRegionBuffer::marshal()
  │
  ├─→ [4] SoundApp::SaveIslandInf(Island.dat, 1)
  │       ├─→ SoundApp::processBlockInfo(m_MazeBuffer, w, h)
  │       │     // BFS 孤岛检测核心算法
  │       │     ├─→ 遍历所有格子
  │       │     ├─→ processIsland() 标记连通区域
  │       │     └─→ 返回孤岛数量
  │       └─→ CRegionBuffer::SaveToNativePath()
  │
  ├─→ [5] SoundApp::SaveIslandInf(Island2.dat, 2)
  │       └─→ (同上，使用 2 层阻挡数据)
  │
  └─→ [6] SoundApp::SaveMonsterKind(monster.dat)
          └─→ Nuclear::XOStream 序列化 → FWrite
```

### 4.4 NPC 编辑流程

#### 4.4.1 选择 NPC

```
CMainDlg::OnLButtonDown() [EDIT_STATE_NPC, TS_SELECT]
  │
  ├─→ Client2World(point, viewport, absPt)
  │
  └─→ SoundApp::SelectNpc(absPt)
        │
        ├─→ 方式 1: Nuclear::IWorld::SelectObjs()
        │     // 引擎内置选择
        │
        ├─→ 方式 2: 遍历 m_NpcList 矩形碰撞检测
        │     // 备用选择逻辑
        │
        └─→ CNpcPropertyDlg::ChangeSelNpc(pNpc)
              └─→ 更新对话框控件显示:
                    BaseID, Model, Name, Pos(X/Y),
                    Type, Title, Chat(1/2/3), Dir
```

#### 4.4.2 修改 NPC 属性

```
CNpcPropertyDlg::OnBnClickedNpcOk()
  │
  ├─→ 从控件读取修改后的属性
  │     BaseID, Model, Name, Type, Title, Chat, Dir
  │
  └─→ 更新 stNpcBaseData 和 NPC 方向
        ├─→ CNpc::SetDirection()
        └─→ CNpc::SetName()
```

#### 4.4.3 保存 NPC

```
CNpcPropertyDlg::OnBnClickedNpcSave()
  │
  └─→ SoundApp::OnSaveNpcInf()
        │
        ├─→ XMLIO::CFileWriter 创建 XML 写入器
        │
        └─→ 遍历 m_NpcList:
              └─→ 写入每个 NPC 的属性到 XML 节点:
                    id, baseid, x, y, dir, name, ...
```

### 4.5 跳转点编辑流程

#### 4.5.1 添加跳转点

```
CJumpPointInfDlg::OnBnClickedAddjump()
  │
  └─→ SoundApp::AddNewJumpPoint()
        ├─→ SoundApp::GenerateNewJumpPointID()
        │     // 生成唯一跳转点 ID
        ├─→ 创建 stJumpPointInf 结构
        ├─→ Nuclear::IEffect 创建特效
        └─→ m_vecJumpVector.push_back(jp)
```

#### 4.5.2 修改跳转点信息

```
CJumpPointInfDlg::OnBnClickedJPInfOK()
  │
  └─→ SoundApp::ChangeEditJPInf(mapID, Dest_X, Dest_Y)
        └─→ 更新 m_vecJumpVector[editIdx] 的目标信息
```

#### 4.5.3 保存跳转点

```
CJumpPointInfDlg::OnBnClickedSavejpinf()
  │
  └─→ SoundApp::SaveJumpPointInf()
        │
        ├─→ XMLIO::CFileWriter 创建 XML 写入器
        │
        └─→ 遍历 m_vecJumpVector:
              └─→ 写入每个跳转点的属性:
                    id, dest_mapID, dest_X, dest_Y, ...
```

---

## 5. 引擎渲染循环

### 5.1 定时器驱动

```
CMainDlg::OnInitDialog()
  └─→ SetTimer(1000, 25, NULL)  // 25ms 间隔定时器

CMainDlg::OnTimer(1000)
  └─→ Nuclear::IEngine::OnIdle()
        │
        ├─→ SoundApp::OnBeforeRender(now)
        │     └─→ return true  // 继续渲染
        │
        ├─→ [Nuclear 引擎内部渲染]
        │     ├─→ 场景渲染
        │     ├─→ 精灵渲染
        │     └─→ 特效渲染
        │
        └─→ SoundApp::OnRenderUI(now)
              │
              ├─→ [1] 绘制网格线 (DrawLine)
              │     if (m_bDrawGird)
              │       遍历可视区域绘制水平/垂直网格线
              │
              ├─→ [2] 绘制阻挡区域 (DrawBox)
              │     if (m_bDrawBlock)
              │       遍历 m_MazeBuffer → 绿色/黄色半透明方块
              │
              ├─→ [3] 绘制区域类型
              │     遍历 m_RegionBuffer → 各区域颜色方块
              │
              ├─→ [4] 绘制跳跃阻挡
              │     遍历 m_JumpBlockBuffer → 飞跃阻挡颜色
              │
              ├─→ [5] 绘制 NPC 选择框 + 名字
              │     DrawSelectNpcBox()  // 选中 NPC 的高亮框
              │     DrawNpcName()       // NPC 头顶名字
              │
              ├─→ [6] 绘制跳转点标志
              │     DrawJumpPoint()     // 跳转点特效和标记
              │
              ├─→ [7] 绘制孤岛信息
              │     DrawGuDaoInf(layer) // 孤岛区域着色
              │
              └─→ [8] 绘制自由区域
                    DrawFreeArea(regionType) // 自由区域着色
```

### 5.2 消息转发

```
Windows 消息 → CMainDlg::WindowProc(message, wParam, lParam)
  │
  ├─→ Nuclear::IEngine::OnWindowsMessage(message, wParam, lParam)
  │     // 所有消息都转发给引擎处理
  │
  └─→ MFC 默认消息处理
        // 鼠标/键盘事件由 MFC 消息映射处理
```

---

## 6. 迷宫阻挡数据详解

### 6.1 阻挡缓冲结构

[`m_MazeBuffer`](../SoundApp.h:100) 是一维字节数组，索引计算方式：

```
索引 = gridY * m_mapGridWidth + gridX

其中:
  gridX = pixelX / GRID_WIDTH  (GRID_WIDTH = 24)
  gridY = pixelY / GRID_HEIGHT (GRID_HEIGHT = 16)
```

### 6.2 阻挡掩码位定义

| 位 | 掩码 | 含义 |
|-----|------|------|
| bit 0 | `0x01` | 1 层阻挡（基本阻挡） |
| bit 1 | `0x02` | 1 层阻挡（扩展） |
| bit 2 | `0x04` | 保留 |
| bit 3 | `0x08`（[`s_BlockLayer2Mask`](../SoundApp.h:72)） | 2 层阻挡 |

默认掩码 `0x03`（bit 0 + bit 1）用于 1 层阻挡编辑。

### 6.3 阻挡编辑操作

```
设置阻挡: m_MazeBuffer[idx] |= mask
清除阻挡: m_MazeBuffer[idx] &= ~mask
全屏设置: 遍历所有格子设置/清除
笔刷模式: 以点击位置为中心，edge 为半径设置
```

---

## 7. 区域类型数据详解

### 7.1 CRegionBuffer 存储原理

[`CRegionBuffer<unsigned short>`](../SoundApp.h:293) 使用稀疏存储，仅保存有值的格子：

```
Key 计算: key = (gridX << 16) | gridY
Value: unsigned short，支持位运算组合多种区域类型

添加区域: m_buffer[key] |= regionType
删除区域: m_buffer[key] &= ~regionType
检查区域: (m_buffer[key] & regionType) > 0
```

### 7.2 区域类型位组合示例

一个格子可以同时属于多种区域：

```
格子 A = RY_QIEZUO | RY_BAITAN = 0x01 | 0x04 = 0x05
  → 同时是切磋区和摆摊区

格子 B = RY_SHUAGUAI | RY_GAOJISHUGUAI = 0x10 | 0x40 = 0x50
  → 同时是刷怪区和高级刷怪区
```

---

## 8. 孤岛检测算法

### 8.1 BFS 孤岛检测流程

[`SoundApp::processBlockInfo()`](../SoundApp.h:308) 使用 BFS（广度优先搜索）检测不可达区域：

```
processBlockInfo(blockinfo, x_grid_num, y_grid_num)
  │
  ├─→ 初始化: 所有非阻挡格子标记为未访问
  │
  ├─→ 从地图起点开始 BFS:
  │     ├─→ getAdjacentPos() 获取相邻可通行格子
  │     ├─→ processAdjacentPoses() 处理相邻位置
  │     └─→ 标记已访问的格子
  │
  ├─→ 遍历所有格子:
  │     ├─→ 未访问的非阻挡格子 = 孤岛
  │     └─→ 分配孤岛索引
  │
  └─→ 返回孤岛数量
```

### 8.2 孤岛信息保存

```
SaveIslandInf(filename, layer)
  │
  ├─→ processBlockInfo()
  │     // 使用对应层的阻挡数据
  │     // layer=1: m_MazeBuffer (1 层阻挡)
  │     // layer=2: m_MazeBuffer + s_BlockLayer2Mask (2 层阻挡)
  │
  └─→ CRegionBuffer::SaveToNativePath()
        // 序列化孤岛信息到文件
```

---

## 9. 怪物分布数据详解

### 9.1 怪物点缓冲结构

[`m_Monbuffer`](../SoundApp.h:276) 使用 `std::map<unsigned int, int>` 存储：

```
Key: (gridX << 16) | gridY  // 与 CRegionBuffer 相同的编码方式
Value: 怪物种类 ID
```

### 9.2 怪物操作流程

```
添加怪物点:
  SoundApp::AddMonsterPoint(x, y)
    → m_Monbuffer[key] = monKind

删除怪物点:
  SoundApp::DelMonsterPoint(x, y)
    → m_Monbuffer.erase(key)

保存怪物数据:
  SoundApp::SaveMonsterKind(filename)
    → Nuclear::XOStream 序列化 → FWrite

读取怪物数据:
  SoundApp::ReadMonsterKind(filename)
    → Nuclear::XIStream 反序列化 → m_Monbuffer
```

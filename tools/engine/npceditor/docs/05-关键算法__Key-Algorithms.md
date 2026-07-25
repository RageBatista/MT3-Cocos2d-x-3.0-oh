# 05 - 关键算法 (Key Algorithms)

> NPC 编辑器（npceditor）核心算法详解。
> 所有算法描述与伪代码均基于源码静态分析，与实际实现保持一致。

---

## 目录

- [1. 迷宫阻挡缓冲编码算法](#1-迷宫阻挡缓冲编码算法)
- [2. 孤岛检测算法（BFS）](#2-孤岛检测算法bfs)
- [3. 区域缓冲稀疏存储算法](#3-区域缓冲稀疏存储算法)
- [4. 坐标转换算法](#4-坐标转换算法)
- [5. NPC 选择算法](#5-npc-选择算法)
- [6. 引擎渲染管线](#6-引擎渲染管线)

---

## 1. 迷宫阻挡缓冲编码算法

### 1.1 概述

迷宫阻挡数据使用一维字节数组 `m_MazeBuffer` 存储，每个网格占一个 `unsigned char`（1 字节）。网格尺寸由常量定义：

| 常量 | 值 | 定义位置 |
|------|-----|----------|
| `GRID_WIDTH` | 24 像素 | [`SoundApp.h:18`](../SoundApp.h:18) |
| `GRID_HEIGHT` | 16 像素 | [`SoundApp.h:19`](../SoundApp.h:19) |

### 1.2 字节位布局

每个字节的位分配如下：

```
  7   6   5   4   3   2   1   0
+---+---+---+---+---+---+---+---+
| 鼠标点击效果 |   | 2层|  1层阻挡  |
|  (高2位)    |   |阻挡|  (低2位)  |
+---+---+---+---+---+---+---+---+
```

| 位范围 | 掩码 | 含义 |
|--------|------|------|
| 低 2 位 (`bits 0-1`) | `0x03` | 1 层阻挡标记。`0x03` = 阻挡，`0x00` = 可通行 |
| 第 3 位 (`bit 3`) | `0x08` (`s_BlockLayer2Mask`) | 2 层阻挡标记 |
| 高 2 位 (`bits 6-7`) | `>> 6` | 鼠标点击效果：1=土(dust)，2=草(grass)，3=水(water) |

### 1.3 SetBlockPoint 算法

**入口**: [`SoundApp::SetBlockPoint()`](../SoundApp.cpp:824)

```
函数 SetBlockPoint(point, bAllScreen, tab, brush, mask=0x03):
    // 委托给 SetMazeMask
    SetMazeMask(mask, point, bAllScreen, brush)
```

### 1.4 SetMazeMask 算法

**实现**: [`SoundApp::SetMazeMask()`](../SoundApp.cpp:892)

```
函数 SetMazeMask(mask, pixel, bAllScreen, brush):
    if m_MazeBuffer 无效:
        return
    
    (x, y) = PixelToGrid(pixel)    // pixel.x / 24, pixel.y / 16
    
    if brush:                       // 笔刷模式
        if !bAllScreen:             // 局部笔刷
            for i in [-EdgeSize/2, EdgeSize/2):
                for j in [-EdgeSize/2, EdgeSize/2):
                    dx = x + i
                    dy = y + j
                    if IsValidGrid(dx, dy):
                        index = dx + dy * mapGridWidth
                        // 鼠标点击效果先清高2位
                        if mask == 0x01<<6 或 0x02<<6 或 0x03<<6:
                            m_MazeBuffer[index] &= 0x3F   // 清除高2位
                        m_MazeBuffer[index] |= mask        // 位或合并
        else:                       // 全屏刷
            SetAllMask(mask)         // 对所有格子 |= mask
    else:                           // 单格模式
        if !bAllScreen:
            if IsValidGrid(x, y):
                index = x + y * mapGridWidth
                if mask == 0x01<<6 或 0x02<<6 或 0x03<<6:
                    m_MazeBuffer[index] &= 0x3F
                m_MazeBuffer[index] |= mask
        else:
            SetAllMask(mask)
```

### 1.5 ClearMazeMask 算法

**实现**: [`SoundApp::ClearMazeMask()`](../SoundApp.cpp:951)

```
函数 ClearMazeMask(mask, pixel, bAllScreen):
    if !bAllScreen:
        (x, y) = PixelToGrid(pixel)
        m_MazeBuffer[x + y * mapGridWidth] &= ~mask   // 位与清除
    else:
        ClearAllMask(mask)    // 对所有格子 &= ~mask
```

**笔刷版重载**: [`SoundApp::ClearMazeMask(mask, center, edge, bAllScreen)`](../SoundApp.cpp:969)

```
函数 ClearMazeMask(mask, center, edge, bAllScreen):
    if !bAllScreen:
        center.x /= 24; center.y /= 16
        for i in [-edge/2, edge/2):
            for j in [-edge/2, edge/2):
                dx = center.x + i; dy = center.y + j
                if 边界检查通过:
                    m_MazeBuffer[dx + dy * mapGridWidth] &= ~mask
    else:
        ClearAllMask(mask)
```

### 1.6 二进制文件格式

**读取**: [`SoundApp::ReadMazeBuffer()`](../SoundApp.cpp:718)  
**写入**: [`SoundApp::WriteMazeBuffer()`](../SoundApp.cpp:766)

```
文件布局:
┌──────────────┬──────────────┬──────────────┬────────────────────────────┐
│ minsize      │ map_width    │ map_height   │ data[map_width × map_height]│
│ (int, 4字节) │ (size_t)     │ (size_t)     │ (unsigned char[])           │
└──────────────┴──────────────┴──────────────┴────────────────────────────┘

minsize = sizeof(int) + sizeof(size_t) + sizeof(size_t)  // 头部大小校验值
data[i] = m_MazeBuffer[i]  // 每字节一个网格
```

**写入流程**:
1. 检查 `m_MazeBuffer` 有效性
2. 调用 `CheckLonelyIsland()` 执行简单孤岛检测
3. 写入头部 + 数据
4. 回读文件并通过 `IWorld::SetMapMaze()` 更新引擎运行时阻挡

---

## 2. 孤岛检测算法（BFS）

### 2.1 概述

孤岛检测用于发现地图中被阻挡点完全包围的不可达区域。编辑器实现了两级检测：

1. **简单检测** (`CheckLonelyIsland`) — 检查单个非阻挡点周围 8 方向是否全为阻挡
2. **BFS 连通域检测** (`processBlockInfo`) — 通过广度优先搜索识别所有连通区域

### 2.2 简单孤岛检测

**实现**: [`SoundApp::CheckLonelyIsland()`](../SoundApp.cpp:845)

```
函数 CheckLonelyIsland() -> bool:
    for i in [0, mapGridWidth):
        for j in [0, mapGridHeight):
            // 检查非阻挡点（低2位不等于 0x03）
            if (m_MazeBuffer[i + j * mapGridWidth] & 0x03) != 0x03:
                bAllblock = true
                // 检查周围 8 个方向
                for a in [-1, 1]:
                    for b in [-1, 1]:
                        if a==0 && b==0: continue
                        x = i + a; y = j + b
                        if IsValidGrid(x, y):
                            if (m_MazeBuffer[x + y * mapGridWidth] & 0x03) != 0x03:
                                bAllblock = false   // 有相邻的非阻挡点
                if bAllblock:
                    // 该点被阻挡完全包围，标记为阻挡
                    m_MazeBuffer[i + j * mapGridWidth] |= 0x03
                    MessageBox("存在孤岛")
                    return false
    return true
```

### 2.3 BFS 连通域检测

**实现**: [`SoundApp::processBlockInfo()`](../SoundApp.cpp:2872)

这是核心的孤岛检测算法，使用迭代 BFS（非递归）遍历所有非阻挡点，为每个连通区域分配唯一编号。

```
函数 processBlockInfo(blockinfo, x_grid_num, y_grid_num) -> int:
    islandindex = 1
    
    for x in [0, x_grid_num):
        for y in [0, y_grid_num):
            // 跳过已标记或阻挡的点（值 != 0 表示已标记或阻挡）
            if blockinfo[x + y * x_grid_num] != 0:
                continue
            
            // 标记当前点为新的连通区域
            blockinfo[x + y * x_grid_num] = islandindex
            
            // BFS 迭代扩展
            poses = [(x, y)]              // 当前层待处理点
            outPoes = []                   // 下一层发现的点
            
            while poses 不为空:
                processAdjacentPoses(blockinfo, poses, outPoes, 
                                     x_grid_num, y_grid_num, islandindex)
                
                // 将输出作为下一轮输入
                poses = outPoes
                outPoes = []
            
            islandindex++                  // 下一个连通区域
    
    return islandindex - 1                // 连通区域总数
```

### 2.4 邻接点扩展

**实现**: [`SoundApp::processAdjacentPoses()`](../SoundApp.cpp:2976)

```
函数 processAdjacentPoses(blockinfo, inputVecPos, outVecPos, 
                           x_grid_num, y_grid_num, islandindex):
    for each pos in inputVecPos:
        // 获取周围最多 8 个邻接点
        adjVec = getAdjacentPos(pos.x, pos.y, x_grid_num, y_grid_num)
        
        for each adj in adjVec:
            // 跳过已标记或阻挡的点
            if blockinfo[adj.x + adj.y * x_grid_num] != 0:
                continue
            
            // 对角线合法性检查
            if !validPos(blockinfo, pos.x, pos.y, adj.x, adj.y, 
                         x_grid_num, y_grid_num):
                continue
            
            // 标记为当前连通区域
            blockinfo[adj.x + adj.y * x_grid_num] = islandindex
            outVecPos.push_back(adj)
```

### 2.5 对角线合法性检查

**实现**: [`SoundApp::validPos()`](../SoundApp.cpp:2941)

```
函数 validPos(blockinfo, x, y, tmpx, tmpy, x_grid_num, y_grid_num) -> bool:
    // 直线方向（上下左右）始终合法
    if x == tmpx 或 y == tmpy:
        return true
    
    // 对角线方向：检查是否穿越了两个阻挡点
    //  +--------+--------+
    //  | 阻挡   | 非     |
    //  | (x,ty) |(tmpx,ty)|
    //  +--------+--------+
    //  | 非     | 阻挡   |
    //  | (x,y)  |(tmpx,y) |
    //  +--------+--------+
    if blockinfo[x + tmpy * x_grid_num] == -1 
       AND blockinfo[tmpx + y * x_grid_num] == -1:
        return false    // 对角线穿越两个阻挡点，非法
    
    return true
```

**合法性图示**：

```
合法对角移动:              非法对角移动:
+--------+--------+       +--------+--------+
| 阻挡   | ✓目标  |       | 阻挡-1 | 阻挡-1 |
| (x,ty) |(tx,ty) |       | (x,ty) |(tx,ty) |
+--------+--------+       +--------+--------+
| ✓起点  | 可通行  |       | ✓起点  | ✓目标  |
| (x,y)  |(tx,y)  |       | (x,y)  |(tx,y)  |
+--------+--------+       +--------+--------+
  一侧有阻挡可通过          两侧都有阻挡不可通过对角穿越
```

### 2.6 获取邻接点

**实现**: [`SoundApp::getAdjacentPos()`](../SoundApp.cpp:2957)

```
函数 getAdjacentPos(vecPos, x, y, maxx, maxy):
    vecPos.clear()
    for i in [x-1, x+1]:
        for j in [y-1, y+1]:
            if i >= 0 && i < maxx && j >= 0 && j < maxy:
                if i == x && j == y: continue   // 跳过自身
                vecPos.push_back(Location(i, j))
    // 最多返回 8 个邻接点
```

### 2.7 SaveIslandInf 流程

**实现**: [`SoundApp::SaveIslandInf()`](../SoundApp.cpp:2779)

```
函数 SaveIslandInf(islandInfFilename, layer):
    x_gridNum = mapGridWidth
    y_gridNum = mapGridHeight
    
    // 1. 根据层号选择阻挡掩码
    if layer == 1:
        checkMask = 0x03        // 1层阻挡：低2位
        buffer = m_IslandBuffer
    else if layer == 2:
        checkMask = 0x08        // 2层阻挡：第3位
        buffer = m_IslandBuffer2
    
    // 2. 构建阻挡信息数组
    for x in [0, x_gridNum):
        for y in [0, y_gridNum):
            mask = m_MazeBuffer[x + y * mapGridWidth]
            if mask & checkMask:
                buffer[x + y * x_gridNum] = -1   // 阻挡
            else:
                buffer[x + y * x_gridNum] = 0     // 可通行
    
    // 3. 执行 BFS 孤岛检测
    isLandNum = processBlockInfo(buffer, x_gridNum, y_gridNum)
    
    // 4. 将结果写入 CRegionBuffer 并序列化
    islandBuffer = CRegionBuffer<char>
    for x1 in [0, x_gridNum):
        for y1 in [0, y_gridNum):
            if buffer[x1 + y1 * x_gridNum] > 0:
                islandBuffer.AddPoint(x1, y1, buffer[x1 + y1 * x_gridNum])
    
    islandBuffer.SaveToNativePath(islandInfFilename)
```

---

## 3. 区域缓冲稀疏存储算法

### 3.1 概述

**定义**: [`CRegionBuffer<T>`](../regionbuffer.h:7)

区域缓冲使用稀疏存储方案，仅保存有数据的网格点。使用 `std::map<unsigned int, T>` 作为底层容器，通过位运算编码坐标为 Key。

### 3.2 Key 编码算法

```
Key = (x << 16) | y

约束: x <= 65535 && y <= 65535
支持网格范围: 65535 × 65535
```

**解码**：
```
x = key >> 16
y = key & 0xFFFF
```

### 3.3 AddPoint 算法（位或合并）

**实现**: [`regionbuffer.h:31`](../regionbuffer.h:31)

```
函数 AddPoint(w, h, regiontype):
    assert(w <= 65535 && h <= 65535)
    key = (w << 16) | h
    
    if m_buffer 中已存在 key:
        val = m_buffer[key]
        val |= regiontype            // 位或合并
        m_buffer[key] = val
    else:
        m_buffer[key] |= regiontype  // 新增条目
```

**特点**：同一网格可以同时属于多种区域类型。例如一个格子可以同时是"切磋"和"刷怪"区域。

### 3.4 DelPoint 算法（位与清除）

**实现**: [`regionbuffer.h:49`](../regionbuffer.h:49)

```
函数 DelPoint(w, h, regiontype):
    assert(w <= 65535 && h <= 65535)
    key = (w << 16) | h
    
    if m_buffer 中已存在 key:
        val = m_buffer[key]
        val &= ~regiontype           // 位与清除指定位
        m_buffer[key] = val
```

**注意**：清除后即使值为 0，条目仍保留在 map 中（不删除条目）。

### 3.5 CheckPointType 算法

**实现**: [`regionbuffer.h:64`](../regionbuffer.h:64)

```
函数 CheckPointType(w, h, regiontype) -> bool:
    key = (w << 16) | h
    if m_buffer 中不存在 key:
        return false
    val = m_buffer[key]
    return (val & regiontype) > 0
```

### 3.6 序列化格式

**写入**: [`regionbuffer.h:91`](../regionbuffer.h:91) (`marshal`)  
**读取**: [`regionbuffer.h:111`](../regionbuffer.h:111) (`unmarshal`)

```
文件布局:
┌──────────────────────────────────────────────────────────────┐
│ 文件头 (4字节): 'Q' 'U' 'Y' 'U'                              │
├──────────────────────────────────────────────────────────────┤
│ m_Width  (unsigned int, 4字节)                                │
│ m_Height (unsigned int, 4字节)                                │
│ count    (int, 4字节) — 条目数量                               │
├──────────────────────────────────────────────────────────────┤
│ [key_0 (unsigned int)] [value_0 (T)]                          │
│ [key_1 (unsigned int)] [value_1 (T)]                          │
│ ...                                                           │
│ [key_{count-1}] [value_{count-1}]                             │
└──────────────────────────────────────────────────────────────┘
```

**读取流程**:
1. 读取 4 字节文件头，校验是否为 `'QUYU'`
2. 校验失败则抛出 `Exception`
3. 清空 `m_buffer`
4. 读取 `m_Width`、`m_Height`
5. 读取 `count`（条目数量）
6. 循环读取 `count` 个 `(key, value)` 对，填入 `m_buffer`

**写入流程**:
1. 写入 `'QUYU'` 文件头
2. 写入 `m_Width`、`m_Height`
3. 写入 `m_buffer.size()`（条目数量）
4. 遍历 `m_buffer`，依次写入每个 `(key, value)` 对

### 3.7 实例化类型

在 NPC 编辑器中，`CRegionBuffer` 被实例化为以下类型：

| 实例 | 模板参数 T | 用途 |
|------|-----------|------|
| `m_RegionBuffer` | `unsigned short` | 区域类型缓冲（支持 `RegionType` 位掩码组合） |
| `islandBuffer`（局部变量） | `char` | 孤岛信息缓冲 |
| `jumpblockBuffer`（局部变量） | `unsigned char` | 跳跃阻挡缓冲 |

---

## 4. 坐标转换算法

### 4.1 坐标体系概述

NPC 编辑器涉及三层坐标体系：

| 坐标类型 | 说明 | 范围 |
|----------|------|------|
| 屏幕坐标 | 窗口客户区内的像素坐标 | (0, 0) ~ (1024, 768) |
| 世界像素坐标 | 地图内的绝对像素坐标 | (0, 0) ~ (mapWidth, mapHeight) |
| 网格坐标 | 以 GRID_WIDTH × GRID_HEIGHT 为单位的网格索引 | (0, 0) ~ (gridWidth, gridHeight) |
| 逻辑坐标 | 游戏逻辑使用的坐标（通过 `WorldLogicCoord` 转换） | 与世界像素坐标有固定换算关系 |

### 4.2 屏幕坐标 → 世界坐标

**实现**: [`CMainDlg::Client2World()`](../MainDlg.h:94)

```
函数 Client2World(clientpt, vp, worldpt):
    worldpt.x = clientpt.x + vp.left
    worldpt.y = clientpt.y + vp.top
```

**说明**：`vp` 是当前视口矩形（`Nuclear::CRECT`），`vp.left/top` 是视口左上角在世界坐标中的偏移。

### 4.3 世界坐标 → 屏幕坐标

**实现**: [`CMainDlg::World2Client()`](../MainDlg.h:99)

```
函数 World2Client(worldpt, vp, clientpt):
    clientpt.x = worldpt.x - vp.left
    clientpt.y = worldpt.y - vp.top
```

### 4.4 像素坐标 → 网格坐标

**实现**: [`PixelPointToGridPoint()`](../MainDlg.h:11) 和 [`SoundApp::PixelToGrid()`](../SoundApp.cpp:131)

```
函数 PixelPointToGridPoint(pt) -> CPoint:
    return CPoint(pt.x / GRID_WIDTH, pt.y / GRID_HEIGHT)
    // 即 CPoint(pt.x / 24, pt.y / 16)

函数 PixelToGrid(pixel, x, y) -> bool:
    if pixel.x < 0 || pixel.y < 0:
        x = -1; y = -1; return false
    x = pixel.x / GRID_WIDTH
    y = pixel.y / GRID_HEIGHT
    return IsValidGrid(x, y)
```

**网格索引计算**：[`SoundApp::GetGridIndex()`](../SoundApp.cpp:144)

```
函数 GetGridIndex(x, y) -> size_t:
    return x + y * m_mapGridWidth
```

### 4.5 世界像素坐标 ↔ 逻辑坐标

通过 `Nuclear::WorldLogicCoord` 静态方法实现：

```
// 世界像素 → 逻辑
Nuclear::Location logicLoc = Nuclear::WorldLogicCoord::world2logic(worldX, worldY)

// 逻辑 → 世界像素
Nuclear::Location worldLoc = Nuclear::WorldLogicCoord::logic2world(logicX, logicY)
```

**使用场景**：
- NPC 保存时：世界像素坐标 → 逻辑坐标写入 XML（[`SoundApp::OnSaveNpcInf()`](../SoundApp.cpp:1714)）
- NPC 加载时：逻辑坐标 → 世界像素坐标设置位置（[`SoundApp::ResetMapNpc()`](../SoundApp.cpp:1161)）
- NPC 移动时：世界像素坐标 → 逻辑坐标更新面板显示（[`SoundApp::MoveSelectNpc()`](../SoundApp.cpp:1418)）

### 4.6 坐标对齐

**实现**: [`SoundApp::FixPoint()`](../SoundApp.cpp:2428)

```
函数 FixPoint(pt) -> CPoint:
    newPt.x = (pt.x / 24) * 24
    newPt.y = (pt.y / 16) * 16
    return newPt
```

**用途**：将坐标对齐到网格边界，用于跳转点放置。

---

## 5. NPC 选择算法

### 5.1 概述

**实现**: [`SoundApp::SelectNpc()`](../SoundApp.cpp:1312)

NPC 选择采用两阶段策略：
1. **精确选择** — 利用引擎的 `IWorld::SelectObjs()` 基于精灵像素级碰撞检测
2. **矩形碰撞回退** — 精确选择失败时，使用固定大小的矩形包围盒进行点测试

### 5.2 算法流程

```
函数 SelectNpc(pt) -> bool:
    // 0. 懒加载 NPC 属性对话框指针
    if m_pNpcDlg == NULL:
        m_pNpcDlg = 从主框架获取属性面板中的 NPC 属性对话框
    
    // 1. 前置检查
    if m_pEngine == NULL: return false
    pWorld = m_pEngine->GetWorld()
    if pWorld == NULL: return false
    
    // 2. 检查当前选中 NPC 是否在阻挡位置上
    if m_pCurSelNpc != NULL:
        npcloc = m_pCurSelNpc->GetLocation()
        mask = GetMazeMask(npcloc)
        if (mask & 0x03) != 0x00:
            return false    // 当前 NPC 在阻挡上，拒绝切换
    
    // 3. 阶段一：精确选择
    objs = []
    loc = Location(pt.x, pt.y)
    pWorld->SelectObjs(loc, objs)       // 引擎级精灵选择
    
    if objs.size() > 0:
        // 在 NPC 列表中匹配引擎选中的精灵
        for it in m_NpcList:
            if it->m_pSprite == objs.front():
                if it != m_pCurSelNpc:
                    m_pCurSelNpc = it       // 选中新 NPC
                else:
                    m_pCurSelNpc = NULL     // 取消选中（再次点击同一NPC）
        // 注意：如果精灵不在 NPC 列表中，不改变选中状态
    
    // 4. 阶段二：矩形碰撞回退
    else:
        for itNpc in m_NpcList:
            npcLoc = itNpc->GetLocation()
            
            // 构造 60×120 像素的碰撞矩形（屏幕坐标）
            rect.top    = (npcLoc.y - vp.top) - 120.0f
            rect.left   = (npcLoc.x - vp.left) - 30.0f
            rect.right  = rect.left + 60.0f
            rect.bottom = rect.top + 120.0f
            
            if rect.PtInRect(pt):         // 点在矩形内
                m_pCurSelNpc = itNpc
                break
        
        if 遍历完未找到:
            m_pCurSelNpc = NULL           // 点在空白处
    
    // 5. 更新属性面板
    if m_pCurSelNpc != NULL:
        m_pNpcDlg->ChangeSelNpc(m_pCurSelNpc)
        return true
    return false
```

### 5.3 碰撞矩形示意

```
              ← 30px →←— 60px —→← 30px →
              ┌─────────────────────────┐ ↑
              │                         │ │
              │       NPC 精灵区域       │ 120px
              │    (以脚底为原点)        │ │
              │                         │ ↓
              └─────────────────────────┘
                       ↑
                  NPC Location
                  (脚底坐标)
```

- 碰撞矩形宽 60 像素，以 NPC Location 为中心水平偏移 -30
- 碰撞矩形高 120 像素，从 NPC Location 向上延伸 120 像素

---

## 6. 引擎渲染管线

### 6.1 驱动方式

渲染由 25ms 定时器驱动：

```
定时器 (25ms)
    └── CMainDlg::OnTimer()
        └── m_pEngine->OnIdle()
            ├── OnBeforeRender(now)     // SoundApp 实现，返回 true
            ├── 引擎内部渲染
            │   ├── 渲染地图
            │   ├── 渲染精灵
            │   └── 渲染特效
            └── OnRenderUI(now)         // SoundApp 实现
```

**定时器创建**: [`CMainDlg::OnInitDialog()`](../MainDlg.cpp:83) — `SetTimer(1000, 25, NULL)`

### 6.2 OnRenderUI 绘制顺序

**实现**: [`SoundApp::OnRenderUI()`](../SoundApp.cpp:338)

```
函数 OnRenderUI(now):
    if m_pDoc == NULL: return
    
    pRenderer = m_pEngine->GetRenderer()
    vp = m_pEngine->GetWorld()->GetViewport()
    
    // ===== 第 1 步：绘制网格线 =====
    if m_bDrawGird:
        // 竖线：绿色 0x3F00FF00
        for x in [0, col]:
            DrawLine(x * 24 - addX, 0, x * 24 - addX, 768, 绿色)
        // 横线：蓝色 0x3F0000FF
        for y in [0, row]:
            DrawLine(0, y * 16 - addY, 1024, y * 16 - addY, 蓝色)
    
    // ===== 第 2 步：绘制阻挡区域 =====
    if m_bDrawBlock:
        // 2a. 基础阻挡（1层/2层）
        if m_regionType 不是 土/草/水:
            for 可见网格 (x, y):
                mask = GetMazeMask(CPoint(x*24, y*16))
                if m_regionType == 24 或 25:      // 2层阻挡
                    if mask & 0x08:
                        添加到 BlockRectList
                else:                              // 1层阻挡
                    if (mask & 0x03) == 0x03:
                        添加到 BlockRectList
            DrawBlock(BlockRectList, 黄色/浅绿色)
        
        // 2b. 根据工具类型绘制区域
        switch m_regionType:
            case 4 (切磋):     绘制 RY_QIEZUO 区域 (红色 0x3FFF0000)
            case 5 (播撒):     绘制 RY_BOSA 区域 (黄色 0x3FFFFF00)
            case 6 (摆摊):     绘制 RY_BAITAN 区域 (紫色 0x3FFF00FF)
            case 7/8/9 (土/草/水): 按高2位分类绘制 (黄/绿/蓝)
            case 10 (风筝):    绘制 RY_KITE 区域 (青色 0x3F00FFFF)
            case 11 (刷怪):    绘制 RY_SHUAGUAI 区域 + 怪物ID文字
            case 12 (名胜):    绘制 RY_MINGSHENG 区域 (红色)
            case 13-16 (飞跃): DrawJumpBlockRect()
            case 17 (孤岛1层): DrawGuDaoInf(1)
            case 18-23 (自由区域): DrawFreeArea(m_regionType)
            case 25 (孤岛2层): DrawGuDaoInf(2)
            case 26 (高级刷怪): 绘制 RY_GAOJISHUGUAI 区域 (绿色 0x3F00FF88)
    
    // ===== 第 3 步：绘制 NPC 选择框 + 名字 =====
    if m_editState == EDIT_STATE_NPC:
        DrawSelectNpcBox()    // 编辑NPC的红色选择框 (60×120)
        DrawNpcName()         // 所有NPC名字（黄色文字+阴影）
    
    // ===== 第 4 步：绘制跳转点标志 =====
    if m_editState == EDIT_STATE_MapJump:
        DrawJumpPoint()       // 所有跳转点的 5×5 网格矩形
                              // 普通黄色 0xCCFFFF00
                              // 编辑中天蓝色 0xCC87CEEB
```

### 6.3 绘制性能特征

| 特征 | 说明 |
|------|------|
| **视口裁剪** | 只绘制视口范围内的网格（`vp.left/GRID_WIDTH` ~ `vp.right/GRID_WIDTH`） |
| **批量绘制** | 阻挡矩形收集到 `std::vector<FRECT>` 后一次性调用 `DrawBox()` |
| **定时器频率** | 25ms 间隔 ≈ 40 FPS |
| **窗口尺寸** | 固定 1024×768 |
| **网格密度** | 每屏约 42×48 = 2016 个网格 |

### 6.4 视口拖拽机制

```
右键按下:
    记录 m_oldMousePoint (世界坐标)
    记录 m_oldViewportPos (视口位置)

鼠标移动(右键按下 或 左键+移动工具):
    计算世界坐标差值 dx, dy
    MoveViewPort(dx, dy)    // m_pWorld->SetViewportLT(old + dx, old + dy)
    m_pEngine->OnIdle()     // 立即刷新渲染
```

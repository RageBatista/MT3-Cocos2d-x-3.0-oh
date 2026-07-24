---
name: performance-optimization
version: 1.2.0
priority: medium
category: common
description: |
  MT3项目性能优化技能。涵盖CPU优化、内存优化、渲染优化和网络优化技术。
  触发词: 性能, 优化, CPU, 内存, 渲染, 帧率, FPS, 缓存, 批处理, 内存池, 对象池, DrawCall, 纹理, 帧时间, hotspot
allowed-tools:
  - Bash
  - Read
  - Edit
---

# 性能优化系统指南 (MT3 项目)

**版本**: v1.2.0
**最后更新**: 2026-04-11

---

## 🎯 性能优化方法论

### 优化原则 (优先级排序)

```yaml
1. 测量优先 (Measure First):
   - 使用工具识别真正的瓶颈
   - 不要凭直觉优化
   - 建立性能基准

2. 影响最大化 (Impact Maximization):
   - 优先优化热点路径 (Hot Path)
   - 20% 的代码占 80% 的执行时间
   - 关注用户感知的性能

3. 可维护性平衡 (Maintainability Balance):
   - 不要过度优化
   - 保持代码可读性
   - 权衡开发成本和性能收益

4. 平台特性利用 (Platform Optimization):
   - 利用硬件特性 (SIMD, 多核, 缓存)
   - 使用平台优化的库和 API
   - 考虑移动设备的电量消耗
```

### 优化流程

```
1. 建立基准 → 2. 性能分析 → 3. 识别瓶颈 → 4. 制定方案
                                                ↓
5. 实施优化 ← 6. 验证效果 ← 7. 代码审查 ← 8. 发布上线
     ↓
达到目标? (否) → 返回性能分析
达到目标? (是) → 完成
```

---

## 🔍 性能分析工具

### 客户端 (C++ / Windows)

#### Visual Studio Profiler

```bash
# 1. 启用性能分析
# Visual Studio → Debug → Performance Profiler (Alt+F2)

# 2. 选择分析类型
- CPU Usage: CPU 热点分析
- Memory Usage: 内存分配和泄漏
- GPU Usage: 渲染性能分析

# 3. 运行游戏并收集数据

# 4. 分析报告
- Hot Path: 查看最耗时的函数
- Call Tree: 查看调用关系
- Caller/Callee: 查看函数的调用者和被调用者
```

#### Very Sleepy (免费第三方工具)

```bash
# 1. 下载 Very Sleepy (C++ Profiler)
# http://www.codersnotes.com/sleepy/

# 2. 启动游戏
# 3. 附加到进程 MT3.exe
# 4. 运行 30-60 秒采样
# 5. 查看函数耗时排行

# 优点: 轻量级, 免费, 易用
# 缺点: 功能相对简单
```

### 客户端 (Lua 脚本)

#### Lua Profiler (自定义工具)

```lua
-- profiler.lua
local Profiler = {}
local startTime = {}
local totalTime = {}
local callCount = {}

function Profiler.start(name)
    startTime[name] = os.clock()
end

function Profiler.stop(name)
    if not startTime[name] then return end

    local elapsed = os.clock() - startTime[name]
    totalTime[name] = (totalTime[name] or 0) + elapsed
    callCount[name] = (callCount[name] or 0) + 1

    startTime[name] = nil
end

function Profiler.report()
    print("\n=== Lua Profiler Report ===")
    local results = {}
    for name, time in pairs(totalTime) do
        table.insert(results, {
            name = name,
            time = time,
            count = callCount[name],
            avg = time / callCount[name]
        })
    end

    table.sort(results, function(a, b) return a.time > b.time end)

    for i, v in ipairs(results) do
        print(string.format("%2d. %30s: %8.3fms (%5d calls, avg %6.3fms)",
            i, v.name, v.time * 1000, v.count, v.avg * 1000))
    end
end

return Profiler
```

**使用示例**:

```lua
local Profiler = require("profiler")

function onUpdate(dt)
    Profiler.start("update_enemies")
    updateEnemies(dt)
    Profiler.stop("update_enemies")

    Profiler.start("update_player")
    updatePlayer(dt)
    Profiler.stop("update_player")
end

-- 在退出时输出报告
function onExit()
    Profiler.report()
end
```

### 服务器端 (Java)

#### JProfiler / YourKit

```bash
# 1. 启动 JProfiler
java -agentpath:/path/to/jprofiler/bin/linux-x64/libjprofilerti.so=port=8849 \
     -jar game_server.jar

# 2. 连接到 JProfiler GUI
# 选择 "Attach to running JVM"

# 3. 分析类型
- CPU Views: 方法热点分析
- Memory Views: 堆内存分析，查找内存泄漏
- Threads: 线程状态和死锁检测
- Monitors: 锁竞争分析
```

#### JVisualVM (免费, JDK 自带)

```bash
# 1. 启动游戏服务器
java -jar game_server.jar

# 2. 启动 JVisualVM
jvisualvm

# 3. 附加到进程
# 选择 game_server 进程

# 4. 分析
- Monitor: 实时 CPU/内存/线程监控
- Sampler: CPU 和内存采样
- Profiler: 详细性能分析
```

---

## ⚡ CPU 优化

### 1. 热点函数优化

**识别热点**:

```cpp
// 错误: 频繁调用低效函数
for (int i = 0; i < 10000; i++) {
    std::string str = "Player_" + std::to_string(i);  // 每次都分配
    processName(str);
}
```

**优化方案**:

```cpp
// 正确: 重用缓冲区
std::string buffer;
buffer.reserve(32);  // 预分配

for (int i = 0; i < 10000; i++) {
    buffer.clear();
    buffer = "Player_";
    buffer += std::to_string(i);
    processName(buffer);
}

// 更好: 使用格式化字符串
char buffer[32];
for (int i = 0; i < 10000; i++) {
    snprintf(buffer, sizeof(buffer), "Player_%d", i);
    processName(buffer);
}
```

### 2. 缓存优化 (Cache-Friendly Code)

**错误: 缓存不友好**:

```cpp
struct Enemy {
    int id;              // 4 bytes
    char padding[60];    // 60 bytes padding
    Vector2 position;    // 8 bytes
    int health;          // 4 bytes
};  // Total: 76 bytes

// 遍历 1000 个敌人，缓存命中率低
for (int i = 0; i < 1000; i++) {
    enemies[i].position.x += enemies[i].velocity.x * dt;
}
```

**优化: 数据结构重排 (SoA - Structure of Arrays)**:

```cpp
struct EnemyManager {
    std::vector<Vector2> positions;    // 连续存储
    std::vector<Vector2> velocities;   // 连续存储
    std::vector<int> healths;          // 连续存储
};

// 缓存命中率高，SIMD 友好
for (int i = 0; i < 1000; i++) {
    positions[i].x += velocities[i].x * dt;
    positions[i].y += velocities[i].y * dt;
}
```

### 3. 分支预测优化

**错误: 分支不可预测**:

```cpp
for (int i = 0; i < 1000; i++) {
    if (enemies[i].health > 0) {  // 随机分布
        updateEnemy(enemies[i]);
    }
}
```

**优化: 减少分支**:

```cpp
// 方案1: 重排数据，将活跃敌人放在前面
int aliveCount = 0;
for (int i = 0; i < totalCount; i++) {
    if (enemies[i].health > 0) {
        enemies[aliveCount++] = enemies[i];
    }
}

// 无分支遍历
for (int i = 0; i < aliveCount; i++) {
    updateEnemy(enemies[i]);
}

// 方案2: 使用无分支技巧 (Branchless)
for (int i = 0; i < 1000; i++) {
    int mask = (enemies[i].health > 0) ? -1 : 0;  // 编译器优化为 cmov
    updateEnemy(enemies[i], mask);
}
```

### 4. 循环优化

```cpp
// 错误: 循环中重复计算
for (int i = 0; i < enemyCount; i++) {
    float dist = sqrt(pow(enemy[i].x - player.x, 2) +
                      pow(enemy[i].y - player.y, 2));
    if (dist < 100) {
        attack(enemy[i]);
    }
}

// 优化: 避免平方根
float threshold = 100 * 100;  // 提前计算
for (int i = 0; i < enemyCount; i++) {
    float dx = enemy[i].x - player.x;
    float dy = enemy[i].y - player.y;
    float distSq = dx * dx + dy * dy;  // 无需 sqrt
    if (distSq < threshold) {
        attack(enemy[i]);
    }
}
```

---

## 💾 内存优化

### 1. 对象池 (Object Pool)

```cpp
// object_pool.h
template<typename T>
class ObjectPool {
public:
    ObjectPool(size_t initialSize = 64) {
        m_pool.reserve(initialSize);
        for (size_t i = 0; i < initialSize; i++) {
            m_pool.push_back(new T());
        }
    }

    ~ObjectPool() {
        for (T* obj : m_pool) delete obj;
        for (T* obj : m_inUse) delete obj;
    }

    T* acquire() {
        if (m_pool.empty()) {
            return new T();  // 扩容
        }
        T* obj = m_pool.back();
        m_pool.pop_back();
        m_inUse.insert(obj);
        return obj;
    }

    void release(T* obj) {
        m_inUse.erase(obj);
        obj->reset();  // 重置状态
        m_pool.push_back(obj);
    }

private:
    std::vector<T*> m_pool;
    std::unordered_set<T*> m_inUse;
};
```

**使用示例**:

```cpp
ObjectPool<Bullet> bulletPool(100);

// 发射子弹
Bullet* bullet = bulletPool.acquire();
bullet->init(position, direction);

// 子弹销毁
bulletPool.release(bullet);
```

### 2. 智能指针使用原则

```cpp
// ❌ 错误: 过度使用 shared_ptr
class GameScene {
    std::vector<std::shared_ptr<Enemy>> enemies;  // 引用计数开销
};

// ✅ 正确: 根据所有权选择
class GameScene {
    std::vector<std::unique_ptr<Enemy>> enemies;  // 独占所有权, 无开销

    // 仅在需要共享时使用 shared_ptr
    std::shared_ptr<Texture> sharedTexture;
};

// ✅ 正确: 使用裸指针用于观察者模式
class Enemy {
    GameScene* scene;  // 不拥有所有权, 使用裸指针
};
```

### 3. 内存对齐

```cpp
// 错误: 未对齐 (缓存行污染)
struct ParticleData {
    float x, y, z;        // 12 bytes
    float vx, vy, vz;     // 12 bytes
    int alive;            // 4 bytes
};  // Total: 28 bytes (不对齐)

// 优化: 对齐到 32 字节
struct alignas(32) ParticleData {
    float x, y, z;        // 12 bytes
    float vx, vy, vz;     // 12 bytes
    int alive;            // 4 bytes
    int padding;          // 4 bytes padding
};  // Total: 32 bytes (对齐)
```

### 4. 内存池 (Memory Pool)

```cpp
class MemoryPool {
public:
    MemoryPool(size_t blockSize, size_t blockCount)
        : m_blockSize(blockSize) {
        m_memory = malloc(blockSize * blockCount);

        // 初始化空闲链表
        char* ptr = (char*)m_memory;
        for (size_t i = 0; i < blockCount - 1; i++) {
            *(void**)ptr = ptr + blockSize;
            ptr += blockSize;
        }
        *(void**)ptr = nullptr;
        m_freeList = m_memory;
    }

    void* allocate() {
        if (!m_freeList) return nullptr;

        void* ptr = m_freeList;
        m_freeList = *(void**)m_freeList;
        return ptr;
    }

    void deallocate(void* ptr) {
        *(void**)ptr = m_freeList;
        m_freeList = ptr;
    }

private:
    void* m_memory;
    void* m_freeList;
    size_t m_blockSize;
};
```

---

## 🎨 渲染优化

### 1. 批次渲染 (Batch Rendering)

```cpp
// 错误: 每个精灵单独绘制
for (auto& sprite : sprites) {
    renderer->drawSprite(sprite);  // 1000 次 draw call
}

// 优化: 批次渲染
SpriteBatch batch;
batch.begin();
for (auto& sprite : sprites) {
    batch.add(sprite);  // 添加到批次
}
batch.end();  // 一次性提交, 只有 1-2 次 draw call
```

**Cocos2d-x 实现**:

```cpp
// 使用 CCSpriteBatchNode
CCSpriteBatchNode* batchNode = CCSpriteBatchNode::create("sprites.png");
addChild(batchNode);

for (int i = 0; i < 1000; i++) {
    CCSprite* sprite = CCSprite::createWithTexture(batchNode->getTexture());
    batchNode->addChild(sprite);  // 自动批次渲染
}
```

### 2. 纹理优化

```cpp
// 1. 纹理图集 (Texture Atlas)
// 将多个小纹理合并为一张大纹理, 减少纹理切换

// 2. 纹理压缩
// - Android: ETC1/ETC2
// - iOS: PVRTC
// - Windows: DXT1/DXT5

// 3. Mipmap 生成
glGenerateMipmap(GL_TEXTURE_2D);  // 自动生成各级 mipmap

// 4. 纹理缓存管理
CCTextureCache::sharedTextureCache()->removeUnusedTextures();
```

### 3. 遮挡剔除 (Occlusion Culling)

```cpp
class Renderer {
    void render(Camera& camera) {
        Frustum frustum = camera.getFrustum();

        for (auto& obj : objects) {
            // 视锥体剔除
            if (!frustum.intersects(obj.getBounds())) {
                continue;  // 不在视野内, 跳过渲染
            }

            // 距离剔除
            float dist = (obj.position - camera.position).length();
            if (dist > maxRenderDistance) {
                continue;
            }

            obj.render();
        }
    }
};
```

### 4. LOD (Level of Detail)

```cpp
enum LODLevel {
    LOD_HIGH = 0,    // < 50m, 高模 (5000 triangles)
    LOD_MEDIUM = 1,  // 50-100m, 中模 (2000 triangles)
    LOD_LOW = 2,     // 100-200m, 低模 (500 triangles)
    LOD_BILLBOARD = 3 // > 200m, 广告牌 (2 triangles)
};

LODLevel selectLOD(float distance) {
    if (distance < 50) return LOD_HIGH;
    if (distance < 100) return LOD_MEDIUM;
    if (distance < 200) return LOD_LOW;
    return LOD_BILLBOARD;
}
```

---

## 🌐 网络优化

### 1. 协议压缩

```java
// 错误: 发送未压缩的 JSON
String json = toJson(gameState);  // 10KB
socket.send(json);

// 优化: 使用二进制协议 + 压缩
byte[] data = serializeToBinary(gameState);  // 2KB
byte[] compressed = gzip(data);  // 0.5KB
socket.send(compressed);
```

### 2. 批量发送 (Batching)

```java
// 错误: 每个操作单独发送
for (Player player : players) {
    sendUpdatePacket(player);  // 100 次网络调用
}

// 优化: 批量发送
List<PlayerUpdate> updates = new ArrayList<>();
for (Player player : players) {
    updates.add(player.getUpdate());
}
sendBatchPacket(updates);  // 1 次网络调用
```

### 3. 连接池

```java
// gnet 框架连接池配置
public class ConnectionPool {
    private int minIdle = 10;
    private int maxActive = 100;
    private int maxWait = 5000;  // ms

    public Connection getConnection() {
        // 从池中获取连接
        if (idleConnections.isEmpty()) {
            if (activeCount < maxActive) {
                return createConnection();
            } else {
                return waitForConnection(maxWait);
            }
        }
        return idleConnections.pop();
    }

    public void releaseConnection(Connection conn) {
        if (idleConnections.size() < minIdle) {
            idleConnections.push(conn);
        } else {
            conn.close();
        }
    }
}
```

### 4. 增量同步

```java
// 错误: 每次发送完整状态
class PlayerState {
    int x, y, z;              // 12 bytes
    int health, mana;         // 8 bytes
    String name;              // 20 bytes
    List<Item> inventory;     // 200 bytes
}  // Total: ~240 bytes/update

// 优化: 只发送变化的字段
class PlayerStateDelta {
    byte flags;  // bit 0: position changed, bit 1: health changed, ...
    int x, y, z;       // optional
    int health, mana;  // optional
}  // Average: ~10 bytes/update (96% reduction)
```

---

## 📊 性能基准测试

### 客户端性能目标

| 指标 | 目标 | 测试条件 |
|-----|------|---------|
| **帧率** | ≥ 60 FPS | 主城场景, 100+ 玩家 |
| **帧率** | ≥ 30 FPS | 战斗场景, 50+ 敌人 + 特效 |
| **启动时间** | ≤ 3 秒 | 冷启动到主菜单 |
| **场景加载** | ≤ 2 秒 | 场景切换 |
| **内存占用** | ≤ 200MB | 运行 1 小时后 |
| **网络延迟** | ≤ 100ms | 正常操作响应时间 |

### 服务器性能目标

| 指标 | 目标 | 测试条件 |
|-----|------|---------|
| **TPS** | ≥ 10,000 | 每秒事务数 |
| **延迟** | P99 ≤ 50ms | 99% 请求响应时间 |
| **并发** | ≥ 5,000 | 同时在线玩家数 |
| **CPU** | ≤ 70% | 正常负载 |
| **内存** | ≤ 4GB | 运行 24 小时后 |
| **GC 停顿** | ≤ 100ms | Full GC 时间 |

---

## 🛠️ 性能优化工具箱

### Windows 工具

- **Visual Studio Profiler**: CPU/内存/GPU 分析
- **Very Sleepy**: 轻量级 C++ profiler
- **Intel VTune**: 高级性能分析
- **PIX**: DirectX 图形调试

### Lua 工具

- **自定义 Profiler**: 见上文示例
- **LuaJIT**: 使用 JIT 编译器

### Java 工具

- **JProfiler**: 商业性能分析工具
- **YourKit**: 商业性能分析工具
- **JVisualVM**: 免费, JDK 自带
- **Java Flight Recorder**: Oracle JDK 自带

---

## 📚 学习资源

### 相关技能文档

- [C++ 开发技能](../client/cpp-development.md) - C++ 优化技巧
- [Cocos2d-x 2.2.6 使用指南](../client/cocos2dx-usage.md) - 渲染优化
- [Lua 脚本技能](../client/lua-scripting.md) - Lua 性能优化
- [Java 开发技能](../server/java-development.md) - JVM 性能调优

### 外部资源

- **书籍**: 《Code Complete 2》, 《Effective C++》
- **论坛**: Stack Overflow, GameDev.net
- **工具**: godbolt.org (查看编译器优化)

---

## 🎯 实践项目

### 初级项目: 游戏循环优化 (3-5天)

**目标**: 将游戏主循环从 30 FPS 优化到 60 FPS

**步骤**:
1. 使用 Visual Studio Profiler 识别热点函数
2. 优化前 3 个最耗时的函数
3. 验证帧率提升

### 中级项目: 内存优化 (1-2周)

**目标**: 将游戏内存占用从 300MB 降到 200MB

**步骤**:
1. 使用 Memory Profiler 识别内存泄漏
2. 实现对象池管理子弹和粒子
3. 优化纹理加载策略

### 高级项目: 网络协议优化 (2-3周)

**目标**: 将网络流量减少 50%

**步骤**:
1. 分析当前协议开销
2. 设计二进制协议格式
3. 实现增量同步和压缩

---

## ⚠️ 常见陷阱

### 1. 过早优化

```cpp
// ❌ 错误: 优化不常用的代码
void loadConfig() {  // 只在启动时调用一次
    // 花费大量时间优化这个函数...
}

// ✅ 正确: 专注热点路径
void gameLoop() {  // 每秒调用 60 次
    update();  // 优化这里!
    render();  // 优化这里!
}
```

### 2. 忽略测量

```cpp
// ❌ 错误: 凭直觉优化
"我觉得这个函数慢，优化它吧"

// ✅ 正确: 基于数据
Timer t;
t.start();
myFunction();
t.stop();
printf("myFunction took %.3f ms\n", t.elapsed());
```

### 3. 牺牲可读性

```cpp
// ❌ 错误: 过度优化
#define FAST_SQRT(x) (*((float*)&(((*(int*)&(x)) >> 1) + 0x1fbb67a8)))

// ✅ 正确: 使用标准库
float result = sqrtf(x);  // 编译器已优化
```

---

## ✅ 检查清单

### 性能优化前

- [ ] 建立性能基准（FPS, 内存, 网络）
- [ ] 使用 Profiler 识别瓶颈
- [ ] 明确优化目标（提升 XX%）
- [ ] 估算优化成本和收益

### 性能优化时

- [ ] 专注热点路径
- [ ] 保持代码可读性
- [ ] 避免过度优化
- [ ] 每次优化后重新测量

### 性能优化后

- [ ] 验证性能提升
- [ ] 进行回归测试
- [ ] 更新性能文档
- [ ] 代码审查

---

**版本历史**:
- v1.1.0 (2025-11-25): 系统化性能优化指南
- v1.0.0 (2025-11-24): 初始版本

**维护者**: MT3 技术委员会
**反馈**: 如有问题或建议，请联系技术委员会

# 性能优化最佳实践文档

> MT3 项目性能优化最佳实践文档

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、渲染优化

### 1.1 减少 Draw Call

**问题描述**: Draw Call 过多导致性能下降

**解决方案**:

```cpp
// 错误：每个精灵单独渲染
for (int i = 0; i < 100; i++) {
    CCSprite* sprite = CCSprite::create("sprite.png");
    sprite->setPosition(i * 10, 0);
    addChild(sprite);
}

// 正确：使用批处理
CCSpriteBatchNode* batchNode = CCSpriteBatchNode::create("sprites.png");
addChild(batchNode);

for (int i = 0; i < 100; i++) {
    CCSprite* sprite = CCSprite::createWithTexture(batchNode->getTexture());
    sprite->setPosition(i * 10, 0);
    batchNode->addChild(sprite);
}
```

### 1.2 优化纹理格式

**问题描述**: 纹理格式不优导致性能下降

**解决方案**:

```cpp
// 使用压缩纹理格式
// Win32: DXT5
// Android: ETC1
// iOS: PVRTC

// 使用纹理图集减少纹理切换
TexturePacker::pack("sprites/*.png", "spritesheet.png", {
    .format = "PVRTC",
    .maxSize = 2048,
    .padding = 2
});
```

### 1.3 使用 LOD (Level of Detail)

**问题描述**: 远距离物体渲染过多细节

**解决方案**:

```cpp
// 根据距离选择不同细节
void Update() {
    float distance = GetDistanceToCamera();

    if (distance < 100) {
        SetLOD(LOD_HIGH);
    } else if (distance < 500) {
        SetLOD(LOD_MEDIUM);
    } else {
        SetLOD(LOD_LOW);
    }
}
```

### 1.4 使用视锥体裁剪

**问题描述**: 渲染视锥体外的物体

**解决方案**:

```cpp
// 使用视锥体裁剪
void CullObjects() {
    Frustum frustum = GetCameraFrustum();

    for (auto obj : m_objects) {
        if (!frustum.contains(obj->getBoundingBox())) {
            obj->setVisible(false);
        } else {
            obj->setVisible(true);
        }
    }
}
```

---

## 二、逻辑优化

### 2.1 减少不必要的计算

**问题描述**: 重复计算导致性能下降

**解决方案**:

```cpp
// 错误：重复计算
void Update() {
    for (int i = 0; i < 100; i++) {
        float distance = sqrt(x * x + y * y + z * z);
        // 使用距离
    }
}

// 正确：缓存计算结果
void Update() {
    float distance = sqrt(x * x + y * y + z * z);
    for (int i = 0; i < 100; i++) {
        // 使用距离
    }
}
```

### 2.2 使用空间分区

**问题描述**: 碰撞检测遍历所有物体

**解决方案**:

```cpp
// 使用四叉树进行空间分区
class QuadTree {
public:
    void insert(Object* obj) {
        // 插入物体到四叉树
    }

    std::vector<Object*> query(const BoundingBox& box) {
        // 查询四叉树中的物体
    }
};

// 使用四叉树进行碰撞检测
void Update() {
    BoundingBox box = GetPlayerBoundingBox();
    std::vector<Object*> objects = m_quadTree.query(box);

    for (auto obj : objects) {
        if (CheckCollision(box, obj->getBoundingBox())) {
            // 处理碰撞
        }
    }
}
```

### 2.3 优化碰撞检测

**问题描述**: 碰撞检测过于频繁

**解决方案**:

```cpp
// 使用简单的碰撞检测
bool CheckCollision(const BoundingBox& a, const BoundingBox& b) {
    return (a.min.x <= b.max.x && a.max.x >= b.min.x &&
            a.min.y <= b.max.y && a.max.y >= b.min.y &&
            a.min.z <= b.max.z && a.max.z >= b.min.z);
}

// 使用分离轴定理进行精确碰撞检测
bool CheckCollisionSAT(const BoundingBox& a, const BoundingBox& b) {
    // 实现分离轴定理
}
```

---

## 三、内存优化

### 3.1 使用对象池

**问题描述**: 频繁创建销毁对象导致内存碎片

**解决方案**:

```cpp
// 使用对象池复用对象
class BulletPool {
public:
    static BulletPool& getInstance() {
        static BulletPool instance;
        return instance;
    }

    Bullet* obtain() {
        if (!m_pool.empty()) {
            Bullet* bullet = m_pool.back();
            m_pool.pop_back();
            return bullet;
        }
        return new Bullet();
    }

    void recycle(Bullet* bullet) {
        bullet->reset();
        m_pool.push_back(bullet);
    }

private:
    std::vector<Bullet*> m_pool;
};

// 使用对象池
void FireBullet() {
    Bullet* bullet = BulletPool::getInstance().obtain();
    bullet->setPosition(player->getPosition());
    bullet->setDirection(player->getDirection());
    addBullet(bullet);
}

void OnBulletHit(Bullet* bullet) {
    BulletPool::getInstance().recycle(bullet);
}
```

### 3.2 及时释放资源

**问题描述**: 资源未及时释放导致内存占用过高

**解决方案**:

```cpp
// 及时释放不再使用的资源
void UnloadScene() {
    for (auto sprite : m_sprites) {
        sprite->removeFromParent();
    }
    m_sprites.clear();

    for (auto texture : m_textures) {
        CCTextureCache::sharedTextureCache()->removeTexture(texture);
    }
    m_textures.clear();
}
```

### 3.3 使用智能指针

**问题描述**: 手动管理内存容易出错

**解决方案**:

```cpp
// 使用智能指针管理对象
std::shared_ptr<MyClass> obj = std::make_shared<MyClass>();

// 使用弱指针避免循环引用
std::weak_ptr<MyClass> weakObj = obj;

// 获取对象
if (auto ptr = weakObj.lock()) {
    ptr->doSomething();
}
```

---

## 四、线程优化

### 4.1 使用多线程并行处理

**问题描述**: 单线程处理导致性能瓶颈

**解决方案**:

```cpp
// 使用多线程并行处理
void ProcessData() {
    const int threadCount = 4;
    std::vector<std::thread> threads;

    for (int i = 0; i < threadCount; i++) {
        threads.emplace_back([i, threadCount]() {
            for (int j = i; j < dataSize; j += threadCount) {
                ProcessItem(data[j]);
            }
        });
    }

    for (auto& thread : threads) {
        thread.join();
    }
}
```

### 4.2 优化线程同步

**问题描述**: 过多的锁导致性能下降

**解决方案**:

```cpp
// 使用原子操作避免锁
class AtomicCounter {
public:
    void increment() {
        m_count.fetch_add(1, std::memory_order_relaxed);
    }

    int getCount() {
        return m_count.load(std::memory_order_relaxed);
    }

private:
    std::atomic<int> m_count;
};

// 使用读写锁
class ReadWriteLock {
public:
    void readLock() {
        m_mutex.lock_shared();
    }

    void readUnlock() {
        m_mutex.unlock_shared();
    }

    void writeLock() {
        m_mutex.lock();
    }

    void writeUnlock() {
        m_mutex.unlock();
    }

private:
    std::shared_mutex m_mutex;
};
```

### 4.3 使用线程池

**问题描述**: 频繁创建销毁线程导致性能下降

**解决方案**:

```cpp
// 使用线程池复用线程
class ThreadPool {
public:
    ThreadPool(size_t threadCount) {
        for (size_t i = 0; i < threadCount; i++) {
            m_workers.emplace_back([this]() {
                while (true) {
                    Task task;
                    {
                        std::unique_lock<std::mutex> lock(m_mutex);
                        m_condition.wait(lock, [this]() {
                            return !m_tasks.empty() || m_stop;
                        });

                        if (m_stop && m_tasks.empty()) {
                            return;
                        }

                        task = std::move(m_tasks.front());
                        m_tasks.pop();
                    }

                    task();
                }
            });
        }
    }

    void enqueue(Task task) {
        {
            std::lock_guard<std::mutex> lock(m_mutex);
            m_tasks.push(task);
        }
        m_condition.notify_one();
    }

    ~ThreadPool() {
        {
            std::lock_guard<std::mutex> lock(m_mutex);
            m_stop = true;
        }
        m_condition.notify_all();

        for (auto& worker : m_workers) {
            worker.join();
        }
    }

private:
    std::vector<std::thread> m_workers;
    std::queue<Task> m_tasks;
    std::mutex m_mutex;
    std::condition_variable m_condition;
    bool m_stop = false;
};
```

---

## 五、网络优化

### 5.1 使用数据压缩

**问题描述**: 网络数据过大导致延迟

**解决方案**:

```cpp
// 使用 zlib 压缩数据
#include <zlib.h>

std::string CompressData(const std::string& data) {
    uLongf compressedSize = compressBound(data.size());
    std::string compressed(compressedSize, '\0');

    compress2(
        (Bytef*)compressed.data(),
        &compressedSize,
        (const Bytef*)data.data(),
        data.size()
    );

    compressed.resize(compressedSize);
    return compressed;
}

std::string DecompressData(const std::string& compressed) {
    uLongf decompressedSize = 1024 * 1024;
    std::string decompressed(decompressedSize, '\0');

    uncompress(
        (Bytef*)decompressed.data(),
        &decompressedSize,
        (const Bytef*)compressed.data(),
        compressed.size()
    );

    decompressed.resize(decompressedSize);
    return decompressed;
}
```

### 5.2 使用数据缓存

**问题描述**: 频繁请求相同数据

**解决方案**:

```cpp
// 使用数据缓存
class DataCache {
public:
    static DataCache& getInstance() {
        static DataCache instance;
        return instance;
    }

    std::string getData(const std::string& key) {
        auto it = m_cache.find(key);
        if (it != m_cache.end()) {
            return it->second;
        }

        std::string data = FetchDataFromServer(key);
        m_cache[key] = data;
        return data;
    }

private:
    std::map<std::string, std::string> m_cache;
};
```

---

## 六、性能分析

### 6.1 使用性能分析工具

**问题描述**: 无法定位性能瓶颈

**解决方案**:

```cpp
// 使用性能分析工具
#include <chrono>

class PerformanceProfiler {
public:
    void start(const std::string& name) {
        m_startTimes[name] = std::chrono::high_resolution_clock::now();
    }

    void stop(const std::string& name) {
        auto endTime = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(
            endTime - m_startTimes[name]
        ).count();

        m_durations[name] = duration;
    }

    void printReport() {
        for (auto& [name, duration] : m_durations) {
            printf("%s: %lld us\n", name.c_str(), duration);
        }
    }

private:
    std::map<std::string, std::chrono::time_point<std::chrono::high_resolution_clock>> m_startTimes;
    std::map<std::string, long long> m_durations;
};

// 使用性能分析器
PerformanceProfiler profiler;

void Update() {
    profiler.start("Update");
    // 更新逻辑
    profiler.stop("Update");

    profiler.start("Render");
    // 渲染逻辑
    profiler.stop("Render");

    profiler.printReport();
}
```

### 6.2 监控性能指标

**问题描述**: 无法实时监控性能

**解决方案**:

```cpp
// 监控 FPS
class FPSMonitor {
public:
    void update() {
        auto currentTime = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
            currentTime - m_lastTime
        ).count();

        m_frameCount++;

        if (duration >= 1000) {
            float fps = m_frameCount * 1000.0f / duration;
            printf("FPS: %.2f\n", fps);

            m_frameCount = 0;
            m_lastTime = currentTime;
        }
    }

private:
    int m_frameCount = 0;
    std::chrono::time_point<std::chrono::high_resolution_clock> m_lastTime = std::chrono::high_resolution_clock::now();
};

// 监控内存使用
size_t GetCurrentMemoryUsage() {
#if defined(_WIN32)
    PROCESS_MEMORY_COUNTERS pmc;
    GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc));
    return pmc.WorkingSetSize;
#elif defined(ANDROID)
    // Android 内存使用
    return 0;
#elif defined(IOS)
    // iOS 内存使用
    return 0;
#endif
}
```

---

## 七、最佳实践

### 7.1 渲染优化最佳实践

- 使用批处理减少 Draw Call
- 使用纹理图集减少纹理切换
- 使用 LOD 减少渲染细节
- 使用视锥体裁剪减少渲染物体

### 7.2 逻辑优化最佳实践

- 减少不必要的计算
- 使用空间分区优化碰撞检测
- 使用对象池复用对象
- 优化算法复杂度

### 7.3 内存优化最佳实践

- 及时释放资源
- 使用对象池
- 使用智能指针
- 优化内存分配

### 7.4 线程优化最佳实践

- 使用多线程并行处理
- 优化线程同步
- 使用线程池
- 避免线程竞争

---

## 八、参考资料

- [公共约束](../references/common-constraints.md)
- [最佳实践](../references/best-practices.md)
- [跨平台最佳实践](../references/cross-platform-best-practices.md)

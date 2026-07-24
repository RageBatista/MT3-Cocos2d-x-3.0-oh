# C++ 设计模式 (C++ Design Patterns)

> **范围**: MT3 项目常用设计模式
> **版本**: 1.0 | **更新**: 2026-01-07

---

## 📋 概述

MT3 项目中的 C++ 设计模式分为三类:

1. **内存管理模式** - 引用计数, 对象池, RAII
2. **性能优化模式** - 脏标记, 延迟计算, 缓存
3. **架构模式** - 单例, 工厂, 观察者

---

## 🔄 内存管理模式

### 1. 引用计数 (Reference Counting)

**用途**: Cocos2d-x 和 Nuclear 引擎的核心内存管理机制

**实现原理**:

```cpp
// CCObject.h (Cocos2d-x 2.0)
class CCObject {
protected:
    unsigned int m_uReference;
    unsigned int m_uAutoReleaseCount;

public:
    CCObject() : m_uReference(1), m_uAutoReleaseCount(0) {}

    void retain() {
        ++m_uReference;
    }

    void release() {
        --m_uReference;
        if (m_uReference == 0) {
            delete this;
        }
    }

    CCObject* autorelease() {
        CCPoolManager::sharedPoolManager()->addObject(this);
        return this;
    }

    unsigned int retainCount() const {
        return m_uReference;
    }
};
```

**使用模式**:

```cpp
// ✅ 正确: 工厂方法返回 autorelease 对象
CCSprite* CCSprite::create(const char* filename) {
    CCSprite* sprite = new CCSprite();
    if (sprite && sprite->initWithFile(filename)) {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

// ✅ 正确: 添加到容器时 retain
class GameLayer : public CCLayer {
    CCSprite* m_player;

public:
    GameLayer() : m_player(nullptr) {}

    void setPlayer(CCSprite* player) {
        if (m_player != player) {
            CC_SAFE_RELEASE(m_player);  // 释放旧对象
            m_player = player;
            CC_SAFE_RETAIN(m_player);   // 保持新对象
        }
    }

    ~GameLayer() {
        CC_SAFE_RELEASE(m_player);
    }
};

// ❌ 错误: 忘记 release
class BadLayer : public CCLayer {
    CCSprite* m_player;

public:
    BadLayer() {
        m_player = CCSprite::create("player.png");
        m_player->retain();  // retain 了
        // 但析构函数没有 release → 内存泄漏!
    }
};
```

**宏辅助**:

```cpp
// cocos2d-x 提供的宏
#define CC_SAFE_DELETE(p)            do { if(p) { delete (p); (p) = nullptr; } } while(0)
#define CC_SAFE_RELEASE(p)           do { if(p) { (p)->release(); } } while(0)
#define CC_SAFE_RELEASE_NULL(p)      do { if(p) { (p)->release(); (p) = nullptr; } } while(0)
#define CC_SAFE_RETAIN(p)            do { if(p) { (p)->retain(); } } while(0)

// Nuclear 引擎扩展
#define NUCLEAR_SAFE_RELEASE(p) \
    do { if (p) { (p)->release(); (p) = nullptr; } } while(0)
```

**检查清单**:

```yaml
- [ ] 构造函数中 retain 的对象在析构函数中 release
- [ ] setXxx 方法先 release 旧值再 retain 新值
- [ ] 工厂方法返回 autorelease 对象
- [ ] 容器清理时遍历 release 所有元素
- [ ] 避免循环引用 (A retain B, B retain A)
```

---

### 2. 对象池 (Object Pool)

**用途**: 减少频繁创建/销毁对象的开销,特别是粒子/特效/子弹等

**实现**:

```cpp
// 简单对象池模板
template <typename T>
class ObjectPool {
private:
    std::vector<T*> m_pool;
    std::vector<T*> m_active;
    int m_capacity;

public:
    ObjectPool(int capacity) : m_capacity(capacity) {
        m_pool.reserve(capacity);
    }

    ~ObjectPool() {
        for (T* obj : m_pool) {
            delete obj;
        }
        for (T* obj : m_active) {
            delete obj;
        }
    }

    T* allocate() {
        T* obj = nullptr;
        if (!m_pool.empty()) {
            obj = m_pool.back();
            m_pool.pop_back();
        } else {
            obj = new T();
        }
        m_active.push_back(obj);
        return obj;
    }

    void free(T* obj) {
        auto it = std::find(m_active.begin(), m_active.end(), obj);
        if (it != m_active.end()) {
            m_active.erase(it);
            if (m_pool.size() < m_capacity) {
                m_pool.push_back(obj);
            } else {
                delete obj;
            }
        }
    }

    void clear() {
        for (T* obj : m_active) {
            m_pool.push_back(obj);
        }
        m_active.clear();
    }
};
```

**使用示例**:

```cpp
// 特效对象池
class Effect {
public:
    void reset() {
        m_active = false;
        m_position = CCPointZero;
        m_duration = 0.0f;
    }

    void play(const CCPoint& pos, float duration) {
        m_active = true;
        m_position = pos;
        m_duration = duration;
    }

private:
    bool m_active;
    CCPoint m_position;
    float m_duration;
};

// 游戏层使用对象池
class GameLayer : public CCLayer {
private:
    ObjectPool<Effect> m_effectPool;

public:
    GameLayer() : m_effectPool(100) {  // 预分配 100 个
    }

    void playEffect(const CCPoint& pos) {
        Effect* effect = m_effectPool.allocate();
        effect->reset();
        effect->play(pos, 1.0f);
    }

    void update(float dt) {
        // 更新特效
        // 完成后回收: m_effectPool.free(effect);
    }
};
```

**Cocos2d-x 内置对象池**:

```cpp
// CCPoolManager - 自动释放池
CCSprite* sprite = CCSprite::create("test.png");  // autorelease
// 当前帧结束时自动 release

// CCArray - 对象数组 (引用计数管理)
CCArray* array = CCArray::create();
array->addObject(sprite);  // 自动 retain
// array 销毁时自动 release 所有元素
```

**性能对比**:

```yaml
场景: 创建 1000 个粒子对象

不使用对象池:
  - new/delete 1000 次
  - 耗时: ~5ms
  - 内存碎片: 高

使用对象池:
  - 预分配 1000 个
  - 重复使用
  - 耗时: ~0.5ms
  - 内存碎片: 低

性能提升: 10x
```

---

### 3. RAII (Resource Acquisition Is Initialization)

**用途**: 自动资源管理,防止内存泄漏/文件未关闭/锁未释放

**文件管理**:

```cpp
// ✅ 正确: RAII 文件管理
class FileGuard {
private:
    FILE* m_file;

public:
    FileGuard(const char* path, const char* mode) {
        m_file = fopen(path, mode);
        if (!m_file) {
            throw std::runtime_error("Cannot open file");
        }
    }

    ~FileGuard() {
        if (m_file) {
            fclose(m_file);
        }
    }

    FILE* get() { return m_file; }

    // 禁止拷贝
    FileGuard(const FileGuard&) = delete;
    FileGuard& operator=(const FileGuard&) = delete;
};

// 使用
void processFile(const char* path) {
    FileGuard file(path, "r");
    // 使用 file.get()
    // 函数退出时自动关闭文件,即使抛异常
}

// ❌ 错误: 手动管理,容易泄漏
void badProcessFile(const char* path) {
    FILE* file = fopen(path, "r");
    // ... 如果这里抛异常,文件未关闭!
    fclose(file);
}
```

**锁管理**:

```cpp
// ✅ 正确: RAII 锁管理
class MutexGuard {
private:
    pthread_mutex_t* m_mutex;

public:
    MutexGuard(pthread_mutex_t* mutex) : m_mutex(mutex) {
        pthread_mutex_lock(m_mutex);
    }

    ~MutexGuard() {
        pthread_mutex_unlock(m_mutex);
    }
};

// 使用
pthread_mutex_t g_mutex = PTHREAD_MUTEX_INITIALIZER;

void threadSafeFunction() {
    MutexGuard lock(&g_mutex);
    // 临界区代码
    // 退出时自动解锁,即使抛异常
}
```

**Cocos2d-x 节点管理**:

```cpp
// ✅ 正确: addChild 自动 retain
CCSprite* sprite = CCSprite::create("test.png");
this->addChild(sprite);  // addChild 会 retain
// layer 销毁时自动 release sprite

// ❌ 错误: 手动 retain 后忘记 release
CCSprite* sprite = CCSprite::create("test.png");
sprite->retain();  // 多余的 retain
this->addChild(sprite);  // addChild 已经 retain
// 导致 retainCount = 2, layer 销毁后仍有 1 → 泄漏
```

---

## ⚡ 性能优化模式

### 4. 脏标记 (Dirty Flag)

**用途**: 延迟计算,避免重复计算未变化的值

**实现**:

```cpp
class NuclearSprite {
private:
    // 位置/旋转/缩放
    CCPoint m_position;
    float m_rotation;
    float m_scale;

    // 变换矩阵
    CCAffineTransform m_transform;
    bool m_transformDirty;  // 脏标记

public:
    NuclearSprite()
        : m_position(CCPointZero)
        , m_rotation(0.0f)
        , m_scale(1.0f)
        , m_transformDirty(true)
    {}

    void setPosition(const CCPoint& pos) {
        if (!CCPoint::CCPointEqualToPoint(m_position, pos)) {
            m_position = pos;
            m_transformDirty = true;  // 标记为脏
        }
    }

    void setRotation(float rotation) {
        if (m_rotation != rotation) {
            m_rotation = rotation;
            m_transformDirty = true;
        }
    }

    void setScale(float scale) {
        if (m_scale != scale) {
            m_scale = scale;
            m_transformDirty = true;
        }
    }

    const CCAffineTransform& getTransform() {
        if (m_transformDirty) {
            // 仅在脏时重新计算
            m_transform = CCAffineTransformIdentity;
            m_transform = CCAffineTransformTranslate(m_transform, m_position.x, m_position.y);
            m_transform = CCAffineTransformRotate(m_transform, CC_DEGREES_TO_RADIANS(m_rotation));
            m_transform = CCAffineTransformScale(m_transform, m_scale, m_scale);
            m_transformDirty = false;
        }
        return m_transform;
    }
};
```

**性能对比**:

```yaml
场景: 每帧调用 getTransform() 1000 次,但实际只改变 10 次位置

无脏标记:
  - 计算矩阵 1000 次
  - 耗时: ~2ms

有脏标记:
  - 计算矩阵 10 次
  - 耗时: ~0.02ms

性能提升: 100x
```

**Cocos2d-x 中的脏标记**:

```cpp
// CCNode 使用脏标记
class CCNode {
protected:
    bool m_bTransformDirty;
    bool m_bInverseDirty;

    CCAffineTransform m_sTransform;
    CCAffineTransform m_sInverse;

public:
    const CCAffineTransform& nodeToParentTransform() {
        if (m_bTransformDirty) {
            // 重新计算
            m_bTransformDirty = false;
        }
        return m_sTransform;
    }
};
```

---

### 5. 延迟计算 (Lazy Evaluation)

**用途**: 推迟计算到真正需要时,避免无用计算

**实现**:

```cpp
class TextureAtlas {
private:
    std::string m_atlasPath;
    CCTexture2D* m_texture;  // 延迟加载
    bool m_loaded;

public:
    TextureAtlas(const std::string& path)
        : m_atlasPath(path)
        , m_texture(nullptr)
        , m_loaded(false)
    {}

    CCTexture2D* getTexture() {
        if (!m_loaded) {
            // 首次访问时才加载
            m_texture = CCTextureCache::sharedTextureCache()
                ->addImage(m_atlasPath.c_str());
            m_loaded = true;
        }
        return m_texture;
    }

    void unload() {
        if (m_loaded) {
            CCTextureCache::sharedTextureCache()
                ->removeTexture(m_texture);
            m_texture = nullptr;
            m_loaded = false;
        }
    }
};
```

**使用场景**:

```cpp
// ✅ 正确: 延迟加载纹理
class GameScene {
private:
    TextureAtlas m_atlas1;
    TextureAtlas m_atlas2;

public:
    void onEnter() {
        // 不立即加载所有纹理
    }

    void showMonster() {
        // 仅在需要时加载
        CCSprite* monster = CCSprite::createWithTexture(m_atlas1.getTexture());
    }
};

// ❌ 错误: 预加载所有纹理
class BadGameScene {
public:
    void onEnter() {
        // 加载所有纹理,即使不用
        CCTextureCache::sharedTextureCache()->addImage("atlas1.png");
        CCTextureCache::sharedTextureCache()->addImage("atlas2.png");
        CCTextureCache::sharedTextureCache()->addImage("atlas3.png");
        // 内存浪费!
    }
};
```

---

### 6. 缓存 (Caching)

**用途**: 缓存计算结果,避免重复计算

**实现**:

```cpp
class PathFinder {
private:
    struct CacheKey {
        CCPoint start;
        CCPoint end;

        bool operator<(const CacheKey& other) const {
            if (start.x != other.start.x) return start.x < other.start.x;
            if (start.y != other.start.y) return start.y < other.start.y;
            if (end.x != other.end.x) return end.x < other.end.x;
            return end.y < other.end.y;
        }
    };

    std::map<CacheKey, std::vector<CCPoint>> m_cache;
    int m_maxCacheSize;

public:
    PathFinder() : m_maxCacheSize(100) {}

    std::vector<CCPoint> findPath(const CCPoint& start, const CCPoint& end) {
        CacheKey key = {start, end};

        // 检查缓存
        auto it = m_cache.find(key);
        if (it != m_cache.end()) {
            return it->second;  // 返回缓存结果
        }

        // 计算路径 (耗时操作)
        std::vector<CCPoint> path = calculatePath(start, end);

        // 缓存结果
        if (m_cache.size() < m_maxCacheSize) {
            m_cache[key] = path;
        }

        return path;
    }

    void clearCache() {
        m_cache.clear();
    }

private:
    std::vector<CCPoint> calculatePath(const CCPoint& start, const CCPoint& end) {
        // A* 寻路算法 (耗时)
        // ...
    }
};
```

**Cocos2d-x 缓存机制**:

```cpp
// CCTextureCache - 纹理缓存
CCTexture2D* tex1 = CCTextureCache::sharedTextureCache()->addImage("test.png");
CCTexture2D* tex2 = CCTextureCache::sharedTextureCache()->addImage("test.png");
// tex1 == tex2 (同一个对象,不重复加载)

// CCSpriteFrameCache - 精灵帧缓存
CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("sprites.plist");
CCSpriteFrame* frame = CCSpriteFrameCache::sharedSpriteFrameCache()
    ->spriteFrameByName("hero.png");
```

---

## 🏗️ 架构模式

### 7. 单例 (Singleton)

**用途**: 全局唯一实例,如配置管理器/音频管理器

**线程安全实现 (C++11)**:

```cpp
class ConfigManager {
private:
    ConfigManager() {}
    ~ConfigManager() {}

    // 禁止拷贝
    ConfigManager(const ConfigManager&) = delete;
    ConfigManager& operator=(const ConfigManager&) = delete;

public:
    static ConfigManager& getInstance() {
        static ConfigManager instance;  // C++11 线程安全
        return instance;
    }

    void loadConfig(const std::string& path) {
        // ...
    }

    std::string getValue(const std::string& key) const {
        // ...
    }
};

// 使用
ConfigManager::getInstance().loadConfig("config.xml");
std::string value = ConfigManager::getInstance().getValue("resolution");
```

**Cocos2d-x 单例模式**:

```cpp
// CCDirector::sharedDirector()
CCDirector* director = CCDirector::sharedDirector();

// CCTextureCache::sharedTextureCache()
CCTextureCache* cache = CCTextureCache::sharedTextureCache();

// ⚠️ 注意: Cocos2d-x 2.0 使用指针返回,需手动销毁
// Cocos2d-x 3.0+ 改为引用返回
```

---

### 8. 工厂 (Factory)

**用途**: 创建对象,隐藏创建细节

**简单工厂**:

```cpp
class Sprite {
public:
    enum Type {
        Static,
        Animated,
        Particle
    };

    static Sprite* create(Type type) {
        switch (type) {
        case Static:
            return new StaticSprite();
        case Animated:
            return new AnimatedSprite();
        case Particle:
            return new ParticleSprite();
        default:
            return nullptr;
        }
    }
};

// 使用
Sprite* sprite = Sprite::create(Sprite::Animated);
```

**Cocos2d-x 工厂模式**:

```cpp
// CCSprite::create 系列
CCSprite* sprite1 = CCSprite::create("test.png");
CCSprite* sprite2 = CCSprite::createWithTexture(texture);
CCSprite* sprite3 = CCSprite::createWithSpriteFrameName("hero.png");

// CCLayer::create
CCLayer* layer = CCLayer::create();

// CCMenu::create
CCMenu* menu = CCMenu::create(item1, item2, nullptr);
```

---

### 9. 观察者 (Observer)

**用途**: 事件通知,解耦发送者和接收者

**实现**:

```cpp
// 观察者接口
class IObserver {
public:
    virtual ~IObserver() {}
    virtual void onNotify(int event, void* data) = 0;
};

// 被观察者 (主题)
class Subject {
private:
    std::vector<IObserver*> m_observers;

public:
    void addObserver(IObserver* observer) {
        m_observers.push_back(observer);
    }

    void removeObserver(IObserver* observer) {
        auto it = std::find(m_observers.begin(), m_observers.end(), observer);
        if (it != m_observers.end()) {
            m_observers.erase(it);
        }
    }

    void notify(int event, void* data) {
        for (IObserver* observer : m_observers) {
            observer->onNotify(event, data);
        }
    }
};

// 具体观察者
class GameLayer : public CCLayer, public IObserver {
public:
    void onNotify(int event, void* data) override {
        switch (event) {
        case EVENT_PLAYER_DIED:
            // 处理玩家死亡
            break;
        case EVENT_LEVEL_UP:
            // 处理升级
            break;
        }
    }
};
```

**Cocos2d-x 通知中心**:

```cpp
// 注册观察者
CCNotificationCenter::sharedNotificationCenter()->addObserver(
    this,
    callfuncO_selector(GameLayer::onPlayerDied),
    "player_died",
    nullptr
);

// 发送通知
CCNotificationCenter::sharedNotificationCenter()->postNotification(
    "player_died",
    player
);

// 移除观察者
CCNotificationCenter::sharedNotificationCenter()->removeObserver(
    this,
    "player_died"
);
```

---

## ✅ 最佳实践

### 内存管理

```yaml
✅ 使用引用计数 (Cocos2d-x/Nuclear 对象)
✅ 使用对象池 (频繁创建/销毁的对象)
✅ 使用 RAII (文件/锁/资源)
❌ 避免裸指针 (使用智能管理)
❌ 避免手动 new/delete (使用工厂方法)
```

### 性能优化

```yaml
✅ 使用脏标记 (避免重复计算)
✅ 使用延迟计算 (推迟到需要时)
✅ 使用缓存 (重复查询的数据)
❌ 避免过早优化 (先测量再优化)
❌ 避免过度缓存 (内存占用)
```

### 架构设计

```yaml
✅ 单例用于全局管理器 (ConfigManager, AudioManager)
✅ 工厂用于创建对象 (隐藏细节)
✅ 观察者用于事件通知 (解耦)
❌ 避免单例滥用 (难以测试)
❌ 避免上帝对象 (职责过多)
```

---

**文档版本**: 1.0
**最后更新**: 2026-01-07
**参考**: MT3 项目实践, Cocos2d-x 2.0, Nuclear 引擎

# 最佳实践指南 (Best Practices Guide)

## 目录 (Table of Contents)

- [内存管理](#内存管理-memory-management)
- [性能优化](#性能优化-performance-optimization)
- [代码组织](#代码组织-code-organization)
- [错误处理](#错误处理-error-handling)
- [资源管理](#资源管理-resource-management)
- [多线程编程](#多线程编程-multi-threading)
- [调试技巧](#调试技巧-debugging-techniques)
- [安全最佳实践](#安全最佳实践-security-best-practices)

---

## 内存管理 (Memory Management)

### 对象创建与释放 (Object Creation and Release)

**最佳实践**: 使用 Cocos2d-x 的内存管理机制

```cpp
// 正确: 使用 create() 静态方法
CCSprite* sprite = CCSprite::create("player.png");
this->addChild(sprite);

// 正确: 使用 retain() 和 release()
CCSprite* sprite = new CCSprite();
sprite->initWithFile("player.png");
sprite->autorelease();
this->addChild(sprite);

// 错误: 直接使用 new 而不调用 autorelease
CCSprite* sprite = new CCSprite();
sprite->initWithFile("player.png");
// 缺少 autorelease()，会导致内存泄漏
```

### 引用计数管理 (Reference Count Management)

```cpp
// 正确: 使用 retain() 增加引用计数
void MyClass::setTarget(CCNode* target) {
    if (m_pTarget) {
        m_pTarget->release();
    }
    m_pTarget = target;
    if (m_pTarget) {
        m_pTarget->retain();
    }
}

// 正确: 在析构函数中释放引用
MyClass::~MyClass() {
    CC_SAFE_RELEASE_NULL(m_pTarget);
    CC_SAFE_RELEASE_NULL(m_pSprite);
}
```

### 避免循环引用 (Avoid Circular References)

```cpp
// 错误: 循环引用
class A {
    B* m_pB;
public:
    void setB(B* b) { m_pB = b; m_pB->retain(); }
};

class B {
    A* m_pA;
public:
    void setA(A* a) { m_pA = a; m_pA->retain(); }
};

// 正确: 使用弱引用
class A {
    B* m_pB;
public:
    void setB(B* b) { m_pB = b; m_pB->retain(); }
};

class B {
    A* m_pA;
public:
    void setA(A* a) { m_pA = a; }
    // 不调用 retain()，避免循环引用
};
```

---

## 性能优化 (Performance Optimization)

### 精灵批处理 (Sprite Batching)

**最佳实践**: 使用 CCSpriteBatchNode 批处理相同纹理的精灵

```cpp
// 正确: 使用 CCSpriteBatchNode
CCSpriteBatchNode* batch = CCSpriteBatchNode::create("sprites.png");
this->addChild(batch);

for (int i = 0; i < 100; ++i) {
    CCSprite* sprite = CCSprite::createWithTexture(batch->getTexture());
    sprite->setPosition(ccp(i * 10, i * 10));
    batch->addChild(sprite);
}

// 错误: 直接添加多个精灵，导致多次绘制调用
for (int i = 0; i < 100; ++i) {
    CCSprite* sprite = CCSprite::create("sprites.png");
    sprite->setPosition(ccp(i * 10, i * 10));
    this->addChild(sprite);
}
```

### 纹理优化 (Texture Optimization)

```cpp
// 正确: 使用纹理图集
CCTextureCache::sharedTextureCache()->addImageAsync("atlas.png", this, 
    callfuncO_selector(MyClass::textureLoaded));

// 正确: 使用 PVR 格式纹理
CCTexture2D* texture = CCTextureCache::sharedTextureCache()
    ->addImage("texture.pvr.ccz");

// 正确: 释放不用的纹理
CCTextureCache::sharedTextureCache()->removeUnusedTextures();
```

### 节点优化 (Node Optimization)

```cpp
// 正确: 设置不可见节点为不活跃
node->setVisible(false);
node->setActive(false);

// 正确: 移除不需要的节点
node->removeFromParentAndCleanup(true);

// 正确: 使用对象池重用对象
class BulletPool {
    std::vector<CCSprite*> m_pBullets;
public:
    CCSprite* getBullet() {
        if (m_pBullets.empty()) {
            return CCSprite::create("bullet.png");
        }
        CCSprite* bullet = m_pBullets.back();
        m_pBullets.pop_back();
        return bullet;
    }
    
    void recycleBullet(CCSprite* bullet) {
        bullet->setVisible(false);
        m_pBullets.push_back(bullet);
    }
};
```

### 动作优化 (Action Optimization)

```cpp
// 正确: 使用动作序列
CCFiniteTimeAction* action = CCSequence::create(
    CCMoveBy::create(1.0f, ccp(100, 0)),
    CCRotateBy::create(0.5f, 360),
    NULL
);
sprite->runAction(action);

// 正确: 使用动作池
CCActionManager* manager = CCDirector::sharedDirector()->getActionManager();
manager->pauseAllActionsForTarget(sprite);

// 正确: 停止不需要的动作
sprite->stopAllActions();
sprite->stopActionByTag(ACTION_TAG);
```

---

## 代码组织 (Code Organization)

### 文件结构 (File Structure)

**最佳实践**: 按功能模块组织代码

```
src/
  scenes/           # 场景
    MainMenuScene.cpp
    GameScene.cpp
  layers/           # 层
    GameLayer.cpp
    HUDLayer.cpp
  sprites/          # 精灵
    Player.cpp
    Enemy.cpp
  managers/         # 管理器
    GameManager.cpp
    ResourceManager.cpp
  utils/            # 工具类
    Utils.cpp
    Constants.cpp
```

### 命名规范 (Naming Conventions)

```cpp
// 类名: 大驼峰命名法
class PlayerSprite : public CCSprite {
};

// 方法名: 小驼峰命名法
void updatePosition();
void handleCollision();

// 成员变量: m_ 前缀 + 小驼峰
class MyClass {
    CCSprite* m_pSprite;
    int m_nScore;
    float m_fSpeed;
};

// 常量: 全大写 + 下划线
const int MAX_PLAYERS = 10;
const float GRAVITY = 9.8f;

// 宏定义: 全大写 + 下划线
#define SCREEN_WIDTH 1024
#define SCREEN_HEIGHT 768
```

### 代码注释 (Code Comments)

```cpp
/**
 * @brief 更新玩家位置
 * @param deltaTime 上一帧到当前帧的时间间隔（秒）
 * @return void
 */
void Player::updatePosition(float deltaTime) {
    // 计算新位置
    CCPoint newPos = ccpAdd(m_tPosition, ccpMult(m_tVelocity, deltaTime));
    
    // 边界检查
    if (newPos.x < 0 || newPos.x > SCREEN_WIDTH) {
        m_tVelocity.x *= -1;
    }
    
    m_tPosition = newPos;
}
```

---

## 错误处理 (Error Handling)

### 断言检查 (Assertion Checks)

```cpp
// 正确: 使用 CCAssert 检查前置条件
void MyClass::setSprite(CCSprite* sprite) {
    CCAssert(sprite != NULL, "sprite cannot be NULL");
    CCAssert(sprite->getParent() == NULL, "sprite already has a parent");
    
    m_pSprite = sprite;
    m_pSprite->retain();
}

// 正确: 检查返回值
bool success = CCTextureCache::sharedTextureCache()->addImage("texture.png");
if (!success) {
    CCLog("Failed to load texture: texture.png");
    return false;
}
```

### 异常处理 (Exception Handling)

```cpp
// 正确: 使用 try-catch 处理可能的异常
try {
    CCSprite* sprite = CCSprite::create("player.png");
    this->addChild(sprite);
} catch (const std::exception& e) {
    CCLog("Exception caught: %s", e.what());
    return false;
}

// 正确: 检查文件是否存在
bool fileExists = CCFileUtils::sharedFileUtils()->isFileExist("data.json");
if (!fileExists) {
    CCLog("File not found: data.json");
    return false;
}
```

---

## 资源管理 (Resource Management)

### 资源加载 (Resource Loading)

```cpp
// 正确: 异步加载资源
CCTextureCache::sharedTextureCache()->addImageAsync("background.png", 
    this, callfuncO_selector(MyClass::textureLoaded));

// 正确: 预加载资源
void preloadResources() {
    CCTextureCache::sharedTextureCache()->addImage("player.png");
    CCTextureCache::sharedTextureCache()->addImage("enemy.png");
    CCTextureCache::sharedTextureCache()->addImage("bullet.png");
}

// 正确: 使用资源管理器
class ResourceManager {
    std::map<std::string, CCTexture2D*> m_pTextures;
public:
    CCTexture2D* getTexture(const std::string& filename) {
        if (m_pTextures.find(filename) == m_pTextures.end()) {
            CCTexture2D* texture = CCTextureCache::sharedTextureCache()
                ->addImage(filename.c_str());
            m_pTextures[filename] = texture;
        }
        return m_pTextures[filename];
    }
};
```

### 资源释放 (Resource Release)

```cpp
// 正确: 在场景切换时释放资源
void GameScene::onExit() {
    CCScene::onExit();
    
    // 释放不需要的资源
    CCTextureCache::sharedTextureCache()->removeTexture(m_pBackgroundTexture);
    m_pBackgroundTexture = NULL;
}

// 正确: 清理缓存
void cleanupCache() {
    CCTextureCache::sharedTextureCache()->removeUnusedTextures();
    CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFrames();
    CCAnimationCache::sharedAnimationCache()->purgeSharedAnimationCache();
}
```

---

## 多线程编程 (Multi-threading)

### 线程安全 (Thread Safety)

```cpp
// 正确: 使用互斥锁保护共享资源
class ThreadSafeCounter {
    int m_nCount;
    pthread_mutex_t m_Mutex;
public:
    ThreadSafeCounter() : m_nCount(0) {
        pthread_mutex_init(&m_Mutex, NULL);
    }
    
    void increment() {
        pthread_mutex_lock(&m_Mutex);
        m_nCount++;
        pthread_mutex_unlock(&m_Mutex);
    }
    
    int getCount() {
        pthread_mutex_lock(&m_Mutex);
        int count = m_nCount;
        pthread_mutex_unlock(&m_Mutex);
        return count;
    }
};
```

### 异步任务 (Asynchronous Tasks)

```cpp
// 正确: 使用调度器执行异步任务
void MyClass::loadDataAsync() {
    CCDirector::sharedDirector()->getScheduler()
        ->scheduleSelector(schedule_selector(MyClass::update), this, 0.0f, false);
}

void MyClass::update(float dt) {
    // 执行异步任务
    if (m_bLoading) {
        if (m_fProgress >= 1.0f) {
            m_bLoading = false;
            onLoadingComplete();
        }
    }
}
```

---

## 调试技巧 (Debugging Techniques)

### 日志输出 (Logging)

```cpp
// 正确: 使用 CCLog 输出调试信息
CCLog("Player position: (%.2f, %.2f)", player->getPosition().x, player->getPosition().y);
CCLog("Frame time: %.3f ms", deltaTime * 1000);
CCLog("Memory usage: %.2f MB", getMemoryUsage());

// 正确: 使用条件日志
#ifdef DEBUG
    CCLog("Debug: %s", message);
#endif
```

### 性能分析 (Performance Profiling)

```cpp
// 正确: 使用性能计时器
class PerformanceTimer {
    clock_t m_StartTime;
    const char* m_pName;
public:
    PerformanceTimer(const char* name) : m_pName(name) {
        m_StartTime = clock();
    }
    
    ~PerformanceTimer() {
        clock_t endTime = clock();
        double elapsed = double(endTime - m_StartTime) / CLOCKS_PER_SEC;
        CCLog("%s took %.3f seconds", m_pName, elapsed);
    }
};

// 使用
void updateGame() {
    PerformanceTimer timer("updateGame");
    // 更新逻辑
}
```

---

## 安全最佳实践 (Security Best Practices)

### 输入验证 (Input Validation)

```cpp
// 正确: 验证输入参数
void setPlayerPosition(float x, float y) {
    if (x < 0 || x > SCREEN_WIDTH || y < 0 || y > SCREEN_HEIGHT) {
        CCLog("Invalid position: (%.2f, %.2f)", x, y);
        return;
    }
    
    m_tPosition = ccp(x, y);
}

// 正确: 验证文件路径
bool isValidFilePath(const std::string& path) {
    if (path.empty()) return false;
    if (path.find("..") != std::string::npos) return false;
    if (path.find("/") != std::string::npos) return false;
    return true;
}
```

### 防止内存泄漏 (Prevent Memory Leaks)

```cpp
// 正确: 使用智能指针
#include <memory>

class MyClass {
    std::unique_ptr<CCSprite> m_pSprite;
public:
    MyClass() {
        m_pSprite.reset(CCSprite::create("sprite.png"));
    }
};

// 正确: 使用 RAII 模式
class ScopedTexture {
    CCTexture2D* m_pTexture;
public:
    ScopedTexture(const char* filename) {
        m_pTexture = CCTextureCache::sharedTextureCache()->addImage(filename);
    }
    
    ~ScopedTexture() {
        CCTextureCache::sharedTextureCache()->removeTexture(m_pTexture);
    }
};
```

---

## 快速参考 (Quick Reference)

### 性能检查清单 (Performance Checklist)

- [ ] 使用 CCSpriteBatchNode 批处理精灵
- [ ] 使用纹理图集减少绘制调用
- [ ] 释放不用的纹理和资源
- [ ] 使用对象池重用对象
- [ ] 避免频繁的内存分配和释放
- [ ] 使用异步加载资源
- [ ] 优化动作和动画

### 代码质量检查清单 (Code Quality Checklist)

- [ ] 遵循命名规范
- [ ] 添加适当的注释
- [ ] 使用断言检查前置条件
- [ ] 处理可能的错误情况
- [ ] 避免循环引用
- [ ] 正确管理内存
- [ ] 使用 RAII 模式

---

## 相关文档 (Related Documentation)

- [开发编译构建指南](09_开发编译构建指南__Development-and-Build-Guide.md)
- [故障排除指南](11_故障排除指南__Troubleshooting-Guide.md)
- [核心类架构](02_核心类架构__Core-Classes-Architecture.md)
- [关键实现细节](04_关键实现细节与代码示例__Key-Implementation-Details.md)
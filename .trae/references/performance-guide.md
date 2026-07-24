# 性能优化指南

> 本文件定义了 MT3 项目中的性能优化策略和最佳实践。

## 目录

- [性能基线](#性能基线)
- [CEGUI 性能优化](#cegui-性能优化)
- [Cocos2d-x 性能优化](#cocos2d-x-性能优化)
- [Nuclear 引擎性能优化](#nuclear-引擎性能优化)
- [内存优化](#内存优化)
- [性能分析工具](#性能分析工具)
- [常见性能问题](#常见性能问题)
- [参考文档](#参考文档)

---

## 性能基线

### 目标指标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| **FPS** | ≥ 60 | 正常游戏运行帧率 |
| **内存占用** | < 500 MB | Win32 平台峰值 |
| **场景加载时间** | < 3 秒 | 主场景加载 |
| **UI 响应时间** | < 100 ms | 用户操作响应 |

### 监控方法

```cpp
// 监控 FPS
void monitorFPS() {
    float fps = cocos2d::CCDirector::sharedDirector()->getAnimationInterval();
    printf("FPS: %.2f\n", 1.0f / fps);
}

// 监控内存
void monitorMemory() {
    CCTextureCache* cache = CCTextureCache::sharedTextureCache();
    printf("Texture count: %d\n", cache->textureCount());

    CCSpriteFrameCache* frameCache = CCSpriteFrameCache::sharedSpriteFrameCache();
    printf("Sprite frame count: %d\n", frameCache->spriteFrames()->count());
}
```

## CEGUI 性能优化

### UI 渲染优化

```cpp
// 1. 使用脏矩形技术（只更新变化的区域）
CEGUI::Window* window = CEGUI::WindowManager::getSingleton().getWindow("MyWindow");
window->setClippedByParent(true);  // 启用裁剪

// 2. 减少不必要的属性更新
void updateUI() {
    static std::string lastText;
    std::string newText = getCurrentText();
    if (newText != lastText) {
        window->setText(newText);
        lastText = newText;
    }
}

// 3. 批量更新 UI 属性
void batchUpdateUI() {
    // 暂停渲染
    CEGUI::System::getSingleton().setRenderingEnabled(false);

    // 批量更新
    window1->setProperty("Alpha", "0.8");
    window2->setProperty("Alpha", "0.8");
    window3->setProperty("Alpha", "0.8");

    // 恢复渲染
    CEGUI::System::getSingleton().setRenderingEnabled(true);
}
```

### 图片集优化

```cpp
// 1. 合并小图片到大的图片集
// 使用工具：tools/SplitImageset/SplitImageset.exe

// 2. 延迟加载图片集
void loadImagesetOnDemand(const std::string& name) {
    static std::set<std::string> loadedImagesets;
    if (loadedImagesets.find(name) == loadedImagesets.end()) {
        CEGUI::ImagesetManager::getSingleton().create(name + ".imageset");
        loadedImagesets.insert(name);
    }
}

// 3. 卸载未使用的图片集
void unloadUnusedImagesets() {
    CEGUI::ImagesetManager::getSingleton().destroyAll();
}
```

### 字体优化

```cpp
// 1. 使用字体缓存
CEGUI::FontManager::getSingleton().createFont("MyFont.font");

// 2. 避免频繁创建/销毁字体
// 使用预加载的字体，不要在运行时动态创建

// 3. 使用字体子集（只包含需要的字符）
// 在 .font 文件中指定字符范围
```

### 事件处理优化

```cpp
// 1. 使用事件委托而非直接订阅
class UIEventManager {
public:
    static UIEventManager& getInstance() {
        static UIEventManager instance;
        return instance;
    }

    void subscribe(const std::string& eventName, CEGUI::Event::Subscriber subscriber) {
        m_subscribers[eventName].push_back(subscriber);
    }

    void dispatch(const std::string& eventName, CEGUI::EventArgs& args) {
        auto it = m_subscribers.find(eventName);
        if (it != m_subscribers.end()) {
            for (auto& subscriber : it->second) {
                subscriber(args);
            }
        }
    }

private:
    std::map<std::string, std::vector<CEGUI::Event::Subscriber>> m_subscribers;
};

// 2. 避免在事件处理中执行耗时操作
void onButtonClicked(const CEGUI::EventArgs& args) {
    // 快速处理 UI 更新
    updateUI();

    // 将耗时操作推迟到下一帧
    scheduleHeavyTask();
}
```

## Cocos2d-x 性能优化

### 精灵批处理

```cpp
// 1. 使用 CCSpriteBatchNode 批量渲染相同纹理的精灵
CCSpriteBatchNode* batchNode = CCSpriteBatchNode::create("sprites.png");
this->addChild(batchNode);

// 添加精灵到批处理节点
CCSprite* sprite1 = CCSprite::createWithTexture(batchNode->getTexture());
sprite1->setPosition(ccp(100, 100));
batchNode->addChild(sprite1);

CCSprite* sprite2 = CCSprite::createWithTexture(batchNode->getTexture());
sprite2->setPosition(ccp(200, 100));
batchNode->addChild(sprite2);

// 2. 使用纹理图集减少绘制调用
CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("atlas.plist", "atlas.png");
```

### 动画优化

```cpp
// 1. 复用动画对象
CCAnimation* walkAnimation = CCAnimation::createWithSpriteFrames(frames, 0.1f);
CCAnimate* animate = CCAnimate::create(walkAnimation);

// 2. 使用动作池
class ActionPool {
public:
    static CCAnimate* getWalkAnimation() {
        static CCAnimate* s_walkAnimate = nullptr;
        if (!s_walkAnimate) {
            CCAnimation* animation = CCAnimation::createWithSpriteFrames(frames, 0.1f);
            s_walkAnimate = CCAnimate::create(animation);
            s_walkAnimate->retain();
        }
        return s_walkAnimate;
    }
};

// 3. 避免在 update 中创建动作
// 错误：每帧创建动作
void update(float delta) {
    sprite->runAction(CCMoveTo::create(1.0f, targetPos));  // 性能问题
}

// 正确：使用定时器或条件判断
void startMove() {
    sprite->runAction(CCMoveTo::create(1.0f, targetPos));
}
```

### 资源管理优化

```cpp
// 1. 异步加载资源
void loadResourcesAsync() {
    CCTextureCache::sharedTextureCache()->addImageAsync("background.png", this,
        callfuncO_selector(MyLayer::onTextureLoaded));
}

void onTextureLoaded(CCTexture2D* texture) {
    // 纹理加载完成
}

// 2. 预加载常用资源
void preloadResources() {
    CCTextureCache::sharedTextureCache()->addImage("common_ui.png");
    CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("common.plist", "common.png");
}

// 3. 释放未使用的资源
void releaseUnusedResources() {
    CCTextureCache::sharedTextureCache()->removeUnusedTextures();
    CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFrames();
}
```

### 调度优化

```cpp
// 1. 使用 scheduleUpdate 替代 schedule
// scheduleUpdate 比自定义 schedule 更高效
this->scheduleUpdate();

// 2. 避免频繁的 schedule/unschedule
// 错误：每帧重新调度
void update(float delta) {
    this->scheduleOnce(schedule_selector(MyLayer::doSomething), 1.0f);
}

// 正确：使用计时器
float m_timer = 0;
void update(float delta) {
    m_timer += delta;
    if (m_timer >= 1.0f) {
        doSomething();
        m_timer = 0;
    }
}

// 3. 减少调度频率
// 如果不需要每帧更新，可以降低频率
this->schedule(schedule_selector(MyLayer::update), 0.1f);  // 10 FPS
```

### 场景优化

```cpp
// 1. 使用场景缓存
class SceneCache {
public:
    static CCScene* getCachedScene(const std::string& name) {
        static std::map<std::string, CCScene*> s_cache;
        auto it = s_cache.find(name);
        if (it != s_cache.end()) {
            return it->second;
        }
        CCScene* scene = createScene(name);
        scene->retain();
        s_cache[name] = scene;
        return scene;
    }
};

// 2. 使用场景过渡效果
CCScene* newScene = MyScene::create();
CCTransitionFade* transition = CCTransitionFade::create(0.5f, newScene);
CCDirector::sharedDirector()->replaceScene(transition);

// 3. 避免在场景切换时创建大量对象
// 使用预加载或延迟加载
```

## Nuclear 引擎性能优化

### 特效优化

```cpp
// 1. 复用特效对象
class EffectPool {
public:
    static Nuclear::IEffect* getEffect(const std::string& name) {
        static std::map<std::string, std::vector<Nuclear::IEffect*>> s_pool;
        auto it = s_pool.find(name);
        if (it != s_pool.end() && !it->second.empty()) {
            Nuclear::IEffect* effect = it->second.back();
            it->second.pop_back();
            return effect;
        }
        return createNewEffect(name);
    }

    static void returnEffect(const std::string& name, Nuclear::IEffect* effect) {
        static std::map<std::string, std::vector<Nuclear::IEffect*>> s_pool;
        s_pool[name].push_back(effect);
    }
};

// 2. 批量更新特效
void updateEffects() {
    Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
    if (engine) {
        Nuclear::EffectManager* effectMan = engine->GetEffectManager();
        effectMan->UpdateAllEffects();
    }
}

// 3. 使用 LOD（细节层次）技术
// 根据距离使用不同精度的特效
```

### 渲染优化

```cpp
// 1. 减少渲染状态切换
// 将相同材质的对象一起渲染

// 2. 使用视锥剔除
// 只渲染视野内的对象

// 3. 使用脏矩形
// 只更新变化的区域
```

## 内存优化

### 对象池

```cpp
// 通用对象池模板
template<typename T>
class ObjectPool {
public:
    static ObjectPool& getInstance() {
        static ObjectPool instance;
        return instance;
    }

    T* acquire() {
        if (!m_pool.empty()) {
            T* obj = m_pool.back();
            m_pool.pop_back();
            return obj;
        }
        return new T();
    }

    void release(T* obj) {
        obj->reset();
        m_pool.push_back(obj);
    }

    void clear() {
        for (auto obj : m_pool) {
            delete obj;
        }
        m_pool.clear();
    }

private:
    std::vector<T*> m_pool;
};

// 使用示例
class Bullet {
public:
    void reset() {
        m_position = ccp(0, 0);
        m_velocity = ccp(0, 0);
        m_active = false;
    }

    CCPoint m_position;
    CCPoint m_velocity;
    bool m_active;
};

// 获取子弹
Bullet* bullet = ObjectPool<Bullet>::getInstance().acquire();
bullet->m_active = true;

// 释放子弹
ObjectPool<Bullet>::getInstance().release(bullet);
```

### 内存泄漏检测

```cpp
// 使用 Visual Studio 的 CRT 调试功能检测内存泄漏
#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>

// 在程序入口启用内存泄漏检测
_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);

// 在程序退出时检查内存泄漏
// 输出窗口会显示内存泄漏信息
```

## 性能分析工具

### Visual Studio 性能分析器

```powershell
# 使用 VS 性能分析器
# 1. 打开项目
# 2. 菜单：分析 > 性能分析器
# 3. 选择分析类型（CPU 使用率、内存使用量等）
# 4. 运行分析
# 5. 查看分析报告
```

### 自定义性能分析

```cpp
// 性能计时器
class PerformanceTimer {
public:
    PerformanceTimer(const std::string& name) : m_name(name) {
        m_start = std::chrono::high_resolution_clock::now();
    }

    ~PerformanceTimer() {
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - m_start);
        printf("%s: %lld us\n", m_name.c_str(), duration.count());
    }

private:
    std::string m_name;
    std::chrono::high_resolution_clock::time_point m_start;
};

// 使用示例
void updateScene() {
    PerformanceTimer timer("updateScene");
    // ... 更新场景代码
}
```

## 常见性能问题

### 问题：FPS 下降

**可能原因**：
- 渲染调用过多
- CPU 计算密集
- 内存分配频繁

**解决方案**：
- 使用批处理减少绘制调用
- 优化算法复杂度
- 使用对象池减少内存分配

### 问题：内存占用过高

**可能原因**：
- 资源未释放
- 内存泄漏
- 缓存过多

**解决方案**：
- 检查资源释放逻辑
- 使用内存泄漏检测工具
- 限制缓存大小

### 问题：加载时间长

**可能原因**：
- 同步加载大量资源
- 资源文件过大
- 磁盘 I/O 瓶颈

**解决方案**：
- 使用异步加载
- 压缩资源文件
- 使用资源分包

## 参考文档

- [公共约束](common-constraints.md)
- [Nuclear 集成](nuclear-integration.md)
- [资源管理](resource-management.md)
- [调试指南](debugging-commands.md)

# 故障排除指南 (Troubleshooting Guide)

## 目录 (Table of Contents)

- [编译问题](#编译问题-compilation-issues)
- [运行时错误](#运行时错误-runtime-errors)
- [性能问题](#性能问题-performance-issues)
- [内存问题](#内存问题-memory-issues)
- [图形渲染问题](#图形渲染问题-graphics-rendering-issues)
- [音频问题](#音频问题-audio-issues)
- [输入处理问题](#输入处理问题-input-handling-issues)
- [平台特定问题](#平台特定问题-platform-specific-issues)

---

## 编译问题 (Compilation Issues)

### 问题 1: 找不到头文件 (Issue 1: Cannot Find Header Files)

**症状**: 编译错误 "fatal error C1083: 无法打开包括文件"

**可能原因**:
- 包含目录配置不正确
- 头文件路径错误
- 项目依赖关系未正确设置

**解决方案**:

```cpp
// 检查项目属性中的包含目录
// 项目 -> 属性 -> C/C++ -> 常规 -> 附加包含目录

// 确保包含以下路径:
$(ProjectDir);$(ProjectDir)..\..\cocos2dx;$(ProjectDir)..\..\cocos2dx\include;$(ProjectDir)..\..\cocos2dx\platform;$(ProjectDir)..\..\cocos2dx\platform\win32;$(ProjectDir)..\..\cocos2dx\kazmath\include;$(ProjectDir)..\..\external;$(ProjectDir)..\..\external\chipmunk\include\chipmunk;
```

### 问题 2: 链接错误 (Issue 2: Linker Errors)

**症状**: 链接错误 "unresolved external symbol"

**可能原因**:
- 库文件路径配置不正确
- 缺少必要的库文件
- 库文件版本不匹配

**解决方案**:

```cpp
// 检查项目属性中的库目录
// 项目 -> 属性 -> 链接器 -> 常规 -> 附加库目录

// 确保包含以下路径:
$(OutDir);$(ProjectDir)..\..\external\lib\win32

// 检查附加依赖项
// 项目 -> 属性 -> 链接器 -> 输入 -> 附加依赖项

// 确保包含以下库:
libcocos2d.lib;libCocosDenshion.lib;glew32.lib;opengl32.lib;glu32.lib;winmm.lib;ws2_32.lib;iphlpapi.lib
```

### 问题 3: Visual Studio 版本不匹配 (Issue 3: Visual Studio Version Mismatch)

**症状**: 编译错误 "Platform Toolset not found"

**可能原因**:
- Visual Studio 版本不正确
- 平台工具集设置错误

**解决方案**:

```batch
# 确认 Visual Studio 2013 安装路径
D:\Program Files (x86)\Microsoft Visual Studio 12.0

# 设置平台工具集为 Visual Studio 2013 (v120)
# 项目 -> 属性 -> 配置属性 -> 常规 -> 平台工具集
# 选择: Visual Studio 2013 (v120)
```

### 问题 4: 字符集错误 (Issue 4: Character Set Errors)

**症状**: 编译错误 "cannot convert from 'const char *' to 'LPCWSTR'"

**可能原因**:
- 项目字符集设置不正确

**解决方案**:

```cpp
// 项目 -> 属性 -> 配置属性 -> 项目默认值 -> 字符集
// 选择: 使用多字节字符集 (Use Multi-Byte Character Set)
```

---

## 运行时错误 (Runtime Errors)

### 问题 1: 空指针访问 (Issue 1: Null Pointer Access)

**症状**: 程序崩溃，访问违规

**可能原因**:
- 未初始化的指针
- 已释放的指针被访问
- 返回 NULL 的函数未检查

**解决方案**:

```cpp
// 正确: 检查指针是否为 NULL
void MyClass::setSprite(CCSprite* sprite) {
    if (sprite == NULL) {
        CCLog("Error: sprite is NULL");
        return;
    }
    
    m_pSprite = sprite;
    m_pSprite->retain();
}

// 正确: 使用 CCAssert 进行断言检查
void MyClass::updateSprite() {
    CCAssert(m_pSprite != NULL, "m_pSprite cannot be NULL");
    m_pSprite->update(dt);
}
```

### 问题 2: 内存泄漏 (Issue 2: Memory Leaks)

**症状**: 程序运行时间越长，内存占用越高

**可能原因**:
- 对象创建后未释放
- 循环引用
- retain() 和 release() 不匹配

**解决方案**:

```cpp
// 正确: 在析构函数中释放资源
MyClass::~MyClass() {
    CC_SAFE_RELEASE_NULL(m_pSprite);
    CC_SAFE_RELEASE_NULL(m_pTarget);
}

// 正确: 使用智能指针
#include <memory>

class MyClass {
    std::unique_ptr<CCSprite> m_pSprite;
public:
    MyClass() {
        m_pSprite.reset(CCSprite::create("sprite.png"));
    }
};
```

### 问题 3: 断言失败 (Issue 3: Assertion Failures)

**症状**: 程序在 CCAssert 处崩溃

**可能原因**:
- 前置条件未满足
- 逻辑错误

**解决方案**:

```cpp
// 检查断言失败的原因
CCAssert(sprite != NULL, "sprite cannot be NULL");

// 添加更多调试信息
if (sprite == NULL) {
    CCLog("Error: sprite is NULL at line %d in file %s", __LINE__, __FILE__);
    return;
}
```

---

## 性能问题 (Performance Issues)

### 问题 1: 帧率低 (Issue 1: Low Frame Rate)

**症状**: 游戏运行卡顿，帧率低于 60 FPS

**可能原因**:
- 绘制调用过多
- 纹理未优化
- 动作过多
- 物理模拟计算量大

**解决方案**:

```cpp
// 正确: 使用 CCSpriteBatchNode 批处理精灵
CCSpriteBatchNode* batch = CCSpriteBatchNode::create("sprites.png");
this->addChild(batch);

// 正确: 使用纹理图集
CCTextureCache::sharedTextureCache()->addImageAsync("atlas.png", this, 
    callfuncO_selector(MyClass::textureLoaded));

// 正确: 释放不用的纹理
CCTextureCache::sharedTextureCache()->removeUnusedTextures();

// 正确: 使用对象池
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

### 问题 2: 加载时间过长 (Issue 2: Long Loading Time)

**症状**: 游戏启动或场景切换时加载时间过长

**可能原因**:
- 资源文件过大
- 同步加载资源
- 未使用压缩格式

**解决方案**:

```cpp
// 正确: 异步加载资源
CCTextureCache::sharedTextureCache()->addImageAsync("background.png", 
    this, callfuncO_selector(MyClass::textureLoaded));

// 正确: 使用压缩纹理格式
CCTexture2D* texture = CCTextureCache::sharedTextureCache()
    ->addImage("texture.pvr.ccz");

// 正确: 预加载资源
void preloadResources() {
    CCTextureCache::sharedTextureCache()->addImage("player.png");
    CCTextureCache::sharedTextureCache()->addImage("enemy.png");
}
```

---

## 内存问题 (Memory Issues)

### 问题 1: 内存占用过高 (Issue 1: High Memory Usage)

**症状**: 程序内存占用远超预期

**可能原因**:
- 纹理未释放
- 对象未清理
- 资源重复加载

**解决方案**:

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

### 问题 2: 内存碎片 (Issue 2: Memory Fragmentation)

**症状**: 内存分配失败，即使总内存足够

**可能原因**:
- 频繁的内存分配和释放
- 对象大小不一

**解决方案**:

```cpp
// 正确: 使用对象池减少内存分配
class ObjectPool {
    std::vector<void*> m_pObjects;
    size_t m_nObjectSize;
public:
    ObjectPool(size_t objectSize, size_t initialCount) : m_nObjectSize(objectSize) {
        for (size_t i = 0; i < initialCount; ++i) {
            void* obj = malloc(m_nObjectSize);
            m_pObjects.push_back(obj);
        }
    }
    
    void* allocate() {
        if (m_pObjects.empty()) {
            return malloc(m_nObjectSize);
        }
        void* obj = m_pObjects.back();
        m_pObjects.pop_back();
        return obj;
    }
    
    void deallocate(void* obj) {
        m_pObjects.push_back(obj);
    }
};
```

---

## 图形渲染问题 (Graphics Rendering Issues)

### 问题 1: 纹理显示不正确 (Issue 1: Incorrect Texture Display)

**症状**: 纹理显示为黑色或白色方块

**可能原因**:
- 纹理加载失败
- 纹理格式不支持
- 纹理尺寸不符合要求

**解决方案**:

```cpp
// 正确: 检查纹理是否加载成功
CCTexture2D* texture = CCTextureCache::sharedTextureCache()->addImage("texture.png");
if (texture == NULL) {
    CCLog("Failed to load texture: texture.png");
    return;
}

// 正确: 检查纹理尺寸
CCSize textureSize = texture->getContentSize();
if (textureSize.width == 0 || textureSize.height == 0) {
    CCLog("Invalid texture size: (%.2f, %.2f)", textureSize.width, textureSize.height);
    return;
}
```

### 问题 2: 渲染顺序错误 (Issue 2: Incorrect Rendering Order)

**症状**: 对象显示顺序不正确

**可能原因**:
- z-order 设置错误
- 节点层级关系不正确

**解决方案**:

```cpp
// 正确: 设置 z-order 控制渲染顺序
this->addChild(background, 0);
this->addChild(player, 1);
this->addChild(enemy, 2);
this->addChild(hud, 10);

// 正确: 使用 reorderChild 调整顺序
this->reorderChild(sprite, 5);
```

### 问题 3: 精灵批处理失效 (Issue 3: Sprite Batching Not Working)

**症状**: 绘制调用数量过多

**可能原因**:
- 精灵使用了不同的纹理
- 精灵使用了不同的混合模式
- 精灵不在同一个 CCSpriteBatchNode 中

**解决方案**:

```cpp
// 正确: 确保所有精灵使用相同的纹理
CCSpriteBatchNode* batch = CCSpriteBatchNode::create("sprites.png");
this->addChild(batch);

// 所有精灵必须使用相同的纹理
CCSprite* sprite1 = CCSprite::createWithTexture(batch->getTexture());
CCSprite* sprite2 = CCSprite::createWithTexture(batch->getTexture());

batch->addChild(sprite1);
batch->addChild(sprite2);
```

---

## 音频问题 (Audio Issues)

### 问题 1: 音频无法播放 (Issue 1: Audio Not Playing)

**症状**: 音频文件无法播放

**可能原因**:
- 音频文件路径错误
- 音频格式不支持
- 音频设备未初始化

**解决方案**:

```cpp
// 正确: 检查音频文件是否存在
bool fileExists = CCFileUtils::sharedFileUtils()->isFileExist("sound.mp3");
if (!fileExists) {
    CCLog("Audio file not found: sound.mp3");
    return;
}

// 正确: 使用支持的音频格式
// 支持的格式: mp3, wav, mid, ogg
SimpleAudioEngine::sharedEngine()->playBackgroundMusic("background.mp3", true);
SimpleAudioEngine::sharedEngine()->playEffect("effect.wav");
```

### 问题 2: 音频延迟 (Issue 2: Audio Latency)

**症状**: 音频播放有延迟

**可能原因**:
- 音频文件过大
- 音频缓冲区设置不当

**解决方案**:

```cpp
// 正确: 预加载音频
SimpleAudioEngine::sharedEngine()->preloadBackgroundMusic("background.mp3");
SimpleAudioEngine::sharedEngine()->preloadEffect("effect.wav");

// 正确: 使用适当的音频格式
// mp3: 适合背景音乐，文件小
// wav: 适合音效，延迟低
SimpleAudioEngine::sharedEngine()->playBackgroundMusic("background.mp3", true);
SimpleAudioEngine::sharedEngine()->playEffect("effect.wav");
```

---

## 输入处理问题 (Input Handling Issues)

### 问题 1: 触摸事件不响应 (Issue 1: Touch Events Not Responding)

**症状**: 触摸屏幕无响应

**可能原因**:
- 触摸事件未注册
- 触摸优先级设置错误
- 节点不可见或不可交互

**解决方案**:

```cpp
// 正确: 注册触摸事件
void GameLayer::onEnter() {
    CCLayer::onEnter();
    
    CCDirector::sharedDirector()->getTouchDispatcher()
        ->addTargetedDelegate(this, 0, true);
}

void GameLayer::onExit() {
    CCDirector::sharedDirector()->getTouchDispatcher()
        ->removeDelegate(this);
    
    CCLayer::onExit();
}

// 正确: 实现触摸事件处理方法
bool GameLayer::ccTouchBegan(CCTouch* touch, CCEvent* event) {
    CCPoint location = touch->getLocation();
    CCLog("Touch began at: (%.2f, %.2f)", location.x, location.y);
    return true;
}
```

### 问题 2: 键盘事件不响应 (Issue 2: Keyboard Events Not Responding)

**症状**: 键盘输入无响应

**可能原因**:
- 键盘事件未注册
- 键盘焦点未设置

**解决方案**:

```cpp
// 正确: 注册键盘事件
void GameLayer::onEnter() {
    CCLayer::onEnter();
    
    this->setKeypadEnabled(true);
}

void GameLayer::keyBackClicked() {
    CCLog("Back button clicked");
    CCDirector::sharedDirector()->popScene();
}

void GameLayer::keyMenuClicked() {
    CCLog("Menu button clicked");
}
```

---

## 平台特定问题 (Platform Specific Issues)

### 问题 1: Windows 平台特定问题 (Issue 1: Windows Platform Specific Issues)

**症状**: Windows 平台特有的问题

**可能原因**:
- 路径分隔符问题
- 编码问题
- DirectX 版本问题

**解决方案**:

```cpp
// 正确: 使用跨平台路径处理
std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("data.json");

// 正确: 使用 UTF-8 编码
std::string content = CCFileUtils::sharedFileUtils()->getStringFromFile(path);

// 正确: 检查 DirectX 版本
// 确保安装了 DirectX 9.0c 或更高版本
```

### 问题 2: 屏幕分辨率问题 (Issue 2: Screen Resolution Issues)

**症状**: 游戏在不同分辨率下显示不正确

**可能原因**:
- 未适配不同分辨率
- 固定尺寸设计

**解决方案**:

```cpp
// 正确: 使用相对坐标
CCPoint pos = ccp(0.5f, 0.5f);
CCSize winSize = CCDirector::sharedDirector()->getWinSize();
sprite->setPosition(ccp(winSize.width * pos.x, winSize.height * pos.y));

// 正确: 使用设计分辨率
CCEGLView* view = CCEGLView::sharedOpenGLView();
view->setDesignResolutionSize(960, 640, kResolutionNoBorder);
```

---

## 快速参考 (Quick Reference)

### 常见错误代码 (Common Error Codes)

| 错误代码 | 描述 | 解决方案 |
|---------|------|---------|
| C1083 | 找不到头文件 | 检查包含目录配置 |
| LNK2019 | 链接错误 | 检查库文件配置 |
| 0xC0000005 | 访问违规 | 检查空指针访问 |
| 0xC0000409 | 堆栈缓冲区溢出 | 检查数组边界 |

### 调试技巧 (Debugging Tips)

1. **使用 CCLog 输出调试信息**
   ```cpp
   CCLog("Debug info: %s", message);
   ```

2. **使用断点调试**
   - 在 Visual Studio 中设置断点
   - 查看变量值
   - 单步执行代码

3. **使用性能分析器**
   - 使用 Visual Studio 性能分析器
   - 查找性能瓶颈

4. **检查内存泄漏**
   - 使用 Visual Studio 内存诊断工具
   - 检查对象引用计数

---

## 相关文档 (Related Documentation)

- [开发编译构建指南](09_开发编译构建指南__Development-and-Build-Guide.md)
- [最佳实践指南](10_最佳实践指南__Best-Practices-Guide.md)
- [核心类架构](02_核心类架构__Core-Classes-Architecture.md)
- [关键实现细节](04_关键实现细节与代码示例__Key-Implementation-Details.md)
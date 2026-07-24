---
name: cocos2dx-usage
version: 1.4.0
priority: medium
category: client
description: |
  Cocos2d-x 2.0游戏引擎使用技能。涵盖节点系统、精灵动画、动作系统、触摸事件和渲染优化。
  触发词: Cocos2d-x, 精灵, 动画, CCSprite, CCAction, 场景, 渲染, 节点, CCScene, CCLayer, CCDirector, CCNode, CCTexture2D, CCGLProgram, OpenGL, 批量渲染, CCSpriteBatchNode
dependencies:
  - cpp-development
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 10000
---

# Cocos2d-x 2.0 使用技能 (MT3 客户端)

**版本**: v1.4.0
**最后更新**: 2026-04-11

---

## 🎯 Cocos2d-x 2.0 概述

### 版本说明

MT3 项目使用 **Cocos2d-x 2.0-rc2-x-2.0.1**（2012年左右版本）：
- ⚠️ 这是一个老版本，与最新的 Cocos2d-x 3.x/4.x 不兼容
- ✅ API 稳定，已在生产环境验证多年
- ⚠️ 网上大部分教程是基于 3.x 版本，需要注意区别
- ⚠️ Win32 平台使用原生 OpenGL 2.0，非 OpenGL ES；Android/iOS 使用 OpenGL ES

### 核心特性

- **场景管理**: CCScene / CCLayer / CCDirector
- **精灵系统**: CCSprite / CCSpriteBatchNode
- **动作系统**: CCAction / CCAnimation
- **事件系统**: CCTouchDelegate / CCKeyboardDelegate
- **音频引擎**: CocosDenshion (SimpleAudioEngine)
- **粒子系统**: CCParticleSystem
- **UI 组件**: CCMenu / CCLabelTTF

---

## 🏗️ 核心类详解

### 1. CCNode - 节点基类

**职责**: 所有可见对象的基类

**核心属性**:
```cpp
// 位置和变换
void setPosition(const CCPoint& position);
CCPoint getPosition() const;

void setScale(float scale);
void setScaleX(float scaleX);
void setScaleY(float scaleY);

void setRotation(float rotation);

// 可见性和层级
void setVisible(bool visible);
bool isVisible() const;

void setZOrder(int zOrder);
int getZOrder() const;

// 父子关系
void addChild(CCNode* child);
void addChild(CCNode* child, int zOrder);
void removeChild(CCNode* child, bool cleanup);
void removeAllChildren();
```

**常用方法**:
```cpp
// 定时更新
void scheduleUpdate();
void unscheduleUpdate();
virtual void update(float dt); // 重写此方法

// 动作控制
CCAction* runAction(CCAction* action);
void stopAction(CCAction* action);
void stopAllActions();

// 坐标转换
CCPoint convertToNodeSpace(const CCPoint& worldPoint);
CCPoint convertToWorldSpace(const CCPoint& nodePoint);
```

---

### 2. CCSprite - 精灵类

**职责**: 显示纹理、图片的核心类

**创建精灵**:
```cpp
// 方法1: 从文件创建
CCSprite* sprite = CCSprite::create("player.png");

// 方法2: 从纹理创建
CCTexture2D* texture = CCTextureCache::sharedTextureCache()->addImage("player.png");
CCSprite* sprite = CCSprite::createWithTexture(texture);

// 方法3: 从精灵帧创建 (适用于精灵表)
CCSpriteFrame* frame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName("player_01.png");
CCSprite* sprite = CCSprite::createWithSpriteFrame(frame);

// 设置位置并添加到层
sprite->setPosition(ccp(100, 100));
layer->addChild(sprite);
```

**纹理矩形**:
```cpp
// 设置纹理矩形 (裁剪显示区域)
sprite->setTextureRect(CCRectMake(0, 0, 64, 64));

// 设置锚点 (默认 (0.5, 0.5) 中心)
sprite->setAnchorPoint(ccp(0, 0));  // 左下角
sprite->setAnchorPoint(ccp(1, 1));  // 右上角
```

**颜色和透明度**:
```cpp
// 设置透明度 (0-255)
sprite->setOpacity(128);  // 半透明

// 设置颜色 (RGB)
sprite->setColor(ccc3(255, 0, 0));  // 红色

// 混合模式
ccBlendFunc blendFunc = {GL_SRC_ALPHA, GL_ONE};
sprite->setBlendFunc(blendFunc);
```

---

### 3. CCLayer - 层类

**职责**: 场景的容器，处理输入事件

**创建层**:
```cpp
class GameLayer : public CCLayer
{
public:
    virtual bool init();
    CREATE_FUNC(GameLayer);

    // 触摸事件
    virtual void ccTouchesBegan(CCSet* touches, CCEvent* event);
    virtual void ccTouchesMoved(CCSet* touches, CCEvent* event);
    virtual void ccTouchesEnded(CCSet* touches, CCEvent* event);

    // 更新函数
    virtual void update(float dt);
};

bool GameLayer::init()
{
    if (!CCLayer::init())
        return false;

    // 启用触摸
    this->setTouchEnabled(true);

    // 启用更新
    this->scheduleUpdate();

    return true;
}
```

**触摸事件处理**:
```cpp
void GameLayer::ccTouchesBegan(CCSet* touches, CCEvent* event)
{
    CCTouch* touch = (CCTouch*)touches->anyObject();
    CCPoint location = touch->getLocation();

    CCLOG("Touch began at: (%f, %f)", location.x, location.y);

    // 判断是否点击了精灵
    if (m_pSprite->boundingBox().containsPoint(location))
    {
        // 精灵被点击
    }
}
```

---

### 4. CCScene - 场景类

**职责**: 游戏场景的根容器

**创建场景**:
```cpp
CCScene* GameScene::scene()
{
    CCScene* scene = CCScene::create();
    GameLayer* layer = GameLayer::create();
    scene->addChild(layer);
    return scene;
}

// 在其他地方切换到这个场景
CCDirector::sharedDirector()->replaceScene(GameScene::scene());
```

**场景切换效果**:
```cpp
// 淡入淡出
CCScene* nextScene = GameScene::scene();
CCTransitionFade* transition = CCTransitionFade::create(1.0f, nextScene);
CCDirector::sharedDirector()->replaceScene(transition);

// 其他常用转场效果
CCTransitionSlideInL::create(1.0f, nextScene);  // 从左滑入
CCTransitionSlideInR::create(1.0f, nextScene);  // 从右滑入
CCTransitionSlideInT::create(1.0f, nextScene);  // 从上滑入
CCTransitionSlideInB::create(1.0f, nextScene);  // 从下滑入
CCTransitionFlipX::create(1.0f, nextScene);     // X轴翻转
CCTransitionFlipY::create(1.0f, nextScene);     // Y轴翻转
```

---

### 5. CCDirector - 导演类（单例）

**职责**: 管理场景切换、渲染、帧率等

**常用方法**:
```cpp
// 获取单例
CCDirector* director = CCDirector::sharedDirector();

// 场景管理
director->runWithScene(scene);     // 运行第一个场景
director->replaceScene(scene);     // 替换当前场景
director->pushScene(scene);        // 压栈场景
director->popScene();              // 弹出场景

// 获取屏幕尺寸
CCSize winSize = director->getWinSize();
CCLOG("Window size: %f x %f", winSize.width, winSize.height);

// 帧率控制
director->setAnimationInterval(1.0f / 60);  // 60 FPS
```

---

## 🎬 动作系统 (CCAction)

### 基础动作

```cpp
// 1. 移动动作
CCMoveTo* moveTo = CCMoveTo::create(2.0f, ccp(200, 200));
sprite->runAction(moveTo);

CCMoveBy* moveBy = CCMoveBy::create(1.0f, ccp(100, 0));
sprite->runAction(moveBy);

// 2. 缩放动作
CCScaleTo* scaleTo = CCScaleTo::create(1.0f, 2.0f);  // 放大2倍
sprite->runAction(scaleTo);

CCScaleBy* scaleBy = CCScaleBy::create(1.0f, 1.5f);
sprite->runAction(scaleBy);

// 3. 旋转动作
CCRotateTo* rotateTo = CCRotateTo::create(2.0f, 360.0f);
sprite->runAction(rotateTo);

// 4. 淡入淡出
CCFadeIn* fadeIn = CCFadeIn::create(1.0f);
CCFadeOut* fadeOut = CCFadeOut::create(1.0f);
sprite->runAction(fadeOut);

// 5. 闪烁
CCBlink* blink = CCBlink::create(3.0f, 10);  // 3秒内闪烁10次
sprite->runAction(blink);
```

### 组合动作

```cpp
// 顺序执行
CCAction* action1 = CCMoveTo::create(1.0f, ccp(100, 100));
CCAction* action2 = CCScaleTo::create(1.0f, 2.0f);
CCAction* action3 = CCRotateTo::create(1.0f, 360.0f);
CCSequence* sequence = CCSequence::create(action1, action2, action3, NULL);
sprite->runAction(sequence);

// 同时执行
CCSpawn* spawn = CCSpawn::create(
    CCMoveTo::create(2.0f, ccp(200, 200)),
    CCScaleTo::create(2.0f, 3.0f),
    CCRotateTo::create(2.0f, 360.0f),
    NULL
);
sprite->runAction(spawn);

// 重复动作
CCRepeat* repeat = CCRepeat::create(moveBy, 5);  // 重复5次
sprite->runAction(repeat);

CCRepeatForever* repeatForever = CCRepeatForever::create(rotate);
sprite->runAction(repeatForever);

// 延迟动作
CCDelayTime* delay = CCDelayTime::create(2.0f);
CCSequence* seq = CCSequence::create(delay, action, NULL);
sprite->runAction(seq);
```

### 回调动作

```cpp
// 方法1: 使用 CCCallFunc
void GameLayer::onActionComplete()
{
    CCLOG("Action completed!");
}

CCCallFunc* callback = CCCallFunc::create(this, callfunc_selector(GameLayer::onActionComplete));
CCSequence* seq = CCSequence::create(action, callback, NULL);
sprite->runAction(seq);

// 方法2: 使用 CCCallFuncN (带节点参数)
void GameLayer::onSpriteActionComplete(CCNode* node)
{
    CCSprite* sprite = (CCSprite*)node;
    sprite->setVisible(false);
}

CCCallFuncN* callback = CCCallFuncN::create(this, callfuncN_selector(GameLayer::onSpriteActionComplete));
CCSequence* seq = CCSequence::create(action, callback, NULL);
sprite->runAction(seq);
```

### 缓动函数 (Easing)

```cpp
// 加速
CCEaseIn* easeIn = CCEaseIn::create(move, 2.0f);
sprite->runAction(easeIn);

// 减速
CCEaseOut* easeOut = CCEaseOut::create(move, 2.0f);
sprite->runAction(easeOut);

// 先加速后减速
CCEaseInOut* easeInOut = CCEaseInOut::create(move, 2.0f);
sprite->runAction(easeInOut);

// 弹性效果
CCEaseElasticOut* elastic = CCEaseElasticOut::create(move);
sprite->runAction(elastic);

// 回弹效果
CCEaseBounceOut* bounce = CCEaseBounceOut::create(move);
sprite->runAction(bounce);
```

---

## 🎨 帧动画

### 使用精灵帧

```cpp
// 1. 加载精灵表
CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("player.plist");

// 2. 创建动画帧数组
CCArray* frames = CCArray::create();
for (int i = 1; i <= 8; i++)
{
    char frameName[32];
    sprintf(frameName, "player_run_%02d.png", i);
    CCSpriteFrame* frame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName(frameName);
    frames->addObject(frame);
}

// 3. 创建动画
CCAnimation* animation = CCAnimation::createWithSpriteFrames(frames, 0.1f);  // 每帧0.1秒

// 4. 创建动画动作
CCAnimate* animate = CCAnimate::create(animation);

// 5. 循环播放
CCRepeatForever* repeatForever = CCRepeatForever::create(animate);
sprite->runAction(repeatForever);
```

### 手动切换帧

```cpp
// 切换到指定帧
CCSpriteFrame* frame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName("player_01.png");
sprite->setDisplayFrame(frame);
```

---

## 📅 调度器和定时器

### 定时更新

```cpp
// 方法1: 使用 update
void GameLayer::update(float dt)
{
    // 每帧调用
    m_time += dt;
}

// 启用
this->scheduleUpdate();

// 禁用
this->unscheduleUpdate();
```

### 自定义定时器

```cpp
// 方法2: 使用自定义选择器
void GameLayer::customUpdate(float dt)
{
    CCLOG("Custom update called, dt = %f", dt);
}

// 每0.5秒调用一次
this->schedule(schedule_selector(GameLayer::customUpdate), 0.5f);

// 延迟2秒后开始，每1秒调用一次
this->schedule(schedule_selector(GameLayer::customUpdate), 1.0f, kCCRepeatForever, 2.0f);

// 停止定时器
this->unschedule(schedule_selector(GameLayer::customUpdate));
```

### 一次性定时器

```cpp
void GameLayer::onTimeout(float dt)
{
    CCLOG("Timeout!");
}

// 3秒后调用一次
this->scheduleOnce(schedule_selector(GameLayer::onTimeout), 3.0f);
```

---

## 🎵 音频引擎

### 背景音乐

```cpp
#include "SimpleAudioEngine.h"
using namespace CocosDenshion;

// 播放背景音乐
SimpleAudioEngine::sharedEngine()->playBackgroundMusic("background.mp3", true);  // 循环播放

// 停止背景音乐
SimpleAudioEngine::sharedEngine()->stopBackgroundMusic();

// 暂停/恢复
SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();

// 音量控制 (0.0 - 1.0)
SimpleAudioEngine::sharedEngine()->setBackgroundMusicVolume(0.5f);
```

### 音效

```cpp
// 预加载音效
SimpleAudioEngine::sharedEngine()->preloadEffect("hit.wav");

// 播放音效
unsigned int effectID = SimpleAudioEngine::sharedEngine()->playEffect("hit.wav");

// 停止音效
SimpleAudioEngine::sharedEngine()->stopEffect(effectID);

// 停止所有音效
SimpleAudioEngine::sharedEngine()->stopAllEffects();

// 音效音量
SimpleAudioEngine::sharedEngine()->setEffectsVolume(0.8f);
```

---

## 🎆 粒子系统

### 内置粒子效果

```cpp
// 创建粒子系统
CCParticleSystem* emitter = CCParticleFire::create();  // 火焰
// CCParticleFireworks::create();  // 烟花
// CCParticleExplosion::create();  // 爆炸
// CCParticleSmoke::create();      // 烟雾
// CCParticleSnow::create();       // 雪花
// CCParticleRain::create();       // 雨

emitter->setPosition(ccp(200, 200));
this->addChild(emitter);
```

### 自定义粒子

```cpp
// 从 plist 文件加载
CCParticleSystem* emitter = CCParticleSystemQuad::create("MyParticle.plist");
emitter->setPosition(ccp(100, 100));
this->addChild(emitter);

// 修改参数
emitter->setEmissionRate(100);        // 发射速率
emitter->setLife(2.0f);                // 粒子生命周期
emitter->setStartSize(32.0f);          // 起始大小
emitter->setEndSize(8.0f);             // 结束大小
emitter->setStartColor(ccc4f(1, 0, 0, 1));  // 起始颜色
emitter->setEndColor(ccc4f(1, 1, 0, 0.5f)); // 结束颜色
```

---

## 🖱️ UI 组件

### 菜单 (CCMenu)

```cpp
// 创建菜单项
CCMenuItemImage* item1 = CCMenuItemImage::create(
    "btn_normal.png",
    "btn_selected.png",
    this,
    menu_selector(GameLayer::onStartClicked)
);

CCMenuItemImage* item2 = CCMenuItemImage::create(
    "btn_quit_normal.png",
    "btn_quit_selected.png",
    this,
    menu_selector(GameLayer::onQuitClicked)
);

// 创建菜单
CCMenu* menu = CCMenu::create(item1, item2, NULL);
menu->alignItemsVerticallyWithPadding(20.0f);  // 垂直排列，间距20
this->addChild(menu);

// 回调函数
void GameLayer::onStartClicked(CCObject* sender)
{
    CCLOG("Start button clicked");
}
```

### 文本标签 (CCLabelTTF)

```cpp
// 创建文本标签
CCLabelTTF* label = CCLabelTTF::create(
    "Hello World",
    "Arial",
    24
);
label->setPosition(ccp(200, 200));
this->addChild(label);

// 修改文本
label->setString("New Text");

// 修改颜色
label->setColor(ccc3(255, 0, 0));
```

---

## ⚠️ 内存管理

### 引用计数

Cocos2d-x 2.0 使用引用计数进行内存管理：

```cpp
// 创建对象时，引用计数 = 1，且已 autorelease
CCSprite* sprite = CCSprite::create("player.png");

// 添加到父节点时，父节点会 retain，引用计数 +1
this->addChild(sprite);

// 从父节点移除时，父节点会 release，引用计数 -1
this->removeChild(sprite);

// 手动 retain/release
sprite->retain();   // 引用计数 +1
sprite->release();  // 引用计数 -1
```

### 最佳实践

```cpp
// ✅ 推荐：使用 create 方法
CCSprite* sprite = CCSprite::create("player.png");
this->addChild(sprite);
// 不需要手动 release

// ❌ 避免：使用 new
CCSprite* sprite = new CCSprite();
sprite->initWithFile("player.png");
sprite->autorelease();  // 必须调用 autorelease
this->addChild(sprite);

// ❌ 避免：成员变量直接保存
class GameLayer : public CCLayer {
private:
    CCSprite* m_pSprite;  // 危险！
};

// ✅ 推荐：成员变量需要 retain
void GameLayer::init() {
    m_pSprite = CCSprite::create("player.png");
    m_pSprite->retain();  // 保持引用
    this->addChild(m_pSprite);
}

void GameLayer::~GameLayer() {
    CC_SAFE_RELEASE(m_pSprite);  // 释放引用
}
```

---

## 🚀 性能优化

### 1. 使用批次渲染

```cpp
// ❌ 低效：每个精灵单独渲染
for (int i = 0; i < 100; i++) {
    CCSprite* sprite = CCSprite::create("bullet.png");
    sprite->setPosition(ccp(i * 10, 100));
    this->addChild(sprite);
}

// ✅ 高效：使用 SpriteBatchNode
CCSpriteBatchNode* batchNode = CCSpriteBatchNode::create("bullet.png");
this->addChild(batchNode);

for (int i = 0; i < 100; i++) {
    CCSprite* sprite = CCSprite::createWithTexture(batchNode->getTexture());
    sprite->setPosition(ccp(i * 10, 100));
    batchNode->addChild(sprite);
}
```

### 2. 纹理缓存

```cpp
// 预加载纹理
CCTextureCache::sharedTextureCache()->addImage("player.png");

// 清理未使用的纹理
CCTextureCache::sharedTextureCache()->removeUnusedTextures();
```

### 3. 对象池

```cpp
// 重用精灵而不是频繁创建和销毁
class BulletPool {
private:
    CCArray* m_pool;
public:
    CCSprite* getBullet() {
        if (m_pool->count() > 0) {
            CCSprite* bullet = (CCSprite*)m_pool->lastObject();
            m_pool->removeLastObject();
            return bullet;
        }
        return CCSprite::create("bullet.png");
    }

    void returnBullet(CCSprite* bullet) {
        bullet->stopAllActions();
        bullet->setVisible(false);
        m_pool->addObject(bullet);
    }
};
```

---

## ⚠️ 常见陷阱

### 1. 忘记调用 autorelease

```cpp
// ❌ 错误
CCSprite* sprite = new CCSprite();
sprite->initWithFile("player.png");
this->addChild(sprite);  // 内存泄漏！

// ✅ 正确
CCSprite* sprite = new CCSprite();
sprite->initWithFile("player.png");
sprite->autorelease();  // 必须调用
this->addChild(sprite);

// ✅ 更好：使用 create
CCSprite* sprite = CCSprite::create("player.png");
this->addChild(sprite);
```

### 2. 在回调中访问已释放的对象

```cpp
// ❌ 危险
void GameLayer::delayedAction() {
    CCSprite* sprite = CCSprite::create("player.png");
    this->addChild(sprite);

    CCCallFunc* callback = CCCallFunc::create(this, callfunc_selector(GameLayer::removeSprite));
    CCSequence* seq = CCSequence::create(CCDelayTime::create(5.0f), callback, NULL);
    this->runAction(seq);
}

void GameLayer::removeSprite() {
    // sprite 已经不在作用域内！
}

// ✅ 正确：使用成员变量
void GameLayer::delayedAction() {
    m_pSprite = CCSprite::create("player.png");
    m_pSprite->retain();
    this->addChild(m_pSprite);

    CCCallFunc* callback = CCCallFunc::create(this, callfunc_selector(GameLayer::removeSprite));
    CCSequence* seq = CCSequence::create(CCDelayTime::create(5.0f), callback, NULL);
    this->runAction(seq);
}

void GameLayer::removeSprite() {
    if (m_pSprite) {
        this->removeChild(m_pSprite);
        CC_SAFE_RELEASE_NULL(m_pSprite);
    }
}
```

### 3. 坐标系混淆

```cpp
// Cocos2d-x 坐标系：左下角为原点 (0, 0)
// Windows/iOS 坐标系：左上角为原点

// 触摸坐标已经转换为 Cocos2d-x 坐标系
CCPoint location = touch->getLocation();

// 如果需要转换到节点本地坐标
CCPoint localPoint = sprite->convertToNodeSpace(location);
```

### 4. 过度使用 update

```cpp
// ❌ 低效：每帧检查状态
void GameLayer::update(float dt) {
    if (m_isGameOver) {
        // 切换场景
    }
}

// ✅ 高效：在状态改变时立即处理
void GameLayer::setGameOver() {
    m_isGameOver = true;
    // 立即切换场景
    CCDirector::sharedDirector()->replaceScene(GameOverScene::scene());
}
```

---

## 🎯 实践项目

### 初级项目：简单场景和精灵 (3-5天)

**目标**: 创建一个简单的游戏场景，包含背景、角色精灵和基本动画

**任务**:
1. 创建 GameScene 和 GameLayer
2. 添加背景精灵
3. 添加角色精灵并播放动画
4. 实现触摸移动角色
5. 添加背景音乐和音效

**检查点**:
- [ ] 场景能够正常显示
- [ ] 精灵能够响应触摸事件
- [ ] 动画播放流畅
- [ ] 音频正常播放

---

### 中级项目：角色动画和AI (1-2周)

**目标**: 实现角色的行走、攻击动画，以及简单的 AI 逻辑

**任务**:
1. 加载精灵表，创建角色动画
2. 实现状态机（待机、行走、攻击）
3. 添加敌人 AI（巡逻、追击、攻击）
4. 实现碰撞检测
5. 添加技能特效（粒子系统）

**检查点**:
- [ ] 角色状态切换流畅
- [ ] 敌人 AI 行为正确
- [ ] 碰撞检测准确
- [ ] 特效显示正常

---

### 高级项目：完整的战斗系统 (2-4周)

**目标**: 实现一个完整的战斗系统，包括技能、特效、UI等

**任务**:
1. 设计技能系统架构
2. 实现技能释放和CD管理
3. 添加伤害计算和显示
4. 实现 buff/debuff 系统
5. 创建技能特效和动画
6. 优化性能（对象池、批次渲染）

**检查点**:
- [ ] 技能系统完整且可扩展
- [ ] 伤害计算准确
- [ ] buff 系统工作正常
- [ ] 性能达标（60 FPS）

---

## ✅ 技能检查清单

### 初级 (1周)
- [ ] 能够创建场景和层
- [ ] 能够添加精灵到场景
- [ ] 能够使用基本动作（移动、缩放、旋转）
- [ ] 能够处理触摸事件
- [ ] 能够播放音频

### 中级 (1-2周)
- [ ] 能够使用动画和精灵表
- [ ] 能够实现场景切换
- [ ] 能够使用调度器和定时器
- [ ] 能够使用粒子系统
- [ ] 能够进行性能优化

### 高级 (2-4周)
- [ ] 能够设计复杂的游戏系统
- [ ] 能够管理内存和避免泄漏
- [ ] 能够优化渲染性能
- [ ] 能够扩展 Cocos2d-x 功能
- [ ] 能够与 Nuclear 引擎集成

---

## 📚 学习资源

### 官方资源
- **Cocos2d-x 2.x 文档**: https://docs.cocos.com/cocos2d-x/v2/ (已归档)
- **API 参考**: `cocos2d-2.0-rc2-x-2.0.1/docs/`
- **示例代码**: `cocos2d-2.0-rc2-x-2.0.1/samples/`

### 项目内资源
- **C++ 开发技能**: [cpp-development.md](cpp-development.md)
- **Lua 脚本技能**: [lua-scripting.md](lua-scripting.md)
- **编译指南**: [../../BUILD_GUIDE.md](../../BUILD_GUIDE.md)
- **项目规则**: [../../RULES.md](../../RULES.md)

### 注意事项
⚠️ **版本差异**: Cocos2d-x 2.0 与 3.x/4.x 有重大差异
- API 命名不同（2.0: CCSprite, 3.x: Sprite）
- 内存管理机制不同（2.0: retain/release, 3.x: Ref）
- 渲染管线不同
- 网上大部分教程基于 3.x，需要转换

---

## 🔗 相关文档

- [C++ 开发技能](cpp-development.md) - C++ 基础和项目规范
- [Lua 脚本技能](lua-scripting.md) - Lua 与 Cocos2d-x 集成
- [编译指南](../../BUILD_GUIDE.md) - 项目编译流程
- [项目规则](../../RULES.md) - 核心开发规则

---

**最后更新**: 2025-11-25
**维护状态**: ✅ 活跃维护中
**下次审查**: 2026-02-25
**反馈渠道**: 提交 Issue 或联系技术委员会


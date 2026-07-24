# 核心类架构 __ Core Classes Architecture

> **版本**: 2.0.1
> **更新**: 2026-01-02

---

## 目录

1. [类继承层次结构](#类继承层次结构)
2. [核心类详解](#核心类详解)
3. [类依赖关系](#类依赖关系)
4. [关键算法实现](#关键算法实现)

---

## 类继承层次结构

### 完整继承树

```
CCObject (引用计数基类)
│
├── CCAction (动作基类)
│   │
│   ├── CCFiniteTimeAction (有限时间动作) ← ⚠️ 重要中间类
│   │   │
│   │   ├── CCActionInterval (持续动作)
│   │   │   ├── CCSequence (序列动作)
│   │   │   ├── CCSpawn (并行动作)
│   │   │   ├── CCRotateTo (旋转)
│   │   │   ├── CCMoveTo (移动)
│   │   │   ├── CCScaleTo (缩放)
│   │   │   ├── CCFadeTo (淡入淡出)
│   │   │   ├── CCBezierTo (贝塞尔曲线)
│   │   │   ├── CCSkewTo (倾斜)
│   │   │   ├── CCJumpTo (跳跃)
│   │   │   ├── CCBlink (闪烁) ← ⚠️ 修正：CCActionInterval的子类
│   │   │   └── ... (更多持续动作)
│   │   │
│   │   └── CCActionInstant (瞬时动作)
│   │       ├── CCFlipX (水平翻转)
│   │       ├── CCFlipY (垂直翻转)
│   │       ├── CCHide (隐藏)
│   │       ├── CCShow (显示)
│   │       └── ... (更多瞬时动作)
│   │
│   ├── CCActionEase (缓动动作) ← ⚠️ 修正：CCActionInterval的子类
│   │   ├── CCEaseIn (缓入)
│   │   ├── CCEaseOut (缓出)
│   │   ├── CCEaseInOut (缓入缓出)
│   │   └── ... (更多缓动变体)
│   │
│   ├── CCActionCamera (相机动作) ← ⚠️ 修正：CCActionInterval的子类
│   │   ├── CCOrbitCamera (轨道相机)
│   │   └── ...
│   │
│   └── CCFollow (跟随动作) ← ⚠️ 修正：CCAction的直接子类
│
├── CCNode (节点基类) ★★★★★
│   ├── CCScene (场景)
│   │
│   ├── CCLayer (层)
│   │   ├── CCLayerColor (颜色层)
│   │   │   └── CCLayerGradient (渐变层)
│   │   │
│   │   └── CCLayerMultiplex (多层切换)
│   │
│   ├── CCSprite (精灵) ★★★★★
│   │
│   ├── CCLabelTTF (TTF 文字标签)
│   ├── CCLabelBMFont (位图字体标签)
│   ├── CCLabelAtlas (图集文字标签)
│   │
│   ├── CCMenu (菜单)
│   │   ├── CCMenuItem (菜单项基类)
│   │   │   ├── CCMenuItemLabel (标签菜单项)
│   │   │   ├── CCMenuItemSprite (精灵菜单项)
│   │   │   └── CCMenuItemToggle (开关菜单项)
│   │   │
│   │   └── CCMenuItemImage (图片菜单项)
│   │
│   ├── CCProgressTimer (进度条)
│   ├── CCRenderTexture (渲染纹理)
│   ├── CCClippingNode (裁剪节点)
│   ├── CCMotionStreak (拖尾效果)
│   │
│   ├── CCParticleBatchNode (粒子批处理)
│   ├── CCTMXLayer (TileMap 层)
│   │
│   └── CCParallaxNode (视差节点)
│
├── CCTexture2D (纹理)
│
├── CCScheduler (定时器)
│
├── CCActionManager (动作管理器)
│
├── CCTouchHandler (触摸处理器)
│
├── CCComponent (组件)
│
└── ... (更多派生类)
```

### 协议接口层次

```
CCRGBAProtocol (颜色协议)
├── CCNodeRGBA
└── CCSprite

CCTextureProtocol (纹理协议) ← ⚠️ 补充
└── CCSprite

CCLabelProtocol (标签协议)
├── CCLabelTTF
├── CCLabelBMFont
└── CCLabelAtlas

CCTouchDelegate (触摸委托)
├── CCLayer
└── 所有需要响应触摸的类

CCAccelerometerDelegate (加速计委托) ← ⚠️ 补充
└── CCLayer

CCKeypadDelegate (键盘委托)
└── CCLayer

CCStandardTouchDelegate
CCTargetedTouchDelegate
```

---

## 核心类详解

### 1. CCObject - 基础对象类

**文件**: `cocos2dx/cocoa/CCObject.h`

**描述**: 所有 Cocos2d-x 类的基类，提供引用计数内存管理。

```cpp
class CC_DLL CCObject {
public:
    // 引用计数操作
    void release();                      // 释放引用
    void retain();                       // 增加引用
    CCObject* autorelease();             // 加入自动释放池
    unsigned int retainCount();          // 获取引用计数

    // 对象信息
    bool isSingleRefrence();           // 是否只有一个引用
    virtual bool isEqual(const CCObject* pObject);

    // 标识
    unsigned int getID();                // 获取唯一ID

    // ⚠️ 注意: CCObject 没有 create() 工厂方法
    // 派生类（如 CCNode、CCSprite 等）提供各自的 create() 方法

protected:
    unsigned int m_uReference;           // 引用计数
    unsigned int m_uID;                  // 唯一标识
    bool m_bManaged;                     // 是否被管理器管理
};
```

> ⚠️ **代码注意**: 源代码中 `isSingleRefrence()` 方法存在拼写错误（缺少字母 'e'），
> 正确拼写应为 `isSingleReference()`。使用时请以实际代码中的方法名为准。

**关键特性**:
- **引用计数**: 手动内存管理
- **自动释放池**: 支持 autorelease
- **对象 ID**: 唯一标识符
- **无工厂方法**: CCObject 本身不提供 `create()` 方法，派生类各自实现

---

### 2. CCNode - 节点基类 ★★★★★

**文件**: `cocos2dx/base_nodes/CCNode.h` (769 行)

**描述**: 场景图中的节点基类，是所有可渲染对象的基类。

```cpp
class CC_DLL CCNode : public CCObject {
public:
    // === 创建与初始化 ===
    static CCNode* create(void);
    virtual bool init(void);

    // === 树形结构管理 ===
    virtual void addChild(CCNode* child);
    virtual void addChild(CCNode* child, int zOrder);
    virtual void addChild(CCNode* child, int zOrder, int tag);
    
    // ⚠️ 正确的方法签名（带 cleanup 参数）
    virtual void removeFromParentAndCleanup(bool cleanup);  // 从父节点移除
    virtual void removeChild(CCNode* child, bool cleanup);  // 移除子节点
    virtual void removeChildByTag(int tag, bool cleanup);   // 按标签移除
    virtual void removeAllChildrenWithCleanup(bool cleanup); // 移除所有子节点

    // === 坐标与变换 ===
    virtual void setPosition(const CCPoint& position);
    virtual const CCPoint& getPosition();
    virtual void setPositionX(float x);           // ⚠️ 补充
    virtual void setPositionY(float y);           // ⚠️ 补充
    virtual float getPositionX(void);             // ⚠️ 补充
    virtual float getPositionY(void);             // ⚠️ 补充
    virtual void setRotation(float rotation);
    virtual float getRotation();
    virtual void setScale(float scale);
    virtual void setScaleX(float scaleX);
    virtual void setScaleY(float scaleY);
    virtual void setAnchorPoint(const CCPoint& anchorPoint);
    virtual const CCPoint& getAnchorPoint();
    virtual void setContentSize(const CCSize& contentSize);
    virtual const CCSize& getContentSize();
    virtual void setVisible(bool visible);
    virtual bool isVisible();

    // === 坐标转换 ===
    CCPoint convertToNodeSpace(const CCPoint& worldPoint);
    CCPoint convertToWorldSpace(const CCPoint& nodePoint);

    // === 渲染相关 ===
    virtual void visit(void);                    // 访问/渲染
    virtual void draw(void);                     // 绘制
    void setZOrder(int zOrder);
    virtual int getZOrder();

    // === 动作系统 ===
    virtual void runAction(CCAction* action);
    void stopAllActions(void);
    void stopAction(CCAction* action);
    void stopActionByTag(int tag);
    CCAction* getActionByTag(int tag);

    // === 调度器 ===
    void scheduleUpdate(void);                   // 每帧更新
    void schedule(SEL_SCHEDULE selector);
    void schedule(SEL_SCHEDULE selector, float interval);
    void unschedule(SEL_SCHEDULE selector);
    void unscheduleUpdate(void);
    void update(float delta);                    // 更新回调

    // === 生命周期 ===
    virtual void onEnter(void);                  // 进入场景
    virtual void onEnterTransitionDidFinish(void); // ⚠️ 补充：过渡完成后
    virtual void onExitTransitionDidStart(void);   // ⚠️ 补充：过渡开始前
    virtual void onExit(void);                   // 退出场景

    // === 标签系统 ===
    void setTag(int tag);
    int getTag();

protected:
    CCPoint m_tPosition;                // 位置
    float m_fRotation;                  // 旋转角度
    float m_fScaleX;                    // X 缩放
    float m_fScaleY;                    // Y 缩放
    CCPoint m_tAnchorPoint;             // 锚点 (0-1)
    CCSize m_tContentSize;              // 内容尺寸
    CCAffineTransform m_sTransform;     // 变换矩阵
    bool m_bIsVisible;                  // 是否可见
    int m_nZOrder;                      // Z 顺序

    CCNode* m_pParent;                  // 父节点
    CCArray* m_pChildren;               // 子节点数组

    CCActionManager* m_pActionManager;  // 动作管理器
    CCScheduler* m_pScheduler;          // 调度器
};
```

> ⚠️ **重要方法签名修正**:
> - `removeFromParent()` → 实际为 `removeFromParentAndCleanup(bool cleanup)`
> - `removeChild(CCNode*)` → 实际为 `removeChild(CCNode*, bool cleanup)`
> - `removeAllChildren()` → 实际为 `removeAllChildrenWithCleanup(bool cleanup)`

**核心方法说明**:

| 方法 | 功能 | 调用时机 |
|-----|------|---------|
| `visit()` | 遍历子节点并渲染 | 每帧 |
| `draw()` | 自定义绘制 | 每帧 |
| `update(dt)` | 逻辑更新 | 每帧(如果启用) |
| `onEnter()` | 进入场景 | 添加到场景时 |
| `onExit()` | 退出场景 | 从场景移除时 |

---

### 3. CCDirector - 导演类 ★★★★★

**文件**: `cocos2dx/CCDirector.h` (469 行)

**描述**: 游戏的主控制器，管理场景、渲染循环、坐标转换等。是单例模式。

```cpp
class CCDirector {
public:
    static CCDirector* sharedDirector(void);

    // === 场景管理 ===
    virtual void runWithScene(CCScene* scene);
    virtual void replaceScene(CCScene* scene);
    virtual void pushScene(CCScene* scene);
    virtual void popScene(void);
    virtual void popToRootScene(void);           // ⚠️ 补充：弹出到根场景

    // === 渲染循环 ===
    virtual void mainLoop(void);
    virtual void startAnimation(void);
    virtual void stopAnimation(void);

    // === 暂停/恢复 ===
    void pause(void);
    void resume(void);

    // === 缓存管理 ===
    void purgeCachedData(void);                  // ⚠️ 补充：清理缓存数据

    // === 视口 ===
    const CCSize& getWinSize(void);
    const CCSize& getVisibleSize(void);
    CCPoint getVisibleOrigin(void);

    // === 坐标转换 ===
    CCPoint convertToGL(const CCPoint& point);
    CCPoint convertToUI(const CCPoint& point);

    // === FPS 显示 ===
    void setDisplayStats(bool bDisplayStats);
    bool isDisplayStats(void);

protected:
    CCScene* m_pRunningScene;             // 当前运行场景
    CCEGLView* m_pOpenGLView;              // OpenGL 视图
    CCTextureCache* m_pTextureCache;       // 纹理缓存
    CCArray* m_pScenesStack;               // 场景栈
};
```

**导演工作流程**:

```
mainLoop() {
    1. 计算时间增量 (delta time)
    2. purgeDirector() - 清理待删除对象
    3. 如果没有暂停:
       a. scheduler->update(delta) - 执行定时器
       b. actionManager->update(delta) - 更新动作
       c. runningScene->visit() - 渲染当前场景
    4. 交换缓冲区显示
}
```

---

### 4. CCScene - 场景类

```cpp
class CC_DLL CCScene : public CCNode {
public:
    static CCScene* create(void);
    bool init(void);

protected:
    CCScene();
    virtual ~CCScene();
};
```

---

### 5. CCLayer - 层类

```cpp
// ⚠️ 完整的继承关系
class CC_DLL CCLayer : public CCNode,
                       public CCTouchDelegate,
                       public CCAccelerometerDelegate,  // ⚠️ 补充
                       public CCKeypadDelegate {
public:
    static CCLayer* create(void);
    virtual bool init(void);

    // === 触摸事件 ===
    virtual void registerWithTouchDispatcher(void);
    virtual bool ccTouchBegan(CCTouch* touch, CCEvent* event);
    virtual void ccTouchMoved(CCTouch* touch, CCEvent* event);
    virtual void ccTouchEnded(CCTouch* touch, CCEvent* event);
    virtual void ccTouchCancelled(CCTouch* touch, CCEvent* event); // ⚠️ 补充

    // === 触摸模式 ===
    void setTouchEnabled(bool enabled);
    void setTouchMode(ccTouchesMode mode);

    // === 加速计事件 ===
    void setAccelerometerEnabled(bool enabled);  // ⚠️ 补充
    virtual void didAccelerate(CCAcceleration* pAccelerationValue);

    // === 键盘事件 ===
    void setKeypadEnabled(bool enabled);
};
```

---

### 6. CCSprite - 精灵类 ★★★★★

```cpp
// ⚠️ 完整的继承关系
class CC_DLL CCSprite : public CCNode,
                        public CCTextureProtocol,    // ⚠️ 补充
                        public CCRGBAProtocol {
public:
    static CCSprite* create(const char* filename);
    static CCSprite* create(const char* filename, const CCRect& rect); // ⚠️ 补充
    static CCSprite* createWithTexture(CCTexture2D* texture);
    static CCSprite* createWithTexture(CCTexture2D* texture, const CCRect& rect); // ⚠️ 补充
    static CCSprite* createWithSpriteFrame(CCSpriteFrame* spriteFrame);
    static CCSprite* createWithSpriteFrameName(const char* spriteFrameName); // ⚠️ 补充

    // === 纹理 (CCTextureProtocol) ===
    void setTexture(CCTexture2D* texture);
    CCTexture2D* getTexture(void);
    void setTextureRect(const CCRect& rect);

    // === 颜色 (CCRGBAProtocol) ===
    void setColor(const ccColor3B& color);
    const ccColor3B& getColor(void);              // ⚠️ 补充
    void setOpacity(GLubyte opacity);
    GLubyte getOpacity(void);

    // === 帧动画 ===
    void setDisplayFrame(CCSpriteFrame* newFrame);
    void setDisplayFrameWithAnimationName(const char* name, int index);
    bool isFrameDisplayed(CCSpriteFrame* pFrame); // ⚠️ 补充

    // === 翻转 ===
    void setFlipX(bool flipX);
    void setFlipY(bool flipY);
    bool isFlipX(void);                           // ⚠️ 补充
    bool isFlipY(void);                           // ⚠️ 补充

protected:
    CCTexture2D* m_pTexture;           // 纹理
    CCRect m_obRect;                   // 纹理矩形
    bool m_bFlipX;                     // 水平翻转
    bool m_bFlipY;                     // 垂直翻转
    ccColor3B m_sColor;                // RGB 颜色
    GLubyte m_cOpacity;                // 透明度
    CCSpriteBatchNode* m_pBatchNode;   // 批处理节点
};
```

---

## 类依赖关系

### 核心依赖图

```
┌─────────────────────────────────────────────────────────────────┐
│                         CCDirector (单例)                        │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐      │
│  │             │             │             │             │      │
│  ▼             ▼             ▼             ▼             ▼      │
│ CCScheduler  CCActionManager CCTouchDispatcher CCKeypadDispatcher │
│              │              │              │             │      │
│              │              │              │             │      │
│              ▼              ▼              ▼             │      │
│           CCAction       CCTouch        CCKeypad        │      │
│              │              │              │             │      │
│              ▼              ▼              ▼             │      │
│           CCNode ◄─────────┴──────────────┴─────────────┘      │
│           │                                                   │
│     ┌─────┼─────┬─────┬─────┬─────┬─────┐                     │
│     ▼     ▼     ▼     ▼     ▼     ▼     ▼                     │
│  CCScene CCLayer CCSprite CCLabel...                          │
│                                                          │      │
└──────────────────────────────────────────────────────────┼──────┘
                                                           │
                                                    ┌──────┴──────┐
                                                    │ CCTexture2D │
                                                    │ CCTextureCache│
                                                    └─────────────┘
```

---

## 关键算法实现

### 1. 坐标转换算法

```cpp
CCPoint CCNode::convertToWorldSpace(const CCPoint& nodePoint) {
    return ccMult(m_tTransform, nodePoint);
}
```

### 2. 变换矩阵计算

```cpp
void CCNode::transform(void) {
    kmMat4 identity;
    kmMat4Identity(&identity);
    kmMat4Translation(&m_tTransform, m_tPosition.x, m_tPosition.y, 0);
    kmMat4RotationZ(&m_sTransform, m_fRotation);
    kmMat4Scaling(&m_sTransform, m_fScaleX, m_fScaleY, 1);
    kmMat4Multiply(&m_tTransform, &m_tTransform, &m_sTransform);
}
```

### 3. 渲染遍历算法

```cpp
void CCNode::visit(void) {
    if (!m_bIsVisible) return;

    kmGLPushMatrix();
    this->transform();
    this->draw();

    this->sortAllChildren();
    for (int i = 0; i < m_pChildren->count(); ++i) {
        CCNode* child = (CCNode*)m_pChildren->objectAtIndex(i);
        child->visit();
    }

    kmGLPopMatrix();
}
```

---

## 相关文档

- [01_项目概览__Project-Overview.md](01_项目概览__Project-Overview.md)
- [03_动作系统__Action-System.md](03_动作系统__Action-System.md)
- [07_API参考__API-Reference.md](07_API参考__API-Reference.md)

---

> 📖 **弃用 API 迁移指南**: 关于旧版 API 的迁移说明，请参阅 [07_API参考__API-Reference.md](07_API参考__API-Reference.md#弃用-api-迁移指南)。

---

**文档版本**: 1.2
**最后更新**: 2026-01-26

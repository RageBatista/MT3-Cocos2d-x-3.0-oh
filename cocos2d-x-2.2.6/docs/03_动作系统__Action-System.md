# 动作系统 __ Action System

> **版本**: 2.0.1
> **更新**: 2026-01-02

---

## 目录

1. [动作系统架构](#动作系统架构)
2. [动作类型](#动作类型)
3. [缓动函数](#缓动函数)
4. [组合动作](#组合动作)
5. [自定义动作](#自定义动作)

---

## 动作系统架构

### 类层次结构

```
CCAction (动作基类)
│
├── CCFiniteTimeAction (有限时间动作基类) ← ⚠️ 重要中间类
│   │
│   ├── CCActionInterval (持续动作基类)
│   │
│   ├── 基本移动动作
│   │   ├── CCMoveTo          // 移动到指定位置
│   │   ├── CCMoveBy          // 相对移动
│   │   ├── CCJumpTo          // 跳跃到指定位置
│   │   ├── CCJumpBy          // 相对跳跃
│   │   ├── CCBezierTo        // 贝塞尔曲线移动
│   │   └── CCBezierBy        // 相对贝塞尔曲线
│   │
│   ├── 旋转动作
│   │   ├── CCRotateTo        // 旋转到指定角度
│   │   └── CCRotateBy        // 相对旋转
│   │
│   ├── 缩放动作
│   │   ├── CCScaleTo         // 缩放到指定大小
│   │   └── CCScaleBy         // 相对缩放
│   │
│   ├── 颜色/透明度动作
│   │   ├── CCFadeIn          // 淡入
│   │   ├── CCFadeOut         // 淡出
│   │   ├── CCFadeTo          // 渐变到指定透明度
│   │   ├── CCTintTo          // 渐变到指定颜色
│   │   └── CCTintBy          // 相对颜色渐变
│   │
│   ├── 特殊动作
│   │   ├── CCSkewTo          // 倾斜到指定角度
│   │   ├── CCSkewBy          // 相对倾斜
│   │   ├── CCFlipX3D         // 3D X轴翻转
│   │   ├── CCFlipY3D         // 3D Y轴翻转
│   │   ├── CCWaves3D         // 3D 波浪
│   │   ├── CCLens3D          // 3D 透镜效果
│   │   ├── CCRipple3D        // 3D 涟漪
│   │   └── CCShaky3D         // 3D 震动
│   │
│   ├── 组合动作
│   │   ├── CCSequence        // 序列执行
│   │   ├── CCSpawn           // 并发执行
│   │   ├── CCRepeat          // 重复执行
│   │   └── CCRepeatForever   // 无限重复
│   │
│   └── 缓动动作
│       ├── CCEaseIn          // 缓入
│       ├── CCEaseOut         // 缓出
│       ├── CCEaseInOut       // 缓入缓出
│       ├── CCEaseSineIn      // 正弦缓入
│       ├── CCEaseSineOut     // 正弦缓出
│       ├── CCEaseBounceIn    // 弹跳缓入
│       ├── CCEaseBounceOut   // 弹跳缓出
│       └── CCEaseBackIn      // 回弹缓入
│
│   └── CCActionInstant (瞬时动作基类)
│       ├── CCFlipX              // 水平翻转
│       ├── CCFlipY              // 垂直翻转
│       ├── CCHide               // 隐藏
│       ├── CCShow               // 显示
│       ├── CCToggleVisibility   // 切换可见性
│       ├── CCPlace              // 瞬移
│       └── CCCallFunc           // 回调函数
│           ├── CCCallFuncN      // 带节点参数
│           ├── CCCallFuncND     // 带节点和数据参数
│           └── CCCallFuncO      // 带对象参数
│
├── CCFollow (跟随动作) ← ⚠️ 直接继承CCAction
│
└── CCActionManager (动作管理器)
```

> ⚠️ **继承关系说明**:
> - `CCFiniteTimeAction` 是 `CCActionInterval` 和 `CCActionInstant` 的共同基类
> - `CCBlink` 实际上是 `CCActionInterval` 的子类，不是 `CCActionInstant`
> - `CCFollow` 直接继承自 `CCAction`，不是 `CCFiniteTimeAction`

---

## 动作类型

### 1. 基础动作 (CCActionInterval)

#### CCMoveTo / CCMoveBy - 移动动作

```cpp
// 移动到指定位置 (绝对)
CCMoveTo* move = CCMoveTo::create(duration, ccp(x, y));

// 相对移动
CCMoveBy* moveBy = CCMoveBy::create(duration, ccp(deltaX, deltaY));

// 使用示例
sprite->runAction(CCMoveTo::create(2.0f, ccp(100, 100)));
```

#### CCRotateTo / CCRotateBy - 旋转动作

```cpp
// 旋转到指定角度 (绝对)
CCRotateTo* rotate = CCRotateTo::create(duration, angle);

// 相对旋转
CCRotateBy* rotateBy = CCRotateBy::create(duration, deltaAngle);

// 使用示例
sprite->runAction(CCRotateTo::create(1.0f, 180));
```

#### CCScaleTo / CCScaleBy - 缩放动作

```cpp
// 缩放到指定大小 (绝对)
CCScaleTo* scale = CCScaleTo::create(duration, scale);
CCScaleTo* scaleXY = CCScaleTo::create(duration, scaleX, scaleY);

// 相对缩放
CCScaleBy* scaleBy = CCScaleBy::create(duration, deltaScale);

// 使用示例
sprite->runAction(CCScaleTo::create(0.5f, 2.0f));  // 放大2倍
```

#### CCFadeIn / CCFadeOut / CCFadeTo - 淡入淡出

```cpp
// 淡入 (透明度 0 -> 255)
CCFadeIn* fadeIn = CCFadeIn::create(duration);

// 淡出 (透明度 255 -> 0)
CCFadeOut* fadeOut = CCFadeOut::create(duration);

// 渐变到指定透明度
CCFadeTo* fadeTo = CCFadeTo::create(duration, opacity);

// 使用示例
sprite->runAction(CCFadeOut::create(1.0f));
```

#### CCTintTo / CCTintBy - 颜色渐变

```cpp
// 渐变到指定颜色 (绝对)
CCTintTo* tintTo = CCTintTo::create(duration, r, g, b);

// 相对颜色渐变
CCTintBy* tintBy = CCTintBy::create(duration, deltaR, deltaG, deltaB);

// 使用示例
sprite->runAction(CCTintTo::create(1.0f, 255, 0, 0));  // 变红
```

#### CCJumpTo / CCJumpBy - 跳跃动作

```cpp
// 跳跃到指定位置
// 参数: duration, position, height, jumps
CCJumpTo* jump = CCJumpTo::create(2.0f, ccp(100, 100), 50, 4);

// 使用示例
sprite->runAction(CCJumpBy::create(2.0f, ccp(100, 0), 50, 4));
```

#### CCBezierTo / CCBezierBy - 贝塞尔曲线

```cpp
// 配置贝塞尔曲线
ccBezierConfig bezier;
bezier.controlPoint_1 = ccp(100, 200);
bezier.controlPoint_2 = ccp(200, 200);
bezier.endPosition = ccp(300, 100);

// 创建贝塞尔动作
CCBezierTo* bezierTo = CCBezierTo::create(3.0f, bezier);
```

### 2. 瞬时动作 (CCActionInstant)

#### CCCallFunc - 回调动作

```cpp
// 无参数回调
CCCallFunc* callFunc = CCCallFunc::create(target,
    callfunc_selector(MyClass::callback));

// 带节点参数
CCCallFuncN* callFuncN = CCCallFuncN::create(target,
    callfuncN_selector(MyClass::callbackWithNode));

// 带节点和数据参数
CCCallFuncND* callFuncND = CCCallFuncND::create(target,
    callfuncND_selector(MyClass::callbackWithData), (void*)data);
```

#### CCPlace - 瞬移动作

```cpp
// 瞬间移动到指定位置
CCPlace* place = CCPlace::create(ccp(100, 100));
sprite->runAction(place);
```

#### CCFlipX / CCFlipY - 翻转动作

```cpp
// 水平翻转
CCFlipX* flipX = CCFlipX::create(true);
sprite->runAction(flipX);

// 垂直翻转
CCFlipY* flipY = CCFlipY::create(true);
sprite->runAction(flipY);
```

---

## 缓动函数

### 缓动类型

#### CCEaseIn - 缓入

动画开始时缓慢，逐渐加速。

```cpp
CCAction* move = CCMoveTo::create(2.0f, ccp(100, 100));
CCAction* easeIn = CCEaseIn::create(move, 3.0f);  // rate = 3.0
sprite->runAction(easeIn);
```

#### CCEaseOut - 缓出

动画开始时快速，逐渐减速。

```cpp
CCAction* move = CCMoveTo::create(2.0f, ccp(100, 100));
CCAction* easeOut = CCEaseOut::create(move, 3.0f);
sprite->runAction(easeOut);
```

#### CCEaseInOut - 缓入缓出

动画开始和结束时缓慢，中间快速。

```cpp
CCAction* move = CCMoveTo::create(2.0f, ccp(100, 100));
CCAction* easeInOut = CCEaseInOut::create(move, 3.0f);
sprite->runAction(easeInOut);
```

#### CCEaseSineIn/Out/InOut - 正弦缓动

```cpp
CCAction* move = CCMoveTo::create(2.0f, ccp(100, 100));
CCAction* easeSine = CCEaseSineInOut::create(move);
sprite->runAction(easeSine);
```

#### CCEaseBounceIn/Out - 弹跳缓动

```cpp
CCAction* move = CCMoveTo::create(2.0f, ccp(100, 100));
CCAction* easeBounce = CCEaseBounceOut::create(move);
sprite->runAction(easeBounce);
```

### 缓动函数曲线

```
缓入 (EaseIn):          缓出 (EaseOut):
    ▓                       █
   ▓▓                      ██
  ▓▓▓                     ▓▓██
 ▓▓▓▓                    ▓▓▓▓██
▓▓▓▓▓                   ▓▓▓▓▓▓██

缓入缓出 (EaseInOut):   弹跳 (BounceOut):
    ▓                       █
   ▓▓                      █
  ▓▓▓                     ██ ▓
 ▓▓▓▓                    █▓▓▓
▓▓▓▓▓                   ▓██▓
```

---

## 弃用API说明

> ⚠️ **重要提示**: Cocos2d-x 2.0.1 中，许多旧的API已被标记为弃用（使用 `CC_DEPRECATED_ATTRIBUTE` 宏）。
> 这些API在未来版本中可能会被移除，建议使用新的API。

### 弃用API列表

| 旧API | 新API | 说明 |
|-------|-------|------|
| `CCSprite::spriteWithFile()` | `CCSprite::create()` | 创建精灵 |
| `CCSprite::spriteWithTexture()` | `CCSprite::create()` | 使用纹理创建精灵 |
| `CCActionInterval::actionWithDuration()` | `CCActionInterval::create()` | 创建间隔动作 |
| `CCSequence::actions()` | `CCSequence::create()` | 创建序列动作 |
| `CCArray::array()` | `CCArray::create()` | 创建数组 |
| `CCDictionary::dictionary()` | `CCDictionary::create()` | 创建字典 |

### 迁移指南

```cpp
// ❌ 旧API（已弃用）
CCSprite* sprite = CCSprite::spriteWithFile("player.png");

// ✅ 新API（推荐）
CCSprite* sprite = CCSprite::create("player.png");

// ❌ 旧API（已弃用）
CCSequence* seq = CCSequence::actions(
    CCMoveTo::create(1.0f, ccp(100, 100)),
    CCRotateTo::create(0.5f, 180),
    NULL
);

// ✅ 新API（推荐）
CCSequence* seq = CCSequence::create(
    CCMoveTo::create(1.0f, ccp(100, 100)),
    CCRotateTo::create(0.5f, 180),
    NULL
);
```

---

## 组合动作

### CCSequence - 序列执行

按顺序依次执行多个动作。

```cpp
CCSequence* sequence = CCSequence::create(
    CCMoveTo::create(1.0f, ccp(100, 100)),
    CCRotateTo::create(0.5f, 180),
    CCFadeOut::create(0.5f),
    NULL
);

sprite->runAction(sequence);
```

### CCSpawn - 并发执行

同时执行多个动作。

```cpp
CCSpawn* spawn = CCSpawn::create(
    CCMoveTo::create(1.0f, ccp(100, 100)),
    CCRotateTo::create(1.0f, 360),
    CCFadeOut::create(1.0f),
    NULL
);

sprite->runAction(spawn);
```

### CCRepeat - 重复执行

重复执行动作指定次数。

```cpp
CCAction* move = CCMoveBy::create(1.0f, ccp(50, 0));

// 重复 3 次
CCRepeat* repeat = CCRepeat::create(move, 3);

// 无限重复
CCRepeatForever* repeatForever = CCRepeatForever::create(move);

sprite->runAction(repeatForever);
```

### 复杂组合示例

```cpp
// 复杂动画序列
CCSequence* complexSequence = CCSequence::create(
    // 1. 移动到目标
    CCMoveTo::create(1.0f, ccp(200, 200)),

    // 2. 同时旋转和缩放
    CCSpawn::create(
        CCRotateTo::create(0.5f, 180),
        CCScaleTo::create(0.5f, 1.5f),
        NULL
    ),

    // 3. 跳跃两次
    CCRepeat::create(
        CCJumpBy::create(0.5f, ccp(0, 50), 30, 1),
        2
    ),

    // 4. 闪烁后淡出
    CCSequence::create(
        CCBlink::create(1.0f, 3),
        CCFadeOut::create(0.5f),
        NULL
    ),

    // 5. 回调
    CCCallFunc::create(this, callfunc_selector(MyClass::onAnimationComplete)),

    NULL
);

sprite->runAction(complexSequence);
```

---

## 自定义动作

### 创建自定义持续动作

```cpp
// 自定义震动动作
class CShake : public CCActionInterval {
public:
    static CShake* create(float duration, float strength) {
        CShake* ret = new CShake();
        if (ret && ret->initWithDuration(duration, strength)) {
            ret->autorelease();
            return ret;
        }
        CC_SAFE_DELETE(ret);
        return NULL;
    }

    virtual void update(float time) {
        float randX = (CCRANDOM_0_1() - 0.5f) * 2 * m_strength;
        float randY = (CCRANDOM_0_1() - 0.5f) * 2 * m_strength;
        m_pTarget->setPosition(ccp(m_initialX + randX, m_initialY + randY));
    }

protected:
    float m_strength;
    float m_initialX, m_initialY;
};

// 使用
sprite->runAction(CShake::create(0.5f, 10));
```

---

## 性能优化建议

1. **使用动作池**: 频繁使用的动作可以缓存复用
2. **限制并发动作数**: 避免单个节点执行过多动作
3. **使用 CCSpawn**: 合并可并行动作，减少更新次数
4. **及时清理**: 不需要的动作及时停止
5. **优先使用简单动作**: CCMoveTo 比 CCBezierTo 性能更好

---

> 📖 **弃用 API 迁移指南**: 关于旧版动作 API 的迁移说明，请参阅 [07_API参考__API-Reference.md](07_API参考__API-Reference.md#弃用-api-迁移指南)。

---

## 相关文档

- [02_核心类架构__Core-Classes-Architecture.md](02_核心类架构__Core-Classes-Architecture.md)
- [01_项目概览__Project-Overview.md](01_项目概览__Project-Overview.md)
- [07_API参考__API-Reference.md](07_API参考__API-Reference.md)

---

**文档版本**: 1.2
**最后更新**: 2026-01-26

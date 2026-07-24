---
name: cocos2dx
description: MT3 项目中 Cocos2d-x 2.0 开发技能：场景/层/精灵/动作，资源加载（plist/png），坐标转换，调度，与 Nuclear/FireClient 集成
---

# Cocos2d-x 2.0 开发 (MT3)

## 何时使用

- 需要创建或修改游戏场景（`CCScene`）
- 需要创建或修改层（`CCLayer`）
- 需要处理精灵（`CCSprite`）和动画（`CCAnimation`）
- 需要使用动作系统（`CCAction`）
- 需要处理资源加载（`plist/png`）
- 需要进行坐标转换
- 需要使用调度器（`schedule`）
- 需要集成 Nuclear 引擎

## 何时不使用

- 需要创建 UI 界面（使用 [cegui](../cegui/SKILL.md) 技能）
- 需要处理 3D 渲染（使用 engine 技能）
- 需要处理网络通信（使用 server 技能）
- 需要处理音频播放（使用 audio 技能）

## 输入要求

- 资源文件路径（`.plist`, `.png`）
- 场景/层/精灵配置
- 动画帧数据
- 坐标信息

## 关键约束

> 详细约束请参考 [公共约束](../../references/common-constraints.md)

- 使用 Cocos2d-x 2.0-rc2-x-2.0.1（`cocos2d-2.0-rc2-x-2.0.1`），禁止升级
- 保持 toolset v120（VS2013），禁止修改预编译库
- 遵循编码规则：C++/headers UTF-8 with BOM；Lua/MD/XML UTF-8 without BOM
- Win32 平台使用原生 OpenGL 2.0（非 OpenGL ES）

## 工作流程

### 1. 定位调用点

```powershell
# 搜索 Cocos2d-x 相关代码
rg "CCDirector|CCScene|CCLayer|CCSprite|CCAnimation|CCAction" client engine cocos2d-2.0-rc2-x-2.0.1
```

### 2. 修改或添加节点

- 使用 `create/autorelease` 模式
- 调用 `addChild` 添加到父节点
- 保持 `retain/release` 平衡（如手动管理）

### 3. 管理资源

- 通过 `CCSpriteFrameCache` 加载 `plist/png`
- 确保文件存在于 `client/resource`

### 4. 处理定时

- 使用 `schedule`, `scheduleOnce`, `unschedule`
- 将重工作移出主线程

### 5. 坐标转换

- 使用 `convertToNodeSpace`/`convertToWorldSpace`
- 使用 `CCDirector::sharedDirector()->getWinSize()`

### 6. 集成 Nuclear 引擎

- 使用 `IEngine` 接口
- 使用 tolua++ 绑定

## 代码示例

### 创建基本场景和层

```cpp
#include "cocos2d.h"

class MyScene : public cocos2d::CCScene {
public:
    static MyScene* create() {
        MyScene* scene = new MyScene();
        if (scene && scene->init()) {
            scene->autorelease();
            return scene;
        }
        CC_SAFE_DELETE(scene);
        return NULL;
    }

    virtual bool init() {
        if (!CCScene::init()) {
            return false;
        }

        CCLayer* layer = CCLayer::create();
        this->addChild(layer);

        return true;
    }
};
```

### 使用 CCDirector（MT3 特定）

```cpp
// 获取 director 实例
cocos2d::CCDirector* director = cocos2d::CCDirector::sharedDirector();

// 获取运行场景
CCScene* runningScene = director->getRunningScene();

// 暂停/恢复动画
director->pause();
director->resume();
director->stopAnimation();
director->startAnimation();
```

### 创建和添加精灵

```cpp
// 加载精灵帧缓存
CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("sprites.plist", "sprites.png");

// 从帧创建精灵
CCSprite* sprite = CCSprite::createWithSpriteFrameName("player.png");
sprite->setPosition(ccp(100, 100));
this->addChild(sprite);

// 从纹理创建精灵
CCSprite* sprite2 = CCSprite::create("background.png");
sprite2->setPosition(ccp(0, 0));
sprite2->setAnchorPoint(ccp(0, 0));
this->addChild(sprite2);
```

### 在精灵上运行动作

```cpp
// 移动动作
CCMoveTo* move = CCMoveTo::create(2.0f, ccp(200, 200));
sprite->runAction(move);

// 动作序列
CCSequence* sequence = CCSequence::create(
    CCMoveTo::create(1.0f, ccp(200, 200)),
    CCRotateBy::create(1.0f, 360),
    CCScaleTo::create(0.5f, 2.0f),
    NULL
);
sprite->runAction(sequence);

// 重复动作
CCRepeatForever* repeat = CCRepeatForever::create(
    CCSequence::create(
        CCFadeIn::create(1.0f),
        CCFadeOut::create(1.0f),
        NULL
    )
);
sprite->runAction(repeat);
```

### 创建动画

```cpp
// 加载精灵帧
CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("walk.plist", "walk.png");

// 创建动画帧
CCArray* frames = CCArray::create();
for (int i = 1; i <= 8; i++) {
    char frameName[32];
    sprintf(frameName, "walk%d.png", i);
    CCSpriteFrame* frame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName(frameName);
    frames->addObject(frame);
}

// 创建动画
CCAnimation* animation = CCAnimation::createWithSpriteFrames(frames, 0.1f);
CCAnimate* animate = CCAnimate::create(animation);

// 运行动画
CCRepeatForever* repeatWalk = CCRepeatForever::create(animate);
sprite->runAction(repeatWalk);
```

### 调度更新

```cpp
// 每帧调度更新
this->scheduleUpdate();

// 调度自定义选择器
this->schedule(schedule_selector(MyLayer::customUpdate), 1.0f);

// 调度一次
this->scheduleOnce(schedule_selector(MyLayer::oneTimeAction), 2.0f);

// 取消调度
this->unschedule(schedule_selector(MyLayer::customUpdate));

// 更新函数
void MyLayer::update(float delta) {
    // 每帧调用
}

void MyLayer::customUpdate(float delta) {
    // 每秒调用
}
```

### 坐标转换

```cpp
// 获取窗口大小
CCSize winSize = CCDirector::sharedDirector()->getWinSize();

// 将触摸位置转换为节点空间
CCPoint touchLocation = touch->locationInView();
CCPoint glLocation = CCDirector::sharedDirector()->convertToGL(touchLocation);
CCPoint nodeLocation = this->convertToNodeSpace(glLocation);

// 转换为世界空间
CCPoint worldLocation = this->convertToWorldSpace(ccp(0, 0));
```

### 场景转换

```cpp
// 使用过渡替换场景
CCScene* newScene = MyScene::create();
CCTransitionScene* transition = CCTransitionFade::create(1.0f, newScene);
CCDirector::sharedDirector()->replaceScene(transition);

// 其他过渡类型
CCTransitionSlideInR::create(1.0f, newScene);
CCTransitionFlipX::create(1.0f, newScene);
CCTransitionZoomFlipY::create(1.0f, newScene);
```

### Lua 集成（MT3 特定）

```cpp
// 定义 Lua 模块
tolua_beginmodule(tolua_S, "MyModule");
    // 导出 C++ 函数到 Lua
tolua_endmodule(tolua_S);
```

```lua
-- 从 Lua 调用 C++ 函数
local result = MyModule.someFunction(param1, param2)
```

## Nuclear 引擎集成

> 详细集成指南请参考 [Nuclear 集成指南](../../references/nuclear-integration.md)

### 引擎访问

```cpp
// 获取 Nuclear 引擎实例
Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
if (!engine) {
    // 处理错误
    return;
}
```

### 渲染器操作

```cpp
// 获取渲染器
Nuclear::IRenderer* renderer = engine->GetRenderer();

// 重置设备
renderer->OnResetDevice();

// 重置纹理 uniform
renderer->ResetAllTextureUName();

// 重新加载所有纹理
renderer->OnReloadAllTexture();
```

### 定时器管理

```cpp
// 调度定时器回调
class MyTimerCallback : public Nuclear::ExecThread::CallbackTask {
public:
    MyTimerCallback() : Nuclear::ExecThread::CallbackTask(0) {}

    virtual void Execute() {
        // 定时器回调代码
    }
};

// 调度定时器
MyTimerCallback* callback = new MyTimerCallback();
Nuclear::GetEngine()->ScheduleTimer(callback, 1000); // 1000ms

// 取消定时器
Nuclear::GetEngine()->CancelTimer(callback);
```

## 常见错误与解决方案

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| "CCSpriteFrameCache: trying to use invalid texture" | 纹理文件未加载或路径错误 | 确保 `.png` 文件存在，先加载纹理 |
| "CCSprite: sprite frame not found" | 精灵帧名不匹配 plist 条目 | 检查 plist 中的精灵帧名，确保完全匹配 |
| "CCDirector: Assertion failed in replaceScene" | 场景为 NULL 或未正确初始化 | 验证场景创建返回非 NULL，检查 init() 返回 true |
| "CCAction: Action not running on target" | 动作创建但未运行，或目标为 NULL | 调用 `runAction()`，验证目标节点有效 |
| "Memory leak detected" | retain/release 不平衡 | 使用 `create()` 方法，使用 `CC_SAFE_DELETE` 和 `CC_SAFE_RELEASE` |
| "CCNode: addChild: child already added" | 尝试将同一子节点添加到多个父节点 | 从当前父节点移除后再添加到新父节点 |
| "Nuclear::Engine::GetEngine() returns NULL" | Nuclear 引擎未初始化 | 验证 Nuclear 引擎在使用前已初始化 |
| "tolua++ binding not found" | 函数未通过 tolua++ 导出到 Lua | 验证函数在 `tolua_beginmodule` 和 `tolua_endmodule` 之间 |
| "CCDirector::sharedDirector() returns NULL" | Director 未初始化 | 验证 CCDirector 在使用前已初始化 |
| "Nuclear::IEffect::OnDelete called on invalid effect" | 特效删除时仍被引用 | 验证特效在删除前从所有映射中移除 |

> 详细错误处理策略请参考 [错误处理指南](../../references/error-handling.md)

## 调试技巧

> 详细调试命令请参考 [调试命令集合](../../references/debugging-commands.md)

### 启用调试绘制

```cpp
// 启用精灵调试绘制
sprite->setDebugDraw(true);

// 启用层调试绘制
this->setDebugDraw(true);
```

### 打印节点层次

```cpp
void printNodeHierarchy(CCNode* node, int depth = 0) {
    std::string indent(depth * 2, ' ');
    CCPoint pos = node->getPosition();
    CCSize size = node->getContentSize();

    printf("%sNode: %s, Position: (%.1f, %.1f), Size: (%.1f, %.1f), Children: %d\n",
           indent.c_str(), node->getDescription(), pos.x, pos.y, size.width, size.height,
           (int)node->getChildrenCount());

    CCArray* children = node->getChildren();
    CCObject* obj = NULL;
    CCARRAY_FOREACH(children, obj) {
        CCNode* child = (CCNode*)obj;
        printNodeHierarchy(child, depth + 1);
    }
}
```

### 检查精灵帧缓存

```cpp
void printSpriteFrameCache() {
    CCDictionary* frames = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrames();
    CCDictElement* element = NULL;
    CCDICT_FOREACH(frames, element) {
        printf("Sprite frame: %s\n", element->getStrKey());
    }
}
```

## 性能优化

> 详细优化策略请参考 [性能优化指南](../../references/performance-guide.md)

### 精灵批处理

- 使用 `CCSpriteBatchNode` 批量渲染相同纹理的精灵
- 使用纹理图集减少绘制调用

### 动画优化

- 复用动画对象
- 使用动作池
- 避免在 update 中创建动作

### 资源管理优化

- 异步加载资源
- 预加载常用资源
- 释放未使用的资源

### 调度优化

- 使用 `scheduleUpdate` 替代自定义 `schedule`
- 避免频繁的 `schedule/unschedule`
- 减少调度频率

### 场景优化

- 使用场景缓存
- 使用场景过渡效果
- 避免在场景切换时创建大量对象

## 注意事项

- Cocos2d-x 2.0 在 Win32 上使用 OpenGL 2.0（非 OpenGL ES），某些移动特定功能不可用
- 坐标系统：原点在左下角，不是左上角
- 动作完成后自动移除，除非使用 `CCRepeatForever`
- 节点的锚点默认为 (0.5, 0.5)（中心），不是 (0, 0)
- 小心 retain/release，尽可能使用 autorelease
- 场景转换可能导致内存问题，需正确管理
- 触摸坐标需要从视图空间转换为 GL 空间
- Lua 集成使用 tolua++，确保正确的绑定约定
- Nuclear 引擎提供 `IEngine` 接口，用于引擎集成
- 始终在使用前检查 `Nuclear::GetEngine()` 返回非 NULL
- Nuclear 特效必须正确清理以避免内存泄漏
- 定时器回调必须正确管理以避免崩溃
- 协调背景模式更改与 CEGUI 和 Nuclear 引擎
- tolua++ 绑定必须在 `tolua_beginmodule` 和 `tolua_endmodule` 之间
- tolua++ 收集函数必须正确删除 C++ 对象

## 资源管理

> 详细资源管理策略请参考 [资源管理指南](../../references/resource-management.md)

### 资源加载

```cpp
// 加载精灵帧缓存
CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("sprites.plist", "sprites.png");

// 加载纹理
CCTextureCache::sharedTextureCache()->addImage("background.png");

// 异步加载资源
CCTextureCache::sharedTextureCache()->addImageAsync("background.png", this,
    callfuncO_selector(MyLayer::onTextureLoaded));
```

### 资源释放

```cpp
// 释放未使用的纹理
CCTextureCache::sharedTextureCache()->removeUnusedTextures();

// 释放未使用的精灵帧
CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFrames();

// 清空所有缓存
CCTextureCache::sharedTextureCache()->removeAllTextures();
CCSpriteFrameCache::sharedSpriteFrameCache()->removeSpriteFrames();
```

## 相关技能

- [Nuclear 引擎技能](../nuclear/SKILL.md) - Nuclear 引擎集成与开发
- [tolua++ 绑定技能](../tolua/SKILL.md) - C++/Lua 绑定开发
- [公共约束](../../references/common-constraints.md) - 编码规范与代码风格
- [Nuclear 集成指南](../../references/nuclear-integration.md) - Nuclear 引擎集成方法

## 参考资料

- [公共约束](../../references/common-constraints.md)
- [Nuclear 集成指南](../../references/nuclear-integration.md)
- [性能优化指南](../../references/performance-guide.md)
- [资源管理指南](../../references/resource-management.md)
- [错误处理指南](../../references/error-handling.md)
- [调试命令集合](../../references/debugging-commands.md)
- 项目架构：`docs/19-项目架构分析报告-Project-Architecture-Analysis.md`
- 依赖矩阵：`docs/06-工具链/02-依赖矩阵.md`
- Cocos2d-x 2.0 API 参考：`cocos2d-2.0-rc2-x-2.0.1/cocos2dx/include/`
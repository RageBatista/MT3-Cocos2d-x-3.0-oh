---
name: nuclear-engine
version: 1.4.0
priority: high
category: client
description: |
  MT3客户端Nuclear自研引擎开发技能。涵盖IEngine/IWorld/IEnv/IQuery接口、精灵和特效管理、引用计数和对象池、NED Malloc分配器、批量渲染和视锥裁剪、性能优化技巧。
  触发词: Nuclear, 引擎, IEngine, IWorld, IEnv, IQuery, 精灵, 特效, 批量渲染, 视锥裁剪, 对象池, NED, Malloc, 精灵管理器, 特效管理器, 动画管理器, ISprite, IEffect
dependencies:
  - cpp-development
  - cocos2dx-usage
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 14000
---

# Nuclear 引擎开发技能

**版本**: v1.4.0
**最后更新**: 2026-04-11

---

## 🎯 核心知识点

### 1. Nuclear引擎架构

#### 架构层级（详细架构见 [cpp-development](cpp-development.md)）

```
Layer 3: Nuclear 引擎层 (IEngine, IWorld, IEnv, IQuery)
Layer 2: Cocos2d-x 2.2.6 层
Layer 1: 平台层 (Win32/Android/iOS)
```

#### 核心模块

- **引擎核心**: 引擎生命周期管理
- **管理器**: 精灵管理器、特效管理器、动画管理器
- **组件**: 精灵组件、特效组件、动画组件
- **渲染**: 批量渲染、视锥裁剪、纹理管理

### 2. IEngine接口

#### 引擎生命周期

```cpp
// 初始化引擎
bool Initialize();

// 运行引擎主循环
void Run();

// 退出引擎
void Exit();
```

#### 屏幕管理

```cpp
// 获取屏幕宽度
int GetScreenWidth();

// 获取屏幕高度
int GetScreenHeight();

// 设置屏幕分辨率
bool SetScreenResolution(int width, int height);
```

#### 时间管理

```cpp
// 设置游戏时间速度
void SetGameTimeSpeedScale(float scale);

// 获取游戏时间速度
float GetGameTimeSpeedScale();

// 获取FPS
float GetFPS();
```

#### 核心管理器访问

```cpp
// 获取世界管理器
IWorld* GetWorld();

// 获取环境管理器
IEnv* GetEnv();

// 获取查询管理器
IQuery* GetQuery();
```

#### 任务调度

```cpp
// 添加任务到队列
bool PutTask(ITask* task);

// 调度定时器
bool ScheduleTimer(int delayMs, ITask* task);

// 取消定时器
bool CancelTimer(ITask* task);
```

#### 日志管理

```cpp
// 设置信息日志路径
void SetInfoLogPath(const char* path);

// 设置错误日志路径
void SetErrorLogPath(const char* path);

// 输出日志
void LogInfo(const char* format, ...);
void LogError(const char* format, ...);
```

#### 内存管理

```cpp
// 立即执行垃圾回收
void GCNow();

// 获取当前内存大小
size_t GetCurMemSize();

// 获取峰值内存大小
size_t GetPeakMemSize();
```

#### 渲染控制

```cpp
// 执行渲染
void Draw();

// 设置清除颜色
void SetCleanColor(float r, float g, float b, float a);

// 启用/禁用渲染
void SetRenderEnabled(bool enabled);
```

### 3. IWorld接口

#### 地图管理

```cpp
// 加载地图
bool LoadMap(const char* mapName);

// 卸载地图
void UnloadMap();

// 获取当前地图名称
const char* GetCurrentMapName();
```

#### 精灵管理

```cpp
// 创建新精灵
ISprite* NewSprite();

// 删除精灵
void DeleteSprite(ISprite* sprite);

// 根据ID查询精灵
ISprite* QuerySprite(int id);
```

#### 不可移动对象管理

```cpp
// 创建不可移动对象
IImmovableObj* NewImmovableObj();

// 删除不可移动对象
void DeleteImmovableObj(IImmovableObj* obj);
```

#### 特效管理

```cpp
// 设置特效
bool SetEffect(int spriteId, const char* effectName);

// 移除特效
void RemoveEffect(int spriteId);

// 查询特效
IEffect* QueryEffect(int id);
```

#### 相机控制

```cpp
// 将相机附加到精灵
void AttachCameraTo(int spriteId);

// 设置相机位置
void SetCameraPosition(float x, float y);

// 设置相机缩放
void SetCameraScale(float scale);

// 设置视口
void SetViewport(float x, float y, float width, float height);
```

#### A*寻路

```cpp
// 获取A*路径
bool GetAStartPath(float startX, float startY, float endX, float endY, 
                 PathPoint* path, int maxPathPoints);
```

#### 障碍管理

```cpp
// 设置地图障碍
void SetMapMaze(int x, int y, bool blocked);

// 设置障碍掩码
void SetMazeMask(int mask);

// 获取障碍状态
bool GetMapMaze(int x, int y);
```

#### 游戏时间

```cpp
// 设置游戏时间
void SetGameTime(int year, int month, int day, int hour, int minute);

// 获取游戏时间
void GetGameTime(int* year, int* month, int* day, int* hour, int* minute);

// 设置游戏时间周期
void SetGameTimeCycle(int cycleMinutes);
```

### 4. IEnv接口

#### 显示模式

```cpp
// 获取显示模式
DisplayMode GetDisplayMode();

// 获取当前多重采样类型
MultiSampleType GetCurrentMultiSampleType();

// 设置显示模式
bool SetDisplayMode(DisplayMode mode);
```

#### FPS控制

```cpp
// 设置控制FPS
void SetControlFPS(int fps);

// 获取控制FPS
int GetControlFPS();

// 启用/禁用FPS控制
void SetControlFPSEnabled(bool enabled);
```

#### 渲染效果配置

```cpp
// 设置夜间渲染效果
void SetRenderNightEffectByShader(bool enabled);

// 设置精灵阴影
void SetRenderSpriteShadow(bool enabled);

// 设置精灵阴影参数
void SetSpriteShadowParam(float offsetX, float offsetY, float blur);
```

#### 半透明配置

```cpp
// 获取精灵半透明类型
SpriteTranslucentType GetSpriteTranslucentType();

// 设置精灵半透明类型
void SetSpriteTranslucentType(SpriteTranslucentType type);

// 设置遮罩透明度
void SetMaskAlpha(float alpha);
```

#### 声音系统配置

```cpp
// 获取BGM类型
BGMType GetBGMType();

// 设置BGM类型
void SetBGMType(BGMType type);

// 获取音效音量
float GetSoundVolume();

// 设置音效音量
void SetSoundVolume(float volume);
```

#### GC配置

```cpp
// 设置动画图片GC时间
void SetAniPicGCTime(int seconds);

// 设置动画XAP GC时间
void SetAniXapGCTime(int seconds);

// 立即执行GC
void GCNow();
```

### 5. IQuery接口

#### 动作信息查询

```cpp
// 获取动作信息
ActionInfo* GetActionInfo(int actionId);
```

#### 精灵层级信息查询

```cpp
// 获取精灵层级信息
SpriteLayerInfo* GetSpriteLayerInfo(int layerId);
```

### 6. 精灵和特效管理

#### 精灵创建

```cpp
// 创建精灵
ISprite* sprite = world->NewSprite();

// 设置精灵位置
sprite->SetPosition(x, y);

// 设置精灵缩放
sprite->SetScale(scale);

// 设置精灵旋转
sprite->SetRotation(angle);

// 设置精灵可见性
sprite->SetVisible(true);

// 设置精灵颜色
sprite->SetColor(r, g, b, a);
```

#### 特效创建

```cpp
// 创建特效
IEffect* effect = world->SetEffect(spriteId, "effect.plist");

// 设置特效持续时间
effect->SetDuration(1.0f);

// 设置特效位置
effect->SetPosition(x, y);

// 设置特效缩放
effect->SetScale(scale);
```

### 7. 引用计数和对象池

#### 引用计数

```cpp
// 增加引用计数
obj->AddRef();

// 减少引用计数
obj->Release();

// 获取引用计数
int GetRefCount() const;
```

#### 对象池

```cpp
// 创建对象池
NuclearObjectPool<ISprite> spritePool(100);

// 从对象池获取对象
ISprite* sprite = spritePool.Obtain();

// 归还对象到对象池
spritePool.Free(sprite);

// 清空对象池
spritePool.Clear();
```

### 8. NED Malloc分配器

#### 内存分配

```cpp
// 使用NED Malloc分配内存
void* ptr = NED_MALLOC(size);

// 使用NED Malloc分配并清零内存
void* ptr = NED_CALLOC(count, size);

// 使用NED Malloc重新分配内存
void* ptr = NED_REALLOC(ptr, newSize);

// 使用NED Malloc释放内存
NED_FREE(ptr);
```

### 9. 批量渲染和视锥裁剪

#### 批量渲染

```cpp
// 创建精灵批处理
ISpriteBatch* batch = spriteBatchManager->CreateBatch("spritesheet.png");

// 添加精灵到批处理
batch->AddSprite(sprite1);
batch->AddSprite(sprite2);
batch->AddSprite(sprite3);

// 渲染批处理
batch->Render();
```

#### 视锥裁剪

```cpp
// 设置视锥裁剪距离
env->SetViewFrustumCullingDistance(1000.0f);

// 启用视锥裁剪
env->SetViewFrustumCullingEnabled(true);

// 手动检查精灵是否在视锥内
bool IsInViewFrustum(ISprite* sprite);
```

---

## 🚨 常见陷阱

### 陷阱1: 线程安全问题

**错误**:
```cpp
// ❌ 错误：在非主线程调用Nuclear引擎API
std::thread workerThread([]() {
    world->NewSprite();  // 线程不安全！
});
```

**正确**:
```cpp
// ✅ 正确：在主线程调用Nuclear引擎API
void OnWorkerThreadComplete() {
    world->NewSprite();  // 主线程安全
}
```

### 陷阱2: 内存泄漏

**错误**:
```cpp
// ❌ 错误：忘记释放精灵
ISprite* sprite = world->NewSprite();
// 忘记调用 DeleteSprite
```

**正确**:
```cpp
// ✅ 正确：及时释放精灵
ISprite* sprite = world->NewSprite();
// 使用精灵...
world->DeleteSprite(sprite);
sprite = nullptr;
```

### 陷阱3: 引用计数错误

**错误**:
```cpp
// ❌ 错误：过度增加引用计数
obj->AddRef();
obj->AddRef();
obj->AddRef();  // 引用计数过高
```

**正确**:
```cpp
// ✅ 正确：正确管理引用计数
obj->AddRef();
// 使用对象...
obj->Release();  // 释放引用
```

### 陷阱4: 批量渲染对象数过多

**错误**:
```cpp
// ❌ 错误：批量渲染对象数过多
ISpriteBatch* batch = spriteBatchManager->CreateBatch("spritesheet.png");
for (int i = 0; i < 10000; i++) {
    batch->AddSprite(sprites[i]);  // 对象数过多
}
```

**正确**:
```cpp
// ✅ 正确：控制批量渲染对象数
ISpriteBatch* batch = spriteBatchManager->CreateBatch("spritesheet.png");
for (int i = 0; i < 1000; i++) {  // 控制在1000以内
    batch->AddSprite(sprites[i]);
}
batch->Render();
batch->Clear();  // 清空批处理
```

---

## 🛠️ 实践项目

### 项目1: 创建简单场景

**目标**: 创建一个包含背景和角色的简单场景

**步骤**:
1. 初始化Nuclear引擎
2. 创建场景
3. 添加背景精灵
4. 添加角色精灵
5. 设置相机
6. 运行引擎主循环

**代码示例**:
```cpp
bool CreateSimpleScene() {
    // 初始化引擎
    if (!engine->Initialize()) {
        return false;
    }

    // 获取世界管理器
    IWorld* world = engine->GetWorld();

    // 创建场景
    if (!world->LoadMap("simple.map")) {
        return false;
    }

    // 创建背景精灵
    ISprite* background = world->NewSprite();
    background->SetPosition(0, 0);
    background->SetScale(1.0f);

    // 创建角色精灵
    ISprite* character = world->NewSprite();
    character->SetPosition(100, 100);
    character->SetScale(1.0f);

    // 设置相机
    world->AttachCameraTo(character->GetId());

    return true;
}
```

### 项目2: 实现动画精灵

**目标**: 创建一个带有动画的精灵

**步骤**:
1. 创建精灵
2. 加载动画
3. 设置动画循环
4. 添加到场景
5. 更新动画

**代码示例**:
```cpp
ISprite* CreateAnimatedSprite(const char* spriteName, const char* animName) {
    // 创建精灵
    ISprite* sprite = world->NewSprite();
    sprite->SetName(spriteName);

    // 加载动画
    IAnimation* animation = animationManager->LoadAnimation(animName);
    animation->SetRepeatCount(-1);  // 无限循环

    // 设置精灵动画
    sprite->SetAnimation(animation);

    return sprite;
}
```

### 项目3: 实现特效系统

**目标**: 创建一个特效管理系统

**步骤**:
1. 创建特效管理器
2. 实现特效播放
3. 实现特效回收
4. 实现特效池
5. 集成到引擎

**代码示例**:
```cpp
class EffectManager {
public:
    EffectManager(IWorld* world) : m_world(world) {
        // 创建特效池
        m_effectPool = new NuclearObjectPool<IEffect>(50);
    }

    ~EffectManager() {
        delete m_effectPool;
    }

    IEffect* PlayEffect(int spriteId, const char* effectName) {
        // 从特效池获取特效
        IEffect* effect = m_effectPool->Obtain();
        if (!effect) {
            // 特效池已满，创建新特效
            effect = m_world->SetEffect(spriteId, effectName);
        } else {
            // 重用特效
            effect->Reset();
            effect->SetName(effectName);
            m_world->SetEffect(spriteId, effect);
        }

        // 设置完成回调
        effect->SetCompletionCallback([this, effect]() {
            // 归还特效到对象池
            m_effectPool->Free(effect);
        });

        return effect;
    }

private:
    IWorld* m_world;
    NuclearObjectPool<IEffect>* m_effectPool;
};
```

---

## 📚 参考资料

### 项目文档
- `tools/engine/docs/06-VS2013构建架构分析-VS2013-Build-Architecture-Analysis.md`（runtime-local；clean checkout 缺失时不可用）
- `tools/engine/docs/00-文档索引-Documentation-Index.md`（runtime-local；使用前先以当前工作区实物复核）
- [Nuclear 引擎工具文档](../../../.trae/references/nuclear-tools.md)
- [Nuclear 引擎开发规则](../../../.roo/rules/nuclear-engine-rules.md)

### 相关技能
- [C++ 开发指南](cpp-development.md)
- [Cocos2d-x 使用指南](cocos2dx-usage.md)
- [tolua++ 绑定开发](tolua-binding.md)

### 外部资源
- [Cocos2d-x 2.x 文档](https://docs.cocos.com/cocos2d-x/v2/)
- [OpenGL 2.0 规范](https://www.khronos.org/opengl/)

---

## ✅ 技能验证清单

### 基础能力
- [ ] 能够初始化Nuclear引擎
- [ ] 能够创建和删除精灵
- [ ] 能够创建和删除特效
- [ ] 能够设置相机位置和缩放
- [ ] 能够加载和卸载地图

### 进阶能力
- [ ] 能够使用IEngine接口管理引擎生命周期
- [ ] 能够使用IWorld接口管理游戏世界
- [ ] 能够使用IEnv接口配置渲染环境
- [ ] 能够使用IQuery接口查询游戏状态
- [ ] 能够实现批量渲染优化
- [ ] 能够实现视锥裁剪优化

### 高级能力
- [ ] 能够实现对象池管理
- [ ] 能够实现引用计数管理
- [ ] 能够使用NED Malloc分配器
- [ ] 能够实现性能优化技巧
- [ ] 能够排查内存泄漏问题
- [ ] 能够排查性能瓶颈问题

### 实践项目
- [ ] 完成项目1：创建简单场景
- [ ] 完成项目2：实现动画精灵
- [ ] 完成项目3：实现特效系统

---

## 📝 更新日志

| 版本 | 日期 | 变更 |
|-----|------|------|
| 1.0.0 | 2026-01-27 | 初始版本 |

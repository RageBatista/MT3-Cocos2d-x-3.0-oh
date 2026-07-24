# Nuclear 引擎集成指南

> 本文件定义了 MT3 项目中 Nuclear 引擎的集成规范，适用于 CEGUI 和 Cocos2d-x 技能。

## 引擎访问

### 获取引擎实例

```cpp
// 获取 Nuclear 引擎实例（必须检查 NULL）
Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
if (!engine) {
    // 处理引擎未初始化的情况
    return false;
}
```

### 渲染器操作

```cpp
// 获取渲染器
Nuclear::IRenderer* renderer = engine->GetRenderer();

// 重置设备（设备丢失时调用）
renderer->OnResetDevice();

// 重置所有纹理 uniform 名称
renderer->ResetAllTextureUName();

// 重新加载所有纹理
renderer->OnReloadAllTexture();

// 获取字体管理器
Nuclear::IFontManager* fontMan = renderer->GetFontManager();
```

## 特效管理

### Effect-Window 映射（CEGUI）

```cpp
// 定义映射表
std::map<Nuclear::IEffect*, CEGUI::Window*> m_mapUIEffect;

// 添加特效到 UI 窗口映射
m_mapUIEffect[pEffect] = pWindow;

// 移除特效映射
std::map<Nuclear::IEffect*, CEGUI::Window*>::iterator it = m_mapUIEffect.find(pEffect);
if (it != m_mapUIEffect.end()) {
    m_mapUIEffect.erase(it);
}

// 清理特效前必须从映射中移除
if (effect) {
    m_mapUIEffect.erase(effect);
    effectMan->DestroyEffect(effect);
}
```

### Sprite-Window 映射（CEGUI）

```cpp
// 定义映射表
std::map<UISprite*, CEGUI::Window*> m_mapWindowSprite;

// 添加精灵到窗口映射
m_mapWindowSprite[pSprite] = pWindow;

// 移除精灵映射
std::map<UISprite*, CEGUI::Window*>::iterator it = m_mapWindowSprite.find(pSprite);
if (it != m_mapWindowSprite.end()) {
    m_mapWindowSprite.erase(it);
}
```

### 特效生命周期管理

```cpp
// 创建特效
Nuclear::EffectManager* effectMan = engine->GetEffectManager();
Nuclear::IEffect* effect = effectMan->CreateEffect(...);

// 使用特效
// ...

// 销毁特效（必须检查映射表）
if (effect) {
    // 1. 从映射表中移除
    m_mapUIEffect.erase(effect);

    // 2. 销毁特效
    effectMan->DestroyEffect(effect);
    effect = nullptr;
}
```

## 渲染循环协调

### CEGUI 渲染循环

```cpp
// 渲染开始前：清理纹理状态
CEGUI::ImagesetManager::getSingleton().CleanUPTextureState();
CEGUI::System::getSingleton().getRenderer()->ResetRenderTextures();

// 渲染 CEGUI
CEGUI::System::getSingleton().renderGUI();

// 渲染完成后：更新纹理状态
CEGUI::ImagesetManager::getSingleton().UpdateTextureState();
```

### Cocos2d-x 渲染循环

```cpp
// Cocos2d-x 渲染由 CCDirector 管理
cocos2d::CCDirector* director = cocos2d::CCDirector::sharedDirector();
director->mainLoop();  // 包含场景更新和渲染
```

### 跨引擎渲染协调

```cpp
// 当同时使用 CEGUI 和 Cocos2d-x 时
void renderFrame() {
    // 1. 清理 CEGUI 纹理状态
    CEGUI::ImagesetManager::getSingleton().CleanUPTextureState();

    // 2. 渲染 Cocos2d-x 场景
    cocos2d::CCDirector::sharedDirector()->drawScene();

    // 3. 渲染 CEGUI
    CEGUI::System::getSingleton().renderGUI();

    // 4. 更新 CEGUI 纹理状态
    CEGUI::ImagesetManager::getSingleton().UpdateTextureState();
}
```

## 定时器管理

### 定时器回调定义

```cpp
// 定义定时器回调类
class MyTimerCallback : public Nuclear::ExecThread::CallbackTask {
public:
    MyTimerCallback() : Nuclear::ExecThread::CallbackTask(0) {}

    virtual void Execute() {
        // 定时器回调代码
        // 注意：此函数在主线程执行
    }

    virtual ~MyTimerCallback() {
        // 清理资源
    }
};
```

### 调度定时器

```cpp
// 创建定时器回调
MyTimerCallback* callback = new MyTimerCallback();

// 调度定时器（单位：毫秒）
Nuclear::GetEngine()->ScheduleTimer(callback, 1000);  // 1 秒后执行

// 保存回调指针以便取消
m_timerCallbacks.push_back(callback);
```

### 取消定时器

```cpp
// 取消定时器
if (callback) {
    Nuclear::GetEngine()->CancelTimer(callback);
    callback = nullptr;
}

// 清理所有定时器
for (auto it = m_timerCallbacks.begin(); it != m_timerCallbacks.end(); ++it) {
    Nuclear::GetEngine()->CancelTimer(*it);
    delete *it;
}
m_timerCallbacks.clear();
```

## 输入捕获管理

### 释放输入捕获

```cpp
// 安全释放输入捕获
void safeReleaseInput() {
    CEGUI::Window* captureWindow = CEGUI::Window::getCaptureWindow();
    if (captureWindow) {
        try {
            captureWindow->releaseInput();
        } catch (...) {
            // 处理异常
        }
    }
}
```

### 检查输入捕获状态

```cpp
// 检查是否有窗口捕获了输入
bool isInputCaptured() {
    return CEGUI::Window::getCaptureWindow() != nullptr;
}
```

## 背景模式协调

### 设置背景模式

```cpp
// 背景模式标志
bool s_bIsGameInBackground = false;

// 设置背景模式（影响 CEGUI 和 Cocos2d-x）
void setBackgroundMode(bool inBackground) {
    s_bIsGameInBackground = inBackground;

    // 通知 Cocos2d-x
    if (cocos2d::CCDirector::sharedDirector()) {
        cocos2d::CCDirector::sharedDirector()->SetBackgroundMode(inBackground);
    }

    // 通知 Nuclear 引擎
    Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
    if (engine) {
        if (inBackground) {
            // 暂停引擎
            engine->Pause();
        } else {
            // 恢复引擎
            engine->Resume();
        }
    }
}
```

## 引擎层访问

### 获取引擎层

```cpp
// 获取引擎层
Nuclear::EngineLayer* layer = static_cast<Nuclear::EngineLayer*>(
    Nuclear::GetEngine()->GetEngineLayer()
);

if (layer) {
    // 访问引擎层属性
    layer->m_LastTick = Nuclear::GetMilliSeconds();
}
```

## 错误处理

### 引擎未初始化

```cpp
// 检查引擎是否初始化
if (!Nuclear::GetEngine()) {
    // 记录错误日志
    LOG_ERROR("Nuclear engine not initialized");

    // 返回错误或使用默认行为
    return false;
}
```

### 特效创建失败

```cpp
// 创建特效时处理失败
Nuclear::IEffect* effect = effectMan->CreateEffect(...);
if (!effect) {
    LOG_ERROR("Failed to create effect");
    // 使用备用方案或返回错误
    return nullptr;
}
```

### 纹理加载失败

```cpp
// 重载纹理时处理失败
try {
    renderer->OnReloadAllTexture();
} catch (const std::exception& e) {
    LOG_ERROR("Failed to reload textures: %s", e.what());
    // 使用备用纹理或显示错误提示
}
```

## 性能优化建议

### 特效管理

- 复用特效对象，避免频繁创建/销毁
- 使用对象池管理常用特效
- 在场景切换时批量清理未使用的特效

### 渲染优化

- 减少渲染状态切换
- 批量处理相同类型的渲染操作
- 使用脏矩形技术只更新变化的区域

### 定时器优化

- 避免创建大量短周期定时器
- 使用单一定时器管理多个任务
- 在后台模式下暂停不必要的定时器

## 常见问题

### 问题：Nuclear::GetEngine() 返回 NULL

**原因**：引擎未初始化或已销毁

**解决方案**：
- 确保在引擎初始化后调用
- 检查初始化顺序
- 在使用前检查 NULL

### 问题：特效未显示

**原因**：特效未添加到渲染队列或映射表

**解决方案**：
- 确保特效已添加到 m_mapUIEffect
- 检查特效位置和大小
- 验证特效资源是否正确加载

### 问题：纹理状态不一致

**原因**：渲染循环顺序错误

**解决方案**：
- 确保 CleanUPTextureState 在渲染前调用
- 确保 UpdateTextureState 在渲染后调用
- 检查是否有其他代码修改了纹理状态

### 问题：定时器未触发

**原因**：定时器被取消或引擎暂停

**解决方案**：
- 检查定时器是否被意外取消
- 确保引擎未处于暂停状态
- 验证定时器回调是否正确注册

## 参考文档

- [Nuclear 引擎文档](../../engine/docs/)
- [CEGUI 技能](../cegui/SKILL.md)
- [Cocos2d-x 技能](../cocos2dx/SKILL.md)
- [公共约束](common-constraints.md)

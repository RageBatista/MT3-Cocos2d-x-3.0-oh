# 调试命令集合

> 本文件收集了 MT3 项目开发中常用的调试命令和搜索模式。

## 搜索命令（ripgrep）

### CEGUI 相关

```powershell
# 查找所有 CEGUI 资源文件
rg --files -g '*.layout' -g '*.scheme' -g '*.looknfeel' -g '*.imageset' -g '*.font' client

# 查找 CEGUI 相关代码
rg "CEGUI::" client

# 查找 CEGUI 管理器
rg "CEGUI::WindowManager|CEGUI::ImagesetManager|CEGUI::FontManager" client

# 查找事件订阅
rg "subscribeEvent" client

# 查找特定控件
rg "MyWidgetName" client

# 查找 CEGUI 初始化
rg "CEGUI::System::getSingleton" client

# 查找图片集管理
rg "CEGUI::ImagesetManager" client

# 查找字体管理
rg "CEGUI::FontManager" client

# 查找 UI 效果映射
rg "m_mapUIEffect|m_mapWindowSprite" client

# 查找纹理状态管理
rg "CleanUPTextureState|UpdateTextureState" client

# 查找输入捕获
rg "getCaptureWindow|releaseInput" client
```

### Cocos2d-x 相关

```powershell
# 查找 Cocos2d-x 相关代码
rg "CCDirector|CCScene|CCLayer|CCSprite|CCAnimation|CCAction" client engine cocos2d-2.0-rc2-x-2.0.1

# 查找精灵创建
rg "CCSprite.*create" client

# 查找动作使用
rg "runAction|CCAction" client

# 查找调度器
rg "schedule|unschedule" client

# 查找资源加载
rg "addSpriteFramesWithFile|addImage" client

# 查找坐标转换
rg "convertToNodeSpace|convertToWorldSpace" client

# 查找 CCDirector 使用
rg "CCDirector::sharedDirector" client

# 查找场景创建
rg "CCScene.*create" client

# 查找 plist 文件
rg --files -g '*.plist' client/resource
```

### Nuclear 引擎相关

```powershell
# 查找 Nuclear 引擎集成
rg "Nuclear::GetEngine|Nuclear::Engine|Nuclear::IRenderer" client

# 查找 Nuclear 特效
rg "Nuclear::IEffect|Nuclear::EffectManager" client

# 查找 Nuclear 定时器
rg "ScheduleTimer|CancelTimer" client

# 查找引擎层访问
rg "Nuclear::EngineLayer|GetEngineLayer" client

# 查找背景模式
rg "SetBackgroundMode" client
```

### tolua++ 相关

```powershell
# 查找 tolua++ 模块定义
rg "tolua_beginmodule|tolua_endmodule" client

# 查找 tolua++ 收集函数
rg "tolua_collect_" client/FireClient/Application/Framework/LuaFireClientWin32.cpp

# 查找 Lua 绑定
rg "tolua_FireClientWin32_open" client
```

### 资源文件

```powershell
# 查找所有资源文件
rg --files -g '*.png' -g '*.jpg' -g '*.plist' -g '*.xml' client/resource

# 查找特定资源
rg "resource_name" client/resource
```

## Visual Studio 调试

### 断点设置

```cpp
// 条件断点
// 在断点属性中设置条件：i == 10
for (int i = 0; i < 100; ++i) {
    // ...
}

// 数据断点
// 监视变量地址，当值改变时触发
int value = 0;
// 设置数据断点：&value

// 消息断点
// 在断点属性中设置消息：WM_LBUTTONDOWN
```

### 内存调试

```cpp
// 启用 CRT 内存泄漏检测
#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>

// 在程序入口
_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);

// 在程序退出时检查泄漏
// 输出窗口会显示泄漏信息

// 设置断点在特定分配
_CrtSetBreakAlloc(123);  // 在第 123 次分配时中断
```

### 输出调试信息

```cpp
// 使用 OutputDebugString
OutputDebugStringA("Debug message\n");

// 使用 printf（控制台输出）
printf("Debug message: %s\n", message);

// 使用 TRACE（MFC）
TRACE("Debug message: %s\n", message);

// 使用 CEGUI 日志
CEGUI::Logger::getSingleton().logEvent("Debug message", CEGUI::Informative);
```

## 性能分析

### FPS 监控

```cpp
// 监控 FPS
void monitorFPS() {
    static float lastTime = 0;
    static int frameCount = 0;

    float currentTime = getTickCount();
    frameCount++;

    if (currentTime - lastTime >= 1.0f) {
        float fps = frameCount / (currentTime - lastTime);
        printf("FPS: %.2f\n", fps);
        frameCount = 0;
        lastTime = currentTime;
    }
}
```

### 内存监控

```cpp
// 监控内存使用
void monitorMemory() {
    MEMORYSTATUSEX status;
    status.dwLength = sizeof(status);
    GlobalMemoryStatusEx(&status);

    printf("Memory load: %d%%\n", status.dwMemoryLoad);
    printf("Available physical memory: %lld MB\n", status.ullAvailPhys / (1024 * 1024));

    // Cocos2d-x 纹理数量
    CCTextureCache* cache = CCTextureCache::sharedTextureCache();
    printf("Texture count: %d\n", cache->textureCount());

    // Cocos2d-x 精灵帧数量
    CCSpriteFrameCache* frameCache = CCSpriteFrameCache::sharedSpriteFrameCache();
    printf("Sprite frame count: %d\n", frameCache->spriteFrames()->count());
}
```

### 性能计时

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

## 调试工具

### CEGUI 调试

```cpp
// 启用 CEGUI 日志
CEGUI::Logger::getSingleton().setLoggingLevel(CEGUI::Informative);

// 打印控件树
void printWidgetTree(CEGUI::Window* window, int depth = 0) {
    std::string indent(depth * 2, ' ');
    std::cout << indent << window->getName() << " (" << window->getType() << ")" << std::endl;

    for (size_t i = 0; i < window->getChildCount(); ++i) {
        printWidgetTree(window->getChildAtIdx(i), depth + 1);
    }
}

// 验证布局文件
void validateLayout(const std::string& layoutFile) {
    try {
        CEGUI::Window* window = CEGUI::WindowManager::getSingleton().loadWindowLayout(layoutFile);
        printf("Layout %s is valid\n", layoutFile.c_str());
        CEGUI::WindowManager::getSingleton().destroyWindow(window);
    } catch (const CEGUI::Exception& e) {
        printf("Layout %s is invalid: %s\n", layoutFile.c_str(), e.what());
    }
}
```

### Cocos2d-x 调试

```cpp
// 启用调试绘制
sprite->setDebugDraw(true);
this->setDebugDraw(true);

// 打印节点树
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

// 打印精灵帧缓存
void printSpriteFrameCache() {
    CCDictionary* frames = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrames();
    CCDictElement* element = NULL;
    CCDICT_FOREACH(frames, element) {
        printf("Sprite frame: %s\n", element->getStrKey());
    }
}
```

### Nuclear 引擎调试

```cpp
// 打印特效信息
void printEffectInfo(Nuclear::IEffect* effect) {
    if (!effect) {
        printf("Effect is NULL\n");
        return;
    }

    printf("Effect info:\n");
    printf("  Position: (%.1f, %.1f, %.1f)\n",
           effect->GetPosition().x, effect->GetPosition().y, effect->GetPosition().z);
    printf("  Active: %s\n", effect->IsActive() ? "Yes" : "No");
    // ... 更多信息
}

// 打印所有特效
void printAllEffects() {
    Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
    if (!engine) {
        printf("Engine is NULL\n");
        return;
    }

    Nuclear::EffectManager* effectMan = engine->GetEffectManager();
    // 打印所有特效信息
}
```

## 常见问题排查

### 资源加载失败

```powershell
# 检查文件是否存在
rg "MyLayout.layout" client/resource

# 检查路径是否正确
rg "loadWindowLayout|addSpriteFramesWithFile|addImage" client

# 检查 CEGUI 资源
rg --files -g '*.layout' -g '*.scheme' -g '*.looknfeel' client/resource

# 检查 Cocos2d-x 资源
rg --files -g '*.plist' -g '*.png' client/resource
```

### 内存泄漏

```powershell
# 查找 new/delete 不匹配
rg "new " client | rg -v "delete"
rg "delete " client | rg -v "new"

# 查找 retain/release 不匹配
rg "\.retain()" client
rg "\.release()" client

# 查找未释放的资源
rg "create\(\)" client | rg -v "autorelease\(\)"
```

### 性能问题

```powershell
# 查找频繁的内存分配
rg "new " client | rg "update|draw|render"

# 查找频繁的字符串操作
rg "\.c_str\(\)" client

# 查找频繁的文件操作
rg "fopen|fread|fwrite" client
```

## 日志分析

### 查找错误日志

```powershell
# 查找所有错误
rg "ERROR|Error|error" client

# 查找特定错误
rg "Failed to load|Not found|Cannot open" client

# 查找警告
rg "WARNING|Warning|warning" client
```

### 分析日志文件

```powershell
# 统计错误数量
rg "ERROR" client --count-matches

# 查找特定时间段的日志
rg "2025-01-27 10:" client

# 查找特定模块的日志
rg "CEGUI|Cocos2d|Nuclear" client
```

## 参考文档

- [公共约束](common-constraints.md)
- [错误处理](error-handling.md)
- [性能优化](performance-guide.md)

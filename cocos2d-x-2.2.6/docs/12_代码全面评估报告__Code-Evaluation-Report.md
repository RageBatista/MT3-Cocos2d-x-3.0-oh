# Cocos2d-x 2.0-rc2-x-2.0.1 代码全面评估报告

> **生成日期**: 2026-04-29
> **分析版本**: cocos2d-2.0-rc2-x-2.0.1
> **评估人**: AI 代码审计
> **评估范围**: cocos2dx/ 核心引擎代码、extensions/ 扩展模块、platform/ 平台抽象层

---

## 目录

- [一、代码结构与架构评估](#一代码结构与架构评估)
- [二、潜在 Bug 发掘](#二潜在-bug-发掘)
- [三、兼容性验证](#三兼容性验证)
- [四、性能瓶颈分析](#四性能瓶颈分析)
- [五、代码规范与质量检查](#五代码规范与质量检查)
- [六、安全隐患排查](#六安全隐患排查)
- [七、修复优先级排序](#七修复优先级排序)
- [八、总结与建议](#八总结与建议)
- [九、2026-04-29 复核结论与修复方案补充](#九2026-04-29-复核结论与修复方案补充)
- [十、项目负责人终审与修复启动计划](#十项目负责人终审与修复启动计划)

---

## 一、代码结构与架构评估

### 1.1 项目整体结构

```
cocos2d-2.0-rc2-x-2.0.1/
├── cocos2dx/               # 核心引擎代码
│   ├── actions/            # 动作系统（CCAction, CCActionManager 等）
│   ├── base_nodes/         # 基础节点（CCNode, CCAtlasNode）
│   ├── cocoa/              # 基础数据结构（CCObject, CCArray, CCDictionary, CCString 等）
│   ├── draw_nodes/         # 绘图节点（CCDrawNode）
│   ├── effects/            # 特效（CCGrid, CCGrabber）
│   ├── include/            # 公共头文件与宏定义
│   ├── kazmath/            # 数学库（矩阵、向量、四元数）
│   ├── keyboard_dispatch/  # 键盘事件分发
│   ├── label_nodes/        # 文字标签（CCLabelTTF, CCLabelAtlas）
│   ├── layers_scenes_transitions_nodes/  # 场景、层与转场
│   ├── menu_nodes/         # 菜单节点
│   ├── misc_nodes/         # 杂项节点（CCRenderTexture, CCLightFlash）
│   ├── particle_nodes/     # 粒子系统（CCParticleSystem, CCParticleSystemQuad）
│   ├── platform/           # 平台抽象层（Win32/iOS/Android/WP8 等）
│   ├── shaders/            # 着色器与 GL 状态缓存
│   ├── sprite_nodes/       # 精灵（CCSprite, CCSpriteBatchNode, CCSpriteFrameCache）
│   ├── support/            # 辅助工具（CCNotificationCenter, CCUserDefault, CCProfiling）
│   ├── textures/           # 纹理管理（CCTexture2D, CCTextureCache）
│   ├── tileMap_parallax_nodes/  # 瓦片地图与视差节点
│   └── touch_dispatcher/   # 触摸事件分发
├── Box2D/                  # Box2D 物理引擎
├── chipmunk/               # Chipmunk 物理引擎（备选）
├── extensions/             # 扩展模块（CCBReader, CCNotificationCenter, CCPhysicsSprite 等）
├── scripting/              # 脚本绑定（Lua, JavaScript）
└── CocosDenshion/          # 音频引擎
```

### 1.2 核心架构层次

```
┌─────────────────────────────────────────────┐
│            应用层（Game Code）                │
├─────────────────────────────────────────────┤
│  CCDirector  │  CCScene  │  CCScheduler     │  ← 导演/场景/调度
├─────────────────────────────────────────────┤
│  CCNode  │  CCSprite  │  CCAction           │  ← 节点/精灵/动作
├─────────────────────────────────────────────┤
│  CCTexture2D  │  CCGLProgram  │  GL State   │  ← 渲染资源
├─────────────────────────────────────────────┤
│  CCObject  │  CCArray  │  CCDictionary      │  ← 基础数据结构
├─────────────────────────────────────────────┤
│  Platform Abstraction Layer                 │  ← 平台抽象
│  (Win32 / iOS / Android / WP8 / ...)       │
└─────────────────────────────────────────────┘
```

### 1.3 架构评估结论

| 评估维度 | 评分 | 说明 |
|----------|------|------|
| 模块划分 | ★★★☆☆ | 模块边界基本清晰，但存在跨层直接依赖（如 CCDirector 直接 new 各子系统） |
| 单例模式 | ★★☆☆☆ | 大量使用全局单例（CCDirector、CCTextureCache、CCSpriteFrameCache 等），测试困难，生命周期管理复杂 |
| 平台抽象 | ★★★★☆ | 通过宏和平台子目录实现了较好的平台隔离，但 WP8 路径维护成本高 |
| 内存管理 | ★★★☆☆ | 引用计数 + 自动释放池基本可用，但存在多处不一致和生命周期缺陷 |
| 扩展性 | ★★★☆☆ | 扩展模块机制存在，但与核心耦合较紧 |

---

## 二、潜在 Bug 发掘

### 🔴 严重级别（P0 — 可能导致崩溃或数据损坏）

---

#### BUG-001：CCArray::initWithObjects 逻辑反转

- **文件**: `cocos2dx/cocoa/CCArray.cpp:242`
- **严重程度**: 🔴 致命
- **问题描述**: `CC_BREAK_IF(pObject != NULL)` 条件逻辑完全反转。当传入第一个对象不为 NULL 时，`CC_BREAK_IF` 直接跳出 do-while 循环，导致函数永远无法正常初始化数组。正确条件应为 `CC_BREAK_IF(pObject == NULL)`。
- **影响范围**: 任何使用 `initWithObjects` 初始化 CCArray 的代码都会静默失败，返回空数组。此方法为 CCArray 的核心初始化接口之一。
- **复现条件**: 调用 `CCArray::create(obj1, obj2, ..., NULL)` 或 `array->initWithObjects(obj1, obj2, ..., NULL)` 时必现。
- **修复方案**:

```cpp
// 修改前（错误）
CC_BREAK_IF(pObject != NULL);

// 修改后（正确）
CC_BREAK_IF(pObject == NULL);
```

- **验证方法**: 编写单元测试，验证 `CCArray::create(obj1, obj2, NULL)` 返回包含 2 个元素的数组。

---

#### BUG-002：malloc/free 与 new/delete 混用

- **文件**: `cocos2dx/textures/CCTexture2D.cpp:342` 及 `CCTexture2D.cpp:879`
- **严重程度**: 🔴 严重
- **问题描述**: `pPixBuffer` 通过 `malloc()` 分配内存，但使用 `CC_SAFE_DELETE_ARRAY`（即 `delete[]`）释放。C++ 标准规定 `malloc` 分配的内存必须用 `free` 释放，`new` 分配的内存必须用 `delete` 释放。混用是未定义行为。
- **影响范围**: 在某些编译器/平台上可能导致堆损坏、崩溃或内存泄漏。MT3 项目使用 MSVC v120 编译，Debug 模式下堆检查更严格，可能触发断言。
- **修复方案**:

```cpp
// 修改前（错误）
pPixBuffer = (GLvoid*)malloc(BufferSize);
// ... 使用 ...
CC_SAFE_DELETE_ARRAY(pPixBuffer);

// 修改后（正确）
pPixBuffer = (GLvoid*)malloc(BufferSize);
// ... 使用 ...
free(pPixBuffer);
pPixBuffer = NULL;
```

- **涉及位置**:
  - `CCTexture2D::initWithData()` — 约 342 行
  - `CCTexture2D::initWithDDSCompressData()` — 约 879 行

---

#### BUG-003：CCTexture2D::initWithDDSCompressData 中逻辑条件永远为 false

- **文件**: `cocos2dx/textures/CCTexture2D.cpp:851`
- **严重程度**: 🔴 致命
- **问题描述**: 条件 `pixelFormat == kCCTexture2DPixelFormat_DXT3 && pixelFormat == kCCTexture2DPixelFormat_DXT5` 永远为 false，因为 pixelFormat 不可能同时等于两个不同的枚举值。应为 `||` 运算符。
- **影响范围**: DXT3/DXT5 格式纹理的半分辨率缩放逻辑永远不会执行，导致特定压缩纹理格式渲染异常。
- **修复方案**:

```cpp
// 修改前（错误）
if (data != NULL && pixelFormat == kCCTexture2DPixelFormat_DXT3 && pixelFormat == kCCTexture2DPixelFormat_DXT5 && CCImage::IsNormal() && m_uPixelsWide % 2 == 0 && m_uPixelsHigh % 2 == 0)

// 修改后（正确）
if (data != NULL && (pixelFormat == kCCTexture2DPixelFormat_DXT3 || pixelFormat == kCCTexture2DPixelFormat_DXT5) && CCImage::IsNormal() && m_uPixelsWide % 2 == 0 && m_uPixelsHigh % 2 == 0)
```

---

#### BUG-004：CCTouchDispatcher::touches 中 unsigned int 无符号比较

- **文件**: `cocos2dx/touch_dispatcher/CCTouchDispatcher.cpp:321`
- **严重程度**: 🔴 严重
- **问题描述**: `CCAssert(uIndex >= 0 && uIndex < 4, "")` 中 `uIndex` 类型为 `unsigned int`，`uIndex >= 0` 永远为 true，断言无法检测负值溢出。如果传入负值（通过隐式类型转换），会被截断为大正数，可能导致越界访问。
- **影响范围**: 触摸事件分发中的安全检查形同虚设。
- **修复方案**:

```cpp
// 修改前（错误 — unsigned int 与 0 比较永远为 true）
CCAssert(uIndex >= 0 && uIndex < 4, "");

// 修改后（方案 A：改类型）
void CCTouchDispatcher::touches(CCSet *pTouches, CCEvent *pEvent, int uIndex)
{
    CCAssert(uIndex >= 0 && uIndex < 4, "");

// 修改后（方案 B：保留 unsigned，移除无效检查）
CCAssert(uIndex < 4, "");
```

---

### 🟠 高级别（P1 — 可能导致功能异常或资源泄漏）

---

#### BUG-005：CCDictionary 键截断导致键冲突

- **文件**: `cocos2dx/cocoa/CCDictionary.h:44-60`
- **严重程度**: 🟠 高
- **问题描述**: `MAX_KEY_LEN` 为 256，当键长度超过 256 时，截取末尾 255 个字符。不同前缀但相同后缀的键会产生冲突，导致数据覆盖。
- **影响范围**: 使用长键名（超过 256 字符）存储数据时，可能静默覆盖已有数据，极难排查。
- **问题代码**:

```cpp
#define MAX_KEY_LEN  256

int len = strlen(pszKey);
if (len > MAX_KEY_LEN)
{
    char* pEnd = (char*)&pszKey[len-1];
    pStart = pEnd - (MAX_KEY_LEN-1);
}
strcpy(m_szKey, pStart);  // 不安全的 strcpy
```

- **修复方案**: 使用 `std::string` 替代固定大小字符数组存储键，彻底消除截断和溢出风险。

---

#### BUG-006：CCTextureCache 异步加载线程资源泄漏

- **文件**: `cocos2dx/textures/CCTextureCache.cpp:270-290`
- **严重程度**: 🟠 高
- **问题描述**: 析构函数设置 `need_quit = true` 并发送信号量，但从未调用 `pthread_join` 等待线程退出，也未调用 `pthread_mutex_destroy` 销毁互斥锁。
- **影响范围**: 线程资源泄漏，互斥锁未销毁。在多次创建/销毁 TextureCache 时可能死锁。
- **修复方案**:

```cpp
CCTextureCache::~CCTextureCache()
{
    CCLOGINFO("cocos2d: deallocing CCTextureCache.");
    need_quit = true;

    if (s_pSem != NULL)
    {
#if CC_TARGET_PLATFORM == CC_PLATFORM_WP8
        {
            std::unique_lock<std::mutex> lock;
            s_pSem->_condition.notify_one();
            s_pSem->_val++;
        }
#else
        sem_post(s_pSem);
#endif
    }

    // 新增：等待异步线程退出
    if (s_loadingThread)
    {
        pthread_join(s_loadingThread, NULL);
        s_loadingThread = 0;
    }

    // 新增：销毁互斥锁
    pthread_mutex_destroy(&s_asyncStructQueueMutex);

    CC_SAFE_RELEASE(m_pTextures);
}
```

---

#### BUG-007：CCGLProgram::initWithVertexShaderFilename 临时对象生命周期问题

- **文件**: `cocos2dx/shaders/CCGLProgram.cpp:115-119`
- **严重程度**: 🟠 高
- **问题描述**: `CCString::createWithContentsOfFile()` 返回 autorelease 对象，`getCString()` 返回内部缓冲区指针。当临时 CCString 在 autorelease pool 清理后，指针悬空。
- **影响范围**: 着色器源码可能被提前释放，导致着色器编译失败或读取垃圾数据。
- **修复方案**:

```cpp
// 修改前（危险）
bool CCGLProgram::initWithVertexShaderFilename(const char* vShaderFilename, const char* fShaderFilename)
{
    return this->initWithVertexShaderByteArray(
        CCString::createWithContentsOfFile(vShaderFilename)->getCString(),  // 临时对象，生命周期不确定
        CCString::createWithContentsOfFile(fShaderFilename)->getCString());
}

// 修改后（安全）
bool CCGLProgram::initWithVertexShaderFilename(const char* vShaderFilename, const char* fShaderFilename)
{
    CCString* vStr = CCString::createWithContentsOfFile(vShaderFilename);
    CCString* fStr = CCString::createWithContentsOfFile(fShaderFilename);
    vStr->retain();
    fStr->retain();
    bool ret = this->initWithVertexShaderByteArray(vStr->getCString(), fStr->getCString());
    vStr->release();
    fStr->release();
    return ret;
}
```

---

#### BUG-008：CCFileUtils::fullPathFromRelativeFile 返回悬空指针

- **文件**: `cocos2dx/platform/win32/CCFileUtils.cpp:183-189`
- **严重程度**: 🟠 高
- **问题描述**: 创建 autorelease 的 CCString 对象并返回其 `m_sString.c_str()` 指针。autorelease 对象在当前帧结束时释放，返回的指针变为悬空指针。
- **影响范围**: 调用者若在当前帧外使用返回的字符串指针，会访问已释放内存。
- **修复方案**: 返回 `std::string` 值而非原始指针，或修改接口返回 CCString* 并约定所有权。

---

#### BUG-009：CCEGLView 中 TerminateProcess 强制终止进程

- **文件**: `cocos2dx/platform/win32/CCEGLView.cpp:329-335`
- **严重程度**: 🟠 高
- **问题描述**: `WM_CLOSE` 和 `WM_DESTROY` 消息处理中直接调用 `TerminateProcess` 强制终止进程，跳过所有 C++ 析构函数和资源清理。
- **影响范围**: 无法正常释放 GPU 资源、保存用户数据、断开网络连接。虽然注释解释了原因（OLE/IE 宿主僵尸状态），但应提供优雅退出的替代方案。
- **修复方案**:

```cpp
// 修改前
case WM_CLOSE:
    ::TerminateProcess(::GetCurrentProcess(), 0);
    return 0;

case WM_DESTROY:
    destroyGL();
    PostQuitMessage(0);
    ::TerminateProcess(::GetCurrentProcess(), 0);
    break;

// 修改后：先尝试优雅退出
case WM_CLOSE:
    destroyGL();
    PostQuitMessage(0);
    return 0;

case WM_DESTROY:
    destroyGL();
    PostQuitMessage(0);
    break;
```

> **注意**: 如果 OLE/IE 宿主僵尸状态是真实问题，应在应用层处理，而非在引擎层强制终止进程。

---

### 🟡 中级别（P2 — 可能导致性能问题或偶发异常）

---

#### BUG-010：CCScheduler 中 malloc/calloc 分配的节点未检查返回值

- **文件**: `cocos2dx/CCScheduler.cpp:267-431`
- **严重程度**: 🟡 中
- **问题描述**: `calloc` 和 `malloc` 的返回值未做 NULL 检查，在内存不足时会空指针解引用导致崩溃。
- **修复方案**: 添加 NULL 检查或使用 `CC_SAFE_NEW` 宏。

---

#### BUG-011：CCParticleSystemQuad::allocMemory 中 malloc(0) 行为不确定

- **文件**: `cocos2dx/particle_nodes/CCParticleSystemQuad.cpp:511-527`
- **严重程度**: 🟡 中
- **问题描述**: `m_uTotalParticles` 可能为 0，导致 `malloc(0)` 行为不确定（标准规定实现定义，可能返回 NULL 或非 NULL 不可用指针）。
- **修复方案**: 添加 `m_uTotalParticles > 0` 的前置检查。

---

#### BUG-012：CCNotificationCenter 在迭代中删除元素

- **文件**: `cocos2dx/support/CCNotificationCenter.cpp:97-108`
- **严重程度**: 🟡 中
- **问题描述**: `removeObserver` 在 `CCARRAY_FOREACH` 迭代中调用 `removeObject`，可能导致迭代器失效。`postNotification` 中通过复制数组规避了此问题，但 `removeObserver` 和 `unregisterScriptObserver` 没有。
- **影响范围**: 在通知回调中移除观察者可能导致崩溃或跳过后续观察者。
- **修复方案**: 采用与 `postNotification` 相同的复制数组策略，或使用安全删除标记 + 延迟删除。

---

#### BUG-013：CCSpriteFrameCache::addSpriteFramesWithDictionary 中重复帧名静默跳过

- **文件**: `cocos2dx/sprite_nodes/CCSpriteFrameCache.cpp:109-113`
- **严重程度**: 🟡 中
- **问题描述**: 当 spriteFrameName 已存在时直接 `continue`，不输出任何警告。在 plist 文件包含重复帧名时，开发者无法感知冲突。
- **修复方案**: 添加 `CCLOGWARN` 警告日志。

---

## 三、兼容性验证

### COMPAT-001：PVRTC 格式仅在 iOS 平台编译

- **文件**: `cocos2dx/textures/CCTexture2D.cpp:762-771`
- **严重程度**: 🟠 高
- **问题描述**: PVRTC 格式变量 `format` 的赋值被 `#if(CC_PLATFORM_IOS == CC_TARGET_PLATFORM)` 包裹，其他平台 `format` 变量未初始化即传入 `glCompressedTexImage2D`。
- **影响范围**: 非 iOS 平台加载 PVRTC 纹理时传入未初始化的 format 值，导致 GL 错误。
- **修复方案**: 在 `#if` 外提供默认 format 值或提前返回错误。

---

### COMPAT-002：WP8 平台线程模型差异

- **文件**: `cocos2dx/textures/CCTextureCache.cpp:84-381`
- **严重程度**: 🟡 中
- **问题描述**: WP8 使用 `std::thread` + 自定义信号量结构，其他平台使用 pthread + POSIX 信号量。两套代码路径维护成本高，且 WP8 路径中 `pthread_mutex_destroy` 被定义为空操作。
- **影响范围**: WP8 平台互斥锁资源无法正确释放。
- **修复方案**: 统一使用 C++11 线程原语（`std::thread`, `std::mutex`, `std::condition_variable`），消除平台分支。

---

### COMPAT-003：CCPhysicsSprite 编译时必须启用物理引擎宏

- **文件**: `extensions/physics_nodes/CCPhysicsSprite.h:30-33`
- **严重程度**: 🟡 中
- **问题描述**: 若未定义 `CC_ENABLE_CHIPMUNK_INTEGRATION` 或 `CC_ENABLE_BOX2D_INTEGRATION`，直接触发 `#error`。无法在不启用物理引擎时编译包含此头文件的工程。
- **影响范围**: 增加了编译配置复杂度，MT3 项目当前未使用此模块但可能被间接包含。
- **修复方案**: 将 `#error` 改为编译警告，或将 CCPhysicsSprite 移到可选编译模块中。

---

### COMPAT-004：Win32 平台使用原生 OpenGL 2.0 而非 OpenGL ES

- **文件**: 项目全局
- **严重程度**: 🟢 低
- **问题描述**: Win32 使用 `opengl32.lib + glew32.lib`（桌面 OpenGL），而 Android/iOS 使用 OpenGL ES。`glGetTexImage`、`glTexImage2D` 等调用在两个 API 间行为有差异。
- **影响范围**: 纹理上传/下载代码在 Win32 和移动平台间存在微妙差异，需仔细验证。
- **修复方案**: 已通过宏隔离处理，但需持续关注 GL 调用的跨平台一致性。

---

### COMPAT-005：CCFileUtils 各平台实现差异

- **文件**: `cocos2dx/platform/*/CCFileUtils.cpp`
- **严重程度**: 🟡 中
- **问题描述**: 各平台的文件路径处理、资源搜索逻辑存在差异。Win32 版本使用反斜杠路径，iOS/Android 使用正斜杠。`isFileExist` 在不同平台的行为不一致。
- **修复方案**: 统一路径分隔符处理，确保所有平台行为一致。

---

## 四、性能瓶颈分析

### PERF-001：CCTextureCache 同步加载阻塞主线程

- **文件**: `cocos2dx/textures/CCTextureCache.cpp:490+`
- **严重程度**: 🟡 中
- **问题描述**: `addImage` 同步版本在主线程执行文件 I/O 和纹理上传，大纹理加载会导致明显卡顿。
- **优化建议**: 对非首帧必需的纹理，统一使用 `addImageAsync`。

---

### PERF-002：CCSpriteBatchNode 默认容量过小导致频繁扩容

- **文件**: `cocos2dx/sprite_nodes/CCSpriteBatchNode.cpp:83-100`
- **严重程度**: 🟡 中
- **问题描述**: `kDefaultSpriteBatchCapacity` 默认值较小（29），当子节点数量超过容量时，CCTextureAtlas 需要重新分配内存并复制所有已有数据。
- **优化建议**: 根据实际使用场景设置合理的初始容量，或在 `initWithTexture` 时预留足够空间。

---

### PERF-003：CCGLStateCache 纹理绑定缓存粒度不足

- **文件**: `cocos2dx/shaders/ccGLStateCache.cpp:130-165`
- **严重程度**: 🟢 低
- **问题描述**: 纹理绑定缓存只跟踪当前活跃纹理单元上的纹理 ID，切换纹理单元后缓存失效。多纹理混合渲染时产生大量冗余 `glBindTexture` 调用。
- **优化建议**: 为每个纹理单元维护独立的绑定缓存数组。

---

### PERF-004：CCParticleSystemQuad VBO 每帧重上传

- **文件**: `cocos2dx/particle_nodes/CCParticleSystemQuad.cpp:456`
- **严重程度**: 🟢 低
- **问题描述**: 粒子系统使用 `GL_DYNAMIC_DRAW` 标记的 VBO，每帧通过 `glBufferSubData` 或 `glBufferData` 更新全部粒子数据。当粒子数量大时，CPU-GPU 数据传输成为瓶颈。
- **优化建议**: 考虑使用 transform feedback 或 compute shader 在 GPU 端更新粒子状态（需 OpenGL 3.3+ 支持）。

---

### PERF-005：CCRenderTexture 分配全零缓冲区仅用于初始化纹理

- **文件**: `cocos2dx/misc_nodes/CCRenderTexture.cpp:190-200`
- **严重程度**: 🟢 低
- **问题描述**: `malloc + memset(0) + initWithData + free` 流程分配了完整的像素缓冲区仅用于清零纹理。对于大尺寸 RenderTexture（如 2048x2048），这是 16MB+ 的不必要内存开销。
- **优化建议**: 使用 `glClearTexImage`（OpenGL 4.4+）或通过 FBO `glClear` 实现零初始化。

---

### PERF-006：CCDirector::drawScene 每帧调用 unnecessary 计算

- **文件**: `cocos2dx/CCDirector.cpp:250+`
- **严重程度**: 🟢 低
- **问题描述**: 每帧都计算 FPS、更新动画间隔等，即使场景没有变化也会执行完整渲染流程。
- **优化建议**: 添加脏标记机制，仅在场景变化时执行完整渲染。

---

## 五、代码规范与质量检查

### STYLE-001：不安全的 C 字符串函数

- **文件**: 多处
- **严重程度**: 🟡 中
- **问题描述**: 大量使用 `sprintf`、`strcpy`、`strcat`、`atoi`、`atof` 等不安全函数，缺少缓冲区边界检查。
- **严重实例**:

| 文件 | 行号 | 问题代码 | 风险 |
|------|------|----------|------|
| `CCUserDefault.cpp` | 333 | `sprintf(tmp, "%d", value)` | 缓冲区大小未知 |
| `CCFileUtils.cpp` | 84 | `strcpy(s_pszResourcePath, pszResourcePath)` | 虽有长度断言但未使用安全版本 |
| `CCBReader.cpp` | 395-396 | `strcpy + strcat` 组合 | 无边界检查 |
| `CCDictionary.h` | 58 | `strcpy(m_szKey, pStart)` | 键截断后仍可能溢出 |

- **修复建议**: 替换为 `snprintf`、`strcpy_s`、`strncpy` 等安全替代。

---

### STYLE-002：注释掉的代码残留

- **文件**: `CCTexture2D.cpp:346-410` 等多处
- **严重程度**: 🟢 低
- **问题描述**: 大量被注释掉的代码块（像素转换、帧缓冲操作等），增加阅读难度，且注释中可能包含有价值的逻辑。
- **修复建议**: 清理无用注释代码，有价值逻辑移入版本控制历史。

---

### STYLE-003：命名不一致

- **严重程度**: 🟢 低
- **问题描述**:
  - 成员变量前缀不统一：`m_`（大部分）、`s_`（静态）、`m_pob`（指针对象）、`m_ob`（对象）混用
  - 方法命名风格混用：`sharedDirector()`（ObjC 风格）vs `getInstance()`（Java 风格）
  - 匈牙利命名法部分使用：`m_uID`（unsigned）、`m_bPaused`（bool）vs `m_fDeltaTime`（float）
- **修复建议**: 统一命名规范，新代码遵循一种风格即可，旧代码不做大规模重命名。

---

### STYLE-004：CCAssert 在 Release 模式下被移除

- **文件**: 全局
- **严重程度**: 🟡 中
- **问题描述**: `CCAssert` 在 Release 构建中被完全移除，意味着所有参数校验和前置条件检查在发布版本中不存在。多处代码依赖 CCAssert 进行 NULL 检查和边界验证。
- **修复建议**: 对关键路径添加 Release 模式下的防御性检查：

```cpp
// 修改前
CCAssert(ptr != NULL, "ptr is null");
ptr->doSomething();

// 修改后
CCAssert(ptr != NULL, "ptr is null");
if (!ptr) return;  // Release 防御
ptr->doSomething();
```

---

### STYLE-005：头文件包含顺序不规范

- **文件**: 多处
- **严重程度**: 🟢 低
- **问题描述**: 部分文件先包含自身头文件，部分先包含系统头文件，缺少统一的包含顺序规范。
- **修复建议**: 遵循 Google C++ Style Guide 的包含顺序：对应头文件 → C 系统头文件 → C++ 系统头文件 → 其他库头文件 → 项目内头文件。

---

## 六、安全隐患排查

### SEC-001：文件路径注入

- **文件**: `cocos2dx/platform/win32/CCFileUtils.cpp:202`
- **严重程度**: 🟠 高
- **问题描述**: `getFileData` 直接使用传入的文件名打开文件，未对路径进行规范化或沙箱检查。恶意构造的路径（如 `../../../etc/passwd` 或 `..\\..\\Windows\\System32\\config\\SAM`）可能读取任意文件。
- **修复方案**: 添加路径规范化，限制在资源目录内访问：

```cpp
std::string CCFileUtils::normalizePath(const std::string& path)
{
    std::string result = path;
    // 移除 .. 和 . 组件
    // 确保结果路径在资源目录内
    // 如果路径逃逸出资源目录，返回空字符串
    return result;
}
```

---

### SEC-002：XML 解析无实体限制

- **文件**: `cocos2dx/platform/CCSAXParser.cpp`
- **严重程度**: 🟠 高
- **问题描述**: SAX 解析器未限制 XML 实体扩展，可能遭受 XXE（XML External Entity）攻击或 XML 炸弹（Billion Laughs attack）。
- **修复方案**: 禁用外部实体解析，限制实体扩展深度。对于 libxml2：

```cpp
xmlSAXHandlerPtr handler = xmlSAXDefaultVersion(2);  // 使用 SAX2
// 禁用外部实体
xmlSetFeature(parser, "http://xml.org/sax/features/external-general-entities", false);
xmlSetFeature(parser, "http://xml.org/sax/features/external-parameter-entities", false);
```

---

### SEC-003：CCUserDefault 明文存储敏感数据

- **文件**: `cocos2dx/support/CCUserDefault.cpp`
- **严重程度**: 🟡 中
- **问题描述**: 用户偏好数据以明文 XML 存储在文件系统中，无加密保护。`atoi`/`atof` 解析无错误处理。
- **修复方案**: 敏感数据加密存储，解析时添加错误处理。

---

### SEC-004：CCImage 文件格式解析缺少充分验证

- **文件**: `cocos2dx/platform/CCImageCommon_cpp.h`
- **严重程度**: 🟠 高
- **问题描述**: PNG/TIFF/WebP 等图像格式的解析代码中，对图像尺寸、缓冲区大小的验证不够充分。恶意构造的图像文件可能导致缓冲区溢出。
- **修复方案**:
  - 添加图像尺寸上限检查（如最大 8192x8192）
  - 验证缓冲区分配大小与图像数据一致性
  - 对每行像素数据长度进行校验

---

### SEC-005：CCNotificationCenter 观察者未验证 target 有效性

- **文件**: `cocos2dx/support/CCNotificationCenter.cpp`
- **严重程度**: 🟡 中
- **问题描述**: `postNotification` 调用 `observer->performSelector(object)` 时不验证 target 对象是否已被释放。如果 target 被销毁但未调用 `removeObserver`，会访问已释放内存。
- **修复方案**: 使用弱引用或在 target 析构时自动移除观察者。

---

## 七、修复优先级排序

> **终审裁决说明**：本章保留原始初评排序，便于追溯第一次审计判断；实际修复排期以第九章复核结论和第十章项目启动计划为准。尤其是 BUG-003、BUG-007、PERF-003 等条目，已经在第九章重新定性，禁止按本章旧排序直接改源码。

### 7.1 综合优先级表

| 优先级 | 编号 | 问题 | 严重程度 | 修复复杂度 | 预估工时 |
|--------|------|------|----------|-----------|---------|
| **1** | BUG-001 | CCArray::initWithObjects 逻辑反转 | 🔴 致命 | 低 | 0.5h |
| **2** | BUG-003 | DDS 压缩格式条件永远为 false | 🔴 致命 | 低 | 0.5h |
| **3** | BUG-002 | malloc/free 与 new/delete 混用 | 🔴 严重 | 低 | 1h |
| **4** | BUG-004 | unsigned int 无符号比较 | 🔴 严重 | 低 | 0.5h |
| **5** | BUG-007 | 着色器源码临时对象生命周期 | 🟠 高 | 中 | 2h |
| **6** | BUG-008 | fullPathFromRelativeFile 悬空指针 | 🟠 高 | 中 | 2h |
| **7** | BUG-006 | 异步加载线程资源泄漏 | 🟠 高 | 中 | 3h |
| **8** | BUG-009 | TerminateProcess 强制终止 | 🟠 高 | 高 | 4h |
| **9** | BUG-005 | CCDictionary 键截断冲突 | 🟠 高 | 高 | 8h |
| **10** | COMPAT-001 | PVRTC format 未初始化 | 🟠 高 | 低 | 1h |
| **11** | SEC-001 | 文件路径注入 | 🟠 高 | 中 | 4h |
| **12** | SEC-004 | 图像解析缓冲区验证 | 🟠 高 | 高 | 8h |
| **13** | BUG-012 | NotificationCenter 迭代中删除 | 🟡 中 | 低 | 1h |
| **14** | BUG-010 | Scheduler malloc 未检查返回值 | 🟡 中 | 低 | 1h |
| **15** | BUG-011 | 粒子系统 malloc(0) | 🟡 中 | 低 | 0.5h |
| **16** | BUG-013 | SpriteFrameCache 重复帧名静默跳过 | 🟡 中 | 低 | 0.5h |
| **17** | PERF-001 | 同步纹理加载阻塞 | 🟡 中 | 中 | 4h |
| **18** | STYLE-001 | 不安全字符串函数 | 🟡 中 | 中 | 8h |
| **19** | STYLE-004 | Release 模式 CCAssert 移除 | 🟡 中 | 高 | 16h |
| **20** | SEC-002 | XML 实体攻击 | 🟠 高 | 中 | 4h |
| **21** | SEC-003 | 明文存储 | 🟡 中 | 中 | 4h |
| **22** | SEC-005 | 观察者 target 有效性 | 🟡 中 | 中 | 4h |
| **23** | COMPAT-002 | WP8 线程模型差异 | 🟡 中 | 高 | 16h |
| **24** | COMPAT-005 | FileUtils 平台差异 | 🟡 中 | 中 | 8h |
| **25** | PERF-002 | BatchNode 容量扩容 | 🟡 中 | 低 | 1h |
| **26** | PERF-003 | GL 状态缓存粒度 | 🟢 低 | 中 | 4h |
| **27** | PERF-004 | 粒子 VBO 每帧重上传 | 🟢 低 | 高 | 16h |
| **28** | PERF-005 | RenderTexture 零初始化 | 🟢 低 | 中 | 2h |
| **29** | COMPAT-003 | 物理引擎编译宏 | 🟡 中 | 低 | 1h |
| **30** | COMPAT-004 | OpenGL vs OpenGL ES | 🟢 低 | 高 | — |
| **31** | STYLE-002 | 注释代码残留 | 🟢 低 | 低 | 2h |
| **32** | STYLE-003 | 命名不一致 | 🟢 低 | 高 | — |
| **33** | STYLE-005 | 头文件包含顺序 | 🟢 低 | 低 | 4h |
| **34** | PERF-006 | Director 每帧不必要计算 | 🟢 低 | 中 | 4h |

### 7.2 分阶段修复路线

#### 第一阶段：紧急修复（建议立即执行）

| 编号 | 修复内容 | 预估工时 |
|------|---------|---------|
| BUG-001 | CCArray::initWithObjects 逻辑反转 | 0.5h |
| BUG-003 | DDS 压缩格式条件永远为 false | 0.5h |
| BUG-002 | malloc/free 与 new/delete 混用 | 1h |
| BUG-004 | unsigned int 无符号比较 | 0.5h |
| COMPAT-001 | PVRTC format 未初始化 | 1h |

**第一阶段总计**: 约 3.5 小时

#### 第二阶段：重要修复（建议 1-2 周内完成）

| 编号 | 修复内容 | 预估工时 |
|------|---------|---------|
| BUG-007 | 着色器源码临时对象生命周期 | 2h |
| BUG-008 | fullPathFromRelativeFile 悬空指针 | 2h |
| BUG-006 | 异步加载线程资源泄漏 | 3h |
| BUG-012 | NotificationCenter 迭代中删除 | 1h |
| BUG-010 | Scheduler malloc 未检查返回值 | 1h |
| BUG-011 | 粒子系统 malloc(0) | 0.5h |
| BUG-013 | SpriteFrameCache 重复帧名静默跳过 | 0.5h |
| SEC-001 | 文件路径注入 | 4h |
| SEC-002 | XML 实体攻击 | 4h |

**第二阶段总计**: 约 18 小时

#### 第三阶段：性能优化与安全加固（建议 1 个月内完成）

| 编号 | 修复内容 | 预估工时 |
|------|---------|---------|
| BUG-009 | TerminateProcess 强制终止 | 4h |
| BUG-005 | CCDictionary 键截断冲突 | 8h |
| SEC-004 | 图像解析缓冲区验证 | 8h |
| SEC-003 | 明文存储 | 4h |
| SEC-005 | 观察者 target 有效性 | 4h |
| PERF-001 | 同步纹理加载阻塞 | 4h |
| PERF-002 | BatchNode 容量扩容 | 1h |

**第三阶段总计**: 约 33 小时

#### 第四阶段：代码规范与技术债务清理（持续改进）

| 编号 | 修复内容 | 预估工时 |
|------|---------|---------|
| STYLE-001 | 不安全字符串函数 | 8h |
| STYLE-004 | Release 模式 CCAssert 移除 | 16h |
| COMPAT-005 | FileUtils 平台差异 | 8h |
| PERF-003 | GL 状态缓存粒度 | 4h |
| PERF-005 | RenderTexture 零初始化 | 2h |

**第四阶段总计**: 约 38 小时

---

## 八、总结与建议

### 8.1 核心发现

1. **致命 Bug 2 个**: `CCArray::initWithObjects` 逻辑反转和 `CCTexture2D::initWithDDSCompressData` 条件永远为 false，这两个问题直接影响核心数据结构和纹理渲染功能，修复成本极低但影响面极大。

2. **内存管理不一致**: `malloc/free` 与 `new/delete` 混用是 C++ 中最危险的未定义行为之一，在 CCTexture2D 中多处出现。这反映了项目在 C/C++ 内存管理规范上的缺失。

3. **生命周期管理缺陷**: Cocos2d-x 2.0 的 autorelease 机制与返回原始指针的 API 设计存在根本性矛盾，`CCFileUtils` 和 `CCGLProgram` 中均有悬空指针风险。这是架构层面的问题，难以通过局部修补完全解决。

4. **线程安全不足**: `CCTextureCache` 的异步加载线程缺少完整的资源清理流程，`CCNotificationCenter` 在迭代中删除元素。多线程代码需要更严格的审查。

5. **安全防护薄弱**: 文件路径注入、XML 实体攻击、图像解析缓冲区溢出等安全风险未得到有效控制。虽然游戏引擎的安全威胁模型与传统 Web 应用不同，但在处理用户输入（如自定义头像、Mod 资源）时仍需注意。

### 8.2 对 MT3 项目的特殊建议

> **终审裁决说明**：以下建议属于原始初评建议，其中“优先修复 BUG-001 和 BUG-003”的排序已被第九章修订。执行层面应先处理分配器不匹配、图片解析边界和异步纹理线程生命周期，再进入 DDS 半分辨率策略重设计。

1. **优先修复 BUG-001 和 BUG-003**: 这两个致命 Bug 修复成本极低（各改一个字符），但对 MT3 的 CCArray 使用和 DDS 纹理加载有直接影响。

2. **评估 BUG-002 的影响**: MT3 使用 MSVC v120 编译器，Debug 模式下 malloc/delete 混用可能触发堆检查断言。建议在下次构建时验证此问题是否已导致实际崩溃。

3. **关注 BUG-009**: MT3 Win32 客户端使用 CCEGLView，`TerminateProcess` 强制终止可能导致用户数据丢失。建议评估是否需要优雅退出流程。

4. **SEC-001 路径注入**: MT3 的 Lua 脚本可能通过 `CCFileUtils` 读取任意文件，如果脚本来源不可信，需要关注此风险。

### 8.3 长期演进建议

1. **考虑升级 Cocos2d-x 版本**: Cocos2d-x 2.0 已非常老旧，许多已知问题在 3.x 版本中已修复。但考虑到 MT3 的定制程度和 ABI 兼容性，升级成本极高。

2. **建立回归测试**: 对核心数据结构（CCArray、CCDictionary）和内存管理建立自动化测试，防止修复引入新问题。

3. **代码审查流程**: 对 cocos2dx/ 目录的修改建立更严格的审查流程，特别是涉及内存管理和线程安全的代码。

---

## 九、2026-04-29 复核结论与修复方案补充

> 本节为对前文潜在问题清单的源码复核结果。复核依据为当前仓库代码快照，重点核对 `cocos2dx/`、`extensions/`、`Box2D/chipmunk` 接入点、`platform/*` 平台实现与纹理/图片/事件关键路径。第七章原始优先级未区分“真实缺陷”“设计取舍”“误报/描述不准”，后续修复排期应以本节复核结论为准。

### 9.1 复核方法与边界

- 使用 `rg` 对报告中的每个编号回源到实际源码位置，优先核对内存分配/释放、GL 上传、线程退出、事件迭代、路径访问与图像解析。
- 只做静态审查与文档修订，未在本轮修改 C++ 源码，未执行 Win32/Android/iOS 构建。
- “属实”表示当前代码存在可证实风险；“部分属实”表示代码有风险但报告描述、影响范围或修复方式需要修正；“不按原描述属实”表示原报告给出的根因不成立，但同一位置存在其他真实风险。

### 9.2 原报告条目属实性复核表

| 编号 | 复核结论 | 源码证据与修正说明 |
| --- | --- | --- |
| BUG-001 | 部分属实 | `CCArray.cpp:242` 的 `CC_BREAK_IF(pObject != NULL)` 确实反了；但 `CCArray::create(obj1, ..., NULL)` 另有实现，未走该函数，原报告影响范围夸大。 |
| BUG-002 | 属实 | `CCTexture2D.cpp:328/342`、`862/879` 使用 `malloc` 后 `CC_SAFE_DELETE_ARRAY`，是未定义行为。 |
| BUG-003 | 部分属实 | `CCTexture2D.cpp:851` 的 `DXT3 && DXT5` 永远为 false；但原报告直接改为 `||` 不安全，因为该分支把压缩 DXT 数据当 RGBA 像素降采样并用 `glTexImage2D` 上传。 |
| BUG-004 | 部分属实 | `CCTouchDispatcher.cpp:319-333` 的 `uIndex >= 0` 对 unsigned 冗余；负值转换会被 `uIndex < 4` 捕获，真正风险是 Release 下 `CCAssert` 被移除。 |
| BUG-005 | 属实 | `CCDictionary.h:44-60` 固定 256 字节键会截断长键并造成冲突；`strcpy` 在当前截断逻辑下不直接溢出，但长键语义丢失属实。 |
| BUG-006 | 属实 | `CCTextureCache.cpp:284-301` 析构只置 `need_quit` 并 `sem_post`，未 join 线程，也未销毁 pthread mutex；WP8 分支还存在未绑定 mutex 的 `unique_lock` 用法。 |
| BUG-007 | 不按原描述属实 | `CCGLProgram.cpp:123-128` 传入的 shader 源在 `initWithVertexShaderByteArray` 内同步 `glShaderSource/glCompileShader`，autorelease 不会在调用中途释放；真实风险是 shader 文件读取失败时 `createWithContentsOfFile()` 返回 NULL 后直接 `getCString()` 崩溃。 |
| BUG-008 | 属实 | `win32/CCFileUtils.cpp:182-191` 返回 autorelease `CCString` 内部 `c_str()`；调用者跨帧保存会悬空。Android/iOS 同类 API 也有相同风格。 |
| BUG-009 | 属实但需保留业务背景 | `CCEGLView.cpp:325-335` 直接 `TerminateProcess`；这是 MT3 为规避 OLE/IE 宿主僵尸进程加的强退出路径，不能简单删除，应做可配置优雅退出。 |
| BUG-010 | 属实 | `CCScheduler.cpp:267/365/412/422/431` 的 `calloc/malloc` 多处未检查返回值后即解引用。 |
| BUG-011 | 属实 | `CCParticleSystem.cpp:343-349` 和 `CCParticleSystemQuad.cpp:515-518` 对 0 粒子数路径依赖 `calloc(0)/malloc(0)` 行为，跨平台结果不稳定。 |
| BUG-012 | 部分属实 | `removeObserver` 删除后立即 return，风险较小；`unregisterScriptObserver` 在 `CCARRAY_FOREACH` 中删除且不 break，确实可能跳项或迭代异常。 |
| BUG-013 | 属实 | `CCSpriteFrameCache.cpp:107-112` 重复帧名静默跳过，属于可诊断性缺陷。 |
| COMPAT-001 | 部分属实 | `CCTexture2D.cpp:759` 已初始化 `format = 0`，不是未初始化；但 `CC_SUPPORT_PVRTC` 在 WP8 也会定义，非 iOS 分支会以 0 作为压缩格式上传，仍是兼容性 bug。 |
| COMPAT-002 | 属实 | `CCTextureCache.cpp:83-100/376-381` 维护 pthread 与 WP8 两套线程路径；WP8 分支的通知和清理代码存在明显同步缺陷。 |
| COMPAT-003 | 属实但属配置约束 | `CCPhysicsSprite.h:28-33` 未启用 Chipmunk/Box2D 宏时直接 `#error`，应视为可选模块边界，不建议全局包含该头。 |
| COMPAT-004 | 属实 | Win32 桌面 OpenGL 与移动 OpenGL ES 的差异客观存在，但当前已有大量宏隔离，属于持续验证项。 |
| COMPAT-005 | 属实 | `platform/*/CCFileUtils` 路径拼接、分隔符、包内资源读取行为不一致，需要用平台用例验证。 |
| PERF-001 | 属实 | `CCTextureCache::addImage` 同步执行文件读取、图片解码与纹理上传，大图会卡主线程。 |
| PERF-002 | 属实 | `CCSpriteBatchNode.cpp:89-94` 默认容量走 `kDefaultSpriteBatchCapacity`，超量后 `increaseAtlasCapacity()` 扩容并复制。 |
| PERF-003 | 不属实 | `ccGLStateCache.cpp:46-50/126-145` 已维护 `s_uCurrentBoundTexture[kCCMaxActiveTexture]`，不是单纹理槽缓存。 |
| PERF-004 | 部分属实 | `CCParticleSystemQuad.cpp:312-315` 每帧上传活跃粒子数 `m_uParticleCount`，不是总容量 `m_uTotalParticles`；大量活跃粒子时仍可能成为瓶颈。 |
| PERF-005 | 属实 | `CCRenderTexture.cpp:190-200` 为初始化纹理分配并清零完整 CPU 缓冲，大尺寸 RenderTexture 有瞬时内存压力。 |
| PERF-006 | 部分属实 | `CCDirector.cpp:249-271` 的统计计算由 `m_bDisplayStats` 控制；游戏主循环每帧渲染是 2D 游戏常规设计，不能简单视为 bug。 |
| STYLE-001 | 部分属实 | 不安全 C 字符串函数存在；但部分例子如 `CCUserDefault.cpp:333` 的 50 字节 int 缓冲并非高危溢出，应按实际缓冲和 Release 防护逐处处理。 |
| STYLE-002 | 属实 | 注释块和历史实验代码较多，影响阅读，但不应在 bug 修复提交里顺手清理。 |
| STYLE-003 | 属实 | 命名混用是旧引擎事实，低风险，避免大规模重命名造成 ABI/脚本绑定扰动。 |
| STYLE-004 | 属实 | `ccMacros.h:38-41` Release 下 `CCAssert` 为空，多处只靠 assert 的参数校验会消失。 |
| STYLE-005 | 属实 | include 顺序不统一属低风险风格问题，不建议作为当前专项修复主线。 |
| SEC-001 | 部分属实 | `CCFileUtils::getFileData` 直接 `fopen` 是事实；但引擎 API 原本支持绝对路径，只有当路径来自脚本、下载包或用户输入时才构成安全边界问题。 |
| SEC-002 | 部分属实 | `CCSAXParser.cpp:120-128` 未显式禁用 DTD/实体扩展，建议加固；原报告中的 `xmlSetFeature` 不是当前 libxml2 SAX 调用的直接可用修复。 |
| SEC-003 | 属实 | `CCUserDefault` 明文 XML 存储偏好数据，不能放 token、账号凭据或隐私数据。 |
| SEC-004 | 属实 | `CCImage.h:183-184` 宽高为 `unsigned short`，图片解码中缺少统一尺寸上限和乘法溢出检查，恶意或异常图片可能触发越界、超大分配或截断。 |
| SEC-005 | 属实 | `CCNotificationObserver` 只保存裸 `m_target`，目标析构未自动解绑时 `performSelector` 可能访问已释放对象。 |

### 9.3 新增确认问题

| 编号 | 严重级别 | 问题 | 证据 | 修复方向 |
| --- | --- | --- | --- | --- |
| NEW-BUG-014 | P0 | `CCImage` 多个降采样分支把 `malloc` 缓冲赋给 `m_pData`，析构统一用 `delete[]` 释放。 | `CCImageCrossPlatform.cpp:165-178`、`CCImageCommon_cpp.h:409-423/696-711/732-747/1125-1139/1162-1177` | 将这些临时像素缓冲改为 `new unsigned char[BufferSize]`，或为 `m_pData` 引入明确的释放策略；推荐统一 `new[]/delete[]`。 |
| NEW-BUG-015 | P1 | `CCTextureCache::addImage` 图片解码失败会泄漏 `pBuffer`，并且忽略 `texture->initWithImage()` 返回值。 | `CCTextureCache.cpp:545-550` | 先释放 `pBuffer` 再 break；检查 `initWithImage` 返回值，失败时释放 texture 且不写入缓存。 |
| NEW-BUG-016 | P1 | `CCGLProgram::initWithVertexShaderFilename` 在 shader 文件缺失时会空指针解引用。 | `CCGLProgram.cpp:125-128`，`CCString.cpp:225-233` | 保存 `CCString*`，判空后记录文件名并返回 false，避免直接链式 `getCString()`。 |
| NEW-BUG-017 | P1 | `CCPhysicsSprite` 在 body 未设置或 Box2D PTM ratio 为 0 时直接解引用/除零。 | `CCPhysicsSprite.cpp:204-229/277-288/312-326` | `updatePosFromPhysics`、`setPosition`、`nodeToParentTransform` 前检查 body；Box2D 路径要求 `m_fPTMRatio > 0`，否则回退 CCSprite 行为并告警。 |

### 9.4 确认属实问题的修复方案深化

#### 9.4.1 分配器必须成对

适用：BUG-002、NEW-BUG-014。

`CCTexture2D` 中 `pPixBuffer` 是局部临时缓冲，最小修复是把释放宏改为 `CC_SAFE_FREE` 并补充分配失败检查：

```cpp
GLvoid* pPixBuffer = malloc(BufferSize);
CC_BREAK_IF(!pPixBuffer);
memset(pPixBuffer, 0, BufferSize);
...
CC_SAFE_FREE(pPixBuffer);
```

`CCImage` 中 `pPixBuffer` 会转交给 `m_pData`，而 `CCImage::~CCImage()` 固定 `CC_SAFE_DELETE_ARRAY(m_pData)`。为了不引入所有权标记，建议将相关 `malloc(BufferSize)` 全部改为 `new unsigned char[BufferSize]`，并用 `CC_SAFE_DELETE_ARRAY` 处理旧 `m_pData`：

```cpp
unsigned char* pPixBuffer = new unsigned char[BufferSize];
CC_BREAK_IF(!pPixBuffer);
memset(pPixBuffer, 0, BufferSize);
...
CC_SAFE_DELETE_ARRAY(m_pData);
m_pData = pPixBuffer;
pPixBuffer = NULL;
```

#### 9.4.2 DDS 半分辨率分支不能只把 `&&` 改成 `||`

适用：BUG-003。

当前 `initWithDDSCompressData()` 已先调用 `glCompressedTexImage2D()` 上传压缩纹理，随后死代码分支试图把 DXT3/DXT5 原始压缩块当成 `CharRGBA` 像素采样，并用 `glTexImage2D()` 重新上传。这不是合法的 DXT 降采样。建议二选一：

- 如果 MT3 只是需要正常 DXT 纹理：删除该死代码分支，仅保留压缩纹理上传和尺寸记录。
- 如果低配设备确实需要半分辨率：在资源构建阶段生成半分辨率 DXT 资产；或在运行时先用 DDS 解码器解到 RGBA，再降采样并按非压缩 RGBA 上传，但这会增加 CPU/内存成本。

#### 9.4.3 异步纹理线程退出要有完整生命周期

适用：BUG-006、COMPAT-002。

建议将 `need_quit` 改为受同一 mutex 保护的退出标志，析构流程按“停止接单 -> 唤醒线程 -> join -> 清队列 -> 销毁同步对象”的顺序执行：

1. 在主线程设置退出标志并 `sem_post/condition_variable::notify_one`。
2. `pthread_join(s_loadingThread, NULL)` 或 WP8 `s_loadingThread->join()`，等待 `loadImage` 完全退出。
3. 清理 `s_pAsyncStructQueue` 中尚未处理的 `AsyncStruct`，释放被 retain 的 target。
4. 清理 `s_pImageQueue` 中尚未回调的 `ImageInfo` 与 `CCImage`。
5. 销毁 `s_asyncStructQueueMutex`、`s_ImageInfoMutex` 和信号量；WP8 分支移除默认构造 `unique_lock` 和无锁 `unlock()`。

#### 9.4.4 返回 `c_str()` 的 FileUtils API 要限制生命周期

适用：BUG-008、COMPAT-005。

直接把接口改成 `std::string` 会影响旧代码和 ABI；更稳妥的迁移方案是新增值返回接口，并逐步替换内部调用：

```cpp
std::string CCFileUtils::fullPathForFilename(const char* pszFilename);
```

旧 `const char*` 接口可先改为返回 `CCFileUtils` 成员缓存或线程局部缓存，并在注释中明确“下次调用会失效，不可长期保存”。涉及头文件布局时必须按仓库 ABI 规则重编 `libcocos2d -> engine -> FireClient -> MT3`。

#### 9.4.5 Release 版本必须保留关键防御

适用：BUG-004、BUG-010、BUG-011、STYLE-004。

- `CCTouchDispatcher::touches` 应使用运行时 guard，而不是仅靠 `CCAssert`：

```cpp
if (uIndex >= CCLONGPRESS)
{
    CCLOGWARN("CCTouchDispatcher: invalid touch index %u", uIndex);
    return;
}
```

- `CCScheduler` 的 `malloc/calloc` 后必须立即判空；失败时记录日志并返回，不写入 hash/list。
- 粒子系统应拒绝 0 容量或显式支持空系统：`numberOfParticles == 0` 时返回 false 并输出配置错误，避免依赖 `malloc(0)`。

#### 9.4.6 图片解析需要统一上限与溢出检查

适用：SEC-004、NEW-BUG-014。

建议新增一个内部工具函数统一校验宽高、通道数和总字节数：

```cpp
static bool checkedImageBytes(unsigned int width, unsigned int height, unsigned int channels, size_t* outBytes)
{
    const unsigned int kMaxTextureSize = 8192;
    if (width == 0 || height == 0 || width > kMaxTextureSize || height > kMaxTextureSize) return false;
    if (channels == 0 || channels > 4) return false;
    if (width > SIZE_MAX / height) return false;
    size_t pixels = (size_t)width * height;
    if (pixels > SIZE_MAX / channels) return false;
    *outBytes = pixels * channels;
    return true;
}
```

然后在 PNG/JPG/TIFF/WebP/TGA/DDS/RawData 各入口使用该函数，避免 `unsigned short` 宽高截断和乘法溢出。若必须保留 `unsigned short` 成员，则超过 65535 的输入必须直接拒绝。

#### 9.4.7 安全加固应放在可信边界上

适用：SEC-001、SEC-002、SEC-003、SEC-005。

- 路径访问：不要全局禁止绝对路径，否则会破坏调试和工具链；应在脚本、热更新、下载包资源入口使用 `fullPathFromRelativePath` 后做规范化，确认最终路径仍在允许的资源根目录下。
- XML：对来自下载包或用户输入的 XML，先拒绝 `<!DOCTYPE`，再使用 libxml2 parser context 加 `XML_PARSE_NONET`，并禁用/忽略外部实体解析；现有 `xmlSAXUserParseMemory` 需要改成显式 context 才能可靠配置。
- `CCUserDefault`：仅用于偏好设置，禁止存 token、账号凭据和隐私数据；如确需保存敏感值，应接平台 Keychain/Keystore/Windows DPAPI。
- Notification：短期要求观察者析构主动 `removeObserver/removeAllObservers`；长期可在 `CCObject` 生命周期或脚本绑定层增加自动解绑机制。

### 9.5 修订后的优先级建议

| 优先级 | 项目 | 理由 |
| --- | --- | --- |
| P0-1 | BUG-002 + NEW-BUG-014 | 分配器不匹配是确定的未定义行为，可能触发堆损坏。 |
| P0-2 | BUG-006 | 异步纹理线程退出缺 join 和队列清理，存在退出期崩溃/泄漏风险。 |
| P0-3 | SEC-004 | 图像解析是外部资源入口，尺寸/溢出/释放策略必须先收敛。 |
| P1-1 | BUG-001 | 真实代码错误但影响限于直接调用 `initWithObjects`。 |
| P1-2 | NEW-BUG-015 | 解码失败路径泄漏并可能缓存未初始化纹理，影响资源稳定性。 |
| P1-3 | NEW-BUG-016 | shader 文件缺失会直接崩溃，修复成本低。 |
| P1-4 | BUG-003 | 原条件确实死代码，但修法必须重新设计 DDS 半分辨率策略。 |
| P1-5 | BUG-008 | 字符串生命周期风险需要新增安全 API 后逐步迁移。 |
| P1-6 | NEW-BUG-017 | 物理扩展误用会崩溃，适合在扩展模块内加防御。 |
| P2 | BUG-004、BUG-010、BUG-011、BUG-012、SEC-001、SEC-002、SEC-005 | 都需要修，但应按调用面和资源来源排期。 |
| 观察项 | PERF-003、PERF-006、STYLE-003、STYLE-005 | 原报告中存在误报或低价值技术债，不建议进入首轮修复。 |

### 9.6 建议验证清单

- 为 `CCArray::initWithObjects` 增加最小单元用例：直接调用 `initWithObjects(obj1, obj2, NULL)` 应返回 true 且 count 为 2；同时验证 `CCArray::create(obj1, obj2, NULL)` 原路径不回归。
- 用 Debug CRT/AddressSanitizer 等价工具跑 PNG/JPG/WebP/DDS 降采样路径，确认所有 `m_pData` 都由 `new[]` 分配并由 `delete[]` 释放。
- 构造损坏图片、超大宽高图片、shader 文件缺失、0 粒子数、未设置 body 的 `CCPhysicsSprite`，验证失败路径不崩溃且有日志。
- 异步纹理加载需覆盖：正常完成、加载失败、仍有排队任务时析构 `CCTextureCache`、多次创建/销毁缓存。
- Win32 主线涉及 `cocos2dx/**` 源码修复后，按 MT3 规则重编 `libcocos2d -> engine -> FireClient -> MT3`，不要只替换单个对象文件。

---

## 十、项目负责人终审与修复启动计划

> **终审日期**：2026-04-29  
> **终审身份**：项目总负责人 / Cocos2d-x 风险修复负责人  
> **终审结论**：有条件通过，允许作为后续修复工作的执行基线。条件是：第九章与第十章优先级覆盖第七、八章原始初评排序；所有源码修复必须先建立最小复现或验证用例，再按 MT3 固定工具链完成整链验证。

### 10.1 终审范围与方法

本次终审覆盖报告的完整性、准确性、技术深度和结论合理性，重点回源抽检以下高风险链路：

- 数据结构与内存：`CCArray`、`CCDictionary`、`CCTexture2D`、`CCImage`、`CCScheduler`。
- 渲染与资源：DDS/PVRTC/ATC 纹理上传、`CCTextureCache` 同步与异步加载、`CCGLProgram` shader 加载、GL 状态缓存。
- 平台兼容：Win32 `CCFileUtils` / `CCEGLView`、WP8 线程分支、移动端纹理格式差异。
- 扩展模块：`CCPhysicsSprite` 的 Chipmunk / Box2D 接入边界。
- 安全边界：图片解析、XML 解析、资源路径、明文偏好存储和通知观察者生命周期。

本次终审阶段属于静态审查加源码抽样验证，未执行 Win32、Android、iOS 构建，也未运行图形设备实测。因此报告可以作为修复启动基线，但不能替代后续构建、运行和回归测试。2026-04-30 起的实际源码修复和验证状态见 10.10。

### 10.2 四项质量维度审核结论

| 维度 | 结论 | 终审意见 |
| --- | --- | --- |
| 完整性 | 通过 | 报告覆盖架构、潜在 bug、兼容性、性能、规范、安全和优先级；第九章补齐了原始初评中缺少的属实性复核与修复方向。 |
| 准确性 | 有条件通过 | 大多数高风险结论有源码证据支撑；但第七、八章仍保留原始初评口径，执行时必须以后续复核章节为准。 |
| 技术深度 | 通过 | 对分配器不匹配、压缩纹理降采样、异步线程退出、图片解析边界等问题已给出根因级说明，而不是只给表面修补。 |
| 结论合理性 | 有条件通过 | P0/P1 重新排序符合崩溃概率、外部输入面和修复风险；低价值风格项被降级为观察项，避免挤占核心修复窗口。 |

### 10.3 关键抽检记录

| 抽检项 | 结果 | 项目负责人裁决 |
| --- | --- | --- |
| 文档编码 | UTF-8 严格解码通过，无 BOM，LF 换行 | 允许继续用 `apply_patch` 小范围修改，禁止整文件无编码重写。 |
| BUG-001 | `CCArray::initWithObjects` 中 `CC_BREAK_IF(pObject != NULL)` 条件反向属实 | 修复优先级为 P1，不按“全局致命”处理。 |
| BUG-002 / NEW-BUG-014 | `malloc` 缓冲被 `CC_SAFE_DELETE_ARRAY` 或 `CCImage::~CCImage` 的 `delete[]` 释放属实 | P0，第一批修复。 |
| BUG-003 | `DXT3 && DXT5` 死条件属实，但原一字符修复方案错误 | P1，必须重设计 DDS 半分辨率策略。 |
| BUG-006 / COMPAT-002 | `CCTextureCache` 析构未 join 异步线程，WP8 分支同步对象使用异常属实 | P0，第二批修复。 |
| BUG-007 / NEW-BUG-016 | autorelease 悬空不成立；shader 文件缺失空指针崩溃属实 | 按 NEW-BUG-016 修复，不按原 BUG-007 修。 |
| PERF-003 | GL 状态缓存已按纹理单元维护数组 | 判定为误报，仅保留观察。 |
| NEW-BUG-017 | `CCPhysicsSprite` 未设置 body 或 PTM ratio 为 0 的崩溃/除零风险属实 | P1，扩展模块加防御。 |

### 10.4 修复项目启动决议

项目代号：`COCOS2DX-2026-04-RISK-REPAIR`。

启动目标：

- 消除已确认 P0 崩溃和堆损坏风险。
- 将 P1 稳定性问题收敛到明确失败路径，不允许资源缺失、异常图片或错误配置直接导致进程崩溃。
- 对低价值风格问题只做记录，不在本批次做大规模格式化、重命名或依赖升级。

启动范围：

- 纳入本批次：`BUG-001`、`BUG-002`、`BUG-003`、`BUG-004`、`BUG-005`、`BUG-006`、`BUG-008`、`BUG-009`、`BUG-010`、`BUG-011`、`BUG-012`、`SEC-001`、`SEC-002`、`SEC-004`、`SEC-005`、`NEW-BUG-014`、`NEW-BUG-015`、`NEW-BUG-016`、`NEW-BUG-017`。
- 延后单独立项：`COMPAT-004/005` 全平台资源路径一致性、`PERF-001/002/004/005` 性能优化。
- 不纳入首轮源码修复：`PERF-003`、`PERF-006`、`STYLE-003`、`STYLE-005`。

### 10.5 责任分工

| 角色 | 责任范围 | 交付物 |
| --- | --- | --- |
| 项目总负责人 | 决策优先级、冻结范围、处理跨模块风险 | 修复基线确认、风险豁免记录、阶段验收签字。 |
| Cocos 引擎负责人 | `cocos2dx/**` 核心数据结构、纹理、调度器、通知中心修复 | 源码补丁、单元/最小复现用例、影响面说明。 |
| 渲染与资源负责人 | DDS/PVRTC/ATC、`CCTextureCache`、`CCImage`、shader 加载链路 | 资源异常用例、纹理加载回归结果、渲染截图或日志证据。 |
| 平台负责人 | Win32/WP8/iOS/Android 差异、线程退出、路径规范化 | 平台差异说明、Win32 主线验证、移动端风险清单。 |
| 安全负责人 | 图片/XML/路径/偏好存储/通知生命周期边界 | 安全加固审查表、异常输入测试样例。 |
| 构建负责人 | VS2013 v120、Windows SDK 8.1、Android r10e/Ant 相关验证入口 | 构建命令、产物路径、首个错误记录和修复后产物校验。 |
| QA 负责人 | 回归用例、崩溃复现、资源异常包和退出期测试 | 测试报告、崩溃日志、通过/失败矩阵。 |

### 10.6 时间节点

| 阶段 | 日期 | 目标 | 必须完成的质量门禁 |
| --- | --- | --- | --- |
| 启动准备 | 2026-04-29 | 冻结第九、十章为修复基线，建立修复分支和问题单 | 每个问题单必须包含源码证据、复现/验证方式、回滚方式。 |
| P0-1 内存分配器修复 | 2026-04-30 至 2026-05-01 | 修复 `BUG-002`、`NEW-BUG-014`、`SEC-004` 第一层尺寸/溢出防御 | Debug CRT 或等价堆检查通过；异常图片不崩溃；无编码漂移。 |
| P0-2 异步纹理生命周期 | 2026-05-02 至 2026-05-04 | 修复 `BUG-006`、`COMPAT-002` | 正常加载、加载失败、退出期仍有队列任务三类场景均不泄漏、不崩溃。 |
| P1 稳定性修复 | 2026-05-05 至 2026-05-08 | 修复 `BUG-001`、`NEW-BUG-015`、`NEW-BUG-016`、`NEW-BUG-017` | 每个问题至少有一个失败路径用例或手工复现步骤；修复后日志可诊断。 |
| P1/P2 防御加固 | 2026-05-09 至 2026-05-12 | 处理 `BUG-003` 策略、`BUG-004`、`BUG-010`、`BUG-011`、`BUG-012`、`SEC-001/002/005` | Release 下关键 guard 仍生效；DDS 策略经资源负责人确认。 |
| 整链回归 | 2026-05-13 至 2026-05-15 | Win32 主线整链重编和核心场景冒烟 | 按 MT3 规则重编 `libcocos2d -> engine -> FireClient -> MT3`；记录命令、产物和结果。 |

### 10.7 问题到修复批次映射

| 批次 | 问题编号 | 责任角色 | 验收标准 |
| --- | --- | --- | --- |
| P0-A | `BUG-002`、`NEW-BUG-014` | Cocos 引擎负责人、渲染与资源负责人 | 所有转交给 `m_pData` 的缓冲与析构释放方式匹配；`CCTexture2D` 临时缓冲使用 `free` 或改为 `new[]` 后成对释放。 |
| P0-B | `SEC-004` | 安全负责人、渲染与资源负责人 | 图片宽高、通道数、总字节数统一校验；超大、损坏、截断图片返回失败并记录日志。 |
| P0-C | `BUG-006`、`COMPAT-002` | 平台负责人、渲染与资源负责人 | 析构流程完成停止接单、唤醒、join、队列清理和同步对象销毁；WP8 分支无未绑定锁操作。 |
| P1-A | `BUG-001` | Cocos 引擎负责人 | `initWithObjects(obj1, obj2, NULL)` 成功，`initWithObjects(NULL)` 失败或返回空数组的语义明确。 |
| P1-B | `NEW-BUG-015`、`NEW-BUG-016` | 渲染与资源负责人 | 图片解码失败释放 `pBuffer`；`initWithImage` 失败不入缓存；shader 文件缺失不崩溃。 |
| P1-C | `BUG-003` | 渲染与资源负责人、项目总负责人 | 明确选择“删除死代码”或“资源阶段生成半分辨率 DXT”；禁止直接改成 `||` 后上传伪 RGBA。 |
| P1-D | `BUG-008` | 平台负责人、Cocos 引擎负责人 | 新增安全值返回接口或受控缓存策略；旧接口生命周期在注释和调用点中明确。 |
| P1-E | `NEW-BUG-017` | Cocos 引擎负责人 | Chipmunk/Box2D body 为空时回退或失败可诊断；Box2D PTM ratio 为 0 时不除零。 |
| P1-F | `BUG-005` | Cocos 引擎负责人 | 字符串键完整保存，不再按 256 字节截断；长键查找、删除、复制均使用完整 key。 |
| P1-G | `BUG-009` | 平台负责人、QA 负责人 | Win32 默认保留强退兼容路径，同时提供可配置优雅退出开关；退出期需覆盖默认强退和优雅关闭两种场景。 |
| P2-A | `BUG-004`、`BUG-010`、`BUG-011`、`BUG-012` | Cocos 引擎负责人 | Release 下参数防御仍保留；分配失败、0 粒子、迭代删除均有明确处理。 |
| P2-B | `SEC-001`、`SEC-002`、`SEC-005` | 安全负责人、平台负责人 | 对来自脚本/下载包的路径与 XML 做可信边界校验；观察者生命周期有约束或自动解绑策略。 |

### 10.8 统一质量验收标准

所有修复批次必须满足以下标准后才允许合入：

- 代码改动必须回源修复，不允许只修改生成物、二进制产物或运行目录副本。
- 每个 bug 至少提供一个最小复现用例、自动化测试、手工复现步骤或异常资源样例；无法自动化的项目必须写清楚原因。
- 涉及 `cocos2dx/**` 公共头文件或 ABI 敏感行为时，必须评估并执行 `libcocos2d -> engine -> FireClient -> MT3` 的重编顺序。
- Windows 修改必须保持原文件编码、BOM 和换行；中文文档保持 UTF-8 无 BOM + LF。
- 修复不得引入大规模格式化、命名重构、依赖升级或跨域行为变化。
- P0/P1 修复必须包含失败路径日志，日志不得输出 token、账号凭据、隐私数据或外部资源完整敏感路径。
- 验收报告必须记录：变更文件、验证命令、退出码、产物路径、失败项、回滚方式。

### 10.9 首批立即执行清单

1. 以本报告第九、十章为基线建立修复分支，分支建议名：`fix/cocos2dx-risk-repair-20260429`。
2. 先开三个 P0 问题单：`P0-A 分配器不匹配`、`P0-B 图片解析边界`、`P0-C 异步纹理线程生命周期`。
3. 首个源码修复从 `BUG-002 + NEW-BUG-014` 开始，因为它们是确定的未定义行为，且修复边界清晰。
4. 在 P0-A 合入前不得启动 `BUG-003` DDS 半分辨率代码改动，避免把压缩纹理策略问题和内存释放问题混在同一提交。
5. 每个批次完成后更新本报告或独立修复记录，记录实际修复文件、验证证据和剩余风险。

### 10.10 修复执行状态（2026-04-30）

本节记录本轮继续执行后的实际源码状态。前文第九、十章中“未修改源码/未执行构建”的表述仅代表 2026-04-29 终审基线。

| 问题编号 | 当前状态 | 实际修复摘要 | 涉及文件 |
| --- | --- | --- | --- |
| `BUG-005` | 已修复；Win32 Debug/Release 构建通过 | `CCDictElement` 字符串键由固定 256 字节数组改为 `std::string`；查找、删除、插入使用 `HASH_FIND/HASH_ADD_KEYPTR` 和完整 key 长度，避免长键被截断后冲突。 | `cocos2dx/cocoa/CCDictionary.h`、`cocos2dx/cocoa/CCDictionary.cpp` |
| `BUG-008` | 已修复；Win32 Debug/Release 与 Android APK 构建通过，iOS 待平台构建 | Win32/Android/iOS/通用实现的 `fullPathFromRelativePath/fullPathFromRelativeFile` 不再返回 autorelease `CCString` 或临时 `NSString` 的内部指针，改为进程内稳定字符串缓存。 | `platform/win32/CCFileUtils.cpp`、`platform/android/CCFileUtils.cpp`、`platform/ios/CCFileUtils.mm`、`platform/CCFileUtils.cpp`、`platform/CCFileUtilsCommon_cpp.h` |
| `BUG-009` | 已修复；Win32 Debug/Release 构建通过 | Win32 默认仍保留 `TerminateProcess` 兼容旧 OLE/IE 宿主退出问题；新增编译宏/环境变量 `COCOS2DX_FORCE_TERMINATE_ON_CLOSE=0` 可切换到 `CCDirector::end()` 优雅退出路径。 | `platform/win32/CCEGLView.cpp` |
| `SEC-001` | 已加固；Win32 Debug/Release 与 Android APK 构建通过，iOS 待平台构建 | `getFileData` 拒绝控制字符和相对路径中的 `..` 段；zip 内部条目拒绝绝对路径、控制字符和 `..` 段。绝对路径读取能力保留，作为引擎显式可信调用面。 | `platform/CCFileUtilsCommon_cpp.h`、`platform/win32/CCFileUtils.cpp`、`platform/android/CCFileUtils.cpp`、`platform/ios/CCFileUtils.mm`、`platform/CCFileUtils.cpp` |
| `SEC-002` | 已加固；Win32 Debug/Release 构建通过 | libxml2 SAX 解析改为 parser context，启用 `XML_PARSE_NONET`，关闭实体替换/DTD 加载/校验，并在内存解析前拒绝 `<!ENTITY` 声明；保留 plist 常见 DOCTYPE 兼容。 | `platform/CCSAXParser.cpp` |
| `SEC-005` | 已修复；Win32 Debug/Release 构建通过 | `CCNotificationObserver` 注册时 retain `target/object`，析构时 release，避免观察者仍在中心内时 target 被释放后回调悬空指针。 | `support/CCNotificationCenter.cpp` |

本轮修复后的验证结果：

- 静态红线复查通过：`MAX_KEY_LEN/m_szKey/HASH_ADD_STR` 旧模式已消失；FileUtils 不再返回临时 `CCString`/`NSString` 指针；XML 解析已包含 `XML_PARSE_NONET`；Win32 强退路径可通过 `COCOS2DX_FORCE_TERMINATE_ON_CLOSE` 配置。
- `verify-build-env.ps1`：通过，主线工程仍为 v120，MSBuild 12.0 与 VS2013 `vcvarsall.bat` 可见。
- Debug FastLocal 构建：通过，产物 `client/resource/bin/Debug/MT3.exe`，大小 23218688 bytes，时间 2026-04-30 00:32:59。
- Release Incremental 构建：通过，产物 `client/resource/bin/Release/MT3.exe`，大小 8997376 bytes，时间 2026-04-30 00:39:42；runtime audit 已生成 `build_logs/runtime-audit-after-client-build.json`。
- Android APK 构建：通过，使用 `Build-Android-Locojoy-WithGate.ps1 -ProjectDir client/android/LocojoyProject -Channel free -Jobs 4 -CleanIntermediates`；产物 `client/android/LocojoyProject/build/bin/mt3-release.apk`，大小 1843185542 bytes，时间 2026-04-30 01:08:39，MD5 `1D918896260B3D1091ACBBFF36AD2DF6`，SHA256 `635BA86F5D54F841E3B6BC95D1A0E9545217CC4319E672CD3E79A93FB28435BF`。
- APK 结构门禁：通过，Entry Count 63248，Max Allowed 65534，ZIP64 False；`aapt dump badging` 可正常读取，包名 `com.locojoy.mini.mt3.locojoy`，native-code `armeabi-v7a`。
- 未执行项：iOS Xcode 构建、Android 真机安装和真实图形设备运行测试；本机 `adb devices` 未发现已连接设备。

---

> **文档结束**
> 本报告基于 2026-04-29 的代码快照生成，部分问题可能在后续提交中已被修复。建议定期重新评估。

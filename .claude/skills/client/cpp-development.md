---
name: cpp-development
version: 1.5.0
priority: high
category: client
description: |
  MT3客户端C++开发技能。涵盖四层架构理解、Nuclear引擎使用、v120工具集编译规范。
  触发词: C++, 客户端, 引擎, 编译, Nuclear, Cocos2d-x, 四层架构, v120, 预编译头, FireClient, 内存管理, 引用计数, CC_SAFE_RELEASE, autorelease, create()
dependencies:
  - project-context
  - git-workflow
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 12000
---

# C++ 开发技能 (MT3 客户端)

**版本**: v1.5.0
**最后更新**: 2026-04-11

---

## 🏗️ 四层架构理解

> **数据来源**: 代码分析报告 [`02-客户端C++代码分析.md`](../../../docs/09-历史归档/文档审计/2026-02-28-客户端C++代码分析.md)

### 代码规模统计

| 模块 | 代码量 | 说明 |
|------|--------|------|
| **C++ 客户端** | ~66,000 行 | 客户端引擎和业务代码 |
| **Nuclear 引擎** | ~17,000 行 | 自研 2D 游戏引擎 |
| **FireClient 业务层** | - | 游戏业务逻辑（预编译库） |

### 架构图

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: FireClient 业务层 (C++)                           │
│  - GameApplication (继承 IApp)                              │
│  - Lua 脚本系统 (LuaEngine, LuaFireClient)                  │
│  - UI管理 (GameUIManager)                                   │
│  - 战斗系统 (BattleManager, Battler, Skill)                 │
│  - 网络通信 (NetConnection, MessageManager)                 │
│  - 配置数据 (ConfigManager, GameTable)                      │
└─────────────────────────────────────────────────────────────┘
                         ↓ IApp 接口
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: Nuclear 引擎层 (~17k 行)                          │
│  - IEngine/IWorld/IEnv/IQuery 核心接口                      │
│  - 场景/精灵/动画/特效管理                                   │
│  - A* 寻路系统 (astar/)                                     │
│  - 粒子系统 (particlesystem/)                               │
└─────────────────────────────────────────────────────────────┘
                         ↓ CCLayer 桥接
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Cocos2d-x 2.2.6 层                                │
│  - libcocos2d + libCocosDenshion + libExtensions           │
│  - OpenGL 2.0 (Win32) / OpenGL ES (Android/iOS)              │
└─────────────────────────────────────────────────────────────┘
                         ↓ Platform API
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: 平台层 (Win32/Android/iOS)                        │
│  - OpenGL, DirectShow, FMOD                                 │
└─────────────────────────────────────────────────────────────┘
```

### 各层职责

| 层级 | 职责 | 代码位置 |
|-----|------|---------|
| FireClient 业务层 | 网络通信、数据管理、Lua 脚本系统 | client/FireClient/ |
| Nuclear 引擎 | 场景管理、精灵系统、A* 寻路 | engine/ |
| Cocos2d-x | 图形渲染、动画系统 | cocos2d-x-2.2.6/ |
| 平台层 | 系统接口、平台抽象 | common/platform/ |

---

## 📝 代码规范详解

### 命名规范

```cpp
// ❌ 错误示例
class sprite {
    int count;
    Sprite* sprite;
};

// ✅ 正确示例
class Sprite {
private:
    int m_count;              // 成员变量: m_ 前缀
    Sprite* m_pParent;        // 指针: p 前缀
    std::wstring m_modelName; // 使用 wstring

public:
    // 函数: PascalCase
    void SetLocation(const NuclearLocation& loc);
    NuclearLocation GetLocation() const;
};

// 接口类: I 前缀
class IEngine {
public:
    virtual ~IEngine() {}
    virtual void Draw() = 0;
};

// 常量/枚举: 全大写
const int MAX_SPRITE_COUNT = 1000;

enum SPRITE_ACTION_TYPE {
    SAT_LOAD = 0,
    SAT_UNLOAD = 1
};
```

### 文件组织

```cpp
// ❌ 错误: 缺少预编译头
#include "Sprite.h"
#include <string>

// ✅ 正确: 第一行必须是预编译头
#include "nupch.h"
#include "Sprite.h"
```

### 头文件保护

```cpp
// ✅ 传统风格 (项目标准)
#ifndef __Nuclear_SPRITE_H__
#define __Nuclear_SPRITE_H__

// 代码...

#endif // __Nuclear_SPRITE_H__
```

### 源文件编码 (强制)

| 文件类型 | 编码格式 | 说明 |
|----------|----------|------|
| `.cpp`, `.c`, `.h`, `.hpp` | **UTF-8 with BOM** | VS2013 需要 BOM 识别 UTF-8 |
| `.rc` (资源文件) | **UTF-8 with BOM** | MFC 资源文件 |

**原因**:
- VS2013 默认按系统代码页 (GBK) 解析源文件
- 无 BOM 的 UTF-8 会被误认为 GBK，导致 `L"中文"` 编译错误
- UTF-8 BOM (`EF BB BF`) 让 VS2013 正确识别编码

**验证与修复**:
```powershell
# 检查文件是否有 UTF-8 BOM
Format-Hex -Path "file.cpp" | Select-Object -First 1
# 应显示: EF BB BF ...

# 添加 UTF-8 BOM
$file = "path/to/file.cpp"
$enc = New-Object System.Text.UTF8Encoding($true)
$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($file, $text, $enc)
```

**禁止事项**:
- ❌ 使用 GBK 编码（跨系统不兼容）
- ❌ 使用 UTF-8 无 BOM（VS2013 无法识别）

---

## 🔑 核心概念

### Nuclear 引擎核心接口

> **数据来源**: 代码分析报告 [`02-客户端C++代码分析.md`](../../../docs/09-历史归档/文档审计/2026-02-28-客户端C++代码分析.md)

#### IEngine 接口（图形引擎）

**文件位置**: [`engine/nuiengine.h`](../../../engine/nuiengine.h)

```cpp
class IEngine {
public:
    // 屏幕信息
    virtual int GetScreenWidth() = 0;
    virtual int GetScreenHeight() = 0;
    virtual int GetLogicWidth() = 0;
    virtual int GetLogicHeight() = 0;
    
    // 引擎生命周期
    virtual bool Run(const EngineParameter &ep) = 0;
    virtual bool Exit() = 0;
    
    // 核心接口获取
    virtual IWorld* GetWorld() = 0;
    virtual IEnv* GetEnv() = 0;
    virtual IApp* GetApp() = 0;
    virtual Renderer* GetRenderer() = 0;
    
    // Cocos2d-x 层集成
    virtual void SetEngineLayer(cocos2d::CCLayer* aPLayer) = 0;
    virtual cocos2d::CCLayer* GetEngineLayer() = 0;
    
    // 精灵管理（非世界精灵）
    virtual EngineSpriteHandle CreateEngineSprite(const std::wstring &modelname, bool async) = 0;
    virtual void ReleaseEngineSprite(EngineSpriteHandle handle) = 0;
    
    // 特效管理
    virtual IEffect* CreateEffect(const std::wstring &effectname, bool async = true) = 0;
    virtual void DrawEffect(IEffect* pEffect) = 0;
    virtual void ReleaseEffect(IEffect* pEffect) = 0;
};
```

**关键发现**:
- IEngine 通过 `SetEngineLayer()` 与 Cocos2d-x 集成
- 提供完整的精灵和特效生命周期管理
- **注意**: `GetEngine()` 是命名空间函数，不是 IEngine 的成员

#### IWorld 接口（游戏世界）

**文件位置**: [`engine/nuiworld.h`](../../../engine/nuiworld.h)

```cpp
class IWorld {
public:
    // 地图管理
    virtual bool LoadMap(const std::wstring& mapname, const std::wstring &mazename, const XPLoadmapParam* param, bool async) = 0;
    virtual bool UnloadMap() = 0;
    
    // 精灵管理 - 注意方法命名
    virtual ISprite* NewSprite(NuclearSpriteLayer layer, const std::wstring &modelname) = 0;
    virtual void DeleteSprite(ISprite* sprite) = 0;
    virtual void DeleteAllSprite(NuclearSpriteLayer layer, bool keepAttached = false) = 0;
    
    // 障碍和寻路
    virtual bool SetMapMaze(const void* mazeBuffer, size_t size) = 0;
    virtual bool GetAStartPath(astar::Path& path, const Nuclear::NuclearLocation& start, const Nuclear::NuclearLocation& end) = 0;
    
    // 特效管理
    virtual IEffect* SetEffect(const std::wstring &name, Nuclear_EffectLayer layer, int x, int y, bool async) = 0;
    virtual IEffect* PlayEffect(const std::wstring &name, Nuclear_EffectLayer layer, int x, int y, int times, bool async, unsigned char soundtype) = 0;
    virtual void RemoveEffect(IEffect* pEffect) = 0;
    
    // 相机控制
    virtual void AttachCameraTo(ISprite* sprite) = 0;
};
```

**常见偏差**: ❌ `CreateSprite/AddSprite/RemoveSprite` → ✅ `NewSprite/DeleteSprite`

#### IQuery 接口（信息查询）

**文件位置**: [`engine/nuiquery.h`](../../../engine/nuiquery.h)

```cpp
class IQuery {
public:
    struct ActionInfo {
        int nTime;   // 播放时间（毫秒）
        int nFrame;  // 帧数
        int nStride; // 步幅（像素）
    };
    
    struct SpriteLayerInfo {
        std::wstring name; // 层名称
        std::wstring des;  // 层描述
    };
    
    virtual bool GetActionInfo(const std::wstring &modelname, const std::wstring &actname, ActionInfo &info) const = 0;
    virtual std::vector<SpriteLayerInfo> GetSpriteLayerInfo(const std::wstring &modelname) const = 0;
};
```

#### IEnv 接口（环境配置）

**文件位置**: [`engine/nuienv.h`](../../../engine/nuienv.h)

```cpp
class IEnv {
public:
    // 调试选项
    virtual void SetConsoleInfo(NuclearConsoleInfo eInfo, bool bOn) = 0;
    virtual void ShowSpritePath(bool b) = 0;
    virtual void ShowMapGrid(bool b) = 0;
    
    // 性能配置
    virtual void SetDynamicMapLoading(bool b) = 0;
    virtual void SetControlFPS(bool b) = 0;
    
    // 渲染选项
    virtual void SetRenderSpriteShadow(bool b) = 0;
    virtual void SetEnableSurfaceCache(bool b) = 0;
};
```

#### ISprite 接口（精灵）

**文件位置**: [`engine/nuisprite.h`](../../../engine/nuisprite.h)

```cpp
class ISprite : virtual public ISelectableObj {
public:
    // 位置和方向
    virtual void SetLocation(const NuclearLocation& location) = 0;
    virtual NuclearLocation GetLocation() const = 0;
    virtual void SetDirection(NuclearDirection direction) = 0;
    
    // 缩放和透明度
    virtual void SetScale(float scale) = 0;
    virtual void SetAlpha(unsigned char a) = 0;
    
    // 可见性
    virtual void SetVisible(bool v) = 0;
    virtual bool IsVisiable() const = 0;
    
    // 模型和组件
    virtual bool SetModel(const std::wstring &modelname, bool async) = 0;
    virtual const std::wstring& GetModelName() const = 0;
    
    // 动作系统
    virtual bool PlayAction(const std::wstring& action_name, XPSPRITE_ACTION_LOAD_TYPE type, float fScaleForTotalTime) = 0;
    
    // 移动系统
    virtual void SetMoveSpeed(float speed) = 0;
    virtual void MoveTo(int targetX, int targetY, int range, const CSIZE * size, bool straight) = 0;
    virtual void MoveTo(astar::Path & trail) = 0;
};
```

#### IImmovableObj / ISelectableObj 接口

```cpp
// 静态对象接口
class IImmovableObj {
public:
    virtual NuclearLocation GetLocation() const = 0;
    virtual void SetLocation(const NuclearLocation& loc) = 0;
};

// 可选择对象接口
class ISelectableObj {
public:
    virtual bool IsSelected() const = 0;
    virtual void SetSelected(bool selected) = 0;
};
```

### 类继承关系

```
ISelectableObj (接口)
    └── ISprite (接口) [engine/nuisprite.h]
           └── Sprite (实现) [engine/sprite/nusprite.h]
               ├── MovableSpriteImp [engine/sprite/numovablespriteimp.h]
               ├── C3DSprite [engine/sprite/nuc3dsprite.h]
               ├── ComponentSprite [engine/sprite/nucomponentsprite.h]
               └── SpineSprite [engine/sprite/nuspinesprite.h]

IEffect (接口)
    ├── ParticleEffect [engine/particlesystem/]
    ├── ListEffect [engine/effect/nulisteffect.h]
    └── SpecialParticleSystem [engine/particlesystem/]
```

### 1. Nuclear 精灵系统使用示例

```cpp
// 获取引擎（命名空间函数）
IEngine* engine = Nuclear::GetEngine();

// 获取世界接口
IWorld* world = engine->GetWorld();

// 创建精灵 - 使用 NewSprite
ISprite* sprite = world->NewSprite(NSL_OBJECT, L"player_model");

// 设置精灵属性
NuclearLocation loc(100, 200);
sprite->SetLocation(loc);
sprite->SetVisible(true);

// 播放动作
sprite->PlayAction(L"walk", XPSPRITE_ACTION_LOAD_TYPE::LOAD_ASYNC, 1.0f);

// 删除精灵 - 使用 DeleteSprite
world->DeleteSprite(sprite);
```

### 2. 引用计数

```cpp
class RefCounted {
private:
    int m_refCount;

public:
    RefCounted() : m_refCount(0) {}

    void AddRef() { ++m_refCount; }

    void Release() {
        if (--m_refCount == 0) {
            delete this;
        }
    }
};
```

### 3. 脏标记模式

```cpp
class Transform {
private:
    bool m_bDirty;
    Matrix m_matrix;

public:
    void SetPosition(float x, float y) {
        m_position.x = x;
        m_position.y = y;
        m_bDirty = true;  // 标记为脏
    }

    const Matrix& GetMatrix() {
        if (m_bDirty) {
            RecalculateMatrix();
            m_bDirty = false;
        }
        return m_matrix;
    }
};
```

### 4. 对象池

```cpp
template<typename T>
class ObjectPool {
private:
    std::vector<T*> m_freeList;
    std::vector<T*> m_usedList;

public:
    T* Allocate() {
        if (m_freeList.empty()) {
            return new T();
        }
        T* obj = m_freeList.back();
        m_freeList.pop_back();
        m_usedList.push_back(obj);
        return obj;
    }

    void Free(T* obj) {
        auto it = std::find(m_usedList.begin(),
                           m_usedList.end(), obj);
        if (it != m_usedList.end()) {
            m_usedList.erase(it);
            m_freeList.push_back(obj);
        }
    }
};
```

---

## 🛠️ 常用操作

### 添加新类

```cpp
// 1. 创建头文件 Foo.h
#ifndef __Nuclear_FOO_H__
#define __Nuclear_FOO_H__

namespace Nuclear {

class Foo {
private:
    int m_value;

public:
    Foo();
    ~Foo();

    void SetValue(int value);
    int GetValue() const;
};

} // namespace Nuclear

#endif

// 2. 创建实现文件 Foo.cpp
#include "nupch.h"  // 必须第一行
#include "Foo.h"

namespace Nuclear {

Foo::Foo() : m_value(0) {
}

Foo::~Foo() {
}

void Foo::SetValue(int value) {
    m_value = value;
}

int Foo::GetValue() const {
    return m_value;
}

} // namespace Nuclear
```

### 扩展现有功能

```cpp
// 1. 找到相关类 (使用 Serena MCP)
// 2. 阅读接口和实现
// 3. 添加新方法
class Sprite {
public:
    // 现有方法...

    // 新增方法
    void SetScale(float scaleX, float scaleY);
    void GetScale(float& outScaleX, float& outScaleY) const;

private:
    float m_scaleX;
    float m_scaleY;
};
```

---

## ⚠️ 常见陷阱

### 1. 忘记预编译头

```cpp
// ❌ 错误: 编译失败
#include "Sprite.h"

// ✅ 正确: 第一行必须是 nupch.h
#include "nupch.h"
#include "Sprite.h"
```

### 2. 内存泄漏

```cpp
// ❌ 错误: 内存泄漏
ISprite* sprite = engine->CreateSprite(L"model");
// ... 忘记释放

// ✅ 正确: 使用后释放
ISprite* sprite = engine->CreateSprite(L"model");
// ... 使用精灵
engine->ReleaseSprite(sprite);
sprite = nullptr;
```

### 3. 宽字符串错误

```cpp
// ❌ 错误: 使用窄字符串
sprite->LoadModel("player");

// ✅ 正确: 使用宽字符串
sprite->LoadModel(L"player");
```

### 4. 工具集版本错误

```xml
<!-- ❌ 错误: 使用 v140 -->
<PlatformToolset>v140</PlatformToolset>

<!-- ✅ 正确: 必须使用 v120 -->
<PlatformToolset>v120</PlatformToolset>
```

---

## 🎯 实践项目

### 初级项目：添加精灵缩放功能
```
任务：为 Sprite 类添加缩放功能
步骤：
1. 在 ISprite 接口添加 SetScale/GetScale 方法
2. 在 Sprite 实现类中实现这些方法
3. 修改渲染代码应用缩放
4. 在 Lua 中暴露接口
5. 编写测试代码验证
```

### 中级项目：实现特效管理器
```
任务：设计并实现一个特效管理器
要求：
- 使用对象池优化内存
- 支持特效播放、暂停、停止
- 支持特效层级管理
- 提供 Lua 接口
```

### 高级项目：优化渲染批次
```
任务：优化精灵渲染批次，减少 Draw Call
技术：
- 分析当前渲染流程
- 实现精灵批次合并
- 使用纹理图集
- 性能测试和对比
```

---

## 📚 推荐阅读

### 项目文档
1. [项目概览](../../../docs/01-快速入门/02-项目概述.md)
2. [项目架构](../../../docs/02-技术架构/02-项目架构.md)
3. [Windows 完整构建指南](../../../docs/03-开发指南/02-Windows完整构建指南.md)

### 外部资源
1. **Effective C++** - Scott Meyers
2. **More Effective C++** - Scott Meyers
3. **C++ Coding Standards** - Herb Sutter

---

## ✅ 技能检查清单

### 初级检查点
- [ ] 能够成功编译客户端
- [ ] 理解五层架构
- [ ] 能够阅读 Nuclear 引擎代码
- [ ] 熟悉项目命名规范
- [ ] 能够使用基本调试功能

### 中级检查点
- [ ] 能够添加新类和模块
- [ ] 理解精灵系统原理
- [ ] 掌握引用计数机制
- [ ] 能够使用对象池
- [ ] 能够排查常见 bug

### 高级检查点
- [ ] 能够设计模块架构
- [ ] 能够优化渲染性能
- [ ] 能够优化内存占用
- [ ] 能够进行跨模块重构
- [ ] 能够指导团队成员

---

**相关技能**:
- [Lua 脚本](lua-scripting.md)
- [Cocos2d-x 使用](cocos2dx-usage.md)
- [Windows 编译](windows-build.md)
- [性能优化](../common/performance-optimization.md)

**下次更新**: 2026-02-20

---

## 📋 更新日志

### v1.1.0 (2025-11-24)
- 添加版本控制和更新日志
- 完善技能检查清单
- 更新相关技能链接

### v1.0.0 (初始版本)
- 创建 C++ 开发技能文档
- 包含五层架构、代码规范、核心概念

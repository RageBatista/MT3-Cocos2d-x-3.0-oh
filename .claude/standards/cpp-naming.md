# C++ 命名约定 (C++ Naming Conventions)

> **范围**: MT3 项目 C++ 命名规则
> **版本**: 1.0 | **更新**: 2026-01-07

---

## 📋 概述

MT3 项目跨越多个代码层级,每层有不同的命名风格:

- **engine/**: Nuclear 引擎风格 (PascalCase 为主)
- **common/**: 标准 C++ 风格 (camelCase 为主)
- **cocos2d/**: Cocos2d-x 2.0 风格 (CC 前缀, 不可修改)
- **client/FireClient/**: FireClient 业务风格 (预编译库, 不可修改)

---

## 🎨 引擎层命名 (engine/)

### 类名

```cpp
// ✅ 正确: Nuclear 前缀 + PascalCase
class NuclearSprite : public CCNode {
    // ...
};

class NuclearWorld {
    // ...
};

class NuclearAnimationFrame {
    // ...
};

// ❌ 错误: 缺少 Nuclear 前缀
class Sprite {  // 会与 CCSprite 冲突
    // ...
};

// ❌ 错误: 使用下划线
class Nuclear_Sprite {
    // ...
};
```

**规则**:
- 引擎核心类必须有 `Nuclear` 前缀
- 使用 PascalCase (每个单词首字母大写)
- 不使用下划线分隔
- 继承 Cocos2d-x 类时保持一致性

### 成员变量

```cpp
class NuclearSprite {
private:
    // ✅ 正确: m_ 前缀 + 匈牙利命名
    int m_nHealth;           // n = number (整数)
    float m_fScale;          // f = float
    bool m_bVisible;         // b = boolean
    CCPoint m_ptLocation;    // pt = point
    std::string m_strName;   // str = string
    CCSprite* m_pSprite;     // p = pointer

    // ✅ 正确: m_ 前缀 + camelCase (无类型前缀也可接受)
    int m_health;
    float m_scale;
    bool m_visible;

    // ❌ 错误: 无 m_ 前缀
    int health;
    float scale;

    // ❌ 错误: 使用下划线分隔
    int m_max_health;
};
```

**规则**:
- 成员变量必须有 `m_` 前缀
- 可选匈牙利命名: `m_n` (int), `m_f` (float), `m_b` (bool), `m_p` (pointer)
- 或使用 `m_` + camelCase
- 私有成员优先,公有成员谨慎使用

### 成员函数

```cpp
class NuclearSprite {
public:
    // ✅ 正确: PascalCase,动词开头
    void SetLocation(const CCPoint& location);
    CCPoint GetLocation() const;
    void UpdateTransform();
    void DrawSprite();

    // ✅ 正确: is/has 前缀 (布尔查询)
    bool IsVisible() const;
    bool HasParent() const;

    // ❌ 错误: camelCase (引擎层应使用 PascalCase)
    void setLocation(const CCPoint& location);

    // ❌ 错误: 名词开头
    void Location(const CCPoint& location);  // 应为 SetLocation
};
```

**规则**:
- 使用 PascalCase
- 动词开头: Set/Get/Update/Draw/Create/Destroy
- 布尔查询: Is/Has/Can/Should
- const 函数标记 `const`

### 常量

```cpp
// ✅ 正确: 全大写 + 下划线
const int MAX_SPRITES = 1000;
const float PI = 3.14159f;
const char* DEFAULT_TEXTURE_PATH = "default.png";

// ✅ 正确: 类内静态常量
class NuclearConfig {
public:
    static const int MAX_LAYERS = 10;
    static const float DEFAULT_SCALE = 1.0f;
};

// ❌ 错误: camelCase
const int maxSprites = 1000;

// ❌ 错误: 无命名空间/类限定
const int MAX = 10;  // 太泛化,易冲突
```

**规则**:
- 全大写 + 下划线
- 带描述性前缀 (MAX_/MIN_/DEFAULT_)
- 优先使用类内静态常量限定作用域

### 宏定义

```cpp
// ✅ 正确: NUCLEAR_ 前缀 + 全大写
#define NUCLEAR_SAFE_DELETE(p) \
    do { if (p) { delete (p); (p) = nullptr; } } while (0)

#define NUCLEAR_SAFE_RELEASE(p) \
    do { if (p) { (p)->release(); (p) = nullptr; } } while (0)

#define NUCLEAR_ASSERT(cond, msg) \
    do { if (!(cond)) { CCLog("Assert: %s", msg); } } while (0)

// ❌ 错误: 无命名空间前缀
#define SAFE_DELETE(p) \
    do { if (p) { delete (p); (p) = nullptr; } } while (0)  // 易与其他库冲突

// ❌ 错误: 函数式宏未使用 do-while(0)
#define NUCLEAR_LOG(msg) CCLog(msg)  // 在 if 语句中会出错
```

**规则**:
- 必须有 `NUCLEAR_` 前缀
- 全大写 + 下划线
- 函数式宏使用 `do { ... } while (0)` 包装
- 优先使用 inline 函数替代宏

### 枚举

```cpp
// ✅ 正确: enum class (C++11,v120 支持)
enum class SpriteType {
    Static,
    Animated,
    Particle
};

// ✅ 正确: 传统 enum (带前缀)
enum ESpriteType {
    ST_Static,
    ST_Animated,
    ST_Particle
};

// 使用
SpriteType type = SpriteType::Animated;
ESpriteType type2 = ST_Animated;

// ❌ 错误: 无前缀的传统 enum
enum SpriteType {
    Static,    // 易与其他枚举冲突
    Animated,
    Particle
};
```

**规则**:
- 优先使用 `enum class` (类型安全)
- 传统 enum 使用前缀 (E + TypeName, 枚举值用缩写前缀)
- 枚举值使用 PascalCase 或全大写

---

## 🛠️ 工具层命名 (common/)

### 类名

```cpp
// ✅ 正确: 描述性名词 + Manager/Helper/Util 后缀
class TextureManager {
    // 资源管理类
};

class MathHelper {
    // 数学辅助类
};

class StringUtil {
    // 字符串工具类
};

// ✅ 正确: RAII 资源管理类
class FileGuard {
    FILE* m_file;
public:
    FileGuard(const char* path);
    ~FileGuard();
};

// ❌ 错误: 无意义缩写
class TexMgr {  // 应为 TextureManager
};
```

**规则**:
- PascalCase
- 管理类: XxxManager
- 辅助类: XxxHelper
- 工具类: XxxUtil
- RAII 类: XxxGuard

### 成员变量

```cpp
class TextureManager {
private:
    // ✅ 正确: m_ 前缀 + camelCase
    std::map<std::string, CCTexture2D*> m_textures;
    int m_cacheCapacity;
    bool m_enableCompression;

    // ❌ 错误: 无 m_ 前缀
    std::map<std::string, CCTexture2D*> textures;
};
```

**规则**:
- `m_` 前缀 + camelCase
- 不强制匈牙利命名 (可选)

### 成员函数

```cpp
class TextureManager {
public:
    // ✅ 正确: camelCase,动词开头
    void loadTexture(const std::string& path);
    CCTexture2D* getTexture(const std::string& name) const;
    void clearCache();

    // ✅ 正确: 布尔查询
    bool hasTexture(const std::string& name) const;
    bool isLoaded(const std::string& name) const;

    // ❌ 错误: PascalCase (工具层应使用 camelCase)
    void LoadTexture(const std::string& path);
};
```

**规则**:
- camelCase (与引擎层区分)
- 动词开头
- const 查询标记 `const`

---

## 🎮 Cocos2d-x 层命名

### 遵循 Cocos2d-x 2.0 风格 (不可修改)

```cpp
// ✅ Cocos2d-x 标准风格
class CCSprite : public CCNode {
public:
    static CCSprite* create(const char* filename);
    void setPosition(const CCPoint& pos);
    CCPoint getPosition() const;

private:
    CCTexture2D* m_pobTexture;
    bool m_bDirty;
};

// ⚠️ 注意: MT3 项目不应修改 cocos2d-2.0-rc2-x-2.0.1/ 代码
```

**规则** (仅供参考):
- 类名: CC 前缀 + PascalCase
- 成员变量: `m_pob` (object pointer), `m_b` (bool), `m_u` (unsigned)
- 成员函数: camelCase
- 不应修改 Cocos2d-x 源码

---

## 📦 命名空间

### 引擎层

```cpp
// ✅ 正确: Nuclear 命名空间
namespace Nuclear {
    class Sprite {
        // ...
    };

    namespace Renderer {
        class OpenGLRenderer {
            // ...
        };
    }
}

// 使用
Nuclear::Sprite* sprite = new Nuclear::Sprite();
Nuclear::Renderer::OpenGLRenderer renderer;

// ❌ 错误: 全局命名空间
class NuclearSprite {  // 应该在 Nuclear 命名空间内
    // ...
};
```

### 工具层

```cpp
// ✅ 正确: 功能命名空间
namespace Utils {
    namespace String {
        std::string trim(const std::string& str);
    }

    namespace Math {
        float clamp(float value, float min, float max);
    }
}

// 使用
std::string result = Utils::String::trim("  hello  ");
float value = Utils::Math::clamp(1.5f, 0.0f, 1.0f);
```

---

## 📝 文件命名

### 头文件

```bash
# ✅ 正确: 小写 + 下划线
nuclearsprite.h
nuclearworld.h
texture_manager.h
string_util.h

# ✅ 正确: 匹配类名 (部分项目风格)
NuclearSprite.h
NuclearWorld.h

# ❌ 错误: 大小写混乱
NuclearSprite.H
nuclearSprite.h
```

### 源文件

```bash
# ✅ 正确: 与头文件匹配
nuclearsprite.cpp
nuclearworld.cpp
texture_manager.cpp

# 或
NuclearSprite.cpp
NuclearWorld.cpp
```

**规则**:
- 与类名对应 (小写或 PascalCase)
- `.h` 头文件, `.cpp` 源文件
- 一致性优先 (项目内统一风格)

---

## 🔍 特殊情况

### tolua++ 绑定代码

```cpp
// ✅ tolua++ 生成代码风格 (不可修改)
int tolua_Nuclear_NuclearSprite_SetLocation00(lua_State* tolua_S) {
    // 自动生成代码
}

// ⚠️ 手动绑定代码
static int lua_NuclearSprite_setLocation(lua_State* L) {
    // 遵循 lua_ClassName_methodName 风格
}
```

### 接口类

```cpp
// ✅ 正确: I 前缀
class IFireClient {
public:
    virtual ~IFireClient() {}
    virtual void connect(const char* host, int port) = 0;
    virtual void disconnect() = 0;
};

// ✅ 正确: 实现类
class FireClientImpl : public IFireClient {
    // ...
};
```

### 抽象基类

```cpp
// ✅ 正确: Base 后缀
class SpriteBase {
public:
    virtual ~SpriteBase() {}
    virtual void draw() = 0;
};

// ✅ 正确: 派生类
class AnimatedSprite : public SpriteBase {
    // ...
};
```

---

## ✅ 检查清单

### 新建类时

```yaml
- [ ] 类名符合层级风格 (Nuclear/Xxx/CC)
- [ ] 成员变量有 m_ 前缀
- [ ] 成员函数符合大小写规则 (PascalCase/camelCase)
- [ ] 公有接口使用动词
- [ ] 布尔查询使用 is/has 前缀
- [ ] 析构函数为 virtual (如有继承)
```

### 新建常量/宏时

```yaml
- [ ] 常量全大写 + 下划线
- [ ] 宏有命名空间前缀 (NUCLEAR_)
- [ ] 函数式宏使用 do-while(0)
- [ ] 考虑用 const/inline 替代宏
```

### 代码审查时

```yaml
- [ ] 命名一致性 (不混用风格)
- [ ] 避免单字母变量 (除循环)
- [ ] 避免无意义缩写
- [ ] 命名体现意图 (不需要注释解释)
```

---

## 📚 参考示例

### 引擎层完整示例

```cpp
// nuclearsprite.h
#pragma once

#include "cocos2d.h"

namespace Nuclear {

class NuclearSprite : public cocos2d::CCNode {
public:
    // 工厂方法
    static NuclearSprite* create();

    // 生命周期
    NuclearSprite();
    virtual ~NuclearSprite();

    // 属性访问
    void SetLocation(const cocos2d::CCPoint& location);
    cocos2d::CCPoint GetLocation() const;

    void SetScale(float scale);
    float GetScale() const;

    // 查询
    bool IsVisible() const;
    bool HasTexture() const;

    // 更新
    void Update(float dt);

private:
    // 成员变量
    cocos2d::CCPoint m_ptLocation;
    float m_fScale;
    bool m_bVisible;
    cocos2d::CCSprite* m_pSprite;

    // 辅助方法
    void UpdateTransform();
};

} // namespace Nuclear
```

### 工具层完整示例

```cpp
// texture_manager.h
#pragma once

#include <map>
#include <string>
#include "cocos2d.h"

namespace Utils {

class TextureManager {
public:
    static TextureManager* getInstance();

    void loadTexture(const std::string& path);
    cocos2d::CCTexture2D* getTexture(const std::string& name) const;
    void clearCache();

    bool hasTexture(const std::string& name) const;
    int getCacheSize() const;

private:
    TextureManager();
    ~TextureManager();

    std::map<std::string, cocos2d::CCTexture2D*> m_textures;
    int m_cacheCapacity;
};

} // namespace Utils
```

---

**文档版本**: 1.0
**最后更新**: 2026-01-07
**参考标准**: MT3 项目实践, Cocos2d-x 2.0 风格

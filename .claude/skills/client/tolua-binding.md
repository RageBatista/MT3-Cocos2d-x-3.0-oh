---
name: tolua-binding
version: 1.4.0
priority: high
category: client
description: |
  MT3客户端tolua++ C++/Lua绑定技能。涵盖.pkg文件编写、绑定生成流程、类型映射、内存管理、常见错误排查。
  触发词: tolua++, 绑定, .pkg, 类型映射, LuaCFunction, tolua_push, tolua_to, 模块注册, LuaBridge Lua, C++, 接口导出
dependencies:
  - cpp-development
  - lua-scripting
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 10000
---

# tolua++ 绑定开发指南

**版本**: v1.4.0
**最后更新**: 2026-04-11

---

## 📋 概述

MT3 使用 tolua++ 1.0.93 将 C++ 类和函数暴露给 Lua 脚本层，实现游戏逻辑与引擎的解耦。

### 技术栈

```yaml
tolua++ 版本: 1.0.93
Lua 版本: 5.1 (LuaJIT 2.0.3)
生成方式: .pkg 文件 → tolua++ 工具 → C++ 绑定代码
```

### 核心约束

```yaml
⚠️ 强制规则:
  - ❌ 禁止手动修改生成的绑定代码 (*_bind.cpp)
  - ✅ 只能修改 .pkg 文件，然后重新生成
  - ✅ 生成后需要重新编译客户端
```

---

## 📁 文件结构

```
client/
├── tolua++-pkgs/                   # tolua++ 包定义目录
│   ├── generate.bat                # Windows 生成脚本
│   ├── generate.sh                 # Linux/macOS 生成脚本
│   ├── Cocos2d.pkg                 # Cocos2d-x 绑定包
│   ├── Nuclear.pkg                 # Nuclear 引擎绑定包
│   ├── FireClient.pkg              # FireClient 业务绑定包
│   ├── CEGUI.pkg                   # CEGUI UI 绑定包
│   └── ...
├── tolua++-bind/                   # 生成的绑定代码 (自动生成)
│   ├── Cocos2d_bind.cpp            # ❌ 不可手动修改
│   ├── Nuclear_bind.cpp            # ❌ 不可手动修改
│   ├── FireClient_bind.cpp         # ❌ 不可手动修改
│   └── ...
└── tolua++/                        # tolua++ 工具
    ├── tolua++.exe                 # Windows 版本
    └── ...
```

---

## 🔧 .pkg 文件语法

### 基本结构

```cpp
// MyModule.pkg

$#include "MyClass.h"              // C++ 头文件包含

module MyModule                     // 模块名
{
    // 类定义
    class MyClass
    {
        // 构造函数
        MyClass();
        ~MyClass();

        // 成员函数
        void doSomething(int value);
        int getValue();

        // 属性 (getter/setter)
        tolua_property int count;

        // 静态函数
        static MyClass* getInstance();
    };
}
```

### 常用语法元素

#### 1. 模块声明

```cpp
module GameModule
{
    // 模块内容
}
```

#### 2. 类定义

```cpp
class Player : public Entity     // 继承
{
    Player();                    // 构造函数
    ~Player();                   // 析构函数

    void update(float dt);       // 成员函数
    const char* getName();       // 返回字符串

    int level;                   // 公共成员变量
};
```

#### 3. 枚举

```cpp
enum PlayerState
{
    STATE_IDLE,
    STATE_WALKING,
    STATE_RUNNING,
    STATE_ATTACKING
};
```

#### 4. 命名空间

```cpp
namespace Nuclear
{
    class World
    {
        static World* getInstance();
        void addEntity(Entity* entity);
    };
}
```

#### 5. 函数重载

```cpp
class Vector2
{
    Vector2();
    Vector2(float x, float y);

    float length();
    void normalize();

    // 使用 @ 区分重载
    Vector2 operator+(const Vector2& other) @ add;
    Vector2 operator-(const Vector2& other) @ sub;
};
```

#### 6. 回调函数

```cpp
// 使用 typedef 定义回调类型
typedef void (*EventCallback)(int eventId, void* data);

class EventManager
{
    void subscribe(int eventId, EventCallback callback);
};
```

---

## 🚀 生成流程

### Windows

```batch
cd client\tolua++-pkgs
generate.bat
```

### 生成脚本内容

```batch
@echo off
set TOLUA=..\tolua++\tolua++.exe
set OUTPUT=..\tolua++-bind

%TOLUA% -o %OUTPUT%\Cocos2d_bind.cpp -H %OUTPUT%\Cocos2d_bind.h Cocos2d.pkg
%TOLUA% -o %OUTPUT%\Nuclear_bind.cpp -H %OUTPUT%\Nuclear_bind.h Nuclear.pkg
%TOLUA% -o %OUTPUT%\FireClient_bind.cpp -H %OUTPUT%\FireClient_bind.h FireClient.pkg

echo 绑定代码生成完成
```

### 验证生成结果

```batch
:: 检查生成的文件
dir ..\tolua++-bind\*.cpp

:: 检查文件时间戳
forfiles /p ..\tolua++-bind /m *.cpp /c "cmd /c echo @file @fdate @ftime"
```

---

## 📜 Lua 调用示例

### C++ 类定义

```cpp
// Player.h
class Player {
public:
    Player(const std::string& name);
    ~Player();

    void setPosition(float x, float y);
    void attack(Entity* target);
    int getLevel() const;
    void setLevel(int level);

    static Player* create(const std::string& name);

private:
    std::string m_name;
    float m_x, m_y;
    int m_level;
};
```

### .pkg 文件

```cpp
// Player.pkg
$#include "Player.h"

class Player
{
    Player(const char* name);
    ~Player();

    void setPosition(float x, float y);
    void attack(Entity* target);

    int getLevel();
    void setLevel(int level);

    static Player* create(const char* name);
};
```

### Lua 调用

```lua
-- 创建玩家
local player = Player:create("Hero")

-- 设置属性
player:setPosition(100, 200)
player:setLevel(10)

-- 获取属性
local level = player:getLevel()
print("Player level: " .. level)

-- 攻击目标
local enemy = Monster:create("Goblin")
player:attack(enemy)
```

---

## ⚠️ 常见问题

### 1. 字符串类型转换

```cpp
// ❌ 错误：std::string 不能直接暴露
void setName(const std::string& name);

// ✅ 正确：使用 const char*
void setName(const char* name);
```

### 2. 指针 vs 引用

```cpp
// ❌ 错误：引用类型可能导致问题
Vector2& getPosition();

// ✅ 正确：返回值或指针
Vector2 getPosition();
// 或
Vector2* getPositionPtr();
```

### 3. 模板类

```cpp
// ❌ 错误：tolua++ 不支持模板
std::vector<int> getItems();

// ✅ 正确：使用包装函数
// C++ 侧
void getItemsLua(lua_State* L);

// .pkg 文件
void getItemsLua(lua_State* tolua_S);
```

### 4. 内存管理

```cpp
// 在 .pkg 中指定所有权
// tolua_new: Lua 管理内存
// tolua_delete: C++ 管理内存

class Player
{
    // Lua 创建的对象，Lua GC 时自动释放
    Player @ new() tolua_new;

    // C++ 管理的单例，不要让 Lua 释放
    static Player* getInstance();  // 默认 C++ 管理
};
```

### 5. 事件回调 (Lua 函数传递)

```lua
-- Lua 侧
local function onButtonClick(args)
    print("Button clicked!")
    return true
end

button:subscribeEvent("Clicked", onButtonClick)
```

```cpp
// C++ 侧需要特殊处理
// 使用 tolua_function 或自定义绑定
int lua_subscribeEvent(lua_State* L) {
    // 获取 Lua 函数引用
    int funcRef = luaL_ref(L, LUA_REGISTRYINDEX);
    // 存储并在事件触发时调用
    ...
}
```

---

## 🔍 调试技巧

### 1. 打印绑定信息

```lua
-- 检查类是否绑定成功
print(type(Player))           -- 应该输出 "table"
print(Player.create)          -- 应该输出 "function"

-- 列出类的所有方法
for k, v in pairs(Player) do
    print(k, type(v))
end
```

### 2. 检查对象类型

```lua
local player = Player:create("Test")
print(tolua.type(player))     -- 输出 "Player"
print(tolua.cast(player, "Entity"))  -- 类型转换
```

### 3. 内存泄漏检测

```lua
-- 强制 GC 并检查
collectgarbage("collect")
print(collectgarbage("count"))  -- 输出当前 Lua 内存使用 (KB)
```

---

## 📋 最佳实践

### 1. 分离接口和实现

```cpp
// IPlayer.h - 仅暴露给 Lua 的接口
class IPlayer {
public:
    virtual void setPosition(float x, float y) = 0;
    virtual int getLevel() const = 0;
};

// Player.h - 完整实现
class Player : public IPlayer {
    // 实现细节
};

// Player.pkg - 只暴露接口
class IPlayer {
    void setPosition(float x, float y);
    int getLevel();
};
```

### 2. 使用工厂模式

```cpp
// ❌ 避免：直接暴露构造函数可能导致内存问题
Player @ new();

// ✅ 推荐：使用工厂方法
static Player* create(const char* name);
```

### 3. 批量操作优化

```cpp
// ❌ 避免：频繁的 C++/Lua 调用
for i = 1, 1000 do
    entity:setX(i)  -- 每次调用都有跨语言开销
end

// ✅ 推荐：批量操作
entity:setPositions(positions)  -- 一次传递所有数据
```

---

## 📚 相关文档

- [C++ 开发指南](cpp-development.md)
- [Lua 脚本指南](lua-scripting.md)
- [生成代码规则](../../rules/04-generated-code.md)
- [依赖管理](../common/dependency-management.md)

---

## 📝 更新日志

| 版本 | 日期 | 变更 |
|-----|------|------|
| 1.0.0 | 2026-01-10 | 初始版本 |

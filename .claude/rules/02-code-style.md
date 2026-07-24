# 代码规范规则

> **优先级**: 🟡 重要
> **适用范围**: 所有代码提交

---

## C++ 代码规范

### 命名约定

```cpp
// 类名: PascalCase
class PlayerManager {};
class GameScene {};

// 成员变量: m_ 前缀 + camelCase
class Player {
    int m_health;
    std::string m_name;
    CCPoint m_position;
};

// 函数名: camelCase (Cocos2d-x 风格)
void updatePosition();
bool isPlayerDead();
int getHealth();
void setHealth(int value);

// 常量: ALL_CAPS
const int MAX_PLAYERS = 100;
const float MOVE_SPEED = 5.0f;

// 宏定义: ALL_CAPS
#define SAFE_DELETE(p) if(p) { delete p; p = nullptr; }
```

### 代码结构

```cpp
// ✅ 正确: 头文件包含顺序
#include "nupch.h"          // 1. 预编译头 (必须第一个)
#include <cocos2d.h>        // 2. 系统/引擎头文件
#include <CEGUI.h>          // 3. 第三方库
#include "GameDefines.h"    // 4. 项目头文件

// ✅ 正确: 使用命名空间
using namespace cocos2d;

// ❌ 禁止: 在头文件中 using namespace
// 会污染所有包含该头文件的源文件
```

### 内存管理

```cpp
// ✅ 正确: Cocos2d-x 对象使用 create 模式
CCSprite* sprite = CCSprite::create("image.png");
this->addChild(sprite);  // 自动管理生命周期

// ✅ 正确: 使用 CC_SAFE_RELEASE
CC_SAFE_RELEASE_NULL(m_sprite);

// ❌ 禁止: 手动 new Cocos2d-x 对象
CCSprite* sprite = new CCSprite();  // 错误!
```

---

## Lua 代码规范

### 命名约定

```lua
-- 类名: PascalCase
local PlayerController = class("PlayerController")

-- 局部变量: camelCase
local playerHealth = 100
local currentScene = nil

-- 常量: ALL_CAPS (使用注释标明)
local MAX_LEVEL = 100  -- 常量

-- 函数名: camelCase
local function calculateDamage(attack, defense)
    return math.max(0, attack - defense)
end

-- 方法: 冒号语法
function PlayerController:update(dt)
    self:updatePosition(dt)
end
```

### 代码结构

```lua
-- ✅ 正确: 局部化全局变量
local math = math
local string = string
local table = table
local pairs = pairs
local ipairs = ipairs

-- ✅ 正确: 模块返回
local M = {}

function M.init()
    -- 初始化代码
end

return M

-- ❌ 禁止: 全局变量污染
globalPlayer = {}  -- 错误! 使用 local
```

### 性能注意事项

```lua
-- ✅ 正确: 在循环外创建表
local tempTable = {}
for i = 1, 1000 do
    tempTable.x = i
    -- 使用 tempTable
end

-- ❌ 禁止: 在循环内创建表
for i = 1, 1000 do
    local t = {}  -- 每次都分配新内存!
    t.x = i
end
```

---

## Java 代码规范 (服务器端)

### 命名约定

```java
// 类名: PascalCase
public class PlayerManager {}
public class GameService {}

// 成员变量: camelCase
private int playerId;
private String playerName;

// 常量: ALL_CAPS
public static final int MAX_PLAYERS = 1000;

// 方法名: camelCase
public void processMessage(Message msg) {}
public boolean isPlayerOnline(int playerId) {}
```

### xbean 规范

```java
// ❌ 禁止: 手动修改 xbean 生成的代码
// 文件位置: server/**/xbean/*.java

// ✅ 正确: 修改 xbean.xml 后重新生成
// 1. 编辑 xbean.xml
// 2. 运行: ant xbean
// 3. 代码自动更新
```

### gnet 规范

```java
// ❌ 禁止: 手动修改 gnet 生成的代码
// 文件位置: server/**/rpc/*.java

// ✅ 正确: 修改 protocol.xml 后重新生成
// 1. 编辑 protocol.xml
// 2. 运行: ant gnet
// 3. 代码自动更新
```

---

## Git 提交规范

### 提交消息格式

```
<类型>: <简短描述>

<详细描述 (可选)>

<相关信息 (可选)>
```

### 类型列表

| 类型 | 说明 | 示例 |
|------|------|------|
| feat | 新功能 | feat: 添加背包系统 |
| fix | 修复 Bug | fix: 修复登录超时问题 |
| refactor | 重构 | refactor: 优化精灵渲染 |
| perf | 性能优化 | perf: 减少 draw call |
| docs | 文档 | docs: 更新 API 文档 |
| style | 格式 | style: 统一缩进 |
| test | 测试 | test: 添加单元测试 |
| chore | 构建/工具 | chore: 更新构建脚本 |

---

**相关文档**:
- [C++ 开发技能](../skills/client/cpp-development.md)
- [Lua 脚本技能](../skills/client/lua-scripting.md)
- [Java 开发技能](../skills/server/java-development.md)
- [Git 工作流](../skills/common/git-workflow.md)

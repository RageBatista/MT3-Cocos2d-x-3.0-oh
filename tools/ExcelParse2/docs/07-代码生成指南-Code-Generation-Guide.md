# 代码生成指南 (Code Generation Guide)

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术团队

---

## 文档概述

本文档详细说明 ExcelParse2 工具的代码生成规则，包括 C++、Java、Lua 和 PKG 绑定的代码生成规范。

---

## 目录

1. [C++ 代码生成规则](#c-代码生成规则)
2. [Java 代码生成规则](#java-代码生成规则)
3. [Lua 代码生成规则](#lua-代码生成规则)
4. [PKG 绑定生成规则](#pkg-绑定生成规则)
5. [模板自定义说明](#模板自定义说明)

---

## C++ 代码生成规则

### 头文件结构

C++ 头文件包含数据结构、表类和索引支持。

#### 文件模板

```cpp
#pragma once

#include <map>
#include <vector>
#include <string>

namespace fire {
namespace pb {

// 数据结构
struct Item {
    int id;
    std::string name;
    int level;
    long exp;
    
    // 默认构造函数
    Item() : id(0), level(0), exp(0) {}
};

// 表类
class ItemTable {
public:
    // 加载数据
    bool load(const char* filename);
    
    // 获取记录
    Item* getRecorder(int id);
    
    // 获取所有 ID
    std::vector<int> getAllID();
    
    // 获取记录数量
    size_t size() const { return m_data.size(); }
    
private:
    std::map<int, Item> m_data;
};

} // namespace pb
} // namespace fire
```

#### 编码规范

- **字符编码**：UTF-8 with BOM
- **包含保护**：`#pragma once`
- **命名空间**：使用 `fire::pb`
- **类名**：PascalCase（如 `ItemTable`）
- **成员变量**：`m_` 前缀（如 `m_data`）

---

### 数据结构生成

#### 基本类型映射

| Bean 类型 | C++ 类型 | 说明 |
|---------|---------|------|
| bool | bool | 布尔值 |
| int | int | 整数 |
| long | long | 长整数 |
| double | double | 浮点数 |
| string | std::string | 字符串 |
| vector<int> | std::vector<int> | 整数数组 |
| vector<long> | std::vector<long> | 长整数数组 |
| vector<double> | std::vector<double> | 浮点数数组 |
| vector<string> | std::vector<std::string> | 字符串数组 |
| Bean | struct | 自定义结构 |

#### 示例：基本类型

**Bean 定义**：
```xml
<bean name="Item" ...>
    <col name="id" type="int" .../>
    <col name="name" type="string" .../>
    <col name="level" type="int" .../>
    <col name="exp" type="long" .../>
</bean>
```

**生成的 C++ 代码**：
```cpp
struct Item {
    int id;
    std::string name;
    int level;
    long exp;
    
    Item() : id(0), level(0), exp(0) {}
};
```

#### 示例：数组类型

**Bean 定义**：
```xml
<bean name="Player" ...>
    <col name="id" type="int" .../>
    <col name="skills" type="vector<int>" value="int" .../>
</bean>
```

**生成的 C++ 代码**：
```cpp
struct Player {
    int id;
    std::vector<int> skills;
    
    Player() : id(0) {}
};
```

#### 示例：Bean 类型

**Bean 定义**：
```xml
<bean name="Position" ...>
    <col name="x" type="int" .../>
    <col name="y" type="int" .../>
</bean>

<bean name="Monster" ...>
    <col name="id" type="int" .../>
    <col name="position" type="Position" .../>
</bean>
```

**生成的 C++ 代码**：
```cpp
struct Position {
    int x;
    int y;
    
    Position() : x(0), y(0) {}
};

struct Monster {
    int id;
    Position position;
    
    Monster() : id(0) {}
};
```

---

### 表类生成

#### 基本方法

| 方法名 | 返回类型 | 说明 |
|-------|---------|------|
| load | bool | 加载二进制文件 |
| getRecorder | Item* | 根据 ID 获取记录 |
| getAllID | std::vector<int> | 获取所有 ID |
| size | size_t | 获取记录数量 |

#### 示例：表类

**生成的 C++ 代码**：
```cpp
class ItemTable {
public:
    bool load(const char* filename) {
        // 打开文件
        FILE* fp = fopen(filename, "rb");
        if (!fp) return false;
        
        // 读取文件头
        char magic[4];
        fread(magic, 1, 4, fp);
        if (strncmp(magic, "LDZY", 4) != 0) {
            fclose(fp);
            return false;
        }
        
        // 读取版本号
        ushort version;
        fread(&version, sizeof(ushort), 1, fp);
        
        // 读取记录数量
        ushort memberCount;
        fread(&memberCount, sizeof(ushort), 1, fp);
        
        // 读取列校验和
        uint colCheckNumber;
        fread(&colCheckNumber, sizeof(uint), 1, fp);
        
        // 读取数据
        for (int i = 0; i < memberCount; i++) {
            Item item;
            fread(&item.id, sizeof(int), 1, fp);
            // ... 读取其他字段
            m_data[item.id] = item;
        }
        
        fclose(fp);
        return true;
    }
    
    Item* getRecorder(int id) {
        auto it = m_data.find(id);
        if (it != m_data.end()) {
            return &it->second;
        }
        return nullptr;
    }
    
    std::vector<int> getAllID() {
        std::vector<int> ids;
        for (auto& pair : m_data) {
            ids.push_back(pair.first);
        }
        return ids;
    }
    
private:
    std::map<int, Item> m_data;
};
```

---

### 索引支持

#### 多索引支持

如果 Bean 定义包含多个索引字段，表类会生成对应的索引方法。

**示例**：
```cpp
class ItemTable {
public:
    // 根据 ID 获取记录
    Item* getRecorder(int id);
    
    // 根据 Name 获取记录
    Item* getRecorderByName(const std::string& name);
    
    // 根据 Level 获取记录列表
    std::vector<Item*> getRecorderByLevel(int level);
    
private:
    std::map<int, Item> m_data;
    std::map<std::string, Item*> m_nameIndex;
    std::multimap<int, Item*> m_levelIndex;
};
```

---

### TableDataManager 统一表管理器

#### 管理器结构

```cpp
class TableDataManager {
public:
    // 初始化
    bool initialize(const char* dataPath);
    
    // 获取表
    ItemTable* getItemTable();
    PlayerTable* getPlayerTable();
    
    // 清理
    void cleanup();
    
private:
    ItemTable m_itemTable;
    PlayerTable m_playerTable;
};
```

#### 使用示例

```cpp
// 初始化
TableDataManager::getInstance().initialize("data/");

// 获取表
ItemTable* itemTable = TableDataManager::getInstance().getItemTable();

// 查询数据
Item* item = itemTable->getRecorder(1);
if (item) {
    printf("Item name: %s\n", item->name.c_str());
}

// 获取所有 ID
std::vector<int> ids = itemTable->getAllID();
for (int id : ids) {
    Item* item = itemTable->getRecorder(id);
    if (item) {
        // 处理数据
    }
}
```

---

## Java 代码生成规则

### Bean 类结构

Java Bean 类实现 `Comparable` 和 `Checkable` 接口。

#### 文件模板

```java
package fire.pb;

import java.util.*;

public class Item implements Comparable<Item>, Checkable {
    private int id;
    private String name;
    private int level;
    private long exp;
    
    // Getter 方法
    public int getId() { return id; }
    public String getName() { return name; }
    public int getLevel() { return level; }
    public long getExp() { return exp; }
    
    // Setter 方法
    public void setId(int id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setLevel(int level) { this.level = level; }
    public void setExp(long exp) { this.exp = exp; }
    
    // Comparable 接口
    @Override
    public int compareTo(Item other) {
        return this.id - other.id;
    }
    
    // Checkable 接口
    @Override
    public boolean check() {
        if (id < 0) return false;
        if (level < 1 || level > 100) return false;
        if (exp < 0) return false;
        return true;
    }
}
```

#### 编码规范

- **字符编码**：UTF-8 无 BOM
- **包名**：使用 `fire.pb`
- **类名**：PascalCase（如 `Item`）
- **方法名**：camelCase（如 `getId()`）
- **成员变量**：private

---

### 数据类型映射

| Bean 类型 | Java 类型 | 说明 |
|---------|----------|------|
| bool | boolean | 布尔值 |
| int | int | 整数 |
| long | long | 长整数 |
| double | double | 浮点数 |
| string | String | 字符串 |
| vector<int> | int[] | 整数数组 |
| vector<long> | long[] | 长整数数组 |
| vector<double> | double[] | 浮点数数组 |
| vector<string> | String[] | 字符串数组 |
| Bean | class | 自定义类 |

---

### Getter/Setter 方法

#### 生成规则

每个字段自动生成对应的 Getter 和 Setter 方法。

**示例**：
```java
// 字段定义
private int id;

// Getter 方法
public int getId() { return id; }

// Setter 方法
public void setId(int id) { this.id = id; }
```

#### 命名规则

- Getter 方法：`get` + 字段名（首字母大写）
- Setter 方法：`set` + 字段名（首字母大写）
- 布尔类型 Getter：`is` + 字段名（首字母大写）

**示例**：
```java
private boolean enabled;

// Getter 方法
public boolean isEnabled() { return enabled; }

// Setter 方法
public void setEnabled(boolean enabled) { this.enabled = enabled; }
```

---

### 数据范围检查

#### min/max 验证

Bean 定义可以指定数据的最小值和最大值，生成的 Java 代码会自动验证。

**Bean 定义**：
```xml
<bean name="Item" ...>
    <col name="level" type="int" min="1" max="100" .../>
    <col name="exp" type="long" min="0" .../>
</bean>
```

**生成的 Java 代码**：
```java
@Override
public boolean check() {
    if (level < 1 || level > 100) return false;
    if (exp < 0) return false;
    return true;
}
```

#### Checkable 接口

```java
public interface Checkable {
    boolean check();
}
```

---

### Comparable 接口

#### 排序支持

Bean 类实现 `Comparable` 接口，支持排序。

**示例**：
```java
@Override
public int compareTo(Item other) {
    return this.id - other.id;
}
```

#### 使用示例

```java
List<Item> items = new ArrayList<>();
items.add(item1);
items.add(item2);

// 排序
Collections.sort(items);

// 查找
int index = Collections.binarySearch(items, targetItem);
```

---

## Lua 代码生成规则

### Lua 表类

#### 文件模板

```lua
local Item = {}
Item.data = {}

-- 加载二进制文件
function Item.load(filename)
    -- 读取文件
    local file = io.open(filename, "rb")
    if not file then
        return false
    end
    
    -- 读取文件头
    local magic = file:read(4)
    if magic ~= "LDZY" then
        file:close()
        return false
    end
    
    -- 读取版本号
    local version = string.unpack("<H", file:read(2))
    
    -- 读取记录数量
    local memberCount = string.unpack("<H", file:read(2))
    
    -- 读取列校验和
    local colCheckNumber = string.unpack("<I", file:read(4))
    
    -- 读取数据
    for i = 1, memberCount do
        local item = {}
        item.id = string.unpack("<i", file:read(4))
        -- ... 读取其他字段
        Item.data[item.id] = item
    end
    
    file:close()
    return true
end

-- 获取记录
function Item.getRecorder(id)
    return Item.data[id]
end

-- 获取所有 ID
function Item.getAllID()
    local ids = {}
    for id, _ in pairs(Item.data) do
        table.insert(ids, id)
    end
    return ids
end

return Item
```

#### 编码规范

- **字符编码**：ASCII
- **模块定义**：使用 `local M = {}` 模式
- **函数名**：camelCase（如 `getRecorder`）
- **返回值**：必须返回模块

---

### 二进制文件加载

#### 文件头读取

```lua
-- 读取魔数
local magic = file:read(4)
if magic ~= "LDZY" then
    return false
end

-- 读取版本号
local version = string.unpack("<H", file:read(2))

-- 读取记录数量
local memberCount = string.unpack("<H", file:read(2))

-- 读取列校验和
local colCheckNumber = string.unpack("<I", file:read(4))
```

#### 数据读取

```lua
-- 读取整数
local id = string.unpack("<i", file:read(4))

-- 读取长整数
local exp = string.unpack("<l", file:read(8))

-- 读取浮点数
local value = string.unpack("<d", file:read(8))

-- 读取字符串
local strLen = string.unpack("<I", file:read(4))
local str = file:read(strLen)

-- 读取数组
local arrayLen = string.unpack("<I", file:read(4))
local array = {}
for i = 1, arrayLen do
    array[i] = string.unpack("<i", file:read(4))
end
```

---

### 数据访问接口

#### 基本方法

| 方法名 | 返回类型 | 说明 |
|-------|---------|------|
| load | boolean | 加载二进制文件 |
| getRecorder | table | 根据 ID 获取记录 |
| getAllID | table | 获取所有 ID |
| size | number | 获取记录数量 |

#### 使用示例

```lua
-- 加载数据
Item.load("data/fire.pb.item.bin")

-- 获取记录
local item = Item.getRecorder(1)
if item then
    print("Item name: " .. item.name)
end

-- 获取所有 ID
local ids = Item.getAllID()
for i, id in ipairs(ids) do
    local item = Item.getRecorder(id)
    if item then
        -- 处理数据
    end
end
```

---

## PKG 绑定生成规则

### tolua++ 绑定定义

#### 文件模板

```pkg
$#include "Item.h"

class Item {
    bool load(const char* filename);
    Item* getRecorder(int id);
    std::vector<int> getAllID();
    size_t size();
};
```

#### 编码规范

- **字符编码**：UTF-8 无 BOM
- **头文件包含**：使用 `$#include`
- **类名**：PascalCase（如 `Item`）
- **函数名**：camelCase（如 `getRecorder`）

---

### 导出给 Lua 的接口

#### 基本类型导出

```pkg
// 基本类型
int id;
string name;
int level;
long exp;
double value;
bool enabled;

// 数组类型
std::vector<int> skills;
std::vector<string> names;
```

#### 方法导出

```pkg
// 无参数方法
bool load();

// 单参数方法
Item* getRecorder(int id);

// 多参数方法
Item* getRecorderByNameAndLevel(string name, int level);

// 返回值方法
std::vector<int> getAllID();
size_t size();
```

#### 构造函数导出

```pkg
// 默认构造函数
Item();

// 带参数构造函数
Item(int id, string name);
```

---

### 生成命令

#### tolua++ 命令

```bash
# 生成 C++ 绑定代码
tolua++ -o Item_bind.cpp -H Item_bind.h Item.pkg

# 编译绑定代码
g++ -c Item_bind.cpp -I/usr/include/lua5.1
```

#### 集成到项目

```cpp
// 在 Lua 初始化时加载绑定
#include "Item_bind.h"

void initLua() {
    lua_State* L = lua_open();
    tolua_Item_open(L);
    
    // 加载 Lua 脚本
    luaL_dofile(L, "Item.lua");
}
```

---

## 模板自定义说明

### 模板文件位置

```
ExcelParse2/
├── templates/
│   ├── cpp/
│   │   ├── header.txt      # C++ 头文件模板
│   │   └── source.txt      # C++ 源文件模板
│   ├── java/
│   │   └── bean.txt        # Java Bean 模板
│   ├── lua/
│   │   └── module.txt      # Lua 模块模板
│   └── pkg/
│       └── binding.txt     # PKG 绑定模板
```

### 模板变量

#### C++ 模板变量

| 变量名 | 说明 | 示例 |
|-------|------|------|
| `{NAMESPACE}` | 命名空间 | `fire::pb` |
| `{CLASS_NAME}` | 类名 | `Item` |
| `{STRUCT_NAME}` | 结构体名 | `Item` |
| `{MEMBER_DECLS}` | 成员变量声明 | `int id;` |
| `{METHOD_DECLS}` | 方法声明 | `bool load(const char* filename);` |

#### Java 模板变量

| 变量名 | 说明 | 示例 |
|-------|------|------|
| `{PACKAGE}` | 包名 | `fire.pb` |
| `{CLASS_NAME}` | 类名 | `Item` |
| `{MEMBER_DECLS}` | 成员变量声明 | `private int id;` |
| `{GETTER_METHODS}` | Getter 方法 | `public int getId() { return id; }` |
| `{SETTER_METHODS}` | Setter 方法 | `public void setId(int id) { this.id = id; }` |

#### Lua 模板变量

| 变量名 | 说明 | 示例 |
|-------|------|------|
| `{MODULE_NAME}` | 模块名 | `Item` |
| `{METHOD_DECLS}` | 方法声明 | `function Item.getRecorder(id)` |

---

### 自定义模板示例

#### C++ 自定义模板

**模板文件** (`templates/cpp/header.txt`)：
```cpp
#pragma once

#include <map>
#include <vector>
#include <string>

namespace {NAMESPACE} {

// 数据结构
struct {STRUCT_NAME} {{
{MEMBER_DECLS}
    {STRUCT_NAME}() : {MEMBER_INITS} {{}}
}};

// 表类
class {CLASS_NAME} {{
public:
{METHOD_DECLS}
private:
    std::map<int, {STRUCT_NAME}> m_data;
}};

} // namespace {NAMESPACE}
```

#### Java 自定义模板

**模板文件** (`templates/java/bean.txt`)：
```java
package {PACKAGE};

import java.util.*;

public class {CLASS_NAME} implements Comparable<{CLASS_NAME}>, Checkable {{
{MEMBER_DECLS}

{GETTER_METHODS}

{SETTER_METHODS}

    @Override
    public int compareTo({CLASS_NAME} other) {{
        return this.id - other.id;
    }}
    
    @Override
    public boolean check() {{
{CHECK_VALIDATIONS}
        return true;
    }}
}}
```

---

## 参考资料

- [00-文档索引-Documentation-Index.md](00-文档索引-Documentation-Index.md) - 文档导航
- [05-数据格式规范-Data-Format-Specification.md](05-数据格式规范-Data-Format-Specification.md) - 数据格式规范
- [06-Bean定义指南-Bean-Definition-Guide.md](06-Bean定义指南-Bean-Definition-Guide.md) - Bean 定义规范
- [08-二进制格式规范-Binary-Format-Specification.md](08-二进制格式规范-Binary-Format-Specification.md) - 二进制格式详解

---

**维护者**: 技术团队
**下次审查**: 2026-03-20
**许可证**: 内部使用

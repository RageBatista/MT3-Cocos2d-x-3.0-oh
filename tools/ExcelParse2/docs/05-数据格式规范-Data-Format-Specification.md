# 数据格式规范 (Data Format Specification)

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术团队

---

## 文档概述

本文档详细说明 ExcelParse2 工具支持的输入和输出数据格式规范，包括文件格式、编码规范、数据类型映射等内容。

---

## 目录

1. [输入格式详解](#输入格式详解)
2. [输出格式详解](#输出格式详解)
3. [编码规范](#编码规范)
4. [数据类型映射表](#数据类型映射表)
5. [数据验证规则](#数据验证规则)

---

## 输入格式详解

### 1. Excel 格式 (.xlsx, .xlsm)

ExcelParse2 使用 NPOI 库读取 Excel 文件，支持 `.xlsx` 和 `.xlsm` 格式。

#### 文件结构要求

```
Excel 文件结构：
├── 第 1 行：表头（列名）
├── 第 2 行：数据类型说明（可选）
└── 第 3 行及之后：数据行
```

#### 表头命名规则

- **列名**：使用小写字母或下划线分隔（如 `id`, `item_name`, `max_level`）
- **ID 列**：必须包含名为 `id` 或 `ID` 的列作为主键
- **命名约束**：列名不能包含特殊字符（如空格、括号、逗号等）

#### 数据类型说明（第 2 行）

第 2 行可以包含数据类型说明，格式为 `<类型>`：

| 类型标记 | 说明 | 示例 |
|---------|------|------|
| `<int>` | 整数 | `<int>` |
| `<long>` | 长整数 | `<long>` |
| `<double>` | 浮点数 | `<double>` |
| `<bool>` | 布尔值 | `<bool>` |
| `<string>` | 字符串 | `<string>` |
| `<vector<int>>` | 整数数组 | `<vector<int>>` |

#### 示例 Excel 文件

| id | name | level | exp |
|----|------|-------|-----|
| <int> | <string> | <int> | <long> |
| 1 | "战士" | 1 | 100 |
| 2 | "法师" | 1 | 100 |

#### 代码实现

参见 [`DataManager.cs`](../DataManager.cs:189) 中的 `loadXlsFile()` 方法：

```csharp
public bool loadXlsFile(string xlsPathFileName)
{
    // 滤过临时文件
    int nStartPos = xlsPathFileName.IndexOf("~$");
    if (nStartPos != -1)
    {
        return true;
    }

    MainWindow.Info("开始加载" + xlsPathFileName);
    XlsData data = new XlsData();
    XSSFWorkbook HSSFWB = new XSSFWorkbook(...);
    // ... 读取 Excel 数据
}
```

---

### 2. CSV 格式

CSV 文件使用 GB2312 编码，逗号分隔字段。

#### 文件结构要求

```
CSV 文件结构：
├── 第 1 行：表头（列名）
└── 第 2 行及之后：数据行
```

#### 字段分隔符

- **主分隔符**：逗号（`,`）
- **字符串引用**：双引号（`"`）
- **换行符**：`\r\n`（Windows 风格）

#### 编码规范

- **字符编码**：GB2312
- **原因**：兼容 Excel 导出的 CSV 文件

#### 示例 CSV 文件

```csv
id,name,level,exp
1,"战士",1,100
2,"法师",1,100
```

#### 代码实现

参见 [`DataManager.cs`](../DataManager.cs:82) 中的 `makeTitleIndexsCsv()` 方法：

```csharp
public bool makeTitleIndexsCsv()
{
    mTitleIndex.Clear();
    for (int i = 0; i < colCount; i++)
    {
        if (mData[i] != "\"\"" && !MainWindow.IsInvalidName(mData[i]))
        {
            try
            {
                mTitleIndex.Add(mData[i], i);
            }
            catch (ArgumentException ae)
            {
                MainWindow.Error("表" + mFileName + "的表头中有同名的列，列名是" + mData[i] + "！");
                return false;
            }
        }
    }
    return true;
}
```

---

### 3. TXT 格式

TXT 文件实际上是 CSV 格式，使用 GB2312 编码。

#### 文件结构要求

与 CSV 格式完全相同，仅文件扩展名不同。

#### 使用场景

- 需要使用文本编辑器编辑的配置文件
- 版本控制系统（如 Git）友好的格式

---

## 输出格式详解

### 1. 客户端 Bin 格式

二进制格式，用于客户端快速加载数据。

#### 文件头结构

```csharp
struct BinFileHeader {
    char magic[4];        // 'LDZY' (4 bytes)
    uint fileLength;       // 文件长度 (4 bytes)
    ushort version;        // 版本号 = 101 (2 bytes)
    ushort memberCount;    // 成员数量 (2 bytes)
    uint colCheckNumber;   // 列校验和 (4 bytes)
};
```

#### 数据记录格式

每个字段按类型写入：

- **bool**: 1 byte
- **int**: 4 bytes
- **long**: 8 bytes
- **double**: 8 bytes
- **string**: 长度 (4 bytes) + UTF-8 字节
- **vector<T>**: 长度 (4 bytes) + 元素数据

#### 文件命名规则

```
<命名空间>.<表名>.bin
示例：fire.pb.item.bin
```

#### 代码实现

参见 [`MainWindow.xaml.cs`](../MainWindow.xaml.cs:603) 中的二进制写入代码：

```csharp
bw.Write('L');
bw.Write('D');
bw.Write('Z');
bw.Write('Y');
uint fileLength = 0; // 最后覆盖
bw.Write(fileLength);
bw.Write(MainWindow.mBinFileVersion); // 101
ushort memberCount = 0; // 最后覆盖
bw.Write(memberCount);
bw.Write(beanDef.GetColCheckNumber());
```

详细格式说明参见 [`08-二进制格式规范-Binary-Format-Specification.md`](08-二进制格式规范-Binary-Format-Specification.md)。

---

### 2. 客户端 Xml 格式

XML 格式，用于客户端调试和数据验证。

#### 编码规范

- **字符编码**：UTF-8
- **XML 声明**：`<?xml version="1.0" encoding="UTF-8"?>`

#### 文件结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <entry>
    <id>1</id>
    <name>战士</name>
    <level>1</level>
    <exp>100</exp>
  </entry>
  <entry>
    <id>2</id>
    <name>法师</name>
    <level>1</level>
    <exp>100</exp>
  </entry>
</root>
```

#### 文件命名规则

```
<命名空间>.<表名>.xml
示例：fire.pb.item.xml
```

---

### 3. 客户端 C++ 格式

C++ 头文件格式，用于客户端编译时数据访问。

#### 文件结构

```cpp
#pragma once

#include <map>
#include <string>

namespace fire {
namespace pb {

// 数据结构
struct Item {
    int id;
    std::string name;
    int level;
    long exp;
};

// 表类
class ItemTable {
public:
    bool load(const char* filename);
    Item* getRecorder(int id);
    std::vector<int> getAllID();
    
private:
    std::map<int, Item> m_data;
};

} // namespace pb
} // namespace fire
```

#### 文件命名规则

```
<表名>.h
示例：Item.h
```

---

### 4. 客户端 Lua 格式

Lua 表格式，用于客户端脚本访问数据。

#### 编码规范

- **字符编码**：ASCII
- **原因**：Lua 解释器不支持 BOM

#### 文件结构

```lua
local Item = {}
Item.data = {}

Item.data[1] = {
    id = 1,
    name = "战士",
    level = 1,
    exp = 100
}

Item.data[2] = {
    id = 2,
    name = "法师",
    level = 1,
    exp = 100
}

function Item.getRecorder(id)
    return Item.data[id]
end

function Item.getAllID()
    local ids = {}
    for id, _ in pairs(Item.data) do
        table.insert(ids, id)
    end
    return ids
end

return Item
```

#### 文件命名规则

```
<表名>.lua
示例：Item.lua
```

---

### 5. 客户端 PKG 格式

tolua++ 绑定格式，用于导出 C++ 接口给 Lua。

#### 文件结构

```pkg
$#include "Item.h"

class Item {
    bool load(const char* filename);
    Item* getRecorder(int id);
    std::vector<int> getAllID();
};
```

#### 文件命名规则

```
<表名>.pkg
示例：Item.pkg
```

详细说明参见 [`07-代码生成指南-Code-Generation-Guide.md`](07-代码生成指南-Code-Generation-Guide.md)。

---

### 6. 服务器 Xml 格式

XML 格式，用于服务器数据加载。

#### 编码规范

- **字符编码**：UTF-8
- **XML 声明**：`<?xml version="1.0" encoding="UTF-8"?>`

#### 文件结构（tree-map 格式）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <entry>
    <int>1</int>
    <fire.pb.item>
      <id>1</id>
      <name>战士</name>
      <level>1</level>
      <exp>100</exp>
    </fire.pb.item>
  </entry>
  <entry>
    <int>2</int>
    <fire.pb.item>
      <id>2</id>
      <name>法师</name>
      <level>1</level>
      <exp>100</exp>
    </fire.pb.item>
  </entry>
</root>
```

#### 代码实现

参见 [`ServerBeanData.cs`](../ServerBeanData.cs:23) 中的 `WriteFile()` 方法：

```csharp
public bool WriteFile(ref StreamWriter bw, ref XlsData fileData, string spaceName)
{
    bool result = true;
    ServerBeanNode node;
    if (mRoot.FindNodeFromName(out node, "id"))
    {
        if (fileData.mIdIndex.Count() == 0)
        {
            if (!fileData.makeIdIndexs(node.GetNodeXlsTitle()))
            {
                result = false;
            }
        }

        if (result == true)
        {
            Dictionary<int, int>.KeyCollection ids = fileData.mIdIndex.Keys;
            foreach (int id in ids)
            {
                bw.Write("  <entry>\n");
                // ... 写入数据
                bw.Write("  </entry>\n");
            }
        }
    }
    return true;
}
```

---

### 7. 服务器 Java 格式

Java Bean 类格式，用于服务器数据访问。

#### 文件结构

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

#### 文件命名规则

```
<表名>.java
示例：Item.java
```

---

## 编码规范

### 文件类型编码表

| 文件类型 | 编码格式 | BOM要求 | 说明 |
|---------|---------|---------|------|
| **输入文件** |
| Excel (.xlsx, .xlsm) | UTF-8 | 无 | NPOI 库自动处理 |
| CSV | GB2312 | 无 | 兼容 Excel 导出 |
| TXT | GB2312 | 无 | CSV 格式 |
| **输出文件** |
| 客户端 Bin | 二进制 | N/A | 二进制格式 |
| 客户端 Xml | UTF-8 | 无 | XML 标准 |
| 客户端 C++ | UTF-8 with BOM | **必须** | VS2013 需要 BOM |
| 客户端 Lua | ASCII | 禁止 | Lua 解释器不支持 BOM |
| 客户端 PKG | UTF-8 | 禁止 | tolua++ 不支持 BOM |
| 服务器 Xml | UTF-8 | 无 | XML 标准 |
| 服务器 Java | UTF-8 | 禁止 | Java 编译器不支持 BOM |

### 编码转换规则

#### 字符串编码转换

```csharp
// UTF-8 转换
byte[] utf8Bytes = System.Text.UnicodeEncoding.UTF8.GetBytes(data);
bw.Write(utf8Bytes.Length);
bw.Write(utf8Bytes);

// GB2312 转换
byte[] gb2312Bytes = System.Text.Encoding.GetEncoding("GB2312").GetBytes(data);
```

#### BOM 添加规则

```csharp
// C++ 文件添加 BOM
public static void AddBOM(string filePath)
{
    byte[] bom = new byte[] { 0xEF, 0xBB, 0xBF };
    byte[] content = File.ReadAllBytes(filePath);
    using (FileStream fs = new FileStream(filePath, FileMode.Create))
    {
        fs.Write(bom, 0, bom.Length);
        fs.Write(content, 0, content.Length);
    }
}
```

---

## 数据类型映射表

### 基本数据类型

| Excel 类型 | C++ 类型 | Java 类型 | Lua 类型 | 二进制大小 |
|-----------|---------|----------|---------|-----------|
| bool | bool | boolean | boolean | 1 byte |
| int | int | int | number | 4 bytes |
| long | long | long | number | 8 bytes |
| double | double | double | number | 8 bytes |
| string | std::string | String | string | 长度 + UTF-8 字节 |

### 复合数据类型

| Excel 类型 | C++ 类型 | Java 类型 | Lua 类型 | 说明 |
|-----------|---------|----------|---------|------|
| vector<int> | std::vector<int> | int[] | table | 整数数组 |
| vector<long> | std::vector<long> | long[] | table | 长整数数组 |
| vector<double> | std::vector<double> | double[] | table | 浮点数数组 |
| vector<string> | std::vector<std::string> | String[] | table | 字符串数组 |
| Bean | struct | class | table | 自定义结构 |

### 类型映射示例

#### vector<int> 示例

**Excel 输入**：
```
id,skills
1,"1,2,3"
2,"4,5,6"
```

**C++ 输出**：
```cpp
struct Item {
    int id;
    std::vector<int> skills;
};
```

**Java 输出**：
```java
public class Item {
    private int id;
    private int[] skills;

    public int[] getSkills() { return skills; }
    public void setSkills(int[] skills) { this.skills = skills; }
}
```

**Lua 输出**：
```lua
Item.data[1] = {
    id = 1,
    skills = {1, 2, 3}
}
```

#### Bean 示例

**Excel 输入**：
```
id,position.x,position.y
1,100,200
2,300,400
```

**Bean 定义**：
```xml
<bean name="Position">
    <col name="x" type="int" fromCol="position.x"/>
    <col name="y" type="int" fromCol="position.y"/>
</bean>
```

**C++ 输出**：
```cpp
struct Position {
    int x;
    int y;
};

struct Item {
    int id;
    Position position;
};
```

---

## 数据验证规则

### ID 验证

- **必须包含**：每个表必须包含 `id` 或 `ID` 列
- **唯一性**：ID 值必须唯一，不能重复
- **类型**：ID 必须是整数类型（int 或 long）
- **范围**：ID 必须大于等于 0

#### 代码实现

参见 [`DataManager.cs`](../DataManager.cs:102) 中的 `makeIdIndexs()` 方法：

```csharp
public bool makeIdIndexs(string idTitle)
{
    mIdIndex.Clear();
    int idCol;
    if (mTitleIndex.TryGetValue(idTitle, out idCol))
    {
        for (int i = 1; i < rowCount; i++)
        {
            int index = i * colCount + idCol;
            if (index < mData.Count())
            {
                string idString = mData[index];
                if (idString != "" && !MainWindow.IsInvalidName(idString))
                {
                    try
                    {
                        int id = Convert.ToInt32(mData[i * colCount + idCol]);
                        mIdIndex.Add(id, i);
                        MainWindow.mInstance.mIdIndex.Add(id, i);
                    }
                    catch (ArgumentException ae)
                    {
                        MainWindow.Error("表" + mFileName + "的中发现ID值" + idString + "有冲突，异常信息=" + ae.Message);
                        return false;
                    }
                    catch (FormatException fe)
                    {
                        MainWindow.Error("表" + mFileName + "的ID值" + idString + "不是一个合法的数字,异常信息=" + fe.Message);
                    }
                }
            }
        }
    }
    else
    {
        MainWindow.Error("生成表<" + mFileName + ">的ID索引失败，因为找不到标题<" + idTitle + ">");
        return false;
    }
    return true;
}
```

### 数据范围验证

#### minLimit/maxLimit 验证

Bean 定义可以指定数据的最小值和最大值：

```xml
<bean name="Item">
    <col name="level" type="int" min="1" max="100"/>
    <col name="exp" type="long" min="0"/>
</bean>
```

#### 验证规则

- **int 类型**：必须在 [min, max] 范围内
- **long 类型**：必须在 [min, max] 范围内
- **double 类型**：必须在 [min, max] 范围内
- **string 类型**：长度必须在 [min, max] 范围内
- **bool 类型**：不进行范围验证

### 数据类型验证

#### 类型转换验证

参见 [`MainWindow.xaml.cs`](../MainWindow.xaml.cs:468) 中的 `WriteBinData()` 方法：

```csharp
private bool WriteBinData(BinaryWriter bw, string type, string data)
{
    try
    {
        if (type == "int")
        {
            if (data.Length > 0)
            {
                int nPointPos = data.IndexOf(".");
                if (nPointPos != -1)
                {
                    data = data.Substring(0, nPointPos);
                }
                int intData = Convert.ToInt32(data);
                bw.Write(intData);
            }
            else
                bw.Write((int)0);
        }
        // ... 其他类型
    }
    catch (FormatException e)
    {
        Error("写二进制数据" + type + "=" + data + "时，发现数据格式错！异常信息=" + e.Message);
        return false;
    }
    return true;
}
```

---

## 参考资料

- [00-文档索引-Documentation-Index.md](00-文档索引-Documentation-Index.md) - 文档导航
- [06-Bean定义指南-Bean-Definition-Guide.md](06-Bean定义指南-Bean-Definition-Guide.md) - Bean 定义规范
- [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md) - 代码生成规则
- [08-二进制格式规范-Binary-Format-Specification.md](08-二进制格式规范-Binary-Format-Specification.md) - 二进制格式详解

---

**维护者**: 技术团队
**下次审查**: 2026-03-20
**许可证**: 内部使用

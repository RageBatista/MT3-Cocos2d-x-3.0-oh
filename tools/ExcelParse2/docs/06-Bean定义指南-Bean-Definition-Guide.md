# Bean 定义指南 (Bean Definition Guide)

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术团队

---

## 文档概述

本文档详细说明 Bean 定义的 XML 格式规范，包括 Bean 元素结构、Col 元素结构、定义示例和常见错误解决方案。

---

## 目录

1. [Bean 定义 XML 格式规范](#bean-定义-xml-格式规范)
2. [Bean 元素结构](#bean-元素结构)
3. [Col 元素结构](#col-元素结构)
4. [Bean 定义示例](#bean-定义示例)
5. [常见定义错误和解决方案](#常见定义错误和解决方案)
6. [高级特性](#高级特性)

---

## Bean 定义 XML 格式规范

### 文件结构

Bean 定义文件使用 XML 格式，文件扩展名为 `.xml`。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<namespace name="fire.pb">
    <bean name="Item" from="item.xlsx" genxml="client" gencode="mtlua" baseclass="" priority="0">
        <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
        <col name="name" fromCol="Name" type="string" min="" max="" data=""/>
        <col name="level" fromCol="Level" type="int" min="1" max="100" data=""/>
    </bean>
</namespace>
```

### 命名空间结构

Bean 定义支持多级命名空间：

```xml
<namespace name="fire">
    <namespace name="pb">
        <namespace name="item">
            <bean name="Item" ...>
                <!-- Bean 定义 -->
            </bean>
        </namespace>
    </namespace>
</namespace>
```

#### 代码实现

参见 [`DefineManager.cs`](../DefineManager.cs:150) 中的 `loadDefFromFile()` 方法：

```csharp
public bool loadDefFromFile(string xmlDefFileName)
{
    XmlDocument doc = new XmlDocument();
    doc.Load(xmlDefFileName);
    XmlNode xn = doc.SelectSingleNode("namespace");
    string spaceName = ((XmlElement)xn).GetAttribute("name");
    
    if (spaceName == "fire" && xn.ChildNodes.Count > 0)
    {
        xn = xn.ChildNodes[0];
        spaceName = ((XmlElement)xn).GetAttribute("name");
        if (spaceName == "pb" && xn.ChildNodes.Count > 0)
        {
            xn = xn.ChildNodes[0];
            spaceName = ((XmlElement)xn).GetAttribute("name");
        }
    }
    
    // ... 加载 Bean 定义
}
```

---

## Bean 元素结构

### 属性列表

| 属性名 | 类型 | 必填 | 默认值 | 说明 |
|-------|------|------|--------|------|
| name | string | 是 | - | Bean 名称（PascalCase） |
| from | string | 是 | - | 来源文件（逗号分隔多个文件） |
| genxml | string | 是 | - | 生成目标（server/client） |
| gencode | string | 否 | - | 代码生成方式（mtlua） |
| baseclass | string | 否 | - | 基类名称 |
| priority | string | 否 | "0" | 优先级（用于排序） |
| spaceName | string | 否 | - | 命名空间（自动从 XML 获取） |

### 属性详解

#### name

**说明**：Bean 名称，用于生成代码和文件名

**命名规则**：
- 使用 PascalCase（如 `Item`, `PlayerInfo`）
- 不能包含特殊字符
- 不能以数字开头

**示例**：
```xml
<bean name="Item" ...>
<bean name="PlayerInfo" ...>
```

#### from

**说明**：来源文件，支持多个文件（逗号分隔）

**格式**：
- 单个文件：`item.xlsx`
- 多个文件：`item1.xlsx,item2.xlsx,item3.xlsx`

**文件类型**：
- `.xlsx` - Excel 文件
- `.xlsm` - Excel 启用宏的文件
- `.csv` - CSV 文件
- `.txt` - TXT 文件（CSV 格式）

**示例**：
```xml
<bean name="Item" from="item.xlsx" ...>
<bean name="PlayerInfo" from="player1.xlsx,player2.xlsx" ...>
```

#### genxml

**说明**：生成目标，决定生成的数据类型

**可选值**：
- `server` - 生成服务器数据（XML + Java）
- `client` - 生成客户端数据（Bin + Xml + C++ + Lua + PKG）

**示例**：
```xml
<bean name="Item" genxml="client" ...>
<bean name="ServerConfig" genxml="server" ...>
```

#### gencode

**说明**：代码生成方式

**可选值**：
- `mtlua` - 生成 Lua 代码

**示例**：
```xml
<bean name="Item" gencode="mtlua" ...>
```

#### baseclass

**说明**：基类名称，用于继承

**使用场景**：
- 多个 Bean 共享相同字段时
- 需要统一接口时

**示例**：
```xml
<bean name="Item" baseclass="BaseItem" ...>
```

#### priority

**说明**：优先级，用于控制生成顺序

**使用场景**：
- 有依赖关系的 Bean 需要先生成基类
- 控制加载顺序

**示例**：
```xml
<bean name="BaseItem" priority="0" ...>
<bean name="Item" priority="1" ...>
```

#### spaceName

**说明**：命名空间，自动从 XML 获取

**生成规则**：
- 单级命名空间：`fire.pb`
- 多级命名空间：`fire.pb.item`

**示例**：
```xml
<namespace name="fire.pb">
    <bean name="Item" spaceName="fire.pb" ...>
```

---

## Col 元素结构

### 属性列表

| 属性名 | 类型 | 必填 | 默认值 | 说明 |
|-------|------|------|--------|------|
| name | string | 是 | - | 列名（camelCase） |
| fromCol | string | 是 | - | 来源列名（Excel 表头） |
| type | string | 是 | - | 数据类型 |
| value | string | 否 | - | 值类型（用于 vector） |
| min | string | 否 | - | 最小值限制 |
| max | string | 否 | - | 最大值限制 |
| data | string | 否 | - | 数据说明 |

### 属性详解

#### name

**说明**：列名，用于生成代码的成员变量名

**命名规则**：
- 使用 camelCase（如 `id`, `itemName`, `maxLevel`）
- 不能包含特殊字符
- 不能以数字开头

**示例**：
```xml
<col name="id" ...>
<col name="itemName" ...>
<col name="maxLevel" ...>
```

#### fromCol

**说明**：来源列名，对应 Excel 表头的列名

**格式**：
- 单列：`ID`
- 多列（用于 vector）：`col1,col2,col3`

**示例**：
```xml
<col name="id" fromCol="ID" ...>
<col name="skills" fromCol="skill1,skill2,skill3" type="vector<int>" value="int">
```

#### type

**说明**：数据类型

**可选值**：
- `bool` - 布尔值
- `int` - 整数
- `long` - 长整数
- `double` - 浮点数
- `string` - 字符串
- `vector<T>` - 数组（T 为元素类型）

**示例**：
```xml
<col name="id" type="int" ...>
<col name="name" type="string" ...>
<col name="skills" type="vector<int>" value="int" ...>
```

#### value

**说明**：值类型，用于 vector 类型的元素类型

**使用场景**：
- 当 type 为 `vector<T>` 时，指定 T 的类型

**示例**：
```xml
<col name="skills" type="vector<int>" value="int" ...>
<col name="positions" type="vector<double>" value="double" ...>
```

#### min

**说明**：最小值限制

**使用场景**：
- 限制数值范围
- 限制字符串长度

**示例**：
```xml
<col name="level" type="int" min="1" ...>
<col name="name" type="string" min="1" ...>
```

#### max

**说明**：最大值限制

**使用场景**：
- 限制数值范围
- 限制字符串长度

**示例**：
```xml
<col name="level" type="int" max="100" ...>
<col name="name" type="string" max="50" ...>
```

#### data

**说明**：数据说明，用于文档和注释

**示例**：
```xml
<col name="level" type="int" data="玩家等级" ...>
```

### 代码实现

参见 [`DefineManager.cs`](../DefineManager.cs:186) 中的 Col 解析代码：

```csharp
for (int i = 0; i < childXn.ChildNodes.Count; i++)
{
    nodeType = childXn.ChildNodes[i].GetType();
    if (nodeType.Name == "XmlElement")
    {
        BeanCol beanCol = new BeanCol();
        XmlElement xeEx = (XmlElement)childXn.ChildNodes[i];
        beanCol.name = xeEx.GetAttribute("name").ToString();
        beanCol.fromCol = xeEx.GetAttribute("fromCol").ToString();
        beanCol.type = xeEx.GetAttribute("type").ToString();
        beanCol.value = xeEx.GetAttribute("value").ToString();
        beanCol.minLimit = xeEx.GetAttribute("min").ToString();
        beanCol.maxLimit = xeEx.GetAttribute("max").ToString();
        beanDef.cols.Add(beanCol);
    }
}
```

---

## Bean 定义示例

### 示例 1：基础 Bean 定义

#### Excel 文件（item.xlsx）

| ID | Name | Level | Exp |
|----|------|-------|-----|
| 1 | "战士" | 1 | 100 |
| 2 | "法师" | 1 | 100 |

#### Bean 定义

```xml
<?xml version="1.0" encoding="UTF-8"?>
<namespace name="fire.pb">
    <bean name="Item" from="item.xlsx" genxml="client" gencode="mtlua" baseclass="" priority="0">
        <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
        <col name="name" fromCol="Name" type="string" min="" max="" data=""/>
        <col name="level" fromCol="Level" type="int" min="1" max="100" data=""/>
        <col name="exp" fromCol="Exp" type="long" min="0" max="" data=""/>
    </bean>
</namespace>
```

---

### 示例 2：包含数组的 Bean 定义

#### Excel 文件（player.xlsx）

| ID | Name | Skill1 | Skill2 | Skill3 |
|----|------|--------|--------|--------|
| 1 | "玩家1" | 1 | 2 | 3 |
| 2 | "玩家2" | 4 | 5 | 6 |

#### Bean 定义

```xml
<?xml version="1.0" encoding="UTF-8"?>
<namespace name="fire.pb">
    <bean name="Player" from="player.xlsx" genxml="client" gencode="mtlua" baseclass="" priority="0">
        <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
        <col name="name" fromCol="Name" type="string" min="" max="" data=""/>
        <col name="skills" fromCol="Skill1,Skill2,Skill3" type="vector<int>" value="int" min="" max="" data=""/>
    </bean>
</namespace>
```

---

### 示例 3：包含 Bean 的 Bean 定义

#### Excel 文件（monster.xlsx）

| ID | Name | PositionX | PositionY |
|----|------|-----------|-----------|
| 1 | "怪物1" | 100 | 200 |
| 2 | "怪物2" | 300 | 400 |

#### Bean 定义

```xml
<?xml version="1.0" encoding="UTF-8"?>
<namespace name="fire.pb">
    <!-- Position Bean 定义 -->
    <bean name="Position" from="" genxml="" baseclass="" priority="0">
        <col name="x" fromCol="" type="int" min="" max="" data=""/>
        <col name="y" fromCol="" type="int" min="" max="" data=""/>
    </bean>
    
    <!-- Monster Bean 定义 -->
    <bean name="Monster" from="monster.xlsx" genxml="client" gencode="mtlua" baseclass="" priority="0">
        <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
        <col name="name" fromCol="Name" type="string" min="" max="" data=""/>
        <col name="position" fromCol="PositionX,PositionY" type="Position" value="" min="" max="" data=""/>
    </bean>
</namespace>
```

---

### 示例 4：服务器端 Bean 定义

#### Excel 文件（config.xlsx）

| ID | Key | Value |
|----|-----|-------|
| 1 | "maxLevel" | "100" |
| 2 | "expRate" | "1.5" |

#### Bean 定义

```xml
<?xml version="1.0" encoding="UTF-8"?>
<namespace name="fire.pb">
    <bean name="ServerConfig" from="config.xlsx" genxml="server" baseclass="" priority="0">
        <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
        <col name="key" fromCol="Key" type="string" min="" max="" data=""/>
        <col name="value" fromCol="Value" type="string" min="" max="" data=""/>
    </bean>
</namespace>
```

---

### 示例 5：多文件 Bean 定义

#### Excel 文件
- `item1.xlsx` - 基础物品
- `item2.xlsx` - 扩展物品

#### Bean 定义

```xml
<?xml version="1.0" encoding="UTF-8"?>
<namespace name="fire.pb">
    <bean name="Item" from="item1.xlsx,item2.xlsx" genxml="client" gencode="mtlua" baseclass="" priority="0">
        <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
        <col name="name" fromCol="Name" type="string" min="" max="" data=""/>
        <col name="level" fromCol="Level" type="int" min="1" max="100" data=""/>
        <col name="exp" fromCol="Exp" type="long" min="0" max="" data=""/>
    </bean>
</namespace>
```

---

## 常见定义错误和解决方案

### 错误 1：列名重复

**错误信息**：
```
表item.xlsx的表头中有同名的列，列名是ID！
```

**原因**：Excel 表头中有重复的列名

**解决方案**：
- 检查 Excel 表头，确保列名唯一
- 修改重复的列名

**代码位置**：
[`DataManager.cs`](../DataManager.cs:73) 中的 `makeTitleIndexs()` 方法

---

### 错误 2：ID 冲突

**错误信息**：
```
表item.xlsx的中发现ID值1有冲突，异常信息=...
```

**原因**：Excel 中有重复的 ID 值

**解决方案**：
- 检查 Excel 数据，确保 ID 唯一
- 修改重复的 ID 值

**代码位置**：
[`DataManager.cs`](../DataManager.cs:122) 中的 `makeIdIndexs()` 方法

---

### 错误 3：找不到列

**错误信息**：
```
获取文件<item.xlsx>的标题<Name>失败
```

**原因**：Bean 定义的 `fromCol` 属性指定的列名在 Excel 中不存在

**解决方案**：
- 检查 Bean 定义的 `fromCol` 属性
- 确保列名与 Excel 表头一致（区分大小写）

**代码位置**：
[`DataManager.cs`](../DataManager.cs:52) 中的 `GetXlsData()` 方法

---

### 错误 4：找不到 ID 列

**错误信息**：
```
生成表<item.xlsx>的ID索引失败，因为找不到标题<ID>
```

**原因**：Excel 中没有名为 `id` 或 `ID` 的列

**解决方案**：
- 在 Excel 中添加 `id` 或 `ID` 列
- 确保列名正确（区分大小写）

**代码位置**：
[`DataManager.cs`](../DataManager.cs:136) 中的 `makeIdIndexs()` 方法

---

### 错误 5：数据类型转换失败

**错误信息**：
```
写二进制数据int=abc时，发现数据格式错！异常信息=...
```

**原因**：Excel 中的数据与 Bean 定义的类型不匹配

**解决方案**：
- 检查 Excel 数据格式
- 确保数据类型与 Bean 定义一致

**代码位置**：
[`MainWindow.xaml.cs`](../MainWindow.xaml.cs:530) 中的 `WriteBinData()` 方法

---

### 错误 6：Bean 数组列数不一致

**错误信息**：
```
bean(Monster)定义Position错误！Bean数组对象的列数不一致!
```

**原因**：Bean 数组的列数不一致

**解决方案**：
- 检查 Excel 数据，确保 Bean 数组的列数一致
- 修改 Bean 定义的 `fromCol` 属性

**代码位置**：
[`ServerBeanNode.cs`](../ServerBeanNode.cs:137) 中的 `SetupDef()` 方法

---

### 错误 7：无法识别的类型

**错误信息**：
```
无法识别的bean(Monster) type=unknown!
```

**原因**：Bean 定义的 `type` 属性值不正确

**解决方案**：
- 检查 Bean 定义的 `type` 属性
- 确保类型值正确（bool, int, long, double, string, vector<T>, Bean）

**代码位置**：
[`ServerBeanNode.cs`](../ServerBeanNode.cs:157) 中的 `SetupDef()` 方法

---

## 高级特性

### 列校验和检测

Bean 定义支持列校验和检测，用于检测结构变更。

#### 校验和计算

参见 [`DefineManager.cs`](../DefineManager.cs:65) 中的 `GetColCheckNumber()` 方法：

```csharp
public uint GetColCheckNumber()
{
    uint colVersion = 0;
    uint allColCount = 0;
    for (int i = 0; i < cols.Count; i++)
    {
        for (int j = 0; j < cols[i].subCols.Count; j++)
        {
            string type = cols[i].type;
            if (cols[i].type == "vector")
                type = cols[i].value;

            if (type == "bool")
                colVersion += 1;
            else if (type == "int")
                colVersion += 2;
            else if (cols[i].type == "long")
                colVersion += 3;
            else if (type == "double")
                colVersion += 4;
            else if (type == "string" || type == "String")
                colVersion += 5;
            colVersion += allColCount;
            ++allColCount;
        }
    }
    colVersion += allColCount * 0x10000;
    return colVersion;
}
```

#### 使用场景

- 检测 Bean 结构变更
- 验证二进制文件兼容性
- 自动化测试

---

### Bean 继承

Bean 定义支持继承，用于共享字段。

#### 基类定义

```xml
<bean name="BaseItem" from="" genxml="" baseclass="" priority="0">
    <col name="id" fromCol="" type="int" min="" max="" data=""/>
    <col name="name" fromCol="" type="string" min="" max="" data=""/>
</bean>
```

#### 子类定义

```xml
<bean name="Item" from="item.xlsx" genxml="client" baseclass="BaseItem" priority="0">
    <col name="level" fromCol="Level" type="int" min="1" max="100" data=""/>
    <col name="exp" fromCol="Exp" type="long" min="0" max="" data=""/>
</bean>
```

#### 代码实现

参见 [`ServerBeanNode.cs`](../ServerBeanNode.cs:74) 中的基类处理代码：

```csharp
if (mBeanDef.baseClass.Length > 0)
{
    mBaseClassNode = new ServerBeanNode();
    mBaseClassNode.mParentNode = this;
    if (!mBaseClassNode.SetupDef("baseClass", mBeanDef.baseClass, "", ""))
    {
        return false;
    }
}
```

---

### Bean 数组

Bean 定义支持数组类型，用于存储多个 Bean。

#### 数组定义

```xml
<bean name="Position" from="" genxml="" baseclass="" priority="0">
    <col name="x" fromCol="" type="int" min="" max="" data=""/>
    <col name="y" fromCol="" type="int" min="" max="" data=""/>
</bean>

<bean name="Path" from="path.xlsx" genxml="client" baseclass="" priority="0">
    <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
    <col name="positions" fromCol="X1,Y1,X2,Y2" type="vector<Position>" value="Position" min="" max="" data=""/>
</bean>
```

#### Excel 数据

| ID | X1 | Y1 | X2 | Y2 |
|----|----|----|----|----|
| 1 | 100 | 200 | 300 | 400 |
| 2 | 500 | 600 | 700 | 800 |

---

### Bean 引用

Bean 定义支持引用其他 Bean。

#### 引用定义

```xml
<bean name="Item" from="item.xlsx" genxml="client" baseclass="" priority="0">
    <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
    <col name="name" fromCol="Name" type="string" min="" max="" data=""/>
</bean>

<bean name="Player" from="player.xlsx" genxml="client" baseclass="" priority="0">
    <col name="id" fromCol="ID" type="int" min="" max="" data=""/>
    <col name="name" fromCol="Name" type="string" min="" max="" data=""/>
    <col name="itemId" fromCol="ItemId" type="int" min="" max="" data=""/>
</bean>
```

---

## 参考资料

- [00-文档索引-Documentation-Index.md](00-文档索引-Documentation-Index.md) - 文档导航
- [05-数据格式规范-Data-Format-Specification.md](05-数据格式规范-Data-Format-Specification.md) - 数据格式规范
- [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md) - 代码生成规则
- [DefineManager.cs](../DefineManager.cs) - Bean 定义管理器
- [ServerBeanNode.cs](../ServerBeanNode.cs) - 服务器 Bean 节点

---

**维护者**: 技术团队
**下次审查**: 2026-03-20
**许可证**: 内部使用

# convxml - 基于 Freemarker 的 XML 到 Java 代码生成器

## 1. 工具概述

### 1.1 用途说明
convxml 是一个基于 Freemarker 模板引擎的代码生成工具，主要用于将游戏策划配置的 XML 文件转换为 Java Bean 类和转换入口类。它是 MT3 游戏配置系统的重要组成部分。

**核心功能**：
- **XML → Java Bean**：从 XML 定义自动生成 Java 数据结构类
- **模板驱动**：基于 Freemarker 模板，灵活可扩展
- **类型安全**：自动生成带类型检查的 getter/setter
- **多文件支持**：支持从多个 Excel 表格文件加载配置数据
- **服务端/客户端分离**：支持为服务端和客户端生成不同的代码

**解决的问题**：
- 游戏策划的 XML 配置需要转换为程序可用的 Java 类
- 避免手工编写大量重复的 Bean 类代码
- 确保配置数据结构的类型安全和数据验证
- 统一管理配置数据的加载和访问入口

**典型使用场景**：
- 游戏配置表（怪物、技能、道具等）的数据结构生成
- 游戏策划 XML 配置文件到程序代码的自动转换
- 服务端和客户端共享配置数据结构的生成
- 配置数据的批量加载和访问框架生成

### 1.2 关键特性
- **Freemarker 模板引擎**：使用成熟的模板技术，易于定制
- **XInclude 支持**：支持 XML 模块化和复用
- **命名空间感知**：正确处理 XML 命名空间
- **类型丰富**：支持 string, int, long, double, float, bool, vector, set 等类型
- **数据验证**：支持 min/max 值范围验证
- **列映射**：支持 fromCol/prefix 属性，灵活映射 Excel 列
- **引用关系**：支持 ref 属性，定义 Bean 间的引用关系
- **UTF-8 输出**：生成的 Java 文件使用 UTF-8 编码
- **Log4j 日志**：完整的日志跟踪，便于调试

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
convxml 位于 MT3 配置管理系统的**代码生成层**：

```
┌─────────────────────────────────────────────────────────────┐
│         游戏逻辑层（Game Logic Layer）                       │
│  使用生成的 Bean 类加载配置数据                              │
└────────────────┬────────────────────────────────────────────┘
                 │ 使用 ConvMain.java 加载配置
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              convxml 代码生成器                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   XML 配置定义                                       │   │
│  │   <bean name="Monster" from="monster.xls">         │   │
│  │     <variable name="id" type="int"/>               │   │
│  │     <variable name="name" type="string"/>          │   │
│  │   </bean>                                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                 │                                            │
│                 ↓ convxml.jar 处理                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   生成的 Java 代码                                   │   │
│  │   public class Monster {                           │   │
│  │     private int id;                                │   │
│  │     private String name;                           │   │
│  │     public int getId() { return id; }             │   │
│  │     public void setId(int id) { this.id = id; }  │   │
│  │   }                                                │   │
│  │   ConvMain.java (加载入口)                          │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────┬────────────────────────────────────────────┘
                 │ 依赖
                 ↓
┌─────────────────────────────────────────────────────────────┐
│       外部依赖（Freemarker, Log4j, DOM Parser）              │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **被依赖模块**：
  - 游戏配置系统 - 使用生成的 Bean 类
  - Excel 数据导入工具 - 读取 Excel 表格填充 Bean 数据
  - 配置验证工具 - 验证配置数据的合法性

- **依赖模块**：
  - `freemarker.jar` - 模板引擎
  - `log4j.jar` - 日志框架
  - JDK DOM Parser - XML 解析

- **数据流**：
  - 编译时：XML 定义 + Freemarker 模板 → 生成 Java Bean 类
  - 运行时：Bean 类 + Excel 数据 → ConvMain 加载 → 游戏逻辑使用

### 2.3 关键代码位置

| 功能模块 | 文件路径 | 关键类/方法 |
|---------|---------|------------|
| 程序入口 | [src/mytools/Main.java](src/mytools/Main.java#L48-L131) | `Main.main()` |
| Freemarker 初始化 | [src/mytools/Main.java](src/mytools/Main.java#L35-L46) | `initFreeMarker()` |
| XML 解析 | [src/mytools/Main.java](src/mytools/Main.java#L65-L76) | DOM Parser 配置 |
| Bean 遍历 | [src/mytools/Main.java](src/mytools/Main.java#L103-L117) | Bean 节点遍历循环 |
| Java 文件生成 | [src/mytools/Main.java](src/mytools/Main.java#L338-L533) | `writeJavaFile()` |
| ConvMain 生成 | [src/mytools/Main.java](src/mytools/Main.java#L118-L129) | main.ftl 模板处理 |
| 类名工具 | [src/mytools/ClassNameUtil.java](src/mytools/ClassNameUtil.java) | 命名空间和类名转换 |
| 变量信息 | [src/mytools/Main.java](src/mytools/Main.java#L535-L594) | `VarInfo` 内部类 |
| 类型验证 | [src/mytools/Main.java](src/mytools/Main.java#L133-L167) | `isInt()`, `isFloat()` 等 |
| 日志配置 | [log4j.xml](log4j.xml) | Log4j 配置文件 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**：JDK/JRE 1.6 及以上
- **必需库文件**：
  - `freemarker.jar` - Freemarker 模板引擎
  - `log4j.jar` - Log4j 日志框架
  - `dom4j.jar` 或 JDK 自带的 DOM Parser

### 3.2 构建时依赖
由于项目未提供 build.xml，需要手动构建或参考以下步骤：

```bash
# 假设的构建命令
javac -encoding GBK -cp lib/freemarker.jar:lib/log4j.jar \
      -d classes src/mytools/*.java

jar cvf convxml.jar -C classes .
```

### 3.3 构建步骤

#### 手动构建
```bash
# 1. 创建输出目录
mkdir -p classes

# 2. 编译 Java 源代码（注意 GBK 编码）
javac -encoding GBK \
      -cp lib/freemarker.jar:lib/log4j.jar \
      -d classes \
      src/mytools/*.java

# 3. 打包为 JAR 文件
jar cvf convxml.jar -C classes .

# 4. 将 log4j.xml 复制到工作目录
cp log4j.xml .
```

#### Windows 批处理脚本示例
```batch
@echo off
mkdir classes 2>nul
javac -encoding GBK -cp lib\freemarker.jar;lib\log4j.jar -d classes src\mytools\*.java
jar cvf convxml.jar -C classes .
echo Build completed.
```

### 3.4 模板文件准备

convxml 依赖 Freemarker 模板文件，需要准备：

**bean.ftl** - Bean 类生成模板：
```ftl
package ${namespace};

<#if baseclass?has_content>
import ${baseclass};
</#if>

public class ${classname} <#if baseclass?has_content>extends ${baseclass}</#if> {
    <#list varList as var>
    // ${var.comment}
    private ${var.type} ${var.name} = ${var.initValue};
    </#list>

    <#list varList as var>
    public ${var.type} get${var.name?cap_first}() {
        return ${var.name};
    }

    public void set${var.name?cap_first}(${var.type} ${var.name}) {
        this.${var.name} = ${var.name};
    }
    </#list>
}
```

**main.ftl** - ConvMain 入口类生成模板：
```ftl
package mytools;

public class ConvMain {
    public static void main(String[] args) {
        <#if !defineOnly>
        // 加载服务端配置
        <#list serverClassList as cls>
        load${cls}();
        </#list>
        </#if>
    }

    <#if !defineOnly>
    <#list serverClassList as cls>
    private static void load${cls}() {
        // 实现配置加载逻辑
    }
    </#list>
    </#if>
}
```

---

## 4. 配置与使用

### 4.1 XML 配置文件格式

#### 基本结构
```xml
<?xml version="1.0" encoding="UTF-8"?>
<config xmlns:xi="http://www.w3.org/2001/XInclude">
  <!-- 服务端配置 Bean -->
  <bean name="com.game.config.Monster" from="monster.xls" genxml="server">
    <variable name="id" type="int" fromCol="A">怪物ID</variable>
    <variable name="name" type="string" fromCol="B">怪物名称</variable>
    <variable name="level" type="int" fromCol="C" min="1" max="100">等级</variable>
    <variable name="hp" type="long" fromCol="D">生命值</variable>
    <variable name="skills" type="vector" value="int" fromCol="E,F,G">技能列表</variable>
  </bean>

  <!-- 客户端配置 Bean -->
  <bean name="com.game.config.Item" from="item.xls" genxml="client">
    <variable name="itemId" type="int" fromCol="A">道具ID</variable>
    <variable name="itemName" type="string" fromCol="B">道具名称</variable>
    <variable name="price" type="int" fromCol="C">价格</variable>
  </bean>

  <!-- 公共 Bean（不从文件加载） -->
  <bean name="com.game.config.Attribute" baseclass="BaseConfig">
    <variable name="attrType" type="int">属性类型</variable>
    <variable name="attrValue" type="double">属性值</variable>
  </bean>

  <!-- 使用 XInclude 引入其他配置 -->
  <xi:include href="skills.xml"/>
</config>
```

#### Bean 属性说明

| 属性 | 说明 | 示例值 | 必需 |
|-----|------|--------|-----|
| `name` | Bean 的完全限定类名 | `com.game.config.Monster` | ✅ |
| `from` | 数据来源的 Excel 文件名（逗号分隔多文件） | `monster.xls,monster2.xls` | ⚠️ 非 pbean 必需 |
| `genxml` | 生成目标（server/client） | `server` 或 `client` | ❌ |
| `baseclass` | 父类的完全限定名 | `com.game.BaseConfig` | ❌ |

#### Variable 属性说明

| 属性 | 说明 | 示例值 | 必需 |
|-----|------|--------|-----|
| `name` | 变量名 | `monsterId` | ✅ |
| `type` | 数据类型 | `int/long/string/bool/float/double/vector/set` | ✅ |
| `fromCol` | Excel 列映射 | `A` 或 `A,B,C` 或 `prefix1:A,B\|prefix2:C,D` | ⚠️ 从文件加载时必需 |
| `prefix` | 列前缀（非从文件加载时） | `attr1,attr2` | ❌ |
| `min` | 最小值（用于验证） | `1` | ❌ |
| `max` | 最大值（用于验证） | `100` | ❌ |
| `ref` | 引用其他 Bean | `com.game.config.Skill` | ❌ |
| `value` | 集合元素类型（vector/set） | `int` 或 `String` 或自定义 Bean | ⚠️ vector/set 必需 |

#### 支持的数据类型

| 类型 | Java 类型 | 默认值 | 示例 |
|-----|----------|--------|------|
| `int` | `int` | `0` | `<variable name="level" type="int"/>` |
| `long` | `long` | `0L` | `<variable name="exp" type="long"/>` |
| `string` | `String` | `null` | `<variable name="name" type="string"/>` |
| `double` | `double` | `0.0` | `<variable name="rate" type="double"/>` |
| `float` | `float` | `0.0f` | `<variable name="speed" type="float"/>` |
| `bool` | `boolean` | `false` | `<variable name="isActive" type="bool"/>` |
| `vector` | `ArrayList<T>` | `new ArrayList<>()` | `<variable name="items" type="vector" value="int"/>` |
| `set` | `TreeSet<T>` | `new TreeSet<>()` | `<variable name="tags" type="set" value="String"/>` |

#### fromCol 高级映射

支持复杂的列映射语法：

```xml
<!-- 简单列映射 -->
<variable name="name" type="string" fromCol="B"/>

<!-- 多列映射（用于 vector/set） -->
<variable name="skills" type="vector" value="int" fromCol="E,F,G"/>

<!-- 带前缀的映射（根据前缀选择不同列） -->
<variable name="attrs" type="vector" value="int"
          fromCol="normal:A,B,C|elite:D,E,F|boss:G,H,I"/>
```

### 4.2 命令行使用

#### 基本语法
```bash
java -jar convxml.jar <xml> <outDir> <templatesDir> [defineOnly]
```

#### 参数说明
- `<xml>`：输入的 XML 配置文件路径
- `<outDir>`：生成 Java 文件的输出目录
- `<templatesDir>`：Freemarker 模板文件所在目录
- `[defineOnly]`：可选参数，如果指定任意第4个参数，则只生成 Bean 定义，不生成加载逻辑

#### 使用示例

**示例 1：生成完整代码（包含加载逻辑）**
```bash
java -jar convxml.jar config.xml src/gen templates
```
- 读取 `config.xml` 定义
- 在 `src/gen/` 目录生成 Bean 类
- 使用 `templates/` 目录的模板
- 生成 `src/gen/mytools/ConvMain.java` 入口类

**示例 2：仅生成 Bean 定义（不生成加载逻辑）**
```bash
java -jar convxml.jar config.xml src/gen templates defineOnly
```
- 第4个参数 `defineOnly` 可以是任意值
- 只生成 Bean 类，不生成 `ConvMain.java` 的加载方法

**示例 3：使用相对路径**
```bash
cd /path/to/project
java -jar ../tools/convxml.jar \
     config/monsters.xml \
     src/main/java \
     templates
```

**示例 4：Windows 批处理脚本**
```batch
@echo off
set XML_FILE=config\game.xml
set OUT_DIR=src\gen
set TEMPLATE_DIR=templates

java -jar convxml.jar %XML_FILE% %OUT_DIR% %TEMPLATE_DIR%
if errorlevel 1 (
    echo Code generation failed!
    exit /b 1
)
echo Code generation successful!
```

**示例 5：Linux Shell 脚本**
```bash
#!/bin/bash
XML_FILE="config/game.xml"
OUT_DIR="src/gen"
TEMPLATE_DIR="templates"

java -jar convxml.jar "$XML_FILE" "$OUT_DIR" "$TEMPLATE_DIR"
if [ $? -ne 0 ]; then
    echo "Code generation failed!"
    exit 1
fi
echo "Code generation successful!"
```

### 4.3 生成的代码结构

```
src/gen/
├── com/
│   └── game/
│       └── config/
│           ├── Monster.java          # 怪物配置 Bean
│           ├── Item.java             # 道具配置 Bean
│           ├── Skill.java            # 技能配置 Bean
│           └── Attribute.java        # 属性配置 Bean
└── mytools/
    └── ConvMain.java                 # 配置加载入口类
```

**生成的 Bean 类示例**（Monster.java）：
```java
package com.game.config;

public class Monster {
    // 怪物ID
    private int id = 0;
    // 怪物名称
    private String name = null;
    // 等级
    private int level = 0;
    // 生命值
    private long hp = 0L;
    // 技能列表
    private java.util.ArrayList<Integer> skills = new java.util.ArrayList<Integer>();

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // ... 其他 getter/setter ...
}
```

**生成的 ConvMain 类示例**：
```java
package mytools;

public class ConvMain {
    public static void main(String[] args) {
        // 加载服务端配置
        loadMonster();
        loadItem();
    }

    private static void loadMonster() {
        // 从 monster.xls 加载数据
    }

    private static void loadItem() {
        // 从 item.xls 加载数据
    }
}
```

### 4.4 日志配置

convxml 使用 Log4j 记录日志，需要在工作目录放置 `log4j.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
  <appender name="CONSOLE" class="org.apache.log4j.ConsoleAppender">
    <layout class="org.apache.log4j.PatternLayout">
      <param name="ConversionPattern" value="%d [%t] %-5p %c - %m%n"/>
    </layout>
  </appender>

  <root>
    <priority value="INFO"/>
    <appender-ref ref="CONSOLE"/>
  </root>
</log4j:configuration>
```

**日志输出示例**：
```
2025-11-27 10:30:15 [main] INFO  mytools.Main - writing com.game.config.Monster
2025-11-27 10:30:15 [main] INFO  mytools.Main - writing com.game.config.Item
2025-11-27 10:30:16 [main] ERROR mytools.Main - java文件生成成功
```

---

## 5. 输入输出规范

### 5.1 输入格式

#### XML 配置文件要求
- **编码**：UTF-8（推荐）或其他标准编码
- **格式**：符合 XML 1.0 规范
- **根元素**：任意（通常使用 `<config>` 或 `<beans>`）
- **Bean 元素**：`<bean>` 标签定义每个配置类
- **XInclude 支持**：可以使用 `<xi:include>` 引入其他 XML 文件

#### 模板文件要求
- **位置**：由命令行参数 `<templatesDir>` 指定的目录
- **必需模板**：
  - `bean.ftl` - Bean 类生成模板
  - `main.ftl` - ConvMain 类生成模板
- **编码**：UTF-8
- **语法**：Freemarker 模板语言（FTL）

### 5.2 输出格式

#### Java 文件输出
- **编码**：UTF-8（硬编码，见 `Main.java:121,524`）
- **包结构**：根据 Bean 的 `name` 属性自动生成
- **文件位置**：`<outDir>/<package_path>/<ClassName>.java`

**示例**：
```
Bean name: com.game.config.Monster
输出文件: src/gen/com/game/config/Monster.java
```

#### ConvMain 入口类
- **固定路径**：`<outDir>/mytools/ConvMain.java`
- **包名**：固定为 `mytools`
- **功能**：
  - 定义 `serverClassList` 和 `clientClassList`
  - 为每个服务端 Bean 生成 `loadXxx()` 方法框架

### 5.3 错误处理

| 错误类型 | 场景 | 处理方式 |
|---------|------|---------|
| 参数不足 | 命令行参数 < 3 | 静默返回（不打印帮助） |
| XML 解析失败 | XML 格式错误 | 记录错误日志并返回 |
| 模板目录不存在 | Freemarker 初始化失败 | 记录错误日志并返回 `null` |
| Bean 元素未找到 | XPath 查询失败 | 记录错误日志并返回 |
| 类型不支持 | 未知的 `type` 属性 | 抛出 `RuntimeException` |
| fromCol 格式错误 | 映射语法错误 | 抛出 `RuntimeException` |
| 模板处理失败 | Freemarker 模板错误 | 记录错误日志并返回 |

**错误日志示例**：
```
ERROR mytools.Main - parse doc fail
java.xml.sax.SAXParseException: Premature end of file
    at com.sun.org.apache.xerces.internal.parsers.DOMParser.parse(...)
    ...

ERROR mytools.Main - 无法识别的类型,type=unknown
java.lang.RuntimeException: 无法识别的类型,type=unknown
    at mytools.Main.writeJavaFile(Main.java:505)
    ...
```

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制
- **源代码编码**：Java 源代码使用 GBK 编码（见注释），但生成的文件强制为 UTF-8
- **参数校验不足**：命令行参数不足时静默返回，没有使用提示
- **无帮助信息**：没有 `-h` 或 `--help` 选项
- **错误处理简单**：大部分错误仅记录日志，不提供详细的错误信息
- **模板固定**：模板文件名硬编码为 `bean.ftl` 和 `main.ftl`
- **包名限制**：ConvMain 固定生成在 `mytools` 包

#### 设计限制
- **不支持嵌套 Bean**：不能在 Bean 内部定义子 Bean
- **不支持继承链验证**：`baseclass` 属性不检查父类是否存在
- **Excel 加载未实现**：生成的 `loadXxx()` 方法是空框架，需要手动实现
- **公共 Bean 功能被注释**：`savePublicBean()` 方法被注释掉（`Main.java:169-336`）

### 6.2 性能考虑

#### 影响性能的因素
- **XML 文件大小**：大型 XML 文件（> 10MB）解析较慢
- **Bean 数量**：Bean 数量过多（> 1000 个）会增加生成时间
- **模板复杂度**：复杂的 Freemarker 模板会降低生成速度
- **文件 I/O**：频繁的文件创建和写入操作

#### 性能优化建议
```yaml
# 1. 分割大型 XML 文件
good_practice:
  - "使用 XInclude 将配置分散到多个文件"
  - "按模块或功能组织 Bean 定义"

# 2. 批量生成
optimization:
  - "一次运行生成所有 Bean，避免多次调用"
  - "使用构建脚本自动化生成过程"

# 3. 模板优化
template_tips:
  - "避免复杂的 Freemarker 逻辑"
  - "使用简单的变量替换和循环"
```

### 6.3 安全注意事项

#### 代码注入风险
```yaml
risk: "XML 中的类名和包名直接用于生成 Java 代码"
mitigation:
  - "确保 XML 配置文件来源可信"
  - "不要使用用户输入的 XML 文件"
  - "验证生成的 Java 文件内容"

example_attack:
  malicious_xml: |
    <bean name="com.game.Hack; System.exit(0); //Comment">
      ...
    </bean>
  result: "可能生成包含恶意代码的 Java 文件"
```

#### 路径遍历风险
```yaml
risk: "输出目录由用户指定，可能导致文件覆盖"
mitigation:
  - "验证输出目录路径的合法性"
  - "使用绝对路径或相对于项目根目录的路径"
  - "避免使用 ../ 等相对路径符号"
```

#### 模板注入风险
```yaml
risk: "Freemarker 模板如果包含用户输入，可能执行任意代码"
mitigation:
  - "模板文件应由开发团队维护"
  - "不要使用用户上传的模板文件"
  - "定期审查模板内容"
```

### 6.4 故障排查指南

#### 问题 1：生成失败 - "parse doc fail"
**症状**：
```
ERROR mytools.Main - parse doc fail
org.xml.sax.SAXParseException: Element type "bean" must be followed by either attribute specifications, ">" or "/>"
```

**可能原因**：
- XML 文件格式错误
- 未闭合的标签
- 属性值未用引号括起

**解决方案**：
```bash
# 1. 使用 XML 验证工具检查
xmllint --noout config.xml

# 2. 检查 XML 编码
file -i config.xml

# 3. 检查特殊字符
grep -n '[^[:print:][:space:]]' config.xml
```

#### 问题 2：生成文件编码错误
**症状**：
生成的 Java 文件包含乱码，编译失败

**可能原因**：
- XML 文件编码与声明不符
- log4j.xml 编码错误

**解决方案**：
```bash
# 确保 XML 文件使用 UTF-8 编码
iconv -f GBK -t UTF-8 config.xml > config_utf8.xml

# 检查 Java 文件编码
file -i src/gen/com/game/config/Monster.java
# 输出应为：text/x-java; charset=utf-8
```

#### 问题 3：模板未找到
**症状**：
```
ERROR mytools.Main - err
freemarker.template.TemplateNotFoundException: Template not found for name "bean.ftl"
```

**解决方案**：
```bash
# 1. 检查模板目录路径
ls -la templates/
# 应包含 bean.ftl 和 main.ftl

# 2. 检查模板文件权限
chmod 644 templates/*.ftl

# 3. 使用绝对路径
java -jar convxml.jar config.xml src/gen /absolute/path/to/templates
```

#### 问题 4：生成的 Java 文件编译失败
**症状**：
```
error: cannot find symbol
  symbol:   class BaseConfig
  location: class Monster
```

**可能原因**：
- `baseclass` 属性指定的父类不存在
- 包名路径不正确
- 依赖的类未生成

**解决方案**：
```bash
# 1. 检查父类是否存在
find src/gen -name "BaseConfig.java"

# 2. 确保按依赖顺序生成
# 先生成基类，再生成子类

# 3. 检查生成的包结构
tree src/gen
```

#### 问题 5：命令行参数错误
**症状**：
程序静默返回，没有任何输出

**可能原因**：
- 参数数量少于 3 个
- 参数顺序错误

**解决方案**：
```bash
# 正确的参数顺序
java -jar convxml.jar <xml文件> <输出目录> <模板目录> [defineOnly]

# 错误示例（参数顺序错误）
java -jar convxml.jar templates src/gen config.xml  # ❌

# 正确示例
java -jar convxml.jar config.xml src/gen templates  # ✅
```

#### 问题 6：内存溢出
**症状**：
```
java.lang.OutOfMemoryError: Java heap space
```

**可能原因**：
- XML 文件过大
- Bean 数量过多
- 内存配置不足

**解决方案**：
```bash
# 增加 JVM 堆内存
java -Xms512m -Xmx2g -jar convxml.jar config.xml src/gen templates

# 分割大型 XML 文件
# 将单个大文件拆分为多个小文件，使用 XInclude 引入
```

---

## 7. 扩展与改进

### 7.1 推荐改进方向

#### 短期优化（1-2 周）
1. **增强错误提示**：
   - 添加命令行参数使用帮助（`-h`, `--help`）
   - 改进错误日志，提供更详细的上下文信息
   - 添加参数验证，检查文件和目录是否存在

2. **支持自定义模板**：
   - 支持通过命令行参数指定模板文件名
   - 支持多种代码生成目标（C++, Python, TypeScript 等）

3. **增强类型系统**：
   - 支持更多 Java 类型（BigDecimal, LocalDate 等）
   - 支持 Map 类型
   - 支持枚举类型

#### 中期优化（1-2 个月）
4. **实现 Excel 加载**：
   - 实现 `loadXxx()` 方法，从 Excel 读取数据
   - 支持多种 Excel 格式（.xls, .xlsx）
   - 支持数据验证（min/max, ref 引用检查）

5. **配置验证工具**：
   - XML Schema 定义和验证
   - Bean 引用完整性检查
   - Excel 表格结构验证

6. **增量生成**：
   - 检测 XML 文件变更，只重新生成修改的 Bean
   - 提高构建速度

#### 长期优化（3-6 个月）
7. **可视化配置编辑器**：
   - GUI 工具，可视化编辑 Bean 定义
   - 所见即所得的配置管理

8. **代码质量提升**：
   - 重构 `Main.java`（过长，超过 500 行）
   - 提取接口和抽象类
   - 增加单元测试

9. **多语言支持**：
   - 支持生成 C++, Python, Go 等语言的代码
   - 提供语言适配器接口

10. **与 IDE 集成**：
    - IntelliJ IDEA 插件
    - Eclipse 插件
    - VS Code 扩展

### 7.2 扩展示例

#### 自定义模板 - 生成带验证的 Bean

**enhanced-bean.ftl**：
```ftl
package ${namespace};

<#if baseclass?has_content>
import ${baseclass};
</#if>

public class ${classname} <#if baseclass?has_content>extends ${baseclass}</#if> {
    <#list varList as var>
    // ${var.comment}
    private ${var.type} ${var.name} = ${var.initValue};
    </#list>

    <#list varList as var>
    public ${var.type} get${var.name?cap_first}() {
        return ${var.name};
    }

    public void set${var.name?cap_first}(${var.type} ${var.name}) {
        <#if var.minValue?has_content || var.maxValue?has_content>
        // 验证范围
        <#if var.minValue?has_content>
        if (${var.name} < ${var.minValue}) {
            throw new IllegalArgumentException("${var.name} must be >= ${var.minValue}");
        }
        </#if>
        <#if var.maxValue?has_content>
        if (${var.name} > ${var.maxValue}) {
            throw new IllegalArgumentException("${var.name} must be <= ${var.maxValue}");
        }
        </#if>
        </#if>
        this.${var.name} = ${var.name};
    }
    </#list>

    // 验证方法
    public boolean validate() {
        <#list varList as var>
        <#if var.ref?has_content>
        // 验证引用: ${var.name} -> ${var.ref}
        // TODO: 实现引用验证逻辑
        </#if>
        </#list>
        return true;
    }
}
```

#### 自定义工具类 - Bean 工厂

```java
package mytools;

import java.util.HashMap;
import java.util.Map;

public class BeanFactory {
    private static final Map<String, Class<?>> beanRegistry = new HashMap<>();

    static {
        // 注册所有 Bean 类
        registerBean("Monster", com.game.config.Monster.class);
        registerBean("Item", com.game.config.Item.class);
        // ... 其他 Bean
    }

    public static void registerBean(String name, Class<?> clazz) {
        beanRegistry.put(name, clazz);
    }

    public static <T> T createBean(String name) {
        Class<?> clazz = beanRegistry.get(name);
        if (clazz == null) {
            throw new IllegalArgumentException("Unknown bean: " + name);
        }
        try {
            return (T) clazz.newInstance();
        } catch (Exception e) {
            throw new RuntimeException("Failed to create bean: " + name, e);
        }
    }
}
```

---

## 8. 快速参考

### 8.1 常用命令速查表

```bash
# 基本生成
java -jar convxml.jar config.xml src/gen templates

# 仅生成 Bean 定义（不生成加载逻辑）
java -jar convxml.jar config.xml src/gen templates defineOnly

# 启用详细日志
# 修改 log4j.xml，将 priority 改为 DEBUG

# 检查生成的文件
find src/gen -name "*.java" -type f

# 编译生成的代码
javac -d classes src/gen/**/*.java

# 查看生成的 ConvMain 类
cat src/gen/mytools/ConvMain.java
```

### 8.2 XML 配置速查

```xml
<!-- 最小化配置 -->
<config>
  <bean name="com.game.Monster">
    <variable name="id" type="int">ID</variable>
    <variable name="name" type="string">名称</variable>
  </bean>
</config>

<!-- 完整配置 -->
<config xmlns:xi="http://www.w3.org/2001/XInclude">
  <bean name="com.game.Monster" from="monster.xls" genxml="server" baseclass="BaseConfig">
    <variable name="id" type="int" fromCol="A">ID</variable>
    <variable name="name" type="string" fromCol="B" min="1" max="32">名称</variable>
    <variable name="level" type="int" fromCol="C" min="1" max="100">等级</variable>
    <variable name="skills" type="vector" value="int" fromCol="E,F,G">技能列表</variable>
  </bean>

  <xi:include href="items.xml"/>
</config>
```

### 8.3 故障排查速查

| 问题 | 检查项 | 命令 |
|-----|-------|------|
| 生成失败 | XML 格式 | `xmllint --noout config.xml` |
| 编码错误 | 文件编码 | `file -i config.xml` |
| 模板未找到 | 模板目录 | `ls -la templates/` |
| 编译失败 | 依赖关系 | `javac -verbose src/gen/**/*.java` |
| 内存溢出 | 堆内存 | `java -Xmx2g -jar convxml.jar ...` |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | convxml (Config XML to Java Code Generator) |
| **主要功能** | XML → Java Bean 代码生成 |
| **主要依赖** | Freemarker, Log4j, DOM Parser |
| **代码位置** | `server/tools/convxml/` |
| **主类** | `mytools.Main` |
| **输出编码** | UTF-8（硬编码） |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, Freemarker, Log4j |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器配置管理团队
- 查看项目 Wiki 获取更多文档

---

**文档版本**：v1.0
**维护者**：MT3 开发团队
**最后更新**：2025-11-27

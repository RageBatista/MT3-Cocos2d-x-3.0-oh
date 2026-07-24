# rpcgen - RPC 协议代码生成工具

## 1. 工具概述

### 1.1 用途说明
rpcgen 是一个基于 XML 协议定义的多语言代码生成器，专为 MT3 游戏服务器集群设计。该工具从 XML 协议定义文件自动生成跨语言通信所需的数据结构和序列化/反序列化代码，实现以下核心功能：

- **协议代码生成**：从 XML 定义生成 Protocol/RPC 类
- **数据结构生成**：生成 Bean 类及其 marshal/unmarshal 方法
- **多语言支持**：统一定义，生成 Java、C++、ActionScript、JavaScript 代码
- **类型安全**：自动生成类型转换和验证代码
- **序列化支持**：生成高效的二进制序列化/反序列化逻辑

### 1.2 典型使用场景
- **客户端-服务器通信**：定义网络协议，生成客户端（AS/JS）和服务器（Java/C++）代码
- **服务间通信**：游戏服务器集群内部 RPC 调用
- **数据持久化**：生成可序列化的数据对象
- **协议版本管理**：统一管理协议定义，确保多端一致性
- **开发效率提升**：避免手写样板代码，减少人为错误

### 1.3 关键特性
- **单一数据源**：XML 定义一次，生成多种语言代码
- **类型系统完整**：支持基础类型、集合类型、自定义 Bean、嵌套类型
- **协议验证**：支持字段范围验证（value/capacity validator）
- **增量生成**：智能缓存，仅更新变化的文件
- **命名空间支持**：支持多层命名空间（namespace）隔离
- **默认值支持**：字段可设置默认值
- **注释保留**：XML 注释转换为目标语言注释

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
rpcgen 位于 MT3 服务器架构的**开发工具链**，在编译阶段生成跨语言协议代码：

```
┌─────────────────────────────────────────┐
│    协议定义 (XML)                        │
│  - application, protocol, rpc            │
│  - bean, provider, service               │
└──────────────┬──────────────────────────┘
               │ (rpcgen 解析)
               ↓
┌─────────────────────────────────────────┐
│         rpcgen 代码生成器                │
│  - XML Parser (SAX/DOM)                 │
│  - Type System (types/*.java)           │
│  - Code Formatters (java/cxx/as/js/)    │
└──────────────┬──────────────────────────┘
               │ 生成代码
               ↓
┌─────────────────────────────────────────┐
│       多语言输出                         │
│  Java    → beans/, protocols/           │
│  C++     → rpcgen.cpp, rpcgen.hpp       │
│  AS      → (ActionScript 源文件)        │
│  JS      → (JavaScript 源文件)          │
└─────────────────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│    编译到最终应用程序                    │
│  - 游戏服务器 (Java/C++)                │
│  - 客户端 (AS/JS)                       │
└─────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **上游依赖**：
  - XML 协议定义文件（`*.xml`）
  - 基础类型库（`com.locojoy.base.Marshal`, `GNET::Octets` 等）
- **下游消费者**：
  - 游戏服务器（game_server, gate_server, zone_server 等）
  - 客户端（Flash AS3, HTML5 JS）
  - 工具（GM 工具、测试工具）
- **数据流**：单向生成（XML → 源代码）

### 2.3 支持的目标语言

| 语言 | 输出目录 | 主要用途 | 关键文件 |
|-----|---------|---------|---------|
| **Java** | `<service>/beans/`, `<service>/src/` | 服务器后端 | BeanFormatter.java, ProtocolFormatter.java |
| **C++** | `rpcgen/`, `rpcgen.hpp`, `rpcgen.cpp` | 高性能服务器/客户端 | BeanFormatter.java (cxx包) |
| **ActionScript** | (自定义输出) | Flash 客户端 | Rpcgen.java (as包) |
| **JavaScript** | (自定义输出) | H5 客户端 | Rpcgen.java (js包) |

### 2.4 关键代码位置

| 功能模块 | 文件路径 | 关键类 |
|---------|---------|-------|
| XML 解析器 | [src/rpcgen/Parser.java](src/rpcgen/Parser.java) | Parser |
| 类型系统 | [src/rpcgen/types/](src/rpcgen/types/) | Type, Bean, Variable, TypeInt, TypeMap... |
| Java 代码生成 | [src/rpcgen/java/BeanFormatter.java](src/rpcgen/java/BeanFormatter.java) | BeanFormatter, ProtocolFormatter, RpcFormatter |
| C++ 代码生成 | [src/rpcgen/cxx/BeanFormatter.java](src/rpcgen/cxx/BeanFormatter.java) | BeanFormatter, ProtocolFormatter, ManagerFormatter |
| AS 代码生成 | [src/rpcgen/as/](src/rpcgen/as/) | Rpcgen, BeanFormatter |
| JS 代码生成 | [src/rpcgen/js/](src/rpcgen/js/) | Rpcgen, BeanFormatter |
| 序列化逻辑 | [src/rpcgen/java/Marshal.java](src/rpcgen/java/Marshal.java) | Marshal, Unmarshal, Validator |
| 构建配置 | [build.xml](build.xml) | Ant 构建脚本 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**：JDK/JRE 1.6 及以上（推荐 JDK 8）
- **XML 解析器**：JDK 内置 `javax.xml.parsers`
- **基础库**（生成的代码依赖）：
  - Java: `com.locojoy.base.Marshal.Marshal`
  - C++: `GNET::Octets`, `GNET::Marshal`

### 3.2 构建时依赖
- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）
- **第三方 Jar**（可选）：`lib/` 目录下的依赖库

### 3.3 构建步骤

#### Windows/Linux/macOS 环境
```bash
# 方式 1：使用 Ant 构建
ant clean dist

# 方式 2：安装到指定目录
ant install

# 输出文件：rpcgen.jar
```

#### 构建流程说明
构建脚本执行以下步骤（参见 [build.xml](build.xml)）：

1. **初始化阶段**（init）：创建 `classes/` 编译输出目录
2. **编译阶段**（compile）：
   - 编译 `src/**/*.java` → `classes/`
   - 使用 GBK 编码（中文注释兼容）
   - 启用调试信息（lines, source）
   - 编译参数：`-Xlint:unchecked`（警告未检查的泛型）
3. **打包阶段**（dist）：
   - 生成 `rpcgen.jar`
   - 使用 `src/MANIFEST.MF` 清单文件
4. **安装阶段**（install，可选）：
   - 复制到 `../bin/rpcgen.jar`
   - 复制到 `../../server/game_server/rpcgen.jar`

### 3.4 构建参数说明

| 参数 | 说明 | 默认值 |
|-----|------|-------|
| `src` | 源代码目录 | `src/` |
| `build` | 编译输出目录 | `classes/` |
| `lib` | 第三方库目录 | `lib/` |
| `snailbin` | 工具安装目录 | `../bin` |
| `game_server` | 服务器安装目录 | `../../server/game_server/` |

---

## 4. XML 协议定义规范

### 4.1 基本结构
```xml
<?xml version="1.0" encoding="gbk"?>
<application name="demo" shareHome="../../../../share" pvids="12">
    <!-- 导入其他协议定义 -->
    <import file="gnet/gnet.xml"/>

    <!-- 自定义数据结构 -->
    <bean name="UserInfo">
        <variable name="userId" type="long"/>
        <variable name="userName" type="string"/>
    </bean>

    <!-- 协议定义 -->
    <protocol name="CLogin" type="1001" maxsize="1024" prior="1">
        <variable name="username" type="string"/>
        <variable name="password" type="string"/>
    </protocol>

    <!-- RPC 定义 -->
    <rpc name="QueryUser" type="2001"
         argument="UserQueryRequest"
         result="UserQueryResponse"
         timeout="5000"/>

    <!-- 协议提供者 -->
    <provider name="auth" pvid="10">
        <protocol name="CLogin" type="1001"/>
        <rpc name="QueryUser" type="2001"/>
    </provider>

    <!-- 状态定义 -->
    <state name="AuthState">
        <provider ref="auth"/>
    </state>

    <!-- 服务定义 -->
    <service name="auth_server">
        <manager name="AuthManager" type="server"
                 initstate="AuthState" port="8001">
            <state ref="AuthState"/>
        </manager>
    </service>
</application>
```

### 4.2 核心元素详解

#### 4.2.1 `<application>` - 应用根节点
定义整个应用及其命名空间。

**属性**：
- `name` (必填)：应用名称，也是顶级命名空间
- `shareHome` (可选)：C++ 共享库路径（生成 C++ 代码时使用）
- `pvids` (可选)：Provider ID 范围（格式：`"start-end"` 或单个数字）

**示例**：
```xml
<application name="game" shareHome="../../../../share" pvids="10-20">
    <!-- 内容 -->
</application>
```

#### 4.2.2 `<bean>` - 自定义数据结构
定义可序列化的数据对象（类似 Java Bean）。

**属性**：
- `name` (必填)：Bean 名称
- `comparable` (可选)：是否实现 Comparable 接口（默认 false）

**子元素**：
- `<enum>`：枚举常量
- `<variable>`：字段定义

**示例**：
```xml
<bean name="PlayerData" comparable="true">
    <enum name="MAX_LEVEL" value="100"/>
    <variable name="playerId" type="long"/>
    <variable name="level" type="int" default="1"/>
    <variable name="items" type="map" key="int" value="ItemData"/>
</bean>
```

#### 4.2.3 `<protocol>` - 协议定义
定义单向通信协议（C→S 或 S→C）。

**属性**：
- `name` (必填)：协议名称
- `type` (必填)：协议类型号（全局唯一）
- `maxsize` (可选)：协议最大长度（字节）
- `prior` (可选)：优先级（C++ 使用）
- `argument` (可选)：附带的参数类型（Bean 名称）

**子元素**：与 `<bean>` 相同（`<enum>`, `<variable>`）

**示例**：
```xml
<protocol name="CAttack" type="3001" maxsize="512" prior="1">
    <variable name="targetId" type="long"/>
    <variable name="skillId" type="int"/>
    <variable name="position" type="Vector3" validator="capacity=3"/>
</protocol>
```

#### 4.2.4 `<rpc>` - RPC 定义
定义双向 RPC 调用（请求-响应模式）。

**属性**：
- `name` (必填)：RPC 名称
- `type` (必填)：协议类型号（全局唯一）
- `argument` (必填)：请求参数类型（Bean 名称）
- `result` (必填)：响应结果类型（Bean 名称）
- `timeout` (可选)：RPC 超时时间（毫秒）
- `maxsize` (可选)：最大长度（字节）
- `prior` (可选)：优先级

**示例**：
```xml
<rpc name="QueryPlayerInfo" type="4001"
     argument="PlayerQueryReq"
     result="PlayerQueryResp"
     timeout="3000"
     maxsize="2048"/>
```

#### 4.2.5 `<variable>` - 字段定义
定义协议或 Bean 的字段。

**属性**：
- `name` (必填)：字段名称
- `type` (必填)：字段类型（见 4.3 节）
- `default` (可选)：默认值
- `validator` (可选)：字段验证规则（见 4.5 节）
- `key` (集合类型)：Map 的 Key 类型
- `value` (集合类型)：容器的元素类型

**示例**：
```xml
<!-- 基础类型 -->
<variable name="age" type="int" default="18"/>

<!-- 字符串（带长度限制） -->
<variable name="username" type="string" validator="capacity=32"/>

<!-- 列表 -->
<variable name="scores" type="list" value="int" validator="capacity=100"/>

<!-- 映射表 -->
<variable name="inventory" type="map" key="int" value="ItemData"
          validator="capacity=200;key=[1,1000];value=[1,)"/>

<!-- 自定义 Bean -->
<variable name="profile" type="UserProfile"/>
```

#### 4.2.6 `<provider>` - 协议提供者
将多个协议/RPC 组织到一个逻辑单元。

**属性**：
- `name` (必填)：提供者名称
- `pvid` (必填)：提供者 ID（在 `application.pvids` 范围内）

**子元素**：
- `<protocol/>`：引用协议
- `<rpc/>`：引用 RPC
- `<bean>`：嵌套 Bean 定义

**示例**：
```xml
<provider name="combat" pvid="15">
    <protocol name="CAttack" type="3001"/>
    <protocol name="SAttackResult" type="3002"/>
    <rpc name="QuerySkillInfo" type="3003"/>

    <!-- 提供者内部 Bean（命名空间：app.combat.SkillData） -->
    <bean name="SkillData">
        <variable name="skillId" type="int"/>
    </bean>
</provider>
```

#### 4.2.7 `<state>` - 状态定义
定义连接状态及可用的协议集。

**属性**：
- `name` (必填)：状态名称
- `timeout` (可选)：状态超时时间（毫秒）

**子元素**：
- `<protocol ref="..."/>`：引用协议（使用全限定名）
- `<rpc ref="..."/>`：引用 RPC
- `<provider ref="..."/>`：引用提供者

**示例**：
```xml
<state name="InGame" timeout="60000">
    <provider ref="combat"/>
    <provider ref="trade"/>
    <protocol ref="gnet.link.KeepAlive"/>
</state>
```

#### 4.2.8 `<service>` - 服务定义
rpcgen 的生成单元（每个 service 生成一个目录）。

**属性**：
- `name` (必填)：服务名称（生成的目录名）

**子元素**：
- `<manager>`：管理器定义

**示例**：
```xml
<service name="game_server">
    <manager name="ClientManager" type="server"
             initstate="PlayerState" port="9000">
        <state ref="PlayerState"/>
        <state ref="CombatState"/>
    </manager>
</service>
```

#### 4.2.9 `<manager>` - 管理器定义
定义网络管理器及其状态机。

**属性**：
- `name` (必填)：管理器名称
- `type` (必填)：类型（`client` / `server` / `provider`）
- `initstate` (必填)：初始状态名称
- `port` (可选)：监听端口（生成初始化代码）
- `bind` (可选)：绑定的 Provider 名称（type=provider 时使用）

**子元素**：
- `<state ref="..."/>`：引用状态（使用全限定名）

**示例**：
```xml
<manager name="GateManager" type="server"
         initstate="LoginState" port="8888">
    <state ref="LoginState"/>
    <state ref="InGameState"/>
</manager>
```

#### 4.2.10 `<namespace>` - 命名空间
用于组织协议，避免命名冲突。

**示例**：
```xml
<provider name="gs" pvid="12">
    <namespace name="fight">
        <protocol name="CAttack" type="100"/>
        <namespace name="skill">
            <protocol name="CUseSkill" type="101"/>
        </namespace>
    </namespace>
    <namespace name="trade">
        <protocol name="CAttack" type="200"/> <!-- 不冲突 -->
    </namespace>
</provider>
```

**生成的 Java 包名**：
- `gs.fight.CAttack`
- `gs.fight.skill.CUseSkill`
- `gs.trade.CAttack`

### 4.3 支持的类型系统

#### 4.3.1 基础类型

| XML 类型 | Java | C++ | ActionScript | JavaScript | 说明 |
|---------|------|-----|--------------|-----------|------|
| `byte` | `byte` | `char` | `int` | `Number` | 8 位整数 |
| `short` | `short` | `short` | `int` | `Number` | 16 位整数 |
| `int` | `int` | `int` | `int` | `Number` | 32 位整数 |
| `long` | `long` | `int64_t` | `Number` | `Number` | 64 位整数 |
| `float` | `float` | `float` | `Number` | `Number` | 单精度浮点 |
| `octets` | `Octets` | `GNET::Octets` | `ByteArray` | `ArrayBuffer` | 二进制数据 |
| `string` | `String` | `GNET::Octets` | `String` | `String` | UTF-16LE 编码 |

#### 4.3.2 集合类型

| XML 类型 | Java | C++ | 语法示例 |
|---------|------|-----|---------|
| `list` | `LinkedList<T>` | `std::list<T>` | `<variable name="ids" type="list" value="int"/>` |
| `vector` | `ArrayList<T>` | `std::vector<T>` | `<variable name="names" type="vector" value="string"/>` |
| `set` | `HashSet<T>` | `std::set<T>` | `<variable name="flags" type="set" value="int"/>` |
| `map` | `HashMap<K,V>` | `std::map<K,V>` | `<variable name="data" type="map" key="int" value="string"/>` |

#### 4.3.3 自定义类型
- **Bean 引用**：使用 Bean 名称（支持全限定名）
- **跨命名空间引用**：`demo.bfloat`, `gs.fight.SkillData`

**示例**：
```xml
<bean name="InventoryItem">
    <variable name="itemId" type="int"/>
</bean>

<protocol name="SInventoryUpdate" type="5001">
    <variable name="items" type="list" value="InventoryItem"/>
</protocol>
```

### 4.4 默认值支持

#### 4.4.1 基础类型默认值
```xml
<!-- 数字类型 -->
<variable name="level" type="int" default="1"/>
<variable name="rate" type="float" default="0.5f"/>
<variable name="gold" type="long" default="1000L"/>

<!-- 枚举常量 -->
<bean name="Player">
    <enum name="DEFAULT_LEVEL" value="10"/>
    <variable name="level" type="int" default="DEFAULT_LEVEL"/>
</bean>
```

**注意**：
- 浮点数需要后缀 `f`：`0.5f`
- 长整数需要后缀 `L`：`1000L`
- 支持 C++/Java 通用写法：`0x1000`（十六进制）、`1.23e-5f`（科学计数法）

#### 4.4.2 跨命名空间默认值
```xml
<bean name="Config">
    <variable name="maxLevel" type="int" default="demo.bfloat.MAX_LEVEL"/>
    <!-- 同一命名空间可省略前缀 -->
    <variable name="defaultHP" type="int" default="Player.DEFAULT_HP"/>
</bean>
```

**规则**：
- `.` 在 Java 中表示包分隔符
- `.` 在 C++ 中自动转换为 `::`
- 必须引用已定义的枚举常量

#### 4.4.3 字符串默认值
```xml
<!-- 字符串默认值（不需要引号） -->
<variable name="serverName" type="string" default="DefaultServer"/>
```

**注意**：
- 不支持包含空格或特殊字符的默认值
- 生成代码时自动添加引号

### 4.5 字段验证（Validator）

#### 4.5.1 值范围验证（value）
限制数值字段的取值范围。

**语法**：
```
value=[min,max]    // 闭区间：min <= value <= max
value=(min,max)    // 开区间：min < value < max
value=[min,max)    // 半开区间：min <= value < max
value=(min,max]    // 半开区间：min < value <= max
value=[min,)       // 仅最小值限制
value=(,max]       // 仅最大值限制
value=(,)          // 不验证（占位符）
```

**示例**：
```xml
<!-- 等级范围 1-100 -->
<variable name="level" type="int" validator="value=[1,100]"/>

<!-- 血量必须大于 0 -->
<variable name="hp" type="int" validator="value=(0,)"/>

<!-- 概率 0.0 ~ 1.0 -->
<variable name="rate" type="float" validator="value=[0.0,1.0]"/>

<!-- Map 的 key 和 value 都有范围限制 -->
<variable name="scores" type="map" key="int" value="int"
          validator="key=[1,1000];value=[0,100]"/>
```

#### 4.5.2 容量验证（capacity）
限制容器类型（string/octets/list/vector/set/map）的最大长度。

**语法**：
```
capacity=<max>     // 最大容量
```

**示例**：
```xml
<!-- 用户名最长 32 个字符 -->
<variable name="username" type="string" validator="capacity=32"/>

<!-- 背包最多 100 个物品 -->
<variable name="items" type="list" value="ItemData" validator="capacity=100"/>

<!-- 二进制数据最大 1KB -->
<variable name="rawData" type="octets" validator="capacity=1024"/>

<!-- Map 最多 200 个键值对 -->
<variable name="config" type="map" key="string" value="int"
          validator="capacity=200"/>
```

#### 4.5.3 组合验证
同时限制容量和元素范围。

**示例**：
```xml
<!-- 最多 50 个 ID，每个 ID 在 1-10000 范围内 -->
<variable name="playerIds" type="list" value="long"
          validator="capacity=50;value=[1,10000]"/>

<!-- Map：最多 100 项，key 1-1000，value 正数 -->
<variable name="inventory" type="map" key="int" value="int"
          validator="capacity=100;key=[1,1000];value=(0,)"/>
```

#### 4.5.4 验证时机控制
通过 rpcgen 命令行参数控制验证时机。

**命令行参数**：
- `-validateMarshal`：在序列化（marshal）前验证
- `-validateUnmarshal`：在反序列化（unmarshal）后验证

**验证失败处理**：
- **Java**：抛出 `java.lang.VerifyError("validator failed")`
- **C++**：抛出 `Marshal::Exception()`

**最佳实践**：
- **客户端发送**：不验证 marshal（信任客户端，节省性能）
- **服务器接收**：必须验证 unmarshal（防御恶意数据）
- **服务器发送**：可选验证 marshal（调试阶段开启）

#### 4.5.5 支持验证的类型

| 类型 | 支持的 validator | 示例 |
|-----|-----------------|------|
| `byte` | `value=[min,max]` | `value=[-128,127]` |
| `int` | `value=[min,max]` | `value=[0,100]` |
| `float` | `value=[min,max]` | `value=[0.0,1.0]` |
| `long` | `value=[min,max]` | `value=[1,1000000L]` |
| `octets` | `capacity=max` | `capacity=1024` |
| `string` | `capacity=max` | `capacity=64` |
| `list` | `capacity=max` + `value=[min,max]`* | `capacity=100;value=[1,)` |
| `vector` | `capacity=max` + `value=[min,max]`* | `capacity=50` |
| `set` | `capacity=max` + `value=[min,max]`* | `capacity=20;value=[0,1000]` |
| `map` | `capacity=max` + `key=[min,max]`* + `value=[min,max]`* | `capacity=200;key=[1,);value=(0,100]` |

*：仅当元素类型支持值验证时有效

### 4.6 注释支持
XML 注释会转换为目标语言的注释。

**示例**：
```xml
<!-- 用户登录协议 -->
<protocol name="CLogin" type="1001">
    <variable name="username" type="string"/> <!-- 用户名 -->
    <variable name="password" type="string"/> <!-- 密码 -->
</protocol>
```

**生成的 Java 代码**：
```java
/**
 * 用户登录协议
 */
public class CLogin implements Protocol {
    public String username; // 用户名
    public String password; // 密码
    // ...
}
```

---

## 5. 使用指南

### 5.1 基本命令格式
```bash
java -jar rpcgen.jar [options] <xml-file>
```

**参数说明**：
- `<xml-file>`：协议定义文件路径
- `[options]`：可选命令行参数（见下节）

### 5.2 命令行选项

| 选项 | 说明 | 默认值 |
|-----|------|-------|
| `-h`, `--help` | 显示帮助信息 | - |
| `-validateMarshal` | 在序列化前调用验证函数 | 禁用 |
| `-validateUnmarshal` | 在反序列化后调用验证函数 | 禁用 |
| *(其他选项)* | *(根据实际实现补充)* | - |

### 5.3 使用示例

#### 示例 1：生成基本协议
**XML 定义**（`auth.xml`）：
```xml
<?xml version="1.0" encoding="gbk"?>
<application name="auth" pvids="10">
    <bean name="UserInfo">
        <variable name="userId" type="long"/>
        <variable name="username" type="string" validator="capacity=32"/>
        <variable name="level" type="int" default="1"/>
    </bean>

    <protocol name="CLogin" type="1001" maxsize="512">
        <variable name="username" type="string" validator="capacity=32"/>
        <variable name="password" type="string" validator="capacity=64"/>
    </protocol>

    <protocol name="SLoginResult" type="1002" maxsize="1024">
        <variable name="success" type="byte"/>
        <variable name="userInfo" type="UserInfo"/>
    </protocol>

    <service name="auth_server">
        <manager name="AuthManager" type="server"
                 initstate="AuthState" port="8001">
            <state ref="AuthState"/>
        </manager>
    </service>

    <state name="AuthState">
        <protocol ref="auth.CLogin"/>
        <protocol ref="auth.SLoginResult"/>
    </state>
</application>
```

**生成代码**：
```bash
java -jar rpcgen.jar auth.xml
```

**输出结构**：
```
auth_server/
├── beans/
│   └── auth/
│       └── UserInfo.java          # 生成的 Bean
├── src/
│   └── auth/
│       ├── CLogin.java            # 协议类
│       └── SLoginResult.java
└── auth_server.xio.xml            # 管理器配置
```

**生成的 Java 代码示例**（`UserInfo.java`）：
```java
package auth;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public class UserInfo implements Marshal {
    public long userId;
    public String username;
    public int level = 1; // 默认值

    public UserInfo() {}

    public UserInfo(long userId, String username, int level) {
        this.userId = userId;
        this.username = username;
        this.level = level;
    }

    // 验证方法（仅在启用 validator 时调用）
    private void _validator_() throws MarshalException {
        if (username.length() > 32)
            throw new VerifyError("validator failed: username capacity");
    }

    // 序列化
    public OctetsStream marshal(OctetsStream os) {
        os.marshal(userId);
        os.marshal(username);
        os.marshal(level);
        return os;
    }

    // 反序列化
    public OctetsStream unmarshal(OctetsStream os) throws MarshalException {
        userId = os.unmarshal_long();
        username = os.unmarshal_String();
        level = os.unmarshal_int();
        return os;
    }

    // equals, hashCode, toString 等方法...
}
```

#### 示例 2：多语言代码生成
**生成 Java + C++ 代码**：
```bash
# 生成 Java 代码（默认）
java -jar rpcgen.jar game.xml

# 如果工具支持多语言参数（需查看实际实现）
java -jar rpcgen.jar -lang java,cxx game.xml
```

**C++ 输出结构**：
```
rpcgen/
├── UserInfo.hpp              # C++ Bean 头文件
├── CLogin.hpp
└── protocols.hpp             # 协议集合头文件
rpcgen.cpp                    # C++ 实现文件
rpcgen.hpp                    # C++ 主头文件
```

#### 示例 3：使用验证功能
**XML 定义**：
```xml
<protocol name="CCreateRole" type="2001">
    <variable name="roleName" type="string"
              validator="capacity=16"/>
    <variable name="gender" type="byte"
              validator="value=[0,1]"/>
    <variable name="classId" type="int"
              validator="value=[1,5]"/>
</protocol>
```

**生成带验证的代码**：
```bash
# 仅在反序列化时验证（推荐服务器端）
java -jar rpcgen.jar -validateUnmarshal game.xml

# 序列化和反序列化都验证（调试模式）
java -jar rpcgen.jar -validateMarshal -validateUnmarshal game.xml
```

**生成的验证逻辑**（Java）：
```java
private void _validator_() throws MarshalException {
    // 字符串长度验证
    if (roleName.length() > 16)
        throw new VerifyError("validator failed: roleName capacity");

    // 数值范围验证
    if (gender < 0 || gender > 1)
        throw new VerifyError("validator failed: gender value");

    if (classId < 1 || classId > 5)
        throw new VerifyError("validator failed: classId value");
}

// 在 unmarshal 后自动调用
public OctetsStream unmarshal(OctetsStream os) throws MarshalException {
    // ... 反序列化代码 ...
    _validator_(); // 验证失败抛出异常
    return os;
}
```

#### 示例 4：跨文件引用
**基础定义**（`base.xml`）：
```xml
<application name="base">
    <bean name="Vector3">
        <variable name="x" type="float"/>
        <variable name="y" type="float"/>
        <variable name="z" type="float"/>
    </bean>
</application>
```

**游戏协议**（`game.xml`）：
```xml
<application name="game">
    <import file="base.xml"/>

    <protocol name="CMove" type="3001">
        <variable name="position" type="base.Vector3"/>
    </protocol>
</application>
```

**生成代码**：
```bash
java -jar rpcgen.jar game.xml
```

---

## 6. 输出规范

### 6.1 Java 输出

#### 6.1.1 目录结构
```
<service>/
├── beans/                    # Bean 类目录
│   └── <namespace>/
│       └── <BeanName>.java
├── src/                      # Protocol/RPC 类目录
│   └── <namespace>/
│       ├── <ProtocolName>.java
│       └── <RpcName>.java
└── <service>.xio.xml         # 管理器配置文件
```

#### 6.1.2 生成的类结构
**Bean 类**：
```java
public class <BeanName> implements Marshal, Comparable<BeanName> {
    // 枚举常量
    public final static int ENUM_NAME = value;

    // 字段
    public <Type> fieldName = defaultValue;

    // 构造函数
    public <BeanName>() {}
    public <BeanName>(<params>) { ... }

    // 序列化方法
    public OctetsStream marshal(OctetsStream os) { ... }
    public OctetsStream unmarshal(OctetsStream os) { ... }

    // 验证方法（可选）
    private void _validator_() throws MarshalException { ... }

    // 工具方法
    public boolean equals(Object o) { ... }
    public int hashCode() { ... }
    public int compareTo(<BeanName> o) { ... }
    public String toString() { ... }
}
```

**Protocol 类**：
```java
public class <ProtocolName> implements Protocol {
    public static final int TYPE = <type>;

    // 字段定义...

    // Protocol 接口方法
    public int getType() { return TYPE; }
    public OctetsStream encode(OctetsStream os) { ... }
    public OctetsStream decode(OctetsStream os) { ... }
}
```

**RPC 类**：
```java
public class <RpcName> extends Rpc {
    public static final int TYPE = <type>;

    private <ArgumentBean> argument;
    private <ResultBean> result;

    public int getType() { return TYPE; }
    public <ArgumentBean> getArgument() { return argument; }
    public <ResultBean> getResult() { return result; }

    // RPC 生命周期回调
    public void onRequest() { ... }
    public void onTimeout() { ... }
}
```

#### 6.1.3 生成的配置文件（xio.xml）
```xml
<?xml version="1.0" encoding="UTF-8"?>
<MkioConf name="auth_server">
    <Manager name="AuthManager" type="server">
        <BindProvider pvid="10"/>
        <State name="AuthState" timeout="60000">
            <Protocol ref="auth.CLogin"/>
            <Protocol ref="auth.SLoginResult"/>
        </State>
    </Manager>
</MkioConf>
```

### 6.2 C++ 输出

#### 6.2.1 目录结构
```
rpcgen/
├── <namespace>/
│   ├── <BeanName>.hpp        # Bean 头文件
│   └── <ProtocolName>.hpp    # Protocol 头文件
├── protocols.hpp             # 所有协议的集合头文件
rpcgen.cpp                    # 实现文件
rpcgen.hpp                    # 主头文件
```

#### 6.2.2 生成的类结构（C++）
**Bean 类**：
```cpp
#pragma once
#include <GNET/Marshal.hpp>

namespace <namespace> {

class <BeanName> : public GNET::Marshal {
public:
    enum {
        ENUM_NAME = value
    };

    <Type> fieldName;

    <BeanName>() : fieldName(defaultValue) {}
    <BeanName>(<params>) : fieldName(val) {}

    void _validator_() const {
        // 验证逻辑...
    }

    GNET::OctetsStream& marshal(GNET::OctetsStream& os) const {
        os << fieldName;
        return os;
    }

    const GNET::OctetsStream& unmarshal(const GNET::OctetsStream& os) {
        os >> fieldName;
        return os;
    }

    bool operator<(const <BeanName>& rhs) const { ... }
    friend std::ostream& operator<<(std::ostream& os, const <BeanName>& obj);
};

} // namespace
```

### 6.3 ActionScript 输出
（根据 `src/rpcgen/as/` 实现，生成 AS3 类文件）

### 6.4 JavaScript 输出
（根据 `src/rpcgen/js/` 实现，生成 JS 模块）

### 6.5 仅生成一次的文件
以下文件仅在首次生成时创建，后续不会覆盖（允许手动修改）：

**Java**：
- `<service>/<service>.xio.xml`（管理器配置）
- 带有 `Coder` 标记的文件

**C++**：
- `rpcgen.cpp`
- `rpcgen.hpp`
- `protocols.hpp`
- `rpcgen/` 目录下的文件

**注意**：如果删除这些文件，重新运行 rpcgen 会重新生成。

---

## 7. 注意事项

### 7.1 已知限制

#### 7.1.1 编码限制
- **XML 文件编码**：必须使用 GBK 编码（`<?xml version="1.0" encoding="gbk"?>`）
- **生成代码编码**：Java 使用 UTF-8，C++ 取决于项目配置
- **字符串编码**：Java 字符串默认 UTF-16LE

#### 7.1.2 类型限制
- **不支持多维数组**：如需嵌套集合，需定义中间 Bean
  ```xml
  <!-- 错误：不支持 list<list<int>> -->
  <variable name="matrix" type="list" value="list"/>

  <!-- 正确：定义中间 Bean -->
  <bean name="IntList">
      <variable name="items" type="list" value="int"/>
  </bean>
  <variable name="matrix" type="list" value="IntList"/>
  ```

- **Map 的 Key 限制**：某些语言（如 AS3）可能不支持复杂类型作为 Key
- **循环引用**：Bean 之间不能形成循环依赖
  ```xml
  <!-- 错误：循环依赖 -->
  <bean name="A">
      <variable name="b" type="B"/>
  </bean>
  <bean name="B">
      <variable name="a" type="A"/>  <!-- 循环！ -->
  </bean>
  ```

#### 7.1.3 命名限制
- **保留关键字**：避免使用目标语言的保留字（如 Java 的 `class`, `public`）
- **类型号唯一性**：全局 `type` 必须唯一（建议分段管理，如 1000-1999 登录，2000-2999 战斗）
- **Provider ID 范围**：`pvid` 必须在 `application.pvids` 范围内

#### 7.1.4 验证限制
- **性能开销**：大量验证规则会影响性能，生产环境建议仅在 unmarshal 时验证
- **不支持 Bean 嵌套验证**：自定义 Bean 类型的字段无法设置 validator
- **protocol.maxsize 未实现**：容器容量验证可替代部分功能，但协议总大小验证未完全实现

### 7.2 性能考虑

#### 7.2.1 序列化性能
- **基础类型**：性能最优（直接字节操作）
- **字符串**：涉及编码转换，中等性能
- **集合类型**：需遍历元素，性能取决于容量
- **嵌套 Bean**：递归序列化，深度影响性能

**优化建议**：
- 避免过深的嵌套结构（建议 ≤ 3 层）
- 使用 `vector` 替代 `list`（连续内存，缓存友好）
- 限制集合容量（使用 `capacity` validator）

#### 7.2.2 代码生成性能
- **增量生成**：仅更新变化的文件（基于缓存机制）
- **大规模协议**：数百个协议定义时，生成时间可能达到数十秒

#### 7.2.3 编译性能
- **Java**：生成的类数量多时，编译时间增加
- **C++**：头文件依赖多，建议使用预编译头（PCH）

### 7.3 最佳实践

#### 7.3.1 协议设计
1. **小而精**：单个协议不超过 20 个字段
2. **版本化**：协议类型号预留扩展空间（如 1000-1099 登录 v1，1100-1199 登录 v2）
3. **向后兼容**：新增字段放在末尾，使用默认值
4. **文档注释**：所有协议/字段添加 XML 注释

#### 7.3.2 类型选择
- **整数类型**：
  - 小范围（0-255）用 `byte`
  - ID/时间戳用 `long`
  - 其他用 `int`
- **字符串 vs Octets**：
  - 文本内容用 `string`
  - 二进制数据用 `octets`
- **集合类型**：
  - 顺序重要用 `list`
  - 随机访问用 `vector`
  - 唯一性用 `set`
  - 键值对用 `map`

#### 7.3.3 验证策略
- **客户端**：仅验证 unmarshal（防御服务器错误）
- **服务器**：必须验证所有 unmarshal（防御恶意客户端）
- **内部服务**：可信环境下可关闭验证

#### 7.3.4 命名规范
- **协议**：`C`（客户端发起）/ `S`（服务器发起）+ 功能名
  - 示例：`CLogin`, `SLoginResult`
- **RPC**：动词 + 名词
  - 示例：`QueryPlayerInfo`, `UpdateInventory`
- **Bean**：名词
  - 示例：`PlayerData`, `ItemInfo`

#### 7.3.5 目录组织
```
protocols/
├── base.xml           # 基础类型定义
├── auth.xml           # 认证协议
├── combat.xml         # 战斗协议
├── trade.xml          # 交易协议
└── build.sh           # 批量生成脚本
```

**批量生成脚本**（`build.sh`）：
```bash
#!/bin/bash
cd "$(dirname "$0")"

RPCGEN="java -jar ../rpcgen.jar -validateUnmarshal"

$RPCGEN base.xml
$RPCGEN auth.xml
$RPCGEN combat.xml
$RPCGEN trade.xml

echo "All protocols generated successfully!"
```

### 7.4 故障排查指南

#### 问题 1：XML 解析失败
**症状**：`SAXParseException` 或 `Malformed XML`

**可能原因**：
- XML 格式错误（未闭合标签、属性缺少引号）
- 编码不匹配（文件编码非 GBK）
- 特殊字符未转义（如 `<`, `>` 需写成 `&lt;`, `&gt;`）

**排查步骤**：
```bash
# 1. 验证 XML 格式
xmllint --noout protocols/game.xml

# 2. 检查文件编码
file -i protocols/game.xml
# 应输出：charset=gbk 或 charset=gb2312

# 3. 转换编码（如果需要）
iconv -f UTF-8 -t GBK protocols/game.xml > protocols/game_gbk.xml
```

#### 问题 2：类型找不到
**症状**：`Type not found: XXX` 或编译错误 `cannot find symbol`

**可能原因**：
- Bean 未定义或拼写错误
- 跨命名空间引用缺少前缀
- 导入文件路径错误

**解决方案**：
```xml
<!-- 错误：引用未定义的类型 -->
<variable name="data" type="UnknownBean"/>

<!-- 正确：使用已定义的 Bean -->
<bean name="KnownBean">
    <variable name="value" type="int"/>
</bean>
<variable name="data" type="KnownBean"/>

<!-- 跨命名空间引用 -->
<variable name="pos" type="base.Vector3"/>  <!-- 完整路径 -->
```

#### 问题 3：协议类型号冲突
**症状**：`Duplicate protocol type: 1001`

**解决方案**：
1. 检查所有 XML 文件，确保 `type` 唯一
2. 使用分段管理策略：
   ```xml
   <!-- auth.xml -->
   <protocol name="CLogin" type="1001"/>    <!-- 1000-1999 认证 -->

   <!-- combat.xml -->
   <protocol name="CAttack" type="2001"/>   <!-- 2000-2999 战斗 -->
   ```

#### 问题 4：生成的代码编译失败
**症状**：Java/C++ 编译错误

**Java 常见问题**：
```bash
# 缺少依赖库
# 解决：确保 com.locojoy.base.Marshal 在 classpath 中
javac -cp "lib/*:." beans/auth/*.java

# 编码问题
# 解决：指定编码
javac -encoding UTF-8 beans/auth/*.java
```

**C++ 常见问题**：
```bash
# 找不到头文件
# 解决：检查 application.shareHome 路径
<application shareHome="../../../../share"/>

# 命名空间冲突
# 解决：检查是否有重名的 namespace
```

#### 问题 5：验证失败
**症状**：运行时抛出 `VerifyError: validator failed`

**调试方法**：
```java
// 临时关闭验证，定位问题字段
try {
    protocol.unmarshal(stream);
} catch (VerifyError e) {
    System.err.println("Validation failed: " + e.getMessage());
    // 打印字段值，检查哪个字段超限
}
```

**检查清单**：
- [ ] 字段值是否在 `value=[min,max]` 范围内
- [ ] 容器大小是否超过 `capacity=max`
- [ ] Map 的 key 和 value 是否都满足验证规则
- [ ] 默认值是否符合验证规则

#### 问题 6：性能问题
**症状**：序列化/反序列化耗时过长

**性能分析**：
```java
// Java 性能测试
long start = System.nanoTime();
for (int i = 0; i < 10000; i++) {
    protocol.marshal(new OctetsStream());
}
long end = System.nanoTime();
System.out.println("Avg marshal time: " + (end - start) / 10000 + " ns");
```

**优化方向**：
1. 减少嵌套深度
2. 限制集合容量
3. 使用 `vector` 替代 `list`
4. 缓存序列化结果（如果协议不可变）

---

## 8. 扩展与改进

### 8.1 架构特点

#### 8.1.1 访问者模式（Visitor Pattern）
代码生成器使用访问者模式遍历类型树：

```
Type (抽象类型)
├── TypeByte, TypeInt, TypeLong...  (基础类型)
├── TypeOctets, TypeText            (二进制/字符串)
└── TypeCollection                  (集合类型)
    ├── TypeList, TypeVector
    ├── TypeSet
    └── TypeMap

Visitor 接口：
├── Marshal (序列化逻辑)
├── Unmarshal (反序列化逻辑)
├── Validator (验证逻辑)
└── Construct (构造函数逻辑)
```

#### 8.1.2 代码缓存机制
`CachedFileOutputStream` 避免重复生成未变化的文件：
- 计算内容哈希，仅写入变化的文件
- 删除未被引用的旧文件

#### 8.1.3 命名空间管理
`Namespace` 类处理多层命名空间：
```
demo
├── gs
│   ├── fight
│   │   └── skill
│   └── trade
└── auth
```

### 8.2 推荐改进方向

#### 8.2.1 短期优化（1-2 周）
1. **错误提示优化**：
   - 精确定位 XML 错误行号
   - 友好的类型错误提示
   - 验证失败时输出详细字段信息

2. **文档生成**：
   - 从 XML 生成 Markdown/HTML 协议文档
   - 自动生成协议变更日志

3. **IDE 支持**：
   - XML Schema (XSD) 定义，支持 IDE 自动补全
   - IntelliJ IDEA / VS Code 插件

#### 8.2.2 中期优化（1-2 个月）
4. **版本兼容性**：
   - 协议版本号管理
   - 自动检测不兼容变更（字段删除、类型变更）

5. **代码优化**：
   - 使用 StringBuilder 替代字符串拼接
   - 延迟初始化（Lazy Initialization）

6. **测试支持**：
   - 自动生成协议测试用例
   - Mock 数据生成器

7. **新语言支持**：
   - TypeScript
   - Protobuf 格式导出

#### 8.2.3 长期优化（3-6 个月）
8. **性能优化**：
   - 零拷贝序列化（DirectByteBuffer）
   - 自定义序列化格式（替代 OctetsStream）

9. **高级特性**：
   - 泛型 Bean 支持
   - 继承与多态支持
   - 协议加密/压缩

10. **可观测性**：
    - 协议调用统计（埋点代码生成）
    - 协议大小分析工具

### 8.3 参考资料
- 示例协议定义：[demo/demo.gsd.xml](demo/demo.gsd.xml)
- 中文文档：[readme.txt](readme.txt)
- 构建脚本：[build.xml](build.xml)

---

## 9. 快速参考

### 9.1 XML 元素速查表

| 元素 | 用途 | 必填属性 | 示例 |
|-----|------|---------|------|
| `<application>` | 应用根节点 | `name` | `<application name="game">` |
| `<bean>` | 自定义数据结构 | `name` | `<bean name="UserInfo">` |
| `<protocol>` | 单向协议 | `name`, `type` | `<protocol name="CLogin" type="1001">` |
| `<rpc>` | RPC 调用 | `name`, `type`, `argument`, `result` | `<rpc name="Query" type="2001" argument="Req" result="Resp">` |
| `<variable>` | 字段定义 | `name`, `type` | `<variable name="id" type="long">` |
| `<enum>` | 枚举常量 | `name`, `value` | `<enum name="MAX" value="100">` |
| `<provider>` | 协议提供者 | `name`, `pvid` | `<provider name="auth" pvid="10">` |
| `<state>` | 连接状态 | `name` | `<state name="Login">` |
| `<service>` | 生成单元 | `name` | `<service name="game_server">` |
| `<manager>` | 网络管理器 | `name`, `type`, `initstate` | `<manager name="Client" type="server" initstate="State1">` |
| `<namespace>` | 命名空间 | `name` | `<namespace name="combat">` |

### 9.2 类型速查表

| XML 类型 | Java | C++ | 大小 | 说明 |
|---------|------|-----|------|------|
| `byte` | `byte` | `char` | 1 字节 | -128 ~ 127 |
| `short` | `short` | `short` | 2 字节 | -32768 ~ 32767 |
| `int` | `int` | `int` | 4 字节 | -2^31 ~ 2^31-1 |
| `long` | `long` | `int64_t` | 8 字节 | -2^63 ~ 2^63-1 |
| `float` | `float` | `float` | 4 字节 | 单精度浮点 |
| `octets` | `Octets` | `GNET::Octets` | 可变 | 二进制数据 |
| `string` | `String` | `GNET::Octets` | 可变 | UTF-16LE 编码 |
| `list<T>` | `LinkedList<T>` | `std::list<T>` | 可变 | 链表 |
| `vector<T>` | `ArrayList<T>` | `std::vector<T>` | 可变 | 动态数组 |
| `set<T>` | `HashSet<T>` | `std::set<T>` | 可变 | 无序集合 |
| `map<K,V>` | `HashMap<K,V>` | `std::map<K,V>` | 可变 | 键值对 |

### 9.3 Validator 速查表

| 规则 | 语法 | 示例 | 适用类型 |
|-----|------|------|---------|
| 闭区间 | `value=[min,max]` | `value=[1,100]` | byte, int, long, float |
| 开区间 | `value=(min,max)` | `value=(0,1)` | 同上 |
| 半开区间 | `value=[min,max)` | `value=[0,100)` | 同上 |
| 仅最小值 | `value=[min,)` | `value=[1,)` | 同上 |
| 仅最大值 | `value=(,max]` | `value=(,100]` | 同上 |
| 容量限制 | `capacity=max` | `capacity=50` | string, octets, list, vector, set, map |
| 组合验证 | `capacity=N;value=[a,b]` | `capacity=100;value=[1,1000]` | 集合类型 |
| Map Key | `key=[min,max]` | `key=[1,)` | map |
| Map Value | `value=[min,max]` | `value=[0,100]` | map |

### 9.4 常用命令速查

```bash
# 基本生成
java -jar rpcgen.jar protocols/game.xml

# 启用验证（反序列化时）
java -jar rpcgen.jar -validateUnmarshal protocols/game.xml

# 启用全验证（调试模式）
java -jar rpcgen.jar -validateMarshal -validateUnmarshal protocols/game.xml

# 查看帮助
java -jar rpcgen.jar -h

# 批量生成（脚本）
for file in protocols/*.xml; do
    java -jar rpcgen.jar "$file"
done
```

### 9.5 生成代码使用示例

**Java**：
```java
// 创建协议对象
CLogin login = new CLogin();
login.username = "player1";
login.password = "pass123";

// 序列化
OctetsStream os = new OctetsStream();
login.marshal(os);
byte[] data = os.getBytes();

// 反序列化
OctetsStream is = new OctetsStream(data);
CLogin recv = new CLogin();
recv.unmarshal(is);
```

**C++**：
```cpp
// 创建协议对象
auth::CLogin login;
login.username = "player1";
login.password = "pass123";

// 序列化
GNET::OctetsStream os;
login.marshal(os);

// 反序列化
GNET::OctetsStream is(data, len);
auth::CLogin recv;
recv.unmarshal(is);
```

---

## 10. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | rpcgen (RPC Generator) |
| **版本** | 见 Jar 文件时间戳 |
| **主要维护者** | 见项目 Git 提交历史（liuxinhua@locojoy.com） |
| **代码位置** | `server/tools/rpcgen/` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, XML (SAX/DOM), Ant |
| **支持语言** | Java, C++, ActionScript, JavaScript |

---

## 11. 联系方式

如有问题或建议，请通过以下方式联系：
- **原始作者**：liuxinhua@locojoy.com
- **项目维护**：提交 Issue 到项目仓库
- **游戏服务器团队**：查看项目 Wiki 获取更多文档

---

**注意事项**：
1. 本文档基于 `readme.txt` 和源代码分析生成，部分细节（如命令行参数）可能需根据实际实现调整
2. 协议定义需严格遵循 XML 规范，建议使用 XML 编辑器进行验证
3. 生成的代码仅供项目内部使用，不得用于其他商业用途
4. 修改协议定义后务必重新生成代码并完整测试

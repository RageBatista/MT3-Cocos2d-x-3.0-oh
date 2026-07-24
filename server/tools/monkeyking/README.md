# monkeyking - MT3 核心基础库

## 1. 工具概述

### 1.1 用途说明
monkeyking 是 MT3 游戏服务器的核心基础库，提供三大核心功能模块：

- **mkdb（文件数据库）**：轻量级事务性文件数据库，支持表操作、事务管理、缓存机制、持久化存储
- **mkio（网络通信引擎）**：高性能网络 I/O 引擎，基于 NIO Selector 实现异步事件驱动
- **mkgen（代码生成器）**：从 XML 配置自动生成 Java 数据结构代码（XBean、Table、Cache）

### 1.2 典型使用场景
- **游戏服务器开发**：作为核心数据库和网络引擎支撑游戏业务逻辑
- **代码生成**：从 mkdb.xml 自动生成数据表、实体类、缓存结构
- **数据持久化**：玩家数据、游戏配置、运行时状态的持久化存储
- **网络通信**：服务器间 RPC 调用、客户端连接管理

### 1.3 关键特性
- **事务支持**：完整的 ACID 事务机制（begin/commit/rollback/savepoint）
- **无外部依赖**：纯 Java 实现，仅依赖 JDK 标准库和 jio.jar
- **代码生成**：自动生成类型安全的数据访问代码
- **高性能缓存**：内置 LRU/ConcurrentMap 缓存策略
- **事件驱动网络**：基于 Java NIO 的高性能网络引擎
- **自动递增主键**：支持表的 autoIncrement 特性
- **外键约束**：支持表间 foreign key 关联
- **索引支持**：支持 unique 索引（secondary index）

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
monkeyking 位于 MT3 服务器架构的**基础设施层**，为所有游戏服务器提供底层支持：

```
┌─────────────────────────────────────────────────────────────┐
│         游戏业务逻辑层（Game Logic Layer）                  │
│  game_server / gate_server / zone_server / trans_server    │
└────────────────┬────────────────────────────────────────────┘
                 │ 依赖 monkeyking.jar
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              monkeyking 核心基础库                          │
│  ┌─────────────┬─────────────┬─────────────────────────┐   │
│  │   mkgen     │    mkdb     │         mkio            │   │
│  │ 代码生成器  │  文件数据库  │      网络引擎           │   │
│  │             │             │                         │   │
│  │ • XML解析   │ • 事务管理  │ • Selector 多路复用     │   │
│  │ • Java生成  │ • 表操作    │ • RPC 调用              │   │
│  │ • XBean     │ • 缓存      │ • 安全传输（压缩/加密） │   │
│  │ • Table     │ • 持久化    │ • 连接管理              │   │
│  └─────────────┴─────────────┴─────────────────────────┘   │
└────────────────┬────────────────────────────────────────────┘
                 │ JDK 1.6+
                 ↓
┌─────────────────────────────────────────────────────────────┐
│               Java 运行时环境 (JRE/JDK)                     │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **被依赖模块**（10+ 工具/服务器依赖此库）：
  - `game_server` - 游戏服务器核心
  - `jauthc` - 认证客户端工具
  - `calccap` - 容量计算工具
  - `xbrowse` - 数据库浏览工具
  - `newxmerge` - 数据合并工具
  - 其他所有服务器进程
- **依赖模块**：
  - `jio.jar` - Java I/O 工具库（位于 `../bin/jio.jar`）
- **数据流**：
  - 编译时：mkgen 读取 XML → 生成 Java 代码 → 业务代码编译
  - 运行时：业务逻辑 → mkdb API → 文件存储 / mkio → 网络传输

### 2.3 关键代码位置
| 功能模块 | 文件路径 | 关键类/方法 |
|---------|---------|----------|
| 代码生成器入口 | [src/mkgen/Main.java](src/mkgen/Main.java#L54-L127) | `Main.main()` |
| XML 配置解析 | [src/mkgen/Mkdb.java](src/mkgen/Mkdb.java) | `Mkdb.compile()` |
| 数据库核心 | [src/mkdb/Mkdb.java](src/mkdb/Mkdb.java#L16-L353) | `Mkdb.start()`, `Mkdb.stop()` |
| 事务管理 | [src/mkdb/Transaction.java](src/mkdb/Transaction.java#L19-L100) | `begin()`, `commit()`, `rollback()` |
| 表操作 | [src/mkdb/Table.java](src/mkdb/Table.java#L12-L36) | `Table`, `TTable` |
| 存储过程 | [src/mkdb/Procedure.java](src/mkdb/Procedure.java#L14-L100) | `Procedure.process()` |
| 网络引擎 | [src/mkio/Engine.java](src/mkio/Engine.java#L10-L219) | `Engine.open()`, `selector()` |
| RPC 基类 | [src/mkio/Rpc.java](src/mkio/Rpc.java) | RPC 协议定义 |
| 安全传输 | [src/mkio/security/](src/mkio/security/) | 压缩/加密/MD5/ARCFour |
| 构建配置 | [build.xml](build.xml) | Ant 构建脚本 |
| 配置示例 | [mkdb.xml](mkdb.xml) | 数据库 XML 配置 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**：JDK/JRE 1.6 及以上（推荐 JDK 8）
- **必需库文件**：
  - `jio.jar` - 位于 `../bin/jio.jar`（编译时依赖）
  - 运行时 monkeyking.jar 无外部依赖

### 3.2 构建时依赖
- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）
- **编码**：源代码使用 GBK 编码

### 3.3 构建步骤

#### Windows 环境
```batch
# 方式 1：使用 Ant 直接构建
ant clean dist

# 方式 2：构建并运行 mkgen 代码生成器
ant mkgen

# 方式 3：构建并安装到目标目录
ant install

# 输出文件：monkeyking.jar
```

#### Linux/macOS 环境
```bash
# 方式 1：使用 Ant 直接构建
ant clean dist

# 方式 2：构建并运行 mkgen 代码生成器
ant mkgen

# 方式 3：构建并安装到目标目录
ant install

# 输出文件：monkeyking.jar
```

#### 构建流程说明
构建脚本执行以下步骤（参见 [build.xml](build.xml)）：

1. **清理阶段**（clean）：删除旧的 `classes/` 目录
2. **初始化阶段**（init）：创建 `classes/` 编译输出目录
3. **编译阶段**（compile）：
   - 编译 `src/**/*.java` → `classes/`
   - 使用 GBK 编码
   - classpath 包含 `../bin/jio.jar`
   - 启用调试信息（lines, source）
   - 启用 unchecked 警告
4. **打包阶段**（dist）：
   - 生成 `monkeyking.jar`
   - 设置 Main-Class: `mkgen.Main`（用于代码生成）
   - 包含所有编译后的 class 文件
5. **代码生成**（mkgen，可选）：
   - 运行 `java -jar monkeyking.jar mkdb.xml -noverify`
   - 生成 XBean、Table 等数据结构代码
6. **安装阶段**（install，可选）：
   - 复制 jar 到 `../bin/`（工具共享库）
   - 复制 jar 到 `../../server/game_server/gs/lib/`（游戏服务器库）

### 3.4 构建参数说明
| 参数 | 说明 | 默认值 |
|-----|------|-------|
| `src` | 源代码目录 | `src/` |
| `build` | 编译输出目录 | `classes/` |
| `lib` | 外部库目录 | `../bin` |
| `gslib` | 游戏服务器库目录 | `../../server/game_server/gs/lib` |
| `monkeykingjar` | 输出 Jar 文件路径 | `./monkeyking.jar` |

---

## 4. mkgen - 代码生成器

### 4.1 功能说明
mkgen 从 XML 配置文件自动生成以下 Java 代码：
- **XBean**：数据实体类（对应 `<xbean>` 标签）
- **CBean**：可比较的 Bean（对应 `<cbean>` 标签，支持用作 Map key）
- **Table**：数据表类（对应 `<table>` 标签）
- **Cache**：缓存结构（对应 `<cache>` 标签）

### 4.2 命令行用法
```bash
java -jar monkeyking.jar [options] mkdb.xml

选项：
  -outputEncoding <encoding>  输出文件编码（默认 GBK）
  -output <dir>               输出目录（覆盖 XML 中的 mkgenOutput）
  -nowarn                     禁止警告信息
  -warn [cfo]                 选择警告类型：c=capacity, f=foreign, o=owner
  -noverify                   不生成 xbean 验证代码
  -transform                  数据转换模式
  -srcdb <dir>                转换源数据库目录
  -destdb <dir>               转换目标数据库目录
  -transformCheck             检查是否需要转换
  -explicitLockCheck [table1:table2]  生成显式锁检查代码
```

### 4.3 配置文件格式（mkdb.xml）

#### 基本结构
```xml
<?xml version="1.0" encoding="gbk"?>
<xdb
  mkgenOutput="../monkeyking/src"     <!-- 代码生成目录 -->
  trace="debug"                        <!-- 日志级别 -->
  corePoolSize="50"                    <!-- 线程池大小 -->
  dbhome="xdb"                         <!-- 数据库目录 -->
  flushPeriod="5000"                   <!-- 刷盘间隔（毫秒） -->
  checkpointPeriod="60000"             <!-- 检查点间隔（毫秒） -->
  >

  <!-- XBean 定义 -->
  <xbean name="Player">
    <variable name="id" type="long"/>
    <variable name="name" type="string" capacity="32"/>
    <variable name="level" type="int" default="1"/>
    <variable name="gold" type="long" default="0"/>
    <variable name="items" type="map" key="int" value="int" capacity="100"/>
  </xbean>

  <!-- Table 定义 -->
  <table name="player"
         key="long"
         value="Player"
         cacheCapacity="4096"
         autoIncrement="true"
         persistence="DB"/>

  <!-- Cache 定义 -->
  <cache name="playercache" key="long" capacity="10240">
    <cref ref="player.name"/>
    <cref ref="player.level"/>
  </cache>
</xdb>
```

#### 关键配置说明

**XDB 根节点属性**：
| 属性 | 说明 | 示例值 |
|-----|------|-------|
| `mkgenOutput` | 代码生成目录 | `../monkeyking/src` |
| `trace` | 日志级别 | `debug/info/warn/error` |
| `corePoolSize` | 线程池核心线程数 | `50` |
| `logpages` | 日志缓冲页数 | `4096` |
| `dbhome` | 数据库主目录 | `xdb` |
| `backupDir` | 备份目录 | `xbackup` |
| `flushPeriod` | 刷盘间隔（毫秒） | `5000` |
| `checkpointPeriod` | 检查点间隔（毫秒） | `60000` |

**XBean 数据类型**：
| 类型 | XML 声明 | Java 类型 | 说明 |
|-----|---------|----------|------|
| 整数 | `type="int"` | `int` | 32位整数 |
| 长整数 | `type="long"` | `long` | 64位整数 |
| 短整数 | `type="short"` | `short` | 16位整数 |
| 浮点 | `type="float"` | `float` | 单精度浮点 |
| 布尔 | `type="boolean"` | `boolean` | 布尔值 |
| 字符串 | `type="string" capacity="32"` | `String` | 需指定最大长度 |
| 二进制 | `type="binary" capacity="128"` | `byte[]` | 二进制数据 |
| Set | `type="set" value="int" capacity="100"` | `Set<Integer>` | 集合 |
| List | `type="list" value="Player" capacity="100"` | `List<Player>` | 列表 |
| Map | `type="map" key="int" value="string" capacity="100;key:32"` | `Map<Integer, String>` | 映射 |
| TreeMap | `type="treemap" key="int" value="Player"` | `TreeMap<Integer, Player>` | 有序映射 |
| 自定义 | `type="Player"` | `Player` | 引用其他 XBean |

**Table 关键属性**：
| 属性 | 说明 | 示例值 |
|-----|------|-------|
| `name` | 表名 | `player` |
| `key` | 主键类型 | `int/long/string/自定义CBean` |
| `value` | 值类型 | `Player/int/string` |
| `cacheCapacity` | 缓存容量 | `4096` |
| `persistence` | 持久化模式 | `DB`（磁盘）或 `MEMORY`（内存） |
| `autoIncrement` | 自动递增主键 | `true/false` |
| `foreign` | 外键约束 | `key:ftable;value:vtable` |
| `cacheClass` | 缓存实现类 | `mkdb.TTableCacheLRU` |

### 4.4 生成的代码结构
```
xgenoutput/                    # 生成代码根目录
├── xbean/                     # XBean 类（业务数据结构）
│   ├── Player.java
│   ├── Item.java
│   └── __/                    # 内部实现类
│       ├── Player.java
│       └── Item.java
├── xtable/                    # Table 类（数据表）
│   ├── Tplayer.java
│   └── _Tables_.java          # 表管理器（统一入口）
└── xcache/                    # Cache 类（缓存结构）
    └── PlayercacheCache.java
```

### 4.5 使用示例

#### 示例 1：定义玩家数据结构
```xml
<!-- mkdb.xml -->
<xbean name="PlayerData">
  <variable name="userId" type="long"/>
  <variable name="nickname" type="string" capacity="32"/>
  <variable name="level" type="int" default="1"/>
  <variable name="exp" type="long" default="0"/>
  <variable name="gold" type="long" default="0"/>
  <variable name="vip" type="int" default="0"/>
  <variable name="lastLoginTime" type="long"/>
  <variable name="inventory" type="map" key="int" value="int" capacity="200"/>
</xbean>

<table name="player_data"
       key="long"
       value="PlayerData"
       cacheCapacity="8192"
       autoIncrement="true"/>
```

**生成的业务代码使用**：
```java
// 创建玩家数据
PlayerData player = new PlayerData();
player.setUserId(10001L);
player.setNickname("张三");
player.setLevel(10);

// 保存到数据库
_Tables_.getInstance().player_data.insert(10001L, player);

// 查询玩家数据
PlayerData p = _Tables_.getInstance().player_data.get(10001L);

// 修改数据（事务中）
p.setLevel(11);
p.setGold(p.getGold() + 1000);
```

#### 示例 2：外键约束
```xml
<!-- 定义物品表 -->
<xbean name="Item">
  <variable name="itemId" type="int"/>
  <variable name="count" type="int"/>
</xbean>
<table name="items" key="int" value="Item" cacheCapacity="1024"/>

<!-- 玩家背包引用物品表 -->
<xbean name="Inventory">
  <variable name="items" type="set" value="int" capacity="200" foreign="items"/>
</xbean>
<table name="player_inventory" key="long" value="Inventory" foreign="key:player_data"/>
```

---

## 5. mkdb - 文件数据库引擎

### 5.1 核心概念

#### 5.1.1 架构组成
- **Tables**：所有表的管理器（`_Tables_.getInstance()`）
- **Table**：单个数据表（对应 XML 中的 `<table>`）
- **Transaction**：事务上下文（支持嵌套事务）
- **Procedure**：存储过程（业务逻辑执行单元）
- **Lockey**：锁对象（表+主键的唯一锁）
- **Storage**：存储引擎（文件读写）
- **Checkpoint**：检查点机制（定期持久化）

#### 5.1.2 数据持久化机制
```
内存缓存 → 日志写入 → 检查点刷盘 → 备份

1. 事务提交时，修改先写入内存日志（Log）
2. flushPeriod 到期，日志批量刷盘（Storage）
3. checkpointPeriod 到期，执行检查点（Checkpoint）
4. backupPeriod 到期，执行增量/全量备份
```

### 5.2 数据库 API

#### 5.2.1 初始化与启动
```java
import mkdb.*;

// 1. 加载配置
MkdbConf conf = new MkdbConf("mkdb.xml");
Mkdb.getInstance().setConf(conf);

// 2. 启动数据库
Mkdb.getInstance().start();  // 仅数据库
// 或
Mkdb.getInstance().start(Mkdb.NETWORK);  // 启动网络引擎
// 或
Mkdb.getInstance().start(Mkdb.UNIQNAME); // 启动唯一名服务

// 3. 关闭数据库
Mkdb.getInstance().stop();
```

#### 5.2.2 表操作（CRUD）
```java
import xtable._Tables_;

// 获取表实例
TTable<Long, PlayerData> playerTable = _Tables_.getInstance().player_data;

// 1. 插入（Insert）
PlayerData player = new PlayerData();
player.setNickname("张三");
playerTable.insert(10001L, player);

// 2. 查询（Select）
PlayerData p = playerTable.select(10001L);  // 无锁查询
PlayerData p2 = playerTable.get(10001L);    // 加锁查询（事务中）

// 3. 修改（Update）
// 方式 1：直接修改（事务中自动加锁）
PlayerData p = playerTable.get(10001L);
p.setLevel(p.getLevel() + 1);

// 方式 2：替换整个对象
PlayerData newPlayer = new PlayerData();
newPlayer.setNickname("李四");
playerTable.insert(10001L, newPlayer);  // 覆盖旧数据

// 4. 删除（Delete）
boolean success = playerTable.remove(10001L);

// 5. 批量遍历（Walk）
playerTable.walk((key, value) -> {
    System.out.println("玩家ID: " + key + ", 昵称: " + value.getNickname());
    return true;  // 返回 false 终止遍历
});
```

#### 5.2.3 事务操作
```java
// 方式 1：手动事务管理
Transaction txn = Transaction.current();
txn.begin();
try {
    // 业务逻辑
    PlayerData p = playerTable.get(10001L);
    p.setGold(p.getGold() + 1000);
    txn.commit();
} catch (Exception e) {
    txn.rollback(0);  // 回滚到事务开始
    throw e;
}

// 方式 2：使用 Procedure（推荐）
public class AddGoldProcedure extends Procedure {
    private final long userId;
    private final long amount;

    public AddGoldProcedure(long userId, long amount) {
        this.userId = userId;
        this.amount = amount;
    }

    @Override
    protected boolean process() {
        PlayerData player = _Tables_.getInstance().player_data.get(userId);
        if (player == null) return false;

        player.setGold(player.getGold() + amount);
        return true;
    }
}

// 提交执行
Mkdb.executor().execute(new AddGoldProcedure(10001L, 1000L));
```

#### 5.2.4 嵌套事务与保存点
```java
Transaction txn = Transaction.current();
txn.begin();
try {
    // 外层事务
    PlayerData p = playerTable.get(10001L);
    p.setGold(p.getGold() + 1000);

    // 创建保存点
    int savepoint = txn.savepoint();
    txn.begin();  // 嵌套事务
    try {
        // 内层事务
        p.setLevel(p.getLevel() + 1);
        txn.commit();
    } catch (Exception e) {
        txn.rollback(savepoint);  // 回滚到保存点
    }

    txn.commit();  // 提交外层事务
} catch (Exception e) {
    txn.rollback(0);
}
```

#### 5.2.5 锁管理
```java
import mkdb.*;

// 1. 自动锁（通过 get 获取记录时自动加锁）
PlayerData p = playerTable.get(10001L);  // 自动加锁

// 2. 手动锁（批量操作时预先加锁）
Lockey lock = Lockeys.get(playerTable, 10001L);
Transaction.current().add(lock);  // 手动加锁

// 3. 批量锁
List<Long> userIds = Arrays.asList(10001L, 10002L, 10003L);
for (Long id : userIds) {
    Transaction.current().add(Lockeys.get(playerTable, id));
}

// 4. Procedure 中的锁管理
public class TransferGoldProcedure extends Procedure {
    @Override
    protected boolean process() {
        // 使用 Locks 辅助类管理锁
        Locks locks = new Locks();
        locks.add(playerTable, fromUserId);
        locks.add(playerTable, toUserId);
        locks.lock();  // 批量加锁（自动排序防止死锁）

        // 业务逻辑
        PlayerData from = playerTable.get(fromUserId);
        PlayerData to = playerTable.get(toUserId);
        from.setGold(from.getGold() - amount);
        to.setGold(to.getGold() + amount);
        return true;
    }
}
```

### 5.3 高级特性

#### 5.3.1 自动递增主键
```xml
<table name="player" key="long" value="PlayerData" autoIncrement="true"/>
```
```java
// 插入时自动分配主键
PlayerData player = new PlayerData();
Long autoId = playerTable.add(player);  // 返回自动分配的 ID
```

#### 5.3.2 外键约束
```xml
<!-- 玩家背包的物品必须存在于物品表 -->
<xbean name="Inventory">
  <variable name="items" type="set" value="int" foreign="items"/>
</xbean>
```
```java
// 插入时会自动验证外键（items 表中必须存在该物品）
Inventory inv = new Inventory();
inv.getItems().add(1001);  // 如果 items 表不存在 1001，会抛出异常
```

#### 5.3.3 缓存策略
```xml
<!-- LRU 缓存（默认） -->
<table name="player" cacheCapacity="4096"/>

<!-- 无缓存 -->
<table name="logs" cacheClass="mkdb.TTableCacheNull"/>

<!-- ConcurrentMap 缓存 -->
<table name="config" cacheClass="mkdb.TTableCacheConcurrentMap"/>
```

#### 5.3.4 内存表 vs 持久化表
```xml
<!-- 持久化表（默认，数据存储在磁盘） -->
<table name="player" persistence="DB"/>

<!-- 内存表（仅内存存储，重启丢失） -->
<table name="session" persistence="MEMORY"/>
```

---

## 6. mkio - 网络引擎

### 6.1 核心架构
```
┌─────────────────────────────────────────┐
│          业务 RPC 处理器                 │
│   (实现 Rpc.Request / Rpc.Response)     │
└──────────────┬──────────────────────────┘
               │ 调用
               ↓
┌─────────────────────────────────────────┐
│           mkio.Engine                   │
│  ┌─────────────────────────────────┐   │
│  │   SelectorThread[] (多路复用)   │   │
│  │   - NIO Selector                │   │
│  │   - 事件驱动                     │   │
│  │   - 负载均衡                     │   │
│  └─────────────────────────────────┘   │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│         MkioConf (配置管理)              │
│  - Manager (连接管理器)                  │
│  - Coder (编解码器)                      │
│  - Security (安全传输)                   │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│       TCP/IP Socket 网络传输             │
└─────────────────────────────────────────┘
```

### 6.2 网络引擎 API

#### 6.2.1 启动与关闭
```java
import mkio.*;

// 1. 注册配置（在 Engine.open() 之前）
MkioConf conf = new MkioConf("MyService");
// ... 配置 conf
Engine.getInstance().register(conf);

// 2. 启动网络引擎
Engine.getInstance().open();  // 默认 4 个 Selector 线程
// 或
Engine.getInstance().open(8); // 指定 8 个 Selector 线程（最多 32）

// 3. 关闭引擎
Engine.getInstance().close();
```

#### 6.2.2 RPC 定义
```java
import mkio.Rpc;

// 1. 定义 RPC 请求（客户端 → 服务器）
public class LoginRequest extends Rpc.Request<LoginRequest, LoginResponse> {
    public String username;
    public String password;

    @Override
    public void process() {
        // 服务器端处理逻辑
        if (authenticate(username, password)) {
            response = new LoginResponse();
            response.success = true;
            response.sessionId = generateSessionId();
        } else {
            response = new LoginResponse();
            response.success = false;
        }
    }
}

// 2. 定义 RPC 响应（服务器 → 客户端）
public class LoginResponse extends Rpc.Response<LoginRequest, LoginResponse> {
    public boolean success;
    public String sessionId;

    @Override
    public void onClient(LoginRequest req) {
        // 客户端收到响应的回调
        if (success) {
            System.out.println("登录成功，SessionID: " + sessionId);
        } else {
            System.out.println("登录失败");
        }
    }
}
```

#### 6.2.3 安全传输
```java
import mkio.security.*;

// 1. 压缩 + 加密（ARCFour）
Security security = new CompressARCFourSecurity("mySecretKey");

// 2. 仅压缩
Security security = new Compress();

// 3. 仅加密（ARCFour）
Security security = new ARCFourSecurity("mySecretKey");

// 4. MD5 哈希验证
Security security = new HmacMd5Hash("mySecretKey");

// 5. 无安全措施
Security security = new NullSecurity();
```

### 6.3 配置示例（mkdb.xml）
```xml
<UniqNameConf localId="0">
  <XioConf name="mkdb.util.UniqName">
    <Manager maxSize="1" name="Client">
      <Coder>
        <Rpc class="mkdb.util.UniqName$Allocate"/>
        <Rpc class="mkdb.util.UniqName$Confirm"/>
      </Coder>
      <Connector
        inputBufferSize="131072"
        outputBufferSize="131072"
        receiveBufferSize="131072"
        sendBufferSize="131072"
        remoteIp="127.0.0.1"
        remotePort="22200"
        tcpNoDelay="false"/>
    </Manager>
  </XioConf>
</UniqNameConf>
```

---

## 7. 输入输出规范

### 7.1 标准输入格式
- **mkgen**：读取 XML 配置文件（`mkdb.xml`）
- **mkdb**：读取 MkdbConf 配置（通过 XML 或代码初始化）
- **mkio**：读取 MkioConf 配置（通过 XML 注册）

### 7.2 标准输出格式

#### mkgen 代码生成器
| 输出类型 | 路径 | 示例 |
|---------|------|------|
| XBean 类 | `{mkgenOutput}/xbean/Player.java` | 业务数据结构 |
| XBean 内部实现 | `{mkgenOutput}/xbean/__/Player.java` | 序列化/反序列化 |
| Table 类 | `{mkgenOutput}/xtable/Tplayer.java` | 数据表操作 |
| 表管理器 | `{mkgenOutput}/xtable/_Tables_.java` | 统一表入口 |
| Cache 类 | `{mkgenOutput}/xcache/MyCache.java` | 缓存结构 |

#### mkdb 数据库文件
| 文件类型 | 路径 | 说明 |
|---------|------|------|
| 数据文件 | `{dbhome}/table/{tablename}/` | 表数据存储 |
| 日志文件 | `{dbhome}/log/` | 事务日志 |
| 锁文件 | `{dbhome}/mkdb.inuse` | 防止多实例同时启动 |
| 元数据 | `{dbhome}/metadata.xml` | 数据库结构元数据 |
| 备份文件 | `{backupDir}/` | 增量/全量备份 |

#### mkio 网络传输
- **二进制协议**：自定义二进制 RPC 协议（支持压缩/加密）
- **日志输出**：通过 `mkdb.Trace` 输出到 `{dbhome}/trace.log`

### 7.3 错误代码说明
| 异常类型 | 说明 | 处理建议 |
|---------|------|---------|
| `XError` | 数据库核心错误 | 严重错误，需停止服务 |
| `XError("mkdb is still in active use")` | 多实例同时启动 | 删除 `mkdb.inuse` 或检查其他进程 |
| `RuntimeException("Compare metadata fail")` | 数据库结构不匹配 | 运行 xtransform 转换工具 |
| `IOError` | 网络 I/O 错误 | 检查网络连接 |
| `MarshalError` | 序列化/反序列化错误 | 检查数据结构定义 |

---

## 8. 注意事项

### 8.1 已知限制

#### 功能限制
- **单实例**：同一数据库目录不支持多进程同时访问（通过 `mkdb.inuse` 文件防护）
- **GBK 编码**：源代码和 XML 配置必须使用 GBK 编码
- **Java 版本**：最低 JDK 1.6，推荐 JDK 8（不支持 Java 9+ 模块系统）
- **文件系统**：依赖本地文件系统，不支持分布式存储

#### 性能限制
- **单表缓存容量**：建议不超过 100 万条记录
- **单个 XBean 大小**：建议不超过 1MB（受 binary/string capacity 限制）
- **并发线程数**：受 `corePoolSize` 限制（默认 50）

### 8.2 性能考虑

#### 缓存策略选择
| 场景 | 推荐缓存 | 原因 |
|-----|---------|------|
| 热点数据（玩家数据） | `TTableCacheLRU` | 自动淘汰冷数据 |
| 全量缓存（配置表） | `TTableCacheConcurrentMap` | 高并发读性能 |
| 日志表 | `TTableCacheNull` | 无需缓存，减少内存 |

#### 事务优化
```java
// ❌ 错误：频繁的小事务（性能差）
for (int i = 0; i < 1000; i++) {
    Transaction txn = Transaction.current();
    txn.begin();
    playerTable.get(i).setGold(100);
    txn.commit();
}

// ✅ 正确：批量事务（性能好）
Transaction txn = Transaction.current();
txn.begin();
for (int i = 0; i < 1000; i++) {
    playerTable.get(i).setGold(100);
}
txn.commit();
```

#### 锁粒度控制
```java
// ❌ 错误：表级锁（阻塞其他玩家）
synchronized (playerTable) {
    PlayerData p = playerTable.get(10001L);
    p.setGold(p.getGold() + 1000);
}

// ✅ 正确：记录级锁（仅锁定单个玩家）
Transaction.current().add(Lockeys.get(playerTable, 10001L));
PlayerData p = playerTable.get(10001L);
p.setGold(p.getGold() + 1000);
```

### 8.3 安全注意事项

#### 数据完整性
- **定期备份**：配置 `backupIncPeriod` 和 `backupFullPeriod`
- **检查点机制**：确保 `checkpointPeriod` 合理设置（默认 60 秒）
- **元数据验证**：启动时自动检查数据库结构，不匹配时拒绝启动

#### 外键约束
```xml
<!-- 严格模式：插入时验证外键存在性 -->
<variable name="itemIds" type="set" value="int" foreign="items"/>

<!-- 警告模式：仅警告不报错 -->
<variable name="itemIds" type="set" value="int" foreign="warn"/>
```

#### 并发安全
- **避免死锁**：使用 `Procedure.Locks` 自动排序加锁
- **事务超时**：配置 `maxExecutionTime` 防止长事务阻塞
- **锁泄漏检测**：定期检查 `Angel` 线程日志

### 8.4 故障排查指南

#### 问题 1：构建失败 - "找不到 jio.jar"
**症状**：
```
BUILD FAILED
compile: Cannot find jio.jar
```
**解决方案**：
```bash
# 检查 jio.jar 是否存在
ls ../bin/jio.jar

# 如果不存在，从其他工具复制或重新构建
cp ../../server/game_server/gs/lib/jio.jar ../bin/
```

#### 问题 2：代码生成失败 - "编码错误"
**症状**：
```
Exception in thread "main" java.nio.charset.MalformedInputException
```
**解决方案**：
```bash
# 确保 mkdb.xml 保存为 GBK 编码
# 或强制指定输出编码
java -jar monkeyking.jar -outputEncoding UTF-8 mkdb.xml
```

#### 问题 3：数据库启动失败 - "mkdb is still in active use"
**症状**：
```
XError: mkdb is still in active use(never use simultaneously)
```
**解决方案**：
```bash
# 1. 检查是否有其他进程占用数据库
ps aux | grep java

# 2. 确认无其他进程后删除锁文件
rm xdb/mkdb.inuse

# 3. 重新启动
```

#### 问题 4：数据库启动失败 - "Compare metadata fail"
**症状**：
```
RuntimeException: Compare metadata fail, should run xtransform?
```
**解决方案**：
```bash
# 数据库结构已变更，需要运行转换工具
# 1. 备份现有数据
cp -r xdb xdb.backup

# 2. 运行转换工具（假设存在）
java -jar monkeyking.jar -transform -srcdb xdb.backup -destdb xdb mkdb.xml

# 3. 重新启动
```

#### 问题 5：网络引擎启动失败
**症状**：
```
java.net.BindException: Address already in use
```
**解决方案**：
```bash
# 检查端口占用
netstat -anp | grep 22200

# 修改配置文件中的端口
# 或停止占用端口的进程
kill -9 <pid>
```

#### 问题 6：内存溢出 - OutOfMemoryError
**症状**：
```
java.lang.OutOfMemoryError: Java heap space
```
**解决方案**：
```bash
# 1. 增加 JVM 堆内存
java -Xms2g -Xmx4g -jar your-server.jar

# 2. 检查缓存容量配置是否过大
# 修改 mkdb.xml 中的 cacheCapacity

# 3. 启用 GC 日志分析
java -Xms2g -Xmx4g -XX:+PrintGCDetails -XX:+PrintGCDateStamps \
     -Xloggc:gc.log -jar your-server.jar
```

---

## 9. 扩展与改进

### 9.1 当前未使用的功能
- **JMX Server**（注释代码）：
  - 文件：`build.xml` 第 46-55 行
  - 用途：远程 JMX 管理代理
  - 激活：取消注释 `<target name="jmxserver">` 并构建

### 9.2 推荐改进方向

#### 短期优化（1-2 周）
1. **编码支持**：支持 UTF-8 编码，淘汰 GBK
2. **文档补充**：增加更多代码示例和最佳实践
3. **单元测试**：补充核心模块单元测试

#### 中期优化（1-2 个月）
4. **性能监控**：集成 Metrics/Prometheus 监控
5. **热更新**：支持 XBean 结构的热更新（无需重启）
6. **分布式支持**：支持多节点数据同步
7. **SQL 兼容层**：提供类 SQL 查询接口

#### 长期优化（3-6 个月）
8. **存储引擎**：支持 RocksDB/LevelDB 后端存储
9. **分布式事务**：支持跨节点的 2PC 事务
10. **流式处理**：支持实时数据流处理（类似 Kafka）
11. **可观测性**：集成 OpenTelemetry 追踪

### 9.3 参考资料
- XML Schema 定义：查看 `mkdb.xml` 注释了解所有配置选项
- 测试用例：参考 `mkdb.xml` 中的测试表定义（`listlistenertest`, `cachetest` 等）
- 网络配置：参考 `UniqNameConf` 配置示例

---

## 10. 快速参考

### 10.1 常用命令速查表

```bash
# 构建 monkeyking.jar
ant clean dist

# 运行代码生成器
java -jar monkeyking.jar mkdb.xml -noverify

# 指定输出目录
java -jar monkeyking.jar -output ../src mkdb.xml

# 数据转换
java -jar monkeyking.jar -transform -srcdb old_db -destdb new_db mkdb.xml

# 安装到系统库
ant install
```

### 10.2 常用 API 速查

```java
// === 数据库初始化 ===
Mkdb.getInstance().setConf(new MkdbConf("mkdb.xml"));
Mkdb.getInstance().start();

// === 表操作 ===
TTable<Long, Player> t = _Tables_.getInstance().player;
t.insert(1L, player);           // 插入
Player p = t.get(1L);           // 查询（加锁）
Player p2 = t.select(1L);       // 查询（不加锁）
t.remove(1L);                   // 删除
t.walk((k, v) -> true);         // 遍历

// === 事务管理 ===
Transaction txn = Transaction.current();
txn.begin();
int sp = txn.savepoint();
txn.rollback(sp);
txn.commit();

// === 存储过程 ===
Mkdb.executor().execute(new MyProcedure());

// === 网络引擎 ===
Engine.getInstance().open(4);
Engine.getInstance().close();
```

### 10.3 配置速查

```xml
<!-- 最小化配置 -->
<xdb mkgenOutput="src" dbhome="xdb">
  <xbean name="Data">
    <variable name="id" type="int"/>
  </xbean>
  <table name="mytable" key="int" value="Data" cacheCapacity="1024"/>
</xdb>
```

### 10.4 故障排查速查

| 问题 | 检查项 | 命令 |
|-----|-------|------|
| 构建失败 | jio.jar 是否存在 | `ls ../bin/jio.jar` |
| 编码错误 | XML 文件编码 | `file -i mkdb.xml` |
| 启动失败 | 锁文件存在 | `rm xdb/mkdb.inuse` |
| 结构不匹配 | 元数据变更 | 运行 xtransform |
| 端口占用 | 端口冲突 | `netstat -anp \| grep 22200` |
| 内存溢出 | 堆内存不足 | `java -Xmx4g ...` |

---

## 11. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | monkeyking (MT3 Core Library) |
| **版本** | 见最新 Jar 文件时间戳 |
| **主要模块** | mkgen (代码生成) + mkdb (数据库) + mkio (网络) |
| **主要维护者** | 见项目 Git 提交历史 |
| **代码位置** | `server/tools/monkeyking/` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, Ant, NIO |
| **被依赖模块** | 10+ 服务器/工具 |

---

## 12. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器架构团队
- 查看项目 Wiki 获取更多文档

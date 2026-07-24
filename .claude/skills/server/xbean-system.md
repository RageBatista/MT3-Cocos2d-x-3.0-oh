---
name: xbean-system
version: 1.5.0
priority: high
category: server
description: |
  MT3 xbean数据配置系统技能。涵盖XML配置定义、代码生成流程、配置热更新机制。
  触发词: xbean, 配置, 数据表, XML, Bean, Excel, 配置表, 热更新, genxdb, XBean, TableManager, DataConfig
dependencies:
  - java-development
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 12000
---

# xbean 数据系统技能 (MT3 服务器端)

**版本**: v1.5.0
**最后更新**: 2026-04-11

---

## 技能目标

### 初级 (1周)
- 理解 xbean 框架架构和基本概念
- 能够阅读和理解 xbean 定义文件
- 能够使用基本的数据读写 API
- 理解表 (table) 和实体 (xbean) 的关系

### 中级 (2-3周)
- 能够定义新的 xbean 数据结构
- 能够编写事务处理 (Procedure)
- 理解缓存机制和配置优化
- 能够处理数据迁移和升级

### 高级 (4周+)
- 能够设计复杂的数据模型
- 能够优化数据库性能
- 理解 XDB 底层存储机制
- 能够排查数据一致性问题

---

## xbean 框架架构

### 架构概览

```
┌─────────────────────────────────────────────────────────┐
│                    xbean 框架架构                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐    ┌─────────────┐                    │
│  │   xbean     │    │    Table    │                    │
│  │  Definition │ →  │   Schema    │                    │
│  │   (.xml)    │    │  (生成代码)  │                    │
│  └─────────────┘    └──────┬──────┘                    │
│                            │                            │
│  ┌─────────────┐    ┌──────▼──────┐                    │
│  │  Procedure  │ ←  │   Cache     │                    │
│  │  (事务处理)  │    │   Layer     │                    │
│  └─────────────┘    └──────┬──────┘                    │
│                            │                            │
│  ┌─────────────────────────▼───────────────────────┐   │
│  │                 XDB 文件数据库                    │   │
│  │           (B+树索引 + 日志 + 检查点)              │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 核心组件

| 组件 | 职责 | 说明 | 数量统计 |
|------|------|------|----------|
| **xbean** | 数据实体定义 | 类似 ORM 中的 Entity | **300+ 接口** |
| **xtable** | 数据表映射 | key-value 存储结构 | **286+ 类** |
| **Procedure** | 事务处理 | 保证数据一致性 | **300+ 子类** |
| **Cache** | 数据缓存 | LRU 缓存策略 | - |
| **XDB** | 持久化引擎 | 文件数据库 | - |

> **数据来源**: 代码分析报告 [`03-服务器端Java代码分析.md`](../../../docs/09-历史归档/文档审计/2026-03-06-服务器端Java代码分析.md)

---

## xbean 定义语法

### 基本结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xdb mkgenOutput="src"
     trace="debug"
     corePoolSize="5"
     procPoolSize="20"
     dbhome="mkdb"
     cacheCapacity="10240">

    <!-- xbean 实体定义 -->
    <xbean name="EntityName">
        <variable name="fieldName" type="dataType"/>
    </xbean>

    <!-- 数据表定义 -->
    <table name="tableName"
           key="keyType"
           value="EntityName"
           cacheCapacity="1024"/>

</xdb>
```

### 支持的数据类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `int` | 32位整数 | `<variable name="id" type="int"/>` |
| `long` | 64位整数 | `<variable name="money" type="long"/>` |
| `float` | 单精度浮点 | `<variable name="speed" type="float"/>` |
| `double` | 双精度浮点 | `<variable name="rate" type="double"/>` |
| `boolean` | 布尔值 | `<variable name="active" type="boolean"/>` |
| `string` | 字符串 | `<variable name="name" type="string"/>` |
| `binary` | 二进制数据 | `<variable name="data" type="binary"/>` |

### 复杂数据类型

```xml
<!-- 列表 (List) -->
<variable name="skills" type="list" value="int"/>
<variable name="items" type="vector" value="Item"/>

<!-- 映射 (Map) -->
<variable name="attrs" type="map" key="int" value="long"/>
<variable name="bags" type="map" key="int" value="Bag" capacity="8"/>

<!-- 集合 (Set) -->
<variable name="friends" type="set" value="long"/>

<!-- 嵌套 xbean -->
<variable name="equipment" type="EquipInfo"/>
```

---

## 实际项目示例

### 物品系统 (Item)

```xml
<!-- 物品实体定义 -->
<xbean name="Item">
    <variable name="id" type="int"/>           <!-- 物品模板ID -->
    <variable name="flags" type="int"/>        <!-- 物品标志位 -->
    <variable name="position" type="int" default="-1"/>  <!-- 背包位置 -->
    <variable name="number" type="int"/>       <!-- 数量 -->
    <variable name="timeout" type="long" default="0"/>   <!-- 到期时间 -->
    <variable name="uniqueid" type="long"/>    <!-- 唯一ID -->
    <variable name="typeid" type="int" default="-1"/>    <!-- 物品类型 -->
</xbean>

<!-- 背包实体定义 -->
<xbean name="Bag">
    <variable name="currency" type="map" key="int" value="long"/>  <!-- 货币 -->
    <variable name="capacity" type="int"/>     <!-- 容量 -->
    <variable name="nextid" type="int"/>       <!-- 下一个槽位ID -->
    <variable name="items" type="map" key="int" value="Item"/>     <!-- 物品列表 -->
    <variable name="locked" type="int" default="0"/>  <!-- 锁定状态 -->
</xbean>

<!-- 背包表定义 -->
<table name="bag"
       key="long"
       value="Bag"
       foreign="key:properties"
       cacheCapacity="7024"
       cachehigh="512"
       cachelow="256"
       lock="rolelock"/>
```

### 用户系统 (User)

```xml
<!-- 用户实体定义 -->
<xbean name="User">
    <variable name="prevLoginRoleid" type="long"/>    <!-- 上次登录角色 -->
    <variable name="idlist" type="vector" value="long"/>  <!-- 角色列表 -->
    <variable name="createtime" type="long"/>         <!-- 创建时间 -->
    <variable name="isfirst" type="int" default="0"/> <!-- 是否首次登录 -->
</xbean>

<!-- 用户表定义 -->
<table name="user"
       key="int"
       value="User"
       cacheCapacity="1024"
       cachehigh="512"
       cachelow="256"
       lock="userlock"/>
```

---

## 📊 MT3 实际数据表列表

> **数据来源**: 代码分析报告 [`03-服务器端Java代码分析.md`](../../../docs/09-历史归档/文档审计/2026-03-06-服务器端Java代码分析.md)

### 核心数据表（20+ 个）

| 表名 | 键类型 | 值类型 | 说明 |
|------|--------|--------|------|
| bag | long | Bag | 背包 |
| depot | long | Bag | 仓库 |
| equip | long | Bag | 装备栏 |
| temp | long | Bag | 临时背包 |
| questbag | long | Bag | 任务背包 |
| bagtimelock | long | BagTimeLock | 背包时间锁 |
| itemrecyclebin | long | DiscardItem | 物品回收站 |
| petrecyclebin | long | DiscardPet | 宠物回收站 |
| uniquepets | long | UniquePet | 宠物唯一信息 |
| itemrecover | long | Itemrecoverlist | 物品找回 |
| petrecover | long | Petrecoverlist | 宠物找回 |
| user | int | User | 用户信息 |
| userdeviceinfotab | int | UserDeviceInfo | 用户设备信息 |
| auuserinfo | int | AUUserInfo | AU用户信息 |
| yingyongbaoinfos | int | YingYongBao | 应用宝信息 |
| yybfushi | int | YybFushiNums | 应用宝符石 |
| properties | long | Properties | 角色属性 |

### Properties 角色属性 xbean（完整定义）

```xml
<xbean name="Properties">
    <!-- 基础信息 -->
    <variable name="rolename" type="string"/> 角色名
    <variable name="userid" type="int"/> 账号ID
    <variable name="level" type="int"/> 等级
    <variable name="exp" type="long"/> 经验
    <variable name="school" type="int"/> 门派
    
    <!-- 战斗属性 -->
    <variable name="title" type="int" default="-1"/> 称谓
    <variable name="hp" type="int"/> 气血
    <variable name="uplimithp" type="int"/> 气血上限
    <variable name="wound" type="int"/> 伤
    <variable name="mp" type="int"/> 法力
    <variable name="sp" type="int" default="0"/> 怒气
    
    <!-- 位置信息 -->
    <variable name="sceneid" type="long"/> 场景ID
    <variable name="posx" type="int"/> 坐标x
    <variable name="posy" type="int"/> 坐标y
    <variable name="posz" type="int"/> 坐标z
    
    <!-- 宠物相关 -->
    <variable name="fightpetkey" type="int" default="-1"/> 战斗宠物
    <variable name="showpetkey" type="int"/> 展示宠物
    
    <!-- 公会相关 -->
    <variable name="clanKey" type="long" default="-1"/> 公会key
    
    <!-- 时间相关 -->
    <variable name="onlineTime" type="long" default="-1"/> 上次登录时间
    <variable name="offlineTime" type="long" default="-1"/> 上次离线时间
    <variable name="createtime" type="long"/> 创建时间
    
    <!-- VIP相关 -->
    <variable name="vipLevel" type="int"/> VIP等级
    <variable name="energy" type="int"/> 活力
    
    <!-- 评分相关 -->
    <variable name="rolezonghemaxscore" type="int"/> 综合实力最高评分
    <variable name="skillscore" type="int"/> 技能评分
    <variable name="petscore" type="int"/> 最强单宠物评分
    <variable name="equipscore" type="int"/> 装备评分
</xbean>
```

### Procedure 事务处理（300+ 个子类）

> 代码中发现的 Procedure 子类数量：**300+ 个**

主要 Procedure 类命名模式：

| 前缀 | 说明 | 示例 |
|------|------|------|
| P | 普通事务处理 | PAddExpProc, PLevelUpProc |
| C | 客户端请求处理 | CEnterWorld, CCreateRole |
| S | 服务器响应 | SRoleList, SEnterWorld |
| D | 数据库操作 | DPGiveItem |

典型 Procedure 实现：

```java
public class PAfterEnterWorld extends Procedure {
    @Override
    protected boolean process() {
        // 事务处理逻辑
        // 1. 获取数据
        // 2. 修改数据
        // 3. 返回 true 提交事务
        return true;
    }
}
```

---

## 表配置详解

### 表属性

| 属性 | 说明 | 示例 |
|------|------|------|
| `name` | 表名 | `name="bag"` |
| `key` | 主键类型 | `key="long"` |
| `value` | 值类型 (xbean) | `value="Bag"` |
| `cacheCapacity` | 缓存容量 | `cacheCapacity="10240"` |
| `cachehigh` | 缓存高水位 | `cachehigh="512"` |
| `cachelow` | 缓存低水位 | `cachelow="256"` |
| `lock` | 锁策略 | `lock="rolelock"` |
| `persistence` | 持久化策略 | `persistence="MEMORY"` |
| `foreign` | 外键关联 | `foreign="key:properties"` |

### 持久化策略

```xml
<!-- 持久化到磁盘 (默认) -->
<table name="bag" key="long" value="Bag"/>

<!-- 仅内存 (重启丢失) -->
<table name="cache" key="long" value="TempData" persistence="MEMORY"/>
```

### 锁策略

```xml
<!-- 角色级别锁 -->
<table name="bag" key="long" value="Bag" lock="rolelock"/>

<!-- 用户级别锁 -->
<table name="user" key="int" value="User" lock="userlock"/>

<!-- 全局锁 (性能较差) -->
<table name="global" key="int" value="Config" lock="global"/>
```

---

## 生成的代码使用

### 代码生成

```bash
# 进入游戏服务器目录
cd server/server/game_server

# 生成 xbean 代码
ant genxdb

# 生成的代码位于:
# gs/src/xbean/ - xbean 实体类
# gs/src/xtable/ - 表访问类
```

### 基本 CRUD 操作

```java
import xtable.Bag;
import xbean.Bag;

// 获取表实例
Bag bagTable = xtable.Bag.get();

// 读取数据
xbean.Bag bag = bagTable.select(roleId);
if (bag != null) {
    int capacity = bag.getCapacity();
    Map<Integer, xbean.Item> items = bag.getItems();
}

// 插入数据
xbean.Bag newBag = new xbean.Bag();
newBag.setCapacity(100);
bagTable.insert(roleId, newBag);

// 更新数据 (需要在 Procedure 中)
bagTable.update(roleId, bag -> {
    bag.setCapacity(200);
    return true;
});

// 删除数据
bagTable.delete(roleId);
```

### 使用 Procedure (事务)

```java
import xdb.Procedure;

// 定义事务处理
public class AddItemProcedure extends Procedure {
    private long roleId;
    private int itemId;
    private int count;

    public AddItemProcedure(long roleId, int itemId, int count) {
        this.roleId = roleId;
        this.itemId = itemId;
        this.count = count;
    }

    @Override
    protected boolean process() {
        // 获取背包
        xbean.Bag bag = xtable.Bag.get().select(roleId);
        if (bag == null) {
            return false;
        }

        // 检查容量
        if (bag.getItems().size() >= bag.getCapacity()) {
            return false;  // 回滚事务
        }

        // 添加物品
        xbean.Item item = new xbean.Item();
        item.setId(itemId);
        item.setNumber(count);
        item.setPosition(bag.getNextid());

        bag.getItems().put(bag.getNextid(), item);
        bag.setNextid(bag.getNextid() + 1);

        return true;  // 提交事务
    }
}

// 执行事务
AddItemProcedure proc = new AddItemProcedure(roleId, 1001, 10);
boolean success = proc.call();
```

---

## 缓存机制

### 缓存配置

```xml
<table name="bag"
       key="long"
       value="Bag"
       cacheCapacity="10240"   <!-- 最大缓存条目数 -->
       cachehigh="512"         <!-- 高水位阈值 -->
       cachelow="256"/>        <!-- 低水位阈值 -->
```

### 缓存行为

```
数据访问流程:
1. 检查缓存是否存在
2. 缓存命中 → 直接返回
3. 缓存未命中 → 从 XDB 加载 → 放入缓存 → 返回

缓存淘汰策略 (LRU):
- 缓存达到 cachehigh 时触发淘汰
- 淘汰至 cachelow 水位
- 脏数据先写回 XDB
```

### 缓存预热

```java
// 服务器启动时预热缓存
public void warmupCache() {
    // 加载热点数据
    List<Long> activeRoles = getActiveRoleIds();
    for (Long roleId : activeRoles) {
        xtable.Bag.get().select(roleId);  // 触发缓存加载
    }
}
```

---

## 常见问题

### 1. 数据不一致

```
问题: 多个线程同时修改同一数据导致不一致

解决:
1. 使用 Procedure 包装所有写操作
2. 配置正确的 lock 策略
3. 避免在 Procedure 外修改 xbean 对象
```

### 2. 缓存穿透

```
问题: 频繁查询不存在的数据

解决:
1. 添加布隆过滤器
2. 缓存空值 (设置短过期时间)
3. 检查业务逻辑，避免无效查询
```

### 3. 代码生成失败

```
问题: ant genxdb 失败

检查:
1. XML 语法是否正确
2. 数据类型是否支持
3. xbean 引用是否存在
4. 查看详细错误日志
```

### 4. 性能问题

```
问题: 数据访问缓慢

优化:
1. 增加 cacheCapacity
2. 使用合适的 lock 策略
3. 避免大事务
4. 减少不必要的数据加载
```

---

## 最佳实践

### 1. xbean 设计原则

```xml
<!-- 好的设计: 扁平化、字段明确 -->
<xbean name="PlayerBasic">
    <variable name="name" type="string"/>
    <variable name="level" type="int"/>
    <variable name="exp" type="long"/>
</xbean>

<!-- 避免: 过度嵌套 -->
<xbean name="PlayerComplex">
    <variable name="info" type="PlayerInfo"/>      <!-- 嵌套 -->
    <variable name="stats" type="PlayerStats"/>    <!-- 嵌套 -->
    <variable name="data" type="PlayerData"/>      <!-- 嵌套 -->
</xbean>
```

### 2. 事务处理原则

```java
// 好的实践: 事务简短、明确
public class UpdateLevelProcedure extends Procedure {
    @Override
    protected boolean process() {
        xbean.Role role = xtable.Role.get().select(roleId);
        role.setLevel(role.getLevel() + 1);
        return true;
    }
}

// 避免: 长事务、复杂逻辑
public class BadProcedure extends Procedure {
    @Override
    protected boolean process() {
        // 避免: 网络调用
        // 避免: 复杂计算
        // 避免: 操作多张表
        return true;
    }
}
```

### 3. 缓存配置原则

```xml
<!-- 高频访问表: 大缓存 -->
<table name="role" cacheCapacity="50000"/>

<!-- 低频访问表: 小缓存 -->
<table name="log" cacheCapacity="1000"/>

<!-- 临时数据: 内存表 -->
<table name="session" persistence="MEMORY" cacheCapacity="10000"/>
```

---

## 数据迁移

### 添加新字段

```xml
<!-- 1. 添加带默认值的字段 -->
<variable name="newField" type="int" default="0"/>

<!-- 2. 重新生成代码 -->
<!-- ant genxdb -->

<!-- 3. 服务器启动时自动兼容旧数据 -->
```

### 删除字段

```
警告: 删除字段需要谨慎处理

步骤:
1. 先在代码中移除对该字段的使用
2. 部署并观察一段时间
3. 确认无问题后从 xbean 定义中移除
4. 重新生成代码
5. 数据库清理 (可选)
```

### 修改字段类型

```
警告: 修改字段类型可能导致数据丢失

建议:
1. 添加新字段
2. 编写迁移脚本
3. 验证数据完整性
4. 移除旧字段
```

---

## 相关文档

- [gnet 网络框架](gnet-framework.md)
- [Java 开发技能](java-development.md)
- [Ant 构建技能](ant-build.md)
- [服务器 README](../../../server/README.md)

---

## 更新日志

### v1.0.0 (2025-12-28)
- 初始版本
- xbean 框架架构说明
- 完整的定义语法参考
- 实际项目示例 (Item、Bag、User)
- Procedure 事务处理
- 缓存机制详解
- 最佳实践和常见问题

---

**维护者**: 技术委员会
**下次审查**: 2026-03-28

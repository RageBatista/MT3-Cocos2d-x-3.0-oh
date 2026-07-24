# exportdata - XDB 数据库示例与数据导出工具

## 1. 工具概述

### 1.1 用途说明
exportdata 是一个 XDB（基于 mkdb 的文件数据库）的示例项目和数据导出工具，展示了如何定义数据库结构、生成 XBean/XTable 代码，并进行基本的数据操作。

**核心功能**:
- **XDB 结构示例**: 展示完整的 xdb.xml 配置示例
- **代码生成演示**: 演示从 XML 定义生成 XBean 和 XTable 类
- **数据操作示例**: 提供用户信息、订单信息的数据结构范例
- **测试入口**: 包含启动/停止 XDB 的测试代码
- **自增主键示例**: 演示 autoIncrement 表的使用
- **唯一名服务配置**: 展示 UniqName 服务的集成

**解决的问题**:
- 为开发者提供 XDB 数据库的学习样例
- 演示用户系统、订单系统的数据结构设计
- 展示 locojoy 平台集成的数据模型
- 验证 XDB 表结构与主键配置的正确性

**典型使用场景**:
- 学习 XDB 数据库的使用方法
- 作为新项目的数据结构设计参考
- 测试 XDB 功能和性能
- 验证表结构定义的正确性

### 1.2 关键特性
- **完整的示例**: 包含用户表、订单表的完整定义
- **自增主键**: users 表使用 long 型自增主键
- **外键关系**: LocojoyPlatUserInfo 引用 users 表
- **多表结构**: 展示 4 个业务表的设计
- **UniqName 集成**: 配置唯一名生成服务
- **测试代码**: 提供完整的启动/停止测试代码

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
exportdata 位于 MT3 **示例代码层**，为开发者提供参考:

```
┌─────────────────────────────────────────────────────────────┐
│         游戏业务系统（Game Business Layer）                  │
│  参考 exportdata 的数据结构设计实现自己的业务逻辑            │
└────────────────┬────────────────────────────────────────────┘
                 │ 参考设计
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              exportdata 示例项目                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   xdb.xml - 数据库结构定义                          │   │
│  │   - users (用户表, 自增主键)                        │   │
│  │   - locojoyplatusers (平台用户映射表)              │   │
│  │   - locojoyplatorderinfos (订单信息表)             │   │
│  │   - locojoyplatordergametoplat (订单映射表)        │   │
│  └─────────────────────────────────────────────────────┘   │
│                 │                                            │
│                 ↓ mkgen 代码生成                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   生成的代码                                         │   │
│  │   - xbean/ (UserInfo, LocojoyPlatUserInfo...)      │   │
│  │   - xtable/ (Users, Locojoyplatusers...)          │   │
│  │   - test/XdbMain.java (测试入口)                   │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────┬────────────────────────────────────────────┘
                 │ 依赖
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              monkeyking 核心库 (mkdb)                        │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **被参考模块**:
  - 游戏服务器项目 - 参考数据结构设计
  - 其他工具项目 - 学习 XDB 使用方法

- **依赖模块**:
  - `monkeyking.jar` - mkdb 数据库引擎
  - `jio.jar` - I/O 工具库

- **数据流**:
  - 设计时: xdb.xml 定义 → mkgen 生成代码
  - 运行时: XdbMain 启动 → 加载表结构 → 执行业务逻辑

### 2.3 关键代码位置

| 功能模块 | 文件路径 | 关键类/方法 |
|---------|---------|------------|
| 数据库配置 | [xdb.xml](xdb.xml#L1-L33) | XDB 结构定义 |
| 用户表定义 | [xdb.xml](xdb.xml#L4-L8) | `UserInfo` XBean, `users` 表 |
| 平台用户表 | [xdb.xml](xdb.xml#L11-L15) | `LocojoyPlatUserInfo` XBean |
| 订单表定义 | [xdb.xml](xdb.xml#L17-L24) | `LocojoyPlatOrderInfo` XBean |
| 测试入口 | [src/test/XdbMain.java](src/test/XdbMain.java#L4-L14) | `main()` 启动/停止 |
| 表管理器 | [src/xtable/_Tables_.java](src/xtable/_Tables_.java) | 统一表访问入口 |
| 生成的 XBean | [src/xbean/UserInfo.java](src/xbean/UserInfo.java) | 用户信息数据结构 |
| 生成的 XTable | [src/xtable/Users.java](src/xtable/Users.java) | 用户表操作类 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**: JDK/JRE 1.6 及以上
- **必需库文件**:
  - `monkeyking.jar` - mkdb 数据库引擎
  - `jio.jar` - I/O 工具库 (位于 `../../bin/jio.jar`)

### 3.2 构建步骤

#### 代码生成
```bash
# 1. 使用 mkgen 生成 XBean 和 XTable 代码
java -jar ../bin/monkeyking.jar xdb.xml -noverify

# 生成的代码位置:
# - src/xbean/*.java
# - src/xbean/__/*.java (内部实现)
# - src/xtable/*.java
```

#### 编译
```bash
# 2. 编译生成的代码和测试代码
javac -encoding GBK \
      -cp ../bin/monkeyking.jar:../bin/jio.jar \
      -d classes \
      src/xbean/*.java src/xbean/__/*.java \
      src/xtable/*.java src/test/*.java

# Windows 版本
javac -encoding GBK ^
      -cp ..\bin\monkeyking.jar;..\bin\jio.jar ^
      -d classes ^
      src\xbean\*.java src\xbean\__\*.java ^
      src\xtable\*.java src\test\*.java
```

#### 运行测试
```bash
# 3. 运行测试程序
java -cp classes:../bin/monkeyking.jar:../bin/jio.jar test.XdbMain

# Windows 版本
java -cp classes;..\bin\monkeyking.jar;..\bin\jio.jar test.XdbMain
```

---

## 4. 配置与使用

### 4.1 xdb.xml 配置文件详解

#### 整体结构
```xml
<xdb xgenOutput="src"
     trace="debug"
     traceTo=":file:out"
     corePoolSize="30"
     procPoolSize="10"
     schedPoolSize="5"
     dbhome="xdb"
     logpages="4096"
     backupDir="xbackup"
     checkpointPeriod="60000"
     backupIncPeriod="600000"
     backupFullPeriod="36000000"
     angelPeriod="5000"
     xdbVerify="true">
```

**配置参数说明**:

| 参数 | 说明 | 示例值 |
|-----|------|--------|
| `xgenOutput` | 代码生成输出目录 | `src` |
| `trace` | 日志级别 | `debug/info/warn/error` |
| `traceTo` | 日志输出位置 | `:file:out` (文件+控制台) |
| `corePoolSize` | 核心线程池大小 | `30` |
| `procPoolSize` | 存储过程线程池 | `10` |
| `schedPoolSize` | 调度线程池 | `5` |
| `dbhome` | 数据库主目录 | `xdb` |
| `logpages` | 日志缓冲页数 | `4096` |
| `backupDir` | 备份目录 | `xbackup` |
| `checkpointPeriod` | 检查点间隔(ms) | `60000` (1分钟) |
| `backupIncPeriod` | 增量备份间隔(ms) | `600000` (10分钟) |
| `backupFullPeriod` | 全量备份间隔(ms) | `36000000` (10小时) |
| `angelPeriod` | Angel监控间隔(ms) | `5000` (5秒) |
| `xdbVerify` | 启用数据验证 | `true/false` |

#### 用户表定义 (users)
```xml
<xbean name="UserInfo">
    <variable name="plat" type="string" />      <!-- 平台标识 -->
    <variable name="uid" type="string" />       <!-- 用户ID (platformUID) -->
</xbean>

<table name="users"
       key="long"
       value="UserInfo"
       cacheCapacity="10240"
       cachehigh="512"
       cachelow="256"
       lock="userlock"
       autoIncrement="true"/>  <!-- 自增长型 ID -->
```

**关键特性**:
- `autoIncrement="true"`: 主键自动递增
- `key="long"`: 使用 64 位长整型主键
- `cacheCapacity="10240"`: 缓存容量 10240 条记录

#### Locojoy 平台用户表 (locojoyplatusers)
```xml
<xbean name="LocojoyPlatUserInfo">
    <variable name="userid" type="int" />        <!-- 游戏内 userid -->
    <variable name="userinfoid" type="long" />   <!-- users 表的外键 -->
</xbean>

<table name="locojoyplatusers"
       key="string"                <!-- 平台账号作为主键 -->
       value="LocojoyPlatUserInfo"
       cacheCapacity="10240"
       cachehigh="512"
       cachelow="256"
       lock="locojoyplatuserlock"/>
```

**关键特性**:
- `key="string"`: 使用平台账号字符串作为主键
- `userinfoid` 字段引用 `users` 表的自增 ID

#### Locojoy 订单信息表 (locojoyplatorderinfos)
```xml
<xbean name="LocojoyPlatOrderInfo">
    <variable name="createtime" type="long" />        <!-- 创建时间 -->
    <variable name="orderserialplat" type="string" /> <!-- 平台订单号 -->
    <variable name="orderserialgame" type="string" /> <!-- 游戏订单号 -->
    <variable name="username" type="string" />        <!-- 用户名 -->
    <variable name="vars" type="binary" />            <!-- 扩展数据(二进制) -->
</xbean>

<table name="locojoyplatorderinfos"
       key="string"                  <!-- 订单号作为主键 -->
       value="LocojoyPlatOrderInfo"
       cacheCapacity="10240"
       cachehigh="512"
       cachelow="256"
       lock="locojoyplatorderinfolock"/>
```

**关键特性**:
- `vars` 字段使用 `binary` 类型存储扩展数据
- 支持平台订单号和游戏订单号双向映射

#### 订单映射表 (locojoyplatordergametoplat)
```xml
<table name="locojoyplatordergametoplat"
       key="string"      <!-- 游戏订单号 -->
       value="string"    <!-- 平台订单号 -->
       cacheCapacity="10240"
       cachehigh="512"
       cachelow="256"
       lock="locojoyplatordergametoplatlock"/>
```

**关键特性**:
- 简单的 Key-Value 映射表
- 游戏订单号 → 平台订单号的快速查询

#### 系统表配置 (_sys_)
```xml
<TableSysConf name="_sys_"
              cacheCapacity="1"
              cachehigh="512"
              cachelow="256"/>
```

#### UniqName 唯一名服务配置
```xml
<UniqNameConf localId="1">
    <XioConf name="xdb.util.UniqName">
        <!-- 唯一名生成服务配置 -->
    </XioConf>
</UniqNameConf>
```

### 4.2 使用示例

#### 示例 1: 启动数据库
```java
package test;

public class XdbMain {
    public static void main(String args[]) {
        // 1. 加载配置文件
        String xdbConfName = "../testdata/xdb.xml";
        xdb.XdbConf conf = new xdb.XdbConf(xdbConfName);

        // 2. 设置配置并启动数据库
        xdb.Xdb.getInstance().setConf(conf);
        xdb.Xdb.getInstance().start();

        try {
            // 3. 业务逻辑
            // 例如: 获取下一个自增主键
            // System.out.println(xtable.Users.nextKey());

        } finally {
            // 4. 停止数据库
            xdb.Xdb.getInstance().stop();
        }
    }
}
```

#### 示例 2: 插入用户数据
```java
import xbean.UserInfo;
import xtable._Tables_;

// 创建用户信息
UserInfo user = new UserInfo();
user.setPlat("locojoy");
user.setUid("user123");

// 插入到 users 表 (自增主键)
long userId = _Tables_.getInstance().getUsers().nextKey();
_Tables_.getInstance().getUsers().insert(userId, user);

System.out.println("Created user with ID: " + userId);
```

#### 示例 3: 建立平台用户映射
```java
import xbean.LocojoyPlatUserInfo;
import xtable._Tables_;

// 创建平台用户映射
LocojoyPlatUserInfo platUser = new LocojoyPlatUserInfo();
platUser.setUserid(10001);        // 游戏内 userid
platUser.setUserinfoid(userId);   // 关联 users 表的 ID

// 以平台账号为 key 插入
String platformAccount = "locojoy_user123";
_Tables_.getInstance().getLocojoyplatusers().insert(platformAccount, platUser);
```

#### 示例 4: 记录订单信息
```java
import xbean.LocojoyPlatOrderInfo;
import xtable._Tables_;

// 创建订单信息
LocojoyPlatOrderInfo order = new LocojoyPlatOrderInfo();
order.setCreatetime(System.currentTimeMillis());
order.setOrderserialplat("PLAT20251127001");
order.setOrderserialgame("GAME20251127001");
order.setUsername("user123");
order.setVars(new byte[]{0x01, 0x02, 0x03}); // 扩展数据

// 插入订单信息
_Tables_.getInstance().getLocojoyplatorderinfos()
    .insert(order.getOrderserialgame(), order);

// 建立订单映射
_Tables_.getInstance().getLocojoyplatordergametoplat()
    .insert(order.getOrderserialgame(), order.getOrderserialplat());
```

#### 示例 5: 查询用户信息
```java
// 通过平台账号查询游戏内 userid
String platformAccount = "locojoy_user123";
LocojoyPlatUserInfo platUser = _Tables_.getInstance()
    .getLocojoyplatusers()
    .select(platformAccount);

if (platUser != null) {
    int gameUserId = platUser.getUserid();
    long userInfoId = platUser.getUserinfoid();

    // 查询完整用户信息
    UserInfo user = _Tables_.getInstance()
        .getUsers()
        .select(userInfoId);

    System.out.println("Platform: " + user.getPlat());
    System.out.println("UID: " + user.getUid());
    System.out.println("Game User ID: " + gameUserId);
}
```

---

## 5. 输入输出规范

### 5.1 输入格式

#### xdb.xml 配置文件
- **编码**: UTF-8 或 GBK
- **格式**: 符合 mkdb XML Schema
- **必需元素**: `<xdb>`, `<xbean>`, `<table>`

#### 测试数据
- **路径**: `../testdata/xdb.xml`
- **格式**: 与 xdb.xml 相同

### 5.2 输出格式

#### 生成的代码结构
```
src/
├── xbean/                      # XBean 数据结构类
│   ├── UserInfo.java
│   ├── LocojoyPlatUserInfo.java
│   ├── LocojoyPlatOrderInfo.java
│   ├── Pod.java
│   └── __/                     # 内部实现类
│       ├── UserInfo.java
│       ├── LocojoyPlatUserInfo.java
│       └── LocojoyPlatOrderInfo.java
├── xtable/                     # XTable 表操作类
│   ├── _Tables_.java           # 表管理器
│   ├── Users.java
│   ├── Locojoyplatusers.java
│   ├── Locojoyplatorderinfos.java
│   ├── Locojoyplatordergametoplat.java
│   ├── Locks.java              # 锁管理
│   └── _DatabaseMetaData_.java # 元数据
└── test/
    └── XdbMain.java            # 测试入口
```

#### 数据库文件结构
```
xdb/                            # 数据库主目录
├── table/
│   ├── users/                  # users 表数据
│   ├── locojoyplatusers/
│   ├── locojoyplatorderinfos/
│   └── locojoyplatordergametoplat/
├── log/                        # 事务日志
├── mkdb.inuse                  # 锁文件
└── metadata.xml                # 元数据

xbackup/                        # 备份目录
├── inc_<timestamp>/            # 增量备份
└── full_<timestamp>/           # 全量备份
```

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制
- **示例代码**: 主要用于学习和参考,非生产环境工具
- **测试代码简单**: XdbMain 仅演示启动/停止,无完整业务逻辑
- **无数据导入**: 未实现从外部数据源导入数据的功能
- **固定配置**: xdb.xml 配置针对示例场景,需根据实际修改

#### 设计限制
- **Locojoy 平台特定**: 数据结构针对 Locojoy 平台设计
- **无通用性**: 表结构不适用于其他平台或场景
- **简化的扩展数据**: `vars` 字段使用简单的 binary 类型

### 6.2 性能考虑

#### 缓存配置
```yaml
users表:
  cacheCapacity: 10240  # 适合中小规模用户
  cachehigh: 512        # 高水位
  cachelow: 256         # 低水位

建议调整:
  大规模用户(>100万): cacheCapacity: 100000
  小规模用户(<1万):   cacheCapacity: 1024
```

#### 自增主键性能
```java
// ❌ 错误: 频繁调用 nextKey()
for (int i = 0; i < 1000; i++) {
    long id = _Tables_.getInstance().getUsers().nextKey();
    _Tables_.getInstance().getUsers().insert(id, user);
}

// ✅ 正确: 批量预分配 ID
long startId = _Tables_.getInstance().getUsers().nextKey(1000);
for (int i = 0; i < 1000; i++) {
    _Tables_.getInstance().getUsers().insert(startId + i, user);
}
```

### 6.3 安全注意事项

#### 数据安全
- **用户密码**: 示例中未包含密码字段,实际应用需添加并加密
- **敏感数据**: `vars` 二进制字段可能包含敏感信息,应加密存储
- **订单安全**: 订单号应使用安全的随机生成算法

#### 并发安全
```java
// 使用事务保证数据一致性
xdb.Transaction txn = xdb.Transaction.current();
txn.begin();
try {
    // 创建用户
    long userId = _Tables_.getInstance().getUsers().nextKey();
    _Tables_.getInstance().getUsers().insert(userId, user);

    // 创建平台映射
    platUser.setUserinfoid(userId);
    _Tables_.getInstance().getLocojoyplatusers()
        .insert(platformAccount, platUser);

    txn.commit();
} catch (Exception e) {
    txn.rollback(0);
    throw e;
}
```

### 6.4 故障排查指南

#### 问题 1: 启动失败 - "mkdb is still in active use"
**解决方案**:
```bash
# 删除锁文件
rm xdb/mkdb.inuse
```

#### 问题 2: 代码生成失败
**解决方案**:
```bash
# 确保 monkeyking.jar 存在
ls -l ../bin/monkeyking.jar

# 重新生成代码
java -jar ../bin/monkeyking.jar xdb.xml -noverify
```

#### 问题 3: 编译错误 - "找不到符号"
**解决方案**:
```bash
# 确保已生成代码
ls -l src/xbean/ src/xtable/

# 检查 classpath
javac -cp ../bin/monkeyking.jar:../bin/jio.jar -verbose src/test/XdbMain.java
```

---

## 7. 扩展与改进

### 7.1 推荐改进方向

#### 短期优化 (1-2 周)
1. **完善测试代码**: 添加完整的 CRUD 操作示例
2. **数据导入工具**: 实现从 CSV/Excel 导入测试数据
3. **性能测试**: 添加并发测试和性能基准测试

#### 中期优化 (1-2 个月)
4. **通用化设计**: 移除 Locojoy 平台特定的设计
5. **数据验证**: 添加字段格式验证和约束检查
6. **API 封装**: 提供高层次的业务 API 封装

### 7.2 扩展示例

#### 扩展 1: 添加用户认证
```xml
<xbean name="UserInfo">
    <variable name="plat" type="string" />
    <variable name="uid" type="string" />
    <!-- 新增字段 -->
    <variable name="passwordHash" type="string" />
    <variable name="salt" type="string" />
    <variable name="createTime" type="long" />
    <variable name="lastLoginTime" type="long" />
</xbean>
```

#### 扩展 2: 订单状态管理
```xml
<xbean name="LocojoyPlatOrderInfo">
    <variable name="createtime" type="long" />
    <variable name="orderserialplat" type="string" />
    <variable name="orderserialgame" type="string" />
    <variable name="username" type="string" />
    <variable name="vars" type="binary" />
    <!-- 新增字段 -->
    <variable name="status" type="int" />  <!-- 0=待支付, 1=已支付, 2=已取消 -->
    <variable name="amount" type="long" /> <!-- 订单金额(分) -->
    <variable name="currency" type="string" /> <!-- 货币类型 -->
</xbean>
```

---

## 8. 快速参考

### 8.1 常用命令速查表

```bash
# 生成代码
java -jar ../bin/monkeyking.jar xdb.xml -noverify

# 编译代码
javac -encoding GBK -cp ../bin/monkeyking.jar:../bin/jio.jar \
      -d classes src/**/*.java

# 运行测试
java -cp classes:../bin/monkeyking.jar:../bin/jio.jar test.XdbMain

# 清理数据库
rm -rf xdb xbackup

# 查看表结构
cat xdb.xml | grep -A 5 '<table'
```

### 8.2 表结构速查

| 表名 | 主键类型 | 值类型 | 自增 | 用途 |
|-----|---------|--------|-----|------|
| `users` | `long` | `UserInfo` | ✅ | 用户基本信息 |
| `locojoyplatusers` | `string` | `LocojoyPlatUserInfo` | ❌ | 平台用户映射 |
| `locojoyplatorderinfos` | `string` | `LocojoyPlatOrderInfo` | ❌ | 订单详细信息 |
| `locojoyplatordergametoplat` | `string` | `string` | ❌ | 订单号映射 |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | exportdata (XDB Example & Data Export Tool) |
| **主要功能** | XDB 数据库示例与参考 |
| **依赖库** | monkeyking.jar, jio.jar |
| **代码位置** | `server/tools/exportdata/` |
| **配置文件** | `xdb.xml` |
| **测试入口** | `src/test/XdbMain.java` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |

---

## 10. 联系方式

如有问题或建议,请通过以下方式联系:
- 提交 Issue 到项目仓库
- 联系游戏服务器架构团队
- 查看 monkeyking 工具文档获取更多 XDB 使用说明

---

**文档版本**: v1.0
**维护者**: MT3 开发团队
**最后更新**: 2025-11-27

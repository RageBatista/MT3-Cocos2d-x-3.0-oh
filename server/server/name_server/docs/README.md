# Name Server (唯一名服务器) 技术文档

## 📋 文档信息

- **模块名称**: Name Server (NS)
- **版本**: v1.0
- **最后更新**: 2025-11-20
- **维护团队**: MT3服务器开发组
- **优先级**: ⭐⭐⭐⭐ (核心服务器 - 唯一性保证)

---

## 📖 目录

1. [模块概述](#模块概述)
2. [功能特性](#功能特性)
3. [目录结构](#目录结构)
4. [安装部署](#安装部署)
5. [配置说明](#配置说明)
6. [使用示例](#使用示例)
7. [运维指南](#运维指南)
8. [常见问题](#常见问题)
9. [附录](#附录)

---

## 🎯 模块概述

### 功能定位

Name Server (NS) 是 MT3 服务器架构中的**唯一性保证服务**，负责：

1. **唯一名称管理** - 保证角色名、公会名等的全局唯一性
2. **ID分配** - 分配唯一的ID（如家族ID）
3. **高性能查询** - 快速的名称查询和验证
4. **持久化存储** - 基于 BerkeleyDB 的可靠存储
5. **独立部署** - 可独立于游戏服务器部署

### 技术栈

| 技术 | 用途 | 版本/说明 |
|------|------|----------|
| **Java** | 核心实现语言 | Java 6/7/8 |
| **Ant** | 构建工具 | Apache Ant |
| **XDB** | 对象数据库 | eXtensible DataBase |
| **BerkeleyDB** | 底层存储 | Oracle BerkeleyDB JE |
| **monkeyking.jar** | XDB代码生成 | 自研工具 |

### 应用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **角色名** | 保证角色名唯一 | "张三"只能被一个角色使用 |
| **公会名** | 保证公会名唯一 | "霸气公会"只能有一个 |
| **家族名** | 保证家族名唯一 | "王氏家族"全服唯一 |
| **ID分配** | 分配递增的唯一ID | 家族ID从10000开始递增 |

---

## 🏛️ 架构设计

### 服务架构

```
┌─────────────────────────────────────────────────────────┐
│                   Game Server / Proxy                    │
│              (调用Name Server验证名称)                    │
└───────────────┬─────────────────────────────────────────┘
                │ RPC调用
                ▼
┌─────────────────────────────────────────────────────────┐
│              Name Server 唯一名服务器 ⭐                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Name Table   │  │ ID Generator │  │ Cache        │  │
│  │ 名称表        │  │ ID生成器     │  │ Manager      │  │
│  │ (角色/公会)   │  │ (家族ID等)   │  │ 缓存管理     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└───────────────┬─────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────┐
│             BerkeleyDB 持久化存储                        │
│          (name.db, id.db)                               │
└─────────────────────────────────────────────────────────┘
```

### 数据流向

```
名称注册流程：

1. [Game Server] ──registerName(name, roleid)──► [Name Server]
2. [Name Server] ──查询名称表──► [XDB]
3. [XDB] ──检查是否存在──► [BerkeleyDB]
4. [Name Server] ──插入新名称──► [XDB]
5. [XDB] ──持久化──► [BerkeleyDB]
6. [Name Server] ──返回结果(true/false)──► [Game Server]

ID分配流程：

1. [Game Server] ──allocateId(type)──► [Name Server]
2. [Name Server] ──查询ID表──► [XDB]
3. [XDB] ──获取当前最大ID──► [BerkeleyDB]
4. [Name Server] ──递增ID并保存──► [XDB]
5. [XDB] ──持久化──► [BerkeleyDB]
6. [Name Server] ──返回新ID──► [Game Server]
```

---

## 📂 目录结构

```
server/server/name_server/
├── docs/                           # 技术文档目录
│   └── README.md                   # 本文档
│
├── 核心文件
│   ├── ns.jar                      # Name Server JAR包 ⭐
│   ├── ns.Mkdb.xml                 # 初始化数据库配置 ⭐
│   ├── ns.install.xml              # 安装配置 ⭐
│   ├── ns.class                    # 安装器类
│   ├── build.xml                   # Ant构建脚本
│   └── install.txt                 # 安装说明文档 (中文)
│
├── 数据库文件 (运行时生成)
│   ├── name.db/                    # 名称数据库
│   ├── id.db/                      # ID数据库
│   └── __lock/                     # 数据库锁文件
│
├── 配置文件 (运行时生成)
│   └── ns.conf                     # 运行时配置
│
└── 日志文件 (运行时生成)
    └── ns.log                      # 运行日志
```

---

## 🛠️ 安装部署

### 前置条件

1. **Java环境**: Java 6 或更高版本
2. **Ant工具**: Apache Ant (用于构建)
3. **磁盘空间**: 至少 100MB 可用空间

### 安装步骤

#### 1. 获取安装文件

从SVN获取最新版本：

```bash
# SVN仓库
svn checkout http://svnroot/repos/snail/bin

# 文件列表
# - ns.jar           # 唯一名服务器所有版本（兼容所有平台）
# - ns.Mkdb.xml      # 唯一名服务器初始化配置（仅首次安装或重置初始配置时使用）
# - ns.install.xml   # 唯一名服务器升级脚本
# - ns.class         # 安装器
```

#### 2. 执行安装

```bash
# 创建安装目录
mkdir -p /opt/nameserver
cd /opt/nameserver

# 复制安装文件
cp /path/to/snail/bin/ns.* .

# 执行安装 (-c 参数表示创建新安装)
java -cp . ns installdir -c

# installdir: 安装目录路径（必须不存在）
# -c: 创建新安装（首次安装使用）
```

**注意**: 安装目录必须不存在，否则安装会失败。

#### 3. 配置数据库

编辑 `ns.Mkdb.xml` 配置文件：

```xml
<!-- ns.Mkdb.xml -->
<xdb>
    <!-- 1. 名称表配置 -->
    <table name="role" key="string" value="NameState"
           cacheCapacity="10240" cachehigh="128" cachelow="64">
        <comment>角色名称唯一性表</comment>
    </table>

    <table name="guild" key="string" value="NameState"
           cacheCapacity="1024" cachehigh="32" cachelow="16">
        <comment>公会名称唯一性表</comment>
    </table>

    <table name="family" key="string" value="NameState"
           cacheCapacity="512" cachehigh="16" cachelow="8">
        <comment>家族名称唯一性表</comment>
    </table>

    <!-- 2. ID分配表配置（不推荐直接使用，建议通过Game Server管理） -->
    <table name="familyid" idmin="10000" idmax="1000000"
           key="long" value="IdState"
           cacheCapacity="10240" cachehigh="128" cachelow="64">
        <comment>家族ID分配表</comment>
    </table>
</xdb>
```

**配置参数说明**:

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| **name** | 表名 | 有意义的名称 |
| **key** | 键类型 | string/long |
| **value** | 值类型 | NameState/IdState |
| **cacheCapacity** | 缓存容量 | 10240（角色）/1024（公会） |
| **cachehigh** | 缓存高水位 | 128/32 |
| **cachelow** | 缓存低水位 | 64/16 |
| **idmin** | ID最小值 | 10000 |
| **idmax** | ID最大值 | 1000000 |

#### 4. 生成新的 ns.jar

```bash
# 使用Ant重新生成ns.jar
cd installdir
ant

# 输出: ns.jar (包含新配置的XDB代码)
```

### 升级部署

如果已有运行中的Name Server需要升级：

```bash
# 1. 备份数据
cp -r /opt/nameserver/db /opt/nameserver/db.backup

# 2. 停止服务
java -jar ns.jar stop

# 3. 复制新版本文件
cp /path/to/new/ns.jar /opt/nameserver/

# 4. 执行升级脚本
java -jar ns.jar upgrade ns.install.xml

# 5. 启动服务
java -jar ns.jar start
```

---

## ⚙️ 配置说明

### ns.Mkdb.xml - 数据库初始化配置

```xml
<xdb>
    <!-- 名称表 -->
    <table name="role" key="string" value="NameState"
           cacheCapacity="10240" cachehigh="128" cachelow="64"/>

    <!-- ID表 -->
    <table name="familyid" idmin="10000" idmax="1000000"
           key="long" value="IdState"
           cacheCapacity="10240" cachehigh="128" cachelow="64"/>
</xdb>
```

### ns.install.xml - 升级脚本配置

```xml
<install>
    <!-- 升级步骤 -->
    <step version="1.1">
        <add-table name="pet" key="string" value="NameState"
                   cacheCapacity="5120" cachehigh="64" cachelow="32"/>
    </step>

    <step version="1.2">
        <modify-table name="role" cacheCapacity="20480"/>
    </step>
</install>
```

### NameState / IdState - 数据对象

```java
// NameState.java (自动生成)
package xbean;

public class NameState extends Bean {
    private int id;         // 关联ID (角色ID/公会ID)
    private long timestamp; // 注册时间戳

    public NameState() {}

    public int getId() { return id; }
    public void setId(int value) { id = value; }

    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long value) { timestamp = value; }

    // 序列化/反序列化方法...
}

// IdState.java (自动生成)
package xbean;

public class IdState extends Bean {
    private long currentId;  // 当前最大ID
    private long timestamp;  // 最后更新时间

    public IdState() {}

    public long getCurrentId() { return currentId; }
    public void setCurrentId(long value) { currentId = value; }

    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long value) { timestamp = value; }

    // 序列化/反序列化方法...
}
```

---

## 💻 使用示例

### Java客户端调用

```java
import xdb.Table;
import xbean.NameState;
import xbean.IdState;

public class NameServerClient {
    private static final Table<String, NameState> roleNames =
        xdb.Database.getTable("role");

    private static final Table<Long, IdState> familyIds =
        xdb.Database.getTable("familyid");

    // 注册角色名
    public static boolean registerRoleName(String name, int roleid) {
        NameState state = new NameState();
        state.setId(roleid);
        state.setTimestamp(System.currentTimeMillis());

        try {
            NameState old = roleNames.insert(name, state);
            return old == null; // null表示插入成功
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 查询角色名
    public static Integer findRoleByName(String name) {
        try {
            NameState state = roleNames.get(name);
            return state != null ? state.getId() : null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 删除角色名
    public static boolean deleteRoleName(String name) {
        try {
            NameState state = roleNames.remove(name);
            return state != null;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 分配家族ID
    public static Long allocateFamilyId() {
        try {
            // 使用原子操作分配ID
            xdb.Procedure proc = new xdb.Procedure() {
                @Override
                public boolean process() {
                    IdState state = familyIds.get(0L);
                    if (state == null) {
                        state = new IdState();
                        state.setCurrentId(10000L); // 起始ID
                    }

                    long newId = state.getCurrentId() + 1;
                    state.setCurrentId(newId);
                    state.setTimestamp(System.currentTimeMillis());

                    familyIds.insert(0L, state);
                    return true;
                }
            };

            if (proc.call()) {
                IdState state = familyIds.get(0L);
                return state.getCurrentId();
            }

            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 检查名称是否已存在
    public static boolean isNameExists(String name) {
        return findRoleByName(name) != null;
    }
}
```

### 批量操作

```java
// 批量注册名称
public static Map<String, Boolean> batchRegisterNames(
        List<String> names, int roleid) {

    Map<String, Boolean> results = new HashMap<>();

    for (String name : names) {
        boolean success = registerRoleName(name, roleid);
        results.put(name, success);
    }

    return results;
}

// 批量查询
public static Map<String, Integer> batchFindRoles(List<String> names) {
    Map<String, Integer> results = new HashMap<>();

    for (String name : names) {
        Integer roleid = findRoleByName(name);
        if (roleid != null) {
            results.put(name, roleid);
        }
    }

    return results;
}
```

---

## 🚀 运维指南

### 启动服务

```bash
# 方式1: 直接启动
cd /opt/nameserver
java -jar ns.jar

# 方式2: 后台启动
nohup java -jar ns.jar > ns.log 2>&1 &

# 方式3: 使用systemd (推荐)
sudo systemctl start nameserver
```

### 停止服务

```bash
# 方式1: 优雅停止
java -jar ns.jar stop

# 方式2: 强制停止
kill -TERM `cat /var/run/ns.pid`

# 方式3: 使用systemd
sudo systemctl stop nameserver
```

### 监控指标

| 指标 | 说明 | 正常范围 | 告警阈值 |
|------|------|---------|---------|
| **名称总数** | 注册的名称数量 | 0-100万 | >90万 |
| **QPS** | 每秒查询数 | <1000 | >5000 |
| **响应时间** | 平均响应时间 | <10ms | >50ms |
| **缓存命中率** | 缓存命中比例 | >95% | <90% |
| **磁盘使用** | 数据库文件大小 | <1GB | >5GB |

### 数据备份

```bash
#!/bin/bash
# backup.sh - Name Server数据备份脚本

BACKUP_DIR="/opt/nameserver/backup"
DATE=`date +%Y%m%d_%H%M%S`

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
cp -r /opt/nameserver/db $BACKUP_DIR/db_$DATE

# 压缩备份
cd $BACKUP_DIR
tar -czf db_$DATE.tar.gz db_$DATE
rm -rf db_$DATE

# 清理30天前的备份
find $BACKUP_DIR -name "db_*.tar.gz" -mtime +30 -delete

echo "Backup completed: db_$DATE.tar.gz"
```

### 数据恢复

```bash
#!/bin/bash
# restore.sh - Name Server数据恢复脚本

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# 停止服务
java -jar ns.jar stop

# 备份当前数据
mv /opt/nameserver/db /opt/nameserver/db.old

# 解压备份文件
tar -xzf $BACKUP_FILE -C /opt/nameserver

# 启动服务
java -jar ns.jar start

echo "Restore completed from: $BACKUP_FILE"
```

### 性能调优

#### JVM参数优化

```bash
# 启动脚本 start.sh
#!/bin/bash

java -Xms512m -Xmx1024m \
     -XX:+UseConcMarkSweepGC \
     -XX:+UseParNewGC \
     -XX:CMSInitiatingOccupancyFraction=75 \
     -XX:+PrintGCDetails \
     -XX:+PrintGCTimeStamps \
     -Xloggc:logs/gc.log \
     -jar ns.jar
```

#### BerkeleyDB调优

```java
// 数据库环境配置
EnvironmentConfig envConfig = new EnvironmentConfig();
envConfig.setAllowCreate(true);
envConfig.setTransactional(true);
envConfig.setCacheSize(512 * 1024 * 1024);  // 512MB缓存
envConfig.setLockTimeout(5000, TimeUnit.MILLISECONDS);  // 5秒锁超时
```

---

## ❓ 常见问题

### Q1: 名称注册失败，返回false？

**可能原因**:

1. 名称已被占用
2. 数据库锁超时
3. 磁盘空间不足

**解决方案**:

```bash
# 1. 检查名称是否已存在
java -jar ns.jar query role "张三"

# 2. 检查磁盘空间
df -h /opt/nameserver

# 3. 查看日志
tail -f ns.log | grep ERROR

# 4. 重启服务
java -jar ns.jar restart
```

### Q2: ID分配耗尽怎么办？

**诊断**:

```bash
# 查看当前ID
java -jar ns.jar query familyid 0
```

**解决**:

1. 修改 `ns.Mkdb.xml` 中的 `idmax` 值
2. 重新生成 ns.jar
3. 升级部署

### Q3: 如何清空所有数据？

**警告**: 此操作会删除所有数据，请谨慎操作！

```bash
# 1. 停止服务
java -jar ns.jar stop

# 2. 删除数据库
rm -rf /opt/nameserver/db

# 3. 重新初始化
java -cp . ns /opt/nameserver -c

# 4. 启动服务
java -jar ns.jar start
```

### Q4: 数据库损坏如何修复？

```bash
# 使用BerkeleyDB自带的工具修复
java -cp je-X.X.X.jar com.sleepycat.je.util.DbVerify \
     -h /opt/nameserver/db

# 如果无法修复，从备份恢复
./restore.sh /opt/nameserver/backup/db_20251120.tar.gz
```

---

## 📚 附录

### A. 端口说明

Name Server 通常不开放网络端口，而是通过直接的Java API调用或嵌入到Game Server进程中。

如果需要网络访问，可以封装RPC接口：

| 端口 | 协议 | 用途 |
|------|------|------|
| 未使用 | - | 本地API调用 |
| 可选 | RPC | 远程调用接口 |

### B. 数据对象定义

#### NameState

```java
package xbean;

public class NameState extends Bean {
    private int id;         // 关联ID
    private long timestamp; // 时间戳

    // getter/setter...
}
```

#### IdState

```java
package xbean;

public class IdState extends Bean {
    private long currentId;  // 当前ID
    private long timestamp;  // 时间戳

    // getter/setter...
}
```

### C. 相关文档

- [Common 公共模块文档](../common/docs/README.md)
- [Game Server 技术文档](../game_server/docs/README.md)
- [Server 总体架构分析](../../docs/server-directory-analysis-report.md)

### D. 技术支持

- **文档维护**: MT3技术文档团队
- **问题反馈**: 请通过内部问题跟踪系统提交

---

## 📝 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| v1.0 | 2025-11-20 | 初始版本，Name Server技术文档 |

---

**文档结束**

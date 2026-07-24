# newxmerge - 新版游戏服务器合服工具

## 1. 工具概述

### 1.1 用途说明
newxmerge 是 MT3 游戏服务器的跨服/跨库数据合并与校验工具集，用于将两个独立运营的游戏服务器数据库合并为一个统一数据库。该工具提供以下核心功能：

- **数据预处理**：合并前的数据预处理和清理
- **冲突检测**：自动检测主键冲突（已知冲突 vs 未知冲突）
- **智能合并**：支持自定义合并策略处理已知冲突
- **外键校验**：验证和修复外键引用关系
- **冲突修复**：自动修复未知冲突（重新分配唯一键）
- **数据输出**：生成合并结果数据库和冲突数据集

### 1.2 典型使用场景
- **服务器合并**：多个游戏服务器合区操作
- **数据迁移**：跨环境数据库迁移（测试环境 → 生产环境）
- **灾难恢复**：从备份数据库恢复并合并增量数据
- **数据整合**：合并分布式数据库为单一数据源

### 1.3 关键特性
- **三阶段处理**：合并 → 检测 → 修复 → 再合并
- **事务回滚**：失败时自动回滚，保护原始数据
- **灵活配置**：通过 XML 配置表级别的合并策略
- **可扩展性**：支持自定义 Merger/Allocator 实现
- **数据安全**：自动备份源数据库，不修改原始数据

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
newxmerge 位于 MT3 服务器架构的**运维工具层**，是游戏服务器数据库运维的核心工具：

```
┌─────────────────────────────────────────┐
│      游戏服务器运维管理平台              │
└──────────────┬──────────────────────────┘
               │ (调用 newxmerge)
               ↓
┌─────────────────────────────────────────┐
│         newxmerge 合服工具              │
│  ┌────────────────────────────────────┐ │
│  │  1. Merger (合并引擎)              │ │
│  │  2. CheckDupKey (冲突检测器)       │ │
│  │  3. Repair (冲突修复器)            │ │
│  │  4. ForeignValidator (外键校验器)  │ │
│  └────────────────────────────────────┘ │
└──────────────┬──────────────────────────┘
               │ XDB 数据库操作
               ↓
┌─────────────────────────────────────────┐
│         游戏服务器数据库 (XDB)          │
│  - user (用户表 - 已知冲突)            │
│  - role (角色表 - 未知冲突)            │
│  - item (物品表 - 未知冲突)            │
│  - _sys_ (系统表 - 自增键)             │
└─────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **上游依赖**：
  - 游戏服务器 jar 包 (gs.jar) - 提供数据结构定义 (xbean)
  - jio.jar - JNI 数据库访问库
  - monkeyking.jar - 数据库元数据管理
- **下游消费者**：运维脚本、服务器管理平台
- **数据流**：`源数据库 + 目标数据库 → 结果数据库`（单向合并）

### 2.3 关键代码位置
| 功能模块 | 文件路径 | 关键行号 |
|---------|---------|---------|
| 合并主流程 | [xmerge/src/xmerge/Xmerge.java](xmerge/src/xmerge/Xmerge.java#L52-L97) | 52-97 |
| 合并引擎 | [xmerge/src/xmerge/Merger.java](xmerge/src/xmerge/Merger.java#L124-L228) | 124-228 |
| 已知冲突处理 | [xmerge/src/xmerge/Merger.java](xmerge/src/xmerge/Merger.java#L362-L448) | 362-448 |
| 未知冲突处理 | [xmerge/src/xmerge/Merger.java](xmerge/src/xmerge/Merger.java#L296-L332) | 296-332 |
| 冲突检测 | [xmerge/src/xmerge/CheckDupKey.java](xmerge/src/xmerge/CheckDupKey.java) | 全文 |
| 冲突修复 | [xmerge/src/xmerge/Repair.java](xmerge/src/xmerge/Repair.java) | 全文 |
| 外键校验 | [xmerge/src/validator/ForeignValidator.java](xmerge/src/validator/ForeignValidator.java) | 全文 |
| 配置管理 | [xmerge/src/xmerge/XmergeConf.java](xmerge/src/xmerge/XmergeConf.java) | 全文 |
| 命令行入口 | [xmerge/src/xmerge/Main.java](xmerge/src/xmerge/Main.java#L35-L90) | 35-90 |
| 构建配置 | [xmerge/build-xmerge.xml](xmerge/build-xmerge.xml) | 全文 |

---

## 3. 核心概念与术语

### 3.1 关键术语定义

| 术语 | 说明 |
|-----|------|
| **合服 (Merge)** | 将两个独立运营的服务器数据库合并为一个 |
| **合区 (Server Merge)** | 合服的游戏业务术语 |
| **src_db** | 源数据库，合服时内容不会被修改（工具会自动备份） |
| **dest_db** | 目标数据库，合服时内容不会被修改 |
| **result_db** | 结果数据库，合服成功后得到的最终数据库 |
| **error_keys_db** | 冲突键数据库，检测时发现的所有重复主键 |
| **foreign_db** | 外键关系数据库，专门用来保存错误键数据表及其外键关系 |
| **key_conflict** | 主键冲突，合并时源数据表的主键值在目标表中已经存在 |
| **known_key_conflict** | 已知重复冲突，如 user 表的主键为账号，同一个账号可能在两个服务器都有角色 |
| **unknown_key_conflict** | 未知重复冲突，应该不重复但实际重复了，如 role 表的主键为角色名 |

### 3.2 冲突类型与处理策略

#### 3.2.1 已知冲突 (known_key_conflict)
**定义**：业务上允许重复的主键，如用户账号可能在多个服务器都存在。

**处理方式**：
```java
// 定义合并逻辑（由游戏业务逻辑决定）
merge(src_key, src_value, dest_value) {
    // 例如：保留等级高的角色，合并金币/经验
    if (src_value.level > dest_value.level) {
        dest_value.level = src_value.level;
    }
    dest_value.gold += src_value.gold;
}
```

**配置示例**：
```xml
<table name="user" type="known_key_conflict" class="mymerge.UserMergeImplement"/>
```

#### 3.2.2 未知冲突 (unknown_key_conflict)
**定义**：理论上不应该重复但实际发生冲突的主键，如角色名称冲突。

**处理流程**：
1. **检测阶段**：扫描并记录所有重复键到 error_keys_db
2. **修复阶段**：
   - 为冲突键分配新的唯一主键 (AutoKey)
   - 删除旧记录，插入新记录
   - 更新所有引用该键的外键 (foreign references)

**修复示例**：
```
原始冲突：
  src_db:  role[name="张三", id=1001]
  dest_db: role[name="张三", id=2001]

修复后：
  src_db:  role[name="张三", id=3001]  // 新分配的 AutoKey
  更新所有引用 id=1001 的外键 → 3001
```

---

## 4. 依赖与构建

### 4.1 运行时依赖
- **Java 运行时**：JDK/JRE 1.6 及以上（推荐 JDK 8）
- **游戏服务器库**：gs.jar（包含 xbean 数据结构定义）
- **数据库库**：
  - jio.jar：JNI 数据库访问层
  - monkeyking.jar：数据库元数据和工具类
- **系统权限**：
  - 源/目标数据库的读权限
  - 结果数据库目录的写权限
  - 备份目录的读写权限

### 4.2 构建时依赖
- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）
- **编码要求**：源码使用 GBK 编码

### 4.3 构建步骤

#### Windows 环境
```batch
# 进入构建目录
cd E:\MT3\server\tools\newxmerge\xmerge

# 使用 Ant 构建
ant -f build-xmerge.xml install

# 输出文件：
#   xmerge.jar         - 合并工具 Jar 包
#   xdbmerge/          - 输出目录
#     ├── xmerge.jar
#     └── xmerge.xml
```

#### Linux/macOS 环境
```bash
# 进入构建目录
cd server/tools/newxmerge/xmerge

# 使用 Ant 构建
ant -f build-xmerge.xml install

# 输出文件：xdbmerge/xmerge.jar, xdbmerge/xmerge.xml
```

#### 构建流程说明
构建脚本执行以下步骤（参见 [build-xmerge.xml](xmerge/build-xmerge.xml)）：

1. **清理阶段** (clean)：删除旧的 classes/ 目录
2. **初始化阶段** (init)：创建 classes/xmerge/ 和 xdbmerge/ 目录
3. **编译阶段** (compile)：
   - 编译 `src/xmerge/**/*.java` 和 `src/validator/**/*.java` → `classes/xmerge/`
   - 使用 GBK 编码
   - 依赖 jio.jar 和 monkeyking.jar
   - 启用调试信息和 unchecked 警告
4. **打包阶段** (dist)：
   - 生成 `xmerge.jar`
   - 设置 Main-Class: `xmerge.Main`
5. **安装阶段** (install)：
   - 复制 xmerge.jar 和 xmerge.xml 到 xdbmerge/ 目录

### 4.4 构建参数说明
| 参数 | 说明 | 默认值 |
|-----|------|-------|
| `src` | 合并工具源代码目录 | `src/xmerge` |
| `validatorsrc` | 校验器源代码目录 | `src/validator` |
| `build` | 编译输出目录 | `classes/xmerge` |
| `bin` | 依赖库目录 | `lib` |
| `output` | 最终输出目录 | `xdbmerge` |

---

## 5. 配置与使用

### 5.1 基本命令格式

#### 完整合并模式（默认）
```bash
java -cp gs.jar -jar xmerge.jar -conf xmerge.xml -srcdb <src_db_dir> -destdb <dest_db_dir> -resultdb <result_db_dir> [-dest_foreigndb <foreign_db_dir>]
```

#### 仅检测模式
```bash
java -cp gs.jar -jar xmerge.jar -conf xmerge.xml -check -srcdb <src_db_dir> -destdb <dest_db_dir> -resultdb <result_db_dir>
```

**参数说明**：
- `-conf <xmerge.xml>`：合并配置文件（必需）
- `-srcdb <src_db_dir>`：源数据库目录路径（必需）
- `-destdb <dest_db_dir>`：目标数据库目录路径（必需）
- `-resultdb <result_db_dir>`：结果数据库输出目录（必需）
- `-check`：仅检测冲突模式，不执行合并（可选）
- `-dest_foreigndb <foreign_db_dir>`：外键关系数据库输出目录（可选，不指定则自动生成）

**重要提示**：
- 工具会自动备份源数据库到 `src1dbbackup/` 目录
- 原始 src_db 和 dest_db 不会被修改
- 实际合并操作在备份数据上进行

### 5.2 配置文件格式 (xmerge.xml)

#### 基本结构
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xmerge>
    <!-- 已知冲突表：需要自定义合并逻辑 -->
    <table name="user" type="known_key_conflict" class="mymerge.UserMergeImplement"/>
    <table name="guild" type="known_key_conflict" class="mymerge.GuildMergeImplement"/>

    <!-- 清空表：合并前清空目标表 -->
    <table name="temp_cache" type="clean_table"/>

    <!-- 预处理表：合并前执行自定义逻辑 -->
    <table name="ranking" type="preprocess_table" class="mymerge.RankingPreprocess"/>

    <!-- 未配置的表默认为 unknown_key_conflict（发现冲突则报错） -->
</xmerge>
```

#### 表类型说明

| 类型 | 说明 | 示例场景 |
|-----|------|---------|
| `known_key_conflict` | 已知冲突表，需要提供 IMerge 实现类 | user, guild, clan |
| `unknown_key_conflict` | 未知冲突表（默认），发现冲突则进入修复流程 | role, item, quest |
| `clean_table` | 清空表，合并前删除目标表所有数据 | temp_cache, session |
| `preprocess_table` | 预处理表，合并前执行自定义逻辑 | ranking, statistics |

### 5.3 自定义合并逻辑 (IMerge 接口)

#### 接口定义
```java
package xmerge;

import com.locojoy.base.Marshal.OctetsStream;

public interface IMerge {
    /**
     * 合并已知冲突的记录
     * @param src_key    源数据库的主键（只读）
     * @param src_value  源数据库的值（只读）
     * @param dest_value 目标数据库的值（可修改，作为输出）
     * @return true 合并成功，false 合并失败（记录到日志）
     * @throws Exception 严重错误（会终止合并流程）
     */
    boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception;
}
```

#### 实现示例 1：用户表合并
```java
package mymerge;

import com.locojoy.base.Marshal.OctetsStream;
import xbean.User;

public class UserMergeImplement implements xmerge.IMerge {
    @Override
    public boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception {

        // 反序列化数据
        User srcUser = new User();
        User destUser = new User();
        srcUser.unmarshal(src_value);
        destUser.unmarshal(dest_value);

        // 业务规则：保留等级高的角色
        if (srcUser.getLevel() > destUser.getLevel()) {
            destUser.setLevel(srcUser.getLevel());
            destUser.setExp(srcUser.getExp());
        }

        // 业务规则：合并货币（金币/钻石累加）
        destUser.setGold(destUser.getGold() + srcUser.getGold());
        destUser.setDiamond(destUser.getDiamond() + srcUser.getDiamond());

        // 业务规则：合并 VIP 时长
        destUser.setVipExpireTime(
            Math.max(destUser.getVipExpireTime(), srcUser.getVipExpireTime())
        );

        // 序列化回 dest_value
        dest_value.clear();
        destUser.marshal(dest_value);

        return true; // 合并成功
    }
}
```

#### 实现示例 2：公会表合并
```java
package mymerge;

import com.locojoy.base.Marshal.OctetsStream;
import xbean.Guild;

public class GuildMergeImplement implements xmerge.IMerge {
    @Override
    public boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception {

        Guild srcGuild = new Guild();
        Guild destGuild = new Guild();
        srcGuild.unmarshal(src_value);
        destGuild.unmarshal(dest_value);

        // 业务规则：保留成员数多的公会
        if (srcGuild.getMemberCount() > destGuild.getMemberCount()) {
            // 替换为源公会数据
            dest_value.clear();
            srcGuild.marshal(dest_value);
            return true;
        }

        // 业务规则：保留等级高的公会
        if (srcGuild.getLevel() > destGuild.getLevel()) {
            dest_value.clear();
            srcGuild.marshal(dest_value);
            return true;
        }

        // 冲突无法自动解决，记录到日志
        mkdb.Trace.warn("Guild merge conflict: " + srcGuild.getName() + " vs " + destGuild.getName());
        return false; // 合并失败，但不终止流程
    }
}
```

### 5.4 执行流程详解

#### 5.4.1 完整合并流程（默认模式）
```
1. 备份阶段
   ├─ 创建 src1dbbackup/ 目录
   ├─ 复制 src_db → src1dbbackup/
   └─ 后续操作在备份数据上进行

2. 第一次合并尝试
   ├─ 预处理表（preprocess_table）
   ├─ 清空表（clean_table）
   ├─ 合并已知冲突表（known_key_conflict）
   ├─ 合并未知冲突表（unknown_key_conflict）
   └─ 如果成功 → 输出 result_db，流程结束

3. 冲突检测阶段（第一次合并失败）
   ├─ 回滚所有修改
   ├─ 扫描 src_db 和 dest_db
   ├─ 记录所有重复键到 error_keys_db
   └─ 生成冲突报告

4. 外键校验阶段
   ├─ 扫描 error_keys_db
   ├─ 查找所有外键引用关系
   └─ 输出到 foreign_db

5. 冲突修复阶段
   ├─ 读取 error_keys_db 中的冲突键
   ├─ 为每个冲突键分配新的唯一主键
   ├─ 更新源数据库中的冲突记录
   └─ 更新所有外键引用

6. 第二次合并尝试
   ├─ 使用修复后的 src_db
   ├─ 重新执行合并流程
   └─ 如果成功 → 输出 result_db

7. 清理阶段
   ├─ 删除临时数据库（error_keys_db）
   ├─ 删除外键数据库（如果是自动生成）
   └─ 保留备份数据（src1dbbackup/）
```

#### 5.4.2 仅检测模式（-check 参数）
```
1. 备份阶段（同完整流程）

2. 冲突检测阶段
   ├─ 扫描 src_db 和 dest_db
   ├─ 记录所有重复键到 error_keys_db
   └─ 输出冲突报告

3. 输出结果
   ├─ 显示 error_keys_db 路径
   └─ 流程结束（不执行修复和合并）
```

### 5.5 输出说明

#### 成功场景输出
```
Merge Start
preprocess table success: ranking
clear table success: temp_cache
Merge table start: user
Merge user finish
Merge table start: guild
Merge guild finish
...
Perfect... ... Merge OK, Output DB is E:\result_db
总耗时: 120 秒
```

#### 失败场景输出（需要修复）
```
Merge Start
Merge Error goto Check... ...
merge error.both db has been backuped at Folder backup
Check output errKeyDB: E:\error_keys_db
Check OK goto Repair... ...
validate errKeyDB start... ...
validate errKeyDB over... ...
Repair OK goto merge... ...
Merge after repair OK... ...
OUTPUTDIR is E:\result_db
总耗时: 240 秒
```

---

## 6. 外键校验工具 (ForeignValidator)

### 6.1 工具说明
ForeignValidator 是独立的外键关系校验工具，用于验证数据库中的外键引用完整性。

### 6.2 命令格式
```bash
java -jar foreignValidator.jar -v <validate_db_dir> [-output <foreign_db_dir>]
```

**参数说明**：
- `-v <validate_db_dir>`：要校验外键关系完整性的数据库目录路径（必需）
- `-output <foreign_db_dir>`：输出包含外键关系错误数据记录的数据库目录（可选）

### 6.3 使用示例

#### 仅校验模式
```bash
# 校验数据库外键完整性
java -jar foreignValidator.jar -v /data/result_db

# 输出示例：
# validate start... ...
# Table: role, Foreign key errors: 0
# Table: item, Foreign key errors: 3
# validate over... ...
```

#### 输出错误数据模式
```bash
# 校验并输出错误数据
java -jar foreignValidator.jar -v /data/result_db -output /data/foreign_errors

# 生成 /data/foreign_errors/ 数据库，包含所有外键错误的记录
```

---

## 7. 注意事项

### 7.1 已知限制

#### 功能限制
- **数据库结构版本**：源数据库和目标数据库必须使用相同的表结构版本，否则需要重新编译工具
- **仅支持 XDB**：当前版本仅支持 XDB 数据库格式，不支持其他数据库类型
- **无并发支持**：合并过程为单线程顺序执行，大数据库合并耗时较长
- **内存限制**：大表合并时可能需要较大内存（建议 JVM -Xmx4G 以上）

#### 数据完整性限制
- **外键嵌套结构**：某些以二进制方式存储的嵌套外键无法自动修复，需要游戏逻辑手动处理
- **自定义数据结构**：xdb 中不透明的数据结构（如 Octets 字段）内的外键引用无法检测

### 7.2 安全注意事项

#### 数据备份
- **务必在生产环境执行前进行完整数据库备份**
- 工具虽然会自动备份 src_db，但建议手动额外备份

#### 验证流程
1. **测试环境验证**：在测试环境使用生产数据副本测试合并流程
2. **分阶段执行**：先使用 -check 模式检测冲突
3. **结果验证**：合并后使用 ForeignValidator 验证外键完整性

---

## 8. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | newxmerge (新版游戏服务器合服工具) |
| **代码位置** | `server/tools/newxmerge/` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, XDB, JNI, Ant |
| **依赖库** | gs.jar, jio.jar, monkeyking.jar |

---

## 9. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器运维团队
- 查看项目 Wiki 获取更多文档

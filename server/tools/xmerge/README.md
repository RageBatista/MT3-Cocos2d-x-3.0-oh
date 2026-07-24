# xmerge - XDB 游戏服务器数据库合并工具

## 1. 工具概述

### 1.1 用途说明
xmerge 是 XDB 数据库的游戏服务器合并工具，用于将两个独立运行的游戏服务器数据库合并为一个统一的数据库。这是游戏运营中常见的需求，例如服务器合并、跨服活动、数据迁移等场景。

**核心功能**:
- **数据库合并**: 将两个 XDB 数据库（src_db + dest_db）合并为一个新数据库（result_db）
- **键冲突处理**: 支持自定义冲突键（known_key_conflict）的处理逻辑
- **自动键重分配**: 对于未预料的冲突键（unknown_key_conflict），自动分配新键
- **外键验证**: 通过 validator 工具验证数据库外键引用完整性
- **检查模式**: 支持仅检查冲突而不执行合并的预检模式
- **数据完整性**: 合并过程中保证源数据库不被修改

**解决的问题**:
- 游戏服务器合并（合服）时的数据整合
- 跨服数据迁移
- 测试环境和生产环境数据合并
- 角色 ID、账号 ID 等主键冲突的自动处理
- 外键引用关系的完整性验证

**典型使用场景**:
- 游戏合服：将多个小区服务器合并为一个大区
- 跨服活动：临时合并多个服务器数据
- 数据迁移：将旧服数据迁移到新服
- 测试验证：合并测试数据验证业务逻辑

### 1.2 关键特性
- **零数据损失**: 源数据库和目标数据库在合并过程中不被修改
- **可扩展**: 支持自定义键冲突处理逻辑（IMerge 接口）
- **灵活键分配**: 支持自定义键生成器（IAllocator 接口）
- **外键完整性**: 配套 validator 工具验证外键关系
- **批处理支持**: 提供 shell 脚本自动化合并流程
- **冲突报告**: 详细记录键冲突和处理结果

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
xmerge 位于 MT3 **游戏运营与数据维护层**:

```
┌─────────────────────────────────────────────────────────────┐
│         游戏运营场景（Game Operations）                      │
│  合服、跨服活动、数据迁移                                    │
└────────────────┬────────────────────────────────────────────┘
                 │ 数据整合需求
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              xmerge 数据库合并工具                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   合并流程                                           │   │
│  │                                                     │   │
│  │   输入:                                             │   │
│  │   ┌─────────────────┐  ┌─────────────────┐       │   │
│  │   │  src_db (服务器A) │  │ dest_db (服务器B) │       │   │
│  │   │  角色: 1001-2000 │  │ 角色: 1001-2000  │       │   │
│  │   │  家族: 100-200   │  │ 家族: 100-200    │       │   │
│  │   └─────────────────┘  └─────────────────┘       │   │
│  │           ↓                     ↓                  │   │
│  │   ┌──────────────────────────────────────┐        │   │
│  │   │  冲突检测与处理                       │        │   │
│  │   │  - known_key_conflict (预定义处理)  │        │   │
│  │   │  - unknown_key_conflict (自动重分配) │        │   │
│  │   └──────────────────────────────────────┘        │   │
│  │           ↓                                        │   │
│  │   输出:                                             │   │
│  │   ┌─────────────────────────────────────┐         │   │
│  │   │  result_db (合并后)                  │         │   │
│  │   │  角色: 1001-2000 (A) + 3001-4000 (B) │         │   │
│  │   │  家族: 100-200 (A) + 300-400 (B)     │         │   │
│  │   └─────────────────────────────────────┘         │   │
│  └─────────────────────────────────────────────────────┘   │
│                 │                                            │
│                 ↓ 外键验证                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   validator 外键完整性验证工具                       │   │
│  │   - 检查角色 → 家族引用是否完整                      │   │
│  │   - 检查配偶 → 角色引用是否完整                      │   │
│  │   - 生成外键关系数据库（foreign_db）                 │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────┬────────────────────────────────────────────┘
                 │ 依赖
                 ↓
┌─────────────────────────────────────────────────────────────┐
│       XDB 数据库引擎 + 游戏业务逻辑 (mylogic.jar)            │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **操作对象**:
  - 源数据库（src_db）- 只读，不修改
  - 目标数据库（dest_db）- 只读，不修改
  - 结果数据库（result_db）- 合并后的新数据库

- **依赖模块**:
  - `xdb.jar` / `monkeyking.jar` - XDB 数据库引擎
  - `jio.jar` - I/O 工具库
  - `mylogic.jar` - 游戏业务逻辑（XBean/XTable + IMerge 实现）

- **数据流**:
  - 配置加载: xmerge.xml → 表冲突策略配置
  - 合并流程: src_db + dest_db → 键冲突检测 → IMerge 处理 → result_db
  - 外键验证: result_db → validator → foreign_db (外键关系数据库)

### 2.3 关键代码位置

| 功能模块 | 文件路径 | 关键类/方法 |
|---------|---------|------------|
| 程序入口 | [src/xmerge/Main.java](src/xmerge/Main.java#L1-L51) | `Main.main()` |
| 合并引擎 | [src/xmerge/Xmerge.java](src/xmerge/Xmerge.java) | `Xmerge.run()` |
| 合并器接口 | [src/xmerge/IMerge.java](src/xmerge/IMerge.java) | `IMerge.merge()` |
| 键分配器接口 | [src/xmerge/IAllocator.java](src/xmerge/IAllocator.java) | `IAllocator.allocateKey()` |
| 键分配器管理 | [src/xmerge/Allocators.java](src/xmerge/Allocators.java) | 键生成器集合管理 |
| 冲突检测 | [src/xmerge/CheckDupKey.java](src/xmerge/CheckDupKey.java) | 重复键检测逻辑 |
| 合并器注册 | [src/xmerge/KnownMergers.java](src/xmerge/KnownMergers.java) | 已知冲突处理器管理 |
| 配置管理 | [src/xmerge/XmergeConf.java](src/xmerge/XmergeConf.java) | 配置文件解析 |
| 外键验证入口 | [src/validator/Main.java](src/validator/Main.java) | validator 主程序 |
| 外键验证器 | [src/validator/ForeignValidator.java](src/validator/ForeignValidator.java) | 外键完整性验证 |
| 测试用例 | [test/src/XmergeTestSuite.java](test/src/XmergeTestSuite.java) | 完整测试套件 |
| IMerge 示例 | [test/mylogic/UserMergeImplement.java](test/mylogic/UserMergeImplement.java) | 冲突处理实现示例 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**: JDK/JRE 1.6 及以上
- **必需库文件**:
  - `xdb.jar` 或 `monkeyking.jar` - XDB 数据库引擎
  - `jio.jar` - I/O 工具库
  - `mylogic.jar` - 游戏业务逻辑（用户提供，包含 XBean/XTable 和 IMerge 实现）

### 3.2 构建步骤

#### 使用 Ant 构建

```bash
# 1. 构建 xmerge.jar（合并工具）
ant -f build.xml install

# 2. 构建 validator.jar（外键验证工具）
ant -f build-validator.xml install

# 3. 构建 mylogic.jar（用户业务逻辑，示例）
ant -f build-ml.xml install

# 构建产物位置:
# - xmerge.jar → ../bin/xmerge.jar
# - validator.jar → ../bin/validator.jar
# - mylogic.jar → test/mylogic.jar
```

#### 手动构建（无 Ant）

```bash
# 1. 编译 xmerge 主程序
mkdir -p classes
javac -encoding GBK \
      -cp ../bin/jio.jar:../bin/xdb.jar \
      -d classes \
      src/xmerge/*.java

# 2. 打包 xmerge.jar
jar cvf xmerge.jar -C classes xmerge

# 3. 编译 validator
javac -encoding GBK \
      -cp ../bin/jio.jar:../bin/xdb.jar:xmerge.jar \
      -d classes \
      src/validator/*.java

# 4. 打包 validator.jar
jar cvf validator.jar -C classes validator

# 5. 编译 mylogic（示例）
javac -encoding GBK \
      -cp ../bin/jio.jar:../bin/xdb.jar:xmerge.jar:generated-src \
      -d classes \
      test/mylogic/*.java

# 6. 打包 mylogic.jar
jar cvf mylogic.jar -C classes .
```

---

## 4. 配置与使用

### 4.1 xmerge.xml 配置文件详解

#### 基本结构

```xml
<?xml version="1.0" encoding="gbk"?>
<xmerge libpath="../bin" srcDir="SrcTmp" destDir="DstTmp" resultDir="resultDB">

    <!-- 已知冲突表（需要自定义处理逻辑） -->
    <table name="user" type="known_key_conflict" class="mylogic.UserMerger"/>
    <table name="family" type="known_key_conflict" class="mylogic.FamilyMerger"/>

    <!-- 未知冲突表（自动重分配键） -->
    <!-- 不配置的表默认为 unknown_key_conflict -->

    <!-- 自定义键分配器 -->
    <allocator name="long_key" class="mylogic.LongAllocator"/>
    <allocator name="string_key" class="mylogic.StringAllocator"/>

</xmerge>
```

**配置属性说明**:

| 属性 | 说明 | 示例值 | 必需 |
|-----|------|--------|------|
| `libpath` | XDB 库文件所在目录 | `../bin` | ✅ |
| `srcDir` | 源数据库目录 | `SrcTmp` | ✅ |
| `destDir` | 目标数据库目录 | `DstTmp` | ✅ |
| `resultDir` | 合并结果数据库目录 | `resultDB` | ✅ |

**注意**:
- 命令行参数 `-srcdb`, `-destdb` 可以覆盖 XML 中的 `srcDir`, `destDir`
- `resultDir` 会在合并成功后自动创建

#### 表配置

**known_key_conflict 表**（已知冲突，需自定义处理）:
```xml
<table name="user"              <!-- 表名 -->
       type="known_key_conflict"  <!-- 冲突类型 -->
       class="mylogic.UserMerger"/> <!-- 处理类（实现 IMerge 接口） -->
```

**使用场景**:
- 关键业务表（用户、角色、家族等）
- 需要复杂合并逻辑（如属性累加、数据合并）
- 需要业务规则判断（如 VIP 等级高的保留）

**unknown_key_conflict 表**（未知冲突，自动处理）:
```xml
<!-- 不需要显式配置，未配置的表默认为 unknown_key_conflict -->
<!-- xmerge 会自动为冲突键分配新的唯一键 -->
```

**使用场景**:
- 非关键业务表
- 简单的查找表、配置表
- 可以接受键值变化的表

#### 键分配器配置

```xml
<allocator name="family_id" class="mylogic.FamilyIdAllocator"/>
```

**用途**:
- 为 unknown_key_conflict 表的冲突键提供自定义键生成逻辑
- 替代默认的随机键分配策略
- 适用于有特定键规则的表（如自增 ID、特定前缀等）

### 4.2 IMerge 接口实现

#### 接口定义

```java
package xmerge;

import jio.common.OctetsStream;

public interface IMerge {
    /**
     * 处理键冲突的合并逻辑
     *
     * @param src_key 冲突的键（来自 src_db 和 dest_db 的相同键）
     * @param src_value 源数据库中该键的值（未序列化）
     * @param dest_value 目标数据库中该键的值（未序列化）
     * @return
     *   true: 使用 dest_value 作为合并后的值
     *   false: 跳过该键（记录冲突日志），稍后生成新键重新合并
     * @throws Exception 抛出异常时，合并过程中断
     * @note src_value 和 dest_value 都是经过序列化的 OctetsStream
     */
    boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception;
}
```

#### 实现示例 1: 简单保留目标值

```java
package mylogic;

import xmerge.IMerge;
import jio.common.OctetsStream;

public class UserMergeImplementReturnTrue implements IMerge {
    @Override
    public boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception {
        // 总是保留 dest_db 的值
        return true;
    }
}
```

#### 实现示例 2: 反序列化后比较

```java
package mylogic;

import xmerge.IMerge;
import jio.common.OctetsStream;
import xbean.UserInfo;  // 假设 UserInfo 是用户表的 XBean

public class UserMerger implements IMerge {
    @Override
    public boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception {
        // 反序列化
        UserInfo srcUser = new UserInfo();
        UserInfo destUser = new UserInfo();

        srcUser.unmarshal(new OctetsStream(src_value));
        destUser.unmarshal(new OctetsStream(dest_value));

        // 业务逻辑: 保留 VIP 等级高的用户
        if (srcUser.getVipLevel() > destUser.getVipLevel()) {
            // 将 src 的值写入 dest_value（修改引用）
            dest_value.clear();
            srcUser.marshal(dest_value);
        }

        return true;  // 使用 dest_value 作为最终值
    }
}
```

#### 实现示例 3: 属性累加

```java
package mylogic;

import xmerge.IMerge;
import jio.common.OctetsStream;
import xbean.FamilyInfo;

public class FamilyMerger implements IMerge {
    @Override
    public boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception {
        FamilyInfo srcFamily = new FamilyInfo();
        FamilyInfo destFamily = new FamilyInfo();

        srcFamily.unmarshal(new OctetsStream(src_value));
        destFamily.unmarshal(new OctetsStream(dest_value));

        // 合并成员列表（去重）
        destFamily.getMembers().addAll(srcFamily.getMembers());

        // 贡献度累加
        destFamily.setContribution(
            destFamily.getContribution() + srcFamily.getContribution()
        );

        // 序列化回 dest_value
        dest_value.clear();
        destFamily.marshal(dest_value);

        return true;
    }
}
```

#### 实现示例 4: 跳过冲突键

```java
package mylogic;

import xmerge.IMerge;
import jio.common.OctetsStream;

public class UserMergeImplementReturnFalse implements IMerge {
    @Override
    public boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception {
        // 跳过该键，不合并
        // xmerge 会记录冲突日志，并尝试为该键分配新的唯一键
        return false;
    }
}
```

### 4.3 IAllocator 接口实现

#### 接口定义

```java
package xmerge;

public interface IAllocator {
    /**
     * 为冲突键生成新的唯一键
     *
     * @param tableName 表名
     * @param oldKey 旧的冲突键
     * @return 新的唯一键
     */
    Object allocateKey(String tableName, Object oldKey);
}
```

#### 实现示例 1: 随机 Long 键

```java
package mylogic;

import xmerge.IAllocator;
import java.util.Random;

public class LongAllocator implements IAllocator {
    private Random random = new Random();

    @Override
    public Object allocateKey(String tableName, Object oldKey) {
        // 生成一个随机的 long 键
        // 实际使用中应确保唯一性（如查询已有键）
        return random.nextLong();
    }
}
```

#### 实现示例 2: 递增 Long 键

```java
package mylogic;

import xmerge.IAllocator;
import java.util.concurrent.atomic.AtomicLong;

public class IncrementalAllocator implements IAllocator {
    private AtomicLong counter = new AtomicLong(1000000);  // 从 1000000 开始

    @Override
    public Object allocateKey(String tableName, Object oldKey) {
        return counter.getAndIncrement();
    }
}
```

#### 实现示例 3: 带前缀的 String 键

```java
package mylogic;

import xmerge.IAllocator;
import java.util.UUID;

public class StringAllocator implements IAllocator {
    @Override
    public Object allocateKey(String tableName, Object oldKey) {
        // 生成带前缀的 UUID
        return "MERGED_" + UUID.randomUUID().toString();
    }
}
```

### 4.4 命令行使用

#### 基本语法

```bash
java -jar xmerge.jar -conf <xmerge.xml> [选项]
```

#### 参数说明

| 参数 | 说明 | 必需 |
|-----|------|------|
| `-conf <xml>` | 配置文件路径 | ✅ |
| `-srcdb <dir>` | 源数据库目录（覆盖 XML 配置） | ❌ |
| `-destdb <dir>` | 目标数据库目录（覆盖 XML 配置） | ❌ |
| `-dest_foreigndb <dir>` | 外键数据库目录（可选） | ❌ |
| `-check` | 仅检查冲突，不执行合并 | ❌ |

#### 使用示例

**示例 1: 基本合并**
```bash
java -Xmx512m -Xms512m -Xss4m \
     -cp mylogic.jar \
     -jar xmerge.jar \
     -conf xmerge.xml \
     -srcdb /data/server1/xdb \
     -destdb /data/server2/xdb
```

**示例 2: 仅检查冲突（不合并）**
```bash
java -cp mylogic.jar \
     -jar xmerge.jar \
     -conf xmerge.xml \
     -srcdb /data/server1/xdb \
     -destdb /data/server2/xdb \
     -check
```

**输出**:
```
检测到冲突键:
  表 user: 123 条冲突
  表 family: 45 条冲突
总冲突数: 168 条
```

**示例 3: 使用 Shell 脚本（推荐）**
```bash
# xmerge.sh（位于 snail/bin/）
./xmerge.sh mylogic.jar \
            -conf xmerge.xml \
            -srcdb /data/server1/xdb \
            -destdb /data/server2/xdb \
            -libpath ../bin
```

**示例 4: 完整合服流程**
```bash
#!/bin/bash
# merge-servers.sh - 游戏合服自动化脚本

echo "========================================="
echo " 游戏服务器合并工具"
echo "========================================="

# 配置
SRC_DB="/data/game_server_1/xdb"
DEST_DB="/data/game_server_2/xdb"
RESULT_DB="/data/merged_server/xdb"
MYLOGIC_JAR="mylogic.jar"
CONF="xmerge.xml"

# 步骤 1: 检查冲突
echo "步骤 1: 检查键冲突..."
java -cp $MYLOGIC_JAR -jar xmerge.jar \
     -conf $CONF \
     -srcdb $SRC_DB \
     -destdb $DEST_DB \
     -check

if [ $? -ne 0 ]; then
    echo "错误: 冲突检查失败"
    exit 1
fi

# 步骤 2: 备份数据库
echo "步骤 2: 备份源数据库..."
cp -r $SRC_DB ${SRC_DB}.backup.$(date +%Y%m%d)
cp -r $DEST_DB ${DEST_DB}.backup.$(date +%Y%m%d)

# 步骤 3: 执行合并
echo "步骤 3: 执行数据库合并..."
java -Xmx2g -Xms2g -Xss4m \
     -cp $MYLOGIC_JAR \
     -jar xmerge.jar \
     -conf $CONF \
     -srcdb $SRC_DB \
     -destdb $DEST_DB

if [ $? -ne 0 ]; then
    echo "错误: 合并失败"
    exit 1
fi

# 步骤 4: 外键验证
echo "步骤 4: 验证外键完整性..."
java -Xmx1g -Xms1g \
     -jar validator.jar \
     -v $RESULT_DB \
     -output ${RESULT_DB}_foreign

if [ $? -ne 0 ]; then
    echo "警告: 外键验证发现问题，请检查 validate.log"
fi

echo "合并完成！结果数据库: $RESULT_DB"
```

### 4.5 validator 外键验证工具

#### 用途
验证数据库中的外键引用关系是否完整，例如:
- TableA(key) ← TableB(key/value)
- 外键关系: TableB 的 key 或 value 引用 TableA 的 key
- 完整性要求: TableB 中所有外键必须在 TableA 的 key 集合中存在

#### 使用方法

```bash
# 基本验证（仅检查，输出日志到 validate.log）
java -Xmx512m -Xms512m -Xss4m \
     -jar validator.jar \
     -v /data/merged_server/xdb

# 生成外键关系数据库
java -Xmx512m -Xms512m -Xss4m \
     -jar validator.jar \
     -v /data/merged_server/xdb \
     -output /data/foreign_db
```

#### 参数说明

| 参数 | 说明 | 必需 |
|-----|------|------|
| `-v <dir>` | 要验证的数据库目录 | ✅ |
| `-output <dir>` | 输出外键关系数据库目录 | ❌ |

#### 输出示例

**validate.log** (外键错误日志):
```
[ERROR] Table 'role' foreign key error:
  - 键: 12345
  - 外键字段: familyId
  - 引用值: 999
  - 错误: family 表中不存在 ID 999

[ERROR] Table 'spouse' foreign key error:
  - 键: 67890
  - 外键字段: husbandId
  - 引用值: 54321
  - 错误: role 表中不存在 ID 54321

总错误数: 2 条
```

---

## 5. 输入输出规范

### 5.1 输入文件

#### xmerge.xml 配置文件
- **编码**: GBK
- **格式**: XML 1.0
- **必需元素**: `<xmerge>`, `<table>`, `<allocator>` (可选)

#### mylogic.jar 业务逻辑包
- **内容**: XBean、XTable 类 + IMerge/IAllocator 实现类
- **编译**: 依赖 xdb.jar, jio.jar, xmerge.jar

#### 数据库目录
- **src_db**: 源数据库（只读）
- **dest_db**: 目标数据库（只读）
- **结构**: 符合 XDB 规范的数据库目录

### 5.2 输出文件

#### result_db 合并结果数据库
```
resultDB/                       # 合并后的数据库
├── table/
│   ├── user/                   # 用户表数据（合并后）
│   ├── family/                 # 家族表数据（合并后）
│   ├── role/                   # 角色表数据（合并后）
│   └── ...
├── log/                        # 事务日志
├── mkdb.inuse                  # 锁文件
└── metadata.xml                # 元数据
```

#### 冲突报告（控制台输出）
```
开始合并...
表 user: 检测到 123 个键冲突
  - 使用 mylogic.UserMerger 处理
  - 处理成功: 120 个
  - 跳过重分配: 3 个
表 family: 检测到 45 个键冲突
  - 使用 mylogic.FamilyMerger 处理
  - 处理成功: 45 个
表 item: 未配置处理器，自动重分配 78 个冲突键
合并完成！
```

#### foreign_db 外键关系数据库（可选）
```
foreign_db/                     # 外键关系数据库
├── table/
│   ├── role_family/            # 角色→家族外键关系
│   ├── spouse_role/            # 配偶→角色外键关系
│   └── ...
└── metadata.xml
```

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制
- **XDB 专用**: 仅支持 XDB 数据库，不支持其他数据库格式
- **单机运行**: 不支持分布式合并
- **内存限制**: 大型数据库需要足够的 JVM 堆内存
- **不支持增量**: 每次合并都是全量合并，不支持增量更新

#### 性能限制
- **合并速度**: 取决于数据库大小和键冲突数量
- **内存占用**: 需要同时加载两个数据库的元数据
- **磁盘 I/O**: 大量读写操作，建议使用 SSD

### 6.2 性能考虑

#### 影响合并性能的因素

```yaml
数据量:
  - 表数量 (越多越慢)
  - 记录数量 (越多越慢)
  - 单条记录大小 (越大越慢)

键冲突:
  - 冲突键数量 (越多越慢)
  - IMerge 处理复杂度 (越复杂越慢)

硬件:
  - CPU 核心数 (单线程，影响有限)
  - 内存大小 (不足会导致频繁 GC)
  - 磁盘速度 (HDD vs SSD 差异显著)
```

#### 性能优化建议

```yaml
JVM 参数优化:
  - "-Xmx2g -Xms2g": 增加堆内存（大型数据库建议 4g+）
  - "-Xss4m": 增加栈大小（深度递归场景）
  - "-XX:+UseConcMarkSweepGC": 使用 CMS 垃圾回收器

配置优化:
  - "减少 known_key_conflict 表": IMerge 处理开销大
  - "简化 IMerge 逻辑": 避免复杂计算和数据库查询
  - "使用高效的 IAllocator": 避免全表扫描

数据准备:
  - "清理无用数据": 合并前删除过期数据
  - "预处理冲突": 手动解决部分已知冲突
  - "分批合并": 大型数据库分多次合并
```

### 6.3 安全注意事项

#### 数据安全

```yaml
critical_warnings:
  - "合并前务必备份源数据库和目标数据库"
  - "验证 mylogic.jar 中 IMerge 实现的正确性"
  - "合并前在测试环境充分测试"
  - "合并后验证关键业务数据的完整性"

best_practices:
  - "使用 -check 模式先检查冲突"
  - "合并后使用 validator 验证外键"
  - "保留 3-5 份历史备份"
  - "记录合并操作日志（时间、参数、结果）"
```

#### 业务安全

```yaml
game_operations:
  - "合服前通知玩家，做好数据备份"
  - "选择低峰期进行合并（凌晨 2-4 点）"
  - "合并后进行全面功能测试"
  - "准备回滚方案（如合并失败）"

data_integrity:
  - "验证玩家资产（金币、道具、等级）"
  - "验证社交关系（好友、家族、配偶）"
  - "验证排行榜数据"
  - "验证邮件和聊天记录"
```

### 6.4 故障排查指南

#### 问题 1: "java.lang.OutOfMemoryError: Java heap space"

**症状**:
```
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
    at xmerge.Xmerge.run(...)
```

**原因**:
- JVM 堆内存不足
- 数据库过大

**解决方案**:
```bash
# 增加堆内存
java -Xmx4g -Xms4g -Xss4m \
     -cp mylogic.jar \
     -jar xmerge.jar \
     -conf xmerge.xml \
     -srcdb src_db \
     -destdb dest_db

# 如果仍不足，考虑分批合并或升级硬件
```

#### 问题 2: "ClassNotFoundException: mylogic.UserMerger"

**症状**:
```
java.lang.ClassNotFoundException: mylogic.UserMerger
    at java.net.URLClassLoader.findClass(...)
```

**原因**:
- mylogic.jar 未包含在 classpath
- 类名拼写错误

**解决方案**:
```bash
# 检查 classpath
java -cp mylogic.jar -jar xmerge.jar ...

# 检查 mylogic.jar 内容
jar tf mylogic.jar | grep UserMerger

# 确认类名拼写与 xmerge.xml 一致
```

#### 问题 3: 合并后外键验证失败

**症状**:
```
[ERROR] Table 'role' foreign key error:
  - 键: 12345
  - 外键字段: familyId
  - 引用值: 999
  - 错误: family 表中不存在 ID 999
```

**原因**:
- IMerge 实现错误，未更新外键引用
- IAllocator 生成的新键未同步更新外键

**解决方案**:
```java
// 在 IMerge 实现中同步更新外键
public class RoleMerger implements IMerge {
    @Override
    public boolean merge(OctetsStream src_key, OctetsStream src_value, OctetsStream dest_value)
        throws Exception {
        Role srcRole = new Role();
        srcRole.unmarshal(new OctetsStream(src_value));

        // 如果 familyId 是外键，需要映射到新的 family ID
        Long oldFamilyId = srcRole.getFamilyId();
        Long newFamilyId = FamilyIdMapper.getNewId(oldFamilyId);  // 使用映射表
        srcRole.setFamilyId(newFamilyId);

        // 序列化
        dest_value.clear();
        srcRole.marshal(dest_value);
        return true;
    }
}
```

#### 问题 4: 合并速度极慢

**症状**:
- 合并 1GB 数据库耗时超过 1 小时
- CPU 占用低（< 30%）

**可能原因和排查**:
```bash
# 1. 检查磁盘 I/O
iostat -x 1
# 如果 %util 接近 100%，磁盘是瓶颈 → 使用 SSD

# 2. 检查 GC 频率
jstat -gcutil <pid> 1000
# 如果 Full GC 频繁 → 增加堆内存

# 3. 检查 IMerge 逻辑
# 如果 IMerge 中有复杂计算或数据库查询 → 优化逻辑

# 4. 检查冲突键数量
# 使用 -check 模式查看冲突数量
# 如果冲突过多 → 考虑分批合并
```

---

## 7. 扩展与改进

### 7.1 推荐改进方向

#### 短期优化 (1-2 周)
1. **增强日志输出**:
   - 添加详细的进度条
   - 记录每个表的处理时间
   - 输出冲突键详细信息到文件

2. **错误恢复机制**:
   - 支持断点续传
   - 自动重试失败的键合并
   - 生成未合并键列表

3. **性能指标收集**:
   - 统计合并速度（记录/秒）
   - 记录内存峰值
   - 输出性能报告

#### 中期优化 (1-2 个月)
4. **并行合并**:
   - 多线程并行处理不同表
   - 提高 CPU 利用率
   - 缩短合并时间

5. **增量合并**:
   - 支持仅合并变化的数据
   - 记录上次合并的时间戳
   - 适用于定期同步场景

6. **Web 管理界面**:
   - 可视化配置 xmerge.xml
   - 实时监控合并进度
   - 查看历史合并记录

### 7.2 扩展示例

#### 扩展 1: 带进度条的合并器

```java
public class ProgressXmerge {
    public void runWithProgress(String configFile) {
        Xmerge worker = new Xmerge(configFile);

        // 获取表列表和总记录数
        List<String> tables = worker.getTables();
        long totalRecords = worker.getTotalRecords();

        // 进度回调
        worker.setProgressCallback((tableName, processed, total) -> {
            int percentage = (int) (processed * 100.0 / total);
            System.out.printf("\r处理表 %s: %d/%d (%d%%)",
                tableName, processed, total, percentage);
        });

        worker.run();
        System.out.println("\n合并完成！");
    }
}
```

#### 扩展 2: 冲突报告生成器

```java
public class ConflictReporter {
    private Map<String, List<Object>> conflicts = new HashMap<>();

    public void recordConflict(String tableName, Object key) {
        conflicts.computeIfAbsent(tableName, k -> new ArrayList<>()).add(key);
    }

    public void generateReport(String outputFile) throws IOException {
        try (PrintWriter writer = new PrintWriter(outputFile)) {
            writer.println("冲突键报告");
            writer.println("生成时间: " + new Date());
            writer.println("========================================");

            for (Map.Entry<String, List<Object>> entry : conflicts.entrySet()) {
                writer.printf("表: %s\n", entry.getKey());
                writer.printf("冲突数: %d\n", entry.getValue().size());
                writer.println("冲突键列表:");
                for (Object key : entry.getValue()) {
                    writer.printf("  - %s\n", key);
                }
                writer.println();
            }
        }
    }
}
```

---

## 8. 快速参考

### 8.1 常用命令速查表

```bash
# 基本合并
java -cp mylogic.jar -jar xmerge.jar -conf xmerge.xml -srcdb src_db -destdb dest_db

# 仅检查冲突
java -cp mylogic.jar -jar xmerge.jar -conf xmerge.xml -srcdb src_db -destdb dest_db -check

# 外键验证
java -jar validator.jar -v result_db -output foreign_db

# 构建工具
ant -f build.xml install               # 构建 xmerge.jar
ant -f build-validator.xml install     # 构建 validator.jar
ant -f build-ml.xml install            # 构建 mylogic.jar（示例）
```

### 8.2 配置速查

```xml
<!-- xmerge.xml 最小配置 -->
<xmerge libpath="../bin" srcDir="SrcDB" destDir="DestDB" resultDir="ResultDB">
    <!-- 所有表默认 unknown_key_conflict，自动处理 -->
</xmerge>

<!-- xmerge.xml 完整配置 -->
<xmerge libpath="../bin" srcDir="SrcDB" destDir="DestDB" resultDir="ResultDB">
    <table name="user" type="known_key_conflict" class="mylogic.UserMerger"/>
    <table name="family" type="known_key_conflict" class="mylogic.FamilyMerger"/>
    <allocator name="long_key" class="mylogic.LongAllocator"/>
</xmerge>
```

### 8.3 故障排查速查

| 问题 | 检查项 | 命令 |
|-----|-------|------|
| 内存溢出 | JVM 堆内存 | `java -Xmx4g ...` |
| ClassNotFoundException | classpath | `java -cp mylogic.jar -jar xmerge.jar ...` |
| 外键验证失败 | IMerge 实现 | 检查外键更新逻辑 |
| 合并速度慢 | 磁盘 I/O | `iostat -x 1` |
| 冲突过多 | 冲突数量 | 使用 `-check` 模式统计 |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | xmerge (XDB Game Server Database Merge Tool) |
| **主要功能** | XDB 数据库合并、键冲突处理、外键验证 |
| **核心组件** | xmerge.jar, validator.jar, mylogic.jar (用户提供) |
| **接口** | IMerge (键冲突处理), IAllocator (键生成器) |
| **依赖库** | xdb.jar, jio.jar |
| **代码位置** | `server/tools/xmerge/` |
| **配置文件** | `xmerge.xml` |
| **构建工具** | Apache Ant |
| **应用场景** | 游戏合服、跨服活动、数据迁移 |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏运营支持团队
- 技术支持: leiyu01471@locojoy.com, caijiacheng01470@locojoy.com, zhangxi01469@locojoy.com
- 查看 README 文件获取更多使用说明

---

**文档版本**: v1.0
**维护者**: MT3 开发团队
**最后更新**: 2025-11-27

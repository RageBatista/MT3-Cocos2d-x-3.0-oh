# xdbench - XDB 性能基准测试工具

## 1. 工具概述

### 1.1 用途说明
xdbench 是 XDB（基于 mkdb 的文件数据库）的性能基准测试工具，用于评估数据库在各种负载场景下的性能表现。它通过模拟真实游戏场景的数据操作来测试数据库的吞吐量、延迟和稳定性。

**核心功能**:
- **性能测试**: 测量事务吞吐量 (TPS) 和操作延迟
- **压力测试**: 模拟高并发场景下的数据库表现
- **缓存测试**: 测试 Cache Miss 和 Storage 操作性能
- **基准建立**: 为数据库优化建立性能基线
- **真实场景**: 使用游戏实际数据结构（角色、装备、宠物等）

**解决的问题**:
- 数据库性能瓶颈识别
- 配置参数优化验证
- 版本升级前后性能对比
- 负载容量规划
- 内存/磁盘 I/O 平衡调优

**典型使用场景**:
- 新版本发布前性能验证
- 硬件配置选型
- 数据库参数调优
- 性能回归测试
- 容量规划评估

### 1.2 关键特性
- **真实数据结构**: 使用梦幻西游游戏的真实 XBean 定义
- **多场景测试**: AddStorageMiss、Memory、Ostream 等不同场景
- **并发测试**: 支持异步并发事务测试
- **指标收集**: TPS、错误率、延迟统计
- **可配置**: 通过 xdb.xml 调整测试参数
- **自动化**: Ant 构建脚本支持自动化测试流程

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
xdbench 位于 MT3 **性能测试与优化层**:

```
┌─────────────────────────────────────────────────────────────┐
│         游戏服务器生产环境（Production Game Servers）        │
│  使用 XDB 存储海量游戏数据（角色、装备、任务等）              │
└────────────────┬────────────────────────────────────────────┘
                 │ 性能要求
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              xdbench 性能测试工具                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   测试场景                                           │   │
│  │   - AddStorageMiss (Cache Miss 写入测试)           │   │
│  │   - Memory (内存操作测试)                           │   │
│  │   - Ostream (输出流测试)                            │   │
│  │                                                     │   │
│  │   测试数据结构 (xdb.xml)                            │   │
│  │   - 16个游戏业务表 (team, basic, user, family...)  │   │
│  │   - 33个 XBean 定义 (Role, Properties, Pet...)    │   │
│  │   - 真实游戏数据模型                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                 │                                            │
│                 ↓ 性能指标                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   性能报告                                           │   │
│  │   - TPS: ~50,000/s (AddStorageMiss 场景)           │   │
│  │   - 并发测试: 100,000 事务                          │   │
│  │   - 错误率统计                                       │   │
│  │   - 延迟分布                                         │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────┬────────────────────────────────────────────┘
                 │ 依赖
                 ↓
┌─────────────────────────────────────────────────────────────┐
│       XDB 数据库引擎 (xdb.jar + jio.jar)                     │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **测试目标**:
  - XDB 数据库引擎 - 核心测试对象
  - 游戏业务数据结构 - 真实场景模拟

- **依赖模块**:
  - `xdb.jar` - XDB 数据库引擎
  - `jio.jar` - I/O 工具库
  - `xdb.xml` - 数据库配置和表结构定义

- **数据流**:
  - 测试启动: xdb.xml 加载 → XDB 引擎启动 → 测试线程池初始化
  - 测试执行: 并发事务提交 → 事务处理 → 性能指标收集
  - 结果输出: 完成事件回调 → 统计计算 → 性能报告输出

### 2.3 关键代码位置

| 功能模块 | 文件路径 | 关键类/方法 |
|---------|---------|------------|
| Cache Miss 测试 | [src/bench/AddStorageMiss.java](src/bench/AddStorageMiss.java#L13-L56) | `AddStorageMiss.main()` |
| 测试事务 | [src/bench/AddStorageMiss.java](src/bench/AddStorageMiss.java#L15-L21) | `Add` 内部类 (继承 `xdb.Procedure`) |
| 并发控制 | [src/bench/AddStorageMiss.java](src/bench/AddStorageMiss.java#L22-L35) | 原子计数器 + 回调机制 |
| 内存测试 | [src/bench/Memory.java](src/bench/Memory.java) | 内存操作性能测试 |
| 输出流测试 | [src/bench/Ostream.java](src/bench/Ostream.java) | 输出流性能测试 |
| 数据库配置 | [xdb.xml](xdb.xml#L1-L545) | 完整游戏数据结构定义 |
| 构建脚本 | [build.xml](build.xml#L1-L32) | Ant 编译配置 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**: JDK/JRE 1.6 及以上
- **必需库文件**:
  - `../bin/xdb.jar` - XDB 数据库引擎
  - `../bin/jio.jar` - I/O 工具库
- **配置文件**:
  - `xdb.xml` - 数据库配置和表结构定义

### 3.2 构建步骤

#### 使用 Ant 构建
```bash
# 1. 初始化并编译
ant compile

# 构建过程会:
# - 创建 classes/ 输出目录
# - 创建 xdb/ 数据库目录
# - 创建 xbackup/ 备份目录
# - 编译 src/ 下所有 Java 源码

# 2. 清理构建产物
ant clean
```

#### 手动构建（无 Ant）
```bash
# 1. 创建必要目录
mkdir -p classes xdb xbackup

# 2. 生成 XBean 和 XTable 代码
java -jar ../bin/xdb.jar xdb.xml -noverify

# 3. 编译 Java 源代码（注意 GBK 编码）
javac -encoding GBK \
      -cp ../bin/jio.jar:../bin/xdb.jar \
      -d classes \
      -Xlint:unchecked \
      src/bench/*.java \
      src/xbean/*.java \
      src/xbean/__/*.java \
      src/xtable/*.java

# Windows 版本
javac -encoding GBK ^
      -cp ..\bin\jio.jar;..\bin\xdb.jar ^
      -d classes ^
      -Xlint:unchecked ^
      src\bench\*.java src\xbean\*.java src\xbean\__\*.java src\xtable\*.java
```

---

## 4. 配置与使用

### 4.1 xdb.xml 配置详解

#### 基本配置
```xml
<xdb
xgenOutput="../xdbench/src"
trace="fatal"                   <!-- 日志级别: fatal/error/warn/info/debug -->
traceTo=":out:file"             <!-- 日志输出: 控制台+文件 -->
corePoolSize="5"                <!-- 核心线程池大小 -->
dbhome="xdb"                    <!-- 数据库主目录 -->
logpages="4096"                 <!-- 日志缓冲页数 -->
backupDir="xbackup"             <!-- 备份目录 -->
flushFatalTime="1000"           <!-- 致命错误刷新时间(ms) -->
flushPeriod="5000"              <!-- 刷新周期(ms) -->
checkpointPeriod="60000"        <!-- 检查点周期(ms) -->
backupIncPeriod="600000"        <!-- 增量备份周期(ms) -->
backupFullPeriod="3600000"      <!-- 全量备份周期(ms) -->
angelPeriod="5000"              <!-- Angel监控周期(ms) -->
>
```

**配置参数说明**:

| 参数 | 说明 | 推荐值 | 影响 |
|-----|------|--------|------|
| `corePoolSize` | 核心线程池大小 | 5-20 | 影响并发事务处理能力 |
| `logpages` | 日志缓冲页数 | 4096-8192 | 影响写入性能和内存占用 |
| `flushPeriod` | 刷新周期(ms) | 5000 | 影响数据持久化延迟 |
| `checkpointPeriod` | 检查点周期(ms) | 60000 | 影响恢复时间和写入放大 |
| `trace` | 日志级别 | `fatal` (测试) / `debug` (调试) | 影响日志量和性能 |

#### 存储过程配置
```xml
<ProcedureConf
    executionTime="300"     <!-- 执行超时(ms) -->
    retryTimes="3"          <!-- 重试次数 -->
    retryDelay="100"        <!-- 重试延迟(ms) -->
/>
```

#### 游戏数据表结构

**核心业务表**（16张表）:

1. **team** (队伍表) - MEMORY 持久化
```xml
<xbean name="Team">
    <variable name="name" type="string"/>
    <variable name="members" type="vector" value="int"/>
    <variable name="templeave" type="set" value="int"/>
    <variable name="grid" type="int"/>
</xbean>

<table name="team" key="long" value="Team"
       persistence="MEMORY"          <!-- 仅内存存储 -->
       cacheCapacity="0"             <!-- 无缓存限制 -->
       cachehigh="128" cachelow="64"/>
```

2. **basic** (角色基础信息表)
```xml
<xbean name="Basic">
    <enum name="FEMALE" value="1"/>
    <enum name="MALE"   value="0"/>
    <enum name="MENPAI_00" vname="无门无派" value="0"/>
    <!-- 12个门派枚举定义 -->

    <variable name="name" type="string"/>
    <variable name="race" type="int"/>
    <variable name="sex" type="int"/>
    <variable name="modelid" type="int"/>           <!-- 模型 -->
    <variable name="toufa_yanse" type="int"/>       <!-- 头发颜色 -->
    <variable name="yifu_yanse" type="int"/>        <!-- 衣服颜色 -->
    <variable name="createtime" type="int"/>
</xbean>

<table name="basic" key="int" value="Basic"
       cacheCapacity="20480" cachehigh="128" cachelow="64"/>
```

3. **properties** (角色属性表)
```xml
<xbean name="Properties">
    <!-- 等级相关 -->
    <variable name="level" type="int"/>
    <variable name="experience" type="int"/>
    <variable name="vitality" type="int"/>

    <!-- 基础属性 -->
    <variable name="strength" type="int"/>          <!-- 力量 -->
    <variable name="dexterity" type="int"/>         <!-- 敏捷 -->
    <variable name="health" type="int"/>            <!-- 体质 -->
    <variable name="spiritualism" type="int"/>      <!-- 灵力 -->
    <variable name="resistance" type="int"/>        <!-- 耐力 -->

    <!-- HP/MP -->
    <variable name="hpmaxbase" type="int"/>
    <variable name="hpmaxnow" type="int"/>
    <variable name="hp" type="int"/>
    <variable name="mp" type="int"/>

    <!-- 移动信息 -->
    <variable name="moveinfo" type="MoveInfo"/>

    <!-- 社交关系 -->
    <variable name="familyid" type="int"/>          <!-- 家族 -->
    <variable name="factionid" type="int"/>         <!-- 帮派 -->
    <variable name="materoleid" type="int"/>        <!-- 配偶 -->

    <!-- 战斗相关 -->
    <variable name="petfight" type="int"/>
    <variable name="petshow" type="int"/>
    <variable name="logout_time" type="long"/>
</xbean>

<table name="properties" key="int" value="Properties"
       cacheCapacity="20480" cachehigh="128" cachelow="64"/>
```

4. **family** (家族表) - 自增主键
```xml
<xbean name="Family">
    <variable name="id" type="int"/>
    <variable name="level" type="int"/>
    <variable name="contribution" type="int"/>      <!-- 贡献度 -->
    <variable name="leaderid" type="int"/>          <!-- 族长 -->
    <variable name="viceLeader" type="list" value="int"/>   <!-- 副族长(2) -->
    <variable name="directors" type="list" value="int"/>    <!-- 长老(4) -->
    <variable name="name" type="string"/>
    <variable name="aim" type="string"/>            <!-- 宗旨 -->
    <variable name="pub" type="string"/>            <!-- 公告 -->
    <variable name="memebers" type="map" key="int" value="MemberInfo"/>
    <variable name="status" type="int"/>            <!-- 是否解散 -->
    <variable name="create_time" type="long"/>
    <variable name="money" type="int"/>
</xbean>

<table name="family" key="long" value="Family"
       autoIncrement="true"          <!-- 自增长主键 -->
       cacheCapacity="1000" cachehigh="128" cachelow="64"/>
```

5. **bag/pets/depot/equip** (背包系列表)
```xml
<xbean name="Bag">
    <variable name="version" type="int"/>
    <variable name="money" type="int"/>
    <variable name="passwd" type="string"/>
    <variable name="capacity" type="int"/>
    <variable name="nextid" type="int"/>
    <variable name="items" type="map" key="int" value="BagItem"/>
</xbean>

<!-- 4个背包表使用相同结构 -->
<table name="pets"  key="int" value="Bag" cacheCapacity="20480" .../>
<table name="bag"   key="int" value="Bag" cacheCapacity="20480" .../>
<table name="depot" key="int" value="Bag" cacheCapacity="20480" .../>
<table name="equip" key="int" value="Bag" cacheCapacity="20480" .../>
```

6. **task** (任务数据表)
```xml
<xbean name="PlayerTaskData">
    <variable name="m_mapGraphID2TaskStatus" type="map" key="int" value="TaskGraphStatus"/>
    <variable name="m_ringLevel" type="int"/>
    <variable name="m_ringSequence" type="int"/>
    <variable name="m_graphtimestamp" type="map" key="int" value="long"/>
    <variable name="m_graphcounter" type="map" key="int" value="int"/>
    <variable name="m_mapStoreTask" type="map" key="int" value="StoreTask"/>
</xbean>

<table name="task" key="int" value="PlayerTaskData"
       cacheCapacity="20480" cachehigh="128" cachelow="64"/>
```

7. **其他业务表**:
   - `user` - 账号角色列表
   - `uniqname` - 角色名到ID映射
   - `skills` - 技能表
   - `produce` - 生产技能表
   - `friends` - 好友表
   - `spouse` - 配偶表
   - `swornbrother` - 结义表

### 4.2 测试场景使用

#### 场景 1: AddStorageMiss - Cache Miss 写入测试

**用途**: 测试当记录不在 cache 且 storage 中也不存在时的插入性能

**特点**:
- 每次插入新记录，100% Cache Miss
- 触发完整的 storage 写入流程
- 测试数据库写入吞吐量上限

**运行**:
```bash
# 编译后运行
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss

# Windows 版本
java -cp classes;..\bin\xdb.jar;..\bin\jio.jar bench.AddStorageMiss
```

**测试流程**:
```java
// 1. 初始化数据库
xdb.XdbConf xdbConf = new xdb.XdbConf("../xdbench/xdb.xml");
xdb.Xdb.getInstance().setConf(xdbConf);
xdb.Xdb.getInstance().start();

// 2. 并发提交 100,000 个事务
int count = 100000;
for (int i = 0; i < count; ++i) {
    xdb.Procedure.execute(new Add(), done);
}

// 3. 等待所有事务完成
synchronized (done) {
    done.wait();
}

// 4. 输出性能报告
xdb.Trace.error("end jobs=" + jobs + " error=" + error);
```

**Add 事务定义**:
```java
static class Add extends xdb.Procedure {
    @Override
    protected boolean process() throws Exception {
        // 插入新 Family 记录（自增主键）
        xtable.Family.insert(xbean.Pod.newFamily());
        return false;  // 异步事务
    }
}
```

**预期性能**:
- **TPS**: ~50,000/s（根据代码注释）
- **并发**: 100,000 事务
- **错误率**: 统计失败事务数
- **延迟**: 通过回调统计端到端延迟

**输出示例**:
```
start
... (日志输出)
end jobs=0 error=0
```

#### 场景 2: Memory - 内存操作测试

**用途**: 测试纯内存操作性能（未实现完整代码）

**特点**:
- 使用 `persistence="MEMORY"` 的 team 表
- 不涉及磁盘 I/O
- 测试内存操作极限性能

#### 场景 3: Ostream - 输出流测试

**用途**: 测试输出流性能（未实现完整代码）

### 4.3 性能调优参数

#### 调优目标 1: 提升 TPS（吞吐量）

**策略**:
```xml
<!-- 增加线程池大小 -->
<xdb corePoolSize="20" ... >  <!-- 默认 5，增加到 20 -->

<!-- 增加日志缓冲 -->
<xdb logpages="8192" ... >    <!-- 默认 4096，加倍到 8192 -->

<!-- 降低刷新频率 -->
<xdb flushPeriod="10000" ... >  <!-- 默认 5秒，延长到 10秒 -->

<!-- 增加检查点间隔 -->
<xdb checkpointPeriod="120000" ... >  <!-- 默认 60秒，延长到 120秒 -->
```

**权衡**:
- ✅ 提升: 吞吐量提升 20-50%
- ⚠️ 代价: 内存占用增加，恢复时间延长

#### 调优目标 2: 降低延迟

**策略**:
```xml
<!-- 快速刷新 -->
<xdb flushPeriod="1000" ... >  <!-- 1秒刷新 -->

<!-- 降低检查点间隔 -->
<xdb checkpointPeriod="30000" ... >  <!-- 30秒检查点 -->

<!-- 减少日志缓冲 -->
<xdb logpages="2048" ... >  <!-- 减少到 2048 页 -->
```

**权衡**:
- ✅ 提升: 延迟降低 30-50%
- ⚠️ 代价: 吞吐量下降，I/O 压力增加

#### 调优目标 3: 平衡模式

**策略**:
```xml
<!-- 平衡配置 -->
<xdb
corePoolSize="10"
logpages="4096"
flushPeriod="5000"
checkpointPeriod="60000"
backupIncPeriod="600000"
backupFullPeriod="3600000"
>
```

### 4.4 使用流程

#### 完整测试流程

```bash
# 步骤 1: 清理旧数据
ant clean

# 步骤 2: 编译测试代码
ant compile

# 步骤 3: 运行基准测试
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss

# 步骤 4: 分析性能报告
# 查看 TPS、错误率、延迟等指标

# 步骤 5: 调整配置参数
nano xdb.xml  # 修改 corePoolSize, logpages 等参数

# 步骤 6: 重新测试验证
ant clean && ant compile
java -cp classes:../bin:xdb.jar:../bin/jio.jar bench.AddStorageMiss

# 步骤 7: 对比性能差异
```

#### 批处理脚本示例 (Linux/macOS)

```bash
#!/bin/bash
# benchmark.sh - 自动化基准测试脚本

echo "========================================="
echo " XDB Benchmark Suite"
echo "========================================="

# 清理和编译
echo "Building..."
ant clean && ant compile || exit 1

# 测试场景 1: AddStorageMiss
echo ""
echo "Running AddStorageMiss test..."
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss | tee result_addmiss.log

# 测试场景 2: Memory (如果实现)
# echo ""
# echo "Running Memory test..."
# java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.Memory | tee result_memory.log

echo ""
echo "Benchmark completed. Results saved to result_*.log"
```

#### Windows 批处理脚本示例

```batch
@echo off
REM benchmark.bat - Windows 自动化测试脚本

echo =========================================
echo  XDB Benchmark Suite
echo =========================================

REM 清理和编译
echo Building...
call ant clean
call ant compile
if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

REM 运行 AddStorageMiss 测试
echo.
echo Running AddStorageMiss test...
java -cp classes;..\bin\xdb.jar;..\bin\jio.jar bench.AddStorageMiss > result_addmiss.log 2>&1

echo.
echo Benchmark completed. Results saved to result_addmiss.log
pause
```

---

## 5. 输入输出规范

### 5.1 输入文件

#### xdb.xml 配置文件
- **编码**: GBK（硬编码）
- **格式**: 符合 XDB XML Schema
- **必需元素**: `<xdb>`, `<xbean>`, `<table>`
- **路径**: `../xdbench/xdb.xml`（相对于测试代码）

### 5.2 输出格式

#### 控制台输出
```
start                          # 测试开始标记
... (XDB 内部日志)
end jobs=0 error=0             # 测试结束，jobs=剩余任务数，error=错误数
```

**关键指标**:
- `jobs`: 剩余任务数（应为 0）
- `error`: 失败事务数（理想为 0）
- 从 "start" 到 "end" 的时间间隔 → 计算 TPS

**TPS 计算**:
```
TPS = 总事务数 / 总耗时(秒)

示例:
  总事务数: 100,000
  总耗时: 2秒
  TPS = 100,000 / 2 = 50,000/s
```

#### 数据库文件输出

```
xdb/                            # 数据库主目录
├── table/
│   ├── team/                   # team 表数据
│   ├── basic/                  # basic 表数据
│   ├── properties/             # properties 表数据
│   ├── family/                 # family 表数据（测试产生）
│   └── ...                     # 其他表
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
- **场景不完整**: Memory 和 Ostream 场景未实现完整代码
- **指标简单**: 仅统计 TPS 和错误率，缺少详细延迟分布
- **单机测试**: 不支持分布式性能测试
- **固定数据**: 使用固定的游戏数据结构，通用性有限

#### 测试限制
- **预热不足**: 未实现 JVM 预热逻辑
- **无监控集成**: 不自动收集 CPU/内存/I/O 指标
- **结果未持久化**: 性能数据仅打印到控制台
- **无可视化**: 缺少图表和趋势分析

### 6.2 性能考虑

#### 影响测试结果的因素

```yaml
硬件因素:
  - CPU 核心数和频率 (影响事务并发处理)
  - 内存大小 (影响缓存容量)
  - 磁盘类型 (HDD vs SSD vs NVMe，影响 I/O 延迟)
  - 网络延迟 (如果涉及远程服务)

软件因素:
  - JVM 版本和参数 (-Xmx, -XX:+UseConcMarkSweepGC)
  - 操作系统调度策略
  - 文件系统类型 (ext4, xfs, NTFS)
  - 后台进程负载

配置因素:
  - corePoolSize (线程池大小)
  - logpages (日志缓冲)
  - cacheCapacity (缓存容量)
  - flushPeriod (刷新周期)
```

#### 测试最佳实践

```yaml
环境准备:
  - "关闭不必要的后台程序"
  - "固定 CPU 频率（禁用省电模式）"
  - "使用专用测试机器"
  - "预热 JVM（运行 2-3 次测试再记录结果）"

数据采集:
  - "多次测试取平均值（至少 5 次）"
  - "记录峰值和谷值"
  - "监控系统资源占用"
  - "使用相同的测试数据量"

结果分析:
  - "对比不同配置的 TPS"
  - "分析错误率和失败原因"
  - "识别性能瓶颈（CPU/内存/I/O）"
  - "绘制性能趋势图"
```

### 6.3 安全注意事项

#### 测试数据安全

```yaml
warning:
  - "测试会清空 xdb 目录，注意备份重要数据"
  - "不要在生产数据库上运行测试"
  - "测试数据包含游戏业务结构，注意保密"

best_practices:
  - "使用独立的测试环境"
  - "测试前备份数据"
  - "测试后清理敏感数据"
  - "控制测试脚本的访问权限"
```

### 6.4 故障排查指南

#### 问题 1: "java.lang.OutOfMemoryError: Java heap space"

**症状**:
```
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
    at xdb.Procedure.execute(...)
```

**原因**:
- 并发事务数过多
- JVM 堆内存不足
- 缓存配置过大

**解决方案**:
```bash
# 1. 增加 JVM 堆内存
java -Xms1g -Xmx4g -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss

# 2. 减少并发事务数
# 修改 AddStorageMiss.java 中的 count 值
int count = 10000;  // 从 100000 降低到 10000

# 3. 调整缓存配置
# 降低 xdb.xml 中的 cacheCapacity
<table name="family" ... cacheCapacity="100" .../>
```

#### 问题 2: "mkdb is still in active use"

**症状**:
```
ERROR: mkdb is still in active use
```

**原因**:
- 上次测试未正常关闭数据库
- mkdb.inuse 锁文件残留

**解决方案**:
```bash
# 删除锁文件
rm xdb/mkdb.inuse

# 或清理整个数据库目录
ant clean
```

#### 问题 3: 性能远低于预期

**症状**:
- TPS < 10,000/s（预期 ~50,000/s）
- 测试耗时过长

**可能原因和排查**:
```bash
# 1. 检查 CPU 占用
top -p $(pgrep java)
# 如果 CPU < 50%，可能是配置问题

# 2. 检查磁盘 I/O
iostat -x 1
# 如果 %util 接近 100%，磁盘是瓶颈

# 3. 检查线程池配置
grep corePoolSize xdb.xml
# 如果值过小（如 1-2），增加到 10-20

# 4. 检查日志级别
grep trace xdb.xml
# 如果是 "debug"，改为 "fatal" 减少日志开销

# 5. 检查文件系统
df -T xdb/
# 确认不是网络文件系统（NFS, CIFS）
```

#### 问题 4: 编译失败 - "找不到符号"

**症状**:
```
error: cannot find symbol
  symbol:   class Family
  location: class xtable
```

**原因**:
- 未生成 XBean 和 XTable 代码

**解决方案**:
```bash
# 生成 XBean 和 XTable 代码
java -jar ../bin/xdb.jar xdb.xml -noverify

# 验证生成的代码
ls -l src/xbean/ src/xtable/

# 重新编译
ant clean && ant compile
```

---

## 7. 扩展与改进

### 7.1 推荐改进方向

#### 短期优化 (1-2 周)
1. **完善测试场景**:
   - 实现 Memory 场景的完整测试代码
   - 实现 Ostream 场景的完整测试代码
   - 添加 GetStorageMiss/RemoveStorageMiss 场景

2. **增强指标收集**:
   - 记录详细延迟分布（P50, P95, P99）
   - 统计 TPS 随时间变化
   - 收集 CPU/内存/I/O 指标

3. **结果持久化**:
   - 输出 JSON/CSV 格式的性能报告
   - 保存历史测试结果
   - 生成对比报告

#### 中期优化 (1-2 个月)
4. **可视化报告**:
   - 生成性能趋势图表
   - 提供 Web 界面查看结果
   - 集成到 CI/CD 流程

5. **自动化测试套件**:
   - 参数化测试配置
   - 批量运行多组测试
   - 自动识别性能回归

6. **压力测试增强**:
   - 模拟真实用户行为模式
   - 支持混合读写场景
   - 测试极限负载和恢复能力

### 7.2 扩展示例

#### 扩展 1: 添加延迟统计

```java
public class AddStorageMissWithLatency {

    // 延迟直方图
    java.util.concurrent.ConcurrentHashMap<Long, AtomicInteger> latencyHistogram =
        new java.util.concurrent.ConcurrentHashMap<>();

    static class Add extends xdb.Procedure {
        long startTime;

        @Override
        protected boolean process() throws Exception {
            startTime = System.nanoTime();
            xtable.Family.insert(xbean.Pod.newFamily());
            return false;
        }
    }

    xdb.Procedure.Done<Add> done = new xdb.Procedure.Done<Add>() {
        @Override
        public void doDone(Add p) {
            // 计算延迟（毫秒）
            long latency = (System.nanoTime() - p.startTime) / 1_000_000;
            latencyHistogram.computeIfAbsent(latency, k -> new AtomicInteger()).incrementAndGet();

            // ... 原有逻辑
        }
    };

    void printLatencyStats() {
        System.out.println("Latency Distribution:");
        latencyHistogram.entrySet().stream()
            .sorted(Map.Entry.comparingByKey())
            .forEach(e -> System.out.printf("%d ms: %d\n", e.getKey(), e.getValue().get()));
    }
}
```

#### 扩展 2: JSON 格式输出

```java
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class BenchmarkResult {
    String testName;
    long totalTransactions;
    long totalTimeMs;
    double tps;
    int errorCount;
    Map<String, Object> config;
    Map<Long, Integer> latencyHistogram;

    public void saveToFile(String filename) throws IOException {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String json = gson.toJson(this);
        Files.write(Paths.get(filename), json.getBytes());
    }
}
```

---

## 8. 快速参考

### 8.1 常用命令速查表

```bash
# 构建和清理
ant compile               # 编译测试代码
ant clean                 # 清理构建产物和数据库

# 运行测试
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.Memory
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.Ostream

# 性能分析
top -p $(pgrep java)      # 监控 CPU 占用
iostat -x 1               # 监控磁盘 I/O
jstat -gcutil <pid> 1000  # 监控 GC 统计

# 数据库管理
rm xdb/mkdb.inuse         # 删除锁文件
ls -lh xdb/table/         # 查看表数据大小
du -sh xdb/ xbackup/      # 查看数据库和备份大小
```

### 8.2 配置速查

```xml
<!-- 高吞吐量配置 -->
<xdb corePoolSize="20" logpages="8192" flushPeriod="10000" checkpointPeriod="120000">

<!-- 低延迟配置 -->
<xdb corePoolSize="10" logpages="2048" flushPeriod="1000" checkpointPeriod="30000">

<!-- 平衡配置（默认） -->
<xdb corePoolSize="5" logpages="4096" flushPeriod="5000" checkpointPeriod="60000">
```

### 8.3 故障排查速查

| 问题 | 检查项 | 命令 |
|-----|-------|------|
| 内存溢出 | JVM 堆内存 | `java -Xmx4g ...` |
| 锁文件残留 | mkdb.inuse | `rm xdb/mkdb.inuse` |
| 性能低下 | CPU/I/O | `top`, `iostat -x 1` |
| 编译失败 | 生成代码 | `java -jar ../bin/xdb.jar xdb.xml` |
| 数据库启动失败 | 配置文件 | `cat xdb.xml \| grep trace` |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | xdbench (XDB Performance Benchmark Tool) |
| **主要功能** | XDB 数据库性能基准测试 |
| **测试场景** | AddStorageMiss, Memory, Ostream |
| **数据结构** | 16 张游戏业务表，33 个 XBean 定义 |
| **依赖库** | xdb.jar, jio.jar |
| **代码位置** | `server/tools/xdbench/` |
| **配置文件** | `xdb.xml` |
| **构建工具** | Apache Ant |
| **预期性能** | ~50,000 TPS (AddStorageMiss) |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器性能优化团队
- 查看 XDB 数据库文档获取更多调优建议

---

**文档版本**: v1.0
**维护者**: MT3 开发团队
**最后更新**: 2025-11-27

# calccap - JMX 诊断工具集

## 1. 工具概述

### 1.1 用途说明
calccap (原名 tools.jar) 是一个基于 JMX 的综合诊断与运维工具集，专为 MT3 游戏服务器的 mkdb 数据库应用设计。该工具通过本地 attach 机制或远程 JMX 连接，提供以下核心功能：

- **进程管理**：列出 Java 应用进程、检测 mkdb 应用
- **JMX 浏览**：查看 MBean 域、MBean 列表、属性信息
- **死锁检测**：实时检测线程死锁
- **元数据分析**：计算 mkdb 表容量、缓存占用
- **性能监控**：Top 实时统计类调用和锁竞争
- **远程管理**：Kill 单个或批量 mkdb 应用

### 1.2 典型使用场景
- 运维诊断：快速定位服务器性能瓶颈、死锁问题
- 容量规划：计算 mkdb 表缓存占用，优化内存配置
- 性能分析：实时监控热点类和锁竞争
- 批量管理：安全关闭多个 mkdb 实例
- 开发调试：浏览 JMX MBean，验证数据结构

### 1.3 关键特性
- **多命令集成**：10+ 个子命令，覆盖诊断、监控、管理全流程
- **本地 Attach**：无需 JMX 端口，直接 attach 本地 Java 进程
- **远程连接**：支持通过 JMX 端口远程管理
- **动态加载**：运行时加载 monkeyking.jar 和 jio.jar，访问 mkdb 内部 API
- **无依赖安装**：单个 Jar 包运行，无需安装额外依赖

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
calccap 位于 MT3 服务器架构的**运维诊断层**，与 mkdb 数据库和 JMX 管理端点对接：

```
┌─────────────────────────────────────────┐
│        运维人员 / 自动化脚本            │
└──────────────┬──────────────────────────┘
               │ (执行 calccap.jar 命令)
               ↓
┌─────────────────────────────────────────┐
│           calccap 工具集                │
│  (JMX 客户端 + 本地 Attach + mkdb API)  │
│  - ps: 进程列表                         │
│  - domains/mbeans/attrs: JMX 浏览       │
│  - deadlocked: 死锁检测                 │
│  - mkcap: 元数据分析                    │
│  - top: 性能监控                        │
│  - kill/killall: 远程关闭               │
└──────────────┬──────────────────────────┘
               │ JMX / Local Attach
               ↓
┌─────────────────────────────────────────┐
│      mkdb 数据库应用 JMX MBean          │
│  - mkdb:type=Mkdb (核心管理接口)        │
│  - ThreadMXBean (死锁检测)              │
│  - DatabaseMetaData (表元数据)          │
└─────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **上游依赖**：
  - monkeyking.jar (mkdb 核心库，包含 MBean 和元数据 API)
  - jio.jar (I/O 工具库)
  - JDK tools.jar (本地 attach API)
- **下游消费者**：运维脚本、Shell、PowerShell、监控平台
- **数据流**：
  - 本地模式：通过 Attach API 连接本地 JVM
  - 远程模式：通过 RMI/JMX 协议远程连接

### 2.3 关键代码位置
| 功能模块 | 文件路径 | 关键行号 |
|---------|---------|---------|
| 命令行入口 | [src/snail/tools/Main.java](src/snail/tools/Main.java#L24-L107) | 24-107 |
| 进程列表 (ps) | [src/snail/tools/Ps.java](src/snail/tools/Ps.java#L144-L255) | 144-255 |
| JMX 连接器 | [src/snail/tools/Jmxc.java](src/snail/tools/Jmxc.java) | 全文 |
| 死锁检测 (deadlocked) | [src/snail/tools/Deadlocked.java](src/snail/tools/Deadlocked.java#L11-L19) | 11-19 |
| 元数据分析 (mkcap) | [src/snail/tools/Mkcap.java](src/snail/tools/Mkcap.java#L135-L201) | 135-201 |
| 性能监控 (top) | [src/snail/tools/Top.java](src/snail/tools/Top.java#L55-L101) | 55-101 |
| Kill 应用 (kill) | [src/snail/tools/Kill.java](src/snail/tools/Kill.java#L16-L29) | 16-29 |
| 类路径加载器 | [src/snail/tools/Classpath.java](src/snail/tools/Classpath.java) | 全文 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**：JDK 1.6 及以上（推荐 JDK 8）
  - 需要 JDK（非 JRE），因为依赖 tools.jar 中的 Attach API
- **mkdb 库文件**：
  - monkeyking.jar (mkdb 核心库)
  - jio.jar (I/O 工具库)
  - 默认从 calccap.jar 同目录加载，或通过 `-snail` 参数指定
- **网络连接**（远程模式）：可访问目标服务器的 JMX 端口

### 3.2 构建时依赖
- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac 和 tools.jar）

### 3.3 构建步骤

#### 使用 Ant 构建
```bash
# 清理并构建
ant clean jar

# 输出文件：calccap.jar
```

#### 构建流程说明
构建脚本执行以下步骤：

1. **清理阶段**（clean）：删除旧的 bin/ 目录和 jar 文件
2. **初始化阶段**（init）：创建 bin/ 编译输出目录
3. **编译阶段**（compile）：
   - 编译 `src/**/*.java` → `bin/`
   - 使用 UTF-8 编码
   - 启用调试信息
4. **打包阶段**（jar）：
   - 生成 `calccap.jar`
   - 设置 Main-Class: `snail.tools.Main`

---

## 4. 配置与使用

### 4.1 基本命令格式
```bash
java -jar calccap.jar [main-options] command [command-options]
```

**全局选项**：
- `-snail <dir>`：指定 monkeyking.jar 和 jio.jar 所在目录（默认为 calccap.jar 同目录）

**获取帮助**：
```bash
# 查看所有命令列表
java -jar calccap.jar help

# 查看特定命令帮助
java -jar calccap.jar help <command>
```

### 4.2 支持的功能列表

#### 4.2.1 进程管理功能

**1. 列出 Java 进程 (ps)**
```bash
# 基本用法：列出所有 Java 进程
java -jar calccap.jar ps

# 检测哪些是 mkdb 应用（mk=是 mkdb, -=不是, ?=检测错误）
java -jar calccap.jar ps -mk

# 显示详细信息
java -jar calccap.jar ps -m      # 显示主类参数
java -jar calccap.jar ps -v      # 显示 JVM 参数
java -jar calccap.jar ps -V      # 显示 JVM 标志

# 仅显示进程 ID（安静模式）
java -jar calccap.jar ps -q

# 远程主机
java -jar calccap.jar ps 192.168.1.100:1099
```
- **实现**：`src/snail/tools/Ps.java:144-255`
- **输出示例**：
  ```
  12345       mk  fire.main.GameServer
  12346       -   fire.main.NameServer
  ```

#### 4.2.2 JMX 浏览功能

**2. 查看 JMX 域 (domains)**
```bash
# 本地 attach
java -jar calccap.jar domains -p 12345

# 远程连接
java -jar calccap.jar domains -h 192.168.1.100 -r 1099
```
- **输出**：列出所有 MBean 域名（如 java.lang, mkdb, com.sun.management）

**3. 查看 MBean 列表 (mbeans)**
```bash
# 列出指定域下的所有 MBean
java -jar calccap.jar mbeans -p 12345 -d "mkdb"

# 远程模式
java -jar calccap.jar mbeans -h 192.168.1.100 -r 1099 -d "java.lang"
```
- **输出**：MBean 对象名称列表

**4. 查看 MBean 属性 (attrs)**
```bash
# 查看指定 MBean 的所有属性
java -jar calccap.jar attrs -p 12345 -m "mkdb:type=Mkdb"
```
- **输出**：属性名称、类型、值

#### 4.2.3 诊断功能

**5. 死锁检测 (deadlocked)**
```bash
# 检测是否存在死锁
java -jar calccap.jar deadlocked -p 12345

# 远程检测
java -jar calccap.jar deadlocked -h 192.168.1.100 -r 1099
```
- **实现**：`src/snail/tools/Deadlocked.java:11-19`
- **输出**：`deadlocked = true/false`

**6. mkdb 元数据分析 (mkcap)**
```bash
# 分析 mkdb 表容量和缓存占用
java -jar calccap.jar mkcap \
  -mkdb /path/to/mkdb.xml \
  -mkbean /path/to/mkbeans.jar

# 按缓存占用百分比排序，显示前 10 名
java -jar calccap.jar mkcap \
  -mkdb mkdb.xml \
  -mkbean mkbeans.jar \
  -o "cache%" \
  -n 10
```
- **实现**：`src/snail/tools/Mkcap.java:135-201`
- **参数说明**：
  - `-mkdb <file>`：mkdb 配置文件路径（必需）
  - `-mkbean <classpath>`：mkbeans 类路径（必需）
  - `-o <name>`：排序字段（默认 `cache%`）
    - 支持：`table`、`cache`、`capacity`、`page`
    - 百分比：`table%`、`cache%`、`capacity%`、`page%`
  - `-n <number>`：限制显示行数（默认 0 = 全部）
- **输出示例**：
  ```
  name          table    table%    cache       cache%    capacity    capacity%    page    page%
  tplayer       1024     0.3456    10485760    0.4512    10240       0.3891       256     0.2048
  ...
  -------------------------------------------------------------------
  TOTAL
      cache: 128M page: 64M table<key, value>: 32K<8, 24K>
      TABLE-COUNT: 45
  -------------------------------------------------------------------
  ```

**7. 性能监控 Top (top)**
```bash
# 实时监控类调用和锁竞争
java -jar calccap.jar top -p 12345

# 自定义刷新周期（毫秒）
java -jar calccap.jar top -p 12345 -r 2000

# 限制显示行数
java -jar calccap.jar top -p 12345 -n 5

# 过滤命名空间
java -jar calccap.jar top -p 12345 \
  -sc "mkio.;mkdb." \
  -sl "mkio.;mkdb."

# 显示 [Others] 统计
java -jar calccap.jar top -p 12345 -o
```
- **实现**：`src/snail/tools/Top.java:55-101`
- **参数说明**：
  - `-sc <namespace>`：类命名空间过滤（分号分隔）
  - `-sl <namespace>`：锁命名空间过滤（分号分隔）
  - `-r <period>`：刷新周期（毫秒，默认 1500）
  - `-n <limit>`：显示行数（默认 10）
  - `-o`：显示 [Others] 统计
- **输出示例**：
  ```
  12345 mkio.ByteBuffer.allocate
   8976 mkdb.Table.get
   5432 mkdb.Table.put
   - 3210 - locked <0x12345678> (a mkdb.Table)
   - 1987 - locked <0x87654321> (a mkio.Lock)
  ------------------------------------
  ```

#### 4.2.4 管理功能

**8. Kill 单个应用 (kill)**
```bash
# 本地 kill
java -jar calccap.jar kill -p 12345

# 远程 kill
java -jar calccap.jar kill -h 192.168.1.100 -r 1099
```
- **实现**：`src/snail/tools/Kill.java:16-29`
- **安全机制**：调用 `mkdb:type=Mkdb.shutdown("iamsure")`，确保安全关闭
- **注意**：仅对 mkdb 应用有效

**9. Kill 全部应用 (killall)**
```bash
# Kill 本地所有 mkdb 应用
java -jar calccap.jar killall

# 指定主机
java -jar calccap.jar killall -h 192.168.1.100:1099
```
- **实现**：枚举所有 mkdb 进程并逐个调用 kill
- **安全提示**：生产环境慎用！

### 4.3 JMX 连接选项

所有需要连接 JVM 的命令（除 `ps`）支持以下选项：

| 选项 | 说明 | 示例 |
|-----|------|------|
| `-p <pid>` | 本地进程 ID（Attach 模式） | `-p 12345` |
| `-h <host>` | 远程主机 IP | `-h 192.168.1.100` |
| `-r <port>` | JMX RMI 端口 | `-r 1099` |
| `-u <user>` | JMX 用户名（认证） | `-u admin` |
| `-w <pass>` | JMX 密码（认证） | `-w secret` |

**连接优先级**：
- 本地模式（`-p`）：直接 attach 本地进程，无需 JMX 端口
- 远程模式（`-h` + `-r`）：通过 JMX 协议连接

### 4.4 配置示例

#### 示例 1：诊断死锁并生成报告
```bash
#!/bin/bash
# check_deadlock.sh

PIDS=$(java -jar calccap.jar ps -mk -q | grep mk | awk '{print $1}')

for pid in $PIDS; do
  result=$(java -jar calccap.jar deadlocked -p $pid)
  echo "[$pid] $result"

  if echo "$result" | grep -q "true"; then
    echo "ALERT: Deadlock detected in process $pid!" | mail -s "Deadlock Alert" ops@example.com
  fi
done
```

#### 示例 2：容量规划分析
```bash
# 分析所有表的内存占用，生成 CSV 报告
java -jar calccap.jar mkcap \
  -mkdb /opt/gameserver/config/mkdb.xml \
  -mkbean /opt/gameserver/lib/mkbeans.jar \
  -o "cache%" \
  -n 0 > capacity_report.txt
```

#### 示例 3：性能监控并记录日志
```bash
# 持续监控 10 分钟，记录 Top 10 热点
timeout 600 java -jar calccap.jar top -p 12345 -n 10 -r 5000 > top_$(date +%Y%m%d_%H%M%S).log
```

#### 示例 4：批量安全关闭
```bash
# 先检查进程，再确认后 kill
java -jar calccap.jar ps -mk
read -p "确认 kill 所有 mkdb 应用？(yes/no): " confirm
if [ "$confirm" == "yes" ]; then
  java -jar calccap.jar killall
fi
```

---

## 5. 输入输出规范

### 5.1 标准输入格式
工具不接受标准输入（stdin），所有参数通过命令行参数传递。

### 5.2 标准输出格式

#### 成功场景
| 命令 | 输出格式 | 示例 |
|-----|---------|------|
| ps | `<pid> [mk/-/?] <mainClass>` | `12345 mk fire.main.GameServer` |
| domains | 域名列表 | `mkdb\njava.lang\ncom.sun.management` |
| mbeans | MBean 对象名列表 | `mkdb:type=Mkdb` |
| attrs | 属性表格 | `Name: HeapMemoryUsage, Type: long, Value: 1024` |
| deadlocked | `deadlocked = true/false` | `deadlocked = false` |
| mkcap | 容量分析表格 + 总计 | 见第 4.2.3 节示例 |
| top | 实时统计输出（循环刷新） | 见第 4.2.3 节示例 |
| kill/killall | 无输出（静默成功） | _(空)_ |

#### 失败场景
| 错误类型 | 输出 | 退出码 |
|---------|------|-------|
| 参数不足 | 使用说明 + 命令列表 | 1 |
| 命令不存在 | 使用说明 | 1 |
| 连接失败 | 异常堆栈追踪 | 非 0 |
| JMX 调用失败 | 异常信息 | 非 0 |

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制
- **仅支持 mkdb 应用**：`kill`、`killall`、`top`、`mkcap` 命令需要目标应用暴露 `mkdb:type=Mkdb` MBean
- **动态加载依赖**：必须提供 `monkeyking.jar` 和 `jio.jar`，否则部分命令无法运行
- **本地 Attach 限制**：
  - 需要 JDK（非 JRE）
  - 仅支持同用户进程
  - Windows 下可能需要管理员权限

#### 平台限制
- **Windows**：Attach API 可能不稳定，建议优先使用远程 JMX 模式
- **Linux**：需要 `/tmp/.java_pid<pid>` 文件可访问

### 6.2 性能考虑

#### Top 命令性能影响
- `top` 命令会定期调用 `mkdb:type=Mkdb.top()` 方法，对目标 JVM 产生轻微性能开销
- 建议刷新周期 > 1000ms，避免频繁采样

#### mkcap 命令内存占用
- 分析大量表（> 100 张）时，工具本身会消耗较多内存
- 建议在内存充足的环境运行

### 6.3 安全注意事项

#### Kill 命令风险
- **严禁在生产环境使用 `killall`**：会立即关闭所有 mkdb 应用，可能导致数据丢失
- **生产环境操作**：
  1. 先用 `ps -mk` 确认目标进程
  2. 逐个使用 `kill -p <pid>` 关闭
  3. 确认数据已持久化后再执行

#### 权限管理
- 工具本身无认证机制，通过 JMX 认证控制访问
- 建议限制 JMX 端口访问（防火墙白名单）
- 生产环境启用 JMX SSL/TLS 加密

### 6.4 故障排查指南

#### 问题 1：NoClassDefFoundError (monkeyking.jar 或 jio.jar)
**症状**：执行命令后提示类未找到
```
NoClassDefFoundError: mkdb.MkdbConf
```
**解决方案**：
```bash
# 确认 jar 文件存在
ls -l monkeyking.jar jio.jar

# 使用 -snail 指定目录
java -jar calccap.jar -snail /opt/libs mkcap -mkdb mkdb.xml -mkbean mkbeans.jar
```

#### 问题 2：本地 Attach 失败
**症状**：
```
Unable to open socket file: target process not responding or HotSpot VM not loaded
```
**排查步骤**：
```bash
# 1. 确认进程存在且是 Java 应用
jps -l | grep 12345

# 2. 检查权限（必须同用户）
ps -u $(whoami) | grep 12345

# 3. 确认使用 JDK（非 JRE）
java -version | grep -i jdk

# 4. Windows：以管理员身份运行
# 右键 → 以管理员身份运行 CMD
```

#### 问题 3：JMX 远程连接失败
**症状**：连接超时或认证失败
**排查步骤**：
```bash
# 1. 检查网络连通性
telnet 192.168.1.100 1099

# 2. 确认目标 JVM 启动参数包含：
# -Dcom.sun.management.jmxremote
# -Dcom.sun.management.jmxremote.port=1099
# -Dcom.sun.management.jmxremote.authenticate=false
# -Dcom.sun.management.jmxremote.ssl=false

# 3. 使用正确的用户名/密码
java -jar calccap.jar domains -h 192.168.1.100 -r 1099 -u admin -w password
```

---

## 7. 扩展与改进

### 7.1 当前架构优势
- **插件化设计**：每个命令独立实现 `Tool` 接口，易于扩展新功能
- **统一选项解析**：`Options` 类提供声明式参数定义
- **动态类加载**：支持运行时加载外部依赖

### 7.2 推荐改进方向

#### 短期优化（1-2 周）
1. **日志记录**：增加 `-v` 详细模式，记录连接过程和调用耗时
2. **输出格式**：支持 JSON/CSV 输出，便于自动化解析
3. **批量操作**：支持 `ps` 结果管道传递给 `kill`

#### 中期优化（1-2 个月）
4. **性能优化**：
   - `top` 命令支持增量更新，减少重绘
   - `mkcap` 支持并行分析多个表
5. **可视化**：集成 JFreeChart，生成容量趋势图表
6. **报告生成**：自动生成 HTML/PDF 诊断报告

#### 长期优化（3-6 个月）
7. **监控集成**：
   - 暴露 Prometheus Exporter，导出 mkdb 指标
   - 支持定时采集并推送到 InfluxDB/Grafana
8. **Web UI**：提供简单的 Web 控制台，实现图形化操作
9. **分布式支持**：支持批量连接多个节点，聚合统计

---

## 8. 快速参考

### 8.1 常用命令速查表

```bash
# 列出所有 Java 进程
java -jar calccap.jar ps

# 检测哪些是 mkdb 应用
java -jar calccap.jar ps -mk

# 检查死锁
java -jar calccap.jar deadlocked -p 12345

# 分析表容量
java -jar calccap.jar mkcap -mkdb mkdb.xml -mkbean mkbeans.jar -n 10

# 实时监控性能
java -jar calccap.jar top -p 12345 -n 10

# 查看 JMX 域
java -jar calccap.jar domains -p 12345

# Kill 单个应用
java -jar calccap.jar kill -p 12345

# Kill 全部 mkdb 应用（危险！）
java -jar calccap.jar killall
```

### 8.2 常用参数速查

| 参数 | 说明 | 适用命令 |
|-----|------|---------|
| `-p <pid>` | 本地进程 ID | 所有（除 ps） |
| `-h <host>` | 远程主机 | 所有（除 ps） |
| `-r <port>` | JMX 端口 | 所有（除 ps） |
| `-mk` | 检测 mkdb 应用 | ps |
| `-q` | 安静模式 | ps |
| `-m` | 显示主类参数 | ps |
| `-v` | 显示 JVM 参数 | ps |
| `-mkdb <file>` | mkdb 配置文件 | mkcap |
| `-mkbean <classpath>` | mkbeans 类路径 | mkcap |
| `-o <name>` | 排序字段 | mkcap |
| `-n <number>` | 限制行数 | mkcap, top |
| `-r <period>` | 刷新周期（毫秒） | top |
| `-sc <ns>` | 类命名空间 | top |
| `-sl <ns>` | 锁命名空间 | top |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | calccap (JMX Diagnostic Tools) |
| **原始名称** | tools.jar |
| **版本** | 见最新 Jar 文件时间戳 |
| **主要维护者** | 见项目 Git 提交历史 |
| **代码位置** | `server/tools/calccap/` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, JMX, Attach API, mkdb |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器运维团队
- 查看项目 Wiki 获取更多文档

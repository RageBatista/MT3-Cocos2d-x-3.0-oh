# xbrowse - XDB 数据库可视化浏览器

## 1. 工具概述

### 1.1 用途说明
xbrowse 是一个功能强大的 XDB 数据库可视化浏览与管理工具，专为 MT3 游戏服务器的 XDB 数据库设计。该工具提供 GUI 和命令行两种模式，支持以下核心功能：

- **数据浏览**：可视化查看 mkdb/mbackup 数据库文件中的表和数据
- **XQL 查询**：使用类 SQL 语法（XQL）查询、更新、删除数据
- **JMX 管理**：远程连接游戏服务器，执行 JMX 管理操作
- **对象查看**：反射查看 Java 对象序列化数据，支持嵌套结构
- **数据导出**：批量导出数据库表为 JSON 格式
- **实时监控**：连接运行中的服务器，实时查看和修改数据

### 1.2 典型使用场景
- **数据调试**：开发阶段查看数据库表结构和内容
- **数据修复**：通过 XQL 语句修改错误数据
- **数据分析**：导出 JSON 进行数据统计和分析
- **GM 工具**：通过 JMX 远程执行游戏管理操作
- **故障排查**：查看备份数据，定位问题根因
- **数据迁移**：批量导出导入数据

### 1.3 关键特性
- **双模式运行**：GUI 图形界面 + 命令行批处理模式
- **XQL 查询语言**：类 SQL 语法，支持 WHERE/ORDER BY/LIMIT
- **对象反射**：自动解析 Java Bean 结构，支持集合和嵌套对象
- **JMX 集成**：内置 JMX 客户端，远程管理游戏服务器
- **批量导出**：支持整库导出为 JSON 格式
- **语法高亮**：XQL 语句编辑器支持关键字高亮和行号显示

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
xbrowse 位于 MT3 服务器架构的**数据工具层**，是开发和运维人员的核心数据管理工具：

```
┌─────────────────────────────────────────┐
│      开发人员 / 运维人员 / GM          │
└──────────────┬──────────────────────────┘
               │ (启动 xbrowse)
               ↓
┌─────────────────────────────────────────┐
│           xbrowse 工具                  │
│  ┌────────────┐      ┌────────────┐    │
│  │ GUI 模式    │      │ CLI 模式    │    │
│  │ (Swing)    │      │ (批处理)   │    │
│  └────┬───────┘      └────┬───────┘    │
│       │                   │             │
│  ┌────┴─────┬────────────┴────┐        │
│  │          │                 │         │
│  │ XQL 查询 │ JMX 管理 │ JSON导出│      │
│  └────┬─────┴────┬──────┴─────┘        │
└───────┼──────────┼────────────────────┘
        │          │
        ↓          ↓
┌───────────┐  ┌──────────────┐
│ mkdb/     │  │  游戏服务器   │
│ mbackup   │  │  JMX 端口     │
│ (本地文件)│  │  (远程连接)   │
└───────────┘  └──────────────┘
```

### 2.2 与其他模块的交互
- **数据源**：
  - mkdb 目录（游戏服务器数据库原始文件）
  - mbackup 目录（数据库备份文件）
  - 运行中的游戏服务器（通过 JMX）
- **依赖库**：
  - gsd.jar：游戏数据定义和 XBean 类库
  - jio.jar：XDB 数据库读写引擎
  - 第三方 UI 库：javadocking, json-lib, commons 系列
- **输出**：
  - JSON 文件（数据导出）
  - 控制台输出（命令行模式）
  - GUI 显示（图形界面模式）

### 2.3 关键代码位置
| 功能模块 | 文件路径 | 说明 |
|---------|---------|------|
| 主入口 | [src/com/pwrd/XdbBrowser.java](src/com/pwrd/XdbBrowser.java) | 启动入口，解析命令行参数 |
| GUI 主窗口 | [src/com/pwrd/ui/XdbBrowserFrame.java](src/com/pwrd/ui/XdbBrowserFrame.java) | Swing 主窗口，面板布局 |
| 命令行控制台 | [src/com/pwrd/console/XdbBrowserConsole.java](src/com/pwrd/console/XdbBrowserConsole.java) | CLI 命令解析和执行 |
| XQL 解析器 | [src/com/pwrd/xql/XQLParser.java](src/com/pwrd/xql/XQLParser.java) | XQL 语法解析（YACC 生成）|
| XQL 执行器 | [src/com/pwrd/xql/XQLExecutor.java](src/com/pwrd/xql/XQLExecutor.java) | XQL 语句执行引擎 |
| JMX 客户端 | [src/com/pwrd/jmx/JmxClient.java](src/com/pwrd/jmx/JmxClient.java) | JMX 远程管理功能 |
| 对象反射 | [src/com/pwrd/reflect/XBeanReflection.java](src/com/pwrd/reflect/XBeanReflection.java) | Java Bean 结构解析 |
| 数据库管理器 | [src/com/pwrd/dbx/DbxManager.java](src/com/pwrd/dbx/DbxManager.java) | mkdb/mbackup 文件管理 |
| 构建配置 | [build.xml](build.xml) | Ant 构建脚本 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**：JDK/JRE 1.6 及以上（推荐 JDK 8）
- **核心依赖库**：
  - `gsd.jar`：游戏数据定义（必需，包含 XBean 类）
  - `jio.jar`：XDB 数据库 I/O 引擎（必需）
  - `monkeyking.jar`：数据库操作辅助库（必需）
  - `yl.jar`：YACC 解析器运行时（必需）
- **第三方库**（lib/ 目录）：
  - `commons-beanutils-1.8.0.jar`：Bean 工具
  - `commons-collections-3.1.jar`：集合工具
  - `commons-lang-2.6.jar`：通用工具
  - `commons-logging-1.2.jar`：日志接口
  - `ezmorph-1.0.6.jar`：对象转换
  - `json-lib-2.3-jdk15.jar`：JSON 处理
  - `javadocking.jar`：可停靠面板框架
  - `log4j-1.2.15.jar`：日志实现
- **系统依赖**：
  - `db_amd64.dll`：Berkeley DB 本地库（Windows x64）

### 3.2 构建时依赖
- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）
- **ProGuard**：可选，用于代码混淆（lib/proguard.jar）

### 3.3 构建步骤

#### Windows 环境
```batch
# 使用 Ant 构建
ant dist

# 输出文件：
#   dist/xbrowse.jar       - 主程序（未混淆）
#   dist/xbrowserencry.jar - 混淆后程序（可选）
#   dist/lib/              - 依赖库
#   dist/resources/        - 资源文件
#   dist/db_amd64.dll      - 本地库
```

#### Linux/macOS 环境
```bash
# 使用 Ant 构建
ant dist

# 注意：需要替换对应平台的 Berkeley DB 库
# Linux: libdb.so
# macOS: libdb.dylib
```

#### 构建流程说明
构建脚本执行以下步骤（参见 [build.xml](build.xml)）：

1. **清理阶段**（clean）：
   - 删除 build/ 和 dist/ 目录
2. **初始化阶段**（init）：
   - 创建 build/ 和 dist/ 目录
3. **编译阶段**（compile）：
   - 编译 `src/**/*.java` → `build/`
   - 使用 GBK 编码（适配中文注释）
   - 启用调试信息（lines, source）
   - Classpath：lib/ 目录下所有 jar 文件
4. **打包阶段**（compiledist）：
   - 生成 `dist/xbrowse.jar`
   - 设置 Main-Class: `com.pwrd.XdbBrowser`
   - Class-Path：指向 lib/ 目录所有依赖
5. **混淆阶段**（obfuscate，可选）：
   - 使用 ProGuard 混淆代码
   - 配置文件：applications.pro
   - 输出：xbrowserencry.jar
6. **分发阶段**（dist）：
   - 复制所有运行时文件到 dist/
   - 包含库文件、资源文件、配置文件

### 3.4 构建参数说明
| 参数 | 说明 | 默认值 |
|-----|------|-------|
| `src` | 源代码目录 | `src/` |
| `build` | 编译输出目录 | `build/` |
| `dist` | 分发目录 | `dist/` |
| `lib` | 依赖库目录 | `lib/` |
| `res` | 资源文件目录 | `resources/` |

---

## 4. 配置与使用

### 4.1 启动方式

#### 方式 1：GUI 模式（图形界面）
```bash
# Windows
run_xbrowse.bat

# Linux/macOS
java -jar xbrowse.jar

# 或指定依赖库
java -jar xbrowse.jar
```

**GUI 功能**：
- **数据库面板**：左侧树形结构显示已加载的数据库
- **查询面板**：顶部输入 XQL 查询语句
- **结果面板**：中间显示查询结果表格
- **详情面板**：底部显示选中记录的详细信息
- **控制台面板**：显示操作日志和错误信息
- **JMX 面板**：远程连接游戏服务器

**基本操作**：
1. 点击菜单 `Database → Add Database` 或工具栏 `Add` 按钮
2. 选择 mkdb 或 mbackup 目录
3. 在左侧树中选择要查看的表
4. 在查询面板输入 XQL 语句，点击 `Execute` 执行
5. 查看结果面板中的数据

#### 方式 2：命令行模式（批处理）
```bash
# 基本格式
java -jar xbrowse.jar -cmd -lib <xbeans_jar_path>

# 示例：进入交互式控制台
java -jar xbrowse.jar -cmd -lib gsd.jar

# 控制台提示符
xbrowse> help          # 查看帮助
xbrowse> adddbx <path> # 添加数据库
xbrowse> use <dbname>  # 切换数据库
xbrowse> show tables   # 显示所有表
xbrowse> select from <table> # 查询数据
xbrowse> exit          # 退出
```

#### 方式 3：批量导出 JSON（自动化）
```bash
# 格式
java -jar xbrowse.jar -exportjson -lib <xbeans_jar> dbin=<input_dir> dbout=<output_dir>

# 示例（Windows）
java -jar xbrowserencry.jar -exportjson -lib gsd.jar ^
  dbin=C:\game_data\mbackup\20160509192319 ^
  dbout=C:\exported_json

# 示例（Linux/macOS）
java -jar xbrowserencry.jar -exportjson -lib gsd.jar \
  dbin=/opt/game_data/mbackup/20160509192319 \
  dbout=/tmp/exported_json

# 参数说明：
#   dbin=<path>  : mkdb 或 mbackup 目录的完整路径
#   dbout=<path> : JSON 输出目录（可选，默认 ./jsonout）
#   -lib <jar>   : XBean 类库路径（必需）
```

**批量导出说明**：
- 自动读取 dbin 目录下的所有表
- 将每个表的数据导出为独立的 JSON 文件
- 输出文件名：`<table_name>.json`
- 支持配置过滤表（通过 json_out_tbl.ini）

### 4.2 XQL 查询语言

XQL (XDB Query Language) 是类 SQL 的查询语言，语法简化但保留核心功能。

#### 4.2.1 SELECT 查询语句

**基本语法**：
```sql
select from TABLE_NAME
    [where CONDITION]
    [order by FIELD [asc | desc]]
    [limit START_POSITION, COUNT]
```

**示例**：

```sql
-- 1. 查询所有数据
select from rankinglist

-- 2. 条件查询（WHERE）
select from rankinglist where key == 8345
select from rankinglist where value.rolltime == 12345678

-- 3. 复合条件（&& 和 ||）
select from rankinglist
where value.rolltime == 12345678 && value.totalranking[0].inrankingtime == 1234567

-- 4. 排序查询（ORDER BY）
select from rankinglist order by value.rolltime asc
select from rankinglist where key > 1000 order by value.rolltime desc

-- 5. 分页查询（LIMIT）
select from rankinglist limit 0, 10          -- 前 10 条
select from rankinglist limit 10, 20         -- 第 11-30 条
select from rankinglist where key > 5000 order by key asc limit 0, 100

-- 6. 完整查询
select from rankinglist
where value.rolltime > 10000000 && key < 50000
order by value.rolltime desc
limit 0, 50
```

**字段访问语法**：
- `key`：表的主键字段
- `value`：表的值对象根字段
- `value.fieldname`：访问值对象的子字段
- `value.list[0]`：访问数组/列表元素
- `value.map.keyname`：访问 Map 的键值

**条件运算符**：
| 运算符 | 说明 | 示例 |
|-------|------|------|
| `==` | 等于 | `key == 100` |
| `!=` | 不等于 | `value.level != 0` |
| `>` | 大于 | `value.exp > 1000` |
| `<` | 小于 | `value.gold < 500` |
| `>=` | 大于等于 | `value.level >= 10` |
| `<=` | 小于等于 | `value.hp <= 100` |
| `&&` | 逻辑与 | `key > 1 && key < 100` |
| `||` | 逻辑或 | `value.type == 1 || value.type == 2` |

#### 4.2.2 UPDATE 更新语句

**基本语法**：
```sql
update TABLE_NAME set ASSIGN_LIST [where CONDITION]
```

**示例**：

```sql
-- 1. 更新单个字段
update rankinglist set value.rolltime = 99999999 where key == 8345

-- 2. 更新多个字段（用逗号分隔）
update rankinglist
set value.rolltime = 12345678, value.totalranking[0].inrankingtime = 1234567
where key == 8345

-- 3. 批量更新（无 WHERE 条件）
update rankinglist set value.status = 1

-- 4. 条件批量更新
update rankinglist set value.expired = true where value.rolltime < 10000000
```

**注意事项**：
- 更新立即生效，无法回滚
- 建议先用 SELECT 验证 WHERE 条件
- 批量更新（无 WHERE）操作需谨慎
- 数组索引必须存在，否则抛出异常

#### 4.2.3 DELETE 删除语句

**基本语法**：
```sql
delete from TABLE_NAME [where CONDITION]
```

**示例**：

```sql
-- 1. 删除单条记录
delete from rankinglist where key == 8345

-- 2. 条件批量删除
delete from rankinglist where value.rolltime < 10000000

-- 3. 删除所有数据（危险操作！）
delete from rankinglist
```

**警告**：
- DELETE 操作不可逆，数据无法恢复
- **强烈建议**先备份数据库
- 生产环境禁止无 WHERE 条件的删除
- 建议先用 SELECT 验证删除范围

### 4.3 命令行控制台命令

#### 基本命令

**1. help - 显示帮助**
```bash
xbrowse> help
# 显示所有可用命令
```

**2. adddbx - 添加数据库**
```bash
xbrowse> adddbx <mkdb_or_mbackup_path>

# 示例
xbrowse> adddbx C:\game_data\mkdb
xbrowse> adddbx /opt/game_data/mbackup/20160509192319
```

**3. use - 切换当前数据库**
```bash
xbrowse> use <database_name>

# 示例（mkdb 目录名为 mkdb）
xbrowse> use mkdb

# 示例（mbackup 目录名为时间戳）
xbrowse> use 20160509192319
```

**4. show - 显示信息**
```bash
# 显示所有表
xbrowse> show tables

# 显示表结构
xbrowse> show <table_name>

# 示例
xbrowse> show rankinglist
```

**5. json - 导出 JSON**
```bash
xbrowse> json <output_directory>

# 示例
xbrowse> json C:\exported_json
xbrowse> json /tmp/json_export
```

**6. exit - 退出控制台**
```bash
xbrowse> exit
```

#### XQL 命令

在控制台中直接输入 XQL 语句执行：
```bash
xbrowse> select from rankinglist
xbrowse> select from rankinglist where key == 100
xbrowse> update rankinglist set value.status = 1 where key == 100
xbrowse> delete from rankinglist where key == 999
```

#### 输出重定向

支持将命令输出重定向到文件：
```bash
# 格式
xbrowse> <command> > <output_file>

# 示例
xbrowse> show tables > tables_list.txt
xbrowse> select from rankinglist > ranking_data.txt
xbrowse> show rankinglist > table_structure.txt
```

### 4.4 JMX 远程管理功能

xbrowse 内置 JMX 客户端，可远程连接游戏服务器执行管理操作。

#### 启动 JMX 控制台

**GUI 模式**：
1. 在主窗口菜单选择 `Tools → JMX Client`
2. 输入连接信息：
   - Host: 服务器 IP 地址
   - Port: JMX 端口（RMI 注册端口）
   - Username/Password: 认证凭据（可选）
3. 点击 `Connect` 连接

**命令行模式**：
```bash
# 进入 JMX 控制台（在 xbrowse 命令行中）
xbrowse> jmx
jmx> help              # 查看 JMX 命令帮助
jmx> connect <host> <port> [username] [password]
jmx> use <mbean_name>
jmx> invoke <method> [args...]
jmx> exit              # 退出 JMX 模式
```

#### JMX 命令详解

**1. connect - 连接服务器**
```bash
jmx> connect 192.168.32.44 1098
jmx> connect 192.168.32.44 1098 admin password123
```

**2. use - 选择 MBean**
```bash
jmx> use IWEB:type=GameControl
jmx> use gs.counter:type=GMProcMXBeant
```

**3. invoke - 调用 MBean 方法**
```bash
# 格式
jmx> invoke <method_name> [arg1] [arg2] ...

# 示例
jmx> invoke keepAlive
jmx> invoke getOnlineNum
jmx> invoke stop 300
```

**4. get - 获取 MBean 属性**
```bash
jmx> get <attribute_name>
```

**5. set - 设置 MBean 属性**
```bash
jmx> set <attribute_name> <value>
```

**6. show - 显示 MBean 信息**
```bash
jmx> show           # 显示当前 MBean 的所有属性和方法
jmx> show mbeans    # 显示服务器所有 MBean
```

#### 常用 JMX 操作示例

```bash
# 1. 心跳检测
jmx> connect 192.168.32.44 1098
jmx> use IWEB:type=GameControl
jmx> invoke keepAlive
# 输出：true/false

# 2. 查询在线人数
jmx> invoke getOnlineNum
# 输出：当前在线人数

# 3. 执行 GM 命令
jmx> use gs.counter:type=GMProcMXBeant
jmx> invoke execute 9845 4097 "addgold#1000"

# 4. 关闭服务器
jmx> use bean:name=stopper
jmx> invoke stop 300    # 300 秒后关服

# 5. 重载配置
jmx> use IWEB:type=Reload
jmx> invoke reload
```

### 4.5 配置文件

#### json_out_tbl.ini - JSON 导出配置

控制批量导出时要包含/排除的表：

```ini
# json_out_tbl.ini
# 配置导出规则（一行一个表名）

# 包含这些表
+rankinglist
+playerdata
+guildinfo

# 排除这些表
-tempdata
-cachelog
```

**规则说明**：
- `+<tablename>`：包含该表
- `-<tablename>`：排除该表
- 空行和 `#` 开头的行为注释
- 如果文件为空或不存在，导出所有表

---

## 5. 输入输出规范

### 5.1 标准输入格式

#### GUI 模式
- **XQL 输入框**：多行文本，支持语法高亮和行号
- **文件选择器**：使用系统原生文件对话框
- **参数对话框**：表单输入，带验证提示

#### 命令行模式
- **标准输入**：从控制台读取命令（`System.in`）
- **命令格式**：`<command> <arg1> <arg2> ...`
- **空格分隔**：参数之间用空格或制表符分隔
- **路径处理**：支持绝对路径和相对路径，自动转换 `\` 为 `/`

### 5.2 标准输出格式

#### 成功场景

**查询结果（SELECT）**：
```
Table: rankinglist
Columns: key, value.rolltime, value.totalranking[0].inrankingtime
Rows: 150

key      | value.rolltime | value.totalranking[0].inrankingtime
---------|----------------|------------------------------------
8345     | 12345678       | 1234567
8346     | 12345679       | 1234568
...
```

**更新结果（UPDATE）**：
```
Updated 3 rows in table rankinglist
```

**删除结果（DELETE）**：
```
Deleted 5 rows from table rankinglist
```

**JSON 导出**：
```
Exporting table rankinglist... OK (1500 records)
Exporting table playerdata... OK (3200 records)
Exporting table guildinfo... OK (450 records)
Total: 3 tables, 5150 records exported to C:\exported_json
```

#### 失败场景

| 错误类型 | 输出示例 | 原因 |
|---------|---------|------|
| 语法错误 | `XQL Syntax Error: unexpected token 'from' at line 1` | XQL 语句语法不正确 |
| 表不存在 | `Table 'xxx' does not exist` | 指定的表名不存在 |
| 字段不存在 | `Field 'value.xxx' does not exist` | 访问了不存在的字段 |
| 库未加载 | `Invalid xbeans library: gsd.jar` | XBean 类库加载失败 |
| 数据库无效 | `Invalid Mkdb Directory` | 目录路径不存在或不是有效的数据库 |
| 连接失败 | `JMX connection failed: Connection refused` | JMX 服务器连接失败 |

### 5.3 日志输出

**日志级别**：
- INFO：正常操作信息
- WARN：警告信息（非致命）
- ERROR：错误信息（需处理）

**日志位置**：
- GUI 模式：控制台面板（底部）
- 命令行模式：标准错误输出（`System.err`）
- 文件日志：logs/xbrowse.log（如果配置了 log4j）

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制
- **XQL 语法限制**：
  - 不支持 JOIN 操作（单表查询）
  - 不支持子查询和嵌套 SELECT
  - 不支持聚合函数（SUM/COUNT/AVG）
  - 不支持 GROUP BY 和 HAVING
  - 条件中只能使用简单数据类型（不支持复杂对象比较）
- **数据类型限制**：
  - WHERE 条件仅支持基本类型和字符串
  - 不支持日期时间类型的直接比较
  - 集合和 Map 的条件查询有限制
- **性能限制**：
  - 大表查询（>10万条）可能导致内存溢出
  - 无索引支持，全表扫描性能较低
  - GUI 模式加载大量数据会卡顿

#### 平台限制
- **本地库依赖**：
  - Windows x64: db_amd64.dll（必需）
  - Linux: libdb.so（需自行编译）
  - macOS: libdb.dylib（需自行编译）
- **编码问题**：
  - 源代码使用 GBK 编码
  - 控制台输出可能乱码（非 UTF-8 环境）
  - 文件路径需避免特殊字符

#### 并发限制
- **单实例运行**：同一数据库目录不能被多个 xbrowse 实例同时打开
- **无事务支持**：UPDATE/DELETE 操作无事务保护，失败可能导致数据不一致
- **文件锁**：Berkeley DB 会锁定数据库文件，异常退出可能遗留锁文件

### 6.2 性能考虑

#### 内存管理
```bash
# 大数据库场景增加堆内存
java -Xms512m -Xmx2048m -jar xbrowse.jar

# 导出大表时使用流式处理
java -Xms1g -Xmx4g -jar xbrowserencry.jar -exportjson -lib gsd.jar \
  dbin=/data/mbackup/large_db dbout=/tmp/json
```

#### 查询优化建议
- **使用 LIMIT**：限制返回结果集大小
  ```sql
  -- 不推荐（可能返回百万条）
  select from bigTable where value.type == 1

  -- 推荐（限制 1000 条）
  select from bigTable where value.type == 1 limit 0, 1000
  ```
- **精确 WHERE 条件**：缩小扫描范围
  ```sql
  -- 不推荐（全表扫描）
  select from playerdata where value.level > 0

  -- 推荐（精确主键）
  select from playerdata where key == 123456
  ```
- **避免复杂条件**：减少运算开销
  ```sql
  -- 不推荐（复杂嵌套）
  select from data where (a==1 && b==2) || (c==3 && d==4) || (e==5 && f==6)

  -- 推荐（简化逻辑）
  select from data where status == 1
  ```

#### GUI 性能优化
- **分页加载**：避免一次性加载全部数据
- **延迟渲染**：展开树节点时才加载子节点
- **关闭自动刷新**：修改数据后手动刷新查询结果

### 6.3 安全注意事项

#### 数据备份
- **操作前备份**：执行 UPDATE/DELETE 前必须备份数据库
  ```bash
  # Windows
  xcopy /E /I mkdb mkdb_backup_20250101

  # Linux/macOS
  cp -r mkdb mkdb_backup_20250101
  ```
- **定期备份**：重要数据库每日备份，保留 7 天历史
- **验证备份**：定期测试备份文件的可恢复性

#### 权限管理
- **文件权限**：数据库目录应限制访问权限
  ```bash
  # Linux/macOS
  chmod 700 /opt/game_data/mkdb
  chown gameuser:gamegroup /opt/game_data/mkdb
  ```
- **JMX 认证**：生产环境必须启用 JMX 用户名密码认证
- **网络隔离**：JMX 端口仅在内网开放

#### 操作审计
- **启用日志**：记录所有 UPDATE/DELETE 操作
- **操作记录**：在控制台使用输出重定向保存操作历史
  ```bash
  xbrowse> update rankinglist set value.status=1 where key==100 > update_log.txt
  ```
- **双人复核**：生产数据修改需要第二人审核

### 6.4 故障排查指南

#### 问题 1：启动失败 - 找不到 gsd.jar
**症状**：
```
Invalid xbeans library: gsd.jar, failed to startup xbrowse console.
```

**解决方案**：
1. 检查 gsd.jar 是否存在于当前目录
2. 使用 `-lib` 参数指定完整路径：
   ```bash
   java -jar xbrowse.jar -cmd -lib /opt/game/gsd.jar
   ```
3. 确认 gsd.jar 版本与数据库匹配

#### 问题 2：无法打开数据库 - Berkeley DB 错误
**症状**：
```
DB Error: __db.001: unexpected file type or format
```

**可能原因**：
- 数据库文件损坏
- Berkeley DB 版本不兼容
- 数据库被其他进程锁定

**排查步骤**：
1. 检查数据库目录完整性：
   ```bash
   ls -lh mkdb/
   # 应包含：__db.001, __db.002, <tablename>.db 等文件
   ```
2. 删除锁文件重试：
   ```bash
   rm -f mkdb/__db.*
   ```
3. 使用 Berkeley DB 工具验证：
   ```bash
   db_verify mkdb/tablename.db
   ```
4. 恢复备份数据：
   ```bash
   cp -r mkdb_backup/* mkdb/
   ```

#### 问题 3：XQL 语法错误
**症状**：
```
XQL Syntax Error: unexpected token 'where' at line 1
```

**常见错误**：
```sql
-- 错误：缺少 from 关键字
select rankinglist where key == 100

-- 正确
select from rankinglist where key == 100

-- 错误：使用了单引号（XQL 不支持字符串常量）
select from rankinglist where value.name == 'Alice'

-- 正确：直接使用数字或使用双引号（取决于字段类型）
select from rankinglist where value.id == 100

-- 错误：字段名拼写错误
select from rankinglist where value.rollTime == 100

-- 正确：检查字段名大小写
select from rankinglist where value.rolltime == 100
```

#### 问题 4：内存溢出（OutOfMemoryError）
**症状**：
```
java.lang.OutOfMemoryError: Java heap space
```

**解决方案**：
1. 增加堆内存：
   ```bash
   java -Xms1g -Xmx4g -jar xbrowse.jar
   ```
2. 使用 LIMIT 限制结果集：
   ```sql
   select from bigTable limit 0, 1000
   ```
3. 批量导出时分批处理：
   - 配置 json_out_tbl.ini 仅导出部分表
   - 多次运行导出不同表

#### 问题 5：JMX 连接失败
**症状**：
```
JMX connection failed: Connection refused
```

**排查步骤**：
1. 检查服务器 JMX 端口：
   ```bash
   telnet 192.168.32.44 1098
   ```
2. 确认服务器启动参数包含：
   ```
   -Dcom.sun.management.jmxremote
   -Dcom.sun.management.jmxremote.port=1098
   -Dcom.sun.management.jmxremote.authenticate=false
   -Dcom.sun.management.jmxremote.ssl=false
   ```
3. 检查防火墙规则：
   ```bash
   # Linux
   sudo iptables -L -n | grep 1098

   # Windows
   netsh advfirewall firewall show rule name=all | findstr 1098
   ```
4. 验证 RMI 服务端口（port+2687）：
   ```bash
   netstat -an | grep 3785    # 1098 + 2687 = 3785
   ```

#### 问题 6：中文乱码
**症状**：
- 控制台输出中文显示为乱码
- 查询结果中文字段乱码

**解决方案**：
1. 设置 JVM 编码参数：
   ```bash
   java -Dfile.encoding=GBK -jar xbrowse.jar
   # 或
   java -Dfile.encoding=UTF-8 -jar xbrowse.jar
   ```
2. Windows 控制台设置：
   ```cmd
   chcp 936         # GBK 编码
   chcp 65001       # UTF-8 编码
   ```
3. Linux 终端设置：
   ```bash
   export LANG=zh_CN.GBK
   # 或
   export LANG=zh_CN.UTF-8
   ```

---

## 7. 扩展与改进

### 7.1 当前未使用的功能
- **配置面板**：`CfgPanel`、`CfgStrChangePanel` 已注释，可用于配置文件编辑
- **定时器工具**：`TimerKitDlg` 可用于定时任务执行

### 7.2 推荐改进方向

#### 短期优化（1-2 周）
1. **错误提示增强**：详细的 XQL 语法错误提示，指出错误位置
2. **结果集分页**：自动分页加载大表查询结果
3. **导出格式扩展**：支持 CSV、Excel 格式导出
4. **快捷键支持**：常用操作绑定快捷键（Ctrl+E 执行、F5 刷新等）

#### 中期优化（1-2 个月）
5. **查询历史记录**：保存和管理常用 XQL 查询
6. **SQL 导入支持**：将标准 SQL 自动转换为 XQL
7. **数据比较工具**：对比两个数据库的差异
8. **批量修改向导**：图形化批量数据修改工具
9. **JMX 连接池**：保持 JMX 连接，避免频繁重连

#### 长期优化（3-6 个月）
10. **Web UI 版本**：基于 Web 的远程访问界面
11. **索引支持**：为常用字段建立索引，提升查询速度
12. **多数据库支持**：同时连接多个数据库，支持跨库查询
13. **数据可视化**：图表展示统计数据（在线人数趋势等）
14. **插件系统**：支持自定义数据处理插件
15. **版本控制集成**：数据库变更与 Git 集成

### 7.3 参考资料
- XQL 语法规范：[xql-syntax.txt](xql-syntax.txt)
- 控制台命令帮助：resources/console.help.txt
- JMX 命令帮助：resources/jmx.help.txt
- 构建脚本：[build.xml](build.xml)

---

## 8. 快速参考

### 8.1 启动命令速查

```bash
# GUI 模式
java -jar xbrowse.jar

# 命令行模式
java -jar xbrowse.jar -cmd -lib gsd.jar

# JSON 导出模式
java -jar xbrowserencry.jar -exportjson -lib gsd.jar \
  dbin=/path/to/mbackup/20160509192319 \
  dbout=/path/to/output

# 增加内存（大数据库）
java -Xms1g -Xmx4g -jar xbrowse.jar
```

### 8.2 XQL 语句速查

```sql
-- 查询所有
select from tablename

-- 条件查询
select from tablename where key == 100
select from tablename where value.field > 1000

-- 复合条件
select from tablename where value.a == 1 && value.b > 10

-- 排序
select from tablename order by value.field asc
select from tablename order by value.field desc

-- 分页
select from tablename limit 0, 100

-- 更新
update tablename set value.field = 999 where key == 100

-- 删除
delete from tablename where key == 100
```

### 8.3 控制台命令速查

```bash
# 添加数据库
xbrowse> adddbx /path/to/mkdb

# 切换数据库
xbrowse> use mkdb

# 显示所有表
xbrowse> show tables

# 显示表结构
xbrowse> show tablename

# 导出 JSON
xbrowse> json /path/to/output

# 输出重定向
xbrowse> select from tablename > result.txt

# 退出
xbrowse> exit
```

### 8.4 JMX 命令速查

```bash
# 连接服务器
jmx> connect 192.168.32.44 1098

# 选择 MBean
jmx> use IWEB:type=GameControl

# 调用方法
jmx> invoke keepAlive
jmx> invoke getOnlineNum

# 显示信息
jmx> show
jmx> show mbeans

# 退出 JMX 模式
jmx> exit
```

### 8.5 常见错误码速查

| 错误信息关键字 | 含义 | 解决方案 |
|-------------|------|---------|
| `Invalid xbeans library` | XBean 类库加载失败 | 检查 gsd.jar 路径和版本 |
| `Invalid Mkdb Directory` | 数据库目录无效 | 验证路径正确性和目录结构 |
| `Table 'xxx' does not exist` | 表不存在 | 使用 `show tables` 查看可用表 |
| `Field 'xxx' does not exist` | 字段不存在 | 使用 `show tablename` 查看表结构 |
| `XQL Syntax Error` | XQL 语法错误 | 检查语句语法，参考 4.2 节 |
| `OutOfMemoryError` | 内存溢出 | 增加 JVM 堆内存或使用 LIMIT |
| `DB Error: __db.001` | Berkeley DB 错误 | 删除锁文件或恢复备份 |
| `JMX connection failed` | JMX 连接失败 | 检查网络和服务器配置 |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | xbrowse (XDB Browser) |
| **版本** | 见 Jar 文件时间戳 |
| **主要维护者** | 见项目 Git 提交历史 |
| **代码位置** | `server/tools/xbrowse/` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, Swing, Berkeley DB, JMX, YACC, JSON |
| **核心依赖** | gsd.jar, jio.jar, monkeyking.jar, yl.jar |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器开发团队
- 查看项目 Wiki 获取更多文档

---

## 附录 A：XQL 语法 BNF 范式

```bnf
<select_statement> ::= "select" "from" <table_name>
                       [<where_clause>]
                       [<order_by_clause>]
                       [<limit_clause>]

<update_statement> ::= "update" <table_name> "set" <assign_list>
                       [<where_clause>]

<delete_statement> ::= "delete" "from" <table_name>
                       [<where_clause>]

<where_clause> ::= "where" <condition>

<condition> ::= <simple_condition>
              | <condition> "&&" <condition>
              | <condition> "||" <condition>
              | "(" <condition> ")"

<simple_condition> ::= <field> <operator> <value>

<operator> ::= "==" | "!=" | ">" | "<" | ">=" | "<="

<order_by_clause> ::= "order" "by" <field> ["asc" | "desc"]

<limit_clause> ::= "limit" <number> "," <number>

<assign_list> ::= <assign> ["," <assign>]*

<assign> ::= <field> "=" <value>

<field> ::= "key"
          | "value" ["." <identifier>]*
          | "value" ["." <identifier>]* "[" <number> "]" ["." <identifier>]*

<table_name> ::= <identifier>

<identifier> ::= [a-zA-Z_][a-zA-Z0-9_]*

<number> ::= [0-9]+

<value> ::= <number> | <string> | <boolean>

<string> ::= '"' [^"]* '"'

<boolean> ::= "true" | "false"
```

---

## 附录 B：依赖库清单

| 库名称 | 版本 | 用途 | 许可证 |
|-------|------|------|-------|
| commons-beanutils | 1.8.0 | JavaBean 工具 | Apache 2.0 |
| commons-collections | 3.1 | 集合框架增强 | Apache 2.0 |
| commons-lang | 2.6 | 通用工具类 | Apache 2.0 |
| commons-logging | 1.2 | 日志接口 | Apache 2.0 |
| ezmorph | 1.0.6 | 对象类型转换 | Apache 2.0 |
| json-lib | 2.3-jdk15 | JSON 序列化 | Apache 2.0 |
| javadocking | - | 可停靠面板 | LGPL |
| log4j | 1.2.15 | 日志实现 | Apache 2.0 |
| yl.jar | - | YACC 解析器运行时 | - |
| jio.jar | - | XDB I/O 引擎 | 内部 |
| monkeyking.jar | - | 数据库辅助库 | 内部 |
| gsd.jar | - | 游戏数据定义 | 内部 |

---

**文档版本**: v1.0
**生成日期**: 2025-11-27
**适用工具版本**: xbrowse (所有版本)

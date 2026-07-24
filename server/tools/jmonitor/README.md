# jmonitor - JMX 监控 Web 服务

## 1. 工具概述

### 1.1 用途说明
jmonitor 是一个基于 JMX (Java Management Extensions) 的可视化监控平台，专为 MT3 游戏服务器集群设计。该工具通过 HTTP 服务从多个服务器实例拉取 JMX 指标数据，提供 Web 界面进行集中展示与管理，实现以下核心功能：

- **服务器监控**：实时监控多个游戏服务器的运行状态与性能指标
- **数据可视化**：通过图表（Chart）和表格（Table）展示历史数据趋势
- **数据持久化**：定期拉取 MBean 数据并存储到数据库，支持数据分析与历史回溯
- **角色权限管理**：基于角色的访问控制（manager/viewer），保障系统安全
- **RESTful API**：提供标准化的 REST 接口，支持自动化运维集成

### 1.2 典型使用场景
- **实时监控**：通过 Web 界面查看服务器在线人数、资源使用情况、业务指标
- **性能分析**：查看历史数据趋势，分析服务器负载与业务波动
- **数据导出**：导出监控数据用于离线分析与报表生成
- **运维自动化**：通过 REST API 集成到监控平台（如 Prometheus/Grafana）
- **多服务器管理**：在单一界面管理多个游戏服务器实例的监控配置

### 1.3 关键特性
- **定时拉取机制**：每 30 秒轮询一次，根据配置的拉取周期（offset/period）自动采集数据
- **数据聚合**：支持按服务器 ID (zid) 聚合数据，支持按天（DAY）汇总历史数据
- **表自动管理**：当表大小超过 100MB 且间隔 7 天后，自动重命名表以归档历史数据
- **连接管理**：智能连接池管理，连接失败时自动重试
- **超时保护**：JMX 连接内置超时机制，防止监控服务挂起
- **GZIP 压缩**：HTTP 响应支持 GZIP 压缩，优化带宽使用

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
jmonitor 位于 MT3 服务器架构的**监控服务层**，作为中心化的 JMX 数据采集与展示平台：

```
┌─────────────────────────────────────────┐
│       运维人员 / 监控平台               │
│       (浏览器访问 Web UI / REST API)    │
└──────────────┬──────────────────────────┘
               │ HTTP (GET/POST/DELETE)
               ↓
┌─────────────────────────────────────────┐
│         jmonitor Web 服务               │
│  - Jersey RESTful API                   │
│  - Freemarker 模板引擎                  │
│  - 定时任务调度器 (ScheduledExecutor)  │
│  - 数据持久化 (MySQL)                   │
└──────────────┬──────────────────────────┘
               │ JMX over RMI
               ↓
┌─────────────────────────────────────────┐
│      游戏服务器 JMX MBean 接口          │
│  - 在线人数统计                         │
│  - 资源使用监控                         │
│  - 业务指标采集                         │
│  - 自定义性能计数器                     │
└─────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **上游依赖**：
  - 游戏服务器开启 JMX 端口（通过 jmxports.xml 配置）
  - MySQL 数据库用于存储监控数据
  - PortForwarder（可选）用于跨网络访问 JMX 服务
- **下游消费者**：
  - Web 浏览器（查看监控界面）
  - REST API 客户端（自动化运维脚本）
  - 第三方监控系统（通过 API 集成）
- **数据流**：
  - 拉取数据：jmonitor → 游戏服务器 JMX（定时轮询）
  - 展示数据：Web UI / REST API → jmonitor → MySQL
  - 管理配置：Web UI → jmonitor → XML 配置文件

### 2.3 关键代码位置
| 功能模块 | 文件路径 | 关键说明 |
|---------|---------|---------|
| 启动入口 | [jmonitor/src/com/locojoy/jmonitor/main/Main.java](jmonitor/src/com/locojoy/jmonitor/main/Main.java#L65-L119) | HTTP 服务器启动、Jersey 配置、定时任务初始化 |
| 服务器管理 | [jmonitor/src/com/locojoy/jmonitor/spi/ServerManager.java](jmonitor/src/com/locojoy/jmonitor/spi/ServerManager.java#L166-L267) | 定时拉取任务、数据聚合、表归档管理 |
| 表管理 | [jmonitor/src/com/locojoy/jmonitor/spi/TableManager.java](jmonitor/src/com/locojoy/jmonitor/spi/TableManager.java) | 表配置管理、数据收集与持久化 |
| 图表管理 | [jmonitor/src/com/locojoy/jmonitor/spi/ChartManager.java](jmonitor/src/com/locojoy/jmonitor/spi/ChartManager.java) | 图表配置管理、数据查询与展示 |
| REST API - Server | [jmonitor/src/com/locojoy/jmonitor/webapp/res/Server.java](jmonitor/src/com/locojoy/jmonitor/webapp/res/Server.java) | 服务器管理接口（增删查）|
| REST API - Table | [jmonitor/src/com/locojoy/jmonitor/webapp/res/Table.java](jmonitor/src/com/locojoy/jmonitor/webapp/res/Table.java) | 表管理接口（增删查）|
| REST API - Chart | [jmonitor/src/com/locojoy/jmonitor/webapp/res/Chart.java](jmonitor/src/com/locojoy/jmonitor/webapp/res/Chart.java) | 图表管理接口 |
| 安全过滤器 | [jmonitor/src/com/locojoy/jmonitor/webapp/MySecurityFilter.java](jmonitor/src/com/locojoy/jmonitor/webapp/MySecurityFilter.java) | 基于角色的权限控制 |
| JMX 连接工具 | [jmonitor/src/com/locojoy/jmonitor/util/JMXTimeoutConnect.java](jmonitor/src/com/locojoy/jmonitor/util/JMXTimeoutConnect.java) | JMX 超时连接实现 |
| 构建配置 | [jmonitor/build.xml](jmonitor/build.xml) | Ant 构建脚本 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**：JDK/JRE 1.6 及以上（推荐 JDK 8）
- **外部库**：
  - `freemarker.jar`：模板引擎（用于 Web UI 渲染）
  - `jersey-core-1.9.1.jar` + `jersey-server-1.9.1.jar`：RESTful 框架
  - `mysql-connector-java-5.0.8-bin.jar`：MySQL 数据库连接
  - `json_simple-1.1.jar`：JSON 处理
  - `asm-3.1.jar`：字节码操作库（Jersey 依赖）
  - `jio.jar` + `locojoydb.jar`：内部数据库操作库
- **数据库**：MySQL 5.0 及以上版本
- **网络连接**：可访问目标服务器的 JMX 端口

### 3.2 构建时依赖
- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）
- **依赖库**：所有运行时依赖库需放置在 `../lib/` 目录

### 3.3 构建步骤

#### 3.3.1 自动构建（推荐）
```bash
# 顶层 build.xml 会自动构建所有子项目
cd server/tools/jmonitor
ant all

# 输出文件：../dist/jmonitor.jar
# 同时复制到：../bin/jmonitor/dist/jmonitor.jar
```

#### 3.3.2 手动构建
```bash
cd server/tools/jmonitor/jmonitor
ant all

# 分步执行（仅在需要时）
ant clean       # 清理 build/ 目录
ant init        # 创建 build/ 和 dist/ 目录
ant compile     # 编译 Java 源码
ant dist        # 打包 Jar 文件
```

#### 3.3.3 构建流程说明
构建脚本执行以下步骤（参见 [jmonitor/build.xml](jmonitor/build.xml)）：

1. **初始化阶段**（init）：创建 `build/` 和 `dist/` 目录
2. **编译阶段**（compile）：
   - 编译 `src/**/*.java` → `build/`
   - 使用 UTF-8 编码
   - 启用调试信息（lines, source）
   - 复制非 .java 资源文件（如 Freemarker 模板）
3. **打包阶段**（dist）：
   - 生成 `../dist/jmonitor.jar`
   - 设置 Main-Class: `com.locojoy.jmonitor.main.Main`
   - 设置 Class-Path: 包含所有依赖库
   - 复制到 `../bin/jmonitor/dist/jmonitor.jar`
4. **清理阶段**（clean）：删除 `build/` 目录

### 3.4 构建参数说明
| 参数 | 说明 | 默认值 |
|-----|------|-------|
| `build` | 编译输出目录 | `build` |
| `dist` | Jar 包输出目录 | `../dist` |
| `lib` | 依赖库目录 | `../lib` |
| `deplibs` | 依赖库列表 | freemarker.jar, mysql-connector-java-5.0.8-bin.jar, jio.jar, locojoydb.jar, jersey-core-1.9.1.jar, jersey-server-1.9.1.jar, json_simple-1.1.jar, asm-3.1.jar |
| `jarfile` | Jar 包文件名 | `${dist}/jmonitor.jar` |

---

## 4. 配置与使用

### 4.1 启动命令格式
```bash
java -jar jmonitor.jar <mbeandb.xml> <jmxports.xml> <access.xml> <port> [ip]
```

**参数说明**：
- `<mbeandb.xml>`：MBean 配置文件路径（定义表、图表、数据采集规则）
- `<jmxports.xml>`：JMX 端口配置文件路径（定义服务器列表与 JMX 连接信息）
- `<access.xml>`：访问控制配置文件路径（定义角色与权限）
- `<port>`：HTTP 服务监听端口（如 80、8080）
- `[ip]`：可选，HTTP 服务绑定 IP 地址（默认绑定所有网卡 0.0.0.0）

**启动示例**：
```bash
# 监听所有网卡的 80 端口
java -jar jmonitor.jar mbeandb.xml jmxports.xml access.xml 80

# 仅监听本地回环地址的 8080 端口
java -jar jmonitor.jar mbeandb.xml jmxports.xml access.xml 8080 127.0.0.1

# 指定日志配置文件
java -Djava.util.logging.config.file=logging.properties -jar jmonitor.jar mbeandb.xml jmxports.xml access.xml 80
```

### 4.2 配置文件详解

#### 4.2.1 jmxports.xml - 服务器连接配置
定义监控的游戏服务器列表与 JMX 连接信息。

**配置示例**：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<data>
    <server
        gsip="172.20.54.11"              <!-- 游戏服务器 IP -->
        gsjmxport1="29023"               <!-- JMX 端口 1 -->
        gsjmxport2="31623"               <!-- JMX 端口 2 -->
        link="qinyoutiyanfu.link.mhsd.locojoylink.com"  <!-- 外部访问域名 -->
        linkport="28993-29000"           <!-- 外部访问端口范围 -->
        name="测试大区-亲友体验服"       <!-- 服务器显示名称 -->
        port1="27001"                    <!-- 服务端口 1 -->
        port2="31623"                    <!-- 服务端口 2 -->
        server="127.0.0.1"               <!-- 内部服务器地址 -->
        zoneid="2600"                    <!-- 区服 ID（唯一标识）-->
    />

    <!-- 可添加更多 <server> 节点监控多个服务器 -->
</data>
```

**字段说明**：
- `zoneid`：服务器唯一标识（必填），用于数据库存储与查询
- `name`：服务器显示名称（必填），在 Web UI 中展示
- `gsip` / `server`：服务器 IP 地址
- `gsjmxport1` / `gsjmxport2`：JMX 服务端口
- `link` / `linkport`：外部访问配置（用于跨网络访问）

#### 4.2.2 access.xml - 角色权限配置
定义用户角色与访问权限控制规则。

**配置示例**：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<accessmanager>
    <!-- 角色定义：manager 拥有所有权限 -->
    <access role="manager"/>

    <!-- 角色定义：viewer 只读权限，禁止 POST/DELETE 操作 -->
    <access role="viewer">
        <forbid methods="POST" path="chart"/>
        <forbid methods="DELETE" path="chart/.*"/>
        <forbid methods="POST" path="chartchain"/>
        <forbid methods="DELETE" path="chartchain/.*"/>
        <forbid methods="POST" path="localize"/>
        <forbid methods="DELETE" path="localize/.*"/>
        <forbid methods="POST" path="server"/>
        <forbid methods="DELETE" path="server/.*"/>
        <forbid methods="POST" path="table"/>
        <forbid methods="DELETE" path="table/.*"/>
        <forbid methods="POST" path="access"/>
        <forbid methods="DELETE" path="access/.*"/>
        <forbid methods="GET" path="cfg/.*"/>
    </access>

    <!-- 用户-角色映射：manager 角色成员 -->
    <role name="manager">
        <user name="chengxiaosan"/>
        <user name="xuhui"/>
        <user name="zengpan"/>
        <user name="fenghongxia"/>
    </role>

    <!-- 用户-角色映射：viewer 角色成员 -->
    <role name="viewer">
        <user name="wulinxu"/>
        <user name="xucong"/>
        <user name="chenlei100802"/>
    </role>
</accessmanager>
```

**权限模型**：
- **manager 角色**：完全控制权限（增删改查所有资源）
- **viewer 角色**：只读权限（仅允许 GET 请求，禁止 POST/DELETE）
- **路径匹配**：支持正则表达式（如 `chart/.*` 匹配所有图表子路径）

#### 4.2.3 mbeandb.xml - 监控配置（核心配置）
定义监控表（Table）、图表（Chart）、数据采集规则等核心配置。

**注意**：此文件通常非常大（28000+ tokens），包含复杂的表结构、列定义、数据源配置。

**核心结构概述**：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<mbeandb>
    <!-- 数据库连接配置 -->
    <database driver="com.mysql.jdbc.Driver"
              url="jdbc:mysql://localhost:3306/jmonitor?characterEncoding=UTF-8"
              user="root"
              password="password"/>

    <!-- 表定义：定义监控数据表结构 -->
    <table identification="online_num"
           fetch_offset="0"          <!-- 拉取偏移分钟数 -->
           fetch_period="5"          <!-- 拉取周期（分钟）-->
           dbname="online_statistics">

        <!-- 表列定义 -->
        <column name="zoneid" type="INT" primary="true"/>      <!-- 区服 ID -->
        <column name="timestamp" type="BIGINT" primary="true"/> <!-- 时间戳 -->
        <column name="online_count" type="INT"/>                <!-- 在线人数 -->

        <!-- 数据源：从 JMX MBean 拉取数据 -->
        <source mbean="IWEB:type=GameControl"
                attribute="onlineNum"
                method="getOnlineNum"/>
    </table>

    <!-- 图表定义：用于 Web UI 数据可视化 -->
    <chart identification="online_trend"
           table="online_num"
           title="在线人数趋势图">
        <xaxis column="timestamp" label="时间"/>
        <yaxis column="online_count" label="在线人数"/>
    </chart>

    <!-- 图表链（ChartChain）：多图表联合展示 -->
    <chartchain identification="server_overview"
                title="服务器总览">
        <chart ref="online_trend"/>
        <chart ref="cpu_usage"/>
        <chart ref="memory_usage"/>
    </chartchain>
</mbeandb>
```

**关键字段说明**：
- **table.fetch_offset**：拉取偏移时间（分钟），用于错开不同表的拉取时间
- **table.fetch_period**：拉取周期（分钟），如 5 表示每 5 分钟拉取一次
- **column.primary**：主键标识，通常包含 `zoneid` + `timestamp`
- **source.mbean**：JMX MBean 对象名称
- **source.attribute / method**：MBean 属性或方法名

### 4.3 Web 界面使用

#### 4.3.1 访问地址
```
http://<服务器IP>:<端口>/
```

**主要页面**：
- `/server`：服务器管理页面（查看、添加、删除监控服务器）
- `/table`：表管理页面（查看、添加、删除监控表）
- `/chart`：图表管理页面（查看、添加、删除图表）
- `/chartchain`：图表链管理页面（组合多个图表）
- `/tabledata/{table_id}`：查看表数据
- `/chartdata/{chart_id}`：查看图表数据
- `/access`：访问控制管理（仅 manager 角色）

#### 4.3.2 服务器管理操作
**查看服务器列表**：
- 访问 `/server`
- 显示所有已配置的监控服务器
- 显示 PortForwarder 连接状态

**添加监控服务器**（通过 Web UI）：
```
POST /server
Form Data:
  serverid: 2600
  url: service:jmx:rmi:///jndi/rmi://172.20.54.11:29023/jmxrmi
  name: 测试大区-亲友体验服
```

**删除监控服务器**：
```
DELETE /server/{id}
```

**手动拉取服务器数据**：
```
POST /server/{id}
```

#### 4.3.3 表管理操作
**查看表列表**：
- 访问 `/table`
- 显示所有监控表的配置与工作状态

**添加监控表**（通过 Web UI）：
```
POST /table
Form Data:
  xml: <table identification="...">...</table>
```

**删除监控表**：
```
DELETE /table/{identification}
```

#### 4.3.4 数据查询与导出
**查看表数据**：
```
GET /tabledata/{table_id}?zoneid=2600&from=2025-11-01&to=2025-11-27
```

**导出数据（CSV 格式）**：
```
GET /tabledatadumper/{table_id}?zoneid=2600&from=2025-11-01&to=2025-11-27
```

**查看图表数据**：
```
GET /chartdata/{chart_id}?zoneid=2600&from=2025-11-01&to=2025-11-27
```

### 4.4 REST API 接口

#### 4.4.1 服务器管理 API
| 方法 | 路径 | 说明 | 权限 |
|-----|------|------|------|
| GET | `/server` | 获取服务器列表（HTML） | ALL |
| POST | `/server` | 添加监控服务器 | manager |
| DELETE | `/server/{id}` | 删除监控服务器 | manager |
| POST | `/server/{id}` | 手动拉取服务器数据 | manager |

#### 4.4.2 表管理 API
| 方法 | 路径 | 说明 | 权限 |
|-----|------|------|------|
| GET | `/table` | 获取表列表（HTML） | ALL |
| POST | `/table` | 添加监控表 | manager |
| DELETE | `/table/{identification}` | 删除监控表 | manager |

#### 4.4.3 图表管理 API
| 方法 | 路径 | 说明 | 权限 |
|-----|------|------|------|
| GET | `/chart` | 获取图表列表（HTML） | ALL |
| POST | `/chart` | 添加图表 | manager |
| DELETE | `/chart/{identification}` | 删除图表 | manager |

#### 4.4.4 数据查询 API
| 方法 | 路径 | 说明 | 权限 |
|-----|------|------|------|
| GET | `/tabledata/{table_id}` | 查询表数据（JSON） | ALL |
| GET | `/tabledatadumper/{table_id}` | 导出表数据（CSV） | ALL |
| GET | `/chartdata/{chart_id}` | 查询图表数据（JSON） | ALL |
| GET | `/chartchaindata/{chartchain_id}` | 查询图表链数据（JSON） | ALL |

#### 4.4.5 配置管理 API
| 方法 | 路径 | 说明 | 权限 |
|-----|------|------|------|
| GET | `/cfg/mbeandb` | 获取 mbeandb.xml 配置 | manager |
| GET | `/cfg/jmxport` | 获取 jmxports.xml 配置 | manager |
| GET | `/cfg/access` | 获取 access.xml 配置 | manager |
| GET | `/cfg/lastfetch` | 获取 lastfetch.xml 状态 | manager |

---

## 5. 输入输出规范

### 5.1 标准输入格式
工具不接受标准输入（stdin），所有参数通过命令行参数和配置文件传递。

### 5.2 标准输出格式

#### 5.2.1 启动成功输出
```
INFO: ServerManager started!
INFO: jmonitor HTTP server started on port 80
```

#### 5.2.2 日志输出格式
```
[时间戳] [级别] [类名] [消息]

示例：
2025-11-27 10:30:00 INFO com.locojoy.jmonitor.spi.ServerManager fetch server.size=5, table.size=10, used.millis=1234
2025-11-27 10:35:00 INFO com.locojoy.jmonitor.spi.ServerManager fetch.storeDay used.millis=5678
2025-11-27 10:40:00 WARNING com.locojoy.jmonitor.spi.TableLastFetch lastfetch.saveConfig error: Permission denied
```

### 5.3 REST API 响应格式

#### 成功响应
```json
HTTP/1.1 200 OK
Content-Type: application/json; charset=UTF-8
Content-Encoding: gzip

{
  "status": "success",
  "data": [...]
}
```

#### 错误响应
```json
HTTP/1.1 409 Conflict
Content-Type: text/plain; charset=UTF-8

id = 2600 already started
```

**HTTP 状态码**：
- `200 OK`：请求成功
- `409 Conflict`：资源冲突（如重复添加服务器）
- `403 Forbidden`：权限不足
- `404 Not Found`：资源不存在
- `500 Internal Server Error`：服务器内部错误

### 5.4 数据导出格式（CSV）
```csv
zoneid,timestamp,column1,column2,column3
2600,1732694400000,100,200,300
2600,1732694700000,110,210,310
```

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制
- **配置热更新**：修改配置文件后需重启服务才能生效
- **数据库依赖**：必须预先创建数据库和表结构，工具不自动创建
- **无认证机制**：当前版本仅通过用户名区分角色，无密码验证，依赖网络隔离保护
- **单实例部署**：不支持高可用集群部署

#### 协议限制
- **仅支持 RMI 协议**：不支持 SSL/JMXMP 等加密协议
- **明文传输**：JMX 连接和 HTTP 服务均为明文，需通过 VPN/内网保护

#### 平台限制
- **时区问题**：数据聚合按标准时间 0 点（北京时间 8 点）进行，不支持配置时区
- **数据库字符集**：必须使用 UTF-8 编码，否则可能出现中文乱码

### 6.2 性能考虑

#### 定时任务调度
- **拉取周期**：默认每 30 秒检查一次，根据表配置的 `fetch_period` 决定是否拉取
- **服务器数量影响**：每次拉取会串行访问所有服务器，服务器数量过多会延长拉取时间
- **数据库写入压力**：拉取后立即写入数据库，高频拉取可能导致数据库负载过高

**优化建议**：
- 合理设置 `fetch_period`（推荐 5-10 分钟）
- 使用 `fetch_offset` 错开不同表的拉取时间
- 定期归档历史数据（利用自动表重命名机制）

#### 连接管理
- **连接复用**：每个服务器维护一个 JMX 连接，连接失败时自动重连
- **超时设置**：JMX 连接超时时间建议设置为 5-10 秒
- **连接泄漏**：服务停止时会自动关闭所有连接

#### 数据库优化
- **索引优化**：确保主键（zoneid, timestamp）有索引
- **分区表**：对于大表（>1GB），建议使用 MySQL 分区表按时间分区
- **定期清理**：设置数据保留策略，定期删除过期数据

### 6.3 安全注意事项

#### 网络隔离
- **HTTP 服务应仅在内网开放**，禁止公网访问
- 建议使用防火墙白名单限制源 IP
- 通过 VPN/堡垒机访问生产环境

#### 权限管理
- **当前版本无密码认证**，仅通过 access.xml 用户名区分角色
- 推荐改进方案：
  - 集成 LDAP/AD 认证
  - 实现基于 Token 的 API 认证
  - 启用 HTTPS + Basic Auth

#### 数据安全
- **数据库凭据管理**：mbeandb.xml 包含数据库密码，应设置严格的文件权限（chmod 600）
- **JMX 凭据**：如果 JMX 启用认证，凭据应加密存储
- **敏感数据脱敏**：日志中不应包含密码等敏感信息

#### 审计日志
- **操作日志**：当前仅记录拉取任务日志，建议增加用户操作审计
- **日志保留**：生产环境建议保留至少 90 天日志
- **日志集中管理**：接入 ELK/Splunk 等日志平台

### 6.4 故障排查指南

#### 问题 1：服务启动失败
**症状**：执行启动命令后立即退出或报错

**可能原因**：
- 配置文件路径错误或格式错误
- 端口已被占用
- 依赖库缺失

**排查步骤**：
```bash
# 1. 检查配置文件是否存在
ls -l mbeandb.xml jmxports.xml access.xml

# 2. 验证配置文件 XML 格式
xmllint --noout mbeandb.xml

# 3. 检查端口占用
netstat -tuln | grep :80

# 4. 检查依赖库
java -jar jmonitor.jar
# 查看 ClassNotFoundException 或 NoClassDefFoundError

# 5. 启用详细日志
java -Djava.util.logging.config.file=logging.properties -jar jmonitor.jar ...
```

#### 问题 2：无法连接 JMX 服务器
**症状**：Web UI 显示服务器状态为"未连接"或"连接失败"

**可能原因**：
- JMX 端口配置错误
- 服务器未开启 JMX 服务
- 网络不通或防火墙阻止

**排查步骤**：
```bash
# 1. 检查网络连通性
ping 172.20.54.11

# 2. 检查 JMX 端口
telnet 172.20.54.11 29023

# 3. 验证 JMX 服务是否开启
# 在游戏服务器上执行：
jps -l  # 查看 Java 进程
jinfo <pid> | grep jmx  # 查看 JMX 配置

# 4. 查看 jmonitor 日志
tail -f jmonitor.log | grep "connect error"
```

#### 问题 3：数据未拉取
**症状**：表数据为空或长时间未更新

**可能原因**：
- 拉取周期配置错误
- MBean 路径或属性名错误
- 数据库连接失败

**排查步骤**：
```bash
# 1. 检查表配置
# 访问 Web UI: http://<ip>:<port>/table
# 查看 "isWorking" 字段是否为 true

# 2. 查看拉取日志
tail -f jmonitor.log | grep "fetch server.size"

# 3. 手动触发拉取
# POST http://<ip>:<port>/server/{id}

# 4. 检查 MBean 是否存在
# 使用 jconsole 连接目标服务器，浏览 MBean 树
```

#### 问题 4：Web UI 无法访问
**症状**：浏览器访问超时或 404 错误

**可能原因**：
- HTTP 服务未启动
- IP/端口绑定错误
- 防火墙阻止

**排查步骤**：
```bash
# 1. 检查进程是否运行
ps aux | grep jmonitor

# 2. 检查端口监听
netstat -tuln | grep :80

# 3. 测试本地访问
curl http://localhost:80/server

# 4. 检查防火墙
iptables -L -n | grep 80
```

#### 问题 5：权限拒绝
**症状**：Web UI 操作返回 403 Forbidden

**可能原因**：
- 用户角色配置错误
- access.xml 配置错误

**排查步骤**：
```bash
# 1. 检查 access.xml 配置
cat access.xml

# 2. 确认用户角色映射
# <role name="viewer"> 是否包含当前用户

# 3. 检查权限规则
# <forbid methods="POST" path="server"/> 是否阻止了操作

# 4. 临时授予 manager 权限测试
# 在 <role name="manager"> 下添加用户
```

---

## 7. 扩展与改进

### 7.1 当前架构优势
- **模块化设计**：Manager/Table/Chart/Server 分离，便于扩展
- **RESTful API**：标准化接口，易于集成
- **插件化表结构**：通过 XML 配置动态添加监控表，无需修改代码

### 7.2 推荐改进方向

#### 短期优化（1-2 周）
1. **HTTPS 支持**：启用 SSL/TLS 加密传输，保护数据安全
2. **密码认证**：实现 Basic Auth 或 Token 认证，替代单纯用户名区分
3. **配置热更新**：支持动态重载配置文件，无需重启服务
4. **健康检查接口**：提供 `/health` 端点用于监控服务存活性

#### 中期优化（1-2 个月）
5. **Prometheus 集成**：暴露 Prometheus metrics 端点，集成到现代监控栈
6. **数据库连接池**：使用 HikariCP 或 Druid 连接池，优化数据库性能
7. **异步拉取**：使用线程池并发拉取多个服务器数据，提升效率
8. **自动建表**：根据 mbeandb.xml 配置自动创建数据库表结构

#### 长期优化（3-6 个月）
9. **高可用集群**：支持多实例部署，使用 Zookeeper/Consul 协调任务
10. **时序数据库**：迁移到 InfluxDB/TimescaleDB，优化时序数据存储
11. **前端现代化**：使用 React/Vue 重写前端，提升用户体验
12. **告警机制**：支持指标阈值告警，集成邮件/短信/钉钉通知

### 7.3 监控集成示例

#### 集成到 Prometheus
```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'jmonitor'
    metrics_path: '/metrics'  # 需实现 Prometheus exporter
    static_configs:
      - targets: ['localhost:8080']
```

#### 集成到 Grafana
```json
{
  "datasource": "MySQL",
  "query": "SELECT timestamp, online_count FROM online_statistics WHERE zoneid=2600"
}
```

### 7.4 参考资料
- JMX 官方文档：https://docs.oracle.com/javase/tutorial/jmx/
- Jersey RESTful 框架：https://eclipse-ee4j.github.io/jersey/
- Freemarker 模板引擎：https://freemarker.apache.org/
- 游戏服务器监控最佳实践：（内部文档）

---

## 8. 快速参考

### 8.1 常用命令速查表

```bash
# 启动服务（默认配置）
java -jar jmonitor.jar mbeandb.xml jmxports.xml access.xml 80

# 启动服务（指定日志配置）
java -Djava.util.logging.config.file=logging.properties -jar jmonitor.jar mbeandb.xml jmxports.xml access.xml 80

# 构建项目
ant all

# 运行测试（需配置 build.xml 中的 run target）
ant run

# 清理构建产物
ant clean
```

### 8.2 Web UI 快速操作

| 操作 | URL | 方法 |
|-----|-----|------|
| 查看服务器列表 | `/server` | GET |
| 查看表列表 | `/table` | GET |
| 查看图表列表 | `/chart` | GET |
| 查看表数据 | `/tabledata/{table_id}?zoneid=2600&from=2025-11-01&to=2025-11-27` | GET |
| 导出 CSV | `/tabledatadumper/{table_id}?zoneid=2600&from=2025-11-01&to=2025-11-27` | GET |
| 查看配置文件 | `/cfg/mbeandb` | GET |

### 8.3 核心配置文件清单

| 文件名 | 用途 | 关键字段 |
|-------|------|---------|
| `mbeandb.xml` | 监控配置 | `<table>`, `<chart>`, `<chartchain>`, `<database>` |
| `jmxports.xml` | 服务器列表 | `<server zoneid="" gsip="" gsjmxport1="">` |
| `access.xml` | 权限控制 | `<role>`, `<user>`, `<forbid>` |
| `logging.properties` | 日志配置 | `java.util.logging` 配置 |

### 8.4 关键时间参数

| 参数 | 说明 | 默认值 |
|-----|------|-------|
| 定时任务检查间隔 | 每次检查是否需要拉取数据 | 30 秒 |
| 表拉取周期 | `fetch_period` | 5 分钟（配置化） |
| 表拉取偏移 | `fetch_offset` | 0 分钟（配置化） |
| 日汇总时间 | 每天标准时间 0 点 | 北京时间 8:00 |
| 表归档周期 | 表大小 > 100MB 且间隔 ≥ 7 天 | 7 天 |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | jmonitor (JMX Monitor Web Service) |
| **版本** | 见 Jar 文件时间戳 |
| **主要维护者** | 见项目 Git 提交历史 / access.xml 中的 manager 用户列表 |
| **代码位置** | `server/tools/jmonitor/` |
| **文档生成时间** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, Jersey 1.9.1, Freemarker, MySQL, JMX/RMI |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器运维团队
- 查看项目 Wiki 获取更多文档
- 参考 access.xml 中的 manager 用户列表联系管理员

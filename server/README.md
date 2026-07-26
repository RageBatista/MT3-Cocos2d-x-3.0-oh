# MT3 游戏服务器总览

> **梦幻西游 MG 版本** - 服务器端结构、构建与工具导航
>
> 本文档按当前工作树实物描述 `server/` 子树；构建与边界裁决以 `server/server/game_server/build.xml`、`server/AGENTS.md`、根 `AGENTS.md` 和 `.claude/RULES.md` 为准。

---

## 📋 目录

- [1. 目录结构与快速导航](#1-目录结构与快速导航)
- [2. 服务子工程 (server/server/)](#2-服务子工程-serverserver)
- [3. 数据库与 XDB 工具](#3-数据库与-xdb-工具)
- [4. 开发与代码生成工具](#4-开发与代码生成工具)
- [5. 运维与日志工具](#5-运维与日志工具)
- [6. 技术架构总览](#6-技术架构总览)
- [7. 快速开始指南](#7-快速开始指南)
- [8. 常见问题 FAQ](#8-常见问题-faq)
- [9. 文档维护信息](#9-文档维护信息)

---

## 1. 目录结构与快速导航

`server/` 顶层实物（2026-07-26 核对）：

| 目录 | 角色 |
|------|------|
| `core/` | 基础框架库源码：`common/`、`io/`、`jio/`、`mk/`、`perf/`、`rpc/` |
| `doc/` | 历史部署文档（`.doc`/`.txt`/`.pdf`：部署说明、nameserver、热更新、跨服 PVP 配置等） |
| `game/` | 游戏运行侧资料（`common/`、`server1/`、`server2/`） |
| `gsxdb/` | XDB 库（`lib/`、`src/`） |
| `gsxdb_source/` | XDB 相关源码树 |
| `ops/` | 运维脚本（`qd/`、`game/`、`Test-QdScripts.ps1`） |
| `server/` | **服务子工程主目录**（见第 2 节；主构建入口在其中的 `game_server/`） |
| `serverbin/` | 运行时分发产物；由 `copyfile2serverbin` 等构建目标刷新，不作为长期手写源 |
| `tools/` | 服务端工具链（见第 3-5 节） |

> 注意：主构建入口的完整仓库路径为 `server/server/game_server/build.xml`（`server` 出现两层）。

## 2. 服务子工程 (server/server/)

`server/server/` 下的实际子工程：

| 子工程 | 说明 |
|--------|------|
| `game_server/` | **主构建与代码生成入口**：`build.xml`、`gnet.xml`、`gnet.cross.xml`、`protocol.main.xml`、`gs/`（编译打包子工程）、`nameserver/`、`localprotocols/`、`conf.m4`；另含架构分析文档（`00-文档索引` 等） |
| `game_server_f/` | game_server 的并存变体工程 |
| `gate_server/`、`name_server/`、`proxy_server/`、`zone_server/` | 网关/命名/代理/分区类服务子工程（职责以各自源码与配置为准） |
| `sdk_server/`、`spirit_server/`、`trans_server/` | SDK 接入、精灵、传输类服务子工程（职责以各自源码与配置为准） |
| `web_app/` | Web 应用子工程 |
| `common/` | 服务子工程共享部分 |

`build.xml`（`server/server/game_server/`）实际构建目标：

| target | 用途（源自 build.xml 注释与定义） |
|--------|------|
| `init` | 首次必用：执行 `genfiles` 并生成 `mhsdcounter.jar` |
| `genfiles` | 生成全部文件（依赖 `genrpc`、`genxdb`、`gengbeans`、`jsconvert`） |
| `genrpc` | 只生成协议/RPC 相关文件（源：`protocol.main.xml` 等） |
| `genxdb` | 只生成 XDB 相关 `xtable`/`xbean` Java 文件（源：`gsx.mkdb.xml`） |
| `gengbeans` | 只生成策划配置 Java 文件（源：仓库根 `gbeans/*.xml`，36 个） |
| `robot` | 生成最新机器人 |
| `dist` | 编译打包服务器（依赖 `confm4`、`genfiles`，委托 `gs/` 子工程） |
| `checkconf` / `confm4` / `jsconvert` / `copyfile2serverbin` | 配置检查、m4 配置展开、JS 转换、产物拷贝到 `serverbin/` |

**没有 `compile` / `jar` 目标**；编译发生在 `dist` 链路的 `gs/` 子工程内。

## 3. 数据库与 XDB 工具

`server/tools/` 中与数据库/XDB 相关的实际目录：

| 工具 | 用途 |
|------|------|
| `monkeyking/` | XDB 数据库引擎（xbean/xtable 代码生成与运行支持） |
| `xmerge/`、`newxmerge/` | 数据库合并（合服） |
| `xclear/` | 数据库清理 |
| `xdbench/` | 数据库基准测试 |
| `xbrowse/` | XDB 数据浏览 |
| `transform_mkdb/` | mkdb 数据转换 |
| `jnidb/` | JNI 数据库支撑 |

## 4. 开发与代码生成工具

| 工具 | 用途 |
|------|------|
| `rpcgen/` | RPC/协议代码生成（配合 `genrpc`） |
| `convxml/` | XML 配置转换/代码生成 |
| `exportdata/` | 数据导出 |
| `jsconvert/` | JS 转换（`build.xml` 的 `jsconvert` 目标相关） |
| `calccap/` | 容量计算 |
| `Checkexcel`（仓库根 `tools/`） | 策划表检查（客户端/服务端共用工具链见根 `tools/`） |

## 5. 运维与日志工具

| 工具 | 用途 |
|------|------|
| `jmxc/` | JMX 控制台/主控接入 |
| `jmonitor/` | 运行监控 |
| `jauthc/` | 认证支撑 |
| `LogViewer/` | 日志查看 |
| `bin/`、`testdir/` | 工具运行支撑与测试目录 |
| `../ops/` | 渠道/区服运维脚本（`qd/`、`Test-QdScripts.ps1`） |

## 6. 技术架构总览

- **技术栈**：Java（JDK 1.7/1.8）+ Apache Ant + gnet/RPC + XDB/XBean。禁止以 JDK 9+、Maven、Gradle 替换主线（见 `.claude/RULES.md`）。
- **代码生成边界**：`server/**/xbean/*.java`、`server/**/rpc/*.java` 为生成产物，禁止长期手工维护；变更回到 `protocol.main.xml`、`gsx.mkdb.xml`、`gbeans/*.xml` 等源定义后重新生成。
- **协议联动**：客户端 `client/FireClient/Application/ProtoDef/**` 与 Lua 协议脚本同服务端协议定义存在生成关系；协议调整必须双侧同步核对。
- **框架层**：`server/core/`（common/io/jio/mk/perf/rpc）为基础库；`server/gsxdb/`、`gsxdb_source/` 承载 XDB。

## 7. 快速开始指南

从仓库根执行（Windows PowerShell）：

```powershell
# 定位主构建入口
Get-Item .\server\server\game_server\build.xml

# 首次初始化（genfiles + mhsdcounter.jar）
ant -f .\server\server\game_server\build.xml init

# 重新生成协议 / XDB / 策划配置代码
ant -f .\server\server\game_server\build.xml genfiles

# 编译打包
ant -f .\server\server\game_server\build.xml dist
```

前置要求：JDK 1.7/1.8、Ant 1.9+（`java -version`、`ant -version` 自检）。

## 8. 常见问题 FAQ

### Q1: 为什么 `ant compile` / `ant jar` 失败？
`build.xml` 中不存在这两个目标。编译打包统一走 `dist`（内部委托 `gs/` 子工程）；代码生成走 `genfiles` 或细分的 `genrpc`/`genxdb`/`gengbeans`。

### Q2: 修改协议后要做什么？
修改 `protocol.main.xml` 等源定义 → `ant genrpc`（或 `genfiles`）→ 重新编译；同时核对客户端 ProtoDef 生成链是否需要同步（见根 `AGENTS.md` §3.4）。

### Q3: 策划配置（gbeans）改动如何生效？
修改仓库根 `gbeans/*.xml` → `ant gengbeans` → 重新编译打包。`gbeans/*.xml` 是源定义，不是生成结果。

### Q4: `serverbin/` 里的文件可以直接改吗？
不可以。`serverbin/` 是运行分发产物，由 `copyfile2serverbin` 等目标刷新；修改应回到源码与配置源。

### Q5: 部署文档在哪里？
历史部署资料在 `server/doc/`（MT3服务部署说明、外网服务器部署基本配置、nameserver 文档、热更新说明、跨服 PVP3 配置等）；使用时需结合当前工作树核对时效。

## 9. 文档维护信息

| 项目 | 信息 |
|-----|------|
| **项目名称** | MT3 梦幻西游 MG 版本服务器 |
| **技术栈** | Java 1.7/1.8, Ant, gnet/RPC, XDB/XBean |
| **文档版本** | v2.0 |
| **最后更新** | 2026-07-26 |
| **维护者** | MT3 开发团队 |

### 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v2.0 | 2026-07-26 | 按当前工作树实物重写：v1.0 所述 `server/tools/` 下 9 个游戏服务器目录（gateway/gdelivery/gfaction/glink/gprovider/gtransaction/gtradestart/gpvp/gws）与 `server/bin/`、`tools/logs/` 在本仓库中不存在，已全部移除；补齐 `server/server/*` 真实子工程、`build.xml` 真实目标与生成代码边界。 |
| v1.0 | 2025-11-27 | 初版（结构描述与本仓库实物不符，已被 v2.0 取代） |

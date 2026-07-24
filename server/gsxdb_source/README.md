# GSXDB 源代码与使用指南

![Java](https://img.shields.io/badge/Java-8%2B-blue.svg) ![Build](https://img.shields.io/badge/build-manual-lightgrey.svg) ![Coverage](https://img.shields.io/badge/coverage-N%2FA-lightgrey.svg) ![Status](https://img.shields.io/badge/status-active-success.svg) ![License](https://img.shields.io/badge/license-proprietary-red.svg)

## 项目概述
- GSXDB 是 MT3 游戏服务器的核心业务模块（由 `gs.jar` 构建后复制并发布为 `gsxdb.jar`），承担网络协议处理、业务逻辑编排、数据模型定义与配置加载。
- 主要职责：
  - 统一启动流程与服务生命周期管理（`fire.pb.main.Gs`）
  - 协议定义与分发（`fire.pb.*`、`gnet.*`）
  - 业务逻辑与状态管理（如角色上下线、战斗、场景等）
  - 配置加载与属性管理（`fire.pb.main.ConfigManager`、`XStreamUnmarshaller`）
- 构建产物：`e:\MT3\server\server\game_server\gs\dist\gs.jar`（构建后复制命名为 `gsxdb.jar`）

### 技术栈
- 语言：Java 8+
- 日志：Log4j 1.x、Log4j 2（上游工程统一提供）
- HTTP 客户端：Apache HttpComponents AsyncClient
- 配置反序列化：XStream
- 管理与监控：JMX
- 内部库：`mkdb`、`mkio`、`gnet`、`xbean`（随 MT3 服务器工程提供）

### 主要依赖项（由上游服务器工程提供）
- `org.apache.httpcomponents:httpasyncclient`
- `log4j:log4j` 与 `org.apache.logging.log4j:log4j-api/log4j-core`
- `com.thoughtworks.xstream:xstream`
- JMX（JDK 自带）

## 目录
- [项目概述](#项目概述)
- [目录结构说明](#目录结构说明)
- [安装指南](#安装指南)
- [使用说明](#使用说明)
- [开发指南](#开发指南)
- [问题反馈](#问题反馈)
- [许可证](#许可证)

## 目录结构说明

### 源码目录统计
- `src`：约 4350 个文件
- `beans`：约 275 个文件
- `confsrc`：约 320 个文件
- 总计：约 4945 个文件

### 主要包结构

```
e:\MT3\docs\gsxdb_source
├── src/           # 业务逻辑代码
│   ├── fire/      # 核心业务包
│   │   ├── msp/   # 服务端处理逻辑
│   │   ├── pb/    # 协议定义和处理
│   │   ├── log/   # 日志模块
│   │   └── util/  # 工具类
│   ├── gnet/      # 网络通信相关协议
│   ├── mkdb/      # 数据库过程封装
│   ├── mkio/      # I/O 协议框架
│   └── xbean/     # 业务数据模型
├── beans/         # 数据模型（生成/定义）
│   ├── fire/      # 游戏相关数据模型
│   └── gnet/      # 网络相关数据模型
├── confsrc/       # 配置相关工具与转换
└── MANIFEST.MF    # 打包清单
```

### 核心模块示意图

```
          +-------------------+
          |  Client/Link      |
          +---------+---------+
                    |
               gnet.link
                    |
        +-----------v-----------+
        |  fire.pb.main.Gs      |  启动/生命周期/JMX
        +------+----------------+
               |
      +--------v--------+    +-------------------+
      | ConfigManager    |    | HttpAsyncClient   |
      | XStream/XML      |    | 日志/监控         |
      +--------+--------+    +-------------------+
               |
       业务模块/场景/战斗/角色等
```

## 安装指南

### 环境要求
- 操作系统：Windows 10/11（开发）、Linux x86_64（部署）
- 必需工具：JDK 8+（建议 1.8u202 及以上）、Git
- 环境变量：
  - `JAVA_HOME` 指向 JDK 安装目录
  - `PATH` 包含 `%JAVA_HOME%\bin`（Windows）或 `$JAVA_HOME/bin`（Linux）

### 依赖安装
- 默认情况下，依赖由上游 MT3 服务器工程统一管理与提供，无需在本仓库单独安装。
- 如需独立编译，请确保以下依赖在运行/编译时的 `CLASSPATH` 中：
  - `httpasyncclient`、`log4j`（1.x 与 2.x）、`xstream` 等

### 构建准备（可选）
- 切换调试/发布模式：
  - 调试：将 `src\config\CompileArg.debug` 覆盖为 `src\config\CompileArg.java`
  - 发布：将 `src\config\CompileArg.dist` 覆盖为 `src\config\CompileArg.java`

### 独立编译与打包示例（无上游工程时）
- Windows PowerShell：
```
mkdir out
Get-ChildItem -Recurse -Filter *.java | ForEach-Object { $_.FullName } | Set-Content sources.txt
javac -encoding UTF-8 -cp lib/* -d out @sources.txt
jar cfm gsxdb.jar MANIFEST.MF -C out .
```
- Linux Bash：
```
mkdir -p out
find . -name "*.java" > sources.txt
javac -encoding UTF-8 -cp lib/* -d out @sources.txt
jar cfm gsxdb.jar MANIFEST.MF -C out .
```

## 使用说明

### 基本运行命令
```
java -jar gsxdb.jar -rmiport 20981 -zoneid 2662 -usemysql 1
```

### 运行参数说明（摘自 `fire.pb.main.ConfigManager`）
- `-rmiport` RMI 端口（默认 20981）
- `-zoneid` 区服 ID（默认 2662）
- `-usemysql` 是否启用 MySQL（`1` 表示启用）

### 常见使用场景示例
- 切换调试模式：
```java
boolean debug = fire.pb.main.Gs.isDebug();
```
- 读取属性配置：
```java
java.util.Properties sys = fire.pb.main.ConfigManager.getInstance().getPropConf("sys");
String port = sys.getProperty("sys.http.port");
```
- 踢角色下线（关服清理流程片段）：
```java
new fire.pb.state.PRoleOffline(roleId, fire.pb.state.PRoleOffline.TYPE_LINK_BROKEN).submit();
```

## 开发指南

### 贡献流程
- 创建分支：`feature/xxx` 或 `fix/xxx`
- 遵循最小可审查提交，提供清晰的提交信息
- 提交合并请求并通过代码评审

### 构建与测试
- 构建：使用上游 MT3 服务器工程的标准构建流程（推荐），或使用本文档的独立编译示例。
- 测试：建议在上游工程中集成 JUnit 测试；为协议与关键业务流程补充单元测试与集成测试。
- 日志：统一使用上游工程的日志配置，避免在模块内硬编码日志参数。

### 代码风格
- 包命名与分层遵循现有结构（`fire.pb.*`、`gnet.*`、`mkdb.*`）
- 类型命名使用驼峰，常量使用大写下划线
- 缩进与格式与现有文件保持一致（Tab 或 4 空格）
- 禁止提交敏感信息与密钥；配置通过属性文件/环境变量注入

## 问题反馈
- 内部项目，请通过企业内部的 Issue/需求管理平台提交（Jira/禅道/Redmine 等），或联系项目维护团队。

## 许可证
- 本模块为内部专用，版权归属 MT3 项目组。未经授权不得对外传播或使用。


---
name: java-development
version: 1.5.0
priority: high
category: server
description: |
  MT3服务器端Java开发技能。涵盖分布式微服务架构、JDK 1.7+开发规范、Ant构建系统。
  触发词: Java, 服务器, 后端, JDK, Ant, 分布式, 微服务, 服务端, Procedure, gbeans, GameServer, Manager, Session
dependencies:
  - project-context
  - git-workflow
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 12000
---

# Java 开发技能 (MT3 服务器端)

**版本**: v1.5.0
**最后更新**: 2026-04-11

---

## 🏗️ 分布式架构理解

### 代码规模统计

> **数据来源**: 代码分析报告 [`03-服务器端Java代码分析.md`](../../../docs/09-历史归档/文档审计/2026-03-06-服务器端Java代码分析.md)

| 指标 | 数值 |
|------|------|
| **Java 源文件总数** | 13,983 个 |
| **Java 代码总行数** | ~1,844,640 行 |
| **gbeans 配置文件** | 36 个 |
| **协议定义文件** | 30+ 个 |
| **Procedure 子类** | 300+ 个 |

### 架构图

```
                    客户端 (Client)
                          │
                          ▼
            ┌─────────────────────────────┐
            │     gate_server (网关)       │
            │     - 连接管理               │
            │     - 协议转发               │
            └──────────┬──────────────────┘
                       │
       ┌───────────────┼───────────────┐
       ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ game_server │ │ zone_server │ │spirit_server│
│  (游戏逻辑)  │ │   (区域)    │ │   (灵兽)    │
└──────┬──────┘ └─────────────┘ └─────────────┘
       │
       ▼
┌─────────────────────────────────────────────┐
│              支撑服务层                      │
├──────────┬──────────┬──────────┬───────────┤
│name_server│proxy_server│trans_server│sdk_server│
│  (名称)   │  (代理)   │  (传输)   │  (SDK)   │
└──────────┴──────────┴──────────┴───────────┘
```

### 服务模块职责（10个服务）

| 序号 | 模块 | 职责 | 语言 | 端口 |
|------|------|------|------|------|
| 1 | **game_server** | 核心游戏逻辑处理 | Java | 8001 |
| 2 | **game_server_f** | 游戏服务副本（分线） | - | - |
| 3 | **gate_server** | 网关，客户端连接入口 | C++ | 9000 |
| 4 | **zone_server** | 区域管理，场景服务 | - | 8002 |
| 5 | **spirit_server** | 灵兽系统服务 | - | 8003 |
| 6 | **name_server** | 名称服务，全局 ID | Java | 7000 |
| 7 | **proxy_server** | 代理服务，跨服通信 | C++ | 8010 |
| 8 | **trans_server** | 数据传输服务 | - | 8020 |
| 9 | **sdk_server** | SDK 接入服务 | Java | 9001 |
| 10 | **logservice** | 日志服务 | C++ | - |

---

## 📝 代码规范详解

### 命名规范

```java
// ❌ 错误示例
package GameServer;

public class playerManager {
    private int player_count;
    private String SERVER_NAME;
}

// ✅ 正确示例
package com.mt3.gameserver.logic;

public class PlayerManager {
    // 成员变量: camelCase
    private int playerCount;
    private String serverName;

    // 常量: 全大写 + 下划线
    public static final int MAX_PLAYER_COUNT = 10000;

    // 方法: camelCase
    public void processMessage(Message msg) {
        // ...
    }

    public PlayerData getPlayerData(int playerId) {
        return null;
    }
}

// 接口: I 前缀 或 able/ible 后缀
public interface IGameService {
    void start();
    void stop();
}

public interface Serializable {
    byte[] serialize();
}
```

### 包结构

```
server/server/game_server/
├── src/
│   └── com/mt3/gameserver/
│       ├── logic/          # 游戏逻辑
│       │   ├── PlayerManager.java
│       │   └── ItemManager.java
│       ├── protocol/       # 协议定义
│       │   ├── LoginProtocol.java
│       │   └── ChatProtocol.java
│       ├── service/        # 服务类
│       │   └── GameService.java
│       └── util/           # 工具类
│           └── TimeUtil.java
├── xgenoutput/             # xbean 生成代码
│   └── xbean/
│       ├── IdState.java
│       └── NameState.java
└── build.xml               # Ant 构建配置
```

---

## 🔑 核心概念

### 1. gnet 网络框架

```java
// 协议定义 (gnet.xml)
<protocol id="1001" name="LoginRequest">
    <field name="username" type="string"/>
    <field name="password" type="string"/>
</protocol>

<protocol id="1002" name="LoginResponse">
    <field name="success" type="boolean"/>
    <field name="playerId" type="int"/>
</protocol>

// 协议处理器
public class LoginHandler implements ProtocolHandler {
    @Override
    public void handle(Session session, LoginRequest request) {
        // 验证登录
        boolean success = validateLogin(
            request.username,
            request.password
        );

        // 发送响应
        LoginResponse response = new LoginResponse();
        response.success = success;
        response.playerId = getPlayerId(request.username);

        session.send(response);
    }
}
```

### 2. xbean 数据管理

```java
// xbean 定义 (state.xml)
<bean name="PlayerState">
    <field name="playerId" type="int"/>
    <field name="name" type="string"/>
    <field name="level" type="int"/>
    <field name="exp" type="long"/>
</bean>

// 生成的代码 (xgenoutput/xbean/PlayerState.java)
public class PlayerState {
    private int playerId;
    private String name;
    private int level;
    private long exp;

    // getter/setter...
}

// 使用
PlayerState state = new PlayerState();
state.setPlayerId(1001);
state.setName("张三");
state.setLevel(10);
state.setExp(5000);

// 序列化保存
byte[] data = state.marshal();
db.save("player_" + state.getPlayerId(), data);
```

### 3. RPC 远程调用

```java
// 服务接口
public interface IZoneService extends Remote {
    // 进入场景
    void enterScene(int playerId, int sceneId);

    // 离开场景
    void leaveScene(int playerId);
}

// 服务实现
public class ZoneServiceImpl implements IZoneService {
    @Override
    public void enterScene(int playerId, int sceneId) {
        Scene scene = getScene(sceneId);
        Player player = getPlayer(playerId);
        scene.addPlayer(player);
    }

    @Override
    public void leaveScene(int playerId) {
        Scene scene = getPlayerScene(playerId);
        scene.removePlayer(playerId);
    }
}

// 客户端调用
IZoneService zoneService = getRemoteService("zone_server");
zoneService.enterScene(1001, 100);
```

### 4. 服务间通信

```java
// 跨服消息
public class CrossServerMessage {
    private String sourceServer;
    private String targetServer;
    private int messageId;
    private byte[] data;
}

// 发送跨服消息
public void sendCrossServerMessage(
    String targetServer,
    int messageId,
    byte[] data
) {
    CrossServerMessage msg = new CrossServerMessage();
    msg.sourceServer = getServerName();
    msg.targetServer = targetServer;
    msg.messageId = messageId;
    msg.data = data;

    proxyService.route(msg);
}

// 处理跨服消息
public void handleCrossServerMessage(CrossServerMessage msg) {
    ProtocolHandler handler = getHandler(msg.messageId);
    handler.handle(msg.data);
}
```

---

## 🛠️ 常用操作

### 添加新协议

```java
// 1. 在 gnet.xml 中定义协议
<protocol id="2001" name="CreateRoleRequest">
    <field name="roleName" type="string"/>
    <field name="roleClass" type="int"/>
</protocol>

<protocol id="2002" name="CreateRoleResponse">
    <field name="success" type="boolean"/>
    <field name="roleId" type="int"/>
</protocol>

// 2. 运行 rpcgen 生成代码
ant rpcgen

// 3. 实现协议处理器
public class CreateRoleHandler implements ProtocolHandler {
    @Override
    public void handle(Session session, CreateRoleRequest request) {
        // 创建角色
        int roleId = createRole(request.roleName, request.roleClass);

        // 发送响应
        CreateRoleResponse response = new CreateRoleResponse();
        response.success = (roleId > 0);
        response.roleId = roleId;

        session.send(response);
    }
}

// 4. 注册处理器
protocolManager.register(2001, new CreateRoleHandler());
```

### 添加新服务模块

```java
// 1. 创建服务主类
public class MyService {
    private ServiceConfig config;
    private NetworkManager networkManager;
    private ProtocolManager protocolManager;

    public void start() throws Exception {
        // 加载配置
        config = loadConfig();

        // 初始化网络
        networkManager = new NetworkManager(config.getPort());
        networkManager.start();

        // 注册协议
        registerProtocols();

        System.out.println("MyService started on port " + config.getPort());
    }

    public void stop() {
        networkManager.stop();
        System.out.println("MyService stopped");
    }

    private void registerProtocols() {
        protocolManager.register(1001, new MyProtocolHandler());
    }
}

// 2. 创建启动脚本
#!/bin/bash
java -cp lib/*:bin com.mt3.myservice.MyService

// 3. 创建 build.xml
<project name="myservice" default="build">
    <target name="build">
        <javac srcdir="src" destdir="bin" includeantruntime="false">
            <classpath>
                <fileset dir="lib" includes="**/*.jar"/>
            </classpath>
        </javac>
    </target>
</project>
```

---

## ⚠️ 常见陷阱

### 1. 并发问题

```java
// ❌ 错误: 线程不安全
public class PlayerManager {
    private Map<Integer, Player> players = new HashMap<>();

    public void addPlayer(Player player) {
        players.put(player.getId(), player);  // 可能并发问题
    }
}

// ✅ 正确: 使用并发集合
public class PlayerManager {
    private ConcurrentHashMap<Integer, Player> players =
        new ConcurrentHashMap<>();

    public void addPlayer(Player player) {
        players.put(player.getId(), player);  // 线程安全
    }
}
```

### 2. 内存泄漏

```java
// ❌ 错误: 缓存未清理
public class SessionManager {
    private Map<Integer, Session> sessions = new HashMap<>();

    public void addSession(Session session) {
        sessions.put(session.getId(), session);
        // 忘记在断开时移除
    }
}

// ✅ 正确: 及时清理
public class SessionManager {
    private Map<Integer, Session> sessions = new ConcurrentHashMap<>();

    public void addSession(Session session) {
        sessions.put(session.getId(), session);

        // 监听断开事件
        session.onDisconnect(() -> {
            sessions.remove(session.getId());
        });
    }
}
```

### 3. 阻塞操作

```java
// ❌ 错误: 在网络线程中执行 IO
public void handle(Session session, SaveDataRequest request) {
    database.save(request.data);  // 阻塞操作!
    session.send(new SaveDataResponse());
}

// ✅ 正确: 异步处理
public void handle(Session session, SaveDataRequest request) {
    executor.submit(() -> {
        database.save(request.data);
        session.send(new SaveDataResponse());
    });
}
```

---

## 🎯 实践项目

### 初级项目：实现简单的聊天功能
```
任务：实现玩家间聊天功能
步骤：
1. 定义聊天协议 (ChatRequest/ChatResponse)
2. 实现聊天处理器
3. 管理在线玩家列表
4. 支持私聊和广播
5. 测试验证
```

### 中级项目：实现好友系统
```
任务：设计并实现好友系统
要求：
- 添加/删除好友
- 好友列表查询
- 好友在线状态
- 跨服好友支持
- 数据持久化
```

### 高级项目：实现负载均衡
```
任务：为 game_server 实现负载均衡
技术：
- 统计服务器负载
- 实现玩家分配策略
- 支持动态扩容
- 性能监控和告警
```

---

## 📚 推荐阅读

### 项目文档
1. [服务器架构](../../BUILD_GUIDE.md#服务器端架构概览)
2. [gnet 框架](gnet-framework.md)
3. [分布式架构](distributed-arch.md)

### 外部资源
1. **Effective Java** - Joshua Bloch
2. **Java 并发编程实战** - Brian Goetz
3. **分布式系统原理与范型** - Andrew S. Tanenbaum

---

## ✅ 技能检查清单

### 初级检查点
- [ ] 能够成功编译服务器
- [ ] 理解分布式架构
- [ ] 能够阅读协议定义
- [ ] 熟悉项目代码规范
- [ ] 能够启动和停止服务

### 中级检查点
- [ ] 能够定义和实现新协议
- [ ] 理解 gnet 框架原理
- [ ] 掌握 xbean 数据管理
- [ ] 能够实现跨服通信
- [ ] 能够排查常见问题

### 高级检查点
- [ ] 能够设计服务架构
- [ ] 能够优化服务器性能
- [ ] 能够处理并发问题
- [ ] 能够排查分布式问题
- [ ] 能够指导团队成员

---

**相关技能**:
- [Ant 构建](ant-build.md)
- [gnet 框架](gnet-framework.md)
- [分布式架构](distributed-arch.md)
- [性能优化](../common/performance-optimization.md)

**下次更新**: 2026-02-20

---

## 📋 更新日志

### v1.1.0 (2025-11-24)
- 添加版本控制和更新日志
- 完善技能检查清单
- 更新相关技能链接

### v1.0.0 (初始版本)
- 创建 Java 服务器开发技能文档
- 包含分布式架构、gnet 框架、xbean 数据管理

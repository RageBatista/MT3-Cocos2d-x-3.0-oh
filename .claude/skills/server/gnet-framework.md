---
name: gnet-framework
version: 1.5.0
priority: high
category: server
description: |
  MT3 gnet网络框架技能。涵盖RPC协议定义、Bean序列化、跨服通信和协议处理器开发。
  触发词: gnet, RPC, 协议, Protocol, Bean, 网络, 通信, 序列化, Provider, genrpc, Procedure, Handler, SessionManager, xbean
dependencies:
  - java-development
  - protocol-design
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 12000
---

# gnet 网络框架技能 (MT3 服务器端)

**版本**: v1.5.0
**最后更新**: 2026-04-11

---

## 🏗️ gnet 框架架构

### 架构概览

```
┌─────────────────────────────────────────────────────┐
│                     gnet 框架                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────┐    ┌─────────────┐                │
│  │  Protocol   │    │   Handler   │                │
│  │  Definition │ →  │   Dispatch  │                │
│  └─────────────┘    └──────┬──────┘                │
│                            │                        │
│  ┌─────────────┐    ┌──────▼──────┐                │
│  │ Serializer  │ ←  │   Session   │                │
│  │  (marshal)  │    │  Management │                │
│  └─────────────┘    └──────┬──────┘                │
│                            │                        │
│  ┌─────────────────────────▼───────────────────┐   │
│  │              Network I/O (NIO)               │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 核心组件

| 组件 | 职责 | 说明 |
|------|------|------|
| **Protocol** | 协议定义 | XML 定义消息结构 |
| **Handler** | 消息处理 | 实现业务逻辑 |
| **Session** | 连接管理 | 维护客户端连接 |
| **Serializer** | 序列化 | 消息编解码 |
| **Dispatcher** | 消息分发 | 路由到处理器 |

---

## 📝 协议定义

### gnet.xml 基本语法

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gnet>
    <!-- 命名空间 -->
    <namespace>com.mt3.gameserver.protocol</namespace>

    <!-- 协议定义 -->
    <protocol id="1001" name="LoginRequest">
        <field name="username" type="string"/>
        <field name="password" type="string"/>
        <field name="deviceId" type="string"/>
        <field name="version" type="int"/>
    </protocol>

    <protocol id="1002" name="LoginResponse">
        <field name="success" type="boolean"/>
        <field name="playerId" type="int"/>
        <field name="errorCode" type="int"/>
        <field name="errorMsg" type="string"/>
        <field name="serverTime" type="long"/>
    </protocol>

</gnet>
```

### 支持的数据类型

| 类型 | Java 类型 | 字节数 | 说明 |
|------|-----------|--------|------|
| `boolean` | `boolean` | 1 | 布尔值 |
| `byte` | `byte` | 1 | 字节 |
| `short` | `short` | 2 | 短整数 |
| `int` | `int` | 4 | 整数 |
| `long` | `long` | 8 | 长整数 |
| `float` | `float` | 4 | 单精度 |
| `double` | `double` | 8 | 双精度 |
| `string` | `String` | 变长 | 字符串 |
| `bytes` | `byte[]` | 变长 | 字节数组 |

### 复杂类型

```xml
<!-- 列表类型 -->
<protocol id="2001" name="ItemListResponse">
    <field name="items" type="list&lt;ItemInfo&gt;"/>
</protocol>

<!-- 嵌套类型 -->
<bean name="ItemInfo">
    <field name="itemId" type="int"/>
    <field name="templateId" type="int"/>
    <field name="count" type="int"/>
</bean>

<!-- Map 类型 -->
<protocol id="2002" name="PlayerDataResponse">
    <field name="attributes" type="map&lt;string,int&gt;"/>
</protocol>

<!-- 枚举类型 -->
<enum name="ItemQuality">
    <value name="NORMAL" value="0"/>
    <value name="RARE" value="1"/>
    <value name="EPIC" value="2"/>
    <value name="LEGENDARY" value="3"/>
</enum>
```

### 协议设计原则

```yaml
1. 协议 ID 分配（实际项目范围）：
   - 100-199: 基础协议（心跳、握手、错误）
   - 500-599: 认证相关（矩阵密码、充值）
   - 2000-2999: 服务器管理
   - 3000-3999: 账号管理
   - 4000-4999: 邮件系统
   - 4200-4299: 邮件操作
   - 700-799: 排行榜
   - 8000-8999: 跨服协议

2. 命名规范：
   - 请求：XxxRequest
   - 响应：XxxResponse
   - 通知：XxxNotify
   - 广播：XxxBroadcast

3. 版本兼容：
   - 新增字段放最后
   - 不删除已有字段
   - 不修改字段类型
```

---

## 📊 MT3 实际 RPC 协议列表

> **数据来源**: 代码分析报告 [`03-服务器端Java代码分析.md`](../../../docs/09-历史归档/文档审计/2026-03-06-服务器端Java代码分析.md)

### 主要 RPC 协议（31+ 个）

| RPC 名称 | 类型 | 说明 |
|---------|------|------|
| MatrixPasswd | 550 | 矩阵密码认证 |
| MatrixPasswd2 | 8066 | 矩阵密码认证2 |
| UserLogin | 15 | 用户登录 |
| UserLogin2 | 8067 | 用户登录2 |
| UserLogout | 33 | 用户登出 |
| QueryUserid2 | 8002 | 查询用户ID |
| GetAddCashSN | 514 | 获取充值序列号 |
| GetAddCashSN2 | 8009 | 获取充值序列号2 |
| PassportGetRoleList | 8013 | 获取角色列表 |
| InstantAddCash | 8015 | 即时充值 |
| SetServerAttr | 204 | 设置服务器属性 |
| SetMaxOnlineNum | 205 | 设置最大在线数 |
| GetMaxOnlineNum | 206 | 获取最大在线数 |
| AuAnyLogin | 8903 | AU任意登录 |
| DBGetMailList | 4251 | 获取邮件列表 |
| DBGetMail | 4252 | 获取邮件 |
| DBGetMailAttach | 4253 | 获取邮件附件 |
| DBSetMailAttr | 4254 | 设置邮件属性 |
| DBSendMail | 4255 | 发送邮件 |
| DBDeleteMail | 4256 | 删除邮件 |
| DBGetMailAll | 4257 | 获取所有邮件 |
| DBSendGiving | 4258 | 发送赠礼 |
| DBReloadRole | 4265 | 重载角色 |
| DBPutTopTable | 703 | 存储排行榜 |
| DBGetTopTable | 704 | 获取排行榜 |
| GetWeeklyTop | 706 | 获取周排行榜 |
| AccountAddRole | 3010 | 账号添加角色 |
| AccountDelRole | 3011 | 账号删除角色 |

### 主要协议类型

| 协议名称 | 类型 | 说明 |
|---------|------|------|
| KeepAlive | 100 | 心跳保活 |
| Challenge | 101 | 挑战（握手） |
| ErrorInfo | 102 | 错误信息 |
| Response | 103 | 登录响应 |
| KeyExchange | 106 | 密钥交换 |
| OnlineAnnounce | 110 | 上线通知 |
| MatrixChallenge | 551 | 矩阵挑战 |
| MatrixResponse | 552 | 矩阵响应 |
| PortForward | 109 | 端口转发 |
| VerifyMaster2 | 604 | 验证师父 |
| SysSendMail2 | 4216 | 系统发邮件 |
| AddCash | 515 | 充值 |
| AU2Game | 8038 | AU到游戏 |

### 协议定义文件清单

| 文件 | 路径 | 说明 |
|------|------|------|
| gnet.xml | server/server/common/ | 通用协议定义 |
| gnet.cross.xml | server/server/common/ | 跨服协议定义 |
| gnet.proxy.xml | server/server/common/ | 代理服务协议 |
| gnet.gate.xml | server/server/common/ | 网关服务协议 |
| gnet.sdk.xml | server/server/common/ | SDK 服务协议 |
| gnet.openau.xml | server/server/common/ | 开放认证协议 |
| protocol.main.xml | server/server/game_server/ | 主协议定义 |
| pb.xml | server/server/game_server/protocols/ | 游戏协议定义 |
| msp.xml | server/server/game_server/localprotocols/ | 本地协议定义 |

---

## 🔧 rpcgen 代码生成

### 运行 rpcgen

```bash
# 进入项目目录
cd server/server/game_server

# 运行生成
ant rpcgen

# 或者手动运行
java -cp lib/*:bin gnet.RpcGen src/gnet.xml src/
```

### 生成的代码结构

```java
// 生成的 LoginRequest.java
package com.mt3.gameserver.protocol;

public class LoginRequest implements Protocol {
    // 协议 ID
    public static final int PROTOCOL_ID = 1001;

    // 字段
    private String username;
    private String password;
    private String deviceId;
    private int version;

    // 默认构造函数
    public LoginRequest() {}

    // 全参构造函数
    public LoginRequest(String username, String password,
                        String deviceId, int version) {
        this.username = username;
        this.password = password;
        this.deviceId = deviceId;
        this.version = version;
    }

    // Getter/Setter
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    // ...

    // 序列化
    @Override
    public void marshal(OutputStream out) throws IOException {
        DataOutputStream dos = new DataOutputStream(out);
        dos.writeUTF(username);
        dos.writeUTF(password);
        dos.writeUTF(deviceId);
        dos.writeInt(version);
    }

    // 反序列化
    @Override
    public void unmarshal(InputStream in) throws IOException {
        DataInputStream dis = new DataInputStream(in);
        username = dis.readUTF();
        password = dis.readUTF();
        deviceId = dis.readUTF();
        version = dis.readInt();
    }

    // 获取协议 ID
    @Override
    public int getProtocolId() {
        return PROTOCOL_ID;
    }
}
```

---

## 🎯 协议处理器

### 实现处理器

```java
// 登录处理器
public class LoginHandler implements ProtocolHandler<LoginRequest> {

    @Override
    public void handle(Session session, LoginRequest request) {
        // 1. 验证参数
        if (StringUtils.isEmpty(request.getUsername())) {
            sendError(session, ErrorCode.INVALID_PARAM, "用户名不能为空");
            return;
        }

        // 2. 验证账号密码
        AccountInfo account = accountService.verify(
            request.getUsername(),
            request.getPassword()
        );

        if (account == null) {
            sendError(session, ErrorCode.WRONG_PASSWORD, "用户名或密码错误");
            return;
        }

        // 3. 检查版本
        if (request.getVersion() < MIN_VERSION) {
            sendError(session, ErrorCode.VERSION_TOO_OLD, "请更新客户端");
            return;
        }

        // 4. 加载玩家数据
        Player player = playerService.loadOrCreate(account.getId());

        // 5. 绑定会话
        session.setAttribute("playerId", player.getId());
        sessionManager.bindPlayer(player.getId(), session);

        // 6. 发送响应
        LoginResponse response = new LoginResponse();
        response.setSuccess(true);
        response.setPlayerId(player.getId());
        response.setServerTime(System.currentTimeMillis());

        session.send(response);

        // 7. 发送初始化数据
        sendInitData(session, player);
    }

    private void sendError(Session session, int code, String msg) {
        LoginResponse response = new LoginResponse();
        response.setSuccess(false);
        response.setErrorCode(code);
        response.setErrorMsg(msg);
        session.send(response);
    }
}
```

### 注册处理器

```java
// 协议管理器
public class ProtocolManager {
    private Map<Integer, ProtocolHandler> handlers = new HashMap<>();

    // 注册处理器
    public void register(int protocolId, ProtocolHandler handler) {
        handlers.put(protocolId, handler);
    }

    // 分发消息
    public void dispatch(Session session, Protocol protocol) {
        int id = protocol.getProtocolId();
        ProtocolHandler handler = handlers.get(id);

        if (handler == null) {
            log.error("No handler for protocol: {}", id);
            return;
        }

        try {
            handler.handle(session, protocol);
        } catch (Exception e) {
            log.error("Handle error: protocol={}, error={}",
                      id, e.getMessage(), e);
        }
    }
}

// 初始化
public void init() {
    protocolManager.register(LoginRequest.PROTOCOL_ID, new LoginHandler());
    protocolManager.register(ChatRequest.PROTOCOL_ID, new ChatHandler());
    protocolManager.register(MoveRequest.PROTOCOL_ID, new MoveHandler());
    // ...
}
```

### 异步处理

```java
// 对于耗时操作，使用异步处理
public class SaveDataHandler implements ProtocolHandler<SaveDataRequest> {

    private ExecutorService executor = Executors.newFixedThreadPool(10);

    @Override
    public void handle(Session session, SaveDataRequest request) {
        // 立即返回确认
        session.send(new SaveDataAck());

        // 异步处理
        executor.submit(() -> {
            try {
                // 耗时的数据库操作
                database.save(request.getData());

                // 发送结果
                session.send(new SaveDataResponse(true));
            } catch (Exception e) {
                session.send(new SaveDataResponse(false, e.getMessage()));
            }
        });
    }
}
```

---

## 🔌 Session 管理

### Session 接口

```java
public interface Session {
    // 获取 Session ID
    String getId();

    // 发送消息
    void send(Protocol protocol);

    // 关闭连接
    void close();

    // 属性管理
    void setAttribute(String key, Object value);
    Object getAttribute(String key);
    void removeAttribute(String key);

    // 获取远程地址
    InetSocketAddress getRemoteAddress();

    // 是否已连接
    boolean isConnected();
}
```

### Session 管理器

```java
public class SessionManager {
    // 所有会话
    private ConcurrentHashMap<String, Session> sessions = new ConcurrentHashMap<>();

    // 玩家 ID 到会话的映射
    private ConcurrentHashMap<Integer, Session> playerSessions = new ConcurrentHashMap<>();

    // 添加会话
    public void addSession(Session session) {
        sessions.put(session.getId(), session);
    }

    // 移除会话
    public void removeSession(String sessionId) {
        Session session = sessions.remove(sessionId);
        if (session != null) {
            Integer playerId = (Integer) session.getAttribute("playerId");
            if (playerId != null) {
                playerSessions.remove(playerId);
            }
        }
    }

    // 绑定玩家
    public void bindPlayer(int playerId, Session session) {
        // 踢掉旧会话
        Session old = playerSessions.put(playerId, session);
        if (old != null && old != session) {
            old.send(new KickNotify("账号在其他地方登录"));
            old.close();
        }
    }

    // 获取玩家会话
    public Session getPlayerSession(int playerId) {
        return playerSessions.get(playerId);
    }

    // 发送给玩家
    public void sendToPlayer(int playerId, Protocol protocol) {
        Session session = playerSessions.get(playerId);
        if (session != null && session.isConnected()) {
            session.send(protocol);
        }
    }

    // 广播给所有在线玩家
    public void broadcast(Protocol protocol) {
        for (Session session : playerSessions.values()) {
            if (session.isConnected()) {
                session.send(protocol);
            }
        }
    }
}
```

---

## 🔄 RPC 调用

### RPC 原理

```
┌─────────────┐     请求      ┌─────────────┐
│   调用方     │ ────────────→ │   服务方     │
│ (Caller)    │              │  (Callee)   │
│             │ ←──────────── │             │
└─────────────┘     响应      └─────────────┘
```

### 同步 RPC

```java
// 定义 RPC 接口
public interface IZoneService {
    PlayerInfo getPlayerInfo(int playerId);
    boolean enterScene(int playerId, int sceneId);
}

// 客户端代理
public class ZoneServiceProxy implements IZoneService {
    private RpcClient client;
    private String serverAddress;

    @Override
    public PlayerInfo getPlayerInfo(int playerId) {
        GetPlayerInfoRequest request = new GetPlayerInfoRequest(playerId);
        GetPlayerInfoResponse response = client.call(serverAddress, request);
        return response.getPlayerInfo();
    }

    @Override
    public boolean enterScene(int playerId, int sceneId) {
        EnterSceneRequest request = new EnterSceneRequest(playerId, sceneId);
        EnterSceneResponse response = client.call(serverAddress, request);
        return response.isSuccess();
    }
}

// 服务端实现
public class ZoneServiceImpl implements IZoneService {
    @Override
    public PlayerInfo getPlayerInfo(int playerId) {
        return playerManager.getPlayerInfo(playerId);
    }

    @Override
    public boolean enterScene(int playerId, int sceneId) {
        return sceneManager.enter(playerId, sceneId);
    }
}
```

### 异步 RPC

```java
// 异步调用
public void asyncGetPlayerInfo(int playerId, RpcCallback<PlayerInfo> callback) {
    GetPlayerInfoRequest request = new GetPlayerInfoRequest(playerId);

    client.asyncCall(serverAddress, request, new RpcCallback<GetPlayerInfoResponse>() {
        @Override
        public void onSuccess(GetPlayerInfoResponse response) {
            callback.onSuccess(response.getPlayerInfo());
        }

        @Override
        public void onError(Exception e) {
            callback.onError(e);
        }
    });
}

// 使用
asyncGetPlayerInfo(1001, new RpcCallback<PlayerInfo>() {
    @Override
    public void onSuccess(PlayerInfo info) {
        // 处理结果
    }

    @Override
    public void onError(Exception e) {
        // 处理错误
    }
});
```

---

## ⚡ 网络优化

### 协议压缩

```java
public class CompressedProtocolCodec {
    private static final int COMPRESS_THRESHOLD = 100;

    public byte[] encode(Protocol protocol) throws IOException {
        byte[] data = serialize(protocol);

        if (data.length > COMPRESS_THRESHOLD) {
            byte[] compressed = compress(data);
            if (compressed.length < data.length * 0.8) {
                // 压缩有效
                return wrapCompressed(compressed);
            }
        }

        return wrapUncompressed(data);
    }

    private byte[] compress(byte[] data) throws IOException {
        Deflater deflater = new Deflater();
        deflater.setInput(data);
        deflater.finish();

        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        while (!deflater.finished()) {
            int count = deflater.deflate(buffer);
            bos.write(buffer, 0, count);
        }

        return bos.toByteArray();
    }
}
```

### 批量发送

```java
public class MessageBatcher {
    private List<Protocol> batch = new ArrayList<>();
    private long lastFlush = System.currentTimeMillis();
    private static final int MAX_BATCH_SIZE = 100;
    private static final long FLUSH_INTERVAL = 50;  // ms

    public synchronized void add(Protocol protocol) {
        batch.add(protocol);

        if (shouldFlush()) {
            flush();
        }
    }

    private boolean shouldFlush() {
        return batch.size() >= MAX_BATCH_SIZE ||
               System.currentTimeMillis() - lastFlush > FLUSH_INTERVAL;
    }

    public synchronized void flush() {
        if (!batch.isEmpty()) {
            BatchProtocol batchProtocol = new BatchProtocol(batch);
            session.send(batchProtocol);
            batch.clear();
            lastFlush = System.currentTimeMillis();
        }
    }
}
```

### 心跳机制

```java
public class HeartbeatManager {
    private static final long HEARTBEAT_INTERVAL = 30000;  // 30s
    private static final long TIMEOUT = 90000;  // 90s

    private ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    public void start(Session session) {
        // 定时发送心跳
        scheduler.scheduleAtFixedRate(() -> {
            session.send(new HeartbeatRequest());
        }, HEARTBEAT_INTERVAL, HEARTBEAT_INTERVAL, TimeUnit.MILLISECONDS);

        // 检查超时
        scheduler.scheduleAtFixedRate(() -> {
            long lastActive = session.getLastActiveTime();
            if (System.currentTimeMillis() - lastActive > TIMEOUT) {
                session.close();
            }
        }, TIMEOUT, TIMEOUT / 2, TimeUnit.MILLISECONDS);
    }
}
```

---

## ❌ 常见问题

### 1. 协议 ID 冲突

```
错误: Duplicate protocol id: 1001
```

**解决**: 检查 gnet.xml，确保协议 ID 唯一

### 2. 序列化错误

```
错误: EOFException during unmarshal
```

**原因**: 协议字段顺序或类型不匹配

**解决**: 确保客户端和服务器使用相同版本的协议

### 3. 连接超时

```
错误: Connection timeout
```

**解决**:
- 检查网络连接
- 增加超时时间
- 检查心跳配置

---

## 🎯 实践项目

### 初级项目：实现简单聊天
```
任务：实现玩家间聊天功能
要求：
- 定义聊天协议
- 实现处理器
- 支持私聊和广播
```

### 中级项目：实现 RPC 调用
```
任务：实现跨服务器 RPC
要求：
- 定义 RPC 接口
- 实现客户端代理
- 实现服务端处理
- 处理超时和异常
```

### 高级项目：网络性能优化
```
任务：优化网络延迟和吞吐量
要求：
- 协议压缩
- 批量发送
- 连接池
- 性能测试报告
```

---

## ✅ 技能检查清单

### 初级检查点
- [ ] 理解 gnet 架构
- [ ] 能够定义协议
- [ ] 能够实现处理器
- [ ] 能够发送和接收消息
- [ ] 理解 Session 管理

### 中级检查点
- [ ] 能够设计复杂协议
- [ ] 能够实现 RPC 调用
- [ ] 理解序列化机制
- [ ] 能够处理网络异常
- [ ] 能够使用批处理

### 高级检查点
- [ ] 能够优化网络性能
- [ ] 能够设计跨服通信
- [ ] 能够实现协议压缩
- [ ] 能够扩展框架
- [ ] 能够指导他人

---

## 变更日志

### v1.0.0 (2025-11-24)
- 初始版本
- 包含协议定义、处理器、Session 管理
- 添加 RPC 调用和网络优化
- 添加实践项目

---

**相关技能**:
- [Java 开发](java-development.md)
- [Ant 构建](ant-build.md)
- [分布式架构](distributed-arch.md)

**下次更新**: 2026-02-24

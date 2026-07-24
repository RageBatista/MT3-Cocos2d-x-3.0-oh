# Gate Server (网关服务器) 技术文档

## 📋 文档信息

- **模块名称**: Gate Server (glinkd)
- **版本**: v5019
- **最后更新**: 2025-11-20
- **维护团队**: MT3服务器开发组
- **优先级**: ⭐⭐⭐⭐⭐ (核心服务器 - 所有客户端连接的入口)

---

## 📖 目录

1. [模块概述](#模块概述)
2. [架构设计](#架构设计)
3. [目录结构](#目录结构)
4. [核心组件](#核心组件)
5. [配置详解](#配置详解)
6. [协议系统](#协议系统)
7. [连接管理](#连接管理)
8. [安全机制](#安全机制)
9. [性能优化](#性能优化)
10. [运维指南](#运维指南)
11. [常见问题](#常见问题)
12. [附录](#附录)

---

## 🎯 模块概述

### 功能定位

Gate Server (glinkd) 是 MT3 服务器架构中的**网络接入网关**，负责：

1. **客户端连接管理** - 接受和维护客户端连接 (LinkServer)
2. **协议转发** - 在客户端和游戏服务器之间转发协议
3. **会话状态管理** - 管理用户登录状态和会话超时
4. **安全防护** - 提供加密、心跳检测、IP限制等安全机制
5. **负载通告** - 向Delivery服务器通告当前负载状态

### 技术栈

| 技术 | 用途 | 版本/说明 |
|------|------|----------|
| **C++** | 核心实现语言 | C++98/03 |
| **PollIO** | 异步I/O框架 | 自研高性能IO库 |
| **TCP** | 传输协议 | 可靠连接 |
| **log4cpp** | 日志框架 | 分级日志 |
| **Octets** | 数据序列化 | 自研二进制协议 |
| **ARCFOUR/BLOWFISH/DES** | 加密算法 | 可选加密 |

### 版本信息

- **当前版本**: 5019
- **协议版本**: 与 Proxy Server 协商
- **兼容性**: 客户端必须使用匹配的协议版本

---

## 🏛️ 架构设计

### 三层架构

```
┌─────────────────────────────────────────────────────┐
│                   客户端层                           │
│     (PC Client / Mobile Client / Web Client)        │
└───────────────┬─────────────────────────────────────┘
                │ TCP (Port 10003)
                ▼
┌─────────────────────────────────────────────────────┐
│                  Gate Server 网关层                  │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ LinkServer  │  │ ProviderServer│  │ Delivery   │ │
│  │ (Port 10003)│  │ (Port 10011)  │  │ Client     │ │
│  │ 客户端连接   │  │ Proxy连接     │  │ (Port 10020│ │
│  └─────────────┘  └──────────────┘  └────────────┘ │
└───────────────┬─────────────────────────────────────┘
                │ TCP (Port 10011)
                ▼
┌─────────────────────────────────────────────────────┐
│                  Proxy Server 代理层                 │
│         (认证、角色管理、数据转发)                    │
└───────────────┬─────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────┐
│              Game Server / DB Server 业务层          │
└─────────────────────────────────────────────────────┘
```

### 数据流向

```
客户端登录流程：

1. [Client] ──Challenge──►[Gate LinkServer]
2. [Gate]   ──转发────────►[Proxy ProviderServer]
3. [Proxy]  ──UserLoginReq►[Auth Server]
4. [Auth]   ──UserLoginRep►[Proxy]
5. [Proxy]  ──Response─────►[Gate]
6. [Gate]   ──Response────►[Client] (登录成功)

游戏协议转发：

1. [Client] ──游戏协议─────►[Gate LinkServer]
2. [Gate]   ──Dispatch────►[Proxy via ProviderServer]
3. [Proxy]  ──处理/转发───►[Game Server]
4. [Game]   ──结果协议────►[Proxy]
5. [Proxy]  ──Send────────►[Gate]
6. [Gate]   ──游戏协议────►[Client]
```

### 核心组件职责

| 组件 | 职责 | 监听端口 | 连接类型 |
|------|------|---------|---------|
| **LinkServer** | 接受客户端连接，管理会话 | 10003 | TCP Server |
| **ProviderServer** | 连接Proxy服务器 | 10011 | TCP Server |
| **DeliveryClient** | 通告服务器状态给Delivery | 10020 | TCP Client |
| **LogClient** | 发送日志到LogService | 11100/11101 | UDP/TCP Client |

---

## 📂 目录结构

```
server/server/gate_server/
├── docs/                           # 技术文档目录
│   └── README.md                   # 本文档
│
├── gate/                           # Gate Server 主目录
│   ├── 核心源文件
│   │   ├── gate.cpp                # 主程序入口
│   │   ├── gate.conf               # 核心配置文件 ⭐
│   │   ├── gate.log4cpp.properties # 日志配置
│   │   ├── Makefile                # 编译脚本
│   │   └── glinkd                  # 可执行文件 (编译输出)
│   │
│   ├── 连接管理模块
│   │   ├── LinkServer.cpp/.hpp     # 客户端连接服务器
│   │   ├── LinkSession.hpp         # 客户端会话
│   │   ├── LinkBrokenCache.hpp     # 断线缓存
│   │   ├── ProviderServer.cpp/.hpp # Proxy连接服务器
│   │   ├── ProviderMap.hpp         # Provider映射表
│   │   └── DeliveryClient.cpp/.hpp # Delivery客户端
│   │
│   ├── 协议处理模块
│   │   ├── protocols.hpp           # 协议头文件汇总
│   │   ├── rpcgen.cpp/.hpp         # RPC代码生成器输出
│   │   ├── gnet/                   # 协议定义 (*.hpp)
│   │   │   ├── Challenge.hpp       # 挑战协议
│   │   │   ├── Response.hpp        # 响应协议
│   │   │   ├── KeyExchange.hpp     # 密钥交换
│   │   │   ├── KeepAlive.hpp       # 心跳协议
│   │   │   ├── UserLoginReq/Rep.hpp # 登录协议
│   │   │   ├── MatrixPasswd*.hpp   # 矩阵密码
│   │   │   ├── link/               # Link协议子目录
│   │   │   │   ├── Bind.hpp        # 绑定用户
│   │   │   │   ├── UnBind.hpp      # 解绑用户
│   │   │   │   ├── Send.hpp        # 发送数据
│   │   │   │   ├── Dispatch.hpp    # 分发数据
│   │   │   │   ├── Kick.hpp        # 踢出用户
│   │   │   │   └── LinkBroken.hpp  # 连接断开
│   │   │   └── ... (60+ 协议文件)
│   │   └── rpcgen/                 # 自动生成的代码
│   │       └── gnet/               # 协议实现 (*.inc)
│   │
│   ├── 安全与监控模块
│   │   ├── speedlimit.h            # 速率限制
│   │   ├── checktimer.cpp/.hpp     # 定时检查器
│   │   ├── stat.cpp/.hpp           # 统计模块
│   │   └── pf.cpp/.hpp/pfp.hpp     # 端口转发
│   │
│   ├── OpenAU 集成
│   │   └── openau/                 # OpenAU协议
│   │       ├── DataBetweenAuAnyAndClient.hpp
│   │       └── ServerIDResponse.hpp
│   │
│   └── 开发辅助文件
│       ├── glinkd.kdev4            # KDevelop 项目
│       ├── glinkd.cbp              # Code::Blocks 项目
│       ├── cscope.out              # 代码索引
│       └── logs/                   # 日志输出目录
│
├── 协议定义文件 (XML)
│   ├── gnet.xml                    # 核心协议
│   ├── gnet.gate.xml               # Gate专用协议
│   ├── gnet.proxy.xml              # Proxy协议
│   ├── gnet.cross.xml              # 跨服协议
│   ├── gnet.openau.xml             # OpenAU协议
│   └── gnet.sdk.xml                # SDK协议
│
└── 编译脚本
    └── gate_build.bat              # Windows编译脚本
```

---

## 🔧 核心组件

### 1. LinkServer - 客户端连接服务器

**文件**: `LinkServer.cpp/.hpp`

**职责**:
- 监听客户端连接 (TCP端口 10003)
- 维护客户端会话状态 (LinkSession)
- 处理客户端协议并转发给 Proxy
- 管理心跳检测 (KeepAlive)
- 处理加密/解密

**核心功能**:

```cpp
class LinkServer : public Protocol::Manager {
public:
    // 启动监听
    void Start(const char* config_file);

    // 接受新连接
    void OnAddSession(Session::ID sid);

    // 处理断开
    void OnDelSession(Session::ID sid);

    // 协议路由
    bool HandleProtocol(Session::ID sid, Protocol* p);

    // 会话状态管理
    LinkSession* GetSession(Session::ID sid);
    void SetSessionLogin(Session::ID sid, int userid);

    // 心跳检测
    void CheckKeepAlive();

    // 统计信息
    int GetOnlineCount();
    int GetLoadFactor();
};
```

**会话状态机**:

```
[初始状态] ──Challenge──► [挑战中]
                             │
              Response ◄─────┘
                 │
                 ▼
             [已认证] ──UserLogin──► [登录中]
                                        │
                         UserLoginRep ◄─┘
                            │
                            ▼
                        [已登录] ──游戏协议──► [游戏中]
                            │
                            │ KeepAlive定时器超时
                            ▼
                        [断开连接]
```

### 2. ProviderServer - Proxy连接服务器

**文件**: `ProviderServer.cpp/.hpp`

**职责**:
- 监听 Proxy 服务器连接 (TCP端口 10011)
- 维护 Proxy 服务器列表
- 转发客户端协议到 Proxy
- 接收 Proxy 的响应并转发给客户端

**核心功能**:

```cpp
class ProviderServer : public Protocol::Manager {
public:
    // 启动监听
    void Start(const char* config_file);

    // Proxy连接建立
    void OnProviderReady(Session::ID sid, int linkid);

    // Proxy断开处理
    void OnProviderLost(Session::ID sid);

    // 转发到Proxy
    void SendToProvider(Protocol* p);

    // 从Proxy接收
    bool HandleFromProvider(Session::ID sid, Protocol* p);

    // Provider映射
    Session::ID GetProviderSession(int linkid);
};
```

**协议转发流程**:

```
客户端协议 → LinkServer → Dispatch协议 → ProviderServer → Proxy

Proxy响应 → ProviderServer → Send协议 → LinkServer → 客户端
```

### 3. DeliveryClient - Delivery客户端

**文件**: `DeliveryClient.cpp/.hpp`

**职责**:
- 连接 Delivery 服务器 (TCP端口 10020)
- 定期通告当前在线人数和负载
- 接收服务器控制指令

**核心功能**:

```cpp
class DeliveryClient : public Protocol::Manager {
public:
    // 连接Delivery
    void Connect(const char* host, int port);

    // 通告状态
    void AnnounceStatus(int online_count, int load_factor);

    // 处理控制指令
    void OnServerControl(Protocol* p);

    // 重连机制
    void Reconnect();
};
```

---

## ⚙️ 配置详解

### gate.conf 完整配置

#### [LinkServer] - 客户端连接服务器

```ini
[LinkServer]
# 网络配置
type            = tcp               # 协议类型
port            = 10003             # 监听端口 ⭐
address         = 0.0.0.0           # 监听地址 (0.0.0.0 = 所有网卡)
listen_backlog  = 10                # 监听队列长度

# 缓冲区配置
so_sndbuf       = 16384             # Socket发送缓冲 (16KB)
so_rcvbuf       = 16384             # Socket接收缓冲 (16KB)
ibuffermax      = 65536             # 输入缓冲最大值 (64KB)
obuffermax      = 65536             # 输出缓冲最大值 (64KB)
accumulate      = 131072            # 累积缓冲 (128KB)

# 会话状态管理
session_state_check = 1             # 开启会话状态检查 (1=开启)
# state's timeout defined in gnet.link.xml

# 心跳检测
keepalive_open      = 1             # 开启心跳检测 (1=开启, 0=关闭)
keepalive_interval  = 30            # 心跳超时时间 (秒) ⭐
# 客户端必须在30秒内发送KeepAlive，否则连接断开 (LinkBroken reason=7)

# IP封禁
forbid_ip_interval  = 10            # IP封禁时间 (秒)
# 当errcode=2或errcode=3次数超限时，封禁IP 10秒

# 协议检查
checkunknownprotocol = 0            # 检查未知协议 (0=不检查)

# 端口控制
listen_port_open    = 1             # 自行开启监听端口 (1=自行开启, 0=由GS控制)

# 统计开关
stat_open           = 0             # 协议统计开关 (0=关闭, 1=开启)

# 日志级别
log_level           = 6             # 登录/登出日志级别
# 6=详细, 11=一般, 15=精简 (梦幻西游=15, 倚天=11)

# 用户数量控制
max_users           = 10000         # 最大在线用户数 ⭐
halflogin_users     = 3000          # 半登录用户数限制

# 其他选项
tcp_nodelay         = 0             # TCP_NODELAY选项 (0=关闭Nagle)
close_discard       = 1             # 关闭时丢弃数据
urgency_support     = 1             # 紧急数据支持
;so_broadcast      = 1             # 广播支持 (注释掉)

# 协议版本号
version             = 5019          # 当前版本 ⭐
```

#### [ProviderServer] - Proxy连接服务器

```ini
[ProviderServer]
# 网络配置
type            = tcp               # 协议类型
port            = 10011             # 监听端口 ⭐
address         = 0.0.0.0           # 监听地址
listen_backlog  = 10                # 监听队列长度

# Link ID (保留,不使用0)
linkid          = 1                 # Link标识符

# 缓冲区配置
so_sndbuf       = 16384             # Socket发送缓冲 (16KB)
so_rcvbuf       = 16384             # Socket接收缓冲 (16KB)
ibuffermax      = 1638400           # 输入缓冲最大值 (1.6MB) ⭐
obuffermax      = 1638400           # 输出缓冲最大值 (1.6MB) ⭐
accumulate      = 131072            # 累积缓冲 (128KB)
```

#### [DeliveryClient] - Delivery客户端

```ini
[DeliveryClient]
# 网络配置
type            = tcp               # 协议类型
port            = 10020             # Delivery服务器端口 ⭐
address         = 0.0.0.0           # Delivery服务器地址

# 缓冲区配置
so_sndbuf       = 16384             # Socket发送缓冲 (16KB)
so_rcvbuf       = 16384             # Socket接收缓冲 (16KB)
ibuffermax      = 1638400           # 输入缓冲最大值 (1.6MB)
obuffermax      = 1638400           # 输出缓冲最大值 (1.6MB)
accumulate      = 131072            # 累积缓冲 (128KB)

# 加密配置 (可选,注释掉表示不加密)
;isec            = 2                # 输入加密类型 (2=ARCFOUR)
;iseckey         = 123              # 输入加密密钥
;osec            = 2                # 输出加密类型
;oseckey         = 456              # 输出加密密钥
```

#### [SpeedLimit] - 速率限制

```ini
[SpeedLimit]
window          = 10                # 时间窗口 (秒)
high            = 3                 # 高水位 (次数)
# 在10秒内同一IP不能超过3次特定操作
```

#### [LogClientManager] - UDP日志客户端

```ini
[LogClientManager]
type            = udp               # 协议类型
port            = 11100             # LogService UDP端口
address         = 0.0.0.0           # LogService地址

# 缓冲区配置
so_sndbuf       = 65536             # Socket发送缓冲 (64KB)
so_rcvbuf       = 65536             # Socket接收缓冲 (64KB)
ibuffermax      = 65536             # 输入缓冲最大值 (64KB)
obuffermax      = 1048576           # 输出缓冲最大值 (1MB)
accumulate      = 1048576           # 累积缓冲 (1MB)
```

#### [LogClientTcpManager] - TCP日志客户端

```ini
[LogClientTcpManager]
type            = tcp               # 协议类型
port            = 11101             # LogService TCP端口
address         = 0.0.0.0           # LogService地址

# 缓冲区配置
so_sndbuf       = 65536             # Socket发送缓冲 (64KB)
so_rcvbuf       = 65536             # Socket接收缓冲 (64KB)
ibuffermax      = 65536             # 输入缓冲最大值 (64KB)
obuffermax      = 1048576           # 输出缓冲最大值 (1MB)
accumulate      = 1048576           # 累积缓冲 (1MB)
```

### 配置参数优化建议

#### 高并发场景 (>5000在线)

```ini
[LinkServer]
max_users           = 20000         # 提高用户上限
halflogin_users     = 6000          # 提高半登录限制
so_sndbuf           = 32768         # 增大发送缓冲 (32KB)
so_rcvbuf           = 32768         # 增大接收缓冲 (32KB)
ibuffermax          = 131072        # 增大输入缓冲 (128KB)
obuffermax          = 131072        # 增大输出缓冲 (128KB)
accumulate          = 262144        # 增大累积缓冲 (256KB)
listen_backlog      = 50            # 增大监听队列

[ProviderServer]
ibuffermax          = 3276800       # 增大到 3.2MB
obuffermax          = 3276800       # 增大到 3.2MB
```

#### 低延迟场景 (PVP竞技)

```ini
[LinkServer]
tcp_nodelay         = 1             # 启用TCP_NODELAY (禁用Nagle算法)
keepalive_interval  = 10            # 降低心跳间隔 (10秒)
so_sndbuf           = 8192          # 减小发送缓冲减少延迟
so_rcvbuf           = 8192          # 减小接收缓冲减少延迟
```

#### 安全加固场景

```ini
[LinkServer]
keepalive_open      = 1             # 强制开启心跳
keepalive_interval  = 15            # 严格心跳检测 (15秒)
forbid_ip_interval  = 300           # 增加IP封禁时间 (5分钟)
checkunknownprotocol = 1            # 开启未知协议检查
log_level           = 6             # 详细日志级别

[SpeedLimit]
window              = 60            # 增加时间窗口
high                = 5             # 降低速率限制
```

---

## 🔌 协议系统

### 核心协议列表

#### 认证协议

| 协议名 | 类型 | 方向 | 用途 |
|--------|------|------|------|
| **Challenge** | Req | Client→Gate | 客户端发起挑战 |
| **Response** | Rep | Gate→Client | 服务器响应挑战 |
| **KeyExchange** | Req | Client↔Gate | 密钥交换 |
| **MatrixChallenge** | Req | Gate→Client | 矩阵密码挑战 |
| **MatrixResponse** | Rep | Client→Gate | 矩阵密码响应 |
| **UserLoginReq** | Req | Client→Gate→Proxy | 用户登录请求 |
| **UserLoginRep** | Rep | Proxy→Gate→Client | 用户登录响应 |

#### 会话协议

| 协议名 | 类型 | 方向 | 用途 |
|--------|------|------|------|
| **KeepAlive** | Req | Client↔Gate | 心跳保活 |
| **KickoutUser** | Cmd | Proxy→Gate→Client | 踢出用户 |
| **OnlineAnnounce** | Cmd | Gate→Delivery | 在线人数通告 |
| **StatusAnnounce** | Cmd | Gate→Delivery | 状态通告 |

#### Link协议 (Gate↔Proxy)

| 协议名 | 类型 | 方向 | 用途 |
|--------|------|------|------|
| **Bind** | Cmd | Proxy→Gate | 绑定用户到会话 |
| **UnBind** | Cmd | Proxy→Gate | 解绑用户 |
| **Send** | Cmd | Proxy→Gate | 发送数据到客户端 |
| **Dispatch** | Cmd | Gate→Proxy | 分发客户端数据 |
| **Kick** | Cmd | Proxy→Gate | 踢出指定会话 |
| **LinkBroken** | Event | Gate→Proxy | 连接断开通知 |
| **AnnounceLinkId** | Cmd | Proxy→Gate | 通告LinkID |
| **SetLogin** | Cmd | Proxy→Gate | 设置登录状态 |
| **LinkServerControl** | Cmd | Proxy→Gate | Link服务器控制 |
| **Broadcast** | Cmd | Proxy→Gate | 广播消息 |

#### 业务协议

| 协议名 | 类型 | 方向 | 用途 |
|--------|------|------|------|
| **GetUserCouponReq/Rep** | Req/Rep | Client↔Gate↔Proxy | 获取用户优惠券 |
| **CouponExchangeReq/Rep** | Req/Rep | Client↔Gate↔Proxy | 兑换优惠券 |
| **InstantAddCashReq/Rep** | Req/Rep | Client↔Gate↔Proxy | 即时充值 |
| **SSOGetTicketReq/Rep** | Req/Rep | Client↔Gate↔Proxy | SSO票据获取 |
| **ForceLoginReq/Rep** | Req/Rep | Client↔Gate↔Proxy | 强制登录 |

### 协议处理流程

#### 登录流程详解

```
1. 客户端发起挑战
   Client ──Challenge(nonce_c)──► Gate

2. 服务器响应挑战
   Gate ──Response(nonce_s, oskey)──► Client

3. 客户端计算密码哈希
   passwd_hash = MD5(passwd + nonce_c + nonce_s)

4. 客户端发送登录请求
   Client ──UserLoginReq(account, passwd_hash, kickuser)──► Gate

5. Gate转发到Proxy
   Gate ──Dispatch(UserLoginReq)──► Proxy

6. Proxy验证登录
   Proxy ──查询Auth Server/数据库──► 验证成功/失败

7. Proxy返回结果
   Proxy ──Send(UserLoginRep(result, rolelist))──► Gate

8. Gate转发给客户端
   Gate ──UserLoginRep──► Client

9. 登录成功,Proxy绑定会话
   Proxy ──Bind(sid, userid)──► Gate

10. Gate设置会话状态
    Gate内部: LinkSession.SetLogin(userid)
```

#### 心跳检测机制

```cpp
// 客户端定时发送KeepAlive
Timer: 每 keepalive_interval/2 秒
Client ──KeepAlive──► Gate

// Gate定时检查
Timer: 每 keepalive_interval 秒
Gate检查:
  if (last_keepalive_time + keepalive_interval < now()) {
      CloseSession(sid, REASON_KEEPALIVE_TIMEOUT); // reason=7
      Gate ──LinkBroken(sid, reason=7)──► Proxy
  }
```

#### 协议转发机制

```cpp
// Gate转发到Proxy
void LinkServer::OnClientProtocol(Session::ID sid, Protocol* p) {
    // 包装成Dispatch协议
    Dispatch dispatch;
    dispatch.sid = sid;
    dispatch.protocol = p->Clone();

    // 发送到ProviderServer
    ProviderServer::GetInstance()->SendProtocol(&dispatch);
}

// Proxy返回给Client
void ProviderServer::OnSendProtocol(Protocol* p) {
    Send* send = dynamic_cast<Send*>(p);
    if (send) {
        Session::ID sid = send->sid;
        Protocol* client_protocol = send->protocol;

        // 发送到LinkServer
        LinkServer::GetInstance()->SendToClient(sid, client_protocol);
    }
}
```

---

## 🔗 连接管理

### LinkSession - 客户端会话

**会话状态**:

```cpp
enum SessionState {
    SS_INIT         = 0,    // 初始状态
    SS_CHALLENGED   = 1,    // 已发送Challenge
    SS_AUTHENTICATED= 2,    // 已通过认证
    SS_LOGGED_IN    = 3,    // 已登录
    SS_PLAYING      = 4,    // 游戏中
    SS_CLOSING      = 5     // 关闭中
};
```

**会话数据**:

```cpp
class LinkSession {
    Session::ID sid;                // 会话ID
    int userid;                     // 用户ID (登录后)
    SessionState state;             // 会话状态
    time_t create_time;             // 创建时间
    time_t last_keepalive_time;     // 最后心跳时间
    std::string ip_address;         // 客户端IP
    int login_attempts;             // 登录尝试次数
    Security* isec;                 // 输入加密器
    Security* osec;                 // 输出加密器
    Octets nonce;                   // 随机数
};
```

### 连接限制策略

#### 1. 最大连接数限制

```cpp
// gate.conf
max_users = 10000
halflogin_users = 3000

// 检查逻辑
if (online_count >= max_users) {
    // 拒绝新连接
    CloseSession(sid, REASON_SERVER_FULL);
}

if (halflogin_count >= halflogin_users && !is_logged_in) {
    // 拒绝未登录连接
    CloseSession(sid, REASON_HALFLOGIN_FULL);
}
```

#### 2. IP连接限制

```cpp
// 同一IP最大连接数
#define MAX_CONNECTIONS_PER_IP  10

std::map<std::string, int> ip_connection_count;

if (ip_connection_count[ip] >= MAX_CONNECTIONS_PER_IP) {
    CloseSession(sid, REASON_IP_LIMIT);
}
```

#### 3. IP封禁机制

```cpp
// gate.conf
forbid_ip_interval = 10

// 错误码2和3触发IP封禁
if (error_code == 2 || error_code == 3) {
    if (++ip_error_count[ip] >= HIGH_THRESHOLD) {
        ForbidIP(ip, forbid_ip_interval);
    }
}
```

### 断线重连机制

```cpp
// LinkBrokenCache - 断线缓存
class LinkBrokenCache {
    struct CacheEntry {
        int userid;
        time_t broken_time;
        std::queue<Protocol*> cached_protocols;
    };

    std::map<Session::ID, CacheEntry> cache;

    // 缓存断线会话
    void CacheSession(Session::ID sid, int userid);

    // 恢复会话
    bool RestoreSession(Session::ID new_sid, int userid);

    // 清理过期缓存
    void CleanExpired(int timeout = 180); // 3分钟
};
```

---

## 🛡️ 安全机制

### 1. 加密机制

#### Challenge-Response 认证

```cpp
// 1. 服务器生成随机数
Octets nonce_s = GenerateNonce(16); // 16字节随机数

// 2. 客户端计算密码哈希
Octets passwd_hash = MD5(passwd + nonce_c + nonce_s);

// 3. 服务器验证
Octets expected = MD5(stored_passwd + nonce_c + nonce_s);
if (passwd_hash != expected) {
    return LOGIN_FAILED;
}
```

#### 矩阵密码 (MatrixPasswd)

```cpp
// 矩阵密码卡: 8x8矩阵,每个格子一个数字
// 服务器随机选择3个坐标
MatrixChallenge challenge;
challenge.positions = {(2,3), (5,7), (1,4)};

// 客户端查询矩阵卡并响应
MatrixResponse response;
response.values = {card[2][3], card[5][7], card[1][4]};

// 服务器验证
if (response.values == expected_values) {
    return AUTH_SUCCESS;
}
```

#### 会话加密

```cpp
// 可选: ARCFOUR/BLOWFISH/DES
Security* isec = Security::Create(ARCFOUR);
isec->SetParameter(Octets(iseckey));

// 加密发送
Octets encrypted = osec->Update(plaintext);
SendRaw(encrypted);

// 解密接收
Octets plaintext = isec->Update(encrypted);
```

### 2. 心跳检测

```cpp
// 配置
keepalive_open = 1
keepalive_interval = 30

// 定时器
class KeepAliveTimer : public PollIO::Timer {
    void Run() {
        LinkServer::GetInstance()->CheckKeepAlive();
    }
};

// 检查逻辑
void LinkServer::CheckKeepAlive() {
    time_t now = time(NULL);
    for (auto& session : sessions) {
        if (now - session.last_keepalive_time > keepalive_interval) {
            // 超时,断开连接
            CloseSession(session.sid, REASON_KEEPALIVE_TIMEOUT);

            // 通知Proxy
            LinkBroken broken;
            broken.sid = session.sid;
            broken.userid = session.userid;
            broken.reason = 7; // KeepAlive超时
            ProviderServer::SendProtocol(&broken);
        }
    }
}
```

### 3. 速率限制

```cpp
// SpeedLimit配置
window = 10  // 时间窗口10秒
high = 3     // 高水位3次

// 实现
class SpeedLimit {
    struct Record {
        std::queue<time_t> timestamps;
    };

    std::map<std::string, Record> records;

    bool Check(const std::string& key) {
        time_t now = time(NULL);
        Record& r = records[key];

        // 清理过期记录
        while (!r.timestamps.empty() &&
               r.timestamps.front() + window < now) {
            r.timestamps.pop();
        }

        // 检查是否超限
        if (r.timestamps.size() >= high) {
            return false; // 超过限制
        }

        // 记录新请求
        r.timestamps.push(now);
        return true;
    }
};

// 使用示例
if (!speed_limit.Check(ip_address)) {
    CloseSession(sid, REASON_SPEED_LIMIT);
}
```

### 4. 协议验证

```cpp
// 检查未知协议
if (checkunknownprotocol) {
    if (!IsKnownProtocol(protocol->GetType())) {
        LOG_WARN("Unknown protocol type: %d from sid=%d",
                 protocol->GetType(), sid);
        CloseSession(sid, REASON_INVALID_PROTOCOL);
        return false;
    }
}

// 检查协议大小
if (protocol->Size() > MAX_PROTOCOL_SIZE) {
    LOG_ERROR("Protocol too large: size=%d from sid=%d",
              protocol->Size(), sid);
    CloseSession(sid, REASON_PROTOCOL_TOO_LARGE);
    return false;
}

// 检查协议状态
if (protocol->NeedLogin() && !session->IsLoggedIn()) {
    LOG_WARN("Protocol requires login: type=%d from sid=%d",
             protocol->GetType(), sid);
    CloseSession(sid, REASON_NOT_LOGGED_IN);
    return false;
}
```

---

## ⚡ 性能优化

### 1. 网络优化

#### 缓冲区调优

```ini
# 高吞吐场景
[LinkServer]
so_sndbuf       = 65536             # 64KB发送缓冲
so_rcvbuf       = 65536             # 64KB接收缓冲
obuffermax      = 262144            # 256KB输出缓冲
accumulate      = 524288            # 512KB累积缓冲

# 低延迟场景
[LinkServer]
tcp_nodelay     = 1                 # 禁用Nagle算法
so_sndbuf       = 4096              # 4KB小缓冲
so_rcvbuf       = 4096              # 4KB小缓冲
```

#### TCP参数优化

```bash
# 系统级TCP优化 (Linux)
# /etc/sysctl.conf

# 增大TCP缓冲区
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# 增大连接队列
net.core.somaxconn = 1024
net.ipv4.tcp_max_syn_backlog = 2048

# 启用TCP窗口缩放
net.ipv4.tcp_window_scaling = 1

# 快速回收TIME_WAIT
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
```

### 2. 内存优化

#### Session对象池

```cpp
class SessionPool {
    static const int POOL_SIZE = 20000;
    LinkSession pool[POOL_SIZE];
    std::queue<LinkSession*> free_list;

    LinkSession* Allocate() {
        if (free_list.empty()) {
            return new LinkSession(); // 池满时动态分配
        }
        LinkSession* session = free_list.front();
        free_list.pop();
        return session;
    }

    void Free(LinkSession* session) {
        session->Reset();
        free_list.push(session);
    }
};
```

#### 协议对象池

```cpp
template<typename T>
class ProtocolPool {
    std::queue<T*> pool;

    T* Allocate() {
        if (!pool.empty()) {
            T* p = pool.front();
            pool.pop();
            return p;
        }
        return new T();
    }

    void Free(T* p) {
        p->Clear();
        if (pool.size() < 1000) {
            pool.push(p);
        } else {
            delete p;
        }
    }
};
```

### 3. CPU优化

#### epoll高性能I/O

```cpp
// PollIO使用epoll (Linux)
class PollIO {
    int epfd;
    struct epoll_event events[MAX_EVENTS];

    void Poll(int timeout) {
        int nfds = epoll_wait(epfd, events, MAX_EVENTS, timeout);
        for (int i = 0; i < nfds; i++) {
            ProcessEvent(&events[i]);
        }
    }
};
```

#### 避免锁竞争

```cpp
// 每个线程独立的会话管理器
class ThreadLocalSessionManager {
    thread_local static std::map<Session::ID, LinkSession*> sessions;

    // 无锁访问本线程的会话
    LinkSession* GetSession(Session::ID sid) {
        return sessions[sid];
    }
};
```

### 4. 协议优化

#### 批量发送

```cpp
class BatchSender {
    std::vector<Protocol*> batch;
    static const int BATCH_SIZE = 100;

    void Add(Protocol* p) {
        batch.push_back(p);
        if (batch.size() >= BATCH_SIZE) {
            Flush();
        }
    }

    void Flush() {
        // 合并多个协议,一次发送
        Octets buffer;
        for (auto p : batch) {
            p->Encode(buffer);
        }
        SendRaw(buffer);
        batch.clear();
    }
};
```

#### 协议压缩

```cpp
// 大协议压缩
if (protocol->Size() > 4096) {
    Octets compressed = ZlibCompress(protocol->Encode());
    CompressedProtocol wrapper;
    wrapper.data = compressed;
    SendProtocol(&wrapper);
}
```

---

## 🚀 运维指南

### 启动与停止

#### 启动服务

```bash
cd /path/to/gate_server/gate

# 前台启动 (调试)
./glinkd gate.conf

# 后台启动 (生产)
nohup ./glinkd gate.conf > /dev/null 2>&1 &

# 使用systemd (推荐)
sudo systemctl start gate_server
```

#### 停止服务

```bash
# 优雅停止 (SIGTERM)
kill -TERM `cat /var/run/glinkd.pid`

# 强制停止 (SIGKILL)
kill -KILL `cat /var/run/glinkd.pid`

# 使用systemd
sudo systemctl stop gate_server
```

#### 重启服务

```bash
# 平滑重启
kill -HUP `cat /var/run/glinkd.pid`

# 完全重启
sudo systemctl restart gate_server
```

### 日志管理

#### 日志文件

```bash
# 日志目录
/data/logs/gate/

# 日志文件
gate.log        # 主日志
gate.error.log  # 错误日志
gate.stat.log   # 统计日志
```

#### 日志查看

```bash
# 查看最新日志
tail -f /data/logs/gate/gate.log

# 查看错误日志
tail -f /data/logs/gate/gate.error.log

# 搜索特定用户
grep "userid=123456" /data/logs/gate/gate.log

# 统计在线人数
grep "OnlineAnnounce" /data/logs/gate/gate.log | tail -1
```

#### 日志轮转

```bash
# /etc/logrotate.d/gate_server
/data/logs/gate/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    sharedscripts
    postrotate
        kill -HUP `cat /var/run/glinkd.pid`
    endscript
}
```

### 监控指标

#### 关键指标

| 指标 | 说明 | 正常范围 | 告警阈值 |
|------|------|---------|---------|
| **在线人数** | 当前连接数 | 0-10000 | >9000 |
| **CPU使用率** | CPU占用 | <50% | >80% |
| **内存使用** | 内存占用 | <2GB | >3GB |
| **网络流量** | 出入流量 | <100Mbps | >500Mbps |
| **连接建立速率** | 新连接/秒 | <100 | >500 |
| **协议错误率** | 错误协议比例 | <0.1% | >1% |
| **心跳超时率** | 超时断开比例 | <1% | >5% |

#### 监控脚本

```bash
#!/bin/bash
# monitor_gate.sh

# 检查进程
if ! ps aux | grep -v grep | grep glinkd > /dev/null; then
    echo "CRITICAL: Gate Server not running!"
    exit 2
fi

# 检查端口
if ! netstat -an | grep ":10003" | grep LISTEN > /dev/null; then
    echo "CRITICAL: Gate Server port 10003 not listening!"
    exit 2
fi

# 检查在线人数
ONLINE=`grep "OnlineAnnounce" /data/logs/gate/gate.log | tail -1 | awk '{print $NF}'`
if [ "$ONLINE" -gt 9000 ]; then
    echo "WARNING: Online count too high: $ONLINE"
    exit 1
fi

echo "OK: Gate Server running, online=$ONLINE"
exit 0
```

### 性能调优

#### CPU优化

```bash
# 绑定CPU核心 (使用taskset)
taskset -c 0-3 ./glinkd gate.conf

# 设置进程优先级
nice -n -10 ./glinkd gate.conf
```

#### 内存优化

```bash
# 调整内存限制 (ulimit)
ulimit -m 4194304  # 4GB物理内存
ulimit -v 8388608  # 8GB虚拟内存

# 启动服务
./glinkd gate.conf
```

#### 文件描述符

```bash
# 增大文件描述符限制
ulimit -n 65535

# 永久设置 (/etc/security/limits.conf)
*  soft  nofile  65535
*  hard  nofile  65535
```

---

## ❓ 常见问题

### Q1: 客户端无法连接到Gate Server?

**诊断步骤**:

```bash
# 1. 检查进程是否运行
ps aux | grep glinkd

# 2. 检查端口是否监听
netstat -an | grep 10003
lsof -i:10003

# 3. 检查防火墙
iptables -L -n | grep 10003
firewall-cmd --list-ports

# 4. 检查配置文件
cat gate.conf | grep "port.*10003"

# 5. 检查日志
tail -f /data/logs/gate/gate.error.log
```

**常见原因**:
- 进程未启动
- 端口被占用
- 防火墙拦截
- 配置文件错误

### Q2: 客户端连接后立即断开?

**可能原因**:

1. **协议版本不匹配**

```bash
# 检查版本号
grep "version" gate.conf
# 确保客户端使用相同版本
```

2. **心跳超时**

```ini
# 调整心跳间隔
[LinkServer]
keepalive_interval = 60  # 增加到60秒
```

3. **IP封禁**

```bash
# 检查IP是否被封禁
grep "ForbidIP" /data/logs/gate/gate.log | grep "$CLIENT_IP"
```

### Q3: Gate Server CPU占用过高?

**优化方案**:

1. **检查在线人数**

```bash
# 如果在线人数过多,增加服务器配置或部署多台Gate
grep "OnlineAnnounce" /data/logs/gate/gate.log | tail -1
```

2. **检查协议统计**

```bash
# 如果某个协议频率过高,优化客户端或增加限制
grep "Protocol stat" /data/logs/gate/gate.stat.log
```

3. **启用协议统计分析**

```ini
[LinkServer]
stat_open = 1  # 开启协议统计
```

4. **调整定时器频率**

```cpp
// 降低心跳检查频率
CheckKeepAliveTimer.SetInterval(60000); // 60秒检查一次
```

### Q4: Gate与Proxy之间连接断开?

**诊断步骤**:

```bash
# 1. 检查Proxy是否运行
ssh proxy_server "ps aux | grep proxy"

# 2. 检查网络连通性
telnet proxy_server_ip 10011
nc -zv proxy_server_ip 10011

# 3. 检查Gate日志
grep "ProviderServer" /data/logs/gate/gate.log
grep "Provider lost" /data/logs/gate/gate.error.log

# 4. 检查Proxy日志
ssh proxy_server "tail -f /data/logs/proxy/proxy.log"
```

**解决方案**:

1. **增大缓冲区**

```ini
[ProviderServer]
ibuffermax = 3276800  # 3.2MB
obuffermax = 3276800
```

2. **检查防火墙**

```bash
# 允许Gate访问Proxy的10011端口
iptables -A INPUT -p tcp --dport 10011 -j ACCEPT
```

### Q5: 内存使用持续增长?

**诊断**:

```bash
# 1. 检查内存使用
top -p `pidof glinkd`
pmap -x `pidof glinkd`

# 2. 使用valgrind检查内存泄漏
valgrind --leak-check=full ./glinkd gate.conf
```

**常见原因**:

1. **Session未释放**

```cpp
// 确保断开连接时释放Session
void LinkServer::OnDelSession(Session::ID sid) {
    LinkSession* session = GetSession(sid);
    if (session) {
        SessionPool::Free(session);
        sessions.erase(sid);
    }
}
```

2. **Protocol对象未释放**

```cpp
// 使用智能指针管理协议对象
std::shared_ptr<Protocol> p = std::make_shared<UserLoginReq>();
```

3. **断线缓存过多**

```cpp
// 定期清理过期缓存
LinkBrokenCache::CleanExpired(180); // 清理3分钟前的缓存
```

### Q6: 如何实现多Gate负载均衡?

**方案1: DNS轮询**

```bash
# /etc/hosts 或 DNS配置
game.example.com  A  192.168.1.101  # Gate1
game.example.com  A  192.168.1.102  # Gate2
game.example.com  A  192.168.1.103  # Gate3
```

**方案2: Nginx四层代理**

```nginx
stream {
    upstream gate_servers {
        hash $remote_addr consistent;
        server 192.168.1.101:10003;
        server 192.168.1.102:10003;
        server 192.168.1.103:10003;
    }

    server {
        listen 10003;
        proxy_pass gate_servers;
        proxy_timeout 3600s;
    }
}
```

**方案3: LVS负载均衡**

```bash
# 安装LVS
yum install ipvsadm

# 配置LVS NAT模式
ipvsadm -A -t 192.168.1.100:10003 -s rr
ipvsadm -a -t 192.168.1.100:10003 -r 192.168.1.101:10003 -m
ipvsadm -a -t 192.168.1.100:10003 -r 192.168.1.102:10003 -m
ipvsadm -a -t 192.168.1.100:10003 -r 192.168.1.103:10003 -m
```

---

## 📚 附录

### A. 端口映射表

| 端口 | 协议 | 用途 | 连接方向 |
|------|------|------|---------|
| 10003 | TCP | LinkServer 客户端连接 | Client→Gate |
| 10011 | TCP | ProviderServer Proxy连接 | Proxy→Gate |
| 10020 | TCP | DeliveryClient 状态通告 | Gate→Delivery |
| 11100 | UDP | LogClient 日志发送 | Gate→LogService |
| 11101 | TCP | LogClientTcp 日志发送 | Gate→LogService |

### B. 错误码定义

| 错误码 | 说明 | 处理方式 |
|--------|------|---------|
| 0 | 成功 | - |
| 1 | 账号不存在 | 提示注册 |
| 2 | 密码错误 | IP限制 |
| 3 | 账号被封禁 | IP限制 |
| 4 | 服务器维护 | 稍后重试 |
| 5 | 版本不匹配 | 更新客户端 |
| 6 | 服务器满 | 排队等待 |
| 7 | 心跳超时 | 重新连接 |
| 8 | 被踢下线 | 提示顶号 |
| 9 | 协议错误 | 记录日志 |
| 10 | IP被封禁 | 等待解封 |

### C. LinkBroken原因码

| Reason | 说明 |
|--------|------|
| 0 | 正常断开 |
| 1 | 网络错误 |
| 2 | 客户端主动断开 |
| 3 | 服务器主动踢出 |
| 4 | 协议错误 |
| 5 | 版本不匹配 |
| 6 | 认证失败 |
| 7 | 心跳超时 ⭐ |
| 8 | 顶号登录 |
| 9 | 服务器关闭 |
| 10 | IP封禁 |

### D. 编译依赖

```makefile
# Makefile 依赖库
LIBS = -lpthread -lrt -llog4cpp -lz
INCLUDES = -I. -I../../common -I/usr/local/include

# 链接库
libio.a         # IO库
libsecurity.a   # 加密库
libcommon.a     # 公共库
liblogclient.a  # 日志库
```

### E. 性能基准测试

| 场景 | 配置 | 在线人数 | CPU | 内存 | 网络 |
|------|------|---------|-----|------|------|
| 轻负载 | 2核4G | 1000 | 10% | 500MB | 10Mbps |
| 中负载 | 4核8G | 5000 | 40% | 1.5GB | 50Mbps |
| 重负载 | 8核16G | 10000 | 70% | 3GB | 100Mbps |
| 极限 | 16核32G | 20000 | 90% | 6GB | 200Mbps |

### F. 相关文档

- [Common 公共模块文档](../common/docs/README.md)
- [Proxy Server 技术文档](../proxy_server/docs/README.md)
- [Server 总体架构分析](../../docs/server-directory-analysis-report.md)

---

## 📝 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| v1.0 | 2025-11-20 | 初始版本，完整的Gate Server技术文档 |

---

**文档结束**

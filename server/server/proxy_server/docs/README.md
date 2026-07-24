# Proxy Server (代理认证服务器) 技术文档

## 📋 文档信息

- **模块名称**: Proxy Server (gdeliverd)
- **版本**: v1.0
- **最后更新**: 2025-11-20
- **维护团队**: MT3服务器开发组
- **优先级**: ⭐⭐⭐⭐⭐ (核心服务器 - 认证和数据转发中枢)

---

## 📖 目录

1. [模块概述](#模块概述)
2. [架构设计](#架构设计)
3. [目录结构](#目录结构)
4. [核心组件](#核心组件)
5. [配置详解](#配置详解)
6. [认证系统](#认证系统)
7. [数据库集成](#数据库集成)
8. [跨服架构](#跨服架构)
9. [性能优化](#性能优化)
10. [运维指南](#运维指南)
11. [常见问题](#常见问题)
12. [附录](#附录)

---

## 🎯 模块概述

### 功能定位

Proxy Server (gdeliverd) 是 MT3 服务器架构中的**代理认证中枢**，负责：

1. **用户认证** - 验证用户登录，管理账号安全
2. **角色管理** - 管理角色列表，角色创建/删除/选择
3. **数据转发** - 在 Gate、Game、DB 之间转发协议
4. **数据缓存** - 缓存玩家数据，减轻数据库压力
5. **跨服通信** - 管理跨服战斗、活动的数据交互
6. **第三方集成** - 对接认证服务器、交易服务器、IM服务器

### 技术栈

| 技术 | 用途 | 版本/说明 |
|------|------|----------|
| **C++** | 核心实现语言 | C++98/03 |
| **MySQL Connector/C++** | 数据库连接 | libmysqlcppconn |
| **PollIO** | 异步I/O框架 | 自研高性能IO库 |
| **TCP** | 传输协议 | 可靠连接 |
| **log4cpp** | 日志框架 | 分级日志 |
| **OpenSSL** | 加密算法 | ARCFOUR/BLOWFISH/DES |
| **Octets** | 数据序列化 | 自研二进制协议 |

### 服务器信息

- **区服ID (aid)**: 15
- **分区ID (zoneid)**: 1
- **最大玩家数**: 10000
- **伪装最大数**: 10000
- **最大缓存数**: 500000

---

## 🏛️ 架构设计

### 五层架构

```
┌─────────────────────────────────────────────────────────┐
│                   Gate Server 网关层                     │
│           (客户端连接管理、协议转发)                      │
└───────────────┬─────────────────────────────────────────┘
                │ TCP (Port 10020)
                ▼
┌─────────────────────────────────────────────────────────┐
│              Proxy Server 代理认证层 ⭐                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ DeliverServer│  │ GameDBServer │  │ CrossServer  │  │
│  │ (Port 10020) │  │ (Port 10030) │  │ (Port 29201) │  │
│  │ Gate连接     │  │ Game/DB连接  │  │ 跨服连接     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ AuthClient   │  │ TradeClient  │  │ IMClient     │  │
│  │ (Port 29200) │  │ (Port 29208) │  │ (Port 20026) │  │
│  │ 认证服务     │  │ 交易服务     │  │ IM服务       │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │ MySQL        │  │ CrossClient  │                    │
│  │ (Port 3306)  │  │ (Port 29201) │                    │
│  │ 数据库连接   │  │ 跨服客户端   │                    │
│  └──────────────┘  └──────────────┘                    │
└───────────────┬─────────────────────────────────────────┘
                │ TCP (Port 10030)
                ▼
┌─────────────────────────────────────────────────────────┐
│               Game Server / DB Server 业务层             │
│              (游戏逻辑、数据库操作)                       │
└─────────────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────┐
│                   MySQL Database 数据层                  │
│                  (玩家数据持久化)                        │
└─────────────────────────────────────────────────────────┘
```

### 数据流向

```
用户登录流程：

1. [Gate] ──Dispatch(UserLoginReq)──► [Proxy DeliverServer]
2. [Proxy] ──AuthRequest──► [Auth Server]
3. [Auth] ──AuthResponse(Success)──► [Proxy]
4. [Proxy] ──查询角色列表(MySQL)──► [MySQL Database]
5. [MySQL] ──角色数据──► [Proxy]
6. [Proxy] ──Bind(sid, userid)──► [Gate]
7. [Proxy] ──Send(UserLoginRep)──► [Gate] ──► [Client]

角色选择流程：

1. [Client] ──SelectRole(roleid)──► [Gate] ──► [Proxy]
2. [Proxy] ──GetRoleData(roleid)──► [GameDBServer]
3. [GameDBServer] ──RoleData──► [Proxy]
4. [Proxy] ──缓存角色数据──► [内存Cache]
5. [Proxy] ──SetLogin(sid, roleid)──► [Gate]
6. [Proxy] ──EnterWorld──► [Game Server]

游戏协议转发：

1. [Client] ──游戏协议──► [Gate]
2. [Gate] ──Dispatch(protocol)──► [Proxy]
3. [Proxy] ──转发/处理──► [Game Server / DB Server]
4. [Game] ──响应协议──► [Proxy]
5. [Proxy] ──Send(protocol)──► [Gate] ──► [Client]
```

### 核心组件职责

| 组件 | 职责 | 监听端口 | 连接类型 |
|------|------|---------|---------|
| **DeliverServer** | 接受Gate连接，转发客户端协议 | 10020 | TCP Server |
| **GameDBServer** | 连接Game/DB服务器 | 10030 | TCP Server |
| **AuthClient** | 连接认证服务器验证登录 | 29200 | TCP Client |
| **CrossServer** | 跨服服务器（接受其他Proxy） | 29201 | TCP Server |
| **CrossClient** | 跨服客户端（连接其他Proxy） | 29201 | TCP Client |
| **TradeClient** | 连接交易服务器 | 29208 | TCP Client |
| **IMClient** | 连接IM服务器 | 20026 | TCP Client |
| **SNSClient** | 连接SNS服务器 | 10026 | TCP Client |
| **MySQLConn** | MySQL数据库连接池 | 3306 | TCP Client |

---

## 📂 目录结构

```
server/server/proxy_server/
├── docs/                           # 技术文档目录
│   └── README.md                   # 本文档
│
├── proxy/                          # Proxy Server 主目录
│   ├── 核心源文件
│   │   ├── proxy.cpp               # 主程序入口
│   │   ├── proxy.conf              # 核心配置文件 ⭐
│   │   ├── proxy.log4cpp.properties # 日志配置
│   │   ├── Makefile / DCMakefile   # 编译脚本
│   │   └── gdeliverd               # 可执行文件 (编译输出)
│   │
│   ├── 服务器模块
│   │   ├── DeliverServer.cpp/.hpp  # Gate连接服务器
│   │   ├── GameDBServer.cpp/.hpp   # Game/DB连接服务器
│   │   ├── CrossServer.cpp/.hpp    # 跨服服务器
│   │   ├── CrossClient.cpp/.hpp    # 跨服客户端
│   │   ├── AuthClient.cpp/.hpp     # 认证客户端
│   │   └── AuAnyClient.cpp/.hpp    # AuAny客户端
│   │
│   ├── 数据管理模块
│   │   ├── mysqlppconn.cpp/.h      # MySQL连接池 ⭐
│   │   ├── mapforbid.h             # 封禁映射表
│   │   ├── mapgameattr.h           # 游戏属性映射
│   │   ├── mappasswd.h             # 密码映射表
│   │   ├── mapphonetoken.h         # 手机令牌映射
│   │   ├── mapusbkey.h             # USB Key映射
│   │   ├── mapusertype.h           # 用户类型映射
│   │   ├── netplayer.h             # 网络玩家管理
│   │   └── gmcontainer.h           # GM容器
│   │
│   ├── 业务逻辑模块
│   │   ├── forcelogin.h            # 强制登录
│   │   ├── keepalive.h             # 心跳管理
│   │   ├── speedlimit.h            # 速率限制
│   │   ├── serverattr.h            # 服务器属性
│   │   ├── cert.cpp/.hpp           # 证书验证
│   │   └── usbkey.h                # USB Key验证
│   │
│   ├── 跨服模块
│   │   ├── cross/                  # 跨服协议目录
│   │   ├── crossdata.hpp           # 跨服数据
│   │   └── crossbroadcast.hpp      # 跨服广播
│   │
│   ├── 协议模块
│   │   ├── protocols.hpp           # 协议头文件汇总
│   │   ├── rpcgen.cpp/.hpp         # RPC代码生成器输出
│   │   ├── gnet/                   # 协议定义 (*.hpp)
│   │   ├── rpcgen/                 # 自动生成的代码
│   │   └── openau/                 # OpenAU协议
│   │
│   ├── 辅助模块
│   │   ├── commonhelper.hpp        # 公共辅助函数
│   │   ├── hashstring.h            # 字符串哈希
│   │   └── locojoyca.h             # Locojoy CA
│   │
│   └── 开发辅助文件
│       ├── gdeliverd.cbp           # Code::Blocks 项目
│       └── logs/                   # 日志输出目录
│
├── 协议定义文件 (XML)
│   ├── gnet.xml                    # 核心协议
│   ├── gnet.proxy.xml              # Proxy专用协议
│   ├── gnet.cross.xml              # 跨服协议
│   ├── gnet.openau.xml             # OpenAU协议
│   └── gnet.sdk.xml                # SDK协议
│
└── 编译脚本
    └── proxy_build.bat             # Windows编译脚本
```

---

## 🔧 核心组件

### 1. DeliverServer - Gate连接服务器

**文件**: `DeliverServer.cpp/.hpp`

**职责**:
- 监听 Gate Server 连接 (TCP端口 10020)
- 接收来自 Gate 的客户端协议
- 处理用户登录、角色管理
- 转发游戏协议到 GameDBServer
- 管理用户会话状态

**核心功能**:

```cpp
class DeliverServer : public Protocol::Manager {
public:
    // 启动监听
    void Start(const char* config_file);

    // Gate连接建立
    void OnGateConnected(Session::ID sid);

    // Gate断开处理
    void OnGateLost(Session::ID sid);

    // 用户登录处理
    void OnUserLogin(Session::ID sid, UserLoginReq* req);

    // 角色选择处理
    void OnSelectRole(Session::ID sid, SelectRoleReq* req);

    // 协议转发
    void ForwardToGame(Session::ID sid, Protocol* p);

    // 绑定用户到会话
    void BindUser(Session::ID sid, int userid);

    // 解绑用户
    void UnBindUser(Session::ID sid);

    // 踢出用户
    void KickUser(int userid, int reason);
};
```

**配置参数**:

```ini
[DeliverServer]
type                        = tcp
port                        = 10020
address                     = 0.0.0.0
aid                         = 15              # 区服ID
zoneid                      = 1               # 分区ID
max_player_num              = 10000           # 最大玩家数
fake_max_player_num         = 10000           # 伪装最大数
max_cache_num               = 500000          # 最大缓存数
forbid_client_autologin     = 1               # 禁止客户端自动登录
allow_nickname_contain_account = 1            # 允许昵称包含账号
support_forcelogin          = 0               # 支持强制登录
forcelogin_timeout          = 30              # 强制登录超时
```

### 2. GameDBServer - Game/DB连接服务器

**文件**: `GameDBServer.cpp/.hpp`

**职责**:
- 监听 Game Server 和 DB Server 连接 (TCP端口 10030)
- 转发游戏协议到对应的 Game Server
- 管理 Game Server 列表
- 负载均衡

**核心功能**:

```cpp
class GameDBServer : public Protocol::Manager {
public:
    // 启动监听
    void Start(const char* config_file);

    // Game/DB连接建立
    void OnGameConnected(Session::ID sid, int game_id);

    // Game/DB断开处理
    void OnGameLost(Session::ID sid);

    // 转发到Game
    void SendToGame(int game_id, Protocol* p);

    // 广播到所有Game
    void BroadcastToAllGames(Protocol* p);

    // 获取最佳Game Server
    int GetBestGameServer();
};
```

### 3. AuthClient - 认证客户端

**文件**: `AuthClient.cpp/.hpp`

**职责**:
- 连接第三方认证服务器 (TCP端口 29200)
- 验证用户账号密码
- 获取用户权限信息
- 处理SSO单点登录

**核心功能**:

```cpp
class AuthClient : public Protocol::Manager {
public:
    // 连接认证服务器
    void Connect(const char* host, int port);

    // 验证登录
    void VerifyLogin(const std::string& account,
                     const Octets& passwd,
                     Callback callback);

    // SSO验证
    void VerifySSO(const std::string& ticket,
                   Callback callback);

    // 获取用户信息
    void GetUserInfo(int userid, Callback callback);

    // 重连机制
    void Reconnect();
};
```

**配置参数**:

```ini
[AuthClient]
type                    = tcp
port                    = 29200
address                 = 192.168.32.72
tcp_nodelay             = 0
;isec                   = 2               # 输入加密
;iseckey                = n1hxpxztozyxnsvk6RaycpmrCnrdds
;osec                   = 2               # 输出加密
;oseckey                = rdppjtaki1MxoHnsnaltiiwfjszs9l
;shared_key             = 4khdwAAcjrg0eqfzazqcemdpgulnje
use_cert                = 0               # 是否使用证书验证
```

### 4. CrossServer / CrossClient - 跨服架构

**文件**: `CrossServer.cpp/.hpp`, `CrossClient.cpp/.hpp`

**职责**:
- **CrossServer**: 接受其他 Proxy 的跨服连接 (TCP端口 29201)
- **CrossClient**: 连接到其他 Proxy 进行跨服通信
- 管理跨服战斗、跨服活动的数据交互
- 跨服票据验证

**核心功能**:

```cpp
// CrossServer
class CrossServer : public Protocol::Manager {
public:
    // 启动监听
    void Start(const char* config_file);

    // 接受跨服连接
    void OnCrossConnected(Session::ID sid, int remote_zoneid);

    // 处理跨服协议
    void OnCrossProtocol(Session::ID sid, Protocol* p);

    // 验证跨服票据
    bool VerifyTicket(const std::string& ticket, int userid);

    // 跨服数据传输
    void SendCrossData(int target_zoneid, Protocol* p);
};

// CrossClient
class CrossClient : public Protocol::Manager {
public:
    // 连接到目标区服
    void ConnectTo(const std::string& host, int port, int zoneid);

    // 发送跨服请求
    void SendCrossRequest(Protocol* p);

    // 处理跨服响应
    void OnCrossResponse(Protocol* p);

    // 获取跨服票据
    std::string GetCrossTicket(int userid);
};
```

**配置参数**:

```ini
[CrossServer]
type            = tcp
port            = 29201
address         = 0.0.0.0
isec            = 2                         # 输入加密
iseckey         = yybfjhlYuvMuiasaudykb9cmaxep8wsk
osec            = 2                         # 输出加密
oseckey         = oj73pulofapwoxmvkeuezuavfapstbwf

[CrossClient]
bl_open         = 0                         # 是否开启跨服客户端
type            = tcp
port            = 29201
address         = 0.0.0.0
isec            = 2
iseckey         = oj73pulofapwoxmvkeuezuavfapstbwf
osec            = 2
oseckey         = yybfjhlYuvMuiasaudykb9cmaxep8wsk
```

### 5. MySQLConn - MySQL连接池

**文件**: `mysqlppconn.cpp/.h`

**职责**:
- 管理 MySQL 数据库连接池
- 提供数据库查询接口
- 自动重连机制
- 连接健康检查

**核心功能**:

```cpp
class MySQLConnPool {
public:
    // 初始化连接池
    bool Initialize(const char* host, int port,
                    const char* user, const char* passwd,
                    const char* dbname, int pool_size = 10);

    // 获取连接
    sql::Connection* GetConnection();

    // 释放连接
    void ReleaseConnection(sql::Connection* conn);

    // 执行查询
    sql::ResultSet* Query(const std::string& sql);

    // 执行更新
    int Execute(const std::string& sql);

    // 事务支持
    void BeginTransaction();
    void Commit();
    void Rollback();

    // 重连机制
    void Reconnect();

    // 健康检查
    void HealthCheck();
};
```

**配置参数**:

```ini
[Mysql]
ip                      = 192.168.29.161
port                    = 3306
user                    = root
passwd                  =
dbname                  = mt3
reconninterval          = 600               # 重连间隔(秒)
```

---

## ⚙️ 配置详解

### proxy.conf 完整配置

#### [DeliverServer] - Gate连接服务器

```ini
[DeliverServer]
# 网络配置
type                        = tcp
port                        = 10020         # 监听端口 ⭐
address                     = 0.0.0.0       # 监听地址

# 区服配置
;aid                        = 23            # 区服ID (注释掉)
;zoneid                     = 23088         # 分区ID (注释掉)
aid                         = 15            # 当前区服ID ⭐
zoneid                      = 1             # 当前分区ID ⭐

# 玩家数量配置
max_player_num              = 10000         # 最大在线玩家数 ⭐
fake_max_player_num         = 10000         # 伪装最大数 (用于排队)

# 缓存配置
;default num is 100000
max_cache_num               = 500000        # 最大缓存数 ⭐

# 缓冲区配置
so_sndbuf                   = 65536         # Socket发送缓冲 (64KB)
so_rcvbuf                   = 65536         # Socket接收缓冲 (64KB)
ibuffermax                  = 1048576       # 输入缓冲最大值 (1MB)
obuffermax                  = 1048576       # 输出缓冲最大值 (1MB)
accumulate                  = 1048576       # 累积缓冲 (1MB)

# 其他选项
listen_backlog              = 10            # 监听队列长度
tcp_nodelay                 = 0             # TCP_NODELAY选项
forbid_client_autologin     = 1             # 禁止客户端自动登录 ⭐
allow_nickname_contain_account = 1          # 允许昵称包含账号

# 强制登录配置
support_forcelogin          = 0             # 是否支持强制登录
forcelogin_timeout          = 30            # 强制登录超时(秒)
```

#### [GameDBServer] - Game/DB连接服务器

```ini
[GameDBServer]
# 网络配置
type                        = tcp
port                        = 10030         # 监听端口 ⭐
address                     = 0.0.0.0       # 监听地址

# 缓冲区配置
so_sndbuf                   = 65536         # Socket发送缓冲 (64KB)
so_rcvbuf                   = 65536         # Socket接收缓冲 (64KB)
ibuffermax                  = 1048576       # 输入缓冲最大值 (1MB)
obuffermax                  = 1048576       # 输出缓冲最大值 (1MB)
accumulate                  = 1048576       # 累积缓冲 (1MB)

# 其他选项
tcp_nodelay                 = 0             # TCP_NODELAY选项
listen_backlog              = 10            # 监听队列长度
```

#### [AuthClient] - 认证客户端

```ini
[AuAnyclient]
type                        = tcp
port                        = 29200
address                     = 192.168.32.72
;address                    = 0.0.0.0
tcp_nodelay                 = 0
;isec                       = 2
;iseckey                    = oj73pulofapwoxmvkeuezuavfapstbwf
;osec                       = 2
;oseckey                    = yybfjhlYuvMuiasaudykb9cmaxep8wsk
so_sndbuf                   = 65536
so_rcvbuf                   = 65536
ibuffermax                  = 1048576
obuffermax                  = 131072
accumulate                  = 131072
plattype                    = 1             # 平台类型
serverid                    = 1101961001    # 服务器ID

[AuthClient]
type                        = tcp
port                        = 29200
address                     = 192.168.32.72
tcp_nodelay                 = 0
;isec                       = 2
;iseckey                    = n1hxpxztozyxnsvk6RaycpmrCnrdds
;osec                       = 2
;oseckey                    = rdppjtaki1MxoHnsnaltiiwfjszs9l
;shared_key                 = 4khdwAAcjrg0eqfzazqcemdpgulnje
so_sndbuf                   = 65536
so_rcvbuf                   = 65536
ibuffermax                  = 1048576
obuffermax                  = 131072
accumulate                  = 131072
use_cert                    = 0             # 证书验证 ⭐
```

#### [TradeClient] - 交易客户端

```ini
[TradeClient]
bl_open                     = 0             # 是否连接交易服务器 ⭐
type                        = tcp
port                        = 29208
address                     = 172.16.2.140
tcp_nodelay                 = 0
;isec                       = 2
;iseckey                    = n1hxpxztozyxnsvk6RaycpmrCnrdds
;osec                       = 2
;oseckey                    = rdppjtaki1MxoHnsnaltiiwfjszs9l
;shared_key                 = 4khdwAAcjrg0eqfzazqcemdpgulnje
so_sndbuf                   = 65536
so_rcvbuf                   = 65536
ibuffermax                  = 1048576
obuffermax                  = 131072
accumulate                  = 131072
```

#### [IMClient] - IM客户端

```ini
[IMClient]
bl_open                     = 0             # 是否连接IM服务器 ⭐
type                        = tcp
port                        = 20026
address                     = 172.16.2.87
tcp_nodelay                 = 0
;isec                       = 2
;iseckey                    = n1hxpxztozyxnsvk6RaycpmrCnrdds
;osec                       = 2
;oseckey                    = rdppjtaki1MxoHnsnaltiiwfjszs9l
;shared_key                 = 4khdwAAcjrg0eqfzazqcemdpgulnje
so_sndbuf                   = 65536
so_rcvbuf                   = 65536
ibuffermax                  = 1048576
obuffermax                  = 131072
accumulate                  = 131072
```

#### [SNSClient] - SNS客户端

```ini
[SNSClient]
bl_open                     = 0             # 是否连接SNS服务器 ⭐
type                        = tcp
port                        = 10026
address                     = 172.16.2.84
tcp_nodelay                 = 0
;isec                       = 2
;iseckey                    = n1hxpxztozyxnsvk6RaycpmrCnrdds
;osec                       = 2
;oseckey                    = rdppjtaki1MxoHnsnaltiiwfjszs9l
;shared_key                 = 4khdwAAcjrg0eqfzazqcemdpgulnje
so_sndbuf                   = 65536
so_rcvbuf                   = 65536
ibuffermax                  = 1048576
obuffermax                  = 131072
accumulate                  = 131072
```

#### [CrossServer] - 跨服服务器

```ini
[CrossServer]
type                        = tcp
port                        = 29201         # 监听端口 ⭐
address                     = 0.0.0.0       # 监听地址
isec                        = 2             # 输入加密
iseckey                     = yybfjhlYuvMuiasaudykb9cmaxep8wsk
osec                        = 2             # 输出加密
oseckey                     = oj73pulofapwoxmvkeuezuavfapstbwf
so_sndbuf                   = 65536
so_rcvbuf                   = 65536
ibuffermax                  = 1048576
obuffermax                  = 1048576
accumulate                  = 1048576
listen_backlog              = 10
tcp_nodelay                 = 0
```

#### [CrossClient] - 跨服客户端

```ini
[CrossClient]
bl_open                     = 0             # 是否开启跨服客户端 ⭐
type                        = tcp
port                        = 29201
address                     = 0.0.0.0       # 目标Proxy地址
tcp_nodelay                 = 0
isec                        = 2
iseckey                     = oj73pulofapwoxmvkeuezuavfapstbwf
osec                        = 2
oseckey                     = yybfjhlYuvMuiasaudykb9cmaxep8wsk
so_sndbuf                   = 65536
so_rcvbuf                   = 65536
ibuffermax                  = 1048576
obuffermax                  = 131072
accumulate                  = 131072
```

#### [Intervals] - 定时器配置

```ini
[Intervals]
;set check forbidlogin user's map interval,unit is second
checkforbidmap_interval     = 60            # 检查封禁地图间隔(秒)
keepalive_interval          = 300           # 心跳间隔(秒) ⭐
cross_ticket_alive_second   = 180           # 跨服票据有效期(秒) ⭐
```

#### 速率限制配置

```ini
[SpeedLimit]
window                      = 60            # 时间窗口(秒)
high                        = 50            # 高水位(次数)

[InstantAddCash]
window                      = 300           # 即时充值时间窗口(秒)
high                        = 3             # 即时充值限制(次)

[LockIPLimit]
window                      = 60            # IP锁定时间窗口(秒)
high                        = 5000          # IP锁定阈值(次)

[CouponLimit]
window                      = 300           # 优惠券获取时间窗口(秒)
high                        = 2             # 优惠券获取限制(次)

[CouponExcgangeLimit]
window                      = 120           # 优惠券兑换时间窗口(秒)
high                        = 1             # 优惠券兑换限制(次)

[AuRequestLimit]
window                      = 600           # AU请求时间窗口(秒)
high                        = 100           # AU请求限制(次)
```

#### [Mysql] - 数据库配置

```ini
[Mysql]
;ip                         = 127.0.0.1
ip                          = 192.168.29.161  # MySQL服务器IP ⭐
port                        = 3306            # MySQL端口
user                        = root            # MySQL用户名 ⭐
passwd                      =                 # MySQL密码 (空)
dbname                      = mt3             # 数据库名 ⭐
reconninterval              = 600             # 重连间隔(秒)
```

---

## 🔐 认证系统

### 用户登录流程

#### 1. Challenge-Response 认证

```cpp
// 1. 客户端发起挑战
Challenge challenge;
challenge.nonce = GenerateNonce(16);
SendToGate(&challenge);

// 2. Gate转发到Proxy
void DeliverServer::OnChallenge(Session::ID sid, Challenge* req) {
    // 生成服务器随机数
    Response resp;
    resp.nonce = GenerateNonce(16);
    resp.oskey = GenerateSessionKey(32);

    // 保存到会话
    sessions[sid].nonce_s = resp.nonce;
    sessions[sid].oskey = resp.oskey;

    SendToGate(sid, &resp);
}

// 3. 客户端计算密码哈希并登录
UserLoginReq req;
req.account = account;
req.passwd = MD5(passwd + nonce_c + nonce_s);
SendToGate(&req);

// 4. Proxy验证登录
void DeliverServer::OnUserLogin(Session::ID sid, UserLoginReq* req) {
    // 转发到AuthServer验证
    AuthClient::GetInstance()->VerifyLogin(
        req->account,
        req->passwd,
        [this, sid, req](bool success, int userid) {
            if (success) {
                // 查询角色列表
                QueryRoleList(userid, [this, sid, userid](RoleList roles) {
                    UserLoginRep rep;
                    rep.result = 0; // 成功
                    rep.userid = userid;
                    rep.rolelist = roles;

                    // 发送响应
                    SendToGate(sid, &rep);

                    // 绑定用户
                    BindUser(sid, userid);
                });
            } else {
                // 登录失败
                UserLoginRep rep;
                rep.result = 2; // 密码错误
                SendToGate(sid, &rep);
            }
        }
    );
}
```

#### 2. 矩阵密码验证

```cpp
// 矩阵密码挑战
void DeliverServer::SendMatrixChallenge(Session::ID sid) {
    MatrixChallenge challenge;
    challenge.positions.push_back(GPair(2, 3));
    challenge.positions.push_back(GPair(5, 7));
    challenge.positions.push_back(GPair(1, 4));

    sessions[sid].matrix_positions = challenge.positions;
    SendToGate(sid, &challenge);
}

// 矩阵密码响应
void DeliverServer::OnMatrixResponse(Session::ID sid, MatrixResponse* resp) {
    // 从数据库查询用户的矩阵卡
    std::string matrix_card = QueryMatrixCard(sessions[sid].userid);

    // 验证响应
    bool valid = true;
    for (size_t i = 0; i < sessions[sid].matrix_positions.size(); i++) {
        int row = sessions[sid].matrix_positions[i].key;
        int col = sessions[sid].matrix_positions[i].value;
        int expected = matrix_card[row * 8 + col];

        if (resp->values[i] != expected) {
            valid = false;
            break;
        }
    }

    if (valid) {
        // 验证成功
        sessions[sid].matrix_verified = true;
    } else {
        // 验证失败,踢出用户
        KickUser(sid, REASON_MATRIX_FAILED);
    }
}
```

#### 3. SSO单点登录

```cpp
// SSO登录请求
void DeliverServer::OnSSOGetTicket(Session::ID sid, SSOGetTicketReq* req) {
    // 转发到AuthServer获取票据
    AuthClient::GetInstance()->GetSSOTicket(
        req->account,
        [this, sid](const std::string& ticket) {
            SSOGetTicketRep rep;
            rep.ticket = Octets(ticket.data(), ticket.size());

            SendToGate(sid, &rep);
        }
    );
}

// 使用SSO票据登录
void DeliverServer::OnSSOLogin(Session::ID sid, const std::string& ticket) {
    // 验证票据
    AuthClient::GetInstance()->VerifySSO(
        ticket,
        [this, sid](bool success, int userid) {
            if (success) {
                // 查询角色列表
                QueryRoleList(userid, [this, sid, userid](RoleList roles) {
                    UserLoginRep rep;
                    rep.result = 0;
                    rep.userid = userid;
                    rep.rolelist = roles;

                    SendToGate(sid, &rep);
                    BindUser(sid, userid);
                });
            } else {
                // 票据无效
                UserLoginRep rep;
                rep.result = 5; // SSO失败
                SendToGate(sid, &rep);
            }
        }
    );
}
```

### 角色管理

#### 角色列表查询

```cpp
void DeliverServer::QueryRoleList(int userid, Callback callback) {
    // 从MySQL查询角色列表
    std::string sql = "SELECT roleid, name, level, profession, "
                      "create_time, last_login FROM roles "
                      "WHERE userid = " + std::to_string(userid);

    sql::ResultSet* rs = mysql_pool->Query(sql);

    RoleList roles;
    while (rs->next()) {
        RoleInfo role;
        role.roleid = rs->getInt("roleid");
        role.name = rs->getString("name");
        role.level = rs->getInt("level");
        role.profession = rs->getInt("profession");
        role.create_time = rs->getInt64("create_time");
        role.last_login = rs->getInt64("last_login");

        roles.push_back(role);
    }

    delete rs;
    callback(roles);
}
```

#### 角色创建

```cpp
void DeliverServer::CreateRole(int userid, const std::string& name,
                                int profession, Callback callback) {
    // 检查角色名是否已存在
    std::string sql = "SELECT COUNT(*) FROM roles WHERE name = '" + name + "'";
    sql::ResultSet* rs = mysql_pool->Query(sql);

    if (rs->next() && rs->getInt(1) > 0) {
        delete rs;
        callback(false, ERROR_NAME_EXISTS);
        return;
    }
    delete rs;

    // 创建角色
    sql = "INSERT INTO roles (userid, name, level, profession, create_time) "
          "VALUES (" + std::to_string(userid) + ", '" + name + "', 1, " +
          std::to_string(profession) + ", " + std::to_string(time(NULL)) + ")";

    if (mysql_pool->Execute(sql) > 0) {
        int roleid = mysql_pool->GetLastInsertId();
        callback(true, roleid);
    } else {
        callback(false, ERROR_DB_FAILED);
    }
}
```

#### 角色选择

```cpp
void DeliverServer::SelectRole(Session::ID sid, int roleid) {
    // 验证角色所有权
    int userid = sessions[sid].userid;
    std::string sql = "SELECT userid FROM roles WHERE roleid = " +
                      std::to_string(roleid);

    sql::ResultSet* rs = mysql_pool->Query(sql);

    if (!rs->next() || rs->getInt("userid") != userid) {
        delete rs;
        // 角色不属于该用户
        SelectRoleRep rep;
        rep.result = ERROR_INVALID_ROLE;
        SendToGate(sid, &rep);
        return;
    }
    delete rs;

    // 从GameDBServer加载角色数据
    GetRoleData req;
    req.roleid = roleid;

    GameDBServer::GetInstance()->SendProtocol(&req,
        [this, sid, roleid](GetRoleDataRep* rep) {
            if (rep->result == 0) {
                // 缓存角色数据
                role_cache[roleid] = rep->role_data;

                // 设置登录状态
                sessions[sid].roleid = roleid;
                sessions[sid].state = STATE_PLAYING;

                // 通知Gate
                SetLogin set_login;
                set_login.sid = sid;
                set_login.roleid = roleid;
                SendToGate(&set_login);

                // 通知Game进入世界
                EnterWorld enter;
                enter.roleid = roleid;
                enter.role_data = rep->role_data;
                GameDBServer::GetInstance()->SendProtocol(&enter);

                // 响应客户端
                SelectRoleRep rep2;
                rep2.result = 0;
                rep2.role_data = rep->role_data;
                SendToGate(sid, &rep2);
            } else {
                // 加载失败
                SelectRoleRep rep2;
                rep2.result = ERROR_LOAD_FAILED;
                SendToGate(sid, &rep2);
            }
        }
    );
}
```

---

## 💾 数据库集成

### MySQL连接池实现

```cpp
class MySQLConnPool {
private:
    std::string host;
    int port;
    std::string user;
    std::string passwd;
    std::string dbname;
    int reconninterval;

    std::queue<sql::Connection*> pool;
    std::mutex pool_mutex;
    int pool_size;
    int active_conns;

public:
    bool Initialize(const char* config_file) {
        // 读取配置
        ReadConfig(config_file);

        // 创建连接池
        for (int i = 0; i < pool_size; i++) {
            sql::Connection* conn = CreateConnection();
            if (conn) {
                pool.push(conn);
            }
        }

        // 启动健康检查定时器
        StartHealthCheckTimer();

        return !pool.empty();
    }

    sql::Connection* GetConnection() {
        std::lock_guard<std::mutex> lock(pool_mutex);

        if (pool.empty()) {
            // 池中无可用连接,创建新连接
            return CreateConnection();
        }

        sql::Connection* conn = pool.front();
        pool.pop();
        active_conns++;

        return conn;
    }

    void ReleaseConnection(sql::Connection* conn) {
        std::lock_guard<std::mutex> lock(pool_mutex);

        // 检查连接是否还有效
        if (conn && conn->isValid(1)) {
            pool.push(conn);
        } else {
            delete conn;
            // 创建新连接补充
            conn = CreateConnection();
            if (conn) {
                pool.push(conn);
            }
        }

        active_conns--;
    }

    sql::ResultSet* Query(const std::string& sql) {
        sql::Connection* conn = GetConnection();
        if (!conn) {
            return nullptr;
        }

        try {
            sql::Statement* stmt = conn->createStatement();
            sql::ResultSet* rs = stmt->executeQuery(sql);
            delete stmt;

            ReleaseConnection(conn);
            return rs;
        } catch (sql::SQLException& e) {
            LOG_ERROR("MySQL query failed: %s, SQL: %s",
                      e.what(), sql.c_str());
            ReleaseConnection(conn);
            return nullptr;
        }
    }

    int Execute(const std::string& sql) {
        sql::Connection* conn = GetConnection();
        if (!conn) {
            return -1;
        }

        try {
            sql::Statement* stmt = conn->createStatement();
            int affected = stmt->executeUpdate(sql);
            delete stmt;

            ReleaseConnection(conn);
            return affected;
        } catch (sql::SQLException& e) {
            LOG_ERROR("MySQL execute failed: %s, SQL: %s",
                      e.what(), sql.c_str());
            ReleaseConnection(conn);
            return -1;
        }
    }

private:
    sql::Connection* CreateConnection() {
        try {
            sql::mysql::MySQL_Driver* driver =
                sql::mysql::get_mysql_driver_instance();

            std::string url = "tcp://" + host + ":" + std::to_string(port);
            sql::Connection* conn = driver->connect(url, user, passwd);

            conn->setSchema(dbname);
            conn->setAutoCommit(true);

            LOG_INFO("MySQL connection created: %s@%s:%d/%s",
                     user.c_str(), host.c_str(), port, dbname.c_str());

            return conn;
        } catch (sql::SQLException& e) {
            LOG_ERROR("MySQL connection failed: %s", e.what());
            return nullptr;
        }
    }

    void HealthCheck() {
        std::lock_guard<std::mutex> lock(pool_mutex);

        std::queue<sql::Connection*> new_pool;

        while (!pool.empty()) {
            sql::Connection* conn = pool.front();
            pool.pop();

            if (conn && conn->isValid(1)) {
                new_pool.push(conn);
            } else {
                delete conn;
                // 创建新连接
                conn = CreateConnection();
                if (conn) {
                    new_pool.push(conn);
                }
            }
        }

        pool = new_pool;
    }
};
```

### 数据库表设计

#### users 表 - 用户账号

```sql
CREATE TABLE `users` (
  `userid` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account` VARCHAR(64) NOT NULL,
  `passwd` VARCHAR(64) NOT NULL,
  `email` VARCHAR(128),
  `phone` VARCHAR(32),
  `create_time` INT UNSIGNED NOT NULL,
  `last_login` INT UNSIGNED,
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '0=正常,1=封禁',
  PRIMARY KEY (`userid`),
  UNIQUE KEY `idx_account` (`account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### roles 表 - 角色信息

```sql
CREATE TABLE `roles` (
  `roleid` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userid` INT UNSIGNED NOT NULL,
  `name` VARCHAR(32) NOT NULL,
  `level` INT UNSIGNED NOT NULL DEFAULT 1,
  `profession` TINYINT NOT NULL,
  `create_time` INT UNSIGNED NOT NULL,
  `last_login` INT UNSIGNED,
  `online` TINYINT NOT NULL DEFAULT 0,
  `delete_time` INT UNSIGNED DEFAULT 0,
  PRIMARY KEY (`roleid`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_userid` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### forbid 表 - 封禁记录

```sql
CREATE TABLE `forbid` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userid` INT UNSIGNED,
  `roleid` INT UNSIGNED,
  `type` TINYINT NOT NULL COMMENT '1=账号,2=角色,3=IP',
  `reason` VARCHAR(256),
  `start_time` INT UNSIGNED NOT NULL,
  `end_time` INT UNSIGNED NOT NULL,
  `gm_account` VARCHAR(64),
  PRIMARY KEY (`id`),
  KEY `idx_userid` (`userid`),
  KEY `idx_roleid` (`roleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 🌐 跨服架构

### 跨服票据系统

```cpp
class CrossTicketManager {
private:
    struct Ticket {
        int userid;
        int roleid;
        int source_zoneid;
        int target_zoneid;
        time_t create_time;
        time_t expire_time;
        std::string token;
    };

    std::map<std::string, Ticket> tickets;
    std::mutex tickets_mutex;
    int ticket_alive_seconds;

public:
    // 生成跨服票据
    std::string GenerateTicket(int userid, int roleid,
                                int source_zoneid, int target_zoneid) {
        Ticket ticket;
        ticket.userid = userid;
        ticket.roleid = roleid;
        ticket.source_zoneid = source_zoneid;
        ticket.target_zoneid = target_zoneid;
        ticket.create_time = time(NULL);
        ticket.expire_time = ticket.create_time + ticket_alive_seconds;
        ticket.token = GenerateRandomToken(32);

        std::lock_guard<std::mutex> lock(tickets_mutex);
        tickets[ticket.token] = ticket;

        return ticket.token;
    }

    // 验证跨服票据
    bool VerifyTicket(const std::string& token, int& userid, int& roleid) {
        std::lock_guard<std::mutex> lock(tickets_mutex);

        auto it = tickets.find(token);
        if (it == tickets.end()) {
            return false; // 票据不存在
        }

        Ticket& ticket = it->second;

        // 检查是否过期
        if (time(NULL) > ticket.expire_time) {
            tickets.erase(it);
            return false; // 票据已过期
        }

        userid = ticket.userid;
        roleid = ticket.roleid;

        // 票据使用后立即失效
        tickets.erase(it);

        return true;
    }

    // 清理过期票据
    void CleanExpiredTickets() {
        std::lock_guard<std::mutex> lock(tickets_mutex);

        time_t now = time(NULL);

        for (auto it = tickets.begin(); it != tickets.end(); ) {
            if (now > it->second.expire_time) {
                it = tickets.erase(it);
            } else {
                ++it;
            }
        }
    }
};
```

### 跨服战斗流程

```
1. 玩家请求跨服战斗
   [Client] ──JoinCrossBattle──► [Proxy1]

2. 本服Proxy生成跨服票据
   [Proxy1] ──GenerateTicket(userid, roleid, zoneid1, zoneid2)

3. 连接到目标区服
   [Proxy1 CrossClient] ──Connect──► [Proxy2 CrossServer]

4. 发送跨服请求
   [Proxy1] ──CrossBattleRequest(ticket, role_data)──► [Proxy2]

5. 目标区服验证票据
   [Proxy2] ──VerifyTicket(ticket)──► 验证成功

6. 加入跨服战场
   [Proxy2] ──JoinBattle(role_data)──► [Game Server2]

7. 战斗结束,返回数据
   [Game Server2] ──BattleResult──► [Proxy2]

8. 同步数据到源区服
   [Proxy2] ──CrossBattleResult──► [Proxy1]

9. 更新玩家数据
   [Proxy1] ──UpdateRoleData──► [DB Server1]

10. 通知客户端
    [Proxy1] ──BattleResult──► [Client]
```

---

## ⚡ 性能优化

### 1. 数据缓存

#### 玩家数据缓存

```cpp
class RoleDataCache {
private:
    struct CacheEntry {
        RoleData data;
        time_t cache_time;
        time_t last_access;
        bool dirty; // 是否有修改
    };

    std::unordered_map<int, CacheEntry> cache;
    std::mutex cache_mutex;
    int max_cache_num;
    int cache_timeout;

public:
    // 获取角色数据
    RoleData* Get(int roleid) {
        std::lock_guard<std::mutex> lock(cache_mutex);

        auto it = cache.find(roleid);
        if (it != cache.end()) {
            it->second.last_access = time(NULL);
            return &it->second.data;
        }

        return nullptr; // 缓存未命中
    }

    // 设置角色数据
    void Set(int roleid, const RoleData& data) {
        std::lock_guard<std::mutex> lock(cache_mutex);

        // 检查缓存是否已满
        if (cache.size() >= max_cache_num) {
            EvictLRU();
        }

        CacheEntry entry;
        entry.data = data;
        entry.cache_time = time(NULL);
        entry.last_access = time(NULL);
        entry.dirty = false;

        cache[roleid] = entry;
    }

    // 标记为脏数据
    void MarkDirty(int roleid) {
        std::lock_guard<std::mutex> lock(cache_mutex);

        auto it = cache.find(roleid);
        if (it != cache.end()) {
            it->second.dirty = true;
        }
    }

    // 刷新脏数据到数据库
    void FlushDirty() {
        std::lock_guard<std::mutex> lock(cache_mutex);

        for (auto& pair : cache) {
            if (pair.second.dirty) {
                // 保存到数据库
                SaveToDatabase(pair.first, pair.second.data);
                pair.second.dirty = false;
            }
        }
    }

private:
    // LRU驱逐
    void EvictLRU() {
        time_t oldest_access = time(NULL);
        int oldest_roleid = -1;

        for (const auto& pair : cache) {
            if (pair.second.last_access < oldest_access) {
                oldest_access = pair.second.last_access;
                oldest_roleid = pair.first;
            }
        }

        if (oldest_roleid != -1) {
            // 如果是脏数据,先保存
            if (cache[oldest_roleid].dirty) {
                SaveToDatabase(oldest_roleid, cache[oldest_roleid].data);
            }

            cache.erase(oldest_roleid);
        }
    }
};
```

### 2. 协议批量处理

```cpp
class ProtocolBatcher {
private:
    std::vector<Protocol*> batch;
    int batch_size;
    std::mutex batch_mutex;

public:
    void Add(Protocol* p) {
        std::lock_guard<std::mutex> lock(batch_mutex);

        batch.push_back(p);

        if (batch.size() >= batch_size) {
            Flush();
        }
    }

    void Flush() {
        if (batch.empty()) {
            return;
        }

        // 合并多个协议
        Octets buffer;
        for (auto p : batch) {
            p->Encode(buffer);
            delete p;
        }

        // 一次性发送
        SendRaw(buffer);

        batch.clear();
    }
};
```

### 3. 异步数据库操作

```cpp
class AsyncDBExecutor {
private:
    struct Task {
        std::string sql;
        std::function<void(sql::ResultSet*)> callback;
    };

    std::queue<Task> task_queue;
    std::mutex queue_mutex;
    std::condition_variable queue_cv;
    std::vector<std::thread> workers;
    bool running;

public:
    void Start(int num_threads) {
        running = true;

        for (int i = 0; i < num_threads; i++) {
            workers.emplace_back([this]() {
                WorkerThread();
            });
        }
    }

    void ExecuteAsync(const std::string& sql,
                      std::function<void(sql::ResultSet*)> callback) {
        std::lock_guard<std::mutex> lock(queue_mutex);

        Task task;
        task.sql = sql;
        task.callback = callback;

        task_queue.push(task);
        queue_cv.notify_one();
    }

private:
    void WorkerThread() {
        while (running) {
            std::unique_lock<std::mutex> lock(queue_mutex);

            queue_cv.wait(lock, [this]() {
                return !task_queue.empty() || !running;
            });

            if (!running) {
                break;
            }

            Task task = task_queue.front();
            task_queue.pop();

            lock.unlock();

            // 执行SQL
            sql::ResultSet* rs = mysql_pool->Query(task.sql);

            // 回调
            if (task.callback) {
                task.callback(rs);
            }

            delete rs;
        }
    }
};
```

---

## 🚀 运维指南

### 启动与停止

#### 启动服务

```bash
cd /path/to/proxy_server/proxy

# 前台启动 (调试)
./gdeliverd proxy.conf

# 后台启动 (生产)
nohup ./gdeliverd proxy.conf > /dev/null 2>&1 &

# 使用systemd (推荐)
sudo systemctl start proxy_server
```

#### 停止服务

```bash
# 优雅停止 (SIGTERM)
kill -TERM `cat /var/run/gdeliverd.pid`

# 强制停止 (SIGKILL)
kill -KILL `cat /var/run/gdeliverd.pid`

# 使用systemd
sudo systemctl stop proxy_server
```

### 日志管理

#### 日志文件

```bash
# 日志目录
/data/logs/proxy/

# 日志文件
proxy.log        # 主日志
proxy.error.log  # 错误日志
proxy.stat.log   # 统计日志
proxy.auth.log   # 认证日志
proxy.cross.log  # 跨服日志
```

#### 日志查看

```bash
# 查看最新日志
tail -f /data/logs/proxy/proxy.log

# 查看错误日志
tail -f /data/logs/proxy/proxy.error.log

# 搜索特定用户
grep "userid=123456" /data/logs/proxy/proxy.log

# 统计登录成功率
grep "UserLogin" /data/logs/proxy/proxy.log | \
  awk '{if($0~/result=0/)success++;else fail++;} \
  END{print "Success:",success,"Fail:",fail,"Rate:",success/(success+fail)*100"%"}'
```

### 监控指标

| 指标 | 说明 | 正常范围 | 告警阈值 |
|------|------|---------|---------|
| **在线人数** | 当前在线玩家 | 0-10000 | >9500 |
| **缓存命中率** | 数据缓存命中 | >90% | <80% |
| **数据库QPS** | 数据库查询 | <1000 | >5000 |
| **认证成功率** | 登录成功率 | >95% | <90% |
| **跨服延迟** | 跨服通信延迟 | <100ms | >500ms |

### 常见运维操作

#### 数据库连接池重置

```bash
# 发送USR1信号重置连接池
kill -USR1 `cat /var/run/gdeliverd.pid`
```

#### 刷新缓存

```bash
# 发送USR2信号刷新脏数据
kill -USR2 `cat /var/run/gdeliverd.pid`
```

#### 热更新配置

```bash
# 发送HUP信号重载配置
kill -HUP `cat /var/run/gdeliverd.pid`
```

---

## ❓ 常见问题

### Q1: 玩家无法登录?

**诊断步骤**:

```bash
# 1. 检查AuthServer连接
grep "AuthClient" /data/logs/proxy/proxy.log | tail -20

# 2. 检查MySQL连接
mysql -h 192.168.29.161 -u root -p mt3 -e "SHOW PROCESSLIST;"

# 3. 检查网络
telnet 192.168.32.72 29200
nc -zv 192.168.29.161 3306

# 4. 查看登录日志
grep "UserLogin" /data/logs/proxy/proxy.log | tail -20
```

### Q2: 数据库连接数过多?

**解决方案**:

```cpp
// 调整连接池大小
MySQLConnPool::Initialize(config_file, 20); // 增加到20个连接

// 启用连接复用
conn->setAutoCommit(true);

// 定期清理空闲连接
MySQLConnPool::CleanIdleConnections(300); // 清理5分钟未使用的连接
```

### Q3: 跨服功能无法使用?

**检查清单**:

1. **CrossClient是否开启**

```ini
[CrossClient]
bl_open = 1  # 确保为1
```

2. **目标区服地址是否正确**

```ini
address = 目标Proxy的IP
```

3. **加密密钥是否匹配**

```ini
# 本地CrossClient的oseckey必须等于目标CrossServer的iseckey
[CrossClient]
oseckey = yybfjhlYuvMuiasaudykb9cmaxep8wsk

# 目标Proxy的CrossServer
[CrossServer]
iseckey = yybfjhlYuvMuiasaudykb9cmaxep8wsk
```

---

## 📚 附录

### A. 端口映射表

| 端口 | 协议 | 用途 | 连接方向 |
|------|------|------|---------|
| 10020 | TCP | DeliverServer Gate连接 | Gate→Proxy |
| 10030 | TCP | GameDBServer Game/DB连接 | Game/DB→Proxy |
| 29200 | TCP | AuthClient 认证服务 | Proxy→Auth |
| 29201 | TCP | CrossServer/Client 跨服 | Proxy↔Proxy |
| 29208 | TCP | TradeClient 交易服务 | Proxy→Trade |
| 20026 | TCP | IMClient IM服务 | Proxy→IM |
| 10026 | TCP | SNSClient SNS服务 | Proxy→SNS |
| 3306 | TCP | MySQL 数据库 | Proxy→MySQL |

### B. 相关文档

- [Common 公共模块文档](../common/docs/README.md)
- [Gate Server 技术文档](../gate_server/docs/README.md)
- [Game Server 技术文档](../game_server/docs/README.md)
- [Server 总体架构分析](../../docs/server-directory-analysis-report.md)

---

## 📝 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| v1.0 | 2025-11-20 | 初始版本，完整的Proxy Server技术文档 |

---

**文档结束**

# Common 公共模块技术文档

## 📋 文档信息

- **模块名称**: Common 公共模块
- **版本**: v1.0
- **最后更新**: 2025-11-20
- **维护团队**: MT3服务器开发组
- **优先级**: ⭐⭐⭐⭐⭐ (最高 - 所有服务器依赖的基础模块)

---

## 📖 目录

1. [模块概述](#模块概述)
2. [目录结构](#目录结构)
3. [协议系统](#协议系统)
4. [日志系统](#日志系统)
5. [核心文件说明](#核心文件说明)
6. [使用指南](#使用指南)
7. [配置说明](#配置说明)
8. [常见问题](#常见问题)
9. [附录](#附录)

---

## 🎯 模块概述

### 功能定位

Common 模块是 MT3 服务器架构的**基础公共模块**，为所有服务器提供：

1. **协议定义系统** - 基于 XML 的协议定义和代码生成
2. **分布式日志系统** - 集中式日志收集和管理
3. **公共数据结构** - 跨服务器共享的数据类型定义

### 技术栈

| 技术 | 用途 | 版本/说明 |
|------|------|----------|
| **C++** | 日志客户端实现 | C++98/03 |
| **XML** | 协议定义 | 自定义 Schema |
| **RPC Generator** | 代码生成工具 | rpcgen.jar |
| **UDP/TCP** | 日志传输协议 | 双协议支持 |
| **log4cpp** | 本地日志框架 | 分级日志 |

### 架构定位

```
┌─────────────────────────────────────────────────────────┐
│                   Application Servers                    │
│  (Gate / Proxy / Game / Name / SDK / Spirit / Zone)     │
└───────────────┬─────────────────────────────────────────┘
                │ 依赖
                ▼
┌─────────────────────────────────────────────────────────┐
│                    Common 公共模块                       │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │ 协议定义      │  │ 日志系统      │  │ 公共数据结构    │ │
│  │ (gnet.xml)  │  │ (logclient)  │  │ (Bean/Protocol)│ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────┘
                │ 输出
                ▼
┌─────────────────────────────────────────────────────────┐
│         生成的代码 (C++/Java Headers/Classes)            │
└─────────────────────────────────────────────────────────┘
```

---

## 📂 目录结构

```
server/server/common/
├── docs/                           # 技术文档目录
│   └── README.md                   # 本文档
│
├── 协议定义文件 (Protocol Definitions)
│   ├── gnet.xml                    # 核心协议定义
│   ├── gnet.gate.xml               # 网关服务器协议
│   ├── gnet.proxy.xml              # 代理服务器协议
│   ├── gnet.authc.xml              # 认证客户端协议
│   ├── gnet.cross.xml              # 跨服协议
│   ├── gnet.openau.xml             # OpenAU协议
│   └── gnet.sdk.xml                # SDK协议
│
├── logclient/                      # 日志客户端 (C++)
│   ├── glog.cpp                    # 日志封装主文件
│   ├── log.cpp                     # 日志实现
│   ├── logclient.conf              # 日志客户端配置
│   ├── logclient.cpp               # 日志客户端主程序
│   ├── LogClientManager.cpp/.hpp   # UDP日志管理器
│   ├── LogClientTcpManager.cpp/.hpp # TCP日志管理器
│   ├── protocols.hpp               # 协议头文件
│   ├── Makefile                    # 编译脚本
│   ├── gnet/                       # 协议定义
│   │   ├── RemoteLog.hpp           # 远程日志协议
│   │   ├── RemoteLogVital.hpp      # 重要日志协议
│   │   ├── StatInfo.hpp            # 统计信息协议
│   │   └── StatInfoVital.hpp       # 重要统计协议
│   └── rpcgen/                     # 自动生成的RPC代码
│       └── gnet/                   # 协议实现文件
│           ├── RemoteLog.inc
│           ├── RemoteLogVital.inc
│           ├── StatInfo.inc
│           ├── StatInfoVital.inc
│           ├── _depends_*.hpp      # 依赖文件
│           └── _protocols_.hpp     # 协议汇总
│
├── logservice/                     # 日志服务端 (C++)
│   ├── logservice.cpp              # 日志服务主程序
│   ├── logservice.conf             # 日志服务配置
│   ├── logserviceserver.cpp/.hpp   # UDP日志服务器
│   ├── logservicetcpserver.cpp/.hpp # TCP日志服务器
│   ├── logdispatch.cpp/.h          # 日志分发器
│   ├── remotelog.hpp               # 远程日志处理
│   ├── remotelogvital.hpp          # 重要日志处理
│   ├── statinfo.hpp                # 统计信息处理
│   ├── statinfovital.hpp           # 重要统计处理
│   ├── state.cxx/.hxx              # 状态管理
│   ├── stubs.cxx                   # 桩代码
│   ├── callid.hxx                  # 调用ID定义
│   ├── log.xml                     # 日志配置XML
│   ├── rpcalls.xml                 # RPC调用定义
│   ├── Makefile                    # 编译脚本
│   └── log*                        # 可执行文件和数据文件
│
├── Makefile                        # 主编译脚本
├── sizepolicy.conf                 # 大小策略配置
└── real.demo.txt                   # 演示文件
```

### 目录说明

| 目录/文件 | 类型 | 说明 |
|----------|------|------|
| **gnet.xml** | 协议定义 | 核心协议定义文件，包含所有Bean和Protocol |
| **gnet.*.xml** | 协议定义 | 各服务器专用协议定义 |
| **logclient/** | C++模块 | 嵌入到各服务器的日志客户端库 |
| **logservice/** | C++服务 | 独立的日志收集服务器 |
| **rpcgen/** | 生成代码 | 由 rpcgen.jar 自动生成的C++/Java代码 |

---

## 🔌 协议系统

### 协议定义架构

MT3 使用基于 XML 的协议定义系统，支持自动代码生成：

```xml
<!-- gnet.xml 示例 -->
<gnet>
    <!-- Bean定义：数据结构 -->
    <bean name="ServerAttr">
        <enum name="FLAG_DOUBLE_DROP" value="4"/>
        <enum name="FLAG_DOUBLE_SP" value="8"/>
        <variable name="flags" type="int"/>
        <variable name="load" type="byte"/>
        <variable name="extra" type="map" key="int" value="int"/>
    </bean>

    <!-- Protocol定义：通信协议 -->
    <protocol name="UserLoginArg" type="27">
        <variable name="account" type="string"/>
        <variable name="passwd" type="octets"/>
        <variable name="kickuser" type="byte"/>
        <variable name="sessionid" type="octets"/>
    </protocol>
</gnet>
```

### 协议文件分类

| 文件名 | 用途 | 主要内容 |
|--------|------|---------|
| **gnet.xml** | 核心协议 | ServerAttr, RoleForbid, MatrixPasswdArg, UserLoginArg 等 |
| **gnet.gate.xml** | 网关协议 | 客户端连接、心跳、加密相关协议 |
| **gnet.proxy.xml** | 代理协议 | 登录认证、角色管理、数据同步协议 |
| **gnet.authc.xml** | 认证协议 | 第三方认证对接协议 |
| **gnet.cross.xml** | 跨服协议 | 跨服战斗、数据交互协议 |
| **gnet.openau.xml** | OpenAU协议 | OpenAU平台对接协议 |
| **gnet.sdk.xml** | SDK协议 | SDK接入相关协议 |

### 数据类型映射

| XML类型 | C++类型 | Java类型 | 说明 |
|---------|---------|----------|------|
| **byte** | `char` | `byte` | 8位有符号整数 |
| **short** | `short` | `short` | 16位有符号整数 |
| **int** | `int` | `int` | 32位有符号整数 |
| **long** | `long long` | `long` | 64位有符号整数 |
| **float** | `float` | `float` | 32位浮点数 |
| **string** | `Octets` | `String` | UTF-8字符串 |
| **octets** | `Octets` | `OctetsStream` | 二进制数据流 |
| **list** | `std::vector<T>` | `ArrayList<T>` | 动态数组 |
| **map** | `std::map<K,V>` | `HashMap<K,V>` | 键值映射 |

### 代码生成流程

```bash
# 1. 修改协议定义
vim gnet.xml

# 2. 运行代码生成器
java -jar rpcgen.jar gnet.xml -o ../gate_server/gnet/
java -jar rpcgen.jar gnet.xml -o ../proxy_server/gnet/ -lang java

# 3. 编译项目
cd ../gate_server && make
cd ../proxy_server && ant compile
```

### 协议版本管理

- **版本号位置**: 各服务器配置文件中的 `version` 参数
- **兼容性检查**: 客户端与服务器版本必须一致
- **升级流程**:
  1. 修改协议定义
  2. 重新生成代码
  3. 更新版本号
  4. 重新编译部署

---

## 📝 日志系统

### 日志架构

```
┌──────────────┐  UDP/TCP   ┌──────────────┐
│ Gate Server  ├──────────►│              │
├──────────────┤            │              │
│ Proxy Server ├──────────►│  LogService  │──► 日志文件
├──────────────┤            │              │      /data/logs/
│ Game Server  ├──────────►│  (Port:      │      ├── game.log
├──────────────┤            │   11100 UDP  │      ├── login.log
│ Name Server  ├──────────►│   11101 TCP) │      ├── trade.log
├──────────────┤            │              │      └── error.log
│ ... 其他服务  ├──────────►│              │
└──────────────┘            └──────────────┘
```

### 日志客户端 (LogClient)

#### 功能特性

1. **双协议支持**: UDP (高性能) + TCP (可靠性)
2. **异步传输**: 非阻塞式日志发送
3. **缓冲机制**: 批量发送减少网络开销
4. **日志分级**: TRACE, DEBUG, INFO, WARN, ERROR, FATAL
5. **自动重连**: 连接断开自动恢复

#### 配置文件 (logclient.conf)

```ini
[LogClientManager]
type            = udp
port            = 11100
address         = 127.0.0.1

so_sndbuf       = 65536
so_rcvbuf       = 65536
ibuffermax      = 65536
obuffermax      = 1048576
accumulate      = 1048576

[LogClientTcpManager]
type            = tcp
port            = 11101
address         = 127.0.0.1

so_sndbuf       = 65536
so_rcvbuf       = 65536
ibuffermax      = 65536
obuffermax      = 1048576
accumulate      = 1048576
```

#### 使用示例 (C++)

```cpp
#include "logclient/glog.cpp"

// 初始化日志客户端
LogClientManager::GetInstance()->Initialize("logclient.conf");

// 发送普通日志
LOG_TRACE("Server starting...");
LOG_INFO("User %d logged in from IP %s", userId, ip.c_str());
LOG_WARN("Connection timeout: userId=%d", userId);
LOG_ERROR("Database query failed: %s", errorMsg.c_str());

// 发送重要日志 (RemoteLogVital)
LogClientManager::GetInstance()->SendVitalLog(
    LogLevel::ERROR,
    "critical_error",
    "System crash detected"
);

// 发送统计信息
StatInfo stat;
stat.online_users = 1234;
stat.cpu_usage = 45.2;
stat.memory_mb = 2048;
LogClientManager::GetInstance()->SendStatInfo(stat);
```

### 日志服务端 (LogService)

#### 功能特性

1. **集中收集**: 接收所有服务器的日志
2. **实时分发**: 按类型分发到不同文件
3. **日志轮转**: 按日期/大小自动轮转
4. **过滤规则**: 支持日志级别过滤
5. **统计监控**: 实时统计各服务器日志量

#### 配置文件 (logservice.conf)

```ini
[LogServiceServer]
type            = udp
port            = 11100
address         = 0.0.0.0
listen_backlog  = 100

so_sndbuf       = 65536
so_rcvbuf       = 65536
ibuffermax      = 65536
obuffermax      = 1048576
accumulate      = 1048576

[LogServiceTcpServer]
type            = tcp
port            = 11101
address         = 0.0.0.0
listen_backlog  = 100

so_sndbuf       = 65536
so_rcvbuf       = 65536
ibuffermax      = 65536
obuffermax      = 1048576
accumulate      = 1048576

[LogDispatch]
log_dir         = /data/logs
max_file_size   = 100MB
rotation_time   = daily
retention_days  = 30
```

#### 日志分类存储

| 日志文件 | 内容 | 保留时间 |
|---------|------|---------|
| **game.log** | 游戏逻辑日志 | 7天 |
| **login.log** | 登录认证日志 | 30天 |
| **trade.log** | 交易日志 | 永久 |
| **error.log** | 错误日志 | 30天 |
| **stat.log** | 统计信息 | 7天 |
| **vital.log** | 重要事件 | 永久 |

---

## 📄 核心文件说明

### gnet.xml - 核心协议定义

**文件路径**: `server/server/common/gnet.xml`

**主要内容**:

1. **Bean定义** (80+ 个数据结构):
   - ServerAttr - 服务器属性
   - RoleForbid - 角色封禁
   - UserLoginArg - 用户登录参数
   - MatrixPasswdArg - 矩阵密码参数
   - ...

2. **Protocol定义** (200+ 个协议):
   - 客户端 <-> 网关
   - 网关 <-> 代理
   - 代理 <-> 游戏服务器
   - 跨服通信
   - 数据库交互

**查看方式**:

```bash
# 统计Bean数量
grep -c '<bean name=' gnet.xml

# 统计Protocol数量
grep -c '<protocol name=' gnet.xml

# 查看特定Bean
grep -A 20 '<bean name="ServerAttr"' gnet.xml
```

### LogClient - 日志客户端库

**文件路径**: `server/server/common/logclient/`

**关键文件**:

1. **glog.cpp** - 日志封装主文件
   - 提供统一的日志接口
   - 封装 UDP/TCP 日志管理器
   - 支持格式化输出

2. **LogClientManager.cpp/.hpp** - UDP日志管理器
   - 高性能日志发送
   - 异步非阻塞
   - 自动缓冲

3. **LogClientTcpManager.cpp/.hpp** - TCP日志管理器
   - 可靠日志传输
   - 适用于重要日志
   - 自动重连

**编译方式**:

```bash
cd logclient
make clean && make

# 生成 liblogclient.a 静态库
# 其他服务器链接此库即可使用日志功能
```

### LogService - 日志服务端

**文件路径**: `server/server/common/logservice/`

**关键文件**:

1. **logservice.cpp** - 主程序
   - 初始化服务器
   - 启动事件循环
   - 信号处理

2. **logdispatch.cpp/.h** - 日志分发器
   - 解析日志协议
   - 分类写入文件
   - 日志轮转

**启动方式**:

```bash
cd logservice
./logservice logservice.conf

# 后台运行
nohup ./logservice logservice.conf > /dev/null 2>&1 &
```

---

## 🚀 使用指南

### 协议开发流程

#### 1. 定义新协议

编辑 `gnet.xml`:

```xml
<!-- 添加新Bean -->
<bean name="NewFeatureConfig">
    <variable name="featureId" type="int"/>
    <variable name="enabled" type="byte"/>
    <variable name="params" type="map" key="string" value="string"/>
</bean>

<!-- 添加新Protocol -->
<protocol name="NewFeatureRequest" type="10001">
    <variable name="userId" type="long"/>
    <variable name="featureId" type="int"/>
    <variable name="action" type="byte"/>
</protocol>

<protocol name="NewFeatureResponse" type="10002">
    <variable name="result" type="int"/>
    <variable name="config" type="NewFeatureConfig"/>
</protocol>
```

#### 2. 生成代码

```bash
# 为C++项目生成 (Gate/Proxy C++部分)
cd /path/to/rpcgen
java -jar rpcgen.jar ../common/gnet.xml -o ../gate_server/gnet/ -lang cpp

# 为Java项目生成 (Game Server)
java -jar rpcgen.jar ../common/gnet.xml -o ../game_server/gnet/ -lang java
```

#### 3. 使用生成的代码

**C++ 示例**:

```cpp
#include "gnet/NewFeatureRequest.hpp"
#include "gnet/NewFeatureResponse.hpp"

// 发送请求
NewFeatureRequest req;
req.userId = 123456;
req.featureId = 1001;
req.action = 1;
SendProtocol(req);

// 接收响应
void OnNewFeatureResponse(Protocol* p) {
    NewFeatureResponse* resp = dynamic_cast<NewFeatureResponse*>(p);
    if (resp->result == 0) {
        LOG_INFO("Feature enabled: %d", resp->config.featureId);
    }
}
```

**Java 示例**:

```java
import gnet.NewFeatureRequest;
import gnet.NewFeatureResponse;

// 发送请求
NewFeatureRequest req = new NewFeatureRequest();
req.userId = 123456L;
req.featureId = 1001;
req.action = (byte)1;
sendProtocol(req);

// 处理响应
public void onNewFeatureResponse(NewFeatureResponse resp) {
    if (resp.result == 0) {
        logger.info("Feature enabled: {}", resp.config.featureId);
    }
}
```

### 日志集成指南

#### 1. 编译日志客户端库

```bash
cd server/server/common/logclient
make clean && make

# 输出: liblogclient.a
```

#### 2. 链接到项目

在服务器 Makefile 中添加:

```makefile
LDFLAGS += -L$(COMMON_DIR)/logclient -llogclient
INCLUDES += -I$(COMMON_DIR)/logclient
```

#### 3. 初始化日志

在服务器启动代码中:

```cpp
#include "logclient/glog.cpp"

int main(int argc, char* argv[]) {
    // 初始化日志客户端
    if (!LogClientManager::GetInstance()->Initialize("logclient.conf")) {
        fprintf(stderr, "Failed to initialize log client\n");
        return 1;
    }

    LOG_INFO("Server started successfully");

    // ... 服务器主循环 ...

    // 关闭日志
    LogClientManager::GetInstance()->Shutdown();
    return 0;
}
```

#### 4. 部署日志服务

```bash
# 1. 配置 logservice.conf
vim logservice/logservice.conf

# 2. 启动日志服务
cd logservice
./logservice logservice.conf

# 3. 验证日志接收
tail -f /data/logs/game.log
```

---

## ⚙️ 配置说明

### sizepolicy.conf - 大小策略

```ini
# 数据结构大小限制配置
[SizePolicy]
max_string_length = 4096        # 最大字符串长度
max_list_size = 10000           # 最大列表元素数
max_map_size = 10000            # 最大映射元素数
max_octets_size = 1048576       # 最大二进制数据大小 (1MB)
```

**用途**: 防止恶意客户端发送超大数据包导致服务器内存溢出

### 日志配置最佳实践

#### logclient.conf 优化

```ini
[LogClientManager]
type            = udp
port            = 11100
address         = 127.0.0.1

# 生产环境建议配置
so_sndbuf       = 131072        # 增大发送缓冲 (128KB)
so_rcvbuf       = 131072
obuffermax      = 2097152       # 增大输出缓冲 (2MB)
accumulate      = 2097152

# 日志级别过滤 (可选)
min_log_level   = INFO          # 只发送INFO及以上级别
```

#### logservice.conf 优化

```ini
[LogDispatch]
log_dir         = /data/logs
max_file_size   = 500MB         # 单文件最大500MB
rotation_time   = daily         # 每日轮转
retention_days  = 30            # 保留30天

# 性能优化
write_buffer_size = 8192        # 写缓冲8KB
flush_interval  = 5             # 每5秒强制刷盘

# 压缩归档 (可选)
compress_old_logs = true
compression_format = gzip
```

---

## ❓ 常见问题

### Q1: 修改协议后客户端连接失败？

**原因**: 协议版本不匹配

**解决**:
```bash
# 1. 检查服务器版本号
grep "version" gate/gate.conf
grep "version" proxy/proxy.conf

# 2. 确保客户端使用相同版本的协议代码
# 3. 重新生成客户端协议代码
java -jar rpcgen.jar gnet.xml -o client/protocols/ -lang cpp

# 4. 重新编译客户端
```

### Q2: 日志服务接收不到日志？

**诊断步骤**:

```bash
# 1. 检查日志服务是否运行
ps aux | grep logservice
netstat -an | grep 11100

# 2. 检查防火墙
iptables -L -n | grep 11100

# 3. 检查日志客户端配置
cat logclient.conf
# 确认 address 指向正确的日志服务器IP

# 4. 测试网络连通性
nc -zuvw3 127.0.0.1 11100

# 5. 查看日志服务日志
tail -f /data/logs/logservice.log
```

### Q3: 如何添加新的协议文件？

**步骤**:

1. 创建新文件 `gnet.newmodule.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gnet>
    <bean name="NewModuleConfig">
        <!-- 定义内容 -->
    </bean>

    <protocol name="NewModuleRequest" type="20001">
        <!-- 定义内容 -->
    </protocol>
</gnet>
```

2. 在主协议文件中引入:

```xml
<!-- gnet.xml -->
<gnet>
    <!-- 包含新模块协议 -->
    <include file="gnet.newmodule.xml"/>
</gnet>
```

3. 重新生成代码:

```bash
java -jar rpcgen.jar gnet.xml -o target_dir/
```

### Q4: 协议类型号冲突怎么办？

**检测冲突**:

```bash
# 查找所有type定义
grep 'type="' gnet.xml gnet.*.xml | awk -F'"' '{print $2}' | sort -n | uniq -c | grep -v '^ *1 '

# 输出示例：
#   2 10003   <-- 表示type=10003被定义了2次
```

**解决**:

1. 使用不同的类型号范围：
   - 1-9999: 核心协议 (gnet.xml)
   - 10000-19999: 网关协议 (gnet.gate.xml)
   - 20000-29999: 代理协议 (gnet.proxy.xml)
   - 30000-39999: 跨服协议 (gnet.cross.xml)

2. 修改冲突的协议类型号

3. 重新生成代码并测试

### Q5: 如何优化日志性能？

**建议**:

1. **使用UDP日志** (适合高频日志):

```cpp
// 高频日志使用UDP
LOG_TRACE("Player moved: x=%d y=%d", x, y);
LOG_DEBUG("Item used: itemId=%d", itemId);
```

2. **重要日志使用TCP**:

```cpp
// 重要事件使用TCP日志
LogClientTcpManager::GetInstance()->SendVitalLog(
    LogLevel::ERROR,
    "payment_failed",
    "Payment transaction failed: orderId=" + orderId
);
```

3. **批量发送**:

```cpp
// 累积多条日志后一次发送
LogClientManager::GetInstance()->SetBatchSize(100);
LogClientManager::GetInstance()->SetFlushInterval(5); // 5秒
```

4. **异步日志**:

```cpp
// 使用异步日志避免阻塞主线程
LogClientManager::GetInstance()->SetAsyncMode(true);
```

---

## 📚 附录

### A. 协议类型号分配表

| 范围 | 用途 | 文件 |
|------|------|------|
| 1-99 | 系统核心协议 | gnet.xml |
| 100-999 | 登录认证协议 | gnet.xml |
| 1000-1999 | 角色管理协议 | gnet.xml |
| 2000-2999 | 背包物品协议 | gnet.xml |
| 3000-3999 | 战斗协议 | gnet.xml |
| 10000-10999 | 网关协议 | gnet.gate.xml |
| 20000-20999 | 代理协议 | gnet.proxy.xml |
| 30000-30999 | 跨服协议 | gnet.cross.xml |
| 40000-40999 | 认证协议 | gnet.authc.xml |
| 50000-50999 | SDK协议 | gnet.sdk.xml |

### B. 日志级别定义

| 级别 | 数值 | 用途 | 示例 |
|------|------|------|------|
| **TRACE** | 0 | 详细追踪信息 | 函数进入/退出 |
| **DEBUG** | 1 | 调试信息 | 变量值、中间状态 |
| **INFO** | 2 | 一般信息 | 用户登录、任务完成 |
| **WARN** | 3 | 警告信息 | 连接超时、重试 |
| **ERROR** | 4 | 错误信息 | 操作失败、异常 |
| **FATAL** | 5 | 致命错误 | 系统崩溃 |

### C. 编译依赖

**logclient 编译依赖**:

```bash
# 系统库
- pthread
- rt (实时扩展)
- log4cpp

# 本地库
- libio.a (IO库)
- libsecurity.a (安全库)
```

**Makefile 示例**:

```makefile
INCLUDES = -I. -I../.. -I/usr/local/include
LDFLAGS = -L/usr/local/lib -llog4cpp -lpthread -lrt

OBJS = glog.o log.o logclient.o LogClientManager.o LogClientTcpManager.o

liblogclient.a: $(OBJS)
	ar rcs $@ $(OBJS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f *.o *.a
```

### D. 相关文档

- [Server 总体架构分析](../../docs/server-directory-analysis-report.md)
- [Gate Server 技术文档](../gate_server/docs/README.md)
- [Proxy Server 技术文档](../proxy_server/docs/README.md)
- [Game Server 技术文档](../game_server/docs/README.md)

### E. 联系方式

- **技术支持**: MT3服务器开发组
- **文档维护**: MT3技术文档团队
- **问题反馈**: 请通过内部问题跟踪系统提交

---

## 📝 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| v1.0 | 2025-11-20 | 初始版本，完整的Common模块技术文档 |

---

**文档结束**

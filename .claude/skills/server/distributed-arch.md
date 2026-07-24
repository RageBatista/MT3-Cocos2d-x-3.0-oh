---
name: distributed-arch
version: 1.2.0
priority: medium
category: server
description: |
  MT3分布式微服务架构技能。涵盖服务模块设计、跨服通信、负载均衡和高可用配置。
  触发词: 分布式, 微服务, 架构, 跨服, 负载均衡, 高可用, 网关, game_server, Auany, GameServer, SceneServer, DBServer
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
---

# 分布式架构技能 (MT3 服务器端)

**版本**: v1.2.0
**最后更新**: 2026-04-11

---

## 🏗️ 四层架构概览

### 架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      玩家客户端层（Client Layer）                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │  PC 客户端    │  │  Web/H5 端   │  │  移动端       │                 │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                 │
└─────────┼──────────────────┼──────────────────┼─────────────────────────┘
          │                  │                  │
          ↓ TCP/UDP          ↓ WebSocket       ↓ TCP
┌─────────────────────────────────────────────────────────────────────────┐
│                       网关层（Gateway Layer）                            │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │  gateway (网关服务器) - 连接管理、协议加密、负载均衡          │     │
│  │  gws (WebSocket 网关) - Web 端连接支持                        │     │
│  └──────────────────────────────────────────────────────────────┘     │
└─────────┬───────────────────────────────────────────────────────────────┘
          │ RPC/Jelly
          ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                       主控层（Control Layer）                            │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │  jmxc (主控服务器) - 集群协调、登录认证、全局配置管理        │     │
│  └──────────────────────────────────────────────────────────────┘     │
└─────────┬───────────────────────────────────────────────────────────────┘
          │ 服务分发
          ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                    游戏逻辑层（Game Logic Layer）                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ gdelivery   │  │ gfaction    │  │ gtransaction│  │ gpvp        │ │
│  │ (交付服务器) │  │ (帮派服务器) │  │ (交易服务器) │  │ (PVP服务器) │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │ glink       │  │ gprovider   │  │ gtradestart │                  │
│  │ (跨服连接)  │  │ (资源提供)  │  │ (交易启动)  │                  │
│  └─────────────┘  └─────────────┘  └─────────────┘                  │
└─────────┬───────────────────────────────────────────────────────────────┘
          │ 数据持久化
          ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                      数据层（Data Layer）                                │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │  XDB (文件数据库) - 基于 monkeyking 引擎的持久化存储          │     │
│  │  - B+ 树索引                                                  │     │
│  │  - 事务支持 (ACID)                                           │     │
│  │  - xbean 数据实体                                            │     │
│  └──────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘
```

### 层次职责

| 层次 | 职责 | 关键组件 |
|------|------|----------|
| **客户端层** | 玩家交互、渲染展示 | PC/Web/移动客户端 |
| **网关层** | 连接管理、协议处理、安全防护 | gateway, gws |
| **主控层** | 集群协调、认证授权、配置管理 | jmxc |
| **逻辑层** | 游戏业务逻辑处理 | gdelivery, gfaction, gpvp 等 |
| **数据层** | 数据持久化、缓存管理 | XDB, monkeyking |

---

## 🎮 核心服务器详解

### 1. jmxc - 主控服务器 ⭐⭐⭐⭐⭐

**职责**: 游戏服务器集群的核心控制节点

```yaml
核心功能:
  - 服务器集群启动协调
  - 玩家登录认证与分发
  - 全局配置管理
  - 服务器状态监控
  - RPC 消息路由

配置文件: jmxc.xml
启动命令: java -jar jmxc.jar -conf jmxc.xml
JMX监控: java -Dcom.sun.management.jmxremote.port=9999 -jar jmxc.jar

关键配置:
  <jmxc>
    <bind port="29001"/>           <!-- 服务端口 -->
    <maxConnections>10000</maxConnections>
    <sessionTimeout>300000</sessionTimeout>
    <servers>
      <server name="gdelivery" address="127.0.0.1:29002"/>
      <server name="gfaction" address="127.0.0.1:29003"/>
    </servers>
  </jmxc>
```

### 2. gateway - 网关服务器 ⭐⭐⭐⭐⭐

**职责**: 玩家客户端连接的第一道入口

```yaml
核心功能:
  - 接收客户端 TCP/UDP 连接
  - 协议加密与解密 (ARC4 + MD5)
  - 连接限流与防护
  - 消息转发到后端服务器
  - 心跳检测与断线重连

配置文件: gateway.xml
启动命令: java -Xmx1g -jar gateway.jar -conf gateway.xml

关键配置:
  <gateway>
    <listen port="29000"/>         <!-- 客户端连接端口 -->
    <maxConnections>50000</maxConnections>
    <heartbeat interval="30000"/>
    <encryption algorithm="ARC4"/>
    <upstream server="jmxc" address="127.0.0.1:29001"/>
  </gateway>

性能指标:
  - 单实例支持: ~10,000 并发连接
  - 消息吞吐: ~100,000 msg/s
```

### 3. gdelivery - 交付服务器 ⭐⭐⭐⭐⭐

**职责**: 核心游戏逻辑处理服务器

```yaml
核心功能:
  - 玩家移动、战斗、技能释放
  - 物品交易、装备强化
  - 任务系统、副本管理
  - NPC 交互、怪物 AI
  - 地图场景管理

配置文件: gdelivery.xml
启动命令: java -Xmx2g -jar gdelivery.jar -conf gdelivery.xml

关键配置:
  <gdelivery>
    <bind port="29002"/>
    <scenes>
      <scene id="1001" name="新手村" capacity="1000"/>
      <scene id="1002" name="长安城" capacity="5000"/>
    </scenes>
    <xdb path="mkdb" cacheCapacity="50000"/>
  </gdelivery>
```

### 4. gfaction - 帮派服务器 ⭐⭐⭐⭐

**职责**: 帮派系统专用服务器

```yaml
核心功能:
  - 帮派创建、解散、合并
  - 成员管理（职位、权限、贡献度）
  - 帮派战争、攻城战
  - 帮派仓库、资金管理
  - 帮派技能、建筑升级

配置文件: gfaction.xml
启动命令: java -jar gfaction.jar -conf gfaction.xml

数据模型:
  <xbean name="Faction">
    <variable name="id" type="long"/>
    <variable name="name" type="string"/>
    <variable name="level" type="int"/>
    <variable name="members" type="map" key="long" value="FactionMember"/>
    <variable name="fund" type="long"/>
  </xbean>
```

### 5. glink - 跨服连接服务器 ⭐⭐⭐⭐

**职责**: 实现跨服互动的桥接服务器

```yaml
核心功能:
  - 跨服聊天（世界频道、帮派频道）
  - 跨服组队、跨服副本
  - 跨服拍卖行
  - 跨服排行榜同步
  - 跨服好友系统

配置文件: glink.xml
启动命令: java -jar glink.jar -conf glink.xml

跨服通信流程:
  Server A → glink → Server B
       ↓         ↓
    玩家 X    玩家 Y

关键配置:
  <glink>
    <bind port="29005"/>
    <clusters>
      <cluster name="cluster1">
        <server id="1" address="192.168.1.10:29001"/>
        <server id="2" address="192.168.1.11:29001"/>
      </cluster>
    </clusters>
  </glink>
```

### 6. gpvp - PVP 竞技服务器 ⭐⭐⭐⭐

**职责**: 玩家对战系统专用服务器

```yaml
核心功能:
  - 竞技场匹配与战斗
  - 天梯排位系统
  - 战场活动（攻城战、帮派战）
  - 跨服 PVP 赛事
  - 战绩记录与排行榜

匹配算法: ELO Rating
  新玩家初始分: 1000
  K因子: 32 (低段位), 16 (高段位)

配置文件: gpvp.xml
启动命令: java -jar gpvp.jar -conf gpvp.xml
```

### 7. 其他服务器

| 服务器 | 职责 | 优先级 |
|--------|------|--------|
| **gtransaction** | 玩家交易系统（ACID 保证） | ⭐⭐⭐ |
| **gtradestart** | 交易系统初始化与管理 | ⭐⭐⭐ |
| **gprovider** | 动态资源加载与配置分发 | ⭐⭐⭐ |
| **gws** | WebSocket 服务器（H5/Web 端） | ⭐⭐⭐ |

---

## 🔗 服务间通信

### RPC 通信机制

```
┌─────────────┐                    ┌─────────────┐
│   Client    │                    │   Server    │
│  (调用方)    │                    │  (服务方)    │
└──────┬──────┘                    └──────┬──────┘
       │                                  │
       │  1. 序列化请求                    │
       │  ────────────────────────────→   │
       │                                  │
       │                     2. 反序列化   │
       │                        处理请求   │
       │                                  │
       │  3. 序列化响应                    │
       │  ←────────────────────────────   │
       │                                  │
       │  4. 反序列化响应                  │
       │     返回结果                      │
       ↓                                  ↓
```

### 通信协议示例

```java
// 定义 RPC 接口 (gnet.xml)
<protocol id="2001" name="GetPlayerInfoRequest">
    <field name="playerId" type="long"/>
</protocol>

<protocol id="2002" name="GetPlayerInfoResponse">
    <field name="success" type="boolean"/>
    <field name="name" type="string"/>
    <field name="level" type="int"/>
    <field name="faction" type="string"/>
</protocol>

// 服务端处理
public class GetPlayerInfoHandler implements RpcHandler {
    @Override
    public void handle(RpcContext ctx, GetPlayerInfoRequest req) {
        long playerId = req.getPlayerId();

        // 查询数据库
        xbean.Role role = xtable.Role.get().select(playerId);

        // 构造响应
        GetPlayerInfoResponse resp = new GetPlayerInfoResponse();
        resp.setSuccess(role != null);
        if (role != null) {
            resp.setName(role.getName());
            resp.setLevel(role.getLevel());
        }

        ctx.reply(resp);
    }
}
```

### 服务注册与发现

```yaml
服务注册流程:
  1. 服务启动时向 jmxc 注册
  2. jmxc 维护服务列表
  3. 其他服务通过 jmxc 发现目标服务

服务发现配置:
  <discovery>
    <registry type="jmxc" address="127.0.0.1:29001"/>
    <heartbeat interval="10000"/>
    <timeout>30000</timeout>
  </discovery>
```

---

## 📊 服务器启动顺序

### 标准启动流程

```
┌──────────────────────────────────────────────────────────────┐
│                     服务器启动顺序                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  第一阶段: 基础服务                                          │
│  ┌─────────────┐                                            │
│  │ 1. jmxc     │ ← 主控服务器（必须最先启动）               │
│  └──────┬──────┘                                            │
│         ↓                                                    │
│  第二阶段: 数据服务                                          │
│  ┌─────────────┐                                            │
│  │ 2. monkeyking│ ← XDB 数据库引擎（嵌入式，随服务启动）    │
│  └──────┬──────┘                                            │
│         ↓                                                    │
│  第三阶段: 核心游戏服务                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ 3. gdelivery│  │ 4. gfaction │  │ 5. gpvp     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         ↓                ↓                ↓                │
│  第四阶段: 辅助服务                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ 6. glink    │  │ 7. gprovider│  │ 8. gtransac │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         ↓                ↓                ↓                │
│  第五阶段: 网关服务                                          │
│  ┌─────────────┐  ┌─────────────┐                          │
│  │ 9. gateway  │  │ 10. gws     │ ← 最后启动，开放连接     │
│  └─────────────┘  └─────────────┘                          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 启动脚本示例

```bash
#!/bin/bash
# start-cluster.sh - 服务器集群启动脚本

# 配置
JAVA_OPTS="-Xmx2g -XX:+UseG1GC"
LOG_DIR="/var/log/mt3"

# 1. 启动主控服务器
echo "Starting jmxc..."
java $JAVA_OPTS -jar jmxc.jar -conf jmxc.xml > $LOG_DIR/jmxc.log 2>&1 &
sleep 5

# 2. 启动游戏服务器
echo "Starting game servers..."
java $JAVA_OPTS -jar gdelivery.jar -conf gdelivery.xml > $LOG_DIR/gdelivery.log 2>&1 &
java $JAVA_OPTS -jar gfaction.jar -conf gfaction.xml > $LOG_DIR/gfaction.log 2>&1 &
java $JAVA_OPTS -jar gpvp.jar -conf gpvp.xml > $LOG_DIR/gpvp.log 2>&1 &
sleep 10

# 3. 启动辅助服务
echo "Starting auxiliary servers..."
java $JAVA_OPTS -jar glink.jar -conf glink.xml > $LOG_DIR/glink.log 2>&1 &
java $JAVA_OPTS -jar gprovider.jar -conf gprovider.xml > $LOG_DIR/gprovider.log 2>&1 &
sleep 5

# 4. 最后启动网关
echo "Starting gateway..."
java $JAVA_OPTS -jar gateway.jar -conf gateway.xml > $LOG_DIR/gateway.log 2>&1 &

echo "All servers started."
```

---

## 🔧 负载均衡策略

### 场景分线

```yaml
分线策略:
  - 每个场景支持多个分线
  - 玩家自动分配到负载较低的分线
  - 支持跨分线切换

配置示例:
  <scene id="1002" name="长安城">
    <line id="1" capacity="1000"/>
    <line id="2" capacity="1000"/>
    <line id="3" capacity="1000"/>
    <balance strategy="least-connections"/>
  </scene>

分配算法:
  1. 获取所有可用分线
  2. 计算每个分线当前负载
  3. 选择负载最低的分线
  4. 如果负载差异 < 10%，随机选择
```

### 服务器水平扩展

```
                    ┌─────────────┐
                    │   Load      │
                    │  Balancer   │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        ↓                  ↓                  ↓
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  gdelivery-1  │  │  gdelivery-2  │  │  gdelivery-3  │
│  场景 1001-1500│  │  场景 1501-2000│  │  场景 2001-2500│
└───────────────┘  └───────────────┘  └───────────────┘

扩展策略:
  1. 按场景分片（Scene Sharding）
  2. 按玩家ID分片（Player Sharding）
  3. 按功能分离（Feature Isolation）
```

---

## 🛡️ 容错与恢复

### 服务健康检查

```java
// 健康检查接口
public class HealthChecker {
    private static final int TIMEOUT = 5000;

    public HealthStatus check(String serverAddress) {
        try {
            // 发送心跳请求
            HeartbeatRequest req = new HeartbeatRequest();
            HeartbeatResponse resp = rpcClient.call(serverAddress, req, TIMEOUT);

            return new HealthStatus(
                resp.isHealthy(),
                resp.getLoad(),
                resp.getConnections()
            );
        } catch (TimeoutException e) {
            return HealthStatus.UNHEALTHY;
        }
    }
}
```

### 故障转移

```yaml
故障检测:
  - 心跳超时: 3次连续超时判定为故障
  - 超时阈值: 10秒
  - 检查间隔: 5秒

故障转移流程:
  1. 检测到服务器故障
  2. 从服务列表中移除故障节点
  3. 将流量重定向到健康节点
  4. 通知运维人员
  5. 故障节点恢复后自动重新加入

配置示例:
  <failover>
    <detection>
      <heartbeat timeout="10000" interval="5000"/>
      <threshold failures="3"/>
    </detection>
    <recovery>
      <auto enabled="true"/>
      <delay>30000</delay>
    </recovery>
  </failover>
```

---

## 📈 监控与运维

### JMX 监控

```java
// 暴露 JMX 指标
@MBean
public class ServerMetrics {
    @ManagedAttribute
    public int getOnlineCount() {
        return sessionManager.getOnlineCount();
    }

    @ManagedAttribute
    public long getMessageThroughput() {
        return messageCounter.getThroughput();
    }

    @ManagedAttribute
    public double getCpuUsage() {
        return systemMonitor.getCpuUsage();
    }
}

// 启动时启用 JMX
java -Dcom.sun.management.jmxremote \
     -Dcom.sun.management.jmxremote.port=9999 \
     -Dcom.sun.management.jmxremote.authenticate=false \
     -jar server.jar
```

### 关键指标

| 指标 | 描述 | 告警阈值 |
|------|------|----------|
| **在线人数** | 当前连接的玩家数 | > 90% 容量 |
| **消息吞吐** | 每秒处理消息数 | < 1000 msg/s |
| **响应延迟** | 平均请求响应时间 | > 500ms |
| **CPU 使用率** | 服务器 CPU 占用 | > 80% |
| **内存使用率** | JVM 堆内存占用 | > 85% |
| **GC 频率** | 垃圾回收频率 | Full GC > 1/min |

### 日志收集

```yaml
日志级别:
  - ERROR: 系统错误，需要立即处理
  - WARN: 警告信息，可能影响功能
  - INFO: 重要业务信息
  - DEBUG: 调试信息（生产环境关闭）

日志格式:
  [时间] [级别] [服务名] [线程] [类名] - 消息

示例:
  [2026-01-01 10:30:15] [INFO] [gdelivery] [main] [PlayerService] - 玩家登录: id=12345
  [2026-01-01 10:30:16] [ERROR] [gdelivery] [rpc-1] [RpcHandler] - RPC调用失败: timeout
```

---

## 🎯 实践项目

### 初级: 服务器状态查看器

```
目标: 编写工具查看所有服务器状态
技能:
  - 连接 jmxc 获取服务列表
  - 向每个服务发送心跳请求
  - 显示在线人数、负载等信息
预计时间: 3-5天
```

### 中级: 跨服消息转发

```
目标: 实现简单的跨服聊天功能
技能:
  - 理解 glink 跨服通信机制
  - 实现消息路由逻辑
  - 处理服务器不可用情况
预计时间: 1-2周
```

### 高级: 服务器扩容方案

```
目标: 设计并实现服务器动态扩容
技能:
  - 服务注册与发现
  - 负载均衡策略
  - 数据分片与迁移
  - 无缝扩容验证
预计时间: 3-4周
```

---

## ✅ 技能自测清单

### 架构理解
- [ ] 能够画出四层架构图
- [ ] 理解每个服务器的职责
- [ ] 知道服务器启动顺序及原因

### 配置能力
- [ ] 能够修改服务器配置
- [ ] 能够添加新的服务节点
- [ ] 能够配置负载均衡策略

### 排障能力
- [ ] 能够定位服务间通信问题
- [ ] 能够分析服务器日志
- [ ] 能够处理服务器故障转移

### 设计能力
- [ ] 能够设计新的服务模块
- [ ] 能够规划扩容方案
- [ ] 能够优化分布式性能

---

## 📚 相关文档

- [gnet 网络框架](gnet-framework.md) - RPC 通信详解
- [xbean 数据系统](xbean-system.md) - 数据持久化
- [Java 开发技能](java-development.md) - Java 编程基础
- [Ant 构建技能](ant-build.md) - 服务器编译
- [服务器 README](../../../server/README.md) - 工具集总览

---

## 📝 更新日志

### v1.0.0 (2026-01-01)
- 初始版本
- 四层架构概览
- 10 个核心服务器详解
- 服务间通信机制
- 启动顺序与脚本
- 负载均衡策略
- 容错与恢复
- 监控与运维
- 实践项目

---

**维护者**: 技术委员会
**下次审查**: 2026-04-01

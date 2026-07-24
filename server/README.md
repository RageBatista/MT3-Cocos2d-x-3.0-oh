# MT3 游戏服务器工具集总览

> **梦幻西游 MG 版本** - 服务器端工具完整文档
>
> 本文档提供所有服务器工具的快速导航、使用场景说明和技术架构概览

---

## 📋 目录

- [1. 工具分类与快速导航](#1-工具分类与快速导航)
- [2. 核心游戏服务器 (Game Servers)](#2-核心游戏服务器-game-servers)
- [3. 数据库工具 (Database Tools)](#3-数据库工具-database-tools)
- [4. 开发与代码生成工具 (Development Tools)](#4-开发与代码生成工具-development-tools)
- [5. 运维与测试工具 (Operations & Testing)](#5-运维与测试工具-operations--testing)
- [6. 技术架构总览](#6-技术架构总览)
- [7. 快速开始指南](#7-快速开始指南)
- [8. 常见问题 FAQ](#8-常见问题-faq)

---

## 1. 工具分类与快速导航

### 1.1 按功能分类

| 分类 | 工具数量 | 用途 |
|-----|---------|------|
| 🎮 **核心游戏服务器** | 9 个 | 游戏业务逻辑处理（登录、交易、帮派、PVP 等） |
| 💾 **数据库工具** | 4 个 | 数据库操作、合并、清理、测试 |
| 🛠️ **开发工具** | 2 个 | 代码生成、配置转换 |
| ⚙️ **运维工具** | 1 个 | 日志收集与分析 |

**工具总数**: 16 个

### 1.2 按使用频率分类

| 优先级 | 工具 | 使用场景 |
|-------|------|---------|
| 🔴 **必需** | monkeyking, jmxc | 数据库引擎 + 主控服务器（必须运行） |
| 🟡 **常用** | gdelivery, gateway | 游戏交付服务器 + 网关（高频使用） |
| 🟢 **按需** | xmerge, convxml | 合服、配置生成（运营需要时使用） |
| ⚪ **辅助** | logs, xdbench | 日志分析、性能测试（开发调试） |

---

## 2. 核心游戏服务器 (Game Servers)

### 2.1 jmxc - 游戏主控服务器 ⭐⭐⭐⭐⭐
📍 **文档**: [tools/jmxc/README.md](tools/jmxc/README.md)

**用途**: 游戏服务器集群的核心控制节点

**使用场景**:
- ✅ 游戏服务器集群启动（必需运行）
- ✅ 服务器间通信协调（RPC 调度）
- ✅ 玩家登录认证与分发
- ✅ 全局配置管理
- ✅ 服务器状态监控

**关键特性**:
- 基于 Jelly/RPC 框架的分布式架构
- 支持多服务器负载均衡
- 提供 JMX 监控接口
- 角色缓存与会话管理

**典型命令**:
```bash
# 启动主控服务器
java -jar jmxc.jar -conf jmxc.xml

# 带 JMX 监控启动
java -Dcom.sun.management.jmxremote.port=9999 -jar jmxc.jar
```

---

### 2.2 gateway - 游戏网关服务器 ⭐⭐⭐⭐⭐
📍 **文档**: [tools/gateway/README.md](tools/gateway/README.md)

**用途**: 玩家客户端连接的第一道入口

**使用场景**:
- ✅ 接收客户端 TCP/UDP 连接
- ✅ 协议加密与解密
- ✅ 连接限流与防护
- ✅ 转发消息到后端游戏服务器
- ✅ 维护客户端在线状态

**关键特性**:
- 高并发连接处理（万级在线）
- 协议安全加密（ARC4 + MD5）
- 多实例负载均衡
- 心跳检测与断线重连

**典型命令**:
```bash
# 启动网关服务器
java -Xmx1g -jar gateway.jar -conf gateway.xml

# 指定监听端口
java -jar gateway.jar -conf gateway.xml -port 29000
```

---

### 2.3 gdelivery - 游戏交付服务器 ⭐⭐⭐⭐⭐
📍 **文档**: [tools/gdelivery/README.md](tools/gdelivery/README.md)

**用途**: 核心游戏逻辑处理服务器

**使用场景**:
- ✅ 玩家移动、战斗、技能释放
- ✅ 物品交易、装备强化
- ✅ 任务系统、副本管理
- ✅ NPC 交互、怪物 AI
- ✅ 地图场景管理

**关键特性**:
- 角色数据持久化（XDB）
- 场景分线管理
- 事件驱动架构
- 状态同步机制

**典型命令**:
```bash
# 启动交付服务器
java -Xmx2g -jar gdelivery.jar -conf gdelivery.xml

# 带性能监控启动
java -Xmx2g -XX:+PrintGCDetails -jar gdelivery.jar
```

---

### 2.4 gfaction - 帮派服务器 ⭐⭐⭐⭐
📍 **文档**: [tools/gfaction/README.md](tools/gfaction/README.md)

**用途**: 帮派系统专用服务器

**使用场景**:
- ✅ 帮派创建、解散、合并
- ✅ 成员管理（职位、权限、贡献度）
- ✅ 帮派战争、攻城战
- ✅ 帮派仓库、资金管理
- ✅ 帮派技能、建筑升级

**关键特性**:
- 独立帮派数据库
- 实时成员在线状态同步
- 帮派活动事件调度
- 跨服帮派战支持

**典型命令**:
```bash
# 启动帮派服务器
java -jar gfaction.jar -conf gfaction.xml
```

---

### 2.5 glink - 跨服连接服务器 ⭐⭐⭐⭐
📍 **文档**: [tools/glink/README.md](tools/glink/README.md)

**用途**: 实现跨服互动的桥接服务器

**使用场景**:
- ✅ 跨服聊天（世界频道、帮派频道）
- ✅ 跨服组队、跨服副本
- ✅ 跨服拍卖行
- ✅ 跨服排行榜同步
- ✅ 跨服好友系统

**关键特性**:
- 服务器间消息路由
- 玩家身份跨服验证
- 数据同步与一致性保证
- 支持动态服务器注册

**典型命令**:
```bash
# 启动跨服连接服务器
java -jar glink.jar -conf glink.xml
```

---

### 2.6 gprovider - 游戏资源提供服务器 ⭐⭐⭐
📍 **文档**: [tools/gprovider/README.md](tools/gprovider/README.md)

**用途**: 动态资源加载与配置分发

**使用场景**:
- ✅ 游戏配置表热更新（怪物、道具、技能）
- ✅ 资源文件分发（地图数据、模型资源）
- ✅ 活动配置动态加载
- ✅ 版本管理与灰度发布

**关键特性**:
- HTTP/RPC 双协议支持
- 配置文件增量更新
- 版本校验与回滚
- 缓存与 CDN 集成

**典型命令**:
```bash
# 启动资源提供服务器
java -jar gprovider.jar -conf gprovider.xml -port 8080
```

---

### 2.7 gtransaction - 交易服务器 ⭐⭐⭐
📍 **文档**: [tools/gtransaction/README.md](tools/gtransaction/README.md)

**用途**: 玩家交易系统专用服务器

**使用场景**:
- ✅ 玩家间直接交易（面对面交易）
- ✅ 交易行/拍卖行系统
- ✅ 寄售系统（摆摊）
- ✅ 交易锁定与安全验证
- ✅ 交易日志与审计

**关键特性**:
- 事务性交易保证（ACID）
- 物品锁定机制
- 交易历史记录
- 防刷防欺诈检测

**典型命令**:
```bash
# 启动交易服务器
java -jar gtransaction.jar -conf gtransaction.xml
```

---

### 2.8 gtradestart - 交易启动服务器 ⭐⭐⭐
📍 **文档**: [tools/gtradestart/README.md](tools/gtradestart/README.md)

**用途**: 交易系统初始化与管理

**使用场景**:
- ✅ 交易系统启动与配置加载
- ✅ 交易服务器集群管理
- ✅ 交易数据迁移与备份
- ✅ 交易状态监控

**关键特性**:
- 交易服务器自动发现
- 配置热更新
- 交易统计与报表

**典型命令**:
```bash
# 启动交易管理服务器
java -jar gtradestart.jar -conf gtradestart.xml
```

---

### 2.9 gpvp - PVP 竞技服务器 ⭐⭐⭐⭐
📍 **文档**: [tools/gpvp/README.md](tools/gpvp/README.md)

**用途**: 玩家对战（PVP）系统专用服务器

**使用场景**:
- ✅ 竞技场匹配与战斗
- ✅ 天梯排位系统
- ✅ 战场活动（攻城战、帮派战）
- ✅ 跨服 PVP 赛事
- ✅ 战绩记录与排行榜

**关键特性**:
- ELO 匹配算法
- 实时战斗同步
- 回放系统
- 防作弊检测

**典型命令**:
```bash
# 启动 PVP 服务器
java -jar gpvp.jar -conf gpvp.xml
```

---

### 2.10 gws - WebSocket 服务器 ⭐⭐⭐
📍 **文档**: [tools/gws/README.md](tools/gws/README.md)

**用途**: Web 客户端连接支持

**使用场景**:
- ✅ H5/Web 端游戏接入
- ✅ 微信小游戏支持
- ✅ 管理后台实时通信
- ✅ 跨平台消息推送

**关键特性**:
- WebSocket 协议支持
- HTTP 长轮询降级
- 跨域资源共享（CORS）
- Token 认证机制

**典型命令**:
```bash
# 启动 WebSocket 服务器
java -jar gws.jar -conf gws.xml -port 8080
```

---

## 3. 数据库工具 (Database Tools)

### 3.1 monkeyking - XDB 数据库引擎 ⭐⭐⭐⭐⭐
📍 **文档**: [tools/monkeyking/README.md](tools/monkeyking/README.md)

**用途**: XDB 文件数据库核心引擎与代码生成器

**使用场景**:
- ✅ 从 xdb.xml 生成 XBean/XTable Java 代码
- ✅ 数据库模式验证与检查
- ✅ 数据库结构升级与迁移
- ✅ XDB 引擎库（monkeyking.jar）

**关键特性**:
- 文件数据库引擎（无需 MySQL/Oracle）
- 事务支持（ACID 保证）
- 自动代码生成（XBean/XTable）
- 热备份与恢复

**典型命令**:
```bash
# 生成 XBean/XTable 代码
java -jar monkeyking.jar xdb.xml -noverify

# 验证数据库结构
java -jar monkeyking.jar xdb.xml -checkonly

# 启动数据库引擎（嵌入式使用）
# 无需单独启动，集成在游戏服务器中
```

---

### 3.2 xmerge - 数据库合并工具 ⭐⭐⭐⭐
📍 **文档**: [tools/xmerge/README.md](tools/xmerge/README.md)

**用途**: 游戏服务器合并（合服）的数据库整合工具

**使用场景**:
- ✅ 游戏合服数据整合
- ✅ 跨服数据迁移
- ✅ 测试环境数据合并
- ✅ 键冲突自动处理

**关键特性**:
- 零数据损失合并
- 自定义冲突处理逻辑（IMerge 接口）
- 自动键重分配（IAllocator）
- 外键完整性验证（validator）

**典型命令**:
```bash
# 检查冲突（不合并）
java -cp mylogic.jar -jar xmerge.jar -conf xmerge.xml \
     -srcdb /data/server1/xdb -destdb /data/server2/xdb -check

# 执行合并
java -Xmx2g -cp mylogic.jar -jar xmerge.jar -conf xmerge.xml \
     -srcdb /data/server1/xdb -destdb /data/server2/xdb

# 外键验证
java -jar validator.jar -v result_db -output foreign_db
```

---

### 3.3 xclear - 数据库清理工具 ⭐⭐⭐
📍 **文档**: [tools/xclear/README.md](tools/xclear/README.md)

**用途**: mkdb 数据库清理与重置工具

**使用场景**:
- ✅ 开发测试环境数据库重置
- ✅ 数据库损坏修复
- ✅ 版本升级前清理旧数据
- ✅ 初始化新环境数据库

**关键特性**:
- 安全清理（源数据库不修改）
- 批处理自动化（run.bat）
- 配置验证（gsx.mkdb.xml）
- 备份与恢复支持

**典型命令**:
```bash
# Windows 批处理执行
run.bat

# 手动执行清理
del /f /q mkdb\mkdb.inuse
rd /s /q mkdb\log
rd /s /q mkdb\table
mkdir mkdb\log
mkdir mkdb\table
```

---

### 3.4 xdbench - 性能基准测试工具 ⭐⭐⭐
📍 **文档**: [tools/xdbench/README.md](tools/xdbench/README.md)

**用途**: XDB 数据库性能测试与优化

**使用场景**:
- ✅ 数据库性能基准测试（TPS、延迟）
- ✅ 压力测试与容量规划
- ✅ 配置参数调优验证
- ✅ 性能回归测试

**关键特性**:
- 真实游戏数据结构测试
- 多场景测试（Cache Miss、Memory、Ostream）
- 并发事务测试（10 万级）
- 性能指标收集（TPS ~50,000/s）

**典型命令**:
```bash
# 编译测试代码
ant compile

# 运行 AddStorageMiss 测试
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss

# 性能调优后重新测试
# 修改 xdb.xml 配置参数后
ant clean && ant compile
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss
```

---

## 4. 开发与代码生成工具 (Development Tools)

### 4.1 convxml - XML 到 Java 代码生成器 ⭐⭐⭐⭐
📍 **文档**: [tools/convxml/README.md](tools/convxml/README.md)

**用途**: 游戏配置 XML 转换为 Java Bean 类

**使用场景**:
- ✅ 策划配置表自动生成代码
- ✅ Excel → XML → Java Bean 流水线
- ✅ 配置数据结构类型安全
- ✅ 服务端/客户端配置分离

**关键特性**:
- Freemarker 模板驱动
- 类型安全的 getter/setter
- 支持多种数据类型（vector, set, map）
- 数据验证（min/max 范围）
- Excel 列映射（fromCol 属性）

**典型命令**:
```bash
# 生成完整代码（包含加载逻辑）
java -jar convxml.jar config.xml src/gen templates

# 仅生成 Bean 定义（不生成加载逻辑）
java -jar convxml.jar config.xml src/gen templates defineOnly

# 批处理脚本
./gen-config.sh config/monsters.xml
```

---

### 4.2 exportdata - XDB 示例与参考项目 ⭐⭐⭐
📍 **文档**: [tools/exportdata/README.md](tools/exportdata/README.md)

**用途**: XDB 数据库使用示例与学习材料

**使用场景**:
- ✅ 学习 XDB 数据库使用方法
- ✅ 作为新项目数据结构设计参考
- ✅ 测试 XDB 功能和性能
- ✅ 验证表结构定义正确性

**关键特性**:
- 完整的 xdb.xml 配置示例
- 4 张业务表（users, orders, platform）
- 自增主键示例
- Locojoy 平台集成数据模型
- 测试入口代码（XdbMain.java）

**典型命令**:
```bash
# 生成 XBean/XTable 代码
java -jar ../bin/monkeyking.jar xdb.xml -noverify

# 编译示例代码
javac -encoding GBK -cp ../bin/monkeyking.jar:../bin/jio.jar \
      -d classes src/**/*.java

# 运行测试
java -cp classes:../bin/monkeyking.jar:../bin/jio.jar test.XdbMain
```

---

## 5. 运维与测试工具 (Operations & Testing)

### 5.1 logs - 游戏日志收集分析工具 ⭐⭐⭐
📍 **文档**: [tools/logs/README.md](tools/logs/README.md)

**用途**: 游戏服务器日志收集、解析与分析

**使用场景**:
- ✅ 游戏日志统一收集（文件、数据库）
- ✅ 玩家行为日志分析
- ✅ 经济系统监控（金币流水、物品交易）
- ✅ 异常行为检测（外挂、刷金）
- ✅ 运营数据报表

**关键特性**:
- 多源日志收集（文件、数据库、消息队列）
- 日志分类与索引
- 实时分析与告警
- 可视化报表生成
- 日志归档与压缩

**典型命令**:
```bash
# 启动日志收集服务
java -jar logs.jar -conf logs.xml

# 分析特定日志文件
java -jar logs.jar -analyze /data/logs/game.log -output report.html

# 查询玩家行为日志
java -jar logs.jar -query "userId=12345 AND action=trade" -from 2025-11-01
```

---

## 6. 技术架构总览

### 6.1 服务器架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         玩家客户端层（Client Layer）                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │  PC 客户端    │  │  Web/H5 端   │  │  移动端       │                 │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                 │
└─────────┼──────────────────┼──────────────────┼─────────────────────────┘
          │                  │                  │
          ↓ TCP/UDP          ↓ WebSocket       ↓ TCP
┌─────────────────────────────────────────────────────────────────────────┐
│                         网关层（Gateway Layer）                          │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │  gateway (网关服务器) - 连接管理、协议加密、负载均衡          │     │
│  │  gws (WebSocket 网关) - Web 端连接支持                        │     │
│  └──────────────────────────────────────────────────────────────┘     │
└─────────┬───────────────────────────────────────────────────────────────┘
          │ RPC/Jelly
          ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                         主控层（Control Layer）                          │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │  jmxc (主控服务器) - 集群协调、登录认证、全局配置管理        │     │
│  └──────────────────────────────────────────────────────────────┘     │
└─────────┬───────────────────────────────────────────────────────────────┘
          │ 服务分发
          ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                      游戏逻辑层（Game Logic Layer）                      │
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
│                      数据库层（Database Layer）                          │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │  XDB (monkeyking) - 文件数据库引擎                           │     │
│  │  - 事务支持（ACID）                                           │     │
│  │  - 热备份与恢复                                               │     │
│  │  - 表结构自动代码生成（XBean/XTable）                         │     │
│  └──────────────────────────────────────────────────────────────┘     │
└─────────┬───────────────────────────────────────────────────────────────┘
          │
          ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                     运维工具层（Operations Layer）                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ logs        │  │ xmerge      │  │ xclear      │  │ xdbench     │ │
│  │ (日志分析)  │  │ (数据库合并) │  │ (数据库清理) │  │ (性能测试)  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ │
│  ┌─────────────┐  ┌─────────────┐                                    │
│  │ convxml     │  │ exportdata  │                                    │
│  │ (代码生成)  │  │ (示例项目)  │                                    │
│  └─────────────┘  └─────────────┘                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

### 6.2 数据流图

```
┌─────────────┐
│ 玩家客户端   │
└──────┬──────┘
       │ 1. 登录请求
       ↓
┌─────────────┐      2. 身份验证      ┌─────────────┐
│   gateway   │ ──────────────────→  │    jmxc     │
│  (网关)     │ ←──────────────────  │  (主控)     │
└──────┬──────┘      3. 分配服务器    └─────────────┘
       │ 4. 转发到游戏服务器
       ↓
┌─────────────┐      5. 读写游戏数据   ┌─────────────┐
│  gdelivery  │ ──────────────────→  │ XDB数据库   │
│ (交付服务器) │ ←──────────────────  │ (monkeyking)│
└─────────────┘      6. 返回数据      └─────────────┘
       │ 7. 游戏逻辑处理
       ↓
┌─────────────┐      8. 记录日志      ┌─────────────┐
│  gfaction   │ ──────────────────→  │    logs     │
│ (帮派服务器) │                       │  (日志收集)  │
└─────────────┘                       └─────────────┘
```

### 6.3 核心技术栈

| 层级 | 技术 | 说明 |
|-----|------|------|
| **编程语言** | Java 1.6+ | 服务器端主要开发语言 |
| **RPC 框架** | Jelly/RPC | 自研 RPC 框架，服务器间通信 |
| **数据库** | XDB (monkeyking) | 文件数据库，支持事务 |
| **序列化** | jio (Octets) | 自研序列化框架 |
| **网络 I/O** | NIO + Selector | 高并发连接处理 |
| **配置管理** | XML + Freemarker | 配置文件 + 模板生成 |
| **构建工具** | Apache Ant | 项目构建与部署 |
| **加密算法** | ARC4 + MD5 | 协议加密与校验 |

---

## 7. 快速开始指南

### 7.1 完整服务器启动流程

#### 步骤 1: 准备环境

```bash
# 1. 确认 Java 环境
java -version
# 输出: java version "1.6.0_45" 或更高

# 2. 确认目录结构
cd /path/to/MT3/server
ls tools/
# 输出: jmxc gateway gdelivery monkeyking ...

# 3. 准备依赖库
ls bin/
# 输出: jio.jar monkeyking.jar xdb.jar
```

#### 步骤 2: 初始化数据库

```bash
# 1. 生成 XBean/XTable 代码
cd tools/gdelivery
java -jar ../bin/monkeyking.jar xdb.xml -noverify

# 2. 编译生成的代码
ant compile

# 3. 初始化数据库目录
mkdir -p xdb/table xdb/log
```

#### 步骤 3: 启动核心服务

```bash
# 1. 启动主控服务器
cd tools/jmxc
java -Xmx512m -jar jmxc.jar -conf jmxc.xml &
# 等待输出: "jmxc server started on port 29100"

# 2. 启动网关服务器
cd tools/gateway
java -Xmx1g -jar gateway.jar -conf gateway.xml &
# 等待输出: "gateway server started on port 29000"

# 3. 启动交付服务器
cd tools/gdelivery
java -Xmx2g -jar gdelivery.jar -conf gdelivery.xml &
# 等待输出: "gdelivery server started"
```

#### 步骤 4: 启动业务服务（按需）

```bash
# 启动帮派服务器
cd tools/gfaction
java -jar gfaction.jar -conf gfaction.xml &

# 启动交易服务器
cd tools/gtransaction
java -jar gtransaction.jar -conf gtransaction.xml &

# 启动 PVP 服务器
cd tools/gpvp
java -jar gpvp.jar -conf gpvp.xml &

# 启动跨服连接服务器
cd tools/glink
java -jar glink.jar -conf glink.xml &
```

#### 步骤 5: 验证服务状态

```bash
# 检查进程
ps aux | grep java

# 检查端口监听
netstat -tuln | grep -E "29000|29100|29200"

# 检查日志
tail -f tools/jmxc/logs/jmxc.log
tail -f tools/gateway/logs/gateway.log
```

### 7.2 一键启动脚本

```bash
#!/bin/bash
# start-all.sh - 启动所有游戏服务器

SERVER_HOME="/path/to/MT3/server"
cd $SERVER_HOME

echo "========================================="
echo " 启动 MT3 游戏服务器集群"
echo "========================================="

# 1. 启动主控服务器
echo "启动 jmxc (主控服务器)..."
cd tools/jmxc
nohup java -Xmx512m -jar jmxc.jar -conf jmxc.xml > /dev/null 2>&1 &
sleep 3

# 2. 启动网关服务器
echo "启动 gateway (网关服务器)..."
cd $SERVER_HOME/tools/gateway
nohup java -Xmx1g -jar gateway.jar -conf gateway.xml > /dev/null 2>&1 &
sleep 2

# 3. 启动交付服务器
echo "启动 gdelivery (交付服务器)..."
cd $SERVER_HOME/tools/gdelivery
nohup java -Xmx2g -jar gdelivery.jar -conf gdelivery.xml > /dev/null 2>&1 &
sleep 2

# 4. 启动业务服务器
echo "启动业务服务器..."
cd $SERVER_HOME/tools/gfaction
nohup java -jar gfaction.jar -conf gfaction.xml > /dev/null 2>&1 &

cd $SERVER_HOME/tools/gtransaction
nohup java -jar gtransaction.jar -conf gtransaction.xml > /dev/null 2>&1 &

cd $SERVER_HOME/tools/gpvp
nohup java -jar gpvp.jar -conf gpvp.xml > /dev/null 2>&1 &

cd $SERVER_HOME/tools/glink
nohup java -jar glink.jar -conf glink.xml > /dev/null 2>&1 &

echo ""
echo "所有服务器启动完成！"
echo "检查运行状态: ps aux | grep java"
echo "查看日志: tail -f tools/*/logs/*.log"
```

### 7.3 一键停止脚本

```bash
#!/bin/bash
# stop-all.sh - 停止所有游戏服务器

echo "========================================="
echo " 停止 MT3 游戏服务器集群"
echo "========================================="

# 优雅停止（发送 SIGTERM）
echo "发送停止信号..."
pkill -TERM -f "jmxc.jar"
pkill -TERM -f "gateway.jar"
pkill -TERM -f "gdelivery.jar"
pkill -TERM -f "gfaction.jar"
pkill -TERM -f "gtransaction.jar"
pkill -TERM -f "gpvp.jar"
pkill -TERM -f "glink.jar"

# 等待 10 秒
echo "等待服务器优雅关闭..."
sleep 10

# 强制停止仍在运行的进程
echo "强制停止残留进程..."
pkill -KILL -f "jmxc.jar"
pkill -KILL -f "gateway.jar"
pkill -KILL -f "gdelivery.jar"
pkill -KILL -f "gfaction.jar"
pkill -KILL -f "gtransaction.jar"
pkill -KILL -f "gpvp.jar"
pkill -KILL -f "glink.jar"

echo ""
echo "所有服务器已停止！"
ps aux | grep java | grep -v grep
```

---

## 8. 常见问题 FAQ

### Q1: 首次启动服务器需要哪些步骤？

**A**: 完整步骤如下：
1. 安装 JDK 1.6 或更高版本
2. 使用 monkeyking 生成 XBean/XTable 代码
3. 编译各服务器项目（`ant compile`）
4. 配置 XML 文件（端口、数据库路径等）
5. 按顺序启动服务器：jmxc → gateway → gdelivery → 其他业务服务器

**详细文档**: 参见 [7.1 完整服务器启动流程](#71-完整服务器启动流程)

---

### Q2: 如何进行游戏合服操作？

**A**: 使用 xmerge 工具合并两个服务器数据库：

```bash
# 1. 停止源服务器和目标服务器
./stop-all.sh

# 2. 备份数据库
cp -r server1/xdb server1/xdb.backup
cp -r server2/xdb server2/xdb.backup

# 3. 检查冲突
java -cp mylogic.jar -jar xmerge.jar -conf xmerge.xml \
     -srcdb server1/xdb -destdb server2/xdb -check

# 4. 执行合并
java -Xmx2g -cp mylogic.jar -jar xmerge.jar -conf xmerge.xml \
     -srcdb server1/xdb -destdb server2/xdb

# 5. 外键验证
java -jar validator.jar -v result_db -output foreign_db

# 6. 启动合并后的服务器
./start-all.sh
```

**详细文档**: 参见 [tools/xmerge/README.md](tools/xmerge/README.md)

---

### Q3: 如何生成游戏配置表的 Java 代码？

**A**: 使用 convxml 工具从 XML 配置生成 Java Bean：

```bash
# 1. 准备配置 XML 文件（如 monsters.xml）
# 2. 准备 Freemarker 模板（bean.ftl, main.ftl）

# 3. 生成代码
java -jar convxml.jar monsters.xml src/gen templates

# 4. 编译生成的代码
javac -d classes src/gen/**/*.java

# 5. 在游戏服务器中使用
import com.game.config.Monster;
Monster monster = new Monster();
```

**详细文档**: 参见 [tools/convxml/README.md](tools/convxml/README.md)

---

### Q4: 数据库性能不理想如何优化？

**A**: 使用 xdbench 进行性能测试并调优：

```bash
# 1. 运行基准测试
cd tools/xdbench
ant compile
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss

# 2. 记录性能指标（TPS、延迟）

# 3. 调整 xdb.xml 配置参数
# - 增加 corePoolSize（线程池大小）
# - 增加 logpages（日志缓冲）
# - 调整 flushPeriod（刷新周期）

# 4. 重新测试验证
ant clean && ant compile
java -cp classes:../bin/xdb.jar:../bin/jio.jar bench.AddStorageMiss

# 5. 对比性能差异
```

**详细文档**: 参见 [tools/xdbench/README.md](tools/xdbench/README.md)

---

### Q5: 如何清理开发环境的测试数据？

**A**: 使用 xclear 工具清理数据库：

```bash
# Windows 环境
cd tools/xclear
run.bat

# Linux 环境
rm -rf xdb/table/* xdb/log/*
rm -f xdb/mkdb.inuse
mkdir -p xdb/table xdb/log
```

**⚠️ 警告**: 清理操作会删除所有数据，务必先备份！

**详细文档**: 参见 [tools/xclear/README.md](tools/xclear/README.md)

---

### Q6: 服务器启动失败如何排查？

**A**: 按以下步骤排查：

```bash
# 1. 检查 Java 版本
java -version

# 2. 检查端口占用
netstat -tuln | grep 29000

# 3. 查看日志文件
tail -100 tools/jmxc/logs/jmxc.log
tail -100 tools/gateway/logs/gateway.log

# 4. 检查配置文件
cat tools/jmxc/jmxc.xml | grep port

# 5. 检查依赖库
ls -l bin/jio.jar bin/monkeyking.jar

# 6. 检查数据库锁文件
ls -l tools/gdelivery/xdb/mkdb.inuse
# 如果存在，删除: rm tools/gdelivery/xdb/mkdb.inuse
```

**常见问题**:
- 端口被占用 → 修改配置文件端口号
- 数据库锁文件残留 → 删除 `mkdb.inuse`
- 依赖库缺失 → 重新编译或拷贝 jar 文件
- 内存不足 → 增加 JVM 堆内存 `-Xmx2g`

---

### Q7: 如何监控服务器运行状态？

**A**: 多种监控方式：

```bash
# 1. 进程监控
ps aux | grep java

# 2. 端口监控
netstat -tuln | grep -E "29000|29100"

# 3. JMX 监控（如果启用）
jconsole localhost:9999

# 4. 日志监控
tail -f tools/jmxc/logs/jmxc.log | grep ERROR

# 5. 性能监控
jstat -gcutil <pid> 1000  # GC 统计
top -p <pid>              # CPU 和内存

# 6. 游戏日志分析
cd tools/logs
java -jar logs.jar -query "level=ERROR" -from today
```

---

### Q8: 跨服功能如何配置？

**A**: 使用 glink 服务器实现跨服功能：

```bash
# 1. 启动 glink 服务器
cd tools/glink
java -jar glink.jar -conf glink.xml

# 2. 配置其他服务器连接到 glink
# 在 gdelivery.xml, gfaction.xml 等配置文件中添加:
# <link host="127.0.0.1" port="29300"/>

# 3. 重启业务服务器
# 支持的跨服功能:
# - 跨服聊天
# - 跨服组队
# - 跨服拍卖行
# - 跨服排行榜
```

**详细文档**: 参见 [tools/glink/README.md](tools/glink/README.md)

---

## 9. 文档维护信息

| 项目 | 信息 |
|-----|------|
| **项目名称** | MT3 梦幻西游 MG 版本服务器工具集 |
| **工具总数** | 16 个（9 个游戏服务器 + 4 个数据库工具 + 2 个开发工具 + 1 个运维工具） |
| **技术栈** | Java 1.6+, Jelly/RPC, XDB, jio, Ant |
| **文档版本** | v1.0 |
| **最后更新** | 2025-11-27 |
| **维护者** | MT3 开发团队 |

---

## 10. 快速链接

### 10.1 核心服务器文档

- [jmxc - 主控服务器](tools/jmxc/README.md)
- [gateway - 网关服务器](tools/gateway/README.md)
- [gdelivery - 交付服务器](tools/gdelivery/README.md)
- [gfaction - 帮派服务器](tools/gfaction/README.md)
- [glink - 跨服连接服务器](tools/glink/README.md)
- [gprovider - 资源提供服务器](tools/gprovider/README.md)
- [gtransaction - 交易服务器](tools/gtransaction/README.md)
- [gtradestart - 交易启动服务器](tools/gtradestart/README.md)
- [gpvp - PVP 服务器](tools/gpvp/README.md)
- [gws - WebSocket 服务器](tools/gws/README.md)

### 10.2 数据库工具文档

- [monkeyking - XDB 数据库引擎](tools/monkeyking/README.md)
- [xmerge - 数据库合并工具](tools/xmerge/README.md)
- [xclear - 数据库清理工具](tools/xclear/README.md)
- [xdbench - 性能基准测试工具](tools/xdbench/README.md)

### 10.3 开发工具文档

- [convxml - XML 到 Java 代码生成器](tools/convxml/README.md)
- [exportdata - XDB 示例与参考项目](tools/exportdata/README.md)

### 10.4 运维工具文档

- [logs - 游戏日志收集分析工具](tools/logs/README.md)

---

## 11. 贡献与反馈

如有问题、建议或发现文档错误，请通过以下方式联系：

- **提交 Issue**: 到项目 Git 仓库提交问题
- **技术讨论**: 联系 MT3 开发团队技术负责人
- **文档更新**: 提交 Pull Request 或联系文档维护者

---

**文档结束** | **Document End** | **最后更新**: 2025-11-27

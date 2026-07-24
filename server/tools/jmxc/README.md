# jmxc - JMX 远程管理命令行工具

## 1. 工具概述

### 1.1 用途说明
jmxc 是一个基于 JMX (Java Management Extensions) 的轻量级远程管理与运维 CLI 工具，专为 MT3 游戏服务器集群设计。该工具通过 RMI 协议远程调用服务器暴露的 MBean，实现以下核心功能：

- **服务管理**：关服、重启、心跳检测
- **GM 命令执行**：远程执行游戏管理员指令（添加等级、金币等）
- **状态查询**：在线人数、排队人数、缓存信息
- **配置管理**：热重载配置、刷新排行榜、同步经验状态

### 1.2 典型使用场景
- 运维脚本自动化：批量健康检查、定时任务执行
- 游戏服务器运维：紧急关服、GM 操作、配置热更新
- 监控与告警：在线人数监控、服务存活性检测
- 调试与测试：开发环境快速测试 GM 命令

### 1.3 关键特性
- **超时保护**：所有远程调用内置 7 秒超时机制，防止运维脚本挂起
- **容错设计**：失败时输出 sentinel 值（0/-1），便于脚本解析
- **无依赖**：纯 Java 实现，仅依赖 JDK 标准库
- **跨平台**：支持 Windows/Linux/macOS

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
jmxc 位于 MT3 服务器架构的**运维工具层**，与游戏服务器的 JMX 管理端点对接：

```
┌─────────────────────────────────────────┐
│        运维脚本 / 自动化平台            │
└──────────────┬──────────────────────────┘
               │ (调用 jmxc.jar)
               ↓
┌─────────────────────────────────────────┐
│           jmxc CLI 工具                 │
│  (JMX 客户端 + 命令解析 + 超时控制)     │
└──────────────┬──────────────────────────┘
               │ RMI over TCP
               ↓
┌─────────────────────────────────────────┐
│      游戏服务器 JMX MBean 接口          │
│  - IWEB:type=GameControl (心跳/在线)    │
│  - gs.counter:type=GMProcMXBeant (GM)   │
│  - bean:name=stopper (关服)             │
│  - IWEB:type=Reload (配置重载)          │
└─────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **上游依赖**：需要游戏服务器开启 JMX 端口（默认 RMI 注册端口 + JMX 服务端口 port+2687）
- **下游消费者**：Shell 脚本、PowerShell、批处理文件、监控平台
- **数据流**：单向调用（工具 → 服务器），无状态会话

### 2.3 关键代码位置
| 功能模块 | 文件路径 | 关键行号 |
|---------|---------|---------|
| 命令行入口 | [src/jmxc.java](src/jmxc.java#L326-L527) | 326-527 |
| 连接管理 | [src/jmxc.java](src/jmxc.java#L36-L45) | 36-45 |
| 超时控制 | [src/jmxc.java](src/jmxc.java#L216-L252) | 216-252 |
| 心跳检测 | [src/jmxc.java](src/jmxc.java#L102-L111) | 102-111 |
| GM 命令执行 | [src/jmxc.java](src/jmxc.java#L153-L172) | 153-172 |
| 在线人数查询 | [src/jmxc.java](src/jmxc.java#L133-L141) | 133-141 |
| 关服操作 | [src/jmxc.java](src/jmxc.java#L96-L131) | 96-131 |
| 配置重载 | [src/jmxc.java](src/jmxc.java#L174-L181) | 174-181 |
| 构建配置 | [build.xml](build.xml) | 全文 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**：JDK/JRE 1.6 及以上（推荐 JDK 8）
- **网络连接**：可访问目标服务器的 JMX 端口（RMI 注册端口 + JMX 服务端口）
- **系统权限**：目标 MBean 的调用权限（通过用户名/密码认证）

### 3.2 构建时依赖
- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）

### 3.3 构建步骤

#### Windows 环境
```batch
# 方式 1：使用现成的构建脚本
build.bat

# 方式 2：直接使用 Ant
ant clean build

# 输出文件：jmxc-new.jar
```

#### Linux/macOS 环境
```bash
# 方式 1：使用现成的构建脚本
chmod +x build.sh
./build.sh

# 方式 2：直接使用 Ant
ant clean build

# 输出文件：jmxc-new.jar
```

#### 构建流程说明
构建脚本执行以下步骤（参见 [build.xml](build.xml)）：

1. **清理阶段**（clean）：删除旧的 bin/ 目录和 jar 文件
2. **初始化阶段**（init）：创建 bin/ 编译输出目录
3. **编译阶段**（compile）：
   - 编译 `src/**/*.java` → `bin/`
   - 使用 UTF-8 编码
   - 启用调试信息（lines, vars, source）
4. **打包阶段**（jar）：
   - 生成 `jmxc-new.jar`
   - 设置 Main-Class: `jmxc`
   - Class-Path: `.`

### 3.4 构建参数说明
| 参数 | 说明 | 默认值 |
|-----|------|-------|
| `src.dir` | 源代码目录 | `src` |
| `bin.dir` | 编译输出目录 | `bin` |
| `jar.name` | 输出 Jar 文件名 | `jmxc-new.jar` |
| `main.class` | 主类名 | `jmxc` |

---

## 4. 配置与使用

### 4.1 基本命令格式
```bash
java -jar jmxc.jar <username> <password> <ip> <port> <function> [args...]
```

**参数说明**：
- `<username>`：JMX 用户名（空字符串 `""` 表示无认证）
- `<password>`：JMX 密码（空字符串 `""` 表示无认证）
- `<ip>`：目标服务器 IP 地址
- `<port>`：RMI 注册端口（实际 JMX 服务端口为 port+2687）
- `<function>`：要执行的功能名称（见下方完整列表）
- `[args...]`：特定功能的额外参数

### 4.2 支持的功能列表

#### 4.2.1 服务管理功能

**1. 心跳检测 (keepAlive)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "keepAlive"
# 成功输出：1
# 失败输出：0
```
- **实现**：`jmxc.java:102-111`
- **MBean**：`IWEB:type=GameControl.keepAlive(LogInfo)`
- **用途**：检测服务器存活状态
- **返回**：布尔值转换为 1/0

**2. 关闭游戏服 (shutdownGs)**
```bash
# 默认 300 秒延迟关服
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "shutdownGs"

# 自定义延迟时间（秒）
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "shutdownGs" "600"
```
- **实现**：`jmxc.java:96-101,370-382`
- **MBean**：`bean:name=stopper.stop(Integer)`
- **参数**：`[waitSec]` - 延迟关服时间（默认 300 秒）

**3. 关闭 UN 服务 (shutdownUn)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "shutdownUn"
```
- **实现**：`jmxc.java:127-131,383-395`
- **MBean**：`bean:name=stopper.stop(Integer)`
- **注意**：吞掉 UnmarshalException/ConnectException 异常

**4. 关闭 Auany 服务 (shutdownAuany)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "shutdownAuany"
```
- **实现**：`jmxc.java:112-116,396-408`
- **MBean**：`bean:name=stopper.stop(Integer)`

#### 4.2.2 状态查询功能

**5. 获取在线人数 (GetMaxOnlineNum)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "GetMaxOnlineNum"
# 成功输出：当前在线人数（整数）
# 失败输出：0
```
- **实现**：`jmxc.java:133-141,424-438`
- **MBean**：`IWEB:type=GameControl.getOnlineNum(LogInfo)`
- **返回**：`GameOnlineNumBean.curronlinenum` 字段
- **数据结构**：包含 0~150 档在线人数统计（见 [GameOnlineNumBean.java](src/com/jmxservice/mt3interfaces/GameOnlineNumBean.java)）

**6. 获取排队人数 (getUserNumInQueue)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "getUserNumInQueue"
# 成功输出：排队人数（整数）
# 失败输出：-1
```
- **实现**：`jmxc.java:143-151,450-461`
- **MBean**：`IWEB:type=GameControl.getUserNumInQueue(LogInfo)`

**7. 获取缓存信息 (getCacheInfo)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "getCacheInfo"
```
- **实现**：`jmxc.java:201-208,498-509`
- **MBean**：`gs.counter:type=CacheInfo.getCacheInfo()`

#### 4.2.3 配置管理功能

**8. 重载配置 (reload)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "reload"
```
- **实现**：`jmxc.java:174-181,462-473`
- **MBean**：`IWEB:type=Reload.reload()`
- **用途**：热重载服务器配置文件

**9. 刷新排行榜 (refreshRankList)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "refreshRankList"
```
- **实现**：`jmxc.java:183-190,474-485`
- **MBean**：`gs.counter:type=RankList.doSortRankList()`

**10. 同步经验状态 (doExpState)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "doExpState"
```
- **实现**：`jmxc.java:192-199,486-497`
- **MBean**：`gs.counter:type=ForceActiveLog.doExpState()`

#### 4.2.4 GM 命令功能

**11. 执行 GM 命令 (gm)**
```bash
# 添加等级
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "gm" "userId=9845" "roleId=4097" "addlevel#100"

# 添加金币
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "gm" "userId=9845" "roleId=4097" "addgold#100"

# 多行 GM 命令
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "gm" "userId=9845" "roleId=4097" "addgold#100" "addlevel#50"
```
- **实现**：`jmxc.java:153-172,510-522`
- **MBean**：`gs.counter:type=GMProcMXBeant.execute(Integer userId, Long roleId, String command)`
- **参数解析**：
  - `userId=<数字>`：用户 ID
  - `roleId=<数字>`：角色 ID
  - 其余参数：GM 命令文本（多行用 `\n` 连接）
- **返回**：成功返回服务器响应，失败返回 0

#### 4.2.5 其他功能

**12. MAC 地址绑定 (bindMacToLahu)**
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "bindMacToLahu"
```
- **实现**：`jmxc.java:118-125,439-449`
- **MBean**：`bean:name=bindmac.bind()`

### 4.3 配置示例

#### 示例 1：监控脚本（定时心跳检测）
```bash
#!/bin/bash
# heartbeat_check.sh

SERVERS=(
  "192.168.32.44:1098"
  "192.168.32.45:1098"
  "192.168.32.46:1098"
)

for server in "${SERVERS[@]}"; do
  ip=$(echo $server | cut -d: -f1)
  port=$(echo $server | cut -d: -f2)

  result=$(java -jar jmxc.jar "" "" "$ip" "$port" "keepAlive")

  if [ "$result" == "1" ]; then
    echo "[OK] $server is alive"
  else
    echo "[FAIL] $server is down!" | mail -s "Server Alert" admin@example.com
  fi
done
```

#### 示例 2：批量 GM 操作（PowerShell）
```powershell
# batch_gm.ps1
$servers = @(
    @{ip="192.168.32.44"; port="1098"}
    @{ip="192.168.32.45"; port="1098"}
)

$gmCommands = @(
    "userId=9845 roleId=4097 addgold#1000",
    "userId=9846 roleId=4098 addlevel#50"
)

foreach ($server in $servers) {
    foreach ($cmd in $gmCommands) {
        $params = $cmd -split " "
        & java -jar jmxc.jar "" "" $server.ip $server.port "gm" $params
    }
}
```

#### 示例 3：在线人数监控（Crontab）
```bash
# crontab -e
# 每 5 分钟检查一次在线人数
*/5 * * * * /path/to/check_online.sh

# check_online.sh
#!/bin/bash
ONLINE=$(java -jar /opt/tools/jmxc.jar "" "" "192.168.32.44" "1098" "GetMaxOnlineNum")
echo "$(date): Online players = $ONLINE" >> /var/log/game_online.log

if [ "$ONLINE" -lt 100 ]; then
  echo "Warning: Low online count ($ONLINE)" | mail -s "Game Alert" ops@example.com
fi
```

---

## 5. 输入输出规范

### 5.1 标准输入格式
工具不接受标准输入（stdin），所有参数通过命令行参数传递。

### 5.2 标准输出格式

#### 成功场景
| 功能 | 输出格式 | 示例 |
|-----|---------|------|
| keepAlive | `1` (成功) / `0` (失败) | `1` |
| GetMaxOnlineNum | 在线人数（整数） | `523` |
| getUserNumInQueue | 排队人数（整数） | `42` |
| gm | 服务器返回的文本 | `GM command executed successfully` |
| reload/refresh... | 服务器返回的文本 | `Config reloaded` |
| shutdownGs/Un/Auany | 无输出（静默成功） | _(空)_ |

#### 失败场景
| 错误类型 | 输出 | 退出码 |
|---------|------|-------|
| 参数不足 | `Usage: java jmxc username password ip port function ...` | 非 0 |
| 功能不存在 | `function not found!` | 非 0 |
| 连接失败（keepAlive） | `0` + 堆栈追踪 | 非 0 |
| 连接失败（GetMaxOnlineNum） | `0` | 非 0 |
| JMX 调用超时 | _(无输出)_ 返回值为 null | 非 0 |
| 其他异常 | `jmxc connect error` + 异常抛出 | 非 0 |

### 5.3 错误代码说明
工具未定义标准化的错误码，依赖以下 sentinel 值：

| 返回值 | 含义 | 适用功能 |
|-------|------|---------|
| `0` | 调用失败或服务器无响应 | keepAlive, GetMaxOnlineNum, gm |
| `-1` | 查询失败 | getUserNumInQueue |
| 异常抛出 | 连接错误或严重异常 | 所有功能 |

### 5.4 超时机制
- **连接超时**：7000 毫秒（`jmxc.java:30,254-313`）
- **调用超时**：7000 毫秒（`jmxc.java:216-252`）
- **实现方式**：
  - 使用 `ExecutorService` + `Future.get(timeout, unit)` 实现
  - 守护线程池确保 CLI 不挂起
  - 超时后返回 `null`，由调用方转换为 sentinel 值

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制
- **串行执行**：当前版本不支持并发连接多个节点，所有操作串行执行
- **无状态**：每次调用创建新连接，无会话保持
- **参数校验缺失**：非法输入直接触发异常，无友好提示
- **无日志记录**：失败信息仅通过标准输出/异常堆栈展示

#### 协议限制
- **仅支持 RMI 协议**：不支持 SSL/JMXMP/HTTP 等高级协议
- **明文传输**：凭据和数据未加密，需通过 VPN/SSH 隧道保护

#### 平台限制
- **端口映射规则固定**：JMX 服务端口 = RMI 注册端口 + 2687（硬编码）
- **Windows 路径**：批处理脚本不支持带空格的路径

### 6.2 性能考虑

#### 超时设置
- 默认超时 7 秒可能不适合高延迟网络，无法通过参数调整
- 需要修改代码并重新编译：`jmxc.java:30`

#### 连接池
- 未实现连接池，频繁调用会产生大量 TCP 连接开销
- 建议外层脚本控制调用频率（如 crontab 设置 5 分钟间隔）

#### 资源释放
- 工具会自动关闭 JMX 连接（`jmxc.java:47-53`）
- 使用守护线程池，确保进程正常退出

### 6.3 安全注意事项

#### 凭据管理
- **⚠️ 严禁将密码硬编码在脚本中**
- 推荐方案：
  - 使用环境变量存储凭据：`$JMX_USER`, `$JMX_PASS`
  - Windows：使用 Credential Manager
  - Linux：使用密钥环（gnome-keyring/kwallet）

#### 网络隔离
- JMX 端口应仅在管理网络开放，禁止公网访问
- 建议使用防火墙白名单限制源 IP
- 通过 VPN/堡垒机访问生产环境

#### 审计日志
- 工具本身不记录操作日志，建议在调用层实现审计
- GM 命令应强制记录操作者、时间、参数

#### 风控措施（高危操作）
针对 `gm`、`shutdownGs` 等高危命令，建议实施：
1. **双人确认**：关键操作需要二次授权
2. **频率限制**：服务器端增加操作频率/金额限制
3. **实时监控**：SIEM 系统监控 JMX 调用异常
4. **凭据轮换**：定期更换 JMX 账号密码
5. **工具加固**：对 Jar 包进行代码混淆和完整性校验

更多风控方案详见：[泄露风控方案](docs/20251124-泄露风控方案-jmxc-leak-mitigation.md)

### 6.4 故障排查指南

#### 问题 1：连接超时
**症状**：执行命令后 7 秒无响应，输出 `0` 或异常
**可能原因**：
- 目标服务器 JMX 端口未开启或被防火墙阻止
- IP/端口参数错误
- 网络不通

**排查步骤**：
```bash
# 1. 检查网络连通性
ping 192.168.32.44

# 2. 检查 RMI 注册端口（示例：1098）
telnet 192.168.32.44 1098

# 3. 检查 JMX 服务端口（port+2687，示例：3785）
telnet 192.168.32.44 3785

# 4. 查看服务器端 JMX 配置
# 确认启动参数包含：
# -Dcom.sun.management.jmxremote
# -Dcom.sun.management.jmxremote.port=1098
# -Dcom.sun.management.jmxremote.authenticate=false
# -Dcom.sun.management.jmxremote.ssl=false
```

#### 问题 2：认证失败
**症状**：`SecurityException` 或 `Authentication failed`
**解决方案**：
- 检查用户名/密码是否正确
- 确认服务器端 `jmxremote.password` 文件配置
- 验证账号是否有调用权限

#### 问题 3：GM 命令无效
**症状**：执行 gm 命令返回 `-1` 或 `0`
**可能原因**：
- `userId` 或 `roleId` 参数缺失或格式错误
- GM 命令语法错误
- 目标角色不存在

**正确格式**：
```bash
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "gm" "userId=9845" "roleId=4097" "addgold#100"
#                                                      ^^^^^^^^^^^^  ^^^^^^^^^^^^  ^^^^^^^^^^^
#                                                      必须参数      必须参数      GM 命令文本
```

#### 问题 4：功能未找到
**症状**：`function not found!`
**解决方案**：
- 检查 `<function>` 参数拼写（大小写敏感）
- 参考第 4.2 节支持的功能列表

#### 问题 5：Jar 包无法执行
**症状**：`no main manifest attribute` 或 `ClassNotFoundException`
**解决方案**：
```bash
# 重新构建 Jar 包
ant clean build

# 验证 Jar 包结构
jar -tf jmxc-new.jar | head -20

# 检查 MANIFEST.MF
unzip -p jmxc-new.jar META-INF/MANIFEST.MF
# 应包含：Main-Class: jmxc
```

---

## 7. 扩展与改进

### 7.1 当前未使用的代码
- **ConnectTask.java**（`src/ConnectTask.java`）：早期的异步连接实现，当前未被引用，可用于未来支持并发连接多个节点

### 7.2 推荐改进方向

#### 短期优化（1-2 周）
1. **日志记录**：增加操作日志，记录调用时间、参数、耗时、结果
2. **参数校验**：对必填参数进行前置验证，提供友好错误提示
3. **配置文件支持**：支持从 YAML/JSON 读取连接信息，避免命令行暴露凭据

#### 中期优化（1-2 个月）
4. **命令注册表**：使用 `Map<String, CommandHandler>` 替代 if-else 链，便于扩展新功能
5. **多节点支持**：启用 `ConnectTask` 实现并发连接，支持批量健康检查
6. **结构化输出**：支持 JSON/XML 输出格式，便于自动化平台解析
7. **可配置超时**：通过命令行参数或配置文件调整超时时间

#### 长期优化（3-6 个月）
8. **安全增强**：
   - 支持 SSL/TLS 加密传输
   - 集成 Windows Credential Manager / Linux 密钥环
   - 实现凭据加密存储
9. **高级协议**：支持 JMXMP / HTTP 协议
10. **可观测性**：集成 Prometheus/Grafana 监控，暴露调用指标
11. **Web UI**：提供简单的 Web 界面，便于非技术人员使用

### 7.3 参考资料
- 完整项目说明：[20251124-项目说明-jmxc-tool.md](docs/20251124-项目说明-jmxc-tool.md)
- 安全风控方案：[20251124-泄露风控方案-jmxc-leak-mitigation.md](docs/20251124-泄露风控方案-jmxc-leak-mitigation.md)
- 构建详细说明：[BUILD_README.md](BUILD_README.md)

---

## 8. 快速参考

### 8.1 常用命令速查表

```bash
# 心跳检测
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "keepAlive"

# 获取在线人数
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "GetMaxOnlineNum"

# 关服（300 秒延迟）
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "shutdownGs"

# GM 添加金币
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "gm" "userId=9845" "roleId=4097" "addgold#1000"

# 重载配置
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "reload"

# 刷新排行榜
java -jar jmxc.jar "" "" "192.168.32.44" "1098" "refreshRankList"
```

### 8.2 返回值速查

| 返回值 | 含义 | 应对措施 |
|-------|------|---------|
| `1` | keepAlive 成功 | 服务器正常 |
| `0` | 调用失败 | 检查网络/服务状态 |
| `-1` | 查询失败 | 检查参数或服务端日志 |
| 整数 > 0 | 在线/排队人数 | 正常数据 |
| 文本 | 服务器返回消息 | 根据内容判断 |
| 异常 | 连接/调用错误 | 参考故障排查指南 |

### 8.3 端口计算公式
```
JMX 服务端口 = RMI 注册端口 + 2687

示例：
  RMI 端口 = 1098
  JMX 端口 = 1098 + 2687 = 3785
```

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | jmxc (Java Management Extensions Client) |
| **版本** | 见最新 Jar 文件时间戳 |
| **主要维护者** | 见项目 Git 提交历史 |
| **代码位置** | `server/tools/jmxc/` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, JMX, RMI, Ant |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器运维团队
- 查看项目 Wiki 获取更多文档

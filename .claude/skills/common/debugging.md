---
name: debugging
version: 1.1.0
priority: high
category: common
description: |
  MT3项目调试技巧技能。涵盖客户端和服务器端调试方法、性能分析工具、内存调试和网络调试技术。
  触发词: 调试, debug, 断点, 崩溃, 内存泄漏, 性能分析, Wireshark, profiler, Access Violation, LNK, 堆栈, callstack, assert
allowed-tools:
  - Bash
  - Read
  - Edit
---

# 调试技巧技能 (MT3 项目)

**版本**: v1.1.0
**最后更新**: 2026-04-11

---

## 🎯 调试在 MT3 中的重要性

### 调试影响所有技能
```
┌─────────────────────────────────────────┐
│            调试技巧（核心技能）           │
│                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │ C++ 开发 │  │Lua 脚本 │  │Java 开发│  │
│  └────┬────┘  └────┬────┘  └────┬────┘  │
│       │            │            │       │
│       └────────────┼────────────┘       │
│                    │                    │
│            更快定位和解决问题             │
└─────────────────────────────────────────┘
```

### 调试的价值
| 能力 | 没有调试技能 | 有调试技能 |
|-----|------------|-----------|
| 问题定位 | 几小时甚至几天 | 几分钟到几小时 |
| 代码理解 | 靠猜测和阅读 | 动态观察执行流程 |
| 性能优化 | 盲目尝试 | 精准定位瓶颈 |
| 学习效率 | 低效 | 高效 |

---

## 🖥️ 客户端调试

### Visual Studio 调试器

#### 基本调试操作

```cpp
// 示例代码
void Player::Update(float deltaTime) {
    m_position.x += m_velocity.x * deltaTime;  // 断点位置
    m_position.y += m_velocity.y * deltaTime;

    if (m_health <= 0) {
        OnDeath();  // 条件断点
    }
}
```

**常用快捷键**：
| 快捷键 | 功能 | 说明 |
|--------|------|------|
| F5 | 开始调试/继续 | 启动或恢复执行 |
| F9 | 切换断点 | 在当前行设置/取消断点 |
| F10 | 单步跳过 | 执行当前行，不进入函数 |
| F11 | 单步进入 | 执行当前行，进入函数 |
| Shift+F11 | 跳出 | 执行完当前函数 |
| Ctrl+Shift+F9 | 删除所有断点 | 清除所有断点 |

#### 高级断点技巧

##### 1. 条件断点
```cpp
// 只在特定条件下中断
// 右键断点 → 条件 → 输入条件表达式
// 条件: playerId == 1001 && health < 10
```

**设置步骤**：
1. 设置普通断点 (F9)
2. 右键断点 → "条件..."
3. 输入条件表达式
4. 选择"为 true 时"或"已更改时"

##### 2. 命中计数断点
```cpp
// 循环中只在第100次迭代时中断
for (int i = 0; i < 10000; i++) {
    ProcessItem(i);  // 设置命中计数 = 100
}
```

**设置步骤**：
1. 右键断点 → "命中计数..."
2. 选择"命中计数等于"
3. 输入次数: 100

##### 3. 数据断点（内存断点）
```cpp
// 当变量值被修改时中断
int m_health = 100;  // 监视这个变量

// 设置步骤:
// 1. 调试 → 新建断点 → 新建数据断点
// 2. 地址: &m_health
// 3. 字节计数: 4 (int 大小)
```

##### 4. 追踪点（Tracepoint）
```cpp
// 不中断，只打印信息
void ProcessMessage(Message* msg) {
    // 追踪点: 打印 "Processing: {msg->id}"
    HandleMessage(msg);
}
```

**设置步骤**：
1. 右键断点 → "操作..."
2. 勾选"记录消息到输出窗口"
3. 输入: `Processing message: {msg->id}, type: {msg->type}`
4. 取消勾选"继续执行"（如果不想中断）

#### 监视和即时窗口

##### 监视窗口
```cpp
// 在监视窗口中可以：
// 1. 查看变量值
player->m_health

// 2. 查看表达式
player->m_position.x + player->m_velocity.x * deltaTime

// 3. 修改值（调试时）
player->m_health = 100

// 4. 格式化显示
player->m_position,x    // 十六进制
player->m_name,su       // Unicode 字符串
arrayPtr,10             // 显示数组前10个元素
```

**常用格式说明符**：
| 说明符 | 格式 | 示例 |
|--------|------|------|
| d | 十进制 | 255,d → 255 |
| x | 十六进制 | 255,x → 0xff |
| o | 八进制 | 255,o → 0377 |
| s | 字符串 | ptr,s → "hello" |
| su | Unicode | wptr,su → L"中文" |
| 10 | 数组 | arr,10 → 前10个元素 |

##### 即时窗口
```cpp
// 在即时窗口中执行表达式（调试 → 窗口 → 即时）

// 查看变量
? player->m_health
100

// 调用函数
? player->GetPosition()
{x=100.5, y=200.3}

// 修改变量
player->m_health = 50

// 复杂表达式
? sqrt(player->m_position.x * player->m_position.x + player->m_position.y * player->m_position.y)
223.83
```

#### 调用栈分析

```
示例调用栈：
MT3Client.exe!Player::OnDamage(int damage) 行 156
MT3Client.exe!Combat::ApplyDamage(Player* target, int damage) 行 89
MT3Client.exe!Skill::Execute(Player* caster, Player* target) 行 234
MT3Client.exe!SkillManager::UseSkill(int skillId, int targetId) 行 67
MT3Client.exe!GameLogic::ProcessInput(InputEvent* event) 行 445
```

**分析技巧**：
1. **从下往上读**：了解调用路径
2. **查看参数**：双击栈帧查看局部变量
3. **切换上下文**：点击栈帧切换到对应代码
4. **异常处理**：查看异常抛出点

---

### 内存调试工具

#### Visual Leak Detector (VLD)

**安装和配置**：
```cpp
// 1. 下载 VLD: https://vld.codeplex.com/
// 2. 在项目中包含头文件
#include <vld.h>

// 3. 链接库
// 项目属性 → 链接器 → 输入 → vld.lib

// 4. 运行程序，退出时自动报告泄漏
```

**输出示例**：
```
---------- Block 1 at 0x00A41040: 64 bytes ----------
  Leak Hash: 0x553E2F6E, Count: 1, Total 64 bytes
  Call Stack (TID 5765):
    ntdll.dll!RtlAllocateHeap()
    MT3Client.exe!malloc() + 0x5A
    MT3Client.exe!operator new() + 0x1F
    MT3Client.exe!Player::CreateSprite() + 0x45 (player.cpp, Line 123)
    MT3Client.exe!Player::Initialize() + 0x89 (player.cpp, Line 67)
```

**分析步骤**：
1. 查看泄漏大小和次数
2. 分析调用栈找到分配位置
3. 检查对应的释放逻辑

#### Application Verifier

**配置步骤**：
1. 打开 Application Verifier
2. 添加程序 (MT3Client.exe)
3. 选择检测项：
   - Basics → Heaps（堆损坏检测）
   - Basics → Handles（句柄泄漏）
   - Basics → Locks（死锁检测）
4. 保存并运行程序

**常见检测问题**：
- 堆缓冲区溢出
- 使用已释放内存
- 双重释放
- 句柄泄漏

#### AddressSanitizer (VS 2019+)

**启用方法**：
```
项目属性 → C/C++ → 常规 → 启用地址擦除器 → 是
```

**检测的问题**：
- 堆缓冲区溢出
- 栈缓冲区溢出
- 使用已释放内存
- 使用未初始化内存

---

### Lua 调试

#### Print 调试（基础）

```lua
-- 基础打印
print("Debug: player id =", playerId)

-- 打印 Table
local function printTable(t, indent)
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. tostring(k) .. ":")
            printTable(v, indent .. "  ")
        else
            print(indent .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

-- 使用
printTable(player)
-- 输出:
-- id = 1001
-- name = 张三
-- position:
--   x = 100
--   y = 200
```

#### 调用栈打印

```lua
-- 打印调用栈
local function printStackTrace()
    print("Stack trace:")
    local level = 2
    while true do
        local info = debug.getinfo(level, "Sln")
        if not info then break end

        local src = info.short_src or "?"
        local line = info.currentline or 0
        local name = info.name or "[anonymous]"

        print(string.format("  %s:%d in %s", src, line, name))
        level = level + 1
    end
end

-- 使用
function Player:takeDamage(damage)
    printStackTrace()  -- 查看谁调用了这个函数
    self.health = self.health - damage
end
```

#### ZeroBrane Studio 调试

**配置步骤**：

1. **安装 ZeroBrane Studio**
   - 下载: https://studio.zerobrane.com/

2. **在项目中添加调试器**
   ```lua
   -- 在 Lua 入口文件添加
   if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
       require("lldebugger").start()
   end

   -- 或者使用 mobdebug
   require("mobdebug").start()
   ```

3. **设置断点和调试**
   - 打开 Lua 文件
   - 点击行号设置断点
   - F5 开始调试

#### 远程调试（MobDebug）

```lua
-- 服务端（游戏客户端）
local mobdebug = require("mobdebug")
mobdebug.start("127.0.0.1", 8172)  -- 连接到调试器

-- 在代码中设置断点
mobdebug.pause()  -- 程序会在这里暂停

-- 常用命令
mobdebug.on()     -- 启用调试
mobdebug.off()    -- 禁用调试
mobdebug.done()   -- 结束调试会话
```

---

## ☕ 服务器端调试

### Eclipse/IntelliJ IDEA 调试

#### 基本调试配置

**Eclipse 配置**：
1. 右键项目 → Debug As → Java Application
2. 或创建 Debug Configuration

**IntelliJ IDEA 配置**：
1. Run → Edit Configurations
2. 添加 Application 配置
3. 设置主类和参数

#### 远程调试配置

**服务器端启动参数**：
```bash
# Java 8
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
     -jar game_server.jar

# Java 9+
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 \
     -jar game_server.jar
```

**IDE 配置（IntelliJ）**：
1. Run → Edit Configurations
2. 添加 Remote JVM Debug
3. Host: 服务器 IP
4. Port: 5005
5. 开始调试

#### 条件断点和日志断点

```java
// 条件断点示例
public void processMessage(int playerId, Message msg) {
    // 右键断点 → Condition: playerId == 1001 && msg.type == MSG_CHAT
    handleMessage(playerId, msg);
}

// 日志断点（不中断，只打印）
// 右键断点 → More → Suspend: 取消勾选
// 勾选 "Evaluate and log"
// 表达式: "Processing: " + playerId + ", type: " + msg.type
```

### Java 性能分析工具

#### JProfiler

**连接方式**：
```bash
# 启动时集成
java -agentpath:/path/to/libjprofilerti.so=port=8849 -jar game_server.jar

# 或者附加到运行中的进程
jprofiler attach <pid>
```

**主要功能**：
1. **CPU 分析**
   - 方法调用树
   - 热点方法
   - 调用计数

2. **内存分析**
   - 对象分配
   - 内存泄漏检测
   - GC 活动

3. **线程分析**
   - 线程状态
   - 死锁检测
   - 等待分析

#### VisualVM

**启动**：
```bash
# JDK 自带
jvisualvm

# 或者独立版本
visualvm
```

**主要功能**：
1. **监控**
   - CPU、内存、线程、类

2. **采样器**
   - CPU 采样
   - 内存采样

3. **分析器**
   - 堆转储
   - 线程转储

#### JMX 监控

```java
// 在服务器中暴露监控接口
@ManagedResource(description = "Player Manager")
public class PlayerManager {

    @ManagedAttribute(description = "Online player count")
    public int getOnlinePlayerCount() {
        return players.size();
    }

    @ManagedOperation(description = "Kick player")
    public void kickPlayer(int playerId) {
        // ...
    }
}
```

**JMX 连接**：
```bash
# 启动时启用 JMX
java -Dcom.sun.management.jmxremote \
     -Dcom.sun.management.jmxremote.port=9010 \
     -Dcom.sun.management.jmxremote.authenticate=false \
     -Dcom.sun.management.jmxremote.ssl=false \
     -jar game_server.jar
```

### 分布式调试技巧

#### 日志分析

```java
// 结构化日志
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameService {
    private static final Logger log = LoggerFactory.getLogger(GameService.class);

    public void processRequest(int playerId, Request req) {
        // 请求入口日志
        log.info("REQ_START playerId={} reqType={} reqId={}",
                 playerId, req.getType(), req.getId());

        try {
            // 处理逻辑
            Result result = handle(req);

            // 成功日志
            log.info("REQ_SUCCESS playerId={} reqId={} result={}",
                     playerId, req.getId(), result);
        } catch (Exception e) {
            // 错误日志
            log.error("REQ_ERROR playerId={} reqId={} error={}",
                      playerId, req.getId(), e.getMessage(), e);
            throw e;
        }
    }
}
```

**日志分析命令**：
```bash
# 查找特定玩家的日志
grep "playerId=1001" game_server.log

# 查找错误日志
grep "ERROR" game_server.log | tail -100

# 统计请求类型
grep "REQ_START" game_server.log | awk '{print $4}' | sort | uniq -c | sort -rn

# 分析响应时间
grep "REQ_SUCCESS" game_server.log | awk '{print $NF}' | sort -n | tail -10
```

#### 分布式追踪

```java
// 使用追踪 ID 关联日志
public class TraceContext {
    private static ThreadLocal<String> traceId = new ThreadLocal<>();

    public static void setTraceId(String id) {
        traceId.set(id);
    }

    public static String getTraceId() {
        return traceId.get();
    }
}

// 在处理请求时设置
public void handleRequest(Request req) {
    String traceId = req.getTraceId();
    if (traceId == null) {
        traceId = UUID.randomUUID().toString();
    }
    TraceContext.setTraceId(traceId);

    // 转发到其他服务时携带 traceId
    forwardRequest(otherService, req, traceId);
}
```

---

## 🌐 网络调试

### Wireshark 使用

#### 捕获过滤器

```
# 只捕获特定端口
port 9000

# 只捕获特定 IP
host 192.168.1.100

# 组合条件
host 192.168.1.100 and port 9000
```

#### 显示过滤器

```
# TCP 端口过滤
tcp.port == 9000

# IP 地址过滤
ip.addr == 192.168.1.100

# 包含特定数据
data contains "login"

# TCP 标志
tcp.flags.syn == 1
tcp.flags.rst == 1
```

#### 协议分析

1. **查看 TCP 流**
   - 右键数据包 → Follow → TCP Stream
   - 查看完整的请求响应

2. **分析协议结构**
   - 展开数据包详情
   - 查看各层协议信息

3. **时序分析**
   - Statistics → Flow Graph
   - 查看请求响应时序

### tcpdump 命令

```bash
# 捕获特定端口
tcpdump -i eth0 port 9000

# 捕获并保存
tcpdump -i eth0 port 9000 -w capture.pcap

# 显示包内容
tcpdump -i eth0 port 9000 -X

# 只显示特定数量
tcpdump -i eth0 port 9000 -c 100

# 过滤特定 IP
tcpdump -i eth0 host 192.168.1.100 and port 9000
```

### 常见网络问题排查

#### 连接问题
```bash
# 检查端口是否监听
netstat -tlnp | grep 9000

# 检查连接状态
netstat -an | grep 9000

# 测试连接
telnet 192.168.1.100 9000
```

#### 延迟问题
```bash
# 测试延迟
ping 192.168.1.100

# 路由追踪
traceroute 192.168.1.100

# 详细延迟分析
mtr 192.168.1.100
```

---

## 📊 性能分析工具

### 客户端性能分析

#### Nvidia Nsight

**功能**：
- GPU 性能分析
- Draw Call 分析
- 着色器调试
- 帧分析

**使用步骤**：
1. 安装 Nsight Graphics
2. File → Launch Application
3. 选择 MT3Client.exe
4. 开始捕获和分析

#### Intel VTune

**功能**：
- CPU 热点分析
- 线程分析
- 内存访问分析
- 微架构分析

**使用步骤**：
1. 创建新项目
2. 选择分析类型（如 Hotspots）
3. 运行分析
4. 查看结果

### 服务器性能分析

#### perf (Linux)

```bash
# CPU 性能分析
perf record -g java -jar game_server.jar
perf report

# 实时性能统计
perf top -p <pid>

# 生成火焰图
perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

#### async-profiler

```bash
# 启动 profiler
./profiler.sh -d 30 -f profile.svg <pid>

# CPU 分析
./profiler.sh -e cpu -d 30 -f cpu.svg <pid>

# 内存分配分析
./profiler.sh -e alloc -d 30 -f alloc.svg <pid>

# 锁分析
./profiler.sh -e lock -d 30 -f lock.svg <pid>
```

---

## 🎯 调试方法论

### 问题定位步骤

```
1. 复现问题
   └─ 确定复现步骤
   └─ 记录环境信息

2. 收集信息
   └─ 错误日志
   └─ 调用栈
   └─ 系统状态

3. 形成假设
   └─ 可能的原因
   └─ 影响范围

4. 验证假设
   └─ 添加日志
   └─ 调试断点
   └─ 代码审查

5. 修复验证
   └─ 实施修复
   └─ 回归测试
   └─ 代码审查
```

### 常见问题类型和调试策略

| 问题类型 | 调试策略 | 常用工具 |
|---------|---------|---------|
| 崩溃 | 分析调用栈、core dump | VS 调试器、gdb |
| 内存泄漏 | 内存分析工具 | VLD、Valgrind |
| 性能问题 | 性能分析 | JProfiler、perf |
| 死锁 | 线程分析 | VS 并行堆栈、jstack |
| 网络问题 | 抓包分析 | Wireshark、tcpdump |
| 逻辑错误 | 断点调试 | IDE 调试器 |

---

## 🧠 自动进化高价值规则（2026-03 回灌）

来源：`.claude/evolution/evolved/skills/backfill-proposals.md`（2026-03-05）。

### 规则 A：首错优先（confidence=0.84）

- 构建/运行日志优先定位第一条 `error`，不要先处理后续连锁报错。
- 抓取首错前后 `30` 行上下文后再下结论。

示例（PowerShell）：

```powershell
$hit = Select-String -Path .\build.log -Pattern "error " -CaseSensitive | Select-Object -First 1
if ($hit) {
  $start = [Math]::Max(0, $hit.LineNumber - 31)
  Get-Content .\build.log | Select-Object -Skip $start -First 61
}
```

### 规则 B：Exception 观察态（confidence=0.84）

- `Exception` 信号先记录到观测流并关联首错，不直接升格为通用修复规则。
- 样本量不足时禁止“拍脑袋”推广修复模板。

---

## ⚠️ 常见陷阱

### 1. 优化版本行为不同

```cpp
// ❌ 问题：Release 版本行为与 Debug 不同
int uninitializedVar;  // Debug 下可能为 0，Release 下随机值
if (uninitializedVar == 0) {
    // 可能执行，可能不执行
}

// ✅ 解决：总是初始化变量
int initializedVar = 0;
```

### 2. 断点影响时序

```cpp
// ❌ 问题：多线程问题在断点时消失
void Thread1() {
    data = prepare();
    ready = true;  // 断点位置
}

void Thread2() {
    if (ready) {
        process(data);  // 可能访问未准备好的数据
    }
}

// ✅ 解决：使用日志和条件检查
```

### 3. printf 调试隐藏问题

```cpp
// ❌ 问题：printf 改变时序
void update() {
    printf("updating...\n");  // 这行代码本身会影响时序
    // ...
}

// ✅ 解决：使用非阻塞日志
```

### 4. 远程调试端口冲突

```bash
# ❌ 问题：端口被占用
Error: Address already in use: 5005

# ✅ 解决：检查端口占用
netstat -tlnp | grep 5005
# 换一个端口或杀掉占用进程
```

---

## 🎯 实践项目

### 初级项目：定位客户端崩溃
```
任务：排查并修复一个空指针崩溃问题
步骤：
1. 复现崩溃
2. 分析调用栈
3. 使用数据断点定位
4. 修复并验证
评分标准：
- 正确复现问题（20分）
- 调用栈分析（30分）
- 问题定位（30分）
- 修复方案（20分）
```

### 中级项目：排查内存泄漏
```
任务：使用内存调试工具排查泄漏
要求：
- 使用 VLD 或类似工具
- 定位泄漏位置
- 分析泄漏原因
- 修复并验证无泄漏
评分标准：
- 工具使用正确（20分）
- 泄漏定位准确（30分）
- 原因分析清楚（30分）
- 修复彻底（20分）
```

### 高级项目：分布式系统问题诊断
```
任务：排查跨服务的性能问题
要求：
- 使用日志分析
- 网络抓包分析
- 性能分析工具
- 形成完整的问题报告
评分标准：
- 日志分析（20分）
- 网络分析（20分）
- 性能分析（20分）
- 根因定位（25分）
- 报告质量（15分）
```

---

## 📚 推荐资源

### 官方文档
- [Visual Studio Debugger](https://docs.microsoft.com/en-us/visualstudio/debugger/)
- [IntelliJ IDEA Debugging](https://www.jetbrains.com/help/idea/debugging-code.html)
- [Wireshark User's Guide](https://www.wireshark.org/docs/wsug_html/)

### 工具下载
- [Visual Leak Detector](https://vld.codeplex.com/)
- [ZeroBrane Studio](https://studio.zerobrane.com/)
- [JProfiler](https://www.ej-technologies.com/products/jprofiler/overview.html)
- [async-profiler](https://github.com/jvm-profiling-tools/async-profiler)

### 书籍推荐
1. **Advanced Windows Debugging** - Mario Hewardt
2. **Java Performance** - Scott Oaks
3. **Systems Performance** - Brendan Gregg

---

## ✅ 技能检查清单

### 初级检查点
- [ ] 能够设置和使用断点
- [ ] 能够查看变量和表达式
- [ ] 能够分析调用栈
- [ ] 能够使用 print 调试 Lua
- [ ] 能够进行基本的远程调试

### 中级检查点
- [ ] 能够使用条件断点和数据断点
- [ ] 能够使用内存调试工具
- [ ] 能够使用 Wireshark 抓包
- [ ] 能够分析 Java 线程转储
- [ ] 能够使用性能分析工具

### 高级检查点
- [ ] 能够排查复杂的多线程问题
- [ ] 能够进行深度内存泄漏分析
- [ ] 能够排查分布式系统问题
- [ ] 能够使用高级性能分析工具
- [ ] 能够指导他人进行调试

---

## 变更日志

### v1.0.0 (2025-11-24)
- 初始版本
- 包含客户端、服务器端、网络调试内容
- 添加性能分析工具介绍
- 添加实践项目

---

**相关技能**:
- [C++ 开发](../client/cpp-development.md)
- [Java 开发](../server/java-development.md)
- [Lua 脚本](../client/lua-scripting.md)
- [性能优化](performance-optimization.md)

**下次更新**: 2026-02-24

# jauthc - 客户端认证通道库

## 1. 工具概述

### 1.1 用途说明
jauthc (Java Authentication Client) 是一个客户端认证通道的 Java 库实现，专为 MT3 游戏系统的客户端-服务器认证流程设计。该库基于 XIO 网络通信框架，提供以下核心功能：

- **登录认证**：完整的客户端登录流程实现（用户名/密码认证）
- **会话管理**：连接池与会话生命周期管理
- **协议通信**：基于 XIO 的网络协议通信（Challenge-Response 机制）
- **安全特性**：支持多因素认证（手机验证、矩阵卡）
- **调试辅助**：内置 Trace 日志与统计功能

### 1.2 典型使用场景
- **SDK 联调与测试**：客户端 SDK 与服务端认证服务器的集成测试
- **自动化测试**：模拟客户端登录流程，进行自动化测试
- **调试工具**：快速验证认证服务器功能与配置
- **压力测试**：批量并发登录测试，验证服务器容量
- **网络协议开发**：基于 XIO 协议层的网络应用开发基础库

### 1.3 关键特性
- **XIO 协议支持**：完整实现基于 XIO 框架的网络协议通信
- **多认证方式**：支持密码认证、手机验证、矩阵卡等多因素认证
- **会话复用**：连接池与会话管理，支持高并发场景
- **加密通信**：集成安全库（sec_x86.dll/libsec_amd64.so）支持加密传输
- **配置驱动**：通过 XML 配置文件驱动协议定义与连接参数
- **跨平台**：支持 Windows/Linux，自动适配平台相关库

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
jauthc 位于 MT3 服务器架构的**客户端通信层**，与认证服务器（auany/auanymanager）对接：

```
┌─────────────────────────────────────────┐
│        客户端应用 / 测试工具            │
│  (游戏客户端 / SDK / 自动化测试)        │
└──────────────┬──────────────────────────┘
               │ (调用 jauthc.jar)
               ↓
┌─────────────────────────────────────────┐
│           jauthc 认证库                 │
│  - LoginManager (会话管理)              │
│  - LoginIns (登录实例)                  │
│  - ILoginUI (回调接口)                  │
│  - XIO 协议层 (网络通信)                │
└──────────────┬──────────────────────────┘
               │ XIO over TCP (Challenge-Response)
               ↓
┌─────────────────────────────────────────┐
│      认证服务器 (auany/auanymanager)    │
│  - Challenge (挑战)                     │
│  - Response (响应)                      │
│  - KeepAlive (心跳)                     │
│  - KeyExchange (密钥交换)               │
│  - ErrorInfo (错误信息)                 │
└─────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **上游依赖**：
  - **monkeyking.jar**：XIO 网络框架核心库
  - **jio.jar**：Java I/O 扩展库
  - **rpcgen.jar**：协议代码生成工具
  - **安全库**：sec_x86.dll (Windows) / libsec_amd64.so (Linux)
- **下游消费者**：游戏客户端、SDK 测试工具、自动化测试脚本
- **数据流**：
  - 客户端 → jauthc → 认证服务器（登录请求）
  - 认证服务器 → jauthc → 客户端（认证响应、心跳、通知）

### 2.3 关键代码位置
| 功能模块 | 文件路径 | 关键类/方法 |
|---------|---------|------------|
| 引擎入口 | [authc/src/xio/JAuthc.java](authc/src/xio/JAuthc.java) | `start()`, `close()` |
| 登录管理器 | [authc/src/xio/LoginManager.java](authc/src/xio/LoginManager.java) | `newLogin()`, `addXio()`, `removeXio()` |
| 登录实例 | [authc/src/xio/LoginIns.java](authc/src/xio/LoginIns.java) | `start()`, `stop()` |
| UI 回调接口 | [authc/src/xio/ILoginUI.java](authc/src/xio/ILoginUI.java) | `onAuthOk()`, `onAuthError()` |
| 安全辅助 | [authc/src/xio/HelperSecurity.java](authc/src/xio/HelperSecurity.java) | 加密/解密辅助功能 |
| 统计功能 | [authc/src/xio/JStatistic.java](authc/src/xio/JStatistic.java) | 连接统计 |
| 协议层 | [authc/src/gnet/](authc/src/gnet/) | Challenge, Response, KeepAlive 等 |
| 配置文件 | [authc/authc.xio.xml](authc/authc.xio.xml) | 协议定义 |
| 构建配置 | [build.xml](build.xml) | Ant 构建脚本 |
| 测试用例 | [test/TestAuthcOk.java](test/TestAuthcOk.java) | 登录认证测试 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **Java 运行时**：JDK/JRE 1.6 及以上（推荐 JDK 8）
- **核心依赖库**：
  - `monkeyking.jar`：XIO 网络框架
  - `jio.jar`：I/O 扩展库
- **安全库**（可选，用于加密传输）：
  - Windows：`sec_x86.dll`（默认路径：`../../snail/bin/`）
  - Linux：`libsec_amd64.so`
- **网络连接**：可访问认证服务器的 IP 和端口（默认示例：127.0.0.1:10000）

### 3.2 构建时依赖
- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）
- **rpcgen.jar**：协议代码生成工具（位于 `../bin/rpcgen.jar`）
- **协议定义文件**：
  - `gnet.authc.xml`：认证协议定义
  - `gnet.xml`：通用网络协议定义
  - `gnet.openau.xml`：开放认证协议定义

### 3.3 构建步骤

#### 前置准备
确保以下依赖库已存在于 `../bin/` 目录：
```
server/tools/bin/
├── jio.jar
├── monkeyking.jar
└── rpcgen.jar
```

#### 构建流程

**使用 Ant 构建（推荐）**
```bash
# 完整构建（清理 + 生成协议 + 编译 + 打包）
ant dist

# 安装到工具目录
ant install

# 仅清理
ant clean

# 仅编译
ant compile
```

**构建流程详解**（参见 [build.xml](build.xml)）：

1. **初始化阶段**（init）：
   - 创建 `classes/` 编译输出目录
   - 从 `../../server/common/` 复制协议定义文件：
     - `gnet.xml`
     - `gnet.authc.xml`
     - `gnet.openau.xml`

2. **协议生成阶段**（rpcgen）：
   - 使用 `rpcgen.jar` 生成 Java 协议代码
   - 输入：`gnet.authc.xml`
   - 输出：`general/` 目录（协议 Java 类）

3. **编译阶段**（compile）：
   - 编译 `authc/beans/**/*.java` → `classes/beans/`（数据模型）
   - 编译 `authc/src/**/*.java` → `classes/src/`（业务逻辑）
   - 使用 GBK 编码
   - 启用调试信息（lines, source）
   - 最大堆内存：512MB

4. **打包阶段**（dist）：
   - 复制配置文件 `authc/authc.xio.xml` → `classes/authc/authc/`
   - 生成 `jauthc.jar`
   - 包含内容：
     - `classes/src/`：业务逻辑类
     - `classes/beans/`：数据模型类
     - `classes/authc/`：配置文件

5. **安装阶段**（install）：
   - 复制 `jauthc.jar` → `../bin/`

### 3.4 构建参数说明
| 参数 | 说明 | 默认值 |
|-----|------|-------|
| `build` | 编译输出目录 | `classes/` |
| `tools.path` | 工具根目录 | `../` |
| `common.path` | 公共协议定义目录 | `../../server/common` |
| `tools.bin` | 工具二进制目录 | `${tools.path}/bin` |
| `gen.dir` | 协议生成输出目录 | `general` |
| `jauthc.xml` | 认证协议定义文件 | `gnet.authc.xml` |
| `gnet.xml` | 通用协议定义文件 | `gnet.xml` |

---

## 4. 配置与使用

### 4.1 基本使用流程

#### 4.1.1 程序集成方式
```java
import mkio.ILoginIns;
import mkio.ILoginUI;
import mkio.JAuthc;
import mkio.LoginManager;

// 1. 启动认证引擎
JAuthc.start();

// 2. 配置登录参数
ILoginIns.Param param = new ILoginIns.Param();
param.host = "127.0.0.1";       // 认证服务器 IP
param.port = "10000";           // 认证服务器端口
param.username = "testuser";    // 用户名
param.password = "123456";      // 密码
param.iskickuser = true;        // 是否踢出已登录的同名用户

// 3. 实现回调接口（处理认证结果）
ILoginUI callback = new ILoginUI() {
    @Override
    public void onAuthOk(int userid) {
        System.out.println("登录成功，UserID: " + userid);
    }

    @Override
    public void onAuthError(Action a, int e, String detail) {
        System.err.println("登录失败: " + detail);
    }

    @Override
    public void dispatch(Manager manager, Mkio connection, Protocol p) {
        // 协议分发处理
        mkdb.Xdb.executor().execute(p);
    }

    // 其他回调方法...
};

// 4. 创建登录实例并启动
LoginManager loginMgr = JAuthc.getLoginManager();
ILoginIns loginIns = loginMgr.newLogin(param, callback);
loginIns.start();

// 5. 等待认证完成...

// 6. 关闭连接
loginMgr.close(loginIns);

// 7. 关闭引擎
JAuthc.close();
```

#### 4.1.2 配置文件方式
修改 `authc/authc.xio.xml` 自定义网络参数：
```xml
<Connector
    remoteIp="127.0.0.1"         <!-- 默认服务器地址 -->
    remotePort="10000"           <!-- 默认服务器端口 -->
    inputBufferSize="16384"      <!-- 输入缓冲区大小 -->
    outputBufferSize="16384"     <!-- 输出缓冲区大小 -->
    receiveBufferSize="16384"    <!-- 接收缓冲区大小 -->
    sendBufferSize="16384"       <!-- 发送缓冲区大小 -->
    tcpNoDelay="false"           <!-- TCP_NODELAY 选项 -->
/>
```

### 4.2 核心 API 说明

#### 4.2.1 JAuthc 引擎入口
```java
// 启动引擎（使用默认配置）
JAuthc.start();

// 启动引擎（自定义 XIO 配置文件）
JAuthc.start("path/to/custom.xio.xml");

// 启动引擎（自定义配置文件和安全库路径）
JAuthc.start("path/to/custom.xio.xml", "path/to/sec/lib/");

// 关闭引擎
JAuthc.close();

// 开启调试日志
JAuthc.openTraceDebug();

// 关闭调试日志
JAuthc.closeTraceDebug();

// 获取登录管理器
LoginManager loginMgr = JAuthc.getLoginManager();
```

#### 4.2.2 LoginManager 会话管理
```java
// 创建新登录实例
ILoginIns newLogin(ILoginIns.Param param, ILoginUI callback);

// 关闭指定登录实例
void close(ILoginIns ins);

// 关闭所有会话
void closeAll();

// 获取当前会话数量
int size();
```

#### 4.2.3 ILoginIns.Param 登录参数
```java
public static class Param {
    public String host;         // 服务器 IP 地址
    public String port;         // 服务器端口
    public String username;     // 登录用户名
    public String password;     // 登录密码
    public boolean iskickuser;  // 是否踢出已登录用户
}
```

#### 4.2.4 ILoginUI 回调接口
```java
public interface ILoginUI {
    // 认证成功回调
    void onAuthOk(int userid);

    // 认证失败回调
    void onAuthError(Action action, int errorCode, String detail);

    // 手机验证回调
    void onAuthHandSet(int num);

    // 矩阵卡验证回调
    void onAuthMatrixCard(int[] x, int[] y);

    // 禁言/封号通知
    void onAnnounceForbidInfo(char type, int time, int createtime, String reason);

    // 充值卡充值响应
    void onInstantAddCashRep(int retcode, int userid, int reserved);

    // 协议分发处理
    void dispatch(Manager manager, Mkio connection, Protocol p);
}
```

**Action 枚举说明**：
| Action | 含义 | 说明 |
|--------|------|------|
| eConnect | 连接失败 | 无法连接到认证服务器 |
| eServer | 服务器内部错误 | 收到 gnet::ErrorInfo 协议 |
| eNet | 网络错误 | 连接建立后收发异常 |
| eTimeout | 超时错误 | 认证超时 |
| eVersion | 版本不匹配 | 客户端与服务器版本不一致 |
| eProtocol | 协议处理错误 | 协议解析失败 |
| eServerAttr | 服务器属性错误 | 未提供用户账号或服务器禁止登录 |

### 4.3 配置示例

#### 示例 1：单次登录测试
```java
import mkio.ILoginIns;
import mkio.JAuthc;

public class SimpleLoginTest {
    public static void main(String[] args) {
        // 启动引擎
        JAuthc.start();
        JAuthc.openTraceDebug();

        // 配置参数
        ILoginIns.Param param = new ILoginIns.Param();
        param.host = "172.16.0.72";
        param.port = "30010";
        param.username = "player001";
        param.password = "123456";
        param.iskickuser = true;

        // 创建简单回调
        ILoginUI ui = new SimpleLoginUI();

        // 执行登录
        ILoginIns ins = JAuthc.getLoginManager().newLogin(param, ui);
        ins.start();

        // 等待 5 秒
        try { Thread.sleep(5000); } catch (Exception e) {}

        // 关闭
        JAuthc.getLoginManager().close(ins);
        JAuthc.close();
    }
}
```

#### 示例 2：批量并发登录测试
```java
import java.util.ArrayList;
import java.util.List;
import mkio.ILoginIns;
import mkio.JAuthc;

public class ConcurrentLoginTest {
    public static void main(String[] args) {
        JAuthc.start();

        List<ILoginIns> sessions = new ArrayList<>();

        // 创建 100 个并发登录
        for (int i = 0; i < 100; i++) {
            ILoginIns.Param param = new ILoginIns.Param();
            param.host = "127.0.0.1";
            param.port = "10000";
            param.username = "user" + i;
            param.password = "pass" + i;
            param.iskickuser = false;

            ILoginUI callback = new BatchLoginUI();
            ILoginIns ins = JAuthc.getLoginManager().newLogin(param, callback);
            ins.start();
            sessions.add(ins);
        }

        // 等待 10 秒
        try { Thread.sleep(10000); } catch (Exception e) {}

        // 关闭所有会话
        JAuthc.getLoginManager().closeAll();
        JAuthc.close();
    }
}
```

#### 示例 3：自定义 XIO 配置文件
创建 `custom.xio.xml`：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<XioConf name="authc">
    <Manager class="xio.LoginManager" name="LinkClient">
        <Connector
            remoteIp="192.168.1.100"
            remotePort="30010"
            inputBufferSize="32768"
            outputBufferSize="32768"
            receiveBufferSize="32768"
            sendBufferSize="32768"
            tcpNoDelay="true"
        />
    </Manager>
</XioConf>
```

使用自定义配置：
```java
JAuthc.start("./custom.xio.xml");
```

---

## 5. 协议与通信

### 5.1 支持的协议列表
jauthc 支持以下 XIO 协议（定义在 `authc/authc.xio.xml`）：

| 协议名称 | 最大包大小 | 用途说明 |
|---------|-----------|---------|
| Challenge | 65535 | 服务器发起的认证挑战 |
| Response | 65536 | 客户端响应认证挑战 |
| KeepAlive | 16 | 心跳保活协议 |
| KeyExchange | 32 | 密钥交换（加密通信） |
| ErrorInfo | 256 | 服务器错误信息通知 |
| ForceLoginReq | 64 | 强制登录请求 |
| ForceLoginRep | 64 | 强制登录响应 |
| MatrixChallenge | 64 | 矩阵卡挑战 |
| MatrixResponse | 64 | 矩阵卡响应 |
| OnlineAnnounce | 64 | 在线状态通知 |
| AnnounceForbidInfo | 384 | 禁言/封号通知 |
| AddictionControl | 512 | 防沉迷控制 |
| GetUserCouponReq | 32 | 获取用户优惠券请求 |
| GetUserCouponRep | 128 | 获取用户优惠券响应 |
| CouponExchangeReq | 64 | 优惠券兑换请求 |
| CouponExchangeRep | 128 | 优惠券兑换响应 |
| InstantAddCashReq | 128 | 即时充值请求 |
| InstantAddCashRep | 64 | 即时充值响应 |
| SSOGetTicketReq | 2048 | SSO 获取票据请求 |
| SSOGetTicketRep | 2048 | SSO 获取票据响应 |
| PortForward | 65536 | 端口转发 |
| DataBetweenAuAnyAndClient | 1048576 | AuAny 与客户端数据交换 |
| ServerIDResponse | 512 | 服务器 ID 响应 |

### 5.2 认证流程时序图
```
客户端 (jauthc)                    认证服务器 (auany)
    |                                    |
    |--- TCP 连接请求 ------------------>|
    |                                    |
    |<---------- Challenge --------------|  (挑战：随机数、加密参数)
    |                                    |
    |--- Response ---------------------->|  (响应：加密后的用户名/密码)
    |                                    |
    |<---------- KeyExchange ------------|  (可选：密钥交换)
    |                                    |
    |<---------- AuthOk/ErrorInfo -------|  (成功：userid / 失败：错误码)
    |                                    |
    |--- KeepAlive -------------------->|  (定期心跳)
    |<---------- KeepAlive --------------|
    |                                    |
    |--- MatrixResponse --------------->|  (可选：矩阵卡验证)
    |<---------- AuthOk -----------------|
    |                                    |
    |<---------- OnlineAnnounce ---------|  (在线通知)
    |<---------- AnnounceForbidInfo -----|  (可选：封号通知)
    |                                    |
    |--- 断开连接 ---------------------->|
```

### 5.3 协议代码生成
协议类由 `rpcgen.jar` 根据 XML 定义自动生成：

**输入文件**：
- `gnet.authc.xml`：认证协议定义
- `gnet.xml`：通用协议定义
- `gnet.openau.xml`：开放认证协议定义

**生成命令**：
```bash
java -jar rpcgen.jar -java gnet.authc.xml
```

**输出目录**：
- `general/`：生成的 Java 协议类

**生成的协议类示例**：
```
authc/src/gnet/
├── Challenge.java
├── Response.java
├── KeepAlive.java
├── KeyExchange.java
├── ErrorInfo.java
├── MatrixChallenge.java
├── MatrixResponse.java
└── ...
```

---

## 6. 输入输出规范

### 6.1 标准输入格式
jauthc 作为库使用，通过 API 调用传递参数，无标准输入（stdin）。

### 6.2 标准输出格式

#### 6.2.1 成功场景
| 回调方法 | 输出/参数 | 示例 |
|---------|----------|------|
| onAuthOk | `userid`（整数） | `userid=12345` |
| onInstantAddCashRep | `retcode=0, userid, reserved` | `retcode=0, userid=12345, reserved=0` |
| onAnnounceForbidInfo | `type, time, createtime, reason` | `type=1, time=3600, createtime=1623456789, reason="违规发言"` |

#### 6.2.2 失败场景
| 回调方法 | 参数 | 错误码说明 |
|---------|------|-----------|
| onAuthError | `action=eConnect, errorCode=0, detail="连接失败"` | 无法连接到服务器 |
| onAuthError | `action=eServer, errorCode=101, detail="账号不存在"` | 服务器返回业务错误 |
| onAuthError | `action=eTimeout, errorCode=0, detail="认证超时"` | 超过认证时间限制 |
| onAuthError | `action=eVersion, errorCode=0, detail="客户端版本过低"` | 版本不匹配 |
| onAuthError | `action=eProtocol, errorCode=0, detail="协议解析失败"` | 协议格式错误 |

#### 6.2.3 即时充值返回码（InstantAddCashRep）
| retcode | 含义 | 处理建议 |
|---------|------|---------|
| 0 | 成功 | 充值成功 |
| 1 | 卡号不存在 | 提示用户检查卡号 |
| 2 | 用户不存在 | 检查 userid |
| 3 | 充值类型不存在 | 检查充值类型配置 |
| 4 | 余额不足 | 提示余额不足 |
| 5 | 优惠券已过期 | 提示优惠券过期 |
| 6 | 同一卡多次充值限制 | 提示重复充值 |
| 11 | 用户在该服务器上有角色在等待认证 | 稍后再试 |
| 12 | 用户有点卡充值未完成 | 等待完成 |
| 13 | 用户当前状态不能充值 | 检查用户状态 |
| -1 | 内部错误 | 联系管理员 |

### 6.3 日志输出
当开启调试日志（`JAuthc.openTraceDebug()`）时，会输出详细日志：

**日志级别**：
- `Trace.DEBUG`：详细调试信息
- `Trace.INFO`：一般信息（会话创建/销毁）
- `Trace.ERROR`：错误信息

**日志示例**：
```
[INFO] add new Session: [user]:player001
[DEBUG] OnAuthOK , UserID is 12345
[ERROR] OnAuthError: Action: eNet Detail:Connection Failed!! Errcode: 0
[ERROR] del one Session: [user]:player001 [Error]: java.net.SocketException: Connection reset
```

---

## 7. 注意事项

### 7.1 已知限制

#### 功能限制
- **编码固定**：代码使用 GBK 编码，处理非中文字符可能有问题
- **配置加载**：XIO 配置文件路径硬编码，灵活性有限
- **无连接池配置**：连接池参数固定在配置文件中，无法动态调整
- **异常处理简单**：某些异常直接打印堆栈，无详细错误码映射

#### 协议限制
- **仅支持 XIO 协议**：不支持 HTTP/WebSocket 等其他协议
- **协议版本绑定**：客户端与服务器协议版本必须严格匹配
- **包大小限制**：各协议有最大包大小限制（见协议列表）

#### 平台限制
- **安全库依赖**：加密功能依赖平台特定的 .dll/.so 库
- **路径假设**：默认安全库路径为 `../../snail/bin/`，需确保路径正确
- **Windows 路径**：代码中存在硬编码的 Windows 路径（如 `cmd /c del xdb\\mkdb.inuse`）

### 7.2 性能考虑

#### 内存管理
- 编译时最大堆内存：512MB（`build.xml:45,53`）
- 缓冲区大小：默认 16KB（可通过配置文件调整）
- 建议生产环境增大缓冲区至 32KB 或 64KB

#### 网络优化
- **tcpNoDelay**：默认为 `false`，对于交互式应用建议设为 `true`
- **缓冲区调优**：根据网络延迟和带宽调整缓冲区大小
- **KeepAlive**：定期发送心跳，防止连接超时

#### 并发性能
- **会话管理**：使用 `ConcurrentHashMap` 支持高并发
- **临时会话列表**：使用 `synchronized` 同步，可能成为瓶颈
- **建议**：避免同时创建大量会话（建议分批创建）

### 7.3 安全注意事项

#### 凭据管理
- **严禁在代码中硬编码密码**
- 推荐方案：
  - 从配置文件或环境变量读取凭据
  - 使用密钥管理系统（如 HashiCorp Vault）
  - 密码在内存中使用后立即清除（`Arrays.fill(password, (char)0)`）

#### 网络安全
- **明文传输风险**：默认配置下部分数据可能明文传输
- **加密通信**：确保安全库（sec_x86.dll/libsec_amd64.so）正确加载
- **中间人攻击**：建议在 VPN/专网环境中使用
- **证书验证**：生产环境应增加服务器身份验证

#### 错误处理
- **敏感信息泄露**：错误日志可能包含用户名/IP 等信息
- **日志审计**：生产环境关闭调试日志，仅记录必要信息
- **异常堆栈**：避免向客户端暴露详细堆栈信息

### 7.4 故障排查指南

#### 问题 1：连接失败（onAuthError: eConnect）
**症状**：无法连接到认证服务器
**可能原因**：
- 服务器 IP/端口配置错误
- 认证服务器未启动
- 网络不通或防火墙阻止

**排查步骤**：
```bash
# 1. 检查网络连通性
ping 127.0.0.1

# 2. 检查端口是否开放
telnet 127.0.0.1 10000

# 3. 查看服务器端日志
tail -f /path/to/auany/logs/server.log

# 4. 检查 jauthc 配置
cat authc/authc.xio.xml | grep remoteIp
cat authc/authc.xio.xml | grep remotePort
```

#### 问题 2：认证失败（onAuthError: eServer）
**症状**：收到服务器返回的错误信息
**可能原因**：
- 用户名/密码错误
- 账号被封禁
- 服务器内部错误

**解决方案**：
- 检查用户名/密码是否正确
- 查看服务器端日志确认具体错误码
- 联系管理员检查账号状态

#### 问题 3：Jar 包加载失败
**症状**：`ClassNotFoundException` 或 `NoClassDefFoundError`
**解决方案**：
```bash
# 重新构建 Jar 包
ant clean dist

# 验证 Jar 包结构
jar -tf jauthc.jar | head -20

# 检查依赖库
ls -l ../bin/monkeyking.jar
ls -l ../bin/jio.jar

# 确保 CLASSPATH 包含所有依赖
java -cp "jauthc.jar:../bin/monkeyking.jar:../bin/jio.jar" YourTestClass
```

#### 问题 4：安全库加载失败
**症状**：`UnsatisfiedLinkError` 或加密功能异常
**解决方案**：
```bash
# 检查安全库是否存在
ls -l ../../snail/bin/sec_x86.dll        # Windows
ls -l ../../snail/bin/libsec_amd64.so    # Linux

# 自定义安全库路径
JAuthc.start("authc.xio.xml", "/custom/path/to/sec/lib/");

# 检查库依赖
ldd libsec_amd64.so  # Linux
```

#### 问题 5：GBK 编码问题
**症状**：中文字符显示乱码或编译失败
**解决方案**：
```bash
# 确保 Java 编译时使用 GBK 编码
ant clean compile

# 如需修改为 UTF-8（需同步修改服务器端）
# 编辑 build.xml，将 encoding="GBK" 改为 encoding="UTF-8"
```

#### 问题 6：协议版本不匹配（onAuthError: eVersion）
**症状**：客户端与服务器版本不一致
**解决方案**：
- 确保使用最新的协议定义文件（`gnet.authc.xml`）
- 重新生成协议代码：`ant rpcgen`
- 重新构建 Jar 包：`ant clean dist`
- 确认服务器端协议版本一致

---

## 8. 扩展与改进

### 8.1 当前未使用的功能
- **mkio 版本实现**：`authc/src/mkio/` 目录包含与 `xio` 并行的 mkio 实现，当前未使用
- **测试用例**：`test/TestAuthcOk.java` 提供基本测试框架，可扩展更多测试场景
- **安全库加载**：代码中存在安全库加载逻辑（已注释），可根据需要启用

### 8.2 推荐改进方向

#### 短期优化（1-2 周）
1. **配置灵活化**：支持从命令行参数或环境变量读取配置
2. **错误码映射**：建立标准化错误码体系，替代异常堆栈
3. **日志框架集成**：使用 SLF4J/Log4j 替代 `mkdb.Trace`
4. **单元测试完善**：增加协议解析、会话管理等单元测试

#### 中期优化（1-2 个月）
5. **UTF-8 编码支持**：迁移至 UTF-8 编码，提升国际化支持
6. **连接池参数化**：支持通过 API 动态配置连接池参数
7. **协议版本协商**：支持客户端与服务器自动协商协议版本
8. **异步回调优化**：使用 CompletableFuture 或 RxJava 改进回调机制

#### 长期优化（3-6 个月）
9. **多协议支持**：增加 WebSocket/HTTP 协议支持
10. **安全增强**：
    - 集成 TLS/SSL 加密传输
    - 支持 OAuth2/JWT 认证
    - 实现密钥轮换机制
11. **监控与度量**：集成 Prometheus/Micrometer，暴露性能指标
12. **高可用支持**：支持多认证服务器负载均衡与故障切换

### 8.3 参考资料
- **XIO 框架文档**：查看 `monkeyking.jar` 相关文档
- **协议定义规范**：参考 `gnet.authc.xml` 注释
- **测试用例**：[test/TestAuthcOk.java](test/TestAuthcOk.java)

---

## 9. 快速参考

### 9.1 常用代码片段速查表

**基本登录流程**
```java
JAuthc.start();
ILoginIns.Param param = new ILoginIns.Param();
param.host = "127.0.0.1"; param.port = "10000";
param.username = "user"; param.password = "pass";
ILoginIns ins = JAuthc.getLoginManager().newLogin(param, callback);
ins.start();
// ... 等待认证完成 ...
JAuthc.getLoginManager().close(ins);
JAuthc.close();
```

**开启调试日志**
```java
JAuthc.openTraceDebug();
mkdb.Trace.set(mkdb.Trace.DEBUG);
```

**自定义配置文件**
```java
JAuthc.start("custom.xio.xml", "path/to/sec/lib/");
```

**关闭所有会话**
```java
JAuthc.getLoginManager().closeAll();
```

### 9.2 构建命令速查

| 命令 | 用途 |
|-----|------|
| `ant clean` | 清理编译输出 |
| `ant init` | 初始化目录，复制协议文件 |
| `ant rpcgen` | 生成协议代码 |
| `ant compile` | 编译源代码 |
| `ant dist` | 完整构建（清理+生成+编译+打包） |
| `ant install` | 构建并安装到 `../bin/` |

### 9.3 协议类速查

| 功能 | 协议类 | 包名 |
|-----|--------|------|
| 认证挑战 | Challenge | gnet |
| 认证响应 | Response | gnet |
| 心跳 | KeepAlive | gnet |
| 密钥交换 | KeyExchange | gnet |
| 错误信息 | ErrorInfo | gnet |
| 矩阵卡验证 | MatrixChallenge/MatrixResponse | gnet |
| 即时充值 | InstantAddCashReq/InstantAddCashRep | gnet |

### 9.4 错误处理速查

| 错误类型 | Action | 处理建议 |
|---------|--------|---------|
| 连接失败 | eConnect | 检查网络/服务器状态 |
| 服务器错误 | eServer | 查看错误码和详细信息 |
| 网络异常 | eNet | 检查网络稳定性 |
| 认证超时 | eTimeout | 增加超时时间或检查服务器性能 |
| 版本不匹配 | eVersion | 更新客户端或服务器 |
| 协议错误 | eProtocol | 重新生成协议代码 |
| 服务器属性错误 | eServerAttr | 检查服务器配置 |

---

## 10. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | jauthc (Java Authentication Client) |
| **版本** | 见 Jar 文件时间戳（2016-08-03） |
| **主要维护者** | 见项目 Git 提交历史 |
| **代码位置** | `server/tools/jauthc/` |
| **依赖库** | monkeyking.jar, jio.jar, rpcgen.jar |
| **支持平台** | Windows, Linux |
| **Java 版本** | JDK 1.6+ （推荐 JDK 8） |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java, XIO, Ant |

---

## 11. 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue 到项目仓库
- 联系游戏服务器开发团队
- 查看项目 Wiki 获取更多文档
- 参考相关工具文档（jmxc, monkeyking 等）

---

**文档版本**：v1.0
**生成日期**：2025-11-27
**适用版本**：jauthc 2016-08-03 及以后版本

---
name: protocol-design
version: 1.2.0
priority: medium
category: common
description: |
  MT3 协议设计技能。覆盖 gnet RPC、xbean 数据结构、协议演进与兼容策略。
  触发词: 协议, gnet, rpc, xbean, 兼容, protocol.xml, genrpc, RPC定义, 序列化, 反序列化, 跨服通信
dependencies:
  - java-development
  - gnet-framework
  - xbean-system
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 10000
---

# 协议设计指南

**版本**: v1.2.0
**最后更新**: 2026-04-11

---

## 📋 概述

MT3 使用 gnet 框架进行网络协议定义和代码生成，配合 xbean 进行数据序列化。

### 技术栈

```yaml
协议框架: gnet (自研 RPC 框架)
数据格式: xbean (二进制序列化)
代码生成: Ant 任务 (protocol.xml → Java/C++ 代码)
传输层: TCP (自定义协议头)
```

### 核心约束

```yaml
⚠️ 强制规则:
  - ❌ 禁止手动修改生成的协议代码 (rpc/*.java)
  - ✅ 只能修改 protocol.xml，然后重新生成
  - ✅ 协议变更需要同时更新客户端和服务器
  - ✅ 保持向后兼容性（除非大版本更新）
```

---

## 📁 文件结构

```
server/
├── protocols/                      # 协议定义
│   ├── protocol.xml                # 主协议定义文件
│   ├── beans.xml                   # 数据 bean 定义
│   └── ...
├── tools/jgs/                      # 代码生成工具
│   ├── build.xml                   # Ant 构建脚本
│   └── gnet/                       # gnet 代码生成器
├── shared/                         # 生成的共享代码
│   ├── rpc/                        # 协议 RPC 代码 (自动生成)
│   │   ├── *.java                  # ❌ 不可手动修改
│   │   └── ...
│   └── xbean/                      # xbean 数据类 (自动生成)
│       ├── *.java                  # ❌ 不可手动修改
│       └── ...
└── ...

client/
├── FireClient/                     # 客户端协议实现
│   └── protocol/                   # 协议处理代码
└── ...
```

---

## 🔧 协议定义语法

### protocol.xml 基本结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<protocols>
    <!-- 命名空间定义 -->
    <namespace name="fire.pb">

        <!-- 协议模块 -->
        <module name="login">
            <!-- 请求协议 -->
            <protocol name="CLogin" type="request">
                <field name="username" type="string" />
                <field name="password" type="string" />
                <field name="version" type="int" />
            </protocol>

            <!-- 响应协议 -->
            <protocol name="SLoginResult" type="response">
                <field name="result" type="int" />
                <field name="message" type="string" />
                <field name="roleList" type="list<RoleInfo>" />
            </protocol>

            <!-- 通知协议 -->
            <protocol name="SKickOff" type="notify">
                <field name="reason" type="int" />
                <field name="message" type="string" />
            </protocol>
        </module>

    </namespace>
</protocols>
```

### 数据类型

| 类型 | 描述 | Java 类型 |
|-----|------|-----------|
| `int` | 32位整数 | `int` |
| `long` | 64位整数 | `long` |
| `float` | 单精度浮点 | `float` |
| `double` | 双精度浮点 | `double` |
| `bool` | 布尔值 | `boolean` |
| `string` | 字符串 | `String` |
| `bytes` | 字节数组 | `byte[]` |
| `list<T>` | 列表 | `List<T>` |
| `map<K,V>` | 映射 | `Map<K,V>` |
| `BeanType` | xbean 类型 | `BeanType` |

### xbean 数据定义

```xml
<!-- beans.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<xbeans>
    <xbean name="RoleInfo">
        <field name="roleId" type="long" />
        <field name="name" type="string" maxlen="32" />
        <field name="level" type="int" />
        <field name="profession" type="int" />
        <field name="createTime" type="long" />
    </xbean>

    <xbean name="ItemInfo">
        <field name="itemId" type="int" />
        <field name="count" type="int" />
        <field name="bindType" type="int" />
        <field name="attrs" type="map<int,int>" />
    </xbean>
</xbeans>
```

---

## 🚀 代码生成

### 生成命令

```bash
cd server/tools/jgs
ant gnet        # 生成协议代码
ant xbean       # 生成 xbean 代码
ant all         # 生成所有代码
```

### build.xml 任务定义

```xml
<target name="gnet" description="生成协议代码">
    <java classname="gnet.CodeGenerator" fork="true">
        <arg value="-i" />
        <arg value="${basedir}/protocols/protocol.xml" />
        <arg value="-o" />
        <arg value="${basedir}/../shared/rpc" />
        <arg value="-lang" />
        <arg value="java" />
    </java>
</target>
```

---

## 📜 协议使用示例

### 服务器端发送

```java
// 发送登录响应
public void sendLoginResult(Player player, int result, String message) {
    SLoginResult response = new SLoginResult();
    response.setResult(result);
    response.setMessage(message);

    // 填充角色列表
    List<RoleInfo> roleList = new ArrayList<>();
    for (Role role : player.getRoles()) {
        RoleInfo info = new RoleInfo();
        info.setRoleId(role.getId());
        info.setName(role.getName());
        info.setLevel(role.getLevel());
        roleList.add(info);
    }
    response.setRoleList(roleList);

    // 发送给客户端
    player.send(response);
}
```

### 服务器端接收

```java
// 处理登录请求
@Override
public void onCLogin(Player player, CLogin request) {
    String username = request.getUsername();
    String password = request.getPassword();
    int version = request.getVersion();

    // 版本检查
    if (version < MIN_VERSION) {
        sendLoginResult(player, ERROR_VERSION, "版本过低，请更新");
        return;
    }

    // 验证登录
    if (validateLogin(username, password)) {
        sendLoginResult(player, SUCCESS, "登录成功");
    } else {
        sendLoginResult(player, ERROR_AUTH, "用户名或密码错误");
    }
}
```

### 客户端发送 (Lua)

```lua
-- 发送登录请求
local function sendLogin(username, password)
    local req = CLogin.new()
    req.username = username
    req.password = password
    req.version = GAME_VERSION

    Network:send(req)
end
```

### 客户端接收 (Lua)

```lua
-- 注册协议处理器
ProtocolHandler:register("SLoginResult", function(msg)
    if msg.result == 0 then
        -- 登录成功
        print("Login success!")
        for _, role in ipairs(msg.roleList) do
            print("Role: " .. role.name .. " Lv." .. role.level)
        end
    else
        -- 登录失败
        print("Login failed: " .. msg.message)
    end
end)
```

---

## 📋 协议设计原则

### 1. 命名规范

```yaml
客户端发送: C开头 (CLogin, CMove, CAttack)
服务器发送: S开头 (SLoginResult, SMove, SAttack)
通知协议: S开头+Notify后缀 (SChatNotify, SKickNotify)
```

### 2. 字段设计

```yaml
必填字段: 尽量少，核心数据
可选字段: 使用默认值
列表字段: 考虑分页
大数据: 拆分多个协议
```

### 3. 向后兼容

```xml
<!-- ✅ 兼容：新增字段，带默认值 -->
<protocol name="CLogin" type="request">
    <field name="username" type="string" />
    <field name="password" type="string" />
    <field name="version" type="int" default="1" />  <!-- 新增 -->
</protocol>

<!-- ❌ 不兼容：删除或重命名字段 -->
<!-- <field name="passwd" type="string" />  删除 password 不兼容 -->
```

### 4. 错误码设计

```java
// 统一错误码定义
public class ErrorCodes {
    // 通用错误 (0-999)
    public static final int SUCCESS = 0;
    public static final int ERROR_UNKNOWN = 1;
    public static final int ERROR_PARAM = 2;
    public static final int ERROR_TIMEOUT = 3;

    // 登录错误 (1000-1999)
    public static final int ERROR_AUTH = 1000;
    public static final int ERROR_BANNED = 1001;
    public static final int ERROR_VERSION = 1002;

    // 游戏错误 (2000-2999)
    public static final int ERROR_NOT_ENOUGH_MONEY = 2000;
    public static final int ERROR_BAG_FULL = 2001;
}
```

---

## ⚠️ 常见问题

### 1. 协议版本不一致

```yaml
问题: 客户端和服务器协议版本不同导致解析失败
解决:
  1. 同步更新 protocol.xml
  2. 重新生成客户端和服务器代码
  3. 版本号检查
```

### 2. 字段类型修改

```yaml
问题: 修改已有字段类型导致旧客户端无法解析
解决:
  - ❌ 不要修改已有字段类型
  - ✅ 新增字段，弃用旧字段
  - ✅ 或者新建协议版本
```

### 3. 大数据传输

```yaml
问题: 单个协议数据过大，超过 MTU 或缓冲区
解决:
  1. 拆分为多个协议 (分页、分批)
  2. 使用压缩 (gzip)
  3. 增量更新而非全量同步
```

### 4. 列表为空

```lua
-- 检查列表是否为空
if msg.roleList and #msg.roleList > 0 then
    for _, role in ipairs(msg.roleList) do
        -- 处理角色
    end
else
    print("No roles found")
end
```

---

## 🔍 调试技巧

### 1. 协议日志

```java
// 服务器开启协议日志
Logger.getLogger("protocol").setLevel(Level.DEBUG);

// 打印协议内容
log.debug("Received: {}", request.toString());
```

### 2. 抓包分析

```bash
# 使用 Wireshark 抓取 TCP 包
# 过滤: tcp.port == 8080

# 或使用 tcpdump
tcpdump -i eth0 port 8080 -w game.pcap
```

### 3. 模拟发送

```java
// 单元测试中模拟协议
@Test
public void testLogin() {
    CLogin request = new CLogin();
    request.setUsername("test");
    request.setPassword("123456");
    request.setVersion(100);

    // 模拟处理
    handler.onCLogin(mockPlayer, request);

    // 验证响应
    verify(mockPlayer).send(any(SLoginResult.class));
}
```

---

## 📚 相关文档

- [Java 开发指南](../server/java-development.md)
- [gnet 框架指南](../server/gnet-framework.md)
- [xbean 系统指南](../server/xbean-system.md)
- [生成代码规则](../../rules/04-generated-code.md)

---

## 📝 更新日志

| 版本 | 日期 | 变更 |
|-----|------|------|
| 1.0.0 | 2026-01-10 | 初始版本 |

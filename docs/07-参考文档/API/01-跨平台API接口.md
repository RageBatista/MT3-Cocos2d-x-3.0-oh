# 跨平台 API 接口

> **定位**：共享 C++ 客户端网络接口与平台边界参考。
> **当前实现**：Windows、Android、iOS 游戏客户端共同编译 `FireClient/Application` 的 C++ 网络主链。
> **独立组件**：PC Launcher 使用 HTTP/JSON 更新与登录前流程，不走游戏协议主链。
> **维护日期**：2026-07-15

## 1. 当前接口分层

```text
平台壳层（Win32 / Android JNI / iOS ObjC++）
                    │
                    ▼
FireClient/Application 共享 C++ 业务层
                    │
                    ▼
Game::NetConnection : FireNet::ILoginConnection
                    │
                    ▼
FireNet::IConnector / INetIO / INetSystem
                    │
                    ▼
aio::Protocol / aio::LuaProtocol + FireNet::Octets
```

源码纳入三端工程的证据：

- Win32：[`FireClient.win32.vcxproj`](../../../client/MT3Win32App/FireClient.win32.vcxproj) 编译 `NetConnection.cpp`。
- Android：[`Android.mk`](../../../client/FireClient/Android.mk) 编译 `Application/Framework/NetConnection.cpp`。
- iOS：[`project.pbxproj`](../../../client/FireClient/FireClient.xcodeproj/project.pbxproj) 将 `NetConnection.cpp` 加入 Sources。

因此，平台代码主要负责生命周期、SDK、JNI/ObjC++ 回调等壳层职责；游戏连接、协议发送和协议分发进入共享 C++ 主链。

## 2. `NetConnection` 接口

定义：[`NetConnection.h`](../../../client/FireClient/Application/Framework/NetConnection.h)
实现：[`NetConnection.cpp`](../../../client/FireClient/Application/Framework/NetConnection.cpp)

| 接口 | 作用 | 当前落点 |
| --- | --- | --- |
| `send(const aio::Protocol&)` | 发送生成的 C++ 协议对象 | `IConnector::send(protocol)` |
| `luasend(const FireNet::Octets&)` | 发送 Lua 协议字节流 | `IConnector::send(octets)` |
| `DispatchProtocol(...)` | 接收并分发 C++ 协议 | `MessageTask` -> Nuclear 任务队列 |
| `DispatchLuaProtocol(...)` | 接收并分发 Lua 协议 | `LuaMessageTask` -> Nuclear 任务队列 |
| `OnAutoSuccess(...)` | 登录成功回调 | 更新登录状态与区服信息 |
| `OnAutoFailed(...)` | 连接、认证或协议失败回调 | 清理等待 UI，进入退出/重连路径 |
| `close()` | 关闭当前连接 | `IConnector::Close()` |
| `OnSendPing` / `OnRecvPing` | 心跳与网络统计 | 超时计数和延迟统计 |
| `setSecurityType(...)` | 设置收发安全/压缩类型 | Connector 压缩类型接口 |
| `InstantAddCash(...)` | 旧即时充值入口 | 登录模块接口，不是平台 SDK 支付抽象 |

### 2.1 连接创建

构造函数组装 `FireNet::CLoginParam` 后调用：

```cpp
m_login = FireNet::GetNetSystem()->CreateConnector(param, this);
```

连接参数由登录流程传入，包括账号、主机、端口、区服、渠道、连接类型和扩展参数。实际值以 `LoginManager`、`GameApplication` 和当前配置链为准。

### 2.2 发送与接收

```cpp
void NetConnection::send(const aio::Protocol& protocol)
{
    m_login->send(protocol);
}

void NetConnection::luasend(const FireNet::Octets& luaProtocol)
{
    m_login->send(luaProtocol);
}
```

```text
INetIO / aio::Manager 收到数据
        ├─ C++ 协议 -> DispatchProtocol -> MessageTask
        └─ Lua 协议 -> DispatchLuaProtocol -> LuaMessageTask
                                      │
                                      ▼
                              Nuclear 任务队列
```

协议回调先回到共享任务队列，再进入业务或 Lua handler，避免把业务处理直接放在网络 IO 回调中。

## 3. FireNet 接口边界

定义：[`FNet.h`](../../../common/cauthc/net/FNet.h)

- `IConnector`：连接句柄，提供 Start/Close、协议与 Octets 发送、Session/服务器信息、压缩类型和登录模块接口。
- `ILoginConnection`：登录成功/失败、协议分发、心跳、封禁和旧计费回调契约。
- `INetIO`：Session 级发送、关闭、分发和连接。
- `INetSystem`：创建 Connector、处理协议队列、启动与清理网络系统。

业务层通常通过 `NetConnection` 使用这些能力，不直接依赖平台 Socket API。

## 4. 协议定义与生成链

### 4.1 源定义

- `client/FireClient/Application/protocols/*.xml`
- `client/FireClient/Application/client.xml`
- `client/FireClient/Application/modules.xml`
- `client/FireClient/Application/lua_client.xml`
- `client/FireClient/Application/pkg_client.xml`

部分 XML 由 Git LFS 管理；检出为指针时，先恢复 LFS 内容再核对字段。

### 4.2 生成入口

| 入口 | 作用 |
| --- | --- |
| [`genprotocols.sh`](../../../client/FireClient/Application/genprotocols.sh) | 生成 C++ `ProtoDef` |
| [`genluaforproto.sh`](../../../client/FireClient/Application/genluaforproto.sh) | 生成 Lua 协议镜像 |
| [`genprotocol.bat`](../../../client/FireClient/Application/genprotocol.bat) | Windows 下生成 C++、Lua package 与 Lua 协议 |
| [`genprotocolandtolua.bat`](../../../client/FireClient/Application/genprotocolandtolua.bat) | 生成协议并继续执行 tolua 入口 |

生成命令使用仓库内 `rpcgen.jar`，并启用 `-validateMarshal -validateUnmarshal`。`ProtoDef/**` 是生成物，协议字段或编号调整应回到 XML 源定义。

### 4.3 生成对象

[`CEnterWorld.hpp`](../../../client/FireClient/Application/ProtoDef/fire/pb/CEnterWorld.hpp) 继承 `aio::Protocol`，生成片段位于 [`CEnterWorld.inc`](../../../client/FireClient/Application/ProtoDef/rpcgen/fire/pb/CEnterWorld.inc)，包含协议号、字段、校验、`marshal/unmarshal`、Clone 和大小策略。

协议号、字段顺序和校验规则应引用生成物或源 XML，不在本文维护第二份静态表。

## 5. 平台桥接边界

| 范围 | 共享 C++ | 平台壳层 |
| --- | --- | --- |
| 游戏 TCP 连接 | `NetConnection` / FireNet | 平台线程、网络状态与生命周期条件 |
| 游戏协议 | `aio::Protocol`、ProtoDef、Lua protocol | JNI/ObjC++ 传递平台事件 |
| 登录业务状态 | `LoginManager`、`GameApplication` | SDK 登录结果回调 |
| 渠道与支付 SDK | `ChannelManager` 业务入口 | 各渠道 Java/ObjC++ 适配 |
| PC Launcher | 不走游戏 `NetConnection` | Win32 HTTP/JSON 更新与启动 |

支付或登录桥接从 [`ChannelManager.h`](../../../client/FireClient/Application/Framework/3rdplatform/ChannelManager.h) 与具体渠道目录继续追踪，不在网络协议文档中虚构统一的 Java 代理接口。

## 6. 维护约束

1. C++ 协议使用生成类型并调用 `NetConnection::send()`。
2. Lua 协议通过生成定义和 handler 链进入 `luasend/DispatchLuaProtocol`。
3. 协议先改 XML 源定义，再运行生成链；不长期手改 `ProtoDef`。
4. 不在 Java 或 Objective-C 层复制游戏协议序列化。
5. Launcher 的 HTTP/JSON 模型单独维护。
6. 公共头文件或生成物更新按 ABI 与生成代码规则重编。

## 7. 相关文档

- [跨平台数据传输模型](02-跨平台数据传输模型.md)
- [项目架构](../../02-技术架构/02-项目架构.md)
- [跨平台代码流转](../../02-技术架构/专题/01-跨平台代码流转.md)
- [跨平台状态机](../../02-技术架构/专题/04-跨平台状态机.md)
- [文档索引](../02-文档索引.md)

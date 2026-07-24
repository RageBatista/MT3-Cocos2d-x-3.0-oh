---
name: build-server
version: 1.1.0
description: 编译服务器主模块（game_server）
linked-skill: server/ant-build
linked-agent: build-expert
allowed-tools:
  - Bash
---

# 服务器编译命令

**关联技能**: [ant-build](../skills/server/ant-build.md)
**关联代理**: [build-expert](../agents/build-expert.md)

当前仓库主入口为 `server/server/game_server`。

## 代码生成（按需）

```powershell
cd E:/MT3/server/server/game_server
ant genrpc
ant genxdb
ant gengbeans
```

## 完整构建

```powershell
cd E:/MT3/server/server/game_server
ant dist
```

## 结果检查

- `server/serverbin/gs/gsxdb.jar`
- `server/serverbin/gs/lib/*.jar`

根据用户请求执行“仅生成”或“完整构建”，并报告失败阶段与错误摘要。
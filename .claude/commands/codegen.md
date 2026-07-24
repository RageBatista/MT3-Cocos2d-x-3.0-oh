---
name: codegen
version: 1.1.0
description: 生成 gnet/xbean/策划配置代码
linked-skill: server/gnet-framework
linked-skill-2: server/xbean-system
linked-agent: build-expert
allowed-tools:
  - Bash
---

# 代码生成命令

**关联技能**: [gnet-framework](../skills/server/gnet-framework.md), [xbean-system](../skills/server/xbean-system.md)
**关联代理**: [build-expert](../agents/build-expert.md)

## 推荐入口

```powershell
cd E:/MT3/server/server/game_server
```

## 生成命令

```powershell
# 协议相关代码
ant genrpc

# xbean / xtable 相关代码
ant genxdb

# 策划配置相关代码
ant gengbeans
```

## 约束

- 禁止手动修改 `server/**/xbean/*.java` 与 `server/**/rpc/*.java`。
- 必须通过源定义文件（`protocol.main.xml`、`gsx.mkdb.xml.m4` 等）驱动生成。

## 后续验证

```powershell
ant dist
```

执行后输出生成步骤、产物变更范围和后续验证建议。
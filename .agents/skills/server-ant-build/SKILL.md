---
name: server-ant-build
description: "MT3 服务器端 Ant 构建与代码生成技能。处理 `game_server` 构建、`genrpc`、`genxdb`、`gengbeans`、JDK 版本选择或服务端打包问题时使用；不用于客户端平台壳层或运行时业务逻辑问题。"
---

固定服务端链路为 `JDK 1.7/1.8 + Ant`。

## 何时使用

- 服务端构建失败、Ant 任务失败、JDK 版本不匹配
- 协议、xbean、数据库结构或 beans 变更后需要确认生成顺序
- 需要梳理 `build.xml`、生成流程与打包发布链

## 不使用

- 仅处理服务端运行时业务逻辑而不涉及构建或生成链时，不要优先加载本技能
- 客户端平台壳层、Win32/Android 构建或资源热更新问题改用对应技能

## 输入校验

- 先确认主入口是否为 `server/server/game_server/build.xml`
- 先确认本轮是否命中协议/数据结构/beans 变更
- 先拿到首个阻塞证据：Ant 任务失败点、JDK 版本、缺失目标或生成报错
- 可先运行快速体检脚本：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\server-ant-build\scripts\verify-server-ant-chain.ps1
```
- 需要供后续脚本或审计链直接消费时，可追加 `-Json`

## 标准流程

1. 固定服务端链路为 `JDK 1.7/1.8 + Ant`
2. 以 `server/server/game_server/build.xml` 为主入口
3. 协议和数据结构变更后先跑 `genrpc / genxdb / gengbeans`
4. 不把生成产物当成人工维护文件

## 失败处理

- 若失败点还停留在生成物，不要直接修生成结果，先回到源定义与生成入口
- 若构建问题实际来自 JDK/环境变量/Ant 依赖缺失，先修工具链再看业务代码

## 输出与验证

- 输出至少包含：主入口、生成顺序判断、首个阻塞任务、工具链状态、下一步验证命令
- 改动后至少验证一次目标 Ant 任务或完整构建链
- 快速体检脚本固定输出 `STATUS/SUMMARY/DETAIL/NEXT`，优先用于首轮生成链核对
- 若需要机器可读结果，优先使用 `verify-server-ant-chain.ps1 -Json`

## 资源与上下文预算

- 默认只读当前 `build.xml`、相关生成入口和首个失败任务日志
- 不因单次构建失败批量展开整个服务端子树长文

## 深度参考

- `.claude/skills/server/ant-build.md`
- `.claude/skills/server/java-development.md`

# MT3 服务器子树规则

> **定位**: `server/` 的就近规则；默认叠加根 `AGENTS.md` 与 `../.claude/RULES.md`。这里优先把任务拆成“源定义/生成代码/Ant 构建/运行配置”四类。

## 首轮路由

- `server/server/game_server/build.xml`（自仓库根）：服务器主构建与代码生成入口。
- `server/server/game_server/gs/**`：主服务源码、XDB 生成链和打包产物。
- `tools/**`：`monkeyking`、`rpcgen` 等服务端工具链。
- `serverbin/**`：运行时分发产物，不作为长期人工维护主源。

## 本目录硬边界

- 服务端问题先核对 `build.xml`、生成输出、错误日志、配置源与运行产物，再定根因；不要先改生成物或只补表层现象。
- 主线工具链固定为 `JDK 1.7/1.8 + Ant`；不要用 Maven/Gradle 替换主线。
- 生成链目标以 `build.xml` 中的 `genrpc`、`genxdb`、`gengbeans`、`genfiles`、`dist` 为准；协议或数据结构变更后先判定是否需要重新生成。
- `server/**/xbean/*.java` 与 `server/**/rpc/*.java` 默认视为生成物，不做手工长期维护。
- `server/README.md` 可作背景材料，但构建与边界判断以当前 `build.xml`、根 `AGENTS.md` 和 `.claude/RULES.md` 为准。

## 首轮验证入口

从仓库根执行：

```powershell
Get-Item .\server\server\game_server\build.xml
ant -f .\server\server\game_server\build.xml genfiles
ant -f .\server\server\game_server\build.xml dist
```

## 常用技能

- `server-ant-build`
- `generated-code-guard`

---
name: application-core-flow
description: "处理 `gRunGameApplication()` 之后的 MT3 共享 C++ 应用主链。用于启动初始化、登录、入世界、Manager/Framework 协作与 FireClient 主业务模块排障；不用于平台壳层、纯资源发布或纯渲染问题。"
---

主攻共享 C++ 业务主链。只要任务已经进入 `gRunGameApplication()` 之后的 FireClient/Nuclear/Cocos2d-x 共享流程，就优先用本技能。

## 何时使用

- 启动后卡死、初始化失败、登录后不进世界
- 需要梳理 `GameApplication::OnInit(...)` 的阶段依赖
- 需要定位 `Application/Framework`、`Application/Manager`、`Application/SceneObj`、`Application/Battle` 之间的调用关系
- 需要确认共享层 API 锚点和真实模块边界

## 不使用

- 问题仍停留在 `main.cpp`、JNI、`AppDelegate`、WebView、SDK 登录桥接或渠道壳层时，改用 `platform-bridge`
- 问题只涉及 `.layout/.scheme/.looknfeel/.imageset` 资源链或纯渲染显示异常时，改用 `cegui-layout-integration` 或 `rendering-pipeline`
- 症状落在版本索引、PFS、热更新、补丁包或下载器时，改用 `resource-packaging-pipeline`

## 输入校验

- 先确认当前故障阶段：启动初始化、登录、场景切换、入世界、战斗还是 UI/网络消息驱动
- 先确认入口是否已经离开平台壳层并进入共享 C++ 主链
- 先拿到首个阻塞证据：日志、调用栈、报错函数、最近改动文件或明确锚点

## 先做什么

1. 先运行 `scripts/probe-core-flow-entry.ps1`，快速确认 Win32 入口是否已经把控制权交给 `gRunGameApplication()`，以及 `GameApplication.cpp` 的初始化/登录/战斗锚点是否齐备；需要供后续脚本或审计链直接消费时，可追加 `-Json`
2. 若入口仍停在 `main.cpp`、JNI、`AppDelegate`、WebView 或 SDK 登录桥接，改用 `platform-bridge`
3. 再确定问题落在启动初始化、登录、场景切换、战斗、UI 管理还是网络消息驱动
4. 只在需要时继续读取 `references/core-flow.md`

## 常用组合

- 命中 `ProtoDef`、`tolua++` 或协议绑定生成边界时，加 `generated-code-guard`
- 修改中文 Lua、C++、Markdown 或配置说明时，加 `encoding-bom-guard`
- 遇到资源发布、版本包或热更新症状，不要硬归因到业务逻辑，转 `resource-packaging-pipeline`

## 关键锚点

- `client/MT3Win32App/main.cpp`
- `client/FireClient/Application/Framework/GameApplication.cpp`
- `client/FireClient/Application/Manager/LoginManager.cpp`
- `client/FireClient/Application/SceneObj`
- `client/FireClient/Application/Battle`

## 失败处理

- 若故障阶段仍不清晰，先补取证，不要同时修改 `Framework/Manager/SceneObj/Battle` 多域代码
- 若定位过程中命中 `ProtoDef`、`tolua++` 或协议生成边界，立即联动 `generated-code-guard`
- 若长文和调用链仍不足以支撑判断，只补读 `references/core-flow.md` 的相关段落，不批量展开无关文档

## 输出与验证

- 输出至少包含：当前阶段判断、首个阻塞锚点、候选根因、受影响模块、下一步验证命令
- 需要快速确认共享主链骨架时，优先附上 `scripts/probe-core-flow-entry.ps1` 的 `STATUS/SUMMARY/DETAIL/NEXT`
- 若需要机器可读结果，优先使用 `probe-core-flow-entry.ps1 -Json`
- 改动后至少验证一条关键链路：启动初始化、登录成功、进入世界或场景切换中的直接受影响路径

## 资源与上下文预算

- 默认先跑 `scripts/probe-core-flow-entry.ps1`，再只读当前报错文件、相邻调用链和最新日志时间窗
- `references/core-flow.md` 只在锚点不足时按需展开
- 不因单点故障一次性加载整套 `.claude` 长文或跨域技能资料

## 需要时再读

- `references/core-flow.md`

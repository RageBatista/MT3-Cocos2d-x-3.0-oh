# MT3 任务架构分流

## 目的

本文件解释为什么技能体系采用“五域分流”，同时避免把它误写成客户端运行时代码分层。

## 双重视角

- 运行时代码基线：平台层 -> Cocos2d-x 层 -> Nuclear 层 -> FireClient 层
- Agent 任务分域：应用核心层、打包处理层、打包算法层、渲染处理层、平台抽象层

前者是源码事实，后者是为了让 Agent 更快选中正确技能的执行模型。

## 五域与技能映射

| 任务域 | 主技能 | 典型目录 | 典型问题 |
|---|---|---|---|
| 应用核心层 | `application-core-flow` | `client/FireClient/Application/**` | 初始化失败、登录不进世界、场景或战斗逻辑串联异常 |
| 打包处理层 | `resource-packaging-pipeline` | `common/updateengine/**` `client/Launcher/**` `tools/engine/pfs/**` | 热更新失败、版本索引不一致、补丁校验失败 |
| 打包算法层 | `sprite-pack-algorithm` | `tools/engine/SpriteEditor/**` | 图集排布、包体大小、导出异常 |
| 渲染处理层 | `rendering-pipeline` | `engine/**` `tools/CEGUI-0.7.1/**` `client/FireClient/Application/GameUI/**` | UI 不显示、绘制顺序异常、渲染性能问题 |
| 平台抽象层 | `platform-bridge` | `client/MT3Win32App/**` `client/android/**` `client/FireClient/FireClient/**` | JNI/ObjC++ 桥接、SDK 生命周期、平台容器问题 |

## 常用组合

- `application-core-flow + generated-code-guard`：协议、绑定、生成代码边界
- `resource-packaging-pipeline + platform-bridge`：Android/iOS 下载器、热更新接入
- `rendering-pipeline + resource-packaging-pipeline`：渲染异常但怀疑资源包或 PFS 提供器
- `platform-bridge + android-r10e-build`：Android 壳层、JNI 与旧链路构建
- `windows-v120-build + rendering-pipeline`：Win32 构建同时涉及 CEGUI/Nuclear 渲染链

## 最小决策规则

1. 先定主故障域，只选一个主技能。
2. 再按工具链、生成代码、编码风险补辅助技能。
3. 只有主技能正文不足时，才继续读对应 `references/`。

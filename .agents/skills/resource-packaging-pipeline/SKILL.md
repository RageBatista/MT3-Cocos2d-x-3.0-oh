---
name: resource-packaging-pipeline
description: "处理资源打包、PFS、热更新、版本索引、补丁发布与三端下载校验的技能。用于资源发布链路、更新失败、补丁结构问题和上线校验任务；不用于 SpriteEditor 算法细节或共享业务主链问题。"
---

负责“打包处理层”。当问题与资源发布、版本差异、下载器、更新校验、PFS 或上线回滚有关时，优先用本技能。

## 何时使用

- 更新包下载失败、校验失败、解包失败
- `ver.ljvi`、`fl.ljpi`、`UpdateJson`、`PackInfo` 对不齐
- 需要追踪 `Launcher`、`common/updateengine`、Android/iOS 下载器与 PFS 的衔接关系
- 需要做发布前检查、灰度发布或回滚链路分析

## 不使用

- 只改 SpriteEditor 的合图策略、`pack.ini` 或导出算法时，改用 `sprite-pack-algorithm`
- 问题已经进入客户端共享业务主链且与版本/补丁/PFS 无关时，不要留在本技能

## 输入校验

- 先确认问题属于资源生成、版本索引、下载传输、校验解包还是客户端接管阶段
- 先拿到首个阻塞证据：版本文件差异、下载日志、校验失败信息、包结构或平台下载器报错
- 先确认是否需要联动 `platform-bridge`
- 需要做补丁目录预检时，先运行 `powershell -ExecutionPolicy Bypass -File .\.agents\skills\resource-packaging-pipeline\scripts\verify-patch-layout.ps1 [-Path <publish-root>]`
- 需要供后续脚本或审计链直接消费时，可追加 `-Json`

## 先做什么

1. 先确认问题属于资源生成、版本索引、下载传输、校验解包还是客户端接管阶段
2. 仅在资源算法本身需要调整时，转 `sprite-pack-algorithm`
3. 仅在需要深入版本文件、PFS 路径和平台下载器细节时，读取 `references/update-and-pfs.md`

## 常用组合

- Android 渠道包、下载器或 `FileDownloader.java` 相关问题，加 `platform-bridge`
- iOS `FileDownloader.mm`、平台下载回调或桥接问题，加 `platform-bridge`
- 需要追到 SpriteEditor 生成策略、矩形打包或 `pack.ini`，加 `sprite-pack-algorithm`

## 关键锚点

- `common/updateengine`
- `client/Launcher/Code/Update`
- `tools/engine/pfs`
- `client/android/*/FileDownloader.java`
- `common/updateengine/ios/FileDownloader.mm`

## 失败处理

- 若问题实为打包算法质量而非发布链路，不要继续在更新链路硬修
- 若平台下载器和版本包同时异常，先判定主故障域，再拆分后续验证

## 输出与验证

- 输出至少包含：阶段判断、首个阻塞点、受影响产物/索引/下载器、验证建议
- 改动后至少验证一条真实链路：版本对比、包下载、校验解包或客户端接管
- 对发布目录、`ver.ljvi`/`fl.ljpi` 配对和 Android 更新布局的静态核对，优先复用 `scripts/verify-patch-layout.ps1`
- 若需要机器可读结果，优先使用 `verify-patch-layout.ps1 -Json`

## 资源与上下文预算

- 默认只读当前阶段直接相关的版本文件、下载器日志和打包产物
- `references/update-and-pfs.md` 仅在需要完整发布链图时展开

## 需要时再读

- `references/update-and-pfs.md`

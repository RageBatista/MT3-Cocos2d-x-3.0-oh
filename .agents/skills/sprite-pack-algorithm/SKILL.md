---
name: sprite-pack-algorithm
description: "处理 SpriteEditor 打包策略、调用方提供的 `pack.ini`、矩形打包、精灵图集生成与 ANI/XAP 输出。用于打包算法优化、资源体积治理和工具链排障；不用于热更新发布链或客户端运行时 UI 问题。"
---

负责“打包算法层”。只要任务聚焦 SpriteEditor 的资源合图、布局、导出算法或批量配置，就优先用本技能。

## 何时使用

- 需要调整工作区本地 `SpritePackCoreService` 的 `BuildAtlas()`、`RectPacking()`、`PicArrange()` 或 `WriteConvertedAni()`
- 需要优化矩形排布、图集输出质量或包体大小
- 需要核对调用方传入的 `pack.ini` 参数与导出行为
- 需要解释 ANI/XAP 资源如何由编辑器流程生成

## 不使用

- 问题主要在版本包、下载器、热更新或客户端接管链路时，改用 `resource-packaging-pipeline`
- 只是客户端运行时显示异常而未证实来自 SpriteEditor 产物时，不要提前归因到本技能

## 输入校验

- 先确认问题发生在 SpriteEditor 工具层而非发布链或运行时加载链
- 先拿到首个阻塞证据：真实配置路径、导出结果、算法入口函数、产物体积或布局异常
- 先确认 `tools/engine/SpriteEditor/SpritePackCoreService.{h,cpp}` 是否存在；该目录是运行时工作区本地内容，清理 Git 检出中可能不存在
- 先确认是否需要联动 `encoding-bom-guard`
- 需要做 `pack.ini` 预检时，先运行 `powershell -ExecutionPolicy Bypass -File .\.agents\skills\sprite-pack-algorithm\scripts\verify-pack-output.ps1 -ConfigPath <pack.ini>`；其中占位符必须替换为调用方真实路径
- 需要供后续脚本或审计链直接消费时，可追加 `-Json`

## 先做什么

1. 先确认问题在 SpriteEditor 工具层，而不是热更新发布或客户端运行时加载
2. 只分析当前导入模式、矩形排布策略和导出产物，不把发布链路与算法问题混在一起
3. 仓库内没有默认 `pack.ini`；它不是仓库链接，必须使用调用方提供的真实配置路径
4. 需要完整流程、可用性边界和 `pack.ini` 键说明时，再读 `references/spriteeditor-pack.md`

## 常用组合

- 若症状实际出现在版本包、更新包或客户端下载校验，改用 `resource-packaging-pipeline`
- 若修改文档、配置或中文资源说明，联动 `encoding-bom-guard`

## 关键锚点

- `tools/engine/SpriteEditor/SpritePackCoreService.h`（工作区本地，可能缺席）
- `tools/engine/SpriteEditor/SpritePackCoreService.cpp`（工作区本地，可能缺席）
- `docs/08-技术研究/research/sprite-editor/02-完整工作流.md`

## 失败处理

- 若症状无法稳定复现到工具导出层，不要在 `BuildAtlas()`、`RectPacking()` 或 `WriteConvertedAni()` 上猜测式下补丁
- 若异常最终落在发布索引或客户端下载校验，立即切回 `resource-packaging-pipeline`

## 输出与验证

- 输出至少包含：算法入口、产物症状、配置来源、受影响导出行为、验证方式
- 改动后至少验证一个导出结果：图集布局、包体大小、ANI/XAP 产物或 `pack.ini` 驱动行为
- 对 `pack.ini` 语法、关键参数范围和输出路径做静态检查时，优先复用 `scripts/verify-pack-output.ps1`
- 若需要机器可读结果，优先使用 `verify-pack-output.ps1 -Json`

## 资源与上下文预算

- 默认只读当前存在的 `SpritePackCoreService` 入口、调用方提供的 `pack.ini` 和直接相关的产物样本
- `references/spriteeditor-pack.md` 仅在需要完整模式表和参数说明时展开

## 需要时再读

- `references/spriteeditor-pack.md`

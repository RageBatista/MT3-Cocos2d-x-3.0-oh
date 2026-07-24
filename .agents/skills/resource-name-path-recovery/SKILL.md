---
name: resource-name-path-recovery
description: 处理 LJFilePack / SuperLJFilePackUnpack 解包后数字残留、错误扩展名、review/unresolved 收敛、真实文件名与目录路径恢复，以及结果回流到 `unpacked_res`、`dev_res` 和正式报告目录的任务。用于资源真实名称与路径恢复、路径映射补种、语义表回流、同内容减噪、扩展修正和候选分级；不用于纯热更新发布链、运行时渲染故障或共享业务逻辑排障。
---

负责“资源真实名称与路径恢复”这一条证据驱动工作流。目标不是单次把文件“猜对”，而是把恢复链拆成可验证、可回流、可复盘的稳定流程。

## 何时使用

- 解包后大量文件仍是数字名、错误扩展名或落在 `review/unresolved`
- 需要把 `assets/res` 恢复成可用于二次开发的资源树
- 需要把 `auto`、Lua/C++、`tabledef`、模型 layer、GUI layout、路径映射、CRC 规则串成统一证据链
- 需要把恢复结果分成 `accepted / candidate / alias / unresolved` 四类并输出正式报告

## 不使用

- 只做 PFS、热更新、版本索引、补丁发布时，改用 `resource-packaging-pipeline`
- 只做 UI 布局接线、Lua dialog 生命周期或运行时渲染异常时，改用 `cegui-layout-integration`、`lua-dialog-integration`、`rendering-pipeline`
- 只做 Win32/Android/服务端构建排障时，不要停留在本技能

## 输入校验

- 先确认输入根目录、`unpacked_res`、`review/unresolved`、`dev_res`、正式报告目录是否存在
- 先确认当前问题属于哪一类：路径缺失、扩展错误、二进制表未结构化、模型链未打通、重复内容未减噪
- 先拿到首个阻塞证据：`unpack_path_manifest.*`、严格失败诊断、`auto` XML、脚本/引擎调用链、现有正式报告
- 先确认本轮目标是“恢复真实路径”还是“把不可唯一恢复的残留安全剥离出主 backlog”

## 标准流程

1. 先固定基线：确认当前最优解包结果、严格失败清单、`review/unresolved` 数量和正式归档目录。
2. 再建路径证据链：优先用 `unpack_path_manifest.*`、路径 CRC 规则、已有 mapping、客户端代码引用和 `auto` 线索，而不是直接猜目录。
3. 再做结构恢复：文本/XML 走内容回源；二进制表走 `tabledef`、客户端 C++ schema、语义 parser；模型链走 `layerdef.lmx`、`ride*.lmx`、动作名和引擎加载路径。
4. 再做减噪分流：把“唯一同内容命中”移到 `resolved_exact_content_alias`，把“多命中歧义”移到 `resolved_ambiguous_content_alias`，不要继续占用主 `unresolved`。
5. 再做强信号修正：只对 JSON 文本、PNG 魔数、ANI 头、地图 `.dat` 可读副本、稳定二进制 `.dat` 这类高置信条目补扩展并回流。
6. 再做候选升级：像 `sound.inf`、`ridemodel`、地图配置这类有证据但未完全闭环的条目，提升到独立候选目录并写清证据与置信度。
7. 最后回流与验收：同步 `unpacked_res`、`dev_res`、正式报告，更新 manifest、README、统计和剩余 backlog。

## 常用工具

- 路径映射与 seed：`dependencies/SuperLJFilePackUnpack/tools/manifest_seed_pipeline.py`
- 二进制语义：`dependencies/SuperLJFilePackUnpack/tools/extract_semantic_binary_records.py`
- ridemodel 映射：`dependencies/SuperLJFilePackUnpack/tools/extract_ridemodel_mapping.py`
- 减噪分流：`classify_unresolved_exact_matches.py`、`classify_unresolved_ambiguous_matches.py`
- 强信号扩展修正：`integrate_strong_extension_corrections.py`

## 失败处理

- 证据不足时，先停在“候选级”而不是强行并入主资源树
- 同内容但多命中时，先归到 `resolved_ambiguous_content_alias`，不要假装恢复原始路径
- 二进制表结构打不穿时，先做字段级语义导出，再决定是否继续补 parser
- 模型链只追到组件号或 layer 时，先输出上下文映射表，不直接伪造实体目录

## 输出与验证

- 输出至少包含：目标目录、证据来源、恢复/减噪动作、分类结果、剩余 backlog
- 回流到主资源树的每一项都要说明依据：路径命中、内容命中、语义结构、引擎加载逻辑或 `auto` 交叉验证
- 结果至少同步三处：正式报告、`unpacked_res`、`dev_res`
- 若修改 repo-local skill，再补跑 `.claude/scripts/audit_codex_skills.ps1` 与 `.claude/scripts/analyze_codex_skill_workflows.ps1`

## 资源与上下文预算

- 默认只读当前目标直接相关的报告、脚本和代码锚点
- 详细流程、问题分流和质量标准分别放到 `references/`，不要把长报告塞进 `SKILL.md`
- 只有在需要实际执行恢复或分类时，才调用对应工具脚本

## 需要时再读

- `references/recovery-workflow.md`
- `references/problem-playbook.md`
- `references/quality-standards.md`

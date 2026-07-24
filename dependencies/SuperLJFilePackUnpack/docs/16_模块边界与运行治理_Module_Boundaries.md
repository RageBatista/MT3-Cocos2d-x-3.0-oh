# 16 模块边界与运行治理

> 基准日期: 2026-04-24  
> 适用范围: `dependencies/SuperLJFilePackUnpack`

本文补充说明当前 `Unpacker` 的四个核心子模块边界，以及解密 key、路径 seed、源码模板补种、运行时探针和人工审阅回流的治理要求。

## 1. 当前四个核心子模块

### 1.1 索引管理

职责：

- 识别 `.ljpi / .ljzip`
- 读取索引字节流
- 做索引头、长度、CRC、解压边界校验
- 产出 `FileInfo[] + totalBytes`

接口：

- `LoadIndex()`
- `LoadLjpiIndex()`
- `LoadLjzipIndex()`
- `ParseLjpiData()`
- `src/SLJFP_UnpackIndexIO.{h,cpp}`

输入/输出协议：

- 输入：索引路径、CRC/解压/解密依赖、`verifyCRC32`
- 输出：`IndexLoadResult`
- 失败：统一返回 `LJFP_ERR_INDEX_* / LJFP_ERR_CRC32_*`

### 1.2 解密处理

职责：

- 根据 `DecryptMode` 组装候选链路
- 执行 `legacy / clientobf / clientkeyed / passthrough`
- 解压、CRC 对照、探针记录、首个失败样本捕获

接口：

- `BuildDecryptModeCandidates()`
- `DecryptBufferForMode()`
- `DecryptAndDecompress()`
- `SetLastDecryptProbeRecords()`
- `CaptureFirstFailedDecryptDiagnostic()`

输入/输出协议：

- 输入：原始字节、候选模式、`originalSize`、期望 CRC
- 输出：解包后的字节流、`DecryptProbeRecord[]`
- 失败：优先返回真正阻塞后续写盘的首个错误码

### 1.3 路径恢复

职责：

- 基于映射、类型探测和两阶段恢复策略决定写盘路径
- 写出 `CRC -> relative_path` sidecar
- 对根目录数字残留做后处理、别名写出与严格校验

接口：

- `ResolveOutputPathForWrite()`
- `BuildConflictOutputPath()`
- `RefreshOutputPathAuditFinalPaths()`
- `WriteOutputPathManifest()`
- `PostProcessRestoredOutputs()`
- `ValidateRestoreOutcome()`
- `PathMappingGenerator`

输入/输出协议：

- 输入：`FileInfo`、映射表、检测出的扩展、输出根目录、恢复策略开关
- 输出：最终相对路径、实际物理路径、扩展检测结果、冲突消解信息、`unpack_path_manifest.tsv/json`
- 物理状态：`manifest_path`、`review_unresolved_relocated`、`content_deduped_alias`、`missing_physical`
- 失败：冲突无法消解或严格校验失败时返回 `LJFP_ERR_PARTIAL_FAILURE`

### 1.4 审阅输出

职责：

- 聚合失败文件、首个失败样本、路径清单
- 导出 TSV/JSON
- 驱动 GUI 审阅页和问题组复跑

接口：

- `RecordFailedFile()`
- `GetLastFailedFiles()`
- `GetFirstFailedDecryptDiagnostic()`
- `GetLastOutputPathManifestRecords()`
- `WorkflowReviewExportService`
- `WorkflowReviewController`

输入/输出协议：

- 输入：运行时失败事件、路径审计记录、筛选条件
- 输出：结构化失败项 TSV/JSON、首个失败样本 JSON、结果页视图模型

## 2. 解密 Key 获取与管理

优先级固定如下：

1. 显式 `--decrypt-key`
2. `--android-libgame`
3. 自动在输入目录附近查找可提取 key 的 `libgame.so`
4. 历史默认 key 回退

治理要求：

- 日志中必须记录“key 来源”，但不要在调试日志外扩散明文 key
- 默认 key 仅用于兼容历史样本，不能当成长期万能 key 假设
- 运行时 probe 抓到的新 key，应先进入受控报告目录，再决定是否沉淀到测试夹具

## 3. 路径 Seed 生成策略

当前 seed 来源分三类：

- `manifest_seed_pipeline.py` 产出的高置信映射种子
- `source_template_seed_pipeline.py` 从源码/配置提取的模板种子
- 人工确认后回流的权威 `CRC -> path` 条目

使用规范：

- 外部种子优先保留“权威 CRC”，不要重新算 CRC 覆盖原值
- `mapping_conflicts / seed_conflicts` 必须保留，不要静默覆盖
- `direct_hits / hit_gain / merged_hits` 是补种链的核心验收指标

## 4. 源码模板自动补种与版本控制

自动补种主链：

1. 从源码、Lua、配置和 `map.cmapconfig.bin` 提取路径模板
2. 生成 `source_template_reports_*`
3. 产出 `source_template_promoted_*`
4. 仅在命中率提升时加载 promoted mapping

版本控制建议：

- `reports` 和 `promoted` 目录视为运行产物，不直接当源定义
- 真正稳定的模板规则应沉淀在脚本、单测和文档中
- 样本夹具只保留最小可复现集，不把全量运行产物混进源码审查

## 5. 运行时探针与数据采集

当前已有探针：

- `DecryptProbeRecord`
- `DecryptFailureDiagnostic`
- `review_failed_items_all_failed.tsv/json`
- `review_failed_first_decrypt_all_failed.json`
- `unpack_path_manifest.tsv/json`
- `content_deduped_alias` 用于标记同内容根目录残留已被命名物理文件承载，避免误判为数据丢失

后续埋点建议：

- 对 `DecryptMode::Auto` 单独统计 candidate 扩张次数与命中率
- 对 `PostProcessRestoredOutputs()` 单独统计阶段耗时
- 对 `review/unresolved` 按扩展和来源分类计数

最小采集原则：

- 记录首个错误、直接阻塞点、关键样本
- 不把大批量正常样本逐条刷日志

## 6. 人工审阅结果回流

建议统一采用四态：

- `accepted`
- `candidate`
- `alias`
- `unresolved`

处理流程：

1. 自动链先把高置信项写入正式输出或 review bucket
2. 人工确认项回写到权威 mapping/seed 来源
3. 回归测试夹具固化“曾经出错但现在必须稳定”的样本
4. 文档记录为何可自动化、为何仍需人工确认

## 7. `orange_subset` 的回归定位建议

`orange_subset` 的目标不是“证明所有 LJ 包都能 100% 恢复”，而是：

- 固化历史 10/10 内容级恢复基准
- 追踪默认回放与历史基准的差异 CRC
- 确保后续改动至少不再退回 7/10 或更差

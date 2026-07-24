# SuperLJFilePackUnpack

> 基准日期: 2026-04-22
> 代码与目录事实以 `dependencies/SuperLJFilePackUnpack` 当前源码、CMake、测试与清理后的目录状态为准

## 当前定位

`SuperLJFilePackUnpack` 现在是一个完整的资源解包工具链，而不是单一的“解包函数”。

当前目录内实际存在并仍在使用的能力分为 5 层：

1. 核心解包库
   - `SLJFP::Unpacker`
   - 负责索引加载、文件读取、解密、解压、CRC 校验、写盘、路径恢复、审阅数据输出
2. 辅助能力
   - `SLJFP::PathMappingGenerator`
   - `SLJFP::FileTypeDetector`
   - `SLJFP::AndroidBinaryKey`
   - `SLJFP_LibsWrapper`
3. 结果审阅工作流
   - `WorkflowSessionController`
   - `WorkflowPresenter`
   - `WorkflowReviewController`
   - `WorkflowReviewExportService`
4. 交互入口
   - wxWidgets GUI：`ljfp-gui`
     - 实际输出文件名：`LJFilePackUnpacker.exe`
   - 示例 CLI：`ljfp-unpack`
   - 诊断 CLI：`ljfp-unpack-diag`
5. 辅助脚本
   - `tools/manifest_seed_pipeline.py`
   - `tools/runtime/check_adb_frida_env.ps1`
   - `tools/runtime/lj_runtime_key_probe.js`
   - 这些脚本属于开发/排障辅助层，不属于常规交付入口

## 清理后的目录结构

当前源码目录只保留源码、文档、示例、测试和真实在用工具：

```text
SuperLJFilePackUnpack/
├── .gitignore
├── CMakeLists.txt
├── LICENSE
├── README.md
├── cmake/
├── docs/
├── examples/
├── gui/
├── include/
├── libs/
├── src/
├── test/
└── tools/
```

说明：

- `build/`、`test_output/` 现在视为本地生成物，不再作为目录内容保留
- `tools/__pycache__/`、`tools/tests/__pycache__/`、`include/tmp_`、`gui/temp_bom_file` 已清理
- 历史归档文档和失联的独立工具构建脚本已移除
- 路径映射生成不再依赖独立 `PathMappingGenerator.exe`，统一收敛到：
  - GUI 的“生成/合并路径映射”
  - `ljfp-unpack --scan=<resDir>`
  - 直接调用 `SLJFP::PathMappingGenerator`

## 构建目标

顶层 CMake 当前真实目标如下：

- 静态库：`SuperLJFilePackUnpack`
- 示例 CLI：`ljfp-unpack`
- 诊断 CLI：`ljfp-unpack-diag`
- 单元测试：`ljfp-test`
- 测试数据生成器：`ljfp-testgen`
- GUI：`ljfp-gui`（依赖 wxWidgets）
  - 实际输出文件名为 `LJFilePackUnpacker.exe`

仍保留但只作兼容提示的开关：

- `BUILD_CLI`
  - 当前不会生成通用 CLI 主程序，只会输出废弃 warning

常用配置开关：

- `BUILD_EXAMPLES=ON|OFF`
- `BUILD_TESTS=ON|OFF`
- `BUILD_GUI=ON|OFF`

## 核心功能现状

### 1. 索引加载

- 支持 `.ljpi` 明文索引
- 支持 `.ljzip` 加密索引
- `.ljzip` 现在有明确的边界校验：
  - `MagicKey == 9999`
  - 文件总长度至少覆盖头尾
  - `encryptedSize` 不得越界
  - `compressedSize` 必须满足 `0 < compressedSize <= encryptedSize`
  - `originalSize <= MAX_DECOMPRESS_SIZE`
  - `verifyCRC32=true` 时必须提供 `crc32Func`
  - 成功解压后尺寸必须等于 `originalSize`

### 2. 解包执行

- `threadCount <= 1` 走顺序解包
- `threadCount > 1` 走 `UnpackAllParallelOptimized()`
- 支持散文件与 `.ljfp` 包内文件混合读取
- 支持 `Auto / LJFilePackSMS4 / ApkClientObf` 三种解密模式
- 支持流式路径：
  - `UnpackSingleFileStream()`
  - `UnpackSingleFileStreamCompressed()`
- 但流式模式存在明确 fallback 条件，不保证每个文件都能流式完成

### 3. 路径恢复

- 映射加载支持文本和 `.ljpm`
- CLI 与 GUI 都支持生成路径映射
- `forceCrcOutputFirst + restorePathStructureAfterUnpack` 组成当前两阶段恢复主链
- 对“已经能确定真实相对路径模板”的资源，工具现在会直接按
  `CRC32("规范化相对路径") == PathFileNameCRC32`
  做精确命中并落盘
  - 当前已内建并验证的典型场景：
    - `map.cmapconfig.bin` 结构化 `resdir` 驱动的地图资源恢复
    - `map/<resdir>/(regiontypeinfo|jumpblock|island|island2).dat` 这类固定叶子名资源
  - 详细规则见：
    - `docs/13_路径CRC32精确恢复规则_Path_CRC32_Exact_Recovery.md`
- 结果审阅支持：
  - 失败项聚合
  - 定位样本
  - 导出失败清单
  - 对问题组复跑
  - 输出路径清单 `unpack_path_manifest.tsv/json`
    - `physical_path_status` 会区分 `manifest_path`、`review_unresolved_relocated`、`content_deduped_alias`、`missing_physical`
    - `content_deduped_alias` 表示该逻辑记录已被同内容物理文件去重承载，不再按物理缺失处理

### 4. 运行时密钥支持

- 可显式传入解密 key
- 可通过 Android `libgame.so` 自动提取 key
- GUI、CLI 和诊断 CLI 都支持这条链路

## 接口设计概览

最重要的公开接口位于：

- [SLJFP_Unpack.h](include/SLJFP_Unpack.h)
- [SLJFP_PathMappingGenerator.h](include/SLJFP_PathMappingGenerator.h)
- [SLJFP_FileTypeDetector.h](include/SLJFP_FileTypeDetector.h)
- [SLJFP_AndroidBinaryKey.h](include/SLJFP_AndroidBinaryKey.h)

`UnpackOptions` 当前除了基础的 CRC、覆盖、线程、流式外，还实际承载：

- `detectFileType`
- `preferPathMapping`
- `organizeByType`
- `forceCrcOutputFirst`
- `restorePathStructureAfterUnpack`
- `strictRestoreValidation`
- `relocateRootNumericResiduals`
- `writeReviewAliases`
- `writePathManifest`
- `decryptMode`

GUI 并没有把这些高级选项全部做成显式控件；GUI 主要暴露：

- CRC 校验
- 覆盖
- 按类型分类
- 流式模式
- 流式块大小
- 自动加载映射
- 线程数
- 解密模式
- Android `libgame.so` 路径
- 解密 key
- 映射前缀/历史

当前需要特别区分 CLI 与 GUI：

- `ljfp-unpack`
  - 固定启用两阶段恢复：
    - `forceCrcOutputFirst = true`
    - `restorePathStructureAfterUnpack = true`
- GUI
  - 只显式暴露常用开关
  - `forceCrcOutputFirst`、`restorePathStructureAfterUnpack`、`strictRestoreValidation`、`relocateRootNumericResiduals`、`writeReviewAliases` 仍保持默认值

## 数据处理主流程

主流程可以抽象为：

```text
LoadIndex
  -> LoadLjpiIndex / LoadLjzipIndex
  -> ParseLjpiBuffer
  -> FileInfo[]

UnpackAll / UnpackSelected
  -> ReadFileData
  -> DecryptAndDecompress
  -> ResolveOutputPathForWrite
  -> Write file
  -> RefreshOutputPathAuditFinalPaths
  -> WriteOutputPathManifest
  -> Post-process restore stage (optional)
  -> Strict restore validation (optional)
```

如果启用了 `DecryptMode::Auto`，`DecryptAndDecompress()` 会扩展候选链路并保存探针记录，供：

- `GetLastDecryptProbeRecords()`
- `GetFirstFailedDecryptDiagnostic()`

用于失败分析。

## 错误处理现状

错误码以 `LJFP_ERR_*` 为主，`LJFP_ERROR_*` 只是兼容别名。

当前最重要的错误处理点：

- 索引层：
  - 非法格式与坏包尽量在读头阶段直接拒绝
- 数据层：
  - 解密失败、解压失败、CRC32 漂移分离记录
- 执行层：
  - `LJFP_ERR_PARTIAL_FAILURE = 110` 表示流程完成但存在失败文件
- 审阅层：
  - 最近一次失败文件列表
  - 首个失败样本的候选探针记录
  - 输出路径 sidecar 审计

## 当前性能瓶颈

当前真正限制吞吐的，不是“是否开多线程”这么简单，而是以下几个点：

1. `DecryptMode::Auto` 会扩大候选探针链，导致单文件可能经历多次解密/解压尝试
2. 路径恢复后处理是串行阶段，且包含多轮规则推断、内容解析和文件搬移
3. 流式模式在自动解密、块不对齐或 inflate 异常时会 fallback 回普通路径
4. `WriteOutputPathManifest()` 会额外写 TSV + JSON，两份 sidecar 在大批量场景下有固定开销
5. 并行写盘前后的输出路径预留与冲突消解存在共享锁

更详细的现状分析见：

- `docs/07_性能优化_Performance.md`
- `docs/12_现状审计与目录清理报告_Current_State_Audit.md`

## 当前验证基线

2026-04-30 的最新基线验证结果：

- `cmake --build <build> --config Release --target ljfp-test` 通过
- `cmake --build <build> --config Release --target ljfp-unpack` 通过
- `cmake --build <build> --config Release --target ljfp-unpack-diag` 通过
- `cmake --build <build> --config Release --target ljfp-gui` 通过
- `ljfp-test.exe` 全量通过，`283/283`
- `ctest -C Release --output-on-failure` 通过，`2/2`
- `python -m unittest tools/tests/test_manifest_seed_pipeline.py tools/tests/test_source_template_seed_pipeline.py` 通过，`8/8`

## 文档入口

优先阅读：

1. `docs/01_工具概述_Tool_Overview.md`
2. `docs/02_快速开始_Quick_Start.md`
3. `docs/03_API接口_API_Reference.md`
4. `docs/08_GUI使用指南_GUI_User_Guide.md`
5. `docs/12_现状审计与目录清理报告_Current_State_Audit.md`

补充深挖：

- `docs/04_文件格式_File_Format.md`
- `docs/05_解包算法_Unpacking_Algorithm.md`
- `docs/06_错误代码_Error_Codes.md`
- `docs/07_性能优化_Performance.md`
- `docs/09_运行时密钥抓取_Runtime_Key_Probe.md`
- `docs/10_原始打包-逆向解包对照分析__Pack_Unpack_Correspondence_Report.md`
- `docs/15_源码模板补种工作流_Source_Template_Seeding_Workflow.md`
- `docs/16_模块边界与运行治理_Module_Boundaries.md`

工具辅助说明：

- `tools/README.md`
- `tools/runtime/README.md`
- `tools/tests/README.md`

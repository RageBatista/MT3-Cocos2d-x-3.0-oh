# 01 工具概述

> 基准日期: 2026-04-21
> 规范性事实以 `CMakeLists.txt`、`include/*.h`、`src/*.cpp`、`gui/*` 为准

## 1. 工具定位

`SuperLJFilePackUnpack` 当前是一个“解包 + 路径恢复 + 审阅诊断”的组合工具链，服务对象主要有三类：

- 需要集成静态库的开发者
- 需要通过 GUI 分析和恢复资源的排障人员
- 需要用 CLI 批处理和诊断的工程使用者

它不是原始 `LJFilePack` 的打包器，而是面向现有资源包的读取、还原和审阅工具。

## 2. 模块分层

### 2.1 核心库层

- `Unpacker`
  - 索引加载
  - 文件读取
  - 解密与解压
  - 路径解析
  - 写盘
  - 后处理恢复
  - 失败诊断

### 2.2 支撑能力层

- `PathMappingGenerator`
  - 扫描参考资源目录
  - 生成文本 / `.ljpm` 映射
  - 支持兼容 LJFilePack 的路径哈希模式
- `FileTypeDetector`
  - 基于 Magic Number 与文本特征补扩展名
- `AndroidBinaryKey`
  - 从 Android `libgame.so` 自动提取 key
- `SLJFP_LibsWrapper`
  - CRC32 / MiniZ / SMS4 的封装入口

### 2.3 审阅工作流层

- `WorkflowSessionController`
- `WorkflowPresenter`
- `WorkflowReviewController`
- `WorkflowReviewExportService`

这组类型主要供 GUI 结果审阅页使用，用于：

- 汇总失败组
- 生成概览文本
- 管理过滤与选择
- 导出失败项

### 2.4 交互入口层

- GUI：`ljfp-gui`
- CLI：`ljfp-unpack`
- 诊断 CLI：`ljfp-unpack-diag`

### 2.5 辅助脚本层

- `tools/manifest_seed_pipeline.py`
  - 用于根据清单构建高置信映射 seed
- `tools/runtime/check_adb_frida_env.ps1`
- `tools/runtime/lj_runtime_key_probe.js`

## 3. 当前真实目录结构

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

- `build/`、`test_output/` 现在是本地生成物，不再视为目录事实
- `tools/__pycache__/`、`tools/tests/__pycache__/`、`include/tmp_`、`gui/temp_bom_file` 已清理

## 4. 核心执行流

### 4.1 索引加载

```text
LoadIndex
  -> 识别 .ljpi / .ljzip
  -> LoadLjpiIndex / LoadLjzipIndex
  -> ParseLjpiBuffer
  -> 得到 FileInfo[]
```

### 4.2 单文件处理

```text
ReadFileData
  -> DecryptAndDecompress
  -> ResolveOutputPathForWrite
  -> 写出文件
```

### 4.3 批量处理

```text
UnpackAll / UnpackSelected
  -> 顺序路径 或 优化版并行路径
  -> 统计命中率 / 失败项
  -> 写输出路径清单
  -> 后处理恢复（可选）
  -> 严格恢复校验（可选）
```

## 5. 接口设计特点

### 5.1 依赖注入

`Unpacker` 构造时注入 CRC32、压缩、解压、SMS4 函数指针，避免把底层实现写死到类内部。

### 5.2 选项集中

`UnpackOptions` 统一承载：

- 校验策略
- 覆盖策略
- 并行策略
- 流式策略
- 路径恢复策略
- 审阅副产物策略
- 解密模式

需要特别区分 CLI 与 GUI 的默认恢复策略：

- `ljfp-unpack`
  - 固定启用两阶段恢复：`forceCrcOutputFirst = true`、`restorePathStructureAfterUnpack = true`
- GUI
  - 只显式暴露常用开关
  - `forceCrcOutputFirst`、`restorePathStructureAfterUnpack`、`strictRestoreValidation`、`relocateRootNumericResiduals`、`writeReviewAliases` 保持默认值

### 5.3 诊断显式建模

当前并不是只返回一个错误码，而是额外保留：

- `DecryptProbeRecord`
- `DecryptFailureDiagnostic`
- `FailedFileRecord`
- `OutputPathManifestRecord`

这让 GUI 审阅和 CLI 诊断都能直接消费运行结果。

## 6. 错误处理现状

当前错误处理分层比较明确：

- 输入与文件系统错误：`1xx`
- 索引错误：`2xx`
- 解密错误：`3xx`
- 解压错误：`4xx`
- CRC 错误：`5xx`

`.ljzip` 解析现在会在读头阶段尽量拒绝坏包，而不是放到后续解压阶段才爆炸。

## 7. 当前性能特征

已经落地的优化：

- `UnpackAllParallelOptimized()`
- `UnpackSelectedParallelOptimized()`
- `UnpackSingleFileStream()`
- `UnpackSingleFileStreamCompressed()`
- 预创建输出目录
- 输出路径 sidecar 审计

当前瓶颈主要在：

- `DecryptMode::Auto` 的多候选探针
- 路径恢复的串行后处理
- 流式 fallback 回普通路径
- 大批量 sidecar 输出

## 8. 当前不再保留的入口

以下入口不再作为项目现行能力描述：

- 独立 `PathMappingGenerator.exe`
- 仓库内提交的 `build/`
- `BUILD_CLI` 所代表的旧通用 CLI 主程序

路径映射生成当前统一入口是：

- GUI 生成/合并映射
- `ljfp-unpack --scan=<dir>`
- `SLJFP::PathMappingGenerator`

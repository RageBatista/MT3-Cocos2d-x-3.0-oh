# 12 现状审计与目录清理报告

> 审计日期: 2026-04-22
> 审计范围: `dependencies/SuperLJFilePackUnpack`
> 基准来源: 目录盘点、`CMakeLists.txt`、`include/*.h`、`src/*.cpp`、GUI 代码、CLI 示例、单元测试与脚本实跑

## 1. 审计目标

这份报告回答三个问题：

1. 当前工具到底实现了什么
2. 当前目录里哪些内容是源码事实，哪些只是生成物或冗余项
3. 清理完成后，文档应该以什么作为新的真实入口

## 2. 当前功能逻辑总览

### 2.1 核心功能实现

当前主功能由 `SLJFP::Unpacker` 承担，能力包括：

- `.ljpi` / `.ljzip` 索引加载
- 散文件 / `.ljfp` 包文件读取
- SMS4 / 客户端混淆变体解密
- zlib 解压
- CRC32 校验
- 输出路径解析与冲突消解
- 两阶段路径恢复
- 严格恢复校验
- 失败诊断与审阅导出

支持模块：

- `PathMappingGenerator`
  - 扫描参考资源目录
  - 生成文本 / `.ljpm` 映射
  - 支持 `PathHashMode::NormalizedPath` 与 `LjFilePackLegacyAcpExact`
- `FileTypeDetector`
  - 基于 Magic Number 和文本特征补扩展名
- `AndroidBinaryKey`
  - 从 Android `libgame.so` 自动提取解密 key
- GUI 审阅工作流
  - `WorkflowSessionController`
  - `WorkflowPresenter`
  - `WorkflowReviewController`
  - `WorkflowReviewExportService`

### 2.2 接口设计

当前对外接口分为三层：

1. 核心库 API
   - `Unpacker`
   - `PathMappingGenerator`
   - `FileTypeDetector`
   - `AndroidBinaryKey`
2. GUI 调度层
   - `MainFrame`
   - `UnpackThread`
   - `Workflow*`
3. CLI 入口
   - `ljfp-unpack`
   - `ljfp-unpack-diag`
   - `manifest_seed_pipeline.py`

设计特点：

- 底层依赖通过函数指针注入，不把 MiniZ/SMS4/CRC32 硬编码到类模板里
- `UnpackOptions` 集中承载执行策略，而不是把开关散落到多个函数参数
- 失败诊断单独建模为 `DecryptProbeRecord` 和 `DecryptFailureDiagnostic`
- 输出审计单独建模为 `OutputPathManifestRecord`
- GUI 与 CLI 的默认恢复策略不同
  - `ljfp-unpack` 固定启用两阶段恢复
  - GUI 只暴露常用控件，高级恢复项保持默认值

### 2.3 数据处理流程

#### 索引阶段

```text
LoadIndex
  -> 识别 .ljpi / .ljzip
  -> LoadLjpiIndex / LoadLjzipIndex
  -> ParseLjpiBuffer
  -> FileInfo[]
```

#### 解包阶段

```text
UnpackAll / UnpackSelected
  -> ReadFileData
  -> DecryptAndDecompress
  -> ResolveOutputPathForWrite
  -> 写盘
  -> RefreshOutputPathAuditFinalPaths
  -> WriteOutputPathManifest
```

#### 后处理阶段

```text
restorePathStructureAfterUnpack=true
  -> 启动 post-process restore stage
  -> 多轮路径推断 / 补命名 / 去重 / review 归档
  -> strictRestoreValidation（可选）
```

### 2.4 错误处理机制

当前错误处理分为四层：

1. 参数与输入完整性
   - 空索引、找不到索引、索引元数据非法
2. 解密/解压执行错误
   - 解密失败
   - 解压失败
   - 输出尺寸漂移
   - CRC32 不匹配
3. 部分失败聚合
   - `LJFP_ERR_PARTIAL_FAILURE = 110`
4. 审阅数据保留
   - 最近一次失败文件清单
   - 首个失败样本候选探针链
   - 输出路径清单 sidecar

`.ljzip` 读头阶段目前已经明确拒绝：

- 魔数不匹配
- 头尾长度不足
- `encryptedSize` 越界
- `compressedSize == 0`
- `compressedSize > encryptedSize`
- `originalSize > MAX_DECOMPRESS_SIZE`
- `verifyCRC32=true` 但 `crc32Func == nullptr`
- 解压后尺寸与 `originalSize` 不一致

### 2.5 当前性能瓶颈

当前瓶颈不在“基础解包能不能跑”，而在以下阶段：

1. `DecryptMode::Auto`
   - 会扩大候选链路，单文件可能经历多次解密/解压探针
2. 路径恢复后处理
   - 串行执行，包含多轮规则推断、内容读取与文件搬移
3. 流式模式 fallback
   - 自动解密、块不对齐、inflate 异常都会回退到普通路径
4. sidecar 写出
   - `unpack_path_manifest.tsv/json` 会带来固定 I/O
5. 并行写盘冲突控制
   - 输出路径预留、冲突消解和部分审计写入存在共享锁
6. GUI 映射补全
   - `GeneratePathMappingFromReferenceDirs()` 会做多目录扫描、内容样本分析、近邻 seed 合并，必要时再调用 `manifest_seed_pipeline.py`

## 3. 目录清理判定

### 3.1 已删除的低风险冗余项

以下内容已删除：

- `build/`
  - 本地 CMake/VS 生成物
  - 清理前共 `113` 个文件，约 `28.58 MB`
- `tools/__pycache__/`
- `tools/tests/__pycache__/`
- `include/tmp_`
  - 仅包含 UTF-8 BOM 的占位文件
- `gui/temp_bom_file`
  - 仅包含 UTF-8 BOM 的占位文件

### 3.2 明确保留的内容

以下内容保留，因为它们仍承担当前功能：

- `examples/UnpackExample.cpp`
  - 当前主 CLI 示例入口
- `tools/UnpackDiag.cpp`
  - 诊断 CLI
- `tools/manifest_seed_pipeline.py`
  - GUI 清单补种依赖脚本
- `tools/runtime/*`
  - 运行时 key 探测链
- `tools/tests/test_manifest_seed_pipeline.py`
  - 脚本测试
- `docs/09` / `docs/10`
  - 仍有分析参考价值，现已明确降级为“补充深挖文档”

### 3.3 新的目录约束

新增 `.gitignore` 后，以下路径视为本地生成物，不再作为目录事实：

- `build/`
- `build_gui/`
- `test_output/`
- `tools/**/__pycache__/`
- `*.pyc`
- `*.pyo`
- `*.log`
- `install-release/`

## 4. 文档对齐结论

本轮文档对齐后的新规则是：

1. 规范性事实优先看：
   - `README.md`
   - `docs/01`
   - `docs/02`
   - `docs/03`
   - `docs/06`
   - `docs/07`
   - `docs/08`
   - `docs/11`
2. 深挖与逆向分析看：
   - `docs/04`
   - `docs/05`
   - `docs/06_客户端资源读取逻辑分析`
   - `docs/09`
   - `docs/10`
3. 当前目录事实不再包含仓库内已提交的 `build/`
4. 当前命令行入口不再包含独立 `PathMappingGenerator.exe`

## 5. 当前真实状态摘要

截至 2026-04-22，`SuperLJFilePackUnpack` 的真实状态可以简化为：

- 有静态库
- 有 GUI
- 有两个主 CLI 入口
- 有路径映射生成与补种能力
- 有 Android key 自动提取链
- 有失败诊断与结果审阅工作流
- 有 265 个注册测试
- 没有独立的、纳入主构建的 `PathMappingGenerator.exe`
- 不再把仓库内 `build/` 目录视为项目组成部分

## 6. 后续维护建议

为了避免文档再次漂移，后续维护建议遵循：

1. 新增/删除构建目标时，先改 `README.md` 和 `docs/02`
2. 新增/删除公开字段或方法时，先改 `docs/03`
3. 新增错误码或坏包校验时，先改 `docs/06`
4. 增加路径恢复策略或性能调优时，先改 `docs/07`
5. 删除目录或脚本入口时，先改 `docs/README.md` 和本报告

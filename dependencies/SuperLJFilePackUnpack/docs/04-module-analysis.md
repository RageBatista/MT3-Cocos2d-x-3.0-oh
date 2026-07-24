# SuperLJFilePackUnpack 模块功能深度解析

> 本文档基于源代码实际实现编写，确保与代码逻辑 100% 精准同步。
> 生成日期：2026-04-26

---

## 目录

- [1. 核心解包模块 (Unpacker)](#1-核心解包模块-unpacker)
- [2. 索引 I/O 子模块 (UnpackIndexIO)](#2-索引-io-子模块-unpackindexio)
- [3. 源文件 I/O 子模块 (UnpackSourceIO)](#3-源文件-io-子模块-unpacksourceio)
- [4. 库函数包装器 (LibsWrapper)](#4-库函数包装器-libswrapper)
- [5. 文件类型检测器 (FileTypeDetector)](#5-文件类型检测器-filetypedetector)
- [6. Android 密钥提取器 (AndroidBinaryKey)](#6-android-密钥提取器-androidbinarykey)
- [7. 路径映射生成器 (PathMappingGenerator)](#7-路径映射生成器-pathmappinggenerator)
- [8. 工作流呈现器 (WorkflowPresenter)](#8-工作流呈现器-workflowpresenter)
- [9. 审阅控制器 (WorkflowReviewController)](#9-审阅控制器-workflowreviewcontroller)
- [10. 审阅导出服务 (WorkflowReviewExportService)](#10-审阅导出服务-workflowreviewexportservice)
- [11. 日志系统 (Logger)](#11-日志系统-logger)
- [12. 基础算法库](#12-基础算法库)
- [13. GUI 模块](#13-gui-模块)

---

## 1. 核心解包模块 (Unpacker)

**源文件**: `include/SLJFP_Unpack.h`, `src/SLJFP_Unpack.cpp`

### 1.1 模块职责

`Unpacker` 是系统的核心枢纽类，负责协调完整的资源包解包流程，包括：
- 索引加载与解析
- 路径映射加载与匹配
- 文件数据读取、解密、解压
- 输出路径消解与文件写入
- 后处理路径恢复
- 并行/串行解包调度
- 进度回调与暂停/停止控制

### 1.2 关键成员变量

| 成员 | 类型 | 用途 |
|------|------|------|
| `m_crc32Func` | `CRC32_Func` | CRC32 计算函数指针 |
| `m_zipFunc` | `Zip_Func` | 压缩函数指针 |
| `m_unzipFunc` | `UnZip_Func` | 解压函数指针 |
| `m_sms4Func` | `SMS4_Func` | SMS4 加密函数指针 |
| `m_desms4Func` | `DeSMS4_Func` | SMS4 解密函数指针 |
| `m_fileList` | `std::vector<FileInfo>` | 文件索引列表 |
| `m_pathMapping` | `std::map<uint32_t, std::string>` | CRC32→路径映射表 |
| `m_inputDir` | `std::string` | 输入目录 |
| `m_outputDir` | `std::string` | 输出目录 |
| `m_options` | `UnpackOptions` | 运行时选项 |
| `m_shouldStop` | `std::atomic<bool>` | 停止信号 |
| `m_shouldPause` | `std::atomic<bool>` | 暂停信号 |
| `m_progressCallback` | `ProgressCallback` | 进度回调函数 |
| `m_processedFiles` | `uint32_t` | 已处理文件数 |
| `m_failedFiles` | `uint32_t` | 失败文件数 |
| `m_processedBytes` | `uint64_t` | 已处理字节数 |
| `m_reservedOutputPaths` | `std::unordered_map<std::string, uint32_t>` | 输出路径预留表 |
| `m_outputPathAuditRecords` | `std::vector<OutputPathAuditRecord>` | 输出路径审计记录 |
| `m_pathMappingAudit` | `std::vector<PathMappingAuditInfo>` | 路径映射审计信息 |
| `m_streamConsidered` | `std::atomic<uint32_t>` | 流式模式考虑计数 |
| `m_streamUsed` | `std::atomic<uint32_t>` | 流式模式使用计数 |
| `m_streamSkipEncryptedUnaligned` | `std::atomic<uint32_t>` | 非对齐加密跳过计数 |
| `m_streamFallback` | `std::atomic<uint32_t>` | 流式回退计数 |
| `m_lastDecryptProbeRecords` | `std::vector<DecryptProbeRecord>` | 最近解密探测记录 |
| `m_lastFailedFiles` | `std::vector<std::pair<size_t, int>>` | 最近失败文件记录 |

### 1.3 核心业务逻辑

#### 解密探测引擎

`DecryptAndDecompress` 方法实现了多候选解密探测机制：

1. **候选构建** (`BuildDecryptProbeCandidates`)：根据 `DecryptMode` 和文件特征构建候选链路
2. **候选执行**：对每个候选执行解密→解压→CRC32校验
3. **候选选择**：第一个通过 CRC32 校验的候选被选中
4. **探测记录**：每个候选的执行细节记录到 `DecryptProbeRecord`，用于诊断

#### 路径恢复引擎

`PostProcessRestoredOutputs` 方法实现了3轮迭代的内容启发式路径恢复：

1. **映射匹配轮**：使用预加载的 CRC32→路径映射表
2. **扩展名检测轮**：基于 Magic Number 检测文件类型并添加扩展名
3. **内容分析轮**：解析文件内容提取引用关系，推断原始路径

#### 并行解包引擎

`UnpackAllParallelOptimized` 方法实现了基于任务队列的并行解包：

1. **任务队列**：将文件索引放入共享队列
2. **工作线程**：N 个工作线程从队列取任务执行
3. **统计同步**：`statsMutex` 保护共享统计变量
4. **进度通知**：每个文件完成后触发进度回调
5. **协作取消**：每个文件处理前检查 `m_shouldStop`

---

## 2. 索引 I/O 子模块 (UnpackIndexIO)

**源文件**: `src/SLJFP_UnpackIndexIO.h`, `src/SLJFP_UnpackIndexIO.cpp`

### 2.1 模块职责

负责解析 LJFilePack 索引文件，支持两种格式：
- `.ljpi` — 明文二进制索引
- `.ljzip` — 加密压缩索引

### 2.2 核心数据结构

```cpp
struct IndexLoadDependencies {
    DeSMS4_Func deSMS4Func;
    UnZip_Func unZipFunc;
    CRC32_Func crc32Func;
    std::string decryptKey;
};

struct IndexLoadResult {
    std::vector<FileInfo> fileList;
};
```

### 2.3 业务逻辑

**.ljpi 解析流程**:
1. 读取 4 字节 `fileCount`
2. 循环读取每个 `FileInfo` 的字段
3. `PackIndex > 0` 时读取 `Pos` 字段
4. `CompressType > 0 || CodeType > 0` 时读取 `SizeOriginal` 和 `CRC32Original`
5. 否则 `SizeOriginal = Size`, `CRC32Original = CRC32`

**.ljzip 解析流程**:
1. 读取 4 字节 `magicKey`，校验值是否为 9999
2. 读取 `encryptedSize` 和加密数据
3. 调用 `DeSMS4Func` 解密
4. 读取 `compressedSize`、`originalSize`、`originalCRC32`
5. 调用 `UnZipFunc` 解压
6. 调用 `CRC32Func` 校验
7. 调用 `ParseLjpiBuffer` 解析解压后的索引数据

---

## 3. 源文件 I/O 子模块 (UnpackSourceIO)

**源文件**: `src/SLJFP_UnpackSourceIO.h`, `src/SLJFP_UnpackSourceIO.cpp`

### 3.1 模块职责

负责构建源文件路径并读取文件数据，处理散文件和包内文件两种情况。

### 3.2 路径构建规则

| 条件 | 路径格式 | 说明 |
|------|----------|------|
| `PackIndex == 0` | `{inputDir}/{PathFileNameCRC32}` | 散文件，直接以 CRC32 数字为文件名 |
| `PackIndex > 0` | `{inputDir}/{PackIndex}.ljfp` | 包文件，多个文件共享一个 .ljfp 包 |

### 3.3 读取策略

- **散文件**：读取完整文件内容（`FileSize` 字节）
- **包内文件**：打开 .ljfp 文件，seek 到 `Pos` 偏移，读取 `Size` 字节

---

## 4. 库函数包装器 (LibsWrapper)

**源文件**: `include/SLJFP_LibsWrapper.h`, `src/SLJFP_LibsWrapper.cpp`

### 4.1 模块职责

提供三种 SMS4 解密策略的封装，屏蔽底层 `LJFP_SMS4` 类的使用细节。

### 4.2 三种解密策略对比

| 策略 | 函数 | 密钥来源 | 适用场景 |
|------|------|----------|----------|
| Legacy | `SLJFP_DeSMS4BlocksLegacy` | 默认硬编码密钥 | 原始 LJFilePack 打包格式 |
| ClientObf | `SLJFP_DeSMS4BlocksClientObf` | APK 客户端混淆密钥 | APK 客户端打包格式 |
| ClientKeyed | `SLJFP_DeSMS4BlocksClientKeyed` | 从 APK 提取的密钥 | 使用自定义密钥的 APK 客户端 |

### 4.3 解密流程

```
输入: inBuff[uiSize], ouBuff[uiSize], strPassword
  │
  ▼
构造 SMS4 对象: SMS4(key = strPassword.c_str())
  │
  ▼
循环: offset = 0; offset < uiSize; offset += 16
  │
  ├── sms4.Decrypt(inBuff + offset, ouBuff + offset)
  │
  └── 继续下一个 16 字节分组
```

---

## 5. 文件类型检测器 (FileTypeDetector)

**源文件**: `include/SLJFP_FileTypeDetector.h`, `src/SLJFP_FileTypeDetector.cpp`

### 5.1 模块职责

基于文件内容的 Magic Number 签名检测文件类型，返回对应的扩展名。

### 5.2 支持的文件类型

| Magic Number | 文件类型 | 扩展名 |
|-------------|----------|--------|
| `89 50 4E 47` | PNG 图像 | `.png` |
| `FF D8 FF` | JPEG 图像 | `.jpg` |
| `47 49 46 38` | GIF 图像 | `.gif` |
| `42 4D` | BMP 图像 | `.bmp` |
| `49 49 2A 00` / `4D 4D 00 2A` | TIFF 图像 | `.tiff` |
| `52 49 46 46...57 45 42 50` | WebP 图像 | `.webp` |
| `44 44 53 20` | DDS 纹理 | `.dds` |
| `4F 67 67 53` | OGG 音频 | `.ogg` |
| `FF FB` / `FF F3` / `49 44 33` | MP3 音频 | `.mp3` |
| `52 49 46 46...57 41 56 45` | WAV 音频 | `.wav` |
| `66 4C 61 43` | FLAC 音频 | `.flac` |
| `50 4B 03 04` | ZIP 压缩包 | `.zip` |
| `3C 3F 78 6D 6C` / `EF BB BF 3C` | XML 文档 | `.xml` |
| `7B` (JSON 对象) | JSON 文档 | `.json` |
| `1B 4C 75 61` | Lua 字节码 | `.luac` |
| `00 01 00 00` | TrueType 字体 | `.ttf` |
| `4F 54 54 4F` | OpenType 字体 | `.otf` |
| `78 9C` / `78 01` | zlib 压缩数据 | `.zlib` |
| `CA FE BA BE` | Java Class | `.class` |
| `DE AD BE EF` | 二进制表 | `.bin` |

### 5.3 检测策略

1. 首先检查数据前几个字节是否匹配已知 Magic Number
2. 对于 XML，额外检查 UTF-8 BOM (`EF BB BF`) 后跟 `<` 的情况
3. 对于 JSON，检查首字节为 `{` 且后续内容包含 JSON 特征字符
4. 对于 Lua 脚本（非字节码），检查是否包含 `function`/`local`/`return` 等关键字
5. 如果所有签名都不匹配，返回空字符串

---

## 6. Android 密钥提取器 (AndroidBinaryKey)

**源文件**: `include/SLJFP_AndroidBinaryKey.h`, `src/SLJFP_AndroidBinaryKey.cpp`

### 6.1 模块职责

从 Android APK 客户端的 `lib/armeabi-v7a/libgame.so` 中提取 SMS4 解密密钥。

### 6.2 提取流程

```
APK 文件 (ZIP 格式)
    │
    ▼
解压 lib/armeabi-v7a/libgame.so
    │
    ▼
在 .so 二进制中搜索密钥特征模式
    │
    ├── 搜索 SMS4 密钥初始化代码段
    ├── 识别密钥数据引用
    └── 提取 16 字节密钥数据
    │
    ▼
返回密钥字符串
```

---

## 7. 路径映射生成器 (PathMappingGenerator)

**源文件**: `include/SLJFP_PathMappingGenerator.h`, `src/SLJFP_PathMappingGenerator.cpp`

### 7.1 模块职责

从客户端资源目录结构生成 CRC32→路径映射表，用于解包后恢复原始文件路径。

### 7.2 生成流程

```
资源目录 (dev_res/)
    │
    ▼
递归遍历所有文件
    │
    ▼
对每个文件的相对路径计算 CRC32
    │
    ▼
构建 CRC32 → 相对路径 映射
    │
    ▼
输出映射表文件 (文本或 .ljpm 二进制)
```

---

## 8. 工作流呈现器 (WorkflowPresenter)

**源文件**: `include/SLJFP_WorkflowPresenter.h`, `src/SLJFP_WorkflowPresenter.cpp`

### 8.1 模块职责

协调解包工作流各阶段的执行顺序，管理阶段间的状态转换。

### 8.2 工作流阶段

| 阶段 | 说明 |
|------|------|
| `Idle` | 空闲状态 |
| `LoadingIndex` | 加载索引文件 |
| `LoadingMapping` | 加载路径映射 |
| `Configuring` | 配置解包选项 |
| `Unpacking` | 执行解包 |
| `PostProcessing` | 后处理路径恢复 |
| `Reviewing` | 审阅解包结果 |
| `Exporting` | 导出审阅报告 |
| `Completed` | 完成 |
| `Error` | 错误状态 |

### 8.3 阶段转换

```
Idle → LoadingIndex → LoadingMapping → Configuring → Unpacking
  → PostProcessing → Reviewing → Exporting → Completed
```

任何阶段均可转换到 `Error` 状态。

---

## 9. 审阅控制器 (WorkflowReviewController)

**源文件**: `include/SLJFP_WorkflowReviewController.h`, `src/SLJFP_WorkflowReviewController.cpp`

### 9.1 模块职责

管理解包结果的审阅流程，对未恢复路径的文件进行归类和分析。

### 9.2 审阅分类

| 分类 | 说明 |
|------|------|
| `ExactMatch` | 路径映射完全匹配 |
| `ExtensionDetected` | 通过 Magic Number 检测到扩展名 |
| `ContentHeuristic` | 通过内容启发式推断路径 |
| `Unresolved` | 未能恢复路径 |
| `ConflictResolved` | 冲突消解后的路径 |

---

## 10. 审阅导出服务 (WorkflowReviewExportService)

**源文件**: `include/SLJFP_WorkflowReviewExportService.h`, `src/SLJFP_WorkflowReviewExportService.cpp`

### 10.1 模块职责

将审阅结果导出为结构化文件，支持 TSV 和 JSON 两种格式。

### 10.2 导出格式

**TSV 格式**:
```
CRC32\tSourceKind\tRawMappingPath\tNormalizedPath\tWrittenPath\tFinalPath\tStatus
```

**JSON 格式**:
```json
{
  "exportTime": "2026-04-26T00:00:00",
  "totalFiles": 1000,
  "resolvedFiles": 800,
  "unresolvedFiles": 200,
  "records": [
    {
      "pathCRC32": "0x0A1B2C3D",
      "sourceKind": "ExactMatch",
      "rawMappingPath": "ui/layouts/main.layout",
      "normalizedRelativePath": "ui/layouts/main.layout",
      "writtenRelativePath": "ui/layouts/main.layout",
      "finalRelativePath": "ui/layouts/main.layout",
      "mappingSanitized": false,
      "conflictResolved": false,
      "existingTargetPreserved": false,
      "postProcessMoved": true
    }
  ]
}
```

---

## 11. 日志系统 (Logger)

**源文件**: `include/SLJFP_Logger.h`, `include/SLJFP_Logger_Impl.h`

### 11.1 模块职责

提供分级日志输出功能，支持编译期和运行时日志级别控制。

### 11.2 日志级别

| 级别 | 宏 | 说明 |
|------|-----|------|
| TRACE | `LJFP_LOG_TRACE` | 详细跟踪信息 |
| DEBUG | `LJFP_LOG_DEBUG` | 调试信息 |
| INFO | `LJFP_LOG_INFO` | 一般信息 |
| WARN | `LJFP_LOG_WARN` | 警告信息 |
| ERROR | `LJFP_LOG_ERROR` | 错误信息 |
| FATAL | `LJFP_LOG_FATAL` | 致命错误 |

### 11.3 实现方式

- 编译期：通过预处理器宏控制是否编译日志语句
- 运行时：通过全局日志级别变量过滤输出
- 输出目标：`stderr` 或可配置的文件输出

---

## 12. 基础算法库

### 12.1 LJFP_CRC32

**源文件**: `libs/ljfp/LJFP_CRC32.h`

**实现方式**: 查表法，使用预计算的 256 项 CRC32 查找表。

**核心函数**:
```cpp
uint32_t LJFP_CRC32(uint32_t crc, const unsigned char* buf, unsigned int len);
```

**算法**: 标准 CRC32 (ISO 3309 / ITU-T V.42)，多项式 `0xEDB88320`。

### 12.2 LJFP_SMS4

**源文件**: `libs/ljfp/LJFP_SMS4.h`

**实现方式**: 国密 SMS4 对称加密算法，128 位密钥，32 轮 Feistel 结构。

**核心函数**:
```cpp
void SMS4::Encrypt(unsigned char* input, unsigned char* output);
void SMS4::Decrypt(unsigned char* input, unsigned char* output);
```

**密钥扩展**: 32 轮轮密钥 `rk[0..31]`，使用 FK 和 CK 常量。

### 12.3 LJFP_MiniZ

**源文件**: `libs/ljfp/LJFP_MiniZ.h`

**实现方式**: MiniZ 库，zlib 兼容的压缩/解压实现。

**核心函数**:
```cpp
int LJFP_MiniZ_Compress(unsigned char* pDest, unsigned long* pDest_len,
                          const unsigned char* pSource, unsigned long source_len);
int LJFP_MiniZ_Uncompress(unsigned char* pDest, unsigned long* pDest_len,
                            const unsigned char* pSource, unsigned long source_len);
```

### 12.4 LJFP_FileUtil

**源文件**: `libs/ljfp/LJFP_FileUtil.h`

**核心功能**:
- 文件读写操作
- 目录创建与遍历
- 路径规范化与拼接
- 文件大小查询

### 12.5 LJFP_StringUtil

**源文件**: `libs/ljfp/LJFP_StringUtil.h`

**核心功能**:
- 字符串分割与拼接
- 大小写转换
- 前后缀修剪
- 格式化输出

### 12.6 LJFP_Var

**源文件**: `libs/ljfp/LJFP_Var.h`

**核心功能**: 变体类型封装，支持整数、浮点、字符串等类型的动态存储。

---

## 13. GUI 模块

### 13.1 SLJFP_App

**源文件**: `gui/SLJFP_App.cpp`

**职责**: wxWidgets 应用入口，初始化主窗口。

### 13.2 SLJFP_MainFrame

**源文件**: `gui/SLJFP_MainFrame.h`, `gui/SLJFP_MainFrame.cpp`

**职责**: 主窗口框架，提供以下 UI 控件：
- 索引文件选择与加载
- 路径映射文件选择与加载
- 解包选项配置面板
- 解包进度显示
- 审阅结果展示
- 日志输出面板

**关键交互**:
- 持有 `Unpacker*` 实例，直接调用其 API
- 持有 `SLJFP_WorkflowPresenter*` 实例，驱动工作流
- 通过 `ProgressCallback` 更新进度条
- 通过 `wxThreadEvent` 在工作线程和 UI 线程间通信

### 13.3 SLJFP_ProgressDialog

**源文件**: `gui/SLJFP_ProgressDialog.h`, `gui/SLJFP_ProgressDialog.cpp`

**职责**: 模态进度对话框，显示解包进度条和取消按钮。

### 13.4 SLJFP_WorkflowSession

**源文件**: `gui/SLJFP_WorkflowSession.h`

**职责**: 工作流会话数据容器，在 GUI 层与 Workflow 层间传递状态。

---

## 文档与代码映射关系

| 文档章节 | 对应源文件 |
|----------|-----------|
| 1. 核心解包模块 | `include/SLJFP_Unpack.h`, `src/SLJFP_Unpack.cpp` |
| 2. 索引 I/O | `src/SLJFP_UnpackIndexIO.h`, `src/SLJFP_UnpackIndexIO.cpp` |
| 3. 源文件 I/O | `src/SLJFP_UnpackSourceIO.h`, `src/SLJFP_UnpackSourceIO.cpp` |
| 4. 库函数包装器 | `include/SLJFP_LibsWrapper.h`, `src/SLJFP_LibsWrapper.cpp` |
| 5. 文件类型检测 | `include/SLJFP_FileTypeDetector.h`, `src/SLJFP_FileTypeDetector.cpp` |
| 6. Android 密钥 | `include/SLJFP_AndroidBinaryKey.h`, `src/SLJFP_AndroidBinaryKey.cpp` |
| 7. 路径映射生成 | `include/SLJFP_PathMappingGenerator.h`, `src/SLJFP_PathMappingGenerator.cpp` |
| 8. 工作流呈现 | `include/SLJFP_WorkflowPresenter.h`, `src/SLJFP_WorkflowPresenter.cpp` |
| 9. 审阅控制器 | `include/SLJFP_WorkflowReviewController.h`, `src/SLJFP_WorkflowReviewController.cpp` |
| 10. 审阅导出 | `include/SLJFP_WorkflowReviewExportService.h`, `src/SLJFP_WorkflowReviewExportService.cpp` |
| 11. 日志系统 | `include/SLJFP_Logger.h`, `include/SLJFP_Logger_Impl.h` |
| 12. 基础算法库 | `libs/ljfp/LJFP_*.h` |
| 13. GUI 模块 | `gui/SLJFP_*.{h,cpp}` |

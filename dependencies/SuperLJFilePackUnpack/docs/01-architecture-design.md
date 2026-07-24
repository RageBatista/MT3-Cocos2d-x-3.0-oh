# SuperLJFilePackUnpack 分层架构设计详解

> 本文档基于源代码实际实现编写，确保与代码逻辑 100% 精准同步。
> 生成日期：2026-04-26
> 源码根目录：`dependencies/SuperLJFilePackUnpack/`

---

## 目录

- [1. 系统整体架构蓝图](#1-系统整体架构蓝图)
- [2. 分层结构详解](#2-分层结构详解)
- [3. 设计模式应用](#3-设计模式应用)
- [4. 模块间交互接口与通信机制](#4-模块间交互接口与通信机制)
- [5. 核心类继承体系](#5-核心类继承体系)
- [6. 函数调用链与关键路径](#6-函数调用链与关键路径)

---

## 1. 系统整体架构蓝图

SuperLJFilePackUnpack 是 MT3 项目资源包逆向解包工具，负责将 LJFilePack 格式的加密压缩资源包还原为原始文件。系统采用**四层架构**设计：

```
┌─────────────────────────────────────────────────────────────────┐
│                     GUI 表现层 (Presentation)                    │
│  SLJFP_App · SLJFP_MainFrame · SLJFP_ProgressDialog             │
├─────────────────────────────────────────────────────────────────┤
│                   工作流控制层 (Workflow)                         │
│  SLJFP_WorkflowPresenter · SLJFP_WorkflowReviewController       │
│  SLJFP_WorkflowReviewExportService · SLJFP_WorkflowSession      │
├─────────────────────────────────────────────────────────────────┤
│                    核心业务层 (Core Business)                     │
│  Unpacker · FileInfo · DecryptAndDecompress · PathMapping       │
│  PostProcessRestoredOutputs · ResolveOutputPathForWrite         │
├─────────────────────────────────────────────────────────────────┤
│                    基础设施层 (Infrastructure)                    │
│  LJFP_CRC32 · LJFP_SMS4 · LJFP_MiniZ · LJFP_FileUtil          │
│  LJFP_Compress · LJFP_StringUtil · LJFP_Var · LibsWrapper      │
│  FileTypeDetector · AndroidBinaryKey · Logger · ErrorCodes      │
│  UnpackIndexIO · UnpackSourceIO                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 架构特征

| 特征 | 描述 |
|------|------|
| 依赖注入 | `Unpacker` 构造函数注入 CRC32/Zip/UnZip/SMS4/DeSMS4 五个函数指针，解耦底层算法实现 |
| 策略模式 | `DecryptMode` 枚举驱动解密策略选择，`Auto` 模式自动探测候选链路 |
| 观察者模式 | `ProgressCallback` 回调函数实现进度通知 |
| 协作式取消 | `m_shouldStop`/`m_shouldPause` 原子变量 + `WaitIfPaused()` 实现暂停/停止 |
| 流式处理 | `UnpackSingleFileStream`/`UnpackSingleFileStreamCompressed` 分块处理大文件 |
| 两阶段路径恢复 | 先按 CRC32 落地，后处理阶段通过内容启发式恢复原始路径结构 |

---

## 2. 分层结构详解

### 2.1 GUI 表现层

| 组件 | 源文件 | 职责 |
|------|--------|------|
| `SLJFP_App` | `gui/SLJFP_App.cpp` | wxWidgets 应用入口，初始化主窗口 |
| `SLJFP_MainFrame` | `gui/SLJFP_MainFrame.{h,cpp}` | 主窗口框架，提供索引加载、路径映射、解包配置、进度显示等 UI 控件 |
| `SLJFP_ProgressDialog` | `gui/SLJFP_ProgressDialog.{h,cpp}` | 进度对话框，显示解包进度条与取消按钮 |
| `SLJFP_WorkflowSession` | `gui/SLJFP_WorkflowSession.h` | 工作流会话数据，在 GUI 层与 Workflow 层间传递状态 |

**关键交互**：`SLJFP_MainFrame` 持有 `Unpacker` 实例，通过调用 `Unpacker` 的公共 API 驱动解包流程，并注册 `ProgressCallback` 更新进度条。

### 2.2 工作流控制层

| 组件 | 源文件 | 职责 |
|------|--------|------|
| `SLJFP_WorkflowPresenter` | `src/SLJFP_WorkflowPresenter.{h,cpp}` | 工作流呈现器，协调解包各阶段（加载索引→配置→解包→后处理→审阅）的执行顺序 |
| `SLJFP_WorkflowReviewController` | `src/SLJFP_WorkflowReviewController.{h,cpp}` | 审阅控制器，管理解包结果的审阅流程，包括未恢复路径的归类 |
| `SLJFP_WorkflowReviewExportService` | `src/SLJFP_WorkflowReviewExportService.{h,cpp}` | 审阅导出服务，将审阅结果导出为 TSV/JSON 格式 |

**关键交互**：`WorkflowPresenter` 持有 `Unpacker` 引用，按阶段调用 `LoadIndex`→`LoadPathMapping`→`UnpackAll`→`PostProcessRestoredOutputs`→`ValidateRestoreOutcome`→`WriteOutputPathManifest`。

### 2.3 核心业务层

| 组件 | 源文件 | 职责 |
|------|--------|------|
| `Unpacker` | `include/SLJFP_Unpack.h` / `src/SLJFP_Unpack.cpp` | 核心解包类，协调索引加载、文件读取、解密解压、路径恢复、输出写入全流程 |
| `FileInfo` | `include/SLJFP_Unpack.h` | 文件元信息结构，记录包索引、偏移、大小、CRC32、压缩/加密类型 |
| `DecryptAndDecompress` | `src/SLJFP_Unpack.cpp` (Unpacker 私有方法) | 多候选解密探测引擎，按候选链路依次尝试解密+解压+CRC32校验 |
| `PathMapping` | `src/SLJFP_Unpack.cpp` (Unpacker 私有成员) | CRC32→路径映射表，支持文本和二进制(.ljpm)格式 |
| `PostProcessRestoredOutputs` | `src/SLJFP_Unpack.cpp` (Unpacker 私有方法) | 后处理路径恢复，通过内容启发式分析恢复原始目录结构 |
| `ResolveOutputPathForWrite` | `src/SLJFP_Unpack.cpp` (Unpacker 私有方法) | 输出路径冲突消解，确保并行写入时路径唯一性 |

**关键交互**：`Unpacker` 是系统的核心枢纽，向上为 Workflow 层和 GUI 层提供公共 API，向下通过注入的函数指针调用基础设施层的加密/压缩算法。

### 2.4 基础设施层

| 组件 | 源文件 | 职责 |
|------|--------|------|
| `LJFP_CRC32` | `libs/ljfp/LJFP_CRC32.h` | CRC32 校验和计算（查表法实现） |
| `LJFP_SMS4` | `libs/ljfp/LJFP_SMS4.h` | SMS4 国密对称加密/解密算法 |
| `LJFP_MiniZ` | `libs/ljfp/LJFP_MiniZ.h` | MiniZ 压缩/解压库（zlib 兼容） |
| `LJFP_Compress` | `libs/ljfp/LJFP_Compress.h` | 压缩/解压封装层 |
| `LJFP_FileUtil` | `libs/ljfp/LJFP_FileUtil.h` | 文件操作工具集 |
| `LJFP_StringUtil` | `libs/ljfp/LJFP_StringUtil.h` | 字符串工具集 |
| `LJFP_Var` | `libs/ljfp/LJFP_Var.h` | 变体类型工具 |
| `LibsWrapper` | `include/SLJFP_LibsWrapper.{h,cpp}` | 库函数包装器，提供 `SLJFP_DeSMS4BlocksLegacy`/`SLJFP_DeSMS4BlocksClientObf`/`SLJFP_DeSMS4BlocksClientKeyed` 三种解密策略 |
| `FileTypeDetector` | `include/SLJFP_FileTypeDetector.{h,cpp}` | 基于 Magic Number 的文件类型检测器 |
| `AndroidBinaryKey` | `include/SLJFP_AndroidBinaryKey.{h,cpp}` | Android APK 客户端二进制密钥提取 |
| `Logger` | `include/SLJFP_Logger.{h}` / `include/SLJFP_Logger_Impl.{h}` | 日志系统，支持多级别日志输出 |
| `ErrorCodes` | `include/SLJFP_ErrorCodes.h` | 统一错误码定义 |
| `UnpackIndexIO` | `src/SLJFP_UnpackIndexIO.{h,cpp}` | 索引文件 I/O 子模块，解析 .ljpi 和 .ljzip 格式 |
| `UnpackSourceIO` | `src/SLJFP_UnpackSourceIO.{h,cpp}` | 源文件 I/O 子模块，构建源文件路径并读取数据 |

---

## 3. 设计模式应用

### 3.1 依赖注入（Dependency Injection）

**应用位置**：`Unpacker` 构造函数

```cpp
// 源文件: include/SLJFP_Unpack.h, 行 570-576
Unpacker(
    CRC32_Func crc32Func,
    Zip_Func zipFunc,
    UnZip_Func unzipFunc,
    SMS4_Func sms4Func,
    DeSMS4_Func desms4Func);
```

**设计意图**：将底层加密/压缩算法的具体实现与核心业务逻辑解耦。`Unpacker` 不直接依赖 `LJFP_SMS4` 或 `LJFP_MiniZ`，而是通过函数指针调用，使得：
- 可以替换不同的加密实现（如测试时注入 Mock）
- 支持多种解密策略（Legacy/ClientObf/ClientKeyed）的动态切换

### 3.2 策略模式（Strategy Pattern）

**应用位置**：`DecryptMode` 枚举与 `DecryptBufferForMode` 方法

```cpp
// 源文件: include/SLJFP_Unpack.h, 行 40-44
enum class DecryptMode {
    Auto = 0,               ///< 自动模式
    LJFilePackSMS4 = 1,     ///< 原始 LJFilePack SMS4
    ApkClientObf = 2        ///< APK 客户端混淆变体
};
```

**设计意图**：`Auto` 模式下系统自动构建多个解密候选（`BuildDecryptProbeCandidates`），按优先级依次尝试，通过 CRC32 校验确定正确策略。

### 3.3 观察者模式（Observer Pattern）

**应用位置**：`ProgressCallback` 回调

```cpp
// 源文件: include/SLJFP_Unpack.h, 行 271-273
typedef std::function<void(float progress, uint32_t current, uint32_t total)> ProgressCallback;
```

**设计意图**：GUI 层注册回调函数，`Unpacker` 在处理过程中定期通知进度更新，实现 UI 与业务逻辑的解耦。

### 3.4 模板方法模式（Template Method Pattern）

**应用位置**：`UnpackAll` 方法定义了固定执行骨架

```cpp
// 源文件: src/SLJFP_Unpack.cpp, UnpackAll 方法
// 执行骨架：配置→创建目录→解包→后处理→校验→写清单
int Unpacker::UnpackAll(...) {
    ConfigureSession(inputDir, outputDir, options);
    CreateDirectoryRecursive(outputDir);
    // 单线程或多线程解包
    result = (threadCount == 1) ? UnpackAllSequential() : UnpackAllParallelOptimized(threadCount);
    // 后处理路径恢复
    if (m_options.restorePathStructureAfterUnpack) { PostProcessRestoredOutputs(); }
    // 校验恢复结果
    ValidateRestoreOutcome();
    // 写出路径清单
    if (m_options.writePathManifest) { WriteOutputPathManifest(); }
    return result;
}
```

---

## 4. 模块间交互接口与通信机制

### 4.1 核心交互接口

```
┌──────────────┐    ProgressCallback    ┌──────────────┐
│  GUI Layer   │◄───────────────────────│   Unpacker   │
│  MainFrame   │                        │   (Core)     │
│              │──LoadIndex()──────────►│              │
│              │──LoadPathMapping()────►│              │
│              │──UnpackAll()──────────►│              │
│              │──Stop()/Pause()───────►│              │
└──────────────┘                        └──────┬───────┘
                                               │
                              函数指针调用       │
                                               ▼
                                        ┌──────────────┐
                                        │  Infra Layer  │
                                        │  CRC32/SMS4/  │
                                        │  MiniZ/IO     │
                                        └──────────────┘
```

### 4.2 通信机制

| 机制 | 使用场景 | 线程安全 |
|------|----------|----------|
| 函数指针注入 | Unpacker 调用底层加密/压缩算法 | 否（只读，初始化后不变） |
| `std::function` 回调 | 进度通知 | 否（仅在主线程调用） |
| `std::atomic<bool>` | 停止/暂停信号传播 | 是 |
| `std::mutex` + `std::lock_guard` | 并行解包时统计信息更新 | 是 |
| `std::condition_variable` | 并行解包任务队列同步 | 是 |
| `std::atomic<uint32_t>` | 流式解包统计计数器 | 是 |

### 4.3 线程安全设计

并行解包模式下的线程安全策略：

| 共享资源 | 保护机制 | 代码位置 |
|----------|----------|----------|
| `m_processedFiles` / `m_failedFiles` / `m_processedBytes` | `statsMutex` | `UnpackAllParallel` |
| `m_lastFailedFiles` | `m_failedFilesMutex` | `RecordFailedFile` |
| `m_lastDecryptProbeRecords` | `m_decryptProbeMutex` | `SetLastDecryptProbeRecords` |
| `m_reservedOutputPaths` / `m_outputPathAuditRecords` | `m_outputPathMutex` | `ResolveOutputPathForWrite` |
| `m_streamConsidered` 等 | `std::atomic<uint32_t>` | `UnpackSingleFile` |
| 任务队列 `taskQueue` | `queueMutex` + `cv` | `UnpackAllParallel` |

---

## 5. 核心类继承体系

### 5.1 类关系图

```
FileInfo (值类型结构体)
  ├── m_PackIndex: uint32_t
  ├── m_Pos: uint32_t
  ├── m_Size: uint32_t
  ├── m_CRC32: uint32_t
  ├── m_CompressType: uint32_t
  ├── m_CodeType: uint32_t
  ├── m_SizeOriginal: uint32_t
  ├── m_CRC32Original: uint32_t
  └── m_PathFileNameCRC32: uint32_t

Unpacker (核心业务类，无继承)
  ├── 公共 API
  │   ├── LoadIndex()
  │   ├── UnpackAll() / UnpackSelected() / UnpackSingle()
  │   ├── LoadPathMapping() / LoadPathMappingBinary()
  │   ├── Stop() / Pause() / Resume()
  │   └── GetFileList() / GetFilePath() / FindFileByCRC32()
  ├── 私有子模块
  │   ├── IndexIO (detail::LoadLjpiIndexData / LoadLjzipIndexData)
  │   ├── SourceIO (detail::ReadSourceFileData / OpenSourceFileStream)
  │   ├── DecryptAndDecompress (多候选探测引擎)
  │   ├── ResolveOutputPathForWrite (路径冲突消解)
  │   └── PostProcessRestoredOutputs (内容启发式路径恢复)
  └── 内部审计结构
      ├── PathMappingAuditInfo
      └── OutputPathAuditRecord

SMS4 (加密算法类，无继承)
  ├── KeyExpansion()
  ├── Encrypt()
  └── Decrypt()

FileTypeDetector (静态工具类)
  └── DetectExtension()

AndroidBinaryKey (工具类)
  └── ExtractKeyFromApk()

LibsWrapper (静态函数集)
  ├── SLJFP_DeSMS4BlocksLegacy()
  ├── SLJFP_DeSMS4BlocksClientObf()
  └── SLJFP_DeSMS4BlocksClientKeyed()
```

### 5.2 GUI 层类继承

```
wxApp
  └── SLJFP_App

wxFrame
  └── SLJFP_MainFrame
        ├── 持有 Unpacker* 实例
        └── 持有 SLJFP_WorkflowPresenter* 实例

wxDialog
  └── SLJFP_ProgressDialog
```

---

## 6. 函数调用链与关键路径

### 6.1 主解包流程调用链

```
GUI: MainFrame::OnUnpackButtonClick()
  └── WorkflowPresenter::RunUnpack(session)
        ├── Unpacker::LoadIndex(indexPath)
        │     ├── detail::LoadLjpiIndexData() 或 detail::LoadLjzipIndexData()
        │     │     └── detail::ParseLjpiBuffer()
        │     └── UpdatePathMappingStats()
        ├── Unpacker::LoadPathMapping(mapPath)
        │     ├── LoadPathMappingBinary() 或文本解析
        │     └── UpdatePathMappingStats()
        └── Unpacker::UnpackAll(inputDir, outputDir, options)
              ├── ConfigureSession()
              ├── CreateDirectoryRecursive()
              ├── UnpackAllSequential() 或 UnpackAllParallelOptimized()
              │     └── [循环] UnpackSingleFile(fileInfo, index)
              │           ├── [流式路径] UnpackSingleFileStream() 或 UnpackSingleFileStreamCompressed()
              │           │     ├── detail::OpenSourceFileStream()
              │           │     ├── DecryptBufferForMode()
              │           │     ├── mz_inflate() (流式解压)
              │           │     └── ResolveOutputPathForWrite()
              │           └── [缓冲区路径] 完整读取→解密解压→写入
              │                 ├── ReadFileData() → detail::ReadSourceFileData()
              │                 ├── DecryptAndDecompress()
              │                 │     ├── BuildDecryptProbeCandidates()
              │                 │     ├── [循环候选] DecryptBufferForMode() + m_unzipFunc()
              │                 │     └── CRC32 校验选择正确候选
              │                 ├── ResolveOutputPathForWrite()
              │                 └── 写入输出文件
              ├── PostProcessRestoredOutputs()
              │     ├── scanOutputs() — 扫描输出目录
              │     ├── 路径映射候选匹配
              │     ├── 扩展名检测与重命名
              │     ├── 内容启发式分析（XML/Lua/Atlas/Spine/二进制表等）
              │     └── applyCandidates() — 移动/重命名文件
              ├── ValidateRestoreOutcome()
              └── WriteOutputPathManifest()
                    ├── TSV 格式输出
                    └── JSON 格式输出
```

### 6.2 解密探测关键路径

```
DecryptAndDecompress(inputData, inputSize, ...)
  ├── BuildDecryptProbeCandidates()
  │     ├── needDecrypt=false → ["passthrough"]
  │     ├── DecryptMode::LJFilePackSMS4 → ["legacy-window1024"]
  │     ├── DecryptMode::ApkClientObf → ["clientobf-window1024"]
  │     └── DecryptMode::Auto → [
  │           "passthrough" (如果输入看起来像 zlib),
  │           "legacy-window1024",
  │           "clientobf-window1024",
  │           "clientkeyed-window1024",
  │           "legacy-full" (如果文件>1024字节),
  │           "clientobf-full" (如果文件>1024字节),
  │           "clientkeyed-full" (如果文件>1024字节),
  │           "passthrough"
  │         ]
  └── [循环每个候选]
        ├── DecryptBufferForMode() — 按候选策略解密
        ├── m_unzipFunc() — 解压（如果需要）
        │     └── 失败时自动重试（输出缓冲区倍增，最多10次）
        ├── m_crc32Func() — CRC32 校验
        ├── CRC32 匹配 → 选中此候选，返回成功
        └── CRC32 不匹配 → 继续下一个候选
```

### 6.3 路径恢复后处理关键路径

```
PostProcessRestoredOutputs()
  └── [3轮迭代]
        ├── scanOutputs() — 收集输出文件，识别根目录数字文件名
        ├── 路径映射候选匹配 — applyCandidates()
        ├── 扩展名检测与重命名 — detectCustomExtension()
        ├── 内容启发式分析：
        │     ├── XML 文件 → ExtractUiLayoutNameHints / ExtractUiImagesetNameHints / ExtractUiFontNameHints
        │     ├── Lua 文件 → ExtractLuaModuleRefs / ExtractLuaTopLevelTableSymbols
        │     ├── Atlas 文件 → ParseAtlasPrimaryPageInfo / ExtractAtlasRegionNames
        │     ├── Spine JSON → ExtractSpineJsonAttachments / FindUniqueSpineStem
        │     ├── 二进制表 → ParseMapConfigResDirsFromBinary / ParseNpcShapeTableData / ParseNpcActionInfoTableData / ParseNpcRideTableData
        │     ├── Imageset 文件 → ExtractUiImagesetImagePathHintsFromText
        │     └── 通用引用提取 → ExtractQuotedStrings / ExtractLuaModuleRefs / ExtractAttrValues
        └── applyCandidates() — 移动文件到恢复路径
```

---

## 文档与代码映射关系

| 文档章节 | 对应源文件 | 关键代码行范围 |
|----------|-----------|---------------|
| 2.1 GUI 表现层 | `gui/SLJFP_MainFrame.h` | 全文件 |
| 2.2 工作流控制层 | `src/SLJFP_WorkflowPresenter.cpp` | 全文件 |
| 2.3 核心业务层 | `src/SLJFP_Unpack.cpp` | 行 2096-4100 |
| 2.4 基础设施层 | `libs/ljfp/LJFP_SMS4.h` | 全文件 |
| 3.1 依赖注入 | `include/SLJFP_Unpack.h` | 行 570-576 |
| 3.2 策略模式 | `src/SLJFP_Unpack.cpp` | 行 496-530 (`BuildDecryptProbeCandidates`) |
| 4.3 线程安全设计 | `src/SLJFP_Unpack.cpp` | 行 2375-2599 (`UnpackAllParallel`) |
| 6.1 主解包流程 | `src/SLJFP_Unpack.cpp` | 行 2127-2200 (`UnpackAll`) |
| 6.2 解密探测 | `src/SLJFP_Unpack.cpp` | 行 4100-4350 (`DecryptAndDecompress`) |
| 6.3 路径恢复 | `src/SLJFP_Unpack.cpp` | 行 4700-5500 (`PostProcessRestoredOutputs`) |

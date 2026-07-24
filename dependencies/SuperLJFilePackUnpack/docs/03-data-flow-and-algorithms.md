# SuperLJFilePackUnpack 数据流向图与关键算法详解

> 本文档基于源代码实际实现编写，确保与代码逻辑 100% 精准同步。
> 生成日期：2026-04-26

---

## 目录

- [1. 全链路数据流向图](#1-全链路数据流向图)
- [2. 索引加载数据流](#2-索引加载数据流)
- [3. 单文件解包数据流](#3-单文件解包数据流)
- [4. 解密探测算法详解](#4-解密探测算法详解)
- [5. 路径恢复算法详解](#5-路径恢复算法详解)
- [6. 输出路径冲突消解算法](#6-输出路径冲突消解算法)
- [7. 流式解包算法详解](#7-流式解包算法详解)

---

## 1. 全链路数据流向图

```
┌─────────────┐     ┌─────────────┐     ┌──────────────────┐
│  .ljpi 文件  │     │  .ljzip 文件 │     │  路径映射文件     │
│  (明文索引)  │     │  (加密索引)  │     │  (.txt / .ljpm)  │
└──────┬──────┘     └──────┬──────┘     └────────┬─────────┘
       │                   │                     │
       ▼                   ▼                     ▼
  ParseLjpiBuffer    SMS4解密→zlib解压      文本/二进制解析
       │              →CRC32校验→解析           │
       │                   │                     │
       └───────┬───────────┘                     │
               ▼                                 │
        ┌──────────────┐                         │
        │  m_fileList   │◄────────────────────────┘
        │  (FileInfo[]) │     m_pathMapping
        └──────┬───────┘     (CRC32→路径)
               │
               ▼
  ┌────────────────────────────────────────────┐
  │            UnpackAll / UnpackSelected       │
  │  ┌──────────────────────────────────────┐  │
  │  │  [循环每个文件]                        │  │
  │  │    │                                  │  │
  │  │    ▼                                  │  │
  │  │  读取源文件数据                         │  │
  │  │  (散文件: {CRC32} / 包文件: {N}.ljfp)  │  │
  │  │    │                                  │  │
  │  │    ▼                                  │  │
  │  │  DecryptAndDecompress                 │  │
  │  │  (多候选解密探测 + CRC32 校验)         │  │
  │  │    │                                  │  │
  │  │    ▼                                  │  │
  │  │  ResolveOutputPathForWrite            │  │
  │  │  (路径映射→文件类型检测→冲突消解)       │  │
  │  │    │                                  │  │
  │  │    ▼                                  │  │
  │  │  写入输出文件                           │  │
  │  └──────────────────────────────────────┘  │  └────────────────────────────────────────────┘
               │
               ▼
  ┌────────────────────────────────────────────┐
  │      PostProcessRestoredOutputs             │
  │  (3轮迭代: 映射匹配→扩展名检测→内容启发式)  │
  └────────────────────────────────────────────┘
               │
               ▼
  ┌────────────────────────────────────────────┐
  │      ValidateRestoreOutcome                 │
  │  + WriteOutputPathManifest                  │
  │  (TSV + JSON 格式路径清单)                   │
  └────────────────────────────────────────────┘
               │
               ▼
        ┌──────────────┐
        │   输出目录    │
        │  (解包结果)   │
        └──────────────┘
```

---

## 2. 索引加载数据流

### 2.1 .ljpi 明文索引

```
文件字节流
    │
    ▼
┌──────────────────────────────────┐
│  [4B] fileCount                  │
│  [循环 fileCount 次]              │
│    [4B] PackIndex                │
│    (PackIndex>0) [4B] Pos        │
│    [4B] Size                     │
│    [4B] CRC32                    │
│    [4B] CompressType             │
│    [4B] CodeType                 │
│    (CompressType>0||CodeType>0)  │
│      [4B] SizeOriginal           │
│      [4B] CRC32Original          │
│    [4B] PathFileNameCRC32        │
└──────────────────────────────────┘
    │
    ▼
FileInfo 结构体数组 (m_fileList)
```

**数据转换规则**:
- `CompressType == 0 && CodeType == 0` 时，`SizeOriginal = Size`，`CRC32Original = CRC32`
- `PackIndex == 0` 表示散文件（独立文件，不在 .ljfp 包内）
- `PackIndex > 0` 表示包内文件，`Pos` 为包内偏移

### 2.2 .ljzip 加密索引

```
文件字节流
    │
    ▼
┌──────────────────────────────────┐
│  [4B] magicKey (=9999) 校验      │
│  [4B] encryptedSize              │
│  [encryptedSize B] 加密数据 ─────┼──► DeSMS4Func(加密数据, key)
│  [4B] compressedSize             │         │
│  [4B] originalSize               │         ▼
│  [4B] originalCRC32              │    解密后数据
└──────────────────────────────────┘         │
                                             ▼
                                    UnZipFunc(解密数据, compressedSize)
                                             │
                                             ▼
                                    CRC32 校验 (originalCRC32)
                                             │
                                             ▼
                                    ParseLjpiBuffer(解压数据)
                                             │
                                             ▼
                                    FileInfo 结构体数组
```

---

## 3. 单文件解包数据流

```
┌──────────────────────────────────────────────────────────────┐
│                    UnpackSingleFile                           │
│                                                              │
│  ┌──────────┐                                                │
│  │ FileInfo │                                                │
│  └────┬─────┘                                                │
│       │                                                      │
│       ▼                                                      │
│  ┌─────────────────────────────────────┐                     │
│  │  useStreamMode?                      │                     │
│  │  ├─ Yes: 尝试流式路径                 │                     │
│  │  │  ├─ 加密且非16对齐 → 跳过流式       │                     │
│  │  │  ├─ 压缩 → StreamCompressed       │                     │
│  │  │  ├─ 未压缩 → Stream               │                     │
│  │  │  └─ 流式失败 → 回退缓冲区路径       │                     │
│  │  └─ No: 缓冲区路径                    │                     │
│  └──────────────┬──────────────────────┘                     │
│                 │                                            │
│                 ▼                                            │
│  ┌─────────────────────────────────────┐                     │
│  │  ReadFileData (缓冲区路径)            │                     │
│  │  ├─ PackIndex==0: 读取散文件          │                     │
│  │  └─ PackIndex>0:  读取包文件+偏移     │                     │
│  └──────────────┬──────────────────────┘                     │
│                 │ encryptedData                               │
│                 ▼                                            │
│  ┌─────────────────────────────────────┐                     │
│  │  DecryptAndDecompress                │                     │
│  │  (多候选探测，详见第4章)              │                     │
│  └──────────────┬──────────────────────┘                     │
│                 │ decryptedData                               │
│                 ▼                                            │
│  ┌─────────────────────────────────────┐                     │
│  │  CRC32 校验 (verifyCRC32)            │                     │
│  │  actualCRC32 vs FileInfo.CRC32Original│                    │
│  └──────────────┬──────────────────────┘                     │
│                 │                                            │
│                 ▼                                            │
│  ┌─────────────────────────────────────┐                     │
│  │  ResolveOutputPathForWrite           │                     │
│  │  (路径映射→类型检测→冲突消解)         │                     │
│  └──────────────┬──────────────────────┘                     │
│                 │ outputPath                                 │
│                 ▼                                            │
│  ┌─────────────────────────────────────┐                     │
│  │  CreateDirectoryRecursive            │                     │
│  │  + 写入文件                           │                     │
│  └─────────────────────────────────────┘                     │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. 解密探测算法详解

### 4.1 算法概述

`DecryptAndDecompress` 是系统的核心算法，采用**多候选探测**策略解决解密模式未知的问题。在 `DecryptMode::Auto` 下，系统构建多个解密候选链路，依次尝试，通过 CRC32 校验确定正确结果。

### 4.2 伪代码

```
FUNCTION DecryptAndDecompress(inputData, inputSize, needDecrypt, needDecompress,
                              originalSize, expectedCRC32, probeRecordsOut):

    candidates = BuildDecryptProbeCandidates(inputData, inputSize, needDecrypt,
                                             needDecompress, options)

    FOR EACH candidate IN candidates:
        // 步骤1: 解密（如果需要）
        IF candidate.applyDecrypt:
            transformedBuffer = DecryptBufferForMode(inputData, candidate.mode,
                                                      candidate.useFullWindow)
        ELSE:
            transformedBuffer = inputData

        // 步骤2: 解压（如果需要）
        IF needDecompress:
            outputBuffer, outputSize = UnzipFunc(transformedBuffer)
            // 失败时自动重试（输出缓冲区倍增，最多10次）
            WHILE unzipResult == Z_BUF_ERROR AND retryCount < 10:
                outputSize *= 2
                IF outputSize > MAX_DECOMPRESS_SIZE (100MB):
                    BREAK
                outputBuffer, outputSize = UnzipFunc(transformedBuffer)
            IF unzip failed:
                CONTINUE to next candidate
        ELSE:
            outputBuffer = transformedBuffer (直接复制)

        // 步骤3: CRC32 校验
        IF verifyCRC32 AND expectedCRC32 != 0:
            actualCRC32 = CRC32Func(0, outputBuffer)
            IF actualCRC32 != expectedCRC32:
                CONTINUE to next candidate  // Auto 模式下跳过

        // 步骤4: 选中此候选
        RETURN SUCCESS with outputBuffer

    // 所有候选均失败
    RETURN lastError
```

### 4.3 候选链路构建规则

```
FUNCTION BuildDecryptProbeCandidates(inputData, inputSize, needDecrypt, needDecompress, options):

    IF NOT needDecrypt:
        RETURN [("passthrough", no_decrypt)]

    inputLooksZlib = needDecompress AND LooksLikeZlibHeader(inputData)
    tryFullWindow = inputSize > 1024

    SWITCH options.decryptMode:
        CASE LJFilePackSMS4:
            RETURN [("legacy-window1024", SMS4, window=1024)]

        CASE ApkClientObf:
            RETURN [("clientobf-window1024", ClientObf, window=1024)]

        CASE Auto:
            candidates = []
            IF inputLooksZlib:
                APPEND ("passthrough", no_decrypt)  // 可能未加密
            APPEND ("legacy-window1024", SMS4, window=1024)
            APPEND ("clientobf-window1024", ClientObf, window=1024)
            APPEND ("clientkeyed-window1024", ClientKeyed, window=1024)
            IF tryFullWindow:
                APPEND ("legacy-full", SMS4, window=全文件)
                APPEND ("clientobf-full", ClientObf, window=全文件)
                APPEND ("clientkeyed-full", ClientKeyed, window=全文件)
            APPEND ("passthrough", no_decrypt)  // 最后尝试直通
            RETURN candidates
```

### 4.4 解密窗口机制

```
FUNCTION DecryptBufferForMode(inputData, outputData, dataSize, mode, fileOffset, decryptWindowBytes):

    // 复制原始数据到输出
    memcpy(outputData, inputData, dataSize)

    decryptWindow = (decryptWindowBytes == 0) ? 1024 : decryptWindowBytes

    // 如果文件偏移已超出解密窗口，不再解密
    IF decryptWindow != FULL_WINDOW AND fileOffset >= decryptWindow:
        RETURN  // 数据保持原样

    // 计算需要解密的字节数
    IF decryptWindow == FULL_WINDOW:
        bytesInsideWindow = dataSize
    ELSE:
        bytesInsideWindow = min(dataSize, decryptWindow - fileOffset)

    // SMS4 按 16 字节分组，截断到 16 的倍数
    decryptBytes = (bytesInsideWindow / 16) * 16
    IF decryptBytes == 0:
        RETURN

    // 按候选策略执行解密
    SWITCH candidateId:
        "clientkeyed*": SLJFP_DeSMS4BlocksClientKeyed(...)
        "clientobf*":   SLJFP_DeSMS4BlocksClientObf(...)
        "legacy*":      SLJFP_DeSMS4BlocksLegacy(...)
```

### 4.5 复杂度分析

| 指标 | 分析 |
|------|------|
| 时间复杂度 | O(C × N)，C=候选数量（Auto模式最多8个），N=文件大小 |
| 空间复杂度 | O(N)，每个候选需要一份完整缓冲区 |
| CRC32 校验 | O(N)，需遍历完整解密解压后数据 |
| 最坏情况 | 8个候选全部尝试，8次解密+8次解压+8次CRC32 |

---

## 5. 路径恢复算法详解

### 5.1 算法概述

`PostProcessRestoredOutputs` 是系统的第二大核心算法，通过**3轮迭代**的内容启发式分析，将 CRC32 数字文件名的解包结果恢复为原始路径结构。

### 5.2 伪代码

```
FUNCTION PostProcessRestoredOutputs():

    changed = false

    FOR pass = 0 TO 2:
        // 步骤1: 扫描输出目录
        files, unresolved = scanOutputs()
        // unresolved = 根目录下纯数字文件名的文件（CRC32 未恢复）

        IF unresolved.isEmpty():
            BREAK

        // 步骤2: 路径映射候选匹配
        IF NOT m_pathMapping.isEmpty():
            mappingCandidates = {}
            FOR EACH (crc32, path) IN m_pathMapping:
                IF CRC32(normalize(path)) IN unresolved:
                    mappingCandidates[crc32].add(normalize(path))
            changed |= applyCandidates(mappingCandidates, unresolved)

        // 步骤3: 扩展名检测与重命名
        FOR EACH file IN files:
            IF file.isRootNumeric AND file.ext.isEmpty():
                data = ReadFileBytes(file.absPath)
                detectedExt = detectCustomExtension(data)
                IF detectedExt NOT empty:
                    RenameFile(file.absPath, file.rootCRC + detectedExt)
                    changed = true
                    CONTINUE to next pass  // 重新扫描

        // 步骤4: 内容启发式分析
        candidates = {}
        directCandidates = {}

        FOR EACH file IN files:
            data = ReadFileBytes(file.absPath)
            tokens = ExtractContentTokens(data)

            // 4a: XML 文件 → UI 布局/图片集/字体路径推断
            IF file.isRootNumeric AND file.ext == ".xml":
                layoutHints = ExtractUiLayoutNameHints(tokens, text)
                imagesetHints = ExtractUiImagesetNameHints(text)
                fontHints = ExtractUiFontNameHints(text)
                // 对每个 hint 计算 CRC32，与 unresolved 匹配
                FOR EACH hint:
                    candidatePath = "ui/layouts/" + hint + ".layout"
                    IF CRC32(candidatePath) == file.rootCRC:
                        directCandidates[file.rootCRC].add(candidatePath)
                    ELSE:
                        candidates[CRC32(candidatePath)].add(candidatePath)

            // 4b: Lua 文件 → require/module 引用推断
            IF file.isRootNumeric AND file.ext == ".lua":
                moduleRefs = ExtractLuaModuleRefs(text)
                topSymbols = ExtractLuaTopLevelTableSymbols(text)
                // 用模块目录+顶层符号名推断脚本路径

            // 4c: Atlas 文件 → 页面图片路径推断
            // 4d: Spine JSON → 附件图片路径推断
            // 4e: 二进制表 → NPC/地图/特效路径推断
            // 4f: Imageset → 引用图片路径推断
            // 4g: 通用引用提取 → quoted strings, Lua module refs

        // 步骤5: 应用候选（仅唯一匹配的候选）
        changed |= applyCandidates(candidates, unresolved)
        changed |= applyCandidates(directCandidates, unresolved)

    RETURN changed
```

### 5.3 候选匹配规则

```
FUNCTION applyCandidates(candidates, unresolved, resolvedFromPathMapping):

    changed = false
    FOR EACH (crc32, pathSet) IN candidates:
        IF pathSet.size() != 1:
            CONTINUE  // 歧义候选，跳过

        targetRel = pathSet.first()
        sourceFile = unresolved[crc32]

        IF sourceFile.absPath == targetAbs:
            CONTINUE  // 已在正确位置

        IF FileExists(targetAbs):
            // 目标已存在：比较内容，相同则删除源文件
            IF ReadFileBytes(source) == ReadFileBytes(target):
                DeleteFile(source)
                changed = true
            CONTINUE

        // 移动文件到目标路径
        IF MoveFile(source, target):
            registerRecoveredExactPathMapping(crc32, targetRel)
            updateOutputAuditForResolvedPath(crc32, targetRel)
            changed = true

    RETURN changed
```

### 5.4 复杂度分析

| 指标 | 分析 |
|------|------|
| 时间复杂度 | O(3 × (F + C))，F=输出文件数，C=候选匹配数 |
| 空间复杂度 | O(F + C)，文件列表和候选集合 |
| I/O 开销 | 每轮需扫描输出目录 + 读取部分文件内容 |
| 启发式精度 | 仅应用唯一匹配候选，避免误恢复 |

---

## 6. 输出路径冲突消解算法

### 6.1 伪代码

```
FUNCTION ResolveOutputPathForWrite(fileInfo, requestedOutputPath, fileData, dataSize):

    desiredPath = requestedOutputPath OR BuildOutputPath(fileInfo, fileData, dataSize)

    // 路径映射优先
    IF NOT hasCustomOutputPath AND preferPathMapping AND NOT forceCrcOutputFirst:
        IF fileInfo.PathFileNameCRC32 IN m_pathMapping:
            desiredRelativePath = m_pathMapping[fileInfo.PathFileNameCRC32]

    // 冲突消解循环
    conflictIndex = 0
    LOOP:
        reservationKey = ToLower(NormalizeSlashes(candidate))

        // 检查预留表（并行写入冲突）
        IF reservationKey IN m_reservedOutputPaths
           AND m_reservedOutputPaths[reservationKey] != fileInfo.PathFileNameCRC32:
            conflictIndex++
            candidate = BuildConflictOutputPath(desiredPath, fileInfo.PathFileNameCRC32, conflictIndex)
            CONTINUE

        // 检查磁盘文件（已有文件冲突）
        IF FileExists(candidate) AND NOT overwriteExisting:
            conflictIndex++
            candidate = BuildConflictOutputPath(desiredPath, fileInfo.PathFileNameCRC32, conflictIndex)
            CONTINUE

        // 预留路径
        m_reservedOutputPaths[reservationKey] = fileInfo.PathFileNameCRC32
        BREAK

    RETURN candidate
```

### 6.2 冲突路径命名规则

```
BuildConflictOutputPath(outputPath, pathFileNameCRC32, conflictIndex):

    stem = RemoveExtension(FileName(outputPath))
    ext = Extension(outputPath)

    result = stem + ".conflict." + HEX(pathFileNameCRC32)
    IF conflictIndex > 1:
        result += "." + conflictIndex
    result += ext

    RETURN JoinPath(DirPath(outputPath), result)
```

**示例**:
- 原始路径: `ui/layouts/main.layout`
- 冲突路径1: `ui/layouts/main.conflict.0A1B2C3D.layout`
- 冲突路径2: `ui/layouts/main.conflict.0A1B2C3D.2.layout`

---

## 7. 流式解包算法详解

### 7.1 未压缩流式解包

```
FUNCTION UnpackSingleFileStream(fileInfo, index, customOutputPath, outError):

    chunkSize = options.streamChunkSize OR 4MB
    IF needDecrypt:
        chunkSize = (chunkSize / 16) * 16  // 对齐到16字节

    OpenSourceFileStream(fileInfo) → fs

    remaining = fileInfo.Size
    fileOffset = 0
    crc32 = 0

    WHILE remaining > 0:
        readSize = min(remaining, chunkSize)
        fs.read(inBuf, readSize)

        IF needDecrypt:
            DecryptBufferForMode(inBuf, outBuf, readSize, mode, fileOffset)
            dataPtr = outBuf
        ELSE:
            dataPtr = inBuf

        // 首次写入时确定输出路径（可能需要文件数据做类型检测）
        IF NOT outputReady:
            ResolveOutputPathForWrite(fileInfo, "", dataPtr, dataSize) → outputPath
            OpenOutputFile(outputPath)

        outFile.write(dataPtr, dataSize)

        IF verifyCRC32:
            crc32 = CRC32Func(crc32, dataPtr, dataSize)

        remaining -= readSize
        fileOffset += readSize

    // CRC32 校验
    IF verifyCRC32 AND crc32 != fileInfo.CRC32Original:
        outError = LJFP_ERROR_CRC32_MISMATCH
        RETURN true  // 已处理（但失败）

    RETURN true  // 已处理
```

### 7.2 压缩流式解包

```
FUNCTION UnpackSingleFileStreamCompressed(fileInfo, index, customOutputPath, outError):

    chunkSize = options.streamChunkSize OR 4MB
    outChunkSize = clamp(chunkSize, 64KB, 8MB)

    OpenSourceFileStream(fileInfo) → fs
    mz_inflateInit(stream)

    remaining = fileInfo.Size
    fileOffset = 0
    totalOut = 0
    crc32 = 0

    WHILE remaining > 0:
        readSize = min(remaining, chunkSize)
        fs.read(inBuf, readSize)

        IF needDecrypt:
            DecryptBufferForMode(inBuf, decryptBuf, readSize, mode, fileOffset)
            dataPtr = decryptBuf
        ELSE:
            dataPtr = inBuf

        stream.next_in = dataPtr
        stream.avail_in = readSize

        WHILE stream.avail_in > 0:
            stream.next_out = outBuf
            stream.avail_out = outChunkSize

            status = mz_inflate(stream, MZ_NO_FLUSH)
            produced = outChunkSize - stream.avail_out

            IF produced > 0:
                // 首次写入时确定输出路径
                IF NOT outputReady:
                    ResolveOutputPathForWrite(...) → outputPath
                    OpenOutputFile(outputPath)

                outFile.write(outBuf, produced)
                crc32 = CRC32Func(crc32, outBuf, produced)
                totalOut += produced

                // 大小溢出保护
                IF totalOut > fileInfo.SizeOriginal:
                    cleanupAndFallback()
                    RETURN false  // 需要回退到非流式

            IF status == MZ_STREAM_END:
                streamDone = true
                BREAK
            IF status != MZ_OK AND status != MZ_BUF_ERROR:
                cleanupAndFallback()
                RETURN false

        remaining -= readSize
        fileOffset += readSize

    // 刷新剩余数据
    IF NOT streamDone:
        mz_inflate(stream, MZ_FINISH) ...

    mz_inflateEnd(stream)

    // 大小和 CRC32 校验
    IF totalOut != fileInfo.SizeOriginal:
        cleanupAndFallback()
        RETURN false

    RETURN true
```

### 7.3 流式回退条件

| 条件 | 回退原因 |
|------|----------|
| `useStreamMode == false` | 未启用流式模式 |
| `CodeType > 0 && Size % 16 != 0` | 加密数据非 16 字节对齐 |
| `DecryptMode::Auto` + 需要解密 | 自动模式需要多候选探测 |
| `mz_inflateInit` 失败 | zlib 初始化失败 |
| 解压输出超过 `SizeOriginal` | 数据损坏或解密错误 |
| `mz_inflate` 返回非 OK/BUF_ERROR | 解压流错误 |
| 解压产出大小不匹配 | 解压不完整 |

---

## 文档与代码映射关系

| 文档章节 | 对应源文件 | 关键代码行范围 |
|----------|-----------|---------------|
| 2.1 .ljpi 索引 | `src/SLJFP_UnpackIndexIO.cpp` | 行 16-55 |
| 2.2 .ljzip 索引 | `src/SLJFP_UnpackIndexIO.cpp` | 行 76-170 |
| 3. 单文件解包 | `src/SLJFP_Unpack.cpp` | 行 3360-3490 |
| 4. 解密探测 | `src/SLJFP_Unpack.cpp` | 行 4100-4350 |
| 5. 路径恢复 | `src/SLJFP_Unpack.cpp` | 行 4700-5500 |
| 6. 冲突消解 | `src/SLJFP_Unpack.cpp` | 行 4350-4450 |
| 7.1 未压缩流式 | `src/SLJFP_Unpack.cpp` | 行 3490-3680 |
| 7.2 压缩流式 | `src/SLJFP_Unpack.cpp` | 行 3680-4100 |

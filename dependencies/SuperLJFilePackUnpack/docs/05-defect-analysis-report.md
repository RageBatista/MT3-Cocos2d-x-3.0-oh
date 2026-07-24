# SuperLJFilePackUnpack 缺陷分析报告（复核与修复版）

> **版本**: 1.2  
> **初始审计日期**: 2026-04-26  
> **复核日期**: 2026-04-26  
> **修复验证日期**: 2026-04-26  
> **审计范围**: `dependencies/SuperLJFilePackUnpack/` 全部源代码、测试代码与构建脚本  
> **审计方法**: 静态代码审计 + 针对原报告逐项源码核验 + 回归测试补充 + 修复后构建/测试验证  
> **验证基线**: `dependencies/SuperLJFilePackUnpack/build/bin/Release/ljfp-test.exe`，279/279 通过

---

## 1. 复核结论

原 1.0 报告覆盖面较全，但存在严重度夸大、误报和与当前源码不一致的问题。经逐项核验与本轮修复：

- 原报告列出的主要编号中，**确认 23 项代码/设计缺陷**与 4 项 Info/技术债建议，其中多项需要调整严重度或修正缺陷描述。
- **不成立 5 项**：`DEF-H001`、`DEF-H004`、`DEF-M005`、`DEF-L006`、`DEF-I003`。
- **并入重复项 4 项**：`DEF-I001` 并入 `DEF-L004`，`DEF-I004` 并入 `DEF-L001`，`TD-001` 并入 `DEF-L001`，`TD-002` 并入 `DEF-L002`。
- `TD-004` “缺乏单元测试”与源码不符：修复后当前存在 279 个测试用例并全部通过；本轮已补充恶意输入、边界解析、UTF-8 JSON、流式失败清理等回归测试。
- 本轮已完成 `DEF-C002`、`DEF-H003`、`DEF-H005`、`DEF-H006`、`DEF-M001`、`DEF-M002`、`DEF-M006`、`DEF-M007`、`DEF-M008`、`DEF-L007`、`DEF-C003` 的直接代码修复；`DEF-H002`、`DEF-L005` 已做局部加固。
- 仍建议后续单独治理 `DEF-M003`、`DEF-M009` 以及低优先级维护性问题，避免在安全修复分支中扩大重构面。

复核后的优先级应聚焦在：索引解析未定义行为、路径/目录命令注入、错误路径残留不完整输出、无界或截断型输入处理、二进制映射解析错位、JSON UTF-8 语义损坏、ELF64 不支持。

---

## 2. 复核后缺陷统计

| 严重程度 | 数量 | 编号 |
| --- | ---: | --- |
| Critical | 0 | 无 |
| High | 5 | `DEF-C002`、`DEF-H003`、`DEF-H005`、`DEF-H006`、`DEF-M001` |
| Medium | 8 | `DEF-H002`、`DEF-M002`、`DEF-M003`、`DEF-M006`、`DEF-M007`、`DEF-M008`、`DEF-M009`、`DEF-L007` |
| Low | 10 | `DEF-C001`、`DEF-C003`、`DEF-M004`、`DEF-M010`、`DEF-L001`、`DEF-L002`、`DEF-L003`、`DEF-L004`、`DEF-L005`、`DEF-L008` |
| Info | 4 | `DEF-I002`、`DEF-I005`、`TD-003`、`TD-005` |
| 不成立/误报 | 5 | `DEF-H001`、`DEF-H004`、`DEF-M005`、`DEF-L006`、`DEF-I003` |

### 2.1 本轮修复状态统计

| 修复状态 | 数量 | 编号 |
| --- | ---: | --- |
| 已直接修复并有回归/静态验证 | 11 | `DEF-C002`、`DEF-H003`、`DEF-H005`、`DEF-H006`、`DEF-M001`、`DEF-M002`、`DEF-M006`、`DEF-M007`、`DEF-M008`、`DEF-L007`、`DEF-C003` |
| 已局部加固，仍建议后续完善 | 2 | `DEF-H002`、`DEF-L005` |
| 维持待治理 | 10 | `DEF-C001`、`DEF-M003`、`DEF-M004`、`DEF-M009`、`DEF-M010`、`DEF-L001`、`DEF-L002`、`DEF-L003`、`DEF-L004`、`DEF-L008` |
| Info/技术债建议 | 4 | `DEF-I002`、`DEF-I005`、`TD-003`、`TD-005` |

---

## 3. High 级确认缺陷

### DEF-C002: 索引解析使用 `reinterpret_cast` 直接读取整数，存在未定义行为

- **复核结论**: 确认，严重度从 Critical 调整为 High。
- **修复状态**: 已修复。
- **证据**: `src/SLJFP_UnpackIndexIO.cpp` 的 `ParseEntry` 与 `ParseLjpiBuffer` 多处使用 `*reinterpret_cast<const uint32_t*>(ptr)` 读取 `std::vector<unsigned char>` 中的字段。
- **真实风险**:
  - 在 ARM 等要求对齐访问的平台上，非 4 字节对齐地址可能触发总线错误。
  - 违反 C++ 严格别名和对象生命周期假设，优化级别变化后存在未定义行为风险。
  - 代码也隐含小端序读取，移植到大端平台会解析错误。
- **已执行修复**: `ParseEntry` 与 `ParseLjpiBuffer` 已改用 `ReadUInt32Le()` 逐字节读取并推进游标；新增 `LjpiIndexParsesFromUnalignedBuffer` 回归测试覆盖非对齐缓冲区。
- **修复方案**:
  1. 在 `SLJFP_UnpackIndexIO.cpp` 增加小端读取工具：

     ```cpp
     bool ReadUInt32Le(const unsigned char*& ptr, const unsigned char* end, uint32_t& out) {
         if (ptr == nullptr || ptr + 4 > end) {
             return false;
         }
         out = static_cast<uint32_t>(ptr[0]) |
               (static_cast<uint32_t>(ptr[1]) << 8) |
               (static_cast<uint32_t>(ptr[2]) << 16) |
               (static_cast<uint32_t>(ptr[3]) << 24);
         ptr += 4;
         return true;
     }
     ```

  2. 将 `ParseEntry`、`ParseLjpiBuffer` 中所有 `reinterpret_cast<const uint32_t*>` 替换为该函数。
  3. 新增回归测试：构造前置 1 字节偏移后的 LJPI 缓冲区，调用解析入口确认不崩溃且按预期返回成功或格式错误。
  4. 使用 `/O2`、x86、x64 与 Android/ARM 工具链各跑一次解析测试。

### DEF-H003: 流式解包失败时可能残留不完整输出文件

- **复核结论**: 确认，High。
- **修复状态**: 已修复。
- **证据**: `src/SLJFP_Unpack.cpp` 的 `UnpackSingleFileStream` 在读失败、写失败、用户取消、CRC 失败等路径中只关闭 `outFile`，未统一删除已创建的 `outputPath`。`UnpackSingleFileStreamCompressed` 虽有 `cleanupOutputForFallback`，但用户取消、读失败、写失败等部分路径仍直接返回。
- **影响**: 调用者可能把半写入文件当作有效解包结果；后处理路径恢复、清单生成或人工验收会被污染。
- **已执行修复**:
  1. 在 `UnpackSingleFileStream` 与 `UnpackSingleFileStreamCompressed` 中统一引入 `cleanupPartialOutput()`。
  2. CRC mismatch、读失败、写失败、用户取消、解压失败回退等非成功路径均关闭输出流并删除未提交文件。
  3. Windows 删除路径改走 `DeleteFilePath()`，避免 UTF-8 中文路径下 `std::remove()` 删除失败。
  4. 新增 `StreamModeDeletesPartialOutputOnCrcMismatch` 与 `StreamCompressedDeletesPartialOutputOnCrcMismatch` 回归测试。
- **修复方案**:
  1. 在两个流式函数中引入统一清理 lambda，例如：

     ```cpp
     bool outputCommitted = false;
     auto cleanupPartialOutput = [&]() {
         if (outFile.is_open()) {
             outFile.close();
         }
         if (!outputCommitted && outputReady && !outputPath.empty()) {
             std::remove(outputPath.c_str());
         }
     };
     ```

  2. 所有非成功返回路径调用 `cleanupPartialOutput()`；仅在 CRC 校验通过且所有写入完成后设置 `outputCommitted = true`。
  3. 对回退到非流式路径的场景继续删除临时流式输出，避免后续非流式写入被旧文件干扰。
  4. 新增测试：模拟源文件短读、CRC mismatch、写失败或用户取消，断言输出路径不存在。

### DEF-H005: POSIX 平台 `CreateDirectoryRecursive` 使用 `system()`，存在命令注入风险

- **复核结论**: 确认，High。
- **修复状态**: 已修复；当前 Windows 构建无法执行 POSIX 分支，已完成源码静态验证。
- **证据**: `src/SLJFP_Unpack.cpp` 的非 Windows 分支拼接 `mkdir -p "` + `dirPath` + `"` 后调用 `system(cmd.c_str())`。
- **真实风险**: `dirPath` 可能来自路径映射或输出选项。包含引号、反引号、`$()`、分号等 shell 元字符时可逃逸命令上下文。
- **已执行修复**:
  1. 删除 `SLJFP_Unpack.cpp` 中 POSIX 分支的 `system()` 调用。
  2. 新增 `CreatePosixDirectoryIfMissing()`，使用 `mkdir()` + `stat()` 逐级创建目录。
  3. `EEXIST` 仅在目标确认为目录时视为成功；其他错误记录 warning 后停止。
  4. 静态验证：`rg -n "system\\(" dependencies/SuperLJFilePackUnpack/src/SLJFP_Unpack.cpp` 无匹配。
- **修复方案**:
  1. 删除 POSIX 分支中的 `system()`。
  2. 使用 `mkdir()` 逐级创建目录，并对 `EEXIST` 继续处理：

     ```cpp
     #include <cerrno>
     #include <sys/stat.h>
     #include <sys/types.h>
     ```

  3. 将 `/` 规范化后逐段创建；遇到空段、`.`、根目录时跳过；失败时记录 `errno`。
  4. 新增测试：路径包含空格、引号、分号、美元符号时仅创建字面目录，不执行额外命令。

### DEF-H006: `ReadSourceFileData` 将散文件大小截断为 `uint32_t`

- **复核结论**: 确认，High。
- **修复状态**: 已修复。
- **证据**: `src/SLJFP_UnpackSourceIO.cpp` 在 `m_PackIndex == 0` 时对 `stream.tellg()` 结果执行 `static_cast<uint32_t>(fileSize)`。
- **影响**: 大于 4GB 的散文件会静默截断；后续读取、CRC 与清单统计都可能错误。
- **已执行修复**: 在转换前拒绝超过 `MAX_DECOMPRESS_SIZE` 的散文件，并新增 `ReadSourceFileDataRejectsLooseFileLargerThanLimit` 回归测试。当前 `MAX_DECOMPRESS_SIZE` 小于 `UINT32_MAX`，因此已覆盖本代码路径的截断风险；若未来允许更大文件，需整体升级 `FileInfo` 大小字段为 `uint64_t`。
- **修复方案**:
  1. 在转换前校验：

     ```cpp
     if (fileSize > static_cast<std::streamoff>(UINT32_MAX) ||
         fileSize > static_cast<std::streamoff>(MAX_DECOMPRESS_SIZE)) {
         return LJFP_ERROR_DECOMPRESS_TOO_LARGE;
     }
     ```

  2. 若业务允许大文件，需将 `FileInfo::m_Size`、读取长度、CRC 和统计链路一起升级为 `uint64_t`，不能只局部改读取函数。
  3. 新增测试：用稀疏文件或 mock stream 模拟 `UINT32_MAX + 1`，断言返回错误而不是截断。

### DEF-M001: `ParseLjpiBuffer` 的 `fileCount` 未校验即 `reserve`

- **复核结论**: 确认，严重度从 Medium 调整为 High。
- **修复状态**: 已修复。
- **证据**: `src/SLJFP_UnpackIndexIO.cpp` 读取 `fileCount` 后立即 `outResult.fileList.reserve(fileCount)`，再进入解析循环。
- **真实风险**: 恶意 LJPI 可把 `fileCount` 设置为极大值，触发超大内存分配或 `std::bad_alloc`，造成拒绝服务。
- **已执行修复**: 在 `reserve` 前增加 `kMaxLjpiEntryCount` 与理论最小条目大小校验；新增 `LjpiIndexRejectsImpossibleFileCountWithoutAllocating` 回归测试。
- **修复方案**:
  1. 在 `reserve` 前计算理论最小条目大小，拒绝不可能的数量：

     ```cpp
     const uint32_t payloadSize = size - 4;
     const uint32_t minEntrySize = 4 + 16 + 4;
     if (fileCount > payloadSize / minEntrySize) {
         return LJFP_ERROR_INDEX_CORRUPTED;
     }
     ```

  2. 再加业务硬上限，例如 `kMaxIndexEntries = 1000000`，超过返回 `LJFP_ERROR_INDEX_CORRUPTED`。
  3. 新增测试：`fileCount = 0xFFFFFFFF` 且缓冲区只有头部时必须快速返回错误，不发生大分配。

---

## 4. Medium 级确认缺陷

### DEF-H002: 停止信号语义不完整，取消响应不及时

- **复核结论**: 部分确认，严重度从 High 调整为 Medium；原报告“虚假唤醒遗漏”表述不准确。
- **修复状态**: 已局部加固。
- **证据**: `UnpackAllParallel` 的 worker 在 `stopFlag == true` 且队列非空时仍会继续取任务；已取走的 `UnpackSingleFile` 也不能被外部立刻中断。`UnpackAllParallelOptimized` 在每个文件前检查停止状态，响应性更好。
- **已执行修复**: `UnpackAllParallel`、`UnpackAllParallelOptimized`、`UnpackSelectedParallelOptimized` 的 worker 均在领取任务后、处理前检查 `stopFlag || m_shouldStop`，避免取消后继续处理新文件。后续如需更强实时性，应继续在非流式解密/解压长循环中增加停止检查点。
- **修复方案**:
  1. 明确停止语义：若用户取消应尽快停止，不再领取新任务。
  2. 在 worker 取任务后、处理前增加：

     ```cpp
     if (stopFlag.load() || m_shouldStop.load()) {
         break;
     }
     ```

  3. 在 `UnpackSingleFile`、流式读取循环、解密解压重试循环中增加停止检查点。
  4. 新增并行取消测试：构造多文件任务，触发 `Stop()` 后断言处理数小于总数且返回取消错误。

### DEF-M002: JSON 转义破坏 UTF-8 字符语义

- **复核结论**: 确认，Medium；原报告“生成的 JSON 不合法”不准确。
- **修复状态**: 已修复。
- **证据**: `src/SLJFP_Unpack.cpp` 与 `src/SLJFP_WorkflowReviewExportService.cpp` 的 `EscapeJsonString` 对每个 `>= 0x80` 字节输出 `\u00XX`。
- **真实风险**: JSON 语法仍可能合法，但 UTF-8 中文路径会被拆成多个 Latin-1 码位，解析后内容不再等于原路径。
- **已执行修复**: 两处 `EscapeJsonString` 均只转义引号、反斜杠和控制字符，保留合法 UTF-8 字节；新增 `OutputPathManifestJsonPreservesUtf8Paths` 与 `WorkflowReviewExportService.JsonPreservesUtf8FailedItemPaths` 回归测试。
- **修复方案**:
  1. 推荐保留合法 UTF-8 字节，只转义 `"`、`\` 与控制字符；JSON 标准允许 UTF-8 文本。
  2. 若必须全 Unicode 转义，先严格解码 UTF-8 到码点，再输出 `\uXXXX` 或代理对。
  3. 抽出一个公共 `JsonEscapeUtf8`，替换两个重复实现。
  4. 新增测试：输入 `res/中文/贴图.png`，生成 JSON 后用解析器读取，断言字符串与原值一致。

### DEF-M003: 后处理路径恢复阶段重复全量扫描和重复读取内容

- **复核结论**: 确认，Medium。
- **证据**: `PostProcessRestoredOutputs` 多轮调用 `scanOutputs`，在多个启发式分支反复 `ReadFileBytes` 读取相同文件内容。
- **影响**: 大资源包下 I/O 放大明显，后处理耗时可能超过解包本身。
- **修复方案**:
  1. 建立 `absPath -> FileSnapshot` 缓存，至少缓存文件大小、mtime、扩展名、是否 root numeric、可选内容摘要。
  2. 对需要内容启发式的文件，缓存 `ReadFileBytes` 结果；移动文件后按新路径迁移或失效缓存。
  3. 将“扫描输出目录”和“读取文件内容”拆成两个阶段，避免每个启发式重新走磁盘。
  4. 新增性能基准：构造 1 万个小文件，记录后处理读取次数和总耗时。

### DEF-M006: 严格恢复校验会误判合法根目录数字文件

- **复核结论**: 确认，Medium。
- **修复状态**: 已修复。
- **证据**: `ValidateRestoreOutcome` 对输出根目录中所有 `ParseNumericBaseName` 命中的文件计为残留，不区分它是否来自合法映射路径。
- **影响**: 若映射表中合法路径就是 `12345.png`，严格模式仍会失败。
- **已执行修复**: 严格校验阶段会参考输出 audit/manifest 记录，映射命中且最终路径合法的根目录数字文件不再计为残留；新增 `StrictRestoreValidationAllowsMappedRootNumericFile` 回归测试。
- **修复方案**:
  1. 在 `OutputPathAuditRecord` 中保留输出文件的 `pathCRC32` 与路径来源。
  2. 校验根目录数字文件时，先查 manifest/audit：若该文件是映射命中且最终路径等于映射规范化路径，不计为残留。
  3. 对无法关联到 audit 的历史文件才按残留处理。
  4. 新增测试：映射 `crc -> 12345.png`，严格模式应通过；未映射 CRC 落根目录数字名仍应失败。

### DEF-M007: `LoadPathMappingBinary` 对非法 `pathLen` 处理不完整，可能导致流错位

- **复核结论**: 确认，Medium；原报告只提到 `pathLen == 0` 静默跳过，实际还包括 `pathLen >= 4096` 时未消费路径字节导致后续记录错位。
- **修复状态**: 已修复。
- **证据**: `src/SLJFP_Unpack.cpp` 中仅在 `pathLen > 0 && pathLen < 4096` 时读取路径内容；否则直接进入下一轮。
- **已执行修复**: magic/version/count/CRC/pathLen 读取均检查失败状态；`pathLen == 0` 记录 warning 后继续；`pathLen >= 4096` 与截断路径直接返回 `LJFP_ERROR_INDEX_INVALID_FORMAT`；新增 `LoadPathMappingBinaryRejectsOversizedPathLength` 回归测试。
- **修复方案**:
  1. `pathLen == 0`：记录 warning 并继续。
  2. `pathLen >= 4096`：返回 `LJFP_ERROR_INDEX_INVALID_FORMAT`，不要继续错位解析。
  3. 若选择跳过超长条目，必须 `seekg(pathLen, std::ios::cur)` 并校验成功。
  4. 读取 magic、version、count、crc32、pathLen 后都检查 `fs.fail()`。
  5. 新增测试：空路径、4096 长路径、截断路径三种二进制映射文件均有确定返回值和日志。

### DEF-M008: `TryParseAtlasSizePair` 未检查 `strtoul` 溢出

- **复核结论**: 确认，Medium。
- **修复状态**: 已修复。
- **证据**: `src/SLJFP_Unpack.cpp` 中 `strtoul` 后直接 `static_cast<uint32_t>`，未检查 `errno == ERANGE`，也未校验超过 `UINT32_MAX`。
- **已执行修复**: `strtoul` 前清零 `errno`，解析后检查 `ERANGE` 与 `UINT32_MAX` 上界，拒绝溢出宽高。
- **修复方案**:
  1. 调用前清零 `errno`，调用后检查 `ERANGE`。
  2. 拒绝 `parsedWidth > UINT32_MAX` 或 `parsedHeight > UINT32_MAX`。
  3. 拒绝宽高为 0 或超过纹理业务上限的值，例如 `32768`。
  4. 新增测试：`999999999999,1`、`1,999999999999`、`0,1`、`4096,4096`。

### DEF-M009: Android 密钥提取仅支持 ELF32

- **复核结论**: 确认，Medium。
- **证据**: `SLJFP_AndroidBinaryKey.cpp` 只定义 `Elf32Header`、`Elf32ProgramHeader`、`Elf32SectionHeader`、`Elf32Symbol`，且 `ParseElf32Image` 明确要求 `e_ident[4] == 1`；候选路径却包含 `lib/arm64-v8a/libgame.so` 和 `lib/x86_64/libgame.so`。
- **修复方案**:
  1. 增加 `Elf64Header`、`Elf64ProgramHeader`、`Elf64SectionHeader`、`Elf64Symbol`。
  2. 读取 ELF `EI_CLASS` 后分派 ELF32/ELF64。
  3. 抽象符号表遍历与虚拟地址到文件偏移映射，避免复制业务搜索逻辑。
  4. 新增最小 ELF64 fixture，覆盖 arm64/x86_64 候选路径。

### DEF-L007: 解压重试存在整数翻倍溢出风险

- **复核结论**: 部分确认，严重度从 Low 调整为 Medium；原报告“无总大小限制”不成立，因为已有 `MAX_DECOMPRESS_SIZE` 检查，但乘 2 发生在检查之前。
- **修复状态**: 已修复。
- **证据**: `DecryptAndDecompress` 中 `candidateOutputSize *= 2` 后才判断 `candidateOutputSize > MAX_DECOMPRESS_SIZE`。
- **已执行修复**: 初始解压输出大小与翻倍前均检查 `MAX_DECOMPRESS_SIZE`/溢出条件；新增 `DecompressRetryRejectsHugeReportedBufferBeforeOverflow` 回归测试。
- **修复方案**:
  1. 翻倍前检查：

     ```cpp
     if (candidateOutputSize > MAX_DECOMPRESS_SIZE / 2) {
         candidateError = LJFP_ERROR_DECOMPRESS_TOO_LARGE;
         break;
     }
     candidateOutputSize *= 2;
     ```

  2. 将 `candidateOutputSize` 临时变量升级为 `uint64_t`，分配前再校验并转换。
  3. 新增测试：构造 inflater 持续返回 `Z_BUF_ERROR`，确认不会整数回绕。

---

## 5. Low 级确认缺陷

### DEF-C001: SMS4 包装函数和底层函数按值传递 `std::string` 密钥

- **复核结论**: 部分确认，严重度从 Critical 调整为 Low。
- **证据**: `SLJFP_LibsWrapper.cpp` 和 `libs/ljfp/LJFP_SMS4.h` 的 SMS4/SMS4 解密函数均按值接收 `std::string strPassword`。
- **纠偏**: 按值传递会造成拷贝开销，但不会导致字符串“截断”；异常或内存不足导致空密钥的说法缺乏源码证据。
- **修复方案**:
  1. 第一阶段只改项目自有 wrapper 为 `const std::string&`，同步更新 `include/SLJFP_LibsWrapper.h`。
  2. 第二阶段评估修改 `LJFP_SMS4.h` 中 inline 函数签名；因函数在头文件内联，需全量重编所有调用方。
  3. 增加性能测试：批量解密 10 万个小块，对比修改前后耗时和分配次数。

### DEF-C003: `DecryptBufferForMode` 使用 `const_cast`，接口 const 语义不清

- **复核结论**: 部分确认，严重度从 Critical 调整为 Low。
- **修复状态**: 已修复。
- **证据**: `DecryptBufferForMode` 先 `memcpy(outputData, inputData, dataSize)`，随后把 `inputData` `const_cast` 后传给 SMS4 block 函数。
- **纠偏**: 当前函数已先复制输入，且 SMS4 实现未见修改输入缓冲区的证据；真实问题是第三方接口缺少 `const unsigned char*` 约束，未来维护时存在误用风险。
- **已执行修复**: 调用 SMS4 block 解密时改为以 `outputData` 作为输入/输出缓冲，消除对外部 `inputData` 的 `const_cast`。
- **修复方案**:
  1. 优先把调用改为 `SLJFP_DeSMS4Blocks*(outputData, outputData, decryptBytes, key)`，明确只操作输出副本。
  2. 若底层函数支持输入输出分离但输入只读，应把 wrapper 入参改为 `const unsigned char*`，并在底层实现中消除写输入的可能。
  3. 新增测试：调用前后比较原始输入缓冲区完全不变。

### DEF-M004: `FindFileByCRC32` 线性搜索

- **复核结论**: 确认，Low。
- **证据**: `Unpacker::FindFileByCRC32` 遍历 `m_fileList`。
- **修复方案**:
  1. 在索引加载成功后构建 `std::unordered_map<uint32_t, size_t> m_fileIndexByPathCRC32`。
  2. 若存在 CRC 冲突，改为 `std::unordered_map<uint32_t, std::vector<size_t>>` 并明确返回第一个或提供多结果接口。
  3. 在 `Clear()`、重新 `LoadIndex()` 时重建或清空索引。

### DEF-M010: `ReadTableHeader` 使用十进制 FourCC 魔数

- **复核结论**: 确认，严重度从 Medium 调整为 Low。
- **证据**: `src/SLJFP_Unpack.cpp` 中 `magic == 1499087948u` 注释为 `'LDZY'`。
- **修复方案**:
  1. 定义可读常量：

     ```cpp
     const uint32_t kFourCcLdzy = MakeFourCC('L', 'D', 'Z', 'Y');
     ```

  2. 统一所有表格式 FourCC 常量，避免十进制字面量散落。
  3. 新增测试覆盖 `LDZY` 表头识别。

### DEF-L001: 匿名命名空间工具函数重复

- **复核结论**: 确认，Low；`DEF-I004` 与 `TD-001` 并入本项。
- **证据**: `NormalizeSlashes*`、`JoinPath`、`ReadFileBytes`、`MultiByteToWideBestEffort`、`EscapeJsonString` 等在多个 `.cpp` 中重复实现。
- **修复方案**:
  1. 新建内部工具模块，例如 `src/SLJFP_InternalUtils.h/.cpp`。
  2. 第一批只迁移无状态、无平台差异的函数：路径拼接、大小写转换、JSON 转义、文件读取。
  3. 平台转换函数单独放入 `SLJFP_TextEncodingUtils`，避免把 Windows API 依赖扩散到纯逻辑模块。
  4. 每迁移一组函数跑完整测试，避免一次性大重构。

### DEF-L002: `Unpacker` 类职责过重

- **复核结论**: 确认，Low；`TD-002` 并入本项。
- **证据**: `Unpacker` 同时负责索引加载、解密解压、流式/并行执行、路径恢复、输出清单、失败诊断与 review 数据。
- **修复方案**:
  1. 不建议在缺陷修复分支中一次性拆分。
  2. 先按低风险边界抽取：`IndexLoader`、`SourceIO` 已有雏形，可继续扩展；`OutputPathManager` 与 `PathRecoveryEngine` 后续拆。
  3. 每次抽取保持外部 API 不变，并用现有 279 个测试守住行为。

### DEF-L003: `FileInfo` 使用 `unsigned int` 而非固定宽度类型

- **复核结论**: 确认，Low。
- **证据**: `include/SLJFP_Unpack.h` 的 `FileInfo` 字段全部为 `unsigned int`。
- **修复方案**:
  1. 将字段改为 `uint32_t`，同步包含 `<cstdint>`。
  2. 对外 ABI 若已发布静态库/二进制包，需全量重编并更新包版本。
  3. 增加 `static_assert(sizeof(FileInfo::m_Size) == 4)` 或结构级大小测试。

### DEF-L004: `m_pathMapping` 使用 `std::map`

- **复核结论**: 确认但仅为 Low/性能建议；`DEF-I001` 并入本项。
- **纠偏**: 原报告中“线性搜索”表述不准确，`std::map::find` 是 O(log n)，不是 O(n)。
- **修复方案**:
  1. 若路径映射规模达到数万以上，可改为 `std::unordered_map<uint32_t, std::string>`。
  2. 注意 `GetPathMappingTable()` 当前返回 `std::map` 引用，直接改类型会破坏 API；应先新增只读枚举接口或 typedef 过渡。
  3. 用大映射 benchmark 决定是否值得变更。

### DEF-L005: Windows 长路径支持不完整

- **复核结论**: 确认，Low。
- **修复状态**: 已局部加固。
- **证据**: `CreateDirectoryRecursive` 使用 `CreateDirectoryW`，但没有为超过 `MAX_PATH` 的路径添加 `\\?\` 前缀；文件流打开也未统一长路径处理。
- **已执行修复**: Windows 输出文件创建统一优先通过 UTF-8 到宽字符路径打开，已修复中文 UTF-8 输出路径创建失败这一子问题；完整 `\\?\` 长路径规范化仍建议后续单独实现。
- **修复方案**:
  1. 增加 `NormalizeWin32LongPath`，对本地绝对路径加 `\\?\`，对 UNC 路径加 `\\?\UNC\`。
  2. 目录创建、文件打开、删除、移动统一经过该函数。
  3. 新增测试：超过 260 字符的嵌套路径创建和写入。

### DEF-L008: `SLJFP_Unpack.cpp` 文件过大，维护成本偏高

- **复核结论**: 确认但严重度为 Low；原报告中“超过 7000 行”的描述与当前源码不一致，实际约 6200 行以上，仍明显偏大。
- **修复状态**: 待治理。
- **证据**: `SLJFP_Unpack.cpp` 同时包含路径映射、清单输出、后处理恢复、文件类型启发式、流式解包、并行解包等多类逻辑。
- **修复方案**:
  1. 不在安全修复分支中直接大拆文件。
  2. 优先沿已存在的 `SLJFP_UnpackIndexIO`、`SLJFP_UnpackSourceIO` 边界继续抽取纯 IO 逻辑。
  3. 后续可拆出 `OutputPathManifestWriter`、`RestorePostProcessor`、`StreamUnpackEngine`，每次拆分保持外部 API 不变并跑完整测试。

---

## 6. Info 级确认问题

### DEF-I002: 日志接口以 `std::wstring` 为中心，跨平台体验较弱

- **复核结论**: 确认但属于 Info。当前项目明显偏 Windows GUI/工具链，不能按跨平台库标准直接判为缺陷。
- **修复建议**: 内部日志事件使用 UTF-8 `std::string`，Windows GUI 展示层再转 `std::wstring`；保持旧接口一段时间以降低迁移风险。

### DEF-I005: `ParseNpcRideTableData` 中 `524335u` 缺少命名常量

- **复核结论**: 确认，Info。
- **修复建议**: 定义 `kNpcRideTableHasDescriptionCheckNumber`，补充该值来源，并添加 fixture 覆盖带/不带额外字段两种表数据。

### TD-003: 错误码可读性和覆盖度仍需治理

- **复核结论**: 确认，Info。
- **修复建议**:
  1. 梳理所有硬编码错误码和 `std::to_wstring(result)` 输出点。
  2. 统一通过 `GetErrorMessage` 或新增 `GetErrorName` 输出。
  3. 为 `DecryptProbeRecord` 的 `errorCode`、`unzipResult` 添加可读描述。

### TD-005: MiniZ 包含方式较脆弱

- **复核结论**: 确认但风险较低。`MINIZ_HEADER_FILE_ONLY` 已在包含后 `#undef`，当前没有宏污染证据。
- **修复建议**: 将 MiniZ 声明/实现包装到单独编译单元，避免主解包文件依赖宏切换包含顺序。

---

## 7. 不成立或需删除的原报告项

| 编号 | 原结论 | 复核结论 | 依据 |
| --- | --- | --- | --- |
| `DEF-H001` | 多线程统计变量数据竞争 | 不成立 | `UnpackAllParallel` 与 `UnpackAllParallelOptimized` 中 `m_processedFiles`、`m_failedFiles`、`m_processedBytes`、`m_lastErrorCodeCounts`、`m_firstErrorCode` 均在 `statsMutex` 内更新。 |
| `DEF-H004` | `LoadLjzipIndexData` 可能越界读取解密数据 | 不成立 | 已校验 `compressedSize != 0 && compressedSize <= encryptedSize`；`encryptedData` 按 `encryptedSize` 完整读取，`decryptedData` 也按 `encryptedSize` 分配并填充。未见越界读取路径。 |
| `DEF-M005` | UTF-16 代理对导致 token 提取错误 | 不成立 | `ExtractPrintableUtf16Tokens` 只提取 ASCII `32..126`，代理对高低项都不会被当作 ASCII token；这更像“只支持 ASCII token”的能力边界。 |
| `DEF-L006` | 使用 `NULL` 而非 `nullptr` | 不作为缺陷 | 项目整体是 C++11 但仍有历史 C 风格代码；这属于风格一致性问题，不能计入缺陷。可在后续机械清理中处理。 |
| `DEF-I003` | `streamChunkSize` 未初始化 | 不成立 | `UnpackOptions` 构造函数已显式初始化 `streamChunkSize(4 * 1024 * 1024)`。 |
| `TD-004` | 缺乏单元测试 | 不成立，改为覆盖缺口建议 | 当前测试可执行文件包含 279 个用例且全部通过；仍建议继续补充未覆盖平台与性能边界测试。 |

---

## 8. 建议修复顺序

1. **第一批安全/正确性修复**：`DEF-C002`、`DEF-M001`、`DEF-H005`、`DEF-H006`、`DEF-H003`。本轮已完成。
2. **第二批输入健壮性修复**：`DEF-M007`、`DEF-M008`、`DEF-L007`、`DEF-M002`。本轮已完成。
3. **第三批兼容性与体验修复**：`DEF-M009`、`DEF-H002`、`DEF-M006`、`DEF-L005`。其中 `DEF-M006` 已完成，`DEF-H002` 与 `DEF-L005` 已局部加固，`DEF-M009` 待后续实现。
4. **第四批维护性治理**：`DEF-L001`、`DEF-L002`、`DEF-L003`、`DEF-L004`、`TD-003`、`TD-005`。

---

## 9. 回归测试清单

修复本报告确认项后，至少补充以下测试并执行完整基线：

| 测试目标 | 建议用例 |
| --- | --- |
| LJPI 安全解析 | 极大 `fileCount`、截断 entry、非对齐输入、小端字段正确性 |
| LJZIP 边界 | `compressedSize == 0`、`compressedSize > encryptedSize`、CRC mismatch、缺少 inflater |
| 流式输出清理 | 读失败、写失败、CRC mismatch、用户取消后输出文件不存在 |
| POSIX 目录创建 | 路径包含 shell 元字符时不执行命令，仅创建字面路径 |
| 大文件读取 | 散文件超过 `UINT32_MAX` 或 `MAX_DECOMPRESS_SIZE` 时返回确定错误 |
| 二进制映射 | `pathLen == 0`、`pathLen == 4096`、路径截断、合法中文路径 |
| JSON 清单 | UTF-8 中文路径 round-trip 后内容一致 |
| ELF 密钥提取 | ELF32 旧 fixture 保持通过，新增 ELF64 fixture |
| 严格恢复校验 | 合法根目录数字映射通过，未映射数字残留失败 |
| 解压重试 | inflater 连续返回 `Z_BUF_ERROR` 时不整数溢出 |

当前验证命令：

```powershell
cmake --build 'dependencies/SuperLJFilePackUnpack/build' --config Release --target ljfp-test
& 'dependencies/SuperLJFilePackUnpack/build/bin/Release/ljfp-test.exe'
```

当前验证结果：

- 构建：成功，`0` error；存在 `2278` 个既有 `C4127/C4505` 警告，未纳入本轮缺陷修复范围。
- 测试：`Total: 279, Passed: 279, Failed: 0, Skipped: 0`。

---

## 10. 缺陷汇总表（复核后）

| 编号 | 复核状态 | 复核严重度 | 文件 | 修订后摘要 |
| --- | --- | --- | --- | --- |
| `DEF-C001` | 部分确认 | Low | `SLJFP_LibsWrapper.cpp`, `LJFP_SMS4.h` | SMS4 密钥按值传递造成拷贝开销，不构成截断/安全漏洞证据 |
| `DEF-C002` | 确认 | High | `SLJFP_UnpackIndexIO.cpp` | `reinterpret_cast` 读取整数存在未对齐 UB |
| `DEF-C003` | 部分确认 | Low | `SLJFP_Unpack.cpp` | `const_cast` 反映接口 const 语义不清，当前未见输入被修改 |
| `DEF-H001` | 不成立 | - | `SLJFP_Unpack.cpp` | 统计变量更新已在 `statsMutex` 内 |
| `DEF-H002` | 部分确认 | Medium | `SLJFP_Unpack.cpp` | 取消响应不及时，非虚假唤醒问题 |
| `DEF-H003` | 确认 | High | `SLJFP_Unpack.cpp` | 流式失败路径可能残留半写入文件 |
| `DEF-H004` | 不成立 | - | `SLJFP_UnpackIndexIO.cpp` | 未发现 `compressedSize` 导致越界读取证据 |
| `DEF-H005` | 确认 | High | `SLJFP_Unpack.cpp` | POSIX `system("mkdir -p ...")` 存在命令注入 |
| `DEF-H006` | 确认 | High | `SLJFP_UnpackSourceIO.cpp` | 散文件大小转 `uint32_t` 可截断 |
| `DEF-M001` | 确认 | High | `SLJFP_UnpackIndexIO.cpp` | `fileCount` 未校验即 reserve，可导致内存 DoS |
| `DEF-M002` | 确认 | Medium | `SLJFP_Unpack.cpp`, `SLJFP_WorkflowReviewExportService.cpp` | JSON 转义破坏 UTF-8 语义 |
| `DEF-M003` | 确认 | Medium | `SLJFP_Unpack.cpp` | 后处理重复扫描和重复读文件 |
| `DEF-M004` | 确认 | Low | `SLJFP_Unpack.cpp` | CRC 查文件索引为线性搜索 |
| `DEF-M005` | 不成立 | - | `SLJFP_Unpack.cpp` | 该函数仅提取 ASCII token，代理对不会被错误纳入 token |
| `DEF-M006` | 确认 | Medium | `SLJFP_Unpack.cpp` | 严格校验可能误判合法根目录数字文件 |
| `DEF-M007` | 确认 | Medium | `SLJFP_Unpack.cpp` | 二进制映射非法 pathLen 可能静默跳过或导致流错位 |
| `DEF-M008` | 确认 | Medium | `SLJFP_Unpack.cpp` | `strtoul` 溢出未检查 |
| `DEF-M009` | 确认 | Medium | `SLJFP_AndroidBinaryKey.cpp` | 候选包含 64 位 so，但解析器仅支持 ELF32 |
| `DEF-M010` | 确认 | Low | `SLJFP_Unpack.cpp` | FourCC 魔数使用十进制字面量 |
| `DEF-L001` | 确认 | Low | 多文件 | 工具函数重复，含 `DEF-I004`/`TD-001` |
| `DEF-L002` | 确认 | Low | `SLJFP_Unpack.h/.cpp` | `Unpacker` 职责过重，含 `TD-002` |
| `DEF-L003` | 确认 | Low | `SLJFP_Unpack.h` | `FileInfo` 未使用固定宽度类型 |
| `DEF-L004` | 确认 | Low | `SLJFP_Unpack.h` | `std::map` 可按规模评估替换，含 `DEF-I001` |
| `DEF-L005` | 确认 | Low | `SLJFP_Unpack.cpp` | Windows 长路径支持不完整 |
| `DEF-L006` | 不作为缺陷 | - | 多文件 | `NULL` 属风格问题，不计入缺陷 |
| `DEF-L007` | 部分确认 | Medium | `SLJFP_Unpack.cpp` | 已有总大小限制，但翻倍前存在整数溢出风险 |
| `DEF-L008` | 确认 | Low | `SLJFP_Unpack.cpp` | 文件实际约 6236 行，仍偏大但不是原报告所称超过 7000 行 |
| `DEF-I002` | 确认 | Info | `SLJFP_Logger.h` | `wstring` 日志跨平台体验弱 |
| `DEF-I003` | 不成立 | - | `SLJFP_Unpack.h` | `streamChunkSize` 已显式初始化 |
| `DEF-I005` | 确认 | Info | `SLJFP_Unpack.cpp` | `524335u` 缺少命名常量和来源说明 |
| `TD-003` | 确认 | Info | 多文件 | 错误码可读性与覆盖度需治理 |
| `TD-004` | 原结论不成立 | - | `test/` | 当前已有 279 个通过测试，但仍需补充未覆盖平台与性能边界测试 |
| `TD-005` | 确认 | Info | `SLJFP_Unpack.cpp` | MiniZ 宏式包含方式较脆弱 |

---

## 11. 本轮修复执行状态

| 编号 | 执行状态 | 修复/验证摘要 |
| --- | --- | --- |
| `DEF-C002` | 已修复 | LJPI 解析改为小端逐字节读取，新增非对齐解析测试。 |
| `DEF-H003` | 已修复 | 流式与流式压缩输出失败统一删除半写入文件，新增 2 个 CRC mismatch 清理测试。 |
| `DEF-H005` | 已修复 | POSIX 目录创建移除 `system()`，改为逐级 `mkdir()`；静态验证 `SLJFP_Unpack.cpp` 无 `system(`。 |
| `DEF-H006` | 已修复 | 散文件大小超过上限直接返回 `LJFP_ERROR_DECOMPRESS_TOO_LARGE`，新增稀疏大文件测试。 |
| `DEF-M001` | 已修复 | LJPI `fileCount` 增加硬上限与理论最小条目校验，避免大分配。 |
| `DEF-M002` | 已修复 | 两处 JSON 转义保留 UTF-8 字节，新增 manifest 与 review export UTF-8 回归测试。 |
| `DEF-M006` | 已修复 | 严格恢复校验允许映射命中的根目录数字文件。 |
| `DEF-M007` | 已修复 | 二进制映射读取全字段校验，拒绝超长/截断路径。 |
| `DEF-M008` | 已修复 | atlas 宽高解析检查 `ERANGE` 与 `UINT32_MAX`。 |
| `DEF-L007` | 已修复 | 解压重试翻倍前检查上限，避免回绕。 |
| `DEF-C003` | 已修复 | 解密调用不再对外部输入缓冲做 `const_cast`。 |
| `DEF-H002` | 局部加固 | worker 领取任务后增加停止检查；非流式长耗时步骤的更细取消点待后续治理。 |
| `DEF-L005` | 局部加固 | 输出文件创建优先使用 Windows 宽字符路径；完整长路径 `\\?\` 策略待后续治理。 |
| `DEF-M003` | 待治理 | 后处理 I/O 缓存与性能基准建议拆成独立优化任务。 |
| `DEF-M009` | 待治理 | ELF64 解析需要新增 64 位 ELF 结构与 fixture，建议单独提交。 |
| 低优先级维护项 | 待治理 | `DEF-C001`、`DEF-M004`、`DEF-M010`、`DEF-L001`、`DEF-L002`、`DEF-L003`、`DEF-L004`、`DEF-L008` 不建议混入本轮安全修复。 |

---

## 12. 最终审计意见

当前项目功能完整度和测试基线优于原报告描述，特别是路径恢复、文件类型检测、SMS4、压缩、集成流程已有较多回归测试。本轮已完成 High 项与主要输入健壮性问题修复，并将测试基线提升到 279/279 通过。后续重点应放在 ELF64 支持、后处理性能缓存、长路径完整规范化和 `Unpacker` 职责拆分等独立治理任务上。

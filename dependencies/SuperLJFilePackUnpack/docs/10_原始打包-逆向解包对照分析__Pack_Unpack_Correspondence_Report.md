# 10 原始打包与逆向解包对照分析报告

> 基准日期: 2026-04-21
> 对照范围:
> - `dependencies/LJFilePack`
> - `dependencies/SuperLJFilePackUnpack`

## 文档定位

这份文档属于“实现对照与逆向分析材料”，不是日常构建或解包的快速入口。

适合使用它的场景：

- 需要确认原始 `LJFilePack` 与当前逆向工具在字段和字节流上的对应关系
- 需要解释为什么某些 CRC / 索引 / `.ljzip` 校验规则必须这样写
- 需要为后续坏包测试、格式审计或兼容模式扩展提供依据

如果目标只是“怎么构建、怎么用、怎么排错”，优先看：

- [README.md](../README.md)
- [02_快速开始_Quick_Start.md](02_快速开始_Quick_Start.md)
- [03_API接口_API_Reference.md](03_API接口_API_Reference.md)
- [12_现状审计与目录清理报告_Current_State_Audit.md](12_现状审计与目录清理报告_Current_State_Audit.md)

## 1. 分析目标

本报告关注两件事：

1. 原始打包工具 `LJFilePack` 是如何生成 `.ljpi / .ljzip / .ljfp / CRC32 散文件` 的
2. 逆向解包工具 `SuperLJFilePackUnpack` 是如何逐字段、逐步骤还原这些产物的

重点对齐：

- 文件头结构定义
- 索引生成和索引解析
- 压缩与加密顺序
- 字节级写入/读取例程
- 原始逻辑与逆向逻辑的差异和边缘情况

## 2. 结论摘要

### 2.1 保真复现部分

`SuperLJFilePackUnpack` 对以下原始打包逻辑做到了结构级同构还原：

- `.ljpi` 条目字段布局
- `.ljzip` 文件头和尾部元数据布局
- 资源文件的“先压缩、后加密”变换顺序
- `SMS4Ex / DeSMS4Ex` 的 1024 字节局部加解密语义
- `PathFileNameCRC32` 的来源和用途
- `PackIndex=0` 散文件、`PackIndex>0` 包内文件的区分

### 2.2 明显增强部分

`SuperLJFilePackUnpack` 在原始工具之上新增了真正可用的逆向能力：

- 真正支持 `.ljfp` 包内偏移读取
- 路径映射恢复原始路径
- 文件类型检测补扩展名
- `.ljpm` 二进制映射
- 自动解密模式回退
- 优化版并行解包
- 流式解包

### 2.3 关键差异

原始 `LJFilePack` 自带的 `unpack:` 帮助链路并不是严格对称的“完整反向打包器”。

它主要问题有两个：

1. 不使用 `PackIndex + Pos` 去读取 `.ljfp`
2. `LoadFromStream()` 后 `m_PathFileName` 已退化为 CRC32 字符串，因此无法恢复原始路径

换句话说，`SuperLJFilePackUnpack` 不只是“把原工具解包命令重写了一遍”，而是补全了原始工具未实现完整闭环的逆向恢复部分。

## 3. 原始打包链路

## 3.1 文件扫描

入口：

- `LJFP_Main.h`
- `LJFP_Main_Helper.h::FindOneFile`
- `LJFP_Find.h`

真实流程：

```text
命令行参数 -> 读取 LJFilePackOption.xml
  -> FindFiles()
  -> OnFindData()
  -> 文件/目录名强制 lower-case
  -> 根据 Option 判断:
       IsPackFile()
       IsCompressFile()
       IsCodeFile()
  -> FileList::AddFile()
```

重要事实：

- `_wcslwr_s()` 会把扫描到的文件名和目录名统一转小写
- 目录层级通过 `strParentPathName + strFileName` 以 `/` 风格累计
- 零字节文件在 `OnFindData()` 中被直接跳过，不进入打包

这也是为什么 `SuperLJFilePackUnpack::PathMappingGenerator` 当前默认：

- `lowercasePaths = true`
- `normalizeSlashes = true`

## 3.2 `PathFileNameCRC32` 的生成

原始生成位置：

- `LJFP_Pack.h::LJFP_FileList::AddFile`

核心逻辑：

```cpp
std::wstring wstrPF = pFile->m_PathName + pFile->m_Name;
std::string strPF = GetStringUtil().WS2S(wstrPF);
pFile->m_PathFileNameCRC32 = crc32(0, (unsigned char*)strPF.c_str(), strPF.size() * sizeof(char));
```

含义：

- CRC 输入不是宽字符字节流
- 输入是转成窄字符串后的路径字节
- 路径规范化已在扫描阶段完成

对应的逆向恢复手段：

- `SuperLJFilePackUnpack` 自身无法从索引反推原始路径
- 只能靠外部路径映射或参考目录重建同样的 CRC32

## 3.3 资源文件打包变换顺序

原始资源文件处理在 `LJFP_File` 中完成：

1. `LoadData()`
   - 读原始文件
   - 计算 `m_CRC32Original`
   - `m_Data = m_DataOriginal`
2. `CompressData()`
   - 仅当 `m_CompressType > 0`
   - 调用 `mz_compress2(level=9)`
   - 更新 `m_Size / m_CRC32`
3. `CodeData()`
   - 仅当 `m_CodeType > 0`
   - 调用 `SMS4Ex(..., "locojoy123456789")`
   - 更新 `m_Size / m_CRC32`

所以资源文件真实管线是：

```text
原始文件 -> 可选压缩 -> 可选加密 -> 落盘或写入 .ljfp
```

逆向时必须反着来：

```text
读取源数据 -> 可选解密 -> 可选解压 -> 校验原始 CRC32 -> 输出
```

`SuperLJFilePackUnpack::DecryptAndDecompress()` 正是按这个逆序实现。

## 3.4 `.ljfp` 包文件生成

原始生成位置：

- `LJFP_Pack.h::LJFP_Pack::ExportFileInfo(..., bPack=true, ...)`

逻辑：

- 新建 `1.ljfp`, `2.ljfp`, ...
- 每写一个文件前记录 `m_Pos = FS.tellp()`
- 直接写入变换后的 `m_Data[0..m_Size)`
- 当累计写入达到 `m_PackMaxSize`，关闭当前包，开启下一个

格式结论：

- `.ljfp` 本身没有额外包头
- 只是多个变换后文件的字节拼接
- 文件边界完全依赖 `.ljpi` 中的 `PackIndex + Pos + Size`

对应逆向实现：

- `ResolveSourceFilePath()`
- `OpenSourceFile()`
- `ReadFileData()`

这部分是 `SuperLJFilePackUnpack` 真正补全原始工具逆向能力的关键。

## 3.5 `.ljpi` 索引生成

原始打包并不是直接把 `LJFP_File` 数组写成 `.ljpi`，而是走了一次中间结构：

```text
LJFP_FileList::ExportRes()
  -> ExportFileInfoOne() 写入 XML/Node 树
  -> LJFP_PackInfo::LoadFromNode()
  -> LJFP_PackInfo::SaveToFile("fl.ljpi")
```

虽然路径有中间节点表示，但最终 `.ljpi` 只保留：

- `PackIndex`
- `Pos`
- `Size`
- `CRC32`
- `CompressType`
- `CodeType`
- `SizeOriginal`
- `CRC32Original`
- `PathFileNameCRC32`

原始路径字符串没有进入最终 `.ljpi`。

## 3.6 `.ljzip` 索引生成

原始生成位置：

- `LJFP_Pack.h::LJFP_FileList::ExportRes()`
- `LJFP_ZipFile::ZipFile() / ZipStream()`

真实流程：

```text
fl.ljpi
  -> 计算原始 CRC32
  -> mz_compress2(level=9)
  -> SMS4Ex(password="locojoy123456789")
  -> 写出 ljzip 头/体/尾
```

字节布局严格为：

```text
uint32 MagicKey      // 9999
uint32 SizeSMS4      // 加密体长度
byte   DataSMS4[SizeSMS4]
uint32 SizeZip       // 解密后的压缩体长度
uint32 SizeSrc       // 原始 ljpi 长度
uint32 CRC32Src      // 原始 ljpi CRC32
```

因为 `SMS4Ex` 不做 padding，只做局部 16B 分组加密并拷贝尾部，所以：

- 在原始打包器里，`SizeSMS4 == SizeZip`

对应逆向实现：

- `LoadLjzipIndex()`

区别是逆向工具为了兼容更宽松的输入，允许：

- `compressedSize <= encryptedSize`

而不是强制相等。

## 4. 逆向解包链路

## 4.1 索引解析

`SuperLJFilePackUnpack` 当前解析 `.ljpi` 的函数是：

- `ReadUInt32FromStream()`
- `ReadUInt32FromBuffer()`
- `ParseLjpiFileEntry()`
- `LoadLjpiIndex()`
- `ParseLjpiData()`

它逐字段读取的顺序与原始 `LJFP_FileInfo::SaveToStream()` 完全同构：

```text
PackIndex
[Pos if PackIndex > 0]
Size
CRC32
CompressType
CodeType
[SizeOriginal + CRC32Original if CompressType > 0 or CodeType > 0]
PathFileNameCRC32
```

## 4.2 `.ljzip` 逆向还原

`LoadLjzipIndex()` 对应原始 `LJFP_ZipFile::ZipStream()`：

```text
读 magic
读 encryptedSize
读 encrypted payload
读 compressedSize
读 originalSize
读 originalCRC32
按 decryptMode 候选:
  decrypt
  unzip
  verify original CRC32
成功后 ParseLjpiData()
```

这比原始 `LJFP_ZipFile::UnZipStream()` 更强的地方在于：

- 支持 `Auto` 候选重试
- 可扩展到 `ApkClientObf`
- 有 `MAX_DECOMPRESS_SIZE` 安全上限

## 4.3 资源文件逆向还原

`UnpackSingleFile()` 是对原始 `LoadData + CompressData + CodeData + SaveData` 的逆过程：

1. 读散文件或 `.ljfp` 中的片段
2. 若需要解密，则按选定模式解密
3. 若需要解压，则解压
4. 若开启 `verifyCRC32`，校验 `CRC32Original`
5. 构建输出路径并写出

## 4.4 路径恢复增强

原始打包器故意丢弃路径，所以逆向工具新增了两层能力：

### 第一层：外部路径映射

- 文本映射 `.txt / .map / .csv`
- 二进制映射 `.ljpm`

### 第二层：类型探测

- 没有路径映射时，以 `CRC32` 为文件名
- 基于 magic number 补扩展名

这两层都不是原始 `LJFilePack` 的组成部分，而是逆向恢复必须增加的工程能力。

## 5. 关键函数映射表

| 原始 `LJFilePack` | 逆向 `SuperLJFilePackUnpack` | 关系 |
|---|---|---|
| `LJFP_FileList::AddFile` | `PathMappingGenerator::ScanDirectory/AddPath` | 都基于规范化路径计算 CRC32 |
| `LJFP_File::LoadData` | `ReadFileData/OpenSourceFile` | 一个读取原始待打包文件，一个读取打包产物 |
| `LJFP_File::CompressData` | `DecryptAndDecompress` 中的解压阶段 | 逆操作 |
| `LJFP_File::CodeData` | `DecryptAndDecompress` 中的解密阶段 | 逆操作 |
| `LJFP_FileInfo::SaveToStream` | `ParseLjpiFileEntry/LoadLjpiIndex` | 字段布局同构 |
| `LJFP_PackInfo::SaveToFile` | `LoadLjpiIndex/ParseLjpiData` | 索引文件直接对应 |
| `LJFP_ZipFile::ZipStream` | `LoadLjzipIndex` | `.ljzip` 封装/解封装对照 |
| `LJFP_ZipFile::UnZipStream` | `LoadLjzipIndex` | 但逆向工具更健壮 |
| `ExportPackFile` | `DecryptAndDecompress` | 都是“对单个数据块做解密/解压” |
| `UnZipPack` | `UnpackAll` | 目标相似，但原工具实现不完整 |

## 6. 字节级结构对照

## 6.1 `.ljpi`

### 原始写入

```text
uint32 fileCount
for each file:
  uint32 PackIndex
  [uint32 Pos]
  uint32 Size
  uint32 CRC32
  uint32 CompressType
  uint32 CodeType
  [uint32 SizeOriginal]
  [uint32 CRC32Original]
  uint32 PathFileNameCRC32
```

### 逆向读取

`ParseLjpiFileEntry()` 逐项按同样规则读取，没有额外偏移或对齐字节。

## 6.2 `.ljzip`

### 原始写入

```text
4 bytes  MagicKey = 9999
4 bytes  SizeSMS4
N bytes  EncryptedCompressedData
4 bytes  SizeZip
4 bytes  SizeSrc
4 bytes  CRC32Src
```

### 逆向读取

`LoadLjzipIndex()` 用对应顺序读取，并在内存中直接恢复 `.ljpi` 内容。

## 6.3 `.ljfp`

### 原始写入

```text
concat(file_1_transformed, file_2_transformed, ...)
```

### 逆向读取

```text
open <PackIndex>.ljfp
seek Pos
read Size bytes
```

## 7. 关键差异与边缘情况

## 7.1 原始 `unpack:` 并不完整

`LJFP_Main_Helper::UnZipPack()` 存在明显非对称性：

- 它没有使用 `PackIndex`
- 也没有用 `Pos` 去读取 `.ljfp`
- 对每个文件直接按 `RootPathName + CurPathName + CurFileName` 找源文件

但 `LoadFromStream()` 之后：

- `m_PathFileName` 已经被设置成 `UI2WS(PathFileNameCRC32)`

因此：

- `CurPathName` 基本为空
- `CurFileName` 基本是十进制 CRC32 字符串
- 只能处理同目录 CRC 散文件
- 不能真正逆向 `.ljfp` 包文件

这也是 `SuperLJFilePackUnpack` 存在的根本原因之一。

## 7.2 路径映射在原始工具里不是恢复链的一部分

原始打包器在打包前知道真实路径，但生成索引时故意只落 `PathFileNameCRC32`。

因此逆向工具新增：

- `LoadPathMapping()`
- `LoadPathMappingBinary()`
- `GetPathMappingHitRate()`
- `PathMappingGenerator`

这些都是“弥补信息丢失”的工程措施，不是原格式的一部分。

## 7.3 原始打包器会提前阻止路径 CRC 冲突

`LJFP_Pack::CheckSameCRC32()` 会在发现重复 `PathFileNameCRC32` 时直接失败。

所以对正规包来说：

- 索引内重复路径 CRC 理论上不应出现

而 `SuperLJFilePackUnpack::PathMappingGenerator` 仍然保留 collision tracking，是为了：

- 处理参考目录本身存在冲突
- 处理非官方或污染输入

## 7.4 `SMS4Ex` 的“只处理前 1024 字节”是关键兼容点

原始 `SMS4Ex` / `DeSMS4Ex` 规则：

- 当 `uiSize >= 1024` 时
  - 只对前 `1024` 字节按 16B 分组加解密
  - 其余尾部直接拷贝
- 当 `uiSize < 1024` 时
  - 仅处理完整 16B 分组
  - 尾部不足 16B 的字节直接拷贝

`SuperLJFilePackUnpack` 在标准模式下沿用同一实现，因此和原打包器兼容。

## 7.5 `overwriteExisting` 与 `createDirectories` 是文义字段，不是完整行为开关

当前 `SuperLJFilePackUnpack` 中：

- `overwriteExisting` 参与配置，但写文件时没有显式“存在则跳过/报错”分支
- `createDirectories` 也是配置字段，但当前主流程始终会建目录

这不影响格式兼容，但属于逆向工具当前实现和字段语义之间的边缘差异。

## 7.6 `LoadIndex()` 对 `.ljzip` 的识别比原工具更宽松

当前实现通过字符串包含 `.ljzip` 判断，而不是严格按扩展名后缀判断。  
这通常没问题，但理论上会比原工具更宽松。

## 7.7 零字节文件是非典型输入

原始扫描器默认跳过零字节文件，所以正规由 `LJFilePack` 产出的索引一般不会包含空文件。  
`SuperLJFilePackUnpack` 仍然保留了对空输出的防御式处理，这属于鲁棒性增强。

## 8. 数据流向总图

### 8.1 正向打包

```text
资源目录
  -> 扫描并 lower-case 路径
  -> 计算 PathFileNameCRC32
  -> 按规则判定是否 pack/compress/code
  -> 文件数据可选压缩/加密
  -> 输出:
       CRC32 散文件 或 N.ljfp
       fl.ljpi
       fl.ljzip
```

### 8.2 逆向解包

```text
fl.ljpi / fl.ljzip
  -> 解析 FileInfo[]
  -> 按 PackIndex 决定读取散文件还是 .ljfp
  -> 按 CodeType / CompressType 逆向还原
  -> 按映射或类型检测构造输出路径
  -> 落盘为可读资源
```

## 9. 审计结论

从源码事实看，`SuperLJFilePackUnpack` 已经完成了对 `LJFilePack` 核心格式的真实逆向闭环：

- 索引结构是准确还原的
- `.ljzip` 封装和密码学语义是准确还原的
- `.ljfp` 偏移读取是对原始打包逻辑的准确补全

同时，它并不是简单镜像原始工具，而是在以下方向上做了有意增强：

- 更健壮的解密模式选择
- 更健壮的解压缓冲区扩张
- 更完整的包文件读取
- 外部路径映射和自动重建
- 并行和流式性能增强

如果只用一句话概括这份对照结果：

`LJFilePack` 负责“生成资源产物”，而 `SuperLJFilePackUnpack` 负责“把这些产物真正恢复成可用文件系统视图”；两者在格式和字节流上是同构的，但逆向工具在工程能力上明显更完整。`

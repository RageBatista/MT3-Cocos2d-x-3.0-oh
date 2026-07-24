# 04 文件格式

> 基准日期: 2026-03-13
> 以 `src/SLJFP_Unpack.cpp` 与 `include/SLJFP_PathMappingGenerator.h` 为准

## 1. 总览

当前模块直接处理 5 类数据格式：

1. `.ljpi` 明文索引
2. `.ljzip` 加密索引
3. `.ljfp` 包文件
4. 文本路径映射
5. `.ljpm` 二进制路径映射

## 2. `.ljpi` 索引格式

### 2.1 顶层结构

```text
uint32 FileCount
repeat FileCount times:
    FileEntry
```

### 2.2 `FileEntry` 读取规则

基础字段：

```text
uint32 PackIndex
if PackIndex > 0:
    uint32 Pos
uint32 Size
uint32 CRC32
uint32 CompressType
uint32 CodeType
if CompressType > 0 or CodeType > 0:
    uint32 SizeOriginal
    uint32 CRC32Original
else:
    SizeOriginal = Size
    CRC32Original = CRC32
uint32 PathFileNameCRC32
```

对应 `FileInfo` 字段：

- `PackIndex -> m_PackIndex`
- `Pos -> m_Pos`
- `Size -> m_Size`
- `CRC32 -> m_CRC32`
- `CompressType -> m_CompressType`
- `CodeType -> m_CodeType`
- `SizeOriginal -> m_SizeOriginal`
- `CRC32Original -> m_CRC32Original`
- `PathFileNameCRC32 -> m_PathFileNameCRC32`

### 2.3 格式结论

- 索引中不保存原始路径字符串
- 只保存路径的 CRC32
- 这就是解包后默认文件名会退化为数字的根因

## 3. `.ljzip` 加密索引格式

### 3.1 顶层结构

```text
uint32 MagicKey          // 固定为 9999
uint32 EncryptedSize
byte   EncryptedData[EncryptedSize]
uint32 CompressedSize
uint32 OriginalSize
uint32 OriginalCRC32
```

### 3.2 真实解析顺序

`LoadLjzipIndex()` 当前流程是：

1. 校验 `MagicKey == 9999`
2. 读取 `EncryptedSize`
3. 读取完整 `EncryptedData`
4. 读取 `CompressedSize`
5. 读取 `OriginalSize`
6. 读取 `OriginalCRC32`
7. 根据 `DecryptMode` 生成候选模式
8. 逐个尝试“解密 -> 解压 -> CRC 校验”
9. 成功后调用 `ParseLjpiData()`

### 3.3 限制

- `OriginalSize` 必须小于等于 `MAX_DECOMPRESS_SIZE`
- `CompressedSize` 不能大于 `EncryptedSize`

## 4. `.ljfp` 包文件格式

当前实现把 `.ljfp` 视为“裸拼接数据容器”：

- 没有额外包头解析
- 文件元数据全部来自 `.ljpi`
- 实际定位方式是：
  - 打开 `<PackIndex>.ljfp`
  - `seek` 到 `m_Pos`
  - 读取 `m_Size` 字节

## 5. 散文件布局

若 `m_PackIndex == 0`，解包器会直接查找：

```text
<inputDir>/<PathFileNameCRC32>
```

也就是说，散文件目录本身就是 CRC32 文件名集合，而不是保留原始路径树。

## 6. 文本路径映射格式

`LoadPathMapping()` 当前支持多种文本格式：

```text
CRC32|path
0xCRC32<TAB>path
CRC32,path
CRC32;path
CRC32=path
path|CRC32
```

解析特点：

- 允许十进制或十六进制 CRC32
- 允许 CRC 在左或右
- 第一行若包含 UTF-8 BOM，会自动剥离
- 允许注释：
  - `#`
  - `//`
- 重复 CRC 键时，后者覆盖前者

## 7. `.ljpm` 二进制映射格式

### 7.1 文件头

```text
uint32 Magic   = 0x4D504A4C   // "LJPM"
uint32 Version = 1
uint32 Count
```

### 7.2 条目结构

```text
uint32 CRC32
uint16 PathLen
byte   PathBytes[PathLen]
```

### 7.3 当前实现的额外行为

`LoadPathMappingBinary()` 会做三类额外校验：

1. 重新根据路径字节计算 CRC32
2. 若文件中存储的 CRC32 错误，则自动纠正
3. 若同一 CRC32 重复出现，则后条覆盖前条并记录 warning

这意味着 `.ljpm` 不是“完全信任输入文件”，而是“边加载边自修复”的格式。

## 8. 输出路径格式

### 8.1 命中映射

```text
<outputDir>/<mapped/original/path>
```

### 8.2 未命中映射

```text
<outputDir>/<PathFileNameCRC32>[.ext]
```

### 8.3 启用按类型分类

```text
<outputDir>/<type-dir>/<PathFileNameCRC32>[.ext]
```

类型目录来自 `BuildOutputPath()` 的硬编码映射：

- `images`
- `audio`
- `scripts`
- `config`
- `models`
- `fonts`
- `shaders`
- `data`
- `text`
- `misc`
- `unknown`

## 9. CRC32 与路径关系

模块内部默认假设：

- CRC32 计算基于路径字符串字节序列
- 路径映射生成器通常会先转小写，再统一为 `/`

这也是为什么映射生成时常用选项是：

- `lowercasePaths=true`
- `normalizeSlashes=true`

如果路径规范化方式和客户端打包时不一致，就会出现映射命中率低的问题。

## 10. 代码中的关键常量

```cpp
LJZIP_MAGIC_KEY      = 9999
DEFAULT_DECRYPT_KEY  = "locojoy123456789"
MAX_DECOMPRESS_SIZE  = 100 * 1024 * 1024
```

## 11. 格式关系图

```text
.ljzip
  -> 解密/解压
  -> .ljpi 逻辑内容
  -> FileInfo[]
  -> 定位散文件或 .ljfp
  -> 输出原始文件

path_mapping.txt / path_mapping.ljpm
  -> CRC32 -> path
  -> 参与 GetFilePath()/BuildOutputPath()
```

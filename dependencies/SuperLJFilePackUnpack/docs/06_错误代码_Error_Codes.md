# 06 错误代码

> 基准日期: 2026-04-21
> 事实源: `include/SLJFP_ErrorCodes.h` 与当前索引/解包实现

## 1. 命名规则

当前主错误码前缀是 `LJFP_ERR_*`。

`LJFP_ERROR_*` 仍存在，但只作为兼容别名。

## 2. 分段

- `0` 成功
- `1xx` 文件操作
- `2xx` 索引
- `3xx` 解密
- `4xx` 解压
- `5xx` CRC32
- `6xx` 包文件
- `7xx` 内存
- `8xx` 用户操作
- `9xx` 未知

## 3. 完整枚举

### 成功

- `0` `LJFP_SUCCESS`

### 文件操作

- `100` `LJFP_ERR_FILE_NOT_FOUND`
- `101` `LJFP_ERR_FILE_OPEN_FAILED`
- `102` `LJFP_ERR_FILE_READ_FAILED`
- `103` `LJFP_ERR_FILE_WRITE_FAILED`
- `104` `LJFP_ERR_FILE_SEEK_FAILED`
- `105` `LJFP_ERR_FILE_CREATE_FAILED`
- `106` `LJFP_ERR_DIRECTORY_CREATE_FAILED`
- `107` `LJFP_ERR_PERMISSION_DENIED`
- `108` `LJFP_ERR_DISK_FULL`
- `109` `LJFP_ERR_INVALID_INDEX`
- `110` `LJFP_ERR_PARTIAL_FAILURE`

### 索引

- `200` `LJFP_ERR_INDEX_NOT_FOUND`
- `201` `LJFP_ERR_INDEX_INVALID_FORMAT`
- `202` `LJFP_ERR_INDEX_VERSION_MISMATCH`
- `203` `LJFP_ERR_INDEX_CORRUPTED`
- `204` `LJFP_ERR_INDEX_DECRYPT_FAILED`
- `205` `LJFP_ERR_INDEX_DECOMPRESS_FAILED`

### 解密

- `300` `LJFP_ERR_DECRYPT_INVALID_KEY`
- `301` `LJFP_ERR_DECRYPT_INVALID_DATA`
- `302` `LJFP_ERR_DECRYPT_BLOCK_SIZE`
- `303` `LJFP_ERR_DECRYPT_MEMORY`
- `304` `LJFP_ERR_DECRYPT_FAILED`

### 解压

- `400` `LJFP_ERR_DECOMPRESS_DATA_CORRUPT`
- `401` `LJFP_ERR_DECOMPRESS_BUFFER_OVERFLOW`
- `402` `LJFP_ERR_DECOMPRESS_MEMORY`
- `403` `LJFP_ERR_DECOMPRESS_TOO_LARGE`
- `404` `LJFP_ERR_DECOMPRESS_UNKNOWN`
- `405` `LJFP_ERR_DECOMPRESS_FAILED`

### CRC32

- `500` `LJFP_ERR_CRC32_MISMATCH`
- `501` `LJFP_ERR_CRC32_ORIGINAL_MISMATCH`

### 包文件

- `600` `LJFP_ERR_PACK_NOT_FOUND`
- `601` `LJFP_ERR_PACK_INVALID_FORMAT`
- `602` `LJFP_ERR_PACK_SEEK_OUT_OF_RANGE`
- `603` `LJFP_ERR_PACK_SIZE_MISMATCH`

### 内存

- `700` `LJFP_ERR_MEMORY_ALLOCATION`
- `701` `LJFP_ERR_MEMORY_OVERFLOW`

### 用户操作

- `800` `LJFP_ERR_USER_CANCELLED`

### 未知

- `999` `LJFP_ERR_UNKNOWN`

## 4. 当前最常见的返回值

### 索引加载阶段

- `101`
  - 索引文件打不开
- `201`
  - `.ljzip` 魔数错误
  - `.ljzip` 头尾长度不足
  - `encryptedSize` 越界
  - `compressedSize == 0`
  - `compressedSize > encryptedSize`
  - `verifyCRC32=true` 但 `crc32Func == nullptr`
  - 需要解压但 `unzipFunc == nullptr`
  - 缺失 `desms4Func`
- `203`
  - `.ljpi` 记录损坏
  - `.ljzip` 解压后尺寸和 `originalSize` 不一致
- `205`
  - `.ljzip` 解压器返回失败
- `403`
  - `.ljzip` 声称的 `originalSize` 超过 `MAX_DECOMPRESS_SIZE`
- `500`
  - `.ljzip` 成功解压，但原始 CRC32 不匹配

### 解包执行阶段

- `100`
  - 散文件不存在
- `600`
  - `.ljfp` 包文件不存在
- `102`
  - 源文件读取失败
- `105`
  - 输出文件创建失败
- `103`
  - 输出文件写入失败
- `304`
  - 解密失败
- `405`
  - 解压失败
- `500`
  - 最终数据 CRC32 不匹配
- `110`
  - 主流程跑完，但有失败文件

## 5. `GetErrorMessage()`

头文件内联提供：

```cpp
const wchar_t* GetErrorMessage(ErrorCode code);
```

当前返回英文文本，适合：

- CLI 输出
- GUI 基础提示
- 日志记录

## 6. 审阅辅助机制

当前不仅返回错误码，还会额外保留：

- 最近一次失败文件列表
- 首个失败样本的候选探针链
- 输出路径 sidecar 审计

因此排障时应同时看：

- 返回码
- 日志
- `GetLastFailedFiles()`
- `GetFirstFailedDecryptDiagnostic()`

## 7. 排查建议

### `201` 很多

优先检查：

- 输入是不是错版本索引
- `.ljzip` 文件是否被截断
- 是否把坏包当成正常索引读
- 是否错误地要求 CRC 校验但没提供 CRC 函数

### `203 / 205` 很多

优先检查：

- 解压器行为
- 解密模式
- 数据是否损坏
- `originalSize` 是否可信

### `500` 很多

优先检查：

- 解密模式选错
- key 不匹配
- 读取到了错误源文件

### `110`

这不是“整体崩溃”，而是“流程完成但存在失败项”。应继续查看失败分组，而不是直接否定全部输出。

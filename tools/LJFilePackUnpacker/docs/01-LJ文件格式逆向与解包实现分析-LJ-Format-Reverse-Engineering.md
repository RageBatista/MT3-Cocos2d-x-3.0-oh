# LJFilePackUnpacker 逆向工程与代码级分析报告

> **文档版本**: 1.0.0  
> **最后更新时间**: 2026-02-28  
> **维护者**: MT3 技术委员会（工具链方向）  
> **源码路径**:  
> - `tools/LJFilePackUnpacker/`  
> - `dependencies/LJFilePack/`（格式与算法对照源）  
> - `client/resource/tools/`（资源打包脚本入口）  
> **相关文档**:  
> - `tools/LJFilePackUnpacker/docs/00-架构设计文档-Architecture-Design.md`  
> - `dependencies/LJFilePack/docs/09-解密技术方案Decryption_Technical_Solution.md`  
> - `docs/06-工具链/Launcher技术文档-2026-01-08.md`  
> - `client/Launcher/Code/Update/UpdateManagerEx.cpp`  

---

## 1. 分析目标与结论

### 1.1 目标

针对 `tools/LJFilePackUnpacker` 做代码级逆向分析，形成可复用的技术文档，覆盖：

1. LJ 文件格式二进制结构（`.ljzip`/`.ljpi`/`.ljfp`）
2. 加密、压缩、校验机制
3. 命令行参数与调用示例
4. 解密解包核心调用链
5. 在 MT3 资源构建/更新流程中的定位

### 1.2 核心结论

1. `LJFilePackUnpacker` 当前代码形态是“解包核心原型 + 部分 GUI 头文件”，缺少可执行入口（未发现 `main/wWinMain` 对应实现）。
2. LJ 真正格式以 `dependencies/LJFilePack` 为准：  
`.ljzip` 为 `Magic + SMS4数据 + 尾部元信息`；`.ljpi` 为“变长记录”而非固定 28 字节。
3. `tools/LJFilePackUnpacker` 的多处实现与真实生产格式不一致，直接用于当前资源包会失败（详见第 7 节“关键偏差与风险”）。

---

## 2. LJ 文件格式二进制结构解析

## 2.1 `.ljzip`（加密索引封装）

来源依据：

- `dependencies/LJFilePack/LJFP_ZipFile.h:57-62`
- `tools/LJFilePackUnpacker/src/FileHandler/LJFPU_ZipReader.cpp:57-130`

二进制布局（小端）：

| 偏移 | 长度 | 字段 | 说明 |
|---|---:|---|---|
| `0x00` | 4 | `Key` | 固定 `0x0000270F` |
| `0x04` | 4 | `SizeSMS4` | `DataSMS4` 字节数 |
| `0x08` | `SizeSMS4` | `DataSMS4` | 经 SMS4 处理后的压缩索引数据 |
| `0x08+SizeSMS4` | 4 | `SizeZip` | 压缩数据大小 |
| `0x0C+SizeSMS4` | 4 | `SizeSrc` | 原始索引数据大小 |
| `0x10+SizeSMS4` | 4 | `CRC32Src` | 原始索引 CRC32 |

样本验证（`client/resource/res1/fl.ljzip`）：

- `Key=0x0000270F`
- `SizeSMS4=411396`
- `SizeZip=411396`
- `SizeSrc=685348`
- `CRC32Src=0x9226CCC9`
- 文件总长满足：`8 + SizeSMS4 + 12 = 411416`

## 2.2 `.ljpi`（索引文件）

来源依据：

- `dependencies/LJFilePack/LJFP_FileInfo.h:101-170`（`LoadFromStream/SaveToStream`）
- `dependencies/LJFilePack/LJFP_FileInfo.h:306-326`（`LJFP_PackInfo::LoadFromStream`）

文件头：

| 偏移 | 长度 | 字段 |
|---|---:|---|
| `0x00` | 4 | `FileCount` |
| `0x04` | 变长 | `FileInfo[FileCount]` |

单条 `FileInfo` 为**变长记录**（不是固定 28 字节）：

1. 固定字段：
   - `PackIndex`（4）
2. 条件字段：
   - `Pos`（4，仅 `PackIndex > 0`）
3. 固定字段：
   - `Size`（4）
   - `CRC32`（4）
   - `CompressType`（4）
   - `CodeType`（4）
4. 条件字段：
   - `SizeOriginal`（4，仅 `CompressType>0 || CodeType>0`）
   - `CRC32Original`（4，仅 `CompressType>0 || CodeType>0`）
5. 固定字段：
   - `PathFileNameCRC32`（4）

因此单条长度可能是：

- `24` 字节（散文件且无压缩/加密）
- `28` 字节（打包文件且无压缩/加密，或散文件但有压缩/加密）
- `32` 字节（打包文件且有压缩/加密）

样本验证（`client/resource/res1/fl.ljpi`）：

- `FileCount=19199`
- 按上述变长规则可完整解析至 EOF（`finalOffset=685348`，无剩余）
- 包索引分布：`pack[0..7]` 共 8 组（`pack[0]` 为散文件区）

## 2.3 `.ljfp`（数据块文件）

来源依据：

- `dependencies/LJFilePack/LJFP_Pack.h:337`（打包文件命名）
- `dependencies/LJFilePack/LJFP_Pack.h:341-357`（连续写入数据）

组织方式：

1. `PackIndex > 0` 的文件内容按 `Pos` 偏移顺序写入 `N.ljfp`。
2. `PackIndex == 0` 的散文件，直接以 `PathFileNameCRC32` 作为文件名落地（例如 `1162650629`）。
3. `.ljfp` 本身不含独立文件头，靠 `.ljpi` 的索引描述切片读取。

---

## 3. 加密算法与压缩机制

## 3.1 SMS4（SM4）算法实现要点

来源依据：

- `dependencies/LJFilePack/LJFP_SMS4.h:209-266`
- `tools/LJFilePackUnpacker/src/Core/LJFPU_SMS4.cpp`

关键事实：

1. 密钥为硬编码字符串：`"locojoy123456789"`。
2. 原始工具 `SMS4Ex/DeSMS4Ex` 对输入做了**1024 字节上限处理**：  
`uiSize >= 1024` 时，仅前 1024 字节走 16 字节分组，尾部直接拷贝。
3. 解包顺序是：先 SMS4 逆处理，再 MiniZ 解压，再 CRC32 校验。

## 3.2 MiniZ/zlib 压缩解压

来源依据：

- `dependencies/LJFilePack/LJFP_ZipFile.h:44,111`
- `tools/LJFilePackUnpacker/src/Core/LJFPU_MiniZ.cpp:5-69`

关键点：

1. 压缩用 `mz_compress2(..., level=9)`。
2. 解压用 `mz_uncompress`（`LJFPU_MiniZ` 中封装为 `uncompress`）。
3. `.ljzip` 尾部保存了压缩前大小与 CRC32，用于解压后验证。

## 3.3 CRC32

来源依据：

- `dependencies/LJFilePack/LJFP_ZipFile.h:40,118`
- `tools/LJFilePackUnpacker/src/Core/LJFPU_CRC32.cpp`

用于：

1. `.ljzip` 解开后索引内容校验（`CRC32Src`）。
2. 文件级内容校验（`CRC32`/`CRC32Original`）。
3. 路径字符串映射键（`PathFileNameCRC32`）。

---

## 4. 工具命令行参数与示例

## 4.1 现状说明（LJFilePackUnpacker）

`tools/LJFilePackUnpacker` 当前源码中未发现 `main/wWinMain` 可执行入口，仅有核心类与部分 GUI 头文件，因此“可直接运行的 CLI 参数解析”尚未落地到该目录。

## 4.2 现网可用参数（来自 LJFilePack.exe）

参数定义来源：

- `dependencies/LJFilePack/LJFP_Main.h:35-308`
- `dependencies/LJFilePack/LJFP_Main_Helper.h:52-80`

包装脚本来源：

- `client/resource/tools/LJFilePack_Tools_*.bat`
- `client/resource/tools/LJFilePack_打包*.bat`

常用命令：

| 参数 | 功能 | 示例 |
|---|---|---|
| `ljpi2xml:<file>` | 将 `.ljpi` 转为 XML | `LJFilePack.exe ljpi2xml:fl.ljpi` |
| `ljzip2xml:<file>` | 将 `.ljzip` 解开并转 XML | `LJFilePack.exe ljzip2xml:fl.ljzip` |
| `decode:<file>` | 仅解密 | `LJFilePack.exe decode:1.ljfp` |
| `unzip:<file>` | 仅解压 | `LJFilePack.exe unzip:1.ljfp` |
| `decodeunzip:<file>` | 解密+解压 | `LJFilePack.exe decodeunzip:1.ljfp` |
| `unpack:<fl.ljpi/fl.ljzip>` | 全量解包 | `LJFilePack.exe unpack:fl.ljpi` |
| `makeupdatepack:<a|b|out>` | 生成两版差分包 | `LJFilePack.exe makeupdatepack:res0/|res1/|resNew/` |
| `makeupdatepackall:<list>` | 多版本差分链 | `LJFilePack.exe makeupdatepackall:list.txt` |
| `getversionnum` | 版本号文本转整数 | `LJFilePack.exe getversionnum` |
| `getversioncaption` | 版本号整数转文本 | `LJFilePack.exe getversioncaption` |
| `getstrcrc32` | 计算字符串 CRC32 | `LJFilePack.exe getstrcrc32` |
| `nopause` | 禁止结束暂停 | `LJFilePack.exe ... nopause` |

脚本调用示例：

```bat
%~dp0LJFilePack.exe unpack:%1
%~dp0LJFilePack.exe decodeunzip:%1
LJFilePack.exe version:2 update:4 channel:2 extend:2 io:4 filter:0 pack:0 compress:0 code:0
```

---

## 5. 核心解密解包逻辑（源码调用链）

## 5.1 索引加载链路

`LJFPU_FileHandler::LoadIndexFile()`：

1. `LJFPU_ZipReader::ReadFile()` 读取 `.ljzip` 头与 `DataSMS4`
2. `LJFPU_ZipReader::DecryptAndDecompressIndex()` 解密并解压索引
3. `LJFPU_PackInfo::Deserialize()` 反序列化索引记录
4. 初始化 `LJFPU_UnpackCore`

关键源码：

- `tools/LJFilePackUnpacker/src/FileHandler/LJFPU_FileHandler.cpp:21-63`
- `tools/LJFilePackUnpacker/src/FileHandler/LJFPU_ZipReader.cpp:27-178`

## 5.2 单文件解包链路

`LJFPU_FileHandler::UnpackFile()`：

1. `ReadFileData()` 从包文件读取切片
2. `DecryptAndDecompressFile()` 做解密/解压
3. 创建输出目录并写文件

关键源码：

- `tools/LJFilePackUnpacker/src/FileHandler/LJFPU_FileHandler.cpp:147-188`
- `tools/LJFilePackUnpacker/src/FileHandler/LJFPU_FileHandler.cpp:286-381`

## 5.3 数据处理核心

`LJFPU_UnpackCore`：

- `Decrypt()`：SMS4 逆处理
- `Decompress()`：zlib 解压 + CRC32 校验
- `DecryptAndDecompress()`：一体流程

关键源码：

- `tools/LJFilePackUnpacker/src/Core/LJFPU_UnpackCore.cpp:62-158`
- `tools/LJFilePackUnpacker/src/Core/LJFPU_UnpackCore.cpp:160-270`

---

## 6. 在 MT3 资源构建流程中的定位

## 6.1 构建阶段（资源生成）

资源打包脚本通过 `LJFilePack.exe` 生成：

1. `pack*.ljfp`（或 `N.ljfp`）资源包
2. `fl.ljpi` 索引
3. `fl.ljzip` 加密索引
4. `ver.ljvi` 版本信息

关键入口：

- `client/resource/tools/LJFilePack_打包win.bat`
- `client/resource/tools/LJFilePack_打包安卓.bat`
- `dependencies/LJFilePack/LJFP_Pack.h:501-543`

## 6.2 更新阶段（Launcher）

Launcher 更新流程中：

1. 下载 `fl.ljzip`
2. 使用 `LJFP_ZipFile` 解出 `fl.ljpi`
3. 解析差异并下载/覆盖资源

关键源码：

- `client/Launcher/Code/Update/UpdateManagerEx.cpp:263-292`
- `client/Launcher/Code/Update/UpdateManagerEx.cpp:370-430`

## 6.3 运行阶段（资源读取）

运行时文件系统初始化会读取 `fl.ljpi`，并用路径 CRC 映射资源实体。

关键源码：

- `common/ljfm/code/source/ljfmopen.cpp:53-99`

## 6.4 LJFilePackUnpacker 的实际角色

`tools/LJFilePackUnpacker` 应定位为：

1. 离线逆向与排障工具（验证包格式、抽检资源）
2. 资源构建回归工具（验证打包输出可逆）
3. 非运行时依赖组件（不参与客户端在线更新主链路）

---

## 7. 关键偏差与风险清单（代码级）

| 编号 | 问题 | 级别 | 影响 |
|---|---|---|---|
| R1 | `.ljpi` 按固定 28 字节解析 | 严重 | 与真实变长记录不兼容，索引解析错位 |
| R2 | 包文件命名使用 `pack%04u.ljfp` | 严重 | 与实际 `N.ljfp` 不一致，无法打开包文件 |
| R3 | `packIndex==0` 返回空路径 | 严重 | 散文件区无法读取 |
| R4 | 文件处理阶段“总是解压” | 严重 | 未压缩文件会被错误调用 zlib 解压 |
| R5 | SMS4 实现与原始算法实现不一致（SBox/轮函数/流程） | 严重 | 无法正确解密生产包 |
| R6 | SMS4 未保留原实现 `1024` 字节处理边界 | 严重 | 对 `.ljzip` 等数据解密结果偏离 |
| R7 | `LJFPU_FileInfo` 构造/拷贝声明缺失定义 | 高 | 工程链接风险 |
| R8 | 缺失完整 GUI/CLI 入口实现 | 中 | 当前目录不可直接产出可执行工具 |

对应证据：

- R1：`tools/LJFilePackUnpacker/src/FileHandler/LJFPU_PackInfo.cpp:152-167`  
对照 `dependencies/LJFilePack/LJFP_FileInfo.h:101-170`
- R2：`tools/LJFilePackUnpacker/src/FileHandler/LJFPU_FileHandler.cpp:442`  
对照 `dependencies/LJFilePack/LJFP_Pack.h:337`
- R3：`tools/LJFilePackUnpacker/src/FileHandler/LJFPU_FileHandler.cpp:434-437`
- R4：`tools/LJFilePackUnpacker/src/FileHandler/LJFPU_FileHandler.cpp:366`
- R5/R6：`tools/LJFilePackUnpacker/src/Core/LJFPU_SMS4.cpp`  
对照 `dependencies/LJFilePack/LJFP_SMS4.h:209-266`

---

## 8. 参考实现流程（建议落地）

1. 按真实变长规则重写 `.ljpi` 反序列化器。
2. 统一包命名策略：支持 `N.ljfp` 与 `packNNNN.ljfp` 双模式。
3. 明确散文件策略：`packIndex==0` 时从资源根目录按 `PathFileNameCRC32` 定位。
4. 恢复与原工具一致的 SMS4 实现（含 1024 边界）。
5. 修正“是否解压”分支，仅在 `CompressType>0` 时解压。
6. 补全 CLI 入口（最小参数集建议）：  
`--index <fl.ljpi|fl.ljzip> --pack-dir <dir> --out <dir> [--password] [--verbose]`

---

## 9. 附：样本验证摘要

验证样本：

- `client/resource/res1/fl.ljzip`
- `client/resource/res1/fl.ljpi`
- `client/resource/res1/1.ljfp`

关键观测：

1. `fl.ljzip` 头尾字段与 `LJFP_ZipFile` 写入逻辑完全一致。
2. `fl.ljpi` 必须按变长记录解析，才能精确到 EOF。
3. 资源目录实际存在 `1.ljfp ... 7.ljfp` 与大量 `CRC32` 命名散文件。

---

**文档状态**: 已完成首版逆向与代码级审计，可作为后续修复实现基线。  

# LJFilePackUnpacker 全量技术分析报告

> 文档日期：2026-03-30  
> 分析范围：`tools/LJFilePackUnpacker/`、`dependencies/LJFilePack/`、`dependencies/SuperLJFilePackUnpack/`、`client/resource/tools/`  
> 结论基线：以当前仓库源码、脚本、工程文件和可执行帮助输出为准；设计稿或历史文档若与源码冲突，以源码为准。

---

## 1. 报告目标与结论摘要

本报告的目标，不是只解释某一个 EXE 的使用方法，而是把 `tools/LJFilePackUnpacker` 所处的整条打包/解包链讲清楚，包括：

1. 这个工具在仓库里的真实定位
2. 它依赖的上下游工程和格式
3. 当前真正可运行的入口、命令行参数和 GUI 操作方式
4. 原始 LJ 打包链的底层实现逻辑
5. 当前原型代码与实际可用实现之间的差异
6. 典型应用场景与故障排除方法

核心结论如下：

1. `tools/LJFilePackUnpacker` 不是仓库原始生产打包链的源码目录。原始生产级打包工具是 `client/resource/tools/LJFilePack.exe`，其源码基线在 `dependencies/LJFilePack/`。
2. `tools/LJFilePackUnpacker` 目录内同时存在三套语义不同的内容：
   - 一套自研 C++ 解包原型
   - 一套 .NET WinForms MVP 图形界面
   - 一份分发目录 `dist/mvp`
3. 当前真正可运行、且被 `gui-mvp` 包装调用的解包后端，并不是该目录中的 C++ 原型，而是 `dependencies/SuperLJFilePackUnpack` 构建出来的 `ljfp-unpack.exe`。
4. 原始 LJ 资源格式的主干是：
   - `.ljfp`：资源数据容器
   - `.ljpi`：二进制索引
   - `.ljzip`：对 `.ljpi` 做压缩+加密后的索引封装
   - `.ljvi`：版本信息
5. 原始打包链与新解包链在能力边界上不同：
   - 原始 `LJFilePack.exe` 负责“扫描资源 -> 分类 -> 打包/散列输出 -> 生成索引/版本 -> 生成增量”
   - 新 `ljfp-unpack.exe` 负责“加载索引 -> 读取 `.ljfp`/散文件 -> 解密/解压 -> 路径恢复 -> 后处理”
6. `tools/LJFilePackUnpacker/inc+src` 下的自研 C++ 原型目前不适合作为生产解包器依据，因为它在索引格式、包命名、散文件处理和流程分支上与真实生产格式存在明显偏差。

---

## 2. 仓库定位与实现分层

### 2.1 需要先区分的三条线

为避免把不同年代、不同目的的实现混为一谈，本报告采用如下划分：

| 线索 | 路径 | 当前角色 |
|---|---|---|
| 原始生产打包链 | `dependencies/LJFilePack/` + `client/resource/tools/LJFilePack.exe` | 负责正式资源打包、索引生成、版本文件和差分包 |
| 当前可运行解包链 | `dependencies/SuperLJFilePackUnpack/` + `ljfp-unpack.exe` | 负责稳定解包、路径映射恢复、两阶段后处理 |
| `tools/LJFilePackUnpacker` 本地原型 | `tools/LJFilePackUnpacker/inc/` + `src/` | 研究性/原型性实现，当前不是主执行后端 |

### 2.2 `tools/LJFilePackUnpacker` 目录的真实构成

当前目录结构可以按职责理解为：

```text
tools/LJFilePackUnpacker/
├── docs/         # 本地文档与逆向分析
├── gui-mvp/      # .NET WinForms MVP GUI
├── scripts/      # GUI 构建/启动脚本
├── dist/mvp/     # GUI 分发目录（GUI + native CLI + CRT）
├── inc/ src/     # 自研 C++ 解包原型
└── README.md     # 混合了早期设计稿和后续 MVP 说明
```

### 2.3 当前推荐使用路径

按当前源码与脚本事实，推荐路径应拆分为两类：

1. 要做正式资源打包、生成 `fl.ljpi/fl.ljzip/ver.ljvi`、制作增量包：
   - 用 `client/resource/tools/LJFilePack.exe`
   - 或直接用它的 bat 封装脚本
2. 要做离线解包、逆向检查、路径恢复、资源抽取：
   - 用 `tools/LJFilePackUnpacker/gui-mvp`
   - 或直接用 `dependencies/SuperLJFilePackUnpack` 产出的 `ljfp-unpack.exe`

不建议把 `tools/LJFilePackUnpacker/src` 下的自研 C++ 原型当成当前主线可交付实现。

---

## 3. 组件架构与功能分工

### 3.1 原始生产打包链架构

原始 `LJFilePack.exe` 的总体职责是：

1. 读取 `LJFilePackOption.xml`
2. 根据命令行里的索引参数选择版本/渠道/IO/过滤/打包/压缩/加密配置
3. 扫描资源目录
4. 决定哪些文件打包进 `.ljfp`，哪些文件散列保存
5. 决定哪些文件压缩，哪些文件加密
6. 生成 `fl.ljpi`
7. 基于 `fl.ljpi` 生成 `fl.ljzip`
8. 生成 `ver.ljvi`
9. 可选执行版本差分比较

架构可以概括为：

```text
LJFilePack.exe
  ├─ 参数解析层
  ├─ 配置装载层 (LJFilePackOption.xml)
  ├─ 文件扫描层
  ├─ 打包分类层 (是否 Pack / Compress / Code)
  ├─ 数据处理层 (CRC32 / zlib / SMS4)
  ├─ 索引生成层 (.ljpi / .ljzip)
  └─ 版本/增量层 (.ljvi / makeupdatepack)
```

### 3.2 当前可运行解包链架构

当前实际可用的解包链是：

```text
WinForms GUI (tools/LJFilePackUnpacker/gui-mvp)
  └─ Process 启动 ljfp-unpack.exe
       └─ SLJFP::Unpacker
            ├─ LoadIndex(.ljpi/.ljzip)
            ├─ ReadFileData(.ljfp / loose file)
            ├─ DecryptAndDecompress()
            ├─ BuildOutputPath()
            ├─ 路径映射恢复
            ├─ 阶段化后处理
            └─ 并行/流式优化
```

### 3.3 `tools/LJFilePackUnpacker` 原型代码架构

自研原型自身采用典型四层结构：

```text
GUI 层
  └─ FileHandler 层
       ├─ LJFPU_FileHandler
       ├─ LJFPU_ZipReader
       └─ LJFPU_PackInfo
            └─ UnpackCore 层
                 ├─ LJFPU_UnpackCore
                 ├─ LJFPU_SMS4
                 ├─ LJFPU_MiniZ
                 └─ LJFPU_CRC32
```

但这套原型目前缺少真正的原生程序入口，目录内没有可用的 `main/wWinMain`，因此它更接近“实验性核心代码”而不是当前实际执行入口。

### 3.4 GUI 壳与 native CLI 的协作方式

`gui-mvp` 不是 DLL 直连架构，而是薄壳进程包装器：

1. GUI 收集输入目录、输出目录、索引文件、映射文件和几个复选项
2. GUI 按表单状态拼接 `ljfp-unpack.exe` 参数
3. GUI 用 `ProcessStartInfo` 启动 native CLI
4. GUI 实时读取标准输出/标准错误
5. GUI 用正则从 CLI 日志中抽取 `XX% (current/total)` 进度
6. GUI 更新进度条和日志窗口
7. 点“停止”时直接杀进程树

这意味着：

1. 真正的解包逻辑不在 WinForms 代码中
2. GUI 暴露的参数集只是 CLI 的一个子集
3. GUI 的稳定性高度依赖 `ljfp-unpack.exe` 的输出格式保持兼容

---

## 4. 目录与工程清单

### 4.1 `tools/LJFilePackUnpacker` 相关目录

| 目录 | 作用 |
|---|---|
| `tools/LJFilePackUnpacker/docs/` | 工具分析、架构与逆向文档 |
| `tools/LJFilePackUnpacker/gui-mvp/` | WinForms GUI 源码 |
| `tools/LJFilePackUnpacker/scripts/` | GUI 构建与启动脚本 |
| `tools/LJFilePackUnpacker/dist/mvp/` | GUI 分发目录 |
| `tools/LJFilePackUnpacker/inc/` | 自研 C++ 原型头文件 |
| `tools/LJFilePackUnpacker/src/` | 自研 C++ 原型源文件 |

### 4.2 原始生产链关键位置

| 路径 | 作用 |
|---|---|
| `dependencies/LJFilePack/` | 原始 LJFilePack 源码与文档 |
| `client/resource/tools/LJFilePack.exe` | 项目内实际使用的生产工具 |
| `client/resource/tools/LJFilePackOption.xml` | 项目当前打包配置 |
| `client/resource/tools/LJFilePack_打包*.bat` | 平台打包入口 |
| `client/resource/tools/LJFilePack_Tools_*.bat` | 解包/转换/差分等单功能入口 |

### 4.3 当前可运行解包链关键位置

| 路径 | 作用 |
|---|---|
| `dependencies/SuperLJFilePackUnpack/` | 当前主用解包库、CLI、GUI、测试 |
| `dependencies/SuperLJFilePackUnpack/examples/UnpackExample.cpp` | `ljfp-unpack.exe` 参数入口 |
| `dependencies/SuperLJFilePackUnpack/include/SLJFP_Unpack.h` | 核心解包数据结构与选项定义 |
| `dependencies/SuperLJFilePackUnpack/src/SLJFP_Unpack.cpp` | 核心解包实现 |

---

## 5. 文件格式规范

本节统一说明真实生产格式，而不是原型里的简化假设。

### 5.1 `.ljfp`：资源数据包

`.ljfp` 是资源数据容器，不带独立复杂头结构。它的定位完全依赖 `.ljpi`：

1. `PackIndex > 0` 的文件内容会按顺序写入 `N.ljfp`
2. 每个文件项在 `.ljpi` 中记录：
   - 所属包号 `PackIndex`
   - 包内偏移 `Pos`
   - 当前大小 `Size`
3. 解包时只需：
   - 打开 `<PackIndex>.ljfp`
   - `seek` 到 `Pos`
   - 读取 `Size` 字节

当前生产链中，包文件命名规则是真实的 `1.ljfp`、`2.ljfp`、`3.ljfp`，不是 `pack0001.ljfp`。

### 5.2 `.ljpi`：明文索引

顶层结构：

```text
uint32 FileCount
repeat FileCount times:
    FileEntry
```

单条 `FileEntry` 的真实规则是变长记录，不是固定 28 字节：

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
    SizeOriginal  = Size
    CRC32Original = CRC32

uint32 PathFileNameCRC32
```

因此实际记录长度可能是：

| 条件 | 长度 |
|---|---:|
| 散文件且未压缩/未加密 | 24 字节 |
| 打包文件且未压缩/未加密 | 28 字节 |
| 散文件但压缩或加密 | 28 字节 |
| 打包文件且压缩或加密 | 32 字节 |

这也是为什么 `tools/LJFilePackUnpacker` 原型里“固定 28 字节/条”的假设并不成立。

### 5.3 `.ljzip`：加密索引封装

`.ljzip` 不是资源包本体，而是 `.ljpi` 的“压缩+加密封装”：

```text
uint32 MagicKey        // 固定 9999 (0x270F)
uint32 SizeSMS4
byte   DataSMS4[SizeSMS4]
uint32 SizeZip
uint32 SizeSrc
uint32 CRC32Src
```

处理链路是：

1. 先把 `.ljpi` 原始内容读入内存
2. 计算原始 CRC32
3. 用 zlib/miniz 压缩
4. 用 SMS4 处理压缩结果
5. 写入上述头+数据+尾

解开时则反过来：

1. 验证 `MagicKey == 9999`
2. 读取加密体 `DataSMS4`
3. 解密为压缩数据
4. 解压为 `.ljpi` 原始内容
5. 用 `CRC32Src` 校验

### 5.4 `.ljvi`：版本信息

`ver.ljvi` 保存更新链所需的元数据，典型包含：

1. 当前版本号
2. 基础版本号
3. 最低允许版本
4. 版本校验开关
5. 渠道号、渠道说明
6. 更新 URL 列表
7. AppURL
8. 扩展字段

它本质上对应的是 `LJFilePackOption.xml` 中 `Version`、`Update`、`Channel`、`Extend` 节点导出的运行时版本描述。

### 5.5 散文件布局

当 `PackIndex == 0` 时，资源不会进入 `.ljfp`，而是以“路径 CRC32”作为文件名直接落盘：

```text
<outputDir>/<PathFileNameCRC32>
```

这也是很多解包结果只剩数字文件名的根因：索引只保存路径 CRC32，不保存原始路径字符串。

### 5.6 路径映射文本格式

当前 `ljfp-unpack.exe` 支持文本路径映射，常见格式包括：

```text
CRC32|path
0xCRC32<TAB>path
CRC32,path
CRC32;path
CRC32=path
path|CRC32
```

特性：

1. 支持十进制和十六进制 CRC32
2. 支持 CRC 在左或在右
3. 支持 UTF-8 BOM 自动剥离
4. 支持 `#`、`//` 注释
5. 重复键后者覆盖前者

### 5.7 `.ljpm`：二进制路径映射

二进制路径映射的逻辑格式为：

```text
uint32 Magic   = 0x4D504A4C   // "LJPM"
uint32 Version = 1
uint32 Count

repeat Count times:
    uint32 CRC32
    uint16 PathLen
    byte   PathBytes[PathLen]
```

加载时还会做额外自检：

1. 重新根据路径计算 CRC32
2. 若文件里记错 CRC，会自动修正
3. 重复键保留最后一个条目并记 warning

---

## 6. 数据结构与关键常量

### 6.1 原始生产链关键结构

#### `LJFP_FileInfo`

真实生产链中的单文件索引项核心字段是：

| 字段 | 含义 |
|---|---|
| `m_PackIndex` | 包号，0 表示散文件 |
| `m_Pos` | 在 `.ljfp` 中的偏移 |
| `m_Size` | 当前存储尺寸 |
| `m_CRC32` | 当前数据 CRC32 |
| `m_CompressType` | 压缩标志 |
| `m_CodeType` | 加密标志 |
| `m_SizeOriginal` | 原始大小 |
| `m_CRC32Original` | 原始 CRC32 |
| `m_PathFileNameCRC32` | 原始路径的 CRC32 |
| `m_PathFileName` | 运行时可还原/填充的逻辑路径 |
| `m_PackFileName` | 运行时包文件名 |

#### `LJFP_PackInfo`

它维护：

1. 文件数组
2. CRC32 到文件项的映射
3. 每个包的统计信息

它既能从 `.ljpi` 二进制加载，也能转成 XML 节点结构。

### 6.2 当前解包链关键结构

#### `SLJFP::FileInfo`

当前解包器采用的核心索引项字段与生产链兼容：

| 字段 | 含义 |
|---|---|
| `m_PackIndex` | 包号 |
| `m_Pos` | 包内偏移 |
| `m_Size` | 当前大小 |
| `m_CRC32` | 当前 CRC32 |
| `m_CompressType` | 压缩类型 |
| `m_CodeType` | 加密类型 |
| `m_SizeOriginal` | 原始大小 |
| `m_CRC32Original` | 原始 CRC32 |
| `m_PathFileNameCRC32` | 原始路径 CRC32 |

#### `SLJFP::UnpackOptions`

这是当前 CLI 的行为开关总表，重要项包括：

| 选项字段 | 含义 |
|---|---|
| `verifyCRC32` | 是否校验 CRC |
| `overwriteExisting` | 是否覆盖现有文件 |
| `threadCount` | 线程数 |
| `decryptKey` | 自定义密钥 |
| `useStreamMode` | 是否流式解包 |
| `detectFileType` | 是否探测扩展名 |
| `preferPathMapping` | 是否优先走路径映射 |
| `organizeByType` | 是否按类型分桶 |
| `forceCrcOutputFirst` | 是否先按 CRC 落盘 |
| `restorePathStructureAfterUnpack` | 是否二阶段恢复路径 |
| `strictRestoreValidation` | 是否严格校验恢复结果 |
| `relocateRootNumericResiduals` | 是否归档根目录数字残留 |
| `writeReviewAliases` | 是否写 review alias |
| `decryptMode` | 解密模式 |

### 6.3 自研原型关键结构

`tools/LJFilePackUnpacker` 原型里主要有：

1. `LJFPU_FileInfo`
2. `LJZIP_Header`
3. `LJFPU_PackStats`
4. `LJFPU_UnpackCore`

但需要注意：

1. 原型把索引项二进制结构固定成 28 字节
2. 这和真实生产格式并不一致

### 6.4 关键常量

| 常量 | 值 | 说明 |
|---|---|---|
| LJZIP Magic | `9999` / `0x270F` | `.ljzip` 魔数 |
| 默认密钥 | `locojoy123456789` | 原始生产链与新解包链都默认使用 |
| 最大单包大小 | `52428800` | 默认 50MB |
| 最大解压大小 | `100MB` | 当前 `SLJFP::Unpacker` 的保护上限 |
| SMS4 块大小 | `16` 字节 | 128 位分组 |
| 原始 SMS4 处理上限 | `1024` 字节 | 生产链里超过 1024 字节时只处理前 1024 字节，余下直接拷贝 |

---

## 7. 命令行参数与操作语法

本节必须区分三套入口：

1. 当前 GUI 暴露出来的用户操作
2. 当前底层 CLI `ljfp-unpack.exe` 的完整参数
3. 原始 `LJFilePack.exe` 的生产级参数

### 7.1 GUI 可视化操作方式

`tools/LJFilePackUnpacker/gui-mvp` 当前暴露的字段有：

1. 资源目录
2. 输出目录
3. 索引文件
4. 映射文件
5. `启用 CRC32 校验`
6. `覆盖已存在文件`
7. `启用文件类型检测`
8. `一键解包`
9. `停止`
10. `打开输出目录`

GUI 的标准操作流程：

1. 选择资源目录
2. 可选指定 `fl.ljpi` 或 `fl.ljzip`
3. 可选指定映射文件 `*.ljpm/*.map/*.txt`
4. 选择输出目录
5. 配置校验/覆盖/类型探测
6. 点击“一键解包”

### 7.2 GUI 实际传递给 CLI 的参数

GUI 实际拼接的参数只有：

```text
"<inputDir>" "<outputDir>"
--no-verify
--overwrite
--no-detect
--index="<file>"
--mapping="<file>"
```

也就是说，GUI 并没有把 CLI 的所有能力都暴露出来。

### 7.3 当前 `ljfp-unpack.exe` 完整 CLI 语法

当前源码与实际帮助输出对应的完整语法为：

```text
ljfp-unpack <输入目录|索引文件> [输出目录] [选项]

选项:
  --index=FILE
  --no-verify
  --overwrite
  --mapping=FILE
  --scan=DIR
  --strict-restore
  --no-detect
  --keep-root-residuals
  --review-aliases
  --decrypt-mode=auto|lj|apk
  --decrypt-key=K
  --help
```

参数说明如下：

| 参数 | 作用 |
|---|---|
| `<输入目录>` | 自动查找其中的 `fl.ljpi` 或 `fl.ljzip` |
| `<索引文件>` | 也可直接传入单个 `.ljpi` 或 `.ljzip` |
| `[输出目录]` | 输出目录，默认 `./unpacked/` |
| `--index=FILE` | 显式指定索引文件 |
| `--no-verify` | 跳过 CRC32 校验 |
| `--overwrite` | 覆盖已有文件 |
| `--mapping=FILE` | 加载路径映射 |
| `--scan=DIR` | 扫描目录生成路径映射文件 |
| `--strict-restore` | 开启严格恢复校验 |
| `--no-detect` | 禁用文件类型探测 |
| `--keep-root-residuals` | 保留根目录数字残留，不归档 |
| `--review-aliases` | 写人工核对别名副本 |
| `--decrypt-mode=auto|lj|apk` | 指定解密模式 |
| `--decrypt-key=K` | 指定自定义密钥 |
| `--help` | 显示帮助 |

#### PowerShell 示例

```powershell
& .\dependencies\SuperLJFilePackUnpack\build\bin\Release\ljfp-unpack.exe `
  '.\client\resource\res1' `
  '.\tools\LJFilePackUnpacker\output' `
  '--mapping=.\path_mapping.ljpm' `
  '--overwrite'
```

#### 直接生成映射文件

```powershell
& .\dependencies\SuperLJFilePackUnpack\build\bin\Release\ljfp-unpack.exe `
  '--scan=.\client\resource\res'
```

### 7.4 原始 `LJFilePack.exe` 生产参数语法

原始 `LJFilePack.exe` 默认不是靠显式路径长参数工作，而是通过“索引型参数”选择 `LJFilePackOption.xml` 中的配置段：

```text
version:N update:N channel:N extend:N io:N filter:N pack:N compress:N code:N [nopause]
```

各参数含义：

| 参数 | 含义 |
|---|---|
| `version:N` | 选择版本配置 |
| `update:N` | 选择更新配置 |
| `channel:N` | 选择渠道配置 |
| `extend:N` | 选择扩展字段配置 |
| `io:N` | 选择输入/输出路径配置 |
| `filter:N` | 选择过滤规则 |
| `pack:N` | 选择打包规则 |
| `compress:N` | 选择压缩规则 |
| `code:N` | 选择加密规则 |
| `nopause` | 结束时不暂停 |

#### Win 打包示例

```powershell
& .\client\resource\tools\LJFilePack.exe `
  'version:2' 'update:4' 'channel:2' 'extend:2' `
  'io:4' 'filter:0' 'pack:0' 'compress:0' 'code:0'
```

#### 直接看帮助

```powershell
cmd /c "client\resource\tools\LJFilePack.exe ?"
```

### 7.5 原始工具的单功能命令

原始 `LJFilePack.exe` 还支持下列独立命令：

| 命令 | 作用 |
|---|---|
| `getversionnum` | 版本号文本转整数 |
| `getversioncaption` | 整数转版本号文本 |
| `getstrcrc32` | 计算字符串 CRC32 |
| `verljvi2xml:<file>` | `.ljvi -> .xml` |
| `verxml2ljvi:<file>` | `.xml -> .ljvi` |
| `ljpi2xml:<file>` | `.ljpi -> .xml` |
| `ljzip2xml:<file>` | `.ljzip -> 解出 `.ljpi` -> `.xml` |
| `decode:<file>` | 仅解密，输出 `.decode` |
| `unzip:<file>` | 仅解压，输出 `.unzip` |
| `decodeunzip:<file>` | 解密+解压，输出 `.decodeunzip` |
| `unpack:<fl.ljpi|fl.ljzip>` | 全量解包 |
| `makeupdatepack:<base|new|out>` | 双版本差分包 |
| `makeupdatepackall:<listfile>` | 多版本差分链 |

### 7.6 项目内现成 bat 封装

项目已经准备了大量 bat 封装，常用的有：

| 脚本 | 作用 |
|---|---|
| `LJFilePack_打包苹果.bat` | iOS 打包 |
| `LJFilePack_打包安卓.bat` | Android 打包 |
| `LJFilePack_打包纯纯的安卓.bat` | Android 纯散文件模式 |
| `LJFilePack_打包win.bat` | Win 打包 |
| `LJFilePack_解包解密.bat` | 全量解包 |
| `LJFilePack_Tools_Unpack.bat` | 单命令解包 |
| `LJFilePack_Tools_Decode*.bat` | 单文件解密/解压 |
| `LJFilePack_Tools_MakeUpdatePackAll.bat` | 多版本增量 |

### 7.7 一个容易误判的参数陷阱

原始解析器只识别裸参数 `nopause`，不识别 `nopause:0`。

因此：

1. `nopause` 生效
2. `nopause:0` 不会命中关闭暂停的逻辑

这意味着某些旧脚本里写的 `nopause:0` 实际上是无效参数。

---

## 8. 打包的底层实现逻辑

### 8.1 总体流程

原始打包链的真实流程是：

```text
读取配置
  -> 扫描输入目录
  -> 对每个文件判定:
       是否过滤
       是否进包
       是否压缩
       是否加密
  -> 读取原始数据
  -> CRC32
  -> 可选 zlib 压缩
  -> 可选 SMS4 加密
  -> 输出:
       散文件 (CRC32 文件名)
       或 N.ljfp
  -> 生成 fl.ljpi
  -> 生成 fl.ljzip
  -> 生成 ver.ljvi
```

### 8.2 配置决策逻辑

原始工具会根据 `LJFilePackOption.xml` 决定每个文件的命运：

1. `IsFilterFile/IsFilterDir`
   - 决定是否过滤
2. `IsPackFile`
   - 决定是进 `.ljfp` 还是散文件
3. `IsCompressFile`
   - 决定是否压缩
4. `IsCodeFile`
   - 决定是否加密

这些规则支持按：

1. 文件名
2. 完整相对路径
3. 扩展名
4. 目录名
5. 完整目录路径

进行判定。

### 8.3 单文件数据处理链

对每个文件，`LJFP_File` 的典型处理顺序是：

1. `LoadData()`
   - 读入原始字节
   - 计算原始 CRC32
2. `CompressData()`
   - 若 `CompressType > 0` 且允许压缩，则走 `mz_compress2(level=9)`
3. `CodeData()`
   - 若 `CodeType > 0` 且允许加密，则走 `SMS4Ex`
4. 若是散文件：
   - 用 `PathFileNameCRC32` 作文件名直接保存
5. 若是打包文件：
   - 写入当前 `.ljfp`
   - 记录包号与偏移

### 8.4 `.ljfp` 输出逻辑

当 `OutputType = Pack` 时：

1. `PackIndex == 0` 的散文件先单独输出
2. 需要进包的文件从 `1.ljfp` 开始写
3. 单包大小达到 `MaxSize` 后，切换到下一个 `.ljfp`
4. 每个文件都把 `Pos` 和最终尺寸写入索引节点

### 8.5 `fl.ljpi` 生成逻辑

打包完成后会先构建 XML 树式节点，再转换成 `LJFP_PackInfo`，最后写回 `fl.ljpi`：

1. 每个包节点记录 `FileCount` 和 `Size`
2. 每个文件节点记录：
   - `P`
   - `PFNC32`
   - `S`
   - `C32`
   - `CPT`
   - `CDT`
   - `SO`
   - `C32O`
3. 再由 `LJFP_PackInfo::SaveToFile()` 输出为 `.ljpi`

### 8.6 `fl.ljzip` 生成逻辑

`fl.ljpi` 输出后，会立即走：

1. `mz_compress2`
2. `SMS4Ex`
3. 写 `Magic/SizeSMS4/DataSMS4/SizeZip/SizeSrc/CRC32Src`

最终得到 `fl.ljzip`。

### 8.7 `ver.ljvi` 生成逻辑

版本文件导出时，会把配置里的：

1. 版本号
2. 基础版本
3. 最低版本
4. 渠道
5. URL 列表
6. AppURL
7. 扩展字段

写入 `ver.ljvi`。

---

## 9. 解包的底层实现逻辑

### 9.1 当前主解包器 `SLJFP::Unpacker` 的总体流程

当前主解包器的真实流程为：

```text
LoadIndex(indexPath)
  -> .ljpi or .ljzip
  -> 解析索引项

UnpackAll(inputDir, outputDir, options)
  -> 读取每个文件的数据源
  -> 解密/解压
  -> CRC 校验
  -> 构建输出路径
  -> 落盘
  -> 路径恢复后处理
  -> 严格校验/清单输出
```

### 9.2 索引加载逻辑

`LoadIndex()` 会根据扩展名决定：

1. `.ljpi`：直接解析
2. `.ljzip`：读取头部、加密体和尾部元信息，再做“解密 -> 解压 -> CRC 校验 -> 按 `.ljpi` 解析”

#### `Auto` 解密模式的真实含义

`Auto` 不是万能自适应，而是按固定候选顺序重试：

1. `LJFilePackSMS4`
2. `ApkClientObf`

### 9.3 数据源定位

当前解包器读取单文件时只有两条规则：

1. `m_PackIndex == 0`
   - 去 `<inputDir>/<PathFileNameCRC32>` 读取散文件
2. `m_PackIndex > 0`
   - 去 `<inputDir>/<PackIndex>.ljfp` 打开包
   - `seek` 到 `m_Pos`
   - 读取 `m_Size`

### 9.4 解密与解压逻辑

单文件处理时，逻辑大致是：

```text
if needDecrypt:
    先按 decryptMode 处理

if needDecompress:
    以 originalSize 或估算值申请缓冲区
    调用 zlib uncompress
    遇到 Z_BUF_ERROR 时扩容重试
    最多重试若干次
else:
    直接拷贝

if verifyCRC32:
    校验原始 CRC32
```

### 9.5 路径恢复与两阶段策略

当前主解包器默认支持两阶段恢复：

#### 阶段 1：先按 CRC32 落盘

优点：

1. 不依赖映射完整性
2. 先保证内容能成功解出来
3. 为后续路径恢复提供稳定输入

#### 阶段 2：再恢复目录结构与文件名

优先级：

1. 命中路径映射则直接使用映射路径
2. 未命中时，尝试从内容中推断扩展名和目录语义
3. 根目录残留数字文件可归档到 `review/unresolved`

#### 阶段 3 及以后：后处理

当前解包器还支持：

1. 仅补扩展名
2. `model/` 目录的保守归位
3. `effect/`、`spine/`、`table/` 等语义链恢复
4. review alias 副本生成
5. 输出路径清单生成
6. 根目录数字残留归档
7. 严格恢复校验

### 9.6 并行与流式

当前主解包器不是简单顺序处理，还支持：

1. 顺序解包
2. 优化版并行解包
   - 先按 `PackIndex + Pos` 排序
   - 预创建目录
   - 固定分片分配给线程
3. 流式解包
   - 针对大文件减少峰值内存
   - 但若解密模式是 `Auto`、加密块不对齐或流式解压不稳定，会自动回退普通路径

---

## 10. `tools/LJFilePackUnpacker` 原型源码的现状与局限

### 10.1 它实现了什么

原型代码确实实现了以下模块：

1. `LJFPU_SMS4`
2. `LJFPU_MiniZ`
3. `LJFPU_CRC32`
4. `LJFPU_UnpackCore`
5. `LJFPU_ZipReader`
6. `LJFPU_PackInfo`
7. `LJFPU_FileHandler`

从代码结构看，它的目标是实现一个独立的原生解包器。

### 10.2 它目前缺什么

当前原型仍缺关键闭环：

1. 没有真正的 native 程序入口
2. 没有可直接运行的 MFC/WTL 主程序
3. 没有和当前 `gui-mvp` 打通

### 10.3 它与真实生产格式的主要偏差

这是本目录最需要被明确记录的部分：

1. 把 `.ljpi` 误当成“固定 28 字节/条”
   - 实际是变长结构
2. 包文件命名写死为 `pack%04u.ljfp`
   - 实际生产文件是 `1.ljfp`、`2.ljfp`
3. `packIndex == 0` 时返回空路径
   - 散文件无法正确读取
4. 解包阶段倾向于总是调用解压流程
   - 对未压缩文件可能不成立
5. 自己的 SMS4 实现与原始链路存在实现差异
6. 没有完整入口和测试闭环

### 10.4 这意味着什么

结论很直接：

1. 它是有研究价值的
2. 但它不是当前仓库里最可靠的主用解包实现
3. 实战上应该以 `dependencies/SuperLJFilePackUnpack` 为准

---

## 11. 依赖环境、构建方式与运行要求

### 11.1 原始生产打包链依赖

原始链路的技术栈主要是：

1. VS2013 / v120
2. Win32
3. zlib/miniz
4. SMS4 实现
5. `LJFilePackOption.xml`

运行时通常依赖 VC++ 2013 CRT。

### 11.2 当前 MVP GUI 依赖

当前 `gui-mvp` 工程要求：

1. `Microsoft.NET.Sdk`
2. `TargetFramework = net10.0-windows`
3. `UseWindowsForms = true`

构建方式：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\LJFilePackUnpacker\scripts\Build-MVP-OneClickUnpacker.ps1
```

该脚本会做三件事：

1. 先用 `msbuild` 构建 `dependencies/SuperLJFilePackUnpack` 的 native CLI
2. 再用 `dotnet build` 或 `dotnet publish` 构建 WinForms GUI
3. 最后把 `ljfp-unpack.exe` 复制进 `dist/mvp`

### 11.3 当前 GUI 运行要求

非自包含发布下，GUI 需要：

1. `.NET 10 Windows Desktop Runtime`
2. 同目录存在 `ljfp-unpack.exe`

当前 `dist/mvp` 还带有：

1. `msvcp120.dll`
2. `msvcr120.dll`

这说明分发包默认还考虑了 native CLI 的 VC++ 2013 CRT 依赖。

### 11.4 一个重要的分发风险

`dist/mvp` 中现成的 `ljfp-unpack.exe` 只是一个历史快照，不一定和当前 `dependencies/SuperLJFilePackUnpack` 源码一致。

因此：

1. 若要做准确分析，应该以当前依赖工程源码和当前构建产物为准
2. 若要重新交付工具，应该重新执行构建脚本，而不是直接信任旧 `dist` 快照

### 11.5 GUI 默认路径的运行时注意事项

GUI 默认填的是相对路径：

1. `client/resource/res1`
2. `tools/LJFilePackUnpacker/output`

而启动脚本只是 `start` 程序，并没有显式 `cd` 到仓库根目录。

这意味着：

1. 若当前工作目录不是仓库根目录，默认路径可能失效
2. 最稳妥的方式是手工浏览选择目录，或在仓库根目录下启动

---

## 12. 典型应用场景

### 12.1 平台资源打包

适用场景：

1. iOS 发布包
2. Android 发布包
3. Win 发布包

推荐入口：

1. `client/resource/tools/LJFilePack_打包苹果.bat`
2. `client/resource/tools/LJFilePack_打包安卓.bat`
3. `client/resource/tools/LJFilePack_打包win.bat`

输出物通常包括：

1. `N.ljfp`
2. 散文件
3. `fl.ljpi`
4. `fl.ljzip`
5. `ver.ljvi`

### 12.2 全量解包审计

适用场景：

1. 逆向检查资源内容
2. 验证包是否损坏
3. 抽取文件样本

推荐入口：

1. MVP GUI
2. `ljfp-unpack.exe`
3. 原始 `LJFilePack.exe unpack:...` 仅作为旧链路对照

### 12.3 目录结构恢复

适用场景：

1. 希望尽量恢复原始文件路径
2. 需要按脚本/UI/模型目录浏览资源

推荐做法：

1. 准备同版本参考资源目录
2. 先扫描生成路径映射
3. 再用 `--mapping`
4. 若需要高可信恢复，考虑 `--strict-restore`

### 12.4 版本与索引调试

适用场景：

1. 检查 `ver.ljvi`
2. 检查 `fl.ljpi/fl.ljzip`
3. 查某个路径的 CRC32

常用入口：

1. `verljvi2xml`
2. `verxml2ljvi`
3. `ljpi2xml`
4. `ljzip2xml`
5. `getstrcrc32`

### 12.5 差分更新包制作

适用场景：

1. 比较两个版本资源目录差异
2. 生成更新发布目录
3. 构建多版本升级链

常用入口：

1. `makeupdatepack:<base|new|out>`
2. `makeupdatepackall:<listfile>`

差分逻辑是：

1. 对比两个版本的 `fl.ljpi`
2. 识别新增/修改/删除文件
3. 复制新增/修改文件
4. 删除已删除文件
5. 带上新版本的 `ver.ljvi` 和 `fl.ljzip`

---

## 13. 故障排除与诊断建议

### 13.1 输入目录中找不到 `fl.ljpi/fl.ljzip`

现象：

1. GUI 启动后报参数错误
2. CLI 提示输入目录中未找到索引

排查：

1. 确认目录是否真的是资源根目录
2. 若索引文件不在默认位置，使用 `--index=...`
3. 确认不是只拿到了单个 `.ljfp` 文件而没拿索引

### 13.2 映射命中率很低

常见原因：

1. 参考目录版本不匹配
2. 大小写规则不一致
3. 斜杠规范不一致
4. 路径前缀不同

建议：

1. 重新从当前参考目录生成映射
2. 优先用同版本、同渠道资源目录
3. 不要把“补扩展名”误当成“恢复真实目录结构”

### 13.3 CRC32 校验失败

常见原因：

1. 索引和资源目录不配套
2. 解密模式不对
3. 密钥不对
4. 包内容本身损坏

建议：

1. 先切换 `--decrypt-mode=lj` 或 `--decrypt-mode=apk`
2. 必要时显式指定 `--decrypt-key`
3. 若只是先抽样浏览，可用 `--no-verify`
4. 但正式校验时不建议长期关闭 CRC

### 13.4 解包后仍有大量数字文件名

这不一定是失败，可能只是没有足够的路径信息。

分情况处理：

1. 仅剩少量数字文件：
   - 多半是缺映射或语义不足，属于正常边界
2. 大量数字文件：
   - 优先怀疑映射缺失或命中率过低
3. 根目录残留很多数字文件：
   - 看是否启用了 `--keep-root-residuals`
   - 默认可归档到 `review/unresolved`

### 13.5 GUI 能启动，但点击解包提示找不到 `ljfp-unpack.exe`

排查：

1. 先执行 `Build-MVP-OneClickUnpacker.ps1`
2. 确认 `dist/mvp` 同目录有 `ljfp-unpack.exe`
3. 若 `dist` 不完整，GUI 会尝试回退到 `dependencies/SuperLJFilePackUnpack/build/bin/Release`；但该目录属于本机构建输出，清理后可能不存在，不应当作仓库稳定交付物依赖

### 13.6 GUI 能启动，但默认路径无效

原因：

1. GUI 默认路径是相对路径
2. 启动脚本没有显式切仓库根目录

处理：

1. 手工浏览选择目录
2. 或在仓库根目录下启动 GUI

### 13.7 `nopause:0` 看起来写了，但工具仍 pause

原因：

1. 解析器只识别裸参数 `nopause`
2. `nopause:0` 不会关闭暂停

处理：

1. 改为 `nopause`
2. 或直接使用新版 bat 包装

### 13.8 为什么 `dist/mvp` 和当前源码描述不一致

原因：

1. `dist/mvp` 是快照，不是源码真相
2. 目录里可能保留了旧版 `ljfp-unpack.exe`

处理：

1. 以当前 `dependencies/SuperLJFilePackUnpack` 源码和帮助输出为准
2. 重新执行构建脚本生成新分发包

### 13.9 为什么不建议直接基于 `tools/LJFilePackUnpacker/src` 做生产修复

因为它当前至少有这些高风险点：

1. 索引格式假设不完整
2. 包命名规则不匹配生产实际
3. 散文件逻辑未闭环
4. 没有程序入口
5. 与当前 GUI 未联动

如果目标是“尽快可用”，应优先修 `SuperLJFilePackUnpack` 线，而不是把原型直接转正。

---

## 14. 当前状态判断与建议

### 14.1 当前最可信的事实基线

从仓库当前状态出发，最稳妥的判断是：

1. 打包主线：
   - `LJFilePack.exe`
   - `dependencies/LJFilePack`
2. 解包主线：
   - `SuperLJFilePackUnpack`
   - `ljfp-unpack.exe`
   - `gui-mvp`
3. `tools/LJFilePackUnpacker/inc+src`：
   - 是原型与研究产物，不是当前主执行后端

### 14.2 文档层面的一个重要事实

`tools/LJFilePackUnpacker/README.md` 同时混入了：

1. 早期“待实现模块”设计稿
2. 后来的 MVP GUI 说明

因此它不能被当作单一事实来源。做任何技术判断，都应回到：

1. 工程文件
2. 脚本
3. 代码
4. 帮助输出

### 14.3 后续使用建议

若只考虑可用性和维护成本，建议如下：

1. 需要打包：
   - 继续走 `LJFilePack.exe + LJFilePackOption.xml`
2. 需要解包：
   - 优先走 `ljfp-unpack.exe`
   - 有 GUI 需求时用 `gui-mvp`
3. 需要修格式兼容或恢复能力：
   - 优先修改 `dependencies/SuperLJFilePackUnpack`
4. 需要研究历史实现或验证逆向结论：
   - 再参考 `tools/LJFilePackUnpacker/src`

---

## 15. 本次分析的验证证据

本报告基于以下证据链整理：

1. 阅读 `tools/LJFilePackUnpacker` 目录结构、README、MVP GUI 源码、构建脚本、分发目录
2. 阅读 `dependencies/LJFilePack` 的参数解析、配置、打包、索引、加密和差分实现
3. 阅读 `dependencies/SuperLJFilePackUnpack` 的 CLI 入口、核心数据结构、解包实现和文档
4. 直接执行当前仓库内帮助命令，确认当前 CLI/原始工具帮助输出

本次核验过的代表性命令包括：

```powershell
cmd /c "dependencies\SuperLJFilePackUnpack\build\bin\Release\ljfp-unpack.exe --help"
cmd /c "client\resource\tools\LJFilePack.exe ?"
Get-Content -Raw -Encoding UTF8 tools\LJFilePackUnpacker\gui-mvp\README.md
Get-Content -Raw -Encoding UTF8 dependencies\SuperLJFilePackUnpack\README.md
```

---

## 16. 最终结论

`tools/LJFilePackUnpacker` 这个名字容易让人误以为“这里就是 MT3 当前的 LJ 打包/解包工具源码”，但仓库现实不是这样。

更准确的说法是：

1. MT3 的原始生产打包链仍然是 `LJFilePack.exe` 及其源码 `dependencies/LJFilePack`
2. `tools/LJFilePackUnpacker` 是后续补建的“解包专题目录”
3. 这个专题目录中真正可运行的产品形态，是 `gui-mvp` 包装 `SuperLJFilePackUnpack` 的 CLI
4. 目录里的自研 C++ 原型，目前更适合作为逆向研究材料，而不是主线执行引擎

如果后续要继续系统化治理这条工具链，建议的事实边界应固定为：

1. `LJFilePack.exe` 负责打包与增量
2. `ljfp-unpack.exe` 负责解包与恢复
3. `gui-mvp` 负责桌面操作壳层
4. 原型代码只作为研究与验证材料维护

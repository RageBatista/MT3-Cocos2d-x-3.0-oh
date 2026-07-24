# SuperLJFilePackUnpack 示例程序

## 1. 当前示例入口

本目录当前只保留一个主 CLI 示例：

- `UnpackExample.cpp`
  - 构建目标：`ljfp-unpack`

诊断 CLI 在 `tools/UnpackDiag.cpp`，构建目标是 `ljfp-unpack-diag`。

## 2. 构建

```powershell
Set-Location E:\MT3\dependencies\SuperLJFilePackUnpack
New-Item -ItemType Directory -Force build | Out-Null
Set-Location build
cmake .. -G "Visual Studio 12 2013" -DBUILD_EXAMPLES=ON
cmake --build . --config Release --target ljfp-unpack
cmake --build . --config Release --target ljfp-unpack-diag
```

输出：

- `build\bin\Release\ljfp-unpack.exe`
- `build\bin\Release\ljfp-unpack-diag.exe`

## 3. `ljfp-unpack` 当前能力

### 基本用法

```powershell
.\bin\Release\ljfp-unpack.exe <输入目录或索引文件> [输出目录]
```

### 当前实际支持的主要参数

- `--index=FILE`
- `--mapping=FILE`
- `--scan=DIR`
- `--no-source-template-seed`
- `--source-scan-root=DIR`
- `--source-map-config-bin=FILE`
- `--no-verify`
- `--overwrite`
- `--no-detect`
- `--strict-restore`
- `--keep-root-residuals`
- `--review-aliases`
- `--decrypt-mode=auto|lj|apk`
- `--decrypt-key=KEY`
- `--android-libgame=PATH`
- `--help`

### 典型示例

```powershell
.\bin\Release\ljfp-unpack.exe E:\sample\packed E:\sample\out --mapping=path_mapping.ljpm
.\bin\Release\ljfp-unpack.exe E:\sample\packed --decrypt-mode=lj
.\bin\Release\ljfp-unpack.exe --scan=E:\MT3\client\resource\res
```

### 当前输出策略

- 有映射时优先按路径输出
- 无映射时按 `CRC32 + 补扩展名` 输出
- 两阶段恢复下，可在后处理阶段把残留归到 `review/unresolved/`
- 正常解包模式下，CLI 现在会尽力自动执行一轮源码模板补种：
  - `source_template_seed_pipeline.py`
  - 目标是把“客户端源码模板 + 配置变量 + CRC 精确命中”先转成高置信 mapping
  - 失败不会阻断主解包流程

### 源码模板补种

这条链默认启用，可通过以下参数控制：

- `--no-source-template-seed`
  - 禁用自动源码模板补种
- `--source-scan-root=DIR`
  - 显式追加源码/配置语料根目录，可重复传入
- `--source-map-config-bin=FILE`
  - 显式追加 `map.cmapconfig.bin` 路径，可重复传入

## 4. `ljfp-unpack-diag`

### 基本用法

```powershell
.\bin\Release\ljfp-unpack-diag.exe <input_dir> <output_dir> [mapping_file] [decrypt_key] [thread_count] [stream_mode]
```

额外命名参数：

- `--android-libgame=<file|dir>`

### 主要用途

- 快速检查索引统计
- 输出 `CodeType / CompressType` 分布
- 查看首个失败样本的探针链
- 验证 Android key 自动提取结果

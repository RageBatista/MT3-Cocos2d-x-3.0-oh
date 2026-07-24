# 02 快速开始

> 基准日期: 2026-04-22
> 适用对象: 开发者、GUI 使用者、CLI 批处理用户

## 1. 前置条件

### Windows 主线

- Visual Studio 2013 / v120
- CMake 3.6+
- 可选 GUI 依赖：wxWidgets 3.0.5

### 额外工具

- Python 3
  - 在使用 `tools/manifest_seed_pipeline.py` 或
    `tools/source_template_seed_pipeline.py` 时需要

## 2. 从干净目录构建

`build/` 现在是本地生成目录，不再作为仓库内容保留。推荐从源码目录重新生成：

```powershell
Set-Location E:\MT3\dependencies\SuperLJFilePackUnpack
New-Item -ItemType Directory -Force build | Out-Null
Set-Location build
cmake .. -G "Visual Studio 12 2013"
cmake --build . --config Release
```

常用开关：

- `-DBUILD_TESTS=ON`
- `-DBUILD_EXAMPLES=ON`
- `-DBUILD_GUI=ON`

注意：

- `BUILD_CLI` 只是历史兼容开关，不会生成旧通用 CLI 主程序
- GUI 是否能构建，取决于本机 wxWidgets 是否可用

## 3. 当前目标矩阵

| 目标 | 说明 | 默认 |
|------|------|------|
| `SuperLJFilePackUnpack` | 静态库 | ON |
| `ljfp-test` | 单元测试 | ON |
| `ljfp-testgen` | 测试数据生成器 | 条件开启 |
| `ljfp-unpack` | 主 CLI 示例 | ON |
| `ljfp-unpack-diag` | 诊断 CLI | ON |
| `ljfp-gui` | wxWidgets GUI 目标 | ON（依赖满足时） |

补充：

- `ljfp-gui` 的实际输出文件名是 `LJFilePackUnpacker.exe`
- `BUILD_CLI` 是废弃兼容开关，不会生成旧主程序

## 4. 最小库集成示例

```cpp
#include "../include/SLJFP_Unpack.h"
#include "../include/SLJFP_LibsWrapper.h"

SLJFP::Unpacker unpacker(
    SLJFP_crc32,
    SLJFP_mz_compress2,
    SLJFP_mz_uncompress,
    SLJFP_SMS4Ex,
    SLJFP_DeSMS4Ex
);

int rc = unpacker.LoadIndex("E:/sample/fl.ljzip");
if (rc != SLJFP::LJFP_SUCCESS) {
    return rc;
}

SLJFP::UnpackOptions options;
options.threadCount = 4;
options.decryptMode = SLJFP::DecryptMode::Auto;
options.verifyCRC32 = true;
options.useStreamMode = false;

return unpacker.UnpackAll("E:/sample/res", "E:/sample/out", options);
```

### 4.1 已安装包消费示例

安装导出链验证通过后，其他 CMake 项目可直接：

```cmake
find_package(SuperLJFilePackUnpack CONFIG REQUIRED)

add_executable(my_unpack_tool main.cpp)
target_link_libraries(my_unpack_tool PRIVATE SuperLJFilePackUnpack::SuperLJFilePackUnpack)
```

头文件引用方式：

```cpp
#include <SuperLJFilePackUnpack/SLJFP_Unpack.h>
#include <SuperLJFilePackUnpack/SLJFP_LibsWrapper.h>
```

## 5. CLI 入口

### 5.1 `ljfp-unpack`

基本用法：

```powershell
.\bin\Release\ljfp-unpack.exe <输入目录或索引文件> [输出目录]
```

当前实际支持的主要参数：

- `--index=FILE`
- `--mapping=FILE`
- `--scan=DIR`
- `--no-verify`
- `--overwrite`
- `--no-detect`
- `--strict-restore`
- `--keep-root-residuals`
- `--review-aliases`
- `--decrypt-mode=auto|lj|apk`
- `--decrypt-key=KEY`
- `--android-libgame=PATH`

### 5.2 `ljfp-unpack-diag`

用于快速诊断索引、密钥和失败样本：

```powershell
.\bin\Release\ljfp-unpack-diag.exe <input_dir> <output_dir> [mapping_file] [decrypt_key] [thread_count] [stream_mode]
```

额外命名参数：

- `--android-libgame=<file|dir>`

## 6. 路径映射生成

### 6.1 通过 CLI

当前不再使用独立 `PathMappingGenerator.exe`。路径映射生成统一走：

```powershell
.\bin\Release\ljfp-unpack.exe --scan=E:\MT3\client\resource\res
```

输出：

- `path_mapping.ljpm`
- `path_mapping.txt`

补充：

- `ljfp-unpack` 在正常解包模式下，若检测到可用脚本、源码/配置根目录和目标 CRC 集，还会尽力执行：
  - `tools/source_template_seed_pipeline.py`
- 这条链会把“客户端源码模板 + 配置变量 + CRC 精确命中”先转成高置信 mapping，再进入正式解包

### 6.2 通过 GUI

GUI 的“生成/合并路径映射”支持：

- 连续选择多个参考资源目录
- 合并扫描结果
- 立即加载生成后的映射

### 6.3 通过 API

```cpp
SLJFP::PathMappingGenerator generator;
generator.SetCRC32Function(PathMappingCRC32Adapter);
generator.ScanDirectory("E:/MT3/client/resource/res");
generator.SaveMappingBinary("path_mapping.ljpm");
```

## 7. GUI 快速使用

GUI 当前建议流程：

1. 打开索引文件或资源目录
2. 让 GUI 尝试自动加载映射
3. 命中率不足时，执行“生成/合并路径映射”
4. 设置输出目录
5. 选择预设
6. 启动解包
7. 在结果审阅页定位失败项、导出失败清单或问题组复跑

当前三个预设只会修改 GUI 显式暴露的控件项：

### 标准闭环

- `verifyCRC32 = true`
- `overwriteExisting = false`
- `organizeByType = true`
- `useStreamMode = false`
- `streamChunkMB = 4`
- `threadCount = 4`
- 其余高级恢复开关保持 `UnpackOptions` 默认值

### 快速审阅

- `verifyCRC32 = false`
- `overwriteExisting = false`
- `organizeByType = false`
- `useStreamMode = false`
- `threadCount = 2`
- 其余高级恢复开关保持 `UnpackOptions` 默认值

### 长任务/大文件

- `verifyCRC32 = true`
- `overwriteExisting = false`
- `organizeByType = true`
- `useStreamMode = true`
- `streamChunkMB = 8`
- `threadCount = 6`
- 其余高级恢复开关保持 `UnpackOptions` 默认值

## 8. 当前输出行为

### CLI `ljfp-unpack`

CLI 会固定走两阶段恢复：

- 第一阶段先按 CRC 落地
- 第二阶段再尝试恢复目录结构
- 无法恢复的根目录数字残留可归档到 `review/unresolved/`

### GUI

GUI 默认优先按映射路径直接输出；未显式暴露的高级恢复开关仍保持默认值，不会自动切到 CLI 那条固定两阶段主链。

### 无映射

默认输出为：

```text
<outputDir>/<crc32>[.detected-ext]
```

如果启用了两阶段恢复：

- 第一阶段先按 CRC 落地
- 第二阶段再恢复目录结构
- 无法恢复的残留文件可归档到 `review/unresolved/`

## 9. 常见误区

### “开了流式一定会走流式”

不是。以下情况会回退普通路径：

- `decryptMode=Auto`
- 加密块不满足 16 字节对齐
- 压缩流初始化或 inflate 异常
- 输出尺寸与 `m_SizeOriginal` 不一致

### “没有独立 PathMappingGenerator.exe 就不能生成映射”

不是。当前生成入口已经统一收敛到 `ljfp-unpack --scan`、GUI 和 API。

### “GUI 可以配置所有高级恢复开关”

不是。GUI 暴露的是常用配置，高级恢复开关主要仍在 CLI 和默认值层面生效。

# BinLayoutStudio v120 构建

> 适用对象：`dependencies/BinLayoutConvert/BinLayoutStudio/BinLayoutStudio.vcxproj`。
> 当前结论：`BinLayoutStudio` 必须直接构建 `.vcxproj`，不要从 `BinLayoutConvert.sln` 入口构建；该 solution 当前不包含 `BinLayoutStudio` 工程。
> 文档索引：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)。

## 1. 工具链约束

- 编译器：Visual Studio 2013 / MSVC v120。
- 平台：`Win32`。
- Debug 运行库：`/MDd`，Release 运行库：`/MD`。
- 工具依赖：BinLayoutStudio 保持其已验证的 2.2.6/CEGUI 兼容资产；该工具不属于 Win32 游戏 `Upgrade30` 主链。
- Spine 依赖：按工具工程当前 `libExtensions.lib` 输入校验；不得把旧 `libSpine.lib` 混入。
- wxWidgets：使用 `dependencies/wxWidgets-3.0.5/lib/vc_lib` 下的静态库；需要完整第三方调试符号时重建 wxWidgets PDB。

## 2. 一键构建入口

项目提供本地构建脚本：

```powershell
Set-Location E:\MT3
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-BinLayoutStudio-v120.ps1 -Configuration Release -Target Rebuild
```

严格 Release 构建：

```powershell
Set-Location E:\MT3
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-BinLayoutStudio-v120.ps1 -Configuration Release -Target Rebuild -FailOnWarnings
```

首次补齐 wxWidgets 第三方 PDB：

```powershell
Set-Location E:\MT3
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-BinLayoutStudio-v120.ps1 -Configuration Release -Target Rebuild -RebuildWxPdb
```

Debug 构建：

```powershell
Set-Location E:\MT3
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-BinLayoutStudio-v120.ps1 -Configuration Debug -Target Rebuild
```

脚本会执行以下门禁：

- 校验 MSBuild 12.x 与 VS2013 `vcvarsall.bat`。
- 阻断 `cocos2d-2.0-rc2-x-2.0.1` 与 `libSpine.lib` 回流。
- 校验 `cocos2d-x-2.2.6`、`libExtensions.lib` 与 `/MD` 版本 `jpeg/png` 库优先级。
- 解析 MSBuild 日志，遇到编译/链接错误或 `LNK4098` 直接失败。
- 可选 `-FailOnWarnings` 将所有警告提升为失败。

## 3. 依赖与链接顺序

Release 链接路径中，`dependencies/jpeg/prebuilt/win32` 与 `dependencies/png/prebuilt/win32` 必须排在 `cocos2d-x-2.2.6/Release.win32` 前面。原因是 `cocos2d-x-2.2.6/Release.win32` 下的 `libjpeg.lib`、`libpng.lib` 带 `/MT` 默认库指令，会触发 `LNK4098`；`dependencies/*/prebuilt/win32` 下的版本与工具工程 `/MD` 一致。

关键库关系：

- `wxmsw30u_core.lib`、`wxbase30u.lib` 等 wxWidgets 静态库提供 GUI。
- `libcocos2d.lib`、`libCocosDenshion.lib`、`libExtensions.lib` 来自 `cocos2d-x-2.2.6`。
- `cegui.lib` 来自 `dependencies/cegui/project/win32/Release.win32`，用于底层 BinLayout XML/BIN 转换链。
- `engine.lib`、`FireClient.lib`、`platform.lib`、`ljfm.lib`、`cauthc.lib` 为 MT3 一方工具运行时依赖。

## 4. Release 优化策略

当前 Release 配置：

- 编译：`/O2`、`FavorSizeOrSpeed=Speed`、`/Gy`、`/Oi`、字符串池、SSE2、`/GL`。
- 链接：`/LTCG`、`/OPT:REF`、`/OPT:ICF`、生成 PDB。
- 运行库：`/MD`，与 wxWidgets、png/jpeg 预构建库保持一致。

PGO 不作为默认 Release 配置。若需要启用 PGO，应新增独立配置或独立属性表，流程如下：

1. 使用 `/GL` 与链接器 `/LTCG:PGINSTRUMENT /PGD:<path>` 生成插桩版。
2. 用真实样本运行 `--bin2xml`、`--xml2bin` 与批量转换路径，生成 `.pgc`。
3. 使用 `/LTCG:PGOPTIMIZE /PGD:<path>` 生成优化版。
4. 与普通 Release 做体积、启动、转换耗时和输出一致性对比后再发布。

## 5. 输出产物

构建产物：

- `dependencies/BinLayoutConvert/BinLayoutStudio/Release/BinLayoutStudio.exe`
- `dependencies/BinLayoutConvert/BinLayoutStudio/Release/BinLayoutStudio.pdb`

PostBuild 同步产物：

- `client/resource/bin/Release/BinLayoutStudio.exe`

`BinLayoutStudio.exe` 是 Windows 子系统程序。在 PowerShell 中做 CLI 验证时建议使用 `Start-Process -Wait`。

## 6. CI/CD 草案

Windows 构建节点要求：

- VS2013/v120 + Windows SDK 8.1。
- Git LFS 已拉取二进制依赖。
- 工作目录固定到仓库根。

示例流程：

```powershell
Set-Location E:\MT3
git lfs checkout
powershell -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\windows-v120-build\scripts\verify-build-env.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-BinLayoutStudio-v120.ps1 -Configuration Release -Target Rebuild -FailOnWarnings
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-BinLayoutStudio-v120.ps1 -Configuration Debug -Target Rebuild
```

首次铺设新构建机时，先运行一次：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-BinLayoutStudio-v120.ps1 -Configuration Release -Target Rebuild -RebuildWxPdb
```

推荐归档：

- `build_logs/BinLayoutStudio.Release.msbuild.log`
- `dependencies/BinLayoutConvert/BinLayoutStudio/Release/BinLayoutStudio.exe`
- `dependencies/BinLayoutConvert/BinLayoutStudio/Release/BinLayoutStudio.pdb`
- `client/resource/bin/Release/BinLayoutStudio.exe`

## 7. 常见故障

- `LNK1181: libSpine.lib`：旧 `cocos2d-2.0` 依赖回流；应使用 `libExtensions.lib`。
- `LNK4098`：CRT 混用；检查 `/MD` 与 png/jpeg 搜索优先级。
- `LNK4099`：wxWidgets 静态库缺 PDB；运行 `-RebuildWxPdb` 后再构建。
- `C4996 GetVersionExW`：wxWidgets 3.0.5 源码在 Windows SDK 8.1 下的历史 API 提示；默认不影响主工具产物，严格 wx 第三方构建可在独立 wx 属性表中治理。

架构边界、批量转换和后续优化路线见 [BinLayoutStudio 优化方案](../08-技术研究/13-BinLayoutStudio优化方案.md)。

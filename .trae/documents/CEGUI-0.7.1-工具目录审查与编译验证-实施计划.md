# CEGUI-0.7.1 工具目录编译阻断审查计划

> 状态: 已执行并回写事实基线
> 日期: 2026-06-30
> 范围: `tools\CEGUI-0.7.1` 的目录盘点、`test_corona.vcxproj` Debug/Release 编译、产物与运行门禁验证
> 原则: 先修正编译阻断根因，再谈 Debug/Release 试运行；二进制只校验不手工修改

## 1. 当前结论

本计划已经按 v120/Win32 执行。C1083 不再是当前阻断点；它的真实根因是 `test_corona.cpp` 和 `test_corona.vcxproj` 同时指向不存在的本地 include 树。修正 include 后又暴露 C2259，真实根因是 `CoronaImageCodec` 旧头文件未覆盖 `ImageCodec::load(const RawDataContainer&, Texture*, bool)` 纯虚函数。同步头/源签名后，Debug 与 Release 均已编译通过。

运行验证没有通过：`test_corona.exe` 在严格使用 `tools\CEGUI-0.7.1\bin` 作为 DLL 目录时退出 `-1073741515 (0xC0000135)`，属于进程加载阶段缺 DLL。`dumpbin /DEPENDENTS` 证实 Debug 依赖 `CEGUIBase_d.dll`，Release 依赖 `CEGUIBase.dll`，而 `tools\CEGUI-0.7.1\bin` 下没有这两个 DLL。此前把 `CEGUIBase_d.lib` / `CEGUIBase.lib` 判断为静态库是错误的；`dumpbin /LINKERMEMBER:1` 显示它们含 `__IMPORT_DESCRIPTOR_CEGUIBase(_d)` 与 `__imp_` 符号，实际为导入库。

## 2. 硬边界

- 不手工修改 `.lib`、`.dll`、`.exe`、`.obj`、`.tlog` 等二进制产物。
- 编译入口固定为 `tools\CEGUI-0.7.1\test_corona.vcxproj`，`PlatformToolset=v120`，`Platform=Win32`。
- 文本改动保持原编码：`test_corona.cpp` 保持 UTF-8 BOM；`test_corona.vcxproj`、Markdown 与日志摘要保持 UTF-8 no BOM。
- 运行门禁必须在 Debug/Release 编译退出码均为 0 且 exe 存在后执行。
- 不把其他 CEGUI 工具目录里的 DLL 混入本目录完整性结论；可作为后续运行解阻候选，但不能证明 `tools\CEGUI-0.7.1\bin` 自身完整。

## 3. 已核实事实基线

| 事实项 | 当前结果 | 证据 |
|---|---|---|
| 目录性质 | 预编译 CEGUI 0.7.1 vendor 目录 + 单个 `test_corona` 测试工程 | `inventory_by_extension.csv` |
| 目录清单 | 1183 个文件，含 790 `.obj`、172 `.tlog`、43 `.lib`、22 `.dll`、3 `.exe` | `build_logs\inventory_by_extension.csv` |
| 二进制指纹 | 40 个关键二进制 SHA256 已记录 | `build_logs\binary_hashes.csv` |
| 漏采命令修正 | 不再使用 `Get-ChildItem <dir> -Include *.dll,*.exe -File` 直接取 `bin`；已改为先枚举 `bin` 文件再按扩展名过滤 | `binary_hashes.csv`、`artifact_baseline.csv` |
| C1083 根因 | include 写法与 vcxproj IncludePath 指向不存在的 `cegui\include` / `dependencies\include` | 旧错误日志 + `Test-Path` |
| C1083 修正 | include 改为 `ImageCodecModules/...`，IncludePath 指向 `..\..\dependencies\cegui\CEGUI\include` | `test_corona.cpp`、`test_corona.vcxproj` |
| C2259 根因 | `CoronaImageCodec` 旧签名缺少 `bool bSyn`，未覆盖基类纯虚函数 | `CEGUIImageCodec.h:107` 与旧头文件对比 |
| C2259 修正 | `CEGUICoronaImageCodec.h/.cpp` 同步为 `load(..., bool bSyn=true)`，实现传入 `loadFromMemory(..., bSyn)` | 源文件回读 |
| CEGUIBase lib 性质 | `CEGUIBase_d.lib` / `CEGUIBase.lib` 是导入库，不是静态库 | `dumpbin /LINKERMEMBER:1` |
| Debug 编译 | 成功，退出码 0，错误 0，警告 1 | `test_corona_Debug.exit.txt`、`*_warnings.log` |
| Release 编译 | 成功，退出码 0，错误 0，警告 0 | `test_corona_Release.exit.txt` |
| 试运行 | Debug/Release 均退出 `-1073741515 (0xC0000135)` | `run_summary.txt` |
| 运行阻断 | 本目录 `bin` 缺 `CEGUIBase_d.dll` / `CEGUIBase.dll`；Debug 还依赖 Debug CRT | `dumpbin /DEPENDENTS` |
| FireClient 调用 | `client` 下 `Corona/ImageCodec/setImageCodec/CEGUI_DEFAULT_IMAGE_CODEC` 检索 0 命中 | `rg` |

## 4. 编译环境与参数

| 项 | 值 |
|---|---|
| MSBuild | `C:\Program Files (x86)\MSBuild\12.0\bin\MSBuild.exe` |
| Visual C++ 目标 | v120 / VS2013 |
| 平台 | Win32 |
| 配置 | Debug、Release |
| 运行时 | Debug=`MultiThreadedDebugDLL`，Release=`MultiThreadedDLL` |
| IncludePath | `$(ProjectDir)..\..\dependencies\cegui\CEGUI\include;$(ProjectDir)..\..\common\platform;$(IncludePath)` |
| LibraryPath | `$(ProjectDir)lib;$(ProjectDir)dependencies\lib\dynamic;$(LibraryPath)` |
| Debug 链接 | `CEGUIBase_d.lib;CEGUICoronaImageCodec_d.lib` |
| Release 链接 | `CEGUIBase.lib;CEGUICoronaImageCodec.lib` |
| 日志目录 | `tools\CEGUI-0.7.1\build_logs` |

`dumpbin.exe` 不应在文档中写死 C 盘路径；本机可通过 `Get-Command dumpbin.exe` 定位到 `D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\dumpbin.exe`。后续复查请优先使用 `Get-Command dumpbin.exe`。

## 5. 执行步骤

### A. 目录盘点与二进制基线

1. 枚举 `tools\CEGUI-0.7.1` 全目录文件，输出 `build_logs\inventory_by_extension.csv`。
2. 对 `lib\*.lib`、`bin\*.dll`、`bin\*.exe`、`dependencies\lib\dynamic\corona*.lib` 计算 SHA256，输出 `build_logs\binary_hashes.csv`。
3. 对关键输入/输出产物生成 `artifact_baseline.csv` 与 `artifact_verification.csv`。
4. 使用 `dumpbin /LINKERMEMBER:1` 判断 `.lib` 性质，不能仅靠前 64KB 字符串扫描定性。

### B. C1083 阻断修正

修改点：

| 文件 | 修正前 | 修正后 |
|---|---|---|
| `test_corona.cpp` | `#include "cegui/include/ImageCodecModules/CoronaImageCodec/CEGUICoronaImageCodec.h"` | `#include "ImageCodecModules/CoronaImageCodec/CEGUICoronaImageCodec.h"` |
| `test_corona.vcxproj` | `$(ProjectDir)cegui\include;$(ProjectDir)dependencies\include;...` | `$(ProjectDir)..\..\dependencies\cegui\CEGUI\include;$(ProjectDir)..\..\common\platform;...` |

门禁：

```powershell
$toolRoot = 'e:\MT3\tools\CEGUI-0.7.1'
Test-Path "$toolRoot\..\..\dependencies\cegui\CEGUI\include\ImageCodecModules\CoronaImageCodec\CEGUICoronaImageCodec.h"
Test-Path "$toolRoot\..\..\dependencies\cegui\CEGUI\include\Nuclear.h"
Test-Path "$toolRoot\..\..\common\platform"
Select-String -Path "$toolRoot\test_corona.cpp" -Pattern 'ImageCodecModules/CoronaImageCodec/CEGUICoronaImageCodec.h'
Select-String -Path "$toolRoot\test_corona.vcxproj" -Pattern 'dependencies\\cegui\\CEGUI\\include'
```

### C. C2259 阻断修正

C1083 解除后，Debug 首次 Rebuild 暴露：

```text
test_corona.cpp(16): error C2259: “CEGUI::CoronaImageCodec”: 不能实例化抽象类
```

根因：`CEGUIImageCodec.h` 中基类纯虚函数为 `Texture* load(const RawDataContainer& data, Texture* result, bool bSyn=true) = 0;`，而 `CoronaImageCodec` 旧头文件只声明两个参数版本。现有预编译导入库/DLL 导出的符号也包含 `_N`（bool）参数，因此应同步头/源，而不是改二进制。

修改点：

| 文件 | 修正 |
|---|---|
| `dependencies\cegui\CEGUI\include\ImageCodecModules\CoronaImageCodec\CEGUICoronaImageCodec.h` | `Texture* load(const RawDataContainer& data, Texture* result, bool bSyn=true);` |
| `dependencies\cegui\CEGUI\src\ImageCodecModules\CoronaImageCodec\CEGUICoronaImageCodec.cpp` | 实现签名增加 `bool bSyn`，`result->loadFromMemory(..., bSyn);` |

### D. Debug/Release Rebuild

构建命令：

```powershell
$logDir = 'e:\MT3\tools\CEGUI-0.7.1\build_logs'
$msbuild = 'C:\Program Files (x86)\MSBuild\12.0\bin\MSBuild.exe'
$proj = 'e:\MT3\tools\CEGUI-0.7.1\test_corona.vcxproj'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

& $msbuild $proj /t:Rebuild /p:Configuration=Debug /p:Platform=Win32 /verbosity:diagnostic `
  /flp1:"logfile=$logDir\test_corona_Debug.log;verbosity=diagnostic;Encoding=UTF-8" `
  /flp2:"logfile=$logDir\test_corona_Debug_errors.log;errorsonly;Encoding=UTF-8" `
  /flp3:"logfile=$logDir\test_corona_Debug_warnings.log;warningsonly;Encoding=UTF-8"
"DebugExit=$LASTEXITCODE" | Set-Content -Encoding UTF8 "$logDir\test_corona_Debug.exit.txt"

& $msbuild $proj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /verbosity:diagnostic `
  /flp1:"logfile=$logDir\test_corona_Release.log;verbosity=diagnostic;Encoding=UTF-8" `
  /flp2:"logfile=$logDir\test_corona_Release_errors.log;errorsonly;Encoding=UTF-8" `
  /flp3:"logfile=$logDir\test_corona_Release_warnings.log;warningsonly;Encoding=UTF-8"
"ReleaseExit=$LASTEXITCODE" | Set-Content -Encoding UTF8 "$logDir\test_corona_Release.exit.txt"
```

执行结果：

| 配置 | 退出码 | 错误 | 警告 | exe |
|---|---:|---:|---:|---|
| Debug | 0 | 0 | 1 (`C4996 sprintf`) | `Debug\test_corona.exe` |
| Release | 0 | 0 | 0 | `Release\test_corona.exe` |

### E. 产物完整性与运行门禁

产物校验输出：`build_logs\artifact_verification.csv`。当前 exe 与 PDB 均存在：

| 产物 | 状态 |
|---|---|
| `Debug\test_corona.exe` | 存在，SHA256 已记录 |
| `Debug\test_corona.pdb` | 存在，SHA256 已记录 |
| `Release\test_corona.exe` | 存在，SHA256 已记录 |
| `Release\test_corona.pdb` | 存在，SHA256 已记录 |

运行门禁命令严格使用本目录 `bin`：

```powershell
$oldPath = $env:PATH
try {
  $env:PATH = 'e:\MT3\tools\CEGUI-0.7.1\bin;' + $env:PATH
  & 'e:\MT3\tools\CEGUI-0.7.1\Debug\test_corona.exe'
  $debugRunExit = $LASTEXITCODE
  & 'e:\MT3\tools\CEGUI-0.7.1\Release\test_corona.exe'
  $releaseRunExit = $LASTEXITCODE
} finally {
  $env:PATH = $oldPath
}
```

结果：

| 配置 | 运行退出码 | 判定 |
|---|---:|---|
| Debug | `-1073741515` (`0xC0000135`) | 运行阻断，加载阶段缺 DLL |
| Release | `-1073741515` (`0xC0000135`) | 运行阻断，加载阶段缺 DLL |

依赖核验：

```powershell
$dumpbin = (Get-Command dumpbin.exe).Source
& $dumpbin /DEPENDENTS 'e:\MT3\tools\CEGUI-0.7.1\Debug\test_corona.exe'
& $dumpbin /DEPENDENTS 'e:\MT3\tools\CEGUI-0.7.1\Release\test_corona.exe'
```

Debug 依赖 `CEGUIBase_d.dll`、`CEGUICoronaImageCodec_d.dll`、`MSVCP120D.dll`、`MSVCR120D.dll`、`KERNEL32.dll`。Release 依赖 `CEGUIBase.dll`、`CEGUICoronaImageCodec.dll`、`MSVCP120.dll`、`MSVCR120.dll`、`KERNEL32.dll`。本目录 `bin` 有 `CEGUICoronaImageCodec*.dll` 和 Release CRT，但缺 `CEGUIBase_d.dll` / `CEGUIBase.dll`；Debug CRT 也不是本目录随附产物。

## 6. 需求符合性评估

| 项 | 结果 |
|---|---|
| FireClient 是否调用 Corona/ImageCodec | `client` 下 `.cpp/.h/.lua` 检索 0 命中 |
| 默认 image codec | `dependencies\cegui\CEGUI\include\config.h:8` 覆盖为 `CEGUI_CODEC_cocos2d` |
| test_corona 与客户端关系 | 独立 vendor 副本链接性测试，与 FireClient 当前运行路径无直接需求关系 |
| 构造函数 public 结论 | 只能说明可访问；旧文档把它直接等同“可实例化”不完整，因类仍可能因纯虚函数未覆盖而抽象 |

## 7. 必须纠正的旧结论

| 旧说法 | 纠正后 |
|---|---|
| 旧版本对 `CEGUIBase*.lib` 的性质判断相反，并把缺 DLL 当成正常现象 | 错。`CEGUIBase_d.lib` / `CEGUIBase.lib` 是导入库；`bin` 下缺 DLL 正是运行阻断根因 |
| 修 include 后即可直接运行验证 | 不完整。C1083 解除后先暴露 C2259，需修正 `CoronaImageCodec::load(..., bool)` 覆盖纯虚函数 |
| 构造函数 public，所以 `new CoronaImageCodec()` 合法 | 不完整。public 只是访问条件；旧头文件未覆盖纯虚函数时该类仍是抽象类，不能实例化 |
| 旧版本把 C1083 当作最终阻断，并写成尚未复测 | 已过期。C1083/C2259 均已修正，Debug/Release 编译退出码均为 0 |
| 试运行输出应生成 `run_Debug.out` / `run_Release.out` | 当前加载器失败发生在程序输出前，没有生成 stdout 文件；以 `run_summary.txt` 记录退出码 |

## 8. 输出物

| 输出物 | 路径 |
|---|---|
| 目录清单 | `tools\CEGUI-0.7.1\build_logs\inventory_by_extension.csv` |
| 二进制 SHA256 | `tools\CEGUI-0.7.1\build_logs\binary_hashes.csv` |
| 预检记录 | `tools\CEGUI-0.7.1\build_logs\preflight_checks.txt` |
| Debug 完整日志 | `tools\CEGUI-0.7.1\build_logs\test_corona_Debug.log` |
| Debug 错误/警告 | `test_corona_Debug_errors.log` / `test_corona_Debug_warnings.log` |
| Release 完整日志 | `tools\CEGUI-0.7.1\build_logs\test_corona_Release.log` |
| Release 错误/警告 | `test_corona_Release_errors.log` / `test_corona_Release_warnings.log` |
| 产物校验 | `tools\CEGUI-0.7.1\build_logs\artifact_verification.csv` |
| 试运行摘要 | `tools\CEGUI-0.7.1\build_logs\run_summary.txt` |
| 依赖清单 | `tools\CEGUI-0.7.1\build_logs\dependents_Debug.txt` / `dependents_Release.txt` |
| 导入库性质证据 | `tools\CEGUI-0.7.1\build_logs\importlib_CEGUIBase.txt` |
| 运行依赖存在性 | `tools\CEGUI-0.7.1\build_logs\runtime_dependency_check.txt` |
| 构建摘要 | `tools\CEGUI-0.7.1\build_logs\build_summary.txt` |
| 审查报告 | `docs\audit\CEGUI-0.7.1-工具目录审查与编译验证报告-2026-06-30.md` |

## 9. 后续解阻建议

若后续目标是让 `test_corona.exe` 运行通过，需要先决定是否把同版本 `CEGUIBase_d.dll` / `CEGUIBase.dll` 纳入 `tools\CEGUI-0.7.1\bin` 的发布布局，或在运行脚本中显式加入可信 CEGUIBase DLL 目录。该动作属于运行时依赖补齐，不属于本次“编译阻断审查计划”的二进制手工修改范围。

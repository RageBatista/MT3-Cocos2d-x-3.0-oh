# 03-Windows 构建前检查清单

> 在仓库根目录执行。目标是构建前一次性发现工具链、编码、ABI、LFS、产物和运行目录问题。

## 1. 工作树与范围

- [ ] 已阅读根 `AGENTS.md`、当前目录规则、`.claude/RULES.md` 与 `.claude/BUILD_GUIDE.md`；
- [ ] 已确认本轮改动属于平台壳层、Cocos、Nuclear、FireClient、资源或第三方依赖；
- [ ] 已检查工作树，未混入无关修改：

```powershell
git status --short
git diff --check
```

## 2. 工具链

- [ ] VS2013 C++ 工具链可用；
- [ ] `PlatformToolset` 为 `v120`；
- [ ] Windows SDK 8.1 可用；
- [ ] MSBuild 主版本为 12；
- [ ] 目标平台为 Win32。

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\windows-v120-build\scripts\verify-build-env.ps1 -Json
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1
```

## 3. 固定入口与当前主线

- [ ] 外部入口是 `tools/scripts/Build-MT3-Exe-Canonical.ps1`；
- [ ] `client/Build-MT3-v120.ps1` 只作为内部链路；
- [ ] 当前 Cocos 路径是 `cocos2d-x-2.2.6/`；
- [ ] 未把 `cocos2d-2.0-rc2-x-2.0.1/` 作为当前构建输入。

```powershell
@(
    '.\tools\scripts\Build-MT3-Exe-Canonical.ps1',
    '.\client\Build-MT3-v120.ps1',
    '.\cocos2d-x-2.2.6',
    '.\client\MT3Win32App\FireClient.win32.vcxproj',
    '.\client\MT3Win32App\mt3.win32.vcxproj'
) | ForEach-Object { Get-Item -LiteralPath $_ }
```

## 4. 编码与源码完整性

- [ ] 修改前已确认原文件编码、BOM 与换行；
- [ ] 含中文的 VS2013 C/C++ 源文件保留 UTF-8 BOM；
- [ ] `.rc` 文件保持原编码；
- [ ] 未批量转码或格式化 vendor/历史工程；
- [ ] 核心源码不含 NUL 字节。

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Test-SourceNoNulBytes.ps1 -RepoRoot . -IncludeRoots 'client/FireClient/Application,client/MT3Win32App,engine,common,tools/scripts'
```

VS2013 在中文字符串附近报告 `C2001: 常量中有换行符` 时，先检查 BOM，不先改字符串内容。

## 5. ABI 风险

- [ ] 已检查 `engine/**.h` 和 `client/FireClient/Application/**.h` 是否变化；
- [ ] 已识别类成员、继承、虚函数、模板、内联实现、对象大小/偏移和宏布局变化；
- [ ] `engine` ABI 变化计划执行 `Rebuild engine -> Rebuild FireClient -> Build MT3`；
- [ ] `FireClient` ABI 变化计划执行 `Rebuild FireClient -> Build MT3`；
- [ ] 怀疑混编时已停止普通增量构建。

```powershell
git diff --name-only -- 'engine/*.h' 'engine/**/*.h' 'client/FireClient/Application/*.h' 'client/FireClient/Application/**/*.h'
```

## 6. Git LFS 与链接输入

- [ ] `git lfs status` 无意外 pointer 状态；
- [ ] `client/res_win/res` 和运行目录中的关键 DLL/LIB/EXE/PDB 已签出；
- [ ] 第三方链接输入由现有脚本校验，不手工复制来源不明二进制。

```powershell
git lfs status
rg -a -n 'version https://git-lfs.github.com/spec/v1' client/res_win/res client/resource/bin
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Ensure-MT3-Win32-LinkDeps.ps1 -Configuration Release -Platform Win32 -Json
```

`rg` 无输出才表示扫描范围内未发现 LFS pointer 文本。

## 7. 模式选择

- [ ] 日常 Debug：`-FastLocal`；
- [ ] 日常 Release：`-BuildMode Incremental`；
- [ ] ABI 敏感改动、工具链漂移或发版：`-BuildMode SafeChain`；
- [ ] 里程碑：`Build-MT3-FullValidation.ps1 -Configuration Both`；
- [ ] 日常构建未无故添加 `-Clean`。

## 8. 产物与运行目录

- [ ] 已记录构建前 `engine.lib`、`FireClient.lib`、`MT3.exe` 时间戳；
- [ ] 已确认目标运行目录是 `client/resource/bin/<Configuration>/`；
- [ ] 已确认 Launcher 不在本次 canonical build 范围；
- [ ] 已准备在运行目录启动，而不是从仓库根目录直接运行。

```powershell
Get-Item .\client\MT3Win32App\Release.win32\engine.lib -ErrorAction SilentlyContinue
Get-Item .\client\MT3Win32App\Release.win32\FireClient.lib -ErrorAction SilentlyContinue
Get-Item .\client\resource\bin\Release\MT3.exe -ErrorAction SilentlyContinue
```

## 9. 构建后门禁

- [ ] 构建进程退出码为 `0`；
- [ ] 对应配置的 `MT3.exe` 存在且时间戳已刷新；
- [ ] runtime audit 满足本轮严格度；
- [ ] 从运行目录启动并完成最小冒烟验证；
- [ ] 构建失败时记录首个错误、日志路径和直接阻塞点。

命令入口见 [Windows 构建命令速查](./04-Windows构建命令速查.md)，完整边界见 [Windows 完整构建指南](./02-Windows完整构建指南.md)。

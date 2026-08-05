# 02-Windows 完整构建指南

> **适用范围**：MT3 Win32 客户端 `Debug|Win32` 与 `Release|Win32`
> **外部固定入口**：`tools/scripts/Build-MT3-Exe-Canonical.ps1`
> **内部构建链**：`client/Build-MT3-v120.ps1`
> **默认引擎配置**：`Upgrade30`（`cocos2d-x-3.0-oh + CEGUI-0.7.9-r5`）

## 1. 构建原则

1. 固定使用 VS2013、`v120`、Windows SDK 8.1、MSBuild 12.0；
2. 人工、Agent 和 CI 手工触发统一调用 canonical wrapper；
3. `client/Build-MT3-v120.ps1` 只作为 wrapper 的内部 ABI 安全链；
4. 日常迭代优先增量，ABI 敏感改动和发版验收使用 `SafeChain`；
5. 构建成功、运行时依赖完整和实际启动是三个不同门禁。

## 2. 构建前检查

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1 -EngineProfile Upgrade30
git lfs status
git status --short
```

`Check-v120Toolset.ps1` 与内部构建链共同读取 `tools/scripts/build-config.psm1`。默认 Upgrade30 清单覆盖 Cocos 3.0-oh 的 21 个 CMake 工程、CEGUI 0.7.9-r5、三个公共/业务工程、engine、FireClient 和最终 MT3，共 28 个检查对象。

canonical wrapper 在正式构建前还会：

1. 扫描核心源码是否含 NUL 字节；
2. 执行 v120 主线预检（`FastLocal` 默认跳过）；
3. 校验 `EngineProfile` 与 Cocos/CEGUI 工程路径完全一致；
4. 调用 `Ensure-MT3-Win32-LinkDeps.ps1` 补齐/校验链接输入；
5. 检查关键资源和运行时文件是否仍是 Git LFS pointer；
6. 收敛 `ProgramFiles(x86)`、`VS120COMNTOOLS` 与 `MT3_MSBUILD_PATH`；
7. 调用内部构建链并检查 `MT3.exe` 是否实际生成。

## 3. 构建模式

### 3.1 Debug 日常开发

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -EngineProfile Upgrade30 -FastLocal -MaxParallelJobs 8
```

`-FastLocal` 会把默认 `SafeChain` 收敛为 `Incremental`，并默认跳过工具链预检和 runtime audit。首次配置环境、工具链变更后或准备交付时不要只依赖该模式。

### 3.2 Release 日常验证

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -EngineProfile Upgrade30 -BuildMode Incremental -MaxParallelJobs 8
```

若内部 ABI 防护拒绝增量，切换到 `SafeChain`，不要传入内部的 `-AllowUnsafeAbiIncremental`。

### 3.3 ABI/发版安全构建

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -EngineProfile Upgrade30 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit
```

### 3.4 Debug + Release 里程碑验证

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both -EngineProfile Upgrade30 -MaxParallelJobs 8 -StrictRuntimeAudit
```

日常构建默认不加 `-Clean`。显式 `-Clean` 会强制回到 `SafeChain`。

## 4. 内部脚本的实际步骤

以下表格把 `client/Build-MT3-v120.ps1` 当前 Upgrade30 动作归纳为 10 个文档分组阶段：

| 序号 | 阶段 | 工程或动作 |
| ---: | --- | --- |
| 1 | platform | `common/platform/platform.win32.vcxproj` |
| 2 | ljfm | `common/ljfm/ljfm.win32.vcxproj` |
| 3 | cauthc | `common/cauthc/projects/windows/cauthc.win32.vcxproj` |
| 4 | cocos30_* 基础库 | `cocos2d-x-3.0-oh/build/**`（kazmath、tinyxml2、unzip、Box2D、chipmunk、lua、base、core、audio、extensions、network、ui、cocostudio、cocosbuilder、luabinding） |
| 5 | CEGUI079 | `tools/CEGUI-0.7.9-r5/cegui-0.7.9.win32.vcxproj` |
| 6 | engine | `engine/engine.win32.vcxproj` |
| 7 | FireClient | `client/MT3Win32App/FireClient.win32.vcxproj` |
| 8 | link-input-sync | 同步最终链接所需 `.lib` |
| 9 | MT3 | `client/MT3Win32App/mt3.win32.vcxproj` |
| 10 | runtime-sync/audit | 同步运行时文件并执行依赖审计 |

Upgrade30 实际记录 31 个独立计时步骤：27 个 `buildSteps`，再加 `link-input-sync`、`build:MT3`、`runtime-sync`、`runtime-audit`。`lua51-output-sync` 只在 Legacy226 执行，不属于 Upgrade30。

`Check-v120Toolset.ps1`、内部构建和 Win32 分析器均使用共享项目清单；新增或删除构建工程时只维护 `build-config.psm1`，并同时运行分析器自测。当前工作区本地的 `Test-No-D3D9Dependency.ps1` 也已按同一清单完成验证，但该文件受 `/tools/` 忽略规则影响，不属于 clean checkout 的强制入口。

## 5. ABI 重编边界

### 5.1 修改 engine 公共 ABI

命中 `engine/**.h`、renderer/framework 公共基类、虚函数、布局宏、模板或内联实现时：

```text
Rebuild engine -> Rebuild FireClient -> Build MT3
```

### 5.2 修改 FireClient 公共 ABI

命中 `client/FireClient/Application/**.h` 的类布局、继承、虚函数、模板或内联实现时：

```text
Rebuild FireClient -> Build MT3
```

### 5.3 修改 Cocos2d-x 公共 ABI

从对应 Cocos2d-x 3.0-oh 库开始重编，再继续：

```text
对应 Cocos 库 -> engine -> FireClient -> MT3
```

`FireClient.win32.vcxproj` 与 `mt3.win32.vcxproj` 共享输出目录（`OutDir`），但中间目录（`IntDir`）各自带项目名前缀（`$(ProjectName).$(Configuration).win32\`）相互独立。单项目增量成功、输出显示最新或只重链 `MT3.exe` 都不能证明 ABI 一致。

## 6. 输出与日志

| 类型 | 路径 |
| --- | --- |
| Debug 运行目录 | `client/resource/bin/Debug/` |
| Release 运行目录 | `client/resource/bin/Release/` |
| 最终主程序 | `client/resource/bin/<Configuration>/MT3.exe` |
| 内部中间产物 | `client/MT3Win32App/<Configuration>.win32/` |
| 构建日志 | `build_logs/msbuild_<step>_<Configuration>_<Platform>.log` |
| runtime audit | `build_logs/runtime-audit-*.json` 或脚本指定路径 |

构建完成后检查：

```powershell
Get-Item .\client\resource\bin\Release\MT3.exe | Select-Object FullName, Length, LastWriteTime
Get-Item .\client\MT3Win32App\Release.win32\FireClient.lib | Select-Object FullName, Length, LastWriteTime
Get-Item .\client\MT3Win32App\Release.win32\engine.lib | Select-Object FullName, Length, LastWriteTime
```

只检查本次构建的配置，并核对受影响库和 `MT3.exe` 的时间戳是否符合重编顺序。

## 7. runtime audit 与启动验证

默认 canonical build 会把 runtime audit 的 High 项作为警告并允许归档运行时回退；传入 `-StrictRuntimeAudit` 后，High 项会使构建门禁失败。

启动时从运行目录执行：

```powershell
Push-Location .\client\resource\bin\Release
try {
    .\MT3.exe
} finally {
    Pop-Location
}
```

若启动失败，先记录 Windows 事件、DMP、运行日志和第一个缺失依赖，再转到 [编译问题排查](../04-问题排查/01-编译问题排查.md) 或 [DMP 调试与崩溃栈分析](../04-问题排查/05-DMP调试与崩溃栈分析.md)。

## 8. 回滚

工程配置、依赖路径或构建治理调整失败时，按以下顺序回滚：

1. 停止继续叠加工程文件、宏或链接参数修改；保留首个错误和对应日志。
2. 在回退前归档本轮日志、关键产物大小/时间戳和 runtime audit 报告，不用删除输出目录代替证据保存。

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$evidenceDir = Join-Path '.\build_logs' "rollback-$stamp"
New-Item -ItemType Directory -Path $evidenceDir -Force | Out-Null
Copy-Item .\build_logs\*.log $evidenceDir -Force -ErrorAction SilentlyContinue
Copy-Item .\build_logs\runtime-audit-*.json $evidenceDir -Force -ErrorAction SilentlyContinue
Get-Item .\client\MT3Win32App\Release.win32\engine.lib,
         .\client\MT3Win32App\Release.win32\FireClient.lib,
         .\client\resource\bin\Release\MT3.exe -ErrorAction SilentlyContinue |
    Select-Object FullName, Length, LastWriteTimeUtc |
    Export-Csv (Join-Path $evidenceDir 'artifacts.csv') -NoTypeInformation -Encoding UTF8
```

3. 用 Git 对照并只回退本轮涉及的源码、`.vcxproj`、`.props` 或构建脚本；`KNOWN_GOOD_COMMIT` 和 `PATHS` 替换为已确认基线。

```powershell
git diff -- PATHS
git restore --source=KNOWN_GOOD_COMMIT -- PATHS
git status --short
```

4. 回退后使用 canonical wrapper 的 `SafeChain` 重新生成一致产物并执行严格 runtime audit：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -EngineProfile Upgrade30 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit
```

5. 复核 `engine.lib -> FireClient.lib -> MT3.exe` 时间戳、runtime audit、运行目录和实际启动；验证失败时保留新证据并继续回退到更早的已知可用配置。

不通过手工替换 `.lib/.dll/.exe`、切换新工具集或 `/FORCE` 链接来完成回滚。

## 9. Launcher 与第三方库

- Launcher 是独立解决方案，不由 canonical wrapper 构建，见 [Launcher 编译构建](../06-工具链/05-Launcher编译构建.md)；
- 第三方链接输入的自动补齐与逐库排障见 [第三方库编译指南](./05-第三方库编译指南.md)；
- 不创建替代 canonical wrapper 的批处理或新的全仓构建系统。

# 04-Windows 构建命令速查

> 所有命令从仓库根目录的 PowerShell 执行。环境变量统一使用 `$env:`。

## 1. 环境检查

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\windows-v120-build\scripts\verify-build-env.ps1 -Json
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1
```

全仓工程扫描：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1 -Scope All
```

## 2. 常用构建

```powershell
# Debug 日常开发
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -FastLocal -MaxParallelJobs 8

# Release 日常验证
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode Incremental -MaxParallelJobs 8

# Release ABI/发版安全构建
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit

# Debug + Release 里程碑验证
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both -MaxParallelJobs 8 -StrictRuntimeAudit
```

## 3. 常用参数

| 参数 | 作用 |
| --- | --- |
| `-Configuration Debug|Release` | 选择配置 |
| `-Platform Win32` | 固定主线平台 |
| `-BuildMode Incremental|SafeChain` | 选择增量或安全链 |
| `-FastLocal` | Debug 快速本地模式 |
| `-Clean` | 清理并强制 SafeChain |
| `-MaxParallelJobs N` | 设置工程并行度 |
| `-MaxCompilerProcesses N` | 限制编译器进程数 |
| `-StrictRuntimeAudit` | runtime audit High 直接失败 |
| `-SkipRuntimeAudit` | 仅专项排障时跳过运行时审计 |

## 4. 第三方链接输入

```powershell
# 校验并按需补齐 Debug 链接输入
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Ensure-MT3-Win32-LinkDeps.ps1 -Configuration Debug -Platform Win32 -Json

# 强制重建脚本可构建的 Release 依赖
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Ensure-MT3-Win32-LinkDeps.ps1 -Configuration Release -Platform Win32 -ForceRebuild -Json
```

canonical wrapper 会自动调用该脚本，通常不需要提前单独执行。

## 5. ABI 定向重编

```powershell
$vcvars = Join-Path $env:VS120COMNTOOLS '..\..\VC\vcvarsall.bat'
$msbuild = if ($env:MT3_MSBUILD_PATH) {
    $env:MT3_MSBUILD_PATH
} else {
    Join-Path ${env:ProgramFiles(x86)} 'MSBuild\12.0\Bin\MSBuild.exe'
}

# engine ABI 变化
cmd /c "call `"$vcvars`" x86 && `"$msbuild`" engine\engine.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo"
cmd /c "call `"$vcvars`" x86 && `"$msbuild`" client\MT3Win32App\FireClient.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /p:BuildProjectReferences=false /m /nologo"
cmd /c "call `"$vcvars`" x86 && `"$msbuild`" client\MT3Win32App\mt3.win32.vcxproj /t:Build /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /p:BuildProjectReferences=false /m /nologo"
```

手工命令只用于明确的定向重编/排障。常规交付仍应使用 canonical wrapper，让链接输入和 runtime audit 一并执行。

## 6. 日志与产物

```powershell
Get-ChildItem .\build_logs -Filter 'msbuild_*_Release_Win32.log' | Sort-Object LastWriteTime -Descending
Get-Item .\client\resource\bin\Release\MT3.exe | Select-Object FullName, Length, LastWriteTime
Get-Item .\client\MT3Win32App\Release.win32\engine.lib | Select-Object FullName, Length, LastWriteTime
Get-Item .\client\MT3Win32App\Release.win32\FireClient.lib | Select-Object FullName, Length, LastWriteTime
```

## 7. 从运行目录启动

```powershell
Push-Location .\client\resource\bin\Release
try {
    .\MT3.exe
} finally {
    Pop-Location
}
```

详细说明见 [Windows 完整构建指南](./02-Windows完整构建指南.md)。

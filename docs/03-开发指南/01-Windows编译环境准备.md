# 01-Windows 编译环境准备

> **适用范围**：MT3 Win32 主线
> **固定工具链**：Visual Studio 2013、`v120`、Windows SDK 8.1、MSBuild 12.0

## 1. 安装要求

| 组件 | 要求 |
| --- | --- |
| Visual Studio | Visual Studio 2013 C++ 工具链 |
| PlatformToolset | `v120` |
| Windows SDK | 8.1 |
| MSBuild | 12.0，目标为 Win32 |
| PowerShell | Windows PowerShell，可执行仓库 `.ps1` 脚本 |
| Git LFS | 已安装，并已签出构建所需二进制/资源 |

Win32 主线不使用 v140/v141/v142/v143 产物替换现有库，也不通过新工具集绕过链接或 ABI 问题。

## 2. 仓库自带环境探测

从仓库根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\windows-v120-build\scripts\verify-build-env.ps1 -Json
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1
```

两个入口的职责不同：

- `verify-build-env.ps1`：汇总 VS2013 `vcvarsall.bat`、MSBuild 12.0、关键脚本和 `Check-v120Toolset.ps1` 的结果；
- `Check-v120Toolset.ps1`：检查其 `Mainline` 清单中的 13 个 Win32 工程是否使用 `v120`。

这两个现有脚本都不读取 Windows SDK 8.1 注册表，也不检查 `Include\um\Windows.h`。SDK 必须按下一节单独探测。

只有排查全仓 vendor/示例工程时才扫描所有 `.vcxproj`：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1 -Scope All
```

`-Scope All` 的非主线告警不应反向修改 WinRT、WP8 或 vendor 工程来“统一全仓”。

## 3. 实际探测 Windows SDK 8.1

以下命令兼容 Windows PowerShell 5.1，同时检查 64 位与 WOW6432Node 注册表路径、`InstallationFolder` 和 SDK 头文件：

```powershell
$sdkRegistryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v8.1',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SDKs\Windows\v8.1'
)

$sdkCandidates = foreach ($registryPath in $sdkRegistryPaths) {
    if (-not (Test-Path -LiteralPath $registryPath)) {
        continue
    }

    $installationFolder = (Get-ItemProperty -LiteralPath $registryPath -Name InstallationFolder -ErrorAction Stop).InstallationFolder
    if ([string]::IsNullOrWhiteSpace($installationFolder)) {
        continue
    }

    $windowsHeader = Join-Path $installationFolder 'Include\um\Windows.h'
    [pscustomobject]@{
        RegistryPath = $registryPath
        InstallationFolder = $installationFolder
        InstallationFolderExists = Test-Path -LiteralPath $installationFolder
        WindowsHeader = $windowsHeader
        WindowsHeaderExists = Test-Path -LiteralPath $windowsHeader
    }
}

$sdkCandidates | Format-Table -AutoSize
$validSdk = @($sdkCandidates | Where-Object { $_.InstallationFolderExists -and $_.WindowsHeaderExists })
if ($validSdk.Count -eq 0) {
    throw 'Windows SDK 8.1 registry entry or Include\um\Windows.h is missing.'
}
```

至少应有一行同时满足 `InstallationFolderExists=True` 和 `WindowsHeaderExists=True`。注册表键存在但目录或 `Windows.h` 缺失时，仍判定 SDK 8.1 环境不完整。

## 4. 手工确认 VS2013 与 MSBuild

PowerShell 中的环境变量统一使用 `$env:`：

```powershell
$vcvars = Join-Path $env:VS120COMNTOOLS '..\..\VC\vcvarsall.bat'
$msbuild = if ($env:MT3_MSBUILD_PATH) {
    $env:MT3_MSBUILD_PATH
} else {
    Join-Path ${env:ProgramFiles(x86)} 'MSBuild\12.0\Bin\MSBuild.exe'
}

Test-Path -LiteralPath $vcvars
Test-Path -LiteralPath $msbuild
& $msbuild /version /nologo
cmd /c "call `"$vcvars`" x86 && cl"
```

预期：

- 两次 `Test-Path` 返回 `True`；
- MSBuild 主版本为 `12`；
- `cl` 来自 VS2013 x86 工具链。

如果环境变量未设置，可在当前 PowerShell 进程中显式配置：

```powershell
$env:VS120COMNTOOLS = 'D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\'
$env:MT3_MSBUILD_PATH = 'C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe'
```

构建入口也会在常见安装路径中探测并收敛这些变量；固定路径仅作为当前工作机示例，不应写入工程文件。

## 5. 核对仓库入口

```powershell
@(
    '.\tools\scripts\Build-MT3-Exe-Canonical.ps1',
    '.\client\Build-MT3-v120.ps1',
    '.\tools\scripts\Check-v120Toolset.ps1',
    '.\tools\scripts\Ensure-MT3-Win32-LinkDeps.ps1',
    '.\tools\scripts\Audit-RuntimeDependencies.ps1',
    '.\client\MT3Win32App\FireClient.win32.vcxproj',
    '.\client\MT3Win32App\mt3.win32.vcxproj',
    '.\cocos2d-x-2.2.6'
) | ForEach-Object { Get-Item -LiteralPath $_ }
```

`cocos2d-x-2.2.6/` 必须存在；旧 `cocos2d-2.0-rc2-x-2.0.1/` 不作为当前构建主线。

## 6. 首次构建前准备

```powershell
git lfs install
git lfs pull
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1
```

然后按 [Windows 构建前检查清单](./03-Windows构建前检查清单.md) 核对编码、ABI、运行目录和产物状态，再使用 [Windows 完整构建指南](./02-Windows完整构建指南.md) 的固定入口构建。

## 7. 边界

- Launcher 不由 `Build-MT3-Exe-Canonical.ps1` 构建，见 [Launcher 编译构建](../06-工具链/05-Launcher编译构建.md)；
- Android、服务器和资源发布使用各自既有工具链；
- 不批量改写 `.vcxproj` 的工具集、运行时库、编码或换行；
- 遇到 `C2001: 常量中有换行符` 且文件包含中文时，先检查 C/C++ 源文件是否丢失 UTF-8 BOM。

param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-WindowsEnvDefaults {
    if (-not $env:SystemRoot) {
        $env:SystemRoot = "C:\\Windows"
    }
    if (-not $env:WINDIR) {
        $env:WINDIR = $env:SystemRoot
    }

    if (-not $env:SystemDrive) {
        $driveRoot = [System.IO.Path]::GetPathRoot($env:SystemRoot)
        if ($driveRoot) {
            $env:SystemDrive = $driveRoot.TrimEnd("\\")
        }
    }
    if (-not $env:SystemDrive) {
        $env:SystemDrive = "C:"
    }

    if (-not $env:ProgramData) {
        $env:ProgramData = Join-Path $env:SystemDrive "ProgramData"
    }
    if (-not $env:ALLUSERSPROFILE) {
        $env:ALLUSERSPROFILE = $env:ProgramData
    }

    if (-not $env:USERPROFILE) {
        if ($env:TEMP -match "^(.*)\\\\AppData\\\\Local\\\\Temp\\\\?$") {
            $env:USERPROFILE = $Matches[1]
        } else {
            $env:USERPROFILE = Join-Path $env:SystemDrive "Users\\$env:USERNAME"
        }
    }

    if (-not $env:HOMEDRIVE) {
        $homeDriveRoot = [System.IO.Path]::GetPathRoot($env:USERPROFILE)
        if ($homeDriveRoot) {
            $env:HOMEDRIVE = $homeDriveRoot.TrimEnd("\\")
        } else {
            $env:HOMEDRIVE = $env:SystemDrive
        }
    }
    if (-not $env:HOMEPATH) {
        if ($env:USERPROFILE.StartsWith($env:HOMEDRIVE, [System.StringComparison]::OrdinalIgnoreCase)) {
            $env:HOMEPATH = $env:USERPROFILE.Substring($env:HOMEDRIVE.Length)
        } else {
            $env:HOMEPATH = "\\Users\\$env:USERNAME"
        }
    }

    if (-not $env:LOCALAPPDATA) {
        $env:LOCALAPPDATA = Join-Path $env:USERPROFILE "AppData\\Local"
    }
    if (-not $env:APPDATA) {
        $env:APPDATA = Join-Path $env:USERPROFILE "AppData\\Roaming"
    }
    if (-not $env:TEMP) {
        $env:TEMP = Join-Path $env:LOCALAPPDATA "Temp"
    }
    if (-not $env:TMP) {
        $env:TMP = $env:TEMP
    }

    foreach ($path in @($env:ProgramData, $env:LOCALAPPDATA, $env:APPDATA, $env:TEMP)) {
        if ($path -and -not (Test-Path $path)) {
            New-Item -ItemType Directory -Force -Path $path | Out-Null
        }
    }
}

function Resolve-ProgramFilesX86 {
    $candidates = New-Object System.Collections.Generic.List[string]

    if (${env:ProgramFiles(x86)}) {
        [void]$candidates.Add(${env:ProgramFiles(x86)})
    }

    $folderByApi = [Environment]::GetFolderPath("ProgramFilesX86")
    if (-not [string]::IsNullOrWhiteSpace($folderByApi)) {
        [void]$candidates.Add($folderByApi)
    }

    [void]$candidates.Add("C:\\Program Files (x86)")
    [void]$candidates.Add("D:\\Program Files (x86)")

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        if (Test-Path $candidate) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    return $null
}

function Resolve-MSBuild12 {
    $candidates = New-Object System.Collections.Generic.List[string]

    if ($env:MT3_MSBUILD_PATH) {
        [void]$candidates.Add($env:MT3_MSBUILD_PATH)
    }

    $programFilesX86 = Resolve-ProgramFilesX86
    if ($programFilesX86) {
        [void]$candidates.Add((Join-Path $programFilesX86 "MSBuild\\12.0\\Bin\\MSBuild.exe"))
    }

    [void]$candidates.Add("C:\\Program Files (x86)\\MSBuild\\12.0\\Bin\\MSBuild.exe")
    [void]$candidates.Add("D:\\Program Files (x86)\\MSBuild\\12.0\\Bin\\MSBuild.exe")

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        if (Test-Path $candidate) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    throw "未找到 MSBuild 12.0。请安装 VS2013 或设置 MT3_MSBUILD_PATH。"
}

Ensure-WindowsEnvDefaults
$programFilesX86 = Resolve-ProgramFilesX86
if ($programFilesX86) {
    ${env:ProgramFiles(x86)} = $programFilesX86
}

$root = Split-Path -Parent $PSScriptRoot
$sln = Join-Path $root "vc++12\TexturePacker_CEGUI.sln"
$msbuild = Resolve-MSBuild12

& $msbuild $sln /t:Rebuild /p:Configuration=$Configuration /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo
if ($LASTEXITCODE -ne 0) {
    throw "构建失败，退出码: $LASTEXITCODE"
}

Write-Host "构建成功: $Configuration"

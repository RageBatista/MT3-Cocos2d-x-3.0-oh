[CmdletBinding()]
param(
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release",
    [ValidateSet("Win32")]
    [string]$Platform = "Win32",
    [ValidateSet("SafeChain", "Incremental")]
    [string]$BuildMode = "SafeChain",
    [ValidateSet("Legacy226", "Upgrade30")]
    [string]$EngineProfile = "Upgrade30",
    [switch]$Clean,
    [int]$MaxParallelJobs = 0,
    [int]$MaxCompilerProcesses = 0,
    [string]$FmodDll,
    [switch]$FastLocal,
    [switch]$SkipToolchainPrecheck,
    [switch]$SkipSourceNulScan,
    [switch]$SkipRuntimeSync,
    [switch]$SkipRuntimeAudit,
    [switch]$StrictRuntimeAudit
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Resolve-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..\\..")).Path
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

    throw "ProgramFiles(x86) is not resolvable. Install VS2013/MSBuild 12.0 first."
}

function Resolve-VS120ComnTools {
    $candidates = New-Object System.Collections.Generic.List[string]

    if ($env:VS120COMNTOOLS) {
        [void]$candidates.Add($env:VS120COMNTOOLS)
    }

    [void]$candidates.Add("D:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\Common7\\Tools\\")
    [void]$candidates.Add("C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\Common7\\Tools\\")

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        $toolsRoot = [System.IO.Path]::GetFullPath($candidate)
        $vcvars = Join-Path $toolsRoot "..\\..\\VC\\vcvarsall.bat"
        if (Test-Path $vcvars) {
            return $toolsRoot
        }
    }

    throw "VS120COMNTOOLS is not resolvable. Expected VS2013 at Common7\\Tools."
}

function Resolve-MSBuildPath {
    param(
        [Parameter(Mandatory = $true)][string]$ProgramFilesX86
    )

    if ($env:MT3_MSBUILD_PATH -and (Test-Path $env:MT3_MSBUILD_PATH)) {
        return [System.IO.Path]::GetFullPath($env:MT3_MSBUILD_PATH)
    }

    $candidate = Join-Path $ProgramFilesX86 "MSBuild\\12.0\\Bin\\MSBuild.exe"
    if (Test-Path $candidate) {
        return [System.IO.Path]::GetFullPath($candidate)
    }

    throw "MSBuild 12.0 not found. Set MT3_MSBUILD_PATH or install VS2013 Build Tools."
}

function Resolve-PowerShellExe {
    $candidate = Join-Path $env:SystemRoot "System32\\WindowsPowerShell\\v1.0\\powershell.exe"
    if (Test-Path $candidate) {
        return $candidate
    }
    return "powershell.exe"
}

function Assert-EngineProfileProjectConfiguration {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$EngineProfile
    )

    $expectedCocosRoot = if ($EngineProfile -eq "Upgrade30") { "cocos2d-x-3.0-oh" } else { "cocos2d-x-2.2.6" }
    $unexpectedCocosRoot = if ($EngineProfile -eq "Upgrade30") { "cocos2d-x-2.2.6" } else { "cocos2d-x-3.0-oh" }
    $expectedCeguiRoot = if ($EngineProfile -eq "Upgrade30") { "tools\CEGUI-0.7.9-r5" } else { "dependencies\cegui" }
    $unexpectedCeguiRoot = if ($EngineProfile -eq "Upgrade30") { "dependencies\cegui" } else { "tools\CEGUI-0.7.9-r5" }

    $checks = @(
        @{ Path = "engine\engine.win32.vcxproj"; Expected = @($expectedCocosRoot); Unexpected = @($unexpectedCocosRoot) },
        @{ Path = "client\MT3Win32App\FireClient.win32.vcxproj"; Expected = @($expectedCocosRoot, $expectedCeguiRoot); Unexpected = @($unexpectedCocosRoot, $unexpectedCeguiRoot) },
        @{ Path = "client\MT3Win32App\mt3.win32.vcxproj"; Expected = @($expectedCocosRoot, $expectedCeguiRoot); Unexpected = @($unexpectedCocosRoot, $unexpectedCeguiRoot) }
    )

    if ($EngineProfile -eq "Upgrade30") {
        $checks += @{
            Path = "tools\CEGUI-0.7.9-r5\cegui-0.7.9.win32.vcxproj"
            Expected = @($expectedCocosRoot)
            Unexpected = @($unexpectedCocosRoot)
        }
    } else {
        $checks += @{
            Path = "dependencies\cegui\project\win32\cegui.win32.vcxproj"
            Expected = @($expectedCocosRoot)
            Unexpected = @($unexpectedCocosRoot)
        }
    }

    $violations = New-Object System.Collections.Generic.List[string]
    foreach ($check in $checks) {
        $projectPath = Join-Path $RepoRoot $check.Path
        if (-not (Test-Path -LiteralPath $projectPath -PathType Leaf)) {
            [void]$violations.Add("missing project: $($check.Path)")
            continue
        }

        $content = [System.IO.File]::ReadAllText($projectPath).Replace('/', '\')
        foreach ($marker in $check.Expected) {
            if ($content.IndexOf($marker, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
                [void]$violations.Add("$($check.Path) does not reference $marker")
            }
        }
        foreach ($marker in $check.Unexpected) {
            if ($content.IndexOf($marker, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                [void]$violations.Add("$($check.Path) still references $marker")
            }
        }
    }

    if ($violations.Count -gt 0) {
        throw ("EngineProfile {0} does not match the Win32 project configuration:`n{1}" -f $EngineProfile, ($violations -join "`n"))
    }

    Write-Host "Engine profile project configuration: ok ($EngineProfile)"
}

function Invoke-LinkDependencyRepair {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$Configuration,
        [Parameter(Mandatory = $true)][string]$Platform,
        [Parameter(Mandatory = $true)][string]$EngineProfile
    )

    $repairScript = Join-Path $RepoRoot "tools\\scripts\\Ensure-MT3-Win32-LinkDeps.ps1"
    if (-not (Test-Path $repairScript)) {
        throw "Missing Win32 link dependency repair script: $repairScript"
    }

    if (-not $FastLocal) {
        Write-Host "Running Win32 link dependency repair: $repairScript"
    }
    $psExe = Resolve-PowerShellExe
    $output = @(& $psExe -NoProfile -ExecutionPolicy Bypass -File $repairScript -RepoRoot $RepoRoot -Configuration $Configuration -Platform $Platform -EngineProfile $EngineProfile -Json 2>&1)
    $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    if ($exitCode -ne 0) {
        $joinedOutput = ($output | Out-String).Trim()
        if (-not [string]::IsNullOrWhiteSpace($joinedOutput)) {
            Write-Host $joinedOutput
        }
        throw "Win32 link dependency repair failed. Resolve third-party link dependencies before building MT3.exe."
    }

    $joined = ($output | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($joined)) {
        Write-Host "Win32 link deps: no output"
        return
    }

    try {
        $result = $joined | ConvertFrom-Json
    } catch {
        Write-Host $joined
        throw "Win32 link dependency repair returned non-JSON output."
    }

    $builtCount = @($result.data.built).Count
    $stagedCount = @($result.data.staged).Count
    $verifiedCount = @($result.data.verified).Count
    $summarySuffix = @()
    if ($builtCount -gt 0) {
        $summarySuffix += ("built={0}" -f $builtCount)
    }
    if ($stagedCount -gt 0) {
        $summarySuffix += ("staged={0}" -f $stagedCount)
    }
    if ($verifiedCount -gt 0) {
        $summarySuffix += ("verified={0}" -f $verifiedCount)
    }

    if ($summarySuffix.Count -gt 0) {
        Write-Host ("Win32 link deps: {0} ({1})" -f $result.summary, ($summarySuffix -join ", "))
    } else {
        Write-Host ("Win32 link deps: {0}" -f $result.summary)
    }
}

function Test-GitLfsPointerFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )

    $stream = $null
    try {
        $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $buffer = New-Object byte[] 128
        $read = $stream.Read($buffer, 0, $buffer.Length)
        if ($read -le 0) {
            return $false
        }

        $prefix = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
        return $prefix.StartsWith("version https://git-lfs.github.com/spec/v1", [System.StringComparison]::Ordinal)
    } catch {
        throw ("Unable to inspect Git LFS pointer state for {0}: {1}" -f $Path, $_.Exception.Message)
    } finally {
        if ($stream) {
            $stream.Dispose()
        }
    }
}

function Assert-NoGitLfsPointers {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$Configuration,
        [Parameter(Mandatory = $true)][string]$EngineProfile
    )

    $checks = @(
        @{
            Root = "client\res_win\res"
            Patterns = @("*")
            Fix = 'git lfs checkout "client/res_win/res"'
        },
        @{
            Root = "client\resource\bin\Release"
            Patterns = @("*.dll", "*.exe", "*.lib", "*.pdb")
            Fix = 'git lfs checkout "client/resource/bin/Release"'
        },
        @{
            Root = "client\resource\bin\Debug"
            Patterns = @("*.dll", "*.exe", "*.lib", "*.pdb")
            Fix = 'git lfs checkout "client/resource/bin/Debug"'
        }
    )

    if ($EngineProfile -eq "Upgrade30") {
        $checks += @(
            @{
                Root = "cocos2d-x-3.0-oh\build\lib\$Configuration"
                Patterns = @("*.lib")
                Fix = 'rebuild the Cocos2d-x 3.0-oh static libraries'
            },
            @{
                Root = "cocos2d-x-3.0-oh\build\cocos\audio\$Configuration"
                Patterns = @("*.lib")
                Fix = 'rebuild the Cocos2d-x 3.0-oh audio static library'
            },
            @{
                Root = "tools\CEGUI-0.7.9-r5\$Configuration.win32"
                Patterns = @("*.lib")
                Fix = 'rebuild the CEGUI 0.7.9-r5 static library'
            }
        )
    } else {
        $checks += @(
            @{
                Root = "cocos2d-x-2.2.6\Release.win32"
                Patterns = @("*.dll", "*.exe", "*.lib", "*.pdb")
                Fix = 'git lfs checkout "cocos2d-x-2.2.6/Release.win32"'
            },
            @{
                Root = "cocos2d-x-2.2.6\Debug.win32"
                Patterns = @("*.dll", "*.exe", "*.lib", "*.pdb")
                Fix = 'git lfs checkout "cocos2d-x-2.2.6/Debug.win32"'
            }
        )
    }

    $violations = New-Object System.Collections.Generic.List[string]
    foreach ($check in $checks) {
        $root = Join-Path $RepoRoot $check.Root
        if (-not (Test-Path $root)) {
            continue
        }

        foreach ($pattern in $check.Patterns) {
            $items = Get-ChildItem -LiteralPath $root -Filter $pattern -File -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                if (Test-GitLfsPointerFile -Path $item.FullName) {
                    [void]$violations.Add(("{0} -> {1}" -f $item.FullName, $check.Fix))
                }
            }
        }
    }

    if ($violations.Count -gt 0) {
        $shown = @($violations | Select-Object -First 20)
        $more = ""
        if ($violations.Count -gt $shown.Count) {
            $more = "`n... and $($violations.Count - $shown.Count) more"
        }
        throw ("Git LFS pointer files found in runtime inputs. Run the listed checkout commands before building MT3.exe.`n{0}{1}" -f ($shown -join "`n"), $more)
    }

    Write-Host "Git LFS runtime inputs: ok"
}

function Invoke-V120ToolchainPrecheck {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$EngineProfile
    )

    $checkScript = Join-Path $RepoRoot "tools\\scripts\\Check-v120Toolset.ps1"
    if (-not (Test-Path $checkScript)) {
        throw "Missing toolchain precheck script: $checkScript"
    }

    Write-Host "Running toolchain precheck: $checkScript"
    $psExe = Resolve-PowerShellExe
    $proc = Start-Process -FilePath $psExe `
        -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $checkScript, "-RootPath", $RepoRoot, "-Scope", "Mainline", "-EngineProfile", $EngineProfile) `
        -Wait -NoNewWindow -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "v120 toolchain precheck failed. Resolve toolchain issues before building MT3.exe."
    }
}

function Invoke-SourceNulScan {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $scanScript = Join-Path $RepoRoot "tools\scripts\Test-SourceNoNulBytes.ps1"
    if (-not (Test-Path $scanScript)) {
        throw "Missing source NUL scan script: $scanScript"
    }

    Write-Host "Running source NUL scan: $scanScript"
    $psExe = Resolve-PowerShellExe
    $scanRoots = @(
        "client\FireClient\Application",
        "client\MT3Win32App",
        "client\Build-MT3-v120.ps1",
        "engine",
        "common",
        "tools\scripts"
    )
    $scanArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $scanScript, "-RepoRoot", $RepoRoot, "-IncludeRoots", ($scanRoots -join ","))
    $output = @(& $psExe @scanArgs 2>&1)
    $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    if ($output.Count -gt 0) {
        $output | ForEach-Object { Write-Host $_ }
    }
    if ($exitCode -ne 0) {
        throw "Source NUL scan failed. Remove embedded NUL bytes before building MT3.exe."
    }
}

function Resolve-EffectiveBuildMode {
    param(
        [Parameter(Mandatory = $true)][string]$RequestedMode,
        [Parameter(Mandatory = $true)][bool]$IsClean,
        [Parameter(Mandatory = $true)][bool]$IsFastLocal
    )

    if ($IsClean) {
        return "SafeChain"
    }

    if ($IsFastLocal -and ($RequestedMode -eq "SafeChain")) {
        return "Incremental"
    }

    return $RequestedMode
}

function Assert-MSBuildVersion12 {
    param(
        [Parameter(Mandatory = $true)][string]$MSBuildPath,
        [Parameter(Mandatory = $true)][string]$LogDir
    )

    $versionLog = Join-Path $LogDir "msbuild_version_check.log"
    $versionLines = & $MSBuildPath /version /nologo 2>&1
    $exitCode = $LASTEXITCODE
    $raw = ($versionLines | Out-String)
    Set-Content -Path $versionLog -Value $raw -Encoding UTF8
    if ($exitCode -ne 0) {
        throw "Failed to query MSBuild version. See log: $versionLog"
    }

    $versionMatch = [regex]::Match($raw, '(?m)\b\d+\.\d+(?:\.\d+){0,2}\b')
    if (-not $versionMatch.Success) {
        throw "Unable to parse MSBuild version from log: $versionLog"
    }

    $version = $versionMatch.Value
    if (-not $version.StartsWith("12.")) {
        throw "MSBuild version mismatch: expected 12.x but got $version (path: $MSBuildPath)"
    }

    Write-Host "MSBuild version: $version"
}

function Resolve-FailedBuildLogPath {
    param(
        [Parameter(Mandatory = $true)][System.Management.Automation.ErrorRecord]$ErrorRecord,
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$Configuration,
        [Parameter(Mandatory = $true)][string]$Platform,
        [datetime]$NotBefore
    )

    $message = $ErrorRecord.Exception.Message
    if ($message -match '\(log:\s*(?<path>[^)]+)\)') {
        $explicitLog = $Matches["path"].Trim()
        if (-not [string]::IsNullOrWhiteSpace($explicitLog) -and (Test-Path $explicitLog)) {
            return [System.IO.Path]::GetFullPath($explicitLog)
        }
    }

    $logDir = Join-Path $RepoRoot "build_logs"
    if (-not (Test-Path $logDir)) {
        return $null
    }

    $candidates = Get-ChildItem -Path $logDir -File -Filter ("msbuild_*_{0}_{1}.log" -f $Configuration, $Platform)
    if ($NotBefore) {
        $candidates = $candidates | Where-Object { $_.LastWriteTime -ge $NotBefore }
    }

    $latest = $candidates |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($latest) {
        return $latest.FullName
    }

    return $null
}

function Write-BuildLogTail {
    param(
        [Parameter(Mandatory = $true)][string]$LogPath,
        [int]$TailLines = 40
    )

    if (-not (Test-Path $LogPath)) {
        Write-Host "Failed log path not found: $LogPath"
        return
    }

    Write-Host ("Last build log tail ({0}, {1} lines):" -f $LogPath, $TailLines)
    try {
        Get-Content -Path $LogPath -Encoding UTF8 -Tail $TailLines | ForEach-Object { Write-Host $_ }
    } catch {
        Write-Host ("Unable to read build log tail: {0}" -f $_.Exception.Message)
    }
}

function Ensure-WindowsEnvDefaults {
    if (-not $env:SystemRoot) {
        $env:SystemRoot = "C:\\Windows"
    }
    if (-not $env:WINDIR) {
        $env:WINDIR = $env:SystemRoot
    }

    if ($env:SystemDrive -and $env:SystemDrive.Contains("%")) {
        $env:SystemDrive = $null
    }
    if ($env:SystemDrive -and ($env:SystemDrive -notmatch "^[A-Za-z]:$")) {
        $driveRootFromEnv = [System.IO.Path]::GetPathRoot($env:SystemDrive)
        if ($driveRootFromEnv -and ($driveRootFromEnv -match "^[A-Za-z]:\\$")) {
            $env:SystemDrive = $driveRootFromEnv.TrimEnd("\\")
        } else {
            $env:SystemDrive = $null
        }
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
            $env:USERPROFILE = Join-Path $env:SystemDrive "Users\\www"
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
            $env:HOMEPATH = "\\Users\\www"
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

$repoRoot = $null
$buildStartedAt = $null

try {
    Ensure-WindowsEnvDefaults

    $repoRoot = Resolve-RepoRoot
    $canonicalLogDir = Join-Path $repoRoot "build_logs"
    New-Item -ItemType Directory -Force -Path $canonicalLogDir | Out-Null

    if ($SkipSourceNulScan) {
        Write-Host "Skipping source NUL scan (requested by -SkipSourceNulScan)."
    } else {
        Invoke-SourceNulScan -RepoRoot $repoRoot
    }

    $effectiveSkipToolchainPrecheck = $SkipToolchainPrecheck.IsPresent
    if ($FastLocal -and -not $SkipToolchainPrecheck) {
        $effectiveSkipToolchainPrecheck = $true
    }

    if ($effectiveSkipToolchainPrecheck) {
        if ($SkipToolchainPrecheck) {
            Write-Host "Skipping toolchain precheck (requested by -SkipToolchainPrecheck)."
        } else {
            Write-Host "Skipping toolchain precheck (FastLocal default)."
        }
    } else {
        Invoke-V120ToolchainPrecheck -RepoRoot $repoRoot -EngineProfile $EngineProfile
    }

    $buildScript = Join-Path $repoRoot "client\\Build-MT3-v120.ps1"
    if (-not (Test-Path $buildScript)) {
        throw "Missing script: $buildScript"
    }

    $programFilesX86 = Resolve-ProgramFilesX86
    ${env:ProgramFiles(x86)} = $programFilesX86

    $vs120ComnTools = Resolve-VS120ComnTools
    $env:VS120COMNTOOLS = $vs120ComnTools

    $msbuildPath = Resolve-MSBuildPath -ProgramFilesX86 $programFilesX86
    $env:MT3_MSBUILD_PATH = $msbuildPath
    Assert-MSBuildVersion12 -MSBuildPath $msbuildPath -LogDir $canonicalLogDir

    $effectiveBuildMode = Resolve-EffectiveBuildMode -RequestedMode $BuildMode -IsClean:$Clean.IsPresent -IsFastLocal:$FastLocal.IsPresent
    $effectiveSkipRuntimeAudit = $SkipRuntimeAudit.IsPresent
    if ($FastLocal -and -not $SkipRuntimeAudit) {
        $effectiveSkipRuntimeAudit = $true
    }

    Assert-EngineProfileProjectConfiguration -RepoRoot $repoRoot -EngineProfile $EngineProfile
    Invoke-LinkDependencyRepair -RepoRoot $repoRoot -Configuration $Configuration -Platform $Platform -EngineProfile $EngineProfile
    Assert-NoGitLfsPointers -RepoRoot $repoRoot -Configuration $Configuration -EngineProfile $EngineProfile

    $buildParams = @{
        Configuration = $Configuration
        Platform = $Platform
        BuildMode = $effectiveBuildMode
        EngineProfile = $EngineProfile
        CalledFromCanonical = $true
        SkipSourceNulScan = $true
    }

    if ($Clean) {
        $buildParams.Clean = $true
    }
    if ($MaxParallelJobs -gt 0) {
        $buildParams.MaxParallelJobs = $MaxParallelJobs
    }
    if ($MaxCompilerProcesses -gt 0) {
        $buildParams.MaxCompilerProcesses = $MaxCompilerProcesses
    }
    if ($FmodDll) {
        $buildParams.FmodDll = $FmodDll
    }
    if ($SkipRuntimeSync) {
        $buildParams.SkipRuntimeSync = $true
    }
    if ($effectiveSkipRuntimeAudit) {
        $buildParams.SkipRuntimeAudit = $true
    } else {
        $buildParams.AllowArchiveRuntimeFallback = $true
        if (-not $StrictRuntimeAudit) {
            $buildParams.RuntimeAuditWarnOnly = $true
        }
    }

    Write-Host "MT3 canonical build: $Configuration|$Platform"
    Write-Host "EngineProfile: $EngineProfile"
    Write-Host "BuildMode: $effectiveBuildMode"
    if ($FastLocal) {
        $buildParams.ConciseOutput = $true
        Write-Host "FastLocal: enabled (auto Incremental + SkipRuntimeAudit + SkipToolchainPrecheck by default)"
    }
    if (-not $FastLocal) {
        Write-Host "VS120COMNTOOLS: $env:VS120COMNTOOLS"
        Write-Host "MSBuild: $env:MT3_MSBUILD_PATH"
    }
    $buildStartedAt = Get-Date
    $buildResult = & $buildScript @buildParams
    $resultToken = $null
    if ($buildResult -is [hashtable]) {
        $resultToken = $buildResult
    } elseif ($buildResult -is [System.Collections.IEnumerable]) {
        $resultToken = @(
            $buildResult |
                Where-Object { $_ -is [hashtable] -and $_.ContainsKey("Success") } |
                Select-Object -Last 1
        )[0]
    }

    if (-not $resultToken -or (-not [bool]$resultToken.Success)) {
        throw "Internal build chain did not report explicit success."
    }

    $mt3Exe = Join-Path $repoRoot ("client\\resource\\bin\\{0}\\MT3.exe" -f $Configuration)
    if (-not (Test-Path $mt3Exe)) {
        throw "Build completed but MT3.exe is missing: $mt3Exe"
    }

    $exeItem = Get-Item $mt3Exe
    Write-Host ("MT3.exe => {0} | {1} bytes | {2:yyyy-MM-dd HH:mm:ss}" -f $exeItem.FullName, $exeItem.Length, $exeItem.LastWriteTime)
    exit 0
}
catch {
    $err = $_
    Write-Host ("ERROR [{0}] {1}" -f $err.Exception.GetType().FullName, $err.Exception.Message)
    if ($err.ScriptStackTrace) {
        Write-Host "Script stack trace:"
        Write-Host $err.ScriptStackTrace
    }

    if ($repoRoot) {
        $resolveFailedLogArgs = @{
            ErrorRecord = $err
            RepoRoot = $repoRoot
            Configuration = $Configuration
            Platform = $Platform
        }
        if ($buildStartedAt) {
            $resolveFailedLogArgs.NotBefore = $buildStartedAt
        }
        $failedLog = Resolve-FailedBuildLogPath @resolveFailedLogArgs
        if ($failedLog) {
            Write-BuildLogTail -LogPath $failedLog -TailLines 40
        }
    }

    exit 1
}

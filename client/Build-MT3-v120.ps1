[CmdletBinding()]
param(
    [ValidateSet("Release", "Debug")][string]$Configuration = "Release",
    [ValidateSet("Win32")][string]$Platform = "Win32",
    [switch]$Clean,
    [ValidateSet("SafeChain", "Incremental")][string]$BuildMode = "SafeChain",
    [ValidateSet("Legacy226", "Upgrade30")][string]$EngineProfile = "Legacy226",
    [switch]$AllowUnsafeAbiIncremental,
    [int]$MaxParallelJobs = 0,
    [int]$MaxCompilerProcesses = 0,
    [string]$FmodDll,
    [switch]$SkipRuntimeSync,
    [switch]$AllowArchiveRuntimeFallback,
    [switch]$SkipRuntimeAudit,
    [switch]$RuntimeAuditWarnOnly,
    [string]$RuntimeAuditScript = "tools\\scripts\\Audit-RuntimeDependencies.ps1",
    [string]$RuntimeAuditReport = "build_logs\\runtime-audit-after-client-build.json",
    [string[]]$RuntimeAuditScanRoots = @(),
    [switch]$SkipSourceNulScan,
    [switch]$ConciseOutput,
    [Parameter(DontShow = $true)][switch]$CalledFromCanonical
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($Clean) {
    $BuildMode = "SafeChain"
}

function Resolve-MT3Roots {
    $scriptRoot = $PSScriptRoot
    $repoRoot = $null
    $clientRoot = $null

    if (Test-Path (Join-Path $scriptRoot "client\\FireClient\\FireClient.sln")) {
        $repoRoot = $scriptRoot
        $clientRoot = Join-Path $repoRoot "client"
    } elseif (Test-Path (Join-Path $scriptRoot "FireClient\\FireClient.sln")) {
        $clientRoot = $scriptRoot
        $repoRoot = Split-Path -Parent $clientRoot
    } else {
        throw "Cannot locate FireClient.sln relative to $scriptRoot"
    }

    return @{
        RepoRoot   = $repoRoot
        ClientRoot = $clientRoot
    }
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$BaseRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BaseRoot $PathValue))
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

function Resolve-MSBuild {
    if ($env:MT3_MSBUILD_PATH -and (Test-Path $env:MT3_MSBUILD_PATH)) {
        return [System.IO.Path]::GetFullPath($env:MT3_MSBUILD_PATH)
    }

    $programFilesX86 = Resolve-ProgramFilesX86
    if ($programFilesX86) {
        $candidate = Join-Path $programFilesX86 "MSBuild\\12.0\\Bin\\MSBuild.exe"
        if (Test-Path $candidate) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    $fallbacks = @(
        "C:\\Program Files (x86)\\MSBuild\\12.0\\Bin\\MSBuild.exe",
        "D:\\Program Files (x86)\\MSBuild\\12.0\\Bin\\MSBuild.exe"
    )
    foreach ($path in $fallbacks) {
        if (Test-Path $path) {
            return [System.IO.Path]::GetFullPath($path)
        }
    }

    throw "MSBuild 12.0 not found. Install VS2013 or set MT3_MSBUILD_PATH."
}

function Resolve-Vs120Tool {
    param(
        [Parameter(Mandatory = $true)][string]$ToolName
    )

    $candidates = New-Object System.Collections.Generic.List[string]

    if ($env:VS120COMNTOOLS) {
        [void]$candidates.Add((Join-Path $env:VS120COMNTOOLS ("..\\..\\VC\\bin\\{0}" -f $ToolName)))
    }

    [void]$candidates.Add(("D:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\bin\\{0}" -f $ToolName))
    [void]$candidates.Add(("C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\bin\\{0}" -f $ToolName))

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        $toolPath = [System.IO.Path]::GetFullPath($candidate)
        if (Test-Path $toolPath) {
            return $toolPath
        }
    }

    throw "VS2013 tool not found: $ToolName"
}

function Resolve-VcVars {
    $candidates = New-Object System.Collections.Generic.List[string]

    if ($env:VS120COMNTOOLS) {
        [void]$candidates.Add((Join-Path $env:VS120COMNTOOLS "..\\..\\VC\\vcvarsall.bat"))
    }

    [void]$candidates.Add("D:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\vcvarsall.bat")
    [void]$candidates.Add("C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\vcvarsall.bat")

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        $vcvars = [System.IO.Path]::GetFullPath($candidate)
        if (Test-Path $vcvars) {
            $vsRoot = Split-Path (Split-Path $vcvars -Parent) -Parent
            $toolsRoot = Join-Path $vsRoot "Common7\\Tools\\"
            $env:VS120COMNTOOLS = [System.IO.Path]::GetFullPath($toolsRoot)
            return $vcvars
        }
    }

    return $null
}

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

function Clear-InheritedToolchainEnv {
    # Guard against polluted parent-shell toolchain variables (common MSB4019 trigger).
    $varsToClear = @(
        "VCTargetsPath",
        "VCINSTALLDIR",
        "VSINSTALLDIR",
        "VisualStudioVersion",
        "WindowsSdkDir",
        "WindowsSDKVersion"
    )

    foreach ($varName in $varsToClear) {
        if (Test-Path ("Env:{0}" -f $varName)) {
            Remove-Item ("Env:{0}" -f $varName) -ErrorAction SilentlyContinue
        }
    }
}

function Get-LastBuildStatePath {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectName
    )

    switch ($ProjectName) {
        "engine" {
            return Join-Path $script:RepoRoot ("engine\\{0}.win32\\engine.tlog\\engine.lastbuildstate" -f $script:Configuration)
        }
        "FireClient" {
            return Join-Path $script:ClientRoot ("MT3Win32App\\FireClient.{0}.win32\\FireClient.tlog\\FireClient.lastbuildstate" -f $script:Configuration)
        }
        default {
            return $null
        }
    }
}

function Get-LastBuildStateTime {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectName
    )

    $path = Get-LastBuildStatePath -ProjectName $ProjectName
    if (-not $path -or -not (Test-Path $path)) {
        return $null
    }

    return (Get-Item $path).LastWriteTime
}

function Get-NewerAbiSensitiveInput {
    param(
        [Parameter(Mandatory = $true)][string[]]$Roots,
        [Parameter(Mandatory = $true)][datetime]$ReferenceTime
    )

    foreach ($root in $Roots) {
        if (-not (Test-Path $root)) {
            continue
        }

        $candidate = Get-ChildItem -Path $root -Recurse -File -Include *.h,*.hpp |
            Where-Object { $_.LastWriteTime -gt $ReferenceTime } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if ($candidate) {
            return $candidate
        }
    }

    return $null
}

function Assert-IncrementalBuildSafety {
    if ($script:BuildMode -ne "Incremental") {
        return
    }

    if ($script:AllowUnsafeAbiIncremental) {
        Write-Warning "Unsafe incremental ABI mode enabled; caller accepted mixed-build risk."
        return
    }

    $engineStateTime = Get-LastBuildStateTime -ProjectName "engine"
    $fireClientStateTime = Get-LastBuildStateTime -ProjectName "FireClient"

    if (-not $engineStateTime -or -not $fireClientStateTime) {
        throw "Incremental ABI build is blocked because lastbuildstate is missing. Use the default SafeChain mode."
    }

    $engineHeaderChange = Get-NewerAbiSensitiveInput -Roots @(
        (Join-Path $script:RepoRoot "engine")
    ) -ReferenceTime $engineStateTime

    if ($engineHeaderChange) {
        throw ("Incremental ABI build is blocked. Engine header changed after last engine build: {0} ({1:yyyy-MM-dd HH:mm:ss}). Use Build-MT3-v120.ps1 default SafeChain mode." -f $engineHeaderChange.FullName, $engineHeaderChange.LastWriteTime)
    }

    $fireClientHeaderChange = Get-NewerAbiSensitiveInput -Roots @(
        (Join-Path $script:RepoRoot "engine"),
        (Join-Path $script:ClientRoot "FireClient\\Application")
    ) -ReferenceTime $fireClientStateTime

    if ($fireClientHeaderChange) {
        throw ("Incremental ABI build is blocked. Downstream ABI-sensitive header changed after last FireClient build: {0} ({1:yyyy-MM-dd HH:mm:ss}). Use Build-MT3-v120.ps1 default SafeChain mode." -f $fireClientHeaderChange.FullName, $fireClientHeaderChange.LastWriteTime)
    }
}

function Get-BuildTarget {
    param(
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($script:BuildMode -eq "SafeChain") {
        return "Rebuild"
    }

    if ($script:Clean) {
        return "Rebuild"
    }

    return "Build"
}

function Get-CeguiLibraryName {
    if ($script:EngineProfile -eq "Upgrade30") {
        if ($script:Configuration -eq "Debug") {
            return "cegui-0.7.9_d.lib"
        }
        return "cegui-0.7.9.lib"
    }

    if ($script:Configuration -eq "Debug") {
        return "cegui_d.lib"
    }

    return "cegui.lib"
}

function Get-LinkInputMap {
    $ceguiLibraryName = Get-CeguiLibraryName
    if ($script:EngineProfile -eq "Upgrade30") {
        $map = [ordered]@{
            "platform.lib" = Join-Path $script:RepoRoot ("common\platform\{0}.win32\platform.lib" -f $script:Configuration)
            "ljfm.lib" = Join-Path $script:RepoRoot ("common\ljfm\{0}.win32\ljfm.lib" -f $script:Configuration)
            "cauthc.lib" = Join-Path $script:RepoRoot ("common\cauthc\projects\windows\{0}.win32\cauthc.lib" -f $script:Configuration)
            "engine.lib" = Join-Path $script:RepoRoot ("engine\{0}.win32\engine.lib" -f $script:Configuration)
        }
        $map[$ceguiLibraryName] = Join-Path $script:RepoRoot ("tools\CEGUI-0.7.9-r5\{0}.win32\{1}" -f $script:Configuration, $ceguiLibraryName)
        return $map
    }

    $map = [ordered]@{
        "platform.lib"         = Join-Path $script:RepoRoot ("common\platform\{0}.win32\platform.lib" -f $script:Configuration)
        "ljfm.lib"             = Join-Path $script:RepoRoot ("common\ljfm\{0}.win32\ljfm.lib" -f $script:Configuration)
        "cauthc.lib"           = Join-Path $script:RepoRoot ("common\cauthc\projects\windows\{0}.win32\cauthc.lib" -f $script:Configuration)
        "libBox2D.lib"         = Join-Path $script:RepoRoot ("cocos2d-x-2.2.6\{0}.win32\libBox2D.lib" -f $script:Configuration)
        "liblua.lib"           = Join-Path $script:RepoRoot ("cocos2d-x-2.2.6\{0}.win32\liblua.lib" -f $script:Configuration)
        "lua51.lib"            = Join-Path $script:RepoRoot ("cocos2d-x-2.2.6\{0}.win32\lua51.lib" -f $script:Configuration)
        "libcocos2d.lib"       = Join-Path $script:RepoRoot ("cocos2d-x-2.2.6\{0}.win32\libcocos2d.lib" -f $script:Configuration)
        "libCocosDenshion.lib" = Join-Path $script:RepoRoot ("cocos2d-x-2.2.6\{0}.win32\libCocosDenshion.lib" -f $script:Configuration)
        "libExtensions.lib"    = Join-Path $script:RepoRoot ("cocos2d-x-2.2.6\{0}.win32\libExtensions.lib" -f $script:Configuration)
        "pcre.lib"             = Join-Path $script:RepoRoot ("dependencies\pcre-8.31\{0}.win32\pcre.lib" -f $script:Configuration)
        "silly.lib"            = Join-Path $script:RepoRoot ("dependencies\SILLY-0.1.0\{0}.win32\SILLY.lib" -f $script:Configuration)
        "engine.lib"           = Join-Path $script:RepoRoot ("engine\{0}.win32\engine.lib" -f $script:Configuration)
    }
    $map[$ceguiLibraryName] = Join-Path $script:RepoRoot ("dependencies\cegui\project\win32\{0}.win32\{1}" -f $script:Configuration, $ceguiLibraryName)
    return $map
}

$script:SupportsGetFileHash = $null

function Get-Sha256FileHashValue {
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )

    if ($null -eq $script:SupportsGetFileHash) {
        $script:SupportsGetFileHash = [bool](Get-Command Get-FileHash -ErrorAction SilentlyContinue)
    }

    if ($script:SupportsGetFileHash) {
        return (Get-FileHash -Path $Path -Algorithm SHA256).Hash
    }

    $stream = $null
    $hasher = $null
    try {
        $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
        $hasher = [System.Security.Cryptography.SHA256]::Create()
        $hashBytes = $hasher.ComputeHash($stream)
        return ([System.BitConverter]::ToString($hashBytes)).Replace('-', '')
    }
    finally {
        if ($hasher) {
            $hasher.Dispose()
        }
        if ($stream) {
            $stream.Dispose()
        }
    }
}

function Test-FileContentUpToDate {
    param(
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$DestinationPath
    )

    if (-not (Test-Path $DestinationPath)) {
        return $false
    }

    $srcItem = Get-Item $SourcePath
    $dstItem = Get-Item $DestinationPath
    if ($srcItem.Length -ne $dstItem.Length) {
        return $false
    }

    # Fast path: aligned timestamp + length means no content drift.
    if ($srcItem.LastWriteTimeUtc.Ticks -eq $dstItem.LastWriteTimeUtc.Ticks) {
        return $true
    }

    $srcHash = Get-Sha256FileHashValue -Path $SourcePath
    $dstHash = Get-Sha256FileHashValue -Path $DestinationPath
    return $srcHash -eq $dstHash
}

function Copy-FileIfChanged {
    param(
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$DestinationPath
    )

    if (Test-FileContentUpToDate -SourcePath $SourcePath -DestinationPath $DestinationPath) {
        return $false
    }

    $maxRetries = 6
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            Copy-Item -Path $SourcePath -Destination $DestinationPath -Force

            # Keep timestamp aligned so future syncs can skip hashing quickly.
            $srcItem = Get-Item $SourcePath
            $dstItem = Get-Item $DestinationPath
            $dstItem.LastWriteTimeUtc = $srcItem.LastWriteTimeUtc

            return $true
        }
        catch {
            $message = $_.Exception.Message
            $hresult = $_.Exception.HResult
            $isSharingViolation = (
                ($hresult -eq -2147024864) -or
                ($message -match 'being used by another process') -or
                ($message -match 'cannot access the file')
            )

            if ($isSharingViolation -and $attempt -lt $maxRetries) {
                Start-Sleep -Milliseconds 500
                continue
            }

            if ($isSharingViolation) {
                if (Test-FileContentUpToDate -SourcePath $SourcePath -DestinationPath $DestinationPath) {
                    return $false
                }
                Write-Warning ("runtime-sync skipped locked file: {0} => {1}" -f $SourcePath, $DestinationPath)
                return $false
            }

            throw
        }
    }

    return $false
}

function Resolve-FirstExistingRepoPath {
    param(
        [Parameter(Mandatory = $true)][string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        $candidatePath = $candidate
        if (-not [System.IO.Path]::IsPathRooted($candidatePath)) {
            $candidatePath = Join-Path $script:RepoRoot $candidatePath
        }

        if (Test-Path $candidatePath) {
            return $candidatePath
        }
    }

    return $null
}

function Test-ValidWin32PeFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }

    $stream = $null
    $reader = $null
    try {
        $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $reader = New-Object System.IO.BinaryReader($stream)
        if ($stream.Length -lt 64 -or $reader.ReadUInt16() -ne 0x5A4D) {
            return $false
        }

        $stream.Position = 0x3C
        $peOffset = $reader.ReadInt32()
        if ($peOffset -lt 64 -or $peOffset -gt $stream.Length - 24) {
            return $false
        }

        $stream.Position = $peOffset
        if ($reader.ReadUInt32() -ne 0x00004550) {
            return $false
        }

        # MT3 Win32 uses the x86 v120 ABI; reject compressed blobs and other architectures.
        return $reader.ReadUInt16() -eq 0x014C
    }
    catch {
        return $false
    }
    finally {
        if ($reader) { $reader.Dispose() }
        elseif ($stream) { $stream.Dispose() }
    }
}

function Invoke-Lua51OutputSync {
    $outputDir = Join-Path $script:RepoRoot ("cocos2d-x-2.2.6\{0}.win32" -f $script:Configuration)
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

    $sourceMap = [ordered]@{
        "lua51.lib" = @(
            ("client\resource\bin\{0}\lua51.lib" -f $script:Configuration),
            ("client\MT3Win32App\{0}.win32\lua51.lib" -f $script:Configuration),
            "client\resource\bin\Release\lua51.lib",
            "client\MT3Win32App\Release.win32\lua51.lib"
        )
        "lua51.dll" = @(
            ("client\resource\bin\{0}\lua51.dll" -f $script:Configuration),
            "client\resource\bin\Release\lua51.dll",
            "client\resource\bin\Debug\lua51.dll"
        )
    }

    $copied = New-Object System.Collections.Generic.List[string]
    foreach ($entry in $sourceMap.GetEnumerator()) {
        $fileName = $entry.Key
        $resolvedSource = Resolve-FirstExistingRepoPath -Candidates $entry.Value
        if (-not $resolvedSource) {
            throw ("lua51-output-sync missing source for {0}: {1}" -f $fileName, (($entry.Value) -join "; "))
        }

        $destinationPath = Join-Path $outputDir $fileName
        if (Copy-FileIfChanged -SourcePath $resolvedSource -DestinationPath $destinationPath) {
            $copied.Add($fileName) | Out-Null
        }
    }

    if ($copied.Count -gt 0) {
        Write-Host ("lua51-output-sync copied: {0}" -f (($copied | Sort-Object) -join ", "))
    } else {
        Write-Host "lua51-output-sync up-to-date"
    }
}

function Invoke-MT3Build {
    param(
        [string]$Name,
        [string]$ProjectPath,
        [switch]$DisableProjectReferences
    )

    if (-not (Test-Path $ProjectPath)) {
        throw "Missing project: $ProjectPath"
    }

    $logFile = Join-Path $script:LogDir ("msbuild_{0}_{1}_{2}.log" -f $Name, $script:Configuration, $script:Platform)
    $target = Get-BuildTarget -Name $Name

    $msbuildArgs = "/t:$target /p:Configuration=$script:Configuration /p:Platform=$script:Platform /p:PlatformToolset=v120 /p:VisualStudioVersion=12.0 /nr:false /nologo"
    $cocosRoot = [System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot "cocos2d-x-2.2.6")).TrimEnd("\") + "\"
    $projectFullPath = [System.IO.Path]::GetFullPath($ProjectPath)
    if ($projectFullPath.StartsWith($cocosRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $msbuildArgs += " /p:SolutionDir=$cocosRoot"
    }
    if ($DisableProjectReferences) {
        $msbuildArgs += " /p:BuildProjectReferences=false"
    }
    if ($script:MaxParallelJobs -gt 0) {
        $msbuildArgs += " /m:$script:MaxParallelJobs"
    } else {
        $msbuildArgs += " /m"
    }
    if ($script:MaxCompilerProcesses -gt 0) {
        $msbuildArgs += " /p:CL_MPCount=$script:MaxCompilerProcesses"
    }

    if ($script:VcVars) {
        $basePathCmd = "set `"PATHEXT=.COM;.EXE;.BAT;.CMD`" && set `"PATH=%SystemRoot%\\System32;%SystemRoot%;%PATH%`" && set `"VCTargetsPath=`" && set `"VCINSTALLDIR=`" && set `"VSINSTALLDIR=`" && set `"VisualStudioVersion=`" && set `"WindowsSdkDir=`" && set `"WindowsSDKVersion=`" && "
        $vsToolsCmd = ""
        if ($env:VS120COMNTOOLS) {
            $vsToolsCmd = "set `"VS120COMNTOOLS=$($env:VS120COMNTOOLS)`" && "
        }
        $cmd = "$basePathCmd$vsToolsCmd" + "call `"$script:VcVars`" x86 && `"$script:MSBuild`" `"$ProjectPath`" $msbuildArgs > `"$logFile`" 2>&1"
    } else {
        throw "vcvarsall.bat unresolved. Build-MT3-v120.ps1 requires VS2013 x86 environment."
    }

    $cmdExe = Join-Path $env:SystemRoot "System32\\cmd.exe"
    if (-not (Test-Path $cmdExe)) {
        $cmdExe = "cmd.exe"
    }
    & $cmdExe /c $cmd
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "Build failed: $Name (log: $logFile)"
    }
}

function Invoke-LinkInputSync {
    param(
        [string[]]$RequiredLibraries = @()
    )

    $linkInputDir = Join-Path $script:ClientRoot ("MT3Win32App\\{0}.win32" -f $script:Configuration)
    New-Item -ItemType Directory -Force -Path $linkInputDir | Out-Null

    $requiredSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($name in $RequiredLibraries) {
        if (-not [string]::IsNullOrWhiteSpace($name)) {
            $requiredSet.Add($name) | Out-Null
        }
    }

    $libMap = Get-LinkInputMap

    $copied = New-Object System.Collections.Generic.List[string]
    $removed = New-Object System.Collections.Generic.List[string]
    $missing = New-Object System.Collections.Generic.List[string]
    foreach ($entry in $libMap.GetEnumerator()) {
        $name = $entry.Key
        $src = $entry.Value
        $dst = Join-Path $linkInputDir $name

        if (-not (Test-Path $src)) {
            if (Test-Path $dst) {
                Remove-Item -Path $dst -Force
                $removed.Add($name) | Out-Null
            }
            if ($requiredSet.Contains($name)) {
                $missing.Add(("{0} <= {1}" -f $name, $src)) | Out-Null
            }
            continue
        }

        if (Copy-FileIfChanged -SourcePath $src -DestinationPath $dst) {
            $copied.Add($name) | Out-Null
        }
    }

    if ($copied.Count -gt 0) {
        Write-Host ("link-input-sync copied: {0}" -f (($copied | Sort-Object) -join ", "))
    }
    if ($removed.Count -gt 0) {
        Write-Host ("link-input-sync removed stale: {0}" -f (($removed | Sort-Object) -join ", "))
    }
    if ($copied.Count -eq 0 -and $removed.Count -eq 0) {
        Write-Host "link-input-sync up-to-date"
    }
    if ($missing.Count -gt 0) {
        throw ("link-input-sync missing required libraries: {0}" -f (($missing | Sort-Object) -join "; "))
    }
}

function Ensure-FmodImportLibrary {
    $libPath = Join-Path $script:RepoRoot "cocos2d-x-2.2.6\external\fmod\win32\lib\fmodex_vc.lib"
    if (Test-Path $libPath) {
        return
    }

    $defPath = Join-Path $script:RepoRoot "cocos2d-x-2.2.6\external\fmod\win32\lib\fmodex_vc.def"
    if (-not (Test-Path $defPath)) {
        throw "FMOD import library is missing and fmodex_vc.def was not found: $defPath"
    }

    $libExe = Resolve-Vs120Tool -ToolName "lib.exe"
    $tempDir = Join-Path $script:LogDir "fmod-import-lib"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    $tempLibPath = Join-Path $tempDir "fmodex_vc.lib"

    Write-Host "Generating FMOD import library: $libPath"
    $output = @(& $libExe ("/def:{0}" -f $defPath) "/machine:x86" ("/out:{0}" -f $tempLibPath) 2>&1)
    $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    if ($exitCode -ne 0) {
        $joinedOutput = ($output | Out-String).Trim()
        throw "Failed to generate FMOD import library with $libExe. ExitCode=$exitCode`n$joinedOutput"
    }

    Copy-Item -LiteralPath $tempLibPath -Destination $libPath -Force
}

function Invoke-RuntimeSync {
    if ($script:SkipRuntimeSync) {
        Write-Host "runtime-sync skipped"
        return
    }

    $isDebug = $script:Configuration -match "Debug"
    $configName = if ($isDebug) { "Debug" } else { "Release" }
    $configNameLower = $configName.ToLowerInvariant()
    $runtimeDir = Join-Path $script:ClientRoot ("resource\\bin\\{0}" -f $configName)
    New-Item -ItemType Directory -Force -Path $runtimeDir | Out-Null

    $runtimeMap = [ordered]@{
        "MT3.exe"             = @(
            "client\MT3Win32App\$configName.win32\MT3.exe"
        )
        "libcocos2d.dll"      = @(
            "cocos2d-x-2.2.6\$configName.win32\libcocos2d.dll",
            "client\FireClient\$configName.win32\libcocos2d.dll"
        )
        "libCocosDenshion.dll" = @(
            "cocos2d-x-2.2.6\$configName.win32\libCocosDenshion.dll",
            "client\MT3Win32App\$configName.win32\libCocosDenshion.dll",
            "client\FireClient\$configName.win32\libCocosDenshion.dll"
        )
        "fmodex.dll"          = @(
            $FmodDll,
            "cocos2d-x-2.2.6\external\fmod\win32\bin\fmodex.dll",
            "client\resource\bin\$configNameLower-Archive\fmodex.dll",
            "client\resource\bin\Release\fmodex.dll",
            "client\resource\res1\Update\bin\release\fmodex.dll"
        )
        "libExtensions.dll"   = @(
            "cocos2d-x-2.2.6\$configName.win32\libExtensions.dll"
        )
        "lua51.dll"           = @(
            "cocos2d-x-2.2.6\$configName.win32\lua51.dll"
        )
        "libcurl.dll"         = @(
            "cocos2d-x-2.2.6\$configName.win32\libcurl.dll"
        )
        "libtiff.dll"         = @(
            "cocos2d-x-2.2.6\$configName.win32\libtiff.dll"
        )
        "glew32.dll"          = @(
            "cocos2d-x-2.2.6\$configName.win32\glew32.dll",
            "client\\resource\\tools\\glew32.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\debug\\glew32.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\release\\glew32.dll"
        )
        "pthreadVCE2.dll"     = @(
            "cocos2d-x-2.2.6\$configName.win32\pthreadVCE2.dll",
            "client\\resource\\tools\\pthreadVCE2.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\debug\\pthreadVCE2.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\release\\pthreadVCE2.dll"
        )
        "iconv.dll"           = @(
            "cocos2d-x-2.2.6\$configName.win32\iconv.dll",
            "client\\resource\\tools\\iconv.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\debug\\iconv.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\release\\iconv.dll"
        )
        "zlib1.dll"           = @(
            "cocos2d-x-2.2.6\$configName.win32\zlib1.dll",
            "client\\resource\\tools\\zlib1.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\debug\\zlib1.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\release\\zlib1.dll"
        )
        "msvcr120.dll"        = @(
            "D:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\redist\\x86\\Microsoft.VC120.CRT\\msvcr120.dll",
            "C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\redist\\x86\\Microsoft.VC120.CRT\\msvcr120.dll",
            "client\\resource\\tools\\msvcr120.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\debug\\msvcr120.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\release\\msvcr120.dll"
        )
    }

    if ($script:EngineProfile -eq "Upgrade30") {
        $runtimeMap["websockets.dll"] = @(
            "cocos2d-x-3.0-oh\external\websockets\prebuilt\win32\websockets.dll"
        )
        $runtimeMap["libcurld.dll"] = @(
            "dependencies\third-party-rebuild\curl-7.48.0\build\Win32\VC12\DLL Debug - DLL Windows SSPI\libcurld.dll"
        )
        $runtimeMap["msvcr110.dll"] = @(
            "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\redist\x86\Microsoft.VC110.CRT\msvcr110.dll",
            "D:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\redist\x86\Microsoft.VC110.CRT\msvcr110.dll",
            "C:\Windows\SysWOW64\msvcr110.dll"
        )
    }

    if ($isDebug) {
        $runtimeMap["msvcp120.dll"] = @(
            "D:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\redist\\x86\\Microsoft.VC120.CRT\\msvcp120.dll",
            "C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\redist\\x86\\Microsoft.VC120.CRT\\msvcp120.dll",
            "client\\resource\\tools\\msvcp120.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\debug\\msvcp120.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\release\\msvcp120.dll"
        )
        $runtimeMap["msvcp120d.dll"] = @(
            "tools\\CEImagesetEditor-0.7.1\\bin\\debug\\msvcp120d.dll"
        )
        $runtimeMap["msvcr120d.dll"] = @(
            "tools\\CEImagesetEditor-0.7.1\\bin\\debug\\msvcr120d.dll"
        )
    } else {
        $runtimeMap["msvcp120.dll"] = @(
            "D:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\redist\\x86\\Microsoft.VC120.CRT\\msvcp120.dll",
            "C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\redist\\x86\\Microsoft.VC120.CRT\\msvcp120.dll",
            "client\\resource\\tools\\msvcp120.dll",
            "tools\\CEImagesetEditor-0.7.1\\bin\\release\\msvcp120.dll"
        )
    }

    if ($script:AllowArchiveRuntimeFallback) {
        # Keep zlib ABI aligned with archived runtime when available.
        $runtimeMap["zlib1.dll"] = @(
            "client\\resource\\bin\\$configNameLower-Archive\\zlib1.dll"
        ) + $runtimeMap["zlib1.dll"]
        $runtimeMap["libcurl.dll"] += @(
            "client\\resource\\bin\\$configNameLower-Archive\\libcurl.dll"
        )
    }

    $copied = New-Object System.Collections.Generic.List[string]
    $retained = New-Object System.Collections.Generic.List[string]
    $removed = New-Object System.Collections.Generic.List[string]
    $missing = New-Object System.Collections.Generic.List[string]
    $notSynchronized = New-Object System.Collections.Generic.List[string]

    foreach ($entry in $runtimeMap.GetEnumerator()) {
        $fileName = $entry.Key
        $destPath = Join-Path $runtimeDir $fileName

        $resolvedSource = $null
        foreach ($candidate in $entry.Value) {
            if ([string]::IsNullOrWhiteSpace($candidate)) {
                continue
            }

            $candidatePath = Resolve-RepoPath -BaseRoot $script:RepoRoot -PathValue $candidate
            if (Test-Path $candidatePath) {
                if ($fileName -eq "fmodex.dll" -and -not (Test-ValidWin32PeFile -Path $candidatePath)) {
                    Write-Warning ("runtime-sync ignored invalid Win32 PE candidate: {0}" -f $candidatePath)
                    continue
                }
                $resolvedSource = $candidatePath
                break
            }
        }

        if ($resolvedSource) {
            if (Copy-FileIfChanged -SourcePath $resolvedSource -DestinationPath $destPath) {
                $copied.Add(("{0} <= {1}" -f $fileName, $resolvedSource)) | Out-Null
            }
            else {
                $retained.Add($fileName) | Out-Null
            }
            if (-not (Test-FileContentUpToDate -SourcePath $resolvedSource -DestinationPath $destPath)) {
                $notSynchronized.Add(("{0} <= {1}" -f $fileName, $resolvedSource)) | Out-Null
            }
        } elseif (Test-Path $destPath) {
            if ($fileName -eq "fmodex.dll" -and -not (Test-ValidWin32PeFile -Path $destPath)) {
                Write-Warning ("runtime-sync removed invalid Win32 PE destination: {0}" -f $destPath)
                Remove-Item -LiteralPath $destPath -Force
                $removed.Add($fileName) | Out-Null
                $missing.Add($fileName) | Out-Null
            } else {
                $retained.Add($fileName) | Out-Null
            }
        } else {
            $missing.Add($fileName) | Out-Null
        }
    }

    $obsoleteRuntimeNames = @("sqlite3.dll", "libxml2.dll")
    if ($script:EngineProfile -ne "Upgrade30") {
        $obsoleteRuntimeNames += "websockets.dll"
    }
    foreach ($obsoleteName in $obsoleteRuntimeNames) {
        $obsoletePath = Join-Path $runtimeDir $obsoleteName
        if (Test-Path $obsoletePath) {
            Remove-Item -LiteralPath $obsoletePath -Force
            $removed.Add($obsoleteName) | Out-Null
        }
    }

    if ($copied.Count -gt 0) {
        Write-Host ("runtime-sync copied: {0}" -f $copied.Count)
    }
    if ($removed.Count -gt 0) {
        Write-Host ("runtime-sync removed obsolete: {0}" -f (($removed | Sort-Object) -join ", "))
    }
    if ($copied.Count -eq 0 -and $removed.Count -eq 0 -and $missing.Count -eq 0 -and $notSynchronized.Count -eq 0) {
        Write-Host "runtime-sync up-to-date"
    }
    if ($missing.Count -gt 0) {
        $suffix = if ($script:AllowArchiveRuntimeFallback) { "" } else { " (you can retry with -AllowArchiveRuntimeFallback)" }
        Write-Warning ("runtime-sync missing: {0}{1}" -f (($missing | Sort-Object) -join ", "), $suffix)
    }
    if ($script:EngineProfile -eq "Upgrade30") {
        $requiredRuntimeNames = @("MT3.exe", "websockets.dll", "libcurld.dll", "msvcr110.dll")
        $requiredMissing = @($missing | Where-Object { $requiredRuntimeNames -contains $_ })
        if ($requiredMissing.Count -gt 0) {
            throw ("Upgrade30 runtime-sync missing required dependencies: {0}" -f (($requiredMissing | Sort-Object) -join ", "))
        }
    }
    if ($notSynchronized.Count -gt 0) {
        throw ("runtime-sync failed to update: {0}. Close running MT3.exe or locked files and retry." -f (($notSynchronized | Sort-Object) -join ", "))
    }
}

function Invoke-RuntimeAudit {
    if ($script:SkipRuntimeAudit) {
        Write-Host "runtime-audit skipped"
        return
    }

    $auditScriptPath = Resolve-RepoPath -BaseRoot $script:RepoRoot -PathValue $script:RuntimeAuditScript
    if (-not (Test-Path $auditScriptPath)) {
        throw "Runtime audit script not found: $auditScriptPath"
    }

    $reportPath = Resolve-RepoPath -BaseRoot $script:RepoRoot -PathValue $script:RuntimeAuditReport
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $reportPath) | Out-Null

    $auditParams = @{
        ScanRoots  = $script:RuntimeAuditScanRoots
        ReportPath = $reportPath
    }
    if (-not $script:RuntimeAuditWarnOnly) {
        $auditParams.FailOnIssues = $true
    }

    if (-not $script:ConciseOutput) {
        Write-Host "==> runtime-audit"
    }
    & $auditScriptPath @auditParams
}

function Invoke-StepTimed {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$Action,
        [switch]$SuppressTimingOutput
    )

    if (-not $script:StepTimings) {
        $script:StepTimings = New-Object System.Collections.Generic.List[object]
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    & $Action
    $sw.Stop()

    $seconds = [Math]::Round($sw.Elapsed.TotalSeconds, 2)
    $script:StepTimings.Add([PSCustomObject]@{
        Step = $Name
        Seconds = $seconds
    }) | Out-Null

    if ($SuppressTimingOutput) {
        return
    }

    if ($script:ConciseOutput) {
        Write-Host ("{0} {1:N2}s" -f $Name, $seconds)
    } else {
        Write-Host ("==> {0} done ({1:N2}s)" -f $Name, $seconds)
    }
}

function Invoke-SourceNulScan {
    $scanScriptPath = Resolve-RepoPath -BaseRoot $script:RepoRoot -PathValue "tools\scripts\Test-SourceNoNulBytes.ps1"
    if (-not (Test-Path $scanScriptPath)) {
        throw "Source NUL scan script not found: $scanScriptPath"
    }

    $scanRoots = @(
        "client\FireClient\Application",
        "client\MT3Win32App",
        "client\Build-MT3-v120.ps1",
        "engine",
        "common",
        "tools\scripts"
    )

    if (-not $script:ConciseOutput) {
        Write-Host "==> source-nul-scan"
    }
    & $scanScriptPath -RepoRoot $script:RepoRoot -IncludeRoots $scanRoots
    if ($LASTEXITCODE -ne 0) {
        throw "Source NUL scan failed. Remove embedded NUL bytes before building MT3.exe."
    }
}

Ensure-WindowsEnvDefaults
Clear-InheritedToolchainEnv
$programFilesX86 = Resolve-ProgramFilesX86
if ($programFilesX86) {
    ${env:ProgramFiles(x86)} = $programFilesX86
}

$roots = Resolve-MT3Roots
$RepoRoot = $roots.RepoRoot
$ClientRoot = $roots.ClientRoot

if ($RuntimeAuditScanRoots.Count -eq 0) {
    $RuntimeAuditScanRoots = @("client\resource\bin\$Configuration")
}

$LogDir = Join-Path $RepoRoot "build_logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$MSBuild = Resolve-MSBuild
$VcVars = Resolve-VcVars
if (-not $VcVars) {
    throw "VS120COMNTOOLS/vcvarsall.bat not found. Use tools/scripts/Build-MT3-Exe-Canonical.ps1 or fix VS2013 environment."
}

if (-not $CalledFromCanonical) {
    Write-Warning "External entry point has moved to tools/scripts/Build-MT3-Exe-Canonical.ps1; continuing through the internal build chain."
}

if ($SkipSourceNulScan) {
    if (-not $ConciseOutput) {
        Write-Host "source-nul-scan skipped"
    }
} else {
    Invoke-SourceNulScan
}

Assert-IncrementalBuildSafety

Ensure-FmodImportLibrary

$buildSteps = @(
    @{ Name = "platform"; Path = (Join-Path $RepoRoot "common\platform\platform.win32.vcxproj") },
    @{ Name = "ljfm"; Path = (Join-Path $RepoRoot "common\ljfm\ljfm.win32.vcxproj") },
    @{ Name = "cauthc"; Path = (Join-Path $RepoRoot "common\cauthc\projects\windows\cauthc.win32.vcxproj") },
    @{ Name = "libBox2D"; Path = (Join-Path $RepoRoot "cocos2d-x-2.2.6\external\Box2D\proj.win32\Box2D.vcxproj") },
    @{ Name = "libchipmunk"; Path = (Join-Path $RepoRoot "cocos2d-x-2.2.6\external\chipmunk\proj.win32\chipmunk.vcxproj") },
    @{ Name = "liblua"; Path = (Join-Path $RepoRoot "cocos2d-x-2.2.6\scripting\lua\proj.win32\liblua.vcxproj") },
    @{ Name = "cocos2d"; Path = (Join-Path $RepoRoot "cocos2d-x-2.2.6\cocos2dx\proj.win32\cocos2d.vcxproj") },
    @{ Name = "CocosDenshion"; Path = (Join-Path $RepoRoot "cocos2d-x-2.2.6\CocosDenshion\proj.win32\CocosDenshion.vcxproj") },
    @{ Name = "libExtensions"; Path = (Join-Path $RepoRoot "cocos2d-x-2.2.6\extensions\proj.win32\libExtensions.vcxproj") },
    @{ Name = "CEGUI"; Path = (Join-Path $RepoRoot "dependencies\cegui\project\win32\cegui.win32.vcxproj") },
    @{ Name = "engine"; Path = (Join-Path $RepoRoot "engine\engine.win32.vcxproj") },
    @{ Name = "FireClient"; Path = (Join-Path $ClientRoot "MT3Win32App\FireClient.win32.vcxproj"); DisableProjectReferences = $true }
)

if ($EngineProfile -eq "Upgrade30") {
    $cocosBuildRoot = Join-Path $RepoRoot "cocos2d-x-3.0-oh\build"
    $buildSteps = @(
        @{ Name = "platform"; Path = (Join-Path $RepoRoot "common\platform\platform.win32.vcxproj") },
        @{ Name = "ljfm"; Path = (Join-Path $RepoRoot "common\ljfm\ljfm.win32.vcxproj") },
        @{ Name = "cauthc"; Path = (Join-Path $RepoRoot "common\cauthc\projects\windows\cauthc.win32.vcxproj") },
        @{ Name = "cocos30_kazmath"; Path = (Join-Path $cocosBuildRoot "cocos\math\kazmath\kazmath\kazmath.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_tinyxml2"; Path = (Join-Path $cocosBuildRoot "external\tinyxml2\tinyxml2.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_unzip"; Path = (Join-Path $cocosBuildRoot "external\unzip\unzip.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_xxhash"; Path = (Join-Path $cocosBuildRoot "external\xxhash\xxhash.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_chipmunk"; Path = (Join-Path $cocosBuildRoot "external\chipmunk\src\chipmunk_static.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_box2d"; Path = (Join-Path $cocosBuildRoot "external\Box2D\box2d.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_lua"; Path = (Join-Path $cocosBuildRoot "external\lua\lua\lua.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_tolua"; Path = (Join-Path $cocosBuildRoot "external\lua\tolua\tolua.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_luasocket"; Path = (Join-Path $cocosBuildRoot "external\lua\luasocket\ext_luasocket.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_base"; Path = (Join-Path $cocosBuildRoot "cocos\base\cocosbase.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_core"; Path = (Join-Path $cocosBuildRoot "cocos\2d\cocos2d.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_audio"; Path = (Join-Path $cocosBuildRoot "cocos\audio\audio.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_spine"; Path = (Join-Path $cocosBuildRoot "cocos\editor-support\spine\spine.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_extensions"; Path = (Join-Path $cocosBuildRoot "extensions\extensions.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_network"; Path = (Join-Path $cocosBuildRoot "cocos\network\network.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_sqlite3"; Path = (Join-Path $cocosBuildRoot "external\sqlite3\sqlite3.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_storage"; Path = (Join-Path $cocosBuildRoot "cocos\storage\storage.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_ui"; Path = (Join-Path $cocosBuildRoot "cocos\ui\ui.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_cocostudio"; Path = (Join-Path $cocosBuildRoot "cocos\editor-support\cocostudio\cocostudio.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_cocosbuilder"; Path = (Join-Path $cocosBuildRoot "cocos\editor-support\cocosbuilder\cocosbuilder.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "cocos30_luabinding"; Path = (Join-Path $cocosBuildRoot "cocos\scripting\lua-bindings\luabinding.vcxproj"); DisableProjectReferences = $true },
        @{ Name = "CEGUI079"; Path = (Join-Path $RepoRoot "tools\CEGUI-0.7.9-r5\cegui-0.7.9.win32.vcxproj") },
        @{ Name = "engine"; Path = (Join-Path $RepoRoot "engine\engine.win32.vcxproj") },
        @{ Name = "FireClient"; Path = (Join-Path $ClientRoot "MT3Win32App\FireClient.win32.vcxproj"); DisableProjectReferences = $true }
    )
}

$mt3ProjectPath = Join-Path $ClientRoot "MT3Win32App\\mt3.win32.vcxproj"
$linkInputRequiredLibraries = @(
    "platform.lib",
    "ljfm.lib",
    "cauthc.lib",
    "libBox2D.lib",
    "liblua.lib",
    "lua51.lib",
    "libcocos2d.lib",
    "libCocosDenshion.lib",
    "libExtensions.lib",
    (Get-CeguiLibraryName),
    "pcre.lib",
    "silly.lib",
    "engine.lib"
)
if ($EngineProfile -eq "Upgrade30") {
    $linkInputRequiredLibraries = @(
        "platform.lib",
        "ljfm.lib",
        "cauthc.lib",
        (Get-CeguiLibraryName),
        "engine.lib"
    )
}

if ($ConciseOutput) {
    Write-Host ("MT3 build: {0}|{1} | {2}" -f $Configuration, $Platform, $BuildMode)
} else {
    Write-Host "MT3 build: $Configuration|$Platform"
    Write-Host "Build mode: $BuildMode"
    Write-Host "Engine profile: $EngineProfile"
    Write-Host "Logs: $LogDir"
}
$script:StepTimings = New-Object System.Collections.Generic.List[object]
$allBuildStart = Get-Date

foreach ($step in $buildSteps) {
    $disableProjectReferences = $false
    if ($step.ContainsKey("DisableProjectReferences")) {
        $disableProjectReferences = [bool]$step.DisableProjectReferences
    }
    Invoke-StepTimed -Name ("build:{0}" -f $step.Name) -Action {
        Invoke-MT3Build -Name $step.Name -ProjectPath $step.Path -DisableProjectReferences:$disableProjectReferences
    }
}

if ($EngineProfile -eq "Legacy226") {
    Invoke-StepTimed -Name "lua51-output-sync" -Action {
        Invoke-Lua51OutputSync
    } -SuppressTimingOutput:$ConciseOutput
}
Invoke-StepTimed -Name "link-input-sync" -Action {
    Invoke-LinkInputSync -RequiredLibraries $linkInputRequiredLibraries
} -SuppressTimingOutput:$ConciseOutput
Invoke-StepTimed -Name "build:MT3" -Action {
    Invoke-MT3Build -Name "MT3" -ProjectPath $mt3ProjectPath -DisableProjectReferences
}

Invoke-StepTimed -Name "runtime-sync" -Action {
    Invoke-RuntimeSync
} -SuppressTimingOutput:$ConciseOutput

Invoke-StepTimed -Name "runtime-audit" -Action {
    Invoke-RuntimeAudit
} -SuppressTimingOutput:$ConciseOutput

$allBuildElapsed = (Get-Date) - $allBuildStart
if ($ConciseOutput) {
    Write-Host ("Elapsed: {0:c}" -f $allBuildElapsed)
    Write-Host "Build complete."
} else {
    Write-Host "==> step-timing-summary"
    $script:StepTimings | Format-Table -AutoSize
    Write-Host ("Total elapsed: {0:c}" -f $allBuildElapsed)
    Write-Host "Build complete."
}

if ($CalledFromCanonical) {
    return @{
        Success       = $true
        Configuration = $Configuration
        Platform      = $Platform
        EngineProfile = $EngineProfile
        LogDir        = $LogDir
    }
}

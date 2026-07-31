[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [ValidateSet("Release", "Debug")][string]$Configuration = "Debug",
    [ValidateSet("Win32")][string]$Platform = "Win32",
    [ValidateSet("Legacy226", "Upgrade30")][string]$EngineProfile = "Upgrade30",
    [switch]$ForceRebuild,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRootPath {
    param([string]$InputPath)
    if (-not [string]::IsNullOrWhiteSpace($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
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

    [void]$candidates.Add("C:\Program Files (x86)")
    [void]$candidates.Add("D:\Program Files (x86)")

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        if (Test-Path $candidate) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    throw "ProgramFiles(x86) is not resolvable."
}

function Resolve-VS120ComnTools {
    $candidates = New-Object System.Collections.Generic.List[string]

    if ($env:VS120COMNTOOLS) {
        [void]$candidates.Add($env:VS120COMNTOOLS)
    }

    [void]$candidates.Add("D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\")
    [void]$candidates.Add("C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\")

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        $toolsRoot = [System.IO.Path]::GetFullPath($candidate)
        $vcvars = Join-Path $toolsRoot "..\..\VC\vcvarsall.bat"
        if (Test-Path $vcvars) {
            return $toolsRoot
        }
    }

    throw "VS120COMNTOOLS is not resolvable."
}

function Resolve-MSBuildPath {
    param(
        [Parameter(Mandatory = $true)][string]$ProgramFilesX86
    )

    if ($env:MT3_MSBUILD_PATH -and (Test-Path $env:MT3_MSBUILD_PATH)) {
        return [System.IO.Path]::GetFullPath($env:MT3_MSBUILD_PATH)
    }

    $candidate = Join-Path $ProgramFilesX86 "MSBuild\12.0\Bin\MSBuild.exe"
    if (Test-Path $candidate) {
        return [System.IO.Path]::GetFullPath($candidate)
    }

    throw "MSBuild 12.0 not found."
}

function Resolve-CmdExe {
    $candidate = Join-Path $env:SystemRoot "System32\cmd.exe"
    if (Test-Path $candidate) {
        return $candidate
    }
    return "cmd.exe"
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

function Get-ExistingPath {
    param([string[]]$Candidates)
    foreach ($candidate in $Candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        if (Test-Path $candidate) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }
    return ""
}

function Get-RepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$BaseRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $baseUri = New-Object System.Uri(($BaseRoot.TrimEnd("\") + "\"))
    $pathUri = New-Object System.Uri($PathValue)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace("/", "\")
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

    if ($srcItem.LastWriteTimeUtc.Ticks -eq $dstItem.LastWriteTimeUtc.Ticks) {
        return $true
    }

    $srcHash = (Get-FileHash -Path $SourcePath -Algorithm SHA256).Hash
    $dstHash = (Get-FileHash -Path $DestinationPath -Algorithm SHA256).Hash
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

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $DestinationPath) | Out-Null
    Copy-Item -Path $SourcePath -Destination $DestinationPath -Force

    $srcItem = Get-Item $SourcePath
    $dstItem = Get-Item $DestinationPath
    $dstItem.LastWriteTimeUtc = $srcItem.LastWriteTimeUtc
    return $true
}

function Invoke-MSBuildProject {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRootPath,
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [Parameter(Mandatory = $true)][string]$DisplayName,
        [Parameter(Mandatory = $true)][string]$VcVarsPath,
        [Parameter(Mandatory = $true)][string]$MSBuildPath,
        [Parameter(Mandatory = $true)][string]$ConfigurationName,
        [Parameter(Mandatory = $true)][string]$PlatformName,
        [Parameter(Mandatory = $true)][string]$LogDir,
        [switch]$Rebuild
    )

    if (-not (Test-Path $ProjectPath)) {
        throw "Missing project: $ProjectPath"
    }

    $sanitizedName = ($DisplayName -replace '[^A-Za-z0-9]+', '_').Trim('_').ToLowerInvariant()
    $logPath = Join-Path $LogDir ("ensure-linkdeps_{0}_{1}_{2}.log" -f $sanitizedName, $ConfigurationName.ToLowerInvariant(), $PlatformName.ToLowerInvariant())
    $target = if ($Rebuild) { "Rebuild" } else { "Build" }
    $msbuildArgs = "/t:$target /p:Configuration=$ConfigurationName /p:Platform=$PlatformName /p:PlatformToolset=v120 /p:VisualStudioVersion=12.0 /nr:false /m /nologo"
    $cocosRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRootPath "cocos2d-x-2.2.6")).TrimEnd("\") + "\"
    $projectFullPath = [System.IO.Path]::GetFullPath($ProjectPath)
    if ($projectFullPath.StartsWith($cocosRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $msbuildArgs += " /p:SolutionDir=$cocosRoot"
    }
    $cmd = "call `"$VcVarsPath`" x86 && `"$MSBuildPath`" `"$ProjectPath`" $msbuildArgs > `"$logPath`" 2>&1"

    $proc = Start-Process -FilePath (Resolve-CmdExe) -ArgumentList @("/c", $cmd) -WorkingDirectory $RepoRootPath -Wait -NoNewWindow -PassThru
    if ($proc.ExitCode -ne 0) {
        throw ("Failed to build {0} (log: {1})" -f $DisplayName, $logPath)
    }

    return $logPath
}

function Ensure-LibOggCompatPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRootPath,
        [Parameter(Mandatory = $true)][string]$ConfigurationName,
        [Parameter(Mandatory = $true)][string]$LibOggPath,
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$DetailList
    )

    $compatDir = Resolve-RepoPath -BaseRoot $RepoRootPath -PathValue ("dependencies\libogg-1.3.2\win32\VS2015\Win32\{0}" -f $ConfigurationName)
    $compatPath = Join-Path $compatDir "libogg.lib"
    if (Copy-FileIfChanged -SourcePath $LibOggPath -DestinationPath $compatPath) {
        [void]$DetailList.Add("compat_libogg=" + (Get-RepoRelativePath -BaseRoot $RepoRootPath -PathValue $compatPath))
    }
}

function Resolve-SpecPathCandidates {
    param(
        [Parameter(Mandatory = $true)]$Spec,
        [Parameter(Mandatory = $true)][string]$RepoRootPath
    )

    $resolved = New-Object System.Collections.Generic.List[string]
    foreach ($candidate in @($Spec.SourceCandidates)) {
        [void]$resolved.Add((Resolve-RepoPath -BaseRoot $RepoRootPath -PathValue $candidate))
    }
    return $resolved.ToArray()
}

function Ensure-Upgrade30WebSocketsPackage {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRootPath,
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$DetailList
    )

    $packageDir = Resolve-RepoPath -BaseRoot $RepoRootPath -PathValue "cocos2d-x-3.0-oh\external\websockets\prebuilt\win32"
    $expected = [ordered]@{
        "websockets.dll" = "9E2B30F881E3A6EF2567C21EDC7D322323E4EAFAC730C6272308323544B834E8"
        "websockets.lib" = "E7B8ABC97ABC0DA46D3C592E36915F9A2FBE8DBC807DD89C1258E487AB416AF8"
    }

    $restore = $false
    foreach ($entry in $expected.GetEnumerator()) {
        $path = Join-Path $packageDir $entry.Key
        if (-not (Test-Path -LiteralPath $path) -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $entry.Value) {
            $restore = $true
            break
        }
    }

    if ($restore) {
        $archivePath = Join-Path $env:TEMP "cocos2d-x-v3-deps-1.zip"
        Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/cocos2d/cocos2d-x-3rd-party-libs-bin/archive/v3-deps-1.zip" -OutFile $archivePath
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        New-Item -ItemType Directory -Force -Path $packageDir | Out-Null
        $archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
        try {
            foreach ($fileName in $expected.Keys) {
                $suffix = "/websockets/prebuilt/win32/$fileName"
                $zipEntry = $archive.Entries | Where-Object { $_.FullName.EndsWith($suffix, [System.StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1
                if (-not $zipEntry) {
                    throw "Official cocos2d-x v3-deps-1 package is missing $fileName."
                }
                $input = $zipEntry.Open()
                $output = [System.IO.File]::Create((Join-Path $packageDir $fileName))
                try {
                    $input.CopyTo($output)
                }
                finally {
                    $output.Dispose()
                    $input.Dispose()
                }
            }
        }
        finally {
            $archive.Dispose()
        }
        [void]$DetailList.Add("restored=official cocos2d-x v3-deps-1 WebSocket package")
    }

    foreach ($entry in $expected.GetEnumerator()) {
        $path = Join-Path $packageDir $entry.Key
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Upgrade30 WebSocket dependency is missing: $path"
        }
        $actualHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
        if ($actualHash -ne $entry.Value) {
            throw "Upgrade30 WebSocket dependency hash mismatch: $path"
        }
        [void]$DetailList.Add("verified=" + (Get-RepoRelativePath -BaseRoot $RepoRootPath -PathValue $path) + " sha256=" + $actualHash)
    }
}

function Write-Result {
    param(
        [string]$Status,
        [string]$Summary,
        [string]$Next,
        [System.Collections.Generic.List[string]]$Details,
        [object]$Payload = $null
    )

    if ($Json) {
        $resultObject = [ordered]@{
            status = $Status
            script = "Ensure-MT3-Win32-LinkDeps.ps1"
            summary = $Summary
            next = $Next
            details = @($Details)
            data = $Payload
        }
        $resultObject | ConvertTo-Json -Depth 6 -Compress
        if ($Status -eq "FAIL") {
            exit 1
        }
        exit 0
    }

    Write-Output ("STATUS: " + $Status)
    Write-Output "SCRIPT: Ensure-MT3-Win32-LinkDeps.ps1"
    Write-Output ("SUMMARY: " + $Summary)
    foreach ($detail in $Details) {
        Write-Output ("DETAIL: " + $detail)
    }
    Write-Output ("NEXT: " + $Next)

    if ($Status -eq "FAIL") {
        exit 1
    }
    exit 0
}

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$built = New-Object System.Collections.Generic.List[string]
$staged = New-Object System.Collections.Generic.List[string]
$verified = New-Object System.Collections.Generic.List[string]

$logDir = Resolve-RepoPath -BaseRoot $RepoRoot -PathValue "build_logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

try {
    ${env:ProgramFiles(x86)} = Resolve-ProgramFilesX86
    $env:VS120COMNTOOLS = Resolve-VS120ComnTools
    $msbuildPath = Resolve-MSBuildPath -ProgramFilesX86 ${env:ProgramFiles(x86)}
    [void]$details.Add("msbuild12=" + $msbuildPath)
    [void]$details.Add("vs120tools=" + $env:VS120COMNTOOLS)
    [void]$details.Add("engine_profile=" + $EngineProfile)

    if ($EngineProfile -eq "Upgrade30") {
        Ensure-Upgrade30WebSocketsPackage -RepoRootPath $RepoRoot -DetailList $details
    }

    $stageDirs = @(
        $(Resolve-RepoPath -BaseRoot $RepoRoot -PathValue ("client\MT3Win32App\{0}.win32" -f $Configuration)),
        $(Resolve-RepoPath -BaseRoot $RepoRoot -PathValue ("lib\vs2013\Win32\{0}" -f $Configuration))
    )

    foreach ($dir in $stageDirs) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        [void]$details.Add("stage_dir=" + (Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $dir))
    }

    $specs = @(
        [pscustomobject]@{
            Name = "esUtil.lib"
            ProjectPath = ""
            SourceCandidates = @(
                "cocos2d-x-2.2.6\cocos2dx\platform\third_party\winrt\libraries\vs2013\Win32\esUtil.lib",
                "cocos2d-x-2.2.6\cocos2dx\platform\third_party\winrt\libraries\vs2013\Win32\esUtil.lib"
            )
            StageFileName = ""
            Stage = $false
            BeforeBuild = ""
        }
        [pscustomobject]@{
            Name = "libspeex.lib"
            ProjectPath = "dependencies\speex-1.2rc2\win32\VS2008\libspeex\libspeex.vcxproj"
            SourceCandidates = @("dependencies\speex-1.2rc2\win32\VS2008\libspeex\$Configuration.win32\libspeex.lib")
            StageFileName = "libspeex.lib"
            Stage = $true
            BeforeBuild = ""
        }
        [pscustomobject]@{
            Name = "libogg.lib"
            ProjectPath = "dependencies\libogg-1.3.2\win32\VS2010\libogg_static.vcxproj"
            SourceCandidates = @("dependencies\libogg-1.3.2\win32\VS2010\$Configuration.win32\libogg.lib")
            StageFileName = "libogg.lib"
            Stage = $true
            BeforeBuild = ""
        }
        [pscustomobject]@{
            Name = "libvorbis.lib"
            ProjectPath = "dependencies\libvorbis-1.3.7\win32\VS2010\libvorbis\libvorbis_static.vcxproj"
            SourceCandidates = @("dependencies\libvorbis-1.3.7\win32\VS2010\libvorbis\Win32\$Configuration\libvorbis_static.lib")
            StageFileName = "libvorbis.lib"
            Stage = $true
            BeforeBuild = "libvorbis"
        }
        [pscustomobject]@{
            Name = "freetype.lib"
            ProjectPath = ""
            SourceCandidates = @(
                "cocos2d-x-2.2.6\cocos2dx\platform\third_party\winrt\libraries\vs2013\Win32\$Configuration\freetype.lib",
                "cocos2d-x-2.2.6\cocos2dx\platform\third_party\winrt\libraries\vs2013\Win32\freetype.lib",
                "dependencies\freetype-2.4.12\objs\win32\vc2010\freetype.lib",
                "tools\engine\lib\freetype.lib",
                "tools\CEGUI-0.7.9-r5\dependencies\lib\dynamic\freetype.lib"
            )
            StageFileName = "freetype.lib"
            Stage = $true
            BeforeBuild = ""
        }
        [pscustomobject]@{
            Name = "silly.lib"
            ProjectPath = "dependencies\SILLY-0.1.0\SILLY-0.1.0.win32.vcxproj"
            SourceCandidates = @("dependencies\SILLY-0.1.0\$Configuration.win32\SILLY.lib")
            StageFileName = "silly.lib"
            Stage = $true
            BeforeBuild = ""
        }
    )

    # Upgrade30 links CEGUI 0.7.9 with its bundled FreeType path and has no esUtil dependency.
    if ($Configuration -eq "Debug" -or $EngineProfile -eq "Upgrade30") {
        $specs = @($specs | Where-Object { $_.Name -notin @("esUtil.lib", "freetype.lib") })
    }

    foreach ($spec in $specs) {
        $resolvedSource = Get-ExistingPath -Candidates (Resolve-SpecPathCandidates -Spec $spec -RepoRootPath $RepoRoot)

        $needsBuild = $ForceRebuild.IsPresent
        if (-not $needsBuild -and [string]::IsNullOrWhiteSpace($resolvedSource) -and -not [string]::IsNullOrWhiteSpace($spec.ProjectPath)) {
            $needsBuild = $true
        }

        if ($needsBuild) {
            if ($spec.BeforeBuild -eq "libvorbis") {
                $libOggCompatSource = Get-ExistingPath -Candidates @(
                    $(Resolve-RepoPath -BaseRoot $RepoRoot -PathValue ("dependencies\libogg-1.3.2\win32\VS2010\{0}.win32\libogg.lib" -f $Configuration))
                )
                if ([string]::IsNullOrWhiteSpace($libOggCompatSource)) {
                    $libOggProject = Resolve-RepoPath -BaseRoot $RepoRoot -PathValue "dependencies\libogg-1.3.2\win32\VS2010\libogg_static.vcxproj"
                    $logPath = Invoke-MSBuildProject -RepoRootPath $RepoRoot -ProjectPath $libOggProject -DisplayName "libogg" -VcVarsPath (Join-Path $env:VS120COMNTOOLS "..\..\VC\vcvarsall.bat") -MSBuildPath $msbuildPath -ConfigurationName $Configuration -PlatformName $Platform -LogDir $logDir -Rebuild:$ForceRebuild
                    [void]$built.Add("libogg (log: " + (Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $logPath) + ")")
                    $libOggCompatSource = Get-ExistingPath -Candidates @(
                        $(Resolve-RepoPath -BaseRoot $RepoRoot -PathValue ("dependencies\libogg-1.3.2\win32\VS2010\{0}.win32\libogg.lib" -f $Configuration))
                    )
                }
                if ([string]::IsNullOrWhiteSpace($libOggCompatSource)) {
                    throw "libvorbis prebuild failed because libogg.lib is still missing."
                }
                Ensure-LibOggCompatPath -RepoRootPath $RepoRoot -ConfigurationName $Configuration -LibOggPath $libOggCompatSource -DetailList $details
            }

            if (-not [string]::IsNullOrWhiteSpace($spec.ProjectPath)) {
                $projectPath = Resolve-RepoPath -BaseRoot $RepoRoot -PathValue $spec.ProjectPath
                $logPath = Invoke-MSBuildProject -RepoRootPath $RepoRoot -ProjectPath $projectPath -DisplayName $spec.Name -VcVarsPath (Join-Path $env:VS120COMNTOOLS "..\..\VC\vcvarsall.bat") -MSBuildPath $msbuildPath -ConfigurationName $Configuration -PlatformName $Platform -LogDir $logDir -Rebuild:$ForceRebuild
                [void]$built.Add($spec.Name + " (log: " + (Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $logPath) + ")")
            }

            $resolvedSource = Get-ExistingPath -Candidates (Resolve-SpecPathCandidates -Spec $spec -RepoRootPath $RepoRoot)
        }

        if ([string]::IsNullOrWhiteSpace($resolvedSource)) {
            [void]$failures.Add("missing link dependency source: " + $spec.Name)
            continue
        }

        if ($spec.Stage) {
            foreach ($stageDir in $stageDirs) {
                $destPath = Join-Path $stageDir $spec.StageFileName
                if (Copy-FileIfChanged -SourcePath $resolvedSource -DestinationPath $destPath) {
                    [void]$staged.Add((Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $destPath) + " <= " + (Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $resolvedSource))
                }
            }
        } else {
            [void]$verified.Add($spec.Name + " <= " + (Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $resolvedSource))
        }
    }
}
catch {
    [void]$failures.Add($_.Exception.Message)
}

foreach ($item in $built) {
    [void]$details.Add("built=" + $item)
}
foreach ($item in $staged) {
    [void]$details.Add("staged=" + $item)
}
foreach ($item in $verified) {
    [void]$details.Add("verified=" + $item)
}
foreach ($item in $warnings) {
    [void]$details.Add("warning=" + $item)
}
foreach ($item in $failures) {
    [void]$details.Add("failure=" + $item)
}

$status = "PASS"
$summary = "Win32 link dependencies are ready for MT3.exe build."
$next = "Run powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration $Configuration -EngineProfile $EngineProfile"

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "Win32 link dependency repair failed."
    $next = "Open the newest ensure-linkdeps log under build_logs and fix the first missing third-party library."
} elseif ($built.Count -gt 0 -or $staged.Count -gt 0) {
    $summary = "Win32 link dependencies were repaired and staged for MT3.exe build."
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    configuration = $Configuration
    platform = $Platform
    engine_profile = $EngineProfile
    built = @($built)
    staged = @($staged)
    verified = @($verified)
    warnings = @($warnings)
    failures = @($failures)
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

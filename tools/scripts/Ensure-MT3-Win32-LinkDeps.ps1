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

function Resolve-DumpbinPath {
    param([Parameter(Mandatory = $true)][string]$VS120ToolsPath)

    $candidate = Join-Path $VS120ToolsPath "..\..\VC\bin\dumpbin.exe"
    if (Test-Path -LiteralPath $candidate) {
        return [System.IO.Path]::GetFullPath($candidate)
    }

    throw "VS2013 dumpbin.exe not found."
}

function Resolve-CMakePath {
    if ($env:MT3_CMAKE_PATH -and (Test-Path -LiteralPath $env:MT3_CMAKE_PATH)) {
        return [System.IO.Path]::GetFullPath($env:MT3_CMAKE_PATH)
    }

    $command = Get-Command cmake.exe -ErrorAction SilentlyContinue
    if ($command) {
        return [System.IO.Path]::GetFullPath($command.Source)
    }

    throw "CMake is required to rebuild GLFW 3.0.4."
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

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    $getFileHash = Get-Command Get-FileHash -ErrorAction SilentlyContinue
    if ($getFileHash) {
        return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    }

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        return ([System.BitConverter]::ToString($sha256.ComputeHash($stream)) -replace '-', '').ToUpperInvariant()
    }
    finally {
        $stream.Dispose()
        $sha256.Dispose()
    }
}

function Get-StaticLibraryRuntimeAudit {
    param(
        [Parameter(Mandatory = $true)][string]$LibraryPath,
        [Parameter(Mandatory = $true)][string]$ConfigurationName,
        [Parameter(Mandatory = $true)][string]$DumpbinPath,
        [switch]$RequireExpectedRuntime
    )

    $expectedRuntime = if ($ConfigurationName -eq "Debug") { "MSVCRTD" } else { "MSVCRT" }
    $runtimeNames = @("LIBCMT", "LIBCMTD", "MSVCRT", "MSVCRTD")

    if (-not (Test-Path -LiteralPath $LibraryPath)) {
        return [pscustomobject]@{
            Compatible = $false
            Expected = $expectedRuntime
            Detected = @()
            Effective = "MISSING"
            Reason = "library is missing"
        }
    }

    $output = @(& $DumpbinPath /nologo /directives $LibraryPath 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "dumpbin failed for static library: $LibraryPath"
    }

    $directives = New-Object System.Collections.Generic.List[string]
    $text = $output -join "`n"
    foreach ($match in [regex]::Matches($text, '(?i)(?:/|-)?DEFAULTLIB:"?([^"\s]+)"?')) {
        $name = $match.Groups[1].Value.TrimEnd(',').ToUpperInvariant()
        if (-not $directives.Contains($name)) {
            [void]$directives.Add($name)
        }
    }

    $detectedRuntime = @($directives | Where-Object { $runtimeNames -contains $_ })
    $unexpectedRuntime = @($detectedRuntime | Where-Object { $_ -ne $expectedRuntime })
    $hasExpectedRuntime = $detectedRuntime -contains $expectedRuntime
    $isNeutral = $detectedRuntime.Count -eq 0
    $compatible = $unexpectedRuntime.Count -eq 0 -and ($hasExpectedRuntime -or ($isNeutral -and -not $RequireExpectedRuntime))
    $effectiveRuntime = if ($isNeutral) { "NEUTRAL" } else { $detectedRuntime -join "," }
    $reason = if ($hasExpectedRuntime -and $unexpectedRuntime.Count -eq 0) {
        "runtime matches"
    } elseif ($isNeutral -and -not $RequireExpectedRuntime) {
        "CRT-neutral static library"
    } elseif ($isNeutral) {
        "expected CRT directive is missing"
    } else {
        "detected incompatible CRT directives: " + ($detectedRuntime -join ",")
    }

    return [pscustomobject]@{
        Compatible = $compatible
        Expected = $expectedRuntime
        Detected = $detectedRuntime
        Effective = $effectiveRuntime
        Reason = $reason
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

    if ($srcItem.LastWriteTimeUtc.Ticks -eq $dstItem.LastWriteTimeUtc.Ticks) {
        return $true
    }

    $srcHash = Get-Sha256 -Path $SourcePath
    $dstHash = Get-Sha256 -Path $DestinationPath
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
    $msbuildArgs = @(
        "/t:$target",
        "/p:Configuration=$ConfigurationName",
        "/p:Platform=$PlatformName",
        "/p:PlatformToolset=v120",
        "/p:VisualStudioVersion=12.0",
        "/nr:false",
        "/m",
        "/nologo"
    )
    $cocosRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRootPath "cocos2d-x-2.2.6")).TrimEnd("\") + "\"
    $projectFullPath = [System.IO.Path]::GetFullPath($ProjectPath)
    if ($projectFullPath.StartsWith($cocosRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $msbuildArgs += "/p:SolutionDir=$cocosRoot"
    }
    if (-not (Test-Path -LiteralPath $VcVarsPath)) {
        throw "VS2013 vcvarsall.bat not found: $VcVarsPath"
    }

    $originalLocation = Get-Location
    try {
        Set-Location -LiteralPath $RepoRootPath
        $output = @(& $MSBuildPath $ProjectPath @msbuildArgs 2>&1)
        $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    }
    finally {
        Set-Location -LiteralPath $originalLocation
    }
    $logLines = @($output | ForEach-Object { $_.ToString() })
    [System.IO.File]::WriteAllLines($logPath, $logLines, (New-Object System.Text.UTF8Encoding($false)))
    if ($exitCode -ne 0) {
        throw ("Failed to build {0} (log: {1})" -f $DisplayName, $logPath)
    }

    return $logPath
}

function Invoke-CMakeConfigure {
    param(
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$BuildPath,
        [Parameter(Mandatory = $true)][string]$CMakePath,
        [Parameter(Mandatory = $true)][string]$LogPath
    )

    New-Item -ItemType Directory -Force -Path $BuildPath | Out-Null
    $arguments = '-G "Visual Studio 12 2013" -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF -DGLFW_INSTALL=OFF -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON "' + $SourcePath + '"'
    $errorLogPath = $LogPath + ".error.log"
    $proc = Start-Process -FilePath $CMakePath -ArgumentList $arguments -WorkingDirectory $BuildPath -RedirectStandardOutput $LogPath -RedirectStandardError $errorLogPath -Wait -NoNewWindow -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "Failed to configure GLFW 3.0.4 (logs: $LogPath, $errorLogPath)"
    }
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
        if (-not (Test-Path -LiteralPath $path) -or (Get-Sha256 -Path $path) -ne $entry.Value) {
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
        $actualHash = Get-Sha256 -Path $path
        if ($actualHash -ne $entry.Value) {
            throw "Upgrade30 WebSocket dependency hash mismatch: $path"
        }
        [void]$DetailList.Add("verified=" + (Get-RepoRelativePath -BaseRoot $RepoRootPath -PathValue $path) + " sha256=" + $actualHash)
    }
}

function Ensure-Upgrade30GlfwLibrary {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRootPath,
        [Parameter(Mandatory = $true)][string]$ConfigurationName,
        [Parameter(Mandatory = $true)][string]$PlatformName,
        [Parameter(Mandatory = $true)][string]$VcVarsPath,
        [Parameter(Mandatory = $true)][string]$MSBuildPath,
        [Parameter(Mandatory = $true)][string]$DumpbinPath,
        [Parameter(Mandatory = $true)][string]$LogDir,
        [System.Collections.Generic.List[string]]$DetailList,
        [System.Collections.Generic.List[string]]$BuiltList,
        [System.Collections.Generic.List[string]]$StagedList,
        [switch]$Rebuild
    )

    $version = "3.0.4"
    $archiveHash = "0F3B3CF3646A1AF762F4288CEA7453AADBAF6F0D3FFD7F0E01664EC500AA12BC"
    $headerHash = "914AD3984CAC2E6DD8665E3076D7A9E3C513717145A696A18155B9324ED9F1BB"
    $targetPath = Resolve-RepoPath -BaseRoot $RepoRootPath -PathValue ("cocos2d-x-3.0-oh\build\lib\{0}\glfw3.lib" -f $ConfigurationName)
    $provenancePath = Join-Path (Split-Path -Parent $targetPath) "glfw3.mt3-build.json"
    $targetAudit = Get-StaticLibraryRuntimeAudit -LibraryPath $targetPath -ConfigurationName $ConfigurationName -DumpbinPath $DumpbinPath -RequireExpectedRuntime
    $targetHash = if (Test-Path -LiteralPath $targetPath) { Get-Sha256 -Path $targetPath } else { "" }
    $provenanceValid = $false
    if (Test-Path -LiteralPath $provenancePath) {
        try {
            $provenance = [System.IO.File]::ReadAllText($provenancePath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
            $provenanceValid = $provenance.version -eq $version -and
                $provenance.archive_sha256 -eq $archiveHash -and
                $provenance.header_sha256 -eq $headerHash -and
                $provenance.configuration -eq $ConfigurationName -and
                $provenance.platform_toolset -eq "v120" -and
                $provenance.library_sha256 -eq $targetHash
        }
        catch {
            $provenanceValid = $false
        }
    }
    $needsBuild = $Rebuild.IsPresent -or -not $targetAudit.Compatible -or -not $provenanceValid

    if ($needsBuild) {
        $trackedHeader = Resolve-RepoPath -BaseRoot $RepoRootPath -PathValue "cocos2d-x-3.0-oh\external\glfw3\include\win32\glfw3.h"
        if (-not (Test-Path -LiteralPath $trackedHeader) -or (Get-Sha256 -Path $trackedHeader) -ne $headerHash) {
            throw "Upgrade30 GLFW header is not the pinned GLFW 3.0.4 header: $trackedHeader"
        }

        $archivePath = Join-Path $env:TEMP ("mt3-glfw-{0}.zip" -f $version)
        if (-not (Test-Path -LiteralPath $archivePath) -or (Get-Sha256 -Path $archivePath) -ne $archiveHash) {
            $downloadPath = $archivePath + ".download"
            Invoke-WebRequest -UseBasicParsing -Uri ("https://codeload.github.com/glfw/glfw/zip/refs/tags/{0}" -f $version) -OutFile $downloadPath
            $downloadHash = Get-Sha256 -Path $downloadPath
            if ($downloadHash -ne $archiveHash) {
                throw "GLFW 3.0.4 source archive hash mismatch: $downloadHash"
            }
            Move-Item -LiteralPath $downloadPath -Destination $archivePath -Force
        }

        $cacheRoot = Resolve-RepoPath -BaseRoot $RepoRootPath -PathValue ("tmp\mt3-third-party\glfw-{0}-{1}" -f $version, $archiveHash.Substring(0, 12).ToLowerInvariant())
        $sourceRoot = Join-Path $cacheRoot ("glfw-{0}" -f $version)
        $sourceHeader = Join-Path $sourceRoot "include\GLFW\glfw3.h"
        if (-not (Test-Path -LiteralPath $sourceHeader)) {
            if (Test-Path -LiteralPath $cacheRoot) {
                throw "GLFW source cache is incomplete; remove the generated cache and rerun: $cacheRoot"
            }
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $cacheRoot) | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory($archivePath, $cacheRoot)
        }
        if ((Get-Sha256 -Path $sourceHeader) -ne $headerHash) {
            throw "GLFW source header hash does not match the Upgrade30 header."
        }

        $buildRoot = Resolve-RepoPath -BaseRoot $RepoRootPath -PathValue ("tmp\mt3-third-party\glfw-{0}-v120-build" -f $version)
        $projectPath = Join-Path $buildRoot "src\glfw.vcxproj"
        if (-not (Test-Path -LiteralPath $projectPath)) {
            $cmakePath = Resolve-CMakePath
            $configureLog = Join-Path $LogDir "ensure-linkdeps_glfw_configure.log"
            Invoke-CMakeConfigure -SourcePath $sourceRoot -BuildPath $buildRoot -CMakePath $cmakePath -LogPath $configureLog
            [void]$DetailList.Add("configured=GLFW 3.0.4 v120 (log: " + (Get-RepoRelativePath -BaseRoot $RepoRootPath -PathValue $configureLog) + ")")
        }

        $buildLog = Invoke-MSBuildProject -RepoRootPath $RepoRootPath -ProjectPath $projectPath -DisplayName "glfw3" -VcVarsPath $VcVarsPath -MSBuildPath $MSBuildPath -ConfigurationName $ConfigurationName -PlatformName $PlatformName -LogDir $LogDir -Rebuild
        [void]$BuiltList.Add("glfw3 3.0.4 (log: " + (Get-RepoRelativePath -BaseRoot $RepoRootPath -PathValue $buildLog) + ")")

        $builtPath = Join-Path $buildRoot ("src\{0}\glfw3.lib" -f $ConfigurationName)
        $builtAudit = Get-StaticLibraryRuntimeAudit -LibraryPath $builtPath -ConfigurationName $ConfigurationName -DumpbinPath $DumpbinPath -RequireExpectedRuntime
        if (-not $builtAudit.Compatible) {
            throw ("GLFW {0} CRT audit failed: expected={1}; detected={2}; reason={3}" -f $ConfigurationName, $builtAudit.Expected, ($builtAudit.Detected -join ","), $builtAudit.Reason)
        }

        if (Copy-FileIfChanged -SourcePath $builtPath -DestinationPath $targetPath) {
            [void]$StagedList.Add((Get-RepoRelativePath -BaseRoot $RepoRootPath -PathValue $targetPath) + " <= generated GLFW 3.0.4")
        }
        $targetAudit = Get-StaticLibraryRuntimeAudit -LibraryPath $targetPath -ConfigurationName $ConfigurationName -DumpbinPath $DumpbinPath -RequireExpectedRuntime
        $targetHash = Get-Sha256 -Path $targetPath
        $provenance = [ordered]@{
            version = $version
            source_url = "https://codeload.github.com/glfw/glfw/zip/refs/tags/$version"
            archive_sha256 = $archiveHash
            header_sha256 = $headerHash
            configuration = $ConfigurationName
            platform = $PlatformName
            platform_toolset = "v120"
            runtime = $targetAudit.Expected
            library_sha256 = $targetHash
        }
        $provenanceJson = $provenance | ConvertTo-Json -Depth 3
        [System.IO.File]::WriteAllText($provenancePath, $provenanceJson + "`r`n", (New-Object System.Text.UTF8Encoding($false)))
        $provenanceValid = $true
    }

    if (-not $targetAudit.Compatible -or -not $provenanceValid) {
        throw ("Upgrade30 GLFW {0} CRT audit failed: expected={1}; detected={2}; reason={3}" -f $ConfigurationName, $targetAudit.Expected, ($targetAudit.Detected -join ","), $targetAudit.Reason)
    }

    [void]$DetailList.Add(("verified=glfw3.lib version={0} crt={1} sha256={2} provenance={3}" -f $version, $targetAudit.Expected, $targetHash, (Get-RepoRelativePath -BaseRoot $RepoRootPath -PathValue $provenancePath)))
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
    $vcVarsPath = Join-Path $env:VS120COMNTOOLS "..\..\VC\vcvarsall.bat"
    $dumpbinPath = Resolve-DumpbinPath -VS120ToolsPath $env:VS120COMNTOOLS
    [void]$details.Add("msbuild12=" + $msbuildPath)
    [void]$details.Add("vs120tools=" + $env:VS120COMNTOOLS)
    [void]$details.Add("dumpbin=" + $dumpbinPath)
    [void]$details.Add("engine_profile=" + $EngineProfile)

    if ($EngineProfile -eq "Upgrade30") {
        Ensure-Upgrade30WebSocketsPackage -RepoRootPath $RepoRoot -DetailList $details
        Ensure-Upgrade30GlfwLibrary -RepoRootPath $RepoRoot -ConfigurationName $Configuration -PlatformName $Platform -VcVarsPath $vcVarsPath -MSBuildPath $msbuildPath -DumpbinPath $dumpbinPath -LogDir $logDir -DetailList $details -BuiltList $built -StagedList $staged -Rebuild:$ForceRebuild
    }

    $stageDirs = @(
        $(Resolve-RepoPath -BaseRoot $RepoRoot -PathValue ("client\MT3Win32App\{0}.win32" -f $Configuration)),
        $(Resolve-RepoPath -BaseRoot $RepoRoot -PathValue ("lib\vs2013\Win32\{0}" -f $Configuration))
    )

    foreach ($dir in $stageDirs) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        [void]$details.Add("stage_dir=" + (Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $dir))
    }

    $speexConfiguration = if ($Configuration -eq "Debug") { "Debug_RTL_dll" } else { "Release_RTL_dll" }

    $specs = @(
        [pscustomobject]@{
            Name = "esUtil.lib"
            ProjectPath = ""
            BuildConfiguration = $Configuration
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
            BuildConfiguration = $speexConfiguration
            SourceCandidates = @("dependencies\speex-1.2rc2\win32\VS2008\libspeex\$speexConfiguration\libspeex.lib")
            StageFileName = "libspeex.lib"
            Stage = $true
            BeforeBuild = ""
        }
        [pscustomobject]@{
            Name = "libogg.lib"
            ProjectPath = "dependencies\libogg-1.3.2\win32\VS2010\libogg_static.vcxproj"
            BuildConfiguration = $Configuration
            SourceCandidates = @("dependencies\libogg-1.3.2\win32\VS2010\$Configuration.win32\libogg.lib")
            StageFileName = "libogg.lib"
            Stage = $true
            BeforeBuild = ""
        }
        [pscustomobject]@{
            Name = "libvorbis.lib"
            ProjectPath = "dependencies\libvorbis-1.3.7\win32\VS2010\libvorbis\libvorbis_static.vcxproj"
            BuildConfiguration = $Configuration
            SourceCandidates = @("dependencies\libvorbis-1.3.7\win32\VS2010\libvorbis\Win32\$Configuration\libvorbis_static.lib")
            StageFileName = "libvorbis.lib"
            Stage = $true
            BeforeBuild = "libvorbis"
        }
        [pscustomobject]@{
            Name = "freetype.lib"
            ProjectPath = ""
            BuildConfiguration = $Configuration
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
            BuildConfiguration = $Configuration
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
        $sourceAudit = $null
        if ($spec.Stage -and -not [string]::IsNullOrWhiteSpace($resolvedSource)) {
            $sourceAudit = Get-StaticLibraryRuntimeAudit -LibraryPath $resolvedSource -ConfigurationName $Configuration -DumpbinPath $dumpbinPath
        }

        $needsBuild = $ForceRebuild.IsPresent
        if (-not $needsBuild -and [string]::IsNullOrWhiteSpace($resolvedSource) -and -not [string]::IsNullOrWhiteSpace($spec.ProjectPath)) {
            $needsBuild = $true
        }
        if (-not $needsBuild -and $sourceAudit -and -not $sourceAudit.Compatible) {
            $needsBuild = $true
            [void]$details.Add(("crt_rebuild={0} expected={1} detected={2}" -f $spec.Name, $sourceAudit.Expected, ($sourceAudit.Detected -join ",")))
        }

        if ($needsBuild) {
            if ($spec.BeforeBuild -eq "libvorbis") {
                $libOggCompatSource = Get-ExistingPath -Candidates @(
                    $(Resolve-RepoPath -BaseRoot $RepoRoot -PathValue ("dependencies\libogg-1.3.2\win32\VS2010\{0}.win32\libogg.lib" -f $Configuration))
                )
                if ([string]::IsNullOrWhiteSpace($libOggCompatSource)) {
                    $libOggProject = Resolve-RepoPath -BaseRoot $RepoRoot -PathValue "dependencies\libogg-1.3.2\win32\VS2010\libogg_static.vcxproj"
                    $logPath = Invoke-MSBuildProject -RepoRootPath $RepoRoot -ProjectPath $libOggProject -DisplayName "libogg" -VcVarsPath $vcVarsPath -MSBuildPath $msbuildPath -ConfigurationName $Configuration -PlatformName $Platform -LogDir $logDir -Rebuild:$ForceRebuild
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
                $logPath = Invoke-MSBuildProject -RepoRootPath $RepoRoot -ProjectPath $projectPath -DisplayName $spec.Name -VcVarsPath $vcVarsPath -MSBuildPath $msbuildPath -ConfigurationName $spec.BuildConfiguration -PlatformName $Platform -LogDir $logDir -Rebuild:$ForceRebuild
                [void]$built.Add($spec.Name + " (log: " + (Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $logPath) + ")")
            }

            $resolvedSource = Get-ExistingPath -Candidates (Resolve-SpecPathCandidates -Spec $spec -RepoRootPath $RepoRoot)
        }

        if ([string]::IsNullOrWhiteSpace($resolvedSource)) {
            [void]$failures.Add("missing link dependency source: " + $spec.Name)
            continue
        }

        if ($spec.Stage) {
            $sourceAudit = Get-StaticLibraryRuntimeAudit -LibraryPath $resolvedSource -ConfigurationName $Configuration -DumpbinPath $dumpbinPath
            if (-not $sourceAudit.Compatible) {
                [void]$failures.Add(("static library CRT mismatch: {0}; expected={1}; detected={2}; reason={3}" -f $spec.Name, $sourceAudit.Expected, ($sourceAudit.Detected -join ","), $sourceAudit.Reason))
                continue
            }
            [void]$verified.Add(("{0} crt={1} <= {2}" -f $spec.Name, $sourceAudit.Effective, (Get-RepoRelativePath -BaseRoot $RepoRoot -PathValue $resolvedSource)))
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

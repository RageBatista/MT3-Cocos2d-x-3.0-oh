[CmdletBinding()]
param(
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release",
    [ValidateSet("Win32")]
    [string]$Platform = "Win32",
    [ValidateSet("Build", "Rebuild")]
    [string]$Target = "Rebuild",
    [int]$MaxParallelJobs = 0,
    [switch]$RebuildSupportLibs,
    [switch]$RebuildWxPdb,
    [switch]$SkipToolchainPrecheck,
    [switch]$SkipWxPdbSync,
    [switch]$FailOnWarnings,
    [switch]$RunSmoke,
    [string]$LogDir
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Resolve-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
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

    throw "ProgramFiles(x86) is not resolvable. Install VS2013/MSBuild 12.0 first."
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
        $vcvars = [System.IO.Path]::GetFullPath((Join-Path $toolsRoot "..\..\VC\vcvarsall.bat"))
        if (Test-Path $vcvars) {
            return @{
                ToolsRoot = $toolsRoot
                VcVarsPath = $vcvars
            }
        }
    }

    throw "VS120COMNTOOLS is not resolvable. Expected VS2013 Common7\Tools and VC\vcvarsall.bat."
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

    throw "MSBuild 12.0 not found. Set MT3_MSBUILD_PATH or install VS2013 Build Tools."
}

function Assert-MSBuildVersion12 {
    param(
        [Parameter(Mandatory = $true)][string]$MSBuildPath
    )

    $versionLines = & $MSBuildPath /version /nologo 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to query MSBuild version from $MSBuildPath."
    }

    $raw = ($versionLines | Out-String)
    $versionMatch = [regex]::Match($raw, '(?m)\b\d+\.\d+(?:\.\d+){0,2}\b')
    if (-not $versionMatch.Success) {
        throw "Unable to parse MSBuild version from $MSBuildPath."
    }

    $version = $versionMatch.Value
    if (-not $version.StartsWith("12.")) {
        throw "MSBuild version mismatch: expected 12.x but got $version ($MSBuildPath)."
    }

    Write-Host "MSBuild version: $version"
}

function Invoke-DevCmd {
    param(
        [Parameter(Mandatory = $true)][string]$VcVarsPath,
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string]$FailureMessage
    )

    $cmd = 'call "{0}" x86 && {1}' -f $VcVarsPath, $Command
    & cmd.exe /d /c $cmd
    $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    if ($exitCode -ne 0) {
        throw ("{0} ExitCode={1}" -f $FailureMessage, $exitCode)
    }
}

function Assert-BinLayoutStudioProjectState {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [string]$ProjectName = "BinLayoutStudio",
        [switch]$RequireWxJpeg
    )

    $text = Get-Content -Raw -Encoding UTF8 $ProjectPath
    $blocked = @("cocos2d-2.0-rc2-x-2.0.1", "libSpine.lib")
    foreach ($item in $blocked) {
        if ($text.Contains($item)) {
            throw "$ProjectName still references deprecated engine item: $item"
        }
    }

    if (-not $text.Contains("cocos2d-x-2.2.6")) {
        throw "$ProjectName does not reference cocos2d-x-2.2.6."
    }
    if (-not $text.Contains("libExtensions.lib")) {
        throw "$ProjectName must link libExtensions.lib from cocos2d-x-2.2.6; do not restore libSpine.lib."
    }

    $wxLibPath = "../../wxWidgets-3.0.5/lib/vc_lib"
    $jpegPath = "../../../dependencies/jpeg/prebuilt/win32"
    $pngPath = "../../../dependencies/png/prebuilt/win32"
    $pcrePath = '../../../dependencies/pcre-8.31/$(ConfigurationName).win32'
    $sillyPath = '../../../dependencies/SILLY-0.1.0/$(ConfigurationName).win32'
    $freetypePath = "../../../dependencies/freetype-2.4.12/objs/win32/vc2010"
    $fireClientPath = '../../../client/FireClient/$(ConfigurationName).win32'
    $mt3OutputPath = '../../../client/MT3Win32App/$(ConfigurationName).win32'
    $vs2013ThirdPartyPath = "../../../cocos2d-x-2.2.6/cocos2dx/platform/third_party/winrt/libraries/vs2013/Win32"
    $cocosOutputPath = '../../../cocos2d-x-2.2.6/$(ConfigurationName).win32'
    $pcreIndex = $text.IndexOf($pcrePath, [System.StringComparison]::OrdinalIgnoreCase)
    $sillyIndex = $text.IndexOf($sillyPath, [System.StringComparison]::OrdinalIgnoreCase)
    $freetypeIndex = $text.IndexOf($freetypePath, [System.StringComparison]::OrdinalIgnoreCase)
    $wxLibIndex = $text.IndexOf($wxLibPath, [System.StringComparison]::OrdinalIgnoreCase)
    $fireClientIndex = $text.IndexOf($fireClientPath, [System.StringComparison]::OrdinalIgnoreCase)
    $mt3OutputIndex = $text.IndexOf($mt3OutputPath, [System.StringComparison]::OrdinalIgnoreCase)
    $vs2013ThirdPartyIndex = $text.IndexOf($vs2013ThirdPartyPath, [System.StringComparison]::OrdinalIgnoreCase)
    $jpegIndex = $text.IndexOf($jpegPath, [System.StringComparison]::OrdinalIgnoreCase)
    $pngIndex = $text.IndexOf($pngPath, [System.StringComparison]::OrdinalIgnoreCase)
    $cocosIndex = $text.IndexOf($cocosOutputPath, [System.StringComparison]::OrdinalIgnoreCase)
    if ($pcreIndex -lt 0 -or $sillyIndex -lt 0 -or $freetypeIndex -lt 0 -or $fireClientIndex -lt 0 -or $mt3OutputIndex -lt 0 -or $vs2013ThirdPartyIndex -lt 0 -or $jpegIndex -lt 0 -or $pngIndex -lt 0 -or $cocosIndex -lt 0) {
        throw "BinLayoutStudio library paths are incomplete; expected pcre/SILLY/freetype support libs, client outputs, VS2013 third-party, jpeg/png prebuilt, and cocos2d-x-2.2.6 output paths."
    }
    if ($jpegIndex -gt $cocosIndex -or $pngIndex -gt $cocosIndex) {
        throw "jpeg/png prebuilt library paths must precede cocos2d-x-2.2.6 output path to avoid /MT libpng/libjpeg CRT conflicts."
    }
    if ($RequireWxJpeg) {
        if ($wxLibIndex -lt 0 -or -not $text.Contains("wxjpegd.lib;libjpeg.lib") -or -not $text.Contains("wxjpeg.lib;libjpeg.lib")) {
            throw "$ProjectName must prefer wxjpegd/wxjpeg before fallback libjpeg to avoid Debug auto-LTCG from legacy libjpeg.lib."
        }
        if ($wxLibIndex -gt $jpegIndex) {
            throw "$ProjectName wxWidgets library path must precede legacy jpeg prebuilt path."
        }
    }
    if ($pcreIndex -gt $fireClientIndex -or $pcreIndex -gt $mt3OutputIndex) {
        throw "pcre support library path must precede client output paths to avoid stale /ZI pcre.lib being selected."
    }
    if ($sillyIndex -gt $fireClientIndex -or $sillyIndex -gt $mt3OutputIndex) {
        throw "SILLY support library path must precede client output paths to avoid stale /ZI silly.lib being selected."
    }
    if ($freetypeIndex -gt $fireClientIndex -or $freetypeIndex -gt $mt3OutputIndex) {
        throw "Debug freetype support library path must precede client output paths to avoid stale LTCG/static CRT freetype.lib being selected."
    }
    if ($freetypeIndex -gt $vs2013ThirdPartyIndex) {
        throw "Debug freetype library path must precede VS2013 WinRT third-party libraries to avoid LTCG libpng/freetype codegen failures."
    }
    if ($text -notmatch '<IgnoreSpecificDefaultLibraries>\s*msvcrt\.lib;libcmt\.lib;') {
        throw "Debug link settings must ignore msvcrt.lib/libcmt.lib default directives from legacy image libraries while using /MDd."
    }

    Write-Host "$ProjectName dependency gate: cocos2d-x-2.2.6, libExtensions, support-lib ordering, Debug CRT overrides, and image library ordering are ok."
}

function Get-WxPdbNames {
    param(
        [Parameter(Mandatory = $true)][string]$Configuration
    )

    if ($Configuration -eq "Debug") {
        return @(
            "wxmsw30ud_core.pdb",
            "wxbase30ud.pdb",
            "wxtiffd.pdb",
            "wxjpegd.pdb",
            "wxpngd.pdb",
            "wxzlibd.pdb",
            "wxregexud.pdb",
            "wxexpatd.pdb"
        )
    }

    return @(
        "wxmsw30u_core.pdb",
        "wxbase30u.pdb",
        "wxtiff.pdb",
        "wxjpeg.pdb",
        "wxpng.pdb",
        "wxzlib.pdb",
        "wxregexu.pdb",
        "wxexpat.pdb"
    )
}

function Sync-WxPdbs {
    param(
        [Parameter(Mandatory = $true)][string]$WxLibDir,
        [Parameter(Mandatory = $true)][string]$OutputDir,
        [Parameter(Mandatory = $true)][string]$Configuration
    )

    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

    $missing = New-Object System.Collections.Generic.List[string]
    $copied = 0
    foreach ($pdbName in (Get-WxPdbNames -Configuration $Configuration)) {
        $source = Join-Path $WxLibDir $pdbName
        if (-not (Test-Path $source)) {
            [void]$missing.Add($pdbName)
            continue
        }

        Copy-Item -LiteralPath $source -Destination (Join-Path $OutputDir $pdbName) -Force
        $copied++
    }

    if ($copied -gt 0) {
        Write-Host "wxWidgets PDB sync: copied $copied file(s) to $OutputDir."
    }
    if ($missing.Count -gt 0) {
        Write-Warning ("wxWidgets PDB sync: missing {0} file(s): {1}" -f $missing.Count, ($missing -join ", "))
    }

    return $missing.Count
}

function Invoke-WxWidgetsBuild {
    param(
        [Parameter(Mandatory = $true)][string]$MSBuildPath,
        [Parameter(Mandatory = $true)][string]$VcVarsPath,
        [Parameter(Mandatory = $true)][string]$SolutionPath,
        [Parameter(Mandatory = $true)][string]$Configuration,
        [Parameter(Mandatory = $true)][string]$Platform,
        [Parameter(Mandatory = $true)][string]$LogPath,
        [Parameter(Mandatory = $true)][int]$MaxParallelJobs
    )

    $jobsArg = if ($MaxParallelJobs -gt 0) { "/m:$MaxParallelJobs" } else { "/m" }
    $targets = "wxregex;wxzlib;wxpng;wxjpeg;wxtiff;wxexpat;base;core"
    $command = '"{0}" "{1}" /t:{2} /p:Configuration={3} /p:Platform={4} /p:PlatformToolset=v120 {5} /nologo /v:minimal /fl /flp:"logfile={6};verbosity=normal"' -f `
        $MSBuildPath, $SolutionPath, $targets, $Configuration, $Platform, $jobsArg, $LogPath

    Write-Host "Building wxWidgets static libs/PDBs: $Configuration|$Platform"
    Invoke-DevCmd -VcVarsPath $VcVarsPath -Command $command -FailureMessage "wxWidgets build failed. See log: $LogPath"
}

function Invoke-SupportLibraryBuild {
    param(
        [Parameter(Mandatory = $true)][string]$MSBuildPath,
        [Parameter(Mandatory = $true)][string]$VcVarsPath,
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [Parameter(Mandatory = $true)][string]$Configuration,
        [Parameter(Mandatory = $true)][string]$Platform,
        [Parameter(Mandatory = $true)][string]$LogPath,
        [Parameter(Mandatory = $true)][int]$MaxParallelJobs,
        [Parameter(Mandatory = $true)][string]$DisplayName
    )

    $jobsArg = if ($MaxParallelJobs -gt 0) { "/m:$MaxParallelJobs" } else { "/m" }
    $command = '"{0}" "{1}" /t:Rebuild /p:Configuration={2} /p:Platform={3} /p:PlatformToolset=v120 {4} /nologo /v:minimal /fl /flp:"logfile={5};verbosity=normal"' -f `
        $MSBuildPath, $ProjectPath, $Configuration, $Platform, $jobsArg, $LogPath

    Write-Host "Building support library: $DisplayName ($Configuration|$Platform)"
    Invoke-DevCmd -VcVarsPath $VcVarsPath -Command $command -FailureMessage "$DisplayName build failed. See log: $LogPath"
}

function Invoke-BinLayoutStudioBuild {
    param(
        [Parameter(Mandatory = $true)][string]$MSBuildPath,
        [Parameter(Mandatory = $true)][string]$VcVarsPath,
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [Parameter(Mandatory = $true)][string]$Configuration,
        [Parameter(Mandatory = $true)][string]$Platform,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$LogPath,
        [Parameter(Mandatory = $true)][int]$MaxParallelJobs
    )

    $jobsArg = if ($MaxParallelJobs -gt 0) { "/m:$MaxParallelJobs" } else { "/m" }
    $command = '"{0}" "{1}" /t:{2} /p:Configuration={3} /p:Platform={4} /p:PlatformToolset=v120 {5} /nologo /v:minimal /fl /flp:"logfile={6};verbosity=normal"' -f `
        $MSBuildPath, $ProjectPath, $Target, $Configuration, $Platform, $jobsArg, $LogPath

    Write-Host "Building BinLayoutStudio: $Configuration|$Platform ($Target)"
    Invoke-DevCmd -VcVarsPath $VcVarsPath -Command $command -FailureMessage "BinLayoutStudio build failed. See log: $LogPath"
}

function Test-BuildLog {
    param(
        [Parameter(Mandatory = $true)][string]$LogPath,
        [switch]$FailOnWarnings
    )

    if (-not (Test-Path $LogPath)) {
        throw "Build log is missing: $LogPath"
    }

    $matches = @(Select-String -Path $LogPath -Encoding UTF8 -Pattern 'fatal error| error (C|LNK|MSB)\d+| : error |warning (C|LNK|MSB)\d+')
    $errors = @($matches | Where-Object { $_.Line -match 'fatal error| error (C|LNK|MSB)\d+| : error ' })
    if ($errors.Count -gt 0) {
        $errors | Select-Object -First 20 | ForEach-Object { Write-Host $_.Line }
        throw "Build log contains error lines: $LogPath"
    }

    $autoLtcgDiagnostics = @(Select-String -Path $LogPath -Encoding UTF8 -Pattern 'MSIL \.netmodule|compiled with /GL|restarting link|restart.*LTCG')
    if ($autoLtcgDiagnostics.Count -gt 0) {
        $autoLtcgDiagnostics | Select-Object -First 20 | ForEach-Object { Write-Host $_.Line }
        throw "Build log contains automatic LTCG restart diagnostics. Fix library selection before accepting the build."
    }

    $warnings = @($matches | Where-Object { $_.Line -match 'warning (C|LNK|MSB)\d+' })
    $crtWarnings = @($warnings | Where-Object { $_.Line -match 'warning LNK4098' })
    if ($crtWarnings.Count -gt 0) {
        $crtWarnings | Select-Object -First 20 | ForEach-Object { Write-Host $_.Line }
        throw "Build log contains LNK4098 CRT mismatch. Fix library search order/runtime library first."
    }

    if ($warnings.Count -eq 0) {
        Write-Host "Build log warning gate: clean."
        return
    }

    Write-Host "Build log warning summary:"
    $warnings |
        ForEach-Object {
            if ($_.Line -match 'warning (?<code>(C|LNK|MSB)\d+)') {
                $Matches["code"]
            } else {
                "UNKNOWN"
            }
        } |
        Group-Object |
        Sort-Object Count -Descending |
        ForEach-Object { Write-Host ("  {0}: {1}" -f $_.Name, $_.Count) }

    if ($FailOnWarnings) {
        throw "Build log contains warning lines and -FailOnWarnings was specified: $LogPath"
    }
}

function Assert-Artifacts {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectOutputDir,
        [Parameter(Mandatory = $true)][string]$RuntimeOutputDir
    )

    $projectExe = Join-Path $ProjectOutputDir "BinLayoutStudio.exe"
    $projectPdb = Join-Path $ProjectOutputDir "BinLayoutStudio.pdb"
    $runtimeExe = Join-Path $RuntimeOutputDir "BinLayoutStudio.exe"

    foreach ($path in @($projectExe, $projectPdb, $runtimeExe)) {
        if (-not (Test-Path $path)) {
            throw "Expected artifact is missing: $path"
        }
    }

    Get-Item $projectExe, $projectPdb, $runtimeExe |
        Select-Object FullName, Length, LastWriteTime |
        Format-Table -AutoSize
}

function Invoke-Smoke {
    param(
        [Parameter(Mandatory = $true)][string]$RuntimeExe,
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$LogDir,
        [Parameter(Mandatory = $true)][string]$Configuration
    )

    $sampleCandidates = @(
        "client\resource\bin\Release\petpropertyxilian_mtg_bin.layout",
        "client\resource\bin\release\petpropertyxilian_mtg_bin.layout",
        "client\resource\bin\Release\test.layout",
        "client\resource\bin\release\test.layout"
    )

    $sample = $null
    foreach ($relative in $sampleCandidates) {
        $candidate = Join-Path $RepoRoot $relative
        if (Test-Path $candidate) {
            $sample = [System.IO.Path]::GetFullPath($candidate)
            break
        }
    }

    if (-not $sample) {
        Write-Warning "Smoke test skipped: no known sample .layout file exists under client\resource\bin\Release."
        return
    }

    $stamp = Get-Date -Format "yyyyMMddHHmmss"
    $outPath = Join-Path $LogDir ("BinLayoutStudio.smoke.{0}.{1}.layout" -f $Configuration, $stamp)
    $proc = Start-Process -FilePath $RuntimeExe -ArgumentList @("--bin2xml", $sample, $outPath) -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "BinLayoutStudio smoke test failed. ExitCode=$($proc.ExitCode)"
    }
    if (-not (Test-Path $outPath)) {
        throw "BinLayoutStudio smoke test did not produce output: $outPath"
    }
    $outItem = Get-Item $outPath
    if ($outItem.Length -le 0) {
        throw "BinLayoutStudio smoke test produced an empty output: $outPath"
    }

    Write-Host ("Smoke test: ok ({0}, {1} bytes)" -f $outItem.FullName, $outItem.Length)
}

$repoRoot = Resolve-RepoRoot
if (-not $LogDir) {
    $LogDir = Join-Path $repoRoot "build_logs"
}
$LogDir = [System.IO.Path]::GetFullPath($LogDir)
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$projectPath = Join-Path $repoRoot "dependencies\BinLayoutConvert\BinLayoutStudio\BinLayoutStudio.vcxproj"
$convertProjectPath = Join-Path $repoRoot "dependencies\BinLayoutConvert\BinLayoutConvert\BinLayoutConvert.vcxproj"
$projectOutputDir = Join-Path $repoRoot ("dependencies\BinLayoutConvert\BinLayoutStudio\{0}" -f $Configuration)
$runtimeOutputDir = Join-Path $repoRoot ("client\resource\bin\{0}" -f $Configuration)
$wxSolutionPath = Join-Path $repoRoot "dependencies\wxWidgets-3.0.5\build\msw\wx_vc12.sln"
$wxLibDir = Join-Path $repoRoot "dependencies\wxWidgets-3.0.5\lib\vc_lib"
$pcreProjectPath = Join-Path $repoRoot "dependencies\pcre-8.31\pcre-8.31.win32.vcxproj"
$sillyProjectPath = Join-Path $repoRoot "dependencies\SILLY-0.1.0\SILLY-0.1.0.win32.vcxproj"
$freetypeProjectPath = Join-Path $repoRoot "dependencies\freetype-2.4.12\builds\win32\build_vs2013\freetype.vcxproj"

$programFilesX86 = Resolve-ProgramFilesX86
${env:ProgramFiles(x86)} = $programFilesX86
$vs120 = Resolve-VS120ComnTools
$env:VS120COMNTOOLS = $vs120.ToolsRoot
$msbuildPath = Resolve-MSBuildPath -ProgramFilesX86 $programFilesX86
$env:MT3_MSBUILD_PATH = $msbuildPath

if (-not $SkipToolchainPrecheck) {
    Assert-MSBuildVersion12 -MSBuildPath $msbuildPath
    Write-Host "VS120COMNTOOLS: $env:VS120COMNTOOLS"
} else {
    Write-Host "Skipping toolchain precheck (requested by -SkipToolchainPrecheck)."
}

Assert-BinLayoutStudioProjectState -ProjectPath $projectPath -ProjectName "BinLayoutStudio"
Assert-BinLayoutStudioProjectState -ProjectPath $convertProjectPath -ProjectName "BinLayoutConvert" -RequireWxJpeg

$shouldRebuildSupportLibs = $RebuildSupportLibs -or $FailOnWarnings
if ($shouldRebuildSupportLibs) {
    if (-not (Test-Path $pcreProjectPath)) {
        throw "pcre project is missing: $pcreProjectPath"
    }
    $pcreLog = Join-Path $LogDir ("pcre831.{0}.msbuild.log" -f $Configuration)
    Invoke-SupportLibraryBuild -MSBuildPath $msbuildPath -VcVarsPath $vs120.VcVarsPath -ProjectPath $pcreProjectPath -Configuration $Configuration -Platform $Platform -LogPath $pcreLog -MaxParallelJobs $MaxParallelJobs -DisplayName "pcre-8.31"
    Test-BuildLog -LogPath $pcreLog -FailOnWarnings:$FailOnWarnings

    if (-not (Test-Path $sillyProjectPath)) {
        throw "SILLY project is missing: $sillyProjectPath"
    }
    $sillyLog = Join-Path $LogDir ("SILLY010.{0}.msbuild.log" -f $Configuration)
    Invoke-SupportLibraryBuild -MSBuildPath $msbuildPath -VcVarsPath $vs120.VcVarsPath -ProjectPath $sillyProjectPath -Configuration $Configuration -Platform $Platform -LogPath $sillyLog -MaxParallelJobs $MaxParallelJobs -DisplayName "SILLY 0.1.0"
    Test-BuildLog -LogPath $sillyLog -FailOnWarnings:$FailOnWarnings

    if ($Configuration -eq "Debug") {
        if (-not (Test-Path $freetypeProjectPath)) {
            throw "FreeType VS2013 project is missing: $freetypeProjectPath"
        }
        $freetypeLog = Join-Path $LogDir ("freetype2412.{0}.msbuild.log" -f $Configuration)
        Invoke-SupportLibraryBuild -MSBuildPath $msbuildPath -VcVarsPath $vs120.VcVarsPath -ProjectPath $freetypeProjectPath -Configuration $Configuration -Platform $Platform -LogPath $freetypeLog -MaxParallelJobs $MaxParallelJobs -DisplayName "FreeType 2.4.12"
        Test-BuildLog -LogPath $freetypeLog -FailOnWarnings:$FailOnWarnings
    }
}

if ($RebuildWxPdb) {
    if (-not (Test-Path $wxSolutionPath)) {
        throw "wxWidgets solution is missing: $wxSolutionPath"
    }
    $wxLog = Join-Path $LogDir ("wxWidgets305.{0}.msbuild.log" -f $Configuration)
    Invoke-WxWidgetsBuild -MSBuildPath $msbuildPath -VcVarsPath $vs120.VcVarsPath -SolutionPath $wxSolutionPath -Configuration $Configuration -Platform $Platform -LogPath $wxLog -MaxParallelJobs $MaxParallelJobs
    Test-BuildLog -LogPath $wxLog -FailOnWarnings:$FailOnWarnings
}

if (-not $SkipWxPdbSync) {
    [void](Sync-WxPdbs -WxLibDir $wxLibDir -OutputDir $projectOutputDir -Configuration $Configuration)
}

$buildLog = Join-Path $LogDir ("BinLayoutStudio.{0}.msbuild.log" -f $Configuration)
Invoke-BinLayoutStudioBuild -MSBuildPath $msbuildPath -VcVarsPath $vs120.VcVarsPath -ProjectPath $projectPath -Configuration $Configuration -Platform $Platform -Target $Target -LogPath $buildLog -MaxParallelJobs $MaxParallelJobs
Test-BuildLog -LogPath $buildLog -FailOnWarnings:$FailOnWarnings
Assert-Artifacts -ProjectOutputDir $projectOutputDir -RuntimeOutputDir $runtimeOutputDir

if ($RunSmoke) {
    $runtimeExe = Join-Path $runtimeOutputDir "BinLayoutStudio.exe"
    Invoke-Smoke -RuntimeExe $runtimeExe -RepoRoot $repoRoot -LogDir $LogDir -Configuration $Configuration
}

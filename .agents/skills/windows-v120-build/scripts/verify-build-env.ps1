[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "windows-v120-build"

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$requiredFiles = @(
    "tools/scripts/Build-MT3-Exe-Canonical.ps1",
    "tools/scripts/Build-MT3-FullValidation.ps1",
    "tools/scripts/Ensure-MT3-Win32-LinkDeps.ps1",
    "tools/scripts/Check-v120Toolset.ps1",
    "client/Build-MT3-v120.ps1",
    "client/MT3Win32App/FireClient.win32.vcxproj",
    "client/MT3Win32App/mt3.win32.vcxproj",
    "engine/engine.win32.vcxproj"
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $RepoRoot $relativePath
    if (Test-Path $fullPath -PathType Leaf) {
        [void]$details.Add("repo_file=" + $relativePath)
    } else {
        [void]$failures.Add("missing repo file: " + $relativePath)
    }
}

$projectPaths = @(
    "common/platform/platform.win32.vcxproj",
    "common/ljfm/ljfm.win32.vcxproj",
    "common/lua/lua.win32.vcxproj",
    "common/cauthc/projects/windows/cauthc.win32.vcxproj",
    "cocos2d-x-2.2.6/external/Box2D/proj.win32/Box2D.vcxproj",
    "cocos2d-x-2.2.6/external/chipmunk/proj.win32/chipmunk.vcxproj",
    "cocos2d-x-2.2.6/scripting/lua/proj.win32/liblua.vcxproj",
    "cocos2d-x-2.2.6/cocos2dx/proj.win32/cocos2d.vcxproj",
    "cocos2d-x-2.2.6/CocosDenshion/proj.win32/CocosDenshion.vcxproj",
    "cocos2d-x-2.2.6/extensions/proj.win32/libExtensions.vcxproj",
    "engine/engine.win32.vcxproj",
    "client/MT3Win32App/FireClient.win32.vcxproj",
    "client/MT3Win32App/mt3.win32.vcxproj"
)

function Test-ProjectDeclaresV120 {
    param(
        [Parameter(Mandatory = $true)][string]$Text
    )

    return ($Text -match "<PlatformToolset(?:\s+[^>]*)?>\s*v120\s*</PlatformToolset>")
}

$nonV120 = New-Object System.Collections.Generic.List[string]
foreach ($relativePath in $projectPaths) {
    $fullPath = Join-Path $RepoRoot $relativePath
    if (-not (Test-Path $fullPath -PathType Leaf)) {
        [void]$failures.Add("missing vcxproj: " + $relativePath)
        continue
    }

    $content = Get-Content -Raw -Encoding UTF8 $fullPath
    if (-not (Test-ProjectDeclaresV120 -Text $content)) {
        [void]$nonV120.Add($relativePath)
    }
}

if ($nonV120.Count -gt 0) {
    foreach ($item in $nonV120) {
        [void]$failures.Add("toolset drift: " + $item)
    }
} else {
    [void]$details.Add("mainline_vcxproj=v120")
}

$vs120Candidates = @()
if (-not [string]::IsNullOrWhiteSpace($env:VS120COMNTOOLS)) {
    $vs120Candidates += [System.IO.Path]::GetFullPath((Join-Path $env:VS120COMNTOOLS "..\..\VC\vcvarsall.bat"))
}
$vs120Candidates += @(
    "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat",
    "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
)
$vcvarsPath = Get-ExistingPath -Candidates $vs120Candidates
if ([string]::IsNullOrWhiteSpace($vcvarsPath)) {
    [void]$warnings.Add("vcvarsall.bat not found")
} else {
    [void]$details.Add("vcvarsall=" + $vcvarsPath)
}

$programFilesX86 = @(
    ${env:ProgramFiles(x86)},
    [Environment]::GetFolderPath("ProgramFilesX86"),
    "C:\Program Files (x86)",
    "D:\Program Files (x86)"
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
$msbuildCandidates = foreach ($root in $programFilesX86) {
    Join-Path $root "MSBuild\12.0\Bin\MSBuild.exe"
}
$msbuildPath = Get-ExistingPath -Candidates $msbuildCandidates
if ([string]::IsNullOrWhiteSpace($msbuildPath)) {
    [void]$warnings.Add("MSBuild 12.0 not found")
} else {
    [void]$details.Add("msbuild12=" + $msbuildPath)
}

$checkScript = Join-Path $RepoRoot "tools/scripts/Check-v120Toolset.ps1"
$toolsetExitCode = $null
if (Test-Path $checkScript -PathType Leaf) {
    $toolsetOutput = @(& powershell -NoProfile -ExecutionPolicy Bypass -File $checkScript -RootPath $RepoRoot -Scope Mainline 2>&1)
    $toolsetExitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    [void]$details.Add("check_v120_exit=" + $toolsetExitCode)
    foreach ($line in @($toolsetOutput | Select-Object -First 3)) {
        [void]$details.Add("check_v120=" + ([string]$line).Trim())
    }
    if ($toolsetExitCode -ne 0) {
        [void]$warnings.Add("Check-v120Toolset.ps1 reported issues")
    }
}

$status = "PASS"
$summary = "Windows v120 build entrypoints and mainline toolset look consistent."
$next = "Run powershell -ExecutionPolicy Bypass -File .\\tools\\scripts\\Build-MT3-Exe-Canonical.ps1 -Configuration Release"

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "Windows build repo baseline has drift and should be fixed before building."
    $next = "Fix missing entry files or v120 drift first, then rerun this preflight."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "Windows build repo baseline is valid, but the local toolchain environment still needs attention."
    $next = "Repair VS2013/MSBuild 12.0 visibility, then run the canonical build entry."
}

foreach ($item in $failures) {
    [void]$details.Add("failure=" + $item)
}
foreach ($item in $warnings) {
    [void]$details.Add("warning=" + $item)
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    required_file_count = $requiredFiles.Count
    project_file_count = $projectPaths.Count
    vcvarsall = $vcvarsPath
    msbuild12 = $msbuildPath
    check_v120_exit = $toolsetExitCode
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

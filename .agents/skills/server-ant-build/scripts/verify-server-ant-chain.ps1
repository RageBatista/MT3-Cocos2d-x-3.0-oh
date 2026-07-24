[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "server-ant-build"

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$targetsFound = New-Object System.Collections.Generic.List[string]
$lfsPointerPaths = New-Object System.Collections.Generic.List[string]

$requiredFiles = @(
    "server/server/game_server/build.xml",
    "server/server/game_server/gnet.xml",
    "server/server/game_server/protocol.main.xml",
    "server/server/game_server/gs/build.xml"
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $RepoRoot $relativePath
    if (Test-Path $fullPath -PathType Leaf) {
        [void]$details.Add("repo_file=" + $relativePath)
        if (Test-GitLfsPointer -Path $fullPath) {
            [void]$lfsPointerPaths.Add($relativePath)
            [void]$failures.Add("Git LFS pointer is not materialized: " + $relativePath)
        }
    } else {
        [void]$failures.Add("missing repo file: " + $relativePath)
    }
}

$lfsCheckoutCommand = ""
$lfsPullCommand = ""
if ($lfsPointerPaths.Count -gt 0) {
    $quotedPaths = @($lfsPointerPaths | ForEach-Object { '"' + $_ + '"' })
    $includePaths = [string]::Join(",", @($lfsPointerPaths))
    $lfsPullCommand = 'git lfs pull --include="' + $includePaths + '" --exclude=""'
    $lfsCheckoutCommand = "git lfs checkout -- " + [string]::Join(" ", $quotedPaths)
    [void]$details.Add("lfs_recovery=" + $lfsPullCommand)
    [void]$details.Add("lfs_recovery=" + $lfsCheckoutCommand)
}

$buildXmlPath = Join-Path $RepoRoot "server/server/game_server/build.xml"
if ((Test-Path $buildXmlPath -PathType Leaf) -and -not (Test-GitLfsPointer -Path $buildXmlPath)) {
    $buildXml = Read-TextFileSmart -Path $buildXmlPath
    foreach ($targetName in @("genrpc", "genxdb", "gengbeans", "dist")) {
        if ($buildXml -match ('<target\s+name="' + [regex]::Escape($targetName) + '"')) {
            [void]$targetsFound.Add($targetName)
            [void]$details.Add("target=" + $targetName)
        } else {
            [void]$failures.Add("build.xml missing target: " + $targetName)
        }
    }
}

$javaPath = ""
$javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME")
if (-not [string]::IsNullOrWhiteSpace($javaHome)) {
    $javaCandidate = Join-Path $javaHome "bin\java.exe"
    if (Test-Path $javaCandidate -PathType Leaf) {
        $javaPath = [System.IO.Path]::GetFullPath($javaCandidate)
    }
}
if ([string]::IsNullOrWhiteSpace($javaPath)) {
    $javaPath = Get-CommandSource -Name "java"
}
if ([string]::IsNullOrWhiteSpace($javaPath)) {
    [void]$warnings.Add("java not found")
} else {
    [void]$details.Add("java=" + $javaPath)
    $javaOutput = [string]::Join(" ", (Get-CommandOutput -FilePath $javaPath -Arguments @("-version")))
    if ($javaOutput -match 'version "1\.7' -or $javaOutput -match 'version "1\.8') {
        [void]$details.Add("java_version=ok")
    } else {
        [void]$warnings.Add("java version is not 1.7/1.8")
    }
}

$antPath = Get-CommandSource -Name "ant"
if ([string]::IsNullOrWhiteSpace($antPath)) {
    $antHome = [Environment]::GetEnvironmentVariable("ANT_HOME")
    if (-not [string]::IsNullOrWhiteSpace($antHome)) {
        $antCandidate = Join-Path $antHome "bin\ant.bat"
        if (Test-Path $antCandidate -PathType Leaf) {
            $antPath = [System.IO.Path]::GetFullPath($antCandidate)
        }
    }
}
if ([string]::IsNullOrWhiteSpace($antPath)) {
    [void]$warnings.Add("ant not found")
} else {
    [void]$details.Add("ant=" + $antPath)
}

$status = "PASS"
$summary = "Server Ant entrypoints and generation targets look consistent."
$next = "Use server/server/game_server/build.xml and run genrpc -> genxdb -> gengbeans before full dist when definitions change."

if ($lfsPointerPaths.Count -gt 0) {
    $status = "FAIL"
    $summary = "Server Ant inputs are still Git LFS pointers and cannot be parsed safely."
    $next = $lfsPullCommand + "; " + $lfsCheckoutCommand
} elseif ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "Server build repo baseline has drift and should be fixed before generation or packaging."
    $next = "Restore build.xml targets or missing server entry files, then rerun this preflight."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "Server repo baseline is valid, but the local JDK/Ant environment still needs attention."
    $next = "Repair JDK 1.7/1.8 or Ant visibility, then rerun the intended Ant target."
}

foreach ($item in $failures) {
    [void]$details.Add("failure=" + $item)
}
foreach ($item in $warnings) {
    [void]$details.Add("warning=" + $item)
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    build_xml = $buildXmlPath
    required_file_count = $requiredFiles.Count
    targets_found = $targetsFound.ToArray()
    java = $javaPath
    ant = $antPath
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
    lfs_pointer_paths = $lfsPointerPaths.ToArray()
    lfs_pull_command = $lfsPullCommand
    lfs_checkout_command = $lfsCheckoutCommand
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

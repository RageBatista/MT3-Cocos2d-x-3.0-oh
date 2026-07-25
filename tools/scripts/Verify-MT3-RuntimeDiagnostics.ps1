[CmdletBinding()]
param(
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$failures = New-Object System.Collections.Generic.List[string]
$details = New-Object System.Collections.Generic.List[string]

function Read-Utf8Text {
    param([string]$RelativePath)
    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path $path -PathType Leaf)) {
        $script:failures.Add("missing file: $RelativePath") | Out-Null
        return ""
    }
    return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

function Require-Pattern {
    param(
        [string]$RelativePath,
        [string]$Pattern,
        [string]$Description
    )
    $text = Read-Utf8Text -RelativePath $RelativePath
    if ($text -notmatch $Pattern) {
        $script:failures.Add("$RelativePath missing $Description") | Out-Null
    } else {
        $script:details.Add("$RelativePath has $Description") | Out-Null
    }
}

Require-Pattern "client/FireClient/Application/Framework/GameApplication.cpp" "MT3_RUNTIME_DIAG_ENABLE" "compile-time runtime diag gate"
Require-Pattern "client/FireClient/Application/Framework/GameApplication.cpp" "bRuntimeDiag" "runtime diag config key"
Require-Pattern "client/FireClient/Application/Framework/GameApplication.cpp" "nRuntimeDiagIntervalSec" "runtime diag interval config key"
Require-Pattern "client/FireClient/Application/Framework/GameApplication.cpp" "MT3_DIAG_RENDER" "render diagnostic prefix"
Require-Pattern "client/FireClient/Application/Framework/GameApplication.cpp" "MT3_DIAG_FONT" "font diagnostic prefix"
Require-Pattern "engine/engine/nuanimanager.cpp" "MT3_DIAG_ANI" "animation diagnostic prefix"
Require-Pattern "engine/engine/nuspinemanager.cpp" "MT3_DIAG_SPINE" "spine diagnostic prefix"
Require-Pattern "common/updateengine/UpdateManagerEx.cpp" "MT3_DIAG_UPDATE" "update diagnostic prefix"
Require-Pattern "client/android/common/src/com/locojoy/mini/mt3/FileDownloader.java" "MT3_DIAG_UPDATE" "android downloader diagnostic prefix"

$cfgMatches = Select-String -Path (Join-Path $repoRoot "client/resource/res/cfg/*.ini") -Pattern "bRuntimeDiag\s*=\s*1" -ErrorAction SilentlyContinue
if ($cfgMatches) {
    foreach ($match in $cfgMatches) {
        $failures.Add("runtime diagnostics enabled by default in $($match.Path):$($match.LineNumber)") | Out-Null
    }
} else {
    $details.Add("default cfg keeps runtime diagnostics disabled") | Out-Null
}

$sensitivePattern = "password|passwd|pwd|token|cookie"
$diagFiles = @(
    "client/FireClient/Application/Framework/GameApplication.cpp",
    "engine/engine/nuanimanager.cpp",
    "engine/engine/nuspinemanager.cpp",
    "common/updateengine/UpdateManagerEx.cpp",
    "client/android/common/src/com/locojoy/mini/mt3/FileDownloader.java"
)
foreach ($relativePath in $diagFiles) {
    $path = Join-Path $repoRoot $relativePath
    if (-not (Test-Path $path -PathType Leaf)) {
        continue
    }
    $matches = Select-String -Path $path -Pattern "MT3_DIAG_.*($sensitivePattern)" -CaseSensitive:$false -ErrorAction SilentlyContinue
    foreach ($match in $matches) {
        $failures.Add("sensitive-looking diagnostic log in ${relativePath}:$($match.LineNumber)") | Out-Null
    }
}

$status = if ($failures.Count -eq 0) { "PASS" } else { "FAIL" }
$summary = if ($status -eq "PASS") {
    "Runtime diagnostic probe anchors are present and default-off."
} else {
    "Runtime diagnostic probe verification failed."
}

if ($Json) {
    [pscustomobject][ordered]@{
        status = $status
        summary = $summary
        failures = $failures.ToArray()
        details = $details.ToArray()
    } | ConvertTo-Json -Depth 4
} else {
    "STATUS: $status"
    "SUMMARY: $summary"
    foreach ($item in $details) { "DETAIL: $item" }
    foreach ($item in $failures) { "FAILURE: $item" }
}

if ($status -ne "PASS") {
    exit 1
}

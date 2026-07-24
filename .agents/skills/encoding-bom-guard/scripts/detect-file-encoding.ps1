[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "encoding-bom-guard"

function Resolve-TargetPath {
    param(
        [string]$InputPath,
        [string]$BasePath
    )
    if ([System.IO.Path]::IsPathRooted($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $InputPath))
}

function Get-BomKind {
    param([byte[]]$Bytes)
    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 239 -and $Bytes[1] -eq 187 -and $Bytes[2] -eq 191) {
        return "utf8-bom"
    }
    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 255 -and $Bytes[1] -eq 254) {
        return "utf16le-bom"
    }
    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 254 -and $Bytes[1] -eq 255) {
        return "utf16be-bom"
    }
    return "no-bom"
}

function Test-Utf8Strict {
    param([byte[]]$Bytes)
    $decoder = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        [void]$decoder.GetString($Bytes)
        return $true
    } catch {
        return $false
    }
}

function Test-LikelyUtf16Le {
    param([byte[]]$Bytes)
    if ($Bytes.Length -lt 8) {
        return $false
    }

    $nullCount = 0
    for ($i = 1; $i -lt $Bytes.Length; $i += 2) {
        if ($Bytes[$i] -eq 0) {
            $nullCount++
        }
    }

    $sampleCount = [math]::Max([int]($Bytes.Length / 2), 1)
    return (($nullCount / $sampleCount) -ge 0.3)
}

function Get-LineEndingKind {
    param([byte[]]$Bytes)
    $hasCrLf = $false
    $hasLf = $false
    for ($i = 0; $i -lt $Bytes.Length; $i++) {
        if ($Bytes[$i] -eq 10) {
            if ($i -gt 0 -and $Bytes[$i - 1] -eq 13) {
                $hasCrLf = $true
            } else {
                $hasLf = $true
            }
        }
    }

    if ($hasCrLf -and $hasLf) {
        return "mixed"
    }
    if ($hasCrLf) {
        return "crlf"
    }
    if ($hasLf) {
        return "lf"
    }
    return "none"
}

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$targetPath = Resolve-TargetPath -InputPath $Path -BasePath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path $targetPath -PathType Leaf)) {
    [void]$details.Add("failure=file not found: " + $targetPath)
    Write-Result -Status "FAIL" -Summary "The target file does not exist." -Next "Check the file path and rerun the probe." -Details $details
}

$bytes = [System.IO.File]::ReadAllBytes($targetPath)
$bomKind = Get-BomKind -Bytes $bytes
$lineEnding = Get-LineEndingKind -Bytes $bytes
$encodingCandidate = ""

switch ($bomKind) {
    "utf8-bom" { $encodingCandidate = "utf8-bom" }
    "utf16le-bom" { $encodingCandidate = "utf16le-bom" }
    "utf16be-bom" { $encodingCandidate = "utf16be-bom" }
    default {
        if (Test-Utf8Strict -Bytes $bytes) {
            $encodingCandidate = "utf8-no-bom"
        } elseif (Test-LikelyUtf16Le -Bytes $bytes) {
            $encodingCandidate = "utf16le-no-bom"
        } else {
            $encodingCandidate = "gb18030-or-legacy-ansi"
        }
    }
}

$applyPatchSafe = $encodingCandidate -in @("utf8-bom", "utf8-no-bom")
$status = "PASS"
$summary = "The file is UTF-8 based and safe for apply_patch when BOM and line endings are preserved."
$next = "Keep the original BOM and line ending style stable during edit."

if (-not $applyPatchSafe) {
    $status = "WARN"
    $summary = "The file is not a safe direct apply_patch target and should use script-based write-back with the original encoding."
    $next = "Use an encoding-preserving write path; do not rewrite this file with apply_patch."
}

[void]$details.Add("file=" + $targetPath)
[void]$details.Add("byte_count=" + $bytes.Length)
[void]$details.Add("bom=" + $bomKind)
[void]$details.Add("encoding_candidate=" + $encodingCandidate)
[void]$details.Add("line_ending=" + $lineEnding)
[void]$details.Add("apply_patch_safe=" + $applyPatchSafe.ToString().ToLowerInvariant())

$payload = [pscustomobject][ordered]@{
    file = $targetPath
    byte_count = $bytes.Length
    bom = $bomKind
    encoding_candidate = $encodingCandidate
    line_ending = $lineEnding
    apply_patch_safe = $applyPatchSafe
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

[CmdletBinding()]
param(
    [string]$BinDir = 'client\resource\bin\Release',
    [string[]]$Binaries = @('MT3.exe', 'libcocos2d.dll', 'libCocosDenshion.dll'),
    [string]$OldMarker = 'cocos2d-2.0-rc2-x-2.0.1',
    [string]$NewMarker = 'cocos2d-x 2.2.6',
    [switch]$AllowDebugCrt,
    [switch]$SkipDumpbin,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )
    if ([System.IO.Path]::IsPathRooted($PathValue)) { return [System.IO.Path]::GetFullPath($PathValue) }
    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $PathValue))
}

function Get-DumpbinPath {
    $candidates = @()
    if ($env:VS120COMNTOOLS) { $candidates += (Join-Path $env:VS120COMNTOOLS '..\..\VC\bin\dumpbin.exe') }
    $candidates += 'D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\dumpbin.exe'
    $candidates += 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\dumpbin.exe'
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { return [System.IO.Path]::GetFullPath($candidate) }
    }
    return $null
}

function Count-AsciiPattern {
    param(
        [Parameter(Mandatory = $true)][byte[]]$Bytes,
        [Parameter(Mandatory = $true)][string]$Pattern
    )
    $needle = [System.Text.Encoding]::ASCII.GetBytes($Pattern)
    if ($needle.Length -eq 0 -or $Bytes.Length -lt $needle.Length) { return 0 }
    $count = 0
    for ($i = 0; $i -le $Bytes.Length - $needle.Length; $i++) {
        $matched = $true
        for ($j = 0; $j -lt $needle.Length; $j++) {
            if ($Bytes[$i + $j] -ne $needle[$j]) { $matched = $false; break }
        }
        if ($matched) { $count++ }
    }
    return $count
}

function Get-DirectDependents {
    param(
        [Parameter(Mandatory = $true)][string]$DumpbinPath,
        [Parameter(Mandatory = $true)][string]$BinaryPath
    )
    $out = & $DumpbinPath /dependents $BinaryPath 2>$null | Out-String
    $deps = New-Object System.Collections.Generic.List[string]
    foreach ($line in ($out -split "`r?`n")) {
        if ($line -match '^\s+[A-Za-z0-9_.-]+$') {
            $name = $line.Trim()
            if ($name -ne 'Summary') { $deps.Add($name) | Out-Null }
        }
    }
    return @($deps)
}

function New-Result {
    param(
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)][string]$Summary,
        [Parameter(Mandatory = $true)][object]$Data,
        [string[]]$Failures = @()
    )
    return [PSCustomObject]@{
        status = $Status
        summary = $Summary
        failures = $Failures
        data = $Data
    }
}

$repoRoot = Get-RepoRoot
$resolvedBinDir = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $BinDir
$failures = New-Object System.Collections.Generic.List[string]
$rows = New-Object System.Collections.Generic.List[object]
$dumpbin = $null
if (-not $SkipDumpbin) { $dumpbin = Get-DumpbinPath }
$forbiddenCrt = if ($AllowDebugCrt) {
    @('MSVCR90.dll')
} else {
    @('MSVCP120D.dll', 'MSVCR120D.dll', 'MSVCR90.dll')
}
$totalNewMarkers = 0
$totalOldMarkers = 0

foreach ($binary in $Binaries) {
    $path = Resolve-RepoPath -RepoRoot $resolvedBinDir -PathValue $binary
    if (-not (Test-Path $path)) {
        $failures.Add("Binary not found: $path") | Out-Null
        $rows.Add([PSCustomObject]@{ Name = $binary; Path = $path; Exists = $false; OldMarkerCount = $null; NewMarkerCount = $null; Dependents = @(); ForbiddenCrt = @() }) | Out-Null
        continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($path)
    $oldCount = Count-AsciiPattern -Bytes $bytes -Pattern $OldMarker
    $newCount = Count-AsciiPattern -Bytes $bytes -Pattern $NewMarker
    $totalOldMarkers += $oldCount
    $totalNewMarkers += $newCount
    if ($oldCount -gt 0) { $failures.Add("$binary contains legacy marker '$OldMarker' $oldCount time(s).") | Out-Null }

    $deps = @()
    $badCrt = @()
    if ($dumpbin) {
        $deps = @(Get-DirectDependents -DumpbinPath $dumpbin -BinaryPath $path)
        $badCrt = @($deps | Where-Object { $forbiddenCrt -contains $_ })
        if ($badCrt.Count -gt 0) { $failures.Add("$binary imports forbidden CRT: $($badCrt -join '; ')") | Out-Null }
    }

    $rows.Add([PSCustomObject]@{
        Name = $binary
        Path = $path
        Exists = $true
        Length = (Get-Item -LiteralPath $path).Length
        OldMarkerCount = $oldCount
        NewMarkerCount = $newCount
        Dependents = $deps
        ForbiddenCrt = $badCrt
    }) | Out-Null
}

if ($totalNewMarkers -lt 1) {
    $failures.Add("No binary contains required marker '$NewMarker'.") | Out-Null
}

$data = [PSCustomObject]@{
    RepoRoot = $repoRoot
    BinDir = $resolvedBinDir
    Dumpbin = $dumpbin
    OldMarker = $OldMarker
    NewMarker = $NewMarker
    TotalOldMarkerCount = $totalOldMarkers
    TotalNewMarkerCount = $totalNewMarkers
    ForbiddenCrt = $forbiddenCrt
    Binaries = $rows.ToArray()
}

if ($failures.Count -gt 0) {
    $result = New-Result -Status 'FAIL' -Summary 'Cocos2d-x 2.2.6 binary gate failed.' -Data $data -Failures @($failures)
    if ($Json) { $result | ConvertTo-Json -Depth 8 } else { $result | Format-List }
    exit 1
}

$result = New-Result -Status 'PASS' -Summary 'Cocos2d-x 2.2.6 binary gate passed.' -Data $data
if ($Json) { $result | ConvertTo-Json -Depth 8 } else { $result | Format-List }

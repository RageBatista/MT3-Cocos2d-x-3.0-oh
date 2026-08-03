[CmdletBinding()]
param(
    [string]$RepoRoot = '',
    [string]$UnpackedRoot = '',
    [string]$PatchRoot = '',
    [string]$ReportPath = 'build_logs\resource-ui-gate.json',
    [string]$BaselinePath = 'tools\scripts\baselines\resource-ui-gate-baseline.json',
    [switch]$GenerateBaseline,
    [switch]$NoBaseline,
    [switch]$SkipUnpacked,
    [switch]$SkipPatchLayout,
    [switch]$SkipCeguiBindings,
    [switch]$SkipCeguiResources,
    [switch]$Json
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$scriptDir = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { $PSScriptRoot }

function Resolve-FullPath {
    param([string]$PathValue, [string]$BaseDirectory)
    if ([string]::IsNullOrWhiteSpace($PathValue)) { return '' }
    if ([System.IO.Path]::IsPathRooted($PathValue)) { return [System.IO.Path]::GetFullPath($PathValue) }
    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $PathValue))
}

function Get-PowerShellExe {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) { return $pwsh.Source }
    $powershell = Get-Command powershell -ErrorAction SilentlyContinue
    if ($powershell) { return $powershell.Source }
    throw 'PowerShell executable not found.'
}

function Test-UnpackedRootShape {
    param([string]$PathValue)
    if ([string]::IsNullOrWhiteSpace($PathValue)) { return $false }
    if (-not (Test-Path -LiteralPath $PathValue -PathType Container)) { return $false }
    return (
        ((Test-Path -LiteralPath (Join-Path $PathValue 'unpack_path_manifest.tsv')) -or
            (Test-Path -LiteralPath (Join-Path $PathValue 'unpack_path_manifest.json'))) -and
        (Test-Path -LiteralPath (Join-Path $PathValue 'ui\layouts') -PathType Container) -and
        (Test-Path -LiteralPath (Join-Path $PathValue 'ui\schemes') -PathType Container) -and
        (Test-Path -LiteralPath (Join-Path $PathValue 'table') -PathType Container)
    )
}

function Resolve-UnpackedRoot {
    param([string]$ResolvedRepoRoot, [string]$RequestedRoot)
    if (-not [string]::IsNullOrWhiteSpace($RequestedRoot)) {
        return [pscustomobject][ordered]@{
            path = (Resolve-FullPath -PathValue $RequestedRoot -BaseDirectory $ResolvedRepoRoot)
            discovery = 'explicit'
        }
    }

    $defaultRoot = Join-Path $ResolvedRepoRoot 'unpacked_res'
    if (Test-UnpackedRootShape -PathValue $defaultRoot) {
        return [pscustomobject][ordered]@{ path = $defaultRoot; discovery = 'default' }
    }

    foreach ($candidate in @((Join-Path $ResolvedRepoRoot 'assets\unpacked_res'), (Join-Path $ResolvedRepoRoot 'assets\dev_res'))) {
        if (Test-UnpackedRootShape -PathValue $candidate) {
            return [pscustomobject][ordered]@{ path = $candidate; discovery = ('auto:' + $candidate) }
        }
    }

    return [pscustomobject][ordered]@{ path = $defaultRoot; discovery = 'missing' }
}

function Invoke-GateScript {
    param([string]$ScriptPath, [string[]]$Arguments)
    $exe = Get-PowerShellExe
    $allArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $ScriptPath) + $Arguments
    $output = @()
    $exitCode = 0
    try {
        $output = @(& $exe @allArgs 2>&1)
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
    }
    catch {
        $output = @($_.Exception.Message)
        $exitCode = 1
    }
    $text = ($output | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    $parsed = $null
    try { $parsed = $text | ConvertFrom-Json -ErrorAction Stop } catch { }
    return [pscustomobject][ordered]@{ exit_code = $exitCode; output = $text; json = $parsed }
}

function Add-Check {
    param(
        [System.Collections.Generic.List[object]]$Checks,
        [string]$Name,
        [string]$Status,
        [string]$Summary,
        [string]$Report = '',
        [object]$Data = $null
    )
    $Checks.Add([pscustomobject][ordered]@{
        name = $Name
        status = $Status
        summary = $Summary
        report = $Report
        data = $Data
    }) | Out-Null
}

$resolvedRepoRoot = if ([string]::IsNullOrWhiteSpace($RepoRoot)) { [System.IO.Path]::GetFullPath((Join-Path $scriptDir '..\..')) } else { Resolve-FullPath -PathValue $RepoRoot -BaseDirectory (Get-Location).Path }
$unpackedSelection = Resolve-UnpackedRoot -ResolvedRepoRoot $resolvedRepoRoot -RequestedRoot $UnpackedRoot
$resolvedUnpackedRoot = $unpackedSelection.path
$resolvedPatchRoot = Resolve-FullPath -PathValue $PatchRoot -BaseDirectory $resolvedRepoRoot
$resolvedReportPath = Resolve-FullPath -PathValue $ReportPath -BaseDirectory $resolvedRepoRoot
$resolvedBaselinePath = Resolve-FullPath -PathValue $BaselinePath -BaseDirectory $resolvedRepoRoot
$reportDir = Split-Path -Parent $resolvedReportPath
if ($reportDir -and -not (Test-Path $reportDir)) { [System.IO.Directory]::CreateDirectory($reportDir) | Out-Null }

$checks = New-Object System.Collections.Generic.List[object]

if ($SkipUnpacked) {
    Add-Check -Checks $checks -Name 'unpacked_resources' -Status 'SKIP' -Summary 'Skipped by parameter.'
}
else {
    $script = Join-Path $resolvedRepoRoot 'tools\scripts\Validate-UnpackedResources.ps1'
    $jsonReport = Join-Path $reportDir 'unpacked-res-validation.json'
    $mdReport = Join-Path $reportDir 'unpacked-res-validation.md'
    if (-not (Test-Path $script)) {
        Add-Check -Checks $checks -Name 'unpacked_resources' -Status 'FAIL' -Summary 'Validate-UnpackedResources.ps1 not found.'
    }
    elseif (-not (Test-Path $resolvedUnpackedRoot -PathType Container)) {
        Add-Check -Checks $checks -Name 'unpacked_resources' -Status 'FAIL' -Summary ("Unpacked root not found: {0}. Do not create an empty directory; pass -UnpackedRoot, restore a real unpacked resource artifact, or regenerate with SuperLJFilePackUnpack." -f $resolvedUnpackedRoot)
    }
    else {
        foreach ($oldReport in @($jsonReport, $mdReport)) {
            if (Test-Path -LiteralPath $oldReport) {
                Remove-Item -LiteralPath $oldReport -Force
            }
        }
        $result = Invoke-GateScript -ScriptPath $script -Arguments @('-RootPath', $resolvedUnpackedRoot, '-MarkdownReportPath', $mdReport, '-JsonReportPath', $jsonReport)
        $status = 'FAIL'
        $summary = 'Unable to parse unpacked resource report.'
        $data = $null
        if ($result.exit_code -ne 0) {
            $summary = 'Validate-UnpackedResources.ps1 failed: ' + ($result.output -replace "`r?`n", ' ')
        }
        elseif (Test-Path $jsonReport) {
            $data = Get-Content -Raw -Encoding UTF8 $jsonReport | ConvertFrom-Json
            $status = if ([string]$data.overall_status -eq 'pass') { 'PASS' } else { 'FAIL' }
            $summary = "root=$resolvedUnpackedRoot discovery=$($unpackedSelection.discovery) overall_status=$($data.overall_status) failed_items=$($data.counts.failed_items) missing_final_path_count=$($data.manifest.missing_final_path_count)"
        }
        Add-Check -Checks $checks -Name 'unpacked_resources' -Status $status -Summary $summary -Report $jsonReport -Data $data
    }
}

if ($SkipPatchLayout) {
    Add-Check -Checks $checks -Name 'patch_layout' -Status 'SKIP' -Summary 'Skipped by parameter.'
}
else {
    $script = Join-Path $resolvedRepoRoot '.agents\skills\resource-packaging-pipeline\scripts\verify-patch-layout.ps1'
    if (-not (Test-Path $script)) {
        Add-Check -Checks $checks -Name 'patch_layout' -Status 'WARN' -Summary 'verify-patch-layout.ps1 not found.'
    }
    else {
        $args = @('-RepoRoot', $resolvedRepoRoot, '-Json')
        if (-not [string]::IsNullOrWhiteSpace($resolvedPatchRoot)) { $args += @('-Path', $resolvedPatchRoot) }
        $result = Invoke-GateScript -ScriptPath $script -Arguments $args
        $status = if ($result.exit_code -ne 0) { 'FAIL' } elseif ($result.json -and $result.json.status) { [string]$result.json.status } else { 'WARN' }
        $summary = if ($result.json -and $result.json.summary) { [string]$result.json.summary } else { ('verify-patch-layout output not parsed: ' + ($result.output -replace "`r?`n", ' ')) }
        Add-Check -Checks $checks -Name 'patch_layout' -Status $status -Summary $summary -Data $result.json
    }
}

if ($SkipCeguiBindings) {
    Add-Check -Checks $checks -Name 'cegui_bindings' -Status 'SKIP' -Summary 'Skipped by parameter.'
}
else {
    $script = Join-Path $resolvedRepoRoot '.agents\skills\cegui-layout-integration\scripts\check-cegui-bindings.ps1'
    if (-not (Test-Path $script)) {
        Add-Check -Checks $checks -Name 'cegui_bindings' -Status 'FAIL' -Summary 'check-cegui-bindings.ps1 not found.'
    }
    else {
        $result = Invoke-GateScript -ScriptPath $script -Arguments @('-RepoRoot', $resolvedRepoRoot, '-All', '-DeepScan', '-Json')
        $status = if ($result.exit_code -ne 0) { 'FAIL' } elseif ($result.json -and $result.json.status) { [string]$result.json.status } else { 'WARN' }
        $summary = if ($result.json -and $result.json.summary) { [string]$result.json.summary } else { ('check-cegui-bindings output not parsed: ' + ($result.output -replace "`r?`n", ' ')) }
        Add-Check -Checks $checks -Name 'cegui_bindings' -Status $status -Summary $summary -Data $result.json
    }
}

if ($SkipCeguiResources) {
    Add-Check -Checks $checks -Name 'cegui_resources' -Status 'SKIP' -Summary 'Skipped by parameter.'
}
else {
    $script = Join-Path $resolvedRepoRoot '.agents\skills\cegui-layout-integration\scripts\validate-cegui-resources.ps1'
    if (-not (Test-Path $script)) {
        Add-Check -Checks $checks -Name 'cegui_resources' -Status 'FAIL' -Summary 'validate-cegui-resources.ps1 not found.'
    }
    else {
        $result = Invoke-GateScript -ScriptPath $script -Arguments @('-RepoRoot', $resolvedRepoRoot, '-Json')
        $status = if ($result.exit_code -ne 0) { 'FAIL' } elseif ($result.json -and $result.json.status) { [string]$result.json.status } else { 'WARN' }
        if ($result.json -and $result.json.data -and $result.json.data.failed -gt 0) { $status = 'FAIL' }
        $summary = if ($result.json -and $result.json.summary) { [string]$result.json.summary } else { ('validate-cegui-resources output not parsed: ' + ($result.output -replace "`r?`n", ' ')) }
        Add-Check -Checks $checks -Name 'cegui_resources' -Status $status -Summary $summary -Data $result.json
    }
}

$overall = 'PASS'
$checkArray = @()
$blockerArray = @()
foreach ($check in $checks) {
    $checkArray += $check
    if ($check.status -eq 'FAIL') {
        $overall = 'FAIL'
        $blockerArray += ("{0}: {1}" -f $check.name, $check.summary)
    }
    elseif ($check.status -eq 'WARN' -and $overall -ne 'FAIL') {
        $overall = 'WARN'
    }
}

$preBaselinePayload = [ordered]@{
    generated_at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    repo_root = $resolvedRepoRoot
    status = $overall
    checks = $checkArray
    baseline = $null
    blockers = $blockerArray
}
[System.IO.File]::WriteAllText($resolvedReportPath, (($preBaselinePayload | ConvertTo-Json -Depth 10) + [Environment]::NewLine), $utf8NoBom)

$baselineResult = $null
if (-not $NoBaseline) {
    $baselineScript = Join-Path $resolvedRepoRoot 'tools\scripts\Test-MT3-ResourceUiBaseline.ps1'
    if (Test-Path $baselineScript) {
        $baselineArgs = @('-RepoRoot', $resolvedRepoRoot, '-ReportPath', $resolvedReportPath, '-BaselinePath', $resolvedBaselinePath, '-Json')
        if ($GenerateBaseline) { $baselineArgs += '-GenerateBaseline' }
        $baselineRun = Invoke-GateScript -ScriptPath $baselineScript -Arguments $baselineArgs
        if ($baselineRun.json) {
            $baselineResult = $baselineRun.json
            $blockerArray = @($baselineResult.blockers)
            if ($blockerArray.Count -eq 0) {
                foreach ($check in $checkArray) {
                    if ($check.status -eq 'FAIL' -and @('unpacked_resources', 'cegui_bindings', 'cegui_resources') -contains $check.name) {
                        $check.status = 'WARN'
                        $check.summary = $check.summary + ' (known baseline issue; no new P0-P2 issue detected)'
                    }
                }
                $warnChecks = @($checkArray | Where-Object { $_.status -eq 'WARN' })
                $overall = if ($warnChecks.Count -gt 0) { 'WARN' } else { 'PASS' }
            }
            else {
                $overall = 'FAIL'
            }
        }
        else {
            $overall = 'FAIL'
            $blockerArray = @('resource-ui baseline comparison failed: ' + ($baselineRun.output -replace "`r?`n", ' '))
        }
    }
    else {
        $overall = 'FAIL'
        $blockerArray = @('resource-ui baseline helper not found: ' + $baselineScript)
    }
}

$payload = [ordered]@{
    generated_at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    repo_root = $resolvedRepoRoot
    status = $overall
    checks = $checkArray
    baseline = $baselineResult
    blockers = $blockerArray
}

[System.IO.File]::WriteAllText($resolvedReportPath, (($payload | ConvertTo-Json -Depth 10) + [Environment]::NewLine), $utf8NoBom)

if ($Json) {
    $payload | ConvertTo-Json -Depth 10
}
else {
    Write-Host ("STATUS: {0}" -f $overall)
    foreach ($check in $checks) {
        Write-Host ("CHECK: {0} [{1}] {2}" -f $check.name, $check.status, $check.summary)
    }
    if ($baselineResult) {
        Write-Host ("BASELINE: {0} status={1} current={2} known={3} new={4} increased={5} resolved={6}" -f $resolvedBaselinePath, $baselineResult.baseline_status, $baselineResult.current_issue_count, $baselineResult.known_issue_count, $baselineResult.new_issue_count, $baselineResult.increased_issue_count, $baselineResult.resolved_issue_count)
    }
    foreach ($blocker in $blockerArray) {
        Write-Host ("BLOCKER: {0}" -f $blocker)
    }
    Write-Host ("REPORT: {0}" -f $resolvedReportPath)
}

if ($overall -eq 'FAIL') { exit 1 }
exit 0

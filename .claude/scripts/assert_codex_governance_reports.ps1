[CmdletBinding()]
param(
    [string]$ProjectRoot = "",
    [string]$ReportsRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
} else {
    $ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
}

if ([string]::IsNullOrWhiteSpace($ReportsRoot)) {
    $ReportsRoot = Join-Path $ProjectRoot ".claude\reports"
} elseif (-not [System.IO.Path]::IsPathRooted($ReportsRoot)) {
    $ReportsRoot = Join-Path $ProjectRoot $ReportsRoot
}
$ReportsRoot = [System.IO.Path]::GetFullPath($ReportsRoot)

$definitions = @(
    [pscustomobject]@{ id = "codex-sidecars-validation"; file = "codex-sidecars-validation.json"; status_field = "status" },
    [pscustomobject]@{ id = "codex-guardrails-audit"; file = "codex-guardrails-audit.json"; status_field = "status" },
    [pscustomobject]@{ id = "codex-skills-audit"; file = "codex-skills-audit.json"; status_field = "status" },
    [pscustomobject]@{ id = "codex-skills-workflow-health"; file = "codex-skills-workflow-health.json"; status_field = "status" },
    [pscustomobject]@{ id = "claude-config-audit"; file = "claude-config-audit.json"; status_field = "overall_status" },
    [pscustomobject]@{ id = "quality-gate"; file = "quality-gate-report.json"; status_field = "overall_status" }
)

$checks = New-Object System.Collections.Generic.List[object]
$issues = New-Object System.Collections.Generic.List[string]

foreach ($definition in $definitions) {
    $path = Join-Path $ReportsRoot ([string]$definition.file)
    $status = "MISSING"
    $detail = "report file is missing"

    if (Test-Path -LiteralPath $path -PathType Leaf) {
        try {
            $document = Get-Content -Raw -Encoding UTF8 -LiteralPath $path | ConvertFrom-Json -ErrorAction Stop
            $statusProperty = $document.PSObject.Properties[[string]$definition.status_field]
            if ($null -eq $statusProperty -or [string]::IsNullOrWhiteSpace([string]$statusProperty.Value)) {
                $status = "MISSING_STATUS"
                $detail = "status field is missing: $($definition.status_field)"
            } else {
                $status = ([string]$statusProperty.Value).Trim().ToUpperInvariant()
                $detail = "status field: $($definition.status_field)"
            }
        } catch {
            $status = "INVALID_JSON"
            $detail = $_.Exception.Message
        }
    }

    if ($status -ne "PASS") {
        [void]$issues.Add("$($definition.id): $status ($detail)")
    }
    [void]$checks.Add([pscustomobject][ordered]@{
        id = [string]$definition.id
        file = [string]$definition.file
        status_field = [string]$definition.status_field
        status = $status
        passed = ($status -eq "PASS")
        detail = $detail
    })
}

$overallStatus = if ($issues.Count -eq 0) { "PASS" } else { "FAIL" }
$result = [pscustomobject][ordered]@{
    schema_version = "1.0.0"
    generated_at = [DateTime]::UtcNow.ToString("o")
    project_root = $ProjectRoot
    reports_root = $ReportsRoot
    status = $overallStatus
    reports_checked = $checks.Count
    checks = $checks.ToArray()
    issues = $issues.ToArray()
}

if ($Json) {
    Write-Output ($result | ConvertTo-Json -Depth 8)
} else {
    Write-Output "=== Codex Governance Report Status ==="
    Write-Output "Status: $overallStatus"
    Write-Output "Reports: $($checks.Count)"
    foreach ($check in $checks) {
        Write-Output "- $($check.id): $($check.status) ($($check.file))"
    }
    foreach ($issue in $issues) {
        Write-Output "ISSUE: $issue"
    }
}

if ($issues.Count -gt 0) {
    exit 1
}
exit 0

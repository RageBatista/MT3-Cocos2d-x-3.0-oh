param(
    [string]$RootPath = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)]$Actual,
        [Parameter(Mandatory = $true)]$Expected,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if ($Actual -ne $Expected) {
        throw ("{0}. Expected: {1}; Actual: {2}" -f $Message, $Expected, $Actual)
    }
}

$repoRoot = [System.IO.Path]::GetFullPath($RootPath)
$scriptPath = Join-Path $repoRoot "tools\scripts\Analyze-MT3-Win32Build.ps1"

$output = @(
    & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -RootPath $repoRoot -Json 2>&1
)
$exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }

Assert-Equal -Actual $exitCode -Expected 0 -Message "Analyzer should exit 0 for WARN governance findings"

$jsonText = ($output | Out-String).Trim()
Assert-True -Condition (-not [string]::IsNullOrWhiteSpace($jsonText)) -Message "Analyzer should emit JSON"

$payload = $jsonText | ConvertFrom-Json -ErrorAction Stop

Assert-Equal -Actual ([string]$payload.status) -Expected "WARN" -Message "Current repository should report governance warnings"
Assert-Equal -Actual ([string]$payload.skill) -Expected "windows-v120-build" -Message "Analyzer should identify the build skill domain"
Assert-True -Condition ($payload.details.Count -gt 0) -Message "Analyzer should include human-readable details"
Assert-True -Condition ($payload.data.actual_build_projects.Count -ge 10) -Message "Analyzer should report actual build projects"
Assert-True -Condition ($payload.data.warnings.Count -gt 0) -Message "Analyzer should report warnings"

$joinedWarnings = ($payload.data.warnings | Out-String)
Assert-True -Condition ($joinedWarnings -match "check_v120_list_only") -Message "Analyzer should detect Check-v120 mainline list drift"
Assert-True -Condition ($joinedWarnings -match "legacy_solution_reference") -Message "Analyzer should detect legacy solution references"

Write-Host "STATUS: PASS"
Write-Host "SUMMARY: MT3 Win32 build analysis self-test passed."

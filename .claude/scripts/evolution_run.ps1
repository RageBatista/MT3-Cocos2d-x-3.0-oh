param(
    [string]$ProjectRoot = "",
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
    } else {
        $ProjectRoot = (Get-Location).Path
    }
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $ProjectRoot ".claude\config\evolution.config.json"
}

if (-not (Test-Path $ConfigPath)) {
    throw "Missing evolution config: $ConfigPath"
}

function Resolve-PathSafe {
    param([string]$Base, [string]$Relative)
    if ([System.IO.Path]::IsPathRooted($Relative)) {
        return [System.IO.Path]::GetFullPath($Relative)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Base $Relative))
}

$config = Get-Content -Raw -Encoding UTF8 $ConfigPath | ConvertFrom-Json
$configDir = Split-Path -Parent $ConfigPath

$collectorRel = if ($null -ne $config.automation.collector_script -and -not [string]::IsNullOrWhiteSpace([string]$config.automation.collector_script)) {
    [string]$config.automation.collector_script
} else {
    "../scripts/evolution_collect.ps1"
}
$evolverRel = if ($null -ne $config.automation.evolver_script -and -not [string]::IsNullOrWhiteSpace([string]$config.automation.evolver_script)) {
    [string]$config.automation.evolver_script
} else {
    "../scripts/evolution_evolve.ps1"
}
$backfillRel = if ($null -ne $config.automation.backfill_script -and -not [string]::IsNullOrWhiteSpace([string]$config.automation.backfill_script)) {
    [string]$config.automation.backfill_script
} else {
    "../scripts/evolution_backfill.ps1"
}

$collector = Resolve-PathSafe -Base $configDir -Relative $collectorRel
$evolver = Resolve-PathSafe -Base $configDir -Relative $evolverRel
$backfill = Resolve-PathSafe -Base $configDir -Relative $backfillRel

if (-not (Test-Path $collector)) { throw "Missing collector script: $collector" }
if (-not (Test-Path $evolver)) { throw "Missing evolver script: $evolver" }
if (-not (Test-Path $backfill)) { throw "Missing backfill script: $backfill" }

Write-Output "[1/3] collect observations..."
& $collector -ProjectRoot $ProjectRoot -ConfigPath $ConfigPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output "[2/3] evolve instincts..."
& $evolver -ProjectRoot $ProjectRoot -ConfigPath $ConfigPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output "[3/3] generate skill backfill proposals..."
& $backfill -ProjectRoot $ProjectRoot -ConfigPath $ConfigPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output "Evolution pipeline completed."

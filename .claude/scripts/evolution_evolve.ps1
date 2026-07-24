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

$config = Get-Content -Raw -Encoding UTF8 $ConfigPath | ConvertFrom-Json
if (-not $config.enabled) {
    Write-Output "evolution_evolve: disabled by config"
    exit 0
}

function Resolve-PathSafe {
    param([string]$Base, [string]$Relative)
    if ([System.IO.Path]::IsPathRooted($Relative)) {
        return [System.IO.Path]::GetFullPath($Relative)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Base $Relative))
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Get-RecommendedAction {
    param([string]$Key)
    if ($Key -match "^log\.pattern::LNK$") {
        return "Check PlatformToolset=v120, library link order, and prebuilt ABI compatibility first."
    }
    if ($Key -match "^log\.pattern::MSB$") {
        return "Run toolchain preflight checks (VS2013/MSBuild12/JDK/NDK/Ant) before build."
    }
    if ($Key -match "^log\.pattern::error") {
        return "Use first-error-first policy: inspect the first error with 30 lines of context."
    }
    if ($Key -match "^git\.topic::claude-config$") {
        return "Run mandatory audit on .claude config changes and sync workflow/manifest mappings."
    }
    if ($Key -match "^git\.topic::build$") {
        return "Use platform-specific routing (windows/android/server) for build tasks by default."
    }
    if ($Key -match "^git\.hotfile::") {
        return "Add high-churn files to focused review checklist with regression validation."
    }
    return "Keep as observation rule and wait for more samples before promotion."
}

$configDir = Split-Path -Parent $ConfigPath
$observationsPath = Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.observations_file)
$instinctsPath = Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.instincts_file)
$reportPath = Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.report_file)
$suggestionPath = Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.skill_suggestions_file)

if (-not (Test-Path $observationsPath)) {
    Write-Output "No observations found: $observationsPath"
    exit 0
}

$minSamples = [int]$config.scoring.min_samples
$minConfidence = [double]$config.scoring.min_confidence
$maxRules = [int]$config.scoring.max_rules_per_run

$rows = @()
Get-Content -Encoding UTF8 $observationsPath | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line)) { return }
    try {
        $rows += ($line | ConvertFrom-Json)
    } catch {
        # ignore malformed lines
    }
}

if ($rows.Count -eq 0) {
    Write-Output "No valid observations to evolve."
    exit 0
}

$groups = $rows | Group-Object key
$rules = New-Object System.Collections.Generic.List[object]

foreach ($group in $groups) {
    $key = [string]$group.Name
    $samples = @($group.Group)
    $sampleCount = $samples.Count
    if ($sampleCount -lt $minSamples) { continue }

    $sumValue = 0.0
    foreach ($s in $samples) {
        $v = 0.0
        try { $v = [double]$s.value } catch { $v = 0.0 }
        $sumValue += $v
    }
    $avgValue = if ($sampleCount -gt 0) { [Math]::Round($sumValue / $sampleCount, 2) } else { 0.0 }

    $base = 0.45 + [Math]::Min(0.35, ($sampleCount / 50.0))
    $valueBoost = [Math]::Min(0.15, ($avgValue / 200.0))
    $confidence = [Math]::Round([Math]::Min(0.99, $base + $valueBoost), 2)
    if ($confidence -lt $minConfidence) { continue }

    $rule = [ordered]@{
        id = ("instinct-{0}" -f ($key -replace '[^a-zA-Z0-9\-_.:]+', '-'))
        signal = $key
        samples = $sampleCount
        avg_value = $avgValue
        confidence = $confidence
        recommended_action = Get-RecommendedAction -Key $key
        updated_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
    $rules.Add($rule) | Out-Null
}

$finalRules = @($rules | Sort-Object confidence, samples -Descending | Select-Object -First $maxRules)

$instinctDoc = [ordered]@{
    schema_version = "1.0.0"
    updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    project = "MT3"
    source_observations = $rows.Count
    rules = $finalRules
}

Write-Utf8NoBom -Path $instinctsPath -Content ($instinctDoc | ConvertTo-Json -Depth 20)

$md = @()
$md += "# Evolution Report"
$md += ""
$md += "- Time: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
$md += "- Observations: $($rows.Count)"
$md += "- Candidate Rules: $($finalRules.Count)"
$md += "- Min Samples: $minSamples"
$md += "- Min Confidence: $minConfidence"
$md += ""
if ($finalRules.Count -eq 0) {
    $md += "No rules reached threshold in this run. Continue collecting observations."
} else {
    $md += "## Top Rules"
    foreach ($rule in $finalRules) {
        $md += "- **$($rule.signal)** | confidence=$($rule.confidence) | samples=$($rule.samples) | action=$($rule.recommended_action)"
    }
}
Write-Utf8NoBom -Path $reportPath -Content ([string]::Join("`n", $md))

$suggestions = @()
$suggestions += "# continuous-learning-v2 Suggestions"
$suggestions += ""
$suggestions += "These suggestions are generated automatically. Review manually before applying."
$suggestions += ""
if ($finalRules.Count -eq 0) {
    $suggestions += "- No high-confidence rules."
} else {
    $index = 1
    foreach ($rule in $finalRules) {
        $suggestions += ("{0}. [{1}] {2}" -f $index, $rule.signal, $rule.recommended_action)
        $index++
    }
}
Write-Utf8NoBom -Path $suggestionPath -Content ([string]::Join("`n", $suggestions))

Write-Output "=== Evolution Evolve ==="
Write-Output "Observations: $($rows.Count)"
Write-Output "Rules: $($finalRules.Count)"
Write-Output "Instincts: $instinctsPath"
Write-Output "Report: $reportPath"
Write-Output "Suggestions: $suggestionPath"

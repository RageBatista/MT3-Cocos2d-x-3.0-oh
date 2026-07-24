param(
    [string]$ProjectRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
    } else {
        $ProjectRoot = (Get-Location).Path
    }
}

$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$reportRoot = Join-Path $ProjectRoot ".claude\reports"
$rulesPath = Join-Path $ProjectRoot ".claude\RULES.md"
$nativeRulesPath = Join-Path $ProjectRoot ".codex\rules\mt3-guardrails.rules"
$requirementsPath = Join-Path $ProjectRoot ".codex\requirements.toml"
$guardrailsPath = Join-Path $ProjectRoot ".codex\permissions\guardrails.json"
$execpolicyTestPath = Join-Path $ProjectRoot ".claude\tests\test-codex-execpolicy.ps1"
$pretoolHookTestPath = Join-Path $ProjectRoot ".claude\tests\test-codex-pretool-hook.ps1"
$lifecycleHookTestPath = Join-Path $ProjectRoot ".claude\tests\test-codex-session-hooks.ps1"

function Write-Utf8NoBom {
    param(
        [string]$FilePath,
        [string]$Text
    )

    $dir = Split-Path -Parent $FilePath
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($FilePath, $Text, $encoding)
}

function Invoke-JsonTestMatrix {
    param(
        [string]$TestPath,
        [string]$MatrixId
    )

    if (-not (Test-Path -LiteralPath $TestPath -PathType Leaf)) {
        return [pscustomobject][ordered]@{
            id = $MatrixId
            status = "FAIL"
            exit_code = -1
            case_count = 0
            executed_count = 0
            max_elapsed_ms = -1
            max_process_ms = -1
            max_decision_cpu_ms = -1
            performance_p95_cpu_ms = -1
            failures = @("Missing matrix test: $TestPath")
            output = ""
        }
    }

    $hostCommand = Get-Command powershell.exe -ErrorAction SilentlyContinue
    if ($null -eq $hostCommand) {
        return [pscustomobject][ordered]@{
            id = $MatrixId
            status = "FAIL"
            exit_code = -1
            case_count = 0
            executed_count = 0
            max_elapsed_ms = -1
            max_process_ms = -1
            max_decision_cpu_ms = -1
            performance_p95_cpu_ms = -1
            failures = @("powershell.exe is required to run guardrail matrices")
            output = ""
        }
    }

    $oldErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $raw = @(& $hostCommand.Source -NoLogo -NoProfile -ExecutionPolicy Bypass -File $TestPath -ProjectRoot $ProjectRoot -Json 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }

    $text = [string]::Join("`n", @($raw | ForEach-Object { [string]$_ })).Trim()
    try {
        $parsed = $text | ConvertFrom-Json -ErrorAction Stop
        $cases = @($parsed.data.cases)
        $failures = @($parsed.data.failures | ForEach-Object { [string]$_ })
        $declaredCount = if ($parsed.data.PSObject.Properties.Name -contains "case_count") { [int]$parsed.data.case_count } else { $cases.Count }
        $executedCount = if ($parsed.data.PSObject.Properties.Name -contains "executed_count") { [int]$parsed.data.executed_count } else { $cases.Count }
        $maxElapsedMilliseconds = if ($parsed.data.PSObject.Properties.Name -contains "max_elapsed_ms") {
            [int]$parsed.data.max_elapsed_ms
        } elseif ($cases.Count -gt 0 -and $cases[0].PSObject.Properties.Name -contains "elapsed_ms") {
            [int](($cases | Measure-Object -Property elapsed_ms -Maximum).Maximum)
        } else {
            -1
        }
        $maxProcessMilliseconds = if ($parsed.data.PSObject.Properties.Name -contains "max_process_ms") {
            [int]$parsed.data.max_process_ms
        } elseif ($cases.Count -gt 0 -and $cases[0].PSObject.Properties.Name -contains "process_ms") {
            [int](($cases | Measure-Object -Property process_ms -Maximum).Maximum)
        } else {
            -1
        }
        $maxDecisionCpuMilliseconds = if ($parsed.data.PSObject.Properties.Name -contains "max_decision_cpu_ms") { [int]$parsed.data.max_decision_cpu_ms } else { -1 }
        $performanceP95CpuMilliseconds = if ($parsed.data.PSObject.Properties.Name -contains "performance_p95_cpu_ms") { [int]$parsed.data.performance_p95_cpu_ms } else { -1 }
        $status = if ($exitCode -eq 0 -and [string]$parsed.status -eq "PASS" -and $failures.Count -eq 0 -and $executedCount -gt 0) { "PASS" } else { "FAIL" }
        if ($status -eq "FAIL" -and $failures.Count -eq 0) {
            $failures = @("Matrix returned status=$($parsed.status), exit=$exitCode, executed=$executedCount")
        }
        return [pscustomobject][ordered]@{
            id = $MatrixId
            status = $status
            exit_code = $exitCode
            case_count = $declaredCount
            executed_count = $executedCount
            max_elapsed_ms = $maxElapsedMilliseconds
            max_process_ms = $maxProcessMilliseconds
            max_decision_cpu_ms = $maxDecisionCpuMilliseconds
            performance_p95_cpu_ms = $performanceP95CpuMilliseconds
            failures = $failures
            output = [string]$parsed.summary
        }
    } catch {
        return [pscustomobject][ordered]@{
            id = $MatrixId
            status = "FAIL"
            exit_code = $exitCode
            case_count = 0
            executed_count = 0
            max_elapsed_ms = -1
            max_process_ms = -1
            max_decision_cpu_ms = -1
            performance_p95_cpu_ms = -1
            failures = @("Matrix JSON parse failed: $($_.Exception.Message)")
            output = $text
        }
    }
}

$auditIssues = New-Object System.Collections.Generic.List[string]
$gitHead = ""
try {
    $gitHead = [string]((& git -C $ProjectRoot rev-parse HEAD 2>$null | Select-Object -First 1)).Trim()
    if ($gitHead -notmatch '^[0-9a-fA-F]{40}$') {
        throw "git rev-parse returned an invalid HEAD"
    }
} catch {
    [void]$auditIssues.Add("Unable to capture current Git HEAD for report freshness")
}

foreach ($requiredPath in @($rulesPath, $nativeRulesPath, $requirementsPath, $guardrailsPath, $execpolicyTestPath, $pretoolHookTestPath, $lifecycleHookTestPath)) {
    if (-not (Test-Path $requiredPath -PathType Leaf)) {
        [void]$auditIssues.Add("Missing required file: $requiredPath")
    }
}

$execpolicyMatrix = Invoke-JsonTestMatrix -TestPath $execpolicyTestPath -MatrixId "execpolicy"
$pretoolHookMatrix = Invoke-JsonTestMatrix -TestPath $pretoolHookTestPath -MatrixId "pretool_hook"
$lifecycleHookMatrix = Invoke-JsonTestMatrix -TestPath $lifecycleHookTestPath -MatrixId "lifecycle_hooks"
foreach ($matrix in @($execpolicyMatrix, $pretoolHookMatrix, $lifecycleHookMatrix)) {
    if ([string]$matrix.status -ne "PASS") {
        foreach ($failure in @($matrix.failures)) {
            [void]$auditIssues.Add("$($matrix.id) matrix failed: $failure")
        }
    }
}

$rulesText = if (Test-Path $rulesPath -PathType Leaf) { Get-Content -Raw -Encoding UTF8 $rulesPath } else { "" }
$nativeRulesText = if (Test-Path $nativeRulesPath -PathType Leaf) { Get-Content -Raw -Encoding UTF8 $nativeRulesPath } else { "" }
$requirementsText = if (Test-Path $requirementsPath -PathType Leaf) { Get-Content -Raw -Encoding UTF8 $requirementsPath } else { "" }
$guardrailsConfig = if (Test-Path $guardrailsPath -PathType Leaf) { Get-Content -Raw -Encoding UTF8 $guardrailsPath | ConvertFrom-Json } else { $null }
$guardrailsSchemaVersion = if ($null -ne $guardrailsConfig -and $null -ne $guardrailsConfig.schema_version) {
    [string]$guardrailsConfig.schema_version
} else {
    ""
}
$guardrailRulesSource = "missing"
$guardrailRuleIds = @()
if ($null -ne $guardrailsConfig) {
    $hasRules = $guardrailsConfig.PSObject.Properties.Name -contains "rules"
    $hasRuleReferences = $guardrailsConfig.PSObject.Properties.Name -contains "rule_references"
    if ($hasRules) {
        $guardrailRulesSource = "rules"
        $guardrailRuleIds = @($guardrailsConfig.rules | ForEach-Object { [string]$_.id })
    } elseif ($hasRuleReferences) {
        $guardrailRulesSource = "rule_references"
        $guardrailRuleIds = @($guardrailsConfig.rule_references | ForEach-Object { [string]$_.id })
    } else {
        [void]$auditIssues.Add(".codex/permissions/guardrails.json missing both rules and rule_references")
    }
}

$families = @(
    [ordered]@{
        id = "win32-build-canonical-entry"
        rules_tokens = @("Build-MT3-Exe-Canonical.ps1")
        native_rules_tokens = @("Build-MT3-Exe-Canonical.ps1", "Build-MT3-v120.ps1")
        requirements_tokens = @("Build-MT3-Exe-Canonical.ps1", "Build-MT3-v120.ps1")
        guardrail_rule_id = "win32-build-canonical-entry"
    },
    [ordered]@{
        id = "android-gradle-disallowed"
        rules_tokens = @("Gradle", "Ant")
        native_rules_tokens = @("gradle", "gradlew")
        requirements_tokens = @("gradle", "gradlew")
        guardrail_rule_id = "android-gradle-disallowed"
    },
    [ordered]@{
        id = "server-non-ant-build-disallowed"
        rules_tokens = @("Maven/Gradle", "Ant")
        native_rules_tokens = @("mvn", "maven")
        requirements_tokens = @("mvn", "maven")
        guardrail_rule_id = "server-non-ant-build-disallowed"
    },
    [ordered]@{
        id = "unsafe-text-write-without-encoding"
        rules_tokens = @("UTF-16 LE", "CP936/ANSI", "UTF-8 with BOM")
        native_rules_tokens = @("Set-Content", "Add-Content", "Out-File")
        requirements_tokens = @("Set-Content", "Add-Content", "Out-File")
        guardrail_rule_id = "unsafe-text-write-without-encoding"
    }
)

$familyResults = @()

foreach ($family in $families) {
    $missing = New-Object System.Collections.Generic.List[string]

    foreach ($token in @($family.rules_tokens)) {
        if (-not $rulesText.Contains([string]$token)) {
            [void]$missing.Add(".claude/RULES.md missing token: $token")
        }
    }
    foreach ($token in @($family.native_rules_tokens)) {
        if (-not $nativeRulesText.Contains([string]$token)) {
            [void]$missing.Add(".codex/rules/mt3-guardrails.rules missing token: $token")
        }
    }
    foreach ($token in @($family.requirements_tokens)) {
        if (-not $requirementsText.Contains([string]$token)) {
            [void]$missing.Add(".codex/requirements.toml missing token: $token")
        }
    }
    if ($guardrailRuleIds -notcontains [string]$family.guardrail_rule_id) {
        [void]$missing.Add(".codex/permissions/guardrails.json missing rule id: $($family.guardrail_rule_id)")
    }

    if ($missing.Count -gt 0) {
        foreach ($item in $missing) {
            [void]$auditIssues.Add("$($family.id) :: $item")
        }
    }

    $familyResults += [pscustomobject]@{
        id = [string]$family.id
        status = if ($missing.Count -eq 0) { "PASS" } else { "FAIL" }
        missing = @($missing)
    }
}

$status = if ($auditIssues.Count -eq 0) { "PASS" } else { "FAIL" }
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

$result = [pscustomobject]@{
    timestamp = $timestamp
    project_root = $ProjectRoot
    git_head = $gitHead
    status = $status
    guardrails_schema_version = $guardrailsSchemaVersion
    guardrails_rule_source = $guardrailRulesSource
    errors = @($auditIssues)
    families = @($familyResults)
    test_matrices = [pscustomobject][ordered]@{
        execpolicy = $execpolicyMatrix
        pretool_hook = $pretoolHookMatrix
        lifecycle_hooks = $lifecycleHookMatrix
    }
}

$jsonPath = Join-Path $reportRoot "codex-guardrails-audit.json"
$mdPath = Join-Path $reportRoot "codex-guardrails-audit.md"

Write-Utf8NoBom -FilePath $jsonPath -Text ($result | ConvertTo-Json -Depth 20)

$md = @()
$md += "# Codex Guardrails Audit"
$md += ""
$md += "- Time: $timestamp"
$md += "- Project: $ProjectRoot"
$md += "- Status: **$status**"
$md += ""
foreach ($family in $familyResults) {
    $md += "## $($family.id)"
    $md += ""
    $md += "- Status: **$($family.status)**"
    if (@($family.missing).Count -gt 0) {
        foreach ($item in @($family.missing)) {
            $md += "- $item"
        }
    }
    $md += ""
}
$md += "## Executable Matrices"
$md += ""
$md += "- Execpolicy: **$($execpolicyMatrix.status)** ($($execpolicyMatrix.executed_count) executed)"
$md += "- PreToolUse hook: **$($pretoolHookMatrix.status)** ($($pretoolHookMatrix.executed_count) executed, decision CPU p95 $($pretoolHookMatrix.performance_p95_cpu_ms) ms, process wall max $($pretoolHookMatrix.max_process_ms) ms diagnostic only)"
$md += "- Lifecycle hooks: **$($lifecycleHookMatrix.status)** ($($lifecycleHookMatrix.executed_count) executed, max $($lifecycleHookMatrix.max_elapsed_ms) ms, wall $($lifecycleHookMatrix.max_process_ms) ms)"
$md += ""

Write-Utf8NoBom -FilePath $mdPath -Text ([string]::Join("`r`n", $md))

Write-Output "=== Codex Guardrails Audit ==="
Write-Output "Status: $status"
Write-Output "Families: $($familyResults.Count)"
Write-Output "Errors: $($auditIssues.Count)"
Write-Output "Execpolicy Matrix: $($execpolicyMatrix.status) ($($execpolicyMatrix.executed_count) executed)"
Write-Output "PreToolUse Matrix: $($pretoolHookMatrix.status) ($($pretoolHookMatrix.executed_count) executed, decision CPU p95 $($pretoolHookMatrix.performance_p95_cpu_ms) ms, process wall max $($pretoolHookMatrix.max_process_ms) ms diagnostic only)"
Write-Output "Lifecycle Matrix: $($lifecycleHookMatrix.status) ($($lifecycleHookMatrix.executed_count) executed, max $($lifecycleHookMatrix.max_elapsed_ms) ms, wall $($lifecycleHookMatrix.max_process_ms) ms)"
Write-Output "JSON Report: $jsonPath"
Write-Output "Markdown Report: $mdPath"

if ($status -eq "PASS") {
    exit 0
}
exit 1

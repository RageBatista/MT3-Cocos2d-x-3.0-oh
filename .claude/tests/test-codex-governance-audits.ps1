[CmdletBinding()]
param(
    [string]$ProjectRoot = "",
    [switch]$ReuseExistingGuardrailReport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
} else {
    $ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
}

$failures = New-Object System.Collections.Generic.List[string]
$passes = 0

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Invoke-Case {
    param(
        [string]$Name,
        [scriptblock]$Body
    )

    try {
        & $Body
        $script:passes++
        Write-Output "PASS: $Name"
    } catch {
        [void]$script:failures.Add("$Name`: $($_.Exception.Message)")
        Write-Output "FAIL: $Name`: $($_.Exception.Message)"
    }
}

function Invoke-AuditProcess {
    param(
        [string]$ScriptRelativePath,
        [string[]]$Arguments = @()
    )

    $hostCommand = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($null -eq $hostCommand) {
        $hostCommand = Get-Command pwsh -ErrorAction SilentlyContinue
    }
    if ($null -eq $hostCommand) {
        throw "PowerShell 7 (pwsh) is required for UTF-8 no-BOM governance audits."
    }
    $scriptPath = Join-Path $ProjectRoot $ScriptRelativePath
    $raw = @(& $hostCommand.Source -NoLogo -NoProfile -ExecutionPolicy Bypass -File $scriptPath @Arguments 2>&1)
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output = [string]::Join([Environment]::NewLine, @($raw | ForEach-Object { [string]$_ }))
    }
}

function Read-Json {
    param([string]$RelativePath)
    return (Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot $RelativePath) | ConvertFrom-Json -ErrorAction Stop)
}

function Assert-GuardrailReportFreshness {
    param(
        [object]$Report,
        [string]$CurrentGitHead
    )

    Assert-True ([string]$Report.git_head -eq $CurrentGitHead) "guardrail report is stale: report git_head does not match current HEAD"
}

Invoke-Case -Name "sidecar schema and graph audit" -Body {
    $run = Invoke-AuditProcess -ScriptRelativePath ".claude\scripts\validate_codex_sidecars.ps1" -Arguments @("-ProjectRoot", $ProjectRoot)
    Assert-True ($run.ExitCode -eq 0) "sidecar validator failed: $($run.Output)"
    $report = Read-Json ".claude\reports\codex-sidecars-validation.json"
    Assert-True ($report.schema_validation.workflow_catalog.status -eq "PASS") "workflow catalog schema was not validated"
    Assert-True ($report.schema_validation.project_map.status -eq "PASS") "project map schema was not validated"
    Assert-True ($report.schema_validation.mcp_profile.status -eq "PASS") "MCP profile schema was not validated"
    Assert-True ([string]$report.tooling.schema_engine -eq "python/jsonschema") "sidecar schemas must use the pinned Python jsonschema path"
    [string[]]$configMcpIds = @($report.config_mcp_ids | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    [string[]]$profileMcpIds = @((Read-Json ".codex\mcp\mcp-profiles.json").known_servers | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    [string[]]$manifestMcpIds = @((Read-Json ".claude\config\mcp.manifest.json").servers.id | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    Assert-True (($configMcpIds -join "|") -eq ($profileMcpIds -join "|")) "config MCP ids differ from profile known_servers"
    Assert-True (($configMcpIds -join "|") -eq ($manifestMcpIds -join "|")) "config MCP ids differ from manifest server ids"
    Assert-True ([int]$report.workflow_graphs.total -eq 13) "expected 13 workflow graphs"
    Assert-True ([int]$report.workflow_graphs.connected -eq 13) "not every workflow graph is connected"
    Assert-True ([int]$report.cross_file.agent_references_checked -gt 0) "agent references were not checked"
    Assert-True ([int]$report.cross_file.skill_references_checked -gt 0) "skill references were not checked"
    Assert-True ([int]$report.path_availability.checked -gt 0) "path availability was not checked"
    Assert-True ([int]$report.lfs.checked -gt 0) "LFS hydration was not checked"
}

Invoke-Case -Name "workflow routing and warning outcomes stay explicit" -Body {
    $catalog = Read-Json ".codex\workflows\workflow-engine.json"
    $android = @($catalog.workflows | Where-Object { $_.id -eq "android-build" })[0]
    $cegui = @($catalog.workflows | Where-Object { $_.id -eq "cegui-layout-integration" })[0]
    $governance = @($catalog.workflows | Where-Object { $_.id -eq "codex-governance" })[0]

    Assert-True (-not (@($android.routing.required_skills) -contains "platform-bridge")) "Android build must not require platform-bridge"
    Assert-True (@($android.routing.optional_runtime_skills) -contains "platform-bridge") "Android build must keep platform-bridge as a conditional runtime skill"
    Assert-True (-not (@($cegui.routing.required_skills) -contains "rendering-pipeline")) "CEGUI XML integration must not require rendering-pipeline"
    Assert-True (@($cegui.routing.optional_runtime_skills) -contains "rendering-pipeline") "CEGUI XML integration must keep rendering-pipeline as a conditional runtime skill"

    Assert-True (@($governance.nodes.quality_gate.command.arguments) -contains "-Strict") "Codex governance quality gate must fail on warnings"
    Assert-True ([string]$governance.nodes.quality_gate.on_success -eq "report_status_gate") "quality gate must not route directly to PASS"
    Assert-True ($null -ne $governance.nodes.report_status_gate) "report status gate is missing"
    Assert-True ([string]$governance.nodes.report_status_gate.kind -eq "command") "report status gate must be executable"
    Assert-True ([string]$governance.nodes.report_status_gate.command.entry -eq ".claude/scripts/assert_codex_governance_reports.ps1") "report status verifier entry is missing"
    Assert-True ([string]$governance.nodes.report_status_gate.on_success -eq "complete") "clean report set must route to PASS"
    Assert-True ([string]$governance.nodes.report_status_gate.on_failure -eq "failed") "failed report set must route to FAIL"
    Assert-True ([string]$governance.nodes.skill_audit.on_success -eq "claude_audit") "skill audit must route to Claude runtime snapshot capture"
    Assert-True ([string]$governance.nodes.claude_audit.on_success -eq "workflow_analysis") "Claude runtime snapshot capture must precede workflow health analysis"
    Assert-True ([string]$governance.nodes.workflow_analysis.on_success -eq "quality_gate") "workflow health analysis must route to the strict quality gate"
}

Invoke-Case -Name "report status verifier rejects semantic warnings" -Body {
    $scriptPath = Join-Path $ProjectRoot ".claude\scripts\assert_codex_governance_reports.ps1"
    $command = Get-Command $scriptPath -ErrorAction Stop
    foreach ($parameter in @("ProjectRoot", "ReportsRoot")) {
        Assert-True ($command.Parameters.ContainsKey($parameter)) "missing report verifier parameter: $parameter"
    }

    $current = Invoke-AuditProcess -ScriptRelativePath ".claude\scripts\assert_codex_governance_reports.ps1" -Arguments @("-ProjectRoot", $ProjectRoot)
    Assert-True ($current.ExitCode -eq 0) "current governance reports are not PASS: $($current.Output)"

    $tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    $fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $tempBase ("mt3-codex-report-status-" + [guid]::NewGuid().ToString("N"))))
    Assert-True ($fixtureRoot.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe report fixture path"
    [System.IO.Directory]::CreateDirectory($fixtureRoot) | Out-Null
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    try {
        $fixtures = @{
            "codex-sidecars-validation.json" = '{"status":"PASS"}'
            "codex-guardrails-audit.json" = '{"status":"PASS"}'
            "codex-skills-audit.json" = '{"status":"PASS"}'
            "codex-skills-workflow-health.json" = '{"status":"PASS"}'
            "claude-config-audit.json" = '{"overall_status":"PASS"}'
            "quality-gate-report.json" = '{"overall_status":"pass"}'
        }
        foreach ($name in $fixtures.Keys) {
            [System.IO.File]::WriteAllText((Join-Path $fixtureRoot $name), [string]$fixtures[$name], $utf8NoBom)
        }

        $passRun = Invoke-AuditProcess -ScriptRelativePath ".claude\scripts\assert_codex_governance_reports.ps1" -Arguments @("-ProjectRoot", $ProjectRoot, "-ReportsRoot", $fixtureRoot)
        Assert-True ($passRun.ExitCode -eq 0) "PASS fixtures were rejected: $($passRun.Output)"

        [System.IO.File]::WriteAllText((Join-Path $fixtureRoot "codex-skills-workflow-health.json"), '{"status":"WARN"}', $utf8NoBom)
        $warnRun = Invoke-AuditProcess -ScriptRelativePath ".claude\scripts\assert_codex_governance_reports.ps1" -Arguments @("-ProjectRoot", $ProjectRoot, "-ReportsRoot", $fixtureRoot)
        Assert-True ($warnRun.ExitCode -ne 0) "semantic WARN was accepted"
        Assert-True ($warnRun.Output -match "codex-skills-workflow-health.*WARN") "WARN evidence is missing: $($warnRun.Output)"
    } finally {
        if (Test-Path -LiteralPath $fixtureRoot -PathType Container) {
            [System.IO.Directory]::Delete($fixtureRoot, $true)
        }
    }
}

Invoke-Case -Name "Claude workflow intents mirror router bindings" -Body {
    $router = Read-Json ".claude\config\router.json"
    $manifest = Read-Json ".claude\config\workflows.manifest.json"
    $expected = @{}
    foreach ($route in @($router.intent_routes)) {
        $intent = [string]$route.intent
        $workflowIds = @()
        if (($route.PSObject.Properties.Name -contains "workflow_id") -and -not [string]::IsNullOrWhiteSpace([string]$route.workflow_id)) {
            $workflowIds += [string]$route.workflow_id
        }
        if ($route.PSObject.Properties.Name -contains "workflow_candidates") {
            $workflowIds += @($route.workflow_candidates | ForEach-Object { [string]$_ })
        }
        foreach ($workflowId in @($workflowIds | Sort-Object -Unique)) {
            if (-not $expected.ContainsKey($workflowId)) {
                $expected[$workflowId] = New-Object System.Collections.Generic.List[string]
            }
            [void]$expected[$workflowId].Add($intent)
        }
    }

    foreach ($workflow in @($manifest.workflows)) {
        $workflowId = [string]$workflow.id
        [string[]]$actual = @($workflow.intents | ForEach-Object { [string]$_ } | Sort-Object -Unique)
        [string[]]$wanted = @()
        if ($expected.ContainsKey($workflowId)) {
            $wanted = @($expected[$workflowId] | Sort-Object -Unique)
        }
        Assert-True (($actual -join "|") -eq ($wanted -join "|")) "workflow intents drift: $workflowId actual=$($actual -join ',') expected=$($wanted -join ',')"
    }
}

Invoke-Case -Name "guardrail executable matrices" -Body {
    if (-not $ReuseExistingGuardrailReport) {
        $run = Invoke-AuditProcess -ScriptRelativePath ".claude\scripts\audit_codex_guardrails.ps1" -Arguments @("-ProjectRoot", $ProjectRoot)
        Assert-True ($run.ExitCode -eq 0) "guardrail audit failed: $($run.Output)"
    }
    $report = Read-Json ".claude\reports\codex-guardrails-audit.json"
    $currentGitHead = (& git -C $ProjectRoot rev-parse HEAD).Trim()
    Assert-GuardrailReportFreshness -Report $report -CurrentGitHead $currentGitHead
    Assert-True ($report.test_matrices.execpolicy.status -eq "PASS") "execpolicy matrix was not executed"
    Assert-True ([int]$report.test_matrices.execpolicy.executed_count -gt 0) "execpolicy matrix has no executed cases"
    Assert-True ($report.test_matrices.pretool_hook.status -eq "PASS") "PreToolUse hook matrix was not executed"
    Assert-True ([int]$report.test_matrices.pretool_hook.executed_count -gt 0) "PreToolUse matrix has no executed cases"
    Assert-True ([int]$report.test_matrices.pretool_hook.performance_p95_cpu_ms -ge 0) "PreToolUse decision CPU percentile is missing"
    $guardrailAuditSource = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".claude\scripts\audit_codex_guardrails.ps1")
    Assert-True ($guardrailAuditSource -notmatch 'Matrix exceeded 250ms') "guardrail audit must not re-apply a wall-clock threshold"
}

Invoke-Case -Name "workflow reuses the fresh guardrail audit" -Body {
    $workflowPath = Join-Path $ProjectRoot ".github\workflows\codex-skills-quality-gate.yml"
    $workflowText = Get-Content -Raw -Encoding UTF8 -LiteralPath $workflowPath
    Assert-True ($workflowText -notmatch '& "\./\.claude/scripts/audit_codex_guardrails\.ps1"') "workflow runs the heavyweight guardrail matrix before the Claude audit runs it again"
    Assert-True ($workflowText -match 'test-codex-governance-audits\.ps1" -ProjectRoot "\." -ReuseExistingGuardrailReport') "workflow governance regression must reuse the fresh guardrail report"
    $governanceCommand = Get-Command (Join-Path $ProjectRoot ".claude\tests\test-codex-governance-audits.ps1") -ErrorAction Stop
    Assert-True ($governanceCommand.Parameters.ContainsKey("ReuseExistingGuardrailReport")) "governance regression is missing -ReuseExistingGuardrailReport"
    $staleRejected = $false
    try {
        Assert-GuardrailReportFreshness -Report ([pscustomobject]@{ git_head = "0" * 40 }) -CurrentGitHead ((& git -C $ProjectRoot rev-parse HEAD).Trim())
    } catch {
        $staleRejected = $true
    }
    Assert-True $staleRejected "governance reuse path accepted a stale guardrail report"
}

Invoke-Case -Name "skill audit integration controls" -Body {
    $scriptPath = Join-Path $ProjectRoot ".claude\scripts\audit_codex_skills.ps1"
    $command = Get-Command $scriptPath -ErrorAction Stop
    foreach ($parameter in @("SkipIntegration", "OfficialValidatorPath", "RequireOfficialValidator")) {
        Assert-True ($command.Parameters.ContainsKey($parameter)) "missing audit parameter: $parameter"
    }

    $run = Invoke-AuditProcess -ScriptRelativePath ".claude\scripts\audit_codex_skills.ps1" -Arguments @("-ProjectRoot", $ProjectRoot, "-SkipIntegration")
    Assert-True ($run.ExitCode -eq 0) "skill audit failed: $($run.Output)"
    $report = Read-Json ".claude\reports\codex-skills-audit.json"
    Assert-True ([bool]$report.integration.skipped) "-SkipIntegration was not reported"
    Assert-True ([int]$report.summary.links_checked -gt 0) "skill links were not checked"
    Assert-True ([int]$report.summary.lfs_files_checked -gt 0) "skill LFS files were not checked"
}

Invoke-Case -Name "quality gate coverage accounting" -Body {
    $run = Invoke-AuditProcess -ScriptRelativePath ".claude\scripts\quality_gate.ps1" -Arguments @("-TargetPath", ".codex", "-Strict")
    Assert-True ($run.ExitCode -eq 0) "quality gate failed: $($run.Output)"
    $report = Read-Json ".claude\reports\quality-gate-report.json"
    Assert-True ([int]$report.discovered_files -gt 0) "discovered file count is missing"
    Assert-True ([int]$report.checked_files -gt 0) "checked file count is missing"
    Assert-True ($null -ne $report.skipped_by_reason) "skip reasons are missing"
    Assert-True (@($report.checked_extensions) -contains ".toml") ".toml is not checked"
    Assert-True (@($report.checked_extensions) -contains ".rules") ".rules is not checked"
    Assert-True (@($report.checked_extensions) -contains ".yaml") ".yaml is not checked"
    Assert-True (@($report.checked_extensions) -contains ".txt") ".txt is not checked"
}

Invoke-Case -Name "governance contracts cover codex subtree" -Body {
    $quality = Read-Json ".claude\config\quality-gates.json"
    $authority = Read-Json ".claude\config\source-authority.json"
    $evidence = Read-Json ".claude\config\evidence-contract.json"
    Assert-True (@($quality.governance_scope.roots) -contains ".codex/**") "quality-gates.json does not cover .codex/**"
    Assert-True (@($authority.governance_scope.roots) -contains ".codex/**") "source-authority.json does not cover .codex/**"
    Assert-True (@($evidence.governance_scope.roots) -contains ".codex/**") "evidence-contract.json does not cover .codex/**"
}

Invoke-Case -Name "Codex SDK dependency stays pinned and trackable" -Body {
    $packagePath = Join-Path $ProjectRoot "tools\codex\package.json"
    $lockPath = Join-Path $ProjectRoot "tools\codex\package-lock.json"
    Assert-True (Test-Path -LiteralPath $packagePath -PathType Leaf) "tools/codex/package.json is missing"
    Assert-True (Test-Path -LiteralPath $lockPath -PathType Leaf) "tools/codex/package-lock.json is missing"
    $package = Get-Content -Raw -Encoding UTF8 -LiteralPath $packagePath | ConvertFrom-Json
    Assert-True ([string]$package.engines.node -eq ">=18") "Node engine must remain >=18"
    Assert-True ([string]$package.dependencies.'@openai/codex-sdk' -eq "0.144.4") "Codex SDK must remain pinned to 0.144.4"
    Assert-True ([string]$package.dependencies.ajv -eq "8.20.0") "Ajv must remain pinned to 8.20.0"
    $ignoredSource = git -C $ProjectRoot check-ignore "tools/codex/package.json" 2>$null
    Assert-True ([string]::IsNullOrWhiteSpace(($ignoredSource | Out-String))) "tools/codex source is still ignored"
    $ignoredState = git -C $ProjectRoot check-ignore "tools/codex/.state/example.json" 2>$null
    Assert-True (-not [string]::IsNullOrWhiteSpace(($ignoredState | Out-String))) "tools/codex/.state must be ignored"
    $filter = (git -C $ProjectRoot check-attr filter -- "tools/codex/package-lock.json") -join "`n"
    Assert-True ($filter -match "filter: unset") "tools/codex JSON must stay outside Git LFS"
    $codexAgents = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot "tools\codex\AGENTS.md")
    Assert-True ($codexAgents -notmatch 'Test-MT3Codex\.ps1') "tools/codex/AGENTS.md references a missing test entry"
    Assert-True ($codexAgents -match 'npm test --prefix tools/codex') "tools/codex/AGENTS.md is missing the real npm test entry"
    Assert-True ($codexAgents -match 'audit_codex_guardrails\.ps1') "tools/codex/AGENTS.md is missing the related governance audit entry"
}

Invoke-Case -Name "project MCP defaults are closed and profile catalog is advisory" -Body {
    $configText = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".codex\config.toml")
    $readmeText = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".codex\README.md")
    $profiles = Read-Json ".codex\mcp\mcp-profiles.json"
    $expectedServers = @(
        "apktool", "atlassian", "chrome-devtools", "context7", "docker-gateway", "exa",
        "fetch", "filesystem", "git", "github", "linear", "memory", "node_repl", "notion",
        "open-websearch", "openaiDeveloperDocs", "playwright", "postgres", "puppeteer",
        "sequential-thinking", "sqlite", "tavily-search", "time"
    )
    foreach ($server in $expectedServers) {
        Assert-True ($configText.Contains("[mcp_servers.$server]")) "project MCP override is missing: $server"
    }
    [string[]]$knownServers = @($profiles.known_servers | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    [string[]]$sortedExpectedServers = @($expectedServers | Sort-Object -Unique)
    Assert-True (($knownServers -join "|") -eq ($sortedExpectedServers -join "|")) "MCP catalog known_servers drifted from the project closure set"
    Assert-True ([string]$profiles.kind -eq "mcp-profile-catalog") "MCP catalog kind drifted"
    $runtimeEffect = [string]$profiles.runtime_effect
    if ($runtimeEffect -ne "none") {
        $runtimeEffectPath = Join-Path $ProjectRoot $runtimeEffect
        Assert-True (Test-Path -LiteralPath $runtimeEffectPath -PathType Leaf) "non-none MCP runtime_effect target is missing: $runtimeEffect"
    }
    Assert-True ($runtimeEffect -eq "none") "advisory MCP catalog must declare runtime_effect=none"
    Assert-True (-not [bool]$profiles.automatic_runtime_switching) "advisory MCP catalog must not claim automatic runtime switching"
    Assert-True ($readmeText -match '23 个.*disabled override') "Codex README must document the 23 disabled project overrides"
    Assert-True ($readmeText -match 'configured=23、enabled=0') "Codex README must document the current merged runtime snapshot"
    Assert-True ($readmeText -notmatch '只声明官方 `openaiDeveloperDocs`|无法形成闭合白名单|差集不可由项目 manifest 关闭') "Codex README still describes the superseded inheritance model"
    foreach ($id in @("none", "official-docs", "research", "browser-debug")) {
        Assert-True (@($profiles.profiles.id) -contains $id) "MCP profile is missing: $id"
    }
    $none = @($profiles.profiles | Where-Object id -eq "none")[0]
    Assert-True (@($none.enable).Count -eq 0) "none profile must not enable servers"
    Assert-True (@($none.disable).Count -eq 23) "none profile must disable all known servers"

    $realTransportTokens = @(
        'url = "https://developers.openai.com/mcp"',
        'args = ["-y", "@upstash/context7-mcp@3.2.3"]',
        'args = ["-y", "tavily-mcp@0.2.21"]',
        'env_vars = ["TAVILY_API_KEY"]',
        'args = ["-y", "chrome-devtools-mcp@1.6.0", "--headless", "--isolated", "--no-usage-statistics"]',
        'args = ["-y", "@playwright/mcp@0.0.78", "--headless"]'
    )
    foreach ($token in $realTransportTokens) {
        Assert-True ($configText.Contains($token)) "profile transport is missing or unpinned: $token"
    }

    $noOpHttpServers = @("atlassian", "exa", "github", "linear", "notion")
    foreach ($server in $noOpHttpServers) {
        $pattern = '(?ms)^\[mcp_servers\.' + [regex]::Escape($server) + '\]\s*url = "http://127\.0\.0\.1:9/mcp"\s*enabled = false\s*required = false'
        Assert-True ([regex]::IsMatch($configText, $pattern)) "disabled HTTP no-op transport drift: $server"
    }

    $noOpStdioServers = @(
        "apktool", "docker-gateway", "fetch", "filesystem", "git", "memory", "node_repl",
        "open-websearch", "postgres", "puppeteer", "sequential-thinking", "sqlite", "time"
    )
    foreach ($server in $noOpStdioServers) {
        $pattern = '(?ms)^\[mcp_servers\.' + [regex]::Escape($server) + '\]\s*command = "cmd\.exe"\s*args = \["/d", "/c", "exit", "0"\]\s*enabled = false\s*required = false'
        Assert-True ([regex]::IsMatch($configText, $pattern)) "disabled STDIO no-op transport drift: $server"
    }
    Assert-True (-not $configText.Contains("SERVER_ID")) "MCP placeholder leaked into project config"
}

Invoke-Case -Name "active skill routing excludes corrupted legacy references" -Body {
    $legacyReferences = @(
        ".agents\skills\cegui-layout-integration\references\cegui-lua-shared-ui-reference.md",
        ".agents\skills\cegui-layout-integration\references\cegui-architecture-guide.md",
        ".agents\skills\cegui-layout-integration\references\cegui-diagnostic-workbench.md",
        ".agents\skills\cegui-layout-integration\references\cegui-layout-patterns.md"
    )
    foreach ($relativePath in $legacyReferences) {
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot $relativePath))) "corrupted legacy reference remains active: $relativePath"
    }

    foreach ($relativePath in @(
        ".agents\skills\cegui-layout-integration\SKILL.md",
        ".agents\skills\lua-dialog-integration\SKILL.md",
        ".agents\skills\lua-dialog-integration\references\lua-dialog-reference-index.md"
    )) {
        $content = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot $relativePath)
        foreach ($legacyName in @($legacyReferences | ForEach-Object { Split-Path -Leaf $_ })) {
            Assert-True (-not $content.Contains($legacyName)) "active skill routing still references $legacyName in $relativePath"
        }
    }
}

Invoke-Case -Name "CI pins official validator and runs full chain" -Body {
    $legacyGovernanceCommandPattern = 'powershell(?:\.exe)? [^\r\n]*(?:audit_claude_config|audit_evidence_baseline|validate_codex_sidecars|audit_codex_guardrails|audit_codex_skills|analyze_codex_skill_workflows|quality_gate|assert_codex_governance_reports)\.ps1'
    $workflowPath = Join-Path $ProjectRoot ".github\workflows\codex-skills-quality-gate.yml"
    $workflowBytes = [System.IO.File]::ReadAllBytes($workflowPath)
    $invalidControls = @($workflowBytes | Where-Object { $_ -lt 32 -and $_ -notin @(10, 13) })
    Assert-True ($invalidControls.Count -eq 0) "CI YAML contains forbidden control bytes"
    $workflow = Get-Content -Raw -Encoding UTF8 -LiteralPath $workflowPath
    Assert-True ($workflow -match '(?m)^\s+lfs:\s*false\s*$') "checkout must avoid full LFS hydration"
    Assert-True ($workflow -match '(?m)^permissions:\s*\r?\n\s+contents:\s*read\s*$') "Codex CI must declare read-only repository permissions"
    Assert-True ($workflow.Contains('git lfs pull -I ($requiredLfsFiles -join ",") --exclude=""')) "targeted LFS hydration command is missing"
    foreach ($path in @(
        "client/android/LocojoyProject/build.xml",
        "server/server/game_server/build.xml",
        "server/server/game_server/gnet.xml",
        "server/server/game_server/protocol.main.xml",
        "server/server/game_server/gs/build.xml"
    )) {
        Assert-True ($workflow.Contains($path)) "targeted LFS path is missing: $path"
    }
    Assert-True ($workflow.Contains("49f948faa9258a0c61caceaf225e179651397431")) "official validator commit is not pinned"
    foreach ($token in @("--strict-config doctor --json", "CODEX_HOME", "'config.load'", "'mcp.config'", "'configured servers'")) {
        Assert-True ($workflow.Contains($token)) "native strict config CI control is missing: $token"
    }
    foreach ($token in @(
        '.github/workflows/claude-config-audit.yml',
        '.github/workflows/encoding-check.yml',
        'tools/scripts/CI-CD-EncodeCheck.ps1',
        '${{ github.workspace }}/tools/codex/node_modules/.bin',
        '$env:GITHUB_PATH',
        'CODEX_HOME: ${{ github.workspace }}/.ci-codex-governance-home',
        '$codexHome = $env:CODEX_HOME',
        '$global:LASTEXITCODE = 0',
        '$mcpStatus -notin @("ok", "warning")',
        'optional reachability failed',
        '$unexpectedMcpDetails'
    )) {
        Assert-True ($workflow.Contains($token)) "Codex CI runtime isolation/trigger control is missing: $token"
    }
    foreach ($token in @("validate_codex_sidecars.ps1", "audit_codex_skills.ps1", "audit_codex_guardrails.ps1", "test-codex-skill-scripts.ps1", "test-codex-governance-audits.ps1", "quality_gate.ps1", "assert_codex_governance_reports.ps1", "-RequireOfficialValidator")) {
        Assert-True ($workflow.Contains($token)) "CI token is missing: $token"
    }
    Assert-True ($workflow.Contains('.claude/reports/mcp-runtime-snapshot.json')) "Codex governance artifact is missing the MCP runtime snapshot"
    Assert-True ([regex]::Matches($workflow, '(?m)^\s+- "tools/codex/\*\*"\s*$').Count -eq 2) "Codex governance push and pull-request triggers must cover tools/codex/**"
    Assert-True ([regex]::Matches($workflow, '(?m)^\s+- "\.gitattributes"\s*$').Count -eq 2) "Codex governance push and pull-request triggers must cover Git text/LFS policy changes"
    Assert-True ([regex]::Matches($workflow, '(?m)^\s+- "\.github/workflows/claude-evolution-nightly\.yml"\s*$').Count -eq 2) "Codex governance push and pull-request triggers must cover Claude evolution workflow changes"
    $claudeAuditStepIndex = $workflow.IndexOf('- name: Refresh Claude compatibility audit report', [System.StringComparison]::Ordinal)
    $workflowHealthStepIndex = $workflow.IndexOf('- name: Refresh skill workflow health report', [System.StringComparison]::Ordinal)
    Assert-True ($claudeAuditStepIndex -ge 0 -and $workflowHealthStepIndex -gt $claudeAuditStepIndex) "runtime MCP snapshot capture must precede workflow health analysis"
    $npmCiIndex = $workflow.IndexOf('npm ci --prefix tools/codex', [System.StringComparison]::Ordinal)
    $githubPathIndex = $workflow.IndexOf('$env:GITHUB_PATH', [System.StringComparison]::Ordinal)
    Assert-True ($npmCiIndex -ge 0 -and $githubPathIndex -gt $npmCiIndex) "project-local Codex bin must be exported after npm ci"
    Assert-True ($workflow.Contains('foreach ($tool in @("git", "git-lfs", "python", "codex", "powershell.exe", "pwsh.exe"))')) "CI tool probe must resolve codex from GITHUB_PATH"

    $claudeWorkflow = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".github\workflows\claude-config-audit.yml")
    Assert-True ([regex]::Matches($claudeWorkflow, '(?m)^\s+- "\.gitattributes"\s*$').Count -eq 2) "standalone Claude audit push and pull-request triggers must cover Git text/LFS policy changes"
    foreach ($token in @(
        "client/android/LocojoyProject/build.xml",
        "server/server/game_server/build.xml",
        "server/server/game_server/gnet.xml",
        "server/server/game_server/protocol.main.xml",
        "server/server/game_server/gs/build.xml",
        "@openai/codex@0.144.1",
        "49f948faa9258a0c61caceaf225e179651397431",
        "MT3_OFFICIAL_SKILL_VALIDATOR",
        "codex-sidecars-validation.json",
        "codex-guardrails-audit.json",
        "codex-skills-audit.json",
        "mcp-runtime-snapshot.json"
    )) {
        Assert-True ($claudeWorkflow.Contains($token)) "standalone Claude audit CI control is missing: $token"
    }

    $evolutionWorkflow = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".github\workflows\claude-evolution-nightly.yml")
    Assert-True ($evolutionWorkflow -match '(?m)^permissions:\s*\r?\n\s+contents:\s*read\s*$') "Claude evolution CI must declare read-only repository permissions"
    Assert-True ($evolutionWorkflow -match '(?m)^\s+lfs:\s*false\s*$') "Claude evolution checkout must avoid full LFS hydration"
    foreach ($token in @(
        '.gitattributes',
        '.codex/**',
        '.agents/**',
        '.github/workflows/claude-evolution-nightly.yml',
        'git lfs pull -I ($requiredLfsFiles -join ",") --exclude=""',
        '49f948faa9258a0c61caceaf225e179651397431',
        'PyYAML==6.0.2 jsonschema==4.25.1',
        '@openai/codex@0.144.1',
        'MT3_OFFICIAL_SKILL_VALIDATOR',
        'CODEX_HOME',
        'mcp-runtime-snapshot.json',
        'codex-sidecars-validation.json',
        'codex-guardrails-audit.json',
        'codex-skills-audit.json'
    )) {
        Assert-True ($evolutionWorkflow.Contains($token)) "Claude evolution governance prerequisite is missing: $token"
    }
    $evolutionHydrationIndex = $evolutionWorkflow.IndexOf('- name: Hydrate required governance XML only', [System.StringComparison]::Ordinal)
    $evolutionAuditIndex = $evolutionWorkflow.IndexOf('- name: Run Claude Config Audit (LegacyStrict)', [System.StringComparison]::Ordinal)
    Assert-True ($evolutionHydrationIndex -ge 0 -and $evolutionAuditIndex -gt $evolutionHydrationIndex) "Claude evolution must hydrate governance inputs before LegacyStrict audit"

    $encodingWorkflow = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".github\workflows\encoding-check.yml")
    Assert-True (-not $encodingWorkflow.Contains("microsoft/setup-powershell")) "encoding CI references a nonexistent PowerShell setup action"
    Assert-True (-not $encodingWorkflow.Contains("-Mode All")) "encoding CI must not scan the full legacy repository"
    Assert-True ($encodingWorkflow.Contains('${{ github.event.before }}')) "push-range encoding baseline is missing"
    Assert-True ($encodingWorkflow.Contains("-TargetBranch")) "encoding CI does not pass an explicit Git baseline"
    Assert-True (-not $encodingWorkflow.Contains("pull-requests: write")) "encoding CI requests unnecessary pull-request write permission"
    Assert-True (-not $encodingWorkflow.Contains("issues: write")) "encoding CI requests unnecessary issue write permission"
    $encodingJobs = [regex]::Matches($encodingWorkflow, '(?m)^  encoding-check-[^:]+:\s*$')
    Assert-True ($encodingJobs.Count -eq 1) "encoding CI must use one incremental job, actual=$($encodingJobs.Count)"

    $claudeAuditScript = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".claude\scripts\audit_claude_config.ps1")
    Assert-True ($claudeAuditScript.Contains("Get-Command pwsh.exe")) "nested Claude audits do not prefer the UTF-8-safe pwsh host"
    foreach ($token in @(
        '$codexSidecarValidationOutput = @($sidecarValidationResult.output | Select-Object -First 20)',
        '$codexGuardrailAuditOutput = @($guardrailAuditResult.output | Select-Object -First 20)',
        '$codexSkillsAuditOutput = @($skillsAuditResult.output | Select-Object -First 20)'
    )) {
        Assert-True ($claudeAuditScript.Contains($token)) "nested Codex audit evidence sample is incomplete: $token"
    }

    $governanceTestScript = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".claude\tests\test-codex-governance-audits.ps1")
    Assert-True ($governanceTestScript.Contains('Get-Command pwsh.exe -ErrorAction SilentlyContinue')) "governance nested audits do not prefer the UTF-8-safe pwsh host"
    Assert-True ($governanceTestScript -notmatch '(?m)^\s*\$hostCommand\s*=\s*Get-Command powershell\.exe') "governance nested audits must fail closed when PowerShell 7 is unavailable"

    $hookSample = Read-Json ".claude\hooks\hooks.json"
    $hookCommands = @(
        foreach ($eventProperty in $hookSample.hooks.PSObject.Properties) {
            foreach ($binding in @($eventProperty.Value)) {
                foreach ($hook in @($binding.hooks)) {
                    [string]$hook.command
                }
            }
        }
    )
    Assert-True ($hookCommands.Count -eq 7) "Claude hook sample must expose seven command hooks"
    Assert-True (@($hookCommands | Where-Object { $_ -notmatch '^pwsh\.exe -NoLogo -NoProfile -File ' }).Count -eq 0) "Claude hook sample contains a non-pwsh command"
    $attributes = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot '.gitattributes')
    Assert-True ($attributes -match '(?m)^/\.claude/hooks/\*\.json -filter diff merge text eol=lf\s*$') "Claude hook JSON sample must be stored as reviewable Git text"

    foreach ($relativePath in @(
        '.codex\README.md',
        '.agents\skills\codex-runtime-governance\references\codex-runtime-map.md',
        '.agents\skills\mt3-project-guidelines\references\skill-development-checklist.md',
        '.claude\AGENTS.md',
        '.claude\CLAUDE.md',
        '.claude\CODEX_BRIDGE.md',
        '.claude\commands\audit-config.md',
        '.claude\commands\quality-gate.md',
        '.claude\config\INDEX.md',
        '.claude\config\README.md',
        '.claude\hooks\README.md',
        '.claude\hooks\session-start-profile.ps1',
        '.claude\hooks\stop-config-audit.ps1',
        '.claude\rules\09-claude-config-governance.md',
        '.claude\scripts\README.md',
        '.claude\scripts\analyze_codex_skill_workflows.ps1',
        '.claude\scripts\quality_gate.ps1',
        '.claude\skills\common\claude-config-engineering.md',
        '.claude\workflows\claude-config-workflow.md'
    )) {
        $governanceGuide = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot $relativePath)
        Assert-True ($governanceGuide -notmatch $legacyGovernanceCommandPattern) "governance documentation must use the UTF-8-safe pwsh host: $relativePath"
    }

    foreach ($relativePath in @(
        '.codex\README.md',
        '.agents\skills\codex-runtime-governance\references\codex-runtime-map.md',
        '.agents\skills\mt3-project-guidelines\references\skill-development-checklist.md',
        '.claude\AGENTS.md',
        '.claude\scripts\README.md',
        '.claude\workflows\claude-config-workflow.md'
    )) {
        $sequenceGuide = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot $relativePath)
        $guideAuditIndex = $sequenceGuide.IndexOf('audit_claude_config.ps1', [System.StringComparison]::Ordinal)
        $guideHealthIndex = $sequenceGuide.IndexOf('analyze_codex_skill_workflows.ps1', [System.StringComparison]::Ordinal)
        Assert-True ($guideAuditIndex -ge 0 -and $guideHealthIndex -gt $guideAuditIndex) "governance guide must capture the MCP snapshot before workflow health analysis: $relativePath"
    }

    $workflowAnalyzer = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot '.claude\scripts\analyze_codex_skill_workflows.ps1')
    $analyzerSnapshotIndex = $workflowAnalyzer.IndexOf('Capture MCP runtime snapshot: `pwsh.exe', [System.StringComparison]::Ordinal)
    $analyzerHealthIndex = $workflowAnalyzer.IndexOf('Run workflow health analysis: `pwsh.exe', [System.StringComparison]::Ordinal)
    Assert-True ($analyzerSnapshotIndex -ge 0 -and $analyzerHealthIndex -gt $analyzerSnapshotIndex) "workflow health report recommendations must capture the MCP snapshot before analysis"

    $codexReadme = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $ProjectRoot ".codex\README.md")
    Assert-True ($codexReadme -match '(?m)^pwsh\.exe .*test-codex-governance-audits\.ps1\s*$') "governance regression documentation must use the required pwsh host"
    Assert-True ($codexReadme -notmatch '(?m)^powershell\.exe .*test-codex-governance-audits\.ps1\s*$') "governance regression documentation still advertises Windows PowerShell 5.1"
    $documentedQualityIndex = $codexReadme.IndexOf('quality_gate.ps1 -TargetPath .codex -Strict', [System.StringComparison]::Ordinal)
    $documentedRegressionIndex = $codexReadme.IndexOf('test-codex-governance-audits.ps1', [System.StringComparison]::Ordinal)
    $documentedReportGateIndex = $codexReadme.IndexOf('pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\assert_codex_governance_reports.ps1 -ProjectRoot .', [System.StringComparison]::Ordinal)
    Assert-True ($documentedQualityIndex -ge 0 -and $documentedRegressionIndex -gt $documentedQualityIndex -and $documentedReportGateIndex -gt $documentedRegressionIndex) "documented governance chain must refresh quality evidence before regression and assert reports last"
}

Invoke-Case -Name "encoding checker preserves mixed-source baselines and validates new files" -Body {
    $pwshCommand = Get-Command pwsh.exe -ErrorAction Stop
    $checkerPath = Join-Path $ProjectRoot "tools\scripts\CI-CD-EncodeCheck.ps1"
    $tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    $fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $tempBase ("mt3-encoding-check-" + [guid]::NewGuid().ToString("N"))))
    Assert-True ($fixtureRoot.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe encoding fixture path"
    [System.IO.Directory]::CreateDirectory($fixtureRoot) | Out-Null

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    $utf8Bom = [System.Text.UTF8Encoding]::new($true)
    $legacyEncoding = [System.Text.Encoding]::GetEncoding(936)
    $sourcePath = Join-Path $fixtureRoot "client\MT3Win32App\source.cpp"
    $oldDocPath = Join-Path $fixtureRoot "docs\旧名称.md"
    $newDocPath = Join-Path $fixtureRoot "docs\新名称.md"
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $sourcePath)) | Out-Null
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $oldDocPath)) | Out-Null

    function Invoke-EncodingFixture {
        param(
            [string]$Baseline,
            [string]$ReportName
        )
        $reportPath = Join-Path $fixtureRoot $ReportName
        $raw = @(& $pwshCommand.Source -NoLogo -NoProfile -File $checkerPath `
            -Mode Changed -TargetBranch $Baseline -OutputPath $reportPath -LogLevel Quiet 2>&1)
        return [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output = [string]::Join([Environment]::NewLine, @($raw | ForEach-Object { [string]$_ }))
            ReportPath = $reportPath
            Report = if (Test-Path -LiteralPath $reportPath -PathType Leaf) {
                Get-Content -Raw -Encoding UTF8 -LiteralPath $reportPath
            } else {
                ""
            }
        }
    }

    try {
        Push-Location $fixtureRoot
        try {
            & git init --quiet
            & git config user.email "codex-governance@example.invalid"
            & git config user.name "Codex Governance Test"
            & git config core.autocrlf false
            & git config core.safecrlf false
            [System.IO.File]::WriteAllText($sourcePath, "// 基线`nint value = 1;`n", $legacyEncoding)
            [System.IO.File]::WriteAllText($oldDocPath, "# 旧名称`n", $utf8NoBom)
            & git add --all
            & git commit --quiet -m "base"
            $baseCommit = (& git rev-parse HEAD).Trim()

            [System.IO.File]::WriteAllText($sourcePath, "// 保持原编码`nint value = 2;`n", $legacyEncoding)
            & git mv -- "docs/旧名称.md" "docs/新名称.md"
            & git add --all
            & git commit --quiet -m "preserve and rename"
            $preservedCommit = (& git rev-parse HEAD).Trim()

            $preserved = Invoke-EncodingFixture -Baseline $baseCommit -ReportName "preserved.txt"
            Assert-True ($preserved.ExitCode -eq 0) "unchanged legacy encoding was rejected: $($preserved.Output)"
            Assert-True ($preserved.Report.Contains("docs\新名称.md") -or $preserved.Report.Contains("docs/新名称.md")) "Unicode rename target is absent from the report"
            Assert-True ($preserved.Report -match "source\.cpp[\s\S]*基线编码") "baseline evidence is absent from the report"

            [System.IO.File]::WriteAllText($sourcePath, "// 编码漂移`nint value = 3;`n", $utf8Bom)
            & git add --all
            & git commit --quiet -m "drift encoding"
            $drifted = Invoke-EncodingFixture -Baseline $preservedCommit -ReportName "drifted.txt"
            Assert-True ($drifted.ExitCode -ne 0) "legacy-to-UTF8 encoding drift was accepted"
            Assert-True ($drifted.Report -match "编码/BOM 分类从.*变为") "encoding drift evidence is absent: $($drifted.Report)"

            & git reset --quiet --hard $preservedCommit
            $newSourcePath = Join-Path $fixtureRoot "engine\new-source.cpp"
            [System.IO.Directory]::CreateDirectory((Split-Path -Parent $newSourcePath)) | Out-Null
            [System.IO.File]::WriteAllText($newSourcePath, "// 新增中文源码`nint value = 4;`n", $utf8NoBom)
            & git add --all
            & git commit --quiet -m "new source without bom"
            $newSourceNoBom = Invoke-EncodingFixture -Baseline $preservedCommit -ReportName "new-source-no-bom.txt"
            Assert-True ($newSourceNoBom.ExitCode -ne 0) "new non-ASCII C++ file without BOM was accepted"

            & git reset --quiet --hard $preservedCommit
            [System.IO.Directory]::CreateDirectory((Split-Path -Parent $newSourcePath)) | Out-Null
            [System.IO.File]::WriteAllText($newSourcePath, "// 新增中文源码`nint value = 4;`n", $utf8Bom)
            & git add --all
            & git commit --quiet -m "new source with bom"
            $newSourceWithBom = Invoke-EncodingFixture -Baseline $preservedCommit -ReportName "new-source-with-bom.txt"
            Assert-True ($newSourceWithBom.ExitCode -eq 0) "new non-ASCII C++ file with UTF-8 BOM was rejected: $($newSourceWithBom.Output)"

            & git reset --quiet --hard $preservedCommit
            [System.IO.Directory]::CreateDirectory((Split-Path -Parent $newSourcePath)) | Out-Null
            [System.IO.File]::WriteAllBytes($newSourcePath, [byte[]]@(0xEF, 0xBB, 0xBF, 0xC3, 0x28))
            & git add --all
            & git commit --quiet -m "new source with invalid utf8"
            $invalidUtf8Source = Invoke-EncodingFixture -Baseline $preservedCommit -ReportName "invalid-utf8-source.txt"
            Assert-True ($invalidUtf8Source.ExitCode -ne 0) "new C++ file with invalid UTF-8 after BOM was accepted"

            & git reset --quiet --hard $preservedCommit
            $newRcPath = Join-Path $fixtureRoot "client\MT3Win32App\resource.rc"
            [System.IO.File]::WriteAllText($newRcPath, "STRINGTABLE`nBEGIN`nEND`n", $utf8NoBom)
            & git add --all
            & git commit --quiet -m "new rc without bom"
            $newRcNoBom = Invoke-EncodingFixture -Baseline $preservedCommit -ReportName "new-rc-no-bom.txt"
            Assert-True ($newRcNoBom.ExitCode -ne 0) "new .rc file without an explicit BOM was accepted"

            & git reset --quiet --hard $preservedCommit
            $utf16LeBom = [System.Text.UnicodeEncoding]::new($false, $true, $true)
            [System.IO.File]::WriteAllText($newRcPath, "STRINGTABLE`r`nBEGIN`r`nEND`r`n", $utf16LeBom)
            & git add --all
            & git commit --quiet -m "new rc utf16"
            $newRcUtf16 = Invoke-EncodingFixture -Baseline $preservedCommit -ReportName "new-rc-utf16.txt"
            Assert-True ($newRcUtf16.ExitCode -eq 0) "new UTF-16 LE BOM .rc file was rejected: $($newRcUtf16.Output)"

            & git reset --quiet --hard $preservedCommit
            [System.IO.File]::WriteAllText($sourcePath, "// 暂存区编码漂移`nint value = 5;`n", $utf8Bom)
            & git add --all
            [System.IO.File]::WriteAllText($sourcePath, "// 工作树仍是原编码`nint value = 6;`n", $legacyEncoding)
            $stagedReportPath = Join-Path $fixtureRoot "staged-drift.txt"
            $stagedRaw = @(& $pwshCommand.Source -NoLogo -NoProfile -File $checkerPath `
                -Mode Staged -OutputPath $stagedReportPath -LogLevel Quiet 2>&1)
            $stagedExit = $LASTEXITCODE
            Assert-True ($stagedExit -ne 0) "staged encoding drift was hidden by different working-tree bytes: $([string]::Join([Environment]::NewLine, $stagedRaw))"

            & git reset --quiet --hard $preservedCommit
            $indexOnlyPath = Join-Path $fixtureRoot "docs\staged-only.md"
            [System.IO.File]::WriteAllText($indexOnlyPath, "# 暂存区带 BOM`n", $utf8Bom)
            & git add --all
            Remove-Item -LiteralPath $indexOnlyPath -Force
            $indexOnlyReportPath = Join-Path $fixtureRoot "staged-index-only.txt"
            $indexOnlyRaw = @(& $pwshCommand.Source -NoLogo -NoProfile -File $checkerPath `
                -Mode Staged -OutputPath $indexOnlyReportPath -LogLevel Quiet 2>&1)
            $indexOnlyExit = $LASTEXITCODE
            Assert-True ($indexOnlyExit -ne 0) "staged file missing only from the working tree was filtered out: $([string]::Join([Environment]::NewLine, $indexOnlyRaw))"
        } finally {
            Pop-Location
        }
    } finally {
        if (Test-Path -LiteralPath $fixtureRoot -PathType Container) {
            $resolvedFixture = [System.IO.Path]::GetFullPath($fixtureRoot)
            Assert-True ($resolvedFixture.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase)) "refusing unsafe encoding fixture cleanup"
            Remove-Item -LiteralPath $resolvedFixture -Recurse -Force -ErrorAction Stop
        }
    }
}

Write-Output "Codex governance audit tests: passes=$passes failures=$($failures.Count)"
foreach ($failure in $failures) {
    Write-Output "FAIL: $failure"
}

if ($failures.Count -gt 0) {
    exit 1
}
exit 0

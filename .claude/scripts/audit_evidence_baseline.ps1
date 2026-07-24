param(
    [string]$ProjectRoot = "",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
    } else {
        $ProjectRoot = (Get-Location).Path
    }
}

$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$claudeRoot = Join-Path $ProjectRoot ".claude"
$configRoot = Join-Path $claudeRoot "config"
$reportRoot = Join-Path $claudeRoot "reports"
$contractPath = Join-Path $configRoot "evidence-contract.json"
$authorityPath = Join-Path $configRoot "source-authority.json"
$gatePolicyPath = Join-Path $configRoot "gate-policy.json"

function Write-Utf8NoBom {
    param(
        [string]$FilePath,
        [string]$Text
    )
    $dir = Split-Path -Parent $FilePath
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($FilePath, $Text, $utf8NoBom)
}

function Load-JsonOrNull {
    param([string]$Path)
    if (-not (Test-Path $Path -PathType Leaf)) {
        return $null
    }
    try {
        return (Get-Content -Raw -Encoding UTF8 $Path | ConvertFrom-Json)
    } catch {
        return $null
    }
}

function Test-FileExists {
    param([string]$RelativePath)
    $fullPath = Join-Path $ProjectRoot $RelativePath
    return (Test-Path $fullPath -PathType Leaf)
}

function Get-FileAgeHours {
    param([string]$RelativePath)
    $fullPath = Join-Path $ProjectRoot $RelativePath
    if (-not (Test-Path $fullPath -PathType Leaf)) {
        return $null
    }
    $fileTime = (Get-Item $fullPath).LastWriteTimeUtc
    $now = [DateTime]::UtcNow
    return ($now - $fileTime).TotalHours
}

function Get-JsonPropertyArray {
    param(
        [object]$Root,
        [string]$PropertyPath
    )

    if ($null -eq $Root -or [string]::IsNullOrWhiteSpace($PropertyPath)) {
        return @()
    }

    $current = $Root
    foreach ($segment in ($PropertyPath -split '\.')) {
        if ($null -eq $current) {
            return @()
        }
        $current = $current.$segment
    }

    if ($null -eq $current) {
        return @()
    }

    return @($current)
}

function Get-AuthorityRegistry {
    param(
        [object]$AuthorityMap,
        [string]$Key,
        [string]$DefaultPath,
        [string]$DefaultCollection,
        [string]$DefaultIdField = "id"
    )

    $registry = if ($null -ne $AuthorityMap -and $null -ne $AuthorityMap.canonical_registries) {
        $AuthorityMap.canonical_registries.$Key
    } else {
        $null
    }

    return @{
        key = $Key
        path = if ($null -ne $registry -and -not [string]::IsNullOrWhiteSpace([string]$registry.path)) { [string]$registry.path } else { $DefaultPath }
        collection = if ($null -ne $registry -and -not [string]::IsNullOrWhiteSpace([string]$registry.collection)) { [string]$registry.collection } else { $DefaultCollection }
        id_field = if ($null -ne $registry -and -not [string]::IsNullOrWhiteSpace([string]$registry.id_field)) { [string]$registry.id_field } else { $DefaultIdField }
        class = if ($null -ne $registry -and -not [string]::IsNullOrWhiteSpace([string]$registry.class)) { [string]$registry.class } else { "unknown" }
    }
}

function Get-RegistryIds {
    param(
        [object]$Document,
        [string]$CollectionPath,
        [string]$IdField
    )

    $items = @(Get-JsonPropertyArray -Root $Document -PropertyPath $CollectionPath)
    $ids = @()

    foreach ($item in $items) {
        $value = $item
        foreach ($segment in ($IdField -split '\.')) {
            if ($null -eq $value) {
                break
            }
            $value = $value.$segment
        }

        $text = [string]$value
        if (-not [string]::IsNullOrWhiteSpace($text)) {
            $ids += $text
        }
    }

    return @($ids | Sort-Object -Unique)
}

function Load-RegistryDocument {
    param(
        [hashtable]$Cache,
        [string]$RelativePath
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        return $null
    }

    if ($Cache.ContainsKey($RelativePath)) {
        return $Cache[$RelativePath]
    }

    $fullPath = Join-Path $ProjectRoot $RelativePath
    $doc = Load-JsonOrNull -Path $fullPath
    $Cache[$RelativePath] = $doc
    return $doc
}

$contract = Load-JsonOrNull -Path $contractPath
if ($null -eq $contract) {
    throw "Failed to load evidence contract: $contractPath"
}

$authorityMap = Load-JsonOrNull -Path $authorityPath
$gatePolicy = Load-JsonOrNull -Path $gatePolicyPath
if ($null -eq $gatePolicy) {
    Write-Warning "Gate policy not found at $gatePolicyPath - will use default pass/warn/fail logic"
}
$registryDocumentCache = @{}

$result = @{
    schema_version = "1.0.0"
    audit_timestamp = [DateTime]::UtcNow.ToString("o")
    project_root = $ProjectRoot
    contract_version = $contract.schema_version
    evidence_baseline = @{
        static_consistency = @{}
        runtime_evidence = @{}
    }
    summary = @{
        total_items = 0
        verified_count = 0
        stale_count = 0
        partial_count = 0
        missing_count = 0
        unproven_count = 0
        overall_status = "unknown"
    }
    baseline_compliance = @{}
    gate_decision = @{
        overall_decision = "unknown"
        decision_reason = ""
        triggered_rules = @()
        severity_levels = @{}
    }
}

function Add-EvidenceItem {
    param(
        [hashtable]$CategoryResult,
        [string]$Id,
        [string]$Name,
        [string]$Description,
        [string]$State,
        [hashtable]$Details
    )

    $CategoryResult[$Id] = @{
        name = $Name
        description = $Description
        state = $State
        details = $Details
    }

    $result.summary.total_items++
    switch ($State) {
        "verified" { $result.summary.verified_count++ }
        "stale" { $result.summary.stale_count++ }
        "partial" { $result.summary.partial_count++ }
        "missing" { $result.summary.missing_count++ }
        "unproven" { $result.summary.unproven_count++ }
    }
}

# ===== Static Consistency Checks =====

foreach ($cat in $contract.evidence_types.static_consistency.categories) {
    $catResult = @{}
    $catId = $cat.id

    switch ($catId) {
        "entry_files" {
            $missingFiles = @()
            $allPresent = $true
            foreach ($file in $cat.required_files) {
                if (-not (Test-FileExists -RelativePath $file)) {
                    $missingFiles += $file
                    $allPresent = $false
                }
            }

            $state = if ($allPresent) { "verified" } else { "partial" }
            Add-EvidenceItem -CategoryResult $catResult -Id "entry_files" -Name $cat.name -Description $cat.description -State $state -Details @{
                required_files = $cat.required_files
                missing_files = if ($missingFiles.Count -gt 0) { $missingFiles } else { @() }
                partial = (-not $allPresent)
            }
        }

        "config_files" {
            $missingFiles = @()
            $allPresent = $true
            foreach ($file in $cat.required_files) {
                if (-not (Test-FileExists -RelativePath $file)) {
                    $missingFiles += $file
                    $allPresent = $false
                }
            }

            $state = if ($allPresent) { "verified" } else { "partial" }
            Add-EvidenceItem -CategoryResult $catResult -Id "config_files" -Name $cat.name -Description $cat.description -State $state -Details @{
                required_files = $cat.required_files
                missing_files = if ($missingFiles.Count -gt 0) { $missingFiles } else { @() }
                partial = (-not $allPresent)
            }
        }

        "authority_boundary" {
            if ($null -eq $authorityMap) {
                Add-EvidenceItem -CategoryResult $catResult -Id "authority_boundary" -Name $cat.name -Description $cat.description -State "missing" -Details @{
                    authority_map_path = ".claude/config/source-authority.json"
                    missing_files = @(".claude/config/source-authority.json")
                    missing_classes = @("primary_fact_source", "derived_view", "bridge_sidecar", "runtime_truth_checkpoint", "report_artifact")
                    missing_registries = @("route_agents", "route_skills", "route_workflows", "route_proxies")
                    controlled_exceptions = @()
                }
                break
            }

            $requiredClasses = @("primary_fact_source", "derived_view", "bridge_sidecar", "runtime_truth_checkpoint", "report_artifact")
            $requiredRegistries = @("route_agents", "route_skills", "route_workflows", "route_proxies")
            $classCounts = @{}
            $missingClasses = @()
            $missingArtifacts = @()
            $missingRegistries = @()

            foreach ($artifact in @($authorityMap.artifacts)) {
                $artifactClass = [string]$artifact.class
                $artifactPath = [string]$artifact.path
                if (-not [string]::IsNullOrWhiteSpace($artifactClass)) {
                    if (-not $classCounts.ContainsKey($artifactClass)) {
                        $classCounts[$artifactClass] = 0
                    }
                    $classCounts[$artifactClass]++
                }
                if (-not [string]::IsNullOrWhiteSpace($artifactPath) -and $artifactPath -notlike "*`**") {
                    if (-not (Test-FileExists -RelativePath $artifactPath)) {
                        $missingArtifacts += $artifactPath
                    }
                }
            }

            foreach ($requiredClass in $requiredClasses) {
                if (-not $classCounts.ContainsKey($requiredClass)) {
                    $missingClasses += $requiredClass
                }
            }

            foreach ($registryKey in $requiredRegistries) {
                $registry = if ($null -ne $authorityMap.canonical_registries) { $authorityMap.canonical_registries.$registryKey } else { $null }
                if ($null -eq $registry) {
                    $missingRegistries += $registryKey
                    continue
                }
                $registryPath = [string]$registry.path
                $registryCollection = [string]$registry.collection
                if ([string]::IsNullOrWhiteSpace($registryPath) -or [string]::IsNullOrWhiteSpace($registryCollection) -or -not (Test-FileExists -RelativePath $registryPath)) {
                    $missingRegistries += $registryKey
                }
            }

            $state = if ($missingClasses.Count -eq 0 -and $missingArtifacts.Count -eq 0 -and $missingRegistries.Count -eq 0) { "verified" } else { "partial" }
            Add-EvidenceItem -CategoryResult $catResult -Id "authority_boundary" -Name $cat.name -Description $cat.description -State $state -Details @{
                authority_map_path = ".claude/config/source-authority.json"
                class_counts = $classCounts
                missing_classes = if ($missingClasses.Count -gt 0) { $missingClasses } else { @() }
                missing_artifacts = if ($missingArtifacts.Count -gt 0) { $missingArtifacts } else { @() }
                missing_registries = if ($missingRegistries.Count -gt 0) { $missingRegistries } else { @() }
                controlled_exceptions = if ($null -ne $authorityMap.controlled_exceptions) { @($authorityMap.controlled_exceptions) } else { @() }
                partial = ($missingClasses.Count -gt 0 -or $missingArtifacts.Count -gt 0 -or $missingRegistries.Count -gt 0)
            }
        }

        "codex_native" {
            $missingFiles = @()
            $allPresent = $true
            foreach ($file in $cat.required_files) {
                if (-not (Test-FileExists -RelativePath $file)) {
                    $missingFiles += $file
                    $allPresent = $false
                }
            }

            $state = if ($allPresent) { "verified" } else { "partial" }
            Add-EvidenceItem -CategoryResult $catResult -Id "codex_native" -Name $cat.name -Description $cat.description -State $state -Details @{
                required_files = $cat.required_files
                missing_files = if ($missingFiles.Count -gt 0) { $missingFiles } else { @() }
                partial = (-not $allPresent)
            }
        }

        "manifest_references" {
            $router = Load-JsonOrNull -Path (Join-Path $configRoot "router.json")

            $agentRegistry = Get-AuthorityRegistry -AuthorityMap $authorityMap -Key "route_agents" -DefaultPath ".claude/config/agents.manifest.json" -DefaultCollection "agents"
            $skillRegistry = Get-AuthorityRegistry -AuthorityMap $authorityMap -Key "route_skills" -DefaultPath ".claude/config/skills.manifest.json" -DefaultCollection "skills"
            $workflowRegistry = Get-AuthorityRegistry -AuthorityMap $authorityMap -Key "route_workflows" -DefaultPath ".claude/config/workflows.manifest.json" -DefaultCollection "workflows"
            $proxyRegistry = Get-AuthorityRegistry -AuthorityMap $authorityMap -Key "route_proxies" -DefaultPath ".claude/config/proxies.manifest.json" -DefaultCollection "proxies"

            $agentDocument = Load-RegistryDocument -Cache $registryDocumentCache -RelativePath $agentRegistry.path
            $skillDocument = Load-RegistryDocument -Cache $registryDocumentCache -RelativePath $skillRegistry.path
            $workflowDocument = Load-RegistryDocument -Cache $registryDocumentCache -RelativePath $workflowRegistry.path
            $proxyDocument = Load-RegistryDocument -Cache $registryDocumentCache -RelativePath $proxyRegistry.path

            $agentIds = @(Get-RegistryIds -Document $agentDocument -CollectionPath $agentRegistry.collection -IdField $agentRegistry.id_field)
            $skillIds = @(Get-RegistryIds -Document $skillDocument -CollectionPath $skillRegistry.collection -IdField $skillRegistry.id_field)
            $workflowIds = @(Get-RegistryIds -Document $workflowDocument -CollectionPath $workflowRegistry.collection -IdField $workflowRegistry.id_field)
            $proxyIds = @(Get-RegistryIds -Document $proxyDocument -CollectionPath $proxyRegistry.collection -IdField $proxyRegistry.id_field)

            $brokenRefs = @()
            $allValid = $true

            if ($null -ne $router) {
                foreach ($route in $router.intent_routes) {
                    if ($null -ne $route.primary_agent) {
                        $agentExists = $agentIds -contains [string]$route.primary_agent
                        if (-not $agentExists) {
                            $brokenRefs += "Router intent '$($route.intent)' references unknown agent: $($route.primary_agent)"
                            $allValid = $false
                        }
                    }
                    if ($null -ne $route.default_proxy -and -not [string]::IsNullOrWhiteSpace([string]$route.default_proxy)) {
                        $proxyExists = $proxyIds -contains [string]$route.default_proxy
                        if (-not $proxyExists) {
                            $brokenRefs += "Router intent '$($route.intent)' references unknown proxy: $($route.default_proxy)"
                            $allValid = $false
                        }
                    }
                    if ($null -ne $route.skills) {
                        foreach ($skillId in $route.skills) {
                            $skillExists = $skillIds -contains [string]$skillId
                            if (-not $skillExists) {
                                $brokenRefs += "Router intent '$($route.intent)' references unknown skill: $skillId"
                                $allValid = $false
                            }
                        }
                    }
                    if ($null -ne $route.workflow_id) {
                        $workflowExists = $workflowIds -contains [string]$route.workflow_id
                        if (-not $workflowExists) {
                            $brokenRefs += "Router intent '$($route.intent)' references unknown workflow: $($route.workflow_id)"
                            $allValid = $false
                        }
                    }
                    if ($null -ne $route.workflow_candidates) {
                        foreach ($workflowCandidate in $route.workflow_candidates) {
                            $workflowCandidateExists = $workflowIds -contains [string]$workflowCandidate
                            if (-not $workflowCandidateExists) {
                                $brokenRefs += "Router intent '$($route.intent)' references unknown workflow candidate: $workflowCandidate"
                                $allValid = $false
                            }
                        }
                    }
                }
            }

            $state = if ($allValid) { "verified" } else { "partial" }
            Add-EvidenceItem -CategoryResult $catResult -Id "manifest_references" -Name $cat.name -Description $cat.description -State $state -Details @{
                canonical_registries = @{
                    agents = $agentRegistry
                    skills = $skillRegistry
                    workflows = $workflowRegistry
                    proxies = $proxyRegistry
                }
                broken_references = if ($brokenRefs.Count -gt 0) { $brokenRefs } else { @() }
                partial = (-not $allValid)
            }
        }

        "router_intents" {
            $router = Load-JsonOrNull -Path (Join-Path $configRoot "router.json")
            $missingMappings = @()
            $allMapped = $true

            if ($null -ne $router) {
                foreach ($route in $router.intent_routes) {
                    $hasAgent = $null -ne $route.primary_agent
                    $hasSkills = $null -ne $route.skills -and $route.skills.Count -gt 0
                    $hasWorkflow = $null -ne $route.workflow_id

                    if (-not $hasAgent -and -not $hasSkills -and -not $hasWorkflow) {
                        $missingMappings += "Router intent '$($route.intent)' has no agent/skill/workflow mapping"
                        $allMapped = $false
                    }
                }
            }

            $state = if ($allMapped) { "verified" } else { "partial" }
            Add-EvidenceItem -CategoryResult $catResult -Id "router_intents" -Name $cat.name -Description $cat.description -State $state -Details @{
                unmapped_intents = if ($missingMappings.Count -gt 0) { $missingMappings } else { @() }
                partial = (-not $allMapped)
            }
        }
    }

    $result.evidence_baseline.static_consistency[$catId] = $catResult[$catId]
}

# ===== Runtime Evidence Completeness Checks =====

foreach ($cat in $contract.evidence_types.runtime_evidence.categories) {
    $catResult = @{}
    $catId = $cat.id

    switch ($catId) {
        "audit_reports" {
            $staleReports = @()
            $missingReports = @()
            $allFresh = $true
            $maxAgeHours = $contract.audit_triggers.report_freshness_hours

            foreach ($report in $cat.required_reports) {
                $reportName = [string]$report
                $isRelativeReportPath = $reportName.Contains('/') -or $reportName.Contains('\')
                $reportRelativePath = if ($isRelativeReportPath) { $reportName -replace '/', '\' } else { ".claude/reports/$reportName" }
                $reportPath = if ($isRelativeReportPath) { Join-Path $ProjectRoot $reportRelativePath } else { Join-Path $reportRoot $reportName }
                if (-not (Test-Path $reportPath -PathType Leaf)) {
                    $missingReports += $reportName
                    $allFresh = $false
                } else {
                    $age = Get-FileAgeHours -RelativePath $reportRelativePath
                    if ($null -ne $age -and $age -gt $maxAgeHours) {
                        $staleReports += @{
                            report = $reportName
                            report_path = $reportRelativePath
                            age_hours = [math]::Round($age, 2)
                        }
                        $allFresh = $false
                    }
                }
            }

            $state = if ($missingReports.Count -gt 0) { "missing" } elseif ($staleReports.Count -gt 0) { "stale" } else { "verified" }
            Add-EvidenceItem -CategoryResult $catResult -Id "audit_reports" -Name $cat.name -Description $cat.description -State $state -Details @{
                required_reports = $cat.required_reports
                missing_reports = if ($missingReports.Count -gt 0) { $missingReports } else { @() }
                stale_reports = if ($staleReports.Count -gt 0) { $staleReports } else { @() }
                max_age_hours = $maxAgeHours
                stale = ($staleReports.Count -gt 0)
                missing = ($missingReports.Count -gt 0)
            }
        }

        "runtime_dependency_audit" {
            $reportRelativePath = "tools/reports/runtime-dependency-audit.json"
            $reportPath = Join-Path $ProjectRoot $reportRelativePath
            $hasReport = Test-Path $reportPath -PathType Leaf
            $age = if ($hasReport) { Get-FileAgeHours -RelativePath $reportRelativePath } else { $null }
            $maxAgeHours = $contract.audit_triggers.report_freshness_hours
            $runtimeDependencyReport = if ($hasReport) { Load-JsonOrNull -Path $reportPath } else { $null }

            $driftHighCount = 0
            $missingDepHighCount = 0
            $familyHighCount = 0
            $parseError = $false

            if ($hasReport) {
                if ($null -ne $runtimeDependencyReport -and $null -ne $runtimeDependencyReport.Summary) {
                    $summary = $runtimeDependencyReport.Summary
                    $driftHighCount = if ($null -ne $summary.DriftHighCount) { [int]$summary.DriftHighCount } else { 0 }
                    $missingDepHighCount = if ($null -ne $summary.MissingDepHighCount) { [int]$summary.MissingDepHighCount } else { 0 }
                    $familyHighCount = if ($null -ne $summary.FamilyHighCount) { [int]$summary.FamilyHighCount } else { 0 }
                } else {
                    $parseError = $true
                }
            }

            $highIssueTotal = $driftHighCount + $missingDepHighCount + $familyHighCount
            $state = if (-not $hasReport) {
                "missing"
            } elseif ($null -ne $age -and $age -gt $maxAgeHours) {
                "stale"
            } elseif ($parseError -or $highIssueTotal -gt 0) {
                "partial"
            } else {
                "verified"
            }

            Add-EvidenceItem -CategoryResult $catResult -Id "runtime_dependency_audit" -Name $cat.name -Description $cat.description -State $state -Details @{
                report_path = $reportRelativePath
                has_report = $hasReport
                age_hours = if ($null -ne $age) { [math]::Round($age, 2) } else { $null }
                max_age_hours = $maxAgeHours
                drift_high_count = $driftHighCount
                missing_dep_high_count = $missingDepHighCount
                family_high_count = $familyHighCount
                high_issue_total = $highIssueTotal
                parse_error = $parseError
                missing = (-not $hasReport)
            }
        }

        "session_trace" {
            # Phase 1: Mark as unproven
            Add-EvidenceItem -CategoryResult $catResult -Id "session_trace" -Name $cat.name -Description $cat.description -State "unproven" -Details @{
                note = $cat.note
                unproven = $true
                phase = "1"
                automation_status = "pending"
            }
        }

        "mcp_runtime" {
            # Check for manual codex mcp list evidence
            $mcpEvidencePath = Join-Path $reportRoot "mcp-runtime-snapshot.json"
            $hasEvidence = Test-Path $mcpEvidencePath -PathType Leaf
            $age = if ($hasEvidence) { Get-FileAgeHours -RelativePath ".claude/reports/mcp-runtime-snapshot.json" } else { $null }

            $state = if (-not $hasEvidence) { "missing" } elseif ($null -ne $age -and $age -gt 24) { "stale" } else { "verified" }
            Add-EvidenceItem -CategoryResult $catResult -Id "mcp_runtime" -Name $cat.name -Description $cat.description -State $state -Details @{
                evidence_path = ".claude/reports/mcp-runtime-snapshot.json"
                has_evidence = $hasEvidence
                age_hours = if ($null -ne $age) { [math]::Round($age, 2) } else { $null }
                note = $cat.note
                unproven = (-not $hasEvidence)
            }
        }

        "quality_gate_status" {
            $qgReportPath = Join-Path $reportRoot "quality-gate-report.json"
            $hasReport = Test-Path $qgReportPath -PathType Leaf
            $age = if ($hasReport) { Get-FileAgeHours -RelativePath ".claude/reports/quality-gate-report.json" } else { $null }
            $maxAgeHours = $contract.audit_triggers.report_freshness_hours

            $status = if ($hasReport) {
                $qgReport = Load-JsonOrNull -Path $qgReportPath
                if ($null -ne $qgReport -and $null -ne $qgReport.overall_status) {
                    $qgReport.overall_status
                } else {
                    "unknown"
                }
            } else {
                "no_report"
            }

            $state = if (-not $hasReport) {
                "missing"
            } elseif ($null -ne $age -and $age -gt $maxAgeHours) {
                "stale"
            } elseif ($status -eq "pass") {
                "verified"
            } elseif ($status -eq "fail") {
                "partial"
            } else {
                "stale"
            }
            Add-EvidenceItem -CategoryResult $catResult -Id "quality_gate_status" -Name $cat.name -Description $cat.description -State $state -Details @{
                report_path = ".claude/reports/quality-gate-report.json"
                has_report = $hasReport
                status = $status
                age_hours = if ($null -ne $age) { [math]::Round($age, 2) } else { $null }
                max_age_hours = $maxAgeHours
                missing = (-not $hasReport)
            }
        }
    }

    $result.evidence_baseline.runtime_evidence[$catId] = $catResult[$catId]
}

# ===== Calculate Overall Status =====

$staticVerified = 0
$staticTotal = 0
foreach ($item in $result.evidence_baseline.static_consistency.Values) {
    $staticTotal++
    if ($item.state -eq "verified") {
        $staticVerified++
    }
}
$staticCompliance = if ($staticTotal -gt 0) { [math]::Round(($staticVerified / $staticTotal) * 100, 1) } else { 0 }

$runtimeVerified = 0
$runtimeTotal = 0
foreach ($item in $result.evidence_baseline.runtime_evidence.Values) {
    $runtimeTotal++
    if ($item.state -eq "verified") {
        $runtimeVerified++
    }
}
$runtimeCompliance = if ($runtimeTotal -gt 0) { [math]::Round(($runtimeVerified / $runtimeTotal) * 100, 1) } else { 0 }

$result.baseline_compliance = @{
    static_consistency = @{
        verified_count = $staticVerified
        total_count = $staticTotal
        compliance_percent = $staticCompliance
        meets_minimum = ($staticCompliance -ge 100)
    }
    runtime_evidence = @{
        verified_count = $runtimeVerified
        total_count = $runtimeTotal
        compliance_percent = $runtimeCompliance
        meets_minimum = ($runtimeCompliance -ge 50)
    }
    unproven_tolerance = @{
        unproven_count = $result.summary.unproven_count
        max_allowed = $contract.baseline_requirements.unproven_tolerance.max_unproven_count
        within_tolerance = ($result.summary.unproven_count -le $contract.baseline_requirements.unproven_tolerance.max_unproven_count)
    }
}

$overallStatus = "pass"
if ($result.baseline_compliance.static_consistency.meets_minimum -eq $false) {
    $overallStatus = "fail"
} elseif ($result.baseline_compliance.runtime_evidence.meets_minimum -eq $false) {
    $overallStatus = "warn"
} elseif ($result.baseline_compliance.unproven_tolerance.within_tolerance -eq $false) {
    $overallStatus = "warn"
}

$result.summary.overall_status = $overallStatus

# ===== Gate Decision Evaluation =====

function Test-Condition {
    param(
        [hashtable]$EvidenceState,
        [string]$Condition
    )
    
    # Parse simple conditions like "static_compliance < 100"
    if ($Condition -match '^(\w+)\s*(<|<=|>|>=|==|!=)\s*(\d+)$') {
        $field = $Matches[1]
        $operator = $Matches[2]
        $value = [int]$Matches[3]
        
        $actualValue = switch ($field) {
            "static_compliance" { $result.baseline_compliance.static_consistency.compliance_percent }
            "runtime_compliance" { $result.baseline_compliance.runtime_evidence.compliance_percent }
            "unproven_count" { $result.baseline_compliance.unproven_tolerance.unproven_count }
            "max_allowed" { $result.baseline_compliance.unproven_tolerance.max_allowed }
            default { $null }
        }
        
        if ($null -eq $actualValue) { return $false }
        
        switch ($operator) {
            "<"  { return $actualValue -lt $value }
            "<=" { return $actualValue -le $value }
            ">"  { return $actualValue -gt $value }
            ">=" { return $actualValue -ge $value }
            "==" { return $actualValue -eq $value }
            "!=" { return $actualValue -ne $value }
            default { return $false }
        }
    }
    
    # Parse nested conditions like "entry_files.state == 'missing'"
    if ($Condition -match '^(\w+)\.(\w+)\s*==\s*["'']?(\w+)["'']?$') {
        $category = $Matches[1]
        $field = $Matches[2]
        $expected = $Matches[3]
        
        $item = if ($result.evidence_baseline.static_consistency.ContainsKey($category)) {
            $result.evidence_baseline.static_consistency[$category]
        } elseif ($result.evidence_baseline.runtime_evidence.ContainsKey($category)) {
            $result.evidence_baseline.runtime_evidence[$category]
        } else {
            $null
        }
        
        if ($null -eq $item) { return $false }
        
        $actualValue = if ($item.ContainsKey($field)) {
            $item[$field]
        } elseif ($item.ContainsKey("details") -and $item.details.ContainsKey($field)) {
            $item.details[$field]
        } else {
            $null
        }
        return ($actualValue -eq $expected)
    }
    
    # Parse array conditions like "missing_files contains 'router.json'"
    if ($Condition -match '^(\w+)\.(\w+)\s+contains\s+["'']?(.+)["'']?$') {
        $category = $Matches[1]
        $field = $Matches[2]
        $searchValue = $Matches[3]
        
        $item = if ($result.evidence_baseline.static_consistency.ContainsKey($category)) {
            $result.evidence_baseline.static_consistency[$category]
        } elseif ($result.evidence_baseline.runtime_evidence.ContainsKey($category)) {
            $result.evidence_baseline.runtime_evidence[$category]
        } else {
            $null
        }
        
        if ($null -eq $item) { return $false }
        
        if ($item.ContainsKey("details") -and $item.details.ContainsKey($field)) {
            $array = $item.details[$field]
            if ($array -is [array]) {
                return $array -contains $searchValue
            }
        }
        
        return $false
    }
    
    # Parse array length conditions like "broken_references.length > 0"
    if ($Condition -match '^(\w+)\.(\w+)\.length\s*(<|<=|>|>=|==|!=)\s*(\d+)$') {
        $category = $Matches[1]
        $field = $Matches[2]
        $operator = $Matches[3]
        $value = [int]$Matches[4]
        
        $item = if ($result.evidence_baseline.static_consistency.ContainsKey($category)) {
            $result.evidence_baseline.static_consistency[$category]
        } elseif ($result.evidence_baseline.runtime_evidence.ContainsKey($category)) {
            $result.evidence_baseline.runtime_evidence[$category]
        } else {
            $null
        }
        
        if ($null -eq $item) { return $false }
        
        if ($item.ContainsKey("details") -and $item.details.ContainsKey($field)) {
            $array = $item.details[$field]
            if ($array -is [array]) {
                $actualLength = $array.Count
                switch ($operator) {
                    "<"  { return $actualLength -lt $value }
                    "<=" { return $actualLength -le $value }
                    ">"  { return $actualLength -gt $value }
                    ">=" { return $actualLength -ge $value }
                    "==" { return $actualLength -eq $value }
                    "!=" { return $actualLength -ne $value }
                    default { return $false }
                }
            }
        }
        
        return $false
    }
    
    return $false
}

function Evaluate-GateDecision {
    param()
    
    if ($null -eq $gatePolicy) {
        # Fallback to old logic
        $result.gate_decision.overall_decision = if ($overallStatus -eq "pass") { "allow" } elseif ($overallStatus -eq "warn") { "review_required" } else { "block" }
        $result.gate_decision.decision_reason = "Gate policy not available, using legacy status: $overallStatus"
        return
    }
    
    $triggeredRules = @()
    $severityCounts = @{
        critical = 0
        high = 0
        medium = 0
        low = 0
    }
    
    # Evaluate all rules
    foreach ($ruleGroup in @($gatePolicy.decision_rules.PSObject.Properties)) {
        $groupName = $ruleGroup.Name
        $groupRules = $ruleGroup.Value.rules
        
        foreach ($rule in $groupRules) {
            $condition = $rule.condition
            $severity = $rule.severity
            $decision = $rule.decision
            $reason = $rule.reason
            
            # Check if this is a controlled exception
            $isException = $false
            foreach ($exception in $gatePolicy.controlled_exceptions.exceptions) {
                if ($exception.applies_to -contains $groupName) {
                    $isException = $true
                    # Use override decision from exception
                    $triggeredRules += @{
                        rule_group = $groupName
                        condition = $condition
                        original_severity = $severity
                        original_decision = $decision
                        overridden = $true
                        exception_id = $exception.id
                        exception_reason = $exception.reason
                        final_decision = $exception.override_decision
                        final_severity = "low"  # Exceptions are treated as low severity
                        reason = "$reason (受控例外: $($exception.reason))"
                    }
                    break
                }
            }
            
            if (-not $isException) {
                # Evaluate condition
                if (Test-Condition -EvidenceState $result -Condition $condition) {
                    $triggeredRules += @{
                        rule_group = $groupName
                        condition = $condition
                        severity = $severity
                        decision = $decision
                        overridden = $false
                        reason = $reason
                    }
                    $severityCounts[$severity]++
                }
            }
        }
    }
    
    $result.gate_decision.triggered_rules = $triggeredRules
    $result.gate_decision.severity_levels = $severityCounts
    
    # Determine overall decision based on highest severity
    $overallDecision = "allow"
    $overallReason = "All checks passed with no blocking risk."
    
    if ($severityCounts.critical -gt 0) {
        $overallDecision = "block"
        $overallReason = "Detected $($severityCounts.critical) critical issue(s); remediation is required before continuing."
    } elseif ($severityCounts.high -gt 0) {
        $overallDecision = "review_required"
        $overallReason = "Detected $($severityCounts.high) high-risk item(s); manual review is required."
    } elseif ($severityCounts.medium -gt 0) {
        $overallDecision = "review_required"
        $overallReason = "Detected $($severityCounts.medium) medium-risk item(s); manual review is recommended."
    }
    
    $result.gate_decision.overall_decision = $overallDecision
    $result.gate_decision.decision_reason = $overallReason
}

Evaluate-GateDecision

# ===== Generate JSON Report =====

$timestamp = [DateTime]::UtcNow.ToString("yyyyMMdd-HHmmss")
$reportJsonPath = Join-Path $reportRoot "evidence-baseline-$timestamp.json"
$jsonOutput = $result | ConvertTo-Json -Depth 10
Write-Utf8NoBom -FilePath $reportJsonPath -Text $jsonOutput

# ===== Generate Markdown Report =====

$reportMdPath = Join-Path $reportRoot "evidence-baseline-$timestamp.md"
$mdLines = @(
    "# MT3 Governance Evidence Baseline Report",
    "",
    "> **Generated**: $($result.audit_timestamp)",
    "> **Project Root**: $($result.project_root)",
    "> **Contract Version**: $($result.contract_version)",
    "",
    "---",
    "",
    "## Gate Decision",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    "| **Overall Decision** | **$($result.gate_decision.overall_decision.ToUpper())** |",
    "| Decision Reason | $($result.gate_decision.decision_reason) |",
    "",
    "**Severity Distribution**:",
    "- Critical: $($result.gate_decision.severity_levels.critical)",
    "- High: $($result.gate_decision.severity_levels.high)",
    "- Medium: $($result.gate_decision.severity_levels.medium)",
    "- Low: $($result.gate_decision.severity_levels.low)",
    "",
    "---",
    "",
    "## Evidence Status Summary",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    "| Total Evidence Items | $($result.summary.total_items) |",
    "| Verified | $($result.summary.verified_count) |",
    "| Stale | $($result.summary.stale_count) |",
    "| Partial | $($result.summary.partial_count) |",
    "| Missing | $($result.summary.missing_count) |",
    "| Unproven | $($result.summary.unproven_count) |",
    "",
    "---",
    "",
    "## Baseline Compliance",
    "",
    "### Static Consistency",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    "| Verified Items | $($result.baseline_compliance.static_consistency.verified_count) / $($result.baseline_compliance.static_consistency.total_count) |",
    "| Compliance Rate | $($result.baseline_compliance.static_consistency.compliance_percent)% |",
    "| Meets Minimum | $($result.baseline_compliance.static_consistency.meets_minimum) |",
    "",
    "### Runtime Evidence Completeness",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    "| Verified Items | $($result.baseline_compliance.runtime_evidence.verified_count) / $($result.baseline_compliance.runtime_evidence.total_count) |",
    "| Compliance Rate | $($result.baseline_compliance.runtime_evidence.compliance_percent)% |",
    "| Meets Minimum | $($result.baseline_compliance.runtime_evidence.meets_minimum) |",
    "",
    "### Unproven Tolerance",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    "| Unproven Items | $($result.baseline_compliance.unproven_tolerance.unproven_count) |",
    "| Max Allowed | $($result.baseline_compliance.unproven_tolerance.max_allowed) |",
    "| Within Tolerance | $($result.baseline_compliance.unproven_tolerance.within_tolerance) |",
    "",
    "---",
    "",
    "## Static Consistency Details",
    ""
)

foreach ($catId in $result.evidence_baseline.static_consistency.Keys) {
    $cat = $result.evidence_baseline.static_consistency[$catId]
    $catState = if ($null -ne $cat -and $cat.ContainsKey("state")) { $cat.state } else { "unknown" }
    $stateIcon = switch ($catState) {
        "verified" { "OK" }
        "stale" { "WARN" }
        "partial" { "PARTIAL" }
        "missing" { "FAIL" }
        "unproven" { "UNPROVEN" }
        default { "UNKNOWN" }
    }

    $mdLines += "### [$($stateIcon)] $($cat.name)"
    $mdLines += ""
    $mdLines += "**Status**: $($catState.ToUpper())"
    $mdLines += "**Description**: $($cat.description)"
    $mdLines += ""

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("missing_files") -and $cat.details.missing_files.Count -gt 0) {
        $mdLines += "**Missing Files**:"
        foreach ($file in $cat.details.missing_files) {
            $mdLines += "- $file"
        }
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("broken_references") -and $cat.details.broken_references.Count -gt 0) {
        $mdLines += "**Broken References**:"
        foreach ($ref in $cat.details.broken_references) {
            $mdLines += "- $ref"
        }
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("missing_registries") -and $cat.details.missing_registries.Count -gt 0) {
        $mdLines += "**Missing Registries**:"
        foreach ($registryId in $cat.details.missing_registries) {
            $mdLines += "- $registryId"
        }
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("missing_artifacts") -and $cat.details.missing_artifacts.Count -gt 0) {
        $mdLines += "**Missing Artifacts**:"
        foreach ($artifactPath in $cat.details.missing_artifacts) {
            $mdLines += "- $artifactPath"
        }
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("controlled_exceptions") -and $cat.details.controlled_exceptions.Count -gt 0) {
        $mdLines += "**Controlled Exceptions**:"
        foreach ($exceptionItem in $cat.details.controlled_exceptions) {
            $mdLines += "- $($exceptionItem.id): $($exceptionItem.reason)"
        }
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("unmapped_intents") -and $cat.details.unmapped_intents.Count -gt 0) {
        $mdLines += "**Unmapped Intents**:"
        foreach ($intent in $cat.details.unmapped_intents) {
            $mdLines += "- $intent"
        }
        $mdLines += ""
    }
}

$mdLines += @(
    "---",
    "",
    "## Runtime Evidence Completeness Details",
    ""
)

foreach ($catId in $result.evidence_baseline.runtime_evidence.Keys) {
    $cat = $result.evidence_baseline.runtime_evidence[$catId]
    $catState = if ($null -ne $cat -and $cat.ContainsKey("state")) { $cat.state } else { "unknown" }
    $stateIcon = switch ($catState) {
        "verified" { "OK" }
        "stale" { "WARN" }
        "partial" { "PARTIAL" }
        "missing" { "FAIL" }
        "unproven" { "UNPROVEN" }
        default { "UNKNOWN" }
    }

    $mdLines += "### [$($stateIcon)] $($cat.name)"
    $mdLines += ""
    $mdLines += "**Status**: $($catState.ToUpper())"
    $mdLines += "**Description**: $($cat.description)"
    $mdLines += ""

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("missing_reports") -and $cat.details.missing_reports.Count -gt 0) {
        $mdLines += "**Missing Reports**:"
        foreach ($report in $cat.details.missing_reports) {
            $mdLines += "- $report"
        }
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("stale_reports") -and $cat.details.stale_reports.Count -gt 0) {
        $mdLines += "**Stale Reports** (max age: $($cat.details.max_age_hours) hours):"
        foreach ($report in $cat.details.stale_reports) {
            $mdLines += "- $($report.report) (stale for $($report.age_hours) hours)"
        }
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("note")) {
        $mdLines += "**Note**: $($cat.details.note)"
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("status")) {
        $mdLines += "**Quality Gate Status**: $($cat.details.status)"
        $mdLines += ""
    }

    if ($null -ne $cat -and $cat.ContainsKey("details") -and $cat.details.ContainsKey("high_issue_total")) {
        $mdLines += "**Runtime Dependency High Issues**: $($cat.details.high_issue_total)"
        $mdLines += "- DLL Drift High: $($cat.details.drift_high_count)"
        $mdLines += "- Missing Dependency High: $($cat.details.missing_dep_high_count)"
        $mdLines += "- Family Consistency High: $($cat.details.family_high_count)"
        if ($cat.details.parse_error) {
            $mdLines += "- Parse Error: true"
        }
        $mdLines += ""
    }
}

$mdLines += @(
    '---',
    '',
    '## Gate Decision Details',
    ''
)

if ($result.gate_decision.triggered_rules.Count -gt 0) {
    $mdLines += '**Triggered Rules**:'
    $mdLines += ''
    foreach ($rule in $result.gate_decision.triggered_rules) {
        $severityIcon = switch ($rule.final_severity -or $rule.severity) {
            "critical" { "[CRIT]" }
            "high" { "[HIGH]" }
            "medium" { "[MED]" }
            "low" { "[LOW]" }
            default { "[INFO]" }
        }
        $decisionBadge = switch ($rule.final_decision -or $rule.decision) {
            "block" { "[BLOCK]" }
            "review_required" { "[REVIEW]" }
            "allow" { "[ALLOW]" }
            default { "[?]" }
        }
        $mdLines += "$severityIcon **$decisionBadge** $($rule.reason)"
        if ($rule.overridden) {
            $mdLines += "  - *受控例外: $($exception.reason)*"
        }
        $mdLines += "  - Rule: $($rule.rule_group) - $($rule.condition)"
        $mdLines += ''
    }
} else {
    $mdLines += "No rules triggered - all checks passed."
    $mdLines += ''
}

$mdLines += @(
    '---',
    '',
    '## Next Steps',
    '',
    '### Phase 1 (Completed)',
    '',
    '- [x] Evidence contract defined',
    '- [x] Evidence baseline audit script implemented',
    '- [x] Minimal evidence model and baseline audit are in place',
    '',
    '### Phase 2 (Completed)',
    '',
    '- [x] source-authority.json classifies primary facts, derived views, bridge-sidecars, runtime checkpoints, and report artifacts',
    '- [x] route / manifest / skill references are validated via canonical registries',
    '- [x] compact compat entry_order drift is now tracked as a controlled auditable exception',
    '',
    '### Phase 3 (Current)',
    '',
    '- [x] Gate policy defined with decision rules (allow/review-required/block)',
    '- [x] Evidence baseline audit enhanced with gate decision evaluation',
    '- [x] High-risk missing evidence now triggers explicit gate decisions',
    '- [x] Controlled exceptions for observation gaps (e.g., session_trace)',
    '',
    '### Phase 4 (Out of Scope Here)',
    '',
    '- Session trace evidence automation',
    '- MCP runtime snapshot persistence automation',
    '- Stronger quality gate / hook enforcement',
    '- Evidence history trend analysis',
    '',
    '---',
    '',
    '**Report Paths**:',
    "- JSON: .claude/reports/evidence-baseline-$timestamp.json",
    "- Markdown: .claude/reports/evidence-baseline-$timestamp.md",
    '',
    '**Audit Script**: .claude/scripts/audit_evidence_baseline.ps1',
    '',
    '**Evidence Contract**: .claude/config/evidence-contract.json',
    '',
    '**Gate Policy**: .claude/config/gate-policy.json'
)

Write-Utf8NoBom -FilePath $reportMdPath -Text ($mdLines -join "`r`n")

# Output to console
Write-Host "=== MT3 Governance Evidence Baseline Audit ===" -ForegroundColor Cyan
Write-Host ""
$gateDecision = $result.gate_decision.overall_decision
Write-Host "Gate Decision: $($gateDecision.ToUpper())" -ForegroundColor $(switch ($gateDecision) { "allow" { "Green" } "review_required" { "Yellow" } "block" { "Red" } default { "White" } })
Write-Host "Reason: $($result.gate_decision.decision_reason)" -ForegroundColor $(switch ($gateDecision) { "allow" { "Green" } "review_required" { "Yellow" } "block" { "Red" } default { "White" } })
Write-Host ""
Write-Host "Severity Distribution:" -ForegroundColor Cyan
Write-Host "  Critical: $($result.gate_decision.severity_levels.critical)" -ForegroundColor $(if ($result.gate_decision.severity_levels.critical -gt 0) { "Red" } else { "Green" })
Write-Host "  High: $($result.gate_decision.severity_levels.high)" -ForegroundColor $(if ($result.gate_decision.severity_levels.high -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Medium: $($result.gate_decision.severity_levels.medium)" -ForegroundColor $(if ($result.gate_decision.severity_levels.medium -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Low: $($result.gate_decision.severity_levels.low)" -ForegroundColor Green
Write-Host ""
Write-Host "Evidence Status:" -ForegroundColor Cyan
Write-Host "  Static Consistency: $($staticCompliance)% ($staticVerified/$staticTotal)" -ForegroundColor $(if ($staticCompliance -ge 100) { "Green" } elseif ($staticCompliance -ge 50) { "Yellow" } else { "Red" })
Write-Host "  Runtime Evidence: $($runtimeCompliance)% ($runtimeVerified/$runtimeTotal)" -ForegroundColor $(if ($runtimeCompliance -ge 50) { "Green" } else { "Yellow" })
Write-Host "  Unproven Items: $($result.summary.unproven_count)/$($contract.baseline_requirements.unproven_tolerance.max_unproven_count)" -ForegroundColor $(if ($result.summary.unproven_count -le $contract.baseline_requirements.unproven_tolerance.max_unproven_count) { "Green" } else { "Red" })
Write-Host ""
if ($result.gate_decision.triggered_rules.Count -gt 0) {
    Write-Host "Triggered Rules:" -ForegroundColor Cyan
    foreach ($rule in $result.gate_decision.triggered_rules) {
        $severityColor = switch ($rule.final_severity -or $rule.severity) {
            "critical" { "Red" }
            "high" { "Yellow" }
            "medium" { "Yellow" }
            "low" { "Green" }
            default { "White" }
        }
        $decisionBadge = switch ($rule.final_decision -or $rule.decision) {
            "block" { "[BLOCK]" }
            "review_required" { "[REVIEW]" }
            "allow" { "[ALLOW]" }
            default { "[?]" }
        }
        Write-Host "  $decisionBadge $($rule.reason)" -ForegroundColor $severityColor
    }
    Write-Host ""
}
Write-Host "Reports generated:" -ForegroundColor Cyan
Write-Host "  - $reportJsonPath"
Write-Host "  - $reportMdPath"
Write-Host ""

if ($Verbose) {
    Write-Host "Detailed evidence status:" -ForegroundColor Cyan
    Write-Host ($result | ConvertTo-Json -Depth 5)
}

exit 0

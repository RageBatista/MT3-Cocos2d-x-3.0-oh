param(
    [string]$ProjectRoot = "",
    [switch]$LegacyStrict
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
$claudeRoot = Join-Path $ProjectRoot ".claude"
$configRoot = Join-Path $claudeRoot "config"
$reportRoot = Join-Path $claudeRoot "reports"

if (-not (Test-Path $claudeRoot)) {
    throw "Missing .claude directory: $claudeRoot"
}

$standardErrors = @()
$standardWarnings = @()
$legacyWarnings = @()

function Add-StdError {
    param([string]$Message)
    $script:standardErrors += $Message
}

function Add-StdWarning {
    param([string]$Message)
    $script:standardWarnings += $Message
}

function Add-LegacyWarning {
    param([string]$Message)
    if ($script:legacyWarnings.Count -lt 40) {
        $script:legacyWarnings += $Message
    }
}

function Load-JsonOrNull {
    param(
        [string]$Path,
        [string]$Name
    )
    if (-not (Test-Path $Path)) {
        Add-StdError "Missing config file: $Name ($Path)"
        return $null
    }
    try {
        return (Get-Content -Raw -Encoding UTF8 $Path | ConvertFrom-Json)
    } catch {
        Add-StdError "JSON parse failed: $Name :: $($_.Exception.Message)"
        return $null
    }
}

function ConvertTo-ObjectList {
    param([object]$Value)

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [string]) {
        return @($Value)
    }

    if ($Value -is [System.Array]) {
        return @($Value)
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        return @($Value | ForEach-Object { $_ })
    }

    if ($null -ne $Value.PSObject -and $Value.PSObject.Properties.Name -contains "value") {
        $nestedValue = $Value.value
        if ($null -eq $nestedValue) {
            return @()
        }
        if ($nestedValue -is [System.Collections.IEnumerable] -and -not ($nestedValue -is [string])) {
            return @($nestedValue | ForEach-Object { $_ })
        }
    }

    return @($Value)
}

function Resolve-PathSafe {
    param(
        [string]$Base,
        [string]$Relative
    )
    try {
        if ([System.IO.Path]::IsPathRooted($Relative)) {
            return [System.IO.Path]::GetFullPath($Relative)
        }
        return [System.IO.Path]::GetFullPath((Join-Path $Base $Relative))
    } catch {
        return $null
    }
}

function Write-Utf8NoBom {
    param(
        [string]$FilePath,
        [string]$Text
    )
    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        throw "Empty output path"
    }
    $dir = Split-Path -Parent $FilePath
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($FilePath, $Text, $enc)
}

function Invoke-PowerShellAudit {
    param(
        [string]$ScriptPath,
        [string]$ProjectRoot,
        [string]$Name
    )

    $result = [ordered]@{
        name = $Name
        exit_code = 1
        output = @()
    }

    if ([string]::IsNullOrWhiteSpace($ScriptPath) -or -not (Test-Path $ScriptPath -PathType Leaf)) {
        $result.output = @("Missing script: $ScriptPath")
        return [pscustomobject]$result
    }

    $hostCommand = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($null -eq $hostCommand) {
        $hostCommand = Get-Command pwsh -ErrorAction SilentlyContinue
    }
    if ($null -eq $hostCommand) {
        $hostCommand = Get-Command powershell.exe -ErrorAction SilentlyContinue
    }
    if ($null -eq $hostCommand) {
        $result.output = @("No PowerShell host is available for nested audit: $Name")
        return [pscustomobject]$result
    }

    try {
        $output = @(& $hostCommand.Source -NoLogo -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -ProjectRoot $ProjectRoot 2>&1)
        $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
        $result.exit_code = $exitCode
        $result.output = @($output | ForEach-Object { [string]$_ })
    } catch {
        $result.output = @($_.Exception.Message)
    }

    return [pscustomobject]$result
}

function Invoke-CodexMcpListJson {
    param(
        [string]$ProjectRoot,
        [string]$ReportRoot
    )

    $snapshotRelativePath = ".claude/reports/mcp-runtime-snapshot.json"
    $snapshotPath = Join-Path $ReportRoot "mcp-runtime-snapshot.json"
    $result = [ordered]@{
        status = "missing"
        command = "codex -C $ProjectRoot mcp list --json"
        exit_code = $null
        snapshot_path = $snapshotRelativePath
        configured_count = 0
        configured_servers = @()
        enabled_count = 0
        enabled_servers = @()
        errors = @()
        servers = @()
    }

    $codexCommand = Get-Command "codex" -ErrorAction SilentlyContinue
    if ($null -eq $codexCommand) {
        $result.errors = @("codex command not found")
        return [pscustomobject]$result
    }

    try {
        $output = @(& $codexCommand.Source -C $ProjectRoot mcp list --json 2>&1)
        $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
        $result.exit_code = $exitCode
        if ($exitCode -ne 0) {
            $result.status = "error"
            $result.errors = @($output | ForEach-Object { [string]$_ })
            return [pscustomobject]$result
        }

        $jsonText = [string]::Join([Environment]::NewLine, @($output | ForEach-Object { [string]$_ }))
        $serversRaw = $jsonText | ConvertFrom-Json
        $servers = @(ConvertTo-ObjectList -Value $serversRaw)
        if (
            $servers.Count -eq 1 -and
            $null -ne $servers[0] -and
            $null -ne $servers[0].PSObject -and
            $servers[0].PSObject.Properties.Name -contains "value"
        ) {
            $unwrappedServers = @(ConvertTo-ObjectList -Value $servers[0].value)
            if (@($unwrappedServers | Where-Object {
                $null -ne $_ -and
                $null -ne $_.PSObject -and
                $_.PSObject.Properties.Name -contains "name"
            }).Count -gt 0) {
                $servers = $unwrappedServers
            }
        }
        $enabledServers = @(
            $servers |
                Where-Object {
                    $null -ne $_ -and
                    $null -ne $_.PSObject -and
                    $_.PSObject.Properties.Name -contains "enabled" -and
                    [bool]$_.enabled
                } |
                ForEach-Object { [string]$_.name } |
                Sort-Object -Unique
        )
        $configuredServers = @(
            $servers |
                Where-Object {
                    $null -ne $_ -and
                    $null -ne $_.PSObject -and
                    $_.PSObject.Properties.Name -contains "name"
                } |
                ForEach-Object { [string]$_.name } |
                Sort-Object -Unique
        )
        $snapshot = [ordered]@{
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            project_root = $ProjectRoot
            command = $result.command
            total_servers = $configuredServers.Count
            configured_count = $configuredServers.Count
            configured_servers = $configuredServers
            enabled_count = $enabledServers.Count
            enabled_servers = $enabledServers
            servers = $servers
        }

        Write-Utf8NoBom -FilePath $snapshotPath -Text ($snapshot | ConvertTo-Json -Depth 20)

        $result.status = "captured"
        $result.configured_count = $configuredServers.Count
        $result.configured_servers = $configuredServers
        $result.enabled_count = $enabledServers.Count
        $result.enabled_servers = $enabledServers
        $result.servers = $servers
    } catch {
        $result.status = "error"
        $result.errors = @($_.Exception.Message)
    }

    return [pscustomobject]$result
}

function Remove-MarkdownCodeSegments {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) {
        return ""
    }
    $withoutBlocks = [regex]::Replace($Text, '(?ms)```.*?```', '')
    return [regex]::Replace($withoutBlocks, '`[^`]*`', '')
}

function Get-Threshold {
    param(
        [object]$QualityGates,
        [string]$Key,
        [string]$Level,
        [int]$DefaultValue
    )
    if ($null -eq $QualityGates) {
        return $DefaultValue
    }
    if ($null -eq $QualityGates.thresholds) {
        return $DefaultValue
    }
    $node = $QualityGates.thresholds.$Key
    if ($null -eq $node) {
        return $DefaultValue
    }
    $value = $node.$Level
    if ($null -eq $value) {
        return $DefaultValue
    }
    return [int]$value
}

$agentsManifest = Load-JsonOrNull -Path (Join-Path $configRoot "agents.manifest.json") -Name "agents.manifest.json"
$skillsManifest = Load-JsonOrNull -Path (Join-Path $configRoot "skills.manifest.json") -Name "skills.manifest.json"
$routerConfig = Load-JsonOrNull -Path (Join-Path $configRoot "router.json") -Name "router.json"
$workflowsManifest = Load-JsonOrNull -Path (Join-Path $configRoot "workflows.manifest.json") -Name "workflows.manifest.json"
$qualityGates = Load-JsonOrNull -Path (Join-Path $configRoot "quality-gates.json") -Name "quality-gates.json"
$evolutionConfig = Load-JsonOrNull -Path (Join-Path $configRoot "evolution.config.json") -Name "evolution.config.json"
$proxiesManifest = Load-JsonOrNull -Path (Join-Path $configRoot "proxies.manifest.json") -Name "proxies.manifest.json"
$commandsManifest = Load-JsonOrNull -Path (Join-Path $configRoot "commands.manifest.json") -Name "commands.manifest.json"
$hooksManifest = Load-JsonOrNull -Path (Join-Path $configRoot "hooks.manifest.json") -Name "hooks.manifest.json"
$mcpManifest = Load-JsonOrNull -Path (Join-Path $configRoot "mcp.manifest.json") -Name "mcp.manifest.json"

$thresholdRouteSkillsWarn = Get-Threshold -QualityGates $qualityGates -Key "route_max_skills" -Level "warning" -DefaultValue 4
$thresholdRouteSkillsErr = Get-Threshold -QualityGates $qualityGates -Key "route_max_skills" -Level "error" -DefaultValue 6
$thresholdKeywordCollisionWarn = Get-Threshold -QualityGates $qualityGates -Key "keyword_collision_count" -Level "warning" -DefaultValue 3
$thresholdKeywordCollisionErr = Get-Threshold -QualityGates $qualityGates -Key "keyword_collision_count" -Level "error" -DefaultValue 6
$thresholdOrphanWarn = Get-Threshold -QualityGates $qualityGates -Key "orphan_skill_count" -Level "warning" -DefaultValue 0
$thresholdOrphanErr = Get-Threshold -QualityGates $qualityGates -Key "orphan_skill_count" -Level "error" -DefaultValue 2
$thresholdDependencyDepthWarn = Get-Threshold -QualityGates $qualityGates -Key "dependency_depth" -Level "warning" -DefaultValue 6
$thresholdDependencyDepthErr = Get-Threshold -QualityGates $qualityGates -Key "dependency_depth" -Level "error" -DefaultValue 8
$thresholdUnmappedWorkflowWarn = Get-Threshold -QualityGates $qualityGates -Key "unmapped_required_workflows" -Level "warning" -DefaultValue 0
$thresholdUnmappedWorkflowErr = Get-Threshold -QualityGates $qualityGates -Key "unmapped_required_workflows" -Level "error" -DefaultValue 1
$thresholdMissingConfigWarn = Get-Threshold -QualityGates $qualityGates -Key "missing_required_config_files" -Level "warning" -DefaultValue 0
$thresholdMissingConfigErr = Get-Threshold -QualityGates $qualityGates -Key "missing_required_config_files" -Level "error" -DefaultValue 1
$thresholdEnabledMcpWarn = Get-Threshold -QualityGates $qualityGates -Key "enabled_mcp_server_count" -Level "warning" -DefaultValue 6
$thresholdEnabledMcpErr = Get-Threshold -QualityGates $qualityGates -Key "enabled_mcp_server_count" -Level "error" -DefaultValue 8

$requiredConfigFiles = @(
    "agents.manifest.json",
    "skills.manifest.json",
    "router.json",
    "proxies.manifest.json",
    "commands.manifest.json",
    "hooks.manifest.json",
    "mcp.manifest.json",
    "workflows.manifest.json",
    "quality-gates.json",
    "evolution.config.json",
    "README.md",
    "INDEX.md"
)
if ($null -ne $qualityGates -and $null -ne $qualityGates.required_config_files -and @($qualityGates.required_config_files).Count -gt 0) {
    $requiredConfigFiles = @($qualityGates.required_config_files)
}

$requiredEntryFiles = @(
    "AGENTS.md",
    ".claude/RULES.md",
    ".claude/BUILD_GUIDE.md",
    ".claude/CODEX_BRIDGE.md",
    ".claude/CLAUDE.md"
)
$requiredRootReferences = @(
    ".claude/RULES.md",
    ".claude/BUILD_GUIDE.md",
    ".claude/CODEX_BRIDGE.md"
)
$recommendedRootReferences = @(
    ".claude/config/router.json",
    ".agents/skills/mt3-project-guidelines/SKILL.md"
)
$expectedLoadOrder = @(
    "AGENTS.md",
    ".claude/RULES.md",
    ".claude/BUILD_GUIDE.md",
    ".claude/CODEX_BRIDGE.md",
    ".claude/config/router.json",
    ".claude/config/proxies.manifest.json",
    ".claude/config/agents.manifest.json",
    ".claude/config/skills.manifest.json",
    ".claude/config/commands.manifest.json",
    ".claude/config/workflows.manifest.json",
    ".claude/config/hooks.manifest.json",
    ".claude/config/mcp.manifest.json",
    ".claude/config/quality-gates.json",
    ".claude/config/evolution.config.json",
    ".agents/skills/mt3-project-guidelines/SKILL.md",
    ".claude/CLAUDE.md"
)
$codexRequiredPaths = @(
    ".codex/config.toml",
    ".codex/rules/mt3-guardrails.rules",
    ".codex/compat/claude-bridge.json",
    ".codex/permissions/guardrails.json",
    ".codex/mcp/mcp-profiles.json",
    ".codex/requirements.toml",
    ".agents/skills/mt3-project-guidelines/SKILL.md",
    ".agents/skills/claude-config-governance/SKILL.md"
)
$codexRequiredAgentIds = @(
    "mt3_build_expert",
    "mt3_docs_researcher",
    "mt3_planner",
    "mt3_reviewer"
)
$codexSkillsRoot = ".agents/skills"
$codexRequiredSkillMetadataRelativePath = "agents/openai.yaml"
$codexRequiredSidecarValidator = ".claude/scripts/validate_codex_sidecars.ps1"
$codexRequiredGuardrailAudit = ".claude/scripts/audit_codex_guardrails.ps1"
$codexRequiredSkillAudit = ".claude/scripts/audit_codex_skills.ps1"

if ($null -ne $qualityGates -and $null -ne $qualityGates.entry_contract) {
    $entryContract = $qualityGates.entry_contract
    if ($null -ne $entryContract.required_entry_files -and @($entryContract.required_entry_files).Count -gt 0) {
        $requiredEntryFiles = @($entryContract.required_entry_files)
    }
    if ($null -ne $entryContract.required_root_references -and @($entryContract.required_root_references).Count -gt 0) {
        $requiredRootReferences = @($entryContract.required_root_references)
    }
    if ($null -ne $entryContract.recommended_root_references -and @($entryContract.recommended_root_references).Count -gt 0) {
        $recommendedRootReferences = @($entryContract.recommended_root_references)
    }
    if ($null -ne $entryContract.expected_load_order -and @($entryContract.expected_load_order).Count -gt 0) {
        $expectedLoadOrder = @($entryContract.expected_load_order)
    }
}
if ($null -ne $qualityGates -and $null -ne $qualityGates.codex_runtime_contract) {
    $codexRuntimeContract = $qualityGates.codex_runtime_contract
    if ($null -ne $codexRuntimeContract.required_paths -and @($codexRuntimeContract.required_paths).Count -gt 0) {
        $codexRequiredPaths = @($codexRuntimeContract.required_paths)
    }
    if ($null -ne $codexRuntimeContract.required_agent_ids -and @($codexRuntimeContract.required_agent_ids).Count -gt 0) {
        $codexRequiredAgentIds = @($codexRuntimeContract.required_agent_ids)
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$codexRuntimeContract.skills_root)) {
        $codexSkillsRoot = [string]$codexRuntimeContract.skills_root
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$codexRuntimeContract.required_skill_metadata_relative_path)) {
        $codexRequiredSkillMetadataRelativePath = [string]$codexRuntimeContract.required_skill_metadata_relative_path
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$codexRuntimeContract.required_sidecar_validator)) {
        $codexRequiredSidecarValidator = [string]$codexRuntimeContract.required_sidecar_validator
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$codexRuntimeContract.required_guardrail_audit)) {
        $codexRequiredGuardrailAudit = [string]$codexRuntimeContract.required_guardrail_audit
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$codexRuntimeContract.required_skill_audit)) {
        $codexRequiredSkillAudit = [string]$codexRuntimeContract.required_skill_audit
    }
}

$missingRequiredConfigFiles = @()
foreach ($requiredFile in $requiredConfigFiles) {
    $fileName = [string]$requiredFile
    if ([string]::IsNullOrWhiteSpace($fileName)) { continue }
    $targetPath = Join-Path $configRoot $fileName
    if (-not (Test-Path $targetPath)) {
        $missingRequiredConfigFiles += $fileName
    }
}
if ($missingRequiredConfigFiles.Count -gt $thresholdMissingConfigErr) {
    Add-StdError "Missing required config files (error): $($missingRequiredConfigFiles -join ', ')"
} elseif ($missingRequiredConfigFiles.Count -gt $thresholdMissingConfigWarn) {
    Add-StdWarning "Missing required config files (warning): $($missingRequiredConfigFiles -join ', ')"
}

$agentIds = @{}
$skillIds = @{}
$commandIds = @{}
$proxyIds = @{}
$routeIds = @{}
$workflowIds = @{}
$workflowFiles = @{}
$resourceModes = @{}
$hookIds = @{}
$mcpServerIds = @{}

$agents = @()
$skills = @()
$commands = @()
$proxies = @()
$routes = @()
$workflows = @()
$hooks = @()
$mcpServers = @()
$projectDefaultMcpServers = @()
$projectDefaultMcpServerIds = @{}
$runtimeMcpCaptureStatus = "missing"
$runtimeMcpConfiguredServerCount = 0
$runtimeMcpConfiguredServers = @()
$runtimeMcpEnabledServerCount = 0
$runtimeMcpEnabledServers = @()
$runtimeMcpOutsideProjectDefaultServers = @()
$runtimeMcpUndeclaredEnabledServers = @()
$runtimeMcpCaptureErrors = @()
$runtimeMcpSnapshotPath = ".claude/reports/mcp-runtime-snapshot.json"

if ($null -ne $agentsManifest) {
    if ([string]::IsNullOrWhiteSpace($agentsManifest.schema_version)) {
        Add-StdError "agents.manifest.json missing schema_version"
    }
    $agents = @($agentsManifest.agents)
    foreach ($agent in $agents) {
        $id = [string]$agent.id
        if ([string]::IsNullOrWhiteSpace($id)) {
            Add-StdError "Empty agent id found"
            continue
        }
        if ($agentIds.ContainsKey($id)) {
            Add-StdError "Duplicate agent id: $id"
        } else {
            $agentIds[$id] = $true
        }

        $agentFile = Resolve-PathSafe -Base $configRoot -Relative ([string]$agent.file)
        if ($null -eq $agentFile -or -not (Test-Path $agentFile)) {
            Add-StdError "Agent file not found: $id -> $($agent.file)"
        }

        $inputParams = @($agent.input_params)
        if ($inputParams.Count -eq 0) {
            Add-StdWarning "Agent input_params missing: $id"
        }
        $requiredSections = @($agent.output_contract.required_sections)
        if ($requiredSections.Count -eq 0) {
            Add-StdWarning "Agent output contract missing: $id"
        }

        $triggerKeywords = @($agent.trigger_keywords)
        if ($triggerKeywords.Count -eq 0) {
            Add-StdWarning "Agent trigger_keywords missing: $id"
        }
    }
}

if ($null -ne $skillsManifest) {
    if ($null -eq $skillsManifest.parameter_schema) {
        Add-StdError "skills.manifest.json missing parameter_schema"
    }

    $skills = @($skillsManifest.skills)
    foreach ($skill in $skills) {
        $id = [string]$skill.id
        if ([string]::IsNullOrWhiteSpace($id)) {
            Add-StdError "Empty skill id found"
            continue
        }
        if ($skillIds.ContainsKey($id)) {
            Add-StdError "Duplicate skill id: $id"
        } else {
            $skillIds[$id] = $true
        }

        $skillFile = Resolve-PathSafe -Base $configRoot -Relative ([string]$skill.file)
        if ($null -eq $skillFile -or -not (Test-Path $skillFile)) {
            Add-StdError "Skill file not found: $id -> $($skill.file)"
        }

        $acceptedParams = @($skill.accepted_params)
        if ($acceptedParams.Count -eq 0) {
            Add-StdWarning "Skill accepted_params missing: $id"
        } else {
            foreach ($paramName in $acceptedParams) {
                if ($null -eq $skillsManifest.parameter_schema.$paramName) {
                    Add-StdError ("Skill parameter not in schema: {0}.{1}" -f $id, $paramName)
                }
            }
        }
    }

    foreach ($skill in $skills) {
        $id = [string]$skill.id
        foreach ($dep in @($skill.dependencies)) {
            $depId = [string]$dep
            if (-not $skillIds.ContainsKey($depId)) {
                Add-StdError "Skill dependency missing: $id -> $depId"
            }
        }
    }
}

if ($null -ne $agentsManifest) {
    foreach ($agent in $agents) {
        $id = [string]$agent.id
        foreach ($linked in @($agent.linked_skills)) {
            $linkedId = [string]$linked
            if (-not $skillIds.ContainsKey($linkedId)) {
                Add-StdError "Agent links missing skill: $id -> $linkedId"
            }
        }
    }
}

if ($null -ne $commandsManifest) {
    if ([string]::IsNullOrWhiteSpace($commandsManifest.schema_version)) {
        Add-StdError "commands.manifest.json missing schema_version"
    }

    $commands = @($commandsManifest.commands)
    if ($commands.Count -eq 0) {
        Add-StdError "commands.manifest.json missing commands"
    }

    foreach ($command in $commands) {
        $id = [string]$command.id
        if ([string]::IsNullOrWhiteSpace($id)) {
            Add-StdError "Empty command id found"
            continue
        }
        if ($commandIds.ContainsKey($id)) {
            Add-StdError "Duplicate command id: $id"
        } else {
            $commandIds[$id] = $true
        }

        $commandFile = Resolve-PathSafe -Base $configRoot -Relative ([string]$command.file)
        if ($null -eq $commandFile -or -not (Test-Path $commandFile)) {
            Add-StdError "Command file not found: $id -> $($command.file)"
        }

        $linkedAgent = [string]$command.linked_agent
        if (-not [string]::IsNullOrWhiteSpace($linkedAgent) -and -not $agentIds.ContainsKey($linkedAgent)) {
            Add-StdError "Command links missing agent: $id -> $linkedAgent"
        }

        foreach ($linkedSkill in @($command.linked_skills)) {
            $linkedSkillId = [string]$linkedSkill
            if (-not [string]::IsNullOrWhiteSpace($linkedSkillId) -and -not $skillIds.ContainsKey($linkedSkillId)) {
                Add-StdError "Command links missing skill: $id -> $linkedSkillId"
            }
        }
    }
}

if ($null -ne $proxiesManifest) {
    if ([string]::IsNullOrWhiteSpace($proxiesManifest.schema_version)) {
        Add-StdError "proxies.manifest.json missing schema_version"
    }

    $proxies = @($proxiesManifest.proxies)
    if ($proxies.Count -eq 0) {
        Add-StdError "proxies.manifest.json missing proxies"
    }

    foreach ($proxy in $proxies) {
        $id = [string]$proxy.id
        if ([string]::IsNullOrWhiteSpace($id)) {
            Add-StdError "Empty proxy id found"
            continue
        }
        if ($proxyIds.ContainsKey($id)) {
            Add-StdError "Duplicate proxy id: $id"
        } else {
            $proxyIds[$id] = $true
        }

        $primaryAgent = [string]$proxy.primary_agent
        if ([string]::IsNullOrWhiteSpace($primaryAgent) -or -not $agentIds.ContainsKey($primaryAgent)) {
            Add-StdError "Proxy primary_agent missing: $id -> $primaryAgent"
        }

        foreach ($fallbackAgent in @($proxy.fallback_agents)) {
            $fallbackId = [string]$fallbackAgent
            if (-not [string]::IsNullOrWhiteSpace($fallbackId) -and -not $agentIds.ContainsKey($fallbackId)) {
                Add-StdError "Proxy fallback agent missing: $id -> $fallbackId"
            }
        }

        foreach ($linkedSkill in @($proxy.linked_skills)) {
            $linkedSkillId = [string]$linkedSkill
            if (-not [string]::IsNullOrWhiteSpace($linkedSkillId) -and -not $skillIds.ContainsKey($linkedSkillId)) {
                Add-StdError "Proxy links missing skill: $id -> $linkedSkillId"
            }
        }

        foreach ($linkedCommand in @($proxy.linked_commands)) {
            $linkedCommandId = [string]$linkedCommand
            if (-not [string]::IsNullOrWhiteSpace($linkedCommandId) -and -not $commandIds.ContainsKey($linkedCommandId)) {
                Add-StdError "Proxy links missing command: $id -> $linkedCommandId"
            }
        }
    }
}

if ($null -ne $hooksManifest) {
    if ([string]::IsNullOrWhiteSpace($hooksManifest.schema_version)) {
        Add-StdError "hooks.manifest.json missing schema_version"
    }

    $hooks = @($hooksManifest.hooks)
    if ($hooks.Count -eq 0) {
        Add-StdError "hooks.manifest.json missing hooks"
    }

    foreach ($hook in $hooks) {
        $id = [string]$hook.id
        if ([string]::IsNullOrWhiteSpace($id)) {
            Add-StdError "Empty hook id found"
            continue
        }
        if ($hookIds.ContainsKey($id)) {
            Add-StdError "Duplicate hook id: $id"
        } else {
            $hookIds[$id] = $true
        }

        $eventName = [string]$hook.event
        if ([string]::IsNullOrWhiteSpace($eventName)) {
            Add-StdError "Hook event missing: $id"
        }

        $hookScript = Resolve-PathSafe -Base $configRoot -Relative ([string]$hook.script)
        if ($null -eq $hookScript -or -not (Test-Path $hookScript)) {
            Add-StdError "Hook script not found: $id -> $($hook.script)"
        }
    }
}

if ($null -ne $mcpManifest) {
    if ([string]::IsNullOrWhiteSpace($mcpManifest.schema_version)) {
        Add-StdError "mcp.manifest.json missing schema_version"
    }

    $mcpServers = @($mcpManifest.servers)
    if ($mcpServers.Count -eq 0) {
        Add-StdError "mcp.manifest.json missing servers"
    }

    foreach ($server in $mcpServers) {
        $sid = [string]$server.id
        if ([string]::IsNullOrWhiteSpace($sid)) {
            Add-StdError "Empty MCP server id found"
            continue
        }
        if ($mcpServerIds.ContainsKey($sid)) {
            Add-StdError "Duplicate MCP server id: $sid"
        } else {
            $mcpServerIds[$sid] = $true
        }
    }

    $enabledByDefault = @($mcpServers | Where-Object { [bool]$_.enabled_by_default })
    $projectDefaultMcpServers = @($enabledByDefault | ForEach-Object { [string]$_.id } | Sort-Object -Unique)
    foreach ($projectDefaultMcpServer in $projectDefaultMcpServers) {
        $projectDefaultMcpServerIds[$projectDefaultMcpServer] = $true
    }
    if ($enabledByDefault.Count -gt $thresholdEnabledMcpErr) {
        Add-StdError "Project-default MCP servers exceed error threshold: $($enabledByDefault.Count) > $thresholdEnabledMcpErr"
    } elseif ($enabledByDefault.Count -gt $thresholdEnabledMcpWarn) {
        Add-StdWarning "Project-default MCP servers exceed warning threshold: $($enabledByDefault.Count) > $thresholdEnabledMcpWarn"
    }

    if ($null -ne $mcpManifest.policy) {
        $policyScope = [string]$mcpManifest.policy.scope
        if ($policyScope -ne "project_manifest_enabled_by_default_only") {
            Add-StdError "mcp.manifest policy.scope must be project_manifest_enabled_by_default_only"
        }
        $recommended = [int]$mcpManifest.policy.recommended_enabled_servers
        $maxAllowed = [int]$mcpManifest.policy.max_enabled_servers
        if ($recommended -gt $maxAllowed) {
            Add-StdError "mcp.manifest policy invalid: recommended_enabled_servers > max_enabled_servers"
        } elseif ($enabledByDefault.Count -gt $maxAllowed) {
            Add-StdError "Project-default MCP servers exceed mcp.manifest policy.max_enabled_servers: $($enabledByDefault.Count) > $maxAllowed"
        } elseif ($enabledByDefault.Count -gt $recommended) {
            Add-StdWarning "Project-default MCP servers exceed mcp.manifest recommended_enabled_servers: $($enabledByDefault.Count) > $recommended"
        }
    }
}

$runtimeMcpSnapshot = Invoke-CodexMcpListJson -ProjectRoot $ProjectRoot -ReportRoot $reportRoot
$runtimeMcpCaptureStatus = [string]$runtimeMcpSnapshot.status
$runtimeMcpSnapshotPath = [string]$runtimeMcpSnapshot.snapshot_path
$runtimeMcpCaptureErrors = @($runtimeMcpSnapshot.errors | ForEach-Object { [string]$_ })
if ($runtimeMcpCaptureStatus -eq "captured") {
    $runtimeMcpConfiguredServers = @($runtimeMcpSnapshot.configured_servers | ForEach-Object { [string]$_ })
    $runtimeMcpConfiguredServerCount = $runtimeMcpConfiguredServers.Count
    $runtimeMcpEnabledServers = @($runtimeMcpSnapshot.enabled_servers | ForEach-Object { [string]$_ })
    $runtimeMcpEnabledServerCount = $runtimeMcpEnabledServers.Count
    $runtimeMcpOutsideProjectDefaultServers = @($runtimeMcpEnabledServers | Where-Object { -not $projectDefaultMcpServerIds.ContainsKey([string]$_) })
    $runtimeMcpUndeclaredEnabledServers = @($runtimeMcpEnabledServers | Where-Object { -not $mcpServerIds.ContainsKey([string]$_) })

    if ($runtimeMcpOutsideProjectDefaultServers.Count -gt 0) {
        Add-StdWarning "Runtime MCP inheritance drift observed (not project-enabled; project manifest cannot close user/system/managed inheritance): configured=$runtimeMcpConfiguredServerCount enabled=$runtimeMcpEnabledServerCount project_default=$($projectDefaultMcpServers.Count) outside_project_default=$($runtimeMcpOutsideProjectDefaultServers.Count); servers: $($runtimeMcpOutsideProjectDefaultServers -join ', ')"
    }

    if ($runtimeMcpUndeclaredEnabledServers.Count -gt 0) {
        Add-StdWarning "Runtime enabled MCP servers absent from the project manifest catalog (not project-enabled): $($runtimeMcpUndeclaredEnabledServers -join ', ')"
    }
} else {
    Add-StdWarning "Runtime MCP snapshot capture unavailable: $([string]::Join('; ', $runtimeMcpCaptureErrors))"
}

if ($null -ne $routerConfig) {
    if ($null -eq $routerConfig.intent_routes -or @($routerConfig.intent_routes).Count -eq 0) {
        Add-StdError "router.json missing intent_routes"
    } else {
        $twoStageRoutingEnabled = ($null -ne $routerConfig.routing_strategy -and [string]$routerConfig.routing_strategy.mode -eq "two_stage")
        if ($twoStageRoutingEnabled) {
            $stageOrder = @($routerConfig.routing_strategy.stage_order | ForEach-Object { [string]$_ })
            if ($stageOrder.Count -eq 0) {
                Add-StdError "router.json routing_strategy.stage_order missing"
            } else {
                if ($stageOrder -notcontains "domain") {
                    Add-StdError "router.json routing_strategy.stage_order missing domain"
                }
                if ($stageOrder -notcontains "intent") {
                    Add-StdError "router.json routing_strategy.stage_order missing intent"
                }
            }
        }

        $routes = @($routerConfig.intent_routes)
        foreach ($mode in @($routerConfig.resource_policy.PSObject.Properties.Name)) {
            $resourceModes[$mode] = $true
        }

        foreach ($route in $routes) {
            $intent = [string]$route.intent
            if ([string]::IsNullOrWhiteSpace($intent)) {
                Add-StdError "Empty route intent found"
                continue
            }
            if ($routeIds.ContainsKey($intent)) {
                Add-StdError "Duplicate route intent: $intent"
            } else {
                $routeIds[$intent] = $true
            }

            if ($twoStageRoutingEnabled -and [string]::IsNullOrWhiteSpace([string]$route.domain)) {
                Add-StdError "Route domain missing under two-stage routing: $intent"
            }

            $agent = [string]$route.primary_agent
            if (-not $agentIds.ContainsKey($agent)) {
                Add-StdError "Route agent missing: $intent -> $agent"
            }
            $defaultProxy = [string]$route.default_proxy
            if (-not [string]::IsNullOrWhiteSpace($defaultProxy) -and -not $proxyIds.ContainsKey($defaultProxy)) {
                Add-StdError "Route default_proxy missing in proxies.manifest: $intent -> $defaultProxy"
            }
            foreach ($skillId in @($route.skills)) {
                $sid = [string]$skillId
                if (-not $skillIds.ContainsKey($sid)) {
                    Add-StdError "Route skill missing: $intent -> $sid"
                }
            }

            $mode = [string]$route.mode
            if (-not $resourceModes.ContainsKey($mode)) {
                Add-StdError "Route mode missing in resource_policy: $intent -> $mode"
            }

            $keywordCount = @($route.keywords).Count
            if ($keywordCount -eq 0) {
                Add-StdWarning "Route keywords missing: $intent"
            }

            $routeSkillCount = @($route.skills).Count
            if ($resourceModes.ContainsKey($mode)) {
                $modeLimit = [int]$routerConfig.resource_policy.$mode.max_skills
                if ($routeSkillCount -gt $modeLimit) {
                    Add-StdError "Route exceeds mode max_skills: $intent ($routeSkillCount > $modeLimit)"
                }
            }
            if ($routeSkillCount -gt $thresholdRouteSkillsErr) {
                Add-StdError "Route skills exceed quality error threshold: $intent ($routeSkillCount > $thresholdRouteSkillsErr)"
            } elseif ($routeSkillCount -gt $thresholdRouteSkillsWarn) {
                Add-StdWarning "Route skills exceed quality warning threshold: $intent ($routeSkillCount > $thresholdRouteSkillsWarn)"
            }
        }
    }
}

if ($null -ne $workflowsManifest) {
    if ([string]::IsNullOrWhiteSpace($workflowsManifest.schema_version)) {
        Add-StdError "workflows.manifest.json missing schema_version"
    }
    $workflows = @($workflowsManifest.workflows)
    if ($workflows.Count -eq 0) {
        Add-StdError "workflows.manifest.json missing workflows"
    }
    foreach ($workflow in $workflows) {
        $wid = [string]$workflow.id
        if ([string]::IsNullOrWhiteSpace($wid)) {
            Add-StdError "Empty workflow id found"
            continue
        }
        if ($workflowIds.ContainsKey($wid)) {
            Add-StdError "Duplicate workflow id: $wid"
        } else {
            $workflowIds[$wid] = $true
        }

        $workflowFile = Resolve-PathSafe -Base $configRoot -Relative ([string]$workflow.file)
        if ($null -eq $workflowFile -or -not (Test-Path $workflowFile)) {
            Add-StdError "Workflow file not found: $wid -> $($workflow.file)"
        } else {
            $workflowFiles[$wid] = $workflowFile
        }

        foreach ($intent in @($workflow.intents)) {
            $intentId = [string]$intent
            if ($routeIds.Count -gt 0 -and -not $routeIds.ContainsKey($intentId)) {
                Add-StdWarning "Workflow references unknown intent: $wid -> $intentId"
            }
        }
    }

    $defaultWorkflow = [string]$workflowsManifest.default_workflow
    if (-not [string]::IsNullOrWhiteSpace($defaultWorkflow) -and -not $workflowIds.ContainsKey($defaultWorkflow)) {
        Add-StdError "workflows.manifest.json default_workflow missing: $defaultWorkflow"
    }
}

$keywordCollisions = @()
if ($routes.Count -gt 0) {
    $keywordPairs = @()
    $twoStageRoutingEnabled = ($null -ne $routerConfig -and $null -ne $routerConfig.routing_strategy -and [string]$routerConfig.routing_strategy.mode -eq "two_stage")
    foreach ($route in $routes) {
        $intent = [string]$route.intent
        $domain = if ($twoStageRoutingEnabled) { [string]$route.domain } else { "__global__" }
        foreach ($kw in @($route.keywords)) {
            $keywordPairs += [PSCustomObject]@{
                keyword = [string]$kw
                intent = $intent
                domain = $domain
                scope = if ([string]::IsNullOrWhiteSpace($domain)) { "__global__" } else { $domain }
            }
        }
    }
    $keywordGroups = $keywordPairs | Group-Object scope, keyword | Where-Object { $_.Count -gt 1 } | Sort-Object Count -Descending
    foreach ($group in $keywordGroups) {
        $sample = $group.Group | Select-Object -First 1
        $keywordCollisions += [PSCustomObject]@{
            keyword = [string]$sample.keyword
            domain = [string]$sample.scope
            count = $group.Count
            intents = (($group.Group.intent | Sort-Object -Unique) -join ", ")
        }
    }

    if ($keywordCollisions.Count -gt $thresholdKeywordCollisionErr) {
        Add-StdError "Router keyword collisions exceed error threshold: $($keywordCollisions.Count) > $thresholdKeywordCollisionErr"
    } elseif ($keywordCollisions.Count -gt $thresholdKeywordCollisionWarn) {
        Add-StdWarning "Router keyword collisions exceed warning threshold: $($keywordCollisions.Count) > $thresholdKeywordCollisionWarn"
    }
}

if ($routes.Count -gt 0 -and $workflowIds.Count -gt 0) {
    foreach ($route in $routes) {
        $intent = [string]$route.intent
        $workflowId = [string]$route.workflow_id
        if (-not [string]::IsNullOrWhiteSpace($workflowId) -and -not $workflowIds.ContainsKey($workflowId)) {
            Add-StdError "Route workflow_id missing in workflows.manifest: $intent -> $workflowId"
        }
        foreach ($candidate in @($route.workflow_candidates)) {
            $wid = [string]$candidate
            if (-not [string]::IsNullOrWhiteSpace($wid) -and -not $workflowIds.ContainsKey($wid)) {
                Add-StdError "Route workflow_candidates missing in workflows.manifest: $intent -> $wid"
            }
        }
    }
}

if ($commands.Count -gt 0 -and $routeIds.Count -gt 0) {
    foreach ($command in $commands) {
        $commandId = [string]$command.id
        foreach ($intent in @($command.intents)) {
            $intentId = [string]$intent
            if (-not [string]::IsNullOrWhiteSpace($intentId) -and -not $routeIds.ContainsKey($intentId)) {
                Add-StdWarning "Command intent missing in router: $commandId -> $intentId"
            }
        }
    }
}

if ($proxies.Count -gt 0) {
    foreach ($proxy in $proxies) {
        $proxyId = [string]$proxy.id
        foreach ($intent in @($proxy.activation_intents)) {
            $intentId = [string]$intent
            if ($routeIds.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($intentId) -and -not $routeIds.ContainsKey($intentId)) {
                Add-StdWarning "Proxy activation intent missing in router: $proxyId -> $intentId"
            }
        }

        foreach ($workflowId in @($proxy.workflow_candidates)) {
            $wid = [string]$workflowId
            if ($workflowIds.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($wid) -and -not $workflowIds.ContainsKey($wid)) {
                Add-StdError "Proxy workflow candidate missing in workflows.manifest: $proxyId -> $wid"
            }
        }
    }
}

if ($null -ne $mcpManifest -and $routeIds.Count -gt 0) {
    foreach ($binding in @($mcpManifest.intent_bindings)) {
        $intentId = [string]$binding.intent
        if (-not [string]::IsNullOrWhiteSpace($intentId) -and -not $routeIds.ContainsKey($intentId)) {
            Add-StdWarning "MCP intent binding missing in router: $intentId"
        }
        foreach ($serverId in @($binding.preferred_servers)) {
            $sid = [string]$serverId
            if (-not [string]::IsNullOrWhiteSpace($sid) -and -not $mcpServerIds.ContainsKey($sid)) {
                Add-StdError "MCP preferred server missing: intent=$intentId -> $sid"
            }
        }
        foreach ($serverId in @($binding.optional_servers)) {
            $sid = [string]$serverId
            if (-not [string]::IsNullOrWhiteSpace($sid) -and -not $mcpServerIds.ContainsKey($sid)) {
                Add-StdError "MCP optional server missing: intent=$intentId -> $sid"
            }
        }
    }
}

$requiredWorkflowIntents = @()
if ($null -ne $qualityGates) {
    $requiredWorkflowIntents = @($qualityGates.required_workflow_intents)
}
$unmappedRequiredWorkflowIntents = @()
if ($requiredWorkflowIntents.Count -gt 0 -and $routes.Count -gt 0) {
    $routeMap = @{}
    foreach ($route in $routes) {
        $routeMap[[string]$route.intent] = $route
    }
    foreach ($requiredIntent in $requiredWorkflowIntents) {
        $intentId = [string]$requiredIntent
        if (-not $routeMap.ContainsKey($intentId)) {
            Add-StdError "required_workflow_intents references missing route: $intentId"
            continue
        }
        $route = $routeMap[$intentId]
        $workflowId = [string]$route.workflow_id
        $workflowCandidates = @($route.workflow_candidates)
        if ([string]::IsNullOrWhiteSpace($workflowId) -and $workflowCandidates.Count -eq 0) {
            $unmappedRequiredWorkflowIntents += $intentId
        }
    }
}
if ($unmappedRequiredWorkflowIntents.Count -gt $thresholdUnmappedWorkflowErr) {
    Add-StdError "Required workflow mapping missing (error): $($unmappedRequiredWorkflowIntents -join ', ')"
} elseif ($unmappedRequiredWorkflowIntents.Count -gt $thresholdUnmappedWorkflowWarn) {
    Add-StdWarning "Required workflow mapping missing (warning): $($unmappedRequiredWorkflowIntents -join ', ')"
}

$evolutionEnabled = $false
if ($null -ne $evolutionConfig) {
    $evolutionEnabled = [bool]$evolutionConfig.enabled
}
if ($evolutionEnabled) {
    $configDir = Join-Path $claudeRoot "config"
    $storage = $evolutionConfig.storage
    $automation = $evolutionConfig.automation

    if ($null -eq $storage) {
        Add-StdError "evolution.config missing storage section"
    } else {
        foreach ($prop in @($storage.PSObject.Properties)) {
            $name = [string]$prop.Name
            $entry = [string]$prop.Value
            if ([string]::IsNullOrWhiteSpace($entry)) {
                Add-StdError "evolution.config storage path missing: $name"
                continue
            }
            $resolved = Resolve-PathSafe -Base $configDir -Relative $entry
            if ($null -eq $resolved) {
                Add-StdError "evolution.config storage path invalid: $name -> $entry"
            }
        }
    }

    if ($null -eq $automation) {
        Add-StdError "evolution.config missing automation section"
    } else {
        foreach ($prop in @($automation.PSObject.Properties)) {
            $name = [string]$prop.Name
            $entry = [string]$prop.Value
            if ([string]::IsNullOrWhiteSpace($entry)) {
                Add-StdError "evolution.config automation entry missing: $name"
                continue
            }
            if ($name -like "*_script") {
                $resolved = Resolve-PathSafe -Base $configDir -Relative $entry
                if ($null -eq $resolved -or -not (Test-Path $resolved)) {
                    Add-StdError "evolution.config automation script not found: $name -> $entry"
                }
            } else {
                $resolved = Resolve-PathSafe -Base $configDir -Relative $entry
                if ($null -eq $resolved) {
                    Add-StdError "evolution.config automation entry invalid: $name -> $entry"
                }
            }
        }
    }

    if ($null -ne $automation) {
        foreach ($requiredScriptName in @("collector_script", "evolver_script", "backfill_script", "pipeline_script")) {
            if ($null -eq $automation.$requiredScriptName -or [string]::IsNullOrWhiteSpace([string]$automation.$requiredScriptName)) {
                Add-StdError "evolution.config required automation script missing: $requiredScriptName"
            }
        }
    }

    if ($null -ne $storage) {
        foreach ($requiredStorageName in @("observations_file", "instincts_file", "report_file", "skill_suggestions_file", "backfill_proposals_file", "backfill_summary_file")) {
            if ($null -eq $storage.$requiredStorageName -or [string]::IsNullOrWhiteSpace([string]$storage.$requiredStorageName)) {
                Add-StdError "evolution.config required storage path missing: $requiredStorageName"
            }
        }
    }

    if (-not $skillIds.ContainsKey("continuous-learning-v2")) {
        Add-StdWarning "Evolution enabled but skill missing: continuous-learning-v2"
    }
    if (-not $routeIds.ContainsKey("skill_evolution")) {
        Add-StdWarning "Evolution enabled but route missing: skill_evolution"
    }
}

$dependencyCycle = $false
$dependencyDepth = 0
$topologyProcessedCount = 0
$skillCount = $skillIds.Count

$indegree = @{}
$adjacency = @{}
$depthMap = @{}
foreach ($skill in $skills) {
    $id = [string]$skill.id
    if ([string]::IsNullOrWhiteSpace($id)) { continue }
    $indegree[$id] = 0
    if (-not $adjacency.ContainsKey($id)) {
        $adjacency[$id] = @()
    }
}
foreach ($skill in $skills) {
    $id = [string]$skill.id
    if ([string]::IsNullOrWhiteSpace($id)) { continue }
    foreach ($dep in @($skill.dependencies)) {
        $depId = [string]$dep
        if (-not $skillIds.ContainsKey($depId)) { continue }
        $indegree[$id] = [int]$indegree[$id] + 1
        $list = @($adjacency[$depId])
        $list += $id
        $adjacency[$depId] = $list
    }
}

$queue = New-Object System.Collections.Generic.Queue[string]
foreach ($key in $indegree.Keys) {
    if ([int]$indegree[$key] -eq 0) {
        $queue.Enqueue($key)
        $depthMap[$key] = 1
    }
}

while ($queue.Count -gt 0) {
    $node = $queue.Dequeue()
    $topologyProcessedCount++
    if ($depthMap.ContainsKey($node) -and [int]$depthMap[$node] -gt $dependencyDepth) {
        $dependencyDepth = [int]$depthMap[$node]
    }
    foreach ($next in @($adjacency[$node])) {
        $candidateDepth = [int]$depthMap[$node] + 1
        if (-not $depthMap.ContainsKey($next) -or [int]$depthMap[$next] -lt $candidateDepth) {
            $depthMap[$next] = $candidateDepth
        }
        $indegree[$next] = [int]$indegree[$next] - 1
        if ([int]$indegree[$next] -eq 0) {
            $queue.Enqueue($next)
        }
    }
}

if ($skillCount -gt 0 -and $topologyProcessedCount -lt $skillCount) {
    $dependencyCycle = $true
    Add-StdError "Skill dependency cycle detected: processed $topologyProcessedCount / $skillCount"
}

if ($dependencyDepth -gt $thresholdDependencyDepthErr) {
    Add-StdError "Skill dependency depth exceeds error threshold: $dependencyDepth > $thresholdDependencyDepthErr"
} elseif ($dependencyDepth -gt $thresholdDependencyDepthWarn) {
    Add-StdWarning "Skill dependency depth exceeds warning threshold: $dependencyDepth > $thresholdDependencyDepthWarn"
}

$referencedSkillSet = @{}
foreach ($route in $routes) {
    foreach ($sid in @($route.skills)) {
        $id = [string]$sid
        if ($skillIds.ContainsKey($id)) {
            $referencedSkillSet[$id] = $true
        }
    }
}
foreach ($agent in $agents) {
    foreach ($sid in @($agent.linked_skills)) {
        $id = [string]$sid
        if ($skillIds.ContainsKey($id)) {
            $referencedSkillSet[$id] = $true
        }
    }
}

$orphanSkills = @()
foreach ($sid in $skillIds.Keys) {
    if (-not $referencedSkillSet.ContainsKey($sid)) {
        $orphanSkills += $sid
    }
}
if ($orphanSkills.Count -gt $thresholdOrphanErr) {
    Add-StdError "Orphan skills exceed error threshold: $($orphanSkills.Count) > $thresholdOrphanErr"
} elseif ($orphanSkills.Count -gt $thresholdOrphanWarn) {
    Add-StdWarning "Orphan skills exceed warning threshold: $($orphanSkills.Count) > $thresholdOrphanWarn"
}

$rootAgentsFile = Join-Path $ProjectRoot "AGENTS.md"
if (-not (Test-Path $rootAgentsFile)) {
    Add-StdError "Root AGENTS.md missing"
} else {
    $agentsText = Get-Content -Raw -Encoding UTF8 $rootAgentsFile
    foreach ($ref in $requiredRootReferences) {
        $refText = [string]$ref
        if ([string]::IsNullOrWhiteSpace($refText)) { continue }
        if (-not $agentsText.Contains($refText)) {
            Add-StdError "AGENTS.md does not reference $refText"
        }
    }
    foreach ($ref in $recommendedRootReferences) {
        $refText = [string]$ref
        if ([string]::IsNullOrWhiteSpace($refText)) { continue }
        if (-not $agentsText.Contains($refText)) {
            Add-StdWarning "AGENTS.md does not reference $refText"
        }
    }
}

foreach ($entry in $requiredEntryFiles) {
    $entryPath = [string]$entry
    if ([string]::IsNullOrWhiteSpace($entryPath)) { continue }
    $resolvedEntryPath = Resolve-PathSafe -Base $ProjectRoot -Relative $entryPath
    if ($null -eq $resolvedEntryPath -or -not (Test-Path $resolvedEntryPath)) {
        Add-StdError "Missing required entry file: $entryPath"
    }
}

if ($null -eq $routerConfig -or $null -eq $routerConfig.load_order -or @($routerConfig.load_order).Count -eq 0) {
    Add-StdWarning "router.json missing load_order"
} else {
    $actualLoadOrder = @($routerConfig.load_order | ForEach-Object { [string]$_ })
    foreach ($entry in $expectedLoadOrder) {
        if ($actualLoadOrder -notcontains $entry) {
            Add-StdError "router.json load_order missing entry: $entry"
        }
    }

    $lastIndex = -1
    foreach ($entry in $expectedLoadOrder) {
        $currentIndex = [Array]::IndexOf($actualLoadOrder, $entry)
        if ($currentIndex -lt 0) {
            continue
        }
        if ($currentIndex -lt $lastIndex) {
            Add-StdError "router.json load_order order mismatch near: $entry"
            break
        }
        $lastIndex = $currentIndex
    }
}

$canonicalBuildEntry = "tools/scripts/Build-MT3-Exe-Canonical.ps1"
$legacyExternalBuildEntry = "client/Build-MT3-v120.ps1"

$canonicalEntryExpectedDocs = @(
    "commands/build-win.md",
    "workflows/verification-workflow.md",
    "skills/client/windows-build.md",
    "commands/status.md"
)

$canonicalEntryMissingDocs = @()
$legacyEntryStillUsedDocs = @()
foreach ($relativeDocPath in $canonicalEntryExpectedDocs) {
    $docPath = Join-Path $claudeRoot $relativeDocPath
    if (-not (Test-Path $docPath -PathType Leaf)) {
        Add-StdError "Missing canonical-entry doc file: .claude/$relativeDocPath"
        continue
    }

    $docText = Get-Content -Raw -Encoding UTF8 $docPath
    if (-not $docText.Contains($canonicalBuildEntry)) {
        $canonicalEntryMissingDocs += ".claude/$relativeDocPath"
    }

    if ($docText.Contains($legacyExternalBuildEntry)) {
        $legacyEntryStillUsedDocs += ".claude/$relativeDocPath"
    }
}

if ($canonicalEntryMissingDocs.Count -gt 0) {
    Add-StdError "Canonical build entry missing in docs: $($canonicalEntryMissingDocs -join ', ')"
}
if ($legacyEntryStillUsedDocs.Count -gt 0) {
    Add-StdError "Legacy external build entry still referenced: $($legacyEntryStillUsedDocs -join ', ')"
}

$buildCompileHasWindowsSkill = $false
$buildCompileWorkflowIsWindows = $false
$buildCompileRoute = $null
foreach ($route in $routes) {
    $intentId = [string]$route.intent
    if ($intentId -eq "build_compile") {
        $buildCompileRoute = $route
        break
    }
}

if ($null -eq $buildCompileRoute) {
    Add-StdError "Required route missing: build_compile"
} else {
    $buildCompileSkills = @($buildCompileRoute.skills | ForEach-Object { [string]$_ })
    if ($buildCompileSkills -contains "windows-build") {
        $buildCompileHasWindowsSkill = $true
    } else {
        Add-StdError "build_compile route missing required skill: windows-build"
    }

    $buildCompileWorkflow = [string]$buildCompileRoute.workflow_id
    if ($buildCompileWorkflow -eq "windows-build-workflow") {
        $buildCompileWorkflowIsWindows = $true
    } else {
        Add-StdError "build_compile route workflow drift: expected windows-build-workflow, got $buildCompileWorkflow"
    }
}

$codexCompatExpectedFiles = @($codexRequiredPaths)
$codexCompatMissingFiles = @()
foreach ($relativeFile in $codexCompatExpectedFiles) {
    $resolved = Resolve-PathSafe -Base $ProjectRoot -Relative $relativeFile
    if ($null -eq $resolved -or -not (Test-Path $resolved -PathType Leaf)) {
        $codexCompatMissingFiles += $relativeFile
    }
}
if ($codexCompatMissingFiles.Count -gt 0) {
    Add-StdError "Codex runtime files missing: $($codexCompatMissingFiles -join ', ')"
}

$codexNativeConfigIssues = @()
$codexConfigTomlPath = Resolve-PathSafe -Base $ProjectRoot -Relative ".codex/config.toml"
$codexNativeAgentsDirPath = Resolve-PathSafe -Base $ProjectRoot -Relative ".codex/agents"
$codexBridgeJsonPath = Resolve-PathSafe -Base $ProjectRoot -Relative ".codex/compat/claude-bridge.json"
$codexSkillsRootPath = Resolve-PathSafe -Base $ProjectRoot -Relative $codexSkillsRoot
$codexRequiredSidecarValidatorPath = Resolve-PathSafe -Base $ProjectRoot -Relative $codexRequiredSidecarValidator
$codexRequiredGuardrailAuditPath = Resolve-PathSafe -Base $ProjectRoot -Relative $codexRequiredGuardrailAudit
$codexRequiredSkillAuditPath = Resolve-PathSafe -Base $ProjectRoot -Relative $codexRequiredSkillAudit
$expectedAgentsRoot = ".agents/skills"
$expectedAgentsEntrySkill = ".agents/skills/mt3-project-guidelines/SKILL.md"
$expectedAgentsGovernanceSkill = ".agents/skills/claude-config-governance/SKILL.md"
$codexDeclaredAgentConfigFiles = @{}
$codexMissingRequiredAgentIds = @()
$codexSkillMetadataIssues = @()
$codexSidecarValidationStatus = "SKIP"
$codexGuardrailAuditStatus = "SKIP"
$codexSkillsAuditStatus = "SKIP"
$codexSidecarValidationOutput = @()
$codexGuardrailAuditOutput = @()
$codexSkillsAuditOutput = @()

if ($null -ne $codexConfigTomlPath -and (Test-Path $codexConfigTomlPath -PathType Leaf)) {
    $codexConfigText = Get-Content -Raw -Encoding UTF8 $codexConfigTomlPath
    $requiredCodexTomlTokens = @(
        'approval_policy = "on-request"',
        'sandbox_mode = "workspace-write"',
        'web_search = "cached"',
        '[windows]',
        'sandbox = "elevated"',
        '[agents]',
        '[mcp_servers.openaiDeveloperDocs]',
        'url = "https://developers.openai.com/mcp"'
    )
    foreach ($token in $requiredCodexTomlTokens) {
        if (-not $codexConfigText.Contains($token)) {
            $codexNativeConfigIssues += ".codex/config.toml missing token: $token"
        }
    }

    $agentSectionMatches = [regex]::Matches($codexConfigText, '(?ms)^\[agents\.([^\]]+)\]\s*(.*?)(?=^\[|\z)')
    foreach ($match in $agentSectionMatches) {
        $agentId = $match.Groups[1].Value.Trim()
        $sectionText = $match.Groups[2].Value
        $configMatch = [regex]::Match($sectionText, '(?m)^\s*config_file\s*=\s*"([^"]+)"')
        if ($configMatch.Success) {
            $codexDeclaredAgentConfigFiles[$agentId] = $configMatch.Groups[1].Value.Trim()
        } else {
            $codexNativeConfigIssues += ".codex/config.toml agent $agentId missing config_file"
        }
    }

    foreach ($requiredAgentId in $codexRequiredAgentIds) {
        if (-not $codexDeclaredAgentConfigFiles.ContainsKey([string]$requiredAgentId)) {
            $codexMissingRequiredAgentIds += [string]$requiredAgentId
        }
    }

    foreach ($agentId in @($codexDeclaredAgentConfigFiles.Keys)) {
        $configRelative = [string]$codexDeclaredAgentConfigFiles[$agentId]
        $configResolved = Resolve-PathSafe -Base (Split-Path -Parent $codexConfigTomlPath) -Relative $configRelative
        if ($null -eq $configResolved -or -not (Test-Path $configResolved -PathType Leaf)) {
            $codexNativeConfigIssues += ".codex/config.toml agent $agentId points to missing config_file: $configRelative"
        }
    }
}
if ($null -eq $codexNativeAgentsDirPath -or -not (Test-Path $codexNativeAgentsDirPath -PathType Container)) {
    $codexNativeConfigIssues += ".codex/agents directory missing"
} else {
    $nativeCodexAgents = @(Get-ChildItem -Path $codexNativeAgentsDirPath -File -Filter "*.toml")
    if ($nativeCodexAgents.Count -eq 0) {
        $codexNativeConfigIssues += ".codex/agents has no .toml agent definitions"
    }
}
if ($codexNativeConfigIssues.Count -gt 0) {
    foreach ($issue in $codexNativeConfigIssues) {
        Add-StdError "Codex native config drift: $issue"
    }
}
if ($codexMissingRequiredAgentIds.Count -gt 0) {
    Add-StdError "Codex required agents missing from .codex/config.toml: $($codexMissingRequiredAgentIds -join ', ')"
}

if ($null -eq $codexSkillsRootPath -or -not (Test-Path $codexSkillsRootPath -PathType Container)) {
    $codexSkillMetadataIssues += "$codexSkillsRoot directory missing"
} else {
    $codexSkillDirs = @(Get-ChildItem -Path $codexSkillsRootPath -Directory)
    foreach ($skillDir in $codexSkillDirs) {
        $skillDoc = Join-Path $skillDir.FullName "SKILL.md"
        $skillMetadata = Join-Path $skillDir.FullName $codexRequiredSkillMetadataRelativePath
        if (-not (Test-Path $skillDoc -PathType Leaf)) {
            $codexSkillMetadataIssues += "$($skillDir.Name) missing SKILL.md"
        }
        if (-not (Test-Path $skillMetadata -PathType Leaf)) {
            $codexSkillMetadataIssues += "$($skillDir.Name) missing $codexRequiredSkillMetadataRelativePath"
        }
    }
}
if ($codexSkillMetadataIssues.Count -gt 0) {
    foreach ($issue in $codexSkillMetadataIssues) {
        Add-StdError "Codex skill metadata drift: $issue"
    }
}

$codexAgentsBridgeIssues = @()
$codexBridgeConfig = $null
if ($null -ne $codexBridgeJsonPath -and (Test-Path $codexBridgeJsonPath -PathType Leaf)) {
    $codexBridgeConfig = Load-JsonOrNull -Path $codexBridgeJsonPath -Name ".codex/compat/claude-bridge.json"
}
if ($null -ne $codexBridgeConfig) {
    $codexBridgeEntryOrder = @($codexBridgeConfig.entry_order | ForEach-Object { [string]$_ })
    if ($codexBridgeEntryOrder -notcontains $expectedAgentsEntrySkill) {
        $codexAgentsBridgeIssues += ".codex/compat/claude-bridge.json entry_order missing .agents entry skill"
    }

    if ($null -eq $codexBridgeConfig.agents) {
        $codexAgentsBridgeIssues += ".codex/compat/claude-bridge.json missing agents section"
    } else {
        if ([string]$codexBridgeConfig.agents.skills_root -ne $expectedAgentsRoot) {
            $codexAgentsBridgeIssues += ".codex/compat/claude-bridge.json agents.skills_root drift"
        }
        if ([string]$codexBridgeConfig.agents.entry_skill -ne $expectedAgentsEntrySkill) {
            $codexAgentsBridgeIssues += ".codex/compat/claude-bridge.json agents.entry_skill drift"
        }
        if ([string]$codexBridgeConfig.agents.governance_skill -ne $expectedAgentsGovernanceSkill) {
            $codexAgentsBridgeIssues += ".codex/compat/claude-bridge.json agents.governance_skill drift"
        }
    }
}
if ($codexAgentsBridgeIssues.Count -gt 0) {
    foreach ($issue in $codexAgentsBridgeIssues) {
        Add-StdError "Codex agents bridge drift: $issue"
    }
}

if ($null -eq $codexRequiredSidecarValidatorPath -or -not (Test-Path $codexRequiredSidecarValidatorPath -PathType Leaf)) {
    Add-StdError "Codex sidecar validator missing: $codexRequiredSidecarValidator"
} else {
    $sidecarValidationResult = Invoke-PowerShellAudit -ScriptPath $codexRequiredSidecarValidatorPath -ProjectRoot $ProjectRoot -Name "validate_codex_sidecars"
    $codexSidecarValidationStatus = if ($sidecarValidationResult.exit_code -eq 0) { "PASS" } else { "FAIL" }
    $codexSidecarValidationOutput = @($sidecarValidationResult.output | Select-Object -First 20)
    if ($sidecarValidationResult.exit_code -ne 0) {
        Add-StdError "Codex sidecar validation failed: $($codexRequiredSidecarValidator)"
    }
}

if ($null -eq $codexRequiredGuardrailAuditPath -or -not (Test-Path $codexRequiredGuardrailAuditPath -PathType Leaf)) {
    Add-StdError "Codex guardrail audit missing: $codexRequiredGuardrailAudit"
} else {
    $guardrailAuditResult = Invoke-PowerShellAudit -ScriptPath $codexRequiredGuardrailAuditPath -ProjectRoot $ProjectRoot -Name "audit_codex_guardrails"
    $codexGuardrailAuditStatus = if ($guardrailAuditResult.exit_code -eq 0) { "PASS" } else { "FAIL" }
    $codexGuardrailAuditOutput = @($guardrailAuditResult.output | Select-Object -First 20)
    if ($guardrailAuditResult.exit_code -ne 0) {
        Add-StdError "Codex guardrail audit failed: $($codexRequiredGuardrailAudit)"
    }
}

if ($null -eq $codexRequiredSkillAuditPath -or -not (Test-Path $codexRequiredSkillAuditPath -PathType Leaf)) {
    Add-StdError "Codex skills audit missing: $codexRequiredSkillAudit"
} else {
    $skillsAuditResult = Invoke-PowerShellAudit -ScriptPath $codexRequiredSkillAuditPath -ProjectRoot $ProjectRoot -Name "audit_codex_skills"
    $codexSkillsAuditStatus = if ($skillsAuditResult.exit_code -eq 0) { "PASS" } else { "FAIL" }
    $codexSkillsAuditOutput = @($skillsAuditResult.output | Select-Object -First 20)
    if ($skillsAuditResult.exit_code -ne 0) {
        Add-StdError "Codex skills audit failed: $($codexRequiredSkillAudit)"
    }
}

$enabledMcpServerCount = @($mcpServers | Where-Object { [bool]$_.enabled_by_default }).Count

# Legacy audit (warning only)
$legacyBrokenLinks = 0
$linkRegex = [regex]'\[[^\]]+\]\(([^)]+)\)'
$ignoreToken = @("path", "relative-path", "related-command-1.md", "related-command-2.md", "路径", "相对路径", "相关命令1.md", "相关命令2.md")

$legacyMdFiles = Get-ChildItem -Path $claudeRoot -Recurse -File -Filter "*.md"
foreach ($file in $legacyMdFiles) {
    if ($file.FullName -match '[\\/]templates[\\/]') { continue }

    $content = Get-Content -Raw -Encoding UTF8 $file.FullName
    $scanText = Remove-MarkdownCodeSegments -Text $content
    $matches = $linkRegex.Matches($scanText)
    foreach ($m in $matches) {
        $link = $m.Groups[1].Value.Trim()
        if ($link -match '^(https?://|mailto:|#)') { continue }
        if ($link -match '^[a-zA-Z]+://') { continue }
        if ($ignoreToken -contains $link) { continue }

        $clean = $link.Split("#")[0].Trim()
        if ([string]::IsNullOrWhiteSpace($clean)) { continue }
        if ($clean.Contains("|")) { continue }

        $target = Resolve-PathSafe -Base $file.DirectoryName -Relative $clean
        if ($null -eq $target -or -not (Test-Path $target)) {
            $legacyBrokenLinks++
            Add-LegacyWarning "Broken link: $($file.FullName) -> $link"
        }
    }
}

$agentFrontMatterMissing = 0
$skillFrontMatterMissing = 0
$frontMatterRegex = [regex]'(?s)^---\r?\n(.*?)\r?\n---\r?\n'

$agentDocs = Get-ChildItem -Path (Join-Path $claudeRoot "agents") -File -Filter "*.md"
foreach ($doc in $agentDocs) {
    if ($doc.Name -eq "README.md") { continue }
    $text = Get-Content -Raw -Encoding UTF8 $doc.FullName
    if (-not $frontMatterRegex.IsMatch($text)) {
        $agentFrontMatterMissing++
        Add-LegacyWarning "Agent missing front matter: $($doc.FullName)"
    }
}

$skillDocs = Get-ChildItem -Path (Join-Path $claudeRoot "skills") -Recurse -File -Filter "*.md"
foreach ($doc in $skillDocs) {
    if ($doc.Name -in @("README.md", "dependency-graph.md")) { continue }
    $text = Get-Content -Raw -Encoding UTF8 $doc.FullName
    if (-not $frontMatterRegex.IsMatch($text)) {
        $skillFrontMatterMissing++
        Add-LegacyWarning "Skill missing front matter: $($doc.FullName)"
    }
}

$standardStatus = if ($standardErrors.Count -eq 0) { "PASS" } else { "FAIL" }
$overallStatus = $standardStatus
if ($LegacyStrict -and ($legacyBrokenLinks -gt 0 -or $agentFrontMatterMissing -gt 0 -or $skillFrontMatterMissing -gt 0)) {
    $overallStatus = "FAIL"
}

$qualityLayer = [ordered]@{
    evolution_enabled = $evolutionEnabled
    command_count = $commandIds.Count
    proxy_count = $proxyIds.Count
    hook_count = $hookIds.Count
    mcp_server_count = $mcpServerIds.Count
    enabled_mcp_servers = $enabledMcpServerCount
    enabled_mcp_policy_scope = "project_manifest_enabled_by_default_only"
    runtime_mcp_capture_status = $runtimeMcpCaptureStatus
    runtime_mcp_snapshot_path = $runtimeMcpSnapshotPath
    runtime_configured_mcp_servers = $runtimeMcpConfiguredServerCount
    runtime_enabled_mcp_servers = $runtimeMcpEnabledServerCount
    runtime_enabled_outside_project_default = $runtimeMcpOutsideProjectDefaultServers.Count
    runtime_enabled_undeclared = $runtimeMcpUndeclaredEnabledServers.Count
    runtime_inheritance_drift_project_closable = $false
    missing_required_config_files = $missingRequiredConfigFiles.Count
    keyword_collisions = $keywordCollisions.Count
    orphan_skills = $orphanSkills.Count
    dependency_depth = $dependencyDepth
    dependency_cycle_detected = $dependencyCycle
    required_workflow_unmapped = $unmappedRequiredWorkflowIntents.Count
    canonical_entry_doc_missing = $canonicalEntryMissingDocs.Count
    legacy_external_entry_mentions = $legacyEntryStillUsedDocs.Count
    build_compile_has_windows_skill = $buildCompileHasWindowsSkill
    build_compile_windows_workflow = $buildCompileWorkflowIsWindows
    codex_compat_missing = $codexCompatMissingFiles.Count
    codex_required_agents_missing = $codexMissingRequiredAgentIds.Count
    codex_native_config_issues = $codexNativeConfigIssues.Count
    codex_skill_metadata_issues = $codexSkillMetadataIssues.Count
    codex_agents_bridge_issues = $codexAgentsBridgeIssues.Count
    codex_sidecar_validation_status = $codexSidecarValidationStatus
    codex_guardrail_audit_status = $codexGuardrailAuditStatus
    codex_skills_audit_status = $codexSkillsAuditStatus
    thresholds = [ordered]@{
        route_max_skills_warning = $thresholdRouteSkillsWarn
        route_max_skills_error = $thresholdRouteSkillsErr
        keyword_collision_warning = $thresholdKeywordCollisionWarn
        keyword_collision_error = $thresholdKeywordCollisionErr
        orphan_warning = $thresholdOrphanWarn
        orphan_error = $thresholdOrphanErr
        dependency_depth_warning = $thresholdDependencyDepthWarn
        dependency_depth_error = $thresholdDependencyDepthErr
        unmapped_required_workflow_warning = $thresholdUnmappedWorkflowWarn
        unmapped_required_workflow_error = $thresholdUnmappedWorkflowErr
        missing_required_config_warning = $thresholdMissingConfigWarn
        missing_required_config_error = $thresholdMissingConfigErr
        enabled_mcp_warning = $thresholdEnabledMcpWarn
        enabled_mcp_error = $thresholdEnabledMcpErr
        enabled_mcp_scope = "project_manifest_enabled_by_default_only"
    }
    samples = [ordered]@{
        missing_required_config_files = @($missingRequiredConfigFiles)
        keyword_collisions = @($keywordCollisions | Select-Object -First 8)
        orphan_skills = @($orphanSkills | Select-Object -First 20)
        unmapped_required_workflows = @($unmappedRequiredWorkflowIntents)
        enabled_mcp_servers = @($mcpServers | Where-Object { [bool]$_.enabled_by_default } | Select-Object -ExpandProperty id)
        runtime_configured_mcp_servers = @($runtimeMcpConfiguredServers)
        runtime_enabled_mcp_servers = @($runtimeMcpEnabledServers)
        runtime_enabled_outside_project_default = @($runtimeMcpOutsideProjectDefaultServers)
        runtime_enabled_undeclared = @($runtimeMcpUndeclaredEnabledServers)
        runtime_mcp_capture_errors = @($runtimeMcpCaptureErrors)
        canonical_entry_missing_docs = @($canonicalEntryMissingDocs)
        legacy_entry_docs = @($legacyEntryStillUsedDocs)
        codex_compat_missing_files = @($codexCompatMissingFiles)
        codex_required_agents_missing = @($codexMissingRequiredAgentIds)
        codex_native_config_issues = @($codexNativeConfigIssues)
        codex_skill_metadata_issues = @($codexSkillMetadataIssues)
        codex_agents_bridge_issues = @($codexAgentsBridgeIssues)
        codex_sidecar_validation_output = @($codexSidecarValidationOutput)
        codex_guardrail_audit_output = @($codexGuardrailAuditOutput)
        codex_skills_audit_output = @($codexSkillsAuditOutput)
    }
}

$result = [ordered]@{
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    project_root = $ProjectRoot
    standard_layer = [ordered]@{
        status = $standardStatus
        errors = $standardErrors
        warnings = $standardWarnings
        agent_count = if ($null -ne $agentsManifest) { $agents.Count } else { 0 }
        skill_count = if ($null -ne $skillsManifest) { $skills.Count } else { 0 }
        command_count = if ($null -ne $commandsManifest) { $commands.Count } else { 0 }
        proxy_count = if ($null -ne $proxiesManifest) { $proxies.Count } else { 0 }
        hook_count = if ($null -ne $hooksManifest) { $hooks.Count } else { 0 }
        mcp_server_count = if ($null -ne $mcpManifest) { $mcpServers.Count } else { 0 }
        route_count = if ($null -ne $routerConfig) { $routes.Count } else { 0 }
        workflow_count = if ($null -ne $workflowsManifest) { $workflows.Count } else { 0 }
        evolution_config_loaded = if ($null -ne $evolutionConfig) { $true } else { $false }
    }
    quality_layer = $qualityLayer
    legacy_layer = [ordered]@{
        broken_links = $legacyBrokenLinks
        agent_front_matter_missing = $agentFrontMatterMissing
        skill_front_matter_missing = $skillFrontMatterMissing
        warnings_sample = $legacyWarnings
    }
    overall_status = $overallStatus
}

$jsonReportPath = Join-Path $reportRoot "claude-config-audit.json"
$mdReportPath = Join-Path $reportRoot "claude-config-audit.md"

$json = $result | ConvertTo-Json -Depth 30
Write-Utf8NoBom -FilePath $jsonReportPath -Text $json

$md = @()
$md += "# Claude Config Audit Report"
$md += ""
$md += "- Time: $($result.timestamp)"
$md += "- Project: $($result.project_root)"
$md += "- Overall: **$($result.overall_status)**"
$md += ""
$md += "## Standard Layer"
$md += ""
$md += "- Status: **$($result.standard_layer.status)**"
$md += "- Agents: $($result.standard_layer.agent_count)"
$md += "- Skills: $($result.standard_layer.skill_count)"
$md += "- Commands: $($result.standard_layer.command_count)"
$md += "- Proxies: $($result.standard_layer.proxy_count)"
$md += "- Hooks: $($result.standard_layer.hook_count)"
$md += "- MCP Servers: $($result.standard_layer.mcp_server_count)"
$md += "- Routes: $($result.standard_layer.route_count)"
$md += "- Workflows: $($result.standard_layer.workflow_count)"
$md += "- Evolution Config Loaded: $($result.standard_layer.evolution_config_loaded)"
$md += "- Errors: $($result.standard_layer.errors.Count)"
$md += "- Warnings: $($result.standard_layer.warnings.Count)"
$md += ""
if ($result.standard_layer.errors.Count -gt 0) {
    $md += "### Errors"
    foreach ($item in $result.standard_layer.errors) { $md += "- $item" }
    $md += ""
}
if ($result.standard_layer.warnings.Count -gt 0) {
    $md += "### Warnings"
    foreach ($item in $result.standard_layer.warnings) { $md += "- $item" }
    $md += ""
}

$md += "## Quality Layer"
$md += ""
$md += "- Evolution enabled: $($result.quality_layer.evolution_enabled)"
$md += "- Commands: $($result.quality_layer.command_count)"
$md += "- Proxies: $($result.quality_layer.proxy_count)"
$md += "- Hooks: $($result.quality_layer.hook_count)"
$md += "- MCP servers: $($result.quality_layer.mcp_server_count)"
$md += "- Project-manifest MCP enabled by default: $($result.quality_layer.enabled_mcp_servers)"
$md += "- Enabled-count policy scope: $($result.quality_layer.enabled_mcp_policy_scope)"
$md += "- Runtime MCP capture status: $($result.quality_layer.runtime_mcp_capture_status)"
$md += "- Runtime MCP snapshot: $($result.quality_layer.runtime_mcp_snapshot_path)"
$md += "- Runtime MCP configured after merge: $($result.quality_layer.runtime_configured_mcp_servers)"
$md += "- Runtime MCP enabled: $($result.quality_layer.runtime_enabled_mcp_servers)"
$md += "- Runtime MCP enabled outside project default: $($result.quality_layer.runtime_enabled_outside_project_default)"
$md += "- Runtime MCP undeclared enabled: $($result.quality_layer.runtime_enabled_undeclared)"
$md += "- Runtime inheritance drift project-closable: $($result.quality_layer.runtime_inheritance_drift_project_closable)"
$md += "- Missing required config files: $($result.quality_layer.missing_required_config_files)"
$md += "- Keyword collisions: $($result.quality_layer.keyword_collisions)"
$md += "- Orphan skills: $($result.quality_layer.orphan_skills)"
$md += "- Dependency depth: $($result.quality_layer.dependency_depth)"
$md += "- Dependency cycle detected: $($result.quality_layer.dependency_cycle_detected)"
$md += "- Required workflow unmapped: $($result.quality_layer.required_workflow_unmapped)"
$md += "- Canonical entry doc missing: $($result.quality_layer.canonical_entry_doc_missing)"
$md += "- Legacy external entry mentions: $($result.quality_layer.legacy_external_entry_mentions)"
$md += "- build_compile has windows-build: $($result.quality_layer.build_compile_has_windows_skill)"
$md += "- build_compile workflow is windows-build: $($result.quality_layer.build_compile_windows_workflow)"
$md += "- Codex compat missing: $($result.quality_layer.codex_compat_missing)"
$md += "- Codex required agents missing: $($result.quality_layer.codex_required_agents_missing)"
$md += "- Codex native config issues: $($result.quality_layer.codex_native_config_issues)"
$md += "- Codex skill metadata issues: $($result.quality_layer.codex_skill_metadata_issues)"
$md += "- Codex agents bridge issues: $($result.quality_layer.codex_agents_bridge_issues)"
$md += "- Codex sidecar validation: $($result.quality_layer.codex_sidecar_validation_status)"
$md += "- Codex guardrail audit: $($result.quality_layer.codex_guardrail_audit_status)"
$md += "- Codex skills audit: $($result.quality_layer.codex_skills_audit_status)"
$md += ""

if (@($result.quality_layer.samples.missing_required_config_files).Count -gt 0) {
    $md += "### Missing Required Config Files"
    foreach ($item in @($result.quality_layer.samples.missing_required_config_files)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.keyword_collisions).Count -gt 0) {
    $md += "### Keyword Collision Sample"
    foreach ($item in @($result.quality_layer.samples.keyword_collisions)) {
        $md += "- [$($item.domain)] $($item.keyword) :: count=$($item.count) :: intents=$($item.intents)"
    }
    $md += ""
}
if (@($result.quality_layer.samples.orphan_skills).Count -gt 0) {
    $md += "### Orphan Skills Sample"
    foreach ($item in @($result.quality_layer.samples.orphan_skills)) {
        $md += "- $item"
    }
    $md += ""
}
if (@($result.quality_layer.samples.unmapped_required_workflows).Count -gt 0) {
    $md += "### Unmapped Required Workflows"
    foreach ($item in @($result.quality_layer.samples.unmapped_required_workflows)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.enabled_mcp_servers).Count -gt 0) {
    $md += "### Enabled MCP Servers"
    foreach ($item in @($result.quality_layer.samples.enabled_mcp_servers)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.runtime_enabled_mcp_servers).Count -gt 0) {
    $md += "### Runtime Enabled MCP Servers"
    foreach ($item in @($result.quality_layer.samples.runtime_enabled_mcp_servers)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.runtime_enabled_undeclared).Count -gt 0) {
    $md += "### Runtime Enabled MCP Servers Missing In Manifest"
    foreach ($item in @($result.quality_layer.samples.runtime_enabled_undeclared)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.runtime_mcp_capture_errors).Count -gt 0) {
    $md += "### Runtime MCP Capture Errors"
    foreach ($item in @($result.quality_layer.samples.runtime_mcp_capture_errors)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.canonical_entry_missing_docs).Count -gt 0) {
    $md += "### Canonical Entry Missing Docs"
    foreach ($item in @($result.quality_layer.samples.canonical_entry_missing_docs)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.legacy_entry_docs).Count -gt 0) {
    $md += "### Legacy Entry Docs"
    foreach ($item in @($result.quality_layer.samples.legacy_entry_docs)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.codex_compat_missing_files).Count -gt 0) {
    $md += "### Codex Compat Missing Files"
    foreach ($item in @($result.quality_layer.samples.codex_compat_missing_files)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.codex_required_agents_missing).Count -gt 0) {
    $md += "### Codex Required Agents Missing"
    foreach ($item in @($result.quality_layer.samples.codex_required_agents_missing)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.codex_native_config_issues).Count -gt 0) {
    $md += "### Codex Native Config Issues"
    foreach ($item in @($result.quality_layer.samples.codex_native_config_issues)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.codex_skill_metadata_issues).Count -gt 0) {
    $md += "### Codex Skill Metadata Issues"
    foreach ($item in @($result.quality_layer.samples.codex_skill_metadata_issues)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.codex_agents_bridge_issues).Count -gt 0) {
    $md += "### Codex Agents Bridge Issues"
    foreach ($item in @($result.quality_layer.samples.codex_agents_bridge_issues)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.codex_sidecar_validation_output).Count -gt 0) {
    $md += "### Codex Sidecar Validation Output"
    foreach ($item in @($result.quality_layer.samples.codex_sidecar_validation_output)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.codex_guardrail_audit_output).Count -gt 0) {
    $md += "### Codex Guardrail Audit Output"
    foreach ($item in @($result.quality_layer.samples.codex_guardrail_audit_output)) {
        $md += "- $item"
    }
    $md += ""
}

if (@($result.quality_layer.samples.codex_skills_audit_output).Count -gt 0) {
    $md += "### Codex Skills Audit Output"
    foreach ($item in @($result.quality_layer.samples.codex_skills_audit_output)) {
        $md += "- $item"
    }
    $md += ""
}

$md += "## Legacy Layer (Non-blocking)"
$md += ""
$md += "- Broken links: $($result.legacy_layer.broken_links)"
$md += "- Agent front matter missing: $($result.legacy_layer.agent_front_matter_missing)"
$md += "- Skill front matter missing: $($result.legacy_layer.skill_front_matter_missing)"
$md += ""
if ($result.legacy_layer.warnings_sample.Count -gt 0) {
    $md += "### Warning Sample"
    foreach ($item in $result.legacy_layer.warnings_sample) { $md += "- $item" }
}

Write-Utf8NoBom -FilePath $mdReportPath -Text ([string]::Join("`r`n", $md))

Write-Output "=== Claude Config Audit ==="
Write-Output "Standard Layer: $standardStatus"
Write-Output "Evolution Enabled: $evolutionEnabled"
Write-Output "Missing Required Config Files: $($missingRequiredConfigFiles.Count)"
Write-Output "Commands: $($commandIds.Count)"
Write-Output "Proxies: $($proxyIds.Count)"
Write-Output "Hooks: $($hookIds.Count)"
Write-Output "MCP Servers: $($mcpServerIds.Count)"
Write-Output "Project MCP Enabled By Default: $enabledMcpServerCount"
Write-Output "Runtime MCP Capture: $runtimeMcpCaptureStatus"
Write-Output "Runtime MCP Configured: $runtimeMcpConfiguredServerCount"
Write-Output "Runtime MCP Enabled: $runtimeMcpEnabledServerCount"
Write-Output "Runtime MCP Outside Project Default: $($runtimeMcpOutsideProjectDefaultServers.Count)"
Write-Output "Keyword Collisions: $($keywordCollisions.Count)"
Write-Output "Orphan Skills: $($orphanSkills.Count)"
Write-Output "Dependency Depth: $dependencyDepth"
Write-Output "Dependency Cycle: $dependencyCycle"
Write-Output "Required Workflow Unmapped: $($unmappedRequiredWorkflowIntents.Count)"
Write-Output "Canonical Entry Doc Missing: $($canonicalEntryMissingDocs.Count)"
Write-Output "Legacy Entry Mentions: $($legacyEntryStillUsedDocs.Count)"
Write-Output "build_compile has windows-build: $buildCompileHasWindowsSkill"
Write-Output "build_compile workflow windows-build: $buildCompileWorkflowIsWindows"
Write-Output "Codex Compat Missing: $($codexCompatMissingFiles.Count)"
Write-Output "Codex Required Agents Missing: $($codexMissingRequiredAgentIds.Count)"
Write-Output "Codex Native Config Issues: $($codexNativeConfigIssues.Count)"
Write-Output "Codex Skill Metadata Issues: $($codexSkillMetadataIssues.Count)"
Write-Output "Codex Agents Bridge Issues: $($codexAgentsBridgeIssues.Count)"
Write-Output "Codex Sidecar Validation: $codexSidecarValidationStatus"
Write-Output "Codex Guardrail Audit: $codexGuardrailAuditStatus"
Write-Output "Codex Skills Audit: $codexSkillsAuditStatus"
Write-Output "Legacy Broken Links: $legacyBrokenLinks"
Write-Output "Agent FM Missing: $agentFrontMatterMissing"
Write-Output "Skill FM Missing: $skillFrontMatterMissing"
Write-Output "JSON Report: $jsonReportPath"
Write-Output "Markdown Report: $mdReportPath"

if ($overallStatus -eq "PASS") {
    exit 0
}
exit 1

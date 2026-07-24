param(
    [string]$ProjectRoot = "",
    [switch]$SkipAudit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
    } else {
        $ProjectRoot = (Get-Location).Path
    }
}

$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$skillsRoot = Join-Path $ProjectRoot ".agents\skills"
$reportsRoot = Join-Path $ProjectRoot ".claude\reports"
$auditScriptPath = Join-Path $ProjectRoot ".claude\scripts\audit_codex_skills.ps1"
$auditJsonPath = Join-Path $reportsRoot "codex-skills-audit.json"
$outputJsonPath = Join-Path $reportsRoot "codex-skills-workflow-health.json"
$outputMdPath = Join-Path $reportsRoot "codex-skills-workflow-health.md"
$qualityGatePath = Join-Path $ProjectRoot ".claude\scripts\quality_gate.ps1"
$workflowPath = Join-Path $ProjectRoot ".github\workflows\codex-skills-quality-gate.yml"
$agentsGuidePath = Join-Path $ProjectRoot ".claude\AGENTS.md"
$legacyRoutingPath = Join-Path $ProjectRoot ".agents\skills\mt3-project-guidelines\references\legacy-skill-routing.md"
$factPackPath = Join-Path $ProjectRoot ".agents\skills\mt3-project-guidelines\references\high-frequency-fact-packs.md"
$runtimeSnapshotPath = Join-Path $reportsRoot "mcp-runtime-snapshot.json"
$skillsManifestPath = Join-Path $ProjectRoot ".claude\config\skills.manifest.json"

if (-not (Test-Path $skillsRoot -PathType Container)) {
    throw "Missing skills root: $skillsRoot"
}

function Write-Utf8NoBom {
    param(
        [string]$FilePath,
        [string]$Text
    )

    $directory = Split-Path -Parent $FilePath
    if (-not (Test-Path $directory)) {
        New-Item -Path $directory -ItemType Directory | Out-Null
    }
    [System.IO.File]::WriteAllText($FilePath, $Text, $utf8NoBom)
}

function New-UString {
    param([int[]]$CodePoints)

    return [string]::Concat(($CodePoints | ForEach-Object { [char]$_ }))
}

function Get-RelativeProjectPath {
    param([string]$AbsolutePath)

    $rootWithSlash = $ProjectRoot.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
    $rootUri = New-Object System.Uri($rootWithSlash)
    $pathUri = New-Object System.Uri($AbsolutePath)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace("\", "/")
}

function Test-ObjectProperty {
    param(
        [object]$Object,
        [string]$PropertyName
    )

    return (
        $null -ne $Object -and
        $null -ne $Object.PSObject -and
        $Object.PSObject.Properties.Name -contains $PropertyName
    )
}

function Get-ObjectPropertyValue {
    param(
        [object]$Object,
        [string[]]$PropertyNames
    )

    foreach ($propertyName in $PropertyNames) {
        if (-not (Test-ObjectProperty -Object $Object -PropertyName $propertyName)) {
            continue
        }

        $value = $Object.$propertyName
        if ($null -ne $value -and -not [string]::IsNullOrWhiteSpace([string]$value)) {
            return $value
        }
    }

    return $null
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

    if (Test-ObjectProperty -Object $Value -PropertyName "value") {
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

function Get-McpRuntimeServerList {
    param([object]$Snapshot)

    if (-not (Test-ObjectProperty -Object $Snapshot -PropertyName "servers")) {
        return @()
    }

    $servers = @(ConvertTo-ObjectList -Value $Snapshot.servers)
    if (
        $servers.Count -eq 1 -and
        (Test-ObjectProperty -Object $servers[0] -PropertyName "value")
    ) {
        $unwrappedServers = @(ConvertTo-ObjectList -Value $servers[0].value)
        if (@($unwrappedServers | Where-Object { Test-ObjectProperty -Object $_ -PropertyName "name" }).Count -gt 0) {
            $servers = $unwrappedServers
        }
    }

    return @($servers | Where-Object { Test-ObjectProperty -Object $_ -PropertyName "name" })
}

function Get-FrontMatter {
    param([string]$Text)

    $match = [regex]::Match($Text, '(?s)^---\r?\n(.*?)\r?\n---\r?\n')
    if (-not $match.Success) {
        return [ordered]@{
            raw = ""
            body = $Text
        }
    }

    return [ordered]@{
        raw = $match.Groups[1].Value
        body = $Text.Substring($match.Length)
    }
}

function Test-Heading {
    param(
        [string]$Body,
        [string[]]$Headings
    )

    foreach ($heading in $Headings) {
        $pattern = '(?m)^##\s+' + [regex]::Escape($heading) + '\s*$'
        if ([regex]::IsMatch($Body, $pattern)) {
            return $true
        }
    }

    return $false
}

function Test-BodyPattern {
    param(
        [string]$Body,
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ([regex]::IsMatch($Body, $pattern)) {
            return $true
        }
    }

    return $false
}

function Get-BodyPatternCount {
    param(
        [string]$Body,
        [string[]]$Patterns
    )

    $count = 0
    foreach ($pattern in $Patterns) {
        $count += ([regex]::Matches($Body, $pattern)).Count
    }
    return $count
}

function ConvertTo-DescriptionSignature {
    param([string]$Text)

    $signature = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $signature
    }

    foreach ($tokenMatch in [regex]::Matches($Text.ToLowerInvariant(), '[a-z0-9_\-\./\+]{3,}')) {
        $token = $tokenMatch.Value.Trim()
        if ($token.Length -ge 3) {
            [void]$signature.Add($token)
        }
    }

    $normalized = [regex]::Replace($Text, '[^\p{IsCJKUnifiedIdeographs}a-zA-Z0-9]+', '')
    if ($normalized.Length -ge 2) {
        for ($index = 0; $index -lt ($normalized.Length - 1); $index++) {
            $gram = $normalized.Substring($index, 2)
            if ($gram -match '^[\p{IsCJKUnifiedIdeographs}]{2}$') {
                [void]$signature.Add($gram)
            }
        }
    }

    return $signature
}

function Get-JaccardSimilarity {
    param(
        [System.Collections.Generic.HashSet[string]]$Left,
        [System.Collections.Generic.HashSet[string]]$Right
    )

    if ($Left.Count -eq 0 -and $Right.Count -eq 0) {
        return 0.0
    }

    $intersection = 0
    foreach ($item in $Left) {
        if ($Right.Contains($item)) {
            $intersection++
        }
    }

    $union = $Left.Count
    foreach ($item in $Right) {
        if (-not $Left.Contains($item)) {
            $union++
        }
    }

    if ($union -le 0) {
        return 0.0
    }

    return [math]::Round(($intersection / $union), 2)
}

function ConvertTo-ScoreBand {
    param([int]$SkillChars)

    if ($SkillChars -le 2500) {
        return 8
    }
    if ($SkillChars -le 3500) {
        return 7
    }
    if ($SkillChars -le 4500) {
        return 6
    }
    return 4
}

function New-ScoreObject {
    param(
        [int]$Score,
        [string[]]$Notes
    )

    return [pscustomobject][ordered]@{
        score = $Score
        max = 20
        notes = @($Notes)
    }
}

if (-not $SkipAudit) {
    if (-not (Test-Path $auditScriptPath -PathType Leaf)) {
        throw "Missing audit script: $auditScriptPath"
    }

    & powershell -NoProfile -ExecutionPolicy Bypass -File $auditScriptPath -ProjectRoot $ProjectRoot
    if ($LASTEXITCODE -ne 0) {
        throw "audit_codex_skills.ps1 failed with exit code $LASTEXITCODE"
    }
}

if (-not (Test-Path $auditJsonPath -PathType Leaf)) {
    throw "Missing codex skills audit report: $auditJsonPath"
}

$audit = Get-Content -Raw -Encoding UTF8 $auditJsonPath | ConvertFrom-Json
$runtimeSnapshot = $null
$runtimeNames = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
$runtimeSnapshotAgeHours = $null
if (Test-Path $runtimeSnapshotPath -PathType Leaf) {
    $runtimeSnapshot = Get-Content -Raw -Encoding UTF8 $runtimeSnapshotPath | ConvertFrom-Json
    $runtimeTimestamp = Get-ObjectPropertyValue -Object $runtimeSnapshot -PropertyNames @("generated_at", "timestamp")
    if ($null -ne $runtimeTimestamp) {
        try {
            $runtimeSnapshotAgeHours = [math]::Round(((Get-Date) - [datetime]$runtimeTimestamp).TotalHours, 1)
        } catch {
            $runtimeSnapshotAgeHours = $null
        }
    }

    $runtimeServers = @(Get-McpRuntimeServerList -Snapshot $runtimeSnapshot)
    if ($runtimeServers.Count -gt 0) {
        foreach ($runtimeServer in $runtimeServers) {
            [void]$runtimeNames.Add([string]$runtimeServer.name)
        }
    } elseif (Test-ObjectProperty -Object $runtimeSnapshot -PropertyName "enabled_servers") {
        foreach ($enabledServer in @(ConvertTo-ObjectList -Value $runtimeSnapshot.enabled_servers)) {
            $enabledServerName = [string]$enabledServer
            if (-not [string]::IsNullOrWhiteSpace($enabledServerName)) {
                [void]$runtimeNames.Add($enabledServerName)
            }
        }
    } elseif (Test-ObjectProperty -Object $runtimeSnapshot -PropertyName "raw_output") {
        $rawRuntimeOutput = [string]$runtimeSnapshot.raw_output
        foreach ($match in [regex]::Matches($rawRuntimeOutput, '(?m)^([A-Za-z0-9_-]+)\s+https?://')) {
            [void]$runtimeNames.Add([string]$match.Groups[1].Value)
        }
    }
}

$legacyRoutingText = if (Test-Path $legacyRoutingPath -PathType Leaf) {
    Get-Content -Raw -Encoding UTF8 $legacyRoutingPath
} else {
    ""
}

$skillsManifest = if (Test-Path $skillsManifestPath -PathType Leaf) {
    Get-Content -Raw -Encoding UTF8 $skillsManifestPath | ConvertFrom-Json
} else {
    $null
}

$legacySkillIds = @()
if ($null -ne $skillsManifest -and $null -ne $skillsManifest.skills) {
    $legacySkillIds = @($skillsManifest.skills | ForEach-Object { [string]$_.id })
}

$legacySkillCoverageMissing = New-Object System.Collections.Generic.List[string]
foreach ($legacySkillId in $legacySkillIds) {
    if ($legacyRoutingText.IndexOf($legacySkillId, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        [void]$legacySkillCoverageMissing.Add($legacySkillId)
    }
}

$workflowHealthEnabled = Test-Path $workflowPath -PathType Leaf
$qualityGateMentionsWorkflowHealth = $false
if (Test-Path $qualityGatePath -PathType Leaf) {
    $qualityGateText = Get-Content -Raw -Encoding UTF8 $qualityGatePath
    $qualityGateMentionsWorkflowHealth = $qualityGateText.Contains("codex-skills-workflow-health.json")
}

$guidanceMentionsAnalyzer = $false
if (Test-Path $agentsGuidePath -PathType Leaf) {
    $guidanceText = Get-Content -Raw -Encoding UTF8 $agentsGuidePath
    $guidanceMentionsAnalyzer = $guidanceText.Contains("analyze_codex_skill_workflows.ps1")
}

$officialCriteria = @(
    [pscustomobject][ordered]@{
        id = "progressive_disclosure"
        summary = "Use progressive disclosure: Codex starts with metadata and only loads SKILL.md when the skill is selected."
        source = "https://developers.openai.com/codex/skills"
    },
    [pscustomobject][ordered]@{
        id = "clear_scope"
        summary = "Implicit invocation depends on the description, so scope and negative boundaries must be explicit."
        source = "https://developers.openai.com/codex/skills"
    },
    [pscustomobject][ordered]@{
        id = "single_job"
        summary = "Keep each skill focused on one job."
        source = "https://developers.openai.com/codex/skills"
    },
    [pscustomobject][ordered]@{
        id = "instructions_first"
        summary = "Prefer instructions over scripts unless deterministic behavior or external tooling is required."
        source = "https://developers.openai.com/codex/skills"
    },
    [pscustomobject][ordered]@{
        id = "explicit_io"
        summary = "Write imperative steps with explicit inputs and outputs."
        source = "https://developers.openai.com/codex/skills"
    },
    [pscustomobject][ordered]@{
        id = "trigger_testing"
        summary = "Test prompts against the description to confirm the expected trigger behavior."
        source = "https://developers.openai.com/codex/skills"
    },
    [pscustomobject][ordered]@{
        id = "policy_and_dependencies"
        summary = "Use agents/openai.yaml to declare invocation policy and runtime dependencies."
        source = "https://developers.openai.com/codex/skills"
    }
)

$workflowHeadingNames = @(
    (New-UString @(0x6267, 0x884C, 0x987A, 0x5E8F)),
    (New-UString @(0x6807, 0x51C6, 0x6D41, 0x7A0B)),
    (New-UString @(0x6D41, 0x7A0B))
)
$explicitInputPatterns = @(
    (New-UString @(0x5148, 0x786E, 0x8BA4)),
    (New-UString @(0x5148, 0x62FF, 0x5230)),
    (New-UString @(0x8F93, 0x5165)),
    (New-UString @(0x53C2, 0x6570)),
    (New-UString @(0x5165, 0x53E3)),
    (New-UString @(0x8DEF, 0x5F84)),
    (New-UString @(0x65E5, 0x5FD7)),
    (New-UString @(0x73AF, 0x5883)),
    (New-UString @(0x914D, 0x7F6E)),
    (New-UString @(0x9996, 0x4E2A, 0x963B, 0x585E))
)
$conflictPatterns = @(
    (New-UString @(0x5931, 0x8D25)),
    (New-UString @(0x963B, 0x585E)),
    (New-UString @(0x51B2, 0x7A81)),
    (New-UString @(0x56DE, 0x9000)),
    (New-UString @(0x5148, 0x4FEE)),
    (New-UString @(0x4E0D, 0x8981)),
    (New-UString @(0x8BB0, 0x5F55)),
    (New-UString @(0x7F3A, 0x5931)),
    (New-UString @(0x6F02, 0x79FB))
)
$negativeBoundaryUse = New-UString @(0x4E0D, 0x7528, 0x4E8E)
$negativeBoundaryOwn = New-UString @(0x4E0D, 0x8D1F, 0x8D23)
$stepFirst = New-UString @(0x5148)
$stepConfirm = New-UString @(0x5148, 0x786E, 0x8BA4)
$stepThenJudge = New-UString @(0x518D, 0x5224, 0x65AD)
$stepLast = New-UString @(0x6700, 0x540E)

$skillAnalyses = New-Object System.Collections.Generic.List[object]
$overlapWarnings = New-Object System.Collections.Generic.List[object]
$descriptionSignatures = @{}

foreach ($skill in @($audit.skills)) {
    $descriptionSignatures[[string]$skill.skill] = ConvertTo-DescriptionSignature -Text ([string]$skill.front_matter.description)
}

foreach ($skill in @($audit.skills)) {
    $skillName = [string]$skill.skill
    $skillDir = Join-Path $ProjectRoot ([string]$skill.path)
    $skillDocPath = Join-Path $ProjectRoot ([string]$skill.skill_doc)
    $metadataPath = Join-Path $ProjectRoot ([string]$skill.metadata)
    $skillText = Get-Content -Raw -Encoding UTF8 $skillDocPath
    $frontMatter = Get-FrontMatter -Text $skillText
    $skillBody = [string]$frontMatter.body
    $yamlText = Get-Content -Raw -Encoding UTF8 $metadataPath
    $dependencyNames = @([regex]::Matches($yamlText, '(?m)^\s*value:\s*"([^"]+)"\s*$') | ForEach-Object { [string]$_.Groups[1].Value })
    $scriptFiles = if (Test-Path (Join-Path $skillDir "scripts") -PathType Container) {
        @(Get-ChildItem -Path (Join-Path $skillDir "scripts") -Recurse -File -Filter *.ps1 | Sort-Object FullName | Where-Object { $_.Name -notmatch '(?i)-helpers\.ps1$' })
    } else {
        @()
    }

    $scriptParamCounts = New-Object System.Collections.Generic.List[int]
    $scriptMandatoryCounts = New-Object System.Collections.Generic.List[int]
    $scriptHasPathValidation = New-Object System.Collections.Generic.List[bool]
    $scriptHasRepoResolve = New-Object System.Collections.Generic.List[bool]
    $scriptHasFailureLists = New-Object System.Collections.Generic.List[bool]
    $scriptHasWarningLists = New-Object System.Collections.Generic.List[bool]
    $scriptHasEarlyFail = New-Object System.Collections.Generic.List[bool]
    $scriptRelativePaths = New-Object System.Collections.Generic.List[string]

    foreach ($scriptFile in $scriptFiles) {
        $scriptContent = Get-Content -Raw -Encoding UTF8 $scriptFile.FullName
        $paramMatch = [regex]::Match($scriptContent, '(?s)^\s*\[CmdletBinding\(\)\]\s*param\((.*?)\)\s*')
        $paramBlock = if ($paramMatch.Success) { [string]$paramMatch.Groups[1].Value } else { "" }
        $paramCount = ([regex]::Matches($paramBlock, '(?m)^\s*(?:\[[^\]]+\]\s*)*\$\w+')).Count
        $mandatoryCount = ([regex]::Matches($paramBlock, '(?im)Mandatory\s*=\s*\$true')).Count
        [void]$scriptParamCounts.Add($paramCount)
        [void]$scriptMandatoryCounts.Add($mandatoryCount)
        [void]$scriptHasPathValidation.Add([regex]::IsMatch($scriptContent, '(?m)\bTest-Path\b|\bResolve-FilePath\b'))
        [void]$scriptHasRepoResolve.Add([regex]::IsMatch($scriptContent, '(?m)\bResolve-RepoRootPath\b'))
        [void]$scriptHasFailureLists.Add([regex]::IsMatch($scriptContent, '(?m)\$failures\s*=\s*New-Object'))
        [void]$scriptHasWarningLists.Add([regex]::IsMatch($scriptContent, '(?m)\$warnings\s*=\s*New-Object'))
        [void]$scriptHasEarlyFail.Add([regex]::IsMatch($scriptContent, 'Write-Result\s+-Status\s+"FAIL"'))
        [void]$scriptRelativePaths.Add((Get-RelativeProjectPath -AbsolutePath $scriptFile.FullName))
    }

    $metadataAllowImplicit = $null
    if ($null -ne $skill.metadata_fields.allow_implicit_invocation) {
        $metadataAllowImplicit = [bool]$skill.metadata_fields.allow_implicit_invocation
    }
    $hasNegativeBoundary = ([string]$skill.front_matter.description).Contains($negativeBoundaryUse) -or ([string]$skill.front_matter.description).Contains($negativeBoundaryOwn)
    $hasWorkflowHeading = Test-Heading -Body $skillBody -Headings $workflowHeadingNames
    $proceduralCueCount = Get-BodyPatternCount -Body $skillBody -Patterns @(
        '(?m)^\d+\.\s+',
        ('(?m)^-\s+' + [regex]::Escape($stepFirst)),
        ([regex]::Escape($stepConfirm)),
        ([regex]::Escape($stepThenJudge)),
        ([regex]::Escape($stepLast))
    )
    $hasExplicitInputs = Test-BodyPattern -Body $skillBody -Patterns $explicitInputPatterns
    $hasConflictHandling = Test-BodyPattern -Body $skillBody -Patterns $conflictPatterns
    $hasReferencesMention = $skillBody -match 'references/'
    $hasAssetsMention = $skillBody -match 'assets/'
    $hasProgressiveDisclosure = (($skill.reference_count -gt 0 -and $hasReferencesMention) -or ($skill.asset_count -gt 0 -and $hasAssetsMention) -or ([int]$skill.skill_chars -le 3200))
    $allScriptsHaveParams = ($scriptParamCounts.Count -eq 0) -or (@($scriptParamCounts | Where-Object { $_ -le 0 }).Count -eq 0)
    $allScriptsValidatePaths = ($scriptHasPathValidation.Count -eq 0) -or (@($scriptHasPathValidation | Where-Object { -not $_ }).Count -eq 0)
    $allScriptsResolveRepo = ($scriptHasRepoResolve.Count -eq 0) -or (@($scriptHasRepoResolve | Where-Object { -not $_ }).Count -eq 0)
    $allScriptsHandleFailures = ($scriptHasFailureLists.Count -eq 0) -or (@($scriptHasFailureLists | Where-Object { -not $_ }).Count -eq 0)
    $allScriptsHandleWarnings = ($scriptHasWarningLists.Count -eq 0) -or (@($scriptHasWarningLists | Where-Object { -not $_ }).Count -eq 0)
    $allScriptsHaveEarlyFail = ($scriptHasEarlyFail.Count -eq 0) -or (@($scriptHasEarlyFail | Where-Object { -not $_ }).Count -eq 0)
    $scriptContractPass = ($null -ne $skill.script_contract) -and ((@($skill.script_contract | Where-Object { -not $_.library }).Count -eq 0) -or (@($skill.script_contract | Where-Object { -not $_.pass -and -not $_.library }).Count -eq 0))

    $similarityNotes = New-Object System.Collections.Generic.List[string]
    $similarityRisk = $false
    if ($metadataAllowImplicit -eq $true) {
        foreach ($otherSkill in @($audit.skills)) {
            $otherName = [string]$otherSkill.skill
            if ($otherName -eq $skillName) {
                continue
            }
            if ($null -eq $otherSkill.metadata_fields.allow_implicit_invocation -or -not [bool]$otherSkill.metadata_fields.allow_implicit_invocation) {
                continue
            }

            $similarity = Get-JaccardSimilarity -Left $descriptionSignatures[$skillName] -Right $descriptionSignatures[$otherName]
            if ($similarity -ge 0.55) {
                $similarityRisk = $true
                $note = "$skillName <-> $otherName similarity=$similarity"
                if (-not $similarityNotes.Contains($note)) {
                    [void]$similarityNotes.Add($note)
                }
                [void]$overlapWarnings.Add([pscustomobject][ordered]@{
                    left = $skillName
                    right = $otherName
                    similarity = $similarity
                })
            }
        }
    }

    $dependencyRuntimeMissing = New-Object System.Collections.Generic.List[string]
    foreach ($dependencyName in $dependencyNames) {
        if (-not $runtimeNames.Contains($dependencyName)) {
            [void]$dependencyRuntimeMissing.Add($dependencyName)
        }
    }

    $inputScore = 0
    $inputNotes = New-Object System.Collections.Generic.List[string]
    if ([bool]$skill.sections.input_validation) {
        $inputScore += 8
        [void]$inputNotes.Add("Input validation section is present in SKILL.md.")
    } else {
        [void]$inputNotes.Add("Missing input validation section.")
    }
    if ($hasExplicitInputs) {
        $inputScore += 6
        [void]$inputNotes.Add("The body contains explicit preflight cues such as confirm, path, log, or environment checks.")
    } else {
        [void]$inputNotes.Add("Preflight input expectations are not explicit enough.")
    }
    if (@($scriptFiles).Count -gt 0) {
        if ($allScriptsHaveParams) {
            $inputScore += 3
            [void]$inputNotes.Add("All scripts expose explicit parameters.")
        } else {
            [void]$inputNotes.Add("At least one script does not expose clear parameters.")
        }
        if ($allScriptsValidatePaths -or $allScriptsResolveRepo) {
            $inputScore += 3
            [void]$inputNotes.Add("Scripts validate repo root or file paths before doing work.")
        } else {
            [void]$inputNotes.Add("Scripts need stronger repo root or path validation.")
        }
    } else {
        if ($hasExplicitInputs -and $hasWorkflowHeading) {
            $inputScore += 6
            [void]$inputNotes.Add("Instruction-only skill compensates for the lack of scripts with explicit entry conditions and steps.")
        } else {
            [void]$inputNotes.Add("Instruction-only skill still needs sharper input boundaries.")
        }
    }

    $logicScore = 0
    $logicNotes = New-Object System.Collections.Generic.List[string]
    if ([bool]$skill.sections.use_when) {
        $logicScore += 3
        [void]$logicNotes.Add("Use-when routing is defined.")
    } else {
        [void]$logicNotes.Add("Missing explicit use-when routing.")
    }
    if ([bool]$skill.sections.dont_use) {
        $logicScore += 3
        [void]$logicNotes.Add("Negative routing boundary is defined.")
    } else {
        [void]$logicNotes.Add("Missing don't-use boundary.")
    }
    if ($hasWorkflowHeading) {
        $logicScore += 5
        [void]$logicNotes.Add("The body contains an explicit workflow anchor.")
    } else {
        [void]$logicNotes.Add("The body lacks an explicit workflow anchor.")
    }
    if ($proceduralCueCount -gt 0) {
        $logicScore += 4
        [void]$logicNotes.Add("Numbered steps or first/then/final cues are present.")
    } else {
        [void]$logicNotes.Add("Procedural steps are not explicit enough.")
    }
    if ([bool]$skill.sections.output_verification) {
        $logicScore += 3
        [void]$logicNotes.Add("Output verification section is present.")
    } else {
        [void]$logicNotes.Add("Missing output verification section.")
    }
    if ($hasProgressiveDisclosure) {
        $logicScore += 2
        [void]$logicNotes.Add("Progressive disclosure is supported through short body text, references, or scripts.")
    } else {
        [void]$logicNotes.Add("The body is long without enough material moved to references or assets.")
    }

    $errorScore = 0
    $errorNotes = New-Object System.Collections.Generic.List[string]
    if ([bool]$skill.sections.failure_handling) {
        $errorScore += 8
        [void]$errorNotes.Add("Failure-handling section is present.")
    } else {
        [void]$errorNotes.Add("Missing failure-handling section.")
    }
    if ($hasConflictHandling) {
        $errorScore += 4
        [void]$errorNotes.Add("The body contains blocker, conflict, or fallback cues.")
    } else {
        [void]$errorNotes.Add("The body needs a clearer failure escalation path.")
    }
    if (@($scriptFiles).Count -gt 0) {
        if ($scriptContractPass) {
            $errorScore += 4
            [void]$errorNotes.Add("Script output contract passes audit.")
        } else {
            [void]$errorNotes.Add("Not every script passes the output contract audit.")
        }
        if ($allScriptsHandleFailures -and $allScriptsHandleWarnings -and $allScriptsHaveEarlyFail) {
            $errorScore += 4
            [void]$errorNotes.Add("Scripts implement FAIL/WARN branches and early-fail exits.")
        } else {
            [void]$errorNotes.Add("Script failure and warning branches can still be strengthened.")
        }
    } else {
        if ($hasConflictHandling -and [bool]$skill.sections.output_verification) {
            $errorScore += 8
            [void]$errorNotes.Add("Instruction-only skill compensates with explicit conflict handling and verification guidance.")
        } else {
            [void]$errorNotes.Add("Instruction-only skill still needs a clearer failure closure path.")
        }
    }

    $resourceScore = 0
    $resourceNotes = New-Object System.Collections.Generic.List[string]
    $resourceScore += ConvertTo-ScoreBand -SkillChars ([int]$skill.skill_chars)
    [void]$resourceNotes.Add("skill_chars=" + [int]$skill.skill_chars)
    if ([int]$skill.skill_chars -gt 4000) {
        [void]$resourceNotes.Add("The body is long enough to justify moving more edge cases into references.")
    }
    if (([int]$skill.skill_chars -gt 3200) -and ($skill.reference_count -gt 0 -or $skill.asset_count -gt 0 -or $skill.script_count -gt 0)) {
        $resourceScore += 4
        [void]$resourceNotes.Add("Scripts or extra resources already help offset a long body.")
    } elseif ([int]$skill.skill_chars -le 3200) {
        $resourceScore += 4
        [void]$resourceNotes.Add("The body size is in an efficient loading range.")
    } else {
        [void]$resourceNotes.Add("Long body text still needs more supporting material moved out of SKILL.md.")
    }
    if ([int]$skill.script_count -le 1) {
        $resourceScore += 4
        [void]$resourceNotes.Add("Script count stays small, matching the instructions-first guidance.")
    } else {
        $resourceScore += 2
        [void]$resourceNotes.Add("Script count is rising and should be watched for maintenance cost.")
    }
    if ($metadataAllowImplicit -eq $false -or $hasNegativeBoundary) {
        $resourceScore += 4
        [void]$resourceNotes.Add("Invocation boundaries are clear enough to reduce accidental context waste.")
    } else {
        [void]$resourceNotes.Add("Implicit routing still depends heavily on description precision.")
    }

    $accuracyScore = 0
    $accuracyNotes = New-Object System.Collections.Generic.List[string]
    if ($null -ne $metadataAllowImplicit) {
        $accuracyScore += 4
        [void]$accuracyNotes.Add("allow_implicit_invocation is explicit.")
    } else {
        [void]$accuracyNotes.Add("allow_implicit_invocation is not explicit.")
    }
    if ($metadataAllowImplicit -eq $false -or $hasNegativeBoundary) {
        $accuracyScore += 4
        [void]$accuracyNotes.Add("Negative routing boundary is present.")
    } else {
        [void]$accuracyNotes.Add("Implicit routing boundary can be tightened further.")
    }
    if ([string]::IsNullOrWhiteSpace([string]$skill.metadata_fields.default_prompt)) {
        [void]$accuracyNotes.Add("default_prompt is missing.")
    } else {
        $accuracyScore += 4
        [void]$accuracyNotes.Add("default_prompt provides a stable explicit entry point.")
    }
    if (-not $similarityRisk) {
        $accuracyScore += 4
        [void]$accuracyNotes.Add("No high-similarity implicit description pairs were found.")
    } else {
        [void]$accuracyNotes.Add("High-similarity implicit descriptions were found and should be tightened.")
    }
    if ($dependencyRuntimeMissing.Count -eq 0) {
        $accuracyScore += 4
        if ($dependencyNames.Count -gt 0) {
            [void]$accuracyNotes.Add("Declared runtime dependencies are visible in the MCP snapshot.")
        } else {
            [void]$accuracyNotes.Add("This skill has no extra runtime dependencies.")
        }
    } else {
        [void]$accuracyNotes.Add("Declared dependencies are missing from the runtime snapshot: " + [string]::Join(", ", $dependencyRuntimeMissing.ToArray()))
    }

    $scoreTotal = $inputScore + $logicScore + $errorScore + $resourceScore + $accuracyScore
    $status = "PASS"
    if ($scoreTotal -lt 70 -or $dependencyRuntimeMissing.Count -gt 0) {
        $status = "FAIL"
    } elseif ($scoreTotal -lt 85 -or $similarityRisk) {
        $status = "WARN"
    }

    $issues = New-Object System.Collections.Generic.List[string]
    $recommendations = New-Object System.Collections.Generic.List[string]

    if ([int]$skill.skill_chars -gt 4500) {
        [void]$issues.Add("Body text exceeds 4500 characters and increases progressive-disclosure pressure.")
        [void]$recommendations.Add("Move more edge cases, exceptions, or history notes into references so SKILL.md stays a short entry point.")
    }
    if ($metadataAllowImplicit -eq $true -and -not $hasNegativeBoundary) {
        [void]$issues.Add("Implicit invocation description needs a stronger negative boundary.")
        [void]$recommendations.Add("Strengthen the exclusion wording in the description to reduce false-positive matches.")
    }
    if ($similarityRisk) {
        foreach ($note in $similarityNotes) {
            [void]$issues.Add("Implicit description overlap is too high: " + $note)
        }
        [void]$recommendations.Add("Add more domain-specific anchor terms to overlapping descriptions so adjacent skills do not compete for the same prompt.")
    }
    if ($dependencyRuntimeMissing.Count -gt 0) {
        [void]$issues.Add("Declared dependency is missing from the runtime snapshot: " + [string]::Join(", ", $dependencyRuntimeMissing.ToArray()))
        [void]$recommendations.Add("Include MCP and tool dependencies in routine runtime snapshot checks so metadata does not drift from reality.")
    }
    if (@($scriptFiles).Count -gt 0 -and -not ($allScriptsValidatePaths -or $allScriptsResolveRepo)) {
        [void]$issues.Add("Script path or repo-root validation is weaker than expected.")
        [void]$recommendations.Add("Keep standardizing on Resolve-RepoRootPath, Resolve-FilePath, and Test-Path style preflight checks.")
    }
    if ($issues.Count -eq 0) {
        [void]$recommendations.Add("The skill is structurally healthy; keep tracking trigger accuracy and context footprint over time.")
    }

    $analysisRecord = [pscustomobject][ordered]@{
        skill = $skillName
        status = $status
        score = $scoreTotal
        characteristics = [pscustomobject][ordered]@{
            allow_implicit_invocation = $metadataAllowImplicit
            description_length = ([string]$skill.front_matter.description).Length
            skill_chars = [int]$skill.skill_chars
            reference_count = [int]$skill.reference_count
            script_count = [int]$skill.script_count
            asset_count = [int]$skill.asset_count
            dependency_names = @($dependencyNames)
            runtime_dependency_missing = @($dependencyRuntimeMissing)
            script_paths = @($scriptRelativePaths)
            mandatory_param_count = @($scriptMandatoryCounts)
        }
        dimensions = [pscustomobject][ordered]@{
            input_validation = New-ScoreObject -Score $inputScore -Notes $inputNotes.ToArray()
            logic_flow = New-ScoreObject -Score $logicScore -Notes $logicNotes.ToArray()
            error_handling = New-ScoreObject -Score $errorScore -Notes $errorNotes.ToArray()
            resource_efficiency = New-ScoreObject -Score $resourceScore -Notes $resourceNotes.ToArray()
            accuracy_and_runtime = New-ScoreObject -Score $accuracyScore -Notes $accuracyNotes.ToArray()
        }
        issues = @($issues)
        recommendations = @($recommendations)
    }

    [void]$skillAnalyses.Add($analysisRecord)
}

$averageScore = if ($skillAnalyses.Count -gt 0) {
    [int][math]::Round((@($skillAnalyses | Measure-Object -Property score -Average).Average))
} else {
    0
}
$lowestSkill = $skillAnalyses | Sort-Object score, skill | Select-Object -First 1
$highestSkill = $skillAnalyses | Sort-Object -Property score, skill -Descending | Select-Object -First 1
$highContextSkills = @($skillAnalyses | Where-Object { $_.characteristics.skill_chars -gt 4000 } | ForEach-Object { $_.skill })
$dependencyRiskSkills = @($skillAnalyses | Where-Object { $_.characteristics.runtime_dependency_missing.Count -gt 0 } | ForEach-Object { $_.skill })
$skillsBelow85 = @($skillAnalyses | Where-Object { $_.score -lt 85 } | ForEach-Object { $_.skill })

$bottlenecks = New-Object System.Collections.Generic.List[object]
if ($highContextSkills.Count -gt 0) {
    [void]$bottlenecks.Add([pscustomobject][ordered]@{
        severity = "medium"
        finding = "Some skills still have long entry bodies"
        impact = "Longer bodies increase post-trigger context cost and reduce the benefit of progressive disclosure."
        evidence = @($highContextSkills)
        recommendation = "Keep moving history notes, edge cases, and large examples into references or assets."
    })
}
if ($dependencyRiskSkills.Count -gt 0) {
    [void]$bottlenecks.Add([pscustomobject][ordered]@{
        severity = "high"
        finding = "At least one skill declares dependencies that are missing from the runtime snapshot"
        impact = "The skill metadata can drift away from the real execution surface, which directly hurts accuracy."
        evidence = @($dependencyRiskSkills)
        recommendation = "Monitor MCP and tool dependencies continuously and raise a clear warning whenever the runtime snapshot is incomplete."
    })
}
if ($legacySkillCoverageMissing.Count -gt 0) {
    [void]$bottlenecks.Add([pscustomobject][ordered]@{
        severity = "medium"
        finding = "Legacy .claude skill aliases are not fully covered"
        impact = "Old skill names, document paths, or historical wording can still bypass the current .agents entry skills."
        evidence = @($legacySkillCoverageMissing.ToArray())
        recommendation = "Keep legacy-skill-routing.md synchronized with skills.manifest.json and continue auditing the mapping."
    })
}
if (-not $workflowHealthEnabled -or -not $qualityGateMentionsWorkflowHealth) {
    [void]$bottlenecks.Add([pscustomobject][ordered]@{
        severity = "high"
        finding = "Continuous workflow-health monitoring is missing"
        impact = "Only structural issues are visible, while efficiency, trigger accuracy, and dependency availability drift remain hidden."
        evidence = @(
            "workflow_exists=$workflowHealthEnabled",
            "quality_gate_mentions_workflow_health=$qualityGateMentionsWorkflowHealth"
        )
        recommendation = "Wire the workflow-health analysis into GitHub Actions and quality-gate freshness checks."
    })
}

$overallStatus = "PASS"
if ($bottlenecks.Count -gt 0 -and (@($bottlenecks | Where-Object { $_.severity -eq "high" }).Count -gt 0)) {
    $overallStatus = "WARN"
}
if ($averageScore -lt 80) {
    $overallStatus = "WARN"
}
if ($dependencyRiskSkills.Count -gt 0) {
    $overallStatus = "WARN"
}

$implementedImprovements = @{
    shared_helper_adoption = ($audit.summary.script_shared_helper -eq $audit.summary.script_files_total)
    script_json_contract = ($audit.summary.script_json_capable -eq $audit.summary.script_files_total)
    legacy_skill_routing = (Test-Path $legacyRoutingPath -PathType Leaf)
    fact_pack_templates = (Test-Path $factPackPath -PathType Leaf)
    workflow_health_ci = $workflowHealthEnabled
    quality_gate_freshness = $qualityGateMentionsWorkflowHealth
    runtime_snapshot_available = (Test-Path $runtimeSnapshotPath -PathType Leaf)
    governance_entry_mentions_analyzer = $guidanceMentionsAnalyzer
}

$summary = @{
    total_skills = $skillAnalyses.Count
    average_score = $averageScore
    highest_skill = if ($null -ne $highestSkill) { [string]$highestSkill.skill } else { "" }
    highest_score = if ($null -ne $highestSkill) { [int]$highestSkill.score } else { 0 }
    lowest_skill = if ($null -ne $lowestSkill) { [string]$lowestSkill.skill } else { "" }
    lowest_score = if ($null -ne $lowestSkill) { [int]$lowestSkill.score } else { 0 }
    implicit_skills = [int]$audit.summary.implicit_enabled
    instruction_only_skills = (@($skillAnalyses | Where-Object { $_.characteristics.script_count -eq 0 }).Count)
    scripted_skills = [int]$audit.summary.skills_with_scripts
    skills_over_4000_chars = @($highContextSkills)
    skills_below_85 = @($skillsBelow85)
    overlap_warning_count = (@($overlapWarnings | Sort-Object left, right -Unique)).Count
    runtime_dependency_warning_count = $dependencyRiskSkills.Count
    legacy_skill_alias_total = $legacySkillIds.Count
    legacy_skill_alias_missing = @($legacySkillCoverageMissing.ToArray())
    runtime_snapshot_age_hours = $runtimeSnapshotAgeHours
    monitoring_ready = ($workflowHealthEnabled -and $qualityGateMentionsWorkflowHealth)
}

$bottleneckArray = $bottlenecks.ToArray()
$overlapPairArray = @($overlapWarnings.ToArray() | Sort-Object left, right -Unique)
$skillAnalysisArray = $skillAnalyses.ToArray()

$result = @{
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    project_root = $ProjectRoot
    status = $overallStatus
    official_criteria = $officialCriteria
    summary = $summary
    implemented_improvements = $implementedImprovements
    bottlenecks = $bottleneckArray
    overlap_pairs = $overlapPairArray
    skills = $skillAnalysisArray
}

$resultObject = [pscustomobject]$result
$resultJson = $resultObject | ConvertTo-Json -Depth 20
Write-Utf8NoBom -FilePath $outputJsonPath -Text $resultJson

$markdown = New-Object System.Collections.Generic.List[string]
[void]$markdown.Add("# Codex Skills Workflow Health")
[void]$markdown.Add("")
[void]$markdown.Add("- Time: $($resultObject.timestamp)")
[void]$markdown.Add("- Project: $($resultObject.project_root)")
[void]$markdown.Add("- Status: **$($resultObject.status)**")
[void]$markdown.Add("- Skills: $($resultObject.summary.total_skills)")
[void]$markdown.Add("- Average Score: $($resultObject.summary.average_score)")
[void]$markdown.Add("- Highest Score: $($resultObject.summary.highest_skill) ($($resultObject.summary.highest_score))")
[void]$markdown.Add("- Lowest Score: $($resultObject.summary.lowest_skill) ($($resultObject.summary.lowest_score))")
[void]$markdown.Add("- Monitoring Ready: $($resultObject.summary.monitoring_ready)")
[void]$markdown.Add("")
[void]$markdown.Add("## Official Criteria")
[void]$markdown.Add("")
foreach ($item in $resultObject.official_criteria) {
    [void]$markdown.Add(('- [{0}] {1} ({2})' -f $item.id, $item.summary, $item.source))
}
[void]$markdown.Add("")
[void]$markdown.Add("## Summary")
[void]$markdown.Add("")
[void]$markdown.Add("- implicit skills: $($resultObject.summary.implicit_skills)")
[void]$markdown.Add("- instruction-only skills: $($resultObject.summary.instruction_only_skills)")
[void]$markdown.Add("- scripted skills: $($resultObject.summary.scripted_skills)")
[void]$markdown.Add("- skills over 4000 chars: $(if ($resultObject.summary.skills_over_4000_chars.Count -gt 0) { [string]::Join(', ', $resultObject.summary.skills_over_4000_chars) } else { 'none' })")
[void]$markdown.Add("- skills below 85: $(if ($resultObject.summary.skills_below_85.Count -gt 0) { [string]::Join(', ', $resultObject.summary.skills_below_85) } else { 'none' })")
[void]$markdown.Add("- overlap warnings: $($resultObject.summary.overlap_warning_count)")
[void]$markdown.Add("- runtime dependency warnings: $($resultObject.summary.runtime_dependency_warning_count)")
[void]$markdown.Add("- legacy alias missing: $(if ($resultObject.summary.legacy_skill_alias_missing.Count -gt 0) { [string]::Join(', ', $resultObject.summary.legacy_skill_alias_missing) } else { 'none' })")
[void]$markdown.Add("- runtime snapshot age hours: $(if ($null -ne $resultObject.summary.runtime_snapshot_age_hours) { $resultObject.summary.runtime_snapshot_age_hours } else { 'unknown' })")
[void]$markdown.Add("")
[void]$markdown.Add("## Implemented Improvements")
[void]$markdown.Add("")
foreach ($key in $result.implemented_improvements.Keys) {
    [void]$markdown.Add(('- {0}: {1}' -f $key, $result.implemented_improvements[$key]))
}
[void]$markdown.Add("")

if ($resultObject.bottlenecks.Count -gt 0) {
    [void]$markdown.Add("## Bottlenecks")
    [void]$markdown.Add("")
    foreach ($bottleneck in $resultObject.bottlenecks) {
        [void]$markdown.Add("- [$($bottleneck.severity)] $($bottleneck.finding)")
        [void]$markdown.Add("  impact: $($bottleneck.impact)")
        [void]$markdown.Add("  evidence: $([string]::Join('; ', @($bottleneck.evidence)))")
        [void]$markdown.Add("  recommendation: $($bottleneck.recommendation)")
    }
    [void]$markdown.Add("")
}

[void]$markdown.Add("## Skill Scores")
[void]$markdown.Add("")
[void]$markdown.Add("| Skill | Status | Score | Input | Logic | Error | Resource | Accuracy | Key Issues |")
[void]$markdown.Add("|---|---|---:|---:|---:|---:|---:|---:|---|")
foreach ($item in @($resultObject.skills | Sort-Object score, skill)) {
    $issueText = if ($item.issues.Count -gt 0) { [string]::Join(' / ', @($item.issues | Select-Object -First 2)) } else { "clean" }
    [void]$markdown.Add("| $($item.skill) | $($item.status) | $($item.score) | $($item.dimensions.input_validation.score) | $($item.dimensions.logic_flow.score) | $($item.dimensions.error_handling.score) | $($item.dimensions.resource_efficiency.score) | $($item.dimensions.accuracy_and_runtime.score) | $issueText |")
}
[void]$markdown.Add("")
[void]$markdown.Add("## Monitoring Signals")
[void]$markdown.Add("")
[void]$markdown.Add('- Run audit: `pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_codex_skills.ps1`')
[void]$markdown.Add('- Capture MCP runtime snapshot: `pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1`')
[void]$markdown.Add('- Run workflow health analysis: `pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\analyze_codex_skill_workflows.ps1`')
[void]$markdown.Add('- Recheck governance freshness: `pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly -Strict`')

Write-Utf8NoBom -FilePath $outputMdPath -Text ([string]::Join("`r`n", $markdown))

Write-Output "=== Codex Skills Workflow Health ==="
Write-Output "Status: $($resultObject.status)"
Write-Output "Average Score: $($resultObject.summary.average_score)"
Write-Output "Monitoring Ready: $($resultObject.summary.monitoring_ready)"
Write-Output "Skills Over 4000 Chars: $(if ($highContextSkills.Count -gt 0) { [string]::Join(', ', $highContextSkills) } else { 'none' })"
Write-Output "Runtime Dependency Warnings: $($dependencyRiskSkills.Count)"
Write-Output "Legacy Alias Missing: $($legacySkillCoverageMissing.Count)"
Write-Output "JSON Report: $outputJsonPath"
Write-Output "Markdown Report: $outputMdPath"

if ($resultObject.status -eq "FAIL") {
    exit 1
}

exit 0

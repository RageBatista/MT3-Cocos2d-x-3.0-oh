param(
    [string]$ProjectRoot = "",
    [string]$ConfigPath = "",
    [switch]$Apply,
    [string]$ProposalJsonPath = "",
    [string[]]$RuleIds = @(),
    [switch]$Force
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
    Write-Output "evolution_backfill: disabled by config"
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

function Get-LineEnding {
    param([string]$Text)
    if ($Text.Contains("`r`n")) { return "`r`n" }
    return "`n"
}

function Get-TargetSkills {
    param([string]$Signal)
    if ($Signal -match '^log\.pattern::LNK$') {
        return @("build-troubleshooting", "windows-build", "dependency-management")
    }
    if ($Signal -match '^log\.pattern::MSB$') {
        return @("build-troubleshooting", "windows-build", "android-build", "ant-build")
    }
    if ($Signal -match '^log\.pattern::error') {
        return @("build-troubleshooting", "debugging")
    }
    if ($Signal -match '^log\.pattern::Exception$') {
        return @("debugging", "build-troubleshooting")
    }
    if ($Signal -match '^git\.topic::build$') {
        return @("build-troubleshooting", "windows-build", "android-build", "ant-build")
    }
    if ($Signal -match '^git\.topic::claude-config$') {
        return @("continuous-learning-v2", "project-context")
    }
    if ($Signal -match '^git\.hotfile::') {
        return @("git-workflow", "debugging")
    }
    return @("continuous-learning-v2")
}

function Build-ProposalLine {
    param([object]$Rule)
    $signal = [string]$Rule.signal
    $ruleId = [string]$Rule.id
    $confidence = [string]$Rule.confidence
    $action = [string]$Rule.recommended_action
    $action = $action.Replace("`r", " ").Replace("`n", " ").Trim()
    return ("- [{0}] signal='{1}' confidence={2} action={3}" -f $ruleId, $signal, $confidence, $action)
}

$configDir = Split-Path -Parent $ConfigPath
$skillsManifestPath = Join-Path $configDir "skills.manifest.json"
if (-not (Test-Path $skillsManifestPath)) {
    throw "Missing skills manifest: $skillsManifestPath"
}
$skillsManifest = Get-Content -Raw -Encoding UTF8 $skillsManifestPath | ConvertFrom-Json

$skillFileMap = @{}
foreach ($skill in @($skillsManifest.skills)) {
    $sid = [string]$skill.id
    if ([string]::IsNullOrWhiteSpace($sid)) { continue }
    $skillFileMap[$sid] = Resolve-PathSafe -Base $configDir -Relative ([string]$skill.file)
}

$instinctsPath = Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.instincts_file)
$proposalJsonOutput = if ([string]::IsNullOrWhiteSpace($ProposalJsonPath)) {
    Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.backfill_proposals_file)
} else {
    Resolve-PathSafe -Base $ProjectRoot -Relative $ProposalJsonPath
}
$proposalMdOutput = Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.backfill_summary_file)
$applyLogOutput = Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.backfill_apply_log_file)

if (-not $Apply) {
    if (-not (Test-Path $instinctsPath)) {
        Write-Output "No instincts file found: $instinctsPath"
        exit 0
    }

    $instincts = Get-Content -Raw -Encoding UTF8 $instinctsPath | ConvertFrom-Json
    $rules = @($instincts.rules)
    $items = @()

    foreach ($rule in $rules) {
        $signal = [string]$rule.signal
        $targets = @(Get-TargetSkills -Signal $signal | Where-Object { $skillFileMap.ContainsKey($_) } | Select-Object -Unique)
        if ($targets.Count -eq 0 -and $skillFileMap.ContainsKey("continuous-learning-v2")) {
            $targets = @("continuous-learning-v2")
        }
        if ($targets.Count -eq 0) { continue }

        $targetFiles = @()
        foreach ($sid in $targets) {
            $targetFiles += $skillFileMap[$sid]
        }

        $items += [PSCustomObject]@{
            rule_id = [string]$rule.id
            signal = $signal
            confidence = [double]$rule.confidence
            recommended_action = [string]$rule.recommended_action
            target_skills = $targets
            target_files = $targetFiles
            proposal_line = Build-ProposalLine -Rule $rule
            status = "proposed"
        }
    }

    $proposal = [PSCustomObject]@{
        generated_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        mode = "propose"
        source_instincts = $instinctsPath
        item_count = $items.Count
        items = $items
    }
    Write-Utf8NoBom -Path $proposalJsonOutput -Content ($proposal | ConvertTo-Json -Depth 20)

    $md = @()
    $md += "# Skill Backfill Proposals"
    $md += ""
    $md += "- Time: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
    $md += "- Source instincts: $instinctsPath"
    $md += "- Proposal count: $($items.Count)"
    $md += ""

    $skillBuckets = @{}
    foreach ($item in $items) {
        foreach ($sid in @($item.target_skills)) {
            if (-not $skillBuckets.ContainsKey($sid)) {
                $skillBuckets[$sid] = New-Object System.Collections.Generic.List[object]
            }
            $skillBuckets[$sid].Add($item) | Out-Null
        }
    }

    foreach ($sid in ($skillBuckets.Keys | Sort-Object)) {
        $md += "## Skill: $sid"
        $md += ""
        $md += "- File: $($skillFileMap[$sid])"
        foreach ($item in @($skillBuckets[$sid])) {
            $md += $item.proposal_line
        }
        $md += ""
    }

    Write-Utf8NoBom -Path $proposalMdOutput -Content ([string]::Join("`n", $md))

    Write-Output "=== Evolution Backfill (Propose) ==="
    Write-Output "Proposals: $($items.Count)"
    Write-Output "JSON: $proposalJsonOutput"
    Write-Output "Summary: $proposalMdOutput"
    exit 0
}

# Apply mode
if ([string]::IsNullOrWhiteSpace($ProposalJsonPath) -and [string]::IsNullOrWhiteSpace([string]$config.storage.backfill_proposals_file)) {
    throw "Proposal path is required in apply mode."
}
if (-not (Test-Path $proposalJsonOutput)) {
    throw "Proposal file not found: $proposalJsonOutput"
}

if ($RuleIds.Count -eq 0 -and -not $Force) {
    throw "Apply mode requires -RuleIds or -Force."
}

$proposalDoc = Get-Content -Raw -Encoding UTF8 $proposalJsonOutput | ConvertFrom-Json
$proposalItems = @($proposalDoc.items)
if ($RuleIds.Count -gt 0) {
    $ruleSet = @{}
    foreach ($id in $RuleIds) { $ruleSet[$id] = $true }
    $proposalItems = @($proposalItems | Where-Object { $ruleSet.ContainsKey([string]$_.rule_id) })
}
if ($proposalItems.Count -eq 0) {
    Write-Output "No proposal items selected for apply."
    exit 0
}

$fileLines = @{}
foreach ($item in $proposalItems) {
    foreach ($file in @($item.target_files)) {
        $path = [string]$file
        if (-not (Test-Path $path)) { continue }
        if (-not $fileLines.ContainsKey($path)) {
            $fileLines[$path] = New-Object System.Collections.Generic.List[string]
        }
        $fileLines[$path].Add([string]$item.proposal_line) | Out-Null
    }
}

$startMarker = "<!-- AUTO_LEARNED_INSTINCTS_START -->"
$endMarker = "<!-- AUTO_LEARNED_INSTINCTS_END -->"
$appliedFiles = New-Object System.Collections.Generic.List[string]

foreach ($path in $fileLines.Keys) {
    $content = Get-Content -Raw -Encoding UTF8 $path
    $eol = Get-LineEnding -Text $content

    $uniqueLines = @($fileLines[$path] | Select-Object -Unique)
    $block = @()
    $block += "## Auto-Learned Instincts"
    $block += $startMarker
    $block += $uniqueLines
    $block += $endMarker
    $blockText = [string]::Join($eol, $block)

    $newContent = ""
    if ($content.Contains($startMarker) -and $content.Contains($endMarker)) {
        $startIndex = $content.IndexOf($startMarker)
        $endIndex = $content.IndexOf($endMarker, $startIndex)
        if ($startIndex -lt 0 -or $endIndex -lt 0) {
            $trimmed = $content.TrimEnd("`r", "`n")
            $newContent = $trimmed + $eol + $eol + $blockText + $eol
        } else {
            $endIndex += $endMarker.Length
            $replacement = $startMarker + $eol + [string]::Join($eol, $uniqueLines) + $eol + $endMarker
            $newContent = $content.Substring(0, $startIndex) + $replacement + $content.Substring($endIndex)
        }
    } else {
        $trimmed = $content.TrimEnd("`r", "`n")
        $newContent = $trimmed + $eol + $eol + $blockText + $eol
    }

    Write-Utf8NoBom -Path $path -Content $newContent
    $appliedFiles.Add($path) | Out-Null
}

$applyLog = @()
$applyLog += "# Backfill Apply Report"
$applyLog += ""
$applyLog += "- Time: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
$applyLog += "- Proposal file: $proposalJsonOutput"
$applyLog += "- Applied rules: $($proposalItems.Count)"
$applyLog += "- Updated files: $($appliedFiles.Count)"
$applyLog += ""
foreach ($f in @($appliedFiles | Sort-Object)) {
    $applyLog += "- $f"
}
Write-Utf8NoBom -Path $applyLogOutput -Content ([string]::Join("`n", $applyLog))

Write-Output "=== Evolution Backfill (Apply) ==="
Write-Output "Applied rules: $($proposalItems.Count)"
Write-Output "Updated files: $($appliedFiles.Count)"
Write-Output "Apply report: $applyLogOutput"

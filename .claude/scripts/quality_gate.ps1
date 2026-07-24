param(
    [string]$TargetPath = ".",
    [switch]$ChangedOnly,
    [switch]$Strict,
    [switch]$NonBlocking
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$claudeRoot = Join-Path $repoRoot ".claude"
$auditReportPath = Join-Path $claudeRoot "reports\claude-config-audit.json"
$sidecarValidationReportPath = Join-Path $claudeRoot "reports\codex-sidecars-validation.json"
$guardrailAuditReportPath = Join-Path $claudeRoot "reports\codex-guardrails-audit.json"
$skillsAuditReportPath = Join-Path $claudeRoot "reports\codex-skills-audit.json"
$skillsWorkflowHealthReportPath = Join-Path $claudeRoot "reports\codex-skills-workflow-health.json"
$qualityGateReportPath = Join-Path $claudeRoot "reports\quality-gate-report.json"

if (-not $PSBoundParameters.ContainsKey("ChangedOnly") -and $TargetPath -eq ".") {
    $ChangedOnly = $true
}

$cppSourceExtensions = @(".cpp", ".c", ".h", ".hpp")
$bomRequiredResourceExtensions = @(".rc")
$noBomExtensions = @(".lua", ".java", ".md", ".xml", ".json", ".txt", ".toml", ".rules", ".ps1", ".cmd", ".bat", ".sh", ".pkg", ".yml", ".yaml")

function Resolve-RepoPath {
    param([string]$PathText)
    if ([string]::IsNullOrWhiteSpace($PathText)) {
        return $null
    }
    if ([System.IO.Path]::IsPathRooted($PathText)) {
        return [System.IO.Path]::GetFullPath($PathText)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $PathText))
}

function Get-BomKind {
    param([byte[]]$Bytes)
    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 239 -and $Bytes[1] -eq 187 -and $Bytes[2] -eq 191) {
        return "utf8-bom"
    }
    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 255 -and $Bytes[1] -eq 254) {
        return "utf16le-bom"
    }
    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 254 -and $Bytes[1] -eq 255) {
        return "utf16be-bom"
    }
    return "no-bom"
}

function Get-RelativeRepoPath {
    param([string]$AbsolutePath)
    $rootWithSlash = $repoRoot.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
    $rootUri = New-Object System.Uri($rootWithSlash)
    $pathUri = New-Object System.Uri($AbsolutePath)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace("\", "/")
}

function Test-IsGeneratedPath {
    param([string]$RelativePath)
    return (
        $RelativePath -match "(?i)^server/.+/xbean/.+\.java$" -or
        $RelativePath -match "(?i)^server/.+/rpc/.+\.java$" -or
        $RelativePath -match "(?i)^client/.+/tolua\+\+/.+\.cpp$" -or
        $RelativePath -match "(?i).+_tolua\.cpp$" -or
        $RelativePath -match "(?i)^client/FireClient/Application/ProtoDef/rpcgen/.+\.(hpp|cpp)$" -or
        $RelativePath -match "(?i)^client/FireClient/Application/ProtoDef/fire/pb/.+\.(hpp|cpp)$" -or
        $RelativePath -match "(?i)^client/FireClient/Application/ProtoDef/(rpcgen|protocols)\.(hpp|cpp)$"
    )
}

function Get-EncodingRequirement {
    param(
        [string]$RelativePath,
        [string]$Extension
    )

    if ($noBomExtensions -contains $Extension) {
        return "utf8-no-bom"
    }

    if ($bomRequiredResourceExtensions -contains $Extension) {
        return "resource-bom"
    }

    if ($cppSourceExtensions -contains $Extension) {
        if ($RelativePath -match "(?i)^client/FireClient/Application/" -or $RelativePath -match "(?i)^engine/") {
            return "utf8-bom"
        }
        if (
            $RelativePath -match "(?i)^client/MT3Win32App/" -or
            $RelativePath -match "(?i)^cocos2d-2\.0-rc2-x-2\.0\.1/" -or
            $RelativePath -match "(?i)^dependencies/"
        ) {
            return "preserve-existing"
        }
        return "preserve-existing"
    }

    return "ignore"
}

function Test-ReportFreshness {
    param(
        [string[]]$SourceFiles,
        [string]$ReportPath,
        [string]$DisplayName
    )

    if ($SourceFiles.Count -eq 0) {
        return $null
    }

    if (-not (Test-Path $ReportPath -PathType Leaf)) {
        return "缺少报告: $DisplayName"
    }

    $latestChangedTime = $null
    foreach ($path in $SourceFiles) {
        if (-not (Test-Path $path -PathType Leaf)) {
            continue
        }
        $changedTime = (Get-Item $path).LastWriteTimeUtc
        if ($null -eq $latestChangedTime -or $changedTime -gt $latestChangedTime) {
            $latestChangedTime = $changedTime
        }
    }

    if ($null -eq $latestChangedTime) {
        return $null
    }

    $reportTime = (Get-Item $ReportPath).LastWriteTimeUtc
    if ($reportTime.AddSeconds(2) -lt $latestChangedTime) {
        return "检测到治理配置变更时间晚于最近报告，请重新执行 $DisplayName"
    }

    return $null
}

function Get-ChangedFiles {
    param([string]$Scope)
    $gitArgs = @("-C", $repoRoot, "status", "--porcelain=v1", "--untracked-files=all", "--", $Scope)
    $statusLines = & git @gitArgs 2>$null
    $results = New-Object System.Collections.Generic.List[string]

    foreach ($line in @($statusLines)) {
        $entry = [string]$line
        if ([string]::IsNullOrWhiteSpace($entry) -or $entry.Length -lt 4) {
            continue
        }

        $pathText = $entry.Substring(3).Trim()
        if ($pathText -match "\s->\s") {
            $pathText = ($pathText -split "\s->\s")[-1]
        }
        $pathText = $pathText.Trim('"')
        if ([string]::IsNullOrWhiteSpace($pathText)) {
            continue
        }

        $absolutePath = Resolve-RepoPath -PathText $pathText
        if ($null -eq $absolutePath -or -not (Test-Path $absolutePath -PathType Leaf)) {
            continue
        }

        [void]$results.Add($absolutePath)
    }

    return @($results | Sort-Object -Unique)
}

function Get-TargetFiles {
    param([string]$Scope)
    $resolvedTarget = Resolve-RepoPath -PathText $Scope
    if ($null -eq $resolvedTarget -or -not (Test-Path $resolvedTarget)) {
        return @()
    }

    if (Test-Path $resolvedTarget -PathType Leaf) {
        return @($resolvedTarget)
    }

    return @(Get-ChildItem -Path $resolvedTarget -Recurse -File | Select-Object -ExpandProperty FullName)
}

$rawDiscoveredFiles = if ($ChangedOnly) { Get-ChangedFiles -Scope $TargetPath } else { Get-TargetFiles -Scope $TargetPath }
$discoveredFiles = @($rawDiscoveredFiles | Sort-Object -Unique)
$candidateFileList = New-Object System.Collections.Generic.List[string]
$skipReasonCounts = [ordered]@{
    excluded_governance_output = 0
    missing_file = 0
    preserve_existing_encoding = 0
    unsupported_extension = 0
}
foreach ($file in $discoveredFiles) {
    $relative = Get-RelativeRepoPath -AbsolutePath $file
    if (
        $relative -like ".claude/reports/*" -or
        $relative -like ".claude/evolution/*" -or
        $relative -like ".claude/indexes/*"
    ) {
        $skipReasonCounts.excluded_governance_output++
        continue
    }
    [void]$candidateFileList.Add($file)
}
$candidateFiles = @($candidateFileList.ToArray() | Sort-Object -Unique)

$violations = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$inspectedFiles = 0
$claudeTouched = New-Object System.Collections.Generic.List[string]
$codexTouched = New-Object System.Collections.Generic.List[string]
$agentsTouched = New-Object System.Collections.Generic.List[string]

foreach ($file in $candidateFiles) {
    if (-not (Test-Path $file -PathType Leaf)) {
        $skipReasonCounts.missing_file++
        continue
    }

    $relativePath = Get-RelativeRepoPath -AbsolutePath $file
    $extension = [System.IO.Path]::GetExtension($file).ToLowerInvariant()

    if ($relativePath -like ".claude/*") {
        [void]$claudeTouched.Add($file)
    }
    if ($relativePath -like ".codex/*") {
        [void]$codexTouched.Add($file)
    }
    if ($relativePath -like ".agents/*") {
        [void]$agentsTouched.Add($file)
    }

    if (Test-IsGeneratedPath -RelativePath $relativePath) {
        [void]$warnings.Add("触碰生成代码路径: $relativePath")
    }

    $encodingRequirement = Get-EncodingRequirement -RelativePath $relativePath -Extension $extension
    if ($encodingRequirement -eq "preserve-existing") {
        $skipReasonCounts.preserve_existing_encoding++
        continue
    }
    if ($encodingRequirement -eq "ignore") {
        $skipReasonCounts.unsupported_extension++
        continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($file)
    $bomKind = Get-BomKind -Bytes $bytes
    $inspectedFiles++

    if ($encodingRequirement -eq "utf8-bom" -and $bomKind -ne "utf8-bom") {
        [void]$violations.Add("编码不符合要求: $relativePath 需要 UTF-8 BOM，当前为 $bomKind")
        continue
    }

    if ($encodingRequirement -eq "resource-bom" -and $bomKind -notin @("utf8-bom", "utf16le-bom")) {
        [void]$violations.Add("资源文件 BOM 异常: $relativePath 需要 UTF-8 BOM 或 UTF-16 LE BOM，当前为 $bomKind")
        continue
    }

    if ($encodingRequirement -eq "utf8-no-bom" -and $bomKind -ne "no-bom") {
        [void]$violations.Add("编码不符合要求: $relativePath 不应包含 BOM，当前为 $bomKind")
    }
}

$signalClaudeFiles = @($claudeTouched | Where-Object {
    $relative = Get-RelativeRepoPath -AbsolutePath $_
    $relative -notlike ".claude/reports/*"
})

if ($signalClaudeFiles.Count -gt 0) {
    $freshnessWarning = Test-ReportFreshness -SourceFiles $signalClaudeFiles -ReportPath $auditReportPath -DisplayName ".claude/reports/claude-config-audit.json"
    if (-not [string]::IsNullOrWhiteSpace($freshnessWarning)) {
        [void]$warnings.Add($freshnessWarning)
    }
}

$signalCodexFiles = @($codexTouched)
$signalAgentFiles = @($agentsTouched)
$signalRuntimeFiles = @($signalCodexFiles + $signalAgentFiles | Sort-Object -Unique)
if ($signalRuntimeFiles.Count -gt 0) {
    foreach ($report in @(
        [ordered]@{ path = $sidecarValidationReportPath; name = ".claude/reports/codex-sidecars-validation.json" },
        [ordered]@{ path = $guardrailAuditReportPath; name = ".claude/reports/codex-guardrails-audit.json" }
    )) {
        $freshnessWarning = Test-ReportFreshness -SourceFiles $signalRuntimeFiles -ReportPath ([string]$report.path) -DisplayName ([string]$report.name)
        if (-not [string]::IsNullOrWhiteSpace($freshnessWarning)) {
            [void]$warnings.Add($freshnessWarning)
        }
    }
}

if ($signalAgentFiles.Count -gt 0) {
    foreach ($report in @(
        [ordered]@{ path = $skillsAuditReportPath; name = ".claude/reports/codex-skills-audit.json" },
        [ordered]@{ path = $skillsWorkflowHealthReportPath; name = ".claude/reports/codex-skills-workflow-health.json" }
    )) {
        $freshnessWarning = Test-ReportFreshness -SourceFiles $signalAgentFiles -ReportPath ([string]$report.path) -DisplayName ([string]$report.name)
        if (-not [string]::IsNullOrWhiteSpace($freshnessWarning)) {
            [void]$warnings.Add($freshnessWarning)
        }
    }
}

$status = "PASS"
if ($violations.Count -gt 0) {
    $status = "FAIL"
} elseif ($warnings.Count -gt 0) {
    $status = if ($Strict) { "FAIL" } else { "WARN" }
}

$lines = New-Object System.Collections.Generic.List[string]
$skippedFiles = 0
foreach ($reason in $skipReasonCounts.Keys) {
    $skippedFiles += [int]$skipReasonCounts[$reason]
}
$managedExtensions = @($cppSourceExtensions + $bomRequiredResourceExtensions + $noBomExtensions | Sort-Object -Unique)
[void]$lines.Add("QUALITY GATE: $status")
[void]$lines.Add("- Target: $TargetPath")
[void]$lines.Add("- Mode: $(if ($ChangedOnly) { 'changed-only' } else { 'full-scan' })")
[void]$lines.Add("- Discovered Files: $($discoveredFiles.Count)")
[void]$lines.Add("- Candidate Files: $($candidateFiles.Count)")
[void]$lines.Add("- Checked Files: $inspectedFiles")
[void]$lines.Add("- Skipped Files: $skippedFiles")
[void]$lines.Add("- Skip Reasons: $((@($skipReasonCounts.Keys | ForEach-Object { $_ + '=' + $skipReasonCounts[$_] })) -join ', ')")
[void]$lines.Add("- Violations: $($violations.Count)")
[void]$lines.Add("- Warnings: $($warnings.Count)")

if ($violations.Count -gt 0) {
    [void]$lines.Add("## Violations")
    foreach ($item in $violations) {
        [void]$lines.Add("- $item")
    }
}

if ($warnings.Count -gt 0) {
    [void]$lines.Add("## Warnings")
    foreach ($item in $warnings) {
        [void]$lines.Add("- $item")
    }
}

if ($violations.Count -gt 0 -or $warnings.Count -gt 0) {
    [void]$lines.Add("## Recommended Commands")
    [void]$lines.Add("- pwsh.exe -NoLogo -NoProfile -File .\\.claude\\scripts\\audit_claude_config.ps1")
    [void]$lines.Add("- pwsh.exe -NoLogo -NoProfile -File .\\.claude\\scripts\\validate_codex_sidecars.ps1")
    [void]$lines.Add("- pwsh.exe -NoLogo -NoProfile -File .\\.claude\\scripts\\audit_codex_guardrails.ps1")
    [void]$lines.Add("- pwsh.exe -NoLogo -NoProfile -File .\\.claude\\scripts\\audit_codex_skills.ps1")
    [void]$lines.Add("- pwsh.exe -NoLogo -NoProfile -File .\\.claude\\scripts\\analyze_codex_skill_workflows.ps1")
    [void]$lines.Add("- pwsh.exe -NoLogo -NoProfile -File .\\.claude\\scripts\\quality_gate.ps1 -ChangedOnly -Strict")
}

Write-Output ([string]::Join([Environment]::NewLine, $lines))

$qualityGateReport = [ordered]@{
    schema_version = "1.0.0"
    generated_at = [DateTime]::UtcNow.ToString("o")
    overall_status = $status.ToLowerInvariant()
    target = $TargetPath
    mode = if ($ChangedOnly) { "changed-only" } else { "full-scan" }
    discovered_files = $discoveredFiles.Count
    candidate_files = $candidateFiles.Count
    checked_files = $inspectedFiles
    inspected_files = $inspectedFiles
    skipped_files = $skippedFiles
    skipped_by_reason = [pscustomobject]$skipReasonCounts
    checked_extensions = $managedExtensions
    violations = @($violations)
    warnings = @($warnings)
}

$qualityGateReportJson = $qualityGateReport | ConvertTo-Json -Depth 6
[System.IO.Directory]::CreateDirectory((Split-Path -Parent $qualityGateReportPath)) | Out-Null
[System.IO.File]::WriteAllText($qualityGateReportPath, $qualityGateReportJson, $utf8NoBom)

if ($NonBlocking) {
    exit 0
}

if ($violations.Count -gt 0 -or ($Strict -and $warnings.Count -gt 0)) {
    exit 1
}

exit 0

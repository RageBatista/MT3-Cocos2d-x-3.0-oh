[CmdletBinding()]
param(
    [string]$RepoRoot = '',
    [string]$ReportPath = 'build_logs\resource-ui-gate.json',
    [string]$BaselinePath = 'tools\scripts\baselines\resource-ui-gate-baseline.json',
    [switch]$GenerateBaseline,
    [switch]$Json
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$scriptDir = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { $PSScriptRoot }

function Resolve-FullPath {
    param([string]$PathValue, [string]$BaseDirectory)
    if ([string]::IsNullOrWhiteSpace($PathValue)) { return '' }
    if ([System.IO.Path]::IsPathRooted($PathValue)) { return [System.IO.Path]::GetFullPath($PathValue) }
    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $PathValue))
}

function Read-JsonFile {
    param([string]$PathValue, [string]$Kind)
    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $PathValue
    if ($text -match '^version https://git-lfs.github.com/spec/v1') {
        throw ("{0} is a Git LFS pointer, not JSON: {1}" -f $Kind, $PathValue)
    }
    try {
        return $text | ConvertFrom-Json
    }
    catch {
        throw ("{0} is not valid JSON: {1}: {2}" -f $Kind, $PathValue, $_.Exception.Message)
    }
}

function New-Sha256Hex {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Get-Severity {
    param([string]$Category)
    switch ($Category) {
        'unpacked_root_missing' { return 'P0' }
        'unpacked_key_path_missing' { return 'P0' }
        'unpacked_failed_items' { return 'P0' }
        'tooling_environment_error' { return 'P0' }
        'layout_xml_parse_error' { return 'P1' }
        'missing_imageset' { return 'P1' }
        'missing_font' { return 'P1' }
        'unmapped_window_type' { return 'P1' }
        'unpacked_missing_final_paths' { return 'P1' }
        'unpacked_review_unresolved' { return 'P1' }
        'orphan_getwindow' { return 'P2' }
        'missing_lua_event_handler' { return 'P2' }
        'imageset_not_declared_in_scheme' { return 'P3' }
        'font_not_declared_in_scheme' { return 'P3' }
        default { return 'P3' }
    }
}

function Test-BlockingSeverity {
    param([string]$Severity)
    return @('P0', 'P1', 'P2') -contains $Severity
}

function New-Issue {
    param(
        [string]$Gate,
        [string]$Category,
        [string]$Message,
        [string]$Layout = '',
        [string]$Resource = '',
        [string]$WindowType = '',
        [string]$LuaSymbol = '',
        [string]$SourceRef = '',
        [int]$Count = 0,
        [bool]$BaselineEligible = $true
    )
    $severity = Get-Severity -Category $Category
    $key = (@($Gate, $Category, $Layout, $Resource, $WindowType, $LuaSymbol, $SourceRef) | ForEach-Object { if ($null -eq $_) { '' } else { [string]$_ } }) -join '|'
    return [pscustomobject][ordered]@{
        id = New-Sha256Hex -Text $key
        gate = $Gate
        category = $Category
        severity = $severity
        status = 'current'
        baseline_eligible = $BaselineEligible
        layout = $Layout
        resource = $Resource
        window_type = $WindowType
        lua_symbol = $LuaSymbol
        source_ref = $SourceRef
        count = $Count
        message = $Message
    }
}

function Convert-CeguiMessageToIssue {
    param([string]$Gate, [string]$Message, [bool]$IsWarning)
    $layout = ''
    $body = $Message
    $category = if ($IsWarning) { 'cegui_warning' } else { 'cegui_failure' }
    $resource = ''
    $windowType = ''
    $luaSymbol = ''
    $sourceRef = ''

    if ($Message -match '^([^:]+\.layout)\s*:\s*(.+)$') {
        $layout = $matches[1].Trim()
        $body = $matches[2].Trim()
    }
    elseif ($Message -match '^deep_scan\s*:\s*(.+)$') {
        $body = $matches[1].Trim()
    }

    if ($body -match '^missing imageset file for ref:\s*(.+)$') {
        $category = 'missing_imageset'
        $resource = ($matches[1].Trim() + '.imageset')
    }
    elseif ($body -match "^imageset '([^']+\.imageset)' not found") {
        $category = 'missing_imageset'
        $resource = $matches[1].Trim()
    }
    elseif ($body -match '^missing font file for ref:\s*(.+)$') {
        $category = 'missing_font'
        $resource = ($matches[1].Trim() + '.font')
    }
    elseif ($body -match "^font '([^']+\.font)' not found") {
        $category = 'missing_font'
        $resource = $matches[1].Trim()
    }
    elseif ($body -match '^unmapped window type:\s*(.+)$') {
        $category = 'unmapped_window_type'
        $windowType = $matches[1].Trim()
    }
    elseif ($body -match "^type '([^']+)' not mapped in any scheme") {
        $category = 'unmapped_window_type'
        $windowType = $matches[1].Trim()
    }
    elseif ($body -match 'XML parse error' -or $body -match 'layout xml parse failed') {
        $category = 'layout_xml_parse_error'
    }
    elseif ($body -match "Lua getWindow\('([^']+)'\) not found") {
        $category = 'orphan_getwindow'
        $luaSymbol = $matches[1].Trim()
        if ($body -match '\(ref:\s*([^\)]+)\)') { $sourceRef = $matches[1].Trim() }
    }
    elseif ($body -match "LuaEventOnClicked handler '([^']+)' not found") {
        $category = 'missing_lua_event_handler'
        $luaSymbol = $matches[1].Trim()
    }
    elseif ($body -match '^imageset not declared in scheme:\s*(.+)$') {
        $category = 'imageset_not_declared_in_scheme'
        $resource = ($matches[1].Trim() + '.imageset')
    }
    elseif ($body -match '^font not declared in scheme:\s*(.+)$') {
        $category = 'font_not_declared_in_scheme'
        $resource = ($matches[1].Trim() + '.font')
    }

    return New-Issue -Gate $Gate -Category $category -Message $Message -Layout $layout -Resource $resource -WindowType $windowType -LuaSymbol $luaSymbol -SourceRef $sourceRef -BaselineEligible $true
}

function Add-Issue {
    param([System.Collections.Generic.List[object]]$Issues, [object]$Issue)
    if ($null -ne $Issue) { $Issues.Add($Issue) | Out-Null }
}

function Get-IssueSummary {
    param([object[]]$Issues)
    $bySeverity = [ordered]@{}
    $byCategory = [ordered]@{}
    $byGate = [ordered]@{}
    foreach ($issue in @($Issues)) {
        foreach ($pair in @(
            @($bySeverity, [string]$issue.severity),
            @($byCategory, [string]$issue.category),
            @($byGate, [string]$issue.gate)
        )) {
            if (-not $pair[0].Contains($pair[1])) { $pair[0][$pair[1]] = 0 }
            $pair[0][$pair[1]]++
        }
    }
    return [pscustomobject][ordered]@{
        total = @($Issues).Count
        by_severity = $bySeverity
        by_category = $byCategory
        by_gate = $byGate
    }
}

$resolvedRepoRoot = if ([string]::IsNullOrWhiteSpace($RepoRoot)) { [System.IO.Path]::GetFullPath((Join-Path $scriptDir '..\..')) } else { Resolve-FullPath -PathValue $RepoRoot -BaseDirectory (Get-Location).Path }
$resolvedReportPath = Resolve-FullPath -PathValue $ReportPath -BaseDirectory $resolvedRepoRoot
$resolvedBaselinePath = Resolve-FullPath -PathValue $BaselinePath -BaseDirectory $resolvedRepoRoot

if (-not (Test-Path -LiteralPath $resolvedReportPath)) {
    throw "Resource/UI gate report not found: $resolvedReportPath"
}

$report = Read-JsonFile -PathValue $resolvedReportPath -Kind 'resource-ui report'
$issues = New-Object System.Collections.Generic.List[object]

foreach ($check in @($report.checks)) {
    $gate = [string]$check.name
    if ($gate -eq 'unpacked_resources') {
        $summary = [string]$check.summary
        if ($summary -match 'Unpacked root not found') {
            Add-Issue -Issues $issues -Issue (New-Issue -Gate $gate -Category 'unpacked_root_missing' -Message $summary -BaselineEligible $false)
        }
        elseif ($null -ne $check.data) {
            $data = $check.data
            if ($data.counts.failed_items -gt 0) {
                Add-Issue -Issues $issues -Issue (New-Issue -Gate $gate -Category 'unpacked_failed_items' -Message ("failed_items={0}" -f $data.counts.failed_items) -Count ([int]$data.counts.failed_items) -BaselineEligible $false)
            }
            if ($data.manifest.missing_final_path_count -gt 0) {
                $samples = (@($data.manifest.missing_final_paths) | Select-Object -First 5) -join '; '
                Add-Issue -Issues $issues -Issue (New-Issue -Gate $gate -Category 'unpacked_missing_final_paths' -Message ("missing_final_path_count={0}; samples={1}" -f $data.manifest.missing_final_path_count, $samples) -Count ([int]$data.manifest.missing_final_path_count) -BaselineEligible $true)
            }
            if ($data.counts.review_unresolved_files -gt 0) {
                Add-Issue -Issues $issues -Issue (New-Issue -Gate $gate -Category 'unpacked_review_unresolved' -Message ("review_unresolved_files={0}" -f $data.counts.review_unresolved_files) -Count ([int]$data.counts.review_unresolved_files) -BaselineEligible $true)
            }
            foreach ($prop in @($data.key_path_checks.PSObject.Properties)) {
                if ($prop.Value -ne $true) {
                    Add-Issue -Issues $issues -Issue (New-Issue -Gate $gate -Category 'unpacked_key_path_missing' -Message ("required key path missing: {0}" -f $prop.Name) -SourceRef $prop.Name -BaselineEligible $false)
                }
            }
        }
    }
    elseif ($gate -eq 'cegui_bindings' -or $gate -eq 'cegui_resources') {
        $extractedCount = 0
        if ($null -ne $check.data -and $null -ne $check.data.data) {
            foreach ($failure in @($check.data.data.failures)) {
                Add-Issue -Issues $issues -Issue (Convert-CeguiMessageToIssue -Gate $gate -Message ([string]$failure) -IsWarning $false)
                $extractedCount++
            }
            foreach ($warning in @($check.data.data.warnings)) {
                Add-Issue -Issues $issues -Issue (Convert-CeguiMessageToIssue -Gate $gate -Message ([string]$warning) -IsWarning $true)
                $extractedCount++
            }
        }
        if ($check.status -eq 'FAIL' -and $extractedCount -eq 0) {
            Add-Issue -Issues $issues -Issue (New-Issue -Gate $gate -Category 'tooling_environment_error' -Message ([string]$check.summary) -BaselineEligible $false)
        }
    }
    elseif ($check.status -eq 'FAIL') {
        Add-Issue -Issues $issues -Issue (New-Issue -Gate $gate -Category 'tooling_environment_error' -Message ([string]$check.summary) -BaselineEligible $false)
    }
}

$issueArray = @($issues | Sort-Object id -Unique)
$eligibleIssues = @($issueArray | Where-Object { $_.baseline_eligible -eq $true })
$environmentIssues = @($issueArray | Where-Object { $_.baseline_eligible -ne $true })
$summary = Get-IssueSummary -Issues $issueArray

if ($GenerateBaseline) {
    $baselineDir = Split-Path -Parent $resolvedBaselinePath
    if ($baselineDir -and -not (Test-Path -LiteralPath $baselineDir)) {
        [System.IO.Directory]::CreateDirectory($baselineDir) | Out-Null
    }
    $baselinePayload = [ordered]@{
        schema_version = 1
        generated_at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        repo_root = $resolvedRepoRoot
        source_report = $resolvedReportPath
        summary = Get-IssueSummary -Issues $eligibleIssues
        issues = @($eligibleIssues | ForEach-Object {
            [pscustomobject][ordered]@{
                id = $_.id
                gate = $_.gate
                category = $_.category
                severity = $_.severity
                status = 'baseline'
                layout = $_.layout
                resource = $_.resource
                window_type = $_.window_type
                lua_symbol = $_.lua_symbol
                source_ref = $_.source_ref
                count = $_.count
                message = $_.message
            }
        })
    }
    $baselineJson = ($baselinePayload | ConvertTo-Json -Depth 12) -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($resolvedBaselinePath, ($baselineJson + "`n"), $utf8NoBom)
}

$baselineMap = @{}
$baselineStatus = 'missing'
if (Test-Path -LiteralPath $resolvedBaselinePath) {
    $baselineStatus = if ($GenerateBaseline) { 'generated' } else { 'loaded' }
    $baseline = Read-JsonFile -PathValue $resolvedBaselinePath -Kind 'resource-ui baseline'
    foreach ($issue in @($baseline.issues)) { $baselineMap[[string]$issue.id] = $issue }
}

$newIssues = New-Object System.Collections.Generic.List[object]
$knownIssues = New-Object System.Collections.Generic.List[object]
$increasedIssues = New-Object System.Collections.Generic.List[object]
foreach ($issue in @($eligibleIssues)) {
    if ($baselineMap.ContainsKey([string]$issue.id)) {
        $knownIssues.Add($issue) | Out-Null
        $base = $baselineMap[[string]$issue.id]
        if ([int]$issue.count -gt 0 -and [int]$base.count -gt 0 -and [int]$issue.count -gt [int]$base.count) {
            $copy = $issue | Select-Object *
            $copy | Add-Member -NotePropertyName baseline_count -NotePropertyValue ([int]$base.count) -Force
            $increasedIssues.Add($copy) | Out-Null
        }
    }
    else {
        $newIssues.Add($issue) | Out-Null
    }
}

$currentMap = @{}
foreach ($issue in @($eligibleIssues)) { $currentMap[[string]$issue.id] = $issue }
$resolvedIssues = New-Object System.Collections.Generic.List[object]
foreach ($base in $baselineMap.Values) {
    if (-not $currentMap.ContainsKey([string]$base.id)) { $resolvedIssues.Add($base) | Out-Null }
}

$blockers = New-Object System.Collections.Generic.List[string]
foreach ($issue in @($environmentIssues | Where-Object { Test-BlockingSeverity -Severity $_.severity })) {
    $blockers.Add(("{0}/{1}/{2}: {3}" -f $issue.gate, $issue.severity, $issue.category, $issue.message)) | Out-Null
}
foreach ($issue in @($newIssues | Where-Object { Test-BlockingSeverity -Severity $_.severity })) {
    $blockers.Add(("new {0}/{1}/{2}: {3}" -f $issue.gate, $issue.severity, $issue.category, $issue.message)) | Out-Null
}
foreach ($issue in @($increasedIssues | Where-Object { Test-BlockingSeverity -Severity $_.severity })) {
    $blockers.Add(("increased {0}/{1}/{2}: count {3} > baseline {4}" -f $issue.gate, $issue.severity, $issue.category, $issue.count, $issue.baseline_count)) | Out-Null
}
$eligibleBlockingCount = ($eligibleIssues | Where-Object { Test-BlockingSeverity -Severity $_.severity } | Measure-Object).Count
if ($baselineStatus -eq 'missing' -and $eligibleBlockingCount -gt 0) {
    $blockers.Add(("resource-ui baseline missing: {0}. Review current issues, then rerun with -GenerateBaseline." -f $resolvedBaselinePath)) | Out-Null
}

$status = 'PASS'
if ($blockers.Count -gt 0) {
    $status = 'FAIL'
}
elseif ($summary.total -gt 0 -or $newIssues.Count -gt 0 -or $resolvedIssues.Count -gt 0) {
    $status = 'WARN'
}

$eligibleIssueCount = $eligibleIssues.Count
$knownIssueCount = $knownIssues.Count
$newIssueCount = $newIssues.Count
$increasedIssueCount = $increasedIssues.Count
$resolvedIssueCount = $resolvedIssues.Count
$environmentIssueCount = $environmentIssues.Count
$newIssueSamples = @($newIssues | Select-Object -First 100)
$increasedIssueSamples = @($increasedIssues | Select-Object -First 50)
$resolvedIssueSamples = @($resolvedIssues | Select-Object -First 100)

$payload = [ordered]@{
    generated_at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    status = $status
    report_path = $resolvedReportPath
    baseline_path = $resolvedBaselinePath
    baseline_status = $baselineStatus
    summary = $summary
    baseline_issue_count = $baselineMap.Count
    current_issue_count = $eligibleIssueCount
    known_issue_count = $knownIssueCount
    new_issue_count = $newIssueCount
    increased_issue_count = $increasedIssueCount
    resolved_issue_count = $resolvedIssueCount
    environment_issue_count = $environmentIssueCount
    blockers = @($blockers)
    new_issues = $newIssueSamples
    increased_issues = $increasedIssueSamples
    resolved_issues = $resolvedIssueSamples
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    Write-Host ("STATUS: {0}" -f $status)
    Write-Host ("BASELINE: {0} status={1} current={2} known={3} new={4} increased={5} resolved={6}" -f $resolvedBaselinePath, $baselineStatus, $eligibleIssueCount, $knownIssueCount, $newIssueCount, $increasedIssueCount, $resolvedIssueCount)
    foreach ($blocker in @($blockers)) { Write-Host ("BLOCKER: {0}" -f $blocker) }
}

if ($status -eq 'FAIL') { exit 1 }
exit 0

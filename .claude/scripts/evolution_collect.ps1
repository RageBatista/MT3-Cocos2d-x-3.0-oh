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
    Write-Output "evolution_collect: disabled by config"
    exit 0
}

function Resolve-PathSafe {
    param([string]$Base, [string]$Relative)
    if ([System.IO.Path]::IsPathRooted($Relative)) {
        return [System.IO.Path]::GetFullPath($Relative)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Base $Relative))
}

function New-Utf8NoBomWriter {
    param([string]$Path, [bool]$Append = $true)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $enc = New-Object System.Text.UTF8Encoding($false)
    return New-Object System.IO.StreamWriter($Path, $Append, $enc)
}

$configDir = Split-Path -Parent $ConfigPath
$observationsPath = Resolve-PathSafe -Base $configDir -Relative ([string]$config.storage.observations_file)
$runId = (Get-Date).ToString("yyyyMMdd-HHmmss")
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

$observations = New-Object System.Collections.Generic.List[object]

function Add-Observation {
    param(
        [string]$Source,
        [string]$Key,
        [double]$Value,
        [double]$Confidence,
        [hashtable]$Meta
    )
    $obs = [ordered]@{
        run_id = $runId
        timestamp = $now
        source = $Source
        key = $Key
        value = $Value
        confidence = $Confidence
        meta = $Meta
    }
    $observations.Add($obs) | Out-Null
}

# 1) Git 观测
$gitSource = $config.observation_sources.git
$sinceDays = [int]$gitSource.since_days
$maxCommits = [int]$gitSource.max_commits
$sinceDate = (Get-Date).AddDays(-$sinceDays).ToString("yyyy-MM-dd")
$gitPaths = @($gitSource.paths)

$commitLines = @()
try {
    $commitLines = & git -C $ProjectRoot log "--since=$sinceDate" "--pretty=format:%H`t%ad`t%s" "--date=iso" "--" @gitPaths
} catch {
    $commitLines = @()
}

if ($commitLines.Count -gt $maxCommits) {
    $commitLines = $commitLines | Select-Object -First $maxCommits
}

Add-Observation -Source "git" -Key "git.commit_count" -Value $commitLines.Count -Confidence 0.9 -Meta @{
    since = $sinceDate
    paths = ($gitPaths -join ",")
}

$topicMap = @{}
foreach ($line in $commitLines) {
    $parts = $line -split "`t", 3
    if ($parts.Count -lt 3) { continue }
    $subject = [string]$parts[2]
    $topic = "other"
    if ($subject -match "build|编译|msbuild|ndk|ant|link") { $topic = "build" }
    elseif ($subject -match "skill|规则|rule|workflow|claude|agent") { $topic = "claude-config" }
    elseif ($subject -match "fix|bug|修复|回归|regression") { $topic = "bugfix" }
    elseif ($subject -match "性能|performance|fps|优化") { $topic = "performance" }
    elseif ($subject -match "文档|docs|readme|guide") { $topic = "docs" }

    if (-not $topicMap.ContainsKey($topic)) {
        $topicMap[$topic] = 0
    }
    $topicMap[$topic] = [int]$topicMap[$topic] + 1
}
foreach ($topic in $topicMap.Keys) {
    Add-Observation -Source "git" -Key ("git.topic::{0}" -f $topic) -Value ([double]$topicMap[$topic]) -Confidence 0.75 -Meta @{
        since = $sinceDate
    }
}

$numstatLines = @()
try {
    $numstatLines = & git -C $ProjectRoot log "--since=$sinceDate" "--numstat" "--pretty=tformat:" "--" @gitPaths
} catch {
    $numstatLines = @()
}
$fileCounter = @{}
foreach ($line in $numstatLines) {
    if ($line -match '^(\d+|-)\s+(\d+|-)\s+(.+)$') {
        $file = [string]$matches[3]
        if (-not $fileCounter.ContainsKey($file)) {
            $fileCounter[$file] = 0
        }
        $fileCounter[$file] = [int]$fileCounter[$file] + 1
    }
}
$hotFiles = $fileCounter.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 20
foreach ($item in $hotFiles) {
    Add-Observation -Source "git" -Key ("git.hotfile::{0}" -f $item.Key) -Value ([double]$item.Value) -Confidence 0.7 -Meta @{
        since = $sinceDate
    }
}

# 2) 日志观测
$logSource = $config.observation_sources.logs
$logPaths = @($logSource.paths)
$logPatterns = @($logSource.patterns)
$maxLogFiles = [int]$logSource.max_files

$candidateFiles = New-Object System.Collections.Generic.List[object]
foreach ($path in $logPaths) {
    $full = Resolve-PathSafe -Base $ProjectRoot -Relative ([string]$path)
    if (-not (Test-Path $full)) { continue }
    $files = Get-ChildItem -Path $full -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in @(".log", ".txt", ".json") } |
        Sort-Object LastWriteTime -Descending
    foreach ($f in $files) { $candidateFiles.Add($f) | Out-Null }
}
$recentLogs = $candidateFiles | Sort-Object LastWriteTime -Descending | Select-Object -First $maxLogFiles

Add-Observation -Source "logs" -Key "logs.file_count" -Value $recentLogs.Count -Confidence 0.9 -Meta @{
    paths = ($logPaths -join ",")
}

foreach ($file in $recentLogs) {
    foreach ($pattern in $logPatterns) {
        $count = 0
        try {
            $count = (Select-String -Path $file.FullName -Pattern $pattern -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
        } catch {
            $count = 0
        }
        if ($count -gt 0) {
            Add-Observation -Source "logs" -Key ("log.pattern::{0}" -f $pattern) -Value ([double]$count) -Confidence 0.65 -Meta @{
                file = $file.FullName
                modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            }
        }
    }
}

# 3) 输出 JSONL（追加）
$writer = New-Utf8NoBomWriter -Path $observationsPath -Append $true
try {
    foreach ($obs in $observations) {
        $line = ($obs | ConvertTo-Json -Depth 8 -Compress)
        $writer.WriteLine($line)
    }
} finally {
    $writer.Dispose()
}

Write-Output "=== Evolution Collect ==="
Write-Output "Run ID: $runId"
Write-Output "Observations Written: $($observations.Count)"
Write-Output "Output: $observationsPath"

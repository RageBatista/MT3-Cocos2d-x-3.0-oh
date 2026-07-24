Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$rawInput = [Console]::In.ReadToEnd()
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$auditReport = Join-Path $repoRoot ".claude\reports\claude-config-audit.json"

try {
    $changed = git -C $repoRoot status --porcelain=v1 --untracked-files=all -- .claude 2>$null
    $changedPaths = @()

    foreach ($line in @($changed)) {
        $entry = [string]$line
        if ([string]::IsNullOrWhiteSpace($entry) -or $entry.Length -lt 4) {
            continue
        }

        $pathText = $entry.Substring(3).Trim()
        if ($pathText -match "\s->\s") {
            $pathText = ($pathText -split "\s->\s")[-1]
        }
        $pathText = $pathText.Trim('"')
        if ([string]::IsNullOrWhiteSpace($pathText) -or $pathText -like ".claude/reports/*") {
            continue
        }

        $absolutePath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $pathText))
        if (Test-Path $absolutePath -PathType Leaf) {
            $changedPaths += $absolutePath
        }
    }

    if ($changedPaths.Count -gt 0) {
        $latestChangedTime = ($changedPaths | ForEach-Object { (Get-Item $_).LastWriteTimeUtc } | Sort-Object -Descending | Select-Object -First 1)
        $shouldWarn = $true

        if (Test-Path $auditReport -PathType Leaf) {
            $auditTime = (Get-Item $auditReport).LastWriteTimeUtc
            $shouldWarn = $auditTime -lt $latestChangedTime
        }

        if ($shouldWarn) {
            [Console]::Error.WriteLine("[HOOK][WARN] 检测到 .claude 配置改动晚于最近审计报告。")
            [Console]::Error.WriteLine("[HOOK][WARN] 建议执行: pwsh.exe -NoLogo -NoProfile -File .\\.claude\\scripts\\audit_claude_config.ps1")
        }
    }
} catch {
    # ignore
}

if (-not [string]::IsNullOrWhiteSpace($rawInput)) {
    Write-Output $rawInput
}
exit 0

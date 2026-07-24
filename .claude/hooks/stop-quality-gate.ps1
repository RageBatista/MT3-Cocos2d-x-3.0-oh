Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$rawInput = [Console]::In.ReadToEnd()
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$qualityGateScript = Join-Path $repoRoot ".claude\scripts\quality_gate.ps1"

try {
    if (Test-Path $qualityGateScript -PathType Leaf) {
        $result = & $qualityGateScript -ChangedOnly -NonBlocking 2>&1
        if ($null -ne $result) {
            $text = ($result | Out-String).Trim()
            if (-not [string]::IsNullOrWhiteSpace($text) -and $text -notmatch "QUALITY GATE: PASS") {
                [Console]::Error.WriteLine($text)
            }
        }
    }
} catch {
    [Console]::Error.WriteLine("[HOOK][WARN] stop-quality-gate 执行失败: $($_.Exception.Message)")
}

if (-not [string]::IsNullOrWhiteSpace($rawInput)) {
    Write-Output $rawInput
}
exit 0

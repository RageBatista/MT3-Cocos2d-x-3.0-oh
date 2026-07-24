Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    exit 0
}

try {
    $payload = $rawInput | ConvertFrom-Json -Depth 20
} catch {
    Write-Output $rawInput
    exit 0
}

$commandText = [string]$payload.tool_input.command
if ($commandText -notmatch "(?i)\bgit\s+commit\b") {
    Write-Output $rawInput
    exit 0
}

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$secretHook = Join-Path $repoRoot ".claude\hooks\check-secrets.bat"

if (-not (Test-Path $secretHook)) {
    [Console]::Error.WriteLine("[HOOK][WARN] check-secrets.bat 不存在，跳过提交前敏感信息检查。")
    Write-Output $rawInput
    exit 0
}

Push-Location $repoRoot
try {
    cmd /c "`"$secretHook`""
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    [Console]::Error.WriteLine("[HOOK][BLOCK] 敏感信息检查未通过，已阻断 git commit。")
    exit 2
}

Write-Output $rawInput
exit 0


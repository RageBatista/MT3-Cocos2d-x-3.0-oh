Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$rawInput = [Console]::In.ReadToEnd()
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$auditPath = Join-Path $repoRoot ".claude\reports\claude-config-audit.json"
$routerPath = Join-Path $repoRoot ".claude\config\router.json"
$commandsPath = Join-Path $repoRoot ".claude\config\commands.manifest.json"
$hooksPath = Join-Path $repoRoot ".claude\config\hooks.manifest.json"

try {
    $routeCount = 0
    $commandCount = 0
    $hookCount = 0
    $auditStatus = "UNKNOWN"

    if (Test-Path $routerPath) {
        $routeCount = @((Get-Content -Raw -Encoding UTF8 $routerPath | ConvertFrom-Json).intent_routes).Count
    }
    if (Test-Path $commandsPath) {
        $commandCount = @((Get-Content -Raw -Encoding UTF8 $commandsPath | ConvertFrom-Json).commands).Count
    }
    if (Test-Path $hooksPath) {
        $hookCount = @((Get-Content -Raw -Encoding UTF8 $hooksPath | ConvertFrom-Json).hooks).Count
    }
    if (Test-Path $auditPath) {
        $auditStatus = [string](Get-Content -Raw -Encoding UTF8 $auditPath | ConvertFrom-Json).standard_layer.status
    }

    $hasVs120 = -not [string]::IsNullOrWhiteSpace($env:VS120COMNTOOLS)
    $hasJava = -not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)
    $hasAndroidNdk = (-not [string]::IsNullOrWhiteSpace($env:ANDROID_NDK)) -or (-not [string]::IsNullOrWhiteSpace($env:ANDROID_NDK_HOME))

    [Console]::Error.WriteLine("[HOOK][INFO] MT3 会话初始化: audit=$auditStatus, routes=$routeCount, commands=$commandCount, hooks=$hookCount")
    [Console]::Error.WriteLine("[HOOK][INFO] 工具链变量: VS120COMNTOOLS=$hasVs120, JAVA_HOME=$hasJava, ANDROID_NDK=$hasAndroidNdk")
    [Console]::Error.WriteLine("[HOOK][INFO] 常用命令: /audit-config, /quality-gate, pwsh.exe -NoLogo -NoProfile -File .\\.claude\\scripts\\audit_claude_config.ps1")
} catch {
    [Console]::Error.WriteLine("[HOOK][WARN] session-start-profile 执行失败: $($_.Exception.Message)")
}

if (-not [string]::IsNullOrWhiteSpace($rawInput)) {
    Write-Output $rawInput
}
exit 0

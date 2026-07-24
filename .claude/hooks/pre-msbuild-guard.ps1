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
if ([string]::IsNullOrWhiteSpace($commandText)) {
    Write-Output $rawInput
    exit 0
}

if ($commandText -notmatch "(?i)\bmsbuild(?:\.exe)?\b") {
    Write-Output $rawInput
    exit 0
}

$toolsetMatch = [regex]::Match($commandText, "(?i)platformtoolset\s*=\s*(v\d+)")
if ($toolsetMatch.Success) {
    $toolset = $toolsetMatch.Groups[1].Value.ToLowerInvariant()
    if ($toolset -ne "v120") {
        [Console]::Error.WriteLine("[HOOK][BLOCK] 检测到非 v120 工具集: $toolset")
        [Console]::Error.WriteLine("[HOOK][BLOCK] MT3 Windows 主线必须使用 VS2013 v120。")
        exit 2
    }
} else {
    [Console]::Error.WriteLine("[HOOK][WARN] 未在 msbuild 命令中显式声明 /p:PlatformToolset=v120，请确认项目文件已固定 v120。")
}

Write-Output $rawInput
exit 0


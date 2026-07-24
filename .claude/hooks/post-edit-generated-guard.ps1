Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-EditedPath {
    param([object]$InputPayload)
    if ($null -eq $InputPayload -or $null -eq $InputPayload.tool_input) {
        return ""
    }

    $candidates = @(
        $InputPayload.tool_input.file_path,
        $InputPayload.tool_input.path,
        $InputPayload.tool_input.filename,
        $InputPayload.tool_input.target_file
    )

    foreach ($candidate in $candidates) {
        $value = [string]$candidate
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value
        }
    }
    return ""
}

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

$editedPath = (Get-EditedPath -InputPayload $payload).Replace("\", "/")
if ([string]::IsNullOrWhiteSpace($editedPath)) {
    Write-Output $rawInput
    exit 0
}

if (
    $editedPath -match "(?i)server/.+/xbean/.+\.java$" -or
    $editedPath -match "(?i)server/.+/rpc/.+\.java$" -or
    $editedPath -match "(?i)client/.+/tolua\+\+/.+\.cpp$" -or
    $editedPath -match "(?i).+_tolua\.cpp$" -or
    $editedPath -match "(?i)client/FireClient/Application/ProtoDef/rpcgen/.+\.(hpp|cpp)$" -or
    $editedPath -match "(?i)client/FireClient/Application/ProtoDef/fire/pb/.+\.(hpp|cpp)$" -or
    $editedPath -match "(?i)client/FireClient/Application/ProtoDef/(rpcgen|protocols)\.(hpp|cpp)$"
) {
    [Console]::Error.WriteLine("[HOOK][WARN] 检测到生成代码路径: $editedPath")
    [Console]::Error.WriteLine("[HOOK][WARN] 请优先修改源定义文件并重新生成（xbean/protocol/pkg/rpcgen）。")
}

Write-Output $rawInput
exit 0

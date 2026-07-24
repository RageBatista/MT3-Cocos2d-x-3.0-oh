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

$extension = [System.IO.Path]::GetExtension($editedPath).ToLowerInvariant()
$requiresUtf8Bom = @(".cpp", ".c", ".h", ".hpp") -contains $extension
$requiresResourceBom = @(".rc") -contains $extension
$requiresNoBom = @(".lua", ".java", ".md", ".xml", ".json", ".txt", ".ps1", ".cmd", ".bat", ".sh", ".pkg", ".yml", ".yaml") -contains $extension

if (-not ($requiresUtf8Bom -or $requiresResourceBom -or $requiresNoBom)) {
    Write-Output $rawInput
    exit 0
}

$absolutePath = $editedPath
if (-not [System.IO.Path]::IsPathRooted($absolutePath)) {
    $absolutePath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $editedPath))
}

if (-not (Test-Path $absolutePath -PathType Leaf)) {
    Write-Output $rawInput
    exit 0
}

$bytes = [System.IO.File]::ReadAllBytes($absolutePath)
$bomKind = Get-BomKind -Bytes $bytes

[Console]::Error.WriteLine("[HOOK][WARN] 已编辑文本文件: $editedPath")

if ($requiresUtf8Bom -and $bomKind -ne "utf8-bom") {
    [Console]::Error.WriteLine("[HOOK][WARN] C/C++ 文件需要 UTF-8 BOM，当前检测为: $bomKind")
} elseif ($requiresResourceBom -and $bomKind -notin @("utf8-bom", "utf16le-bom")) {
    [Console]::Error.WriteLine("[HOOK][WARN] .rc 文件需要 UTF-8 BOM 或 UTF-16 LE BOM，当前检测为: $bomKind")
} elseif ($requiresNoBom -and $bomKind -ne "no-bom") {
    [Console]::Error.WriteLine("[HOOK][WARN] 当前文件不应包含 BOM，检测为: $bomKind")
} else {
    [Console]::Error.WriteLine("[HOOK][WARN] 编码/BOM 检查通过，请继续执行回读校验。")
}

[Console]::Error.WriteLine("[HOOK][WARN] 建议校验: Get-Content -Encoding UTF8 -TotalCount 20 <file> && Format-Hex -Path <file> -Count 16")

Write-Output $rawInput
exit 0

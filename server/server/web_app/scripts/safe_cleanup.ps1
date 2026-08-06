param(
    [switch]$Apply,
    [switch]$IncludeOptional,
    [string]$RootPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ProjectRoot {
    param([string]$InputRoot)

    if ([string]::IsNullOrWhiteSpace($InputRoot)) {
        return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    }

    return (Resolve-Path $InputRoot).Path
}

function Assert-ProjectRoot {
    param([string]$Root)

    $required = @("app", "config", "public", "runtime", "composer.json")
    foreach ($item in $required) {
        $full = Join-Path $Root $item
        if (-not (Test-Path $full)) {
            throw "Project root validation failed. Missing: $item (Root=$Root)"
        }
    }
}

function To-AbsolutePath {
    param(
        [string]$Root,
        [string]$RelativePath
    )
    return [System.IO.Path]::GetFullPath((Join-Path $Root $RelativePath))
}

function Assert-PathInRoot {
    param(
        [string]$Root,
        [string]$FullPath
    )

    $rootWithSep = $Root.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $FullPath.StartsWith($rootWithSep, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Safety check failed. Path is outside project root: $FullPath"
    }
}

function Get-PathSizeBytes {
    param([string]$FullPath)

    if (-not (Test-Path $FullPath)) {
        return [int64]0
    }

    $item = Get-Item $FullPath -Force
    if (-not $item.PSIsContainer) {
        return [int64]$item.Length
    }

    $files = @(Get-ChildItem $FullPath -Recurse -File -Force -ErrorAction SilentlyContinue)
    if ($files.Count -eq 0) {
        return [int64]0
    }

    $measure = $files | Measure-Object -Property Length -Sum
    return [int64]$measure.Sum
}

function Clear-Target {
    param(
        [string]$Root,
        [hashtable]$Target,
        [switch]$ApplyDelete
    )

    $fullPath = To-AbsolutePath -Root $Root -RelativePath $Target.Path
    Assert-PathInRoot -Root $Root -FullPath $fullPath

    if (-not (Test-Path $fullPath)) {
        return [PSCustomObject]@{
            Path       = $fullPath
            Exists     = $false
            Deleted    = $false
            Reason     = $Target.Reason
            SizeBytes  = [int64]0
            ActionType = "SkipMissing"
        }
    }

    $size = Get-PathSizeBytes -FullPath $fullPath
    $item = Get-Item $fullPath -Force

    if (-not $ApplyDelete) {
        return [PSCustomObject]@{
            Path       = $fullPath
            Exists     = $true
            Deleted    = $false
            Reason     = $Target.Reason
            SizeBytes  = $size
            ActionType = "DryRun"
        }
    }

    if ($item.PSIsContainer) {
        Get-ChildItem -LiteralPath $fullPath -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction Stop
        $actionType = "ClearDirectoryContent"
    } else {
        Remove-Item -LiteralPath $fullPath -Force -ErrorAction Stop
        $actionType = "DeleteFile"
    }

    return [PSCustomObject]@{
        Path       = $fullPath
        Exists     = $true
        Deleted    = $true
        Reason     = $Target.Reason
        SizeBytes  = $size
        ActionType = $actionType
    }
}

$root = Resolve-ProjectRoot -InputRoot $RootPath
Assert-ProjectRoot -Root $root

$safeTargets = @(
    @{ Path = "runtime/cache";      Reason = "ThinkPHP runtime cache; safe to rebuild." }
    @{ Path = "runtime/log";        Reason = "Runtime logs; can be rotated/cleared." }
    @{ Path = "runtime/admin/temp"; Reason = "Compiled template cache for admin app." }
    @{ Path = "runtime/index/temp"; Reason = "Compiled template cache for index app." }
    @{ Path = "runtime/login/temp"; Reason = "Compiled template cache for login app." }
    @{ Path = "app/gm/Gm.php.bak";  Reason = "Backup artifact; not part of runtime." }
)

$optionalTargets = @(
    @{ Path = "app/api/controller/Log.php";     Reason = "Zero-byte placeholder file." }
    @{ Path = "app/api/controller/Result2.txt"; Reason = "Zero-byte placeholder file." }
    @{ Path = "public/txt/taozhuang.txt";       Reason = "Zero-byte placeholder file." }
    @{ Path = "public/static/template/pay/js/jquery.cookie.min.js"; Reason = "Duplicate file; same hash as public/static/template/js/jquery.cookie.min.js and no internal path reference." }
    @{ Path = "public/favicon.ico"; Reason = "Duplicate file; same hash as public/static/template/favicon.ico. Keep template favicon for __MB__ mapping." }
)

$targets = @()
$targets += $safeTargets
if ($IncludeOptional) {
    $targets += $optionalTargets
}

$mode = if ($Apply) { "APPLY" } else { "DRY-RUN" }
if ($IncludeOptional) { $mode = "$mode + OPTIONAL" }

Write-Host "Project root: $root"
Write-Host "Mode: $mode"
Write-Host ""

$results = @()
foreach ($target in $targets) {
    $results += Clear-Target -Root $root -Target $target -ApplyDelete:$Apply
}

$total = [int64](($results | Measure-Object -Property SizeBytes -Sum).Sum)
$hitCount = @($results | Where-Object { $_.Exists }).Count
$deletedCount = @($results | Where-Object { $_.Deleted }).Count

$results |
    Select-Object ActionType, Deleted, SizeBytes, Path, Reason |
    Sort-Object ActionType, Path |
    Format-Table -AutoSize

Write-Host ""
Write-Host ("Targets found: {0}/{1}" -f $hitCount, $results.Count)
Write-Host ("Estimated reclaim: {0} bytes" -f $total)
Write-Host ("Deleted items: {0}" -f $deletedCount)

if (-not $Apply) {
    Write-Host ""
    Write-Host "Dry-run only. Execute the following after confirmation:"
    if ($IncludeOptional) {
        Write-Host ".\\scripts\\safe_cleanup.ps1 -Apply -IncludeOptional"
    } else {
        Write-Host ".\\scripts\\safe_cleanup.ps1 -Apply"
    }
}

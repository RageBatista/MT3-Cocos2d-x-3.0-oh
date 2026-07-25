#Requires -Version 5.1
<#
.SYNOPSIS
    分析 APK 文件大小分布，识别异常大的文件

.DESCRIPTION
    用于诊断 APK 体积异常，输出文件大小分布和 Top 占用

.PARAMETER ApkPath
    APK 文件路径

.PARAMETER ThresholdMB
    大文件阈值（MB），默认 1MB

.PARAMETER TopN
    输出 Top N 大文件，默认 20

.EXAMPLE
    .\Analyze-ApkSize.ps1 -ApkPath "bin/mt3-debug.apk"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ApkPath,

    [Parameter(Mandatory = $false)]
    [int]$ThresholdMB = 1,

    [Parameter(Mandatory = $false)]
    [int]$TopN = 20,

    [Parameter(Mandatory = $false)]
    [string]$OutputFormat = "text"
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-ApkAnalysis {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "APK not found: $Path"
    }

    Add-Type -AssemblyName System.IO.Compression

    $fileStream = $null
    $zipArchive = $null

    try {
        $fileStream = [System.IO.File]::OpenRead($Path)
        $zipArchive = [System.IO.Compression.ZipArchive]::new($fileStream, [System.IO.Compression.ZipArchiveMode]::Read, $true)

        $entries = @($zipArchive.Entries)
        $totalSize = ($entries | Measure-Object -Property Length -Sum).Sum

        $analysis = @{
            FilePath = (Resolve-Path $Path).FullName
            FileSizeBytes = (Get-Item $Path).Length
            FileSizeGB = [Math]::Round((Get-Item $Path).Length / 1GB, 2)
            TotalCompressedBytes = $totalSize
            EntryCount = $entries.Count
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        # 按类型分组统计
        $byExtension = $entries | Group-Object {
            $ext = [System.IO.Path]::GetExtension($_.FullName)
            if ([string]::IsNullOrEmpty($ext)) {
                if ($_.FullName -like 'lib/*') { return 'lib' }
                if ($_.FullName -like 'assets/*') { return 'assets' }
                if ($_.FullName -like 'res/*') { return 'res' }
                return 'other'
            }
            $ext.ToLower().TrimStart('.')
        } | ForEach-Object {
            @{
                Type = $_.Name
                Count = $_.Count
                TotalBytes = ($_.Group | Measure-Object -Property Length -Sum).Sum
                TotalMB = [Math]::Round(($_.Group | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
                Percent = [Math]::Round(($_.Group | Measure-Object -Property Length -Sum).Sum / $totalSize * 100, 1)
            }
        }

        # Top 大文件
        $topFiles = $entries |
            Sort-Object -Property Length -Descending |
            Select-Object -First $TopN | ForEach-Object {
                @{
                    Name = Split-Path $_.FullName -Leaf
                    Path = $_.FullName
                    SizeBytes = $_.Length
                    SizeMB = [Math]::Round($_.Length / 1MB, 2)
                    Percent = [Math]::Round($_.Length / $totalSize * 100, 2)
                }
            }

        # 大于阈值文件
        $thresholdBytes = $ThresholdMB * 1MB
        $largeFiles = $entries |
            Where-Object { $_.Length -gt $thresholdBytes } |
            Sort-Object -Property Length -Descending

        $analysis['ByType'] = $byExtension
        $analysis['TopFiles'] = $topFiles
        $analysis['LargeFilesCount'] = $largeFiles.Count
        $analysis['LargeFilesTotalMB'] = [Math]::Round(($largeFiles | Measure-Object -Property Length -Sum).Sum / 1MB, 2)

        # 诊断建议
        $suggestions = @()
        if ($analysis.FileSizeGB -gt 0.5) {
            $suggestions += "APK 体积超过 500MB，建议检查资源打包策略"
        }
        if ($analysis.ByType | Where-Object { $_.Type -eq 'assets' -and $_.Percent -gt 50 }) {
            $suggestions += "assets 目录占比过高，考虑使用 APK Split 或动态下载"
        }
        if ($largeFiles.Count -gt 100) {
            $suggestions += "存在 $($largeFiles.Count) 个大文件(>$ThresholdMB MB)，建议优化资源压缩"
        }

        $analysis['Suggestions'] = $suggestions

        return $analysis
    }
    finally {
        if ($zipArchive) { $zipArchive.Dispose() }
        if ($fileStream) { $fileStream.Dispose() }
    }
}

function Format-TextOutput {
    param($Data)

    $sep = "=" * 70
    $subSep = "-" * 50

    Write-Host ""
    Write-Host $sep -ForegroundColor Cyan
    Write-Host "  APK 大小分析报告" -ForegroundColor Cyan
    Write-Host $sep -ForegroundColor Cyan
    Write-Host ""

    Write-Host "基本信息:" -ForegroundColor Yellow
    Write-Host "  文件路径 : $($Data.FilePath)"
    Write-Host "  文件大小 : $($Data.FileSizeGB) GB ($([Math]::Round($Data.FileSizeBytes/1MB, 2)) MB)"
    Write-Host "  压缩大小 : $([Math]::Round($Data.TotalCompressedBytes/1MB, 2)) MB"
    Write-Host "  文件数量 : $($Data.EntryCount) 个"
    Write-Host "  分析时间 : $($Data.Timestamp)"
    Write-Host ""

    Write-Host "按类型分布:" -ForegroundColor Yellow
    $Data.ByType | Sort-Object -Property TotalBytes -Descending | ForEach-Object {
        $barLen = [Math]::Max(1, [int]($_.Percent / 2))
        $bar = "#" * $barLen
        Write-Host ("  {0,-10} {1,6} MB ({2,5:P1}) |{3,-50}| ({4} files)" -f $_.Type, $_.TotalMB, ($_.Percent/100), $bar, $_.Count)
    }
    Write-Host ""

    Write-Host "Top $($Data.TopFiles.Count) 大文件:" -ForegroundColor Yellow
    $Data.TopFiles | ForEach-Object {
        Write-Host ("  {0,8:N2} MB | {1:P2} | {2}" -f $_.SizeMB, ($_.Percent/100), $_.Path)
    }
    Write-Host ""

    Write-Host "大文件统计 (> $ThresholdMB MB):" -ForegroundColor Yellow
    Write-Host "  数量: $($Data.LargeFilesCount) 个"
    Write-Host "  总计: $($Data.LargeFilesTotalMB) MB"
    Write-Host ""

    if ($Data.Suggestions.Count -gt 0) {
        Write-Host "诊断建议:" -ForegroundColor Yellow
        $Data.Suggestions | ForEach-Object {
            Write-Host "  * $_" -ForegroundColor Magenta
        }
        Write-Host ""
    }

    Write-Host $sep -ForegroundColor Cyan
}

function Format-JsonOutput {
    param($Data)

    $Data | ConvertTo-Json -Depth 10
}

# 执行分析
$analysis = Get-ApkAnalysis -Path $ApkPath

# 输出结果
switch ($OutputFormat.ToLower()) {
    "json" { Format-JsonOutput -Data $analysis }
    "compact" {
        Write-Host "APK: $($analysis.FilePath)"
        Write-Host "Size: $($analysis.FileSizeGB) GB ($($analysis.EntryCount) files)"
        Write-Host "Top占用: $(($analysis.ByType | Sort-Object -Property TotalBytes -Descending | Select-Object -First 3 | ForEach-Object { $_.Type + '=' + $_.TotalMB + 'MB' }) -join ', ')"
    }
    default { Format-TextOutput -Data $analysis }
}

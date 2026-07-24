# 预编译头使用检查脚本 (MT3 项目)
# 用途: 检查所有 .cpp 文件是否正确包含预编译头 nupch.h
# 版本: v2.0.0 (优化版)
# 最后更新: 2025-11-27
# 更新内容:
#   - 添加 UTF-8 BOM 检测和处理
#   - 添加 JSON 输出选项（便于 CI/CD）
#   - 添加进度指示
#   - 优化颜色输出和错误报告

param(
    [string]$Path = ".",
    [switch]$Fix,
    [switch]$Verbose,
    [switch]$JsonOutput,
    [switch]$NoProgress
)

# 检测 UTF-8 BOM
function Test-Utf8Bom {
    param([string]$FilePath)

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    if ($bytes.Length -ge 3) {
        return ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    }
    return $false
}

# 移除 UTF-8 BOM
function Remove-Utf8Bom {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $content, $utf8NoBom)
}

if (-not $JsonOutput) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " MT3 预编译头检查工具 v2.0" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

$errorCount = 0
$fixedCount = 0
$checkedCount = 0
$bomCount = 0
$errorList = @()

# 排除的目录
$excludeDirs = @(
    "*\\.git\\*",
    "*\\build\\*",
    "*\\Release.*",
    "*\\Debug.*",
    "*\\dependencies\\*",
    "*\\cocos2d-*",
    "*\\tolua++*"
)

# 获取所有 .cpp 文件
if (-not $JsonOutput) {
    Write-Host "扫描 C++ 源文件..." -ForegroundColor Yellow
}

$cppFiles = Get-ChildItem -Path $Path -Filter *.cpp -Recurse -File | Where-Object {
    $file = $_
    $exclude = $false
    foreach ($pattern in $excludeDirs) {
        if ($file.FullName -like $pattern) {
            $exclude = $true
            break
        }
    }
    -not $exclude
}

$totalFiles = $cppFiles.Count

if (-not $JsonOutput) {
    Write-Host "找到 $totalFiles 个 C++ 文件`n" -ForegroundColor Green
}

foreach ($file in $cppFiles) {
    $checkedCount++

    # 显示进度
    if (-not $NoProgress -and -not $JsonOutput) {
        $percentComplete = [math]::Round(($checkedCount / $totalFiles) * 100, 0)
        Write-Progress -Activity "检查预编译头" `
                       -Status "进度: $checkedCount/$totalFiles ($percentComplete%)" `
                       -PercentComplete $percentComplete `
                       -CurrentOperation $file.Name
    }

    if ($Verbose -and -not $JsonOutput) {
        Write-Host "检查: $($file.FullName)" -ForegroundColor Gray
    }

    # 检测 UTF-8 BOM
    if (Test-Utf8Bom -FilePath $file.FullName) {
        $bomCount++
        if ($Verbose -and -not $JsonOutput) {
            Write-Host "  ⚠️  检测到 UTF-8 BOM" -ForegroundColor Yellow
        }

        if ($Fix) {
            try {
                Remove-Utf8Bom -FilePath $file.FullName
                if ($Verbose -and -not $JsonOutput) {
                    Write-Host "  ✅ 已移除 UTF-8 BOM" -ForegroundColor Green
                }
            } catch {
                if (-not $JsonOutput) {
                    Write-Host "  ❌ 移除 BOM 失败: $_" -ForegroundColor Red
                }
            }
        }
    }

    # 读取文件前10行（增加行数以处理更多注释）
    $lines = Get-Content $file.FullName -TotalCount 10 -ErrorAction SilentlyContinue

    if (-not $lines) {
        $error = @{
            file = $file.FullName
            type = "empty_or_unreadable"
            message = "文件为空或无法读取"
        }
        $errorList += $error

        if (-not $JsonOutput) {
            Write-Host "❌ $($file.FullName): 文件为空或无法读取" -ForegroundColor Red
        }
        $errorCount++
        continue
    }

    # 检查是否包含 nupch.h
    $hasPCH = $false
    $pchLine = -1
    $isFirstCodeLine = $true

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()

        # 跳过注释和空行
        if ($line -match '^\s*//|^\s*$|^\s*/\*') {
            continue
        }

        # 检查是否包含 nupch.h
        if ($line -match '#include\s+["<]nupch\.h[">]') {
            $hasPCH = $true
            $pchLine = $i + 1

            # 检查是否是第一行有效代码
            if (-not $isFirstCodeLine) {
                $error = @{
                    file = $file.FullName
                    type = "pch_not_first_line"
                    line = $pchLine
                    message = "预编译头不在第一行有效代码位置（第 $pchLine 行）"
                }
                $errorList += $error
                $errorCount++

                if (-not $JsonOutput) {
                    Write-Host "⚠️  $($file.FullName): nupch.h 不在第一行 (第 $pchLine 行)" -ForegroundColor Yellow
                }
            }
            break
        }

        # 如果遇到其他代码（include 或其他），标记为非第一行
        if ($line -match '#include|#define|#pragma|^\w+') {
            $isFirstCodeLine = $false
        }
    }

    if (-not $hasPCH) {
        $error = @{
            file = $file.FullName
            type = "missing_pch"
            message = "缺少预编译头 nupch.h"
        }
        $errorList += $error
        $errorCount++

        if (-not $JsonOutput) {
            Write-Host "❌ $($file.FullName): 缺少预编译头 nupch.h" -ForegroundColor Red
        }

        if ($Fix) {
            try {
                $content = Get-Content $file.FullName -Raw
                $newContent = "#include ""nupch.h""`n" + $content

                # 使用 UTF-8 无 BOM 编码
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)

                if (-not $JsonOutput) {
                    Write-Host "   ✅ 已自动添加预编译头" -ForegroundColor Green
                }
                $fixedCount++
            } catch {
                if (-not $JsonOutput) {
                    Write-Host "   ❌ 修复失败: $_" -ForegroundColor Red
                }
            }
        } elseif (-not $JsonOutput) {
            Write-Host "   提示: 运行脚本时添加 -Fix 参数可自动修复" -ForegroundColor Yellow
        }
    } else {
        if ($Verbose -and -not $JsonOutput -and $pchLine -eq 1) {
            Write-Host "✅ $($file.FullName)" -ForegroundColor Green
        }
    }
}

# 清除进度条
if (-not $NoProgress -and -not $JsonOutput) {
    Write-Progress -Activity "检查预编译头" -Completed
}

# 输出结果
if ($JsonOutput) {
    # JSON 格式输出（便于 CI/CD 集成）
    $result = @{
        total_files = $totalFiles
        checked_files = $checkedCount
        error_count = $errorCount
        fixed_count = $fixedCount
        bom_count = $bomCount
        errors = $errorList
        status = if ($errorCount -eq 0) { "success" } else { "failed" }
    }

    $result | ConvertTo-Json -Depth 10
} else {
    # 人类可读格式输出
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " 检查完成" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    Write-Host "检查文件数: $checkedCount" -ForegroundColor White
    Write-Host "错误数量:   $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })

    if ($bomCount -gt 0) {
        Write-Host "BOM 文件数: $bomCount" -ForegroundColor Yellow
    }

    if ($Fix) {
        Write-Host "修复数量:   $fixedCount" -ForegroundColor Green
    }

    Write-Host ""

    if ($errorCount -eq 0) {
        Write-Host "✅ 所有文件都正确包含预编译头" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "❌ 发现 $errorCount 个问题" -ForegroundColor Red
        if (-not $Fix) {
            Write-Host "   运行 'powershell .\check_precompiled_header.ps1 -Fix' 自动修复" -ForegroundColor Yellow
        }
        exit 1
    }
}

#Requires -Version 5.1
<#
.SYNOPSIS
    MT3 服务器端统一构建脚本

.DESCRIPTION
    统一管理游戏服务器的所有构建任务
    支持代码生成、编译、打包

.PARAMETER Target
    构建目标:
      - compile  : 仅编译
      - jar      : 编译并打包 jar
      - genfiles : 生成所有协议和配置代码
      - genrpc   : 仅生成协议代码
      - genxdb   : 仅生成数据层代码
      - dist     : 完整打包部署

.PARAMETER Project
    目标项目:
      - game   : 游戏服务器 (game_server)
      - all    : 所有项目

.PARAMETER ServerBinDir
    服务器产物输出目录

.PARAMETER SkipCodeGen
    跳过代码生成阶段

.PARAMETER SkipCompile
    跳过编译阶段

.EXAMPLE
    # 编译游戏服务器
    .\Build-Server-MT3.ps1 -Target compile -Project game

    # 完整打包
    .\Build-Server-MT3.ps1 -Target dist -Project game

    # 仅生成代码
    .\Build-Server-MT3.ps1 -Target genfiles -Project game
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("compile", "jar", "genfiles", "genrpc", "genxdb", "dist", "all")]
    [string]$Target = "compile",

    [Parameter(Mandatory = $false)]
    [ValidateSet("game", "name", "sdk", "all")]
    [string]$Project = "game",

    [Parameter(Mandatory = $false)]
    [string]$ServerBinDir = "",

    [Parameter(Mandatory = $false)]
    [switch]$SkipCodeGen,

    [Parameter(Mandatory = $false)]
    [switch]$SkipCompile,

    [Parameter(Mandatory = $false)]
    [switch]$Clean,

    [Parameter(Mandatory = $false)]
    [switch]$Verbose
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ============================================================
# 路径解析
# ============================================================
function Get-ServerRepoRoot {
    $scriptRoot = $PSScriptRoot
    if (-not $scriptRoot) {
        $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    }

    $candidates = @(
        $scriptRoot,
        (Join-Path $scriptRoot "..\.."),
        (Join-Path $scriptRoot "..\..\..")
    )

    foreach ($candidate in $candidates) {
        $buildXml = Join-Path $candidate "server\server\game_server\build.xml"
        if (Test-Path $buildXml) {
            return $candidate
        }
    }

    return $null
}

function Get-DefaultServerBinDir {
    param([string]$RepoRoot)
    return Join-Path $RepoRoot "server\serverbin"
}

# ============================================================
# JDK 检测
# ============================================================
function Test-JDK {
    $javaHome = $env:JAVA_HOME
    if (-not $javaHome) {
        $javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
    }

    if (-not $javaHome) {
        # 尝试常见路径
        foreach ($p in @("C:\Program Files\Java\jdk1.7.0_80",
                         "C:\Program Files\Java\jdk1.8.0_144",
                         "C:\Program Files\Java\jdk1.8.0_202")) {
            if (Test-Path (Join-Path $p "bin\java.exe")) {
                $javaHome = $p
                break
            }
        }
    }

    if ($javaHome) {
        $javaExe = Join-Path $javaHome "bin\java.exe"
        if (Test-Path $javaExe) {
            $version = & $javaExe -version 2>&1 | Select-Object -First 1
            return @{
                Found = $true
                Path = $javaHome
                Version = $version
            }
        }
    }

    return @{
        Found = $false
        Path = $null
        Version = $null
    }
}

function Get-AntPath {
    $antHome = $env:ANT_HOME
    if (-not $antHome) {
        $antHome = [Environment]::GetEnvironmentVariable("ANT_HOME", "Machine")
    }

    if (-not $antHome) {
        foreach ($p in @("D:\apache-ant-1.9.7", "C:\apache-ant-1.9.7")) {
            if (Test-Path (Join-Path $p "bin\ant.bat")) {
                $antHome = $p
                break
            }
        }
    }

    if ($antHome) {
        $antBat = Join-Path $antHome "bin\ant.bat"
        if (Test-Path $antBat) {
            return $antBat
        }
    }

    return $null
}

# ============================================================
# Ant 构建执行
# ============================================================
function Invoke-AntBuild {
    param(
        [string]$BuildXmlPath,
        [string]$AntTarget,
        [string]$WorkingDir,
        [string]$JavaHome,
        [string]$AntPath
    )

    if (-not (Test-Path $BuildXmlPath)) {
        throw "Build XML not found: $BuildXmlPath"
    }

    if (-not (Test-Path $WorkingDir)) {
        throw "Working directory not found: $WorkingDir"
    }

    # 设置环境
    $env:JAVA_HOME = $JavaHome
    $env:ANT_HOME = Split-Path (Split-Path $AntPath -Parent) -Parent

    $antArgs = @("-buildfile", $BuildXmlPath)
    if ($Verbose) {
        $antArgs += "-verbose"
    }
    else {
        $antArgs += "-q"
    }
    $antArgs += $AntTarget

    Write-Host "[Ant] $WorkingDir > ant $($AntTarget)" -ForegroundColor Cyan

    Push-Location $WorkingDir
    try {
        & cmd /c "$AntPath $($antArgs -join ' ') 2>&1"
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0) {
            throw "Ant build failed with exit code: $exitCode"
        }

        return $exitCode
    }
    finally {
        Pop-Location
    }
}

# ============================================================
# 服务器构建任务
# ============================================================
function Build-GameServer {
    param(
        [string]$RepoRoot,
        [string]$ServerBinDir,
        [bool]$SkipCodeGen,
        [bool]$SkipCompile,
        [bool]$Clean
    )

    $gameServerDir = Join-Path $RepoRoot "server\server\game_server"
    $antBat = Get-AntPath
    if (-not $antBat) {
        throw "Apache Ant not found. Set ANT_HOME or install Apache Ant."
    }

    $javaInfo = Test-JDK
    if (-not $javaInfo.Found) {
        throw "JDK not found. Set JAVA_HOME or install JDK 1.7/1.8."
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  游戏服务器构建" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  JDK: $($javaInfo.Path)"
    Write-Host "  Ant: $antBat"
    Write-Host "  输出: $ServerBinDir"
    Write-Host "========================================" -ForegroundColor Cyan

    # 创建输出目录
    if (-not (Test-Path $ServerBinDir)) {
        New-Item -ItemType Directory -Path $ServerBinDir -Force | Out-Null
    }

    # 代码生成阶段
    if (-not $SkipCodeGen) {
        Write-Host ""
        Write-Host "阶段 1: 生成代码..." -ForegroundColor Yellow

        # 检查 conf.m4
        $confM4 = Join-Path $gameServerDir "conf.m4"
        $confM4Sample = Join-Path $gameServerDir "conf.m4.sample"

        if (-not (Test-Path $confM4) -and (Test-Path $confM4Sample)) {
            Write-Host "复制 conf.m4.sample -> conf.m4" -ForegroundColor Yellow
            Copy-Item $confM4Sample $confM4
        }

        # 生成协议代码
        Invoke-AntBuild -BuildXmlPath $gameServerDir -AntTarget "genrpc" `
            -WorkingDir $gameServerDir -JavaHome $javaInfo.Path -AntPath $antBat

        # 生成 xdb 代码
        Invoke-AntBuild -BuildXmlPath $gameServerDir -AntTarget "genxdb" `
            -WorkingDir $gameServerDir -JavaHome $javaInfo.Path -AntPath $antBat

        # 生成配置代码
        Invoke-AntBuild -BuildXmlPath $gameServerDir -AntTarget "gengbeans" `
            -WorkingDir $gameServerDir -JavaHome $javaInfo.Path -AntPath $antBat

        Write-Host "代码生成完成" -ForegroundColor Green
    }
    else {
        Write-Host "[跳过] 代码生成阶段" -ForegroundColor DarkGray
    }

    # 编译阶段
    if (-not $SkipCompile) {
        Write-Host ""
        Write-Host "阶段 2: 编译..." -ForegroundColor Yellow

        # 编译 gs 子项目
        $gsBuildXml = Join-Path $gameServerDir "gs\build.xml"
        if (Test-Path $gsBuildXml) {
            Invoke-AntBuild -BuildXmlPath $gsBuildXml -AntTarget "compile" `
                -WorkingDir (Join-Path $gameServerDir "gs") -JavaHome $javaInfo.Path -AntPath $antBat
        }

        Write-Host "编译完成" -ForegroundColor Green
    }
    else {
        Write-Host "[跳过] 编译阶段" -ForegroundColor DarkGray
    }

    # 打包阶段
    if ($Clean) {
        Write-Host ""
        Write-Host "清理..." -ForegroundColor Yellow
        Invoke-AntBuild -BuildXmlPath $gameServerDir -AntTarget "clean" `
            -WorkingDir $gameServerDir -JavaHome $javaInfo.Path -AntPath $antBat
    }
}

function Build-NameServer {
    param(
        [string]$RepoRoot,
        [string]$ServerBinDir
    )

    $nameServerDir = Join-Path $RepoRoot "server\server\name_server"
    $antBat = Get-AntPath
    $javaInfo = Test-JDK

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  名字服务器构建" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    if (Test-Path (Join-Path $nameServerDir "build.xml")) {
        Invoke-AntBuild -BuildXmlPath $nameServerDir -AntTarget "compile" `
            -WorkingDir $nameServerDir -JavaHome $javaInfo.Path -AntPath $antBat
    }
}

# ============================================================
# 主流程
# ============================================================
$repoRoot = Get-ServerRepoRoot
if (-not $repoRoot) {
    Write-Error "无法找到 MT3 服务器仓库根目录"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($ServerBinDir)) {
    $ServerBinDir = Get-DefaultServerBinDir -RepoRoot $repoRoot
}

# JDK 检查
Write-Host ""
Write-Host "检查构建环境..." -ForegroundColor Cyan
$javaInfo = Test-JDK
if ($javaInfo.Found) {
    Write-Host "  [PASS] JDK: $($javaInfo.Path)" -ForegroundColor Green
}
else {
    Write-Host "  [FAIL] JDK 未找到，请设置 JAVA_HOME 环境变量" -ForegroundColor Red
    Write-Host "         支持版本: JDK 1.7 或 JDK 1.8"
    Write-Host "         JDK 9+ 不兼容"
    exit 1
}

$antBat = Get-AntPath
if ($antBat) {
    Write-Host "  [PASS] Ant: $antBat" -ForegroundColor Green
}
else {
    Write-Host "  [FAIL] Apache Ant 未找到，请设置 ANT_HOME 环境变量" -ForegroundColor Red
    Write-Host "         需要版本: Ant 1.9+"
    exit 1
}

# 执行构建
switch ($Target.ToLower()) {
    "compile" {
        Build-GameServer -RepoRoot $repoRoot -ServerBinDir $ServerBinDir `
            -SkipCodeGen $true -SkipCompile $false -Clean $Clean.IsPresent
    }
    "jar" {
        Build-GameServer -RepoRoot $repoRoot -ServerBinDir $ServerBinDir `
            -SkipCodeGen $true -SkipCompile $false -Clean $Clean.IsPresent
    }
    "genfiles" {
        Build-GameServer -RepoRoot $repoRoot -ServerBinDir $ServerBinDir `
            -SkipCodeGen $false -SkipCompile $true -Clean $Clean.IsPresent
    }
    "genrpc" {
        # 只生成协议
        $gameServerDir = Join-Path $repoRoot "server\server\game_server"
        Invoke-AntBuild -BuildXmlPath $gameServerDir -AntTarget "genrpc" `
            -WorkingDir $gameServerDir -JavaHome $javaInfo.Path -AntPath $antBat
    }
    "genxdb" {
        # 只生成 xdb
        $gameServerDir = Join-Path $repoRoot "server\server\game_server"
        Invoke-AntBuild -BuildXmlPath $gameServerDir -AntTarget "genxdb" `
            -WorkingDir $gameServerDir -JavaHome $javaInfo.Path -AntPath $antBat
    }
    "dist" {
        Build-GameServer -RepoRoot $repoRoot -ServerBinDir $ServerBinDir `
            -SkipCodeGen $SkipCodeGen.IsPresent -SkipCompile $SkipCompile.IsPresent `
            -Clean $Clean.IsPresent

        # 完整打包
        $gameServerDir = Join-Path $repoRoot "server\server\game_server"
        Invoke-AntBuild -BuildXmlPath $gameServerDir -AntTarget "dist" `
            -WorkingDir $gameServerDir -JavaHome $javaInfo.Path -AntPath $antBat
    }
    "all" {
        Build-GameServer -RepoRoot $repoRoot -ServerBinDir $ServerBinDir `
            -SkipCodeGen $false -SkipCompile $false -Clean $Clean.IsPresent

        if ($Project -eq "all") {
            Build-NameServer -RepoRoot $repoRoot -ServerBinDir $ServerBinDir
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  构建完成" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 验证产物
if (Test-Path $ServerBinDir) {
    Write-Host ""
    Write-Host "构建产物:" -ForegroundColor Cyan
    Get-ChildItem $ServerBinDir -Directory | ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host ("  {0}: {1:N2} MB" -f $_.Name, $size)
    }
}

exit 0

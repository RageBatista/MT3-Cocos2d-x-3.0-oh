#Requires -Version 5.1
<#
.SYNOPSIS
    MT3 iOS 客户端自动化构建脚本

.DESCRIPTION
    在 macOS 环境下构建 MT3 iOS 客户端
    支持真机打包和模拟器构建

.PARAMETER Configuration
    构建配置: Debug 或 Release

.PARAMETER CodeSignIdentity
    代码签名标识 (如 "iPhone Developer: Name (TEAMID)")

.PARAMETER ProvisioningProfile
    描述文件 UUID 或名称

.PARAMETER DevelopmentTeam
    Apple Developer Team ID

.PARAMETER TargetDevice
    目标设备: Device (真机), Simulator (模拟器), Any (任一连接设备)

.PARAMETER ProjectPath
    Xcode 项目路径

.PARAMETER OutputDir
    产物输出目录

.PARAMETER StaticGateOnly
    只执行 Xcode 工程、目标、宏和物理依赖静态门禁，不调用 Xcode

.PARAMETER SkipCodeSign
    只验证编译和链接，关闭代码签名；不得与 Archive/Export 同时使用

.EXAMPLE
    # 基本构建
    .\Build-iOS-MT3.ps1 -Configuration Release

    # 真机打包
    .\Build-iOS-MT3.ps1 -Configuration Release -CodeSignIdentity "iPhone Developer: XXX" -ProvisioningProfile "xxxxx-xxxxx"

    # 模拟器构建
    .\Build-iOS-MT3.ps1 -Configuration Debug -TargetDevice Simulator

    # Windows/CI 静态门禁
    .\Build-iOS-MT3.ps1 -StaticGateOnly
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",

    [Parameter(Mandatory = $false)]
    [string]$CodeSignIdentity = "",

    [Parameter(Mandatory = $false)]
    [string]$ProvisioningProfile = "",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Device", "Simulator", "Any")]
    [string]$TargetDevice = "Device",

    [Parameter(Mandatory = $false)]
    [string]$ProjectPath = "",

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = "",

    [Parameter(Mandatory = $false)]
    [ValidateSet("arm64", "x86_64")]
    [string[]]$Architectures = @("arm64"),

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d+\.\d+$')]
    [string]$DeploymentTarget = "12.0",

    [Parameter(Mandatory = $false)]
    [string]$DevelopmentTeam = "",

    [Parameter(Mandatory = $false)]
    [string]$BundleIdentifier = "com.locojoy.immt3",

    [Parameter(Mandatory = $false)]
    [switch]$Clean,

    [Parameter(Mandatory = $false)]
    [switch]$Archive,

    [Parameter(Mandatory = $false)]
    [switch]$Export,

    [Parameter(Mandatory = $false)]
    [string]$ExportMethod = "development",

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,

    [Parameter(Mandatory = $false)]
    [switch]$StaticGateOnly,

    [Parameter(Mandatory = $false)]
    [switch]$SkipCodeSign
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$showVerbose = ($VerbosePreference -eq 'Continue')

# ============================================================
# 路径解析
# ============================================================
function Get-IOSRepoRoot {
    $scriptRoot = $PSScriptRoot
    if (-not $scriptRoot) {
        $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    }

    $candidates = @(
        $scriptRoot,
        (Join-Path $scriptRoot "../.."),
        (Join-Path $scriptRoot "../../..")
    )

    foreach ($candidate in $candidates) {
        $fireClient = Join-Path $candidate "client/FireClient/FireClient.xcodeproj"
        if (Test-Path $fireClient) {
            return $candidate
        }
    }

    return $null
}

function Get-DefaultProjectPath {
    param([string]$RepoRoot)
    return Join-Path $RepoRoot "client/FireClient/FireClient.xcodeproj"
}

function Get-DefaultOutputDir {
    param(
        [string]$RepoRoot,
        [string]$Configuration
    )
    return Join-Path $RepoRoot "client/ios-build/$Configuration"
}

# ============================================================
# iOS 静态工程门禁
# ============================================================
function Invoke-IOSProjectStaticGate {
    param([string]$RepoRoot)

    $checks = New-Object System.Collections.Generic.List[object]

    function Add-IOSGateCheck {
        param([string]$Name, [bool]$Passed, [string]$Detail)
        $checks.Add([pscustomobject]@{ Name = $Name; Passed = $Passed; Detail = $Detail })
    }

    function Test-IOSPathCheck {
        param([string]$Name, [string]$RelativePath)
        $item = Get-Item -LiteralPath (Join-Path $RepoRoot $RelativePath) -ErrorAction SilentlyContinue
        $passed = ($null -ne $item -and -not $item.PSIsContainer -and $item.Length -gt 0)
        Add-IOSGateCheck -Name $Name -Passed $passed -Detail $RelativePath
    }

    function Read-IOSProjectText {
        param([string]$RelativePath)
        $fullPath = Join-Path $RepoRoot $RelativePath
        if (-not (Test-Path $fullPath)) {
            return $null
        }
        return [IO.File]::ReadAllText($fullPath, [Text.Encoding]::UTF8)
    }

    function Test-IOSProjectPattern {
        param([string]$Name, [string]$RelativePath, [string]$Pattern)
        $text = Read-IOSProjectText $RelativePath
        Add-IOSGateCheck -Name $Name -Passed ($null -ne $text -and $text -match $Pattern) -Detail $Pattern
    }

    function Test-IOSProjectAbsentPattern {
        param([string]$Name, [string]$RelativePath, [string]$Pattern)
        $text = Read-IOSProjectText $RelativePath
        Add-IOSGateCheck -Name $Name -Passed ($null -ne $text -and $text -notmatch $Pattern) -Detail ("must not match: {0}" -f $Pattern)
    }

    function Test-IOSProjectCocosPathsResolve {
        param([string]$Name, [string]$RelativePath)

        $text = Read-IOSProjectText $RelativePath
        if ($null -eq $text) {
            Add-IOSGateCheck -Name $Name -Passed $false -Detail $RelativePath
            return
        }

        $projectBundle = Split-Path -Parent (Join-Path $RepoRoot $RelativePath)
        $projectRoot = Split-Path -Parent $projectBundle
        $pattern = '(?:(?:\$\((?:SRCROOT|PROJECT_DIR)\)/)?(?:\.\./)+)cocos2d-x-2\.2\.6[^"";,\s]*'
        $references = @([regex]::Matches($text, $pattern) | ForEach-Object {
            $_.Value.TrimEnd('/')
        } | Sort-Object -Unique)
        $missing = New-Object System.Collections.Generic.List[string]

        foreach ($reference in $references) {
            $relativeReference = $reference -replace '^\$\((?:SRCROOT|PROJECT_DIR)\)/', ''
            $fullPath = [IO.Path]::GetFullPath((Join-Path $projectRoot $relativeReference))
            if (-not (Test-Path -LiteralPath $fullPath)) {
                $missing.Add($reference)
            }
        }

        $detail = if ($references.Count -eq 0) {
            "no cocos2d-x-2.2.6 references found"
        }
        elseif ($missing.Count -gt 0) {
            "missing: {0}" -f ($missing -join ', ')
        }
        else {
            "{0} unique paths resolved" -f $references.Count
        }
        Add-IOSGateCheck -Name $Name -Passed ($references.Count -gt 0 -and $missing.Count -eq 0) -Detail $detail
    }

    function Test-IOSEngineSpineSourceSet {
        param([string]$RelativePath)

        $text = Read-IOSProjectText $RelativePath
        $spineRoot = Join-Path $RepoRoot "cocos2d-x-2.2.6/extensions/spine"
        $sources = @(Get-ChildItem -LiteralPath $spineRoot -Filter *.cpp -File -ErrorAction SilentlyContinue |
            Sort-Object Name | Select-Object -ExpandProperty Name)
        $missing = New-Object System.Collections.Generic.List[string]

        foreach ($source in $sources) {
            $escaped = [regex]::Escape($source)
            $hasFileReference = $null -ne $text -and $text -match ("path = `"?{0}`"?;" -f $escaped)
            $hasBuildMembership = $null -ne $text -and $text -match ("/\* {0} in Sources \*/" -f $escaped)
            if (-not ($hasFileReference -and $hasBuildMembership)) {
                $missing.Add($source)
            }
        }

        $detail = if ($sources.Count -eq 0) {
            "no Spine C++ sources found"
        }
        elseif ($missing.Count -gt 0) {
            "missing project membership: {0}" -f ($missing -join ', ')
        }
        else {
            "{0} Spine C++ sources included" -f $sources.Count
        }
        Add-IOSGateCheck -Name "engine Spine 2.2.6 source set" -Passed ($sources.Count -gt 0 -and $missing.Count -eq 0) -Detail $detail
    }

    $fireProject = "client/FireClient/FireClient.xcodeproj/project.pbxproj"
    $engineProject = "engine/engine.xcodeproj/project.pbxproj"
    $ceguiProject = "dependencies/cegui/CEGUI.xcodeproj/project.pbxproj"

    Test-IOSPathCheck "FireClient project file" $fireProject
    Test-IOSPathCheck "engine project file" $engineProject
    Test-IOSPathCheck "CEGUI project file" $ceguiProject
    Test-IOSPathCheck "iOS Cocos 2.2.6 project file" "cocos2d-x-2.2.6/cocos2dx/proj.ios/cocos2dx.xcodeproj/project.pbxproj"
    Test-IOSPathCheck "iOS Cocos 2.2.6 public header" "cocos2d-x-2.2.6/cocos2dx/include/cocos2d.h"
    Test-IOSPathCheck "iOS Cocos 2.2.6 Lua header" "cocos2d-x-2.2.6/scripting/lua/lua/lua.h"
    Test-IOSPathCheck "iOS Spine 2.2.6 header" "cocos2d-x-2.2.6/extensions/spine/spine.h"
    Test-IOSPathCheck "iOS Spine 2.2.6 renderer" "cocos2d-x-2.2.6/extensions/spine/CCSkeletonAnimation.cpp"
    Test-IOSPathCheck "iOS FMOD archive" "cocos2d-x-2.2.6/external/fmod/ios/lib/libfmodex_iphoneos.a"
    Test-IOSPathCheck "iOS curl archive" "cocos2d-x-2.2.6/external/curl/prebuilt/ios/libcurl.a"
    Test-IOSPathCheck "FireClient entry" "client/FireClient/FireClient/main.m"
    Test-IOSPathCheck "FireClient delegate" "client/FireClient/FireClient/FireClientAppDelegate.mm"
    Test-IOSPathCheck "FireClient view controller" "client/FireClient/FireClient/FireClientViewController.mm"

    Test-IOSProjectPattern "FireClient target" $fireProject "(?m)^\s*name = FireClient;"
    Test-IOSProjectPattern "FireClient product" $fireProject "(?m)^\s*productName = FireClient;"
    Test-IOSProjectPattern "FireClient CEGUI dependency" $fireProject "path = ../../dependencies/cegui/CEGUI.xcodeproj;"
    Test-IOSProjectPattern "FireClient engine dependency" $fireProject "path = ../../engine/engine.xcodeproj;"
    Test-IOSProjectPattern "FireClient Cocos 2.2.6 root" $fireProject "cocos2d-x-2\.2\.6"
    Test-IOSProjectPattern "FireClient Cocos 2.2.6 Lua root" $fireProject "cocos2d-x-2\.2\.6/scripting/lua"
    Test-IOSProjectPattern "FireClient tolua source" $fireProject "tolua_push\.c in Sources"
    Test-IOSProjectPattern "FireClient published build macro" $fireProject "PUBLISHED_VERSION"
    Test-IOSProjectAbsentPattern "FireClient legacy Cocos root removed" $fireProject "cocos2d-2\.0-rc2-x-2\.0\.1"
    Test-IOSProjectAbsentPattern "FireClient legacy Lua and Spine inputs removed" $fireProject "libluajit|LuaFunctor|tolua_push\.cpp|extensions/libSpine"
    Test-IOSProjectCocosPathsResolve "FireClient Cocos 2.2.6 paths" $fireProject

    Test-IOSProjectPattern "engine target" $engineProject "(?m)^\s*name = engine;"
    Test-IOSProjectPattern "engine product" $engineProject "(?m)^\s*productName = engine;"
    Test-IOSProjectPattern "engine Cocos subproject" $engineProject "cocos2dx\.xcodeproj"
    Test-IOSProjectPattern "engine Cocos 2.2.6 root" $engineProject "cocos2d-x-2\.2\.6"
    Test-IOSProjectPattern "engine Spine 2.2.6 group" $engineProject "cocos2d-x-2\.2\.6/extensions"
    Test-IOSProjectPattern "engine Spine 2.2.6 renderer" $engineProject "CCSkeletonAnimation\.cpp in Sources"
    Test-IOSProjectAbsentPattern "engine legacy Cocos root removed" $engineProject "cocos2d-2\.0-rc2-x-2\.0\.1"
    Test-IOSProjectAbsentPattern "engine legacy Spine layout removed" $engineProject "extensions/libSpine|spine-c/|spine-cocos2dx/include|SkeletonRenderer|PolygonBatch"
    Test-IOSProjectCocosPathsResolve "engine Cocos 2.2.6 paths" $engineProject
    Test-IOSEngineSpineSourceSet $engineProject

    foreach ($target in @(
        "CEGUI",
        "CEGUIBase",
        "CEGUICocos2DRender",
        "CEGUIFalagardWRBase",
        "CEGUIImageCodec",
        "CEGUIXmlParser",
        "CEGUILuaScriptModule"
    )) {
        Test-IOSProjectPattern ("CEGUI target {0}" -f $target) $ceguiProject ("(?m)^\s*name = {0};" -f [regex]::Escape($target))
    }
    Test-IOSProjectPattern "CEGUI Cocos 2.2.6 root" $ceguiProject "cocos2d-x-2\.2\.6"
    Test-IOSProjectPattern "CEGUI Cocos 2.2.6 Lua root" $ceguiProject "cocos2d-x-2\.2\.6/scripting/lua"
    Test-IOSProjectPattern "CEGUI static macro" $ceguiProject "CEGUI_STATIC"
    Test-IOSProjectPattern "CEGUI published build macro" $ceguiProject "PUBLISHED_VERSION"
    Test-IOSProjectAbsentPattern "CEGUI legacy Cocos root removed" $ceguiProject "cocos2d-2\.0-rc2-x-2\.0\.1"
    Test-IOSProjectCocosPathsResolve "CEGUI Cocos 2.2.6 paths" $ceguiProject

    $checkArray = $checks.ToArray()
    $failed = @($checkArray | Where-Object { -not $_.Passed })
    foreach ($check in $checkArray) {
        $state = if ($check.Passed) { "PASS" } else { "FAIL" }
        Write-Host ("[{0}] {1}: {2}" -f $state, $check.Name, $check.Detail)
    }
    Write-Host ("iOS static gate: {0} ({1}/{2} checks passed)" -f $(if ($failed.Count -eq 0) { "PASS" } else { "FAIL" }), ($checks.Count - $failed.Count), $checks.Count)

    if ($failed.Count -gt 0) {
        throw ("iOS static project gate failed: {0} check(s) failed." -f $failed.Count)
    }
}

# ============================================================
# Xcode 构建工具检测
# ============================================================
function Test-XcodeCommandLineTools {
    $xcodeSelect = Get-Command xcode-select -ErrorAction SilentlyContinue
    if (-not $xcodeSelect) {
        return $false
    }

    $version = & xcodebuild -version 2>&1 | Select-Object -First 1
    return ($version -match "Xcode")
}

function Get-XcodeVersion {
    $version = & xcodebuild -version 2>&1 | Select-Object -First 1
    if ($version -match "Xcode (\d+\.\d+)") {
        return $Matches[1]
    }
    return "Unknown"
}

function Get-AvailableSimulators {
    $output = & xcrun simctl list devices available 2>&1 | Out-String
    $simulators = @()

    $lines = $output -split "`n"
    foreach ($line in $lines) {
        if ($line -match "iPhone|iPad") {
            $name = $line.Trim() -replace "\s+--.*", ""
            if (-not [string]::IsNullOrWhiteSpace($name)) {
                $simulators += $name
            }
        }
    }

    return $simulators | Select-Object -Unique
}

function Get-ConnectedDevices {
    $output = & instruments -s devices 2>&1 | Out-String
    $devices = @()

    $lines = $output -split "`n"
    foreach ($line in $lines) {
        if ($line -match "\[.*\]") {
            $name = ($line -split "\[")[0].Trim()
            if (-not [string]::IsNullOrWhiteSpace($name)) {
                $devices += $name
            }
        }
    }

    return $devices | Select-Object -Unique
}

# ============================================================
# 构建命令生成
# ============================================================
function New-XcodebuildCommand {
    param(
        [string]$ProjectPath,
        [string]$Configuration,
        [string]$TargetDevice,
        [string[]]$Architectures,
        [string]$CodeSignIdentity,
        [string]$ProvisioningProfile,
        [bool]$Clean,
        [bool]$Archive,
        [bool]$ShowVerbose,
        [bool]$PlanOnly
    )

    $cmd = "xcodebuild"

    # 项目/工作空间
    if ($ProjectPath -match "\.xcworkspace$") {
        $cmd += " -workspace `"$ProjectPath`""
    }
    elseif ($ProjectPath -match "\.xcodeproj$") {
        $cmd += " -project `"$ProjectPath`""
    }
    else {
        $cmd += " -project `"$ProjectPath`""
    }

    # 目标
    $cmd += " -target FireClient"

    # 配置
    $cmd += " -configuration $Configuration"

    # SDK 和目标设备
    switch ($TargetDevice) {
        "Device" {
            $cmd += " -sdk iphoneos -destination generic/platform=iOS"
        }
        "Simulator" {
            $sims = @()
            if (-not $PlanOnly) {
                $sims = @(Get-AvailableSimulators)
            }
            if ($sims.Count -gt 0) {
                $simId = $sims[0]
                $cmd += " -sdk iphonesimulator -destination `"platform=iOS Simulator,name=$simId`""
            }
            else {
                $cmd += " -sdk iphonesimulator -destination 'platform=iOS Simulator'"
            }
        }
        "Any" {
            $devices = @()
            if (-not $PlanOnly) {
                $devices = @(Get-ConnectedDevices)
            }
            if ($devices.Count -gt 0) {
                $devId = $devices[0]
                $cmd += " -sdk iphoneos -destination `"platform=iOS,name=$devId`""
            }
            else {
                $cmd += " -sdk iphonesimulator -destination 'platform=iOS Simulator'"
            }
        }
    }

    # 架构
    if ($Architectures.Count -gt 0) {
        $archs = $Architectures -join " "
        $cmd += " ONLY_ACTIVE_ARCH=NO ARCHS=`"$archs`""
    }

    # 代码签名
    if (-not [string]::IsNullOrWhiteSpace($CodeSignIdentity)) {
        $cmd += " CODE_SIGN_IDENTITY=`"$CodeSignIdentity`""
    }

    if (-not [string]::IsNullOrWhiteSpace($ProvisioningProfile)) {
        $cmd += " PROVISIONING_PROFILE=`"$ProvisioningProfile`""
    }

    # 构键操作
    if ($Archive) {
        $projectDir = Split-Path -Parent $ProjectPath
        $archivePath = Join-Path $projectDir "build/MT3-$Configuration.xcarchive"
        $cmd += " -archivePath `"$archivePath`""
        $cmd += " archive"
    }
    else {
        if ($Clean) {
            $cmd += " clean"
        }
        $cmd += " build"
    }

    # 输出控制
    if (-not $ShowVerbose) {
        $cmd += " -quiet"
    }
    else {
        $cmd += " VERBOSE=1"
    }

    return $cmd
}

function New-XcodeExportCommand {
    param(
        [string]$ArchivePath,
        [string]$ExportMethod,
        [string]$OutputDir,
        [string]$CodeSignIdentity,
        [string]$ProvisioningProfile
    )

    $cmd = "xcodebuild"

    $cmd += " -exportArchive"
    $cmd += " -archivePath `"$ArchivePath`""
    $cmd += " -exportPath `"$OutputDir`""
    $cmd += " -exportOptionsPlist -"
    $cmd += " <<EOF"
    $cmd += "`n"
    $cmd += "method=$ExportMethod`n"

    if (-not [string]::IsNullOrWhiteSpace($CodeSignIdentity)) {
        $cmd += "signingCertificate=`"$CodeSignIdentity`"`n"
    }

    if (-not [string]::IsNullOrWhiteSpace($ProvisioningProfile)) {
        $cmd += "provisioningProfiles=`"$ProvisioningProfile`"`n"
    }

    $cmd += "EOF"

    return $cmd
}

# ============================================================
# 验证检查
# ============================================================
function Test-IOSBuildPrerequisites {
    param(
        [string]$ProjectPath,
        [string]$CodeSignIdentity,
        [string]$ProvisioningProfile,
        [string]$TargetDevice
    )

    $errors = @()

    # Xcode 检测
    if (-not (Test-XcodeCommandLineTools)) {
        $errors += "Xcode Command Line Tools 未安装或未选择。请运行: sudo xcode-select --install"
    }

    # 项目路径检测
    if (-not (Test-Path $ProjectPath)) {
        $errors += "Xcode 项目未找到: $ProjectPath"
    }

    # 真机打包需要签名
    if ($TargetDevice -eq "Device" -or $TargetDevice -eq "Any") {
        if ([string]::IsNullOrWhiteSpace($CodeSignIdentity)) {
            $errors += "真机打包需要指定 -CodeSignIdentity"
        }
        if ([string]::IsNullOrWhiteSpace($ProvisioningProfile)) {
            $errors += "真机打包需要指定 -ProvisioningProfile"
        }
    }

    return $errors
}

# ============================================================
# 主流程
# ============================================================
$repoRoot = Get-IOSRepoRoot
if (-not $repoRoot) {
    Write-Error "无法找到 MT3 仓库根目录"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    $ProjectPath = Get-DefaultProjectPath -RepoRoot $repoRoot
}

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Get-DefaultOutputDir -RepoRoot $repoRoot -Configuration $Configuration
}

try {
    Invoke-IOSProjectStaticGate -RepoRoot $repoRoot
}
catch {
    Write-Error $_
    exit 1
}

if ($StaticGateOnly) {
    Write-Host "iOS 静态工程门禁完成。" -ForegroundColor Green
    exit 0
}

# 打印配置
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MT3 iOS 构建配置" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  配置    : $Configuration"
Write-Host "  目标    : $TargetDevice"
Write-Host "  项目    : $ProjectPath"
Write-Host "  输出    : $OutputDir"
Write-Host "  签名    : $CodeSignIdentity"
Write-Host "  描述文件: $ProvisioningProfile"
Write-Host "  架构    : $($Architectures -join ', ')"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($WhatIf) {
    $buildCmd = New-XcodebuildCommand -ProjectPath $ProjectPath `
        -Configuration $Configuration `
        -TargetDevice $TargetDevice `
        -Architectures $Architectures `
        -CodeSignIdentity $CodeSignIdentity `
        -ProvisioningProfile $ProvisioningProfile `
        -Clean $Clean.IsPresent `
        -Archive $Archive.IsPresent `
        -ShowVerbose $showVerbose `
        -PlanOnly $true

    Write-Host "构建命令 (WhatIf):" -ForegroundColor Yellow
    Write-Host $buildCmd
    exit 0
}

# 创建输出目录
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# 验证前置条件
$errors = Test-IOSBuildPrerequisites -ProjectPath $ProjectPath `
    -CodeSignIdentity $CodeSignIdentity `
    -ProvisioningProfile $ProvisioningProfile `
    -TargetDevice $TargetDevice

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "构建前检查失败:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  * $_" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "提示:" -ForegroundColor Cyan
    Write-Host "  1. 确保在 macOS 环境下运行此脚本"
    Write-Host "  2. 安装 Xcode Command Line Tools: sudo xcode-select --install"
    Write-Host "  3. 真机打包需要有效的签名证书和描述文件"
    exit 1
}

# 验证 Xcode 版本
$xcodeVersion = Get-XcodeVersion
Write-Host "Xcode 版本: $xcodeVersion" -ForegroundColor Green

# 生成构建命令
$buildCmd = New-XcodebuildCommand -ProjectPath $ProjectPath `
    -Configuration $Configuration `
    -TargetDevice $TargetDevice `
    -Architectures $Architectures `
    -CodeSignIdentity $CodeSignIdentity `
    -ProvisioningProfile $ProvisioningProfile `
    -Clean $Clean.IsPresent `
    -Archive $Archive.IsPresent `
    -ShowVerbose $showVerbose `
    -PlanOnly $false

# 执行构建
Write-Host ""
Write-Host "开始构建..." -ForegroundColor Green

if ($showVerbose) {
    Write-Host "执行: $buildCmd" -ForegroundColor Gray
}

try {
    # 使用 bash 执行 (macOS)
    $output = bash -c $buildCmd 2>&1
    $exitCode = $LASTEXITCODE

    if ($showVerbose) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -ne 0) {
        throw "Xcodebuild 失败 (exit code: $exitCode)"
    }

    # Archive 模式导出
    if ($Archive -and $Export) {
        Write-Host ""
        Write-Host "正在导出 IPA..." -ForegroundColor Green

        $archivePath = Join-Path (Split-Path $ProjectPath -Parent) "build/MT3-$Configuration.xcarchive"
        $exportCmd = New-XcodeExportCommand `
            -ArchivePath $archivePath `
            -ExportMethod $ExportMethod `
            -OutputDir $OutputDir `
            -CodeSignIdentity $CodeSignIdentity `
            -ProvisioningProfile $ProvisioningProfile

        if ($showVerbose) {
            Write-Host "执行: $exportCmd" -ForegroundColor Gray
        }

        $exportOutput = bash -c $exportCmd 2>&1
        $exportExitCode = $LASTEXITCODE

        if ($showVerbose) {
            $exportOutput | ForEach-Object { Write-Host $_ }
        }

        if ($exportExitCode -ne 0) {
            throw "IPA 导出失败 (exit code: $exportExitCode)"
        }
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  构建成功!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green

    # 列出产物
    if (Test-Path $OutputDir) {
        Write-Host ""
        Write-Host "构建产物:" -ForegroundColor Cyan
        Get-ChildItem $OutputDir -File | ForEach-Object {
            Write-Host ("  {0} ({1:N2} KB)" -f $_.Name, ($_.Length / 1KB))
        }
    }

    exit 0
}
catch {
    Write-Host ""
    Write-Host "构建失败: $_" -ForegroundColor Red
    exit 1
}

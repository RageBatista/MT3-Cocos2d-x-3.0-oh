#Requires -Version 5.1
<#
.SYNOPSIS
    MT3 构建环境检测与诊断

.DESCRIPTION
    检测所有平台（Win32/Android/iOS/Server）的构建环境配置
    输出详细的环境状态报告

.EXAMPLE
    .\Test-MT3BuildEnvironment.ps1
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Win32", "Android", "Server", "All")]
    [string[]]$Platform = @("All"),

    [Parameter(Mandatory = $false)]
    [switch]$Verbose,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ""
)

$ErrorActionPreference = 'Continue'
Set-StrictMode -Version Latest

# 输出颜色定义
$colors = @{
    Success = [ConsoleColor]::Green
    Warning = [ConsoleColor]::Yellow
    Error   = [ConsoleColor]::Red
    Info    = [ConsoleColor]::Cyan
    Header  = [ConsoleColor]::Magenta
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor $colors.Header
    Write-Host "  $Title" -ForegroundColor $colors.Header
    Write-Host ("=" * 70) -ForegroundColor $colors.Header
}

function Write-CheckResult {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Detail = "",
        [string]$Fix = ""
    )

    $icon = if ($Passed) { "[PASS]" } else { "[FAIL]" }
    $color = if ($Passed) { $colors.Success } else { $colors.Error }

    Write-Host "$icon " -NoNewline -ForegroundColor $color
    Write-Host $Name -NoNewline
    if (-not [string]::IsNullOrEmpty($Detail)) {
        Write-Host " - $Detail" -ForegroundColor DarkGray
    }

    if (-not $Passed -and -not [string]::IsNullOrEmpty($Fix)) {
        Write-Host "       Fix: $Fix" -ForegroundColor Yellow
    }
}

function Get-VS120Status {
    $results = @()

    # VS120COMNTOOLS
    $found = $env:VS120COMNTOOLS
    if (-not $found) {
        foreach ($p in @("D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\",
                         "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\")) {
            if (Test-Path $p) { $found = $p; break }
        }
    }

    $results += @{
        Name = "VS120COMNTOOLS"
        Description = "Visual Studio 2013 工具路径"
        Passed = ($null -ne $found)
        Value = $found
        Fix = "设置 VS120COMNTOOLS 环境变量或安装 VS2013"
    }

    # vcvarsall.bat
    $vcvarsFound = $null
    if ($env:VS120COMNTOOLS) {
        $vcvars = Join-Path $env:VS120COMNTOOLS "..\..\VC\vcvarsall.bat"
        if (Test-Path $vcvars) { $vcvarsFound = $vcvars }
    }

    $results += @{
        Name = "vcvarsall.bat"
        Description = "VS2013 VC 环境配置脚本"
        Passed = ($null -ne $vcvarsFound)
        Value = $vcvarsFound
        Fix = "验证 VS2013 安装完整性"
    }

    # MSBuild 12.0
    $msbuild = $env:MT3_MSBUILD_PATH
    if (-not $msbuild) {
        foreach ($p in @("D:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe",
                         "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe")) {
            if (Test-Path $p) { $msbuild = $p; break }
        }
    }

    $version = $null
    if ($msbuild -and (Test-Path $msbuild)) {
        $ver = & $msbuild /version /nologo 2>&1 | Select-Object -First 1
        if ($ver -match '(\d+\.\d+)') { $version = $Matches[1] }
    }

    $results += @{
        Name = "MSBuild 12.0"
        Description = "MSBuild 编译工具"
        Passed = ($version -and $version.StartsWith("12."))
        Value = "$msbuild ($version)"
        Fix = "安装 VS2013 Build Tools 或设置 MT3_MSBUILD_PATH"
    }

    # VCRedist
    $vcrFound = $null
    foreach ($p in @("D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x86\Microsoft.VC120.CRT",
                     "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x86\Microsoft.VC120.CRT")) {
        if (Test-Path $p) {
            $vcrFound = Get-ChildItem $p -Filter "msvcr120.dll" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($vcrFound) { $vcrFound = $vcrFound.FullName; break }
        }
    }

    $results += @{
        Name = "VCRedist x86"
        Description = "MSVC 2013 运行时库"
        Passed = ($null -ne $vcrFound)
        Value = $vcrFound
        Fix = "安装 VS2013 Redistributable"
    }

    return $results
}

function Get-AndroidStatus {
    $results = @()

    # Android SDK
    $sdk = $null
    foreach ($e in @("ANDROID_HOME", "ANDROID_SDK_ROOT")) {
        $v = [Environment]::GetEnvironmentVariable($e)
        if ($v -and (Test-Path $v)) { $sdk = $v; break }
    }
    if (-not $sdk) {
        foreach ($p in @("D:\android-sdk_r24.1.2-windows\android-sdk-windows",
                         "D:\Android\android-sdk-windows",
                         "D:\Android\android-sdk-64")) {
            if (Test-Path $p) { $sdk = $p; break }
        }
    }

    # 验证 SDK 组件
    $sdkValid = $false
    if ($sdk) {
        $aapt = Join-Path $sdk "build-tools\22.0.1\aapt.exe"
        $adb = Join-Path $sdk "platform-tools\adb.exe"
        $antBuild = Join-Path $sdk "tools\ant\build.xml"
        $sdkValid = (Test-Path $aapt) -and (Test-Path $adb) -and (Test-Path $antBuild)
    }

    $results += @{
        Name = "Android SDK"
        Description = "Android SDK (API 22, build-tools 22.0.1)"
        Passed = $sdkValid
        Value = $sdk
        Fix = "安装 Android SDK r24.1.2，设置 ANDROID_HOME"
    }

    # Android NDK
    $ndk = $null
    foreach ($e in @("ANDROID_NDK_HOME", "NDK_HOME")) {
        $v = [Environment]::GetEnvironmentVariable($e)
        if ($v) {
            $ndkBuild = Join-Path $v "ndk-build.cmd"
            if (Test-Path $ndkBuild) { $ndk = $ndkBuild; break }
        }
    }
    if (-not $ndk) {
        foreach ($p in @("D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd",
                         "D:\Android\ndk\16.1.4479499\ndk-build.cmd")) {
            if (Test-Path $p) { $ndk = $p; break }
        }
    }

    $ndkValid = $false
    $ndkVersion = $null
    if ($ndk -and (Test-Path $ndk)) {
        $ndkDir = Split-Path (Split-Path $ndk -Parent) -Parent
        $sourceProps = Join-Path $ndkDir "source.properties"
        if (Test-Path $sourceProps) {
            $content = Get-Content $sourceProps -Raw
            if ($content -match 'Pkg\.Revision\s*=\s*(\d+\.\d+\.\d+)') {
                $ndkVersion = $Matches[1]
                $ndkValid = $ndkVersion.StartsWith("16.")
            }
        }
    }

    $results += @{
        Name = "Android NDK r16"
        Description = "Android NDK (16.1.4479499, clang)"
        Passed = $ndkValid
        Value = "$ndk ($ndkVersion)"
        Fix = "安装 NDK r16，设置 ANDROID_NDK_HOME"
    }

    # JDK 8
    $jdk = $null
    foreach ($e in @("JAVA_HOME")) {
        $v = [Environment]::GetEnvironmentVariable($e)
        if ($v) {
            $javaExe = Join-Path $v "bin\java.exe"
            if (Test-Path $javaExe) {
                $jv = & $javaExe -version 2>&1 | Select-Object -First 1
                if ($jv -match '1\.8\.') { $jdk = $v; break }
            }
        }
    }
    if (-not $jdk) {
        foreach ($p in @("C:\Program Files\Java\jdk1.8.0_144",
                         "C:\Program Files\Java\jdk1.8.0_202",
                         "C:\Program Files\Java\jdk8")) {
            if (Test-Path (Join-Path $p "bin\java.exe")) {
                $jdk = $p; break
            }
        }
    }

    $jdkValid = $null -ne $jdk

    $results += @{
        Name = "JDK 8 (Android)"
        Description = "JDK 1.8.x (JDK9+ 不兼容)"
        Passed = $jdkValid
        Value = $jdk
        Fix = "安装 JDK 8，设置 JAVA_HOME"
    }

    # Ant
    $ant = $null
    foreach ($e in @("ANT_HOME")) {
        $v = [Environment]::GetEnvironmentVariable($e)
        if ($v) {
            $antBat = Join-Path $v "bin\ant.bat"
            if (Test-Path $antBat) { $ant = $antBat; break }
        }
    }
    if (-not $ant) {
        foreach ($p in @("D:\apache-ant-1.9.7\bin\ant.bat")) {
            if (Test-Path $p) { $ant = $p; break }
        }
    }

    $results += @{
        Name = "Apache Ant"
        Description = "Ant 构建工具 (1.9+)"
        Passed = ($null -ne $ant)
        Value = $ant
        Fix = "安装 Apache Ant 1.9+，设置 ANT_HOME"
    }

    return $results
}

function Get-ServerStatus {
    $results = @()

    # JDK for Server
    $jdk = $env:JAVA_HOME
    if (-not $jdk) {
        foreach ($p in @("C:\Program Files\Java\jdk1.7.0_80",
                         "C:\Program Files\Java\jdk1.8.0_144")) {
            if (Test-Path (Join-Path $p "bin\java.exe")) {
                $jdk = $p; break
            }
        }
    }

    $jdkValid = $false
    $jdkVersion = $null
    if ($jdk) {
        $javaExe = Join-Path $jdk "bin\java.exe"
        if (Test-Path $javaExe) {
            $jv = & $javaExe -version 2>&1 | Select-Object -First 1
            if ($jv -match '1\.([78])\.') {
                $jdkVersion = $Matches[0].Trim('"')
                $jdkValid = $true
            }
        }
    }

    $results += @{
        Name = "JDK 1.7/1.8 (Server)"
        Description = "服务器 JDK (JDK9+ 不兼容)"
        Passed = $jdkValid
        Value = "$jdk ($jdkVersion)"
        Fix = "安装 JDK 1.7/1.8，设置 JAVA_HOME"
    }

    # Ant
    $ant = $null
    foreach ($e in @("ANT_HOME")) {
        $v = [Environment]::GetEnvironmentVariable($e)
        if ($v) {
            $antBat = Join-Path $v "bin\ant.bat"
            if (Test-Path $antBat) { $ant = $antBat; break }
        }
    }
    if (-not $ant) {
        foreach ($p in @("D:\apache-ant-1.9.7\bin\ant.bat")) {
            if (Test-Path $p) { $ant = $p; break }
        }
    }

    $results += @{
        Name = "Apache Ant"
        Description = "Ant 构建工具 (1.9+)"
        Passed = ($null -ne $ant)
        Value = $ant
        Fix = "安装 Apache Ant 1.9+"
    }

    return $results
}

# 主流程
Write-Section "MT3 构建环境检测报告"
Write-Host "检测时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "主机名:   $env:COMPUTERNAME"

$allResults = @()
$passCount = 0
$failCount = 0

# Win32 检测
if ($Platform -contains "Win32" -or $Platform -contains "All") {
    Write-Section "Win32 客户端环境"
    $win32Results = Get-VS120Status
    foreach ($r in $win32Results) {
        Write-CheckResult -Name $r.Name -Passed $r.Passed -Detail $r.Value -Fix $r.Fix
        $allResults += $r
        if ($r.Passed) { $passCount++ } else { $failCount++ }
    }
}

# Android 检测
if ($Platform -contains "Android" -or $Platform -contains "All") {
    Write-Section "Android 客户端环境"
    $androidResults = Get-AndroidStatus
    foreach ($r in $androidResults) {
        Write-CheckResult -Name $r.Name -Passed $r.Passed -Detail $r.Value -Fix $r.Fix
        $allResults += $r
        if ($r.Passed) { $passCount++ } else { $failCount++ }
    }
}

# Server 检测
if ($Platform -contains "Server" -or $Platform -contains "All") {
    Write-Section "服务器环境"
    $serverResults = Get-ServerStatus
    foreach ($r in $serverResults) {
        Write-CheckResult -Name $r.Name -Passed $r.Passed -Detail $r.Value -Fix $r.Fix
        $allResults += $r
        if ($r.Passed) { $passCount++ } else { $failCount++ }
    }
}

# 总结
Write-Section "检测总结"
$passRate = if ($allResults.Count -gt 0) { [Math]::Round($passCount / $allResults.Count * 100, 1) } else { 0 }
Write-Host "通过: $passCount / $($allResults.Count) ($passRate%)"
if ($failCount -gt 0) {
    Write-Host ""
    Write-Host "以下项目未通过检测:" -ForegroundColor $colors.Warning
    $allResults | Where-Object { -not $_.Passed } | ForEach-Object {
        Write-Host "  * $($_.Name): $($_.Fix)" -ForegroundColor Yellow
    }
}

# 输出报告
if (-not [string]::IsNullOrEmpty($OutputPath)) {
    $report = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Host = $env:COMPUTERNAME
        Summary = @{
            Total = $allResults.Count
            Passed = $passCount
            Failed = $failCount
            PassRate = $passRate
        }
        Results = $allResults
    }
    $report | ConvertTo-Json -Depth 4 | Set-Content -Path $OutputPath -Encoding UTF8
    Write-Host ""
    Write-Host "报告已保存: $OutputPath" -ForegroundColor $colors.Info
}

exit $(if ($failCount -eq 0) { 0 } else { 1 })

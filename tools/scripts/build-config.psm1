# MT3 构建环境配置
# 此文件集中管理所有工具链路径，支持环境变量覆盖
# 版本: 1.0.0 | 更新: 2026-07-16

# ============================================================
# 工具链版本约束 (禁止修改)
# ============================================================
@{
    # Windows 客户端
    Win32_Toolset = "v120"
    Win32_MSBuild_Version = "12.0"
    Win32_Solution = "FireClient.sln"

    # Android 客户端
    Android_NDK_Version = "r16"
    Android_NDK_Revision = "16.1.4479499"
    Android_API_Level = "22"
    Android_BuildTools_Version = "22.0.1"
    Android_ABI = "arm64-v8a"
    Android_JDK_Min = "1.8"
    Android_JDK_Max = "1.8"  # JDK9+ 不兼容

    # 服务器端
    Server_JDK_Min = "1.7"
    Server_JDK_Max = "1.8"
}

# ============================================================
# 默认路径配置 (可自定义修改)
# ============================================================
# 优先级: 环境变量 > 用户配置 > 默认路径

function Get-MT3BuildConfig {
    param(
        [string]$ConfigFile = ""
    )

    $config = @{}

    # 默认硬编码路径 (回退用)
    $defaultPaths = @{
        # VS2013 路径
        VS120COMNTOOLS = @(
            "D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\",
            "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\"
        )
        MSBuild12 = @(
            "D:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe",
            "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe"
        )
        VS120VCVars = @(
            "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat",
            "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
        )
        VS120Dumpbin = @(
            "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\dumpbin.exe",
            "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\dumpbin.exe"
        )
        VCRedist_x86 = @(
            "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x86\Microsoft.VC120.CRT\",
            "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x86\Microsoft.VC120.CRT\"
        )

        # Android SDK 路径
        AndroidSDK = @(
            "D:\android-sdk_r24.1.2-windows\android-sdk-windows",
            "D:\Android\android-sdk-windows",
            "D:\Android\android-sdk-64",
            "C:\Android\sdk"
        )
        AndroidNDK = @(
            "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd",
            "D:\Android\ndk\16.1.4479499\ndk-build.cmd",
            "C:\Android\ndk\16.1.4479499\ndk-build.cmd"
        )
        AndroidJDK = @(
            "C:\Program Files\Java\jdk1.8.0_144",
            "C:\Program Files\Java\jdk1.8.0_202",
            "C:\Program Files\Java\jdk8"
        )
        ApacheAnt = @(
            "D:\apache-ant-1.9.7\bin\ant.bat",
            "C:\apache-ant-1.9.7\bin\ant.bat"
        )

        # 服务器 JDK
        ServerJDK = @(
            "C:\Program Files\Java\jdk1.7.0_80",
            "C:\Program Files\Java\jdk1.8.0_144",
            "C:\Program Files\Java\jdk8"
        )
    }

    # 环境变量映射
    $envMapping = @{
        "VS120COMNTOOLS" = @("VS120COMNTOOLS")
        "MSBuild12" = @("MT3_MSBUILD_PATH")
        "AndroidSDK" = @("ANDROID_HOME", "ANDROID_SDK_ROOT")
        "AndroidNDK" = @("ANDROID_NDK_HOME", "NDK_HOME")
        "AndroidJDK" = @("JAVA_HOME")
        "ApacheAnt" = @("ANT_HOME")
        "ServerJDK" = @("JAVA_HOME")
    }

    # 加载用户配置
    if ([string]::IsNullOrEmpty($ConfigFile)) {
        $ConfigFile = Join-Path $PSScriptRoot "..\..\build-config.json"
    }

    $userConfig = @{}
    if (Test-Path $ConfigFile) {
        try {
            $userConfig = Get-Content $ConfigFile -Raw | ConvertFrom-Json -AsHashtable
        }
        catch {
            Write-Warning "Failed to load build config: $ConfigFile"
        }
    }

    # 解析路径 (优先级: 环境变量 > 用户配置 > 默认路径)
    foreach ($key in $defaultPaths.Keys) {
        $resolved = $null

        # 1. 环境变量
        if ($envMapping.ContainsKey($key)) {
            foreach ($envName in $envMapping[$key]) {
                $value = [Environment]::GetEnvironmentVariable($envName)
                if (-not [string]::IsNullOrWhiteSpace($value)) {
                    if ($key -eq "AndroidNDK") {
                        $value = Join-Path $value "ndk-build.cmd"
                    }
                    elseif ($key -eq "ApacheAnt") {
                        $value = Join-Path $value "bin\ant.bat"
                    }
                    $resolved = $value
                    break
                }
            }
        }

        # 2. 用户配置
        if (-not $resolved -and $userConfig.ContainsKey($key)) {
            $value = $userConfig[$key]
            if (Test-Path $value) {
                $resolved = $value
            }
        }

        # 3. 默认路径
        if (-not $resolved) {
            foreach ($candidate in $defaultPaths[$key]) {
                if (Test-Path $candidate) {
                    $resolved = $candidate
                    break
                }
            }
        }

        $config[$key] = $resolved
    }

    return $config
}

function Test-MT3BuildEnvironment {
    <#
    .SYNOPSIS
        验证构建环境完整性
    #>
    param(
        [string]$ConfigFile = ""
    )

    $config = Get-MT3BuildConfig -ConfigFile $ConfigFile
    $results = @()

    # Win32 检查
    $results += @{
        Name = "VS2013 v120 Toolset"
        Status = ($config.VS120COMNTOOLS -ne $null)
        Detail = $config.VS120COMNTOOLS
    }

    $results += @{
        Name = "MSBuild 12.0"
        Status = ($config.MSBuild12 -ne $null)
        Detail = $config.MSBuild12
    }

    # Android 检查
    $results += @{
        Name = "Android SDK (API 22)"
        Status = ($config.AndroidSDK -ne $null)
        Detail = $config.AndroidSDK
    }

    $results += @{
        Name = "Android NDK r16"
        Status = ($config.AndroidNDK -ne $null)
        Detail = $config.AndroidNDK
    }

    $results += @{
        Name = "JDK 8 (Android)"
        Status = ($config.AndroidJDK -ne $null)
        Detail = $config.AndroidJDK
    }

    # 服务器检查
    $results += @{
        Name = "JDK 1.7/1.8 (Server)"
        Status = ($config.ServerJDK -ne $null)
        Detail = $config.ServerJDK
    }

    $results += @{
        Name = "Apache Ant"
        Status = ($config.ApacheAnt -ne $null)
        Detail = $config.ApacheAnt
    }

    return $results
}

# 导出函数 (PowerShell 5.1 兼容)
if ($MyInvocation.MyCommand.ScriptBlock) {
    Export-ModuleMember -Function Get-MT3BuildConfig, Test-MT3BuildEnvironment
}

# MT3 构建环境配置
# 此文件集中管理所有工具链路径，支持环境变量覆盖
# 版本: 1.1.0 | 更新: 2026-08-05

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

function Get-MT3Win32ProjectManifest {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [ValidateSet("Legacy226", "Upgrade30")][string]$EngineProfile = "Upgrade30",
        [switch]$IncludeFinalExecutable
    )

    $relativeSteps = @(
        @{ Name = "platform"; RelativePath = "common\platform\platform.win32.vcxproj" },
        @{ Name = "ljfm"; RelativePath = "common\ljfm\ljfm.win32.vcxproj" },
        @{ Name = "cauthc"; RelativePath = "common\cauthc\projects\windows\cauthc.win32.vcxproj" }
    )

    if ($EngineProfile -eq "Upgrade30") {
        $relativeSteps += @(
            @{ Name = "cocos30_kazmath"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\math\kazmath\kazmath\kazmath.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_tinyxml2"; RelativePath = "cocos2d-x-3.0-oh\build\external\tinyxml2\tinyxml2.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_unzip"; RelativePath = "cocos2d-x-3.0-oh\build\external\unzip\unzip.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_xxhash"; RelativePath = "cocos2d-x-3.0-oh\build\external\xxhash\xxhash.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_chipmunk"; RelativePath = "cocos2d-x-3.0-oh\build\external\chipmunk\src\chipmunk_static.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_box2d"; RelativePath = "cocos2d-x-3.0-oh\build\external\Box2D\box2d.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_lua"; RelativePath = "cocos2d-x-3.0-oh\build\external\lua\lua\lua.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_tolua"; RelativePath = "cocos2d-x-3.0-oh\build\external\lua\tolua\tolua.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_luasocket"; RelativePath = "cocos2d-x-3.0-oh\build\external\lua\luasocket\ext_luasocket.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_base"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\base\cocosbase.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_core"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\2d\cocos2d.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_audio"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\audio\audio.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_spine"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\editor-support\spine\spine.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_extensions"; RelativePath = "cocos2d-x-3.0-oh\build\extensions\extensions.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_network"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\network\network.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_sqlite3"; RelativePath = "cocos2d-x-3.0-oh\build\external\sqlite3\sqlite3.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_storage"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\storage\storage.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_ui"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\ui\ui.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_cocostudio"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\editor-support\cocostudio\cocostudio.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_cocosbuilder"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\editor-support\cocosbuilder\cocosbuilder.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "cocos30_luabinding"; RelativePath = "cocos2d-x-3.0-oh\build\cocos\scripting\lua-bindings\luabinding.vcxproj"; DisableProjectReferences = $true },
            @{ Name = "CEGUI079"; RelativePath = "tools\CEGUI-0.7.9-r5\cegui-0.7.9.win32.vcxproj" },
            @{ Name = "engine"; RelativePath = "engine\engine.win32.vcxproj" },
            @{ Name = "FireClient"; RelativePath = "client\MT3Win32App\FireClient.win32.vcxproj"; DisableProjectReferences = $true }
        )
    } else {
        $relativeSteps += @(
            @{ Name = "libBox2D"; RelativePath = "cocos2d-x-2.2.6\external\Box2D\proj.win32\Box2D.vcxproj" },
            @{ Name = "libchipmunk"; RelativePath = "cocos2d-x-2.2.6\external\chipmunk\proj.win32\chipmunk.vcxproj" },
            @{ Name = "liblua"; RelativePath = "cocos2d-x-2.2.6\scripting\lua\proj.win32\liblua.vcxproj" },
            @{ Name = "cocos2d"; RelativePath = "cocos2d-x-2.2.6\cocos2dx\proj.win32\cocos2d.vcxproj" },
            @{ Name = "CocosDenshion"; RelativePath = "cocos2d-x-2.2.6\CocosDenshion\proj.win32\CocosDenshion.vcxproj" },
            @{ Name = "libExtensions"; RelativePath = "cocos2d-x-2.2.6\extensions\proj.win32\libExtensions.vcxproj" },
            @{ Name = "CEGUI"; RelativePath = "dependencies\cegui\project\win32\cegui.win32.vcxproj" },
            @{ Name = "engine"; RelativePath = "engine\engine.win32.vcxproj" },
            @{ Name = "FireClient"; RelativePath = "client\MT3Win32App\FireClient.win32.vcxproj"; DisableProjectReferences = $true }
        )
    }

    if ($IncludeFinalExecutable) {
        $relativeSteps += @{
            Name = "MT3"
            RelativePath = "client\MT3Win32App\mt3.win32.vcxproj"
            DisableProjectReferences = $true
        }
    }

    return @(
        $relativeSteps | ForEach-Object {
            @{
                Name = $_.Name
                RelativePath = $_.RelativePath
                Path = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $_.RelativePath))
                DisableProjectReferences = ($_.ContainsKey("DisableProjectReferences") -and [bool]$_.DisableProjectReferences)
            }
        }
    )
}

# 导出函数 (PowerShell 5.1 兼容)
if ($MyInvocation.MyCommand.ScriptBlock) {
    Export-ModuleMember -Function Get-MT3BuildConfig, Test-MT3BuildEnvironment, Get-MT3Win32ProjectManifest
}

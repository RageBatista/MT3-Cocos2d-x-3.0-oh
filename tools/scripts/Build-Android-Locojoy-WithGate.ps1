param(
    [string]$ProjectDir = "client/android/LocojoyProject",
    [ValidateSet("Legacy226", "Upgrade30")]
    [string]$EngineProfile = "Upgrade30",
    [ValidateSet("free", "monthpayment")]
    [string]$Channel = "free",
    [Alias("Target")]
    [ValidateSet("Debug", "Release")]
    [string]$BuildType = "Release",
    [int]$Jobs = 4,
    [switch]$Clean,
    [switch]$CleanIntermediates,
    [switch]$SyncRes,
    [string]$ResSourceDir = "client/res_android/res",
    [string]$NdkBuildPath = "",
    [string]$AntPath = "",
    [string]$JdkHome = "",
    [string]$AndroidSdkRoot = "",
    [string]$Arm64SourceDir = "",
    [switch]$PrepareArm64,
    [switch]$ForceV7aOnly,
    [switch]$NativeDebug,
    [switch]$SkipNativeBuild,
    [switch]$SkipPackage,
    [switch]$RequireArm64InApk,
    [string[]]$RequiredArm64Libs = @("libgame.so", "libc++_shared.so", "libdu.so", "liblocSDK6a.so"),
    [switch]$HydrateLfs,
    [switch]$NoLfsCheck,
    [switch]$PlanOnly,
    [switch]$Json,
    [string]$KeystorePath = "",
    [string]$KeyAlias = "",
    [string]$KeystorePassword = "",
    [string]$KeyAliasPassword = "",
    [switch]$AllowInteractiveSigning
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    try {
        $root = (& git rev-parse --show-toplevel 2>$null)
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($root)) {
            return (Resolve-Path -LiteralPath $root.Trim()).Path
        }
    }
    catch {
        # Fall back to the current directory.
    }

    return (Resolve-Path ".").Path
}

function Get-CommandText {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @()
    )

    try {
        return [string]::Join(" ", @(& $FilePath @Arguments 2>&1))
    }
    catch {
        return $_.Exception.Message
    }
}

function Get-EnvOrEmpty {
    param([Parameter(Mandatory = $true)][string]$Name)

    foreach ($scope in @("Process", "User", "Machine")) {
        $value = [Environment]::GetEnvironmentVariable($Name, $scope)
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value
        }
    }

    return ""
}

function Test-AndroidSdkForAnt {
    param([string]$SdkRoot)

    if ([string]::IsNullOrWhiteSpace($SdkRoot) -or -not (Test-Path -LiteralPath $SdkRoot -PathType Container)) {
        return $false
    }

    $required = @(
        "tools\ant\build.xml",
        "platform-tools\adb.exe",
        "build-tools\22.0.1\aapt.exe",
        "build-tools\22.0.1\zipalign.exe",
        "platforms\android-22\android.jar"
    )

    foreach ($relative in $required) {
        if (-not (Test-Path -LiteralPath (Join-Path $SdkRoot $relative) -PathType Leaf)) {
            return $false
        }
    }

    return $true
}

function Resolve-AndroidSdkRoot {
    param([string]$UserPath)

    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($UserPath)) {
        $candidates += $UserPath
    }

    foreach ($name in @("ANDROID_HOME", "ANDROID_SDK_ROOT")) {
        $value = Get-EnvOrEmpty -Name $name
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            $candidates += $value
        }
    }

    $candidates += @(
        "D:\android-sdk_r24.1.2-windows\android-sdk-windows",
        "D:\Android\android-sdk-windows",
        "D:\Android\android-sdk-64"
    )

    foreach ($candidate in $candidates) {
        if (Test-AndroidSdkForAnt -SdkRoot $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "Android SDK for Ant build not found. Required: tools\ant\build.xml, platform-tools, build-tools\22.0.1 and platforms\android-22."
}

function Resolve-Jdk8Home {
    param([string]$UserPath)

    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($UserPath)) {
        $candidates += $UserPath
    }

    $envJavaHome = Get-EnvOrEmpty -Name "JAVA_HOME"
    if (-not [string]::IsNullOrWhiteSpace($envJavaHome)) {
        $candidates += $envJavaHome
    }

    $candidates += @(
        "C:\Program Files\Java\jdk1.8.0_144",
        "C:\Program Files\Java\jdk1.8.0_202",
        "C:\Program Files\Java\jdk8"
    )

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        $java = Join-Path $candidate "bin\java.exe"
        $javac = Join-Path $candidate "bin\javac.exe"
        if ((Test-Path -LiteralPath $java -PathType Leaf) -and (Test-Path -LiteralPath $javac -PathType Leaf)) {
            $javaVersion = Get-CommandText -FilePath $java -Arguments @("-version")
            $javacVersion = Get-CommandText -FilePath $javac -Arguments @("-version")
            if ($javaVersion -match 'version "1\.8\.' -and $javacVersion -match 'javac 1\.8\.') {
                return (Resolve-Path -LiteralPath $candidate).Path
            }
        }
    }

    throw "JDK8 is required for Android Ant/dx build. JDK9+ is not supported by this legacy Ant chain."
}

function Use-Jdk8ForCurrentProcess {
    param([Parameter(Mandatory = $true)][string]$ResolvedJdkHome)

    $jdkBin = Join-Path $ResolvedJdkHome "bin"
    $pathEntries = @($env:Path -split ";" | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_) -and
        $_ -notmatch "(?i)Common Files\\Oracle\\Java\\javapath" -and
        $_ -notmatch "(?i)ProgramData\\Oracle\\Java\\javapath" -and
        $_ -notmatch "(?i)jdk-17" -and
        $_ -notmatch "(?i)jdk-21"
    })

    $env:JAVA_HOME = $ResolvedJdkHome
    $env:Path = (@($jdkBin) + $pathEntries | Select-Object -Unique) -join ";"
}

function Resolve-NdkBuildPath {
    param([string]$UserPath)

    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($UserPath)) {
        $candidates += $UserPath
    }

    $candidates += "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd"

    foreach ($name in @("ANDROID_NDK_HOME", "NDK_HOME")) {
        $value = Get-EnvOrEmpty -Name $name
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            $candidates += (Join-Path $value "ndk-build.cmd")
        }
    }

    foreach ($candidate in $candidates) {
        if (-not [string]::IsNullOrWhiteSpace($candidate) -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $cmd = Get-Command ndk-build.cmd -ErrorAction SilentlyContinue
    if ($cmd -and (Test-Path -LiteralPath $cmd.Source -PathType Leaf)) {
        return $cmd.Source
    }

    throw "NDK r16 ndk-build.cmd not found. Pass -NdkBuildPath or install D:\Android\android-sdk-64\ndk\16.1.4479499."
}

function Get-NdkRevision {
    param([Parameter(Mandatory = $true)][string]$NdkBuildPath)

    $ndkRoot = Split-Path -Parent $NdkBuildPath
    $sourceProperties = Join-Path $ndkRoot "source.properties"
    if (Test-Path -LiteralPath $sourceProperties -PathType Leaf) {
        foreach ($line in @(Get-Content -Encoding UTF8 -LiteralPath $sourceProperties)) {
            if ($line -match '^\s*Pkg\.Revision\s*=\s*(.+?)\s*$') {
                return $matches[1]
            }
        }
    }

    if ($ndkRoot -match '(\d+\.\d+\.\d+)') {
        return $matches[1]
    }

    return ""
}

function Assert-NdkR16 {
    param([Parameter(Mandatory = $true)][string]$NdkBuildPath)

    $revision = Get-NdkRevision -NdkBuildPath $NdkBuildPath
    if ([string]::IsNullOrWhiteSpace($revision) -or -not $revision.StartsWith("16.", [System.StringComparison]::Ordinal)) {
        throw "Android native build is pinned to NDK r16 for arm64-v8a. Current ndk-build: $NdkBuildPath, revision: '$revision'."
    }

    return $revision
}

function Resolve-AntPath {
    param([string]$UserPath)

    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($UserPath)) {
        $candidates += $UserPath
    }

    $antHome = Get-EnvOrEmpty -Name "ANT_HOME"
    if (-not [string]::IsNullOrWhiteSpace($antHome)) {
        $candidates += (Join-Path $antHome "bin\ant.bat")
    }

    $candidates += "D:\apache-ant-1.9.7\bin\ant.bat"

    foreach ($candidate in $candidates) {
        if (-not [string]::IsNullOrWhiteSpace($candidate) -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $cmd = Get-Command ant.bat -ErrorAction SilentlyContinue
    if ($cmd -and (Test-Path -LiteralPath $cmd.Source -PathType Leaf)) {
        return $cmd.Source
    }

    throw "ant.bat not found. Pass -AntPath or set ANT_HOME."
}

function Read-AndroidProperties {
    param([Parameter(Mandatory = $true)][string]$Path)

    $result = [ordered]@{}
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $result
    }

    $lines = Get-Content -Encoding UTF8 -LiteralPath $Path
    foreach ($line in $lines) {
        if ($line -match '^\s*#') {
            continue
        }
        if ($line -match '^\s*([^=]+?)\s*=\s*(.*?)\s*$') {
            $result[$matches[1]] = $matches[2]
        }
    }

    return $result
}

function Get-AndroidLibraryProjectDirs {
    param([Parameter(Mandatory = $true)][string]$ProjectPropertiesPath)

    $result = @()
    if (-not (Test-Path -LiteralPath $ProjectPropertiesPath -PathType Leaf)) {
        return $result
    }

    $baseDir = Split-Path -Parent $ProjectPropertiesPath
    $props = Read-AndroidProperties -Path $ProjectPropertiesPath
    foreach ($key in $props.Keys) {
        if ($key -match '^android\.library\.reference\.\d+$') {
            $candidate = Join-Path $baseDir $props[$key]
            if (Test-Path -LiteralPath $candidate -PathType Container) {
                $result += (Resolve-Path -LiteralPath $candidate).Path
            }
        }
    }

    return @($result | Select-Object -Unique)
}

function Get-GradleProjectFiles {
    param([Parameter(Mandatory = $true)][string]$AndroidRoot)

    if (-not (Test-Path -LiteralPath $AndroidRoot -PathType Container)) {
        return @()
    }

    $candidateDirs = New-Object System.Collections.Generic.List[string]
    $root = (Resolve-Path -LiteralPath $AndroidRoot).Path
    $candidateDirs.Add($root)

    foreach ($moduleDir in @(Get-ChildItem -LiteralPath $root -Directory -Force -ErrorAction SilentlyContinue)) {
        $candidateDirs.Add($moduleDir.FullName)
        foreach ($configDir in @(Get-ChildItem -LiteralPath $moduleDir.FullName -Directory -Force -ErrorAction SilentlyContinue)) {
            if ($configDir.Name -in @("gradle", "buildSrc")) {
                $candidateDirs.Add($configDir.FullName)
            }
        }
    }

    $result = New-Object System.Collections.Generic.List[string]
    foreach ($dir in $candidateDirs) {
        foreach ($name in @("build.gradle", "settings.gradle", "gradlew", "gradlew.bat")) {
            $path = Join-Path $dir $name
            if (Test-Path -LiteralPath $path -PathType Leaf) {
                $result.Add((Resolve-Path -LiteralPath $path).Path)
            }
        }

        foreach ($gradleFile in @(Get-ChildItem -LiteralPath $dir -File -Filter "*.gradle" -ErrorAction SilentlyContinue)) {
            $result.Add($gradleFile.FullName)
        }
    }

    return @($result | Select-Object -Unique)
}

function Test-GitLfsPointer {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }

    $stream = $null
    try {
        $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $count = [Math]::Min(128, [int]$stream.Length)
        if ($count -le 0) {
            return $false
        }
        $buffer = New-Object byte[] $count
        [void]$stream.Read($buffer, 0, $count)
        $text = [System.Text.Encoding]::ASCII.GetString($buffer)
        return $text.StartsWith("version https://git-lfs.github.com/spec/v1", [System.StringComparison]::Ordinal)
    }
    finally {
        if ($stream) {
            $stream.Dispose()
        }
    }
}

function Get-NativeAbiProfile {
    return [pscustomobject][ordered]@{
        abi = "arm64-v8a"
        appPlatform = "android-21"
        stl = "c++_shared"
        ndkDefault = "r16-clang"
        requiresLibCxxShared = $true
        requiredSo = @("libgame.so", "libc++_shared.so", "libdu.so", "liblocSDK6a.so")
    }
}

function Get-CriticalLfsPaths {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$ProjectDir,
        [Parameter(Mandatory = $true)][string]$EngineProfile
    )

    $abi = "arm64-v8a"
    $paths = @(
        "$ProjectDir/build.xml",
        "$ProjectDir/AndroidManifest.xml",
        "$ProjectDir/project.properties",
        "client/3rdplatform/duClient_SDK_Lib/libs/$abi/libdu.so",
        "client/3rdplatform/BaiduLBS_AndroidSDK_Lib/libs/$abi/liblocSDK6a.so"
    )

    if ($EngineProfile -eq "Upgrade30") {
        $paths += @(
            "cocos2d-x-3.0-oh/external/freetype2/prebuilt/android/$abi/libfreetype.a",
            "cocos2d-x-3.0-oh/external/jpeg/prebuilt/android/$abi/libjpeg.a",
            "cocos2d-x-3.0-oh/external/png/prebuilt/android/$abi/libpng.a",
            "cocos2d-x-3.0-oh/external/tiff/prebuilt/android/$abi/libtiff.a",
            "cocos2d-x-3.0-oh/external/webp/prebuilt/android/$abi/libwebp.a"
        )
    }
    else {
        $paths += @(
            "dependencies/zlib/prebuilt/android/$abi/libz.a",
            "dependencies/png/prebuilt/android/$abi/libpng.a",
            "dependencies/jpeg/prebuilt/android/$abi/libjpeg.a",
            "cocos2d-x-2.2.6/external/curl/prebuilt/android/$abi/libcurl.a",
            "cocos2d-x-2.2.6/external/curl/prebuilt/android/$abi/libssl.a",
            "cocos2d-x-2.2.6/external/curl/prebuilt/android/$abi/libcrypto.a",
            "cocos2d-x-2.2.6/external/tiff/prebuilt/android/$abi/libtiff.a",
            "cocos2d-x-2.2.6/cocos2dx/platform/third_party/android/prebuilt/libwebp/libs/$abi/libwebp.a",
            "cocos2d-x-2.2.6/cocos2dx/platform/third_party/android/prebuilt/libxml2/libs/$abi/libxml2.a"
        )
    }

    return $paths
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)][scriptblock]$Command,
        [Parameter(Mandatory = $true)][string]$FailureMessage,
        [string]$WorkingDir = ""
    )

    if (-not [string]::IsNullOrWhiteSpace($WorkingDir)) {
        Push-Location $WorkingDir
    }
    try {
        & $Command
        $code = $LASTEXITCODE
    }
    finally {
        if (-not [string]::IsNullOrWhiteSpace($WorkingDir)) {
            Pop-Location
        }
    }

    if ($code -ne 0) {
        throw "$FailureMessage (exit code: $code)"
    }
}

function Remove-IfExists {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
        Write-Host "Removed: $Path"
    }
}

function Sync-Directory {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
        throw "Sync source not found: $Source"
    }
    if (-not (Test-Path -LiteralPath $Destination -PathType Container)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    & robocopy $Source $Destination /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -gt 7) {
        throw "robocopy failed with exit code: $LASTEXITCODE"
    }
}

function Resolve-AndroidSigningConfig {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [string]$UserKeystorePath,
        [string]$UserKeyAlias,
        [string]$UserKeystorePassword,
        [string]$UserKeyAliasPassword,
        [bool]$AllowInteractive
    )

    $resolvedKeystore = $UserKeystorePath
    if ([string]::IsNullOrWhiteSpace($resolvedKeystore)) {
        $resolvedKeystore = Get-EnvOrEmpty -Name "MT3_ANDROID_KEYSTORE"
    }
    if ([string]::IsNullOrWhiteSpace($resolvedKeystore)) {
        $resolvedKeystore = Join-Path $RepoRoot "client/chuhancommon/android_adt"
    }

    $resolvedAlias = $UserKeyAlias
    if ([string]::IsNullOrWhiteSpace($resolvedAlias)) {
        $resolvedAlias = Get-EnvOrEmpty -Name "MT3_ANDROID_KEY_ALIAS"
    }
    if ([string]::IsNullOrWhiteSpace($resolvedAlias)) {
        $resolvedAlias = "LJ"
    }

    $storePassword = $UserKeystorePassword
    if ([string]::IsNullOrWhiteSpace($storePassword)) {
        $storePassword = Get-EnvOrEmpty -Name "MT3_ANDROID_KEYSTORE_PASSWORD"
    }

    $aliasPassword = $UserKeyAliasPassword
    if ([string]::IsNullOrWhiteSpace($aliasPassword)) {
        $aliasPassword = Get-EnvOrEmpty -Name "MT3_ANDROID_KEY_ALIAS_PASSWORD"
    }

    if (-not (Test-Path -LiteralPath $resolvedKeystore -PathType Leaf)) {
        throw "Android signing keystore not found: $resolvedKeystore"
    }

    if (-not $AllowInteractive -and ([string]::IsNullOrWhiteSpace($storePassword) -or [string]::IsNullOrWhiteSpace($aliasPassword))) {
        throw "Release signing passwords must be provided by parameters or MT3_ANDROID_KEYSTORE_PASSWORD/MT3_ANDROID_KEY_ALIAS_PASSWORD."
    }

    return [pscustomobject][ordered]@{
        keystorePath = (Resolve-Path -LiteralPath $resolvedKeystore).Path
        keyAlias = $resolvedAlias
        keystorePassword = $storePassword
        keyAliasPassword = $aliasPassword
        passwordMode = if ([string]::IsNullOrWhiteSpace($storePassword) -or [string]::IsNullOrWhiteSpace($aliasPassword)) { "interactive" } else { "provided" }
    }
}

function Copy-NativeRuntimeLibraries {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$ProjectAbs,
        [Parameter(Mandatory = $true)][string]$NdkBuildCmd
    )

    $profile = Get-NativeAbiProfile
    $abi = $profile.abi
    $targetDir = Join-Path $ProjectAbs "libs\$abi"
    if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    $ndkRoot = Split-Path -Parent $NdkBuildCmd
    $sourceMap = [ordered]@{
        "libdu.so" = Join-Path $RepoRoot "client\3rdplatform\duClient_SDK_Lib\libs\$abi\libdu.so"
        "liblocSDK6a.so" = Join-Path $RepoRoot "client\3rdplatform\BaiduLBS_AndroidSDK_Lib\libs\$abi\liblocSDK6a.so"
    }
    if ($profile.requiresLibCxxShared) {
        $sourceMap["libc++_shared.so"] = Join-Path $ndkRoot "sources\cxx-stl\llvm-libc++\libs\$abi\libc++_shared.so"
    }

    foreach ($name in $sourceMap.Keys) {
        $source = $sourceMap[$name]
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Required $abi runtime library not found: $source"
        }
        Copy-Item -LiteralPath $source -Destination (Join-Path $targetDir $name) -Force
    }

    $libGame = Join-Path $targetDir "libgame.so"
    if (-not (Test-Path -LiteralPath $libGame -PathType Leaf)) {
        throw "ndk-build did not produce libgame.so at $libGame"
    }
}

function Hide-NonSelectedAbiDirectories {
    param([Parameter(Mandatory = $true)][string]$ProjectAbs)

    $libsDir = Join-Path $ProjectAbs "libs"
    $moved = @()
    if (-not (Test-Path -LiteralPath $libsDir -PathType Container)) {
        return $moved
    }

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $abi = "arm64-v8a"
    foreach ($dir in @(Get-ChildItem -LiteralPath $libsDir -Directory -ErrorAction SilentlyContinue)) {
        if ([string]::Equals($dir.Name, $abi, [System.StringComparison]::OrdinalIgnoreCase)) {
            continue
        }

        if ($dir.Name -like "*.__bak_abi_*") {
            continue
        }

        $backupPath = Join-Path $libsDir ("{0}.__bak_abi_{1}" -f $dir.Name, $stamp)
        Move-Item -LiteralPath $dir.FullName -Destination $backupPath
        $moved += [pscustomobject][ordered]@{
            original = $dir.FullName
            backup = $backupPath
        }
        Write-Host "  hidden ABI dir: $($dir.Name)"
    }

    return $moved
}

function Restore-HiddenAbiDirectories {
    param([object[]]$MovedDirectories)

    foreach ($item in @($MovedDirectories)) {
        if ($null -eq $item) {
            continue
        }
        if (-not (Test-Path -LiteralPath $item.backup)) {
            continue
        }
        if (Test-Path -LiteralPath $item.original) {
            Remove-Item -LiteralPath $item.original -Recurse -Force
        }
        Move-Item -LiteralPath $item.backup -Destination $item.original
        Write-Host "  restored ABI dir: $($item.original)"
    }
}

function Get-FileHashValue {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][ValidateSet("MD5", "SHA256")][string]$Algorithm
    )

    return (Get-FileHash -LiteralPath $Path -Algorithm $Algorithm).Hash
}

function New-AndroidBuildPlan {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$ProjectDir,
        [Parameter(Mandatory = $true)][string]$ProjectAbs,
        [Parameter(Mandatory = $true)][string]$AndroidSdk,
        [Parameter(Mandatory = $true)][string]$Jdk,
        [Parameter(Mandatory = $true)][string]$Ndk,
        [Parameter(Mandatory = $true)][string]$NdkRevision,
        [Parameter(Mandatory = $true)][string]$Ant,
        [string[]]$GradleFiles
    )

    $nativeProfile = Get-NativeAbiProfile
    $GradleFiles = @($GradleFiles)
    $projectPropertiesPath = Join-Path $ProjectAbs "project.properties"
    $props = Read-AndroidProperties -Path $projectPropertiesPath
    $target = if ($props.Contains("target")) { $props["target"] } else { "" }
    $buildSystem = if ($GradleFiles.Count -gt 0) { "GradleDetectedUnsupported" } else { "Ant" }
    $packageTarget = $BuildType.ToLowerInvariant()
    $apkName = if ($BuildType -eq "Debug") { "mt3-debug.apk" } else { "mt3-release.apk" }
    $outputApk = Join-Path $ProjectAbs "bin\$apkName"

    return [pscustomobject][ordered]@{
        generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        repoRoot = $RepoRoot
        project = [pscustomobject][ordered]@{
            dir = $ProjectAbs
            channel = $Channel
            engineProfile = $EngineProfile
            buildSystem = $buildSystem
            target = $target
            gradleFiles = @($GradleFiles)
            libraryProjects = @(Get-AndroidLibraryProjectDirs -ProjectPropertiesPath $projectPropertiesPath)
        }
        build = [pscustomobject][ordered]@{
            buildType = $BuildType
            packageTarget = $packageTarget
            clean = [bool]$Clean
            syncResources = [bool]$SyncRes
            skipNativeBuild = [bool]$SkipNativeBuild
            skipPackage = [bool]$SkipPackage
            outputApk = $outputApk
        }
        native = [pscustomobject][ordered]@{
            abi = $nativeProfile.abi
            appPlatform = $nativeProfile.appPlatform
            stl = $nativeProfile.stl
            ndkDefault = $nativeProfile.ndkDefault
            ndkRevision = $NdkRevision
            ndkDebug = if ($NativeDebug) { 1 } else { 0 }
            ndkBuild = $Ndk
            requiredSo = @($nativeProfile.requiredSo)
        }
        toolchain = [pscustomobject][ordered]@{
            jdkHome = $Jdk
            androidSdkRoot = $AndroidSdk
            ant = $Ant
            aapt = Join-Path $AndroidSdk "build-tools\22.0.1\aapt.exe"
            zipalign = Join-Path $AndroidSdk "build-tools\22.0.1\zipalign.exe"
        }
        gates = [pscustomobject][ordered]@{
            lfsCheck = -not [bool]$NoLfsCheck
            requireArm64InApk = $true
            apkStructure = $true
            zipalign = $true
        }
        dependencies = [pscustomobject][ordered]@{
            lfsCriticalPaths = @(Get-CriticalLfsPaths -RepoRoot $RepoRoot -ProjectDir $ProjectDir -EngineProfile $EngineProfile)
        }
    }
}

if ($BuildType.Equals("Debug", [System.StringComparison]::OrdinalIgnoreCase)) {
    $BuildType = "Debug"
}
else {
    $BuildType = "Release"
}

if ($Channel -ne "free") {
    throw "Only the free channel is verified for the canonical arm64 Android build. Channel '$Channel' is not supported until build_monthpayment.xml is restored and revalidated."
}

if ($CleanIntermediates) {
    $Clean = $true
}

if ($ForceV7aOnly) {
    throw "-ForceV7aOnly has been removed from the canonical Android build. Free Android packages are arm64-v8a only."
}

if ($PrepareArm64) {
    Write-Warning "-PrepareArm64 is deprecated; arm64 runtime libraries are resolved automatically from the project, third-party SDKs, and NDK r16."
}

if (-not [string]::IsNullOrWhiteSpace($Arm64SourceDir)) {
    Write-Warning "-Arm64SourceDir is deprecated and ignored; arm64 runtime libraries are resolved from canonical project dependencies."
}

$defaultRequiredArm64Libs = @("libgame.so", "libc++_shared.so", "libdu.so", "liblocSDK6a.so")
if (@(Compare-Object -ReferenceObject $defaultRequiredArm64Libs -DifferenceObject @($RequiredArm64Libs)).Count -gt 0) {
    throw "-RequiredArm64Libs is no longer customizable. Required arm64 libraries are fixed: $($defaultRequiredArm64Libs -join ', ')"
}
$repoRoot = Get-RepoRoot
$Abi = "arm64-v8a"
if ((Split-Path -Leaf $ProjectDir) -ne "LocojoyProject") {
    throw "Free Android package output is pinned to client/android/LocojoyProject. Current ProjectDir: $ProjectDir"
}
$projectAbs = Join-Path $repoRoot $ProjectDir
if (-not (Test-Path -LiteralPath $projectAbs -PathType Container)) {
    throw "Project directory not found: $projectAbs"
}

$androidRoot = Join-Path $repoRoot "client\android"
$resolvedAndroidSdk = Resolve-AndroidSdkRoot -UserPath $AndroidSdkRoot
$resolvedJdkHome = Resolve-Jdk8Home -UserPath $JdkHome
$resolvedNdkBuild = Resolve-NdkBuildPath -UserPath $NdkBuildPath
$resolvedNdkRevision = Assert-NdkR16 -NdkBuildPath $resolvedNdkBuild
$resolvedAnt = Resolve-AntPath -UserPath $AntPath
$gradleFiles = @(Get-GradleProjectFiles -AndroidRoot $androidRoot)
$plan = New-AndroidBuildPlan -RepoRoot $repoRoot -ProjectDir $ProjectDir -ProjectAbs $projectAbs -AndroidSdk $resolvedAndroidSdk -Jdk $resolvedJdkHome -Ndk $resolvedNdkBuild -NdkRevision $resolvedNdkRevision -Ant $resolvedAnt -GradleFiles $gradleFiles

if ($PlanOnly) {
    if ($Json) {
        $plan | ConvertTo-Json -Depth 8
    }
    else {
        $plan | Format-List
    }
    exit 0
}

Use-Jdk8ForCurrentProcess -ResolvedJdkHome $resolvedJdkHome
$env:ANDROID_HOME = $resolvedAndroidSdk
$env:ANDROID_SDK_ROOT = $resolvedAndroidSdk
$env:ANT_HOME = Split-Path -Parent (Split-Path -Parent $resolvedAnt)
$env:ANDROID_NDK_HOME = Split-Path -Parent $resolvedNdkBuild
$env:NDK_HOME = $env:ANDROID_NDK_HOME
$env:Path = "$resolvedAndroidSdk\tools;$resolvedAndroidSdk\platform-tools;$resolvedAndroidSdk\build-tools\22.0.1;$env:ANT_HOME\bin;$env:ANDROID_NDK_HOME;$env:Path"

if ($gradleFiles.Count -gt 0) {
    throw "Gradle files were detected, but this repository has no verified Gradle build chain. Refusing to mix build backends."
}

$migrationGate = Join-Path $repoRoot "tools\scripts\Assert-AndroidArm64Migration.ps1"
Invoke-CheckedCommand -FailureMessage "Android $EngineProfile migration gate failed" -WorkingDir $repoRoot -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File $migrationGate -ProjectDir $ProjectDir -EngineProfile $EngineProfile
}

if ($HydrateLfs) {
    $include = ($plan.dependencies.lfsCriticalPaths -join ",")
    Invoke-CheckedCommand -FailureMessage "git lfs pull failed" -Command {
        git lfs pull --include="$include"
    } -WorkingDir $repoRoot
}

if (-not $NoLfsCheck) {
    $pointers = New-Object System.Collections.Generic.List[string]
    foreach ($relative in $plan.dependencies.lfsCriticalPaths) {
        $path = Join-Path $repoRoot $relative
        if (Test-GitLfsPointer -Path $path) {
            [void]$pointers.Add($relative)
        }
    }
    if ($pointers.Count -gt 0) {
        throw "Git LFS pointer files found in Android build inputs. Run with -HydrateLfs or run git lfs pull. Files: $($pointers -join ', ')"
    }
}

Write-Host "MT3 Android build"
Write-Host "  Project       : $($plan.project.dir)"
Write-Host "  EngineProfile : $($plan.project.engineProfile)"
Write-Host "  BuildSystem   : $($plan.project.buildSystem)"
Write-Host "  BuildType     : $($plan.build.buildType)"
Write-Host "  PackageTarget : $($plan.build.packageTarget)"
Write-Host "  Native ABI    : $($plan.native.abi)"
Write-Host "  Native STL    : $($plan.native.stl)"
Write-Host "  APP_PLATFORM  : $($plan.native.appPlatform)"
Write-Host "  NDK_DEBUG     : $($plan.native.ndkDebug)"
Write-Host "  JDK           : $($plan.toolchain.jdkHome)"
Write-Host "  SDK           : $($plan.toolchain.androidSdkRoot)"
Write-Host "  NDK           : $($plan.native.ndkBuild)"
Write-Host "  Ant           : $($plan.toolchain.ant)"

if ($SyncRes) {
    $resSourceAbs = Join-Path $repoRoot $ResSourceDir
    $assetsResAbs = Join-Path $projectAbs "assets\res"
    Write-Host "Sync resources: $resSourceAbs -> $assetsResAbs"
    Sync-Directory -Source $resSourceAbs -Destination $assetsResAbs
}

if ($Clean) {
    Write-Host "Clean Android intermediates..."
    Remove-IfExists -Path (Join-Path $projectAbs "obj\local")
    Remove-IfExists -Path (Join-Path $projectAbs "bin")
    Remove-IfExists -Path (Join-Path $projectAbs "gen")
    foreach ($libraryDir in $plan.project.libraryProjects) {
        Remove-IfExists -Path (Join-Path $libraryDir "bin")
        Remove-IfExists -Path (Join-Path $libraryDir "gen")
    }
}

if (-not $SkipNativeBuild) {
    if ($Clean) {
        Invoke-CheckedCommand -FailureMessage "ndk-build clean failed" -WorkingDir $projectAbs -Command {
            cmd /c "set ProgramW6432=C:\Program Files&& `"$resolvedNdkBuild`" clean"
        }
    }

    $ndkDebugValue = if ($NativeDebug) { "1" } else { "0" }
    Invoke-CheckedCommand -FailureMessage "ndk-build failed" -WorkingDir $projectAbs -Command {
        cmd /c "set ProgramW6432=C:\Program Files&& `"$resolvedNdkBuild`" NDK_DEBUG=$ndkDebugValue -j$Jobs"
    }

    Copy-NativeRuntimeLibraries -RepoRoot $repoRoot -ProjectAbs $projectAbs -NdkBuildCmd $resolvedNdkBuild
}

if (-not $SkipPackage) {
    $antArgs = @("-buildfile", "build.xml")
    if ($BuildType -eq "Release") {
        $signing = Resolve-AndroidSigningConfig `
            -RepoRoot $repoRoot `
            -UserKeystorePath $KeystorePath `
            -UserKeyAlias $KeyAlias `
            -UserKeystorePassword $KeystorePassword `
            -UserKeyAliasPassword $KeyAliasPassword `
            -AllowInteractive ([bool]$AllowInteractiveSigning)
        $antArgs += "-Dkey.store=$($signing.keystorePath)"
        $antArgs += "-Dkey.alias=$($signing.keyAlias)"
        if (-not [string]::IsNullOrWhiteSpace($signing.keystorePassword)) {
            $antArgs += "-Dkey.store.password=$($signing.keystorePassword)"
        }
        if (-not [string]::IsNullOrWhiteSpace($signing.keyAliasPassword)) {
            $antArgs += "-Dkey.alias.password=$($signing.keyAliasPassword)"
        }
    }

    if ($Clean) {
        $antArgs += "clean"
    }
    $antArgs += $plan.build.packageTarget

    $movedAbiDirs = @()
    try {
        Write-Host "Package selected ABI only: $Abi"
        $movedAbiDirs = @(Hide-NonSelectedAbiDirectories -ProjectAbs $projectAbs)
        Invoke-CheckedCommand -FailureMessage "ant $($plan.build.packageTarget) failed" -WorkingDir $projectAbs -Command {
            & $resolvedAnt @antArgs
        }
    }
    finally {
        Restore-HiddenAbiDirectories -MovedDirectories $movedAbiDirs
    }
}

$apkPath = $plan.build.outputApk
if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) {
    throw "APK not found: $apkPath"
}

$structureGate = Join-Path $repoRoot "tools\scripts\Assert-ApkInstallableStructure.ps1"
$abiGate = Join-Path $repoRoot "tools\scripts\Assert-ApkAbiContents.ps1"
$ljfmResourcePathGate = Join-Path $repoRoot "tools\scripts\Assert-AndroidLJFMResourcePath.ps1"
$audioJniBridgeGate = Join-Path $repoRoot "tools\scripts\Assert-AndroidAudioJniBridge.ps1"
$startupBlackScreenGate = Join-Path $repoRoot "tools\scripts\Assert-AndroidStartupBlackScreenGuards.ps1"
Invoke-CheckedCommand -FailureMessage "APK structure gate failed" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File $structureGate -ApkPath $apkPath -MaxEntryCount 65534 -FailOnZip64
}

Invoke-CheckedCommand -FailureMessage "APK ABI gate failed" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File $abiGate -ApkPath $apkPath -RequiredAbis arm64-v8a -RequiredSoByAbi "arm64-v8a:libgame.so;arm64-v8a:libc++_shared.so;arm64-v8a:libdu.so;arm64-v8a:liblocSDK6a.so"
}

Invoke-CheckedCommand -FailureMessage "Android LJFM resource path gate failed" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File $ljfmResourcePathGate -RepoRoot $repoRoot -ApkPath $apkPath
}

Invoke-CheckedCommand -FailureMessage "Android audio JNI bridge gate failed" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File $audioJniBridgeGate -RepoRoot $repoRoot -EngineProfile $EngineProfile
}

Invoke-CheckedCommand -FailureMessage "Android startup black-screen guard failed" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File $startupBlackScreenGate -RepoRoot $repoRoot -EngineProfile $EngineProfile
}

Invoke-CheckedCommand -FailureMessage "zipalign check failed" -Command {
    & $plan.toolchain.zipalign -c 4 $apkPath
}

$apkInfo = Get-Item -LiteralPath $apkPath
$badging = @(& $plan.toolchain.aapt dump badging $apkPath | Where-Object {
    $_ -match "^package:" -or $_ -match "^sdkVersion" -or $_ -match "^targetSdkVersion" -or $_ -match "^native-code"
})

$result = [pscustomobject][ordered]@{
    status = "success"
    plan = $plan
    artifact = [pscustomobject][ordered]@{
        path = $apkInfo.FullName
        size = $apkInfo.Length
        lastWriteTime = $apkInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        md5 = (Get-FileHashValue -Path $apkInfo.FullName -Algorithm MD5)
        sha256 = (Get-FileHashValue -Path $apkInfo.FullName -Algorithm SHA256)
        badging = @($badging)
    }
}

if ($Json) {
    $result | ConvertTo-Json -Depth 10
}
else {
    Write-Host ""
    Write-Host "Build success"
    Write-Host "  APK     : $($result.artifact.path)"
    Write-Host "  Size    : $($result.artifact.size)"
    Write-Host "  Time    : $($result.artifact.lastWriteTime)"
    Write-Host "  MD5     : $($result.artifact.md5)"
    Write-Host "  SHA256  : $($result.artifact.sha256)"
    foreach ($line in $result.artifact.badging) {
        Write-Host "  $line"
    }
}

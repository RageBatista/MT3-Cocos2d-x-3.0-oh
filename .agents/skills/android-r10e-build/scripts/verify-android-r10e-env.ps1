[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "android-r10e-build"

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$monthPaymentBuildPresent = $false
$buildDirPresent = $false

$requiredFiles = @(
    "tools/scripts/Build-Android-Locojoy-WithGate.ps1",
    "tools/scripts/Assert-ApkInstallableStructure.ps1",
    "tools/scripts/Assert-ApkAbiContents.ps1",
    "tools/scripts/Assert-AndroidArm64Migration.ps1",
    "client/android/LocojoyProject/build/build.xml",
    "client/android/LocojoyProject/project.properties"
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $RepoRoot $relativePath
    if (Test-Path $fullPath -PathType Leaf) {
        [void]$details.Add("repo_file=" + $relativePath)
    } else {
        [void]$failures.Add("missing repo file: " + $relativePath)
    }
}

$buildDirPath = Join-Path $RepoRoot "client/android/LocojoyProject/build"
if (Test-Path $buildDirPath -PathType Container) {
    $buildDirPresent = $true
    [void]$details.Add("repo_dir=client/android/LocojoyProject/build")
} else {
    [void]$failures.Add("missing repo dir: client/android/LocojoyProject/build")
}

$monthPaymentBuildFile = Join-Path $RepoRoot "client/android/LocojoyProject/build/build_monthpayment.xml"
if (Test-Path $monthPaymentBuildFile -PathType Leaf) {
    $monthPaymentBuildPresent = $true
    [void]$details.Add("repo_file=client/android/LocojoyProject/build/build_monthpayment.xml")
}

$ndkCandidates = @()
foreach ($envName in @("ANDROID_NDK_HOME", "NDK_HOME")) {
    $envValue = [Environment]::GetEnvironmentVariable($envName)
    if (-not [string]::IsNullOrWhiteSpace($envValue)) {
        $ndkCandidates += (Join-Path $envValue "ndk-build.cmd")
        $ndkCandidates += (Join-Path $envValue "ndk-build")
    }
}
$ndkCandidates += @(
    "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd",
    "C:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd"
)
$ndkPath = Get-ExistingPath -Candidates $ndkCandidates
if ([string]::IsNullOrWhiteSpace($ndkPath)) {
    $ndkPath = Get-CommandSource -Name "ndk-build"
}
if ([string]::IsNullOrWhiteSpace($ndkPath)) {
    [void]$failures.Add("ndk-build not found; current Android free baseline requires NDK r16 clang")
} else {
    [void]$details.Add("ndk_build=" + $ndkPath)
    $ndkRoot = Split-Path -Parent $ndkPath
    $sourceProperties = Join-Path $ndkRoot "source.properties"
    $ndkLooksR16 = $false
    if ($ndkPath -match "(?i)(16\.1\.4479499|r16)") {
        $ndkLooksR16 = $true
    } elseif (Test-Path $sourceProperties -PathType Leaf) {
        $sourceText = Get-Content -LiteralPath $sourceProperties -Raw -Encoding UTF8
        if ($sourceText -match "Pkg\.Revision\s*=\s*16\.1\.4479499") {
            $ndkLooksR16 = $true
        }
    }
    if (-not $ndkLooksR16) {
        [void]$failures.Add("ndk-build must be NDK r16 clang (16.1.4479499). actual=" + $ndkPath)
    }
}

$antCandidates = @()
$antHome = [Environment]::GetEnvironmentVariable("ANT_HOME")
if (-not [string]::IsNullOrWhiteSpace($antHome)) {
    $antCandidates += (Join-Path $antHome "bin\ant.bat")
}
$antCandidates += @(
    "D:\apache-ant-1.9.7\bin\ant.bat",
    "C:\apache-ant-1.9.7\bin\ant.bat"
)
$antPath = Get-ExistingPath -Candidates $antCandidates
if ([string]::IsNullOrWhiteSpace($antPath)) {
    $antPath = Get-CommandSource -Name "ant"
}
if ([string]::IsNullOrWhiteSpace($antPath)) {
    [void]$warnings.Add("ant not found")
} else {
    [void]$details.Add("ant=" + $antPath)
}

$javaPath = ""
$javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME")
if (-not [string]::IsNullOrWhiteSpace($javaHome)) {
    $javaCandidate = Join-Path $javaHome "bin\java.exe"
    if (Test-Path $javaCandidate -PathType Leaf) {
        $javaPath = [System.IO.Path]::GetFullPath($javaCandidate)
    }
}
if ([string]::IsNullOrWhiteSpace($javaPath)) {
    $javaPath = Get-CommandSource -Name "java"
}
if ([string]::IsNullOrWhiteSpace($javaPath)) {
    [void]$warnings.Add("java not found")
} else {
    [void]$details.Add("java=" + $javaPath)
    $javaOutput = [string]::Join(" ", (Get-CommandOutput -FilePath $javaPath -Arguments @("-version")))
    if ($javaOutput -match 'version "1\.8') {
        [void]$details.Add("java_version=ok")
    } elseif ($javaOutput -match 'version "1\.7') {
        [void]$failures.Add("java version is 1.7; current Android free baseline requires JDK8. actual=" + $javaOutput)
    } elseif ($javaOutput -match 'version "(9|1[0-9]|[2-9][0-9])\.') {
        [void]$failures.Add("JDK 9+ is prohibited for Android Ant/dx builds; use JDK8. actual=" + $javaOutput)
    } else {
        [void]$failures.Add("java version is not JDK8. actual=" + $javaOutput)
    }
}

$javacPath = ""
if (-not [string]::IsNullOrWhiteSpace($javaHome)) {
    $javacCandidate = Join-Path $javaHome "bin\javac.exe"
    if (Test-Path $javacCandidate -PathType Leaf) {
        $javacPath = [System.IO.Path]::GetFullPath($javacCandidate)
    }
}
if ([string]::IsNullOrWhiteSpace($javacPath)) {
    $javacPath = Get-CommandSource -Name "javac"
}
if ([string]::IsNullOrWhiteSpace($javacPath)) {
    [void]$warnings.Add("javac not found")
} else {
    [void]$details.Add("javac=" + $javacPath)
    $javacOutput = [string]::Join(" ", (Get-CommandOutput -FilePath $javacPath -Arguments @("-version")))
    if ($javacOutput -notmatch 'javac 1\.8') {
        [void]$failures.Add("javac must be JDK8 for Android Ant/dx builds. actual=" + $javacOutput)
    }
}

$aaptCandidates = @()
$sdkRootCandidates = New-Object System.Collections.Generic.List[string]
foreach ($sdkEnv in @("ANDROID_HOME", "ANDROID_SDK_ROOT")) {
    $sdkRoot = [Environment]::GetEnvironmentVariable($sdkEnv)
    if (-not [string]::IsNullOrWhiteSpace($sdkRoot)) {
        [void]$sdkRootCandidates.Add($sdkRoot)
        $buildToolsRoot = Join-Path $sdkRoot "build-tools"
        if (Test-Path $buildToolsRoot -PathType Container) {
            $aaptCandidates += @(Get-ChildItem -Path $buildToolsRoot -Recurse -Filter aapt.exe -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
        }
    }
}
$legacySdkRoot = "D:\android-sdk_r24.1.2-windows\android-sdk-windows"
[void]$sdkRootCandidates.Add($legacySdkRoot)
$aaptCandidates += @(
    (Join-Path $legacySdkRoot "build-tools\22.0.1\aapt.exe")
)
$aaptPath = Get-ExistingPath -Candidates $aaptCandidates

$completeAntSdk = ""
foreach ($sdkRoot in $sdkRootCandidates) {
    if ([string]::IsNullOrWhiteSpace($sdkRoot) -or -not (Test-Path $sdkRoot -PathType Container)) {
        continue
    }
    $requiredSdkFiles = @(
        "tools\ant\build.xml",
        "platform-tools\adb.exe",
        "build-tools\22.0.1\aapt.exe",
        "build-tools\22.0.1\zipalign.exe",
        "platforms\android-22\android.jar"
    )
    $missing = @()
    foreach ($relative in $requiredSdkFiles) {
        if (-not (Test-Path (Join-Path $sdkRoot $relative) -PathType Leaf)) {
            $missing += $relative
        }
    }
    if ($missing.Count -eq 0) {
        $completeAntSdk = [System.IO.Path]::GetFullPath($sdkRoot)
        break
    }
    [void]$details.Add("sdk_incomplete=" + $sdkRoot + " missing=" + ($missing -join ","))
}

if ([string]::IsNullOrWhiteSpace($completeAntSdk)) {
    [void]$failures.Add("complete legacy Android SDK not found; require tools\ant\build.xml, platform-tools, build-tools\22.0.1 and platforms\android-22")
} else {
    [void]$details.Add("complete_ant_sdk=" + $completeAntSdk)
    $aaptPath = Join-Path $completeAntSdk "build-tools\22.0.1\aapt.exe"
}

if ([string]::IsNullOrWhiteSpace($aaptPath)) {
    $aaptPath = Get-CommandSource -Name "aapt"
}
if ([string]::IsNullOrWhiteSpace($aaptPath)) {
    [void]$warnings.Add("aapt not found")
} else {
    [void]$details.Add("aapt=" + $aaptPath)
}

$status = "PASS"
$summary = "Android repo entrypoints and r16/Ant build structure look consistent."
$next = "Set JDK8/Android SDK/signing env vars, then run .\\tools\\scripts\\Build-Android-Locojoy-WithGate.ps1 -ProjectDir `"client/android/LocojoyProject`" -BuildType Debug -Channel free -Jobs 4 -NdkBuildPath `"D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd`" -SyncRes -ResSourceDir `"client/res_android/res`" -RequireArm64InApk"

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "Android repo baseline has drift and should be fixed before build preflight."
    $next = "Restore JDK8, complete legacy Android SDK, canonical Android entry files and build descriptors, then rerun this script."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "Android repo baseline is valid, but optional or local environment items still need attention."
    $next = "Use JDK8, NDK r16 clang, a complete legacy Android SDK and the canonical Android build entry."
}

foreach ($item in $failures) {
    [void]$details.Add("failure=" + $item)
}
foreach ($item in $warnings) {
    [void]$details.Add("warning=" + $item)
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    required_file_count = $requiredFiles.Count
    build_dir_present = $buildDirPresent
    monthpayment_build_present = $monthPaymentBuildPresent
    ndk_build = $ndkPath
    ant = $antPath
    java = $javaPath
    javac = $javacPath
    aapt = $aaptPath
    complete_ant_sdk = $completeAntSdk
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

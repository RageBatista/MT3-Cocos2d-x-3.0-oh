param(
    [string]$ProjectDir = "client/android/LocojoyProject",
    [ValidateSet("Legacy226", "Upgrade30")]
    [string]$EngineProfile = "Upgrade30",
    [string[]]$RequiredArm64StaticLibs = @(),
    [string[]]$RequiredArm64InputSharedLibs = @(
        "client/3rdplatform/duClient_SDK_Lib/libs/arm64-v8a/libdu.so",
        "client/3rdplatform/BaiduLBS_AndroidSDK_Lib/libs/arm64-v8a/liblocSDK6a.so"
    ),
    [string[]]$RequiredArm64SharedLibs = @(
        "client/android/LocojoyProject/libs/arm64-v8a/libgame.so",
        "client/android/LocojoyProject/libs/arm64-v8a/libc++_shared.so",
        "client/android/LocojoyProject/libs/arm64-v8a/libdu.so",
        "client/android/LocojoyProject/libs/arm64-v8a/liblocSDK6a.so"
    ),
    [switch]$RequireBuiltSharedLibs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path ".").Path
$projectAbs = Join-Path $repoRoot $ProjectDir
$profile = if ($EngineProfile -eq "Upgrade30") {
    [pscustomobject]@{
        CocosRoot = "cocos2d-x-3.0-oh"
        CocosAndroidMk = "cocos2d-x-3.0-oh\cocos\2d\Android.mk"
        CocosPlatformAndroidMk = "cocos2d-x-3.0-oh\cocos\2d\platform\android\Android.mk"
        JniRoot = "cocos2d-x-3.0-oh\cocos\2d\platform\android\jni"
        CeguiAndroidMk = "client\android\native\cegui-r5\Android.mk"
        RequiredStaticLibs = @(
            "cocos2d-x-3.0-oh/external/freetype2/prebuilt/android/arm64-v8a/libfreetype.a",
            "cocos2d-x-3.0-oh/external/jpeg/prebuilt/android/arm64-v8a/libjpeg.a",
            "cocos2d-x-3.0-oh/external/png/prebuilt/android/arm64-v8a/libpng.a",
            "cocos2d-x-3.0-oh/external/tiff/prebuilt/android/arm64-v8a/libtiff.a",
            "cocos2d-x-3.0-oh/external/webp/prebuilt/android/arm64-v8a/libwebp.a"
        )
        VersionedStaticLibs = @(
            "cocos2d-x-3.0-oh/external/freetype2/prebuilt/android/arm64-v8a/libfreetype.a",
            "cocos2d-x-3.0-oh/external/jpeg/prebuilt/android/arm64-v8a/libjpeg.a",
            "cocos2d-x-3.0-oh/external/png/prebuilt/android/arm64-v8a/libpng.a",
            "cocos2d-x-3.0-oh/external/tiff/prebuilt/android/arm64-v8a/libtiff.a",
            "cocos2d-x-3.0-oh/external/webp/prebuilt/android/arm64-v8a/libwebp.a"
        )
    }
}
else {
    [pscustomobject]@{
        CocosRoot = "cocos2d-x-2.2.6"
        CocosAndroidMk = "cocos2d-x-2.2.6\cocos2dx\Android.mk"
        CocosPlatformAndroidMk = ""
        JniRoot = "cocos2d-x-2.2.6\cocos2dx\platform\android\jni"
        CeguiAndroidMk = "dependencies\cegui\Android.mk"
        RequiredStaticLibs = @(
            "dependencies/zlib/prebuilt/android/arm64-v8a/libz.a",
            "dependencies/png/prebuilt/android/arm64-v8a/libpng.a",
            "dependencies/jpeg/prebuilt/android/arm64-v8a/libjpeg.a",
            "cocos2d-x-2.2.6/external/curl/prebuilt/android/arm64-v8a/libcurl.a",
            "cocos2d-x-2.2.6/external/curl/prebuilt/android/arm64-v8a/libssl.a",
            "cocos2d-x-2.2.6/external/curl/prebuilt/android/arm64-v8a/libcrypto.a",
            "cocos2d-x-2.2.6/external/tiff/prebuilt/android/arm64-v8a/libtiff.a",
            "cocos2d-x-2.2.6/cocos2dx/platform/third_party/android/prebuilt/libwebp/libs/arm64-v8a/libwebp.a",
            "cocos2d-x-2.2.6/cocos2dx/platform/third_party/android/prebuilt/libxml2/libs/arm64-v8a/libxml2.a"
        )
        VersionedStaticLibs = @(
            "cocos2d-x-2.2.6/cocos2dx/platform/third_party/android/prebuilt/libwebp/libs/arm64-v8a/libwebp.a",
            "cocos2d-x-2.2.6/cocos2dx/platform/third_party/android/prebuilt/libxml2/libs/arm64-v8a/libxml2.a"
        )
    }
}

if ($RequiredArm64StaticLibs.Count -eq 0) {
    $RequiredArm64StaticLibs = @($profile.RequiredStaticLibs)
}

$CocosRoot = $profile.CocosRoot
$appMk = Join-Path $projectAbs "jni\Application.mk"
$androidMk = Join-Path $projectAbs "jni\Android.mk"
$engineAndroidMk = Join-Path $repoRoot "engine\Android.mk"
$fireClientAndroidMk = Join-Path $repoRoot "client\FireClient\Android.mk"
$ljfmAndroidMk = Join-Path $repoRoot "common\ljfm\Android.mk"
$updateEngineAndroidMk = Join-Path $repoRoot "common\updateengine\Android.mk"
$cocosAndroidMk = Join-Path $repoRoot $profile.CocosAndroidMk
$cocosPlatformAndroidMk = if ($profile.CocosPlatformAndroidMk) { Join-Path $repoRoot $profile.CocosPlatformAndroidMk } else { "" }
$ceguiAndroidMk = Join-Path $repoRoot $profile.CeguiAndroidMk
$jnih = Join-Path $repoRoot "$($profile.JniRoot)\JniHelper.h"
$jnicpp = Join-Path $repoRoot "$($profile.JniRoot)\JniHelper.cpp"
$helperCpp = Join-Path $repoRoot "$($profile.JniRoot)\Java_org_cocos2dx_lib_Cocos2dxHelper.cpp"
$mainCpp = Join-Path $projectAbs "jni\main.cpp"
$activityJava = Join-Path $projectAbs "src\org\cocos2dx\lib\Cocos2dxActivity.java"
$glSurfaceJava = Join-Path $projectAbs "src\org\cocos2dx\lib\Cocos2dxGLSurfaceView.java"
$activityJavaFiles = @(
    (Join-Path $repoRoot "client\android\common\src\org\cocos2dx\lib\Cocos2dxActivity.java"),
    $activityJava,
    (Join-Path $repoRoot "client\android\JoysdkProject\src\org\cocos2dx\lib\Cocos2dxActivity.java"),
    (Join-Path $repoRoot "client\android\YijieProject\src\org\cocos2dx\lib\Cocos2dxActivity.java")
)
$buildScript = Join-Path $repoRoot "tools\scripts\Build-Android-Locojoy-WithGate.ps1"
$jdkGateScript = Join-Path $repoRoot "tools\scripts\Assert-AndroidJdk8Gate.ps1"

$errors = New-Object System.Collections.Generic.List[string]

function Add-Error {
    param([string]$Message)
    $script:errors.Add($Message)
}

function Assert-File {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Error "Missing file: $Path"
        return $false
    }
    return $true
}

function Read-Text {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Get-RepoRelativePath {
    param([string]$Path)
    if ($Path.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($repoRoot.Length + 1)
    }
    return $Path
}

function Test-GitWorkTree {
    try {
        & git -C $repoRoot rev-parse --is-inside-work-tree *> $null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Test-GitIgnored {
    param([string]$RelativePath)
    & git -C $repoRoot check-ignore -q -- $RelativePath
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        return $true
    }
    if ($exitCode -eq 1) {
        return $false
    }
    Add-Error "Unable to evaluate git ignore state for: $RelativePath"
    return $false
}

if (Assert-File $appMk) {
    $appText = Read-Text $appMk
    if ($appText -notmatch "(?m)^\s*APP_ABI\s*:=\s*arm64-v8a\s*$") {
        Add-Error "Application.mk must build arm64-v8a only."
    }
    if ($appText -match "(?m)^\s*APP_ABI\s*:=.*\barmeabi\b") {
        Add-Error "Application.mk must not include armeabi."
    }
    if ($appText -notmatch "(?m)^\s*APP_PLATFORM\s*:=\s*android-21\s*$") {
        Add-Error "Application.mk must set APP_PLATFORM := android-21 for arm64-v8a."
    }
    if ($appText -notmatch "(?m)^\s*APP_STL\s*:=\s*c\+\+_shared\s*$") {
        Add-Error "Application.mk must use APP_STL := c++_shared."
    }
    if ($appText -match "gnustl") {
        Add-Error "Application.mk must not reference gnustl."
    }
    if ($appText -notmatch "(?m)^\s*NDK_TOOLCHAIN_VERSION\s*:=\s*clang\s*$") {
        Add-Error "Application.mk must use clang for arm64-v8a."
    }
}

if (Assert-File $androidMk) {
    $mkText = Read-Text $androidMk
    if ($mkText -match "armeabi(?!-v7a)") {
        Add-Error "Android.mk must not hard-code armeabi."
    }
    if ($mkText -notmatch "\$\(TARGET_ARCH_ABI\)") {
        Add-Error "Android.mk must route prebuilt native libs through TARGET_ARCH_ABI."
    }
    if ($mkText -match "google-breakpad/android/google_breakpad" -and $mkText -notmatch "ifneq\s*\(\$\(TARGET_ARCH_ABI\),arm64-v8a\)") {
        Add-Error "Breakpad import must be gated out for arm64-v8a unless arm64 breakpad is available."
    }
    if ($EngineProfile -eq "Upgrade30") {
        if ($mkText -notmatch [regex]::Escape($CocosRoot)) {
            Add-Error "Locojoy Android.mk must import the $CocosRoot module root for Upgrade30."
        }
        if ($mkText -match "cocos2d-x-2\.2\.6") {
            Add-Error "Locojoy Android.mk must not mix cocos2d-x-2.2.6 into Upgrade30."
        }
        if ($mkText -notmatch "import-module,android/native/cegui-r5") {
            Add-Error "Locojoy Android.mk must import CEGUI 0.7.9-r5 from android/native/cegui-r5."
        }
    }
}

if (Assert-File $engineAndroidMk) {
    $engineMkText = Read-Text $engineAndroidMk
    if ($engineMkText -match "cocos2d-2\.0-rc2-x-2\.0\.1") {
        Add-Error "Engine Android.mk must not import modules from cocos2d-2.0-rc2-x-2.0.1."
    }
    if ($engineMkText -match "cocos_spine_static") {
        Add-Error "Engine Android.mk must use Spine from the current cocos_extension_static module."
    }
    if ($EngineProfile -eq "Upgrade30" -and $engineMkText -match "cocos2d-x-2\.2\.6") {
        Add-Error "Engine Android.mk must not mix cocos2d-x-2.2.6 into Upgrade30."
    }
}

if (Assert-File $fireClientAndroidMk) {
    $fireClientMkText = Read-Text $fireClientAndroidMk
    if ($fireClientMkText -match "cocos2d-2\.0-rc2-x-2\.0\.1") {
        Add-Error "FireClient Android.mk must not import source files or modules from cocos2d-2.0-rc2-x-2.0.1."
    }
    if ($EngineProfile -eq "Upgrade30") {
        if ($fireClientMkText -match "cocos2d-x-2\.2\.6|dependencies/CEGUI") {
            Add-Error "FireClient Android.mk must use only cocos2d-x-3.0-oh and CEGUI-0.7.9-r5 inputs for Upgrade30."
        }
        if ($fireClientMkText -notmatch "cocos2d-x-3\.0-oh|external/lua") {
            Add-Error "FireClient Android.mk does not expose Upgrade30 Cocos/Lua inputs."
        }
    }
}

foreach ($sharedMk in @($ljfmAndroidMk, $updateEngineAndroidMk)) {
    if (Assert-File $sharedMk) {
        $sharedText = Read-Text $sharedMk
        if ($EngineProfile -eq "Upgrade30" -and $sharedText -match "cocos2d-x-2\.2\.6") {
            Add-Error "$(Get-RepoRelativePath $sharedMk) must not mix cocos2d-x-2.2.6 into Upgrade30."
        }
    }
}

if (Assert-File $cocosAndroidMk) {
    $cocosMkText = Read-Text $cocosAndroidMk
    if ($cocosMkText -match "cocos2d-2\.0-rc2-x-2\.0\.1") {
        Add-Error "Cocos Android.mk must not import prebuilt libraries from cocos2d-2.0-rc2-x-2.0.1."
    }
    if ($EngineProfile -eq "Legacy226") {
        if ($cocosMkText -notmatch "\$\(call import-module,libxml2\)") {
            Add-Error "Cocos Android.mk must import libxml2 from the current $CocosRoot third_party prebuilt root."
        }
        if ($cocosMkText -notmatch "\$\(call import-module,libwebp\)") {
            Add-Error "Cocos Android.mk must import libwebp from the current $CocosRoot third_party prebuilt root."
        }
    }
    else {
        foreach ($module in @("freetype2/prebuilt/android", "chipmunk", "2d/platform/android")) {
            if ($cocosMkText -notmatch [regex]::Escape("`$(call import-module,$module)")) {
                Add-Error "Upgrade30 Cocos Android.mk must import $module."
            }
        }
    }
}

if ($EngineProfile -eq "Upgrade30" -and (Assert-File $cocosPlatformAndroidMk)) {
    $platformMkText = Read-Text $cocosPlatformAndroidMk
    foreach ($module in @("jpeg/prebuilt/android", "png/prebuilt/android", "tiff/prebuilt/android", "webp/prebuilt/android")) {
        if ($platformMkText -notmatch [regex]::Escape("`$(call import-module,$module)")) {
            Add-Error "Upgrade30 Android platform module must import $module."
        }
    }
}

if (Assert-File $ceguiAndroidMk) {
    $ceguiMkText = Read-Text $ceguiAndroidMk
    if ($EngineProfile -eq "Upgrade30") {
        if ($ceguiMkText -notmatch "CEGUI-0\.7\.9-r5" -or $ceguiMkText -notmatch "LOCAL_MODULE\s*:=\s*cegui_static") {
            Add-Error "Upgrade30 CEGUI Android module must build CEGUI-0.7.9-r5 as cegui_static."
        }
        if ($ceguiMkText -match "dependencies[/\\]cegui") {
            Add-Error "Upgrade30 CEGUI Android module must not import the 0.7.1 source tree."
        }
    }
}

foreach ($relative in $RequiredArm64StaticLibs) {
    $path = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Error "Missing arm64 static library: $relative"
    }
}

$versionedArm64StaticLibs = @($profile.VersionedStaticLibs)

if (Test-GitWorkTree) {
    foreach ($relative in $versionedArm64StaticLibs) {
        if (Test-GitIgnored $relative) {
            Add-Error "Arm64 static library is ignored by git and may drift on clean rebuilds: $relative"
        }
    }
}

foreach ($relative in $RequiredArm64InputSharedLibs) {
    $path = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Error "Missing arm64 input shared library: $relative"
    }
}

if ($RequireBuiltSharedLibs) {
    foreach ($relative in $RequiredArm64SharedLibs) {
        $path = Join-Path $repoRoot $relative
        if (-not (Test-Path -LiteralPath $path)) {
            Add-Error "Missing built arm64 shared library: $relative"
        }
    }
}

if (Assert-File $jnih) {
    $jniHeaderText = Read-Text $jnih
    if ($jniHeaderText -notmatch "setClassLoaderFrom") {
        Add-Error "JniHelper.h must expose setClassLoaderFrom for native-thread class loading."
    }
}

if (Assert-File $jnicpp) {
    $jniText = Read-Text $jnicpp
    if ($jniText -notmatch "JNI_VERSION_1_6") {
        Add-Error "JniHelper.cpp should use JNI_VERSION_1_6."
    }
    if ($jniText -notmatch "JNI_EDETACHED") {
        Add-Error "JniHelper.cpp must attach native threads only when GetEnv reports JNI_EDETACHED."
    }
    if ($jniText -notmatch "DetachCurrentThread") {
        Add-Error "JniHelper.cpp must detach JNI-attached native threads via TLS cleanup."
    }
    if ($jniText -notmatch "loadClass") {
        Add-Error "JniHelper.cpp must use cached ClassLoader.loadClass fallback for native threads."
    }
    if ($jniText -notmatch "classloader\s*=\s*env->NewGlobalRef\s*\(\s*_c\s*\)") {
        Add-Error "JniHelper.cpp must retain the Activity ClassLoader with a global reference."
    }
}

if (Assert-File $helperCpp) {
    $helperText = Read-Text $helperCpp
    if ($helperText -notmatch "JniHelper::setClassLoaderFrom\s*\(\s*activity\s*\)") {
        Add-Error "Cocos2dxHelper JNI bridge must initialize the cached Activity ClassLoader."
    }
    if ($helperText -notmatch "Java_org_cocos2dx_lib_Cocos2dxActivity_nativeInitJniBridge") {
        Add-Error "Cocos2dxActivity must expose nativeInitJniBridge for the real Locojoy Java entry."
    }
}

if (Assert-File $mainCpp) {
    $mainText = Read-Text $mainCpp
    if ($EngineProfile -eq "Upgrade30") {
        if ($mainText -match "JNI_OnLoad|Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInit") {
            Add-Error "Upgrade30 project main.cpp must leave JNI_OnLoad/nativeInit ownership to javaactivity.cpp."
        }
        if ($mainText -notmatch "cocos_android_app_init") {
            Add-Error "Upgrade30 project main.cpp must implement cocos_android_app_init."
        }
    }
    else {
        if ($mainText -notmatch "JNI_VERSION_1_6") {
            Add-Error "JNI_OnLoad in project main.cpp must return JNI_VERSION_1_6."
        }
        if ($mainText -match "JNI_VERSION_1_4") {
            Add-Error "Project main.cpp must not use JNI_VERSION_1_4."
        }
    }
}

foreach ($activityFile in $activityJavaFiles) {
    if (Assert-File $activityFile) {
        $activityText = Read-Text $activityFile
        $activityRelative = Get-RepoRelativePath $activityFile
        if ($activityText -notmatch "nativeInitJniBridge\s*\(") {
            Add-Error "$activityRelative must declare nativeInitJniBridge for JNI ClassLoader initialization."
        }
        if ($activityText -notmatch "(?s)nativeInitJniBridge\s*\(\s*this\s*\)\s*;.*nativeSetPaths\s*\(") {
            Add-Error "$activityRelative setPackageName must call nativeInitJniBridge(this) before nativeSetPaths."
        }
    }
}

if (Assert-File $glSurfaceJava) {
    $glText = Read-Text $glSurfaceJava
    if ($glText -notmatch "queueEvent") {
        Add-Error "Cocos2dxGLSurfaceView must dispatch native render/input work through GLSurfaceView.queueEvent."
    }
}

if (Assert-File $buildScript) {
    $buildText = Read-Text $buildScript
    if ($buildText -notmatch "RequireArm64InApk") {
        Add-Error "Ant packaging script must support RequireArm64InApk ABI gate."
    }
    if ($buildText -notmatch "Assert-ApkAbiContents") {
        Add-Error "Ant packaging script must run Assert-ApkAbiContents for arm64 packages."
    }
    if ($buildText -notmatch "Resolve-Jdk8Home" -or ($buildText -notmatch "JDK17\+" -and $buildText -notmatch "JDK9\+")) {
        Add-Error "Ant packaging script must force JDK8 and reject JDK9+/JDK17+."
    }
    if ($buildText -notmatch "Resolve-AndroidSdkRoot" -or $buildText -notmatch "tools\\ant\\build\.xml") {
        Add-Error "Ant packaging script must force a complete legacy Android SDK with tools\\ant\\build.xml."
    }
}

if (Assert-File $jdkGateScript) {
    $jdkGateText = Read-Text $jdkGateScript
    if ($jdkGateText -notmatch "JDK17\+" -or $jdkGateText -notmatch "1\\\.8") {
        Add-Error "JDK gate must explicitly require JDK8 and reject JDK17+."
    }
}

Write-Host "Android arm64 migration gate"
Write-Host "  ProjectDir : $projectAbs"
Write-Host "  Profile    : $EngineProfile"
Write-Host "  CocosRoot  : $CocosRoot"

if ($errors.Count -gt 0) {
    foreach ($err in $errors) {
        [Console]::Error.WriteLine("FAIL: $err")
    }
    exit 31
}

Write-Host "Gate passed: arm64 migration prerequisites are satisfied."
exit 0

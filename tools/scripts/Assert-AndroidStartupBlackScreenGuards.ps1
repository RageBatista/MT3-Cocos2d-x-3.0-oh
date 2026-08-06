param(
    [Parameter(Mandatory = $false)]
    [string]$RepoRoot = '',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Legacy226', 'Upgrade30')]
    [string]$EngineProfile = 'Upgrade30',

    [Parameter(Mandatory = $false)]
    [string]$GameApplicationPath = 'client/FireClient/Application/Framework/GameApplication.cpp',

    [Parameter(Mandatory = $false)]
    [string]$VideoEngineJniPath = '',

    [Parameter(Mandatory = $false)]
    [string]$Cocos2dxHelperJniPath = '',

    [Parameter(Mandatory = $false)]
    [string]$JniHelperPath = '',

    [Parameter(Mandatory = $false)]
    [string]$Cocos2dxActivityPath = 'client/android/LocojoyProject/src/org/cocos2dx/lib/Cocos2dxActivity.java',

    [Parameter(Mandatory = $false)]
    [string]$ZipUtilsPath = '',

    [Parameter(Mandatory = $false)]
    [string]$UISpineSpritePath = 'client/FireClient/Application/GameUI/UISpineSprite.cpp'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

if ($EngineProfile -eq 'Upgrade30') {
    if ([string]::IsNullOrWhiteSpace($Cocos2dxHelperJniPath)) {
        $Cocos2dxHelperJniPath = 'cocos2d-x-3.0-oh/cocos/2d/platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.cpp'
    }
    if ([string]::IsNullOrWhiteSpace($JniHelperPath)) {
        $JniHelperPath = 'cocos2d-x-3.0-oh/cocos/2d/platform/android/jni/JniHelper.cpp'
    }
    if ([string]::IsNullOrWhiteSpace($ZipUtilsPath)) {
        $ZipUtilsPath = 'cocos2d-x-3.0-oh/cocos/2d/ZipUtils.cpp'
    }
}
else {
    if ([string]::IsNullOrWhiteSpace($VideoEngineJniPath)) {
        $VideoEngineJniPath = 'cocos2d-x-2.2.6/cocos2dx/platform/android/jni/VideoEngineJni.cpp'
    }
    if ([string]::IsNullOrWhiteSpace($Cocos2dxHelperJniPath)) {
        $Cocos2dxHelperJniPath = 'cocos2d-x-2.2.6/cocos2dx/platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.cpp'
    }
    if ([string]::IsNullOrWhiteSpace($ZipUtilsPath)) {
        $ZipUtilsPath = 'cocos2d-x-2.2.6/cocos2dx/support/zip_support/ZipUtils.cpp'
    }
}

function Join-RepoPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    return Join-Path $RepoRoot $Path
}

$gamePath = Join-RepoPath -Path $GameApplicationPath
$videoJniPath = if ([string]::IsNullOrWhiteSpace($VideoEngineJniPath)) { $null } else { Join-RepoPath -Path $VideoEngineJniPath }
$helperJniPath = Join-RepoPath -Path $Cocos2dxHelperJniPath
$jniHelperPath = if ([string]::IsNullOrWhiteSpace($JniHelperPath)) { $null } else { Join-RepoPath -Path $JniHelperPath }
$activityPath = Join-RepoPath -Path $Cocos2dxActivityPath
$zipUtilsPath = Join-RepoPath -Path $ZipUtilsPath
$uiSpineSpritePath = Join-RepoPath -Path $UISpineSpritePath

$requiredPaths = @($gamePath, $helperJniPath, $activityPath, $zipUtilsPath, $uiSpineSpritePath)
if ($videoJniPath) {
    $requiredPaths += $videoJniPath
}
if ($jniHelperPath) {
    $requiredPaths += $jniHelperPath
}
foreach ($path in $requiredPaths) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Source file not found: $path"
    }
}

$gameSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $gamePath
$videoJniSource = if ($videoJniPath) { Get-Content -Raw -Encoding UTF8 -LiteralPath $videoJniPath } else { '' }
$helperJniSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $helperJniPath
$jniHelperSource = if ($jniHelperPath) { Get-Content -Raw -Encoding UTF8 -LiteralPath $jniHelperPath } else { '' }
$activitySource = Get-Content -Raw -Encoding UTF8 -LiteralPath $activityPath
$zipUtilsSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $zipUtilsPath
$uiSpineSpriteSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $uiSpineSpritePath

$errors = New-Object System.Collections.Generic.List[string]

if ($gameSource -notmatch 'START_CG_FALLBACK_MS') {
    $errors.Add("GameApplication has no timeout fallback for a start CG that never reports video events.")
}
if ($gameSource -notmatch 'CheckStartCGFallback') {
    $errors.Add("GameApplication OnTick must check start CG fallback after init finishes.")
}
if ($gameSource -notmatch 'CC_TARGET_PLATFORM\s*==\s*CC_PLATFORM_ANDROID' -or
    $gameSource -notmatch 'skip start CG on Android') {
    $errors.Add("GameApplication must not wait for the Android start CG while the VideoPlayer bridge is not linked into the Android build.")
}
foreach ($requiredLuaModule in @('utils.log', 'logic.luauimanager', 'logic.login.loginbackground', 'logic.login.logindlg')) {
    if ($gameSource -notmatch [regex]::Escape($requiredLuaModule)) {
        $errors.Add("GameApplication Android login bootstrap must require $requiredLuaModule before showing the quick login UI.")
    }
}
if ($gameSource -notmatch 'loginBg\.getInstanceAndShow' -or
    $gameSource -notmatch 'LoginQuickDialog\.getInstanceAndShow') {
    $errors.Add("GameApplication Android login bootstrap must show the login background before the quick login UI.")
}
if ($EngineProfile -eq 'Legacy226') {
    if ($videoJniSource -notmatch 'LOG_TAG\s+"VideoEngineJni"') {
        $errors.Add("VideoEngineJni must log bridge calls and failures.")
    }
    if ($videoJniSource -notmatch 'ExceptionCheck\(\)') {
        $errors.Add("VideoEngineJni must clear Java exceptions after JNI calls.")
    }
}
else {
    if ($helperJniSource -notmatch 'nativeInitJniBridge' -or
        $helperJniSource -notmatch 'setClassLoaderFrom') {
        $errors.Add("Upgrade30 helper JNI must initialize the Activity class loader bridge.")
    }
    if ($activitySource -notmatch 'nativeInitJniBridge\s*\(this\)') {
        $errors.Add("Cocos2dxActivity must initialize the Upgrade30 JNI bridge before native calls.")
    }
    if ($jniHelperSource -notmatch 'ExceptionCheck\(\)') {
        $errors.Add("Upgrade30 JniHelper must clear failed class and method lookup exceptions.")
    }
}
if ($helperJniSource -match '#define\s+CLASS_NAME\s+"org/cocos2dx/lib/Cocos2dxHelper"') {
    $errors.Add("Cocos2dxHelper native bridge targets a Java class that is not compiled by LocojoyProject.")
}
if ($activitySource -notmatch 'getBoolForKey\s*\(' -or $activitySource -notmatch 'setBoolForKey\s*\(') {
    $errors.Add("Cocos2dxActivity must expose SharedPreferences methods used by CCUserDefault.")
}
if ($zipUtilsSource -notmatch 's_zipFileReadMutex' -or
    $zipUtilsSource -notmatch 'ZipFileReadLock' -or
    $zipUtilsSource -notmatch 'pthread_mutex_lock') {
    $errors.Add("ZipUtils must serialize Android APK zip reads to avoid CEGUI/LJFM resource-thread crashes in unzReadCurrentFile.")
}
$ctorStart = $uiSpineSpriteSource.IndexOf('UISpineSprite::UISpineSprite')
$dtorStart = $uiSpineSpriteSource.IndexOf('UISpineSprite::~UISpineSprite', [Math]::Max($ctorStart, 0))
$uiSpineCtor = if ($ctorStart -ge 0 -and $dtorStart -gt $ctorStart) {
    $uiSpineSpriteSource.Substring($ctorStart, $dtorStart - $ctorStart)
} else {
    ''
}
if ($uiSpineCtor -notmatch 'SetDefaultAction\(eActionStand\)' -or
    $uiSpineCtor -notmatch 'PlayAction\(eActionStand\)') {
    $errors.Add("UISpineSprite constructor must start the default stand action in native code; Lua/resources are not the Android fix point.")
}

Write-Host "Android Startup Black Screen Guard"
Write-Host "  Profile         : $EngineProfile"
Write-Host "  GameApplication : $gamePath"
if ($videoJniPath) {
    Write-Host "  VideoEngineJni  : $videoJniPath"
}
Write-Host "  Helper JNI      : $helperJniPath"
if ($jniHelperPath) {
    Write-Host "  JniHelper       : $jniHelperPath"
}
Write-Host "  Activity        : $activityPath"
Write-Host "  ZipUtils        : $zipUtilsPath"
Write-Host "  UI Spine Sprite : $uiSpineSpritePath"

if ($errors.Count -gt 0) {
    foreach ($err in $errors) {
        [Console]::Error.WriteLine($err)
    }
    exit 33
}

Write-Host "Gate passed: Android $EngineProfile startup guards, login bootstrap, UI Spine action, JNI bridge, UserDefault bridge, ZIP serialization, and CG fallback are present."
exit 0

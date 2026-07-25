param(
    [Parameter(Mandatory = $false)]
    [string]$RepoRoot = '',

    [Parameter(Mandatory = $false)]
    [string]$GameApplicationPath = 'client/FireClient/Application/Framework/GameApplication.cpp',

    [Parameter(Mandatory = $false)]
    [string]$VideoEngineJniPath = 'cocos2d-x-2.2.6/cocos2dx/platform/android/jni/VideoEngineJni.cpp',

    [Parameter(Mandatory = $false)]
    [string]$Cocos2dxHelperJniPath = 'cocos2d-x-2.2.6/cocos2dx/platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.cpp',

    [Parameter(Mandatory = $false)]
    [string]$Cocos2dxActivityPath = 'client/android/LocojoyProject/src/org/cocos2dx/lib/Cocos2dxActivity.java',

    [Parameter(Mandatory = $false)]
    [string]$ZipUtilsPath = 'cocos2d-x-2.2.6/cocos2dx/support/zip_support/ZipUtils.cpp',

    [Parameter(Mandatory = $false)]
    [string]$UISpineSpritePath = 'client/FireClient/Application/GameUI/UISpineSprite.cpp'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Join-RepoPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    return Join-Path $RepoRoot $Path
}

$gamePath = Join-RepoPath -Path $GameApplicationPath
$videoJniPath = Join-RepoPath -Path $VideoEngineJniPath
$helperJniPath = Join-RepoPath -Path $Cocos2dxHelperJniPath
$activityPath = Join-RepoPath -Path $Cocos2dxActivityPath
$zipUtilsPath = Join-RepoPath -Path $ZipUtilsPath
$uiSpineSpritePath = Join-RepoPath -Path $UISpineSpritePath

foreach ($path in @($gamePath, $videoJniPath, $helperJniPath, $activityPath, $zipUtilsPath, $uiSpineSpritePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Source file not found: $path"
    }
}

$gameSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $gamePath
$videoJniSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $videoJniPath
$helperJniSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $helperJniPath
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
if ($videoJniSource -notmatch 'LOG_TAG\s+"VideoEngineJni"') {
    $errors.Add("VideoEngineJni must log bridge calls and failures.")
}
if ($videoJniSource -notmatch 'ExceptionCheck\(\)') {
    $errors.Add("VideoEngineJni must clear Java exceptions after JNI calls.")
}
if ($helperJniSource -match '#define\s+CLASS_NAME\s+"org/cocos2dx/lib/Cocos2dxHelper"') {
    $errors.Add("Cocos2dxHelper native bridge still targets missing Cocos2dxHelper instead of project Activity.")
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
Write-Host "  GameApplication : $gamePath"
Write-Host "  VideoEngineJni  : $videoJniPath"
Write-Host "  Helper JNI      : $helperJniPath"
Write-Host "  Activity        : $activityPath"
Write-Host "  ZipUtils        : $zipUtilsPath"
Write-Host "  UI Spine Sprite : $uiSpineSpritePath"

if ($errors.Count -gt 0) {
    foreach ($err in $errors) {
        [Console]::Error.WriteLine($err)
    }
    exit 33
}

Write-Host "Gate passed: Android startup skips the unlinked CG bridge, restores login bootstrap, starts UI Spine default actions in native code, serializes APK zip reads, has video JNI diagnostics, UserDefault bridge, and CG fallback."
exit 0

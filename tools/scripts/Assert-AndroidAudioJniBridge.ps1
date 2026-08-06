param(
    [Parameter(Mandatory = $false)]
    [string]$RepoRoot = '',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Legacy226', 'Upgrade30')]
    [string]$EngineProfile = 'Upgrade30',

    [Parameter(Mandatory = $false)]
    [string]$SimpleAudioEnginePath = '',

    [Parameter(Mandatory = $false)]
    [string]$SimpleAudioEngineJniPath = '',

    [Parameter(Mandatory = $false)]
    [string]$JniHelperPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

if ($EngineProfile -eq 'Upgrade30') {
    if ([string]::IsNullOrWhiteSpace($SimpleAudioEnginePath)) {
        $SimpleAudioEnginePath = 'cocos2d-x-3.0-oh/cocos/audio/android/cddSimpleAudioEngine.cpp'
    }
    if ([string]::IsNullOrWhiteSpace($SimpleAudioEngineJniPath)) {
        $SimpleAudioEngineJniPath = 'cocos2d-x-3.0-oh/cocos/audio/android/jni/cddandroidAndroidJavaEngine.cpp'
    }
    if ([string]::IsNullOrWhiteSpace($JniHelperPath)) {
        $JniHelperPath = 'cocos2d-x-3.0-oh/cocos/2d/platform/android/jni/JniHelper.cpp'
    }
}
else {
    if ([string]::IsNullOrWhiteSpace($SimpleAudioEnginePath)) {
        $SimpleAudioEnginePath = 'cocos2d-x-2.2.6/CocosDenshion/android/SimpleAudioEngine.cpp'
    }
    if ([string]::IsNullOrWhiteSpace($SimpleAudioEngineJniPath)) {
        $SimpleAudioEngineJniPath = 'cocos2d-x-2.2.6/CocosDenshion/android/jni/SimpleAudioEngineJni.cpp'
    }
}

function Join-RepoPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    return Join-Path $RepoRoot $Path
}

$enginePath = Join-RepoPath -Path $SimpleAudioEnginePath
$jniPath = Join-RepoPath -Path $SimpleAudioEngineJniPath
$helperPath = if ([string]::IsNullOrWhiteSpace($JniHelperPath)) { $null } else { Join-RepoPath -Path $JniHelperPath }

if (-not (Test-Path -LiteralPath $enginePath -PathType Leaf)) {
    throw "Source file not found: $enginePath"
}
if (-not (Test-Path -LiteralPath $jniPath -PathType Leaf)) {
    throw "Source file not found: $jniPath"
}
if ($helperPath -and -not (Test-Path -LiteralPath $helperPath -PathType Leaf)) {
    throw "Source file not found: $helperPath"
}

$engineSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $enginePath
$jniSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $jniPath
$helperSource = if ($helperPath) { Get-Content -Raw -Encoding UTF8 -LiteralPath $helperPath } else { '' }

$errors = New-Object System.Collections.Generic.List[string]

if ($EngineProfile -eq 'Upgrade30') {
    if ($engineSource -notmatch 's_audioClassName\s*=\s*"org/cocos2dx/lib/Cocos2dxActivity"') {
        $errors.Add("Upgrade30 SimpleAudioEngine must target Cocos2dxActivity.")
    }
    if ($engineSource -notmatch 'getMT3AudioMethodInfo' -or
        $engineSource -notmatch 'if\s*\(\s*!\s*getMT3AudioMethodInfo') {
        $errors.Add("Upgrade30 SimpleAudioEngine must guard MT3 audio JNI lookups.")
    }
    if ($jniSource -notmatch '#define\s+CLASS_NAME\s+"org/cocos2dx/lib/Cocos2dxActivity"') {
        $errors.Add("Upgrade30 AndroidJavaEngine must target Cocos2dxActivity.")
    }
    if ($jniSource -notmatch 'getJNIStaticMethodInfo' -or
        $jniSource -notmatch 'if\s*\(\s*!\s*getJNIStaticMethodInfo') {
        $errors.Add("Upgrade30 AndroidJavaEngine must return safely when JNI lookup fails.")
    }
    if ($helperSource -notmatch 'ExceptionCheck\(\)') {
        $errors.Add("Upgrade30 JniHelper must clear Java exceptions after failed class or method lookup.")
    }
}
else {
    if ($engineSource -match 'jstring\s+jstr\s*;') {
        $errors.Add("SimpleAudioEngine constructor declares an uninitialized jstring.")
    }
    if ($engineSource -notmatch 'if\s*\(\s*!\s*JniHelper::getStaticMethodInfo') {
        $errors.Add("SimpleAudioEngine constructor must return safely when getDeviceModel JNI lookup fails.")
    }
    if ($engineSource -notmatch 'methodInfo\.classID\s*!=\s*NULL') {
        $errors.Add("SimpleAudioEngine constructor must guard classID before DeleteLocalRef.")
    }
    if ($jniSource -match '#define\s+CLASS_NAME\s+"org/cocos2dx/lib/Cocos2dxHelper"') {
        $errors.Add("SimpleAudioEngineJni targets Cocos2dxHelper, but LocojoyProject exposes audio methods on Cocos2dxActivity.")
    }
    if ($jniSource -notmatch 'if\s*\(\s*!\s*classID\s*\)') {
        $errors.Add("SimpleAudioEngineJni getStaticMethodInfo must guard a missing Java class before GetStaticMethodID.")
    }
    if ($jniSource -notmatch 'ExceptionCheck\(\)') {
        $errors.Add("SimpleAudioEngineJni must clear Java exceptions after failed class or method lookup/call.")
    }
}

Write-Host "Android Audio JNI Bridge Gate"
Write-Host "  Profile              : $EngineProfile"
Write-Host "  SimpleAudioEngine    : $enginePath"
Write-Host "  SimpleAudioEngineJni : $jniPath"
if ($helperPath) {
    Write-Host "  JniHelper            : $helperPath"
}

if ($errors.Count -gt 0) {
    foreach ($err in $errors) {
        [Console]::Error.WriteLine($err)
    }
    exit 32
}

Write-Host "Gate passed: Android audio JNI bridge matches LocojoyProject and handles lookup failures."
exit 0

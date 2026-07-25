param(
    [Parameter(Mandatory = $false)]
    [string]$RepoRoot = '',

    [Parameter(Mandatory = $false)]
    [string]$SimpleAudioEnginePath = 'cocos2d-x-2.2.6/CocosDenshion/android/SimpleAudioEngine.cpp',

    [Parameter(Mandatory = $false)]
    [string]$SimpleAudioEngineJniPath = 'cocos2d-x-2.2.6/CocosDenshion/android/jni/SimpleAudioEngineJni.cpp'
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

$enginePath = Join-RepoPath -Path $SimpleAudioEnginePath
$jniPath = Join-RepoPath -Path $SimpleAudioEngineJniPath

if (-not (Test-Path -LiteralPath $enginePath -PathType Leaf)) {
    throw "Source file not found: $enginePath"
}
if (-not (Test-Path -LiteralPath $jniPath -PathType Leaf)) {
    throw "Source file not found: $jniPath"
}

$engineSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $enginePath
$jniSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $jniPath

$errors = New-Object System.Collections.Generic.List[string]

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

Write-Host "Android Audio JNI Bridge Gate"
Write-Host "  SimpleAudioEngine    : $enginePath"
Write-Host "  SimpleAudioEngineJni : $jniPath"

if ($errors.Count -gt 0) {
    foreach ($err in $errors) {
        [Console]::Error.WriteLine($err)
    }
    exit 32
}

Write-Host "Gate passed: Android audio JNI bridge matches LocojoyProject and handles lookup failures."
exit 0

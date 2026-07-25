[CmdletBinding()]
param(
    [string]$CocosDir = 'cocos2d-x-2.2.6',
    [string]$LegacyDir = 'cocos2d-2.0-rc2-x-2.0.1',
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $PathValue))
}

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($stream)) -replace '-', '').ToLowerInvariant()
    }
    finally {
        $stream.Dispose()
        $sha.Dispose()
    }
}

function Get-RelativeFileMap {
    param([Parameter(Mandatory = $true)][string]$Root)
    $map = @{}
    if (-not (Test-Path $Root)) { return $map }
    Get-ChildItem -Path $Root -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch '\\.git(\\|$)' -and
            $_.Name -notin @('MT3_UPSTREAM.md', 'MT3_PATCHES.md')
        } |
        ForEach-Object {
            $rel = $_.FullName.Substring($Root.Length).TrimStart('\', '/') -replace '\\', '/'
            $map[$rel] = $_.FullName
        }
    return $map
}

function Compare-TreeFingerprint {
    param(
        [Parameter(Mandatory = $true)][string]$CurrentRoot,
        [Parameter(Mandatory = $true)][string]$LegacyRoot
    )
    $cur = Get-RelativeFileMap -Root $CurrentRoot
    $legacy = Get-RelativeFileMap -Root $LegacyRoot
    $common = @($cur.Keys | Where-Object { $legacy.ContainsKey($_) })
    $same = 0
    foreach ($rel in $common) {
        $a = Get-Item -LiteralPath $cur[$rel]
        $b = Get-Item -LiteralPath $legacy[$rel]
        if ($a.Length -eq $b.Length -and (Get-Sha256 -Path $a.FullName) -eq (Get-Sha256 -Path $b.FullName)) {
            $same++
        }
    }
    $commonCount = $common.Count
    $sameRatio = 0.0
    if ($commonCount -gt 0) { $sameRatio = [Math]::Round($same / $commonCount, 6) }
    return [PSCustomObject]@{
        CurrentFileCount = $cur.Count
        LegacyFileCount = $legacy.Count
        CommonFileCount = $commonCount
        SameFileCount = $same
        SameRatio = $sameRatio
        CurrentOnlyCount = $cur.Count - $commonCount
        LegacyOnlyCount = $legacy.Count - $commonCount
    }
}

function New-Result {
    param(
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)][string]$Summary,
        [Parameter(Mandatory = $true)][object]$Data,
        [string[]]$Failures = @()
    )
    return [PSCustomObject]@{
        status = $Status
        summary = $Summary
        failures = $Failures
        data = $Data
    }
}

function Assert-TextPattern {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Message,
        [System.Collections.Generic.List[string]]$Failures
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        $Failures.Add("Missing file for source gate: $Path") | Out-Null
        return
    }
    $text = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    if ($text -notmatch $Pattern) {
        $Failures.Add($Message) | Out-Null
    }
}

$repoRoot = Get-RepoRoot
$cocosRoot = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $CocosDir
$legacyRoot = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $LegacyDir
$failures = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path $cocosRoot)) {
    $failures.Add("Cocos directory not found: $cocosRoot") | Out-Null
}

$requiredPaths = @(
    'cocos2dx/cocos2d.cpp',
    'cocos2dx/include/cocos2d.h',
    'cocos2dx/proj.win32/cocos2d.vcxproj',
    'CocosDenshion/proj.win32/CocosDenshion.vcxproj',
    'scripting/lua/proj.win32/liblua.vcxproj',
    'external/Box2D/proj.win32/Box2D.vcxproj',
    'external/chipmunk/proj.win32/chipmunk.vcxproj',
    'extensions/proj.win32/libExtensions.vcxproj',
    'extensions/spine/spine-cocos2dx.h'
)

$forbiddenPaths = @(
    'Box2D',
    'chipmunk',
    'lua',
    'extensions/libSpine',
    'cocos2dx/proj.win32/cocos2d-win32.vcxproj'
)

$missing = New-Object System.Collections.Generic.List[string]
foreach ($rel in $requiredPaths) {
    if (-not (Test-Path (Join-Path $cocosRoot ($rel -replace '/', '\')))) {
        $missing.Add($rel) | Out-Null
    }
}
if ($missing.Count -gt 0) {
    $failures.Add('Missing required official 2.2.6 paths: ' + ($missing -join '; ')) | Out-Null
}

$legacyPresent = New-Object System.Collections.Generic.List[string]
foreach ($rel in $forbiddenPaths) {
    if (Test-Path (Join-Path $cocosRoot ($rel -replace '/', '\'))) {
        $legacyPresent.Add($rel) | Out-Null
    }
}
if ($legacyPresent.Count -gt 0) {
    $failures.Add('Legacy 2.0.x layout paths still present: ' + ($legacyPresent -join '; ')) | Out-Null
}

$versionCpp = Join-Path $cocosRoot 'cocos2dx\cocos2d.cpp'
$versionHeader = Join-Path $cocosRoot 'cocos2dx\include\cocos2d.h'
$cppHas226 = $false
$headerHas226 = $false
if (Test-Path $versionCpp) {
    $cppHas226 = ([System.IO.File]::ReadAllText($versionCpp, [System.Text.Encoding]::UTF8) -match 'cocos2d-x 2\.2\.6')
}
if (Test-Path $versionHeader) {
    $headerHas226 = ([System.IO.File]::ReadAllText($versionHeader, [System.Text.Encoding]::UTF8) -match '0x00020206')
}
if (-not $cppHas226) { $failures.Add('Missing cocos2d-x 2.2.6 marker in cocos2dx/cocos2d.cpp') | Out-Null }
if (-not $headerHas226) { $failures.Add('Missing COCOS2D_VERSION 0x00020206 in cocos2dx/include/cocos2d.h') | Out-Null }

$spineGateChecks = @(
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\Attachment.h'; Pattern = 'ATTACHMENT_SKINNED_MESH'; Message = 'Spine attachment enum must include skinnedmesh.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\SkeletonJson.cpp'; Pattern = 'strcmp\(typeString,\s*"skinnedmesh"\)'; Message = 'SkeletonJson must parse skinnedmesh attachments.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\SkeletonJson.cpp'; Pattern = 'SkinnedMeshAttachment_updateUVs'; Message = 'SkeletonJson must initialize skinnedmesh UVs.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\AtlasAttachmentLoader.cpp'; Pattern = 'ATTACHMENT_SKINNED_MESH'; Message = 'AtlasAttachmentLoader must create skinnedmesh attachments.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\MeshAttachment.h'; Pattern = 'SkinnedMeshAttachment_computeWorldVertices'; Message = 'SkinnedMeshAttachment world-vertex API must be declared.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\MeshAttachment.cpp'; Pattern = 'SkinnedMeshAttachment_computeWorldVertices'; Message = 'SkinnedMeshAttachment world-vertex API must be implemented.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\spine-cocos2dx.cpp'; Pattern = 'SkinnedMeshAttachment_updateQuad'; Message = 'Cocos2d-x bridge must render skinnedmesh triangles.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\CCSkeleton.cpp'; Pattern = 'ATTACHMENT_SKINNED_MESH'; Message = 'CCSkeleton must draw and bound skinnedmesh attachments.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\spine\CCSkeletonAnimation.cpp'; Pattern = 'restoreProgram->setUniformsForBuiltins\(\)'; Message = 'CCSkeletonAnimation must restore shader MVP after Spine draw.' },
    [PSCustomObject]@{ Path = Join-Path $cocosRoot 'extensions\Android.mk'; Pattern = 'spine/MeshAttachment\.cpp'; Message = 'Android extension build must compile MeshAttachment.cpp.' },
    [PSCustomObject]@{ Path = Join-Path $repoRoot 'client\resource\res\script\logic\createroledialog.lua'; Pattern = 'local instance = CCreateRoleDialog:getInstanceOrNot\(\)'; Message = 'Create-role post-render hook must not recreate the dialog singleton.' }
)
foreach ($check in $spineGateChecks) {
    Assert-TextPattern -Path $check.Path -Pattern $check.Pattern -Message $check.Message -Failures $failures
}

$modelRoot = Join-Path $repoRoot 'client\resource\res\model'
if (Test-Path -LiteralPath $modelRoot) {
    $skinnedMeshResources = Get-ChildItem -LiteralPath $modelRoot -Directory -Filter 'spinemh_*' |
        ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Filter '*.json' -File -ErrorAction SilentlyContinue } |
        Select-String -Pattern '"type"\s*:\s*"skinnedmesh"' -Encoding UTF8
    if (-not $skinnedMeshResources) {
        $failures.Add('No create-role spinemh_* resource currently exercises skinnedmesh.') | Out-Null
    }
} else {
    $failures.Add("Missing create-role model directory: $modelRoot") | Out-Null
}

$fingerprint = $null
if ((Test-Path $cocosRoot) -and (Test-Path $legacyRoot)) {
    $fingerprint = Compare-TreeFingerprint -CurrentRoot $cocosRoot -LegacyRoot $legacyRoot
    if ($fingerprint.CommonFileCount -gt 5000 -and $fingerprint.SameRatio -ge 0.90) {
        $failures.Add(("Cocos directory is too similar to legacy tree: common={0}, same={1}, ratio={2}" -f $fingerprint.CommonFileCount, $fingerprint.SameFileCount, $fingerprint.SameRatio)) | Out-Null
    }
}

$data = [PSCustomObject]@{
    RepoRoot = $repoRoot
    CocosRoot = $cocosRoot
    LegacyRoot = $legacyRoot
    RequiredPaths = $requiredPaths
    ForbiddenPaths = $forbiddenPaths
    MissingRequiredPaths = @($missing)
    LegacyPathsPresent = @($legacyPresent)
    VersionCppHas226 = $cppHas226
    VersionHeaderHas226 = $headerHas226
    FingerprintVsLegacy = $fingerprint
}

if ($failures.Count -gt 0) {
    $result = New-Result -Status 'FAIL' -Summary 'Cocos2d-x 2.2.6 source gate failed.' -Data $data -Failures @($failures)
    if ($Json) { $result | ConvertTo-Json -Depth 8 } else { $result | Format-List }
    exit 1
}

$result = New-Result -Status 'PASS' -Summary 'Cocos2d-x 2.2.6 source gate passed.' -Data $data
if ($Json) { $result | ConvertTo-Json -Depth 8 } else { $result | Format-List }

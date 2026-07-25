param(
    [Parameter(Mandatory = $true)]
    [string]$TargetDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$solutionOutput = Join-Path $repoRoot 'tools\CELayoutEditor-0.7.1\vc++12\Release.win32'
$ceguiReleaseOutput = Join-Path $repoRoot 'tools\CEGUI-0.7.1\projects\premake\Release.win32'
$target = [IO.Path]::GetFullPath($TargetDir)

function Get-SHA256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    $stream = [IO.File]::OpenRead($Path)
    try {
        $sha256 = [Security.Cryptography.SHA256]::Create()
        try {
            return ([BitConverter]::ToString($sha256.ComputeHash($stream))).Replace('-', '')
        }
        finally {
            $sha256.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $target -PathType Container)) {
    throw "CELayoutEditor runtime target directory does not exist: $target"
}

if (-not (Test-Path -LiteralPath $ceguiReleaseOutput -PathType Container)) {
    throw "CEGUI release output directory does not exist: $ceguiReleaseOutput"
}

$ceguiModules = @(
    'CEGUIBase.dll',
    'CEGUIExpatParser.dll',
    'CEGUIFalagardWRBase.dll',
    'CEGUIOpenGLRenderer.dll',
    'CEGUISILLYImageCodec.dll'
)

$requiredRuntime = @(
    'CELayoutEditor.exe',
    'CELayoutEditor.ini',
    'CELayoutEditor.properties.ini',
    'glew32.dll',
    'iconv.dll',
    'libcocos2d.dll',
    'libtiff.dll',
    'libxml2.dll',
    'msvcp120.dll',
    'msvcr120.dll',
    'pthreadVCE2.dll',
    'SILLY.dll',
    'zlib1.dll'
)

$missing = @(
    foreach ($name in $requiredRuntime) {
        $path = Join-Path $target $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $path
        }
    }

    foreach ($name in $ceguiModules) {
        $path = Join-Path $solutionOutput $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $path
        }
    }
)

if ($missing.Count -gt 0) {
    throw "CELayoutEditor runtime is incomplete:`n$($missing -join "`n")"
}

foreach ($destinationRoot in @($target, $ceguiReleaseOutput)) {
    foreach ($name in $ceguiModules) {
        $source = Join-Path $solutionOutput $name
        $destination = Join-Path $destinationRoot $name
        Copy-Item -LiteralPath $source -Destination $destination -Force

        $sourceHash = Get-SHA256 -Path $source
        $destinationHash = Get-SHA256 -Path $destination
        if ($sourceHash -ne $destinationHash) {
            throw "CEGUI runtime hash mismatch after copy: $destination"
        }
    }
}

Write-Host "CELayoutEditor runtime synchronized: $target"

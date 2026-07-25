param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    [ValidateSet('Win32')]
    [string]$Platform = 'Win32',
    [string]$Runtime = 'win-x64',
    [switch]$SelfContained
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Copy-GuiArtifacts {
    param(
        [string]$SourceDir,
        [string]$TargetDir
    )

    Get-ChildItem -Path $SourceDir -File | Where-Object { $_.Extension -ne '.pdb' } | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $TargetDir -Force
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir '..\..\..')).Path
$toolRoot = Join-Path $repoRoot 'tools\LJFilePackUnpacker'
$superRoot = Join-Path $repoRoot 'dependencies\SuperLJFilePackUnpack'
$guiRoot = Join-Path $toolRoot 'gui-mvp'
$cliBuildDir = Join-Path $superRoot 'build'
$distDir = Join-Path $toolRoot 'dist\mvp'
$sharedToolRuntimeDir = Join-Path $repoRoot 'client\resource\tools'
$msbuild = 'msbuild'

$libProj = Join-Path $cliBuildDir 'SuperLJFilePackUnpack.vcxproj'
if (-not (Test-Path $libProj)) {
    throw "未找到原生库工程: $libProj"
}

$cliProjectPath = $null
$cliExecutableName = $null
$cliFlavor = $null

$legacyExampleProj = Join-Path $cliBuildDir 'UnpackExample.vcxproj'
$legacyCliProj = Join-Path $cliBuildDir 'ljfp-unpack.vcxproj'
$diagnosticCliProj = Join-Path $cliBuildDir 'ljfp-unpack-diag.vcxproj'

if (Test-Path $legacyExampleProj) {
    $cliProjectPath = $legacyExampleProj
    $cliExecutableName = 'ljfp-unpack.exe'
    $cliFlavor = 'legacy'
}
elseif (Test-Path $legacyCliProj) {
    $cliProjectPath = $legacyCliProj
    $cliExecutableName = 'ljfp-unpack.exe'
    $cliFlavor = 'legacy'
}
elseif (Test-Path $diagnosticCliProj) {
    $cliProjectPath = $diagnosticCliProj
    $cliExecutableName = 'ljfp-unpack-diag.exe'
    $cliFlavor = 'diagnostic'
}
else {
    throw "未找到可构建的 CLI 工程。候选工程: $legacyExampleProj; $legacyCliProj; $diagnosticCliProj"
}

Write-Host "===> [1/3] Build native CLI unpacker ($cliExecutableName)" -ForegroundColor Cyan
& $msbuild $libProj /p:Configuration=$Configuration /p:Platform=$Platform /m /nologo
if ($LASTEXITCODE -ne 0) {
    throw "构建 SuperLJFilePackUnpack.vcxproj 失败，退出码: $LASTEXITCODE"
}

& $msbuild $cliProjectPath /p:Configuration=$Configuration /p:Platform=$Platform /m /nologo
if ($LASTEXITCODE -ne 0) {
    throw "构建 $([System.IO.Path]::GetFileName($cliProjectPath)) 失败，退出码: $LASTEXITCODE"
}

$cliExeCandidates = @(
    (Join-Path $cliBuildDir "bin\$Configuration\$cliExecutableName"),
    (Join-Path $cliBuildDir "bin\$cliExecutableName"),
    (Join-Path $superRoot "out\mvp_cli_manual\$cliExecutableName")
)

$cliExe = $null
foreach ($candidate in $cliExeCandidates) {
    if (Test-Path $candidate) {
        $cliExe = $candidate
        break
    }
}

if (-not $cliExe) {
    throw "未找到 CLI 可执行文件。候选路径: $($cliExeCandidates -join '; ')"
}

Write-Host "Selected backend CLI: $cliExe" -ForegroundColor DarkGray
Write-Host "===> [2/3] Build/publish WinForms GUI" -ForegroundColor Cyan

if (Test-Path $distDir) {
    $resolvedDistDir = (Resolve-Path $distDir).Path
    if (-not $resolvedDistDir.StartsWith($toolRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "拒绝删除目标目录：$resolvedDistDir"
    }
    Remove-Item -LiteralPath $resolvedDistDir -Recurse -Force
}

New-Item -ItemType Directory -Path $distDir | Out-Null

if (-not $SelfContained) {
    & dotnet build $guiRoot -c $Configuration
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet build 失败，退出码: $LASTEXITCODE"
    }

    $buildOutputDir = Join-Path $guiRoot "bin\$Configuration\net10.0-windows"
    Copy-GuiArtifacts -SourceDir $buildOutputDir -TargetDir $distDir
}
else {
    $publishArgs = @(
        'publish',
        $guiRoot,
        '-c', $Configuration,
        '-r', $Runtime,
        '-o', $distDir,
        '-p:PublishSingleFile=true',
        '-p:IncludeNativeLibrariesForSelfExtract=true',
        '--self-contained', 'true'
    )
    & dotnet @publishArgs
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish 失败，退出码: $LASTEXITCODE"
    }

    Get-ChildItem -Path $distDir -Filter '*.pdb' -File -ErrorAction SilentlyContinue | Remove-Item -Force
}

Write-Host "===> [3/3] Copy CLI into GUI output folder" -ForegroundColor Cyan
Copy-Item -LiteralPath $cliExe -Destination (Join-Path $distDir ([System.IO.Path]::GetFileName($cliExe))) -Force
Copy-Item -LiteralPath (Join-Path $guiRoot 'README.md') -Destination (Join-Path $distDir 'README-MVP-GUI.md') -Force

foreach ($runtimeDll in @('MSVCP120.dll', 'MSVCR120.dll')) {
    $runtimeSource = Join-Path $sharedToolRuntimeDir $runtimeDll
    if (-not (Test-Path $runtimeSource)) {
        throw "未找到共享运行库: $runtimeSource"
    }

    Copy-Item -LiteralPath $runtimeSource -Destination (Join-Path $distDir $runtimeDll) -Force
}

$mvpExe = Join-Path $distDir 'LJFilePackUnpacker.MvpGui.exe'
if (-not (Test-Path $mvpExe)) {
    throw "未找到 GUI 可执行文件: $mvpExe"
}

Write-Host ''
Write-Host "Build completed. Output folder:" -ForegroundColor Green
Write-Host "  $distDir" -ForegroundColor Green
Write-Host ''
Write-Host "Executable:" -ForegroundColor Green
Write-Host "  $mvpExe" -ForegroundColor Green
Write-Host "  Backend CLI: $([System.IO.Path]::GetFileName($cliExe)) ($cliFlavor)" -ForegroundColor Green

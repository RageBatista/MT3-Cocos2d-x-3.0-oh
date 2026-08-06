[CmdletBinding()]
param(
    [string]$NdkBuildPath = "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd",
    [string]$CacheDir = "build/android-upgrade30-deps",
    [int]$Jobs = 4,
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Checked {
    param([scriptblock]$Command, [string]$Message)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Message (exit code: $LASTEXITCODE)"
    }
}

function Assert-ArchiveHash {
    param([string]$Path, [string]$Expected)
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if (-not [string]::Equals($actual, $Expected, [StringComparison]::OrdinalIgnoreCase)) {
        throw "SHA-256 mismatch for $Path. Expected $Expected, actual $actual."
    }
}

$repoRoot = (& git rev-parse --show-toplevel).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
    throw "Run this script from the MT3 Git work tree."
}
$repoRoot = (Resolve-Path -LiteralPath $repoRoot).Path

if (-not (Test-Path -LiteralPath $NdkBuildPath -PathType Leaf)) {
    throw "NDK r16 ndk-build was not found: $NdkBuildPath"
}
$ndkRoot = Split-Path -Parent $NdkBuildPath
$sourceProperties = Join-Path $ndkRoot "source.properties"
$revision = Get-Content -Raw -Encoding UTF8 $sourceProperties
if ($revision -notmatch "Pkg\.Revision\s*=\s*16\.") {
    throw "Upgrade30 arm64 prebuilts are pinned to NDK r16. Found: $revision"
}

$cacheRoot = if ([IO.Path]::IsPathRooted($CacheDir)) {
    [IO.Path]::GetFullPath($CacheDir)
}
else {
    [IO.Path]::GetFullPath((Join-Path $repoRoot $CacheDir))
}
$buildRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot "client/android/native/upgrade30-prebuilts"))
$downloadRoot = Join-Path $cacheRoot "downloads"
$sourceRoot = Join-Path $cacheRoot "src"

New-Item -ItemType Directory -Force -Path $downloadRoot, $sourceRoot | Out-Null

$dependencies = @(
    [pscustomobject]@{
        Name = "freetype"
        Archive = "freetype-2.5.0.tar.gz"
        Url = "https://github.com/freetype/freetype/archive/refs/tags/VER-2-5-0.tar.gz"
        Sha256 = "EE4830B4A68998569C2B8B3C49A87D4D29AF9358EA83CDEB78C1AD26ECF6BEA8"
        SourceDir = "freetype-VER-2-5-0"
    },
    [pscustomobject]@{
        Name = "jpeg"
        Archive = "jpegsrc.v9.tar.gz"
        Url = "https://www.ijg.org/files/jpegsrc.v9.tar.gz"
        Sha256 = "6E004D72F9108014CACCF434095514C139478C72B6B1873A3E3807EA5BEC5C59"
        SourceDir = "jpeg-9"
    },
    [pscustomobject]@{
        Name = "png"
        Archive = "libpng-1.6.2.tar.gz"
        Url = "https://download.sourceforge.net/libpng/libpng-1.6.2.tar.gz"
        Sha256 = "516BE5E8C4ABFD688E6C73C14F74B523B9EF73BE39751DF514069CDF14B3BE96"
        SourceDir = "libpng-1.6.2"
    },
    [pscustomobject]@{
        Name = "tiff"
        Archive = "tiff-4.0.3.tar.gz"
        Url = "https://download.osgeo.org/libtiff/old/tiff-4.0.3.tar.gz"
        Sha256 = "EA1AEBE282319537FB2D4D7805F478DD4E0E05C33D0928BABA76A7C963684872"
        SourceDir = "tiff-4.0.3"
    },
    [pscustomobject]@{
        Name = "webp"
        Archive = "libwebp-0.2.1.tar.gz"
        Url = "https://github.com/webmproject/libwebp/archive/refs/tags/v0.2.1.tar.gz"
        Sha256 = "A782E9E09F0EB04D004C0E94BC94AEE3F135D361658539429E386C7AF361E0D9"
        SourceDir = "libwebp-0.2.1"
    }
)

$curl = (Get-Command curl.exe -ErrorAction Stop).Source
$tar = (Get-Command tar.exe -ErrorAction Stop).Source
foreach ($dependency in $dependencies) {
    $archivePath = Join-Path $downloadRoot $dependency.Archive
    if (-not (Test-Path -LiteralPath $archivePath -PathType Leaf)) {
        Write-Host "Download $($dependency.Name): $($dependency.Url)"
        Invoke-Checked -Message "Download failed for $($dependency.Name)" -Command {
            & $curl -L --fail --silent --show-error --output $archivePath $dependency.Url
        }
    }
    Assert-ArchiveHash -Path $archivePath -Expected $dependency.Sha256

    $sourceDir = Join-Path $sourceRoot $dependency.SourceDir
    if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
        Write-Host "Extract $($dependency.Archive)"
        Invoke-Checked -Message "Extraction failed for $($dependency.Name)" -Command {
            & $tar -xf $archivePath -C $sourceRoot
        }
    }
}

$pngSource = Join-Path $sourceRoot "libpng-1.6.2"
Copy-Item -LiteralPath (Join-Path $pngSource "scripts/pnglibconf.h.prebuilt") -Destination (Join-Path $pngSource "pnglibconf.h") -Force

$ndkArgs = @(
    "-C", $buildRoot,
    "NDK_PROJECT_PATH=$buildRoot",
    "NDK_APPLICATION_MK=$(Join-Path $buildRoot 'Application.mk')",
    "APP_BUILD_SCRIPT=$(Join-Path $buildRoot 'Android.mk')",
    "MT3_UPGRADE30_DEPS_ROOT=$($sourceRoot -replace '\\', '/')"
)
if ($Clean) {
    Invoke-Checked -Message "Upgrade30 prebuilt clean failed" -Command {
        & $NdkBuildPath @ndkArgs clean
    }
}

Write-Host "Build Upgrade30 arm64 prebuilts with NDK r16 clang"
Invoke-Checked -Message "Upgrade30 prebuilt build failed" -Command {
    & $NdkBuildPath @ndkArgs "-j$Jobs"
}

$objRoot = Join-Path $buildRoot "obj/local/arm64-v8a"
$outputs = @(
    [pscustomobject]@{ Name = "freetype"; BuildFile = "freetype.a"; File = "libfreetype.a"; Target = "cocos2d-x-3.0-oh/external/freetype2/prebuilt/android/arm64-v8a" },
    [pscustomobject]@{ Name = "jpeg"; BuildFile = "jpeg.a"; File = "libjpeg.a"; Target = "cocos2d-x-3.0-oh/external/jpeg/prebuilt/android/arm64-v8a" },
    [pscustomobject]@{ Name = "png"; BuildFile = "png.a"; File = "libpng.a"; Target = "cocos2d-x-3.0-oh/external/png/prebuilt/android/arm64-v8a" },
    [pscustomobject]@{ Name = "tiff"; BuildFile = "tiff.a"; File = "libtiff.a"; Target = "cocos2d-x-3.0-oh/external/tiff/prebuilt/android/arm64-v8a" },
    [pscustomobject]@{ Name = "webp"; BuildFile = "libwebp.a"; File = "libwebp.a"; Target = "cocos2d-x-3.0-oh/external/webp/prebuilt/android/arm64-v8a" }
)

foreach ($output in $outputs) {
    $source = Join-Path $objRoot $output.BuildFile
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Expected static library was not produced: $source"
    }
    $targetDir = Join-Path $repoRoot $output.Target
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -LiteralPath $source -Destination (Join-Path $targetDir $output.File) -Force
}

$ftSource = Join-Path $sourceRoot "freetype-VER-2-5-0/include"
$ftTarget = Join-Path $repoRoot "cocos2d-x-3.0-oh/external/freetype2/include/android"
Copy-Item -LiteralPath (Join-Path $ftSource "ft2build.h") -Destination (Join-Path $ftTarget "ft2build.h") -Force
Copy-Item -Path (Join-Path $ftSource "freetype") -Destination (Join-Path $ftTarget "freetype2") -Recurse -Force

$pngTarget = Join-Path $repoRoot "cocos2d-x-3.0-oh/external/png/include/android"
Copy-Item -LiteralPath (Join-Path $pngSource "png.h") -Destination (Join-Path $pngTarget "png.h") -Force
Copy-Item -LiteralPath (Join-Path $pngSource "pngconf.h") -Destination (Join-Path $pngTarget "pngconf.h") -Force
Copy-Item -LiteralPath (Join-Path $pngSource "pnglibconf.h") -Destination (Join-Path $pngTarget "pnglibconf.h") -Force

$jpegSource = Join-Path $sourceRoot "jpeg-9"
$jpegTarget = Join-Path $repoRoot "cocos2d-x-3.0-oh/external/jpeg/include/android"
foreach ($header in @("jerror.h", "jmorecfg.h", "jpeglib.h")) {
    Copy-Item -LiteralPath (Join-Path $jpegSource $header) -Destination (Join-Path $jpegTarget $header) -Force
}
Copy-Item -LiteralPath (Join-Path $buildRoot "jpeg-config/jconfig.h") -Destination (Join-Path $jpegTarget "jconfig.h") -Force

$webpSource = Join-Path $sourceRoot "libwebp-0.2.1/src/webp"
$webpTarget = Join-Path $repoRoot "cocos2d-x-3.0-oh/external/webp/include/android"
Copy-Item -Path (Join-Path $webpSource "*.h") -Destination $webpTarget -Force

$ar = Join-Path $ndkRoot "toolchains/aarch64-linux-android-4.9/prebuilt/windows-x86_64/bin/aarch64-linux-android-ar.exe"
foreach ($output in $outputs) {
    $archive = Join-Path (Join-Path $repoRoot $output.Target) $output.File
    $members = @(& $ar t $archive)
    if ($LASTEXITCODE -ne 0 -or $members.Count -eq 0) {
        throw "Static archive validation failed: $archive"
    }
    $item = Get-Item -LiteralPath $archive
    $sha256 = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
    Write-Host ("  {0,-10} {1,10} bytes  {2}  {3} objects" -f $output.Name, $item.Length, $sha256, $members.Count)
}

Write-Host "Upgrade30 arm64 prebuilt dependencies are ready."

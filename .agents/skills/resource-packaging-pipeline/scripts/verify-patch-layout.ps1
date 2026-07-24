[CmdletBinding()]
param(
    [string]$Path = "",
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "resource-packaging-pipeline"

function Get-RelativeRepoPath {
    param(
        [string]$AbsolutePath,
        [string]$RootPath
    )
    $rootWithSlash = $RootPath.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
    $rootUri = New-Object System.Uri($rootWithSlash)
    $pathUri = New-Object System.Uri($AbsolutePath)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace("/", "\")
}

function Get-AsciiStrings {
    param(
        [byte[]]$Bytes,
        [int]$MinLength = 4
    )

    $strings = New-Object System.Collections.Generic.List[string]
    $builder = New-Object System.Text.StringBuilder

    foreach ($byte in $Bytes) {
        if ($byte -ge 32 -and $byte -le 126) {
            [void]$builder.Append([char]$byte)
        } else {
            if ($builder.Length -ge $MinLength) {
                $strings.Add($builder.ToString()) | Out-Null
            }
            [void]$builder.Clear()
        }
    }
    if ($builder.Length -ge $MinLength) {
        $strings.Add($builder.ToString()) | Out-Null
    }
    return @($strings)
}

function Get-TargetDirectories {
    param(
        [string]$RepoRootPath,
        [string]$InputPath
    )

    $dirs = New-Object System.Collections.Generic.List[string]
    $probeRoots = New-Object System.Collections.Generic.List[string]

    if (-not [string]::IsNullOrWhiteSpace($InputPath)) {
        $targetPath = if ([System.IO.Path]::IsPathRooted($InputPath)) {
            [System.IO.Path]::GetFullPath($InputPath)
        } else {
            [System.IO.Path]::GetFullPath((Join-Path $RepoRootPath $InputPath))
        }

        if (Test-Path $targetPath -PathType Leaf) {
            $probeRoots.Add((Split-Path -Parent $targetPath)) | Out-Null
        } elseif (Test-Path $targetPath -PathType Container) {
            $probeRoots.Add($targetPath) | Out-Null
        }
    } else {
        foreach ($path in @(
            (Join-Path $RepoRootPath "client\res_win\res"),
            (Join-Path $RepoRootPath "client\res_ios\res"),
            (Join-Path $RepoRootPath "server\server\web_app\public")
        )) {
            if (Test-Path $path) {
                $probeRoots.Add([System.IO.Path]::GetFullPath($path)) | Out-Null
            }
        }
        foreach ($androidAssets in @(Get-ChildItem -Path (Join-Path $RepoRootPath "client\android") -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            Join-Path $_.FullName "assets\res"
        })) {
            if (Test-Path $androidAssets) {
                $probeRoots.Add([System.IO.Path]::GetFullPath($androidAssets)) | Out-Null
            }
        }
    }

    foreach ($probeRoot in @($probeRoots | Select-Object -Unique)) {
        if (-not (Test-Path $probeRoot -PathType Container)) {
            continue
        }

        $matchingDirs = Get-ChildItem -Path $probeRoot -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object {
            (Test-Path (Join-Path $_.FullName "fl.ljpi") -PathType Leaf) -or
            (Test-Path (Join-Path $_.FullName "ver.ljvi") -PathType Leaf)
        }

        if ((Test-Path (Join-Path $probeRoot "fl.ljpi") -PathType Leaf) -or (Test-Path (Join-Path $probeRoot "ver.ljvi") -PathType Leaf)) {
            $dirs.Add([System.IO.Path]::GetFullPath($probeRoot)) | Out-Null
        }
        foreach ($dir in $matchingDirs) {
            $dirs.Add([System.IO.Path]::GetFullPath($dir.FullName)) | Out-Null
        }
    }

    return @($dirs | Select-Object -Unique | Sort-Object)
}

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$directories = Get-TargetDirectories -RepoRootPath $RepoRoot -InputPath $Path
$details.Add("directory_count=" + $directories.Count) | Out-Null

if ($directories.Count -eq 0) {
    $details.Add("failure=no ver.ljvi/fl.ljpi directories found in target scope") | Out-Null
    Write-Result -Status "FAIL" -Summary "No patch-layout directories were found in the target scope." -Next "Point the script at a real patch root or let it scan the default MT3 publish roots." -Details $details
}

$pairDirCount = 0
$versionHubCount = 0

foreach ($directory in $directories) {
    $verPath = Join-Path $directory "ver.ljvi"
    $flPath = Join-Path $directory "fl.ljpi"
    $hasVer = Test-Path $verPath -PathType Leaf
    $hasFl = Test-Path $flPath -PathType Leaf
    $relativePath = Get-RelativeRepoPath -AbsolutePath $directory -RootPath $RepoRoot

    if ($hasFl) {
        $pairDirCount++
        $details.Add("pair_dir=" + $relativePath) | Out-Null
        if (-not $hasVer) {
            $failures.Add("fl.ljpi exists without sibling ver.ljvi: " + $relativePath) | Out-Null
            continue
        }

        $verInfo = Get-Item $verPath
        $flInfo = Get-Item $flPath
        if ($verInfo.Length -le 0) {
            $failures.Add("empty ver.ljvi: " + $relativePath) | Out-Null
        }
        if ($flInfo.Length -le 0) {
            $failures.Add("empty fl.ljpi: " + $relativePath) | Out-Null
        }

        $verStrings = Get-AsciiStrings -Bytes ([System.IO.File]::ReadAllBytes($verPath))
        $hasVersionMarker = $verStrings -contains "VersionInfo" -or $verStrings -contains "VersionCaption"
        $hasUrlMarker = $verStrings -contains "URLInfo" -or $verStrings -contains "System"
        if (-not $hasVersionMarker) {
            $warnings.Add("ver.ljvi missing expected version markers: " + $relativePath) | Out-Null
        }
        if (-not $hasUrlMarker) {
            $warnings.Add("ver.ljvi missing expected URL/system markers: " + $relativePath) | Out-Null
        }

        if ($relativePath -match '^client\\android\\([^\\]+)\\assets\\res$') {
            $projectName = $matches[1]
            $androidLayout = Join-Path $RepoRoot ("client\android\" + $projectName + "\res\layout\mt_update.xml")
            if (Test-Path $androidLayout -PathType Leaf) {
                $details.Add("android_update_layout=" + $androidLayout) | Out-Null
            } else {
                $warnings.Add("missing mt_update.xml beside Android assets root: " + $projectName) | Out-Null
            }
        }
    } elseif ($hasVer) {
        $descendantFl = Get-ChildItem -Path $directory -Recurse -File -Filter fl.ljpi -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $descendantFl) {
            $versionHubCount++
            $details.Add("version_hub=" + $relativePath) | Out-Null
        } else {
            $warnings.Add("ver.ljvi exists without local or descendant fl.ljpi: " + $relativePath) | Out-Null
        }
    }
}

$details.Add("pair_directory_count=" + $pairDirCount) | Out-Null
$details.Add("version_hub_count=" + $versionHubCount) | Out-Null

$status = "PASS"
$summary = "Patch roots contain the expected version/index pairs for the checked scope."
$next = "Use this probe before publishing or after syncing assets to catch missing pair files early."

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "Patch layout drift was found in the checked scope."
    $next = "Fix missing sibling ver/fl files or empty publish artifacts, then rerun the checker."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "Patch layout pairs look usable, but some publish roots still need manual review."
    $next = "Review version hubs and warning directories before treating the publish tree as release-ready."
}

foreach ($item in $failures) {
    $details.Add("failure=" + $item) | Out-Null
}
foreach ($item in $warnings) {
    $details.Add("warning=" + $item) | Out-Null
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    target_path = $Path
    directory_count = $directories.Count
    pair_directory_count = $pairDirCount
    version_hub_count = $versionHubCount
    directories = @($directories)
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

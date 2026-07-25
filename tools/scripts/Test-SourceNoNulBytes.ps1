[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [string[]]$IncludeRoots = @(),
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRootPath {
    param([string]$InputPath)

    if (-not [string]::IsNullOrWhiteSpace($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$BaseRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BaseRoot $PathValue))
}

function Get-RepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$BaseRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $full = [System.IO.Path]::GetFullPath($PathValue)
    $root = [System.IO.Path]::GetFullPath($BaseRoot).TrimEnd("\", "/") + "\"
    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($root.Length) -replace "\\", "\"
    }

    return $full
}

function Expand-IncludeRoots {
    param([string[]]$Roots)

    $expanded = New-Object System.Collections.Generic.List[string]
    foreach ($root in @($Roots)) {
        if ([string]::IsNullOrWhiteSpace($root)) {
            continue
        }

        foreach ($part in ($root -split ",")) {
            $trimmed = $part.Trim()
            if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
                [void]$expanded.Add($trimmed)
            }
        }
    }

    return @($expanded)
}

function Test-IsTextCandidate {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$File)

    $textExtensions = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
    @(
        ".bat", ".cmd", ".c", ".cc", ".cpp", ".cxx", ".h", ".hh", ".hpp", ".hxx",
        ".inl", ".ipp", ".lua", ".luacfg", ".mm", ".m", ".md", ".markdown",
        ".pkg", ".props", ".ps1", ".py", ".rc", ".sln", ".targets", ".txt",
        ".vcxproj", ".filters", ".xml", ".xsd", ".json", ".ini", ".cfg", ".conf",
        ".manifest", ".def", ".idl", ".natvis", ".ruleset", ".toml", ".yml", ".yaml"
    ) | ForEach-Object { [void]$textExtensions.Add($_) }

    if ($textExtensions.Contains($File.Extension)) {
        return $true
    }

    $knownNames = @(
        "makefile",
        "readme",
        "authors",
        "license",
        "changelog"
    )

    return $knownNames -contains $File.Name.ToLowerInvariant()
}

function Test-IsSkippedDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path -replace "/", "\"
    return (
        $normalized -match "\\\.git(\\|$)" -or
        $normalized -match "\\\.vs(\\|$)" -or
        $normalized -match "\\ipch(\\|$)" -or
        $normalized -match "\\Debug\.win32(\\|$)" -or
        $normalized -match "\\Release\.win32(\\|$)" -or
        $normalized -match "\\build_logs(\\|$)" -or
        $normalized -match "\\resource\\bin(\\|$)"
    )
}

function Find-NulOffsets {
    param([Parameter(Mandatory = $true)][string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 2) {
        $isUtf16 = (($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) -or ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF))
        if ($isUtf16) { return @() }
    }
    if ($bytes.Length -ge 4) {
        $isUtf32 = (
            ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE -and $bytes[2] -eq 0x00 -and $bytes[3] -eq 0x00) -or
            ($bytes[0] -eq 0x00 -and $bytes[1] -eq 0x00 -and $bytes[2] -eq 0xFE -and $bytes[3] -eq 0xFF)
        )
        if ($isUtf32) { return @() }
    }
    $offsets = New-Object System.Collections.Generic.List[int]
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        if ($bytes[$i] -eq 0) {
            [void]$offsets.Add($i)
            if ($offsets.Count -ge 16) {
                break
            }
        }
    }

    return @($offsets)
}

function Get-ScanFiles {
    param(
        [Parameter(Mandatory = $true)][string]$BaseRoot,
        [Parameter(Mandatory = $true)][string[]]$Roots
    )

    $files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    foreach ($root in $Roots) {
        $resolved = Resolve-RepoPath -BaseRoot $BaseRoot -PathValue $root
        if (-not (Test-Path $resolved)) {
            throw "Include root not found: $resolved"
        }

        $item = Get-Item -LiteralPath $resolved
        if (-not $item.PSIsContainer) {
            if (Test-IsTextCandidate -File $item) {
                [void]$files.Add($item)
            }
            continue
        }

        Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Force |
            Where-Object {
                -not (Test-IsSkippedDirectory -Path $_.DirectoryName) -and
                (Test-IsTextCandidate -File $_)
            } |
            ForEach-Object { [void]$files.Add($_) }
    }

    return @($files | Sort-Object FullName -Unique)
}

$repoRootPath = Resolve-RepoRootPath -InputPath $RepoRoot
$roots = @(Expand-IncludeRoots -Roots $IncludeRoots)
if ($roots.Count -eq 0) {
    $roots = @(
        "client\FireClient\Application",
        "client\MT3Win32App",
        "client\Build-MT3-v120.ps1",
        "engine",
        "common",
        "tools\scripts"
    )
}

$failures = New-Object System.Collections.Generic.List[object]
$scanFiles = @(Get-ScanFiles -BaseRoot $repoRootPath -Roots $roots)

foreach ($file in $scanFiles) {
    $offsets = @(Find-NulOffsets -Path $file.FullName)
    if ($offsets.Count -gt 0) {
        [void]$failures.Add([pscustomobject]@{
            path = Get-RepoRelativePath -BaseRoot $repoRootPath -PathValue $file.FullName
            nul_offsets = $offsets
        })
    }
}

$status = if ($failures.Count -gt 0) { "FAIL" } else { "PASS" }
$summary = if ($failures.Count -gt 0) {
    "Source NUL byte scan found $($failures.Count) file(s) with embedded NUL bytes."
} else {
    "Source NUL byte scan passed for $($scanFiles.Count) text file(s)."
}

if ($Json) {
    [pscustomobject]@{
        status = $status
        script = "Test-SourceNoNulBytes.ps1"
        summary = $summary
        data = [pscustomobject]@{
            repo_root = $repoRootPath
            include_roots = @($roots)
            scanned_file_count = $scanFiles.Count
            failures = $failures.ToArray()
        }
    } | ConvertTo-Json -Depth 6 -Compress
} else {
    Write-Host $summary
    foreach ($failure in $failures) {
        Write-Host ("NUL: {0} offsets={1}" -f $failure.path, ($failure.nul_offsets -join ","))
    }
}

if ($failures.Count -gt 0) {
    exit 1
}

exit 0

[CmdletBinding()]
param(
    [string]$ConfigPath = "",
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "sprite-pack-algorithm"

function Resolve-ConfigFile {
    param(
        [string]$InputPath,
        [string]$RootPath
    )

    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        return ""
    }
    if ([System.IO.Path]::IsPathRooted($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $RootPath $InputPath))
}

function Get-IniSections {
    param([string]$Text)

    $sections = New-Object System.Collections.ArrayList
    $current = $null

    foreach ($rawLine in ($Text -split "`r?`n")) {
        $line = $rawLine.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        if ($line.StartsWith(";") -or $line.StartsWith("#")) {
            continue
        }
        if ($line.StartsWith("[") -and $line.EndsWith("]")) {
            if ($null -ne $current) {
                [void]$sections.Add($current)
            }
            $current = [pscustomobject]@{
                Name = $line.Substring(1, $line.Length - 2)
                Keys = @{}
            }
            continue
        }
        if ($null -eq $current) {
            continue
        }
        $separatorIndex = $line.IndexOf("=")
        if ($separatorIndex -lt 1) {
            continue
        }
        $key = $line.Substring(0, $separatorIndex).Trim()
        $value = $line.Substring($separatorIndex + 1).Trim()
        $current.Keys[$key] = $value
    }

    if ($null -ne $current) {
        [void]$sections.Add($current)
    }

    return [object[]]$sections
}

function Test-PathWithinRepo {
    param(
        [string]$AbsolutePath,
        [string]$RootPath
    )

    $repoPrefix = $RootPath.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
    return $AbsolutePath.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-PackArtifacts {
    param([string]$OutputDirectory)

    return @(
        Get-ChildItem -LiteralPath $OutputDirectory -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Extension -ieq ".ani" -or
                $_.Extension -ieq ".xap" -or
                $_.Name -like "*_res*.png"
            }
    )
}

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $details.Add("failure=ConfigPath is required; no default pack.ini is assumed") | Out-Null
    $missingConfigPayload = [pscustomobject][ordered]@{
        repo_root = $RepoRoot
        config = ""
        input_required = $true
        section_count = 0
        existing_source_count = 0
        existing_output_count = 0
        artifact_count = 0
        section_names = @()
        failures = @("ConfigPath is required")
        warnings = @()
    }
    Write-Result -Status "FAIL" -Summary "A SpriteEditor configuration path is required." -Next "Pass the real configuration file with -ConfigPath, then rerun the checker." -Details $details -Payload $missingConfigPayload
}

$configFile = Resolve-ConfigFile -InputPath $ConfigPath -RootPath $RepoRoot
if (-not (Test-Path -LiteralPath $configFile -PathType Leaf)) {
    $details.Add("failure=SpriteEditor config not found: " + $configFile) | Out-Null
    $missingFilePayload = [pscustomobject][ordered]@{
        repo_root = $RepoRoot
        config = $configFile
        input_required = $false
        section_count = 0
        existing_source_count = 0
        existing_output_count = 0
        artifact_count = 0
        section_names = @()
        failures = @("SpriteEditor config not found: " + $configFile)
        warnings = @()
    }
    Write-Result -Status "FAIL" -Summary "The SpriteEditor configuration file does not exist." -Next "Pass an existing configuration file with -ConfigPath, then rerun the checker." -Details $details -Payload $missingFilePayload
}

$details.Add("config=" + $configFile) | Out-Null
$iniText = Read-TextFileSmart -Path $configFile
$sections = @(Get-IniSections -Text $iniText)
$details.Add("section_count=" + $sections.Count) | Out-Null

if ($sections.Count -eq 0) {
    $details.Add("failure=SpriteEditor config has no parseable sections") | Out-Null
    $emptyConfigPayload = [pscustomobject][ordered]@{
        repo_root = $RepoRoot
        config = $configFile
        input_required = $false
        section_count = 0
        existing_source_count = 0
        existing_output_count = 0
        artifact_count = 0
        section_names = @()
        failures = @("SpriteEditor config has no parseable sections")
        warnings = @()
    }
    Write-Result -Status "FAIL" -Summary "The SpriteEditor configuration file has no parseable sections." -Next "Fix the INI section syntax first, then rerun the checker." -Details $details -Payload $emptyConfigPayload
}

$requiredKeys = @("texfmt", "blend", "centerx", "centery", "dirmode", "packtime", "bBindType", "sysLevel", "OutputPath")
$optionalKeys = @("frameseq", "regioncount", "partpath")
$numericKeys = @("texfmt", "blend", "centerx", "centery", "dirmode", "packtime", "bBindType", "sysLevel", "frameseq", "regioncount")
$existingSourceCount = 0
$existingOutputCount = 0
$artifactPaths = @{}

foreach ($section in $sections) {
    $sectionName = [string]$section.Name
    $details.Add("section=" + $sectionName) | Out-Null

    foreach ($requiredKey in $requiredKeys) {
        if (-not $section.Keys.ContainsKey($requiredKey) -or [string]::IsNullOrWhiteSpace([string]$section.Keys[$requiredKey])) {
            $failures.Add("missing required key '" + $requiredKey + "' in section: " + $sectionName) | Out-Null
        }
    }

    foreach ($key in $section.Keys.Keys) {
        if ($requiredKeys -notcontains $key -and $optionalKeys -notcontains $key) {
            $warnings.Add("unknown pack.ini key '" + $key + "' in section: " + $sectionName) | Out-Null
        }
    }

    foreach ($numericKey in $numericKeys) {
        if ($section.Keys.ContainsKey($numericKey)) {
            $parsedNumber = 0
            if (-not [int]::TryParse([string]$section.Keys[$numericKey], [ref]$parsedNumber)) {
                $failures.Add("non-integer value for key '" + $numericKey + "' in section: " + $sectionName) | Out-Null
                continue
            }

            if ($numericKey -eq "dirmode" -and ($parsedNumber -lt 0 -or $parsedNumber -gt 8)) {
                $failures.Add("dirmode out of supported range 0..8 in section: " + $sectionName) | Out-Null
            }
            if ($numericKey -eq "packtime" -and ($parsedNumber -lt 1 -or $parsedNumber -gt 65536)) {
                $warnings.Add("packtime outside expected range 1..65536 in section: " + $sectionName) | Out-Null
            }
        }
    }

    $sourcePath = $sectionName
    if (-not [string]::IsNullOrWhiteSpace($sourcePath)) {
        if ([System.IO.Path]::IsPathRooted($sourcePath)) {
            if (Test-Path $sourcePath) {
                $existingSourceCount++
            } elseif (Test-PathWithinRepo -AbsolutePath $sourcePath -RootPath $RepoRoot) {
                $warnings.Add("repo-local source path is missing: " + $sourcePath) | Out-Null
            } else {
                $details.Add("external_source_sample=" + $sourcePath) | Out-Null
            }
        } else {
            $resolvedSource = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $sourcePath))
            if (Test-Path $resolvedSource) {
                $existingSourceCount++
            } else {
                $warnings.Add("relative source path is missing: " + $sourcePath) | Out-Null
            }
        }
    }

    if ($section.Keys.ContainsKey("OutputPath")) {
        $outputPath = [string]$section.Keys["OutputPath"]
        if ([System.IO.Path]::IsPathRooted($outputPath)) {
            if (Test-Path -LiteralPath $outputPath -PathType Container) {
                $existingOutputCount++
                $outputArtifacts = @(Get-PackArtifacts -OutputDirectory $outputPath)
                foreach ($artifact in $outputArtifacts) {
                    $artifactPaths[$artifact.FullName] = $true
                }
                $details.Add("output_artifact_count=" + $outputArtifacts.Count + "@" + $outputPath) | Out-Null
                if ($outputArtifacts.Count -eq 0) {
                    $warnings.Add("no ANI/XAP/atlas artifacts found under output path: " + $outputPath) | Out-Null
                }
            } elseif (Test-PathWithinRepo -AbsolutePath $outputPath -RootPath $RepoRoot) {
                $warnings.Add("repo-local output path is missing: " + $outputPath) | Out-Null
            } else {
                $details.Add("external_output_sample=" + $outputPath) | Out-Null
            }
        } else {
            $resolvedOutput = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $outputPath))
            if (Test-Path -LiteralPath $resolvedOutput -PathType Container) {
                $existingOutputCount++
                $outputArtifacts = @(Get-PackArtifacts -OutputDirectory $resolvedOutput)
                foreach ($artifact in $outputArtifacts) {
                    $artifactPaths[$artifact.FullName] = $true
                }
                $details.Add("output_artifact_count=" + $outputArtifacts.Count + "@" + $resolvedOutput) | Out-Null
                if ($outputArtifacts.Count -eq 0) {
                    $warnings.Add("no ANI/XAP/atlas artifacts found under output path: " + $resolvedOutput) | Out-Null
                }
            } else {
                $warnings.Add("relative output path is missing: " + $outputPath) | Out-Null
            }
        }
    }
}

$details.Add("existing_source_count=" + $existingSourceCount) | Out-Null
$details.Add("existing_output_count=" + $existingOutputCount) | Out-Null
$details.Add("artifact_count=" + $artifactPaths.Count) | Out-Null

$status = "PASS"
$summary = "The SpriteEditor pack.ini syntax and key ranges look consistent."
$next = "Run this checker before using pack.ini batch mode to catch key drift and path mistakes early."

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "The SpriteEditor pack.ini file has structural drift that should be fixed first."
    $next = "Fix missing keys or invalid numeric ranges, then rerun the checker."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "The pack.ini file is syntactically usable, but some paths or values still need review."
    $next = "Review warning sections, especially missing repo-local paths or unusual timing values, then rerun if needed."
}

foreach ($item in $failures) {
    $details.Add("failure=" + $item) | Out-Null
}
foreach ($item in $warnings) {
    $details.Add("warning=" + $item) | Out-Null
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    config = $configFile
    input_required = $false
    section_count = $sections.Count
    existing_source_count = $existingSourceCount
    existing_output_count = $existingOutputCount
    artifact_count = $artifactPaths.Count
    section_names = @($sections | ForEach-Object { [string]$_.Name })
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

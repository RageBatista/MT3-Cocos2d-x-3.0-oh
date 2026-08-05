param(
    [string]$RootPath = ".",
    [ValidateSet("Legacy226", "Upgrade30")]
    [string]$EngineProfile = "Upgrade30",
    [switch]$Json,
    [string]$ReportPath
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

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

function Normalize-RepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $normalized = $PathValue -replace "/", "\"
    $normalized = $normalized -replace "\\+", "\"
    $normalized = $normalized.Trim()
    while ($normalized.StartsWith(".\")) {
        $normalized = $normalized.Substring(2)
    }
    return $normalized.TrimStart([char[]]@("\"))
}

function Get-BuildScriptProjects {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$Profile
    )

    Import-Module -Name (Join-Path $RepoRoot "tools\scripts\build-config.psm1") -Force
    return @(
        Get-MT3Win32ProjectManifest -RepoRoot $RepoRoot -EngineProfile $Profile -IncludeFinalExecutable |
            ForEach-Object {
                [PSCustomObject]@{
                    name = $_.Name
                    path = Normalize-RepoRelativePath -PathValue $_.RelativePath
                    source = "build-config.psm1"
                }
            }
    )
}

function Get-CheckV120MainlineProjects {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$Profile
    )

    $scriptPath = Resolve-RepoPath -BaseRoot $RepoRoot -PathValue "tools\scripts\Check-v120Toolset.ps1"
    if (-not (Test-Path $scriptPath)) {
        return @()
    }

    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $scriptPath
    if ($text -notmatch 'Get-MT3Win32ProjectManifest') {
        return @()
    }

    Import-Module -Name (Join-Path $RepoRoot "tools\scripts\build-config.psm1") -Force
    return @(
        Get-MT3Win32ProjectManifest -RepoRoot $RepoRoot -EngineProfile $Profile -IncludeFinalExecutable |
            ForEach-Object {
                [PSCustomObject]@{
                    path = Normalize-RepoRelativePath -PathValue $_.RelativePath
                    source = "Check-v120Toolset.ps1/build-config.psm1"
                }
            }
    )
}

function Split-MSBuildList {
    param(
        [AllowNull()][string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }

    return @(
        $Value -split ";" |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -notmatch "^%\(" }
    )
}

function Add-UniqueString {
    param(
        [Parameter(Mandatory = $true)]$List,
        [Parameter(Mandatory = $true)][string]$Value
    )

    if (-not $List.Contains($Value)) {
        $List.Add($Value) | Out-Null
    }
}

function Get-NodeLabel {
    param(
        [Parameter(Mandatory = $true)][System.Xml.XmlNode]$Node
    )

    $condition = ""
    $current = $Node
    while ($null -ne $current) {
        if ($current.Attributes -and $current.Attributes["Condition"]) {
            $condition = $current.Attributes["Condition"].Value
            break
        }
        $current = $current.ParentNode
    }

    if ([string]::IsNullOrWhiteSpace($condition)) {
        return $Node.LocalName
    }

    return ("{0}[{1}]" -f $Node.LocalName, $condition)
}

function Get-VcxprojAnalysis {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][object[]]$Projects
    )

    $analyses = New-Object System.Collections.ArrayList

    foreach ($project in $Projects) {
        $relativePath = Normalize-RepoRelativePath -PathValue ([string]$project.path)
        $fullPath = Resolve-RepoPath -BaseRoot $RepoRoot -PathValue $relativePath

        $analysis = [ordered]@{
            name = [string]$project.name
            path = $relativePath
            exists = (Test-Path $fullPath)
            toolsets = @()
            has_v120 = $false
            project_references = @()
            duplicate_entries = @()
            hardcoded_entries = @()
            old_cocos_entries = @()
            config_summary = @()
        }

        if (-not $analysis.exists) {
            $analyses.Add([PSCustomObject]$analysis) | Out-Null
            continue
        }

        [xml]$xml = Get-Content -Raw -Encoding UTF8 -LiteralPath $fullPath
        $toolsets = @(
            $xml.SelectNodes("//*[local-name()='PlatformToolset']") |
                ForEach-Object { $_.InnerText.Trim() } |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
                Sort-Object -Unique
        )
        $analysis.toolsets = @($toolsets)
        $analysis.has_v120 = @($toolsets | Where-Object { $_ -eq "v120" }).Count -gt 0

        $analysis.project_references = @(
            $xml.SelectNodes("//*[local-name()='ProjectReference']") |
                ForEach-Object { Normalize-RepoRelativePath -PathValue $_.Include }
        )

        $listNodes = @($xml.SelectNodes("//*[local-name()='AdditionalIncludeDirectories' or local-name()='AdditionalLibraryDirectories' or local-name()='AdditionalDependencies']"))
        foreach ($node in $listNodes) {
            $label = Get-NodeLabel -Node $node
            $entries = @(Split-MSBuildList -Value $node.InnerText)

            $duplicateGroups = @($entries | Group-Object | Where-Object { $_.Count -gt 1 })
            foreach ($group in $duplicateGroups) {
                $record = [PSCustomObject]@{
                    node = $label
                    value = $group.Name
                    count = $group.Count
                }
                $analysis.duplicate_entries += @($record)
            }

            foreach ($entry in $entries) {
                if ($entry -match "^[A-Za-z]:[\\/]") {
                    $analysis.hardcoded_entries += @([PSCustomObject]@{
                        node = $label
                        value = $entry
                    })
                }
                if ($entry -match "cocos2d-x-2\.2\.6-mt3") {
                    $analysis.old_cocos_entries += @([PSCustomObject]@{
                        node = $label
                        value = $entry
                    })
                }
            }
        }

        $itemGroups = @($xml.SelectNodes("//*[local-name()='ItemDefinitionGroup']"))
        foreach ($group in $itemGroups) {
            $condition = ""
            if ($group.Attributes -and $group.Attributes["Condition"]) {
                $condition = $group.Attributes["Condition"].Value
            }

            $cl = $group.SelectSingleNode("*[local-name()='ClCompile']")
            $link = $group.SelectSingleNode("*[local-name()='Link']")

            $optimization = ""
            $debugFormat = ""
            $generateDebugInfo = ""
            if ($cl) {
                $optNode = $cl.SelectSingleNode("*[local-name()='Optimization']")
                $dbgNode = $cl.SelectSingleNode("*[local-name()='DebugInformationFormat']")
                if ($optNode) { $optimization = $optNode.InnerText.Trim() }
                if ($dbgNode) { $debugFormat = $dbgNode.InnerText.Trim() }
            }
            if ($link) {
                $genDbgNode = $link.SelectSingleNode("*[local-name()='GenerateDebugInformation']")
                if ($genDbgNode) { $generateDebugInfo = $genDbgNode.InnerText.Trim() }
            }

            if ($condition -or $optimization -or $debugFormat -or $generateDebugInfo) {
                $analysis.config_summary += @([PSCustomObject]@{
                    condition = $condition
                    optimization = $optimization
                    debug_information_format = $debugFormat
                    generate_debug_information = $generateDebugInfo
                })
            }
        }

        $analyses.Add([PSCustomObject]$analysis) | Out-Null
    }

    return @($analyses.ToArray())
}

function Get-LegacySolutionReferences {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $solutionPaths = @(
        "client\FireClient\FireClient.sln"
    )
    $findings = New-Object System.Collections.ArrayList

    foreach ($relativePath in $solutionPaths) {
        $fullPath = Resolve-RepoPath -BaseRoot $RepoRoot -PathValue $relativePath
        if (-not (Test-Path $fullPath)) {
            continue
        }

        $lineNumber = 0
        foreach ($line in (Get-Content -Encoding UTF8 -LiteralPath $fullPath)) {
            $lineNumber++
            if ($line -match "cocos2d-x-2\.2\.6-mt3|E:/|E:\\") {
                $findings.Add([PSCustomObject]@{
                    path = Normalize-RepoRelativePath -PathValue $relativePath
                    line = $lineNumber
                    text = $line.Trim()
                }) | Out-Null
            }
        }
    }

    return @($findings.ToArray())
}

function Write-AnalysisResult {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Payload,
        [Parameter(Mandatory = $true)][bool]$AsJson
    )

    if ($AsJson) {
        $Payload | ConvertTo-Json -Depth 10
        return
    }

    Write-Output ("STATUS: {0}" -f $Payload.status)
    Write-Output ("SKILL: {0}" -f $Payload.skill)
    Write-Output ("SUMMARY: {0}" -f $Payload.summary)
    foreach ($detail in $Payload.details) {
        Write-Output ("DETAIL: {0}" -f $detail)
    }
    Write-Output ("NEXT: {0}" -f $Payload.next)
}

$repoRoot = [System.IO.Path]::GetFullPath($RootPath)
if (-not (Test-Path $repoRoot)) {
    throw ("Path not found: {0}" -f $repoRoot)
}

$failures = New-Object System.Collections.ArrayList
$warnings = New-Object System.Collections.ArrayList
$details = New-Object System.Collections.ArrayList

$canonicalScript = Resolve-RepoPath -BaseRoot $repoRoot -PathValue "tools\scripts\Build-MT3-Exe-Canonical.ps1"
$internalBuildScript = Resolve-RepoPath -BaseRoot $repoRoot -PathValue "client\Build-MT3-v120.ps1"
$checkScript = Resolve-RepoPath -BaseRoot $repoRoot -PathValue "tools\scripts\Check-v120Toolset.ps1"

foreach ($requiredScript in @($canonicalScript, $internalBuildScript, $checkScript)) {
    if (Test-Path $requiredScript) {
        $details.Add(("script={0}" -f (Normalize-RepoRelativePath -PathValue $requiredScript.Substring($repoRoot.Length).TrimStart([char[]]@("\", "/"))))) | Out-Null
    } else {
        $failures.Add(("missing_script={0}" -f $requiredScript)) | Out-Null
    }
}

$actualBuildProjects = @(Get-BuildScriptProjects -RepoRoot $repoRoot -Profile $EngineProfile)
$checkV120Projects = @(Get-CheckV120MainlineProjects -RepoRoot $repoRoot -Profile $EngineProfile)

$actualPathSet = New-Object "System.Collections.Generic.HashSet[string]" ([StringComparer]::OrdinalIgnoreCase)
foreach ($project in $actualBuildProjects) {
    $actualPathSet.Add((Normalize-RepoRelativePath -PathValue $project.path)) | Out-Null
}

$checkPathSet = New-Object "System.Collections.Generic.HashSet[string]" ([StringComparer]::OrdinalIgnoreCase)
foreach ($project in $checkV120Projects) {
    $checkPathSet.Add((Normalize-RepoRelativePath -PathValue $project.path)) | Out-Null
}

foreach ($project in $actualBuildProjects) {
    $path = Normalize-RepoRelativePath -PathValue $project.path
    if (-not $checkPathSet.Contains($path)) {
        Add-UniqueString -List $warnings -Value ("build_script_only={0}" -f $path)
    }
}

foreach ($project in $checkV120Projects) {
    $path = Normalize-RepoRelativePath -PathValue $project.path
    if (-not $actualPathSet.Contains($path)) {
        Add-UniqueString -List $warnings -Value ("check_v120_list_only={0}" -f $path)
    }
}

$projectAnalyses = @(Get-VcxprojAnalysis -RepoRoot $repoRoot -Projects $actualBuildProjects)
foreach ($analysis in $projectAnalyses) {
    if (-not $analysis.exists) {
        $failures.Add(("missing_vcxproj={0}" -f $analysis.path)) | Out-Null
        continue
    }

    $details.Add(("vcxproj={0};toolsets={1}" -f $analysis.path, (($analysis.toolsets) -join ","))) | Out-Null

    if (-not $analysis.has_v120) {
        $failures.Add(("non_v120_actual_project={0};toolsets={1}" -f $analysis.path, (($analysis.toolsets) -join ","))) | Out-Null
    }

    foreach ($entry in $analysis.duplicate_entries) {
        $prefix = "duplicate_entry"
        if ($entry.node -match "AdditionalDependencies") {
            $prefix = "duplicate_link_dependency"
        }
        Add-UniqueString -List $warnings -Value ("{0}={1};node={2};value={3};count={4}" -f $prefix, $analysis.path, $entry.node, $entry.value, $entry.count)
    }

    foreach ($entry in $analysis.hardcoded_entries) {
        Add-UniqueString -List $warnings -Value ("hardcoded_path={0};node={1};value={2}" -f $analysis.path, $entry.node, $entry.value)
    }

    foreach ($entry in $analysis.old_cocos_entries) {
        Add-UniqueString -List $warnings -Value ("old_cocos_reference={0};node={1};value={2}" -f $analysis.path, $entry.node, $entry.value)
    }
}

$legacySolutionReferences = @(Get-LegacySolutionReferences -RepoRoot $repoRoot)
foreach ($finding in $legacySolutionReferences) {
    Add-UniqueString -List $warnings -Value ("legacy_solution_reference={0}:{1};text={2}" -f $finding.path, $finding.line, $finding.text)
}

$status = "PASS"
if ($failures.Count -gt 0) {
    $status = "FAIL"
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
}

$summary = "MT3 Win32 build governance baseline passed without warnings."
$next = "Run the canonical Debug or Release build."
if ($status -eq "FAIL") {
    $summary = "MT3 Win32 build governance found hard blockers."
    $next = "Fix missing scripts/projects or v120 drift, then rerun this analyzer."
} elseif ($status -eq "WARN") {
    $summary = "MT3 Win32 build governance found warnings that should be cleaned up incrementally."
    $next = "Review warnings, then run Check-v120Toolset and the canonical build before changing vcxproj files."
}

$details.Add(("actual_build_project_count={0}" -f $actualBuildProjects.Count)) | Out-Null
$details.Add(("check_v120_project_count={0}" -f $checkV120Projects.Count)) | Out-Null
$details.Add(("engine_profile={0}" -f $EngineProfile)) | Out-Null
$details.Add(("warning_count={0}" -f $warnings.Count)) | Out-Null
$details.Add(("failure_count={0}" -f $failures.Count)) | Out-Null

foreach ($failure in $failures) {
    $details.Add(("failure={0}" -f $failure)) | Out-Null
}
foreach ($warning in ($warnings | Select-Object -First 60)) {
    $details.Add(("warning={0}" -f $warning)) | Out-Null
}

$payload = @{
    status = $status
    skill = "windows-v120-build"
    summary = $summary
    next = $next
    details = @($details.ToArray())
    data = @{
        repo_root = $repoRoot
        engine_profile = $EngineProfile
        canonical_script = Normalize-RepoRelativePath -PathValue $canonicalScript.Substring($repoRoot.Length).TrimStart([char[]]@("\", "/"))
        internal_build_script = Normalize-RepoRelativePath -PathValue $internalBuildScript.Substring($repoRoot.Length).TrimStart([char[]]@("\", "/"))
        check_v120_script = Normalize-RepoRelativePath -PathValue $checkScript.Substring($repoRoot.Length).TrimStart([char[]]@("\", "/"))
        actual_build_projects = @($actualBuildProjects)
        check_v120_projects = @($checkV120Projects)
        project_analysis = @($projectAnalyses)
        legacy_solution_references = @($legacySolutionReferences)
        warnings = @($warnings.ToArray())
        failures = @($failures.ToArray())
    }
}

if (-not [string]::IsNullOrWhiteSpace($ReportPath)) {
    $reportFullPath = Resolve-RepoPath -BaseRoot $repoRoot -PathValue $ReportPath
    $parent = Split-Path -Parent $reportFullPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $jsonText = $payload | ConvertTo-Json -Depth 10
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($reportFullPath, $jsonText, $utf8NoBom)
}

Write-AnalysisResult -Payload $payload -AsJson:$Json.IsPresent

if ($status -eq "FAIL") {
    exit 1
}

exit 0

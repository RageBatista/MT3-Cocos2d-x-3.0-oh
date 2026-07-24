[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "generated-code-guard"

function Resolve-TargetPath {
    param(
        [string]$InputPath,
        [string]$BasePath
    )
    if ([System.IO.Path]::IsPathRooted($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $InputPath))
}

function Get-RelativeRepoPath {
    param(
        [string]$AbsolutePath,
        [string]$RootPath
    )
    $rootWithSlash = $RootPath.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
    $rootUri = New-Object System.Uri($rootWithSlash)
    $pathUri = New-Object System.Uri($AbsolutePath)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace("\", "/")
}

function Add-HintsFromSearch {
    param(
        [System.Collections.Generic.List[string]]$Hints,
        [string]$SearchRoot,
        [string]$Pattern,
        [string]$Filter
    )

    if (-not (Test-Path $SearchRoot -PathType Container)) {
        return
    }

    $files = Get-ChildItem -Path $SearchRoot -Recurse -File -Filter $Filter -ErrorAction SilentlyContinue
    foreach ($match in @($files | Select-String -Pattern $Pattern -List -ErrorAction SilentlyContinue | Select-Object -First 5)) {
        if ($null -ne $match.Path) {
            [void]$Hints.Add([System.IO.Path]::GetFullPath($match.Path))
        }
    }
}

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$targetPath = Resolve-TargetPath -InputPath $Path -BasePath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path $targetPath -PathType Leaf)) {
    [void]$details.Add("failure=file not found: " + $targetPath)
    Write-Result -Status "FAIL" -Summary "The target file does not exist." -Next "Check the file path and rerun the boundary probe." -Details $details
}

$relativePath = Get-RelativeRepoPath -AbsolutePath $targetPath -RootPath $RepoRoot
$stem = [System.IO.Path]::GetFileNameWithoutExtension($targetPath)
$status = "WARN"
$summary = "The file does not match a known generated boundary."
$next = "Treat it as a normal source file only after checking nearby AGENTS.md and project rules."
$kind = "not-generated"
$editPolicy = "normal-source"
$hints = New-Object System.Collections.Generic.List[string]
$regenHints = New-Object System.Collections.Generic.List[string]
$isGeneratedBoundary = $false

if ($relativePath -match "(?i)^server/.+/xbean/.+\.java$") {
    $isGeneratedBoundary = $true
    $kind = "generated-java-xbean"
    $editPolicy = "do-not-edit-generated"
    $status = "PASS"
    $summary = "The file is inside a generated xbean path and should be traced back to source definitions."
    $next = "Edit the source definition, then rerun genxdb/gengbeans instead of patching this Java file."
    $moduleRoot = Split-Path -Parent $targetPath
    if ((Split-Path -Leaf $moduleRoot) -ieq "xbean") {
        $moduleRoot = Split-Path -Parent $moduleRoot
    }
    if ((Split-Path -Leaf $moduleRoot) -ieq "src") {
        $moduleRoot = Split-Path -Parent $moduleRoot
    }
    $moduleBuildXml = Join-Path $moduleRoot "build.xml"
    if (Test-Path -LiteralPath $moduleBuildXml -PathType Leaf) {
        [void]$regenHints.Add($moduleBuildXml + " -> genxdb/gengbeans")
    }
    Add-HintsFromSearch -Hints $hints -SearchRoot $moduleRoot -Pattern ([regex]::Escape($stem)) -Filter "*.xml"
} elseif ($relativePath -match "(?i)^server/.+/rpc/.+\.java$") {
    $isGeneratedBoundary = $true
    $kind = "generated-java-rpc"
    $editPolicy = "do-not-edit-generated"
    $status = "PASS"
    $summary = "The file is inside a generated rpc path and should be traced back to protocol definitions."
    $next = "Edit the protocol XML or rpc source, then rerun genrpc."
    $moduleRoot = Split-Path -Parent $targetPath
    if ((Split-Path -Leaf $moduleRoot) -ieq "rpc") {
        $moduleRoot = Split-Path -Parent $moduleRoot
    }
    if ((Split-Path -Leaf $moduleRoot) -ieq "src") {
        $moduleRoot = Split-Path -Parent $moduleRoot
    }
    $moduleBuildXml = Join-Path $moduleRoot "build.xml"
    if (Test-Path -LiteralPath $moduleBuildXml -PathType Leaf) {
        [void]$regenHints.Add($moduleBuildXml + " -> genrpc")
    }
    Add-HintsFromSearch -Hints $hints -SearchRoot $moduleRoot -Pattern ([regex]::Escape($stem)) -Filter "*.xml"
} elseif ($relativePath -match "(?i)^client/.+/tolua\+\+/.+\.cpp$" -or $relativePath -match "(?i).+_tolua\.cpp$") {
    $isGeneratedBoundary = $true
    $kind = "generated-tolua-cpp"
    $editPolicy = "do-not-edit-generated"
    $status = "PASS"
    $summary = "The file looks like generated tolua output and should be traced back to pkg definitions."
    $next = "Edit the matching .pkg or binding source, then regenerate tolua output."
    $pkgFiles = Get-ChildItem -Path $RepoRoot -Recurse -File -Filter "*.pkg" -ErrorAction SilentlyContinue | Where-Object {
        $_.BaseName -eq $stem -or $_.Name -like ("*" + $stem + "*")
    } | Select-Object -First 5
    foreach ($pkgFile in $pkgFiles) {
        [void]$hints.Add($pkgFile.FullName)
    }
} elseif ($relativePath -match "(?i)^client/FireClient/Application/ProtoDef/.+\.(hpp|cpp)$") {
    $isGeneratedBoundary = $true
    $kind = "generated-protodef-cpp"
    $editPolicy = "do-not-edit-generated"
    $status = "PASS"
    $summary = "The file is inside generated ProtoDef output and should be traced back to protocol or generation inputs."
    $next = "Edit the upstream protocol definition and rerun generation instead of patching this file."
    $serverGameRoot = Join-Path $RepoRoot "server\server\game_server"
    $serverBuildXml = Join-Path $serverGameRoot "build.xml"
    if (Test-Path -LiteralPath $serverBuildXml -PathType Leaf) {
        [void]$regenHints.Add($serverBuildXml + " -> genrpc/genxdb/gengbeans")
    }
    Add-HintsFromSearch -Hints $hints -SearchRoot $serverGameRoot -Pattern ([regex]::Escape($stem)) -Filter "*.xml"
} elseif ($relativePath -match "(?i)^client/resource/res/script/protodef/.+\.lua$") {
    $isGeneratedBoundary = $true
    $kind = "runtime-protodef-lua-mirror"
    $editPolicy = "mirror-sync-only"
    $status = "PASS"
    $summary = "The file is in the runtime Lua protocol mirror layer and should be traced to an existing packaged source before syncing."
    $next = "Locate an existing packaged protocol file with the same relative path, then sync only the verified mirror file."
    $subPath = $relativePath -replace "(?i)^client/resource/res/script/protodef/", ""
    $androidRoot = Join-Path $RepoRoot "client\android"
    if (Test-Path -LiteralPath $androidRoot -PathType Container) {
        $candidateName = [System.IO.Path]::GetFileName($subPath)
        $expectedSuffix = ("script/protodef/" + $subPath).Replace("\", "/")
        foreach ($candidateFile in @(Get-ChildItem -LiteralPath $androidRoot -Recurse -File -Filter $candidateName -ErrorAction SilentlyContinue)) {
            $candidateRelative = Get-RelativeRepoPath -AbsolutePath $candidateFile.FullName -RootPath $RepoRoot
            if ($candidateRelative.EndsWith($expectedSuffix, [System.StringComparison]::OrdinalIgnoreCase)) {
                [void]$hints.Add([System.IO.Path]::GetFullPath($candidateFile.FullName))
            }
        }
    }
}

$sourceHints = @($hints | Select-Object -Unique -First 5)
$regenerationHints = @($regenHints | Select-Object -Unique -First 5)
$sourceEvidenceFound = $sourceHints.Count -gt 0

if ($isGeneratedBoundary -and -not $sourceEvidenceFound) {
    $status = "WARN"
    $summary = "The generated boundary is recognized, but no concrete upstream source evidence was found."
    $next = "Do not edit the generated file; locate and verify the real source definition or generator input before changing it."
}

[void]$details.Add("path=" + $targetPath)
[void]$details.Add("relative_path=" + $relativePath)
[void]$details.Add("kind=" + $kind)
[void]$details.Add("edit_policy=" + $editPolicy)

foreach ($hint in $sourceHints) {
    [void]$details.Add("source_hint=" + $hint)
}
foreach ($hint in $regenerationHints) {
    [void]$details.Add("regen_hint=" + $hint)
}

$payload = [pscustomobject][ordered]@{
    path = $targetPath
    relative_path = $relativePath
    kind = $kind
    edit_policy = $editPolicy
    source_evidence_found = $sourceEvidenceFound
    source_hints = $sourceHints
    regen_hints = $regenerationHints
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

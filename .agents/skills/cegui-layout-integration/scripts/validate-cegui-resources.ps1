[CmdletBinding()]
param(
    [string]$LayoutFamily = "",
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve paths
$scriptDir = Split-Path -Parent $PSCommandPath
$skillRoot = Split-Path -Parent $scriptDir
$helperPath = Join-Path $skillRoot "..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"
if (-not (Test-Path -LiteralPath $helperPath -PathType Leaf)) {
    throw "Shared skill script helper not found: $helperPath"
}
. $helperPath
$script:SkillScriptName = "cegui-layout-integration"
$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot

$uiRoot = Join-Path $RepoRoot "client\resource\res\ui"
$layoutDir = Join-Path $uiRoot "layouts"
$schemeDir = Join-Path $uiRoot "schemes"
$lookDir = Join-Path $uiRoot "looknfeel"
$imagesetDir = Join-Path $uiRoot "imagesets"
$fontDir = Join-Path $uiRoot "fonts"

# Load all LookNFeel WidgetLook declarations.
$widgetLooks = @{}
$lookIssues = @()
if (Test-Path -LiteralPath $lookDir -PathType Container) {
    $lookFiles = @(Get-ChildItem -LiteralPath $lookDir -File -Filter *.looknfeel -ErrorAction SilentlyContinue)
    foreach ($lookFile in $lookFiles) {
        try {
            $lookXml = [xml](Read-TextFileSmart -Path $lookFile.FullName)
            foreach ($widgetLook in $lookXml.SelectNodes("//WidgetLook")) {
                $lookName = [string]$widgetLook.GetAttribute("name")
                if (-not [string]::IsNullOrWhiteSpace($lookName)) {
                    $widgetLooks[$lookName] = $lookFile.Name
                }
            }
        } catch {
            $lookIssues += "$($lookFile.Name): XML parse failed: $($_.Exception.Message)"
        }
    }
}

# Load all scheme FalagardMappings and retain their LookNFeel target.
$schemeMappings = @{}
$schemeIssues = @()
if (Test-Path -LiteralPath $schemeDir -PathType Container) {
    $schemeFiles = @(Get-ChildItem -LiteralPath $schemeDir -File -Filter *.scheme -ErrorAction SilentlyContinue)
    foreach ($sf in $schemeFiles) {
        try {
            $xml = [xml](Read-TextFileSmart -Path $sf.FullName)
            foreach ($m in $xml.SelectNodes("//FalagardMapping")) {
                $wt = [string]$m.GetAttribute("WindowType")
                if ($wt) {
                    $schemeMappings[$wt] = [pscustomobject]@{
                        Scheme = $sf.Name
                        LookNFeel = [string]$m.GetAttribute("LookNFeel")
                    }
                }
            }
        } catch {
            $schemeIssues += "$($sf.Name): XML parse failed: $($_.Exception.Message)"
        }
    }
}

# Collect layout files
if ($LayoutFamily) {
    $layoutFiles = @(Get-ChildItem -LiteralPath $layoutDir -File -Filter "$LayoutFamily*.layout" -ErrorAction SilentlyContinue)
} else {
    $layoutFiles = @(Get-ChildItem -LiteralPath $layoutDir -File -Filter *.layout -ErrorAction SilentlyContinue)
}

$totalLayouts = $layoutFiles.Count
$totalPassed = 0
$totalFailed = 0
$allFailures = @()
$allWarnings = @()

if ($totalLayouts -eq 0) {
    $filterDescription = if ($LayoutFamily) { "$LayoutFamily*.layout" } else { "*.layout" }
    $allFailures += "no layout files matched '$filterDescription' under: $layoutDir"
}

foreach ($lf in $layoutFiles) {
    $layoutFailures = @()
    try {
        $layXml = [xml](Read-TextFileSmart -Path $lf.FullName)
        $typeSet = @{}
        $fontSet = @{}
        $imsetSet = @{}

        foreach ($wn in $layXml.SelectNodes("//Window")) {
            $t = [string]$wn.GetAttribute("Type")
            if ($t -and $t.Contains("/")) { $typeSet[$t] = $true }
            foreach ($pn in $wn.SelectNodes("Property")) {
                $pnName = [string]$pn.GetAttribute("Name")
                $pnVal = [string]$pn.GetAttribute("Value")
                if ($pnName -eq "Font" -and $pnVal) { $fontSet[$pnVal] = $true }
                if ($pnVal -match 'set:([^\s]+)\s+image:') { $imsetSet[$matches[1]] = $true }
            }
        }

        # Check types against scheme mappings
        foreach ($t in $typeSet.Keys) {
            if (-not $schemeMappings.ContainsKey($t)) {
                $layoutFailures += "$($lf.Name): type '$t' not mapped in any scheme"
                continue
            }

            $mapping = $schemeMappings[$t]
            $mappedLook = [string]$mapping.LookNFeel
            if ([string]::IsNullOrWhiteSpace($mappedLook)) {
                $layoutFailures += "$($lf.Name): type '$t' has no LookNFeel target in $($mapping.Scheme)"
            } elseif (-not $widgetLooks.ContainsKey($mappedLook)) {
                $layoutFailures += "$($lf.Name): WidgetLook '$mappedLook' for type '$t' not found in any .looknfeel"
            }
        }

        # Check font files exist
        foreach ($f in $fontSet.Keys) {
            $ff = Join-Path $fontDir "$f.font"
            if (-not (Test-Path $ff)) {
                $layoutFailures += "$($lf.Name): font '$f.font' not found"
            }
        }

        # Check imageset files exist
        foreach ($im in $imsetSet.Keys) {
            $imf = Join-Path $imagesetDir "$im.imageset"
            if (-not (Test-Path $imf)) {
                $layoutFailures += "$($lf.Name): imageset '$im.imageset' not found"
            }
        }

        if ($layoutFailures.Count -gt 0) {
            $totalFailed++
            $allFailures += $layoutFailures
        } else {
            $totalPassed++
        }
    } catch {
        $totalFailed++
        $allFailures += "$($lf.Name): XML parse error: $($_.Exception.Message)"
    }
}

# Add unreferenced XML issues as warnings. Referenced missing mappings/looks fail above.
$allWarnings += $schemeIssues
$allWarnings += $lookIssues

# Output
$summary = "CEGUI resource chain validation: Layouts=$totalLayouts Passed=$totalPassed Failed=$totalFailed WidgetLooks=$($widgetLooks.Count)"
$status = if ($totalLayouts -eq 0 -or $totalFailed -gt 0) {
    "FAIL"
} elseif ($allWarnings.Count -gt 0) {
    "WARN"
} else {
    "PASS"
}
$next = if ($totalLayouts -eq 0) {
    "Restore the expected CEGUI layout resources or pass the correct layout family, then rerun validate-cegui-resources.ps1."
} elseif ($totalFailed -gt 0) {
    "Fix missing mappings, WidgetLooks, fonts, or imagesets, then rerun validate-cegui-resources.ps1."
} elseif ($allWarnings.Count -gt 0) {
    "Review scheme/looknfeel XML warnings, then rerun if resources changed."
} else {
    "Rerun after any layout, scheme, looknfeel, imageset, or font change."
}

$resultObj = [pscustomobject][ordered]@{
    status = $status
    summary = $summary
    repo_root = $RepoRoot
    layout_family = $(if ($LayoutFamily) { $LayoutFamily } else { "ALL" })
    total_layouts = $totalLayouts
    passed = $totalPassed
    failed = $totalFailed
    scheme_mapping_count = $schemeMappings.Count
    widget_look_count = $widgetLooks.Count
    failures = @($allFailures)
    warnings = @($allWarnings)
}

$details = New-Object System.Collections.Generic.List[string]
[void]$details.Add("repo_root=$RepoRoot")
[void]$details.Add("layout_family=$(if ($LayoutFamily) { $LayoutFamily } else { 'ALL' })")
[void]$details.Add("total_layouts=$totalLayouts")
[void]$details.Add("passed=$totalPassed")
[void]$details.Add("failed=$totalFailed")
[void]$details.Add("scheme_mapping_count=$($schemeMappings.Count)")
[void]$details.Add("widget_look_count=$($widgetLooks.Count)")
foreach ($failure in @($allFailures)) { [void]$details.Add("failure=$failure") }
foreach ($warning in @($allWarnings)) { [void]$details.Add("warning=$warning") }

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $resultObj

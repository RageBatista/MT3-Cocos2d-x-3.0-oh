[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptPath,
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "lua-dialog-integration"

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$scriptRoot = Join-Path $RepoRoot "client\resource\res\script"
$uiRoot = Join-Path $RepoRoot "client\resource\res\ui"
$layoutSearchRoots = @(
    $uiRoot,
    (Join-Path $uiRoot "layouts")
)

$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$luaPath = Resolve-FilePath -InputPath $ScriptPath -RootPath $RepoRoot -SearchRoots @($scriptRoot) -DefaultExtension "lua"
if ([string]::IsNullOrWhiteSpace($luaPath)) {
    $details.Add("failure=Lua script not found: " + $ScriptPath) | Out-Null
    Write-Result -Status "FAIL" -Summary "The Lua UI script does not exist." -Next "Pass a valid Lua dialog or cell script path, then rerun the checker." -Details $details
}

$luaText = Read-TextFileSmart -Path $luaPath
$details.Add("script=" + $luaPath) | Out-Null

$mode = "manager"
if ($luaText -match 'GetLayoutFileName') {
    $mode = "dialog"
} elseif ($luaText -match 'loadWindowLayout\s*\(') {
    $mode = "cell"
}
$details.Add("mode=" + $mode) | Out-Null

$layoutName = ""
$layoutMatch = [regex]::Match($luaText, '(?s)GetLayoutFileName\s*\([^)]*\).*?return\s+["'']([^"'']+\.layout)["'']')
if ($layoutMatch.Success) {
    $layoutName = $layoutMatch.Groups[1].Value
} else {
    $dynamicLayoutMatch = [regex]::Match($luaText, 'loadWindowLayout\(\s*["'']([^"'']+\.layout)["'']')
    if ($dynamicLayoutMatch.Success) {
        $layoutName = $dynamicLayoutMatch.Groups[1].Value
    }
}

$layoutPath = ""
$windowNames = @{}
$rootWindow = ""
$crossLayoutMatches = [ordered]@{}
if (-not [string]::IsNullOrWhiteSpace($layoutName)) {
    $layoutPath = Resolve-FilePath -InputPath $layoutName -RootPath $RepoRoot -SearchRoots $layoutSearchRoots -DefaultExtension "layout"
    $details.Add("layout_name=" + $layoutName) | Out-Null
    if ([string]::IsNullOrWhiteSpace($layoutPath)) {
        $failures.Add("layout file not found for script: " + $layoutName) | Out-Null
    } else {
        $details.Add("layout_path=" + $layoutPath) | Out-Null
        try {
            $layoutXml = [xml](Read-TextFileSmart -Path $layoutPath)
            $layoutWindowNodes = @($layoutXml.SelectNodes("//Window"))
            foreach ($windowNode in $layoutWindowNodes) {
                $name = Normalize-WindowPath -Value ([string]$windowNode.GetAttribute("Name"))
                if (-not [string]::IsNullOrWhiteSpace($name)) {
                    $windowNames[$name] = $true
                }
            }
            $rootNode = $layoutWindowNodes | Select-Object -First 1
            if ($null -ne $rootNode) {
                $rootWindow = Normalize-WindowPath -Value ([string]$rootNode.GetAttribute("Name"))
                $details.Add("root_window=" + $rootWindow) | Out-Null
            }
        } catch {
            $failures.Add("layout XML parse failed: " + $layoutPath) | Out-Null
        }
    }
} elseif ($mode -eq "dialog") {
    $failures.Add("dialog script has no detectable GetLayoutFileName return value") | Out-Null
} else {
    $warnings.Add("no static layout name detected; some checks are skipped") | Out-Null
}

$staticWindowRefs = New-Object System.Collections.Generic.List[string]
foreach ($match in [regex]::Matches($luaText, 'getWindow\(\s*["'']([^"'']+)["'']\s*\)')) {
    $windowRef = Normalize-WindowPath -Value $match.Groups[1].Value
    if (-not [string]::IsNullOrWhiteSpace($windowRef) -and -not $staticWindowRefs.Contains($windowRef)) {
        $staticWindowRefs.Add($windowRef) | Out-Null
    }
}
$details.Add("static_getwindow_count=" + $staticWindowRefs.Count) | Out-Null

if ($windowNames.Count -gt 0) {
    $missingWindowRefs = @($staticWindowRefs | Where-Object { -not $windowNames.ContainsKey($_) })
    $crossLayoutIndex = @{}

    if ($missingWindowRefs.Count -gt 0 -and (Test-Path -LiteralPath $uiRoot -PathType Container)) {
        $otherLayoutFiles = @(Get-ChildItem -LiteralPath $uiRoot -Recurse -File -Filter *.layout -ErrorAction SilentlyContinue | Where-Object {
            [string]::IsNullOrWhiteSpace($layoutPath) -or -not $_.FullName.Equals($layoutPath, [System.StringComparison]::OrdinalIgnoreCase)
        })

        foreach ($otherLayoutFile in $otherLayoutFiles) {
            try {
                $otherLayoutXml = [xml](Read-TextFileSmart -Path $otherLayoutFile.FullName)
                $namesInFile = @{}
                foreach ($otherWindowNode in @($otherLayoutXml.SelectNodes("//Window"))) {
                    $otherWindowName = Normalize-WindowPath -Value ([string]$otherWindowNode.GetAttribute("Name"))
                    if (-not [string]::IsNullOrWhiteSpace($otherWindowName)) {
                        $namesInFile[$otherWindowName] = $true
                    }
                }
                foreach ($nameInFile in $namesInFile.Keys) {
                    if (-not $crossLayoutIndex.ContainsKey($nameInFile)) {
                        $crossLayoutIndex[$nameInFile] = New-Object System.Collections.Generic.List[string]
                    }
                    $crossLayoutIndex[$nameInFile].Add($otherLayoutFile.FullName) | Out-Null
                }
            } catch {
                $warnings.Add("cross-layout index skipped malformed layout: " + $otherLayoutFile.FullName) | Out-Null
            }
        }
    }

    foreach ($windowRef in $missingWindowRefs) {
        $matchingLayoutPaths = @(if ($crossLayoutIndex.ContainsKey($windowRef)) {
            $crossLayoutIndex[$windowRef] | Select-Object -Unique
        })
        $crossLayoutMatches[$windowRef] = $matchingLayoutPaths

        if ($matchingLayoutPaths.Count -eq 1) {
            $warnings.Add("unique cross-layout match for window path '" + $windowRef + "': " + $matchingLayoutPaths[0]) | Out-Null
            $details.Add("cross_layout_match=" + $windowRef + "@" + $matchingLayoutPaths[0]) | Out-Null
        } elseif ($matchingLayoutPaths.Count -gt 1) {
            $warnings.Add("multiple cross-layout matches for window path '" + $windowRef + "': " + [string]::Join(", ", $matchingLayoutPaths)) | Out-Null
            foreach ($matchPath in $matchingLayoutPaths) {
                $details.Add("cross_layout_match=" + $windowRef + "@" + $matchPath) | Out-Null
            }
        } else {
            $failures.Add("window path missing from all layouts: " + $windowRef) | Out-Null
        }
    }
} elseif ($staticWindowRefs.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($layoutName)) {
    $warnings.Add("layout window tree not available; static window-path verification skipped") | Out-Null
}

$subscribeCount = [regex]::Matches($luaText, 'subscribeEvent\s*\(').Count
$details.Add("subscribe_event_count=" + $subscribeCount) | Out-Null

$handlerRefs = New-Object System.Collections.Generic.List[string]
foreach ($match in [regex]::Matches($luaText, 'subscribeEvent\(\s*["''][^"'']+["'']\s*,\s*([A-Za-z_][\w]*\.[A-Za-z_][\w]*)')) {
    $handlerRef = $match.Groups[1].Value
    if (-not $handlerRefs.Contains($handlerRef)) {
        $handlerRefs.Add($handlerRef) | Out-Null
    }
}
$details.Add("class_handler_ref_count=" + $handlerRefs.Count) | Out-Null

foreach ($handlerRef in $handlerRefs) {
    $handlerPattern = 'function\s+' + [regex]::Escape($handlerRef) + '\b|function\s+' + [regex]::Escape($handlerRef.Replace(".", ":")) + '\b'
    if ($luaText -notmatch $handlerPattern) {
        $failures.Add("event handler not defined in script: " + $handlerRef) | Out-Null
    }
}

if ($mode -eq "dialog") {
    if ($luaText -notmatch 'require\s+["'']logic\.dialog["'']') {
        $warnings.Add("dialog script does not explicitly require logic.dialog") | Out-Null
    }
    if ($luaText -notmatch 'DestroyDialog') {
        $warnings.Add("dialog script has no DestroyDialog symbol") | Out-Null
    }
    if ($luaText -notmatch 'OnClose') {
        $warnings.Add("dialog script has no OnClose path") | Out-Null
    }
}

if ($staticWindowRefs.Count -eq 0 -and $mode -ne "manager") {
    $warnings.Add("no static getWindow path found; script may rely on dynamic prefix paths") | Out-Null
}

$status = "PASS"
$summary = "The Lua UI script's detectable layout, static window paths, and event handlers look consistent."
$next = "If you touch layout names or event callbacks, rerun this checker before moving to runtime verification."

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "The Lua UI script has layout or event-binding drift that should be fixed first."
    $next = "Fix the missing layout, window path, or callback definition, then rerun the checker."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "The Lua UI script is mostly consistent, but some lifecycle or dynamic-binding paths still need manual review."
    $next = "Review the warnings, then pair this script with the CEGUI checker for the same layout family."
}

foreach ($item in $failures) {
    $details.Add("failure=" + $item) | Out-Null
}
foreach ($item in $warnings) {
    $details.Add("warning=" + $item) | Out-Null
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    script_path = $luaPath
    mode = $mode
    layout_name = $layoutName
    layout_path = $layoutPath
    root_window = $rootWindow
    static_window_refs = $staticWindowRefs.ToArray()
    cross_layout_matches = $crossLayoutMatches
    subscribe_event_count = $subscribeCount
    handler_refs = $handlerRefs.ToArray()
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

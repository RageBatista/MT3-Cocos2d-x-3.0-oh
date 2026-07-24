[CmdletBinding()]
param(
    [Parameter(ParameterSetName="Single", Mandatory=$true)]
    [string]$Layout,

    [Parameter(ParameterSetName="Family")]
    [string]$Family = "",

    [Parameter(ParameterSetName="All")]
    [switch]$All,

    [string]$LuaScript = "",
    [string]$RepoRoot = "",
    [switch]$SkipLuaBindings,
    [switch]$DeepScan,
    [switch]$PerformanceCheck,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---- helpers ----
$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
if (-not (Test-Path $skillHelperPath)) {
    Write-Warning "skill-script-helpers.ps1 not found; using inline fallback definitions"
}
else {
    . $skillHelperPath
}
$script:SkillScriptName = "cegui-layout-integration"

# fallback helpers
if (-not (Get-Command -Name Resolve-RepoRootPath -ErrorAction SilentlyContinue)) {
    function Resolve-RepoRootPath { param($InputPath) if ($InputPath) { $InputPath } else { "e:/MT3" } }
}
if (-not (Get-Command -Name Resolve-FilePath -ErrorAction SilentlyContinue)) {
    function Resolve-FilePath { param($InputPath, $RootPath, $SearchRoots, $DefaultExtension) $InputPath }
}
if (-not (Get-Command -Name Read-TextFileSmart -ErrorAction SilentlyContinue)) {
    function Read-TextFileSmart { param($Path) Get-Content -Path $Path -Raw -Encoding UTF8 }
}
if (-not (Get-Command -Name Normalize-WindowPath -ErrorAction SilentlyContinue)) {
    function Normalize-WindowPath { param($Value) $Value }
}
if (-not (Get-Command -Name Write-Result -ErrorAction SilentlyContinue)) {
    function Write-Result { param($Status, $Summary, $Next, $Details, $Payload) 
        $result = [PSCustomObject]@{ status=$Status; summary=$Summary; next=$Next; details=$Details; payload=$Payload }
        if ($Json) { $result | ConvertTo-Json -Depth 10 } else { $result | Format-List }
    }
}

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$perfNotes = New-Object System.Collections.Generic.List[string]

$uiRoot = Join-Path $RepoRoot "client\resource\res\ui"
$layoutRoot = Join-Path $uiRoot "layouts"
$scriptRoot = Join-Path $RepoRoot "client\resource\res\script"
$schemeDir = Join-Path $uiRoot "schemes"
$fontDir = Join-Path $uiRoot "fonts"
$imagesetDir = Join-Path $uiRoot "imagesets"

# ---- Step 0: determine layout targets ----
$layoutFiles = @()

if ($PSCmdlet.ParameterSetName -eq "Single") {
    $resolved = Resolve-FilePath -InputPath $Layout -RootPath $RepoRoot -SearchRoots @($uiRoot, $layoutRoot) -DefaultExtension "layout"
    if ([string]::IsNullOrWhiteSpace($resolved)) {
        $details.Add("failure=layout not found: $Layout") | Out-Null
        Write-Result -Status "FAIL" -Summary "Target layout file does not exist." -Next "Pass a valid .layout path or file name." -Details $details
        exit 1
    }
    $layoutFiles = @($resolved)
}
elseif ($PSCmdlet.ParameterSetName -eq "Family") {
    if ([string]::IsNullOrWhiteSpace($Family)) {
        Write-Result -Status "FAIL" -Summary "-Family requires a non-empty prefix (e.g., 'role_', 'item_')." -Next "Specify a family prefix or use -All for all layouts." -Details $details
        exit 1
    }
    $layoutFiles = @(Get-ChildItem -Path $layoutRoot -File -Filter "${Family}*.layout" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
    if ($layoutFiles.Count -eq 0) {
        $details.Add("failure=no layouts found for family prefix: $Family") | Out-Null
        Write-Result -Status "FAIL" -Summary "No .layout files match family prefix '$Family'." -Next "Verify the prefix or use a different pattern." -Details $details
        exit 1
    }
    $details.Add("family=$Family") | Out-Null
    $details.Add("family_layout_count=$($layoutFiles.Count)") | Out-Null
}
elseif ($PSCmdlet.ParameterSetName -eq "All") {
    $layoutFiles = @(Get-ChildItem -Path $layoutRoot -File -Filter *.layout -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
    if ($layoutFiles.Count -eq 0) {
        Write-Result -Status "FAIL" -Summary "No .layout files found in $layoutRoot" -Next "Verify the UI layouts directory." -Details $details
        exit 1
    }
    $details.Add("all_layouts_count=$($layoutFiles.Count)") | Out-Null
}

$details.Add("layout_count_to_check=$($layoutFiles.Count)") | Out-Null

# ---- Step 1: load scheme/font/imageset indexes ----
$schemeMappings = @{}
$schemeFonts = @{}
$schemeImagesets = @{}
$fontFiles = @{}
$imagesetFiles = @{}

if (Test-Path $fontDir -PathType Container) {
    foreach ($file in @(Get-ChildItem -Path $fontDir -File -Filter *.font -ErrorAction SilentlyContinue)) {
        $fontFiles[$file.BaseName] = $file.FullName
    }
}
if (Test-Path $imagesetDir -PathType Container) {
    foreach ($file in @(Get-ChildItem -Path $imagesetDir -File -Filter *.imageset -ErrorAction SilentlyContinue)) {
        $imagesetFiles[$file.BaseName] = $file.FullName
    }
}
if (Test-Path $schemeDir -PathType Container) {
    foreach ($schemeFile in @(Get-ChildItem -Path $schemeDir -File -Filter *.scheme -ErrorAction SilentlyContinue)) {
        try {
            $schemeXml = [xml](Read-TextFileSmart -Path $schemeFile.FullName)
        } catch {
            $warnings.Add("scheme parse skipped: " + $schemeFile.FullName) | Out-Null
            continue
        }
        foreach ($mapping in @($schemeXml.SelectNodes("//FalagardMapping"))) {
            $wt = [string]$mapping.GetAttribute("WindowType")
            if (-not [string]::IsNullOrWhiteSpace($wt)) { $schemeMappings[$wt] = $schemeFile.Name }
        }
        foreach ($fn in @($schemeXml.SelectNodes("//Font"))) {
            $f = [string]$fn.GetAttribute("Filename")
            if ($f) { $schemeFonts[[System.IO.Path]::GetFileNameWithoutExtension($f)] = $schemeFile.Name }
        }
        foreach ($in in @($schemeXml.SelectNodes("//Imageset"))) {
            $f = [string]$in.GetAttribute("Filename")
            if ($f) { $schemeImagesets[[System.IO.Path]::GetFileNameWithoutExtension($f)] = $schemeFile.Name }
        }
    }
}

$details.Add("scheme_mapping_count=$($schemeMappings.Count)") | Out-Null
$details.Add("available_font_count=$($fontFiles.Count)") | Out-Null
$details.Add("available_imageset_count=$($imagesetFiles.Count)") | Out-Null

# ---- Step 2: scan each layout ----
$allWindowNames = @{}          # global map: windowPath -> layoutFile
$allWindowTypes = @{}          # global type set
$allFontRefs = @{}             # global font ref set
$allImagesetRefs = @{}         # global imageset ref set
$allLuaEventHandlers = @{}     # global handler set
$layoutParsedCount = 0
$layoutFailCount = 0
$perLayoutStats = @()          # for performance analysis

foreach ($layoutPath in $layoutFiles) {
    $layoutText = Read-TextFileSmart -Path $layoutPath
    try {
        $layoutXml = [xml]$layoutText
    } catch {
        $warnings.Add("layout xml parse failed: $layoutPath") | Out-Null
        $layoutFailCount++
        continue
    }
    $layoutParsedCount++

    $localWindowNames = @{}
    $localWindowTypes = @{}
    $localFontRefs = @{}
    $localImagesetRefs = @{}
    $localLuaHandlers = @{}

    $windowNodes = @($layoutXml.SelectNodes("//Window"))
    $layoutName = [System.IO.Path]::GetFileName($layoutPath)

    foreach ($wn in $windowNodes) {
        $name = Normalize-WindowPath -Value ([string]$wn.GetAttribute("Name"))
        $type = [string]$wn.GetAttribute("Type")
        if ($name) {
            $localWindowNames[$name] = $true
            $allWindowNames[$name] = $layoutName
        }
        if ($type) {
            $localWindowTypes[$type] = $true
            $allWindowTypes[$type] = $true
        }
        foreach ($pn in @($wn.SelectNodes("Property"))) {
            $pnName = [string]$pn.GetAttribute("Name")
            $pnValue = [string]$pn.GetAttribute("Value")
            if ($pnName -eq "Font" -and $pnValue) {
                $localFontRefs[$pnValue] = $true
                $allFontRefs[$pnValue] = $true
            }
            if ($pnName -eq "LuaEventOnClicked" -and $pnValue) {
                $localLuaHandlers[$pnValue] = $true
                $allLuaEventHandlers[$pnValue] = $true
            }
            if ($pnValue -and $pnValue -match 'set:([^\s]+)\s+image:') {
                $localImagesetRefs[$matches[1]] = $true
                $allImagesetRefs[$matches[1]] = $true
            }
        }
    }

    # per-layout validation
    $hasFailures = $false
    foreach ($typeName in ($localWindowTypes.Keys | Sort-Object)) {
        if ([string]::IsNullOrWhiteSpace($typeName)) { continue }
        if ($typeName.Contains("/")) {
            if (-not $schemeMappings.ContainsKey($typeName)) {
                $failures.Add("$layoutName : unmapped window type: $typeName") | Out-Null
                $hasFailures = $true
            }
        }
    }
    foreach ($fontName in ($localFontRefs.Keys | Sort-Object)) {
        if (-not $fontFiles.ContainsKey($fontName)) {
            $failures.Add("$layoutName : missing font file for ref: $fontName") | Out-Null
            $hasFailures = $true
        } elseif (-not $schemeFonts.ContainsKey($fontName)) {
            $warnings.Add("$layoutName : font not declared in scheme: $fontName") | Out-Null
        }
    }
    foreach ($inName in ($localImagesetRefs.Keys | Sort-Object)) {
        if (-not $imagesetFiles.ContainsKey($inName)) {
            $failures.Add("$layoutName : missing imageset file for ref: $inName") | Out-Null
            $hasFailures = $true
        } elseif (-not $schemeImagesets.ContainsKey($inName)) {
            $warnings.Add("$layoutName : imageset not declared in scheme: $inName") | Out-Null
        }
    }

    # collect performance stats per layout
    $perLayoutStats += [PSCustomObject]@{
        Layout = $layoutName
        WindowCount = $localWindowNames.Count
        TypeCount = $localWindowTypes.Count
        FontRefCount = $localFontRefs.Count
        ImagesetRefCount = $localImagesetRefs.Count
        LuaHandlerCount = $localLuaHandlers.Count
        HasFailures = $hasFailures
    }
}

$details.Add("layouts_parsed=$layoutParsedCount") | Out-Null
$details.Add("layouts_parse_failed=$layoutFailCount") | Out-Null
$details.Add("total_window_names=$($allWindowNames.Count)") | Out-Null
$details.Add("total_window_types=$($allWindowTypes.Count)") | Out-Null
$details.Add("total_font_refs=$($allFontRefs.Count)") | Out-Null
$details.Add("total_imageset_refs=$($allImagesetRefs.Count)") | Out-Null
$details.Add("total_lua_event_handlers=$($allLuaEventHandlers.Count)") | Out-Null

# ---- Step 3: DeepScan - cross-reference Lua getWindow paths ----
if ($DeepScan -and $layoutParsedCount -gt 0) {
    $details.Add("deep_scan=enabled") | Out-Null

    # find Lua files that reference any of these layouts
    $luaFiles = @(Get-ChildItem -Path $scriptRoot -Recurse -File -Filter *.lua -ErrorAction SilentlyContinue)
    $layoutNamesSet = @{}
    foreach ($lf in $layoutFiles) {
        $layoutNamesSet[[System.IO.Path]::GetFileName($lf)] = $true
    }

    # Build a regex that matches any of the layout filenames
    $layoutPatterns = @()
    foreach ($ln in $layoutNamesSet.Keys) {
        $escaped = [regex]::Escape($ln)
        $layoutPatterns += "'$escaped'"
        $layoutPatterns += "`"$escaped`""
    }
    $combinedPattern = ($layoutPatterns -join '|')

    $referencingLuaFiles = @()
    if ($combinedPattern) {
        foreach ($luaFile in $luaFiles) {
            try {
                $content = Get-Content -Path $luaFile.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($content -and $content -match $combinedPattern) {
                    $referencingLuaFiles += $luaFile.FullName
                }
            } catch { }
        }
    }

    $details.Add("deep_scan_lua_candidates=$($referencingLuaFiles.Count)") | Out-Null

    # For each referencing Lua file, extract all getWindow() paths and cross-reference
    $luaWindowRefs = @{}   # getWindow path -> list of Lua files
    foreach ($luaFile in $referencingLuaFiles) {
        try {
            $luaText = Get-Content -Path $luaFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
            if (-not $luaText) { continue }
            foreach ($match in [regex]::Matches($luaText, 'getWindow\(\s*["'']([^"'']+)["'']\s*\)')) {
                $wref = Normalize-WindowPath -Value $match.Groups[1].Value
                if ($wref) {
                    if (-not $luaWindowRefs.ContainsKey($wref)) {
                        $luaWindowRefs[$wref] = New-Object System.Collections.Generic.List[string]
                    }
                    $luaWindowRefs[$wref].Add($luaFile) | Out-Null
                }
            }
        } catch { }
    }

    $details.Add("deep_scan_lua_getwindow_refs_total=$($luaWindowRefs.Count)") | Out-Null

    # Cross-reference: for each Lua getWindow path, check if it exists in ANY scanned layout
    $orphanRefs = 0
    $foundRefs = 0
    foreach ($kv in $luaWindowRefs.GetEnumerator()) {
        if ($allWindowNames.ContainsKey($kv.Key)) {
            $foundRefs++
        } else {
            $orphanRefs++
            $srcFiles = ($kv.Value | Select-Object -First 3) -join "; "
            $failures.Add("deep_scan : Lua getWindow('$($kv.Key)') not found in any scanned layout (ref: $srcFiles)") | Out-Null
        }
    }

    $details.Add("deep_scan_lua_refs_found=$foundRefs") | Out-Null
    $details.Add("deep_scan_lua_refs_orphan=$orphanRefs") | Out-Null

    # Check LuaEventOnClicked cross-layout consistency
    if ($allLuaEventHandlers.Count -gt 0) {
        $details.Add("deep_scan_lua_handlers_total=$($allLuaEventHandlers.Count)") | Out-Null

        # Collect all Lua functions across referencing Lua files
        $luaFunctions = @{}
        foreach ($luaFile in $referencingLuaFiles) {
            try {
                $luaText = Get-Content -Path $luaFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if (-not $luaText) { continue }
                # Match global, local, table-dot, and table-colon Lua function declarations.
                $functionPatterns = @(
                    '(?m)\b(?:local\s+)?function\s+(?:(?:\w[\w\d_]*[.:])*)(\w[\w\d_]*)\s*\(',
                    '(?m)(?:^|[^\w.])(?:local\s+)?(?:(?:\w[\w\d_]*[.:])*)(\w[\w\d_]*)\s*=\s*function\s*\('
                )
                foreach ($pattern in $functionPatterns) {
                    foreach ($fm in [regex]::Matches($luaText, $pattern)) {
                        $fname = $fm.Groups[1].Value
                        if (-not $luaFunctions.ContainsKey($fname)) {
                            $luaFunctions[$fname] = New-Object System.Collections.Generic.List[string]
                        }
                        $luaFunctions[$fname].Add($luaFile) | Out-Null
                    }
                }
            } catch { }
        }

        foreach ($handlerName in $allLuaEventHandlers.Keys) {
            if (-not $luaFunctions.ContainsKey($handlerName)) {
                $failures.Add("deep_scan : LuaEventOnClicked handler '$handlerName' not found in any Lua file") | Out-Null
            }
        }
    }
}

# ---- Step 4: PerformanceCheck ----
if ($PerformanceCheck -and $perLayoutStats.Count -gt 0) {
    $details.Add("performance_check=enabled") | Out-Null

    # Check 1: Total imageset count
    if ($allImagesetRefs.Count -gt 20) {
        $perfNotes.Add("IMAGESET_OVERFLOW: $($allImagesetRefs.Count) unique imagesets referenced (recommended <= 20)") | Out-Null
    } else {
        $perfNotes.Add("imageset_count_ok: $($allImagesetRefs.Count) unique imagesets") | Out-Null
    }

    # Check 2: Total font count
    if ($allFontRefs.Count -gt 5) {
        $perfNotes.Add("FONT_OVERFLOW: $($allFontRefs.Count) unique fonts referenced (recommended <= 5)") | Out-Null
    } else {
        $perfNotes.Add("font_count_ok: $($allFontRefs.Count) unique fonts") | Out-Null
    }

    # Check 3: High window count per layout
    $highWindowLayouts = $perLayoutStats | Where-Object { $_.WindowCount -gt 50 }
    foreach ($hwl in $highWindowLayouts) {
        $perfNotes.Add("HIGH_WINDOW_COUNT: $($hwl.Layout) has $($hwl.WindowCount) windows (recommended <= 50)") | Out-Null
    }

    # Check 4: Layouts with too many types (possible scheme splitting needed)
    $highTypeLayouts = $perLayoutStats | Where-Object { $_.TypeCount -gt 10 }
    foreach ($htl in $highTypeLayouts) {
        $perfNotes.Add("HIGH_TYPE_VARIETY: $($htl.Layout) uses $($htl.TypeCount) window types (scheme splitting candidate)") | Out-Null
    }

    # Check 5: Average window count
    $avgWindows = [math]::Round(($perLayoutStats | Measure-Object -Property WindowCount -Average).Average, 1)
    $perfNotes.Add("avg_windows_per_layout: $avgWindows") | Out-Null

    # Check 6: Detect imageset texture sizes (read imageset files)
    $largeTextures = @()
    if (Test-Path $imagesetDir -PathType Container) {
        foreach ($isName in $allImagesetRefs.Keys) {
            $isPath = Join-Path $imagesetDir "${isName}.imageset"
            if (-not (Test-Path $isPath)) { continue }
            try {
                $isXml = [xml](Read-TextFileSmart -Path $isPath)
                $imgNode = $isXml.SelectNodes("//Image") | Select-Object -First 1
                if ($imgNode) {
                    $w = [int]$imgNode.GetAttribute("XSize")
                    $h = [int]$imgNode.GetAttribute("YSize")
                    if ($w -gt 2048 -or $h -gt 2048) {
                        $largeTextures += "${isName} (${w}x${h})"
                        $perfNotes.Add("LARGE_TEXTURE: ${isName}.imageset (${w}x${h}) exceeds 2048x2048") | Out-Null
                    } elseif ($w -gt 1024 -or $h -gt 1024) {
                        $perfNotes.Add("MEDIUM_TEXTURE: ${isName}.imageset (${w}x${h}) - consider atlas optimization") | Out-Null
                    }
                }
            } catch { }
        }
    }
    if ($largeTextures.Count -eq 0) {
        $perfNotes.Add("texture_size_check: no oversized textures detected") | Out-Null
    }

    # Check 7: Layout count (loading time risk)
    if ($layoutFiles.Count -gt 100) {
        $perfNotes.Add("LAYOUT_COUNT_HIGH: $($layoutFiles.Count) layout files in scan - consider lazy loading for off-screen dialogs") | Out-Null
    }

    $details.Add("performance_notes_count=$($perfNotes.Count)") | Out-Null
    foreach ($pn in $perfNotes) {
        $details.Add("perf_note=$pn") | Out-Null
    }
}

# ---- Step 5: Determine status ----
$status = "PASS"
$summary = "All checked layouts are consistent with scheme mappings and available resources."
$next = "Rerun after any layout/scheme/resource change to catch drift early."

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "$($failures.Count) failure(s) found. Check details for specific layout+resource mismatches."
    $next = "Fix each failure (unmapped types, missing resources), then rerun."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "All critical checks passed, but $($warnings.Count) warning(s) need manual review."
    $next = "Review warnings (scheme registration gaps, missing Lua handlers), then rerun if needed."
}

if ($PerformanceCheck -and $perfNotes.Count -gt 0) {
    $next = $next + " Performance notes should be reviewed for optimization opportunities."
}

# Append failures and warnings to details
foreach ($item in $failures) {
    $details.Add("failure=$item") | Out-Null
}
foreach ($item in $warnings) {
    $details.Add("warning=$item") | Out-Null
}

# ---- Build payload ----
$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    scan_mode = $PSCmdlet.ParameterSetName
    layout_files = @($layoutFiles | ForEach-Object { [System.IO.Path]::GetFileName($_) })
    scheme_mappings = @($schemeMappings.Keys | Sort-Object)
    total_window_types = @($allWindowTypes.Keys | Sort-Object)
    total_font_refs = @($allFontRefs.Keys | Sort-Object)
    total_imageset_refs = @($allImagesetRefs.Keys | Sort-Object)
    total_lua_event_handlers = @($allLuaEventHandlers.Keys | Sort-Object)
    per_layout_stats = @($perLayoutStats)
    deep_scan_enabled = [bool]$DeepScan
    performance_check_enabled = [bool]$PerformanceCheck
    failures = @($failures)
    warnings = @($warnings)
    performance_notes = @($perfNotes)
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

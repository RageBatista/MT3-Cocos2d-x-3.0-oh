[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "application-core-flow"

function Test-Marker {
    param(
        [string]$Text,
        [string]$Pattern
    )

    return [regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
}

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$mainMarkersFound = New-Object System.Collections.Generic.List[string]
$coreMarkersFound = New-Object System.Collections.Generic.List[string]
$optionalMarkersFound = New-Object System.Collections.Generic.List[string]

$mainPath = Join-Path $RepoRoot "client\MT3Win32App\main.cpp"
$gameAppPath = Join-Path $RepoRoot "client\FireClient\Application\Framework\GameApplication.cpp"
$loginManagerPath = Join-Path $RepoRoot "client\FireClient\Application\Manager\LoginManager.cpp"
$battleDir = Join-Path $RepoRoot "client\FireClient\Application\Battle"

foreach ($requiredFile in @($mainPath, $gameAppPath, $loginManagerPath)) {
    if (-not (Test-Path $requiredFile -PathType Leaf)) {
        [void]$failures.Add("missing anchor file: " + $requiredFile.Substring($RepoRoot.Length + 1).Replace("\", "/"))
    }
}

if (-not (Test-Path $battleDir -PathType Container)) {
    [void]$warnings.Add("missing battle directory anchor: client/FireClient/Application/Battle")
}

if ($failures.Count -eq 0) {
    $mainText = Read-TextFileSmart -Path $mainPath
    $gameAppText = Read-TextFileSmart -Path $gameAppPath

    $mainMarkers = [ordered]@{
        win32_entry = '_tWinMain\s*\('
        handoff_to_shared_core = 'gRunGameApplication\s*\('
        gl_view_bootstrap = 'CCEGLView::sharedOpenGLView\s*\('
    }
    foreach ($name in $mainMarkers.Keys) {
        if (Test-Marker -Text $mainText -Pattern $mainMarkers[$name]) {
            [void]$mainMarkersFound.Add($name)
            [void]$details.Add("main_marker=" + $name)
        } else {
            [void]$failures.Add("main.cpp missing marker: " + $name)
        }
    }

    $coreMarkers = [ordered]@{
        run_entry = 'bool\s+gRunGameApplication\s*\(\s*\)'
        init_stages = 'bool\s+GameApplication::OnInit\s*\(\s*int\s+step\s*\)'
        login_manager_new = 'LoginManager::NewInstance\s*\(\s*\)'
        login_manager_init = 'gGetLoginManager\(\)->Init\s*\(\s*\)'
        login_manager_run = 'gGetLoginManager\(\)->Run\s*\(\s*now\s*,\s*delta\s*\)'
    }
    foreach ($name in $coreMarkers.Keys) {
        if (Test-Marker -Text $gameAppText -Pattern $coreMarkers[$name]) {
            [void]$coreMarkersFound.Add($name)
            [void]$details.Add("core_marker=" + $name)
        } else {
            [void]$failures.Add("GameApplication.cpp missing marker: " + $name)
        }
    }

    $optionalMarkers = [ordered]@{
        battle_manager_new = 'BattleManager::NewInstance\s*\(\s*\)'
        battle_manager_run = 'GetBattleManager\(\)->Run\s*\(\s*now\s*,\s*delta\s*\)'
        battle_manager_draw = 'GetBattleManager\(\)->Draw\s*\('
        run_trace = 'MT3_TRACE\("gRunGameApplication enter"\)'
    }
    foreach ($name in $optionalMarkers.Keys) {
        if (Test-Marker -Text $gameAppText -Pattern $optionalMarkers[$name]) {
            [void]$optionalMarkersFound.Add($name)
            [void]$details.Add("optional_marker=" + $name)
        } else {
            [void]$warnings.Add("missing optional core-flow marker: " + $name)
        }
    }

    [void]$details.Add("anchor=client/MT3Win32App/main.cpp")
    [void]$details.Add("anchor=client/FireClient/Application/Framework/GameApplication.cpp")
    [void]$details.Add("anchor=client/FireClient/Application/Manager/LoginManager.cpp")
    if (Test-Path $battleDir -PathType Container) {
        [void]$details.Add("anchor=client/FireClient/Application/Battle")
    }
}

$status = "PASS"
$summary = "The Win32 entry and shared core-flow anchors are aligned with the expected gRunGameApplication handoff."
$next = "If the issue is after startup handoff, continue from GameApplication::OnInit stages and LoginManager run loop."

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "The shared core-flow entry chain has drift and should be fixed before deeper business-layer analysis."
    $next = "Restore the missing handoff or initialization anchor first, then rerun this probe."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "The shared core-flow handoff is present, but some secondary anchors still need manual confirmation."
    $next = "Review the warned optional anchors before patching battle or scene-side logic."
}

foreach ($item in $failures) {
    [void]$details.Add("failure=" + $item)
}
foreach ($item in $warnings) {
    [void]$details.Add("warning=" + $item)
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    main_path = $mainPath
    game_application_path = $gameAppPath
    login_manager_path = $loginManagerPath
    battle_directory = $battleDir
    main_markers_found = $mainMarkersFound.ToArray()
    core_markers_found = $coreMarkersFound.ToArray()
    optional_markers_found = $optionalMarkersFound.ToArray()
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

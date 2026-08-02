[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "rendering-pipeline"

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

$renderFiles = [ordered]@{
    cegui_renderer = "tools/CEGUI-0.7.9-r5/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp"
    cegui_window_manager = "tools/CEGUI-0.7.9-r5/cegui/src/CEGUIWindowManager.cpp"
    cegui_pfs_provider = "tools/CEGUI-0.7.9-r5/cegui/src/CEGUIPfsResourceProvider.cpp"
    game_ui_manager = "client/FireClient/Application/Manager/GameUIManager.cpp"
    nuclear_renderer = "engine/renderer/nucocos2d_render.cpp"
}

foreach ($label in $renderFiles.Keys) {
    $fullPath = Join-Path $RepoRoot $renderFiles[$label]
    if (Test-Path $fullPath -PathType Leaf) {
        [void]$details.Add($label + "=" + $renderFiles[$label].Replace("\", "/"))
    } else {
        [void]$failures.Add("missing render anchor: " + $renderFiles[$label].Replace("\", "/"))
    }
}

if ($failures.Count -eq 0) {
    $rendererText = Read-TextFileSmart -Path (Join-Path $RepoRoot $renderFiles.cegui_renderer)
    $windowManagerText = Read-TextFileSmart -Path (Join-Path $RepoRoot $renderFiles.cegui_window_manager)
    $pfsProviderText = Read-TextFileSmart -Path (Join-Path $RepoRoot $renderFiles.cegui_pfs_provider)
    $gameUiText = Read-TextFileSmart -Path (Join-Path $RepoRoot $renderFiles.game_ui_manager)
    $nuclearText = Read-TextFileSmart -Path (Join-Path $RepoRoot $renderFiles.nuclear_renderer)

    $requiredMarkers = [ordered]@{
        renderer_bootstrap = @{
            text = $rendererText
            pattern = 'bootstrapSystem'
        }
        renderer_destroy = @{
            text = $rendererText
            pattern = 'destroySystem'
        }
        renderer_resource_provider = @{
            text = $rendererText
            pattern = 'getResourceProvider'
        }
        renderer_pfs_provider = @{
            text = $rendererText
            pattern = 'ResourceProvider'
        }
        ui_bootstrap = @{
            text = $gameUiText
            pattern = 'CEGUI::Cocos2DRenderer::bootstrapSystem'
        }
        ui_system_create = @{
            text = $gameUiText
            pattern = 'CEGUI::System::create'
        }
        ui_resource_provider = @{
            text = $gameUiText
            pattern = 'new\s+CEGUI::PFSResourceProvider'
        }
        ui_default_layout_group = @{
            text = $gameUiText
            pattern = 'WindowManager::setDefaultResourceGroup\("layouts"\)'
        }
        ui_render_gui = @{
            text = $gameUiText
            pattern = 'renderGUI\s*\(\s*\)'
        }
        window_manager_load_layout = @{
            text = $windowManagerText
            pattern = 'loadWindowLayout'
        }
        window_manager_get_window = @{
            text = $windowManagerText
            pattern = 'getWindow\s*\('
        }
        pfs_load_raw = @{
            text = $pfsProviderText
            pattern = 'loadRawDataContainer'
        }
        pfs_final_filename = @{
            text = $pfsProviderText
            pattern = 'getFinalFilename'
        }
        pfs_group_listing = @{
            text = $pfsProviderText
            pattern = 'getResourceGroupFileNames'
        }
        nuclear_push_rt = @{
            text = $nuclearText
            pattern = 'PushRenderTarget'
        }
        nuclear_pop_rt = @{
            text = $nuclearText
            pattern = 'PopRenderTarget'
        }
        nuclear_render_effect = @{
            text = $nuclearText
            pattern = 'SetRenderEffect'
        }
        nuclear_draw_particles = @{
            text = $nuclearText
            pattern = 'DrawCurParticles'
        }
    }

    foreach ($name in $requiredMarkers.Keys) {
        $marker = $requiredMarkers[$name]
        if (Test-Marker -Text ([string]$marker.text) -Pattern ([string]$marker.pattern)) {
            [void]$details.Add("marker=" + $name)
        } else {
            [void]$failures.Add("missing render marker: " + $name)
        }
    }

    $optionalMarkers = [ordered]@{
        ui_performance_panel = @{
            text = $gameUiText
            pattern = 'DrawPerformance'
        }
        nuclear_texture_metrics = @{
            text = $gameUiText
            pattern = 'ManagedTextureCount'
        }
    }
    foreach ($name in $optionalMarkers.Keys) {
        $marker = $optionalMarkers[$name]
        if (Test-Marker -Text ([string]$marker.text) -Pattern ([string]$marker.pattern)) {
            [void]$details.Add("optional_marker=" + $name)
        } else {
            [void]$warnings.Add("missing optional render marker: " + $name)
        }
    }
}

$status = "PASS"
$summary = "The CEGUI, FireClient UI, and Nuclear renderer anchors still form a consistent render stack."
$next = "If the symptom is visual, keep tracing from GameUIManager into the CEGUI resource provider and Nuclear renderer state."

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "The render stack baseline has drift and should be repaired before changing UI or renderer code."
    $next = "Restore the missing renderer, resource-provider, or UI bootstrap marker first, then rerun this probe."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "The main render stack is intact, but some secondary performance anchors still need manual confirmation."
    $next = "Review the warned performance anchors before optimizing draw or texture behavior."
}

foreach ($item in $failures) {
    [void]$details.Add("failure=" + $item)
}
foreach ($item in $warnings) {
    [void]$details.Add("warning=" + $item)
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    render_anchors = [pscustomobject]$renderFiles
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

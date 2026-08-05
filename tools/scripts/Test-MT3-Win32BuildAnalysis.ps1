param(
    [string]$RootPath = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)]$Actual,
        [Parameter(Mandatory = $true)]$Expected,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if ($Actual -ne $Expected) {
        throw ("{0}. Expected: {1}; Actual: {2}" -f $Message, $Expected, $Actual)
    }
}

function Assert-ManifestConsumer {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$ProfileVariable,
        [Parameter(Mandatory = $true)][int]$ExpectedCallCount,
        [Parameter(Mandatory = $true)][bool]$IncludeFinalExecutable
    )

    $scriptPath = Join-Path $RepoRoot $RelativePath
    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        $scriptPath,
        [ref]$tokens,
        [ref]$parseErrors
    )
    Assert-Equal -Actual @($parseErrors).Count -Expected 0 -Message ("{0} should parse" -f $RelativePath)

    $commands = @(
        $ast.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.GetCommandName() -eq "Get-MT3Win32ProjectManifest"
        }, $true)
    )
    Assert-Equal -Actual $commands.Count -Expected $ExpectedCallCount -Message ("{0} manifest call count" -f $RelativePath)

    $profilePattern = '-EngineProfile\s+\$' + [regex]::Escape($ProfileVariable) + '\b'
    foreach ($command in $commands) {
        $commandText = $command.Extent.Text
        Assert-True -Condition ($commandText -match $profilePattern) -Message ("{0} should forward {1}" -f $RelativePath, $ProfileVariable)
        Assert-Equal `
            -Actual ([bool]($commandText -match '(?i)-IncludeFinalExecutable\b')) `
            -Expected $IncludeFinalExecutable `
            -Message ("{0} IncludeFinalExecutable contract" -f $RelativePath)
    }
}

function Assert-ManifestContract {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$Profile,
        [Parameter(Mandatory = $true)][string[]]$ExpectedEntries
    )

    $items = @(Get-MT3Win32ProjectManifest -RepoRoot $RepoRoot -EngineProfile $Profile -IncludeFinalExecutable)
    Assert-Equal -Actual $items.Count -Expected $ExpectedEntries.Count -Message ("{0} manifest count" -f $Profile)

    for ($index = 0; $index -lt $ExpectedEntries.Count; $index++) {
        $item = $items[$index]
        $actualEntry = "{0}|{1}|{2}" -f $item.Name, $item.RelativePath, $item.DisableProjectReferences
        Assert-Equal -Actual $actualEntry -Expected $ExpectedEntries[$index] -Message ("{0} manifest entry {1}" -f $Profile, $index)
        Assert-True -Condition (Test-Path -LiteralPath $item.Path -PathType Leaf) -Message ("{0} manifest path should exist: {1}" -f $Profile, $item.RelativePath)
    }
}

function Invoke-AnalyzerProfileTest {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$Profile,
        [Parameter(Mandatory = $true)][int]$ExpectedProjectCount
    )

    $scriptPath = Join-Path $RepoRoot "tools\scripts\Analyze-MT3-Win32Build.ps1"
    $output = @(
        & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -RootPath $RepoRoot -EngineProfile $Profile -Json 2>&1
    )
    $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }

    Assert-Equal -Actual $exitCode -Expected 0 -Message ("{0} analyzer should exit 0 for WARN governance findings" -f $Profile)

    $jsonText = ($output | Out-String).Trim()
    Assert-True -Condition (-not [string]::IsNullOrWhiteSpace($jsonText)) -Message ("{0} analyzer should emit JSON" -f $Profile)

    $payload = $jsonText | ConvertFrom-Json -ErrorAction Stop
    Assert-Equal -Actual ([string]$payload.status) -Expected "WARN" -Message ("{0} should report current governance warnings" -f $Profile)
    Assert-Equal -Actual ([string]$payload.skill) -Expected "windows-v120-build" -Message "Analyzer should identify the build skill domain"
    Assert-Equal -Actual ([string]$payload.data.engine_profile) -Expected $Profile -Message "Analyzer should report the requested profile"
    Assert-True -Condition ($payload.details.Count -gt 0) -Message "Analyzer should include human-readable details"
    Assert-Equal -Actual ([int]$payload.data.actual_build_projects.Count) -Expected $ExpectedProjectCount -Message ("{0} build manifest count" -f $Profile)
    Assert-Equal -Actual ([int]$payload.data.check_v120_projects.Count) -Expected $ExpectedProjectCount -Message ("{0} toolset manifest count" -f $Profile)
    Assert-True -Condition ($payload.data.warnings.Count -gt 0) -Message "Analyzer should report warnings"

    $joinedWarnings = ($payload.data.warnings | Out-String)
    Assert-True -Condition ($joinedWarnings -notmatch "check_v120_list_only|build_script_only") -Message "Analyzer should not report shared manifest drift"
    Assert-True -Condition ($joinedWarnings -match "legacy_solution_reference") -Message "Analyzer should detect legacy solution references"
}

$repoRoot = [System.IO.Path]::GetFullPath($RootPath)
$buildConfigModule = Join-Path $repoRoot "tools\scripts\build-config.psm1"
Import-Module -Name $buildConfigModule -Force

$expectedUpgrade30 = @(
    "platform|common\platform\platform.win32.vcxproj|False",
    "ljfm|common\ljfm\ljfm.win32.vcxproj|False",
    "cauthc|common\cauthc\projects\windows\cauthc.win32.vcxproj|False",
    "cocos30_kazmath|cocos2d-x-3.0-oh\build\cocos\math\kazmath\kazmath\kazmath.vcxproj|True",
    "cocos30_tinyxml2|cocos2d-x-3.0-oh\build\external\tinyxml2\tinyxml2.vcxproj|True",
    "cocos30_unzip|cocos2d-x-3.0-oh\build\external\unzip\unzip.vcxproj|True",
    "cocos30_xxhash|cocos2d-x-3.0-oh\build\external\xxhash\xxhash.vcxproj|True",
    "cocos30_chipmunk|cocos2d-x-3.0-oh\build\external\chipmunk\src\chipmunk_static.vcxproj|True",
    "cocos30_box2d|cocos2d-x-3.0-oh\build\external\Box2D\box2d.vcxproj|True",
    "cocos30_lua|cocos2d-x-3.0-oh\build\external\lua\lua\lua.vcxproj|True",
    "cocos30_tolua|cocos2d-x-3.0-oh\build\external\lua\tolua\tolua.vcxproj|True",
    "cocos30_luasocket|cocos2d-x-3.0-oh\build\external\lua\luasocket\ext_luasocket.vcxproj|True",
    "cocos30_base|cocos2d-x-3.0-oh\build\cocos\base\cocosbase.vcxproj|True",
    "cocos30_core|cocos2d-x-3.0-oh\build\cocos\2d\cocos2d.vcxproj|True",
    "cocos30_audio|cocos2d-x-3.0-oh\build\cocos\audio\audio.vcxproj|True",
    "cocos30_spine|cocos2d-x-3.0-oh\build\cocos\editor-support\spine\spine.vcxproj|True",
    "cocos30_extensions|cocos2d-x-3.0-oh\build\extensions\extensions.vcxproj|True",
    "cocos30_network|cocos2d-x-3.0-oh\build\cocos\network\network.vcxproj|True",
    "cocos30_sqlite3|cocos2d-x-3.0-oh\build\external\sqlite3\sqlite3.vcxproj|True",
    "cocos30_storage|cocos2d-x-3.0-oh\build\cocos\storage\storage.vcxproj|True",
    "cocos30_ui|cocos2d-x-3.0-oh\build\cocos\ui\ui.vcxproj|True",
    "cocos30_cocostudio|cocos2d-x-3.0-oh\build\cocos\editor-support\cocostudio\cocostudio.vcxproj|True",
    "cocos30_cocosbuilder|cocos2d-x-3.0-oh\build\cocos\editor-support\cocosbuilder\cocosbuilder.vcxproj|True",
    "cocos30_luabinding|cocos2d-x-3.0-oh\build\cocos\scripting\lua-bindings\luabinding.vcxproj|True",
    "CEGUI079|tools\CEGUI-0.7.9-r5\cegui-0.7.9.win32.vcxproj|False",
    "engine|engine\engine.win32.vcxproj|False",
    "FireClient|client\MT3Win32App\FireClient.win32.vcxproj|True",
    "MT3|client\MT3Win32App\mt3.win32.vcxproj|True"
)

$expectedLegacy226 = @(
    "platform|common\platform\platform.win32.vcxproj|False",
    "ljfm|common\ljfm\ljfm.win32.vcxproj|False",
    "cauthc|common\cauthc\projects\windows\cauthc.win32.vcxproj|False",
    "libBox2D|cocos2d-x-2.2.6\external\Box2D\proj.win32\Box2D.vcxproj|False",
    "libchipmunk|cocos2d-x-2.2.6\external\chipmunk\proj.win32\chipmunk.vcxproj|False",
    "liblua|cocos2d-x-2.2.6\scripting\lua\proj.win32\liblua.vcxproj|False",
    "cocos2d|cocos2d-x-2.2.6\cocos2dx\proj.win32\cocos2d.vcxproj|False",
    "CocosDenshion|cocos2d-x-2.2.6\CocosDenshion\proj.win32\CocosDenshion.vcxproj|False",
    "libExtensions|cocos2d-x-2.2.6\extensions\proj.win32\libExtensions.vcxproj|False",
    "CEGUI|dependencies\cegui\project\win32\cegui.win32.vcxproj|False",
    "engine|engine\engine.win32.vcxproj|False",
    "FireClient|client\MT3Win32App\FireClient.win32.vcxproj|True",
    "MT3|client\MT3Win32App\mt3.win32.vcxproj|True"
)

Assert-ManifestContract -RepoRoot $repoRoot -Profile "Upgrade30" -ExpectedEntries $expectedUpgrade30
Assert-ManifestContract -RepoRoot $repoRoot -Profile "Legacy226" -ExpectedEntries $expectedLegacy226

Assert-ManifestConsumer -RepoRoot $repoRoot -RelativePath "client\Build-MT3-v120.ps1" -ProfileVariable "EngineProfile" -ExpectedCallCount 1 -IncludeFinalExecutable $false
Assert-ManifestConsumer -RepoRoot $repoRoot -RelativePath "tools\scripts\Check-v120Toolset.ps1" -ProfileVariable "Profile" -ExpectedCallCount 1 -IncludeFinalExecutable $true
Assert-ManifestConsumer -RepoRoot $repoRoot -RelativePath "tools\scripts\Analyze-MT3-Win32Build.ps1" -ProfileVariable "Profile" -ExpectedCallCount 2 -IncludeFinalExecutable $true
Assert-ManifestConsumer -RepoRoot $repoRoot -RelativePath ".agents\skills\windows-v120-build\scripts\verify-build-env.ps1" -ProfileVariable "EngineProfile" -ExpectedCallCount 1 -IncludeFinalExecutable $true

Invoke-AnalyzerProfileTest -RepoRoot $repoRoot -Profile "Upgrade30" -ExpectedProjectCount 28
Invoke-AnalyzerProfileTest -RepoRoot $repoRoot -Profile "Legacy226" -ExpectedProjectCount 13

Write-Host "STATUS: PASS"
Write-Host "SUMMARY: MT3 Win32 manifest and build analysis contract tests passed."

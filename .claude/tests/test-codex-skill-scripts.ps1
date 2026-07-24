[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd("\", "/")
$fixtureRoot = Join-Path $tempRoot ("mt3-codex-skill-scripts-" + [guid]::NewGuid().ToString("N"))
$failures = New-Object System.Collections.Generic.List[string]
$passCount = 0

function New-FixtureDirectory {
    param([string]$RelativePath)

    $path = Join-Path $fixtureRoot $RelativePath
    [void][System.IO.Directory]::CreateDirectory($path)
    return $path
}

function Write-FixtureText {
    param(
        [string]$RelativePath,
        [string]$Text,
        [System.Text.Encoding]$Encoding = $(New-Object System.Text.UTF8Encoding($false))
    )

    $path = Join-Path $fixtureRoot $RelativePath
    [void][System.IO.Directory]::CreateDirectory((Split-Path -Parent $path))
    [System.IO.File]::WriteAllText($path, $Text.Replace("`r`n", "`n"), $Encoding)
    return $path
}

function Get-ShellMatrix {
    $shells = New-Object System.Collections.Generic.List[object]
    $missingShells = New-Object System.Collections.Generic.List[string]
    foreach ($name in @("powershell.exe", "pwsh.exe")) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $command) {
            $source = [string]$command.Source
            if (-not @($shells | Where-Object { $_.Path -eq $source })) {
                [void]$shells.Add([pscustomobject]@{ Name = $name; Path = $source })
            }
        } else {
            [void]$missingShells.Add($name)
        }
    }

    if ($missingShells.Count -gt 0) {
        throw ("Required PowerShell fixture host(s) are unavailable: " + [string]::Join(", ", $missingShells.ToArray()))
    }
    return $shells.ToArray()
}

function Invoke-JsonScript {
    param(
        [string]$ShellPath,
        [string]$ScriptPath,
        [string[]]$Arguments
    )

    $raw = @(& $ShellPath -NoLogo -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    $text = [string]::Join([Environment]::NewLine, @($raw | ForEach-Object { [string]$_ }))
    try {
        $object = $text | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "JSON parse failed (exit=$exitCode): $text"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Object = $object
        Raw = $text
    }
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function New-UString {
    param([int[]]$CodePoints)

    return [string]::Concat(($CodePoints | ForEach-Object { [char]$_ }))
}

function Invoke-FixtureCase {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [string[]]$Arguments,
        [string]$ExpectedStatus,
        [int]$ExpectedExitCode,
        [scriptblock]$Validate = $null
    )

    foreach ($shell in $script:shellMatrix) {
        $caseName = $Name + " [" + $shell.Name + "]"
        try {
            $result = Invoke-JsonScript -ShellPath $shell.Path -ScriptPath $ScriptPath -Arguments $Arguments
            Assert-True -Condition ($result.ExitCode -eq $ExpectedExitCode) -Message ("expected exit {0}, got {1}: {2}" -f $ExpectedExitCode, $result.ExitCode, $result.Raw)
            Assert-True -Condition ([string]$result.Object.status -eq $ExpectedStatus) -Message ("expected status {0}, got {1}" -f $ExpectedStatus, $result.Object.status)
            Assert-True -Condition ($null -ne $result.Object.data) -Message "JSON data must not be null"
            if ($null -ne $Validate) {
                & $Validate $result.Object
            }
            $script:passCount++
            Write-Host ("PASS: " + $caseName)
        } catch {
            [void]$script:failures.Add($caseName + ": " + $_.Exception.Message)
            Write-Host ("FAIL: " + $caseName + ": " + $_.Exception.Message)
        }
    }
}

function Invoke-TextContractCase {
    param(
        [string]$Name,
        [scriptblock]$Validate
    )

    try {
        & $Validate
        $script:passCount++
        Write-Host ("PASS: " + $Name)
    } catch {
        [void]$script:failures.Add($Name + ": " + $_.Exception.Message)
        Write-Host ("FAIL: " + $Name + ": " + $_.Exception.Message)
    }
}

function Invoke-AuditCase {
    param(
        [string]$Name,
        [string]$ProjectRoot,
        [string]$ExpectedStatus,
        [int]$ExpectedExitCode,
        [scriptblock]$Validate = $null
    )

    foreach ($shell in $script:shellMatrix) {
        $caseName = $Name + " [" + $shell.Name + "]"
        try {
            $raw = @(& $shell.Path -NoLogo -NoProfile -ExecutionPolicy Bypass -File $scripts.Audit -ProjectRoot $ProjectRoot 2>&1)
            $exitCode = $LASTEXITCODE
            $reportPath = Join-Path $ProjectRoot ".claude\reports\codex-skills-audit.json"
            Assert-True -Condition ($exitCode -eq $ExpectedExitCode) -Message ("expected exit {0}, got {1}: {2}" -f $ExpectedExitCode, $exitCode, [string]::Join([Environment]::NewLine, @($raw)))
            Assert-True -Condition (Test-Path -LiteralPath $reportPath -PathType Leaf) -Message "audit JSON report is missing"
            $report = Get-Content -Raw -Encoding UTF8 -LiteralPath $reportPath | ConvertFrom-Json -ErrorAction Stop
            Assert-True -Condition ([string]$report.status -eq $ExpectedStatus) -Message ("expected status {0}, got {1}" -f $ExpectedStatus, $report.status)
            if ($null -ne $Validate) {
                & $Validate $report
            }
            $script:passCount++
            Write-Host ("PASS: " + $caseName)
        } catch {
            [void]$script:failures.Add($caseName + ": " + $_.Exception.Message)
            Write-Host ("FAIL: " + $caseName + ": " + $_.Exception.Message)
        }
    }
}

$scripts = @{
    Audit = Join-Path $repoRoot ".claude\scripts\audit_codex_skills.ps1"
    Cegui = Join-Path $repoRoot ".agents\skills\cegui-layout-integration\scripts\validate-cegui-resources.ps1"
    Lua = Join-Path $repoRoot ".agents\skills\lua-dialog-integration\scripts\check-lua-ui-bindings.ps1"
    Generated = Join-Path $repoRoot ".agents\skills\generated-code-guard\scripts\find-generation-source.ps1"
    Sprite = Join-Path $repoRoot ".agents\skills\sprite-pack-algorithm\scripts\verify-pack-output.ps1"
}

$shellMatrix = @(Get-ShellMatrix)

try {
    Invoke-TextContractCase -Name "Windows PowerShell audit entrypoint is ASCII-only" -Validate {
        $auditBytes = [System.IO.File]::ReadAllBytes($scripts.Audit)
        $nonAsciiByteCount = @($auditBytes | Where-Object { $_ -gt 0x7F }).Count
        Assert-True -Condition ($nonAsciiByteCount -eq 0) -Message ("audit_codex_skills.ps1 must stay ASCII-only for locale-independent Windows PowerShell 5.1 parsing; non-ASCII bytes=" + $nonAsciiByteCount)
    }

    $auditRoot = New-FixtureDirectory "audit-root"
    [void](New-FixtureDirectory "audit-root\.agents\skills\sample-skill\agents")
    $auditSkillText = @'
---
name: sample-skill
description: "Use when a fixture needs a narrowly scoped sample skill; not for unrelated work."
---

## __USE_WHEN__

- Use for the fixture.

## __DONT_USE__

- Do not use elsewhere.

## __INPUT_VALIDATION__

- Validate the input.

## __FAILURE_HANDLING__

- Report the first failure.

## __OUTPUT_VERIFICATION__

- Report the result.

## __CONTEXT_BUDGET__

- Load only this file.
'@
    $auditSkillText = $auditSkillText.Replace("__USE_WHEN__", (New-UString @(0x4F55, 0x65F6, 0x4F7F, 0x7528)))
    $auditSkillText = $auditSkillText.Replace("__DONT_USE__", (New-UString @(0x4E0D, 0x4F7F, 0x7528)))
    $auditSkillText = $auditSkillText.Replace("__INPUT_VALIDATION__", (New-UString @(0x8F93, 0x5165, 0x6821, 0x9A8C)))
    $auditSkillText = $auditSkillText.Replace("__FAILURE_HANDLING__", (New-UString @(0x5931, 0x8D25, 0x5904, 0x7406)))
    $auditSkillText = $auditSkillText.Replace("__OUTPUT_VERIFICATION__", (New-UString @(0x8F93, 0x51FA, 0x4E0E, 0x9A8C, 0x8BC1)))
    $auditSkillText = $auditSkillText.Replace("__CONTEXT_BUDGET__", (New-UString @(0x8D44, 0x6E90, 0x4E0E, 0x4E0A, 0x4E0B, 0x6587, 0x9884, 0x7B97)))
    $auditSkillPath = Write-FixtureText "audit-root\.agents\skills\sample-skill\SKILL.md" $auditSkillText
    $auditOpenAiText = @'
interface:
  display_name: "Sample Skill"
  short_description: "Validate a narrow sample skill fixture only."
  default_prompt: "Use $sample-skill to validate this fixture."
policy:
  allow_implicit_invocation: false
'@
    $auditOpenAiPath = Write-FixtureText "audit-root\.agents\skills\sample-skill\agents\openai.yaml" $auditOpenAiText

    Invoke-AuditCase -Name "Official skill metadata without trigger_keywords" -ProjectRoot $auditRoot -ExpectedStatus "PASS" -ExpectedExitCode 0 -Validate {
        param($report)
        Assert-True -Condition ([int]$report.summary.warnings -eq 0) -Message "official name/description metadata must not produce warnings"
        Assert-True -Condition (@($report.skills[0].front_matter.PSObject.Properties.Name) -notcontains "trigger_keywords") -Message "audit report must not expose non-native trigger_keywords"
    }

    $auditSkillWithLegacyTrigger = $auditSkillText.Replace('description: "Use when a fixture needs a narrowly scoped sample skill; not for unrelated work."', "description: `"Use when a fixture needs a narrowly scoped sample skill; not for unrelated work.`"`ntrigger_keywords: [sample]")
    [void](Write-FixtureText "audit-root\.agents\skills\sample-skill\SKILL.md" $auditSkillWithLegacyTrigger)
    Invoke-AuditCase -Name "Reject non-native trigger_keywords" -ProjectRoot $auditRoot -ExpectedStatus "FAIL" -ExpectedExitCode 1 -Validate {
        param($report)
        Assert-True -Condition (@($report.findings.errors | Where-Object { $_ -match "unexpected front matter key.*trigger_keywords" }).Count -eq 1) -Message "unexpected frontmatter key failure is missing"
    }

    [void](Write-FixtureText "audit-root\.agents\skills\sample-skill\SKILL.md" $auditSkillText)
    $auditOpenAiWithVersion = $auditOpenAiText + "`nversion: `"1`"`n"
    [void](Write-FixtureText "audit-root\.agents\skills\sample-skill\agents\openai.yaml" $auditOpenAiWithVersion)
    Invoke-AuditCase -Name "Reject unsupported openai.yaml top-level field" -ProjectRoot $auditRoot -ExpectedStatus "FAIL" -ExpectedExitCode 1 -Validate {
        param($report)
        Assert-True -Condition (@($report.findings.errors | Where-Object { $_ -match "unexpected openai.yaml top-level key.*version" }).Count -eq 1) -Message "unexpected openai.yaml key failure is missing"
    }

    Invoke-TextContractCase -Name "Codex governance is available for promised implicit routing" -Validate {
        $yaml = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot ".agents\skills\codex-runtime-governance\agents\openai.yaml")
        Assert-True -Condition ($yaml -match '(?m)^\s*allow_implicit_invocation:\s*true\s*$') -Message "codex-runtime-governance must be implicitly invocable when the root router promises automatic governance routing"
    }

    Invoke-TextContractCase -Name "Android build and platform bridge descriptions do not overlap" -Validate {
        $android = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot ".agents\skills\android-r10e-build\SKILL.md")
        $platform = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot ".agents\skills\platform-bridge\SKILL.md")
        $compile = [regex]::Escape((New-UString @(0x7F16, 0x8BD1)))
        $dontUse = [regex]::Escape((New-UString @(0x4E0D, 0x7528, 0x4E8E)))
        $register = [regex]::Escape((New-UString @(0x6CE8, 0x518C)))
        $callback = [regex]::Escape((New-UString @(0x56DE, 0x8C03)))
        $runtime = [regex]::Escape((New-UString @(0x8FD0, 0x884C, 0x65F6)))
        $build = [regex]::Escape((New-UString @(0x6784, 0x5EFA)))
        $package = [regex]::Escape((New-UString @(0x6253, 0x5305)))
        Assert-True -Condition ($android -match ("(?m)^description:.*JNI.*" + $compile + ".*" + $dontUse + ".*JNI.*(" + $register + "|" + $callback + "|" + $runtime + ")")) -Message "Android description must own JNI compilation but exclude runtime JNI contracts"
        Assert-True -Condition ($platform -match ("(?m)^description:.*JNI.*(" + $register + "|" + $callback + "|" + $runtime + ").*" + $dontUse + ".*(NDK|Ant).*(" + $compile + "|" + $build + "|" + $package + ")")) -Message "platform description must own runtime JNI contracts but exclude Android build mechanics"
    }

    Invoke-TextContractCase -Name "CEGUI resources and rendering execution descriptions do not overlap" -Validate {
        $cegui = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot ".agents\skills\cegui-layout-integration\SKILL.md")
        $rendering = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot ".agents\skills\rendering-pipeline\SKILL.md")
        $resourceDeclaration = [regex]::Escape((New-UString @(0x8D44, 0x6E90, 0x58F0, 0x660E)))
        $dontUse = [regex]::Escape((New-UString @(0x4E0D, 0x7528, 0x4E8E)))
        $renderer = [regex]::Escape((New-UString @(0x6E32, 0x67D3, 0x5668)))
        $drawOrder = [regex]::Escape((New-UString @(0x7ED8, 0x5236, 0x987A, 0x5E8F)))
        $load = [regex]::Escape((New-UString @(0x52A0, 0x8F7D)))
        $declaration = [regex]::Escape((New-UString @(0x58F0, 0x660E)))
        $parse = [regex]::Escape((New-UString @(0x89E3, 0x6790)))
        Assert-True -Condition ($cegui -match ("(?m)^description:.*(XML|" + $resourceDeclaration + ").*" + $dontUse + ".*(" + $renderer + "|" + $drawOrder + "|DrawCall)")) -Message "CEGUI description must own resource declarations but exclude rendering execution"
        Assert-True -Condition ($rendering -match ("(?m)^description:.*(" + $renderer + "|" + $drawOrder + "|DrawCall).*" + $dontUse + ".*(layout|scheme|looknfeel).*(" + $load + "|" + $declaration + "|" + $parse + ")")) -Message "rendering description must own draw execution but exclude CEGUI resource declarations"
    }

    Invoke-TextContractCase -Name "Sprite guidance requires caller config and real runtime-local anchors" -Validate {
        $skill = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot ".agents\skills\sprite-pack-algorithm\SKILL.md")
        $reference = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot ".agents\skills\sprite-pack-algorithm\references\spriteeditor-pack.md")
        Assert-True -Condition ($skill -notmatch 'tools/engine/SpriteEditor/pack\.ini') -Message "skill must not claim a repository-canonical pack.ini"
        Assert-True -Condition ($skill -notmatch '\[-ConfigPath') -Message "ConfigPath must not be documented as optional"
        Assert-True -Condition ($skill -match '-ConfigPath\s+<pack\.ini>') -Message "required ConfigPath command is missing"
        Assert-True -Condition ($reference -match 'SpritePackCoreService\.\{h,cpp\}') -Message "runtime-local SpritePackCoreService anchors are missing"
        $workspaceLocal = New-UString @(0x5DE5, 0x4F5C, 0x533A, 0x672C, 0x5730)
        $untracked = New-UString @(0x672A, 0x8DDF, 0x8E2A)
        $noCanonicalInRepo = New-UString @(0x4ED3, 0x5E93, 0x5185, 0x4E0D, 0x5B58, 0x5728, 0x89C4, 0x8303)
        Assert-True -Condition ($reference.Contains($workspaceLocal) -and $reference.Contains($untracked)) -Message "runtime-local availability boundary is missing"
        Assert-True -Condition ($reference.Contains($noCanonicalInRepo) -and $reference.Contains("pack.ini")) -Message "caller-supplied pack.ini boundary is missing"
    }

    [void](New-FixtureDirectory "client\resource\res\ui\layouts")
    [void](New-FixtureDirectory "client\resource\res\ui\schemes")
    [void](New-FixtureDirectory "client\resource\res\ui\looknfeel")
    [void](New-FixtureDirectory "client\resource\res\ui\imagesets")
    [void](New-FixtureDirectory "client\resource\res\ui\fonts")
    [void](New-FixtureDirectory "client\resource\res\script")

    Invoke-FixtureCase -Name "CEGUI zero layouts" -ScriptPath $scripts.Cegui -Arguments @("-RepoRoot", $fixtureRoot, "-Json") -ExpectedStatus "FAIL" -ExpectedExitCode 1 -Validate {
        param($json)
        Assert-True -Condition ([int]$json.data.total_layouts -eq 0) -Message "zero-layout fixture must report total_layouts=0"
    }

    $buttonName = [string][char]0x6309 + [string][char]0x94AE
    $scheme = (@'
<?xml version="1.0" encoding="gb2312"?>
<GUIScheme Name="Fixture">
  <FalagardMapping WindowType="TaharezLook/__BUTTON__" TargetType="DefaultWindow" LookNFeel="TaharezLook/Button" Renderer="Falagard/Default" />
</GUIScheme>
'@).Replace("__BUTTON__", $buttonName)
    [void](Write-FixtureText "client\resource\res\ui\schemes\fixture.scheme" $scheme ([System.Text.Encoding]::GetEncoding(54936)))
    $mainLayout = (@'
<?xml version="1.0" encoding="UTF-8"?>
<GUILayout>
  <Window Type="TaharezLook/__BUTTON__" Name="Root" />
</GUILayout>
'@).Replace("__BUTTON__", $buttonName)
    [void](Write-FixtureText "client\resource\res\ui\layouts\main.layout" $mainLayout)

    Invoke-FixtureCase -Name "CEGUI mapping without WidgetLook" -ScriptPath $scripts.Cegui -Arguments @("-RepoRoot", $fixtureRoot, "-LayoutFamily", "main", "-Json") -ExpectedStatus "FAIL" -ExpectedExitCode 1 -Validate {
        param($json)
        Assert-True -Condition ([int]$json.data.total_layouts -eq 1) -Message "single-layout fixture must report total_layouts=1"
        Assert-True -Condition (@($json.data.failures | Where-Object { $_ -match "WidgetLook 'TaharezLook/Button'.*not found" }).Count -eq 1) -Message "missing WidgetLook failure is absent"
    }

    $lookNFeel = @'
<?xml version="1.0" encoding="UTF-8"?>
<Falagard>
  <WidgetLook name="TaharezLook/Button" />
</Falagard>
'@
    [void](Write-FixtureText "client\resource\res\ui\looknfeel\fixture.looknfeel" $lookNFeel)
    Invoke-FixtureCase -Name "CEGUI mapped WidgetLook exists" -ScriptPath $scripts.Cegui -Arguments @("-RepoRoot", $fixtureRoot, "-LayoutFamily", "main", "-Json") -ExpectedStatus "PASS" -ExpectedExitCode 0 -Validate {
        param($json)
        Assert-True -Condition ([int]$json.data.total_layouts -eq 1) -Message "single-layout fixture must report total_layouts=1"
        Assert-True -Condition ([int]$json.data.failed -eq 0) -Message "mapped WidgetLook fixture must not fail"
        Assert-True -Condition ([int]$json.data.widget_look_count -eq 1) -Message "WidgetLook registry must report one entry"
    }

    $crossLayout = @'
<?xml version="1.0" encoding="UTF-8"?>
<GUILayout>
  <Window Type="DefaultWindow" Name="CrossOnly" />
</GUILayout>
'@
    [void](Write-FixtureText "client\resource\res\ui\layouts\cross-one.layout" $crossLayout)
    $crossLua = @'
require "logic.dialog"
CrossDialog = {}
function CrossDialog.GetLayoutFileName()
    return "main.layout"
end
function CrossDialog.Init(self)
    self:GetWindow():getWindow("CrossOnly")
end
function CrossDialog.DestroyDialog() end
function CrossDialog.OnClose() end
'@
    $crossLuaPath = Write-FixtureText "client\resource\res\script\cross.lua" $crossLua

    Invoke-FixtureCase -Name "Lua unique cross-layout match" -ScriptPath $scripts.Lua -Arguments @("-RepoRoot", $fixtureRoot, "-ScriptPath", $crossLuaPath, "-Json") -ExpectedStatus "WARN" -ExpectedExitCode 0 -Validate {
        param($json)
        Assert-True -Condition (@($json.data.warnings | Where-Object { $_ -match "unique cross-layout match" }).Count -eq 1) -Message "unique cross-layout evidence warning is missing"
    }

    [void](Write-FixtureText "client\resource\res\ui\layouts\cross-two.layout" $crossLayout)
    Invoke-FixtureCase -Name "Lua ambiguous cross-layout match" -ScriptPath $scripts.Lua -Arguments @("-RepoRoot", $fixtureRoot, "-ScriptPath", $crossLuaPath, "-Json") -ExpectedStatus "WARN" -ExpectedExitCode 0 -Validate {
        param($json)
        Assert-True -Condition (@($json.data.warnings | Where-Object { $_ -match "multiple cross-layout matches" }).Count -eq 1) -Message "ambiguous cross-layout warning is missing"
    }

    $missingLua = $crossLua.Replace("CrossOnly", "AbsentWindow")
    $missingLuaPath = Write-FixtureText "client\resource\res\script\missing.lua" $missingLua
    Invoke-FixtureCase -Name "Lua window missing everywhere" -ScriptPath $scripts.Lua -Arguments @("-RepoRoot", $fixtureRoot, "-ScriptPath", $missingLuaPath, "-Json") -ExpectedStatus "FAIL" -ExpectedExitCode 1 -Validate {
        param($json)
        Assert-True -Condition (@($json.data.failures | Where-Object { $_ -match "missing from all layouts" }).Count -eq 1) -Message "missing-window failure is absent"
    }

    Invoke-FixtureCase -Name "Sprite config path required" -ScriptPath $scripts.Sprite -Arguments @("-RepoRoot", $fixtureRoot, "-Json") -ExpectedStatus "FAIL" -ExpectedExitCode 1 -Validate {
        param($json)
        Assert-True -Condition ([string]::IsNullOrWhiteSpace([string]$json.data.config)) -Message "empty ConfigPath must not invent a pack.ini path"
    }

    [void](New-FixtureDirectory "sprite-input")
    [void](New-FixtureDirectory "sprite-output")
    $validIni = @'
[sprite-input]
texfmt=1
blend=0
centerx=0
centery=0
dirmode=4
packtime=10
bBindType=0
sysLevel=1
OutputPath=sprite-output
'@
    $validIniPath = Write-FixtureText "fixtures\valid-pack.ini" $validIni
    Invoke-FixtureCase -Name "Sprite empty output is not PASS" -ScriptPath $scripts.Sprite -Arguments @("-RepoRoot", $fixtureRoot, "-ConfigPath", $validIniPath, "-Json") -ExpectedStatus "WARN" -ExpectedExitCode 0 -Validate {
        param($json)
        Assert-True -Condition ([int]$json.data.section_count -eq 1) -Message "valid Sprite fixture must report one section"
        Assert-True -Condition ([int]$json.data.artifact_count -eq 0) -Message "empty output must report artifact_count=0"
        Assert-True -Condition (@($json.data.warnings | Where-Object { $_ -match "no ANI/XAP/atlas artifacts" }).Count -eq 1) -Message "empty output warning is absent"
    }

    [void](Write-FixtureText "sprite-output\atlas.ani" "fixture")
    Invoke-FixtureCase -Name "Sprite output artifact is counted" -ScriptPath $scripts.Sprite -Arguments @("-RepoRoot", $fixtureRoot, "-ConfigPath", $validIniPath, "-Json") -ExpectedStatus "PASS" -ExpectedExitCode 0 -Validate {
        param($json)
        Assert-True -Condition ([int]$json.data.artifact_count -eq 1) -Message "existing ANI artifact must be counted"
    }

    $invalidIni = $validIni.Replace("dirmode=4", "dirmode=99")
    $invalidIniPath = Write-FixtureText "fixtures\invalid-pack.ini" $invalidIni
    Invoke-FixtureCase -Name "Sprite invalid config" -ScriptPath $scripts.Sprite -Arguments @("-RepoRoot", $fixtureRoot, "-ConfigPath", $invalidIniPath, "-Json") -ExpectedStatus "FAIL" -ExpectedExitCode 1 -Validate {
        param($json)
        Assert-True -Condition (@($json.data.failures | Where-Object { $_ -match "dirmode out of supported range" }).Count -eq 1) -Message "invalid dirmode failure is absent"
    }

    $generatedPath = Write-FixtureText "server\module\src\xbean\NoEvidence.java" "public final class NoEvidence {}"
    Invoke-FixtureCase -Name "Generated boundary without source evidence" -ScriptPath $scripts.Generated -Arguments @("-RepoRoot", $fixtureRoot, "-Path", $generatedPath, "-Json") -ExpectedStatus "WARN" -ExpectedExitCode 0 -Validate {
        param($json)
        Assert-True -Condition (-not [bool]$json.data.source_evidence_found) -Message "fixture must report source_evidence_found=false"
        Assert-True -Condition (@($json.data.source_hints).Count -eq 0) -Message "fixture must not fabricate source hints"
    }
} finally {
    $resolvedFixture = [System.IO.Path]::GetFullPath($fixtureRoot)
    $fixtureName = [System.IO.Path]::GetFileName($resolvedFixture)
    if ($resolvedFixture.StartsWith($tempRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase) -and
        $fixtureName.StartsWith("mt3-codex-skill-scripts-", [System.StringComparison]::Ordinal) -and
        (Test-Path -LiteralPath $resolvedFixture)) {
        Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Host ("ERROR: " + $failure)
    }
    throw ("Codex skill script fixture failures: " + $failures.Count)
}

Write-Host ("PASS: Codex skill script fixtures completed across " + $shellMatrix.Count + " shell(s); assertions=" + $passCount)

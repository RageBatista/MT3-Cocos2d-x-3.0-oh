[CmdletBinding()]
param(
    [string]$ProjectRoot = "",
    [string]$OfficialValidatorPath = "",
    [switch]$RequireOfficialValidator,
    [switch]$SkipIntegration
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
    } else {
        $ProjectRoot = (Get-Location).Path
    }
}

$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$skillsRoot = Join-Path $ProjectRoot ".agents\skills"
$reportRoot = Join-Path $ProjectRoot ".claude\reports"

if (-not (Test-Path $skillsRoot -PathType Container)) {
    throw "Missing skills root: $skillsRoot"
}

function Write-Utf8NoBom {
    param(
        [string]$FilePath,
        [string]$Text
    )

    $dir = Split-Path -Parent $FilePath
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }
    [System.IO.File]::WriteAllText($FilePath, $Text, $utf8NoBom)
}

function New-UString {
    param([int[]]$CodePoints)
    return [string]::Concat(($CodePoints | ForEach-Object { [char]$_ }))
}

function Get-RelativeProjectPath {
    param([string]$AbsolutePath)
    $rootWithSlash = $ProjectRoot.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
    $rootUri = New-Object System.Uri($rootWithSlash)
    $pathUri = New-Object System.Uri($AbsolutePath)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace("\", "/")
}

function Get-FrontMatter {
    param([string]$Text)
    $match = [regex]::Match($Text, '(?s)^---\r?\n(.*?)\r?\n---\r?\n')
    if (-not $match.Success) {
        return $null
    }
    return [ordered]@{
        raw = $match.Groups[1].Value
        body = $Text.Substring($match.Length)
    }
}

function Get-FrontMatterValue {
    param(
        [string]$FrontMatterRaw,
        [string]$Key
    )

    $pattern = '(?m)^\s*' + [regex]::Escape($Key) + ':\s*(.+?)\s*$'
    $match = [regex]::Match($FrontMatterRaw, $pattern)
    if (-not $match.Success) {
        return ""
    }

    $value = $match.Groups[1].Value.Trim()
    if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
        $value = $value.Substring(1, $value.Length - 2)
    }
    return $value.Trim()
}

function Get-YamlTopLevelKeys {
    param([string]$Text)

    $keys = New-Object System.Collections.Generic.List[string]
    foreach ($match in [regex]::Matches($Text, '(?m)^([A-Za-z0-9_-]+):(?:\s|$)')) {
        $key = [string]$match.Groups[1].Value
        if (-not $keys.Contains($key)) {
            [void]$keys.Add($key)
        }
    }
    return $keys.ToArray()
}

function Get-YamlScalarValue {
    param(
        [string]$Text,
        [string]$Key
    )

    $pattern = '(?m)^\s*' + [regex]::Escape($Key) + ':\s*(.+?)\s*$'
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return ""
    }

    $value = $match.Groups[1].Value.Trim()
    if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
        $value = $value.Substring(1, $value.Length - 2)
    }
    return $value.Trim()
}

function Test-AnyHeading {
    param(
        [string]$Text,
        [string[]]$Headings
    )

    foreach ($heading in $Headings) {
        $pattern = '(?m)^##\s+' + [regex]::Escape($heading) + '\s*$'
        if ([regex]::IsMatch($Text, $pattern)) {
            return $true
        }
    }
    return $false
}

function Test-ScriptLibrary {
    param([string]$Path)

    $fileName = [System.IO.Path]::GetFileName($Path)
    return $fileName -match '(?i)-helpers\.ps1$'
}

function Test-ScriptContract {
    param([string]$Text)

    $usesSharedHelper = [regex]::IsMatch($Text, '(?i)skill-script-helpers\.ps1')
    $callsWriteResult = [regex]::IsMatch($Text, '(?m)\bWrite-Result\b')
    $checks = [ordered]@{
        cmdlet_binding = [regex]::IsMatch($Text, '(?m)^\[CmdletBinding\(\)\]')
        strict_mode = [regex]::IsMatch($Text, '(?m)^\s*Set-StrictMode\s+-Version\s+Latest\s*$')
        error_action_stop = [regex]::IsMatch($Text, '(?m)^\s*\$ErrorActionPreference\s*=\s*"Stop"\s*$')
        shared_helper_import = $usesSharedHelper
        write_result_function = [regex]::IsMatch($Text, '(?m)^\s*function\s+Write-Result\b') -or ($usesSharedHelper -and $callsWriteResult)
        status_output = $Text.Contains("STATUS: ") -or ($usesSharedHelper -and $callsWriteResult)
        summary_output = $Text.Contains("SUMMARY: ") -or ($usesSharedHelper -and $callsWriteResult)
        detail_output = $Text.Contains("DETAIL: ") -or ($usesSharedHelper -and $callsWriteResult)
        next_output = $Text.Contains("NEXT: ") -or ($usesSharedHelper -and $callsWriteResult)
        json_switch = [regex]::IsMatch($Text, '(?m)^\s*\[switch\]\$Json\s*$')
        json_output = $Text.Contains("ConvertTo-Json") -or ($usesSharedHelper -and $callsWriteResult)
    }
    $requiredCheckKeys = @(
        "cmdlet_binding",
        "strict_mode",
        "error_action_stop",
        "write_result_function",
        "status_output",
        "summary_output",
        "detail_output",
        "next_output"
    )

    $missing = New-Object System.Collections.Generic.List[string]
    foreach ($key in $requiredCheckKeys) {
        if (-not [bool]$checks[$key]) {
            [void]$missing.Add($key)
        }
    }

    return [pscustomobject]@{
        pass = ($missing.Count -eq 0)
        checks = [pscustomobject]$checks
        missing = @($missing)
    }
}

function Test-LfsPointer {
    param([string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -eq 0) {
        return $false
    }
    $length = [Math]::Min($bytes.Length, 200)
    $prefix = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $length).TrimStart([char]0xFEFF)
    return $prefix.StartsWith("version https://git-lfs.github.com/spec/v1", [System.StringComparison]::Ordinal)
}

function Resolve-OfficialValidator {
    param([string]$RequestedPath)

    $candidates = New-Object System.Collections.Generic.List[string]
    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        [void]$candidates.Add($RequestedPath)
    } elseif (-not [string]::IsNullOrWhiteSpace($env:MT3_OFFICIAL_SKILL_VALIDATOR)) {
        [void]$candidates.Add($env:MT3_OFFICIAL_SKILL_VALIDATOR)
    } else {
        if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
            [void]$candidates.Add((Join-Path $env:CODEX_HOME "skills\.system\skill-creator\scripts\quick_validate.py"))
        }
        if (-not [string]::IsNullOrWhiteSpace($HOME)) {
            [void]$candidates.Add((Join-Path $HOME ".codex\skills\.system\skill-creator\scripts\quick_validate.py"))
        }
    }

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        $resolved = if ([System.IO.Path]::IsPathRooted($candidate)) {
            [System.IO.Path]::GetFullPath($candidate)
        } else {
            [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $candidate))
        }
        if (Test-Path -LiteralPath $resolved -PathType Leaf) {
            return $resolved
        }
    }
    return ""
}

function Invoke-OfficialSkillValidator {
    param(
        [string]$ValidatorPath,
        [string]$SkillPath
    )

    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($null -eq $python) {
        return [pscustomobject][ordered]@{
            status = "FAIL"
            exit_code = -1
            output = "Python 3 is required to execute quick_validate.py."
        }
    }

    $oldErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $raw = @(& $python.Source -X utf8 $ValidatorPath $SkillPath 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }
    return [pscustomobject][ordered]@{
        status = if ($exitCode -eq 0) { "PASS" } else { "FAIL" }
        exit_code = $exitCode
        output = [string]::Join("`n", @($raw | ForEach-Object { [string]$_ })).Trim()
    }
}

$headingUseWhen = New-UString @(0x4F55, 0x65F6, 0x4F7F, 0x7528)
$headingUsage = New-UString @(0x4F7F, 0x7528, 0x65B9, 0x5F0F)
$headingExecutionOrder = New-UString @(0x6267, 0x884C, 0x987A, 0x5E8F)
$headingDontUse = New-UString @(0x4E0D, 0x4F7F, 0x7528)
$headingInputValidation = New-UString @(0x8F93, 0x5165, 0x6821, 0x9A8C)
$headingFailureHandling = New-UString @(0x5931, 0x8D25, 0x5904, 0x7406)
$headingOutputVerification = New-UString @(0x8F93, 0x51FA, 0x4E0E, 0x9A8C, 0x8BC1)
$headingContextBudget = New-UString @(0x8D44, 0x6E90, 0x4E0E, 0x4E0A, 0x4E0B, 0x6587, 0x9884, 0x7B97)
$negativeBoundaryUse = New-UString @(0x4E0D, 0x7528, 0x4E8E)
$negativeBoundaryOwn = New-UString @(0x4E0D, 0x8D1F, 0x8D23)

$sectionDefinitions = [ordered]@{
    use_when = @($headingUseWhen, $headingUsage, $headingExecutionOrder)
    dont_use = @($headingDontUse)
    input_validation = @($headingInputValidation)
    failure_handling = @($headingFailureHandling)
    output_verification = @($headingOutputVerification)
    context_budget = @($headingContextBudget)
}
$requiredScriptsBySkill = @{
    "application-core-flow" = @("scripts/probe-core-flow-entry.ps1")
    "cegui-layout-integration" = @("scripts/check-cegui-bindings.ps1")
    "lua-dialog-integration" = @("scripts/check-lua-ui-bindings.ps1")
    "platform-bridge" = @("scripts/probe-platform-handoff.ps1")
    "resource-packaging-pipeline" = @("scripts/verify-patch-layout.ps1")
    "rendering-pipeline" = @("scripts/probe-render-stack.ps1")
    "sprite-pack-algorithm" = @("scripts/verify-pack-output.ps1")
    "windows-v120-build" = @("scripts/verify-build-env.ps1")
    "android-r10e-build" = @("scripts/verify-android-r10e-env.ps1")
    "server-ant-build" = @("scripts/verify-server-ant-chain.ps1")
    "encoding-bom-guard" = @("scripts/detect-file-encoding.ps1")
    "generated-code-guard" = @("scripts/find-generation-source.ps1")
}

$skillDirs = @(Get-ChildItem -Path $skillsRoot -Directory | Sort-Object Name)
$skillResults = New-Object System.Collections.Generic.List[object]
$allErrors = New-Object System.Collections.Generic.List[string]
$allWarnings = New-Object System.Collections.Generic.List[string]

$implicitEnabledCount = 0
$implicitDisabledCount = 0
$missingPolicyCount = 0
$skillsWithRefsCount = 0
$skillsWithScriptsCount = 0
$skillsWithAssetsCount = 0
$routingBoundaryWarningCount = 0
$longSkillWarningCount = 0
$assetReferenceWarningCount = 0
$scriptFilesTotal = 0
$scriptLibraryFilesTotal = 0
$scriptContractPassCount = 0
$scriptContractFailCount = 0
$scriptCmdletBindingMissingCount = 0
$scriptStrictModeMissingCount = 0
$scriptErrorActionMissingCount = 0
$scriptWriteResultMissingCount = 0
$scriptOutputFieldMissingCount = 0
$scriptJsonCapableCount = 0
$scriptJsonPartialCount = 0
$scriptSharedHelperCount = 0
$scriptSharedHelperMissingCount = 0
$linksCheckedTotal = 0
$brokenLinksTotal = 0
$lfsFilesCheckedTotal = 0
$lfsPointerFailuresTotal = 0
$officialValidatorPassCount = 0
$officialValidatorFailCount = 0
$officialValidatorResults = New-Object System.Collections.Generic.List[object]
$officialValidatorResolved = Resolve-OfficialValidator -RequestedPath $OfficialValidatorPath
if (-not [string]::IsNullOrWhiteSpace($OfficialValidatorPath) -and [string]::IsNullOrWhiteSpace($officialValidatorResolved)) {
    [void]$allErrors.Add("official validator path does not exist: $OfficialValidatorPath")
}
if ($RequireOfficialValidator -and [string]::IsNullOrWhiteSpace($officialValidatorResolved)) {
    [void]$allErrors.Add("official quick_validate.py is required but unavailable")
}
$missingSectionCounts = [ordered]@{
    use_when = 0
    dont_use = 0
    input_validation = 0
    failure_handling = 0
    output_verification = 0
    context_budget = 0
}

foreach ($skillDir in $skillDirs) {
    $skillName = $skillDir.Name
    $skillPath = $skillDir.FullName
    $skillDocPath = Join-Path $skillPath "SKILL.md"
    $skillMetaPath = Join-Path $skillPath "agents\openai.yaml"
    $referencesPath = Join-Path $skillPath "references"
    $scriptsPath = Join-Path $skillPath "scripts"
    $assetsPath = Join-Path $skillPath "assets"

    $errors = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $skillText = ""
    $skillBody = ""
    $frontMatterRaw = ""
    $frontMatterName = ""
    $frontMatterDescription = ""
    $yamlText = ""
    $displayName = ""
    $shortDescription = ""
    $defaultPrompt = ""
    $allowImplicitText = ""
    $allowImplicit = $null
    $dependencyCount = 0
    $skillLinksChecked = 0
    $skillBrokenLinks = 0
    $skillLfsFilesChecked = 0
    $skillLfsPointerFailures = 0
    $officialValidation = $null

    $referenceCount = if (Test-Path $referencesPath -PathType Container) { @(Get-ChildItem -Path $referencesPath -Recurse -File).Count } else { 0 }
    $scriptCount = if (Test-Path $scriptsPath -PathType Container) { @(Get-ChildItem -Path $scriptsPath -Recurse -File).Count } else { 0 }
    $assetCount = if (Test-Path $assetsPath -PathType Container) { @(Get-ChildItem -Path $assetsPath -Recurse -File).Count } else { 0 }
    if ($referenceCount -gt 0) { $skillsWithRefsCount++ }
    if ($scriptCount -gt 0) { $skillsWithScriptsCount++ }
    if ($assetCount -gt 0) { $skillsWithAssetsCount++ }
    $scriptContractResults = New-Object System.Collections.Generic.List[object]

    if (-not (Test-Path $skillDocPath -PathType Leaf)) {
        [void]$errors.Add("missing SKILL.md")
    } else {
        $skillText = Get-Content -Raw -Encoding UTF8 $skillDocPath
        $frontMatter = Get-FrontMatter -Text $skillText
        if ($null -eq $frontMatter) {
            [void]$errors.Add("missing front matter")
            $skillBody = $skillText
        } else {
            $frontMatterRaw = [string]$frontMatter.raw
            $skillBody = [string]$frontMatter.body
            $frontMatterName = Get-FrontMatterValue -FrontMatterRaw $frontMatterRaw -Key "name"
            $frontMatterDescription = Get-FrontMatterValue -FrontMatterRaw $frontMatterRaw -Key "description"

            $allowedFrontMatterKeys = @("name", "description")
            foreach ($frontMatterKey in @(Get-YamlTopLevelKeys -Text $frontMatterRaw)) {
                if ($allowedFrontMatterKeys -notcontains $frontMatterKey) {
                    [void]$errors.Add("unexpected front matter key: " + $frontMatterKey)
                }
            }

            if ([string]::IsNullOrWhiteSpace($frontMatterName)) {
                [void]$errors.Add("missing front matter name")
            } elseif ($frontMatterName -ne $skillName) {
                [void]$errors.Add("front matter name drift: expected $skillName got $frontMatterName")
            } elseif ($frontMatterName.Length -gt 64) {
                [void]$errors.Add("front matter name exceeds 64 characters")
            } elseif ($frontMatterName -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
                [void]$errors.Add("front matter name must use lowercase hyphen-case")
            }

            if ([string]::IsNullOrWhiteSpace($frontMatterDescription)) {
                [void]$errors.Add("missing front matter description")
            } elseif ($frontMatterDescription.Length -gt 1024) {
                [void]$errors.Add("front matter description exceeds 1024 characters")
            } elseif ($frontMatterDescription.Contains("<") -or $frontMatterDescription.Contains(">")) {
                [void]$errors.Add("front matter description contains angle brackets")
            }
            if ($frontMatterRaw -match '(?m)^\s*description:\s*.*\u89E6\u53D1\u8BCD:') {
                [void]$errors.Add("front matter description still embeds trigger keywords")
            }
        }
    }

    if (-not (Test-Path $skillMetaPath -PathType Leaf)) {
        [void]$errors.Add("missing agents/openai.yaml")
    } else {
        $yamlText = Get-Content -Raw -Encoding UTF8 $skillMetaPath
        $allowedOpenAiTopLevelKeys = @("interface", "dependencies", "policy")
        foreach ($openAiTopLevelKey in @(Get-YamlTopLevelKeys -Text $yamlText)) {
            if ($allowedOpenAiTopLevelKeys -notcontains $openAiTopLevelKey) {
                [void]$errors.Add("unexpected openai.yaml top-level key: " + $openAiTopLevelKey)
            }
        }
        $openAiTopLevelKeys = @(Get-YamlTopLevelKeys -Text $yamlText)
        if ($openAiTopLevelKeys -notcontains "interface") {
            [void]$errors.Add("missing openai.yaml interface section")
        }
        if ($openAiTopLevelKeys -notcontains "policy") {
            [void]$errors.Add("missing openai.yaml policy section")
        }

        $displayName = Get-YamlScalarValue -Text $yamlText -Key "display_name"
        $shortDescription = Get-YamlScalarValue -Text $yamlText -Key "short_description"
        $defaultPrompt = Get-YamlScalarValue -Text $yamlText -Key "default_prompt"
        $allowImplicitText = Get-YamlScalarValue -Text $yamlText -Key "allow_implicit_invocation"

        if ([string]::IsNullOrWhiteSpace($displayName)) {
            [void]$errors.Add("missing interface.display_name")
        }
        if ([string]::IsNullOrWhiteSpace($shortDescription)) {
            [void]$errors.Add("missing interface.short_description")
        } elseif ($shortDescription.Length -lt 25 -or $shortDescription.Length -gt 64) {
            [void]$errors.Add("interface.short_description must contain 25..64 characters")
        }
        if ([string]::IsNullOrWhiteSpace($defaultPrompt)) {
            [void]$errors.Add("missing interface.default_prompt")
        } elseif ($defaultPrompt -notmatch ('\$' + [regex]::Escape($skillName) + '(?![\w-])')) {
            [void]$errors.Add("default_prompt missing `$" + $skillName)
        }

        if ([string]::IsNullOrWhiteSpace($allowImplicitText)) {
            $missingPolicyCount++
            [void]$errors.Add("missing explicit policy.allow_implicit_invocation")
        } else {
            $lower = $allowImplicitText.ToLowerInvariant()
            if ($lower -eq "true") {
                $allowImplicit = $true
                $implicitEnabledCount++
            } elseif ($lower -eq "false") {
                $allowImplicit = $false
                $implicitDisabledCount++
            } else {
                [void]$errors.Add("invalid allow_implicit_invocation value: $allowImplicitText")
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($yamlText)) {
            $dependencyCount = ([regex]'(?m)^\s*-\s+type:\s*').Matches([string]$yamlText).Count
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($officialValidatorResolved)) {
        $officialValidation = Invoke-OfficialSkillValidator -ValidatorPath $officialValidatorResolved -SkillPath $skillPath
        [void]$officialValidatorResults.Add([pscustomobject][ordered]@{
            skill = $skillName
            status = [string]$officialValidation.status
            exit_code = [int]$officialValidation.exit_code
            output = [string]$officialValidation.output
        })
        if ([string]$officialValidation.status -eq "PASS") {
            $officialValidatorPassCount++
        } else {
            $officialValidatorFailCount++
            [void]$errors.Add("official quick_validate.py failed: $([string]$officialValidation.output)")
        }
    }

    foreach ($skillFile in @(Get-ChildItem -LiteralPath $skillPath -Recurse -File | Sort-Object FullName)) {
        $skillLfsFilesChecked++
        $lfsFilesCheckedTotal++
        if (Test-LfsPointer -Path $skillFile.FullName) {
            $skillLfsPointerFailures++
            $lfsPointerFailuresTotal++
            [void]$errors.Add("Git LFS pointer is not hydrated: " + (Get-RelativeProjectPath -AbsolutePath $skillFile.FullName))
        }
    }

    foreach ($markdownFile in @(Get-ChildItem -LiteralPath $skillPath -Recurse -File -Filter *.md | Sort-Object FullName)) {
        $markdownText = Get-Content -Raw -Encoding UTF8 -LiteralPath $markdownFile.FullName
        foreach ($linkMatch in [regex]::Matches($markdownText, '(?m)(?<!\!)\[[^\]]*\]\((?<target>[^)]+)\)')) {
            $target = [string]$linkMatch.Groups["target"].Value.Trim()
            if ($target.StartsWith("<") -and $target.Contains(">")) {
                $target = $target.Substring(1, $target.IndexOf(">") - 1)
            } elseif ($target -match '^(?<path>\S+)(?:\s+["''][^"'']*["''])?$') {
                $target = [string]$Matches["path"]
            }
            if ([string]::IsNullOrWhiteSpace($target) -or $target.StartsWith("#") -or $target -match '^[A-Za-z][A-Za-z0-9+.-]*:') {
                continue
            }

            $skillLinksChecked++
            $linksCheckedTotal++
            $pathPart = ($target -split '[?#]', 2)[0]
            try {
                $pathPart = [System.Uri]::UnescapeDataString($pathPart)
                $resolvedLink = [System.IO.Path]::GetFullPath((Join-Path $markdownFile.DirectoryName $pathPart))
                $rootPrefix = $ProjectRoot.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
                if (-not $resolvedLink.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $resolvedLink)) {
                    $skillBrokenLinks++
                    $brokenLinksTotal++
                    [void]$errors.Add("broken local Markdown link: " + (Get-RelativeProjectPath -AbsolutePath $markdownFile.FullName) + " -> " + $target)
                }
            } catch {
                $skillBrokenLinks++
                $brokenLinksTotal++
                [void]$errors.Add("invalid local Markdown link: " + (Get-RelativeProjectPath -AbsolutePath $markdownFile.FullName) + " -> " + $target)
            }
        }
    }

    if ($requiredScriptsBySkill.ContainsKey($skillName)) {
        foreach ($requiredScript in @($requiredScriptsBySkill[$skillName])) {
            $requiredScriptPath = Join-Path $skillPath $requiredScript
            if (-not (Test-Path $requiredScriptPath -PathType Leaf)) {
                [void]$errors.Add("missing required script: " + $requiredScript)
            }
        }
    }

    $sections = [ordered]@{}
    foreach ($sectionKey in $sectionDefinitions.Keys) {
        $present = $false
        if (-not [string]::IsNullOrWhiteSpace($skillBody)) {
            $present = Test-AnyHeading -Text $skillBody -Headings @($sectionDefinitions[$sectionKey])
        }
        $sections[$sectionKey] = $present
        if (-not $present) {
            $missingSectionCounts[$sectionKey]++
        }
    }

    if (-not [bool]$sections.use_when) {
        [void]$warnings.Add("missing use-when section")
    }
    if (-not [bool]$sections.dont_use) {
        [void]$warnings.Add("missing dont-use section")
    }
    if (-not [bool]$sections.input_validation) {
        [void]$warnings.Add("missing input-validation section")
    }
    if (-not [bool]$sections.failure_handling) {
        [void]$warnings.Add("missing failure-handling section")
    }
    if (-not [bool]$sections.output_verification) {
        [void]$warnings.Add("missing output-verification section")
    }
    if (-not [bool]$sections.context_budget) {
        [void]$warnings.Add("missing context-budget section")
    }

    if ($referenceCount -gt 0 -and -not [string]::IsNullOrWhiteSpace($skillBody) -and $skillBody -notmatch 'references/') {
        [void]$warnings.Add("references exist but SKILL.md does not point to references/")
    }
    if ($assetCount -gt 0 -and -not [string]::IsNullOrWhiteSpace($skillBody) -and $skillBody -notmatch 'assets/') {
        $assetReferenceWarningCount++
        [void]$warnings.Add("assets exist but SKILL.md does not point to assets/")
    }

    if (Test-Path $scriptsPath -PathType Container) {
        foreach ($scriptFile in @(Get-ChildItem -Path $scriptsPath -Recurse -File -Filter *.ps1 | Sort-Object FullName)) {
            $scriptRelativePath = Get-RelativeProjectPath -AbsolutePath $scriptFile.FullName
            $isLibraryScript = Test-ScriptLibrary -Path $scriptFile.FullName
            if ($isLibraryScript) {
                $scriptLibraryFilesTotal++
                [void]$scriptContractResults.Add([pscustomobject][ordered]@{
                    path = $scriptRelativePath
                    pass = $true
                    library = $true
                    shared_helper = $false
                    json_capable = $false
                    missing = @()
                    checks = [pscustomobject]@{
                        library = $true
                    }
                })
                continue
            }

            $scriptFilesTotal++
            $scriptText = Get-Content -Raw -Encoding UTF8 $scriptFile.FullName
            $contract = Test-ScriptContract -Text $scriptText
            $missingChecks = @($contract.missing)
            $usesSharedHelper = [bool]$contract.checks.shared_helper_import

            if ($usesSharedHelper) {
                $scriptSharedHelperCount++
            } else {
                $scriptSharedHelperMissingCount++
                [void]$warnings.Add("script does not import shared helper: " + $scriptRelativePath)
            }

            if ([bool]$contract.pass) {
                $scriptContractPassCount++
            } else {
                $scriptContractFailCount++
                [void]$errors.Add("script output contract drift: " + $scriptRelativePath + " missing " + [string]::Join(", ", $missingChecks))
            }

            if (-not [bool]$contract.checks.cmdlet_binding) {
                $scriptCmdletBindingMissingCount++
            }
            if (-not [bool]$contract.checks.strict_mode) {
                $scriptStrictModeMissingCount++
            }
            if (-not [bool]$contract.checks.error_action_stop) {
                $scriptErrorActionMissingCount++
            }
            if (-not [bool]$contract.checks.write_result_function) {
                $scriptWriteResultMissingCount++
            }
            if (
                (-not [bool]$contract.checks.status_output) -or
                (-not [bool]$contract.checks.summary_output) -or
                (-not [bool]$contract.checks.detail_output) -or
                (-not [bool]$contract.checks.next_output)
            ) {
                $scriptOutputFieldMissingCount++
            }
            $hasJsonSwitch = [bool]$contract.checks.json_switch
            $hasJsonOutput = [bool]$contract.checks.json_output
            if ($hasJsonSwitch -and $hasJsonOutput) {
                $scriptJsonCapableCount++
            } elseif ($hasJsonSwitch -or $hasJsonOutput) {
                $scriptJsonPartialCount++
                [void]$warnings.Add("script JSON contract is partial: " + $scriptRelativePath)
            }

            [void]$scriptContractResults.Add([pscustomobject][ordered]@{
                path = $scriptRelativePath
                pass = [bool]$contract.pass
                library = $false
                shared_helper = $usesSharedHelper
                json_capable = ($hasJsonSwitch -and $hasJsonOutput)
                missing = $missingChecks
                checks = $contract.checks
            })
        }
    }

    $skillCharCount = if ([string]::IsNullOrWhiteSpace($skillText)) { 0 } else { $skillText.Length }
    $headingCount = if ([string]::IsNullOrWhiteSpace($skillBody)) { 0 } else { [regex]::Matches($skillBody, '(?m)^##\s+').Count }

    if ($skillCharCount -gt 4000 -and $referenceCount -eq 0 -and $scriptCount -eq 0) {
        $longSkillWarningCount++
        [void]$warnings.Add("long skill without references/scripts")
    }

    if ($allowImplicit -eq $true) {
        $hasBoundary = $false
        if (-not [string]::IsNullOrWhiteSpace($frontMatterDescription)) {
            if ($frontMatterDescription.Contains($negativeBoundaryUse) -or $frontMatterDescription.Contains($negativeBoundaryOwn)) {
                $hasBoundary = $true
            }
        }
        if (-not $hasBoundary) {
            $routingBoundaryWarningCount++
            [void]$warnings.Add("implicit skill description lacks negative routing boundary")
        }
    }

    $allowImplicitValue = $null
    if ($null -ne $allowImplicit) {
        $allowImplicitValue = [bool]$allowImplicit
    }

    $status = "PASS"
    if ($errors.Count -gt 0) {
        $status = "FAIL"
    } elseif ($warnings.Count -gt 0) {
        $status = "WARN"
    }

    foreach ($item in $errors) {
        [void]$allErrors.Add($skillName + ": " + $item)
    }
    foreach ($item in $warnings) {
        [void]$allWarnings.Add($skillName + ": " + $item)
    }

    $skillRelativePath = Get-RelativeProjectPath -AbsolutePath $skillPath
    $skillDocRelativePath = Get-RelativeProjectPath -AbsolutePath $skillDocPath
    $skillMetaRelativePath = Get-RelativeProjectPath -AbsolutePath $skillMetaPath
    $scriptContractArray = $scriptContractResults.ToArray()
    $errorArray = $errors.ToArray()
    $warningArray = $warnings.ToArray()
    $frontMatterObject = [ordered]@{
        name = $frontMatterName
        description = $frontMatterDescription
    }
    $metadataFieldsObject = [ordered]@{
        display_name = $displayName
        short_description = $shortDescription
        default_prompt = $defaultPrompt
        allow_implicit_invocation = $allowImplicitValue
        dependency_count = $dependencyCount
    }

    $skillRecord = New-Object PSObject
    $skillRecord | Add-Member -NotePropertyName "skill" -NotePropertyValue $skillName
    $skillRecord | Add-Member -NotePropertyName "status" -NotePropertyValue $status
    $skillRecord | Add-Member -NotePropertyName "path" -NotePropertyValue $skillRelativePath
    $skillRecord | Add-Member -NotePropertyName "skill_doc" -NotePropertyValue $skillDocRelativePath
    $skillRecord | Add-Member -NotePropertyName "metadata" -NotePropertyValue $skillMetaRelativePath
    $skillRecord | Add-Member -NotePropertyName "skill_chars" -NotePropertyValue $skillCharCount
    $skillRecord | Add-Member -NotePropertyName "heading_count" -NotePropertyValue $headingCount
    $skillRecord | Add-Member -NotePropertyName "reference_count" -NotePropertyValue $referenceCount
    $skillRecord | Add-Member -NotePropertyName "script_count" -NotePropertyValue $scriptCount
    $skillRecord | Add-Member -NotePropertyName "asset_count" -NotePropertyValue $assetCount
    $skillRecord | Add-Member -NotePropertyName "links_checked" -NotePropertyValue $skillLinksChecked
    $skillRecord | Add-Member -NotePropertyName "broken_links" -NotePropertyValue $skillBrokenLinks
    $skillRecord | Add-Member -NotePropertyName "lfs_files_checked" -NotePropertyValue $skillLfsFilesChecked
    $skillRecord | Add-Member -NotePropertyName "lfs_pointer_failures" -NotePropertyValue $skillLfsPointerFailures
    $skillRecord | Add-Member -NotePropertyName "official_validation" -NotePropertyValue $officialValidation
    $skillRecord | Add-Member -NotePropertyName "front_matter" -NotePropertyValue $frontMatterObject
    $skillRecord | Add-Member -NotePropertyName "metadata_fields" -NotePropertyValue $metadataFieldsObject
    $skillRecord | Add-Member -NotePropertyName "sections" -NotePropertyValue $sections
    $skillRecord | Add-Member -NotePropertyName "script_contract" -NotePropertyValue $scriptContractArray
    $skillRecord | Add-Member -NotePropertyName "errors" -NotePropertyValue $errorArray
    $skillRecord | Add-Member -NotePropertyName "warnings" -NotePropertyValue $warningArray
    [void]$skillResults.Add($skillRecord)
}

$integration = [pscustomobject][ordered]@{
    status = "SKIPPED"
    skipped = $true
    reason = "-SkipIntegration was specified"
    exit_code = 0
    output = ""
}
if (-not $SkipIntegration) {
    $fixtureTestPath = Join-Path $ProjectRoot ".claude\tests\test-codex-skill-scripts.ps1"
    if (-not (Test-Path -LiteralPath $fixtureTestPath -PathType Leaf)) {
        $integration = [pscustomobject][ordered]@{
            status = "SKIPPED"
            skipped = $true
            reason = "fixture test is not present under the audited ProjectRoot"
            exit_code = 0
            output = ""
        }
    } else {
        $hostCommand = Get-Command powershell.exe -ErrorAction SilentlyContinue
        if ($null -eq $hostCommand) {
            $integration = [pscustomobject][ordered]@{
                status = "FAIL"
                skipped = $false
                reason = "powershell.exe is unavailable"
                exit_code = -1
                output = ""
            }
            [void]$allErrors.Add("skill fixture integration failed closed: powershell.exe is unavailable")
        } else {
            $oldErrorActionPreference = $ErrorActionPreference
            try {
                $ErrorActionPreference = "Continue"
                $fixtureRaw = @(& $hostCommand.Source -NoLogo -NoProfile -ExecutionPolicy Bypass -File $fixtureTestPath 2>&1)
                $fixtureExitCode = $LASTEXITCODE
            } finally {
                $ErrorActionPreference = $oldErrorActionPreference
            }
            $fixtureOutput = [string]::Join("`n", @($fixtureRaw | ForEach-Object { [string]$_ })).Trim()
            $integration = [pscustomobject][ordered]@{
                status = if ($fixtureExitCode -eq 0) { "PASS" } else { "FAIL" }
                skipped = $false
                reason = ""
                exit_code = $fixtureExitCode
                output = $fixtureOutput
            }
            if ($fixtureExitCode -ne 0) {
                [void]$allErrors.Add("skill fixture integration failed (exit=$fixtureExitCode): $fixtureOutput")
            }
        }
    }
}

$status = "PASS"
if ($allErrors.Count -gt 0) {
    $status = "FAIL"
} elseif ($allWarnings.Count -gt 0) {
    $status = "WARN"
}

$skillCharValues = @($skillResults | Select-Object -ExpandProperty skill_chars)
$averageSkillChars = if ($skillCharValues.Count -gt 0) { [int][math]::Round(($skillCharValues | Measure-Object -Average).Average) } else { 0 }
$maxSkill = $skillResults | Sort-Object skill_chars -Descending | Select-Object -First 1
$maxSkillName = ""
$maxSkillChars = 0
if ($null -ne $maxSkill) {
    $maxSkillName = [string]$maxSkill.skill
    $maxSkillChars = [int]$maxSkill.skill_chars
}

$summary = [pscustomobject]@{
    total_skills = $skillResults.Count
    implicit_enabled = $implicitEnabledCount
    implicit_disabled = $implicitDisabledCount
    missing_explicit_policy = $missingPolicyCount
    skills_with_references = $skillsWithRefsCount
    skills_with_scripts = $skillsWithScriptsCount
    skills_with_assets = $skillsWithAssetsCount
    average_skill_chars = $averageSkillChars
    max_skill_chars = $maxSkillChars
    max_skill_name = $maxSkillName
    routing_boundary_warnings = $routingBoundaryWarningCount
    long_skill_warnings = $longSkillWarningCount
    asset_reference_warnings = $assetReferenceWarningCount
    script_files_total = $scriptFilesTotal
    script_library_files_total = $scriptLibraryFilesTotal
    script_contract_pass = $scriptContractPassCount
    script_contract_fail = $scriptContractFailCount
    script_cmdletbinding_missing = $scriptCmdletBindingMissingCount
    script_strictmode_missing = $scriptStrictModeMissingCount
    script_erroraction_missing = $scriptErrorActionMissingCount
    script_write_result_missing = $scriptWriteResultMissingCount
    script_output_field_missing = $scriptOutputFieldMissingCount
    script_json_capable = $scriptJsonCapableCount
    script_json_partial = $scriptJsonPartialCount
    script_shared_helper = $scriptSharedHelperCount
    script_shared_helper_missing = $scriptSharedHelperMissingCount
    links_checked = $linksCheckedTotal
    broken_links = $brokenLinksTotal
    lfs_files_checked = $lfsFilesCheckedTotal
    lfs_pointer_failures = $lfsPointerFailuresTotal
    official_validator_pass = $officialValidatorPassCount
    official_validator_fail = $officialValidatorFailCount
    errors = $allErrors.Count
    warnings = $allWarnings.Count
    missing_sections = [pscustomobject]$missingSectionCounts
}

$findings = [pscustomobject]@{
    errors = @($allErrors)
    warnings = @($allWarnings)
}

$skillArray = $skillResults.ToArray()
$result = New-Object PSObject
$result | Add-Member -NotePropertyName "timestamp" -NotePropertyValue ((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
$result | Add-Member -NotePropertyName "project_root" -NotePropertyValue $ProjectRoot
$result | Add-Member -NotePropertyName "status" -NotePropertyValue $status
$result | Add-Member -NotePropertyName "summary" -NotePropertyValue $summary
$result | Add-Member -NotePropertyName "findings" -NotePropertyValue $findings
$result | Add-Member -NotePropertyName "skills" -NotePropertyValue $skillArray
$result | Add-Member -NotePropertyName "official_validation" -NotePropertyValue ([pscustomobject][ordered]@{
    required = [bool]$RequireOfficialValidator
    path = $officialValidatorResolved
    status = if ([string]::IsNullOrWhiteSpace($officialValidatorResolved)) {
        if ($RequireOfficialValidator) { "FAIL" } else { "NOT_RUN" }
    } elseif ($officialValidatorFailCount -gt 0) {
        "FAIL"
    } else {
        "PASS"
    }
    pass = $officialValidatorPassCount
    fail = $officialValidatorFailCount
    results = $officialValidatorResults.ToArray()
})
$result | Add-Member -NotePropertyName "integration" -NotePropertyValue $integration

$jsonPath = Join-Path $reportRoot "codex-skills-audit.json"
$mdPath = Join-Path $reportRoot "codex-skills-audit.md"

$json = $result | ConvertTo-Json -Depth 20
Write-Utf8NoBom -FilePath $jsonPath -Text $json

$md = New-Object System.Collections.Generic.List[string]
[void]$md.Add("# Codex Skills Audit")
[void]$md.Add("")
[void]$md.Add("- Time: $($result.timestamp)")
[void]$md.Add("- Project: $($result.project_root)")
[void]$md.Add("- Status: **$($result.status)**")
[void]$md.Add("- Skills: $($result.summary.total_skills)")
[void]$md.Add("- Implicit Enabled: $($result.summary.implicit_enabled)")
[void]$md.Add("- Implicit Disabled: $($result.summary.implicit_disabled)")
[void]$md.Add("- Missing Explicit Policy: $($result.summary.missing_explicit_policy)")
[void]$md.Add("- Skills With References: $($result.summary.skills_with_references)")
[void]$md.Add("- Skills With Scripts: $($result.summary.skills_with_scripts)")
[void]$md.Add("- Skills With Assets: $($result.summary.skills_with_assets)")
[void]$md.Add("- Average Skill Chars: $($result.summary.average_skill_chars)")
[void]$md.Add("- Largest Skill: $($result.summary.max_skill_name) ($($result.summary.max_skill_chars))")
[void]$md.Add("- Script Files: $($result.summary.script_files_total)")
[void]$md.Add("- Script Library Files: $($result.summary.script_library_files_total)")
[void]$md.Add("- Script Contract Pass: $($result.summary.script_contract_pass)")
[void]$md.Add("- Script Contract Fail: $($result.summary.script_contract_fail)")
[void]$md.Add("- Script CmdletBinding Missing: $($result.summary.script_cmdletbinding_missing)")
[void]$md.Add("- Script StrictMode Missing: $($result.summary.script_strictmode_missing)")
[void]$md.Add("- Script ErrorAction Missing: $($result.summary.script_erroraction_missing)")
[void]$md.Add("- Script Write-Result Missing: $($result.summary.script_write_result_missing)")
[void]$md.Add("- Script Output Field Missing: $($result.summary.script_output_field_missing)")
[void]$md.Add("- Script JSON Capable: $($result.summary.script_json_capable)")
[void]$md.Add("- Script JSON Partial: $($result.summary.script_json_partial)")
[void]$md.Add("- Script Shared Helper: $($result.summary.script_shared_helper)")
[void]$md.Add("- Script Shared Helper Missing: $($result.summary.script_shared_helper_missing)")
[void]$md.Add("- Local Links Checked: $($result.summary.links_checked)")
[void]$md.Add("- Broken Local Links: $($result.summary.broken_links)")
[void]$md.Add("- LFS Files Checked: $($result.summary.lfs_files_checked)")
[void]$md.Add("- LFS Pointer Failures: $($result.summary.lfs_pointer_failures)")
[void]$md.Add("- Official Validator: $($result.official_validation.status) ($($result.official_validation.pass)/$($result.summary.total_skills))")
[void]$md.Add("- Fixture Integration: $($result.integration.status)")
[void]$md.Add("- Errors: $($result.summary.errors)")
[void]$md.Add("- Warnings: $($result.summary.warnings)")
[void]$md.Add("")
[void]$md.Add("## Section Coverage")
[void]$md.Add("")
[void]$md.Add("- use_when missing: $($result.summary.missing_sections.use_when)")
[void]$md.Add("- dont_use missing: $($result.summary.missing_sections.dont_use)")
[void]$md.Add("- input_validation missing: $($result.summary.missing_sections.input_validation)")
[void]$md.Add("- failure_handling missing: $($result.summary.missing_sections.failure_handling)")
[void]$md.Add("- output_verification missing: $($result.summary.missing_sections.output_verification)")
[void]$md.Add("- context_budget missing: $($result.summary.missing_sections.context_budget)")
[void]$md.Add("")

[void]$md.Add("## Script Contract")
[void]$md.Add("")
[void]$md.Add("- asset reference warnings: $($result.summary.asset_reference_warnings)")
[void]$md.Add("- script files total: $($result.summary.script_files_total)")
[void]$md.Add("- script library files total: $($result.summary.script_library_files_total)")
[void]$md.Add("- contract pass: $($result.summary.script_contract_pass)")
[void]$md.Add("- contract fail: $($result.summary.script_contract_fail)")
[void]$md.Add("- cmdletbinding missing: $($result.summary.script_cmdletbinding_missing)")
[void]$md.Add("- strictmode missing: $($result.summary.script_strictmode_missing)")
[void]$md.Add("- erroraction missing: $($result.summary.script_erroraction_missing)")
[void]$md.Add("- write-result missing: $($result.summary.script_write_result_missing)")
[void]$md.Add("- output field missing: $($result.summary.script_output_field_missing)")
[void]$md.Add("- json capable: $($result.summary.script_json_capable)")
[void]$md.Add("- json partial: $($result.summary.script_json_partial)")
[void]$md.Add("- shared helper: $($result.summary.script_shared_helper)")
[void]$md.Add("- shared helper missing: $($result.summary.script_shared_helper_missing)")
[void]$md.Add("")

if ($result.findings.errors.Count -gt 0) {
    [void]$md.Add("## Errors")
    foreach ($item in $result.findings.errors) {
        [void]$md.Add("- $item")
    }
    [void]$md.Add("")
}

if ($result.findings.warnings.Count -gt 0) {
    [void]$md.Add("## Warnings")
    foreach ($item in $result.findings.warnings) {
        [void]$md.Add("- $item")
    }
    [void]$md.Add("")
}

[void]$md.Add("## Skill Details")
[void]$md.Add("")
[void]$md.Add("| Skill | Status | Chars | Refs | Scripts | Assets | Implicit | Notes |")
[void]$md.Add("|---|---|---:|---:|---:|---:|---|---|")
foreach ($skill in $result.skills) {
    $noteParts = @()
    if ($skill.errors.Count -gt 0) {
        $noteParts += ("errors=" + $skill.errors.Count)
    }
    if ($skill.warnings.Count -gt 0) {
        $noteParts += ("warnings=" + $skill.warnings.Count)
    }
    if ($noteParts.Count -eq 0) {
        $noteParts = @("clean")
    }
    $implicitText = if ($null -eq $skill.metadata_fields.allow_implicit_invocation) { "missing" } elseif ([bool]$skill.metadata_fields.allow_implicit_invocation) { "true" } else { "false" }
    [void]$md.Add("| $($skill.skill) | $($skill.status) | $($skill.skill_chars) | $($skill.reference_count) | $($skill.script_count) | $($skill.asset_count) | $implicitText | $([string]::Join(', ', $noteParts)) |")
}

Write-Utf8NoBom -FilePath $mdPath -Text ([string]::Join("`r`n", $md))

Write-Output "=== Codex Skills Audit ==="
Write-Output "Status: $status"
Write-Output "Skills: $($skillResults.Count)"
Write-Output "Implicit Enabled: $implicitEnabledCount"
Write-Output "Implicit Disabled: $implicitDisabledCount"
Write-Output "Missing Explicit Policy: $missingPolicyCount"
Write-Output "Script Files: $($result.summary.script_files_total)"
Write-Output "Script Library Files: $($result.summary.script_library_files_total)"
Write-Output "Script Shared Helper: $($result.summary.script_shared_helper)"
Write-Output "Script Shared Helper Missing: $($result.summary.script_shared_helper_missing)"
Write-Output "Local Links Checked: $($result.summary.links_checked)"
Write-Output "LFS Files Checked: $($result.summary.lfs_files_checked)"
Write-Output "Official Validator: $($result.official_validation.status)"
Write-Output "Fixture Integration: $($result.integration.status)"
Write-Output "Errors: $($allErrors.Count)"
Write-Output "Warnings: $($allWarnings.Count)"
Write-Output "JSON Report: $jsonPath"
Write-Output "Markdown Report: $mdPath"

if ($status -eq "FAIL") {
    exit 1
}

exit 0

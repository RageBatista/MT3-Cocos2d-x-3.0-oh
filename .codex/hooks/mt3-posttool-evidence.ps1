[CmdletBinding()]
param(
    [string]$ProjectRoot = ""
)

$script:HookStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

function Resolve-ProjectRoot {
    param([string]$RequestedRoot)

    if (-not [string]::IsNullOrWhiteSpace($RequestedRoot)) {
        return [System.IO.Path]::GetFullPath($RequestedRoot)
    }

    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $scriptRootCandidate = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
        if (Test-Path -LiteralPath (Join-Path $scriptRootCandidate ".git")) {
            return $scriptRootCandidate
        }
    }

    try {
        $gitRoot = (& git -C $PSScriptRoot rev-parse --show-toplevel 2>$null | Select-Object -First 1)
        if (-not [string]::IsNullOrWhiteSpace([string]$gitRoot)) {
            return [System.IO.Path]::GetFullPath(([string]$gitRoot).Trim())
        }
    } catch {
    }

    return [System.IO.Path]::GetFullPath((Get-Location).Path)
}

$script:ProjectRoot = Resolve-ProjectRoot -RequestedRoot $ProjectRoot
$script:GovernanceMessage = "MT3 governance changed: run pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\validate_codex_sidecars.ps1 -ProjectRoot `"$script:ProjectRoot`"."
$script:SkillMessage = "MT3 skill changed: run audit_codex_skills.ps1 and analyze_codex_skill_workflows.ps1."
$script:ServerMessage = "Generated server output changed: verify the upstream definition and genrpc/genxdb/gengbeans chain."
$script:GovernancePattern = '(?i)(?:^|[\s"''=;,(]|/)\.codex/'
$script:SkillPattern = '(?i)(?:^|[\s"''=;,(]|/)\.agents/skills/'
$script:ServerGeneratedPattern = '(?i)(?:^|[\s"''=;,(]|/)server/(?:[^/\s"''=;(),]+/)*(?:rpc|xbean)(?:/|(?=$|[\s"''=;(),]))'
$script:ServerConfigPattern = '(?i)(?:^|[\s"''=;,(]|/)server/server/game_server/gs/confsrc(?:/|(?=$|[\s"''=;(),]))'
$script:PatchHeaderPattern = '(?im)^\*{3}[ \t]+(?:(?:Add|Update|Delete)[ \t]+File|Move[ \t]+to):[ \t]*(?<path>[^\r\n]+?)[ \t]*$'
$script:PathCandidates = [System.Collections.Generic.List[string]]::new()
$script:PatchCandidates = [System.Collections.Generic.List[string]]::new()
$script:NestedMutationText = ""

function Stop-Hook {
    $script:HookStopwatch.Stop()
    if ($env:MT3_POSTTOOL_HOOK_TEST_TIMING -eq "1") {
        [Console]::Error.WriteLine("MT3_POSTTOOL_ELAPSED_MS=$($script:HookStopwatch.ElapsedMilliseconds)")
    }
    exit 0
}

function Add-ToolInputValues {
    param(
        [object]$Value,
        [string]$FieldName = "",
        [int]$Depth = 0
    )

    if ($null -eq $Value -or $Depth -gt 6) {
        return
    }
    if ($Value -is [string]) {
        if ($FieldName -eq "patch") {
            [void]$script:PatchCandidates.Add([string]$Value)
        } elseif ($FieldName -in @("command", "cmd", "input", "path", "file_path")) {
            [void]$script:PathCandidates.Add([string]$Value)
        }
        return
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [System.Collections.IDictionary]) {
        foreach ($entry in $Value) {
            Add-ToolInputValues -Value $entry -FieldName $FieldName -Depth ($Depth + 1)
        }
        return
    }

    foreach ($key in @("command", "cmd", "patch", "input", "path", "file_path")) {
        if ($Value -is [System.Collections.IDictionary]) {
            if ($Value.Contains($key)) {
                Add-ToolInputValues -Value $Value[$key] -FieldName $key -Depth ($Depth + 1)
            }
        } else {
            $property = $Value.PSObject.Properties[$key]
            if ($null -ne $property) {
                Add-ToolInputValues -Value $property.Value -FieldName $key -Depth ($Depth + 1)
            }
        }
    }
}

function Get-ObjectPropertyValue {
    param(
        [object]$Object,
        [string]$Name
    )

    if ($null -eq $Object) {
        return $null
    }
    if ($Object -is [System.Collections.IDictionary]) {
        if ($Object.Contains($Name)) {
            return $Object[$Name]
        }
        return $null
    }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }
    return $property.Value
}

function Test-ToolSucceeded {
    param([object]$ToolResponse)

    if ($null -eq $ToolResponse) {
        return $false
    }

    $exitCode = Get-ObjectPropertyValue -Object $ToolResponse -Name "exit_code"
    if ($null -ne $exitCode -and [int]$exitCode -ne 0) {
        return $false
    }
    $success = Get-ObjectPropertyValue -Object $ToolResponse -Name "success"
    if ($null -ne $success -and -not [bool]$success) {
        return $false
    }
    $isError = Get-ObjectPropertyValue -Object $ToolResponse -Name "is_error"
    if ($null -ne $isError -and [bool]$isError) {
        return $false
    }
    $status = Get-ObjectPropertyValue -Object $ToolResponse -Name "status"
    if ($null -ne $status -and [string]$status -match '^(?i:fail(?:ed|ure)?|error|cancelled|canceled)$') {
        return $false
    }
    return $true
}

function Test-UnquotedOutputRedirection {
    param([string]$CommandText)

    $inSingleQuote = $false
    $inDoubleQuote = $false
    for ($index = 0; $index -lt $CommandText.Length; $index++) {
        $character = $CommandText[$index]
        if ($character -eq '`' -and $inDoubleQuote) {
            $index++
            continue
        }
        if ($character -eq "'" -and -not $inDoubleQuote) {
            $inSingleQuote = -not $inSingleQuote
            continue
        }
        if ($character -eq '"' -and -not $inSingleQuote) {
            $inDoubleQuote = -not $inDoubleQuote
            continue
        }
        if ($character -ne '>' -or $inSingleQuote -or $inDoubleQuote) {
            continue
        }
        $nextCharacter = if ($index + 1 -lt $CommandText.Length) { $CommandText[$index + 1] } else { [char]0 }
        if ($nextCharacter -ne '&') {
            return $true
        }
    }
    return $false
}

function Test-MutatingCommand {
    param(
        [string]$CommandText,
        [int]$Depth = 0
    )

    if ([string]::IsNullOrWhiteSpace($CommandText) -or $Depth -gt 4) {
        return $false
    }

    $powerShellWrapper = [regex]::Match($CommandText, '(?is)^\s*(?:&\s*)?(?:powershell|pwsh)(?:\.exe)?\b(?<arguments>.*)$')
    if ($powerShellWrapper.Success) {
        $wrapperArguments = $powerShellWrapper.Groups["arguments"].Value
        $encodedMatch = [regex]::Match($wrapperArguments, '(?is)(?:^|\s)-(?:EncodedCommand|enc|e)\s+(?<encoded>[A-Za-z0-9+/=]+)')
        if ($encodedMatch.Success) {
            try {
                $decodedCommand = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($encodedMatch.Groups["encoded"].Value))
                $isMutation = Test-MutatingCommand -CommandText $decodedCommand -Depth ($Depth + 1)
                if ($isMutation) {
                    $script:NestedMutationText = $decodedCommand
                }
                return $isMutation
            } catch {
                return $false
            }
        }

        $commandMatch = [regex]::Match($wrapperArguments, '(?is)(?:^|\s)-(?:Command|c)\s+(?<command>.+)$')
        if ($commandMatch.Success) {
            $nestedCommand = $commandMatch.Groups["command"].Value.Trim()
            if ($nestedCommand.Length -ge 2) {
                $first = $nestedCommand[0]
                $last = $nestedCommand[$nestedCommand.Length - 1]
                if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
                    $nestedCommand = $nestedCommand.Substring(1, $nestedCommand.Length - 2)
                }
            }
            $isMutation = Test-MutatingCommand -CommandText $nestedCommand -Depth ($Depth + 1)
            if ($isMutation) {
                $script:NestedMutationText = $nestedCommand
            }
            return $isMutation
        }
        return $false
    }

    if ($CommandText -match '(?i)(?:^|[;&|\r\n]\s*)(?:&\s*)?(?:Set-Content|Add-Content|Out-File|Clear-Content|Remove-Item|Move-Item|Copy-Item|Rename-Item|New-Item)\b') {
        return $true
    }
    if ($CommandText -match '(?i)\[(?:System\.)?IO\.(?:File|Directory)\]::(?:WriteAllText|WriteAllLines|WriteAllBytes|AppendAllText|AppendAllLines|Create|CreateText|OpenWrite|Delete|Move|Copy)\b') {
        return $true
    }
    if ($CommandText -match '(?i)(?:python|python3|py)(?:\.exe)?\b' -and $CommandText -match '(?i)(?:\bopen\s*\([^)]*,\s*["''][^"'']*[wax+][^"'']*["'']|\.(?:write_text|write_bytes|unlink|rename|replace)\s*\()') {
        return $true
    }
    if ($CommandText -match '(?i)(?:^|[;&|\r\n]\s*)(?:git(?:\.exe)?\s+(?:(?:-C|-c)\s+\S+\s+)*(?:add|apply|checkout|clean|commit|merge|mv|rebase|reset|restore|rm|switch)\b|(?:rm|mv|cp|touch|mkdir|rmdir|del|erase)\b|(?:sed|perl)\b[^\r\n;&|]*\s-(?:i|pi)\b)') {
        return $true
    }
    return (Test-UnquotedOutputRedirection -CommandText $CommandText)
}

function Get-EvidenceMessage {
    param([string]$Text)

    $normalized = $Text.Replace("\", "/")
    if ($normalized -match $script:GovernancePattern) {
        return $script:GovernanceMessage
    }
    if ($normalized -match $script:SkillPattern) {
        return $script:SkillMessage
    }
    if ($normalized -match $script:ServerGeneratedPattern -or $normalized -match $script:ServerConfigPattern) {
        return $script:ServerMessage
    }
    return ""
}

$inputText = ([Console]::In.ReadToEnd()).TrimStart([char]0xFEFF)
try {
    $hookInput = $inputText | ConvertFrom-Json -ErrorAction Stop
} catch {
    Stop-Hook
}

if ($hookInput.PSObject.Properties.Name -notcontains "tool_input" -or $hookInput.PSObject.Properties.Name -notcontains "tool_response") {
    Stop-Hook
}
if (-not (Test-ToolSucceeded -ToolResponse $hookInput.tool_response)) {
    Stop-Hook
}
$toolName = if ($hookInput.PSObject.Properties.Name -contains "tool_name") { [string]$hookInput.tool_name } else { "" }
Add-ToolInputValues -Value $hookInput.tool_input

if ($toolName -match '^(?i:Write|Edit)$') {
    foreach ($candidateValue in $script:PathCandidates) {
        $matchedMessage = Get-EvidenceMessage -Text $candidateValue
        if (-not [string]::IsNullOrWhiteSpace($matchedMessage)) {
            [ordered]@{ systemMessage = $matchedMessage } | ConvertTo-Json -Compress
            Stop-Hook
        }
    }
    Stop-Hook
}

if ($toolName -match '^(?i:apply_patch)$') {
    foreach ($patchText in $script:PatchCandidates) {
        foreach ($match in [regex]::Matches($patchText, $script:PatchHeaderPattern)) {
            $candidatePath = ([string]$match.Groups["path"].Value).Trim().Trim('"').Trim("'")
            $matchedMessage = Get-EvidenceMessage -Text $candidatePath
            if (-not [string]::IsNullOrWhiteSpace($matchedMessage)) {
                [ordered]@{ systemMessage = $matchedMessage } | ConvertTo-Json -Compress
                Stop-Hook
            }
        }
    }
    Stop-Hook
}

foreach ($candidateValue in $script:PathCandidates) {
    $script:NestedMutationText = ""
    if (-not (Test-MutatingCommand -CommandText $candidateValue)) {
        continue
    }
    $evidenceText = ([string]$candidateValue) + [Environment]::NewLine + $script:NestedMutationText
    $matchedMessage = Get-EvidenceMessage -Text $evidenceText
    if (-not [string]::IsNullOrWhiteSpace($matchedMessage)) {
        [ordered]@{ systemMessage = $matchedMessage } | ConvertTo-Json -Compress
        Stop-Hook
    }
}

Stop-Hook

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom
$script:ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))

function Stop-Hook {
    param([int]$ExitCode = 0)

    $script:HookStopwatch.Stop()
    if ($env:MT3_PRETOOL_TEST_TIMING -eq "1") {
        $decisionCpuMilliseconds = [long][Math]::Ceiling(([System.Diagnostics.Process]::GetCurrentProcess().TotalProcessorTime - $script:HookCpuStart).TotalMilliseconds)
        [Console]::Error.WriteLine("MT3_PRETOOL_ELAPSED_MS=$($script:HookStopwatch.ElapsedMilliseconds)")
        [Console]::Error.WriteLine("MT3_PRETOOL_CPU_MS=$decisionCpuMilliseconds")
    }
    exit $ExitCode
}

function Write-DenyDecision {
    param([string]$Reason)

    [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName = "PreToolUse"
            permissionDecision = "deny"
            permissionDecisionReason = $Reason
        }
    } | ConvertTo-Json -Depth 6 -Compress
    Stop-Hook
}

function Get-ObjectPropertyValue {
    param(
        [object]$Object,
        [string]$Name
    )

    if ($null -eq $Object -or $Object.PSObject.Properties.Name -notcontains $Name) {
        return $null
    }
    return $Object.$Name
}

function Get-ToolInputTexts {
    param(
        [object]$Value,
        [int]$Depth = 0
    )

    if ($null -eq $Value -or $Depth -gt 6) {
        return @()
    }
    if ($Value -is [string]) {
        return @([string]$Value)
    }
    if ($Value -is [System.Collections.IDictionary]) {
        $items = New-Object System.Collections.Generic.List[string]
        foreach ($key in @("command", "cmd", "patch", "input", "path", "file_path", "text", "content")) {
            if ($Value.Contains($key)) {
                foreach ($item in @(Get-ToolInputTexts -Value $Value[$key] -Depth ($Depth + 1))) {
                    [void]$items.Add([string]$item)
                }
            }
        }
        return $items.ToArray()
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $items = New-Object System.Collections.Generic.List[string]
        foreach ($entry in $Value) {
            foreach ($item in @(Get-ToolInputTexts -Value $entry -Depth ($Depth + 1))) {
                [void]$items.Add([string]$item)
            }
        }
        return $items.ToArray()
    }
    $items = New-Object System.Collections.Generic.List[string]
    foreach ($property in $Value.PSObject.Properties) {
        if ($property.Name -in @("command", "cmd", "patch", "input", "path", "file_path", "text", "content")) {
            foreach ($item in @(Get-ToolInputTexts -Value $property.Value -Depth ($Depth + 1))) {
                [void]$items.Add([string]$item)
            }
        }
    }
    return $items.ToArray()
}

function Remove-OuterQuotes {
    param([string]$Value)

    $trimmed = $Value.Trim()
    if ($trimmed.Length -ge 2) {
        $first = $trimmed[0]
        $last = $trimmed[$trimmed.Length - 1]
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            return $trimmed.Substring(1, $trimmed.Length - 2)
        }
    }
    return $trimmed
}

function Get-CommandTokens {
    param([string]$CommandText)

    $tokens = New-Object System.Collections.Generic.List[string]
    foreach ($tokenMatch in [regex]::Matches($CommandText, '(?:"[^"]*"|''[^'']*''|\S+)')) {
        [void]$tokens.Add((Remove-OuterQuotes -Value $tokenMatch.Value))
    }
    return $tokens.ToArray()
}

function Test-LegacyBuildScriptPath {
    param([string]$PathValue)

    $candidate = Remove-OuterQuotes -Value $PathValue
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        return $false
    }

    try {
        if ([System.IO.Path]::IsPathRooted($candidate)) {
            $fullPath = [System.IO.Path]::GetFullPath($candidate)
        } else {
            $fullPath = [System.IO.Path]::GetFullPath((Join-Path $script:ProjectRoot $candidate))
        }
    } catch {
        $fullPath = $candidate
    }

    $normalized = $fullPath.Replace("\", "/").TrimEnd("/")
    return $normalized.EndsWith("/client/Build-MT3-v120.ps1", [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-ForbiddenBuildToolPath {
    param([string]$PathValue)

    $candidate = (Remove-OuterQuotes -Value $PathValue).Replace("/", "\")
    $fileName = [string](@($candidate.Split("\"))[-1])
    $fileName = $fileName.ToLowerInvariant()
    return @("gradle", "gradle.bat", "gradlew", "gradlew.bat", "mvn", "mvn.cmd", "maven", "mvnw", "mvnw.cmd") -contains $fileName
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

function Get-NormalizedCommandSegments {
    param([string]$CommandText)

    $normalized = $CommandText.Replace("\", "/")
    $segments = New-Object System.Collections.Generic.List[string]
    $builder = New-Object System.Text.StringBuilder
    $inSingleQuote = $false
    $inDoubleQuote = $false

    for ($index = 0; $index -lt $normalized.Length; $index++) {
        $character = $normalized[$index]
        if ($character -eq '`' -and $inDoubleQuote -and $index + 1 -lt $normalized.Length) {
            [void]$builder.Append($character)
            $index++
            [void]$builder.Append($normalized[$index])
            continue
        }
        if ($character -eq "'" -and -not $inDoubleQuote) {
            $inSingleQuote = -not $inSingleQuote
            [void]$builder.Append($character)
            continue
        }
        if ($character -eq '"' -and -not $inSingleQuote) {
            $inDoubleQuote = -not $inDoubleQuote
            [void]$builder.Append($character)
            continue
        }

        $isSeparator = $false
        if (-not $inSingleQuote -and -not $inDoubleQuote) {
            if ($character -eq ';' -or $character -eq '|') {
                $isSeparator = $true
                if ($index + 1 -lt $normalized.Length -and $normalized[$index + 1] -eq $character) {
                    $index++
                }
            } elseif ($character -eq '&' -and $index + 1 -lt $normalized.Length -and $normalized[$index + 1] -eq '&') {
                $isSeparator = $true
                $index++
            }
        }

        if ($isSeparator) {
            $value = $builder.ToString().Trim()
            if (-not [string]::IsNullOrWhiteSpace($value)) {
                [void]$segments.Add($value)
            }
            [void]$builder.Clear()
            continue
        }
        [void]$builder.Append($character)
    }

    $lastValue = $builder.ToString().Trim()
    if (-not [string]::IsNullOrWhiteSpace($lastValue)) {
        [void]$segments.Add($lastValue)
    }
    return $segments.ToArray()
}

function Test-ForbiddenBuildExecutable {
    param([string]$CommandText)

    if ($CommandText -notmatch '(?i)(?:Build-MT3-v120\.ps1|gradle|mvn|maven)') {
        return $false
    }

    foreach ($segmentValue in @(Get-NormalizedCommandSegments -CommandText $CommandText)) {
        $segment = ([string]$segmentValue).Trim()
        $segment = $segment.Trim('"', "'")

        $cmdWrapper = [regex]::Match($segment, '(?i)^cmd(?:\.exe)?\s+/(?:c|k)\s+(?:call\s+)?(.+)$')
        if ($cmdWrapper.Success) {
            if (Test-ForbiddenBuildExecutable -CommandText $cmdWrapper.Groups[1].Value.Trim('"', "'")) {
                return $true
            }
            continue
        }

        $powerShellCommand = [regex]::Match($segment, '(?i)^(?:powershell|pwsh)(?:\.exe)?\b.*?\s-(?:Command|c)\s+(.+)$')
        if ($powerShellCommand.Success) {
            if (Test-ForbiddenBuildExecutable -CommandText $powerShellCommand.Groups[1].Value.Trim('"', "'")) {
                return $true
            }
            continue
        }

        $powerShellFile = [regex]::Match($segment, '(?i)^(?:powershell|pwsh)(?:\.exe)?\b.*?\s-File\s+(?<path>"[^"]+"|''[^'']+''|\S+)')
        if ($powerShellFile.Success -and (Test-LegacyBuildScriptPath -PathValue $powerShellFile.Groups["path"].Value)) {
            return $true
        }

        $directInvocation = [regex]::Match($segment, '^(?:&\s*)?(?<path>"[^"]+"|''[^'']+''|\S+)')
        if ($directInvocation.Success -and (Test-LegacyBuildScriptPath -PathValue $directInvocation.Groups["path"].Value)) {
            return $true
        }

        if ($directInvocation.Success -and (Test-ForbiddenBuildToolPath -PathValue $directInvocation.Groups["path"].Value)) {
            return $true
        }
    }

    return $false
}

function Get-GuardedGitOperationReason {
    param([string]$CommandText)

    if ($CommandText -notmatch '(?i)\bgit(?:\.exe)?\b') {
        return ''
    }

    foreach ($segmentValue in @(Get-NormalizedCommandSegments -CommandText $CommandText)) {
        $segment = ([string]$segmentValue).Trim()

        $cmdWrapper = [regex]::Match($segment, '(?i)^cmd(?:\.exe)?\s+/(?:c|k)\s+(?:call\s+)?(.+)$')
        if ($cmdWrapper.Success) {
            $nestedReason = Get-GuardedGitOperationReason -CommandText $cmdWrapper.Groups[1].Value.Trim('"', "'")
            if (-not [string]::IsNullOrWhiteSpace($nestedReason)) {
                return $nestedReason
            }
            continue
        }

        $powerShellCommand = [regex]::Match($segment, '(?i)^(?:powershell|pwsh)(?:\.exe)?\b.*?\s-(?:Command|c)\s+(.+)$')
        if ($powerShellCommand.Success) {
            $nestedReason = Get-GuardedGitOperationReason -CommandText $powerShellCommand.Groups[1].Value.Trim('"', "'")
            if (-not [string]::IsNullOrWhiteSpace($nestedReason)) {
                return $nestedReason
            }
            continue
        }

        $tokens = @(Get-CommandTokens -CommandText $segment)
        if ($tokens.Count -eq 0 -or $tokens[0] -notmatch '^(?i:git(?:\.exe)?)$') {
            continue
        }

        $index = 1
        while ($index -lt $tokens.Count) {
            if ($tokens[$index] -eq '-C' -and $index + 1 -lt $tokens.Count) {
                $index += 2
                continue
            }
            if ($tokens[$index] -eq '-c' -and $index + 1 -lt $tokens.Count) {
                $index += 2
                continue
            }
            if ($tokens[$index] -match '^--(?:git-dir|work-tree)=') {
                $index++
                continue
            }
            break
        }
        if ($index -ge $tokens.Count) {
            continue
        }

        $operation = $tokens[$index].ToLowerInvariant()
        $arguments = @()
        if ($index + 1 -lt $tokens.Count) {
            $arguments = @($tokens[($index + 1)..($tokens.Count - 1)])
        }

        if ($operation -eq 'add' -and @($arguments | Where-Object { $_ -in @('-A', '--all', '.') }).Count -gt 0) {
            return 'Broad git staging is blocked; inspect the target worktree and stage explicit paths.'
        }

        if ($operation -eq 'clean') {
            $hasForce = @($arguments | Where-Object { $_ -eq '--force' -or $_ -match '^-[^-]*f' }).Count -gt 0
            if ($hasForce) {
                return 'Forced git clean is blocked; inventory untracked paths and preserve required artifacts first.'
            }
        }

        if ($operation -eq 'sparse-checkout' -and $arguments.Count -gt 0 -and $arguments[0] -in @('add', 'disable', 'init', 'reapply', 'set')) {
            return 'Changing sparse-checkout boundaries is blocked until the current mode, path list, and target worktree are recorded.'
        }
    }

    return ''
}

function Get-UnsafeTextWriteReason {
    param([string]$CommandText)

    if ($CommandText -notmatch '(?i)(?:Set-Content|Add-Content|Out-File|Clear-Content|WriteAllText|WriteAllLines|AppendAllText|AppendAllLines|python|python3|\bpy(?:\.exe)?\b|>)') {
        return ''
    }

    foreach ($segmentValue in @(Get-NormalizedCommandSegments -CommandText $CommandText)) {
        $segment = ([string]$segmentValue).Trim()

        $cmdWrapper = [regex]::Match($segment, '(?i)^cmd(?:\.exe)?\s+/(?:c|k)\s+(?:call\s+)?(.+)$')
        if ($cmdWrapper.Success) {
            $nestedReason = Get-UnsafeTextWriteReason -CommandText $cmdWrapper.Groups[1].Value.Trim('"', "'")
            if (-not [string]::IsNullOrWhiteSpace($nestedReason)) {
                return $nestedReason
            }
            continue
        }

        $powerShellCommand = [regex]::Match($segment, '(?i)^(?:powershell|pwsh)(?:\.exe)?\b.*?\s-(?:Command|c)\s+(.+)$')
        if ($powerShellCommand.Success) {
            $nestedReason = Get-UnsafeTextWriteReason -CommandText $powerShellCommand.Groups[1].Value.Trim('"', "'")
            if (-not [string]::IsNullOrWhiteSpace($nestedReason)) {
                return $nestedReason
            }
            continue
        }

        if ($segment -match '(?i)^(?:&\s*)?(?:Set-Content|Add-Content|Out-File|Clear-Content)\b') {
            $encodingMatch = [regex]::Match($segment, '(?i)-Encoding\s+([A-Za-z0-9_-]+)')
            if (-not $encodingMatch.Success) {
                return "PowerShell text writes must specify a stable encoding or use a .NET writer with an explicit Encoding instance."
            }
            $encodingName = $encodingMatch.Groups[1].Value.ToLowerInvariant()
            if (@("default", "oem") -contains $encodingName) {
                return "-Encoding Default/OEM is machine-code-page dependent and is forbidden for MT3 text writes."
            }
        }

        if ($segment -match '(?i)^(?:&\s*)?\[(?:System\.)?IO\.File\]::(?:WriteAllText|WriteAllLines|AppendAllText|AppendAllLines)\b' -and $segment -notmatch '(?i)(?:Text\.)?Encoding') {
            return ".NET text writes must pass an explicit Encoding instance."
        }

        if ($segment -match '(?i)^(?:python|python3|py)(?:\.exe)?\b' -and $segment -match '(?i)\bopen\s*\([^)]*,\s*["''][^"'']*[wax+][^"'']*["'']' -and $segment -notmatch '(?i)\bencoding\s*=') {
            return "Python text writes must pass an explicit encoding argument."
        }
    }

    if (Test-UnquotedOutputRedirection -CommandText $CommandText) {
        return "MT3 text writes must not use > or >>; detect the original encoding and use an explicit-encoding writer."
    }
    return ""
}

function Test-GeneratedPath {
    param([string]$Text)

    $normalized = $Text.Replace("\", "/")
    return (
        $normalized -match '(?i)server/.+/(?:xbean|rpc)/.+\.java' -or
        $normalized -match '(?i)server/server/game_server/gs/confsrc/' -or
        $normalized -match '(?i)client/.+/tolua\+\+/.+\.cpp' -or
        $normalized -match '(?i)client/FireClient/Application/ProtoDef/' -or
        $normalized -match '(?i)client/android/LocojoyProject/assets/res/'
    )
}

function Test-GeneratedMutationCommand {
    param([string]$CommandText)

    if (-not (Test-GeneratedPath -Text $CommandText)) {
        return $false
    }

    foreach ($segmentValue in @(Get-NormalizedCommandSegments -CommandText $CommandText)) {
        $segment = ([string]$segmentValue).Trim()

        $cmdWrapper = [regex]::Match($segment, '(?i)^cmd(?:\.exe)?\s+/(?:c|k)\s+(?:call\s+)?(.+)$')
        if ($cmdWrapper.Success) {
            if (Test-GeneratedMutationCommand -CommandText $cmdWrapper.Groups[1].Value.Trim('"', "'")) {
                return $true
            }
            continue
        }

        $powerShellCommand = [regex]::Match($segment, '(?i)^(?:powershell|pwsh)(?:\.exe)?\b.*?\s-(?:Command|c)\s+(.+)$')
        if ($powerShellCommand.Success) {
            if (Test-GeneratedMutationCommand -CommandText $powerShellCommand.Groups[1].Value.Trim('"', "'")) {
                return $true
            }
            continue
        }

        if ($segment -match '(?i)^(?:&\s*)?(?:Set-Content|Add-Content|Out-File|Clear-Content|Remove-Item|Move-Item|Copy-Item|del|erase|rm|mv|cp)\b') {
            return $true
        }
        if ($segment -match '(?i)^(?:&\s*)?\[(?:System\.)?IO\.File\]::(?:WriteAllText|WriteAllLines|AppendAllText|AppendAllLines|CreateText|OpenWrite|Delete|Move|Copy)\b') {
            return $true
        }
        if ($segment -match '(?i)^(?:python|python3|py)(?:\.exe)?\b' -and $segment -match '(?i)(?:\bopen\s*\([^)]*,\s*["''][^"'']*[wax+][^"'']*["'']|\.(?:write_text|write_bytes|unlink|rename|replace)\s*\()') {
            return $true
        }
        if ($segment -match '(?i)^(?:&\s*)?git(?:\.exe)?\b(?:\s+-C\s+(?:"[^"]+"|''[^'']+''|\S+))*\s+restore\b') {
            return $true
        }
    }

    return $false
}

$inputText = ([Console]::In.ReadToEnd()).TrimStart([char]0xFEFF)
$script:HookStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$script:HookCpuStart = [System.Diagnostics.Process]::GetCurrentProcess().TotalProcessorTime
try {
    $hookInput = $inputText | ConvertFrom-Json -ErrorAction Stop
} catch {
    Write-DenyDecision -Reason ("MT3 PreToolUse hook could not parse its input JSON: " + $_.Exception.Message)
}

$toolNameValue = Get-ObjectPropertyValue -Object $hookInput -Name "tool_name"
$toolInput = Get-ObjectPropertyValue -Object $hookInput -Name "tool_input"
$toolName = [string]$toolNameValue
$candidateTexts = @(Get-ToolInputTexts -Value $toolInput)
$combinedText = ($candidateTexts -join [Environment]::NewLine)

if ($toolName -match '^(?i:apply_patch|Edit|Write)$') {
    if (Test-GeneratedPath -Text $combinedText) {
        Write-DenyDecision -Reason "The patch targets generated MT3 code or generated Android resources; edit the source definition/resource and rerun its generator."
    }
    Stop-Hook
}

if ($candidateTexts.Count -eq 0) {
    Stop-Hook
}

foreach ($candidateText in $candidateTexts) {
    $commandText = [string]$candidateText
    if ([string]::IsNullOrWhiteSpace($commandText)) {
        continue
    }

    if (Test-ForbiddenBuildExecutable -CommandText $commandText) {
        Write-DenyDecision -Reason "The command bypasses MT3 build baselines: use the canonical v120 entry for Win32, NDK r16 clang plus Ant for Android, and Ant for the server."
    }

    $guardedGitReason = Get-GuardedGitOperationReason -CommandText $commandText
    if (-not [string]::IsNullOrWhiteSpace($guardedGitReason)) {
        Write-DenyDecision -Reason $guardedGitReason
    }

    $unsafeWriteReason = Get-UnsafeTextWriteReason -CommandText $commandText
    if (-not [string]::IsNullOrWhiteSpace($unsafeWriteReason)) {
        Write-DenyDecision -Reason $unsafeWriteReason
    }

    if (Test-GeneratedMutationCommand -CommandText $commandText) {
        Write-DenyDecision -Reason "The command attempts to write or move generated MT3 files; locate the upstream definition and generator first."
    }
}

Stop-Hook

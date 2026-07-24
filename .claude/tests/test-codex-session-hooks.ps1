[CmdletBinding()]
param(
    [string]$ProjectRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
} else {
    $ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
}

$sessionHookPath = Join-Path $ProjectRoot ".codex\hooks\mt3-session-context.ps1"
$postToolHookPath = Join-Path $ProjectRoot ".codex\hooks\mt3-posttool-evidence.ps1"
$hooksConfigPath = Join-Path $ProjectRoot ".codex\hooks.json"
$auditScriptPath = Join-Path $ProjectRoot ".claude\scripts\audit_codex_guardrails.ps1"
$testScriptPath = Join-Path $ProjectRoot ".claude\tests\test-codex-session-hooks.ps1"
$failures = New-Object System.Collections.Generic.List[string]
$results = New-Object System.Collections.Generic.List[object]

$sessionContext = "MT3 toolchains: Win32=VS2013/v120/Windows SDK 8.1; Android=NDK r16 clang + Ant + JDK 8; Server=JDK 7/8 + Ant. Generated outputs must be changed through source definitions. Default MCP profile=none."
$governanceMessage = "MT3 governance changed: run pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\validate_codex_sidecars.ps1 -ProjectRoot `"$ProjectRoot`"."
$skillMessage = "MT3 skill changed: run audit_codex_skills.ps1 and analyze_codex_skill_workflows.ps1."
$serverMessage = "Generated server output changed: verify the upstream definition and genrpc/genxdb/gengbeans chain."
$sensitiveMarkers = @(
    "COMMAND_SECRET_MARKER",
    "PATH_SECRET_MARKER",
    "PATCH_SECRET_MARKER",
    "TOOL_RESPONSE_SECRET_MARKER",
    "ENV_SECRET_MARKER"
)

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        [void]$script:failures.Add($Message)
    }
}

function Add-CaseResult {
    param(
        [string]$Shell,
        [string]$Name,
        [long]$ElapsedMilliseconds,
        [long]$ProcessElapsedMilliseconds,
        [long[]]$ElapsedSamplesMilliseconds,
        [long[]]$ProcessSamplesMilliseconds,
        [bool]$Passed
    )

    [void]$script:results.Add([pscustomobject][ordered]@{
        shell = $Shell
        name = $Name
        elapsed_ms = $ElapsedMilliseconds
        process_ms = $ProcessElapsedMilliseconds
        elapsed_samples_ms = @($ElapsedSamplesMilliseconds)
        process_samples_ms = @($ProcessSamplesMilliseconds)
        passed = $Passed
    })
}

function Invoke-HookProcess {
    param(
        [string]$ShellPath,
        [string]$ScriptPath,
        [string]$InputJson,
        [string]$TimingEnvironmentVariable,
        [string]$TimingMarker
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $ShellPath
    $startInfo.Arguments = '-NoLogo -NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '"'
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true
    $startInfo.EnvironmentVariables[$TimingEnvironmentVariable] = "1"

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $processStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    [void]$process.Start()
    $inputBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($InputJson)
    $inputStream = $process.StandardInput.BaseStream
    $inputStream.Write($inputBytes, 0, $inputBytes.Length)
    $inputStream.Flush()
    $inputStream.Close()
    $stdout = $process.StandardOutput.ReadToEnd().Trim()
    $stderr = $process.StandardError.ReadToEnd().Trim()
    $process.WaitForExit()
    $processStopwatch.Stop()

    $escapedMarker = [regex]::Escape($TimingMarker)
    $timingMatches = [regex]::Matches($stderr, "(?m)^$escapedMarker=(?<elapsed>\d+)\r?$")
    $elapsedMilliseconds = -1
    $timingError = ""
    if ($timingMatches.Count -eq 1) {
        $elapsedMilliseconds = [long]$timingMatches[0].Groups["elapsed"].Value
        $stderr = [regex]::Replace($stderr, "(?m)^$escapedMarker=\d+\r?$", "").Trim()
    } else {
        $timingError = "Expected one $TimingMarker sample, found $($timingMatches.Count)"
    }

    return [pscustomobject][ordered]@{
        ExitCode = $process.ExitCode
        Stdout = $stdout
        Stderr = $stderr
        TimingError = $timingError
        ElapsedMilliseconds = $elapsedMilliseconds
        ProcessElapsedMilliseconds = $processStopwatch.ElapsedMilliseconds
        ElapsedSamplesMilliseconds = @($elapsedMilliseconds)
        ProcessSamplesMilliseconds = @($processStopwatch.ElapsedMilliseconds)
    }
}

function Convert-HookOutput {
    param(
        [string]$Text,
        [string]$CaseName
    )

    try {
        return $Text | ConvertFrom-Json -ErrorAction Stop
    } catch {
        [void]$script:failures.Add("$CaseName returned invalid JSON")
        return $null
    }
}

function New-PostCase {
    param(
        [string]$Name,
        [string]$ToolName,
        [object]$InputObject,
        [string]$ExpectedMessage = "",
        [string]$ToolResponseContent = "tool response fixture",
        [object]$ToolResponse = $null
    )

    return [pscustomobject][ordered]@{
        Name = $Name
        ToolName = $ToolName
        InputObject = $InputObject
        ExpectedMessage = $ExpectedMessage
        ToolResponseContent = $ToolResponseContent
        ToolResponse = $ToolResponse
    }
}

function Test-Utf8NoBomLf {
    param([string]$FilePath)

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $hasUtf8Bom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $strictUtf8 = $true
    try {
        [void]([System.Text.UTF8Encoding]::new($false, $true).GetString($bytes))
    } catch {
        $strictUtf8 = $false
    }
    $lfCount = 0
    $crlfCount = 0
    for ($index = 0; $index -lt $bytes.Length; $index++) {
        if ($bytes[$index] -eq 10) {
            $lfCount++
            if ($index -gt 0 -and $bytes[$index - 1] -eq 13) {
                $crlfCount++
            }
        }
    }
    return ($strictUtf8 -and -not $hasUtf8Bom -and $lfCount -gt 0 -and $crlfCount -eq 0)
}

$requiredFiles = @($sessionHookPath, $postToolHookPath, $hooksConfigPath, $auditScriptPath, $testScriptPath)
$missingFiles = @()
foreach ($requiredPath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        $missingFiles += $requiredPath
        [void]$failures.Add("Missing lifecycle contract file: $requiredPath")
    }
}

$shells = New-Object System.Collections.Generic.List[string]
foreach ($shellName in @("powershell.exe", "pwsh.exe")) {
    $command = Get-Command $shellName -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        [void]$failures.Add("Required lifecycle shell not found: $shellName")
    } else {
        [void]$shells.Add($command.Source)
    }
}
Assert-True ($shells.Count -eq 2) "Lifecycle matrix requires both powershell.exe and pwsh.exe"

if ($missingFiles.Count -eq 0 -and $shells.Count -eq 2) {
    $sessionPayload = [ordered]@{
        hook_event_name = "SessionStart"
        session_id = "SESSION_FIXTURE"
        transcript_path = "TRANSCRIPT_FIXTURE"
    } | ConvertTo-Json -Compress

    $largeToolResponse = "TOOL_RESPONSE_SECRET_MARKER_" + ("R" * 131072)
    $largePatch = "*** Begin Patch`n*** Update File: server/demo/rpc/Large.java`n@@`n-old`n+PATCH_SECRET_MARKER " + ("P" * 65536) + "`n*** End Patch"
    $largeCommand = ("Write-Output payload; " * 2048) + 'Get-Content ".codex/config.toml" COMMAND_SECRET_MARKER'
    $encodedWriteCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes('Set-Content -Encoding UTF8 ".codex/config.toml" value'))

    $postToolCases = @(
        (New-PostCase -Name "governance-read-relative-forward" -ToolName "exec_command" -InputObject ([ordered]@{ command = "Get-Content .codex/config.toml COMMAND_SECRET_MARKER"; env = [ordered]@{ TOKEN = "ENV_SECRET_MARKER" } }) -ToolResponseContent "TOOL_RESPONSE_SECRET_MARKER"),
        (New-PostCase -Name "governance-cmd-relative-forward" -ToolName "shell" -InputObject ([ordered]@{ cmd = "git diff -- .codex/hooks.json" })),
        (New-PostCase -Name "governance-read-quoted" -ToolName "shell" -InputObject ([ordered]@{ command = 'Get-Content ".codex/config.toml"' })),
        (New-PostCase -Name "governance-command-write-success" -ToolName "shell" -InputObject ([ordered]@{ command = 'Set-Content -Encoding UTF8 ".codex/config.toml" value' }) -ExpectedMessage $governanceMessage -ToolResponse ([ordered]@{ exit_code = 0; content = "updated" })),
        (New-PostCase -Name "governance-command-write-failed" -ToolName "shell" -InputObject ([ordered]@{ command = 'Set-Content -Encoding UTF8 ".codex/config.toml" value' }) -ToolResponse ([ordered]@{ exit_code = 1; content = "failed" })),
        (New-PostCase -Name "governance-direct-newline-write" -ToolName "shell" -InputObject ([ordered]@{ command = "Write-Output before`nRemove-Item .codex/config.toml" }) -ExpectedMessage $governanceMessage),
        (New-PostCase -Name "governance-pwsh-command-write" -ToolName "shell" -InputObject ([ordered]@{ command = 'pwsh.exe -NoProfile -Command "Set-Content -Encoding UTF8 .codex/config.toml value"' }) -ExpectedMessage $governanceMessage),
        (New-PostCase -Name "governance-pwsh-command-read" -ToolName "shell" -InputObject ([ordered]@{ command = 'pwsh -c "Get-Content .codex/config.toml"' })),
        (New-PostCase -Name "governance-powershell-encoded-write" -ToolName "shell" -InputObject ([ordered]@{ command = "powershell.exe -NoProfile -EncodedCommand $encodedWriteCommand" }) -ExpectedMessage $governanceMessage),
        (New-PostCase -Name "governance-wrapper-write-failed" -ToolName "shell" -InputObject ([ordered]@{ command = 'pwsh -Command "Remove-Item .codex/config.toml"' }) -ToolResponse ([ordered]@{ exit_code = 1; content = "failed" })),
        (New-PostCase -Name "governance-path-relative-backslash" -ToolName "Write" -InputObject ([ordered]@{ path = ".codex\config.toml" }) -ExpectedMessage $governanceMessage),
        (New-PostCase -Name "governance-path-absolute-backslash" -ToolName "Write" -InputObject ([ordered]@{ path = "E:\PATH_SECRET_MARKER\repo\.codex\config.toml" }) -ExpectedMessage $governanceMessage),
        (New-PostCase -Name "governance-file-path-forward" -ToolName "Write" -InputObject ([ordered]@{ file_path = "./.codex/config.toml" }) -ExpectedMessage $governanceMessage),
        (New-PostCase -Name "governance-nested-input" -ToolName "Write" -InputObject ([ordered]@{ input = [ordered]@{ path = ".\.codex\project-map.json" } }) -ExpectedMessage $governanceMessage),
        (New-PostCase -Name "skill-file-path" -ToolName "Write" -InputObject ([ordered]@{ file_path = ".agents/skills/mt3-project-guidelines/SKILL.md" }) -ExpectedMessage $skillMessage),
        (New-PostCase -Name "server-path-backslash" -ToolName "Write" -InputObject ([ordered]@{ path = "server\demo\rpc\Login.java" }) -ExpectedMessage $serverMessage),
        (New-PostCase -Name "server-read-forward" -ToolName "shell" -InputObject ([ordered]@{ command = "Get-Content server/demo/xbean/User.java" })),
        (New-PostCase -Name "server-confsrc-absolute" -ToolName "Write" -InputObject ([ordered]@{ file_path = "E:\MT3\server\server\game_server\gs\confsrc\Item.java" }) -ExpectedMessage $serverMessage),
        (New-PostCase -Name "patch-update-generated" -ToolName "apply_patch" -InputObject ([ordered]@{ patch = "*** Begin Patch`n*** Update File: server/demo/rpc/Login.java`n@@`n-old`n+PATCH_SECRET_MARKER`n*** End Patch" }) -ExpectedMessage $serverMessage),
        (New-PostCase -Name "patch-add-generated" -ToolName "apply_patch" -InputObject ([ordered]@{ patch = "*** Begin Patch`n*** Add File: server/demo/xbean/User.java`n+value`n*** End Patch" }) -ExpectedMessage $serverMessage),
        (New-PostCase -Name "patch-delete-generated" -ToolName "apply_patch" -InputObject ([ordered]@{ patch = "*** Begin Patch`n*** Delete File: server/server/game_server/gs/confsrc/Old.java`n*** End Patch" }) -ExpectedMessage $serverMessage),
        (New-PostCase -Name "patch-move-generated" -ToolName "apply_patch" -InputObject ([ordered]@{ patch = "*** Begin Patch`n*** Update File: definitions/Login.xml`n*** Move to: server/demo/rpc/Login.java`n*** End Patch" }) -ExpectedMessage $serverMessage),
        (New-PostCase -Name "patch-update-generated-failed" -ToolName "apply_patch" -InputObject ([ordered]@{ patch = "*** Begin Patch`n*** Update File: server/demo/rpc/Login.java`n@@`n-old`n+new`n*** End Patch" }) -ToolResponse ([ordered]@{ success = $false; error = "patch rejected" })),
        (New-PostCase -Name "governance-write-failed" -ToolName "Write" -InputObject ([ordered]@{ path = ".codex/config.toml" }) -ToolResponse ([ordered]@{ is_error = $true; content = "write rejected" })),
        (New-PostCase -Name "large-tool-response" -ToolName "Write" -InputObject ([ordered]@{ path = ".codex/config.toml" }) -ExpectedMessage $governanceMessage -ToolResponseContent $largeToolResponse),
        (New-PostCase -Name "large-patch" -ToolName "apply_patch" -InputObject ([ordered]@{ patch = $largePatch }) -ExpectedMessage $serverMessage),
        (New-PostCase -Name "large-command" -ToolName "shell" -InputObject ([ordered]@{ command = $largeCommand })),
        (New-PostCase -Name "ordinary-command" -ToolName "shell" -InputObject ([ordered]@{ command = "git status --short"; env = [ordered]@{ TOKEN = "ENV_SECRET_MARKER" } })),
        (New-PostCase -Name "tool-response-only" -ToolName "Write" -InputObject ([ordered]@{ path = "docs/guide.md" }) -ToolResponseContent "TOOL_RESPONSE_SECRET_MARKER .codex/config.toml"),
        (New-PostCase -Name "rpc-overview-boundary" -ToolName "Write" -InputObject ([ordered]@{ path = "server/docs/rpc-overview.md" })),
        (New-PostCase -Name "myrpc-notes-boundary" -ToolName "Write" -InputObject ([ordered]@{ path = "server/demo/myrpc_notes/Login.java" })),
        (New-PostCase -Name "unrelated-patch-body-reference" -ToolName "apply_patch" -InputObject ([ordered]@{ patch = "*** Begin Patch`n*** Update File: docs/note.md`n@@`n-old`n+server/demo/rpc/Login.java PATCH_SECRET_MARKER`n*** End Patch" })),
        (New-PostCase -Name "patch-header-rpc-overview" -ToolName "apply_patch" -InputObject ([ordered]@{ patch = "*** Begin Patch`n*** Update File: server/docs/rpc-overview.md`n@@`n-old`n+server/demo/rpc/Login.java`n*** End Patch" })),
        (New-PostCase -Name "embedded-codex-name" -ToolName "Write" -InputObject ([ordered]@{ path = "notes/my.codex/config.toml" })),
        (New-PostCase -Name "embedded-agents-name" -ToolName "Write" -InputObject ([ordered]@{ path = "notes/my.agents/skills/demo/SKILL.md" }))
    )

    foreach ($shell in $shells) {
        $shellName = [System.IO.Path]::GetFileName($shell)
        $failureCountBefore = $failures.Count
        $sessionRun = Invoke-HookProcess -ShellPath $shell -ScriptPath $sessionHookPath -InputJson $sessionPayload -TimingEnvironmentVariable "MT3_SESSION_HOOK_TEST_TIMING" -TimingMarker "MT3_SESSION_ELAPSED_MS"
        Assert-True ($sessionRun.ExitCode -eq 0) "$shellName/SessionStart exited with $($sessionRun.ExitCode)"
        Assert-True ([string]::IsNullOrWhiteSpace($sessionRun.Stderr)) "$shellName/SessionStart wrote unexpected stderr"
        Assert-True ([string]::IsNullOrWhiteSpace($sessionRun.TimingError)) "$shellName/SessionStart timing sample missing"
        Assert-True ($sessionRun.ElapsedMilliseconds -ge 0) "$shellName/SessionStart returned an invalid timing sample"
        if ([string]::IsNullOrWhiteSpace($sessionRun.Stdout)) {
            [void]$failures.Add("$shellName/SessionStart returned empty stdout")
        } else {
            $expectedSessionJson = [ordered]@{
                hookSpecificOutput = [ordered]@{
                    hookEventName = "SessionStart"
                    additionalContext = $sessionContext
                }
            } | ConvertTo-Json -Depth 5 -Compress
            Assert-True ($sessionRun.Stdout -ceq $expectedSessionJson) "$shellName/SessionStart JSON payload mismatch"
            $session = Convert-HookOutput -Text $sessionRun.Stdout -CaseName "$shellName/SessionStart"
            if ($null -ne $session) {
                Assert-True (@($session.PSObject.Properties.Name).Count -eq 1 -and $session.PSObject.Properties.Name -contains "hookSpecificOutput") "SessionStart top-level fields mismatch"
                Assert-True (@($session.hookSpecificOutput.PSObject.Properties.Name).Count -eq 2) "SessionStart specific field count mismatch"
                Assert-True ([string]$session.hookSpecificOutput.hookEventName -ceq "SessionStart") "SessionStart event name mismatch"
                Assert-True ([string]$session.hookSpecificOutput.additionalContext -ceq $sessionContext) "SessionStart context mismatch"
            }
        }
        Assert-True ([string]$sessionRun.Stdout -notmatch "SESSION_FIXTURE|TRANSCRIPT_FIXTURE") "$shellName/SessionStart leaked input details"
        Add-CaseResult -Shell $shellName -Name "session-start" -ElapsedMilliseconds $sessionRun.ElapsedMilliseconds -ProcessElapsedMilliseconds $sessionRun.ProcessElapsedMilliseconds -ElapsedSamplesMilliseconds $sessionRun.ElapsedSamplesMilliseconds -ProcessSamplesMilliseconds $sessionRun.ProcessSamplesMilliseconds -Passed ($failures.Count -eq $failureCountBefore)

        foreach ($case in $postToolCases) {
            $failureCountBefore = $failures.Count
            $toolResponse = if ($null -ne $case.ToolResponse) {
                $case.ToolResponse
            } else {
                [ordered]@{
                    content = [string]$case.ToolResponseContent
                    token = "TOOL_RESPONSE_SECRET_MARKER"
                }
            }
            $payload = [ordered]@{
                hook_event_name = "PostToolUse"
                tool_name = [string]$case.ToolName
                tool_input = $case.InputObject
                tool_response = $toolResponse
            } | ConvertTo-Json -Depth 12 -Compress
            $run = Invoke-HookProcess -ShellPath $shell -ScriptPath $postToolHookPath -InputJson $payload -TimingEnvironmentVariable "MT3_POSTTOOL_HOOK_TEST_TIMING" -TimingMarker "MT3_POSTTOOL_ELAPSED_MS"
            Assert-True ($run.ExitCode -eq 0) "$shellName/$($case.Name) exited with $($run.ExitCode)"
            Assert-True ([string]::IsNullOrWhiteSpace($run.Stderr)) "$shellName/$($case.Name) wrote unexpected stderr"
            Assert-True ([string]::IsNullOrWhiteSpace($run.TimingError)) "$shellName/$($case.Name) timing sample missing"
            Assert-True ($run.ElapsedMilliseconds -ge 0) "$shellName/$($case.Name) returned an invalid timing sample"
            foreach ($marker in $sensitiveMarkers) {
                Assert-True ([string]$run.Stdout -notmatch [regex]::Escape($marker)) "$shellName/$($case.Name) leaked $marker"
            }

            if ([string]::IsNullOrWhiteSpace([string]$case.ExpectedMessage)) {
                Assert-True ([string]::IsNullOrWhiteSpace($run.Stdout)) "$shellName/$($case.Name) ordinary PostToolUse must stay silent"
            } else {
                if ([string]::IsNullOrWhiteSpace($run.Stdout)) {
                    [void]$failures.Add("$shellName/$($case.Name) returned empty stdout")
                } else {
                    $expectedPostJson = [ordered]@{ systemMessage = [string]$case.ExpectedMessage } | ConvertTo-Json -Compress
                    Assert-True ($run.Stdout -ceq $expectedPostJson) "$shellName/$($case.Name) JSON payload mismatch"
                    $postResult = Convert-HookOutput -Text $run.Stdout -CaseName "$shellName/$($case.Name)"
                    if ($null -ne $postResult) {
                        Assert-True (@($postResult.PSObject.Properties.Name).Count -eq 1 -and $postResult.PSObject.Properties.Name -contains "systemMessage") "$shellName/$($case.Name) fields mismatch"
                        Assert-True ([string]$postResult.systemMessage -ceq [string]$case.ExpectedMessage) "$shellName/$($case.Name) message mismatch"
                    }
                }
            }
            Add-CaseResult -Shell $shellName -Name ([string]$case.Name) -ElapsedMilliseconds $run.ElapsedMilliseconds -ProcessElapsedMilliseconds $run.ProcessElapsedMilliseconds -ElapsedSamplesMilliseconds $run.ElapsedSamplesMilliseconds -ProcessSamplesMilliseconds $run.ProcessSamplesMilliseconds -Passed ($failures.Count -eq $failureCountBefore)
        }
    }

    $failureCountBefore = $failures.Count
    try {
        $hooksConfig = Get-Content -Raw -Encoding UTF8 -LiteralPath $hooksConfigPath | ConvertFrom-Json -ErrorAction Stop
        $eventScripts = [ordered]@{
            SessionStart = "mt3-session-context.ps1"
            PostToolUse = "mt3-posttool-evidence.ps1"
        }
        foreach ($eventName in $eventScripts.Keys) {
            Assert-True ($hooksConfig.hooks.PSObject.Properties.Name -contains $eventName) "hooks.json missing $eventName"
            if ($hooksConfig.hooks.PSObject.Properties.Name -contains $eventName) {
                $eventEntries = @($hooksConfig.hooks.$eventName)
                Assert-True ($eventEntries.Count -eq 1) "hooks.json $eventName must have one entry"
                if ($eventEntries.Count -eq 1) {
                    $commands = @($eventEntries[0].hooks)
                    Assert-True ($commands.Count -eq 1) "hooks.json $eventName must have one command"
                    if ($commands.Count -eq 1) {
                        Assert-True ([int]$commands[0].timeout -eq 5) "hooks.json $eventName timeout must be 5"
                        Assert-True ([string]$commands[0].commandWindows -match '^powershell\.exe -NoProfile -ExecutionPolicy Bypass -Command ') "hooks.json $eventName Windows command style mismatch"
                        Assert-True ([string]$commands[0].commandWindows -match [regex]::Escape([string]$eventScripts[$eventName])) "hooks.json $eventName Windows command target mismatch"
                    }
                }
            }
        }
    } catch {
        [void]$failures.Add("hooks.json lifecycle registration is invalid")
    }
    Add-CaseResult -Shell "config" -Name "hooks-registration" -ElapsedMilliseconds 0 -ProcessElapsedMilliseconds 0 -ElapsedSamplesMilliseconds @(0) -ProcessSamplesMilliseconds @(0) -Passed ($failures.Count -eq $failureCountBefore)

    $failureCountBefore = $failures.Count
    foreach ($hookPath in @($sessionHookPath, $postToolHookPath)) {
        $sourceText = Get-Content -Raw -Encoding UTF8 -LiteralPath $hookPath
        $timerIndex = $sourceText.IndexOf('$script:HookStopwatch = [System.Diagnostics.Stopwatch]::StartNew()')
        $strictModeIndex = $sourceText.IndexOf('Set-StrictMode -Version Latest')
        $readIndex = $sourceText.IndexOf('[Console]::In.ReadToEnd()')
        Assert-True ($timerIndex -ge 0) "$(Split-Path -Leaf $hookPath) missing lifecycle stopwatch"
        Assert-True ($strictModeIndex -ge 0 -and $timerIndex -lt $strictModeIndex) "$(Split-Path -Leaf $hookPath) stopwatch must start before initialization"
        Assert-True ($readIndex -ge 0 -and $timerIndex -lt $readIndex) "$(Split-Path -Leaf $hookPath) stopwatch must cover stdin ReadToEnd"
    }
    $postToolSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $postToolHookPath
    Assert-True ($postToolSource -notmatch 'E:\\MT3') "mt3-posttool-evidence.ps1 must not hard-code the repository root"
    Assert-True ($postToolSource -match 'ProjectRoot') "mt3-posttool-evidence.ps1 must resolve ProjectRoot"
    Add-CaseResult -Shell "source" -Name "timing-order" -ElapsedMilliseconds 0 -ProcessElapsedMilliseconds 0 -ElapsedSamplesMilliseconds @(0) -ProcessSamplesMilliseconds @(0) -Passed ($failures.Count -eq $failureCountBefore)

    $failureCountBefore = $failures.Count
    $auditSourceText = Get-Content -Raw -Encoding UTF8 -LiteralPath $auditScriptPath
    Assert-True ($auditSourceText -match 'max_process_ms') "guardrail audit must retain lifecycle process wall-clock diagnostics"
    Assert-True ($auditSourceText -match 'Lifecycle Matrix:.*wall') "guardrail audit console summary must report lifecycle wall clock"
    Add-CaseResult -Shell "source" -Name "audit-wall-diagnostic" -ElapsedMilliseconds 0 -ProcessElapsedMilliseconds 0 -ElapsedSamplesMilliseconds @(0) -ProcessSamplesMilliseconds @(0) -Passed ($failures.Count -eq $failureCountBefore)

    $failureCountBefore = $failures.Count
    foreach ($filePath in $requiredFiles) {
        Assert-True (Test-Utf8NoBomLf -FilePath $filePath) "$(Split-Path -Leaf $filePath) must be UTF-8 no BOM with LF"
    }
    Add-CaseResult -Shell "source" -Name "utf8-no-bom-lf" -ElapsedMilliseconds 0 -ProcessElapsedMilliseconds 0 -ElapsedSamplesMilliseconds @(0) -ProcessSamplesMilliseconds @(0) -Passed ($failures.Count -eq $failureCountBefore)
}

$status = if ($failures.Count -eq 0) { "PASS" } else { "FAIL" }
$maxElapsedMilliseconds = if ($results.Count -gt 0) {
    [long](($results | Measure-Object -Property elapsed_ms -Maximum).Maximum)
} else {
    -1
}
$maxProcessElapsedMilliseconds = if ($results.Count -gt 0) {
    [long](($results | Measure-Object -Property process_ms -Maximum).Maximum)
} else {
    -1
}
$result = [pscustomobject][ordered]@{
    status = $status
    summary = "Codex lifecycle hook matrix: shells=$($shells.Count) cases=$($results.Count) failures=$($failures.Count) max_elapsed_ms=$maxElapsedMilliseconds max_process_ms=$maxProcessElapsedMilliseconds"
    data = [pscustomobject][ordered]@{
        session_hook = $sessionHookPath
        posttool_hook = $postToolHookPath
        shell_count = $shells.Count
        case_count = $results.Count
        executed_count = $results.Count
        max_elapsed_ms = $maxElapsedMilliseconds
        max_process_ms = $maxProcessElapsedMilliseconds
        failures = $failures.ToArray()
        cases = $results.ToArray()
    }
    issues = $failures.ToArray()
}

if ($Json) {
    $result | ConvertTo-Json -Depth 10
} else {
    Write-Output $result.summary
    foreach ($failure in $failures) {
        Write-Output ("FAIL: " + $failure)
    }
}

if ($status -eq "FAIL") {
    exit 1
}
exit 0

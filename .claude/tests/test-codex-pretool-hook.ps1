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

$hookPath = Join-Path $ProjectRoot ".codex\hooks\mt3-pretool-guard.ps1"
if (-not (Test-Path -LiteralPath $hookPath -PathType Leaf)) {
    throw "PreToolUse hook not found: $hookPath"
}

function Invoke-HookProcess {
    param(
        [string]$ShellPath,
        [string]$ScriptPath,
        [string]$InputJson
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $ShellPath
    $startInfo.Arguments = '-NoLogo -NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '"'
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true
    $startInfo.EnvironmentVariables["MT3_PRETOOL_TEST_TIMING"] = "1"

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $processStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    [void]$process.Start()
    $inputBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($InputJson)
    $inputStream = $process.StandardInput.BaseStream
    $inputStream.Write($inputBytes, 0, $inputBytes.Length)
    $inputStream.Flush()
    $inputStream.Close()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderrText = $process.StandardError.ReadToEnd().Trim()
    $process.WaitForExit()
    $processStopwatch.Stop()

    $timingMatches = [regex]::Matches($stderrText, '(?m)^MT3_PRETOOL_ELAPSED_MS=(?<elapsed>\d+)\r?$')
    $cpuTimingMatches = [regex]::Matches($stderrText, '(?m)^MT3_PRETOOL_CPU_MS=(?<elapsed>\d+)\r?$')
    $timingError = ""
    $cpuTimingError = ""
    $elapsedMilliseconds = -1
    $decisionCpuMilliseconds = -1
    if ($timingMatches.Count -eq 1) {
        $elapsedMilliseconds = [long]$timingMatches[0].Groups["elapsed"].Value
        $stderrText = [regex]::Replace($stderrText, '(?m)^MT3_PRETOOL_ELAPSED_MS=\d+\r?$', '').Trim()
    } else {
        $timingError = "Expected one hook timing sample, found $($timingMatches.Count)"
    }
    if ($cpuTimingMatches.Count -eq 1) {
        $decisionCpuMilliseconds = [long]$cpuTimingMatches[0].Groups["elapsed"].Value
        $stderrText = [regex]::Replace($stderrText, '(?m)^MT3_PRETOOL_CPU_MS=\d+\r?$', '').Trim()
    } else {
        $cpuTimingError = "Expected one hook CPU sample, found $($cpuTimingMatches.Count)"
    }

    return [pscustomobject]@{
        ExitCode = $process.ExitCode
        Stdout = $stdout.Trim()
        Stderr = $stderrText
        TimingError = $timingError
        CpuTimingError = $cpuTimingError
        ElapsedMilliseconds = $elapsedMilliseconds
        DecisionCpuMilliseconds = $decisionCpuMilliseconds
        ProcessElapsedMilliseconds = $processStopwatch.ElapsedMilliseconds
    }
}

$generatedPatch = "*** Begin Patch`n*** Update File: server/demo/xbean/User.java`n@@`n-old`n+new`n*** End Patch"
$normalPatch = "*** Begin Patch`n*** Update File: .codex/README.md`n@@`n-old`n+new`n*** End Patch"
$projectRootLegacyScript = Join-Path $ProjectRoot "client\Build-MT3-v120.ps1"
$projectLeaf = Split-Path -Leaf $ProjectRoot
$depth6Input = "server/demo/rpc/DepthSix.java"
foreach ($depth in 1..6) {
    $depth6Input = [ordered]@{ input = $depth6Input }
}
$depth7Input = "server/demo/rpc/DepthSeven.java"
foreach ($depth in 1..7) {
    $depth7Input = [ordered]@{ input = $depth7Input }
}

$cases = @(
    [pscustomobject]@{ Name = "legacy-direct"; Tool = "Bash"; Input = [ordered]@{ cmd = ".\client\Build-MT3-v120.ps1 -Configuration Release" }; Denied = $true },
    [pscustomobject]@{ Name = "legacy-shell-wrapper"; Tool = "Bash"; Command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\client\Build-MT3-v120.ps1"; Denied = $true },
    [pscustomobject]@{ Name = "legacy-nested-wrapper"; Tool = "Bash"; Command = "cmd.exe /c powershell.exe -File .\client\Build-MT3-v120.ps1"; Denied = $true },
    [pscustomobject]@{ Name = "legacy-absolute-path"; Tool = "Bash"; Command = 'powershell.exe -File "' + $projectRootLegacyScript + '"'; Denied = $true },
    [pscustomobject]@{ Name = "legacy-parent-normalized-path"; Tool = "Bash"; Command = "powershell.exe -File .\client\..\client\Build-MT3-v120.ps1"; Denied = $true },
    [pscustomobject]@{ Name = "legacy-parent-traversal-path"; Tool = "Bash"; Command = "powershell.exe -File ../$projectLeaf/client/Build-MT3-v120.ps1"; Denied = $true },
    [pscustomobject]@{ Name = "canonical-win32"; Tool = "Bash"; Command = "powershell.exe -File tools/scripts/Build-MT3-Exe-Canonical.ps1 -Configuration Release"; Denied = $false },
    [pscustomobject]@{ Name = "search-legacy-text"; Tool = "Bash"; Command = 'rg -n "Build-MT3-v120.ps1" .codex'; Denied = $false },
    [pscustomobject]@{ Name = "gradle-cmd-wrapper"; Tool = "Bash"; Command = "cmd.exe /c gradlew.bat assembleDebug"; Denied = $true },
    [pscustomobject]@{ Name = "gradle-cmd-call-wrapper"; Tool = "Bash"; Command = "cmd.exe /c call gradlew.bat assembleDebug"; Denied = $true },
    [pscustomobject]@{ Name = "maven-command-wrapper"; Tool = "Bash"; Command = 'powershell.exe -Command "mvnw.cmd package"'; Denied = $true },
    [pscustomobject]@{ Name = "maven-cmd-call-wrapper"; Tool = "Bash"; Command = "cmd.exe /c call mvnw.cmd package"; Denied = $true },
    [pscustomobject]@{ Name = "search-gradle-text"; Tool = "Bash"; Command = 'rg -n "gradle" .codex'; Denied = $false },
    [pscustomobject]@{ Name = "search-alternation-text"; Tool = "Bash"; Command = 'rg -n "gradle|mvn|Build-MT3-v120.ps1" .codex'; Denied = $false },
    [pscustomobject]@{ Name = "unsafe-set-content"; Tool = "Bash"; Command = "Set-Content path.txt value"; Denied = $true },
    [pscustomobject]@{ Name = "unsafe-set-content-wrapper"; Tool = "Bash"; Command = 'pwsh.exe -Command "Set-Content path.txt value"'; Denied = $true },
    [pscustomobject]@{ Name = "unstable-default-encoding"; Tool = "Bash"; Command = "set-content -Encoding Default path.txt value"; Denied = $true },
    [pscustomobject]@{ Name = "explicit-utf8-write"; Tool = "Bash"; Command = "Set-Content -Encoding UTF8 path.txt value"; Denied = $false },
    [pscustomobject]@{ Name = "dotnet-explicit-write"; Tool = "Bash"; Command = '[IO.File]::WriteAllText("path.txt", "value", (New-Object Text.UTF8Encoding($false)))'; Denied = $false },
    [pscustomobject]@{ Name = "stderr-merge"; Tool = "Bash"; Command = "Get-Content path.txt 2>&1"; Denied = $false },
    [pscustomobject]@{ Name = "output-redirection"; Tool = "Bash"; Command = "Get-Content path.txt > out.txt"; Denied = $true },
    [pscustomobject]@{ Name = "broad-staging-worktree-wrapper"; Tool = "Bash"; Command = "git -C . add -A"; Denied = $true },
    [pscustomobject]@{ Name = "explicit-staging-worktree-wrapper"; Tool = "Bash"; Command = "git -C . add -- .codex/rules/mt3-guardrails.rules"; Denied = $false },
    [pscustomobject]@{ Name = "destructive-git-clean"; Tool = "Bash"; Command = "git clean -fdx"; Denied = $true },
    [pscustomobject]@{ Name = "git-clean-dry-run"; Tool = "Bash"; Command = "git clean -ndx"; Denied = $false },
    [pscustomobject]@{ Name = "sparse-checkout-disable"; Tool = "Bash"; Command = "git sparse-checkout disable"; Denied = $true },
    [pscustomobject]@{ Name = "sparse-checkout-list"; Tool = "Bash"; Command = "git sparse-checkout list"; Denied = $false },
    [pscustomobject]@{ Name = "generated-patch"; Tool = "apply_patch"; Command = $generatedPatch; Denied = $true },
    [pscustomobject]@{ Name = "normal-patch"; Tool = "apply_patch"; Command = $normalPatch; Denied = $false },
    [pscustomobject]@{ Name = "generated-patch-real-field"; Tool = "apply_patch"; Input = [ordered]@{ patch = $generatedPatch }; Denied = $true },
    [pscustomobject]@{ Name = "normal-patch-real-field"; Tool = "apply_patch"; Input = [ordered]@{ patch = $normalPatch }; Denied = $false },
    [pscustomobject]@{ Name = "generated-edit-input"; Tool = "Edit"; Input = [ordered]@{ input = [ordered]@{ path = "server/demo/rpc/Login.java"; text = "value" } }; Denied = $true },
    [pscustomobject]@{ Name = "generated-write-array"; Tool = "Write"; Input = [ordered]@{ input = @([ordered]@{ path = "client/demo/tolua++/bind.cpp" }, [ordered]@{ text = "value" }) }; Denied = $true },
    [pscustomobject]@{ Name = "generated-gbeans-output"; Tool = "apply_patch"; Input = [ordered]@{ patch = "*** Update File: server/server/game_server/gs/confsrc/Test.java" }; Denied = $true },
    [pscustomobject]@{ Name = "gbeans-source-definition"; Tool = "apply_patch"; Input = [ordered]@{ patch = "*** Update File: gbeans/item.xml" }; Denied = $false },
    [pscustomobject]@{ Name = "generated-depth-six"; Tool = "apply_patch"; Input = $depth6Input; Denied = $true },
    [pscustomobject]@{ Name = "generated-depth-seven-truncated"; Tool = "apply_patch"; Input = $depth7Input; Denied = $false },
    [pscustomobject]@{ Name = "generated-read"; Tool = "Bash"; Command = "Get-Content server/demo/xbean/User.java"; Denied = $false },
    [pscustomobject]@{ Name = "generated-delete"; Tool = "Bash"; Command = "Remove-Item server/demo/xbean/User.java"; Denied = $true },
    [pscustomobject]@{ Name = "generated-explicit-write"; Tool = "Bash"; Command = "Set-Content -Encoding UTF8 server/demo/xbean/User.java value"; Denied = $true },
    [pscustomobject]@{ Name = "generated-dotnet-write"; Tool = "Bash"; Command = '[IO.File]::WriteAllText("server/demo/xbean/User.java", "value", (New-Object Text.UTF8Encoding($false)))'; Denied = $true },
    [pscustomobject]@{ Name = "generated-clear-content"; Tool = "Bash"; Command = "Clear-Content server/demo/xbean/User.java"; Denied = $true },
    [pscustomobject]@{ Name = "generated-python-write"; Tool = "Bash"; Command = 'python -c "open(''server/demo/xbean/User.java'', ''w'', encoding=''utf-8'').write(''value'')"'; Denied = $true },
    [pscustomobject]@{ Name = "generated-python-read"; Tool = "Bash"; Command = 'python -c "open(''server/demo/xbean/User.java'', ''r'', encoding=''utf-8'').read()"'; Denied = $false },
    [pscustomobject]@{ Name = "generated-git-restore"; Tool = "Bash"; Command = "git restore -- server/demo/xbean/User.java"; Denied = $true },
    [pscustomobject]@{ Name = "generated-git-diff"; Tool = "Bash"; Command = "git diff -- server/demo/xbean/User.java"; Denied = $false },
    [pscustomobject]@{ Name = "normal-python-read"; Tool = "Bash"; Command = 'python -c "open(''.codex/README.md'', ''r'').read()"'; Denied = $false },
    [pscustomobject]@{ Name = "bom-prefixed-input"; Tool = "Bash"; Command = 'Get-Content .codex/README.md'; Denied = $false; PrefixBom = $true }
)

$shells = New-Object System.Collections.Generic.List[string]
foreach ($shellName in @("powershell.exe", "pwsh.exe")) {
    $command = Get-Command $shellName -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        [void]$shells.Add($command.Source)
    }
}
if ($shells.Count -eq 0) {
    throw "Neither powershell.exe nor pwsh.exe is available."
}

$results = New-Object System.Collections.Generic.List[object]
$failures = New-Object System.Collections.Generic.List[string]

foreach ($shell in $shells) {
    foreach ($case in $cases) {
        $toolInput = if ($case.PSObject.Properties.Name -contains "Input") {
            $case.Input
        } else {
            [ordered]@{ command = [string]$case.Command }
        }
        $payload = [ordered]@{
            hook_event_name = "PreToolUse"
            tool_name = [string]$case.Tool
            tool_input = $toolInput
        } | ConvertTo-Json -Depth 12 -Compress

        if (($case.PSObject.Properties.Name -contains "PrefixBom") -and [bool]$case.PrefixBom) {
            $payload = [string][char]0xFEFF + $payload
        }

        $run = Invoke-HookProcess -ShellPath $shell -ScriptPath $hookPath -InputJson $payload
        $timingError = [string]$run.TimingError
        $cpuTimingError = [string]$run.CpuTimingError
        $elapsedMilliseconds = [long]$run.ElapsedMilliseconds
        $decisionCpuMilliseconds = [long]$run.DecisionCpuMilliseconds
        $denied = $false
        $parseError = ""
        if (-not [string]::IsNullOrWhiteSpace($run.Stdout)) {
            try {
                $parsed = $run.Stdout | ConvertFrom-Json -ErrorAction Stop
                $specific = $parsed.hookSpecificOutput
                $denied = ([string]$specific.permissionDecision -eq "deny")
            } catch {
                $parseError = $_.Exception.Message
            }
        }

        $passed = ($run.ExitCode -eq 0 -and [string]::IsNullOrWhiteSpace($run.Stderr) -and [string]::IsNullOrWhiteSpace($timingError) -and [string]::IsNullOrWhiteSpace($cpuTimingError) -and [string]::IsNullOrWhiteSpace($parseError) -and $denied -eq [bool]$case.Denied)
        if (-not $passed) {
            [void]$failures.Add("$([System.IO.Path]::GetFileName($shell))/$($case.Name): expected_denied=$($case.Denied) actual_denied=$denied exit=$($run.ExitCode) stderr=$($run.Stderr) timing_error=$timingError cpu_timing_error=$cpuTimingError parse_error=$parseError")
        }

        [void]$results.Add([pscustomobject][ordered]@{
            shell = [System.IO.Path]::GetFileName($shell)
            name = [string]$case.Name
            expected_denied = [bool]$case.Denied
            actual_denied = $denied
            exit_code = $run.ExitCode
            process_ms = [long]$run.ProcessElapsedMilliseconds
            elapsed_ms = $elapsedMilliseconds
            decision_cpu_ms = $decisionCpuMilliseconds
            elapsed_samples_ms = @($elapsedMilliseconds)
            passed = $passed
        })
    }
}

$performanceSampleCount = 7
$decisionCpuBudgetMilliseconds = 250
$performanceResults = New-Object System.Collections.Generic.List[object]
$performancePayload = [ordered]@{
    hook_event_name = "PreToolUse"
    tool_name = "apply_patch"
    tool_input = $depth6Input
} | ConvertTo-Json -Depth 12 -Compress
foreach ($shell in $shells) {
    $shellName = [System.IO.Path]::GetFileName($shell)
    [void](Invoke-HookProcess -ShellPath $shell -ScriptPath $hookPath -InputJson $performancePayload)
    $cpuSamples = New-Object System.Collections.Generic.List[long]
    $wallSamples = New-Object System.Collections.Generic.List[long]
    $sampleErrors = New-Object System.Collections.Generic.List[string]
    foreach ($sampleIndex in 1..$performanceSampleCount) {
        $sample = Invoke-HookProcess -ShellPath $shell -ScriptPath $hookPath -InputJson $performancePayload
        if ($sample.ExitCode -ne 0 -or -not [string]::IsNullOrWhiteSpace($sample.Stderr) -or -not [string]::IsNullOrWhiteSpace($sample.TimingError) -or -not [string]::IsNullOrWhiteSpace($sample.CpuTimingError)) {
            [void]$sampleErrors.Add("sample=$sampleIndex exit=$($sample.ExitCode) stderr=$($sample.Stderr) timing_error=$($sample.TimingError) cpu_timing_error=$($sample.CpuTimingError)")
            continue
        }
        [void]$cpuSamples.Add([long]$sample.DecisionCpuMilliseconds)
        [void]$wallSamples.Add([long]$sample.ProcessElapsedMilliseconds)
    }
    $sortedCpu = @($cpuSamples | Sort-Object)
    $p95Cpu = if ($sortedCpu.Count -gt 0) {
        $p95Index = [Math]::Max(0, [Math]::Ceiling($sortedCpu.Count * 0.95) - 1)
        [long]$sortedCpu[[int]$p95Index]
    } else {
        -1
    }
    $performancePassed = ($cpuSamples.Count -eq $performanceSampleCount -and $sampleErrors.Count -eq 0 -and $p95Cpu -ge 0 -and $p95Cpu -lt $decisionCpuBudgetMilliseconds)
    if (-not $performancePassed) {
        [void]$failures.Add("$shellName/decision-performance: samples=$($cpuSamples.Count)/$performanceSampleCount p95_cpu_ms=$p95Cpu budget_ms=$decisionCpuBudgetMilliseconds errors=$($sampleErrors -join '; ')")
    }
    [void]$performanceResults.Add([pscustomobject][ordered]@{
        shell = $shellName
        metric = "decision_cpu_p95"
        sample_count = $cpuSamples.Count
        budget_ms = $decisionCpuBudgetMilliseconds
        p95_cpu_ms = $p95Cpu
        cpu_samples_ms = $cpuSamples.ToArray()
        process_samples_ms = $wallSamples.ToArray()
        passed = $performancePassed
    })
}

$status = if ($failures.Count -eq 0) { "PASS" } else { "FAIL" }
$maxElapsedMilliseconds = if ($results.Count -gt 0) {
    [long](($results | Measure-Object -Property elapsed_ms -Maximum).Maximum)
} else {
    0
}
$maxDecisionCpuMilliseconds = if ($results.Count -gt 0) {
    [long](($results | Measure-Object -Property decision_cpu_ms -Maximum).Maximum)
} else {
    -1
}
$maxPerformanceP95CpuMilliseconds = if ($performanceResults.Count -gt 0) {
    [long](($performanceResults | Measure-Object -Property p95_cpu_ms -Maximum).Maximum)
} else {
    -1
}
$result = [pscustomobject][ordered]@{
    status = $status
    summary = "Codex PreToolUse hook matrix: shells=$($shells.Count) cases=$($results.Count) failures=$($failures.Count) max_decision_cpu_ms=$maxDecisionCpuMilliseconds performance_p95_cpu_ms=$maxPerformanceP95CpuMilliseconds"
    data = [pscustomobject][ordered]@{
        hook = $hookPath
        shell_count = $shells.Count
        case_count = $results.Count
        max_elapsed_ms = $maxElapsedMilliseconds
        max_decision_cpu_ms = $maxDecisionCpuMilliseconds
        performance_p95_cpu_ms = $maxPerformanceP95CpuMilliseconds
        performance = $performanceResults.ToArray()
        failures = $failures.ToArray()
        cases = $results.ToArray()
    }
    issues = $failures.ToArray()
}

if ($Json) {
    $result | ConvertTo-Json -Depth 8
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

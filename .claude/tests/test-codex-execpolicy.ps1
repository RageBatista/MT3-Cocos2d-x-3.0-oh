[CmdletBinding()]
param(
    [string]$ProjectRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
} else {
    $ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
}

$rulesPath = Join-Path $ProjectRoot ".codex\rules\mt3-guardrails.rules"
$projectCodexPath = Join-Path $ProjectRoot "tools\codex\node_modules\.bin\codex.ps1"
$codexCommandPath = if (Test-Path -LiteralPath $projectCodexPath -PathType Leaf) {
    $projectCodexPath
} else {
    (Get-Command codex -ErrorAction Stop).Source
}

if (-not (Test-Path -LiteralPath $rulesPath -PathType Leaf)) {
    throw "Execpolicy rules file not found: $rulesPath"
}

$cases = @(
    [pscustomobject]@{ Name = "legacy-direct-backslash"; Expected = "forbidden"; Tokens = @(".\client\Build-MT3-v120.ps1", "-Configuration", "Release") },
    [pscustomobject]@{ Name = "legacy-powershell-bypass"; Expected = "forbidden"; Tokens = @("powershell.exe", "-ExecutionPolicy", "Bypass", "-File", ".\client\Build-MT3-v120.ps1", "-Configuration", "Release") },
    [pscustomobject]@{ Name = "legacy-pwsh-noprofile"; Expected = "forbidden"; Tokens = @("pwsh", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "./client/Build-MT3-v120.ps1") },
    [pscustomobject]@{ Name = "legacy-cmd-wrapper"; Expected = "forbidden"; Tokens = @("cmd.exe", "/c", ".\client\Build-MT3-v120.ps1", "-Configuration", "Release") },
    [pscustomobject]@{ Name = "gradle-direct"; Expected = "forbidden"; Tokens = @("gradle", "assembleDebug") },
    [pscustomobject]@{ Name = "gradlew-bat"; Expected = "forbidden"; Tokens = @("gradlew.bat", "assembleDebug") },
    [pscustomobject]@{ Name = "gradlew-relative"; Expected = "forbidden"; Tokens = @(".\gradlew", "assembleDebug") },
    [pscustomobject]@{ Name = "gradlew-cmd-wrapper"; Expected = "forbidden"; Tokens = @("cmd", "/c", "gradlew.bat", "assembleDebug") },
    [pscustomobject]@{ Name = "gradlew-cmd-call-wrapper"; Expected = "forbidden"; Tokens = @("cmd", "/c", "call", "gradlew.bat", "assembleDebug") },
    [pscustomobject]@{ Name = "maven-direct"; Expected = "forbidden"; Tokens = @("mvn.cmd", "package") },
    [pscustomobject]@{ Name = "maven-wrapper"; Expected = "forbidden"; Tokens = @("mvnw.cmd", "package") },
    [pscustomobject]@{ Name = "maven-relative"; Expected = "forbidden"; Tokens = @(".\mvnw", "package") },
    [pscustomobject]@{ Name = "maven-cmd-wrapper"; Expected = "forbidden"; Tokens = @("cmd.exe", "/c", "mvnw.cmd", "package") },
    [pscustomobject]@{ Name = "maven-cmd-call-wrapper"; Expected = "forbidden"; Tokens = @("cmd.exe", "/c", "call", "mvnw.cmd", "package") },
    [pscustomobject]@{ Name = "msbuild-manual"; Expected = "prompt"; Tokens = @("msbuild.exe", "client\MT3Win32App\mt3.win32.vcxproj") },
    [pscustomobject]@{ Name = "set-content"; Expected = "prompt"; Tokens = @("Set-Content", "path.txt", "value") },
    [pscustomobject]@{ Name = "set-content-lowercase"; Expected = "prompt"; Tokens = @("set-content", "path.txt", "value") },
    [pscustomobject]@{ Name = "git-add-all"; Expected = "prompt"; Tokens = @("git", "add", "-A") },
    [pscustomobject]@{ Name = "git-worktree-add-all"; Expected = "prompt"; Tokens = @("git", "-C", ".", "add", "-A") },
    [pscustomobject]@{ Name = "git-clean"; Expected = "prompt"; Tokens = @("git", "clean", "-fdx") },
    [pscustomobject]@{ Name = "git-sparse-checkout-disable"; Expected = "prompt"; Tokens = @("git", "sparse-checkout", "disable") },
    [pscustomobject]@{ Name = "canonical-win32"; Expected = "allow"; Tokens = @("tools/scripts/Build-MT3-Exe-Canonical.ps1", "-Configuration", "Release") },
    [pscustomobject]@{ Name = "canonical-android"; Expected = "allow"; Tokens = @("powershell.exe", "-File", "tools/scripts/Build-Android-Locojoy-WithGate.ps1", "-PlanOnly", "-Json") },
    [pscustomobject]@{ Name = "canonical-ant"; Expected = "allow"; Tokens = @("ant", "-f", "server/server/game_server/build.xml", "dist") },
    [pscustomobject]@{ Name = "cegui-dry-run"; Expected = "allow"; Tokens = @("git", "add", "-n", "--", "tools/CEGUI-0.7.1") }
)

$results = New-Object System.Collections.Generic.List[object]
$failures = New-Object System.Collections.Generic.List[string]

foreach ($case in $cases) {
    $caseTokens = @($case.Tokens)
    $raw = @(& $codexCommandPath execpolicy check --rules $rulesPath @caseTokens 2>&1)
    $exitCode = $LASTEXITCODE
    $text = [string]::Join("`n", @($raw | ForEach-Object { [string]$_ }))

    $actual = ""
    $parseError = ""
    try {
        $parsed = $text | ConvertFrom-Json -ErrorAction Stop
        if ($parsed.PSObject.Properties.Name -contains "decision") {
            $actual = [string]$parsed.decision
        } else {
            $actual = "allow"
        }
    } catch {
        $parseError = $_.Exception.Message
        $actual = "invalid-json"
    }

    $passed = ($exitCode -eq 0 -and $actual -eq [string]$case.Expected)
    if (-not $passed) {
        [void]$failures.Add("$($case.Name): expected=$($case.Expected) actual=$actual exit=$exitCode parse_error=$parseError")
    }

    [void]$results.Add([pscustomobject][ordered]@{
        name = [string]$case.Name
        expected = [string]$case.Expected
        actual = $actual
        exit_code = $exitCode
        passed = $passed
    })
}

$status = if ($failures.Count -eq 0) { "PASS" } else { "FAIL" }
$result = [pscustomobject][ordered]@{
    status = $status
    summary = "Codex execpolicy matrix: cases=$($cases.Count) failures=$($failures.Count)"
    data = [pscustomobject][ordered]@{
        rules = $rulesPath
        case_count = $cases.Count
        executed_count = $results.Count
        failures = $failures.ToArray()
        cases = $results.ToArray()
    }
    issues = $failures.ToArray()
}

if ($Json) {
    $result | ConvertTo-Json -Depth 8
} else {
    Write-Output $result.summary
    foreach ($item in $results) {
        Write-Output ("{0}: expected={1} actual={2} passed={3}" -f $item.name, $item.expected, $item.actual, $item.passed)
    }
}

if ($status -eq "FAIL") {
    exit 1
}
exit 0

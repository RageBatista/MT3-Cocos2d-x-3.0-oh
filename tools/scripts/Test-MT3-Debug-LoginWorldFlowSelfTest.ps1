[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRootPath {
    param([string]$InputPath)

    if (-not [string]::IsNullOrWhiteSpace($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
}

function New-TempCaseDirectory {
    param([string]$Name)

    $root = Join-Path ([System.IO.Path]::GetTempPath()) ("mt3-login-world-flow-selftest-{0}-{1}" -f $Name, [System.Guid]::NewGuid().ToString("N"))
    [System.IO.Directory]::CreateDirectory($root) | Out-Null
    return $root
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Text
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        [System.IO.Directory]::CreateDirectory($parent) | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

function Invoke-FlowScript {
    param(
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [Parameter(Mandatory = $true)][string]$LogDirectory,
        [Parameter(Mandatory = $true)][string]$ReportPath,
        [string[]]$AdditionalArguments = @()
    )

    $arguments = @("-NoLaunch", "-LogDirectory", $LogDirectory, "-ReportPath", $ReportPath, "-Json") + $AdditionalArguments
    $output = @(& powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @arguments 2>&1)
    $exitCode = $LASTEXITCODE
    $text = ($output | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    $json = $null
    try {
        $json = $text | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw "Unable to parse flow script JSON output. exit=$exitCode output=$text"
    }

    return [pscustomobject][ordered]@{
        exit_code = $exitCode
        output = $text
        json = $json
    }
}

function Assert-Equal {
    param(
        [object]$Actual,
        [object]$Expected,
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw ("{0} actual={1} expected={2}" -f $Message, $Actual, $Expected)
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

$repoRootPath = Resolve-RepoRootPath -InputPath $RepoRoot
$flowScript = Join-Path $repoRootPath "tools\scripts\Test-MT3-Debug-LoginWorldFlow.ps1"
if (-not (Test-Path -LiteralPath $flowScript -PathType Leaf)) {
    throw "Missing production flow script: $flowScript"
}

$checks = New-Object System.Collections.Generic.List[object]

$passDir = New-TempCaseDirectory -Name "pass"
$passLog = @"
2026-06-20 12:00:01:(Info) LUA LoginQuickDialog.getInstanceAndShow enter
2026-06-20 12:00:02:(Info) [LoginHTTP] request start register=0 url=http://127.0.0.1/login accountLen=6 postLen=42
2026-06-20 12:00:03:(Info) [LoginHTTP] request success register=0 code=1 accountLen=6 sessionLen=32
LUA:2026-06-20 12:00:04:(Info) [LoginFlow] LoginGame CreateConnection before serverid=1 servername=test area=test host=127.0.0.1 port=10000 connectAccountLen=6 hasComma=false
2026-06-20 12:00:04:(Info) [LoginFlow] CreateConnection enter accountLen=6 hasComma=0 host=127.0.0.1 port=10000 serverid=1 force=1 type=0 ct=0 suffixLen=0 channelLen=0
2026-06-20 12:00:04:(Info) [LoginFlow] CreateConnection exit netConnection=1
2026-06-20 12:00:05:(Info) [LoginFlow] LoginManager::LoginIn send CRoleList accountLen=6
2026-06-20 12:00:06:(Info) enter SRoleList create
2026-06-20 12:00:06:(Info) [LoginFlow] LoginManager::UpdateRoleList roleNum=1 preRole=123456
2026-06-20 12:00:07:(Info) [LoginFlow] send CEnterWorld roleid=123456 rolesnum=30
2026-06-20 12:00:08:(Info) enter SEnterWorld create
2026-06-20 12:00:09:(Info) [LoginFlow] GameScene sent CAfterEnterWorld
"@
Write-Utf8NoBom -Path (Join-Path $passDir "mt3_history.log") -Text $passLog
$passReport = Join-Path $passDir "report.json"
$passResult = Invoke-FlowScript -ScriptPath $flowScript -LogDirectory $passDir -ReportPath $passReport
Assert-Equal -Actual $passResult.exit_code -Expected 0 -Message "complete flow should exit 0"
Assert-Equal -Actual ([string]$passResult.json.status) -Expected "PASS" -Message "complete flow should PASS"
Assert-Equal -Actual ([string]$passResult.json.data.blocked_stage) -Expected "" -Message "complete flow should not have blocked stage"
[void]$checks.Add([pscustomobject][ordered]@{ name = "complete_flow_fixture"; status = "PASS"; report = $passReport })

$failDir = New-TempCaseDirectory -Name "login-http-fail"
$failLog = @"
2026-06-20 12:10:01:(Info) LUA LoginQuickDialog.getInstanceAndShow enter
2026-06-20 12:10:02:(Info) [LoginHTTP] request start register=0 url=http://127.0.0.1/login accountLen=6 postLen=42
2026-06-20 12:10:03:(Warn) [LoginHTTP] request failed register=0 http=200 code=1 bodyLen=91 accountLen=6
"@
Write-Utf8NoBom -Path (Join-Path $failDir "mt3_history.log") -Text $failLog
$failReport = Join-Path $failDir "report.json"
$failResult = Invoke-FlowScript -ScriptPath $flowScript -LogDirectory $failDir -ReportPath $failReport
Assert-Equal -Actual $failResult.exit_code -Expected 1 -Message "failed login HTTP flow should exit 1"
Assert-Equal -Actual ([string]$failResult.json.status) -Expected "FAIL" -Message "failed login HTTP flow should FAIL"
Assert-Equal -Actual ([string]$failResult.json.data.blocked_stage) -Expected "login_http_success" -Message "failed login HTTP flow should block at login_http_success"
Assert-True -Condition (([string]$failResult.json.summary) -match "LoginHTTP") -Message "failed login summary should mention LoginHTTP"
[void]$checks.Add([pscustomobject][ordered]@{ name = "login_http_failure_fixture"; status = "PASS"; report = $failReport })

$mixedDir = New-TempCaseDirectory -Name "mixed-history"
$mixedLog = @"
2026-06-20 12:00:01:(Info) LUA LoginQuickDialog.getInstanceAndShow enter
2026-06-20 12:00:02:(Info) [LoginHTTP] request start register=0 url=http://127.0.0.1/login accountLen=6 postLen=42
2026-06-20 12:00:03:(Info) [LoginHTTP] request success register=0 code=1 accountLen=6 sessionLen=32
2026-06-20 12:00:04:(Info) [LoginFlow] LoginGame CreateConnection before serverid=1 servername=test area=test host=127.0.0.1 port=10000 connectAccountLen=6 hasComma=false
2026-06-20 12:00:04:(Info) [LoginFlow] CreateConnection exit netConnection=1
2026-06-20 12:00:05:(Info) [LoginFlow] LoginManager::LoginIn send CRoleList accountLen=6
2026-06-20 12:00:06:(Info) [LoginFlow] LoginManager::UpdateRoleList roleNum=1 preRole=123456
2026-06-20 12:00:07:(Info) [LoginFlow] send CEnterWorld roleid=123456 rolesnum=30
2026-06-20 12:00:08:(Info) enter SEnterWorld create
2026-06-20 12:00:09:(Info) [LoginFlow] GameScene sent CAfterEnterWorld
2026-06-20 13:00:01:(Info) LUA LoginQuickDialog.getInstanceAndShow enter
2026-06-20 13:00:02:(Info) [LoginHTTP] request start register=0 url=http://127.0.0.1/login accountLen=6 postLen=42
2026-06-20 13:00:03:(Warn) [LoginHTTP] request failed register=0 http=200 code=1 bodyLen=91 accountLen=6
"@
Write-Utf8NoBom -Path (Join-Path $mixedDir "mt3_history.log") -Text $mixedLog
$mixedReport = Join-Path $mixedDir "report.json"
$mixedResult = Invoke-FlowScript -ScriptPath $flowScript -LogDirectory $mixedDir -ReportPath $mixedReport -AdditionalArguments @("-SinceLocalTime", "2026-06-20 13:00:00")
Assert-Equal -Actual $mixedResult.exit_code -Expected 1 -Message "time-windowed mixed history should exit 1 for the latest failed attempt"
Assert-Equal -Actual ([string]$mixedResult.json.status) -Expected "FAIL" -Message "time-windowed mixed history should FAIL"
Assert-Equal -Actual ([string]$mixedResult.json.data.blocked_stage) -Expected "login_http_success" -Message "time-windowed mixed history should ignore old successful markers"
[void]$checks.Add([pscustomobject][ordered]@{ name = "time_window_mixed_history_fixture"; status = "PASS"; report = $mixedReport })

$payload = [pscustomobject][ordered]@{
    status = "PASS"
    script = "Test-MT3-Debug-LoginWorldFlowSelfTest.ps1"
    summary = "MT3 Debug login/world flow verifier self-test passed."
    data = [pscustomobject][ordered]@{
        repo_root = $repoRootPath
        production_script = $flowScript
        checks = $checks.ToArray()
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 6
}
else {
    Write-Host ("STATUS: {0}" -f $payload.status)
    Write-Host ("SUMMARY: {0}" -f $payload.summary)
    foreach ($check in $checks) {
        Write-Host ("CHECK: {0} [{1}] {2}" -f $check.name, $check.status, $check.report)
    }
}

exit 0

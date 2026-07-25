[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [ValidateSet("Debug")]
    [string]$Configuration = "Debug",
    [string]$ExePath = "",
    [string]$LogDirectory = "",
    [ValidateRange(1, 3600)][int]$TimeoutSeconds = 600,
    [ValidateRange(100, 10000)][int]$PollIntervalMilliseconds = 1000,
    [string]$ReportPath = "build_logs\mt3-debug-login-world-flow.json",
    [datetime]$SinceLocalTime = [datetime]::MinValue,
    [switch]$NoLaunch,
    [switch]$AttachExisting,
    [switch]$KeepProcess,
    [switch]$LatestRunOnly,
    [switch]$AllowIncomplete,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Resolve-RepoRootPath {
    param([string]$InputPath)

    if (-not [string]::IsNullOrWhiteSpace($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
}

function Resolve-FullPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$BaseDirectory
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return ""
    }

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $PathValue))
}

function Ensure-ParentDirectory {
    param([Parameter(Mandatory = $true)][string]$FilePath)

    $parent = Split-Path -Parent $FilePath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        [System.IO.Directory]::CreateDirectory($parent) | Out-Null
    }
}

function Get-ProcessExecutablePath {
    param([Parameter(Mandatory = $true)][System.Diagnostics.Process]$Process)

    try {
        return [string]$Process.MainModule.FileName
    }
    catch {
        return ""
    }
}

function Get-ExistingMT3Process {
    param([Parameter(Mandatory = $true)][string]$ResolvedExePath)

    $matches = New-Object System.Collections.Generic.List[object]
    foreach ($proc in @(Get-Process -Name "MT3" -ErrorAction SilentlyContinue)) {
        $path = Get-ProcessExecutablePath -Process $proc
        if (-not [string]::IsNullOrWhiteSpace($path) -and
            [System.IO.Path]::GetFullPath($path).Equals($ResolvedExePath, [System.StringComparison]::OrdinalIgnoreCase)) {
            [void]$matches.Add($proc)
        }
    }

    return $matches.ToArray()
}

function Get-LogFileCandidates {
    param([Parameter(Mandatory = $true)][string]$Directory)

    $names = @(
        "mt3_ct.log",
        "mt3_history.log",
        "mt3.log",
        "startup_bootstrap.log",
        "LuaDebugLog.txt",
        "CEGUI_ct.log",
        "CEGUI_history.log",
        "CEGUI.log"
    )

    $files = New-Object System.Collections.Generic.List[string]
    foreach ($name in $names) {
        $path = Join-Path $Directory $name
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            [void]$files.Add([System.IO.Path]::GetFullPath($path))
        }
    }

    if (Test-Path -LiteralPath $Directory -PathType Container) {
        Get-ChildItem -LiteralPath $Directory -File -Force |
            Where-Object { $_.Extension -in ".log", ".txt" } |
            ForEach-Object {
                if (-not $files.Contains($_.FullName)) {
                    [void]$files.Add($_.FullName)
                }
            }
    }

    return $files.ToArray()
}

function Get-LogOffsets {
    param(
        [Parameter(Mandatory = $true)][string[]]$Files,
        [bool]$FromBeginning
    )

    $offsets = @{}
    foreach ($file in $Files) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            $offsets[$file] = 0L
            continue
        }

        $item = Get-Item -LiteralPath $file
        $offsets[$file] = if ($FromBeginning) { 0L } else { [Int64]$item.Length }
    }

    return $offsets
}

function Read-FileSegmentUtf8 {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][Int64]$Offset
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return ""
    }

    $stream = $null
    try {
        $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $safeOffset = $Offset
        if ($safeOffset -lt 0 -or $safeOffset -gt $stream.Length) {
            $safeOffset = 0L
        }

        [void]$stream.Seek($safeOffset, [System.IO.SeekOrigin]::Begin)
        $remaining = [int]($stream.Length - $safeOffset)
        if ($remaining -le 0) {
            return ""
        }

        $buffer = New-Object byte[] $remaining
        $read = $stream.Read($buffer, 0, $buffer.Length)
        if ($read -le 0) {
            return ""
        }

        if ($read -ne $buffer.Length) {
            $actual = New-Object byte[] $read
            [Array]::Copy($buffer, $actual, $read)
            $buffer = $actual
        }

        return [System.Text.Encoding]::UTF8.GetString($buffer)
    }
    finally {
        if ($stream -ne $null) {
            $stream.Dispose()
        }
    }
}

function Read-ObservedLogs {
    param(
        [Parameter(Mandatory = $true)][string]$Directory,
        [Parameter(Mandatory = $true)][hashtable]$Offsets
    )

    $currentFiles = @(Get-LogFileCandidates -Directory $Directory)
    foreach ($file in $currentFiles) {
        if (-not $Offsets.ContainsKey($file)) {
            $Offsets[$file] = 0L
        }
    }

    $chunks = New-Object System.Collections.Generic.List[string]
    foreach ($file in @($Offsets.Keys | Sort-Object)) {
        $text = Read-FileSegmentUtf8 -Path $file -Offset ([Int64]$Offsets[$file])
        if (-not [string]::IsNullOrEmpty($text)) {
            [void]$chunks.Add(("### MT3_LOG_FILE: {0} ###" -f $file))
            [void]$chunks.Add($text)
        }
    }

    return ($chunks.ToArray() -join [Environment]::NewLine)
}

function Get-LogLineTimestamp {
    param([string]$Line)

    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $null
    }

    if ($Line -match '^### MT3_LOG_FILE:') {
        return $null
    }

    $stamp = ""
    if ($Line -match '^\[(?<ts>\d{4}-\d{1,2}-\d{1,2}\s+\d{1,2}:\d{2}:\d{2}(?:\.\d{1,7})?)\]') {
        $stamp = $Matches.ts
    }
    elseif ($Line -match '^(?:LUA:)?(?<ts>\d{4}-\d{1,2}-\d{1,2}\s+\d{1,2}:\d{2}(?::\d{2})?)') {
        $stamp = $Matches.ts
    }

    if ([string]::IsNullOrWhiteSpace($stamp)) {
        return $null
    }

    [string[]]$formats = @(
        "yyyy-MM-dd HH:mm:ss.FFFFFFF",
        "yyyy-M-d H:mm:ss.FFFFFFF",
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-M-d H:mm:ss",
        "yyyy-MM-dd HH:mm",
        "yyyy-M-d H:mm"
    )
    $parsed = [datetime]::MinValue
    $ok = [datetime]::TryParseExact(
        $stamp,
        $formats,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::AssumeLocal,
        [ref]$parsed
    )

    if ($ok) {
        return $parsed
    }

    return $null
}

function Get-LatestBootstrapTimestamp {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    $latest = [datetime]::MinValue
    if ([string]::IsNullOrEmpty($Text)) {
        return $latest
    }

    foreach ($line in ($Text -split "`r?`n")) {
        if ($line -notmatch '\[LJFM\]\s+InitFileList begin') {
            continue
        }
        $timestamp = Get-LogLineTimestamp -Line $line
        if ($timestamp -ne $null -and $timestamp -gt $latest) {
            $latest = $timestamp
        }
    }

    return $latest
}

function Select-ObservedLogsSince {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $true)][datetime]$Since
    )

    if ($Since -le [datetime]::MinValue -or [string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    $selected = New-Object System.Collections.Generic.List[string]
    $currentTimestamp = $null
    foreach ($line in ($Text -split "`r?`n")) {
        if ($line -match '^### MT3_LOG_FILE:') {
            $currentTimestamp = $null
            continue
        }

        $timestamp = Get-LogLineTimestamp -Line $line
        if ($timestamp -ne $null) {
            $currentTimestamp = $timestamp
        }

        if ($currentTimestamp -ne $null -and $currentTimestamp -ge $Since) {
            [void]$selected.Add($line)
        }
    }

    return ($selected.ToArray() -join [Environment]::NewLine)
}

function Apply-LogTimeWindow {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [datetime]$Since,
        [bool]$UseLatestRun
    )

    $effectiveSince = $Since
    if ($UseLatestRun) {
        $latest = Get-LatestBootstrapTimestamp -Text $Text
        if ($latest -gt $effectiveSince) {
            $effectiveSince = $latest
        }
    }

    $filtered = Select-ObservedLogsSince -Text $Text -Since $effectiveSince
    return [pscustomobject][ordered]@{
        text = $filtered
        effective_since = $effectiveSince
    }
}

function Redact-LogLine {
    param([string]$Line)

    if ([string]::IsNullOrEmpty($Line)) {
        return ""
    }

    $redacted = $Line
    $redacted = $redacted -replace '(?i)(password|passwd|pwd|token|session|sid|key)=([^&\s]+)', '$1=<redacted>'
    $redacted = $redacted -replace '(?i)(url=)(\S+)', '$1<redacted-url>'
    $redacted = $redacted -replace '(?i)(host=)([^ \t]+)', '$1<redacted-host>'
    $redacted = $redacted -replace '(?i)(gip=)([^ \t]+)', '$1<redacted-host>'
    if ($redacted.Length -gt 360) {
        $redacted = $redacted.Substring(0, 360) + "..."
    }
    return $redacted
}

function Find-FirstPatternMatch {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $true)][string[]]$Patterns
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return $null
    }

    $lines = $Text -split "`r?`n"
    foreach ($line in $lines) {
        foreach ($pattern in $Patterns) {
            if ($line -match $pattern) {
                return [pscustomobject][ordered]@{
                    pattern = $pattern
                    line = (Redact-LogLine -Line $line)
                }
            }
        }
    }

    return $null
}

function Get-StageDefinitions {
    return @(
        ([pscustomobject][ordered]@{
            name = "login_ui_ready"
            summary = "Login UI is ready."
            patterns = @(
                'LoginQuickDialog\.getInstanceAndShow',
                'LoginQuickDialog\.OnCreate',
                'SwitchAccountDialog show',
                '\[LJFM\] InitFileList'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "login_http_started"
            summary = "Account LoginHTTP request started."
            patterns = @(
                '\[LoginHTTP\]\s+request start',
                '\[LoginHTTP\]\s+request failed',
                '\[LoginHTTP\]\s+request error'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "login_http_success"
            summary = "Account LoginHTTP succeeded and returned a game credential."
            patterns = @('\[LoginHTTP\]\s+request success')
        }),
        ([pscustomobject][ordered]@{
            name = "game_server_connection_started"
            summary = "Game server connection started."
            patterns = @(
                '\[LoginFlow\]\s+LoginGame CreateConnection before',
                '\[LoginFlow\]\s+CreateConnection enter'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "game_server_connection_ready"
            summary = "Game server connection object is ready."
            patterns = @('\[LoginFlow\]\s+CreateConnection exit netConnection=1')
        }),
        ([pscustomobject][ordered]@{
            name = "role_list_requested"
            summary = "CRoleList request was sent."
            patterns = @(
                'LoginManager::LoginIn send CRoleList',
                'send\s*\(\s*fire\.pb\.CRoleList',
                '\bCRoleList\b'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "role_list_received"
            summary = "SRoleList was received and role selection or auto-enter decision started."
            patterns = @(
                'LoginManager::UpdateRoleList roleNum=',
                'enter SRoleList create',
                '\bSRoleList\b'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "enter_world_requested"
            summary = "CEnterWorld request was sent."
            patterns = @(
                'send CEnterWorld',
                '\bCEnterWorld\b',
                'SetWaitForEnterWorldState\s*\(\s*true\s*\)',
                'SetWaitToEnterWorld\s*\(\s*true\s*\)',
                'BeginDrawServantIntro',
                'DrawLoginBar\(20\)'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "enter_world_ack"
            summary = "SEnterWorld was received or map transition started."
            patterns = @(
                'enter SEnterWorld create',
                '\bSEnterWorld\b',
                'GameScene::ChangeMap',
                '\bChangeMap\b',
                'AddMainCharacter'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "world_ready"
            summary = "World scene reached a ready marker such as CAfterEnterWorld."
            patterns = @(
                'CAfterEnterWorld',
                'AfterEnterWorld',
                'GameScene sent CAfterEnterWorld',
                'ShowHide\.ChangeMap',
                'EndLoadMap',
                'AddMainCharacter'
            )
        })
    )
}

function Get-FailureDefinitions {
    return @(
        ([pscustomobject][ordered]@{
            name = "login_http_failed"
            stage = "login_http_success"
            override_blocked_stage = $true
            patterns = @(
                '\[LoginHTTP\]\s+request failed',
                '\[LoginHTTP\]\s+request error',
                '\[LoginHTTP\]\s+request skipped'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "connection_failed"
            stage = "game_server_connection_ready"
            override_blocked_stage = $true
            patterns = @(
                'CreateConnection skipped',
                'after CreateConnection: net connection is nil',
                'HandleLoginBtnClick blocked: network disconnected'
            )
        }),
        ([pscustomobject][ordered]@{
            name = "exited_before_world_ready"
            stage = "world_ready"
            override_blocked_stage = $false
            patterns = @('\[LoginFlow\]\s+ExitGame enter')
        }),
        ([pscustomobject][ordered]@{
            name = "runtime_crash_marker"
            stage = "world_ready"
            override_blocked_stage = $true
            patterns = @(
                'Unhandled exception',
                'Access violation',
                'Debug Assertion Failed',
                'FATAL EXCEPTION',
                'SIGSEGV'
            )
        })
    )
}

function Test-FlowStages {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$ObservedText)

    $stageResults = New-Object System.Collections.Generic.List[object]
    $blockedStage = ""
    $lastReached = ""

    foreach ($stage in @(Get-StageDefinitions)) {
        $match = Find-FirstPatternMatch -Text $ObservedText -Patterns ([string[]]$stage.patterns)
        $status = if ($match -ne $null) { "PASS" } else { "PENDING" }
        if ($status -eq "PASS") {
            $lastReached = [string]$stage.name
        }
        elseif ([string]::IsNullOrWhiteSpace($blockedStage)) {
            $blockedStage = [string]$stage.name
        }

        [void]$stageResults.Add([pscustomobject][ordered]@{
            name = [string]$stage.name
            status = $status
            summary = [string]$stage.summary
            pattern = if ($match) { [string]$match.pattern } else { "" }
            line = if ($match) { [string]$match.line } else { "" }
        })
    }

    $failureMarkers = New-Object System.Collections.Generic.List[object]
    foreach ($failure in @(Get-FailureDefinitions)) {
        $match = Find-FirstPatternMatch -Text $ObservedText -Patterns ([string[]]$failure.patterns)
        if ($match -ne $null) {
            [void]$failureMarkers.Add([pscustomobject][ordered]@{
                name = [string]$failure.name
                stage = [string]$failure.stage
                override_blocked_stage = [bool]$failure.override_blocked_stage
                pattern = [string]$match.pattern
                line = [string]$match.line
            })
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($blockedStage)) {
        foreach ($marker in $failureMarkers) {
            if (-not [bool]$marker.override_blocked_stage) {
                continue
            }
            $target = @($stageResults | Where-Object { $_.name -eq $marker.stage } | Select-Object -First 1)
            if ($target.Count -gt 0 -and $target[0].status -ne "PASS") {
                $blockedStage = [string]$marker.stage
                break
            }
        }
    }

    $passCount = @($stageResults | Where-Object { $_.status -eq "PASS" }).Count
    $allPassed = ($passCount -eq $stageResults.Count)

    return [pscustomobject][ordered]@{
        all_passed = $allPassed
        passed_stage_count = $passCount
        total_stage_count = $stageResults.Count
        last_reached_stage = $lastReached
        blocked_stage = $blockedStage
        stages = $stageResults.ToArray()
        failure_markers = $failureMarkers.ToArray()
    }
}

function Stop-OwnedProcess {
    param(
        [AllowNull()][System.Diagnostics.Process]$Process,
        [bool]$Keep
    )

    if ($Process -eq $null) {
        return [pscustomobject][ordered]@{
            action = "none"
            close_main_window = $false
            forced_stop = $false
            exit_code = $null
        }
    }

    try { $Process.Refresh() } catch { }
    if ($Keep -or $Process.HasExited) {
        return [pscustomobject][ordered]@{
            action = if ($Keep) { "kept" } else { "already_exited" }
            close_main_window = $false
            forced_stop = $false
            exit_code = if ($Process.HasExited) { $Process.ExitCode } else { $null }
        }
    }

    $closed = $false
    $forced = $false
    try {
        $closed = $Process.CloseMainWindow()
        if ($closed) {
            [void]$Process.WaitForExit(10000)
        }
        $Process.Refresh()
        if (-not $Process.HasExited) {
            Stop-Process -Id $Process.Id -Force
            $forced = $true
            [void]$Process.WaitForExit(5000)
        }
    }
    catch {
        try {
            if (-not $Process.HasExited) {
                Stop-Process -Id $Process.Id -Force
                $forced = $true
            }
        }
        catch {
        }
    }

    try { $Process.Refresh() } catch { }
    return [pscustomobject][ordered]@{
        action = "closed"
        close_main_window = $closed
        forced_stop = $forced
        exit_code = if ($Process.HasExited) { $Process.ExitCode } else { $null }
    }
}

$repoRootPath = Resolve-RepoRootPath -InputPath $RepoRoot
$defaultExe = Join-Path $repoRootPath ("client\resource\bin\{0}\MT3.exe" -f $Configuration)
$resolvedExePath = if ([string]::IsNullOrWhiteSpace($ExePath)) { $defaultExe } else { Resolve-FullPath -PathValue $ExePath -BaseDirectory $repoRootPath }
$defaultLogDir = Split-Path -Parent $resolvedExePath
$resolvedLogDir = if ([string]::IsNullOrWhiteSpace($LogDirectory)) { $defaultLogDir } else { Resolve-FullPath -PathValue $LogDirectory -BaseDirectory $repoRootPath }
$resolvedReportPath = Resolve-FullPath -PathValue $ReportPath -BaseDirectory $repoRootPath
Ensure-ParentDirectory -FilePath $resolvedReportPath

$exeExists = Test-Path -LiteralPath $resolvedExePath -PathType Leaf
if (-not $NoLaunch -and -not $exeExists) {
    throw "MT3.exe not found: $resolvedExePath"
}
if (-not (Test-Path -LiteralPath $resolvedLogDir -PathType Container)) {
    throw "Log directory not found: $resolvedLogDir"
}

$exeInfo = $null
$exeHash = ""
if ($exeExists) {
    $exeInfo = Get-Item -LiteralPath $resolvedExePath
    $exeHash = (Get-FileHash -LiteralPath $resolvedExePath -Algorithm SHA256).Hash
}

$logFiles = @(Get-LogFileCandidates -Directory $resolvedLogDir)
$fromBeginning = [bool]$NoLaunch
$offsets = Get-LogOffsets -Files $logFiles -FromBeginning $fromBeginning

$ownedProcess = $null
$attachedProcess = $null
$launchMode = "analyze_existing_logs"
$processStartError = ""

if (-not $NoLaunch) {
    $existing = @(Get-ExistingMT3Process -ResolvedExePath $resolvedExePath)
    if ($existing.Count -gt 0) {
        if (-not $AttachExisting) {
            throw "MT3.exe is already running from $resolvedExePath. Pass -AttachExisting to monitor it, or close it before running this verifier."
        }
        $attachedProcess = $existing[0]
        $launchMode = "attach_existing"
    }
    else {
        try {
            $ownedProcess = Start-Process -FilePath $resolvedExePath -WorkingDirectory $resolvedLogDir -PassThru
            $launchMode = "launch"
        }
        catch {
            $processStartError = $_.Exception.Message
            throw
        }
    }
}

$startedAt = Get-Date
$deadline = $startedAt.AddSeconds($TimeoutSeconds)
$observedText = ""
$effectiveSinceLocalTime = $SinceLocalTime
$flowResult = Test-FlowStages -ObservedText $observedText
$processExitedEarly = $false
$processExitCode = $null

try {
    if ($NoLaunch) {
        $observedText = Read-ObservedLogs -Directory $resolvedLogDir -Offsets $offsets
        $window = Apply-LogTimeWindow -Text $observedText -Since $SinceLocalTime -UseLatestRun ([bool]$LatestRunOnly)
        $observedText = [string]$window.text
        $effectiveSinceLocalTime = [datetime]$window.effective_since
        $flowResult = Test-FlowStages -ObservedText $observedText
    }
    else {
        while ((Get-Date) -lt $deadline) {
            Start-Sleep -Milliseconds $PollIntervalMilliseconds
            $observedText = Read-ObservedLogs -Directory $resolvedLogDir -Offsets $offsets
            $window = Apply-LogTimeWindow -Text $observedText -Since $SinceLocalTime -UseLatestRun ([bool]$LatestRunOnly)
            $observedText = [string]$window.text
            $effectiveSinceLocalTime = [datetime]$window.effective_since
            $flowResult = Test-FlowStages -ObservedText $observedText
            if ($flowResult.all_passed) {
                break
            }

            $procToCheck = if ($ownedProcess -ne $null) { $ownedProcess } else { $attachedProcess }
            if ($procToCheck -ne $null) {
                try { $procToCheck.Refresh() } catch { }
                if ($procToCheck.HasExited) {
                    $processExitedEarly = $true
                    $processExitCode = $procToCheck.ExitCode
                    break
                }
            }
        }
    }
}
finally {
}

$completedAt = Get-Date
$closeResult = Stop-OwnedProcess -Process $ownedProcess -Keep ([bool]$KeepProcess)

$status = if ($flowResult.all_passed) { "PASS" } else { if ($AllowIncomplete) { "WARN" } else { "FAIL" } }
$blockers = New-Object System.Collections.Generic.List[string]
if (-not $flowResult.all_passed) {
    $blockedStage = [string]$flowResult.blocked_stage
    if ([string]::IsNullOrWhiteSpace($blockedStage)) {
        $blockedStage = "unknown"
    }
    $stage = @($flowResult.stages | Where-Object { $_.name -eq $blockedStage } | Select-Object -First 1)
    $stageText = if ($stage.Count -gt 0) { [string]$stage[0].summary } else { $blockedStage }
    [void]$blockers.Add(("blocked_stage={0} ({1})" -f $blockedStage, $stageText))
}
foreach ($marker in @($flowResult.failure_markers)) {
    [void]$blockers.Add(("failure_marker={0} stage={1} line={2}" -f $marker.name, $marker.stage, $marker.line))
}
if ($processExitedEarly -and -not $flowResult.all_passed) {
    [void]$blockers.Add(("process_exited_before_flow_complete exit_code={0}" -f $processExitCode))
}
if (-not [string]::IsNullOrWhiteSpace($processStartError)) {
    [void]$blockers.Add(("process_start_error={0}" -f $processStartError))
}

$summary = if ($flowResult.all_passed) {
    "Debug MT3 login/world flow reached world_ready."
}
elseif (@($flowResult.failure_markers | Where-Object { $_.name -eq "login_http_failed" }).Count -gt 0) {
    "LoginHTTP failed before a successful login credential was observed."
}
elseif ($processExitedEarly) {
    "MT3 process exited before login/world flow completed."
}
else {
    "Debug MT3 login/world flow incomplete; blocked at $($flowResult.blocked_stage)."
}

$payload = [pscustomobject][ordered]@{
    status = $status
    script = "Test-MT3-Debug-LoginWorldFlow.ps1"
    summary = $summary
    generated_at = $startedAt.ToString("yyyy-MM-dd HH:mm:ss")
    completed_at = $completedAt.ToString("yyyy-MM-dd HH:mm:ss")
    data = [pscustomobject][ordered]@{
        repo_root = $repoRootPath
        configuration = $Configuration
        exe_path = if ($exeExists) { $resolvedExePath } else { "" }
        exe_length = if ($exeInfo -ne $null) { $exeInfo.Length } else { 0 }
        exe_sha256 = $exeHash
        log_directory = $resolvedLogDir
        launch_mode = $launchMode
        since_local_time = if ($SinceLocalTime -gt [datetime]::MinValue) { $SinceLocalTime.ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
        latest_run_only = [bool]$LatestRunOnly
        effective_since_local_time = if ($effectiveSinceLocalTime -gt [datetime]::MinValue) { $effectiveSinceLocalTime.ToString("yyyy-MM-dd HH:mm:ss") } else { "" }
        timeout_seconds = $TimeoutSeconds
        observed_seconds = [math]::Round(($completedAt - $startedAt).TotalSeconds, 3)
        process = [pscustomobject][ordered]@{
            pid = if ($ownedProcess -ne $null) { $ownedProcess.Id } elseif ($attachedProcess -ne $null) { $attachedProcess.Id } else { $null }
            owned = ($ownedProcess -ne $null)
            exited_before_complete = $processExitedEarly
            exit_code_before_close = $processExitCode
            close = $closeResult
        }
        passed_stage_count = $flowResult.passed_stage_count
        total_stage_count = $flowResult.total_stage_count
        last_reached_stage = $flowResult.last_reached_stage
        blocked_stage = $flowResult.blocked_stage
        stages = $flowResult.stages
        failure_markers = $flowResult.failure_markers
        blockers = $blockers.ToArray()
        report_path = $resolvedReportPath
    }
}

[System.IO.File]::WriteAllText($resolvedReportPath, (($payload | ConvertTo-Json -Depth 8) + [Environment]::NewLine), $utf8NoBom)

if ($Json) {
    $payload | ConvertTo-Json -Depth 8
}
else {
    Write-Host ("STATUS: {0}" -f $payload.status)
    Write-Host ("SUMMARY: {0}" -f $payload.summary)
    Write-Host ("EXE: {0}" -f $payload.data.exe_path)
    Write-Host ("LOG_DIR: {0}" -f $payload.data.log_directory)
    foreach ($stage in $payload.data.stages) {
        $line = if ([string]::IsNullOrWhiteSpace($stage.line)) { "" } else { " :: " + $stage.line }
        Write-Host ("STAGE: {0} [{1}] {2}{3}" -f $stage.name, $stage.status, $stage.summary, $line)
    }
    foreach ($blocker in $payload.data.blockers) {
        Write-Host ("BLOCKER: {0}" -f $blocker)
    }
    Write-Host ("REPORT: {0}" -f $resolvedReportPath)
}

if ($status -eq "FAIL") {
    exit 1
}
exit 0

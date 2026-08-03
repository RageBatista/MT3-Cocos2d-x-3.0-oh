[CmdletBinding()]
param(
    [ValidateSet("Release", "Debug", "Both")]
    [string]$Configuration = "Both",
    [ValidateSet("Win32")]
    [string]$Platform = "Win32",
    [ValidateSet("Legacy226", "Upgrade30")]
    [string]$EngineProfile = "Upgrade30",
    [switch]$Clean,
    [int]$MaxParallelJobs = 0,
    [switch]$StrictRuntimeAudit,
    [switch]$RunSmoke,
    [ValidateRange(5, 600)][int]$SmokeSeconds = 25,
    [switch]$RunP0Collectors,
    [string]$ReportPath = "build_logs/mt3-full-validation-report.json"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Resolve-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..\\..")).Path
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $PathValue))
}

function Ensure-ParentDirectory {
    param([Parameter(Mandatory = $true)][string]$FilePath)
    $parent = Split-Path -Parent $FilePath
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    $getFileHash = Get-Command Get-FileHash -ErrorAction SilentlyContinue
    if ($getFileHash) {
        return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    }

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        return ([System.BitConverter]::ToString($sha256.ComputeHash($stream)) -replace '-', '').ToUpperInvariant()
    }
    finally {
        $stream.Dispose()
        $sha256.Dispose()
    }
}

function Invoke-PowerShellScript {
    param(
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [Parameter(Mandatory = $false)][string[]]$Arguments = @()
    )

    $cmdArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $ScriptPath) + $Arguments
    & powershell @cmdArgs
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw ("Script failed ({0}): {1}" -f $exitCode, $ScriptPath)
    }
}

function Invoke-MT3SmokeRun {
    param(
        [Parameter(Mandatory = $true)][string]$ExePath,
        [Parameter(Mandatory = $true)][int]$TimeoutSeconds
    )

    $workDir = Split-Path -Parent $ExePath
    $proc = Start-Process -FilePath $ExePath -WorkingDirectory $workDir -PassThru
    $status = "running"
    $exitCode = $null
    $cleanupError = $null

    Start-Sleep -Seconds $TimeoutSeconds
    if ($proc.HasExited) {
        $status = "exited"
        $exitCode = $proc.ExitCode
    } else {
        try {
            try {
                $null = $proc.CloseMainWindow()
                Start-Sleep -Seconds 2
                $proc.Refresh()
            }
            catch {
            }

            if (-not $proc.HasExited) {
                Stop-Process -Id $proc.Id -Force -ErrorAction Stop
                $proc.WaitForExit(5000) | Out-Null
                $proc.Refresh()
            }

            if ($proc.HasExited) {
                $status = "killed_timeout"
                $exitCode = $proc.ExitCode
            } else {
                $status = "cleanup_timeout"
            }
        }
        catch {
            $cleanupError = $_.Exception.Message
            Start-Sleep -Seconds 2
            $proc.Refresh()
            if ($proc.HasExited) {
                $status = "exited_after_timeout"
                $exitCode = $proc.ExitCode
            } else {
                $status = "cleanup_failed"
            }
        }
    }

    return [PSCustomObject]@{
        Pid = $proc.Id
        Status = $status
        ExitCode = $exitCode
        TimeoutSeconds = $TimeoutSeconds
        CleanupError = $cleanupError
    }
}

$repoRoot = Resolve-RepoRoot
$canonicalBuildScript = Resolve-RepoPath -RepoRoot $repoRoot -PathValue "tools\\scripts\\Build-MT3-Exe-Canonical.ps1"
$toolchainScript = Resolve-RepoPath -RepoRoot $repoRoot -PathValue "tools\\scripts\\Check-v120Toolset.ps1"
$runtimeAuditScript = Resolve-RepoPath -RepoRoot $repoRoot -PathValue "tools\\scripts\\Audit-RuntimeDependencies.ps1"
$collectBootScript = Resolve-RepoPath -RepoRoot $repoRoot -PathValue "tools\\scripts\\Collect-P0Boot-Win32.ps1"
$collectEffectScript = Resolve-RepoPath -RepoRoot $repoRoot -PathValue "tools\\scripts\\Collect-P0EffectChain-Win32.ps1"

foreach ($requiredScript in @($canonicalBuildScript, $toolchainScript, $runtimeAuditScript)) {
    if (-not (Test-Path $requiredScript)) {
        throw "Missing required script: $requiredScript"
    }
}

$reportAbs = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $ReportPath
Ensure-ParentDirectory -FilePath $reportAbs

$report = [ordered]@{
    Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    RepoRoot = $repoRoot
    Host = $env:COMPUTERNAME
    Platform = $Platform
    EngineProfile = $EngineProfile
    RequestedConfiguration = $Configuration
    StrictRuntimeAudit = [bool]$StrictRuntimeAudit
    ToolchainCheck = [ordered]@{
        Status = "pending"
    }
    Builds = @()
    RuntimeAudits = @()
    SmokeRuns = @()
    P0Collectors = @()
}

try {
    Write-Host "==> toolchain-check"
    Invoke-PowerShellScript -ScriptPath $toolchainScript -Arguments @("-RootPath", $repoRoot, "-Scope", "Mainline")
    $report.ToolchainCheck.Status = "pass"

    $configs = @()
    if ($Configuration -eq "Both") {
        $configs = @("Release", "Debug")
    } else {
        $configs = @($Configuration)
    }

    for ($idx = 0; $idx -lt $configs.Count; $idx++) {
        $cfg = $configs[$idx]

        Write-Host ("==> build {0}|{1}" -f $cfg, $Platform)
        $buildArgs = @("-Configuration", $cfg, "-Platform", $Platform, "-EngineProfile", $EngineProfile)
        if ($Clean -and $idx -eq 0) {
            $buildArgs += "-Clean"
        }
        if ($MaxParallelJobs -gt 0) {
            $buildArgs += @("-MaxParallelJobs", [string]$MaxParallelJobs)
        }
        if ($StrictRuntimeAudit) {
            $buildArgs += "-StrictRuntimeAudit"
        }

        $buildStart = Get-Date
        Invoke-PowerShellScript -ScriptPath $canonicalBuildScript -Arguments $buildArgs
        $buildEnd = Get-Date

        $exePath = Resolve-RepoPath -RepoRoot $repoRoot -PathValue ("client\\resource\\bin\\{0}\\MT3.exe" -f $cfg)
        if (-not (Test-Path $exePath)) {
            throw "Missing build output: $exePath"
        }

        $exeInfo = Get-Item $exePath
        $exeHash = Get-Sha256 -Path $exePath
        $report.Builds += [PSCustomObject]@{
            Configuration = $cfg
            EngineProfile = $EngineProfile
            Status = "pass"
            ExePath = $exeInfo.FullName
            ExeLength = $exeInfo.Length
            ExeSha256 = $exeHash
            BuildStart = $buildStart.ToString("yyyy-MM-dd HH:mm:ss")
            BuildEnd = $buildEnd.ToString("yyyy-MM-dd HH:mm:ss")
        }

        Write-Host ("==> runtime-audit {0}" -f $cfg)
        $runtimeReportRel = ("build_logs/runtime-audit-{0}-full-validation.json" -f $cfg.ToLowerInvariant())
        $runtimeAuditArgs = @(
            "-ScanRoots", ("client\resource\bin\{0}" -f $cfg),
            "-ExecutableNames", "MT3.exe",
            "-ReportPath", $runtimeReportRel
        )
        if ($StrictRuntimeAudit) {
            $runtimeAuditArgs += "-FailOnIssues"
        }
        Invoke-PowerShellScript -ScriptPath $runtimeAuditScript -Arguments $runtimeAuditArgs
        $runtimeReportPath = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $runtimeReportRel
        $runtimeReport = Get-Content -Raw -Encoding UTF8 $runtimeReportPath | ConvertFrom-Json
        if ([int]$runtimeReport.Summary.ExeCount -ne 1) {
            throw ("Runtime audit must inspect exactly one MT3.exe for {0}; actual={1}" -f
                $cfg, $runtimeReport.Summary.ExeCount)
        }
        $report.RuntimeAudits += [PSCustomObject]@{
            Configuration = $cfg
            Status = "pass"
            ReportPath = $runtimeReportPath
        }

        if ($RunSmoke) {
            Write-Host ("==> smoke-run {0}" -f $cfg)
            $smoke = Invoke-MT3SmokeRun -ExePath $exePath -TimeoutSeconds $SmokeSeconds
            $report.SmokeRuns += [PSCustomObject]@{
                Configuration = $cfg
                Status = $smoke.Status
                ExitCode = $smoke.ExitCode
                TimeoutSeconds = $smoke.TimeoutSeconds
                Pid = $smoke.Pid
                CleanupError = $smoke.CleanupError
            }
        }

        if ($RunP0Collectors) {
            $bootLog = Resolve-RepoPath -RepoRoot $repoRoot -PathValue ("client\\resource\\bin\\{0}\\startup_bootstrap.log" -f $cfg)
            $ctLog = Resolve-RepoPath -RepoRoot $repoRoot -PathValue ("client\\resource\\bin\\{0}\\mt3_ct.log" -f $cfg)
            $collectorCsv = Resolve-RepoPath -RepoRoot $repoRoot -PathValue "docs\\audit\\p0_execution\\p0_effect_chain_records.csv"
            $bootCsv = Resolve-RepoPath -RepoRoot $repoRoot -PathValue "docs\\audit\\p0_execution\\p0_boot_capture_records.csv"

            if (Test-Path $collectBootScript) {
                Write-Host ("==> collect-p0-boot {0}" -f $cfg)
                Invoke-PowerShellScript -ScriptPath $collectBootScript -Arguments @("-LogPath", $bootLog, "-OutputCsv", $bootCsv)
                $report.P0Collectors += [PSCustomObject]@{
                    Configuration = $cfg
                    Collector = "Collect-P0Boot-Win32"
                    Status = "pass"
                    LogPath = $bootLog
                    OutputCsv = $bootCsv
                }
            }

            if (Test-Path $collectEffectScript) {
                Write-Host ("==> collect-p0-effect-chain {0}" -f $cfg)
                Invoke-PowerShellScript -ScriptPath $collectEffectScript -Arguments @("-LogPath", $ctLog, "-OutputCsv", $collectorCsv)
                $report.P0Collectors += [PSCustomObject]@{
                    Configuration = $cfg
                    Collector = "Collect-P0EffectChain-Win32"
                    Status = "pass"
                    LogPath = $ctLog
                    OutputCsv = $collectorCsv
                }
            }
        }
    }

    $report.Status = "pass"
}
catch {
    $report.Status = "fail"
    $report.Error = $_.Exception.Message
    throw
}
finally {
    $report.CompletedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $reportJson = $report | ConvertTo-Json -Depth 8
    [System.IO.File]::WriteAllText($reportAbs, $reportJson, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host ("Validation report: {0}" -f $reportAbs)
}

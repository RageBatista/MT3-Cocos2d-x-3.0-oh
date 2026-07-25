[CmdletBinding()]
param(
    [string]$RepoRoot = '',
    [string]$ReportPath = 'build_logs\security-gate.json',
    [switch]$StrictHttp,
    [switch]$Json
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$scriptDir = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { $PSScriptRoot }

function Resolve-FullPath {
    param([string]$PathValue, [string]$BaseDirectory)
    if ([System.IO.Path]::IsPathRooted($PathValue)) { return [System.IO.Path]::GetFullPath($PathValue) }
    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $PathValue))
}

function Get-RelativePathSafe {
    param([string]$BasePath, [string]$TargetPath)
    $baseUri = New-Object System.Uri(($BasePath.TrimEnd('\\/') + [System.IO.Path]::DirectorySeparatorChar))
    $targetUri = New-Object System.Uri($TargetPath)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('/', '\')
}

function Read-TextFileSmart {
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return [System.Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
    }
    $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
    try { return $utf8Strict.GetString($bytes) }
    catch { return [System.Text.Encoding]::GetEncoding(54936).GetString($bytes) }
}

function Test-ExcludedPath {
    param([string]$RelativePath)
    $p = $RelativePath.Replace('/', '\').TrimStart('\')
    foreach ($prefix in @('dependencies\', 'build\', 'build_logs\', 'Testing\', '.git\', 'node_modules\', '__pycache__\', 'docs\', 'plans\')) {
        if ($p.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    if ($p -match 'LuaFireClient(Win32)?\.cpp$') { return $true }
    if ($p.Equals('tools\scripts\Test-MT3-SecurityGate.ps1', [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    if ($p.IndexOf('\ProtoDef\', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
    return $false
}

function Add-Finding {
    param(
        [System.Collections.Generic.List[object]]$Findings,
        [string]$Severity,
        [string]$Rule,
        [string]$Path,
        [int]$Line,
        [string]$Message,
        [string]$Evidence
    )
    $Findings.Add([pscustomobject][ordered]@{
        severity = $Severity
        rule = $Rule
        path = $Path
        line = $Line
        message = $Message
        evidence = $Evidence
    }) | Out-Null
}

$resolvedRepoRoot = if ([string]::IsNullOrWhiteSpace($RepoRoot)) { [System.IO.Path]::GetFullPath((Join-Path $scriptDir '..\..')) } else { Resolve-FullPath -PathValue $RepoRoot -BaseDirectory (Get-Location).Path }
$resolvedReportPath = Resolve-FullPath -PathValue $ReportPath -BaseDirectory $resolvedRepoRoot
$reportDir = Split-Path -Parent $resolvedReportPath
if ($reportDir -and -not (Test-Path $reportDir)) { [System.IO.Directory]::CreateDirectory($reportDir) | Out-Null }

$scanRoots = @(
    'client/FireClient/Application',
    'client/resource/res/script',
    'common',
    'tools/scripts',
    '.gitlab-ci.yml',
    '.github',
    '.claude',
    '.codex',
    '.agents'
)
$allowedExtensions = @('.cpp', '.h', '.hpp', '.c', '.cc', '.lua', '.ps1', '.yml', '.yaml', '.toml', '.json', '.xml', '.ini', '.txt', '.properties')
$files = New-Object System.Collections.Generic.List[string]
foreach ($root in $scanRoots) {
    $full = Resolve-FullPath -PathValue $root -BaseDirectory $resolvedRepoRoot
    if (Test-Path $full -PathType Leaf) {
        $rel = Get-RelativePathSafe -BasePath $resolvedRepoRoot -TargetPath $full
        if (-not (Test-ExcludedPath -RelativePath $rel)) { $files.Add($full) | Out-Null }
    } elseif (Test-Path $full -PathType Container) {
        Get-ChildItem -Path $full -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $rel = Get-RelativePathSafe -BasePath $resolvedRepoRoot -TargetPath $_.FullName
            if ((-not (Test-ExcludedPath -RelativePath $rel)) -and ($allowedExtensions -contains $_.Extension.ToLowerInvariant())) {
                $files.Add($_.FullName) | Out-Null
            }
        }
    }
}

$blockers = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[object]
$quotedLiteral = '"([^"]+)"'


foreach ($file in $files) {
    $rel = Get-RelativePathSafe -BasePath $resolvedRepoRoot -TargetPath $file
    $text = Read-TextFileSmart -Path $file
    $lines = $text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNo = $i + 1
        $trim = $line.Trim()
        $isComment = ($trim -match '^(//|--|#)')

        if ($line -match ('sPassWord\s*=\s*' + $quotedLiteral)) {
            Add-Finding -Findings $blockers -Severity 'P0' -Rule 'hardcoded_ftp_password' -Path $rel -Line $lineNo -Message 'hardcoded FTP password is forbidden' -Evidence 'sPassWord = REDACTED'
        }
        if ($line -match ('sUserName\s*=\s*' + $quotedLiteral) -and $matches[1].Trim().Length -gt 0) {
            Add-Finding -Findings $blockers -Severity 'P0' -Rule 'hardcoded_ftp_username' -Path $rel -Line $lineNo -Message 'hardcoded FTP username is forbidden' -Evidence 'sUserName = REDACTED'
        }
        if ($line -match ('inputPassWord\s*\(\s*' + $quotedLiteral)) {
            Add-Finding -Findings $blockers -Severity 'P0' -Rule 'hardcoded_ftp_password_call' -Path $rel -Line $lineNo -Message 'hardcoded FTP password call is forbidden' -Evidence 'inputPassWord(REDACTED)'
        }
        if ($line -match ('inputUserName\s*\(\s*' + $quotedLiteral)) {
            Add-Finding -Findings $blockers -Severity 'P0' -Rule 'hardcoded_ftp_username_call' -Path $rel -Line $lineNo -Message 'hardcoded FTP username call is forbidden' -Evidence 'inputUserName(REDACTED)'
        }
        if ($line -match 'ftp://[^\s/:]+:[^\s@]+@') {
            Add-Finding -Findings $blockers -Severity 'P0' -Rule 'ftp_url_with_credentials' -Path $rel -Line $lineNo -Message 'FTP URL with inline credentials is forbidden' -Evidence 'ftp://REDACTED@host'
        }
        if ($line -match 'SetSessionKey\s*\(\s*(?:StringCover::to_wstring\s*\(\s*)?L?"([^"]+)"' -and $matches[1].Trim().Length -gt 0) {
            Add-Finding -Findings $blockers -Severity 'P0' -Rule 'hardcoded_session_key_literal' -Path $rel -Line $lineNo -Message 'hardcoded login session key is forbidden' -Evidence 'SetSessionKey(REDACTED)'
        }

        if (-not $isComment) {
            if ($line -match 'param\s*\[\s*"password"\s*\]\s*=\s*gGetLoginManager\(\):GetPassword\(\)') {
                Add-Finding -Findings $blockers -Severity 'P0' -Rule 'payment_password_param' -Path $rel -Line $lineNo -Message 'payment request must not send login credential' -Evidence 'param[password] = gGetLoginManager():GetPassword()'
            }
            if ($rel -match 'client\\resource\\res\\script\\logic\\(chargedialog|vip\\rolechargedlg|vip\\daychargedlg)\.lua$' -and $line -match 'gGetLoginManager\(\):GetPassword\(\)') {
                Add-Finding -Findings $blockers -Severity 'P0' -Rule 'payment_login_manager_getpassword' -Path $rel -Line $lineNo -Message 'payment/recharge flow must not read login session via deprecated GetPassword' -Evidence 'gGetLoginManager():GetPassword()'
            }
            if ($rel -like 'client\resource\res\script\*.lua' -and $line -match 'gGetLoginManager\(\):SetPassword\(') {
                Add-Finding -Findings $blockers -Severity 'P0' -Rule 'login_manager_setpassword_lua' -Path $rel -Line $lineNo -Message 'Lua must not write raw input into LoginManager deprecated SetPassword compatibility field' -Evidence 'gGetLoginManager():SetPassword(REDACTED)'
            }
            if ($line -match '\bprint\s*\(\s*(password|passwordagain|token|session|sid|cookie)\s*\)') {
                $evidence = $trim -replace '(passwordagain|password|token|session|sid|cookie)', 'SENSITIVE'
                Add-Finding -Findings $blockers -Severity 'P0' -Rule 'sensitive_debug_print' -Path $rel -Line $lineNo -Message 'sensitive debug print is forbidden' -Evidence $evidence
            }
            if ($line -match '\b(SDLOG|LOG)[A-Z_]*\s*\(' -and $line -match '(password|token|session|sid|cookie)' -and $line -notmatch '(Len|length|empty|missing)') {
                $evidence = $trim -replace '(password|token|session|sid|cookie)', 'SENSITIVE'
                Add-Finding -Findings $warnings -Severity 'P1' -Rule 'sensitive_log_review' -Path $rel -Line $lineNo -Message 'sensitive keyword appears in log statement; verify no raw value is logged' -Evidence $evidence
            }

            $isRemoval = ($line -match 'Remove(ValueByName|ServerIniInfo|ServerSection)')
            if (-not $isRemoval) {
                if ($line -match 'LastPassword' -and ($line -match '(GetValueByName|WriteValueByName|SetServerIniInfo|GetServerIniInfo|setText|SetPassword)')) {
                    Add-Finding -Findings $blockers -Severity 'P0' -Rule 'last_password_persistence' -Path $rel -Line $lineNo -Message 'LastPassword read/write/autofill is forbidden' -Evidence $trim
                }
                if ($line -match 'AccountList' -and $line -match 'password' -and ($line -match '(GetValueByName|WriteValueByName|SetServerIniInfo|GetServerIniInfo|SetPassword)')) {
                    Add-Finding -Findings $blockers -Severity 'P0' -Rule 'account_list_password_persistence' -Path $rel -Line $lineNo -Message 'AccountList password read/write/autofill is forbidden' -Evidence $trim
                }
            }
        }

        if ($line -match '(http://|\b192\.168\.\d{1,3}\.\d{1,3}\b|\b127\.0\.0\.1\b|\b10\.\d{1,3}\.\d{1,3}\.\d{1,3}\b|\b172\.(1[6-9]|2[0-9]|3[0-1])\.\d{1,3}\.\d{1,3}\b|testot)') {
            if ($StrictHttp) {
                Add-Finding -Findings $blockers -Severity 'P0' -Rule 'http_private_test_url' -Path $rel -Line $lineNo -Message 'HTTP/private/test URL must be environment-configured; StrictHttp blocks it' -Evidence $trim
            } else {
                Add-Finding -Findings $warnings -Severity 'P1' -Rule 'http_private_test_url' -Path $rel -Line $lineNo -Message 'HTTP/private/test URL must be environment-configured; StrictHttp blocks it' -Evidence $trim
            }
        }
    }
}

$status = if ($blockers.Count -gt 0) { 'FAIL' } else { 'PASS' }
$blockerArray = @()
$warningArray = @()
foreach ($item in $blockers) { $blockerArray += $item }
foreach ($item in $warnings) { $warningArray += $item }

$summary = [ordered]@{
    generated_at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    repo_root = $resolvedRepoRoot
    status = $status
    strict_http = [bool]$StrictHttp
    scanned_files = $files.Count
    blocker_count = $blockers.Count
    warning_count = $warnings.Count
    blockers = $blockerArray
    warnings = $warningArray
}
[System.IO.File]::WriteAllText($resolvedReportPath, (($summary | ConvertTo-Json -Depth 8) + [Environment]::NewLine), $utf8NoBom)

if ($Json) {
    $summary | ConvertTo-Json -Depth 8
} else {
    Write-Host ("STATUS: {0}" -f $status)
    Write-Host ("SUMMARY: scanned_files={0} blockers={1} warnings={2} strict_http={3}" -f $files.Count, $blockers.Count, $warnings.Count, [bool]$StrictHttp)
    Write-Host ("REPORT: {0}" -f $resolvedReportPath)
    $shown = 0
    foreach ($item in $blockerArray) {
        if ($shown -ge 20) { break }
        Write-Host ("BLOCKER: {0}:{1} [{2}] {3}" -f $item.path, $item.line, $item.rule, $item.message)
        $shown++
    }
    $shown = 0
    foreach ($item in $warningArray) {
        if ($shown -ge 10) { break }
        Write-Host ("WARNING: {0}:{1} [{2}] {3}" -f $item.path, $item.line, $item.rule, $item.message)
        $shown++
    }
}
if ($status -eq 'FAIL') { exit 1 }
exit 0

param(
    [string]$BaseUrl = "http://127.0.0.1:88",
    [string]$ProjectRoot = "",
    [int]$TimeoutSec = 8,
    [switch]$SkipRefresh,
    [string]$RemoteHost = "",
    [string]$RemoteUser = "root",
    [string]$RemoteProjectDir = "/www/wwwroot/web_app",
    [string]$PhpFpmService = "php-fpm",
    [switch]$NoSudo
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Info([string]$msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn([string]$msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err([string]$msg)  { Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Resolve-ProjectRoot([string]$inputRoot) {
    if ([string]::IsNullOrWhiteSpace($inputRoot)) {
        return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    }
    return (Resolve-Path $inputRoot).Path
}

function Assert-ProjectRoot([string]$root) {
    $required = @("app", "config", "public", "think")
    foreach ($item in $required) {
        $full = Join-Path $root $item
        if (-not (Test-Path $full)) {
            throw "Project root validation failed. Missing: $item (Root=$root)"
        }
    }
}

function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Body = ""
    )
    try {
        if ($Method -eq "GET") {
            return (Invoke-WebRequest -Method Get -Uri $Url -TimeoutSec $TimeoutSec -UseBasicParsing).Content
        }
        $headers = @{ "Content-Type" = "application/x-www-form-urlencoded" }
        return (Invoke-WebRequest -Method Post -Uri $Url -Body $Body -Headers $headers -TimeoutSec $TimeoutSec -UseBasicParsing).Content
    } catch {
        $ex = $_.Exception
        if ($null -ne $ex.Response) {
            try {
                $stream = $ex.Response.GetResponseStream()
                if ($null -ne $stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $content = $reader.ReadToEnd()
                    $reader.Close()
                    return $content
                }
            } catch {
                return ""
            }
        }
        return ""
    }
}

function Test-JsonLike([string]$body) {
    if ([string]::IsNullOrWhiteSpace($body)) { return $false }
    $t = $body.Trim()
    return $t.StartsWith("{") -or $t.StartsWith("[")
}

function Test-ContainsTraceHtml([string]$body) {
    if ([string]::IsNullOrWhiteSpace($body)) { return $false }
    return ($body -match "(?i)<script[^>]*text/javascript" -or $body -match "(?i)<!DOCTYPE html>" -or $body -match "(?i)<html")
}

function Test-ContainsRequestId([string]$body) {
    if ([string]::IsNullOrWhiteSpace($body)) { return $false }
    return ($body -match '"request_id"')
}

function Assert-Response {
    param(
        [string]$Name,
        [string]$Body,
        [switch]$RequireRequestId
    )

    $ok = $true
    if ([string]::IsNullOrWhiteSpace($Body)) {
        Write-Err "${Name}: empty response"
        return $false
    }
    if (Test-ContainsTraceHtml $Body) {
        Write-Err "${Name}: response contains trace/html debug output"
        $ok = $false
    }
    if (-not (Test-JsonLike $Body)) {
        Write-Err "${Name}: response is not JSON-like"
        $ok = $false
    }
    if ($RequireRequestId -and -not (Test-ContainsRequestId $Body)) {
        Write-Err "${Name}: missing request_id"
        $ok = $false
    }
    return $ok
}

function Invoke-RemoteRefresh {
    param(
        [string]$Host,
        [string]$User,
        [string]$Dir,
        [string]$FpmService,
        [bool]$UseSudo
    )

    $sudo = if ($UseSudo) { "sudo " } else { "" }
    $cmd = @(
        "set -e",
        "cd '$Dir'",
        "php think clear >/dev/null",
        "if command -v systemctl >/dev/null 2>&1; then $sudo" + "systemctl reload '$FpmService' || $sudo" + "systemctl restart '$FpmService'; fi"
    ) -join "; "

    Write-Info "Run remote refresh via SSH: $User@$Host"
    & ssh "$User@$Host" $cmd
}

$root = Resolve-ProjectRoot $ProjectRoot
Assert-ProjectRoot $root

Write-Info "Project root: $root"
Write-Info "Base URL: $BaseUrl"

if (-not $SkipRefresh) {
    if (-not [string]::IsNullOrWhiteSpace($RemoteHost)) {
        Invoke-RemoteRefresh -Host $RemoteHost -User $RemoteUser -Dir $RemoteProjectDir -FpmService $PhpFpmService -UseSudo:(-not $NoSudo)
        Write-Info "Remote refresh finished"
    } else {
        Push-Location $root
        try {
            Write-Info "Run local: php think clear"
            & php think clear | Out-Null
            Write-Info "Local think clear finished"
        } finally {
            Pop-Location
        }
    }
} else {
    Write-Info "Skip refresh enabled"
}

Write-Info "Verify API response format..."
$payitemBody = Invoke-ApiRequest -Method "GET" -Url "$BaseUrl/api/pay/getpayitem"
$rebateBody  = Invoke-ApiRequest -Method "GET" -Url "$BaseUrl/api/game/rebate"
$sdkBody     = Invoke-ApiRequest -Method "GET" -Url "$BaseUrl/api/game/sdk?account=__no_user__&password=__bad__&serverId=1000000001"
$bindBody    = Invoke-ApiRequest -Method "POST" -Url "$BaseUrl/api/game/bind" -Body "account=__no_user__&roleid=1&qu=1000000001&name=test"

$allOk = $true
$allOk = (Assert-Response -Name "pay/getpayitem" -Body $payitemBody -RequireRequestId) -and $allOk
$allOk = (Assert-Response -Name "game/rebate" -Body $rebateBody -RequireRequestId) -and $allOk
$allOk = (Assert-Response -Name "game/sdk(invalid)" -Body $sdkBody -RequireRequestId) -and $allOk
$allOk = (Assert-Response -Name "game/bind(invalid)" -Body $bindBody -RequireRequestId) -and $allOk

function Preview([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return "" }
    if ($s.Length -le 220) { return $s }
    return $s.Substring(0, 220)
}

Write-Host ""
Write-Host "[pay/getpayitem] $(Preview $payitemBody)"
Write-Host "[game/rebate] $(Preview $rebateBody)"
Write-Host "[game/sdk] $(Preview $sdkBody)"
Write-Host "[game/bind] $(Preview $bindBody)"

if (-not $allOk) {
    Write-Err "Verification FAILED"
    exit 1
}

Write-Info "Verification PASSED"

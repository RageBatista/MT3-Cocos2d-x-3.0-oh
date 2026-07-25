param(
    [string]$LogPath = "client/resource/bin/Release/mt3_ct.log",
    [string]$OutputCsv = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String("ZG9jcy8wOS3ljoblj7LlvZLmoaMv5LiT6aG55a6h6K6hL1Aw55S76LSo5LyY5YyWL3AwX2VmZmVjdF9jaGFpbl9yZWNvcmRzLmNzdg=="))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Directory {
    param([string]$FilePath)
    $dir = Split-Path -Parent $FilePath
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Ensure-CsvHeader {
    param([string]$FilePath)
    if (-not (Test-Path -LiteralPath $FilePath)) {
        $header = '"CaptureTime","Platform","Status","Source","Device","SelectEffect","SetParamEffect","DrawEffect","SetParamPtr","DrawParamPtr","RawSelectLine","RawSetLine","RawDrawLine","Reason"'
        [System.IO.File]::WriteAllLines($FilePath, @($header), (New-Object System.Text.UTF8Encoding($false)))
    }
}

function Append-CsvRow {
    param(
        [string]$FilePath,
        [pscustomobject]$Row
    )
    $line = ($Row | ConvertTo-Csv -NoTypeInformation)[1]
    $enc = New-Object System.Text.UTF8Encoding($false)
    $writer = New-Object System.IO.StreamWriter($FilePath, $true, $enc)
    try {
        $writer.WriteLine($line)
    }
    finally {
        $writer.Dispose()
    }
}

function Find-LastMatchLine {
    param(
        [string[]]$Lines,
        [string]$Pattern
    )
    for ($i = $Lines.Count - 1; $i -ge 0; $i--) {
        if ($Lines[$i] -match $Pattern) {
            return $Lines[$i]
        }
    }
    return $null
}

function Normalize-Pointer {
    param([string]$PointerValue)
    if ([string]::IsNullOrWhiteSpace($PointerValue)) {
        return ""
    }

    $p = $PointerValue.Trim().ToLower()
    if ($p -eq "(nil)" -or $p -eq "nil" -or $p -eq "0") {
        return "0x0"
    }
    if ($p.StartsWith("0x")) {
        return $p
    }
    return "0x$p"
}

$outputAbs = [System.IO.Path]::GetFullPath($OutputCsv)
$logAbs = [System.IO.Path]::GetFullPath($LogPath)

Ensure-Directory -FilePath $outputAbs
Ensure-CsvHeader -FilePath $outputAbs

$captureTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$selectRegex = '\[P0\]\[EFFECT\]\s+SelectRenderEffect effect=(-?\d+)\s+prev=(-?\d+)'
$setRegex = '\[P0\]\[EFFECT\]\s+SetShaderParam effect=(-?\d+)\s+param=([0-9A-Fa-fx]+|\(nil\)|nil)'
$drawRegex = '\[P0\]\[EFFECT\]\s+DrawPicture read effect=(-?\d+)\s+param=([0-9A-Fa-fx]+|\(nil\)|nil)'

if (-not (Test-Path -LiteralPath $logAbs)) {
    Append-CsvRow -FilePath $outputAbs -Row ([pscustomobject]@{
            CaptureTime = $captureTime
            Platform = "Win32"
            Status = "blocked"
            Source = $logAbs
            Device = "local"
            SelectEffect = ""
            SetParamEffect = ""
            DrawEffect = ""
            SetParamPtr = ""
            DrawParamPtr = ""
            RawSelectLine = ""
            RawSetLine = ""
            RawDrawLine = ""
            Reason = "log_not_found"
        })
    Write-Host "Win32 effect-chain capture failed: log file not found -> $logAbs"
    exit 2
}

$lines = Get-Content -Encoding UTF8 $logAbs
$selectLine = Find-LastMatchLine -Lines $lines -Pattern $selectRegex
$setLine = Find-LastMatchLine -Lines $lines -Pattern $setRegex
$drawLine = Find-LastMatchLine -Lines $lines -Pattern $drawRegex

$selectEffect = ""
$setEffect = ""
$drawEffect = ""
$setPtr = ""
$drawPtr = ""

if ($selectLine -and ($selectLine -match $selectRegex)) {
    $selectEffect = $Matches[1]
}
if ($setLine -and ($setLine -match $setRegex)) {
    $setEffect = $Matches[1]
    $setPtr = Normalize-Pointer -PointerValue $Matches[2]
}
if ($drawLine -and ($drawLine -match $drawRegex)) {
    $drawEffect = $Matches[1]
    $drawPtr = Normalize-Pointer -PointerValue $Matches[2]
}

$missing = @()
if (-not $setLine) { $missing += "set_not_found" }
if (-not $drawLine) { $missing += "draw_not_found" }

$status = "pass"
$reason = ""
if ($missing.Count -gt 0) {
    $status = "no_match"
    $reason = ($missing -join "|")
}
elseif ($setEffect -ne $drawEffect -or $setPtr -ne $drawPtr) {
    $status = "mismatch"
    $reason = "set_draw_not_aligned"
}
elseif (-not $selectLine) {
    $reason = "select_not_found_optional"
}

Append-CsvRow -FilePath $outputAbs -Row ([pscustomobject]@{
        CaptureTime = $captureTime
        Platform = "Win32"
        Status = $status
        Source = $logAbs
        Device = "local"
        SelectEffect = $selectEffect
        SetParamEffect = $setEffect
        DrawEffect = $drawEffect
        SetParamPtr = $setPtr
        DrawParamPtr = $drawPtr
        RawSelectLine = $(if ($selectLine) { $selectLine } else { "" })
        RawSetLine = $(if ($setLine) { $setLine } else { "" })
        RawDrawLine = $(if ($drawLine) { $drawLine } else { "" })
        Reason = $reason
    })

Write-Host "Win32 effect-chain capture done: status=$status select=$selectEffect set=$setEffect draw=$drawEffect setPtr=$setPtr drawPtr=$drawPtr"

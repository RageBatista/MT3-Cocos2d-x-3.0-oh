param(
    [string]$LogPath = "client/resource/bin/Release/startup_bootstrap.log",
    [string]$OutputCsv = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String("ZG9jcy8wOS3ljoblj7LlvZLmoaMv5LiT6aG55a6h6K6hL1Aw55S76LSo5LyY5YyWL3AwX2Jvb3RfY2FwdHVyZV9yZWNvcmRzLmNzdg=="))
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
        $header = '"CaptureTime","Platform","Status","Source","Device","multiSampleType","bEnableMipMap","dwRenderFlags","appInitStep","RawLine","Reason"'
        [System.IO.File]::WriteAllLines($FilePath, @($header), (New-Object System.Text.UTF8Encoding($false)))
    }
}

function Append-CsvRow {
    param(
        [string]$FilePath,
        [pscustomobject]$Row
    )
    $line = ($Row | ConvertTo-Csv -NoTypeInformation)[1]
    [System.IO.File]::AppendAllText($FilePath, "`n$line", (New-Object System.Text.UTF8Encoding($false)))
}

$outputAbs = [System.IO.Path]::GetFullPath($OutputCsv)
$logAbs = [System.IO.Path]::GetFullPath($LogPath)

Ensure-Directory -FilePath $outputAbs
Ensure-CsvHeader -FilePath $outputAbs

$captureTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$regex = '\[P0\]\[BOOT\]\s+multiSampleType=(\d+)\s+bEnableMipMap=(\d+)\s+dwRenderFlags=(0x[0-9A-Fa-f]+)\s+appInitStep=(\d+)'

if (-not (Test-Path -LiteralPath $logAbs)) {
    Append-CsvRow -FilePath $outputAbs -Row ([pscustomobject]@{
            CaptureTime = $captureTime
            Platform = "Win32"
            Status = "blocked"
            Source = $logAbs
            Device = "local"
            multiSampleType = ""
            bEnableMipMap = ""
            dwRenderFlags = ""
            appInitStep = ""
            RawLine = ""
            Reason = "log_not_found"
        })
    Write-Host "Win32 capture failed: log file not found -> $logAbs"
    exit 2
}

$lines = Get-Content -Encoding UTF8 $logAbs
$matchLine = $null
for ($i = $lines.Count - 1; $i -ge 0; $i--) {
    if ($lines[$i] -match $regex) {
        $matchLine = $lines[$i]
        break
    }
}

if (-not $matchLine) {
    Append-CsvRow -FilePath $outputAbs -Row ([pscustomobject]@{
            CaptureTime = $captureTime
            Platform = "Win32"
            Status = "no_match"
            Source = $logAbs
            Device = "local"
            multiSampleType = ""
            bEnableMipMap = ""
            dwRenderFlags = ""
            appInitStep = ""
            RawLine = ""
            Reason = "p0_boot_not_found"
        })
    Write-Host "Win32 capture failed: [P0][BOOT] not found"
    exit 3
}

$null = $matchLine -match $regex
$multiSampleType = $Matches[1]
$enableMipMap = $Matches[2]
$renderFlags = $Matches[3].ToLower()
$appInitStep = $Matches[4]

Append-CsvRow -FilePath $outputAbs -Row ([pscustomobject]@{
        CaptureTime = $captureTime
        Platform = "Win32"
        Status = "pass"
        Source = $logAbs
        Device = "local"
        multiSampleType = $multiSampleType
        bEnableMipMap = $enableMipMap
        dwRenderFlags = $renderFlags
        appInitStep = $appInitStep
        RawLine = $matchLine
        Reason = ""
    })

Write-Host "Win32 capture done: multiSampleType=$multiSampleType bEnableMipMap=$enableMipMap dwRenderFlags=$renderFlags appInitStep=$appInitStep"

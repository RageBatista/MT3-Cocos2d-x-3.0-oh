param(
    [Parameter(Mandatory = $true)]
    [string]$ApkPath,

    [Parameter(Mandatory = $false)]
    [int]$MaxEntryCount = 65534,

    [Parameter(Mandatory = $false)]
    [switch]$FailOnZip64
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ApkPath)) {
    throw "APK not found: $ApkPath"
}

if ($MaxEntryCount -le 0) {
    throw "MaxEntryCount must be greater than 0."
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Test-ByteSignature {
    param(
        [byte[]]$Buffer,
        [byte[]]$Signature
    )

    if ($Buffer.Length -lt $Signature.Length) {
        return $false
    }

    for ($i = 0; $i -le $Buffer.Length - $Signature.Length; $i++) {
        $matched = $true
        for ($j = 0; $j -lt $Signature.Length; $j++) {
            if ($Buffer[$i + $j] -ne $Signature[$j]) {
                $matched = $false
                break
            }
        }
        if ($matched) {
            return $true
        }
    }

    return $false
}

$zipArchive = $null
$fileStream = $null

try {
    $fileStream = [System.IO.File]::Open($ApkPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    $zipArchive = New-Object System.IO.Compression.ZipArchive($fileStream, [System.IO.Compression.ZipArchiveMode]::Read, $true)
    $entryCount = $zipArchive.Entries.Count

    $tailSize = [Math]::Min([int64]262144, $fileStream.Length)
    $tailBuffer = New-Object byte[] $tailSize
    [void]$fileStream.Seek(-$tailSize, [System.IO.SeekOrigin]::End)
    [void]$fileStream.Read($tailBuffer, 0, $tailSize)

    $zip64EocdSignature = [byte[]](0x50, 0x4B, 0x06, 0x06)
    $zip64LocatorSignature = [byte[]](0x50, 0x4B, 0x06, 0x07)
    $hasZip64 = (Test-ByteSignature -Buffer $tailBuffer -Signature $zip64EocdSignature) -or
                (Test-ByteSignature -Buffer $tailBuffer -Signature $zip64LocatorSignature)

    Write-Host "APK Structure Gate"
    Write-Host "  Path        : $ApkPath"
    Write-Host "  Entry Count : $entryCount"
    Write-Host "  Max Allowed : $MaxEntryCount"
    Write-Host "  ZIP64       : $hasZip64"

    if ($entryCount -gt $MaxEntryCount) {
        Write-Error "Gate failed: entry_count=$entryCount exceeds max=$MaxEntryCount."
        exit 12
    }

    if ($FailOnZip64 -and $hasZip64) {
        Write-Error "Gate failed: ZIP64 structure detected."
        exit 13
    }

    Write-Host "Gate passed: APK structure is install-safe under current policy."
    exit 0
}
finally {
    if ($zipArchive -ne $null) {
        $zipArchive.Dispose()
    }
    if ($fileStream -ne $null) {
        $fileStream.Dispose()
    }
}

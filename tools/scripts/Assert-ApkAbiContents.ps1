param(
    [Parameter(Mandatory = $true)]
    [string]$ApkPath,

    [Parameter(Mandatory = $false)]
    [string[]]$RequiredAbis = @(),

    [Parameter(Mandatory = $false)]
    [string[]]$RequiredSoByAbi = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ApkPath)) {
    throw "APK not found: $ApkPath"
}

$normalizedRequiredAbis = New-Object System.Collections.Generic.List[string]
foreach ($item in $RequiredAbis) {
    if ([string]::IsNullOrWhiteSpace($item)) {
        continue
    }
    foreach ($token in ($item -split "[;,]")) {
        $abi = $token.Trim()
        if (-not [string]::IsNullOrWhiteSpace($abi)) {
            $normalizedRequiredAbis.Add($abi)
        }
    }
}
$RequiredAbis = $normalizedRequiredAbis.ToArray()

$normalizedRequiredSoByAbi = New-Object System.Collections.Generic.List[string]
foreach ($item in $RequiredSoByAbi) {
    if ([string]::IsNullOrWhiteSpace($item)) {
        continue
    }
    foreach ($token in ($item -split "[;,]")) {
        $rule = $token.Trim()
        if (-not [string]::IsNullOrWhiteSpace($rule)) {
            $normalizedRequiredSoByAbi.Add($rule)
        }
    }
}
$RequiredSoByAbi = $normalizedRequiredSoByAbi.ToArray()

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Normalize-ZipPath {
    param([string]$Path)
    return $Path.Replace("\", "/").ToLowerInvariant()
}

$zipArchive = $null
$fileStream = $null

try {
    $fileStream = [System.IO.File]::Open($ApkPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    $zipArchive = New-Object System.IO.Compression.ZipArchive($fileStream, [System.IO.Compression.ZipArchiveMode]::Read, $true)
    $entrySet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($entry in $zipArchive.Entries) {
        [void]$entrySet.Add((Normalize-ZipPath -Path $entry.FullName))
    }

    $errors = New-Object System.Collections.Generic.List[string]

    foreach ($abi in $RequiredAbis) {
        $normalizedAbi = $abi.Trim()
        if ([string]::IsNullOrWhiteSpace($normalizedAbi)) {
            continue
        }

        $prefix = ("lib/{0}/" -f $normalizedAbi).ToLowerInvariant()
        $hasAbi = $false
        foreach ($name in $entrySet) {
            if ($name.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                $hasAbi = $true
                break
            }
        }

        if (-not $hasAbi) {
            $errors.Add("Missing ABI directory in APK: lib/$normalizedAbi/")
        }
    }

    foreach ($item in $RequiredSoByAbi) {
        $raw = $item.Trim()
        if ([string]::IsNullOrWhiteSpace($raw)) {
            continue
        }

        $sep = $raw.IndexOf(":")
        if ($sep -lt 1 -or $sep -ge $raw.Length - 1) {
            $errors.Add("Invalid RequiredSoByAbi item '$raw'. Expected format abi:libname.so")
            continue
        }

        $abi = $raw.Substring(0, $sep).Trim()
        $soName = $raw.Substring($sep + 1).Trim()
        $soPath = Normalize-ZipPath -Path ("lib/{0}/{1}" -f $abi, $soName)
        if (-not $entrySet.Contains($soPath)) {
            $errors.Add("Missing shared library in APK: lib/$abi/$soName")
        }
    }

    Write-Host "APK ABI Gate"
    Write-Host "  Path              : $ApkPath"
    if ($RequiredAbis.Count -gt 0) {
        Write-Host "  Required ABIs     : $($RequiredAbis -join ', ')"
    }
    if ($RequiredSoByAbi.Count -gt 0) {
        Write-Host "  Required ABI+SO   : $($RequiredSoByAbi -join ', ')"
    }

    if ($errors.Count -gt 0) {
        foreach ($err in $errors) {
            [Console]::Error.WriteLine($err)
        }
        exit 21
    }

    Write-Host "Gate passed: required ABI/native libraries are present."
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

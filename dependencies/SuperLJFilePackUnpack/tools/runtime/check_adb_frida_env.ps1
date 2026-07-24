param(
    [string]$Serial = "",
    [string]$FridaServerWorkDir = ".",
    [string]$PackageName = "com.mengyu.mini.my.locojoy"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:PassCount = 0
$script:WarnCount = 0
$script:FailCount = 0

function Write-Result {
    param(
        [ValidateSet("PASS", "WARN", "FAIL", "INFO")]
        [string]$Level,
        [string]$Check,
        [string]$Message
    )

    switch ($Level) {
        "PASS" { $script:PassCount++; $color = "Green" }
        "WARN" { $script:WarnCount++; $color = "Yellow" }
        "FAIL" { $script:FailCount++; $color = "Red" }
        default { $color = "Cyan" }
    }

    $prefix = "[{0}]" -f $Level
    Write-Host ("{0} {1,-26} {2}" -f $prefix, $Check, $Message) -ForegroundColor $color
}

function Resolve-Executable {
    param(
        [string]$Name,
        [string[]]$FallbackPaths
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -ne $cmd -and $cmd.Source) {
        return $cmd.Source
    }

    foreach ($p in $FallbackPaths) {
        if (Test-Path $p) {
            return $p
        }
    }
    return $null
}

function Invoke-External {
    param(
        [string]$Exe,
        [string[]]$CommandArgs
    )

    try {
        $raw = & $Exe @CommandArgs 2>&1
        $code = $LASTEXITCODE
        $text = ($raw | Out-String).Trim()
        return [pscustomobject]@{
            Code = $code
            Out  = $text
        }
    } catch {
        return [pscustomobject]@{
            Code = 99999
            Out  = $_.Exception.Message
        }
    }
}

function Map-AndroidAbiToFridaArch {
    param([string]$Abi)
    switch ($Abi) {
        "arm64-v8a"   { return "android-arm64" }
        "armeabi-v7a" { return "android-arm" }
        "armeabi"     { return "android-arm" }
        "x86"         { return "android-x86" }
        "x86_64"      { return "android-x86_64" }
        default       { return "" }
    }
}

Write-Host "=== MT3 ADB/Frida Environment Check ===" -ForegroundColor White
Write-Host ("Time: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor Gray

$adbExe = Resolve-Executable -Name "adb" -FallbackPaths @(
    "D:\Android\platform-tools\adb.exe"
)
$fridaExe = Resolve-Executable -Name "frida" -FallbackPaths @(
    "$env:APPDATA\Python\Python314\Scripts\frida.exe",
    "$env:APPDATA\Python\Python313\Scripts\frida.exe",
    "$env:APPDATA\Python\Python312\Scripts\frida.exe"
)
$fridaPsExe = Resolve-Executable -Name "frida-ps" -FallbackPaths @(
    "$env:APPDATA\Python\Python314\Scripts\frida-ps.exe",
    "$env:APPDATA\Python\Python313\Scripts\frida-ps.exe",
    "$env:APPDATA\Python\Python312\Scripts\frida-ps.exe"
)

if ($null -eq $adbExe) {
    Write-Result "FAIL" "adb(local)" "Not found in PATH"
    Write-Host "Install adb (platform-tools) first." -ForegroundColor Yellow
    exit 2
}
Write-Result "PASS" "adb(local)" $adbExe

if ($null -eq $fridaExe) {
    Write-Result "FAIL" "frida(local)" "Not found in PATH"
    Write-Host "Install frida-tools: python -m pip install --upgrade frida-tools" -ForegroundColor Yellow
    exit 2
}
Write-Result "PASS" "frida(local)" $fridaExe

if ($null -eq $fridaPsExe) {
    Write-Result "FAIL" "frida-ps(local)" "Not found in PATH"
    Write-Host "frida-tools install seems incomplete." -ForegroundColor Yellow
    exit 2
}
Write-Result "PASS" "frida-ps(local)" $fridaPsExe

$adbVer = Invoke-External -Exe $adbExe -CommandArgs @("version")
if ($adbVer.Code -eq 0) {
    Write-Result "PASS" "adb(version)" (($adbVer.Out -split "`r?`n")[0])
} else {
    Write-Result "FAIL" "adb(version)" $adbVer.Out
}

$fridaVerResp = Invoke-External -Exe $fridaExe -CommandArgs @("--version")
$fridaVersion = ""
if ($fridaVerResp.Code -eq 0 -and $fridaVerResp.Out -match "\d+\.\d+\.\d+") {
    $fridaVersion = $Matches[0]
    Write-Result "PASS" "frida(version)" $fridaVersion
} else {
    Write-Result "FAIL" "frida(version)" $fridaVerResp.Out
}

$devices = Invoke-External -Exe $adbExe -CommandArgs @("devices")
if ($devices.Code -ne 0) {
    Write-Result "FAIL" "adb(devices)" $devices.Out
    exit 3
}

$deviceLines = @()
$allLines = $devices.Out -split "`r?`n"
foreach ($line in $allLines) {
    if ($line -match "^\s*([^\s]+)\s+device\s*$") {
        $deviceLines += $Matches[1]
    }
}

if ($deviceLines.Count -eq 0) {
    Write-Result "FAIL" "device(usb)" "No device in 'device' state"
    $badLines = @($allLines | Where-Object { $_ -match "^\s*[^\s]+\s+(offline|unauthorized)\s*$" })
    if ($badLines.Count -gt 0) {
        Write-Host "Detected non-ready devices:" -ForegroundColor Yellow
        $badLines | ForEach-Object { Write-Host ("  " + $_) -ForegroundColor Yellow }
    }
    Write-Host "Hint: check USB debugging / authorization dialog / cable." -ForegroundColor Yellow
    exit 3
}

if ([string]::IsNullOrWhiteSpace($Serial)) {
    $Serial = $deviceLines[0]
}

if (-not ($deviceLines -contains $Serial)) {
    Write-Result "FAIL" "device(select)" ("Specified serial not ready: " + $Serial)
    exit 3
}
Write-Result "PASS" "device(select)" $Serial

$adbPrefix = @()
if (-not [string]::IsNullOrWhiteSpace($Serial)) {
    $adbPrefix = @("-s", $Serial)
}

function Invoke-Adb {
    param([string[]]$SubArgs)
    return Invoke-External -Exe $adbExe -CommandArgs ($adbPrefix + $SubArgs)
}

$abiResp = Invoke-Adb -SubArgs @("shell", "getprop", "ro.product.cpu.abi")
$abi = $abiResp.Out.Trim()
if ($abiResp.Code -eq 0 -and -not [string]::IsNullOrWhiteSpace($abi)) {
    Write-Result "PASS" "device(abi)" $abi
} else {
    Write-Result "WARN" "device(abi)" ("Unable to read ABI: " + $abiResp.Out)
}

$sdkResp = Invoke-Adb -SubArgs @("shell", "getprop", "ro.build.version.sdk")
if ($sdkResp.Code -eq 0 -and $sdkResp.Out.Trim().Length -gt 0) {
    Write-Result "INFO" "device(android_sdk)" $sdkResp.Out.Trim()
}

$fridaPs = Invoke-External -Exe $fridaPsExe -CommandArgs @("-U")
if ($fridaPs.Code -eq 0) {
    Write-Result "PASS" "frida(connect)" "frida-ps -U succeeded"
} else {
    Write-Result "WARN" "frida(connect)" "frida-ps -U failed (likely frida-server not running)"
    if ($fridaPs.Out.Length -gt 0) {
        Write-Host ("  detail: " + $fridaPs.Out) -ForegroundColor Yellow
    }
}

$psA = Invoke-Adb -SubArgs @("shell", "ps", "-A")
$psText = $psA.Out
if ($psA.Code -ne 0 -or [string]::IsNullOrWhiteSpace($psText)) {
    $psFallback = Invoke-Adb -SubArgs @("shell", "ps")
    $psText = $psFallback.Out
}

if ($psText -match "frida-server") {
    Write-Result "PASS" "frida-server(proc)" "Running on device"
} else {
    Write-Result "WARN" "frida-server(proc)" "Process not detected"
}

$suResp = Invoke-Adb -SubArgs @("shell", "su", "-c", "id")
if ($suResp.Code -eq 0 -and $suResp.Out -match "uid=0") {
    Write-Result "PASS" "device(root_for_su)" "su works"
} else {
    Write-Result "WARN" "device(root_for_su)" "su not available or denied"
}

$fridaArch = ""
if (-not [string]::IsNullOrWhiteSpace($abi)) {
    $fridaArch = Map-AndroidAbiToFridaArch -Abi $abi
}
if ([string]::IsNullOrWhiteSpace($fridaArch)) {
    Write-Result "WARN" "frida(arch_map)" ("Unknown ABI mapping: " + $abi)
} else {
    Write-Result "PASS" "frida(arch_map)" ($abi + " -> " + $fridaArch)
}

$cwd = (Resolve-Path $FridaServerWorkDir).Path
$serverBase = ""
$serverXz = ""
$downloadUrl = ""
if (-not [string]::IsNullOrWhiteSpace($fridaVersion) -and -not [string]::IsNullOrWhiteSpace($fridaArch)) {
    $serverXz = "frida-server-{0}-{1}.xz" -f $fridaVersion, $fridaArch
    $serverBase = "frida-server-{0}-{1}" -f $fridaVersion, $fridaArch
    $downloadUrl = "https://github.com/frida/frida/releases/download/{0}/{1}" -f $fridaVersion, $serverXz
    Write-Result "INFO" "frida(server_asset)" $serverXz
}

Write-Host ""
Write-Host "=== Suggested Next Commands ===" -ForegroundColor White
Write-Host ("Device serial: {0}" -f $Serial) -ForegroundColor Gray

if (-not [string]::IsNullOrWhiteSpace($downloadUrl)) {
    Write-Host ""
    Write-Host "1) Download frida-server package" -ForegroundColor Cyan
    Write-Host ("curl.exe -L `"{0}`" -o `"{1}\{2}`"" -f $downloadUrl, $cwd, $serverXz)

    Write-Host ""
    Write-Host "2) Extract .xz -> binary (Python lzma)" -ForegroundColor Cyan
    Write-Host "@'"
    Write-Host "import lzma"
    Write-Host ("data=lzma.open(r'{0}\{1}','rb').read()" -f $cwd, $serverXz)
    Write-Host ("open(r'{0}\frida-server','wb').write(data)" -f $cwd)
    Write-Host "print('ok')"
    Write-Host "'@ | python -"

    Write-Host ""
    Write-Host "3) Push and run on device (root/su required)" -ForegroundColor Cyan
    Write-Host ("`"{0}`" -s {1} push `"{2}\frida-server`" /data/local/tmp/frida-server" -f $adbExe, $Serial, $cwd)
    Write-Host ("`"{0}`" -s {1} shell `"chmod 755 /data/local/tmp/frida-server`"" -f $adbExe, $Serial)
    Write-Host ("`"{0}`" -s {1} shell `"su -c '/data/local/tmp/frida-server -D &'`"" -f $adbExe, $Serial)
}

Write-Host ""
Write-Host "4) Verify and run MT3 probe script" -ForegroundColor Cyan
Write-Host ("`"{0}`" -U" -f $fridaPsExe)
Write-Host ("`"{0}`" -U -f {1} -l dependencies/SuperLJFilePackUnpack/tools/runtime/lj_runtime_key_probe.js --no-pause" -f $fridaExe, $PackageName)

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor White
Write-Host ("PASS={0} WARN={1} FAIL={2}" -f $script:PassCount, $script:WarnCount, $script:FailCount)

if ($script:FailCount -gt 0) {
    exit 1
}
exit 0

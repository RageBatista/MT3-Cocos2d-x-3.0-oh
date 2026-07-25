param(
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$exeName = if ($Configuration -eq "Debug") { "TexturePacker_CEGUI_d.exe" } else { "TexturePacker_CEGUI.exe" }
$exe = Join-Path $root ("bin\" + $Configuration.ToLower() + "\\" + $exeName)

if (-not (Test-Path $exe)) {
    throw "Executable not found: $exe"
}

$uiOutput = (& $exe --smoke-ui 2>&1 | Out-String)
$uiCode = $LASTEXITCODE

Write-Host $uiOutput.Trim()

if (($uiCode -ne 0) -and ($uiOutput -notmatch "SMOKE_UI_PASS")) {
    throw "UI smoke failed, exit code: $uiCode"
}

Write-Host "UI smoke passed."

$src = Join-Path $root "..\free-tex-packer\src\client\resources\static\images\browser"
$out = Join-Path $root "workspace\smoke-out"
$packOutput = (& $exe --smoke-pack --src=$src --out=$out --atlas=tp_cegui_smoke 2>&1 | Out-String)
$packCode = $LASTEXITCODE

Write-Host $packOutput.Trim()

if (($packCode -ne 0) -and ($packOutput -notmatch "SMOKE_PACK_PASS")) {
    throw "Pack smoke failed, exit code: $packCode"
}

Write-Host "Pack smoke passed."

$cliOut = Join-Path $root "workspace\smoke-cli"
$cliOutput = (& $exe --pack --src=$src --out=$cliOut --atlas=tp_cegui_cli 2>&1 | Out-String)
$cliCode = $LASTEXITCODE

Write-Host $cliOutput.Trim()

if (($cliCode -ne 0) -or ($cliOutput -notmatch "PACK_PASS")) {
    throw "CLI pack smoke failed, exit code: $cliCode"
}

Write-Host "CLI pack smoke passed."

$splitOut = Join-Path $root "workspace\smoke-split"
$splitOutput = (& $exe --pack --src=$src --out=$splitOut --atlas=tp_cegui_split --max-width=180 --max-height=80 2>&1 | Out-String)
$splitCode = $LASTEXITCODE

Write-Host $splitOutput.Trim()

if (($splitCode -ne 0) -or ($splitOutput -notmatch "PACK_PASS")) {
    throw "Auto-split smoke failed, exit code: $splitCode"
}

if ($splitOutput -notmatch "PACK_PAGES:\s*[2-9]") {
    throw "Auto-split smoke expected PACK_PAGES >= 2"
}

Write-Host "Auto-split smoke passed."

param(
    [string]$ProjectRoot = ".",
    [string]$InventoryRoot = "",
    [string]$PolicyPath = ".claude/config/docs-audit-policy.json",
    [string]$ReviewManifestPath = ".claude/config/docs-review-manifest.json",
    [string]$OutputPath = ".superpowers/audits/mt3-docs-audit.json",
    [string]$BrokenLinkBaselinePath = "",
    [switch]$FailOnBrokenLinks,
    [switch]$FailOnNewBrokenLinks,
    [switch]$RequireReviewedFirstParty
)

function Resolve-ProjectPath {
    param(
        [string]$Path,
        [string]$Root
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Root $Path))
}

$pythonScript = Join-Path $PSScriptRoot "audit_mt3_docs.py"
if (-not (Test-Path -LiteralPath $pythonScript -PathType Leaf)) {
    [Console]::Error.WriteLine("MT3 docs audit failed: implementation file is missing.")
    exit 2
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$InventoryRoot = if ([string]::IsNullOrWhiteSpace($InventoryRoot)) {
    $ProjectRoot
} else {
    Resolve-ProjectPath -Path $InventoryRoot -Root $ProjectRoot
}
$PolicyPath = Resolve-ProjectPath -Path $PolicyPath -Root $ProjectRoot
$ReviewManifestPath = Resolve-ProjectPath -Path $ReviewManifestPath -Root $ProjectRoot
$OutputPath = Resolve-ProjectPath -Path $OutputPath -Root $ProjectRoot
if (-not [string]::IsNullOrWhiteSpace($BrokenLinkBaselinePath)) {
    $BrokenLinkBaselinePath = Resolve-ProjectPath -Path $BrokenLinkBaselinePath -Root $ProjectRoot
}

$pythonCommand = Get-Command python -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -eq $pythonCommand) {
    [Console]::Error.WriteLine("MT3 docs audit failed: Python executable was not found.")
    exit 2
}

$arguments = @(
    "-X", "utf8", $pythonScript,
    "--project-root", $ProjectRoot,
    "--inventory-root", $InventoryRoot,
    "--policy", $PolicyPath,
    "--review-manifest", $ReviewManifestPath,
    "--output", $OutputPath
)
if (-not [string]::IsNullOrWhiteSpace($BrokenLinkBaselinePath)) {
    $arguments += @("--broken-link-baseline", $BrokenLinkBaselinePath)
}
if ($FailOnBrokenLinks) { $arguments += "--fail-on-broken-links" }
if ($FailOnNewBrokenLinks) { $arguments += "--fail-on-new-broken-links" }
if ($RequireReviewedFirstParty) { $arguments += "--require-reviewed-first-party" }

& $pythonCommand.Source @arguments
$pythonExitCode = $LASTEXITCODE
if ($null -eq $pythonExitCode) {
    [Console]::Error.WriteLine("MT3 docs audit failed: Python process returned no exit code.")
    exit 2
}
exit [int]$pythonExitCode

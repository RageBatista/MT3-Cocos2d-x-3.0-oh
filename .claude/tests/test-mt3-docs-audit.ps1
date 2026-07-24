[CmdletBinding()]
param(
    [string]$ProjectRoot = (Join-Path $PSScriptRoot "..\..")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$auditScript = Join-Path $projectRoot ".claude\scripts\audit_mt3_docs.ps1"
$pythonScript = Join-Path $projectRoot ".claude\scripts\audit_mt3_docs.py"
$policyPath = Join-Path $projectRoot ".claude\config\docs-audit-policy.json"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$fixtureRoot = Join-Path $env:TEMP ("mt3-docs-audit-fixture-" + [guid]::NewGuid().ToString("N"))
$reportPath = Join-Path $fixtureRoot "reports\mt3-docs-audit.json"
$failed = $false

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Write-Utf8Fixture {
    param(
        [string]$Path,
        [string]$Text
    )

    $parent = Split-Path -Parent $Path
    [System.IO.Directory]::CreateDirectory($parent) | Out-Null
    [System.IO.File]::WriteAllText($Path, ($Text -replace "`r`n", "`n"), $utf8NoBom)
}

function Invoke-PowerShellScriptCapture {
    param(
        [string]$FilePath,
        [string[]]$ScriptArguments,
        [AllowNull()]
        [string]$PathOverride = $null
    )

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = (Get-Process -Id $PID).Path
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    if ($null -ne $PathOverride) {
        $startInfo.EnvironmentVariables["PATH"] = $PathOverride
    }
    $quotedArguments = @("-NoLogo", "-NoProfile", "-File", $FilePath) + $ScriptArguments | ForEach-Object {
        '"' + ($_ -replace '"', '\"') + '"'
    }
    $startInfo.Arguments = $quotedArguments -join " "

    $process = [System.Diagnostics.Process]::Start($startInfo)
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    return [pscustomobject]@{
        ExitCode = $process.ExitCode
        Stdout = $stdout
        Stderr = $stderr
    }
}

$missingPythonFixtureRoot = Join-Path $env:TEMP ("mt3-docs-audit-no-python-" + [guid]::NewGuid().ToString("N"))
try {
    New-Item -ItemType Directory -Path $missingPythonFixtureRoot | Out-Null
    $missingPythonResult = Invoke-PowerShellScriptCapture `
        -FilePath $auditScript `
        -ScriptArguments @(
            "-ProjectRoot", $projectRoot,
            "-PolicyPath", $policyPath,
            "-OutputPath", (Join-Path $missingPythonFixtureRoot "unused.json")
        ) `
        -PathOverride $missingPythonFixtureRoot
    Assert-True ($missingPythonResult.ExitCode -eq 2) "missing Python exit code"
    Assert-True ($missingPythonResult.Stderr -notmatch '[A-Za-z]:[\\/]') "missing Python stderr exposed an absolute path"
    Write-Output "PASS: missing Python fails closed without absolute paths"
} catch {
    $failed = $true
    Write-Output "FAIL: missing Python fails closed without absolute paths: $($_.Exception.Message)"
} finally {
    $tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $missingPythonFixtureFullPath = [System.IO.Path]::GetFullPath($missingPythonFixtureRoot)
    Assert-True ($missingPythonFixtureFullPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe missing Python fixture cleanup path"
    if (Test-Path -LiteralPath $missingPythonFixtureFullPath -PathType Container) {
        Remove-Item -LiteralPath $missingPythonFixtureFullPath -Recurse -Force
    }
    Assert-True (-not (Test-Path -LiteralPath $missingPythonFixtureFullPath)) "missing Python fixture cleanup failed"
}

New-Item -ItemType Directory -Path $fixtureRoot | Out-Null
git -C $fixtureRoot init | Out-Null

try {
    $guideTokens = 1..260 | ForEach-Object { "guide-token-{0:D3}" -f $_ }
    $guideText = "# Current Guide`n`n" + ($guideTokens -join " ") + "`n"
    $nearTokens = @($guideTokens[0..229]) + @(1..30 | ForEach-Object { "near-token-{0:D3}" -f $_ })
    $nearText = "# Current Guide`n`n" + ($nearTokens -join " ") + "`n"
    $licenseText = "Sample vendor license text.`nRedistribution terms are identical for this fixture.`n"
    $linkBoundaryText = @(
        "# Link Boundaries"
        ""
        '`[inline-code](inline-code.md)`'
        "    [four-space](four-space.md)"
        "`t[tab](tab.md)"
        '\[escaped](escaped.md)'
        '[sample](foo_(bar).md)'
        '``cross-line code starts'
        '[sample](cross-line-code-missing.md) `'
        'ends`` [after span](after-span-missing.md)'
    ) -join "`n"

    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\current.md") -Text "# Current`n`nSee the [current guide](guide.md), [same guide with different case](GUIDE.md), and [diagram](assets/diagram.png).`n"
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\guide.md") -Text $guideText
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\copy.md") -Text $guideText
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\near.md") -Text $nearText
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\broken.md") -Text "# Broken`n`nSee the [missing page](missing.md).`n"
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\link-boundaries.md") -Text ($linkBoundaryText + "`n")
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\foo_(bar).md") -Text "# Nested Parentheses Target`n"
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\frontmatter.md") -Text "---`ntitle: Front Matter`n---`n`n# Front Matter`n"
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\source-links.md") -Text @'
# Source Line Links

[valid line](../client/sample.cpp:2)
[valid range](../client/sample.cpp:2-3)
[document line](guide.md:1)
[out of range](../client/sample.cpp:9)
[missing source](../client/missing.cpp:3)
[plain directory](dir/)
[directory line](dir:999)

```text
[fenced missing source](../client/fenced.cpp:1)
```
'@
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "client\sample.cpp") -Text "line 1`nline 2`nline 3`n"
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\dir\asset.txt") -Text "directory fixture`n"
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\unclosed-fence.md") -Text @'
# Unclosed Fence

```text
[ignored](missing-in-fence.md)
'@
    $badEncodingPath = Join-Path $fixtureRoot "docs\bad-encoding.md"
    [System.IO.File]::WriteAllText($badEncodingPath, "# Bad Encoding`r`n", [System.Text.UTF8Encoding]::new($true))
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "docs\assets\diagram.png") -Text "non-editorial fixture asset`n"
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "vendor\pkg\docs\LICENSE.txt") -Text $licenseText
    Write-Utf8Fixture -Path (Join-Path $fixtureRoot "vendor\pkg2\docs\LICENSE.txt") -Text $licenseText
    git -C $fixtureRoot add -- docs client | Out-Null

    & $auditScript `
        -ProjectRoot $fixtureRoot `
        -PolicyPath $policyPath `
        -OutputPath $reportPath
    Assert-True ($LASTEXITCODE -eq 1) "configured quality gates must fail the induced fixture"

    $report = Get-Content -LiteralPath $reportPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
    Assert-True ($report.summary.docs_directories -eq 1) "current docs directory count"
    Assert-True ($report.summary.exact_duplicate_groups -eq 1) "exact duplicate groups"
    Assert-True ($report.near_duplicate_pairs.Count -eq 1) "near duplicate detection"
    $brokenTargets = @($report.broken_links | ForEach-Object { $_.target } | Sort-Object)
    Assert-True ($report.summary.markdown_records -eq 11) "Markdown record count"
    Assert-True ($report.summary.markdown_links -eq 13) "Markdown link count"
    Assert-True ($report.summary.source_line_links -eq 4) "source line link count"
    Assert-True ($report.summary.source_line_link_issues -eq 1) "source line range validation"
    Assert-True ($report.summary.encoding_issues -eq 1) "strict Markdown encoding validation"
    Assert-True ($report.summary.fence_issues -eq 1) "unclosed fence validation"
    Assert-True (@($report.fail_closed.reasons) -contains "encoding_issues") "encoding gate reason"
    Assert-True (@($report.fail_closed.reasons) -contains "fence_issues") "fence gate reason"
    Assert-True (@($report.fail_closed.reasons) -contains "exact_duplicates") "exact duplicate gate reason"
    Assert-True ($report.broken_links.Count -eq 5) "broken link detection"
    Assert-True (($brokenTargets -join "|") -eq "../client/missing.cpp:3|../client/sample.cpp:9|after-span-missing.md|dir:999|missing.md") "source lines, directory line targets, Markdown code spans, and escaped links"
    Assert-True ($report.new_broken_links.Count -eq 0) "new broken links default output"
    $guideEdges = @($report.link_edges | Where-Object { $_.source -eq "docs/current.md" -and $_.target -eq "docs/guide.md" })
    $resourceEdges = @($report.link_edges | Where-Object { $_.source -eq "docs/current.md" -and $_.target -eq "docs/assets/diagram.png" })
    Assert-True ($guideEdges.Count -eq 1) "case-insensitive link edge deduplication"
    Assert-True ($resourceEdges.Count -eq 1) "existing non-editorial resource edge"
    Assert-True (@($report.link_edges | Where-Object { $_.source -eq "docs/source-links.md" -and $_.target -eq "docs/dir" }).Count -eq 1) "plain directory link remains valid"
    Assert-True (@($report.link_edges | Where-Object { $_.source -eq "docs/source-links.md" -and $_.target -eq "client/sample.cpp" }).Count -eq 1) "valid source line links share one graph edge"
    Assert-True (@($report.source_line_links | Where-Object { $_.status -eq "valid" }).Count -eq 3) "valid source line records"
    Assert-True (@($report.source_line_links | Where-Object { $_.status -eq "line_out_of_range" }).Count -eq 1) "out-of-range source line record"
    Assert-True (@($report.link_edges | Where-Object { $_.source -eq "docs/broken.md" }).Count -eq 0) "broken links excluded from link graph"
    $currentRecord = @($report.records | Where-Object { $_.path -eq "docs/current.md" })[0]
    $guideRecord = @($report.records | Where-Object { $_.path -eq "docs/guide.md" })[0]
    Assert-True ((@($currentRecord.outbound_links) -join "|") -eq "docs/guide.md") "record outbound links"
    Assert-True ((@($guideRecord.inbound_links) -join "|") -eq "docs/current.md|docs/source-links.md") "record inbound links"
    Assert-True (@($report.records | Where-Object { @($_.inbound_links) -contains "docs/assets/diagram.png" }).Count -eq 0) "non-record resource excluded from inbound adjacency"
    Assert-True ($report.heading_issues.Where({ $_.path -eq 'docs/frontmatter.md' }).Count -eq 0) "YAML front matter ignored by heading audit"
    Assert-True ($report.records.Where({ $_.path -like 'vendor/*/docs/LICENSE.txt' }).Count -eq 0) "nested vendor Docs excluded from current scope"
    $serializedReport = $report | ConvertTo-Json -Depth 100
    Assert-True (-not $serializedReport.Contains($fixtureRoot)) "report excludes fixture absolute paths"
    Assert-True ($serializedReport -notmatch '[A-Za-z]:\\') "report excludes Windows absolute paths"

    Write-Output "PASS: MT3 docs audit fixture"
} catch {
    $failed = $true
    Write-Output "FAIL: MT3 docs audit fixture: $($_.Exception.Message)"
} finally {
    $tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $fixtureFullPath = [System.IO.Path]::GetFullPath($fixtureRoot)
    Assert-True ($fixtureFullPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe fixture cleanup path"
    if (Test-Path -LiteralPath $fixtureFullPath -PathType Container) {
        Remove-Item -LiteralPath $fixtureFullPath -Recurse -Force
    }
    Assert-True (-not (Test-Path -LiteralPath $fixtureFullPath)) "fixture cleanup failed"
}

$qualityGateFixtureRoot = Join-Path $env:TEMP ("mt3-docs-audit-quality-gates-" + [guid]::NewGuid().ToString("N"))
try {
    New-Item -ItemType Directory -Path $qualityGateFixtureRoot | Out-Null
    git -C $qualityGateFixtureRoot init | Out-Null

    function Invoke-QualityGateFixture {
        param([string]$Name)

        git -C $qualityGateFixtureRoot add -- docs | Out-Null
        $caseReportPath = Join-Path $qualityGateFixtureRoot ("reports\" + $Name + ".json")
        $auditOutput = @(& $auditScript -ProjectRoot $qualityGateFixtureRoot -PolicyPath $policyPath -OutputPath $caseReportPath)
        $auditExitCode = $LASTEXITCODE
        return [pscustomobject]@{
            ExitCode = $auditExitCode
            Output = [string]::Join([Environment]::NewLine, @($auditOutput | ForEach-Object { [string]$_ }))
            Report = Get-Content -Raw -Encoding UTF8 -LiteralPath $caseReportPath | ConvertFrom-Json -ErrorAction Stop
        }
    }

    $documentA = Join-Path $qualityGateFixtureRoot "docs\a.md"
    $documentB = Join-Path $qualityGateFixtureRoot "docs\b.md"
    Write-Utf8Fixture -Path $documentA -Text "# A`n`nUnique baseline.`n"
    $clean = Invoke-QualityGateFixture -Name "clean"
    Assert-True ($clean.ExitCode -eq 0 -and $clean.Report.status -eq "PASS") "clean quality gate fixture"

    [System.IO.File]::WriteAllText($documentA, "# A`r`n", [System.Text.UTF8Encoding]::new($true))
    $encodingFailure = Invoke-QualityGateFixture -Name "encoding"
    Assert-True ($encodingFailure.ExitCode -eq 1 -and @($encodingFailure.Report.fail_closed.reasons) -contains "encoding_issues") "induced encoding issue must fail"

    Write-Utf8Fixture -Path $documentA -Text @'
# A

```text
unclosed
'@
    $fenceFailure = Invoke-QualityGateFixture -Name "fence"
    Assert-True ($fenceFailure.ExitCode -eq 1 -and @($fenceFailure.Report.fail_closed.reasons) -contains "fence_issues") "induced fence issue must fail"

    Write-Utf8Fixture -Path $documentA -Text "## A`n`nHeading starts below H1.`n"
    $headingFailure = Invoke-QualityGateFixture -Name "heading"
    Assert-True ($headingFailure.ExitCode -eq 1 -and @($headingFailure.Report.fail_closed.reasons) -contains "heading_issues") "induced heading issue must fail"

    Write-Utf8Fixture -Path $documentA -Text "# Shared`n`nExact duplicate body.`n"
    Write-Utf8Fixture -Path $documentB -Text "# Shared`n`nExact duplicate body.`n"
    $duplicateFailure = Invoke-QualityGateFixture -Name "duplicate"
    Assert-True ($duplicateFailure.ExitCode -eq 1 -and @($duplicateFailure.Report.fail_closed.reasons) -contains "exact_duplicates") "induced exact duplicate must fail"

    Write-Utf8Fixture -Path $documentA -Text "# A`n`nUnique repaired A.`n"
    Write-Utf8Fixture -Path $documentB -Text "# B`n`nUnique repaired B.`n"
    $repaired = Invoke-QualityGateFixture -Name "repaired"
    Assert-True ($repaired.ExitCode -eq 0 -and $repaired.Report.status -eq "PASS") "repaired quality gate fixture"
    Write-Output "PASS: configured docs quality gates fail closed"
} catch {
    $failed = $true
    Write-Output "FAIL: configured docs quality gates fail closed: $($_.Exception.Message)"
} finally {
    $tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $qualityGateFixtureFullPath = [System.IO.Path]::GetFullPath($qualityGateFixtureRoot)
    Assert-True ($qualityGateFixtureFullPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe quality gate fixture cleanup path"
    if (Test-Path -LiteralPath $qualityGateFixtureFullPath -PathType Container) {
        Remove-Item -LiteralPath $qualityGateFixtureFullPath -Recurse -Force
    }
    Assert-True (-not (Test-Path -LiteralPath $qualityGateFixtureFullPath)) "quality gate fixture cleanup failed"
}

$ignoredFixtureRoot = Join-Path $env:TEMP ("mt3-docs-audit-ignored-" + [guid]::NewGuid().ToString("N"))
$ignoredProjectRoot = Join-Path $ignoredFixtureRoot "project"
$ignoredInventoryRoot = Join-Path $ignoredFixtureRoot "inventory"
$ignoredReportPath = Join-Path $ignoredFixtureRoot "reports\mt3-docs-audit.json"
try {
    New-Item -ItemType Directory -Path $ignoredProjectRoot | Out-Null
    New-Item -ItemType Directory -Path $ignoredInventoryRoot | Out-Null
    git -C $ignoredProjectRoot init | Out-Null
    git -C $ignoredInventoryRoot init | Out-Null
    Write-Utf8Fixture -Path (Join-Path $ignoredProjectRoot ".gitignore") -Text "docs/ignored.md`n"
    Write-Utf8Fixture -Path (Join-Path $ignoredProjectRoot "docs\ignored.md") -Text "# Ignored branch document`n"

    & $auditScript `
        -ProjectRoot $ignoredProjectRoot `
        -InventoryRoot $ignoredInventoryRoot `
        -PolicyPath $policyPath `
        -OutputPath $ignoredReportPath
    Assert-True ($LASTEXITCODE -eq 0) "ignored-state auditor exit code"

    $ignoredReport = Get-Content -LiteralPath $ignoredReportPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
    $ignoredRecord = @($ignoredReport.records | Where-Object { $_.path -eq "docs/ignored.md" })
    Assert-True ($ignoredRecord.Count -eq 0) "ignored document excluded from tracked scope"
    Write-Output "PASS: tracked docs scope excludes ignored state"
} catch {
    $failed = $true
    Write-Output "FAIL: ProjectRoot ignored docs state: $($_.Exception.Message)"
} finally {
    $tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $ignoredFixtureFullPath = [System.IO.Path]::GetFullPath($ignoredFixtureRoot)
    Assert-True ($ignoredFixtureFullPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe ignored fixture cleanup path"
    if (Test-Path -LiteralPath $ignoredFixtureFullPath -PathType Container) {
        Remove-Item -LiteralPath $ignoredFixtureFullPath -Recurse -Force
    }
    Assert-True (-not (Test-Path -LiteralPath $ignoredFixtureFullPath)) "ignored fixture cleanup failed"
}

$manifestFixtureRoot = Join-Path $env:TEMP ("mt3-docs-audit-manifest-" + [guid]::NewGuid().ToString("N"))
$manifestProjectRoot = Join-Path $manifestFixtureRoot "project"
$manifestPath = Join-Path $manifestFixtureRoot "docs-review-manifest.json"
$manifestReportPath = Join-Path $manifestFixtureRoot "reports\mt3-docs-audit.json"
try {
    New-Item -ItemType Directory -Path $manifestProjectRoot | Out-Null
    git -C $manifestProjectRoot init | Out-Null
    Write-Utf8Fixture -Path (Join-Path $manifestProjectRoot "docs\human.md") -Text "# Human Review Document`n"
    Write-Utf8Fixture -Path (Join-Path $manifestProjectRoot "docs\generated\evidence.md") -Text "# Generated Evidence`n"
    Write-Utf8Fixture -Path (Join-Path $manifestProjectRoot "vendor\pkg\docs\LICENSE.txt") -Text "Vendor snapshot license.`n"
    git -C $manifestProjectRoot add -- docs | Out-Null
    Write-Utf8Fixture -Path $manifestPath -Text @'
{
  "schema_version": "1.0.0",
  "records": [
    {
      "path": "docs/human.md",
      "domain": "root_current",
      "review_status": "reviewed",
      "canonical_target": "docs/canonical.md",
      "replacement_for": ["docs/old-human.md"],
      "evidence_sources": ["AGENTS.md", ".claude/RULES.md"]
    }
  ]
}
'@

    & $auditScript `
        -ProjectRoot $manifestProjectRoot `
        -PolicyPath $policyPath `
        -ReviewManifestPath $manifestPath `
        -OutputPath $manifestReportPath `
        -RequireReviewedFirstParty
    $manifestExitCode = $LASTEXITCODE
    $manifestReport = Get-Content -LiteralPath $manifestReportPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
    $humanRecord = @($manifestReport.records | Where-Object { $_.path -eq "docs/human.md" })[0]
    $generatedRecord = @($manifestReport.records | Where-Object { $_.path -eq "docs/generated/evidence.md" })[0]
    $manifestFailures = New-Object System.Collections.Generic.List[string]

    if ($manifestExitCode -ne 0) { [void]$manifestFailures.Add("generated first-party was not exempt from strict review") }
    foreach ($propertyName in @("domain", "review_status", "canonical_target", "replacement_for", "evidence_sources")) {
        if (-not ($humanRecord.PSObject.Properties.Name -contains $propertyName)) {
            [void]$manifestFailures.Add("human record missing $propertyName")
        }
    }
    if ($humanRecord.domain -ne "root_current") { [void]$manifestFailures.Add("human domain was not merged") }
    if ($humanRecord.review_status -ne "reviewed") { [void]$manifestFailures.Add("human review status was not merged") }
    if ($humanRecord.canonical_target -ne "docs/canonical.md") { [void]$manifestFailures.Add("human canonical target was not merged") }
    if ((@($humanRecord.replacement_for) -join "|") -ne "docs/old-human.md") { [void]$manifestFailures.Add("human replacement list was not merged") }
    if ((@($humanRecord.evidence_sources) -join "|") -ne "AGENTS.md|.claude/RULES.md") { [void]$manifestFailures.Add("human evidence sources were not merged") }

    if ($generatedRecord.domain -ne "generated_evidence" -or $generatedRecord.review_status -ne "not_applicable") {
        [void]$manifestFailures.Add("generated first-party defaults are incorrect")
    }
    if ($null -ne $generatedRecord.canonical_target -or @($generatedRecord.replacement_for).Count -ne 0 -or @($generatedRecord.evidence_sources).Count -ne 0) {
        [void]$manifestFailures.Add("generated first-party optional metadata is not empty")
    }
    if ($manifestReport.summary.human_reviewable_first_party -ne 1) { [void]$manifestFailures.Add("human-reviewable summary is incorrect") }
    if ($manifestReport.summary.reviewed_first_party -ne 1) { [void]$manifestFailures.Add("reviewed summary includes the wrong set") }
    if ($manifestReport.summary.unreviewed_first_party -ne 0) { [void]$manifestFailures.Add("unreviewed summary includes generated/vendor records") }
    if ($manifestFailures.Count -gt 0) { throw ($manifestFailures -join "; ") }
    Write-Output "PASS: review manifest metadata contract"
} catch {
    $failed = $true
    Write-Output "FAIL: review manifest metadata contract: $($_.Exception.Message)"
} finally {
    $tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $manifestFixtureFullPath = [System.IO.Path]::GetFullPath($manifestFixtureRoot)
    Assert-True ($manifestFixtureFullPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe manifest fixture cleanup path"
    if (Test-Path -LiteralPath $manifestFixtureFullPath -PathType Container) {
        Remove-Item -LiteralPath $manifestFixtureFullPath -Recurse -Force
    }
    Assert-True (-not (Test-Path -LiteralPath $manifestFixtureFullPath)) "manifest fixture cleanup failed"
}

$baselineFixtureRoot = Join-Path $env:TEMP ("mt3-docs-audit-broken-baseline-" + [guid]::NewGuid().ToString("N"))
$baselineProjectRoot = Join-Path $baselineFixtureRoot "project"
$brokenBaselinePath = Join-Path $baselineFixtureRoot "broken-links-baseline.json"
$baselineReportPath = Join-Path $baselineFixtureRoot "reports\baseline-pass.json"
try {
    New-Item -ItemType Directory -Path $baselineProjectRoot | Out-Null
    git -C $baselineProjectRoot init | Out-Null
    Write-Utf8Fixture -Path (Join-Path $baselineProjectRoot "docs\existing.md") -Text "# Existing`n`n[old](missing-old.md)`n"
    git -C $baselineProjectRoot add -- docs | Out-Null
    Write-Utf8Fixture -Path $brokenBaselinePath -Text @'
{
  "broken_links": [
    {
      "path": "DOCS\\EXISTING.MD",
      "target": "MISSING-OLD.MD",
      "resolved_path": "DOCS\\MISSING-OLD.MD",
      "reason": "TARGET DOES NOT EXIST"
    }
  ]
}
'@

    & $auditScript `
        -ProjectRoot $baselineProjectRoot `
        -PolicyPath $policyPath `
        -OutputPath $baselineReportPath `
        -BrokenLinkBaselinePath $brokenBaselinePath `
        -FailOnNewBrokenLinks
    Assert-True ($LASTEXITCODE -eq 0) "existing baseline broken link gate"
    $baselineReport = Get-Content -LiteralPath $baselineReportPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
    Assert-True ($baselineReport.new_broken_links.Count -eq 0) "existing broken links excluded from new set"
    Assert-True ($baselineReport.fail_closed.fail_on_new_broken_links) "new broken link gate flag"
    Assert-True ($baselineReport.fail_closed.broken_link_baseline_path -eq "<external:broken-link-baseline>/broken-links-baseline.json") "portable broken link baseline path"

    Write-Utf8Fixture -Path (Join-Path $baselineProjectRoot "docs\existing.md") -Text "# Existing`n`n[old](missing-old.md)`n[new](missing/new.md)`n[new variant](MISSING\\NEW.MD)`n"
    $newBrokenReportPath = Join-Path $baselineFixtureRoot "reports\new-broken-fail.json"
    & $auditScript `
        -ProjectRoot $baselineProjectRoot `
        -PolicyPath $policyPath `
        -OutputPath $newBrokenReportPath `
        -BrokenLinkBaselinePath $brokenBaselinePath `
        -FailOnNewBrokenLinks
    Assert-True ($LASTEXITCODE -eq 1) "new broken link gate exit code"
    $newBrokenReport = Get-Content -LiteralPath $newBrokenReportPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
    Assert-True ($newBrokenReport.broken_links.Count -eq 3) "raw broken links remain unchanged"
    Assert-True ($newBrokenReport.new_broken_links.Count -eq 1) "new broken link count"
    Assert-True ($newBrokenReport.new_broken_links[0].target -eq "missing/new.md") "deterministic new broken link representative"
    Assert-True (@($newBrokenReport.fail_closed.reasons) -contains "new_broken_links") "new broken link fail reason"

    $missingBaselinePath = Join-Path $baselineFixtureRoot "missing-baseline.json"
    $missingBaselineResult = Invoke-PowerShellScriptCapture `
        -FilePath $auditScript `
        -ScriptArguments @(
            "-ProjectRoot", $baselineProjectRoot,
            "-PolicyPath", $policyPath,
            "-OutputPath", (Join-Path $baselineFixtureRoot "reports\missing-baseline.json"),
            "-BrokenLinkBaselinePath", $missingBaselinePath,
            "-FailOnNewBrokenLinks"
        )
    Assert-True ($missingBaselineResult.ExitCode -eq 2) "missing broken link baseline exit code"
    Assert-True ($missingBaselineResult.Stderr -notmatch '[A-Za-z]:[\\/]') "missing broken link baseline stderr exposed an absolute path"

    $invalidBaselinePath = Join-Path $baselineFixtureRoot "invalid-baseline.json"
    Write-Utf8Fixture -Path $invalidBaselinePath -Text "{invalid json`n"
    $invalidBaselineResult = Invoke-PowerShellScriptCapture `
        -FilePath $auditScript `
        -ScriptArguments @(
            "-ProjectRoot", $baselineProjectRoot,
            "-PolicyPath", $policyPath,
            "-OutputPath", (Join-Path $baselineFixtureRoot "reports\invalid-baseline.json"),
            "-BrokenLinkBaselinePath", $invalidBaselinePath,
            "-FailOnNewBrokenLinks"
        )
    Assert-True ($invalidBaselineResult.ExitCode -eq 2) "invalid broken link baseline exit code"
    Assert-True ($invalidBaselineResult.Stderr -notmatch '[A-Za-z]:[\\/]') "invalid broken link baseline stderr exposed an absolute path"
    Write-Output "PASS: new broken link baseline gate"
} catch {
    $failed = $true
    Write-Output "FAIL: new broken link baseline gate: $($_.Exception.Message)"
} finally {
    $tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $baselineFixtureFullPath = [System.IO.Path]::GetFullPath($baselineFixtureRoot)
    Assert-True ($baselineFixtureFullPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe broken baseline fixture cleanup path"
    if (Test-Path -LiteralPath $baselineFixtureFullPath -PathType Container) {
        Remove-Item -LiteralPath $baselineFixtureFullPath -Recurse -Force
    }
    Assert-True (-not (Test-Path -LiteralPath $baselineFixtureFullPath)) "broken baseline fixture cleanup failed"
}

$externalCwdFixtureRoot = Join-Path $env:TEMP ("mt3-docs-audit-external-cwd-" + [guid]::NewGuid().ToString("N"))
$externalProjectRoot = Join-Path $externalCwdFixtureRoot "project"
$externalWorkingDirectory = Join-Path $externalCwdFixtureRoot "outside"
$externalDefaultReportPath = Join-Path $externalProjectRoot ".superpowers\audits\mt3-docs-audit.json"
$externalPythonReportPath = Join-Path $externalProjectRoot ".superpowers\audits\python-direct.json"
try {
    New-Item -ItemType Directory -Path $externalProjectRoot | Out-Null
    New-Item -ItemType Directory -Path $externalWorkingDirectory | Out-Null
    git -C $externalProjectRoot init | Out-Null
    Write-Utf8Fixture -Path (Join-Path $externalProjectRoot ".gitignore") -Text (Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $projectRoot ".gitignore"))
    Write-Utf8Fixture -Path (Join-Path $externalProjectRoot "docs\guide.md") -Text "# External CWD Fixture`n"
    $externalPolicyPath = Join-Path $externalProjectRoot ".claude\config\docs-audit-policy.json"
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $externalPolicyPath)) | Out-Null
    [System.IO.File]::Copy($policyPath, $externalPolicyPath)
    git -C $externalProjectRoot add -- . | Out-Null
    git -C $externalProjectRoot -c user.name=fixture -c user.email=fixture@example.invalid commit -q -m "fixture"

    Push-Location $externalWorkingDirectory
    try {
        & $auditScript -ProjectRoot $externalProjectRoot
        $externalWrapperExitCode = $LASTEXITCODE
        & python -X utf8 $pythonScript `
            --project-root $externalProjectRoot `
            --inventory-root $externalProjectRoot `
            --policy ".claude/config/docs-audit-policy.json" `
            --review-manifest (Join-Path $externalProjectRoot ".claude\config\missing-review-manifest.json") `
            --output ".superpowers/audits/python-direct.json"
        $externalPythonExitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }

    Assert-True ($externalWrapperExitCode -eq 0) "external CWD wrapper exit code"
    Assert-True ($externalPythonExitCode -eq 0) "external CWD Python CLI exit code"
    Assert-True (Test-Path -LiteralPath $externalDefaultReportPath -PathType Leaf) "default report was not rooted at ProjectRoot"
    Assert-True (Test-Path -LiteralPath $externalPythonReportPath -PathType Leaf) "relative Python output was not rooted at ProjectRoot"
    $externalGitStatus = @(git -C $externalProjectRoot status --porcelain)
    Assert-True ($externalGitStatus.Count -eq 0) "default output polluted a clean clone"
    Write-Output "PASS: external CWD paths and ignored default output"
} catch {
    $failed = $true
    Write-Output "FAIL: external CWD paths and ignored default output: $($_.Exception.Message)"
} finally {
    $tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $externalCwdFixtureFullPath = [System.IO.Path]::GetFullPath($externalCwdFixtureRoot)
    Assert-True ($externalCwdFixtureFullPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) "unsafe external CWD fixture cleanup path"
    if (Test-Path -LiteralPath $externalCwdFixtureFullPath -PathType Container) {
        Remove-Item -LiteralPath $externalCwdFixtureFullPath -Recurse -Force
    }
    Assert-True (-not (Test-Path -LiteralPath $externalCwdFixtureFullPath)) "external CWD fixture cleanup failed"
}

try {
    $failureProbe = @'
import importlib.util
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from types import SimpleNamespace

script_path, policy_path, project_root = map(Path, sys.argv[1:4])
spec = importlib.util.spec_from_file_location("audit_mt3_docs", script_path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
policy = module.load_policy(policy_path)
failures = []

def walk_with_permission_error(*args, **kwargs):
    kwargs["onerror"](PermissionError("fixture traversal denied"))
    return iter(())

original_walk = module.os.walk
module.os.walk = walk_with_permission_error
try:
    module._list_editorial_files(
        project_root,
        module.list_docs_directories(project_root, policy),
        policy,
    )
except PermissionError:
    pass
else:
    failures.append("directory traversal error was swallowed")
finally:
    module.os.walk = original_walk

original_run = module.subprocess.run

def raise_git_start_error(*args, **kwargs):
    raise OSError("fixture git start failure")

module.subprocess.run = raise_git_start_error
try:
    module._run_git_paths(project_root, ["--cached"])
except (OSError, RuntimeError):
    pass
else:
    failures.append("Git startup error was swallowed")

module.subprocess.run = lambda *args, **kwargs: SimpleNamespace(
    returncode=7,
    stdout=b"",
    stderr=b"fatal: fixture Git I/O failure",
)
try:
    module._run_git_paths(project_root, ["--cached"])
except RuntimeError:
    pass
else:
    failures.append("Git command failure was swallowed")
finally:
    module.subprocess.run = original_run

with tempfile.TemporaryDirectory() as non_git_root:
    if module._run_git_paths(Path(non_git_root), ["--cached"]) != []:
        failures.append("non-Git root did not return an empty path list")

original_git_paths = module._run_git_paths
inventory_root = project_root / "inventory"

def case_variant_git_paths(root, arguments):
    argument_tuple = tuple(arguments)
    if argument_tuple == ("--cached",):
        return [r"Docs\Guide.md"]
    if root == project_root and "--ignored" in arguments:
        return ["DOCS/GUIDE.MD"]
    if root == project_root:
        return ["./docs/guide.md"]
    if "--ignored" in arguments:
        return ["docs/guide.md"]
    return ["docs/Guide.md"]

module._run_git_paths = case_variant_git_paths
try:
    merged_states = module.list_git_paths(project_root, inventory_root)
    if merged_states != {"Docs/Guide.md": "tracked"}:
        failures.append(f"case-insensitive Git priority merge failed: {merged_states!r}")
finally:
    module._run_git_paths = original_git_paths

front_matter_text = "---\ntitle: Front Matter\n---\n\n# Front Matter\n"
front_matter_issues = module.find_heading_issues(front_matter_text, "docs/frontmatter.md")
if front_matter_issues:
    failures.append(f"YAML front matter was parsed as headings: {front_matter_issues!r}")

valid_manifest_entry = {
    "path": "docs/a.md",
    "domain": "root_current",
    "review_status": "pending",
    "canonical_target": None,
    "replacement_for": [],
    "evidence_sources": [],
}

with tempfile.TemporaryDirectory() as manifest_root:
    manifest_root = Path(manifest_root)

    def expect_invalid_manifest(name, records):
        manifest_path = manifest_root / f"{name}.json"
        manifest_path.write_text(
            json.dumps({"schema_version": "1.0.0", "records": records}),
            encoding="utf-8",
        )
        try:
            module._load_review_statuses(manifest_path)
        except (TypeError, ValueError):
            return
        failures.append(f"invalid manifest was accepted: {name}")

    unknown_domain = dict(valid_manifest_entry, domain="unknown_domain")
    expect_invalid_manifest("unknown-domain", [unknown_domain])
    expect_invalid_manifest("review-status-type", [dict(valid_manifest_entry, review_status=None)])
    expect_invalid_manifest("canonical-target-type", [dict(valid_manifest_entry, canonical_target=7)])
    expect_invalid_manifest("replacement-list-type", [dict(valid_manifest_entry, replacement_for="docs/old.md")])
    expect_invalid_manifest("replacement-item-type", [dict(valid_manifest_entry, replacement_for=[7])])
    expect_invalid_manifest("evidence-list-type", [dict(valid_manifest_entry, evidence_sources="AGENTS.md")])
    expect_invalid_manifest("evidence-item-type", [dict(valid_manifest_entry, evidence_sources=[7])])
    missing_field = dict(valid_manifest_entry)
    del missing_field["evidence_sources"]
    expect_invalid_manifest("missing-field", [missing_field])
    duplicate_path = dict(valid_manifest_entry, path="DOCS/A.md")
    expect_invalid_manifest("duplicate-path", [valid_manifest_entry, duplicate_path])

if failures:
    raise AssertionError("; ".join(failures))
print("PASS: traversal and Git failures stay visible")
'@
    $failureProbePath = Join-Path $env:TEMP ("mt3-docs-audit-failure-probe-" + [guid]::NewGuid().ToString("N") + ".py")
    try {
        Write-Utf8Fixture -Path $failureProbePath -Text $failureProbe
        & python -X utf8 $failureProbePath $pythonScript $policyPath $projectRoot
        Assert-True ($LASTEXITCODE -eq 0) "Python failure semantics probe"
    } finally {
        if (Test-Path -LiteralPath $failureProbePath -PathType Leaf) {
            Remove-Item -LiteralPath $failureProbePath -Force
        }
    }
} catch {
    $failed = $true
    Write-Output "FAIL: traversal and Git failures stay visible: $($_.Exception.Message)"
}

if ($failed) {
    exit 1
}
exit 0

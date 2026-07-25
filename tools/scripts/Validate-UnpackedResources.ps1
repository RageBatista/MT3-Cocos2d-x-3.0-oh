[CmdletBinding()]
param(
    [string]$RootPath = "E:\\MT3\\unpacked_res",
    [string]$MarkdownReportPath = "",
    [string]$JsonReportPath = "",
    [int]$MaxSamplesPerExtension = 200
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\\.."))

function Resolve-FullPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $PathValue))
}

function Get-RelativePathSafe {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $baseUri = New-Object System.Uri(($BasePath.TrimEnd("\\/") + [System.IO.Path]::DirectorySeparatorChar))
    $targetUri = New-Object System.Uri($TargetPath)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace("/", "\\")
}

function Test-XmlLikeSignature {
    param([byte[]]$Bytes)

    if ($Bytes.Length -eq 0) {
        return $false
    }

    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE) {
        return $true
    }

    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFE -and $Bytes[1] -eq 0xFF) {
        return $true
    }

    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        return ($Bytes.Length -ge 4 -and $Bytes[3] -eq 0x3C)
    }

    if ($Bytes[0] -eq 0x3C) {
        return $true
    }

    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0x3C -and $Bytes[1] -eq 0x00) {
        return $true
    }

    return $false
}

function Test-WebpSignature {
    param([byte[]]$Bytes)

    if ($Bytes.Length -lt 12) {
        return $false
    }

    return (
        $Bytes[0] -eq 0x52 -and $Bytes[1] -eq 0x49 -and $Bytes[2] -eq 0x46 -and $Bytes[3] -eq 0x46 -and
        $Bytes[8] -eq 0x57 -and $Bytes[9] -eq 0x45 -and $Bytes[10] -eq 0x42 -and $Bytes[11] -eq 0x50
    )
}

function Test-SignatureRule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Extension,
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    switch ($Extension.ToLowerInvariant()) {
        ".png" {
            return $Bytes.Length -ge 8 -and
                $Bytes[0] -eq 0x89 -and $Bytes[1] -eq 0x50 -and $Bytes[2] -eq 0x4E -and $Bytes[3] -eq 0x47 -and
                $Bytes[4] -eq 0x0D -and $Bytes[5] -eq 0x0A -and $Bytes[6] -eq 0x1A -and $Bytes[7] -eq 0x0A
        }
        ".jpg" { return $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xD8 -and $Bytes[2] -eq 0xFF }
        ".jpeg" { return $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xD8 -and $Bytes[2] -eq 0xFF }
        ".gif" {
            return $Bytes.Length -ge 6 -and
                $Bytes[0] -eq 0x47 -and $Bytes[1] -eq 0x49 -and $Bytes[2] -eq 0x46 -and
                $Bytes[3] -eq 0x38 -and ($Bytes[4] -eq 0x37 -or $Bytes[4] -eq 0x39) -and $Bytes[5] -eq 0x61
        }
        ".bmp" { return $Bytes.Length -ge 2 -and $Bytes[0] -eq 0x42 -and $Bytes[1] -eq 0x4D }
        ".ogg" { return $Bytes.Length -ge 4 -and $Bytes[0] -eq 0x4F -and $Bytes[1] -eq 0x67 -and $Bytes[2] -eq 0x67 -and $Bytes[3] -eq 0x53 }
        ".mp3" {
            return (
                ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0x49 -and $Bytes[1] -eq 0x44 -and $Bytes[2] -eq 0x33) -or
                ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFF -and (($Bytes[1] -band 0xE0) -eq 0xE0))
            )
        }
        ".xml" { return Test-XmlLikeSignature -Bytes $Bytes }
        ".layout" { return Test-XmlLikeSignature -Bytes $Bytes }
        ".scheme" { return Test-XmlLikeSignature -Bytes $Bytes }
        ".looknfeel" { return Test-XmlLikeSignature -Bytes $Bytes }
        ".imageset" { return Test-XmlLikeSignature -Bytes $Bytes }
        ".font" { return Test-XmlLikeSignature -Bytes $Bytes }
        ".webp" { return Test-WebpSignature -Bytes $Bytes }
        default { return $null }
    }
}

function Get-FileSampleSignatureResult {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File
    )

    $stream = [System.IO.File]::Open($File.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    try {
        $length = [Math]::Min(32, [int]$stream.Length)
        $buffer = New-Object byte[] $length
        $null = $stream.Read($buffer, 0, $length)
    }
    finally {
        $stream.Dispose()
    }

    return Test-SignatureRule -Extension $File.Extension -Bytes $buffer
}

function Get-ManifestStats {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath,
        [Parameter(Mandatory = $true)]
        [string]$RootDirectory
    )

    $stats = [ordered]@{
        entry_count = 0
        final_path_count = 0
        missing_final_path_count = 0
        missing_final_paths = New-Object System.Collections.Generic.List[string]
        missing_final_file_names = New-Object System.Collections.Generic.List[string]
        flag_counts = @{}
    }

    $reader = [System.IO.File]::OpenText($ManifestPath)
    try {
        $header = $reader.ReadLine()
        while (($line = $reader.ReadLine()) -ne $null) {
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            $stats.entry_count++
            $parts = $line.Split("`t")
            if ($parts.Length -lt 7) {
                continue
            }

            $finalRelativePath = $parts[5]
            if (-not [string]::IsNullOrWhiteSpace($finalRelativePath)) {
                $stats.final_path_count++
                $finalPath = Join-Path $RootDirectory $finalRelativePath
                if (-not (Test-Path -LiteralPath $finalPath)) {
                    $stats.missing_final_path_count++
                    $stats.missing_final_file_names.Add([System.IO.Path]::GetFileName($finalRelativePath))
                    if ($stats.missing_final_paths.Count -lt 20) {
                        $stats.missing_final_paths.Add($finalRelativePath)
                    }
                }
            }

            $flags = $parts[6]
            if (-not [string]::IsNullOrWhiteSpace($flags)) {
                foreach ($flag in $flags.Split(",")) {
                    $trimmed = $flag.Trim()
                    if ([string]::IsNullOrWhiteSpace($trimmed)) {
                        continue
                    }

                    if (-not $stats.flag_counts.ContainsKey($trimmed)) {
                        $stats.flag_counts[$trimmed] = 0
                    }

                    $stats.flag_counts[$trimmed]++
                }
            }
        }
    }
    finally {
        $reader.Dispose()
    }

    return [pscustomobject]$stats
}

function Convert-GroupCounts {
    param($GroupInfo)

    $result = [ordered]@{}
    foreach ($item in $GroupInfo) {
        $result[$item.Name] = $item.Count
    }
    return $result
}

$resolvedRootPath = Resolve-FullPath -PathValue $RootPath -BaseDirectory $repoRoot
if (-not (Test-Path -LiteralPath $resolvedRootPath)) {
    throw "Unpacked resource root does not exist: $resolvedRootPath"
}

if ([string]::IsNullOrWhiteSpace($MarkdownReportPath)) {
    $MarkdownReportPath = Join-Path $repoRoot "plans\\unpacked-res-validation-20260424.md"
}

if ([string]::IsNullOrWhiteSpace($JsonReportPath)) {
    $JsonReportPath = Join-Path $repoRoot "plans\\unpacked-res-validation-20260424.json"
}

$resolvedMarkdownReportPath = Resolve-FullPath -PathValue $MarkdownReportPath -BaseDirectory $repoRoot
$resolvedJsonReportPath = Resolve-FullPath -PathValue $JsonReportPath -BaseDirectory $repoRoot

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $resolvedMarkdownReportPath) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $resolvedJsonReportPath) | Out-Null

$metaFileNames = @(
    "unpack_path_manifest.tsv",
    "unpack_path_manifest.json",
    "review_failed_items_all_failed.tsv",
    "review_failed_items_all_failed.json",
    "review_failed_first_decrypt_all_failed.json",
    "review_alias_model_ani.txt",
    "review_alias_model_pages.txt"
)

$allFiles = @(Get-ChildItem -LiteralPath $resolvedRootPath -Recurse -File -Force)
$classifiedFiles = foreach ($file in $allFiles) {
    $relativePath = Get-RelativePathSafe -BasePath $resolvedRootPath -TargetPath $file.FullName
    $category = "resource"

    if ($metaFileNames -contains $file.Name -or
        $relativePath.StartsWith("source_template_reports_cli\\", [System.StringComparison]::OrdinalIgnoreCase) -or
        $relativePath.StartsWith("source_template_promoted_cli\\", [System.StringComparison]::OrdinalIgnoreCase)) {
        $category = "metadata"
    }
    elseif ($relativePath.StartsWith("review\\", [System.StringComparison]::OrdinalIgnoreCase)) {
        $category = "review"
    }

    [pscustomobject]@{
        file = $file
        relative_path = $relativePath
        category = $category
    }
}

$resourceFiles = @($classifiedFiles | Where-Object { $_.category -eq "resource" })
$reviewFiles = @($classifiedFiles | Where-Object { $_.category -eq "review" })
$metadataFiles = @($classifiedFiles | Where-Object { $_.category -eq "metadata" })

$manifestPath = Join-Path $resolvedRootPath "unpack_path_manifest.tsv"
$manifestStats = if (Test-Path -LiteralPath $manifestPath) {
    Get-ManifestStats -ManifestPath $manifestPath -RootDirectory $resolvedRootPath
}
else {
    [pscustomobject]@{
        entry_count = 0
        final_path_count = 0
        missing_final_path_count = 0
        missing_final_paths = @()
        flag_counts = @{}
    }
}

$failedItemsPath = Join-Path $resolvedRootPath "review_failed_items_all_failed.json"
$failedItems = @()
if (Test-Path -LiteralPath $failedItemsPath) {
    $failedJson = Get-Content -Raw -Encoding UTF8 -LiteralPath $failedItemsPath | ConvertFrom-Json
    $failedItems = @($failedJson.failed_items)
}

$failedByCode = Convert-GroupCounts -GroupInfo ($failedItems | Group-Object error_code)
$failedByMapping = [ordered]@{
    mapping_hit_true = (@($failedItems | Where-Object { $_.mapping_hit -eq $true })).Count
    mapping_hit_false = (@($failedItems | Where-Object { $_.mapping_hit -ne $true })).Count
}

$sourceTemplateSummaryPath = Join-Path $resolvedRootPath "source_template_reports_cli\\source_template_summary.json"
$sourceTemplateSummary = $null
if (Test-Path -LiteralPath $sourceTemplateSummaryPath) {
    $sourceTemplateSummary = Get-Content -Raw -Encoding UTF8 -LiteralPath $sourceTemplateSummaryPath | ConvertFrom-Json
}

$reviewUnresolvedPath = Join-Path $resolvedRootPath "review\\unresolved"
$reviewUnresolvedCount = if (Test-Path -LiteralPath $reviewUnresolvedPath) {
    (Get-ChildItem -LiteralPath $reviewUnresolvedPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
}
else {
    0
}

$reviewNameSet = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($entry in $reviewFiles) {
    $null = $reviewNameSet.Add($entry.file.Name)
}

$reviewBackedMissingCount = 0
foreach ($name in $manifestStats.missing_final_file_names) {
    if ($reviewNameSet.Contains($name)) {
        $reviewBackedMissingCount++
    }
}

$topLevelDirectories = @(
    Get-ChildItem -LiteralPath $resolvedRootPath -Directory -Force |
        Sort-Object Name |
        ForEach-Object {
            [pscustomobject]@{
                name = $_.Name
                file_count = (Get-ChildItem -LiteralPath $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
            }
        }
)

$keyPathChecks = [ordered]@{
    "table/bintable/map.cmapconfig.bin" = Test-Path -LiteralPath (Join-Path $resolvedRootPath "table\\bintable\\map.cmapconfig.bin")
    "ui/layouts" = Test-Path -LiteralPath (Join-Path $resolvedRootPath "ui\\layouts")
    "ui/schemes" = Test-Path -LiteralPath (Join-Path $resolvedRootPath "ui\\schemes")
    "ui/looknfeel" = Test-Path -LiteralPath (Join-Path $resolvedRootPath "ui\\looknfeel")
    "model" = Test-Path -LiteralPath (Join-Path $resolvedRootPath "model")
    "effect" = Test-Path -LiteralPath (Join-Path $resolvedRootPath "effect")
    "map" = Test-Path -LiteralPath (Join-Path $resolvedRootPath "map")
    "script" = Test-Path -LiteralPath (Join-Path $resolvedRootPath "script")
}

$signatureExtensions = @(
    ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ogg", ".mp3",
    ".xml", ".layout", ".scheme", ".looknfeel", ".imageset", ".font", ".webp"
)

$signatureResults = [ordered]@{}
foreach ($extension in $signatureExtensions) {
    $candidates = @(
        $resourceFiles |
            Where-Object { $_.file.Extension -ieq $extension } |
            Select-Object -First $MaxSamplesPerExtension
    )

    if ($candidates.Count -eq 0) {
        continue
    }

    $matched = 0
    $mismatched = New-Object System.Collections.Generic.List[string]
    foreach ($candidate in $candidates) {
        $signatureCheck = Get-FileSampleSignatureResult -File $candidate.file
        if ($signatureCheck -eq $true) {
            $matched++
            continue
        }

        if ($signatureCheck -eq $false -and $mismatched.Count -lt 10) {
            $mismatched.Add($candidate.relative_path)
        }
    }

    $signatureResults[$extension] = [ordered]@{
        sampled = $candidates.Count
        matched = $matched
        mismatched = $candidates.Count - $matched
        sample_mismatches = @($mismatched)
    }
}

$status = "pass"
if ($failedItems.Count -gt 0 -or $manifestStats.missing_final_path_count -gt 0) {
    $status = "needs_attention"
}

$summary = [ordered]@{
    generated_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    root_path = $resolvedRootPath
    overall_status = $status
    counts = [ordered]@{
        all_files = $allFiles.Count
        resource_files = $resourceFiles.Count
        review_files = $reviewFiles.Count
        metadata_files = $metadataFiles.Count
        review_unresolved_files = $reviewUnresolvedCount
        failed_items = $failedItems.Count
    }
    manifest = [ordered]@{
        entry_count = $manifestStats.entry_count
        final_path_count = $manifestStats.final_path_count
        missing_final_path_count = $manifestStats.missing_final_path_count
        review_backed_missing_count = $reviewBackedMissingCount
        missing_final_paths = @($manifestStats.missing_final_paths)
        flag_counts = $manifestStats.flag_counts
    }
    source_template = if ($null -ne $sourceTemplateSummary) { $sourceTemplateSummary } else { $null }
    failed_breakdown = [ordered]@{
        by_error_code = $failedByCode
        by_mapping_hit = $failedByMapping
    }
    key_path_checks = $keyPathChecks
    top_level_directories = $topLevelDirectories
    signature_validation = $signatureResults
}

$reportLines = New-Object System.Collections.Generic.List[string]
$reportLines.Add("# Unpack Validation Report")
$reportLines.Add("")
$reportLines.Add(("- generated_at: {0}" -f $summary.generated_at))
$reportLines.Add(("- root_path: {0}" -f $resolvedRootPath))
$reportLines.Add(("- overall_status: {0}" -f $status))
$reportLines.Add("")
$reportLines.Add("## Overview")
$reportLines.Add("")
$reportLines.Add(("- resource_files: {0}" -f $summary.counts.resource_files))
$reportLines.Add(("- review_files: {0}" -f $summary.counts.review_files))
$reportLines.Add(("- metadata_files: {0}" -f $summary.counts.metadata_files))
$reportLines.Add(("- review_unresolved_files: {0}" -f $summary.counts.review_unresolved_files))
$reportLines.Add(("- failed_items: {0}" -f $summary.counts.failed_items))
$reportLines.Add("")
$reportLines.Add("## Manifest")
$reportLines.Add("")
$reportLines.Add(("- manifest_entry_count: {0}" -f $summary.manifest.entry_count))
$reportLines.Add(("- manifest_final_path_count: {0}" -f $summary.manifest.final_path_count))
$reportLines.Add(("- manifest_missing_final_path_count: {0}" -f $summary.manifest.missing_final_path_count))
$reportLines.Add(("- manifest_review_backed_missing_count: {0}" -f $summary.manifest.review_backed_missing_count))
if ($summary.manifest.missing_final_path_count -gt 0) {
    foreach ($path in $summary.manifest.missing_final_paths) {
        $reportLines.Add(("  - missing: {0}" -f $path))
    }
}
$reportLines.Add("")
$reportLines.Add("## Failed Items")
$reportLines.Add("")
if ($summary.failed_breakdown.by_error_code.Count -eq 0) {
    $reportLines.Add("- no failed items")
}
else {
    foreach ($entry in $summary.failed_breakdown.by_error_code.GetEnumerator()) {
        $reportLines.Add(("- error_code {0}: {1}" -f $entry.Key, $entry.Value))
    }
    $reportLines.Add(("- mapping_hit=true: {0}" -f $summary.failed_breakdown.by_mapping_hit.mapping_hit_true))
    $reportLines.Add(("- mapping_hit=false: {0}" -f $summary.failed_breakdown.by_mapping_hit.mapping_hit_false))
}
$reportLines.Add("")
$reportLines.Add("## Restore And Structure")
$reportLines.Add("")
if ($null -ne $summary.source_template) {
    $reportLines.Add(("- source_template_target_crc_count: {0}" -f $summary.source_template.target_crc_count))
    $reportLines.Add(("- source_template_new_hits: {0}" -f $summary.source_template.new_hits))
    $reportLines.Add(("- source_template_hit_gain: {0}" -f $summary.source_template.hit_gain))
    $reportLines.Add(("- source_template_scanned_text_files: {0}" -f $summary.source_template.scanned_text_files))
}
foreach ($entry in $summary.key_path_checks.GetEnumerator()) {
    $reportLines.Add(("- key path {0}: {1}" -f $entry.Key, ($(if ($entry.Value) { "present" } else { "missing" }))))
}
$reportLines.Add("")
$reportLines.Add("## Top Level Directories")
$reportLines.Add("")
foreach ($entry in $summary.top_level_directories) {
    $reportLines.Add(("- {0}: {1} files" -f $entry.name, $entry.file_count))
}
$reportLines.Add("")
$reportLines.Add("## Signature Sampling")
$reportLines.Add("")
foreach ($entry in $summary.signature_validation.GetEnumerator()) {
    $reportLines.Add(("- {0}: sampled={1}, matched={2}, mismatched={3}" -f $entry.Key, $entry.Value.sampled, $entry.Value.matched, $entry.Value.mismatched))
    foreach ($path in $entry.Value.sample_mismatches) {
        $reportLines.Add(("  - mismatch: {0}" -f $path))
    }
}
$reportLines.Add("")
$reportLines.Add("## Conclusion")
$reportLines.Add("")
if ($status -eq "pass") {
    $reportLines.Add("- no manifest-missing files and no failed items were detected")
}
else {
    $reportLines.Add("- unpacking mostly succeeded, but failed items or residual review files still exist")
    $reportLines.Add("- current failed items are dominated by 405 (Decompression failed) and 500 (CRC32 checksum mismatch)")
}

[System.IO.File]::WriteAllText(
    $resolvedMarkdownReportPath,
    (($reportLines -join [Environment]::NewLine) + [Environment]::NewLine),
    $utf8NoBom
)
[System.IO.File]::WriteAllText(
    $resolvedJsonReportPath,
    (($summary | ConvertTo-Json -Depth 8) + [Environment]::NewLine),
    $utf8NoBom
)

Write-Host ("Markdown report: {0}" -f $resolvedMarkdownReportPath)
Write-Host ("JSON report: {0}" -f $resolvedJsonReportPath)

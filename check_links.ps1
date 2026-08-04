$docsDir = 'e:\MT3\docs'
$rootDir = 'e:\MT3'
$results = @()
$mdFiles = Get-ChildItem -Path $docsDir -Recurse -Filter '*.md' | ForEach-Object { $_.FullName }
$mdFiles += 'e:\MT3\README.md'
$mdFiles += 'e:\MT3\AGENTS.md'
$linkPattern = '\[([^\]]+)\]\(([^)]+)\)'

# Patterns that are clearly not document links
$skipProtocol = '^[a-zA-Z]+://'       # file://, http://, https://, etc.
$skipAnchor = '^#'                    # #section anchors
$skipAnchorMiddle = '#'               # file.md#section  (has anchor in middle)
$skipLineRef = '\.(cpp|h|java|ps1|bat|sh|toml|json|txt|xml|py|lua):\d+'  # file.cpp:123
$skipCodeRef = '\.(cpp|h|java|ps1|bat|sh|toml|json|txt|xml|py|lua)$'     # file.cpp (code file ref)
$skipInlineCode = '^\*|^\`|^\{'      # inline code or special chars starting

foreach ($f in $mdFiles) {
    # Read with explicit UTF8 encoding to preserve Chinese characters
    $content = Get-Content -Path $f -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $relativePath = $f.Substring($rootDir.Length).TrimStart('\')
    $mmatches = [regex]::Matches($content, $linkPattern)
    foreach ($mm in $mmatches) {
        $linkTarget = $mm.Groups[2].Value.Trim()
        
        # Skip clearly non-document links
        if ($linkTarget -match $skipProtocol) { continue }
        if ($linkTarget -match $skipAnchor) { continue }
        if ($linkTarget -match $skipAnchorMiddle) { continue }
        if ($linkTarget -match $skipLineRef) { continue }
        if ($linkTarget -match $skipCodeRef) { continue }
        if ($linkTarget -match $skipInlineCode) { continue }
        
        # Skip links that are just type names, keywords, or likely code references
        if ($linkTarget -match '^\s*$') { continue }
        # Must have a file extension to be a document link
        if ($linkTarget -notmatch '\.(md|txt|json|csv|xml|html|htm|pdf|png|jpg|jpeg|gif|svg|ico|zip|7z|gz|tar)$') { continue }
        
        $fileDir = Split-Path $f -Parent
        $cleanTarget = $linkTarget -replace '%20', ' '
        
        try {
            if ([System.IO.Path]::IsPathRooted($cleanTarget)) {
                $resolvedPath = $cleanTarget
            } else {
                $resolvedPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($fileDir, $cleanTarget))
            }
            $exists = Test-Path -Path $resolvedPath -PathType Leaf
            if (-not $exists) {
                $results += "$($relativePath)|$($linkTarget)"
            }
        } catch {
            # Skip paths that can't be resolved (likely inline code or special patterns)
        }
    }
}
$results | Out-File -FilePath 'e:\MT3\broken_links.txt' -Encoding UTF8
Write-Host "Found $($results.Count) broken links"
$dirs = @(".claude", ".trae", ".github", ".agents", "docs", "common", "engine", "gbeans", "dependencies", "tools", "client", "cocos2d-x-2.2.6", "server", "scheme_doc")
$restored = 0; $notFound = 0; $total = 0
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) { continue }
    $files = Get-ChildItem $dir -Recurse -File -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $total++
        try {
            $fs = [System.IO.File]::OpenRead($f.FullName)
            $buf = New-Object byte[] 300
            $n = $fs.Read($buf, 0, 300)
            $fs.Close()
            $text = [System.Text.Encoding]::ASCII.GetString($buf, 0, $n)
            if ($text -match "oid sha256:([a-f0-9]+)") {
                $oid = $matches[1]
                $lfsPath = ".git/lfs/objects/$($oid.Substring(0,2))/$($oid.Substring(2,2))/$oid"
                if (Test-Path $lfsPath) { Copy-Item $lfsPath $f.FullName -Force; $restored++ }
                else { $notFound++ }
            }
        } catch {}
    }
}
"Total scanned: $total"
"Restored: $restored"
"Not found in cache: $notFound"

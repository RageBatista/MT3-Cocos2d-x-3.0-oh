param(
    [string[]]$ScanRoots = @(
        'client\resource\bin\Release',
        'client\resource\bin\Debug',
        'client\resource\tools',
        'tools'
    ),
    [string[]]$ExecutableNames = @(),
    [string]$ReportPath = '',
    [switch]$FailOnIssues
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $PathValue))
}

function Get-DumpbinPath {
    $candidates = @()

    if ($env:VS120COMNTOOLS) {
        $candidates += (Join-Path $env:VS120COMNTOOLS '..\..\VC\bin\dumpbin.exe')
    }

    $candidates += 'D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\dumpbin.exe'
    $candidates += 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\dumpbin.exe'

    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) {
            return [System.IO.Path]::GetFullPath($c)
        }
    }

    throw 'dumpbin.exe not found (VS2013 required).'
}

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    $getFileHash = Get-Command Get-FileHash -ErrorAction SilentlyContinue
    if ($getFileHash) {
        return (Get-FileHash -Path $Path -Algorithm SHA256).Hash
    }

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        return ([System.BitConverter]::ToString($sha256.ComputeHash($stream)) -replace '-', '').ToUpperInvariant()
    }
    finally {
        $stream.Dispose()
        $sha256.Dispose()
    }
}

function Is-ReleaseLikePath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $p = $Path.ToLowerInvariant()
    return (
        ($p -match '\\client\\resource\\tools($|\\)') -or
        ($p -match '\\bin\\release($|\\)') -or
        ($p -match '\\release\\.win32($|\\)') -or
        ($p -match '\\dist\\mvp($|\\)')
    )
}

function Is-DebugLikePath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $p = $Path.ToLowerInvariant()
    return (
        ($p -match '\\bin\\debug($|\\)') -or
        ($p -match '\\debug\\.win32($|\\)') -or
        $p.EndsWith('_d.exe')
    )
}

function Get-DirectDependents {
    param(
        [Parameter(Mandatory = $true)][string]$DumpbinPath,
        [Parameter(Mandatory = $true)][string]$BinaryPath
    )

    $out = & $DumpbinPath /dependents $BinaryPath 2>$null | Out-String
    $deps = New-Object System.Collections.Generic.List[string]

    foreach ($line in ($out -split "`r?`n")) {
        if ($line -match '^\s+[A-Za-z0-9_.-]+$') {
            $name = $line.Trim()
            if ($name -ne 'Summary') {
                $deps.Add($name)
            }
        }
    }

    return $deps
}

function Is-SystemOrApiSetDll {
    param(
        [Parameter(Mandatory = $true)][string]$DllName,
        [Parameter(Mandatory = $true)][string[]]$SystemDlls
    )

    $n = $DllName.ToUpperInvariant()
    if ($SystemDlls -contains $n) {
        return $true
    }
    if ($n.StartsWith('API-MS-WIN-')) {
        return $true
    }
    if ($n.StartsWith('EXT-MS-WIN-')) {
        return $true
    }
    return $false
}

function Get-ExeDependencyMissing {
    param(
        [Parameter(Mandatory = $true)][string]$DumpbinPath,
        [Parameter(Mandatory = $true)][string]$ExePath,
        [Parameter(Mandatory = $true)][string[]]$SystemDlls
    )

    $baseDir = Split-Path $ExePath -Parent
    $queue = New-Object System.Collections.Generic.Queue[string]
    $seen = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
    $missing = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

    $queue.Enqueue($ExePath)

    while ($queue.Count -gt 0) {
        $cur = $queue.Dequeue()
        $key = [System.IO.Path]::GetFileName($cur)

        if ($seen.Contains($key)) {
            continue
        }
        $seen.Add($key) | Out-Null

        foreach ($dep in (Get-DirectDependents -DumpbinPath $DumpbinPath -BinaryPath $cur)) {
            if (Is-SystemOrApiSetDll -DllName $dep -SystemDlls $SystemDlls) {
                continue
            }

            $local = Join-Path $baseDir $dep
            if (Test-Path $local) {
                $queue.Enqueue($local)
            }
            else {
                $missing.Add($dep) | Out-Null
            }
        }
    }

    return @($missing | Sort-Object)
}

function Get-DriftSeverity {
    param([Parameter(Mandatory = $true)][object[]]$Records)

    $allHashes = @($Records | Select-Object -ExpandProperty Hash -Unique)
    if ($allHashes.Count -le 1) {
        return 'None'
    }

    $releaseHashes = @(
        $Records |
            Where-Object { Is-ReleaseLikePath -Path $_.Directory } |
            Select-Object -ExpandProperty Hash -Unique
    )

    if ($releaseHashes.Count -gt 1) {
        return 'High'
    }

    return 'Info'
}

function Is-KnownControlledCrossFamilyDrift {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$DllName,
        [Parameter(Mandatory = $true)][object[]]$Records
    )

    $allowedDlls = @(
        'CEGUIBase.dll',
        'CEGUIExpatParser.dll',
        'CEGUIFalagardWRBase.dll',
        'CEGUIOpenGLRenderer.dll',
        'CEGUISILLYImageCodec.dll'
    )

    if ($allowedDlls -notcontains $DllName) {
        return $false
    }

    $releaseRecords = @($Records | Where-Object { Is-ReleaseLikePath -Path $_.Directory })
    if ($releaseRecords.Count -eq 0) {
        return $false
    }

    $families = @(
        [PSCustomObject]@{
            Name = 'CELayoutEditor.Current'
            Dirs = @(
                (Join-Path $RepoRoot 'client\resource\tools'),
                (Join-Path $RepoRoot 'tools\CELayoutEditor\bin\release'),
                (Join-Path $RepoRoot 'tools\CELayoutEditor\vc++12\Release.win32')
            )
        },
        [PSCustomObject]@{
            Name = 'CELayoutEditor.Legacy'
            Dirs = @(
                (Join-Path $RepoRoot 'tools\CELayoutEditor-0.7.1\bin\release'),
                (Join-Path $RepoRoot 'tools\CELayoutEditor-0.7.1\vc++12\Release.win32')
            )
        },
        [PSCustomObject]@{
            Name = 'CEImageset'
            Dirs = @(
                (Join-Path $RepoRoot 'tools\CEImagesetEditor-0.7.1\bin\release'),
                (Join-Path $RepoRoot 'client\resource\tools\CEGUIImagesetEditer'),
                (Join-Path $RepoRoot 'tools\TexturePacker_CEGUI\bin\release')
            )
        },
        [PSCustomObject]@{
            Name = 'CEGUI-0.7.9-r5'
            Dirs = @(
                (Join-Path $RepoRoot 'tools\CEGUI-0.7.9-r5\bin')
            )
        }
    )

    $familyByDir = @{}
    foreach ($family in $families) {
        foreach ($dir in $family.Dirs) {
            $familyByDir[[System.IO.Path]::GetFullPath($dir).ToLowerInvariant()] = $family.Name
        }
    }

    $recordsByFamily = @{}
    foreach ($record in $releaseRecords) {
        $dir = [System.IO.Path]::GetFullPath($record.Directory).ToLowerInvariant()
        $familyName = $null
        if ($familyByDir.ContainsKey($dir)) {
            $familyName = $familyByDir[$dir]
        }
        elseif ($dir -match '\\tools\\celayouteditor-bulid\\dist\\celayouteditor-portable-release-win32-[^\\]+$') {
            $familyName = 'CELayoutEditor.PortableDist'
        }
        else {
            return $false
        }

        if (-not $recordsByFamily.ContainsKey($familyName)) {
            $recordsByFamily[$familyName] = New-Object System.Collections.Generic.List[object]
        }
        $recordsByFamily[$familyName].Add($record) | Out-Null
    }

    if ($recordsByFamily.Count -lt 2) {
        return $false
    }

    $familyHashes = New-Object System.Collections.Generic.List[string]
    foreach ($familyName in $recordsByFamily.Keys) {
        $hashes = @($recordsByFamily[$familyName] | Select-Object -ExpandProperty Hash -Unique)
        if ($hashes.Count -gt 1) {
            return $false
        }
        if ($hashes.Count -eq 1) {
            $familyHashes.Add($hashes[0]) | Out-Null
        }
    }

    return (@($familyHashes | Sort-Object -Unique).Count -gt 1)
}

function New-ToolFamilyCheck {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string[]]$Directories,
        [Parameter(Mandatory = $true)][string[]]$DllNames
    )

    return [PSCustomObject]@{
        Name = $Name
        Directories = $Directories
        DllNames = $DllNames
    }
}

function Invoke-FamilyConsistencyChecks {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $checks = @(
        (New-ToolFamilyCheck -Name 'CELayoutEditor.SharedRuntime' -Directories @(
            (Join-Path $RepoRoot 'client\resource\tools'),
            (Join-Path $RepoRoot 'tools\CELayoutEditor\bin\release')
        ) -DllNames @(
            'CEGUIBase.dll','CEGUIExpatParser.dll','CEGUIFalagardWRBase.dll','CEGUIOpenGLRenderer.dll',
            'CEGUISILLYImageCodec.dll','SILLY.dll','libcocos2d.dll','glew32.dll','iconv.dll','libxml2.dll',
            'pthreadVCE2.dll','zlib1.dll','msvcp120.dll','msvcr120.dll'
        )),
        (New-ToolFamilyCheck -Name 'CEImageset.SharedRuntime' -Directories @(
            (Join-Path $RepoRoot 'client\resource\tools\CEGUIImagesetEditer'),
            (Join-Path $RepoRoot 'tools\CEImagesetEditor-0.7.1\bin\release'),
            (Join-Path $RepoRoot 'tools\TexturePacker_CEGUI\bin\release')
        ) -DllNames @(
            'CEGUIBase.dll','CEGUIExpatParser.dll','CEGUIFalagardWRBase.dll','CEGUIOpenGLRenderer.dll',
            'CEGUISILLYImageCodec.dll','CEGUITGAImageCodec.dll','SILLY.dll'
        ))
    )

    $results = New-Object System.Collections.Generic.List[object]
    foreach ($check in $checks) {
        foreach ($dll in $check.DllNames) {
            $existing = @()
            foreach ($dir in $check.Directories) {
                $p = Join-Path $dir $dll
                if (Test-Path $p) {
                    $existing += [PSCustomObject]@{
                        Path = $p
                        Hash = Get-Sha256 -Path $p
                        Length = (Get-Item $p).Length
                    }
                }
            }

            if ($existing.Count -lt 2) {
                continue
            }

            $hashes = @($existing | Select-Object -ExpandProperty Hash -Unique)
            if ($hashes.Count -gt 1) {
                $results.Add([PSCustomObject]@{
                    Check = $check.Name
                    Dll = $dll
                    Severity = 'High'
                    Detail = ($existing | ForEach-Object { "[{0}] {1} {2}" -f $_.Length, $_.Hash.Substring(0, 12), $_.Path }) -join "`n"
                }) | Out-Null
            }
        }
    }

    $layoutCanonicalDir = Join-Path $RepoRoot 'client\resource\tools'
    $imagesetReleaseDir = Join-Path $RepoRoot 'tools\CEImagesetEditor-0.7.1\bin\release'
    $abiSplitDlls = @(
        'CEGUIBase.dll',
        'CEGUIExpatParser.dll',
        'CEGUIFalagardWRBase.dll',
        'CEGUIOpenGLRenderer.dll',
        'CEGUISILLYImageCodec.dll'
    )

    foreach ($dll in $abiSplitDlls) {
        $layoutDll = Join-Path $layoutCanonicalDir $dll
        $imagesetDll = Join-Path $imagesetReleaseDir $dll
        if (-not (Test-Path $layoutDll) -or -not (Test-Path $imagesetDll)) {
            continue
        }

        $layoutHash = Get-Sha256 -Path $layoutDll
        $imagesetHash = Get-Sha256 -Path $imagesetDll

        if ($layoutHash -eq $imagesetHash) {
            $results.Add([PSCustomObject]@{
                Check = 'CEImageset.ABIIsolation'
                Dll = $dll
                Severity = 'High'
                Detail = "Imageset release hash unexpectedly matches Layout shared hash: $layoutHash"
            }) | Out-Null
        }
    }

    return $results
}

$repoRoot = Get-RepoRoot
$dumpbinPath = Get-DumpbinPath

$resolvedRoots = @(
    $ScanRoots |
        ForEach-Object { Resolve-RepoPath -RepoRoot $repoRoot -PathValue $_ } |
        Where-Object { Test-Path $_ }
)

$allExes = New-Object System.Collections.Generic.List[string]
foreach ($root in $resolvedRoots) {
    Get-ChildItem -Path $root -Recurse -File -Filter *.exe -ErrorAction SilentlyContinue |
        ForEach-Object {
            if ($ExecutableNames.Count -eq 0 -or $ExecutableNames -contains $_.Name) {
                $allExes.Add($_.FullName) | Out-Null
            }
        }
}

$runtimeDirs = @($allExes | ForEach-Object { Split-Path $_ -Parent } | Sort-Object -Unique)

$dllRecords = New-Object System.Collections.Generic.List[object]
foreach ($dir in $runtimeDirs) {
    Get-ChildItem -Path $dir -File -Filter *.dll -ErrorAction SilentlyContinue |
        ForEach-Object {
            $dllRecords.Add([PSCustomObject]@{
                Name = $_.Name
                Directory = $dir
                Path = $_.FullName
                Length = $_.Length
                Hash = Get-Sha256 -Path $_.FullName
            }) | Out-Null
        }
}

$driftRows = New-Object System.Collections.Generic.List[object]
foreach ($g in ($dllRecords | Group-Object Name)) {
    $hashes = @($g.Group | Select-Object -ExpandProperty Hash -Unique)
    if ($hashes.Count -le 1) {
        continue
    }

    $severity = Get-DriftSeverity -Records $g.Group
    if ($severity -eq 'High' -and (Is-KnownControlledCrossFamilyDrift -RepoRoot $repoRoot -DllName $g.Name -Records $g.Group)) {
        $severity = 'Controlled'
    }
    $driftRows.Add([PSCustomObject]@{
        Dll = $g.Name
        Severity = $severity
        DistinctHashCount = $hashes.Count
        Locations = ($g.Group | Select-Object -ExpandProperty Directory -Unique).Count
        Detail = ($g.Group | Sort-Object Directory | ForEach-Object { "[{0}] {1} {2}" -f $_.Length, $_.Hash.Substring(0, 12), $_.Directory }) -join "`n"
    }) | Out-Null
}

$systemDlls = @(
    'KERNEL32.DLL','USER32.DLL','GDI32.DLL','ADVAPI32.DLL','SHELL32.DLL','COMDLG32.DLL','COMCTL32.DLL',
    'RPCRT4.DLL','WINMM.DLL','WINSPOOL.DRV','OPENGL32.DLL','GLU32.DLL','OLE32.DLL','OLEAUT32.DLL',
    'WS2_32.DLL','IMM32.DLL','VERSION.DLL','WININET.DLL','CRYPT32.DLL','SETUPAPI.DLL','UXTHEME.DLL',
    'MSIMG32.DLL','WSOCK32.DLL','MSVCRT.DLL','MSVCP_WIN.DLL','NTDLL.DLL','SHLWAPI.DLL','WS2HELP.DLL',
    'IPHLPAPI.DLL','DBGHELP.DLL','COMBASE.DLL','SECHOST.DLL','BCRYPTPRIMITIVES.DLL','KERNELBASE.DLL',
    'DWRITE.DLL','DWMAPI.DLL','WINHTTP.DLL','OLEACC.DLL','CLBCATQ.DLL','ODBC32.DLL','URLMON.DLL',
    'WLDAP32.DLL',
    # DX9/Win32 framework DLLs that are expected from system runtime or managed runtime.
    'D3D9.DLL','D3DX9_43.DLL','DSOUND.DLL','DINPUT8.DLL','GDIPLUS.DLL','MSCOREE.DLL','OLEDLG.DLL',
    'MSACM32.DLL'
)

$depRows = New-Object System.Collections.Generic.List[object]
foreach ($exe in $allExes) {
    $missing = @(Get-ExeDependencyMissing -DumpbinPath $dumpbinPath -ExePath $exe -SystemDlls $systemDlls)
    if ($missing.Count -eq 0) {
        continue
    }

    $severity = 'High'
    if (Is-DebugLikePath -Path $exe) {
        $severity = 'Info'
    }
    elseif (-not (Is-ReleaseLikePath -Path $exe)) {
        $severity = 'Info'
    }

    $depRows.Add([PSCustomObject]@{
        Exe = $exe
        Severity = $severity
        Missing = $missing -join '; '
    }) | Out-Null
}

$forbiddenRuntimeImports = @(
    'MSVCP120D.DLL',
    'MSVCR120D.DLL',
    'MSVCP100.DLL',
    'MSVCR100.DLL',
    'MSVCP100D.DLL',
    'MSVCR100D.DLL',
    'MSVCP90.DLL',
    'MSVCR90.DLL',
    'MSVCP90D.DLL',
    'MSVCR90D.DLL'
)

$legacySystemRuntimeImports = @(
    'MSVCRT.DLL'
)

$runtimeImportRows = New-Object System.Collections.Generic.List[object]
foreach ($dir in $runtimeDirs) {
    Get-ChildItem -Path $dir -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in @('.exe', '.dll') } |
        ForEach-Object {
            $deps = @(Get-DirectDependents -DumpbinPath $dumpbinPath -BinaryPath $_.FullName)
            if ($deps.Count -eq 0) {
                return
            }

            $upperDeps = @($deps | ForEach-Object { $_.ToUpperInvariant() })
            $bad = @($upperDeps | Where-Object { $forbiddenRuntimeImports -contains $_ } | Sort-Object -Unique)
            if ($bad.Count -gt 0) {
                $severity = 'High'
                if (Is-DebugLikePath -Path $_.FullName) {
                    $severity = 'Info'
                }
                elseif (-not (Is-ReleaseLikePath -Path $_.FullName)) {
                    $severity = 'Info'
                }

                $runtimeImportRows.Add([PSCustomObject]@{
                    Binary = $_.FullName
                    Severity = $severity
                    Runtime = $bad -join '; '
                }) | Out-Null
            }

            $legacySystem = @($upperDeps | Where-Object { $legacySystemRuntimeImports -contains $_ } | Sort-Object -Unique)
            if ($legacySystem.Count -gt 0) {
                $runtimeImportRows.Add([PSCustomObject]@{
                    Binary = $_.FullName
                    Severity = 'Info'
                    Runtime = $legacySystem -join '; '
                }) | Out-Null
            }
        }
}

$familyRows = @(Invoke-FamilyConsistencyChecks -RepoRoot $repoRoot)

$summary = [PSCustomObject]@{
    RepoRoot = $repoRoot
    Dumpbin = $dumpbinPath
    ScanRootCount = ($resolvedRoots | Measure-Object).Count
    ExeCount = ($allExes | Measure-Object).Count
    RequestedExecutableCount = $ExecutableNames.Count
    RequestedExecutableMissing = ($ExecutableNames.Count -gt 0 -and $allExes.Count -eq 0)
    RuntimeDirCount = ($runtimeDirs | Measure-Object).Count
    DriftCount = ($driftRows | Measure-Object).Count
    DriftHighCount = ($driftRows | Where-Object { $_.Severity -eq 'High' } | Measure-Object).Count
    MissingDepCount = ($depRows | Measure-Object).Count
    MissingDepHighCount = ($depRows | Where-Object { $_.Severity -eq 'High' } | Measure-Object).Count
    RuntimeImportCount = ($runtimeImportRows | Measure-Object).Count
    RuntimeImportHighCount = ($runtimeImportRows | Where-Object { $_.Severity -eq 'High' } | Measure-Object).Count
    FamilyCheckCount = ($familyRows | Measure-Object).Count
    FamilyHighCount = ($familyRows | Where-Object { $_.Severity -eq 'High' } | Measure-Object).Count
}

Write-Host '=== Runtime Dependency Audit Summary ===' -ForegroundColor Cyan
$summary | Format-List

if ($driftRows.Count -gt 0) {
    Write-Host "`n=== DLL Drift (same name, different hash) ===" -ForegroundColor Yellow
    $driftRows |
        Sort-Object @{ Expression = { if ($_.Severity -eq 'High') { 0 } else { 1 } } }, Dll |
        Select-Object Dll, Severity, DistinctHashCount, Locations |
        Format-Table -AutoSize
}

if ($depRows.Count -gt 0) {
    Write-Host "`n=== EXE Missing Local Dependencies ===" -ForegroundColor Yellow
    $depRows |
        Sort-Object @{ Expression = { if ($_.Severity -eq 'High') { 0 } else { 1 } } }, Exe |
        Format-Table -AutoSize
}

if ($runtimeImportRows.Count -gt 0) {
    Write-Host "`n=== Runtime Import Violations ===" -ForegroundColor Yellow
    $runtimeImportRows |
        Sort-Object @{ Expression = { if ($_.Severity -eq 'High') { 0 } else { 1 } } }, Binary |
        Format-Table -AutoSize
}

if ((($familyRows | Measure-Object).Count) -gt 0) {
    Write-Host "`n=== Family Consistency Violations ===" -ForegroundColor Red
    $familyRows | Format-Table -AutoSize
}

$report = [PSCustomObject]@{
    Summary = $summary
    Drift = @($driftRows | Sort-Object Dll)
    MissingDependencies = @($depRows | Sort-Object Exe)
    RuntimeImportViolations = @($runtimeImportRows | Sort-Object Binary)
    FamilyViolations = @($familyRows | Sort-Object Check, Dll)
}

if (-not [string]::IsNullOrWhiteSpace($ReportPath)) {
    $reportTarget = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $ReportPath
    $reportDir = Split-Path $reportTarget -Parent
    if (-not (Test-Path $reportDir)) {
        New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
    }
    ($report | ConvertTo-Json -Depth 8) | Set-Content -Path $reportTarget -Encoding UTF8
    Write-Host "`nReport saved: $reportTarget" -ForegroundColor Green
}

$hasHigh = (
    ($ExecutableNames.Count -gt 0 -and $allExes.Count -eq 0) -or
    (($driftRows | Where-Object { $_.Severity -eq 'High' } | Measure-Object).Count -gt 0) -or
    (($depRows | Where-Object { $_.Severity -eq 'High' } | Measure-Object).Count -gt 0) -or
    (($runtimeImportRows | Where-Object { $_.Severity -eq 'High' } | Measure-Object).Count -gt 0) -or
    (($familyRows | Where-Object { $_.Severity -eq 'High' } | Measure-Object).Count -gt 0)
)

if ($FailOnIssues -and $hasHigh) {
    throw 'Runtime dependency audit found HIGH issues.'
}

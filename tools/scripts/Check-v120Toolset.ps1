param(
    [string]$RootPath = '.',
    [ValidateSet('Mainline', 'All')]
    [string]$Scope = 'Mainline',
    [ValidateSet('Legacy226', 'Upgrade30')]
    [string]$EngineProfile = 'Upgrade30',
    [switch]$FailOnAnyNonV120
)

$ErrorActionPreference = 'Stop'

function Show-Check {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Detail
    )

    $prefix = if ($Passed) { '[PASS]' } else { '[FAIL]' }
    Write-Host ($prefix + ' ' + $Name + ' - ' + $Detail)
}

function Resolve-ProgramFilesX86 {
    $candidates = New-Object System.Collections.Generic.List[string]

    if (${env:ProgramFiles(x86)}) {
        [void]$candidates.Add(${env:ProgramFiles(x86)})
    }

    $folderByApi = [Environment]::GetFolderPath('ProgramFilesX86')
    if (-not [string]::IsNullOrWhiteSpace($folderByApi)) {
        [void]$candidates.Add($folderByApi)
    }

    [void]$candidates.Add('C:\Program Files (x86)')
    [void]$candidates.Add('D:\Program Files (x86)')

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        if (Test-Path $candidate) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    return $null
}

function Resolve-VS120ComnToolsPath {
    $candidates = New-Object System.Collections.Generic.List[string]

    if ($env:VS120COMNTOOLS) {
        [void]$candidates.Add($env:VS120COMNTOOLS)
    }

    [void]$candidates.Add('D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\')
    [void]$candidates.Add('C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\')

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        $toolsRoot = [System.IO.Path]::GetFullPath($candidate)
        $vcvarsPath = [System.IO.Path]::GetFullPath((Join-Path $toolsRoot '..\..\VC\vcvarsall.bat'))
        if (Test-Path $vcvarsPath) {
            return @{
                ToolsRoot = $toolsRoot
                VcVarsPath = $vcvarsPath
            }
        }
    }

    return $null
}

function Get-MainlineProjectPaths {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Profile
    )

    $modulePath = Join-Path $Root 'tools\scripts\build-config.psm1'
    Import-Module -Name $modulePath -Force
    return @(
        Get-MT3Win32ProjectManifest -RepoRoot $Root -EngineProfile $Profile -IncludeFinalExecutable |
            ForEach-Object { $_.Path }
    )
}

function Test-ProjectDeclaresV120 {
    param(
        [Parameter(Mandatory = $true)][string]$Text
    )

    return ($Text -match '<PlatformToolset(?:\s+[^>]*)?>\s*v120\s*</PlatformToolset>')
}

$root = [System.IO.Path]::GetFullPath($RootPath)
if (-not (Test-Path $root)) {
    throw ('Path not found: ' + $root)
}

$allPassed = $true

$vs120 = Resolve-VS120ComnToolsPath
$vcvarsOk = ($null -ne $vs120)
if ($vcvarsOk) {
    $env:VS120COMNTOOLS = $vs120.ToolsRoot
    Show-Check -Name 'VS120COMNTOOLS/vcvarsall' -Passed $true -Detail $vs120.VcVarsPath
} else {
    Show-Check -Name 'VS120COMNTOOLS/vcvarsall' -Passed $false -Detail 'VS2013 Common7\\Tools / vcvarsall.bat not found'
}
if (-not $vcvarsOk) { $allPassed = $false }

$programFilesX86 = Resolve-ProgramFilesX86
$msbuildPath = if ($programFilesX86) {
    Join-Path $programFilesX86 'MSBuild\\12.0\\Bin\\MSBuild.exe'
} else {
    'MSBuild\\12.0\\Bin\\MSBuild.exe'
}
$msbuildOk = Test-Path $msbuildPath
Show-Check -Name 'MSBuild 12.0' -Passed $msbuildOk -Detail $msbuildPath
if (-not $msbuildOk) { $allPassed = $false }

$missingProjectPaths = New-Object System.Collections.Generic.List[string]
if ($Scope -eq 'All') {
    $projects = @(Get-ChildItem -Path $root -Recurse -File -Filter *.vcxproj)
} else {
    $projects = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    foreach ($projectPath in (Get-MainlineProjectPaths -Root $root -Profile $EngineProfile)) {
        if (Test-Path $projectPath) {
            [void]$projects.Add((Get-Item $projectPath))
        } else {
            [void]$missingProjectPaths.Add($projectPath)
        }
    }
    $projects = @($projects)
}

if ($projects.Count -eq 0) {
    Show-Check -Name 'vcxproj scan' -Passed $false -Detail 'No vcxproj files found'
    Write-Host ''
    Write-Host 'Conclusion: v120 toolchain check failed.'
    exit 1
}

$scopeDetail = if ($Scope -eq 'Mainline') { $Scope + '/' + $EngineProfile } else { $Scope }
Show-Check -Name 'vcxproj scan scope' -Passed $true -Detail ($scopeDetail + ' (' + $projects.Count + ' projects)')

if ($missingProjectPaths.Count -gt 0) {
    Show-Check -Name 'mainline project path' -Passed $false -Detail ('Missing ' + $missingProjectPaths.Count + ' expected projects')
    $missingProjectPaths | Select-Object -First 20 | ForEach-Object { Write-Host ('  - ' + $_) }
    $allPassed = $false
}

$nonV120 = New-Object System.Collections.Generic.List[string]
foreach ($proj in $projects) {
    $text = Get-Content -Raw -Encoding UTF8 $proj.FullName
    if (-not (Test-ProjectDeclaresV120 -Text $text)) {
        [void]$nonV120.Add($proj.FullName)
    }
}

if ($nonV120.Count -eq 0) {
    Show-Check -Name 'vcxproj toolset' -Passed $true -Detail ('Scope ' + $Scope + ', total ' + $projects.Count + ' projects, all use v120')
} else {
    Show-Check -Name 'vcxproj toolset' -Passed $false -Detail ('Scope ' + $Scope + ', total ' + $projects.Count + ' projects, ' + $nonV120.Count + ' are not v120')
    $nonV120 | Select-Object -First 50 | ForEach-Object { Write-Host ('  - ' + $_) }
    if ($Scope -eq 'Mainline' -or $FailOnAnyNonV120) {
        $allPassed = $false
    }
}

Write-Host ''
if ($allPassed) {
    Write-Host 'Conclusion: v120 toolchain check passed.'
    exit 0
}

Write-Host 'Conclusion: v120 toolchain check failed.'
exit 1

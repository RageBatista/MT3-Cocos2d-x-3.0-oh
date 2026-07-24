function Resolve-RepoRootPath {
    param([string]$InputPath)

    if (-not [string]::IsNullOrWhiteSpace($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\..\.."))
}

function Get-ExistingPath {
    param([string[]]$Candidates)

    foreach ($candidate in $Candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        if (Test-Path $candidate) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }
    return ""
}

function Get-CommandSource {
    param([string]$Name)

    try {
        $command = Get-Command $Name -ErrorAction Stop
        return [string]$command.Source
    } catch {
        return ""
    }
}

function Get-CommandOutput {
    param(
        [string]$FilePath,
        [string[]]$Arguments
    )

    try {
        return @(& $FilePath @Arguments 2>&1)
    } catch {
        return @($_.Exception.Message)
    }
}

function Read-TextFileSmart {
    param([string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return [System.Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return [System.Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2)
    }

    $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        return $utf8Strict.GetString($bytes)
    } catch {
        return [System.Text.Encoding]::GetEncoding(54936).GetString($bytes)
    }
}

function Test-GitLfsPointer {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }

    $fileInfo = Get-Item -LiteralPath $Path
    if ($fileInfo.Length -gt 1024) {
        return $false
    }

    $content = [System.IO.File]::ReadAllText($fileInfo.FullName, [System.Text.Encoding]::ASCII)
    return $content -match '\Aversion https://git-lfs\.github\.com/spec/v1\r?\noid sha256:[0-9a-f]{64}\r?\nsize [0-9]+\r?\n?\z'
}

function Get-SkillScriptName {
    param([string]$ExplicitSkillName = "")

    if (-not [string]::IsNullOrWhiteSpace($ExplicitSkillName)) {
        return $ExplicitSkillName
    }

    foreach ($scope in @(1, 2, 3, 0, "Script", "Global")) {
        try {
            $value = Get-Variable -Name SkillScriptName -Scope $scope -ErrorAction Stop
            if (-not [string]::IsNullOrWhiteSpace([string]$value.Value)) {
                return [string]$value.Value
            }
        } catch {
        }
    }

    throw "SkillScriptName is not set. Assign `$script:SkillScriptName before calling Write-Result."
}

function Get-SkillJsonEnabled {
    foreach ($scope in @(1, 2, 3, 0, "Script", "Global")) {
        try {
            $value = Get-Variable -Name Json -Scope $scope -ErrorAction Stop
            return [bool]$value.Value
        } catch {
        }
    }

    return $false
}

function Resolve-FilePath {
    param(
        [string]$InputPath,
        [string]$RootPath,
        [string[]]$SearchRoots,
        [string]$DefaultExtension
    )

    $candidates = New-Object System.Collections.Generic.List[string]
    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        return ""
    }

    if ([System.IO.Path]::IsPathRooted($InputPath)) {
        $candidates.Add([System.IO.Path]::GetFullPath($InputPath)) | Out-Null
    } else {
        $candidates.Add([System.IO.Path]::GetFullPath((Join-Path $RootPath $InputPath))) | Out-Null
        foreach ($searchRoot in $SearchRoots) {
            $candidates.Add([System.IO.Path]::GetFullPath((Join-Path $searchRoot $InputPath))) | Out-Null
        }
    }

    $hasExtension = [System.IO.Path]::HasExtension($InputPath)
    if (-not $hasExtension -and -not [string]::IsNullOrWhiteSpace($DefaultExtension)) {
        $suffix = "." + $DefaultExtension.TrimStart(".")
        $more = @()
        foreach ($candidate in $candidates) {
            $more += ($candidate + $suffix)
        }
        foreach ($item in $more) {
            $candidates.Add($item) | Out-Null
        }
    }

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate -PathType Leaf) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    $fileName = if ($hasExtension) { [System.IO.Path]::GetFileName($InputPath) } else { [System.IO.Path]::GetFileName($InputPath) + "." + $DefaultExtension.TrimStart(".") }
    foreach ($searchRoot in $SearchRoots) {
        if (-not (Test-Path $searchRoot -PathType Container)) {
            continue
        }
        $match = Get-ChildItem -Path $searchRoot -Recurse -File -Filter $fileName -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $match) {
            return [System.IO.Path]::GetFullPath($match.FullName)
        }
    }

    return ""
}

function Normalize-WindowPath {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ""
    }
    return $Value.Trim().TrimEnd("/")
}

function Write-Result {
    param(
        [string]$Status,
        [string]$Summary,
        [string]$Next,
        [System.Collections.Generic.List[string]]$Details,
        [object]$Payload = $null,
        [string]$SkillName = ""
    )

    $resolvedSkillName = Get-SkillScriptName -ExplicitSkillName $SkillName
    $jsonEnabled = Get-SkillJsonEnabled

    if ($jsonEnabled) {
        $resultData = if ($null -eq $Payload) { [ordered]@{} } else { $Payload }
        $resultObject = [ordered]@{
            status = $Status
            skill = $resolvedSkillName
            summary = $Summary
            next = $Next
            details = @($Details)
            data = $resultData
        }
        $resultObject | ConvertTo-Json -Depth 6
        if ($Status -eq "FAIL") {
            exit 1
        }
        exit 0
    }

    Write-Output ("STATUS: " + $Status)
    Write-Output ("SKILL: " + $resolvedSkillName)
    Write-Output ("SUMMARY: " + $Summary)
    foreach ($detail in $Details) {
        Write-Output ("DETAIL: " + $detail)
    }
    Write-Output ("NEXT: " + $Next)

    if ($Status -eq "FAIL") {
        exit 1
    }
    exit 0
}

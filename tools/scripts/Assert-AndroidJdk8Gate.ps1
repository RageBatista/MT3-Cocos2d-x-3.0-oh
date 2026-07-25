param(
    [string]$JdkHome = "",
    [switch]$StrictNoJdk17Install
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-CommandText {
    param(
        [string]$FilePath,
        [string[]]$Arguments
    )

    try {
        return [string]::Join(" ", @(& $FilePath @Arguments 2>&1))
    }
    catch {
        return $_.Exception.Message
    }
}

function Test-IsJdk8Home {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    $java = Join-Path $Path "bin\java.exe"
    $javac = Join-Path $Path "bin\javac.exe"
    if (-not ((Test-Path -LiteralPath $java -PathType Leaf) -and (Test-Path -LiteralPath $javac -PathType Leaf))) {
        return $false
    }

    $javaVersion = Get-CommandText -FilePath $java -Arguments @("-version")
    $javacVersion = Get-CommandText -FilePath $javac -Arguments @("-version")
    return ($javaVersion -match 'version "1\.8\.' -and $javacVersion -match 'javac 1\.8\.')
}

function Resolve-Jdk8Home {
    param([string]$ExplicitPath)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        if (Test-IsJdk8Home -Path $ExplicitPath) {
            return (Resolve-Path -LiteralPath $ExplicitPath).Path
        }
        throw "Explicit -JdkHome must point to JDK8: $ExplicitPath"
    }

    $candidates = New-Object System.Collections.Generic.List[string]
    foreach ($scope in @("Process", "User", "Machine")) {
        $value = [Environment]::GetEnvironmentVariable("JAVA_HOME", $scope)
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            [void]$candidates.Add($value)
        }
    }
    foreach ($fallback in @(
        "C:\Program Files\Java\jdk1.8.0_144",
        "C:\Program Files\Java\jdk1.8.0_202",
        "C:\Program Files\Java\jdk8"
    )) {
        [void]$candidates.Add($fallback)
    }

    foreach ($candidate in $candidates) {
        if (Test-IsJdk8Home -Path $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "JDK8 not found. Android Ant/dx builds must use JDK8; JDK17+ is prohibited."
}

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$resolvedJdk8 = ""
try {
    $resolvedJdk8 = Resolve-Jdk8Home -ExplicitPath $JdkHome
}
catch {
    [void]$errors.Add($_.Exception.Message)
}

$jdk17Path = "C:\Program Files\Java\jdk-17"
if (Test-Path -LiteralPath $jdk17Path -PathType Container) {
    $message = "JDK17 installation still exists: $jdk17Path"
    if ($StrictNoJdk17Install) {
        [void]$errors.Add($message)
    }
    else {
        [void]$warnings.Add($message)
    }
}

$processJavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Process")
$userJavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
$machineJavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")

Write-Host "Android JDK8 Gate"
Write-Host "  ResolvedJdk8     : $resolvedJdk8"
Write-Host "  Process JAVA_HOME: $processJavaHome"
Write-Host "  User JAVA_HOME   : $userJavaHome"
Write-Host "  Machine JAVA_HOME: $machineJavaHome"

if ($warnings.Count -gt 0) {
    foreach ($warning in $warnings) {
        Write-Warning $warning
    }
}

if ($errors.Count -gt 0) {
    foreach ($err in $errors) {
        [Console]::Error.WriteLine("FAIL: $err")
    }
    exit 40
}

Write-Host "Gate passed: Android build can force JDK8."
exit 0

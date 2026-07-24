[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillHelperPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\mt3-project-guidelines\scripts\skill-script-helpers.ps1"))
. $skillHelperPath
$script:SkillScriptName = "platform-bridge"

function Test-Marker {
    param(
        [string]$Text,
        [string]$Pattern
    )

    return [regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
}

function Test-RequiredFile {
    param(
        [string]$Path,
        [string]$Label,
        [System.Collections.Generic.List[string]]$Details,
        [System.Collections.Generic.List[string]]$Failures,
        [string]$RepoRoot
    )

    if (Test-Path $Path -PathType Leaf) {
        [void]$Details.Add($Label + "=" + $Path.Substring($RepoRoot.Length + 1).Replace("\", "/"))
        return $true
    }

    [void]$Failures.Add("missing required platform anchor: " + $Label)
    return $false
}

function Test-FileMarkers {
    param(
        [string]$Path,
        [hashtable]$Markers,
        [string]$LabelPrefix,
        [System.Collections.Generic.List[string]]$Details,
        [System.Collections.Generic.List[string]]$Failures
    )

    $text = Read-TextFileSmart -Path $Path
    foreach ($name in $Markers.Keys) {
        if (Test-Marker -Text $text -Pattern $Markers[$name]) {
            [void]$Details.Add($LabelPrefix + "_marker=" + $name)
        } else {
            [void]$Failures.Add($LabelPrefix + " missing marker: " + $name)
        }
    }
}

$RepoRoot = Resolve-RepoRootPath -InputPath $RepoRoot
$details = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$win32Main = Join-Path $RepoRoot "client\MT3Win32App\main.cpp"
$androidProjects = @("common", "LocojoyProject", "JoysdkProject", "YijieProject")
$iosFiles = @{
    ios_main = "client/FireClient/FireClient/main.m"
    ios_app_delegate = "client/FireClient/FireClient/FireClientAppDelegate.mm"
    ios_view_controller = "client/FireClient/FireClient/FireClientViewController.mm"
    ios_gamesdk = "client/FireClient/FireClient/GameSdk.mm"
    ios_webview = "client/FireClient/FireClient/WebViewController.mm"
}

$win32Ready = Test-RequiredFile -Path $win32Main -Label "win32_main" -Details $details -Failures $failures -RepoRoot $RepoRoot
if ($win32Ready) {
    Test-FileMarkers -Path $win32Main -Markers @{
        win32_entry = '_tWinMain\s*\('
        handoff_to_shared_core = 'gRunGameApplication\s*\('
    } -LabelPrefix "win32" -Details $details -Failures $failures
}

foreach ($project in $androidProjects) {
    $jniPath = Join-Path $RepoRoot ("client\android\" + $project + "\jni\main.cpp")
    if (Test-RequiredFile -Path $jniPath -Label ("android_" + $project + "_jni") -Details $details -Failures $failures -RepoRoot $RepoRoot) {
        Test-FileMarkers -Path $jniPath -Markers @{
            jni_onload = 'JNI_OnLoad\s*\('
            native_init = 'Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInit\s*\('
            handoff_to_shared_core = 'gRunGameApplication\s*\('
        } -LabelPrefix ("android_" + $project) -Details $details -Failures $failures
    }
}

$androidJavaProjects = @("LocojoyProject", "JoysdkProject", "YijieProject")
foreach ($project in $androidJavaProjects) {
    $appPath = Join-Path $RepoRoot ("client\android\" + $project + "\src\com\locojoy\mini\mt3\Mt3Application.java")
    $activityPath = Join-Path $RepoRoot ("client\android\" + $project + "\src\org\cocos2dx\lib\Cocos2dxActivity.java")

    $appReady = Test-RequiredFile -Path $appPath -Label ("android_" + $project + "_app") -Details $details -Failures $failures -RepoRoot $RepoRoot
    if ($appReady) {
        Test-FileMarkers -Path $appPath -Markers @{
            application_class = 'class\s+Mt3Application\s+extends\s+[A-Za-z0-9_\.]+'
        } -LabelPrefix ("android_" + $project + "_app") -Details $details -Failures $failures
    }

    $activityReady = Test-RequiredFile -Path $activityPath -Label ("android_" + $project + "_activity") -Details $details -Failures $failures -RepoRoot $RepoRoot
    if ($activityReady) {
        Test-FileMarkers -Path $activityPath -Markers @{
            activity_class = 'class\s+Cocos2dxActivity\s+extends\s+Activity'
            native_bridge = 'nativeSetPaths\s*\('
        } -LabelPrefix ("android_" + $project + "_activity") -Details $details -Failures $failures
    }

    foreach ($optionalName in @("FileDownloader.java", "HTML5WebView.java")) {
        $optionalPath = Join-Path $RepoRoot ("client\android\" + $project + "\src\com\locojoy\mini\mt3\" + $optionalName)
        if (Test-Path $optionalPath -PathType Leaf) {
            [void]$details.Add("android_optional=" + $optionalPath.Substring($RepoRoot.Length + 1).Replace("\", "/"))
            $optionalText = Read-TextFileSmart -Path $optionalPath
            if ($optionalName -eq "FileDownloader.java" -and -not (Test-Marker -Text $optionalText -Pattern 'DownloadOneFile')) {
                [void]$warnings.Add($project + " FileDownloader.java missing download entry marker")
            }
            if ($optionalName -eq "HTML5WebView.java" -and -not (Test-Marker -Text $optionalText -Pattern 'extends\s+WebView')) {
                [void]$warnings.Add($project + " HTML5WebView.java missing WebView inheritance marker")
            }
        }
    }
}

$splashPath = Join-Path $RepoRoot "client\android\YijieProject\src\com\locojoy\mini\mt3\SplashActivity.java"
if (Test-Path $splashPath -PathType Leaf) {
    [void]$details.Add("android_optional=" + $splashPath.Substring($RepoRoot.Length + 1).Replace("\", "/"))
    Test-FileMarkers -Path $splashPath -Markers @{
        splash_activity = 'class\s+SplashActivity\s+extends\s+'
        splash_handoff = 'startActivity\s*\('
    } -LabelPrefix "android_yijie_splash" -Details $details -Failures $failures
}

foreach ($label in $iosFiles.Keys) {
    $fullPath = Join-Path $RepoRoot $iosFiles[$label]
    if (-not (Test-RequiredFile -Path $fullPath -Label $label -Details $details -Failures $failures -RepoRoot $RepoRoot)) {
        continue
    }

    switch ($label) {
        "ios_main" {
            Test-FileMarkers -Path $fullPath -Markers @{
                uiapplicationmain = 'UIApplicationMain\s*\('
            } -LabelPrefix $label -Details $details -Failures $failures
        }
        "ios_app_delegate" {
            Test-FileMarkers -Path $fullPath -Markers @{
                gamesdk_import = 'GameSdk'
            } -LabelPrefix $label -Details $details -Failures $failures
        }
        "ios_view_controller" {
            Test-FileMarkers -Path $fullPath -Markers @{
                viewdidload = 'viewDidLoad'
                show_webview = 'showWebView'
            } -LabelPrefix $label -Details $details -Failures $failures
        }
        "ios_gamesdk" {
            Test-FileMarkers -Path $fullPath -Markers @{
                sdk_init = 'GameSdk::init'
                login_callback = 's_loginResultCallback'
            } -LabelPrefix $label -Details $details -Failures $failures
        }
        "ios_webview" {
            Test-FileMarkers -Path $fullPath -Markers @{
                show_webview = 'showWebView'
                close_webview = 'closeWebView'
            } -LabelPrefix $label -Details $details -Failures $failures
        }
    }
}

$status = "PASS"
$summary = "The Win32, Android, and iOS shell entrypoints still hand off control along the expected platform bridge."
$next = "If the issue is after these entrypoints, stop patching shell code and switch to the shared core or resource pipeline."

if ($failures.Count -gt 0) {
    $status = "FAIL"
    $summary = "The platform bridge baseline has missing or drifted entry anchors that should be fixed before cross-platform debugging."
    $next = "Restore the missing platform entry file or handoff marker first, then rerun this probe."
} elseif ($warnings.Count -gt 0) {
    $status = "WARN"
    $summary = "The primary platform handoff chain is intact, but some secondary adapters still need manual confirmation."
    $next = "Review the warned downloader or WebView adapters before changing platform bridge code."
}

foreach ($item in $failures) {
    [void]$details.Add("failure=" + $item)
}
foreach ($item in $warnings) {
    [void]$details.Add("warning=" + $item)
}

$payload = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    win32_main_path = $win32Main
    android_projects = $androidProjects
    android_java_projects = $androidJavaProjects
    yijie_splash_path = $splashPath
    ios_anchor_files = [pscustomobject]$iosFiles
    failures = $failures.ToArray()
    warnings = $warnings.ToArray()
}

Write-Result -Status $status -Summary $summary -Next $next -Details $details -Payload $payload

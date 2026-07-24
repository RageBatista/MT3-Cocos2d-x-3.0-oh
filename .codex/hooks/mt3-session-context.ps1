[CmdletBinding()]
param()

$script:HookStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

[void][Console]::In.ReadToEnd()

[ordered]@{
    hookSpecificOutput = [ordered]@{
        hookEventName = "SessionStart"
        additionalContext = "MT3 toolchains: Win32=VS2013/v120/Windows SDK 8.1; Android=NDK r16 clang + Ant + JDK 8; Server=JDK 7/8 + Ant. Generated outputs must be changed through source definitions. Default MCP profile=none."
    }
} | ConvertTo-Json -Depth 5 -Compress

$script:HookStopwatch.Stop()
if ($env:MT3_SESSION_HOOK_TEST_TIMING -eq "1") {
    [Console]::Error.WriteLine("MT3_SESSION_ELAPSED_MS=$($script:HookStopwatch.ElapsedMilliseconds)")
}

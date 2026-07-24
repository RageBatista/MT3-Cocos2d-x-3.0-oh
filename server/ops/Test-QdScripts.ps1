param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'

function Read-Text {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing file: $Path"
    }
    return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path
}

function Assert-Contains {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Pattern,
        [Parameter(Mandatory)][string]$Message
    )
    $text = Read-Text $Path
    if ($text -notmatch $Pattern) {
        throw "$Message`nFile: $Path`nPattern: $Pattern"
    }
}

function Assert-NotContains {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Pattern,
        [Parameter(Mandatory)][string]$Message
    )
    $text = Read-Text $Path
    if ($text -match $Pattern) {
        throw "$Message`nFile: $Path`nPattern: $Pattern"
    }
}

$rootQd = Join-Path $RepoRoot 'server\ops\qd'
$commonQd = Join-Path $RepoRoot 'server\ops\game\common\qd.sh'
$sdkStart = Join-Path $RepoRoot 'server\ops\game\common\sdk_server\start.sh'
$server1GateStart = Join-Path $RepoRoot 'server\ops\game\server1\gate_server\start.sh'
$server1ProxyStart = Join-Path $RepoRoot 'server\ops\game\server1\proxy_server\start.sh'
$server1GameStart = Join-Path $RepoRoot 'server\ops\game\server1\game_server\start.sh'
$server2Qd = Join-Path $RepoRoot 'server\ops\game\server2\qd.sh'
$server2GateStart = Join-Path $RepoRoot 'server\ops\game\server2\gate_server\start.sh'
$server2ProxyStart = Join-Path $RepoRoot 'server\ops\game\server2\proxy_server\start.sh'
$server2GameStart = Join-Path $RepoRoot 'server\ops\game\server2\game_server\start.sh'
$server2GateConf = Join-Path $RepoRoot 'server\ops\game\server2\gate_server\gate.conf'
$server2ProxyConf = Join-Path $RepoRoot 'server\ops\game\server2\proxy_server\proxy.conf'
$server2GsXio = Join-Path $RepoRoot 'server\ops\game\server2\game_server\gs.xio.xml'
$server2GsMkdb = Join-Path $RepoRoot 'server\ops\game\server2\game_server\gsx.mkdb.xml'

Assert-Contains $rootQd 'acquire_operation_lock' 'root qd must serialize mutating operations'
Assert-Contains $rootQd 'LOCK_DIR=' 'root qd must use a directory lock instead of an inherited fd lock'
Assert-Contains $rootQd 'release_operation_lock' 'root qd must release its directory lock on exit'
Assert-Contains $rootQd 'mkdir "\$LOCK_DIR"' 'root qd must acquire the lock using mkdir'
Assert-NotContains $rootQd 'exec\s+9>' 'root qd must not keep an fd lock that can be inherited by daemonized services'
Assert-NotContains $rootQd '\bflock\b' 'root qd must not use flock fd locking for daemon-spawning operations'
Assert-Contains $rootQd 'show_status' 'root qd must expose a read-only status command'
Assert-Contains $rootQd 'bash "\$common_qd" start' 'root qd common start must delegate to the managed common wrapper'
Assert-Contains $rootQd 'bash "\$common_qd" stop' 'root qd common stop must delegate to the managed common wrapper'
Assert-NotContains $rootQd 'chmod\s+-R\s+777' 'root qd must not chmod runtime trees to 777'

Assert-Contains $commonQd 'case "\$\{1:-start\}" in' 'common qd must dispatch start/stop/restart/status'
Assert-Contains $commonQd 'status\)' 'common qd must implement status without starting services'
Assert-Contains $sdkStart 'SDK_LAUNCH_MODE="\$\{SDK_LAUNCH_MODE:-classpath\}"' 'sdk_server must default to the classpath launch mode used by the root qd'
Assert-Contains $sdkStart 'JAVA_SYSTEM_OPTS' 'sdk_server must preserve headless and UTF-8 JVM options'

foreach ($serviceStart in @($server1GateStart, $server1ProxyStart, $server1GameStart, $server2GateStart, $server2ProxyStart, $server2GameStart)) {
    Assert-Contains $serviceStart 'process_matches_service' "service script must recover pid by cwd/cmdline: $serviceStart"
    Assert-Contains $serviceStart 'ensure_ports_available' "service script must check listening ports before start: $serviceStart"
}

Assert-Contains $server2Qd 'SCRIPT_DIR="\$\(cd "\$\(dirname "\$\{BASH_SOURCE\[0\]\}"\)" && pwd\)"' 'server2 qd must be script-dir based'
Assert-Contains $server2Qd 'case "\$\{1:-start\}" in' 'server2 qd must dispatch start/stop/restart/status'
Assert-Contains $server2GameStart '^#!/bin/bash' 'server2 game start must be a Linux bash script'
Assert-NotContains $server2GameStart '@echo off' 'server2 game start must not be a Windows batch file'
Assert-Contains $server2GateConf 'port\s*=\s*42002' 'server2 gate client port must be zone-specific'
Assert-Contains $server2GateConf 'port\s*=\s*43002' 'server2 gate provider port must be zone-specific'
Assert-Contains $server2GateConf 'port\s*=\s*44002' 'server2 gate delivery port must be zone-specific'
Assert-Contains $server2ProxyConf 'port\s*=\s*44002' 'server2 proxy delivery port must be zone-specific'
Assert-Contains $server2ProxyConf 'port\s*=\s*45002' 'server2 proxy game db port must be zone-specific'
Assert-Contains $server2ProxyConf 'serverid\s*=\s*1000000002' 'server2 proxy serverid must be zone-specific'
Assert-Contains $server2GsXio 'remotePort="43002"' 'server2 game must connect to server2 provider port'
Assert-Contains $server2GsXio 'remotePort="45002"' 'server2 game must connect to server2 game db port'
Assert-Contains $server2GsMkdb 'localId="2"' 'server2 game mkdb localId must be zone-specific'

'OK: qd scripts satisfy static operational gates.'

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'

function Read-Utf8Text {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Read-Cp936Text {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::GetEncoding(936))
}

function Assert-LocalFunctionBeforeFunction {
    param(
        [string]$Text,
        [string]$LocalFunctionName,
        [string]$FunctionName,
        [string]$Message
    )
    $localPattern = "local\s+function\s+$LocalFunctionName\s*\("
    $functionPattern = "function\s+$FunctionName\s*\("
    $localMatch = [regex]::Match($Text, $localPattern)
    $functionMatch = [regex]::Match($Text, $functionPattern)
    if (-not $localMatch.Success) {
        throw "Missing local function: $LocalFunctionName"
    }
    if (-not $functionMatch.Success) {
        throw "Missing function: $FunctionName"
    }
    if ($localMatch.Index -gt $functionMatch.Index) {
        throw $Message
    }
}

function Assert-Contains {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )
    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-NotContains {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )
    if ($Text -match $Pattern) {
        throw $Message
    }
}

$loginCpp = Read-Utf8Text (Join-Path $RepoRoot 'client\FireClient\Application\Manager\LoginManager.cpp')
$loginHeader = Read-Utf8Text (Join-Path $RepoRoot 'client\FireClient\Application\Manager\LoginManager.h')
$selectServerEntry = Read-Utf8Text (Join-Path $RepoRoot 'client\resource\res\script\logic\selectserverentry.lua')
$selectServersDialog = Read-Cp936Text (Join-Path $RepoRoot 'client\resource\res\script\logic\selectserversdialog.lua')
$reconnectDlg = Read-Utf8Text (Join-Path $RepoRoot 'client\resource\res\script\logic\reconnectdlg.lua')

Assert-Contains $loginHeader 'public\s+cocos2d::CCObject\s*,\s*public\s+CSingleton<LoginManager>' 'LoginManager must be a CCObject target for CCHttpRequest callbacks.'
Assert-Contains $loginCpp 'StartAccountHttpRequest\s*\(' 'LoginManager must start HTTP login/register requests.'
Assert-Contains $loginCpp 'OnLoginAccountHttpResponse' 'LoginManager must define the login HTTP callback.'
Assert-Contains $loginCpp 'OnRegisterAccountHttpResponse' 'LoginManager must define the register HTTP callback.'
Assert-Contains $loginCpp 'session' 'HTTP response parsing must accept session.'
Assert-Contains $loginCpp 'token' 'HTTP response parsing must accept token.'
Assert-Contains $loginCpp 'sid' 'HTTP response parsing must accept sid.'
Assert-Contains $loginCpp 'password' 'HTTP response parsing must keep password fallback for the current web API.'
Assert-Contains $loginHeader 'GetSessionKey\s*\(' 'LoginManager must expose an explicit HTTP session/key getter.'
Assert-Contains $loginHeader 'SetSessionKey\s*\(' 'LoginManager must expose an explicit HTTP session/key setter.'
Assert-Contains $loginCpp 'GetPassword\(\)[\s\S]*return\s+GetSessionKey\(\);' 'LoginManager GetPassword compatibility wrapper must return the HTTP session/key.'
Assert-Contains $loginCpp 'SetPassword\([\s\S]*SetSessionKey\(password\);' 'LoginManager SetPassword compatibility wrapper must write the HTTP session/key.'
Assert-Contains $loginCpp 'SetSessionKey\(StringCover::to_wstring\(session\)\)' 'LoginManager must save the HTTP session/token as the game login credential.'
Assert-NotContains $loginCpp 'LoginAccount[\s\S]*SetPassword\(StringCover::to_wstring\(password\)\);[\s\S]*OpenSelectServerEntryWithSavedAccount\("account login"\)' 'LoginAccount must not directly save the typed password and enter server selection.'
Assert-NotContains $loginCpp 'RegisterAccount[\s\S]*SetPassword\(StringCover::to_wstring\(password\)\);[\s\S]*OpenSelectServerEntryWithSavedAccount\("account register"\)' 'RegisterAccount must not directly save the typed password and enter server selection.'
Assert-NotContains $selectServerEntry 'account\s*\.\.\s*"\|"\s*\.\.\s*key' 'selectserverentry.lua must not build account|password for CreateConnection.'
Assert-Contains $selectServerEntry 'local\s+sign_key\s*=\s*key' 'selectserverentry.lua must pass the saved HTTP credential directly.'
Assert-LocalFunctionBeforeFunction $selectServersDialog 'SelectServersDialogDiag' 'SelectServersDialog:OnCreate' 'selectserversdialog.lua must define SelectServersDialogDiag before OnCreate; Lua local functions are not visible to earlier chunk functions.'
Assert-LocalFunctionBeforeFunction $selectServersDialog 'SelectServersDialogTableCount' 'SelectServersDialog:OnCreate' 'selectserversdialog.lua must define SelectServersDialogTableCount before OnCreate; Lua local functions are not visible to earlier chunk functions.'
Assert-LocalFunctionBeforeFunction $selectServersDialog 'SelectServersDialogServerCount' 'SelectServersDialog:OnCreate' 'selectserversdialog.lua must define SelectServersDialogServerCount before OnCreate; Lua local functions are not visible to earlier chunk functions.'
Assert-NotContains $reconnectDlg 'account\s*\.\.\s*"\|"\s*\.\.\s*key' 'reconnectdlg.lua must not rebuild account|password during reconnect.'
Assert-Contains $reconnectDlg 'local\s+sign_key\s*=\s*key' 'reconnectdlg.lua must reuse the saved HTTP credential directly.'

Write-Host 'STATUS: PASS'
Write-Host 'SUMMARY: Login HTTP flow static checks passed.'

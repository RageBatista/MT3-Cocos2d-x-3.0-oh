@echo off
setlocal
set "TOOL=%~dp0LJFilePack.exe"

if not exist "%TOOL%" (
    echo [ERROR] Missing dependency: "%TOOL%"
    exit /b 1
)

if "%~1"=="" (
    echo Usage: %~nx0 ^<update_pack_list.txt^>
    echo line 1: output directory ending with /
    echo line 2+: absolute update pack directories ending with /
    exit /b 1
)

chcp 936 >nul
"%TOOL%" makeupdatepackall:%~1

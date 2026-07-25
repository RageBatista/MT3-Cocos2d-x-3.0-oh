@echo off
setlocal
set "TOOL=%~dp0LJFilePack.exe"

if not exist "%TOOL%" (
    echo [ERROR] Missing dependency: "%TOOL%"
    exit /b 1
)

if "%~1"=="" (
    echo Usage: %~nx0 ^<path_to_fl.ljpi^>
    exit /b 1
)

"%TOOL%" unpack:"%~1"

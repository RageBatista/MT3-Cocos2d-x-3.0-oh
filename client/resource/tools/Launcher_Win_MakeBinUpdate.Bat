@echo off
setlocal
for %%I in ("%~dp0..") do set "LAUNCHER_DIR=%%~fI"
set "FILELIST=bin/release/FileList.xml"

if not exist "%LAUNCHER_DIR%\Launcher.exe" (
    echo [ERROR] Missing dependency: "%LAUNCHER_DIR%\Launcher.exe"
    exit /b 1
)

if not exist "%LAUNCHER_DIR%\%FILELIST%" set "FILELIST=bin/release-Archive/FileList.xml"

if not exist "%LAUNCHER_DIR%\%FILELIST%" (
    echo [ERROR] Missing FileList.xml under "%LAUNCHER_DIR%\bin".
    exit /b 1
)

pushd "%LAUNCHER_DIR%"
Launcher.exe makebinupdate:%FILELIST%^|res1/Update/bin/release/
set "EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %EXIT_CODE%

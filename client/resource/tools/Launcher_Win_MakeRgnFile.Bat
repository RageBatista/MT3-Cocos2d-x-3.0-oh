@echo off
setlocal
for %%I in ("%~dp0..") do set "LAUNCHER_DIR=%%~fI"
set "IMAGE=bin/release/LauncherImageBG.png"
set "RGN=bin/release/LauncherImageBG.rgn"

if not exist "%LAUNCHER_DIR%\Launcher.exe" (
    echo [ERROR] Missing dependency: "%LAUNCHER_DIR%\Launcher.exe"
    exit /b 1
)

if not exist "%LAUNCHER_DIR%\%IMAGE%" (
    echo [ERROR] Missing source image: "%LAUNCHER_DIR%\%IMAGE%"
    exit /b 1
)

start "" /d "%LAUNCHER_DIR%" Launcher.exe "makergnfile:%IMAGE%|%RGN%|10|20|10"

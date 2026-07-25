@echo off
setlocal

set "ROOT=%~dp0..\dist\mvp"
set "APP=%ROOT%\LJFilePackUnpacker.MvpGui.exe"

if not exist "%APP%" (
    echo [ERROR] MVP executable not found: %APP%
    echo Run: powershell -ExecutionPolicy Bypass -File .\tools\LJFilePackUnpacker\scripts\Build-MVP-OneClickUnpacker.ps1
    exit /b 1
)

start "" "%APP%"
exit /b 0

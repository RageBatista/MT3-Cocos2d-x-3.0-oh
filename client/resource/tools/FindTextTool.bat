@echo off
setlocal
set "TOOL=%~dp0text1.exe"
set "KEYWORD=%~dp0FindTextKeyWord.txt"
set "RESULT=%~dp0FindTextResult.txt"
set "TARGET=%~1"
for %%I in ("%~dp0..\..\..\FindTextResult.tmp.txt") do set "TMP_RESULT=%%~fI"

if "%TARGET%"=="" set "TARGET=E:\MT_GMemory"

if not exist "%TOOL%" (
    echo [ERROR] Missing dependency: "%TOOL%"
    exit /b 1
)

if not exist "%KEYWORD%" (
    echo [ERROR] Missing keyword file: "%KEYWORD%"
    exit /b 1
)

if not exist "%TARGET%" (
    echo [ERROR] Search root does not exist: "%TARGET%"
    exit /b 1
)

if exist "%RESULT%" del /q "%RESULT%"
if exist "%TMP_RESULT%" del /q "%TMP_RESULT%"

"%TOOL%" FindText "%TARGET%" "%KEYWORD%" "%TMP_RESULT%" >nul

for /l %%I in (1,1,20) do (
    if exist "%TMP_RESULT%" (
        move /y "%TMP_RESULT%" "%RESULT%" >nul 2>nul
        if exist "%RESULT%" goto done
    )
    timeout /t 1 >nul
)

echo [ERROR] text1.exe did not produce a usable result file.
exit /b 1

:done
exit /b 0

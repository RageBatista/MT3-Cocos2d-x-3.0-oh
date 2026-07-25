@echo off
setlocal enabledelayedexpansion

for %%I in ("%~dp0.") do set "PROJECT_DIR=%%~fI"
for %%I in ("%PROJECT_DIR%\..\..\..") do set "ROOT_DIR=%%~fI"

set "TARGET_DIR=%PROJECT_DIR%\libs\arm64-v8a"
set "ARM64_SRC=%ROOT_DIR%\out\apktool_mengyu\lib\arm64-v8a"
if not "%~1"=="" set "ARM64_SRC=%~1"

set "DU_FALLBACK=%ROOT_DIR%\client\3rdplatform\duClient_SDK_Lib\libs\arm64-v8a\libdu.so"
set "LOC_FALLBACK=%ROOT_DIR%\client\3rdplatform\BaiduLBS_AndroidSDK_Lib\libs\arm64-v8a\liblocSDK6a.so"

echo [INFO] PROJECT_DIR=%PROJECT_DIR%
echo [INFO] ROOT_DIR=%ROOT_DIR%
echo [INFO] ARM64_SRC=%ARM64_SRC%
echo [INFO] TARGET_DIR=%TARGET_DIR%

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

if exist "%ARM64_SRC%\libgame.so" (
    copy /Y "%ARM64_SRC%\libgame.so" "%TARGET_DIR%\libgame.so" >nul
) else (
    echo [ERROR] Missing libgame.so in: %ARM64_SRC%
    echo [HINT] Provide a valid arm64 lib directory as first argument.
    exit /b 1
)

if exist "%ARM64_SRC%\libdu.so" (
    copy /Y "%ARM64_SRC%\libdu.so" "%TARGET_DIR%\libdu.so" >nul
) else (
    if exist "%DU_FALLBACK%" (
        copy /Y "%DU_FALLBACK%" "%TARGET_DIR%\libdu.so" >nul
    ) else (
        echo [ERROR] Missing libdu.so in both:
        echo         %ARM64_SRC%
        echo         %DU_FALLBACK%
        exit /b 1
    )
)

if exist "%ARM64_SRC%\liblocSDK6a.so" (
    copy /Y "%ARM64_SRC%\liblocSDK6a.so" "%TARGET_DIR%\liblocSDK6a.so" >nul
) else (
    if exist "%LOC_FALLBACK%" (
        copy /Y "%LOC_FALLBACK%" "%TARGET_DIR%\liblocSDK6a.so" >nul
    ) else (
        echo [ERROR] Missing liblocSDK6a.so in both:
        echo         %ARM64_SRC%
        echo         %LOC_FALLBACK%
        exit /b 1
    )
)

for %%F in (libgame.so libdu.so liblocSDK6a.so) do (
    if not exist "%TARGET_DIR%\%%F" (
        echo [ERROR] Missing target file: %TARGET_DIR%\%%F
        exit /b 1
    )
)

echo [OK] arm64-v8a libraries are ready in %TARGET_DIR%
dir /b "%TARGET_DIR%"
exit /b 0


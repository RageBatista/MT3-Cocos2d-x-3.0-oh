@echo off
REM MT3 编译前验证钩子
REM 检查工具集配置是否为 v120

setlocal enabledelayedexpansion

set "PROJECT_FILE=%~1"

if "%PROJECT_FILE%"=="" (
    echo [HOOK] No project file specified
    exit /b 0
)

REM 检查工具集版本
findstr /i "PlatformToolset.*v140" "%PROJECT_FILE%" >nul 2>&1
if !errorlevel! equ 0 (
    echo [ERROR] 检测到 v140 工具集!
    echo [ERROR] MT3 项目必须使用 VS2013 (v120)
    echo [ERROR] 请修改项目文件: %PROJECT_FILE%
    exit /b 1
)

findstr /i "PlatformToolset.*v141" "%PROJECT_FILE%" >nul 2>&1
if !errorlevel! equ 0 (
    echo [ERROR] 检测到 v141 工具集!
    echo [ERROR] MT3 项目必须使用 VS2013 (v120)
    exit /b 1
)

findstr /i "PlatformToolset.*v142" "%PROJECT_FILE%" >nul 2>&1
if !errorlevel! equ 0 (
    echo [ERROR] 检测到 v142 工具集!
    echo [ERROR] MT3 项目必须使用 VS2013 (v120)
    exit /b 1
)

findstr /i "PlatformToolset.*v143" "%PROJECT_FILE%" >nul 2>&1
if !errorlevel! equ 0 (
    echo [ERROR] 检测到 v143 工具集!
    echo [ERROR] MT3 项目必须使用 VS2013 (v120)
    exit /b 1
)

echo [HOOK] 工具集验证通过 (v120)
exit /b 0

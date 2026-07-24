@echo off
REM MT3 生成代码检查钩子
REM 警告用户可能修改了生成的代码

setlocal enabledelayedexpansion

set "FILE=%~1"

if "%FILE%"=="" (
    exit /b 0
)

REM 检查是否为 xbean 生成的代码
echo %FILE% | findstr /i "xbean" >nul
if !errorlevel! equ 0 (
    echo.
    echo [WARNING] ============================================
    echo [WARNING] 检测到修改 xbean 目录下的文件: %FILE%
    echo [WARNING] ============================================
    echo [WARNING] xbean 目录包含自动生成的代码
    echo [WARNING] 请确认这是通过 'ant xbean' 生成的，而非手动修改
    echo [WARNING] 手动修改会在下次生成时被覆盖!
    echo [WARNING] ============================================
    echo.
)

REM 检查是否为 gnet 生成的代码
echo %FILE% | findstr /i "rpc" >nul
if !errorlevel! equ 0 (
    echo.
    echo [WARNING] ============================================
    echo [WARNING] 检测到修改 rpc 目录下的文件: %FILE%
    echo [WARNING] ============================================
    echo [WARNING] rpc 目录包含自动生成的代码
    echo [WARNING] 请确认这是通过 'ant gnet' 生成的，而非手动修改
    echo [WARNING] 手动修改会在下次生成时被覆盖!
    echo [WARNING] ============================================
    echo.
)

REM 检查是否为 tolua++ 生成的代码
echo %FILE% | findstr /i "_tolua.cpp" >nul
if !errorlevel! equ 0 (
    echo.
    echo [WARNING] ============================================
    echo [WARNING] 检测到修改 tolua++ 生成的文件: %FILE%
    echo [WARNING] ============================================
    echo [WARNING] *_tolua.cpp 文件由 tolua++ 自动生成
    echo [WARNING] 请确认这是通过生成脚本生成的，而非手动修改
    echo [WARNING] 手动修改会在下次生成时被覆盖!
    echo [WARNING] ============================================
    echo.
)

exit /b 0

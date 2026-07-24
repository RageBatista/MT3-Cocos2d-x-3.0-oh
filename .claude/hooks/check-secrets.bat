@echo off
REM MT3 敏感信息检查钩子
REM 检查暂存文件是否包含敏感信息

setlocal enabledelayedexpansion

echo [HOOK] 检查敏感信息...

REM 获取暂存的文件列表
for /f "delims=" %%f in ('git diff --cached --name-only 2^>nul') do (
    set "FILE=%%f"

    REM 跳过二进制文件和配置模板
    echo !FILE! | findstr /i "\.png \.jpg \.zip \.apk \.lib \.dll" >nul
    if !errorlevel! neq 0 (
        REM 检查敏感关键词
        git show ":!FILE!" 2>nul | findstr /i "password= secret= api_key= credentials" >nul
        if !errorlevel! equ 0 (
            echo [WARNING] 文件 !FILE! 可能包含敏感信息!
            echo [WARNING] 请确认后再提交
        )
    )
)

REM 检查 .env 文件
git diff --cached --name-only | findstr /i "\.env" >nul
if !errorlevel! equ 0 (
    echo [ERROR] 检测到 .env 文件!
    echo [ERROR] 禁止提交环境配置文件
    exit /b 1
)

REM 检查密钥文件
git diff --cached --name-only | findstr /i "\.pem \.key \.p12" >nul
if !errorlevel! equ 0 (
    echo [ERROR] 检测到密钥文件!
    echo [ERROR] 禁止提交密钥文件
    exit /b 1
)

echo [HOOK] 敏感信息检查完成
exit /b 0

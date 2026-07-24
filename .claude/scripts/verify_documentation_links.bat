@echo off
REM =====================================================
REM 文档链接校验脚本 (Windows 批处理版本)
REM 版本: 1.0
REM 功能: 检查 .claude/*.md 和 docs/*.md 中的链接有效性
REM =====================================================

setlocal enabledelayedexpansion

title MT3 文档链接校验

echo.
echo ========================================
echo   MT3 文档链接校验工具 v1.0
echo ========================================
echo.

set "TOTAL_LINKS=0"
set "BROKEN_LINKS=0"
set "VALID_LINKS=0"

REM 检查 .claude 目录中的 Markdown 文件
echo [1/2] 检查 .claude/*.md 文件...
echo.

for %%F in (.claude\*.md) do (
    echo 正在检查: %%F

    REM 使用 findstr 提取 Markdown 链接 [text](path)
    for /f "tokens=*" %%L in ('findstr /r "\[.*\](.*\.md.*)" "%%F" 2^>nul') do (
        set "LINE=%%L"

        REM 简化处理: 提取括号中的路径
        for /f "tokens=2 delims=()" %%P in ("!LINE!") do (
            set "LINK_PATH=%%P"

            REM 移除锚点和行号 (#xxx)
            for /f "tokens=1 delims=#" %%C in ("!LINK_PATH!") do (
                set "CLEAN_PATH=%%C"

                REM 转换相对路径 (../ → 上级目录)
                set "CHECK_PATH=!CLEAN_PATH!"

                REM 仅检查以 .md 结尾的本地文件链接
                echo !CLEAN_PATH! | findstr /i "\.md$" >nul
                if not errorlevel 1 (
                    set /a TOTAL_LINKS+=1

                    REM 检查文件是否存在
                    if exist "!CHECK_PATH!" (
                        set /a VALID_LINKS+=1
                    ) else (
                        set /a BROKEN_LINKS+=1
                        echo     [✗] 失效链接: !CLEAN_PATH! ^(来源: %%F^)
                    )
                )
            )
        )
    )
)

echo.
echo [2/2] 检查 docs/*.md 文件...
echo.

for /r docs %%F in (*.md) do (
    echo 正在检查: %%F

    REM 同样的链接检查逻辑
    for /f "tokens=*" %%L in ('findstr /r "\[.*\](.*\.md.*)" "%%F" 2^>nul') do (
        set "LINE=%%L"

        for /f "tokens=2 delims=()" %%P in ("!LINE!") do (
            set "LINK_PATH=%%P"

            for /f "tokens=1 delims=#" %%C in ("!LINK_PATH!") do (
                set "CLEAN_PATH=%%C"
                set "CHECK_PATH=!CLEAN_PATH!"

                echo !CLEAN_PATH! | findstr /i "\.md$" >nul
                if not errorlevel 1 (
                    set /a TOTAL_LINKS+=1

                    if exist "!CHECK_PATH!" (
                        set /a VALID_LINKS+=1
                    ) else (
                        set /a BROKEN_LINKS+=1
                        echo     [✗] 失效链接: !CLEAN_PATH! ^(来源: %%F^)
                    )
                )
            )
        )
    )
)

echo.
echo ========================================
echo   校验结果
echo ========================================
echo.
echo 总链接数:   %TOTAL_LINKS%
echo 有效链接:   %VALID_LINKS%
echo 失效链接:   %BROKEN_LINKS%
echo.

if %BROKEN_LINKS% GTR 0 (
    echo [警告] 发现 %BROKEN_LINKS% 个失效链接！
    echo.
    echo [建议]
    echo   1. 检查文件是否已移动或重命名
    echo   2. 更新相关文档中的链接
    echo   3. 运行 git status 查看文件变更
    echo.
    exit /b 1
) else (
    echo [✓] 所有链接校验通过！
    echo.
    exit /b 0
)

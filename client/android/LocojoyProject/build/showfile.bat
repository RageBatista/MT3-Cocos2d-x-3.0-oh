@echo off

setlocal enabledelayedexpansion

for /r %%a in (*.*) do (
    set a=%%a
    echo "!a!" >> tmp.txt
)

pause


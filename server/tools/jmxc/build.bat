@echo off
REM ============================================
REM jmxc 项目构建脚本
REM 用途: 清理、编译、打包 jmxc.jar
REM ============================================

echo [1/4] 清理旧的编译文件...
if exist bin rmdir /s /q bin
if exist jmxc-new.jar del jmxc-new.jar
mkdir bin

echo [2/4] 编译 Java 源代码...
javac -d bin -encoding UTF-8 ^
  src\jmxc.java ^
  src\ConnectTask.java ^
  src\com\jmxservice\mt3interfaces\GameOnlineNumBean.java ^
  src\com\jmxservice\mt3interfaces\LogInfo.java

if %errorlevel% neq 0 (
    echo 编译失败！
    exit /b 1
)

echo [3/4] 创建 MANIFEST.MF...
(
echo Manifest-Version: 1.0
echo Class-Path: .
echo Main-Class: jmxc
echo.
) > manifest.txt

echo [4/4] 打包 JAR 文件...
jar -cvfm jmxc-new.jar manifest.txt -C bin .

if %errorlevel% neq 0 (
    echo 打包失败！
    exit /b 1
)

echo.
echo ============================================
echo 构建成功！
echo 新的 jar 文件: jmxc-new.jar
echo 文件大小:
dir jmxc-new.jar | find "jmxc-new.jar"
echo ============================================
echo.

REM 清理临时文件
del manifest.txt

echo [可选] 测试新的 jar 包...
echo 运行命令: java -jar jmxc-new.jar
echo.

pause

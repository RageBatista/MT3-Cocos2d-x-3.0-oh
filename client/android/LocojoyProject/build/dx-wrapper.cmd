@echo off
setlocal
set "DX_DIR=D:\android-sdk_r24.1.2-windows\android-sdk-windows\build-tools\22.0.1"
set "DX_LIB_DIR=%DX_DIR%\lib"
set "JAVA_EXE=C:\Program Files\Java\jdk1.8.0_144\bin\java.exe"
"%JAVA_EXE%" -Xmx1024M -Xss1m -Djava.ext.dirs="%DX_LIB_DIR%" -jar "%DX_LIB_DIR%\dx.jar" %*

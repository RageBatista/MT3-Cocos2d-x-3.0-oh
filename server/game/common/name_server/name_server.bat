@echo off
title=name_server
del nsdb\mkdb.inuse
if "%JAVA_ENCODING_OPTS%"=="" set "JAVA_ENCODING_OPTS=-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
java %JAVA_ENCODING_OPTS% -cp ./lib/jio.jar;./lib/monkeyking.jar;ns.jar com.locojoy.ns.Main nsdb.xml
pause


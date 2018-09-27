@echo off
setlocal enabledelayedexpansion

REM include /showIncludes for debugging includes

SET TARGET_NAME=show-touchkeyboard

SET TARGET=%TARGET_NAME%.exe
SET TARGET_DEBUG=%TARGET_NAME%__debug.exe

SET SOURCES=show.cpp

SET INCLUDE_DIRECTORIES=
SET LIB_DIRECTORIES=
SET LIBS=user32.lib gdi32.lib gdiplus.lib  ole32.lib shlwapi.lib
set LIB_OPTIONS=/PROFILE /DEBUG /DEBUGTYPE:CV

SET OPTIMIZATION=/Ox /favor:ATOM
SET DEBUG=/favor:ATOM /ZI 
SET WARNING_LEVEL=/W4 /we4090

rem del %TARGET%
rem del %TARGET_DEBUG%
rem del %TARGET_AVX2%

echo Build TARGET_DEBUG
call cl %WARNING_LEVEL% /nologo /EHsc /MT %SOURCES% %DEBUG%  %INCLUDE_DIRECTORIES% /link /out:%TARGET_DEBUG% %LIB_DIRECTORIES% %LIBS% %LIB_OPTIONS% %*
if %errorlevel% neq 0 exit /b %errorlevel%

echo Build TARGET
call cl %WARNING_LEVEL% /nologo /EHsc /MT /DNDEBUG %SOURCES% %OPTIMIZATION%  %INCLUDE_DIRECTORIES% /link /out:%TARGET% %LIB_DIRECTORIES% %LIBS% %LIB_OPTIONS% %* > build.log
if %errorlevel% neq 0 exit /b %errorlevel%

del *.obj

echo Finished.
exit /b 0

:compile_error
echo Error compiling %errorlevel%
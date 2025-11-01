@setlocal ENABLEDELAYEDEXPANSION
@set loopcount=0

:delcmploop
@set pubdrvpos=-1
@set scandrvpos=-1
@set exitloop=0
@for /F tokens^=1^,2^ delims^=^:^ eol^= %%a IN ('pnputil /enum-drivers') do @(
IF !exitloop! EQU 0 (
set /a scandrvpos+=1
set drvval=%%b
IF /I "!drvval: =!"=="%1" (
set pubdrvpos=!scandrvpos!
set exitloop=1
set /a loopcount+=1
)
)
)

@IF NOT !pubdrvpos! EQU -1 set scandrvpos=0
@IF NOT !pubdrvpos! EQU -1 for /F tokens^=1^,2^ delims^=^:^ eol^= %%a IN ('pnputil /enum-drivers') do @(
set /a scandrvpos+=1
set drvval=%%b
IF !scandrvpos! EQU !pubdrvpos! echo Removing Realtek UAD component %1 instance #!loopcount!...
IF !scandrvpos! EQU !pubdrvpos! pnputil /delete-driver !drvval: =! /force /norestart /uninstall
IF !scandrvpos! EQU !pubdrvpos! echo.
)
@IF NOT !pubdrvpos! EQU -1 GOTO delcmploop
@endlocal

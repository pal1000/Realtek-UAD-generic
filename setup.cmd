@echo off

:: BatchGotAdmin
:-------------------------------------
setlocal EnableDelayedExpansion

NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto RestoreCD ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' ( goto RestoreCD )

set "batchPath=%~f0"
set "batchArgs=ELEV"

::Add quotes to the batch path, if needed
set "script=%0"
set script=%script:"=%
IF '%0'=='!script!' ( GOTO PathQuotesDone )
    set "batchPath=""%batchPath%"""
:PathQuotesDone

::Add quotes to the arguments, if needed.
:ArgLoop
IF '%1'=='' ( GOTO EndArgLoop ) else ( GOTO AddArg )
    :AddArg
    set "arg=%1"
    set arg=%arg:"=%
    IF '%1'=='!arg!' ( GOTO NoQuotes )
        set "batchArgs=%batchArgs% "%1""
        GOTO QuotesDone
        :NoQuotes
        set "batchArgs=%batchArgs% %1"
    :QuotesDone
    shift
    GOTO ArgLoop
:EndArgLoop

::Create and run the vb script to elevate the batch file
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "cmd", "/c ""!batchPath! !batchArgs!""", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%windir%\system32\wscript.exe" "%temp%\OEgetPrivileges.vbs"
exit /B

:RestoreCD
::Remove the elevation tag and set the correct working directory
IF '%1'=='ELEV' ( shift /1 )
endlocal
cd /d "%~dp0"
:--------------------------------------
@TITLE Realtek UAD generic driver setup
@echo Begin uninstalling Realtek UAD driver...
@echo.
@set srventa=1
@set srventb=1
@SET ERRORLEVEL=0
@REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService > nul 2>&1
@IF ERRORLEVEL 1 set srventa=0
@SET ERRORLEVEL=0
@REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run /v RtkAudUService > nul 2>&1
@IF ERRORLEVEL 1 set srventb=0
@IF %srventa% EQU 0 IF %srventb% EQU 0 GOTO checkservice
@echo Removing Realtek Audio Universal Service registration record...
@echo.
@IF %srventa% EQU 1 REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService /f > nul 2>&1
@IF %srventb% EQU 1 REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run /v RtkAudUService /f > nul 2>&1
@net stop RtkAudioUniversalService > nul 2>&1
@sc delete RtkAudioUniversalService > nul 2>&1
@echo Done.
@echo.
@set srvkillloop=0

:checkservice
@set runningservice=0
@for /f "USEBACKQ" %%a IN (`tasklist /FI "IMAGENAME eq RtkAudUService64.exe"`) do @set /a runningservice+=1 > nul
@IF %runningservice% GTR 1 echo Terminating per-user instances of Realtek Audio Universal Service...
@IF %runningservice% GTR 1 set /a srvkillloop+=1
@IF %srvkillloop% EQU 2 echo.
@IF %srvkillloop% EQU 2 echo ERROR: Failed to terminate Realtek Audio Universal Service. Something is wrong.
@IF %srvkillloop% EQU 2 echo Press any key if you really want to continue.
@IF %srvkillloop% EQU 2 echo.
@IF %srvkillloop% EQU 2 pause > nul
@IF %srvkillloop% EQU 2 GOTO cleandrvstore
@IF %runningservice% GTR 1 taskkill /f /im RtkAudUService64.exe > nul 2>&1
@IF %runningservice% GTR 1 echo.
@IF %runningservice% GTR 1 echo Done.
@IF %runningservice% GTR 1 echo.
@IF %runningservice% GTR 1 GOTO checkservice

:cleandrvstore
@set ERRORLEVEL=0
@where /q devcon
@IF ERRORLEVEL 1 echo Windows Device console - devcon.exe is required.&echo.&pause&exit
@echo @call %0 >"%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@devcon /r disable =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*"
@echo.
@devcon /r disable =MEDIA "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
@devcon /r remove =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*"
@echo.
@devcon /r remove =MEDIA "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
@setlocal ENABLEDELAYEDEXPANSION
@set core=0
@set sst=0
@set ext=0
@set extraext=0
@set service=0
@set hsa=0
@set apo=0

@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&if /I "!finddrv: =!"=="hdxrt.inf" set /a core=!drvcount!-1
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&IF !drvcount! EQU %core% pnputil /delete-driver !finddrv: =! /force /reboot
@IF NOT %core% EQU 0 echo.

@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&if /I "!finddrv: =!"=="hdxrtsst.inf" set /a sst=!drvcount!-1
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&IF !drvcount! EQU %sst% pnputil /delete-driver !finddrv: =! /force /reboot
@IF NOT %sst% EQU 0 echo.

@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&if /I "!finddrv: =!"=="hdx_genericext_rtk.inf" set /a ext=!drvcount!-1
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&IF !drvcount! EQU %ext% pnputil /delete-driver !finddrv: =! /force /reboot
@IF NOT %ext% EQU 0 echo.

@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&if /I "!finddrv: =!"=="GenericAudioExtRT.inf" set /a extraext=!drvcount!-1
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&IF !drvcount! EQU %extraext% pnputil /delete-driver !finddrv: =! /force /reboot
@IF NOT %extraext% EQU 0 echo.

@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&if /I "!finddrv: =!"=="realtekservice.inf" set /a service=!drvcount!-1
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&IF !drvcount! EQU %service% pnputil /delete-driver !finddrv: =! /force /reboot
@IF NOT %service% EQU 0 echo.

@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&if /I "!finddrv: =!"=="realtekhsa.inf" set /a hsa=!drvcount!-1
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&IF !drvcount! EQU %hsa% pnputil /delete-driver !finddrv: =! /force /reboot
@IF NOT %hsa% EQU 0 echo.

@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&if /I "!finddrv: =!"=="realtekapo.inf" set /a apo=!drvcount!-1
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @set /a drvcount+=1&set finddrv=%%b&IF !drvcount! EQU %apo% pnputil /delete-driver !finddrv: =! /force /reboot
@IF NOT %apo% EQU 0 echo.

@IF NOT %apo% EQU 0 echo Restarting Windows Audio Service to unload Realtek Audio Effects Component...
@IF NOT %apo% EQU 0 echo.
@IF NOT %apo% EQU 0 net stop Audiosrv
@IF NOT %apo% EQU 0 echo.
@IF NOT %apo% EQU 0 net start Audiosrv
@IF NOT %apo% EQU 0 echo.
@endlocal
@echo Done uninstalling driver.
@echo.
@IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd" del "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"

:install
@set /p install=Do you want to install unofficial and minimal Realtek UAD generic package (y/n):
@echo.
@IF /I NOT "%install%"=="y" GOTO ending
@pnputil /add-driver *.inf /subdirs /reboot
@echo.
@echo Done installing driver
@echo.
@pause
@echo.

:start-driver
@for /F "tokens=2" %%a in ('date /t') do @set currdate=%%a
@(echo If Windows crashes during the initialization of Realtek UAD generic driver you may have to perform a system restore
echo to a moment before the crash. The installer included in this package enables Windows advanced startup menu
echo so that entering Safe mode to access system restore is much easier, avoiding further crashes. Advanced startup menu
echo is then disabled if installation completes sucessfully. A tool that disables advanced startup menu is included.
echo.
echo A Realtek UAD generic driver initialization failure leading to Windows crash occurred at %currdate%:%time%.)>"%~dp0recovery.txt"
@echo Windows advanced startup menu is now permanently enabled for each full boot.>>"%~dp0recovery.txt"
@echo To revert Windows startup to default mode run utility\restorewindowsnormalstartup.cmd.>>"%~dp0recovery.txt"
@echo Enabling Windows advanced startup recovery menu in case something goes very wrong...
@bcdedit /set {globalsettings} advancedoptions true
@echo.
@rem Wait 4 seconds to write recovery instructions to disk before taking the risk of starting the driver.
@ping -n 4 127.0.0.1 >nul
@devcon /rescan
@echo.
@echo Give Windows 20 seconds to load Realtek UAD driver...
@ping -n 20 127.0.0.1 >nul
@pause
@echo.
@rem If we got here then everything is OK.
@(echo If Windows crashes during the initialization of Realtek UAD generic driver you may have to perform a system restore
echo to a moment before the crash. The installer included in this package enables Windows advanced startup menu
echo so that entering Safe mode to access system restore is much easier, avoiding further crashes. Advanced startup menu
echo is then disabled if installation completes sucessfully. A tool that disables advanced startup menu is included.)>"%~dp0recovery.txt"
@echo Reverting Windows to normal startup...
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.

:checkreboot
@set ERRORLEVEL=0
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations > nul 2>&1
@IF ERRORLEVEL 1 pause&GOTO forceupdater
@echo Attention! It is necessary to restart your computer to finish driver installation. Save your work before continuing.
@echo.

@rem Seek force updater and try to run it on next logon if bundled.
@IF EXIST "%~dp0forceupdater\forceupdater.cmd" echo @call "%~dp0forceupdater\forceupdater.cmd" >"%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"

@pause
@shutdown -r -t 0
@exit

:forceupdater
@IF EXIST "%~dp0forceupdater\forceupdater.cmd" call "%~dp0forceupdater\forceupdater.cmd"

:ending
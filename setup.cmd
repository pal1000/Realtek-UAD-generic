@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
@TITLE Realtek UAD generic driver setup
@SET ERRORLEVEL=0
@REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService > nul 2>&1
@IF ERRORLEVEL 1 GOTO checkservice
@echo Removing Realtek Universal Audio Service registration record...
@REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService /f > nul 2>&1
@net stop RtkAudioUniversalService > nul 2>&1
@sc delete RtkAudioUniversalService > nul 2>&1
@echo Done.
@echo @call %0 >"%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@echo.

:checkservice
@set runningservice=0
@for /f "USEBACKQ" %%a IN (`tasklist /FI "IMAGENAME eq RtkAudUService64.exe"`) do @set /a runningservice+=1 > nul
@IF %runningservice% GTR 1 echo Attention! Active instances of Realtek Universal Audio Service are still running.
@IF %runningservice% GTR 1 echo For them to terminate all users have to log out so save your work.
@IF %runningservice% GTR 1 pause
@IF %runningservice% GTR 1 shutdown -l
@IF %runningservice% GTR 1 exit

:uninstall
@set ERRORLEVEL=0
@where /q devcon
@IF ERRORLEVEL 1 echo Windows Device console - devcon.exe is required.&pause&exit
@echo Begin uninstalling Realtek UAD driver.
@echo.
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
@set ext=0
@set service=0
@set hsa=0
@set apo=0
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Original Name" set /a drvcount+=1&set y=%%b&set y=!y:~6!&IF !y!==hdxrt.inf set core=!drvcount!
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Original Name" set /a drvcount+=1&set y=%%b&set y=!y:~6!&IF !y!==hdx_genericext_rtk.inf set ext=!drvcount!
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Original Name" set /a drvcount+=1&set y=%%b&set y=!y:~6!&IF !y!==realtekservice.inf set service=!drvcount!
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Original Name" set /a drvcount+=1&set y=%%b&set y=!y:~6!&IF !y!==realtekapo.inf set apo=!drvcount!
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Original Name" set /a drvcount+=1&set y=%%b&set y=!y:~6!&IF !y!==realtekhsa.inf set hsa=!drvcount!
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%service% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@set drvcount=0
@echo.
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%hsa% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@set drvcount=0
@echo.
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%apo% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@set drvcount=0
@echo.
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%core% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@set drvcount=0
@echo.
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%ext% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@endlocal
@echo.
@echo Done uninstalling driver
@echo.

:install
@set /p install=Do you want to install unofficial and minimal Realtek UAD generic package (y/n):
@echo.
@IF /I "%install%"=="y" pnputil /add-driver *.inf /subdirs /reboot
@IF /I "%install%"=="y" echo.
@IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd" del "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@IF /I NOT "%install%"=="y" GOTO ending
@echo Done installing driver
@echo.
@pause
@echo.

:start-driver
@for /F "tokens=2" %%a in ('date /t') do @set currdate=%%a
@(echo If Windows crashes during the initialization of Realtek UAD generic driver you may have to perform a system restore
echo to a moment before the crash. The installer included in this package enables Windows advanced startup menu
echo so that entering Safe mode to access system restore is much easier, avoiding further crashes. Advanced startup menu
echo is then disabled if installation completes sucessfully. An utility that disables advanced startup menu on demand is included.
echo.
echo A Realtek UAD generic driver initialization failure leading to Windows crash occurred at %currdate%:%time%)>"%~dp0recovery.txt"
@echo using Windows startup recovery menu. That's why we configured windows to start in this mode automatically.>>"%~dp0recovery.txt"
@echo To revert it run utility\restorewindowsnormalstartup.cmd.>>"%~dp0recovery.txt"
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
echo is then disabled if installation completes sucessfully. An utility that disables advanced startup menu on demand is included.)>"%~dp0recovery.txt"
@echo Reverting Windows to normal startup...
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.

:checkreboot
@set ERRORLEVEL=0
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations > nul 2>&1
@IF ERRORLEVEL 1 pause&exit
@echo Attention! It is necessary to restart your computer to finish driver installation. Save your work before continuing.
@echo.
@pause
@shutdown -r -t 0

:ending

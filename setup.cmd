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
@TITLE Update Realtek UAD driver
@SET ERRORLEVEL=0
@REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService > nul 2>&1
@IF ERRORLEVEL 1 GOTO uninstall
@REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService /f
@net stop RtkAudioUniversalService
@sc delete RtkAudioUniversalService
@echo.
@echo @call %0 >"%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@echo.
@echo Attention! You will now be logged out. Save your work before continuing.
@pause
@shutdown -l
@exit

:uninstall
@set ERRORLEVEL=0
@where /q devcon
@IF ERRORLEVEL 1 echo Windows Device console - devcon.exe is required.&pause&exit
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
@del "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@IF /I NOT "%install%"=="y" GOTO ending
@echo Done installing driver
@echo.
@pause
@echo.

:rescan
@echo 1>"%~dp0bluescreen.ini"
@devcon /rescan
@echo.
@echo Give Windows 20 seconds to load Realtek UAD driver...
@ping -n 20 127.0.0.1 >nul
@echo.
@pause
@echo.
@del "%~dp0bluescreen.ini"

:checkreboot
@set ERRORLEVEL=0
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations > nul 2>&1
@IF ERRORLEVEL 1 exit
@echo Attention! It is necessary to restart your computer to finish driver installation. Save your work before continuing.
@echo.
@pause
@shutdown -r -t 0

:ending

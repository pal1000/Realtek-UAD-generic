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
@REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService 2> nul
@IF ERRORLEVEL 1 GOTO uninstall
@REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService /f
@net stop RtkAudioUniversalService
@sc delete RtkAudioUniversalService
@echo.
@SchTasks /Create /SC ONLOGON /TN "RealtekUADSetup" /TR %0
@echo.
@echo Attention! You will now be logged out. Save your work before continuing.
@pause
@shutdown -l
@exit

:uninstall
@devcon /r disable =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*"
@devcon /r remove =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*"
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
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%hsa% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%apo% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%core% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@set drvcount=0
@for /F "USEBACKQ tokens=1,2 delims=:" %%a IN (`pnputil /enum-drivers`) do @IF "%%a"=="Published Name" set /a drvcount+=1&IF !drvcount!==%ext% set y=%%b&set y=!y:~5!&pnputil /delete-driver !y! /force /reboot
@endlocal
@echo.
@echo Done uninstalling driver
@echo.
@pause

:install
@pnputil /add-driver *.inf /subdirs /reboot
@echo.
@echo Done installing driver
@echo.
@pause
@devcon /rescan
@echo.
@pause
@SchTasks /Delete /TN "RealtekUADSetup" /f
@echo.

:checkreboot
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations 2> nul
@IF ERRORLEVEL 1 exit
@echo Attention! It is necessary to restart your computer to finish driver installation. Save your work before continuing.
@echo
@pause
@shutdown -r -t 0

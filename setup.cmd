@echo off
@cd /d "%~dp0"
@"%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
@if NOT '%errorlevel%' == '0' (
@powershell -Command Start-Process ""%0"" -Verb runAs 2>nul
@exit
)
:--------------------------------------
@TITLE Realtek UAD generic driver setup
@IF NOT "%SAFEBOOT_OPTION%"=="" TITLE Realtek UAD generic driver setup (safe mode recovery)
@echo Welcome to Unofficial Realtek UAD generic setup wizard.
@echo WARNING: This setup may spontaneously restart your computer so please be prepared for it.
@echo.
@pause
@cls

@echo Creating setup autostart entry...
@call modules\autostart.cmd setup

@IF NOT EXIST assets md assets
@rem Get initial Windows pending file opertions status
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations>assets\prvregdmp.txt 2>&1

@echo Begin uninstalling Realtek UAD driver...
@echo.
@IF "%SAFEBOOT_OPTION%"=="" (
@echo Stopping Windows Audio service to reduce reboot likelihood...
@echo.
@net stop Audiosrv
@echo.
@echo Done.
@echo.
)
@call modules\uadserviceremove.cmd RtkAudUService64.exe

@rem Clean Realtek UAD components from driver store.
@set ERRORLEVEL=0
@where /q devcon
@IF ERRORLEVEL 1 echo Windows Device console - devcon.exe is required.&echo.&pause&GOTO ending
@IF "%SAFEBOOT_OPTION%"=="" (
@devcon /r disable =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*"
@echo.
@devcon /r disable =MEDIA "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
)
@devcon /r remove =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*"
@echo.
@devcon /r remove =MEDIA "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
@echo Removing generic Realtek UAD components...
@echo.
@call modules\deluadcomponent.cmd hdxrt.inf
@call modules\deluadcomponent.cmd hdxrtsst.inf
@call modules\deluadcomponent.cmd hdx_genericext_rtk.inf
@call modules\deluadcomponent.cmd GenericAudioExtRT.inf
@call modules\deluadcomponent.cmd realtekservice.inf
@call modules\deluadcomponent.cmd realtekhsa.inf
@call modules\deluadcomponent.cmd realtekapo.inf
@echo Done.
@echo.

@IF EXIST oem.ini echo Removing OEM specific Realtek UAD components specified in oem.ini...
@IF EXIST oem.ini echo.
@setlocal EnableDelayedExpansion
@IF EXIST oem.ini FOR /F "tokens=*" %%a IN (oem.ini) do @(
set oemcomponent=%%a
IF /I NOT !oemcomponent:~-4!==.inf set oemcomponent=!oemcomponent!.inf
call modules\deluadcomponent.cmd !oemcomponent!
)
@endlocal
@IF EXIST oem.ini echo Done.
@IF EXIST oem.ini echo.

@IF "%SAFEBOOT_OPTION%"=="" (
@net start Audiosrv
@echo.
)
@echo Done uninstalling driver.
@echo.

@rem Install driver
@echo Removing autostart entry in case installation is rejected...
@call modules\autostart.cmd remove
@IF "%SAFEBOOT_OPTION%"=="" set /p install=Do you want to install unofficial and minimal Realtek UAD generic package (y/n):
@IF "%SAFEBOOT_OPTION%"=="" echo.
@IF NOT "%SAFEBOOT_OPTION%"=="" pause
@IF /I NOT "%install%"=="y" GOTO ending

@echo Restoring autostart entry as installation begins...
@call modules\autostart.cmd setup
@pnputil /add-driver *.inf /subdirs /reboot
@echo.
@echo Done installing driver
@echo.
@pause
@echo.

@rem Start driver
@for /F "tokens=2" %%a in ('date /t') do @set currdate=%%a
@(echo If Windows crashes during the initialization of Realtek UAD generic driver you may have to perform a system restore
echo to a moment before the crash. The installer included in this package enables Windows advanced startup menu
echo so that entering Safe mode to access system restore is much easier, avoiding further crashes. Advanced startup menu
echo is then disabled if installation completes sucessfully. A tool that disables advanced startup menu is included.
echo.
echo A Realtek UAD generic driver initialization failure leading to Windows crash occurred at %currdate%:%time%.)>recovery.txt
@echo Windows advanced startup menu is now permanently enabled for each full boot.>>recovery.txt
@echo To revert Windows startup to default mode run utility\restorewindowsnormalstartup.cmd.>>recovery.txt
@echo Enabling Windows advanced startup recovery menu in case something goes very wrong...
@bcdedit /set {globalsettings} advancedoptions true
@echo.
@rem Wait 4 seconds to write recovery instructions to disk before taking the risk of starting the driver.
@CHOICE /N /T 4 /C y /D y >nul 2>&1
@devcon /rescan
@echo.
@echo Give Windows 20 seconds to load Realtek UAD driver...
@CHOICE /N /T 20 /C y /D y >nul 2>&1
@pause
@echo.
@rem If we got here then everything is OK.
@(echo If Windows crashes during the initialization of Realtek UAD generic driver you may have to perform a system restore
echo to a moment before the crash. The installer included in this package enables Windows advanced startup menu
echo so that entering Safe mode to access system restore is much easier, avoiding further crashes. Advanced startup menu
echo is then disabled if installation completes sucessfully. A tool that disables advanced startup menu is included.)>recovery.txt
@echo Reverting Windows to normal startup...
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.
@IF EXIST forceupdater\forceupdater.cmd echo Creating force updater autostart entry...
@IF EXIST forceupdater\forceupdater.cmd call modules\autostart.cmd forceupdater

@rem Check if reboot is required
@rem Get final Windows pending file opertions status
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations>assets\postregdmp.txt 2>&1
@FC /B assets\prvregdmp.txt assets\postregdmp.txt>NUL&&GOTO forceupdater
@IF EXIST assets RD /S /Q assets
@echo Attention! It is necessary to restart your computer to finish driver installation. Save your work before continuing.
@echo.
@pause
@shutdown -r -t 0
@exit

:forceupdater
@IF EXIST assets RD /S /Q assets
@pause
@IF EXIST forceupdater\forceupdater.cmd call forceupdater\forceupdater.cmd

:ending
@IF EXIST assets RD /S /Q assets
@call modules\autostart.cmd remove >nul 2>&1
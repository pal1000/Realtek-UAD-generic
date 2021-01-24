@echo off
@cd /d "%~dp0"
@set "ERRORLEVEL="
@CMD /C EXIT 0
@"%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
@if NOT "%ERRORLEVEL%"=="0" (
@powershell -Command Start-Process """%0""" -Verb runAs 2>nul
@exit
)
:--------------------------------------
@TITLE Realtek UAD generic driver setup
@IF NOT "%SAFEBOOT_OPTION%"=="" TITLE Realtek UAD generic driver setup (safe mode recovery)

@rem Just wipe autostart entry if force updater reboots Windows to normal mode when enabling sound card.
@IF "%SAFEBOOT_OPTION%"=="" IF EXIST assets\setupdone.ini (
@echo Installation completed successfully.
@echo.
@echo Reverting Windows to normal startup...
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.
@pause
@GOTO ending
)

@echo Welcome to Unofficial Realtek UAD generic setup wizard.
@echo WARNING: This setup may spontaneously restart your computer so please be prepared for it.
@echo.
@echo If Windows crashes (BSOD/GSOD), please boot into safe mode as soon as possible.
@echo Don't use Safe Mode with Command Prompt as it doesn't load shell which setup relies on to autostart even in Safe mode.
@echo Setup makes going into safe mode very easy and it will autostart to restore system stability.
@echo.
@pause
@echo.
@IF NOT EXIST assets md assets

@echo Enabling Windows script host...
@CMD /C EXIT 0
@REG QUERY "HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings" /v "Enabled" /t REG_DWORD >nul 2>&1
@IF "%ERRORLEVEL%"=="0" REG DELETE "HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings" /v "Enabled" /f
@echo.

@rem Prompt to skip to force updater
@IF EXIST forceupdater\forceupdater.cmd IF EXIST Win64\Realtek\UpdatedCodec IF "%SAFEBOOT_OPTION%"=="" set /p forceupdateonly=For advanced users: Do you want to manage yourself, updates of codec, extension and software components (HSA, APO, Service) - y/n, default=n:
@IF EXIST forceupdater\forceupdater.cmd IF EXIST Win64\Realtek\UpdatedCodec IF "%SAFEBOOT_OPTION%"=="" echo.
@IF /I "%forceupdateonly%"=="y" call forceupdater\forceupdater.cmd
@IF /I "%forceupdateonly%"=="y" GOTO ending
@IF /I NOT "%forceupdateonly%"=="y" cls

@echo Creating setup autostart entry...
@call modules\autostart.cmd setup

@rem Get initial Windows pending file operations status
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations>assets\prvregdmp.txt 2>&1

@echo Begin uninstalling Realtek UAD driver...
@echo.
@IF "%SAFEBOOT_OPTION%"=="" (
@echo Stopping Windows Audio service to reduce reboot likelihood...
@echo.
@net stop Audiosrv /y
@echo.
@echo Done.
@echo.
)
@call modules\uadserviceremove.cmd RtkAudUService64.exe

@rem Clean Realtek UAD components from driver store.
@CMD /C EXIT 0
@where /q devcon
@if NOT "%ERRORLEVEL%"=="0" echo Windows Device console - devcon.exe is required.&echo.&pause&GOTO ending
@IF "%SAFEBOOT_OPTION%"=="" (
@devcon /r disable =SoftwareComponent "SWC\VEN_10EC&AID_0001"
@echo.
)
@devcon /r remove =SoftwareComponent "SWC\VEN_10EC&AID_0001"
@echo.
@IF "%SAFEBOOT_OPTION%"=="" (
@devcon /r disable =SoftwareComponent "SWC\VEN_10EC&HID_0001"
@echo.
)
@devcon /r remove =SoftwareComponent "SWC\VEN_10EC&HID_0001"
@echo.
@IF "%SAFEBOOT_OPTION%"=="" (
@devcon /r disable =SoftwareComponent "SWC\VEN_10EC&SID_0001"
@echo.
)
@devcon /r remove =SoftwareComponent "SWC\VEN_10EC&SID_0001"
@echo.
@IF "%SAFEBOOT_OPTION%"=="" (
@devcon /r disable =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*" "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
)
@devcon /r remove =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*" "INTELAUDIO\FUNC_01&VEN_10EC*"
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
@IF EXIST oem.ini FOR /F tokens^=^*^ eol^= %%a IN (oem.ini) do @(
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
@IF NOT "%SAFEBOOT_OPTION%"=="" IF EXIST assets\mainsetupsystemcrash.ini (
@echo WARNING: Windows crashed during the main setup driver initialization phase.
@echo UAD driver installation is canceled.
@echo.
@pause
@GOTO ending
)
@set /p install=Do you want to install unofficial and minimal Realtek UAD generic package (y/n):
@echo.
@IF /I NOT "%install%"=="y" GOTO ending

@echo Restoring autostart entry as installation begins...
@call modules\autostart.cmd setup
@pnputil /add-driver *.inf /subdirs /reboot
@echo.
@echo Done installing driver
@echo.
@pause
@echo.

@rem Start driver (this doesn't run in safe mode)
@IF "%SAFEBOOT_OPTION%"=="" (
@echo Enabling Windows advanced startup recovery menu in case something goes very wrong...
@bcdedit /set {globalsettings} advancedoptions true
@echo.
@echo 1>assets\mainsetupsystemcrash.ini
@rem Wait 1 second to write crash stamp to disk before taking the risk of starting the driver.
@CHOICE /N /T 1 /C y /D y >nul 2>&1
@devcon /rescan
@echo.
@echo Give Windows 20 seconds to load Realtek UAD driver...
@CHOICE /N /T 20 /C y /D y >nul 2>&1
@pause
@echo.
@rem If we got here then everything is OK.
@echo Reverting Windows to normal startup...
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.
@del assets\mainsetupsystemcrash.ini
@rem Force updater doesn't run in safe mode
@IF EXIST forceupdater\forceupdater.cmd IF EXIST Win64\Realtek\UpdatedCodec echo Creating force updater autostart entry...
@IF EXIST forceupdater\forceupdater.cmd IF EXIST Win64\Realtek\UpdatedCodec call modules\autostart.cmd forceupdater
)

@IF EXIST forceupdater\forceupdater.cmd IF EXIST Win64\Realtek\UpdatedCodec IF NOT "%SAFEBOOT_OPTION%"=="" (
@echo WARNING: You are in safe mode. Force updater won't run to update driver beyond latest WHQL generic base.
@echo.
)

@rem Check if reboot is required
@rem Get final Windows pending file operations status
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations>assets\postregdmp.txt 2>&1
@FC /B assets\prvregdmp.txt assets\postregdmp.txt>NUL&&GOTO forceupdater
@IF EXIST assets\prvregdmp.txt del assets\prvregdmp.txt
@IF EXIST assets\postregdmp.txt del assets\postregdmp.txt
@echo Attention! It is necessary to restart your computer to finish driver installation. Save your work before continuing.
@echo.
@pause
@shutdown -r -t 0
@exit

:forceupdater
@IF EXIST assets\prvregdmp.txt del assets\prvregdmp.txt
@IF EXIST assets\postregdmp.txt del assets\postregdmp.txt
@pause
@rem Force updater doesn't run in safe mode
@IF EXIST forceupdater\forceupdater.cmd IF EXIST Win64\Realtek\UpdatedCodec IF "%SAFEBOOT_OPTION%"=="" call forceupdater\forceupdater.cmd

:ending
@call modules\autostart.cmd remove >nul 2>&1
@IF EXIST assets RD /S /Q assets

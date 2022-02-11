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
@rem Title and main page
@TITLE Realtek UAD generic driver force updater
@cls
@cd ..

@rem Disable force updater if no UpdatedCodec folder is found in Win64\Realtek and while on the title screen
@call modules\autostart.cmd remove
@IF NOT EXIST Win64\Realtek\UpdatedCodec echo Force updater is retired for now until is needed again.
@IF NOT EXIST Win64\Realtek\UpdatedCodec echo.
@IF NOT EXIST Win64\Realtek\UpdatedCodec pause
@IF NOT EXIST Win64\Realtek\UpdatedCodec exit

@echo This tool will attempt to forcefully update Realtek UAD generic driver codec core component by replacing
@echo older driver files with a newer version. It is intended to run only after performing a driver update with the main setup.
@echo WARNING: This tool may spontaneously restart your computer so please be prepared for it.
@echo.
@echo If Windows crashes (BSOD/GSOD), please boot into safe mode as soon as possible.
@echo Don't use Safe Mode with Command Prompt as it doesn't load the shell which is required to autostart even in Safe mode.
@echo Force updater makes going into safe mode very easy
@echo and it can restart the main setup from scratch to restore system stability.
@echo.
@pause
@call modules\autostart.cmd forceupdater
@cls

@rem Replace old driver
@CMD /C EXIT 0
@where /q devcon.exe
@if NOT "%ERRORLEVEL%"=="0" echo Windows Device console - devcon.exe is required.&pause&exit
@CMD /C EXIT 0
@where /q nircmd.exe
@if NOT "%ERRORLEVEL%"=="0" echo NirSoft CMD is required.&pause&exit
@CMD /C EXIT 0
@where /q nircmdc.exe
@if NOT "%ERRORLEVEL%"=="0" echo NirSoft CMD is required.&pause&exit
@echo Stopping Windows Audio service to reduce reboot likelihood...
@echo.
@net stop Audiosrv /y
@echo.
@echo Done.
@echo.
@echo Begin force update procedure...
@echo.
@devcon /r disable =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*" "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
@echo Copying files...
@set advrunworkdir=%~dp0
@IF %advrunworkdir:~0,1%%advrunworkdir:~-1%=="" set advrunworkdir=%advrunworkdir:~1,-1%
@IF "%advrunworkdir:~-1%"=="\" set advrunworkdir=%advrunworkdir:~0,-1%
@set advrunworkdir=%advrunworkdir:~0,-13%
@rem AdvancedRun.exe /WaitProcess 1 /EXEFilename "%windir%\System32\cmd.exe" /CommandLine "/C forceupdater\defeatpnplock.cmd" /StartDirectory "%advrunworkdir%" /RunAs 4
@nircmd.exe elevatecmd runassystem %windir%\System32\cmd.exe /c "%advrunworkdir%\forceupdater\defeatpnplock.cmd"
@pause
@echo.
@IF EXIST patches\*.* echo Applying registry patch...
@IF EXIST patches\*.* echo.
@IF EXIST patches\*.* call forceupdater\regedit.cmd
@IF EXIST patches\*.* echo.
@IF EXIST patches\*.* echo Done.
@IF EXIST patches\*.* echo.

@rem Prepare for a potential restart or crash when starting force updated driver
@echo Creating setup autostart entry to either start over or finish setup on reboot if necessary...
@call modules\autostart.cmd setup
@echo Enabling Windows advanced startup recovery menu in case something goes very wrong...
@bcdedit /set {globalsettings} advancedoptions true
@echo.
@rem Create a flag for the main setup to do a post-install cleanup if Windows reboots normally here
@echo 1>assets\setupdone.ini
@rem Wait 1 second to write setup configuration to disk before taking the risk of starting the driver.
@CHOICE /N /T 1 /C y /D y >nul 2>&1

@rem Start updated driver
@echo.
@net start Audiosrv
@echo.
@devcon /r enable =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*" "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
@echo Give Windows 10 seconds to load Realtek UAD driver...
@CHOICE /N /T 10 /C y /D y >nul 2>&1
@pause
@echo.
@rem If we got here then everything is OK.
@del assets\setupdone.ini
@echo Reverting Windows to normal startup...
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.
@echo Removing autostart entry...
@call modules\autostart.cmd remove
@pause

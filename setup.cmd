@echo off

:: BatchGotAdmin
:-------------------------------------
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto RestoreCD ) else ( goto getPrivileges )

:getPrivileges
powershell -Command Start-Process ""%0"" -Verb runAs 2>nul
exit

:RestoreCD
cd /d "%~dp0"
:--------------------------------------
@TITLE Realtek UAD generic driver setup

@echo Welcome to Unofficial Realtek UAD generic setup wizard.
@echo WARNING: This setup may spontaneously restart your computer so please be prepared for it.
@echo.
@pause
@cls

@IF NOT EXIST assets md assets
@rem Get initial Windows pending file opertions status
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations>assets\prvregdmp.txt 2>&1

@echo Begin uninstalling Realtek UAD driver...
@echo.
@echo Stopping Windows Audio service to reduce reboot likelihood...
@echo.
@net stop Audiosrv
@echo.
@echo Done.
@echo.
@echo Removing Realtek Audio Universal Service...
@echo.
@For /f "tokens=*" %%a in ('CScript //nologo "modules\uadserviceusermode.vbs"') do @(
REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v "%%a" /f
echo.
)

@rem Reduce performance penalty of misbehaving security products on vbscript by caching and reusing execution results.
@IF EXIST assets\uadservices.txt del assets\uadservices.txt
@For /f "tokens=*" %%a in ('CScript //nologo "modules\finduadservices.vbs"') do @echo %%a>>assets\uadservices.txt
@IF EXIST assets\uadservices.txt For /f "tokens=*" %%a in (assets\uadservices.txt) do @(
net stop "%%a"
echo.
)
@taskkill /f /im RtkAudUService64.exe
@echo.
@set runningservice=0
@for /f "USEBACKQ tokens=1 delims= " %%a IN (`tasklist /FI "IMAGENAME eq RtkAudUService64.exe" 2^>^&1`) do @IF %%a==RtkAudUService64.exe set /a runningservice+=1
@IF %runningservice% GTR 0 For /f "tokens=*" %%a in (assets\uadservices.txt) do @(
taskkill /FI "Services eq %%a" /F
echo.
)
@IF %runningservice% GTR 0 echo WARNING: Realtek Audio Universal Service did not properly shutdown.
@IF %runningservice% GTR 0 echo.
@IF EXIST assets\uadservices.txt For /f "tokens=*" %%a in (assets\uadservices.txt) do @(
sc delete "%%a"
echo.
)
@echo Done.
@echo.

@rem Clean Realtek UAD components from driver store.
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

@net start Audiosrv
@echo.
@echo Done uninstalling driver.
@echo.
@IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd" del "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"

@rem Install driver
@set /p install=Do you want to install unofficial and minimal Realtek UAD generic package (y/n):
@echo.
@IF /I NOT "%install%"=="y" GOTO ending
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
echo A Realtek UAD generic driver initialization failure leading to Windows crash occurred at %currdate%:%time%.)>"%~dp0recovery.txt"
@echo Windows advanced startup menu is now permanently enabled for each full boot.>>"%~dp0recovery.txt"
@echo To revert Windows startup to default mode run utility\restorewindowsnormalstartup.cmd.>>"%~dp0recovery.txt"
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
echo is then disabled if installation completes sucessfully. A tool that disables advanced startup menu is included.)>"%~dp0recovery.txt"
@echo Reverting Windows to normal startup...
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.

@rem Check if reboot is required
@rem Get final Windows pending file opertions status
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations>assets\postregdmp.txt 2>&1
@FC /B assets\prvregdmp.txt assets\postregdmp.txt>NUL&&GOTO forceupdater
@IF EXIST assets RD /S /Q assets
@echo Attention! It is necessary to restart your computer to finish driver installation. Save your work before continuing.
@echo.

@rem Seek force updater and try to run it on next logon if bundled.
@IF EXIST "%~dp0forceupdater\forceupdater.cmd" echo @call "%~dp0forceupdater\forceupdater.cmd" >"%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@pause
@shutdown -r -t 0
@exit

:forceupdater
@IF EXIST assets RD /S /Q assets
@pause
@IF EXIST "%~dp0forceupdater\forceupdater.cmd" call "%~dp0forceupdater\forceupdater.cmd"

:ending
@IF EXIST assets RD /S /Q assets
@echo off

:: BatchGotAdmin
:-------------------------------------
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto RestoreCD ) else ( goto getPrivileges )

:getPrivileges
powershell -Command Start-Process "%0" -Verb runAs 2>nul
exit

:RestoreCD
cd /d "%~dp0"
:--------------------------------------
@TITLE Realtek UAD generic driver setup
@rem Get initial Windows pending file opertions status
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations>tmpFile 2>&1

@echo Begin uninstalling Realtek UAD driver...
@echo.
@echo Stopping Windows Audio service to reduce reboot likelihood...
@echo.
@net stop Audiosrv > nul 2>&1
@echo Done.
@echo.
@echo Removing Realtek Audio Universal Service registration record...
@echo.
@REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RtkAudUService /f > nul 2>&1
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
@IF EXIST oem.ini FOR /F "USEBACKQ tokens=*" %%a IN (`type oem.ini`) do @(
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
@rem Get final Windows pending file opertions status
@REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations>tmpFile2 2>&1
@FC /B tmpFile tmpFile2>NUL&&GOTO forceupdater
@echo Attention! It is necessary to restart your computer to finish driver installation. Save your work before continuing.
@echo.

@rem Seek force updater and try to run it on next logon if bundled.
@IF EXIST "%~dp0forceupdater\forceupdater.cmd" echo @call "%~dp0forceupdater\forceupdater.cmd" >"%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@pause
@shutdown -r -t 0
@exit

:forceupdater
@pause
@IF EXIST "%~dp0forceupdater\forceupdater.cmd" call "%~dp0forceupdater\forceupdater.cmd"

:ending
@del tmpFile
@del tmpFile2
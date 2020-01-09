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
@rem Title and main page
@TITLE Realtek UAD generic driver force updater
@cls
@cd ..

@rem Disable force updater if no UpdatedCodec folder is found in Win64\Realtek
@IF NOT EXIST Win64\Realtek\UpdatedCodec IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd" del "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@IF NOT EXIST Win64\Realtek\UpdatedCodec echo Force updater is retired for now until is needed again.
@IF NOT EXIST Win64\Realtek\UpdatedCodec echo.
@IF NOT EXIST Win64\Realtek\UpdatedCodec pause
@IF NOT EXIST Win64\Realtek\UpdatedCodec IF EXIST tmpFile del tmpFile
@IF NOT EXIST Win64\Realtek\UpdatedCodec IF EXIST tmpFile2 del tmpFile2
@IF NOT EXIST Win64\Realtek\UpdatedCodec exit

@echo This tool will attempt to forcefully update Realtek UAD generic driver codec core component by replacing
@echo older driver files with newer version. It is intended to run only after performing a driver update with main setup.
@echo This tool may spontaneously restart your computer so please be prepared for it.
@echo.
@pause
@cls

@rem Replace old driver
@set ERRORLEVEL=0
@where /q devcon
@IF ERRORLEVEL 1 echo Windows Device console - devcon.exe is required.&pause&exit
@echo Stopping Windows Audio service to reduce reboot likelihood...
@echo.
@net stop Audiosrv > nul 2>&1
@echo Done.
@echo.
@echo Begin force update procedure...
@echo.
@devcon /r disable =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*"
@echo.
@devcon /r disable =MEDIA "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
@copy /y Win64\Realtek\UpdatedCodec\*.* "%windir%\System32\drivers"
@echo.
@IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd" del "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"

@rem Prepare for a potential crash
@for /F "tokens=2" %%a in ('date /t') do @set currdate=%%a
@(echo If Windows crashes during the initialization of Realtek UAD generic driver you may have to perform a system restore
echo to a moment before the crash. The installer included in this package enables Windows advanced startup menu
echo so that entering Safe mode to access system restore is much easier, avoiding further crashes. Advanced startup menu
echo is then disabled if installation completes sucessfully. A tool that disables advanced startup menu is included.
echo.
echo A Realtek UAD generic driver initialization failure leading to Windows crash occurred at %currdate%:%time%.)>"%cd%\recovery.txt"
@echo Windows advanced startup menu is now permanently enabled for each full boot.>>"%cd%\recovery.txt"
@echo To revert Windows startup to default mode run utility\restorewindowsnormalstartup.cmd.>>"%cd%\recovery.txt"
@echo Enabling Windows advanced startup recovery menu in case something goes very wrong...
@bcdedit /set {globalsettings} advancedoptions true
@echo.
@rem Wait 4 seconds to write recovery instructions to disk before taking the risk of starting the driver.
@CHOICE /N /T 4 /D y >nul 2>&1

@rem Start updated driver
@echo.
@net start Audiosrv
@echo.
@devcon /r enable =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*"
@echo.
@devcon /r enable =MEDIA "INTELAUDIO\FUNC_01&VEN_10EC*"
@echo.
@echo Give Windows 10 seconds to load Realtek UAD driver...
@CHOICE /N /T 10 /D y >nul 2>&1
@pause
@echo.
@rem If we got here then everything is OK.
@(echo If Windows crashes during the initialization of Realtek UAD generic driver you may have to perform a system restore
echo to a moment before the crash. The installer included in this package enables Windows advanced startup menu
echo so that entering Safe mode to access system restore is much easier, avoiding further crashes. Advanced startup menu
echo is then disabled if installation completes sucessfully. A tool that disables advanced startup menu is included.)>"%cd%\recovery.txt"
@echo Reverting Windows to normal startup...
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.
@pause
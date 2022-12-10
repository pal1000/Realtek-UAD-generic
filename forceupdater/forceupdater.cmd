@rem Title and main page
@TITLE Realtek UAD generic driver force updater
@cls

@rem Disable force updater if no UpdatedCodec folder is found in Win64\Realtek and while on the title screen
@IF NOT EXIST Win64\Realtek\UpdatedCodec echo Force updater is retired for now until is needed again.
@IF NOT EXIST Win64\Realtek\UpdatedCodec echo.
@IF NOT EXIST Win64\Realtek\UpdatedCodec pause
@IF NOT EXIST Win64\Realtek\UpdatedCodec exit

@echo This tool will attempt to forcefully update Realtek UAD generic driver codec core component by replacing
@echo older driver files with a newer version. It is intended to run only after performing a driver update with the main setup.
@echo.
@pause
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
@echo Begin force update procedure...
@echo.
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
@rem IF EXIST patches\*.* call forceupdater\regedit.cmd
@rem IF EXIST patches\*.* echo.
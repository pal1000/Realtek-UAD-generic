@rem Get main setup folder path
@set autostart="%~f0"
@set autostart=%autostart:~1,-23%

@rem Generate autostart commands
@IF %1==setup IF EXIST beta.ini REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "explorer.exe,cmd /C call \"%autostart%\setup.cmd\"" /f
@IF %1==forceupdater IF EXIST beta.ini REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "explorer.exe,cmd /C call \"%autostart%\forceupdater\forceupdater.cmd\"" /f
@IF %1==remove IF EXIST beta.ini REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "explorer.exe" /f

@IF %1==setup IF NOT EXIST beta.ini echo @call "%autostart%\setup.cmd" >"%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@IF %1==forceupdater IF NOT EXIST beta.ini echo @call "%autostart%\forceupdater\forceupdater.cmd" >"%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"
@IF %1==remove IF NOT EXIST beta.ini IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd" del "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp\uadsetup.cmd"

@IF NOT EXIST beta.ini echo Done.
@echo.
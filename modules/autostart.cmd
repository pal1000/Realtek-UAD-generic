@rem Get main setup folder path
@set autostart="%~f0"
@set autostart=%autostart:~1,-23%

@rem Get original shell command
@IF NOT EXIST assets\origshell.reg REG EXPORT "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" assets\origshell.reg >nul
@set exitloop=1
@For /f tokens^=1^,2^*^ delims^=^=^ eol^= %%a in ('Find /v "" assets\origshell.reg') do @IF defined exitloop IF /I %%a=="Shell" (@set "exitloop="&set origshell=%%b)

@rem Generate autostart commands
@IF %1==setup REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "%origshell:~1,-1%,cmd /C call \"%autostart%\setup.cmd\"" /f
@IF %1==forceupdater REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "%origshell:~1,-1%,cmd /C call \"%autostart%\forceupdater\forceupdater.cmd\"" /f
@IF %1==remove REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "%origshell:~1,-1%" /f
@echo.
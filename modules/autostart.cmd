@rem Get main setup folder path
@set autostart="%~f0"
@set autostart=%autostart:~1,-23%

@rem Get original shell command
@IF NOT EXIST assets\origshell.txt For /f tokens^=^*^ eol^= %%a in ('CScript //nologo "modules\getshell.vbs"') do @(
set origshell="%%a"
echo "%%a">assets\origshell.txt
)
@IF NOT defined origshell For /f tokens^=^*^ eol^= %%a in ('Find /v "" assets\origshell.txt') do @set origshell=%%a

@rem Generate autostart commands
@IF %1==setup REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "%origshell:~1,-1%,cmd /C call \"%autostart%\setup.cmd\"" /f
@IF %1==forceupdater REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "%origshell:~1,-1%,cmd /C call \"%autostart%\forceupdater\forceupdater.cmd\"" /f
@IF %1==remove REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "%origshell:~1,-1%" /f
@echo.
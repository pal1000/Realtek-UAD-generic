@setlocal EnableDelayedExpansion
@rem Get main setup folder path
@set autostart="%~f0"
@set autostart=%autostart:~1,-23%

@rem Get original shell command
@set origshell=
@For /f tokens^=1^-26^ delims^=^,^ eol^= %%a in ('CScript //nologo "modules\getshell.vbs"') do @(
@IF NOT "%%a"=="" echo "%%a" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%a,
@IF NOT "%%b"=="" echo "%%b" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%b,
@IF NOT "%%c"=="" echo "%%c" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%c,
@IF NOT "%%d"=="" echo "%%d" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%d,
@IF NOT "%%e"=="" echo "%%e" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%e,
@IF NOT "%%f"=="" echo "%%f" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%f,
@IF NOT "%%g"=="" echo "%%g" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%g,
@IF NOT "%%h"=="" echo "%%h" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%h,
@IF NOT "%%i"=="" echo "%%i" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%i,
@IF NOT "%%j"=="" echo "%%j" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%j,
@IF NOT "%%k"=="" echo "%%k" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%k,
@IF NOT "%%l"=="" echo "%%l" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%l,
@IF NOT "%%m"=="" echo "%%m" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%m,
@IF NOT "%%n"=="" echo "%%n" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%n,
@IF NOT "%%o"=="" echo "%%o" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%o,
@IF NOT "%%p"=="" echo "%%p" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%p,
@IF NOT "%%q"=="" echo "%%q" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%q,
@IF NOT "%%r"=="" echo "%%r" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%r,
@IF NOT "%%s"=="" echo "%%s" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%s,
@IF NOT "%%t"=="" echo "%%t" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%t,
@IF NOT "%%u"=="" echo "%%u" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%u,
@IF NOT "%%v"=="" echo "%%v" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%v,
@IF NOT "%%w"=="" echo "%%w" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%w,
@IF NOT "%%x"=="" echo "%%x" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%x,
@IF NOT "%%y"=="" echo "%%y" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%y,
@IF NOT "%%z"=="" echo "%%z" | find /v /i "Realtek-UAD-generic\setup.cmd" | find /v /i "Realtek-UAD-generic\forceupdater\forceupdater.cmd">nul 2>&1 && set origshell=!origshell!%%z,
)
@if "%origshell:~-1%"=="," set origshell=%origshell:~0,-1%

@rem Generate autostart commands
@IF %1==setup REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "%origshell%,cmd /C call \"%autostart%\setup.cmd\"" /f
@IF %1==remove REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /t REG_SZ /v Shell /d "%origshell%" /f
@echo.
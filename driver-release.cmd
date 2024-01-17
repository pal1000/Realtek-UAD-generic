@set fatal_error=0
@set exclude=-x^!.git -x^!RTKUWP -x^!VCLibs_UWP_Preview -x^!.gitattributes -x^!.gitignore -x^!"%~nx0"
@CD /d "%~dp0"
@echo ---------------------------------
@echo Realtek UAD generic release maker
@echo ---------------------------------
@echo.

@setlocal
@set patchescounter=0
@if EXIST "patches\" for /f delims^=^ eol^= %%a IN ('dir /B /S patches^\ 2^>nul') DO @set /a patchescounter+=1
@if EXIST "patches\" IF %patchescounter% EQU 0 set exclude=%exclude% -x^!patches
@endlocal&set exclude=%exclude%

@setlocal
@echo Checking force updater agent availability...
@set nircmd_warn=0
@CMD /C EXIT 0
@where /q nircmd.exe
@if NOT "%ERRORLEVEL%"=="0" set nircmd_warn=1
@CMD /C EXIT 0
@where /q nircmdc.exe
@if NOT "%ERRORLEVEL%"=="0" set nircmd_warn=1
@IF %nircmd_warn% EQU 1 echo WARNING^: Force updater requires NirCMD tool from Nirsoft. Extract it in same folder as driver-release.cmd.
@IF %nircmd_warn% EQU 1 set exclude=%exclude% -x^!forceupdater
@IF %nircmd_warn% EQU 0 echo OK.
@echo.
@endlocal&set exclude=%exclude%

@setlocal
@echo Checking Device Manager commandline tool availability...
@CMD /C EXIT 0
@where /q devcon.exe
@if NOT "%ERRORLEVEL%"=="0" (
@echo FATAL ERROR^: Device Manager commandline tool is missing. You can obtain it by installing Windows driver kit then copying devcon.exe from %ProgramFiles% ^(x86^)^\Windows Kits^\10^\Tools^\^<version^>^\x64 to same folder as driver-release.cmd.
@set fatal_error=1
)
@if %fatal_error% EQU 0 echo OK.
@echo.
@endlocal&set fatal_error=%fatal_error%

@setlocal
@echo Checking 7-zip compressor availability...
@set sevenzip=7z.exe
@CMD /C EXIT 0
@where /q 7z.exe
@if NOT "%ERRORLEVEL%"=="0" set sevenzip="%ProgramFiles%\7-Zip\7z.exe"
@if NOT %sevenzip%==7z.exe if NOT EXIST %sevenzip% set sevenzip="%ProgramW6432%\7-Zip\7z.exe"
@if NOT %sevenzip%==7z.exe if NOT EXIST %sevenzip% set sevenzip="%ProgramFiles(x86)%\7-Zip\7z.exe"
@if NOT %sevenzip%==7z.exe if NOT EXIST %sevenzip% echo FATAL ERROR^: 7-Zip is not installed.
@if NOT %sevenzip%==7z.exe if NOT EXIST %sevenzip% set fatal_error=1
@if %sevenzip%==7z.exe echo OK.
@if NOT %sevenzip%==7z.exe if EXIST %sevenzip% echo OK.
@echo.
@endlocal&set fatal_error=%fatal_error%&set sevenzip=%sevenzip%

@setlocal
@echo Checking driver integrity, this may take a while...
@set no_drv=0
@set drvcheck=0
@for /f delims^=^ eol^= %%a IN ('dir /B /S HDXRT.inf 2^>nul') DO @set /a drvcheck+=1
@IF %drvcheck% EQU 0 set no_drv=1
@set drvcheck=0
@for /f delims^=^ eol^= %%a IN ('dir /B /S HDXRTSST.inf 2^>nul') DO @set /a drvcheck+=1
@IF %drvcheck% EQU 0 set no_drv=1
@set drvcheck=0
@for /f delims^=^ eol^= %%a IN ('dir /B /S HDX_GenericExt_RTK.inf 2^>nul') DO @set /a drvcheck+=1
@IF %drvcheck% EQU 0 set no_drv=1
@set drvcheck=0
@for /f delims^=^ eol^= %%a IN ('dir /B /S RealtekAPO.inf 2^>nul') DO @set /a drvcheck+=1
@IF %drvcheck% EQU 0 set no_drv=1
@set drvcheck=0
@for /f delims^=^ eol^= %%a IN ('dir /B /S RealtekHSA.inf 2^>nul') DO @set /a drvcheck+=1
@IF %drvcheck% EQU 0 set no_drv=1
@set drvcheck=0
@for /f delims^=^ eol^= %%a IN ('dir /B /S RealtekService.inf 2^>nul') DO @set /a drvcheck+=1
@IF %drvcheck% EQU 0 set no_drv=1
@IF %no_drv% EQU 1 echo FATAL ERROR^: Realtek UAD generic driver integrity check failed.
@IF %no_drv% EQU 1 set fatal_error=1
@IF %no_drv% EQU 0 echo OK.
@echo.
@endlocal&set fatal_error=%fatal_error%

@IF %fatal_error% EQU 1 GOTO finish

@set /p drvver=Enter driverr version:
@echo.
@echo Starting driver release maker...
@%sevenzip% a ..\Unofficial-Realtek-UAD-generic-%drvver%.7z "%~dp0" -r %exclude% -m0=LZMA2 -mmt=on -mx=9
@echo.

:finish
@pause
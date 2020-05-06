@echo off
@cd /d "%~dp0"
@set "ERRORLEVEL="
@CMD /C EXIT 0
@"%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
@if NOT "%ERRORLEVEL%"=="0" (
@powershell -Command Start-Process ""%0"" -Verb runAs 2>nul
@exit
)
:--------------------------------------
@TITLE Restore Windows to normal startup
@echo Reverting Windows to normal startup...
@echo.
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.
@pause
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
@TITLE Restore Windows to normal startup
@echo Reverting Windows to normal startup...
@echo.
@bcdedit /deletevalue {globalsettings} advancedoptions
@echo.
@pause
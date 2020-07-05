@echo off
@set "ERRORLEVEL="
@CMD /C EXIT 0
@"%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
@if NOT "%ERRORLEVEL%"=="0" (
@powershell -Command Start-Process ""%0"" -Verb runAs 2>nul
@exit
)
:--------------------------------------
@set blockhdaud=0
@set blockintaud=0
@echo Enabling drivers download via Windows update...

@CMD /C EXIT 0
@REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs /d /e /f HDAUDIO^\FUNC_01^&VEN_10EC >nul 2>&1
@if "%ERRORLEVEL%"=="0" set blockhdaud=1

@CMD /C EXIT 0
@REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs /d /e /f INTELAUDIO^\FUNC_01^&VEN_10EC >nul 2>&1
@if "%ERRORLEVEL%"=="0" set blockintaud=1

@if %blockhdaud% EQU 1 set exitloop=1
@if %blockhdaud% EQU 1 FOR /F "tokens=1 skip=2 USEBACKQ" %%a IN (`REG QUERY HKEY_LOCAL_MACHINE^\SOFTWARE^\Policies^\Microsoft^\Windows^\DeviceInstall^\Restrictions^\DenyDeviceIDs /d /e /f HDAUDIO^^^\FUNC_01^^^&VEN_10EC 2^>^&1`) do @IF defined exitloop (
set "exitloop="
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs /v %%a /f
)

@if %blockintaud% EQU 1 set exitloop=1
@if %blockintaud% EQU 1 FOR /F "tokens=1 skip=2 USEBACKQ" %%a IN (`REG QUERY HKEY_LOCAL_MACHINE^\SOFTWARE^\Policies^\Microsoft^\Windows^\DeviceInstall^\Restrictions^\DenyDeviceIDs /d /e /f INTELAUDIO^^^\FUNC_01^^^&VEN_10EC 2^>^&1`) do @IF defined exitloop (
set "exitloop="
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs /v %%a /f
)

@echo Done.
@pause
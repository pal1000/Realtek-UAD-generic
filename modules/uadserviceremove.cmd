@echo Removing Audio Universal Service - %1...
@echo.
@For /f tokens^=^*^ eol^= %%a in ('CScript //nologo "modules\uadserviceusermode.vbs" %1') do @(
REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v "%%a" /f
echo.
)

@rem Reduce the performance penalty of misbehaving security products on VBScript by caching and reusing execution results.
@IF EXIST assets\uadservices.txt del assets\uadservices.txt
@For /f tokens^=^*^ eol^= %%a in ('CScript //nologo "modules\finduadservices.vbs" %1') do @echo %%a>>assets\uadservices.txt
@IF EXIST assets\uadservices.txt IF "%SAFEBOOT_OPTION%"=="" For /f tokens^=^*^ eol^= %%a in (assets\uadservices.txt) do @(
net stop "%%a" /y
echo.
)
@IF "%SAFEBOOT_OPTION%"=="" (
@taskkill /f /im %1
@echo.
)
@set runningservice=0
@IF "%SAFEBOOT_OPTION%"=="" for /f tokens^=1^ delims^=^ ^ eol^= %%a IN ('tasklist /FI "IMAGENAME eq %1" 2^>^&1') do @IF %%a==%1 set /a runningservice+=1
@IF %runningservice% GTR 0 For /f tokens^=^*^ eol^= %%a in (assets\uadservices.txt) do @(
taskkill /FI "Services eq %%a" /F
echo.
)
@IF %runningservice% GTR 0 echo WARNING: Audio Universal Service %1 did not properly shutdown.
@IF %runningservice% GTR 0 echo.
@IF EXIST assets\uadservices.txt For /f tokens^=^*^ eol^= %%a in (assets\uadservices.txt) do @(
sc delete "%%a"
echo.
)
@echo Done.
@echo.

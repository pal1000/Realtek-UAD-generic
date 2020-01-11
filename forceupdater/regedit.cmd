@set exitloop=1
@FOR /F "tokens=1" %%a IN ('REG QUERY HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318} /f RTKVHD64.sys /e /s') do @IF defined exitloop (
set "exitloop="
set drvprefix=%%a
)
@IF EXIST Win64\Realtek\UpdatedCodec\patch.txt FOR /F "tokens=1-5 delims=," %%a IN (Win64\Realtek\UpdatedCodec\patch.txt) do @IF %%a==HKR call forceupdater\%%a.cmd %%b %%c %%d %%e
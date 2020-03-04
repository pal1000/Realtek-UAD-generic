@rem Locate sound card MEDIA class position
@IF EXIST patches\*.hkr set exitloop=1
@IF EXIST patches\*.hkr FOR /F tokens^=1^ eol^= %%a IN ('REG QUERY HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318} /f 1-14-2020 /e /s') do @IF defined exitloop (
set "exitloop="
set drvprefix=%%a
)

@rem Common codec post INF install patching
@IF EXIST patches\codec-common.hkr FOR /F tokens^=1^-5^ delims^=^,^ eol^= %%a IN (patches\codec-common.hkr) do @IF %%a==HKR call forceupdater\%%a.cmd %%b %%c %%d %%e

@call forceupdater\audiotype.cmd

@rem INTELAUDIO codec post INF install patching
@IF EXIST patches\codec-sst.hkr IF /I %audiotype%==INTELAUDIO FOR /F tokens^=1^-5^ delims^=^,^ eol^= %%a IN (patches\codec-sst.hkr) do @IF %%a==HKR call forceupdater\%%a.cmd %%b %%c %%d %%e
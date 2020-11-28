
@echo off
if not exist C:\OEM\AcerLogs md C:\OEM\AcerLogs
SET LogPath=C:\OEM\AcerLogs\Useralaunch.Log
ECHO.>>%LogPath%
ECHO %DATE% %TIME%[Log START]  ============ %~dpnx0 ============ >> %LogPath%
SETLOCAL ENABLEDELAYEDEXPANSION
pushd "%~dp0"


ECHO %DATE% %TIME%[Log TRACE]  reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber>>%LogPath% 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber>>%LogPath% 2>&1
for /f "skip=2 tokens=3 delims= " %%V in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber') do SET OSCurrentVerison=%%V
if %OSCurrentVerison% LEQ 16299 (
	ECHO %DATE% %TIME%[Log TRACE]  OSCurrentVerison=[%OSCurrentVerison%], No support Driver UWP. Goto :end>>%LogPath%
	goto :END
) else (
	ECHO %DATE% %TIME%[Log TRACE]  OSCurrentVerison=[%OSCurrentVerison%], It's okay to support Driver UWP. Continue>>%LogPath%
)

REM for /f "skip=2 tokens=3" %%A in ('reg query HKLM\Software\OEM\Metadata /v Brand') do set Brand=%%A
REM ECHO %DATE% %TIME%[Log TRACE]  SET Custom DATA File NAME by Brand >> %LogPath%
REM SET CustomDATA=.\CDF\custom.data.acerlt.xml
REM if /I "%Brand%" == "Gateway" set CustomDATA=gateway-abb.json
REM if /I "%Brand%" == "Packard" set CustomDATA=packardbell-abb.json


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::	
::::   DO Not Trim Trailing space............
::::
::::   Each Set Value in the end exist the Space for dism split paramter
::::   set APPXPackagePath_X86=!APPXPackagePath_X86!/dependencypackagepath:"%%d" 
::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


IF /i "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (
	call :GetParameter
	REM ECHO %DATE% %TIME%[Log TRACE]  dism /online /english /add-provisionedappxpackage /packagepath:"!packagepath!" /licensepath:"!licensepath!" !DependencyPackage_X64!/CustomDataPath:"%CustomDATA%" /region="all">>%LogPath% 2>&1
	REM dism /online /english /add-provisionedappxpackage /packagepath:"!packagepath!" /licensepath:"!licensepath!" !DependencyPackage_X64!/CustomDataPath:"%CustomDATA%" /region="all">>%LogPath% 2>&1
	ECHO %DATE% %TIME%[Log TRACE]  dism /online /english /add-provisionedappxpackage /packagepath:"!packagepath!" /licensepath:"!licensepath!" !DependencyPackage_X64!/region="all">>%LogPath% 2>&1
	dism /online /english /add-provisionedappxpackage /packagepath:"!packagepath!" /licensepath:"!licensepath!" !DependencyPackage_X64!/region="all">>%LogPath% 2>&1
) else (	
	call :GetParameter
	REM ECHO %DATE% %TIME%[Log TRACE]  dism /online /english /add-provisionedappxpackage /packagepath:"!packagepath!" /licensepath:"!licensepath!" !DependencyPackage_X86!/CustomDataPath:"%CustomDATA%" /region="all">>%LogPath% 2>&1
	REM dism /online /english /add-provisionedappxpackage /packagepath:"!packagepath!" /licensepath:"!licensepath!" !DependencyPackage_X86!/CustomDataPath:"%CustomDATA%" /region="all">>%LogPath% 2>&1
	ECHO %DATE% %TIME%[Log TRACE]  dism /online /english /add-provisionedappxpackage /packagepath:"!packagepath!" /licensepath:"!licensepath!" !DependencyPackage_X86!/region="all">>%LogPath% 2>&1
	dism /online /english /add-provisionedappxpackage /packagepath:"!packagepath!" /licensepath:"!licensepath!" !DependencyPackage_X86!/region="all">>%LogPath% 2>&1
)
SET DISMErrCode=%errorlevel%
ECHO %DATE% %TIME%[Log TRACE]  got return code [%DISMErrCode%] >>%LogPath%
if %DISMErrCode% neq 0 (
	ECHO %DATE% %TIME%[Log TRACE]  Return code is [%DISMErrCode%], pop up error message to remind user. >>%LogPath%
	call :Reboot
) else (
	ECHO %DATE% %TIME%[Log TRACE]  Return code is [%DISMErrCode%], leave. >>%LogPath%
)

:END
popd
SETLOCAL DISABLEDELAYEDEXPANSION
ECHO %DATE% %TIME%[Log LEAVE]  ============ %~dpnx0 ============ >> %LogPath%
ECHO.>>%LogPath%
exit /b 0



:GetParameter
:GetPackagePath_Start
REM Prepare PackagePath
:Method1
ECHO %DATE% %TIME%[Log TRACE]  dir /s /b *.appxbundle >> %LogPath%
dir /s /b *.appxbundle >> %LogPath% 2>&1
(for /f "delims=" %%d in ('dir /s /b *.appxbundle') do (
	set packagepath=%%d
))>NUL 2>&1

:Method2
ECHO %DATE% %TIME%[Log TRACE]  dir /s /b *.appx>> %LogPath% 2>&1
dir /s /b *.appx>C:\OEM\Appx_list.txt 2>&1
if %errorlevel% neq 0 (
	ECHO !DATE! !TIME![Log TRACE]  *.appx not found, goto :GetPackagePath_END >>%LogPath%
	goto :GetPackagePath_END
)
type C:\OEM\Appx_list.txt >> %LogPath%
ECHO %DATE% %TIME%[Log TRACE]  Getting Dependency Appx list>>%LogPath%
dir /s /b Microsoft*.appx>C:\OEM\DependencyAppx_list.txt 2>&1
type C:\OEM\DependencyAppx_list.txt >>%LogPath%
for /f "delims=" %%f in (C:\OEM\Appx_list.txt) do (
	ECHO ------------------------------------------------------------------------------ >>%LogPath%
	ECHO !DATE! !TIME![Log TRACE]  Checking [%%~nf] if main Package... >>%LogPath%
	ECHO !DATE! !TIME![Log TRACE]  find /i "%%~nf" C:\OEM\DependencyAppx_list.txt>>%LogPath% 2>&1
	find /i "%%~nf" C:\OEM\DependencyAppx_list.txt>>%LogPath% 2>&1
	if !errorlevel! neq 0 (
		ECHO !DATE! !TIME![Log TRACE]  [%%~nxf] did not exist in the C:\OEM\DependencyAppx_list.txt, set as PackagePath>>%LogPath%
		set PackagePath=%%f
	) else (
		ECHO !DATE! !TIME![Log TRACE]  [%%~nxf] exist in the C:\OEM\DependencyAppx_list.txt, not the main package. >>%LogPath%
	)
)

:GetPackagePath_END
ECHO %DATE% %TIME%[Log TRACE]  PackagePath is [%packagepath%]  >> %LogPath%
ECHO.>>%LogPath%

REM Prepare LicensePath
ECHO %DATE% %TIME%[Log TRACE]  dir /s /b *License*.xml >> %LogPath%
dir /s /b *License*.xml >> %LogPath% 2>&1
(for /f "delims=" %%d in ('dir /s /b *License*.xml') do (
	set licensepath=%%d
))>NUL 2>&1
ECHO %DATE% %TIME%[Log TRACE]  LicensePath is [%licensepath%]  >> %LogPath%
ECHO.>>%LogPath%

REM Prepare DependencyPackagePath
ECHO %DATE% %TIME%[Log TRACE]  dir /s /b Microsoft*_x86*.appx >> %LogPath%
dir /s /b Microsoft*_x86*.appx >> %LogPath% 2>&1
(for /f "delims=" %%d in ('dir /s /b Microsoft*_x86*.appx') do (
	set DependencyPackage_X86=!DependencyPackage_X86!/dependencypackagepath:"%%d" 
	ECHO !DATE! !TIME![Log TRACE]  Now DependencyPackage_X86 is [!DependencyPackage_X86!] >>%LogPath%
))>NUL 2>&1
ECHO %DATE% %TIME%[Log TRACE]  dir /s /b Microsoft*_x64*.appx >> %LogPath%
dir /s /b Microsoft*_x64*.appx >> %LogPath% 2>&1
(for /f "delims=" %%d in ('dir /s /b Microsoft*_x64*.appx') do (
	set DependencyPackage_X64=!DependencyPackage_X64!/dependencypackagepath:"%%d" 
	ECHO !DATE! !TIME![Log TRACE]  Now DependencyPackage_X64 is [!DependencyPackage_X64!] >>%LogPath%
))>NUL 2>&1
ECHO %DATE% %TIME%[Log TRACE]  Merge _x86.appx and _x64.appx For X64 >> %LogPath%
set DependencyPackage_X64=%DependencyPackage_X86%%DependencyPackage_X64%
ECHO %DATE% %TIME%[Log TRACE]  After merge DependencyPackage_X64 is [%DependencyPackage_X64%] >>%LogPath%
ECHO.>>%LogPath%
exit /b 0



:Reboot
if exist UWPFAIL_rebooted.tag (
	if exist c:\OEM\NAPP\D2D.tag (
		ECHO %DATE% %TIME%[Log TRACE]  c:\OEM\NAPP\D2D.tag found, exit /b 0 >>%LogPath%
		exit /b 0
	)
)
ECHO %DATE% %TIME%[Log TRACE]  acerReboot.exe with timeout 10 and Pause >>%LogPath%
ECHO %DATE% %TIME%[Log TRACE]  acerReboot.exe with timeout 10 and Pause >UWPFAIL_rebooted.tag
if exist C:\Windows\System32\acerReboot.exe (
	acerReboot.exe >>%LogPath% 2>&1
) else (
	ECHO MsgBox "ERROR! Driver UWP Install process failed with ERROR code %DISMErrCode%",16,"Driver UWP Installation Detection" >ErrorMsg.vbs
	CScript /nologo ErrorMsg.vbs
	CScript /nologo ErrorMsg.vbs
	CScript /nologo ErrorMsg.vbs
)
timeout /t 10
pause
exit /b 0


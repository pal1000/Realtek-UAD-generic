@rem XXX: This script needs to run as SYSTEM
@cd /d "%~dp0"
@cd ..
@for /f "tokens=*" %%a in ('dir /A:D /B "%SystemRoot%\System32\DriverStore\FileRepository\hdxrt.inf*"') do @(
@IF EXIST "%SystemRoot%\System32\DriverStore\FileRepository\%%a\RTKVHD64.sys" copy /y Win64\Realtek\UpdatedCodec\RTKVHD64.sys "%SystemRoot%\System32\DriverStore\FileRepository\%%a"
@IF EXIST "%SystemRoot%\System32\DriverStore\FileRepository\%%a\RTAIODAT.DAT" copy /y Win64\Realtek\UpdatedCodec\RTAIODAT.DAT "%SystemRoot%\System32\DriverStore\FileRepository\%%a"
)
@for /f "tokens=*" %%a in ('dir /A:D /B "%SystemRoot%\System32\DriverStore\FileRepository\hdxrtsst.inf*"') do @(
@IF EXIST "%SystemRoot%\System32\DriverStore\FileRepository\%%a\RTKVHD64.sys" copy /y Win64\Realtek\UpdatedCodec\RTKVHD64.sys "%SystemRoot%\System32\DriverStore\FileRepository\%%a"
@IF EXIST "%SystemRoot%\System32\DriverStore\FileRepository\%%a\RTAIODAT.DAT" copy /y Win64\Realtek\UpdatedCodec\RTAIODAT.DAT "%SystemRoot%\System32\DriverStore\FileRepository\%%a"
)
@pause

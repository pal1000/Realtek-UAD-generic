@IF %3 EQU 0x10001 set regcmd=REG ADD %drvprefix%\%1 /v %2 /t REG_DWORD /d %4 /f
@IF %3 EQU 0x10000 set regcmd=REG ADD %drvprefix%\%1 /v %2 /t REG_MULTI_SZ /d %4 /f
@IF %3 EQU 0x0 set regcmd=REG ADD %drvprefix%\%1 /v %2 /t REG_SZ /d %4 /f
@%regcmd%

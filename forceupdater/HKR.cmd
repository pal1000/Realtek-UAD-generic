@rem REG cmd prefix
@set regcmd=REG ADD %drvprefix%\%1

@rem Add value
@set regcmd=%regcmd% /v %2

@rem Add type
@IF %3==0x10001 set regcmd=%regcmd% /t REG_DWORD

@rem Add data
@set regcmd=%regcmd% /d %4

@rem Work silently
@set regcmd=%regcmd% /f

@%regcmd%

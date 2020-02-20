@set exitloop=1
@FOR /F tokens^=1^ delims^=^\^ USEBACKQ^ eol^= %%a IN (`devcon find =MEDIA "HDAUDIO\FUNC_01&VEN_10EC*" "INTELAUDIO\FUNC_01&VEN_10EC*" 2^>^&1`) do @IF defined exitloop (
set "exitloop="
set audiotype=%%a
)
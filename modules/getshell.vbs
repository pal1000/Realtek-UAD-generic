On Error Resume Next
	WScript.Echo WScript.CreateObject("WScript.Shell").RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Shell")
On Error Goto 0
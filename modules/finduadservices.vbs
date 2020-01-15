For Each objService In GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2").ExecQuery("Select * from Win32_Service")
	If InStr(1, objService.PathName, "RtkAudUService64.exe", vbTextCompare) <> 0 Then
		WScript.Echo objService.Name
	End If
Next
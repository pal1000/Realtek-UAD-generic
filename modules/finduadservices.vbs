Set objWMIService     = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colListOfServices = objWMIService.ExecQuery("Select * from Win32_Service")

For Each objService in colListOfServices
	If InStr(objService.PathName, "RtkAudUService64.exe") Then
		WScript.Echo objService.Name
	End If
Next
For Each objStartupCommand In GetObject("winmgmts:\\.\root\cimv2").ExecQuery("Select * from Win32_StartupCommand")
	With objStartupCommand
		If Left(.Location, 4) = "HKLM" Then
			If InStr(1, .Command, "RtkAudUService64.exe", vbTextCompare) <> 0 Then
				WScript.Echo .Name
			End If
		End If
	End With
Next
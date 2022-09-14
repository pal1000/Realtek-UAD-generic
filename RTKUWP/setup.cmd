@powershell -NoLogo -Command "Add-AppxPackage -Path *.Appx" 2>nul
@powershell -NoLogo -Command "Add-AppxPackage -Path *.AppxBundle"
@powershell -NoLogo -Command "Add-AppxPackage -Path *.EAppxBundle" 2>nul
@pause
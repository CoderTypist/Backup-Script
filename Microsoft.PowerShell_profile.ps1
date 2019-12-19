# FUNCTIONS navigation
function goToHome { cd "C:\Users\$env:UserName" }
function goToDocs { cd "C:\Users\$env:UserName\Documents" }
function goToDrive { cd "C:\Users\$env:UserName\Google Drive" }
function goToAdmin { cd "C:\WINDOWS\system32" }

# FUNCTIONS ease
function doListDirectories { dir | ? {$_.PSIsContainer} }
function doListHidden { dir -Force }

# ALIASES navigation
Set-Alias home goToHome
Set-Alias docs goToDocs 
Set-Alias drive goToDrive
Set-Alias admin goToAdmin

# ALIASES editors
Set-Alias vs code.cmd         #Visual Studio Code
Set-Alias np notepad
Set-Alias npp "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias psi PowerShell_ise.exe

# ALIASES ease
Set-Alias dird doListDirectories
Set-Alias dira doListHidden

# commands to run
docs
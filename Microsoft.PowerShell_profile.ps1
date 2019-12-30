# FUNCTIONS navigation
function goToHome { cd "C:\Users\$env:UserName" }
function goToDocs { cd "C:\Users\$env:UserName\Documents" }
function goToDrive { cd "C:\Users\$env:UserName\Google Drive" }
function goToAdmin { cd "C:\WINDOWS\system32" }

# FUNCTIONS ease
function doShowDirectories { dir | ? {$_.PSIsContainer} }
function doShowHidden { dir -Force }

function doList { dir | foreach { $_.name } }
function doListDirectories { dir | ? {$_.PSIsContainer} | foreach { $_.name } }
function doListHidden { dir -Force | foreach { $_.name } }

function doFormatList { echo ""; dir | foreach { Write-Host "  " -NoNewLine; $_.name }; echo "" }
function doFormatListDirectories { echo ""; dir | ? {$_.PSIsContainer} | foreach { Write-Host "  " -NoNewLine; $_.name }; echo "" }
function doFormatListHidden { echo ""; dir -Force | foreach { Write-Host "  " -NoNewLine; $_.name }; echo "" }

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
Set-Alias dird doShowDirectories
Set-Alias dira doShowHidden

Set-Alias ldir  doList
Set-Alias ldird doListDirectories
Set-Alias ldira doListHidden

Set-Alias fldir doFormatList
Set-Alias fldird doFormatListDirectories
Set-Alias fldira doFormatListHidden

# commands to run
docs
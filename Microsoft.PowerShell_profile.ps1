# ALIASES navigation
$docs = "C:\Users\$env:UserName\Documents"
$drive = "C:\Users\$env:UserName\Google Drive"
$admin = "C:\WINDOWS\system32"
$prof = "$profile\.."

# FUNCTIONS navigation
function goToHome { cd $home }
function goToDocs { cd $docs }
function goToDrive { cd $drive }
function goToAdmin { cd $admin }
function goToProfile { cd $prof }

# FUNCTIONS ease
function doShowDirectories { dir | ? { $_.PSIsContainer } }
function doShowHidden { dir -Force }

function doList { dir | % { $_.name } }
function doListDirectories { dir | ? { $_.PSIsContainer } | % { $_.name } }
function doListHidden { dir -Force | % { $_.name } }

function doFormatList { echo ""; dir | % { Write-Host "  " -NoNewLine; $_.name }; echo "" }
function doFormatListDirectories { echo ""; dir | ? { $_.PSIsContainer } | % { Write-Host "  " -NoNewLine; $_.name }; echo "" }
function doFormatListHidden { echo ""; dir -Force | % { Write-Host "  " -NoNewLine; $_.name }; echo "" }

function doColumns ([int]$numCols) { 
    if ( !$numCols ){ dir | Format-Wide }
    else { dir | Format-Wide -Column $numCols }
}

function doColumnsDirectories ([int]$numCols) { 
    if ( !$numCols ) { dir | ? { $_.PSIsContainer } | Format-Wide }
    else { dir | ? { $_.PSIsContainer } | Format-Wide -Column $numCols }
}

function doColumnsHidden ([int]$numCols) { 
    if ( !$numCols ) { dir -Force | Format-Wide }
    else { dir -Force | Format-Wide -Column $numCols }
}

# ALIASES navigation
Set-Alias home goToHome
Set-Alias docs goToDocs 
Set-Alias drive goToDrive
Set-Alias admin goToAdmin
Set-Alias prof goToProfile

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

Set-Alias cl doColumns
Set-Alias cld doColumnsDirectories
Set-Alias cla doColumnsHidden

Set-Alias zip Compress-Archive
Set-Alias unzip Expand-Archive

# commands to run
docs
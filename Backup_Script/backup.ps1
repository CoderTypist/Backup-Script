
# author: Christian Bargraser
# https://github.com/CoderTypist

# This script is intended to be stored on the external storage device being used
# By doing this, you can easily create backups of different devices

# imports
. .\class_Backup.ps1

# usage information
function usage {

    echo "`nCreates backup"
    echo ".\backup <backup_option>`n"

    echo "Lists backup options"
    echo ".\backup options`n"

    echo "Expands a backup"
    echo ".\backup expand <path_of_backup> <place_expanded_backup_in_this_directory>`n"
}

# lists all backup options
function listBackups {
    
    echo "`nBackup Options:`n"
    foreach ($item in $all_Backups) {
        $item.toString()
    }
    exit
}

#------------------------ ANY MODIFICATIONS GO HERE ------------------------#

# backups will be stored here
$dest = "D:\Backups\"
# $dest = "C:\Users\Coder Typist\Documents\PowerShell\Backup_Script\Backups"

# default number of backups
$numBackups = 3

# list of all backup options
# [Backup[]]$all_Backups = @()
$all_Backups = @()

# [Backup]::new(<1>, <2>, <3>, <4>)
# 1 - Backup option name
# 2 - Create backup in a directory with this name
# 3 - Create the directory containing the backup (<2>) in this directory (<3>)
# 4 - Maximum number of backups to keep

# backup options
$backup_Documents = [Backup]::new("Documents", "Documents_${env:ComputerName}_${env:UserName}", $dest, $numBackups)
$backup_Drive = [Backup]::new("Drive", "Google_Drive", $dest, $numBackups)
$backup_Test = [Backup]::new("Test", "Test_Files", $dest, $numBackups)

# backup Documents
$backup_Documents.add("C:\Users\$env:UserName\Documents")
$backup_Documents.add("C:\Users\$env:UserName\Desktop")
$backup_Documents.add("C:\Users\$env:UserName\Pictures")
$backup_Documents.add("C:\Users\$env:UserName\Videos")
$backup_Documents.add("C:\Users\$env:UserName\Downloads")

# backup Google Drive
$backup_Drive.add("C:\Users\$env:UserName\Google Drive")

# backup Testing
$backup_Test.add("C:\Users\$env:UserName\Documents\A_folder")
$backup_Test.add("C:\Users\$env:UserName\Documents\B_folder")
$backup_Test.add("C:\Users\$env:UserName\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
$backup_Test.add("C:\Users\$env:UserName\Documents\temp.zip")

# add all backup options to list
$all_Backups += $backup_Documents
$all_Backups += $backup_Drive
$all_Backups += $backup_Test

#-------------------- SHOULD NOT MODIFY AFTER THIS POINT -------------------#

# user selected backup option
$cur_Backup = $null

# if no arguments are provided
if ( !$args ) {
    usage
    exit
}

# list backup options
if ( $args[0].toLower().equals("options") ) {
    listBackups
    exit
}

# expand a pre-existing backup
if ( $args[0].toLower().equals("expand") ) {
    expand $args[1] $args[2]
    exit
}

# select backup option from user input
foreach ( $item in $all_Backups ) {

    if( $args[0].toLower().equals($item.backupName.toLower()) ){
        $cur_Backup = $item
        break
    }
}

# if an invalid backup option was selected
if ( !$cur_Backup ) {

    Write-Host "`n  Invalid backup option: " -NoNewLine
    echo $args[0]
    listBackups
    exit
}

# if none of the folders to backup exist
if ( $false -eq $cur_Backup.canBackup() ) {

    echo "`n  None of the target directories exist."
    echo "  No backups were made.`n"
    $cur_Backup.toString()
    exit
}

# create backup
$timer = [system.diagnostics.stopwatch]::StartNew()
$cur_Backup.createBackup()
Write-Host "  Backup took: $($timer.elapsed.toString())`n"

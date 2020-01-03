
# imports
. .\class_Backup.ps1

# usage information
function usage {

    echo "`nCreates backup"
    echo ".\backup <backup_option>`n"

    echo "`nLists backup options"
    echo ".\backup list`n"
}

# lists all backup options
function listBackups {
    
    echo ""
    foreach ($item in $all_Backups) {
        $item.toString()
    }
    exit
}

# maximum number of backups
$num_Backups = 3

# list of all backup options
[Backup[]]$all_Backups = @()

# BACKUP Documents
$backup_Documents = [Backup]::new("Documents")
$backup_Documents.add("C:\Users\$env:UserName\Documents")
$backup_Documents.add("C:\Users\$env:UserName\Desktop")
$backup_Documents.add("C:\Users\$env:UserName\Pictures")
$backup_Documents.add("C:\Users\$env:UserName\Videos")
$backup_Documents.add("C:\Users\$env:UserName\Downloads")

# BACKUP Google Drive
$backup_Drive = [Backup]::new("Google_Drive")
$backup_Drive.add("C:\Users\$env:UserName\Google Drive")

# BACKUP Testing
$backup_Test = [Backup]::new("Test")
$backup_Test.add("C:\Users\$env:UserName\Documents\PowerShell_Examples")

# add all backup options to list
$all_Backups += $backup_Documents
$all_Backups += $backup_Drive
$all_Backups += $backup_Test

# user selected backup option
$cur_Backup = $null

# if no arguments are provided
if ( !$args ) {
    usage
    exit
}

# list backup options
if ( $args[0].tolower().equals("list") ) {
    listBackups
    exit
}

# select backup option 
switch ( $args[0].toLower() ) {

    "drive" { $cur_Backup = $backup_Drive; break }
    "documents" { $cur_Backup = $backup_Documents; break }
    "test" { $cur_Backup = $backup_Test; break }
}

# if an invalid backup option was selected
if ( !$cur_Backup ) {

    echo "`n  Invalid backup option`n"
    exit
}

# name of parent folder that will contain backups
$baseName = $null

# select parent folder name
switch ( $args[0].toLower() ) {

    "drive" { $baseName = "Google_Drive" }
    "documents" { $baseName = $env:ComputerName }
    "test" { $baseName = "PowerShell_Examples"}
}

# remove later
echo "`nThe base name you chose was: ${basename}`n"

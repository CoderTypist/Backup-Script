
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
    
    echo "`nBackup Options:`n"
    foreach ($item in $all_Backups) {
        $item.toString()
    }
    exit
}

# backups will be stored here
# $dest = "D:\"
$dest = "C:\Users\Coder Typist\Documents\PowerShell\Backup_Script\Backups"

# maximum number of backups
$num_Backups = 3

# list of all backup options
[Backup[]]$all_Backups = @()

# BACKUP Documents
$backup_Documents = [Backup]::new("Documents", $env:ComputerName)
$backup_Documents.add("C:\Users\$env:UserName\Documents")
$backup_Documents.add("C:\Users\$env:UserName\Desktop")
$backup_Documents.add("C:\Users\$env:UserName\Pictures")
$backup_Documents.add("C:\Users\$env:UserName\Videos")
$backup_Documents.add("C:\Users\$env:UserName\Downloads")

# BACKUP Google Drive
$backup_Drive = [Backup]::new("Drive", "Google_Drive")
$backup_Drive.add("C:\Users\$env:UserName\Google Drive")

# BACKUP Testing
$backup_Test = [Backup]::new("Test", "PowerShell_Examples")
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

# select backup option from user input
foreach ( $item in $all_Backups ) {

    if( $args[0].toLower().equals($item.backupName.toLower()) ){
        $cur_Backup = $item
    }
}

# if an invalid backup option was selected
if ( !$cur_Backup ) {

    Write-Host "`n  Invalid backup option: " -NoNewLine
    echo $args[0]
    listBackups
    exit
}

# attempt to create the destination folder if it does not exist
if( !(Test-Path $dest -PathType container ) ) {
    md $dest -erroraction 'silentlycontinue'

    if ( $false -eq $? ) {
        echo "`n Unable to create destination folder $dest `n"
        exit
    }
}

# if none of the folders to backup exist
if ( $false -eq $cur_Backup.canBackup() ) {

    echo "`n  None of the target directories exist."
    echo "  No backups were made.`n"
    $cur_Backup.toString()
    exit
}

# destination formatting
if ( $dest[$dest.length-1] -ne '\' -and $dest[$dest.length-1] -ne '/' ) {
    $dest += '\'
}

# $var = get-date -format "_MM_dd_yy_HH_mm"

# imports
. .\class_Backup.ps1

function usage {

    echo ""
    echo "Creates backup"
    echo ".\backup <backup_type>"
    echo ""

    echo ""
    echo "Lists types of backups"
    echo ".\backup list"
    echo ""
}

function listBackups {
    
    echo ""
    foreach ($item in $all_Backups) {
        $item.toString()
    }
    exit
}

$num_Backups = 3
[Backup[]]$all_Backups = @()

$backup_Documents = $null

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

$all_Backups += $backup_Documents
$all_Backups += $backup_Drive
$all_Backups += $backup_Test

$cur_Backup = $null

if ( !$args ) {
    usage
    exit
}

if ( $args[0].tolower().equals("list") ) {
    listBackups
}

switch ( $args[0].toLower() ) {

    "drive" { $cur_Backup = $backup_Drive; break }
    "documents" { $cur_Backup = $backup_Documents; break }
    "test" { $cur_Test = $backup_Test; break }
}

if ( !$cur_Backup ) {

    echo ""
    echo "  Invalid backup type"
    echo ""
    exit
}




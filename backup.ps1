
class Backup{

    [string]$backupName
    [string[]]$directoriesToCopy

    Backup([string]$backupName){
        $this.backupName = $backupName
    }

    [void] add([string]$dirToCopy){
        $this.directoriesToCopy += "$dirToCopy"
    }
    
    [String] toString(){
        
        $s = "`n"
        $s += $this.backupName
        $s += "`n"

        For ($i = 0; $i -lt $this.backupName.length; $i++) {
            $s += '-'
        }

        $s += "`n"

        Foreach ($directory in $this.directoriesToCopy) {
            $s += "${directory}`n"
        }

        return $s
    }
}

$num_Backups = 3
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

$all_Backups += $backup_Documents
$all_Backups += $backup_Drive
$all_Backups += $backup_Test

$backup_Documents.toString()
$backup_Drive.toString()
$backup_Test.toString()

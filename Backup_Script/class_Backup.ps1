
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

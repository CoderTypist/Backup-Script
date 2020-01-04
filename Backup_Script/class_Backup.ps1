
class Backup{

    [string]$backupName # name of backup option
    [string]$baseName   
    [string[]]$directoriesToCopy

    Backup([string]$backupName, [string]$baseName){
        $this.backupName = $backupName
        $this.baseName = $baseName
    }

    [void] add([string]$dirToCopy){
        $this.directoriesToCopy += "$dirToCopy"
    }

    [bool] canBackup(){

        foreach ( $item in $this.directoriesToCopy ) {
            if( Test-Path $item -PathType container ) {
                return $true
            }
        }
        return $false
    }

    [void] createBackup ([string]$dest){
        
    }

    [string] toString(){
        
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


class Backup{

    [string]$backupName              # name of backup option
    [string]$baseName                # backup will be insider a directory with this name
    [string]$dest                    # directory containing the backup will be here
    [int]$numBackups                 # max number of backups to keep
    [string[]]$directoriesToCopy     # directories to copy

    Backup([string]$backupName, [string]$baseName, [string]$dest, [int]$numBackups){

        $this.backupName = $backupName
        $this.baseName = $baseName
        $this.dest = $dest
        $this.numBackups = $numBackups

        if ( $numBackups -le 0 ) {
            Write-Host "`n  class Backup: constructor: numBackups must be greater than 0"
            Write-Host "  Backup option: ${backupName}"
            Write-Host "  numBackups: ${numBackups}`n"
            exit
        }
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

    hidden [void] managePrevious(){

    }

    hidden [void] removePrevious(){

    }

    [void] createBackup (){

        # attempt to create the destination folder if it does not exist
        if( !(Test-Path $this.dest -PathType container ) ) {
            md $this.dest -erroraction 'silentlycontinue'

            if ( $false -eq $? ) {
                Write-Host "`n Unable to create destination folder`n"
                exit
            }
        }

        # destination formatting
        if ( $this.dest[$this.dest.length-1] -ne '\' -and $this.dest[$this.dest.length-1] -ne '/' ) {
            $this.dest += '\'
        }
    }

    [string] toString(){
        
        $s += $this.backupName
        $s += "`n"

        for ($i = 0; $i -lt $this.backupName.length; $i++) {
            $s += '-'
        }

        $s += "`n"

        foreach ($directory in $this.directoriesToCopy) {
            $s += "${directory}`n"
        }

        return $s
    }
}

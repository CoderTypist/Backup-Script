
class Backup{

    [string]$backupName              # name of backup option
    [string]$baseName                # backup will be located in the directory with this name
    [string]$dest                    # directory containing the backup will be here
    [int]$numBackups                 # max number of backups to keep
    [string[]]$directoriesToCopy     # directories to copy

    Backup([string]$backupName, [string]$baseName, [string]$dest, [int]$numBackups) {

        $this.backupName = $backupName
        $this.baseName = $baseName
        $this.dest = $dest
        $this.numBackups = $numBackups

        # numBackups must be greater than 0
        if ( $numBackups -le 0 ) {
            Write-Host "`n  class Backup: constructor: numBackups must be greater than 0"
            Write-Host "  Backup option: ${backupName}"
            Write-Host "  numBackups: ${numBackups}`n"
            exit
        }

        # numBackups cannot be greater than 99
        if ( $numBackups -gt 99 ) {
            Write-Host "`n  class Backup: constructor: numBackups must be less than 100"
            Write-Host "  Backup option: ${backupName}"
            Write-Host "  numBackups: ${numBackups}`n"
            exit
        }

        # destination formatting
        if ( $this.dest[$this.dest.length-1] -ne '\' -and $this.dest[$this.dest.length-1] -ne '/' ) {
            $this.dest += '\'
        }

        $this.dest += $this.baseName
        $this.dest += '\'
    }

    [void] add([string]$dirToCopy){
        $this.directoriesToCopy += "$dirToCopy"
    }

    [bool] canBackup() {

        foreach ( $item in $this.directoriesToCopy ) {
            if( Test-Path $item -PathType container ) {
                return $true
            }
        }
        return $false
    }

    # The backup process may take too long and the user may quit the program.
    # Backups may be several gigabytes and the process may take a while.
    #
    # If the "extra" backups were deleted before backing up is done, and the user
    # quits the program, the old backups would be lost.
    # To avoid this, backups that are meant to be deleted are temporarily renamed
    # until the backup process is completed. 
    # Once the backup is successfully created, the temporarily renamed backups are deleted.
    #
    # If the user quits the program during the backup process, the user will have
    # to manually go rename the backups. 
    # Failing to appropriately rename the temporarily renamed backups will result in 
    # the program not working properly.
    hidden [void] managePrevious() {

        $prevBackups = ls $this.dest | % { $_.name }

        # temporarily rename backups that will be deleted later
        if ( $prevBackups.length -ge $this.numBackups ) {

            # number of backups to be renamed to temp_##
            $numTemps = $prevBackups.length - ( $this.numBackups - 1 )

            # renames backups (that will be deleted later) to temp_##
            for ( $i = 0; $i -lt $numTemps; $i++ ) {
                $tempName = "temp_"
                $tempName += $this.numify($i+1)
                mv "$($this.dest)$($prevBackups[$i])" "$($this.dest)$tempName"
            }

            # renumbers the remaining backups
            $newNum = 1

            for ( $i = $numTemps; $i -lt $prevBackups.length; $i++) {
                
                # Write-Host "$($this.dest)$($this.numify($newNum))$($prevBackups[$i].substring(2))"
                mv "$($this.dest)$($prevBackups[$i])" "$($this.dest)$($this.numify($newNum))$($prevBackups[$i].substring(2))"
                $newNum++
            }

        }

        $result = ls $this.dest | % { $_.name }
        # You need to use a for loop
        foreach ( $item in $result ){
            Write-Host $item
        }
    }

    hidden [void] removeTemps() {

    }

    [void] createBackup() {

        # attempt to create the destination folder if it does not exist
        if( !(Test-Path $this.dest -PathType container ) ) {
            md $this.dest -erroraction 'silentlycontinue'

            if ( $false -eq $? ) {
                Write-Host "`n Unable to create destination folder`n"
                exit
            }
        }

        $this.managePrevious()
    }

    # ensures that a string representation of number with a length of 2 is returned
    # if $num == 2, numify will return "02"
    # if $num == 21, numify will return "21"
    # numBackups must be > 0 and < 100 (the constructor ensures this)
    # therefore, $num can be in the inclusive range of 1-99
    # therefore, [string]$num will always have a length <= 2
    hidden [string] numify([int]$num) {

        if ( $num -gt 9 ) {
            return [string]$num
        }

        else {
            return "0${num}"
        }
    }

    [string] toString() {
        
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

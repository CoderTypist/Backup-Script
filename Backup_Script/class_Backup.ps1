
# author: Christian Bargraser
# https://github.com/CoderTypist

class Backup{

    [string]$backupName              # name of backup option
    [string]$baseName                # backup will be located in the directory with this name
    [string]$dest                    # directory containing the backup will be here
    [int]$numBackups                 # max number of backups to keep
    [string[]]$itemsToCopy           # items to copy

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
        $this.itemsToCopy += "$dirToCopy"
    }

    # returns true if all of the items in $itemsToCopy exist
    [bool] canBackup() {

        foreach ( $item in $this.itemsToCopy ) {

            if( !(Test-Path $item) ) {
                return $false
            }
        }
        return $true
    }

    [void] createBackup() {

        Write-Host "`n  Beginning backup..."
        Write-Host "  $($this.backupName)`n"

        # attempt to create the destination folder if it does not exist
        if( !(Test-Path $this.dest -PathType container ) ) {
            md $this.dest -erroraction 'silentlycontinue'

            if ( $false -eq $? ) {
                Write-Host "`n Unable to create destination folder`n"
                exit
            }
        }

        # recovery from failed backup attempt
        if ( Test-Path "$($this.dest)temp" -PathType container ) {
            rm "$($this.dest)temp" -recurse
        }

        # list of previous backups
        [string[]]$savedBackups = ls $this.dest | % { $_.name }

        # create the new backup
        md "$($this.dest)temp"

        $numItem = 1
        foreach ( $item in $this.itemsToCopy ) {

            Write-Host "  $($numItem)/$($this.itemsToCopy.length): $item" -NoNewLine
            
            # data to pass on to Start-Job
            $argHash = @{ item = $item; dest = $($this.dest) }

            $zip_timer = [system.diagnostics.stopwatch]::StartNew()
            # Wait for compression to finish before resuming the script.
            # Otherwise, the script will continue while the files are being zipped.
            Start-Job -name "ZipItem" -scriptblock {

                # extracts the file/directory name from the filepath
                function getName([string]$path) {
                    
                    if ( !$path ) { return $null }

                    $path = $path.replace('/','\')
                    $index = $path.lastIndexOf('\')

                    if ( $index -eq -1 ) { $path }

                    elseif ( $index -eq $path.length-1 ) { 
                        $path = $path.substring(0, $path.length-1)
                        $path.substring($path.lastIndexOf('\')+1) 
                    }

                    else { $path.substring($path.lastIndexOf('\')+1) }
                }

                $hash = $args[0]

                $loc = $hash["dest"]
                $loc += "temp\"
                $zip = $loc
                $zip += getName($hash["item"])

                # if the item is a directory
                if ( Test-Path $hash["item"] -PathType container ) {

                    $contents = dir $hash["item"] | % { $_.FullName }

                    # if the directory is empty
                    if ( !$contents ) {
                        $dirName = getName($hash["item"])
                        md "$loc\$dirName"
                    }

                    # directory is not empty
                    else {
                        Compress-Archive $contents $zip
                    }
                }

                # if the item is not a directory
                else {
                    $zip += ".zip"
                    Compress-Archive $hash["item"] $zip
                }

            } -ArgumentList $argHash > $null
            Wait-Job -name "ZipItem" > $null
            Receive-Job -name "ZipItem"

            $zip_timer.stop()
            Write-Host " - $($zip_timer.elapsed.toString())"
            
            $numItem++
        }

        # if there are more backups than the max specified by numBackups
        $newNum = 1
        if ( $savedBackups.length -ge $this.numBackups ) {

            # delete the old backups
            for ( $i = 0; $i -le $savedBackups.length - $this.numBackups; $i++ ) {

                rm "$($this.dest)$($savedBackups[$i])" -recurse
            }

            # rename backups
            for ( $i = ( $savedBackups.length - $this.numBackups + 1 ); $i -lt $savedBackups.length; $i++) {

                mv "$($this.dest)$($savedBackups[$i])" "$($this.dest)$($this.numify($newNum))$($savedBackups[$i].substring(2))" 
                $newNum++
            }
        }

        else {
            $newNum = $savedBackups.length+1
        }

        # rename newly made backup
        $date = get-date -format "_MM_dd_yy_HH_mm"
        mv "$($this.dest)temp" "$($this.dest)$($this.numify($newNum))_$($this.baseName)$date"

        Write-Host "`n  Backup complete`n"
    }

    # ensures that a string representation of number with a length of 2 is returned
    # if $num == 2, numify will return "02"
    # numBackups must be > 0 and < 100 (the constructor ensures this)
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

        foreach ($item in $this.itemsToCopy) {
            $s += "${item}`n"
        }

        return $s
    }
}

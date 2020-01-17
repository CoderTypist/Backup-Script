
# author: Christian Bargraser
# https://github.com/CoderTypist

# Functions and classes in this file are used by backup.ps1
# This file has most function and class definitions so that
# backup.ps1 can have the "actual script"
#
# FUNCTIONS:
# - formatPath
# - getName
# 
# CLASSES:
# - Backup

function formatPath ($path) {

    if ( !$path ) { return $null }

    if ( $path[$path.length-1] -ne '\' -and $path[$path.length-1] -ne '/' ) {
        $path += '\'
    }

    $path
}

# extracts the file/directory name from the path
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

class Backup{

    [string]$backupName   # name of backup option
    [string]$baseName     # backup will be located in the directory with this name
    [string]$dest         # directory containing the backup will be here
    [int]$numBackups      # max number of backups to keep
    [System.Collections.ArrayList]$itemsToCopy   # items to copy

    Backup([string]$backupName, [string]$baseName, [string]$dest, [int]$numBackups) {

        $this.itemsToCopy = @()
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
        $this.dest = formatPath $this.dest
        $this.dest += $this.baseName
        $this.dest = formatPath $this.dest
    }

    [void] add([string]$item){
        ($this.itemsToCopy).add($item)
    }

    [void] createBackup() {

        Write-Host "`n  Beginning backup..."
        Write-Host "  $($this.backupName)`n"

        # attempt to create the destination folder if it does not exist
        if( !(Test-Path $this.dest -PathType container) ) {
            md $this.dest -erroraction 'silentlycontinue'

            if ( $false -eq $? ) {
                Write-Host "`n Unable to create destination folder`n"
                exit
            }
        }

        # path to the zip file
        $zip_dest = $this.dest + "temp.zip"

        # recovery from failed backup attempt
        if ( Test-Path "$zip_dest" -PathType leaf ) {
            rm $zip_dest
        }

        $remove = @()
        # remove empty directories from the list of items to copy
        # remove non-existent files and directories from the list of items to copy
        foreach ( $item in $this.itemsToCopy ) {
            
            # if the item does not exist
            if ( !(Test-Path $item) ) { $remove += $item }

            # if the item is an empty directory directory
            elseif ( ( Test-Path $item -PathType container ) -and (dir $item | Measure-Object).count -eq 0 ) {
                $remove += $item
            }
        }
        
        foreach ( $item in $remove ) { $this.itemsToCopy.remove($item) }

        # list of previous backups
        [string[]]$savedBackups = ls $this.dest | % { $_.name }

        # create the new backup
        $argHash = @{ zip_dest = $zip_dest }

        Start-Job -name "Zip" -ScriptBlock {

            $hash = $args[0]
            $items = $args[1]
            Compress-Archive  $items $hash["zip_dest"]

        } -ArgumentList $argHash, $this.itemsToCopy

        Wait-Job -name "Zip"s
        Receive-Job -name "Zip"

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
        mv "$($this.dest)temp.zip" "$($this.dest)$($this.numify($newNum))_$($this.baseName)${date}.zip"

        Write-Host "  Backup complete`n"
    }

    # returns true if all of the items in $itemsToCopy exist
    [bool] canBackup() {

        foreach ( $item in $this.itemsToCopy ) {

            if ( Test-Path $item -PathType leaf ) { return $true }
            elseif ( (Test-Path $item -PathType container) -and (dir $item | Measure-Object).count -ne 0 ) { return $true }
        }
        return $false
    }

    # ensures that a string representation of number with a length of 2 is returned
    # if $num == 2, numify will return "02"
    # numBackups must be > 0 and < 100 (the constructor ensures this)
    hidden [string] numify([int]$num) {

        if ( $num -gt 9 ) { return [string]$num }
        return "0${num}"
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

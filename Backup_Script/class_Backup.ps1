
# author: Christian Bargraser
# https://github.com/CoderTypist

# Functions and classes in this file are used by backup.ps1
# This file has most function and class definitions so that
# backup.ps1 can have the "actual script"
#
# FUNCTIONS:
# - formatPath
# - getName
# = expand
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
        $this.dest = formatPath $this.dest

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

    # four types of files are created:
    #
    # 1 - empty direcotires
    # 2 - .zip
    # 3 - .copy.zip
    # 4 - .item.zip
    #
    # Here are some examples that following the following format:
    # uncompressed -> result (potentially compressed) and naming convention
    #
    # 1 - empty directory -> new empty directory with the same name is created
    #   - This is done because empty directories cannot be zipped
    # 2 - non-empty directory -> .zip file
    # 3 - .zip file -> .copy.zip
    #   - This is done so that .zip file is not decompressed when expanding the backup
    # 4 - file -> .item.zip
    #   - Decompressed files will be treated differently than compressed directories
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

                    # If the item is a zip file
                    # Avoid putting a zip folder inside of a zip folder
                    if ( $hash["item"] -match "^*\.zip$" ) {

                        $zipName = getName( $hash["item"].substring(0, $hash["item"].lastIndexOf(".zip")) )
                        $zipName += ".copy.zip"
                        cp $hash["item"] "$loc$zipName"
                    }

                    # if the item is not a zip file
                    else {
                        $zip += ".item.zip"
                        Compress-Archive $hash["item"] $zip
                    }
                }

            } -ArgumentList $argHash > $null
            Wait-Job -name "ZipItem" > $null

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

# Properly expands a backup
# The name of the backup directory will be exracted from $backup_path
# A folder with that name will be created in $expand_path
# Contents from the backup will be placed in that directory
function expand ([string]$backup_path, [string]$expand_path) {

    # must provide 2 arguments
    if ( !$backup_path -or !$expand_path ) {
        echo "`nTwo arguments must be provided"
        echo ".\backup expand <path_of_backup> <place_expanded_backup_in_this_directory>`n"
        exit
    }

    $backup_path = Resolve-Path $backup_path

    # first directory must exist
    if ( !(Test-Path $backup_path -PathType container) ) {
        echo "`n${backup_path}: No such directory"
        echo "<backup_path> must already exist`n"
        exit
    }

    $expand_path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($expand_path)
    $backup_dir_name = getName $backup_path
    $expand_path = formatPath $expand_path
    $expand_path += $backup_dir_name
    $expand_path += "_EXPANDED"
    $expand_path = formatPath $expand_path

    # if the destination folder already exists, do not expand the backup
    if ( Test-Path $expand_path -PathType container ) {
        
        echo "`n${expand_path}: A directory with this name already exists"
        echo "Unable to expand the backup`n"
        exit
    }

    # attempt to create the destination directory
    md $expand_path -erroraction 'silentlycontinue' > $null

    if ( $false -eq $? ) {
        Write-Host "`n Unable to create $expand_path`n"
        exit
    }

    $contents = dir $backup_path | % { $_.FullName }

    # if the specified backup directory is empty
    if ( $contents.length -eq 0 ) { 
        Write-Host "`n  The specified backup directory was empty"
        Write-Host "  Expansion complete`n"
        exit
    }

    Write-Host "`n  Beginning expansion..."
    Write-Host "  $($backup_dir_name)`n"
    
    foreach ( $item in $contents ) {

        $item_name = getName $item
        $new_name = $null

        # if a directory (was an empty folder)
        if ( Test-Path $item -PathType container ) {
            md "$expand_path$item_name" > $null
        }

        # if .copy.zip (was originally a .zip file renamed to end in .copy.zip)
        elseif ( $item -match "^*\.copy.zip$" ) {

            $new_name = $item_name.substring(0,$item_name.lastIndexOf(".copy.zip"))
            cp $item "$expand_path${new_name}.zip"
        }        

        # if .item.zip (was a single file that was zipped)
        elseif ( $item -match "^*\.item.zip$" ) {

            $new_name = $item_name.substring(0,$item_name.lastIndexOf(".item.zip"))

            $argHash = @{ item = $item; expand_path = $expand_path }
            Start-Job -name "ExpandItem" -ScriptBlock {
                $hash = $args[0]
                Expand-Archive $hash["item"] $hash["expand_path"]
            } -ArgumentList $argHash > $null
            Wait-Job -name "ExpandItem" > $null
        }

        # if .zip (was a directory that was not empty that was zipped)
        elseif ( $item -match "^*\.zip$" ) {

            $new_name = $item_name.substring(0,$item_name.lastIndexOf(".zip"))
            md $expand_path$new_name > $null

            $argHash = @{ item = $item; expand_path = $expand_path; new_name = $new_name }
            Start-Job -name "ExpandDir" -ScriptBlock {
                $hash = $args[0]
                Expand-Archive $hash["item"] ( $hash["expand_path"] + $hash["new_name"] )
            } -ArgumentList $argHash > $null
            Wait-Job -name "ExpandDir" > $null
        }

        # An unexpected type of file
        # Nothing will be done with this file
        else {
            echo ""; Write-Warning "${item}: Unexpected file`nThis file will be ignored"; echo ""
        }
    }

    Write-Host "`n  Expansion complete`n"
}

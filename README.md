# Backup Script


### Set up


Make sure that backup.ps1 and class_Backup.ps1 are in the same directory.


Ideally, you would place the files on your external storage device. 


### Usage


List all backup options


`.\backup options`


Create a backup


`.\backup <option>`


### Default backup location


Default backup location is D:\Backups\


This can be changed by modifying $dest in backup.ps1


### backup.ps1


Contains two default backup options.


Any custom backup options would be placed in this file.


### class_Backup.ps1


This file contains functions and class definitions.


This file should not be modified.


### Creating a new backup option


New backup options will be added in backup.ps1


All backup options must be added to $all_Backups


`[Backup]::new( <1>, <2>, <3>, <4> )`


1 - Backup option name


2 - Create backup in a zip file with this name (do not include .zip)


3 - Create the zip file containing the backup (<2>) in this directory (<3>)


4 - Maximum number of backups to keep


Example:


```
$backup_Docs = [Backup]::new( "Docs", "Documents_$env:ComputerName", "D:\Backups", 4 )
$backup_Docs.add("C:\Users\$env:UserName\Documents") 
$all_Backups += $backup_Docs
```
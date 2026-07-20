<# 
.SYNOPSIS
    Lists VM files on Datastore
.DESCRIPTION
    Does not work if split vmdks across datastores or sub directories.
.EXAMPLE
    .\GET-VMdatastoreFiles.ps1 TEST-VM
.NOTES
    Author: VirtualDataPro
    Version: 1.0 MAR 2017
#>

param(
    [parameter(mandatory = $true)]
    [string[]]$VMname
    )

Get-VM $VMname | %{((Get-Datastore (($_ | get-view).layout.disk.diskfile | ForEach-Object{$_.split("[]",3) | Select-Object -Skip 1 | Select-Object -SkipLast 1} | Select-Object -Unique)).DatastoreBrowserPath + "\" + (($_ | get-view).layout.disk.diskfile | ForEach-Object{$_.split("]/",3) | Select-Object -SkipLast 1 | Select-Object -Skip 1} | Select-Object -Unique).trim("")) | Get-ChildItem | Select-Object Name,Length,LastWriteTime}
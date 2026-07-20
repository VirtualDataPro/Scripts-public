<# 
.SYNOPSIS
 Checks ESXi Host lun paths for Dead Path scenerio.
.DESCRIPTION
 Created to check and look for Paths that are not "active". If paths are found, they are listed for that host.
.EXAMPLE
 .\GET-DeadPath.ps1  <ESXi Name>
 or
 .\GET-DeadPath.ps1 *
.NOTES
 Author: VirtualDataPro
 Version: 1.0 May 2016
#>

param(
    [parameter(Mandatory = $true)]
    [string[]]$Param
    )


$VHs = Get-VMHost $Param -State Connected

ForEach ($VH in $VHs){
 $VHcli = $VH | Get-ESXcli
 Write-Host "Checking "$VH.name" for Dead Path" 
 $VHcli.storage.core.path.list() | ?{$_.state -ne "active"}
}
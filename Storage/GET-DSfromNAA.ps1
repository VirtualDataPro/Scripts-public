<# 
.SYNOPSIS
    Finds Datastore with matching $NAA
.DESCRIPTION
    
.EXAMPLE
    .\GET-DSfromNAA.ps1 naa.60000000393649834638393
.NOTES
    Author: VirtualDataPro
    Version: 1.0 FEB 2017
#>

param(
    [parameter(mandatory = $true)]
    [string[]]$NAA
    )

get-datastore | where{$_.ExtensionData.Info.Vmfs.Extent.Diskname -match $NAA}
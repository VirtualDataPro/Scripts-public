<# 
.SYNOPSIS
    Displays NAA identifier for cluster datastores
.DESCRIPTION
    
.EXAMPLE
    .\GET-ClusterNAA.ps1 ClusterName
.NOTES
    Author: VirtualDataPro
    Version: 1.0 JUL 2013
#>
param(
    [parameter(mandatory = $true)]
    [string[]]$ClusterName
    )

Get-Cluster $ClusterName | Get-VMHost | Get-Datastore | Select-Object Name,@{N="DiskName";E={$_.ExtensionData.Info.Vmfs.Extent.DiskName}}

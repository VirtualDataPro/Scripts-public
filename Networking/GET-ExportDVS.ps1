#####################################################################
#Migration from 5.0 to new 5.5 vCenter Deployment
#Export DvS Portgroups
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################
param(
    [parameter(Mandatory = $true)]
    [string[]]$Cluster    
    )

#$Export = "D:\Scripts\DVS.csv"

Get-Cluster $Cluster | Get-VMHost | Get-VDSwitch | Get-VDPortGroup | ?{$_.IsUplink -ne $true} | Select Name,NumPorts,VDSwitch,@{N="Vlan";E={$_.VlanConfiguration.VlanId}} | Export-CSV $Cluster"DVS.csv" -UseCulture -NoTypeInformation

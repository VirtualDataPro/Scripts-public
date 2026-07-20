#####################################################################
#Migration from 5.0 to new 5.5 vCenter Deployment
#
#Export DvS Portgroups
#
#
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################
param(
    [parameter(Mandatory = $true)]
    [string[]]$Cluster	
	)

$Export = "D:\Scripts\6.0 Migration\"+$Cluster+"-DVS.csv"

Get-Cluster $Cluster | Get-VMHost | Get-VDSwitch | Get-VDPortGroup | ?{$_.VlanConfiguration.VlanType -ne "Trunk"} | Select Name,NumPorts,VDSwitch,@{N="Vlan";E={$_.VlanConfiguration.VlanId}} | Export-CSV $Export -UseCulture -NoTypeInformation
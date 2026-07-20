#####################################################################
#Migration from 5.0 to new 6.0 vCenter Deployment
#
#Import DvS
#
#**NOTE You must add the DvS and Cluster First
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$Cluster	
	)

$Import = "D:\Scripts\6.0 Migration\"+$Cluster+"-DVS.csv"

$PGs = Import-CSV $Import -UseCulture

#$VDSwitch = Get-Cluster $Cluster | Get-VMhost | Get-VDSwitch
$VDSwitch = Get-VDSwitch Org*



#Add PGs to DvS
ForEach($PG in $PGs){$VDSwitch | New-VDPortgroup -Name $PG.Name -NumPorts $PG.NumPorts -VlanId $PG.Vlan}
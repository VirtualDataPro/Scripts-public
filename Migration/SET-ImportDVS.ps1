#####################################################################
#Migration from 5.0 to new 5.5 vCenter Deployment
#
#Import DvS
#
#**NOTE You must add the DvS and Cluster First
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$Switch,

	[Parameter(Mandatory=$True)]
    [string]$Import    
    )



$PGs = Import-CSV $Import -UseCulture

#$VDSwitch = Get-Cluster $Cluster | Get-VMhost | Get-VDSwitch
$VDSwitch = Get-vdswitch $switch

#Add PGs to DvS
ForEach($PG in $PGs){$VDSwitch | New-VDPortgroup -Name $PG.Name -NumPorts $PG.NumPorts -VlanId $PG.Vlan}
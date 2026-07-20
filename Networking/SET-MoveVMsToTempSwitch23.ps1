#####################################################################
#Migration from 5.0 to new 6 vCenter Deployment
#Cluster Prep for Host Migrations
#Creating Temporary vSwitch & Portgroups
#Migrate Uplink to SvS
#
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$Cluster
	)

$TempVSwitch = "Temp-vSwitch"

#Identify vmnicX on hosts to migrate to SvS
$vNIC = "vmnic3"

#####################################################################

#Get Hosts
$cHosts = Get-Cluster $Cluster | Get-VMHost
#$cHosts = Get-VMHost $Cluster
	
#Get VM Network Adapters
$VMNAs = $cHosts | Get-VM | Get-NetworkAdapter

#Migrate vmnic Uplinks from DvS to SvS 
ForEach($cHost in $cHosts){
	$cHostNA = $cHost | Get-VMHostNetworkAdapter -Name $vNIC
	$cHostNA | Remove-VDSwitchPhysicalNetworkAdapter -confirm:$false
	$cHost | Get-VirtualSwitch -Name $TempVSwitch | Add-VirtualSwitchPhysicalNetworkAdapter $cHostNA -confirm:$false
}

#Migrating VM Network Adapters to vSwitch
ForEach($VMNA in $VMNAs){
	$TempName = $VMNA.NetworkName + "VVV"
	Set-NetworkAdapter $VMNA -NetworkName $TempName -confirm:$false
}

#####################################################################
################ Remove DvS From Host         #######################
################ Remove Host From vCenter 5.0 #######################
################ Add Host to New vCenter 5.5  #######################
#####################################################################





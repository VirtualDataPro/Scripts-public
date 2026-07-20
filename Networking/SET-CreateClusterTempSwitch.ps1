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

#Name the Temporary vSwitch	
$TempVSwitch = "Temp-vSwitch"

#####################################################################

#Get Hosts
$cHosts = Get-Cluster $Cluster | Get-VMHost
#$cHosts = Get-VMHost $Cluster
	
#Create Temp vSwitch
$cHosts | New-VirtualSwitch -Name $TempVSwitch -NumPorts 128
ForEach($cHost in $cHosts){
	$PGs = $cHost | Get-VM | Get-NetworkAdapter | Get-VDPortgroup
	ForEach($PG in $PGs){
		$TempName = $PG.Name + "VVV"
		$cHostSvS = $cHost | Get-VirtualSwitch | ?{$_.Name -eq $TempVSwitch}
		$SvSpg = $cHostSvS | Get-VirtualPortgroup -Name $TempName -ErrorAction SilentlyContinue
		If(!$SvSpg){
			$cHostSvS | New-VirtualPortgroup -Name $TempName -VlanID $PG.VlanConfiguration.VlanId
		}
	}
}

#####################################################################
################ Move VMs to SvS              #######################
################ Remove DvS From Host         #######################
################ Remove Host From vCenter 5.0 #######################
################ Add Host to New vCenter 5.5  #######################
#####################################################################





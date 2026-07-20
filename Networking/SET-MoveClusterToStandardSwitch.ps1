#####################################################################
# Migration from 5.X to 6.X vCenter Deployment
# Create Temporary vSwitch and Migrate VMs from a Distributed Switch
#
#	- Cluster Prep for Host Migrations
#	- Create Temporary vSwitch & Portgroups
#	- Migrate a single Distributed Switch(DvS) Uplink to the Temporary vSwitch(SvS)
#	- Migrate VMs on DvS to SvS
#
# Version v1.2 Updated (Aug 2016) VirtualDataPro
# Check Get-VDSwitch <VDSwitch to Migrate> | Get-VMHostNetworkAdapter
#####################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$Cluster,
	
	#Moved vmnic identification to required parameter
	[Parameter(Mandatory=$true)]
    [string]$vmnic
    )

#Name the Temporary vSwitch to be created    
$TempVSwitch = "Temp-vSwitch"

#Identify vmnicX on hosts to migrate to SvS
#$vmnic = "vmnicX"

#####################################################################

#Get Hosts
$ClusterHosts = Get-Cluster $Cluster | Get-VMHost
    
#Create Temp vSwitch    
$ClusterHosts | New-VirtualSwitch -Name $TempVSwitch -NumPorts 128

<#No longer required
#Get Portgroups from DvS
#$PortGroups = $ClusterHosts | Get-VDSwitch | Get-VDPortgroup | ?{$_.IsUplink -eq $false}
#$PortGroups = $ClusterHosts | Get-VDSwitch | Get-VDPortGroup | ?{$_.VlanConfiguration.VlanType -ne "Trunk"}
#>

#Create Portgroups on Temp vSwitch only using the required portgroups to reduce port consumption.
ForEach($cHost in $ClusterHosts){
	$PortGroups = $cHost | Get-VM | Get-NetworkAdapter | Get-VDPortgroup
	$PortGroups | %{$cHost | Get-VirtualSwitch -Name $TempVSwitch | New-VirtualPortgroup -Name ($_.Name + "VVV") -VlanID $_.VlanConfiguration.VlanId}
}

<# Old Portgroup Creation
ForEach($PG in $PortGroups){
    $TempName = $PG.Name + "VVV"
    $ClusterHosts | Get-VirtualSwitch | ?{$_.Name -eq $TempVSwitch} | New-VirtualPortgroup -Name $TempName -VlanID $PG.VlanConfiguration.VlanId -NumPorts
}
#>

#Migrate vmnic Uplinks from DvS to SvS 
ForEach($cHost in $ClusterHosts){
    $cHostNetworkAdapter = $cHost | Get-VMHostNetworkAdapter -Name $vmnic
    $cHostNetworkAdapter | Remove-VDSwitchPhysicalNetworkAdapter -confirm:$false
    $cHost | Get-VirtualSwitch -Name $TempVSwitch | Add-VirtualSwitchPhysicalNetworkAdapter $cHostNetworkAdapter -confirm:$false
}

#Get VM Network Adapters
$VMNetworkAdapters = $ClusterHosts | Get-VM | Get-NetworkAdapter

#Migrating VM Network Adapters to vSwitch
ForEach($VMNA in $VMNetworkAdapters){
    $TempName = $VMNA.NetworkName + "VVV"
    Set-NetworkAdapter $VMNA -NetworkName $TempName -confirm:$false
}

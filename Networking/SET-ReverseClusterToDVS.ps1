###############################################################################
# Migration from 5.0 to new 6 vCenter Deployment
# Migrate Host and VMs to DvS
#
#	Host must be registered in vCenter; Also, the DvS and Portgroups must created with the same name as old vCenter.
#
#	- Migrating VMs on SvS to DvS
#	- Migrate Uplink to DvS
#
# Version v1.2 Updated (AUG 2016) VirtualDataPro
###############################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$VMhost,
	
	#Moved vmnic identification to required parameter
	[Parameter(Mandatory=$True)]
    [string]$dvsvmnic,
	#Moved vmnic identification to required parameter
	[Parameter(Mandatory=$True)]
    [string]$svmnic
	)

$gHost = Get-VMHost $VMhost

#Identify Temporary vSwitch on Host	
$TempVSwitch = "Temp-vSwitch"
$HostvSwitch = $gHost | Get-VirtualSwitch -Name $TempVSwitch

#Identify vmnicX For DVS (MOVED)
#$vmnicdvs = "vmnic8"
$HostDvSvmnic = $gHost | Get-VMHostNetworkAdapter -Name $dvsvmnic

<#Identify vmnicX For current SvS
$vmnicsvs = "vmnic9"
#>

$HostvSwitchNetworkAdapter = $gHost | Get-VMHostNetworkAdapter -Name $svmnic


#$HostvSwitchNetworkAdapter = $gHost | Get-VirtualSwitch -Name $TempVSwitch | Get-VMHostNetworkAdapter

#Identify DvS Name for VM
$DvSwitchName = Read-Host -Prompt "What is the name of the Distributed Switch"
$DvSwitch = Get-VDSwitch | ?{$_.Name -eq $DvSwitchName}

###############################################################################

#Add Host to DvS
$DvSwitch | Add-VDSwitchVMHost -VMHost $gHost

#Add Host Uplink to DvS
$DvSwitch | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $HostDvSvmnic -confirm:$false

#Get VM Network Adapters and Migrate to DvS Portgroups
$VMNetworkAdapters = $gHost | Get-VM | Get-NetworkAdapter
ForEach($VMNA in $VMNetworkAdapters){Set-NetworkAdapter $VMNA -NetworkName $VMNA.NetworkName.Trim("VVV") -confirm:$false}

#Remove Uplink from SvS
#$HostvSwitch | Remove-VirtualSwitchPhysicalNetworkAdapter $HostvSwitchNetworkAdapter -confirm:$false
#Delete vSwitch
$HostvSwitch | Remove-VirtualSwitch -confirm:$false

#Add Host Uplink to DvS
$DvSwitch | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $HostvSwitchNetworkAdapter -confirm:$false


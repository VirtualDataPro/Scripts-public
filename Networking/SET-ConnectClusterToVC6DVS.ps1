#####################################################################
#Migration from 5.0 to new 5.5 vCenter Deployment
#Migrate Host and VMs to DvS
#
#Host must be registerd in vCenter, DvS, and Portgroups Created
#
#Migrating VMs on SvS to DvS
#Migrate Uplink to DvS
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$Host
	)
$gHost = Get-VMHost $Host

#Identify Temporary vSwitch on Host	
$TempVSwitch = "Temp-vSwitch"
$HvSwitch = $gHost | Get-VirtualSwitch | ?{$_.Name -eq $TempvSwitch}

#Identify DvS Name for VM
$DvSwitchName = "dvSwitchNAME"
$DvSwitch = Get-VDSwitch | ?{$_.Name -eq $DvSwitchName}

#Identify vmnicX For DVS
$vNICdvs = "vmnicX"
$gHostNAdvs = $gHost | Get-VMHostNetworkAdapter -Name $vNICdvs

#Identify vmnicX For current SvS
$vNICsvs = "vmnixX"
$gHostNAsvs = $gHost | Get-VMHostNetworkAdapter -Name $vNICsvs

#####################################################################

#Add Host Uplink to DvS
$DvSwitch | Add-VDSwitchPhysicalNetworkAdapter -Name $gHostNAdvs -confirm:$false

#Get VM Network Adapters and Migrate to DvS Portgroups
$VMNAs = $gHost | Get-VM | Get-NetworkAdapter
ForEach($VMNA in $VMNAs){Set-NetworkAdapter $VMNA -NetworkName $VMNA.NetworkName.Trim("VVV")}

#Remove Uplink from SvS
$hvSwitch | Remove-VirtualSwitchPhysicalNetworkAdapter $gHostNAsvs -confirm:$false

#Add Host Uplink to DvS
$DvSwitch | Add-VDSwitchPhysicalNetworkAdapter -Name $gHostNAsvs -confirm:$false

#Delete vSwitch
$HvSwitch | Remove-VirtualSwitch -confirm:$false
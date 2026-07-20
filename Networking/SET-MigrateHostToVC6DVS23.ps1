#####################################################################
#Migration from 5.0 to new 6 vCenter Deployment
#Migrate Host and VMs to DvS
#
#Host must be registered in vCenter, DvS, and Portgroups Created
#
#Migrating VMs on SvS to DvS
#Migrate Uplink to DvS
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$HostN
	)
$gHost = Get-VMHost $HostN

#Identify Temporary vSwitch on Host	
$TempVSwitch = "Temp-vSwitch"
$HvSwitch = $gHost | Get-VirtualSwitch | ?{$_.Name -eq $TempVSwitch}

#Identify DvS Name for VM
$DvSwitchName = "Org_dvSwitch"
$DvSwitch = Get-VDSwitch | ?{$_.Name -eq $DvSwitchName}

#Identify vmnicX For DVS
$vNICdvs = "vmnic2"
$gHostNAdvs = $gHost | Get-VMHostNetworkAdapter -Name $vNICdvs

#Identify vmnicX For current SvS
$vNICsvs = "vmnic3"
$gHostNAsvs = $gHost | Get-VMHostNetworkAdapter -Name $vNICsvs

#####################################################################

#Add Host to DvS
$DvSwitch | Add-VDSwitchVMHost -VMHost $gHost

#Add Host Uplink to DvS
$DvSwitch | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $gHostNAdvs -confirm:$false

#Get VM Network Adapters and Migrate to DvS Portgroups
$VMNAs = $gHost | Get-VM | Get-NetworkAdapter
ForEach($VMNA in $VMNAs){Set-NetworkAdapter $VMNA -NetworkName $VMNA.NetworkName.Trim("VVV") -confirm:$false}

#Remove Uplink from SvS
$hvSwitch | Remove-VirtualSwitchPhysicalNetworkAdapter $gHostNAsvs -confirm:$false

#Add Host Uplink to DvS
$DvSwitch | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $gHostNAsvs -confirm:$false

#Delete vSwitch
$HvSwitch | Remove-VirtualSwitch -confirm:$false
#####################################################################
# Set-VMstig6.ps1
# 
# This will configure VM properties per VMware_vSphere_6-0_Virtual_Machine_STIG_V1R1
# VMware vSphere Virtual Machine Version 6 Security Technical Implementation Guide 
# Version: 1 
# Release: 1 Benchmark Date: 21 Dec 2015 
#
# 
# The following Must be checked manually:
<#
#VMCH-06-000007
Get-VM | Get-HardDisk | ?{$_.Persistence -ne "Persistent" -and $_.Persistence -ne "IndependentPersistent"} | Select Parent, Name, Filename, DiskType, Persistence | FT -AutoSize
#
#VMCH-06-000028
Get-VM | Get-FloppyDrive | Remove-FloppyDrive
#Requires VM to be Powered Off
#
#VMCH-06-000029
Get-VM | Get-CDDrive | Set-CDDrive -NoMedia
#
#VMCH-06-000030
Get-VM | Where {$_.ExtensionData.Config.Hardware.Device.DeviceInfo.Label -match "parallel"}
#Manual Removal
#
#VMCH-06-000031
Get-VM | Where {$_.ExtensionData.Config.Hardware.Device.DeviceInfo.Label -match "serial"}
#Manual Removal
#
#VMCH-06-000032
Get-VM | Get-USBDevice | Remove-USBDevice
#
#VMCH-06-000040
Get-VM | Get-AdvancedSetting -Name sched.mem.pshare.salt | Remove-AdvancedSetting
#
#VMCH-06-000041
Get-VM | Get-AdvancedSetting -Name "ethernet*.filter*.name*" | Remove-AdvancedSetting
#
#VMCH-06-000043
#The system must use hardened & patched templates to deploy VMs whenever possible.
#
#VMCH-06-000044
#The system must minimize use of the VM console. If a VM console is used to perform VM management tasks, other than for troubleshooting VM issues, this is a finding.
#>
#
# USE EXAMPLE:
# .\Set-VMstig6.ps1 NameOfVM
#
# Removing the Parameter and the $VMname will result in the configuration of all VMs in the connected vCenter.
#
# NOTE: This Stig Should be applied to all Templates this will require you to convert existing Templates to a VM then apply the STIG. Applying the STIG after a VM is created from a Template is not sufficient to comply with the STIG. 
#
# v1.3 JAN 2014 (Updated JAN 2016)
# Author: VirtualDataPro
#####################################################################

param(
 [parameter(Mandatory = $true)]
 [string[]]$VMname
 )

 $VMs = Get-VM $VMname
 
 $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
 $spec.tools = New-Object VMware.Vim.ToolsConfigInfo

 #VMCH-06-000001
 $extra1 = New-Object VMware.Vim.OptionValue
 $extra1.Key = "isolation.tools.copy.disable"
 $extra1.Value = "true"
 $spec.ExtraConfig += $extra1
 
 #VMCH-06-000002
 $extra2 = New-Object VMware.Vim.OptionValue
 $extra2.Key = "isolation.tools.dnd.disable"
 $extra2.Value = "true"
 $spec.ExtraConfig += $extra2
 
 #VMCH-06-000003
 $extra3 = New-Object VMware.Vim.OptionValue
 $extra3.Key = "isolation.tools.setGUIOptions.enable"
 $extra3.Value = "false"
 $spec.ExtraConfig += $extra3
 
 #VMCH-06-000004
 $extra4 = New-Object VMware.Vim.OptionValue
 $extra4.Key = "isolation.tools.paste.disable"
 $extra4.Value = "true"
 $spec.ExtraConfig += $extra4
 
 #VMCH-06-000005
 $extra5 = New-Object VMware.Vim.OptionValue
 $extra5.Key = "isolation.tools.diskShrink.disable"
 $extra5.Value = "true"
 $spec.ExtraConfig += $extra5
 
 #VMCH-06-000006
 $extra6 = New-Object VMware.Vim.OptionValue
 $extra6.Key = "isolation.tools.diskWiper.disable"
 $extra6.Value = "true"
 $spec.ExtraConfig += $extra6
 
 #VMCH-06-000008
 $extra8 = New-Object VMware.Vim.OptionValue
 $extra8.Key = "isolation.tools.hgfsServerSet.disable"
 $extra8.Value = "true"
 $spec.ExtraConfig += $extra8
 
 #VMCH-06-000009
 $extra9 = New-Object VMware.Vim.OptionValue
 $extra9.Key = "isolation.tools.ghi.autologon.disable"
 $extra9.Value = "true"
 $spec.ExtraConfig += $extra9
 
 #VMCH-06-000010
 $extra10 = New-Object VMware.Vim.OptionValue
 $extra10.Key = "isolation.bios.bbs.disable"
 $extra10.Value = "true"
 $spec.ExtraConfig += $extra10
 
 #VMCH-06-000011
 $extra11 = New-Object VMware.Vim.OptionValue
 $extra11.Key = "isolation.tools.getCreds.disable"
 $extra11.Value = "true"
 $spec.ExtraConfig += $extra11
 
 #VMCH-06-000012
 $extra12 = New-Object VMware.Vim.OptionValue
 $extra12.Key = "isolation.tools.ghi.launchmenu.change"
 $extra12.Value = "true"
 $spec.ExtraConfig += $extra12
 
 #VMCH-06-000013
 $extra13 = New-Object VMware.Vim.OptionValue
 $extra13.Key = "isolation.tools.memSchedFakeSampleStats.disable"
 $extra13.Value = "true"
 $spec.ExtraConfig += $extra13
 
 #VMCH-06-000014
 $extra14 = New-Object VMware.Vim.OptionValue
 $extra14.Key = "isolation.tools.ghi.protocolhandler.info.disable"
 $extra14.Value = "true"
 $spec.ExtraConfig += $extra14
 
 #VMCH-06-000015
 $extra15 = New-Object VMware.Vim.OptionValue
 $extra15.Key = "isolation.ghi.host.shellAction.disable"
 $extra15.Value = "true"
 $spec.ExtraConfig += $extra15
 
 #VMCH-06-000016
 $extra16 = New-Object VMware.Vim.OptionValue
 $extra16.Key = "isolation.tools.dispTopoRequest.disable"
 $extra16.Value = "true"
 $spec.ExtraConfig += $extra16
 
 #VMCH-06-000017
 $extra17 = New-Object VMware.Vim.OptionValue
 $extra17.Key = "isolation.tools.trashFolderState.disable"
 $extra17.Value = "true"
 $spec.ExtraConfig += $extra17
 
 #VMCH-06-000018
 $extra18 = New-Object VMware.Vim.OptionValue
 $extra18.Key = "isolation.tools.ghi.trayicon.disable"
 $extra18.Value = "true"
 $spec.ExtraConfig += $extra18
 
 #VMCH-06-000019
 $extra19 = New-Object VMware.Vim.OptionValue
 $extra19.Key = "isolation.tools.unity.disable"
 $extra19.Value = "true"
 $spec.ExtraConfig += $extra19
 
 #VMCH-06-000020
 $extra20 = New-Object VMware.Vim.OptionValue
 $extra20.Key = "isolation.tools.unityInterlockOperation.disable"
 $extra20.Value = "true"
 $spec.ExtraConfig += $extra20
 
 #VMCH-06-000021
 $extra21 = New-Object VMware.Vim.OptionValue
 $extra21.Key = "isolation.tools.unity.push.update.disable"
 $extra21.Value = "true"
 $spec.ExtraConfig += $extra21
 
 #VMCH-06-000022
 $extra22 = New-Object VMware.Vim.OptionValue
 $extra22.Key = "isolation.tools.unity.taskbar.disable"
 $extra22.Value = "true"
 $spec.ExtraConfig += $extra22
 
 #VMCH-06-000023
 $extra23 = New-Object VMware.Vim.OptionValue
 $extra23.Key = "isolation.tools.unityActive.disable"
 $extra23.Value = "true"
 $spec.ExtraConfig += $extra23
 
 #VMCH-06-000024
 $extra24 = New-Object VMware.Vim.OptionValue
 $extra24.Key = "isolation.tools.unity.windowContents.disable"
 $extra24.Value = "true"
 $spec.ExtraConfig += $extra24
 
 #VMCH-06-000025
 $extra25 = New-Object VMware.Vim.OptionValue
 $extra25.Key = "isolation.tools.vmxDnDVersionGet.disable"
 $extra25.Value = "true"
 $spec.ExtraConfig += $extra25
 
 #VMCH-06-000026
 $extra26 = New-Object VMware.Vim.OptionValue
 $extra26.Key = "isolation.tools.guestDnDVersionSet.disable"
 $extra26.Value = "true"
 $spec.ExtraConfig += $extra26
 
 #VMCH-06-000027
 $extra27 = New-Object VMware.Vim.OptionValue
 $extra27.Key = "isolation.tools.vixMessage.disable"
 $extra27.Value = "true"
 $spec.ExtraConfig += $extra27
 
 #VMCH-06-000033
 $extra33 = New-Object VMware.Vim.OptionValue
 $extra33.Key = "RemoteDisplay.maxConnections"
 $extra33.Value = "1"
 $spec.ExtraConfig += $extra33
 
 #VMCH-06-000034
 $extra34 = New-Object VMware.Vim.OptionValue
 $extra34.Key = "RemoteDisplay.vnc.enabled"
 $extra34.Value = "false"
 $spec.ExtraConfig += $extra34
 
 #VMCH-06-000035
 $extra35 = New-Object VMware.Vim.OptionValue
 $extra35.Key = "isolation.tools.autoInstall.disable"
 $extra35.Value = "true"
 $spec.ExtraConfig += $extra35
 
 #VMCH-06-000036
 $extra36 = New-Object VMware.Vim.OptionValue
 $extra36.Key = "tools.setinfo.sizeLimit"
 $extra36.Value = "1048576"
 $spec.ExtraConfig += $extra36
 
 #VMCH-06-000037
 $extra37 = New-Object VMware.Vim.OptionValue
 $extra37.Key = "isolation.device.connectable.disable"
 $extra37.Value = "true"
 $spec.ExtraConfig += $extra37
 
 #VMCH-06-000038
 $extra38 = New-Object VMware.Vim.OptionValue
 $extra38.Key = "isolation.device.edit.disable"
 $extra38.Value = "true"
 $spec.ExtraConfig += $extra38
 
 #VMCH-06-000039
 $extra39 = New-Object VMware.Vim.OptionValue
 $extra39.Key = "tools.guestlib.enableHostInfo"
 $extra39.Value = "false"
 $spec.ExtraConfig += $extra39
 
ForEach($VM in $VMs){
 $vm.ExtensionData.ReconfigVM($spec)
}
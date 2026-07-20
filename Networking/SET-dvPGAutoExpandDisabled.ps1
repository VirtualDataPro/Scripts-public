<#
.SYNOPSIS
    Disables AutoExpand on all dvPortgroups
.DESCRIPTION
    Created to comply with DoD VMware ESXi Server 5.0 Security Technical
Implementation Guide :: Release: 9 Benchmark Date: 22 Apr 2016
    Rule Title: The system must disable the autoexpand option for VDS
dvPortgroups.
    STIG ID:    ESXI5-VMNET-000026
    Rule ID:    SV-51238r3_rule
    Vuln ID:    V-39380
    Severity:   CAT III
    Class:      Unclass
.EXAMPLE
    .\SET-dvPGAutoExpandDisable.ps1
.NOTES
    Author: VirtualDataPro
    Version: 1.1 AUG 2016
#>

Get-VDPortgroup | ?{$_.IsUplink -eq $false} | %{
                $dvPG = Get-View $_
                Write-Host "Disabling AutoExpand for dvPortgroup:
$($dvPG.Name)"
        $spec = New-Object VMware.Vim.DVPortgroupConfigSpec
        $spec.AutoExpand = $false
        $spec.ConfigVersion = $dvPG.Config.ConfigVersion
        $dvPG.ReconfigureDVPortgroup_Task($spec)
        $dvPG.UpdateViewData()
 }
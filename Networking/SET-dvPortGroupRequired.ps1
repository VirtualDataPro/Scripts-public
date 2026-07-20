<#
.SYNOPSIS
    Sets the minimum required ports for all dvPortgroups
.DESCRIPTION
    Created to comply with DoD VMware ESXi Server 5.0 Security Technical
Implementation Guide :: Release: 9 Benchmark Date: 22 Apr 2016
    Rule Title: The system must ensure there are no unused ports on a
distributed virtual port group.
    STIG ID:    ESXI5-VMNET-000020
    Rule ID:    SV-51235r3_rule
    Vuln ID:    V-39377
    Severity:   CAT III
    Class:      Unclass
.EXAMPLE
    .\SET-dvPortgroupRequired.ps1
.NOTES
    Author: VirtualDataPro
    Version: 1.1 JUL 2015
#>

Get-VDPortgroup | ?{$_.IsUplink -eq $false} | %{
    $reqports = (Get-VDPort -ConnectedOnly -VDPortgroup $_).count
    $_ | Set-VDPortgroup -NumPorts $reqports
}

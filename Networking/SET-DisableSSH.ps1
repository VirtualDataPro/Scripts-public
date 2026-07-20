<#
.SYNOPSIS
    Disables the SSH service on the ESXi Host
.DESCRIPTION
    Created to comply with DoD VMware ESXi Server 5.0 Security Technical
Implementation Guide :: Release: 9 Benchmark Date: 22 Apr 2016
    Rule Title: The system must disable ESXi Shell unless needed for
diagnostics or troubleshooting.
    STIG ID:    SRG-OS-99999-ESXI5-000136
    Rule ID:    SV-51111r1_rule
    Vuln ID:    V-39295
    Severity:   CAT II
    Class:      Unclass
.EXAMPLE
    .\SET-DisableSSH.ps1 *
.NOTES
    Author: VirtualDataPro
    Version: 1.1 JUL 2015
#>

Param(
 [parameter(Mandatory = $true)]
 [string[]]$vHostName
 )

Get-VMHost $vHostName | %{
        Stop-VMHostService -HostService ($_ | Get-VMHostService | ?{$_.Key.Contains("SSH")}) -Confirm:$false
}

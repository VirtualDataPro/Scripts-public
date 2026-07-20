<#
.SYNOPSIS
    Enables Lockdown Mode on the ESXi Host
.DESCRIPTION
    Created to comply with DoD VMware ESXi Server 5.0 Security Technical
Implementation Guide :: Release: 9 Benchmark Date: 22 Apr 2016
    Rule Title: The system must enable lockdown mode to restrict remote
access.
    STIG ID:    SRG-OS-000092-ESXI5
    Rule ID:    SV-51243r2_rule
    Vuln ID:    V-39385
    Severity:   CAT II
    Class:      Unclass
.EXAMPLE
    .\SET-EnableLockdownMode.ps1 *
.NOTES
    Author: VirtualDataPro
    Version: 1.1 JUL 2015
#>

Param(
 [parameter(Mandatory = $true)]
 [string[]]$vHostName
 )

$Scope = Get-VMHost $vHostName

foreach ($ESXhost in $Scope) {
        (get-vmhost $ESXhost | get-view).EnterLockdownMode()
}

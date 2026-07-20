<#
.SYNOPSIS
    Restart vpxa for Not Responding ESXi hosts
.DESCRIPTION
    Created to restart vpxa after a network failure. vpxa service may be hung ad require a restart to connect back to vcenter. This will check a cluster for ESXi Hosts Not Responding. Then attempt to connect directly to the hosts and restart the service for each host Not Responding. 
.EXAMPLE
    .\SET-RestartClusterNotRespondingVPXA.ps1 Cluster1
.NOTES
    Author: VirtualDataPro
    Version: 1.0 MAR 2021
#>

Param(
 [parameter(Mandatory = $true)]
 [string[]]$vCluster
 )
 
$NRhosts = Get-cluster $vCluster | Get-VMhost -State NotResponding

write-host "Enter root credentials for the affected cluster's ESXi Hosts"

$creds = get-credential

Disconnect-VIServer * -Confirm:$false

ForEach($NRhost in $NRhosts){
	Connect-VIServer $NRhost.name -credential $creds
	Get-VMhost | Get-VMHostService | ?{$_.Label -eq "VMware vCenter Agent"} | Restart-VMHostService -Confirm:$False
	Disconnect-VIServer * -Confirm:$false
}
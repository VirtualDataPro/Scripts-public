#Cisco Cluster Rolling Reboot
#Author VirtualDataPro 


param(
    [parameter(Mandatory = $true)]
    [string[]]$ClusterName
    )
	
$Cluster = Get-Cluster $ClusterName | Get-VMHost

ForEach($Host in $Cluster){
	$gHost = Get-VMHost $Host
	$gHost | Foreach {$_.EnterMaintenanceMode_Task($TRUE)}
	
	$gHost | Foreach {$_.RebootHost_Task($TRUE)}
	}
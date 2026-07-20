<#
.SYNOPSIS
    Completely power off the VMware datacenters logged into.
.DESCRIPTION
    The script was written for Tulane University to shut down the datacenter in the event of an emergency. It will shutdown all virtual Machines cleanly
.EXAMPLE
    .\SET-EmergencyDatacenterShutdown.ps1
.NOTES
    Author: VirtualDataPro
#>

#Connected Esxi Hosts
$ESXSRV = Get-VMHost

#Save Datacenter Export
$DC = Get-Datacenter
$DT = Get-Date -Format ddMMMyy@HHMM
$exportloc = ".\Reports\"+$DC.Name+"-ShutDownReport-"+$DT+".csv"
$exportloc
Write-Host "Exporting current power state and vm location to "+$exportloc+" ..."
$VMlist = $ESXSRV | Get-VM
$VMlist | Select Name, PowerState, VMhost | Export-Csv $exportloc -UseCulture -NoTypeInformation

#Filter Objects
$Stage1VMs = $VMlist | ?{$_.name -notmatch "vcenter|psc|dsm1p03" -and $_.PowerState -eq "PoweredOn"}
$Stage2VMs = Get-VM | ?{$_.name -match "vcenter|psc|dsm1p03"}
$Stage2ESXi = $Stage2VMs.VMHost
$Stage2ESXi | %{$HostFilter = $_.Name+"|"+$HostFilter}
$Stage1ESXi = $ESXSRV | ?{$_.name -notmatch $HostFilter.trim("|")}

#Shutdown GuestOS gracefully if VMtools is running.
Foreach ($VM in $Stage1VMs){
    IF(($VM | Get-view).Guest.ToolsRunningStatus -eq "guestToolsRunning"){
        $VM | Shutdown-VMGuest -Confirm:$false
    }
}

#Set the amount of time to wait before assuming the remaining powered on guests are stuck
$TimeOUT = 300 #Seconds
$TimeINT = (Get-Date).TimeOfDay

#Wait for the VMs to be Shutdown cleanly
do {
    sleep 1.0
    $numvms = ($ESXSRV | Get-VM | ?{ $_.PowerState -eq "poweredOn" }).Count
    $Timer = $TimeOUT - [INT]((Get-Date).TimeOfDay - $TimeINT).TotalSeconds
    Write-Host "Waiting for shutdown of $numvms VMs.  $Timer seconds left..."
    } until ($Timer -le 0)

#Stuck VM Shutdown
Foreach ($VM in ($Stage1VMs | Get-VM | ?{$_.PowerState -eq "PoweredOn"})){
    write-host ""
    write-host "unable to shutdown $VM.Name guest cleanly. Initiating Forced Power Off!" -foregroundcolor red
    write-host ""

    $VM | ?{$_.PowerState -eq "PoweredOn"} | Stop-VM -Confirm:$false
}

$Stage2VMs | Select Name,PowerState,VMHost

# Shutdown the ESX Hosts
$Stage1ESXi | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)}
$Stage2ESXi | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)}

Write-Host "Shutdown Complete"
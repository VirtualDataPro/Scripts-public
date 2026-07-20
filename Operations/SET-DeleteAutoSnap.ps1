# =============================================================================
# ========               VM Snapshot Deletion Automation               ========
# ========                             by                              ========
# ========                          VirtualDataPro                        ========
# ========                      v1.0 - 1/26/2015                       ========
# =============================================================================
#This Script grabs the vms and snapshots then filters the snapshots by excluding VMs with snapshot names that .Contains("exclude")
#Takes 4-5mins to run looking for a cleaner filtering model

$Date = Get-Date

$Snaps = Get-VM | ?{$_.VMHost.Parent -ne "Org VDI"} | Get-Snapshot | ?{$_.Name.Contains("snapshot-") -ne "True" -and $_.Name.Contains("NBU_SNAPSHOT") -ne "True" -and $_.Name.Contains("vdm-initial-") -ne "True"}

ForEach($Snap in $Snaps){
    $Desc = $Snap.Description
    $Expiration = $Desc.Split('::')[1]
    If($Date -ge [datetime]$Expiration){
        Write-host "Deleting Snapshot "$Snap.Name
        Remove-Snapshot $Snap -Confirm:$False -RunAsync
    }
}
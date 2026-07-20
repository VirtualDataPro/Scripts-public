<# 
.SYNOPSIS
    Export All VM Info
.DESCRIPTION
    Exports VM info for vCenter to VMexport.csv
.EXAMPLE
    .\GET-ALLVM.ps1
.NOTES
 Author: VirtualDataPro
 Version: 1.0 DEC 2016
#>
################################################################################

get-vm | Select-Object Name, PowerState, @{N="VLAN";E={(Get-VDPortgroup ($_ | Get-NetworkAdapter).networkname).vlanconfiguration.vlanid}}, @{N="IPaddress";E={$_.guest.IPaddress}}, @{N="Operating System";E={$_.guest.OSfullname}}, GuestID, NumCPU, MemoryGB, UsedSpaceGB, ProvisionedSpaceGB, Notes | export-csv Reports\VMexport.csv -notypeinformation -useculture
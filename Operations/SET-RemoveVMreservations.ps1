<# 
.SYNOPSIS
    Removes All VM Reservations and Limits 
.DESCRIPTION
    Reservations and limits hinder the VM kernel from doing what it is good at. If there is no contention for resources, there is no reason to apply artificial limits and reservations. Some administrators will unknowingly set reservations and limits with good intentions to improve performance related issues. This is a common misconception of the technology and can adversly affect the environment.
.EXAMPLE
    .\SET-RemoveVMreservations.ps1
.NOTES
 Author: VirtualDataPro
 Version: 1.0 DEC 2013
#>

Get-VM | Get-VMResourceConfiguration | Where-Object {$_.CPUReservationMhz -ne '0' -or $_.CPULimitMhz -ne '-1' -or $_.MemReservationMB -ne '0' -or $_.MemLimitMB -ne '-1'} | Set-VMResourceConfiguration -CpuReservationMhz 0 -CPULimitMhz $null -MemReservationMB 0 -MemLimitMB $null

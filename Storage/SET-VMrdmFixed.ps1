<# 
.SYNOPSIS
    Configures a VM's RDM pathing to Fixed.
.DESCRIPTION
    Created to quickly configure MSSQL cluster VMs that need RDMs in physical compatibility mode and SCSI bus sharing. It is recommended that the path selection be configured for Fixed path.
.EXAMPLE
    .\SET-RDMvmtoFixed.ps1  <ESXi Name>
.NOTES
 Author: VirtualDataPro
 Version: 1.0 May 2016
#>

param(
     [parameter(Mandatory = $true,
 ValueFromPipeline=$true)] 
     [string[]]$vmname
     )

$hdds = get-vm $vmname | Get-HardDisk -DiskType RawPhysical

foreach($hdd in $hdds){

	$lun = Get-ScsiLun -CanonicalName $hdd.ScsiCanonicalName -VmHost $hdd.Parent.VMhost

	If($lun.MultipathPolicy -ne 'Fixed'){
		$scsilunpath = get-scsilunpath -ScsiLun $lun | Sort-Object State | Select-Object -First 1
		set-scsilun -ScsiLun $lun -MultipathPolicy Fixed -PreferredPath $scsilunpath -Confirm:$false
	}
}
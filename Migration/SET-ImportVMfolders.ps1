#####################################################################
#Migration from 5.0 to new 6.0 vCenter Deployment
#Import VM Folders and Custom Annotations
#
#
#
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################

#The script uses a New-VIProperty to fetch the blue folderpath for a VM.

#Manually configure .CSV Location 

#Import the folder structure and move existing VMs.

##################################################################### 
param(
    [parameter(Mandatory = $true)]
    [string[]]$newDatacenter
	)

$newFolder = "Imported Folder" 
$csvLocation = "FolderBackup.csv"

$startFolder = New-Folder -Name $newFolder -Location (Get-Folder -Name vm -Location (Get-Datacenter -Name $newDatacenter))

Import-Csv $csvLocation -UseCulture | ForEach-Object{
    $location = $startFolder
    $_.BlueFolderPath.TrimStart('/').Split('/') | ForEach-Object{
        $tgtFolder = Get-Folder -Name $_ -Location $location -ErrorAction SilentlyContinue
        if(!$tgtFolder){
            $location = New-Folder -Name $_ -Location $location
        }
        else{
            $location = $tgtFolder
        }
    }
    
    $vm = Get-VM -Name $_.Name -ErrorAction SilentlyContinue
    if($vm){
        Move-VM -VM $vm -Destination $location -Confirm:$false 
    }
}

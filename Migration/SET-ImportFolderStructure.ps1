#####################################################################
#Migration from 5.0 to new 5.5 vCenter Deployment
#Import VM Folders and Custom Annotations
#
# Thanks LucD 
#####################################################################

#The script uses a New-VIProperty to fetch the blue folderpath for a VM.

#Manually configure .CSV Location 

#Import the folder structure and move existing VMs.

##################################################################### 
param(
    [parameter(Mandatory = $true)]
    [string[]]$newDatacenter,

    [parameter(Mandatory = $true)]
    [string]$CsvLocation
    )

$newFolder = "Imported Folder" 

$startFolder = New-Folder -Name $newFolder -Location (Get-Folder -Name vm -Location (Get-Datacenter -Name $newDatacenter))

Import-Csv $CsvLocation -UseCulture | %{
    $location = $startFolder
    $_.BlueFolderPath.TrimStart('/').Split('/') | %{
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

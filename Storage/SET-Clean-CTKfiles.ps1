<#



#>
param(
    [parameter(Mandatory = $true)]
    [string[]]$param
 )
 
$VM = Get-VM $param
$DSP = Get-Datastore -id $VM.DatastoreIdList
$vDSP = $DSP.DatastoreBrowserPath + "\" + $VM.name
Get-ChildItem $vDSP | ?{$_.name.contains("ctk")} | foreach{
	$NewN = $_.name + ".old"
	$fullDSP = $vDSP + "\" + $_.name
	Get-Item $fullDSP | Rename-Item -NewName $NewN
}

Start-VM $VM -Confirm:$False

$VM.ExtensionData.ConsolidateVMDisks()


#(get-vm | get-view).layout.disk.diskfile | %{$_.split("]/",3) | Select-Object -SkipLast 1 | Select-Object -Skip 1} | Select-Object -Unique
#($X | get-view).layout.disk.diskfile | %{$_.split("[]",3) | Select-Object -Skip 1 | Select-Object -SkipLast 1} | Select-Object -Unique
<#
This works great!
	((Get-Datastore (($X | get-view).layout.disk.diskfile | %{$_.split("[]",3) | Select-Object -Skip 1 | Select-Object -SkipLast 1} | Select-Object -Unique)).DatastoreBrowserPath + "\" + (($X | get-view).layout.disk.diskfile | %{$_.split("]/",3) | Select-Object -SkipLast 1 | Select-Object -Skip 1} | Select-Object -Unique).trim(""))
#>
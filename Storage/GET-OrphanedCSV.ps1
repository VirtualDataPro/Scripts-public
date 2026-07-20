param(
  [parameter(mandatory = $true)]
  [string[]]$csvImportList
  )
$orphaned = import-csv  -path $csvImportList -useculture
$orphaned | %{
  "vmstores:\"+((((Get-Datacenter $_.datacentername).uid.split("/") | Select-Object -First 2).split("@") | Select-Object -Last 1).replace(":","@"))+"\"+$_.DatacenterName+"\"+$_.datastorename+"\"+(($_.diskname.split("/",7) | Select-Object -Last 1).replace("/","\"))
}
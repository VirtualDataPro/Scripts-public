Param(
    [parameter(Mandatory = $true)]
    [string[]]$vHostName
 )

get-vmhost $vHostName | Get-VMHostHba | ?{$_.model -eq "iSCSI Software Adapter"} | select VMHost, iSCSIname
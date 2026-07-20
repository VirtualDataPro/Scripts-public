#Author: VirtualDataPro MAR2014
#Usage: ./GET-ALLVM.ps1
#To Export: ./GET-ALLVM.ps1 | Export-Csv D:\Scripts\Testing\<NameFile>.csv  -NoTypeInformation -UseCulture
#DESCRIPTION - Returns all VM's and Provisioned Resources
#
#####################################################################
	
$Date = Get-Date -f ddMMMyyyy

Get-VM | Select Name,@{N="State";E={$_.Guest.State}},@{N="Custom";E={($_.CustomFields | ?{$_.key -eq "Custom"}).value}},@{N="Cluster";E={$_.Host.Parent.Name}},NumCPU,MemoryGB,@{N="StorageGB";E={[Math]::Round($_.ProvisionedSpaceGB)}},@{N="Vlan";E={$_.NetworkAdapters.NetworkName}},@{N="IPAddress";E={$_.Guest.IPaddress}},@{N="GuestOS";E={$_.Guest.OSFullName}},Notes,@{N="HDD1";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 1"} ; $D.CapacityGB}},@{N="HDD2";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 2"} ; $D.CapacityGB}},@{N="HDD3";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 3"} ; $D.CapacityGB}},@{N="HDD4";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 4"} ; $D.CapacityGB}},@{N="HDD5";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 5"} ; $D.CapacityGB}},@{N="HDD6";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 6"} ; $D.CapacityGB}},@{N="HDD7";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 7"} ; $D.CapacityGB}},@{N="HDD8";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 8"} ; $D.CapacityGB}},@{N="HDD9";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 9"} ; $D.CapacityGB}},@{N="HDD10";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 10"} ; $D.CapacityGB}},@{N="HDD11";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 11"} ; $D.CapacityGB}},@{N="HDD12";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 12"} ; $D.CapacityGB}},@{N="HDD13";E={$D = $_.HardDisks | ?{$_.Name -eq "Hard Disk 13"} ; $D.CapacityGB}},@{N="Datastore";E={Get-Datastore -Id $_.DatastoreIdList}} | Export-Csv ("Reports\VM-DetailsBackup"+"-"+$Date+".csv") -UseCulture -NoTypeInformation



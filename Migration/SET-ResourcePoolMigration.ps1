#####################################################################
#Migration from 5.0 to new 6.0 vCenter Deployment
#Resource Pools
#
#Moves Cluster VMs to appropriate Resource Pool
#
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$Cluster
	)

$PoweredOff = ""
$Test = "Hosted_Test"
$Dev = "Hosted_Dev"
$Prod = "Hosted_Prod"

#####################################################################
	
$VMs = Get-cluster $Cluster | Get-VM

ForEach($VM in $VMs){
#	If($VM.notes.Contain("powewred off")){
#		$VM | Move-VM -Destination $PoweredOff
#	}
#	Else{
		If($VM.Name.Chars(8) -eq "1"){$VM | Move-VM -Destination $Prod}
		If($VM.Name.Chars(8) -eq "2"){$VM | Move-VM -Destination $Dev}
		If($VM.Name.Chars(8) -eq "3"){$VM | Move-VM -Destination $Test}
#	}
}


#Get-ComputeResources.ps1
<#
 
 
 
 
 
#>

#Define Report Array
$Report = @()
 
#Get Clusters
$AllClusters = Get-Cluster | ?{$_.ExtensionData.Summary.NumEffectiveHosts -gt 0}
 
ForEach($cluster in $AllClusters){
	#Reset Counters
	$cVmem = 0
	$cVcpu = 0
	$ccpu = 0
	
	#Reset Object
                $ClusterInfo = New-Object System.Object
               
                #Count Effective Cores
                $Cluster | Get-VMHost | ?{$_.ConnectionState -eq "Connected"} | %{
                                $ccpu = $_.ExtensionData.Hardware.CpuInfo.NumCpuCores+$ccpu
                }
               
                #Count VM Allocation
                $Cluster | Get-VM |?{$_.PowerState -eq "PoweredOn"} | %{
                                $cVmem = $_.MemoryGB+$cVmem
                                $cVcpu = $_.NumCpu+$cVcpu
                }
               
                #Define Custom Metrics
                $MemoryFull = [math]::round(($cVmem/($Cluster.ExtensionData.Summary.EffectiveMemory/1kb))*100)
                $CPUratio = [math]::round($cvcpu/$ccpu,2)
               
                #Add properties to object
                $ClusterInfo | Add-Member -Type NoteProperty -Name "Cluster" -Value $Cluster.name
                $ClusterInfo | Add-Member -Type NoteProperty -Name "ClusterMemoryUsage" -Value $MemoryFull
                $ClusterInfo | Add-Member -Type NoteProperty -Name "CPUratio" -Value $CPUratio
                $ClusterInfo | Add-Member -Type NoteProperty -Name "NumEffectiveHosts" -Value $Cluster.ExtensionData.Summary.NumEffectiveHosts
                $ClusterInfo | Add-Member -Type NoteProperty -Name "VMProvisionedMemoryGB" -Value $cVmem
                $ClusterInfo | Add-Member -Type NoteProperty -Name "AvailibleMem" -Value ([math]::round($Cluster.ExtensionData.Summary.EffectiveMemory/1kb))
                $ClusterInfo | Add-Member -Type NoteProperty -Name "RawMemory" -Value ([math]::round($Cluster.ExtensionData.Summary.TotalMemory/1gb))
                $ClusterInfo | Add-Member -Type NoteProperty -Name "Overhead" -Value ($ClusterInfo.RawMemory - $ClusterInfo.AvailibleMem)
                $ClusterInfo | Add-Member -Type NoteProperty -Name "VMProvisionedCPU" -Value $cVcpu
                $ClusterInfo | Add-Member -Type NoteProperty -Name "AvailibleCores" -Value $ccpu
                               
                <#Intelligence Query Metrics
                hft=0
                ?WHILE MEMFULL -LT 100{
                gethost most mem
                mem-numeff
                hostfailuretollerate = 1
                MEMFULL
                CALCMEMFULL
                WRITEHOST TEST
                aDD TO CLUSTINFO WITH VARIABLE NAME?
                }
                #>
               
               
               
               
                #Add Cluster Object to Array
                $Report += $Clusterinfo
}
 
$Report | Sort ClusterMemoryUsage -Descending

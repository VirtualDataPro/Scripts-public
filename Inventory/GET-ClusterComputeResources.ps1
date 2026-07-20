param(
    [parameter(Mandatory = $true)]
    [string[]]$vmcluster
    )
	
# Define Report Array
$Report = @()

# Get Clusters
$AllClusters = Get-Cluster $vmcluster | ?{$_.ExtensionData.Summary.NumEffectiveHosts -gt 1}

ForEach($Cluster in $AllClusters){
        # Reset Counters
        $cVmem = 0
        $cVcpu = 0
        $ccpu = 0

        # Reset Object
        $ClusterInfo = New-Object System.Object

        # Count Effective Cores
        $Cluster | Get-VMHost | ?{$_.ConnectionState -eq "Connected"} | %{
                $ccpu = $_.ExtensionData.Hardware.CpuInfo.NumCpuCores+$ccpu
        }

        # Count VM Allocation
        $Cluster | Get-VM |?{$_.PowerState -eq "PoweredOn"} | %{
                $cVmem = $_.MemoryGB+$cVmem
                $cVcpu = $_.NumCpu+$cVcpu
        }

        # Get Cluster Largest MemoryGB Host Value
        $BigMem = [math]::round(( $Cluster | Get-VMHost | sort MemoryTotalGB -Descending | Select-Object -First 1).MemoryTotalGB)

        # Define Custom Metrics
        $MemoryFull = [math]::round(($cVmem/($Cluster.ExtensionData.Summary.EffectiveMemory/1kb))* 100)
        $CPUratio = [math]::round($cvcpu/$ccpu,2)

        # Add properties to object
        $ClusterInfo | Add-Member -Type NoteProperty -Name "Cluster" -Value $Cluster.name
        $ClusterInfo | Add-Member -Type NoteProperty -Name "ClusterMemoryUsage" -Value $MemoryFull
        $ClusterInfo | Add-Member -Type NoteProperty -Name "CPUratio" -Value $CPUratio
        $ClusterInfo | Add-Member -Type NoteProperty -Name "NumEffectiveHosts" -Value $Cluster.ExtensionData.Summary.NumEffectiveHosts
        $ClusterInfo | Add-Member -Type NoteProperty -Name "VMProvisionedMemoryGB" -Value $cVmem
        $ClusterInfo | Add-Member -Type NoteProperty -Name "ClusterMemoryGB" -Value ([math]::round($Cluster.ExtensionData.Summary.EffectiveMemory/1kb))
        $ClusterInfo | Add-Member -Type NoteProperty -Name "RawMemory" -Value ([math]::round($Cluster.ExtensionData.Summary.TotalMemory/1gb))
        $ClusterInfo | Add-Member -Type NoteProperty -Name "Overhead" -Value ($ClusterInfo.RawMemory - $ClusterInfo.ClusterMemoryGB)
        $ClusterInfo | Add-Member -Type NoteProperty -Name "VMProvisionedCPU" -Value $cVcpu
        $ClusterInfo | Add-Member -Type NoteProperty -Name "AvailibleCores" -Value $ccpu

        $NEH = $ClusterInfo.NumEffectiveHosts
        $FailCount = 0

        # Host Failure Forecasting "Playing with Numbers"
        While($MemoryFull -lt 100){
                $FailCount = $FailCount + 1
                $NEH = $NEH - 1
                IF($NEH -gt 1){
                        $NewMem = $ClusterInfo.ClusterMemoryGB - ($BigMem*$FailCount)
                        $MemoryFull = [math]::round(($cVmem/$NewMem)*100)
                        IF($MemoryFull -lt 100){
                                $NP = "Failure"+$FailCount
                                $NV = "After "+$FailCount+" Failures, this cluster is "+$MemoryFull+"% Full."
                                $ClusterInfo | Add-Member -Type NoteProperty -Name $NP -Value $NV
                        }
                }
                Else{
                        IF($ClusterInfo.NumEffectiveHosts -eq 2){
								$NP = "Notes"
								$NV = "This cluster contains 2 hosts and cannot support more than 49% of resources"
								$ClusterInfo | Add-Member -Type NoteProperty -Name $NP -Value $NV
								IF($ClusterInfo.ClusterMemoryUsage -lt 50){
										$FailCount = $FailCount + 1
								}
                        }
                        $MemoryFull = 101
                }
        }
		
		$ClusterInfo | Add-Member -Type NoteProperty -Name "MaxFailures" -Value ($FailCount - 1)
		
        # Add Cluster Object to Array
        $Report += $Clusterinfo
}

$Report | Sort ClusterMemoryUsage -Descending
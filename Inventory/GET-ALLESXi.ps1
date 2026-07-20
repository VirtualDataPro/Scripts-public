<# 
.SYNOPSIS
    Export All ESXi Info
.DESCRIPTION
    Exports ESXi info for vCenter to VMexport.csv
.EXAMPLE
    .\GET-ALLESXi.ps1
.NOTES
 Author: VirtualDataPro
 Version: 1.0 DEC 2016
#>
################################################################################

Get-VMHost | Select-Object Name, Parent, Model, Manufacturer, ProcessorType, Version, Build, Powerstate, @{N="MemoryGB";E={[math]::round($_.MemoryTotalGB)}}, @{N="Sockets";E={$_.ExtensionData.Hardware.CpuInfo.NumCpuPackages}}, @{N="Cores/Socket";E={$_.ExtensionData.Hardware.CpuInfo.NumCpuCores / $_.ExtensionData.Hardware.CpuInfo.NumCpuPackages}}, @{N="TotalCores";E={$_.NumCpu}}, @{N="CpuThreads";E={$_.ExtensionData.Hardware.CpuInfo.NumCputhreads}}, HyperthreadingActive, LicenseKey, @{Name="Serial Number"; Expression={($_.ExtensionData.Hardware.SystemInfo.OtherIdentifyingInfo | ?{$_.IdentifierType.Key -eq "ServiceTag"}).identifiervalue | Select-Object -Last 1}} | Export-csv Reports\ESXiExport.csv -notypeinformation -useculture
<# 
.SYNOPSIS
    Finds VM or Host with MAC
.DESCRIPTION
    Requires VM tools and VM be present in vCenter
.EXAMPLE
    .\GET-FindMAC.ps1 30:8d:99:ff:b0:7a
.NOTES
    Author: VirtualDataPro
    Version: 1.0 FEB 2017
#>

param(
    [parameter(mandatory = $true)]
    [string[]]$MACaddress
    )

Get-VM | %{
    $vmMAC = ($_ | Get-NetworkAdapter).MacAddress
    foreach($MAC in $vmMAC){
        if($MAC -eq $MACaddress) {
            Write-Host "MAC FOUND! --->" $_.Name -ForegroundColor green
        }
    }
}

Get-VMHost | %{
    $hostMAC = ($_ | Get-VMHostNetworkAdapter).Mac
    foreach($MAC in $hostMAC){
        if($MAC -eq $MACaddress) {
            Write-Host "MAC FOUND! --->" $_.Name -ForegroundColor green
        }
    }
}
<# 
.SYNOPSIS
    Finds VM with IP
.DESCRIPTION
    Requires VM tools and VM be present in vCenter
.EXAMPLE
    .\GET-FindIP.ps1 192.168.1.1
.NOTES
    Author: VirtualDataPro
    Version: 1.0 FEB 2017
#>

param(
    [parameter(mandatory = $true)]
    [string[]]$IPaddress
    )

Get-VM | %{
    $vmIP = $_.Guest.IPAddress
    foreach($IP in $vmIP){
        if($IP -eq $IPaddress) {
            Write-Host "IP FOUND! --->" $_.Name -ForegroundColor green
        }
    }
}

Get-VMHost | %{
    $HostIP = ($_ | Get-VMHostNetworkAdapter -VMKernel).ip
    foreach($IP in $HostIP){
        if($IP -eq $IPaddress) {
            Write-Host "IP FOUND! --->" $_.Name -ForegroundColor green
        }
    }
}
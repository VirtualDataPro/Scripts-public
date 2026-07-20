############################################################################
#GetClusterHBA.ps1
#
#USAGE: ./GetClusterHBA.ps1 <"cluster name">
############################################################################

param(
    [parameter(Mandatory = $true)]
    [string[]]$Cluster
    )
    
Get-Cluster $Cluster | Get-VMhost | Get-VMHostHBA -Type FibreChannel | Select VMHost,Device,@{N="WWNN";E={"{0:X}"-f$_.NodeWorldWideName}},@{N="WWPN";E={"{0:X}"-f$_.PortWorldWideName}} | Sort VMhost,Device
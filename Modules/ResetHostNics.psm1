<################################################################################
.SYNOPSIS
 Checks and corrects downed link status on ESXi physical nics.
.DESCRIPTION
 Function was created to check and look for "Flapped" NICs. Then reset the nic if link status is down.
.EXAMPLE
 ResetHostNics ESXi1
 or      
 Get-VMhost | %{ResetHostNics $_.Name} 
.NOTES
 By: VirtualDataPro
################################################################################>
Function ResetHostNics($vhost){
    $esxcli = get-vmhost $vhost | Get-EsxCli
    $downNics = $esxcli.network.nic.list() | where{$_.Link -eq "Down"} | Select Name
    ForEach($downNic in $downNics){
        Write-Host $vhost " was Affected. Fixing... "$downNic.name
    $esxcli.network.nic.down($downNic.Name)
    $esxcli.network.nic.up($downNic.Name)
    }
}
<#
.SYNOPSIS
	Checks and corrects downed link status on ESXi physical nics.
.DESCRIPTION
	Function was created to check and look for "Flapped" NICs. Then reset the nic if link status is down.
.EXAMPLE
	ResetNics ESXi1
	or
	Get-VMhost -Location ProdCluster | %{ResetNics $_.Name}
.NOTES
	By: LazyPowerCLI
#>
Function ResetNics($vhost){
	$esxcli = get-vmhost $vhost | Get-EsxCli
	$downNics = $esxcli.network.nic.list() | ?{$_.Link -eq "Down"} | select name
		ForEach($downNic in $downNics){
			Write-Host $vhost " was Affected. Fixing... " $downNic.name
			$esxcli.network.nic.down($downNic.Name)
			$esxcli.network.nic.up($downNic.Name)
		}
}
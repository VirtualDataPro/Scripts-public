$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$vmConfigSpec.Tools = New-Object VMware.Vim.ToolsConfigInfo 
$vmConfigSpec.Tools.ToolsUpgradePolicy = "manual"

Get-VM | Get-View | % {
	$_.ReconfigVM($vmConfigSpec)
}


#Get-VM|Get-View | select name,@{N='ToolsUpgradePolicy';E={$_.Config.Tools.ToolsUpgradePolicy } } |Sort Name
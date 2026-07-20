<#
My Profile
C:\Users\example.user\Documents\WindowsPowerShell\profile.ps1

new-item $profile.CurrentUserAllHosts -ItemType file -Force

PowerCLI O:\Scripts> $profile
C:\Users\example.user\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
Import-Module O:\Scripts\Modules\MyProfileModule.psm1

Set-PowerCLIConfiguration -WebOperationTimeoutSeconds -1 -Scope Session -Confirm:$false
Set-Location -LiteralPath "O:\Scripts\"
#>

#Connection Function
Function Connect{
	[CmdletBinding()]
		Param(
			[Parameter(Mandatory=$True)]
			[ValidateSet("SITE-A","SITE-B","SITE-A-VDI","SITE-B-VDI","ALL")]
			[string]$VIserver
		)
	
	Disconnect-VIServer -Confirm:$False -ErrorAction 4
    
	$Servers = @{
		"SITE-A"     = @("vcenter-a.example.local")
		"SITE-B"     = @("vcenter-b.example.local")
		"SITE-A-VDI" = @("vcenter-a-vdi.example.local")
		"SITE-B-VDI" = @("vcenter-b-vdi.example.local")
	}

	$Targets = if ($VIServer -eq "ALL") { $Servers.Values } else { $Servers[$VIServer] }
	Connect-VIServer @($Targets)
	
}


<# 
.SYNOPSIS
    Module for AD
.DESCRIPTION
    Functions written to call later
.EXAMPLE
    Import-Module ADGroupMembership.psm1
	Export-ADGroupMembership GroupName
.NOTES
    Author: VirtualDataPro
	JUL2021
#>

Function Export-ADGroupMembership {
    param (
		[Parameter(Position=0, Mandaconntory=$true)]
        [string[]]$group
    )
	
	$results = @()
	
	$users = Get-AdGroup -filter * | ?{$_.name -match $group} | select name -expandproperty name | Get-ADGroupMember | Get-ADUser | select SamAccountName, @{N="Email";E={$_.UserPrincipalName}}, @{n="MemberOf";e={($_ | Get-ADPrincipalGroupMembership | ?{$_.name -match $group}).samaccountname}}
	
	ForEach($row in $users){
		ForEach($memof in $row.memberof){
			$info = New-Object System.Object
			$info | Add-Member -Type NoteProperty -Name "SamAccountName" -Value $row.samaccountname
			$info | Add-Member -Type NoteProperty -Name "Email" -Value $row.email
			$info | Add-Member -Type NoteProperty -Name "MemberOf" -Value $memof
			$results += $info 
		}
	}
	
	$results
}


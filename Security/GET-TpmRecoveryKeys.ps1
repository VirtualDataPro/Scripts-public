<#
.SYNOPSIS
    Gets ESXi system configuration encryption recovery keys for all hosts.
.DESCRIPTION
    Uses existing PowerCLI default server connections to enumerate every ESXi
    host and invoke esxcli system settings encryption recovery list through
    Get-EsxCli V2. Connect to each required vCenter with Connect-VIServer first.

    Returns one object per recovery key, or a status object if a host cannot be
    queried or has no recovery keys. A failed host does not stop other hosts.
    Requires an ESXi version supporting this command (ESXi 7.0 Update 2 or later)
    and an account permitted to execute it. No host settings are changed.

    Output contains plaintext secrets. Store exports securely outside this repo.
.EXAMPLE
    Connect-VIServer -Server 'vcenter.example.com'
    .\GET-TpmRecoveryKeys.ps1
.EXAMPLE
    .\GET-TpmRecoveryKeys.ps1 | Export-Csv -Path 'C:\Secure\TpmRecoveryKeys.csv' -NoTypeInformation
.NOTES
    These are host configuration recovery keys, not virtual machine vTPM keys.
    Command reference: https://developer.broadcom.com/xapis/esxcli-command-reference/latest/namespace/esxcli_system.html
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

foreach ($command in 'Get-VMHost', 'Get-EsxCli') {
    if (-not (Get-Command -Name $command -ErrorAction SilentlyContinue)) {
        throw "Required command '$command' is unavailable. Install/import VMware PowerCLI and connect with Connect-VIServer."
    }
}

$vmHosts = @(Get-VMHost -ErrorAction Stop | Sort-Object Name)
if ($vmHosts.Count -eq 0) {
    Write-Warning 'No ESXi hosts were found in the default PowerCLI server connections.'
}

foreach ($vmHost in $vmHosts) {
    Write-Verbose "Retrieving recovery keys from $($vmHost.Name)."
    $records = @()

    try {
        if ([string]$vmHost.ConnectionState -notin @('Connected', 'Maintenance')) {
            throw "Host is not connected (state: $($vmHost.ConnectionState))."
        }

        $esxcli = Get-EsxCli -VMHost $vmHost -V2 -ErrorAction Stop
        $keys = @($esxcli.system.settings.encryption.recovery.list.Invoke())

        foreach ($key in $keys) {
            if ($null -eq $key) { continue }
            if ([string]::IsNullOrWhiteSpace([string]$key.RecoveryID) -or
                [string]::IsNullOrWhiteSpace([string]$key.Key)) {
                throw 'The recovery command returned an incomplete recovery ID or key.'
            }

            $records += [pscustomobject][ordered]@{
                VMHost     = $vmHost.Name
                HostUid    = $vmHost.Uid
                RecoveryID = $key.RecoveryID
                Key        = $key.Key
                Status     = 'Success'
                Error      = $null
            }
        }

        if ($records.Count -eq 0) {
            $records = [pscustomobject][ordered]@{
                VMHost     = $vmHost.Name
                HostUid    = $vmHost.Uid
                RecoveryID = $null
                Key        = $null
                Status     = 'NoRecoveryKeys'
                Error      = $null
            }
        }
    }
    catch {
        $records = [pscustomobject][ordered]@{
            VMHost     = $vmHost.Name
            HostUid    = $vmHost.Uid
            RecoveryID = $null
            Key        = $null
            Status     = 'Failed'
            Error      = $_.Exception.Message
        }
        Write-Warning "Could not retrieve recovery keys for $($vmHost.Name). See the Error field."
    }

    $records
}

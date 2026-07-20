function Connect-AzSubscription {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionName
    )

    Import-Module Az
    Connect-AzAccount
    Get-AzSubscription -SubscriptionName $SubscriptionName | Set-AzContext
}

#####################################################################
#Migration from 5.0 to new 5.5 vCenter Deployment
#Export DRS Rules
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################
# Run .\DRS-RulesExport.ps1 "Cluster Name"

param(
    [parameter(mandatory = $true)]
    [string[]]$clusterName
    )

$Report = @()

$rules = get-cluster -Name $clusterName | Get-DrsRule

foreach($rule in $rules){
  $line = (Get-View -Id $rule.ClusterId).Name
  $line += ("," + $rule.Name + "," + $rule.Enabled + "," + $rule.KeepTogether)
  foreach($vmId in $rule.VMIds){
    $line += ("," + (Get-View -Id $vmId).Name)
  }
  $Report += $line  
}

$Report
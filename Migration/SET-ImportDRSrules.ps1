####################################################################
#Migration from 5.0 to new 5.5 vCenter Deployment
#Import DRS Rules
#
# Version v1.0 JAN 2014 VirtualDataPro
#####################################################################
# The Cluster is defiened in the Rules.txt
$file = "D:\Scripts\DRS\Rules.txt"
$rules = Get-Content $file

foreach($rule in $rules){
  $ruleArr = $rule.Split(",")
  if($ruleArr[2] -eq "True"){$rEnabled = $true} else {$rEnabled = $false}
  if($ruleArr[3] -eq "True"){$rTogether = $true} else {$rTogether = $false}
  get-cluster $ruleArr[0] | `
    New-DrsRule -Name $ruleArr[1] -Enabled $rEnabled -KeepTogether $rTogether -VM (Get-VM -Name ($ruleArr[4..($ruleArr.Count - 1)])) 
}
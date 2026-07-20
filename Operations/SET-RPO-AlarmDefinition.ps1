param(
    [Parameter(Mandatory = $true)]
    [string]$MailTo
)
$alarmMgr = Get-View AlarmManager
# Create AlarmSpec object
$alarm = New-Object VMware.Vim.AlarmSpec
$alarm.Name = "vSphere Replication RPO violation"
$alarm.Description = "Tracks changes of a VM's vSphere Replication RPO violation status"
$alarm.Enabled = $TRUE
# Event expression 1 - RPO violated by more than 1 minute
# will change state to "Red"
$expression1 = New-Object VMware.Vim.EventAlarmExpression
$expression1.EventType = "EventEx"
$expression1.eventTypeId = "com.vmware.vcHms.rpoViolatedEvent"
$expression1.objectType = "VirtualMachine"
$expression1.status = "red"
# Attribute comparison for expression 1
$comparison1 = New-Object VMware.Vim.EventAlarmExpressionComparison
$comparison1.AttributeName = "currentRpoViolation"
$comparison1.Operator = "notEqualTo"
$comparison1.Value = "1"
$expression1.Comparisons += $comparison1
# Event expression 2 - RPO restored
# will change state back to "Green"
$expression2 = New-Object VMware.Vim.EventAlarmExpression
$expression2.EventType = "EventEx"
$expression2.eventTypeId = "com.vmware.vcHms.rpoRestoredEvent"
$expression2.objectType = "VirtualMachine"
$expression2.status = "green"
# Add event expressions to alarm
$alarm.expression = New-Object VMware.Vim.OrAlarmExpression
$alarm.expression.expression += $expression1
$alarm.expression.expression += $expression2
# Create alarm in vCenter root
$alarmMgr.CreateAlarm("Folder-group-d1",$alarm)
# Add action (send mail) to the newly created alarm
Get-AlarmDefinition $alarm.Name | New-AlarmAction -Email -Subject "vSphere Replication RPO violation" -To $mailTo
# New-AlarmAction will automatically add the trigger Yellow->Red (!)
# Add a second trigger for Yellow->Green
Get-AlarmDefinition $alarm.Name | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"

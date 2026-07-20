#https://vrops.example.local/suite-api/doc/swagger-ui.html#/
#https://blogs.vmware.com/PowerCLI/2016/05/using-entire-api-vrealize-operations-via-powercli.html
#https://ryanjan.uk/2018/05/16/running-vrops-reports-using-powercli/
#$vrops = Connect-OMServer -Server vrops.example.local # -AuthSource "Local Users"

#$vrops.ExtensionData.GetReportDefinitions($null, $null, "Oversized Virtual Machines").ReportDefinition

$ResID = Get-OMResource -Name "EXAMPLE-RESOURCE" | Select-Object Id

#Create URL string for Invoke-RestMethod  
$urlsend = 'https://' + 'vrops.example.local' + '/suite-api/internal/optimization/00000000-0000-0000-0000-000000000000/reclaim'
#Credential    
$cred = Get-Credential    
## Debug   
echo $urlsend    
#Send Attribute data to vRops.  
$ContentType = "application/xml;charset=utf-8"  
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"  
$header.Add("Accept", 'application/xml')  
$header.Add("X-vRealizeOps-API-use-unsupported", 'true')    

$result = Invoke-RestMethod -Method GET -uri $urlsend -credential $cred -ContentType $ContentType -Headers $header  
    
Write-Output $result


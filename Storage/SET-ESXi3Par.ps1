<#
.SYNOPSIS
	Sets iSCSI configuration best practices for HPE Alletra(3PAR)
.DESCRIPTION
	Created to quickly configure all standards for 3PAR on ESXi:
        Disable ATS for Heartbeat
        DefaultPSP for ALUA = Round Robin
        Add custom SATP rule for Round Robin
        Disable DelayedAck on iSCSI vmhba64
        LUN QFullSampleSize = 32
        LUN QFullThreshold = 8
        Create claimrule for XCOPY primitive
.PARAMETER ESXiHost
    Target ESXi Host Name
.NOTES
    Version: 1.0
	Author: VirtualDataPro
    Creation Date: MAR2024
    Purpose/Change: Configure 3Par on ESXi 7.0.3 Update 3o
.EXAMPLE
    Single Host:
	./SET-3ParESXi.ps1 <ESXi Name>
    
    Cluster:
    Get-Cluster <Cluster> | Get-VMhost | %{./SET-3ParESXi.ps1 $_.Name}

    Filtered Hosts:
    Get-VMhost *filter* | %{./SET-3ParESXi.ps1 $_.Name}
#>

Param(
    [parameter(Mandatory = $true)]
    [string[]]$ESXiHost
 )

$vH = Get-VMHost $ESXiHost
$vHcli = Get-EsxCli -VMHost $vH
$vHcliV2 = Get-EsxCli -VMHost $vH -V2

$sMsg = "Started configuring " + $vH.Name + " in " + $vH.Parent.Name + "for HPE Alletra(3PAR)"
write-host $sMsg

# Disable ATS for Heartbeating
$sMsg = "Disabling ATS primitive..."
write-host $sMsg

$vH | Get-AdvancedSetting -Name VMFS3.UseATSForHBOnVMFS5 | Set-AdvancedSetting -Value 0 -Confirm:$false

# Set ALUA Default PSP
$sMsg = "Applying DefaultPSP for ALUA to Round Robin..."
write-host $sMsg

$3PAR = $vHcli.storage.nmp.satp.list() | Where-Object{$_.Name -eq "VMW_SATP_ALUA" -and $_.DefaultPSP -ne "VMW_PSP_RR"} | Select-Object @{N="Cluster";E={$vH.Parent.Name}},@{N="VMHost";E={$vH.Name}},DefaultPSP,Name

If($3PAR.Name -eq "VMW_SATP_ALUA" -and $3PAR.DefaultPSP -ne "VMW_PSP_RR"){
    Write-Host "Configuring $vH ALUA Default PSP"
    #Create a low level object that points to the satp namespace:
    $LowLevel = $vHcli.TypeManager.CreateDynamicManagedObject( $vHcli.storage.nmp.satp.id )
    #Create a hashtable holding parameter values. Note that here we do not specify value for boot parameter:
    $Params = @{"defaultpsp" = "VMW_PSP_RR"; satp = "VMW_SATP_ALUA"}
    #Invoke set operation on the $LowLevel object:
    $LowLevel.InvokeOperation("set",$Params)
 }

# Add custom SATP rule
$sMsg = "Adding custom SATP rule..."
write-host $sMsg

$vHcli.storage.nmp.satp.rule.add($null,"tpgs_on","HP 3PAR Custom iSCSI/FC/FCoE ALUA Rule",$null,$null,$null,"VV",$null,"VMW_PSP_RR","iops=1","VMW_SATP_ALUA",$null,$null,"3PARdata")

# Apply DelayedAck
$sMsg = "Setting DelayedAck..."
write-host $sMsg
    #Switch to V2 for Invoke. Success output is "true".
$arr0= @{
    value = "false"
    adapter = "vmhba64" 
    default = $false
    key = "DelayedAck"
}
$vHcliV2.iscsi.adapter.param.set.Invoke($arr0)

# Set LUN queue settings on each LUN
$sMsg = "Setting LUN Queues..."
write-host $sMsg

$vHcli.storage.core.device.list() | Where-Object{$_.vendor -match "3PARdata"} |
ForEach-Object -Process {
    $arr1 = @{
        device = $_.device
        queuefullsamplesize = 32 
        queuefullthreshold = 8
    }
    $vHcliV2.storage.core.device.set.Invoke($arr1)
}

# Create claimrule for XCOPY primitive
$sMsg = "Creating claimrule..."
write-host $sMsg

$arr2 = @{
    rule = 914
    type = "vendor"
    vendor = "3PARdata"
    plugin = "VMW_VAAIP_T10"
    claimruleclass = "VAAI"
    xcopyusearrayvalues = $true
    xcopyusemultisegs = $true
}
$vHcliV2.storage.core.claimrule.add.Invoke($arr2)

$sMsg = "Finished configuring " + $vH.Name + " in cluster " + $vH.Parent.Name
write-host $sMsg
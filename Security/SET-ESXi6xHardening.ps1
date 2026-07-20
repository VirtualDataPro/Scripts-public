#STIG Host 

param(
	[parameter(Mandatory = $true)]
	[string[]]$vHost
	)

$ESXiHosts = Get-VMhost $vHost	

$SysLogDir = ""
$SysLogServer = ""
$ESXAdmins = ""
$NTPServers = ""
	
	
function Assert-HardeningGuideESXiAdvSetting {
  

  [CmdletBinding(SupportsShouldProcess=$true)]
  Param(
    ## VMHost to assess/remediate. If none specified, will act on all VMHosts in the VIServer to which current session is connected
    [parameter(ValueFromPipeline=$true)][VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$VMHost,
    ## Switch: Remediate the entity? Default is $false, which causes function to only report
    [switch]$Remediate = $false
  )

  begin {
    ## array of objects with info about advanced settings and desired values to set per the hardening guide (for guidelines that have no PowerCLI assessment/remediation code in the hardening guide)

$WelcomeMessage = "
{bgcolor:black} {/color}{align:left}{bgcolor:black}{color:yellow}{hostname} , {ip}{/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:black}{color:yellow}{esxproduct} {esxversion}{/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:black}{color:yellow}{memory} RAM{/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:black}{color:white}        {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}                                                                                                                          {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}  You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only. By      {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}  using this IS (which includes any device attached to this IS), you consent to the following conditions:                 {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}                                                                                                                          {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}  -       The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited     {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}          to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law      {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}          enforcement (LE), and counterintelligence (CI) investigations.                                                  {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}                                                                                                                          {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}  -       At any time, the USG may inspect and seize data stored on this IS.                                              {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}                                                                                                                          {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}  -       Communications using, or data stored on, this IS are not private, are subject to routine monitoring,            {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}          interception, and search, and may be disclosed or used for any USG-authorized purpose.                          {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}                                                                                                                          {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}  -       This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not     {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}          for your personal benefit or privacy.                                                                           {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}                                                                                                                          {/color}{/bgcolor}{/align}

{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}  -       Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching    {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}          or monitoring of the content of privileged communications, or work product, related to personal representation  {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}          or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work       {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}          product are private and confidential. See User Agreement for details.                                           {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{align:left}{bgcolor:yellow}{color:black}                                                                                                          {/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
{bgcolor:black} {/color}{align:left}{bgcolor:dark-grey}{color:white}   Accept Conditions and Customize System / View Logs{/align}{align:right} Accept Conditions and Shut Down/Restart  {bgcolor:black} {/color}{/color}{/bgcolor}{/align}
{bgcolor:black} {/color}{bgcolor:dark-grey}{color:black}                                                                                                                          {/color}{/bgcolor}
"

    $arrHardGuideSettingInfo =
	  @{Name = "DCUI.Access"; GuidelineId = "ESXI-06-000002"; Value = "root"},
	  @{Name = "Syslog.global.logHost"; GuidelineId = "ESXI-06-000004"; Value = $SysLogServer},
	  @{Name = "Security.AccountLockFailures"; GuidelineId = "ESXI-06-000005"; Value = 3},
      @{Name = "Security.AccountUnlockTime"; GuidelineId = "ESXI-06-000006"; Value = 900},
	  @{Name = "Annotations.WelcomeMessage"; GuidelineId = "ESXI-06-000007"; Value = $WelcomeMessage},
	  @{Name = "Config.Etc.issue"; GuidelineId = "ESXI-06-000008"; Value = "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only. By using this IS (which includes any device attached to this IS), you consent to the following conditions: -The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations. -At any time, the USG may inspect and seize data stored on this IS. -Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose. -This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy. -Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details."},
	  @{Name = "Config.HostAgent.log.level"; GuidelineId = "ESXI-06-000030"; Value = "info"},
	  @{Name = "Security.PasswordQualityControl"; GuidelineId = "ESXI-06-000031"; Value = "similar=deny retry=3 min=disabled,disabled,disabled,disabled,15"},
	  @{Name = "Config.HostAgent.plugins.solo.enableMob"; GuidelineId = "ESXI-06-000034"; Value = $false},
	  @{Name = "Config.HostAgent.plugins.hostsvc.esxAdminsGroup"; GuidelineId = "ESXI-06-000039"; Value = $ESXAdmins},
	  @{Name = "UserVars.ESXiShellInteractiveTimeOut"; GuidelineId = "ESXI-06-000041"; Value = 600},
	  @{Name = "UserVars.ESXiShellTimeOut"; GuidelineId = "ESXI-06-000042"; Value = 600},
      @{Name = "UserVars.DcuiTimeOut"; GuidelineId = "ESXI-06-000043"; Value = 600},
	  @{Name = "Syslog.global.logDir"; GuidelineId = "ESXI-06-000045"; Value = $SysLogDir},
	  @{Name = "Mem.ShareForceSalting"; GuidelineId = "ESXI-06-000055"; Value = 2},
	  @{Name = "Net.DVFilterBindIpAddress"; GuidelineId = "ESXI-06-000062"; Value = ""},
      @{Name = "Net.BlockGuestBPDU"; GuidelineId = "ESXI-06-000058"; Value = 1} | Foreach-Object {New-Object -Type PSObject -Property $_}
  }

  process {
    $arrVMHostOfInterest = if ($PsBoundParameters.ContainsKey("VMHost")) {$VMHost} else {Get-VMHost}
    $arrAdvSettings_theseHosts = Get-AdvancedSetting -Entity $arrVMHostOfInterest -Name $arrHardGuideSettingInfo.Name
    $arrAdvSettings_theseHosts | Foreach-Object {
      $oThisSetting = $_
      $oThisHGItem = $arrHardGuideSettingInfo | Where-Object {$_.Name -eq $oThisSetting.Name}
      $bIsSuggestedValue = $oThisHGItem.Value -eq $_.Value
      if ($Remediate) {
        if (-not $bIsSuggestedValue) {
          if ($PsCmdlet.ShouldProcess($oThisSetting.Entity, ("Set {0} from {1} to {2}" -f $oThisSetting.Name, $oThisSetting.Value, $oThisHGItem.Value))) {
            Set-AdvancedSetting -AdvancedSetting $oThisSetting -Value $oThisHGItem.Value -Confirm:$false | Select-Object Entity, Name, Value
          }
        }
      }
      ## else, report the current settings' values, and whether they match the values that the hardening guide suggests
      else {
        Select-Object -InputObject $_ Entity, Name, Value,
          @{n="STIG ID"; e={$oThisHGItem.GuidelineId}},
          @{n="STIG Compliant"; e={$bIsSuggestedValue}}
      }
    }
  }
}

$ESXiHosts | Assert-HardeningGuideESXiAdvSetting -Remediate -Verbose

#ESXI-06-000035
$ESXiHosts | Get-VMHostService | Where {$_.Label -eq "SSH"} | Stop-VMHostService -Confirm:$False
$ESXiHosts | Get-VMHostService | Where {$_.Label -eq "SSH"} | Set-VMHostService -Policy Off -Confirm:$False
#ESXI-06-000036
$ESXiHosts | Get-VMHostService | Where {$_.Label -eq "ESXi Shell"} | Stop-VMHostService -Confirm:$False
$ESXiHosts | Get-VMHostService | Where {$_.Label -eq "ESXi Shell"} | Set-VMHostService -Policy Off -Confirm:$False
#ESXI-06-000046
$ESXiHosts | Add-VMHostNTPServer $NTPServers
$ESXiHosts | Get-VMHostService | Where {$_.Label -eq "NTP Daemon"} | Set-VMHostService -Policy On -Confirm:$False
$ESXiHosts | Get-VMHostService | Where {$_.Label -eq "NTP Daemon"} | Start-VMHostService -Confirm:$False
#ESXI-06-000053
Get-VMHostSnmp | Set-VMHostSnmp -Enabled $false -Confirm:$False
#ESXI-06-000057
$ESXiHosts | Get-VMHostFirewallDefaultPolicy | Set-VMHostFirewallDefaultPolicy -AllowIncoming $false -AllowOutgoing $false -Confirm:$False
#ESXI-06-000059-61 -Reject/Reject/Reject
$ESXiHosts | Get-VirtualSwitch -Standard | Get-SecurityPolicy | Set-SecurityPolicy -MacChanges $false -ForgedTransmits $false -AllowPromiscuous $false
$ESXiHosts | Get-VirtualPortGroup -Standard | Get-SecurityPolicy | Set-SecurityPolicy -MacChanges $false -ForgedTransmits $false -AllowPromiscuous $false

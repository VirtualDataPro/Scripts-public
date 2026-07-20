<#
.SYNOPSIS
    ESXi host hardening assessment and remediation script.
.DESCRIPTION
    Evaluates VMware ESXi hosts against a defined security hardening baseline
    and optionally remediates non-compliant settings.
    Controls assessed include:
      - Advanced host security settings
      - SSH configuration
      - Service states and startup policies
      - Syslog configuration
      - NTP configuration
      - SNMP status
      - Secure Boot and TPM validation
      - Local account and kernel security settings
    By default, the script runs in assessment mode and reports compliance.
    Use -Remediate to apply supported corrective actions.
.EXAMPLE
    .\ESXi_Hardening.ps1 -InputObject esx01
.EXAMPLE
    Get-VMHost | .\ESXi_Hardening.ps1
.EXAMPLE
    .\ESXi_Hardening.ps1 -InputObject esx01 -Remediate
.NOTES
    Author: VirtualDataPro
    Version: 2.0
    Date: April 2026
    This script implements a custom hardening baseline and is not, by itself,
    a formal compliance certification tool (e.g. DISA STIG or CIS benchmark validation).
#>
[CmdletBinding()]
param(
  # Accepts a VMHost object from pipeline OR a hostname string
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
  [Alias('Name')]
  [object[]]$InputObject,
# Set to apply remediation; otherwise runs in assess-only mode
  [switch]$Remediate
)
 
$ESXiHosts = Get-VMhost $InputObject
 
$SysLogServers = ""
$NTPServers = @("192.168.1.1")
$ScratchPathPrefix = "/vmfs/"
$WelcomeMessage = "Company Property.  For authorized users only. Company reserves the right to access and disclose any data.
Users have no expectation of privacy.  Action will be taken for unauthorized usage.  Continuing use acknowledges
acceptance of these terms."

Function Invoke-EsxiHardeningCheck {
    Param(
        [parameter(ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]$VMHost,
        [switch]$Remediate
    )
    Begin {
        #Baseline Configuration Branch
        $HardeningBaseline =
        @{Type = "Advanced"; Name = "VMkernel.Boot.forceHyperthreadingMitigation"; Value = $true},
        @{Type = "Advanced"; Name = "VMkernel.Boot.hyperthreading"; Value = $true},
        @{Type = "Advanced"; Name = "VMkernel.Boot.hyperthreadingMitigation"; Value = $true},
        @{Type = "Advanced"; Name = "VMkernel.Boot.hyperthreadingMitigationIntraVM"; Value = $false},
        @{Type = "Advanced"; Name = "Syslog.global.logHost"; Value = $SysLogServers},
        @{Type = "Advanced"; Name = "Security.AccountLockFailures"; Value = 3},
        @{Type = "Advanced"; Name = "Annotations.WelcomeMessage"; Value = $WelcomeMessage},
        @{Type = "Advanced"; Name = "UserVars.HostClientSessionTimeout"; Value = 900},
        @{Type = "Advanced"; Name = "Config.HostAgent.log.level"; Value = "info"},
        @{Type = "Advanced"; Name = "Security.PasswordQualityControl"; Value = "similar=deny retry=3 min=disabled,disabled,disabled,disabled,15"},
        @{Type = "Advanced"; Name = "Security.PasswordHistory"; Value = 5},
        @{Type = "Advanced"; Name = "Config.HostAgent.plugins.solo.enableMob"; Value = $false},
        @{Type = "Advanced"; Name = "UserVars.ESXiShellInteractiveTimeOut"; Value = 0}, #Should be 900 but the requirement to keep SSH on Indefinately prevents this.
        @{Type = "Advanced"; Name = "Security.AccountUnlockTime"; Value = 900},
        @{Type = "Advanced"; Name = "Syslog.global.auditRecord.storageCapacity"; Value = 100},
        @{Type = "Advanced"; Name = "DCUI.Access"; Value = "root"},
        @{Type = "Advanced"; Name = "UserVars.ESXiShellTimeOut"; Value = 0}, #Should be 900 but the requirement to keep SSH on indefinately prevents this.
        @{Type = "Advanced"; Name = "UserVars.DcuiTimeOut"; Value = 600},
        @{Type = "Advanced"; Name = "Net.BlockGuestBPDU"; Value = 1},
        @{Type = "Advanced"; Name = "UserVars.SuppressShellWarning"; Value = 1}, #Should be 0 but Tripwire Requires SSH
        @{Type = "Advanced"; Name = "UserVars.SuppressHyperthreadWarning"; Value = 0},
        @{Type = "Advanced"; Name = "Syslog.global.certificate.checkSSLCerts"; Value = $true},
        @{Type = "Advanced"; Name = "Mem.MemEagerZero"; Value = 0},
        @{Type = "Advanced"; Name = "Config.HostAgent.vmacore.soap.sessionTimeout"; Value = 30},
        @{Type = "Advanced"; Name = "Syslog.global.logLevel"; Value = "info"},
        @{Type = "Advanced"; Name = "ScratchConfig.CurrentScratchLocation"; Value = $ScratchPathPrefix},
        @{Type = "Advanced"; Name = "Net.BMCNetworkEnable"; Value = 0},
        @{Type = "Advanced"; Name = "Mem.ShareForceSalting"; Value = 2},
        @{Type = "SSH"; Name = "hostbasedauthentication"; Value = "no"},
        @{Type = "SSH"; Name = "ciphers"; Value = "aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"},
        @{Type = "SSH"; Name = "permituserenvironment"; Value = "no"},
        @{Type = "SSH"; Name = "permittunnel"; Value = "no"},
        @{Type = "SSH"; Name = "allowtcpforwarding"; Value = "no"},
        @{Type = "SSH"; Name = "gatewayports"; Value = "no"},
        @{Type = "SSH"; Name = "clientalivecountmax"; Value = "3"},
        @{Type = "SSH"; Name = "clientaliveinterval"; Value = "200"},
        @{Type = "Kernel"; Name = "disableHwrng"; Value = $false},
        @{Type = "Kernel"; Name = "entropySources"; Value = 0},
        @{Type = "KeyPersistence"; Name = "keypersistence"; Value = $false},
        @{Type = "LocalAccount"; Name = "dcui"; Value = $false},
        @{Type = "Service"; Name = "TSM-SSH"; Label = "SSH"; Policy = "on";  Running = $true}, #Should be off but Tripwire Requires this
        @{Type = "Service"; Name = "sfcbd-watchdog"; Label = "CIM Server"; Policy = "off"; Running = $false},
        @{Type = "Service"; Name = "slpd"; Label = "slpd"; Policy = "off"; Running = $false},
        @{Type = "Service"; Name = "TSM"; Label = "ESXi Shell"; Policy = "off"; Running = $false},
        @{Type = "Syslog"; Name = 'logfilter'; Value = $false },
        @{Type = "NTP"; Name = "NTP"; Servers = $NTPServers; Policy = "on"; Running = $true},
        @{Type = "SNMP"; Name = "SNMP"; Value = $false},
        @{Type = "SecureBoot"; Name = "RequireSecureBoot"; Value = $true; Remediation = "Manual"},
        @{Type = "TPM"; Name = "TPM"; Value = "TPM"; Remediation = "ManualOrConditional"} | ForEach-Object {New-Object -Type psobject -Property $_}
    }

    Process {
        $VMhostCheck = If ($PSBoundParameters.ContainsKey("VMhost")) {$VMHost} Else {Get-VMHost}
        $EsxCli = Get-EsxCli -VMHost $VMHostCheck -V2
        foreach ($Item in $HardeningBaseline) {
            $CurrentValue = $null
            $Setting = $null
            $Compliant = $false
            
            #Assessment Branch
                switch ($Item.Type) {
                "Advanced" {
                    $Setting = Get-AdvancedSetting -Entity $VMHostCheck -Name $Item.Name
                    $CurrentValue = $Setting.Value
                 }
                "SSH" {
                    $CurrentValue = (
                        $EsxCli.system.ssh.server.config.list.Invoke() |
                        Where-Object {$_.Key -eq $Item.Name}
                    ).Value
                }
                "Syslog" {
                    $CurrentValue = $EsxCli.system.syslog.config.logfilter.get.Invoke().logfilteringenabled
                }
                "Kernel" {
                    $KernelSetting = $EsxCli.system.settings.kernel.list.Invoke() | Where-Object { $_.Name -eq $Item.Name }
                    $CurrentValue = $KernelSetting.Configured
                }
                "KeyPersistence" {
                    $CurrentValue = $EsxCli.system.security.keypersistence.get.Invoke().Enabled
                }
                "LocalAccount" {
                    $Account = ($EsxCli.system.account.list.Invoke() | Where-Object { $_.UserID -eq $Item.Name }).Shellaccess
                    if ($null -eq $Account) {
                        $CurrentValue = $null
                    }
                    else {
                        $CurrentValue = $Account
                    }
                }
                "Service" {
                    $Service = Get-VMHostService -VMHost $VMHostCheck | Where-Object {$_.Key -eq $Item.Name -or $_.Label -eq $Item.Label}
                    if ($null -eq $Service) {
                        $CurrentValue = $null
                    }
                    else {
                        $CurrentValue = [pscustomobject]@{
                            Policy  = $Service.Policy
                            Running = $Service.Running
                            Key     = $Service.Key
                            Label   = $Service.Label
                        }
                    }
                }
                "NTP" {
                    $NtpService = Get-VMHostService -VMHost $VMHostCheck | Where-Object { $_.Key -eq "ntpd" -or $_.Label -eq "NTP Daemon" }
                    $NtpConfig  = Get-VMHostNtpServer -VMHost $VMHostCheck
                    $CurrentValue = [pscustomobject]@{
                        Servers = @($NtpConfig)
                        Policy  = $NtpService.Policy
                        Running = $NtpService.Running
                    }
                }
                #Validated get-vmhostsnmp command usage -Server is correct but expects a string
                "SNMP" {
                    $Snmp = Get-VMHostSnmp -Server $VMHostCheck.Name
                    $CurrentValue = $Snmp.Enabled
                }
                "SecureBoot" {
                    $CurrentValue = $EsxCli.system.settings.encryption.get.Invoke().RequireSecureBoot
                }
                "TPM" {
                    $CurrentValue = $EsxCli.system.settings.encryption.get.Invoke().Mode
                }
            }

            #Compliance Branch
            if ($Item.Type -eq "Service") {
                $Compliant = (
                    $null -ne $CurrentValue -and
                    ([string]$CurrentValue.Policy).ToLower() -eq ([string]$Item.Policy).ToLower() -and
                    ([bool]$CurrentValue.Running -eq [bool]$Item.Running)
                )
            }
            elseif ($Item.Name -eq "ScratchConfig.CurrentScratchLocation") {
                $Compliant = (
                    $null -ne $CurrentValue -and
                    $CurrentValue.StartsWith($ScratchPathPrefix)
                )
            }
            elseif ($Item.Type -eq "NTP") {
                $ConfiguredServers = @($CurrentValue.Servers | Sort-Object)
                $DesiredServers    = @($Item.Servers | Sort-Object)
                $Compliant = (
                    $null -ne $CurrentValue -and
                    (@($ConfiguredServers) -join ',') -eq (@($DesiredServers) -join ',') -and
                    ([string]$CurrentValue.Policy).ToLower() -eq ([string]$Item.Policy).ToLower() -and
                    ([bool]$CurrentValue.Running -eq [bool]$Item.Running)
                )
            }
            elseif ($Item.Type -eq "SNMP") {
                $Compliant = ([bool]$CurrentValue -eq [bool]$Item.Value)
            }
            elseif ($Item.Type -eq "SecureBoot") {
                $Compliant = ([string]$CurrentValue).ToLower() -eq ([string]$Item.Value).ToLower()
            }
            elseif ($Item.Type -eq "TPM") {
                $Compliant = ([string]$CurrentValue).ToUpper() -eq ([string]$Item.Value).ToUpper()
            }
            else {
                $Compliant = ([string]$CurrentValue -eq [string]$Item.Value)
            }

            #Remediation Branch
            if ($Remediate -and -not $Compliant) {
                switch ($Item.Type) {
                    "Advanced" {
                        Set-AdvancedSetting -AdvancedSetting $Setting -Value $Item.Value -Confirm:$false
                    }
                    "SSH" {
                        $spec = $EsxCli.system.ssh.server.config.set.CreateArgs()
                        $spec.keyword = $Item.Name
                        $spec.value   = $Item.Value
                        $EsxCli.system.ssh.server.config.set.Invoke($spec)
                    }
                    "Syslog" {
                        $spec = $EsxCli.system.syslog.config.logfilter.set.CreateArgs()
                        $spec.enabled = [bool]$Item.Value
                        $EsxCli.system.syslog.config.logfilter.set.Invoke($spec)
                    }
                    "Kernel" {
                        $spec = $EsxCli.system.settings.kernel.set.CreateArgs()
                        $spec.setting = $Item.Name
                        $spec.value   = [string]$Item.Value
                        $EsxCli.system.settings.kernel.set.Invoke($spec) | Out-Null
                    }
                    "KeyPersistence" {
                        $spec = $EsxCli.system.security.keypersistence.set.CreateArgs()
                        $spec.enabled = [bool]$Item.Value
                        $EsxCli.system.security.keypersistence.set.Invoke($spec) | Out-Null
                    }
                    "LocalAccount" {
                        if (-not [bool]$Item.Value) {
                            $spec = $EsxCli.system.account.set.CreateArgs()
                            $spec.id = $Item.Name
                            $spec.shellaccess = $false
                            $EsxCli.system.account.set.Invoke($spec) | Out-Null
                        }
                    }
                    "Service" {
                        $Service = Get-VMHostService -VMHost $VMHostCheck | Where-Object {$_.Key -eq $Item.Name -or $_.Label -eq $Item.Label}
                        if ($null -ne $Service) {
                            if (($Service.Policy).ToLower() -ne ($Item.Policy).ToLower()) {
                                Set-VMHostService -HostService $Service -Policy $Item.Policy -Confirm:$false | Out-Null
                            }
                            if ([bool]$Item.Running -and -not $Service.Running) {
                                Start-VMHostService -HostService $Service -Confirm:$false | Out-Null
                            }
                            elseif (-not [bool]$Item.Running -and $Service.Running) {
                                Stop-VMHostService -HostService $Service -Confirm:$false | Out-Null
                            }
                        }
                    }
                    "NTP" {
                        $ExistingServers = @(Get-VMHostNtpServer -VMHost $VMHostCheck)
                        if ((@($ExistingServers | Sort-Object) -join ',') -ne (@($Item.Servers | Sort-Object) -join ',')) {
                            if ($ExistingServers.Count -gt 0) {
                                Remove-VMHostNtpServer -VMHost $VMHostCheck -NtpServer $ExistingServers -Confirm:$false | Out-Null
                            }
                                Add-VMHostNtpServer -VMHost $VMHostCheck -NtpServer $Item.Servers | Out-Null
                        }
                        $NtpService = Get-VMHostService -VMHost $VMHostCheck | Where-Object { $_.Key -eq "ntpd" -or $_.Label -eq "NTP Daemon" }
                        if (($NtpService.Policy).ToLower() -ne ($Item.Policy).ToLower()) {
                            Set-VMHostService -HostService $NtpService -Policy $Item.Policy -Confirm:$false | Out-Null
                        }
                        if ([bool]$Item.Running -and -not $NtpService.Running) {
                            Start-VMHostService -HostService $NtpService -Confirm:$false | Out-Null
                        }
                        elseif (-not [bool]$Item.Running -and $NtpService.Running) {
                            Stop-VMHostService -HostService $NtpService -Confirm:$false | Out-Null
                        }
                    }
                    #validated command usage set-vmhostsnmp expects arguments and accepts pipeline from get-vmhostsnmp
                    "SNMP" {
                        if (-not [bool]$Item.Value) {
                            Get-VMHostSnmp -Server $VMHostCheck.Name | Set-VMHostSnmp -Enabled:$Item.Value -Confirm:$false | Out-Null
                        }
                    }
                }
            }
            #Reporting Branch
            if ($Item.Type -eq "Service") {
                [pscustomobject]@{
                    VMHost            = $VMHostCheck.Name
                    Type              = $Item.Type
                    Name              = $Item.Name
                    Label             = $Item.Label
                    CurrentPolicy     = $CurrentValue.Policy
                    DesiredPolicy     = $Item.Policy
                    CurrentRunning    = $CurrentValue.Running
                    DesiredRunning    = $Item.Running
                    Configured        = $Compliant
                }
            }
            else {
                [pscustomobject]@{
                    VMHost      = $VMHostCheck.Name
                    Type        = $Item.Type
                    Name        = $Item.Name
                    Current     = $CurrentValue
                    Desired     = $Item.Value
                    Configured  = $Compliant
                }
            }
        }
    }
}
 
$ESXiHosts | Invoke-EsxiHardeningCheck -Remediate:$Remediate
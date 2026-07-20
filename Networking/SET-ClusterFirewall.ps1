################################################################################
#Author: VirtualDataPro
#Add or Remove IP's to Firewall
#v1.0 - MAY2014
#USAGE: ./ClusterFirewall "Cluster or Datacenter" <RuleSet> Add/Remove <IP/MASK>
#
#Example: ./ClusterFirewall Cluster1 sshServer add 192.168.1.0/24
#This would add 192.168.1.0/24 to the allowed firewall IP list for SSH Access in the Security Profile for all Hosts in Cluster1
#
#This was designed to simplify changes to host firewall rules for secure environments

################################################################################

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$vCluster,

    [Parameter(Mandatory=$True)]
    [ValidateSet("sshServer", "sshClient","nfsClient", "dhcp", "dns", "snmp", "ntpClient", "CIMHttpServer", "CIMHttpsServer", "CIMSLP", "iSCSI", "vpxHeartbeats", "updateManager", "faultTolerance", "webAccess", "vMotion", "vSphereClient", "activeDirectoryAll", "NFC", "HBR", "ftpClient", "httpClient", "gdbserver", "DVFilter", "DHCPv6", "DVSSync", "syslog", "IKED", "WOL", "vSPC", "remoteSerialPort", "netDump", "fdm", "dynamicruleset")]
    [string]$RuleSet,
    
    [Parameter(Mandatory=$True)]
    [ValidateSet("Add","Remove")]
    [string]$AddRemove,
    
    [Parameter(Mandatory=$True)]
    [string]$IPaddress
)

$vHosts = Get-VMHost -Location $vCluster

ForEach($vHost in $vHosts){
$esxcli = Get-EsxCli -VMHost $vHost
 If(($esxcli.network.firewall.ruleset.allowedip.list($RuleSet) | select AllowedIPAddresses).AllowedIPAddresses -eq "All"){
  If($AddRemove -eq "Add"){
   Write-Host "Configuring $RuleSet on $vHost to ALLOW $IPaddress"  
   $esxcli.network.firewall.ruleset.set($False, $True, $RuleSet)
   $esxcli.network.firewall.ruleset.allowedip.add($IPaddress, $RuleSet)
   $esxcli.network.firewall.refresh()
  }
  If($AddRemove -eq "Remove"){
   Write-Host "Configuring $RuleSet on $vHost to REMOVE $IPaddress" 
   $esxcli.network.firewall.ruleset.set($False, $True, $RuleSet)
   $esxcli.network.firewall.ruleset.allowedip.remove($IPaddress, $RuleSet)
   $esxcli.network.firewall.refresh()
  }
 }
 Else{
  if($AddRemove -eq "Add"){
   Write-Host "Configuring $RuleSet on $vHost to ALLOW $IPaddress"  
   $esxcli.network.firewall.ruleset.allowedip.add($IPaddress, $RuleSet)
   $esxcli.network.firewall.refresh()
  }
  if($AddRemove -eq "Remove"){
   Write-Host "Configuring $RuleSet on $vHost to REMOVE $IPaddress"        
   $esxcli.network.firewall.ruleset.allowedip.remove($IPaddress, $RuleSet)
   $esxcli.network.firewall.refresh()
  }
 }
}
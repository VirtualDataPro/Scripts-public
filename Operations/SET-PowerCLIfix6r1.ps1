#
# PowerCLI 6 R1 installation
#
 
# Variables
$pcli64Install = 'HKLM:\SOFTWARE\Wow6432Node\VMware, Inc.\VMware vSphere PowerCLI'
$pcli32Install = 'HKLM:\SOFTWARE\VMware, Inc.\VMware vSphere PowerCLI'
$installPath = 'InstallPath'
$pcliVersion = 'InstalledVersion'
$psUserModPath = 'HKCU:\Environment'
$psMachModPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
$psModPath = 'PSModulePath'
$vimConsoleFileName = 'vim.psc1'
 
# 32- vs 64-bit platform
if([Environment]::Is64BitProcess){
    $reg = $pcli64Install
}
else{
    $reg = $pcli32Install
}
 
# Installation Path
$path = Get-ItemProperty -Path $reg -Name $installPath | Select-Object -ExpandProperty $installPath
 
# Version
$versionStr = Get-ItemProperty -Path $reg -Name $pcliVersion | Select-Object -ExpandProperty $pcliVersion
 
# Check we are dealing with PowerCLI 6 R1
$version = [Version]$versionStr
if($version.Major -ne 6 -and $version.Revision -ne 7254){
    Throw 'This script is intended for PowerCLI 6 R1'
}
 
# Get PSModulePath
$modUserPath = Get-ItemProperty -Path $psUserModPath -Name $PSModulePath | Select-Object -ExpandProperty $psModPath
$modMachPath = Get-ItemProperty -Path $psMachModPath -Name $PSModulePath | Select-Object -ExpandProperty $psModPath
 
# Correct PSModulePath
if($modMachPath -notcontains "$($path)Modules"){
    [Environment]::SetEnvironmentVariable($psModPath,"$($modMachPath);$($path)Modules\",'Machine')
}
if($modUserPath -contains "$($path)Modules"){
    $newModUserPath = $modUserPath.Replace("$($path)Modules",'')
    if($newModUserPath){
        [Environment]::SetEnvironmentVariable($psUserModPath,$newModUserPath,'User')
    }
    else{
        [Environment]::SetEnvironmentVariable($psModPath,$null,'User')
    }
    # Refresh the modules path
    $env:PSModulePath = [Environment]::GetEnvironmentVariable($psModPath,'Machine')
}
 
# Correct Console file
$file = "$($path)$($vimConsoleFileName)"
Copy-Item -Path $file -Destination "$($file).original"
Set-ItemProperty -Path $file -Name IsReadOnly -Value $false
$include = $true
&{(Get-Content -Path $file) | ForEach-Object{
    if($_ -match '  <PSModules>'){
        $include = $false
    }
    if($_ -match '</PSConsoleFile>'){
        $include = $true
    }
    if($include){
        $_
    }
}} | Set-Content -Path $file
Set-ItemProperty -Path $file -Name IsReadOnly -Value $true
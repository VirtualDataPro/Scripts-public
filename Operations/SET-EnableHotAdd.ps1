param(
  [parameter(mandatory = $true)]
  [string[]]$param
  )

Function Enable-vCpuAndMemHotAdd($vm){
    $gvm = Get-vm $vm 
    If($gvm.ExtensionData.Config.MemoryHotAddEnabled -ne $true -or $gvm.ExtensionData.Config.CpuHotAddEnabled -ne $true){
        $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
        $spec.CpuHotAddEnabled = $true
        $spec.MemoryHotAddEnabled = $true
        $gvm.extensiondata.ReconfigVM_Task($spec)
    }
}

<#Function Enable-vCpuAndMemHotAdd($vm){
    $gvm = get-vm $vm | get-view
    $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $extra1 = New-Object VMware.Vim.optionvalue
    $extra1.Key="mem.hotadd"
    $extra1.Value="true"
    $vmConfigSpec.extraconfig += $extra1
    $extra2 = New-Object VMware.Vim.optionvalue
    $extra2.Key="vcpu.hotadd"
    $extra2.Value="true"
    $vmConfigSpec.extraconfig += $extra2
    $gvm.ReconfigVM($vmConfigSpec)
}
#>
<#Function Enable-HotAdd($vm){
    $vmview = Get-vm $vm #| Get-View 
    $Spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.CpuHotAddEnabled = $true
    $spec.MemoryHotAddEnabled = $true

    #$spec = New-Object VMware.Vim.optionvalue
    #$extra1.Key="mem.hotadd"
    #$extra1.Value="true"
    #$vmConfigSpec.extraconfig += $extra1

    #$extra2 = New-Object VMware.Vim.optionvalue
    #$extra2.Key="vcpu.hotadd"
    #$extra2.Value="true"
    #$vmConfigSpec.extraconfig += $extra2

    $vmview.extensiondata.ReconfigVM($Spec)
}
#>
Enable-vCpuAndMemHotAdd $Param



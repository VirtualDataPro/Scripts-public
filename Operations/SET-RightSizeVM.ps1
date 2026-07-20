Function Enable-vCpuAndMemHotAdd($vm){
    $gvm = Get-vm $vm 
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.CpuHotAddEnabled = $true
    $spec.MemoryHotAddEnabled = $true
    $gvm.extensiondata.ReconfigVM_Task($spec)
}

#Get-VM
#Check VMtools status
#Shutdown guest os
#Sleep/wait 900sec/PowerOff
#Enable-vCpuAndMemHotAdd
#Right-Size VM
#Set-CDDrive -nomedia
#PowerOn VM
#Next VM
#Post Validation
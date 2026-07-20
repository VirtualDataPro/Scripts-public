Function Get-VMMemOverhead {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FullName')]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl[]]$VM
    ) 

    process {
        # Retrieve VM & ESXi MoRef
        $vmMoref = $VM.ExtensionData.MoRef
        $vmHostMoref = $VM.ExtensionData.Runtime.Host

        # Retrieve Overhead Memory Manager
        $overheadMgr = Get-View ($global:DefaultVIServer.ExtensionData.Content.OverheadMemoryManager)

        # Get VM Memory overhead
        $overhead = $overheadMgr.LookupVmOverheadMemory($vmMoref,$vmHostMoref)
        #Write-Host $VM.Name "has overhead of" ([math]::Round($overhead/1MB,2)).ToString() "MB memory`n"
        $VM | select Name, @{N="MemoryOverheadMB";E={([math]::Round($overhead/1MB,2))}}
    }
}
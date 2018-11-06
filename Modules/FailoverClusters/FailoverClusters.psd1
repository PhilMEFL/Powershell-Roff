﻿@{
    GUID="{cc3e946b-9141-48c2-95d8-d9e56594416a}"
    Author="Microsoft Corporation"
    CompanyName="Microsoft Corporation"
    Copyright="© Microsoft Corporation. All rights reserved."
    ModuleVersion="2.0.0.0"
    PowerShellVersion="3.0"
    CLRVersion="4.0"
    HelpInfoUri="https://go.microsoft.com/fwlink/?linkid=390770"
    TypesToProcess="FailoverClusters.Types.ps1xml"
    FormatsToProcess="FailoverClusters.Format.ps1xml"
    NestedModules = @(
        "Microsoft.FailoverClusters.PowerShell.dll", 
        "Microsoft.FailoverClusters.PowerShell.psm1",
        'Microsoft.FailoverClusters.Health.PowerShell.psm1',
        'ClusterFaultDomain.cdxml',
        'ClusterStorageNode.cdxml',
        'ClusterStorageSpacesDirect.cdxml',
        'ClusterCollection.cdxml',
        'ClusterHealthService.cdxml',
        'ClusterNode.cdxml'
        )
    AliasesToExport=@("Add-VMToCluster",
        "Disable-ClusterS2D",
        "Enable-ClusterS2D",
        "Get-ClusterS2D",
        "Remove-VMFromCluster",
        "Repair-ClusterS2D",
        "Set-ClusterS2D",
        "Set-ClusterS2DDisk",
        "Get-ClusterPerf"
        )
    FunctionsToExport = @(  
        "Add-ClusterGroupSetDependency",
        "Add-ClusterGroupToSet",
        "Add-ClusterStorageNode",

        "Get-ClusterGroupSet",
        "Get-ClusterGroupSetDependency",

        "New-ClusterGroupSet",
        "New-ClusterAvailabilitySet",

        "Set-ClusterGroupSet",

        "Remove-ClusterGroupFromSet",
        "Remove-ClusterGroupSet",
        "Remove-ClusterGroupSetDependency",

        "Get-ClusterNodeSupportedVersion",

        "Disable-ClusterStorageSpacesDirect",
        "Enable-ClusterStorageSpacesDirect",
        'Get-ClusterDiagnosticInfo',
        "Get-ClusterFaultDomain",
        "Get-ClusterFaultDomainXML",
        "Get-ClusterStorageNode",
        "Get-ClusterStorageSpacesDirect",
        "New-ClusterFaultDomain",
        "Remove-ClusterFaultDomain",
        "Remove-ClusterStorageNode",
        "Repair-ClusterStorageSpacesDirect",
        "Set-ClusterFaultDomain",
        "Set-ClusterFaultDomainXML",
        "Set-ClusterStorageNode",
        "Set-ClusterStorageSpacesDirect",
        "Set-ClusterStorageSpacesDirectDisk",

        'Get-ClusterPerformanceHistory',
        'Get-HealthFault'
)
    CmdletsToExport="Add-ClusterCheckpoint",
                    "Add-ClusterDisk",
                    "Add-ClusterFileServerRole",
                    "Add-ClusterGenericApplicationRole",
                    "Add-ClusterGenericScriptRole",
                    "Add-ClusterGenericServiceRole",
                    "Add-ClusterGroup",
                    "Add-ClusteriSCSITargetServerRole",
                    "Add-ClusterNode",
                    "Add-ClusterResource",
                    "Add-ClusterResourceDependency",
                    "Add-ClusterResourceType",
                    "Add-ClusterScaleOutFileServerRole",
                    "Add-ClusterServerRole",
                    "Add-ClusterSharedVolume",
                    "Add-ClusterVirtualMachineRole",
                    "Add-ClusterVMMonitoredItem",
                    "Block-ClusterAccess",
                    "Clear-ClusterDiskReservation",
                    "Clear-ClusterNode",
                    "Get-Cluster",
                    "Get-ClusterAccess",
                    "Get-ClusterAvailableDisk",
                    "Get-ClusterCheckpoint",
                    "Get-ClusterGroup",
                    "Get-ClusterLog",
                    "Get-ClusterNetwork",
                    "Get-ClusterNetworkInterface",
                    "Get-ClusterNode",
                    "Get-ClusterOwnerNode",
                    "Get-ClusterParameter",
                    "Get-ClusterQuorum",
                    "Get-ClusterResource",
                    "Get-ClusterResourceDependency",
                    "Get-ClusterResourceDependencyReport",
                    "Get-ClusterResourceType",
                    "Get-ClusterSharedVolume",
                    "Get-ClusterSharedVolumeState",
                    "Get-ClusterVMMonitoredItem",
                    "Grant-ClusterAccess",
                    "Move-ClusterGroup",
                    "Move-ClusterResource",
                    "Move-ClusterSharedVolume",
                    "Move-ClusterVirtualMachineRole",
                    "New-Cluster",
                    "New-ClusterNameAccount",
                    "Remove-Cluster",
                    "Remove-ClusterAccess",
                    "Remove-ClusterCheckpoint",
                    "Remove-ClusterGroup",
                    "Remove-ClusterNameAccount",
                    "Remove-ClusterNode",
                    "Remove-ClusterResource",
                    "Remove-ClusterResourceDependency",
                    "Remove-ClusterResourceType",
                    "Remove-ClusterSharedVolume",
                    "Remove-ClusterVMMonitoredItem",
                    "Reset-ClusterVMMonitoredState",
                    "Resume-ClusterNode",
                    "Resume-ClusterResource",
                    "Set-ClusterLog",
                    "Set-ClusterOwnerNode",
                    "Set-ClusterParameter",
                    "Set-ClusterQuorum",
                    "Set-ClusterResourceDependency",
                    "Start-Cluster",
                    "Start-ClusterGroup",
                    "Start-ClusterNode",
                    "Start-ClusterResource",
                    "Stop-Cluster",
                    "Stop-ClusterGroup",
                    "Stop-ClusterNode",
                    "Stop-ClusterResource",
                    "Suspend-ClusterNode",
                    "Suspend-ClusterResource",
                    "Test-Cluster",
                    "Test-ClusterResourceFailure",
                    "Update-ClusterIPResource",
                    "Update-ClusterNetworkNameResource",
                    "Update-ClusterVirtualMachineConfiguration",
                    "Update-ClusterFunctionalLevel"


    RequiredAssemblies=(Join-Path $ENV:WINDIR "Cluster\FailoverClusters.ObjectModel.dll"),
                       (Join-Path $ENV:WINDIR "Cluster\Microsoft.FailoverClusters.Framework.dll"),
                       (Join-Path $ENV:WINDIR "Cluster\Microsoft.FailoverClusters.Validation.dll"),
                       (Join-Path $ENV:WINDIR "Cluster\FailoverClusters.Common.dll"),
                       (Join-Path $ENV:WINDIR "Cluster\FailoverClusters.Validation.Common.dll"),
                       (Join-Path $ENV:WINDIR "Cluster\Microsoft.FailoverClusters.UI.Common.dll"),
                       (Join-Path $ENV:WINDIR "Cluster\FailoverClusters.Agent.Interop.dll"),
                       (Join-Path $ENV:WINDIR "Cluster\FailoverClusters.FcAgent.Interop.dll"),
                       (Join-Path $ENV:WINDIR "Cluster\FailoverClusters.Wizards.dll")
}
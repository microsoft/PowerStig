# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage Adobe Application STIG settings
    .PARAMETER AdobeApp
        The Adobe Application for which a DISA STIG configuration is generated, i.e. 'AcrobatReader'
    .PARAMETER StigVersion
        The version of the Adobe Application STIG to apply and/or monitor
    .PARAMETER Exception
        A hashtable of StigId=Value key pairs that are injected into the STIG data and applied to
        the target node. The title of STIG settings are tagged with the text 'Exception' to identify
        the exceptions to policy across the data center when you centralize DSC log collection.
    .PARAMETER OrgSettings
        The path to the xml file that contains the local organizations preferred settings for STIG
        items that have allowable ranges.  The OrgSettings parameter also accepts a hashtable for
        values that need to be modified.  When a hashtable is used, the specified values take
        presidence over the values defined in the org.default.xml file.
    .PARAMETER SkipRule
        The SkipRule Node is injected into the STIG data and applied to the taget node. The title
        of STIG settings are tagged with the text 'Skip' to identify the skips to policy across the
        data center when you centralize DSC log collection.
    .PARAMETER SkipRuleType
        All STIG rule IDs of the specified type are collected in an array and passed to the Skip-Rule
        function. Each rule follows the same process as the SkipRule parameter.
#>
configuration Vsphere
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Version,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VsphereHostIP,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VcenterServerIP,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $VsphereCredential,

        [Parameter()]
        [string]
        $AcceptanceLevel,

        [Parameter()]
        [hashtable]
        $AdvancedSetting,

        [Parameter()]
        [string[]]
        $NtpServer,

        [Parameter()]
        [string]
        $ServiceRunning,

        [Parameter()]
        [string]
        $ServiceName,

        [Parameter()]
        [string]
        $ServicePolicy,

        [Parameter()]
        [string]
        $KernelActiveDumpPartitionEnabled,

        [Parameter()]
        [string]
        $AllowPromiscuous,

        [Parameter()]
        [string]
        $ForgedTransmits,

        [Parameter()]
        [string]
        $MacChanges,

        [Parameter()]
        [string]
        $AllowPromiscuousInherited,

        [Parameter()]
        [string]
        $ForgedTransmitsInherited,

        [Parameter()]
        [string]
        $MacChangesInherited,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [version]
        $StigVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Exception,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [object]
        $OrgSettings,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $SkipRuleType
    )

    ##### BEGIN DO NOT MODIFY #####
    $stig = [STIG]::New('Vsphere', $Version, $StigVersion)
    $stig.LoadRules($OrgSettings, $Exception, $SkipRule, $SkipRuleType)
    ##### END DO NOT MODIFY #####

    Import-DscResource -ModuleName Vmware.vSphereDSC -ModuleVersion 2.1.0.58
    . "$resourcePath\Vsphere.VmHostAcceptanceLevel.ps1"
    . "$resourcePath\Vsphere.VmHostAdvancedSettings.ps1"
    . "$resourcePath\Vsphere.VMHostNtpSettings.ps1"
    . "$resourcePath\Vsphere.VmHostService.ps1"
    . "$resourcePath\Vsphere.VmHostSNMPAgent.ps1"
    . "$resourcePath\Vsphere.VmHostVMKernelActiveDumpPartition.ps1"
    . "$resourcePath\Vsphere.VmHostVssSecurity.ps1"
    . "$resourcePath\Vsphere.VmHostVssPortGroupSecurity.ps1"

    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.10.0.0
    . "$resourcePath\windows.Script.skip.ps1"
}

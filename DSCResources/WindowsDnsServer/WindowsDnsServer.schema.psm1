# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage the Windows Server DNS STIG settings
    .PARAMETER OsVersion
        The version of the server operating system STIG to apply and monitor
    .PARAMETER StigVersion
        The version of the Windows Server DNS STIG to apply and/or monitor
    .PARAMETER ForestName
        A string that sets the forest name for items such as security group. The input should be the FQDN of the forest.
        If this is omitted the forest name of the computer that generates the configuration will be used.
    .PARAMETER DomainName
        A string that sets the domain name for items such as security group. The input should be the FQDN of the domain.
        If this is omitted the domain name of the computer that generates the configuration will be used.
    .PARAMETER Exception
        A hashtable of StigId=Value key pairs that are injected into the STIG data and applied to
        the target node. The title of STIG settings are tagged with the text ‘Exception’ to identify
        the exceptions to policy across the data center when you centralize DSC log collection.
    .PARAMETER OrgSettings
        The path to the xml file that contains the local organizations preferred settings for STIG
        items that have allowable ranges.
    .PARAMETER SkipRule
        The SkipRule Node is injected into the STIG data and applied to the taget node. The title
        of STIG settings are tagged with the text 'Skip' to identify the skips to policy across the
        data center when you centralize DSC log collection.
    .PARAMETER SkipRuleType
        All STIG rule IDs of the specified type are collected in an array and passed to the Skip-Rule
        function. Each rule follows the same process as the SkipRule parameter.
#>
Configuration WindowsDnsServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OsVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [version]
        $StigVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ForestName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $DomainName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [sashtable]
        $Exception,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
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
    $stig = [STIG]::New('WindowsServer', $OsVersion, 'Dns' , $StigVersion)
    $stig.LoadRules($OrgSettings, $Exception, $SkipRule, $SkipRuleType)

    # $resourcePath is exported from the helper module in the header
    # Process Skipped rules
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    . "$resourcePath\windows.Script.skip.ps1"
    ##### END DO NOT MODIFY #####

    Import-DscResource -ModuleName AccessControlDsc -ModuleVersion 1.2.0.0
    . "$resourcePath\windows.AccessControl.ps1"

    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    . "$resourcePath\windows.Script.RootHint.ps1"

    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.4.0.0
    . "$resourcePath\windows.UserRightsAssignment.ps1"

    Import-DscResource -ModuleName xDnsServer -ModuleVersion 1.11.0.0
    . "$resourcePath\windows.xDnsServerSetting.ps1"

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.3.0.0
    . "$resourcePath\windows.xRegistry.ps1"

    Import-DscResource -ModuleName xWinEventLog -ModuleVersion 1.2.0.0
    . "$resourcePath\windows.xWinEventLog.ps1"
}

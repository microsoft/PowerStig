# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage the Microsoft Office DISA STIG settings
    .PARAMETER OfficeApp
        The version of the Microsoft Office application the STIG applies to
    .PARAMETER StigVersion
        The version of the Microsoft Office DISA STIG to apply and/or monitor
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
Configuration Office
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OfficeApp,

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
    $stig = [STIG]::New('Office', $OfficeApp, $StigVersion)
    $stig.LoadRules($OrgSettings, $Exception, $SkipRule, $SkipRuleType)
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.3.0.0
    ##### END DO NOT MODIFY #####

    Import-DscResource -ModuleName PolicyFileEditor -ModuleVersion 3.0.1
    . "$resourcePath\windows.cAdministrativeTemplateSetting.ps1"

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.3.0.0
    . "$resourcePath\windows.xRegistry.ps1"
    . "$resourcePath\windows.xScript.skip.ps1"
}

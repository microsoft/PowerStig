# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage the Browser STIG settings

    .PARAMETER BrowserVersion
        The version of the Browser the STIG applies to

    .PARAMETER StigVersion
        The version of the STIG to apply and monitor

    .PARAMETER Exception
        A hash table of key value pairs that are injected into the STIG data and applied to
        the target node. The title of STIG setting is tagged with the text ‘Exception’ to identify
        the exceptions to policy across the data center when you centralize DSC log collection.

    .PARAMETER OrgSettings
        The path to the XML file that contains the local organizations preferred settings for STIG
        items that have allowable ranges.

    .PARAMETER SkipRule
        The SkipRule Node is injected into the STIG data and applied to the target node. The title
        of STIG settings are tagged with the text 'Skip' to identify the skips to policy across the
        data center when you centralize DSC log collection.

    .PARAMETER SkipRuleType
        All STIG rule IDs of the specified type are collected in an array and passed to the Skip-Rule
        function. Each rule follows the same process as the SkipRule parameter.
#>
Configuration Browser
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('IE11')]
        [string]
        $BrowserVersion,

        [Parameter()]
        [ValidateSet('1.13', '1.15', '1.16')]
        [ValidateNotNullOrEmpty()]
        [version]
        $StigVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Exception,

        [Parameter()]
        [psobject]
        $OrgSettings,

        [Parameter()]
        [psobject]
        $SkipRule,

        [Parameter()]
        [psobject]
        $SkipRuleType
    )

    ##### BEGIN DO NOT MODIFY #####
    <#
        The exception, skipped rule, and organizational settings functionality
        is universal across all composites, so the code to process it is in a
        central file that is dot sourced into each composite.
    #>
    $dscResourcesPath = Split-Path -Path $PSScriptRoot -Parent
    $userSettingsPath = Join-Path -Path $dscResourcesPath -ChildPath 'stigdata.usersettings.ps1'
    . $userSettingsPath
    ##### END DO NOT MODIFY #####

    $technology        = [Technology]::Windows
    $technologyVersion = [TechnologyVersion]::New( 'All', $technology )
    $technologyRole    = [TechnologyRole]::New( $BrowserVersion, $technologyVersion )
    $stigDataObject    = [StigData]::New( $StigVersion, $OrgSettings, $technology,
                                          $technologyRole, $technologyVersion, $Exception,
                                          $SkipRuleType, $SkipRule )
    #### BEGIN DO NOT MODIFY ####
    # $StigData is used in the resources that are dot sourced below
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments",'')]
    $StigData = $StigDataObject.StigXml

    # $resourcePath is exported from the helper module in the header

    # This is required to process Skipped rules
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    . "$resourcePath\windows.Script.skip.ps1"
    ##### END DO NOT MODIFY #####

    Import-DscResource -ModuleName PolicyFileEditor -ModuleVersion 3.0.1
    . "$resourcePath\windows.cAdministrativeTemplateSetting.ps1"

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.3.0.0
    . "$resourcePath\windows.xRegistry.ps1"
}

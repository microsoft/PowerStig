# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage the Browser STIG settings

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
Configuration FireFox
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $InstallDirectory = "$env:ProgramFiles\Mozilla Firefox",

        [Parameter()]
        [ValidateSet('4.21')]
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

    $technology        = [Technology]::Mozilla
    $technologyVersion = [TechnologyVersion]::New( 'All', $technology )
    $technologyRole    = [TechnologyRole]::New( 'FireFox', $technologyVersion )
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

    Import-DscResource -ModuleName FileContentDsc # add version
    . "$resourcePath\firefox.ReplaceText.ps1"
}

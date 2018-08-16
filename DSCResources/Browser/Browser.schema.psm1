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
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('IE11')]
        [string]
        $BrowserVersion,

        [Parameter()]
        [ValidateSet('1.13','1.15','1.16')]
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

    #region Add required data to XML
    if ( $Exception )
    {
        $exceptionsObject = [StigException]::ConvertFrom( $Exception )
    }
    else
    {
        $exceptionsObject = $null
    }

    if ( $SkipRule )
    {
        $skipRuleObject = [SkippedRule]::ConvertFrom( $SkipRule )
    }
    else
    {
        $skipRuleObject = $null
    }

    if ( $SkipRuleType )
    {
        $skipRuleTypeObject = [SkippedRuleType]::ConvertFrom( $SkipRuleType )
    }
    else
    {
        $skipRuleTypeObject = $null
    }

    if ( $OrgSettings )
    {
        $orgSettingsObject = Get-OrgSettingsObject -OrgSettings $OrgSettings
    }
    else
    {
        $orgSettingsObject = $null
    }
    #endregion

    $technology        = [Technology]::Windows
    $technologyVersion = [TechnologyVersion]::New( 'All', $technology )
    $technologyRole    = [TechnologyRole]::New( $BrowserVersion, $technologyVersion )
    $StigDataObject    = [StigData]::New( $StigVersion, $orgSettingsObject, $technology,
                                       $technologyRole, $technologyVersion, $exceptionsObject,
                                       $skipRuleTypeObject, $skipRuleObject )

    $StigData = $StigDataObject.StigXml
    # $resourcePath is exported from the helper module in the header

    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    . "$resourcePath\windows.Registry.ps1"
}

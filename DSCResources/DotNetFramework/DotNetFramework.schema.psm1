# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage the DotNetFramework 4.0 STIG settings

    .PARAMETER FrameworkVersion
        The version of .NET the STIG applies to

    .PARAMETER StigVersion
        The version of the DotNetFramework STIG to apply and/or monitor

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
Configuration DotNetFramework
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('DotNet4')]
        [string]
        $FrameworkVersion,

        [Parameter()]
        [ValidateSet('1.4')]
        [ValidateNotNullOrEmpty()]
        [version]
        $StigVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Exception,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $OrgSettings,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $SkipRule,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $SkipRuleType
    )

    <#
        This file is dot sourced here becasue the code it contains applies
        to all composites. It simply processes the exceptions, skipped rules,
        and organizational objects that were provided to the composite and
        converts then into the approperate class for the StigData class
        constructor
    #>
    . ..\stigdata.usersettings.ps1

    $technology        = [Technology]::Windows
    $technologyVersion = [TechnologyVersion]::New( "All", $technology )
    $technologyRole    = [TechnologyRole]::New( $FrameworkVersion, $technologyVersion )
    $stigDataObject    = [StigData]::New( $StigVersion, $orgSettingsObject, $technology,
                                          $technologyRole, $technologyVersion, $Exception,
                                          $SkipRuleType, $SkipRule )

    $StigData = $StigDataObject.StigXml

    # $resourcePath is exported from the helper module in the header
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    . "$resourcePath\windows.Registry.ps1"

    ## BEGIN DO NOT REMOVE
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    # This is required to process Skipped rules
    . "$resourcePath\windows.Script.skip.ps1"
    ## END DO NOT REMOVE
}

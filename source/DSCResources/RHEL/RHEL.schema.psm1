# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage Redhat Enterprise Linux STIG settings
    .PARAMETER OsVersion
        The version of Redhat Enterprise Linux operating system STIG to apply and monitor
    .PARAMETER StigVersion
        Uses the OsVersion to select the version of the STIG to apply and monitor. If this parameter
        is not provided, the most recent version of the STIG is automatically selected.
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
configuration RHEL
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
    $stig = [STIG]::New('RHEL', $OsVersion, $StigVersion)
    $stig.LoadRules($OrgSettings, $Exception, $SkipRule, $SkipRuleType)
    ##### END DO NOT MODIFY #####

    Import-DscResource -ModuleName nx -ModuleVersion 1.0
    . "$resourcePath\linux.nxPackage.ps1"
    . "$resourcePath\linux.nxFileLine.ps1"
    . "$resourcePath\linux.nxService.ps1"
}

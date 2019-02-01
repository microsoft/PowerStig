#region Header
using module ..\helper.psm1
using module ..\..\PowerStig.psm1
#endregion Header

#region Composite
<#
    .SYNOPSIS
        A composite DSC resource to manage the IIS Server STIG settings

    .PARAMETER OsVersion
        The version of the server operating system STIG to apply and monitor

    .PARAMETER LogPath
        The path to store log information

    .PARAMETER StigVersion
        The version of the IIS Server STIG to apply and/or monitor

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

    .EXAMPLE
        In this example the latest version of the IIS Server STIG is applied.

        Import-DscResource -ModuleName PowerStigDsc

        Node localhost
        {
            IisServer 'IISServerConfiguration'
            {
                OsVersion = '2012R2'
                StigVersion = '1.3'
            }
        }
#>
Configuration IisServer
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('2012R2')]
        [string]
        $OsVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $LogPath,

        [Parameter()]
        [ValidateSet('1.3','1.5')]
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
    $technologyVersion = [TechnologyVersion]::New( $OsVersion, $technology )
    $technologyRole    = [TechnologyRole]::New( 'IISServer', $technologyVersion )
    $stigDataObject    = [STIG]::New( $StigVersion, $OrgSettings, $technology,
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

    Import-DscResource -ModuleName AccessControlDsc -ModuleVersion 1.2.0.0
    . "$resourcePath\windows.AccessControl.ps1"

    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    . "$resourcePath\windows.WindowsFeature.ps1"

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.3.0.0
    . "$resourcePath\windows.xRegistry.ps1"

    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 2.3.0.0
    . "$resourcePath\windows.xIisMimeTypeMapping.ps1"
    . "$resourcePath\windows.WebConfigProperty.ps1"
    . "$resourcePath\windows.xIisLogging.ps1"
}
#endregion Composite

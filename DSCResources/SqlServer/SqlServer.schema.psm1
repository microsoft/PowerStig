# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage the SQL STIG settings.

    .PARAMETER SqlVersion
        The version of SQL being used E.g. 'Server2012'

    .PARAMETER SqlRole
        There are two STIGs that cover the scope of SQL. SQL Instance covers each instance of SQL on a server
        SQL Database covers each Database within an Instance.

    .PARAMETER StigVersion
        The version of the SQL STIG to apply and/or monitor

    .PARAMETER ServerInstance
        The name of the SQL Instance that the STIG data will be applied to.
        To define a specific Instance you must use the following format: "ComputerName\InstanceName"
        If you want to use the default instance, you only need to use the hosting computer name.

    .PARAMETER Database
        The Name of the database that you would like to be applied to. This parameter is only used
        for the SQL Database STIG.

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
Configuration SqlServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('2012', '2016')]
        [string]
        $SqlVersion,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Database', 'Instance')]
        [string]
        $SqlRole,

        [Parameter()]
        [ValidateSet('1.3', '1.16', '1.17', '1.18')]
        [ValidateNotNullOrEmpty()]
        [version]
        $StigVersion,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ServerInstance,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Database,

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

    $technology        = [Technology]::SqlServer
    $technologyVersion = [TechnologyVersion]::New( $SqlVersion, $technology )
    $technologyRole    = [TechnologyRole]::New( $SqlRole, $technologyVersion )
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

    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion '12.1.0.0'
    . "$resourcePath\SqlServer.ScriptQuery.ps1"

    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion '2.4.0.0'
    . "$resourcePath\Windows.SecurityOption.ps1"
}

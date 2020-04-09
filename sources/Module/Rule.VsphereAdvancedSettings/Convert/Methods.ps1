# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Takes the AdvancedSettings property from a VsphereRule.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-VsphereAdvancedSettings
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if ($CheckContent -match 'Get-AdvancedSetting')
    {
        $matchName = ($CheckContent | Select-String -Pattern $AdvancedSettingNameList.Values.Values).matches.groups[1].value

        foreach($item in $AdvancedSettingDataList.Values.Values)
        {
            if ($null -eq $matchValue)
            {
                $matchValue = ($Checkcontent | Select-String -Pattern $item).Matches.Value | Get-Unique
            }
        }

        $advancedSettings = "'{0}' = '{1}'" -f $matchName, $matchValue
    }

    switch($matchName)
    {
        {$PSItem -eq "Net.DVFilterBindIpAddress"}
        {
            $advancedSettings = "'{0}' = ''" -f $matchName
        }
        {$PSItem -eq "Syslog.global.logHost" -or $PSItem -eq "Config.HostAgent.plugins.hostsvc.esxAdminsGroup" -or $PSItem -eq "Syslog.global.logDir"}
        {
            $advancedSettings = $null
        }
    }

    if ($null -ne $advancedSettings)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found Advanced Setting: {0}" -f $advancedSettings)
        return $advancedSettings
    }
    else
    {
        return $null
    }
}

function Get-OrganizationValueTestString
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Id
    )
    # TO DO - This should not be a static list
    switch ( $Id )
    {
        { $PsItem -match 'V-93955' }
        {
            return '{0} is set to "Syslog.global.logHost" = "site specific log host"'
        }
        { $PsItem -match 'V-94037' }
        {
            return '"{0}" is set to "Syslog.global.logDir" = "site specific log storage location"'
        }
        default
        {
            return $null
        }
    }
}
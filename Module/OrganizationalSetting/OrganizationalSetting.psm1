# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
# Header

<#
    .SYNOPSIS
        This class describes an OrganizationalSetting

    .DESCRIPTION
        The OrganizationalSetting class describes OrganizationalSetting, a value
        for a Stig Rule that is specific to the implementing organization. Stigs
        requiring organizational settings will be accompanied by a default
        settings file. These can either be used as-is or replaced with values
        specific to the implementing organization. This Xml file will subsequently
        be transformed into OrganizationalSetting objects to be passed into and
        used in the StigData class constructor.

    .PARAMETER RuleId
        The Id of an individual Stig Rule

    .PARAMETER Value
        The specific organizational value to set for the associated Stig rule

    .EXAMPLE
        $organizationalSetting = [OrganizationalSetting]::new('V-1090', '4')

    .NOTES
        This class requires PowerShell v5 or above.
#>
Class OrganizationalSetting
{
    [string] $RuleId
    [string] $Value

    #region Constructors

    <#
        .SYNOPSIS
            DO NOT USE - For testing only

        .DESCRIPTION
            A parameterless constructor for OrganizationalSetting. To be used
            only for build/unit testing purposes as Pester currently requires it
            in order to test static methods on powershell classes.
    #>
    OrganizationalSetting ()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
        .SYNOPSIS
            A constructor for OrganizationalSetting. Returns a ready to use
            instance of OrganizationalSetting.

        .DESCRIPTION
            A constructor for OrganizationalSetting. Returns a ready to use instance
            of OrganizationalSetting.

        .PARAMETER RuleId
            The Id of an individual Stig Rule

        .PARAMETER Value
            The specific organizational value to set for the associated Stig rule
    #>
    OrganizationalSetting ([string] $RuleId, [string] $Value)
    {
        $this.RuleId = $RuleId
        $this.Value = $Value
    }

    #endregion
    #region Static Methods

    <#
        .SYNOPSIS
            Converts a provided Xml document into an OrganizationalSetting array

        .DESCRIPTION
            This method returns an OrganizationalSetting array based on the Xml
            document provided as the parameter. The Xml document must follow the
            same schema as the associated default org settings file for a given
            Stig.

        .PARAMETER OrganizationalSettingsXml
            An Xml document describing the implementing organization's settings
            for Stig rules with a valid range.

            [xml] $OrgSettingXml = @"
                <OrganizationalSettings version="2.9">
                    <OrganizationalSetting id="V-1114" value="xGuest" />
                    <OrganizationalSetting id="V-1115" value="xAdministrator" />
                </OrganizationalSettings>
            "@
    #>
    static [OrganizationalSetting[]] ConvertFrom ([xml] $OrganizationalSettings)
    {
        [System.Collections.ArrayList] $OrganizationalSettingList = @()

        foreach ($OrganizationalSetting in $OrganizationalSettings.OrganizationalSettings.OrganizationalSetting)
        {
            $OrganizationalSettingList.Add(
                [OrganizationalSetting]::New(
                    $OrganizationalSetting.id, $OrganizationalSetting.Value
                )
            )
        }

        return $OrganizationalSettingList
    }

    <#
        .SYNOPSIS
            Converts a provided Hashtable into an OrganizationalSetting array

        .DESCRIPTION
            This method returns an OrganizationalSetting array based on the
            Hashtable provided as the parameter. The Hashtable must follow the
            schema specified below.

        .PARAMETER OrganizationalSettingsHashtable
            A Hashtable describing the implementing organization's settings for
            Stig rules with a valid range

            [hashtable] $OrgSettingHashtable = @{
                "V-1114"="xGuest";
                "V-1115"="xAdministrator";
            }
    #>
    static [OrganizationalSetting[]] ConvertFrom ([hashtable] $OrganizationalSettings)
    {
        [System.Collections.ArrayList] $OrganizationalSettingList = @()

        foreach ($OrganizationalSetting in $OrganizationalSettings.GetEnumerator())
        {
            $OrganizationalSettingList.Add(
                [OrganizationalSetting]::New(
                    $OrganizationalSetting.Name, $OrganizationalSetting.Value
                )
            )
        }

        return $OrganizationalSettingList
    }

    #endregion
}

# Footer
$exclude = @($MyInvocation.MyCommand.Name, 'Template.*.txt')
foreach ($supportFile in Get-ChildItem -Path $PSScriptRoot -Exclude $exclude)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'

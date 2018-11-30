# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
# Header

<#
    .SYNOPSIS
        This class describes an OrganizationalSetting

    .DESCRIPTION
        The OrganizationalSetting class describes OrganizationalSetting, a value for a Stig Rule that is specific to the implementing organization.
        Stigs requiring organizational settings will be accompanied by a default settings file. These can either be used as-is or replaced with
        values specific to the implementing organization. This Xml file will subsequently be transformed into OrganizationalSetting objects to
        be passed into and used in the StigData class constructor.

    .PARAMETER StigRuleId
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
    [string] $StigRuleId
    [string] $Value

    #region Constructors

    <#
        .SYNOPSIS
            DO NOT USE - For testing only

        .DESCRIPTION
            A parameterless constructor for OrganizationalSetting. To be used only for
            build/unit testing purposes as Pester currently requires it in order to test
            static methods on powershell classes
    #>
    OrganizationalSetting ()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
        .SYNOPSIS
            A constructor for OrganizationalSetting. Returns a ready to use instance of OrganizationalSetting.

        .DESCRIPTION
            A constructor for OrganizationalSetting. Returns a ready to use instance
            of OrganizationalSetting.

        .PARAMETER StigRuleId
            The Id of an individual Stig Rule

        .PARAMETER Value
            The specific organizational value to set for the associated Stig rule
    #>
    OrganizationalSetting ([string] $StigRuleId, [string] $Value)
    {
        $this.StigRuleId = $StigRuleId
        $this.Value = $Value
    }

    #endregion
    #region Static Methods

    <#
        .SYNOPSIS
            The mapping of Stig rule types to the property needing to be modified
            within the Stig rule

        .DESCRIPTION
            This method returns a Hashtable containing a mapping between a specific Stig rule
            type and the property of that Stig rule type that needs to be modified by the
            organizational setting

        .NOTES
            This method calls the Get-PropertyMap function which simply returns a variable that is
            only available in the module scope. This eliminates the need to load the module just to
            get access to a variable.
    #>
    static [Hashtable] PropertyMap ()
    {
        return Get-PropertyMap
    }

    <#
        .SYNOPSIS
            Converts a provided Xml document into an OrganizationalSetting array

        .DESCRIPTION
            This method returns an OrganizationalSetting array based on the Xml document provided
            as the parameter. The Xml document must follow the same schema as the associated
            default org settings file for a given Stig

        .PARAMETER OrganizationalSettingsXml
            An Xml document describing the implementing organization's settings for Stig rules with
            a valid range

            [xml] $OrgSettingXml =
                @"
                <OrganizationalSettings version="2.9">
                <OrganizationalSetting id="V-1114" value="xGuest" />
                <OrganizationalSetting id="V-1115" value="xAdministrator" />
                <OrganizationalSetting id="V-3472.a" value="NT5DS" />
                <OrganizationalSetting id="V-4108" value="90" />
                <OrganizationalSetting id="V-4113" value="300000" />
                <OrganizationalSetting id="V-8322.b" value="NT5DS" />
                <OrganizationalSetting id="V-26482" value="Administrators" />
                <OrganizationalSetting id="V-26579" value="32768" />
                <OrganizationalSetting id="V-26580" value="196608" />
                <OrganizationalSetting id="V-26581" value="32768" />
                </OrganizationalSettings>
                "@
    #>
    static [OrganizationalSetting[]] ConvertFrom ([xml] $OrganizationalSettingsXml)
    {
        [System.Collections.ArrayList] $OrgSettings = @()

        foreach ($orgSetting in $OrganizationalSettingsXml.OrganizationalSettings.OrganizationalSetting)
        {
            $org = [OrganizationalSetting]::new($orgSetting.id, $orgSetting.Value)
            $OrgSettings.Add($org)
        }

        return $OrgSettings
    }

    <#
        .SYNOPSIS
            Converts a provided Hashtable into an OrganizationalSetting array

        .DESCRIPTION
            This method returns an OrganizationalSetting array based on the Hashtable provided
            as the parameter. The Hashtable must follow the schema specified below.

        .PARAMETER OrganizationalSettingsHashtable
            A Hashtable describing the implementing organization's settings for Stig rules with
            a valid range

            [hashtable] $OrgSettingHashtable =
                @{
                "V-1114"="xGuest";
                "V-1115"="xAdministrator";
                "V-3472.a"="NT5DS";
                "V-4108"="90";
                "V-4113"="300000";
                "V-8322.b"="NT5DS";
                "V-26482"="Administrators";
                "V-26579"="32768";
                "V-26580"="196608";
                "V-26581"="32768"
                }
    #>
    static [OrganizationalSetting[]] ConvertFrom ([hashtable] $OrganizationalSettingsHashtable)
    {
        [System.Collections.ArrayList] $OrgSettings = @()

        foreach ($orgSetting in $OrganizationalSettingsHashtable.Keys)
        {
            $org = [OrganizationalSetting]::new($orgSetting, $OrganizationalSettingsHashtable.$orgSetting)
            $OrgSettings.Add($org)
        }

        return $OrgSettings
    }

    #endregion
}

# Footer
$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
foreach ($supportFile in Get-ChildItem -Path $PSScriptRoot -Exclude $exclude)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'

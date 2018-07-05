# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        This class describes an OrganizationalSetting

    .DESCRIPTION
        The OrganizationalSetting class describes OrganizationalSetting, a value for a Stig Rule that is specific to the implementing organization.
        Stigs requiring organizational settings will be accompanied by a default settings file. These can either be used as-is or replaced with
        values specific to the implementing organization. This Xml file will subsequently be transformed into OrganizationalSetting objects to
        be passed into and used in the StigData class constructor.

    .EXAMPLE
        $organizationalSetting = [OrganizationalSetting]::new('V-1090', '4')

    .NOTES
        This class requires PowerShell v5 or above.
#>

Class OrganizationalSetting
{
    #region Properties
    <#
    .DESCRIPTION
        The Id of an individual Stig Rule
    #>
    [string] $StigRuleId

    <#
    .DESCRIPTION
        The specific organizational value to set for the associated Stig rule
    #>
    [string] $Value
    #endregion Properties

    #region Constructors
    <#
    .SYNOPSIS
        Parameterless constructor

    .DESCRIPTION
        A parameterless constructor for OrganizationalSetting. To be used only for
        build/unit testing purposes as Pester currently requires it in order to test
        static methods on powershell classes

    .RETURN
        OrganizationalSetting
    #>
    OrganizationalSetting()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
    .SYNOPSIS
        Constructor

    .DESCRIPTION
        A constructor for OrganizationalSetting. Returns a ready to use instance
        of OrganizationalSetting.

    .PARAMETER StigRuleId
        The Id of an individual Stig Rule

    .PARAMETER Value
        The specific organizational value to set for the associated Stig rule

    .RETURN
        OrganizationalSetting
    #>
    OrganizationalSetting([string] $StigRuleId, [string] $Value)
    {
        $this.StigRuleId = $StigRuleId
        $this.Value = $Value
    }
    #endregion Constructors

    #region Static Methods
    <#
    .SYNOPSIS
        The mapping of Stig rule types to the property needing to be modified
        within the Stig rule

    .DESCRIPTION
        This method returns a Hashtable containing a mapping between a specific Stig rule
        type and the property of that Stig rule type that needs to be modified by the
        organizational setting

    .RETURN
        Hashtable
    #>
    static [Hashtable] PropertyMap ()
    {
        try 
        {
            $path = (Resolve-Path -Path "$PSScriptRoot\..\Data\Stig.Data.OrganizationalSettingsPropertyMap.psd1").Path
        }
        catch
        {
            throw "Cannot resolve Stig.Data.OrganizationalSettingsPropertyMap.psd1"
        }
        return Import-PowerShellDataFile -Path $path
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

    .RETURN
        OrganizationalSetting[]
    #>
    static [OrganizationalSetting[]] ConvertFrom ([xml] $OrganizationalSettingsXml)
    {
        [System.Collections.ArrayList] $orgSettings = @()

        foreach ($orgSetting in $OrganizationalSettingsXml.OrganizationalSettings.OrganizationalSetting)
        {
            $org = [OrganizationalSetting]::new($orgSetting.id, $orgSetting.Value)
            $orgSettings.Add($org)
        }

        return $orgSettings
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

    .RETURN
        OrganizationalSetting[]
    #>
    static [OrganizationalSetting[]] ConvertFrom ([hashtable] $OrganizationalSettingsHashtable)
    {
        [System.Collections.ArrayList] $orgSettings = @()

        foreach ($orgSetting in $OrganizationalSettingsHashtable.Keys)
        {
            $org = [OrganizationalSetting]::new($orgSetting, $OrganizationalSettingsHashtable.$orgSetting)
            $orgSettings.Add($org)
        }

        return $orgSettings
    }
    #endregion Static Methods
}

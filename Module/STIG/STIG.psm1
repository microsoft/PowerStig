# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\AccountPolicyRule\AccountPolicyRule.psm1
using module .\..\AuditPolicyRule\AuditPolicyRule.psm1
using module .\..\DocumentRule\DocumentRule.psm1
using module .\..\DnsServerRootHintRule\DnsServerRootHintRule.psm1
using module .\..\DnsServerSettingRule\DnsServerSettingRule.psm1
using module .\..\FileContentRule\FileContentRule.psm1
using module .\..\GroupRule\GroupRule.psm1
using module .\..\IISLoggingRule\IISLoggingRule.psm1
using module .\..\ManualRule\ManualRule.psm1
using module .\..\MimeTypeRule\MimeTypeRule.psm1
using module .\..\OrganizationalSetting\OrganizationalSetting.psm1
using module .\..\PermissionRule\PermissionRule.psm1
using module .\..\ProcessMitigationRule\ProcessMitigationRule.psm1
using module .\..\RegistryRule\RegistryRule.psm1
using module .\..\SecurityOptionRule\SecurityOptionRule.psm1
using module .\..\ServiceRule\ServiceRule.psm1
using module .\..\Stig.StigException\Stig.StigException.psm1
using module .\..\Stig.SkippedRuleType\Stig.SkippedRuleType.psm1
using module .\..\Stig.SkippedRule\Stig.SkippedRule.psm1
using module .\..\Stig.TechnologyRole\Stig.TechnologyRole.psm1
using module .\..\Stig.TechnologyVersion\Stig.TechnologyVersion.psm1
using module .\..\SqlScriptQueryRule\SqlScriptQueryRule.psm1
using module .\..\UserRightsAssignmentRule\UserRightsAssignmentRule.psm1
using module .\..\WebAppPoolRule\WebAppPoolRule.psm1
using module .\..\WebConfigurationPropertyRule\WebConfigurationPropertyRule.psm1
using module .\..\WindowsFeatureRule\WindowsFeatureRule.psm1
using module .\..\WinEventLogRule\WinEventLogRule.psm1
using module .\..\WmiRule\WmiRule.psm1
# Header

<#
    .SYNOPSIS
        This class describes a STIG

    .DESCRIPTION
        The STIG class describes a STIG, the collection of rules for a given
        technology that need to be implemented in order to enforce the security
        posture those rules define. STIG takes in instances of many other classes
        that describe the given technology and the implementing organizations
        specific settings, exceptions, and rules to skip. Upon creation of a
        STIG instance, the resulting Xml is immediately available for those preconditions.

    .PARAMETER StigVersion
        The document/published version of the Stig to select

    .PARAMETER OrganizationalSettings
        An array of settings/values specific to an organization to apply to specific rules

    .PARAMETER Technology
        The type of the technology of the Stig to select

    .PARAMETER TechnologyRole
        The role of the technology of the Stig to select

    .PARAMETER TechnologyVersion
        The version of the technology of the Stig to select

    .PARAMETER StigExceptions
        An array of names of Stig exceptions to apply to specific rules

    .PARAMETER SkippedRuleTypes
        An array of names of rule types to skip all rules of

    .PARAMETER SkippedRules
        An array of Stig rules to skip and move into the SkipRule rule type

    .PARAMETER StigXml
        The loaded Xml document of the Stig loaded from StigPath

    .PARAMETER StigPath
        The file path to the Stig Xml file in the StigData directory

    .EXAMPLE
        $STIG = [STIG]::new([string] $StigVersion, [OrganizationalSetting[]] $OrganizationalSettings, [Technology] $Technology, [TechnologyRole] $TechnologyRole, [TechnologyVersion] $TechnologyVersion, [StigException[]] $StigExceptions, [SkippedRuleType[]] $SkippedRuleTypes, [SkippedRule[]] $SkippedRules)

    .NOTES
        This class requires PowerShell v5 or above.
#>

Class STIG
{
    [Version] $StigVersion
    [OrganizationalSetting[]] $OrganizationalSettings
    [Technology] $Technology
    [TechnologyRole] $TechnologyRole
    [TechnologyVersion] $TechnologyVersion
    [StigException[]] $StigExceptions
    [SkippedRuleType[]] $SkippedRuleTypes
    [SkippedRule[]] $SkippedRules
    [xml] $StigXml
    [string] $StigPath


    #region Constructor

    <#
        .SYNOPSIS
            DO NOT USE - For testing only

        .DESCRIPTION
            A parameterless constructor for STIG. To be used only for
            build/unit testing purposes as Pester currently requires it in order to test
            static methods on powershell classes
    #>
    STIG ()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
        .SYNOPSIS
            A constructor for STIG. Returns a ready to use instance of STIG.

        .DESCRIPTION
            A constructor for STIG. Returns a ready to use instance of STIG.

        .PARAMETER StigVersion
            The document/published version of the Stig to select

        .PARAMETER OrganizationalSettings
            An array of settings/values specific to an organization to apply to specific rules

        .PARAMETER Technology
            The type of the technology of the Stig to select

        .PARAMETER TechnologyRole
            The role of the technology of the Stig to select

        .PARAMETER TechnologyVersion
            The version of the technology of the Stig to select

        .PARAMETER StigExceptions
            An array of names of Stig exceptions to apply to specific rules

        .PARAMETER SkippedRuleTypes
            An array of names of rule types to skip all rules of

        .PARAMETER SkippedRules
            An array of Stig rules to skip and move into the SkipRule rule type
    #>
    STIG ([string] $StigVersion, [OrganizationalSetting[]] $OrganizationalSettings, [Technology] $Technology, [TechnologyRole] $TechnologyRole, [TechnologyVersion] $TechnologyVersion, [StigException[]] $StigExceptions, [SkippedRuleType[]] $SkippedRuleTypes, [SkippedRule[]] $SkippedRules)
    {
        if (($null -eq $Technology) -or !($TechnologyRole) -or !($TechnologyVersion))
        {
            throw("Technology, TechnologyVersion, and TechnologyRole must be provided.")
        }

        if (!($StigVersion))
        {
            $this.StigVersion = [STIG]::GetHighestStigVersion($Technology, $TechnologyRole, $TechnologyVersion)
        }
        else
        {
            $this.StigVersion = $StigVersion
        }

        $this.Technology = $Technology
        $this.TechnologyRole = $TechnologyRole
        $this.TechnologyVersion = $TechnologyVersion

        $this.OrganizationalSettings = $OrganizationalSettings
        $this.StigExceptions = $StigExceptions
        $this.SkippedRuleTypes = $SkippedRuleTypes
        $this.SkippedRules = $SkippedRules

        $this.SetStigPath()
        $this.ProcessStigData()
    }

    #endregion
    #region Methods

    <#
        .SYNOPSIS
            Determines and sets the StigPath

        .DESCRIPTION
            This method determines the value of Stig path given the passed in
            StigVersion, Technology, TechnologyVersion, and TechnologyRole. It
            also validates that a file exists at that determined path.
    #>
    [void] SetStigPath ()
    {
        $path = "$([STIG]::GetRootPath())\$($this.Technology.ToString())-$($this.TechnologyVersion.Name)-$($this.TechnologyRole.Name)-$($this.StigVersion).xml"

        if (Test-Path -Path $path)
        {
            $this.StigPath = $path
        }
        else
        {
            throw("No STIG exists matching the supplied Technology, TechnologyRole, and TechnologyVersion. Please check configuration and try again.")
        }
    }

    <#
        .SYNOPSIS
            Processes properties into Stig Xml

        .DESCRIPTION
            This method processes all the class properties and merges them into the default Stig
    #>
    [void] ProcessStigData ()
    {
        $this.StigXml = [xml] (Get-Content -Path $this.StigPath -Raw)

        $this.MergeOrganizationalSettings()
        $this.MergeStigExceptions()
        $this.ProcessSkippedRuleTypes()
        $this.MergeSkippedRules()
    }

    <#
        .SYNOPSIS
            Merges OrganizationalSetting property into StigXml

        .DESCRIPTION
            This method merges the OrganizationalSettings property into StigXml. If OrganizationalSettings
            are null it will load in the associated default OrganizationalSettings from the default
            file stored in PowerStig. A partial or complete OrganizationalSettings property will be
            merged with the defaults prior to being merged into StigXml.
    #>
    [void] MergeOrganizationalSettings ()
    {
        # Check if default Org Settings exists for STIG
        $orgSettingPath = $this.StigPath -replace "\.xml", ".org.default.xml"
        $orgSettingsExists = Test-Path -Path $orgSettingPath

        # Check if STIG has Org Settings
        if ($orgSettingsExists)
        {
            [xml] $orgSettingsXml = Get-Content -Path $orgSettingPath -Raw
            $mergedOrgSettings = [OrganizationalSetting]::ConvertFrom($orgSettingsXml)

            # Merge default Org Settings with passed in Org Settings
            if ($this.OrganizationalSettings)
            {
                foreach ($orgSetting in $mergedOrgSettings)
                {
                    $matchingOrgSetting = $this.OrganizationalSettings.Where({$PSItem.RuleId -eq $orgSetting.RuleId})
                    if ($matchingOrgSetting)
                    {
                        $orgSetting.Value = $matchingOrgSetting.Value
                    }
                }
            }

            $this.OrganizationalSettings = $mergedOrgSettings

            # Merge Org Settings into StigXml

            foreach ( $ruleType in $this.StigXml.DISASTIG.ChildNodes.Name )
            {
                # Get the list of STIG settings for the current type

                foreach ( $rule in $this.StigXml.DISASTIG.$ruleType.Rule )
                {
                    if ( $rule.OrganizationValueRequired -eq $true )
                    {
                        $orgSetting = $this.OrganizationalSettings.where({$PSItem.RuleId -eq $rule.id})

                        if ( -not $orgSetting )
                        {
                            Write-Warning "An organizational setting was not found for $( $rule.id )."
                        }

                        if ( -not ( & ( [Scriptblock]::Create( "$($rule.OrganizationValueTestString)" -f $orgSetting.Value.ToString() ) ) ) )
                        {
                            Write-Warning "The local setting ($($orgSetting.Value.ToString())) for $($rule.id) is not within the specified range ($($rule.OrganizationValueTestString))
                            Please check and update the Organizational Setting array passed in."
                        }

                        $overrideValue = [scriptblock]::Create("[$ruleType]::OverrideValue").Invoke()
                        $rule.$overrideValue = $orgSetting.Value
                    }
                }
            }
        }
    }

    <#
        .SYNOPSIS
            Merges StigExceptions property into StigXml

        .DESCRIPTION
            This method merges the StigExceptions property into StigXml. If StigExceptions
            are null it will skip any additional execution.
    #>
    [void] MergeStigExceptions ()
    {
        if ($this.StigExceptions)
        {
            foreach ($Exception in $this.StigExceptions)
            {
                # Lookup the STIG Id in the data
                $ruleToOverride = ( $this.StigXml.DISASTIG |
                                Select-Xml -XPath "//Rule[@id='$( $Exception.StigRuleId )']" -ErrorAction Stop ).Node

                # If an Id is not found we can continue, but notify the user.
                if ($null -eq $ruleToOverride)
                {
                    Write-warning "$($Exception.StigRuleId) was not found"
                    continue
                }

                # Append [Exception] to the STIG title
                $ruleToOverride.title = "[Exception]" + $ruleToOverride.title
                # Select and Update the property to override
                $propertiesToOverride = $Exception.Properties
                foreach ($property in $propertiesToOverride)
                {
                    $propertyToOverride = $property.Name
                    $ruleToOverride.$propertyToOverride = $property.Value.ToString()
                }
            }
        }
    }

    <#
        .SYNOPSIS
            Processes SkippedRuleTypes property into SkippedRules

        .DESCRIPTION
            This method processes the SkippedRuleTypes and adds the individual rules
            for each type into the SkippedRules property.
    #>
    [void] ProcessSkippedRuleTypes ()
    {
        if ($this.SkippedRuleTypes)
        {
            foreach ($ruleType in $this.SkippedRuleTypes)
            {
                # Collects the Id's of the rules of the RuleType
                $ruleToOverride = $this.StigXml.DISASTIG.$($RuleType.StigRuleType).rule.id

                # If an Id is not found we can continue, but notify the user.
                if ($null -eq $ruleToOverride)
                {
                    Write-Warning "SkippedRuleType of $($ruleType.StigRuleType) was not found"
                    continue
                }
                else
                {
                    foreach ($rule in $ruleToOverride)
                    {
                        $newSkipRule = [SkippedRule]::new($rule)
                        $this.SkippedRules += $newSkipRule
                    }
                }
            }
        }
    }

    <#
        .SYNOPSIS
            Merges SkippedRules property into StigXml

        .DESCRIPTION
            This method merges the SkippedRules property into StigXml. All Stig rules within
            the SkippedRules array will be moved from their associated Stig rule type into
            a new 'SkipRule' Stig rule type within StigXml.
    #>
    [void] MergeSkippedRules ()
    {
        if ($this.SkippedRules)
        {
            # This creates a Skip rule XML element and appends it to $stigContent
            [System.XML.XMLElement] $skipNode = $this.StigXml.CreateElement("SkipRule")
            [void] $this.StigXml.DISASTIG.AppendChild($skipNode)

            foreach ($rule in $this.SkippedRules)
            {
                # Lookup the STIG Id in the data
                $ruleToOverride = ( $this.StigXml.DISASTIG | Select-Xml -XPath "//Rule[@id='$( $rule.StigRuleId )']" -ErrorAction Stop ).Node

                # If an Id is not found we can continue, but notify the user.
                if ($null -eq $ruleToOverride)
                {
                    Write-Warning "STIG rule with Id '$($rule.StigRuleId)' was not found"
                    continue
                }
                else
                {
                    $ruleToOverride.title = "[Skip]" + $ruleToOverride.title
                    [void] $this.StigXml.SelectSingleNode("//SkipRule").AppendChild($ruleToOverride)
                }
            }
        }
    }

    #endregion
    #region Static Methods

    <#
        .SYNOPSIS
            Returns the root path to the StigData directory

        .DESCRIPTION
            Returns the root path to the StigData directory which contains all the Stig XML files
            currently available for PowerStig
    #>
    static [string] GetRootPath ()
    {
        # The path needs to take into account the version folder that changes with each release
        $rootPath = (Resolve-Path -Path $PSScriptRoot\..\..).Path

        return (Join-Path -Path $rootPath -ChildPath 'StigData\Processed')
    }

    <#
        .SYNOPSIS
            Returns the highest available Stig version

        .DESCRIPTION
            Returns the highest available Stig version for a given Technology, TechnologyVersion, and TechnologyRole

        .PARAMETER Technology
            The type of the technology of the Stig to select

        .PARAMETER TechnologyRole
            The role of the technology of the Stig to select

        .PARAMETER TechnologyVersion
            The version of the technology of the Stig to select
    #>
    static [Version] GetHighestStigVersion ([Technology] $Technology, [TechnologyRole] $TechnologyRole, [TechnologyVersion] $TechnologyVersion)
    {
        $highestStigVersionInTarget = (Get-ChildItem -Path $([STIG]::GetRootPath()) -Exclude "*org*").BaseName |
                                        Where-Object {$PSItem -like "*$($Technology.Name)-$($TechnologyVersion.Name)-$($TechnologyRole.Name)*"} |
                                            Foreach-Object {($PsItem -split "-")[3]} |
                                                Select-Object -unique |
                                                    Sort-Object |
                                                        Select-Object -First 1

        return [Version]::new($highestStigVersionInTarget)
    }

    <#
        .SYNOPSIS
            Returns all available Stigs

        .DESCRIPTION
            Returns all of the currently available for PowerStig along with their
            associated Technology, TechnologyVersion, TechnologyRole, and StigVersion
    #>
    static [PSObject[]] ListAvailable ()
    {
        $childItemParameters = @{
            Path = "$([STIG]::GetRootPath())"
            Exclude = "*.org.*"
            Include = "*.xml"
            File = $true
            Recurse = $true
        }

        $stigList = Get-ChildItem @childItemParameters

        [System.Collections.ArrayList] $returnList = @()

        foreach ($stig in $stigList)
        {
            $stigProperties = $stig.BaseName -Split "-"

            $stigPropertyList = New-Object PSObject
            $stigPropertyList | Add-Member -MemberType NoteProperty -Name 'Technology' -Value $stigProperties[-4]
            $stigPropertyList | Add-Member -MemberType NoteProperty -Name 'TechnologyVersion' -Value $stigProperties[-3]
            $stigPropertyList | Add-Member -MemberType NoteProperty -Name 'TechnologyRole' -Value $stigProperties[-2]
            $stigPropertyList | Add-Member -MemberType NoteProperty -Name 'StigVersion' -Value $stigProperties[-1]

            [void] $ReturnList.Add($stigPropertyList)
        }

        return $returnList
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

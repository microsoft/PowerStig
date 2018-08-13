# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        The base class for all STIG rule types
    .DESCRIPTION
        The base class for all STIG rule types to support a common initializer and
        set of methods that apply to all rule types. PowerShell does not support
        abstract classes, but this class is not intended to be used directly.
    .PARAMETER Id
        The STIG ID
    .PARAMETER Title
        Title string from STIG
    .PARAMETER Severity
        Severity data from STIG
    .PARAMETER ConversionStatus
        Module processing status of the raw string
    .PARAMETER RawString
        The raw string from the check-content element of the STIG item
    .PARAMETER SplitCheckContent
        The raw check string split into multiple lines for pattern matching
    .PARAMETER IsNullOrEmpty
        A flag to determine if a value is supposed to be empty or not.
        Some items should be empty, but there needs to be a way to validate that empty is on purpose.
    .PARAMETER OrganizationValueRequired
        A flag to determine if a local organizational setting is required.
    .PARAMETER OrganizationValueTestString
        A string that can be invoked to test the chosen organizational value.
    .PARAMETER DscResource
        Defines the DSC resource used to configure the rule
#>
Class STIG : ICloneable
{
    [String] $Id
    [String] $Title
    [severity] $Severity
    [status] $ConversionStatus
    [String] $RawString
    hidden [string[]] $SplitCheckContent
    [Boolean] $IsNullOrEmpty
    [Boolean] $OrganizationValueRequired
    [String] $OrganizationValueTestString
    [String] $DscResource

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            This is the base class constructor
    #>
    STIG ()
    {
    }

    #region Methods

    <#
        .SYNOPSIS
            The class initializer
        .DESCRIPTION
            Extracts all of the settings from the xccdf rule that are needed to
            instantiate the base class
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    hidden [void] InvokeClass ( [xml.xmlelement] $StigRule )
    {
        $this.Id = $StigRule.id
        $this.Severity = $StigRule.rule.severity
        $this.Title = $StigRule.title

        # Since the string comes from XML, we have to assume that it is encoded for html.
        # This will decode it back into the normal string characters we are looking for.
        if ( Test-HtmlEncoding -CheckString  $StigRule.rule.Check.('check-content') )
        {
            $this.RawString = ( ConvertFrom-HtmlEncoding -CheckString $StigRule.rule.Check.('check-content') )
        }
        else
        {
            $this.RawString = $StigRule.rule.Check.('check-content')
        }

        <#
            This hidden property is used by all of the methods and passed to subfunctions instead of
            splitting the sting in every function. The Select-String removes any blank lines, so
            that the Mandatory parameter validation does not fail and to prevent the need for a
            work around by allowing empty strings in mandatory parameters.
        #>
        $this.SplitCheckContent = [STIG]::SplitCheckContent( $this.rawString )

        # Default Flags
        $this.IsNullOrEmpty = $false
        $this.OrganizationValueRequired = $false
    }

    <#
        .SYNOPSIS
            Creates a shallow copy of the current
        .DESCRIPTION
            Creates a shallow copy of the current
    #>
    [Object] Clone ()
    {
        return $this.MemberwiseClone()
    }

    <#
        .SYNOPSIS
            Tests if the rule already exists
        .DESCRIPTION
            Compares the rule with existing converted rules
        .PARAMETER ReferenceObject
            The existing converted rules
    #>
    [Boolean] IsDuplicateRule ( [object] $ReferenceObject )
    {
        return Test-DuplicateRule -ReferenceObject $ReferenceObject -DifferenceObject $this
    }

    <#
        .SYNOPSIS
            Tags a rule as being duplicate
        .DESCRIPTION
            Is a rule is a duplicate, tag the title for easy filtering and reporting
    #>
    [void] SetDuplicateTitle ()
    {
        $this.title = $this.title + ' Duplicate'
    }

    <#
        .SYNOPSIS
            Sets the conversion status
        .DESCRIPTION
            Sets the conversion status
        .PARAMETER Value
            The value to be tested
    #>
    [Boolean] SetStatus ( [String] $Value )
    {
        if ( [String]::IsNullOrEmpty( $Value ) )
        {
            $this.conversionstatus = [status]::fail
            return $true
        }
        else
        {
            return $false
        }
    }

    <#
        .SYNOPSIS
            Sets the conversion status with an allowed blank value
        .DESCRIPTION
            Sets the conversion status with an allowed blank value
        .PARAMETER Value
            The value to be tested
        .PARAMETER AllowNullOrEmpty
            A flag to allow blank values
    #>
    [Boolean] SetStatus ( [String] $Value, [Boolean] $AllowNullOrEmpty )
    {
        if ( [String]::IsNullOrEmpty( $Value ) -and -not $AllowNullOrEmpty )
        {
            $this.conversionstatus = [status]::fail
            return $true
        }
        else
        {
            return $false
        }
    }

    <#
        .SYNOPSIS
            Sets the IsNullOrEmpty value to true
        .DESCRIPTION
            Sets the IsNullOrEmpty value to true
    #>
    [void] SetIsNullOrEmpty ()
    {
        $this.IsNullOrEmpty = $true
    }

    <#
        .SYNOPSIS
            Sets the OrganizationValueRequired value to true
        .DESCRIPTION
            Sets the OrganizationValueRequired value to true
    #>
    [void] SetOrganizationValueRequired ()
    {
        $this.OrganizationValueRequired = $true
    }

    <#
        .SYNOPSIS
            Gets the organization value test string
        .DESCRIPTION
            Gets the organization value test string
        .PARAMETER TestString
            The string to extract the
    #>
    [String] GetOrganizationValueTestString ( [String] $TestString )
    {
        return Get-OrganizationValueTestString -String $testString
    }

    <#
        .SYNOPSIS
            Converts the object into a hashtable
        .DESCRIPTION
            Converts the object into a hashtable
    #>
    [hashtable] ConvertToHashTable ()
    {
        return ConvertTo-HashTable -InputObject $this
    }

    <#
        .SYNOPSIS
            Sets the Dsc resource that can use the object
        .DESCRIPTION
            Sets the Dsc resource that can use the object
    #>
    [void] SetStigRuleResource ()
    {
        $thisDscResource = Get-StigRuleResource -RuleType $this.GetType().ToString()

        if ( -not $this.SetStatus( $thisDscResource ) )
        {
            $this.set_dscresource( $thisDscResource )
        }
    }

    <#
        .SYNOPSIS
            Splits the check-content element in the xccdf into an array
        .DESCRIPTION
            Splits the check-content element in the xccdf into an array
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [string[]] SplitCheckContent ( [String] $CheckContent )
    {
        return (
            $CheckContent -split '\n' |
                Select-String -Pattern "\w" |
                ForEach-Object { $PSitem.ToString().Trim() }
        )
    }

    <#
        .SYNOPSIS
            Get the fixtext from the xccdf
        .DESCRIPTION
            Get the fixtext from the xccdf
        .PARAMETER StigRule
            The StigRule to extract the fix text from
    #>
    static [string[]] GetFixText ( [xml.xmlelement] $StigRule )
    {
        $fullFix = $StigRule.Rule.fixtext.'#text'

        $return = $fullFix -split '\n' |
            Select-String -Pattern "\w" |
            ForEach-Object { $PSitem.ToString().Trim() }

        return $return
    }

    <#
        .SYNOPSIS
            Returns the rule type that is should be converted to
        .DESCRIPTION
            Looks at the check-content data and returns the rule type that is should be converted to.
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [RuleType[]] GetRuleTypeMatchList ( [String] $CheckContent )
    {
        return Get-RuleTypeMatchList -CheckContent $CheckContent
    }

    <#
        .SYNOPSIS
            Looks for the rule to see if it already exists
        .DESCRIPTION
            Looks for the rule to see if it already exists
        .PARAMETER RuleCollection
            The global rule collection
    #>
    [Boolean] IsExistingRule ( [object] $RuleCollection )
    {
        return Test-ExistingRule -RuleCollection $RuleCollection $this
    }

    #endregion
    #region Hard coded Methods

    <#
        .SYNOPSIS
            Checks to see if the STIG is a hard coded return value
        .DESCRIPTION
            Accepts defeat in that the STIG string data for a select few checks
            are too unwieldy to parse properly. The OVAL data does not provide
            much more help in a few of the cases, so the STIG Id's for these
            checks are hardcoded here to force a fixed value to be returned.
    #>
    [Boolean] IsHardCoded ()
    {
        return Test-ValueDataIsHardCoded -StigId $this.id
    }

    <#
        .SYNOPSIS
            Returns a hard coded conversion value
        .DESCRIPTION
            Returns a hard coded conversion value
    #>
    [String] GetHardCodedString ()
    {
        return Get-HardCodedString -StigId $this.id
    }

    <#
        .SYNOPSIS
            Checks to see if the STIG org value is a hard coded return value
        .DESCRIPTION
            Accepts defeat in that the STIG string data for a select few checks
            are too unwieldy to parse properly. The OVAL data does not provide
            much more help in a few of the cases, so the STIG Id's for these
            checks are hardcoded here to force a fixed value to be returned.
    #>
    [Boolean] IsHardCodedOrganizationValueTestString ()
    {
        return Test-IsHardCodedOrganizationValueTestString -StigId $this.id
    }

    <#
        .SYNOPSIS
            Returns a hard coded org value
        .DESCRIPTION
            Returns a hard coded org value
    #>
    [String] GetHardCodedOrganizationValueTestString ()
    {
        return Get-HardCodedOrganizationValueTestString -StigId $this.id
    }

    #endregion
}

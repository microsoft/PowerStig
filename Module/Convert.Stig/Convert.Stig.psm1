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

    .DESCRIPTION

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

    .EXAMPLE
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

        .DESCRIPTION

        .EXAMPLE
    #>
    STIG ()
    {
    }

    #region Methods

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

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
            splitting the sting in every function. THe Select-String removes any blank lines, so
            that the Mandatory parameter validataion does not fail and to prevent the need for a
            work around by allowing empty strings in mandatory parameters.
        #>
        $this.SplitCheckContent = [STIG]::SplitCheckContent( $this.rawString )

        # Default Flags
        $this.IsNullOrEmpty = $false
        $this.OrganizationValueRequired = $false
    }

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
    #>
    [Object] Clone ()
    {
        return $this.MemberwiseClone()
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ReferenceObject

        .EXAMPLE
    #>
    [Boolean] IsDuplicateRule ( [object] $ReferenceObject )
    {
        return Test-DuplicateRule -ReferenceObject $ReferenceObject -DifferenceObject $this
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetDuplicateTitle ()
    {
        $this.title = $this.title + ' Duplicate'
    }

    <#
        .SYNOPSIS
            Fail a rule conversion if a property is null or empty
        .DESCRIPTION

        .PARAMETER Value

        .EXAMPLE
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
            Fail a rule conversion if a property is null or empty and not specifically allowed to be
        .DESCRIPTION

        .PARAMETER Value

        .PARAMETER AllowNullOrEmpty

        .EXAMPLE
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

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetIsNullOrEmpty ()
    {
        $this.IsNullOrEmpty = $true
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetOrganizationValueRequired ()
    {
        $this.OrganizationValueRequired = $true
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER TestString

        .EXAMPLE
    #>
    [String] GetOrganizationValueTestString ( [String] $TestString )
    {
        return Get-OrganizationValueTestString -String $testString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [hashtable] ConvertToHashTable ()
    {
        return ConvertTo-HashTable -InputObject $this
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
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

        .DESCRIPTION

        .PARAMETER CheckContent

        .EXAMPLE
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

        .DESCRIPTION

        .PARAMETER StigRule

        .EXAMPLE
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

        .DESCRIPTION

        .PARAMETER CheckContent

        .EXAMPLE
    #>
    static [RuleType[]] GetRuleTypeMatchList ( [String] $CheckContent )
    {
        return Get-RuleTypeMatchList -CheckContent $CheckContent
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER RuleCollection

        .EXAMPLE
    #>
    [Boolean] IsExistingRule ( [object] $RuleCollection )
    {
        return Test-ExistingRule -RuleCollection $RuleCollection $this
    }

    #endregion
    #region Hard coded Methods

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [Boolean] IsHardCoded ()
    {
        return Test-ValueDataIsHardCoded -StigId $this.id
    }

    <#
        .SYNOPSIS

        .DESCRIPTIONt

        .EXAMPLE
    #>
    [String] GetHardCodedString ()
    {
        return Get-HardCodedString -StigId $this.id
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [Boolean] IsHardCodedOrganizationValueTestString ()
    {
        return Test-IsHardCodedOrganizationValueTestString -StigId $this.id
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [String] GetHardCodedOrganizationValueTestString ()
    {
        return Get-HardCodedOrganizationValueTestString -StigId $this.id
    }

    #endregion
}

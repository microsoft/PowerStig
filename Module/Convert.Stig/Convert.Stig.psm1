#region Header
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
#endregion
#region Class Definition
Class STIG : ICloneable
{
    # The STIG ID
    [String] $id

    # Title string from STIG
    [String] $title

    # Severity data from STIG
    [severity] $severity

    # Module processing status of the raw string
    [status] $conversionstatus

    # The raw string from the check-content element of the STIG item
    [String] $rawString

    # The raw check string split into multiple lines for pattern matching
    hidden [string[]] $SplitCheckContent

    # A flag to determine if a value is supposed to be empty or not.
    # Some items should be empty, but there needs to be a way to validate that empty is on purpose.
    [Boolean] $IsNullOrEmpty

    # A flag to determine if a local organizational setting is required.
    [Boolean] $OrganizationValueRequired

    # A string that can be invoked to test the chosen organizational value.
    [String] $OrganizationValueTestString

    # Defines the DSC resource used to configure the rule
    [String] $dscresource

    # Constructors
    STIG ()
    {
    }

    # Methods
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

    [Object] Clone ()
    {
        return $this.MemberwiseClone()
    }

    [Boolean] IsDuplicateRule ( [object] $ReferenceObject )
    {
        return Test-DuplicateRule -ReferenceObject $ReferenceObject -DifferenceObject $this
    }

    [void] SetDuplicateTitle ()
    {
        $this.title = $this.title + ' Duplicate'
    }

    # Fail a rule conversion if a property is null or empty
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

    # Fail a rule conversion if a property is null or empty and not specifically allowed to be
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

    [void] SetIsNullOrEmpty ()
    {
        $this.IsNullOrEmpty = $true
    }

    [void] SetOrganizationValueRequired ()
    {
        $this.OrganizationValueRequired = $true
    }

    [String] GetOrganizationValueTestString ( [String] $testString )
    {
        return Get-OrganizationValueTestString -String $testString
    }

    [hashtable] ConvertToHashTable ()
    {
        return ConvertTo-HashTable -InputObject $this
    }

    [void] SetStigRuleResource ()
    {
        $thisDscResource = Get-StigRuleResource -RuleType $this.GetType()

        if ( -not $this.SetStatus( $thisDscResource ) )
        {
            $this.set_dscresource( $thisDscResource )
        }
    }

    static [string[]] SplitCheckContent ( [String] $CheckContent )
    {
        return (
            $CheckContent -split '\n' |
                Select-String -Pattern "\w" |
                    ForEach-Object { $PSitem.ToString().Trim() }
        )
    }

    static [string[]] GetFixText ( [xml.xmlelement] $StigRule )
    {
        $fullFix = $StigRule.Rule.fixtext.'#text'

        $return = $fullFix -split '\n' |
                  Select-String -Pattern "\w" |
                  ForEach-Object { $PSitem.ToString().Trim() }

        return $return
    }

    static [RuleType[]] GetRuleTypeMatchList ( [String] $CheckContent )
    {
        return Get-RuleTypeMatchList -CheckContent $CheckContent
    }

    [Boolean] IsExistingRule ( [object] $RuleCollection )
    {
        return Test-ExistingRule -RuleCollection $RuleCollection $this
    }
    #region Hard coded Methods
    [Boolean] IsHardCoded ()
    {
        return Test-ValueDataIsHardCoded -StigId $this.id
    }

    [String] GetHardCodedString ()
    {
        return Get-HardCodedString -StigId $this.id
    }

    [Boolean] IsHardCodedOrganizationValueTestString ()
    {
        return Test-IsHardCodedOrganizationValueTestString -StigId $this.id
    }

    [String] GetHardCodedOrganizationValueTestString ()
    {
        return Get-HardCodedOrganizationValueTestString -StigId $this.id
    }
    #endregion
}
#endregion

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

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
        Convert the contents of an xccdf check-content element into an Account Policy object
    .DESCRIPTION
        The AccountPolicyRule class is used to extract the Account Policy Settings
        from the check-content of the xccdf. Once a STIG rule is identifed as an
        Account Policy rule, it is passed to the AccountPolicyRule class for parsing
        and validation.
    .PARAMETER PolicyName
        The name of the account policy
    .PARAMETER PolicyValue
        The value the account policy should be set to.
#>
Class AccountPolicyRule : Rule
{
    [string] $PolicyName
    [string] $PolicyValue
    [String] $DscResource = 'AccountPolicy'
    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a AccountPolicyRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    AccountPolicyRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS
            Gets the account policy name from the xccdf content and sets the Policy Name.
        .DESCRIPTION
            Gets the account policy name from the xccdf content and sets the Policy Name.
            If the account policy that is returned is not a valid account policy Name, the
            parser status is set to fail.
    #>
    [void] SetPolicyName ()
    {
        $thisPolicyName = Get-AccountPolicyName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyName ) )
        {
            $this.set_PolicyName( $thisPolicyName )
        }
    }

    <#
        .SYNOPSIS
            Looks for a range of valid values
        .DESCRIPTION
            When a range of valid values is discovered, the range needs to be extracted out
            so. This method tests for ranges in the check-content.
    #>
    [bool] TestPolicyValueForRange ()
    {
        if (Test-SecurityPolicyContainsRange -CheckContent $this.SplitCheckContent)
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    <#
        .SYNOPSIS
            Gets the account policy value from the xccdf content and sets the Policy value.
        .DESCRIPTION
            Gets the account policy value from the xccdf content and sets the Policy value.
            If the value is determined to be invalid, it sets the parser status to failed.
    #>
    [void] SetPolicyValue ()
    {
        $thisPolicyValue = Get-AccountPolicyValue -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyValue ) )
        {
            $this.set_PolicyValue( $thisPolicyValue )
        }
    }

    <#
        .SYNOPSIS
            Sets the organizational value with the correct range.
        .DESCRIPTION
            A range of valid values is supported with PowerShell expressions. If
            a value is allowed to be between 1 and 3, then the PowerShell
            equivalent needs to be applied to the organizational settings list.
    #>
    [void] SetPolicyValueRange ()
    {
        $this.set_OrganizationValueRequired($true)

        $thisPolicyValueTestString = Get-SecurityPolicyOrganizationValueTestString -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyValueTestString ) )
        {
            $this.set_OrganizationValueTestString( $thisPolicyValueTestString )
        }
    }
    #endregion
}

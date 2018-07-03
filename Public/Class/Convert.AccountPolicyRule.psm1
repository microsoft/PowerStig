#region Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\Convert.Stig.psm1
using module .\..\Data\Convert.Main.psm1
# Additional required modules

#endregion
using module ..\..\private\common\rangeConversion.psm1
#region Data Section
$PolicyNameFixes = @{
    'Minimum password length,'                   = 'Minimum password length'
    'Store password using reversible encryption' = 'Store passwords using reversible encryption'
}
#endregion
#region Class Definition
Class AccountPolicyRule : STIG
{
    # Properties
    [string] $PolicyName
    [string] $PolicyValue

    # Constructor
    AccountPolicyRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetPolicyName ()
    {
        $thisPolicyName = Get-AccountPolicyName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyName ) )
        {
            $this.set_PolicyName( $thisPolicyName )
        }
    }

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

    [void] SetPolicyValue ()
    {
        $thisPolicyValue = Get-AccountPolicyValue -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyValue ) )
        {
            $this.set_PolicyValue( $thisPolicyValue )
        }
    }

    [void] SetPolicyValueRange ()
    {
        $this.set_OrganizationValueRequired($true)

        $thisPolicyValueTestString = Get-SecurityPolicyOrganizationValueTestString -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyValueTestString ) )
        {
            $this.set_OrganizationValueTestString( $thisPolicyValueTestString )
        }
    }
}
#endregion
#region Method Functions
<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Account Policy name
#>
function Get-AccountPolicyName
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $string = Get-SecurityPolicyString -CheckContent $CheckContent

    try
    {
        # Pull the Account Policy string from between the quotes in the string
        $accountPolicyName = (Get-TestStringTokenList -String ($string -join ',') -StringTokens)[0]
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Account Policy : $accountPolicyName "
        if ($PolicyNameFixes.$accountPolicyName)
        {
            $accountPolicyName = $PolicyNameFixes.$accountPolicyName
        }
        return $accountPolicyName
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Account Policy : Not Found"
        return $null
    }
}

<#
    .SYNOPSIS
        Short description
#>
function Get-AccountPolicyValue
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $string = Get-SecurityPolicyString -CheckContent $CheckContent

    try
    {
        $accountPolicyValue = (Get-TestStringTokenList -String ($string -join ',') -StringTokens)[1]
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Account Policy : $accountPolicyValue "
        return $accountPolicyValue
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Account Policy : Not Found"
        return $null
    }
}
#endregion

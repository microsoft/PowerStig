# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\common\enum.psm1
using module .\StigClass.psm1
using module ..\..\private\common\rangeConversion.psm1
. $PSScriptRoot\..\common\data.ps1
#endregion
#region Class Definition
Class SecurityOptionRule : STIG
{
    # Properties
    [ValidateNotNullOrEmpty()] [string] $OptionName
    [ValidateNotNullOrEmpty()] [string] $OptionValue

    # Constructor
    SecurityOptionRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetOptionName ( )
    {
        $thisName = Get-SecurityOptionName -CheckContent $this.SplitCheckContent
        if ( -not $this.SetStatus( $thisName ) )
        {
            $this.set_OptionName( $thisName )
        }
    }

    [bool] TestOptionValueForRange ()
    {
        if ( Test-SecurityPolicyContainsRange -CheckContent $this.SplitCheckContent )
        {
            return $true
        }

        return $false
    }

    [void] SetOptionValue ( )
    {
        $thisValue = Get-SecurityOptionValue -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisValue ) )
        {
            $this.set_OptionValue( $thisValue )
        }
    }

    [void] SetOptionValueRange ()
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
    Parses Check-Content element to retrieve the Security Options Policy name
#>
function Get-SecurityOptionName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    # use a reagular expression to pull the user right string from between the quotes
    $Option = ( $CheckContent |
            Select-String -Pattern $Script:RegularExpression.textBetweenQuotes -AllMatches )

    If ( $Option )
    {
        $Option = $Option.Matches.Groups[3].Value
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : $Option "
        return $option
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : Not Found"
        return
    }
}

<#
 .SYNOPSIS
    Parses Check-Content element to retrieve the Security Policy value
#>
function Get-SecurityOptionValue
{
    [CmdletBinding()]
    [OutputType( [string] )]
    Param
    (
        [parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    # use a reagular expression to pull the user right string from between the quotes
    $option = ( $CheckContent |
            Select-String -Pattern $Script:RegularExpression.textBetweenQuotes -AllMatches )

    if ( $option )
    {
        $Option = $Option.Matches.Groups[5].Value
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : $option "
        return $option
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : Not Found"
        return
    }
}
#endregion

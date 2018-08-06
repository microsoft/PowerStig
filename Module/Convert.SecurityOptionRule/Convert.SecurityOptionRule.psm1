# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

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

    .PARAMETER OptionName

    .PARAMETER OptionValue

    .EXAMPLE
#>
Class SecurityOptionRule : STIG
{
    [ValidateNotNullOrEmpty()] [string] $OptionName
    [ValidateNotNullOrEmpty()] [string] $OptionValue

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    SecurityOptionRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetOptionName ()
    {
        $thisName = Get-SecurityOptionName -CheckContent $this.SplitCheckContent
        if ( -not $this.SetStatus( $thisName ) )
        {
            $this.set_OptionName( $thisName )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [bool] TestOptionValueForRange ()
    {
        if ( Test-SecurityPolicyContainsRange -CheckContent $this.SplitCheckContent )
        {
            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetOptionValue ()
    {
        $thisValue = Get-SecurityOptionValue -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisValue ) )
        {
            $this.set_OptionValue( $thisValue )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetOptionValueRange ()
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

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

    .PARAMETER PolicyName

    .PARAMETER PolicyValue

    .EXAMPLE
#>
Class AccountPolicyRule : STIG
{
    [string] $PolicyName
    [string] $PolicyValue

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

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

        .DESCRIPTION

        .EXAMPLE
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

        .DESCRIPTION

        .EXAMPLE
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

        .DESCRIPTION

        .EXAMPLE
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

        .DESCRIPTION

        .EXAMPLE
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

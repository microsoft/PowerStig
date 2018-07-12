#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
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
#region Footer
Foreach ($supportFile in (Get-ChildItem -Path $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name))
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'
#endregion

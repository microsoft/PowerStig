#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
Class UserRightRule : STIG
{
    [ValidateNotNullOrEmpty()] [string] $DisplayName
    [ValidateNotNullOrEmpty()] [string] $Constant
    [ValidateNotNullOrEmpty()] [string] $Identity
    [bool] $Force = $false

    # Constructor
    UserRightRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetDisplayName ()
    {
        $thisDisplayName = Get-UserRightDisplayName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDisplayName ) )
        {
            $this.set_DisplayName( $thisDisplayName )
        }
    }

    [void] SetConstant ()
    {
        $thisConstant = Get-UserRightConstant -UserRightDisplayName $this.DisplayName

        if ( -not $this.SetStatus( $thisConstant ) )
        {
            $this.set_Constant( $thisConstant )
        }
    }

    [void] SetIdentity ()
    {
        $thisIdentity = Get-UserRightIdentity -CheckContent $this.SplitCheckContent
        $return = $true
        if ( [String]::IsNullOrEmpty( $thisIdentity ) )
        {
            $return = $false
        }
        elseif ( $thisIdentity -ne 'NULL' )
        {
            if ($thisIdentity -join "," -match "{Hyper-V}")
            {
                $this.SetOrganizationValueRequired()
                $HyperVIdentity = $thisIdentity -join "," -replace "{Hyper-V}", "NT Virtual Machine\\Virtual Machines"
                $NoHyperVIdentity = $thisIdentity.Where( {$PSItem -ne "{Hyper-V}"}) -join ","
                $this.set_OrganizationValueTestString("'{0}' -match '^($HyperVIdentity|$NoHyperVIdentity)$'")
            }
        }

        # add the results reguardless so they are easier to update
        $this.Identity = $thisIdentity -Join ","
        #return $return
    }

    [void] SetForce ()
    {
        if ( Test-SetForceFlag -CheckContent $this.SplitCheckContent )
        {
            $this.set_Force( $true )
        }
        else
        {
            $this.set_Force( $false )
        }
    }

    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        if ( Test-MultipleUserRightsAssignment -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
        {
            return $true
        }

        return $false
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleUserRightsAssignment -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
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

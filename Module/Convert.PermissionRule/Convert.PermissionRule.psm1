#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
Class PermissionRule : STIG
{
    [string] $Path
    [object[]] $AccessControlEntry
    [bool] $Force

    PermissionRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
    }

    # Methods

    [void] SetPath ( )
    {
        $thisPath = Get-PermissionTargetPath -StigString $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPath ) )
        {
            $this.set_Path( $thisPath )
        }
    }

    [void] SetForce ( )
    {
        # For now we're setting a default value. Later there could be additional logic here
        $this.set_Force($true)
    }

    [void] SetAccessControlEntry ( )
    {
        $thisAccessControlEntry = Get-PermissionAccessControlEntry -StigString $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisAccessControlEntry ) )
        {
            foreach( $principal in $thisAccessControlEntry.Principal )
            {
                $this.SetStatus( $principal )
            }

            foreach ( $rights in $thisAccessControlEntry.Rights )
            {
                if ( $rights -eq 'blank' )
                {
                    $this.SetStatus( "", $true )
                    continue
                }
                $this.SetStatus( $rights )
            }

            $this.set_AccessControlEntry( $thisAccessControlEntry )
        }
    }

    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        $permissionPaths = Get-PermissionTargetPath -StigString ([STIG]::SplitCheckContent( $CheckContent ) )
        return ( Test-MultiplePermissionRule -PermissionPath $permissionPaths )
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultiplePermissionRule -CheckContent ([STIG]::SplitCheckContent( $CheckContent ) ) )
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

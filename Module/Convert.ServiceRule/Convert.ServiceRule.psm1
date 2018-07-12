#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
Class ServiceRule : STIG
{
    [string] $ServiceName
    [string] $ServiceState
    [string] $StartupType
    [ensure] $Ensure

    # Constructor
    ServiceRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetServiceName ()
    {
        $thisServiceName = Get-ServiceName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceName ) )
        {
            $this.set_ServiceName( $thisServiceName )
            $this.set_Ensure( [ensure]::Present )
        }

    }

    [void] SetServiceState ()
    {
        $thisServiceState = Get-ServiceState -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceState ) )
        {
            $this.set_ServiceState( $thisServiceState )
        }
    }

    [void] SetStartupType ()
    {
        $thisServiceStartupType = Get-ServiceStartupType -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceStartupType ) )
        {
            $this.set_StartupType( $thisServiceStartupType )
        }
    }

    static [bool] HasMultipleRules ( [string] $Servicename )
    {
        return ( Test-MultipleServiceRule -ServiceName $Servicename )
    }

    static [string[]] SplitMultipleRules ( [string] $ServiceName )
    {
        return ( Split-MultipleServiceRule -ServiceName $Servicename )
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

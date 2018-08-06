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

    .PARAMETER ServiceName

    .PARAMETER ServiceState

    .PARAMETER StartupType

    .PARAMETER Ensure

    .EXAMPLE
#>
Class ServiceRule : STIG
{
    [string] $ServiceName
    [string] $ServiceState
    [string] $StartupType
    [ensure] $Ensure

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    ServiceRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetServiceName ()
    {
        $thisServiceName = Get-ServiceName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceName ) )
        {
            $this.set_ServiceName( $thisServiceName )
            $this.set_Ensure( [ensure]::Present )
        }

    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetServiceState ()
    {
        $thisServiceState = Get-ServiceState -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceState ) )
        {
            $this.set_ServiceState( $thisServiceState )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetStartupType ()
    {
        $thisServiceStartupType = Get-ServiceStartupType -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceStartupType ) )
        {
            $this.set_StartupType( $thisServiceStartupType )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ServiceName

        .EXAMPLE
    #>
    static [bool] HasMultipleRules ( [string] $Servicename )
    {
        return ( Test-MultipleServiceRule -ServiceName $Servicename )
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ServiceName

        .EXAMPLE
    #>
    static [string[]] SplitMultipleRules ( [string] $ServiceName )
    {
        return ( Split-MultipleServiceRule -ServiceName $Servicename )
    }

    #endregion
}

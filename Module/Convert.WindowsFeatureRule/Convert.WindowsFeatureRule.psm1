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

    .PARAMETER FeatureName

    .PARAMETER InstallState

    .EXAMPLE
#>
Class WindowsFeatureRule : STIG
{
    [string] $FeatureName
    [string] $InstallState

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    WindowsFeatureRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
    }

    #region Methods

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetFeatureName ()
    {
        $thisFeatureName = Get-WindowsFeatureName -CheckContent $this.RawString

        if ( -not $this.SetStatus( $thisFeatureName ) )
        {
            $this.set_FeatureName( $thisFeatureName )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER StigRule

        .EXAMPLE
    #>
    [void] SetFeatureInstallState ()
    {
        $thisInstallState = Get-FeatureInstallState -CheckContent $this.RawString

        if ( -not $this.SetStatus( $thisInstallState ) )
        {
            $this.set_InstallState( $thisInstallState )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER StigRule

        .EXAMPLE
    #>
    static [bool] HasMultipleRules ( [string] $FeatureName )
    {
        return ( Test-MultipleWindowsFeatureRule -FeatureName $FeatureName )
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER StigRule

        .EXAMPLE
    #>
    static [string[]] SplitMultipleRules ( [string] $FeatureName )
    {
        return ( Split-WindowsFeatureRule -FeatureName $FeatureName )
    }

    #endregion
}

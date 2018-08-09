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

    .PARAMETER MitigationTarget

    .PARAMETER Enable

    .PARAMETER Disable

#>
Class ProcessMitigationRule:STIG
{
    [string] $MitigationTarget
    [string] $Enable
    [string] $Disable

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a ProcessMitigationRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    ProcessMitigationRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS

        .DESCRIPTION

    #>
    [void] SetMitigationTargetName ()
    {
        $thisMitigationTargetName = Get-MitigationTargetName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisMitigationTargetName ) )
        {
            $this.set_MitigationTarget( $thisMitigationTargetName )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

    #>
    [void] SetMitigationToEnable ()
    {
        $thisMitigation = Get-MitigationPolicyToEnable -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisMitigation ) )
        {
            $this.set_Enable( $thisMitigation )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER MitigationTarget

    #>
    static [bool] HasMultipleRules ( [string] $MitigationTarget )
    {
        return ( Test-MultipleProcessMitigationRule -MitigationTarget $MitigationTarget )
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER MitigationTarget

    #>
    static [string[]] SplitMultipleRules ( [string] $MitigationTarget )
    {
        return ( Split-ProcessMitigationRule -MitigationTarget $MitigationTarget )
    }

    #endregion
}

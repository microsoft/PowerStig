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

    .PARAMETER Subcategory

    .PARAMETER AuditFlag

    .PARAMETER Ensure

    .EXAMPLE
#>
Class AuditPolicyRule : STIG
{
    [string] $Subcategory
    [string] $AuditFlag
    [string] $Ensure

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    AuditPolicyRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetSubcategory ()
    {
        $thisSubcategory = Get-AuditPolicySubCategory -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisSubcategory ) )
        {
            $this.set_Subcategory( $thisSubcategory )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetAuditFlag ()
    {
        $thisAuditFlag = Get-AuditPolicyFlag -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisAuditFlag ) )
        {
            $this.set_AuditFlag( $thisAuditFlag )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER EnsureFlag

        .EXAMPLE
    #>
    [void] SetEnsureFlag ( [Ensure] $EnsureFlag )
    {
        $this.Ensure = $EnsureFlag
    }
    #endregion
}

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

    .PARAMETER Extension

    .PARAMETER MimeType

    .PARAMETER Ensure

    .EXAMPLE
#>
Class MimeTypeRule : STIG
{
    [string] $Extension
    [string] $MimeType
    [string] $Ensure

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    MimeTypeRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetExtension ()
    {
        $thisExtension = Get-Extension -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisExtension ) )
        {
            $this.set_Extension( $thisExtension )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetMimeType ()
    {
        $thisMimeType = Get-MimeType -Extension $this.Extension

        if ( -not $this.SetStatus( $thisMimeType ) )
        {
            $this.set_MimeType( $thisMimeType )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetEnsure ()
    {
        $thisEnsure = Get-Ensure -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisEnsure ) )
        {
            $this.set_Ensure( $thisEnsure )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER CheckContent

        .EXAMPLE
    #>
    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        return Test-MultipleMimeTypeRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleMimeTypeRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
    }

    #endregion
}

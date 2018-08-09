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
        Convert the contents of an xccdf check-content element into a mime type object
    .DESCRIPTION
        The MimeTypeRule class is used to extract mime types from the
        check-content of the xccdf. Once a STIG rule is identifed as an
        mime type rule, it is passed to the MimeTypeRule class for parsing
        and validation.
    .PARAMETER Extension
        The Name of the extension
    .PARAMETER MimeType
        The mime type
    .PARAMETER Ensure
        A present or absent flag
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
            Converts a xccdf stig rule element into a MimeTypeRule
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
            Extracts the extension name from the check-content and sets the value
        .DESCRIPTION
            Gets the extension name from the xccdf content and sets the value.
            If the extension name that is returned is not valid, the parser
            status is set to fail
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
            Extracts the mime type from the check-content and sets the value
        .DESCRIPTION
            Gets the mime type from the xccdf content and sets the value.
            If the mime type that is returned is not valid, the parser
            status is set to fail
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
            Sets the ensure flag to the provided value
        .DESCRIPTION
            Sets the ensure flag to the provided value
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

    #>
    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        return Test-MultipleMimeTypeRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER CheckContent

    #>
    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleMimeTypeRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
    }

    #endregion
}

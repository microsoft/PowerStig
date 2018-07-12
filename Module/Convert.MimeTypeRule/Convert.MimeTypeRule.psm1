#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
Class MimeTypeRule : STIG
{
    [string] $Extension
    [string] $MimeType
    [string] $Ensure

    # Constructors
    MimeTypeRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetExtension ( )
    {
        $thisExtension = Get-Extension -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisExtension ) )
        {
            $this.set_Extension( $thisExtension )
        }
    }

    [void] SetMimeType ( )
    {
        $thisMimeType = Get-MimeType -Extension $this.Extension

        if ( -not $this.SetStatus( $thisMimeType ) )
        {
            $this.set_MimeType( $thisMimeType )
        }
    }

    [void] SetEnsure ( )
    {
        $thisEnsure = Get-Ensure -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisEnsure ) )
        {
            $this.set_Ensure( $thisEnsure )
        }
    }

    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        return Test-MultipleMimeTypeRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleMimeTypeRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
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

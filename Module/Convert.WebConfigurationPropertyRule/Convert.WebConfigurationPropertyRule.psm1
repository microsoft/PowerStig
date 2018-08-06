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

    .PARAMETER ConfigSection

    .PARAMETER Key

    .PARAMETER Value

    .EXAMPLE
#>
Class WebConfigurationPropertyRule : STIG
{
    [string] $ConfigSection
    [string] $Key
    [string] $Value

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    WebConfigurationPropertyRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetConfigSection ()
    {
        $thisConfigSection = Get-ConfigSection -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisConfigSection ) )
        {
            $this.set_ConfigSection( $thisConfigSection )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetKeyValuePair ()
    {
        $thisKeyValuePair = Get-KeyValuePair -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisKeyValuePair ) )
        {
            $this.set_Key( $thisKeyValuePair.Key )
            $this.set_Value( $thisKeyValuePair.Value )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [Boolean] IsOrganizationalSetting ()
    {
        if ( -not [String]::IsNullOrEmpty( $this.key ) -and [String]::IsNullOrEmpty( $this.value ) )
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetOrganizationValueTestString ()
    {
        $thisOrganizationValueTestString = Get-OrganizationValueTestString -Key $this.key

        if ( -not $this.SetStatus( $thisOrganizationValueTestString ) )
        {
            $this.set_OrganizationValueTestString( $thisOrganizationValueTestString )
            $this.set_OrganizationValueRequired( $true )
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
        return Test-MultipleWebConfigurationPropertyRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER CheckContent

        .EXAMPLE
    #>
    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleWebConfigurationPropertyRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
    }

    #endregion
}

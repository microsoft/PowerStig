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

    .PARAMETER Key

    .PARAMETER ValueName

    .PARAMETER ValueData

    .PARAMETER ValueType

    .PARAMETER Ensure

    .EXAMPLE
#>
Class RegistryRule : STIG
{
    [string] $Key
    [string] $ValueName
    [string[]] $ValueData
    [string] $ValueType
    [ensure] $Ensure

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    RegistryRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetKey ()
    {
        $thisKey = Get-RegistryKey -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisKey ) )
        {
            $this.set_Key( $thisKey )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetValueName ()
    {
        $thisValueName = Get-RegistryValueName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisValueName ) )
        {
            $this.set_ValueName( $thisValueName )
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [void] SetValueType ()
    {
        $thisValueType = Get-RegistryValueType -CheckContent $this.SplitCheckContent

        if ($thisValueType -ne "Does Not Exist")
        {
            if ( -not $this.SetStatus( $thisValueType ) )
            {
                $this.set_ValueType( $thisValueType )
            }
        }
        else {
            $this.SetEnsureFlag([Ensure]::Absent)
        }
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueDataString

        .EXAMPLE
    #>
    [bool] TestValueDataStringForRange ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataContainsRange -ValueDataString $ValueDataString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #>
    [string] GetValueData ()
    {
        return Get-RegistryValueData -CheckContent $this.SplitCheckContent
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueDataString

        .EXAMPLE
    #>
    [bool] IsDataBlank ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataIsBlank -ValueDataString $ValueDataString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueDataString

        .EXAMPLE
    #>
    [bool] IsDataEnabledOrDisabled ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataIsEnabledOrDisabled -ValueDataString $ValueDataString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueType

        .PARAMETER ValueData

        .EXAMPLE
    #>
    [string] GetValidEnabledOrDisabled ( [string] $ValueType, [string] $ValueData )
    {
        return Get-ValidEnabledOrDisabled -ValueType $ValueType -ValueData $ValueData
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueDataString

        .EXAMPLE
    #>
    [bool] IsDataHexCode ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataIsHexCode -ValueDataString $ValueDataString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueDataString

        .EXAMPLE
    #>
    [int] GetIntegerFromHex ( [string] $ValueDataString )
    {
        return Get-IntegerFromHex -ValueDataString $ValueDataString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueDataString
        .EXAMPLE
    #>
    [bool] IsDataInteger ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataIsInteger -ValueDataString $ValueDataString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueDataString

        .EXAMPLE
    #>
    [string] GetNumberFromString ( [string] $ValueDataString )
    {
        return Get-NumberFromString -ValueDataString $ValueDataString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER ValueDataString

        .EXAMPLE
    #>
    [string[]] FormatMultiStringRegistryData ( [string] $ValueDataString )
    {
        return Format-MultiStringRegistryData -ValueDataString $ValueDataString
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER CheckStrings

        .EXAMPLE
    #>
    [string[]] GetMultiValueRegistryStringData ( [string[]] $CheckStrings )
    {
        return Get-MultiValueRegistryStringData -CheckStrings $CheckStrings
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER Ensure

        .EXAMPLE
    #>
    [void] SetEnsureFlag ( [Ensure] $Ensure )
    {
        $this.Ensure = $Ensure
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER CheckContent

        .EXAMPLE
    #>
    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        return Test-MultipleRegistryEntries -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER CheckContent

        .EXAMPLE
    #>
    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleRegistryEntries -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
    }
}
#endregion

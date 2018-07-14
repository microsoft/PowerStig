#region Header
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
#endregion
#region Class
Class RegistryRule : STIG
{
    [string] $Key

    [string] $ValueName

    [string[]] $ValueData

    [string] $ValueType

    [ensure] $Ensure

    # Constructors
    RegistryRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    [void] SetKey ( )
    {
        $thisKey = Get-RegistryKey -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisKey ) )
        {
            $this.set_Key( $thisKey )
        }
    }

    [void] SetValueName ( )
    {
        $thisValueName = Get-RegistryValueName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisValueName ) )
        {
            $this.set_ValueName( $thisValueName )
        }
    }

    [void] SetValueType ( )
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

    [bool] TestValueDataStringForRange ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataContainsRange -ValueDataString $ValueDataString
    }

    [string] GetValueData ( )
    {
        return Get-RegistryValueData -CheckContent $this.SplitCheckContent
    }

    [bool] IsDataBlank ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataIsBlank -ValueDataString $ValueDataString
    }

    [bool] IsDataEnabledOrDisabled ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataIsEnabledOrDisabled -ValueDataString $ValueDataString
    }

    [string] GetValidEnabledOrDisabled ( [string] $ValueType, [string] $ValueData )
    {
        return Get-ValidEnabledOrDisabled -ValueType $ValueType -ValueData $ValueData
    }

    [bool] IsDataHexCode ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataIsHexCode -ValueDataString $ValueDataString
    }

    [int] GetIntegerFromHex ( [string] $ValueDataString )
    {
        return Get-IntegerFromHex -ValueDataString $ValueDataString
    }

    [bool] IsDataInteger ( [string] $ValueDataString )
    {
        return Test-RegistryValueDataIsInteger -ValueDataString $ValueDataString
    }

    [string] GetNumberFromString ( [string] $ValueDataString )
    {
        return Get-NumberFromString -ValueDataString $ValueDataString
    }

    [string[]] FormatMultiStringRegistryData ( [string] $ValueDataString )
    {
        return Format-MultiStringRegistryData -ValueDataString $ValueDataString
    }

    [string[]] GetMultiValueRegistryStringData ( [string[]] $CheckStrings )
    {
        return Get-MultiValueRegistryStringData -CheckStrings $CheckStrings
    }

    [void] SetEnsureFlag ( [Ensure] $Ensure )
    {
        $this.Ensure = $Ensure
    }

    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        return Test-MultipleRegistryEntries -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleRegistryEntries -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
    }
}
#endregion

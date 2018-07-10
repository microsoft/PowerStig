#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
Class WebConfigurationPropertyRule : STIG
{
    [string] $ConfigSection
    [string] $Key
    [string] $Value

    # Constructors
    WebConfigurationPropertyRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetConfigSection ( )
    {
        $thisConfigSection = Get-ConfigSection -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisConfigSection ) )
        {
            $this.set_ConfigSection( $thisConfigSection )
        }
    }

    [void] SetKeyValuePair ( )
    {
        $thisKeyValuePair = Get-KeyValuePair -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisKeyValuePair ) )
        {
            $this.set_Key( $thisKeyValuePair.Key )
            $this.set_Value( $thisKeyValuePair.Value )
        }
    }

    [Boolean] IsOrganizationalSetting ( )
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

    [void] SetOrganizationValueTestString ( )
    {
        $thisOrganizationValueTestString = Get-OrganizationValueTestString -Key $this.key

        if ( -not $this.SetStatus( $thisOrganizationValueTestString ) )
        {
            $this.set_OrganizationValueTestString( $thisOrganizationValueTestString )
            $this.set_OrganizationValueRequired( $true )
        }
    }

    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        return Test-MultipleWebConfigurationPropertyRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleWebConfigurationPropertyRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
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

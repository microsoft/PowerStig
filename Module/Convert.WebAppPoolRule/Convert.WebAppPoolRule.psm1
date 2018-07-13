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
Class WebAppPoolRule : STIG
{
    [string] $Key
    [string] $Value

    # Constructors
    WebAppPoolRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
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
}
#endregion

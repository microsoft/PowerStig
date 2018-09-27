# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

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
        Convert the contents of an xccdf check-content element into a WebAppPoolRule object
    .DESCRIPTION
        The WebAppPoolRule class is used to extract the webapp pool settings
        from the check-content of the xccdf. Once a STIG rule is identified as a
        webapp rule, it is passed to the WebAppPoolRule class for parsing
        and validation.
    .PARAMETER Key
        The name of the key in the web.config file
    .PARAMETER Value
        The value the web.config key should be set to
#>
Class WebAppPoolRule : Rule
{
    [string] $Key
    [string] $Value
    [String] $DscResource = 'xWebAppPool'

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf STIG rule element into a WebAppPoolRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    WebAppPoolRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the key value pair from the check-content and sets the value
        .DESCRIPTION
            Gets the key value pair from the xccdf content and sets the value.
            If the value that is returned is not valid, the parser status is
            set to fail.
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
            Tests if and organizational value is required
        .DESCRIPTION
            Tests if and organizational value is required
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
            Set the organizational value
        .DESCRIPTION
            Extracts the organizational value from the key and then sets the value
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

    #endregion
}

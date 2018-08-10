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
        Convert the contents of an xccdf check-content element into a
        WebConfigurationPropertyRule object
    .DESCRIPTION
        The WebConfigurationPropertyRule class is used to extract the web
        configuration settings from the check-content of the xccdf. Once a STIG
        rule is identified as a web configuration property rule, it is passed
        to the WebConfigurationPropertyRule class for parsing and validation.
    .PARAMETER ConfigSection
        The section of the web.config to evaluate
    .PARAMETER Key
        The key in the web.config to evaluate
    .PARAMETER Value
        The value the web.config key should be set to
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
            Converts a xccdf STIG rule element into a WebConfigurationPropertyRule
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
            Extracts the config section from the check-content and sets the value
        .DESCRIPTION
            Gets the config section from the xccdf content and sets the value.
            If the section that is returned is not valid, the parser status is
            set to fail.
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

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks
        .DESCRIPTION
            Search the rule text to determine if multiple web configurations are defined
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        return Test-MultipleWebConfigurationPropertyRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    <#
        .SYNOPSIS
            Splits a rule into multiple checks
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. This method splits a web configuration into multiple rules.
            Each split rule id is appended with a dot and letter to keep reporting
            per the ID consistent. An example would be is V-1000 contained 2
            checks, then SplitMultipleRules would return 2 objects with rule ids
            V-1000.a and V-1000.b
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleWebConfigurationPropertyRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
    }

    #endregion
}

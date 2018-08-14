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
        Convert the contents of an xccdf check-content element into a fileContent object
    .DESCRIPTION
        The FileContentRule class is used to manage STIGs for applications that utilize a
        configuration file to manage security settings
    .PARAMETER Key
        Specifies the name of the key pertaining to a configuration setting
    .PARAMETER Value
        Specifies the value of the configuration setting

#>
Class FileContentRule : STIG
{
    [string] $Key
    [string] $Value

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a FileContentRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    FileContentRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods
    <#
        .SYNOPSIS
            Extracts the key name from the check-content and sets the value
        .DESCRIPTION
            Gets the key name from the xccdf content and sets the
            value. If the key name that is returned is not valid,
            the parser status is set to fail
    #>
    [void] SetKeyName ()
    {
        $thisKeyName = (Get-KeyValuePair $this.SplitCheckContent).Key

        if ( -not $this.SetStatus( $thisKeyName ) )
        {
            $this.set_Key( $thisKeyName )
        }
    }

    <#
        .SYNOPSIS
            Extracts the key value from the check-content and sets the value
        .DESCRIPTION
            Gets the key value from the xccdf content and sets the
            value. If the key value that is returned is not valid,
            the parser status is set to fail
    #>
    [void] SetValue ()
    {
        $thisValue = (Get-KeyValuePair $this.SplitCheckContent).Value

        if ( -not $this.SetStatus( $thisValue ) )
        {
            $this.set_Value( $thisValue )
        }
    }

    <#
        .SYNOPSIS
            Tests if a rules contains more than one check
        .DESCRIPTION
            Gets the path defined in the rule from the xccdf content and then
            checks for the existance of multuple entries.
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        $keyValuePairs = Get-KeyValuePair -CheckContent ([STIG]::SplitCheckContent( $CheckContent ) )
        return ( Test-MultipleFileContentRule -KeyValuePair $keyValuePairs )
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        $splitFileContentRules = Get-KeyValuePair -SplitCheckContent -CheckContent ([STIG]::SplitCheckContent($CheckContent))
        return $splitFileContentRules
    }
}

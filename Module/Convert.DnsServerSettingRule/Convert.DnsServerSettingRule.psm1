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
        Convert the contents of an xccdf check-content element into an Dns Server
        Setting object
    .DESCRIPTION
        The DnsServerSettingRule class is used to extract the Dns Server settings
        from the check-content of the xccdf. Once a STIG rule is identified as a
        DNS server setting, it is passed to the DnsServerSettingRule class for
        parsing and validation.
    .PARAMETER PropertyName
        The name of the property to configure
    .PARAMETER PropertyValue
        The value to set the proerty to
#>
Class DnsServerSettingRule : Rule
{
    [string] $PropertyName
    [string] $PropertyValue
    [String] $DscResource = 'xDnsServerSetting'

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a DnsServerSettingRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    DnsServerSettingRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the DNS server setting name from the check-content and sets
            the value
        .DESCRIPTION
            Gets the DNS server setting name from the xccdf content and sets the
            value. If the DNS server setting that is returned is not a valid name,
            the parser status is set to fail.
    #>
    [void] SetDnsServerPropertyName ( )
    {
        $thisDnsServerSettingPropertyName = Get-DnsServerSettingProperty -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDnsServerSettingPropertyName ) )
        {
            $this.set_PropertyName($thisDnsServerSettingPropertyName)
        }
    }

    <#
        .SYNOPSIS
            Extracts the DNS server setting value from the check-content and
            sets the value
        .DESCRIPTION
            Gets the DNS server setting value from the xccdf content and sets
            the value. If the DNS server setting that is returned is not a valid
            property, the parser status is set to fail.
    #>
    [void] SetDnsServerPropertyValue ( )
    {
        $thisDnsServerSettingPropertyValue = Get-DnsServerSettingPropertyValue -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDnsServerSettingPropertyValue ) )
        {
            $this.set_PropertyValue($thisDnsServerSettingPropertyValue)
        }
    }
    #endregion
}

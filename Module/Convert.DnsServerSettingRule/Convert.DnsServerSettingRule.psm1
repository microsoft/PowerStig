#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
Class DnsServerSettingRule : STIG
{
    [string] $PropertyName
    [string] $PropertyValue

    # Constructors
    DnsServerSettingRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }
    # Methods
    [void] SetDnsServerPropertyName ( )
    {
        $thisDnsServerSettingPropertyName = Get-DnsServerSettingProperty -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDnsServerSettingPropertyName ) )
        {
            $this.set_PropertyName($thisDnsServerSettingPropertyName)
        }
    }

    [void] SetDnsServerPropertyValue ( )
    {
        $thisDnsServerSettingPropertyValue = Get-DnsServerSettingPropertyValue -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDnsServerSettingPropertyValue ) )
        {
            $this.set_PropertyValue($thisDnsServerSettingPropertyValue)
        }
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

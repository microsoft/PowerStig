# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\common\enum.psm1
using module .\StigClass.psm1
#endregion
#region Class Definition
Class WinEventLogRule : STIG
{
    [string] $LogName
    [bool]   $IsEnabled

    # Constructors
    WinEventLogRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetWinEventLogName ( )
    {
        $thisDnsWinEventLogName = Get-DnsServerWinEventLogName -StigString $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDnsWinEventLogName ) )
        {
            $this.set_LogName($thisDnsWinEventLogName)
        }
    }

    [void] SetWinEventLogIsEnabled ( )
    {
        # the dns stig always sets this to true
        $this.IsEnabled = $true
    }

}
#endregion
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the Dns Server Windows event log name
#>
function Get-DnsServerWinEventLogName
{
    [CmdletBinding()]
    [OutputType( [string] )]
    Param
    (
        [parameter( Mandatory = $true)]
        [psobject] $StigString
    )

    # There is only one scenario to handle but we will use a switch to easily add additional scenarios
    switch ( $stigString )
    {
        { $StigString -match $script:RegularExpression.WinEventLogPath }
        {
            $dnsServerWinEventLogName = 'Microsoft-Windows-DnsServer/Analytical'

            break
        }
        Default
        {
        }
    }

    return $dnsServerWinEventLogName
}
#endregion

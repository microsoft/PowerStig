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

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a
        WinEventLogRule object
    .DESCRIPTION
        The WinEventLogRule class is used to extract the windows event log settings
        from the check-content of the xccdf. Once a STIG rule is identified as a
        windows event log rule, it is passed to the WinEventLogRule class for
        parsing and validation.
    .PARAMETER LogName
        The name of the log
    .PARAMETER IsEnabled
        The enabled status of the log
#>
Class WinEventLogRule : Rule
{
    [string] $LogName
    [bool] $IsEnabled

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf STIG rule element into a WinEventLogRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    WinEventLogRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the event log from the check-content and sets the value
        .DESCRIPTION
            Gets the event log from the xccdf content and sets the value. If
            the name that is returned is not valid, the parser status is set
            to fail.
    #>
    [void] SetWinEventLogName ()
    {
        $thisDnsWinEventLogName = Get-DnsServerWinEventLogName -StigString $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDnsWinEventLogName ) )
        {
            $this.set_LogName($thisDnsWinEventLogName)
        }
    }

    <#
        .SYNOPSIS
            Extracts the event log enabled status from the check-content and
            sets the value
        .DESCRIPTION
            Gets the event log enabled status from the xccdf content and sets the
            value. If the enabled status that is returned is not valid, the
            parser status is set to fail.
    #>
    [void] SetWinEventLogIsEnabled ()
    {
        # The DNS STIG always sets this to true
        $this.IsEnabled = $true
    }

    #endregion
}

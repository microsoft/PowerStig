# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\WmiRule.psm1

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
        Convert the contents of an xccdf check-content element into a WmiRule object
    .DESCRIPTION
        The WmiRule class is used to extract the settings from rules that don't have
        and dedicated method of evaluation from the check-content of the xccdf.
        Once a STIG rule is identified as a WMI rule, it is passed to the WmiRule
        class for parsing and validation.

#>
Class WmiRuleConvert : WmiRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    WmiRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf STIG rule element into a Wmi Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    WmiRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        Switch ($this.rawString)
        {
            {$PSItem -Match "winver\.exe" }
            {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Service Pack"
                $this.Query = 'SELECT * FROM Win32_OperatingSystem'
                $this.Property = 'Version'
                $this.Operator = '-ge'

                $this.rawString -match "(?:Version\s*)(\d+(\.\d+)?)" | Out-Null

                $osMajMin = $matches[1]

                if ([int]$osMajMin -gt 6.3)
                {
                    [string]$osMajMin = '10.0'
                }

                $this.rawString -match "(?:Build\s*)(\d+)?" | Out-Null
                $osBuild = $matches[1]

                $this.Value = "$osMajMin.$osBuild"
                continue
            }
            {$PSItem -Match "Disk Management"}
            {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] File System Type"
                $this.Query = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
                $this.Property = 'FileSystem'
                $this.Operator = '-match'
                $this.Value = 'NTFS|ReFS'
            }
        }

        $this.DscResource = 'Script'
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "Disk Management" -or
            $CheckContent -Match "winver\.exe"
        )
        {
            return $true
        }
        return $false
    }
}

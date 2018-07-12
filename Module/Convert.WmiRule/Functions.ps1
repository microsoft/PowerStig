# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Processes the raw STIG string that has been identifed as a WMI test.
#>
function ConvertTo-WmiRule
{
    [CmdletBinding()]
    [OutputType([WmiRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $wmiRule = [wmiRule]::New( $StigRule )

    Switch ( $wmiRule.rawString )
    {
        {$PSItem -Match "Service Pack" }
        {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Service Pack"
            $query = 'SELECT * FROM Win32_OperatingSystem'
            $propertyName = 'Version'
            $operatorString = '-ge'

            $wmiRule.rawString -match "\d\.\d" | Out-Null
            $osMajMin = $matches[0]

            ($wmiRule.rawString -match "\(Build\s\d{1,}\)" | Out-Null )
            $osBuild = $matches[0] -replace "\(|\)|Build|\s", ""

            $valueName = "$osMajMin.$osBuild"
            continue
        }
        {$PSItem -Match "Disk Management"}
        {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] File System Type"
            $query = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
            $propertyName = 'FileSystem'
            $operatorString = '-match'
            $valueName = 'NTFS|ReFS'
        }
    }
    $wmiRule.SetStigRuleResource()
    $wmiRule.set_Query( $query )
    $wmiRule.set_Property( $propertyName )
    $wmiRule.set_Operator( $operatorString )
    $wmiRule.set_Value( $valueName )
    return $wmiRule
}
#endregion

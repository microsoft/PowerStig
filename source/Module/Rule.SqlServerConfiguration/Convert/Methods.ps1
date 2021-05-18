# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the SqlServerConfiguration OptionName from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-OptionName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkcontent) 
    {
        {$PSItem -Match "EXEC SP_CONFIGURE 'xp_cmdshell';"}
        {
            $optionName = "xp_cmdshell"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'clr enabled';"}
        {
            $optionName = "clr enabled"
        }
        {$PSItem -Match "WHERE name = 'common criteria compliance enabled'"}
        {
            $optionName = "common criteria compliance enabled"
        }
        {$PSItem -Match "EXEC sp_configure 'filestream access level'"}
        {
            $optionName = "filestream access level"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'Ole Automation Procedures';"}
        {
            $optionName = "Ole Automation Procedures"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'user options';"}
        {
            $optionName = "user options"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'remote access';"}
        {
            $optionName = "remote access"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'hadoop connectivity';"}
        {
            $optionName = "hadoop connectivity"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'allow polybase export';"}
        {
            $optionName = "allow polybase export"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'remote data archive';"}
        {
            $optionName = "remote data archive"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'external scripts enabled';"}
        {
            $optionName = "external scripts enabled"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'replication xps';"}
        {
            $optionName = "Replication XPs"
        }       
    }
    return $optionName
}

<#
    .SYNOPSIS
        Sets the SqlServerConfiguration OptionValue from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-OptionValue
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    #STIG guidance states most configuration options should be disabled unless required. Default state is set to disable.

    switch ($checkContent)
    {
        {$PSItem -Match "WHERE name = 'common criteria compliance enabled'"}
        {
            $optionValue = "1"
        }
        Default
        {
            $optionValue = "0"
        }
    }   
    return $optionValue
}

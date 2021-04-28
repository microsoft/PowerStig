# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the SqlServerDsc OptionName from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-OptionName{
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
            $OptionName = "xp_cmdshell"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'clr enabled';"}
        {
            $OptionName = "clr enabled"
        }
        {$PSItem -Match "WHERE name = 'common criteria compliance enabled'"}
        {
            $OptionName = "common criteria compliance enabled"
        }
        {$PSItem -Match "EXEC sp_configure 'filestream access level'"}
        {
            $OptionName = "filestream access level"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'Ole Automation Procedures';"}
        {
            $OptionName = "Ole Automation Procedures"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'user options';"}
        {
            $OptionName = "user options"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'remote access';"}
        {
            $OptionName = "remote access"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'hadoop connectivity';"}
        {
            $OptionName = "hadoop connectivity"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'allow polybase export';"}
        {
            $OptionName = "allow polybase export"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'remote data archive';"}
        {
            $OptionName = "remote data archive"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'external scripts enabled';"}
        {
            $OptionName = "external scripts enabled"
        }
        {$PSItem -Match "EXEC SP_CONFIGURE 'replication xps';"}
        {
            $OptionName = "Replication XPs"
        }       
    }
    return $OptionName
}

<#
    .SYNOPSIS
        Sets the SqlServerDsc OptionValue from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-OptionValue {
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    #STIG guidance states all configuration options should be disabled unless required. Default state is set to disable.

    switch ($checkContent)
    {
        {$PSItem -eq $false}
        {
            $OptionValue = "1"
        }
        Default
        {
            $OptionValue = "0"
        }
    }   
    return $OptionValue
}

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
        {$PSItem -Match "(?<=EXEC SP_CONFIGURE\s').+?(?=')"}
        {
            $optionName = ($PSItem | Select-String -Pattern "(?<=EXEC SP_CONFIGURE\s').+?(?=')" -AllMatches).Matches[1]
        }
        {$PSItem -Match "WHERE name = 'common criteria compliance enabled'"}
        {
            $optionName = "common criteria compliance enabled"
        }
        {$PSItem -Match "EXEC sp_configure 'filestream access level'"}
        {
            $optionName = "filestream access level"
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

    # STIG guidance states most configuration options should be disabled unless required. Default state is set to disable.

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
